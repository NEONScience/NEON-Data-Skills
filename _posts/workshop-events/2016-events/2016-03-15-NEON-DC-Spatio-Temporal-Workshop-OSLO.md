---
layout: workshop-event
title: "NEON/Data Carpentry - Spatio-Temporal Workshop - March 15-16, 2016 in Oslo, Norway"
estimatedTime: 2 Day Workshop
packagesLibraries: []
date: 2016-03-15
dateCreated: 2016-03-01
lastModified: 2016-03-02
startDate: 2016-03-15
endDate: 2016-03-16
authors: [Leah A. Wasser, Michael Heeremans, Anne Claire Fouilloux, Arnstein Orten, Hans Peter Verne]
tags: []
mainTag: workshop-event
categories: [workshop-event]
description: "This two day workshop, taught at the University of Oslo on 
March 15-16, 2016, will cover shell and spatio-temporal data in R."
code1: 
image:
  feature: 
  credit:
  creditlink: 
permalink: /workshop-event/NEON-Data-Carpentry-Spatio-Temporal-Oslo-03-15
comments: true 
---

<a href="http://pad.software-carpentry.org/2016-03-15-oslo-geo" target="_blank" class="btn">Click here to visit workshop Etherpad</a>
<a href="{{ site.baseurl }}/workshop-event/NEON-Data-Carpentry-Spatio-Temporal-Oslo-03-15#workshop-schedule">Click here to view workshop schedule. </a>

<div id="objectives" markdown="1">

# Things You’ll Need To For The Workshop

### Download Data

To be prepared for this workshop, please download the following files in advance:

{% include/dataSubsets/_data_Site-Layout-Files.html %}
{% include/dataSubsets/_data_Airborne-Remote-Sensing.html %}
{% include/dataSubsets/_data_Landsat-NDVI.html %}

***
Optional - you can download the global boundary files below if you wish to follow along 
with the data management lesson on Coordinate Reference Systems.

<a href="http://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-land/" target="_blank"  class="btn btn-success">
Download "land" - Natural Earth Global Continent Boundary Layer</a>

<a href="http://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-graticules/" target="_blank" class="btn btn-success">
Download all Graticules - Natural Earth Global Graticules Layer</a>

***

### Set Working Directory

Once you have downloaded the data, setup your working directory.
<a href="{{ site.baseurl }}/workshop-event/NEON-Data-Carpentry-Spatio-Temporal-Oslo-03-15#set-working-directory-1">Click here to view working directory setup.</a>

****

## Software Installation

Next, you will need:
access to the software described below (R, R studio, required R packages
and Bash). In addition, you will need an up-to-date web browser.
  

### Install R & R Studio

To participate in the workshop, we recommend that you come with **R** and **RStudio** 
installed. <a href = "http://cran.r-project.org/">R</a> is a programming language 
that specializes in statistical computing. It is a powerful tool for exploratory
 data analysis. To interact with R, we STRONGLY recommend 
<a href="http://www.rstudio.com/">RStudio</a>, an interactive development 
environment (IDE). 

#### If You Already Have R / RStudio Installed -- please update

If you already have R / RStudio installed on your laptop, please be sure that
you are running the most current version of R-Studio, R AND all packages that 
we'll be using in the workshop (listed below).

#### If you don't have R / Rstudio installed - Please follow the instructions below:

* <a href="{{ site.baseurl }}/workshop-event/NEON-Data-Carpentry-Spatio-Temporal-Oslo-03-15#R-mac">Mac Installation of R and R studio</a>
* <a href="{{ site.baseurl }}/workshop-event/NEON-Data-Carpentry-Spatio-Temporal-Oslo-03-15#R-windows">Windows Installation of R and R studio</a>
* <a href="{{ site.baseurl }}/workshop-event/NEON-Data-Carpentry-Spatio-Temporal-Oslo-03-15#R-linux">Linux Installation of R and R studio</a>


**** 

## Install R Packages

You can chose to install each library individually if you already have some installed.

