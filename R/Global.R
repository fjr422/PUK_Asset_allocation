packages <- c('tidyverse','reshape2', 'lattice', 'gridExtra', 'xtable', 
              'splines', 'corrplot', 'kableExtra', 'stringr')

lapply(packages, require, character.only = TRUE)

saveFig <- function(fig, filename, width = 8, height = 4) {
  pdf(filename, width = width, height = height)
  print(fig)
  dev.off()
}

qplot <- ggplot2::qplot


current_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
WD <- file.path(current_dir, "..")
setwd(WD)

  

# Data loading
  #FactorModelData
    #EU6_AvgVWR_Monthly <- read.csv("Data/EU_6PF_SIZE_MOM/AverageValueWeightedReturns_Monthly.csv")
    #EU6_NFirm <- read.csv("Data/EU_6PF_SIZE_MOM/NumberFirmsInPortfolios.csv")
    #EU6_AvgFirmSize <- read.csv("Data/EU_6PF_SIZE_MOM/AvgFirmSize.csv")
    
    #EU25_AvgVWR_Monthly <- read.csv("Data/EU_25PF_SIZE_MOM/AverageValueWeightedReturns_Monthly.csv")
    #EU25_NFirm <- read.csv("Data/EU_25PF_SIZE_MOM/NumberFirmsInPortfolios.csv")
    #EU25_AvgFirmSize <- read.csv("Data/EU_25PF_SIZE_MOM/AvgFirmSize.csv")
    
    #US6_AvgVWR_Monthly <- read.csv("Data/US_6PF_SIZE_MOM/AverageValueWeightedReturns_Monthly.csv")
    #US6_NFirm <- read.csv("Data/US_6PF_SIZE_MOM/NumberFirmsInPortfolios.csv")
    #US6_AvgFirmSize <- read.csv("Data/US_6PF_SIZE_MOM/AvgFirmSize.csv")
    
    #US25_AvgVWR_Monthly <- read.csv("Data/US_25PF_SIZE_MOM/AverageValueWeightedReturns_Monthly.csv")
    #US25_NFirm <- read.csv("Data/US_25PF_SIZE_MOM/NumberFirmsInPortfolios.csv")
    #US25_AvgFirmSize <- read.csv("Data/US_25PF_SIZE_MOM/AvgMarketCap.csv")
    
    #FF3_Factors <- read.csv("Data/F-F_Research_Data_Factors.csv")
    
    #EU6_AvgVWR_Monthly$DateID <- as.Date(paste0(EU25_AvgVWR_Monthly$DateID, "01"), format = "%Y%m%d") 
    #EU6_NFirm$DateID <- as.Date(paste0(EU25_NFirm$DateID, "01"), format = "%Y%m%d")
    #EU6_AvgFirmSize$DateID <- as.Date(paste0(EU25_AvgFirmSize$DateID, "01"), format = "%Y%m%d")
    #EU25_AvgVWR_Monthly$DateID <- as.Date(paste0(EU25_AvgVWR_Monthly$DateID, "01"), format = "%Y%m%d")
    #EU25_NFirm$DateID <- as.Date(paste0(EU25_NFirm$DateID, "01"), format = "%Y%m%d")                                      
    #EU25_AvgFirmSize$DateID <- as.Date(paste0(EU25_AvgFirmSize$DateID, "01"), format = "%Y%m%d")
    #US6_AvgVWR_Monthly$DateID <- as.Date(paste0(US6_AvgVWR_Monthly$DateID, "01"), format = "%Y%m%d")
    #US6_NFirm$DateID <- as.Date(paste0(US6_NFirm$DateID, "01"), format = "%Y%m%d")
    #US6_AvgFirmSize$DateID <- as.Date(paste0(US6_AvgFirmSize$DateID, "01"), format = "%Y%m%d")
    #US25_AvgVWR_Monthly$DateID <- as.Date(paste0(US25_AvgVWR_Monthly$DateID, "01"), format = "%Y%m%d")
    #US25_NFirm$DateID <- as.Date(paste0(US25_NFirm$DateID, "01"), format = "%Y%m%d")
    #US25_AvgFirmSize$DateID <- as.Date(paste0(US25_AvgFirmSize$DateID, "01"), format = "%Y%m%d")
    #FF3_Factors$DateId <- as.Date(paste0(FF3_Factors$DateId, "01"), format = "%Y%m%d")
    
    #save(EU6_AvgVWR_Monthly, EU6_NFirm, EU6_AvgFirmSize,
    #     EU25_AvgVWR_Monthly, EU25_NFirm, EU25_AvgFirmSize,
    #     US6_AvgVWR_Monthly, US6_NFirm, US6_AvgFirmSize,
    #     US25_AvgVWR_Monthly, US25_NFirm, US25_AvgFirmSize, FF3_Factors,
    #     file = "R/Data/FactorModelData.RData")
  
    #load("R/Data/FactorModelData.RData")
    
    #EU25 <- EU25_AvgVWR_Monthly %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "Return") %>%
    #  left_join(EU25_NFirm %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "N_Firms"), 
    #            by = c("DateID", "Portfolio")) %>%
    #  left_join(EU25_AvgFirmSize %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "Avg_FirmSize"), 
    #            by = c("DateID", "Portfolio")) %>% mutate(Division = "EU25")
    
    # EU6 <- EU6_AvgVWR_Monthly %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "Return") %>%
    #   left_join(EU6_NFirm %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "N_Firms"), 
    #             by = c("DateID", "Portfolio")) %>%
    #   left_join(EU6_AvgFirmSize %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "Avg_FirmSize"), 
    #             by = c("DateID", "Portfolio")) %>% mutate(Division = "EU6")
    
    # US25 <- US25_AvgVWR_Monthly %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "Return") %>%
    #   left_join(US25_NFirm %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "N_Firms"), 
    #             by = c("DateID", "Portfolio")) %>%
    #   left_join(US25_AvgFirmSize %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "Avg_FirmSize"), 
    #             by = c("DateID", "Portfolio")) %>% mutate(Division = "US25")  
    # 
    # US6 <- US6_AvgVWR_Monthly %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "Return") %>%
    #   left_join(US6_NFirm %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "N_Firms"), 
    #             by = c("DateID", "Portfolio")) %>%
    #   left_join(US6_AvgFirmSize %>% pivot_longer(cols = -DateID, names_to = "Portfolio", values_to = "Avg_FirmSize"), 
    #             by = c("DateID", "Portfolio")) %>% mutate(Division = "US6")
     
    #PF_Data <- rbind(EU25, EU6, US25, US6)
    
    #save(PF_Data, FF3_Factors, file = "R/Data/FactorModelData_Clean.RData")
    
    #load("R/Data/FactorModelData_Clean.RData")
    
    #PF_Data <- PF_Data %>% mutate(Region = ifelse(Division %in% c("EU25", "EU6"), "EU", "US"))
    
    
    
  #Exchange and Yield Curve Data
  
    # EUR_USD_exchange <- read.csv("Data/ForeignExchangeEuro.csv") %>% select(c("Date", "USD"))
    # EUR_USD_exchange$Date <- as.Date(as.character(EUR_USD_exchange$Date), format = "%Y-%m-%d")
    # 
    # EUR_USD_exchange <- EUR_USD_exchange[order(EUR_USD_exchange$Date), ]  # ensure ascending order
    # EUR_USD_exchange <- EUR_USD_exchange[!duplicated(format(EUR_USD_exchange$Date, "%Y-%m"), fromLast = TRUE), ]
    # 
    # EUR_USD_exchange$USD_return <- (lag(EUR_USD_exchange$USD) / (EUR_USD_exchange$USD))
    # EUR_USD_exchange$EUR_return <- 1/EUR_USD_exchange$USD_return
    # 
    # EUR_USD_exchange$EUR_return
    
    # YieldCurveData <- read.csv("Data/YieldCurveData.csv")
    # 
    # YieldCurveData2 <- YieldCurveData %>%
    #   select(c("CURRENCY", "DATA_TYPE_FM", "TIME_PERIOD", "OBS_VALUE")) %>% 
    #   pivot_wider(names_from = DATA_TYPE_FM, values_from = OBS_VALUE) %>% 
    #   select(c("CURRENCY", "TIME_PERIOD", "BETA0", "BETA1", "BETA2", "BETA3", "TAU1", "TAU2"))
    # 
    #YieldCurveData$TIME_PERIOD <- as.Date(as.character(YieldCurveData$TIME_PERIOD), format = "%Y-%m-%d")
    #write.csv(YieldCurveData, "R/Data/YieldCurveDataClean.csv", row.names = FALSE)
    # 
    # YieldCurveData <- read.csv("R/Data/YieldCurveDataClean.csv")
    # 
    # a <- YieldCurveData %>% mutate(TTM = 1/12) %>% mutate(spotrate = BETA0 + BETA1 * ((1 - exp(-TTM/TAU1)) / (TTM/TAU1)) + 
    #                                                             BETA2 * (((1 - exp(-TTM/TAU1)) / (TTM/TAU1)) - exp(-TTM/TAU1)) + 
    #                                                             BETA3 * (((1 - exp(-TTM/TAU2)) / (TTM/TAU2)) - exp(-TTM/TAU2)),
    #                                                  RF_EUR = exp(spotrate/12)-1)
    # 
    # a %>% ggplot(aes(x = as.Date(TIME_PERIOD), y = RF_EUR)) + geom_point()
  
  # Data manipulation
    # Market_Return_US <- PF_Data %>% filter(Division == "US6") %>% mutate(Market_Cap = N_Firms*Avg_FirmSize) %>% group_by(DateID) %>%
    #   mutate(Total_Market = sum(Market_Cap),
    #          weight = Market_Cap/Total_Market,
    #          Weighted_Return = weight*Return) %>% summarize(Market_Return = sum(Weighted_Return))
    # 
    # Market_Return_EU <- PF_Data %>% filter(Division == "EU6") %>% mutate(Market_Cap = N_Firms*Avg_FirmSize) %>% group_by(DateID) %>%
    #   mutate(Total_Market = sum(Market_Cap),
    #          weight = Market_Cap/Total_Market,
    #          Weighted_Return = weight*Return) %>% summarize(Market_Return = sum(Weighted_Return))
    # 
    # 
    # MOM_SMB_US <- PF_Data %>% select(-c(N_Firms, Avg_FirmSize)) %>% filter(Division == "US6") %>%
    #   pivot_wider(names_from = Portfolio, values_from = Return) %>%
    #   mutate(MOM = 1/2*(SMALL.HiPRIOR + BIG.HiPRIOR) - 1/2*(SMALL.LoPRIOR + BIG.LoPRIOR),
    #          SMB = 1/3*(SMALL.LoPRIOR + ME1.PRIOR2 + SMALL.HiPRIOR) - 1/3*(BIG.LoPRIOR + ME2.PRIOR2 + BIG.HiPRIOR))
    # 
    # view(USD_based_US %>% select(c(DateID, MOM, SMB, Market_Return, RF)) %>% filter(DateID >= "2004-09-01") %>% unique())
    # 
    # 
    # MOM_SMB_EU <- PF_Data %>% select(-c(N_Firms, Avg_FirmSize)) %>% filter(Division == "EU6") %>%
    #   pivot_wider(names_from = Portfolio, values_from = Return) %>%
    #   mutate(MOM = 1/2*(SMALL.HiPRIOR + BIG.HiPRIOR) - 1/2*(SMALL.LoPRIOR + BIG.LoPRIOR),
    #          SMB = 1/3*(SMALL.LoPRIOR + ME1.PRIOR2 + SMALL.HiPRIOR) - 1/3*(BIG.LoPRIOR + ME2.PRIOR2 + BIG.HiPRIOR))
    # 
    # 
    # 
    # Full_PF_Data <- PF_Data %>% left_join(rbind(Market_Return_US %>% mutate(Region = "US"),
    #                                         Market_Return_EU %>% mutate(Region = "EU")),
    #                                  by = c("DateID", "Region")) %>%
    #   left_join(rbind(MOM_SMB_US %>% select(c(DateID, MOM, SMB)) %>% mutate(Region = "US"),
    #                   MOM_SMB_EU %>% select(c(DateID, MOM, SMB)) %>% mutate(Region = "EU")),
    #             by = c("DateID", "Region"))
    # 
    # Full_PF_Data %>% filter(DateID >= "2007-08-01", DateID <= "2024-12-31", Division =="US6")
    # 
    # FactorModelData <- Full_PF_Data %>% filter(Division %in% c("US25","EU25"), DateID >= "2004-09-01", DateID <= "2024-12-31") %>%
    #   left_join(FF3_Factors %>% select(c("DateId", "RF")), by = c("DateID" = "DateId")) %>%
    #   mutate(Market_Excess_Return = Market_Return - RF) %>% select(-c(N_Firms, Avg_FirmSize, Region))
    # 
    
    fama_french_portfolios <- read.csv("Data/Input/fama_french_portfolios.csv")
    
    
    #Look at data
    view(fama_french_portfolios %>% filter(Region == "US", N_Portfolios == 25, Portfolio == "BIG HiPRIOR") %>%
           select(c(-Avg_FirmSize, -N_firms,-Portfolio_market_size)))
    
    
    fama_french_portfolios %>% filter(Region == "US", N_Portfolios == 25)
    
    fama_french_portfolios %>% filter(is.na(RF_EUR)) %>% select(TIME_PERIOD) %>% unique() #Der er missing values for RF_EUR in 2025
    
    
    fama_french_portfolios %>% filter(Region == "US", N_Portfolios == 6, TIME_PERIOD == "2004-09-30",
                                      Portfolio %in% c("SMALL LoPRIOR", "SMALL HiPRIOR", "ME1 PRIOR2")) %>% 
      select(Return_EUR) %>% colSums() *1/3 -
      fama_french_portfolios %>% filter(Region == "US", N_Portfolios == 6, TIME_PERIOD == "2004-09-30",
                                        Portfolio %in% c("BIG LoPRIOR", "BIG HiPRIOR", "ME2 PRIOR2")) %>% 
      select(Return_EUR) %>% colSums() *1/3
      
    
    
    
    
    
    
    
    
  
    

