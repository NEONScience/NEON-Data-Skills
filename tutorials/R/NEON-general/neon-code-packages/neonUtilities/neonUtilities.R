## ----loadStuff, eval=FALSE----------------------------------------------------------------
## # install neonUtilities - can skip if already installed
## install.packages("neonUtilities")
## # load neonUtilities
## library(neonUtilities)


## ----loadBy, eval=F-----------------------------------------------------------------------
## 
## trip.temp <- loadByProduct(dpID="DP1.00003.001",
##                            site=c("MOAB","ONAQ"),
##                            startdate="2018-05",
##                            enddate="2018-08")
## 


## ----loadBy-output, eval=F----------------------------------------------------------------
## 
## Continuing will download files totaling approximately 7.994569 MB. Do you want to proceed y/n: y
## Downloading 8 files
##   |========================================================================================================| 100%
## 
## Unpacking zip files using 1 cores.
##   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=00s
##   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=00s
## Stacking operation across a single core.
## Stacking table TAAT_1min
##   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=00s
## Stacking table TAAT_30min
##   |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=00s
## Merged the most recent publication of sensor position files for each site and saved to /stackedFiles
## Copied the most recent publication of variable definition file to /stackedFiles
## Finished: Stacked 2 data tables and 2 metadata tables!
## Stacking took 0.8517601 secs
## 


## ----loadBy-list, eval=F------------------------------------------------------------------
## 
## names(trip.temp)
## View(trip.temp$TAAT_30min)
## 


## ----env, eval=F--------------------------------------------------------------------------
## 
## list2env(trip.temp, .GlobalEnv)
## 


## ----save-files, eval=F-------------------------------------------------------------------
## 
## write.csv(TAAT_30min,
##           "~/Downloads/TAAT_30min.csv",
##           row.names=F)
## write.csv(variables_00003,
##           "~/Downloads/variables_00003.csv",
##           row.names=F)
## 


## ----run-function, eval = FALSE-----------------------------------------------------------
## # stack files - Mac OSX file path shown
## stackByTable(filepath="~neon/data/NEON_temp-air-single.zip")
## 


## ----sample-output, eval=FALSE------------------------------------------------------------
## Unpacking zip files
##   |=========================================================================================| 100%
## Stacking table SAAT_1min
##   |=========================================================================================| 100%
## Stacking table SAAT_30min
##   |=========================================================================================| 100%
## Finished: All of the data are stacked into  2  tables!
## Copied the first available variable definition file to /stackedFiles and renamed as variables.csv
## Stacked SAAT_1min which has 424800 out of the expected 424800 rows (100%).
## Stacked SAAT_30min which has 14160 out of the expected 14160 rows (100%).
## Stacking took 6.233922 secs
## All unzipped monthly data folders have been removed.


## ----readtable, eval=F--------------------------------------------------------------------
## 
## SAAT30 <- readTableNEON(
##   dataFile='~/stackedFiles/SAAT_30min.csv',
##   varFile='~/stackedFiles/variables_00002.csv'
## )
## 


## ----run-options, eval = FALSE------------------------------------------------------------
## 
## stackByTable(filepath="~neon/data/NEON_temp-air-single.zip",
##              savepath="~data/allTemperature", saveUnzippedFiles=T)
## 


## ----run-zipsByProduct, eval = FALSE------------------------------------------------------
## 
## zipsByProduct(dpID="DP1.00002.001", site="WREF",
##               startdate="2019-04", enddate="2019-05",
##               package="basic", check.size=T)
## 


## ----zips-output, eval=FALSE--------------------------------------------------------------
## 
## Continuing will download files totaling approximately 12.750557 MB. Do you want to proceed y/n: y
## Downloading 2 files
##   |========================================================================================================| 100%
## 2 files downloaded to /Users/neon/filesToStack00002
## 


## ----zips-to-stack, eval = FALSE----------------------------------------------------------
## 
## stackByTable(filepath="/Users/neon/filesToStack00002")
## 


## ----run-zipsByProduct-avg, eval = FALSE--------------------------------------------------
## 
## zipsByProduct(dpID="DP1.00002.001", site="WREF",
##               startdate="2019-04", enddate="2019-05",
##               package="basic", avg=30, check.size=T)
## 


