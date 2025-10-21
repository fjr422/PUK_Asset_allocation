
optimal_portfolio_strategies_return <- read.csv("Data/Active_portfolio/Output/optimal_portfolio_strategies_return.csv")

optimal_portfolio_strategies_return %>%
  mutate(Portfolio.name = 
           recode(Portfolio.name,
                  '{"Market_Return","EU"}' = 'European Market',
                  '{"Market_Return","US"}' = 'US Market',
                  '{"Small Cap","EU"}' = 'European Small Cap Stocks',
                  '{"Small Cap","US"}' = 'US Small Cap Stocks',
                  '{"Tech Stocks","EU"}' = 'European Tech Stocks',
                  '{"Tech Stocks","US"}' = 'US Tech Stocks'
           ),
         'Region' = ifelse(Portfolio.name %in% c('European Market',
                                                 'European Small Cap Stocks',
                                                 'European Tech Stocks'), 
                         'EU', 
                         ifelse(Portfolio.name %in% c('US Market',
                                                      'US Small Cap Stocks',
                                                      'US Tech Stocks'), 'US','None')
                         )) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Portfolio.name, linetype = Region)) +
  geom_line(size = .8) +
  labs(title = "Out-of-Sample Returns of Portfolio Strategies",
       x = "Time Period",
       y = "Return",
       color = "Portfolio Strategy") +
  scale_linetype_manual(values = c("EU" = "twodash",
                                   "US" = "longdash",
                                   "None" = "solid")) + 
  guides(linetype = FALSE) + theme_bw()
                                    


optimal_portfolio_strategies_return$Portfolio.name %>% unique()
