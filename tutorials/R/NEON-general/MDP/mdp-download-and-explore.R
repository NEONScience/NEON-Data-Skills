## ----package-load----------------------------------------------------------------------------------------------------

library(neonUtilities)
library(neonMDP)
library(googleCloudStorageR)



## ----set-wd, eval=FALSE----------------------------------------------------------------------------------------------
# 
# setwd("~/data/NEON/MDP")
# 


## ----setup, include=FALSE--------------------------------------------------------------------------------------------

knitr::opts_knit$set(root.dir = "/Users/clunch/data/MDP")



## ----download-is-data, eval=FALSE------------------------------------------------------------------------------------
# 
# setGcsEnv(bucket='neon-rss-md04')
# downloadMDP('Publication')
# 


## ----stack-is-data, results="hide", message=FALSE--------------------------------------------------------------------

# Single-aspirated Air Temperature
saat <- stackFromStore(dpID='DP1.00002.001', 
                       filepaths=getwd(), 
                       site='all',
                       startdate=NA, enddate=NA, 
                       package='expanded')

# Relative Humidity
rh <- stackFromStore(dpID='DP1.00098.001', 
                     filepaths=getwd(), 
                     site='all',
                     startdate=NA, enddate=NA, 
                     package='basic')

# Water Quality
wq <- stackFromStore(dpID='DP1.20288.001', 
                     filepaths=getwd(), 
                     site='all',
                     startdate=NA, enddate=NA, 
                     package='expanded')



## ----list-is-data----------------------------------------------------------------------------------------------------

# 30-minute single-aspirated air temperature (1st 10 rows & columns)
saat$SAAT_30min[1:10,1:10]

# variable descriptions for the single-aspirated air temperature data
saat$variables_00002[1:10,]



## ----download-sae-data, eval=FALSE-----------------------------------------------------------------------------------
# 
# setGcsEnv(bucket='neon-rss-md04')
# downloadMDP('ods/dataproducts/DP4')
# 


## ----stack-sae-data, results="hide", message=FALSE, warning=FALSE----------------------------------------------------

# NSAE data
flux <- stackFromStore(dpID='DP4.00200.001', 
                       filepaths=paste(getwd(), 'ods', sep='/'), 
                       site='all', startdate=NA, enddate=NA, 
                       package='basic', level='dp04')

# CO2 isotope data
iso <- stackFromStore(dpID='DP4.00200.001', 
                      filepaths=paste(getwd(), 'ods', sep='/'), 
                      site='all', startdate=NA, enddate=NA, 
                      package='basic', level='dp01', 
                      timeIndex=30, var='dlta13CCo2')



## ----list-sae-data---------------------------------------------------------------------------------------------------

# flux data variables (1st 10 rows)
flux$variables[1:10,]

# CO2 isotope data (1st 10 rows & columns)
iso$MD04[1:10,1:10]



## ----download-new-data, eval=FALSE-----------------------------------------------------------------------------------
# 
# setGcsEnv(bucket='neon-rss-md04')
# updateMDP('Publication')
# updateMDP('ods/dataproducts/DP4')
# 


## ----write-is-to-csv-------------------------------------------------------------------------------------------------

write.csv(saat$SAAT_30min, 
          file="SAAT_30min_stacked.csv", 
          row.names=F)



## ----write-sae-to-csv------------------------------------------------------------------------------------------------

write.csv(iso$MD04, 
          file="co2_isotopes_30min_stacked.csv", 
          row.names=F)


