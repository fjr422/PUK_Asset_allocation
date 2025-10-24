import polars as pl
import plotly.express as px

import data

# Paths
active_reserve_strategy_paths = data.ActiveReserveStrategyAnalysisPaths()
portfolio_analysis_paths = data.PortfolioAnalysisPaths()
# Input
cppi_terminal_values = pl.read_csv(active_reserve_strategy_paths.cppi_terminal_values_path, try_parse_dates=True)
cppi_terminal_values_target_common = pl.read_csv(active_reserve_strategy_paths.cppi_terminal_values_path_target, try_parse_dates=True)
tie_in_terminal_values = pl.read_csv(active_reserve_strategy_paths.tie_in_trigger_terminal_values_path, try_parse_dates=True)

# long_values = pl.read_csv(portfolio_analysis_paths.optimal_long_portfolio_strategies_returns_path).with_columns(
#     pl.lit("Long assets").alias("Universe")
# )
# short_values = pl.read_csv(portfolio_analysis_paths.optimal_short_portfolio_strategies_returns_path).with_columns(
#     pl.lit("Short assets").alias("Universe")
# )
# chosen_assets_values = pl.read_csv(portfolio_analysis_paths.optimal_chosen_assets_portfolio_strategies_returns_path).with_columns(
#     pl.lit("Chosen assets").alias("Universe")
# )
#
# all_values = pl.concat([long_values, short_values, chosen_assets_values])
# px.line(all_values, x = "TIME_PERIOD", y = "Value", color = "Strategy ID", facet_col = "Universe", title="Values").show()
#
# long_weights = pl.read_csv(portfolio_analysis_paths.optimal_portfolio_strategies_long).with_columns(
#     pl.lit("Long assets").alias("Universe")
# )
# short_weights = pl.read_csv(portfolio_analysis_paths.optimal_portfolio_strategies_short).with_columns(
#     pl.lit("Short assets").alias("Universe")
# )
# chosen_weights = pl.read_csv(portfolio_analysis_paths.optimal_portfolio_strategies_chosen_assets).with_columns(
#     pl.lit("Chosen assets").alias("Universe")
# )
# all_weights = pl.concat([long_weights, short_weights, chosen_weights])
#
# px.line(all_weights, x = "TIME_PERIOD", y = "Weight", color = "Portfolio", facet_col = "Universe", facet_row="Portfolio strategy", title="Weights").show()



cppi_group_m = cppi_terminal_values.filter(
    pl.col("L_trigger") == pl.col("L_trigger").min()
).with_columns(
    (pl.col("Value") / pl.col("Initial guarantee")).alias("Terminal to initial")
).group_by(
    "m"
).agg(
    pl.col("Terminal to initial").mean().alias("Avg Terminal to initial"),
    pl.col("Terminal to initial").var().sqrt().alias("Sd Terminal to initial"),
    pl.col("Value").mean().alias("Avg value")
).with_columns(
    (pl.col("Avg Terminal to initial") / pl.col("Avg Terminal to initial")).alias("Volatility adjusted Terminal to initial")
).sort("m")

cppi_group_m_target = cppi_terminal_values_target_common.filter(
    pl.col("L_trigger") == pl.col("L_trigger").min()
).with_columns(
    (pl.col("Value") / pl.col("Initial guarantee")).alias("Terminal to initial")
).group_by(
    "m"
).agg(
    pl.col("Terminal to initial").mean().alias("Avg Terminal to initial"),
    pl.col("Terminal to initial").var().sqrt().alias("Sd Terminal to initial"),
    pl.col("Value").mean().alias("Avg value")
).with_columns(
    (pl.col("Avg Terminal to initial") / pl.col("Avg Terminal to initial")).alias("Volatility adjusted Terminal to initial")
).sort("m")

px.line(cppi_group_m, x = "m", y = "Avg value", title="CPPI m", subtitle="Avg value").show()
px.line(cppi_group_m_target, x = "m", y = "Avg value", title="CPPI m current target", subtitle="Avg value").show()
# px.line(cppi_group_m, x = "m", y = "Sd value", title="CPPI m", subtitle="Sd Terminal to initial").show()
# px.line(cppi_group_m, x = "m", y = "Volatility adjusted", title="CPPI m", subtitle="Volatility adjusted").show()


cppi_group_trigger = cppi_terminal_values.filter(
    pl.col("m").round(1) == 3.0
).with_columns(
    (pl.col("Value") / pl.col("Initial guarantee")).alias("Value")
).group_by(
    "L_trigger"
).agg(
    pl.col("Value").mean().alias("Avg value"),
    pl.col("Value").var().sqrt().alias("Sd value"),
).with_columns(
    (pl.col("Avg value") / pl.col("Sd value")).alias("Volatility adjusted")
).sort("L_trigger")

px.line(cppi_group_trigger, x = "L_trigger", y = "Avg value", title="CPPI trigger", subtitle="Avg value").show()
px.line(cppi_group_trigger, x = "L_trigger", y = "Sd value", title="CPPI trigger", subtitle="Sd value").show()
px.line(cppi_group_trigger, x = "L_trigger", y = "Volatility adjusted", title="CPPI trigger", subtitle="Volatility adjusted").show()


tie_in_terminal_values_group = tie_in_terminal_values.with_columns(
    (pl.col("Value") / pl.col("Initial guarantee")).alias("Value")
).group_by(
    "L_trigger"
).agg(
    pl.col("Value").mean().alias("Avg value"),
    pl.col("Value").var().sqrt().alias("Sd value"),
).with_columns(
    (pl.col("Avg value") / pl.col("Sd value")).alias("Volatility adjusted")
).sort("L_trigger")

px.line(tie_in_terminal_values_group, x = "L_trigger", y = "Avg value", title="Tie in trigger", subtitle="Avg value").show()
px.line(tie_in_terminal_values_group, x = "L_trigger", y = "Sd value", title="Tie in trigger", subtitle="Sd value").show()
px.line(tie_in_terminal_values_group, x = "L_trigger", y = "Volatility adjusted", title="Tie in trigger", subtitle="Volatility adjusted").show()