* **raster:** `install.packages("raster")`
* **rgdal (windows):** `install.packages("rgdal")`
* **rgdal (mac):** `install.packages("rgdal",configure.args="--with-proj-include=/Library/Frameworks/PROJ.framework/unix/include --with-gdal-config=/Library/Frameworks/GDAL.framework/unix/bin/gdal-config --with-proj-lib=/Library/Frameworks/PROJ.framework/unix/lib")`
* **rasterVis:** `install.packages("rasterVis")`
* **ggplot2:** `install.packages("ggplot2")`
* **sp:** `install.packages("sp")`
*  **rgeos** `install.packages`("rgeos")

OPTIONAL installation
If you want to work through the metadata lesson which includes a section on the Ecological Metadata Language (EML), 
please install the following:

* **devtools:** `install.packages("devtools")`

NOTE: You have to run the devtools library `library(devtools)` first, and then `install_github` will work.
the EML package is under development which is why the install occurs from GitHub and not can!

* **eml** `install_github("ropensci/EML", build=FALSE, dependencies=c("DEPENDS", "IMPORTS"))`





### GDAL installation for MAC

You may need to install GDAL in order for rgdal to work properly. <a href="https://www.youtube.com/watch?v=G6r46OhNlqw" target="_blank">Click here to watch a video on installing gdal
using homebrew on your mac.</a> <a href="http://www.kyngchaos.com/software/frameworks" target="_blank">Or, you can visit THIS LINK to install GDAL 1.11 complete.</a>

### Make Sure R Packages Are Current 

In RStudio, you can go to `Tools --> Check for package updates` to update already
installed libraries on your computer! Or, you can use <code>update.packages()</code> 
to update all packages that are installed in R automatically. 

[More on Packages in R.]({{site.baseurl}}R/Packages-In-R/)

**** 

## Install Bash

Bash is a commonly-used shell that gives you the power to do simple
tasks more quickly.
  
 We maintain a list of common issues that occur during installation as a reference for instructors
  that may be useful on the
  <a href = "https://github.com/swcarpentry/workshop-template/wiki/Configuration-Problems-and-Solutions" target="_blank">Configuration Problems and Solutions wiki page</a>.
  
#### If you don't have Bash installed - Please follow the instructions below:

* <a href="{{ site.baseurl }}/workshop-event/NEON-Data-Carpentry-Spatio-Temporal-Oslo-03-15#shell-macosx">Mac Installation of Bash</a>
* <a href="{{ site.baseurl }}/workshop-event/NEON-Data-Carpentry-Spatio-Temporal-Oslo-03-15#shell-windows">Windows Installation of Bash</a>
* <a href="{{ site.baseurl }}/workshop-event/NEON-Data-Carpentry-Spatio-Temporal-Oslo-03-15#shell-linux">Linux Installation of Bash</a>

</div>



{% include/wkSetup/_setup_R_Rstudio.html %}

***

{% include/wkSetup/_setup_bash.html %}

***

### Set Working Directory


#### 1) Download Data

First, download the data linked in the blue buttons above. 

* NEON Teaching Data Subset: Site Layout Shapefiles
* NEON Teaching Data Subset: Airborne Remote Sensing Data
* NEON Teaching Data Subset: Landsat NDVI


<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_ZipDownloads.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_ZipDownloads.png"></a>
	 <figcaption> Screenshot of the <b> Data </b> that you should download, prior to the workshop. 
	 Source: National Ecological Observatory Network
	 (NEON) 
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
**Documents** directory on your computer. If you have other files in this data
directory, you may decide to create a sub-directory in your data directory called 
spatial-workshop. However you set it up, your final working directory should look 
similar to the graphic below. 

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/spatial-file-structure.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/spatial-file-structure.png"></a>
	 <figcaption> Screenshot of the computer's Downloads folder containing the
	 new <b>NEONDSMetTimeSeries.zip </b> file. Source: National Ecological
	 Observatory Network (NEON) 
	 </figcaption>
</figure> 

Note that the "Global/boundaries" directory is optional!
If you downloaded the optional global layers, we suggestion you place them in a directory
called Global/boundaries.

#### 4) Unzip/uncompress

Fourth, we need to unzip/uncompress the file so that the data files can be 
accessed. Use your favorite tool that can unpackage/open .zip files (e.g.,
winzip, Archive Utility, etc). The files will now be accessible in three directories:

