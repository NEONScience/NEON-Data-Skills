## ----load-libraries, results="hide"-----------------------------------------------------------------------------------------------------------------------------
library(terra)
library(rhdf5)
library(neonUtilities)


## ----set-wd-----------------------------------------------------------------------------------------------------------------------------------------------------
# set working directory (this will depend on your local environment)
wd <- "~/data/"
setwd(wd)


## ----download-refl, eval=FALSE----------------------------------------------------------------------------------------------------------------------------------
## byTileAOP(dpID = 'DP3.30006.001',
##           site = 'SJER',
##           year = '2021',
##           easting = 257500,
##           northing = 4112500,
##           savepath = wd)


## ----define-h5, results="hide"----------------------------------------------------------------------------------------------------------------------------------
# Define the h5 file name to be opened
h5_file <- paste0(wd,"DP3.30006.001/neon-aop-products/2021/FullSite/D17/2021_SJER_5/L3/Spectrometer/Reflectance/NEON_D17_SJER_DP3_257000_4112000_reflectance.h5")


## ----view-file-structure, eval=FALSE, comment=NA----------------------------------------------------------------------------------------------------------------
View(h5ls(h5_file,all=T))


## ----get-spatial-attributes-------------------------------------------------------------------------------------------------------------------------------------

# define coordinate reference system from the EPSG code provided in the HDF5 file
h5EPSG <- h5read(h5_file,"/SJER/Reflectance/Metadata/Coordinate_System/EPSG Code" )
h5CRS <- crs(paste0("+init=epsg:",h5EPSG))

# get the Reflectance_Data attributes
reflInfo <- h5readAttributes(h5_file,"/SJER/Reflectance/Reflectance_Data" )

# Grab the UTM coordinates of the spatial extent
xMin <- reflInfo$Spatial_Extent_meters[1]
xMax <- reflInfo$Spatial_Extent_meters[2]
yMin <- reflInfo$Spatial_Extent_meters[3]
yMax <- reflInfo$Spatial_Extent_meters[4]

# define the extent (left, right, top, bottom)
rastExt <- ext(xMin,xMax,yMin,yMax)

# view the extent to make sure that it looks right
rastExt

# Finally, define the no data value for later
h5NoDataValue <- as.integer(reflInfo$Data_Ignore_Value)
cat('No Data Value:',h5NoDataValue)


## ----function-read-refl-data------------------------------------------------------------------------------------------------------------------------------------

# file: the hdf5 file
# band: the band you want to process
# returns: a matrix containing the reflectance data for the specific band

band2Raster <- function(file, band, noDataValue, extent, CRS){
    # first, read in the raster
    out <- h5read(file,"/SJER/Reflectance/Reflectance_Data",index=list(band,NULL,NULL))
	  # Convert from array to matrix
	  out <- (out[1,,])
	  # transpose data to fix flipped row and column order 
    # depending upon how your data are formatted you might not have to perform this
    # step.
	  out <- t(out)
    # assign data ignore values to NA
    # note, you might chose to assign values of 15000 to NA
    out[out == noDataValue] <- NA
	  
    # turn the out object into a raster
    outr <- rast(out,crs=CRS)
   
    # assign the extents to the raster
    ext(outr) <- extent
   
    # return the terra raster object
    return(outr)
}



## ----create-raster-list-----------------------------------------------------------------------------------------------------------------------------------------

# create a list of the bands (R,G,B) we want to include in our stack
rgb <- list(58,34,19)

# lapply tells R to apply the function to each element in the list
rgb_rast <- lapply(rgb,FUN=band2Raster, file = h5_file,
                   noDataValue=h5NoDataValue, 
                   ext=rastExt,
                   CRS=h5CRS)


## ----rgb-rast-properties----------------------------------------------------------------------------------------------------------------------------------------
rgb_rast


## ----raster-stack-----------------------------------------------------------------------------------------------------------------------------------------------
rgbStack <- rast(rgb_rast)


## ----plot-raster-stack, fig.cap="Raster plot of band 14 from the raster stack created. The x-axis and y-axis values represent the extent, which range from 257500 to 258000 meters easting, and 4112500 to 4113000 meters northing, respectively. The plot legend depicts the range of reflectance values, which go from 0 to 0.8."----

# Create a list of band names
bandNames <- paste("Band_",unlist(rgb),sep="")

