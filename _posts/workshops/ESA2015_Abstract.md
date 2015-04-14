---
layout: workshop
title: "NEON Intro to HDF5 Workshop"
date:   2015-1-15 20:49:52
dateCreated:   2014-11-03 20:49:52
lastModified: 2015-2-23 22:11:52
authors: Leah A. Wasser
tags: [Data-Workshops]
mainTag: Data-Workshops
description: "This workshop introduces the concept of Hierarchical Data Formats. Learn what an HDF5 file is. Explore HDF5 files in the free HDFviewer. Create and open HDF5 file sin R."
code1: 
image:
  feature: hierarchy_folder_purple.png
  credit: Colin Williams NEON, Inc.
  creditlink: http://www.neoninc.org
permalink: /Data-Workshops/ESA2015R
comments: true
---

###A NEON Data Carpentry Workshop

**Date:** Spring 2015

Ecologists working across scales and integrating disparate datasets face new data management and analysis challenges that demand tools beyond the spreadsheet. This workshop will overview three key data formats: ASCII, HDF5 and las and several key data types including temperature data from a tower, vegetation structure data, hyperspectral imagery and lidar data, that are often encountered when working with ‘Big Data’. It will provide an introduction to available tools in R for working with these formats and types.

In the first half of the workshop, we will learn how to (1) access and visualize large datasets in these formats using R, and (2) to use metadata to efficiently integrate datasets from multiple ecological data sources for analysis. In the second half of the workshop, we will apply the knowledge from the first half to work through a practical example of integrating field-collected vegetation structure data with remotely sensed LiDAR data. For this example, we will use data collected by the National Ecological Observatory Network (NEON), a continental-scale, NSF-funded effort to collect and freely serve terabytes of data per year (stored in a diversity of formats) over the next 30 years to enable ecological research.

Participants will leave the workshop with a basic understanding of the data that NEON and other large projects offer and some basic tools that support the use of Big Data to enhance their own research. 

This workshop will providing hands on experience with working hierarchical data formats(HDF5), and lidar data in R. It will also cover spatial data analysis in R.

<a href="http://lwasser.github.io/08-09-2015_NEON_ESA2015/about/">Read Full Abstract Here.</a>

<div id="objectives">

<h3>Goals / Objectives</h3>
After completing this workshop, you will:
<ol>
<li>Know what the Hierarchical Data Format (HDF5) is.</li>
<li>Know How to create and read from HDF5 files in R.</li>
<li>Know how to read and visualization time series data stored in an HDF5 format.</li>
</ol>

<h3>Before the Workshop Please</h3>
<p>Download All Data Here</p>

<a href="##" class="btn btn-success"> Eventual Download Data Link/a>

Install Packages using this script. Package list includes:

* GDAL
* RHDF5

</div>

####Instructors:

* Leah Wasser
* does anyone else want to actually teach? OR just assist? open to whatever!


**Assistants:**

* Natalie Robinson
* Claire Lunch, NEON Staff Scientist, Data Products
* Kate Thibault, NEON Senior Scientist, FSU

**Content Development Team:**

* Tristan Goulden, Staff Scientist AOP
* Sarah Elmendorf, Staff Scientist Data Products

##SCHEDULE


| Time        | Topic         | Instructor | 
|-------------|---------------|------------|
| 2:00     | <a href="http://neondataskills.org/HDF5/About/" target="_blank">What is HDF5?</a> | ??         |
| 2:30     | [Explore an HDF5 File (HDFviewer)](http://neondataskills.org/HDF5/Exploring-Data-HDFView/ "What is HDF5")      |            |
| 3:00 | [Create an HDF5 file in R](http://neondataskills.org/HDF5/Create-HDF5-In-R/ "What is HDF5")          | Coffee     |
| 4:00 | [Working with and visualizating time series data in HDF5 format](http://neondataskills.org/HDF5/Explore-HDF5-Using-R/ "What is HDF5")        | ??         |




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
