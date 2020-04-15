## ----packages, eval=FALSE------------------------------------------------------------------------
## 
## install.packages("devtools")
## install.packages("neonUtilities")
## install.packages("raster")
## devtools::install_github("NEONScience/NEON-geolocation/geoNEON")
## install.packages("BiocManager")
## BiocManager::install("rhdf5")
## 


## ----setup, results='hide', message=FALSE, warning=FALSE-----------------------------------------

# load packages
library(neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)

# Set global option to NOT convert all character variables to factors
options(stringsAsFactors=F)



## ----stacking-portal, results="hide", message=FALSE, warning=FALSE-------------------------------

# Modify the file path to match the path to your zip file
stackByTable("~/Downloads/NEON_par.zip")



## ----run-loadByProduct, results="hide", eval=FALSE, comment=NA-----------------------------------

veg_str <- loadByProduct(dpID="DP1.10098.001", site="WREF", 
              package="expanded", check.size=T)




## ----loadBy-list, eval=F-------------------------------------------------------------------------
## 
## names(veg_str)
## View(veg_str$vst_perplotperyear)
## 


## ----env, eval=T---------------------------------------------------------------------------------

list2env(veg_str, .GlobalEnv)



## ----save-files, eval=F--------------------------------------------------------------------------
## 
## write.csv(vst_apparentindividual,
##           "~/Downloads/vst_apparentindividual.csv",
##           row.names=F)
## write.csv(variables_10098,
##           "~/Downloads/variables_10098.csv",
##           row.names=F)
## 


## ----aop-tile, results="hide", eval=FALSE, comment=NA--------------------------------------------

byTileAOP("DP3.30015.001", site="WREF", year="2017", check.size = T,
          easting=580000, northing=5075000, savepath="~/Downloads")




## ----read-par, results="hide", message=FALSE, warning=FALSE--------------------------------------

par30 <- readTableNEON(
  dataFile="~/Downloads/NEON_par/stackedFiles/PARPAR_30min.csv", 
  varFile="~/Downloads/NEON_par/stackedFiles/variables_00024.csv")
View(par30)



## ----read-par-var, results="hide", message=FALSE, warning=FALSE----------------------------------

parvar <- read.csv("~/Downloads/NEON_par/stackedFiles/variables_00024.csv")
View(parvar)



## ----plot-par, eval=TRUE-------------------------------------------------------------------------

plot(PARMean~startDateTime, 
     data=par30[which(par30$verticalPosition=="080"),],
     type="l")



## ----read-vst-var, results="hide", message=FALSE, warning=FALSE----------------------------------

View(variables_10098)

View(validation_10098)



## ----stems, results='hide', message=FALSE, warning=FALSE-----------------------------------------

names(vst_mappingandtagging) #this object was created using list2env() above
vegmap <- geoNEON::getLocTOS(vst_mappingandtagging, "vst_mappingandtagging")
names(vegmap)



## ----vst-merge, eval=TRUE------------------------------------------------------------------------

veg <- merge(vst_apparentindividual, vegmap, by=c("individualID","namedLocation",
                                  "domainID","siteID","plotID"))



## ----plot-vst, eval=TRUE-------------------------------------------------------------------------

symbols(veg$adjEasting[which(veg$plotID=="WREF_085")], 
        veg$adjNorthing[which(veg$plotID=="WREF_085")], 
        circles=veg$stemDiameter[which(veg$plotID=="WREF_085")]/100/2, 
        xlab="Easting", ylab="Northing", inches=F)



## ----read-aop, eval=TRUE-------------------------------------------------------------------------

chm <- raster("~/Downloads/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")



## ----plot-aop, eval=TRUE-------------------------------------------------------------------------

plot(chm, col=topo.colors(6))


