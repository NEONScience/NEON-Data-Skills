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

#r get spatial info and map info using the h5readAttributes function developed by Ted Hart
spinfo <- h5readAttributes(f,"spatialInfo")

#read in the wavelength information from the Hdf5 file
wavelengths<- h5read(f,"wavelength",index=list(1:426,1))

#r extract "slices" of data from an HDF5 file (read in only the parts that you need)
b34<- h5read(f,"Reflectance",index=list(1:477,1:502,34))

#Convert from array to matrix
b34 <- b34[,,1]

#note - when R imports the matrix, the dimensions are read in reverse order
#so we need to transpose x and y values in order for our final image to plot properly
b34<-t(b34)

#plot image
image(b34)

#View range of reflectance values.
#when a program applies color to each pixel in a raster, it stretches
hist(b34,breaks=40,col="darkmagenta",
     main="Distribution of Reflectance Values",
     xlab="Reflectance")
hist(b34,breaks=40,col="darkmagenta",xlim = c(0, 5000),
     main="Distribution of Reflectance Values",
     xlab="Reflectance")
hist(b34, breaks=40,col="darkmagenta",xlim = c(5000, 15000),
     ylim=c(0,100),
     main="Distribution of Reflectance Values",
     xlab="Reflectance")
#set data ignore value (15000) to NA (null value)

b34[b34 > 14999] <- NA
image(b34)
image(log(b34))


#######################
#Convert Matrix to Raster
#######################


#Populate the raster image extent value. 
#get the map info, split out elements
mapInfo<-h5read(f,"map info")
mapInfo<-unlist(strsplit(mapInfo, ","))

#define extents of the data using metadata and matrix attributes
xMN=as.numeric(mapInfo[4])
xMX=(xMN+(ncol(b34)))
yMN=as.numeric(mapInfo[5]) 
yMX=(yMN+(nrow(b34)))
     
rasExt <- extent(xMN,xMX,yMN,yMX)

#define final raster with projection info 
b34r<-raster(b34, 
            crs=(spinfo$projdef))

#assign the spatial extent to the raster
extent(b34r) <- rasExt
image(b34r)


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

