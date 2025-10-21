import pandas as pd
import polars as pl
import plotly.express as px

import common_var
from enums import *
import data
import portfolio_strategies

# Input
portfolio_analysis_paths = data.PortfolioAnalysisPaths()
fama_french_paths = data.FamaFrenchPaths()

fama_french_portfolios = pl.read_csv(fama_french_paths.fama_french_portfolios_path, try_parse_dates=True)
tdf_returns = pl.read_csv(portfolio_analysis_paths.tdf_returns_path, try_parse_dates=True,  schema_overrides={"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion})
tdf_weights = pl.read_csv(portfolio_analysis_paths.tdf_weights_path, try_parse_dates=True,  schema_overrides={"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion, "Portfolio strategy": InvestmentStrategyPortfolios})

## Assets to invest in
asset_names = (PortFolioRegion.MomEu.value, PortFolioRegion.MarketUs.value, PortFolioRegion.SmallCapUs.value, PortFolioRegion.TechEu.value, PortFolioRegion.MarketEu.value, PortFolioRegion.SmallCapEu.value)
portfolio_universe = portfolio_strategies.PortfolioStrategy(fama_french_portfolios.filter(pl.col("N_Portfolios") == 6))
optimal_strategies = portfolio_universe.running_optimal_portfolio_strategies(3 * 12, asset_names, pl.DataFrame({"a": [None]}).clear(), common_var.last_tdf_pl)

# Selected active strategy
active_strategy = InvestmentStrategyPortfolios.RP

## Apply investment strategy
reserve_returns = tdf_returns.select(
    ["TIME_PERIOD", "Portfolio", "Return"]
).with_columns(
    (pl.col("Return") / 100).alias("Return")
)

assets_returns = portfolio_universe.portfolio_universe_EUR.select(
    pl.exclude("Return_RF_EU")
).filter(
    (pl.col("TIME_PERIOD") >= common_var.portfolios_start_date_pl) & (pl.col("TIME_PERIOD") <= common_var.last_tdf_pl)
).filter(
    pl.col("Portfolio region").cast(PortFolioRegion).is_in(asset_names)
).pivot(
    index = "TIME_PERIOD", on = ["Portfolio", "Region"], values = "Return_EUR"
).unpivot(
    index = "TIME_PERIOD", value_name = "Return", variable_name = "Portfolio"
).with_columns(
    (pl.col("Return") / 100).alias("Return"), # converting to %
    pl.col("Portfolio").cast(PortFolioRegion)
).select(
    portfolio_strategies.schema_asset_returns.keys()
)

active_reserve_returns = pl.concat([assets_returns, reserve_returns])

## Shifting the weights one period as SF
active_weights_shifted_one_period = optimal_strategies["Optimal strategies"].select(
    ["TIME_PERIOD", "Portfolio strategy", "Portfolio", "Weight"]
).filter(
    pl.col("Portfolio strategy") == active_strategy
).filter(
    (pl.col("TIME_PERIOD") >= common_var.portfolios_start_date_pl) & (pl.col("TIME_PERIOD") <= common_var.last_tdf_pl)
).sort(
    ["Portfolio strategy", "Portfolio", "TIME_PERIOD"]
).with_columns(
    (pl.col("TIME_PERIOD").shift(-1).over(["Portfolio strategy", "Portfolio"])).alias("TIME_PERIOD"),
).cast(
    {"Portfolio": PortFolioRegion, "Portfolio strategy": InvestmentStrategyPortfolios}
).select(
    portfolio_strategies.schema_portfolio_weights.keys()
)

reserve_weights_shifted_one_period = tdf_weights.select(
    portfolio_strategies.schema_portfolio_weights.keys()
).cast(
    {"Weight": pl.Float64}
)

active_reserve_weights_shifted_one_period = pl.concat([active_weights_shifted_one_period, reserve_weights_shifted_one_period])

active_strategy_return_input = portfolio_strategies.PortfolioReturnInput(active_reserve_weights_shifted_one_period, active_reserve_returns)
## Apply active investment
apply_investment = portfolio_strategies.PortfolioReturnCalculator(active_strategy_return_input)


def tie_in_strategy(active: InvestmentStrategyPortfolios, reserve: InvestmentStrategyPortfolios, l_target = common_var.l_target, l_trigger = common_var.l_trigger):

    def balancing(returns: dict[str, float], weights: dict[InvestmentStrategyPortfolios, float], initial_values: dict[InvestmentStrategyPortfolios, float]) -> tuple[dict[InvestmentStrategyPortfolios, float], dict[InvestmentStrategyPortfolios, float]]:
        value_active = initial_values[active] * (1 + returns[active.value])
        value_reserve = initial_values[reserve] * (1 + returns[reserve.value])
        new_value = value_active + value_reserve

        l = new_value / value_reserve
        weights_after_balancing = {}
        if l > l_trigger:
            weights_after_balancing[reserve] = 1 / l_target
            weights_after_balancing[active] = 1 - 1 / l_target
        else:
            weights_after_balancing[reserve] = value_reserve / new_value
            weights_after_balancing[active] = value_active / new_value
        values = {active: new_value * weights_after_balancing[active], reserve: new_value * weights_after_balancing[reserve]}
        return weights_after_balancing, values
    return balancing


# Running tdfs
tdf_runs = tdf_returns.filter(
    pl.col("TIME_PERIOD") == pl.col("TDF inception date")
).select(
    ["TIME_PERIOD", "Portfolio", "ZC"]
).rows_by_key(key = ["TIME_PERIOD"], named=True, unique = True)

schema_portfolio_values = {"TIME_PERIOD": pl.Date, "Value": pl.Float64, "Portfolio name": pl.String}
portfolio_values_df = pl.DataFrame(schema = schema_portfolio_values)


for date, values in tdf_runs.items():
    initial_contribution = 100
    tdf_strategy = InvestmentStrategyPortfolios(values["Portfolio"])
    zero_coupon = values["ZC"]

    initial_value_reserve = initial_contribution * (1 / common_var.l_target) * zero_coupon
    initial_value_active = initial_contribution - initial_value_reserve

    initial_values_tie_in = dict()
    initial_values_tie_in[active_strategy] = initial_value_active
    initial_values_tie_in[tdf_strategy] = initial_value_reserve

    initial_weights_tie_in = dict()
    initial_weights_tie_in[active_strategy] = 1 - 1 / common_var.l_target
    initial_weights_tie_in[tdf_strategy] = 1 / common_var.l_target

    tie_in_start_pd = pd.Timestamp(date)
    tie_in_start_pl = pl.date(tie_in_start_pd.year, tie_in_start_pd.month, tie_in_start_pd.day)
    tie_ind_end_pl = common_var.shift_date_by_months(tie_in_start_pd, common_var.tdf_end_in_months)


    values_strategy = apply_investment.portfolio_values("Tie in for " + tdf_strategy.value, initial_weights_tie_in, initial_values_tie_in, tie_in_strategy(active_strategy, tdf_strategy), start_period = tie_in_start_pl, start_period_pd= tie_in_start_pd, end_period= tie_ind_end_pl)
    portfolio_values_df.extend(values_strategy)


px.line(portfolio_values_df, x = "TIME_PERIOD", y = "Value", color = "Portfolio name").show()
# Testing
def tdf_():
    pass


# Defining cppi strategy
def cppi():
    pass
t = 1