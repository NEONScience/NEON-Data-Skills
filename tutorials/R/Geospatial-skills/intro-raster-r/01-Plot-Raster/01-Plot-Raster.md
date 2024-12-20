---
syncID: cdeed1d7546a4a179c0cd83b17a4938c
title: "Raster 01: Plot Raster Data in R"	
description: "This tutorial explains how to plot a raster in R using R's base plot function. It also shows how to create a hillshade and layer a DSM raster on top of a hillshade to produce an eloquent map."	
dateCreated: 2015-10-2
authors: Leah A. Wasser, Megan A. Jones, Zack Brym, Kristina Riemer, Jason Williams, Jeff Hollister,  Mike Smorul	
contributors:	Jason Brown, Bridget Hass
estimatedTime: 30 minutes
packagesLibraries: terra
topics: data-viz, raster, spatial-data-gis
languagesTool: R
dataProduct: DP3.30024.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/01-Plot-Raster.R
tutorialSeries: raster-data-series
urlTitle: plot-raster-data-r
---


This tutorial reviews how to plot a raster in R using the `plot()` 
function. It also covers how to layer a raster on top of a hillshade to produce 
an eloquent map.

<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this tutorial, you will be able to:

* Know how to plot a single band raster in R.
* Know how to layer a raster dataset on top of a hillshade to create an elegant 
basemap.

## Things You’ll Need To Complete This Tutorial

You will need the most current version of R and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages

* **terra:** `install.packages("terra")`

* <a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

#### Download Data

Data required for this tutorial will be downloaded using `neonUtilities` in the lesson.

The LiDAR and imagery data used in this lesson were collected over the 
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/HARV" target="_blank" >Harvard Forest (HARV)</a> 
field site. 

The entire dataset can be accessed from the 
<a href="http://data.neonscience.org" target="_blank">NEON Data Portal</a>.


****

**Set Working Directory:** This lesson will explain how to set the working directory. You may wish to set your working directory to some other location, depending on how you prefer to organize your data.

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>


****

### Additional Resources

* <a href="https://cran.r-project.org/web/packages/terra/terra.pdf" target="_blank">Read more about the `terra` package in R.</a>

</div>

## Plot Raster Data in R
In this tutorial, we will plot the Digital Surface Model (DSM) raster 
for the NEON Harvard Forest Field Site. We will use the `hist()` function as a 
tool to explore raster values. And render categorical plots, using the `breaks` 
argument to get bins that are meaningful representations of our data. 

We will use the `terra` package in this tutorial. If you do not
have the `DSM_HARV` variable as defined in the pervious tutorial, <a href="https://www.neonscience.org/dc-raster-data-r" target="_blank"> *Intro To Raster In R*</a>, please download it using `neonUtilities`, as shown in the previous tutorial.  


    library(terra)

    

    # set working directory

    wd <- "~/data/"

    setwd(wd)

    

    # import raster into R

    dsm_harv_file <- paste0(wd, "DP3.30024.001/neon-aop-products/2022/FullSite/D01/2022_HARV_7/L3/DiscreteLidar/DSMGtif/NEON_D01_HARV_DP3_732000_4713000_DSM.tif")

    DSM_HARV <- rast(dsm_harv_file)

First, let's plot our Digital Surface Model object (`DSM_HARV`) using the
`plot()` function. We add a title using the argument `main="title"`.


    # Plot raster object

    plot(DSM_HARV, main="Digital Surface Model - HARV")

![Digital surface model showing the continuous elevation of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/hist-raster-1.png)

## Plotting Data Using Breaks
We can view our data "symbolized" or colored according to ranges of values
rather than using a continuous color ramp. This is comparable to a "classified"
map. However, to assign breaks, it is useful to first explore the distribution
of the data using a histogram. The `breaks` argument in the `hist()` function
tells R to use fewer or more breaks or bins. 

If we name the histogram, we can also view counts for each bin and assigned
break values.  


    # Plot distribution of raster values 

    DSMhist<-hist(DSM_HARV,
         breaks=3,
         main="Histogram Digital Surface Model\n NEON Harvard Forest Field Site",
         col="lightblue",  # changes bin color
         xlab= "Elevation (m)")  # label the x-axis

![Histogram of digital surface model showing the distribution of the elevation of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/create-histogram-breaks-1.png)

    # Where are breaks and how many pixels in each category?

    DSMhist$breaks

    ## [1] 300 350 400 450

    DSMhist$counts

    ## [1] 355269 611685  33046

Looking at our histogram, R has binned out the data as follows:

