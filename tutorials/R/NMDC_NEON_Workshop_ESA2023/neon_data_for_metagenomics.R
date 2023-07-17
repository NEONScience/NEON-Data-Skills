## ----opts-set, echo=FALSE---------------
library(knitr)
opts_knit$set(global.par = TRUE)
# add path to graphics 
#wdir<-'/Users/crossh/repos/NEON-Data-Skills/tutorials-in-development/NMDC_NEON_Workshop_ESA2023'
#setwd('/Users/crossh/repos/NEON-Data-Skills/tutorials-in-development/NMDC_NEON_Workshop_ESA2023')
#myPathToGraphics <- paste(wdir,'graphics', sep='/')



## ----packages, eval=FALSE---------------
## 
## install.packages("neonUtilities")
## install.packages("neonOS")
## install.packages("tidyverse")
## 


## ----access soil data, eval=FALSE-------
## #
## library(neonUtilities)
## 
## soilTrialSites = c("HARV","SCBI","DSNY","UNDE","WREF")
## 
## soilChem2018 <- loadByProduct(
##   dpID='DP1.10086.001',
##   startdate = "2018-01",
##   enddate = "2018-12",
##   check.size = FALSE,
##   site = soilTrialSites,
##   package='expanded')
## 
## 


## ----viewSoilChem, eval=FALSE-----------
## View(soilChem2018$sls_soilChemistry)


## ----checkMetaPool, eval=FALSE----------
## View(soilChem2018$sls_metagenomicsPooling)


## ----poolListEx, eval=FALSE-------------
## soilChem2018$sls_metagenomicsPooling$genomicsPooledIDList[1]
## # you can check to confirm the first sample is HARV_033-O-20180709-COMP
## soilChem2018$sls_metagenomicsPooling[1,'genomicsSampleID']
## # then you can get the list:
## soilChem2018$sls_metagenomicsPooling[1,'genomicsPooledIDList']
## # You can also see them together:
## soilChem2018$sls_metagenomicsPooling[1,10:11]
## 
## 

