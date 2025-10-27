
# Data-files from Python
optimal__chosen_assets_portfolio_strategies_values <- read.csv("Data/Active_portfolio/Output/optimal_chosen_assets_portfolio_strategies_values.csv") %>%
  mutate(Universe = "Chosen Assets")
optimal_long_portfolio_strategies_values <- read.csv("Data/Active_portfolio/Output/optimal_long_portfolio_strategies_values.csv") %>% 
  mutate(Universe = "Long Assets")
optimal_short_portfolio_strategies_values <- read.csv("Data/Active_portfolio/Output/optimal_short_portfolio_strategies_values.csv") %>%
  mutate(Universe = "Short Assets")

tdf_returns <- read.csv("Data/Active_portfolio/Output/tdf_returns.csv")
tdf_weights <- read.csv("Data/Active_portfolio/Output/tdf_weights.csv")

All_portfolio_strategies_values <- rbind(optimal_long_portfolio_strategies_values,
                                         optimal_short_portfolio_strategies_values,
                                         optimal__chosen_assets_portfolio_strategies_values)



#Weights


Long_weights <- read.csv("Data/Active_portfolio/Input/portfolio_strategies_long.csv") %>%
  mutate(Universe = "Long Assets")

Short_weights <- read.csv("Data/Active_portfolio/Input/portfolio_strategies_short.csv") %>%
  mutate(Universe = "Short Assets")

Chosen_weights <- read.csv("Data/Active_portfolio/Input/portfolio_strategies_chosen_assets.csv") %>%
  mutate(Universe = "Chosen Assets")


All_weights <- rbind(Long_weights, Short_weights, Chosen_weights)

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
         '{"RF","EU"}' = 'European Risk-Free'
         
  )
}

US_EU_PF_colors <- scale_color_manual(
  values = c(
    "European Market" = "#08519C",
    "European Tech Stocks" = "#3182BD",
    "European MOM" = "#6BAED6",
    "European Small Cap Stocks" = "#9ECAE1",
    "European SMB" = "#C6DBEF",
    "US Market" = "#B2182B",
    "US Tech Stocks" = "#D6604D",
    "US MOM" = "#F4A582",
    "US Small Cap Stocks" = "#FDDBC7",
    "US SMB" = "#FEE0D2",
    "Risk Parity" = "#238B45",                
    "Global Minimum Variance portfolio" = "#2CA25F",  
    "Sharpe-portfolio" = "#A1D99B",           
    "Maximal historical return" = "#C7E9C0",  
    "European Risk-Free" = "#AAAAAA"
  )
)

pf_levels <- c("Global Minimum Variance portfolio",  
               "Maximal historical return",
               "Sharpe-portfolio",
               "Risk Parity", 
               "US Market",
               "US Tech Stocks",
               "US MOM",
               "US Small Cap Stocks",
               "US SMB",
               "European Market",
               "European Tech Stocks",
               "European MOM",
               "European Small Cap Stocks",
               "European SMB",
               "European Risk-Free")          
               
  

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

asset_pfs <- c(
  "European Market",
  "European Tech Stocks",
  "European MOM",
  "European Small Cap Stocks",
  "European SMB",
  "US Market",
  "US Tech Stocks",
  "US MOM",
  "US Small Cap Stocks",
  "US SMB"
)

optimal__chosen_assets_portfolio_strategies_values$Strategy.ID %>% unique()


optimal__chosen_assets_portfolio_strategies_values %>%
  mutate(Strategy.ID = factor(plot_pf_names(Strategy.ID), levels = pf_levels),                              ,
         'Region' = sapply(Strategy.ID, region_pf_names)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Strategy.ID)) +
  geom_line(size = .8) +
  labs(title = "Out-of-Sample Returns of Long Portfolio Strategies",
       x = "Time Period",
       y = "Return",
       color = "Portfolio Strategy") +
  US_EU_PF_colors + theme_bw()

optimal_short_portfolio_strategies_values$Strategy.ID %>% unique()

optimal_short_portfolio_strategies_values %>%
  mutate(Strategy.ID = factor(plot_pf_names(Strategy.ID), levels = pf_levels),
         'Region' = sapply(Strategy.ID, region_pf_names)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Strategy.ID)) +
  geom_line(size = 1) +
  labs(title = "Out-of-Sample Returns of Short Portfolio Strategies",
       x = "Time Period",
       y = "Return",
       color = "Portfolio Strategy") + 
  US_EU_PF_colors + theme_bw()


