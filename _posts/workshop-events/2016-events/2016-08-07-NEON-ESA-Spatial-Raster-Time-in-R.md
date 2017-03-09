---
layout: workshop-event
title: "NEON @ ESA: Work With Spatial Raster Data & Time Series in R"
estimatedTime: 5-hour workshop
date: 2016-08-07
dateCreated: 2016-03-01
lastModified: 2016-03-01
endDate: 2016-08-07
authors: [Megan A. Jones]
tags: []
mainTag: workshop-event
categories: [workshop-event]
packagesLibraries: [raster, rgdal, rasterVis, ggplot2]
description: "This 5-hr workshop, taught at the 2016 meeting of the Ecological
Society of America (ESA) in Ft. Lauderdale, FL, will focus on working with 
spatial time series data in R. Participants will learn to read raster 
metadata and work with and plot raster stacks containing RGB and time 
series data. They will also learn how to automate importing a raster time series
in R."
code1: 
image:
  feature: 
  credit:
  creditlink: 
permalink: /workshop-event/ESA2016-raster-time-workshop/
comments: true 
---

{% include _toc.html %}


This workshop will focus on working with spatial time series data, raster 
GeoTIFF format, in R. The working dataset is derived from remote sensing data. 
Participants will learn how to efficiently explore raster metadata and address 
projection-related issues, how to automate processing a raster time series, and 
how work with raster stacks in support of both RGB and time series data. 

The outcome goal of this workshop is a plot of NDVI over time derived from a 
raster time series that can be used to compare plant phenology at multiple 
sites. We will focus on the `raster`and `rgdal` packages in R. `rasterVis`
will be used to create raster time series plots. 

All materials taught in this workshop were developed in collaborative effort 
between Data Carpentry and the National Ecological Observatory Network (NEON).

### Required Prior Knowledge

The workshop will assume that participants have a basic level of familiarity 
with working with data in R, including installing and loading packages, and data 
import. 

***

This 5-hr workshop will be taught at the 2016 meeting of the Ecological
Society of America (ESA) in Ft. Lauderdale, FL. You must be a registered 
attendee of the conference **and register for this workshop** to participate in 
this workshop. For more information, visit the 
<a href="http://esa.org/ftlauderdale/" target="_blank">ESA 2016 annual meeting website</a>.

<div id="objectives" markdown="1">

## Things You’ll Need For The Workshop

To participant in this workshop, you will need a **laptop** with the most 
current version of R, and preferably RStudio, loaded on your computer. 

