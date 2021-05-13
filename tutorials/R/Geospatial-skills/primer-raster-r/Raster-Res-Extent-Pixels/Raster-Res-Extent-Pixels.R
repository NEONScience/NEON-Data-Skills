## ----load-data-------------------------------------------------------

# load packages 
library(raster)  
library(rgdal)

# set working directory to data folder
#setwd("pathToDirHere")
wd <- ("~/Git/data/")
setwd(wd)

# Load raster in an R object called 'DEM'
DEM <- raster(paste0(wd, "NEON-DS-Field-Site-Spatial-Data/SJER/DigitalTerrainModel/SJER2013_DTM.tif"))  



## ----view-raster-attributes------------------------------------------
# View raster attributes 
DEM



## ----set-raster-extent-----------------------------------------------

# View the extent of the raster
DEM@extent



## ----create-raster---------------------------------------------------

# create a raster from the matrix - a "blank" raster of 4x4
myRaster1 <- raster(nrow=4, ncol=4)

# assign "data" to raster: 1 to n based on the number of cells in the raster
myRaster1[]<- 1:ncell(myRaster1)

# view attributes of the raster
myRaster1

# is the CRS defined?
myRaster1@crs



## ----create-raster-cont----------------------------------------------

# what is the raster extent?
myRaster1@extent

# plot raster
plot(myRaster1, main="Raster with 16 pixels")



## ----resample-raster-------------------------------------------------
## HIGHER RESOLUTION
# Create 32 pixel raster
myRaster2 <- raster(nrow=8, ncol=8)

# resample 16 pix raster with 32 pix raster
# use bilinear interpolation with our numeric data
myRaster2 <- resample(myRaster1, myRaster2, method='bilinear')

# notice new dimensions, resolution, & min/max 
myRaster2

# plot 
plot(myRaster2, main="Raster with 32 pixels")

## LOWER RESOLUTION
myRaster3 <- raster(nrow=2, ncol=2)
myRaster3 <- resample(myRaster1, myRaster3, method='bilinear')
myRaster3
plot(myRaster3, main="Raster with 4 pixels")

## SINGLE PIXEL RASTER
myRaster4 <- raster(nrow=1, ncol=1)
myRaster4 <- resample(myRaster1, myRaster4, method='bilinear')
myRaster4
plot(myRaster4, main="Raster with 1 pixel")



## ----quad-layout-----------------------------------------------------
# change graphical parameter to 2x2 grid
par(mfrow=c(2,2))

# arrange plots in order you wish to see them
plot(myRaster2, main="Raster with 32 pixels")
plot(myRaster1, main="Raster with 16 pixels")
plot(myRaster3, main="Raster with 4 pixels")
plot(myRaster4, main="Raster with 2 pixels")

# change graphical parameter back to 1x1 
par(mfrow=c(1,1))



## ----view-CRS-strings------------------------------------------------

# make sure you loaded rgdal package at the top of your script

# create an object with all ESPG codes
epsg = make_EPSG()

# use View(espg) to see the full table - doesn't render on website well
#View(epsg)

# View top 5 entries
head(epsg, 5)



## ----create-raster-extent--------------------------------------------
# create 10x20 matrix with values 1-8. 
newMatrix  <- (matrix(1:8, nrow = 10, ncol = 20))

# convert to raster
rasterNoProj <- raster(newMatrix)
rasterNoProj



## ----define-extent---------------------------------------------------
## Define the xmin and ymin (the lower left hand corner of the raster)

# 1. define xMin & yMin objects.
xMin = 254570
yMin = 4107302

# 2. grab the cols and rows for the raster using @ncols and @nrows
rasterNoProj@ncols
rasterNoProj@nrows

# 3. raster resolution
res <- 1.0

# 4. add the numbers of cols and rows to the x,y corner location, 
# result = we get the bounds of our raster extent. 
xMax <- xMin + (rasterNoProj@ncols * res)
yMax <- yMin + (rasterNoProj@nrows * res)

# 5.create a raster extent class
rasExt <- extent(xMin,xMax,yMin,yMax)
rasExt

# 6. apply the extent to our raster
rasterNoProj@extent <- rasExt

# Did it work? 
rasterNoProj
# or view extent only
rasterNoProj@extent



## ----plot-raster-our-extent------------------------------------------
# plot new raster
plot(rasterNoProj, main="Raster in UTM coordinates, 1 m resolution")



## ----define-raster-projection----------------------------------------

# view CRS from raster of interest
rasterNoProj@crs

# view the CRS of our DEM object.
DEM@crs

# define the CRS using a CRS of another raster
rasterNoProj@crs <- DEM@crs

# look at the attributes
rasterNoProj

# view just the crs
rasterNoProj@crs



## ----challenge-example-code------------------------------------------
## Challenge Example Code 

# set latLong
latLong <- data.frame(longitude=seq( 0,10,1), latitude=seq( 0,10,1))

# make spatial points dataframe, which will have a spatial extent
sp <- SpatialPoints( latLong[ c("longitude" , "latitude") ], proj4string = CRS("+proj=longlat +datum=WGS84") )

# make raster based on the extent of your data
r <- raster(nrow=5, ncol=5, extent( sp ) )

r[]  <- 1
r[]  <- sample(0:50,25)
r


## ----reproject-data--------------------------------------------------

# reproject raster data from UTM to CRS of Lat/Long WGS84
reprojectedData1 <- projectRaster(rasterNoProj, 
                                 crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

# note that the extent has been adjusted to account for the NEW crs
reprojectedData1@crs
reprojectedData1@extent

# note the range of values in the output data
reprojectedData1

# use nearest neighbor interpolation method to ensure that the values stay the same
reprojectedData2 <- projectRaster(rasterNoProj, 
                                 crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ", 
                                 method = "ngb")


# note that the min and max values have now been forced to stay within the same range.
reprojectedData2


