
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
    
    # Subset this term-structure dataset
    tdf <- tdf_returns %>% filter(Portfolio == pf)
    
    # Preallocate
    A <- R <- G <- L <- W <- numeric(n + 1)
    Date <- Current_Active$TIME_PERIOD[t:(n + t)]
    
    # Initial conditions
    A[1] <- initial * (1 - initial / L_target)
    R[1] <- initial - A[1]
    G[1] <- R[1] / tdf$ZC[1]
    L[1] <- (A[1] + R[1]) / R[1]
    W[1] <- A[1] + R[1]
    
    # Loop over months
    for (i in 1:n) {
      A[i + 1] <- (1 + Current_Active$EU_EQ[i + t] / 100) * A[i]
      R[i + 1] <- R[i] * (1 + tdf$Return[i + 1] / 100)
      
      W[i + 1] <- A[i + 1] + R[i + 1]
      L[i + 1] <- W[i + 1] / R[i + 1]
      G[i + 1] <- R[i + 1] / tdf$ZC[i + 1]
      
      # Trigger condition
      if (L[i + 1] > L_trigger/100) {
        A[i + 1] <- (1 - initial / L_target) * W[i + 1]
        R[i + 1] <- W[i + 1] - A[i + 1]
      }
    }
    
    # Store this portfolio’s results
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
  
  # Combine all portfolios into one data frame
  results_all <- dplyr::bind_rows(results_list)
  
  return(results_all)
}


Current_Baseline <- Current_TieIn_System(130,125)

# Value
Current_Baseline %>% ggplot(aes(x = Date, y = W, color = Portfolio)) +
  geom_line() +
  labs(title = "Current Baseline TDF Values Over Time",
       x = "Date",
       y = "Portfolio Value") + guides(color = FALSE) + theme_bw()

# Guarantees
Current_Baseline %>% ggplot(aes(x = Date, y = G, color = Portfolio)) +
  geom_line() +
  labs(title = "Current Baseline TDF Guarantees Over Time",
       x = "Date",
       y = "Portfolio Value") + guides(color = FALSE) + theme_bw()

#rebalancing events
Current_Baseline %>% filter(L > 1.3) %>% group_by(Portfolio) %>% summarise(n = n())
Current_Baseline %>% filter(L > 1.3) %>% summarise(n = n())


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

Merafkast_Baseline %>% ggplot(aes(x = TerminalW)) + 
  geom_histogram(fill = "gray77", color = "black", bins = 15) +
  labs(title = "Histogram of Baseline Terminal Values",
       x = "Terminal Value",
       y = "Frequency") +
  theme_bw()

Merafkast_Baseline %>% ggplot(aes(x = Return)) + 
  geom_histogram(fill = "gray77", color = "black", bins = 15) +
  labs(title = "Histogram of Baseline Terminal Returns",
       x = "Terminal Return",
       y = "Frequency") +
  theme_bw()


Merafkast_Baseline %>% ggplot(aes(x = Portfolio, y = Return)) +
  geom_bar(stat = "identity", fill = "gray77", color = "black") +
  labs(title = "Baseline Terminal Returns by TDF",
       x = "TDF Start Date",
       y = "Terminal Return") +
  theme_bw() + 
  theme(axis.text.x = element_blank())


Merafkast_Baseline %>% ggplot(aes(x = Portfolio, y = InitialG)) +
  geom_bar(stat = "identity", fill = "gray77", color = "black") +
  labs(title = "Baseline Initial Guarantee by TDF",
       x = "TDF Start Date",
       y = "Terminal Return") +
  theme_bw() + 
  theme(axis.text.x = element_blank())




## CPPI with our new ActivePF

CPPI_System <- function(Active_PF, L_trigger, L_target, m, T = 10) {
  initial <- 100
  n <- T * 12
  
  portfolios <- unique(tdf_returns$Portfolio)
  results_list <- list()
  
  t <- 0
  for (pf in portfolios) {
    t <- t + 1
    
    # Subset this term-structure dataset
    tdf <- tdf_returns %>% filter(Portfolio == pf)
    
    # Preallocate
    A <- R <- G <- L <- W <- F <- numeric(n + 1)
    Date <- Active_PF$TIME_PERIOD[t:(n + t)]
    
    # Initial conditions
    F[1] <- initial * (initial / L_target)
    C <- initial - F[1]
    E <- m * C
    A[1] <- min(E, initial)
    R[1] <- initial - A[1]
    G[1] <- F[1] / tdf$ZC[1]
    W[1] <- A[1] + R[1]
    L[1] <- W[1] / F[1]
    
    # Loop over months
    for (i in 1:n) {
      A[i + 1] <- (1 + Active_PF$Return[i + t] / 100) * A[i]
      R[i + 1] <- R[i] * (1 + tdf$Return[i + 1] / 100)
      
      W[i + 1] <- A[i + 1] + R[i + 1]
      F[i + 1] <- F[i] * (1 + tdf$Return[i + 1]/100)
      L[i + 1] <- W[i + 1] / F[i + 1]
      G[i + 1] <- F[i + 1] / tdf$ZC[i + 1]
      
      # Trigger condition
      if (L[i + 1] > L_trigger/100) {
        C <- W[i + 1] - F[i+1]
        E <- m * C
        A[i + 1] <- min(E, W[i + 1])
        R[i + 1] <- W[i + 1] - A[i + 1]
      }
    }
    
    # Store this portfolio’s results
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
  
  # Combine all portfolios into one data frame
  results_all <- dplyr::bind_rows(results_list)
  
  return(results_all)
}

Current_Active %>% mutate(Return = EU_EQ) %>% select(TIME_PERIOD,Return) %>%
  CPPI_System(L_trigger = 130, L_target = 125, m = 2)


