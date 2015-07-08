## ----View-raster-attributes----------------------------------------------

#load raster library
library(raster)

# Load raster in an R object called 'DEM'
DEM <- raster("DigitalTerrainModel/SJER2013_DTM.tif")  

# View raster attributes 
# Note that this raster (in geotiff format) already has an extent, resolution, 
# CRS defined
DEM


## ----set-raster-extent---------------------------------------------------

# View the extent of the raster
DEM@extent

# Set raster extent (R Code)
# xMN = minimum x value, xMX=maximum x value, yMN - minimum Y value, yMX=maximum Y value
#rasExt <- extent(xMN,xMX,yMN,yMX)


## ----calculate-extent----------------------------------------------------

newMatrix  <- (matrix(1:8, nrow = 10, ncol = 20))

#create a raster from the matrix
myRaster <- raster(newMatrix)

#view attributes of the raster
myRaster

#is the CRS defined?
myRaster@crs

#what are the data extents?
myRaster@extent

plot(myRaster)


## ----define-extent-------------------------------------------------------

#Define the xmin and y min (the lower left hand corner of the raster)
xMin = 254570
yMin = 4107302

# we can grab the cols and rows for the raster using @ncols and @nrows
myRaster@ncols
myRaster@nrows

# define the resolution
res=1.0

# If we add the numbers of cols and rows to the x,y corner location, we get the
#bounds of our raster extent. 
xMax <- xMin + (myRaster@ncols * res)
yMax <- yMin + (myRaster@nrows * res)

#create a raster extent class
rasExt <- extent(xMin,xMax,yMin,yMax)
rasExt

#finally apply the extent to our raster
myRaster@extent <- rasExt

#Now we have an extent associated with our raster which places it in space!
myRaster

plot(myRaster)


## ----define-raster-projection--------------------------------------------

#let's define the projection for our data using the DEM raster that already has 
#defined CRS.

#view the crs of our DEM object.
DEM@crs

#define the CRS using a CRS of another raster
myRaster@crs  <- DEM@crs
#look at the attributes
myRaster


## ----view-CRS-strings----------------------------------------------------

library('rgdal')
epsg = make_EPSG()
#View(epsg)
head(epsg)


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


