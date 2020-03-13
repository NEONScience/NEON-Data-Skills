## ----view-extents, echo=FALSE, results='hide'----------------------------
## Load Packages
library(rgdal)  # for vector work; sp package should always load with rgdal. 
library (raster)

# Import a polygon shapefile 
aoiBoundary_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
                            "HarClip_UTMZ18")

# Import a line shapefile
lines_HARV <- readOGR( "NEON-DS-Site-Layout-Files/HARV/", 
                       "HARV_roads")

# Import a point shapefile 
point_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
                      "HARVtower_UTM18N")

chm_HARV <- raster("NEON-DS-Airborne-Remote-Sensing/HARV/CHM/HARV_chmCrop.tif")

utm18nCRS <- crs(point_HARV)

# Read the .csv file
plot.locations_HARV <- 
  read.csv("NEON-DS-Site-Layout-Files/HARV/HARV_PlotLocations.csv",
           stringsAsFactors = FALSE)

# note that the easting and northing columns are in columns 1 and 2
plot.locationsSp_HARV <- SpatialPointsDataFrame(plot.locations_HARV[,1:2],
                    plot.locations_HARV,    # the R object to convert
                    proj4string = utm18nCRS)   # assign a CRS 

plot(extent(lines_HARV),
     col="purple", lwd="3",
     xlab="Easting", ylab="Northing",
    main="Extent Boundary of Several Spatial Files",
    xlim=c(730741.2,735000),
    col.lab = 'grey', # set axis label color
    col.axis = 'grey') # set axis tick label color

plot(extent(plot.locationsSp_HARV),
     col="black",
     add=TRUE)

plot(extent(aoiBoundary_HARV),
     add=TRUE,
     col="blue", 
     lwd=4)

plot(extent(chm_HARV),
     add=TRUE, 
     lwd=5,
     col="springgreen")

legend("topright", 
       legend=c("Roads","Plot Locations","Tower AOI", "CHM"),
       lwd=3,
       col=c("purple","black","blue","springgreen"),
       bty = "n",  
       cex = .8)


## ----reset-par, results="hide", echo=FALSE-------------------------------
# reset par
dev.off()

## ----load-libraries-data, results="hide", warning=FALSE------------------
# load necessary packages
library(rgdal)  # for vector work; sp package should always load with rgdal. 
library (raster)

# set working directory to data folder
# setwd("pathToDirHere")

# Imported in Vector 00: Vector Data in R - Open & Plot Data
# shapefile 
aoiBoundary_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
                            "HarClip_UTMZ18")
# Import a line shapefile
lines_HARV <- readOGR( "NEON-DS-Site-Layout-Files/HARV/",
                       "HARV_roads")
# Import a point shapefile 
point_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
                      "HARVtower_UTM18N")

# Imported in  Vector 02: .csv to Shapefile in R
# import raster Canopy Height Model (CHM)
chm_HARV <- 
  raster("NEON-DS-Airborne-Remote-Sensing/HARV/CHM/HARV_chmCrop.tif")


## ----Crop-by-vector-extent-----------------------------------------------
# plot full CHM
plot(chm_HARV,
     main="LiDAR CHM - Not Cropped\nNEON Harvard Forest Field Site")

# crop the chm
chm_HARV_Crop <- crop(x = chm_HARV, y = aoiBoundary_HARV)

# plot full CHM
plot(extent(chm_HARV),
     lwd=4,col="springgreen",
     main="LiDAR CHM - Cropped\nNEON Harvard Forest Field Site",
     xlab="easting", ylab="northing")

plot(chm_HARV_Crop,
     add=TRUE)


## ----view-crop-extent, echo=FALSE----------------------------------------
# view the data in a plot
plot(aoiBoundary_HARV, lwd=8, border="blue",
     main = "Cropped LiDAR Canopy Height Model \n NEON Harvard Forest Field Site")

plot(chm_HARV_Crop, add = TRUE)

## ----view-extent---------------------------------------------------------
# lets look at the extent of all of our objects
extent(chm_HARV)
extent(chm_HARV_Crop)
extent(aoiBoundary_HARV)


## ----challenge-code-crop-raster-points, include=TRUE, results="hide", echo=FALSE----

