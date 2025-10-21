# USD-based US:
USD_based_US <- fama_french_portfolios %>% filter(Region == "US", N_Portfolios == 25, TIME_PERIOD <= "2024-12-31", TIME_PERIOD >= "2004-09-01") %>%
  mutate(Market_Excess_Return = Market_Return_USD - RF_US)

#MKT-only

MKT_LMSize1Mom1 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "SMALL LoPRIOR"))
MKT_LMSize1Mom2 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME1 PRIOR2"))
MKT_LMSize1Mom3 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME1 PRIOR3"))
MKT_LMSize1Mom4 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME1 PRIOR4"))
MKT_LMSize1Mom5 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "SMALL HiPRIOR"))

MKT_LMSize2Mom1 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR1"))
MKT_LMSize2Mom2 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR2"))
MKT_LMSize2Mom3 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR3"))
MKT_LMSize2Mom4 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR4"))
MKT_LMSize2Mom5 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR5"))                    

MKT_LMSize3Mom1 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR1"))
MKT_LMSize3Mom2 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR2"))
MKT_LMSize3Mom3 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR3"))
MKT_LMSize3Mom4 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR4"))
MKT_LMSize3Mom5 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR5"))

MKT_LMSize4Mom1 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR1"))
MKT_LMSize4Mom2 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR2"))
MKT_LMSize4Mom3 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR3"))
MKT_LMSize4Mom4 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR4"))
MKT_LMSize4Mom5 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR5"))

MKT_LMSize5Mom1 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "BIG LoPRIOR"))
MKT_LMSize5Mom2 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME5 PRIOR2"))
MKT_LMSize5Mom3 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME5 PRIOR3"))
MKT_LMSize5Mom4 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "ME5 PRIOR4"))
MKT_LMSize5Mom5 <- lm(Return_USD ~ offset(RF_US) + Market_Excess_Return, data = USD_based_US %>% filter(Portfolio == "BIG HiPRIOR"))

#Make table of estimates
MKT_only_b_US25 <- matrix(c(MKT_LMSize1Mom1$coefficients[2], MKT_LMSize1Mom2$coefficients[2], MKT_LMSize1Mom3$coefficients[2], MKT_LMSize1Mom4$coefficients[2], MKT_LMSize1Mom5$coefficients[2],
                   MKT_LMSize2Mom1$coefficients[2], MKT_LMSize2Mom2$coefficients[2], MKT_LMSize2Mom3$coefficients[2], MKT_LMSize2Mom4$coefficients[2], MKT_LMSize2Mom5$coefficients[2],
                   MKT_LMSize3Mom1$coefficients[2], MKT_LMSize3Mom2$coefficients[2], MKT_LMSize3Mom3$coefficients[2], MKT_LMSize3Mom4$coefficients[2], MKT_LMSize3Mom5$coefficients[2],
                   MKT_LMSize4Mom1$coefficients[2], MKT_LMSize4Mom2$coefficients[2], MKT_LMSize4Mom3$coefficients[2], MKT_LMSize4Mom4$coefficients[2], MKT_LMSize4Mom5$coefficients[2],
                   MKT_LMSize5Mom1$coefficients[2], MKT_LMSize5Mom2$coefficients[2], MKT_LMSize5Mom3$coefficients[2], MKT_LMSize5Mom4$coefficients[2], MKT_LMSize5Mom5$coefficients[2]),
                 nrow = 5, byrow = TRUE)
colnames(MKT_only_b_US25) <- c("Low", "2", "3", "4", "High")
rownames(MKT_only_b_US25) <- c("Small", "2", "3", "4", "Big")

MKT_only_tb_US25 <- matrix(c(summary(MKT_LMSize1Mom1)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize1Mom2)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize1Mom3)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize1Mom4)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize1Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(MKT_LMSize2Mom1)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize2Mom2)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize2Mom3)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize2Mom4)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize2Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(MKT_LMSize3Mom1)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize3Mom2)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize3Mom3)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize3Mom4)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize3Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(MKT_LMSize4Mom1)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize4Mom2)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize4Mom3)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize4Mom4)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize4Mom5)$coefficients["Market_Excess_Return","t value"],
                    summary(MKT_LMSize5Mom1)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize5Mom2)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize5Mom3)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize5Mom4)$coefficients["Market_Excess_Return","t value"], summary(MKT_LMSize5Mom5)$coefficients["Market_Excess_Return","t value"]),
                  nrow = 5, byrow = TRUE)
