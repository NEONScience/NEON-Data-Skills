---
layout: post
title: "Working With Rasters in R, Python, QGIS and Other Tools"
date:   2015-1-15 20:49:52
dateCreated:   2014-11-03 20:49:52
lastModified: 2015-06-09 17:11:52
authors: Leah A. Wasser
categories: [GIS-Spatial-Data]
category: remote-sensing
tags: [R, hyperspectral-remote-sensing,GIS-Spatial-Data]
mainTag: GIS-Spatial-Data
description: "Learn about the key attributes needed to work with raster data in tools like R, Python and QGIS."
code1: 
image:
  feature: lidar_GrandMesa.png
  credit: LiDAR data collected over Grand Mesa, Colorado - National Ecological Observatory Network (NEON)
  creditlink: http://www.neoninc.org
permalink: /GIS-Spatial-Data/Working-With-Rasters/
comments: true
---

<section id="table-of-contents" class="toc">
  <header>
    <h3 >Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->



<div id="objectives">

<h3>Goals / Objectives</h3>

After completing this activity, you will:
<ol>
<li>Know the key attributes required to work with raster data including: spatial 
extent, coordinate reference system and spatial resolution.</li>
<li>Understand what a spatial extent is.</li>
<li>Generally understand the basics of coordinate reference systems.</li>
</ol>

<h3>R Libraries to Install:</h3>
<ul>
<li><strong>raster:</strong> <code> install.packages("raster")</code></li>
<li><strong>rgdal:</strong> <code> install.packages("rgdal")</code></li>

</ul>
</div>

###Getting Started
This activity will overview the key attributes of a raster object, that you need to 
to work with it in tools like `R`, `Python` and `QGIS` - but with a focus
on the `R` programming language, including:

1. Spatial Resolution
2. Coordinate Reference System / Projection Information
3. Raster Extent

In order to correctly spatially refence a raster that is not already georeferenced,
you will additional need:

1. The lower left hand corner of the raster.
2. The number of columns and rows that the raster dataset contains.

This post will overview the key components of hyperspectral remote sensing data 
that are required to begin working with the data in a tool like `R` or `Python`.
 
##Spatial Resolution
A raster consists of a series of pixels, each with the same dimensions 
and shape. In the case of rasters derived from airborne sensors, each pixel 
represents an area of space on the Earth's surface. The size of the area on the 
surface that each pixel covers is known as the spatial resolution of the image. 
For instance, an image that has a 1 m spatial resolution means that each pixel in 
the image represents a 1 m x 1 m area.

<figure>
    <a href="{{ site.baseurl }}/images/hyperspectral/pixelDetail.png">
    <img src="{{ site.baseurl }}/images/hyperspectral/pixelDetail.png"></a>
    <figcaption>The spatial resolution of a raster refers the size of each cell 
    in meters. This size in turn relates to the area on the ground that the pixel 
    represents.</figcaption>
</figure>

<figure>
    <img src="{{ site.baseurl }}/images/spatialData/raster1.png">
    <figcaption>A raster at the same extent with more pixels will have a higher
    resolution (it looks more "crisp"). A raster that is stretched over the same
    extent with fewer pixels will look more blury and will be of lower resolution.
    </figcaption>
</figure>



    #load raster library
    library(raster)
    library(rgdal)
    
    # Load raster in an R object called 'DEM'
    DEM <- raster("DigitalTerrainModel/SJER2013_DTM.tif")  
    
    # View raster attributes 
    # Note that this raster (in geotiff format) already has an extent, resolution, 
    # CRS defined
    #note that the resolution in both x and y directions is 1. The CRS tells us that
    #the units of the data are meters (m)
    
    DEM

    ## class       : RasterLayer 
    ## dimensions  : 5060, 4299, 21752940  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## data source : C:\Users\lwasser\Documents\1_Workshops\05-14-2015_NEON_Raster_R\DigitalTerrainModel\SJER2013_DTM.tif 
    ## names       : SJER2013_DTM


