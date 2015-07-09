## ----View-raster-attributes----------------------------------------------

#load raster library
library(raster)

# Load raster in an R object called 'DEM'
DEM <- raster("DigitalTerrainModel/SJER2013_DTM.tif")  

# View raster attributes 
# Note that this raster (in geotiff format) already has an extent, resolution, 
# CRS defined
#note that the resolution in both x and y directions is 1. The CRS tells us that
#the units of the data are meters (m)

DEM


## ----set-raster-extent---------------------------------------------------

# View the extent of the raster
DEM@extent




## ----create-raster-------------------------------------------------------


#create a raster from the matrix
myRaster1 <- raster(nrow=4, ncol=4)

#assign some random data to the raster
myRaster1[]<- 1:ncell(myRaster1)

#view attributes of the raster
myRaster1

#is the CRS defined?
myRaster1@crs

#what are the data extents?
myRaster1@extent

plot(myRaster1, main="Raster with 16 pixels")



## ----resample-raster-----------------------------------------------------

myRaster2 <- raster(nrow=8, ncol=8)
myRaster2 <- resample(myRaster1, myRaster2, method='bilinear')
myRaster2
plot(myRaster2, main="Raster with 32 pixels")


myRaster3 <- raster(nrow=2, ncol=2)
myRaster3 <- resample(myRaster1, myRaster3, method='bilinear')
myRaster3
plot(myRaster3, main="Raster with 4 pixels")

myRaster4 <- raster(nrow=1, ncol=1)
myRaster4 <- resample(myRaster1, myRaster4, method='bilinear')

myRaster4
plot(myRaster4, main="Raster with 1 pixels")


#let's create a layout with 4 rasters in it
#notice that each raster has the SAME extent but is of different resolution
#because it has a different number of pixels spread out over the same extent.
par(mfrow=c(2,2))
plot(myRaster2, main="Raster with 32 pixels")
plot(myRaster1, main="Raster with 16 pixels")
plot(myRaster3, main="Raster with 4 pixels")
plot(myRaster4, main="Raster with 2 pixels")


## ----define-raster-projection--------------------------------------------

#let's define the projection for our data using the DEM raster that already has 
#defined CRS.

#view the crs of our DEM object.
DEM@crs

#define the CRS using a CRS of another raster
myRaster1@crs  <- DEM@crs
#look at the attributes
myRaster1


## ----view-CRS-strings----------------------------------------------------

library('rgdal')
epsg = make_EPSG()
#View(epsg)
head(epsg)


## ----define-extent-------------------------------------------------------



#Define the xmin and y min (the lower left hand corner of the raster)
xMin = 254570
yMin = 4107302

# we can grab the cols and rows for the raster using @ncols and @nrows
myRaster1@ncols
myRaster1@nrows

# define the resolution
res=1.0

# If we add the numbers of cols and rows to the x,y corner location, we get the
#bounds of our raster extent. 
xMax <- xMin + (myRaster1@ncols * res)
yMax <- yMin + (myRaster1@nrows * res)

#create a raster extent class
rasExt <- extent(xMin,xMax,yMin,yMax)
rasExt

#finally apply the extent to our raster
myRaster1@extent <- rasExt

#Now we have an extent associated with our raster which places it in space!
myRaster1
par(mfrow=c(1,1))
plot(myRaster1, main="Raster in UTM coordinates, 1 m resolution")


## ----reproject-data------------------------------------------------------

# reproject raster data to CRS of dataset2 in R

# use nearest neighbor to ensure that the values stay the same
reprojectedData1 <- projectRaster(myRaster, 
                                 crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
#note the range of values in the output data
reprojectedData1

# use nearest neighbor interpolation  method to ensure that the values stay the same
reprojectedData2 <- projectRaster(myRaster, 
                                 crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ", 
                                 method = "ngb")

#http://www.inside-r.org/packages/cran/raster/docs/projectRaster
reprojectedData2


