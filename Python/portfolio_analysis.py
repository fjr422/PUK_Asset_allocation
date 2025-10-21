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
long_assets = (PortFolioRegion.TechUs, PortFolioRegion.MarketUs, PortFolioRegion.SmallCapUs, PortFolioRegion.TechEu, PortFolioRegion.MarketEu, PortFolioRegion.SmallCapEu)
long_assets_names = tuple([name.value for name in long_assets])

short_assets = (PortFolioRegion.MomEu, PortFolioRegion.MomUs, PortFolioRegion.SmbEu, PortFolioRegion.SmbUs, PortFolioRegion.MarketEu, PortFolioRegion.MarketUs)
short_assets_names = tuple([name.value for name in short_assets])

# Dates to make efficient frontier
dates_efficient_frontier = pl.DataFrame(
    {"Year": [2009, 2014, 2019, 2024], "Month": [6] * 4, "Day": [30] * 4}
).with_columns(
    (pl.date(year = pl.col("Year"), month = pl.col("Month"), day = pl.col("Day"))).dt.month_end().alias("Date")
)
# Find the optimal predetermined strategies.
optimal_strategies_long_assets = portfolio_universe.running_optimal_portfolio_strategies(3 * 12, long_assets_names, dates_efficient_frontier, common_var.last_tdf_pl)
optimal_strategies_short_assets = portfolio_universe.running_optimal_portfolio_strategies(3 * 12, short_assets_names, dates_efficient_frontier, common_var.last_tdf_pl)
# Efficient frontier plot
px.scatter(optimal_strategies_long_assets["Efficient frontier"], x = "Historical variance", y = "Historical return", color = "Portfolio", facet_col="TIME_PERIOD").show()
px.scatter(optimal_strategies_short_assets["Efficient frontier"], x = "Historical variance", y = "Historical return", color = "Portfolio", facet_col="TIME_PERIOD").show()

