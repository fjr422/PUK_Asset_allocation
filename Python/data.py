import os
import polars as pl
import polars.selectors as cs

import common_var

data_path = os.path.join(os.path.dirname( __file__ ), os.path.pardir, "Data")
class FamaFrenchPaths:
    def __init__(self):
        self.ff_research_factors_path = os.path.join(data_path, "F-F_Research_Data_Factors.csv")

        # American6
        __american6 = "US_6PF_Size_MOM"
        self.american6_value_weighted_returns_path = os.path.join(data_path, __american6, "AverageValueWeightedReturns_Monthly.csv")
        self.american6_N_firms_path = os.path.join(data_path, __american6, "NumberFirmsInPortfolios.csv")
        self.american6_Avg_FirmSize_firms_path = os.path.join(data_path, __american6, "AverageFirmSize.csv")

        # European 6
        __european6 = "EU_6PF_Size_MOM"
        self.european6_value_weighted_returns_path = os.path.join(data_path, __european6, "AverageValueWeightedReturns_Monthly.csv")
        self.european6_N_firms_path = os.path.join(data_path, __european6, "NumberFirmsInPortfolios.csv")
        self.european6_Avg_FirmSize_firms_path = os.path.join(data_path, __european6, "AverageFirmSize.csv")

        # American25
        __american25 = "US_25PF_Size_MOM"
        self.american25_value_weighted_returns_path = os.path.join(data_path, __american25, "AverageValueWeightedReturns_Monthly.csv")
        self.american25_N_firms_path = os.path.join(data_path, __american25, "NumberFirmsInPortfolios.csv")
        self.american25_Avg_FirmSize_firms_path = os.path.join(data_path, __american25, "AverageFirmSize.csv")

        # European 25
        __european25 = "EU_25PF_Size_MOM"
        self.european25_value_weighted_returns_path = os.path.join(data_path, __european25, "AverageValueWeightedReturns_Monthly.csv")
        self.european25_N_firms_path = os.path.join(data_path, __european25, "NumberFirmsInPortfolios.csv")
        self.european25_Avg_FirmSize_firms_path = os.path.join(data_path, __european25, "AverageFirmSize.csv")

        # Input
        self.fama_french_portfolios_path = os.path.join(data_path, "Input","fama_french_portfolios.csv")
        self.fama_french_factors_path = os.path.join(data_path, "Input", "fama_french_factors.csv")

class YieldCurvePaths:
    zero_cupon_europe = os.path.join(data_path, "zero_cupon_europe.csv")
    # Input
    zero_cupon_europe_params = os.path.join(data_path, "Input", "zero_cupon_europe_params.csv")
    spot_rates_path = os.path.join(data_path, "Input", "spot_rates.csv")

class ExchangeRatePaths:
    all_exchange_rates_path = os.path.join(data_path, "eurofxref-hist.csv" )

    # Input
    usd_exchange_rate_path = os.path.join(data_path, "Input", "USD_exchange_rate.csv" )