For details on setting up RStudio in Mac, PC, or Linux operating systems please
see [the instructions below]({{ site.baseurl }}/workshop-event/ESA2016-raster-time-workshop#additional-set-up-resources).

### Install R Packages

Please have these packages *installed* and *updated* **prior** to the start of 
the workshop.

* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`
* **rasterVis:** `install.packages("rasterVis")`
* **ggplot2:** `install.packages("ggplot2")`

#### Updating R Packages

In RStudio, you can go to `Tools --> Check for package updates` to update 
previously installed packages on your computer.

Or you can use <code>update.packages()</code> to update all packages that are 
installed in R automatically. 

* [More on Packages in R.]({{ site.baseurl }}/R/Packages-In-R/)

### Download Data

{% include/dataSubsets/_data_Airborne-Remote-Sensing.html %}
{% include/dataSubsets/_data_Landsat-NDVI.html %}

Once you have downloaded the data, please set up a "data" directory as a parent 
directory to these three **uncompressed** directories. Set your R working 
directory to this "data" directory **prior** to the beginning of the workshop. 
If you would like further instruction please see the bottom of this page
[for detailed instructions]({{ site.baseurl }}/workshop-event/NEON-ESA-spatial-raster-time-workshop-07Aug16#set-working-directory-to-downloaded-data).  


</div>

### Workshop Instructors
* **[Megan A. Jones](http://www.neonscience.org/about/staff/megan-jones)**; @meganahjones, Staff Scientist/Science Educator; NEON program, Battelle
* **Mike Patterson**; Science Technician & Geospatial Analyst; NEON program, Battelle
* **[Tristan Goulden](http://www.neonscience.org/about/staff/tristan-goulden)**; Associate Scientist, Airborne Platform; NEON program, Battelle

Please get in touch with the instructors prior to the workshop with any questions.

## #WorkWithData Hashtag
  
Please tweet using the hashtag **#WorkWithData** during this workshop!

## Workshop Schedule

**Location**: Ft Lauderdale Convention Center, Rm 317 
Please double check the conference schedule as rooms may change!

Please note that the schedule listed below may change depending upon the pace of
the workshop! 


| Time	| Topic	
|-------------|---------------
| 11:45	| Please come early if you have any setup or installation issues.
| 12:00	| <a href="http://neondataskills.org/R/Introduction-to-Raster-Data-In-R/" target="_blank">Introduction to Working With Raster Data in R</a> 
| 	| <a href="http://neondataskills.org/R/Reproject-Raster-In-R/" target="_blank">When Raster's Don't Line Up: Coordinate Reference System & Reprojection</a> 
| 13:30	|  --------- BREAK 1 --------- 
| 13:45	|  NEON Remote Sensing Data Products Overview
| 14:15	|  <a href="http://www.neondataskills.org/tutorial-series/raster-time-series/" target="_blank">Raster Time Series Data in R: Tutorials 05–07</a>
| 15:00	| --------- BREAK 2 --------- 
| 15:15	|<a href="http://www.neondataskills.org/tutorial-series/raster-time-series/" target="_blank">Raster Time Series Data in R, continued</a> 
| 16:30	| Final Questions & Evaluation
| 16:45	| END with enough time to get to the <a href="http://esa.org/ftlauderdale/plenaries/" target="_blank"> ESA Opening Plenary </a>


## Online Tutorials

All NEON workshops and self-paced tutorials can be accessed via the 
<a href="http://www.neondataskills.org/" target="_blank">NEON
Data Skills portal</a>.

***

## Additional Set Up Resources

### Set Working Directory to Downloaded Data

#### 1) Download Data

First, download the data linked in the blue buttons above. 

* NEON Teaching Data Subset: Airborne Remote Sensing Data
* NEON Teaching Data Subset: Landsat NDVI

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_ZipDownloads.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_ZipDownloads.png"></a>
	 <figcaption> Screenshot of the <b> Data </b> that you should download, prior 
	 to the workshop. (Note: the screenshots show a `NEON-DS-Site-Layout-Files` 
	 folder. This contains vector files we will not be using for this workshop. 
	 You will not be downloading this directory).  Source: National Ecological 
	 Observatory Network (NEON) 
	 </figcaption>
</figure> 

After clicking on the **Download Data** button, the data will automatically 
download to the computer. 

#### 2) Locate .zip file
Second, find the downloaded .zip file. Many browsers default to 
downloading to the **Downloads** directory on your computer. 
Note: You may have previously specified a specific directory (folder) for files
downloaded from the internet, if so, the .zip file will download there.


#### 3) Move to **data** directory
Third, move the data files to a directory called **data** directory within the
**Documents** directory on your computer. 


#### 4) Unzip/uncompress

Fourth, we need to unzip/uncompress the file so that the data files can be 
accessed. Use your favorite tool that can unpackage/open .zip files (e.g.,
winzip, Archive Utility, etc). The files will now be accessible in three directories:

* `NEON-DS-Airborne-Remote-Sensing` 
*  `NEON-DS-Landsat-NDVI`

These directories contain all of the subdirectories and files that
we will use in this workshop. 

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_UnZipped.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_UnZipped.png"></a>
	 <figcaption> Screenshot of the computer's Downloads folder containing the
	 file structure. Source: National Ecological Observatory Network (NEON) 
	 </figcaption>
</figure> 

***

{% include wkSetup/_setup_R_Rstudio.html %}
