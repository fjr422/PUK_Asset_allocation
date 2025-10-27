
####
## Remember to run "Global.R" before running this code ##
####

# Just some plots for visualizing the data

# PF_Data %>% filter(Division %in% c("EU25", "EU6")) %>% ggplot(aes(x = DateID, y = Return, color = Portfolio)) +
#   geom_point(size = .3, alpha = .5) + facet_wrap(~ Division) + theme_bw()
# 
# PF_Data %>% filter(Division %in% c("US25", "US6")) %>% ggplot(aes(x = DateID, y = Return, color = Portfolio)) +
#   geom_point(size = .3, alpha = .5) + facet_wrap(~ Division) + theme_bw()
# 
# PF_Data %>% filter(Division %in% c("US25", "EU25"), DateID > "1990-01-01") %>% ggplot(aes(x = DateID, y = Return, color = Portfolio)) +
#   geom_point(size = .8, alpha = .5) + facet_wrap(~ Division, ncol = 1) + theme_bw()
# 
# EUR_USD_exchange %>% ggplot(aes(x = Date, y = USD)) + geom_line() + labs(y="EUR / USD", x="Date") + theme_bw()


# Comparative Analysis of MKT, SMB, and MOM

# PF_Data %>% filter(Division %in% c("EU25", "EU6")) %>% ggplot(aes(x = DateID, y = Return, color = Portfolio)) +
#   geom_point(size = .3, alpha = .5) + facet_wrap(~ Division) + theme_bw()
# 
# PF_Data %>% filter(Division %in% c("US25", "US6")) %>% ggplot(aes(x = DateID, y = Return, color = Portfolio)) +
#   geom_point(size = .3, alpha = .5) + facet_wrap(~ Division) + theme_bw()
# 
# PF_Data %>% filter(Division %in% c("US25", "EU25"), DateID > "2004-09-01") %>% ggplot(aes(x = DateID, y = Return, color = Portfolio)) +
#   geom_line() + facet_wrap(~ Division, ncol = 1) + theme_bw()


fama_french_portfolios %>% filter(N_Portfolios == 25, TIME_PERIOD <= "2024-12-31", TIME_PERIOD >= "2004-09-01") %>%
  ggplot(aes(x = as.Date(TIME_PERIOD), y = Return_USD, color = Portfolio)) +
  geom_line() + labs(y="Return (USD)", x="Date") + theme_bw() + facet_wrap(~ Region)




#Factor Regression for USD-based US investor
#USD_based_US <- FactorModelData %>% filter(Division == "US25")
USD_based_US <- fama_french_portfolios %>% filter(Region == "US", N_Portfolios == 25, TIME_PERIOD <= "2024-12-31", TIME_PERIOD >= "2004-09-01") %>%
  mutate(Market_Excess_Return = Market_Return_USD - RF_US)


LM_Size1Mom1 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "SMALL LoPRIOR"))
LM_Size1Mom2 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME1 PRIOR2"))
LM_Size1Mom3 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME1 PRIOR3"))
LM_Size1Mom4 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME1 PRIOR4"))
LM_Size1Mom5 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "SMALL HiPRIOR"))

LM_Size2Mom1 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR1"))
LM_Size2Mom2 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR2"))
LM_Size2Mom3 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR3"))
LM_Size2Mom4 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR4"))
LM_Size2Mom5 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR5"))                    
                     
LM_Size3Mom1 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR1"))
LM_Size3Mom2 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR2"))
LM_Size3Mom3 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR3"))
LM_Size3Mom4 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR4"))
LM_Size3Mom5 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR5"))

LM_Size4Mom1 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR1"))
LM_Size4Mom2 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR2"))
LM_Size4Mom3 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR3"))
LM_Size4Mom4 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR4"))
LM_Size4Mom5 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR5"))

LM_Size5Mom1 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "BIG LoPRIOR"))
LM_Size5Mom2 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME5 PRIOR2"))
LM_Size5Mom3 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME5 PRIOR3"))
LM_Size5Mom4 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME5 PRIOR4"))
LM_Size5Mom5 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "BIG HiPRIOR"))

#Make table of estimates
b_US25 <- matrix(c(LM_Size1Mom1$coefficients[2], LM_Size1Mom2$coefficients[2], LM_Size1Mom3$coefficients[2], LM_Size1Mom4$coefficients[2], LM_Size1Mom5$coefficients[2],
         LM_Size2Mom1$coefficients[2], LM_Size2Mom2$coefficients[2], LM_Size2Mom3$coefficients[2], LM_Size2Mom4$coefficients[2], LM_Size2Mom5$coefficients[2],
         LM_Size3Mom1$coefficients[2], LM_Size3Mom2$coefficients[2], LM_Size3Mom3$coefficients[2], LM_Size3Mom4$coefficients[2], LM_Size3Mom5$coefficients[2],
         LM_Size4Mom1$coefficients[2], LM_Size4Mom2$coefficients[2], LM_Size4Mom3$coefficients[2], LM_Size4Mom4$coefficients[2], LM_Size4Mom5$coefficients[2],
         LM_Size5Mom1$coefficients[2], LM_Size5Mom2$coefficients[2], LM_Size5Mom3$coefficients[2], LM_Size5Mom4$coefficients[2], LM_Size5Mom5$coefficients[2]),
         nrow = 5, byrow = TRUE)
colnames(b_US25) <- c("Low", "2", "3", "4", "High")
rownames(b_US25) <- c("Small", "2", "3", "4", "Big")

s_US25 <- matrix(c(LM_Size1Mom1$coefficients[3], LM_Size1Mom2$coefficients[3], LM_Size1Mom3$coefficients[3], LM_Size1Mom4$coefficients[3], LM_Size1Mom5$coefficients[3],
                   LM_Size2Mom1$coefficients[3], LM_Size2Mom2$coefficients[3], LM_Size2Mom3$coefficients[3], LM_Size2Mom4$coefficients[3], LM_Size2Mom5$coefficients[3],
                   LM_Size3Mom1$coefficients[3], LM_Size3Mom2$coefficients[3], LM_Size3Mom3$coefficients[3], LM_Size3Mom4$coefficients[3], LM_Size3Mom5$coefficients[3],
                   LM_Size4Mom1$coefficients[3], LM_Size4Mom2$coefficients[3], LM_Size4Mom3$coefficients[3], LM_Size4Mom4$coefficients[3], LM_Size4Mom5$coefficients[3],
                   LM_Size5Mom1$coefficients[3], LM_Size5Mom2$coefficients[3], LM_Size5Mom3$coefficients[3], LM_Size5Mom4$coefficients[3], LM_Size5Mom5$coefficients[3]),
                 nrow = 5, byrow = TRUE)
colnames(s_US25) <- c("Low", "2", "3", "4", "High")
rownames(s_US25) <- c("Small", "2", "3", "4", "Big")

m_US25 <- matrix(c(LM_Size1Mom1$coefficients[4], LM_Size1Mom2$coefficients[4], LM_Size1Mom3$coefficients[4], LM_Size1Mom4$coefficients[4], LM_Size1Mom5$coefficients[4],
                   LM_Size2Mom1$coefficients[4], LM_Size2Mom2$coefficients[4], LM_Size2Mom3$coefficients[4], LM_Size2Mom4$coefficients[4], LM_Size2Mom5$coefficients[4],
                   LM_Size3Mom1$coefficients[4], LM_Size3Mom2$coefficients[4], LM_Size3Mom3$coefficients[4], LM_Size3Mom4$coefficients[4], LM_Size3Mom5$coefficients[4],
                   LM_Size4Mom1$coefficients[4], LM_Size4Mom2$coefficients[4], LM_Size4Mom3$coefficients[4], LM_Size4Mom4$coefficients[4], LM_Size4Mom5$coefficients[4],
                   LM_Size5Mom1$coefficients[4], LM_Size5Mom2$coefficients[4], LM_Size5Mom3$coefficients[4], LM_Size5Mom4$coefficients[4], LM_Size5Mom5$coefficients[4]),
                 nrow = 5, byrow = TRUE)
