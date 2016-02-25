---
layout: tutorial-series-landing
title: 'Working With Raster Time Series Data in R'
categories: [tutorial-series]
tutorialSeriesName: raster-time-series
permalink: tutorial-series/raster-time-series/
image:
  feature: NEONCarpentryHeader_2.png
  credit: 
  creditlink: 
---

## About
The tutorials in this series cover how to open, work with and plot raster time
series data in `R`. This series includes only the more-advanced, time-series
specific tutorials that are also part of the 
[Introduction to Working With Raster Data in R series]({{ site.baseurl }}tutorial-series/raster-data-series/).

Data used in this series cover NEON Harvard Forest and San Joaquin Experimental 
Range field sites and are in GeoTIFF and .csv formats.

**R Skill Level:** Intermediate - you've got the basics of `R` down but haven't
worked with spatial time-series data in `R` before.

<div id="objectives" markdown="1">

# Series Goals / Objectives
After completing the series you will:

* **Raster 05**
	+ Understand the format of a time series raster dataset.
	+ Know how to work with time series rasters. 
	+ Be able to efficiently import a set of rasters stored in a single directory.
	+ Be able to plot and explore time series raster data using the `plot()`
function in `R`.
* **Raster 06**
	+ Be able to assign custom names to bands in a RasterStack for prettier
plotting.
	+ Understand advanced plotting of rasters using the `rasterVis` package and
`levelplot`.
* **Raster 07**
	+ Be able to extract summary pixel values from a raster.
	+ Know how to save summary values to a .csv file.
	+ Be able to plot summary pixel values using `ggplot()`.
	+ Have experience comparing NDVI values between two different sites. 

## Things You’ll Need To Complete This Series

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

* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`
* **rasterVis:** `install.packages("rasterVis")`
* **ggplot2:** `install.packages("ggplot2")`

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
[working With raster data in R]({{ site.baseurl }}tutorial-series/raster-data-series/), 
[working with vector data in R ]({{ site.baseurl }}tutorial-series/vector-data-series/)
and
[working with tabular time series in R]({{ site.baseurl }}tutorial-series/tabular-time-series/).

</div> 

## Tutorials in the Series
