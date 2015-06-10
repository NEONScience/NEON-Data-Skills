---
layout: post
title: "Creating a Raster Stack from Hyperspectral Imagery in HDF5 Format in R"
date:   2015-1-13 20:49:52
lastModified: 2015-2-9 20:49:52
createddate:   2014-11-26 20:49:52
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: RHDF5, Raster
authors: Edmund Hart, Leah A. Wasser
categories: [remote-sensing]
category: remote-sensing
tags: [hyperspectral-remote-sensing,R,HDF5]
mainTag: hyperspectral-remote-sensing
description: "Open up and explore hyperspectral imagery in HDF format R. Combine multiple bands to create a raster stack. Use these steps to create various band combinations such as RGB, Color-Infrared and False color images."
code1: 
image:
  feature: hierarchy_folder_purple.png
  credit: Colin Williams NEON, Inc.
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
<li>Extract a "slice" of data from a hyperspectral data cube.</li>
<li>Create a rasterstack in R which can then be used to create RGB images from bands in a hyperspectral data cube.</li>
<li>Plot data spatially on a map.</li>
<li>Create basic vegetation indices like NDVI using raster  based calculations in R.</li>
</ol>

<h3>What you'll Need</h3>
<ul>
<li>R or R studio to write your code.</li>
<li>The latest version of RHDF5 package for R.</li>
<li>Recommended Background: Consider reviewing the documentation for the <a href="http://www.bioconductor.org/packages/release/bioc/manuals/rhdf5/man/rhdf5.pdf" target="_blank">RHDF5 libraries</a></li>
</ul>


<h3>Data to Download</h3>
<a href="http://neonhighered.org/Data/HDF5/SJER_140123_chip.h5" class="btn btn-success"> DOWNLOAD the NEON Imaging Spectrometer Data (HDF5) Format</a>. 
<p>The data in this HDF5 file were collected over the San Joachim field site located in California (NEON Domain 17) and processed at NEON headquarters. The entire dataset can be accessed <a href="http://neoninc.org/data-resources/get-data/airborne-data" target="_blank">by request from the NEON website.</a>
</p>  

<h3>Pre-reqs</h3>
<p>We highly recommend you work through the - Introduction to Working with hyperspectral data in R activity before moving on to this activity.</p>
</div>


##About 
We often want to generate a 3 band image from multi or hyperspectral data. The most commonly recognized band combination is RGB which stands for Red, Green and Blue. RGB images are just like the images that your camera takes. But there are other band combinations that are useful too. For example, near infrared images emphasize vegetation and help us classify or identify where vegetation is located on the ground.

<figure class="third">
    <a href="{{ site.baseurl }}/images/hyperspectral/RGBImage_2.png"><img src="{{ site.baseurl }}/images/hyperspectral/RGBImage_2.png"></a>
    <a href="{{ site.baseurl }}/images/hyperspectral/NIR_G_B.png"><img src="{{ site.baseurl }}/images/hyperspectral/NIR_G_B.png"></a>
    <a href="{{ site.baseurl }}/images/hyperspectral/falseColor.png"><img src="{{ site.baseurl }}/images/hyperspectral/falseColor.png"></a>
    
    <figcaption>SJER image using 3 different band combinations. Left: typical red, green and blue (bands 58,34,19), middle: color infrared: near infrared, green and blue (bands 90, 34, 19).</figcaption>
</figure>

<i class="fa fa-star"></i> **Data Tip - Band Combinations:** the Biodiversity Informatics group created a great interactive tool that lets you explore band combinations. Check it out:<a href="http://biodiversityinformatics.amnh.org/interactives/bandcombination.php" target="_blank">Learn more about band combinations using a great online tool!</a>
{: .notice}



##About This Activity
In this activity, we will learn how to create multi (3) band images. We will also learn how to perform some basic raster calculations (known as raster math in the GIS world).


##1. Creating a Raster Stack in R

