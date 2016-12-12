---
layout: post
title: "Image Raster Data in R - An Intro"
date:   2015-05-18
authors: [Leah A. Wasser]
dateCreated:  2015-05-18
lastModified: 2015-05-18
categories: [self-paced-tutorial]
category: self-paced-tutorial
tags: [hyperspectral-remote-sensing, R, spatial-data-gis, remote-sensing]
packagesLibraries: [raster, sp, rgdal]
mainTag: spatial-data-gis
description: "This post explains the fundamental principles, functions and metadata that 
you need to work with raster data, in image format in R. Topics include raster stacks, raster bricks
plotting RGB images and exporting an RGB image to a Geotiff."
code1: 
image:
  feature: lidar_GrandMesa.png
  credit: LiDAR data collected over Grand Mesa, Colorado - National Ecological Observatory Network (NEON)
  creditlink:
permalink: /R/Image-Raster-Data-In-R/
code1: R/image-rasters-R.R
comments: true
---

{% include _toc.html %}

### About
This activity will walk you through the fundamental principles of working 
with image raster data in R.
**R Skill Level:** Intermediate

<div id="objectives">

<h3>Goals / Objectives</h3>
After completing this activity, you will know:
<ol>
<li>How to import multiple image rasters and create a stack of rasters.</li>
<li>How to plot 3 band, RGB images in R.</li>
<li>How to export single band and multiple band image rasters in R.</li>
</ol>

<h3>Things You'll Need To Complete This Lesson</h3>

<h4>Tools & Libraries To Install</h4>
<ul>
<li>R or R studio to write your code.</li>
<li>R packages <code>raster</code>, <code>sp</code> and <code>rgdal</code> </li>
</ul>


<h4>Data to Download</h4>

Download the raster data:

{% include/dataSubsets/_data_Field-Site-Spatial-Data.html %}


<h4>Recommended Pre-Lesson Reading</h4>
<ul>
<li>
<a href="{{ site.baseurl }}/GIS-spatial-data/Working-With-Rasters/">
Please read "Working With Rasters in R, Python and other NON gui tools.</a>
</li>
<li>
<a href="{{ site.baseurl }}/R/Raster-Data-In-R/">
Please read "Raster Data in R - the basics.</a>
</li>
<li>
<a href="http://cran.r-project.org/web/packages/raster/raster.pdf" target="_blank">
Read more about the `raster` package in R.</a>
</li>
</ul>
</div>

### Review - Raster Data
Raster or "gridded" data are data that are saved in pixels. In the spatial world, 
each pixel represents an area on the Earth's surface. An color image raster, is a bit different from other rasters in that it has multiple bands. Each band represents reflectance values for a particular color or type of light. If the image is RGB, then the bands are in the red, green and blue portions of the spectrum. These colors together create what we know as a full color image.

<figure>
	<img src="{{ site.baseurl }}/images/hyperspectral/RGBImage_2.png">
   <figcaption>A color image at the NEON San Joachin site in california. Each pixel in the image represents reflectance in the red, green and blue portions of the electromagnetic spectrum.</figcaption>
</figure>


# Bands & Images in R

## Working with multiple rasters using Raster Stacks and Raster Bricks

In [a previous post]({{ site.baseurl }}/R/Raster-Data-In-R/), we loaded a single raster into R. We've also made sure we knew the `CRS` 
(coordinate reference system) and extent of the dataset among other key metadata 
attributes. Next, let's create a raster stack from 3 raster images.

A raster stack is a collection of raster layers. Each raster layer in the stack 
needs to be in the same projection (CRS), spatial extent and resolution. You 
might use raster stacks for different reasons. For instance, you might want to 
group a time series of rasters representing precipitation or temperature into 
one R object. Or, you might want to create a color images from red, green and blue band derived rasters.

In this lesson, we will stack 3 bands from a multi-band image together to create 
a final RGB image.

First let's load up the libraries that we need: `sp` and `raster`. To install the raster library you can use 
`install.packages(‘raster’)`. When you install the raster library, `sp` should 
also install. Also install the `rgdal` library" 
`install.packages(‘rgdal’)`.

	#load the raster, sp, and rgdal packages
	library(raster)
	library(sp)
	library(rgdal)
	#Set your working directory to the folder where your data for this workshop
	#are stored. NOTE: if you created a project file in R studio, then you don't
	#need to set the working directory as it's part of the project.
	setwd("~/yourWorkingDirectoryHere")  
	

Next, let's create a raster stack. The difficult way to do this is to load our rasters one at a time. But that takes
 a good bit of effort. 

	#import tiffs
	band19 <- "rasterLayers_tif/band19.tif"
	band34 <- "rasterLayers_tif/band34.tif"
	band58 <- "rasterLayers_tif/band58.tif"

We can also use the list.files command to grab all of the files in a directory.
We can use `full.names=TRUE` to ensure that R will store the directory path in our list of
rasters.

	#create list of files to make raster stack
	rasterlist <-  list.files('rasterLayers_tif', full.names=TRUE)