colnames(MKT_only_tb_US25) <- c("Low", "2", "3", "4", "High")
rownames(MKT_only_tb_US25) <- c("Small", "2", "3", "4", "Big")


MKT_only_r2_US25 <- matrix(c(summary(MKT_LMSize1Mom1)$adj.r.squared, summary(MKT_LMSize1Mom2)$adj.r.squared, summary(MKT_LMSize1Mom3)$adj.r.squared, summary(MKT_LMSize1Mom4)$adj.r.squared, summary(MKT_LMSize1Mom5)$adj.r.squared,
                    summary(MKT_LMSize2Mom1)$adj.r.squared, summary(MKT_LMSize2Mom2)$adj.r.squared, summary(MKT_LMSize2Mom3)$adj.r.squared, summary(MKT_LMSize2Mom4)$adj.r.squared, summary(MKT_LMSize2Mom5)$adj.r.squared,
                    summary(MKT_LMSize3Mom1)$adj.r.squared, summary(MKT_LMSize3Mom2)$adj.r.squared, summary(MKT_LMSize3Mom3)$adj.r.squared, summary(MKT_LMSize3Mom4)$adj.r.squared, summary(MKT_LMSize3Mom5)$adj.r.squared,
                    summary(MKT_LMSize4Mom1)$adj.r.squared, summary(MKT_LMSize4Mom2)$adj.r.squared, summary(MKT_LMSize4Mom3)$adj.r.squared, summary(MKT_LMSize4Mom4)$adj.r.squared, summary(MKT_LMSize4Mom5)$adj.r.squared,
                    summary(MKT_LMSize5Mom1)$adj.r.squared, summary(MKT_LMSize5Mom2)$adj.r.squared, summary(MKT_LMSize5Mom3)$adj.r.squared, summary(MKT_LMSize5Mom4)$adj.r.squared, summary(MKT_LMSize5Mom5)$adj.r.squared),
                  nrow = 5, byrow = TRUE)
colnames(MKT_only_r2_US25) <- c("Low", "2", "3", "4", "High")
rownames(MKT_only_r2_US25) <- c("Small", "2", "3", "4", "Big")

MKT_only_se_US25 <- matrix(c(summary(MKT_LMSize1Mom1)$sigma, summary(MKT_LMSize1Mom2)$sigma, summary(MKT_LMSize1Mom3)$sigma, summary(MKT_LMSize1Mom4)$sigma, summary(MKT_LMSize1Mom5)$sigma,
                    summary(MKT_LMSize2Mom1)$sigma, summary(MKT_LMSize2Mom2)$sigma, summary(MKT_LMSize2Mom3)$sigma, summary(MKT_LMSize2Mom4)$sigma, summary(MKT_LMSize2Mom5)$sigma,
                    summary(MKT_LMSize3Mom1)$sigma, summary(MKT_LMSize3Mom2)$sigma, summary(MKT_LMSize3Mom3)$sigma, summary(MKT_LMSize3Mom4)$sigma, summary(MKT_LMSize3Mom5)$sigma,
                    summary(MKT_LMSize4Mom1)$sigma, summary(MKT_LMSize4Mom2)$sigma, summary(MKT_LMSize4Mom3)$sigma, summary(MKT_LMSize4Mom4)$sigma, summary(MKT_LMSize4Mom5)$sigma,
                    summary(MKT_LMSize5Mom1)$sigma, summary(MKT_LMSize5Mom2)$sigma, summary(MKT_LMSize5Mom3)$sigma, summary(MKT_LMSize5Mom4)$sigma, summary(MKT_LMSize5Mom5)$sigma),
                  nrow = 5, byrow = TRUE)
colnames(MKT_only_se_US25) <- c("Low", "2", "3", "4", "High")
rownames(MKT_only_se_US25) <- c("Small", "2", "3", "4", "Big")

MKT_only_USD_Based_US <- rbind(cbind(MKT_only_b_US25, MKT_only_tb_US25),
                               cbind(MKT_only_r2_US25, MKT_only_se_US25))



