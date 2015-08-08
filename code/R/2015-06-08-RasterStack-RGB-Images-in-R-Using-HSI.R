## ----load-libraries, results='hide'--------------------------------------

#Load required packages
  library(raster)
	library(rhdf5)


## ----read-in-file--------------------------------------------------------

#Read in H5 file
f <- 'SJER_140123_chip.h5'
#View HDF5 file structure 
h5ls(f,all=T)


## ----get-spatial-attributes----------------------------------------------

#r get spatial info and map info using the h5readAttributes function
spInfo <- h5readAttributes(f,"spatialInfo")
#define coordinate reference system
myCrs <- spInfo$projdef
#define the resolution
res <- spInfo$xscale

#Populate the raster image extent value. 
mapInfo<-h5read(f,"map info")
#the map info string contains the lower left hand coordinates of our raster
#let's grab those next
# split out the individual components of the mapinfo string
mapInfo<-unlist(strsplit(mapInfo, ","))

#grab the utm coordinates of the lower left corner
xMin<-as.numeric(mapInfo[4])
yMax<-as.numeric(mapInfo[5]) 

#r get attributes for the Reflectance dataset
reflInfo <- h5readAttributes(f,"Reflectance")

#create objects represents the dimensions of the Reflectance dataset
#note that there are several ways to access the size of the raster contained
#within the H5 file
nRows <- reflInfo$row_col_band[1]
nCols <- reflInfo$row_col_band[2]
nBands <- reflInfo$row_col_band[3]

#grab the no data value
myNoDataValue <- reflInfo$`data ignore value`
myNoDataValue


## ----function-read-refl-data---------------------------------------------

# file: the hdf file
# band: the band you want to process
# returns: a matrix containing the reflectance data for the specific band

band2Raster <- function(file, band, noDataValue, xMin, yMin, res, crs){
    #first read in the raster
    out<- h5read(f,"Reflectance",index=list(1:nCols,1:nRows,band))
	  #Convert from array to matrix
	  out <- (out[,,1])
	  #transpose data to fix flipped row and column order 
    #depending upon how your data are formated you might not have to perform this
    #step.
	  out <-t(out)
    #assign data ignore values to NA
    #note, you might chose to assign values of 15000 to NA
    out[out == myNoDataValue] <- NA
	  
    #turn the out object into a raster
    outr <- raster(out,crs=myCrs)
 
    # define the extents for the raster
    #note that you need to multiple the size of the raster by the resolution 
    #(the size of each pixel) in order for this to work properly
    xMax <- xMin + (outr@ncols * res)
    yMin <- yMax - (outr@nrows * res)
 
    #create extents class
    rasExt  <- extent(xMin,xMax,yMin,yMax)
   
    #assign the extents to the raster
    extent(outr) <- rasExt
   
    #return the raster object
    return(outr)
}


## ----create-raster-stack-------------------------------------------------

#create a list of the bands we want in our stack
rgb <- list(58,34,19)
#lapply tells R to apply the function to each element in the list
rgb_rast <- lapply(rgb,band2Raster, file = f, 
                   noDataValue=myNoDataValue, 
                   xMin=xMin, yMin=yMin, res=1,
                   crs=myCrs)

#check out the properties or rgb_rast
#note that it displays properties of 3 rasters.

rgb_rast

#finally, create a raster stack from our list of rasters
hsiStack <- stack(rgb_rast)


## ----plot-raster-stack---------------------------------------------------



#Add the band numbers as names to each raster in the raster list

#Create a list of band names
bandNames <- paste("Band_",unlist(rgb),sep="")

names(hsiStack) <- bandNames
#check properties of the raster list - note the band names
hsiStack

#scale the data as specified in the reflInfo$Scale Factor

hsiStack <- hsiStack/reflInfo$`Scale Factor`

### Plot one raster in the stack to make sure things look OK.
plot(hsiStack$Band_58, main="Band 58")

	

## ----plot-HSI-raster-----------------------------------------------------

#change the colors of our raster 
myCol=terrain.colors(25)
image(hsiStack$Band_58, main="Band 58", col=myCol)

#adjust the zlims or the stretch of the image
myCol=terrain.colors(25)
image(hsiStack$Band_58, main="Band 58", col=myCol, zlim = c(0,.5))

#try a different color palette
myCol=topo.colors(15, alpha = 1)
image(hsiStack$Band_58, main="Band 58", col=myCol, zlim=c(0,.5))


## ----plot-RGB-Image------------------------------------------------------


# create a 3 band RGB image
plotRGB(hsiStack,
        r=1,g=2,b=3, scale=300, 
        stretch = "Lin")



## ----save-raster-geotiff-------------------------------------------------

#write out final raster	
#note - you can bring this tiff into any GIS program!
#note: if you set overwrite to TRUE, then you will overwite or lose the older
#version of the tif file! keep this in mind.
writeRaster(hsiStack, file="rgbImage.tif", format="GTiff", overwrite=TRUE)


## ----create-location-map-------------------------------------------------

#Create a Map showing the location of our dataset in R
library(maps)
map(database="state",region="california")
points(spInfo$LL_lat~spInfo$LL_lon,pch = 15)
#add title to map.
title(main="NEON San Joaquin Field Site - Southern California")


## ----create-NDVI---------------------------------------------------------

#Calculate NDVI
#select bands to use in calculation (red, NIR)
ndvi_bands <- c(58,90)


#create raster list and then a stack using those two bands
ndvi_rast <- lapply(ndvi_bands,band2Raster, file = f, noDataValue=15000, 
                    xMin=xMin, yMin=yMin,
                    crs=myCRS,res=1)
ndvi_stack <- stack(ndvi_rast)

#make the names pretty
bandNDVINames <- paste("Band_",unlist(ndvi_bands),sep="")
names(ndvi_stack) <- bandNDVINames

ndvi_stack

#calculate NDVI
NDVI <- function(x) {
	  (x[,2]-x[,1])/(x[,2]+x[,1])
}
ndvi_calc <- calc(ndvi_stack,NDVI)
plot(ndvi_calc, main="NDVI for the NEON SJER Field Site")

#play with breaks and colors to create a meaningful map

#add a color map with 5 colors
myCol <- terrain.colors(3)
#add breaks to the colormap (6 breaks = 5 segments)
brk <- c(0, .4, .7, .9)

#plot the image using breaks
plot(ndvi_calc, main="NDVI for the NEON SJER Field Site", col=myCol, breaks=brk)