class PortfolioAnalysisPaths:
    __active_portfolio_input_folder = os.path.join(data_path, "Active_portfolio", "Input")
    __active_portfolio_output_folder = os.path.join(data_path, "Active_portfolio", "Output")
    def __init__(self):
        self.portfolio_universe_path = os.path.join(self.__active_portfolio_input_folder, "portfolio_universe.csv")
        self.tdf_enums_path = os.path.join(self.__active_portfolio_input_folder, "tdf_enums.csv")


        self.efficient_frontiers_long = os.path.join(self.__active_portfolio_input_folder, "efficient_frontier_long.csv")
        self.optimal_portfolio_strategies_long = os.path.join(self.__active_portfolio_input_folder, "portfolio_strategies_long.csv")


        self.efficient_frontiers_short = os.path.join(self.__active_portfolio_input_folder, "efficient_frontier_short.csv")
        self.optimal_portfolio_strategies_short = os.path.join(self.__active_portfolio_input_folder, "portfolio_strategies_short.csv")


        self.efficient_frontiers_chosen_assets = os.path.join(self.__active_portfolio_input_folder, "efficient_frontier_chosen_assets.csv")
        self.optimal_portfolio_strategies_chosen_assets = os.path.join(self.__active_portfolio_input_folder, "portfolio_strategies_chosen_assets.csv")

        # Output
        self.tdf_returns_path = os.path.join(self.__active_portfolio_output_folder, "tdf_returns.csv")
        self.tdf_weights_path = os.path.join(self.__active_portfolio_output_folder, "tdf_weights.csv")
        self.zc_prices = os.path.join(self.__active_portfolio_output_folder, "zc_prices.csv")

        self.optimal_long_portfolio_strategies_returns_path = os.path.join(self.__active_portfolio_output_folder, "optimal_long_portfolio_strategies_values.csv")
        self.optimal_short_portfolio_strategies_returns_path = os.path.join(self.__active_portfolio_output_folder, "optimal_short_portfolio_strategies_values.csv")
        self.optimal_chosen_assets_portfolio_strategies_returns_path = os.path.join(self.__active_portfolio_output_folder, "optimal_chosen_assets_portfolio_strategies_values.csv")

class ActiveReserveStrategyAnalysisPaths:
    __active_reserve_strategy_folder = os.path.join(data_path, "Active_reserve_strategy")

    # External input
    fama_french_portfolios_path = FamaFrenchPaths().fama_french_portfolios_path
    tdf_weights_path = PortfolioAnalysisPaths().tdf_weights_path
    tdf_returns_path = PortfolioAnalysisPaths().tdf_returns_path

    # Input
    active_reserve_weights_shifted_one_period_path = os.path.join(__active_reserve_strategy_folder, "Input", "active_reserve_weights_shifted_one_period.csv")
    active_reserve_returns_path = os.path.join(__active_reserve_strategy_folder, "Input", "active_reserve_returns.csv")

    # Output
    cppi_terminal_values_base_path = os.path.join(__active_reserve_strategy_folder, "Output", "cppi_terminal_values")
    tie_in_terminal_values_base_path = os.path.join(__active_reserve_strategy_folder, "Output", "tie_in_trigger_terminal_values")

    def cppi_analysis_path(self, target: str):
        return os.path.join(self.__active_reserve_strategy_folder, "Output", "cppi_analysis" + target + ".csv")
    def cppi_terminal_values_path_target(self, target: str):
        return self.cppi_terminal_values_base_path + target + ".csv"
    def tie_in_trigger_analysis_path(self, target: str):
        return os.path.join(self.__active_reserve_strategy_folder, "Output", "tie_in_trigger_analysis" + target + ".csv")
    def tie_in_trigger_terminal_values_path(self, target: str):
        return self.tie_in_terminal_values_base_path + target + ".csv"



