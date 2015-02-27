---
layout: workshop
title: "NEON Working With Lidar Derived Rasters in R"
estimatedTime: 1.5 - 2.0 Hours
packagesLibraries: Raster, Sp
date:   2015-1-15 20:49:52
dateCreated:   2015-2-23 10:49:52
lastModified: 2015-2-23 22:11:52
authors: Leah A. Wasser
tags: [Data-Workshops]
mainTag: Data-Workshops
description: "This workshop will present how to work with Lidar Data derived rasters in R. Learn how to import rasters into R. Learn associated key metadata attributed needed to work with raster formats. Analyzing the data performing basic raster math  to create a canopy height model. Export raster results as a (spatially located) geotiff."
code1: 
image:
  feature: hierarchy_folder_purple.png
  credit: The Artistry of Colin Williams, NEON
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
<li>GDAL</li>
<li>RHDF5 </li>
</ul>

</div>


##SCHEDULE


| Time        | Topic         | Instructor | 
|-------------|---------------|------------|
| 2:00     | [About Lidar Data]({{ site.baseurl }}/remote-sensing/1_About-LiDAR-Data-Light-Detection-and-Ranging_Activity1/) |          |
| 2:10     | [Key Lidar Derived Data Products - About the CHM, DEM and DSM]({{ site.baseurl }}/http://neondataskills.org/remote-sensing/2_LiDAR-Data-Concepts_Activity2// "Lidar Derived Data Products - CHM, DEM, DSM")      |            |
| 2:20 | [Work with Lidar Point Clouds]({{ site.baseurl }}remote-sensing/2_Lidar-Point-Cloud-Online-Data-Viz-Activity/ "Working With Lidar Point Clouds")          |     |
| 2:40 | [Working with Lidar Derived raster products in R]({{ site.baseurl }}/using-lidar-data/1_lidar_derived-data-products/ "Working with Lidar Rasters in R")        | ??         |




##Setup
To participate in the workshop, you will need working copies of the software described below. Please make sure to install everything (or at least to download the installers) before the start of the workshop.

#HDFView

Hierarchical Data Format 5 (HDF5) is a file format used to store, package, and simultaneously organize large quantities of related data. Although we will use R to analyze data stored in this format, HDFView is free-ware that allows for quick and easy viewing and editing of these files.


#R

<a href = "http://cran.r-project.org/">R</a> is a programming language that specializes in statistical computing. It is a powerful tool for exploratory data analysis. To interact with R, we recommend, but do not require, <a href="http://www.rstudio.com/">RStudio</a>, an interactive development environment (IDE). 

## R Packages to Install
We will use several packages, including 

* <a href = "http://www.bioconductor.org/packages/release/bioc/vignettes/rhdf5/inst/doc/rhdf5.pdf">rhdf5</a> 
* <a href = "http://cran.r-project.org/web/packages/rgdal/rgdal.pdf">gdal</a>
* others?? 

DOWNLOAD 

1. The package installation script <a href="https://github.com/NEONdps/neonESA2014/blob/master/packageInstallation.R">here</a>, 
2. The <a href = "http://trac.osgeo.org/gdal/wiki/DownloadingGdalBinaries">gdal</a> libraries, and 
3. The <a href = "http://www.hdfgroup.org/HDF5/release/obtain5.html">hdf5</a> libraries. 

#Optional resources

##QGIS

 <a href ="http://www.qgis.org/en/site/forusers/index.html#download" target="_blank">QGIS</a> is a cross-platform Open Source Geographic Information system.
 
##Online LiDAR Data Viewer (las viewer)

[http://plas.io](http://plas.io) is a Open Source LiDAR data viewer developed by Martin Isenberg of Las Tools and several of his colleagues.