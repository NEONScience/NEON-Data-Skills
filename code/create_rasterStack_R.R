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
#f <- '/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/HDF5File/SJER_140123_chip.h5'
f <- '/Users/law/Documents/data/SJER_140123_chip.h5'

#look at the HDF5 file structure 
h5ls(f,all=T)

#r get spatial info and map info using the h5readAttributes function developed by Ted Hart
spinfo <- h5readAttributes(f,"spatialInfo")

#Populate the raster image extent value. 
#get the map info, split out elements
mapInfo<-h5read(f,"map info")
mapInfo<-unlist(strsplit(mapInfo, ","))

#get the dimensions of the reflectance dataset
dim(h5read(f,"Reflectance"))

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
  # from a raster list of rasters
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
#check out the properties of rgb_rast
rgb_rast


### Plot one raster in the list
plot(rgb_rast[[1]])
#create a raster stack from the raster list
rgb_stack <- stackList(rgb_rast)

#Add band names to each raster in the stack
bandNames=paste("Band_",unlist(rgb),sep="")
for (i in 1:length(rgb_rast) ) {
  names(rgb_stack)[i]=bandNames[i]
}

#this will plot each band individually
plot(rgb_stack)
#this will plot all 3 bands as one image
plotRGB(rgb_stack,r=1,g=2,b=3, scale=300, stretch = "Lin")
#save the raster as a tiff.
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

##############################
# Calculate Vegetation Indices
##############################

#designate which bands we need for a particular calculation
ndvi_bands <- c(58,90)

ndvi_rast <- lapply(ndvi_bands,band2rast, f = f)
ndvi_stack <- stackList(ndvi_rast)
NDVI <- function(x) {
  (x[,2]-x[,1])/(x[,2]+x[,1])
}
ndvi_calc <- calc(ndvi_stack,NDVI)
plot(ndvi_calc, main="NDVI for the NEON SJER Field Site")


## need to followup with Nathan and tristan on this and look at the data.
#EVI
#B3 - Red Band: USE NIS Band 58 .668nm
#B4: NIR Band: USE NIS Band 90 .828nm
#B1: Blue USE NIS Band 19 .4724
#For rendering a color image: Green band: 34

evi_bands <- c(19,58,90)
evi_rast <- lapply(evi_bands,band2rast, f = f)
evi_stack <- stackList(evi_rast)
evi <- function(x) {
  #(x[,2]-x[,1])/(x[,2]+x[,1])
  b4=x[,3]/10000
  b3=x[,2]/10000
  b1=x[,1]/10000
  2.5 * ((b4-b3) / ( b4 + 6*b3 - 7.5*b1 + 1) )
}

evi_calc <- calc(evi_stack,evi)
plot(evi_calc, main="EVI for the NEON SJER Field Site")





