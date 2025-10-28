
Current_Active <- FactorPortfolios %>% mutate(EU_EQ = (MKT_EU + RF_EU)) %>% 
  select(TIME_PERIOD, EU_EQ) %>% filter(TIME_PERIOD >= "2007-08-31", TIME_PERIOD <= "2024-12-31")
tdf_returns

# Data needed:

#Active_Asset: Return on EU Equity and return series from 1e)
#Reserve_Asset: Zero Coupon Bond prices



Current_TieIn_System <- function(L_trigger, L_target, T = 10) {
  initial <- 100
  n <- T * 12
  
  portfolios <- unique(tdf_returns$Portfolio)
  results_list <- list()
  
  t <- 0
  for (pf in portfolios) {
    t <- t + 1
    
    tdf <- tdf_returns %>% filter(Portfolio == pf)
    
    A <- R <- G <- L <- W <- numeric(n + 1)
    Date <- Current_Active$TIME_PERIOD[t:(n + t)]
    
    # Initial
    A[1] <- initial * (1 - initial / L_target)
    R[1] <- initial - A[1]
    G[1] <- R[1] / tdf$ZC[1]
    L[1] <- (A[1] + R[1]) / R[1]
    W[1] <- A[1] + R[1]
    
    #Each time step
    for (i in 1:n) {
      A[i + 1] <- (1 + Current_Active$EU_EQ[i + t] / 100) * A[i]
      R[i + 1] <- R[i] * (1 + tdf$Return[i + 1] / 100)
      
      W[i + 1] <- A[i + 1] + R[i + 1]
      L[i + 1] <- W[i + 1] / R[i + 1]
      G[i + 1] <- R[i + 1] / tdf$ZC[i + 1]
      
      #Trigger
      if (L[i + 1] > L_trigger/100) {
        A[i + 1] <- (1 - initial / L_target) * W[i + 1]
        R[i + 1] <- W[i + 1] - A[i + 1]
      }
    }
    
    results_list[[pf]] <- data.frame(
      Portfolio = pf,
      Date = as.Date(Date),
      A = A,
      R = R,
      G = G,
      L = L,
      W = W
    )
  }
  
  results_all <- dplyr::bind_rows(results_list)
  
  return(results_all)
}


Current_Baseline <- Current_TieIn_System(130,125)

# Value
Current_W_plot <- Current_Baseline %>% ggplot(aes(x = Date, y = W, color = Portfolio)) +
  geom_line() +
  labs(title = "Current System - TDF values Over Time",
       x = "Date",
       y = "Portfolio Value") + guides(color = FALSE) + theme_bw()

saveFig(
  Current_W_plot,
  "R/Output/Current_Baseline_Values.pdf", 8, 5
)

# Guarantees
Current_G_plot <- Current_Baseline %>% ggplot(aes(x = Date, y = G, color = Portfolio)) +
  geom_line() +
  labs(title = "Current System - TDF Guarantees Over Time",
       x = "Date",
       y = "Guarantees at Maturity") + guides(color = FALSE) + theme_bw()

saveFig(
  Current_G_plot,
  "R/Output/Current_Baseline_Guarantees.pdf", 8, 5
)
  


#rebalancing events
Current_Baseline %>% filter(L > 1.3) %>% group_by(Portfolio) %>% summarise(n = n()) %>% 
  ggplot(aes(x = Portfolio, y = n)) + geom_col() # of rebalancing events per portfolio
Current_Baseline %>% filter(L > 1.3) %>% summarise(n = n()) # total number of rebalancing events


Merafkast_Baseline <- Current_Baseline %>%
  group_by(Portfolio) %>%
  filter(Date == max(Date)) %>%
  select(Portfolio, "TerminalW" = W) %>% left_join(
      Current_Baseline %>%
      group_by(Portfolio) %>%
      filter(Date == min(Date)) %>%
      select(Portfolio, "InitialG" = G),
      by = "Portfolio"
  ) %>% mutate(Return = (TerminalW - InitialG)/InitialG)

Current_Terminal_W_plot <- Merafkast_Baseline %>% ggplot(aes(x = TerminalW)) + 
  geom_histogram(fill = "gray77", color = "black", bins = 15) +
  labs(title = "Current System - Terminal Values",
       x = "Terminal Value",
       y = "Frequency") +
  theme_bw()

Current_Acc_G_plot <- Merafkast_Baseline %>% ggplot(aes(x = Return)) + 
  geom_histogram(fill = "gray77", color = "black", bins = 15) +
  labs(title = "Current System - Terminal Values over Initial Guarantee",
       x = "Excess Return over Initial Guarantee",
       y = "Frequency") +
  scale_x_continuous(labels = scales::percent) +
  theme_bw()

