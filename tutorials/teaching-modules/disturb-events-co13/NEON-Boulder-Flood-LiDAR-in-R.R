## ----load-libraries------------------------------------------------------
# load libraries
library(raster)   # work with raster files
library(rgdal)    # work with raster files

# set working directory to ensure R can find the file we wish to import
#setwd("working-dir-path-here")

## ----open-DTMs-----------------------------------------------------------
# Load DTMs into R
DTM_pre <- raster("lidar/pre-flood/preDTM3.tif")
DTM_post <- raster("lidar/post-flood/postDTM3.tif")

# View raster structure
DTM_pre
DTM_post


## ----open-hillshade------------------------------------------------------
# import DSM hillshade
DTMpre_hill <- raster("lidar/pre-flood/preDTMhill3.tif")
DTMpost_hill <- raster("lidar/post-flood/postDTMhill3.tif")


## ----plot-rasters--------------------------------------------------------

# plot Pre-flood w/ hillshade
plot(DTMpre_hill,
        col=grey(1:100/100),  # create a color ramp of grey colors for hillshade
        legend=FALSE,         # no legend, we don't care about the grey of the hillshade
        main="Four Mile Canyon Creek, Boulder County\nPre-Flood",
        axes=FALSE)           # makes for a cleaner plot, if the coordinates aren't necessary

plot(DTM_pre, 
        axes=FALSE,
        alpha=0.5,   # sets how transparent the object will be (0=transparent, 1=not transparent)
        add=T)  # add=TRUE (or T), add plot to the previous plotting frame

# plot Post-flood w/ hillshade
# note, no add=T in this code, so new plotting frame. 
plot(DTMpost_hill,
        col=grey(1:100/100),  
        legend=FALSE,
        main="Four Mile Canyon Creek, Boulder County\nPost-Flood",
        axes=FALSE)

plot(DTM_post, 
        axes=FALSE,
        alpha=0.5,
        add=T)


## ----create-difference-model---------------------------------------------
# DoD: erosion to be neg, deposition to be positive, therefore post - pre
DoD <- DTM_post-DTM_pre

plot(DoD,
        main="Digital Elevation Model of Difference (DoD)",
        axes=FALSE)


## ----hist-DoD------------------------------------------------------------
# histogram of values in DoD
hist(DoD)


## ----pretty-diff-model---------------------------------------------------
# Color palette for 5 categories
difCol5 = c("#d7191c","#fdae61","#ffffbf","#abd9e9","#2c7bb6")

# Alternate palette for 7 categories - try it out!
#difCol7 = c("#d73027","#fc8d59","#fee090","#ffffbf","#e0f3f8","#91bfdb","#4575b4")

# plot hillshade first
plot(DTMpost_hill,
        col=grey(1:100/100),  # create a color ramp of grey colors
        legend=FALSE,
        main="Elevation Change Post Flood\nFour Mile Canyon Creek, Boulder County",
        axes=FALSE)

# add the DoD to it with specified breaks & colors
plot(DoD,
        breaks = c(-5,-1,-0.5,0.5,1,10),
        col= difCol5,
        axes=FALSE,
        alpha=0.4,
        add =T)


## ----crop-raster-man, eval=FALSE-----------------------------------------
## # plot the rasters you want to crop from
## plot(DTMpost_hill,
##         col=grey(1:100/100),  # create a color ramp of grey colors
##         legend=FALSE,
##         main="Four Mile Canyon Creek, Boulder County\nPre-Flood",
##         axes=FALSE)
## 
## plot(DoD,
##         breaks = c(-5,-1,-0.5,0.5,1,10),
##         col= difCol5,
##         axes=FALSE,
##         alpha=0.4,
##         add =T)
## 
## # crop by designating two opposite corners
## cropbox1<-drawExtent()
## 

## ----crop-raster-man-view------------------------------------------------
# view the extent of the cropbox1
cropbox1


## ----crop-raster-coords--------------------------------------------------
# desired coordinates of the box
cropbox2<-c(473792.6,474999,4434526,4435453)

## ----plot-crop-raster----------------------------------------------------
# crop desired layers to this cropbox
DTM_pre_crop <- crop(DTM_pre, cropbox2)
DTM_post_crop <- crop(DTM_post, cropbox2)
DTMpre_hill_crop <- crop(DTMpre_hill,cropbox2)
DTMpost_hill_crop <- crop(DTMpost_hill,cropbox2)
DoD_crop <- crop(DoD, cropbox2)

# plot all again using the cropped layers

# PRE
plot(DTMpre_hill_crop,
        col=grey(1:100/100),  # create a color ramp of grey colors
        legend=FALSE,
        main="Four Mile Canyon Creek, Boulder County\nPre-Flood",
        axes=FALSE)
# note \n in the title forces a line break in the title
plot(DTM_pre_crop, 
        axes=FALSE,
        alpha=0.5,
        add=T)

# POST
# plot Post-flood w/ hillshade
plot(DTMpost_hill_crop,
        col=grey(1:100/100),  # create a color ramp of grey colors
        legend=FALSE,
        main="Four Mile Canyon Creek, Boulder County\nPost-Flood",
        axes=FALSE)

plot(DTM_post_crop, 
        axes=FALSE,
        alpha=0.5,
        add=T)

# CHANGE - DoD
plot(DTMpost_hill_crop,
        col=grey(1:100/100),  # create a color ramp of grey colors
        legend=FALSE,
        main="Elevation Change Post Flood\nFour Mile Canyon Creek, Boulder County",
        axes=FALSE)

plot(DoD_crop,
        breaks = c(-5,-1,-0.5,0.5,1,10),
        col= difCol5,
        axes=FALSE,
        alpha=0.4,
        add =T)

