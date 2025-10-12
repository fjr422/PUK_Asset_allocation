import data

# Paths
fama_french_paths = data.FamaFrenchPaths()
yield_curve_paths = data.YieldCurvePaths()

# Input
fama_french_input = data.FamaFrenchInput(fama_french_paths)
yield_curve_current = data.YieldCurveInput(yield_curve_paths.zero_cupon_europe)
yield_curve_current.yield_curve_params.write_csv(yield_curve_paths.zero_cupon_europe_params)
spot_rates = yield_curve_current.risk_free_rate(10, 1/12)
spot_rates.write_csv(yield_curve_paths.spot_rates_path)


# Portfolio
# pivot = fama_french_input.fama_french_portfolios.select(pl.exclude(["number_firms", "size"])).pivot("Portfolio", index = ["DateID", "Market", "Portfolio size"], values = "weighted_return").with_columns((pl.col("DateID") + "01").str.to_date("%Y%m%d").alias("DateID")).sort("DateID").with_row_index()
# test = pivot.rolling(index_column = "index", period="30i").agg([pl.cov("SMALL LoPRIOR", 'ME1 PRIOR2')])

