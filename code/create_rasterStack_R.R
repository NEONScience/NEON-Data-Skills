#this R code demonstrates how to bring in, visualize and work with spatial HDF5 data into R.
#Special thanks to Edmund Hart for developing this code!
#adapted by Leah A. Wasser 

#r Load `raster` and `rhdf5` packages and read NIS data into R
library(raster)
library(rhdf5)

#make sure you have atleast rhdf5 version 2.10 installed
packageVersion("rhdf5")

#update rhdf5 if needed.
#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")

#specify the path to the H5 file. Notice that HDF5 extension can be either "hdf5" or "h5"
f <- '/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/HDF5File/SJER_140123_chip.h5'
#f <- '/Users/law/Documents/data/SJER_140123_chip.h5'

#look at the HDF5 file structure 
h5ls(f,all=T)

#############################
# here now.
######################

#Plot  RGB
# f: the hdf file
# band: the band you want to grab
# returns: a cleaned up HDF5 reflectance file
getBandMat <- function(f, band){
  out<- h5read(f,"Reflectance",index=list(1:477,1:502,band))
  #Convert from array to matrix
  out <- (out[,,1])
  #assign data ignore values to NA
  out[out > 14999] <- NA
  return(out)
}

band2rast <- function(f,band){
  
  out <-  raster(getBandMat(f,band),crs="+zone=11N +ellps=WGS84 +datum=WGS84 +proj=longlat")
  
  ex <- sort(unlist(spinfo[2:5]))
  #out <-  raster(getBandMat(f,band),crs="+zone=11 +units=m +ellps=WGS84 +datum=WGS84 +proj=utm")
  # ex <- c(256521.0,256998.0,4112069.0,4112571.0)
  e <- extent(ex)
  extent(out) <- e
  return(out)
}


stackList <- function(rastList){
  ## Creates a stack of rasters from a list of rasters
  masterRaster <- stack(rastList[[1]])
  for(i in 2:length(rastList)){
    masterRaster<-  addLayer(masterRaster,rastList[[i]])
  }
  return(masterRaster)
}

rgb <- list(58,34,19)
rgb_rast <- lapply(rgb,band2rast, f = f)

names(rgb_rast) <- as.character(rgb)

### Check with a plot
plot(rgb_rast[[1]])
rgb_stack <- stackList(rgb_rast)
plot(rgb_stack)
plotRGB(rgb_stack,r=1,g=2,b=3, scale=300, stretch = "Lin")


writeRaster(rgb_stack,file="test6.tif",overwrite=TRUE)


#Create a Map in R
library(maps)
map(database="state",region="california")
points(spinfo$LL_lat~spinfo$LL_lon,pch = 15)
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

