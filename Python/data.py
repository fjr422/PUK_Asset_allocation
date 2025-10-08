import os
import polars as pl
import polars.selectors as cs
class FarmaFrench:
    ff_research_factors_path = os.path.join("Data", "F-F_Research_Data_Factors.csv")

    # US6PF_SIZE_MOM
    __american6 = "US_6PF_SIZE_MOM"
    american6_value_weighted_returns_path = os.path.join("Data", __american6, "AverageValueWeightedReturns_Monthly.csv")
    american6_number_firms_path = os.path.join("Data", __american6, "NumberFirmsInPortfolios.csv")
    american6_size_firms_path = os.path.join("Data", __american6, "AverageValueWeightedReturns_Monthly.csv")

    # European
    __european6 = "EU_6PF_SIZE_MOM"
    european6_value_weighted_return_path = os.path.join("Data", __european6, "AverageValueWeightedReturns_Monthly.csv")
    european6_number_firms_path = os.path.join("Data", __european6, "NumberFirmsInPortfolios.csv")
    european6_size_firms_path = os.path.join("Data", __european6, "AverageValueWeightedReturns_Monthly.csv")

class FarmaFrenchInput:
    def __init__(self, farma_french_paths):

        self.ff_research_factors = pl.read_csv(farma_french_paths.ff_research_factors_path, has_header=True, schema={"DateID": pl.String, "Mkt_RF": pl.Float64, "SMB": pl.Float64, "HML": pl.Float64, "RF": pl.Float64})

        __american6_value_weighted_returns = pl.read_csv(farma_french_paths.american6_value_weighted_returns_path, has_header=True, null_values=["-999", "-99.99"], schema={"DateID":pl.String, "SMALL LoPRIOR": pl.Float64, "ME1 PRIOR2": pl.Float64, "SMALL HiPRIOR": pl.Float64, "BIG LoPRIOR": pl.Float64 , "ME2 PRIOR2": pl.Float64, "BIG HiPRIOR": pl.Float64} ).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="weighted_return")
        __american6_size = pl.read_csv(farma_french_paths.american6_size_firms_path, has_header=True, null_values=["-999", "-99.99"], schema={"DateID":pl.String, "SMALL LoPRIOR": pl.Float64, "ME1 PRIOR2": pl.Float64, "SMALL HiPRIOR": pl.Float64, "BIG LoPRIOR": pl.Float64 , "ME2 PRIOR2": pl.Float64, "BIG HiPRIOR": pl.Float64}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="size")
        __american6_number = pl.read_csv(farma_french_paths.american6_number_firms_path, has_header=True, null_values=["-999", "-99.99"], schema={"DateID":pl.String, "SMALL LoPRIOR": pl.Float64, "ME1 PRIOR2": pl.Float64, "SMALL HiPRIOR": pl.Float64, "BIG LoPRIOR": pl.Float64 , "ME2 PRIOR2": pl.Float64, "BIG HiPRIOR": pl.Float64}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="number_firms")
        self.american6 = __american6_value_weighted_returns.join(__american6_size, how = "full", on=["DateID", "Portfolio"], coalesce=True).join(__american6_number, how = "full", on=["DateID", "Portfolio"], coalesce=True)

        __european6_value_weighted_returns = pl.read_csv(farma_french_paths.european6_value_weighted_return_path, has_header=True, null_values=["-999", "-99.99"], schema={"DateID":pl.String, "SMALL LoPRIOR": pl.Float64, "ME1 PRIOR2": pl.Float64, "SMALL HiPRIOR": pl.Float64, "BIG LoPRIOR": pl.Float64 , "ME2 PRIOR2": pl.Float64, "BIG HiPRIOR": pl.Float64} ).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="weighted_return")
        __european6_size = pl.read_csv(farma_french_paths.european6_size_firms_path, has_header=True, null_values=["-999", "-99.99"], schema={"DateID":pl.String, "SMALL LoPRIOR": pl.Float64, "ME1 PRIOR2": pl.Float64, "SMALL HiPRIOR": pl.Float64, "BIG LoPRIOR": pl.Float64 , "ME2 PRIOR2": pl.Float64, "BIG HiPRIOR": pl.Float64}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="size")
        __european6_number = pl.read_csv(farma_french_paths.european6_number_firms_path, has_header=True, null_values=["-999", "-99.99"], schema={"DateID":pl.String, "SMALL LoPRIOR": pl.Float64, "ME1 PRIOR2": pl.Float64, "SMALL HiPRIOR": pl.Float64, "BIG LoPRIOR": pl.Float64 , "ME2 PRIOR2": pl.Float64, "BIG HiPRIOR": pl.Float64}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="number_firms")
        self.european6 = __european6_value_weighted_returns.join(__european6_size, how = "full", on=["DateID", "Portfolio"], coalesce=True).join(__european6_number, how = "full", on=["DateID", "Portfolio"], coalesce=True)
        

