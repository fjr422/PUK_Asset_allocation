# USD-based US:
EUR_based_EU <- fama_french_portfolios %>% filter(Region == "EU", N_Portfolios == 25, TIME_PERIOD <= "2024-12-31", TIME_PERIOD >= "2004-09-01") %>%
  mutate(Market_Excess_Return = Market_Return_EUR - RF_EU)

#MKT-only

MKT_EUREU_LMSize1Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "SMALL LoPRIOR"))
MKT_EUREU_LMSize1Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME1 PRIOR2"))
MKT_EUREU_LMSize1Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME1 PRIOR3"))
MKT_EUREU_LMSize1Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME1 PRIOR4"))
MKT_EUREU_LMSize1Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "SMALL HiPRIOR"))

MKT_EUREU_LMSize2Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR1"))
MKT_EUREU_LMSize2Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR2"))
MKT_EUREU_LMSize2Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR3"))
MKT_EUREU_LMSize2Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR4"))
MKT_EUREU_LMSize2Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR5"))                    

MKT_EUREU_LMSize3Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR1"))
MKT_EUREU_LMSize3Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR2"))
MKT_EUREU_LMSize3Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR3"))
MKT_EUREU_LMSize3Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR4"))
MKT_EUREU_LMSize3Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR5"))

MKT_EUREU_LMSize4Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR1"))
MKT_EUREU_LMSize4Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR2"))
MKT_EUREU_LMSize4Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR3"))
MKT_EUREU_LMSize4Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR4"))
MKT_EUREU_LMSize4Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR5"))

MKT_EUREU_LMSize5Mom1 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "BIG LoPRIOR"))
MKT_EUREU_LMSize5Mom2 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME5 PRIOR2"))
MKT_EUREU_LMSize5Mom3 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME5 PRIOR3"))
MKT_EUREU_LMSize5Mom4 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "ME5 PRIOR4"))
MKT_EUREU_LMSize5Mom5 <- lm(Return_EUR ~ offset(RF_EU) + Market_Excess_Return, data = EUR_based_EU %>% filter(Portfolio == "BIG HiPRIOR"))

#Make table of estimates
MKT_EUREU_only_b_EUREU <- matrix(c(MKT_EUREU_LMSize1Mom1$coefficients[2], MKT_EUREU_LMSize1Mom2$coefficients[2], MKT_EUREU_LMSize1Mom3$coefficients[2], MKT_EUREU_LMSize1Mom4$coefficients[2], MKT_EUREU_LMSize1Mom5$coefficients[2],
                            MKT_EUREU_LMSize2Mom1$coefficients[2], MKT_EUREU_LMSize2Mom2$coefficients[2], MKT_EUREU_LMSize2Mom3$coefficients[2], MKT_EUREU_LMSize2Mom4$coefficients[2], MKT_EUREU_LMSize2Mom5$coefficients[2],
                            MKT_EUREU_LMSize3Mom1$coefficients[2], MKT_EUREU_LMSize3Mom2$coefficients[2], MKT_EUREU_LMSize3Mom3$coefficients[2], MKT_EUREU_LMSize3Mom4$coefficients[2], MKT_EUREU_LMSize3Mom5$coefficients[2],
                            MKT_EUREU_LMSize4Mom1$coefficients[2], MKT_EUREU_LMSize4Mom2$coefficients[2], MKT_EUREU_LMSize4Mom3$coefficients[2], MKT_EUREU_LMSize4Mom4$coefficients[2], MKT_EUREU_LMSize4Mom5$coefficients[2],
                            MKT_EUREU_LMSize5Mom1$coefficients[2], MKT_EUREU_LMSize5Mom2$coefficients[2], MKT_EUREU_LMSize5Mom3$coefficients[2], MKT_EUREU_LMSize5Mom4$coefficients[2], MKT_EUREU_LMSize5Mom5$coefficients[2]),
                          nrow = 5, byrow = TRUE)
