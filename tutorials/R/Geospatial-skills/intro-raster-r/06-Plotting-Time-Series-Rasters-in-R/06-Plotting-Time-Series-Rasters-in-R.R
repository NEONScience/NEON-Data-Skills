## ----load-libraries-data-----------------------------------------------
# import libraries
library(raster)
library(rgdal)
library(rasterVis)
library(RColorBrewer)

# set working directory to ensure R can find the file we wish to import
wd <- "~/Git/data/" # this will depend on your local environment environment
# be sure that the downloaded file is in this directory
setwd(wd)

# Create list of NDVI file paths
all_NDVI_HARV <- list.files(paste0(wd,"NEON-DS-Landsat-NDVI/HARV/2011/NDVI"), full.names = TRUE, pattern = ".tif$")

# Create a time series raster stack
NDVI_HARV_stack <- stack(all_NDVI_HARV)

# apply scale factor
NDVI_HARV_stack <- NDVI_HARV_stack/10000



## ----plot-time-series, fig.cap="Plot of all the NDVI rasters for NEON's site Harvard Forest"----
# view a plot of all of the rasters
# nc specifies number of columns
plot(NDVI_HARV_stack, nc = 4)



## ----levelplot-time-series, fig.cap="Levelplot of all the NDVI rasters for NEON's site Harvard Forest"----
# create a `levelplot` plot
levelplot(NDVI_HARV_stack,
          main="Landsat NDVI\nNEON Harvard Forest")



## ----change-color-ramp, fig.cap="Levelplot of all the NDVI rasters for NEON's site Harvard Forest with a new color palette"----
# use colorbrewer which loads with the rasterVis package to generate
# a color ramp of yellow to green
cols <- colorRampPalette(brewer.pal(9,"YlGn"))
# create a level plot - plot
levelplot(NDVI_HARV_stack,
        main="Landsat NDVI -- Improved Colors \nNEON Harvard Forest Field Site",
        col.regions=cols)



## ----clean-up-names----------------------------------------------------

# view names for each raster layer
names(NDVI_HARV_stack)

# use gsub to modify label names.that we'll use for the plot 
rasterNames  <- gsub("X","Day ", names(NDVI_HARV_stack))

# view Names
rasterNames

# Remove HARV_NDVI_crop from the second part of the string 
rasterNames  <- gsub("_HARV_ndvi_crop","",rasterNames)

# view names for each raster layer
rasterNames


## ----create-levelplot, fig.cap="Levelplot of all the NDVI rasters for NEON's site Harvard Forest with a legend, a 4x4layout, and each raster labeled with the Julian Day"----

# use level plot to create a nice plot with one legend and a 4x4 layout.
levelplot(NDVI_HARV_stack,
          layout=c(4, 4), # create a 4x4 layout for the data
          col.regions=cols, # add a color ramp
          main="Landsat NDVI - Julian Days \nHarvard Forest 2011",
          names.attr=rasterNames)



## ----adjust-layout, fig.cap="Levelplot of all the NDVI rasters for NEON's site Harvard Forest with a legend, a 5x3 layout, and each raster labeled with the Julian Day"----
# use level plot to create a nice plot with one legend and a 4x4 layout.
levelplot(NDVI_HARV_stack,
          layout=c(5, 3), # create a 5x3 layout for the data
          col.regions=cols, # add a color ramp
          main="Landsat NDVI - Julian Days \nHarvard Forest 2011",
          names.attr=rasterNames)


## ----remove-axis-ticks, fig.cap="Levelplot of all the NDVI rasters for NEON's site Harvard Forest with a legend, no axes, and each raster labeled with the Julian Day"----
# use level plot to create a nice plot with one legend and a 4x4 layout.
levelplot(NDVI_HARV_stack,
          layout=c(5, 3), # create a 5x3 layout for the data
          col.regions=cols, # add a color ramp
          main="Landsat NDVI - Julian Days \nHarvard Forest 2011",
          names.attr=rasterNames,
          scales=list(draw=FALSE )) # remove axes labels & ticks


## ----challenge-code-levelplot-divergent, fig.cap="Levelplot of all the NDVI rasters for NEON's site Harvard Forest with a legend, a 5x3 layout, a divergent color palette, and each raster labeled with the Julian Day", echo=FALSE----
# change Day to Julian Day 
rasterNames  <- gsub("Day","Julian Day ", rasterNames)

# use level plot to create a nice plot with one legend and a 5x3 layout.
levelplot(NDVI_HARV_stack,
      layout=c(5, 3), # create a 4x3 layout for the data
      col.regions=colorRampPalette(brewer.pal(9, "BrBG")), # specify color 
      main="Landsat NDVI - Julian Days - 2011 \nNEON Harvard Forest Field Site",
      names.attr=rasterNames)

# The sequential is better than the divergent as it is more akin to the process
# of greening up, which starts off at one end and just keeps increasing. 