In the [previous activity](http://neondataskills.org/HDF5/Imaging-Spectroscopy-HDF5-In-R/), we exported a subset of the NEON Reflectance data from a HDF5 file. In this activity, we will create a full color image using 3 (red, green and blue - RGB) bands. We will follow many of the steps we followed in the [intro to working with hyperspectral data activity](http://neondataskills.org/HDF5/Imaging-Spectroscopy-HDF5-In-R/). These steps included loading required packages, reading in our file and viewing the file structure.

	#Load required packages
	library(raster)
	library(rhdf5)
	#Read in H5 file
	#f <- '/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/HDF5File/SJER_140123_chip.h5'
	f <- '/Users/law/Documents/data/SJER_140123_chip.h5'
	#View HDF5 file structure 
	h5ls(f,all=T)
	#r get spatial info and map info using the h5readAttributes function developed by Ted Hart
	spinfo <- h5readAttributes(f,"spatialInfo")

	#Populate the raster image extent value. 
	#get the map info, split out elements
	mapInfo<-h5read(f,"map info")
	mapInfo<-unlist(strsplit(mapInfo, ","))

Next, we'll write a set of functions that will perform the processing that we did step by step in the [intro to working with hyperspectral data activity](http://neondataskills.org/HDF5/Imaging-Spectroscopy-HDF5-In-R/). This will allow us to process multiple bands in bulk.

The first function `getBandMat` slices the HDF5 file, extracting the reflectance information for a specified band. It returns a matrix containing that band. To call this function, we would enter `getBandMat(fileObject, *BandNumber*)`.
 
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

The next function, `band2rast` takes the subsetted band matrix and creates a raster. It also calculates and sets both the raster extent and the CRS (coordinate reference system) for the raster. The call for this function would be `band2rast(fileObject, *BandNumber*)`.

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

The last function, `stackList` creates the final raster stack. A <a href="http://www.inside-r.org/packages/cran/raster/docs/stack" target="_blank">raster stack</a> is a set 1 or more rasters. If it contains multiple rasters, it uses a list which defines which bands (or dimensions in the Reflectance dataset) to grab and process. 

	## This function creates a stack of rasters from a list of rasters
	stackList <- function(rastList){
  	  #add first raster to stack.
  	  masterRaster <- stack(rastList[[1]])
  	  #add additional layers to raster stack 
  	  for(i in 2:length(rastList)){
    		masterRaster<-  addLayer(masterRaster,rastList[[i]])
  	  }
  	  return(masterRaster)
	}

Now that the functions are created, we can create our list of rasters. The list specifies which bands (or dimensions in our hyperspectral dataset) we want to include in our raster stack. Let's start with a typical RGB (red, green, blue) combination. We will use bands 58, 34, and 19. 

<i class="fa fa-star"></i> **Data Tip - wavelengths and bands:** Remember that you can look at the wavelengths dataset to determine the center wavelength value for each band. 
{: .notice}

	rgb <- list(58,34,19)
	#lapply tells R to apply the function to each element in the list
	rgb_rast <- lapply(rgb,band2rast, f = f)
	#check out the properties or rgb_rast
	#note that it displays properties of 3 rasters.
	rgb_rast

<a href="http://www.r-bloggers.com/using-apply-sapply-lapply-in-r/" target="_blank">More about Lapply here</a>. 

Next, add the names of the bands to the raster so we can easily keep track of the bands in the list.

	#add the band numbers as names to each raster in the raster list
	names(rgb_rast) <- as.character(rgb)
	#check properties of the raster list - note the band names
	rgb_rast
	### Plot one raster in the list to make sure things look OK.
	plot(rgb_rast[[1]])
	#create a raster stack from the list
	rgb_stack <- stackList(rgb_rast)
	
	
Next, let's add the names of each band to our raster list. Then we can plot the bands

	#Add band names to each raster in the stack
	bandNames=paste("Band_",unlist(rgb),sep="")
	for (i in 1:length(rgb_rast) ) {
  	  names(rgb_stack)[i]=bandNames[i]
	}
	#plot the stack	
	plot(rgb_stack)
	plotRGB(rgb_stack,r=1,g=2,b=3, scale=300, stretch = "Lin")

The `plotRGB` function allows you to combine three bands to create an image. <a href="http://www.inside-r.org/packages/cran/raster/docs/plotRGB" target="_blank">More on plotRGB here.</a>

	#write out final raster	
	#note - you should be able to bring this tiff into any GIS program!

	writeRaster(rgb_stack,file="test6.tif",overwrite=TRUE)

<i class="fa fa-star"></i> **Data Tip - False color and near infrared images:** Use the band combinations listed at the top of this page to modify the raster list. What type of image do you get when you change the band values?
{: .notice}


If you want to play around a bit with this -- try plotting the RGB image using different bands. Here are some suggestions.

* Color Infrared / False Color: rgb: (90,34,19)
* SWIR, NIR,Red Band -- rgb (152,90,58)
* False Color: -- rgb (363,246,55)

More on Band Combinations: [http://gdsc.nlr.nl/gdsc/en/information/earth_observation/band_combinations](http://gdsc.nlr.nl/gdsc/en/information/earth_observation/band_combinations)

<i class="fa fa-star"></i>**A note about image stretching:** 
Notice that the scale is set to 300 on the RGB image that we plotted above. We can adjust this number and notice that the image gets darker - or lighter.
{: .notice}

##2. Plotting our data on a map.
We can plot the location of our image on a map of the US. For this we'll use the lower left coordinates of the raster, extracted from the SPINFO group. Note that these coordinates are in latitude and longitude (geographic coordinates) rather than UTM coordinates.

	#Create a Map in R
	library(maps)
	map(database="state",region="california")
	points(spinfo$LL_lat~spinfo$LL_lon,pch = 15)
	#add title to map.
	title(main="NEON Site Location in Southern California")


## 3. Raster Math - Creating NDVI and other Vegetation Indices in R
In this last part, we will calculate some vegetation indices using raster math in R! We will start by creating NDVI or Normalized Difference Vegetation Index. 

<i class="fa fa-star"></i> **Data Tip - About NDVI:** NDVI is  a ratio between the near infrared (NIR) portion of the electromagnetic spectrum and the red portion of the spectrum. Please keep in mind that there are different ways to aggregate bands when using hyperspectral data. This example is using individual bands to perform the NDVI calculation. Using individual bands is not necessarily the best way to calculate NDVI from hyperspectral data! 
{: .notice}

	#Calculate NDVI
	#select bands to use in calculation (red, NIR)
	ndvi_bands <- c(58,90)
	#create raster list and then a stack using those two bands
	ndvi_rast <- lapply(ndvi_bands,band2rast, f = f)
	ndvi_stack <- stackList(ndvi_rast)
	#calculate NDVI
	NDVI <- function(x) {
  	  (x[,2]-x[,1])/(x[,2]+x[,1])
	}
	ndvi_calc <- calc(ndvi_stack,NDVI)
	plot(ndvi_calc, main="NDVI for the NEON SJER Field Site")
	
	
<figure class="half">
<a href="{{ site.baseurl }}/images/hyperspectral/NDVI.png"><img src="{{ site.baseurl }}/images/hyperspectral/NDVI.png"></a>
<a href="{{ site.baseurl }}/images/hyperspectral/EVI.png"><img src="{{ site.baseurl }}/images/hyperspectral/EVI.png"></a>
    
<figcaption>LEFT: NDVI for the NEON SJER field site, created in R. RIGHT: EVI for the NEON SJER field site created in R.</figcaption>
</figure>
	
## Extra Credit
IF you get done early, try any of the following:

1. Calculate EVI using the following formula : EVI<- 2.5 * ((b4-b3) / (b4 + 6 * b3- 7.5*b1 + 1))
2. Calculate NDNI using the following equation: log(1/p1510)-log(1/p1680)/ log(1/p1510)+log(1/p1680)
3. Explore the bands in the hyperspectral data. What happens if you average reflectance values across multiple red and NIR bands and then calculate NDVI?


  