# Created/imported in L02: .csv to Shapefile in R
plot.locationSp_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
																"PlotLocations_HARV")

# crop the chm 
CHM_plots_HARVcrop <- crop(x = chm_HARV, y = plot.locationsSp_HARV)

plot(CHM_plots_HARVcrop,
     main="Study Plot Locations\n NEON Harvard Forest")

plot(plot.locationSp_HARV, 
     add=TRUE,
     pch=19,
     col="blue")


## ----raster-extents-cropped, echo=FALSE----------------------------------
plot(extent(lines_HARV),
     col="purple", lwd="3",
     xlab="Easting", ylab="Northing",
    main="Extent Boundary of Several Spatial Files")

plot(extent(plot.locationsSp_HARV),
     col="black",
     add=TRUE)

plot(extent(chm_HARV),
     add=TRUE, 
     lwd=5,
     col="springgreen")

plot(extent(CHM_plots_HARVcrop),
     add=TRUE, 
     lwd=5,
     col="darkgreen")

legend("bottomright", 
        legend=c("Roads","Plot Locations", "CHM", "CHM cropped to Plots"),
       lwd=3,
       col=c("purple","black","springgreen", "darkgreen"),
       bty = "n",  
       cex = .8)


## ----hidden-extent-chunk-------------------------------------------------
# extent format (xmin,xmax,ymin,ymax)
new.extent <- extent(732161.2, 732238.7, 4713249, 4713333)
class(new.extent)

## ----crop-using-drawn-extent---------------------------------------------

# crop raster
CHM_HARV_manualCrop <- crop(x = chm_HARV, y = new.extent)

# plot extent boundary and newly cropped raster
plot(aoiBoundary_HARV, 
     main = "Manually Cropped Raster\n NEON Harvard Forest Field Site")
plot(new.extent, 
     col="brown", 
     lwd=4,
     add = TRUE)
plot(CHM_HARV_manualCrop, 
     add = TRUE)


## ----extract-from-raster-------------------------------------------------

# extract tree height for AOI
# set df=TRUE to return a data.frame rather than a list of values
tree_height <- extract(x = chm_HARV, 
                       y = aoiBoundary_HARV, 
                       df=TRUE)

# view the object
head(tree_height)

nrow(tree_height)

## ----view-extract-histogram----------------------------------------------
# view histogram of tree heights in study area
hist(tree_height$HARV_chmCrop, 
     main="Histogram of CHM Height Values (m) \nNEON Harvard Forest Field Site",
     col="springgreen",
     xlab="Tree Height", ylab="Frequency of Pixels")

# view summary of values
summary(tree_height$HARV_chmCrop)


## ----summarize-extract---------------------------------------------------
# extract the average tree height (calculated using the raster pixels)
# located within the AOI polygon
av_tree_height_AOI <- extract(x = chm_HARV, 
                              y = aoiBoundary_HARV,
                              fun=mean, 
                              df=TRUE)

# view output
av_tree_height_AOI


## ----extract-point-to-buffer---------------------------------------------
# what are the units of our buffer
crs(point_HARV)

# extract the average tree height (height is given by the raster pixel value)
# at the tower location
# use a buffer of 20 meters and mean function (fun) 
av_tree_height_tower <- extract(x = chm_HARV, 
                                y = point_HARV, 
                                buffer=20,
                                fun=mean, 
                                df=TRUE)

# view data
head(av_tree_height_tower)

# how many pixels were extracted
nrow(av_tree_height_tower)


## ----challenge-code-extract-plot-tHeight, include=TRUE, results="hide", echo=FALSE----

# first import the plot location file.
plot.locationsSp_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
                            "PlotLocations_HARV")

# extract data at each plot location
meanTreeHt_plots_HARV <- extract(x = chm_HARV, 
                               y = plot.locationsSp_HARV, 
                               buffer=20,
                               fun=mean, 
                               df=TRUE)

# view data
meanTreeHt_plots_HARV

# plot data
plot(meanTreeHt_plots_HARV,
     main="MeanTree Height at each Plot\nNEON Harvard Forest Field Site",
     xlab="Plot ID", ylab="Tree Height (m)",
     pch=16)


