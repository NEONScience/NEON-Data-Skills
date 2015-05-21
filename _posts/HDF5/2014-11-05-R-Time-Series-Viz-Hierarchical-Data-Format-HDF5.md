---
layout: post
title: "Working With Temperature Data Collected for Multiple Sites and Stored in  HDF5 Format in R"
date:   2015-1-28 20:49:52
dateCreated:   2014-11-17 20:49:52
lastModified:   2015-2-06 20:49:52
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: RHDF5, Ggplot
authors: Ted Hart, Leah A Wasser, Adapted from Software Carpentry Materials
contributors: Elizabeth Webb
categories: [coding-and-informatics]
category: coding-and-informatics
tags: [HDF5,R]
mainTag: HDF5
description: "Explore, extract and visualize temporal temperature data collected from a NEON flux tower from multiple sites and sensors in R. Learn how to extract metadata and how to use nested loops and dplyr to perform more advanced queries and data manipulation."
code1: explore_dataViz.R
image:
  feature: hierarchy_folder_purple.png
  credit: Colin Williams NEON, Inc.
  creditlink: http://www.neoninc.org
permalink: /HDF5/Explore-HDF5-Using-R/
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

**R Skill Level:** intermediate

<div id="objectives">
<h3>Goals / Objectives</h3>

After completing this activity, you will:
<ol>
<li> Know how to explore an HDF5 file and access groups and datasets in R.</li>
<li> Understand the basics of manipulating big data sets using indexing, loops, and `dplyr`.</li>
<li> Refine your data plotting skills using `GGPLOT` in `R`.</li>
<li> Be exposed to and learn how to apply a variety of data manipulation tasks including identifying data types given a new dataset, string parsing, and working with / formatting date information.</li>
</ol>


<h3>You will need:</h3>
<ul>
<li>R or R studio running on your computer. </li>
<li>HDF5 libraries and associated packages as described in the "getting started" section below. </li>
<li>Recommended Background: Consider reviewing the documentation for the <a href="http://www.bioconductor.org/packages/release/bioc/manuals/rhdf5/man/rhdf5.pdf" target="_blank">RHDF5 libraries</a></li>
</ul>

<h3>Data to Download:</h3>
<a href="../../data/NEON_TowerDataD3_D10.hdf5" target="_blank" class="btn btn-success">Download the National Ecological Observatory Network (NEON) Flux Tower Temperature data HERE </a>

</div>

###Getting Started
To access HDF5 files in R, you'll need to first install the base [HDF5 libraries](http://www.hdfgroup.org/HDF5/release/obtain5.html#obtain). It might also be useful to install [HDFview](http://www.hdfgroup.org/products/java/hdfview/) which will allow you to explore the contents of an HDF5 file visually using a graphic interface. 

The package we'll be using is `rhdf5` which is part of the <a href="http://www.bioconductor.org" target="_blank">Bioconductor</a> suite of `R` packages. If you haven't installed this package before, you can use the first two lines of code below to install. Then use the library command to call the `rhdf5` library.

	# Install rhdf5 packages
    # source("http://bioconductor.org/biocLite.R")
	# biocLite("rhdf5")
	library("rhdf5")

###HDF5 Quick Review
The HDF5 format is a self-contained directory structure. In HDF5 files though "directories" are called "**groups**" and "**files**" are called "datasets". Each element in an hdf5 file can have metadata attached to it making HDF5 files "self-describing".

## Working with NEON Temporal Temperature Tower Data  
In this activity, we'll work with <a href="http://neoninc.org/science-design/collection-methods/flux-tower-measurements"> temperature data collected using sensors on a flux tower</a> by  <a href="http://www.neoninc.org" target="_blank">the National Ecological Observatory Network (NEON) </a>. NEON will provide 30 years of open ecological data.

