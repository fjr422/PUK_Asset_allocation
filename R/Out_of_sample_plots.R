
# Data-files from Python
optimal_portfolio_strategies_return <- read.csv("Data/Active_portfolio/Output/optimal_portfolio_strategies_return.csv")
optimal_portfolio_strategies_values <- read.csv("Data/Active_portfolio/Output/optimal_portfolio_strategies_values.csv")

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


optimal_portfolio_strategies_return %>%
  mutate(Portfolio.name = plot_pf_names(Portfolio.name),
         'Region' = sapply(Portfolio.name, region_pf_names)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Portfolio.name, linetype = Region)) +
  geom_line(size = .8) +
  labs(title = "Out-of-Sample Returns of Portfolio Strategies",
       x = "Time Period",
       y = "Return",
       color = "Portfolio Strategy") +
  scale_linetype_manual(values = c("EU" = "dashed",
                                   "US" = "longdash",
                                   "None" = "solid")) + 
  guides(linetype = FALSE) + theme_bw()

optimal_portfolio_strategies_values %>%
  mutate(Portfolio.name = plot_pf_names(Portfolio.name),
         'Region' = sapply(Portfolio.name, region_pf_names)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Portfolio.name, linetype = Region)) +
  geom_line(size = .8) +
  labs(title = "Out-of-Sample Returns of Portfolio Strategies",
       x = "Time Period",
       y = "Return",
       color = "Portfolio Strategy") +
  scale_linetype_manual(values = c("EU" = "dashed",
                                   "US" = "longdash",
                                   "None" = "solid")) + 
  guides(linetype = FALSE) + theme_bw()


spot_rates <- read.csv("Data/Input/spot_rates.csv")

a <- spot_rates %>% 
  mutate(spot = BETA0 + BETA1 * ( (1 - exp(-(TIME_TO_MATURITY/12)/TAU1) ) / ((TIME_TO_MATURITY/12)/TAU1) ) + 
                        BETA2 * ( (1 - exp(-(TIME_TO_MATURITY/12)/TAU1) ) / ((TIME_TO_MATURITY/12)/TAU1) - 
                                     exp(-(TIME_TO_MATURITY/12)/TAU1) ) + 
                        BETA3 * ( (1 - exp(-(TIME_TO_MATURITY/12)/TAU2) ) / ((TIME_TO_MATURITY/12)/TAU2) - 
                                     exp(-(TIME_TO_MATURITY/12)/TAU2)) ,
         ZCB_price = exp(-spot/100 * (TIME_TO_MATURITY/12))
         )





