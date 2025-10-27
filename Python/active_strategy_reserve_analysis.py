import polars as pl
import numpy as np
from concurrent.futures import ProcessPoolExecutor
import timeit

import common_var
import data
from enums import *
import portfolio_strategies
import active_reserve_strategy


# Paths
active_reserve_strategy_analysis_paths = data.ActiveReserveStrategyAnalysisPaths()

# Input
fama_french_portfolios = pl.read_csv(active_reserve_strategy_analysis_paths.fama_french_portfolios_path, try_parse_dates=True)
tdf_returns = pl.read_csv(active_reserve_strategy_analysis_paths.tdf_returns_path, try_parse_dates=True,  schema_overrides={"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion})
tdf_weights = pl.read_csv(active_reserve_strategy_analysis_paths.tdf_weights_path, try_parse_dates=True,  schema_overrides={"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion, "Portfolio strategy": InvestmentStrategyPortfolios})

## Parameters
asset_names = tuple([names.value for names in common_var.chosen_assets])

portfolio_universe_chosen = portfolio_strategies.PortfolioStrategy(fama_french_portfolios.filter(pl.col("N_Portfolios") == 6))

chosen_active_reserve_strategy = active_reserve_strategy.ActiveReserveStrategy(asset_names, portfolio_universe_chosen, tdf_returns, tdf_weights, InvestmentStrategyPortfolios.RP)
current_portfolio_strategy = active_reserve_strategy.ActiveReserveStrategy(asset_names, portfolio_universe_chosen, tdf_returns, tdf_weights, InvestmentStrategyPortfolios.MarketEu) # Using EU Market

chosen_active_reserve_strategy.active_reserve_strategy_return_input.portfolio_weights.write_csv(active_reserve_strategy_analysis_paths.active_reserve_weights_shifted_one_period_path)
chosen_active_reserve_strategy.active_reserve_strategy_return_input.portfolio_returns.write_csv(active_reserve_strategy_analysis_paths.active_reserve_returns_path)

# Analysis
schema_runs = {"TIME_PERIOD": pl.Date, "Value": pl.Float64, "Initial guarantee": pl.Float64, "Strategy ID": pl.String, "Fund name": InvestmentStrategyPortfolios, "L_target": pl.Float64, "L_trigger": pl.Float64, "m": pl.Float64, "b": pl.Float64}

## Current Tie-In and EU Market
current_tie_in = current_portfolio_strategy.tie_in_strategies(l_target = common_var.l_target, l_trigger = common_var.l_trigger).with_columns(
        pl.lit(None).alias("m"),
        pl.lit(None).alias("b"),
        pl.lit(common_var.l_target).alias("L_target"),
        pl.lit(common_var.l_trigger).alias("L_trigger")
    ).select(
        schema_runs.keys()
    )

# Ranges for CPPI and L_trigger
running_cppi_m = np.arange(1, 5, 0.2)

l_target = 1.25
running_l_trigger = np.arange(l_target + 0.05 , l_target + 0.5, 0.025)
b = 1.0

# Process CPPI strategy
def process_cppi(m: np.floating, l_trigger: np.floating):
    return chosen_active_reserve_strategy.cppi_strategies(m=float(m.round(4)), l_trigger=float(l_trigger.round(4)), l_target=l_target, b=b).with_columns(
        pl.lit(m).alias("m"),
        pl.lit(b).alias("b"),
        pl.lit(l_target).alias("L_target"),
        pl.lit(l_trigger).alias("L_trigger")
    ).select(
        schema_runs.keys()
    )

# Process tie-in strategy for each L_trigger
def process_tie_in_trigger(l_trigger):
    return chosen_active_reserve_strategy.tie_in_strategies(l_trigger=l_trigger, l_target=l_target).with_columns(
        pl.lit(None).cast(pl.Float64).alias("m"),
        pl.lit(None).cast(pl.Float64).alias("b"),
        pl.lit(l_target).alias("L_target"),
        pl.lit(l_trigger).cast(pl.Float64).alias("L_trigger")
    ).select(
        schema_runs.keys()
    )

# Initialize empty DataFrames
cppi_runs = pl.DataFrame(schema=schema_runs)
tie_in_trigger_runs = pl.DataFrame(schema=schema_runs)

# Function to run in parallel for tie-in trigger processing
def run_tie_in_trigger(l_trigger):
    return process_tie_in_trigger(l_trigger)

# Function to run in parallel for CPPI processing
def run_cppi(m, l_trigger):
    return process_cppi(m, l_trigger)

# Run all tie-in trigger calculations in parallel
start = timeit.default_timer()
if __name__ == '__main__':
    with ProcessPoolExecutor() as executor:
        # Map the tie_in_trigger to parallel execution
        results_tie_in_trigger = list(executor.map(run_tie_in_trigger, running_l_trigger))

        # Collect tie-in results into the DataFrame
        tie_in_runs_value = pl.concat(results_tie_in_trigger)

        # Run all CPPI calculations in parallel
        cppi_runs_value = pl.DataFrame(schema = schema_runs)
        for l_trigger in running_l_trigger:
            cppi_runs_value.extend(pl.concat(executor.map(run_cppi, running_cppi_m, [l_trigger] * len(running_cppi_m))))

    cppi_runs = cppi_runs.vstack(cppi_runs_value)
    tie_in_trigger_runs = tie_in_trigger_runs.vstack(tie_in_runs_value)

# Combining
def extract_terminal(df: pl.DataFrame):
    return df.filter(
        pl.col("Fund name") != InvestmentStrategyPortfolios.ShadowReserve
    ).group_by(
        ["TIME_PERIOD", "Strategy ID", "Initial guarantee", "b", "m", "L_target", "L_trigger"]
    ).agg(
        pl.col("Value").sum()
    ).sort(
        ["Strategy ID", "Initial guarantee", "b", "m", "L_target", "L_trigger", "TIME_PERIOD"], descending=True
    ).group_by(
        ["Strategy ID", "Initial guarantee", "b", "m", "L_target", "L_trigger"]
    ).head(1).sort(
        ["Strategy ID", "Initial guarantee", "b", "m", "L_target", "L_trigger"]
    )

current_tie_in_terminal_values = extract_terminal(current_tie_in)
cppi_terminal_values = extract_terminal(cppi_runs)
tie_in_terminal_values = extract_terminal(tie_in_trigger_runs)

# Output
current_tie_in.write_csv(active_reserve_strategy_analysis_paths.current_tie_in_eu_market_analysis_path)
current_tie_in_terminal_values.write_csv(active_reserve_strategy_analysis_paths.current_tie_in_eu_market_terminal_values_path)

cppi_runs.write_csv(active_reserve_strategy_analysis_paths.cppi_analysis_path(str(l_target)))
cppi_terminal_values.write_csv(active_reserve_strategy_analysis_paths.cppi_terminal_values_path_target(str(l_target)))
tie_in_trigger_runs.write_csv(active_reserve_strategy_analysis_paths.tie_in_trigger_analysis_path(str(l_target)))
tie_in_terminal_values.write_csv(active_reserve_strategy_analysis_paths.tie_in_trigger_terminal_values_path(str(l_target)))

end = timeit.default_timer()
print(f"Execution took {end-start} seconds")