We'll examine our HDF5 file as if we knew nothing about it. We will view its structure, extract metadata and visualize data contained within datasets in the HDF5 file. We will also use use loops and custom functions to efficiently examine data with a complex nested structure using advanced tools like `dplyr`.

##1. Examine File Contents

Often we don't know the structure of an HDF5 file that we receive. This means that to work with the data, we'll first need to explore the underlying file structure. Let's explore a NEON flux tower data file in HDF5 format in R. We'll examine the file contents using the R function, `h5ls`.

	# Load file
	#NOTE: be sure to adjust the path to match your file structure!
	# Identify file path
	f <- "data/NEON_TowerDataD3_D10.hdf5"
	# View structure of file
	h5ls(f,all=T)

Note that `h5ls` returns the full, hierarchical file structure including the group name, the name of a particular node (which may be a group), the type, class and the dimensions of the object. In this case the class of the groups is compound. Compound class means there are mixed data types (e.g. some columns are strings and some columns are integer or floating point numbers)  contained within that group. The dimensions for each dataset are also returned. When the dataset is compound, the dimension returned is the number of elements (or rows in the matrix in this case).

## Slicing Data
One major benefit of HDF5 files is the ability to subset or `slice` out parts of the file. Data slicing is particularly useful and efficient if you're dealing with large files (even gigabytes or more). Let's extract some temperature data, collected at <a href="http://neoninc.org/science-design/field-sites/ordway-swisher-biological-station" target="_blank">the NEON field site - Ordway Swisher Biological Station (OSBS)</a> and plot it.

Remember that we are dealing with **hierarchical data**. In this case we have a nested group and dataset structure. Below, we will slice out temperature data which is located within the following path:
 Domain_03 --> OSBS --> min_1 --> boom_1 -->temperature
 
Take note that there are 4 groups and one dataset called temperature in this part of the HDF5 file as follows:

* **Domain_03** - A NEON domain is an ecologically unique region. Domain 3 is one of 20 regions that <a href="http://neoninc.org/science-design/spatiotemporal-design" target="_blank" >NEON uses to organize its network spatially </a>.
* **OSBS** - a group representing data from the <a href="http://neoninc.org/science-design/field-sites/ordway-swisher-biological-station" target="_blank"> Ordway Swisher Biological Station.</a>
* **min_1** - A group representing the mean temperature data value for every for one minute in time. Temperature data is often collected at high frequencies (20 hz or 20 measurements a second) or more. A typical data product derived from high frequency data is an average value - in this case, all measurements are averaged every minute.  
* **boom_1** - Boom 1 is the first and lowest arm or level on the tower. Towers often contain arms where the sensors are mounted, that reach out horizontally away from the tower (see figure below). The tower at Ordway Swisher has a total of 6 booms (booms 1-5 and the tower top). 

<i class="fa fa-star"></i> **Note:** The data used in this activity were collected by a temperature sensor mounted on a National Ecological Observatory Network (NEON) "flux tower". 
<a href="http://neoninc.org/science-design/collection-methods/flux-tower-measurements" target="_blank">Read more about NEON towers, here. </a>
{: .notice}

<figure>
    <a href="{{ site.baseurl }}/images/NEONtower.png"><img src="{{ site.baseurl }}/images/NEONtower.png"></a>
    <figcaption>A NEON tower contains booms or arms that house sensors at varying heights along the tower.</figcaption>
</figure>

	#read in temperature data
	temp <- h5read(f,"/Domain_03/OSBS/min_1/boom_1/temperature")
	#view the first few lines of the data 
	head(temp)
	#generate a quick plot of the data
	plot(temp$mean,type='l')
	

![image]({{ site.baseurl }}/images/TempData.png)

