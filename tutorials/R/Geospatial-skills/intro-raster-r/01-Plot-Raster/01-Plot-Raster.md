---
syncID: cdeed1d7546a4a179c0cd83b17a4938c
title: "Raster 01: Plot Raster Data in R"	
description: "This tutorial explains how to plot a raster in R using R's base plot function. It also covers how to layer a raster on top of a hillshade to produce  an eloquent map."	
dateCreated: 2015-10-2
authors: Leah A. Wasser, Megan A. Jones, Zack Brym, Kristina Riemer, Jason Williams, Jeff Hollister,  Mike Smorul	
contributors:	Jason Brown
estimatedTime:	
packagesLibraries: raster, rgdal
topics: data-viz, raster, spatial-data-gis
languagesTool: R
dataProduct: DP3.30024.001
code1: /R/dc-spatial-raster/01-Plot-Raster.R	
tutorialSeries: raster-data-series
urlTitle: dc-plot-raster-data-r
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

* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`

* <a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

#### Download Data

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

* <a href="http://cran.r-project.org/web/packages/raster/raster.pdf" target="_blank"> Read more about the `raster` package in R.</a>

</div>

## Plot Raster Data in R
In this tutorial, we will plot the Digital Surface Model (DSM) raster 
for the NEON Harvard Forest Field Site. We will use the `hist()` function as a 
tool to explore raster values. And render categorical plots, using the `breaks` argument to get bins that are meaningful representations of our data. 

We will use the `raster` and `rgdal` packages in this tutorial. If you do not
have the `DSM_HARV` object from the 
<a href="https://www.neonscience.org/dc-raster-data-r" target="_blank"> *Intro To Raster In R* tutorial</a>, 
please create it now.  


    # if they are not already loaded
    library(rgdal)

    ## Loading required package: sp

    ## rgdal: version: 1.4-8, (SVN revision 845)
    ##  Geospatial Data Abstraction Library extensions to R successfully loaded
    ##  Loaded GDAL runtime: GDAL 2.2.3, released 2017/11/20
    ##  Path to GDAL shared files: C:/Users/jbrown1/Documents/R/win-library/3.6/rgdal/gdal
    ##  GDAL binary built with GEOS: TRUE 
    ##  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
    ##  Path to PROJ.4 shared files: C:/Users/jbrown1/Documents/R/win-library/3.6/rgdal/proj
    ##  Linking to sp version: 1.4-1

    library(raster)
    
    # set working directory to ensure R can find the file we wish to import
    wd <- "C:/Users/jbrown1/Documents/R Projects/data/" # this will depend on your local environment
    # be sure that the downloaded file is in this directory
    setwd(wd)
    
    # import raster
    DSM_HARV <- raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif"))

First, let's plot our Digital Surface Model object (`DSM_HARV`) using the
`plot()` function. We add a title using the argument `main="title"`.


    # Plot raster object
    plot(DSM_HARV,
         main="Digital Surface Model\nNEON Harvard Forest Field Site")

![Digital surface model showing the continuous elevation of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/hist-raster-1.png)

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
         col="wheat3",  # changes bin color
         xlab= "Elevation (m)")  # label the x-axis

    ## Warning in .hist1(x, maxpixels = maxpixels, main = main, plot = plot, ...): 4% of the raster
    ## cells were used. 100000 values used.

![Histogram of digital surface model showing the distribution of the elevation of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/create-histogram-breaks-1.png)

    # Where are breaks and how many pixels in each category?
    DSMhist$breaks

    ## [1] 300 350 400 450

    DSMhist$counts

    ## [1] 32067 67485   448

Warning message!? Remember, the default for the histogram is to include only a
subset of 100,000 values. We could force it to show all the pixel values or we
can use the histogram as is and figure that the sample of 100,000 values
represents our data well. 

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
         main="Digital Surface Model (DSM)\n NEON Harvard Forest Field Site")

![Digital surface model showing the elevation of NEON's site Harvard Forest with three breaks](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/plot-with-breaks-1.png)

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
         main="Digital Surface Model\nNEON Harvard Forest Field Site", 
         xlab = "UTM Westing Coordinate (m)", 
         ylab = "UTM Northing Coordinate (m)")

![Digital surface model showing the elevation of NEON's site Harvard Forest with UTM Westing Coordinate (m) on the x-axis and UTM Northing Coordinate (m) on the y-axis](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/add-plot-title-1.png)

Or we can also turn off the axes altogether. 


    # or we can turn off the axis altogether
    plot(DSM_HARV, 
         breaks = c(300, 350, 400, 450), 
         col = myCol,
         main="Digital Surface Model\n NEON Harvard Forest Field Site", 
         axes=FALSE)

![Digital surface model showing the elevation of NEON's site Harvard Forest with no axes](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/turn-off-axes-1.png)

<div id="ds-challenge" markdown="1">
### Challenge: Plot Using Custom Breaks

Create a plot of the Harvard Forest Digital Surface Model (DSM) that has:

* Six classified ranges of values (break points) that are evenly divided among 
the range of pixel values. 
* Axis labels
* A plot title

</div>

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/challenge-code-plotting-1.png)

## Layering Rasters
We can layer a raster on top of a hillshade raster for the same area, and use a 
transparency factor to created a 3-dimensional shaded effect. A
hillshade is a raster that maps the shadows and texture that you would see from
above when viewing terrain.


    # import DSM hillshade
    DSM_hill_HARV <- 
      raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif"))
    
    # plot hillshade using a grayscale color ramp that looks like shadows.
    plot(DSM_hill_HARV,
        col=grey(1:100/100),  # create a color ramp of grey colors
        legend=FALSE,
        main="Hillshade - DSM\n NEON Harvard Forest Field Site",
        axes=FALSE)

![Hillshade digital surface model showing the elevation of NEON's site Harvard Forest in grayscale](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/hillshade-1.png)

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** Turn off, or hide, the legend on 
a plot using `legend=FALSE`.
</div>

We can layer another raster on top of our hillshade using by using `add=TRUE`.
Let's overlay `DSM_HARV` on top of the `hill_HARV`.


    # plot hillshade using a grayscale color ramp that looks like shadows.
    plot(DSM_hill_HARV,
        col=grey(1:100/100),  #create a color ramp of grey colors
        legend=F,
        main="DSM with Hillshade \n NEON Harvard Forest Field Site",
        axes=FALSE)
    
    # add the DSM on top of the hillshade
    plot(DSM_HARV,
         col=rainbow(100),
         alpha=0.4,
         add=T,
         legend=F)

![Digital surface model overlaying the hillshade raster showing the 3D elevation of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/overlay-hillshade-1.png)

The alpha value determines how transparent the colors will be (0 being
transparent, 1 being opaque). Note that here we used the color palette
`rainbow()` instead of `terrain.color()`.

* More information in the 
<a href="https://stat.ethz.ch/R-manual/R-devel/library/grDevices/html/palettes.html" target="_blank">R color palettes documentation</a>. 

<div id="ds-challenge" markdown="1">
### Challenge: Create DTM & DSM for SJER
Use the files in the `NEON_RemoteSensing/SJER/` directory to create a Digital
Terrain Model map and Digital Surface Model map of the San Joaquin Experimental
Range field site.

Make sure to:
 
 * include hillshade in the maps,
 * label axes on the DSM map and exclude them from the DTM map, 
 * a title for the maps,
 * experiment with various alpha values and color palettes to represent the
 data.
 
</div>


![Digital surface model overlaying the hillshade raster showing the 3D elevation of NEON's site San Joaquin Experiment Range](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/challenge-hillshade-layering-1.png)![Digital terrain model overlaying the hillshade raster showing the 3D ground surface of NEON's site San Joaquin Experiment Range](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Geospatial-skills/intro-raster-r/01-Plot-Raster/rfigs/challenge-hillshade-layering-2.png)

