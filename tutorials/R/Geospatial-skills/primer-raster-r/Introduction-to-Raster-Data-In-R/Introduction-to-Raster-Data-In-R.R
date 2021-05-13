## ----load-libraries--------------------------------------------------

# load the raster, sp, and rgdal packages
library(raster)
library(sp)
library(rgdal)

# set working directory to data folder
#setwd("pathToDirHere")
wd <- ("~/Git/data/")
setwd(wd)



## ----load-raster-----------------------------------------------------
# load raster in an R object called 'DEM'
DEM <- raster(paste0(wd, "NEON-DS-Field-Site-Spatial-Data/SJER/DigitalTerrainModel/SJER2013_DTM.tif"))

# look at the raster attributes. 
DEM



## ----set-min-max-----------------------------------------------------

# calculate and save the min and max values of the raster to the raster object
DEM <- setMinMax(DEM)

# view raster attributes
DEM



## ----get-min-max-----------------------------------------------------

#Get min and max cell values from raster
#NOTE: this code may fail if the raster is too large
cellStats(DEM, min)
cellStats(DEM, max)
cellStats(DEM, range)



## ----crs-------------------------------------------------------------
#view coordinate reference system
DEM@crs


## ----view-extent-----------------------------------------------------
# view raster extent
DEM@extent



## ----histogram-------------------------------------------------------

# the distribution of values in the raster
hist(DEM, main="Distribution of elevation values", 
     col= "purple", 
     maxpixels=22000000)



## ----plot-raster-----------------------------------------------------

# plot the raster
# note that this raster represents a small region of the NEON SJER field site
plot(DEM, 
		 main="Digital Elevation Model, SJER") # add title with main


## ----PlotRaster------------------------------------------------------

# create a plot of our raster
image(DEM)

# specify the range of values that you want to plot in the DEM
# just plot pixels between 250 and 300 m in elevation
image(DEM, zlim=c(250,300))

# we can specify the colors too
col <- terrain.colors(5)
image(DEM, zlim=c(250,375), main="Digital Elevation Model (DEM)", col=col)



## ----plot-with-breaks------------------------------------------------

# add a color map with 5 colors
col=terrain.colors(5)

# add breaks to the colormap (6 breaks = 5 segments)
brk <- c(250, 300, 350, 400, 450, 500)

plot(DEM, col=col, breaks=brk, main="DEM with more breaks")


## ----legend-play-----------------------------------------------------
# First, expand right side of clipping rectangle to make room for the legend
# turn xpd off
par(xpd = FALSE, mar=c(5.1, 4.1, 4.1, 4.5))

# Second, plot w/ no legend
plot(DEM, col=col, breaks=brk, main="DEM with a Custom (but flipped) Legend", legend = FALSE)

# Third, turn xpd back on to force the legend to fit next to the plot.
par(xpd = TRUE)

# Fourth, add a legend - & make it appear outside of the plot
legend(par()$usr[2], 4110600,
        legend = c("lowest", "a bit higher", "middle ground", "higher yet", "highest"), 
        fill = col)



## ----flip-legend-----------------------------------------------------
# Expand right side of clipping rect to make room for the legend
par(xpd = FALSE,mar=c(5.1, 4.1, 4.1, 4.5))
#DEM with a custom legend
plot(DEM, col=col, breaks=brk, main="DEM with a Custom Legend",legend = FALSE)
#turn xpd back on to force the legend to fit next to the plot.
par(xpd = TRUE)

#add a legend - but make it appear outside of the plot
legend( par()$usr[2], 4110600,
        legend = c("Highest", "Higher yet", "Middle","A bit higher", "Lowest"), 
        fill = rev(col))


## ----add-color-map---------------------------------------------------

#add a color map with 4 colors
col=terrain.colors(4)
#add breaks to the colormap (6 breaks = 5 segments)
brk <- c(200, 300, 350, 400,500)
plot(DEM, col=col, breaks=brk, main="DEM with fewer breaks")



## ----raster-math-----------------------------------------------------

#multiple each pixel in the raster by 2
DEM2 <- DEM * 2

DEM2
#plot the new DEM
plot(DEM2, main="DEM with all values doubled")



## ----cropDEM, eval=FALSE, comment=NA---------------------------------

#plot the DEM
plot(DEM)

#Define the extent of the crop by clicking on the plot
cropbox1 <- drawExtent()

#crop the raster, then plot the new cropped raster
DEMcrop1 <- crop(DEM, cropbox1)

#plot the cropped extent
plot(DEMcrop1)



## ----cropDEMManual---------------------------------------------------

#define the crop extent
cropbox2 <-c(255077.3,257158.6,4109614,4110934)
#crop the raster
DEMcrop2 <- crop(DEM, cropbox2)
#plot cropped DEM
plot(DEMcrop2)



## ----challenge-code-name, include=TRUE, results="hide", echo=FALSE----

# load raster in an R object called 'DEM'
DSM <- rasterDSM <- raster(paste0(wd, "NEON-DS-Field-Site-Spatial-Data/SJER/DigitalSurfaceModel/SJER2013_DSM.tif"))
# convert from m to ft
DSM2 <- DSM * 3.3

DSM2

# add a color map with 3 colors
col=terrain.colors(3)

# add breaks to the colormap (6 breaks = 5 segments)
brk <- c(700, 1050, 1450, 1800)
plot(DSM2, col=col, breaks=brk, main="Digital Surface Model, SJER (ft)")


