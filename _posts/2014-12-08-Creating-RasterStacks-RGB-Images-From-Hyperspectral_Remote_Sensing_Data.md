---
layout: post
title: "R: Working with HDF5 Format Hyperspectral Remote Sensing Data in in R"
date:   2014-11-26 20:49:52
authors: Edmund Hart, Leah A. Wasser
categories: [remote-sensing]
category: remote-sensing
tags: [hyperspectral-remote-sensing,R,HDF5]
mainTag: hyperspectral-remote-sensing
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
<a href="http://neonhighered.org/data/SJER_140123_chip.h5" class="btn btn-success"> DOWNLOAD the NEON Imaging Spectrometer Data (HDF5) Format</a>. 
<p>The data in this HDF5 file were collected over the San Joachim field site located in California (NEON Domain 17) and processed at NEON headquarters. The entire dataset can be access by request from the NEON website.</p>  

<h3>Pre-reqs</h3>
<p>We highly recommend you work through the - Introduction to Working with hyperspectral data in R activity before moving on to this activity.</p>
</div>


##About 
We often want to generate a 3 band image from multi or hyperspectral dataset. The most commonly recognized band combination is RGB which stands for Red, Green and Blue. RGB images are just like the images that your camera takes. But there are other band combinations that are useful too. For example near infrared images emphasize vegetation and help us classify or identify where vegetation is located on the ground.

<figure class="third">
    <a href="{{ site.baseurl }}/images/hyperspectral/SJER_RGB.png"><img src="{{ site.baseurl }}/images/hyperspectral/SJER_RGB.png"></a>
    <a href="{{ site.baseurl }}/images/hyperspectral/NIR_G_B.png"><img src="{{ site.baseurl }}/images/hyperspectral/NIR_G_B.png"></a>
    <a href="{{ site.baseurl }}/images/hyperspectral/falseColor.png"><img src="{{ site.baseurl }}/images/hyperspectral/falseColor.png"></a>
    
    <figcaption>SJER image using 3 different band combinations. Left: typical red, green and blue (bands 58,34,19), middle: color infrared: near infrared, green and blue (bands90, 34, 19).</figcaption>
</figure>

<i class="fa fa-star"></i> **Data Tip - Band Combinations:** the Biodiversity INformatics group created a great interactive tool that lets you explore band combinations. Check it out:<a hreaf="http://biodiversityinformatics.amnh.org/interactives/bandcombination.php" target="_blank">Learn more about band combinations using this great online tool!</a>
{: .notice}



##About This Activity
In this activity, we will learn how to create multi (3) band images. We will also learn how to perform some basic raster calculations (known as raster math in the GIS world).




##1. Creating a Raster Stack in R

In the previous activity, we exported a subset of the NEON Reflectance data from a HDF5 file. In this activity, we will create a full color image using 3 (red, green and blue - RGB) bands. We will start with the same steps we did in the last activity - make sure our packages are loaded and read in the HDF5 file.

	#Load required packages
	library(raster)
	library(rhdf5)
	#Read in H5 file
	#f <- '/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/HDF5File/SJER_140123_chip.h5'
	f <- '/Users/law/Documents/data/SJER_140123_chip.h5'
	#View HDF5 file structure 
	h5ls(f,all=T)

Next, we'll write a set of functions that will perform the processing that we did step by step in the previous activity. This will allow us to process multiple bands in bulk.

The first function `getBandMat` slices the HDF5 file, extracting the reflectance information for a specified band. It returns a matrix containing that band.
 
	#f: the hdf file
	# band: the band you want to process
	# returns: a matrix containing the reflectance data for the specific band
	getBandMat <- function(f, band){
  	  out<- h5read(f,"Reflectance",index=list(1:477,1:502,band))
  	  #Convert from array to matrix
  	  out <- (out[,,1])
  	  #transpose data to fix flipped row and column order 
  	  out <-t(out)
	  #assign data ignore values to NA
  	  out[out > 14999] <- NA
  	  return(out)
	}

The `band2rast` function takes the subsetted band matrix and creates a raster. IT also calculates and sets both the raster extent and the CRS (coordinate reference system).

	band2rast <- function(f,band){
  	  #define the raster including the CRS (taken from SPINFO)
      out <-  raster(getBandMat(f,band),crs=(spinfo$projdef))
      #define extents of the data using metadata and matrix attributes
      xMN=as.numeric(mapInfo[4])
      xMX=(xMN+(ncol(b34)))
      yMN=as.numeric(mapInfo[5]) 
      yMX=(yMN+(nrow(b34)))
      #set raster extent
      rasExt <- extent(xMN,xMX,yMN,yMX)
      #assign extent to raster
      extent(out) <- rasExt
      return(out)
    }

This function creates the final raster stack - which is a set of multiple rasters.  It uses a list which tells it which bands (or dimensions in the Reflectance dataset) to grab and process.

	stackList <- function(rastList){
  	  ## Creates a stack of rasters from a list of rasters
  	  masterRaster <- stack(rastList[[1]])
  	  for(i in 2:length(rastList)){
    		masterRaster<-  addLayer(masterRaster,rastList[[i]])
  	  }
  	  return(masterRaster)
	}

Now that the functions are out of the way, we can create our list. The list specifies which bands (or dimensions in our hyperspectral dataset) we want to render in our raster stack. Let's start with a typical RGB (red, green, blue) configuration. We will use bands 58, 34, and 19. 

<i class="fa fa-star"></i> **Data Tip - wavelengths and bands:** Remember that you can look at the wavelengths dataset to determine the center wavelength value for each band. 
{: .notice}

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

<i class="fa fa-star"></i> **Data Tip - False color and near infrared images:** Use the band combinations listed at the top of this page to modify the raster list. what type of image do you get when you change the band values?
{: .notice}


**a note about image stretching** 
Notice that the scale is set to 300 on the RGB image that we plotted above. We can adjust this number and notice that the image gets darker - or lighter

If you want to play around a bit with this -- try plotting the RGB image using different bands. Here are some suggestions.
* Color Infrared / False Color: rgb: (90,34,19)
* SWIR, NIR,Red Band -- rgb (152,90,58)
* False Color: -- rgb (363,246,55)

More on Band Combinations: [http://gdsc.nlr.nl/gdsc/en/information/earth_observation/band_combinations](http://gdsc.nlr.nl/gdsc/en/information/earth_observation/band_combinations)

##2. Plotting our data on a map.
We can plot the location of our image on a map of the US. FOr this we'll use the lower left coordinates of the raster, extracted from the SPINFO group. Note that these coordinates are in latitude and longitude (geographic coordinates) rather than UTM coordinates.

	#Create a Map in R
	library(maps)
	map(database="state",region="california")
	points(spinfo$LL_lat~spinfo$LL_lon,pch = 15)
	#add title to map.
	title(main="NEON Site Location in Southern California")


## 3. Raster Math - Creating NDVI and other Veg Indices in R
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



  
