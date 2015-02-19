

#load the raster package
library(raster)
library(sp)
#Set your working directory 

#setwd("~/Documents/WorkshopData/")

setwd("C:/Users/lwasser/Documents/WorkshopData/ESAWorkshop_data/Part3_LiDAR")

#setwd("C:/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/ESAWorkshop_data/Part3_LiDAR/")
#DEMTiff <- "/CHM_InSitu_Data/DigitalSurfaceModel/SJER2013_DSM.tif"
DEMTiff <- "/DigitalTerrainModel/SJER2013_DTM.tif"
DEM <- raster(paste(getwd(),DEMTiff,sep=""))

#notice that this raster already has a CRS and an extent assigned to it
DEM@crs
DEM@extent
#also notice it has a resolution and a set of dimension values associated with the raster
#this means less work for us!
DEM
#let's create a plot of our raster
plot(DEM)

#here's the cool part. you can crop the raster right in the plot area
#first define the extent by running the line of code below
#first, click in the upper left hand corner where you want the crop to begin
# next click somewher in the lower right hand corner to define the bottomr right
#corner of your extent box you will see
#note: this is a manual process!
cropBox <- drawExtent()
#crop the raster then plot the new cropped raster
DEMcrop <- crop(DEM, cropBox)
plot(DEMcrop)

#you can also manually assign the coordinate to use to crop
#you'll need the extent defined as (xmin,xmax,ymin,ymax) to do this.
#this is how you'd crop using a GIS shapefile (with a rectangular shape)
cropbox2 <-c(255077.3,257158.6,4109614,4110934)
DEMcrop2 <- crop(DEM, cropbox2)
plot(DEMcrop2)


#############################
#part 2!
#############################

#next we'll work with the rasters in the rasterLayers_tif folder. 
#to begin let's tell R where we're working
setwd("C:/Users/lwasser/Documents/WorkshopData/rasterLayers_tif")

#setwd(paste(getwd(),"/rasterLayers_tif",sep = ""))

#create list of files to make raster stack
#list files in the working directory 
rasterlist <- list.files()

#create raster stack
rgbRaster <- stack(rasterlist)

#you can also expore the data
hist(rgbRaster)

#check to see that you've created a raster stack and plot the layers
rgbRaster
plot(rgbRaster)
plotRGB(rgbRaster,r=3,g=2,b=1, scale=800, stretch = "Lin")

#remember that crop function? You can crop all rasters within a raster stack too
#finally you can crop all rasters within a raster stack!
rgbCrop <- c(256770.7,256959,4112140,4112284)
rgbRaster_crop <- crop(rgbRaster, rgbCrop)
plot(rgbRaster_crop)

#now we have a list of rasters in a stack. these rasters
#are all the same extent CRS and resolution but
#a raster brick will create one raster object in R that contains all of the rasters
#we can use this object to quickly create RGB images!

RGBbrick <- brick(rgbRaster)


#write out the raster in tiff format
#note that this writes the raster in the order they are in - in the stack. 
#in this case, the blue (band 19) is first but it's looking for the red band first (RGB)
#so we can make a new stack in the order we want the data in:

finalRGBstack <- stack(rgbRaster$band58,rgbRaster$band34,rgbRaster$band19)

writeRaster(finalRGBstack,"rgbRaster.tiff","GTiff", overwrite=TRUE)