colnames(m_US25) <- c("Low", "2", "3", "4", "High")
rownames(m_US25) <- c("Small", "2", "3", "4", "Big")

tb_US25 <- matrix(c(summary(LM_Size1Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_Size1Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_Size1Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_Size1Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_Size1Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(LM_Size2Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_Size2Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_Size2Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_Size2Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_Size2Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(LM_Size3Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_Size3Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_Size3Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_Size3Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_Size3Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(LM_Size4Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_Size4Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_Size4Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_Size4Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_Size4Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(LM_Size5Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_Size5Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_Size5Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_Size5Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_Size5Mom5)$coefficients["Market_Excess_Return","t value"]),
                  nrow = 5, byrow = TRUE)
colnames(tb_US25) <- c("Low", "2", "3", "4", "High")
rownames(tb_US25) <- c("Small", "2", "3", "4", "Big")

ts_US25 <- matrix(c(summary(LM_Size1Mom1)$coefficients["SMB_USD","t value"], summary(LM_Size1Mom2)$coefficients["SMB_USD","t value"], summary(LM_Size1Mom3)$coefficients["SMB_USD","t value"], summary(LM_Size1Mom4)$coefficients["SMB_USD","t value"], summary(LM_Size1Mom5)$coefficients["SMB_USD","t value"],
                    summary(LM_Size2Mom1)$coefficients["SMB_USD","t value"], summary(LM_Size2Mom2)$coefficients["SMB_USD","t value"], summary(LM_Size2Mom3)$coefficients["SMB_USD","t value"], summary(LM_Size2Mom4)$coefficients["SMB_USD","t value"], summary(LM_Size2Mom5)$coefficients["SMB_USD","t value"],
                    summary(LM_Size3Mom1)$coefficients["SMB_USD","t value"], summary(LM_Size3Mom2)$coefficients["SMB_USD","t value"], summary(LM_Size3Mom3)$coefficients["SMB_USD","t value"], summary(LM_Size3Mom4)$coefficients["SMB_USD","t value"], summary(LM_Size3Mom5)$coefficients["SMB_USD","t value"],
                    summary(LM_Size4Mom1)$coefficients["SMB_USD","t value"], summary(LM_Size4Mom2)$coefficients["SMB_USD","t value"], summary(LM_Size4Mom3)$coefficients["SMB_USD","t value"], summary(LM_Size4Mom4)$coefficients["SMB_USD","t value"], summary(LM_Size4Mom5)$coefficients["SMB_USD","t value"],
                    summary(LM_Size5Mom1)$coefficients["SMB_USD","t value"], summary(LM_Size5Mom2)$coefficients["SMB_USD","t value"], summary(LM_Size5Mom3)$coefficients["SMB_USD","t value"], summary(LM_Size5Mom4)$coefficients["SMB_USD","t value"], summary(LM_Size5Mom5)$coefficients["SMB_USD","t value"]),
                  nrow = 5, byrow = TRUE)
colnames(ts_US25) <- c("Low", "2", "3", "4", "High")
rownames(ts_US25) <- c("Small", "2", "3", "4", "Big")

tm_US25 <- matrix(c(summary(LM_Size1Mom1)$coefficients["MOM_USD","t value"], summary(LM_Size1Mom2)$coefficients["MOM_USD","t value"], summary(LM_Size1Mom3)$coefficients["MOM_USD","t value"], summary(LM_Size1Mom4)$coefficients["MOM_USD","t value"], summary(LM_Size1Mom5)$coefficients["MOM_USD","t value"],
                    summary(LM_Size2Mom1)$coefficients["MOM_USD","t value"], summary(LM_Size2Mom2)$coefficients["MOM_USD","t value"], summary(LM_Size2Mom3)$coefficients["MOM_USD","t value"], summary(LM_Size2Mom4)$coefficients["MOM_USD","t value"], summary(LM_Size2Mom5)$coefficients["MOM_USD","t value"],
                    summary(LM_Size3Mom1)$coefficients["MOM_USD","t value"], summary(LM_Size3Mom2)$coefficients["MOM_USD","t value"], summary(LM_Size3Mom3)$coefficients["MOM_USD","t value"], summary(LM_Size3Mom4)$coefficients["MOM_USD","t value"], summary(LM_Size3Mom5)$coefficients["MOM_USD","t value"],
                    summary(LM_Size4Mom1)$coefficients["MOM_USD","t value"], summary(LM_Size4Mom2)$coefficients["MOM_USD","t value"], summary(LM_Size4Mom3)$coefficients["MOM_USD","t value"], summary(LM_Size4Mom4)$coefficients["MOM_USD","t value"], summary(LM_Size4Mom5)$coefficients["MOM_USD","t value"],
                    summary(LM_Size5Mom1)$coefficients["MOM_USD","t value"], summary(LM_Size5Mom2)$coefficients["MOM_USD","t value"], summary(LM_Size5Mom3)$coefficients["MOM_USD","t value"], summary(LM_Size5Mom4)$coefficients["MOM_USD","t value"], summary(LM_Size5Mom5)$coefficients["MOM_USD","t value"]),
                  nrow = 5, byrow = TRUE)
colnames(tm_US25) <- c("Low", "2", "3", "4", "High")
rownames(tm_US25) <- c("Small", "2", "3", "4", "Big")

r2_US25 <- matrix(c(summary(LM_Size1Mom1)$adj.r.squared, summary(LM_Size1Mom2)$adj.r.squared, summary(LM_Size1Mom3)$adj.r.squared, summary(LM_Size1Mom4)$adj.r.squared, summary(LM_Size1Mom5)$adj.r.squared,
                     summary(LM_Size2Mom1)$adj.r.squared, summary(LM_Size2Mom2)$adj.r.squared, summary(LM_Size2Mom3)$adj.r.squared, summary(LM_Size2Mom4)$adj.r.squared, summary(LM_Size2Mom5)$adj.r.squared,
                     summary(LM_Size3Mom1)$adj.r.squared, summary(LM_Size3Mom2)$adj.r.squared, summary(LM_Size3Mom3)$adj.r.squared, summary(LM_Size3Mom4)$adj.r.squared, summary(LM_Size3Mom5)$adj.r.squared,
                     summary(LM_Size4Mom1)$adj.r.squared, summary(LM_Size4Mom2)$adj.r.squared, summary(LM_Size4Mom3)$adj.r.squared, summary(LM_Size4Mom4)$adj.r.squared, summary(LM_Size4Mom5)$adj.r.squared,
                     summary(LM_Size5Mom1)$adj.r.squared, summary(LM_Size5Mom2)$adj.r.squared, summary(LM_Size5Mom3)$adj.r.squared, summary(LM_Size5Mom4)$adj.r.squared, summary(LM_Size5Mom5)$adj.r.squared),
                   nrow = 5, byrow = TRUE)
colnames(r2_US25) <- c("Low", "2", "3", "4", "High")
rownames(r2_US25) <- c("Small", "2", "3", "4", "Big")

se_US25 <- matrix(c(summary(LM_Size1Mom1)$sigma, summary(LM_Size1Mom2)$sigma, summary(LM_Size1Mom3)$sigma, summary(LM_Size1Mom4)$sigma, summary(LM_Size1Mom5)$sigma,
                    summary(LM_Size2Mom1)$sigma, summary(LM_Size2Mom2)$sigma, summary(LM_Size2Mom3)$sigma, summary(LM_Size2Mom4)$sigma, summary(LM_Size2Mom5)$sigma,
                    summary(LM_Size3Mom1)$sigma, summary(LM_Size3Mom2)$sigma, summary(LM_Size3Mom3)$sigma, summary(LM_Size3Mom4)$sigma, summary(LM_Size3Mom5)$sigma,
                    summary(LM_Size4Mom1)$sigma, summary(LM_Size4Mom2)$sigma, summary(LM_Size4Mom3)$sigma, summary(LM_Size4Mom4)$sigma, summary(LM_Size4Mom5)$sigma,
                    summary(LM_Size5Mom1)$sigma, summary(LM_Size5Mom2)$sigma, summary(LM_Size5Mom3)$sigma, summary(LM_Size5Mom4)$sigma, summary(LM_Size5Mom5)$sigma),
                  nrow = 5, byrow = TRUE)
colnames(se_US25) <- c("Low", "2", "3", "4", "High")
rownames(se_US25) <- c("Small", "2", "3", "4", "Big")

factors_USD_Based_US <- rbind(cbind(b_US25, tb_US25),
                                    cbind(s_US25, ts_US25), 
                                    cbind(m_US25, tm_US25), 
                                    cbind(r2_US25, se_US25))

color_factor_tables <- function(data, scales){
  
  data %>%
    kable("latex", escape = FALSE, booktabs = FALSE, linesep = "", align = c("l", rep("c", 10))) %>%
    kable_styling() %>%
    column_spec(2, background = {
      col <- rep("transparent", nrow(data))
      col[6:15] <- spec_color(data[6:15, 1] + 100, option = "D", scale_from = scales)
      col
    }) %>%
    column_spec(3, background = {
      col <- rep("transparent", nrow(data))
      col[6:15] <- spec_color(data[6:15, 2] + 100, option = "D", scale_from = scales)
      col
    }) %>%
    column_spec(4, background = {
      col <- rep("transparent", nrow(data))
      col[6:15] <- spec_color(data[6:15, 3] + 100, option = "D", scale_from = scales)
      col
    }) %>%
    column_spec(5, background = {
      col <- rep("transparent", nrow(data))
      col[6:15] <- spec_color(data[6:15, 4] + 100, option = "D", scale_from = scales)
      col
    }) %>%
    column_spec(6, background = {
      col <- rep("transparent", nrow(data))
      col[6:15] <- spec_color(data[6:15, 5] + 100, option = "D", scale_from = scales)
      col
    })
}



writeLines(color_factor_tables(round(factors_USD_Based_US,2), c(98, 101.35)),
           con = "R/Output/factors_USD_US_colored.tex")



round(factors_USD_Based_US, 2)

print(xtable(factors_USD_Based_US, 
             digits = 2),
      type = "latex", 
      file = "R/Output/factors_USD_US.tex")


## For EUR-based US investor
EUR_based_US <- fama_french_portfolios %>% filter(Region == "US", N_Portfolios == 25, TIME_PERIOD <= "2024-12-31", TIME_PERIOD >= "2004-09-01") %>%
  mutate(Market_Excess_Return = Market_Return_EUR - RF_EU)

EUR_based_US %>% select(c(TIME_PERIOD, SMB_EUR, MOM_EUR, Market_Excess_Return, RF_EU,Monthly_Exchange_Return)) %>% unique()

LM_EURUS_Size1Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "SMALL LoPRIOR"))
LM_EURUS_Size1Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME1 PRIOR2"))
LM_EURUS_Size1Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME1 PRIOR3"))
LM_EURUS_Size1Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME1 PRIOR4"))
LM_EURUS_Size1Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "SMALL HiPRIOR"))

