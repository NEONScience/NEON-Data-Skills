---
layout: post
title: "Activity: LiDAR derived data products"
date:   2014-10-27 20:49:52
authors: Edmund Hart, Leah A. Wasser
categories: [Using LiDAR Data]
tags : [measuring vegetation,remote sensing, laser scanning]
description: "code activity in R."
image:
  feature: textur2_pointsProfile.jpg
  credit: National Ecological Observatory Network (NEON)
  creditlink: http://www.neoninc.org
---

# What you'll need
1. R or R studio loaded on your computer
2. GDAL libraries installed on you computer. <a href="https://www.youtube.com/watch?v=ZqfiZ_J_pQQ&list=PLLWiknuNGd50NbvZhydbTqJJh5ZRkjuak" target="_blank">Click here for videos on installing GDAL on a MAC and a PC.</a>

2. Load the download the raster package to be called in this activity
3. Download the raster and *insitu* collected vegetation structure data here.
[-->Click here to DOWNLOAD Sample NEON LiDAR Data<--](http://www.neoninc.org/NEONedu/Data/LidarActivity/CHM_InSitu_Data.zip "Raster and InSitu Data") 

> NOTE: these data are available in full, for no charge, but by request, [from the NEON data portal](http://data.neoninc.org/airborne-data-request "AOP data").
> 
> Before walking through this activity, you may want to review the DSM, DTM and CHM discussion in the Raster LiDAR Data here.

##Background
NEON (National Ecological Observatory Network) will provide derived LiDAR products as one of its many free ecological data products. One such product is a digital surface model which represents the top of the surface elevation of objects on the earth. These products will come in a [geotiff](http://trac.osgeo.org/geotiff/ "geotiff (read more)") format, which is simply a raster format, that is spatially located on the earth. Geotiffs can be easily accessed using the `raster` package in R.

##Creating a LiDAR derived Canopy Height Model (CHM)
In this activity, we will create a Canopy Height Model. Remember that the canopy height model, represents the actual heights of the trees on the ground. And we can derive the CHM by subtracting the ground elevation from the elevation of the top of the surface (or the tops of the trees). 

To begin the CHM creation, we will call the raster libraries in R and import the lidar derived digital surface model (DSM). Then we will import and plot the DSM.


    # Import DSM into R 
    library(raster)
	
	# IMPORTANT - the path to your DSM data may be different than the path below.  
    dsm_f <- "CHANGE-THIS-TO-PATH-ON-YOUR-COMPUTER/DigitalSurfaceModel/SJER2013_DSM.tif"
    
    dsm <- raster(dsm_f)
    ## See info about the raster.
    dsm
    plot(dsm)


Next, we will import the Digital Terrain Model (DTM). Remember that the DTM represents the ground (terrain) elevation.


    # import the digital terrain model
    dtm_f <- "CHANGE-THIS-TO-PATH-ON-YOUR-COMPUTER/DigitalTerrainModel/SJER2013_DTM.tif"
    dtm <- raster(dtm_f)
    plot(dtm)

Finally, we can create the Canopy Height Model (CHM). Remember that the CHM is simply the difference between the DSM and the DTM. So, we can perform some basic raster math to accomplish this. You might perform the SAME raster math in a GIS package like [QGIS](http://www.qgis.org/en/site/ "QGIS").
    
    ## Create a function that performs this raster math. Canopy height is dsm - dtm
    canopyCalc <- function(x, y) {
      return(x - y)
      }
    
	#use the function to create the final CHM
    chm <- overlay(dsm,dtm,fun = canopyCalc)
    ### a little raster math
    plot(chm)
	#leah's note: rename cnopy --> CHM -- make sure the code works

Woo hoo! we've now successfully created a canopy height model using basic raster math - in R! 

##The Omni-present Question -- How does our CHM data compare to field measured tree heights?

So now we have a canopy height model. however, how does that dataset compare to our laboriously collected, field measured height data? Let's see.

For this activity, we have two csv (comma separate value) files. The first file contains plot centroid location information (X,Y) where we measured trees. The second file contains our vegetation structure data for each plot. Let's start by plotting the plot locations (in red) on a map. 

We will need to convert the plot centroids to a spatial points dataset in R. To do this we'll need two additional packages - the spatial package - [sp](http://cran.r-project.org/web/packages/sp/index.html "R sp package") - and [dplyr](http://cran.r-project.org/web/packages/dplyr/index.html "dplyr"). 

Let's get started!

    ```{r Data overlay}
    library(sp)
    library(dplyr)

    #import the centroid data and the vegetation structure data
	options(stringsAsFactors=FALSE)
	centroids <- read.csv("data/SJERPlotCentroids.csv")
    insitu_dat <- read.csv("data/D17_2013_vegStr.csv")

	#plot the chm
    plot(chm)

### Extract xy locations for centroids, convert to spatial format, Assign coordinate reference system 
    points(centroids$easting,centroids$northing, pch=19, cex = 2,col = 2)
    points(insitu_dat$easting,insitu_dat$northing, pch=19, cex=.5)

	# extract the CRS (coordinate reference system) from the CHM and apply it to our plot centroid data
	# In this case, we know these data are all in the same projection
	centroid_sp <- SpatialPoints(centroids[,4:3],proj4string =CRS(as.character(chm@crs)) )

### Extract CMH data within 20 m radius of each centroid.
	# Insitu sampling took place within 20m x 20m plots.	
    # Note that below will return a list, so we can extract via lapply
    cent_ovr <- extract(chm,centroid_sp,buffer = 20)
    
### Create new dataframe by pulling the CHM max value found within the 20m radius from each plot centroid location
	centroids$overlay <- unlist(lapply(cent_ovr,max))
	
	#find the max and 95th percentile value for all trees within each plot 
	insitu <- insitu_dat %.% filter(plotid %in% centroids$Plot_ID) %.% group_by(plotid) %.% summarise(quant = quantile(stemheight,.95), max = max(stemheight))
	
	centroids$insitu <- insitu$max

### Create the regression final plot that compares in situ max tree height to CHM derived max height
	ggplot(centroids,aes(x=overlay, y =insitu )) + geom_point() + theme_bw() + ylab("Maximum measured height") + xlab("Maximum LiDAR pixel")+geom_abline(intercept = 0, slope=1)+xlim(0, max(centroids[,6:7])) + ylim(0,max(centroids[,6:7]))
```



