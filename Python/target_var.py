import polars as pl
import numpy as np
from concurrent.futures import ProcessPoolExecutor
import timeit
import plotly.express as px

import common_var
import data
import portfolio_analysis
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
asset_names = tuple([names.value for names in portfolio_analysis.chosen_assets])

portfolio_universe = portfolio_strategies.PortfolioStrategy(fama_french_portfolios.filter(pl.col("N_Portfolios") == 6))
current_active_reserve_strategy = active_reserve_strategy.ActiveReserveStrategy(asset_names, portfolio_universe, tdf_returns, tdf_weights, InvestmentStrategyPortfolios.RP)

current_active_reserve_strategy.active_reserve_strategy_return_input.portfolio_weights.write_csv(active_reserve_strategy_analysis_paths.active_reserve_weights_shifted_one_period_path)
current_active_reserve_strategy.active_reserve_strategy_return_input.portfolio_returns.write_csv(active_reserve_strategy_analysis_paths.active_reserve_returns_path)

# Analysis
schema_runs = {"TIME_PERIOD": pl.Date, "Value": pl.Float64, "Initial guarantee": pl.Float64, "Strategy ID": pl.String, "Fund name": InvestmentStrategyPortfolios, "L_target": pl.Float64, "L_trigger": pl.Float64, "m": pl.Float64, "b": pl.Float64}

# Ranges for CPPI and L_trigger
running_cppi_m = np.arange(1, 6, 0.1)

l_target = common_var.l_target
running_l_trigger = np.arange(l_target + 0.05 , l_target + 0.5, 0.025)
b = 1.0

# Process CPPI strategy
def process_cppi(m: np.floating, l_trigger: np.floating):
    return current_active_reserve_strategy.cppi_strategies(m=float(m.round(4)), l_trigger=float(l_trigger.round(4)), l_target=l_target, b=b).with_columns(
        pl.lit(m).alias("m"),
        pl.lit(b).alias("b"),
        pl.lit(l_target).alias("L_target"),
        pl.lit(l_trigger).alias("L_trigger")
    ).select(
        schema_runs.keys()
    )


# Initialize empty DataFrames
cppi_runs = pl.DataFrame(schema=schema_runs)


# Function to run in parallel for CPPI processing
def run_cppi(m, l_trigger):
    return process_cppi(m, l_trigger)

# Run all tie-in trigger calculations in parallel
start = timeit.default_timer()
if __name__ == '__main__':
    with ProcessPoolExecutor() as executor:
        # Map the tie_in_trigger to parallel execution
        # Run all CPPI calculations in parallel
        cppi_runs_value = pl.DataFrame(schema = schema_runs)
        for l_trigger in running_l_trigger:
            cppi_runs_value.extend(pl.concat(executor.map(run_cppi, running_cppi_m, [l_trigger] * len(running_cppi_m))))

    cppi_runs = cppi_runs.vstack(cppi_runs_value)

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

cppi_terminal_values = extract_terminal(cppi_runs)


# Output
#cppi_runs.write_csv(active_reserve_strategy_analysis_paths.cppi_analysis_path)
cppi_terminal_values.write_csv(active_reserve_strategy_analysis_paths.cppi_terminal_values_path_target)
#tie_in_trigger_runs.write_csv(active_reserve_strategy_analysis_paths.tie_in_trigger_analysis_path)


end = timeit.default_timer()
print(f"Execution took {end-start} seconds")