# set the rasterStack's names equal to the list of bandNames created above
names(rgbStack) <- bandNames

# check properties of the raster list - note the band names
rgbStack


## ----scale-plot-refl--------------------------------------------------------------------------------------------------------------------------------------------
# scale the data as specified in the reflInfo$Scale Factor
rgbStack <- rgbStack/as.integer(reflInfo$Scale_Factor)

# plot one raster in the stack to make sure things look OK.
plot(rgbStack$Band_58, main="Band 58")


## ----plot-HSI-raster, fig.cap=c("Raster plot of band 14 from the raster stack created using different colors available from the terrain.colors funtion. The x-axis and y-axis values represent the extent, which range from 257500 to 258000 meters easting, and 4112500 to 4113000 meters northing, respectively.","Raster plot of band 58 from the raster stack created with a 0.5 adjustment of the z plane, which causes the image to be stretched. The x-axis and y-axis values represent the extent, which range from 257500 to 25800 meters easting, and 4112500 to 4113000 meters northing, respectively. The plot legend depicts the range of reflectance values, which go from 0 to 0.8.","Raster plot of band 58 from the raster stack created using a different color palette. The x-axis and y-axis values represent the extent, which range from 257500 to 258000 meters easting, and 4112500 to 4113000 meters northing, respectively.")----

# change the colors of our raster 
colors1 <- terrain.colors(25)
image(rgbStack$Band_58, main="Band 58", col=colors1)

# adjust the zlims or the stretch of the image
image(rgbStack$Band_58, main="Band 58", col=colors1, zlim = c(0,.5))

# try a different color palette
colors2 <- topo.colors(15, alpha = 1)
image(rgbStack$Band_58, main="Band 58", col=colors2, zlim=c(0,.5))



## ----plot-RGB-Image, fig.cap="RGB image of a portion of the SJER field site using 3 bands fom the raster stack. Brightness values have been stretched using the stretch argument to produce a natural looking image."----
# create a 3 band RGB image
plotRGB(rgbStack,
        r=1,g=2,b=3,
        stretch = "lin")


## ----save-raster-geotiff, eval=FALSE, comment=NA----------------------------------------------------------------------------------------------------------------
# Write out final raster	
# Note: if you set overwrite to TRUE, then you will overwrite (and lose) any older version of the tif file! 
writeRaster(rgbStack, file=paste0(wd,"NEON_hyperspectral_tutorial_example_RGB_image.tif"), overwrite=TRUE)


## ----create-NDVI, fig.cap=c("Raster plot of a portion of the SJER field site showing calculated NDVI values. The x-axis and y-axis values represent the extent, which range from 257500 to 258000 meters easting, and 4112500 to 4113000 meters northing, respectively. Plot legend goes from -1 to 1.","Raster plot of a portion of the SJER field site showing calculated NDVI values with predefined breaks at 0, 0.25, 0.5, 05, and 1. The x-axis and y-axis values represent the extent, which range from 257500 to 258000 meters easting, and 4112500 to 4113000 meters northing, respectively. Plot legend goes from 0 to 1.")----

# Calculate NDVI
# select bands to use in calculation (red, NIR)
ndviBands <- c(58,90)

# create raster list and then a stack using those two bands
ndviRast <- lapply(ndviBands,FUN=band2Raster, file = h5_file,
                   noDataValue=h5NoDataValue, 
                   ext=rastExt, CRS=h5CRS)
ndviStack <- rast(ndviRast)

# make the names pretty
bandNDVINames <- paste("Band_",unlist(ndviBands),sep="")
names(ndviStack) <- bandNDVINames

# view the properties of the new raster stack
ndviStack

#calculate NDVI
NDVI <- function(x) {
	  (x[,2]-x[,1])/(x[,2]+x[,1])
}
ndviCalc <- app(ndviStack,NDVI)
plot(ndviCalc, main="NDVI for the NEON SJER Field Site")

# Now, play with breaks and colors to create a meaningful map
# add a color map with 4 colors
myCol <- rev(terrain.colors(4)) # use the 'rev()' function to put green as the highest NDVI value
# add breaks to the colormap, including lowest and highest values (4 breaks = 3 segments)
brk <- c(0, .25, .5, .75, 1)

# plot the image using breaks
plot(ndviCalc, main="NDVI for the NEON SJER Field Site", col=myCol, breaks=brk)


