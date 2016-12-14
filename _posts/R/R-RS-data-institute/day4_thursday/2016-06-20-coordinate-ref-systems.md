---
layout: post
title: "Coordinate Reference Systems 101"
date:   2016-06-08
authors: [Leah A. Wasser]
instructors:
time:
contributors:
dateCreated:  2016-05-01
lastModified: 2016-06-15
packagesLibraries:
categories: [self-paced-tutorial]
mainTag: institute-day4
tags: [R]
tutorialSeries: [institute-day4]
description: "Raster 101 Review & Intro to Coordinate Reference Systems"
code1:
image:
  feature:
  credit:
  creditlink:
permalink: /R/intro-CRS/
comments: false
---

## REVIEW


## Spatial Resolution & Spatial Extent

A raster consists of a series of pixels, each with the same dimensions and shape. In the case of rasters derived from airborne sensors, each pixel represents an area of space on the Earth’s surface. The size of the area on the surface that each pixel covers is known as the spatial resolution of the image. For instance, an image that has a 1 m spatial resolution means that each pixel in the image represents a 1 m x 1 m area.

<figure>
    <a href="http://neondataskills.org/images/hyperspectral/pixelDetail.png">
    <img src="http://neondataskills.org/images/hyperspectral/pixelDetail.png">
    </a>
    <figcaption>The spatial resolution of a raster refers the size of each cell (in meters in this example). This size in turn relates to the area on the ground that the pixel represents.
    </figcaption>
</figure>



<figure>
    <a href="http://neondataskills.org/images/spatialData/raster1.png">
    <img src="http://neondataskills.org/images/spatialData/raster1.png">
    </a>
    <figcaption>A raster at the same extent with more pixels will have a higher resolution (it looks more "crisp"). A raster that is stretched over the same extent with fewer pixels will look more blury and will be of lower resolution.
    </figcaption>
</figure>


### Raster Extent

<figure>
    <a href="http://neondataskills.org/images/hyperspectral/sat_image_corners.png">
    <img src="http://neondataskills.org/images/hyperspectral/sat_image_corners.png">
    </a>
    <figcaption>To be located geographically, the image's location needs to be defined in geographic space (on a spatial grid). The spatial extent defines the 4 corners of a raster within a given coordinate reference system.
    </figcaption>
</figure>

<figure>
    <a href="http://neondataskills.org/images/hyperspectral/sat_image_lat_lon.png">
    <img src="http://neondataskills.org/images/hyperspectral/sat_image_lat_lon.png">
    </a>
    <figcaption>
    </figcaption>
</figure>

## Coordinate Reference Systems

### R Functions

    # reproject a vector object:
    spTransform(vectorObject, crs)

    # reproject a raster objects
    projectRaster(raster, crs)

    # set crs using EPSG code
    CRS("+init=epsg: 32611")

<figure>
    <a href="https://source.opennews.org/media/cache/b9/4f/b94f663c79024f0048ae7b4f88060cb5.jpg">
    <img src="https://source.opennews.org/media/cache/b9/4f/b94f663c79024f0048ae7b4f88060cb5.jpg">
    </a>
    <figcaption>
    </figcaption>
</figure>


#### Getting Started with CRS

Check out this short video highlighting how map projections can make continents
look proportionally larger or smaller than they actually are!

<iframe width="560" height="315" src="https://www.youtube.com/embed/KUF_Ckv8HbE" frameborder="0" allowfullscreen></iframe>

* For more on types of projections, visit
<a href="http://help.arcgis.com/en/arcgisdesktop/10.0/help/index.html#/Datums/003r00000008000000/" target="_blank"> ESRI's ArcGIS reference on projection types.</a>.  
* Read more about <a href="https://source.opennews.org/en-US/learning/choosing-right-map-projection/" target="_blank"> choosing a projection/datum.</a>


## What is a Coordinate Reference System

