import numpy as np
import polars as pl

# # Function to calculate normalized return (log return normalized to simple annualized return)
# def normalized_return(prices):
#     # Calculate log returns
#     log_returns = (prices / prices.shift(1)).log().drop_nulls()
#
#     # Annualized return (252 trading days assumed)
#     annualized_return = log_returns.mean() * 252
#     return annualized_return
#
# # Function to calculate price differentials and their standard deviation (sigma_P)
# def price_differentials_std(prices):
#     # Calculate price differentials
#     price_diff = prices.diff().drop_nulls()
#     return price_diff.std()
#
# # Function to compute Variability-Weighted Return (VWR)
# def variability_weighted_return(prices, sigma_max, tau):
#     # Calculate normalized return (R_norm)
#     R_norm = normalized_return(prices)
#
#     # Calculate standard deviation of price differentials (sigma_P)
#     sigma_P = price_differentials_std(prices)
#
#     # Compute the Variability-Weighted Return
#     VWR = R_norm * (1 - (sigma_P / sigma_max)**tau)
#
#     return VWR
#
# # Example usage with dummy data
# # Generate some sample price data for a stock (replace this with real data)
# dates = pl.date_range(pl.date(2023,1,1), pl.date(2023,12,31), "1d", eager=True)
#
# stock_prices = pl.DataFrame({
#     "date": dates,
#     "price": np.random.randn(dates.len()).cumsum() + 100
# })
#
# # Parameters for the investor
# sigma_max = 0.02  # Maximum acceptable standard deviation (set by the investor)
# tau = 2  # Tolerance level
#
# # Calculate VWR for the stock
# vwr = variability_weighted_return(stock_prices["price"], sigma_max, tau)
# print(f"Variability-Weighted Return (VWR): {vwr:.4f}")


# Weights
import numpy as np
import polars as pl

# Function to calculate normalized return (log return normalized to simple annualized return)
def normalized_return(prices):
    # Calculate log returns using vectorized operations
    log_returns = (prices / prices.shift(1)).log().drop_nulls()

    # Annualized return (252 trading days assumed)
    annualized_return = log_returns.mean() * 252  # 252 trading days in a year
    return annualized_return

# Function to calculate price differentials and their standard deviation (sigma_P)
def price_differentials_std(prices):
    # Calculate price differentials
    price_diff = prices.diff().drop_nulls()
    return price_diff.std()

# Function to compute the VWR for the portfolio of stocks
def portfolio_vwr(prices, weights, sigma_max, tau):
    # Calculate the log returns of each stock in the portfolio
    log_returns = [normalized_return(prices[col]) for col in prices.columns[1:]]  # exclude the 'date' column

    # Compute the weighted average of the returns
    portfolio_return = sum(w * r for w, r in zip(weights.values(), log_returns))

    # Calculate the price differentials of each stock
    price_diffs_std = [price_differentials_std(prices[col]) for col in prices.columns[1:]]

    # Compute the weighted average of the price standard deviations (sigma_P)
    portfolio_price_diff_std = sum(w * std for w, std in zip(weights.values(), price_diffs_std))

    # Calculate the Variability-Weighted Return (VWR) for the portfolio
    VWR = portfolio_return * (1 - (portfolio_price_diff_std / sigma_max) ** tau)

    return VWR

# Example usage with portfolio of stocks "A", "B", and "C"
# Generate some sample price data for each stock (replace this with real data)
dates = pl.date_range(pl.date(2023,1,1), pl.date(2023,12,31), "1d", eager=True)

# Simulating random stock prices for A, B, and C
stock_A_prices = np.random.randn(len(dates)).cumsum() + 100
stock_B_prices = np.random.randn(len(dates)).cumsum() + 200
stock_C_prices = np.random.randn(len(dates)).cumsum() + 150

# Creating the DataFrame for stock prices
portfolio_prices = pl.DataFrame({
    "date": dates,
    "A": stock_A_prices,
    "B": stock_B_prices,
    "C": stock_C_prices
})

# Parameters for the investor
sigma_max = 1  # Maximum acceptable standard deviation (set by the investor)
tau = 2  # Tolerance level

# Portfolio weights (example)
weights = {"A": 0.4, "B": 0.3, "C": 0.3}  # Portfolio weights for stocks A, B, C

# Calculate the VWR for the entire portfolio
vwr = portfolio_vwr(portfolio_prices, weights, sigma_max, tau)

print(f"Variability-Weighted Return (VWR) for the Portfolio: {vwr:.4f}")

