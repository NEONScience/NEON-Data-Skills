---
layout: workshop-event
title: "NEON @ ESA: Using the NEON API"
estimatedTime: 1.75-hour workshop
date: 2017-08-07
dateCreated: 2017-02-28
lastModified: 2017-02-28
startDate: 
endDate: 2017-08-07
authors: [Megan A. Jones]
tags: []
mainTag: workshop-event
categories: [workshop-event]
packagesLibraries: [httr]
description: "Learn to use the NEON API! The National Ecological Observatory 
Network (NEON) provides an Application Programming Interface (API); this 
workshop will guide you through using the API to access NEON data in R."
code1: 
image:
  feature: 
  credit:
  creditlink: 
permalink: /workshop-event/ESA2017-API-workshop/
comments: true 
---

{% include _toc.html %}

The National Ecological Observatory Network (NEON) provides open ecological data 
from over 80 locations across the United States. These data are available both 
on the NEON data portal and through the NEON Application Programming Interface 
(API). The API allows direct programmatic access to data and metadata in the 
NEON database, enabling automation and instantaneous updating of code and models. 
Come to this workshop to learn to navigate the NEON API. NEON scientists will 
demonstrate how to use the API, focusing on access via the R package `httr`, but 
also covering the general API structure. Attendees are encouraged to bring 
laptops and code along with the demonstration. 

### Required Prior Knowledge

Basic familiarity with R is recommended; no previous experience with APIs 
needed. The demonstration materials will also be made available online. 

***

This 1.5-hr workshop will be taught at the 2017 meeting of the Ecological
Society of America (ESA) in Portland, OR. You must be a registered 
attendee of the conference. For more information, visit the 
<a href="http://www.esa.org/portland/" target="_blank">ESA 2017 annual meeting website</a>.

<div id="objectives" markdown="1">

## Things You’ll Need For The Workshop

To fully participant in this workshop, we recommend you bring a **laptop** with 
the most current version of R loaded on your computer. You can still participate
in the workshop without bringing a laptop. 

For details on setting up R & RStudio in Mac, PC, or Linux operating systems, 
please see [the instructions below]({{ site.baseurl }}/workshop-event/ESA2016-raster-time-workshop#additional-set-up-resources).

### Install R Packages

Please have these packages *installed* and *updated* **prior** to the start of 
the workshop.

* **httr:** `install.packages("httr")`

#### Updating R Packages

In RStudio, you can go to `Tools --> Check for package updates` to update 
previously installed packages on your computer.

Or you can use `update.packages()` to update all packages that are 
installed in R automatically. 

* [More on Packages in R.]({{ site.baseurl }}/R/Packages-In-R/)

</div>

### Workshop Instructors
* **[Claire Lunch](http://www.neonscience.org/about/staff/claire-lunch)**; Staff Scientist, Plant Physiology; NEON program, Battelle
* **[Megan A. Jones](http://www.neonscience.org/about/staff/megan-jones)**; @meganahjones, Staff Scientist/Science Educator; NEON program, Battelle
* **[Christine Laney](http://www.neonscience.org/about/staff/christine-laney)**; Staff Scientist; NEON program, Battelle

Please get in touch with the instructors prior to the workshop with any questions.

## Tweet?  
Please tweet using the hashtag **#WorkWithData** and **@NEON_Sci** during this 
workshop!

## Workshop Schedule

**Location**: B115, Oregon Convention Center
Please double check the conference schedule as rooms may change!


| Time	| Topic	
|-------------|---------------
| 11:30	| Begin workshop
| 	| <a href="{{ site.baseurl }}/R/neon-api/" target="_blank"> Using the NEON API in R tutorial </a>   
| 13:15	| End workshop


## Online Tutorials

All NEON workshops and self-paced tutorials can be accessed via the 
<a href="http://www.neondataskills.org/" target="_blank">NEON
Data Skills portal</a>.

***

## Additional Set Up Resources

{% include wkSetup/_setup_R_Rstudio.html %}
