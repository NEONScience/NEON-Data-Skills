---
layout: post
title: "About Hyperspectral Remote Sensing Data"
date:   2014-11-10 20:49:52
authors: Leah A. Wasser
categories: [remote-sensing]
category: remote-sensing
tags: [hyperspectral-remote-sensing]
mainTag: hyperspectral-remote-sensing
description: "Learn about the fundamental principles of hyperspectral remote sensing data."
code1: 
image:
  feature: hierarchy_folder_purple.png
  credit: The Artistry of Colin Williams, NEON
  creditlink: http://www.neoninc.org
permalink: /HDF5/About-Hyperspectral-Remote-Sensing-Data/
comments: true
---

<section id="table-of-contents" class="toc">
  <header>
    <h3 >Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->



<div id="objectives">
NOTE: this page is under development! We welcome any and all feedback!
<h3>Goals / Objectives</h3>

After completing this activity, you will:
<ol>
<li>Understand the fundamental principles of hyperspectral remote sensing data.</li>
<li>Understand the key attributes that are required to effectively work with hyperspectral remote sensing data in tools like R or Python</li>
<li>Know what a band is.</li>
<li>Generally understand spatial references of large raster data cubes.</li>
</ol>


<h3>You will need:</h3>
A working thinking cap - this is an overview / background activity.
</div>

###Getting Started

Raster data, and raster data cubes can be organized and stored in many different ways. To understand raster datasets we often need to explore the data first to tease out key metadata or attributes such as spatial reference information (projection), spatial resolution and spectral resolution. This page will overview the key components of hyperspectral remote sensing data that are required to begin working with the data in a tool like `R` or `Python`.

##About Hyperspectral Remote Sensing Data

The electromagnetic spectrum is composed of thousands of bands representing different types of light energy. Imaging spectrometers (instruments that collect hyperspectral data) break the electromagnetic spectrum into groups of bands that support classification of objects by their spectral properties on the earth's surface. Hyperspectral data consists of many bands - up to hundreds of bands - that cover the electromagnetic spectrum.

The NEON imaging spectrometer (NIS) collects data within the 380nm to 2510nm portions of the electromagnetic spectrum within bands that are approximately 5nm in width. This results in a hyperspectral data cube that contains approximately 426 bands - which means BIG DATA.

#Stuff to look for When Exploring Hyperspectral Data

###Bands and Wavelengths

A *band* represents a group of wavelengths. For example, the wavelength values between 800nm and 805nm might be one band as captured by an imaging spectrometer. The imaging spectrometer collects reflected light energy in a pixel for light in that band. Often when you work with a multi or hyperspectral dataset, the band information is reported as the center wavelength value. This value represents the center point value of the wavelengths represented in that  band. Thus in a band spanning 800-805 nm, the center would be 802.5).

##Spectral Resolution
The spectral resolution of a dataset that has more than one band, refers to the width of each band in the dataset. In the example above, a band was defined as spanning 800-805nm. The width or Spatial Resolution of the band is thus 5 nanometers. To see an example of this, check out the band widths for the <a href="http://landsat.usgs.gov/band_designations_landsat_satellites.php" target="_blank">Landsat sensors</a>.

 
##Full Width Half Max (FWHM)
The full width half max (FWHM) will also often be reported in a multi or hyperspectral dataset. This value represents the spread of the band around that center point. So, a band that covers 800nm-805nm might have a FWHM of 2.5 nm. While a general spectral resolution of the sensor is often  provided, not all sensors create bands of uniform widths. For instance bands 1-9 of Landsat 8 are listed below:


| Band | Wavelength range | Spatial Resolution | Spectral Width |
|-------------------------------------|------------------|--------------------|----------------|
| Band 1 - Coastal aerosol | 0.43 - 0.45 | 30 | 0.02 nm |
| Band 2 - Blue | 0.45 - 0.51 | 30 | 0.06 nm |
| Band 3 - Green | 0.53 - 0.59 | 30 | 0.06 nm |
| Band 4 - Red | 0.64 - 0.67 | 30 | 0.03 nm |
| Band 5 - Near Infrared (NIR) | 0.85 - 0.88 | 30 | 0.03 nm |
| Band 6 - SWIR 1 | 1.57 - 1.65 | 30 | 0.08 nm  |
| Band 7 - SWIR 2 | 2.11 - 2.29 | 30 | 0.18 nm |
| Band 8 - Panchromatic | 0.50 - 0.68 | 15 | 0.18 nm |
| Band 9 - Cirrus | 1.36 - 1.38 | 30 | 0.02 nm |


Above: Source - landsat.usgs.gov

##Spatial Resolution
A raster consists of a series of uniform pixels, each with the same dimension and shape. In the case of rasters derived from airborne sensors, each pixel represents an area of space on the ground. The size of the area on the ground that each pixel covers is known as the spatial resolution of the image. For instance, an image that has a 1m spatial resolution means that each pixels in the image represents a 1 m x 1 m area on the ground.


##Coordinate Reference System / Projection Information

> A spatial reference system (SRS) or coordinate reference system (CRS) is a coordinate-based local, regional or global system used to locate geographical entities. -- Wikipedia

The earth is round. This is not an new concept by any means, however we need to remember this when we talk about coordinate reference systems associated with spatial data. When we make maps on paper or on a computer screen, we are moving from a 3 dimensional space (the globe) to 2 dimensions. To keep this short, the projection of a dataset relates to how the data are "flattened" in geographic space so our human eyes and brains can make sense of the information in 2 dimensions.

The projection refers to the mathematical calculations performed to "flatten the data" in into 2D space. The coordinate system references to the x and y coordinate space, that is associated with the projection used to flatten the data. 

##Making Spatial Data Line Up
There are lots of great resources that describe Coordinate Reference systems and projection in greater detail. However, for the purposes of this activity, what is important to understand is that data, from the same location, but in different projections ** will not line up in any GIS or other program **. Thus it's important when working with spatial data in a program like R or Python to identify the coordinate reference system applied to the data, and carry that information through when you process / analyze the data.

##Reprojecting Data
If you run into multiple spatial datasets with varying projections, you can always ** reproject ** the data so that they are all in the same projection. Python and R both have reprojection tools that perform this task.


