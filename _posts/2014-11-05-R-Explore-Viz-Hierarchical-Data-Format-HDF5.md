---
layout: post
title: "R: HDF5 - Data Exploration & Viz in R"
date:   2014-11-17 20:49:52
authors: Ted Hart - Adapted from Software Carpentry Materials by Leah A. Wasser
categories: [Coding and Informatics]
category: coding-and-informatics
tags : [HDF5,R]
description: "Explore, extract and visualize temporal temperature data collected from a NEON flux tower from multiple sites and sensors in R. Learn how to extract metadata and how to use nested loops and dplyr to perform more advanced queries and data manipulation."
code1: R_Create_Modify_Hdf5.R
image:
  feature: hierarchy_folder_purple.png
  credit: The Artistry of Colin Williams, NEON
  creditlink: http://www.neoninc.org
permalink: /HDF5/Explore-HDF5-Using-R/
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

**R Skill Level:** intermediate

<div id="objectives">
<h3>Goals / Objectives</h3>

After completing this activity, you will:
<ol>
<li> Know how to explore a new HDF5 dataset in R </li>
<li> Access various groups and datasets within an HDF5 file.</li>
<li> Understand the basics of manipulating big data sets using indexing, loops, and `dplyr`.</li>
<li> Know how to work with the 3 key HDF5 data types: <b>file</b>, <b>groups</b> and <b>datasets</b>.</li>
<li> Refine your data plotting skills using `GGPLOT` in `R`.</li>
<li> Be exposed to and learn how to apply a variety of data manipulation tasks including identifying data types given a new dataset, string parsing, and working with / formatting date information.</li>
</ol>


<h3>You will need:</h3>
<ul>
<li>R or R studio running on your laptop. </li>
<li>HDF5 libraries and associated packages as described in the "getting started" section below. </li>
<li>
<a href="../../data/NEON_TowerDataD3_D10.hdf5" target="_blank">Download the National Ecological Observatory Network (NEON) Flux Tower Temperature data HERE </a></li>
</ul>
</div>

###Getting Started
To be able to access HDF5 files, you'll need to first install the base [HDF5 libraries](http://www.hdfgroup.org/HDF5/release/obtain5.html#obtain). It might also be useful to install [HDFview](http://www.hdfgroup.org/products/java/hdfview/) which will allow you to explore the contents of an HDF5 file visually using a graphic interface. 

The package we'll be using is `rhdf5` which is part of the [Bioconductor](http://www.bioconductor.org) suite of `R` packages. If you haven't installed this package before, you can use the first two lines of code below to install. Then use the library command to call the `rhdf5` library.

	#source("http://bioconductor.org/biocLite.R")
	#biocLite("rhdf5")
	library("rhdf5")

###HDF5 Quick Review
The HDF5 format is a self-contained directory structure. In HDF5 files though "directories" are called "**groups**" and "**files**" are called "datasets". Each element in an hdf5 file can have metadata attached to it making HDF5 files "self-describing".

##Working with Real World Data
In this activity, we'll work with a real world data file. We will work with  [flux tower temperature data](http://neoninc.org/science-design/collection-methods/flux-tower-measurements) collected by the [NEON project](http://www.neoninc.org). NEON will provide 30 years of free ecological data.

In this case, we'll examine this file as if we knew nothing about it. We will view it's structure, extract metadata and visualize the contents of the files. The goal of the lesson is to use loops and custom functions to quickly examine data with a complex nested structure using advanced tools like `dplyr`.

###P1. Examine file contents

Often we won't know the structure of an HDF5 file that we receive. In this case, we'll need to start by explore the underlying structure. Let's load up a NEON flux tower data file and examine its contents using `h5ls`.

	#r load file
	#NOTE: be sure to adjust the path to match your file structure!
	f <- "data/NEON_TowerDataD3_D10.hdf5"
	h5ls(f,all=T)

Note that `h5ls` returns the full, hierarchical file structure including the group name, the name of a particular node (which may be a group), the type, class and the dimensions of the object.  In this case the class of the groups is compound. Compound class means there are mixed data types contained within that group. The dimensions are returned as the number of elements for compound groups.

One major benefit of HDF5 files is the ability to subset and slice out parts of the file. Let's extract some temperature data, collected at the Ordway Swisher Biological Station, <a href="http://neoninc.org/science-design/field-sites/ordway-swisher-biological-station" target="_blank">A NEON Field Site</a> and plot it.

