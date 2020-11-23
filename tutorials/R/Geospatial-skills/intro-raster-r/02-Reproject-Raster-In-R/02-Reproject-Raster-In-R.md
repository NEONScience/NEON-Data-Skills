---

syncID: 31a20612d6b54b41b0f63b524b19839d
title: "Raster 02: When Rasters Don't Line Up - Reproject Raster Data in R"	
description: "This tutorial explores issues associated with working with rasters in different Coordinate Reference Systems (CRS) & projections. When two rasters are in different CRS, they will not plot nicely together on a map. We will learn how to reproject a raster in R using the projectRaster function in the raster package."	
dateCreated: 2015-10-23
authors: Leah A. Wasser, Megan A. Jones, Zack Brym, Kristina Riemer, Jason Williams, Jeff Hollister, Mike Smorul	
contributors:	Jason Brown
estimatedTime:	
packagesLibraries: raster, rgdal
topics: 
subtopics: data-analysis, raster, spatial-data-gis
languagesTool: R
dataProduct: DP3.30024.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/02-Reproject-Raster-In-R/02-Reproject-Raster-In-R.R
tutorialSeries: raster-data-series
urlTitle: dc-reproject-raster-data-r

---

Sometimes we encounter raster datasets that do not "line up" when plotted or 
analyzed. Rasters that don't line up are most often in different Coordinate
Reference Systems (CRS).

This tutorial explains how to deal with rasters in different, known CRSs. It
will walk though reprojecting rasters in R using the `projectRaster()`
function in the `raster` package.


<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this tutorial, you will be able to:

* Be able to reproject a raster in R.

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

* <a href="http://cran.r-project.org/web/packages/raster/raster.pdf" target="_blank">
Read more about the `raster` package in R.</a>

</div>

## Raster Projection in R

In the
<a href="https://www.neonscience.org/dc-plot-raster-data-r" target="_blank"> *Plot Raster Data in R* tutorial</a>,
we learned how to layer a raster file on top of a hillshade for a nice
looking basemap. In this tutorial, all of our data were in the same CRS. What 
happens when things don't line up?

We will use the `raster` and `rgdal` packages in this tutorial.  


    # load raster package
    library(raster)
    library(rgdal)
    
    # set working directory to ensure R can find the file we wish to import
    wd <- "~/Git/data/" # this will depend on your local environment
    # be sure that the downloaded file is in this directory
    setwd(wd)

Let's create a map of the Harvard Forest Digital Terrain Model 
(`DTM_HARV`) draped or layered on top of the hillshade (`DTM_hill_HARV`).


    # import DTM
    DTM_HARV <- raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif"))
    # import DTM hillshade
    DTM_hill_HARV <- 
      raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_DTMhill_WGS84.tif"))
    
    # plot hillshade using a grayscale color ramp 
    plot(DTM_hill_HARV,
        col=grey(1:100/100),
        legend=FALSE,
        main="DTM Hillshade\n NEON Harvard Forest Field Site")
    
    # overlay the DTM on top of the hillshade
    plot(DTM_HARV,
         col=terrain.colors(10),
         alpha=0.4,
         add=TRUE,
         legend=FALSE)

![Digital terrain model overlaying the hillshade raster showing the 3D ground surface of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/02-Reproject-Raster-In-R/rfigs/import-DTM-hillshade-1.png)

Our results are curious - the Digital Terrain Model (`DTM_HARV`) did not plot on
top of our hillshade. The hillshade plotted just fine on it's own. Let's try to 
plot the DTM on it's own to make sure there are data there.

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Code Tip:** For boolean R elements, such as
 `add=TRUE`, you can use `T` and `F` in place of `TRUE` and `FALSE`.
</div>


    # Plot DTM 
    plot(DTM_HARV,
         col=terrain.colors(10),
         alpha=1,
         legend=F,
         main="Digital Terrain Model\n NEON Harvard Forest Field Site")

