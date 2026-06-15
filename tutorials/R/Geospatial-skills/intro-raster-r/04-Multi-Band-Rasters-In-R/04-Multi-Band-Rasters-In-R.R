

library(terra) # terra package to work with raster data
library(neonUtilities) # package for downloading NEON data
library(RColorBrewer) # package for specifying color palettes
token <- Sys.getenv("NEON_TOKEN") # read in API token

# set working directory to ensure R can find the file we wish to import
wd <- "~/data/" # this will depend on your local environment environment
# be sure that the downloaded file is in this directory
setwd(wd)



byTileAOP(dpID='DP3.30010.001', # rgb camera data
          site='HARV',
          year='2022',
          easting=732000,
          northing=4713500,
          check.size=FALSE, # set to TRUE or remove to check the size before downloading
          savepath = wd,
          token=token)



# read the file as a raster
rgb_harv_file <- paste0(wd, "DP3.30010.001/neon-aop-products/2022/FullSite/D01/2022_HARV_7/L3/Camera/Mosaic/2022_HARV_7_732000_4713000_image.tif")
RGB_HARV <- rast(rgb_harv_file)

# Create an RGB image from the raster using the terra "plot" function. Note "plot" shows the same image, since there are 3 bands
plotRGB(RGB_HARV, axes=F)
# plot(RGB_HARV, axes=F) < this gives the same result as plotRGB



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


crs(RGB_HARV, describe=TRUE)


# Replace Inf and -Inf with NA
values(RGB_HARV)[is.infinite(values(RGB_HARV))] <- NA

# Get min and max values for all bands
min_max_values <- minmax(RGB_HARV)

# Print the results
cat("Min and Max Values for All Bands:\n")
print(min_max_values)

# 
# # We'd expect a *brighter* value for the forest in band 2 (green) than in # band 1 (red) because the leaves on trees of most often appear "green" -
# # healthy leaves reflect MORE green light compared to red light.
# 

# What does stretch do?

# Plot the linearly stretched raster
plotRGB(RGB_HARV, stretch="lin")

# Plot the histogram-stretched raster
plotRGB(RGB_HARV, stretch="hist")


# 1
# methods for calling a stack
methods(class=class(RGB_HARV))
# 304 methods!

# 2
# methods for calling a band (1)
methods(class=class(RGB_HARV[1]))

# 72 There are more methods you can apply to a full stack (304) than you can apply to a single band (72).
