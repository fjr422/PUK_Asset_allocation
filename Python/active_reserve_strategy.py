import pandas as pd
import polars as pl

import common_var
from enums import *
import portfolio_strategies

schema_active_reserve_values = schema_portfolio_values = {"TIME_PERIOD": pl.Date, "Value": pl.Float64, "Strategy ID": pl.String, "Fund name": InvestmentStrategyPortfolios, "Initial guarantee": pl.Float64}
class ActiveReserveStrategy:
    def __init__(self, asset_names: tuple, portfolio_universe: portfolio_strategies.PortfolioStrategy, tdf_returns: pl.DataFrame, tdf_weights: pl.DataFrame, active_strategy: InvestmentStrategyPortfolios):
        self.asset_names = asset_names
        self.active_strategy = active_strategy
        self.tdf_returns = tdf_returns

        # Making data for applying strategies for Reserve and Active investment.
        self.portfolio_universe = portfolio_universe
        self.optimal_strategies = self.portfolio_universe.running_optimal_portfolio_strategies(common_var.out_of_sample_period, asset_names, pl.DataFrame({"a": [None]}).clear(), common_var.last_tdf_pl)

        # Dividing by 100 to get proper returns for TDF's
        reserve_returns = self.tdf_returns.select(
            ["TIME_PERIOD", "Portfolio", "Return"]
        ).with_columns(
            (pl.col("Return") / 100).alias("Return")
        )
        # Making returns for selected assets into right format
        assets_returns = self.portfolio_universe.portfolio_universe_EUR.select(
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

        # Shifting the weights one period for assets
        active_weights_shifted_one_period = self.optimal_strategies["Optimal strategies"].select(
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
        # Weights for tdf is one for all periods. No need to shift.
        reserve_weights_shifted_one_period = tdf_weights.select(
            portfolio_strategies.schema_portfolio_weights.keys()
        ).cast(
            {"Weight": pl.Float64}
        )

        active_reserve_weights_shifted_one_period = pl.concat([active_weights_shifted_one_period, reserve_weights_shifted_one_period])

        self.active_reserve_strategy_return_input = portfolio_strategies.PortfolioReturnInput(active_reserve_weights_shifted_one_period, active_reserve_returns)
        ## Apply active investment
        self.apply_investment = portfolio_strategies.PortfolioReturnCalculator(self.active_reserve_strategy_return_input)


    # Defining tie in
    @staticmethod
    def __tie_in_strategy(active: InvestmentStrategyPortfolios, reserve: InvestmentStrategyPortfolios, l_target = common_var.l_target, l_trigger = common_var.l_trigger):
        """Tie in strategy with rebalancing when amount of wealth in asset surpasses l_trigger. Then recalibrated to l_target."""
        def balancing(returns: dict[str, float], weights: dict[InvestmentStrategyPortfolios, float], initial_values: dict[str, float]) -> tuple[dict[InvestmentStrategyPortfolios, float], dict[str, float]]:
            value_active = initial_values[active.value] * (1 + returns[active.value])
            value_reserve = initial_values[reserve.value] * (1 + returns[reserve.value])
            new_value = value_active + value_reserve

            l = new_value / value_reserve
            weights_after_balancing = {}
            if l > l_trigger:
                weights_after_balancing[reserve] = 1 / l_target
                weights_after_balancing[active] = 1 - 1 / l_target
            else:
                weights_after_balancing[reserve] = value_reserve / new_value
                weights_after_balancing[active] = value_active / new_value

            values = {active.value: new_value * weights_after_balancing[active], reserve.value: new_value * weights_after_balancing[reserve]}
            return weights_after_balancing, values
        return balancing

    # Defining cppi strategy
    @staticmethod
    def __cppi_strategy(active: InvestmentStrategyPortfolios, reserve: InvestmentStrategyPortfolios, m: float, l_trigger = common_var.l_trigger, l_target = common_var.l_target, b = 1.0):
        def balancing(returns: dict[str, float], weights: dict[InvestmentStrategyPortfolios, float], initial_values: dict[str, float]) -> tuple[dict[InvestmentStrategyPortfolios, float], dict[str, float]]:
            value_active = initial_values[active.value] * (1 + returns[active.value])
            value_reserve = initial_values[reserve.value] * (1 + returns[reserve.value])
            value_shadow_reserve = initial_values[InvestmentStrategyPortfolios.ShadowReserve.value] * (1 + returns[reserve.value])

            wealth = value_active + value_reserve

            # Determining if trigger and to increase floor
            l = wealth / value_shadow_reserve
            if l > l_trigger:
                rebalanced_shadow_reserve = wealth / l_target
            else:
                rebalanced_shadow_reserve = value_shadow_reserve

            floor = b * rebalanced_shadow_reserve
            cushion = wealth - floor
            exposure = m * cushion

            weight_active = min(exposure, b * wealth) / wealth
            weight_reserve = 1 - weight_active

            weights_after_balancing = dict()
            weights_after_balancing[active] = weight_active
            weights_after_balancing[reserve] = weight_reserve
            weights_after_balancing[InvestmentStrategyPortfolios.ShadowReserve] = 1

            values = {active.value: wealth * weights_after_balancing[active], reserve.value: wealth * weights_after_balancing[reserve], InvestmentStrategyPortfolios.ShadowReserve.value: rebalanced_shadow_reserve}
            return weights_after_balancing, values
        return balancing

    def tie_in_strategies(self, l_trigger = common_var.l_trigger, l_target = common_var.l_target, initial_contribution = 100):
        """Running tie-in strategy.
        Specify
            * l_trigger for other trigger level before recalibration.
            * l_target for other target level for rebalancing and initialisation of strategy.
            * initial_contribution for initial contribution of strategy."""

        tdf_runs = self.tdf_returns.filter(
            pl.col("TIME_PERIOD") == pl.col("TDF inception date")
        ).sort(
            "TIME_PERIOD"
        ).select(
            ["TIME_PERIOD", "Portfolio", "ZC"]
        ).rows_by_key(key = ["TIME_PERIOD"], named=True, unique = True)

        portfolio_values_df = pl.DataFrame(schema = schema_active_reserve_values)
        # Looping over times
        for date, portfolio_info in tdf_runs.items():
            tdf_strategy = InvestmentStrategyPortfolios(portfolio_info["Portfolio"])

            initial_value_reserve = initial_contribution * (1 / l_target)
            initial_value_active = initial_contribution - initial_value_reserve

            initial_guarantee = initial_value_reserve / portfolio_info["ZC"]

            initial_values_tie_in = dict()
            initial_values_tie_in[self.active_strategy.value] = initial_value_active
            initial_values_tie_in[tdf_strategy.value] = initial_value_reserve

            initial_weights_tie_in = dict()
            initial_weights_tie_in[self.active_strategy] = 1 - 1 / l_target
            initial_weights_tie_in[tdf_strategy] = 1 / l_target

            tie_in_start_pd = pd.Timestamp(date)
            tie_in_start_pl = pl.date(tie_in_start_pd.year, tie_in_start_pd.month, tie_in_start_pd.day)
            tie_ind_end_pl = common_var.shift_date_by_months(tie_in_start_pd, common_var.tdf_end_in_months)


            values_strategy = self.apply_investment.portfolio_values("Tie in for " + tdf_strategy.value, initial_weights_tie_in, initial_values_tie_in, self.__tie_in_strategy(self.active_strategy, tdf_strategy, l_target = l_target, l_trigger = l_trigger), start_period = tie_in_start_pl, start_period_pd= tie_in_start_pd, end_period= tie_ind_end_pl)
            portfolio_values_df.extend(values_strategy.with_columns(pl.lit(initial_guarantee).alias("Initial guarantee")))

        return portfolio_values_df

    def cppi_strategies(self, m: float, l_trigger = common_var.l_trigger, l_target = common_var.l_target, b = 1, initial_contribution = 100):
        """CPPI strategy.
        Specify
            * m for multiplier of cushion.
            * b for leverage. Default is 1
            * l_target for initialising strategy. Default is common_var.l_target.
            * initial_contribution for initial contribution of strategy.
            """
        tdf_runs = self.tdf_returns.filter(
            pl.col("TIME_PERIOD") == pl.col("TDF inception date")
        ).select(
            ["TIME_PERIOD", "Portfolio", "ZC"]
        ).rows_by_key(key = ["TIME_PERIOD"], named=True, unique = True)

        portfolio_values_df = pl.DataFrame(schema = schema_active_reserve_values)

        # Looping over times
        for date, portfolio_info in tdf_runs.items():
            tdf_strategy = InvestmentStrategyPortfolios(portfolio_info["Portfolio"])

            initial_value_reserve = initial_contribution * (1 / l_target)
            initial_value_active = initial_contribution - initial_value_reserve

            initial_guarantee = initial_value_reserve / portfolio_info["ZC"]

            initial_values_cppi = dict()
            initial_values_cppi[self.active_strategy.value] = initial_value_active
            initial_values_cppi[tdf_strategy.value] = initial_value_reserve
            initial_values_cppi[InvestmentStrategyPortfolios.ShadowReserve.value] = initial_value_reserve

            initial_weights_cppi = dict()
            initial_weights_cppi[self.active_strategy] = 1 - 1 / l_target
            initial_weights_cppi[tdf_strategy] = 1 / l_target
            initial_weights_cppi[InvestmentStrategyPortfolios.ShadowReserve] = 1

            cppi_start_pd = pd.Timestamp(date)
            cppi_start_pl = pl.date(cppi_start_pd.year, cppi_start_pd.month, cppi_start_pd.day)
            cppi_end_pl = common_var.shift_date_by_months(cppi_start_pd, common_var.tdf_end_in_months)


            values_strategy = self.apply_investment.portfolio_values("CPPI for " + tdf_strategy.value, initial_weights_cppi, initial_values_cppi, self.__cppi_strategy(self.active_strategy, tdf_strategy, m = m, b=b, l_target=l_target, l_trigger=l_trigger), start_period = cppi_start_pl, start_period_pd = cppi_start_pd, end_period = cppi_end_pl)
            portfolio_values_df.extend(values_strategy.with_columns(pl.lit(initial_guarantee).alias("Initial guarantee")))

        return portfolio_values_df