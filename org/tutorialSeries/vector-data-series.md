---
layout: tutorial-series-landing
title: 'Self-Paced Tutorial Series: Introduction to Working With Vector Data in R'
categories: [tutorial-series]
tutorialSeriesName: vector-data-series
permalink: tutorial-series/vector-data-series/
image:
  feature: NEONCarpentryHeader_2.png
  credit: 
  creditlink: 
---

## About
The data tutorials in this series cover how to open, work with and plot with 
vector-format spatial data (points, lines and polygons) in `R`. Additional, 
topics include working with spatial metadata (extent and coordinate reference 
system), working with spatial attributes and plotting data by attributes. 

Data used in this series cover NEON Harvard Forest Field Site and are in 
shapefile and .csv formats.

**R Skill Level:** Intermediate - you've got the basics of `R` down but haven't
previously worked with spatial data in `R`.

<div id="objectives" markdown="1">

# Series Goals / Objectives
After completing the series you will:

* **Vector 00:**
	+ Know the difference between point, line, and polygon vector elements.
	+ Understand the differences between opening point, line and polygon shapefiles
 in R.
* **Vector 01:**
	+ Understand the components of a spatial object in R.
	+ Be able to query shapefile attributes.
	+ Be able to subset shapefiles using specific attribute values.
	+ Know how to plot a shapefile, colored by unique attribute values.
* **Vector 02:**
	+ Be able to plot multiple shapefiles using base `plot()`.
	+ Be able to apply custom symbology to spatial objects in a plot in R.
	+ Be able to customize a baseplot legend in R.
* **Vector 03:**
	+ Know how to identify the CRS of a spatial dataset.
	+ Be familiar with geographic vs. projected coordinate reference systems.
	+ Be familiar with the proj4 string format which is one format used used to 
store / reference the CRS of a spatial object.
* **Vector 04:**
	+ Be able to import .csv files containing x,y coordinate locations into R.
	+ Know how to convert a .csv to a spatial object.
	+ Understand how to project coordinate locations provided in a Geographic 
Coordinate System (Latitude, Longitude) to a projected coordinate system (UTM).
	+ Be able to plot raster and vector data in the same plot to create a map.
* **Vector 05:**
	+ Be able to crop a raster to the extent of a vector layer.
	+ Be able to extract values from raster that correspond to a vector file overlay.

## Things You’ll Need To Complete This Lesson

### Setup RStudio
To complete the tutorial series you will need an updated version of `R` and,
 preferably, RStudio installed on your computer.

 <a href = "http://cran.r-project.org/">R</a> 
is a programming language that specializes in statistical computing. It is a 
powerful tool for exploratory data analysis. To interact with `R`, we strongly
recommend 
<a href="http://www.rstudio.com/">RStudio</a>,
an interactive development environment (IDE). 

### Install R Packages
You can chose to install packages with each lesson or you can download all 
of the necessary `R` packages now. 

[More on Packages in R - Adapted from Software Carpentry.]({{site.baseurl}}R/Packages-In-R/)


### Download Data

{% include/dataSubsets/_data_Site-Layout-Files.html %}
{% include/dataSubsets/_data_Airborne-Remote-Sensing.html %}

*****

{% include/_greyBox-wd-rscript.html %}
**Working with Spatio-temporal Data in R Series:** This tutorial series is
part of a larger
[spatio-temporal tutorial series and Data Carpentry workshop.]({{ site.baseurl }}tutorial-series/neon-dc-phenology-series/)
Included series are
[introduction to spatio-temporal data and data management]({{ site.baseurl }}tutorial-series/spatial-data-management-series/),
[working with raster time-series data in R]({{ site.baseurl }}tutorial-series/raster-time-series/), 
[working with vector data in R ]({{ site.baseurl }}tutorial-series/vector-data-series/)
and
[working with tabular time series in R]({{ site.baseurl }}tutorial-series/tabular-time-series/).

</div> 

## Tutorials in the Series
