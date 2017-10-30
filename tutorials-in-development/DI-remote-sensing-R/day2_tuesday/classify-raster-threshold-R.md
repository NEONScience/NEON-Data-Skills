---
layout: post
title: "Classify a Raster using Threshold Values in R"
date:   2016-06-17
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah, Naupaka]
time: "10:15"
contributors: [Megan A. Jones]
dateCreated:  2016-05-01
lastModified: 2016-06-20
packagesLibraries: [raster]
categories: [self-paced-tutorial]
mainTag: institute-day2
tags: [R, HDF5]
tutorialSeries: [institute-day2]
description: "Classify rasters in R using threshold values."
code1: institute-materials/day2_tuesday/classify-raster-threshold-R.R
image:
  feature:
  credit:
  creditlink:
permalink: /R/classify-by-threshold-R/
comments: false
---

## About

In this tutorial, we will walk through how to classify a raster file using
defined value ranges in R.

First, let's load the required libraries.


    # load libraries
    library(raster)
    library(rhdf5)
    library(rgdal)
    
    # be sure to set your working directory
    # setwd("~/Documents/data/NEONDI-2016") # Mac
    # setwd("~/data/NEONDI-2016")  # Windows
    
    #source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")

## Import LiDAR data

To begin, we will open the NEON LiDAR Digital Surface and Digital Terrain Models
(DSM and DTM) which are in Geotiff format.


    # read LiDAR canopy height model
    chm <- raster("NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarCHM.tif")

## View CHM


    # assign chm values of 0 to NA
    chm[chm==0] <- NA
    
    # do the values in the data look reasonable?
    plot(chm,
         main="Canopy Height \n LowerTeakettle, California")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/classify-raster-threshold-R/explore-chm-1.png)

    hist(chm,
         main="Distribution of Canopy Height  \n Lower Teakettle, California",
         xlab="Tree Height (m)",
         col="springgreen")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/classify-raster-threshold-R/explore-chm-2.png)

## Import Aspect Data

Next, we'll import an aspect dataset - one of the NEON data products.

<i class="fa fa-star"></i> **Data Tip:** You can calculate aspect in R
if you have a surface or elevation model as follows:  
`terrain(your.raster.data, opt = "aspect", unit = "degrees", neighbors = 8)` .
{: .notice}


    # calculate aspect of cropped DTM
    # aspect <- terrain(your-dem-or-terrain-data.tif, opt = "aspect", unit = "degrees", neighbors = 8)
    # example code:
    # aspect <- terrain(all.data[[3]], opt = "aspect", unit = "degrees", neighbors = 8)
    # read in aspect .tif
    aspect <- raster("NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarAspect.tif")
    
    plot(aspect,
         main="Aspect for Lower Teakettle Field Site",
         axes=F)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/classify-raster-threshold-R/import-aspect-data-1.png)

## Threshold Based Raster Classification

Next, we will create a classified raster object. To do this we need to:

1. Create a matrix containing the threshold ranges and the associated "class"
2. Use the `raster::reclassify` function to create a new raster.

Our range of values are as follows:
We will assign all north facing slopes "1" and south facing "2".

**North Facing Slopes:** 0-45 degrees, 315-360 degrees; class=1

**South Facing Slopes:** 135-225 degrees; class=2



    # first create a matrix of values that represent the classification ranges
    # North facing = 1
    # South facing = 2
    class.m <- c(0, 45, 1,
                 45, 135, NA,
                 135, 225, 2,  
                 225 , 315, NA,
                 315, 360, 1)
    class.m

    ##  [1]   0  45   1  45 135  NA 135 225   2 225 315  NA 315 360   1

    # reshape the object into a matrix with columns and rows
    rcl.m <- matrix(class.m, 
                    ncol=3, 
                    byrow=TRUE)
    rcl.m

    ##      [,1] [,2] [,3]
    ## [1,]    0   45    1
    ## [2,]   45  135   NA
    ## [3,]  135  225    2
    ## [4,]  225  315   NA
    ## [5,]  315  360    1

    # reclassify the raster using the reclass object - rcl.m
    asp.ns <- reclassify(aspect, 
                         rcl.m)
    
    # plot outside of the plot region
    
    # make room for a legend
    par(xpd = FALSE, mar=c(5.1, 4.1, 4.1, 4.5))
    # plot
    plot(asp.ns,
         col=c("white","blue","green"), # hard code colors, unclassified (0)=white,
    		 #N (1) =blue, S(2)=green
         main="North and South Facing Slopes \nLower Teakettle",
         legend=F)
    # allow legend to plot outside of bounds
    par(xpd=TRUE)
    # create the legend
    legend((par()$usr[2] + 20), 4103300,  # set x,y legend location
           legend = c("North", "South"),  # make sure the order matches the colors, next
           fill = c("blue", "green"),
           bty="n") # turn off border

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/classify-raster-threshold-R/classify-raster-1.png)

## Export Classified Raster


    # export geotiff
    writeRaster(asp.ns,
                filename="outputs/TEAK/Teak_nsAspect.tif",
                format="GTiff",
                options="COMPRESS=LZW",
                overwrite = TRUE,
                NAflag = -9999)

<div id="challenge" markdown="1">
## Challenge: Classify a Raster using Threshold Values

1. Have a look at the code that you created for this lesson. Now imagine that you are
your future self. Document your script so that your methods and process  is clear.
2. In documenting your script, synthesize the outputs.Do they tell you anything
about vegetation structure at the field site?
3. Create the following threshold classified outputs:

* A raster where NDVI values are classified into categories 0 (low greenness,
NDVI <.3), 1 (medium greenness, NDVI =.3-.6) and 2 (high greenness, NDVI>.6).
* A raster where canopy height is classified. Explore the CHM data and chose
threshold values that make sense given the distribution of values in the data.

Be sure to document your workflow as you go using Markdown within your R Markdown
document.

When you are done, knit your outputs to HTML. Save the file as
LastName_Tues_classifyThreshold.html. Add these to the Tuesday directory in your
**DI16-NEON-participants** Git direcotry and push them to your fork in GitHub.
Merge with the central repository using a pull request.
</div>
