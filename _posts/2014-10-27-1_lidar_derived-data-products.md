---
layout: post
title: "Activity: LiDAR derived data products"
date:   2014-10-27 20:49:52
authors: Edmund Hart, Leah A. Wasser
categories: [Using LiDAR Data]
tags : [measuring vegetation,remote sensing, laser scanning]
description: "Bring LiDAR-derived raster data (DSM and DTM) into R to create a final canopy height model representing the actual vegetation height with the influence of elevation removed. Then compare lidar derived height (CHM) to field measured tree height to estimate uncertainty in lidar estimates."
permalink: /using-lidar-data/1_lidar_derived-data-products/
image:
  feature: textur2_pointsProfile.jpg
  credit: National Ecological Observatory Network (NEON) Higher Education
  creditlink: http://www.neoninc.org
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

# What you'll need
1. R or R studio loaded on your computer
2. GDAL libraries installed on you computer. <a href="https://www.youtube.com/watch?v=ZqfiZ_J_pQQ&list=PLLWiknuNGd50NbvZhydbTqJJh5ZRkjuak" target="_blank">Click here for videos on installing GDAL on a MAC and a PC.</a>

###Required R Packages
Please make sure the following packages are installed: Raster, sp, dplyr. 
<a href="http://www.r-bloggers.com/installing-r-packages/" target="_blank">Say What? --> about installing packages in R by R-bloggers.</a>

##REVIEW: How to Install Packages
Use the code below to install the sp and rgdal packages. NOTE: you can just type this into the command line to install each package. Once a package is installed, you don't have to install it again! <a href="http://www.r-bloggers.com/installing-r-packages/" target="_blank">Read more about installing packages in R by R-bloggers.</a>

    install.packages(‘raster’)
    install.packages(‘sp’)
    install.packages(‘dplyr’)

###Data to Download

