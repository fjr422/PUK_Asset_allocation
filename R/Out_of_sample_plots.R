
# Data-files from Python
optimal__chosen_assets_portfolio_strategies_values <- read.csv("Data/Active_portfolio/Output/optimal_chosen_assets_portfolio_strategies_values.csv")
optimal_long_portfolio_strategies_values <- read.csv("Data/Active_portfolio/Output/optimal_long_portfolio_strategies_values.csv")
optimal_short_portfolio_strategies_values <- read.csv("Data/Active_portfolio/Output/optimal_short_portfolio_strategies_values.csv")

tdf_returns <- read.csv("Data/Active_portfolio/Output/tdf_returns.csv")
tdf_weights <- read.csv("Data/Active_portfolio/Output/tdf_weights.csv")

# Recode PF names, to be descriptive for the report
plot_pf_names <- function(name){
  recode(name,
         '{"Market_Return","EU"}' = 'European Market',
         '{"Market_Return","US"}' = 'US Market',
         '{"Small Cap","EU"}' = 'European Small Cap Stocks',
         '{"Small Cap","US"}' = 'US Small Cap Stocks',
         '{"Tech Stocks","EU"}' = 'European Tech Stocks',
         '{"Tech Stocks","US"}' = 'US Tech Stocks',
         '{"SMB","EU"}' = 'European SMB',
         '{"SMB","US"}' = 'US SMB',
         '{"MOM","EU"}' = 'European MOM',
         '{"MOM","US"}' = 'US MOM',
         
  )
}

US_EU_PF_colors <- scale_color_manual(
  values = c(
    "European Market" = "#08519C",
    "European Tech Stocks" = "#3182BD",
    "European MOM" = "#6BAED6",
    "European Small Cap Stocks" = "#9ECAE1",
    "European SMB" = "#C6DBEF",
    "US Market" = "#99000D",
    "US Tech Stocks" = "#CB181D",
    "US MOM" = "#EF3B2C",
    "US Small Cap Stocks" = "#FB6A4A",
    "US SMB" = "#FBB4AE",
    "Risk Parity" = "#008000",
    "Global Minimum Variance portfolio" = "#00DD00",
    "Sharpe-portfolio" = "#00FF00",
    "Maximal historical return" = "#B8FFB8"
  )
)

# Define region based on portfolio name to use in plots
region_pf_names <- function(name){
  if (name %in% c('European Market',
                  'European Small Cap Stocks',
                  'European Tech Stocks',
                  'European SMB',
                  'European MOM')) {
    return('EU')
  } else if (name %in% c('US Market',
                         'US Small Cap Stocks',
                         'US Tech Stocks',
                         'US SMB',
                         'US MOM')) {
    return('US')
  } else {
    return('None')
  }
}

optimal__chosen_assets_portfolio_strategies_values$Strategy.ID %>% unique()


optimal__chosen_assets_portfolio_strategies_values %>%
  mutate(Strategy.ID = plot_pf_names(Strategy.ID),
         'Region' = sapply(Strategy.ID, region_pf_names)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Strategy.ID)) +
  geom_line(size = .8) +
  labs(title = "Out-of-Sample Returns of Portfolio Strategies",
       x = "Time Period",
       y = "Return",
       color = "Portfolio Strategy") +
  US_EU_PF_colors + theme_bw()

optimal_short_portfolio_strategies_values %>%
  mutate(Strategy.ID = plot_pf_names(Strategy.ID),
         'Region' = sapply(Strategy.ID, region_pf_names)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Strategy.ID)) +
  geom_line(size = 1) +
  labs(title = "Out-of-Sample Returns of Portfolio Strategies",
       x = "Time Period",
       y = "Return",
       color = "Portfolio Strategy") + 
  US_EU_PF_colors + theme_bw()


spot_rates <- read.csv("Data/Input/spot_rates.csv")

a <- spot_rates %>% 
  mutate(spot = BETA0 + BETA1 * ( (1 - exp(-(TIME_TO_MATURITY/12)/TAU1) ) / ((TIME_TO_MATURITY/12)/TAU1) ) + 
                        BETA2 * ( (1 - exp(-(TIME_TO_MATURITY/12)/TAU1) ) / ((TIME_TO_MATURITY/12)/TAU1) - 
                                     exp(-(TIME_TO_MATURITY/12)/TAU1) ) + 
                        BETA3 * ( (1 - exp(-(TIME_TO_MATURITY/12)/TAU2) ) / ((TIME_TO_MATURITY/12)/TAU2) - 
                                     exp(-(TIME_TO_MATURITY/12)/TAU2)) ,
         ZCB_price = exp(-spot/100 * (TIME_TO_MATURITY/12))
         )

a %>% ggplot(aes(x = TIME_TO_MATURITY/12, y = ZCB_price, color = TIME_PERIOD)) +
  geom_line() +
  labs(title = "Zero Coupon Bond Prices over Time to Maturity",
       x = "Time to Maturity (Months)",
       y = "ZCB Price",
       color = "Date") +
  xlim(10,0) + 
  theme_bw() + guides(color = FALSE)

a %>% filter(TIME_TO_MATURITY == 120) %>% 
  ggplot(aes(x = as.Date(TIME_PERIOD), y = 100*ZCB_price)) +
  geom_line(size = .5) +
  labs(title = "Zero Coupon Bond Prices with 10-Year Maturity over Time",
       x = "Time Period",
       y = "ZCB Price (10-Year Maturity)") +
  theme_bw()


Plot_ReturnsOfLongOnly <- optimal_long_portfolio_strategies_values %>%
  filter(!(Strategy.ID %in% c('Global Minimum Variance portfolio',
                                   'Risk Parity',
                                   'Sharpe-portfolio'))) %>% 
  mutate(Strategy.ID = plot_pf_names(Strategy.ID),
         'Region' = sapply(Strategy.ID, region_pf_names)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Strategy.ID)) +
  geom_line(size = .6) +
  labs(title = "Historic returns of the Long-Only Portfolios",
       x = "Time Period",
       y = "Portfolio Value",
       color = "Portfolio") +
 US_EU_PF_colors + theme_bw()

saveFig(Plot_ReturnsOfLongOnly, "R/Output/Plot_ReturnsOfLongOnly.pdf", 8, 5)


Plot_ReturnsOfShortAndMarket <- optimal_short_portfolio_strategies_values %>%
  filter(!(Strategy.ID %in% c('Global Minimum Variance portfolio',
                                 'Risk Parity',
                                 'Sharpe-portfolio'))) %>% 
  mutate(Strategy.ID = plot_pf_names(Strategy.ID),
         'Region' = sapply(Strategy.ID, region_pf_names)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Strategy.ID)) +
  geom_line(size = .6) +
  labs(title = "Historic returns of the Short Portfolios (incl. Market)",
       x = "Time Period",
       y = "Portfolio Value",
       color = "Portfolio Strategy") +
  US_EU_PF_colors + theme_bw()

saveFig(Plot_ReturnsOfShortAndMarket, "R/Output/Plot_ReturnsOfShortAndMarket.pdf", 8, 5)


