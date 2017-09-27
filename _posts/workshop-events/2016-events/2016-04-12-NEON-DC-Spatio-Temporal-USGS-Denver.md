---
layout: workshop-event
title: "NEON/Data Carpentry - Spatio-Temporal Workshop"
estimatedTime: 2 Day Workshop
packagesLibraries: [raster, sp, rgdal, rgeos, rasterVis, ggplot2]
date: 2016-04-12
dateCreated: 2016-03-31
lastModified: 2016-04-01
startDate: 2016-04-12
endDate: 2016-04-13
authors: [Leah A. Wasser, Natalie Robinson, Megan A. Jones]
tags: []
mainTag: workshop-event
categories: [workshop-event]
description: "This two-day workshop, taught at the USGS National Training Center
in Denver, CO on 12-13 April 2016, will cover working with spatio-temporal data 
in R."
code1: 
image:
  feature: 
  credit:
  creditlink: 
permalink: /workshop-event/NEON-DC-Spatial-04-12-2016
comments: true 
---

## Quick Links


* [ Workshop Schedule ]({{ site.baseurl }}/workshop-event/NEON-DC-Spatial-04-12-2016#workshop-schedule)
* <a href="http://pad.software-carpentry.org/gqkzFs2w9Q" target="_blank">Workshop Etherpad</a>

<div id="objectives" markdown="1">

## Things You’ll Need To For The Workshop

To participate in this workshop, you will need:

* A **laptop** with the current version of R, and preferably RStudio, loaded. 
* An up-to-date web browser.

For step-by-step details on installing or setting up R or RStudio in Mac, PC,
or Linux Operating Systems, please see 
[the details at the bottom of this page]({{ site.baseurl }}/workshop-event/NEON-DC-Spatial-04-12-2016#additional-set-up-information). 

If you already have R & RStudio installed on your laptop, please be sure that
you are running the most current version of RStudio, R and all packages that 
we'll be using in the workshop (listed below).

### Download Data

To be prepared for this workshop, please download the following files in advance:

{% include/dataSubsets/_data_Site-Layout-Files.html %}
{% include/dataSubsets/_data_Airborne-Remote-Sensing.html %}
{% include/dataSubsets/_data_Landsat-NDVI.html %}


**Optional:** Download these global boundary files if you wish to 
follow along with the Intro to Coordinate Reference System Lesson. 
NOTE: Some of the contents of this code is not explicitly taught in the workshop. It is
used to demonstrate differences between different CRS' and to provide code examples for
those who may be interested in mapping using GGPLOT in the future. 

<a href="http://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-land/" target="_blank"  class="btn btn-success">
Download "land" - Natural Earth Global Continent Boundary Layer</a>
<a href="http://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-graticules/" target="_blank" class="btn btn-success">
Download all Graticules - Natural Earth Global Graticules Layer</a>


### Set Working Directory

Once you have downloaded the data, set the R working directory to the
uncompressed files.
[View complete directions and images of the R working directory setup here.]({{ site.baseurl }}/workshop-event/NEON-DC-Spatial-04-12-2016#set-r-working-directory)

****

## Install R Packages

You can chose to install each package individually if you already have some 
installed.

* **raster:** `install.packages("raster")`
* **rasterVis:** `install.packages("rasterVis")`
* **ggplot2:** `install.packages("ggplot2")`
* **sp:** `install.packages("sp")`
* **rgeos:** `install.packages ("rgeos")`
* **rgdal (Windows):** `install.packages("rgdal")`
* **rgdal (Mac):** `install.packages("rgdal",configure.args="--with-proj-include=/Library/Frameworks/PROJ.framework/unix/include --with-gdal-config=/Library/Frameworks/GDAL.framework/unix/bin/gdal-config --with-proj-lib=/Library/Frameworks/PROJ.framework/unix/lib")`

#### GDAL installation for MAC

You may need to install GDAL in order for `rgdal` to work properly. 
<a href="https://www.youtube.com/watch?v=G6r46OhNlqw" target="_blank">Click here to watch a video on installing GDAL using homebrew on your Mac.</a>
<a href="http://www.kyngchaos.com/software/frameworks" target="_blank">Or, you can visit this link to install GDAL 1.11 complete.</a>

**Optional:** The metadata tutorial, which includes a section on the 
Ecological Metadata Language (EML) is presented with a focus on the conceptual 
understanding of metadata and includes a demonstration of the `eml` package in 
`R`. If you wish to follow along with the code, please install the following:

* **devtools:** `install.packages("devtools")`
* **eml:** `install_github("ropensci/EML", build=FALSE, dependencies=c("DEPENDS", "IMPORTS"))`

NOTE: You have to run the `devtools` package (`library(devtools)`) first, and
then `install_github()` will work. The `eml` package is under development which 
is why the install occurs from GitHub and not CRAN!


### Make Sure R Packages Are Current 

In RStudio, you can go to `Tools --> Check for package updates` to update 
already installed packages on your computer! Or, you can use 
`update.packages()` to update all packages that are installed in R 
automatically. 

* [More on Packages in R.]({{site.baseurl}}/R/Packages-In-R/)


</div>


### Workshop Instructors
* **Leah Wasser**; 
@leahawasser; Supervising Scientist, NEON 
* **[Megan A. Jones](http://www.neonscience.org/about/staff/megan-jones)**; 
@meganahjones; Staff Scientists/Science Educator, NEON
* **[Natalie Robinson](http://www.neonscience.org/about/staff/natalie-robinson)**; 
Staff Scientist, NEON

Please get in touch with the instructors prior to the workshop with any 
questions.

## #WorkWithData Hashtag

Please tweet using the hashtag **#WorkWithData** during this workshop!


## Workshop Schedule

Please note that the schedule listed below may change depending upon the 
pace of the workshop! 

### Day One

| Time        | Topic         |
|-------------|---------------|
| 8:00     | Please come early if you have any setup or installation problems |
| 9:00     | Geospatial Data Management - Intro to Geospatial Concepts
|   | <a href="http://neon-workwithdata.github.io/NEON-R-Spatio-Temporal-Data-and-Management-Intro/R/spatio-temporal-research-questions" target="_blank">Answer a Spatio-temporal Research Question with Data - Where to Start? </a> |
|   | <a href="http://neon-workwithdata.github.io/NEON-R-Spatio-Temporal-Data-and-Management-Intro/R/spatial-data-formats" target="_blank">Data Management: Spatial Data Formats </a> |
|   | <a href="http://neon-workwithdata.github.io/NEON-R-Spatio-Temporal-Data-and-Management-Intro/R/metadata-file-formats-structures" target="_blank">Data about Data -- Intro to Metadata Formats & Structure </a> |
| 10:30 | --------- BREAK --------- |
| 10:45 | <a href="http://neon-workwithdata.github.io/NEON-R-Spatio-Temporal-Data-and-Management-Intro/R/intro-to-coordinate-reference-systems" target="_blank">Data Management: Coordinate Reference Systems</a> |
| 12:00 - 1:00 |  --------- Lunch ---------| 
| 1:00     | <a href="{{ site.baseurl }}/tutorial-series/vector-data-series/" target="_blank">Vector Data in R</a> |
|   | <a href="{{ site.baseurl }}/R/open-shapefiles-in-R/" target="_blank">Open and Plot Shapefiles in R - Getting Started with Point, Line and Polygon Vector Data</a>
|   | <a href="{{ site.baseurl }}/R/shapefile-attributes-in-R/" target="_blank">Explore Shapefile Attributes & Plot Shapefile Objects by Attribute Value in R</a>
|   | <a href="{{ site.baseurl }}/R/plot-shapefiles-in-R/" target="_blank">Plot Multiple Shapefiles and Create Custom Legends in Base Plot in R</a>
| 2:30 | --------- BREAK --------- |
| 2:45     | Vector Data in R, continued|
|   | <a href="{{ site.baseurl }}/R/vector-data-reproject-crs-R/" target="_blank">When Vector Data Don't Line Up - Handling Spatial Projection & CRS in R</a>
|   | <a href="{{ site.baseurl }}/R/csv-to-shapefile-R/" target="_blank">Convert from .csv to a Shapefile in R</a>
| 4:15     | Wrap-Up Day 1 |

### Day Two

| Time        | Topic         |
|-------------|---------------|
| 9:00     | Questions From Day One|
| 9:15     | <a href="{{ site.baseurl }}/tutorial-series/raster-data-series/" target="_blank">Getting Started with Raster Data in R </a> |
|   | <a href="{{ site.baseurl }}/R/Introduction-to-Raster-Data-In-R/" target="_blank">Intro to Raster Data in R </a> |
|   | <a href="{{ site.baseurl }}/R/Plot-Rasters-In-R/" target="_blank">Plot Raster Data in R </a> |
| 10:30    | --------- BREAK --------- |
| 10:45    | Getting Started with Raster Data in R, continued |
|   | <a href="{{ site.baseurl }}/R/Reproject-Raster-In-R/" target="_blank">When Rasters Don't Line Up - Reproject Raster Data in R </a> |
|   | <a href="{{ site.baseurl }}/R/Raster-Calculations-In-R/" target="_blank">Raster Calculations in R - Subtract One Raster from Another and Extract Pixel Values For Defined Locations </a> |
|   | <a href="{{ site.baseurl }}/R/crop-extract-raster-data-R/" target="_blank">Crop Raster Data and Extract Summary Pixels Values From Rasters in R </a> |
| 12:00 - 1:00  | --------- Lunch ---------|  
| 1:00     | Multi-band Raster & Raster Time Series Data in R |
|   | <a href="{{ site.baseurl }}/R/Multi-Band-Rasters-In-R/" target="_blank">Work With Multi-Band Rasters - Image Data in R </a> |
|   | <a href="{{ site.baseurl }}/R/Raster-Times-Series-Data-In-R/" target="_blank">Raster Time Series Data in R </a> |
|   | <a href="{{ site.baseurl }}/R/Plot-Raster-Times-Series-Data-In-R/" target="_blank">Plot Raster Time Series Data in R Using RasterVis and Levelplot </a> |
|   | <a href="{{ site.baseurl }}/R/Extract-NDVI-From-Rasters-In-R/" target="_blank">Extract NDVI Summary Values from a Raster Time Series </a> |
| 2:30 | --------- BREAK --------- |
| 2:45     | Multi-band Raster & Raster Time Series Data in R, continued |
| 4:15     | Wrap-Up Day Two! |


## Collaborative Note Taking

Throughout the course, we will use the Etherpad, to share links and take group notes about
various topics. 

* <a href="http://pad.software-carpentry.org/gqkzFs2w9Q" target="_blank">NEON/DC USGS Spatio-Temporal Workshop Etherpad</a>

***

## Additional Set Up Information

### Install R & R Studio

To participate in the workshop, we recommend that you come with **R** and
**RStudio** installed. 
<a href = "http://cran.r-project.org/" target="_blank">R</a> is a programming language 
that specializes in statistical computing. It is a powerful tool for exploratory
data analysis. To interact with R, we **strongly** recommend 
<a href="http://www.rstudio.com/" target="_blank">RStudio</a>, an interactive development 
environment (IDE). 

#### If You Don't Have R or Rstudio Installed - Please Follow These Instructions:

* <a href="{{ site.baseurl }}/workshop-event/NEON-DC-Spatial-04-12-2016#R-mac">Mac Installation of R and RStudio</a>
* <a href="{{ site.baseurl }}/workshop-event/NEON-DC-Spatial-04-12-2016#R-windows">Windows Installation of R and RStudio</a>
* <a href="{{ site.baseurl }}/workshop-event/NEON-DC-Spatial-04-12-2016#R-linux">Linux Installation of R and RStudio</a>


#### If You Already Have R & RStudio Installed -- Please Update

If you already have R & RStudio installed on your laptop, please be sure that
you are running the most current version of R-Studio, R *and* all packages that 
we'll be using in the workshop (listed below).


{% include/wkSetup/_setup_R_Rstudio.html %}


***

### Set R Working Directory

#### 1) Download Data

First, download the data linked to from the blue buttons in the grey box above. 

* NEON Teaching Data Subset: Site Layout Shapefiles
* NEON Teaching Data Subset: Airborne Remote Sensing Data
* NEON Teaching Data Subset: Landsat NDVI

After clicking on the **Download Data** button, the data will automatically 
download to the computer. 

Note: If you choose to download the optional data do this at the same time and
include those files in the working directory that we are setting up here. 

#### 2) Locate .zip file
Second, find the downloaded .zip file. Many browsers default to 
downloading to the **Downloads** directory on your computer. 
Note: You may have previously specified a specific directory (folder) for files
downloaded from the internet, if so, the .zip file will download there.

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_ZipDownloads.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_ZipDownloads.png"></a>
	 <figcaption> Screenshot of the <b> Data </b> that you should download prior to the workshop. 
	 Source: National Ecological Observatory Network (NEON) 
	 </figcaption>
</figure> 

#### 3) Move to **data** directory
Third, create a directory (folder) called **data** within the
**Documents** directory on your computer. Move the data files to this **data** 
directory.  

#### 4) Unzip/uncompress

Fourth, we need to unzip/uncompress the file so that the data files can be 
accessed. Use your favorite tool that can unpackage/open .zip files (e.g.,
winzip, Archive Utility, etc). The files will now be accessible in three 
directories:

*  `NEON-DS-Airborne-Remote-Sensing` 
*  `NEON-DS-Landsat-NDVI`
*  `NEON-DS-Site-Layout-Files`

These directories contain all of the subdirectories and files that we will use
in this workshop. 

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_UnZipped.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_UnZipped.png"></a>
	 <figcaption>  </b> Screenshot showing all directoires needed for the 
	 workshop. If you choose to set up the directories differently you will need
	 to adjust the file paths used in the lessons as necessary. 
	 Source: National Ecological Observatory Network (NEON) 
	 </figcaption>
</figure> 


We will set up an RStudio project within this working directory. 
<a href="https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects" target="_blank">Read more about R-Studio projects, here.</a>
In RStudio, your working directory space will look like this:

<figure>
    <a href="{{ site.baseurl }}/images/set-working-dir/RStudioEnvironment_SpatioTemporalWorkshop.png">
    <img src="{{ site.baseurl }}/images/set-working-dir/RStudioEnvironment_SpatioTemporalWorkshop.png"></a>
    <figcaption>Your working directory in RStudio should look like the above 
    image. 
    </figcaption>
</figure>


***
