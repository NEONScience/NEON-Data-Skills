---
layout: post
title: "Working With Rasters in R, Python, QGIS and Other Tools"
date:   2015-1-15 20:49:52
dateCreated:   2014-11-03 20:49:52
lastModified: 2015-2-9 20:49:52
authors: Leah A. Wasser
categories: [GIS]
category: remote-sensing
tags: [R, hyperspectral-remote-sensing]
mainTag: hyperspectral-remote-sensing
description: "Learn about the key attributes needed to work with raster data in tools like R, Python and QGIS."
code1: 
image:
  feature: hierarchy_folder_purple.png
  credit: The Artistry of Colin Williams, NEON
  creditlink: http://www.neoninc.org
permalink: /HDF5/Working-With-Rasters/
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
NOTE: this page is under development! We welcome any and all feedback!
> 
<h3>Goals / Objectives</h3>

After completing this activity, you will:
<ol>
<li>Know the key attributes required to work with raster data including: spatial extent, coordinate reference system and spatial resolution.</li>
<li>Understand what a spatial extent it.</li>
<li>Generally understand spatial references of large raster data cubes.</li>
</ol>

<h3>You will need:</h3>
A working thinking cap. This is an overview / background activity.
</div>

###Getting Started
This activity with overview the key attributes that you need to extract for a raster dataset's metadata in tools like R, Python and QGIS. Raster data, and raster data cubes can be organized and stored in many different ways. To understand raster datasets we often need to explore the data first to tease out key metadata or attributes including:

1. Spatial Resolution
2. Coordinate Reference System / Projection Information
3. Raster Extent

This post will overview the key components of hyperspectral remote sensing data that are required to begin working with the data in a tool like `R` or `Python`.
 
##Spatial Resolution
A raster consists of a series of uniform pixels, each with the same dimension and shape. In the case of rasters derived from airborne sensors, each pixel represents an area of space on the ground. The size of the area on the ground that each pixel covers is known as the spatial resolution of the image. For instance, an image that has a 1m spatial resolution means that each pixel in the image represents a 1 m x 1 m area on the ground.

<figure>
    <a href="{{ site.baseurl }}/images/hyperspectral/pixelDetail.png"><img src="{{ site.baseurl }}/images/hyperspectral/pixelDetail.png"></a>
    <figcaption>The spatial resolution of a raster refers the size of each cell in meters. This size in turn relates to the area on the ground that the pixel represents.</figcaption>
</figure>




##Spatial Extent
The spatial extent of a raster, represents the "X, Y" coordinates of the corners of the raster in geographic space. This information, in addition to the cell size or spatial resolution, tells the program how to place or render each pixel in 2 dimensional space.  Tools like `R`, using supporting packages such as `GDAL` and associated raster tools often have comments that allow you to define the extent of a raster that is created within the tool. 

	#set raster extent (R Code)
	#xMN = minimum x value, xMX=maximum x value, yMN - minimum Y value, yMX=maximum Y value
    	rasExt <- extent(xMN,xMX,yMN,yMX)

<figure>
    <a href="{{ site.baseurl }}/images/hyperspectral/sat_image_corners.png"><img src="{{ site.baseurl }}/images/hyperspectral/sat_image_corners.png"></a>
   
    <figcaption>To be located geographically, the images location needs to be defined in geographic space (on a spatial grid). The spatial extent defines the 4 corners of a raster, within a given coordinate reference system.</figcaption>
</figure>
<figure>
	<a href="{{ site.baseurl }}/images/hyperspectral/sat_image_lat_lon.png"><img src="{{ site.baseurl }}/images/hyperspectral/sat_image_lat_lon.png"></a>
    
    <figcaption>The X and Y mins and max values relate to the coordinate system that the file is in (see below). </figcaption>
</figure>

##Coordinate Reference System / Projection Information

> A spatial reference system (SRS) or coordinate reference system (CRS) is a coordinate-based local, regional or global system used to locate geographical entities. -- Wikipedia

The earth is round. This is not an new concept by any means, however we need to remember this when we talk about coordinate reference systems associated with spatial data. When we make maps on paper or on a computer screen, we are moving from a 3 dimensional space (the globe) to 2 dimensions (our computer screens or a piece of paper). To keep this short, the projection of a dataset relates to how the data are "flattened" in geographic space so our human eyes and brains can make sense of the information in 2 dimensions. 

The projection refers to the mathematical calculations performed to "flatten the data" in into 2D space. The coordinate system references to the x and y coordinate space, that is associated with the projection used to flatten the data. If you have the same dataset, saved in two different projections, it won't line up.

<figure>
    <a href="https://source.opennews.org/media/cache/b9/4f/b94f663c79024f0048ae7b4f88060cb5.jpg"><img src="https://source.opennews.org/media/cache/b9/4f/b94f663c79024f0048ae7b4f88060cb5.jpg"></a>
    
    <figcaption>Maps of the United States in different projections. Notice the differences in shape associated with each different projection. These differences are a direct result of the calculations used to "flatten" the data onto a 2 dimensional map. Source: opennews.org</figcaption>
</figure>

<a href="https://source.opennews.org/en-US/learning/choosing-right-map-projection/" target="_blank">Read more about projections.</a>

##What Makes Spatial Data Line Up On A Map?
There are lots of great resources that describe Coordinate Reference systems and projections in greater detail. However, for the purposes of this activity, what is important to understand is that data, from the same location, but saved in different projections **will not line up in any GIS or other program**. Thus it's important when working with spatial data in a program like `R` or `Python` to identify the coordinate reference system applied to the data, and to grab that information and retain it when you process / analyze the data.

##Reprojecting Data
If you run into multiple spatial datasets with varying projections, you can always **reproject** the data so that they are all in the same projection. Python and R both have reprojection tools that perform this task.

	# reproject data to CRS of dataset2 in R
	reprojectedData <- spTransform(dataset,CRS(proj4string(dataset2))) 


