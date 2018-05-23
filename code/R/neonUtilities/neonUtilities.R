## ----loadStuff-----------------------------------------------------------
# install devtools - can skip if already installed
install.packages("devtools")

# load devtools
library(devtools)

# install neonUtilities from GitHub
install_github("NEONScience/NEON-utilities/neonUtilities", dependencies=TRUE)

# load neonUtilities
library (neonUtilities)


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
## zipsByProduct(dpID="DP1.00002.001", site="HARV",
##               package="basic", check.size=T)
## 

## ----zips-output, eval=FALSE---------------------------------------------
## Continuing will download files totaling approximately 121.470836 MB. Do you want to proceed y/n: y
## trying URL 'https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.00002.001/PROV/HARV/20141001T000000--20141101T000000/basic/NEON.D01.HARV.DP1.00002.001.2014-10.basic.20171010T150911Z.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180409T214634Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180409%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=1349949ab91294c564250825007e50315967655a1d0e1a4392d19f310e910654'
## Content type 'application/zip' length 1593260 bytes (1.5 MB)
## ==================================================
## downloaded 1.5 MB
## 
## (Further URLs omitted for space. Function returns a message
##   for each URL it attempts to download from)
## 
## 36 zip files downloaded to /Users/neon/filesToStack00002
## 

## ----zips-to-stack, eval = FALSE-----------------------------------------
## 
## stackByTable(filepath="/Users/neon/filesToStack00002",
##              folder=T)
## 

## ----run-zipsByProduct-avg, eval = FALSE---------------------------------
## 
## zipsByProduct(dpID="DP1.00003.001", site="HARV",
##               package="basic", avg=30, check.size=T)
## 

## ----zips-output-avg, eval=FALSE-----------------------------------------
## Continuing will download files totaling approximately 5.56142 MB. Do you want to proceed y/n: y
## trying URL 'https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.00003.001/PROV/HARV/20141001T000000--20141101T000000/basic/NEON.D01.HARV.DP1.00003.001.000.060.030.TAAT_30min.2014-10.basic.20171014T082555Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180523T221132Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20180523%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=2a52fb43a773d3c91af41f44796876779a0d5ba041be39e4e73fc0a8d2e71b7a'
## Content type 'application/octet-stream' length 56534 bytes (55 KB)
## ==================================================
## downloaded 55 KB
## 
## (Further URLs omitted for space. Function returns a message
##   for each URL it attempts to download from)
## 
## 76 files downloaded to /Users/neon/filesToStack00003
## 

## ----zips-to-stack-avg, eval = FALSE-------------------------------------
## 
## stackByTable(filepath="/Users/neon/filesToStack00003",
##              folder=T)
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

## ----geocsv, eval = FALSE------------------------------------------------
## 
## transformFileToGeoCSV("~/NEON.D01.HARV.DP1.00002.001.000.050.030.SAAT_30min.2017-11.basic.20171207T181046Z.csv",
##                       "~/NEON.D01.HARV.DP1.00002.001.variables.20171207T181046Z.csv",
##                       "~/SAAT_30min_geo.csv")
## 