LM_EURUS_Size2Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME2 PRIOR1"))
LM_EURUS_Size2Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME2 PRIOR2"))
LM_EURUS_Size2Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME2 PRIOR3"))
LM_EURUS_Size2Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME2 PRIOR4"))
LM_EURUS_Size2Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME2 PRIOR5"))                    

LM_EURUS_Size3Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME3 PRIOR1"))
LM_EURUS_Size3Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME3 PRIOR2"))
LM_EURUS_Size3Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME3 PRIOR3"))
LM_EURUS_Size3Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME3 PRIOR4"))
LM_EURUS_Size3Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME3 PRIOR5"))

LM_EURUS_Size4Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME4 PRIOR1"))
LM_EURUS_Size4Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME4 PRIOR2"))
LM_EURUS_Size4Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME4 PRIOR3"))
LM_EURUS_Size4Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME4 PRIOR4"))
LM_EURUS_Size4Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME4 PRIOR5"))

LM_EURUS_Size5Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "BIG LoPRIOR"))
LM_EURUS_Size5Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME5 PRIOR2"))
LM_EURUS_Size5Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME5 PRIOR3"))
LM_EURUS_Size5Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "ME5 PRIOR4"))
LM_EURUS_Size5Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_US %>% filter(Portfolio == "BIG HiPRIOR"))

#Make table of estimates
b_EURUS <- matrix(c(LM_EURUS_Size1Mom1$coefficients[2], LM_EURUS_Size1Mom2$coefficients[2], LM_EURUS_Size1Mom3$coefficients[2], LM_EURUS_Size1Mom4$coefficients[2], LM_EURUS_Size1Mom5$coefficients[2],
                   LM_EURUS_Size2Mom1$coefficients[2], LM_EURUS_Size2Mom2$coefficients[2], LM_EURUS_Size2Mom3$coefficients[2], LM_EURUS_Size2Mom4$coefficients[2], LM_EURUS_Size2Mom5$coefficients[2],
                   LM_EURUS_Size3Mom1$coefficients[2], LM_EURUS_Size3Mom2$coefficients[2], LM_EURUS_Size3Mom3$coefficients[2], LM_EURUS_Size3Mom4$coefficients[2], LM_EURUS_Size3Mom5$coefficients[2],
                   LM_EURUS_Size4Mom1$coefficients[2], LM_EURUS_Size4Mom2$coefficients[2], LM_EURUS_Size4Mom3$coefficients[2], LM_EURUS_Size4Mom4$coefficients[2], LM_EURUS_Size4Mom5$coefficients[2],
                   LM_EURUS_Size5Mom1$coefficients[2], LM_EURUS_Size5Mom2$coefficients[2], LM_EURUS_Size5Mom3$coefficients[2], LM_EURUS_Size5Mom4$coefficients[2], LM_EURUS_Size5Mom5$coefficients[2]),
                 nrow = 5, byrow = TRUE)
colnames(b_EURUS) <- c("Low", "2", "3", "4", "High")
rownames(b_EURUS) <- c("Small", "2", "3", "4", "Big")

s_EURUS <- matrix(c(LM_EURUS_Size1Mom1$coefficients[3], LM_EURUS_Size1Mom2$coefficients[3], LM_EURUS_Size1Mom3$coefficients[3], LM_EURUS_Size1Mom4$coefficients[3], LM_EURUS_Size1Mom5$coefficients[3],
                   LM_EURUS_Size2Mom1$coefficients[3], LM_EURUS_Size2Mom2$coefficients[3], LM_EURUS_Size2Mom3$coefficients[3], LM_EURUS_Size2Mom4$coefficients[3], LM_EURUS_Size2Mom5$coefficients[3],
                   LM_EURUS_Size3Mom1$coefficients[3], LM_EURUS_Size3Mom2$coefficients[3], LM_EURUS_Size3Mom3$coefficients[3], LM_EURUS_Size3Mom4$coefficients[3], LM_EURUS_Size3Mom5$coefficients[3],
                   LM_EURUS_Size4Mom1$coefficients[3], LM_EURUS_Size4Mom2$coefficients[3], LM_EURUS_Size4Mom3$coefficients[3], LM_EURUS_Size4Mom4$coefficients[3], LM_EURUS_Size4Mom5$coefficients[3],
                   LM_EURUS_Size5Mom1$coefficients[3], LM_EURUS_Size5Mom2$coefficients[3], LM_EURUS_Size5Mom3$coefficients[3], LM_EURUS_Size5Mom4$coefficients[3], LM_EURUS_Size5Mom5$coefficients[3]),
                 nrow = 5, byrow = TRUE)
