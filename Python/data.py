import math
import os
import polars as pl
import polars.selectors as cs
class FarmaFrenchPaths:
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

class YieldCurvePaths:
    zero_cupon_europe = os.path.join("Data", "zero_cupon_europe.csv")
    zero_cupon_europe_params = os.path.join("Data", "zero_cupon_europe_params.csv")


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

class YieldCurveInput:
    def risk_free_rate(self, time_to_maturity):
        return self.yield_curve_params.with_columns(
            # Calculate each term of the Svensson model
            (pl.col("BETA0")
             + pl.col("BETA1") * ((1 - (-time_to_maturity / pl.col("TAU1")).exp()) / (time_to_maturity / pl.col("TAU1"))))
            .alias("Term1")
        ).with_columns(
            (pl.col("BETA2") * ((1 - (-time_to_maturity / pl.col("TAU1")).exp()) / (time_to_maturity / pl.col("TAU1")))
             - pl.col("BETA2") * (-time_to_maturity / pl.col("TAU1")).exp()).alias("Term2")
        ).with_columns(
            (pl.col("BETA3") * ((1 - (-time_to_maturity / pl.col("TAU2")).exp()) / (time_to_maturity / pl.col("TAU2")))
             - pl.col("BETA3") * (-time_to_maturity / pl.col("TAU2")).exp()).alias("Term3")
        ).with_columns(
            (pl.col("Term1") + pl.col("Term2") + pl.col("Term3")).alias("SpotRate")
        ).with_columns( (pl.col("SpotRate").exp() - 1).alias("RF")
        ).select(pl.exclude(["Term1", "Term2", "Term3"]))

    def __init__(self, yield_curve_path):
        __yield_curve_params = ["BETA0", "BETA1", "BETA2", "BETA3", "TAU1", "TAU2"]
        __yield_curve_full = pl.read_csv(yield_curve_path, has_header=True, columns=["DATA_TYPE_FM", "TIME_PERIOD", "OBS_VALUE"], try_parse_dates=True)
        __yield_curve_pivot = __yield_curve_full.filter(pl.col("DATA_TYPE_FM").is_in(__yield_curve_params)).pivot("DATA_TYPE_FM", index = "TIME_PERIOD", values = "OBS_VALUE")
        self.yield_curve_params = __yield_curve_pivot.with_columns()