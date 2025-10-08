import polars as pl
import plotly.express as px
import data_paths

# Path
farma_french_paths = data_paths.FarmaFrench()

# Input
ff_research_factors = pl.read_csv(farma_french_paths.ff_research_factors_path, has_header=True, schema={"DateID": pl.String, "Mkt_RF": pl.Float64, "SMB": pl.Float64, "HML": pl.Float64, "RF": pl.Float64})
american_6_value_weighted_returns = pl.read_csv(farma_french_paths.american_6_value_weighted_returns_path, has_header=True, null_values=["-999", "-99.99"], schema={"DateID":pl.String, "SMALL LoPRIOR": pl.Float64, "ME1 PRIOR2": pl.Float64, "SMALL HiPRIOR": pl.Float64, "BIG LoPRIOR": pl.Float64 , "ME2 PRIOR2": pl.Float64, "BIG HiPRIOR": pl.Float64} )
