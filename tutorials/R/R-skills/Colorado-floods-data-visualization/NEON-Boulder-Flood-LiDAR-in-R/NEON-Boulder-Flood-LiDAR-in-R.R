## ----load-libraries-----------------------------
# load libraries
library(raster)   # work with raster files
library(rgdal)    # work with raster files

## Set your working directory to ensure R can find the file we wish to import and where we want to save our files. Be sure to move the downloaded files into your working directory!
wd <- "C:/Users/fsanchez/Documents/data/" # This will depend on your local environment
setwd(wd)


## ----open-DTMs----------------------------------
# Load DTMs into R
DTM_pre <- raster(paste0(wd,"disturb-events-co13/lidar/pre-flood/preDTM3.tif"))
DTM_post <- raster(paste0(wd,"disturb-events-co13/lidar/post-flood/postDTM3.tif"))

# View raster structure
DTM_pre
DTM_post



## ----open-hillshade-----------------------------

# Creating hillshade for DTM_pre & DTM_post
# In order to generate the hillshde, we need both the slope and the aspect of
# the extent we are working on. 


DTM_pre_slope <- terrain(DTM_pre, opt="slope",units = "radians")
DTM_pre_aspect <- terrain(DTM_pre, opt ="aspect", units = "radians")
DTM_pre_hillshade <- hillShade(DTM_pre_slope, DTM_pre_aspect)

DTM_post_slope <- terrain(DTM_post, opt="slope",units = "radians")
DTM_post_aspect <- terrain(DTM_post, opt ="aspect", units = "radians")
DTM_post_hillshade <- hillShade(DTM_post_slope, DTM_post_aspect)



## ----plot-rasters, fig.cap=c("Raster Plot of Four Mile Creek, Boulder County, Pre-Flood. This figure combines the DTM and hillshade raster objects into one plot.","Raster Plot of Four Mile Creek, Boulder County, Post-Flood. This figure combines the DTM and hillshade raster objects into one plot.")----

# plot Pre-flood w/ hillshade
plot(DTM_pre_hillshade,
        col=grey(1:90/100),  # create a color ramp of grey colors for hillshade
        legend=FALSE,         # no legend, we don't care about the grey of the hillshade
        main="Four Mile Canyon Creek, Boulder County\nPre-Flood",
        axes=FALSE)           # makes for a cleaner plot, if the coordinates aren't necessary

plot(DTM_pre, 
        axes=FALSE,
        alpha=0.3,   # sets how transparent the object will be (0=transparent, 1=not transparent)
        add=TRUE)  # add=TRUE (or T), add plot to the previous plotting frame

# plot Post-flood w/ hillshade
# note, no add=T in this code, so new plotting frame. 
plot(DTM_post_hillshade,
        col=grey(1:90/100),  
        legend=FALSE,
        main="Four Mile Canyon Creek, Boulder County\nPost-Flood",
        axes=FALSE)

plot(DTM_post, 
        axes=FALSE,
        alpha=0.3,
        add=T)



## ----create-difference-model, fig.cap="Digital Elevation Model of Difference showing the difference between digital elevation models (DTM)."----
# DoD: erosion to be neg, deposition to be positive, therefore post - pre
DoD <- DTM_post-DTM_pre

plot(DoD,
        main="Digital Elevation Model of Difference (DoD)",
        axes=FALSE)



## ----hist-DoD, fig.cap= "Histogram of values showing the distribution of values in the Digital Elevation Model of Difference. The values are plotted on the X-axis and the frquency on the Y-axis."----
# histogram of values in DoD
hist(DoD)



## ----pretty-diff-model, fig.cap= "Plot of the Elevation change Post-flood in Four Mile Canyon Creek, Boulder County with elevation change represented in categories (breaks)."----
# Color palette for 5 categories
difCol5 = c("#d7191c","#fdae61","#ffffbf","#abd9e9","#2c7bb6")

# Alternate palette for 7 categories - try it out!
#difCol7 = c("#d73027","#fc8d59","#fee090","#ffffbf","#e0f3f8","#91bfdb","#4575b4")

# plot hillshade first
plot(DTM_post_hillshade,
        col=grey(1:90/100),  # create a color ramp of grey colors
        legend=FALSE,
        main="Elevation Change Post Flood\nFour Mile Canyon Creek, Boulder County",
        axes=FALSE)

# add the DoD to it with specified breaks & colors
plot(DoD,
        breaks = c(-5,-1,-0.5,0.5,1,10),
        col= difCol5,
        axes=FALSE,
        alpha=0.3,
        add =T)



## ----crop-raster-man,fig.cap= "Plot of the Elevation change Post-flood in Four Mile Canyon Creek, Boulder County. Figure also includes crop window inlay around the area of interest.", eval=FALSE, comment=NA----
# plot the rasters you want to crop from 
plot(DTM_post_hillshade,
        col=grey(1:90/100),  # create a color ramp of grey colors
        legend=FALSE,
        main="Four Mile Canyon Creek, Boulder County\nPre-Flood",
        axes=FALSE)

plot(DoD,
        breaks = c(-5,-1,-0.5,0.5,1,10),
        col= difCol5,
        axes=FALSE,
        alpha=0.3,
        add =T)

# crop by designating two opposite corners
cropbox1 <- drawExtent()  




## ----crop-raster-man-view-----------------------
# view the extent of the cropbox1
cropbox1



## ----crop-raster-coords-------------------------
# desired coordinates of the box
cropbox2<-c(473792.6,474999,4434526,4435453)


## ----plot-crop-raster, fig.cap=c("Raster Plot of the cropped section of Four Mile Creek, Boulder County.", "Raster Plot of the cropped section of Four Mile Creek, Boulder County, Post-Flood.","Plot of the Elevation change,Post-flood,in the cropped section of Four Mile Canyon Creek, Boulder County with elevation change represented in categories (breaks).")----
# crop desired layers to this cropbox
DTM_pre_crop <- crop(DTM_pre, cropbox2)
DTM_post_crop <- crop(DTM_post, cropbox2)
DTMpre_hill_crop <- crop(DTMpre_hill,cropbox2)
DTMpost_hill_crop <- crop(DTMpost_hill,cropbox2)
DoD_crop <- crop(DoD, cropbox2)

# plot all again using the cropped layers

# PRE
plot(DTMpre_hill_crop,
        col=grey(1:90/100),  # create a color ramp of grey colors
        legend=FALSE,
        main="Four Mile Canyon Creek, Boulder County\nPre-Flood",
        axes=FALSE)
# note \n in the title forces a line break in the title
plot(DTM_pre_crop, 
        axes=FALSE,
        alpha=0.3,
        add=T)

# POST
# plot Post-flood w/ hillshade
plot(DTMpost_hill_crop,
        col=grey(1:90/100),  # create a color ramp of grey colors
        legend=FALSE,
        main="Four Mile Canyon Creek, Boulder County\nPost-Flood",
        axes=FALSE)

plot(DTM_post_crop, 
        axes=FALSE,
        alpha=0.3,
        add=T)

# CHANGE - DoD
plot(DTMpost_hill_crop,
        col=grey(1:90/100),  # create a color ramp of grey colors
        legend=FALSE,
        main="Elevation Change Post Flood\nFour Mile Canyon Creek, Boulder County",
        axes=FALSE)

plot(DoD_crop,
        breaks = c(-5,-1,-0.5,0.5,1,10),
        col= difCol5,
        axes=FALSE,
        alpha=0.3,
        add =T)

