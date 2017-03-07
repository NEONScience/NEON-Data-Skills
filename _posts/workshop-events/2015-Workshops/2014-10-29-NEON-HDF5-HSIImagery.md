---
layout: workshop-event
title: "Working With Hyperspectral Imagery in HDF5 Format in R"
estimatedTime: 3.0 Hours
packagesLibraries: [rhdf5, dplyr]
date:   2015-06-08
dateCreated:   2015-2-23
lastModified: 2015-06-09
authors: [Leah A. Wasser]
tags: []
mainTag: Data-Workshops
categories: [workshop-event]
description: "This workshop introduces remote sensing hyperspectral imagery. We 
will review the background of the data, how to open it in R and how to perform 
basic raster calculations. We will also explore raster data in R."
code1: 
image:
  feature: hierarchy_folder_purple.png
  credit:
  creditlink: 
permalink: /workshop-event/NEON-HDF5-HyperspectralImagery-In-R
comments: true 
---

**Date:** Spring 2015

This workshop will providing hands on experience with working with hyperspectral 
imagery in hierarchical data formats(HDF5) in R. It will also cover basic raster 
data analysis in R.

<div id="objectives" markdown="1">

## Goals/Objectives
After completing this workshop, you will be able to:

* Explain what hyperspectral remote sensing data are.
* Create and read from HDF5 files containing spatial data in R.
* Describe the key attributes of raster data that you need to spatially locate 
raster data in R.


## Things to do, before the workshop:

### Data to Download
{% include/dataSubsets/_data_Imaging-Spec-Data-H5.html %}
 

### R Libraries to Install

Please have these packages *installed* and *updated* **prior** to the start of 
the workshop.

* **rhdf5:** `source("http://bioconductor.org/biocLite.R"); biocLite("rhdf5")`
* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`

#### Updating R Packages

In RStudio, you can go to `Tools --> Check for package updates` to update 
previously installed packages on your computer.

Or you can use <code>update.packages()</code> to update all packages that are 
installed in R automatically. 

* [More on Packages in R.]({{ site.baseurl }}/R/Packages-In-R/)


### Background Materials to Read

* <a href="{{ site.baseurl }}/GIS-spatial-data/Working-With-Rasters/">The Relationship Between Raster Resolution, Spatial extent & Number of Pixels - in R</a>
* <a href = "http://www.bioconductor.org/packages/release/bioc/vignettes/rhdf5/inst/doc/rhdf5.pdf">rhdf5 Package documentation</a>: optional
* <a href = "http://cran.r-project.org/web/packages/rgdal/rgdal.pdf">rgdal Package documentation</a>: optional

</div>

## An Introduction to Remote Sensing

Please watch this video on remote sensing prior to the workshop

<iframe width="560" height="315" src="https://www.youtube.com/embed/3iaFzafWJQE?rel=0" frameborder="0" allowfullscreen></iframe>

## SCHEDULE


| Time        | Topic         |
|-------------|---------------|
| 12:00  | [Raster Data in R - the skinny]({{ site.baseurl }}/R/Raster-Data-In-R/ ) |
| 12:30  | [About Hyperspectral Remote Sensing Data]({{ site.baseurl }}/HDF5/About-Hyperspectral-Remote-Sensing-Data/) |
| 1:00   | [Intro to Working with Hyperspectral Remote Sensing Data in HDF5 Format in R]({{ site.baseurl }}/HDF5/Imaging-Spectroscopy-HDF5-In-R/)  |
| 2:30   | [Create a Raster Stack from Hyperspectral Imagery in HDF5 Format in R]({{ site.baseurl }}/HDF5/Create-Raster-Stack-Spectroscopy-HDF5-In-R/)  |


***

## Setup

To participate in the workshop, you will need working copies of the software 
described below. Please make sure to install everything before the start of the 
workshop.

### HDFView

Hierarchical Data Format 5 (HDF5) is a file format used to store, package, and 
simultaneously organize large quantities of related data. Although we will use 
R to analyze data stored in this format, HDFView is free-ware that allows for 
quick and easy viewing and editing of these files.


### R

<a href = "http://cran.r-project.org/">R</a> 
is a programming language that specializes in statistical computing. It is a 
powerful tool for exploratory data analysis. To interact with R, we recommend, 
but do not require, 
<a href="http://www.rstudio.com/">RStudio</a>, 
an interactive development environment (IDE). 

#### Downloads
1. The package installation script <a href="https://github.com/NEONdps/neonESA2014/blob/master/packageInstallation.R">here</a>, 
2. The <a href = "http://trac.osgeo.org/gdal/wiki/DownloadingGdalBinaries">gdal</a> libraries, and 
3. The <a href = "http://www.hdfgroup.org/HDF5/release/obtain5.html">hdf5</a> libraries. 

### Optional resources

### QGIS

 <a href ="http://www.qgis.org/en/site/forusers/index.html#download" target="_blank">QGIS</a> 
is a cross-platform Open Source Geographic Information system.
 
### Online LiDAR Data Viewer (las viewer)

[http://plas.io](http://plas.io) is a Open Source LiDAR data viewer developed by 
Martin Isenberg of Las Tools and several of his colleagues.