We can make our plot look nicer by adding date values to the x axis. However, in order to list dates o the X axis, we need to assign the date field a date format so that R knows how to read and organize the labels on the axis.


	# Assign the date column a date format.
	temp$date <- as.POSIXct(temp$date ,format = "%Y-%m-%d %H:%M:%S", tz = "EST")
	
    #load GGPLOT 
	library(ggplot2)
	#Create plot
	ordwayPlot <- qplot (date,mean,data=temp,geom="line", title="ordwayData",
	                 main="Mean Temperature Over 3 Days For Ordway Swisher Biological Station", xlab="Date", 
	                 ylab="Mean Temperature (Degrees C)")
	
	#let's check out the plot
	ordwayPlot

Your plot should look like this - pretty cool, right?:

<iframe width="460" height="345" frameborder="0" seamless="seamless" scrolling="no" src="https://plot.ly/~leahawasser/6.embed?width=460&height=345"></iframe>

### Extracting metadata
Remember in HDF5 files, metadata can be stored for all elements (the file itself, groups and datasets) in the HDF5 file. To read the metadata for elements in a file in R, you can use the `h5readAttributes` function. We'll work with this next.

	## Get names of elements in our file
	fiu_struct <- h5ls(f,all=T)
	## Concatenate the domain and the site names separated with a backslash
	# This is the path to the metadata that we are interested in
	g <- paste(fiu_struct[2,1:2],collapse="/")
	# Check out the element g that was created above by printing it
	print(g)
	#  View the metadata for "g"
	h5readAttributes(f,g)

Remember that you can work through the elements of the code above to understand it by typing each line into the console and examining the results. For instance, what happens when you type `fiu_struct[2,1:2]` into the console?

> Extra: Explore using the temperature data further using `h5ls` . View attribute data for other groups within the file. If you have the HDFViewer installed, consider comparing what you get from are to what you see in the file visually using the HDFviewer.

### ******* End Part 1 ********	


## 2 Plotting NEON Temperature Data Extracted from an HDF5 file Using GGPLOT

The NEON HDF5 file that we are working with contains temperature data collected for three days (a very small subset of the available data) using temperature sensors mounted on a towers located at two different <a href="http://neoninc.org/science-design/field-sites" target="_blank">NEON field sites</a>. What if we wanted to create a plot that compared data across sensors or sites? 

### Data From Different Sensors Located at Different Levels, At One NEON Field Site

To compare data, we'll first need to loop through the HDF5 file and build a new data frame that contains temperature information over time, for each sensor or site. Let's start by comparing temperature data collected by sensor located at different heights (on different boom arms on the tower), and averaged every 1 minute for the NEON Domain 3 site, Ordway Swisher Biological Station located in Florida.

	# Load libraries
	library(dplyr)
	
	# Set the path string
	s <- "/Domain_03/Ord/min_1"

    # Grab the paths to the data we want to use
	paths <- fiu_struct %>% filter(grepl(s,group), 
	     grepl("DATA",otype)) %>% group_by(group) %>% summarise(path = paste(group,name,sep="/"))
	#create a new blank data frame    
	ord_temp <- data.frame()
	

The above code uses the powerful `dplyr` libraries to filter data. Let's break the code down. `dplyr` is a package worth getting to know if you are working with big data. <a href="http://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html" target="_blank">Read more about the `dplyr` package here</a>

- `fiu_struct`, defined above in the code, is the structure of our HDF5 file that we returned using `h5ls`.
- `grepl` looks for a text pattern. Type `help(grepl)` to see how it operates. We want to return all "paths" in the HDF file that match `s` which we defined earlier as "/Domain_03/Ord/min_1". Type `s` into the console to see what comes up. 
- `%>%` is syntax specific to the `dplyr` package. the `dplyr` package contains functions that are used to query and subset data in different ways. The `%<%` function allows you to 'chain' or combine multiple queries together into one, concise, line of code. 

Pulling this together, type, `fiu_struct %>% filter(grepl(s,group))` in the console. This code will return a list of both datasets and groups for the Domain_03 site that contain the "/Domain_03/Ord/min_1" path. 
Now let's review the second part of the code:

