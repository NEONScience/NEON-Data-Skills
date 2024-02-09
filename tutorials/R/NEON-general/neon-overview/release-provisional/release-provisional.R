## ----setup, eval=FALSE-----------------------------------------------------------------------------
## 
## # install packages. can skip this step if
## # the packages are already installed
## install.packages("neonUtilities")
## 
## # load packages
## library(neonUtilities)
## library(ggplot2)
## 
## # set working directory
## # modify for your computer
## setwd("~/data")
## 


## ----libraries, include=FALSE----------------------------------------------------------------------
library(neonUtilities)
library(ggplot2)


## ----load-data, results="hide"---------------------------------------------------------------------

qpr <- loadByProduct(dpID="DP1.00066.001", 
                     site=c("HEAL", "GUAN"),
                     startdate="2023-01",
                     enddate="2023-12",
                     check.size=F)



## ----plot-release----------------------------------------------------------------------------------

gg <- ggplot(qpr$PARQL_30min, 
             aes(endDateTime, linePARMean)) +
  geom_line() +
  facet_wrap(~siteID)
gg



## ----load-prov, results="hide"---------------------------------------------------------------------

qpr <- loadByProduct(dpID="DP1.00066.001", 
                     site=c("HEAL", "GUAN"),
                     startdate="2023-01",
                     enddate="2023-12",
                     include.provisional=T,
                     check.size=F)



## ----plot-all--------------------------------------------------------------------------------------

gg <- ggplot(qpr$PARQL_30min, 
             aes(endDateTime, linePARMean)) +
  geom_line() +
  facet_wrap(~siteID)
gg



## ----plot-all-quality------------------------------------------------------------------------------

gg <- ggplot(qpr$PARQL_30min[which(qpr$PARQL_30min$horizontalPosition=="001"),], 
             aes(endDateTime, linePARMean)) +
  geom_line() +
  facet_wrap(~siteID) + 
  geom_rug(data=qpr$PARQL_30min[which(qpr$PARQL_30min$horizontalPosition=="001" 
                                      & qpr$PARQL_30min$finalQF==1),], 
             color="red", sides="b")
gg



## ----cite-prov-------------------------------------------------------------------------------------

writeLines(qpr$citation_00066_PROVISIONAL)



## ----cite-rel--------------------------------------------------------------------------------------

writeLines(qpr$`citation_00066_RELEASE-2024`)



## ----load-tick-data, results="hide"----------------------------------------------------------------

tick <- loadByProduct(dpID="DP1.10093.001", 
                     site=c("GUAN"),
                     release="RELEASE-2024",
                     check.size=F)

saveRDS(tick, paste0(getwd(), "/NEON_tick_data.rds"))



## ----reload-tick-data, results="hide"--------------------------------------------------------------

tick <- readRDS(paste0(getwd(), "/NEON_tick_data.rds"))



## ----download-sae, results="hide"------------------------------------------------------------------

zipsByProduct(dpID="DP4.00200.001", 
              site=c("TEAK"),
              startdate="2023-05",
              enddate="2023-06",
              release="RELEASE-2024",
              savepath=getwd(),
              check.size=F)

flux <- stackEddy(paste0(getwd(), "/filesToStack00200"),
                  level="dp04")



## ----stack-iso, results="hide"---------------------------------------------------------------------

iso <- stackEddy(paste0(getwd(), "/filesToStack00200"),
                level="dp01", var="isoCo2", avg=6)