##Spatial Extent
The spatial extent of a raster, represents the "X, Y" coordinates of the corners 
of the raster in geographic space. This information, in addition to the cell 
size or spatial resolution, tells the program how to place or render each pixel 
in 2 dimensional space.  Tools like `R`, using supporting packages such as `rgdal` 
and associated raster tools have functions that allow you to view and define the 
extent of a new raster. 


    # View the extent of the raster
    DEM@extent

    ## class       : Extent 
    ## xmin        : 254570 
    ## xmax        : 258869 
    ## ymin        : 4107302 
    ## ymax        : 4112362



<figure>
    <img src="{{ site.baseurl }}/images/spatialData/raster2.png">">
    <figcaption>If you double the extent value of a raster - the pixels will be
    stretched over the larger area making it look more "blury".
    </figcaption>
</figure>

###Calculating Raster Extent
Extent and spatial resolution are closely connected. To calculate the extent of a 
raster, we first need the bottom LEFT HAND (X,Y) coordinate of the raster. In 
the case of the UTM coordinate system which is in meters, to calculate
the raster's extent, we can add the number of columns and rows to the X,Y corner 
location of the raster, multiplied by the resolution (the pixel size) of the raster.

Let's explore that next.


    #create a raster from the matrix
    myRaster1 <- raster(nrow=4, ncol=4)
    
    #assign some random data to the raster
    myRaster1[]<- 1:ncell(myRaster1)
    
    #view attributes of the raster
    myRaster1

    ## class       : RasterLayer 
    ## dimensions  : 4, 4, 16  (nrow, ncol, ncell)
    ## resolution  : 90, 45  (x, y)
    ## extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 1, 16  (min, max)

    #is the CRS defined?
    myRaster1@crs

    ## CRS arguments:
    ##  +proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0

    #what are the data extents?
    myRaster1@extent

    ## class       : Extent 
    ## xmin        : -180 
    ## xmax        : 180 
    ## ymin        : -90 
    ## ymax        : 90

    plot(myRaster1, main="Raster with 16 pixels")

![ ]({{ site.baseurl }}/images/rfigs/2014-11-03-Working-With-Rasters-in-R-Python-GIS/create-raster-1.png) 

We can resample the raster as well to adjust the resolution. If want a higher
resolution raster, we will apply a grid with MORE pixels within the same extent.
If we want a LOWER resolution raster, we will apply a grid with LESS pixels
within the same extent.


    myRaster2 <- raster(nrow=8, ncol=8)
    myRaster2 <- resample(myRaster1, myRaster2, method='bilinear')
    myRaster2

    ## class       : RasterLayer 
    ## dimensions  : 8, 8, 64  (nrow, ncol, ncell)
    ## resolution  : 45, 22.5  (x, y)
    ## extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : -0.25, 17.25  (min, max)

    plot(myRaster2, main="Raster with 32 pixels")

![ ]({{ site.baseurl }}/images/rfigs/2014-11-03-Working-With-Rasters-in-R-Python-GIS/resample-raster-1.png) 

    myRaster3 <- raster(nrow=2, ncol=2)
    myRaster3 <- resample(myRaster1, myRaster3, method='bilinear')
    myRaster3

    ## class       : RasterLayer 
    ## dimensions  : 2, 2, 4  (nrow, ncol, ncell)
    ## resolution  : 180, 90  (x, y)
    ## extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 3.5, 13.5  (min, max)

    plot(myRaster3, main="Raster with 4 pixels")

![ ]({{ site.baseurl }}/images/rfigs/2014-11-03-Working-With-Rasters-in-R-Python-GIS/resample-raster-2.png) 

    myRaster4 <- raster(nrow=1, ncol=1)
    myRaster4 <- resample(myRaster1, myRaster4, method='bilinear')
    
    myRaster4

    ## class       : RasterLayer 
    ## dimensions  : 1, 1, 1  (nrow, ncol, ncell)
    ## resolution  : 360, 180  (x, y)
    ## extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 7.666667, 7.666667  (min, max)

    plot(myRaster4, main="Raster with 1 pixels")

