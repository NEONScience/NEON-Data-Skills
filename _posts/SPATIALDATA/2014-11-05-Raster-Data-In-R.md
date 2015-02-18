---
layout: post
title: "Raster Data in R - The Basics"
date:   2015-1-26 20:49:52
authors: Leah A. Wasser
dateCreated:  2014-11-26 20:49:52
lastModified: 2015-02-18 12:30:52
categories: [Coding and Informatics]
category: coding-and-informatics
tags: [hyperspectral-remote-sensing,R,GIS-Spatial-Data]
mainTag: GIS-Spatial-Data
description: "This post explains the fundamental principles, functions and metadata that you need to work with raster data in R."
code1: 
image:
  feature: hierarchy_folder_purple.png
  credit: The Artistry of Colin Williams, NEON
  creditlink: http://www.neoninc.org
permalink: /R/Raster-Data-In-R/
code1: r_RasterFundamentals.R
comments: true
---

<section id="table-of-contents" class="toc">
  <header>
    <h3>Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->

<div id="objectives">
<h3>About</h3>
</p>This activity will walk you through the fundamental principles of working with raster data in R.</p>
<strong>R Skill Level:</strong> Intermediate

<h3>Goals / Objectives</h3>
This activity is under development
After completing this activity, you will know:
<ol>
<li>what a raster dataset is and it's fundamental attributes.</li>
<li>How to work with the raster package to import rasters into R</li>
<li>How to perform basic calculations using rasters in R.</li>
</ol>

<h3>What you'll Need</h3>
<ul>
<li>R or R studio to write your code.</li>
<li>GDAL libraries installed on you computer. <a href="https://www.youtube.com/watch?v=ZqfiZ_J_pQQ&list=PLLWiknuNGd50NbvZhydbTqJJh5ZRkjuak" target="_blank">Click here for videos on installing GDAL on a MAC and a PC.</a></li>
</ul>


<h3>Data to Download</h3>

Download the raster and *insitu* collected vegetation structure data:
<b>Part 1 data</b>
<a href="http://www.neonhighered.org/Data/LidarActivity/CHM_InSitu_Data.zip" class="btn btn-success"> DOWNLOAD NEON  Sample NEON LiDAR Data</a>
<b>Part 2 data</b>
<a href="http://www.neondataskills.org/data/rasterLayers_tif.zip" class="btn btn-success"> DOWNLOAD NEON imagery data (tiff format) California Domain D17</a>

<p>The LiDAR and imagery data used to create the rasters in this dataset were collected over the San Joachim field site located in California (NEON Domain 17) and processed at <a href="http://www.neoninc.org" target="_blank" >NEON </a> headquarters. The entire dataset can be access by request from the NEON website.</p>  

<h3>Pre-reqs</h3>
<ul>
<li>
<a href="http://neondataskills.org/HDF5/Working-With-Rasters/">Please consider reading the background page on rasters, by clicking here.</a>
</li>
<li>
<a href="http://cran.r-project.org/web/packages/raster/raster.pdf" target="_blank">Read more about the Raster Package in R.</a>
</li>
</ul>
</div>

#About Raster Data
Raster or "gridded" data are data that are saved in pixels. In the spatial world, each pixel represents an area "land" on the ground. For example in the raster below, each pixel represents a particular land cover class that would be found in that location in the real world. <a href="http://neondataskills.org/HDF5/Working-With-Rasters/">More on rasters here</a>. 

<figure>
   <figcaption>Raster showing land cover??</figcaption>
</figure>

To work with rasters in R, you will want two key packages, `GDAL` and `Raster`. Let's start by loading these into r. To install the raster package you can use `install.packages(‘raster’)`.

	#load the raster and sp packages
	library(raster)
	library(sp)
	#Set your working directory 
	setwd("~/yourWorkingDirectoryHere")  
	

Next, let's load the raster into R. Notice that we're using some clever code that tells R to paste the working directory into the path, and then it tells it to add the location of the raster layer.

	#load raster in an R objected called 'DEM'
	DEM <- raster(paste(getwd(), "/path here/SJER2013_DTM.tif", sep = ""))  # Tmin for January
	#next, let's look at the attributes of the raster. 
	DEM
	
OUTPUT:

	class       : RasterLayer 
	dimensions  : 5060, 4299, 21752940  (nrow, ncol, ncell)
	resolution  : 1, 1  (x, y)
	extent      : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
	coord. ref. : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
	data source : /Users/law/Documents/data/CHM_InSitu_Data/DigitalTerrainModel/SJER2013_DTMHill.tif 
	names       : SJER2013_DTMHill 
	values      : 0, 253  (min, max)
		
Notice a few things about this raster. 

* **Nrow, Ncol** is the number of rows and columns data. 
* **Ncells** is the total number of pixels that make up the raster.
*  **Resolution** is the size of each pixel (in meters in this case)
*  **Extent** this is the spatial extent of the raster. this value will be coordinate units associated with the coordinate reference system of the raster.
*  **Coord ref** this is the coordinate reference system string for the raster. This raster is in UTM (Universal Trans mercator) zone 11 with a datum of WGS 84. <a href="http://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system" target="_blank">More in UTM here</a>.

##About UTM

<figure>
   <a href="http://upload.wikimedia.org/wikipedia/en/thumb/5/57/Utm-zones.svg/720px-Utm-zones.svg.png
"><img src="http://upload.wikimedia.org/wikipedia/en/thumb/5/57/Utm-zones.svg/720px-Utm-zones.svg.png
"></a>
 <figcaption>The UTM coordinate reference system breaks the world into 60 latitude zones.</figcaption>
</figure>

##Working with Rasters in R
Now that we have the raster loaded into R, let's grab some key metadata.

	DEM@crs
	DEM@extent
	#plot the raster
	plot(DEM)

## Part 2 - Working with multiple rasters within Raster Stacks and Raster Bricks
We've now loaded a raster into R. We've also made sure we knew the CRS (coordinate reference system) and extent of the dataset among other key metadata attributes. Next, let's create a raster stack from 3 raster images.

A raster stack is a collection of raster layers. Each raster layer in the stack needs to be in the same projection (CRS), spatial extent and resolution. You might use raster stacks for different reasons. For instance, you might want to group a time series of rasters representing precipitation or temperature into one R object. In part 2, we will stack 3 bands from a multi-band image together to create a final RGB image.


 

~~ create raster stack (this means i'll have to create something RGB. it would be simpler and would make more sense. maybe i'll create 3 tiffs from the HDF file. then combine as an RGB tiff.