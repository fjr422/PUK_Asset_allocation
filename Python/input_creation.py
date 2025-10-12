import polars as pl
import plotly.express as px
import data

# Path
fama_french_paths = data.FamaFrenchPaths()
yield_curve_paths = data.YieldCurvePaths()
exchange_rate_paths = data.ExchangeRatePaths()

# Input
fama_french_input = data.FamaFrenchInput(fama_french_paths)
yield_curve_current = data.YieldCurveInput(yield_curve_paths.zero_cupon_europe)
exchange_rates = data.ExchangeRates(exchange_rate_paths)

# Creating spot rates
spot_rates = yield_curve_current.risk_free_rate(10, 1 / 12)
# RF_eur
RF_EUR = spot_rates.filter(pl.col("TIME_TO_MATURITY") == 1 / 12
                        ).with_columns(RF = (pl.col("SPOTRATE") * 1/12).exp() - 1
                        ).select("TIME_PERIOD", "RF"
                        ).rename({"RF": "RF_EUR"})

# Eur conversion
fama_french_portfolios_eur = fama_french_input.fama_french_portfolios.join(exchange_rates.usd_exchange_rates, on = "TIME_PERIOD", how = "left"
                                                ).with_columns(Return_EUR = pl.col("Return") * pl.col("Monthly_Exchange_Return"))

fama_french_factors_USD = fama_french_portfolios_eur.select(["Portfolio", "TIME_PERIOD", "Return", "N_Portfolios", "Region"]
                                    ).filter(pl.col("N_Portfolios") == "6"
                                    ).pivot("Portfolio", index = ["TIME_PERIOD", "N_Portfolios", "Region"], values = "Return"
                                    ).with_columns(SMB_USD = 1 / 3 * (pl.col("SMALL LoPRIOR") + pl.col("ME1 PRIOR2") + pl.col("SMALL HiPRIOR"))
                                                   - 1 / 3 * (pl.col("BIG LoPRIOR") + pl.col("ME1 PRIOR2") + pl.col("BIG HiPRIOR"))
                                    ). with_columns(MOM_USD = 1 / 2 * (pl.col("SMALL HiPRIOR") + pl.col("BIG HiPRIOR"))
                                                    - 1 / 2 * (pl.col("SMALL LoPRIOR") + pl.col("BIG LoPRIOR"))
                                    ).join(fama_french_input.ff_research_factors, on = "TIME_PERIOD", how = "left"
                                    ).select(["TIME_PERIOD", "N_Portfolios", "Region", "SMB_USD", "MOM_USD", "RF"]
                                    ).rename({"RF": "RF_USD"})
#
# fama_french_factors_EUR = fama_french_portfolios_eur.select(["Portfolio", "TIME_PERIOD", "Return_EUR", "N_Portfolios", "Region"]
#                                     ).filter(pl.col("N_Portfolios") == "6"
#                                     ).pivot("Portfolio", index = ["TIME_PERIOD", "N_Portfolios", "Region"], values = "Return_EUR"
#                                     ).with_columns(SMB_EUR = 1 / 3 * (pl.col("SMALL LoPRIOR") + pl.col("ME1 PRIOR2") + pl.col("SMALL HiPRIOR"))
#                                                    - 1 / 3 * (pl.col("BIG LoPRIOR") + pl.col("ME1 PRIOR2") + pl.col("BIG HiPRIOR"))
#                                     ). with_columns(MOM_EUR = 1 / 2 * (pl.col("SMALL HiPRIOR") + pl.col("BIG HiPRIOR"))
#                                                     - 1 / 2 * (pl.col("SMALL LoPRIOR") + pl.col("BIG LoPRIOR"))
#                                     ).join(RF_EUR, on = "TIME_PERIOD", how = "left"
#                                     ).select(["TIME_PERIOD", "N_Portfolios", "Region", "SMB_EUR", "MOM_EUR", "RF"]
#                                     ).rename({"RF": "RF_EUR"})

fama_french_portfolios = fama_french_portfolios_eur.join(fama_french_factors_USD, on = ["TIME_PERIOD", "N_Portfolios", "Region"], how = "left"
                                                ).with_columns(MOM_EUR = pl.col("MOM_USD") * pl.col("Monthly_Exchange_Return")
                                                ).with_columns(SMB_EUR = pl.col("SMB_USD") * pl.col("Monthly_Exchange_Return")
                                                ).join(RF_EUR, on = ["TIME_PERIOD"], how = "left"
                                                ).select(pl.exclude(["Portfolio_return_cap", "USD"]))

# Output
fama_french_portfolios.write_csv(fama_french_paths.fama_french_portfolios_path)
fama_french_input.ff_research_factors.write_csv(fama_french_paths.fama_french_factors_path)
yield_curve_current.yield_curve_params.write_csv(yield_curve_paths.zero_cupon_europe_params)
spot_rates.write_csv(yield_curve_paths.spot_rates_path)