#SMB + MOM
SM_LMSize1Mom1 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "SMALL LoPRIOR"))
SM_LMSize1Mom2 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME1 PRIOR2"))
SM_LMSize1Mom3 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME1 PRIOR3"))
SM_LMSize1Mom4 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME1 PRIOR4"))
SM_LMSize1Mom5 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "SMALL HiPRIOR"))

SM_LMSize2Mom1 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR1"))
SM_LMSize2Mom2 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR2"))
SM_LMSize2Mom3 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR3"))
SM_LMSize2Mom4 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR4"))
SM_LMSize2Mom5 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME2 PRIOR5"))                    

SM_LMSize3Mom1 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR1"))
SM_LMSize3Mom2 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR2"))
SM_LMSize3Mom3 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR3"))
SM_LMSize3Mom4 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR4"))
SM_LMSize3Mom5 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME3 PRIOR5"))

SM_LMSize4Mom1 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR1"))
SM_LMSize4Mom2 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR2"))
SM_LMSize4Mom3 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR3"))
SM_LMSize4Mom4 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR4"))
SM_LMSize4Mom5 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME4 PRIOR5"))

SM_LMSize5Mom1 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "BIG LoPRIOR"))
SM_LMSize5Mom2 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME5 PRIOR2"))
SM_LMSize5Mom3 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME5 PRIOR3"))
SM_LMSize5Mom4 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "ME5 PRIOR4"))
SM_LMSize5Mom5 <- lm(Return_USD ~ offset(RF_US) + SMB_USD + MOM_USD, data = USD_based_US %>% filter(Portfolio == "BIG HiPRIOR"))

#Make table of estimates
SM_only_s_US25 <- matrix(c(SM_LMSize1Mom1$coefficients[2], SM_LMSize1Mom2$coefficients[2], SM_LMSize1Mom3$coefficients[2], SM_LMSize1Mom4$coefficients[2], SM_LMSize1Mom5$coefficients[2],
                            SM_LMSize2Mom1$coefficients[2], SM_LMSize2Mom2$coefficients[2], SM_LMSize2Mom3$coefficients[2], SM_LMSize2Mom4$coefficients[2], SM_LMSize2Mom5$coefficients[2],
                            SM_LMSize3Mom1$coefficients[2], SM_LMSize3Mom2$coefficients[2], SM_LMSize3Mom3$coefficients[2], SM_LMSize3Mom4$coefficients[2], SM_LMSize3Mom5$coefficients[2],
                            SM_LMSize4Mom1$coefficients[2], SM_LMSize4Mom2$coefficients[2], SM_LMSize4Mom3$coefficients[2], SM_LMSize4Mom4$coefficients[2], SM_LMSize4Mom5$coefficients[2],
                            SM_LMSize5Mom1$coefficients[2], SM_LMSize5Mom2$coefficients[2], SM_LMSize5Mom3$coefficients[2], SM_LMSize5Mom4$coefficients[2], SM_LMSize5Mom5$coefficients[2]),
                          nrow = 5, byrow = TRUE)
colnames(SM_only_s_US25) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_s_US25) <- c("Small", "2", "3", "4", "Big")

SM_only_ts_US25 <- matrix(c(summary(SM_LMSize1Mom1)$coefficients["SMB_USD","t value"], summary(SM_LMSize1Mom2)$coefficients["SMB_USD","t value"], summary(SM_LMSize1Mom3)$coefficients["SMB_USD","t value"], summary(SM_LMSize1Mom4)$coefficients["SMB_USD","t value"], summary(SM_LMSize1Mom5)$coefficients["SMB_USD","t value"],
                             summary(SM_LMSize2Mom1)$coefficients["SMB_USD","t value"], summary(SM_LMSize2Mom2)$coefficients["SMB_USD","t value"], summary(SM_LMSize2Mom3)$coefficients["SMB_USD","t value"], summary(SM_LMSize2Mom4)$coefficients["SMB_USD","t value"], summary(SM_LMSize2Mom5)$coefficients["SMB_USD","t value"],
                             summary(SM_LMSize3Mom1)$coefficients["SMB_USD","t value"], summary(SM_LMSize3Mom2)$coefficients["SMB_USD","t value"], summary(SM_LMSize3Mom3)$coefficients["SMB_USD","t value"], summary(SM_LMSize3Mom4)$coefficients["SMB_USD","t value"], summary(SM_LMSize3Mom5)$coefficients["SMB_USD","t value"],
                             summary(SM_LMSize4Mom1)$coefficients["SMB_USD","t value"], summary(SM_LMSize4Mom2)$coefficients["SMB_USD","t value"], summary(SM_LMSize4Mom3)$coefficients["SMB_USD","t value"], summary(SM_LMSize4Mom4)$coefficients["SMB_USD","t value"], summary(SM_LMSize4Mom5)$coefficients["SMB_USD","t value"],
                             summary(SM_LMSize5Mom1)$coefficients["SMB_USD","t value"], summary(SM_LMSize5Mom2)$coefficients["SMB_USD","t value"], summary(SM_LMSize5Mom3)$coefficients["SMB_USD","t value"], summary(SM_LMSize5Mom4)$coefficients["SMB_USD","t value"], summary(SM_LMSize5Mom5)$coefficients["SMB_USD","t value"]),
                           nrow = 5, byrow = TRUE)
