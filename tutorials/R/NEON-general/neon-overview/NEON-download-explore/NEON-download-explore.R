## ----opts-set, echo=FALSE---------------------------------------------------------------------------------
library(knitr)
opts_knit$set(global.par = TRUE)


## ----packages, eval=FALSE---------------------------------------------------------------------------------
## 
## install.packages("neonUtilities")
## install.packages("neonOS")
## install.packages("terra")
## 


## ----setup, results='hide', message=FALSE, warning=FALSE--------------------------------------------------

# load packages
library(neonUtilities)
library(neonOS)
library(terra)

# Set global option to NOT convert all character variables to factors.
# If you are working in R version 4 or higher (recommended), this is 
# already the default setting.
options(stringsAsFactors=F)



## ----stacking-portal, results="hide", message=FALSE, warning=FALSE----------------------------------------

# Modify the file path to match the path to your zip file
stackByTable("~/Downloads/NEON_par.zip")



## ----read-par, results="hide", message=FALSE, warning=FALSE-----------------------------------------------

par30 <- readTableNEON(
  dataFile="~/Downloads/NEON_par/stackedFiles/PARPAR_30min.csv", 
  varFile="~/Downloads/NEON_par/stackedFiles/variables_00024.csv")
View(par30)



## ----read-par-var, results="hide", message=FALSE, warning=FALSE-------------------------------------------

parvar <- read.csv("~/Downloads/NEON_par/stackedFiles/variables_00024.csv")
View(parvar)



## ----plot-par, eval=TRUE----------------------------------------------------------------------------------

plot(PARMean~startDateTime, 
     data=par30[which(par30$verticalPosition=="080"),],
     type="l")



## ----plot-par-lower, eval=TRUE----------------------------------------------------------------------------

plot(PARMean~startDateTime, 
     data=par30[which(par30$verticalPosition=="080"),],
     type="l")

lines(PARMean~startDateTime, 
     data=par30[which(par30$verticalPosition=="020"),],
     col="blue")



## ----run-loadByProduct-par, results="hide"----------------------------------------------------------------

parlist <- loadByProduct(dpID="DP1.00024.001", 
                         site="WREF", 
                         startdate="2019-09",
                         enddate="2019-11")



## ----par-list-names---------------------------------------------------------------------------------------

names(parlist)



## ----run-loadByProduct, results="hide", eval=FALSE, comment=NA--------------------------------------------

apchem <- loadByProduct(dpID="DP1.20063.001", 
                  site=c("PRLA","SUGG","TOOK"), 
                  package="expanded", check.size=T)




## ----loadBy-list, eval=T----------------------------------------------------------------------------------

names(apchem)



## ----env, eval=T------------------------------------------------------------------------------------------

list2env(apchem, .GlobalEnv)



## ----save-files, eval=F-----------------------------------------------------------------------------------
## 
## saveRDS(apchem,
##         "~/Downloads/aqu_plant_chem.rds")
## 


## ----read-vst-var, results="hide", message=FALSE, warning=FALSE-------------------------------------------

View(variables_20063)



## ----13C-by-site, message=FALSE, warning=FALSE------------------------------------------------------------

boxplot(analyteConcentration~siteID, 
        data=apl_plantExternalLabDataPerSample, 
        subset=analyte=="d13C",
        xlab="Site", ylab="d13C")



## ----table-merge, eval=TRUE, results="hide", message=F----------------------------------------------------

apct <- joinTableNEON(apl_biomass, 
            apl_plantExternalLabDataPerSample)



## ----set-graph-param, eval=TRUE, echo=F, results='hide', message=F, warning=F-----------------------------

par(mar=c(12,4,0.25,1))



## ----plot-13C-by-tax, eval=TRUE---------------------------------------------------------------------------

boxplot(analyteConcentration~scientificName, 
        data=apct, subset=analyte=="d13C", 
        xlab=NA, ylab="d13C", 
        las=2, cex.axis=0.7)



## ----aop-tile, results="hide", eval=FALSE, comment=NA-----------------------------------------------------

byTileAOP("DP3.30015.001", site="WREF", year="2017", check.size = T,
          easting=580000, northing=5075000, savepath="~/Downloads")




## ----read-aop, eval=TRUE----------------------------------------------------------------------------------

chm <- rast("~/Downloads/DP3.30015.001/neon-aop-products/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")



## ----reset-graph-param, eval=TRUE, echo=F, results='hide', message=F, warning=F---------------------------

par(mar=c(5,4,4,1))



## ----plot-aop, eval=TRUE----------------------------------------------------------------------------------

plot(chm, col=topo.colors(6))


