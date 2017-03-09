#this code will create square "plots" of X radius using plot centroids

library(sp)
library(rgdal)

#be sure to set your working directory so you know where the data are saved at the end.
setwd("~/Conferences/1_DataWorkshop_ESA2014/ESAWorkshop_data")

#Make sure that character strings don't import as factors
options(stringsAsFactors=FALSE)

#read in the FSU plot location data
centroids <- read.csv("InSitu_Data/SJERPlotCentroids.csv")

#set the radius for the plots
radius <- 20 #radius in meters

#define the plot boundaries based upon the radius. NOTE: this assumes that plots are oriented North and are not rotated
yPlus <- centroids$northing+radius
xPlus <- centroids$easting+radius
yMinus <- centroids$northing-radius
xMinus <- centroids$easting-radius

#Extract the plot ID information
ID=centroids$Plot_ID

#calculate polygon coordinates for each plot centroid. NOTE: the first vertex coordinate is repeated (xMinus,yPlus) to close the polygon.
square=cbind(xMinus,yPlus, xPlus,yPlus, xPlus,yMinus, xMinus,yMinus,xMinus,yPlus,xMinus,yPlus)

# next, create Spatial Polygons. NOTE: this particular step is somewhat confusing. Please consider reading up on the SpatialPolygon object
#in R. or check out the stack overflow thread that helped us sort out how this works.
# http://stackoverflow.com/questions/26620373/spatialpolygons-creating-a-set-of-polygons-in-r-from-coordinates
#spatial polygons require a list of lists. Each list contains the xy coordinates of each vertex in the polygon - in order. This includes the closing vertext
# so you'll have to repeat the first vertex coordinate.

# also note -- you can grab the CRS string from another file is like this proj4string =CRS(as.character(YOU-DATA-HERE@crs))

polys <- SpatialPolygons(mapply(function(poly, id) {
  xy <- matrix(poly, ncol=2, byrow=TRUE)
  Polygons(list(Polygon(xy)), ID=id)
}, split(square, row(square)), ID),proj4string=CRS(as.character("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")))


#A Less efficient for loop approach
#this is the inefficient way of doing this - using a for loop
#initialize the list
#a <- vector('list', length(2))

#loop through each centroid value and create a polygon
#for (i in 1:nrow(centroids)) {     
#  a[[i]]<-Polygons(list(Polygon(matrix(square[i, ], ncol=2, byrow=TRUE))), ID[i]) 
#}

#polys<-SpatialPolygons(a,proj4string=CRS(as.character("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Create SpatilPolygonDataFrame -- this step is required to output multiple polygons.
polys.df <- SpatialPolygonsDataFrame(polys, data.frame(id=ID, row.names=ID))

plot(polys.df, col=rainbow(50, alpha=0.5))

#write out the data
writeOGR(polys.df, '.', 'sjerPlots2', 'ESRI Shapefile')
