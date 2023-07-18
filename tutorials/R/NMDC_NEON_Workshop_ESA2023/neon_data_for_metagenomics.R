## ----opts-set, echo=FALSE----
library(knitr)
opts_knit$set(global.par = TRUE)
# add path to graphics 
#wdir<-'/Users/crossh/repos/NEON-Data-Skills/tutorials-in-development/NMDC_NEON_Workshop_ESA2023'
#setwd('/Users/crossh/repos/NEON-Data-Skills/tutorials-in-development/NMDC_NEON_Workshop_ESA2023')
#myPathToGraphics <- paste(wdir,'graphics', sep='/')



## ----packages, eval=FALSE----
## 
## install.packages("neonUtilities")
## install.packages("neonOS")
## install.packages("tidyverse")
## 


## ----access soil data, eval=FALSE----
## library(neonUtilities)
## 
## soilTrialSites = c("BONA","DEJU","HEAL","TOOL","BARR")
## 
## soilChem <- loadByProduct(
##   dpID='DP1.10086.001',
##   startdate = "2017-01",
##   enddate = "2019-12",
##   check.size = FALSE,
##   site = soilTrialSites,
##   package='expanded')
## 
## 


## ----viewSoilChem, eval=FALSE----
## View(soilChem$sls_soilChemistry)


## ----checkMetaPool, eval=FALSE----
## View(soilChem$sls_metagenomicsPooling)


## ----poolListEx, eval=FALSE----
## soilChem$sls_metagenomicsPooling$genomicsPooledIDList[11]
## # you can check to confirm the first sample is TOOL_043-O-20170719-COMP
## soilChem$sls_metagenomicsPooling[11,'genomicsSampleID']
## # then you can get the list:
## soilChem$sls_metagenomicsPooling[11,'genomicsPooledIDList']
## 
## 
## 


## ----link1sample, eval=FALSE----
## library(tidyverse)
## 
## View(soilChem$sls_soilChemistry %>%
##   filter(sampleID == "TOOL_043-O-5-7-20170719") %>%
##   select(sampleID,d15N,organicd13C,CNratio))
## 


## ----splitPool, eval=FALSE----
## # split up the pooled list into new columns
## genomicSamples <- soilChem$sls_metagenomicsPooling %>%
##   tidyr::separate(genomicsPooledIDList, into=c("first","second","third"),sep="\\|",fill="right") %>%
##   dplyr::select(genomicsSampleID,first,second,third)
## # now view the table
## View(genomicSamples)


## ----pivotTable, eval=FALSE----
## genSampleExample <- genomicSamples %>%
##   tidyr::pivot_longer(cols=c("first","second","third"),values_to = "sampleID") %>%
##   dplyr::select(sampleID,genomicsSampleID) %>%
##   drop_na()
## # now view
## View(genSampleExample)


## ----combTab, eval=FALSE----
## chemEx <- soilChem$sls_soilChemistry %>%
##   dplyr::select(sampleID,d15N,organicd13C,nitrogenPercent,organicCPercent)
## 
## ## now combine the tables
## combinedTab <- left_join(genSampleExample,chemEx, by = "sampleID")
## 
## View(combinedTab)
## 

