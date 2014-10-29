---
layout: post
title: "Activity: Creating Plot Boundaries"
date:   2014-10-29 20:49:52
authors: Leah A. Wasser, Natalie Robinson, Sarah Elmendorf
categories: [Working With Field Data]
tags : [measuring vegetation,remote sensing, laser scanning]
description: "This activity walks you through creating square polygons from a plot centroid (x,y format) in R."
code1: final_PlotBoundaryCode.R
image:
  feature: textur2_FieldWork.jpg
  credit: Ordway Swisher Biological Station, NEON, thx to Courtney Meier
  creditlink: http://www.neoninc.org
permalink: /working-with-field-data/Field-Data-Polygons-From-Centroids
---
<section id="table-of-contents" class="toc">
  <header>
    <h3 >Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->

#About This Activity
Sometimes we have a set of plot centroid (marking the center of a plot) values in x,y format. We need to derive the plot boundaries or edges of the plot, from the centroids. If the plot is a circle, we can generate the plot boundary using a buffer function in R or a GIS package. However, creating a SQUARE boundary around a centroid requires an alternate approach. This activity presents a way to create square polygons of a given radius (referring to half of the plots width), for each plot centroid location in a dataset.

This activity requires a ".csv" (Comma Separated Value) file that contains the plot centroids in X,Y format and preferably some sort of unique plot ID. The data used in this activity were collected at the National Ecological Observatory Network field site in San Joaquin Experimental Range, California. 

**We'd Like to Thank**

Special thanks to <a href="http://stackoverflow.com/users/489704/jbaums" target="_blank"> jbaums</a> from StackOverflow for helping with the SpatialPolygons code!

# What You Need
- R or RStudio
- A functioning thinking cap
- **Data to Download:** The plot centroid csv located [HERE](http://lwasser.github.io/data/SJERPlotCentroids.csv "Centroid data for SJER") (right click to download)
- **Required R Packages:** the sp and rgdal packages.
- Quick Hint: You need to first install the sp and rgdal packages before calling them in your code. Make sure they are installed or else calling them as a library won't work.
	- For example, installing the sp package requires you to run the following: install.packages(‘sp’) 
	-  <a href="http://www.r-bloggers.com/installing-r-packages/" target="_blank">Read more about installing packages in R by R-bloggers.</a>

##Part 1 - Load CSV, Setup Plots 

	#this code will create square "plots" of a user-defined radius from X,Y  centroids
	#first, load the sp and gdal libraries
	
	library(sp)
	library(rgdal)

	#be sure to set your working directory so you know where any code outputs are saved.
	setwd("~/SET-YOUR-DIRECTORY-HERE/1_DataWorkshop_ESA2014/ESAWorkshop_data")

	#Make sure character strings don't import as factors
	options(stringsAsFactors=FALSE)

	#read in the NEON plot centroid data (downloaded above - 
	#SJERPlotCentroids.csv)
	#make sure this file has been saved in your working directory
	centroids <- read.csv("SJERPlotCentroids.csv")

The next piece of code sets the radius for the plots. This radius is used to calculate the vertex locations that define the plot perimeter. In this case, we will use a radius of 20m to create a 40 m x 40 m square plot. Radius is in METERS given the data are in the UTM coordinate reference system (CRS).

	#set the radius for the plots
	radius <- 20 #radius in meters

	#define the plot boundaries based upon the plot radius. 
	#NOTE: this assumes that plots are oriented North and are not rotated. 
	#If the plots are rotated, you'd need to do additional math to find 
	#the corners.
	yPlus <- centroids$northing+radius
	xPlus <- centroids$easting+radius
	yMinus <- centroids$northing-radius
	xMinus <- centroids$easting-radius

Next, we will extract each plot's unique ID from the centroids csv file. We will associate the centroid plot ID with the plot perimeter polygon that we create below.

	#Extract the plot ID information. NOTE: because we set
	#stringsAsFactor to false above, we can import the plot 
	#ID's using the code below. If we didn't do that, our ID's would 
	#come in as factors by default. 
	#We'd thus have to use the code ID=as.character(centroids$Plot_ID) 
	ID=centroids$Plot_ID
	
NOTE: When calculating the coordinates for the vertices, it is important to CLOSE the polygon. This means that a square will have 5 instead of 4 vertices. The fifth vertex is identical to the first vertex. Thus, by repeating the first vertex coordinate (xMinus,yPlus) the polygon will be closed.

	#calculate polygon coordinates for each plot centroid. 
	square=cbind(xMinus,yPlus, xPlus,yPlus, xPlus,yMinus, xMinus,yMinus,xMinus,yPlus,xMinus,yPlus)


##Part 2 - Create Spatial Polygons
Next, create Spatial Polygons. NOTE: this particular step is somewhat confusing. Please consider reading up on the SpatialPolygon object
in R. or check out the stack overflow thread that helped us sort out how this works. <a href="http://stackoverflow.com/questions/26620373/spatialpolygons-creating-a-set-of-polygons-in-r-from-coordinates" target="_blank">Stack Overflow Thread</a>

Note 1: Spatial polygons require a list of lists. Each list contains the xy coordinates of each vertex in the polygon - in order. This includes the closing vertex that we discussed above. So, remember, you'll have to repeat the first vertex coordinate.

Note 2: you can grab the CRS string from another file that has CRS information already. To do this, use the syntax: proj4string =CRS(as.character(YOU-DATA-HERE@crs)). So, for example if we imported a tiff called "canopy" that was in a UTM coordinate system, we could type proj4string-CRS(as.character(canopy@crs))

**Let's Do this the efficient way - we will use the mapply function.**

	#create spatial polygons
	polys <- SpatialPolygons(mapply(function(poly, id) {
	  xy <- matrix(poly, ncol=2, byrow=TRUE)
	  Polygons(list(Polygon(xy)), ID=id)
	}, split(square, row(square)), ID),proj4string=CRS(as.character("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")))

**If the above doesn't make sense, let's try to less efficient way - using a loop**

The code below uses simpler R code contained within a loop. Please keep in mind that loops are less efficient to process your data. But this code might be easier for you to understand if you are newer to R.  
	
	#this is the inefficient way of doing this - using a for loop
	#initialize the list
	a <- vector('list', length(2))

    #loop through each centroid value and create a polygon
	for (i in 1:nrow(centroids)) {	   
	  a[[i]]<-Polygons(list(Polygon(matrix(square[i, ], ncol=2, byrow=TRUE))), ID[i]) 
	}
	
	polys<-SpatialPolygons(a,proj4string=CRS(as.character("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")


##Part 3 - Export to Shapefile
Before you can export a shapefile, you need to convert the spatialpolygons to a spatial polygon data frame. Note: this is the step where you could add additional attribute data if you wanted to!

	# Create SpatialPolygonDataFrame -- this step is required to output multiple polygons.
	polys.df <- SpatialPolygonsDataFrame(polys, data.frame(id=ID, row.names=ID))
	
let's check out the results before we export
	plot(polys.df, col=rainbow(50, alpha=0.5))

writeOGR is a nice function as it writes not only the shapefile, but also the associated Coordinate Reference System (CRS) information IF it was identified when creating the SpatialPolygons object. 

	#write out the data
	writeOGR(polys.df, '.', 'sjerPlots2', 'ESRI Shapefile')

And there you have it. Bring that shapefile into QGIS or whatever GIS package you prefer and have a look! Note that you could add additional attribute data to it as well!
