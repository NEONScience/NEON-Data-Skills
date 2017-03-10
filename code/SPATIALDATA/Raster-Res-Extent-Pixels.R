## ----load-data-----------------------------------------------------------

# load packages 
library(raster)  
library(rgdal)

# Load raster in an R object called 'DEM'
DEM <- raster("DigitalTerrainModel/SJER2013_DTM.tif")  

# set working directory to data folder
#setwd("pathToDirHere")


## ----view-raster-attributes----------------------------------------------
# View raster attributes 
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


## ----view-CRS-strings----------------------------------------------------

library('rgdal')
epsg = make_EPSG()
#View(epsg)
head(epsg)


## ----define-extent-------------------------------------------------------

#create a raster from the matrix
newMatrix  <- (matrix(1:8, nrow = 10, ncol = 20))

#create a raster from the matrix
rasterNoProj <- raster(newMatrix)
rasterNoProj
#Define the xmin and y min (the lower left hand corner of the raster)
xMin = 254570
yMin = 4107302

# we can grab the cols and rows for the raster using @ncols and @nrows
rasterNoProj@ncols
rasterNoProj@nrows

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
rasterNoProj@extent <- rasExt
rasterNoProj
#view extent only
rasterNoProj@extent
#Now we have an extent associated with our raster which places it in space!
rasterNoProj
par(mfrow=c(1,1))
plot(rasterNoProj, main="Raster in UTM coordinates, 1 m resolution")


## ----define-raster-projection--------------------------------------------

#let's define the projection for our data using the DEM raster that already has 
#defined CRS.
#NOTE: in this case we have to KNOW that our raster is in this projection already!
rasterNoProj@crs
#view the crs of our DEM object.
DEM@crs

#define the CRS using a CRS of another raster
rasterNoProj@crs  <- DEM@crs
#look at the attributes
rasterNoProj
#view just the crs
rasterNoProj@crs


## ----reproject-data------------------------------------------------------

# reproject raster data from UTM to CRS of Lat/Long WGS84

reprojectedData1 <- projectRaster(rasterNoProj, 
                                 crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

#note that the extent has been adjusted to account for the NEW crs
reprojectedData1@crs
reprojectedData1@extent
#note the range of values in the output data
reprojectedData1

# use nearest neighbor interpolation  method to ensure that the values stay the same
reprojectedData2 <- projectRaster(rasterNoProj, 
                                 crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ", 
                                 method = "ngb")

#http://www.inside-r.org/packages/cran/raster/docs/projectRaster
#note that the min and max values have now been forced to stay within the same range.
reprojectedData2


