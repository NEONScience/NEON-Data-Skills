## ----load-libraries--------------------------------------------------------------------------------------------------------------------------------------

# terra package to work with raster data
library(terra)

# package for downloading NEON data
library(neonUtilities)

# package for specifying color palettes
library(RColorBrewer)

# set working directory to ensure R can find the file we wish to import
wd <- "~/data/" # this will depend on your local environment environment
# be sure that the downloaded file is in this directory
setwd(wd)



## ----download-harv-camera-data---------------------------------------------------------------------------------------------------------------------------

byTileAOP(dpID='DP3.30010.001', # rgb camera data
          site='HARV',
          year='2022',
          easting=732000,
          northing=4713500,
          check.size=FALSE, # set to TRUE or remove if you want to check the size before downloading
          savepath = wd)



## ----demonstrate-RGB-Image, fig.cap="Red, green, and blue composite (true color) image of NEON's Harvard Forest (HARV) site", echo=FALSE-----------------

# read the file as a raster
rgb_harv_file <- paste0(wd, "DP3.30010.001/neon-aop-products/2022/FullSite/D01/2022_HARV_7/L3/Camera/Mosaic/2022_HARV_7_732000_4713000_image.tif")
RGB_HARV <- rast(rgb_harv_file)

# Create an RGB image from the raster using the terra "plot" function. Note "plot" shows the same image, since there are 3 bands
plotRGB(RGB_HARV, axes=F)
# plot(RGB_HARV, axes=F) < this gives the same result as plotRGB



## ----plot-RGB-now, fig.cap="Red, green, and blue bands of the camera imagery at NEON's Harvard Forest (HARV) site", echo=FALSE, message=FALSE------------

# Determine the number of bands
num_bands <- nlyr(RGB_HARV)

# Define colors to plot each
# Define color palettes for each band using RColorBrewer
colors <- list(
  brewer.pal(9, "Reds"),
  brewer.pal(9, "Greens"),
  brewer.pal(9, "Blues")
)

# Plot each band in a loop, with the specified colors
for (i in 1:num_bands) {
  plot(RGB_HARV[[i]], main=paste("Band", i), col=colors[[i]])
}


## ----read-single-band, fig.cap="Red band of NEON's site Harvard Forest"----------------------------------------------------------------------------------
 
# Read in multi-band raster with raster function. 
# Default is the first band only.
RGB_band1_HARV <- 
  raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif"))

# create a grayscale color palette to use for the image.
grayscale_colors <- gray.colors(100,            # number of different color levels 
                                start = 0.0,    # how black (0) to go
                                end = 1.0,      # how white (1) to go
                                gamma = 2.2,    # correction between how a digital 
                                # camera sees the world and how human eyes see it
                                alpha = NULL)   #Null=colors are not transparent

# Plot band 1
plot(RGB_band1_HARV, 
     col=grayscale_colors, 
     axes=FALSE,
     main="RGB Imagery - Band 1-Red\nNEON Harvard Forest Field Site") 

# view attributes: Check out dimension, CRS, resolution, values attributes, and 
# band.
RGB_band1_HARV


## ----raster-attributes-----------------------------------------------------------------------------------------------------------------------------------
# Print dimensions
cat("Dimensions:\n")
cat("Number of rows:", nrow(RGB_HARV), "\n")
cat("Number of columns:", ncol(RGB_HARV), "\n")
cat("Number of layers:", nlyr(RGB_HARV), "\n")

# Print resolution
resolutions <- res(RGB_HARV)
cat("Resolution:\n")
cat("X resolution:", resolutions[1], "\n")
cat("Y resolution:", resolutions[2], "\n")

# Get the extent of the raster
rgb_extent <- ext(RGB_HARV)

# Convert the extent to a string with rounded values
extent_str <- sprintf("xmin: %d, xmax: %d, ymin: %d, ymax: %d", 
                      round(xmin(rgb_extent)), 
                      round(xmax(rgb_extent)), 
                      round(ymin(rgb_extent)), 
                      round(ymax(rgb_extent)))

# Print the extent string
cat("Extent of the raster: \n")
cat(extent_str, "\n")



## ----print-CRS-------------------------------------------------------------------------------------------------------------------------------------------
crs(RGB_HARV, describe=TRUE)


## ----min-max-image---------------------------------------------------------------------------------------------------------------------------------------

# Replace Inf and -Inf with NA
values(RGB_HARV)[is.infinite(values(RGB_HARV))] <- NA

# Get min and max values for all bands
min_max_values <- minmax(RGB_HARV)

# Print the results
cat("Min and Max Values for All Bands:\n")
print(min_max_values)


## ----challenge1-answer, eval=FALSE, echo=FALSE-----------------------------------------------------------------------------------------------------------
## 
## # We'd expect a *brighter* value for the forest in band 2 (green) than in # band 1 (red) because the leaves on trees of most often appear "green" -
## # healthy leaves reflect MORE green light compared to red light.
## 


## ----image-stretch, fig.cap=c("Composite RGB image of HARV with a linear stretch", "Composite RGB image of HARV with a histogram stretch")---------------
# What does stretch do?

# Plot the linearly stretched raster
plotRGB(RGB_HARV_lin_stretch, stretch="lin")

# Plot the histogram-stretched raster
plotRGB(RGB_HARV_lin_stretch, stretch="hist")



## ----challenge-code-calling-methods, include=TRUE, results="hide", echo=FALSE----------------------------------------------------------------------------
# 1
# methods for calling a stack
methods(class=class(RGB_HARV))
# 304 methods!

# 2
# methods for calling a band (1)
methods(class=class(RGB_HARV[1]))

# 72 There are more methods you can apply to a full stack (304) than you can apply to a single band (72).

