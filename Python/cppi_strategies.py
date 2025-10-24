import polars as pl
import plotly.express as px

import data

# Paths
active_reserve_strategy_paths = data.ActiveReserveStrategyAnalysisPaths()
portfolio_analysis_paths = data.PortfolioAnalysisPaths()
# Input
cppi_terminal_values = pl.scan_csv(active_reserve_strategy_paths.cppi_terminal_values_base_path + "*.csv", try_parse_dates=True).collect()
tie_in_terminal_values = pl.scan_csv(active_reserve_strategy_paths.tie_in_terminal_values_base_path + "*.csv", try_parse_dates=True).collect()

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
# px.line(all_values, x = "TIME_PERIOD", y = "Value", color = "Strategy ID", color = "Universe", title="Values").show()
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
# px.line(all_weights, x = "TIME_PERIOD", y = "Weight", color = "Portfolio", color = "Universe", facet_row="Portfolio strategy", title="Weights").show()

cppi_group_m = cppi_terminal_values.with_columns(
    (pl.col("Value") / pl.col("Initial guarantee")).alias("Terminal to initial")
).filter(
    pl.col("L_trigger") == pl.col("L_trigger").min().over(["L_target"])
).group_by(
    ["m", "L_target"]
).agg(
    pl.col("Terminal to initial").mean().alias("Avg Terminal to initial"),
    pl.col("Terminal to initial").var().sqrt().alias("Sd Terminal to initial"),
    pl.col("Value").mean().alias("Avg value")
).with_columns(
    (pl.col("Avg Terminal to initial") / pl.col("Sd Terminal to initial")).alias("Volatility adjusted Terminal to initial")
).sort(["L_target", "m"])

px.line(cppi_group_m, x = "m", y = "Avg Terminal to initial", title="CPPI m", subtitle="Avg value", color= "L_target").show()
px.line(cppi_group_m, x = "m", y = "Sd Terminal to initial", color= "L_target", title="CPPI m", subtitle="Sd Terminal to initial").show()
px.line(cppi_group_m, x = "m", y = "Volatility adjusted Terminal to initial", color= "L_target", title="CPPI m", subtitle="Volatility adjusted Terminal to initial").show()


cppi_group_trigger = cppi_terminal_values.filter(
    pl.col("m").round(1) == 3.0
).with_columns(
    (pl.col("Value") / pl.col("Initial guarantee")).alias("Terminal to initial")
).group_by(
    ["L_trigger", "L_target"]
).agg(
    pl.col("Terminal to initial").mean().alias("Avg Terminal to initial"),
    pl.col("Terminal to initial").var().sqrt().alias("Sd Terminal to initial"),
).with_columns(
    (pl.col("Avg Terminal to initial") / pl.col("Sd Terminal to initial")).alias("Volatility adjusted Terminal to initial")
).sort(["L_target", "L_trigger"])

px.line(cppi_group_trigger, x = "L_trigger", y = "Avg Terminal to initial", color="L_target", title="CPPI trigger", subtitle="Avg Terminal to initial").show()
px.line(cppi_group_trigger, x = "L_trigger", y = "Sd Terminal to initial", color="L_target",title="CPPI trigger", subtitle="Sd Terminal to initial").show()
px.line(cppi_group_trigger, x = "L_trigger", y = "Volatility adjusted Terminal to initial", color="L_target", title="CPPI trigger", subtitle="Volatility adjusted Terminal to initial").show()


tie_in_terminal_values_group = tie_in_terminal_values.with_columns(
    (pl.col("Value") / pl.col("Initial guarantee")).alias("Terminal to initial")
).group_by(
    ["L_trigger", "L_target"]
).agg(
    pl.col("Terminal to initial").mean().alias("Avg Terminal to initial"),
    pl.col("Terminal to initial").var().sqrt().alias("Sd Terminal to initial"),
    pl.col("Value").mean().alias("Avg value")
).with_columns(
    (pl.col("Avg Terminal to initial") / pl.col("Sd Terminal to initial")).alias("Volatility adjusted Terminal to initial")
).sort(["L_target", "L_trigger"])

px.line(tie_in_terminal_values_group, x = "L_trigger", y = "Avg Terminal to initial", color="L_target", title="Tie in trigger", subtitle="Avg Terminal to initial").show()
px.line(tie_in_terminal_values_group, x = "L_trigger", y = "Sd Terminal to initial", color="L_target", title="Tie in trigger", subtitle="Sd Terminal to initial").show()
px.line(tie_in_terminal_values_group, x = "L_trigger", y = "Volatility adjusted Terminal to initial", color="L_target", title="Tie in trigger", subtitle="Volatility Terminal to initial").show()