colnames(s_EURUS) <- c("Low", "2", "3", "4", "High")
rownames(s_EURUS) <- c("Small", "2", "3", "4", "Big")

m_EURUS <- matrix(c(LM_EURUS_Size1Mom1$coefficients[4], LM_EURUS_Size1Mom2$coefficients[4], LM_EURUS_Size1Mom3$coefficients[4], LM_EURUS_Size1Mom4$coefficients[4], LM_EURUS_Size1Mom5$coefficients[4],
                   LM_EURUS_Size2Mom1$coefficients[4], LM_EURUS_Size2Mom2$coefficients[4], LM_EURUS_Size2Mom3$coefficients[4], LM_EURUS_Size2Mom4$coefficients[4], LM_EURUS_Size2Mom5$coefficients[4],
                   LM_EURUS_Size3Mom1$coefficients[4], LM_EURUS_Size3Mom2$coefficients[4], LM_EURUS_Size3Mom3$coefficients[4], LM_EURUS_Size3Mom4$coefficients[4], LM_EURUS_Size3Mom5$coefficients[4],
                   LM_EURUS_Size4Mom1$coefficients[4], LM_EURUS_Size4Mom2$coefficients[4], LM_EURUS_Size4Mom3$coefficients[4], LM_EURUS_Size4Mom4$coefficients[4], LM_EURUS_Size4Mom5$coefficients[4],
                   LM_EURUS_Size5Mom1$coefficients[4], LM_EURUS_Size5Mom2$coefficients[4], LM_EURUS_Size5Mom3$coefficients[4], LM_EURUS_Size5Mom4$coefficients[4], LM_EURUS_Size5Mom5$coefficients[4]),
                 nrow = 5, byrow = TRUE)
colnames(m_EURUS) <- c("Low", "2", "3", "4", "High")
rownames(m_EURUS) <- c("Small", "2", "3", "4", "Big")

tb_EURUS <- matrix(c(summary(LM_EURUS_Size1Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size1Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size1Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size1Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size1Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(LM_EURUS_Size2Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size2Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size2Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size2Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size2Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(LM_EURUS_Size3Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size3Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size3Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size3Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size3Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(LM_EURUS_Size4Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size4Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size4Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size4Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size4Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(LM_EURUS_Size5Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size5Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size5Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size5Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_EURUS_Size5Mom5)$coefficients["Market_Excess_Return","t value"]),
                  nrow = 5, byrow = TRUE)
colnames(tb_EURUS) <- c("Low", "2", "3", "4", "High")
rownames(tb_EURUS) <- c("Small", "2", "3", "4", "Big")

ts_EURUS <- matrix(c(summary(LM_EURUS_Size1Mom1)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size1Mom2)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size1Mom3)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size1Mom4)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size1Mom5)$coefficients["SMB_EUR","t value"],
                    summary(LM_EURUS_Size2Mom1)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size2Mom2)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size2Mom3)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size2Mom4)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size2Mom5)$coefficients["SMB_EUR","t value"],
                    summary(LM_EURUS_Size3Mom1)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size3Mom2)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size3Mom3)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size3Mom4)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size3Mom5)$coefficients["SMB_EUR","t value"],
                    summary(LM_EURUS_Size4Mom1)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size4Mom2)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size4Mom3)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size4Mom4)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size4Mom5)$coefficients["SMB_EUR","t value"],
                    summary(LM_EURUS_Size5Mom1)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size5Mom2)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size5Mom3)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size5Mom4)$coefficients["SMB_EUR","t value"], summary(LM_EURUS_Size5Mom5)$coefficients["SMB_EUR","t value"]),
                  nrow = 5, byrow = TRUE)
colnames(ts_EURUS) <- c("Low", "2", "3", "4", "High")
rownames(ts_EURUS) <- c("Small", "2", "3", "4", "Big")

tm_EURUS <- matrix(c(summary(LM_EURUS_Size1Mom1)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size1Mom2)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size1Mom3)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size1Mom4)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size1Mom5)$coefficients["MOM_EUR","t value"],
                    summary(LM_EURUS_Size2Mom1)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size2Mom2)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size2Mom3)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size2Mom4)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size2Mom5)$coefficients["MOM_EUR","t value"],
                    summary(LM_EURUS_Size3Mom1)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size3Mom2)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size3Mom3)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size3Mom4)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size3Mom5)$coefficients["MOM_EUR","t value"],
                    summary(LM_EURUS_Size4Mom1)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size4Mom2)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size4Mom3)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size4Mom4)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size4Mom5)$coefficients["MOM_EUR","t value"],
                    summary(LM_EURUS_Size5Mom1)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size5Mom2)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size5Mom3)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size5Mom4)$coefficients["MOM_EUR","t value"], summary(LM_EURUS_Size5Mom5)$coefficients["MOM_EUR","t value"]),
                  nrow = 5, byrow = TRUE)
colnames(tm_EURUS) <- c("Low", "2", "3", "4", "High")
rownames(tm_EURUS) <- c("Small", "2", "3", "4", "Big")

r2_EURUS <- matrix(c(summary(LM_EURUS_Size1Mom1)$adj.r.squared, summary(LM_EURUS_Size1Mom2)$adj.r.squared, summary(LM_EURUS_Size1Mom3)$adj.r.squared, summary(LM_EURUS_Size1Mom4)$adj.r.squared, summary(LM_EURUS_Size1Mom5)$adj.r.squared,
                    summary(LM_EURUS_Size2Mom1)$adj.r.squared, summary(LM_EURUS_Size2Mom2)$adj.r.squared, summary(LM_EURUS_Size2Mom3)$adj.r.squared, summary(LM_EURUS_Size2Mom4)$adj.r.squared, summary(LM_EURUS_Size2Mom5)$adj.r.squared,
                    summary(LM_EURUS_Size3Mom1)$adj.r.squared, summary(LM_EURUS_Size3Mom2)$adj.r.squared, summary(LM_EURUS_Size3Mom3)$adj.r.squared, summary(LM_EURUS_Size3Mom4)$adj.r.squared, summary(LM_EURUS_Size3Mom5)$adj.r.squared,
                    summary(LM_EURUS_Size4Mom1)$adj.r.squared, summary(LM_EURUS_Size4Mom2)$adj.r.squared, summary(LM_EURUS_Size4Mom3)$adj.r.squared, summary(LM_EURUS_Size4Mom4)$adj.r.squared, summary(LM_EURUS_Size4Mom5)$adj.r.squared,
                    summary(LM_EURUS_Size5Mom1)$adj.r.squared, summary(LM_EURUS_Size5Mom2)$adj.r.squared, summary(LM_EURUS_Size5Mom3)$adj.r.squared, summary(LM_EURUS_Size5Mom4)$adj.r.squared, summary(LM_EURUS_Size5Mom5)$adj.r.squared),
                  nrow = 5, byrow = TRUE)
colnames(r2_EURUS) <- c("Low", "2", "3", "4", "High")
rownames(r2_EURUS) <- c("Small", "2", "3", "4", "Big")

