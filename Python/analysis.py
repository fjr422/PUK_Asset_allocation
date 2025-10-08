import polars as pl
import plotly.express as px
import data_paths

farma_french_paths = DataPaths.FarmaFrench()

ff_research_factors = pl.read_csv(farma_french_paths.ff_research_factors, has_header=True, schema={
    "DateId": pl.String,
    "Mkt_RF": pl.Float64,
    "SMB": pl.Float64,
    "HML": pl.Float64,
    "RF": pl.Float64
})
print(ff_research_factors.head())
first = ff_research_factors.with_columns((pl.col("Mkt_RF") + pl.col("SMB") + pl.col("HML")).alias("Test"))
print(first.head())
t = 1