![Digital terrain model showing the ground surface of NEON's site Harvard Forest](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/02-Reproject-Raster-In-R/rfigs/plot-DTM-1.png)

Our DTM seems to contain data and plots just fine. Let's next check the
 Coordinate Reference System (CRS) and compare it to our hillshade.


    # view crs for DTM
    crs(DTM_HARV)

    ## CRS arguments:
    ##  +proj=utm +zone=18 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0

    # view crs for hillshade
    crs(DTM_hill_HARV)

    ## CRS arguments:
    ##  +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0

Aha! `DTM_HARV` is in the UTM projection. `DTM_hill_HARV` is in
`Geographic WGS84` - which is represented by latitude and longitude values.
Because the two rasters are in different CRSs, they don't line up when plotted
in R. We need to *reproject* `DTM_hill_HARV` into the UTM CRS. Alternatively,
we could project `DTM_HARV` into WGS84. 

## Reproject Rasters
We can use the `projectRaster` function to reproject a raster into a new CRS.
Keep in mind that reprojection only works when you first have a *defined* CRS
for the raster object that you want to reproject. It cannot be used if *no*
CRS is defined. Lucky for us, the `DTM_hill_HARV` has a defined CRS. 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** When we reproject a raster, we 
move it from one "grid" to another. Thus, we are modifying the data! Keep this 
in mind as we work with raster data. 
</div>

To use the `projectRaster` function, we need to define two things:

1. the object we want to reproject and 
2. the CRS that we want to reproject it to. 

The syntax is `projectRaster(RasterObject,crs=CRSToReprojectTo)`

We want the CRS of our hillshade to match the `DTM_HARV` raster. We can thus
assign the CRS of our `DTM_HARV` to our hillshade within the `projectRaster()`
function as follows: `crs=crs(DTM_HARV)`.


    # reproject to UTM
    DTM_hill_UTMZ18N_HARV <- projectRaster(DTM_hill_HARV, 
                                           crs=crs(DTM_HARV))
    
    # compare attributes of DTM_hill_UTMZ18N to DTM_hill
    crs(DTM_hill_UTMZ18N_HARV)

    ## CRS arguments:
    ##  +proj=utm +zone=18 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0

    crs(DTM_hill_HARV)

    ## CRS arguments:
    ##  +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0

    # compare attributes of DTM_hill_UTMZ18N to DTM_hill
    extent(DTM_hill_UTMZ18N_HARV)

    ## class      : Extent 
    ## xmin       : 731397.3 
    ## xmax       : 733205.3 
    ## ymin       : 4712403 
    ## ymax       : 4713907

    extent(DTM_hill_HARV)

    ## class      : Extent 
    ## xmin       : -72.18192 
    ## xmax       : -72.16061 
    ## ymin       : 42.52941 
    ## ymax       : 42.54234

Notice in the output above that the `crs()` of `DTM_hill_UTMZ18N_HARV` is now
UTM. However, the extent values of `DTM_hillUTMZ18N_HARV` are different from
`DTM_hill_HARV`.

<div id="ds-challenge" markdown="1">
### Challenge: Extent Change with CRS Change
Why do you think the two extents differ?  
</div>




## Deal with Raster Resolution

Let's next have a look at the resolution of our reprojected hillshade.  


    # compare resolution
    res(DTM_hill_UTMZ18N_HARV)

    ## [1] 1.000 0.998

The output resolution of `DTM_hill_UTMZ18N_HARV` is 1 x 0.998. Yet, we know that
the resolution for the data should be 1m x 1m. We can tell R to force our
newly reprojected raster to be 1m x 1m resolution by adding a line of code
(`res=`).  


    # adjust the resolution 
    DTM_hill_UTMZ18N_HARV <- projectRaster(DTM_hill_HARV, 
                                      crs=crs(DTM_HARV),
                                      res=1)
    # view resolution
    res(DTM_hill_UTMZ18N_HARV)

    ## [1] 1 1

Let's plot our newly reprojected raster.


    # plot newly reprojected hillshade
    plot(DTM_hill_UTMZ18N_HARV,
        col=grey(1:100/100),
        legend=F,
        main="DTM with Hillshade\n NEON Harvard Forest Field Site")
    
    # overlay the DTM on top of the hillshade
    plot(DTM_HARV,
         col=terrain.colors(100),
         alpha=0.4,
         add=T,
         legend=F)

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/02-Reproject-Raster-In-R/rfigs/plot-projected-raster-1.png)

We have now successfully draped the Digital Terrain Model on top of our
hillshade to produce a nice looking, textured map! 

<div id="ds-challenge" markdown="1">
### Challenge: Reproject, then Plot a Digital Terrain Model 
Create a map of the 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank" >San Joaquin Experimental Range</a>
field site using the `SJER_DSMhill_WGS84.tif` and `SJER_dsmCrop.tif` files. 

Reproject the data as necessary to make things line up!
</div>

![Digital terrain model overlaying the hillshade raster showing the 3D ground surface of NEON's site San Joaquin Experimental Range](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/02-Reproject-Raster-In-R/rfigs/challenge-code-reprojection-1.png)

<div id="ds-challenge" markdown="1">
If you completed the San Joaquin plotting challenge in the
<a href="https://www.neonscience.org/dc-plot-raster-data-r" target="_blank"> *Plot Raster Data in R* tutorial</a>, 
how does the map you just created compare to that map? 
</div>


