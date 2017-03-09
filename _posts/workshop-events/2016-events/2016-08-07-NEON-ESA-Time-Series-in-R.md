---
layout: workshop-event
title: "NEON @ ESA: Work with Ecological Time Series Data in R"
estimatedTime: 3.5-hour workshop
date: 2016-08-07
dateCreated: 2016-03-01
lastModified: 2016-03-01
endDate: 2016-08-07
authors: [Megan A. Jones]
tags: []
mainTag: workshop-event
categories: [workshop-event]
packagesLibraries: [ggplot2, lubridate, zoo, reshape2, gridExtra, scales]
description: "This 3.5-hr workshop, taught at the 2016 meeting of the Ecological
Society of America (ESA) in Ft. Lauderdale, FL, will cover how to open, work 
with and plot tabular (.csv format) time series data in R. Additional topics 
include working with time and date classes (e.g., POSIXct, POSIXlt, and Date), 
subsetting time series data by date and time, and created facetted or tiled 
sets of plots."
code1: 
image:
  feature: 
  credit:
  creditlink: 
permalink: /workshop-event/ESA2016-time-series-workshop/
comments: true 
---

{% include _toc.html %}

This 3.5-hr workshop, taught at the 2016 meeting of the Ecological
Society of America (ESA) in Ft. Lauderdale, FL, will cover how to open, work 
with and plot tabular (.csv format) time-series data in R. Additional topics 
include working with time and date classes (e.g., POSIXct, POSIXlt, and Date), 
subsetting time series data by date and time, and created facetted or tiles 
sets of plots. 

All materials taught in this workshop were developed in collaborative effort 
between Data Carpentry and the National Ecological Observatory Network (NEON).

### Required Prior Knowledge
The workshop will assume that participants have a basic level of familiarity 
with working with data in R, including installing and loading packages and data 
import. 

***

This workshop will be taught at the 2016 meeting of the Ecological
Society of America (ESA) in Ft. Lauderdale, FL. You must be a registered 
attendee of the conference **and register for this workshop** to participate in 
this workshop. For more information, visit the 
<a href="http://esa.org/ftlauderdale/" target="_blank">ESA 2016 annual meeting website</a>.

<div id="objectives" markdown="1">

## Things You’ll Need For The Workshop

To participant in this workshop, you will need a **laptop** with the most 
current version of R, and preferably RStudio, loaded on your computer. 

For details on setting up RStudio in Mac, PC, or Linux operating systems, please
see [the instructions below]({{ site.baseurl }}/workshop-event/ESA2016-time-series-workshop#additional-set-up-resources).

### Install R Packages

Please have these packages *installed* and *updated* **prior** to the start of 
the workshop.

* **ggplot2:** `install.packages("ggplot2")`
* **lubridate:** `install.packages("lubridate")`
* **scales:** `install.packages("scales")`
* **gridExtra:** `install.packages("gridExtra")`
* **reshape2:** `install.packages("reshape2")`
* **zoo:** `install.packages("zoo")`

#### Updating R Packages

In RStudio, you can go to `Tools --> Check for package updates` to update 
previously installed packages on your computer.

Or you can use <code>update.packages()</code> to update all packages that are 
installed in R automatically. 

* [More on Packages in R.]({{ site.baseurl }}/R/Packages-In-R/)

### Download Data

{% include/dataSubsets/_data_Met-Time-Series.html %}

Once you have downloaded the data, please set up a "data" directory as a parent 
directory to these three **uncompressed** directories. Set your R working 
directory to this "data" directory **prior** to the beginning of the workshop. 
If you would like further instruction please see the bottom of this page
[for detailed instructions]({{ site.baseurl }}/workshop-event/ESA2016-time-series-workshop#additional-set-up-resources).

</div>

### Workshop Instructors

* **[Megan A. Jones](http://www.neonscience.org/about/staff/megan-jones)**; @meganahjones, Staff Scientist/Science Educator; NEON program, Battelle
* **[Samantha Weintraub](http://www.neonscience.org/about/staff/samantha-weintraub)**; @sr_weino, Staff Scientist, Terrestrial Biogeochemist; NEON program, Battelle 

Please get in touch with the instructors prior to the workshop with any 
questions.

## #WorkWithData Hashtag
Please tweet using the hashtag **#WorkWithData** during this workshop!

## Workshop Schedule


**Location**: Ft Lauderdale Convention Center, Rm 316 
Please double check the conference schedule as rooms may change!

Please note that the schedule listed below may change depending upon the pace of
the workshop! 

| Time	| Topic	| 
|-------------|---------------
| 7:45	| Please come early if you have any setup or installation issues
| 8:00	| <a href="{{ site.baseurl }}/R/brief-tabular-time-series-qplot/" target="_blank">Intro to Time Series Data in R</a> 
| 9:00	| <a href="{{ site.baseurl }}/R/time-series-convert-date-time-class-POSIX/" target="_blank">Dealing With Dates & Times in R</a> 
| 9:30	| --------- BREAK --------- |
| 9:45	| <a href="{{ site.baseurl }}/R/subset-data-and-no-data-values/" target="_blank">NoData Values & Subsetting by Date</a>
| 10:10	| <a href="{{ site.baseurl }}/R/time-series-plot-ggplot/" target="_blank">Time Series Plots with ggplot2</a>
| 10:40	| <a href="{{ site.baseurl }}/R/time-series-plot-facets-ndvi/" target="_blank">Multi-panel Plots with ggplot Facets</a>
| 11:15	| Additional Questions & Evaluation
| 11:30	| End


## Online Tutorials

All NEON workshops and self-paced tutorials can be accessed via the [NEON
Data Skills portal]({{ site.baseurl }}/). The materials in this workshop will 
parallel those presented in the 
<a href="({{ site.baseurl}}/tutorial-series/tabular-time-series/" target="_blank"> Introduction to Working With Time Series Data in Text Formats in R series. 
***

## Additional Set Up Resources

### Set Working Directory to Downloaded Data


#### 1) Download Data

First, download the data linked to the blue buttons in the Download Data section. 

* NEON Teaching Data Subset: Meteorological Data for Harvard Forest

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/downloads_folder.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/downloads_folder.png"></a>
	 <figcaption> Screenshot of the computer's Downloads folder containing the
	 new <b>NEONDSMetTimeSeries.zip </b> file. Source: National Ecological
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
winzip, Archive Utility, etc). The files will now be accessible in the directory:

* `NEON-DS-Met-Time-Series` 

These directories contain all of the subdirectories and files that
we will use in this workshop. 

Your directory should now look like this with the exception that you will NOT 
have the `NEON-DS-Site-Layout-Files` directory: 

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/neon-documents-contents.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/neon-documents-contents.png"></a>
	 <figcaption> Screenshot of the <b>neon</b> directory with the nested 
	 <b>Documents</b>, <b>data</b>, <b>NEON-DS-Met-Time-Series</b>, and other 
	 directories. Source: National Ecological Observatory Network
	 (NEON) 
	 </figcaption>
</figure> 

***

{% include wkSetup/_setup_R_Rstudio.html %}