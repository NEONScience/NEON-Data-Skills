#load the raster, sp, and rgdal packages
library(raster)
library(sp)
library(rgdal)
#Set your working directory to the folder where your data for this workshop
#are stored. NOTE: if you created a project file in R studio, then you don't
#need to set the working directory as it's part of the project.
setwd("~/yourWorkingDirectoryHere")  

#create list of files to make raster stack
rasterlist <-  list.files('rasterLayers_tif', full.names=TRUE, pattern=".tif")
rasterlist

#create raster stack
rgbRaster <- stack(rasterlist)

#check to see that you've created a raster stack and plot the layers
rgbRaster
plot(rgbRaster)

#plot an RGB version of the stack
plotRGB(rgbRaster,r=3,g=2,b=1, scale=800, stretch = "Lin")

#look at histogram of reflectance values for all rasters
hist(rgbRaster)

#remember that crop function? You can crop all rasters within a raster stack too
#finally you can crop all rasters within a raster stack!
rgbCrop <- c(256770.7,256959,4112140,4112284)
rgbRaster_crop <- crop(rgbRaster, rgbCrop)
plot(rgbRaster_crop)

#create raster brick
rgbBrick <- brick(rgbRaster)
plotRGB(rgbBrick,r=3,g=2,b=1, scale=800, stretch = "Lin")

#look at the difference in size between the brick and the stack
#the brick contains ALL of the data stored in one object
#the stack contains links or references to the files stored on your computer
object.size(rgbBrick)
object.size(rgbRaster)

#Make a new stack in the order we want the data in: 
finalRGBstack <- stack(rgbRaster$band58,rgbRaster$band34,rgbRaster$band19)
#write the geotiff - change overwrite=TRUE to overwrite=FALSE if you want to make sure you don't overwrite your files!
writeRaster(finalRGBstack,"rgbRaster.tif","GTiff", overwrite=TRUE)

#Import Multi-Band raster
newRaster <- stack("rgbRaster.tif") 
plot(newRaster)
plotRGB(newRaster,r=1,g=2,b=3, scale=800, stretch = "Lin")

