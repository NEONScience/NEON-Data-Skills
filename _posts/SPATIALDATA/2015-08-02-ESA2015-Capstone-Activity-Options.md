---
layout: post
title: "ESA 2015 Capstone Activity"
date:   2015-5-11 20:49:52
createdDate:   2015-08-01 20:49:52
lastModified:   2015-08-01 20:49:52
estimatedTime: 0.5 - 1.0 Hours
packagesLibraries: raster, rhdf5, rgdal
authors: Leah A. Wasser, Claire Lunch, Kate Thibault, Natalie Robinson
category: remote-sensing
categories: [Remote Sensing]
tags : [lidar, R]
mainTag: lidar
description: "This lesson contains two option capstone activities that complement the ESA 2015 workshop materials."
permalink: /R/ESA2015-Capstone-R/
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




# Build Your Own Adventure! 

The last hour of this workshop will be on your own! Please select one of the optional
activities below to work on!

## Option One - Create an HDF5 file

If you have some of your own data that you'd like to explore for this activity,
feel free to do so. Otherwise, use the vegetation structure data that we've provided
in the data downloads for this workshop. 

1. Create a new HDF5 file using the the SJER vegetation structure data `D17_2013_vegStr.csv`.
2. Create two groups  wtihin a `California` group:
	- one for the San Joaquin field site
	- one for the Soaproot saddle field site.
3. Attribute each of the above groups with information about the field sites. HINT
you can explore the < a href="http://www.neoninc.org/science-design/field-sites/" target=_blank">
NEON field site page</a> for more information about each site. 
4.Extract the vegetation structure data for San Joaquin and add it as a dataset to the
San Joaquin group. Do the same for the Soaproot dataset. 
5. Add the plot centroids data to the SJER group. Include relevant attributes for 
this dataset including the CRS string, and any other metadata with the dataset.
6. If there's time, open the metadata file for the vegetation structure data. 
Attribute the structure dataset as you see fit to make it usable. As you do this, 
think about the following:

1. Is there a better way to provide / store these metadata?
2. Is there a way to automate adding the metadata to the H5 file?

## Option Two - Calculate NDVI for the SJER field sites


The Normalized Difference Vegetation Index is calculated using the following equation: (NIR - Red) / (NIR + Red) where:

1. NIR is the near infrared band in an image
2. Red is the red band in an image.
 
 
Use the Red (Band 58 in the tiff files) and the NIR (band 90 in the tiff files) tiff files to 

1. Calculate NDVI in R.
2. Plot NDVI. Make sure your plot has a title and a legend. Assign a colormap to the plot and specify the breaks for the colors to represent NDVI values that make sense to you. For instance, you might chose to color the data using breaks at .25,.5, .75 and 1. 
3. Expore your final NDVI dataset as a geotiff. Make sure the CRS is correct. 
4. To test your work, bring it into QGIS. Does it line up with the other tiffs (for example the band 19 tiff). Did it import properly? 



## Option Three - Guided -- Working with Imagery in R

[Work through the lesson on imagery in R.]({{ site.baseurl }}/R/Image-Raster-Data-In-R/)

