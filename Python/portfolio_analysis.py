import polars as pl
import plotly.express as px

import data

# Paths
fama_french_paths = data.FamaFrenchPaths()
yield_curve_paths = data.YieldCurvePaths()

# Input
fama_french_factors = pl.read_csv(fama_french_paths.fama_french_factors_path, try_parse_dates=True)
fama_french_portfolios = pl.read_csv(fama_french_paths.fama_french_portfolios_path, try_parse_dates=True)
spot_rates = pl.read_csv(yield_curve_paths.spot_rates_path, try_parse_dates=True)
test = spot_rates.filter(pl.col("TIME_TO_MATURITY") == 1/12)
px.line(test, x = "TIME_PERIOD", y = "SPOTRATE").show()
# Portfolio
pivot = fama_french_portfolios.select(pl.exclude(["number_firms", "size"])).pivot("Portfolio", index = ["TIME_PERIOD", "Market", "Number_Portfolios"], values = "weighted_return").with_columns((pl.col("DateID") + "01").str.to_date("%Y%m%d").alias("DateID")).sort("DateID").with_row_index()
test = pivot.rolling(index_column = "index", period="30i").agg([pl.cov("SMALL LoPRIOR", 'ME1 PRIOR2')])