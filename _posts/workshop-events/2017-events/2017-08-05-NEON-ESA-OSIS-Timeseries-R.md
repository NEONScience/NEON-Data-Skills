---
layout: workshop-event
title: "NEON @ ESA: Working with Time Series in R using NEON Data"
estimatedTime: 5-hour workshop
date: 2017-08-06
dateCreated: 2017-02-28
lastModified: 2017-02-28
startDate: 
endDate: 2017-08-06
authors: [Megan A. Jones]
tags: []
mainTag: workshop-event
categories: [workshop-event]
packagesLibraries: 
description: "This 5-hr workshop is taught at the 2017 meeting of the Ecological
Society of America (ESA) in Portland, OR. Learn fundamental skills in R 
needed to work with and plot time series data in text format including data.frames, 
converting text format timestamps to an R date or datetime (e.g. POSIX) class, 
and aggregating data across different time scales (e.g. hourly vs month). "
code1: 
image:
  feature: 
  credit:
  creditlink: 
permalink: /workshop-event/ESA2017-NEON-timeseries-workshop/
comments: true 
---

{% include _toc.html %}

The temporal scale of ecological research is expanding given increased 
continental and global availability of time series data coming from long term 
data collection efforts such as NEON, LTER and Fluxnet. Given increased data 
availability, there is a need to implement efficient, well-documented and 
reproducible workflows in tools like R. 

This workshop will teach participants how to import, manipulate, format and plot 
time series data stored in .csv format in R while working with NEON data. We 
will work with temperature and phenology data to explore working with and 
visualizing data with different time scale intervals. Key skills learned will 
include:  

1. working with data.frames in R, 
2. converting timestamps stored as text strings to R date or datetime (e.g. POSIX) classes, 
3. aggregating data across different time scales (day vs month) and 
4. plotting time series data. 

### Required Prior Knowledge

The workshop will assume that participants have a basic level of familiarity 
with working with data in R, including installing and loading packages, and data 
import. 

***

This 5-hr workshop will be taught at the 2017 meeting of the Ecological
Society of America (ESA) in Portland, OR. You must be a registered 
attendee of the conference **and register for this workshop with your ESA 
registration** to participate in this workshop. For more information, visit the 
<a href="http://www.esa.org/portland/" target="_blank">ESA 2017 annual meeting website</a>.

<div id="objectives" markdown="1">

## Things You’ll Need For The Workshop

To participant in this workshop, you will need a **laptop** with the most 
current version of R, and preferably RStudio, loaded on your computer. 

For details on setting up RStudio in Mac, PC, or Linux operating systems please
see [the instructions below]({{ site.baseurl }}/workshop-event/ESA2016-raster-time-workshop#additional-set-up-resources).

### Install R Packages

Please have these packages *installed* and *updated* **prior** to the start of 
the workshop.

TBD: Workshop materials will be posted by July 2017

#### Updating R Packages

In RStudio, you can go to `Tools --> Check for package updates` to update 
previously installed packages on your computer.

Or you can use `update.packages()` to update all packages that are 
installed in R automatically. 

* [More on Packages in R.]({{ site.baseurl }}/R/Packages-In-R/)

### Download Data

TBD: Workshop materials will be posted by July 2017

Once you have downloaded the data, please set up a "data" directory as a parent 
directory to these three **uncompressed** directories. Set your R working 
directory to this "data" directory **prior** to the beginning of the workshop. 
If you would like further instruction please see the bottom of this page
[for detailed instructions]({{ site.baseurl }}/workshop-event/NEON-ESA-spatial-raster-time-workshop-07Aug16#set-working-directory-to-downloaded-data).  


</div>

### Workshop Instructors
* **[Megan A. Jones](http://www.neonscience.org/about/staff/megan-jones)**; @meganahjones, Staff Scientist/Science Educator; NEON program, Battelle
* **[Natalie Robinson](http://www.neonscience.org/about/staff/natalie-robinson)**; Staff Scientist, Quantitative Ecologist; NEON program, Battelle
* **[Lee Stanish](http://www.neonscience.org/about/staff/lee-stanish)**; Staff Scientist, Microbial Ecologist; NEON program, Battelle

Please get in touch with the instructors prior to the workshop with any questions.

## #WorkWithData Hashtag
  
Please tweet using the hashtag **#WorkWithData** during this workshop!

## Workshop Schedule

**Location**: TBD 
Please double check the conference schedule as rooms may change!

Please note that the schedule listed below may change depending upon the pace of
the workshop! 


| Time	| Topic	
|-------------|---------------
| 11:45	| Please come early if you have any setup or installation issues.
| 12:00	| Workshop Materials will be linked to by July 2017
| 13:30	|  --------- BREAK 1 --------- 
| 13:45	|  Workshop Materials will be linked to by July 2017
| 15:00	| --------- BREAK 2 --------- 
| 15:15	|Workshop Materials will be linked to by July 2017
| 16:30	| Final Questions & Evaluation


## Online Tutorials

All NEON workshops and self-paced tutorials can be accessed via the 
<a href="http://www.neondataskills.org/" target="_blank">NEON
Data Skills portal</a>.

***

## Additional Set Up Resources

### Set Working Directory to Downloaded Data

#### 1) Download Data

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

These directories contain all of the subdirectories and files that
we will use in this workshop. 


***

{% include wkSetup/_setup_R_Rstudio.html %}
