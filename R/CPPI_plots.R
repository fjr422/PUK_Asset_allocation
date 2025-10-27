# Active_Strategy_Reserve_Analysis in python should run before


# Baseline (Current Tie-In):
Current_TieIn_Terminal <- read.csv("Data/Active_reserve_strategy/Output/current_tie_in_EU_terminal_values.csv")
Current_TieIn_Market <- read.csv("Data/Active_reserve_strategy/Output/current_tie_in_EU_analysis_Market.csv") %>% 
  group_by(Strategy.ID, TIME_PERIOD) %>% mutate(W = sum(Value)) %>% ungroup()
                                                

#Histogram of Terminal W
Plot_CurrentTerminalW <- Current_TieIn_Terminal %>% ggplot(aes(x = Value)) +
  geom_histogram(bins = 15, fill = "gray77", color = "black") +
  labs(title = "Current Tie-In System - Terminal Values",
       x = "Terminal Value",
       y = "Frequency") +
  geom_vline(aes(xintercept = mean(Value)),
             color = "blue", linetype = "dashed", size = .7) +
  theme_bw()



saveFig(Plot_CurrentTerminalW,"R/Output/Current_TieIn_Terminal_Values.pdf", 8, 5)

#Histogram of Terminal W over Initial Guarantee
Plot_CurrentTerminalW_over_IG <- Current_TieIn_Terminal %>% mutate(TermW_over_InitG = (Value - Initial.guarantee)/Initial.guarantee) %>%
  ggplot(aes(x = TermW_over_InitG)) +
  geom_histogram(bins = 15, fill = "gray77", color = "black") +
  labs(title = "Current Tie-In System - Terminal Values over Initial Guarantee",
       x = "Excess Return over Initial Guarantee",
       y = "Frequency") +
  scale_x_continuous(labels = scales::percent) +
  geom_vline(aes(xintercept = mean(TermW_over_InitG)),
             color = "blue", linetype = "dashed", size = .7) +
  theme_bw()

saveFig(Plot_CurrentTerminalW_over_IG,"R/Output/Current_TieIn_Terminal_Values_over_IG.pdf", 8, 5)

#TDF values over time
Current_TieIn_Market %>% group_by(Strategy.ID,TIME_PERIOD) %>% summarize(Value = sum(Value)) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Value, color = Strategy.ID)) +
  geom_line(size = .5) + 
  labs(title = "Current Tie-In System - TDF Values Over Time",
       x = "Date",
       y = "TDF value",
       color = "Portfolio Strategy") +
  theme_bw() + guides(color = FALSE)

#Initial Guarantee over time (Current Tie-in)
tdf_returns %>% filter(TIME_TO_MATURITY == 120) %>% mutate(IG = 80/ZC) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = IG)) +
  geom_line(size = .7) +
  labs(title = "Initial Guarantee over Time",
       x = "Date",
       y = "Initial Guarantee") +
  theme_bw()


# New Tie-In Strategy (Our Active PF)
tie_in_trigger_125 <- read.csv("Data/Active_reserve_strategy/Output/tie_in_trigger_terminal_values1.25.csv") %>% 
  mutate(L_trigger = round(L_trigger,3),
         L_target = round(L_target,3))
tie_in_trigger_130 <- read.csv("Data/Active_reserve_strategy/Output/tie_in_trigger_terminal_values1.3.csv") %>% 
  mutate(L_trigger = round(L_trigger,3),
         L_target = round(L_target,3))

tie_in_trigger_135 <- read.csv("Data/Active_reserve_strategy/Output/tie_in_trigger_terminal_values1.35.csv") %>% 
  mutate(L_trigger = round(L_trigger,3),
         L_target = round(L_target,3))
tie_in_trigger_140 <- read.csv("Data/Active_reserve_strategy/Output/tie_in_trigger_terminal_values1.4.csv") %>% 
  mutate(L_trigger = round(L_trigger,3),
         L_target = round(L_target,3))


tie_in_trigger_125 %>% filter(L_trigger == 1.300) %>%
  ggplot(aes(x = Value)) + 
  geom_histogram(fill = "gray77", color = "black", bins = 15) +
  labs(title = "Tie-In Strategy (L_trigger = 1.3) - Terminal Values",
       x = "Terminal Value",
       y = "Frequency") +
  theme_bw()


TI_Trigger_Target_analysis <- rbind(tie_in_trigger_125, tie_in_trigger_130, tie_in_trigger_135, tie_in_trigger_140) %>% 
  mutate(trigger_over_target = L_trigger - L_target) %>% 
  filter(round(trigger_over_target,3) %in% c(0.050,0.100,0.150,0.200)) %>%
  mutate(trigger_over_target = as.factor(round(trigger_over_target,3))) %>%
  ggplot(aes(x = Value, fill = factor(L_target))) +
  geom_histogram(color = "black", bins = 15) +
  facet_grid(rows = vars(L_target), cols = vars(trigger_over_target)) +
  labs(title = "Tie-In Strategy - Terminal Values for Different Trigger Levels",
       x = "Terminal Value",
       y = "Frequency") +
  theme_bw() + guides(fill = FALSE)



#CPPI Strategy (Our Active PF)
CPPI_terminal_values125 <- read.csv("Data/Active_reserve_strategy/Output/cppi_terminal_values1.25.csv") %>%
  mutate(trigger_over_target = L_trigger - L_target) %>%
  mutate(m = factor(round(m,3)),
         L_target = factor(round(L_target,3)),
         L_trigger = factor(round(L_trigger,3)),
         trigger_over_target = factor(round(trigger_over_target,3)))
CPPI_terminal_values130 <- read.csv("Data/Active_reserve_strategy/Output/cppi_terminal_values1.3.csv") %>%
  mutate(trigger_over_target = L_trigger - L_target) %>%
  mutate(m = factor(round(m,3)),
         L_target = factor(round(L_target,3)),
         L_trigger = factor(round(L_trigger,3)),
         trigger_over_target = factor(round(trigger_over_target,3)))
CPPI_terminal_values135 <- read.csv("Data/Active_reserve_strategy/Output/cppi_terminal_values1.35.csv") %>%
  mutate(trigger_over_target = L_trigger - L_target) %>%
  mutate(m = factor(round(m,3)),
         L_target = factor(round(L_target,3)),
         L_trigger = factor(round(L_trigger,3)),
         trigger_over_target = factor(round(trigger_over_target,3)))
CPPI_terminal_values140 <- read.csv("Data/Active_reserve_strategy/Output/cppi_terminal_values1.4.csv") %>%
  mutate(trigger_over_target = L_trigger - L_target) %>%
  mutate(m = factor(round(m,3)),
         L_target = factor(round(L_target,3)),
         L_trigger = factor(round(L_trigger,3)),
         trigger_over_target = factor(round(trigger_over_target,3)))

CPPI_analysis <- rbind(CPPI_terminal_values125, CPPI_terminal_values130,
                       CPPI_terminal_values135, CPPI_terminal_values140)


CPPI_analysis %>%
  filter(trigger_over_target %in% c(0.050, 0.100, 0.150, 0.200),
         m %in% c(1,2,3,4,5)) %>%
  ggplot(aes(x = Value, color = factor(m))) +
  geom_density(size = .7, alpha = 0.2, position = "identity") +
  facet_grid(rows = vars(L_target), cols = vars(trigger_over_target)) +
  labs(
    title = "CPPI Strategy – Terminal Values for Different Multipliers",
    x = "Terminal Value",
    y = "Frequency",
    color = "Multiplier (m)"
  ) +
  theme_bw()










  




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
  



