

#load the raster package
library(raster)
library(sp)
#Set your working directory 

#setwd("~/Documents/data/CHM_InSitu_Data")
#setwd("C:/Users/lwasser/Documents/GitHub/neon_highered/")

setwd("C:/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/ESAWorkshop_data/Part3_LiDAR/")


DEM@crs
DEM@extent

plot(DEM)


#you can also crop the raster if you'd like. 


#create list of files to make raster stack
#path to files
tifPath <- (paste(getwd(),"/rasterLayers_tif",sep = ""))
rasterlist <- list.files(tifPath)

#create raster stack
rgbRaster <- stack(rasterlist)

#check to see that you've created a raster stack and plot the layers
rgbRaster
plot(rgbRaster)

#now we have a list of rasters in a stack. these rasters
#are all the same extent CRS and resolution but
#a raster brick will create one raster object in R that contains all of the rasters
#we can use this object to quickly create RGB images!

RGBbrick <- brick(rgbRaster)









