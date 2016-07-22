---
layout: tutorial-series-landing
title: 'Introduction to Hyperspectral Remote Sensing Data'
categories: [tutorial-series]
tutorialSeriesName: intro-hsi-r-series
permalink: tutorial-series/intro-hsi-r-series/
image:
  feature: laptopCode.png
  credit: 
  creditlink: 
---

## About
In this series, we cover the basics of working with NEON hyperspectral remote 
sensing data. We cover the principles of hyperspectral data, how to open 
hyperspectral data stored in HDF5 format in R and how to extract bands and 
create rasters in GeoTiff format. Finally we explore extracting a hyperspectral
 - spectral signature from a single pixel using R.

Data used in this series are from the National Ecological Observatory Network 
(NEON) and are in HDF5 format.

<div id="objectives" markdown="1">

# Series Goals / Objectives
After completing the series you will:

* Understand the collection of hyperspectral remote sensing data and how they 
can be used
* Understand how HDF5 data can be used to store spatial data and the associated
 benefits of this format when working with large spatial data cubes
* Know how to extract metadata from HDF5 files
* Know how to plot a matrix as an image and a raster
* Understand how to extract and plot spectra from an HDF5 file
* Know how to work with groups and datasets within an HDF5 file
* Know how to export a spatially projected GeoTIFF
* Create a rasterstack in `R` which can then be used to create RGB images from 
bands in a hyperspectral data cube
* Plot data spatially on a map
* Create basic vegetation indices, like NDVI, using raster-based calculations
in R

## Things You’ll Need To Complete This Series

### Setup RStudio
To complete some of the tutorials in this series, you will need an updated 
version of `R` and, preferably, RStudio installed on your computer.

 <a href = "http://cran.r-project.org/">R</a> 
is a programming language that specializes in statistical computing. It is a 
powerful tool for exploratory data analysis. To interact with `R`, we strongly
recommend 
<a href="http://www.rstudio.com/">RStudio</a>,
an interactive development environment (IDE). 

### Download Data
Data is available for download in each tutorial that it is needed in. 

*****

{% include/_greyBox-wd-rscript.html %}


</div> 

## Tutorials in Workshop Series