## ----zips-output-avg, eval=FALSE----------------------------------------------------------
## 
## Continuing will download files totaling approximately 2.101936 MB. Do you want to proceed y/n: y
## Downloading 17 files
##   |========================================================================================================| 100%
## 17 files downloaded to /Users/neon/filesToStack00002
## 


## ----zips-to-stack-avg, eval = FALSE------------------------------------------------------
## 
## stackByTable(filepath="/Users/neon/filesToStack00002")
## SAAT30 <- readTableNEON(
##   dataFile='/Users/neon/filesToStack00002/stackedFiles/SAAT_30min.csv',
##   varFile='/Users/neon/filesToStack00002/stackedFiles/variables_00002.csv'
## )
## 


## ----get-pack, eval = FALSE---------------------------------------------------------------
## 
## getPackage("DP1.00002.001", site_code="HARV",
##            year_month="2017-11", package="basic")
## 


## ----aop-files, eval = FALSE--------------------------------------------------------------
## 
## byFileAOP("DP3.30015.001", site="HOPB",
##           year="2017", check.size=T)
## 


## ----aop-output, eval=FALSE---------------------------------------------------------------
## Continuing will download 36 files totaling approximately 140.3 MB . Do you want to proceed y/n: y
## trying URL 'https://neon-aop-product.s3.data.neonscience.org:443/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D01_HOPB_DP3_716000_4704000_CHM.tif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180410T233031Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20180410%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=92833ebd10218f4e2440cb5ea78d1c8beac4ee4c10be5c6aeefb72d18cf6bd78'
## Content type 'application/octet-stream' length 4009489 bytes (3.8 MB)
## ==================================================
## downloaded 3.8 MB
## 
## (Further URLs omitted for space. Function returns a message
##   for each URL it attempts to download from)
## 
## Successfully downloaded  36  files.
## NEON_D01_HOPB_DP3_716000_4704000_CHM.tif downloaded to /Users/neon/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
## NEON_D01_HOPB_DP3_716000_4705000_CHM.tif downloaded to /Users/neon/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
## 
## (Further messages omitted for space.)
## 


## ----byTile, eval=F-----------------------------------------------------------------------
## 
## byTileAOP(dpID="DP3.30026.001", site="SOAP",
##           year="2018", easting=c(298755,299296),
##           northing=c(4101405,4101461),
##           buffer=20)
## 


## ----byTile-output, eval=F----------------------------------------------------------------
## 
## trying URL 'https://neon-aop-product.s3.data.neonscience.org:443/2018/FullSite/D17/2018_SOAP_3/L3/Spectrometer/VegIndices/NEON_D17_SOAP_DP3_299000_4101000_VegIndices.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20190313T225238Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20190313%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=e9ae6858242b48df0677457e31ea3d86b2f20ac2cf43d5fc02847bbaf2e1da47'
## Content type 'application/octet-stream' length 47798759 bytes (45.6 MB)
## ==================================================
## downloaded 45.6 MB
## 
## (Further URLs omitted for space. Function returns a message
##   for each URL it attempts to download from)
## 
## Successfully downloaded  2  files.
## NEON_D17_SOAP_DP3_298000_4101000_VegIndices.zip downloaded to /Users/neon/DP3.30026.001/2018/FullSite/D17/2018_SOAP_3/L3/Spectrometer/VegIndices
## NEON_D17_SOAP_DP3_299000_4101000_VegIndices.zip downloaded to /Users/neon/DP3.30026.001/2018/FullSite/D17/2018_SOAP_3/L3/Spectrometer/VegIndices
## 


## ----geocsv, eval = FALSE-----------------------------------------------------------------
## 
## transformFileToGeoCSV("~/NEON.D01.HARV.DP1.00002.001.000.050.030.SAAT_30min.2017-11.basic.20171207T181046Z.csv",
##                       "~/NEON.D01.HARV.DP1.00002.001.variables.20171207T181046Z.csv",
##                       "~/SAAT_30min_geo.csv")
## 