colnames(MKT_EUREU_only_b_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(MKT_EUREU_only_b_EUREU) <- c("Small", "2", "3", "4", "Big")

MKT_EUREU_only_tb_EUREU <- matrix(c(summary(MKT_EUREU_LMSize1Mom1)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize1Mom2)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize1Mom3)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize1Mom4)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize1Mom5)$coefficients["Market_Excess_Return","t value"],
                             summary(MKT_EUREU_LMSize2Mom1)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize2Mom2)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize2Mom3)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize2Mom4)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize2Mom5)$coefficients["Market_Excess_Return","t value"],
                             summary(MKT_EUREU_LMSize3Mom1)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize3Mom2)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize3Mom3)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize3Mom4)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize3Mom5)$coefficients["Market_Excess_Return","t value"],
                             summary(MKT_EUREU_LMSize4Mom1)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize4Mom2)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize4Mom3)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize4Mom4)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize4Mom5)$coefficients["Market_Excess_Return","t value"],
                             summary(MKT_EUREU_LMSize5Mom1)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize5Mom2)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize5Mom3)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize5Mom4)$coefficients["Market_Excess_Return","t value"], summary(MKT_EUREU_LMSize5Mom5)$coefficients["Market_Excess_Return","t value"]),
                           nrow = 5, byrow = TRUE)
colnames(MKT_EUREU_only_tb_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(MKT_EUREU_only_tb_EUREU) <- c("Small", "2", "3", "4", "Big")


MKT_EUREU_only_r2_EUREU <- matrix(c(summary(MKT_EUREU_LMSize1Mom1)$adj.r.squared, summary(MKT_EUREU_LMSize1Mom2)$adj.r.squared, summary(MKT_EUREU_LMSize1Mom3)$adj.r.squared, summary(MKT_EUREU_LMSize1Mom4)$adj.r.squared, summary(MKT_EUREU_LMSize1Mom5)$adj.r.squared,
                             summary(MKT_EUREU_LMSize2Mom1)$adj.r.squared, summary(MKT_EUREU_LMSize2Mom2)$adj.r.squared, summary(MKT_EUREU_LMSize2Mom3)$adj.r.squared, summary(MKT_EUREU_LMSize2Mom4)$adj.r.squared, summary(MKT_EUREU_LMSize2Mom5)$adj.r.squared,
                             summary(MKT_EUREU_LMSize3Mom1)$adj.r.squared, summary(MKT_EUREU_LMSize3Mom2)$adj.r.squared, summary(MKT_EUREU_LMSize3Mom3)$adj.r.squared, summary(MKT_EUREU_LMSize3Mom4)$adj.r.squared, summary(MKT_EUREU_LMSize3Mom5)$adj.r.squared,
                             summary(MKT_EUREU_LMSize4Mom1)$adj.r.squared, summary(MKT_EUREU_LMSize4Mom2)$adj.r.squared, summary(MKT_EUREU_LMSize4Mom3)$adj.r.squared, summary(MKT_EUREU_LMSize4Mom4)$adj.r.squared, summary(MKT_EUREU_LMSize4Mom5)$adj.r.squared,
                             summary(MKT_EUREU_LMSize5Mom1)$adj.r.squared, summary(MKT_EUREU_LMSize5Mom2)$adj.r.squared, summary(MKT_EUREU_LMSize5Mom3)$adj.r.squared, summary(MKT_EUREU_LMSize5Mom4)$adj.r.squared, summary(MKT_EUREU_LMSize5Mom5)$adj.r.squared),
                           nrow = 5, byrow = TRUE)
colnames(MKT_EUREU_only_r2_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(MKT_EUREU_only_r2_EUREU) <- c("Small", "2", "3", "4", "Big")

MKT_EUREU_only_se_EUREU <- matrix(c(summary(MKT_EUREU_LMSize1Mom1)$sigma, summary(MKT_EUREU_LMSize1Mom2)$sigma, summary(MKT_EUREU_LMSize1Mom3)$sigma, summary(MKT_EUREU_LMSize1Mom4)$sigma, summary(MKT_EUREU_LMSize1Mom5)$sigma,
                             summary(MKT_EUREU_LMSize2Mom1)$sigma, summary(MKT_EUREU_LMSize2Mom2)$sigma, summary(MKT_EUREU_LMSize2Mom3)$sigma, summary(MKT_EUREU_LMSize2Mom4)$sigma, summary(MKT_EUREU_LMSize2Mom5)$sigma,
                             summary(MKT_EUREU_LMSize3Mom1)$sigma, summary(MKT_EUREU_LMSize3Mom2)$sigma, summary(MKT_EUREU_LMSize3Mom3)$sigma, summary(MKT_EUREU_LMSize3Mom4)$sigma, summary(MKT_EUREU_LMSize3Mom5)$sigma,
                             summary(MKT_EUREU_LMSize4Mom1)$sigma, summary(MKT_EUREU_LMSize4Mom2)$sigma, summary(MKT_EUREU_LMSize4Mom3)$sigma, summary(MKT_EUREU_LMSize4Mom4)$sigma, summary(MKT_EUREU_LMSize4Mom5)$sigma,
                             summary(MKT_EUREU_LMSize5Mom1)$sigma, summary(MKT_EUREU_LMSize5Mom2)$sigma, summary(MKT_EUREU_LMSize5Mom3)$sigma, summary(MKT_EUREU_LMSize5Mom4)$sigma, summary(MKT_EUREU_LMSize5Mom5)$sigma),
                           nrow = 5, byrow = TRUE)
colnames(MKT_EUREU_only_se_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(MKT_EUREU_only_se_EUREU) <- c("Small", "2", "3", "4", "Big")

MKT_EUREU_only_EUR_based_EU <- rbind(cbind(MKT_EUREU_only_b_EUREU, MKT_EUREU_only_tb_EUREU),
                               cbind(MKT_EUREU_only_r2_EUREU, MKT_EUREU_only_se_EUREU))



#SMB + MOM
SM_EUREU_Size1Mom1 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "SMALL LoPRIOR"))
SM_EUREU_Size1Mom2 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME1 PRIOR2"))
SM_EUREU_Size1Mom3 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME1 PRIOR3"))
SM_EUREU_Size1Mom4 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME1 PRIOR4"))
SM_EUREU_Size1Mom5 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "SMALL HiPRIOR"))

