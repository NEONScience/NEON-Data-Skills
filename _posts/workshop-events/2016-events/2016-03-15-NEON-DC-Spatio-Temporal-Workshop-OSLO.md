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


<div id="objectives" markdown="1">

## Things You’ll Need To For The Workshop

To participant in this workshop, you will need the most current version of R, and 
preferably RStudio, loaded on your computer.

### Install R Packages

You can chose to install each library individually if you already have some installed.

In RStudio, you can go to `Tools --> Check for package updates` to update already
installed libraries on your computer!

* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`
* **rasterVis:** `install.packages("rasterVis")`
* **ggplot2:** `install.packages("ggplot2")`
* **sp:** `install.packages("sp")`


### Make Sure R Packages Are Current 

You can use <code>update.packages()</code> to update all packages that are 
installed in R automatically. 

[More on Packages in R.]({{site.baseurl}}R/Packages-In-R/)


### Download Data

{% include/dataSubsets/_data_Site-Layout-Files.html %}
{% include/dataSubsets/_data_Airborne-Remote-Sensing.html %}
{% include/dataSubsets/_data_Landsat-NDVI.html %}

*****

### Setup RStudio 

To participate in the workshop, we recommend that you come with R and RSTUDIO 
installed. <a href = "http://cran.r-project.org/">R</a> is a programming language 
that specializes in statistical computing. It is a powerful tool for exploratory
 data analysis. To interact with R, we STRONGLY recommend 
<a href="http://www.rstudio.com/">RStudio</a>, an interactive development 
environment (IDE). 

#### Windows R / RStudio Setup

*  Download R from
      <a href="http://cran.r-project.org/bin/windows/base/release.htm">here</a>
* Run the .exe file that was just downloaded
* Go to the <a href="http://www.rstudio.com/ide/download/desktop">RStudio Download page</a>
* Under <i>Installers</i> select <b>RStudio 0.98.1103 - Windows XP/Vista/7/8</b>
* Double click the file to install it


Once R and R studio are installed, open RStudio to make sure it works and you don't get any error messages.

#### MAC R / RStudio Setup


*If your Mac is set up for UiO use, you can install R from 
    <a href="https://www.uio.no/tjenester/it/maskin/macosx/drift/munki-overview.html">Managed Software Center</a>
  
* Go to <a href=http://cran.r-project.org>CRAN</a> and click on <i>Download
R for (Mac) OS X</i>
* Select the .pkg file for the version of OS X that you have and the file
will download.
* Double click on the file that was downloaded and R will install
* Go to the <a href="http://www.rstudio.com/ide/download/desktop">RStudio Download page</a>
* Under <i>Installers</i> select <b>RStudio 0.98.1103 - Mac OS X 10.6+ (64-bit)</b> to download it.
* Once it's downloaded, double click the file to install it

Once R and R studio are installed, open RStudio to make sure it works and you don't get any error messages.


#### Linux R / RStudio Setup

* R is available through most Linux package managers. 
You can download the binary files for your distribution
        from <a href="http://cran.r-project.org/index.html">CRAN</a>. Or
        you can use your package manager (e.g. for Debian/Ubuntu
        run <code>sudo apt-get install r-base</code> and for Fedora run
        <code>sudo yum install R</code>). 
* To install RStudi, go to the <a href="http://www.rstudio.com/ide/download/desktop">RStudio Download page</a>
* Under <i>Installers</i> select the version for your distribution.
* Once it's downloaded, double click the file to install it

Once R and R studio are installed, open RStudio to make sure it works and you don't get any error messages.


### If You Already Have R / RStudio -- please update

If you already have R / RStudio installed on your laptop, please be sure that
you are running the most current version of R-Studio, R AND all packages that 
we'll be using in the workshop (listed below).

</div>

### Setup 

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
**Documents** directory on your computer. 

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_UnZipped.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/Raster_Vector_UnZipped.png"></a>
	 <figcaption> Screenshot of the computer's Downloads folder containing the
	 new <b>NEONDSMetTimeSeries.zip </b> file. Source: National Ecological
	 Observatory Network (NEON) 
	 </figcaption>
</figure> 

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
    <a href="{{ site.baseurl }}/images/workshops/ESA2015_RStudio_Directory.png"><img src="{{ site.baseurl }}/images/workshops/ESA2015_RStudio_Directory.png"></a>
    <figcaption>Your working directory in R should look like the above image. NOTE: we will setup the ESA2015.Rproj file together at the beginning of the workshop.</figcaption>
</figure>


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