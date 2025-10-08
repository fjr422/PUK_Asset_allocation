import polars as pl
import polars.selectors as cs
import plotly
import plotly.express as px
import data


# Path
farma_french_paths = data.FarmaFrench()

# Input
farma_french_input = data.FarmaFrenchInput(farma_french_paths)

# plot
px.scatter(farma_french_input.farma_french_portfolios, x = "DateID", y = "weighted_return",
           color="Portfolio", facet_col="Market", facet_row="Portfolio size",
           opacity=0.5).update_traces(marker_size = 5).show()

s = 1