SM_EUREU_Size2Mom1 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR1"))
SM_EUREU_Size2Mom2 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR2"))
SM_EUREU_Size2Mom3 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR3"))
SM_EUREU_Size2Mom4 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR4"))
SM_EUREU_Size2Mom5 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME2 PRIOR5"))                    

SM_EUREU_Size3Mom1 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR1"))
SM_EUREU_Size3Mom2 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR2"))
SM_EUREU_Size3Mom3 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR3"))
SM_EUREU_Size3Mom4 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR4"))
SM_EUREU_Size3Mom5 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME3 PRIOR5"))

SM_EUREU_Size4Mom1 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR1"))
SM_EUREU_Size4Mom2 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR2"))
SM_EUREU_Size4Mom3 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR3"))
SM_EUREU_Size4Mom4 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR4"))
SM_EUREU_Size4Mom5 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME4 PRIOR5"))

SM_EUREU_Size5Mom1 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "BIG LoPRIOR"))
SM_EUREU_Size5Mom2 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME5 PRIOR2"))
SM_EUREU_Size5Mom3 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME5 PRIOR3"))
SM_EUREU_Size5Mom4 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "ME5 PRIOR4"))
SM_EUREU_Size5Mom5 <- lm(Return_EUR ~ offset(RF_EU) + SMB_EUR + MOM_EUR, data = EUR_based_EU %>% filter(Portfolio == "BIG HiPRIOR"))

#Make table of estimates
SM_only_s_EUREU <- matrix(c(SM_EUREU_Size1Mom1$coefficients[2], SM_EUREU_Size1Mom2$coefficients[2], SM_EUREU_Size1Mom3$coefficients[2], SM_EUREU_Size1Mom4$coefficients[2], SM_EUREU_Size1Mom5$coefficients[2],
                           SM_EUREU_Size2Mom1$coefficients[2], SM_EUREU_Size2Mom2$coefficients[2], SM_EUREU_Size2Mom3$coefficients[2], SM_EUREU_Size2Mom4$coefficients[2], SM_EUREU_Size2Mom5$coefficients[2],
                           SM_EUREU_Size3Mom1$coefficients[2], SM_EUREU_Size3Mom2$coefficients[2], SM_EUREU_Size3Mom3$coefficients[2], SM_EUREU_Size3Mom4$coefficients[2], SM_EUREU_Size3Mom5$coefficients[2],
                           SM_EUREU_Size4Mom1$coefficients[2], SM_EUREU_Size4Mom2$coefficients[2], SM_EUREU_Size4Mom3$coefficients[2], SM_EUREU_Size4Mom4$coefficients[2], SM_EUREU_Size4Mom5$coefficients[2],
                           SM_EUREU_Size5Mom1$coefficients[2], SM_EUREU_Size5Mom2$coefficients[2], SM_EUREU_Size5Mom3$coefficients[2], SM_EUREU_Size5Mom4$coefficients[2], SM_EUREU_Size5Mom5$coefficients[2]),
                         nrow = 5, byrow = TRUE)