se_EURUS <- matrix(c(summary(LM_EURUS_Size1Mom1)$sigma, summary(LM_EURUS_Size1Mom2)$sigma, summary(LM_EURUS_Size1Mom3)$sigma, summary(LM_EURUS_Size1Mom4)$sigma, summary(LM_EURUS_Size1Mom5)$sigma,
                    summary(LM_EURUS_Size2Mom1)$sigma, summary(LM_EURUS_Size2Mom2)$sigma, summary(LM_EURUS_Size2Mom3)$sigma, summary(LM_EURUS_Size2Mom4)$sigma, summary(LM_EURUS_Size2Mom5)$sigma,
                    summary(LM_EURUS_Size3Mom1)$sigma, summary(LM_EURUS_Size3Mom2)$sigma, summary(LM_EURUS_Size3Mom3)$sigma, summary(LM_EURUS_Size3Mom4)$sigma, summary(LM_EURUS_Size3Mom5)$sigma,
                    summary(LM_EURUS_Size4Mom1)$sigma, summary(LM_EURUS_Size4Mom2)$sigma, summary(LM_EURUS_Size4Mom3)$sigma, summary(LM_EURUS_Size4Mom4)$sigma, summary(LM_EURUS_Size4Mom5)$sigma,
                    summary(LM_EURUS_Size5Mom1)$sigma, summary(LM_EURUS_Size5Mom2)$sigma, summary(LM_EURUS_Size5Mom3)$sigma, summary(LM_EURUS_Size5Mom4)$sigma, summary(LM_EURUS_Size5Mom5)$sigma),
                  nrow = 5, byrow = TRUE)
colnames(se_EURUS) <- c("Low", "2", "3", "4", "High")
rownames(se_EURUS) <- c("Small", "2", "3", "4", "Big")

factors_EUR_Based_US <- rbind(cbind(b_EURUS, tb_EURUS),
                              cbind(s_EURUS, ts_EURUS), 
                              cbind(m_EURUS, tm_EURUS), 
                              cbind(r2_EURUS, se_EURUS))

round(rbind(cbind(b_EURUS, tb_EURUS),
      cbind(s_EURUS, ts_EURUS), 
      cbind(m_EURUS, tm_EURUS), 
      cbind(r2_EURUS, se_EURUS)),2)

print(xtable(factors_EUR_Based_US, digits = 2), type = "latex", file = "R/Output/factors_EUR_US.tex")

writeLines(color_factor_tables(round(factors_EUR_Based_US,2), c(98, 101.35)),
           con = "R/Output/factors_EUR_US_colored.tex")

Intercepts_EURUS <- cbind(matrix(c(summary(LM_EURUS_Size1Mom1)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size1Mom2)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size1Mom3)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size1Mom4)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size1Mom5)$coefficients["(Intercept)","Estimate"],
                                   summary(LM_EURUS_Size2Mom1)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size2Mom2)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size2Mom3)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size2Mom4)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size2Mom5)$coefficients["(Intercept)","Estimate"],
                                   summary(LM_EURUS_Size3Mom1)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size3Mom2)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size3Mom3)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size3Mom4)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size3Mom5)$coefficients["(Intercept)","Estimate"],
                                   summary(LM_EURUS_Size4Mom1)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size4Mom2)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size4Mom3)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size4Mom4)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size4Mom5)$coefficients["(Intercept)","Estimate"],
                                   summary(LM_EURUS_Size5Mom1)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size5Mom2)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size5Mom3)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size5Mom4)$coefficients["(Intercept)","Estimate"], summary(LM_EURUS_Size5Mom5)$coefficients["(Intercept)","Estimate"]),
                                 nrow = 5, byrow = TRUE),
                          matrix(c(summary(LM_EURUS_Size1Mom1)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size1Mom2)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size1Mom3)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size1Mom4)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size1Mom5)$coefficients["(Intercept)","t value"],
                                   summary(LM_EURUS_Size2Mom1)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size2Mom2)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size2Mom3)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size2Mom4)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size2Mom5)$coefficients["(Intercept)","t value"],
                                   summary(LM_EURUS_Size3Mom1)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size3Mom2)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size3Mom3)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size3Mom4)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size3Mom5)$coefficients["(Intercept)","t value"],
                                   summary(LM_EURUS_Size4Mom1)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size4Mom2)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size4Mom3)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size4Mom4)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size4Mom5)$coefficients["(Intercept)","t value"],
                                   summary(LM_EURUS_Size5Mom1)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size5Mom2)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size5Mom3)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size5Mom4)$coefficients["(Intercept)","t value"], summary(LM_EURUS_Size5Mom5)$coefficients["(Intercept)","t value"]),
                                 nrow = 5, byrow = TRUE)
)


colnames(Intercepts_EURUS) <- rep(c("Low", "2", "3", "4", "High"),2)
rownames(Intercepts_EURUS) <- c("Small", "2", "3", "4", "Big")
Intercepts_EURUS


## For EUR-based EU investor
EUR_based_EU <- fama_french_portfolios %>% filter(Region == "EU", N_Portfolios == 25, TIME_PERIOD <= "2024-12-31", TIME_PERIOD >= "2004-09-01") %>%
  mutate(Market_Excess_Return = Market_Return_EUR - RF_EU)

EUR_based_EU %>% select(c(TIME_PERIOD, Return_USD, USD_to_EUR, Prev_USD_to_EUR, Monthly_Exchange_Return, Return_EUR))

EUR_based_US %>% select(c(TIME_PERIOD, SMB_EUR, MOM_EUR, Market_Excess_Return, RF_EU,Monthly_Exchange_Return)) %>% unique()

EUR_based_EU %>% select(c(TIME_PERIOD, Market_Return_EUR)) %>% unique() %>% ggplot(aes(x = as.Date(TIME_PERIOD), y = Market_Return_EUR)) + geom_line() + ggtitle("Market Return EUR") + ylab("Market Return EUR") + xlab("Time Period")


LM_EUREU_Size1Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "SMALL LoPRIOR"))
LM_EUREU_Size1Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME1 PRIOR2"))
LM_EUREU_Size1Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME1 PRIOR3"))
LM_EUREU_Size1Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME1 PRIOR4"))
LM_EUREU_Size1Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "SMALL HiPRIOR"))

LM_EUREU_Size2Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR1"))
LM_EUREU_Size2Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR2"))
LM_EUREU_Size2Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR3"))
LM_EUREU_Size2Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR4"))
LM_EUREU_Size2Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR5"))                    

LM_EUREU_Size3Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR1"))
LM_EUREU_Size3Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR2"))
LM_EUREU_Size3Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR3"))
LM_EUREU_Size3Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR4"))
LM_EUREU_Size3Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR5"))

LM_EUREU_Size4Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR1"))
LM_EUREU_Size4Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR2"))
LM_EUREU_Size4Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR3"))
LM_EUREU_Size4Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR4"))
LM_EUREU_Size4Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR5")) 

LM_EUREU_Size5Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "BIG LoPRIOR"))
LM_EUREU_Size5Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME5 PRIOR2"))
LM_EUREU_Size5Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME5 PRIOR3"))
LM_EUREU_Size5Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME5 PRIOR4"))
LM_EUREU_Size5Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "BIG HiPRIOR"))

#Make table of estimates
b_EUREU <- matrix(c(LM_EUREU_Size1Mom1$coefficients[2], LM_EUREU_Size1Mom2$coefficients[2], LM_EUREU_Size1Mom3$coefficients[2], LM_EUREU_Size1Mom4$coefficients[2], LM_EUREU_Size1Mom5$coefficients[2],
                    LM_EUREU_Size2Mom1$coefficients[2], LM_EUREU_Size2Mom2$coefficients[2], LM_EUREU_Size2Mom3$coefficients[2], LM_EUREU_Size2Mom4$coefficients[2], LM_EUREU_Size2Mom5$coefficients[2],
                    LM_EUREU_Size3Mom1$coefficients[2], LM_EUREU_Size3Mom2$coefficients[2], LM_EUREU_Size3Mom3$coefficients[2], LM_EUREU_Size3Mom4$coefficients[2], LM_EUREU_Size3Mom5$coefficients[2],
                    LM_EUREU_Size4Mom1$coefficients[2], LM_EUREU_Size4Mom2$coefficients[2], LM_EUREU_Size4Mom3$coefficients[2], LM_EUREU_Size4Mom4$coefficients[2], LM_EUREU_Size4Mom5$coefficients[2],
                    LM_EUREU_Size5Mom1$coefficients[2], LM_EUREU_Size5Mom2$coefficients[2], LM_EUREU_Size5Mom3$coefficients[2], LM_EUREU_Size5Mom4$coefficients[2], LM_EUREU_Size5Mom5$coefficients[2]),
                  nrow = 5, byrow = TRUE)
