---
layout: post
title: "Raster Data 101 - Graphics"
date:   2016-06-17
authors: [Leah A. Wasser]
contributors: []
dateCreated:  2016-05-01
lastModified: 2016-06-15
packagesLibraries: []
categories: [self-paced-tutorial]
mainTag: institute-day1
tags: [R, spatial-data]
description: "Graphics to support a discussion on the basics of raster data: extent, crs, resolution"
code1: 
image:
  feature:
  credit:
  creditlink:
permalink: /spatial-data/raster-graphics/
comments: false
---


## Raster Data structure - Pixels

<figure>
    <a href="http://neondataskills.org/images/dc-spatial-raster/raster_concept.png">
    <img src="http://neondataskills.org/images/dc-spatial-raster/raster_concept.png">
    </a>
    <figcaption>Raster Data Structure.</figcaption>
</figure>


## Single vs Multiple Band rasters

<figure>
    <a href="http://neondataskills.org/images/dc-spatial-raster/single_multi_raster.png">
    <img src="http://neondataskills.org/images/dc-spatial-raster/single_multi_raster.png">
    </a>
    <figcaption>A raster can have 1 or more bands.
    </figcaption>
</figure>

### Data Cubes

<figure>
    <a href="http://neondataskills.org/images/hyperspectral/DataCube.png">
    <img src="http://neondataskills.org/images/hyperspectral/DataCube.png">
    </a>
    <figcaption>A multi-band raster is sometimes
    referred to as a data cube.
    </figcaption>
</figure>


## Spatial resolution & Spatial Extent

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

<figure>
    <a href="https://source.opennews.org/media/cache/b9/4f/b94f663c79024f0048ae7b4f88060cb5.jpg">
    <img src="https://source.opennews.org/media/cache/b9/4f/b94f663c79024f0048ae7b4f88060cb5.jpg">
    </a>
    <figcaption>
    </figcaption>
</figure>


* [Intro to CRS ](http://neon-workwithdata.github.io/NEON-R-Spatio-Temporal-Data-and-Management-Intro/R/intro-to-coordinate-reference-systems)

* [Intro to UTM CRS ](http://neon-workwithdata.github.io/NEON-R-Spatio-Temporal-Data-and-Management-Intro/R/geographic-vs-projected-coordinate-reference-systems-UTM)
