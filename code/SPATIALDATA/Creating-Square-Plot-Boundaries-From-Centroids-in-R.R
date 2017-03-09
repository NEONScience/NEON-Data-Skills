## ----load-data-----------------------------------------------------------
# load the sp and rgdal packages

library(sp)
library(rgdal)

# set working directory to data folder
#setwd("pathToDirHere")


# read in the NEON plot centroid data 
# `stringsAsFactors=F` ensures character strings don't import as factors
centroids <- read.csv("SJERPlotCentroids.csv", stringsAsFactors=FALSE)

## ----view-data-----------------------------------------------------------
# view data structure
str(centroids)

## ----set-radius----------------------------------------------------------
# set the radius for the plots
radius <- 20 # radius in meters

# define the plot edges based upon the plot radius. 

yPlus <- centroids$northing+radius
xPlus <- centroids$easting+radius
yMinus <- centroids$northing-radius
xMinus <- centroids$easting-radius


## ----create-perimeter----------------------------------------------------
# calculate polygon coordinates for each plot centroid. 
square=cbind(xMinus,yPlus,  # NW corner
	xPlus, yPlus,  # NE corner
	xPlus,yMinus,  # SE corner
	xMinus,yMinus, # SW corner
	xMinus,yPlus)  # NW corner again - close ploygon


## ----get-id--------------------------------------------------------------

# Extract the plot ID information
ID=centroids$Plot_ID


## ----mapply--------------------------------------------------------------
# create spatial polygons from coordinates
polys <- SpatialPolygons(mapply(function(poly, id) 
		{
	  xy <- matrix(poly, ncol=2, byrow=TRUE)
	  Polygons(list(Polygon(xy)), ID=id)
	  }, 
	split(square, row(square)), ID),
	proj4string=CRS(as.character("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")))

## ----polys-plot----------------------------------------------------------
# plot the new polygons
plot(polys)


## ----looping-it----------------------------------------------------------
# First, initialize a list tha will later be populated
# a, as a placeholder, since this is temporary
a <- vector('list', length(2))

# loop through each centroid value and create a polygon
# this is where we match the ID to the new plot coordinates
for (i in 1:nrow(centroids)) {  # for each for in object centroids
	  a[[i]]<-Polygons(list(Polygon(matrix(square[i, ], ncol=2, byrow=TRUE))), ID[i]) 
	  # make it an Polygon object with the Plot_ID from object ID
	}

# convert a to SpatialPolygon and assign CRS
polysB<-SpatialPolygons(a,proj4string=CRS(as.character("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")))


## ----polysB-plot---------------------------------------------------------
# plot the new polygons
plot(polysB)


## ----create-spdf---------------------------------------------------------

# Create SpatialPolygonDataFrame -- this step is required to output multiple polygons.
polys.df <- SpatialPolygonsDataFrame(polys, data.frame(id=ID, row.names=ID))

## ----polysdf-plot--------------------------------------------------------
plot(polys.df, col=rainbow(50, alpha=0.5))

## ----write-ogr-----------------------------------------------------------

# write the shapefiles 
writeOGR(polys.df, '.', '2014Plots_SJER', 'ESRI Shapefile')

