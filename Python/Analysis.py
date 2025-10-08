import polars as pl
import DataPaths

farma_french_paths = DataPaths.FarmaFrench()
print(farma_french_paths.american_6)
american_6 = pl.read_csv(farma_french_paths.american_6, separator=',', decimal_comma=False, has_header=True)

t = 1