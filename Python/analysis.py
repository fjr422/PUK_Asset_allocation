import polars as pl
import polars.selectors as cs
import plotly
import plotly.express as px
import data_paths

# Path
farma_french_paths = data_paths.FarmaFrench()

# Input
ff_research_factors = pl.read_csv(farma_french_paths.ff_research_factors_path, has_header=True, schema={"DateID": pl.String, "Mkt_RF": pl.Float64, "SMB": pl.Float64, "HML": pl.Float64, "RF": pl.Float64})
american6_value_weighted_returns = pl.read_csv(farma_french_paths.american_6_value_weighted_returns_path, has_header=True, null_values=["-999", "-99.99"], schema={"DateID":pl.String, "SMALL LoPRIOR": pl.Float64, "ME1 PRIOR2": pl.Float64, "SMALL HiPRIOR": pl.Float64, "BIG LoPRIOR": pl.Float64 , "ME2 PRIOR2": pl.Float64, "BIG HiPRIOR": pl.Float64} ).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="weighted_return")
american6_size = pl.read_csv(farma_french_paths.american_6_size_firms_path, has_header=True, null_values=["-999", "-99.99"], schema={"DateID":pl.String, "SMALL LoPRIOR": pl.Float64, "ME1 PRIOR2": pl.Float64, "SMALL HiPRIOR": pl.Float64, "BIG LoPRIOR": pl.Float64 , "ME2 PRIOR2": pl.Float64, "BIG HiPRIOR": pl.Float64}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="size")
american6_number = pl.read_csv(farma_french_paths.american_6_number_firms_path, has_header=True, null_values=["-999", "-99.99"], schema={"DateID":pl.String, "SMALL LoPRIOR": pl.Float64, "ME1 PRIOR2": pl.Float64, "SMALL HiPRIOR": pl.Float64, "BIG LoPRIOR": pl.Float64 , "ME2 PRIOR2": pl.Float64, "BIG HiPRIOR": pl.Float64}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="number_firms")
american6 = american6_value_weighted_returns.join(american6_size, how = "full", on=["DateID", "Portfolio"], coalesce=True).join(american6_number, how = "full", on=["DateID", "Portfolio"], coalesce=True)

american_return_plot = px.scatter(american6, x ="DateID", y ="weighted_return", color="Portfolio")
s = 1
print(american6.head())