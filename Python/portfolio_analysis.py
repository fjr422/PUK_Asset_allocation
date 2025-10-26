import polars as pl
import plotly.express as px

import common_var
import data
import portfolio_strategies
from enums import PortFolioRegion

# Paths
fama_french_paths = data.FamaFrenchPaths()
yield_curve_paths = data.YieldCurvePaths()
portfolio_analysis_paths = data.PortfolioAnalysisPaths()

# Input
fama_french_factors = pl.read_csv(fama_french_paths.fama_french_factors_path, try_parse_dates=True)
fama_french_portfolios = pl.read_csv(fama_french_paths.fama_french_portfolios_path, try_parse_dates=True)
spot_rates = pl.read_csv(yield_curve_paths.spot_rates_path, try_parse_dates=True)

# Preparing return on risk-free asset.
risk_free_values = spot_rates.select(
    ["TIME_PERIOD", "TIME_TO_MATURITY", "SPOTRATE"]
)
terminal_time_zc = spot_rates.select(
    pl.col("TIME_PERIOD").unique()
).with_columns(
    pl.lit(0).alias("TIME_TO_MATURITY").cast(pl.Int64),
    pl.lit(0.0).alias("SPOTRATE").cast(pl.Float64),
)

price_zc = pl.concat(
    [risk_free_values, terminal_time_zc]
).with_columns(
    pl.col("TIME_PERIOD").dt.month_start().dt.offset_by(pl.col("TIME_TO_MATURITY").cast(pl.String) + "mo").dt.month_end().alias("Portfolio")
).filter(
    (pl.col("Portfolio") >= common_var.first_tdf_pl)
).with_columns(
    ( - (pl.col("TIME_TO_MATURITY") / 12) * (pl.col("SPOTRATE") / 100)).exp().alias("ZC"),
)

risk_free_returns = price_zc.filter(
    (pl.col("Portfolio") <= common_var.last_tdf_pl)
).sort(
    ["Portfolio", "TIME_PERIOD"], descending = False
).with_columns(
    (100 * (pl.col("ZC") - pl.col("ZC").shift(1).over("Portfolio")) / pl.col("ZC").shift(1).over("Portfolio")).alias("Return")
).with_columns(
    (common_var.shift_date_by_months_pl(pl.col("Portfolio"), -common_var.tdf_end_in_months)).alias("TDF inception date"),
    ("TDF " +  pl.col("Portfolio").cast(pl.String)).alias("Portfolio")
)
#### Creating TDFs as portfolio enums: risk_free_returns.select(pl.col("Portfolio")).unique().with_columns((pl.col("Portfolio").str.replace_all(' ', '').str.replace_all('-', '_') + " = '" + pl.col("Portfolio") + "'").alias("Portfolio_Enum")).select("Portfolio_Enum").write_csv(portfolio_analysis_paths.tdf_enums_path)
## Defining weights
weights_tdf = portfolio_strategies.all_in_weights(risk_free_returns)

# Initialising portfolio universe
portfolio_universe = portfolio_strategies.PortfolioStrategy(fama_french_portfolios.filter(pl.col("N_Portfolios") == 6))

# Investable assets
long_assets = (PortFolioRegion.TechUs, PortFolioRegion.MarketUs, PortFolioRegion.SmallCapUs, PortFolioRegion.TechEu, PortFolioRegion.MarketEu, PortFolioRegion.SmallCapEu)
short_assets = (PortFolioRegion.MomEu, PortFolioRegion.MomUs, PortFolioRegion.SmbEu, PortFolioRegion.SmbUs, PortFolioRegion.MarketEu, PortFolioRegion.MarketUs, PortFolioRegion.RfEu)

# Dates to make efficient frontier
dates_efficient_frontier = pl.DataFrame(
    {"Year": [2009, 2014, 2019, 2024], "Month": [6] * 4, "Day": [30] * 4}
).with_columns(
    (pl.date(year = pl.col("Year"), month = pl.col("Month"), day = pl.col("Day"))).dt.month_end().alias("Date")
)

# Find the optimal predetermined strategies.
optimal_strategies_long_assets = portfolio_strategies.PortfolioStrategyAnalysis(portfolio_universe, long_assets, dates_efficient_frontier)
optimal_strategies_short_assets = portfolio_strategies.PortfolioStrategyAnalysis(portfolio_universe, short_assets, dates_efficient_frontier)
optimal_strategies_chosen_assets = portfolio_strategies.PortfolioStrategyAnalysis(portfolio_universe, common_var.chosen_assets, dates_efficient_frontier)





# Output
portfolio_universe.portfolio_universe_EUR.write_csv(portfolio_analysis_paths.portfolio_universe_path)

optimal_strategies_long_assets.optimal_strategies["Optimal strategies"].write_csv(portfolio_analysis_paths.optimal_portfolio_strategies_long)
optimal_strategies_long_assets.optimal_strategies["Efficient frontier"].write_csv(portfolio_analysis_paths.efficient_frontiers_long)
optimal_strategies_short_assets.optimal_strategies["Optimal strategies"].write_csv(portfolio_analysis_paths.optimal_portfolio_strategies_short)
optimal_strategies_short_assets.optimal_strategies["Efficient frontier"].write_csv(portfolio_analysis_paths.efficient_frontiers_short)
optimal_strategies_chosen_assets.optimal_strategies["Optimal strategies"].write_csv(portfolio_analysis_paths.optimal_portfolio_strategies_chosen_assets)
optimal_strategies_chosen_assets.optimal_strategies["Efficient frontier"].write_csv(portfolio_analysis_paths.efficient_frontiers_chosen_assets)

optimal_strategies_long_assets.values_active_portfolio.write_csv(portfolio_analysis_paths.optimal_long_portfolio_strategies_returns_path)
optimal_strategies_short_assets.values_active_portfolio.write_csv(portfolio_analysis_paths.optimal_short_portfolio_strategies_returns_path)
optimal_strategies_chosen_assets.values_active_portfolio.write_csv(portfolio_analysis_paths.optimal_chosen_assets_portfolio_strategies_returns_path)

risk_free_returns.write_csv(portfolio_analysis_paths.tdf_returns_path)
weights_tdf.write_csv(portfolio_analysis_paths.tdf_weights_path)
price_zc.write_csv(portfolio_analysis_paths.zc_prices)






