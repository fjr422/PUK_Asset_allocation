# Active_Strategy_Reserve_Analysis in python should run before

CPPI_terminal <- read.csv("Data/Active_reserve_strategy/Output/cppi_terminal_values.csv")
TI_terminal <- read.csv("Data/Active_reserve_strategy/Output/tie_in_trigger_terminal_values.csv")

CPPI_terminal %>% mutate(m = round(m,2)) %>% filter(m %in% c(1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5)) %>%
  ggplot(aes(x= as.factor(m), y = Value)) +
  geom_boxplot(fill = "gray77", color = "black") +
  labs(title = "Boxplot of Terminal CPPI Values for Different Multipliers",
       x = "CPPI Multiplier",
       y = "Terminal CPPI Value") +
  theme_bw()

#make boxplot for TI terminal values
TI_terminal %>% mutate(L_trigger = round(L_trigger,2)) %>% filter(L_trigger %in% c(1.3, 1.5, 1.7, 1.9, 2.1, 2.3, 2.5, 2.7, 2.9)) %>%
  ggplot(aes(x = as.factor(L_trigger), y = Value)) + 
  geom_boxplot(fill = "gray77", color = "black") + 
  labs(title = "Boxplot of Terminal TI Values for Different Trigger Levels",
       x = "Trigger Level",
       y = "Terminal TI Value") +
  theme_bw()
  