colnames(b_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(b_EUREU) <- c("Small", "2", "3", "4", "Big")

s_EUREU <- matrix(c(LM_EUREU_Size1Mom1$coefficients[3], LM_EUREU_Size1Mom2$coefficients[3], LM_EUREU_Size1Mom3$coefficients[3], LM_EUREU_Size1Mom4$coefficients[3], LM_EUREU_Size1Mom5$coefficients[3],
                    LM_EUREU_Size2Mom1$coefficients[3], LM_EUREU_Size2Mom2$coefficients[3], LM_EUREU_Size2Mom3$coefficients[3], LM_EUREU_Size2Mom4$coefficients[3], LM_EUREU_Size2Mom5$coefficients[3],
                    LM_EUREU_Size3Mom1$coefficients[3], LM_EUREU_Size3Mom2$coefficients[3], LM_EUREU_Size3Mom3$coefficients[3], LM_EUREU_Size3Mom4$coefficients[3], LM_EUREU_Size3Mom5$coefficients[3],
                    LM_EUREU_Size4Mom1$coefficients[3], LM_EUREU_Size4Mom2$coefficients[3], LM_EUREU_Size4Mom3$coefficients[3], LM_EUREU_Size4Mom4$coefficients[3], LM_EUREU_Size4Mom5$coefficients[3],
                    LM_EUREU_Size5Mom1$coefficients[3], LM_EUREU_Size5Mom2$coefficients[3], LM_EUREU_Size5Mom3$coefficients[3], LM_EUREU_Size5Mom4$coefficients[3], LM_EUREU_Size5Mom5$coefficients[3]),
                  nrow = 5, byrow = TRUE)
colnames(s_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(s_EUREU) <- c("Small", "2", "3", "4", "Big")

m_EUREU <- matrix(c(LM_EUREU_Size1Mom1$coefficients[4], LM_EUREU_Size1Mom2$coefficients[4], LM_EUREU_Size1Mom3$coefficients[4], LM_EUREU_Size1Mom4$coefficients[4], LM_EUREU_Size1Mom5$coefficients[4],
                    LM_EUREU_Size2Mom1$coefficients[4], LM_EUREU_Size2Mom2$coefficients[4], LM_EUREU_Size2Mom3$coefficients[4], LM_EUREU_Size2Mom4$coefficients[4], LM_EUREU_Size2Mom5$coefficients[4],
                    LM_EUREU_Size3Mom1$coefficients[4], LM_EUREU_Size3Mom2$coefficients[4], LM_EUREU_Size3Mom3$coefficients[4], LM_EUREU_Size3Mom4$coefficients[4], LM_EUREU_Size3Mom5$coefficients[4],
                    LM_EUREU_Size4Mom1$coefficients[4], LM_EUREU_Size4Mom2$coefficients[4], LM_EUREU_Size4Mom3$coefficients[4], LM_EUREU_Size4Mom4$coefficients[4], LM_EUREU_Size4Mom5$coefficients[4],
                    LM_EUREU_Size5Mom1$coefficients[4], LM_EUREU_Size5Mom2$coefficients[4], LM_EUREU_Size5Mom3$coefficients[4], LM_EUREU_Size5Mom4$coefficients[4], LM_EUREU_Size5Mom5$coefficients[4]),
                  nrow = 5, byrow = TRUE)
colnames(m_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(m_EUREU) <- c("Small", "2", "3", "4", "Big")

tb_EUREU <- matrix(c(summary(LM_EUREU_Size1Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size1Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size1Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size1Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size1Mom5)$coefficients["Market_Excess_Return","t value"],
                     summary(LM_EUREU_Size2Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size2Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size2Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size2Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size2Mom5)$coefficients["Market_Excess_Return","t value"],
                     summary(LM_EUREU_Size3Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size3Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size3Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size3Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size3Mom5)$coefficients["Market_Excess_Return","t value"],
                     summary(LM_EUREU_Size4Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size4Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size4Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size4Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size4Mom5)$coefficients["Market_Excess_Return","t value"],
                     summary(LM_EUREU_Size5Mom1)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size5Mom2)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size5Mom3)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size5Mom4)$coefficients["Market_Excess_Return","t value"], summary(LM_EUREU_Size5Mom5)$coefficients["Market_Excess_Return","t value"]),
                   nrow = 5, byrow = TRUE)
colnames(tb_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(tb_EUREU) <- c("Small", "2", "3", "4", "Big")

ts_EUREU <- matrix(c(summary(LM_EUREU_Size1Mom1)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size1Mom2)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size1Mom3)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size1Mom4)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size1Mom5)$coefficients["SMB_EUR","t value"],
                     summary(LM_EUREU_Size2Mom1)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size2Mom2)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size2Mom3)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size2Mom4)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size2Mom5)$coefficients["SMB_EUR","t value"],
                     summary(LM_EUREU_Size3Mom1)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size3Mom2)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size3Mom3)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size3Mom4)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size3Mom5)$coefficients["SMB_EUR","t value"],
                     summary(LM_EUREU_Size4Mom1)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size4Mom2)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size4Mom3)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size4Mom4)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size4Mom5)$coefficients["SMB_EUR","t value"],
                     summary(LM_EUREU_Size5Mom1)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size5Mom2)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size5Mom3)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size5Mom4)$coefficients["SMB_EUR","t value"], summary(LM_EUREU_Size5Mom5)$coefficients["SMB_EUR","t value"]),
                   nrow = 5, byrow = TRUE)
colnames(ts_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(ts_EUREU) <- c("Small", "2", "3", "4", "Big")

tm_EUREU <- matrix(c(summary(LM_EUREU_Size1Mom1)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size1Mom2)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size1Mom3)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size1Mom4)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size1Mom5)$coefficients["MOM_EUR","t value"],
                     summary(LM_EUREU_Size2Mom1)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size2Mom2)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size2Mom3)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size2Mom4)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size2Mom5)$coefficients["MOM_EUR","t value"],
                     summary(LM_EUREU_Size3Mom1)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size3Mom2)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size3Mom3)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size3Mom4)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size3Mom5)$coefficients["MOM_EUR","t value"],
                     summary(LM_EUREU_Size4Mom1)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size4Mom2)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size4Mom3)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size4Mom4)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size4Mom5)$coefficients["MOM_EUR","t value"],
                     summary(LM_EUREU_Size5Mom1)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size5Mom2)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size5Mom3)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size5Mom4)$coefficients["MOM_EUR","t value"], summary(LM_EUREU_Size5Mom5)$coefficients["MOM_EUR","t value"]),
                   nrow = 5, byrow = TRUE)
