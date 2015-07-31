---
layout: post
title: "Rasters In R: Capstone Exercise - Create NDVI in R"
date:   2015-5-11 20:49:52
createdDate:   2015-5-11 20:49:52
lastModified:   2015-5-11 20:49:52
estimatedTime: 0.5 - 1.0 Hours
packagesLibraries: raster, maptools, rgeos
authors: Leah A. Wasser
category: remote-sensing
categories: [Remote Sensing]
tags : [lidar, R]
mainTag: lidar
description: "This capstone activity brings together skills learned about rasters in R, from tutorials on this site."
permalink: /R/create-NDVI-in-R/
comments: true
code1: 
image:
  feature: textur2_pointsProfile.png
  credit: National Ecological Observatory Network (NEON)
  creditlink: http://www.neoninc.org
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


## Background ##
This activity will utilize the skills that you learned in the previous lessons. You will 

1. Import several rasters into R
2. Perform raster math to calculate NDVI (Normalized Difference Vegetation Index) 
3. Create a color coded plot of NDVI 
4. Export the NDVI file as a georeferenced tiff.

<div id="objectives">
<h3>What you'll need</h3>
<ol>
<li>R or R studio loaded on your computer </li>
<li>rgdal, raster, sp libraries installed on you computer.</li>
</ol>

<h2>Data to Download</h2>

Download the raster and <i>insitu</i> collected vegetation structure data:

<li><a href="{{ site.baseurl }}/data/rasterLayers_tif.zip" class="btn btn-success"> DOWNLOAD NEON imagery data (tiff format) California Domain D17</a></li>

<h3>Recommended Reading</h3>
<a href="http://neondataskills.org/Data-Workshops/NEON-lidar-Rasters-R/">All of hte topics and concepts you need to complete this capstone were covered in the links on this page.</a>
</div>

> NOTE: The data used in this activity were extracted from a hyperspectral dataset collected in California by the NEON airborne observation platform. The full versions of the data used in this activity are freely available by request, [from the NEON data portal](http://www.neoninc.org/data-resources/get-data/airborne-data "AOP data").




## Generating a Raster of NDVI 

The Normalized Difference Vegetation Index is calculated using the following equation: (NIR - Red) / (NIR + Red) where:

1. NIR is the near infrared band in an image
2. Red is the red band in an image.
 
 
Use the Red (Band 58 in the tiff files) and the NIR (band 90 in the tiff files) tiff files to 

1. Calculate NDVI in R.
2. Plot NDVI. Make sure your plot has a title and a legend. Assign a colormap to the plot and specify the breaks for the colors to represent NDVI values that make sense to you. For instance, you might chose to color the data using breaks at .25,.5, .75 and 1. 
3. Expore your final NDVI dataset as a geotiff. Make sure the CRS is correct. 
4. To test your work, bring it into QGIS. Does it line up with the other tiffs (for example the band 19 tiff). Did it import properly? 