Download the raster and *insitu* collected vegetation structure data here.
[-->Click here to DOWNLOAD Sample NEON LiDAR Data<--](http://www.neoninc.org/NEONedu/Data/LidarActivity/CHM_InSitu_Data.zip "Raster and InSitu Data") 

> NOTE: these data are available in full, for no charge, but by request, [from the NEON data portal](http://data.neoninc.org/airborne-data-request "AOP data").
> 
> Before walking through this activity, you may want to review the DSM, DTM and CHM discussion in the Raster LiDAR Data here.

##Background
NEON (National Ecological Observatory Network) will provide derived LiDAR products as one of its many free ecological data products. One such product is a digital surface model which represents the top of the surface elevation of objects on the earth. These products will come in a [geotiff](http://trac.osgeo.org/geotiff/ "geotiff (read more)") format, which is simply a raster format, that is spatially located on the earth. Geotiffs can be easily accessed using the `raster` package in R.

##Part 1. Creating a LiDAR derived Canopy Height Model (CHM)
In this activity, we will create a Canopy Height Model. Remember that the canopy height model, represents the actual heights of the trees on the ground. And we can derive the CHM by subtracting the ground elevation from the elevation of the top of the surface (or the tops of the trees). 

To begin the CHM creation, we will call the raster libraries in R and import the lidar derived digital surface model (DSM). Then we will import and plot the DSM.


	#Because we will be exporting data in this activity, let's set the
	#working directory before we go any further. The working directory 
	#will determine where data are saved.
	setwd("~/Conferences/1_DataWorkshop_ESA2014/ESAWorkshop_data")    

    #Import DSM into R 
    library(raster)
    	
	#IMPORTANT - the path to your DSM data may be different than the 
	#path below.  
    dsm_f <- "CHANGE-THIS-TO-PATH-ON-YOUR-COMPUTER/DigitalSurfaceModel/SJER2013_DSM.tif"
    
    dsm <- raster(dsm_f)
    ## See info about the raster.
    dsm
    plot(dsm)


Next, we will import the Digital Terrain Model (DTM). Remember that the DTM represents the ground (terrain) elevation.


    #import the digital terrain model
    dtm_f <- "CHANGE-THIS-TO-PATH-ON-YOUR-COMPUTER/DigitalTerrainModel/SJER2013_DTM.tif"
    dtm <- raster(dtm_f)
    plot(dtm)

Finally, we can create the Canopy Height Model (CHM). Remember that the CHM is simply the difference between the DSM and the DTM. So, we can perform some basic raster math to accomplish this. You might perform the SAME raster math in a GIS package like [QGIS](http://www.qgis.org/en/site/ "QGIS").
    
    #Create a function that performs this raster math. Canopy height 
	#is dsm - dtm
    canopyCalc <- function(x, y) {
      return(x - y)
      }
    
	#use the function to create the final CHM
	#then plot it.
    chm <- overlay(dsm,dtm,fun = canopyCalc)
    plot(chm)

	#write out the CHM in tiff format. We can look at this in any GIS software.
	writeRaster(chm,"chm.tiff","GTiff")

Woo hoo! We've now successfully created a canopy height model using basic raster math - in R! We can bring the chm.tiff file into QGIS (or any GIS) and look at it.  

##Part 2. How does our CHM data compare to field measured tree heights?

So now we have a canopy height model. however, how does that dataset compare to our laboriously collected, field measured height data? Let's see.

For this activity, we have two csv (comma separate value) files. The first file contains plot centroid location information (X,Y) where we measured trees. The second file contains our vegetation structure data for each plot. Let's start by plotting the plot locations (in red) on a map. 

We will need to convert the plot centroids to a spatial points dataset in R. To do this we'll need two additional packages - the spatial package - [sp](http://cran.r-project.org/web/packages/sp/index.html "R sp package") - and [dplyr](http://cran.r-project.org/web/packages/dplyr/index.html "dplyr"). 

Let's get started!

    {r Data overlay}
    library(sp)
    library(dplyr)

    #import the centroid data and the vegetation structure data
	options(stringsAsFactors=FALSE)
	centroids <- read.csv("data/SJERPlotCentroids.csv")
    insitu_dat <- read.csv("data/D17_2013_vegStr.csv")

	#plot the chm
    plot(chm)

	#Overlay the centroid points and the stem locations on the CHM plot
	#HINT: help(points) to see all of the options for plotting points. 
	#for example, cex = point size 
    points(centroids$easting,centroids$northing, pch=19, cex = 2,col = 2)
    points(insitu_dat$easting,insitu_dat$northing, pch=19, cex=.5)


###Spatial Data Need a Coordinate Reference System - CRS

Next, assign a CRS to our insitu data. the CRS is information that allows a program like QGIS to determine where the data are located, in the world. <a href="http://www.sco.wisc.edu/coordinate-reference-systems/coordinate-reference-systems.html" target="_blank">Read more about CRSs here</a>

	#make spatial points object using the CRS (coordinate 
	#reference system) from the CHM and apply it to our plot centroid data.
	#In this case, we know these data are all in the same projection
	centroid_sp <- SpatialPoints(centroids[,4:3],proj4string =CRS(as.character(chm@crs)) )

###Extract CMH data within 20 m radius of each centroid.**

There are a few ways to go about this task. If your plots are circular, then the extract tool will do the job on it's own! However, if you'd like to use a shapefile that contains the plot boundaries OR if your boundaries are rectangular, you might consider a variation of the code below.

	#Insitu sampling took place within 40m x 40m square plots.	
    #Note that below will return a list, so we can extract via lapply
    cent_ovr <- extract(chm,centroid_sp,buffer = 20)

###Variation Two -- Extract CHM values Using a Shapefile**

If your plot boundaries are saved in a shapefile, you can use the code below. There are two shapefiles in the folder named "PlotCentroid_Shapefile" within the zip file that you downloaded at the top of this page.

	#extract CHM data using polygon boundaries from a shapefile
	squarePlot <- readShapePoly("InSitu_Data/SJERPlotCentroids_Buffer.shp")
	v <- extract(chm, squarePlot, weights=FALSE, fun=max)

###Variation Three -- Derive Square Plot boundaries, then CHM values Using a Shapefile
For more on this, see the [activity](../../working-with-field-data/Field-Data-Polygons-From-Centroids/ "Polygons")

    
Create new dataframe by pulling the CHM max value found within the 20m radius from each plot centroid location**

	centroids$overlay <- unlist(lapply(cent_ovr,max))
	
	#find the max and 95th percentile value for all trees within each plot 
	insitu <- insitu_dat %.% filter(plotid %in% centroids$Plot_ID) %.% group_by(plotid) %.% summarise(quant = quantile(stemheight,.95), max = max(stemheight))
	
	centroids$insitu <- insitu$max

### Create Regression Plot (CHM vs Measured)
Create the regression final plot that compares in situ max tree height to CHM derived max height.

	ggplot(centroids,aes(x=overlay, y =insitu )) + geom_point() + theme_bw() + ylab("Maximum measured height") + xlab("Maximum LiDAR pixel")+geom_abline(intercept = 0, slope=1)+xlim(0, max(centroids[,6:7])) + ylim(0,max(centroids[,6:7]))

And that is it! You have now successfully created a canopy height model using lidar data AND compared lidar derived vegetation height, within plots, to actual measured tree height data!



