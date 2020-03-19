## ----install-load-library, results="hide"----------------------------------------------------------------

# Load `raster` and `rhdf5` packages and read NIS data into R
library(raster)
library(rhdf5)
library(rgdal)

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. Be sure to move the download into your working directory!
wd <- "~/Documents/data/" #This will depend on your local environment
setwd(wd)

# Define the file name to be opened
f <- paste0(wd,"NEON_hyperspectral_tutorial_example_subset.h5")


## ----view-file-strux, eval=FALSE, comment=NA-------------------------------------------------------------
# look at the HDF5 file structure 
View(h5ls(f,all=T))


## ----read-band-wavelength-attributes---------------------------------------------------------------------

# get information about the wavelengths of this dataset
wavelengthInfo <- h5readAttributes(f,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
wavelengthInfo



## ----read-band-wavelengths-------------------------------------------------------------------------------
# read in the wavelength information from the HDF5 file
wavelengths <- h5read(f,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
head(wavelengths)
tail(wavelengths)



## ----get-reflectance-shape-------------------------------------------------------------------------------

# First, we need to extract the reflectance metadata:
reflInfo <- h5readAttributes(f, "/SJER/Reflectance/Reflectance_Data")
reflInfo

# Next, we read the different dimensions

nRows <- reflInfo$Dimensions[1]
nCols <- reflInfo$Dimensions[2]
nBands <- reflInfo$Dimensions[3]

nRows
nCols
nBands



## ----get-reflectance-shape-2-----------------------------------------------------------------------------
# Extract or "slice" data for band 9 from the HDF5 file
b9 <- h5read(f,"/SJER/Reflectance/Reflectance_Data",index=list(9,1:nCols,1:nRows)) 

# what type of object is b9?
class(b9)



## ----convert-to-matrix-----------------------------------------------------------------------------------

# convert from array to matrix by selecting only the first band
b9 <- b9[1,,]

# check it
class(b9)



## ----read-attributes-plot--------------------------------------------------------------------------------
    
# look at the metadata for the reflectance dataset
h5readAttributes(f,"/SJER/Reflectance/Reflectance_Data")

# plot the image
image(b9)

# oh, that is hard to visually interpret.
# what happens if we plot a log of the data?
image(log(b9))



## ----hist-data-------------------------------------------------------------------------------------------

# Plot range of reflectance values as a histogram to view range
# and distribution of values.
hist(b9,breaks=40,col="darkmagenta")

# View values between 0 and 5000
hist(b9,breaks=40,col="darkmagenta",xlim = c(0, 5000))
# View higher values
hist(b9, breaks=40,col="darkmagenta",xlim = c(5000, 15000),ylim=c(0,100))



## ----set-values-NA---------------------------------------------------------------------------------------

# there is a no data value in our raster - let's define it
myNoDataValue <- as.numeric(reflInfo$Data_Ignore_Value)
myNoDataValue

# set all values equal to -9999 to NA
b9[b9 == myNoDataValue] <- NA

# plot the image now
image(b9)



## ----plot-log--------------------------------------------------------------------------------------------

image(log(b9))



## ----transpose-data--------------------------------------------------------------------------------------

# We need to transpose x and y values in order for our 
# final image to plot properly
b9 <- t(b9)
image(log(b9), main="Transposed Image")


## ----define-CRS------------------------------------------------------------------------------------------

# Extract the EPSG from the h5 dataset
myEPSG <- h5read(f, "/SJER/Reflectance/Metadata/Coordinate_System/EPSG Code")

# convert the EPSG code to a CRS string
myCRS <- crs(paste0("+init=epsg:",myEPSG))

# define final raster with projection info 
# note that capitalization will throw errors on a MAC.
# if UTM is all caps it might cause an error!
b9r <- raster(b9, 
        crs=myCRS)

# view the raster attributes
b9r

# let's have a look at our properly oriented raster. Take note of the 
# coordinates on the x and y axis.

image(log(b9r), 
      xlab = "UTM Easting", 
      ylab = "UTM Northing",
      main = "Properly Oriented Raster")




## ----define-extent---------------------------------------------------------------------------------------
# Grab the UTM coordinates of the spatial extent
xMin <- reflInfo$Spatial_Extent_meters[1]
xMax <- reflInfo$Spatial_Extent_meters[2]
yMin <- reflInfo$Spatial_Extent_meters[3]
yMax <- reflInfo$Spatial_Extent_meters[4]

# define the extent (left, right, top, bottom)
rasExt <- extent(xMin,xMax,yMin,yMax)
rasExt

# assign the spatial extent to the raster
extent(b9r) <- rasExt

# look at raster attributes
b9r



## ----plot-colors-raster----------------------------------------------------------------------------------

# let's change the colors of our raster and adjust the zlims 
col <- terrain.colors(25)

image(b9r,  
      xlab = "UTM Easting", 
      ylab = "UTM Northing",
      main= "Raster w Custom Colors",
      col=col, 
      zlim=c(0,3000))



## ----write-raster,  eval=FALSE, comment=NA---------------------------------------------------------------

# write out the raster as a geotiff
writeRaster(b9r,
            file=paste0(wd,"band9.tif"),
            format="GTiff",
            overwrite=TRUE)

# It's always good practice to close the H5 connection before moving on!
# close the H5 file
H5close()


