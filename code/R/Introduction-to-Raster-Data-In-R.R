## ----load-libraries------------------------------------------------------

#load the raster, sp, and rgdal packages
library(raster)
library(sp)
library(rgdal)
#Set your working directory to the folder where your data for this workshop
#are stored. NOTE: if you created a project file in R studio, then you don't
#need to set the working directory as it's part of the project.
#setwd("~/yourWorkingDirectoryHere")  


## ----load-raster---------------------------------------------------------
#load raster in an R object called 'DEM'
DEM <- raster("DigitalTerrainModel/SJER2013_DTM.tif")  
# look at the raster attributes. 
DEM


## ----set-min-max---------------------------------------------------------

#calculate and save the min and max values of the raster to the raster object
DEM <- setMinMax(DEM)
#view raster attributes
DEM


## ----get-min-max---------------------------------------------------------

#Get min and max cell values from raster
#NOTE: this code may fail if the raster is too large
cellStats(DEM, min)
cellStats(DEM, max)
cellStats(DEM, range)


## ----view-crs-plot-------------------------------------------------------

#view coordinate reference system
DEM@crs
#view raster extent
DEM@extent
#plot the raster
#note that this raster represents a small region of the NEON SJER field site
plot(DEM, main="Digital Elevation Model, NEON Field Site")


## ----histogram-----------------------------------------------------------

#we can look at the distribution of values in the raster too
hist(DEM, main="Distribution of elevation values", 
     col= "purple", 
     maxpixels=21752940)


## ----raster-math---------------------------------------------------------

#multiple each pixel in the raster by 2
DEM2 <- DEM * 2

DEM2
#plot the new DEM
plot(DEM2, main="DEM with all values doubled")



## ----PlotRaster----------------------------------------------------------

#create a plot of our raster
image(DEM)
#specify the range of values that you want to plot in the DEM
#just plot pixels between 250 and 300 m in elevation
image(DEM, zlim=c(250,300))

#we can specify the colors too
col <- terrain.colors(5)
image(DEM, zlim=c(250,300), main="Digital Elevation Model (DEM)", col=col)


## ----plot-with-breaks----------------------------------------------------

#add a color map with 5 colors
col=terrain.colors(5)
#add breaks to the colormap (6 breaks = 5 segments)
brk <- c(250, 300, 350, 400,450,500)
plot(DEM, col=col, breaks=brk, main="DEM with more breaks")

# Expand right side of clipping rect to make room for the legend
par(xpd = FALSE,mar=c(5.1, 4.1, 4.1, 4.5))
#DEM with a custom legend
plot(DEM, col=col, breaks=brk, main="DEM with a Custom (buf flipped) Legend",legend = FALSE)

#turn xpd back on to force the legend to fit next to the plot.
par(xpd = TRUE)
#add a legend - but make it appear outside of the plot
legend( par()$usr[2], 4110600,
        legend = c("lowest", "a bit higher", "middle ground", "higher yet", "Highest"), 
        fill = col)


## ----plot-with-legend----------------------------------------------------


# Expand right side of clipping rect to make room for the legend
par(xpd = FALSE,mar=c(5.1, 4.1, 4.1, 4.5))
#DEM with a custom legend
plot(DEM, col=col, breaks=brk, main="DEM with a Custom Fixed Legend",legend = FALSE)
#turn xpd back on to force the legend to fit next to the plot.
par(xpd = TRUE)
#add a legend - but make it appear outside of the plot
legend( par()$usr[2], 4110600,
        legend = c("Highest", "Higher yet", "Middle","A bit higher", "Lowest"), 
        fill = rev(col))


## ----add-color-map-------------------------------------------------------

#add a color map with 4 colors
col=terrain.colors(4)
#add breaks to the colormap (6 breaks = 5 segments)
brk <- c(200, 300, 350, 400,500)
plot(DEM, col=col, breaks=brk, main="DEM with fewer breaks")


## ----cropDEM, eval=FALSE-------------------------------------------------
## 
## #plot the DEM
## plot(DEM)
## #Define the extent of the crop by clicking on the plot
## cropbox1 <- drawExtent()
## #crop the raster, then plot the new cropped raster
## DEMcrop1 <- crop(DEM, cropbox1)
## 
## #plot the cropped extent
## plot(DEMcrop1)
## 

## ----cropDEMManual-------------------------------------------------------

#define the crop extent
cropbox2 <-c(255077.3,257158.6,4109614,4110934)
#crop the raster
DEMcrop2 <- crop(DEM, cropbox2)
#plot cropped DEM
plot(DEMcrop2)


