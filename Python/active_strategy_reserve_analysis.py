import polars as pl
import numpy as np
from concurrent.futures import ProcessPoolExecutor
import timeit
import plotly.express as px

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
asset_names = (PortFolioRegion.SmallCapUs.value, PortFolioRegion.TechEu.value, PortFolioRegion.MarketEu.value, PortFolioRegion.SmallCapEu.value)

portfolio_universe = portfolio_strategies.PortfolioStrategy(fama_french_portfolios.filter(pl.col("N_Portfolios") == 6))
current_active_reserve_strategy = active_reserve_strategy.ActiveReserveStrategy(asset_names, portfolio_universe, tdf_returns, tdf_weights, InvestmentStrategyPortfolios.RP)

current_active_reserve_strategy.active_reserve_strategy_return_input.portfolio_weights.write_csv(active_reserve_strategy_analysis_paths.active_reserve_weights_shifted_one_period_path)
current_active_reserve_strategy.active_reserve_strategy_return_input.portfolio_returns.write_csv(active_reserve_strategy_analysis_paths.active_reserve_returns_path)

# Analysis
schema_runs = {"TIME_PERIOD": pl.Date, "Value": pl.Float64, "Strategy ID": pl.String, "Fund name": InvestmentStrategyPortfolios, "L_target": pl.Float64, "L_trigger": pl.Float64, "m": pl.Float64, "b": pl.Float64}


running_cppi_m = np.arange(1, 6, 0.05)
running_l_trigger = np.arange(common_var.l_trigger, 3.0, 0.01)
b = 1.0

# Attempting different m for CPPI
def process_cppi(m):
    l_target = common_var.l_target
    return current_active_reserve_strategy.cppi_strategies(float(m), b=b, l_target=l_target).with_columns(
        pl.lit(m).alias("m"),
        pl.lit(b).alias("b"),
        pl.lit(l_target).alias("L_target"),
        pl.lit(None).cast(pl.Float64).alias("L_trigger")
    ).select(
        schema_runs.keys()
    )
# Attempting Different l_trigger levels.
def process_tie_in_trigger(l_trigger):
    l_target = common_var.l_target
    return current_active_reserve_strategy.tie_in_strategies(l_trigger = l_trigger, l_target = common_var.l_target).with_columns(
        pl.lit(None).cast(pl.Float64).alias("m"),
        pl.lit(None).cast(pl.Float64).alias("b"),
        pl.lit(l_target).alias("L_target"),
        pl.lit(l_trigger).cast(pl.Float64).alias("L_trigger")
    ).select(
        schema_runs.keys()
    )

# Run CPPI and Tie in parallel
cppi_runs = pl.DataFrame(schema = schema_runs)
tie_in_trigger_runs = pl.DataFrame(schema = schema_runs)
start = timeit.default_timer()
# Use ProcessPoolExecutor for parallel processing
if __name__ == '__main__':
    # Use ProcessPoolExecutor for parallel processing
    with ProcessPoolExecutor() as executor:
        # Map the 'm' values
        results_cppi = list(executor.map(process_cppi, running_cppi_m))
        results_tie_in_trigger = list(executor.map(process_tie_in_trigger, running_l_trigger))

    # Combine the results into a single DataFrame
    cppi_runs_value = pl.concat(results_cppi)
    tie_in_runs_value = pl.concat(results_tie_in_trigger)

    # Combine all results
    cppi_runs = cppi_runs.vstack(cppi_runs_value)
    tie_in_trigger_runs = tie_in_trigger_runs.vstack(tie_in_runs_value)


# Combining
def extract_terminal(df: pl.DataFrame):
    return df.filter(
        pl.col("Fund name") != InvestmentStrategyPortfolios.ShadowReserve
    ).group_by(
        ["TIME_PERIOD", "Strategy ID", "b", "m", "L_target", "L_trigger"]
    ).agg(
        pl.col("Value").sum()
    ).sort(
        ["Strategy ID", "b", "m", "L_target", "L_trigger", "TIME_PERIOD"], descending=True
    ).group_by(
        ["Strategy ID", "b", "m", "L_target", "L_trigger"]
    ).head(1).sort(
        ["Strategy ID", "b", "m", "L_target", "L_trigger"]
    )

cppi_terminal_values = extract_terminal(cppi_runs)

tie_in_terminal_values = extract_terminal(tie_in_trigger_runs)

# Output
cppi_runs.write_csv(active_reserve_strategy_analysis_paths.cppi_analysis_path)
cppi_terminal_values.write_csv(active_reserve_strategy_analysis_paths.cppi_terminal_values_path)
tie_in_trigger_runs.write_csv(active_reserve_strategy_analysis_paths.tie_in_trigger_analysis_path)
tie_in_terminal_values.write_csv(active_reserve_strategy_analysis_paths.tie_in_trigger_terminal_values_path)

end = timeit.default_timer()
print(f"Execution took {end-start} seconds")