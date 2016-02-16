---
layout: tutorial-series-landing
title: 'Self-Paced Tutorial Series: Introduction to Working With Raster Data in R'
categories: [tutorial-series]
tutorialSeriesName: raster-data-series
permalink: tutorial-series/raster-data-series/
image:
  feature: NEONCarpentryHeader_2.png
  credit: 
  creditlink: 
---

## About
The tutorials in this series cover how to open, work with and plot with 
raster-format spatial data in `R`. Additional topics include working with 
spatial metadata (extent and coordinate reference system), reprojecting spatial
data and working with raster time series data. 

Data used in this series cover NEON Harvard Forest and San Joaquin Experimental 
Range field sites and are in GeoTIFF and .csv formats.

**R Skill Level:** Intermediate - you've got the basics of `R` down but haven't
worked with spatial data in `R` before.

<div id="objectives" markdown="1">

# Series Goals / Objectives
After completing the series you will:


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
of the necessary `R` Packages now. 


[More on Packages in R - Adapted from Software Carpentry.]({{site.baseurl}}R/Packages-In-R/)


### Download Data

{% include/dataSubsets/_data_Airborne-Remote-Sensing.html %}
{% include/dataSubsets/_data_Landsat-NDVI.html %}

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