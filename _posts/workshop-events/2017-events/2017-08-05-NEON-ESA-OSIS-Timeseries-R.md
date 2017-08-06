---
layout: workshop-event
title: "NEON @ ESA: Working with Time Series in R using NEON Data"
estimatedTime: 5-hour workshop
date: 2017-08-06
dateCreated: 2017-02-28
lastModified: 2017-02-28
startDate: 2017-08-06
endDate: 2017-08-07
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

1. working with data.frames in R (dplyr package), 
2. converting timestamps stored as text strings to R date or datetime (e.g. POSIX) classes (lubridate package), 
3. aggregating data across different time scales (day vs month) and 
4. plotting time series data (ggplot2 package). 

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
see [the instructions below]({{ site.baseurl }}/workshop-event/ESA2017-NEON-timeseries-workshop#additional-set-up-resources).

### Install R Packages

Please have these packages *installed* and *updated* **prior** to the start of 
the workshop.

* **dplyr:** `install.packages("dplyr")`
* **ggplot2:** `install.packages("ggplot2")`
* **lubridate:** `install.packages("lubridate")`
* **scales:** `install.packages("scales")`
* **tidyr:** `install.packages("tidyr")`
* **gridExtra:** `install.packages("gridExtra")`

#### Updating R Packages

In RStudio, you can go to `Tools --> Check for package updates` to update 
previously installed packages on your computer.

Or you can use `update.packages()` to update all packages that are 
installed in R automatically. 

* [More on Packages in R.]({{ site.baseurl }}/R/Packages-In-R/)

### Download Data

{% include/dataSubsets/_data_NEON-pheno-temp-timeseries.html %}

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

## Twitter?
  
Please tweet using the hashtag **#WorkWithData** & **@NEON_Sci** during this workshop!

## Workshop Schedule

**Location**: C125-126, Oregon Convention Center
Please double check the conference schedule as rooms can change!

Please note that the schedule listed below may change depending upon the pace of
the workshop! 


| Time	| Topic	
|-------------|---------------
| 11:45	| Please come early if you have any setup or installation issues.
| 12:00	| <a href="{{ site.baseurl }}/R/plant-pheno-data" target="_blank">Working With NEON Phenology Data - Discrete Time Series</a>
| 13:30	|  --------- BREAK 1 --------- 
| 13:45	|  <a href="{{ site.baseurl }}/R/neon-SAAT-temp" target="_blank">Working with NEON Temperature Data - Continuous Time Series</a>
| 15:00	| --------- BREAK 2 --------- 
| 15:15	|  <a href="{{ site.baseurl }}/R/neon-pheno-temp-plot" target="_blank">Combining Discrete & Continuous Time Series in Plotting </a>
| 16:30	| Final Questions & Evaluation


### Charging Station
ESA has informed us there will not be power available at each table. However, 
there will be a charging station in the room. If you are concerned about battery 
during the workshop, consider reducing your screen brightness at the start of the 
workshop. 

## Online Tutorials

All NEON workshops and self-paced tutorials can be accessed via the 
<a href="http://www.neondataskills.org/" target="_blank">NEON
Data Skills portal</a>.

***

## Additional Set Up Resources

{% include wkSetup/_setup_data.html %}

***

{% include wkSetup/_setup_R_Rstudio.html %}
