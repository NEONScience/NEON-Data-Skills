## ----loadStuff-----------------------------------------------------------
# install neonUtilities - can skip if already installed
install.packages("neonUtilities")

# load neonUtilities
library(neonUtilities)


## ----run-function, eval = FALSE------------------------------------------
## # stack files - Mac OSX file path shown
## stackByTable(filepath="~neon/data/NEON_temp-air-single.zip")
## 

## ----sample-output, eval=FALSE-------------------------------------------
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

## ----run-options, eval = FALSE-------------------------------------------
## 
## stackByTable(filepath="~neon/data/NEON_temp-air-single.zip",
##              savepath="~data/allTemperature", saveUnzippedFiles=T)
## 

## ----run-zipsByProduct, eval = FALSE-------------------------------------
## 
## zipsByProduct(dpID="DP1.00002.001", site="WREF",
##               package="basic", check.size=T)
## 

## ----zips-output, eval=FALSE---------------------------------------------
## 
## Continuing will download files totaling approximately 10.80949 MB. Do you want to proceed y/n: y
## Downloading 2 files
##   |=================================================================================================| 100%
## 2 files downloaded to /Users/neon/filesToStack00002
## 

## ----zips-to-stack, eval = FALSE-----------------------------------------
## 
## stackByTable(filepath="/Users/neon/filesToStack00002",
##              folder=T)
## 

## ----run-zipsByProduct-avg, eval = FALSE---------------------------------
## 
## zipsByProduct(dpID="DP1.00003.001", site="WREF",
##               package="basic", avg=30, check.size=T)
## 

## ----zips-output-avg, eval=FALSE-----------------------------------------
## 
## Continuing will download files totaling approximately 0.270066 MB. Do you want to proceed y/n: y
## Downloading 4 files
##   |=================================================================================================| 100%
## 4 files downloaded to /Users/neon/filesToStack00003
## 

## ----zips-to-stack-avg, eval = FALSE-------------------------------------
## 
## stackByTable(filepath="/Users/neon/filesToStack00003",
##              folder=T)
## 

## ----loadBy, eval=F------------------------------------------------------
## 
## trip.temp <- loadByProduct(dpID="DP1.00003.001",
##                            site=c("MOAB","ONAQ"),
##                            startdate="2018-05",
##                            enddate="2018-08")
## 

## ----loadBy-output, eval=F-----------------------------------------------
## 
## Continuing will download files totaling approximately 3.789588 MB. Do you want to proceed y/n: y
## Downloading 4 files
##   |=================================================================================================| 100%
## 
## Unpacking zip files
##   |=================================================================================================| 100%
## Stacking table TAAT_1min
##   |=================================================================================================| 100%
## Stacking table TAAT_30min
##   |=================================================================================================| 100%
## Finished: All of the data are stacked into 2 tables!
## Copied the first available variable definition file to /stackedFiles and renamed as variables.csv
## Stacked TAAT_1min which has 174960 out of the expected 174960 rows (100%).
## Stacked TAAT_30min which has 5832 out of the expected 5832 rows (100%).
## Stacking took 3.441994 secs
## All unzipped monthly data folders have been removed.
## 

## ----loadBy-list, eval=F-------------------------------------------------
## 
## names(trip.temp)
## View(trip.temp$TAAT_30min)
## 

## ----assign-loop, eval=F-------------------------------------------------
## 
## for(i in 1:length(trip.temp)) {
##     assign(names(trip.temp)[i], trip.temp[[i]])
## }
## 

## ----get-pack, eval = FALSE----------------------------------------------
## 
## getPackage("DP1.00002.001", site_code="HARV",
##            year_month="2017-11", package="basic")
## 

## ----aop-files, eval = FALSE---------------------------------------------
## 
## byFileAOP("DP3.30015.001", site="HOPB",
##           year="2017", check.size=T)
## 

## ----aop-output, eval=FALSE----------------------------------------------
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

## ----byTile, eval=F------------------------------------------------------
## 
## byTileAOP(dpID="DP3.30026.001", site="SOAP",
##           year="2018", easting=c(298755,299296),
##           northing=c(4101405,4101461),
##           buffer=20)
## 

## ----byTile-output, eval=F-----------------------------------------------
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

## ----geocsv, eval = FALSE------------------------------------------------
## 
## transformFileToGeoCSV("~/NEON.D01.HARV.DP1.00002.001.000.050.030.SAAT_30min.2017-11.basic.20171207T181046Z.csv",
##                       "~/NEON.D01.HARV.DP1.00002.001.variables.20171207T181046Z.csv",
##                       "~/SAAT_30min_geo.csv")
## 