Now remember, we are dealing with **hierarchical data**. In this case we have a nested group and dataset structure. Below, we will extract temperature data which is located within the following structure:
 Domain_03 --> Ord --> min_1 --> boom_1 -->temperature
 
Take note that there are 4 groups and one dataset called temperature in this part of the hdf5 file.

	#read in temperature data
	temp <- h5read(f,"/Domain_03/Ord/min_1/boom_1/temperature")
	#view the first few lines of the data 
	head(temp)
	plot(temp$mean,type='l')
	

![image]({{ site.baseurl }}/images/TempData.png)

### Extracting metadata
Another advantage of HDF5 is that it's self describing. This means that metadata are embedded in the file. Metadata can be associated with every group, dataset and even the file itself. 

The art of extracting metdata in R is not yet refined. Thus to do it effectively, we need to extract attributes individually. Some examples of doing this are below. 

	#r extracting metadata from an HDF5 file
	# Open file
	out <- H5Fopen(f)
	# open a group
	g <- H5Gopen(out,'/Domain_03/Ord')
	#extract the first attribute for that group (g,1)
	a <- H5Aopen_by_idx(g,1)
	#get the name of that attribute
	H5Aget_name(a)

	#get the value for the attribute (in this case it's the site name)
	aval <- H5Aread(a)
	aval

** Be sure to close all elements that you opened!

	H5Aclose(a)
	H5Gclose(g)
	H5Fclose(out)


The above method to extract metadata is tedious because it requires individual commands that query parts of our dataset. An alternative is to create a  function that extracts all of the metadata from any group. Let's do that!

###Create Metadata Extraction Function

	#Create metadata extraction function
	#note: per Ted Hart, this code may be ingested into the rhdf5 
    #library in the future. as of 11/2014 it wasn't there yet.

	h5metadata <- function(fileN, group, natt){
  	 out <- H5Fopen(fileN)
  	 g <- H5Gopen(out,group)
     output <- list()
	 for(i in 0:(natt-1)){
    	  ## Open the attribute
    	  a <- H5Aopen_by_idx(g,i)
    	  output[H5Aget_name(a)] <-  H5Aread(a)
    	  ## Close the attributes
    	  H5Aclose(a)
  	 }
  	 
	H5Gclose(g)
	H5Fclose(out)
	return(output)
	}

Now we can combine the information we get from `h5ls` with our metadata extraction function. This means we could loop through the whole file and extract metadata for every element if we so desired.

	#r extract metadata}
	fiu_struct <- h5ls(f,all=T)
	g <- paste(fiu_struct[2,1:2],collapse="/")
	h5metadata(f,g,fiu_struct$num_attrs[2])

### ******* End Part 1 ********	


##P2 Visualizing datasets in a HDF5 File

This particular dataset contains temperature data collected using different sensors across for multiple field sites and through time. What is we wanted to create a plot that compared data across sensors or sites? 

##P2a. Data from different sensors at one site

To compare data, we'll first need to loop through the HDF5 file and build a new data frame that contains temperature information over time, for each sensor or site. Let's start by comparing temperature data collected by sensor located at different heights (on different boom arms on the tower), and averaged every 1 minute for the NEON Domain 3 site, Ordway Swisher Biological Station located in Florida.

	# Load libraries
	library(dplyr)
	library(ggplot2)
	# Set the path string
	s <- "/Domain_03/Ord/min_1"

    # Grab the paths to the data we want to use
	paths <- fiu_struct %.% filter(grepl(s,group), grepl("DATA",otype)) %.% group_by(group) %.% summarise(path = paste(group,name,sep="/"))
	ord_temp <- data.frame()
	

The above code uses the powerful `dplyr` libraries to filter data. Let's break the code down. 

- `fiu_struct`, defined above in the code, is the structure of our HDF5 file that we returned using `h5ls`.
- `grepl` looks for a text pattern. Type `help(grepl)` to see how it operates. We want to return all "paths" in the HDF file that match `s` which we defined earlier as "/Domain_03/Ord/min_1". Type `s` into the console to see what comes up. 

