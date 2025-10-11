import polars as pl
import polars.selectors as cs
import plotly
import plotly.express as px
import data


# Path
farma_french_paths = data.FarmaFrench()
yield_curve_paths = data.YieldCurvePaths()

# Input
farma_french_input = data.FarmaFrenchInput(farma_french_paths)
yield_curve_current = data.YieldCurveInput(yield_curve_paths.zero_cupon_europe)
yield_curve_current.yield_curve_params.write_csv(yield_curve_paths.zero_cupon_europe_params)
current_risk_free_rate = yield_curve_current.risk_free_rate(1/12)
px.line(current_risk_free_rate, x ="TIME_PERIOD", y = "SpotRate").show()
# plot
px.scatter(farma_french_input.farma_french_portfolios, x = "DateID", y = "weighted_return",
           color="Portfolio", facet_col="Market", facet_row="Portfolio size",
           opacity=0.5).update_traces(marker_size = 5).show()

s = 1
