## ----packages, eval=FALSE------------------------------------------------
## 
## install.packages("devtools")
## install.packages("neonUtilities")
## install.packages("raster")
## devtools::install_github("NEONScience/NEON-geolocation/geoNEON")
## source("http://bioconductor.org/biocLite.R")
## biocLite("rhdf5")
## 

## ----setup, eval=FALSE---------------------------------------------------
## 
## library(neonUtilities)
## library(geoNEON)
## library(raster)
## library(rhdf5)
## 
## # Set global option to NOT convert all character variables to factors
## options(stringsAsFactors=F)
## 

## ----stacking-portal, eval=FALSE-----------------------------------------
## 
## # Modify the file path to match the path to your zip file
## stackByTable("~/Downloads/NEON_par.zip")
## 

## ----run-zipsByProduct, eval=FALSE---------------------------------------
## 
## zipsByProduct(dpID="DP1.10098.001", site="WREF",
##               package="expanded", check.size=T,
##               savepath="~/Downloads")
## 

## ----zips-to-stack, eval=FALSE-------------------------------------------
## 
## stackByTable(filepath="~/Downloads/filesToStack10098",
##              folder=T)
## 

## ----aop-tile, eval=FALSE------------------------------------------------
## 
## byTileAOP("DP3.30015.001", site="WREF", year="2017",
##           easting=580000, northing=5075000, savepath="~/Downloads")
## 

## ----read-par, eval=FALSE------------------------------------------------
## 
## par30 <- read.delim("~/Downloads/NEON_par/stackedFiles/PARPAR_30min.csv",
##                     sep=",")
## View(par30)
## 

## ----read-par-var, eval=FALSE--------------------------------------------
## 
## parvar <- read.delim("~/Downloads/NEON_par/stackedFiles/variables.csv",
##                     sep=",")
## View(parvar)
## 

## ----plot-par, eval=FALSE------------------------------------------------
## 
## par30$startDateTime <- as.POSIXct(par30$startDateTime,
##                                   format="%Y-%m-%d T %H:%M:%S Z",
##                                   tz="GMT")
## 
## plot(PARMean~startDateTime,
##      data=par30[which(par30$verticalPosition==80),],
##      type="l")
## 

## ----read-vst, eval=FALSE------------------------------------------------
## 
## vegmap <- read.delim("~/Downloads/filesToStack10098/stackedFiles/vst_mappingandtagging.csv",
##                      sep=",")
## View(vegmap)
## vegind <- read.delim("~/Downloads/filesToStack10098/stackedFiles/vst_apparentindividual.csv",
##                      sep=",")
## View(vegind)
## 

## ----read-vst-var, eval=FALSE--------------------------------------------
## 
## vstvar <- read.delim("~/filesToStack10098/stackedFiles/variables.csv",
##                     sep=",")
## View(vstvar)
## 
## vstval <- read.delim("~/filesToStack10098/stackedFiles/validation.csv",
##                     sep=",")
## View(vstval)
## 

## ----stems, eval=FALSE---------------------------------------------------
## 
## names(vegmap)
## vegmap <- geoNEON::def.calc.geo.os(vegmap, "vst_mappingandtagging")
## names(vegmap)
## 

## ----vst-merge, eval=FALSE-----------------------------------------------
## 
## veg <- merge(vegind, vegmap, by=c("individualID","namedLocation",
##                                   "domainID","siteID","plotID"))
## 

## ----plot-vst, eval=FALSE------------------------------------------------
## 
## symbols(veg$adjEasting[which(veg$plotID=="WREF_085")],
##         veg$adjNorthing[which(veg$plotID=="WREF_085")],
##         circles=veg$stemDiameter[which(veg$plotID=="WREF_085")]/100,
##         xlab="Easting", ylab="Northing", inches=F)
## 

## ----read-aop, eval=FALSE------------------------------------------------
## 
## chm <- raster("~/Downloads/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")
## 

## ----plot-aop, eval=FALSE------------------------------------------------
## 
## plot(chm, col=topo.colors(6))
## 

