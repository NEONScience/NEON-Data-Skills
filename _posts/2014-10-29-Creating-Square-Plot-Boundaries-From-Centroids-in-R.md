---
layout: post
title: "Activity: Creating Plot Boundaries"
date:   2014-10-29 20:49:52
authors: Leah A. Wasser, Natalie Robinson, Sarah Elmendorf
categories: [Working With Field Data]
tags : [measuring vegetation,remote sensing, laser scanning]
description: "This activity walks you through creating square polygons from a plot centroid (x,y format) in R."

image:
  feature: textur2_FieldWork.jpg
  credit: Ordway Swisher Biological Station, NEON, thx to Courtney Meier
  creditlink: http://www.neoninc.org
permalink: /working-with-field-data/Field-Data-Polygons-From-Centroids
---


#About This Activity
Sometimes you have a set of plot centroid values (x,y) and you need to derive the plot boundaries. If the plot is a circle, this task is quite simple using a buffer function in R or a GIS package. However, creating a SQUARE boundary around a centroid requires an alternate approach. This activity presents a way to create square polygons of a given radius, around a given set of plot centroids.

It requires a csv file that contains the plot centroids and preferably some sort of unique plot ID. The data used in this activity were collected at the National Ecological Observatory Network field site in San Joachium Experimental Range, California. 

#Learning Objectives

# Activity Requirements
- R or RStudio
- The plot centroid csv located [HERE](http://lwasser.github.io/data/SJERPlotCentroids.csv "Centroid data for SJER") (right click to download)
- a functioning thinking cap
- the sp and rgdal packages -- make sure they are installed or else calling them as a library won't work. <a href="http://www.r-bloggers.com/installing-r-packages/" target="_blank">TIP: about installing packages in R by R-bloggers.</a>

Let's get started. 

	#this code will create square "plots" of X radius using plot centroids
	#first, call the sp and gdal libraries
	library(sp)
	library(rgdal)

	#be sure to set your working directory so you know where the data are saved at the end.
	setwd("~/SET-YOUR-DIRECTORY-HERE/1_DataWorkshop_ESA2014/ESAWorkshop_data")

	#read in the FSU plot centroid information (downloaded above - make sure this is placed in your working directory
	centroids <- read.csv("SJERPlotCentroids.csv")

This code allows you to set hte radius for your plots. In this case, we used a 40 x 40m radius square plot. Radius is in METERS given the data are in UTM.

	#set the radius for the plots
	radius <- 20 #radius in meters

	#define the plot boundaries based upon the plot radius. NOTE: this assumes that plots are oriented North and are not rotated. If the plots are rotated, you'd need to do additional math to find the corners.
	yPlus <- centroids$northing+radius
	xPlus <- centroids$easting+radius
	yMinus <- centroids$northing-radius
	xMinus <- centroids$easting-radius

Each plot has a unique ID. Let's extract that from the centroids csv so we can capture it in our polygon file that we create below.

	#Extract the plot ID information
	ID=as.character(centroids$Plot_ID)
	
NOTE: When calculating the coordinates for the vertices, it is important to CLOSE the polygon. This means that a square will have 5 instead of 4 vertices. The fifth vertex is identical to the first vertex. Thus, by repeating the first vertex coordinate (xMinus,yPlus) the polygon will be closed.

	#calculate polygon coordinates for each plot centroid. 
	square=cbind(xMinus,yPlus, xPlus,yPlus, xPlus,yMinus, xMinus,yMinus,xMinus,yPlus,xMinus,yPlus)

Next, create Spatial Polygons. NOTE: this particular step is somewhat confusing. Please consider reading up on the SpatialPolygon object
in R. or check out the stack overflow thread that helped us sort out how this works. <a href="http://stackoverflow.com/questions/26620373/spatialpolygons-creating-a-set-of-polygons-in-r-from-coordinates" target="_blank">Stack Overflow Thread</a>

Note 1: Spatial polygons require a list of lists. Each list contains the xy coordinates of each vertex in the polygon - in order. This includes the closing vertex that we discussed above. So, remember, you'll have to repeat the first vertex coordinate.

Note 2: you can grab the CRS string from another file is like this proj4string =CRS(as.character(YOU-DATA-HERE@crs))

	#create spatial polygons
	polys <- SpatialPolygons(mapply(function(poly, id) {
	  xy <- matrix(poly, ncol=2, byrow=TRUE)
	  Polygons(list(Polygon(xy)), ID=id)
	}, split(square, row(square)), ID),proj4string=CRS(as.character("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")))

Before you can export a shapefile, you need to convert the spatialpolygons to a spatial polygon data frame. Note: this is the step where you could add additional attribute data if you wanted to!

	# Create SpatilPolygonDataFrame -- this step is required to output multiple polygons.
	polys.df <- SpatialPolygonsDataFrame(polys, data.frame(id=ID, row.names=ID))
	
let's check out the results before we export
	plot(polys.df, col=rainbow(50, alpha=0.5))

writeOGR is a nice function as it writes not only the shapefile, but also the associated Coordinate Reference System (CRS) information IF it was identified when creating the SpatialPolygons object. 

	#write out the data
	writeOGR(polys.df, '.', 'sjerPlots2', 'ESRI Shapefile')

And there you have it. Bring that shapefile into QGIS or whatever GIS package you prefer and have a look! Note that you could add additional attribute data to it as well!
