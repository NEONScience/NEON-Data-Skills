---
layout: workshop
title: "ESA 2015: A Hands-On Primer for Working with Big Data in R: Introduction to Hierarchical Data Formats, Lidar Data & Efficient Data Visualization"
estimatedTime: 8.0 Hours
packagesLibraries: RHDF5, raster
language: [R]
date: 2015-08-09 10:49:52
dateCreated:   2015-6-29 10:49:52
lastModified: 2015-6-29 22:11:52
authors: Leah Wasser, Natalie Robinson, Claire Lunch, Kate Thibault, Sarah Elmendorf
tags: [Data-Workshops]
mainTag: Data-Workshops
description: "This workshop will providing hands on experience with working hierarchical data formats (HDF5), and lidar data in R. It will also cover spatial data analysis in R."
code1: 
image:
  feature: hierarchy_folder_green.png
  credit: Colin Williams NEON, Inc.
  creditlink: http://www.neoninc.org
permalink: /Data-Workshops/ESA15-Big-Data-In-R
comments: true 
---

###A NEON #WorkWithData Event

**Date:** 09 August 2015

Ecologists working across scales and integrating disparate datasets face new data management and analysis challenges that demand tools beyond the spreadsheet. This workshop will overview three key data formats: ASCII, HDF5 and las and several key data types including temperature data from a tower, vegetation structure data, hyperspectral imagery and lidar data, that are often encountered when working with ‘Big Data’.  It will provide an introduction to available tools in R for working with these formats and types.

<div id="objectives">

<h2>Background Materials</h2>

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
<li>raster - <code>install.packages("raster")</code></li>
<li>sp (installs with the raster library) - <code>install.packages("sp") </code></li>
<li>rgdal - <code>install.packages("rgdal")</code></li>
<li>maptools - <code>install.packages("maptools")</code></li>
<li>ggplot2 - <code>install.packages("ggplot2")</code></li>
<li>rgeos - <code>install.packages("rgeos")</code></li>
<li>dplyr - <code>install.packages("dplyr")</code></li>
<li>rhdf5 - <code>source("http://bioconductor.org/biocLite.R") ; biocLite("rhdf5")</code></li>
</ul>

<h2>Download the Free H5 Viewer</h2>

<p>The free H5 viewer will allow you to explore H5 data, using a graphic interface. 
</p>

<ul>
<li>
<a href="http://www.hdfgroup.org/products/java/release/download.html" target="_blank" class="btn btn-success"> HDF5 viewer can be downloaded from this page.</a>
</li>
</ul>

<a href="http://neondataskills.org/HDF5/Exploring-Data-HDFView/">More on the
 viewer here</a>

<h3>Please review the following:</h3>
<ul>
<li><a href="http://neondataskills.org/HDF5/About/">What is HDF5? A general overview.</a></li>
</ul>

</div>

##Setting Up Your Working Directory


##TENTATIVE SCHEDULE

* Please note that we are still developing the agenda for this workshop. The schedule below is subject to change.


| Time        | Topic         | Instructor | 
|-------------|---------------|------------|
| 8:00     | Welcome / Introductions / Logistics |          |
| 9:00     | [Getting Started with Rasters in R]({{ site.baseurl }}/R/Raster-Data-In-R/) |          |
| 9:30     | [Raster Resolution, Extent & CRS in R]({{ site.baseurl }}/GIS-Spatial-Data/Working-With-Rasters/)       |            |
| 10:15 | ------- BREAK ------- |      |
| 10:30 | [LiDAR Data Derived Rasters in R]({{ site.baseurl }}/lidar-data/lidar-data-rasters-in-R/) |      |
| 12:00 - 1:00 PM     | Lunch on Your Own |          |
| 1:15     | [Introduction to HDF5 in R]( {{ site.baseurl }}/HDF5/Intro-To-HDF5-In-R/) |          |
| 2:30 | ------- BREAK ------- |      |
| 2:45     | [Hyperspectral Imagery in R]({{ site.baseurl }})/HDF5/Imaging-Spectroscopy-HDF5-In-R/  |          |
| Done Early?     | [Create Raster Stacks & NDVI in R]({{ site.baseurl }})/HDF5/Create-Raster-Stack-Spectroscopy-HDF5-In-R/  |          |
| 3:45 | ------- BREAK ------- |      |
| 4:00     | Hands On Activity?? |          |

