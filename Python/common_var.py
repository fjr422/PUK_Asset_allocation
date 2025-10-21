import polars as pl
import pandas as pd

years_tdf = 10
tdf_end_in_months = 12 * years_tdf

def shift_date_by_months(date: pd.Timestamp, months: int):
    """Shift a date to the equivelant month end months later."""
    month_start = date - pd.offsets.MonthBegin()
    shift_date = month_start + pd.offsets.DateOffset(months=months)
    shift_date_month_end = shift_date + pd.offsets.MonthEnd()
    return shift_date_month_end

def shift_date_by_months_pl(date: pl.date, months: int):
    """Shift a date to the equivelant month end months later."""
    return date.dt.month_start().dt.offset_by(str(months) + "mo").dt.month_end()

assets_start_date_pd = pd.Timestamp(year = 2004, month = 8, day = 31)
assets_start_date_pl = pl.date(year = assets_start_date_pd.year, month = assets_start_date_pd.month, day = assets_start_date_pd.day)

portfolios_start_date_pd = pd.Timestamp(year = 2007, month = 8, day = 31)
portfolios_start_date_pl = pl.date(year = portfolios_start_date_pd.year, month = portfolios_start_date_pd.month, day = portfolios_start_date_pd.day)

first_tdf_pd = shift_date_by_months(portfolios_start_date_pd, tdf_end_in_months)
first_tdf_pl = pl.date(year = first_tdf_pd.year, month = first_tdf_pd.month, day = first_tdf_pd.day)

last_tdf_pd = pd.Timestamp(year = 2024, month = 12, day = 31)
last_tdf_pl = pl.date(year = last_tdf_pd.year, month = last_tdf_pd.month, day = last_tdf_pd.day)


# Portfolio strategy
l_trigger = 1.3
l_target = 1.25

