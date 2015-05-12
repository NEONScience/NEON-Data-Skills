

#load the raster package
library(raster)
library(sp)

#Set your working directory to the folder where you saved the data
#for this lesson.

DEMTiff <- "DigitalTerrainModel/SJER2013_DTM.tif"
 
#DEM <- raster(paste(getwd(),DEMTiff,sep=""))

#import the raster
DEM <- raster(DEMTiff)

#notice that this raster already has a CRS and an extent assigned to it
DEM@crs
DEM@extent
#also notice it has a resolution and a set of dimension values associated with the raster
#this means less work for us!
DEM
#let's create a plot of our raster
plot(DEM, legend=T, main="Digital Elevation Model (DEM)")

#the image command allows you to plot more pixels
plot(DEM)
#specify the range of values that you want to plot
plot(DEM, zlim=c(250,300))

#add breaks to the colormap
brk <- c(250, 300, 350, 400,450,500)
plot(DEM, zlim=c(250,300), col=col, breaks=brk)


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


#create list of files to make raster stack
#list files in the rasterLayers_tif directory within the main working directory 
#note the use of full.names=TRUE This tells R to include the directory path.
rasterlist <- list.files('rasterLayers_tif',full.names=TRUE)

#create raster stack
rgbRaster <- stack(rasterlist)


#you can also expore the data
hist(rgbRaster)

#check to see that you've created a raster stack and plot the layers
rgbRaster
plot(rgbRaster)

#plot the raster as an RGB image. Note that you need to specify the order
#of the  bands in the image
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










