## ----load-libraries------------------------------------------------------

# load packages
library(rgdal)  # for vector work; sp package should always load with rgdal. 
library (raster)   # for metadata/attributes- vectors or rasters

# set working directory to data folder
# setwd("pathToDirHere")


## ----read-csv------------------------------------------------------------

# Read the .csv file
plot.locations_HARV <- 
  read.csv("NEON-DS-Site-Layout-Files/HARV/HARV_PlotLocations.csv",
           stringsAsFactors = FALSE)

# look at the data structure
str(plot.locations_HARV)


## ----find-coordinates----------------------------------------------------

# view column names
names(plot.locations_HARV)


## ----check-out-coordinates-----------------------------------------------
# view first 6 rows of the X and Y columns
head(plot.locations_HARV$easting)
head(plot.locations_HARV$northing)

# note that  you can also call the same two columns using their COLUMN NUMBER
# view first 6 rows of the X and Y columns
head(plot.locations_HARV[,1])
head(plot.locations_HARV[,2])


## ----view-CRS-info-------------------------------------------------------
# view first 6 rows of the X and Y columns
head(plot.locations_HARV$geodeticDa)
head(plot.locations_HARV$utmZone)


## ----explore-units-------------------------------------------------------

# Import the line shapefile
lines_HARV <- readOGR( "NEON-DS-Site-Layout-Files/HARV/", "HARV_roads")

# view CRS
crs(lines_HARV)

# view extent
extent(lines_HARV)


## ----crs-object----------------------------------------------------------
# create crs object
utm18nCRS <- crs(lines_HARV)
utm18nCRS

class(utm18nCRS)

## ----convert-csv-shapefile-----------------------------------------------
# note that the easting and northing columns are in columns 1 and 2
plot.locationsSp_HARV <- SpatialPointsDataFrame(plot.locations_HARV[,1:2],
                    plot.locations_HARV,    #the R object to convert
                    proj4string = utm18nCRS)   # assign a CRS 
                                          
# look at CRS
crs(plot.locationsSp_HARV)


## ----plot-data-points----------------------------------------------------
# plot spatial object
plot(plot.locationsSp_HARV, 
     main="Map of Plot Locations")


## ----create-aoi-boundary-------------------------------------------------
# create boundary object 
aoiBoundary_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
                            "HarClip_UTMZ18")

## ----plot-data-----------------------------------------------------------
# plot Boundary
plot(aoiBoundary_HARV,
     main="AOI Boundary\nNEON Harvard Forest Field Site")

# add plot locations
plot(plot.locationsSp_HARV, 
     pch=8, add=TRUE)

# no plots added, why? CRS?
# view CRS of each
crs(aoiBoundary_HARV)
crs(plot.locationsSp_HARV)


## ----compare-extents-----------------------------------------------------
# view extent of each
extent(aoiBoundary_HARV)
extent(plot.locationsSp_HARV)

# add extra space to right of plot area; 
# par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)

plot(extent(plot.locationsSp_HARV),
     col="purple", 
     xlab="easting",
     ylab="northing", lwd=8,
     main="Extent Boundary of Plot Locations \nCompared to the AOI Spatial Object",
     ylim=c(4712400,4714000)) # extent the y axis to make room for the legend

plot(extent(aoiBoundary_HARV), 
     add=TRUE,
     lwd=6,
     col="springgreen")

legend("bottomright",
       #inset=c(-0.5,0),
       legend=c("Layer One Extent", "Layer Two Extent"),
       bty="n", 
       col=c("purple","springgreen"),
       cex=.8,
       lty=c(1,1),
       lwd=6)


## ----set-plot-extent-----------------------------------------------------

plotLoc.extent <- extent(plot.locationsSp_HARV)
plotLoc.extent
# grab the x and y min and max values from the spatial plot locations layer
xmin <- plotLoc.extent@xmin
xmax <- plotLoc.extent@xmax
ymin <- plotLoc.extent@ymin
ymax <- plotLoc.extent@ymax

# adjust the plot extent using x and ylim
plot(aoiBoundary_HARV,
     main="NEON Harvard Forest Field Site\nModified Extent",
     border="darkgreen",
     xlim=c(xmin,xmax),
     ylim=c(ymin,ymax))

