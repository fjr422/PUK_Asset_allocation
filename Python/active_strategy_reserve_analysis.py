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
asset_names = (PortFolioRegion.SmallCapUs.value, PortFolioRegion.TechEu.value, PortFolioRegion.MarketEu.value, PortFolioRegion.SmallCapEu.value)

portfolio_universe = portfolio_strategies.PortfolioStrategy(fama_french_portfolios.filter(pl.col("N_Portfolios") == 6))
current_active_reserve_strategy = active_reserve_strategy.ActiveReserveStrategy(asset_names, portfolio_universe, tdf_returns, tdf_weights, InvestmentStrategyPortfolios.RP)

current_active_reserve_strategy.active_reserve_strategy_return_input.portfolio_weights.write_csv(active_reserve_strategy_analysis_paths.active_reserve_weights_shifted_one_period_path)
current_active_reserve_strategy.active_reserve_strategy_return_input.portfolio_returns.write_csv(active_reserve_strategy_analysis_paths.active_reserve_returns_path)

# Analysis
schema_runs = {"TIME_PERIOD": pl.Date, "Value": pl.Float64, "Portfolio name": pl.String, "L_target": pl.Float64, "L_trigger": pl.Float64, "m": pl.Float64, "b": pl.Float64}

cppi_runs = pl.DataFrame(schema = schema_runs)
running_cppi_m = np.arange(1, 6, 0.05)
b = 1.0
l_target = common_var.l_target

def process_cppi(m):
    return current_active_reserve_strategy.cppi_strategies(float(m), b=b, l_target=l_target).with_columns(
        pl.lit(m).alias("m"),
        pl.lit(b).alias("b"),
        pl.lit(l_target).alias("L_target"),
        pl.lit(None).cast(pl.Float64).alias("L_trigger")
    ).select(
        schema_runs.keys()
    )


start = timeit.default_timer()
# Use ProcessPoolExecutor for parallel processing
if __name__ == '__main__':
    # Use ProcessPoolExecutor for parallel processing
    with ProcessPoolExecutor() as executor:
        # Map the 'm' values to process_cppi function concurrently
        results = list(executor.map(process_cppi, running_cppi_m))

    # Combine the results into a single DataFrame
    cppi_runs_value = pl.concat(results)

    # If you want to collect the final results into the original DataFrame
    cppi_runs = cppi_runs.vstack(cppi_runs_value)  # If needed, combine all results

# Output
cppi_runs.write_csv(active_reserve_strategy_analysis_paths.cppi_analysis_path)
end = timeit.default_timer()
print(f"Execution took {end-start} seconds")