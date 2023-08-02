## ----opts-set, echo=FALSE-----------------------
library(knitr)
opts_knit$set(global.par = TRUE)
# add path to graphics 
#wdir<-'/Users/crossh/repos/NEON-Data-Skills/tutorials-in-development/NMDC_NEON_Workshop_ESA2023'
#setwd('/Users/crossh/repos/NEON-Data-Skills/tutorials-in-development/NMDC_NEON_Workshop_ESA2023')
#myPathToGraphics <- paste(wdir,'graphics', sep='/')



## ----packages, eval=FALSE-----------------------
## 
## install.packages("neonUtilities")
## install.packages("neonOS")
## install.packages("tidyverse")
## 


## ----access soil data, eval=FALSE---------------
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


## ----viewSoilChem, eval=FALSE-------------------
## View(soilChem$sls_soilChemistry)


## ----checkMetaPool, eval=FALSE------------------
## View(soilChem$sls_metagenomicsPooling)


## ----poolListEx, eval=FALSE---------------------
## soilChem$sls_metagenomicsPooling$genomicsPooledIDList[11]
## # you can check to confirm the first sample is TOOL_043-O-20170719-COMP
## soilChem$sls_metagenomicsPooling[11,'genomicsSampleID']
## 
## 


## ----link1sample, eval=FALSE--------------------
## library(tidyverse)
## 
## View(soilChem$sls_soilChemistry %>%
##   filter(sampleID == "TOOL_043-O-5-7-20170719") %>%
##   select(sampleID,d15N,organicd13C,CNratio))
## 


## ----splitPool, eval=FALSE----------------------
## # split up the pooled list into new columns
## genomicSamples <- soilChem$sls_metagenomicsPooling %>%
##   tidyr::separate(genomicsPooledIDList, into=c("first","second","third"),sep="\\|",fill="right") %>%
##   dplyr::select(genomicsSampleID,first,second,third)
## # now view the table
## View(genomicSamples)


## ----pivotTable, eval=FALSE---------------------
## genSampleExample <- genomicSamples %>%
##   tidyr::pivot_longer(cols=c("first","second","third"),values_to = "sampleID") %>%
##   dplyr::select(sampleID,genomicsSampleID) %>%
##   drop_na()
## # now view
## View(genSampleExample)


## ----combTab, eval=FALSE------------------------
## chemEx <- soilChem$sls_soilChemistry %>%
##   dplyr::select(sampleID,d15N,organicd13C,nitrogenPercent,organicCPercent)
## 
## ## now combine the tables
## combinedTab <- left_join(genSampleExample,chemEx, by = "sampleID") %>% drop_na()
## 
## View(combinedTab)
## 


## ----avgChem, eval=FALSE------------------------
## genome_groups <- combinedTab %>%
##   group_by(genomicsSampleID) %>%
##   summarize_at(c("d15N","organicd13C","nitrogenPercent","organicCPercent"), mean)
## 
## View(genome_groups)


## ----pHmeanTab, eval=FALSE----------------------
## soilpH_Example <- soilChem$sls_soilpH %>%
##   dplyr::filter(sampleID %in% combinedTab$sampleID) %>%
##   dplyr::select(sampleID,soilInWaterpH,soilInCaClpH)
## 
## # have a look at this table
## View(soilpH_Example)
## # now join with the existing table
## combinedTab_pH <- left_join(combinedTab,soilpH_Example, by = "sampleID")
## # and the final
## View(combinedTab_pH)
## 


## ----pHmean, eval=FALSE-------------------------
## library(respirometry)
## 
## genome_groups_pH <- combinedTab_pH %>%
##   group_by(genomicsSampleID) %>%
##   summarize_at(c("soilInWaterpH","soilInCaClpH"), mean_pH)
## 
## View(genome_groups_pH)


## ----multimeans, eval=FALSE---------------------
## genome_groups_all <- combinedTab_pH %>%
##   group_by(genomicsSampleID) %>%
##   {left_join(
##     summarize_at(.,vars("d15N","organicd13C","nitrogenPercent","organicCPercent"), mean),
##     summarize_at(.,vars("soilInWaterpH","soilInCaClpH"), mean_pH)
##   )}
## 
## 
## View(genome_groups_all)
## 


## ----dwnRawGet, eval=FALSE----------------------
## library(neonUtilities)
## library(dplyr)
## 
## #specify sites and/or date ranges depending on your research questions
## metaGdata <- loadByProduct(dpID = 'DP1.10107.001',
##                           startdate = "2018-01",
##                           enddate = "2019-12",
##                           check.size = FALSE,
##                           package = 'expanded')
## 
## 


## ----dwnRawList, eval=FALSE---------------------
## rawFileInfo <- metaGdata$mms_rawDataFiles
## 
## urls_fordownload <- unique(rawFileInfo$rawDataFilePath)
## 
## 


## ----dwnRawOptA, eval=FALSE---------------------
## # Option a, create a list of samples from earlier example
## targetsamples <- combinedTab$genomicsSampleID
## # Create a genomicsSampleID from raw files table, and then subset this to samples
## rawfiles_ids <- rawFileInfo %>%
##   mutate(genomicsSampleID = gsub("-DNA[1,2,3]","",dnaSampleID)) %>%
##   subset(genomicsSampleID %in% targetsamples) %>%
##   unique()
## 
## urls_fordownload <- unique(rawfiles_ids$rawDataFilePath)
## 


## ----dwnRawOptB, eval=FALSE---------------------
## # Option b
## urls_fordownload <- unique(rawFileInfo$rawDataFilePath)[1:20] #for instance, the first 20 rows, and so on


## ----dwnRawWrt, eval=FALSE----------------------
## #put in whatever working directory you want
## file_conn = file("./NEONmetagenome_downloadIDs.txt")
## writeLines(unlist(urls_fordownload), file_conn, sep="\n")
## close(file_conn)
## 
## 


## wget -i NEONmetagenome_downloadIDs.txt

## 

## 

