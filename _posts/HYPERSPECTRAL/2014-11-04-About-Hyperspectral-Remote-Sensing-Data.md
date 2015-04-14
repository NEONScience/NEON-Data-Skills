---
layout: post
title: "About Hyperspectral Remote Sensing Data"
date:   2015-1-15 20:49:52
createdDate:   2014-1-10 20:49:52
lastModified: 2015-2-9 20:49:52
estimatedTime: 0.25 - 0.5 Hours
packagesLibraries:
authors: Leah A. Wasser
categories: [remote-sensing]
category: remote-sensing
tags: [hyperspectral-remote-sensing,HDF5]
mainTag: hyperspectral-remote-sensing
description: "Learn about the fundamental principles of hyperspectral remote sensing data."
code1: 
image:
  feature: hierarchy_folder_purple.png
  credit: Colin Williams NEON, Inc.
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
> 
<h3>Goals / Objectives</h3>

After completing this activity, you will:
<ol>
<li>Understand the fundamental principles of hyperspectral remote sensing data.</li>
<li>Understand the key attributes that are required to effectively work with hyperspectral remote sensing data in tools like R or Python</li>
<li>Know what a band is.</li>
</ol>

<h3>You will need:</h3>
A working thinking cap. This is an overview / background activity.
Please consider reading the post on working with rasters prior to reading this post. 
</div>

##About Hyperspectral Remote Sensing Data

The electromagnetic spectrum is composed of thousands of bands representing different types of light energy. Imaging spectrometers (instruments that collect hyperspectral data) break the electromagnetic spectrum into groups of bands that support classification of objects by their spectral properties on the earth's surface. Hyperspectral data consists of many bands - up to hundreds of bands - that cover the electromagnetic spectrum.

The NEON imaging spectrometer (NIS) collects data within the 380nm to 2510nm portions of the electromagnetic spectrum within bands that are approximately 5nm in width. This results in a hyperspectral data cube that contains approximately 426 bands - which means BIG DATA.

#Key Metadata for Hyperspectral Data

###Bands and Wavelengths

A *band* represents a group of wavelengths. For example, the wavelength values between 800nm and 805nm might be one band as captured by an imaging spectrometer. The imaging spectrometer collects reflected light energy in a pixel for light in that band. Often when you work with a multi or hyperspectral dataset, the band information is reported as the center wavelength value. This value represents the center point value of the wavelengths represented in that  band. Thus in a band spanning 800-805 nm, the center would be 802.5).

<figure>
    <a href="{{ site.baseurl }}/images/hyperspectral/spectrumZoomed.png"><img src="{{ site.baseurl }}/images/hyperspectral/spectrumZoomed.png"></a>
    <figcaption>Imaging spectrometers collect reflected light information within defined bands or regions of the electromagnetic spectrum.</figcaption>
</figure>

##Spectral Resolution
The spectral resolution of a dataset that has more than one band, refers to the width of each band in the dataset. In the example above, a band was defined as spanning 800-805nm. The width or Spatial Resolution of the band is thus 5 nanometers. To see an example of this, check out the band widths for the <a href="http://landsat.usgs.gov/band_designations_landsat_satellites.php" target="_blank">Landsat sensors</a>.

 
##Full Width Half Max (FWHM)
The full width half max (FWHM) will also often be reported in a multi or hyperspectral dataset. This value represents the spread of the band around that center point. 

<figure>
    <a href="{{ site.baseurl }}/images/hyperspectral/FWHM2.png"><img src="{{ site.baseurl }}/images/hyperspectral/FWHM2.png"></a>
    <figcaption>The Full Width Half Max (FWHM) of a band relates to the distance in nanometers between the band center and the edge of the band. In this case, the FWHM for Band C is 2.5 nm.</figcaption>
</figure>

This means that a band that covers 800 nm-805 nm might have a FWHM of 2.5 nm. While a general spectral resolution of the sensor is often  provided, not all sensors create bands of uniform widths. For instance bands 1-9 of Landsat 8 are listed below:


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