- `grepl("DATA",otype))` tells R to look for objects in the file that contain the word "data". Type: `fiu_struct %>% filter(grepl(s,group), grepl("DATA",otype))` in the console. Notice that this code returns the elements in the file that are both for the Ordway site AND are of type "dataset".
- `group_by(group) %>% summarise(path = paste(group,name,sep="/"))`: This code appends the group name (boom_1, boom_2, etc.) and the dataset name (temperature in this case) to the path.

Next, we will create a loop that will populate the final `data.frame` that contains information for all booms in the site that we want to plot.
     
    #populate the ord_temp data frame using a for loop
    for(i in paths$path){
     boom <-  strsplit(i,"/")[[1]][5]
     dat <- h5read(f,i)
     dat$boom <- rep(boom,dim(dat)[1])
     ord_temp <- rbind(ord_temp,dat)
    }

The loop above iterates through the file and grabs the temperature data for each boom in the 1 minute data series for Ordway. It also adds the boom name to the end of the `data.frame` as follows: 

- `for i in path$path`. We have 5 "paths" total - one for each boom: booms 1,2,3,5 and the tower top. NOTE: the boom 4 sensor was not operational when this HDF5 file was created, which is why there is no boom 4 in our list! Thus we will need do iterate through the data 5 times
- `boom <-  strsplit(i,"/")[[1]][5]`: identify the name of the boom for iteration i. 
- `dat <- h5read(f,i)`: read in the data from our hdf5 file (f) for iteration i (whichever iteration in the loop we are on) .
-  `dat$boom <- rep(boom,dim(dat)[1])`: add the boom name as the final column in the dataset - column named "boom"
-  `ord_temp <- rbind(ord_temp,dat)`: append dataset to the end of the data.frame called ord_temp

    EXTRA CREDIT: Modify the loop above so that it adds both the boom name, the site name and the data type (1 minute) as columns in our data frame.

### Cleaning Up Dates
The dates field in our data frame aren't imported by default in "date format". We need to tell R to format the information as a date. Formatting out date fields also allows us to properly label the x axis of our plots. 

	#format the date column as a date field. "TZ:, time zone = Eastern Standard Time
	ord_temp$date <- as.POSIXct(ord_temp$date,format = "%Y-%m-%d %H:%M:%S", tz = "EST")

Now we can make our plot of temperature for all booms on the tower! Notice we are using ggplot to do this.

	ggplot(ord_temp,aes(x=date,y=mean,group=boom,colour=boom))+geom_path()+ylab("Mean temperature") + xlab("Date")+theme_bw()+ggtitle("3 Days of temperature data at Ordway Swisher Biological Station")


![Image]({{ site.baseurl }}/images/HDf5/ordwayPlot.png)

##Data from different sites

Next, let's compare temperature at two different sites: Ordway Swisher Biological Station located in Florida and North Sterling located in Central Colorado. This time we'll plot data averaged every 30 minutes instead of every minute. We'll need to modify our search strings a bit. But we can still re-use most of the code that we just built.

First, let's extract all 30 minute averaged data, for all sites.

	s <- "min_30"
	# Grab the paths for all sites, 30 minute averaged data
	paths <- fiu_struct %>% filter(grepl(s,group), grepl("DATA",otype)) %>% group_by(group) %>% summarise(path = paste(group,name,sep="/"))

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

	temp30_sum <- temp_30 %.% group_by(date,site) %>% summarise(mean = mean(mean))
	
	#Create plot!
	ggplot(temp30_sum,aes(x=date,y=mean,group=site,colour=site)) + geom_path()+ylab("Mean temperature, 30 Minute Average") + xlab("Date")+theme_bw()+ggtitle("Comparison of Ordway-Swisher Biological Station (FL) vs North Sterling (CO)")

![Image]({{ site.baseurl }}/images/HDf5/OrdwaySterling.png)

> Extra Credit: Create a plot of both sites with all booms at each site on the plot.


