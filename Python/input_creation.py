import polars as pl
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
spot_rates = yield_curve_current.risk_free_rate(10).sort("TIME_PERIOD", descending=False)
# RF_eur
RF_EU = spot_rates.filter(pl.col("TIME_TO_MATURITY") == 1
                        ).with_columns(RF = (pl.col("SPOTRATE") * 1/12).exp() - 1
                        ).select("TIME_PERIOD", "RF"
                        ).rename({"RF": "RF_EU"})

# Eur conversion
fama_french_portfolios_eur = fama_french_input.fama_french_portfolios.join(
    exchange_rates.usd_exchange_rates, on = "TIME_PERIOD", how = "left"
).with_columns(
    Return_EUR = (pl.col("Return_USD") + 100) * pl.col("Monthly_Exchange_Return") - 100
)

# Calculating factors
small_cap_portfolios = ("SMALL LoPRIOR", "ME1 PRIOR2", "SMALL HiPRIOR")
big_cap_portfolios = ("BIG LoPRIOR", "ME2 PRIOR2", "BIG HiPRIOR")
HiMOM = ("SMALL HiPRIOR", "BIG HiPRIOR")
LowMOM = ("SMALL LoPRIOR", "BIG LoPRIOR")

tech_stocks = "BIG HiPRIOR"
small_cap = ("SMALL LoPRIOR", "ME1 PRIOR2", "SMALL HiPRIOR")

## In USD
def fama_french_factors(portfolios: pl.DataFrame, return_col: str, currency: str, n_portfolios = "6", small_cap_port = small_cap_portfolios, big_cap_port = big_cap_portfolios, low_mom = LowMOM, high_mom = HiMOM, tech = tech_stocks, small_cap_stocks = small_cap):
    """Calculating Fama & French factors"""
    factors_base = portfolios.filter(pl.col("N_Portfolios") == n_portfolios
                                    ).with_columns(Portfolio_market_size = pl.col("N_firms") * pl.col("Avg_FirmSize")
                                    ).with_columns(Portfolio_return_cap = pl.col("Return_" + currency) * pl.col("Portfolio_market_size") / pl.col("Portfolio_market_size").sum().over(("TIME_PERIOD", "Region"))
                                    ).with_columns((pl.col("Portfolio_return_cap").sum().over(("TIME_PERIOD", "Region"))).alias("Market_Return_" + currency)
                                    ).select(["Portfolio", "TIME_PERIOD", return_col, "Region", "Market_Return_" + currency]
                                    ).pivot("Portfolio", index = ["TIME_PERIOD", "Region", "Market_Return_" + currency], values = return_col
                                    ).with_columns((1 / 3 * (pl.col(small_cap_port[0]) + pl.col(small_cap_port[1]) + pl.col(small_cap_port[2]))
                                                   - 1 / 3 * (pl.col(big_cap_port[0]) + pl.col(big_cap_port[1]) + pl.col(big_cap_port[2]))).alias("SMB_" + currency)
                                    ).with_columns((1 / 2 * (pl.col(high_mom[0]) + pl.col(high_mom[1]))
                                                    - 1 / 2 * (pl.col(low_mom[0]) + pl.col(low_mom[1]))).alias("MOM_" + currency)
                                    ).with_columns((pl.col(tech)).alias("Tech Stocks " + currency)
                                    ).select(["TIME_PERIOD", "Region", "SMB_" + currency, "MOM_" + currency, "Tech Stocks " + currency, "Market_Return_" + currency]
                                    )

    small_cap_factor = portfolios.filter((pl.col("N_Portfolios") == n_portfolios) & (pl.col("Portfolio").is_in(small_cap_stocks))
                                    ).with_columns(Portfolio_market_size = pl.col("N_firms") * pl.col("Avg_FirmSize")
                                    ).select(["Portfolio", "TIME_PERIOD", return_col, "Region", "Portfolio_market_size"]
                                    ).with_columns((pl.col("Portfolio_market_size") / pl.col("Portfolio_market_size").sum().over(("TIME_PERIOD", "Region"),)).alias("Market weight")
                                    ).group_by(["TIME_PERIOD", "Region"]
                                    ).agg((pl.col(return_col) * pl.col("Market weight")).sum().alias("Small Cap " + currency))

    return factors_base.join(small_cap_factor, on = ("TIME_PERIOD", "Region"), how = "left")

fama_french_factors_USD = fama_french_factors(fama_french_portfolios_eur, return_col="Return_USD", currency = "USD")
fama_french_factors_EUR = fama_french_factors(fama_french_portfolios_eur, return_col="Return_EUR", currency = "EUR")

# Collect
fama_french_portfolios = fama_french_portfolios_eur.join(fama_french_factors_USD, on = ["TIME_PERIOD", "Region"], how = "left"
                                    ).join(fama_french_factors_EUR, on = ["TIME_PERIOD", "Region"], how = "left"
                                    ).join(fama_french_input.ff_research_factors, on = "TIME_PERIOD", how = "left"
                                    ).select(pl.exclude("MKT_RF", "HML", "SMB")
                                    ).rename({"RF": "RF_US"}
                                    ).join(RF_EU, on = "TIME_PERIOD", how = "left"
                                    ).select(pl.exclude(["Portfolio_return_cap", "USD"])
                                    ).with_columns(((pl.col("RF_US") + 100) * pl.col("Monthly_Exchange_Return") - 100).alias("RF_US_EUR"))

# Output
fama_french_portfolios.write_csv(fama_french_paths.fama_french_portfolios_path)
fama_french_input.ff_research_factors.write_csv(fama_french_paths.fama_french_factors_path)
yield_curve_current.yield_curve_params.write_csv(yield_curve_paths.zero_cupon_europe_params)
spot_rates.write_csv(yield_curve_paths.spot_rates_path)