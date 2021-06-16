### Overview ###
# NIS Captures electromagnetic energy from sun reflected off Earth's surface
# Data organized by bands which are groups of wavelengths
# E.g. in abridged dataset, band 6 contains reflected light energy (reflectance data) from 480-485nm  
# Data stored in 1000x1000 matricies (1x1m resolution) for each band which are then stacked on each other
# Typically 426 bands, but abridged dataset has 107

# Collection conditions: Travel N-S to minimixze BRDF effects
## Ideally fly in <10% cloud cover
## Fly in >90% Peak Greenness conditions (determined by satellite data)
## Collect when solar angle is >40%
# QA decisions are run by TWG to get support of scientific community

######################################################################
######################################################################
######################################################################

### Plotting Tutorial ###

# Install packages
install.packages("BiocManager")
install.packages(BiocManager::install("rhdf5"))
install.packages('raster')
install.packages('rgdal')

#update.packages()

# Load in packages to read NIS data into R
library("BiocManager")
library("rhdf5")
library("raster")
library("rgdal")

# Set working directory. This is dependent on local environment
wd <- "C:/Users/kmurphy/Downloads/"
setwd(wd)

# Define the file name to be opened
f <- paste0(wd, "NEON_hyperspectral_tutorial_example_subset.h5")

# Look at the HDF5 file structure
# Outside of R, can use HDFView to see the structure in a GUI format
View(h5ls(f, all=T))

