## ----load-libraries, results='hide'--------------------------------------

#Load required packages
  library(raster)
	library(rhdf5)


## ----read-in-file--------------------------------------------------------

#Read in H5 file
f <- 'SJER_140123_chip.h5'
#View HDF5 file structure 
h5ls(f,all=T)

#r get spatial info and map info using the h5readAttributes function
spInfo <- h5readAttributes(f,"spatialInfo")

#Populate the raster image extent value. 
mapInfo<-h5read(f,"map info")
# split out the individual components of the mapinfo string
mapInfo<-unlist(strsplit(mapInfo, ","))

#r get attributes for the Reflectance dataset
reflInfo <- h5readAttributes(f,"Reflectance")

#create objects represents the dimensions of the Reflectance dataset
nRows <- reflInfo$row_col_band[1]
nCols <- reflInfo$row_col_band[2]
nBands <- reflInfo$row_col_band[3]


## ----function-read-refl-data---------------------------------------------


#f: the hdf file
# band: the band you want to process
# returns: a matrix containing the reflectance data for the specific band
getBandMat <- function(f, band){
	  out<- h5read(f,"Reflectance",index=list(1:nCols,1:nRows,band))
	  #Convert from array to matrix
	  out <- (out[,,1])
	  #transpose data to fix flipped row and column order 
	  out <-t(out)
    #assign data ignore values to NA
    #note, you might chose to assign values > 14999 to NA
	  out[out > 10000] <- NA
    #return a single band's worth of reflectance data
	  return(out)
}


## ----fun-create-raster---------------------------------------------------

band2rast <- function(f,band){
	  #Get band from HDF5 file, assign CRS (taken from SPINFO)
    out <-  raster(getBandMat(f,band),crs=(spinfo$projdef))
    #define extents of the data using metadata and matrix attributes
    xMN=as.numeric(mapInfo[4])
    xMX=(xMN+(ncol(band)))
    yMN=as.numeric(mapInfo[5]) 
    yMX=(yMN+(nrow(band)))
    #set raster extent
    rasExt <- extent(xMN,xMX,yMN,yMX)
    #assign extent to raster
    extent(out) <- rasExt
    return(out)
  }



## ----create-raster-stack-------------------------------------------------

#create a list of the bands we want in our stack
rgb <- list(58,34,19)
#lapply tells R to apply the function to each element in the list
rgb_rast <- lapply(rgb,band2rast, f = f)

#check out the properties or rgb_rast
#note that it displays properties of 3 rasters.

rgb_rast

#finally, create a raster stack from our list of rasters
hsiStack <- stack(rgb_rast)


## ----plot-raster-stack---------------------------------------------------



#Add the band numbers as names to each raster in the raster list

#Create a list of band names
bandNames=paste("Band_",unlist(rgb),sep="")

names(hsiStack) <- bandNames
#check properties of the raster list - note the band names
hsiStack
### Plot one raster in the stack to make sure things look OK.
plot(hsiStack$Band_58, main="Band 58")

	

## ----plot-HSI-raster-----------------------------------------------------

#change the colors of our raster 
col=terrain.colors(25)
image(hsiStack$Band_58, main="Band 58", col=col)

#adjust the zlims or the stretch of the image
col=terrain.colors(25)
image(hsiStack$Band_58, main="Band 58", col=col, zlim = c(0,3000))

#try a different color palette
col=topo.colors(15, alpha = 1)
image(hsiStack$Band_58, main="Band 58", col=col, zlim=c(0,3000))

# create a 3 band RGB image
plotRGB(hsiStack,
        r=1,g=2,b=3, scale=300, 
        stretch = "Lin")



## ----save-raster-geotiff-------------------------------------------------

#write out final raster	
#note - you can bring this tiff into any GIS program!
#note: if you set overwrite to TRUE, then you will overwite or lose the older
#version of the tif file! keep this in mind.
writeRaster(hsiStack, file="rgbImage.tif", overwrite=TRUE)


## ----create-location-map-------------------------------------------------

#Create a Map showing the location of our dataset in R
library(maps)
map(database="state",region="california")
points(spinfo$LL_lat~spinfo$LL_lon,pch = 15)
#add title to map.
title(main="NEON San Joaquin Field Site - Southern California")


## ----create-NDVI---------------------------------------------------------

#Calculate NDVI
#select bands to use in calculation (red, NIR)
ndvi_bands <- c(58,90)


#create raster list and then a stack using those two bands
ndvi_rast <- lapply(ndvi_bands,band2rast, f = f)
ndvi_stack <- stack(ndvi_rast)

#make the names pretty
bandNDVINames <- paste("Band_",unlist(ndvi_bands),sep="")
names(ndvi_stack) <- bandNDVINames


#calculate NDVI
NDVI <- function(x) {
	  (x[,2]-x[,1])/(x[,2]+x[,1])
}
ndvi_calc <- calc(ndvi_stack,NDVI)
plot(ndvi_calc, main="NDVI for the NEON SJER Field Site")

#play with breaks and colors to create a meaningful map

#add a color map with 5 colors
col=terrain.colors(3)
#add breaks to the colormap (6 breaks = 5 segments)
brk <- c(0, .4, .7, .9)

#plot the image using breaks
plot(ndvi_calc, main="NDVI for the NEON SJER Field Site", col=col, breaks=brk)