colnames(tm_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(tm_EUREU) <- c("Small", "2", "3", "4", "Big")

r2_EUREU <- matrix(c(summary(LM_EUREU_Size1Mom1)$adj.r.squared, summary(LM_EUREU_Size1Mom2)$adj.r.squared, summary(LM_EUREU_Size1Mom3)$adj.r.squared, summary(LM_EUREU_Size1Mom4)$adj.r.squared, summary(LM_EUREU_Size1Mom5)$adj.r.squared,
                     summary(LM_EUREU_Size2Mom1)$adj.r.squared, summary(LM_EUREU_Size2Mom2)$adj.r.squared, summary(LM_EUREU_Size2Mom3)$adj.r.squared, summary(LM_EUREU_Size2Mom4)$adj.r.squared, summary(LM_EUREU_Size2Mom5)$adj.r.squared,
                     summary(LM_EUREU_Size3Mom1)$adj.r.squared, summary(LM_EUREU_Size3Mom2)$adj.r.squared, summary(LM_EUREU_Size3Mom3)$adj.r.squared, summary(LM_EUREU_Size3Mom4)$adj.r.squared, summary(LM_EUREU_Size3Mom5)$adj.r.squared,
                     summary(LM_EUREU_Size4Mom1)$adj.r.squared, summary(LM_EUREU_Size4Mom2)$adj.r.squared, summary(LM_EUREU_Size4Mom3)$adj.r.squared, summary(LM_EUREU_Size4Mom4)$adj.r.squared, summary(LM_EUREU_Size4Mom5)$adj.r.squared,
                     summary(LM_EUREU_Size5Mom1)$adj.r.squared, summary(LM_EUREU_Size5Mom2)$adj.r.squared, summary(LM_EUREU_Size5Mom3)$adj.r.squared, summary(LM_EUREU_Size5Mom4)$adj.r.squared, summary(LM_EUREU_Size5Mom5)$adj.r.squared),
                   nrow = 5, byrow = TRUE)
colnames(r2_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(r2_EUREU) <- c("Small", "2", "3", "4", "Big")

se_EUREU <- matrix(c(summary(LM_EUREU_Size1Mom1)$sigma, summary(LM_EUREU_Size1Mom2)$sigma, summary(LM_EUREU_Size1Mom3)$sigma, summary(LM_EUREU_Size1Mom4)$sigma, summary(LM_EUREU_Size1Mom5)$sigma,
                     summary(LM_EUREU_Size2Mom1)$sigma, summary(LM_EUREU_Size2Mom2)$sigma, summary(LM_EUREU_Size2Mom3)$sigma, summary(LM_EUREU_Size2Mom4)$sigma, summary(LM_EUREU_Size2Mom5)$sigma,
                     summary(LM_EUREU_Size3Mom1)$sigma, summary(LM_EUREU_Size3Mom2)$sigma, summary(LM_EUREU_Size3Mom3)$sigma, summary(LM_EUREU_Size3Mom4)$sigma, summary(LM_EUREU_Size3Mom5)$sigma,
                     summary(LM_EUREU_Size4Mom1)$sigma, summary(LM_EUREU_Size4Mom2)$sigma, summary(LM_EUREU_Size4Mom3)$sigma, summary(LM_EUREU_Size4Mom4)$sigma, summary(LM_EUREU_Size4Mom5)$sigma,
                     summary(LM_EUREU_Size5Mom1)$sigma, summary(LM_EUREU_Size5Mom2)$sigma, summary(LM_EUREU_Size5Mom3)$sigma, summary(LM_EUREU_Size5Mom4)$sigma, summary(LM_EUREU_Size5Mom5)$sigma),
                   nrow = 5, byrow = TRUE)
colnames(se_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(se_EUREU) <- c("Small", "2", "3", "4", "Big")

factors_EUR_Based_EU <- rbind(cbind(b_EUREU, tb_EUREU),
                              cbind(s_EUREU, ts_EUREU), 
                              cbind(m_EUREU, tm_EUREU), 
                              cbind(r2_EUREU, se_EUREU))

print(xtable(factors_EUR_Based_EU, digits = 2), 
      type = "latex", 
      file = "R/Output/factors_EUR_EU.tex")

writeLines(color_factor_tables(round(factors_EUR_Based_EU,2), c(98, 101.35)),
           con = "R/Output/factors_EUR_EU_colored.tex")

#The intercepts
Intercepts_EUREU <- cbind(matrix(c(summary(LM_EUREU_Size1Mom1)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size1Mom2)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size1Mom3)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size1Mom4)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size1Mom5)$coefficients["(Intercept)","Estimate"],
                          summary(LM_EUREU_Size2Mom1)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size2Mom2)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size2Mom3)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size2Mom4)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size2Mom5)$coefficients["(Intercept)","Estimate"],
                          summary(LM_EUREU_Size3Mom1)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size3Mom2)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size3Mom3)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size3Mom4)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size3Mom5)$coefficients["(Intercept)","Estimate"],
                          summary(LM_EUREU_Size4Mom1)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size4Mom2)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size4Mom3)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size4Mom4)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size4Mom5)$coefficients["(Intercept)","Estimate"],
                          summary(LM_EUREU_Size5Mom1)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size5Mom2)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size5Mom3)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size5Mom4)$coefficients["(Intercept)","Estimate"], summary(LM_EUREU_Size5Mom5)$coefficients["(Intercept)","Estimate"]),
                        nrow = 5, byrow = TRUE),
           matrix(c(summary(LM_EUREU_Size1Mom1)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size1Mom2)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size1Mom3)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size1Mom4)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size1Mom5)$coefficients["(Intercept)","t value"],
                    summary(LM_EUREU_Size2Mom1)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size2Mom2)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size2Mom3)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size2Mom4)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size2Mom5)$coefficients["(Intercept)","t value"],
                    summary(LM_EUREU_Size3Mom1)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size3Mom2)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size3Mom3)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size3Mom4)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size3Mom5)$coefficients["(Intercept)","t value"],
                    summary(LM_EUREU_Size4Mom1)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size4Mom2)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size4Mom3)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size4Mom4)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size4Mom5)$coefficients["(Intercept)","t value"],
                    summary(LM_EUREU_Size5Mom1)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size5Mom2)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size5Mom3)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size5Mom4)$coefficients["(Intercept)","t value"], summary(LM_EUREU_Size5Mom5)$coefficients["(Intercept)","t value"]),
                  nrow = 5, byrow = TRUE)
)
           

colnames(Intercepts_EUREU) <- rep(c("Low", "2", "3", "4", "High"),2)
rownames(Intercepts_EUREU) <- c("Small", "2", "3", "4", "Big")
Intercepts_EUREU




#Expected surplus and correlation of FactorPF's:

FactorPortfolios <- fama_french_portfolios %>% filter(TIME_PERIOD <= "2024-12-31", TIME_PERIOD >= "2004-09-01") %>%
  mutate(MKT = Market_Return_EUR - RF_EU,
         SMB = SMB_EUR,
         MOM = MOM_EUR,
         Tech = Tech.Stocks.EUR - RF_EU,
         SmallCap = Small.Cap.EUR - RF_EU,) %>%
  select(c(TIME_PERIOD, Region, MKT, SMB, MOM, Tech, SmallCap, RF_EU)) %>% unique() %>% pivot_wider(names_from = Region, values_from = c(MKT, SMB, MOM, Tech, SmallCap))
 

SummaryFactorPFs <- FactorPortfolios %>% pivot_longer(cols = -TIME_PERIOD, names_to = "Portfolio", values_to = "Return") %>%
  group_by(Portfolio) %>%
  summarize(Mean = mean(Return),
            Min. = min(Return),
            Q1 = quantile(Return, 0.25),
            Median = median(Return),
            Q3 = quantile(Return, 0.75),
            Max. = max(Return),
            Volatility = sd(Return)
  ) %>% mutate(Portfolio = factor(Portfolio, levels = c("MKT_EU", "MKT_US", "MOM_EU", "MOM_US", "SMB_EU", "SMB_US", "Tech_EU","Tech_US", "SmallCap_EU", "SmallCap_US", "RF_EU" ))) %>%
  arrange(Portfolio)

