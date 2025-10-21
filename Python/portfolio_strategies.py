import math
from collections.abc import Callable

import polars as pl
import numpy as np
from scipy.optimize import minimize

import common_var
from enums import BasePortfolios6, PortFolioRegion, InvestmentStrategyPortfolios

schema_portfolio_weights = {"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion, "Portfolio strategy": InvestmentStrategyPortfolios, "Weight": pl.Float64}
schema_asset_returns = {"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion, "Return": pl.Float64}
schema_portfolio_values = {"TIME_PERIOD": pl.Date, "Value": pl.Float64, "Portfolio name": pl.String}

class PortfolioStrategy:
    """Get methods for implementing different active portfolio strategies for a list of portfolio names."""
    def __init__(self, fama_french_data: pl.DataFrame):
        """Initialising the portfolios.
        Calculating excess return measured in EUR over RF_EUR."""
        # Returns on long and combined portfolios
        __combined_portfolios_EUR = fama_french_data.select(
            ["TIME_PERIOD", "Region", "Tech Stocks EUR", "Small Cap EUR", "Market_Return_EUR", "MOM_EUR", "SMB_EUR"]
        ).unpivot(
            ["Tech Stocks EUR", "Small Cap EUR", "Market_Return_EUR", "MOM_EUR", "SMB_EUR"], index = ["TIME_PERIOD", "Region"], variable_name = "Portfolio", value_name = "Return_EUR"
        ).with_columns(
            pl.col("Portfolio").str.replace(" EUR", '').str.replace("_EUR", '').cast(BasePortfolios6),
        ).unique(
        )

        # Return on RF for EU and US market measured in EUR.
        __RF_returns_EUR = fama_french_data.select(
            ["TIME_PERIOD", "Region", "RF_US_EUR", "RF_EU"]
        ).unpivot(
            ["RF_EU", "RF_US_EUR"], index = ["TIME_PERIOD", "Region"], variable_name = "Portfolio", value_name = "Return_EUR"
        ).filter(
            ((pl.col("Portfolio") == "RF_EU") & (pl.col("Region") == "EU")) | ((pl.col("Portfolio") == "RF_US_EUR") & (pl.col("Region") == "US"))
        ).unique(
        ).with_columns(
            (pl.col("Portfolio").str.replace("_US_EUR", '').str.replace("_EU", '')).alias("Portfolio").cast(BasePortfolios6)
        )

        # Check if only one RF_EU/US pr. period.
        __check_RF = __RF_returns_EUR.group_by(
            "TIME_PERIOD"
        ).len(
        ).filter(pl.col("len") > 0)
        if __check_RF.is_empty():
            raise Exception("More than one RF_EU or RF_US_EUR for a time period. Expected only one.")

        __fama_french_data = fama_french_data.select(
            ["TIME_PERIOD", "Region", "Portfolio", "Monthly_Exchange_Return", "Return_EUR"]
        ).select(
            ["TIME_PERIOD", "Region", "Portfolio", "Return_EUR"]
        ).with_columns(
            pl.col("Portfolio").cast(BasePortfolios6)
        )

        __RF_EUR_TIME_PERIOD = __RF_returns_EUR.filter(
            pl.col("Region") == "EU"
        ).pivot(
            "Portfolio", values = "Return_EUR", index = "TIME_PERIOD"
        ).rename({"RF": "Return_RF_EU"})

        self.portfolio_universe_EUR = pl.concat(
            [__RF_returns_EUR, __combined_portfolios_EUR, __fama_french_data]
        ).join(
            __RF_EUR_TIME_PERIOD, on = "TIME_PERIOD"
        ).select(
            ["TIME_PERIOD", "Portfolio", "Region", "Return_EUR", "Return_RF_EU"]
        ).with_columns(
            (pl.col("Return_EUR") - pl.col("Return_RF_EU")).alias("Excess return RF_EU"),
            ('{"' + pl.col("Portfolio") + '","' + pl.col("Region") + '"}').alias("Portfolio region").cast(PortFolioRegion)
        ).sort(
            ["Portfolio", "TIME_PERIOD"], descending=False
        )

    # Methods
    @staticmethod
    def __compute_portfolio_variance(w: np.ndarray, var_matrix: np.ndarray) -> float:
        """Compute covariance matrix for a portfolio with weights (w) and covariance matrix (var_matrix) for the assets."""
        return np.dot(w.T, np.dot(var_matrix, w))

    # A function to compute the expected portfolio return
    @staticmethod
    def __compute_portfolio_return(w: np.ndarray, mu: np.ndarray[float]) -> float:
        """Compute expected surplus return for assets.
        w: weights.
        mu: Expected surplus return for assets."""
        return np.dot(w, mu)

    def __compute_portfolio_sharpe_ratio(self, w: np.ndarray, mu: np.ndarray[float], mu_e: np.ndarray[float], var_matrix: np.ndarray, var_matrix_e: np.ndarray, include_rf: bool, index_rf: int) -> float:
        """Calculate sharpe ratio for a portfolio with weights (w) and covariance matrix (var_matrix) for the assets."""

        if include_rf:
            portfolio_mean = self.__compute_portfolio_return(np.delete(w, index_rf, axis = 0), mu_e)
            portfolio_variance = self.__compute_portfolio_variance(np.delete(w, index_rf, axis = 0), var_matrix_e)
        else:
            portfolio_mean = self.__compute_portfolio_return(w, mu)
            portfolio_variance = self.__compute_portfolio_variance(w, var_matrix)
        return portfolio_mean / math.sqrt(portfolio_variance)

    # Optimization to maximize Sharpe ratio
    def __optimize_portfolio_sharpe(self, mu: np.ndarray[float], mu_e: np.ndarray[float], var_matrix: np.ndarray, var_matrix_e: np.ndarray, asset_names: tuple, initial_weights: np.ndarray, include_rf: bool, index_rf: int):
        # Initialize with equal weights
        n_assets = len(asset_names)

        weights = np.ones(n_assets) / n_assets

        # Constraint: sum of weights must be 1
        constraints = ({'type': 'eq', 'fun': lambda w: np.sum(w) - 1})
        # Bounds for the weights (between 0 and 1)
        bounds = [(0, 1)] * n_assets

        # Optimization function: maximise Sharpe Ratio
        if include_rf:
            # When RF is available and every other asset has negative excess return maximal sharpe will be all-in on RF.
            if (mu_e < 0).all():
                weights[:index_rf] = 0
                weights[index_rf + 1:] = 0
                weights[index_rf] = 1
                return dict(zip(asset_names, weights))
        result = minimize(lambda w: - self.__compute_portfolio_sharpe_ratio(w, mu, mu_e, var_matrix, var_matrix_e, include_rf, index_rf), weights, bounds = bounds, constraints = constraints)
        return dict(zip(asset_names, result.x))  # Optimal weights

    def __global_minium_variance(self, var_matrix: np.ndarray, assets: tuple[PortFolioRegion], include_rf: bool, index_rf: int):
        """Weights for global minimum variance portfolio. If risk-free is included. All in that"""

        n_assets = len(assets)
        initial_weights = np.ones(n_assets) / n_assets

        if include_rf:
            initial_weights[:index_rf] = 0
            initial_weights[index_rf + 1:] = 0
            initial_weights[index_rf] = 1
            return  dict(zip(assets, initial_weights))
        else:
            # Constraint: sum of weights must be 1
            constraints = ({'type': 'eq', 'fun': lambda w: np.sum(w) - 1})

            # Bounds for the weights (between 0 and 1)
            bounds = [(0, 1)] * n_assets
            result = minimize(lambda w: self.__compute_portfolio_variance(w, var_matrix), initial_weights, bounds = bounds, constraints = constraints)

            return dict(zip(assets, result.x))  # Optimal weights

    @staticmethod
    def __maximal_return(mu: np.ndarray, mu_e: np.ndarray, asset_names: tuple, include_rf: bool, index_rf: int):
        weights = np.zeros(len(asset_names))
        if include_rf:
            if (mu_e < 0).all():
                weights[index_rf] = 1
            else:
                weights[np.argmax(mu_e)] = 1
        else: weights[np.argmax(mu)] = 1
        return dict(zip(asset_names, weights))

    @staticmethod
    def __optimize_risk_parity(var_matrix: np.ndarray, asset_names: tuple):
        # Positive allocation and equal volatility
        inverse_volatility = 1 / np.sqrt(var_matrix.diagonal())
        total_inverse_volatility = np.sum(inverse_volatility)

        weights = inverse_volatility / total_inverse_volatility

        if not math.isclose(np.sum(weights), 1):
            raise Exception("Weights do not sum to 1.")

        return dict(zip(asset_names, weights))

    # Minimum variance optimisation for fixed mu
    def __mv_optimisation(self, mu: np.ndarray, mu_e: np.ndarray, var_matrix: np.ndarray, var_matrix_e: np.ndarray, mu_target, assets: str, include_rf: bool, index_rf: int):
        """Finding portfolio with the least variance for a given return."""
        n_assets = len(assets)
        initial_weights = np.ones(n_assets) / n_assets

        bounds = [(0, 1)] * n_assets

        # Constraint: sum of weights must be 1 and hit target return
        if include_rf:
            constraints = ({'type': 'eq', 'fun': lambda w: np.sum(w) - 1},
                           {'type': 'eq', 'fun': lambda w: self.__compute_portfolio_return(np.delete(w, index_rf, axis = 0), mu_e) - mu_target})
            result = minimize(lambda w: self.__compute_portfolio_variance(np.delete(w, index_rf, axis = 0), var_matrix_e), initial_weights, constraints = constraints, bounds = bounds)
        else:
            constraints = ({'type': 'eq', 'fun': lambda w: np.sum(w) - 1},
                           {'type': 'eq', 'fun': lambda w: self.__compute_portfolio_return(w, mu) - mu_target})
            result = minimize(lambda w: self.__compute_portfolio_variance(w, var_matrix), initial_weights, constraints = constraints, bounds = bounds)

        if result.success:
            return {"Variance": result.fun, "Return": mu_target}
        else:
            raise Exception("Optimization did not converge" )

    def __efficient_frontier(self, mu: np.ndarray, mu_e:np.ndarray, var_matrix: np.ndarray, var_matrix_e: np.ndarray, mu_global_minimum_variance: float, mu_max: float, assets, include_rf: bool, index_rf: int):
        frontier_schema = {"Return": pl.Float64, "Variance": pl.Float64}
        efficient_frontier = pl.DataFrame(schema = frontier_schema)

        if include_rf:
            if (mu_e < 0).all(): # If none is greater than risk free. Then optimal is to be in RF.
                return efficient_frontier

        range_returns = np.arange(mu_global_minimum_variance, mu_max, 0.01)

        for mu_target in range_returns:
            frontier_values = self.__mv_optimisation(mu, mu_e, var_matrix, var_matrix_e, mu_target, assets, include_rf, index_rf)
            df_frontier = pl.DataFrame({"Return": frontier_values["Return"], "Variance": frontier_values["Variance"]}).select(frontier_schema.keys())
            efficient_frontier.extend(df_frontier)
        return efficient_frontier

    def __convert_portfolio_to_weight_to_output(self, portfolio_to_weight: dict, mu: np.ndarray[float], mu_e: np.ndarray[float], var_matrix: np.ndarray, var_matrix_e: np.ndarray, include_rf: bool, index_rf: int, time_period: pl.Date, portfolio_desc: InvestmentStrategyPortfolios, df_schema: dict):
        weights = np.array(list(portfolio_to_weight.values()))

        if include_rf:
            mu_portfolio = self.__compute_portfolio_return(np.delete(weights, index_rf, axis = 0), mu_e)
            variance_portfolio = self.__compute_portfolio_variance(np.delete(weights, index_rf, axis = 0), var_matrix_e)
        else:
            mu_portfolio = self.__compute_portfolio_return(weights, mu)
            variance_portfolio = self.__compute_portfolio_variance(weights, var_matrix)

        df = pl.from_dict(
            portfolio_to_weight
        ).with_columns(
            pl.lit(time_period).alias("TIME_PERIOD"),
            pl.lit(portfolio_desc).alias("Portfolio strategy"),
            pl.lit(mu_portfolio).alias("Historical return"),
            pl.lit(variance_portfolio).alias("Historical variance"),
            pl.lit(include_rf).alias("Is RF Included"),
        ).unpivot(
            index = ["TIME_PERIOD", "Portfolio strategy", "Historical return", "Historical variance", "Is RF Included"], variable_name = "Portfolio", value_name = "Weight"
        ).cast(
            {"Portfolio": PortFolioRegion, "Portfolio strategy": InvestmentStrategyPortfolios,}
        ).select(
            list(df_schema.keys())
        )
        return df

    def running_optimal_portfolio_strategies(self, window_size: int, asset_names: tuple, dates_efficient_frontier: pl.DataFrame, stop_date: pl.date):
        """Find the optimal portfolio weights for the following investment strategies:
            * Mean-variance: weights between 0 and 1
            * Mean-variance: weights unconstrained
            * Risk-parity normalising by equal period volatility
        Parameters:
            * window_size: size of the sliding window in months.
            * asset_names: Portfolio universe.
            * dates_efficient_frontier: Dates where efficient frontier is extracted.
        """
        def tuple_except_index(tuple_to_mod: tuple, index_to_exclude: int):
            return tuple_to_mod[:index_to_exclude] + tuple_to_mod[index_to_exclude + 1:]

        time_periods = self.portfolio_universe_EUR.filter(pl.col("TIME_PERIOD") <= stop_date)["TIME_PERIOD"].unique().sort(descending = False)

        portfolios_return = self.portfolio_universe_EUR.filter(
            pl.col("Portfolio region").cast(PortFolioRegion).is_in(asset_names)
        ).select(
            ["TIME_PERIOD", "Portfolio region", "Return_RF_EU", "Return_EUR"]
        ).pivot(
            values = "Return_EUR", index = ["TIME_PERIOD", "Return_RF_EU"], on = "Portfolio region"
        ).sort(
            ["TIME_PERIOD"], descending=False
        )
        portfolios_excess_return = self.portfolio_universe_EUR.filter(
            pl.col("Portfolio region").cast(PortFolioRegion).is_in(asset_names)
        ).select(
            ["TIME_PERIOD", "Portfolio region", "Excess return RF_EU", "Return_RF_EU"]
        ).pivot(
            values = "Excess return RF_EU", index = ["TIME_PERIOD", "Return_RF_EU"], on = "Portfolio region"
        ).sort(
            ["TIME_PERIOD"], descending=False
        )

        # Getting returns. Order is portfolio_IDs.
        include_rf = PortFolioRegion.RfEu.value in asset_names
        returns = portfolios_return[asset_names].to_numpy()
        if include_rf:
            index_rf = asset_names.index(PortFolioRegion.RfEu.value)
            excess_returns = portfolios_excess_return[tuple_except_index(asset_names, index_rf)].to_numpy()
        else:
            index_rf = None
            excess_returns = None

        # Looping across window and finding optimal portfolio weights
        weights_schema = {"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion, "Weight": pl.Float64, "Portfolio strategy": InvestmentStrategyPortfolios, "Historical return": pl.Float64, "Historical variance": pl.Float64}
        optimized_weights = pl.DataFrame(schema = weights_schema)
        efficient_frontier_schema = {"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion, "Historical return": pl.Float64, "Historical variance": pl.Float64, "Type": pl.String}
        efficient_frontier = pl.DataFrame(schema = efficient_frontier_schema)

        for i in range(window_size - 1, len(time_periods)):
            # Input values
            rolling_returns = returns[i - window_size + 1:i + 1]
            mu = np.mean(rolling_returns, axis=0)
            var_matrix = np.cov(rolling_returns, rowvar=False)
            if include_rf:
                rolling_excess_returns = excess_returns[i - window_size + 1:i + 1]
                mu_e = np.mean(rolling_excess_returns, axis=0)
                var_matrix_e = np.cov(rolling_excess_returns, rowvar=False)
            else:
                mu_e = None
                var_matrix_e = None

            time_period = time_periods[i]

            # Global minimum variance
            global_minimum_variance_dict = self.__global_minium_variance(var_matrix, asset_names, include_rf, index_rf)
            global_minimum_variance = self.__convert_portfolio_to_weight_to_output(global_minimum_variance_dict, mu, mu_e, var_matrix, var_matrix_e, include_rf, index_rf, time_period, InvestmentStrategyPortfolios.GlobalMV, weights_schema)

            # Maximal return
            maximal_return_dict = self.__maximal_return(mu, mu_e, asset_names, include_rf, index_rf)
            maximal_return = self.__convert_portfolio_to_weight_to_output(maximal_return_dict, mu, mu_e, var_matrix, var_matrix_e, include_rf, index_rf, time_period, InvestmentStrategyPortfolios.MaxReturn, weights_schema)

            # Mean-variance optimisation of Sharpe-Ratio
            gmv_weights = np.array(list(global_minimum_variance_dict.values()))

            mv_bounded_dict = self.__optimize_portfolio_sharpe(mu, mu_e, var_matrix, var_matrix_e, asset_names, gmv_weights, include_rf, index_rf)
            mv_bounded = self.__convert_portfolio_to_weight_to_output(mv_bounded_dict,mu, mu_e, var_matrix, var_matrix_e, include_rf, index_rf, time_period, InvestmentStrategyPortfolios.MV, weights_schema)

            # Risk parity
            risk_parity_dict = self.__optimize_risk_parity(var_matrix, asset_names)
            risk_parity = self.__convert_portfolio_to_weight_to_output(risk_parity_dict, mu, mu_e, var_matrix, var_matrix_e, include_rf, index_rf, time_period, InvestmentStrategyPortfolios.RP, weights_schema)

            # Combining and adding
            investment_strategies = pl.concat([global_minimum_variance, maximal_return, mv_bounded, risk_parity])

            optimized_weights.extend(investment_strategies)

            # Efficient_frontier when relevant
            if not dates_efficient_frontier.is_empty():
                if not dates_efficient_frontier.filter(pl.col("Date") == time_period).is_empty():
                    if include_rf:
                        mu_max = mu_e.max()
                        mu_plot = np.insert(mu_e, index_rf, 0)
                    else:
                        mu_max = mu.max()
                        mu_plot = mu.copy()

                    efficient_frontier_bounded_data = self.__efficient_frontier(mu, mu_e, var_matrix, var_matrix_e, global_minimum_variance["Historical return"].min(), mu_max, asset_names, include_rf, index_rf)

                    efficient_frontier_bounded = efficient_frontier_bounded_data.with_columns(
                        pl.lit("l").alias("Type"),
                        pl.lit(PortFolioRegion.BoundedEfficientFrontier).alias("Portfolio"),
                        pl.lit(time_period).alias("TIME_PERIOD")
                    ).rename(
                        {"Return": "Historical return", "Variance": "Historical variance"}
                    ).cast(
                        {"Portfolio": PortFolioRegion}
                    ).select(efficient_frontier_schema.keys())

                    portfolios_frontier = pl.DataFrame(
                        {"Portfolio": asset_names, "Historical return": mu_plot, "Historical variance": var_matrix.diagonal()}
                    ).with_columns(
                        pl.lit("p").alias("Type"),
                        pl.lit(time_period).alias("TIME_PERIOD")
                    ).cast(
                        {"Portfolio": PortFolioRegion}
                    ).select(efficient_frontier_schema.keys())

                    investment_strategies_frontier = investment_strategies.with_columns(
                        pl.col("Portfolio strategy").alias("Portfolio")
                    ).group_by(
                        ["TIME_PERIOD", "Portfolio"]
                    ).agg(
                        pl.first("Historical return"),
                         pl.first("Historical variance")
                    ).with_columns(
                        pl.lit("p").alias("Type")
                    ).cast(
                        {"Portfolio": PortFolioRegion}
                    ).select(efficient_frontier_schema.keys())

                    efficient_frontier_time = pl.concat([portfolios_frontier, efficient_frontier_bounded, investment_strategies_frontier])
                    efficient_frontier.extend(
                        efficient_frontier_time
                    )

        return {"Optimal strategies": optimized_weights, "Efficient frontier": efficient_frontier}

# Portfolio return classes
class PortfolioReturnInput:
    def __init__(self, portfolio_weights_df: pl.DataFrame, asset_returns_df: pl.DataFrame):

        __portfolio_weights_df_init = pl.DataFrame(schema = schema_portfolio_weights)
        self.portfolio_weights = pl.concat([__portfolio_weights_df_init, portfolio_weights_df])
        
        __asset_return_df = pl.DataFrame(schema = schema_asset_returns)
        self.portfolio_returns = pl.concat([__asset_return_df, asset_returns_df])

class PortfolioReturnCalculator:
    def __init__(self, portfolio_return_input: PortfolioReturnInput):
        """Calculates the return in a portfolio of assets.
        Expected input is a PortfolioReturnInput object. This contains:
            * portfolio_weights: A polars DataFrame with the weights from the previous time period shifted to the next for a given investment strategy. This ensures return is calculated with the weights at t_i- before rebalancing at t_i.
            * portfolio_returns: A polars DataFrame with the returns for each time_period for the possible assets to invest in."""
        # Validating all assets for investment strategies are present
        assets_in_weights = portfolio_return_input.portfolio_weights["Portfolio"].unique().sort().to_list()
        assets_in_returns = portfolio_return_input.portfolio_returns["Portfolio"].unique().sort().to_list()

        if len(set(assets_in_returns).symmetric_difference(set(assets_in_weights))) > 0:
            raise Exception("Mismatch between known assets in weight and return DataFrames")

        self.strategy_returns = portfolio_return_input.portfolio_weights.join(
            portfolio_return_input.portfolio_returns, on = ["TIME_PERIOD", "Portfolio"], how = "inner"
        ).with_columns(
            (pl.col("Weight") * pl.col("Return")).alias("Weighted return")
        ).group_by(
            ["TIME_PERIOD", "Portfolio strategy"]
        ).agg(
            pl.col("Weighted return").sum().alias("Return")
        ).cast(
            {"Portfolio strategy": InvestmentStrategyPortfolios}
        ).sort(
            ["Portfolio strategy", "TIME_PERIOD"]
        )



    def portfolio_values(self, portfolio_name: str, initial_weights: dict[InvestmentStrategyPortfolios, float], initial_values: dict[str, float], balancing_method: Callable[[dict[str, float], dict[InvestmentStrategyPortfolios, float], dict[InvestmentStrategyPortfolios, float]], tuple[dict[InvestmentStrategyPortfolios, float], dict[InvestmentStrategyPortfolios, float]]], start_period = common_var.portfolios_start_date_pl, start_period_pd = common_var.portfolios_start_date_pd, end_period = common_var.last_tdf_pl):
        """Calculate the value of a portfolio for an investment strategy where balancing at each timepoint."""
        portfolio_strategies_names = [name.value for name in initial_weights.keys() ]
        time_period_to_investment_strategy_to_return = self.strategy_returns.filter(
            pl.col("Portfolio strategy").is_in(portfolio_strategies_names),
        ).filter(
            (pl.col("TIME_PERIOD") > start_period) & (pl.col("TIME_PERIOD") <= end_period)
        ).pivot(
            index = "TIME_PERIOD", values = "Return", on = "Portfolio strategy"
        ).sort(
            "TIME_PERIOD"
        ).rows_by_key(
            key = "TIME_PERIOD", named = True, unique = True
        )


        portfolio_values_df = pl.DataFrame(schema = schema_portfolio_values)
# TODO: Fix
        value_at_inception = pl.from_dict(initial_values).unpivot(
            variable_name = "Portfolio", value_name= "Value"
            ).filter(
                pl.col("Portfolio") != InvestmentStrategyPortfolios.ShadowReserve.value
            )["Value"].sum()

        first_value_dict = {"Year": start_period_pd.year, "Month": start_period_pd.month, "Day": start_period_pd.day}
        first_value = pl.from_dict(first_value_dict).with_columns(
            pl.date(pl.col("Year"), pl.col("Month"), pl.col("Day")).cast(pl.Date).alias("TIME_PERIOD"),
            pl.lit(value_at_inception).cast(pl.Float64).alias("Value"),
            pl.lit(portfolio_name).cast(pl.String).alias("Portfolio name"),
        ).select(schema_portfolio_values.keys())

        dict_value = dict()

        for time_period, returns in time_period_to_investment_strategy_to_return.items():
            initial_weights, initial_values = balancing_method(returns, initial_weights, initial_values)
            dict_value[str(time_period)] = pl.from_dict(
                initial_values
            ).unpivot( variable_name= "Portfolio", value_name= "Value"
            ).filter(
                pl.col("Portfolio") != InvestmentStrategyPortfolios.ShadowReserve.value
            )["Value"].sum()

        df_values = pl.from_dict(dict_value).unpivot(
            variable_name= "TIME_PERIOD", value_name = "Value"
        ).with_columns(
            pl.col("TIME_PERIOD").cast(pl.Date).alias("TIME_PERIOD"),
            pl.lit(portfolio_name).alias("Portfolio name")
        ).select(
            schema_portfolio_values.keys()
        )

        return pl.concat([portfolio_values_df, first_value, df_values])

    def all_in_strategy_returns(self, investment_strategy_portfolio: InvestmentStrategyPortfolios, initial_value, start_period = common_var.portfolios_start_date_pl, start_period_pd = common_var.portfolios_start_date_pd, end_period = common_var.last_tdf_pl): # -> Callable[[dict[str, float], dict[InvestmentStrategyPortfolios, float], dict[InvestmentStrategyPortfolios, float]], tuple[dict[InvestmentStrategyPortfolios, float], dict[InvestmentStrategyPortfolios, float]]]:
        """Strategy going all in on one asset."""
        def balancing(returns: dict[str, float], weights: dict[InvestmentStrategyPortfolios, float], initial_values: dict[InvestmentStrategyPortfolios, float]) -> tuple[dict[InvestmentStrategyPortfolios, float], dict[InvestmentStrategyPortfolios, float]]:
            value = {investment_strategy_portfolio: initial_values[investment_strategy_portfolio] * weights[investment_strategy_portfolio] * (1 + returns[investment_strategy_portfolio.value])}
            weights = {investment_strategy_portfolio: 1}
            return weights, value
        initial_weights_dict = {investment_strategy_portfolio: 1}
        initial_value_dict = {investment_strategy_portfolio.value: initial_value}
        return self.portfolio_values(investment_strategy_portfolio.value, initial_weights_dict, initial_value_dict, balancing, start_period, start_period_pd, end_period) #balancing