![ ]({{ site.baseurl }}/images/rfigs/2014-11-03-Working-With-Rasters-in-R-Python-GIS/resample-raster-3.png) 

    #let's create a layout with 4 rasters in it
    #notice that each raster has the SAME extent but is of different resolution
    #because it has a different number of pixels spread out over the same extent.
    par(mfrow=c(2,2))
    plot(myRaster2, main="Raster with 32 pixels")
    plot(myRaster1, main="Raster with 16 pixels")
    plot(myRaster3, main="Raster with 4 pixels")
    plot(myRaster4, main="Raster with 2 pixels")

![ ]({{ site.baseurl }}/images/rfigs/2014-11-03-Working-With-Rasters-in-R-Python-GIS/resample-raster-4.png) 


<figure>
    <a href="{{ site.baseurl }}/images/hyperspectral/sat_image_corners.png">
    <img src="{{ site.baseurl }}/images/hyperspectral/sat_image_corners.png"></a>
   
    <figcaption>To be located geographically, the image's location needs to be 
    defined in geographic space (on a spatial grid). The spatial extent defines 
    the 4 corners of a raster within a given coordinate reference system.</figcaption>
</figure>
<figure>
  <a href="{{ site.baseurl }}/images/hyperspectral/sat_image_lat_lon.png">
  <img src="{{ site.baseurl }}/images/hyperspectral/sat_image_lat_lon.png"></a>
    
    <figcaption>The X and Y min and max values relate to the coordinate system 
    that the file is in (see below). </figcaption>
</figure>

##Coordinate Reference System / Projection Information

> A spatial reference system (SRS) or coordinate reference system (CRS) is a 
coordinate-based local, regional or global system used to locate geographical 
entities. -- Wikipedia

The earth is round. This is not an new concept by any means, however we need to 
remember this when we talk about coordinate reference systems associated with 
spatial data. When we make maps on paper or on a computer screen, we are moving 
from a 3 dimensional space (the globe) to 2 dimensions (our computer screens or 
a piece of paper). To keep this short, the projection of a dataset relates to 
how the data are "flattened" in geographic space so our human eyes and brains 
can make sense of the information in 2 dimensions. 

The projection refers to the mathematical calculations performed to "flatten the 
data" in into 2D space. The coordinate system references to the x and y coordinate 
space that is associated with the projection used to flatten the data. If you 
have the same dataset saved in two different projections, these two files won't 
line up correctly when rendered together.

<figure>
    <a href="https://source.opennews.org/media/cache/b9/4f/b94f663c79024f0048ae7b4f88060cb5.jpg">
    <img src="https://source.opennews.org/media/cache/b9/4f/b94f663c79024f0048ae7b4f88060cb5.jpg">
    </a>
    
    <figcaption>Maps of the United States in different projections. Notice the 
    differences in shape associated with each different projection. These 
    differences are a direct result of the calculations used to "flatten" the 
    data onto a 2 dimensional map. Source: opennews.org</figcaption>
</figure>

<a href="https://source.opennews.org/en-US/learning/choosing-right-map-projection/" target="_blank">Read more about projections.</a>

####How Map Projections Can Fool the Eye
Check out this short video highlighting how map projections can make continents 
seems proportionally larger or smaller than they actually are!

<iframe width="560" height="315" src="https://www.youtube.com/embed/KUF_Ckv8HbE" frameborder="0" allowfullscreen></iframe>

##What Makes Spatial Data Line Up On A Map?
There are lots of great resources that describe coordinate reference systems and 
projections in greater detail. However, for the purposes of this activity, what 
is important to understand is that data from the same location but saved in 
different projections **will not line up in any GIS or other program**. Thus 
it's important when working with spatial data in a program like `R` or `Python` 
to identify the coordinate reference system applied to the data, and to grab 
that information and retain it when you process / analyze the data.