colnames(SM_only_s_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_s_EUREU) <- c("Small", "2", "3", "4", "Big")

SM_only_ts_EUREU <- matrix(c(summary(SM_EUREU_Size1Mom1)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size1Mom2)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size1Mom3)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size1Mom4)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size1Mom5)$coefficients["SMB_EUR","t value"],
                            summary(SM_EUREU_Size2Mom1)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size2Mom2)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size2Mom3)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size2Mom4)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size2Mom5)$coefficients["SMB_EUR","t value"],
                            summary(SM_EUREU_Size3Mom1)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size3Mom2)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size3Mom3)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size3Mom4)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size3Mom5)$coefficients["SMB_EUR","t value"],
                            summary(SM_EUREU_Size4Mom1)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size4Mom2)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size4Mom3)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size4Mom4)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size4Mom5)$coefficients["SMB_EUR","t value"],
                            summary(SM_EUREU_Size5Mom1)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size5Mom2)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size5Mom3)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size5Mom4)$coefficients["SMB_EUR","t value"], summary(SM_EUREU_Size5Mom5)$coefficients["SMB_EUR","t value"]),
                          nrow = 5, byrow = TRUE)
colnames(SM_only_ts_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_ts_EUREU) <- c("Small", "2", "3", "4", "Big")

SM_only_m_EUREU <- matrix(c(SM_EUREU_Size1Mom1$coefficients[3], SM_EUREU_Size1Mom2$coefficients[3], SM_EUREU_Size1Mom3$coefficients[3], SM_EUREU_Size1Mom4$coefficients[3], SM_EUREU_Size1Mom5$coefficients[3],
                           SM_EUREU_Size2Mom1$coefficients[3], SM_EUREU_Size2Mom2$coefficients[3], SM_EUREU_Size2Mom3$coefficients[3], SM_EUREU_Size2Mom4$coefficients[3], SM_EUREU_Size2Mom5$coefficients[3],
                           SM_EUREU_Size3Mom1$coefficients[3], SM_EUREU_Size3Mom2$coefficients[3], SM_EUREU_Size3Mom3$coefficients[3], SM_EUREU_Size3Mom4$coefficients[3], SM_EUREU_Size3Mom5$coefficients[3],
                           SM_EUREU_Size4Mom1$coefficients[3], SM_EUREU_Size4Mom2$coefficients[3], SM_EUREU_Size4Mom3$coefficients[3], SM_EUREU_Size4Mom4$coefficients[3], SM_EUREU_Size4Mom5$coefficients[3],
                           SM_EUREU_Size5Mom1$coefficients[3], SM_EUREU_Size5Mom2$coefficients[3], SM_EUREU_Size5Mom3$coefficients[3], SM_EUREU_Size5Mom4$coefficients[3], SM_EUREU_Size5Mom5$coefficients[3]),
                         nrow = 5, byrow = TRUE)
colnames(SM_only_m_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_m_EUREU) <- c("Small", "2", "3", "4", "Big")

SM_only_tm_EUREU <- matrix(c(summary(SM_EUREU_Size1Mom1)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size1Mom2)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size1Mom3)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size1Mom4)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size1Mom5)$coefficients["MOM_EUR","t value"],
                            summary(SM_EUREU_Size2Mom1)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size2Mom2)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size2Mom3)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size2Mom4)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size2Mom5)$coefficients["MOM_EUR","t value"],
                            summary(SM_EUREU_Size3Mom1)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size3Mom2)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size3Mom3)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size3Mom4)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size3Mom5)$coefficients["MOM_EUR","t value"],
                            summary(SM_EUREU_Size4Mom1)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size4Mom2)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size4Mom3)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size4Mom4)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size4Mom5)$coefficients["MOM_EUR","t value"],
                            summary(SM_EUREU_Size5Mom1)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size5Mom2)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size5Mom3)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size5Mom4)$coefficients["MOM_EUR","t value"], summary(SM_EUREU_Size5Mom5)$coefficients["MOM_EUR","t value"]),
                          nrow = 5, byrow = TRUE)
colnames(SM_only_tm_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_tm_EUREU) <- c("Small", "2", "3", "4", "Big")


