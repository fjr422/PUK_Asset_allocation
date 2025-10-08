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
american_return_plot = px.scatter(farma_french_input.american6, x ="DateID", y ="weighted_return", color="Portfolio")
european_return_plot = px.scatter(farma_french_input.european6, x ="DateID", y ="weighted_return", color="Portfolio")
s = 1
print(farma_french_input.american6.head())