## ----load-libraries-------------------------------------------------------------------------
# load libraries
library(raster)
library(rgdal)

# set working directory to ensure R can find the file we wish to import
wd <- "C:/Users/jbrown1/Documents/R Projects/data/" # this will depend on your local environment
# be sure that the downloaded file is in this directory
setwd(wd)


## ----open-raster, fig.cap="Digital surface model showing the elevation of NEON's site Harvard Forest"----
# Load raster into R
DSM_HARV <- raster(paste0(wd, "NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif"))

# View raster structure
DSM_HARV 

# plot raster
# note \n in the title forces a line break in the title
plot(DSM_HARV, 
     main="NEON Digital Surface Model\nHarvard Forest")



## ----elevation-map, fig.cap="Continuous elevation map of NEON's site Harvard Forest"--------
# render DSM for tutorial content background
DSM_HARV <- raster(paste0(wd, "NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif"))

# code output here - DEM rendered on the screen
plot(DSM_HARV, main="Continuous Elevation Map\n NEON Harvard Forest Field Site")



## ----classified-elevation-map, fig.cap="Classified elevation map of NEON's site Harvard Forest"----
# Demonstration image for the tutorial

# add a color map with 5 colors
col=terrain.colors(3)
# add breaks to the colormap (4 breaks = 3 segments)
brk <- c(250,350, 380,500)

# Expand right side of clipping rect to make room for the legend
par(xpd = FALSE,mar=c(5.1, 4.1, 4.1, 4.5))
# DEM with a custom legend
plot(DSM_HARV, 
	col=col, 
	breaks=brk, 
	main="Classified Elevation Map\nNEON Harvard Forest Field Site",
	legend = FALSE
	)

# turn xpd back on to force the legend to fit next to the plot.
par(xpd = TRUE)
# add a legend - but make it appear outside of the plot
legend( par()$usr[2], 4713700,
        legend = c("High Elevation", "Middle","Low Elevation"), 
        fill = rev(col))


## ----view-resolution-units------------------------------------------------------------------
# view resolution units
crs(DSM_HARV)

# assign crs to an object (class) to use for reprojection and other tasks
myCRS <- crs(DSM_HARV)
myCRS



## ----resolution-units-----------------------------------------------------------------------
crs(DSM_HARV)


## ----set-min-max----------------------------------------------------------------------------

# This is the code if min/max weren't calculated: 
# DSM_HARV <- setMinMax(DSM_HARV) 

# view the calculated min value
minValue(DSM_HARV)

# view only max value
maxValue(DSM_HARV)



## ----demonstrate-no-data-black, fig.cap="Colorized raster image with NoDataValues around the edge rendered in black"----
# no data demonstration code - not being taught 
# Use stack function to read in all bands
RGB_stack <- 
  stack(paste0(wd, "NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif"))

# Create an RGB image from the raster stack
par(col.axis="white",col.lab="white",tck=0)
plotRGB(RGB_stack, r = 1, g = 2, b = 3, 
        axes=TRUE, main="Raster With NoData Values\nRendered in Black")



## ----demonstrate-no-data, fig.cap="Colorized raster image with NoDataValues around the edge removed"----
# reassign cells with 0,0,0 to NA
# this is simply demonstration code - we will not teach this.
f <- function(x) {
  x[rowSums(x == 0) == 3, ] <- NA
  x}

newRGBImage <- calc(RGB_stack, f)


par(col.axis="white",col.lab="white",tck=0)
# Create an RGB image from the raster stack
plotRGB(newRGBImage, r = 1, g = 2, b = 3,
        axes=TRUE, main="Raster With No Data Values\nNoDataValue= NA")
 


## ----view-raster-histogram, fig.cap="Histogram showing the distribution of digital surface model values that has a default maximum pixels value of 100,000"----

# view histogram of data
hist(DSM_HARV,
     main="Distribution of Digital Surface Model Values\n Histogram Default: 100,000 pixels\n NEON Harvard Forest",
     xlab="DSM Elevation Value (m)",
     ylab="Frequency",
     col="wheat")



## ----view-raster-histogram2, fig.cap="Histogram showing the distribution of digital surface model values with all pixel values included"----

# View the total number of pixels (cells) in is our raster 
ncell(DSM_HARV)

# create histogram that includes with all pixel values in the raster
hist(DSM_HARV, 
     maxpixels=ncell(DSM_HARV),
     main="Distribution of DSM Values\n All Pixel Values Included\n NEON Harvard Forest Field Site",
     xlab="DSM Elevation Value (m)",
     ylab="Frequency",
     col="wheat4")



## ----view-raster-bands----------------------------------------------------------------------

# view number of bands
nlayers(DSM_HARV)



## ----view-attributes-gdal-------------------------------------------------------------------

# view attributes before opening file
GDALinfo(paste0(wd, "NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif"))



## ----challenge-code-attributes, eval=FALSE, echo=FALSE--------------------------------------
## GDALinfo(paste0(wd, "NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif"))
## 
## # ANSWERS ###
## # 1. If this file has the same CRS as DSM_HARV?  Yes: UTM Zone 18, WGS84, meters.
## # 2. What format `NoDataValues` take?  -9999
## # 3. The resolution of the raster data? 1x1
## # 4. How large a 5x5 pixel area would be? 5mx5m How? We are given resolution of
## #    1x1 and units in meters, therefore resolution of 5x5 means 5x5m.
## # 5. Is the file a multi- or single-band raster?  Single
## 

