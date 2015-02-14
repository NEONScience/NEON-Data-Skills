---
layout: post
title: "Creating a Raster Stack from Hyperspectral Imagery in HDF5 Format in R"
date:   2014-11-26 20:49:52
authors: Leah A. Wasser
categories: [Coding and Informatics]
category: coding-and-informatics
tags: [hyperspectral-remote-sensing,R,GIS-Spatial-Data]
mainTag: GIS-Spatial-Data
description: "Open up and explore hyperspectral imagery in HDF format R. Combine multiple bands to create a raster stack. Use these steps to create various band combinations such as RGB, Color-Infrared and False color images."
code1: 
image:
  feature: hierarchy_folder_purple.png
  credit: The Artistry of Colin Williams, NEON
  creditlink: http://www.neoninc.org
permalink: /HDF5/Create-Raster-Stack-Spectroscopy-HDF5-In-R/
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
###Data to Download

Download the raster and *insitu* collected vegetation structure data:

<a href="http://www.neonhighered.org/Data/LidarActivity/CHM_InSitu_Data.zip" class="btn btn-success"> DOWNLOAD NEON  Sample NEON LiDAR Data</a>

<p>The LiDAR data used to create the rasters in this dataset were collected over the San Joachim field site located in California (NEON Domain 17) and processed at <a href="http://www.neoninc.org" target="_blank" >NEON </a> headquarters. The entire dataset can be access by request from the NEON website.</p>  

<h3>Pre-reqs</h3>
<p></p>
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
	plot(DEM


So we've now successfully loaded a raster into R. Next, let's 

~~ create raster stack (this means i'll have to create something RGB. it would be simpler and would make more sense. maybe i'll create 3 tiffs from the HDF file. then combine as an RGB tiff.