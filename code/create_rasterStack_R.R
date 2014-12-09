#this R code demonstrates how to bring in, visualize and work with spatial HDF5 data into R.
#Special thanks to Edmund Hart for developing this code!
#adapted by Leah A. Wasser 

#r Load `raster` and `rhdf5` packages and read NIS data into R
library(raster)
library(rhdf5)

#make sure you have atleast rhdf5 version 2.10 installed
#packageVersion("rhdf5")

#update rhdf5 if needed.
#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")

#specify the path to the H5 file. Notice that HDF5 extension can be either "hdf5" or "h5"
f <- '/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/HDF5File/SJER_140123_chip.h5'
#f <- '/Users/law/Documents/data/SJER_140123_chip.h5'

#look at the HDF5 file structure 
h5ls(f,all=T)

#r get spatial info and map info using the h5readAttributes function developed by Ted Hart
spinfo <- h5readAttributes(f,"spatialInfo")

#Populate the raster image extent value. 
#get the map info, split out elements
mapInfo<-h5read(f,"map info")
mapInfo<-unlist(strsplit(mapInfo, ","))

#Plot  RGB
# f: the hdf file
# band: the band you want to grab
# returns: a cleaned up HDF5 reflectance file
#create a function that processes multiple bands of data
getBandMat <- function(f, band){
  out<- h5read(f,"Reflectance",index=list(1:477,1:502,band))
  #Convert from array to matrix
  out <- (out[,,1])
  #transpose data to fix flipped row and column order 
  out <-t(out)
  #assign data ignore values to NA
  out[out > 14999] <- NA
  return(out)
}


band2rast <- function(f,band){
  #define the raster including the CRS (taken from SPINFO)
  out <-  raster(getBandMat(f,band),crs=(spinfo$projdef))
  #define extents of the data using metadata and matrix attributes
  xMN=as.numeric(mapInfo[4])
  xMX=(xMN+(ncol(out)))
  yMN=as.numeric(mapInfo[5]) 
  yMX=(yMN+(nrow(out)))
  #set raster extent
  rasExt <- extent(xMN,xMX,yMN,yMX)
  #assign extent to raster
  extent(out) <- rasExt
  return(out)
}


stackList <- function(rastList){
  ## Creates a raster stack (multiple rasters in one file
  # from a list of rasters
  masterRaster <- stack(rastList[[1]])
  for(i in 2:length(rastList)){
    masterRaster<-  addLayer(masterRaster,rastList[[i]])
  }
  return(masterRaster)
}

#typical RGB bands
rgb <- list(58,34,19)
#color infrared (estimating landsat)
rgb <- list(90,34,19)
#false color (estimating landsat)
rgb <- list(363,246,55)

rgb_rast <- lapply(rgb,band2rast, f = f)

names(rgb_rast) <- as.character(rgb)

### Check with a plot
plot(rgb_rast[[1]])
rgb_stack <- stackList(rgb_rast)
plot(rgb_stack)

plotRGB(rgb_stack,r=1,g=2,b=3, scale=300, stretch = "Lin")


writeRaster(rgb_stack,file="threeBandImage.tif",overwrite=TRUE)


#Create a Map in R
#note: this is a quick and dirty way to map the location of this region
#in this case the maps data requires coordinates in lat long
#thus we tool the lat and long values from spinfo as opposed to
#the UTM coordinates in the map info dataset
library(maps)
map(database="state",region="california")
points(spinfo$LL_lat~spinfo$LL_lon,pch = 15)
title(main="NEON Site Location in Southern California")
# Add raster


#r ndvi}

ndvi_bands <- c(58,90)

ndvi_rast <- lapply(ndvi_bands,band2rast, f = f)
ndvi_stack <- stackList(ndvi_rast)
NDVI <- function(x) {
  (x[,2]-x[,1])/(x[,2]+x[,1])
}
ndvi_calc <- calc(ndvi_stack,NDVI)
plot(ndvi_calc)

#http://stackoverflow.com/questions/9542039/resolution-values-for-rasters-in-r

