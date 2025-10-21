import polars as pl
import plotly.express as px

import common_var
import data
import portfolio_strategies
from enums import PortFolioRegion, InvestmentStrategyPortfolios

def __all_in_weights(df: pl.DataFrame):
    return df.with_columns(
        pl.lit(1).cast(pl.Float64).alias("Weight"),
        pl.col("Portfolio").cast(InvestmentStrategyPortfolios).alias("Portfolio strategy")
    ).drop_nulls(
    ).select(
        portfolio_strategies.schema_portfolio_weights.keys()
    )

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
risk_free_returns = pl.concat(
    [risk_free_values, terminal_time_zc]
).with_columns(
    pl.col("TIME_PERIOD").dt.month_start().dt.offset_by(pl.col("TIME_TO_MATURITY").cast(pl.String) + "mo").dt.month_end().alias("Portfolio")
).filter(
    (pl.col("Portfolio") >= common_var.first_tdf_pl) & (pl.col("Portfolio") <= common_var.last_tdf_pl)
).with_columns(
    ( - (pl.col("TIME_TO_MATURITY") / 12) * (pl.col("SPOTRATE") / 100)).exp().alias("ZC"),
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


weights_tdf = __all_in_weights(risk_free_returns)

# Initialising portfolio universe
portfolio_universe = portfolio_strategies.PortfolioStrategy(fama_french_portfolios.filter(pl.col("N_Portfolios") == 6))

# Investable assets
assets = (PortFolioRegion.TechUs, PortFolioRegion.MarketUs, PortFolioRegion.SmallCapUs, PortFolioRegion.TechEu, PortFolioRegion.MarketEu, PortFolioRegion.SmallCapEu)
asset_names = tuple([name.value for name in assets]) #(PortFolioRegion.TechUs.value, PortFolioRegion.MarketUs.value, PortFolioRegion.SmallCapUs.value, PortFolioRegion.TechEu.value, PortFolioRegion.MarketEu.value, PortFolioRegion.SmallCapEu.value)

# Dates to make efficient frontier
dates_efficient_frontier = pl.DataFrame(
    #{"Year": [2009]*12, "Month": range(1, 13), "Day": [1] * 12}
    {"Year": [2009, 2014, 2019, 2024], "Month": [6] * 4, "Day": [30] * 4}
).with_columns(
    (pl.date(year = pl.col("Year"), month = pl.col("Month"), day = pl.col("Day"))).dt.month_end().alias("Date")
)
# Find the optimal predetermined strategies.
optimal_strategies = portfolio_universe.running_optimal_portfolio_strategies(3 * 12, asset_names, dates_efficient_frontier, common_var.last_tdf_pl)

# Efficient frontier plot
px.scatter(optimal_strategies["Efficient frontier"], x = "Historical variance", y = "Historical return", color = "Portfolio", facet_col="TIME_PERIOD").show()

# Calculating returns for the investment strategies
## Preparing input based on optimal portfolio strategies
assets_returns = portfolio_universe.portfolio_universe_EUR.select(
            pl.exclude("Return_RF_EU")
        ).filter(
            (pl.col("TIME_PERIOD") >= common_var.portfolios_start_date_pl) & (pl.col("TIME_PERIOD") <= common_var.last_tdf_pl)
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

## Weights assets and strategies
portfolio_weights_shifted_one_period_later =  optimal_strategies["Optimal strategies"].select(
            ["TIME_PERIOD", "Portfolio strategy", "Portfolio", "Weight"]
        ).filter(
            (pl.col("TIME_PERIOD") >= common_var.portfolios_start_date_pl) & (pl.col("TIME_PERIOD") <= common_var.last_tdf_pl)
        ).sort(
            ["Portfolio strategy", "Portfolio", "TIME_PERIOD"]
        ).with_columns(
            (pl.col("TIME_PERIOD").shift(-1).over(["Portfolio strategy", "Portfolio"])).alias("TIME_PERIOD"),
        ).cast(
            {"Portfolio": PortFolioRegion, "Portfolio strategy": InvestmentStrategyPortfolios}
        ).select(
            portfolio_strategies.schema_portfolio_weights.keys()
        )

assets_all_in_weights = __all_in_weights(assets_returns)

weights_assets_strategies_weights_shifted_on_period = pl.concat([assets_all_in_weights, portfolio_weights_shifted_one_period_later])

portfolio_strategies_return_input = portfolio_strategies.PortfolioReturnInput(weights_assets_strategies_weights_shifted_on_period, assets_returns)

# Apply portfolio strategies
apply_investment = portfolio_strategies.PortfolioReturnCalculator(portfolio_strategies_return_input)

# Finding portfolio value for all in on the active portfolio strategies
## Run strategies and all in on assets
returns_mv = apply_investment.all_in_strategy_returns(InvestmentStrategyPortfolios.MV, 100)
returns_gmv = apply_investment.all_in_strategy_returns(InvestmentStrategyPortfolios.GlobalMV, 100)
returns_rp = apply_investment.all_in_strategy_returns(InvestmentStrategyPortfolios.RP, 100)
max_return_balancing = apply_investment.all_in_strategy_returns(InvestmentStrategyPortfolios.MaxReturn, 100)
returns_max_return = apply_investment.all_in_strategy_returns(InvestmentStrategyPortfolios.MarketUs, 100)

returns_all_in_asset = pl.DataFrame(schema=portfolio_strategies.schema_portfolio_values)
for asset in assets:
    return_asset = apply_investment.all_in_strategy_returns(asset, 100)
    returns_all_in_asset.extend(return_asset)

returns_active_portfolio = pl.concat(
    [returns_all_in_asset, returns_mv, returns_gmv, returns_rp, returns_max_return]
).sort(
    ["Portfolio name", "TIME_PERIOD"]
)
px.line(returns_active_portfolio, x = "TIME_PERIOD", y = "Value", color = "Portfolio name").show()
# Weights
px.line(
    optimal_strategies["Optimal strategies"], title="Strategies", x = "TIME_PERIOD", y = "Weight", color="Portfolio", facet_row="Portfolio strategy"
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