* `NEON-DS-Airborne-Remote-Sensing` 
*  `NEON-DS-Landsat-NDVI`
*  `NEON-DS-Site-Layout-Files`

These directories contain all of the subdirectories and files that
we will use in this workshop. 



We will set up an R-Studio project within this working directory. <a href="https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects" target="_blank">Read more about R-Studio projects, here.</a> In R studio, your working directory space will look like this:

<figure>
    <a href="{{ site.baseurl }}/images/set-working-dir/r-studio-spatial-files.png">
    <img src="{{ site.baseurl }}/images/set-working-dir/r-studio-spatial-files.png"></a>
    <figcaption>Your working directory in R should look like the above image. It is OK if you don't have the "Global" directory
    setup. The data in this directory is OPTIONAL to download. </figcaption>
</figure>

NOTE: we will setup an OSLO2015.Rproj file together at the beginning of the workshop.

***

### Workshop Instructors
* **[Leah Wasser](http://www.neoninc.org/about/staff/leah-wasser)**; @leahawasser, Supervising Scientist, NEON, Inc 
* **Michael Heeremans**
* **Anne Claire Fouilloux**
* **Arnstein Orten**
* **Hans Peter Verne**

Please get in touch with the instructors prior to the workshop with any questions.

## #WorkWithData Hashtag
  
Please tweet using the hashtag:
  "#WorkWithData" during this workshop!



## Workshop SCHEDULE

Please note that the schedule listed below may change depending upon the pace of the workshop! 

## Day One

| Time        | Topic         | Instructor | 
|-------------|---------------|------------|
| 8:00     | Please come early if you have any setup / installation issues |          |
| 9:00     | <a href="{{ site.baseurl }}" target="_blank">The Shell - command line for data exploration</a> | Michael, Anne          |
| 10:30 | ------- Coffee / Tea BREAK ------- |      |
| 10:45 | <a href="http://neon-workwithdata.github.io/NEON-R-Spatio-Temporal-Data-and-Management-Intro/R/spatial-data-formats" target="_blank">Data Management: Spatial Data Formats </a> | Michael    |
| 11:30 | <a href="http://neon-workwithdata.github.io/NEON-R-Spatio-Temporal-Data-and-Management-Intro/R/intro-to-coordinate-reference-systems" target="_blank">Data Management: Coordinate Reference Systems</a> | Michael     |
| 12:00 - 1:00 PM     | Lunch |          |
| 1:00     | <a href="http://neondataskills.org/tutorial-series/vector-data-series/" target="_blank">Introduction to Vector Data in R</a> | Leah         |
| 3:00 | ------- BREAK ------- |      |
| 3:15     |<a href="http://neondataskills.org/tutorial-series/vector-data-series/" target="_blank">Introduction to Vector Data in R</a> | Leah         |
| 4:45     | Wrap-Up Day 1 |       |

## Day Two

| Time        | Topic         | Instructor | 
|-------------|---------------|------------|
| 9:00     | Questions From Previous Day |          |
| 9:15     | <a href="{{ site.baseurl }}/tutorial-series/raster-data-series/" target="_blank">Getting Started with Raster Data in R</a> | Leah          |
| 10:30 | ------- BREAK ------- |      |
| 10:45 | <a href="{{ site.baseurl }}/tutorial-series/raster-data-series/" target="_blank">Getting Started with Raster Data in R</a> 
| 12:00 - 1:00 PM     | Lunch  |          |
Raster Data in R</a> | Leah     |
| 1:00 - 1:30 PM     | <a href="http://neon-workwithdata.github.io/NEON-R-Spatio-Temporal-Data-and-Management-Intro/R/metadata-file-formats-structures" target="_blank">Data Management: Understanding Metadata  </a> |    Michael     |
| 1:00     | <a href="{{ site.baseurl }}/tutorial-series/raster-time-series/" target="_blank">Raster Time Series Data in R</a> | Leah         |
| 3:00 | ------- BREAK ------- |      |
| 3:15     | <a href="{{ site.baseurl }}/tutorial-series/raster-time-series/" target="_blank">Raster Time Series Data in R</a> | Leah         |
| 4:45     | Wrap-Up Day Two!</a> |       |
