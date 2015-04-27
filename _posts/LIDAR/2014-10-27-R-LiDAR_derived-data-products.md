---
layout: post
title: "R: Create a Canopy Height Model from LiDAR derived Rasters (grids) in R"
date:   2014-7-18 20:49:52
createdDate:   2014-07-21 20:49:52
lastModified:   2015-4-27 15:33:52
estimatedTime: 3.0 - 3.5 Hours
packagesLibraries: raster, sp, dplyr, maptools, rgeos
authors: Edmund Hart, Leah A. Wasser
category: remote-sensing
categories: [Remote Sensing]
tags : [lidar,R]
description: "Bring LiDAR-derived raster data (DSM and DTM) into R to create a final canopy height model representing the actual vegetation height with the influence of elevation removed. Then compare lidar derived height (CHM) to field measured tree height to estimate uncertainty in lidar estimates."
permalink: /using-lidar-data/1_lidar_derived-data-products/
code1: Create_Lidar_CHM.R
image:
  feature: textur2_pointsProfile.png
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


##Background
NEON (National Ecological Observatory Network) will provide derived LiDAR products as one of its many free ecological data products. One data product that NEON will provide is a digital surface model which represents the top of the surface elevation of objects on the earth. These products will come in a [geotiff](http://trac.osgeo.org/geotiff/ "geotiff (read more)") format, which is simply a raster format, that is spatially located on the earth. Geotiffs can be easily accessed using the `raster` package in R.

A common first analysis using LiDAR data is to derive top of the canopy height values from the LiDAR data. These values are often used to track changes in forest structure over time, to calculate biomass, and even LAI. Let's dive into the basics of working with raster formatted lidar data in R! Before we begin, make sure you've downloaded the data required to run the code below.

<div id="objectives">
<h3>What you'll need</h3>
<ol>
<li>R or R studio loaded on your computer </li>
<li>GDAL libraries installed on you computer. <a href="https://www.youtube.com/watch?v=ZqfiZ_J_pQQ&list=PLLWiknuNGd50NbvZhydbTqJJh5ZRkjuak" target="_blank">Click here for videos on installing GDAL on a MAC and a PC.</a></li>
</ol>

<h2>Data to Download</h2>

Download the raster and <i>insitu</i> collected vegetation structure data:

<a href="http://www.neonhighered.org/Data/LidarActivity/CHM_InSitu_Data.zip" class="btn btn-success"> DOWNLOAD NEON  Sample NEON LiDAR Data</a>

</div>

> NOTE: these data are available in full, for no charge, but by request, [from the NEON data portal](http://data.neoninc.org/airborne-data-request "AOP data").
> 
> Before walking through this activity, you may want to review the DSM, DTM and CHM discussion in the Raster LiDAR Data here.

###Required R Packages
Please make sure the following packages are installed: Raster, sp, dplyr. 

[More on Packages in R - Adapted from Software Carpentry.]({{ site.baseurl }}/R/Packages-In-R/ "Packages in R")

    install.packages(‘raster’)
    install.packages(‘sp’)
    install.packages(‘dplyr’)


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
    #You could use the overlay function here chm <- overlay(dsm,dtm,fun = canopyCalc)
    #but you can also perform matrix math to get the same output.
    chm <- canopyCalc(dsm,dtm)
    plot(chm)

	#write out the CHM in tiff format. We can look at this in any GIS software.
    #note that the code below places the output in an "outputs" folder. 
    #you need to create this folder or else you will get an error.
	writeRaster(chm,"outputs/chm.tiff","GTiff")

Woo hoo! We've now successfully created a canopy height model using basic raster math - in R! We can bring the chm.tiff file into QGIS (or any GIS) and look at it.  

##Part 2. How does our CHM data compare to field measured tree heights?

So now we have a canopy height model. however, how does that dataset compare to our laboriously collected, field measured height data? Let's see.

For this activity, we have two csv (comma separate value) files. The first file contains plot centroid location information (X,Y) where we measured trees. The second file contains our vegetation structure data for each plot. Let's start by plotting the plot locations (in red) on a map. 

We will need to convert the plot centroids to a spatial points dataset in R. To do this we'll need two additional packages - the spatial package - [sp](http://cran.r-project.org/web/packages/sp/index.html "R sp package") - and [dplyr](http://cran.r-project.org/web/packages/dplyr/index.html "dplyr"). 

Let's get started!

    #load needed libraries
    library(sp)
    library(dplyr)

    #import the centroid data and the vegetation structure data
	options(stringsAsFactors=FALSE)
	centroids <- read.csv("data/SJERPlotCentroids.csv")
    insitu_dat <- read.csv("data/D17_2013_vegStr.csv")

	#Overlay the centroid points and the stem locations on the CHM plot

	#for example, cex = point size 
    points(centroids$easting,centroids$northing, pch=19, cex = 2,col = 2)
    points(insitu_dat$easting,insitu_dat$northing, pch=19, cex=.5)

> HINT: type in `help(points)` to read about the options for plotting points.
> Also, to see a list of pch values (symbols), check out <a href="http://www.endmemo.com/program/R/pchsymbols.php" target=_blank">this website.</a>

###Spatial Data Need a Coordinate Reference System - CRS

Next, assign a CRS to our insitu data. The CRS is information that allows a program like QGIS to determine where the data are located, in the world. <a href="http://www.sco.wisc.edu/coordinate-reference-systems/coordinate-reference-systems.html" target="_blank">Read more about CRS here</a>

In this case, we know these data are all in the same projection.

> HINT: to find out what projection our CHM is in, Type `chm@crs`

	#make spatial points object using the CRS (coordinate 
	#reference system) from the CHM and apply it to our plot centroid data.
	centroid_sp <- SpatialPoints(centroids[,4:3],proj4string =CRS(as.character(chm@crs)) )

###Extract CMH data within 20 m radius of each plot centroid.

There are a few ways to go about this task. If your plots are circular, then the extract tool will do the job! However, you might need to use a shapefile that contains the plot boundaries OR perhaps your plot boundaries are rectangular. Several variations to complete this task are described below.

###Variation 1: Extract Plot Data Using Circle: 20m Radius Plots

	#Insitu sampling took place within 40m x 40m square plots so we use a 20m radius.	
    #Note that below will return a list, so we can extract via lapply
    cent_ovr <- extract(chm,centroid_sp,buffer = 20)

###Variation 2: Extract CHM values Using a Shapefile

If your plot boundaries are saved in a shapefile, you can use the code below. There are two shapefiles in the folder named "PlotCentroid_Shapefile" within the zip file that you downloaded at the top of this page. NOTE: to import a shapefile using the code below, you'll need to have the `maptools` package installed which requires the `rgeos` package. Be sure to install them first:
	
	#install needed packages
	`install.packages(rgeos)`
	`install.packages(maptools)`

	#call the maptools package
	library(maptools)
	#extract CHM data using polygon boundaries from a shapefile
	squarePlot <- readShapePoly("InSitu_Data/SJERPlotCentroids_Buffer.shp")
	cent_ovr <- extract(chm, squarePlot, weights=FALSE, fun=max)

###Variation 3: Derive Square Plot boundaries, then CHM values Using a Shapefile
For see how to extract square plots using a plot centroid value, check out the [extracting square shapes activity.](../../working-with-field-data/Field-Data-Polygons-From-Centroids/ "Polygons")

   
##Working with extracted data 
Using one of the methods above, we have created the `centre_ovr` object in R. This object contains all of the lidar CHM pixel values contained within our plot boundaries. Next, we will create a new dataframe by pulling the maximum value found within our plots.

	centroids$chmMax <- unlist(lapply(cent_ovr,max))

##Extracting descriptive stats from Insitu Data 
Now, there are two ways to extract stats from a dataset. The first option is to write each line out. 

###Option 1 - Extracting Data Using Several Lines of Code

First select plots that are also represented in our centroid layer. Quick test - how many plots are in the centroid folder?

    insitu_inCentroid <- insitu_dat %>% filter(plotid %in% centroids$Plot_ID)

Next, list out plot id results. how many are there?

    unique(insitu_inCentroid$plotid) 

Finally, find the max stem height value for each plot. We will compare this value to the max CHM value.

    insitu_maxStemHeight <- insit_inCentroid %>% group_by(plotid) %.% summarise(max = max(stemheight))

###Option 2 - Extracting Data Using one Line of Code!
We can be super tricky and combine the above steps into one line of code. See below how this is done. To do this, we can take full advantage of the dplyr package.
	
	#find the max and 95th percentile value for all trees within each plot 
	insitu <- insitu_dat %>% filter(plotid %in% centroids$Plot_ID) %>% group_by(plotid) %>% summarise(quant = quantile(stemheight,.95), max = max(stemheight))

	#assign the final output to a column in our centroids object
	centroids$insitu <- insitu$max

### Plot Data (CHM vs Measured)
Create the  final plot that compares in situ max tree height to CHM derived max height.

	ggplot(centroids,aes(x=chmMax, y =insitu )) + geom_point() + theme_bw() + ylab("Maximum measured height") + xlab("Maximum LiDAR pixel")+geom_abline(intercept = 0, slope=1)+xlim(0, max(centroids[,6:7])) + ylim(0,max(centroids[,6:7]))

Another option -- A regression plot. Explore with GGPLOT options. Customize your plot.

	#plot with regression fit
	p <- ggplot(centroids,aes(x=chmMax, y =insitu )) + geom_point() + 
	    ylab("Maximum Measured Height") + xlab("Maximum LiDAR Height")+
	    geom_abline(intercept = 0, slope=1)+
	    geom_smooth(method=lm) +
	    xlim(0, max(centroids[,6:7])) + ylim(0,max(centroids[,6:7])) 
	
	p + theme(panel.background = element_rect(colour = "grey")) + ggtitle("LiDAR CHM Derived vs Measured Tree Height") +
	  theme(plot.title=element_text(family="sans", face="bold", size=20, vjust=1.9)) +
	  theme(axis.title.y = element_text(family="sans", face="bold", size=14, angle=90, hjust=0.54, vjust=1)) +
	  theme(axis.title.x = element_text(family="sans", face="bold", size=14, angle=00, hjust=0.54, vjust=-.2))

Your final plot should look something like this:

![CHM Plot]({{ site.baseurl }}/images/chmPlot.png)

You have now successfully created a canopy height model using lidar data AND compared lidar derived vegetation height, within plots, to actual measured tree height data!


#Test Your Skills

- Create a plot of LiDAR 95th percentile value vs *insitu* max height. Or Lidar 95th percentile vs *insitu* 95th percentile.