Merafkast_Baseline %>% ggplot(aes(x = Portfolio, y = Return)) +
  geom_bar(stat = "identity", fill = "gray77", color = "black") +
  labs(title = "Current System - Terminal Value over Initial Guarantee by TDF",
       x = "TDF Start Date",
       y = "Terminal Return") +
  theme_bw() + 
  scale_y_continuous(labels = scales::percent)+
  theme(axis.text.x = element_blank())


Merafkast_Baseline %>% ggplot(aes(x = Portfolio, y = InitialG, fill = Portfolio)) +
  geom_bar(stat = "identity", color = "Black") + 
  labs(title = "Baseline Initial Guarantee by TDF",
       x = "TDF Start Date",
       y = "Terminal Return") +
  theme_bw() + guides(fill = FALSE) +
  theme(axis.text.x = element_blank())


tdf_returns %>% filter(TIME_TO_MATURITY == 120) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = 80/ZC)) +
  geom_line() + theme_bw()

geom_line(aes(x = as.Date(TIME_PERIOD), y = 80/ZC), data = tdf_returns %>% filter(TIME_TO_MATURITY == 120))

tdf_returns %>% filter(TIME_TO_MATURITY == 120) %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = 100*ZC)) +
  geom_line()




## CPPI with our new ActivePF
# Risk Parity for MKT and TECH (both EU and US)

CPPI_System <- function(Active_PF, L_trigger, L_target, m, T = 10) {
  initial <- 100
  n <- T * 12
  
  portfolios <- unique(tdf_returns$Portfolio)
  results_list <- list()
  
  t <- 0
  for (pf in portfolios) {
    t <- t + 1
    
    tdf <- tdf_returns %>% filter(Portfolio == pf)
    
    A <- R <- G <- L <- W <- F <- numeric(n + 1)
    Date <- Active_PF$TIME_PERIOD[t:(n + t)]
    
    #Initial 
    F[1] <- initial * (initial / L_target)
    C <- initial - F[1]
    E <- m * C
    A[1] <- min(E, initial)
    R[1] <- initial - A[1]
    G[1] <- F[1] / tdf$ZC[1]
    W[1] <- A[1] + R[1]
    L[1] <- W[1] / F[1]
    
    #time step
    for (i in 1:n) {
      A[i + 1] <- (1 + Active_PF$Return[i + t] / 100) * A[i]
      R[i + 1] <- R[i] * (1 + tdf$Return[i + 1] / 100)
      
      W[i + 1] <- A[i + 1] + R[i + 1]
      F[i + 1] <- F[i] * (1 + tdf$Return[i + 1]/100)
      L[i + 1] <- W[i + 1] / F[i + 1]
      G[i + 1] <- F[i + 1] / tdf$ZC[i + 1]
      
      # Trigger 
      if (L[i + 1] > L_trigger/100) {
        C <- W[i + 1] - F[i+1]
        E <- m * C
        A[i + 1] <- min(E, W[i + 1])
        R[i + 1] <- W[i + 1] - A[i + 1]
      }
    }
    
    results_list[[pf]] <- data.frame(
      Portfolio = pf,
      Date = as.Date(Date),
      A = A,
      R = R,
      G = G,
      L = L,
      W = W,
      F = F
    )
  }
  
  results_all <- dplyr::bind_rows(results_list)
  
  return(results_all)
}


CPPIm4 <- Current_Active %>% mutate(Return = EU_EQ) %>% select(TIME_PERIOD,Return) %>%
  CPPI_System(L_trigger = 130, L_target = 125, m = 3)

CPPIm4 %>% ggplot(aes(x = Date, y = W, color = Portfolio)) +
  geom_line() +
  labs(title = "CPPI (m=4) Values Over Time",
       x = "Date",
       y = "Portfolio Value") + guides(color = FALSE) + theme_bw()

CPPIm4 %>% group_by(Portfolio) %>%
  filter(Date == max(Date)) %>%
  select(Portfolio, "TerminalW" = W) %>% ggplot(aes(x = TerminalW)) +
  geom_histogram(fill = "gray77", color = "black", bins = 15) +
  labs(title = "CPPI (m=4) - Terminal Values",
       x = "Terminal Value",
       y = "Frequency") +
  theme_bw()

CPPIm4 %>% group_by(Portfolio) %>%
  filter(Date == max(Date)) %>%
  select(Portfolio, "TerminalW" = W) %>% left_join(
    CPPIm4 %>%
      group_by(Portfolio) %>%
      filter(Date == min(Date)) %>%
      select(Portfolio, "InitialG" = G),
    by = "Portfolio"
  ) %>% mutate(Return = (TerminalW - InitialG)/InitialG) %>%
  ggplot(aes(x = Return)) + 
  geom_histogram(fill = "gray77", color = "black", bins = 15) +
  labs(title = "CPPI (m=4) - Terminal Values over Initial Guarantee",
       x = "Excess Return over Initial Guarantee",
       y = "Frequency") +
  scale_x_continuous(labels = scales::percent) +
  theme_bw()