Mean_Vol_data <- SummaryFactorPFs %>% mutate(Portfolio = recode(Portfolio,
                                               "MKT_EU" = "EU Market",
                                               "MKT_US" = "US Market ",
                                               "MOM_EU" = "EU MOM",
                                               "MOM_US" = "US MOM",
                                               "SMB_EU" = "EU SMB",
                                               "SMB_US" = "US SMB",
                                               "Tech_EU" = "EU Tech",
                                               "Tech_US" = "US Tech",
                                               "SmallCap_EU" = "EU Small Cap",
                                               "SmallCap_US" = "US Small Cap",
                                               "RF_EU" = "Risk-free")) %>% select(Portfolio, Mean, Volatility)

Mean_Vol_plot <- Mean_Vol_data %>% 
  ggplot(aes(x = Volatility, y = Mean, label = Portfolio)) +
  geom_point() + geom_smooth(method = "lm",
                             formula = y ~ 0 + x,   # force intercept = 0
                             se = FALSE,
                             color = "gray77") + 
  geom_text(vjust = -0.5, hjust = 0.5) + xlim(-.3,7) + ylim(-.05,1.1) + 
  labs(title = "Portfolios: Mean vs. Volatility",
       x = "Volatility",
       y = "Mean Return") + theme_bw()




saveFig(Mean_Vol_plot, "R/Output/Mean_Vol_FactorPortfolios.pdf", width = 10, height = 6)

Mean_Vol_table <- Mean_Vol_data %>%
  pivot_longer(cols = c(Mean, Volatility), names_to = " ", values_to = "Value") %>%
  pivot_wider(names_from = Portfolio, values_from = Value)



Mean_Vol_plot_with_table <- gridExtra::grid.arrange(
  Mean_Vol_plot,
  gridExtra::tableGrob(
    Mean_Vol_data %>%
      mutate(Mean = paste0(round(Mean, 2), "%"),
             Volatility = round(Volatility,2)) %>% select(Portfolio, "Mean Return" = Mean, Volatility) %>%  # format as %
      tibble::column_to_rownames("Portfolio") %>%
      t() %>%
      as.data.frame() %>%
      tibble::rownames_to_column(" ") ,
    rows = NULL,
    theme = gridExtra::ttheme_default(
      core = list(fg_params = list(cex = 0.8)),
      colhead = list(fg_params = list(cex = 0.9, fontface = "bold"))
    )
  ),
  ncol = 1,
  heights = c(3, 0.8)  # Adjust the relative space for plot vs. table
)




Mean_Vol_table %>%
  xtable(digits = c(0, rep(2, ncol(Mean_Vol_table)))) %>% 
  print(type = "latex",
        file = "R/Output/Mean_Vol_FactorPortfolios.tex",
        include.rownames = FALSE,
        include.colnames = TRUE)


cov_factorportfolios <- cov(FactorPortfolios %>% select(-TIME_PERIOD, -RF_EU))
round(cov_factorportfolios,2)

MKT_SMB_MOM_corplot <- cor(FactorPortfolios %>% select(c("EU Market" = MKT_EU,
                                  "US Market" = MKT_US,
                                  "EU SMB" = SMB_EU,
                                  "US SMB" = SMB_US,
                                  "EU MOM" = MOM_EU, 
                                  "US MOM" = MOM_US)) , method = "spearman") %>%
  corrplot(method = "color",
           tl.col = "black",    # label color
           tl.srt = 45,         # label rotation
           addCoef.col = "black")


MKT_TECH_SMALL_corplot <- cor(FactorPortfolios %>% select(c("EU Market" = MKT_EU,
                                  "US Market" = MKT_US,
                                  "EU Tech" = Tech_EU,
                                  "US Tech" = Tech_US,
                                  "EU Small Cap" = SmallCap_EU, 
                                  "US Small Cap" = SmallCap_US)) , method = "spearman") %>%
  corrplot(method = "color",
           tl.col = "black",    # label color
           tl.srt = 45,         # label rotation
           addCoef.col = "black")





# before shorting restriction: MKT_US and MOM_EU
round(cov(FactorPortfolios %>% select(MKT_US, MOM_EU)),2)
round(colMeans(FactorPortfolios %>% select(MKT_US, MOM_EU)),2)

summary(FactorPortfolios %>% select(-TIME_PERIOD))

SummaryFactorPFs %>%
  mutate(Portfolio = recode(Portfolio,
                            "MKT_EU" = "European Market Excess",
                            "MKT_US" = "US Market Excess ",
                            "MOM_EU" = "European MOM",
                            "MOM_US" = "US MOM",
                            "SMB_EU" = "European SMB",
                            "SMB_US" = "US SMB",
                            "Tech_EU" = "European Tech Stocks Excess",
                            "Tech_US" = "US Tech Stocks Excess",
                            "SmallCap_EU" = "European Small Cap Excess",
                            "SmallCap_US" = "US Small Cap Excess",
                            "RF_EU" = "Risk-free")) %>%
  xtable(digits = 2) %>% 
  print(type = "latex", file = "R/Output/SummaryFactorPFs.tex", include.rownames = FALSE)




# Tech-stock and Small-cap

LongPortfolios <- fama_french_portfolios %>% filter(TIME_PERIOD <= "2024-12-31", TIME_PERIOD >= "2004-09-01") %>%
  select(c(TIME_PERIOD, Region, Market_Return_EUR, Small.Cap.EUR, Tech.Stocks.EUR, RF_EU)) %>% unique() %>% pivot_wider(names_from = Region, values_from = c(Market_Return_EUR, Small.Cap.EUR, Tech.Stocks.EUR)) %>%
  mutate(MR_US_excess = Market_Return_EUR_US - RF_EU,
         MR_EU_excess = Market_Return_EUR_EU - RF_EU,
         SC_US_excess = Small.Cap.EUR_US - RF_EU,
         SC_EU_excess = Small.Cap.EUR_EU - RF_EU,
         TS_US_excess = Tech.Stocks.EUR_US - RF_EU,
         TS_EU_excess = Tech.Stocks.EUR_EU - RF_EU) %>% 
  select(c(TIME_PERIOD, MR_US_excess, MR_EU_excess, SC_US_excess, SC_EU_excess, TS_US_excess, TS_EU_excess, RF_EU))


cov_longportfolios <- cov(LongPortfolios %>% select(c(MR_US_excess, TS_US_excess, MR_EU_excess, TS_EU_excess)))
round(cov_longportfolios,2)

cor(LongPortfolios %>% select(-TIME_PERIOD, -RF_EU) , method = "spearman") %>%
  corrplot(method = "color",
           tl.col = "black",    # label color
           tl.srt = 45,         # label rotation
           addCoef.col = "black")


round(colMeans(LongPortfolios %>% select(-TIME_PERIOD)),4)

round(colMeans(LongPortfolios %>% select(c(MR_US_excess, TS_US_excess, MR_EU_excess, TS_EU_excess))),2)



## Mean variance optimization (1d):

Rolling3yrMean <- list()
Rolling3yrCov <- list()

(FactorPortfolios %>% select(TIME_PERIOD, MKT_US, MOM_EU))[37:244,]

for (i in 37:nrow(FactorPortfolios)){ 
  
  Rolling3yrMean[[i]] <- colMeans((FactorPortfolios %>% select(MKT_US, MOM_EU))[(i-36):(i-1),])
  Rolling3yrCov[[i]] <- cov((FactorPortfolios %>% select(MKT_US, MOM_EU))[(i-36):(i-1),])
  
}

Rolling3yrMean <- as.data.frame(do.call(rbind, Rolling3yrMean), FactorPortfolios$TIME_PERIOD[37:nrow(FactorPortfolios)]) 

Rolling3yrMean %>% mutate(Largest = ifelse(MKT_US > MOM_EU, "MKT_US", "MOM_EU"))