class FamaFrenchInput:
    def __init__(self, fama_french_paths):
        self.ff_research_factors = pl.read_csv(fama_french_paths.ff_research_factors_path, has_header=True, schema={"DateID": pl.String, "Mkt_RF": pl.Float64, "SMB": pl.Float64, "HML": pl.Float64, "RF": pl.Float64}
                                               ).rename({"DateID": "TIME_PERIOD"}
                                                 ).with_columns((pl.col("TIME_PERIOD") + "01").str.to_date("%Y%m%d").alias("TIME_PERIOD")
                                                 ).with_columns(pl.col("TIME_PERIOD").dt.month_end().alias("TIME_PERIOD")
                                                 ).filter(pl.col("TIME_PERIOD") >= common_var.assets_start_date_pl)
        # American 6
        __american6_value_weighted_returns = pl.read_csv(fama_french_paths.american6_value_weighted_returns_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="weighted_return")
        __american6_Avg_FirmSize = pl.read_csv(fama_french_paths.american6_Avg_FirmSize_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="Avg_FirmSize")
        __american6_number = pl.read_csv(fama_french_paths.american6_N_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="N_firms")
        __american6 = __american6_value_weighted_returns.join(__american6_Avg_FirmSize, how = "full", on=["DateID", "Portfolio"], coalesce=True).join(__american6_number, how = "full", on=["DateID", "Portfolio"], coalesce=True)
        __american6 = __american6.with_columns(pl.lit("US").alias("Region"), pl.lit("6").alias("N_Portfolios")
                                            )

        # European 6
        __european6_value_weighted_returns = pl.read_csv(fama_french_paths.european6_value_weighted_returns_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String} ).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="weighted_return")
        __european6_Avg_FirmSize = pl.read_csv(fama_french_paths.european6_Avg_FirmSize_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="Avg_FirmSize")
        __european6_number = pl.read_csv(fama_french_paths.european6_N_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="N_firms")
        __european6 = __european6_value_weighted_returns.join(__european6_Avg_FirmSize, how = "full", on=["DateID", "Portfolio"], coalesce=True).join(__european6_number, how = "full", on=["DateID", "Portfolio"], coalesce=True)
        __european6 = __european6.with_columns(pl.lit("EU").alias("Region"), pl.lit("6").alias("N_Portfolios")
                                        )

        # American 25
        __american25_value_weighted_returns = pl.read_csv(fama_french_paths.american25_value_weighted_returns_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String} ).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="weighted_return")
        __american25_Avg_FirmSize = pl.read_csv(fama_french_paths.american25_Avg_FirmSize_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="Avg_FirmSize")
        __american25_number = pl.read_csv(fama_french_paths.american25_N_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="N_firms")
        __american25 = __american25_value_weighted_returns.join(__american25_Avg_FirmSize, how = "full", on=["DateID", "Portfolio"], coalesce=True).join(__american25_number, how = "full", on=["DateID", "Portfolio"], coalesce=True)
        __american25 = __american25.with_columns(pl.lit("US").alias("Region"), pl.lit("25").alias("N_Portfolios")
                                       )

        # European 25
        __european25_value_weighted_returns = pl.read_csv(fama_french_paths.european25_value_weighted_returns_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String} ).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="weighted_return")
        __european25_Avg_FirmSize = pl.read_csv(fama_french_paths.european25_Avg_FirmSize_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="Avg_FirmSize")
        __european25_number = pl.read_csv(fama_french_paths.european25_N_firms_path, has_header=True, null_values=["-999", "-99.99"], schema_overrides={"DateID":pl.String}).unpivot(cs.numeric(), index="DateID", variable_name="Portfolio", value_name="N_firms")
        __european25 = __european25_value_weighted_returns.join(__european25_Avg_FirmSize, how = "full", on=["DateID", "Portfolio"], coalesce=True).join(__european25_number, how = "full", on=["DateID", "Portfolio"], coalesce=True)
        __european25 = __european25.with_columns(pl.lit("EU").alias("Region"), pl.lit("25").alias("N_Portfolios")
                                            )

        self.fama_french_portfolios = pl.concat([__american6, __european6, __american25, __european25]
                                                ).rename({"DateID": "TIME_PERIOD"}
                                                ).with_columns((pl.col("TIME_PERIOD") + "01").str.to_date("%Y%m%d").alias("TIME_PERIOD")
                                                ).with_columns(pl.col("TIME_PERIOD").dt.month_end().alias("TIME_PERIOD")
                                                ).filter(pl.col("TIME_PERIOD") >= common_var.assets_start_date_pl
                                                ).rename({"weighted_return": "Return_USD"}
                                                ).sort(["TIME_PERIOD","N_Portfolios", "Region", "Portfolio"])

