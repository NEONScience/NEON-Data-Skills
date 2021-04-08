## ----set-up------------------------------------------------------------

# load the raster, sp, and rgdal packages
library(raster)
library(sp)
library(rgdal)

# set the working directory to the data
#setwd("pathToDirHere")
wd <- ("C:/Users/mccahill/Documents/Github/")
setwd(wd)



## ----import-tiffs------------------------------------------------------

# import tiffs
band19 <- paste0(wd, "NEON-DS-Field-Site-Spatial-Data/SJER/RGB/band19.tif")
band34 <- paste0(wd, "NEON-DS-Field-Site-Spatial-Data/SJER/RGB/band34.tif")
band58 <- paste0(wd, "NEON-DS-Field-Site-Spatial-Data/SJER/RGB/band58.tif")

# View their attributes to check that they loaded correctly:
band19
band34
band58


## ----list-files--------------------------------------------------------
# create list of files to make raster stack
rasterlist1 <- list.files(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/RGB", full.names=TRUE))

rasterlist1



## ----list-files-tif----------------------------------------------------
rasterlist2 <-  list.files(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/RGB", full.names=TRUE, pattern="tif"))

rasterlist2



## ----r-stack-----------------------------------------------------------
# create raster stack
rgbRaster <- stack(band19,band34,band58)

# example syntax for stack from a list
#rstack1 <- stack(rasterlist1)


## ----view-stack--------------------------------------------------------
# check attributes
rgbRaster

# plot stack
plot(rgbRaster)



## ----plot-rgb----------------------------------------------------------
# plot an RGB version of the stack
plotRGB(rgbRaster,r=3,g=2,b=1, stretch = "lin")



## ----hist--------------------------------------------------------------
# view histogram of reflectance values for all rasters
hist(rgbRaster)


## ----stack-crop--------------------------------------------------------

# determine the desired extent
rgbCrop <- c(256770.7,256959,4112140,4112284)

# crop to desired extent
rgbRaster_crop <- crop(rgbRaster, rgbCrop)

# view cropped stack
plot(rgbRaster_crop)



## ----challenge-code-plot-crop-rgb, echo=FALSE--------------------------
# plot an RGB version of the cropped stack
plotRGB(rgbRaster_crop,r=3,g=2,b=1, stretch = "lin")



## ----create-r-brick----------------------------------------------------
# create raster brick
rgbBrick <- brick(rgbRaster)

# check attributes
rgbBrick



## ----rBrick-size-------------------------------------------------------
# view object size
object.size(rgbBrick)
object.size(rgbRaster)

# view raster brick
plotRGB(rgbBrick,r=3,g=2,b=1, stretch = "Lin")


## ----rgb-order-stack---------------------------------------------------
# Make a new stack in the order we want the data in 
orderRGBstack <- stack(rgbRaster$band58,rgbRaster$band34,rgbRaster$band19)

# write the geotiff
# change overwrite=TRUE to FALSE if you want to make sure you don't overwrite your files!
writeRaster(orderRGBstack,paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/RGB/rgbRaster.tif"),"GTiff", overwrite=TRUE)
                           


## ----import-multi-raster-----------------------------------------------

# import multi-band raster as stack
multiRasterS <- stack(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/RGB/rgbRaster.tif")) 

# import multi-band raster direct to brick
multiRasterB <- brick(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/RGB/rgbRaster.tif")) 

# view raster
plot(multiRasterB)
plotRGB(multiRasterB,r=1,g=2,b=3, stretch="lin")

