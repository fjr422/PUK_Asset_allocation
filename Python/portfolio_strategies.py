import math
from operator import indexOf

import polars as pl
import numpy as np
from scipy.optimize import minimize


class MeanVarianceStrategy:
    def __init__(self, fama_french_data: pl.DataFrame, portfolio_names: list[str]):
        """Initialising the portfolios.
        Calculating excess return measured in EUR over RF_EUR."""

        # Returns on long and combined portfolios
        __combined_portfolios_EUR = fama_french_data.select(
            ["TIME_PERIOD", "Region", "Tech Stocks EUR", "Small Cap EUR"]
        ).unpivot(
            ["Tech Stocks EUR", "Small Cap EUR"], index = ["TIME_PERIOD", "Region"], variable_name = "Portfolio", value_name = "Return_EUR"
        ).with_columns(
            pl.col("Portfolio").str.replace(" EUR", '')
        ).unique(
        )

        # Return on RF for EU and US market measured in EUR.
        __RF_returns_EUR = (fama_french_data.select(
            ["TIME_PERIOD", "Region", "RF_USD", "RF_EUR", "Monthly_Exchange_Return"]
        ).with_columns(
            ((pl.col("RF_USD") + 100) * pl.col("Monthly_Exchange_Return") - 100).alias("RF_USD")
        ).select(
            pl.exclude("Monthly_exchange_return")
        ).unpivot(
            ["RF_EUR", "RF_USD"], index = ["TIME_PERIOD", "Region"], variable_name = "Portfolio", value_name = "Return_EUR"
        ).filter(
            ((pl.col("Portfolio") == "RF_EUR") & (pl.col("Region") == "EU")) | ((pl.col("Portfolio") == "RF_USD") & (pl.col("Region") == "US"))
        ).unique(
        ).with_columns(
            (pl.col("Portfolio").str.replace("_EUR", '').str.replace("_USD", '')).alias("Portfolio")
        ))

        # Check if only one RF_EU/US pr. period.
        __check_RF = __RF_returns_EUR.group_by(
            "TIME_PERIOD"
        ).len(
        ).filter(pl.col("len") > 0)
        if __check_RF.is_empty():
            raise Exception("More than one RF_EUR for a time period. Expected only one.")

        __fama_french_data = fama_french_data.select(
            ["TIME_PERIOD", "Region", "Portfolio", "Monthly_Exchange_Return", "Return_EUR"]
        ).filter(
            pl.col("Portfolio").is_in(portfolio_names)
        ).select(
            ["TIME_PERIOD", "Region", "Portfolio", "Return_EUR"]
        )

        __RF_EUR_TIME_PERIOD = __RF_returns_EUR.filter(
            pl.col("Region") == "EU"
        ).pivot(
            "Portfolio", values = "Return_EUR", index = "TIME_PERIOD"
        ).rename({"RF": "Return_RF_EU"})

        self.portfolio_return_EUR = (pl.concat(
            [__RF_returns_EUR, __combined_portfolios_EUR, __fama_french_data]
        ).filter(
            pl.col("Portfolio").is_in(portfolio_names)
        ).join(
            __RF_EUR_TIME_PERIOD, on = "TIME_PERIOD"
        ).select(
            ["TIME_PERIOD", "Portfolio", "Region", "Return_EUR"]
        # ).with_columns(
        #     (pl.col("Return_EUR") / 100).alias("Return_EUR")
        ).pivot(
            values = "Return_EUR", index = "TIME_PERIOD", columns = ["Portfolio", "Region"]
        ).sort(
            "TIME_PERIOD", descending=False
        ))

        self.portfolio_IDs = self.portfolio_return_EUR.unpivot(
            index = "TIME_PERIOD", value_name = "Return_EUR", variable_name = "Portfolio_ID"
        )["Portfolio_ID"].unique().sort()

    def __compute_portfolio_variance(self, w: np.ndarray[float], Sigma: np.ndarray) -> float:
        """Compute covariance matrix for a portfolio with weights (w) and covariance matrix (Sigma) for the assets."""
        return np.dot(w.T, np.dot(Sigma, w))

    # A function to compute the expected portfolio return
    def __compute_portfolio_return(self, w: np.ndarray[float], mu: np.ndarray[float]) -> float:
        """Compute expected surplus return for assets.
        w: weights.
        mu: Expected surplus return for assets."""
        return np.dot(w, mu)

    def __calculate_sharpe_ratio(self, w: np.ndarray[float], mu: np.ndarray[float], mu_rf: float, Sigma: np.ndarray) -> float:
        """Calculate sharpe ratio for a portfolio with weights (w) and covariance matrix (Sigma) for the assets."""
        portfolio_excess_mean = self.__compute_portfolio_return(w, mu) - mu_rf
        portfolio_variance = self.__compute_portfolio_variance(w, Sigma)
        return portfolio_excess_mean / math.sqrt(portfolio_variance)

    # Optimization to maximize Sharpe ratio
    def __optimize_portfolio_sharpe(self, mu_rf: float, mu: np.ndarray[float], Sigma: np.ndarray, full_frontier: bool):
        # Initialize with equal weights
        n_assets = len(self.portfolio_IDs)
        initial_weights = np.ones(n_assets) / n_assets

        # Constraint: sum of weights must be 1
        constraints = ({'type': 'eq', 'fun': lambda w: np.sum(w) - 1})

        # Optimization function: maximise Sharpe Ratio
        if full_frontier:
            result = minimize(lambda w: - self.__calculate_sharpe_ratio(w, mu, mu_rf, Sigma), initial_weights, constraints = constraints)
        else:
            # Bounds for the weights (between 0 and 1)
            bounds = [(0, 1)] * n_assets
            result = minimize(lambda w: - self.__calculate_sharpe_ratio(w, mu, mu_rf, Sigma), initial_weights, bounds = bounds, constraints = constraints)

        return {"Weights": dict(zip(self.portfolio_IDs, result.x)), "Sharpe_ratio": - result.fun}  # Optimal weights

    def running_optimal_sharpe_portfolio(self, window_size: int, full_frontier: bool):
        """Find the optimal mean-variance portfolio that maximises the sharpe ratio.
        window_size: size of the sliding window in months.
        full_frontier: If true, return portfolios where full frontier is allowed."""

        time_periods = self.portfolio_return_EUR["TIME_PERIOD"]

        assets = list(self.portfolio_IDs)
        index_rf = assets.index('{"RF","EU"}')

        # Getting returns. Order is portfolio_IDs. Not using RF_EUR
        returns = self.portfolio_return_EUR[assets].to_numpy()
        # Looping across window and finding optimal
        optimized_weights = {}
        for i in range(0, len(time_periods)):
            if i < window_size:
                continue
            else:
                rolling_returns = returns.copy()[i - window_size:i]

                #Optimize Sharpe
                mu = np.mean(rolling_returns, axis=0)
                mu_rf = mu[index_rf]
                Sigma = np.cov(rolling_returns, rowvar=False)
                optimal_values = self.__optimize_portfolio_sharpe(mu_rf, mu, Sigma, full_frontier)

                time_period = time_periods[i]
                inner_dict = { "mu": dict(zip(self.portfolio_IDs, mu)), "Weights": optimal_values["Weights"],"Sharpe_ratio": optimal_values["Sharpe_ratio"]}
                optimized_weights[str(time_period)] = inner_dict
        return optimized_weights



