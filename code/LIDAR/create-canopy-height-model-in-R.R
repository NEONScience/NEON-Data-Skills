## ----set-up, message=FALSE, warning=FALSE--------------------------

# Load needed packages
library(raster)
library(rgdal)

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. Be sure to move the download into your working directory!
wd="~/Documents/data/" #This will depend on your local environment
setwd(wd)


## ----import-dsm----------------------------------------------------

# assign raster to object
dsm <- raster(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/DigitalSurfaceModel/SJER2013_DSM.tif"))

# view info about the raster.
dsm

# plot the DSM
plot(dsm, main="Lidar Digital Surface Model \n SJER, California")



## ----plot-DTM------------------------------------------------------

# import the digital terrain model
dtm <- raster(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/DigitalTerrainModel/SJER2013_DTM.tif"))

plot(dtm, main="Lidar Digital Terrain Model \n SJER, California")



## ----calculate-plot-CHM--------------------------------------------

# use raster math to create CHM
chm <- dsm - dtm

# view CHM attributes
chm

plot(chm, main="Lidar Canopy Height Model \n SJER, California")



## ----challenge-code-raster-math, include=TRUE, results="hide", echo=FALSE----
# conversion 1m = 3.28084 ft
chm_ft <- chm*3.28084

# plot 
plot(chm_ft, main="Lidar Canopy Height Model \n in feet")



## ----canopy-function-----------------------------------------------
# Create a function that subtracts one raster from another
# 
canopyCalc <- function(DTM, DSM) {
  return(DSM -DTM)
  }
    
# use the function to create the final CHM
chm2 <- canopyCalc(dsm,dtm)
chm2

# or use the overlay function
chm3 <- overlay(dsm,dtm,fun = canopyCalc) 
chm3 



## ----write-raster-to-geotiff, eval=FALSE, comment=NA---------------
# write out the CHM in tiff format. 
writeRaster(chm,paste0(wd,"chm_SJER.tif"),"GTiff")