colnames(SM_only_ts_US25) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_ts_US25) <- c("Small", "2", "3", "4", "Big")

SM_only_m_US25 <- matrix(c(SM_LMSize1Mom1$coefficients[3], SM_LMSize1Mom2$coefficients[3], SM_LMSize1Mom3$coefficients[3], SM_LMSize1Mom4$coefficients[3], SM_LMSize1Mom5$coefficients[3],
                           SM_LMSize2Mom1$coefficients[3], SM_LMSize2Mom2$coefficients[3], SM_LMSize2Mom3$coefficients[3], SM_LMSize2Mom4$coefficients[3], SM_LMSize2Mom5$coefficients[3],
                           SM_LMSize3Mom1$coefficients[3], SM_LMSize3Mom2$coefficients[3], SM_LMSize3Mom3$coefficients[3], SM_LMSize3Mom4$coefficients[3], SM_LMSize3Mom5$coefficients[3],
                           SM_LMSize4Mom1$coefficients[3], SM_LMSize4Mom2$coefficients[3], SM_LMSize4Mom3$coefficients[3], SM_LMSize4Mom4$coefficients[3], SM_LMSize4Mom5$coefficients[3],
                           SM_LMSize5Mom1$coefficients[3], SM_LMSize5Mom2$coefficients[3], SM_LMSize5Mom3$coefficients[3], SM_LMSize5Mom4$coefficients[3], SM_LMSize5Mom5$coefficients[3]),
                         nrow = 5, byrow = TRUE)
colnames(SM_only_m_US25) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_m_US25) <- c("Small", "2", "3", "4", "Big")

SM_only_tm_US25 <- matrix(c(summary(SM_LMSize1Mom1)$coefficients["MOM_USD","t value"], summary(SM_LMSize1Mom2)$coefficients["MOM_USD","t value"], summary(SM_LMSize1Mom3)$coefficients["MOM_USD","t value"], summary(SM_LMSize1Mom4)$coefficients["MOM_USD","t value"], summary(SM_LMSize1Mom5)$coefficients["MOM_USD","t value"],
                           summary(SM_LMSize2Mom1)$coefficients["MOM_USD","t value"], summary(SM_LMSize2Mom2)$coefficients["MOM_USD","t value"], summary(SM_LMSize2Mom3)$coefficients["MOM_USD","t value"], summary(SM_LMSize2Mom4)$coefficients["MOM_USD","t value"], summary(SM_LMSize2Mom5)$coefficients["MOM_USD","t value"],
                           summary(SM_LMSize3Mom1)$coefficients["MOM_USD","t value"], summary(SM_LMSize3Mom2)$coefficients["MOM_USD","t value"], summary(SM_LMSize3Mom3)$coefficients["MOM_USD","t value"], summary(SM_LMSize3Mom4)$coefficients["MOM_USD","t value"], summary(SM_LMSize3Mom5)$coefficients["MOM_USD","t value"],
                           summary(SM_LMSize4Mom1)$coefficients["MOM_USD","t value"], summary(SM_LMSize4Mom2)$coefficients["MOM_USD","t value"], summary(SM_LMSize4Mom3)$coefficients["MOM_USD","t value"], summary(SM_LMSize4Mom4)$coefficients["MOM_USD","t value"], summary(SM_LMSize4Mom5)$coefficients["MOM_USD","t value"],
                           summary(SM_LMSize5Mom1)$coefficients["MOM_USD","t value"], summary(SM_LMSize5Mom2)$coefficients["MOM_USD","t value"], summary(SM_LMSize5Mom3)$coefficients["MOM_USD","t value"], summary(SM_LMSize5Mom4)$coefficients["MOM_USD","t value"], summary(SM_LMSize5Mom5)$coefficients["MOM_USD","t value"]),
                         nrow = 5, byrow = TRUE)