Pulling this together, type, `fiu_struct %.% filter(grepl(s,group))` in the console. This code will return a list of both datasets and groups for the Domain_03 site that contain the "/Domain_03/Ord/min_1" path. 
Now let's review the second part of the code:

- `grepl("DATA",otype))` tells R to look for objects in the file that contain the word "data". Type: `fiu_struct %.% filter(grepl(s,group), grepl("DATA",otype))` in the console. Notice that this code returns the elements in the file that are both for the Ordway site AND are of type "dataset".
- `group_by(group) %.% summarise(path = paste(group,name,sep="/"))`: This code appends the group name (boom_1, boom_2, etc.) and the dataset name (temperature in this case) to the path.

Next, we will create a loop that will populate the final data.frame that contains information for all booms in the site that we want to plot.
     
    for(i in paths$path){
     boom <-  strsplit(i,"/")[[1]][5]
     dat <- h5read(f,i)
     dat$boom <- rep(boom,dim(dat)[1])
     ord_temp <- rbind(ord_temp,dat)
    }

The loop above iterates through the file and grabs the temperature data for each boom in the 1 minute data series for Ordway. It also adds the boom name to the end of the `data.frame` as follows: 

- `for i in path$path`. We have 5 "paths" total - one for each boom: booms 1,2,3,5 and the tower top (boom 4 doesn't have a temperature sensor on it). Thus we will need do iterate through the data 5 times
- `boom <-  strsplit(i,"/")[[1]][5]`: identify the name of the boom for iteration i. 
- `dat <- h5read(f,i)`: read in the data from our hdf5 file (f) for iteration i (whichever iteration in the loop we are on) .
-  `dat$boom <- rep(boom,dim(dat)[1])`: add the boom name as the final column in the dataset - column named "boom"
-  `ord_temp <- rbind(ord_temp,dat)`: append dataset to the end of the data.frame called ord_temp

    EXTRA CREDIT: Modify the loop above so that it added both the boom name, the site name and the data type (1 minute) as columns in our data frame.

### Cleaning Up Dates
As imported, the dates field in our data frame aren't in "date format". we need to tell R to format the information as a date. This will ensure that the plot that we create has dates labeled correctly. Let's dig in:

	ord_temp$date <- as.POSIXct(ord_temp$date,format = "%Y-%m-%d %H:%M:%S", tz = "EST")

Now we can make our plot of temperature for all booms on the tower!

	ggplot(ord_temp,aes(x=date,y=mean,group=boom,colour=boom))+geom_path()+ylab("Mean temperature") + xlab("Date")+theme_bw()+ggtitle("3 Days of temperature data at Ordway Swisher")


![Image]({{ site.baseurl }}/images/HDf5/ordwayPlot.png)

##P2b. Data from different sites

Now, what if we want to compare temperatures at our two different sites? Well let's do that but this time we'll compare 30 minute averages. We'll need to modify our search strings a bit. Bbut we can still re-use most of the code we just built.

First, let's extract all 30 minute averaged data, for all sites.

	s <- "min_30"
	# Grab the paths for all sites, 30 minute averaged data
	paths <- fiu_struct %.% filter(grepl(s,group), grepl("DATA",otype)) %.% group_by(group) %.% summarise(path = paste(group,name,sep="/"))

	temp_30 <- data.frame()
	for(i in paths$path){
	  boom <-  strsplit(i,"/")[[1]][5]
	  site <- strsplit(i,"/")[[1]][3]
	  dat <- h5read(f,i)
	  dat$boom <- rep(boom,dim(dat)[1])
	  dat$site <- rep(site,dim(dat)[1])
	 temp_30 <- rbind(temp_30,dat)
	}

	#Assign the date field to a "date" format in R
	temp_30$date <- as.POSIXct(temp_30$date,format = "%Y-%m-%d %H:%M:%S")

	temp30_sum <- temp_30 %.% group_by(date,site) %.% summarise(mean = mean(mean))
	
	#Create plot!
	ggplot(temp30_sum,aes(x=date,y=mean,group=site,colour=site)) + geom_path()+ylab("Mean temperature") + xlab("Date")+theme_bw()+ggtitle("Comparison of Ordway-Swisher(FL) vs Sterling(CO)")

![Image]({{ site.baseurl }}/images/HDf5/OrdwaySterling.png)

> Extra Credit: Create a plot of both sites with all booms at each site on the plot.


