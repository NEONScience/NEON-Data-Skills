## ----install-load-library, results="hide"------------------------------------------------------------------------------------------------------------------

# Load `terra` and `rhdf5` packages to read NIS data into R
library(terra)
library(rhdf5)
library(neonUtilities)


## ----set-wd, results="hide"--------------------------------------------------------------------------------------------------------------------------------

wd <- "~/data/" #This will depend on your local environment
setwd(wd)


## ----download-refl, eval=FALSE-----------------------------------------------------------------------------------------------------------------------------
## byTileAOP(dpID='DP3.30006.001',
##           site='SJER',
##           year='2021',
##           easting=257500,
##           northing=4112500,
##           check.size=TRUE, # can set to FALSE if you don't want to enter y/n
##           savepath = wd)


## ----define-h5, results="hide"-----------------------------------------------------------------------------------------------------------------------------
# Define the h5 file name to be opened
h5_file <- paste0(wd,"DP3.30006.001/neon-aop-products/2021/FullSite/D17/2021_SJER_5/L3/Spectrometer/Reflectance/NEON_D17_SJER_DP3_257000_4112000_reflectance.h5")


## ----view-file-strux, eval=FALSE, comment=NA---------------------------------------------------------------------------------------------------------------
# look at the HDF5 file structure 
View(h5ls(h5_file,all=T))


## ----read-band-wavelength-attributes-----------------------------------------------------------------------------------------------------------------------

# get information about the wavelengths of this dataset
wavelengthInfo <- h5readAttributes(h5_file,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
wavelengthInfo



## ----read-band-wavelengths---------------------------------------------------------------------------------------------------------------------------------
# read in the wavelength information from the HDF5 file
wavelengths <- h5read(h5_file,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
head(wavelengths)
tail(wavelengths)



## ----get-reflectance-shape---------------------------------------------------------------------------------------------------------------------------------

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



## ----get-reflectance-shape-2-------------------------------------------------------------------------------------------------------------------------------
# Extract or "slice" data for band 34 from the HDF5 file
b34 <- h5read(h5_file,"/SJER/Reflectance/Reflectance_Data",index=list(34,1:nCols,1:nRows)) 

# what type of object is b34?
class(b34)



## ----convert-to-matrix-------------------------------------------------------------------------------------------------------------------------------------

# convert from array to matrix by selecting only the first band
b34 <- b34[1,,]

# display the class of this re-defined variable
class(b34)



## ----read-attributes-plot, fig.cap=c("Plot of reflectance values for band 34 data. This plot shows a very washed out image lacking any detail.","Plot of log transformed reflectance values for band 34 data. Log transformation improved the visibility of details in the image, but it is still not great.")----
    
# look at the metadata for the reflectance dataset
h5readAttributes(h5_file,"/SJER/Reflectance/Reflectance_Data")

# plot the image
image(b34)



## ----plot-log-b34------------------------------------------------------------------------------------------------------------------------------------------
# this is a little hard to visually interpret - what happens if we plot a log of the data?
image(log(b34))


## ----hist-data, fig.cap=c("Histogram of reflectance values for band 34. The x-axis represents the reflectance values and ranges from 0 to 8000. The frequency of these values is on the y-axis. The histogram shows reflectance values are skewed to the right, where the majority of the values lie between 0 and 1000. We can conclude that reflectance values are not equally distributed across the range of reflectance values, resulting in a washed out image.","Histogram of reflectance values between 0 and 5000 for band 34. Reflectance values are on the x-axis, and the frequency is on the y-axis. The x-axis limit has been set 5000 in order to better visualize the distribution of reflectance values. We can confirm that the majority of the values are indeed within the 0 to 4000 range.","Histogram of reflectance values between 5000 and 15000 for band 34. Reflectance values are on the x-axis, and the frequency is on the y-axis. Plot shows that a very few number of pixels have reflectance values larger than 5,000. These values are skewing how the image is being rendered and heavily impacting the way the image is drawn on our monitor.")----

# Plot range of reflectance values as a histogram to view range
# and distribution of values.
hist(b34,breaks=50,col="darkmagenta")

# View values between 0 and 5000
hist(b34,breaks=100,col="darkmagenta",xlim = c(0, 5000))
# View higher values
hist(b34, breaks=100,col="darkmagenta",xlim = c(5000, 15000),ylim = c(0, 750))



## ----set-values-NA, fig.cap="Plot of reflectance values for band 34 data with values equal to -9999 set to NA. Image data in raster format will often contain no data values, which may be attributed to the sensor not collecting data in that area of the image or to processing results which yield null values. Reflectance datasets designate -9999 as data ignore values. As such, we will reassign -9999 values to NA so R won't try to render these pixels."----

# there is a no data value in our raster - let's define it
noDataValue <- as.numeric(reflInfo$Data_Ignore_Value)
noDataValue

# set all values equal to the no data value (-9999) to NA
b34[b34 == noDataValue] <- NA

# plot the image now
image(b34)



## ----plot-log, fig.cap="Plot of log transformed reflectance values for the previous b34 image. Applying the log to the image increases the contrast making it look more like an image by factoring out those larger values. While an improvement, the image is still far from great. The proper way to adjust an image is by doing whats called an image stretch."----

image(log(b34))



## ----transpose-data, fig.cap="Plot showing the transposed image of the log transformed reflectance values of b34. The orientation of the image is rotated in our log transformed image, because R reads in the matrices starting from the upper left hand corner."----

# We need to transpose x and y values in order for our 
# final image to plot properly
b34 <- t(b34)
image(log(b34), main="Transposed Image")


## ----define-CRS, fig.cap="Plot of the properly oriented raster image of the band 34 data. In order to orient the image correctly, the coordinate reference system was defined and assigned to the raster object. X-axis represents the UTM Easting values, and the Y-axis represents the Northing values."----

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



## ----define-extent-----------------------------------------------------------------------------------------------------------------------------------------
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



## ----plot-colors-raster, fig.cap="Plot of the properly oriented raster image of B34 with custom colors. We can adjust the colors of the image by adjusting the z limits, which in this case makes the highly reflective surfaces more vibrant. This color adjustment is more apparent in the bottom left of the image, where the parking lot, buildings and bare surfaces are located. The X-axis represents the UTM Easting values, and the Y-axis represents the Northing values."----

# let's change the colors of our raster and adjust the zlim 
col <- terrain.colors(25)

image(b34r,  
      xlab = "UTM Easting", 
      ylab = "UTM Northing",
      main= "Spatially Referenced Raster",
      col=col, 
      zlim=c(0,3000))



## ----write-raster,  eval=FALSE, comment=NA-----------------------------------------------------------------------------------------------------------------

# write out the raster as a geotiff
writeRaster(b34r,
            file=paste0(wd,"band34.tif"),
            overwrite=TRUE)

# close the H5 file
H5close()