plot(plot.locationsSp_HARV, 
     pch=8,
		 col="purple",
		 add=TRUE)

# add a legend
legend("bottomright", 
       legend=c("Plots", "AOI Boundary"),
       pch=c(8,NA),
       lty=c(NA,1),
       bty="n", 
       col=c("purple","darkgreen"),
       cex=.8)


## ----challenge-code-phen-plots, echo=FALSE, results="hide", warning=FALSE----
## 1
# Read the .csv file
newPlot.locations_HARV <- 
  read.csv("NEON-DS-Site-Layout-Files/HARV/HARV_2NewPhenPlots.csv",
           stringsAsFactors = FALSE)

# look at the data structure -> locations in lat/long
str(newPlot.locations_HARV)

## 2
## Find/ establish a CRS for new points
# Import the US boundary which is in a geographic WGS84 coordinate system
Country.Boundary.US <- readOGR("NEON-DS-Site-Layout-Files/US-Boundary-Layers",
          "US-Boundary-Dissolved-States")

# grab the geographic CRS
geogCRS <- crs(Country.Boundary.US)
geogCRS

## Convert to spatial data frame
# note that the easting and northing columns are in columns 1 and 2
newPlot.Sp.HARV <- SpatialPointsDataFrame(newPlot.locations_HARV[,2:1],
                    newPlot.locations_HARV,    # the R object to convert
                    proj4string = geogCRS)   # assign a CRS 
                                         
# view CRS
crs(newPlot.Sp.HARV)

## We now have the data imported and in WGS84 Lat/Long. We want to map with plot
# locations in UTM so we'll have to reproject. 

# remember we have a UTM Zone 18N crs object from previous code
utm18nCRS

# reproject the new points into UTM using `utm18nCRS`
newPlot.Sp.HARV.UTM <- spTransform(newPlot.Sp.HARV,
                                  utm18nCRS)
# check new plot CRS
crs(newPlot.Sp.HARV.UTM)

## 3
# create plot
plot(plot.locationsSp_HARV, 
     main="NEON Harvard Forest Field Site \nPlot Locations" )

plot(newPlot.Sp.HARV.UTM, 
     add=TRUE, pch=20, col="darkgreen")

# oops - looks like we are missing a point on our new plot. let's compare
# the spatial extents of both objects!
extent(plot.locationsSp_HARV)
extent(newPlot.Sp.HARV.UTM)

# when you plot in base plot, if the extent isn't specified, then the data that
# is added FIRST will define the extent of the plot
plot(extent(plot.locationsSp_HARV),
     main="Comparison of Spatial Object Extents\nPlot Locations vs New Plot Locations")
plot(extent(newPlot.Sp.HARV.UTM),
     col="darkgreen",
     add=TRUE)

# looks like the green box showing the newPlot extent extends
# beyond the plot.locations extent.

# We need to grab the x min and max and y min from our original plots
# but then the ymax from our new plots

originalPlotExtent <- extent(plot.locationsSp_HARV)
newPlotExtent <- extent(newPlot.Sp.HARV.UTM)

# set xmin and max
xmin <- originalPlotExtent@xmin
xmax <- originalPlotExtent@xmax
ymin <- originalPlotExtent@ymin
ymax <- newPlotExtent@ymax

# 3 again... re-plot
# try again but this time specify the x and ylims
# note: we could also write a function that would harvest the smallest and
# largest
# x and y values from an extent object. This is beyond the scope of this tutorial.
plot(plot.locationsSp_HARV, 
     main="NEON Harvard Forest Field Site\nVegetation & Phenology Plots",
     pch=8,
     col="purple",
     xlim=c(xmin,xmax),
     ylim=c(ymin,ymax))

plot(newPlot.Sp.HARV.UTM, 
     add=TRUE, pch=20, col="darkgreen")

# when we create a legend in R, we need to specify the text for each item 
# listed in the legend.
legend("bottomright", 
       legend=c("Vegetation Plots", "Phenology Plots"),
       pch=c(8,20), 
       bty="n", 
       col=c("purple","darkgreen"),
       cex=1.3)

## ----write-shapefile, warnings="hide", eval=FALSE------------------------
## # write a shapefile
## writeOGR(plot.locationsSp_HARV, getwd(),
##          "PlotLocations_HARV", driver="ESRI Shapefile")
## 

