import polars as pl
import plotly.express as px

import data
import portfolio_strategies
from enums import PortFolioRegion, InvestmentStrategyPortfolios

# Paths
fama_french_paths = data.FamaFrenchPaths()
yield_curve_paths = data.YieldCurvePaths()
portfolio_analysis_paths = data.PortfolioAnalysisPaths()

# Input
fama_french_factors = pl.read_csv(fama_french_paths.fama_french_factors_path, try_parse_dates=True)
fama_french_portfolios = pl.read_csv(fama_french_paths.fama_french_portfolios_path, try_parse_dates=True)
spot_rates = pl.read_csv(yield_curve_paths.spot_rates_path, try_parse_dates=True)

# Preparing return on risk-free asset.
tdf_end = 12 * 10
start_date = pl.date(year = 2007, month = 8, day = 30)
first_tdf = start_date.dt.month_start().dt.offset_by(str(tdf_end) + "mo").dt.month_end()
last_tdf = pl.date(year = 2024, month = 12, day = 31)

risk_free_returns = spot_rates.select(
    ["TIME_PERIOD", "TIME_TO_MATURITY", "SPOTRATE"]
).with_columns(
    pl.col("TIME_PERIOD").dt.month_start().dt.offset_by(pl.col("TIME_TO_MATURITY").cast(pl.String) + "mo").dt.month_end().alias("Portfolio")
).filter(
    (pl.col("Portfolio") >= first_tdf) & (pl.col("Portfolio") <= last_tdf)
).with_columns(
    ( - (pl.col("TIME_TO_MATURITY") / 12) * (pl.col("SPOTRATE") / 100)).exp().alias("ZC"),
).sort(
    ["Portfolio", "TIME_PERIOD"], descending = False
).with_columns(
    (100 * (pl.col("ZC") - pl.col("ZC").shift(1).over("Portfolio")) / pl.col("ZC").shift(1).over("Portfolio")).alias("Return")
).with_columns(
    ("TDF " +  pl.col("Portfolio").cast(pl.String)).alias("Portfolio")
)
#### Creating TDFs as portfolio enums: risk_free_returns.select(pl.col("Portfolio")).unique().with_columns((pl.col("Portfolio").str.replace_all(' ', '').str.replace_all('-', '_') + " = '" + pl.col("Portfolio") + "'").alias("Portfolio_Enum")).select("Portfolio_Enum").write_csv(portfolio_analysis_paths.tdf_enums_path)

## Defining weights
weights_tdf = risk_free_returns.with_columns(
    pl.lit(1).alias("Weight"),
    pl.col("Portfolio").alias("Portfolio strategy")
).drop_nulls(
).select(
    ["TIME_PERIOD", "Portfolio strategy", "Portfolio", "Weight"]
)

# Initialising portfolio universe
portfolio_universe = portfolio_strategies.PortfolioStrategy(fama_french_portfolios.filter(pl.col("N_Portfolios") == 6))

# Investable assets
asset_names =  (PortFolioRegion.TechUs.value, PortFolioRegion.MarketUs.value, PortFolioRegion.SmallCapUs.value, PortFolioRegion.TechEu.value, PortFolioRegion.MarketEu.value, PortFolioRegion.SmallCapEu.value)

# Dates to make efficient frontier
dates_efficient_frontier = pl.DataFrame(
    #{"Year": [2009]*12, "Month": range(1, 13), "Day": [1] * 12}
    {"Year": [2009, 2014, 2019, 2024], "Month": [6] * 4, "Day": [30] * 4}
).with_columns(
    (pl.date(year = pl.col("Year"), month = pl.col("Month"), day = pl.col("Day"))).dt.month_end().alias("Date")
)
# Find the optimal predetermined strategies.
optimal_strategies = portfolio_universe.running_optimal_portfolio_strategies(3 * 12, asset_names, dates_efficient_frontier, last_tdf)

px.scatter(optimal_strategies["Efficient frontier"], x = "Historical variance", y = "Historical return", color = "Portfolio", facet_col="TIME_PERIOD").show()

