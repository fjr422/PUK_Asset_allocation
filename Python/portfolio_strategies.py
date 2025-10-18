import math
from collections.abc import Callable

import polars as pl
import numpy as np
from scipy.optimize import minimize

from enums import BasePortfolios6, PortFolioRegion, InvestmentStrategyPortfolios

schema_portfolio_weights = {"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion, "Portfolio strategy": InvestmentStrategyPortfolios, "Weight": pl.Float64}
schema_asset_returns = {"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion, "Return": pl.Float64}

class PortfolioStrategy:
    """Get methods for implementing different active portfolio strategies for a list of portfolio names."""
    def __init__(self, fama_french_data: pl.DataFrame):
        """Initialising the portfolios.
        Calculating excess return measured in EUR over RF_EUR."""
        # Returns on long and combined portfolios
        __combined_portfolios_EUR = fama_french_data.select(
            ["TIME_PERIOD", "Region", "Tech Stocks EUR", "Small Cap EUR", "Market_Return_EUR"]
        ).unpivot(
            ["Tech Stocks EUR", "Small Cap EUR", "Market_Return_EUR"], index = ["TIME_PERIOD", "Region"], variable_name = "Portfolio", value_name = "Return_EUR"
        ).with_columns(
            pl.col("Portfolio").str.replace(" EUR", '').str.replace("_EUR", '').cast(BasePortfolios6)
        ).unique(
        )

        # Return on RF for EU and US market measured in EUR.
        __RF_returns_EUR = (fama_french_data.select(
            ["TIME_PERIOD", "Region", "RF_US_EUR", "RF_EU"]
        ).unpivot(
            ["RF_EU", "RF_US_EUR"], index = ["TIME_PERIOD", "Region"], variable_name = "Portfolio", value_name = "Return_EUR"
        ).filter(
            ((pl.col("Portfolio") == "RF_EU") & (pl.col("Region") == "EU")) | ((pl.col("Portfolio") == "RF_US_EUR") & (pl.col("Region") == "US"))
        ).unique(
        ).with_columns(
            (pl.col("Portfolio").str.replace("_US_EUR", '').str.replace("_EU", '')).alias("Portfolio").cast(BasePortfolios6)
        ))

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
        ).sort(
            ["TIME_PERIOD"], descending=False
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

    def __compute_portfolio_sharpe_ratio(self, w: np.ndarray, mu: np.ndarray[float], mu_rf: float, var_matrix: np.ndarray) -> float:
        """Calculate sharpe ratio for a portfolio with weights (w) and covariance matrix (var_matrix) for the assets."""
        portfolio_excess_mean = self.__compute_portfolio_return(w, mu) - mu_rf
        portfolio_variance = self.__compute_portfolio_variance(w, var_matrix)
        return portfolio_excess_mean / math.sqrt(portfolio_variance)

    def __global_minium_variance(self, var_matrix: np.ndarray, assets: list[str]):
        """Weights for global minimum variance portfolio."""
        n_assets = len(assets)
        initial_weights = np.ones(n_assets) / n_assets

        # Constraint: sum of weights must be 1
        constraints = ({'type': 'eq', 'fun': lambda w: np.sum(w) - 1})

        # Bounds for the weights (between 0 and 1)
        bounds = [(0, 1)] * n_assets
        result = minimize(lambda w: self.__compute_portfolio_variance(w, var_matrix), initial_weights, bounds = bounds, constraints = constraints)

        return dict(zip(assets, result.x))  # Optimal weights

    # Minimum variance optimisation for fixed mu
    def __mv_optimisation(self, mu: np.ndarray, var_matrix: np.ndarray, mu_target, assets: str):
        """Finding portfolio with the least variance for a given return."""
        n_assets = len(assets)
        initial_weights = np.ones(n_assets) / n_assets

        # Constraint: sum of weights must be 1
        constraints = ({'type': 'eq', 'fun': lambda w: np.sum(w) - 1},
                       {'type': 'eq', 'fun': lambda w: self.__compute_portfolio_return(w, mu) - mu_target})

        bounds = [(0, 1)] * n_assets
        result = minimize(lambda w: self.__compute_portfolio_variance(w, var_matrix), initial_weights, constraints = constraints, bounds = bounds)
        #"Weights": dict(zip(assets, result.x))
        if result.success:
            return {"Variance": result.fun, "Return": mu_target}
        else:
            print(mu)
            print(var_matrix)
            raise ValueError("Optimization did not converge" )

    # Optimization to maximize Sharpe ratio
    def __optimize_portfolio_sharpe(self, mu_rf: float, mu: np.ndarray[float], var_matrix: np.ndarray, assets: list[str], initial_weights: np.ndarray):
        # Initialize with equal weights
        n_assets = len(assets)
        #initial_weights = np.ones(n_assets) / n_assets

        # Constraint: sum of weights must be 1
        constraints = ({'type': 'eq', 'fun': lambda w: np.sum(w) - 1})
        # Bounds for the weights (between 0 and 1)
        bounds = [(0, 1)] * n_assets

        # Optimization function: maximise Sharpe Ratio
        if (mu < mu_rf).all():
            mu_mod = mu + mu_rf + mu.min()
            result = minimize(lambda w: - self.__compute_portfolio_sharpe_ratio(w, mu_mod, mu_rf, var_matrix), initial_weights, bounds = bounds, constraints = constraints)
        else:
            result = minimize(lambda w: - self.__compute_portfolio_sharpe_ratio(w, mu, mu_rf, var_matrix), initial_weights, bounds = bounds, constraints = constraints)

        return dict(zip(assets, result.x))  # Optimal weights

    @staticmethod
    def __optimize_risk_parity(var_matrix: np.ndarray, assets: list[str]):
        # Positive allocation and equal volatility
        inverse_volatility = 1 / np.sqrt(var_matrix.diagonal())
        total_inverse_volatility = np.sum(inverse_volatility)

        weights = inverse_volatility / total_inverse_volatility

        if not math.isclose(np.sum(weights), 1):
            raise Exception("Weights do not sum to 1.")

        return dict(zip(assets, weights))

    def __efficient_frontier(self, mu: np.ndarray[float], var_matrix: np.ndarray, mu_global_minimum_variance: float, mu_max: float, assets):
        range_returns = np.arange(mu_global_minimum_variance, mu_max, 0.01)

        frontier_schema = {"Return": pl.Float64, "Variance": pl.Float64}
        efficient_frontier = pl.DataFrame(schema = frontier_schema)
        for mu_target in range_returns:
            frontier_values = self.__mv_optimisation(mu, var_matrix, mu_target, assets)
            df_frontier = pl.DataFrame({"Return": frontier_values["Return"], "Variance": frontier_values["Variance"]}).select(frontier_schema.keys())
            efficient_frontier.extend(df_frontier)
        return efficient_frontier

    def __convert_portfolio_to_weight_to_output(self, portfolio_to_weight: dict, mu: np.ndarray[float], var_matrix: np.ndarray, time_period: pl.Date, portfolio_desc: InvestmentStrategyPortfolios, df_schema: dict):
        weights = np.array(list(portfolio_to_weight.values()))
        mu_portfolio = self.__compute_portfolio_return(weights, mu)
        variance_portfolio = self.__compute_portfolio_variance(weights, var_matrix)

        df = pl.from_dict(
            portfolio_to_weight
        ).with_columns(
            pl.lit(time_period).alias("TIME_PERIOD"),
            pl.lit(portfolio_desc).alias("Portfolio strategy"),
            pl.lit(mu_portfolio).alias("Historical return"),
            pl.lit(variance_portfolio).alias("Historical variance"),
        ).unpivot(
            index = ["TIME_PERIOD", "Portfolio strategy", "Historical return", "Historical variance"], variable_name= "Portfolio", value_name = "Weight"
        ).cast(
            {"Portfolio": PortFolioRegion, "Portfolio strategy": InvestmentStrategyPortfolios,}
        ).select(
            list(df_schema.keys())
        )
        return df

    def running_optimal_portfolio_strategies(self, window_size: int, portfolio_names: tuple, dates_efficient_frontier: pl.DataFrame):
        """Find the optimal portfolio weights for the following investment strategies:
            * Mean-variance: weights between 0 and 1
            * Mean-variance: weights unconstrained
            * Risk-parity normalising by equal period volatility
        Parameters:
            * window_size: size of the sliding window in months.
            * portfolio_names: Portfolio universe.
            * dates_efficient_frontier: Dates where efficient frontier is extracted.
        """
        time_periods = self.portfolio_universe_EUR["TIME_PERIOD"].unique().sort(descending = False)
        portfolios = self.portfolio_universe_EUR.filter(
            pl.col("Portfolio").cast(BasePortfolios6).is_in(portfolio_names)
        ).pivot(
            values = "Return_EUR", index = ["TIME_PERIOD", "Return_RF_EU"], on = ["Portfolio", "Region"]
        ).sort(
            ["TIME_PERIOD"], descending=False
        )

        assets = portfolios.unpivot(
            index = ["TIME_PERIOD", "Return_RF_EU"], value_name = "Return_EUR", variable_name = "Portfolio_ID"
        ).with_columns(
            pl.col("Portfolio_ID").cast(PortFolioRegion),
        )["Portfolio_ID"].unique().sort()

        # Getting returns. Order is portfolio_IDs. Not using RF_EUR
        returns = portfolios[assets.to_list()].to_numpy()
        mu_rf = portfolios["Return_RF_EU"].rolling_mean(window_size).to_numpy()

        # Looping across window and finding optimal portfolio weights
        weights_schema = {"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion, "Weight": pl.Float64, "Portfolio strategy": InvestmentStrategyPortfolios, "Historical return": pl.Float64, "Historical variance": pl.Float64}
        optimized_weights = pl.DataFrame(schema = weights_schema)
        efficient_frontier_schema = {"TIME_PERIOD": pl.Date, "Portfolio": PortFolioRegion, "Historical return": pl.Float64, "Historical variance": pl.Float64, "Type": pl.String}
        efficient_frontier = pl.DataFrame(schema = efficient_frontier_schema)

        for i in range(window_size - 1, len(time_periods)):
            rolling_returns = returns.copy()[i - window_size + 1:i + 1]

            # Input values
            mu = np.mean(rolling_returns, axis=0)
            var_matrix = np.cov(rolling_returns, rowvar=False)
            time_period = time_periods[i]

            # Global minimum variance
            global_minimum_variance_dict = self.__global_minium_variance(var_matrix, assets)
            global_minimum_variance = self.__convert_portfolio_to_weight_to_output(global_minimum_variance_dict, mu, var_matrix, time_period, InvestmentStrategyPortfolios.GlobalMV, weights_schema)

            # Mean-variance optimisation of Sharpe-Ratio
            mv_bounded_dict = self.__optimize_portfolio_sharpe(mu_rf[i], mu, var_matrix, assets, np.array(list(global_minimum_variance_dict.values())))
            mv_bounded = self.__convert_portfolio_to_weight_to_output(mv_bounded_dict, mu, var_matrix, time_period, InvestmentStrategyPortfolios.MV, weights_schema)

            # Risk parity
            risk_parity_dict = self.__optimize_risk_parity(var_matrix, assets)
            risk_parity = self.__convert_portfolio_to_weight_to_output(risk_parity_dict, mu, var_matrix, time_period, InvestmentStrategyPortfolios.RP, weights_schema)

            # Combining and adding
            investment_strategies = pl.concat([global_minimum_variance, mv_bounded, risk_parity])

            optimized_weights.extend(investment_strategies)

            # Efficient_frontier when relevant
            if not dates_efficient_frontier.filter(pl.col("Date") == time_period).is_empty():
                efficient_frontier_bounded_data = self.__efficient_frontier(mu, var_matrix, global_minimum_variance["Historical return"].min(), mu.max(), assets)

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
                    {"Portfolio": assets, "Historical return": mu, "Historical variance": var_matrix.diagonal()}
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

        self.efficient_frontier = efficient_frontier
        self.optimal_portfolios = optimized_weights
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

    def portfolio_values(self, portfolio_name: str, initial_value: float, initial_weights: dict[InvestmentStrategyPortfolios, float], balancing_method: Callable[[dict[str, float], dict[InvestmentStrategyPortfolios, float], float], tuple[dict[InvestmentStrategyPortfolios, float], float]]):

        time_period_to_investment_strategy_to_return = self.strategy_returns.pivot(
            index = "TIME_PERIOD", values = "Return", on = "Portfolio strategy"
        ).sort(
            "TIME_PERIOD"
        ).rows_by_key(
            key = "TIME_PERIOD", named = True, unique = True
        )

        schema_portfolio_values = {"TIME_PERIOD": pl.Date, "Value": pl.Float64, "Portfolio name": pl.String}
        portfolio_values_df = pl.DataFrame(schema = schema_portfolio_values)

        dict_value = {}
        for time_period, returns in time_period_to_investment_strategy_to_return.items():
            initial_weights, initial_value = balancing_method(returns, initial_weights, initial_value)
            dict_value[str(time_period)] = initial_value

        df_values = pl.from_dict(dict_value).unpivot(
            variable_name= "TIME_PERIOD", value_name = "Value"
        ).with_columns(
            pl.col("TIME_PERIOD").cast(pl.Date).alias("TIME_PERIOD"),
            pl.lit(portfolio_name).alias("Portfolio name")
        ).select(
            schema_portfolio_values.keys()
        )
        return pl.concat([portfolio_values_df, df_values])
