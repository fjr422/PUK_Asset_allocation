import polars as pl
import plotly.express as px

import data
import portfolio_strategies

# Paths
fama_french_paths = data.FamaFrenchPaths()
yield_curve_paths = data.YieldCurvePaths()

# Input
fama_french_factors = pl.read_csv(fama_french_paths.fama_french_factors_path, try_parse_dates=True)
fama_french_portfolios = pl.read_csv(fama_french_paths.fama_french_portfolios_path, try_parse_dates=True)
spot_rates = pl.read_csv(yield_curve_paths.spot_rates_path, try_parse_dates=True)

# Creating strategies
mean_variance_strategy = portfolio_strategies.MeanVarianceStrategy(fama_french_portfolios.filter(pl.col("N_Portfolios") == 6), ["BIG HiPRIOR", "SMALL LoPRIOR", "ME1 PRIOR2", "SMALL HiPRIOR"])

sharpe_optimized = mean_variance_strategy.running_optimal_sharpe_portfolio(3 * 12)


test_zero_cupon = spot_rates.with_columns(Zero_cupon_price = ( - (pl.col("TIME_TO_MATURITY") / 12) * (pl.col("SPOTRATE") / 100)).exp()).filter(pl.col("TIME_TO_MATURITY") == 120)

test = 1
px.line(test_zero_cupon, x = "TIME_PERIOD", y = "Zero_cupon_price").show()



# Portfolio
pivot = fama_french_portfolios.select(pl.exclude(["number_firms", "size"])).pivot("Portfolio", index = ["TIME_PERIOD", "Market", "Number_Portfolios"], values = "weighted_return").with_columns((pl.col("DateID") + "01").str.to_date("%Y%m%d").alias("DateID")).sort("DateID").with_row_index()
test = pivot.rolling(index_column = "index", period="30i").agg([pl.cov("SMALL LoPRIOR", 'ME1 PRIOR2')])