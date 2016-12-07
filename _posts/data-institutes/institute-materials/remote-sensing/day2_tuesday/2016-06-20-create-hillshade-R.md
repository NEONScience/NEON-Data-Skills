---
layout: post
title: "Create a Hillshade from a Terrain Raster in R"
date:   2016-06-18
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah, Naupaka]
time:
contributors: [Megan A. Jones]
dateCreated:  2016-05-01
lastModified: 2016-06-20
packagesLibraries: [rhdf5]
categories: [self-paced-tutorial]
mainTag: institute-day2
tags: [R, HDF5]
tutorialSeries: [institute-day2]
description: "Create a hillshade from a raster object in R."
code1: institute-materials/day2_tuesday/create-hillshade-R.R
image:
  feature: 
  credit: 
  creditlink:
permalink: /R/create-hillshade-R/
comments: false
---

## About

In this tutorial, we will walk through how to create a hillshade from terrain
rasters in R.

First, let's load the required libraries.


    # load libraries
    library(raster)
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
(DSM and DTM) which are in GeoTIFF format.


    # read LiDAR data
    # dsm = digital surface model == top of canopy
    dsm <- raster("NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarDSM.tif")
    # dtm = digital terrain model = elevation
    dtm <- raster("NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarDTM.tif") 
    
    # lets also import the canopy height model (CHM).
    chm <- raster("NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarCHM.tif")



    slope <- terrain(dsm, opt='slope')
    aspect <- terrain(dsm, opt='aspect')
    # create hillshade
    # numbers 
    dsm.hill <- hillShade(slope, aspect, 
                          angle=40, 
                          direction=270)
    
    plot(dsm.hill,
         col=grey.colors(100, start=0, end=1),
         legend=F)
    # overlay CHM on top of hillshade
    plot(chm,
         add=T,
         alpha=.4)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/create-hillshade-R/create-hillshade-1.png)


## Export Classified Raster

Now we can export the hillshade raster as a GeoTIFF. 


    # export geotiff 
    writeRaster(dsm.hill,
                filename="outputs/TEAK/TEAK_dsm_hill.tif",
                format="GTiff",
                options="COMPRESS=LZW",
                overwrite = TRUE,
                NAflag = -9999)