For a library of CRS information: 
<a href="http://spatialreference.org/ref/epsg/" target="_blank">A great online 
library of CRS information.</a>



## CRS Strings


    library('rgdal')
    epsg = make_EPSG()
    #View(epsg)
    head(epsg)

    ##   code                                               note
    ## 1 3819                                           # HD1909
    ## 2 3821                                            # TWD67
    ## 3 3824                                            # TWD97
    ## 4 3889                                             # IGRS
    ## 5 3906                                         # MGI 1901
    ## 6 4001 # Unknown datum based upon the Airy 1830 ellipsoid
    ##                                                                                            prj4
    ## 1 +proj=longlat +ellps=bessel +towgs84=595.48,121.69,515.35,4.115,-2.9383,0.853,-3.408 +no_defs
    ## 2                                                         +proj=longlat +ellps=aust_SA +no_defs
    ## 3                                    +proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs
    ## 4                                    +proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs
    ## 5                            +proj=longlat +ellps=bessel +towgs84=682,-203,480,0,0,0,0 +no_defs
    ## 6                                                            +proj=longlat +ellps=airy +no_defs


### Define the extent

In the above example, we created a raster object in R. R defaulted to a global
lat/long extent. We can define the exact extent that we need to use too. Let's
modify the extent. 

In this example, we know that our data are in UTM zone 11N just like our DEM that
we imported above was. We also know that the left hand corner coordinate of the raster
is:  

* xmin = 254570
* ymin = 4107302

to define the extent. The resolution of this dataset is `1 meter` and we will be working
in UTM (meters).


    #create a raster from the matrix
    newMatrix  <- (matrix(1:8, nrow = 10, ncol = 20))
    
    #create a raster from the matrix
    rasterNoProj <- raster(newMatrix)
    rasterNoProj

    ## class       : RasterLayer 
    ## dimensions  : 10, 20, 200  (nrow, ncol, ncell)
    ## resolution  : 0.05, 0.1  (x, y)
    ## extent      : 0, 1, 0, 1  (xmin, xmax, ymin, ymax)
    ## coord. ref. : NA 
    ## data source : in memory
    ## names       : layer 
    ## values      : 1, 8  (min, max)

    #Define the xmin and y min (the lower left hand corner of the raster)
    xMin = 254570
    yMin = 4107302
    
    # we can grab the cols and rows for the raster using @ncols and @nrows
    rasterNoProj@ncols

    ## [1] 20

    rasterNoProj@nrows

    ## [1] 10

    # define the resolution
    res=1.0
    
    # If we add the numbers of cols and rows to the x,y corner location, we get the
    #bounds of our raster extent. 
    xMax <- xMin + (myRaster1@ncols * res)
    yMax <- yMin + (myRaster1@nrows * res)
    
    #create a raster extent class
    rasExt <- extent(xMin,xMax,yMin,yMax)
    rasExt

    ## class       : Extent 
    ## xmin        : 254570 
    ## xmax        : 254574 
    ## ymin        : 4107302 
    ## ymax        : 4107306

    #finally apply the extent to our raster
    rasterNoProj@extent <- rasExt
    rasterNoProj

    ## class       : RasterLayer 
    ## dimensions  : 10, 20, 200  (nrow, ncol, ncell)
    ## resolution  : 0.2, 0.4  (x, y)
    ## extent      : 254570, 254574, 4107302, 4107306  (xmin, xmax, ymin, ymax)
    ## coord. ref. : NA 
    ## data source : in memory
    ## names       : layer 
    ## values      : 1, 8  (min, max)

    #view extent only
    rasterNoProj@extent

    ## class       : Extent 
    ## xmin        : 254570 
    ## xmax        : 254574 
    ## ymin        : 4107302 
    ## ymax        : 4107306

    #Now we have an extent associated with our raster which places it in space!
    rasterNoProj

    ## class       : RasterLayer 
    ## dimensions  : 10, 20, 200  (nrow, ncol, ncell)
    ## resolution  : 0.2, 0.4  (x, y)
    ## extent      : 254570, 254574, 4107302, 4107306  (xmin, xmax, ymin, ymax)
    ## coord. ref. : NA 
    ## data source : in memory
    ## names       : layer 
    ## values      : 1, 8  (min, max)

    par(mfrow=c(1,1))
    plot(rasterNoProj, main="Raster in UTM coordinates, 1 m resolution")