NOTE: If your list of rasters is located in your main R working directory, you can
achieve the same results as above by looking for all files with a '.tif' extension:
 `rasterlist <-  list.files('rasterLayers_tif', full.names=TRUE, pattern="tif")`. 

	#create raster stack
	rgbRaster <- stack(rasterlist)

	#check to see that you've created a raster stack and plot the layers
	rgbRaster
	plot(rgbRaster)

<figure>
   <a href="{{ site.baseurl }}/images/spatialData/rgbStackPlot.png"><img src="{{ site.baseurl }}/images/spatialData/rgbStackPlot.png"></a>
 <figcaption>All rasters in the rasterstack plotted.</figcaption>
</figure>


## Plot an RGB Image

You can plot an RGB image from a raster `stack`. You need to specify the order of the bands when you do this. In our raster stack, band 19 which is the blue band, is first in the list, whereas band 58 which is the red band is last. Thus the order is 3,2,1 to ensure the red band is rendered first as red. 

	#plot an RGB version of the stack
	plotRGB(rgbRaster,r=3,g=2,b=1, scale=800, stretch = "Lin")

<figure>
    <a href="{{ site.baseurl }}/images/spatialData/RGBRaster_SJER.png"><img src="{{ site.baseurl }}/images/spatialData/RGBRaster_SJER.png"></a>
<figcaption>To plot an RGB image in R, you need to specify which rasters to render on the red, green and blue bands. </figcaption>
</figure>



## Explore Raster Values - Histograms
You can also explore the data.


	#look at histogram of reflectance values for all rasters
	hist(rgbRaster)


<figure>
   <a href="{{ site.baseurl }}/images/spatialData/RGBhist.png"><img src="{{ site.baseurl }}/images/spatialData/RGBhist.png"></a>
 <figcaption>Histogram of reflectance values for each raster in the raster stack.</figcaption>
</figure>

	#remember that crop function? You can crop all rasters within a raster stack too
	#finally you can crop all rasters within a raster stack!
	rgbCrop <- c(256770.7,256959,4112140,4112284)
	rgbRaster_crop <- crop(rgbRaster, rgbCrop)
	plot(rgbRaster_crop)

<figure>
   <a href="{{ site.baseurl }}/images/spatialData/cropRaster2.png"><img src="{{ site.baseurl }}/images/spatialData/cropRaster2.png"></a>
 <figcaption>Cropped rasters in the raster stack.</figcaption>
</figure>


## Raster Bricks in R
Now we have a list of rasters in a stack. These rasters are all the same extent CRS and resolution but a raster brick will create one raster object in R that contains all of the rasters we can use this object to quickly create RGB images. Raster bricks are more efficient objects to use when processing larger datasets. This is because the computer doesn't have to spend energy finding the data - it is contained within the object.

	#create raster brick
	RGBbrick <- brick(rgbRaster)
	plotRGB(RGBbrick,r=3,g=2,b=1, scale=800, stretch = "Lin")
	
While the brick might seem similar to the stack, we can see that it's very different when we look at the size of the object.	
	
	#the brick contains ALL of the data stored in one object
	#the stack contains links or references to the files stored on your computer
	object.size(rgbBrick)
	
Output

	> 5759448 bytes	
	
View the size of the stack:
	
	object.size(rgbRaster)

Output:

	> 40408 bytes
	
	
## Write a raster to a Geotiff File in R

We can write out the raster in tiff format as well. When we do this it will copy the CRS, extent and resolution information so the data will read properly into a GIS as well. Note that this writes the raster in the order they are in - in the stack. In this case, the blue (band 19) is first but it's looking for the red band first (RGB). One way around this is to generate a new raster stack with the rasters in the proper order - red, green and blue format.

	#Make a new stack in the order we want the data in: 
	finalRGBstack <- stack(rgbRaster$band58,rgbRaster$band34,rgbRaster$band19)
	#write the geotiff - change overwrite=TRUE to overwrite=FALSE if you want to make sure you don't overwrite your files!
	writeRaster(finalRGBstack,"rgbRaster.tif","GTiff", overwrite=TRUE)

## Import A Multi-Band Image into R
You can import a multi-band image into R too. To do this, you import the file as a stack rather than a raster (which brings in just one band). Let's import the raster than we just created above.

	#Import Multi-Band raster
	newRaster <- stack("rgbRaster.tif") 
	#then plot it
	plot(newRaster)
	plotRGB(newRaster,r=1,g=2,b=3, scale=800, stretch="lin")

## Challenge 


1. A color infrared image is a combination of the gree, red and near-infrared bands. In our case gree <- band 34, red <- band 58 and near-infrared <- band90. Using the same band90 raster that you fixed in step one above, create a color infrared image. HINT: when you use the plotRGB function, you'll map the bands as follows: blue=band34, green=band58, red=band90. Export your results as a geotiff.
