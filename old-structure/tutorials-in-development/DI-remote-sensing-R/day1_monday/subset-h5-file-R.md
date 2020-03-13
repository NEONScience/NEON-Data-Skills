---
layout: post
title: "Subset HDF5 file in R"
date:   2016-06-16
authors: [Leah A. Wasser]
instructors:
contributors: [Megan A. Jones]
time:
dateCreated:  2016-05-10
lastModified: 2016-06-22
packagesLibraries: [rhdf5]
categories: [self-paced-tutorial]
mainTag: institute-day1
tags: [R, HDF5]
tutorialSeries: [institute-day1]
description: "Learn how to subset an H5 file in R."
code1: institute-materials/day1_monday/subset-h5-file-R.R
image:
  feature:
  credit:
  creditlink:
permalink: /R/subset-hdf5-R/
comments: false
---


<div id="objectives">
<strong>R Skill Level:</strong> Intermediate

<h3>Goals / Objectives</h3>
After completing this activity, you will be able to:
<ol>
<li>Subset an HDF5 file.</li>

</ol>

</div>

## Getting Started

In this tutorial, we will extract a single-pixel's worth of reflectance values
from an HDF5 file and plot a spectral profile for that pixel.


    # load packages
    library(rhdf5)
    library(raster)
    library(plyr)
    library(rgeos)
    library(rgdal)
    library(ggplot2)
    
    # be sure to set your working directory
    # setwd("~/Documents/data/NEONDI-2016") # Mac
    # setwd("~/data/NEONDI-2016")  # Windows

## Import H5 Functions

We have built a suite of **functions** that allow us to quickly open and read 
NEON hyperspectral imagery data from an `hdf5` file. 


    # install devtools (only if you have not previously intalled it)
    # install.packages("devtools")
    # call devtools library
    #library(devtools)
    
    ## install from github
    # install_github("lwasser/neon-aop-package/neonAOP")
    ## call library
    library(neonAOP)
    
    
    
    # your file will be in your working directory! This one happens to be in a diff dir
    # than our data
    # source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")

## Open H5 File

Next, let's define a few variables that we will need to access the H5 file.


    # Define the file name to be opened
    f <- "NEONdata/D17-California/TEAK/2013/spectrometer/reflectance/Subset3NIS1_20130614_100459_atmcor.h5"
    
    # Look at the HDF5 file structure
    h5ls(f, all=T)
    
    # define the CRS in EPGS format for the file
    epsg <- 32611

## Read Wavelength Values

Next, let's read in the wavelength center associated with each band in the HDF5
file.


    # read in the wavelength information from the HDF5 file
    wavelengths<- h5read(f,"wavelength")
    # convert wavelength to nanometers (nm)
    # NOTE: this is optional!
    wavelengths <- wavelengths*1000


## Get Subset
Next, we might want to extract just a subset of our data to pull a spectral
signature. For example, a plot boundary.


    # get of H5 file map tie point
    h5.ext <- create_extent(f)
    
    # turn the H5 extent into a polygon to check overlap
    h5.ext.poly <- as(extent(h5.ext), "SpatialPolygons")
    
    # open file clipping extent
    clip.extent <- readOGR("NEONdata/D17-California/TEAK/vector_data", "TEAK_plot")

    ## OGR data source with driver: ESRI Shapefile 
    ## Source: "NEONdata/D17-California/TEAK/vector_data", layer: "TEAK_plot"
    ## with 1 features
    ## It has 1 fields

    # assign crs to h5 extent
    # paste0("+init=epsg:", epsg) -- it is better to use the proj string here
    
    crs(h5.ext.poly) <- CRS("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
    
    
    # ensure the two extents overlap
    gIntersects(h5.ext.poly, clip.extent)

    ## [1] TRUE

    # if they overlap, then calculate the extent
    # this doesn't currently account for pixel size at all 
    # and these values need to be ROUNDED
    
    yscale <- 1
    xscale <- 1
    
    # define index extent
    # xmin.index, xmax.index, ymin.index,ymax.index
    # all units will be rounded which means the pixel must occupy a majority (.5 or greater)
    # within the clipping extent
    index.bounds <- calculate_index_extent(extent(clip.extent),
    																			 h5.ext)
    
    # open a band that is subsetted using the clipping extent
    b58_clipped <- neonAOP::open_band(fileName=f,
    								bandNum=58,
    								epsg=32611,
    								subsetData = TRUE,
    								dims=index.bounds)
    
    # plot clipped bands
    plot(b58_clipped,
         main="Band 58 Clipped")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/extract-subset-1.png)

## Run Subset over Many Bands


    # within the clipping extent
    index.bounds <- calculate_index_extent(extent(clip.extent),
    																			 h5.ext)
    # create  alist of the bands
    bands <- list(19,34,58)
    # within the clipping extent
    index.bounds <- calculate_index_extent(extent(clip.extent),
                  h5.ext)
    # clip out raster
    rgbRast.clip <- neonAOP::create_stack(file=f,
                bands=bands,
                epsg=epsg,
                subset=TRUE,
                dims=index.bounds)
    
    plotRGB(rgbRast.clip,
            stretch="lin")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/open-many-bands-1.png)

## Unclipped Data
And here are the same data not subsetted but with the subset region overlayed
on top.


    rgbRast <- create_stack(file=f,
                             bands=bands,
                             epsg=epsg,
                             subset=FALSE)
    
    plotRGB(rgbRast,
            stretch="lin")
    
    plot(clip.extent,
         add=T,
         border="yellow",
         lwd=3)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/plot-RGB-stack-1.png)

## View Spectra Within Clipped Raster


    # array containing the index dimensions to slice
    H5close()
    
    subset.h5 <- h5read(f, "Reflectance",
                        index=list(index.bounds[1]:index.bounds[2],
                        					 index.bounds[3]:index.bounds[4],
                        					 1:426)) # the column, row
    
    final.spectra <- data.frame(apply(subset.h5,
                  MARGIN = c(3), # take the mean value for each z value
                  mean)) # grab the mean value in the z dimension
    final.spectra$wavelength <- wavelengths
    
    # scale the data
    names(final.spectra) <- c("reflectance","wavelength")
    final.spectra$reflectance <- final.spectra$reflectance / 10000
    
    
    # plot the data
    qplot(x=final.spectra$wavelength,
          y=final.spectra$reflectance,
          xlab="Wavelength (nm)",
          ylab="Reflectance",
          main="Mean Spectral Signature for Clip Region")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/subset-h5-file-1.png)
