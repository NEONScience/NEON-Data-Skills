

#load the raster package
library(raster)
library(sp)
#Set your working directory 

setwd("~/Documents/data/CHM_InSitu_Data")

DEM <- raster(paste(getwd(), "/DigitalTerrainModel/SJER2013_DTM.tif", sep = "")) 
DEM@crs
DEM@extent

plot(DEM)