AllStrategies_OOS <- All_portfolio_strategies_values %>% mutate(Strategy.ID = factor(plot_pf_names(Strategy.ID), levels = pf_levels),
                                           'Region' = sapply(Strategy.ID, region_pf_names)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Strategy.ID)) +
  geom_line(aes(alpha = Strategy.ID %in% asset_pfs), 
            size = 0.6) +
  scale_alpha_manual(values = c("TRUE" = 0.25, "FALSE" = 1), guide = "none") + 
  labs(title = "Out-of-Sample Returns of Portfolio Strategies",
       x = "Date",
       y = "Value",
       color = "Portfolio Strategy") + 
  facet_wrap(~Universe) +
  US_EU_PF_colors + theme_bw()

saveFig(AllStrategies_OOS, "R/Output/AllStrategies_OOS.pdf", 12, 6)


AllStrategies_W_OOS <- All_weights %>% mutate(Portfolio.strategy = factor(plot_pf_names(Portfolio.strategy), levels = pf_levels),
                                              Portfolio = factor(plot_pf_names(Portfolio), levels = pf_levels)) %>%
  filter(Portfolio.strategy %in% c('Global Minimum Variance portfolio',
                                   'Risk Parity',
                                   'Sharpe-portfolio',
                                   'Maximal historical return')) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Weight, color = Portfolio)) +
  geom_line(size = .7, alpha = .7) +
  labs(title = "Out-of-Sample Returns of Portfolio Strategies",
       x = "Date",
       y = "Weigths",
       color = "Portfolio Strategy") + 
  facet_grid(rows = vars(Universe), cols = vars(Portfolio.strategy)) +
  US_EU_PF_colors + theme_bw()


saveFig(AllStrategies_W_OOS, "R/Output/AllStrategies_W_OOS.pdf", 11, 6)





#SPOT RATES

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

Plot_Priceof100ZCB <- a %>% filter(TIME_TO_MATURITY == 120) %>% 
  ggplot(aes(x = as.Date(TIME_PERIOD), y = 100*ZCB_price)) +
  geom_line(size = .5) +
  labs(title = "Prices of 100 10-Year Maturity ZCBs over Time",
       x = "Time Period",
       y = "Price of 100 10-year ZCB") +
  geom_abline(slope = 0, intercept = 100/125*100, linetype = "dashed", color = "red") +
  geom_abline(slope = 0, intercept = 100/130*100, linetype = "dashed", color = "blue") +
  theme_bw()

saveFig(Plot_Priceof100ZCB, "R/Output/Plot_Priceof100ZCB.pdf", 8, 5)


Plot_ReturnsOfLongOnly <- optimal_long_portfolio_strategies_values %>%
  filter(!(Strategy.ID %in% c('Global Minimum Variance portfolio',
                                   'Risk Parity',
                                   'Sharpe-portfolio',
                              'Maximal historical return'))) %>% 
  mutate(Strategy.ID = factor(plot_pf_names(Strategy.ID), levels = pf_levels),
         'Region' = sapply(Strategy.ID, region_pf_names)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Strategy.ID)) +
  geom_line(size = .6) +
  labs(title = "Historic returns of the Long Portfolios",
       x = "Time Period",
       y = "Portfolio Value",
       color = "Portfolio") +
 US_EU_PF_colors + theme_bw()

saveFig(Plot_ReturnsOfLongOnly, "R/Output/Plot_ReturnsOfLongOnly.pdf", 8, 5)


Plot_ReturnsOfShortAndMarket <- optimal_short_portfolio_strategies_values %>%
  filter(!(Strategy.ID %in% c('Global Minimum Variance portfolio',
                                 'Risk Parity',
                                 'Sharpe-portfolio',
                              'Maximal historical return'))) %>% 
  mutate(Strategy.ID = factor(plot_pf_names(Strategy.ID),levels = pf_levels),
         'Region' = sapply(Strategy.ID, region_pf_names)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Strategy.ID)) +
  geom_line(size = .6) +
  labs(title = "Historic returns of the Short Portfolios (incl. Market)",
       x = "Time Period",
       y = "Portfolio Value",
       color = "Portfolio Strategy") +
  US_EU_PF_colors + theme_bw()

saveFig(Plot_ReturnsOfShortAndMarket, "R/Output/Plot_ReturnsOfShortAndMarket.pdf", 8, 5)