# Calculating returns for the investment strategies
## Preparing input based on optimal portfolio strategies
### For long assets
long_assets_returns = portfolio_universe.portfolio_universe_EUR.select(
            pl.exclude("Return_RF_EU")
        ).filter(
            (pl.col("TIME_PERIOD") >= common_var.portfolios_start_date_pl) & (pl.col("TIME_PERIOD") <= common_var.last_tdf_pl)
        ).filter(
            pl.col("Portfolio region").cast(PortFolioRegion).is_in(long_assets_names)
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
### For short assets
short_assets_returns = portfolio_universe.portfolio_universe_EUR.select(
            pl.exclude("Return_RF_EU")
        ).filter(
            (pl.col("TIME_PERIOD") >= common_var.portfolios_start_date_pl) & (pl.col("TIME_PERIOD") <= common_var.last_tdf_pl)
        ).filter(
            pl.col("Portfolio region").cast(PortFolioRegion).is_in(short_assets_names)
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
### For long portfolio
long_portfolio_weights_shifted_one_period_later =  optimal_strategies_long_assets["Optimal strategies"].select(
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
### For short
short_portfolio_weights_shifted_one_period_later =  optimal_strategies_short_assets["Optimal strategies"].select(
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

### Assets all in weights
long_assets_all_in_weights = __all_in_weights(long_assets_returns)
short_assets_all_in_weights = __all_in_weights(short_assets_returns)

weights_assets_long_strategies_weights_shifted_on_period = pl.concat([long_assets_all_in_weights, long_portfolio_weights_shifted_one_period_later])
weights_assets_short_strategies_weights_shifted_on_period = pl.concat([short_assets_all_in_weights, short_portfolio_weights_shifted_one_period_later])

# Init strategies
long_portfolio_strategies_return_input = portfolio_strategies.PortfolioReturnInput(weights_assets_long_strategies_weights_shifted_on_period, long_assets_returns)
short_portfolio_strategies_return_input = portfolio_strategies.PortfolioReturnInput(weights_assets_short_strategies_weights_shifted_on_period, short_assets_returns)

# Apply portfolio strategies
apply_investment_long = portfolio_strategies.PortfolioReturnCalculator(long_portfolio_strategies_return_input)
apply_investment_short = portfolio_strategies.PortfolioReturnCalculator(short_portfolio_strategies_return_input)

# Finding portfolio value for all in on the active portfolio strategies
## Run strategies and all in on assets
### Strategies for long
returns_mv_long = apply_investment_long.all_in_strategy_returns(InvestmentStrategyPortfolios.MV, 100)
returns_gmv_long = apply_investment_long.all_in_strategy_returns(InvestmentStrategyPortfolios.GlobalMV, 100)
returns_rp_long = apply_investment_long.all_in_strategy_returns(InvestmentStrategyPortfolios.RP, 100)
max_return_balancing_long = apply_investment_long.all_in_strategy_returns(InvestmentStrategyPortfolios.MaxReturn, 100)
returns_max_return_long = apply_investment_long.all_in_strategy_returns(InvestmentStrategyPortfolios.MarketUs, 100)
### Strategies for short
returns_mv_short = apply_investment_short.all_in_strategy_returns(InvestmentStrategyPortfolios.MV, 100)
returns_gmv_short = apply_investment_short.all_in_strategy_returns(InvestmentStrategyPortfolios.GlobalMV, 100)
returns_rp_short = apply_investment_short.all_in_strategy_returns(InvestmentStrategyPortfolios.RP, 100)
max_return_balancing_short = apply_investment_short.all_in_strategy_returns(InvestmentStrategyPortfolios.MaxReturn, 100)
returns_max_return_short = apply_investment_short.all_in_strategy_returns(InvestmentStrategyPortfolios.MarketUs, 100)

## Assets
returns_all_in_long_asset = pl.DataFrame(schema=portfolio_strategies.schema_portfolio_values)
for long_asset in long_assets:
    return_long_asset = apply_investment_long.all_in_strategy_returns(long_asset, 100)
    returns_all_in_long_asset.extend(return_long_asset)

returns_all_in_short_asset = pl.DataFrame(schema=portfolio_strategies.schema_portfolio_values)
for short_asset in short_assets:
    return_short_asset = apply_investment_short.all_in_strategy_returns(short_asset, 100)
    returns_all_in_short_asset.extend(return_short_asset)

# Combining
returns_active_long_portfolio = pl.concat(
    [returns_all_in_long_asset, returns_mv_long, returns_gmv_long, returns_rp_long, returns_max_return_long]
).sort(
    ["Portfolio name", "TIME_PERIOD"]
)
returns_active_short_portfolio = pl.concat(
    [returns_all_in_short_asset, returns_mv_short, returns_gmv_short, returns_rp_short, returns_max_return_short]
).sort(
    ["Portfolio name", "TIME_PERIOD"]
)

px.line(returns_active_long_portfolio, x = "TIME_PERIOD", y = "Value", color = "Portfolio name", title = "Long").show()
px.line(returns_active_short_portfolio, x = "TIME_PERIOD", y = "Value", color = "Portfolio name", title = "Short").show()

# Weights
px.line(
    optimal_strategies_long_assets["Optimal strategies"], title="Strategies", x = "TIME_PERIOD", y = "Weight", color="Portfolio", facet_row="Portfolio strategy"
).update_yaxes(
    matches=None, showticklabels=True
).show()

# Output
optimal_strategies_long_assets["Optimal strategies"].write_csv(portfolio_analysis_paths.optimal_portfolio_strategies)
optimal_strategies_long_assets["Efficient frontier"].write_csv(portfolio_analysis_paths.efficient_frontiers)
portfolio_universe.portfolio_universe_EUR.write_csv(portfolio_analysis_paths.portfolio_universe_path)
returns_active_long_portfolio.write_csv(portfolio_analysis_paths.optimal_long_portfolio_strategies_returns_path)
returns_active_short_portfolio.write_csv(portfolio_analysis_paths.optimal_short_portfolio_strategies_returns_path)
risk_free_returns.write_csv(portfolio_analysis_paths.tdf_returns_path)
weights_tdf.write_csv(portfolio_analysis_paths.tdf_weights_path)