SM_only_r2_EUREU <- matrix(c(summary(SM_EUREU_Size1Mom1)$adj.r.squared, summary(SM_EUREU_Size1Mom2)$adj.r.squared, summary(SM_EUREU_Size1Mom3)$adj.r.squared, summary(SM_EUREU_Size1Mom4)$adj.r.squared, summary(SM_EUREU_Size1Mom5)$adj.r.squared,
                            summary(SM_EUREU_Size2Mom1)$adj.r.squared, summary(SM_EUREU_Size2Mom2)$adj.r.squared, summary(SM_EUREU_Size2Mom3)$adj.r.squared, summary(SM_EUREU_Size2Mom4)$adj.r.squared, summary(SM_EUREU_Size2Mom5)$adj.r.squared,
                            summary(SM_EUREU_Size3Mom1)$adj.r.squared, summary(SM_EUREU_Size3Mom2)$adj.r.squared, summary(SM_EUREU_Size3Mom3)$adj.r.squared, summary(SM_EUREU_Size3Mom4)$adj.r.squared, summary(SM_EUREU_Size3Mom5)$adj.r.squared,
                            summary(SM_EUREU_Size4Mom1)$adj.r.squared, summary(SM_EUREU_Size4Mom2)$adj.r.squared, summary(SM_EUREU_Size4Mom3)$adj.r.squared, summary(SM_EUREU_Size4Mom4)$adj.r.squared, summary(SM_EUREU_Size4Mom5)$adj.r.squared,
                            summary(SM_EUREU_Size5Mom1)$adj.r.squared, summary(SM_EUREU_Size5Mom2)$adj.r.squared, summary(SM_EUREU_Size5Mom3)$adj.r.squared, summary(SM_EUREU_Size5Mom4)$adj.r.squared, summary(SM_EUREU_Size5Mom5)$adj.r.squared),
                          nrow = 5, byrow = TRUE)
colnames(SM_only_r2_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_r2_EUREU) <- c("Small", "2", "3", "4", "Big")

SM_only_se_EUREU <- matrix(c(summary(SM_EUREU_Size1Mom1)$sigma, summary(SM_EUREU_Size1Mom2)$sigma, summary(SM_EUREU_Size1Mom3)$sigma, summary(SM_EUREU_Size1Mom4)$sigma, summary(SM_EUREU_Size1Mom5)$sigma,
                            summary(SM_EUREU_Size2Mom1)$sigma, summary(SM_EUREU_Size2Mom2)$sigma, summary(SM_EUREU_Size2Mom3)$sigma, summary(SM_EUREU_Size2Mom4)$sigma, summary(SM_EUREU_Size2Mom5)$sigma,
                            summary(SM_EUREU_Size3Mom1)$sigma, summary(SM_EUREU_Size3Mom2)$sigma, summary(SM_EUREU_Size3Mom3)$sigma, summary(SM_EUREU_Size3Mom4)$sigma, summary(SM_EUREU_Size3Mom5)$sigma,
                            summary(SM_EUREU_Size4Mom1)$sigma, summary(SM_EUREU_Size4Mom2)$sigma, summary(SM_EUREU_Size4Mom3)$sigma, summary(SM_EUREU_Size4Mom4)$sigma, summary(SM_EUREU_Size4Mom5)$sigma,
                            summary(SM_EUREU_Size5Mom1)$sigma, summary(SM_EUREU_Size5Mom2)$sigma, summary(SM_EUREU_Size5Mom3)$sigma, summary(SM_EUREU_Size5Mom4)$sigma, summary(SM_EUREU_Size5Mom5)$sigma),
                          nrow = 5, byrow = TRUE)
colnames(SM_only_se_EUREU) <- c("Low", "2", "3", "4", "High")
rownames(SM_only_se_EUREU) <- c("Small", "2", "3", "4", "Big")

SM_only_EUR_based_EU <- rbind(cbind(SM_only_s_EUREU, SM_only_ts_EUREU),
                              cbind(SM_only_m_EUREU, SM_only_tm_EUREU),
                              cbind(SM_only_r2_EUREU, SM_only_se_EUREU))


#MKT + SMB + MOM
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


MKT_EUREU_only_EUR_based_EU
SM_only_EUR_based_EU
factors_EUR_Based_EU

round(rbind(cbind(MKT_only_r2_EURUS, SM_only_r2_EURUS,r2_EURUS),
      cbind(MKT_EUREU_only_r2_EUREU, SM_only_r2_EUREU, r2_EUREU)),2) %>% 
  xtable() %>% print(include.rownames=TRUE, file="R/Output/EUR_R2.tex")