* 300-350m, 350-400m, 400-450m

We can determine that most of the pixel values fall in the 350-400m range with a
few pixels falling in the lower and higher range. We could specify different
breaks, if we wished to have a different distribution of pixels in each bin.

We can use those bins to plot our raster data. We will use the 
`terrain.colors()` function to create a palette of 3 colors to use in our plot.

The `breaks` argument allows us to add breaks. To specify where the breaks
occur, we use the following syntax: `breaks=c(value1,value2,value3)`.
We can include as few or many breaks as we'd like.



    # plot using breaks.

    plot(DSM_HARV, 
         breaks = c(300, 350, 400, 450), 
         col = terrain.colors(3),
         main="Digital Surface Model (DSM) - HARV")

![Digital surface model showing the elevation of NEON's site Harvard Forest with three breaks](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/plot-with-breaks-1.png)

<div id="ds-dataTip" markdown="1">

<i class="fa fa-star"></i> **Data Tip:** Note that when we assign break values
a set of 4 values will result in 3 bins of data.

</div>

### Format Plot
If we need to create multiple plots using the same color palette, we can create
an R object (`myCol`) for the set of colors that we want to use. We can then
quickly change the palette across all plots by simply modifying the `myCol`
object. 

We can label the x- and y-axes of our plot too using `xlab` and `ylab`. 


    # Assign color to a object for repeat use/ ease of changing

    myCol = terrain.colors(3)

    

    # Add axis labels

    plot(DSM_HARV, 
         breaks = c(300, 350, 400, 450), 
         col = myCol,
         main="Digital Surface Model - HARV", 
         xlab = "UTM Easting (m)", 
         ylab = "UTM Northing (m)")

![Digital surface model showing the elevation of NEON's site Harvard Forest with UTM Westing Coordinate (m) on the x-axis and UTM Northing Coordinate (m) on the y-axis](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/add-plot-title-1.png)

Or we can also turn off the axes altogether. 


    # or we can turn off the axis altogether

    plot(DSM_HARV, 
         breaks = c(300, 350, 400, 450), 
         col = myCol,
         main="Digital Surface Model - HARV", 
         axes=FALSE)

![Digital surface model showing the elevation of NEON's site Harvard Forest with no axes](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/turn-off-axes-1.png)

<div id="ds-challenge" markdown="1">

### Challenge: Plot Using Custom Breaks

Create a plot of the Harvard Forest Digital Surface Model (DSM) that has:

* Six classified ranges of values (break points) that are evenly divided among 
the range of pixel values. 
* Axis labels
* A plot title

</div>

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/challenge-code-plotting-1.png)

## Hillshade & Layering Rasters


The `terra` package has built-in functions called `terrain` for calculating 
slope and aspect, and `shade` for computing hillshade from the slope and aspect. 
A hillshade is a raster that maps the shadows and texture that you would see 
from above when viewing terrain.

See the <a href="https://rdrr.io/cran/terra/man/shade.html" target="_blank">shade 
documentation</a> for more details.

We can layer a raster on top of a hillshade raster for the same area, and use a 
transparency factor to created a 3-dimensional shaded effect. 



    slope <- terrain(DSM_HARV, "slope", unit="radians")

    aspect <- terrain(DSM_HARV, "aspect", unit="radians")

    hill <- shade(slope, aspect, 45, 270)

    plot(hill, col=grey(0:100/100), legend=FALSE, mar=c(2,2,1,4))

    plot(DSM_HARV, col=terrain.colors(25, alpha=0.35), add=TRUE, main="HARV DSM with Hillshade")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/slope-aspect-hill-1.png)

The alpha value determines how transparent the colors will be (0 being
transparent, 1 being opaque). You can also change the color palette, for example, 
use `rainbow()` instead of `terrain.color()`.

* More information can be found in the 
<a href="https://stat.ethz.ch/R-manual/R-devel/library/grDevices/html/palettes.html" target="_blank">R color palettes documentation</a>. 

<div id="ds-challenge" markdown="1">

### Challenge: Create DTM & DSM for SJER
Download data from the NEON field site 
<a href="https://www.neonscience.org/field-sites/SJER" target="_blank" >San Joaquin Experimental Range (SJER)</a> 
and create maps of the Digital Terrain and Digital Surface Models.

Make sure to:
 
 * include hillshade in the maps,
 * label axes on the DSM map and exclude them from the DTM map, 
 * add titles for the maps,
 * experiment with various alpha values and color palettes to represent the data.
 
</div>