![ ]({{ site.baseurl }}/images/rfigs/2014-11-03-Working-With-Rasters-in-R-Python-GIS/define-extent-1.png) 

###Challenges
* Resample myRaster 1 to 10 meter resolution and plot it next to the 1 m 
resolution plot. use: `par(mfrow=c(1,2))` to create side by side plots.
* What happens to the extent if you change the resolution to 1.5 when calculating 
the raster's extent properties??

## Define projection of a raster

We can define the projection of a raster that has a KNOWN CRS already. Sometimes
we download data that have projection information associated with them BUT the CRS
is not defined either in the Geotiff tags or in the raster itself. If this is the 
case, we can simply assign the raster the correct projection. 

Be CAREFUL doing this - it is not the same thing as REPROJECTING your data.


    #let's define the projection for our data using the DEM raster that already has 
    #defined CRS.
    #NOTE: in this case we have to KNOW that our raster is in this projection already!
    rasterNoProj@crs

    ## CRS arguments: NA

    #view the crs of our DEM object.
    DEM@crs

    ## CRS arguments:
    ##  +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84
    ## +towgs84=0,0,0

    #define the CRS using a CRS of another raster
    rasterNoProj@crs  <- DEM@crs
    #look at the attributes
    rasterNoProj

    ## class       : RasterLayer 
    ## dimensions  : 10, 20, 200  (nrow, ncol, ncell)
    ## resolution  : 0.2, 0.4  (x, y)
    ## extent      : 254570, 254574, 4107302, 4107306  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 1, 8  (min, max)

    #view just the crs
    rasterNoProj@crs

    ## CRS arguments:
    ##  +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84
    ## +towgs84=0,0,0

IMPORTANT: the above code does NOT REPROJECT the raster. It simply defines the
Coordinate Reference System based upon the CRS of another raster. If you want to
actually CHANGE the CRS of a raster, you need to use the `projectRaster` function.

##Reprojecting Data
If you run into multiple spatial datasets with varying projections, you can 
always **reproject** the data so that they are all in the same projection. Python 
and R both have reprojection tools that perform this task.



    # reproject raster data from UTM to CRS of Lat/Long WGS84
    
    reprojectedData1 <- projectRaster(rasterNoProj, 
                                     crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
    
    #note that the extent has been adjusted to account for the NEW crs
    reprojectedData1@crs

    ## CRS arguments:
    ##  +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0

    reprojectedData1@extent

    ## class       : Extent 
    ## xmin        : -119.761 
    ## xmax        : -119.7609 
    ## ymin        : 37.07989 
    ## ymax        : 37.07993

    #note the range of values in the output data
    reprojectedData1

    ## class       : RasterLayer 
    ## dimensions  : 12, 25, 300  (nrow, ncol, ncell)
    ## resolution  : 2.25e-06, 3.6e-06  (x, y)
    ## extent      : -119.761, -119.7609, 37.07989, 37.07993  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 0.6920572, 10.2188  (min, max)

    # use nearest neighbor interpolation  method to ensure that the values stay the same
    reprojectedData2 <- projectRaster(rasterNoProj, 
                                     crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ", 
                                     method = "ngb")
    
    #http://www.inside-r.org/packages/cran/raster/docs/projectRaster
    #note that the min and max values have now been forced to stay within the same range.
    reprojectedData2

    ## class       : RasterLayer 
    ## dimensions  : 12, 25, 300  (nrow, ncol, ncell)
    ## resolution  : 2.25e-06, 3.6e-06  (x, y)
    ## extent      : -119.761, -119.7609, 37.07989, 37.07993  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 1, 8  (min, max)

