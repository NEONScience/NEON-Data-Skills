---
layout: post
title: "R: Working with HDF5 Format Hyperspectral Remote Sensing Data in in R"
date:   2014-11-26 20:49:52
authors: Edmund Hart, Leah A. Wasser
categories: [remote-sensing]
category: remote-sensing
tags: [hyperspectral-remote-sensing,R,HDF5]
mainTag: HDF5
description: "Open up and explore hyperspectral imagery in HDF format R."
code1: 
image:
  feature: hierarchy_folder_purple.png
  credit: The Artistry of Colin Williams, NEON
  creditlink: http://www.neoninc.org
permalink: /HDF5/Create-Raster-Stack-Spectroscopy-HDF5-In-R/
code1: create_rasterStack_R.R
comments: true
---

<section id="table-of-contents" class="toc">
  <header>
    <h3>Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->

<div id="objectives">
<strong>R Skill Level:</strong> Intermediate

<h3>Goals / Objectives</h3>
After completing this activity, you will:
<ol>
<li></li>
<li></li>
<li></li>
<li></li>
</ol>

<h3>What you'll Need</h3>
<ul>
<li>R or R studio to write your code.</li>
<li>The latest version of RHDF5 packag for R.</li>
</ul>


<h3>Data to Download</h3>
<a href="http://neonhighered.org/data/SJER_140123_chip.h5" class="btn"> DOWNLOAD the NEON Imaging Spectrometer Data (HDF5) Format</a>. 
<p>The data in this HDF5 file were collected over the San Joachim field site located in California (NEON Domain 17) and processed at NEON headquarters. The entire dataset can be access by request from the NEON website.</p>  

<h3>Pre-reqs</h3>
<p>We highly recommend you work through the - Introduction to Working with hyperspectral data in R activity before moving on to this activity.</p>
</div>


##About 



##About This Activity


<i class="fa fa-star"></i> **Data Tip:** .
{: .notice}


##1. Creating a Raster Stack in R

We often want to generate a 3 band image from multi or hyperspectral data. Now, let's generate a full color image with the red, green and blue (RGB) bands. But before we start, let's write a function to handle some of the basic cleaning we did earlier, that way we can bulk process bands.


	#Plot  RGB
	# f: the hdf file
	# band: the band you want to grab
	# returns: a cleaned up HDF5 reflectance file
	getBandMat <- function(f, band){
  	  out<- h5read(f,"Reflectance",index=list(1:477,1:502,band))
  	  #Convert from array to matrix
  	  out <- (out[,,1])
	  #assign data ignore values to NA
  	  out[out > 14999] <- NA
  	  return(out)
	}

	band2rast <- function(f,band){

	out <-  raster(getBandMat(f,band),crs="+zone=11N +ellps=WGS84 +datum=WGS84 +proj=longlat")

	ex <- sort(unlist(spinfo[2:5]))
	}

If you want to stay in UTM's you can use the code below and comment out the two lines above. Note that these were calculated externally and not embedded in the metadata. In the future they will be embedded in the metadata of NEON HDF5 files.

	#out <-  raster(getBandMat(f,band),crs="+zone=11 +units=m +ellps=WGS84 +datum=WGS84 +proj=utm")
	# ex <- c(256521.0,256998.0,4112069.0,4112571.0)
	e <- extent(ex)
  	extent(out) <- e
  	return(out)
	}


	stackList <- function(rastList){
  	## Creates a stack of rasters from a list of rasters
  	masterRaster <- stack(rastList[[1]])
  	for(i in 2:length(rastList)){
    		masterRaster<-  addLayer(masterRaster,rastList[[i]])
  	}
  	return(masterRaster)
	}

	rgb <- list(58,34,19)
	rgb_rast <- lapply(rgb,band2rast, f = f)

Add the names of the bands so we can easily keep track of the bands in the list

	names(rgb_rast) <- as.character(rgb)

	### Check with a plot
	plot(rgb_rast[[1]])
	rgb_stack <- stackList(rgb_rast)
	plot(rgb_stack)
	plotRGB(rgb_stack,r=1,g=2,b=3, scale=300, stretch = "Lin")


	writeRaster(rgb_stack,file="test6.tif",overwrite=TRUE)

**a note about image stretching** 
notice that hte scale is set to 300 on the RGB image that we plotted above. We can adjust this number and notice that the image gets darker - or lighter

If you want to play around a bit with this -- try plotting the RGB image using different bands. Here are some suggestions.
* Color Infrared / False Color: rgb: (90,34,19)
* SWIR, NIR,Red Band -- rgb (152,90,58)

More on Band Combinations: [http://gdsc.nlr.nl/gdsc/en/information/earth_observation/band_combinations](http://gdsc.nlr.nl/gdsc/en/information/earth_observation/band_combinations)

We can also plot our image on a map of the US

	#Create a Map in R
	library(maps)
	map(database="state",region="california")
	points(spinfo$LL_lat~spinfo$LL_lon,pch = 15)
	# Add raster

Now the fun stuff!  Let's create NDVI or Normalized Difference Vegetation Index
NDVI is simply a ration between the Near infrared portion of the spectrum and the red. Please keep in mind the there are different ways to aggregate bands when using hyperspectral data. We are just showing you how the do the math. This is not necessarily the best way to calculate NDVI using hyperspectral data! 

	#r ndvi}

	ndvi_bands <- c(58,90)

	ndvi_rast <- lapply(ndvi_bands,band2rast, f = f)
	ndvi_stack <- stackList(ndvi_rast)
	NDVI <- function(x) {
  	  (x[,2]-x[,1])/(x[,2]+x[,1])
	}
	ndvi_calc <- calc(ndvi_stack,NDVI)
	plot(ndvi_calc)



  
