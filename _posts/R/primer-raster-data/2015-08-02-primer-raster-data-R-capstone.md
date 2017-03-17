---
layout: post
title: "Primer on Raster Data Series Capstone Challenges"
date:   2015-5-11
createdDate:   2015-08-01
lastModified:   2017-03-17
estimatedTime: 0.5 - 1.0 Hours
packagesLibraries: [raster, rhdf5, rgdal]
authors: [Leah A. Wasser, Claire Lunch, Kate Thibault, Natalie Robinson]
categories: [self-paced-tutorial]
tags : [lidar, R]
mainTag: lidar
description: "This page contains capstone activities that complement the Primer on Spatial Data Types tutorial series."
permalink: /R/Spatial-Data-Primer-Capstones
comments: true
code1: 
image:
  feature: textur2_pointsProfile.png
  credit:
  creditlink:
---


{% include _toc.html %}

These capstone challenges utilize the skills that you learned in the previous 
tutorials in the *Primer on Spatial Data Types* series. 

<div id="objectives" markdown="1">

## Things You’ll Need To Complete This Tutorial
You will need the most current version of `R` and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages

* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`
* **sp:** `install.packages("sp")`

[More on Packages in R - Adapted from Software Carpentry.]({{site.baseurl}}/R/Packages-In-R/)

### Download Data

{% include/dataSubsets/_data_Field-Site-Spatial-Data.html %}

## Tutorial Series 
These capstone activities rely on skills learned in the 
<a href="{{ site.baseurl }}/tutorial-series/spatial-data-types-primer/" target="_blank">Primer on Spatial Data Types series</a>. 
</div>



## Capstone One: Create an HDF5 file

If you have some of your own data that you'd like to explore for this activity,
feel free to do so. Otherwise, use the vegetation structure data that we've provided
in the data downloads for this workshop. 

1. Create a new HDF5 file using the the SJER vegetation structure data `D17_2013_vegStr.csv`.
2. Create two groups  wtihin a `California` group:
	- one for the San Joaquin field site
	- one for the Soaproot saddle field site.
3. Attribute each of the above groups with information about the field sites. HINT
you can explore the < a href="http://www.neonscience.org/science-design/field-sites/" target=_blank">
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

## Capstone Two: Calculate NDVI for the SJER field sites


The Normalized Difference Vegetation Index is calculated using the following 
equation: (NIR - Red) / (NIR + Red) where:

1. NIR is the near infrared band in an image
2. Red is the red band in an image.
 
 
Use the Red (Band 58 in the tiff files) and the NIR (band 90 in the tiff files) 
tiff files to 

1. Calculate NDVI in R.
2. Plot NDVI. Make sure your plot has a title and a legend. Assign a colormap 
to the plot and specify the breaks for the colors to represent NDVI values that 
make sense to you. For instance, you might chose to color the data using breaks 
at .25,.5, .75 and 1. 
3. Expore your final NDVI dataset as a geotiff. Make sure the CRS is correct. 
4. To test your work, bring it into QGIS. Does it line up with the other tiffs 
(for example the band 19 tiff). Did it import properly? 

