---
layout: workshop-event
title: "Work With Lidar Derived Rasters in R"
estimatedTime: 3.0 Hours
date:   2015-05-14
dateCreated:   2015-2-23
lastModified: 2015-5-08
startDate: 2015-05-14
endDate:  2015-05-14
authors: [Leah A. Wasser]
tags: []
mainTag: Data-Workshops
categories: [workshop-event]
packagesLibraries: [raster, sp]
description: "This workshop will present how to work with Lidar Data derived 
rasters in R. Learn how to import rasters into R. Learn associated key metadata 
attributed needed to work with raster formats. Analyzing the data performing basic 
raster math  to create a canopy height model. Export raster results as a (
spatially located) geotiff."

image:
  feature: lidar_GrandMesa.png
  credit: LiDAR data collected over Grand Mesa, Colorado - National Ecological Observatory Network (NEON)
  creditlink:
permalink: Data-Workshops/NEON-lidar-Rasters-R
comments: true 
---


This workshop will provide hands on experience with working lidar data in raster 
format in R. It will cover the basics of what lidar data are and commonly 
derived data products.

<div id="objectives" markdown="1">

## Goals / Objectives
After completing this workshop, you will be able to:

* Explain what lidar data are and how they're used in science.
* Describe the key lidar data products - digital surface model, digital 
terrain model and canopy height model. 
* Work with, analyze and export results of lidar derived rasters in R.


## Things to Do Before the Workshop

### Download The Data 

{% include/dataSubsets/_data_Field-Site-Spatial-Data.html %}

{% include/dataSubsets/_data_Sample-LiDAR-Point-Cloud.html %}

### Setup R & RStudio
To participate in the workshop, we recommend that you come with R and RStudio 
installed. 
<a href = "http://cran.r-project.org/">R</a> is a programming language 
that specializes in statistical computing. It is a powerful tool for exploratory
 data analysis. To interact with R, we STRONGLY recommend 
<a href="http://www.rstudio.com/">RStudio</a>, an interactive development 
environment (IDE). 


## Install R Packages
You can chose to install each library individually if you already have some installed.
Or you can download the script below and run it to install all libraries at once.

* **raster:**  `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`
* **maptools:** `install.packages("maptools")`
* **ggplot2:** `install.packages("ggplot2")`
* **rgeos:** `install.packages("rgeos")`
* **dplyr:**`install.packages("dplyr")`


<a href="{{ site.baseurl }}/code/R/install-for-raster-wkshp.R" class="btn btn-success"> 
Download Script to Install Packages in R</a>

## Read Background Materials

* <a href="{{ site.baseurl }}/GIS-spatial-data/Working-With-Rasters/" >The basics of working with Rasters in tools like R and Python</a></li>
* <a href="{{ site.baseurl }}/remote-sensing/1_About-LiDAR-Data-Light-Detection-and-Ranging_Activity1/" >A brief introduction to Lidar Data </a></li>
* <a href="{{ site.baseurl }}/remote-sensing/2_LiDAR-Data-Concepts_Activity2/" >About the basic Lidar Derived Data Products - CHM, DEM, DSM </a></li>

</div>

## Workshop Instructors
* **Natalie Robinson**
* **Leah A. Wasser**


## SCHEDULE


| Time      | Topic         | 		   | 
|-----------|---------------|------------|
| 12:00    | [Working with Raster Data in R]({{ site.baseurl }}/R/Raster-Data-In-R) |          |
| 12:45    | [Working With Image Formatted Rasters in R]({{ site.baseurl }}/R/Image-Raster-Data-In-R/)     |            |
| 1:15     | [Brief Overview of Lidar Data & Lidar derived rasters]({{ site.baseurl }}/remote-sensing/1_About-LiDAR-Data-Light-Detection-and-Ranging_Activity1/)     |            |
| 1:20     | [Explore with Lidar Point Clouds in a free online viewer: plas.io]({{ site.baseurl }}/lidar-data/online-data-viewer/ "Working With Lidar Point Clouds")          |     |
| 1:45     | [Working with Lidar Derived raster products in R]({{ site.baseurl }}/lidar-data/lidar-data-rasters-in-R/ "Working with Lidar Rasters in R")        |         |
| 2:30     | [Capstone - Create NDVI from Geotiffs in R]({{ site.baseurl }}/R/create-NDVI-in-R/ "Create NDVI in R")  |         |
| 2:50     | Wrap-up, Feedback, Questions     |         |



## Optional resources

### QGIS

 <a href ="http://www.qgis.org/en/site/forusers/index.html#download" target="_blank">QGIS</a> is a cross-platform Open Source Geographic Information system.
 
### Online LiDAR Data Viewer (las viewer)

[http://plas.io](http://plas.io) is a Open Source LiDAR data viewer developed by Martin Isenberg of Las Tools and several of his colleagues.

### Additional Color Palettes

* [`grDevices` documentation](https://stat.ethz.ch/R-manual/R-devel/library/grDevices/html/palettes.html)
* [R-bloggers column on color](http://www.r-bloggers.com/color-palettes-in-r/)
* [The R colorbrewer library is pretty great too](http://cran.r-project.org/web/packages/RColorBrewer/RColorBrewer.pdf)
