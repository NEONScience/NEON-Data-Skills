---
layout: workshop
title: "NEON Working With (Lidar Derived) Rasters in R"
estimatedTime: 3.0 Hours
packagesLibraries: Raster, Sp
date:   2015-1-15 20:49:52
dateCreated:   2015-2-23 10:49:52
lastModified: 2015-5-08 13:00:52
authors: Leah A. Wasser
tags: [Data-Workshops]
mainTag: Data-Workshops
description: "This workshop will present how to work with Lidar Data derived rasters in R. Learn how to import rasters into R. Learn associated key metadata attributed needed to work with raster formats. Analyzing the data performing basic raster math  to create a canopy height model. Export raster results as a (spatially located) geotiff."
code1: 
image:
  feature: lidar_GrandMesa.png
  credit: LiDAR data collected over Grand Mesa, Colorado - National Ecological Observatory Network (NEON)
  creditlink: http://www.neoninc.org
permalink: /Data-Workshops/NEON-lidar-Rasters-R
comments: true 
---

###A NEON Data Carpentry Workshop

**Date:** 14 May 2015

This workshop will provide hands on experience with working lidar data in raster format in R. It will cover the basics of what lidar data are and commonly derived data products.

<div id="objectives">

<h3>Goals / Objectives</h3>
After completing this workshop, you will:
<ol>
<li>Know what lidar data are and how they're used in science.</li>
<li>Understand the key lidar data products - Digital Surface model, digital 
terrain model and canopy height model. </li>
<li>know how to work with, analyze and export results of lidar derived rasters 
in R.</li>
</ol>

<h3>Things to Do Before the Workshop</h3>
<h4>Download The Data</h4>

<a href="{{ site.baseurl }}/data/rasterLayers_tif.zip" class="btn btn-success">
 DOWNLOAD NEON imagery data (tiff format) California Domain D17</a>
<a href="http://www.neonhighered.org/Data/LidarActivity/CHM_InSitu_Data.zip" class="btn btn-success"> 
DOWNLOAD Sample NEON LiDAR Data in Raster Format & Vegetation Sampling data</a>
<a href="http://neonhighered.org/Data/LidarActivity/r_filtered_256000_4111000.las" class="btn btn-success"> 
Download NEON Lidar Point Cloud Data</a>

<h4>Setup RStudio</h4>
To participate in the workshop, we recommend that you come with R and RSTUDIO 
installed. <a href = "http://cran.r-project.org/">R</a> is a programming language 
that specializes in statistical computing. It is a powerful tool for exploratory
 data analysis. To interact with R, we STRONGLY recommend 
<a href="http://www.rstudio.com/">RStudio</a>, an interactive development 
environment (IDE). 


<h4>Install R Packages</h4>
You can chose to install each library individually if you already have some installed.
Or you can download the script below and run it to install all libraries at once.

<ul>
<li>raster - install.packages("raster")</li>
<li>sp (installs with the raster library) - install.packages("sp") </li>
<li>rgdal - install.packages("rgdal")</li>
<li>maptools - install.packages("maptools")</li>
<li>ggplot2 - install.packages("ggplot2")</li>
<li>rgeos - install.packages("rgeos")</li>
<li>dplyr - install.packages("dplyr")</li>

</ul>

<a href="{{ site.baseurl }}/code/R/install-for-raster-wkshp.R" class="btn btn-success"> 
Download Script to Install Packages in R</a>

<h4>Read Background Materials</h4>

<ul>
<li><a href="{{ site.baseurl }}/GIS-Spatial-Data/Working-With-Rasters/" >The basics of working with Rasters in tools like R and Python</a></li>
<li><a href="{{ site.baseurl }}/remote-sensing/1_About-LiDAR-Data-Light-Detection-and-Ranging_Activity1/" >A brief introduction to Lidar Data </a></li>
<li><a href="{{ site.baseurl }}/remote-sensing/2_LiDAR-Data-Concepts_Activity2/" >About the basic Lidar Derived Data Products - CHM, DEM, DSM </a></li>
</ul>
</div>



##SCHEDULE


| Time      | Topic         | 		   | 
|-----------|---------------|------------|
| 12:00     | [Brief Introduction to Raster Data]({{ site.baseurl }}/GIS-Spatial-Data/Working-With-Rasters/) |          |
| 12:15     | [Working with Raster Data in R]({{ site.baseurl }}/R/Raster-Data-In-R) |          |
| 1:15     | [Brief Overview of Lidar Data & Lidar derived rasters]({{ site.baseurl }}/remote-sensing/1_About-LiDAR-Data-Light-Detection-and-Ranging_Activity1/)     |            |
| 1:20     | [Explore with Lidar Point Clouds in a free online viewer: plas.io]({{ site.baseurl }}/lidar-data/online-data-viewer/ "Working With Lidar Point Clouds")          |     |
| 1:45     | [Working with Lidar Derived raster products in R]({{ site.baseurl }}/lidar-data/lidar-data-rasters-in-R/ "Working with Lidar Rasters in R")        |         |
| 2:30     | [Capstone - Create NDVI from Geotiffs in R]({{ site.baseurl }}/R/create-NDVI-in-R/ "Create NDVI in R")  |         |
| 2:50     | Wrap-up, Feedback, Questions     |         |



#Optional resources

##QGIS

 <a href ="http://www.qgis.org/en/site/forusers/index.html#download" target="_blank">QGIS</a> is a cross-platform Open Source Geographic Information system.
 
##Online LiDAR Data Viewer (las viewer)

[http://plas.io](http://plas.io) is a Open Source LiDAR data viewer developed by Martin Isenberg of Las Tools and several of his colleagues.