class YieldCurveInput:
    def __init__(self, yield_curve_path):
        __yield_curve_params = ["BETA0", "BETA1", "BETA2", "BETA3", "TAU1", "TAU2"]
        __yield_curve_full = pl.read_csv(yield_curve_path, has_header=True, columns=["DATA_TYPE_FM", "TIME_PERIOD", "OBS_VALUE"], try_parse_dates=True)
        __yield_curve_pivot = __yield_curve_full.filter(pl.col("DATA_TYPE_FM").is_in(__yield_curve_params))

        self.yield_curve_params = __yield_curve_pivot.pivot("DATA_TYPE_FM", index = "TIME_PERIOD", values = "OBS_VALUE"
                                                            ).with_columns(pl.when(pl.col("TIME_PERIOD") == pl.date(year = 2004, month = 9, day = 6)).then(pl.date(year = 2004, month = 8, day = 31)).otherwise(pl.col("TIME_PERIOD")).alias("TIME_PERIOD")
                                                            ).filter(pl.col("TIME_PERIOD") >= common_var.assets_start_date_pl
                                                            ).sort(pl.col("TIME_PERIOD"), descending=False
                                                            ).group_by((pl.col("TIME_PERIOD").dt.year().alias("Year"), pl.col("TIME_PERIOD").dt.month().alias("Month"))
                                                            ).tail(n = 1
                                                            ).with_columns(pl.col("TIME_PERIOD").dt.month_end().alias("TIME_PERIOD")
                                                            ).select(pl.exclude(["Year", "Month"])
                                                            ).sort("TIME_PERIOD", descending=False)

    def risk_free_rate(self, max_time_to_maturity):
        """Calculate spot rate for time to maturity in years."""
        months = max_time_to_maturity * 12
        time_range = range(1, months + 1)

        return self.yield_curve_params.with_columns(
            # Calculate each term of the Svensson model
            (pl.col("BETA0")
             + pl.col("BETA1") * ((1 - (-(time_to_maturity / 12) / pl.col("TAU1")).exp()) / ((time_to_maturity / 12) / pl.col("TAU1")))
            + pl.col("BETA2") * ((1 - (-(time_to_maturity / 12) / pl.col("TAU1")).exp()) / ((time_to_maturity / 12) / pl.col("TAU1")))
             - pl.col("BETA2") * (-(time_to_maturity / 12) / pl.col("TAU1")).exp()
            + pl.col("BETA3") * ((1 - (-time_to_maturity / 12 / pl.col("TAU2")).exp()) / ((time_to_maturity / 12) / pl.col("TAU2")))
             - pl.col("BETA3") * (-(time_to_maturity / 12) / pl.col("TAU2")).exp()).alias(str(time_to_maturity))
            for time_to_maturity in time_range
        ).unpivot(index = ["TIME_PERIOD", "BETA0", "BETA1", "BETA2", "BETA3", "TAU1", "TAU2"], variable_name = "TIME_TO_MATURITY", value_name = "SPOTRATE"
                  ).cast({"TIME_TO_MATURITY": pl.Int64}
                  ).sort("TIME_PERIOD", descending=False)

class ExchangeRates:
    def __init__(self, exchange_rate_paths: ExchangeRatePaths):
        self.usd_exchange_rates = pl.read_csv(exchange_rate_paths.all_exchange_rates_path, try_parse_dates=True, columns=["Date", "USD"]
                                              ).rename({"Date": "TIME_PERIOD"}
                                              ).sort("TIME_PERIOD", descending=False
                                              ).group_by((pl.col("TIME_PERIOD").dt.year().alias("Year"), pl.col("TIME_PERIOD").dt.month().alias("Month"))
                                              ).tail(n = 1
                                              ).with_columns((pl.col("TIME_PERIOD").dt.month_end()).alias("TIME_PERIOD")
                                              ).with_columns((1 / pl.col("USD") ).alias("USD_to_EUR")
                                              ).sort(pl.col("TIME_PERIOD"), descending=False
                                              ).with_columns(Prev_USD_to_EUR = pl.col("USD_to_EUR").shift(1)
                                              ).with_columns(Monthly_Exchange_Return = pl.col("USD_to_EUR") / pl.col("Prev_USD_to_EUR")
                                              ).select(pl.exclude(["Year", "Month"])
                                              ).sort("TIME_PERIOD", descending=False)
