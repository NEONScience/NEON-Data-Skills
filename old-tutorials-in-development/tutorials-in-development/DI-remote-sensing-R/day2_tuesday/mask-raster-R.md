---
layout: post
title: "Mask a Raster using Threshold Values in R"
date:   2016-06-16
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah, Naupaka]
time: "11:00"
contributors: [Megan A. Jones]
dateCreated:  2016-05-01
lastModified: 2016-06-20
packagesLibraries: [rhdf5]
categories: [self-paced-tutorial]
mainTag: institute-day2
tags: [R, HDF5]
tutorialSeries: [institute-day2]
description: "In this tutorial, we will walk through how to remove parts of a raster based on
pixel values using a mask from an analysis."
code1: institute-materials/day2_tuesday/mask-raster-R.R
image:
  feature: 
  credit: 
  creditlink:
permalink: /R/mask-raster-threshold-R/
comments: false
---

## About

In this tutorial, we will walk through how to remove parts of a raster based on
pixel values using a mask from an analysis. 

A mask raster layer is a layer that contains pixels that won't be used in the 
analysis. In `R`, these pixels as assigned an `NA` value.

<figure>
    <a href="{{ site.baseurl }}/images/spatialData/raster_masks.jpg">
    <img src="{{ site.baseurl }}/images/spatialData/raster_masks.jpg">
    </a>
    <figcaption>Raster Masks</figcaption>
</figure>

<a class="btn btn-info" href="http://www.inside-r.org/packages/cran/raster/docs/mask" target="_blank"> Read more about raster masks in R. </a>

First, let's load the required libraries.


    # load libraries
    library(raster)
    library(rhdf5)
    library(rgdal)
    
    # be sure to set your working directory
    # setwd("~/Documents/data/NEONDI-2016") # Mac
    # setwd("~/data/NEONDI-2016")  # Windows
    
    ## import functions
    # install devtools (only if you have not previously intalled it)
    #install.packages("devtools")
    # call devtools library
    #library(devtools)
    
    # install from github
    #install_github("lwasser/neon-aop-package/neonAOP")
    # call library
    library(neonAOP)
    
    
    #source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")

## Import LiDAR data

To begin, we will open the NEON LiDAR Digital Surface and Digital Terrain Models
(DSM and DTM) which are in Geotiff format.


    # import aspect data from previous lesson
    teak_nsAspect <- raster("outputs/TEAK/TEAK_nsAspect.tif")
    
    # North facing slope = 1
    # South facing slope = 2
    
    # legend outside of the plot region
    # make room for a legend
    par(xpd = FALSE, mar=c(5.1, 4.1, 4.1, 4.5))
    
    plot(teak_nsAspect, 
         col=c("white","blue","green"),
         main="North and South Facing Slopes \n Lower Teakettle",
         legend=F)
    
    # allow legend to plot outside of bounds
    par(xpd=TRUE)
    
    legend((par()$usr[2] + 20), 4103300, # set xy legend location
           legend = c("North", "South"),
           fill = c("blue", "green"), 
           bty="n") # turn off border

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/mask-raster-R/import-lidar-1.png)

## Mask Data

Once we have created a threhold classified raster, we can use it for different 
things. One application is to use it as an analysis mask for another dataset. 

Let's try to find all pixels that have an NDVI value >.6 and are north facing. 


    # open NEON NDVI data
    ndvi <- raster("NEONdata/D17-California/TEAK/2013/spectrometer/veg_index/TEAK_NDVI.tif")
    ndvi

    ## class       : RasterLayer 
    ## dimensions  : 577, 543, 313311  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 325963, 326506, 4102905, 4103482  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## data source : /Users/lwasser/Documents/data/1_NEON-DI2016/NEONdata/D17-California/TEAK/2013/spectrometer/veg_index/TEAK_NDVI.tif 
    ## names       : TEAK_NDVI 
    ## values      : -0.2252816, 0.9218391  (min, max)

    hist(ndvi,
         main="NDVI for Lower Teakettle Field Site")

    ## Warning in .hist1(x, maxpixels = maxpixels, main = main, plot = plot, ...):
    ## 32% of the raster cells were used. 100000 values used.

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/mask-raster-R/mask-data-ndvi-1.png)

    # let's create a mask
    ndvi[ndvi<.6] <- NA
    plot(ndvi,
         main="NDVI > .6")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/mask-raster-R/mask-data-ndvi-2.png)



    n.face.aspect <- teak_nsAspect==1
    
    # mask out only pixels that are north facing and NDVI >.6
    nFacing.ndvi <- mask(n.face.aspect, ndvi)
    
    plot(nFacing.ndvi,
         main="North Facing Locations \n NDVI > .6",
         legend=F)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/mask-raster-R/mask-data-1.png)

## Export Classified Raster


    # export geotiff 
    writeRaster(nFacing.ndvi,
                filename="outputs/TEAK/TEAK_n_ndvi6.tif",
                format="GTiff",
                options="COMPRESS=LZW",
                overwrite = TRUE,
                NAflag = -9999)