colnames(SM_only_tm_US25) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_tm_US25) <- c("Small", "2", "3", "4", "Big")


SM_only_r2_US25 <- matrix(c(summary(SM_LMSize1Mom1)$adj.r.squared, summary(SM_LMSize1Mom2)$adj.r.squared, summary(SM_LMSize1Mom3)$adj.r.squared, summary(SM_LMSize1Mom4)$adj.r.squared, summary(SM_LMSize1Mom5)$adj.r.squared,
                             summary(SM_LMSize2Mom1)$adj.r.squared, summary(SM_LMSize2Mom2)$adj.r.squared, summary(SM_LMSize2Mom3)$adj.r.squared, summary(SM_LMSize2Mom4)$adj.r.squared, summary(SM_LMSize2Mom5)$adj.r.squared,
                             summary(SM_LMSize3Mom1)$adj.r.squared, summary(SM_LMSize3Mom2)$adj.r.squared, summary(SM_LMSize3Mom3)$adj.r.squared, summary(SM_LMSize3Mom4)$adj.r.squared, summary(SM_LMSize3Mom5)$adj.r.squared,
                             summary(SM_LMSize4Mom1)$adj.r.squared, summary(SM_LMSize4Mom2)$adj.r.squared, summary(SM_LMSize4Mom3)$adj.r.squared, summary(SM_LMSize4Mom4)$adj.r.squared, summary(SM_LMSize4Mom5)$adj.r.squared,
                             summary(SM_LMSize5Mom1)$adj.r.squared, summary(SM_LMSize5Mom2)$adj.r.squared, summary(SM_LMSize5Mom3)$adj.r.squared, summary(SM_LMSize5Mom4)$adj.r.squared, summary(SM_LMSize5Mom5)$adj.r.squared),
                           nrow = 5, byrow = TRUE)
colnames(SM_only_r2_US25) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_r2_US25) <- c("Small", "2", "3", "4", "Big")

SM_only_se_US25 <- matrix(c(summary(SM_LMSize1Mom1)$sigma, summary(SM_LMSize1Mom2)$sigma, summary(SM_LMSize1Mom3)$sigma, summary(SM_LMSize1Mom4)$sigma, summary(SM_LMSize1Mom5)$sigma,
                             summary(SM_LMSize2Mom1)$sigma, summary(SM_LMSize2Mom2)$sigma, summary(SM_LMSize2Mom3)$sigma, summary(SM_LMSize2Mom4)$sigma, summary(SM_LMSize2Mom5)$sigma,
                             summary(SM_LMSize3Mom1)$sigma, summary(SM_LMSize3Mom2)$sigma, summary(SM_LMSize3Mom3)$sigma, summary(SM_LMSize3Mom4)$sigma, summary(SM_LMSize3Mom5)$sigma,
                             summary(SM_LMSize4Mom1)$sigma, summary(SM_LMSize4Mom2)$sigma, summary(SM_LMSize4Mom3)$sigma, summary(SM_LMSize4Mom4)$sigma, summary(SM_LMSize4Mom5)$sigma,
                             summary(SM_LMSize5Mom1)$sigma, summary(SM_LMSize5Mom2)$sigma, summary(SM_LMSize5Mom3)$sigma, summary(SM_LMSize5Mom4)$sigma, summary(SM_LMSize5Mom5)$sigma),
                           nrow = 5, byrow = TRUE)
colnames(SM_only_se_US25) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_se_US25) <- c("Small", "2", "3", "4", "Big")

SM_only_USD_Based_US <- rbind(cbind(SM_only_s_US25, SM_only_ts_US25),
                              cbind(SM_only_m_US25, SM_only_tm_US25),
                               cbind(SM_only_r2_US25, SM_only_se_US25))


#MKT + SMB + MOM

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


MKT_only_USD_Based_US
SM_only_USD_Based_US
factors_USD_Based_US


round(cbind(MKT_only_r2_US25, SM_only_r2_US25, r2_US25),2) %>% xtable() %>% print(include.rownames=TRUE, file = "Output/USD_Based_US_R2.tex")
