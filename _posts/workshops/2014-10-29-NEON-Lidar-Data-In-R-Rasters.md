---
layout: workshop
title: "NEON Working With (Lidar Derived) Rasters in R"
estimatedTime: 1.5 - 2.0 Hours
packagesLibraries: Raster, Sp
date:   2015-1-15 20:49:52
dateCreated:   2015-2-23 10:49:52
lastModified: 2015-2-27 17:11:52
authors: Leah A. Wasser
tags: [Data-Workshops]
mainTag: Data-Workshops
description: "This workshop will present how to work with Lidar Data derived rasters in R. Learn how to import rasters into R. Learn associated key metadata attributed needed to work with raster formats. Analyzing the data performing basic raster math  to create a canopy height model. Export raster results as a (spatially located) geotiff."
code1: 
image:
  feature: hierarchy_folder_green.png
  credit: Colin Williams NEON, Inc.
  creditlink: http://www.neoninc.org
permalink: /Data-Workshops/NEON-lidar-Rasters-R
comments: true 
---

###A NEON Data Carpentry Workshop

**Date:** Spring 2015

This workshop will providing hands on experience with working lidar data in raster format in R. It will cover the basics of what lidar data are, and commonly derived data products.

<div id="objectives">

<h3>Goals / Objectives</h3>
After completing this workshop, you will:
<ol>
<li>Know what lidar data are and how they're used in science.</li>
<li>Understand the key lidar data products - Digital Surface model, digitcal terrain model and canopy height model. </li>
<li>know how to work with, analyze and export results of lidar derived rasters in R.</li>
</ol>

<h3>Before the Workshop Please</h3>
<p>Download All Data Here</p>

<a href="##" class="btn btn-success"> Eventual Download Data Link</a>

<p>Install Packages using this script. Package list includes:</p>
<ul>
<li>Raster</li>
<li>Sp </li>
</ul>

</div>

##Background Materials
Please read the following  materials prior to attending

* [Working with Rasters: An overview]({{ site.baseurl }}/GIS-Spatial-Data/Working-With-Rasters/ "Working with Rasters")
* [About Lidar Data]({{ site.baseurl }}/remote-sensing/1_About-LiDAR-Data-Light-Detection-and-Ranging_Activity1/ "About Lidar Data")
* [3 Raster Lidar Derived Data Products: DEM, DSM, & CHM]({{ site.baseurl }}/remote-sensing/2_LiDAR-Data-Concepts_Activity2// "Lidar Derived Data Products - CHM, DEM, DSM") 



##SCHEDULE


| Time      | Topic         | 		   | 
|-----------|---------------|------------|
| 11:00     | Brief Introduction to Raster Data |          |
| 11:10     | [Working with Rasters in R]({{ site.baseurl }}/R/Raster-Data-In-R) |          |
| 11:50     | Brief Overview of Lidar Data & Lidar derived rasters     |            |
| 12:00     | [Explore with Lidar Point Clouds in a free online viewer: plas.io]({{ site.baseurl }}/remote-sensing/2_Lidar-Point-Cloud-Online-Data-Viz-Activity/ "Working With Lidar Point Clouds")          |     |
| 12:10     | [Working with Lidar Derived raster products in R]({{ site.baseurl }}/using-lidar-data/1_lidar_derived-data-products/ "Working with Lidar Rasters in R")        |         |
| 12:50     | Wrap-up, Feedback, Questions     |         |



##Setup
To participate in the workshop, you will need working copies of the software described below. Please make sure to install everything (or at least to download the installers) before the start of the workshop.

#R

<a href = "http://cran.r-project.org/">R</a> is a programming language that specializes in statistical computing. It is a powerful tool for exploratory data analysis. To interact with R, we recommend, but do not require, <a href="http://www.rstudio.com/">RStudio</a>, an interactive development environment (IDE). 

## R Packages to Install
Please install the following packages prior to the workshop: 

* Raster - `install.packages(Raster)`
* Sp - `install.packages(Sp)`

DOWNLOAD 

1. The package installation script <a href="https://github.com/NEONdps/neonESA2014/blob/master/packageInstallation.R">here</a>, 
2. The <a href = "http://trac.osgeo.org/gdal/wiki/DownloadingGdalBinaries">gdal</a> libraries, and 


#Optional resources

##QGIS

 <a href ="http://www.qgis.org/en/site/forusers/index.html#download" target="_blank">QGIS</a> is a cross-platform Open Source Geographic Information system.
 
##Online LiDAR Data Viewer (las viewer)

[http://plas.io](http://plas.io) is a Open Source LiDAR data viewer developed by Martin Isenberg of Las Tools and several of his colleagues.