To define the location of something we often use a coordinate system. This system
consists of an X and a Y value, located within a 2 (or more) -dimensional space.

<figure>
	<a href="http://open.senecac.on.ca/clea/label/projectImages/15_276_xy-grid.jpg">
	<img src="http://open.senecac.on.ca/clea/label/projectImages/15_276_xy-grid.jpg"></a>
	<figcaption> We use coordinate systems with X, Y (and sometimes Z axes) to
	define the location of objects in space.
	Source: http://open.senecac.on.ca
	</figcaption>
</figure>

While the above coordinate system is 2-dimensional, we live on a 3-dimensional
earth that happens to be "round". To define the location of objects on the earth, which is round, we need
a coordinate system that adapts to the Earth's shape. When we make maps on paper
or on a flat computer screen, we move from a 3-Dimensional space (the globe) to
a 2-Dimensional space (our computer
screens or a piece of paper). The components of the CRS define how the
"flattening" of data that exists in a 3-D globe space. The CRS also defines the
the coordinate system itself.

<figure>
	<a href="http://ayresriverblog.com/wp-content/uploads/2011/05/image.png">
	<img src="http://ayresriverblog.com/wp-content/uploads/2011/05/image.png"></a>
	<figcaption>A CRS defines the translation between a location on the round earth
	and that same location, on a flattened, 2 dimensional coordinate system.
	Source: http://ayresriverblog.com
	</figcaption>
</figure>

> A  coordinate reference system (CRS) is a
coordinate-based local, regional or global system used to locate geographical
entities. -- Wikipedia

## The Components of a CRS

The coordinate reference system is made up of several key components:

* **Coordinate System:** the X, Y grid upon which our data is overlayed and how we define
where a point is located in space.
* **Horizontal and vertical units:** The units used to define the grid along the
x, y (and z) axis.
* **Datum:** A modeled version of the shape of the earth which defines the
origin used to place the coordinate system in space. We will explain this further,
below.
* **Projection Information:** the mathematical equation used to flatten objects
that are on a round surface (e.g. the earth) so we can view them on a flat surface
(e.g. our computer screens or a paper map).


## Why CRS is Important

It is important to understand the coordinate system that your data uses -
particularly if you are working with different data stored in different coordinate
systems. If you have data from the same location that are stored in different
coordinate reference systems, **they will not line up in any GIS or other program**
unless you have a program like ArcGIS or QGIS that supports **projection on the
fly**. Even if you work in a tool that supports projection on the fly, you will
want to all of your data in the same projection for performing analysis and processing
tasks.

<i class="fa fa-star"></i> **Data Tip:** Spatialreference.org provides an
excellent <a href="http://spatialreference.org/ref/epsg/" target="_blank">online
library of CRS information.</a>
{: .notice}

## Datums

<iframe width="560" height="315" src="https://www.youtube.com/embed/xKGlMp__jog" frameborder="0" allowfullscreen></iframe>

Another nice explanation of projections and datums.

<iframe width="560" height="315" src="https://www.youtube.com/embed/Z41Dt7_R180" frameborder="0" allowfullscreen></iframe>


## UTM Zones


<figure>
	<a href="https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Utm-zones-USA.svg/1440px-Utm-zones-USA.svg.png
">
	<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Utm-zones-USA.svg/1440px-Utm-zones-USA.svg.png
"></a>
	<figcaption>A CRS defines the translation between a location on the round earth
	and that same location, on a flattened, 2 dimensional coordinate system.
	Source: http://ayresriverblog.com
	</figcaption>
</figure>

* [Intro to CRS ](http://neon-workwithdata.github.io/NEON-R-Spatio-Temporal-Data-and-Management-Intro/R/intro-to-coordinate-reference-systems)

* [Intro to UTM CRS ](http://neon-workwithdata.github.io/NEON-R-Spatio-Temporal-Data-and-Management-Intro/R/geographic-vs-projected-coordinate-reference-systems-UTM)
