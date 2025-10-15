import math
import polars as pl
import numpy as np
from scipy.optimize import minimize


class MeanVarianceStrategy:
    def __init__(self, fama_french_data: pl.DataFrame, portfolio_names: list[str]):
        __fama_french_data = fama_french_data.with_columns(
            Excess_return_US = pl.when(pl.col("Region") == "US").then(pl.col("Return") - pl.col("RF_USD")).otherwise(None)
            ).with_columns(Excess_return_EU = pl.when(pl.col("Region") == "EU").then(pl.col("Return_EUR") - pl.col("RF_EUR")).otherwise(None))
        __fama_french_data = __fama_french_data.with_columns(
            Excess_return_EUR = (pl.when(pl.col("Region") == "US").then((pl.col("Excess_return_US") + 100) * pl.col("Monthly_Exchange_Return") - 100).otherwise(pl.col("Excess_return_EU"))) / 100
        )
        self.portfolio_excess_return_EUR = __fama_french_data.filter(
            pl.col("Portfolio").is_in(portfolio_names),
        ).select(
            ["TIME_PERIOD", "Portfolio", "Region", "Excess_return_EUR"]
        ).pivot(index = "TIME_PERIOD", values = "Excess_return_EUR", columns = ["Portfolio", "Region"]
        ).sort("TIME_PERIOD", descending=False)

        self.portfolio_names = portfolio_names

    def __compute_portfolio_variance(self, w: np.ndarray[float], Sigma: np.ndarray) -> float:
        """Compute covariance matrix for a portfolio with weights (w) and covariance matrix (Sigma) for the assets."""
        return np.dot(w.T, np.dot(Sigma, w))

    # A function to compute the expected portfolio return
    def __compute_portfolio_return(self, w: np.ndarray[float], mu: np.ndarray[float]) -> float:
        """Compute expected surplus return for assets.
        w: weights.
        mu: Expected surplus return for assets."""
        return np.dot(w, mu)

    def __calculate_sharpe_ratio(self, w: np.ndarray[float], mu: np.ndarray[float], Sigma: np.ndarray) -> float:
        """Calculate sharpe ratio for a portfolio with weights (w) and covariance matrix (Sigma) for the assets."""
        return self.__compute_portfolio_return(w, mu) / math.sqrt(self.__compute_portfolio_variance(w, Sigma))

    # Optimization to maximize Sharpe ratio
    def __optimize_portfolio_sharpe(self, mu: np.ndarray[float], Sigma: np.ndarray, portfolio_ids: list ):

        # Initialize with equal weights
        n_assets = len(portfolio_ids)
        initial_weights = np.ones(n_assets) / n_assets

        # Bounds for the weights (between 0 and 1)
        bounds = [(0, 1)] * n_assets

        # Constraint: sum of weights must be 1
        constraints = ({'type': 'eq', 'fun': lambda w: np.sum(w) - 1})

        # Optimization function: maximise Sharpe Ratio
        result = minimize(lambda w: - self.__calculate_sharpe_ratio(w, mu, Sigma), initial_weights, bounds=bounds, constraints=constraints)

        return {"Weights": dict(zip(portfolio_ids, result.x)), "Sharpe_ratio": - result.fun}  # Optimal weights

    def running_optimal_sharpe_portfolio(self, window_size):
        optimized_weights = {}
        #pl.DataFrame({"TIME_PERIOD": self.portfolio_excess_return_EUR["TIME_PERIOD"], "Weights": [{}] * 500, "Sharpe_ratio": [None] * 500} )
        time_periods = self.portfolio_excess_return_EUR["TIME_PERIOD"]
        portfolio_ids = self.portfolio_excess_return_EUR.select(pl.exclude("TIME_PERIOD")).columns
        for i in range(0, len(time_periods)):
            if i < window_size:
                continue
            else:
                # range(window_size, len(self.portfolio_excess_return_EUR) + 1):
                excess_returns = self.portfolio_excess_return_EUR[portfolio_ids].to_numpy()
                rolling_returns = excess_returns[i - window_size:i]

                #Optimize Sharpe
                mu = np.mean(rolling_returns, axis=0)
                Sigma = np.cov(rolling_returns, rowvar=False)
                optimal_values = self.__optimize_portfolio_sharpe(mu, Sigma, portfolio_ids)

                inner_dict = { "mu": dict(zip(portfolio_ids, mu)), "Weights": optimal_values["Weights"],"Sharpe_ratio": optimal_values["Sharpe_ratio"]}
                optimized_weights[str(time_periods[i])] = inner_dict
        return optimized_weights



