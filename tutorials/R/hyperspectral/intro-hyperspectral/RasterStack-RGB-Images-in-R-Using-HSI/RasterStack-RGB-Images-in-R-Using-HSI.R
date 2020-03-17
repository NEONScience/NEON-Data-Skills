## ----load-libraries-----------------------------------------------------------------------------------------

# Load required packages
library(raster)
library(rhdf5)

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. Be sure to move the download into your working directory!
wd <- "~/Documents/data/" # This will depend on your local environment
setwd(wd)

# create path to file name
f <- paste0(wd,"NEON_hyperspectral_tutorial_example_subset.h5")



## ----view-file-structure, eval=FALSE, comment=NA------------------------------------------------------------
# View HDF5 file structure 
View(h5ls(f,all=T))



## ----get-spatial-attributes---------------------------------------------------------------------------------

# define coordinate reference system from the EPSG code provided in the HDF5 file
myEPSG <- h5read(f,"/SJER/Reflectance/Metadata/Coordinate_System/EPSG Code" )
myCRS <- crs(paste0("+init=epsg:",myEPSG))

# get the Reflectance_Data attributes
reflInfo <- h5readAttributes(f,"/SJER/Reflectance/Reflectance_Data" )

# Grab the UTM coordinates of the spatial extent
xMin <- reflInfo$Spatial_Extent_meters[1]
xMax <- reflInfo$Spatial_Extent_meters[2]
yMin <- reflInfo$Spatial_Extent_meters[3]
yMax <- reflInfo$Spatial_Extent_meters[4]

# define the extent (left, right, top, bottom)
rasExt <- extent(xMin,xMax,yMin,yMax)

# view the extent to make sure that it looks right
rasExt

# Finally, define the no data value for later
myNoDataValue <- as.integer(reflInfo$Data_Ignore_Value)
myNoDataValue


## ----function-read-refl-data--------------------------------------------------------------------------------

# file: the hdf file
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
    out[out == myNoDataValue] <- NA
	  
    # turn the out object into a raster
    outr <- raster(out,crs=CRS)
   
    # assign the extents to the raster
    extent(outr) <- extent
   
    # return the raster object
    return(outr)
}



## ----create-raster-stack------------------------------------------------------------------------------------

# create a list of the bands we want in our stack
rgb <- list(14,9,4) #list(58,34,19) when using full NEON hyperspectral dataset

# lapply tells R to apply the function to each element in the list
rgb_rast <- lapply(rgb,FUN=band2Raster, file = f,
                   noDataValue=myNoDataValue, 
                   extent=rasExt,
                   CRS=myCRS)

# check out the properties or rgb_rast
# note that it displays properties of 3 rasters.
rgb_rast

# finally, create a raster stack from our list of rasters
rgbStack <- stack(rgb_rast)



## ----plot-raster-stack--------------------------------------------------------------------------------------

# Create a list of band names
bandNames <- paste("Band_",unlist(rgb),sep="")

# set the rasterStack's names equal to the list of bandNames created above
names(rgbStack) <- bandNames

# check properties of the raster list - note the band names
rgbStack

# scale the data as specified in the reflInfo$Scale Factor
rgbStack <- rgbStack/as.integer(reflInfo$Scale_Factor)

# plot one raster in the stack to make sure things look OK.
plot(rgbStack$Band_14, main="Band 14")

	


## ----plot-HSI-raster----------------------------------------------------------------------------------------

# change the colors of our raster 
myCol <- terrain.colors(25)
image(rgbStack$Band_14, main="Band 14", col=myCol)

# adjust the zlims or the stretch of the image
myCol <- terrain.colors(25)
image(rgbStack$Band_14, main="Band 14", col=myCol, zlim = c(0,.5))

# try a different color palette
myCol <- topo.colors(15, alpha = 1)
image(rgbStack$Band_14, main="Band 14", col=myCol, zlim=c(0,.5))



## ----plot-RGB-Image-----------------------------------------------------------------------------------------
# create a 3 band RGB image
plotRGB(rgbStack,
        r=1,g=2,b=3,
        stretch = "lin")



## ----save-raster-geotiff, eval=FALSE, comment=NA------------------------------------------------------------

# write out final raster	
# note: if you set overwrite to TRUE, then you will overwite or lose the older
# version of the tif file! Keep this in mind.
writeRaster(rgbStack, file=paste0(wd,"NEON_hyperspectral_tutorial_example_RGB_stack_image.tif"), format="GTiff", overwrite=TRUE)



## ----create-NDVI--------------------------------------------------------------------------------------------

# Calculate NDVI
# select bands to use in calculation (red, NIR)
ndvi_bands <- c(16,24) #bands c(58,90) in full NEON hyperspectral dataset

# create raster list and then a stack using those two bands
ndvi_rast <- lapply(ndvi_bands,FUN=band2Raster, file = f,
                   noDataValue=myNoDataValue, 
                   extent=rasExt, CRS=myCRS)
ndvi_stack <- stack(ndvi_rast)

# make the names pretty
bandNDVINames <- paste("Band_",unlist(ndvi_bands),sep="")
names(ndvi_stack) <- bandNDVINames

# view the properties of the new raster stack
ndvi_stack

#calculate NDVI
NDVI <- function(x) {
	  (x[,2]-x[,1])/(x[,2]+x[,1])
}
ndvi_calc <- calc(ndvi_stack,NDVI)
plot(ndvi_calc, main="NDVI for the NEON SJER Field Site")

# Now, play with breaks and colors to create a meaningful map
# add a color map with 4 colors
myCol <- rev(terrain.colors(4)) # use the 'rev()' function to put green as the highest NDVI value
# add breaks to the colormap, including lowest and highest values (4 breaks = 3 segments)
brk <- c(0, .25, .5, .75, 1)

# plot the image using breaks
plot(ndvi_calc, main="NDVI for the NEON SJER Field Site", col=myCol, breaks=brk)


