#Because we will be exporting data in this activity, let's set the
#working directory before we go any further. The working directory 
#will determine where data are saved.
setwd("~/Conferences/1_DataWorkshop_ESA2014/ESAWorkshop_data/Part3_LiDAR")    

# Import DSM into R 
library(raster)

# IMPORTANT - the path to your DSM data may be different than the 
#path below.  
dsm_f <- "/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/ESAWorkshop_data/Part3_LiDAR/DigitalSurfaceModel/SJER2013_DSM.tif"

dsm <- raster(dsm_f)
## See info about the raster.
dsm
plot(dsm)

# import the digital terrain model
dtm_f <- "/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/ESAWorkshop_data/Part3_LiDAR/DigitalTerrainModel/SJER2013_DTM.tif"
dtm <- raster(dtm_f)
plot(dtm)


# Create a function that performs this raster math. Canopy height 
#is dsm - dtm
canopyCalc <- function(x, y) {
  return(x - y)
}

#use the function to perform the math that creates the final Canopy Height Model (CHM)
chm <- overlay(dsm,dtm,fun = canopyCalc)

plot(chm)

#write out the CHM in tiff format. We can look at this in any GIS software.
writeRaster(chm,"chm.tiff","GTiff")

#PART 2 - COMPARING CHM TO FIELD MEASURED TREE HEIGHTS

#first make sure we are calling the needed libraries
library(sp)
library(dplyr)

#import the centroid data and the vegetation structure data
options(stringsAsFactors=FALSE)
centroids <- read.csv("data/SJERPlotCentroids.csv")
insitu_dat <- read.csv("data/D17_2013_vegStr.csv")

#plot the chm
plot(chm)

#Overlay the centroid points and the stem locations on the CHM plot
#HINT: help(points) to see all of the options for plotting points. 
#for example, cex = point size 
points(centroids$easting,centroids$northing, pch=19, cex = 2,col = 2)
points(insitu_dat$easting,insitu_dat$northing, pch=19, cex=.5)


# Create a spatial ponts object using the CRS (coordinate 
#reference system) from the CHM and apply it to our plot centroid data.
#In this case, we know these data are all in the same projection
centroid_sp <- SpatialPoints(centroids[,4:3],proj4string =CRS(as.character(chm@crs)) )
