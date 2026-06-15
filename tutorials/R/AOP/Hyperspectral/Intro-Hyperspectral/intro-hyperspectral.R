
# Load `terra` and `rhdf5` packages to read NIS data into R
library(terra)
library(rhdf5)
library(neonUtilities)
# Read in NEON_TOKEN (see "Things You'll Need to Complete This Tutorial" section to set this up)
token <- Sys.getenv("NEON_TOKEN")


data_dir <- "~/data/" #This will depend on your local environment

# byTileAOP(dpID='DP3.30006.001',
#           site='SJER',
#           year='2021',
#           easting=257500,
#           northing=4112500,
#           check.size=TRUE, # set to FALSE if you don't want to enter y/n
#           savepath = data_dir,
#           token=token)

# Define the h5 file name to be opened
h5_file <- paste0(data_dir,"DP3.30006.001/neon-aop-products/2021/FullSite/D17/2021_SJER_5/L3/Spectrometer/Reflectance/NEON_D17_SJER_DP3_257000_4112000_reflectance.h5")

# # look at the HDF5 file structure
# View(h5ls(h5_file,all=T))


# get information about the wavelengths of this dataset
wavelengthInfo <- h5readAttributes(h5_file,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
wavelengthInfo


# read in the wavelength information from the HDF5 file
wavelengths <- h5read(h5_file,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
head(wavelengths)
tail(wavelengths)



# First, we need to extract the reflectance metadata:
reflInfo <- h5readAttributes(h5_file, "/SJER/Reflectance/Reflectance_Data")
reflInfo

# Next, we read the different dimensions

nRows <- reflInfo$Dimensions[1]
nCols <- reflInfo$Dimensions[2]
nBands <- reflInfo$Dimensions[3]

nRows
nCols
nBands


# Extract or "slice" data for band 34 from the HDF5 file
b34 <- h5read(h5_file,"/SJER/Reflectance/Reflectance_Data",index=list(34,1:nCols,1:nRows)) 

# what type of object is b34?
class(b34)



# convert from array to matrix by selecting only the first band
b34 <- b34[1,,]

# display the class of this re-defined variable
class(b34)


    
# look at the metadata for the reflectance dataset
h5readAttributes(h5_file,"/SJER/Reflectance/Reflectance_Data")

# plot the image
image(b34)


# this is a little hard to visually interpret - what happens if we plot a log of the data?
image(log(b34))


# Plot range of reflectance values as a histogram to view range
# and distribution of values.
hist(b34,breaks=50,col="darkmagenta")

# View values between 0 and 5000
hist(b34,breaks=100,col="darkmagenta",xlim = c(0, 5000))
# View higher values
hist(b34, breaks=100,col="darkmagenta",xlim = c(5000, 15000),ylim = c(0, 750))



# there is a no data value in our raster - let's define it
noDataValue <- as.numeric(reflInfo$Data_Ignore_Value)
noDataValue

# set all values equal to the no data value (-9999) to NA
b34[b34 == noDataValue] <- NA

# plot the image now
image(b34)



image(log(b34))



# We need to transpose x and y values in order for our 
# final image to plot properly
b34 <- t(b34)
image(log(b34), main="Transposed Image")


# Extract the EPSG from the h5 dataset
h5EPSG <- h5read(h5_file, "/SJER/Reflectance/Metadata/Coordinate_System/EPSG Code")

# convert the EPSG code to a CRS string
h5CRS <- crs(paste0("+init=epsg:",h5EPSG))

# define final raster with projection info 
# note that capitalization will throw errors on a MAC.
# if UTM is all caps it might cause an error!
b34r <- rast(b34, 
        crs=h5CRS)

# view the raster attributes
b34r

# let's have a look at our properly oriented raster. Take note of the 
# coordinates on the x and y axis.

image(log(b34r), 
      xlab = "UTM Easting", 
      ylab = "UTM Northing",
      main = "Properly Oriented Raster")


# Grab the UTM coordinates of the spatial extent
xMin <- reflInfo$Spatial_Extent_meters[1]
xMax <- reflInfo$Spatial_Extent_meters[2]
yMin <- reflInfo$Spatial_Extent_meters[3]
yMax <- reflInfo$Spatial_Extent_meters[4]

# define the extent (left, right, top, bottom)
rasExt <- ext(xMin,xMax,yMin,yMax)
rasExt

# assign the spatial extent to the raster
ext(b34r) <- rasExt

# look at raster attributes
b34r



# let's change the colors of our raster and adjust the zlim 
col <- terrain.colors(25)

image(b34r,  
      xlab = "UTM Easting", 
      ylab = "UTM Northing",
      main= "Spatially Referenced Raster",
      col=col, 
      zlim=c(0,3000))


# 
# # write out the raster as a geotiff
# writeRaster(b34r,
#             file=paste0(data_dir,"band34.tif"),
#             overwrite=TRUE)
# 
# # close the H5 file
# H5close()
# 
