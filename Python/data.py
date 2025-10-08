import os
import polars as pl
import polars.selectors as cs
class FarmaFrench:
    ff_research_factors_path = os.path.join("Data", "F-F_Research_Data_Factors.csv")

    # American6
    __american6 = "US_6PF_SIZE_MOM"
    american6_value_weighted_returns_path = os.path.join("Data", __american6, "AverageValueWeightedReturns_Monthly.csv")
    american6_number_firms_path = os.path.join("Data", __american6, "NumberFirmsInPortfolios.csv")
    american6_size_firms_path = os.path.join("Data", __american6, "AverageValueWeightedReturns_Monthly.csv")

    # European 6
    __european6 = "EU_6PF_SIZE_MOM"
    european6_value_weighted_returns_path = os.path.join("Data", __european6, "AverageValueWeightedReturns_Monthly.csv")
    european6_number_firms_path = os.path.join("Data", __european6, "NumberFirmsInPortfolios.csv")
    european6_size_firms_path = os.path.join("Data", __european6, "AverageValueWeightedReturns_Monthly.csv")

    # American25
    __american25 = "US_25PF_SIZE_MOM"
    american25_value_weighted_returns_path = os.path.join("Data", __american25, "AverageValueWeightedReturns_Monthly.csv")
    american25_number_firms_path = os.path.join("Data", __american25, "NumberFirmsInPortfolios.csv")
    american25_size_firms_path = os.path.join("Data", __american25, "AverageValueWeightedReturns_Monthly.csv")

    # European 25
    __european25 = "EU_25PF_SIZE_MOM"
    european25_value_weighted_returns_path = os.path.join("Data", __european25, "AverageValueWeightedReturns_Monthly.csv")
    european25_number_firms_path = os.path.join("Data", __european25, "NumberFirmsInPortfolios.csv")
    european25_size_firms_path = os.path.join("Data", __european25, "AverageValueWeightedReturns_Monthly.csv")

class FarmaFrenchInput:
    def __init__(self, farma_french_paths):

        self.ff_research_factors = pl.read_csv(farma_french_paths.ff_research_factors_path, has_header=True, schema={"DateID": pl.String, "Mkt_RF": pl.Float64, "SMB": pl.Float64, "HML": pl.Float64, "RF": pl.Float64})
        # American 6
        __american6_value_weighted_returns = pl.read_csv(farma_french_paths.american6_value_weighted_returns_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="weighted_return")
        __american6_size = pl.read_csv(farma_french_paths.american6_size_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="size")
        __american6_number = pl.read_csv(farma_french_paths.american6_number_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="number_firms")
        __american6 = __american6_value_weighted_returns.join(__american6_size, how = "full", on=["DateID", "Portfolio"], coalesce=True).join(__american6_number, how = "full", on=["DateID", "Portfolio"], coalesce=True)
        __american6 = __american6.with_columns(pl.lit("American").alias("Market"), pl.lit("6").alias("Portfolio size"))

        # European 6
        __european6_value_weighted_returns = pl.read_csv(farma_french_paths.european6_value_weighted_returns_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String} ).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="weighted_return")
        __european6_size = pl.read_csv(farma_french_paths.european6_size_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="size")
        __european6_number = pl.read_csv(farma_french_paths.european6_number_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="number_firms")
        __european6 = __european6_value_weighted_returns.join(__european6_size, how = "full", on=["DateID", "Portfolio"], coalesce=True).join(__european6_number, how = "full", on=["DateID", "Portfolio"], coalesce=True)
        __european6 = __european6.with_columns(pl.lit("European").alias("Market"), pl.lit("6").alias("Portfolio size"))

        # American 25
        __american25_value_weighted_returns = pl.read_csv(farma_french_paths.american25_value_weighted_returns_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String} ).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="weighted_return")
        __american25_size = pl.read_csv(farma_french_paths.american25_size_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="size")
        __american25_number = pl.read_csv(farma_french_paths.american25_number_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="number_firms")
        __american25 = __american25_value_weighted_returns.join(__american25_size, how = "full", on=["DateID", "Portfolio"], coalesce=True).join(__american25_number, how = "full", on=["DateID", "Portfolio"], coalesce=True)
        __american25 = __american25.with_columns(pl.lit("American").alias("Market"), pl.lit("25").alias("Portfolio size"))

        # European 25
        __european25_value_weighted_returns = pl.read_csv(farma_french_paths.european25_value_weighted_returns_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String} ).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="weighted_return")
        __european25_size = pl.read_csv(farma_french_paths.european25_size_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="size")
        __european25_number = pl.read_csv(farma_french_paths.european25_number_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="number_firms")
        __european25 = __european25_value_weighted_returns.join(__european25_size, how = "full", on=["DateID", "Portfolio"], coalesce=True).join(__european25_number, how = "full", on=["DateID", "Portfolio"], coalesce=True)
        __european25 = __european25.with_columns(pl.lit("European").alias("Market"), pl.lit("25").alias("Portfolio size"))

        self.farma_french_portfolios = pl.concat([__american6, __european6, __american25, __european25])