# Get information about the wavelengths of the dataset
wavelengthInfo <- h5readAttributes(f, "/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
wavelengthInfo

# Read in the wavelength information from the HDF5 file
wavelengths <- h5read(f, "/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")

# View subset of data
head(wavelengths)
head(wavelengths, n = 10)
tail(wavelengths)

# Band represents a group of wavelengths. Our bands are ~5 nm
# Depending on analysis, may only want to process certain bands
# E.g. NDVI only uses red and near infra-red portions of the spectrum
wavelengths[6]

# Extract reflectance metadata
# Note data ignore values and scale factor. SF used to avoid needing floats and saving on storage space
reflInfo <- h5readAttributes(f, "/SJER/Reflectance/Reflectance_Data")
reflInfo


# Read in different dimensions
nRows <- reflInfo$Dimensions[1]
nCols <- reflInfo$Dimensions[2]
nBands <- reflInfo$Dimensions[3]

nRows
nCols
nBands

# Extract data for band 9 from HDF5 file
# HDF5 stores data [Bands, Cols, Rows], but R reads in dataset as [Cols, Bands, Rows] so need to be aware when slicing
wavelengths[9]
b9 <- h5read(f,"/SJER/Reflectance/Reflectance_Data", index=list(9, 1:nCols, 1:nRows))
class(b9)

# Convert from array to matrix by selecting only the first band
# Arrays are matrices with more than 2 dimensions
b9 <- b9[1,,]
class(b9)

# Plot the image
image(b9)
# Image is difficult to distinguish because it is trying to equally weight reflectance values

# Plot the log of the data
image(log(b9))

# Plot the range of reflectance values as a histogram
hist(b9, breaks = 40, col = "darkmagenta")

# View values between 0 and 5000
hist(b9, breaks = 40, col = "darkmagenta", xlim = c(0,5000))

# View higher values
hist(b9, breaks = 40, col = "darkmagenta", xlim = c(5000,15000), ylim = c(0,100))

# Define no data value from metadata
myNoDataValue <- as.numeric(reflInfo$Data_Ignore_Value)
myNoDataValue

# Set all values equal to -9999 to NA
b9[b9 == myNoDataValue] <- NA

# Plot the image
image(b9)

# Plot the log of the image
image(log(b9))

# Apply image stretch
b9[b9>6000] <- 6000

# Plot the image
image(b9)

# Plot the log of the image
image(log(b9))

# Need to transpose x and y values to plot the image properly
# Accounts for difference in data order and the location of the "origin"
# Origin of data is LL corner whereas origin in R is UL
b9 <- t(b9)
image(log(b9), main = "Transposed Image")

# Need to define the Coordinate reference system (CRS) of the raster
# Extract the EPSG from the h5 dataset
myEPSG <- h5read(f, "/SJER/Reflectance/Metadata/Coordinate_System/EPSG Code")

# Convert the EPSG code to a CRS string
myCRS <- crs(paste0("+init=epsg:",myEPSG))

# Define the final raster with projection info
b9r <- raster(b9, crs=myCRS)

# View raster attributes
b9r

# View properly oriented raster
# Note coordinates on x and y axis
image(log(b9r), xlab = "UTM Easting", ylab = "UTM Northing", main = "Properly Oriented Raster")

# Use Reflectance Data defined as reflInfo above to define the extents of the raster
# Grab the UTM coordinates of the spatial extent
xMin <- reflInfo$Spatial_Extent_meters[1]
xMax <- reflInfo$Spatial_Extent_meters[2]
yMin <- reflInfo$Spatial_Extent_meters[3]
yMax <- reflInfo$Spatial_Extent_meters[4]

# Define the extent (left, right, top, bottom)
rasExt <- extent(xMin, xMax, yMin, yMax)
rasExt

# Assign the spatial extent to the raster
extent(b9r) <- rasExt

# View raster attributes
b9r

# Adjust colors of raster and the zlims
col <- terrain.colors(25)
image(b9r, xlab = "UTM Easting", ylab = "UTM Northing", main = "Raster w Custom Colors", col = col, zlim = c(0,3000))

# Write raster as geotiff
writeRaster(b9r,file=paste0(wd,"band9.tif"), format = "GTiff", overwrite = TRUE)

# Close the H5 file
H5close()

##########################################################################################################
##########################################################################################################
##########################################################################################################

### Stacking Tutorial ###

# Install and load packages
install.packages("maps")
library(maps)
library(raster)
library(rhdf5)

# Set working directory
setwd(wd)

# Create path to filename
#f <- paste0(wd, "NEON_hyperspectral_tutorial_example_subset.h5")

# View HDF5 file structure
View(h5ls(f,all=T))

# Spatially locate the raster by defining the CRS using the EPSG code from the HDF5 file
myEPSG <- h5read(f,"/SJER/Reflectance/Metadata/Coordinate_System/EPSG Code")
myCRS <- crs(paste0("+init=epsg:",myEPSG))

# Get the Reflectance_Data attributes
reflInfo <- h5readAttributes(f,"/SJER/Reflectance/Reflectance_Data")

# Use Reflectance Data defined as reflInfo above to define the extents of the raster
# Grab the UTM coordinates of the spatial extent
xMin <- reflInfo$Spatial_Extent_meters[1]
xMax <- reflInfo$Spatial_Extent_meters[2]
yMin <- reflInfo$Spatial_Extent_meters[3]
yMax <- reflInfo$Spatial_Extent_meters[4]

# Define the extent
rasExt <- extent(xMin, xMax, yMin, yMax)

# View the extent
rasExt

# Define the no data value
myNoDataValue <- as.integer(reflInfo$Data_Ignore_Value)
myNoDataValue

# Write a function that will do what we ran step by step above
# Will slice a band of data from HDF5 file, extract the reflectance, converts data to matrix
# Converts it to raster and returns a spatially corrected raster for the specified band

band2raster <- function(band, file, noDataValue, extent, CRS){
  # Read in raster
  out <- h5read(file, "/SJER/Reflectance/Reflectance_Data", index=list(band, NULL, NULL))
  # Convert from array to matrix
  out <- (out[1,,])
  # Transpose dat to fix flipped row and column order
  out <- t(out)
  # Assign data ignore values to NA
  out[out==myNoDataValue] <- NA
  # Turn out object to raster
  outr <- raster(out, crs=CRS)
  # Assign extents to the raster
  extent(outr) <- extent
  # Return the raster object
  return(outr)
}

# Create a list of the bands we want in our stack
rgb <- list(14,9,4) 
# rgb <- list(23,9,5) # Color Infrared/FalseColor
# rgb <- list(38,23,14) # SWIR, NIR, RedBand

# Note that this is only applicable for the abridged dataset
# Normally use list(58,34,19)

# Lapply tells R to apply the function to each element in the list
rgb_rast <- lapply(rgb, band2raster, file = f, noDataValue = myNoDataValue, extent = rasExt, CRS = myCRS)

# Display properties of rgb_rast
rgb_rast

# Create a raster stack from the list of rasters
rgbStack <- stack(rgb_rast)

# Add the names of the bands to the raster for easier tracking
# Create a list of band names
bandNames <- paste("Band_",unlist(rgb),sep="")

# Set the rasterStack's names equal to the list of bandNames
names(rgbStack) <- bandNames

# Check properties of the raster list -- note the band names
rgbStack

# Scale the data as specified in the reflInfo$Scale_Factor
rgbStack <- rgbStack/as.integer(reflInfo$Scale_Factor)

# Plot one raster in the stack to make sure things look good
plot(rgbStack$Band_14, main = "Band 14")

# Create an RGB image
plotRGB(rgbStack, r=1, g=2, b=3, stretch="lin")

# Write out final raster
writeRaster(rgbStack, file=paste0(wd, "NEON_hyperspectral_tutorial_example_RGB_stack_image.tif"), format="GTiff", overwrite=TRUE)

### Calculate NDVI ###
# Select red and NIR bands
ndvi_bands <- c(16,24) # Bands in full dataset are c(58,90)

# Create raster list and then a stack using those two bands
ndvi_rast <- lapply(ndvi_bands, band2raster, file = f, noDataValue = myNoDataValue, extent = rasExt, CRS = myCRS)
ndvi_stack <- stack(ndvi_rast)

# Assign names to bands in stacked raster
bandNDVINames <- paste("Band_", unlist(ndvi_bands),sep="")
names(ndvi_stack) <- bandNDVINames

# View properties of new raster stack
ndvi_stack

# Calculate NDVI
NDVI <- function(x){
  (x[,2]-x[,1])/(x[,2]+x[,1])
}

ndvi_calc <- calc(ndvi_stack,NDVI)
plot(ndvi_calc, main="NDVI for the NEON SJER Field Site")

# Manipulate the breaks and colors to create a meaningful map
# Add a color map with 4 colors
myCol <- rev(terrain.colors(4)) # rev() makes green the highest NDVI value

# Add breaks to the color map, including the lowest and highest values
# 4 breaks = 3 segments
brk <- c(0,0.25,0.5,0.75,1)

# Plot the image using breaks
plot(ndvi_calc, main="NDVI for the NEON SJER Field Site", col=myCol, breaks=brk)

H5close()
