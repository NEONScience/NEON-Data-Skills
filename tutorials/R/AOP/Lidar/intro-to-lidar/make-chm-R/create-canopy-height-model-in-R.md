---
syncID: 4a21c923ecc848e08af1222e5552bc89
title: "Create a Canopy Height Model from lidar-derived Rasters in R"
description: "In this tutorial, you will bring lidar-derived raster data (DSM and DTM) into R to create a canopy height model (CHM)."
dateCreated: 2014-07-21
authors: Edmund Hart, Leah A. Wasser
contributors: Donal O'Leary
estimatedTime: 0.5 Hours
packagesLibraries: raster, rgdal
topics: lidar, R, raster, remote-sensing, spatial-data-gis
languagesTool: R
dataProduct:
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Lidar/intro-to-lidar/create-canopy-height-model-in-R/create-canopy-height-model-in-R.R
tutorialSeries: [intro-lidar-r-series]
urlTitle: create-chm-rasters-r
---


A common analysis using lidar data are to derive top of the canopy height values 
from the lidar data. These values are often used to track changes in forest 
structure over time, to calculate biomass, and even leaf area index (LAI). Let's 
dive into the basics of working with raster formatted lidar data in R! 

<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this tutorial, you will be able to:

* Work with digital terrain model (DTM) & digital surface model (DSM) raster files. 
* Create a canopy height model (CHM) raster from DTM & DSM rasters. 

 
## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded 
on your computer to complete this tutorial.

### Install R Packages

* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`

<a href="https://www.neonscience.org/packages-in-r" target="_blank">More on Packages in R - Adapted from Software Carpentry.</a>

## Download Data
<h3> <a href="https://ndownloader.figshare.com/files/7907590"> NEON Teaching Data Subset: Field Site Spatial Data</a></h3>

These remote sensing data files provide information on the vegetation at the 
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank"> San Joaquin Experimental Range</a> 
and 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SOAP" target="_blank"> Soaproot Saddle</a> 
field sites. The entire dataset can be accessed by request from the 
<a href="http://data.neonscience.org" target="_blank"> NEON Data Portal</a>.

<a href="https://ndownloader.figshare.com/files/7907590" class="link--button link--arrow">
Download Dataset</a>




This tutorial is designed for you to set your working directory to the directory
created by unzipping this file.

****

**Set Working Directory:** This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

**R Script & Challenge Code:** NEON data lessons often contain challenges that reinforce 
learned skills. If available, the code for challenge solutions is found in the
downloadable R script of the entire lesson, available in the footer of each lesson page.


***

## Recommended Reading
<a href="https://www.neonscience.org/chm-dsm-dtm-gridded-lidar-data" target="_blank">
What is a CHM, DSM and DTM? About Gridded, Raster lidar Data</a>

</div>

## Create a lidar-derived Canopy Height Model (CHM)

The National Ecological Observatory Network (NEON) will provide lidar-derived 
data products as one of its many free ecological data products. These products 
will come in the 
<a href="http://trac.osgeo.org/geotiff/" target="_blank">GeoTIFF</a> 
format, which is a .tif raster format that is spatially located on the earth. 

In this tutorial, we create a Canopy Height Model. The 
<a href="https://www.neonscience.org/chm-dsm-dtm-gridded-lidar-data" target="_blank">Canopy Height Model (CHM)</a>,
represents the heights of the trees on the ground. We can derive the CHM 
by subtracting the ground elevation from the elevation of the top of the surface 
(or the tops of the trees). 

We will use the `raster` R package to work with the the lidar-derived digital 
surface model (DSM) and the digital terrain model (DTM). 


    # Load needed packages
    library(raster)
    library(rgdal)
    
    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files. Be sure to move the download into your working directory!
    wd="~/Git/data/" #This will depend on your local environment
    setwd(wd)

First, we will import the Digital Surface Model (DSM). The 
<a href="https://www.neonscience.org/resources/learning-hub/tutorials/chm-dsm-dtm-gridded-lidar-data" target="_blank">DSM</a>
represents the elevation of the top of the objects on the ground (trees, 
buildings, etc).


    # assign raster to object
    dsm <- raster(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/DigitalSurfaceModel/SJER2013_DSM.tif"))
    
    # view info about the raster.
    dsm

    ## class      : RasterLayer 
    ## dimensions : 5060, 4299, 21752940  (nrow, ncol, ncell)
    ## resolution : 1, 1  (x, y)
    ## extent     : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
    ## crs        : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs 
    ## source     : /Users/olearyd/Git/data/NEON-DS-Field-Site-Spatial-Data/SJER/DigitalSurfaceModel/SJER2013_DSM.tif 
    ## names      : SJER2013_DSM

    # plot the DSM
    plot(dsm, main="Lidar Digital Surface Model \n SJER, California")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Lidar/intro-to-lidar/create-canopy-height-model-in-R/rfigs/import-dsm-1.png)

Note the resolution, extent, and coordinate reference system (CRS) of the raster. 
To do later steps, our DTM will need to be the same. 

Next, we will import the Digital Terrain Model (DTM) for the same area. The 
<a href="{{ base.url }}/chm-dsm-dtm-gridded-lidar-data" target="_blank">DTM</a>
represents the ground (terrain) elevation.


    # import the digital terrain model
    dtm <- raster(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/DigitalTerrainModel/SJER2013_DTM.tif"))
    
    plot(dtm, main="Lidar Digital Terrain Model \n SJER, California")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Lidar/intro-to-lidar/create-canopy-height-model-in-R/rfigs/plot-DTM-1.png)

With both of these rasters now loaded, we can create the Canopy Height Model 
(CHM). The 
<a href="{{ base.url }}/chm-dsm-dtm-gridded-lidar-data" target="_blank">CHM</a>
represents the difference between the DSM and the DTM or the height of all objects
on the surface of the earth. 

To do this we perform some basic raster math to calculate the CHM. You can 
perform the same raster math in a GIS program like 
<a href="http://www.qgis.org/en/site/" target="_blank">QGIS</a>.

When you do the math, make sure to subtract the DTM from the DSM or you'll get 
trees with negative heights!


    # use raster math to create CHM
    chm <- dsm - dtm
    
    # view CHM attributes
    chm

    ## class      : RasterLayer 
    ## dimensions : 5060, 4299, 21752940  (nrow, ncol, ncell)
    ## resolution : 1, 1  (x, y)
    ## extent     : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
    ## crs        : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs 
    ## source     : memory
    ## names      : layer 
    ## values     : -1.399994, 40.29001  (min, max)

    plot(chm, main="Lidar Canopy Height Model \n SJER, California")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Lidar/intro-to-lidar/create-canopy-height-model-in-R/rfigs/calculate-plot-CHM-1.png)

We've now created a CHM from our DSM and DTM. What do you notice about the 
canopy cover at this location in the San Joaquin Experimental Range? 

<div id="ds-challenge" markdown="1">
### Challenge: Basic Raster Math 

Convert the CHM from meters to feet. Plot it. 
</div>

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Lidar/intro-to-lidar/create-canopy-height-model-in-R/rfigs/challenge-code-raster-math-1.png)

If, in your work you need to create lots of CHMs from different rasters, an 
efficient way to do this would be to create a function to create your CHMs. 


    # Create a function that subtracts one raster from another
    # 
    canopyCalc <- function(DTM, DSM) {
      return(DSM -DTM)
      }
        
    # use the function to create the final CHM
    chm2 <- canopyCalc(dsm,dtm)
    chm2

    ## class      : RasterLayer 
    ## dimensions : 5060, 4299, 21752940  (nrow, ncol, ncell)
    ## resolution : 1, 1  (x, y)
    ## extent     : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
    ## crs        : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs 
    ## source     : memory
    ## names      : layer 
    ## values     : -40.29001, 1.399994  (min, max)

    # or use the overlay function
    chm3 <- overlay(dsm,dtm,fun = canopyCalc) 
    chm3 

    ## class      : RasterLayer 
    ## dimensions : 5060, 4299, 21752940  (nrow, ncol, ncell)
    ## resolution : 1, 1  (x, y)
    ## extent     : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
    ## crs        : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs 
    ## source     : memory
    ## names      : layer 
    ## values     : -40.29001, 1.399994  (min, max)

As with any raster, we can write out the CHM as a GeoTiff using the 
`writeRaster()` function. 


    # write out the CHM in tiff format. 
    writeRaster(chm,paste0(wd,"chm_SJER.tif"),"GTiff")

We've now successfully created a canopy height model using basic raster math -- in 
R! We can bring the `chm_SJER.tif` file into QGIS (or any GIS program) and look 
at it. 

***

Consider going onto the next tutorial 
<a href="https://www.neonscience.org/extract-raster-values-R/" target="_blank">*Extract Values from a Raster in R*</a>
to compare this lidar-derived CHM with ground-based observations!

