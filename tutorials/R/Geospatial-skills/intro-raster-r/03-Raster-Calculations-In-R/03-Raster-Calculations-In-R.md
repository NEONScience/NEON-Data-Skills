---
syncID: d3f52facdd2e4ed9862a56f28217f5cb
title: "Raster 03: Raster Calculations in R - Subtract One Raster from Another and Extract Pixel Values For Defined Locations"
description: "This tutorial covers how to subtract one raster from another using efficient methods - the overlay function compared to basic subtraction. We also cover how to extract pixel values from a set of locations - for example a buffer region around plot locations at a field site. Finally, it explains the basic principles of writing functions in R."	
dateCreated: 2015-10-23
authors: Leah A. Wasser, Megan A. Jones, Zack Brym, Kristina Riemer, Jason Williams, Jeff Hollister,  Mike Smorul	
contributors:	Jason Brown
estimatedTime: 30 minutes
packagesLibraries: raster, rgdal
topics: data-analysis, raster, spatial-data-gis
languagesTool: R
dataProduct: DP3.30024.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/03-Raster-Calculations-In-R.R
tutorialSeries: raster-data-series
urlTitle: dc-raster-calculations-r

---

We often want to combine values of and perform calculations on rasters to create 
a new output raster. This tutorial covers how to subtract one raster from 
another using basic raster math and the `overlay()` function. It also covers how 
to extract pixel values from a set of locations - for example a buffer region 
around plot locations at a field site. 


<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this tutorial, you will be able to:

* Be able to to perform a subtraction (difference) between two rasters using 
raster math.
* Know how to perform a more efficient subtraction (difference) between two 
rasters using the raster `overlay()` function in R.

## Things You’ll Need To Complete This Tutorial

You will need the most current version of R and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages

* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`

* <a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

#### Data to Download

<h3> <a href="https://ndownloader.figshare.com/files/3701578"> NEON Teaching Data Subset: Airborne Remote Sensing Data </a></h3>

The LiDAR and imagery data used to create this raster teaching data subset 
were collected over the 
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map/HARV" target="_blank" >Harvard Forest</a>
and 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank" >San Joaquin Experimental Range</a>
field sites and processed at NEON headquarters. 
The entire dataset can be accessed by request from the 
<a href="http://data.neonscience.org" target="_blank"> NEON Data Portal</a>.

<a href="https://ndownloader.figshare.com/files/3701578" class="link--button link--arrow"> Download Dataset</a>





### TEST BUTTON CSS

<div><a href="https://ndownloader.figshare.com/files/3701578" class="link--button link--arrow"> Download NEON Teaching Data Subset: Airborne Remote Sensing Data</a>
</div>


****

**Set Working Directory:** This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

**R Script & Challenge Code:** NEON data lessons often contain challenges that reinforce 
learned skills. If available, the code for challenge solutions is found in the
downloadable R script of the entire lesson, available in the footer of each lesson page.


****

### Additional Resources
* <a href="http://cran.r-project.org/web/packages/raster/raster.pdf" target="_blank">Read more about the `raster` package in R.</a>

</div>

## Raster Calculations in R
We often want to perform calculations on two or more rasters to create a new 
output raster. For example, if we are interested in mapping the heights of trees
across an entire field site, we might want to calculate the *difference* between
the Digital Surface Model (DSM, tops of trees) and the 
Digital Terrain Model (DTM, ground level). The resulting dataset is referred to 
as a Canopy Height Model (CHM) and represents the actual height of trees, 
buildings, etc. with the influence of ground elevation removed.

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/lidar-derived-products/lidarTree-height.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/lidar-derived-products/lidarTree-height.png"
    ALT="Series of three images depicting the differences between a digital surface model (DSM), a digital terrain model (DTM), and a canopy height model (CHM). DSM - DTM = CHM."
    </a>
    <figcaption> Source: National Ecological Observatory Network (NEON)
    </figcaption>
</figure>

* Check out more on LiDAR CHM, DTM and DSM in this NEON Data Skills overview tutorial: 
<a href="https://www.neonscience.org/chm-dsm-dtm-gridded-lidar-data" target="_blank"> 
*What is a CHM, DSM and DTM? About Gridded, Raster LiDAR Data*</a>. 

### Load the Data 
We will need the `raster` package to import and perform raster calculations. We
will use the DTM (`NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif`) 
and DSM (`NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif`) from the
NEON Harvard Forest Field site.


    # load raster package
    library(raster)
    
    # set working directory to ensure R can find the file we wish to import
    wd <- "~/Git/data/" # this will depend on your local environment environment
    # be sure that the downloaded file is in this directory
    setwd(wd)
    
    # view info about the dtm & dsm raster data that we will work with.
    GDALinfo(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif"))

    ## rows        1367 
    ## columns     1697 
    ## bands       1 
    ## lower left origin.x        731453 
    ## lower left origin.y        4712471 
    ## res.x       1 
    ## res.y       1 
    ## ysign       -1 
    ## oblique.x   0 
    ## oblique.y   0 
    ## driver      GTiff 
    ## projection  +proj=utm +zone=18 +datum=WGS84 +units=m +no_defs 
    ## file        ~/Git/data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif 
    ## apparent band summary:
    ##    GDType hasNoDataValue NoDataValue blockSize1 blockSize2
    ## 1 Float64           TRUE       -9999          1       1697
    ## apparent band statistics:
    ##     Bmin   Bmax    Bmean      Bsd
    ## 1 304.56 389.82 344.8979 15.86147
    ## Metadata:
    ## AREA_OR_POINT=Area

    GDALinfo(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif"))

    ## rows        1367 
    ## columns     1697 
    ## bands       1 
    ## lower left origin.x        731453 
    ## lower left origin.y        4712471 
    ## res.x       1 
    ## res.y       1 
    ## ysign       -1 
    ## oblique.x   0 
    ## oblique.y   0 
    ## driver      GTiff 
    ## projection  +proj=utm +zone=18 +datum=WGS84 +units=m +no_defs 
    ## file        ~/Git/data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif 
    ## apparent band summary:
    ##    GDType hasNoDataValue NoDataValue blockSize1 blockSize2
    ## 1 Float64           TRUE       -9999          1       1697
    ## apparent band statistics:
    ##     Bmin   Bmax    Bmean      Bsd
    ## 1 305.07 416.07 359.8531 17.83169
    ## Metadata:
    ## AREA_OR_POINT=Area

As seen from the `geoTiff` tags, both rasters have:

* the same CRS, 
* the same resolution 
* defined minimum and maximum values.

Let's load the data. 


    # load the DTM & DSM rasters
    DTM_HARV <- raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif"))
    DSM_HARV <- raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif"))
    
    # create a quick plot of each to see what we're dealing with
    plot(DTM_HARV,
         main="Digital Terrain Model \n NEON Harvard Forest Field Site")

![Digital terrain model showing the ground surface of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/load-plot-data-1.png)

    plot(DSM_HARV,
         main="Digital Surface Model \n NEON Harvard Forest Field Site")

![Digital surface model showing the elevation of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/load-plot-data-2.png)

## Two Ways to Perform Raster Calculations

We can calculate the difference between two rasters in two different ways:

* by directly subtracting the two rasters in R using raster math

or for more efficient processing - particularly if our rasters are large and/or
the calculations we are performing are complex:

* using the `overlay()` function.

## Raster Math & Canopy Height Models
We can perform raster calculations by simply subtracting (or adding,
multiplying, etc) two rasters. In the geospatial world, we call this
"raster math".

Let's subtract the DTM from the DSM to create a Canopy Height Model.


    # Raster math example
    CHM_HARV <- DSM_HARV - DTM_HARV 
    
    # plot the output CHM
    plot(CHM_HARV,
         main="Canopy Height Model - Raster Math Subtract\n NEON Harvard Forest Field Site",
         axes=FALSE) 

![Canopy height model showing the height of the trees of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/raster-math-1.png)

Let's have a look at the distribution of values in our newly created
Canopy Height Model (CHM).


    # histogram of CHM_HARV
    hist(CHM_HARV,
      col="springgreen4",
      main="Histogram of Canopy Height Model\nNEON Harvard Forest Field Site",
      ylab="Number of Pixels",
      xlab="Tree Height (m) ")

![Histogram of canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/create-hist-1.png)

Notice that the range of values for the output CHM is between 0 and 30 meters.
Does this make sense for trees in Harvard Forest?

<div id="ds-challenge" markdown="1">
### Challenge: Explore CHM Raster Values
It's often a good idea to explore the range of values in a raster dataset just
like we might explore a dataset that we collected in the field.  

1. What is the min and maximum value for the Harvard Forest Canopy 
Height Model (`CHM_HARV`) that we just created?
2. What are two ways you can check this range of data in `CHM_HARV`? 
3. What is the distribution of all the pixel values in the CHM? 
4. Plot a histogram with 8 bins instead of the default and change the color of
the histogram. 
5. Plot the `CHM_HARV` raster using breaks that make sense for the data. Include
a appropriate color palette for the data, plot title and no axes ticks / labels. 

</div>

![Histogram of canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/challenge-code-CHM-HARV-1.png)![Histogram of canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest with six breaks](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/challenge-code-CHM-HARV-2.png)![Canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest with four breaks](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/challenge-code-CHM-HARV-3.png)

## Overlay Function: Efficient Raster Calculations 
Raster math, like we just did, is an appropriate approach to raster calculations
if:

1. The rasters we are using are small in size.
2. The calculations we are performing are simple.

However, raster math is a less efficient approach as computation becomes more
complex or as file sizes become large. 
The `overlay()` function is more efficient when:

1. The rasters we are using are larger in size. 
2. The rasters are stored as individual files. 
3. The computations performed are complex. 

The `overlay()` function takes two or more rasters and applies a function to
them using efficient processing methods. The syntax is

`outputRaster <- overlay(raster1, raster2, fun=functionName)`

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** If the rasters are stacked and stored 
as `RasterStack` or `RasterBrick` objects in R, then we should use `calc()`. 
`overlay()` will not work on stacked rasters. 
</div>

Let's perform the same subtraction calculation that we calculated above using 
raster math, using the `overlay()` function.  


    CHM_ov_HARV<- overlay(DSM_HARV,
                          DTM_HARV,
                          fun=function(r1, r2){return(r1-r2)})
    
    plot(CHM_ov_HARV,
      main="Canopy Height Model - Overlay Subtract\n NEON Harvard Forest Field Site")

![Canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest produced by the overlay() function](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/raster-overlay-1.png)

How do the plots of the CHM created with manual raster math and the `overlay()`
function compare?  

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** A custom function consists of a defined
set of commands performed on a input object. Custom functions are particularly 
useful for tasks that need to be repeated over and over in the code. A
simplified syntax for writing a custom function in R is:
`functionName <- function(variable1, variable2){WhatYouWantDone, WhatToReturn}`
</div>

## Export a GeoTIFF
Now that we've created a new raster, let's export the data as a `GeoTIFF` using
the `writeRaster()` function. 

When we write this raster object to a `GeoTIFF` file we'll name it 
`chm_HARV.tiff`. This name allows us to quickly remember both what the data
contains (CHM data) and for where (HARVard Forest). The `writeRaster()` function
by default writes the output file to your working directory unless you specify a 
full file path.


    # export CHM object to new GeotIFF
    writeRaster(CHM_ov_HARV, paste0(wd,"chm_HARV.tiff"),
                format="GTiff",  # specify output format - GeoTIFF
                overwrite=TRUE, # CAUTION: if this is true, it will overwrite an
                                # existing file
                NAflag=-9999) # set no data value to -9999

### writeRaster Options
The function arguments that we used above include:

* **format:** specify that the format will be `GTiff` or `GeoTiff`. 
* **overwrite:** If TRUE, R will overwrite any existing file  with the same
name in the specified directory. USE THIS SETTING WITH CAUTION!
* **NAflag:** set the `geotiff` tag for `NoDataValue` to -9999, the National
Ecological Observatory Network's (NEON) standard `NoDataValue`. 

<div id="ds-challenge" markdown="1">
### Challenge: Explore the NEON San Joaquin Experimental Range Field Site

Data are often more interesting and powerful when we compare them across various 
locations. Let's compare some data collected over Harvard Forest to data
collected in Southern California. The 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank" >NEON San Joaquin Experimental Range (SJER) field site </a> 
located in Southern California has a very different ecosystem and weather than
the
<a href="https://www.neonscience.org/field-sites/field-sites-map/HARV" target="_blank" >NEON Harvard Forest Field Site</a>
in Massachusetts.  

Import the SJER DSM and DTM raster files and create a Canopy Height Model.
Then compare the two sites. Be sure to name your R objects and outputs
carefully, as follows: objectType_SJER (e.g. `DSM_SJER`). This will help you
keep track of data from different sites!

1. Import the DSM and DTM from the SJER directory (if not aready imported
in the 
<a href="https://www.neonscience.org/dc-plot-raster-data-r" target="_blank"> *Plot Raster Data in R* tutorial</a>.) 
Don't forget to examine the data for `CRS`, bad values, etc. 
2. Create a `CHM` from the two raster layers and check to make sure the data
are what you expect. 
3. Plot the `CHM` from SJER. 
4. Export the SJER CHM as a `GeoTIFF`.
5. Compare the vegetation structure of the Harvard Forest and San Joaquin 
Experimental Range. 

Hint: plotting SJER and HARV data side-by-side is an effective way to compare
both datasets!

</div>

![Histogram of digital terrain model showing the distribution of the ground surface of NEON's site San Joaquin Experimental Range](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/challenge-code-SJER-CHM-1.png)![Histogram of digital surface model showing the distribution of the elevation of NEON's site San Joaquin Experimental Range](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/challenge-code-SJER-CHM-2.png)![Histogram of canopy height model showing the distribution of the height of the trees of NEON's site San Joaquin Experimental Range](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/challenge-code-SJER-CHM-3.png)![Canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/challenge-code-SJER-CHM-4.png)![Histogram of canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/03-Raster-Calculations-In-R/rfigs/challenge-code-SJER-CHM-5.png)

What do these two histograms tell us about the vegetation structure at Harvard 
and SJER?