# Calculating returns for the investment strategies
## Preparing input based on optimal portfolio strategies
assets_returns = portfolio_universe.portfolio_universe_EUR.select(
            pl.exclude("Return_RF_EU")
        ).filter(
            (pl.col("TIME_PERIOD") >= start_date) & (pl.col("TIME_PERIOD") <= last_tdf)
        ).filter(
            pl.col("Portfolio region").cast(PortFolioRegion).is_in(asset_names)
        ).pivot(
            index = "TIME_PERIOD", on = ["Portfolio", "Region"], values = "Return_EUR"
        ).unpivot(
            index = "TIME_PERIOD", value_name = "Return", variable_name = "Portfolio"
        ).with_columns(
            (pl.col("Return") / 100).alias("Return"), # converting to %
            pl.col("Portfolio").cast(PortFolioRegion)
        ).select(
            portfolio_strategies.schema_asset_returns.keys()
        )

portfolio_weights_shifted_one_period_later =  optimal_strategies["Optimal strategies"].select(
            ["TIME_PERIOD", "Portfolio strategy", "Portfolio", "Weight"]
        ).filter(
            (pl.col("TIME_PERIOD") >= start_date) & (pl.col("TIME_PERIOD") <= last_tdf)
        ).sort(
            ["Portfolio strategy", "Portfolio", "TIME_PERIOD"]
        ).with_columns(
            (pl.col("TIME_PERIOD").shift(-1).over(["Portfolio strategy", "Portfolio"])).alias("TIME_PERIOD"),
        ).cast(
            {"Portfolio": PortFolioRegion, "Portfolio strategy": InvestmentStrategyPortfolios}
        ).select(
            portfolio_strategies.schema_portfolio_weights.keys()
        )

portfolio_strategies_return_input = portfolio_strategies.PortfolioReturnInput(portfolio_weights_shifted_one_period_later, assets_returns)

# Apply portfolio strategies
apply_investment = portfolio_strategies.PortfolioReturnCalculator(portfolio_strategies_return_input)
# Finding portfolio value for all in on the active portfolio strategies
## Balancing methods
mv_balancing = apply_investment.all_in_strategy_returns(InvestmentStrategyPortfolios.MV)
global_mv_balancing = apply_investment.all_in_strategy_returns(InvestmentStrategyPortfolios.GlobalMV)
risk_parity_balancing = apply_investment.all_in_strategy_returns(InvestmentStrategyPortfolios.RP)
max_return_balancing = apply_investment.all_in_strategy_returns(InvestmentStrategyPortfolios.MaxReturn)

## Initial weights
initial_weight_mv = {InvestmentStrategyPortfolios.MV: 1}
initial_weight_gmv = {InvestmentStrategyPortfolios.GlobalMV: 1}
initial_weight_rp = {InvestmentStrategyPortfolios.RP: 1}
initial_weight_max_return = {InvestmentStrategyPortfolios.MaxReturn: 1}
## Run strategy
returns_mv = apply_investment.portfolio_values(InvestmentStrategyPortfolios.MV.value, 1, initial_weight_mv, mv_balancing)
returns_gmv = apply_investment.portfolio_values(InvestmentStrategyPortfolios.GlobalMV.value, 1, initial_weight_gmv, global_mv_balancing)
returns_rp = apply_investment.portfolio_values(InvestmentStrategyPortfolios.RP.value, 1, initial_weight_rp, risk_parity_balancing)
returns_max_return = apply_investment.portfolio_values(InvestmentStrategyPortfolios.MaxReturn.value, 1, initial_weight_max_return, max_return_balancing)

returns_active_portfolio = pl.concat([returns_mv, returns_gmv, returns_rp, returns_max_return])
px.line(returns_active_portfolio, x = "TIME_PERIOD", y = "Value", color = "Portfolio name").show()





px.line(
    optimal_strategies["Optimal strategies"], title="Optimised Sharpe Ratio portfolios", x = "TIME_PERIOD", y = "Weight", color="Portfolio", facet_row="Portfolio strategy"
).update_yaxes(
    matches=None, showticklabels=True
).show()

# Output
optimal_strategies["Optimal strategies"].write_csv(portfolio_analysis_paths.optimal_portfolio_strategies)
optimal_strategies["Efficient frontier"].write_csv(portfolio_analysis_paths.efficient_frontiers)
portfolio_universe.portfolio_universe_EUR.write_csv(portfolio_analysis_paths.portfolio_universe_path)
returns_active_portfolio.write_csv(portfolio_analysis_paths.optimal_portfolio_strategies_returns_path)
risk_free_returns.write_csv(portfolio_analysis_paths.tdf_returns_path)
weights_tdf.write_csv(portfolio_analysis_paths.tdf_weights_path)




