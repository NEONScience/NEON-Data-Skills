---
layout: tutorial-series-landing
title: 'NEON Self-Paced Tutorial Series & Data Carpentry Workshop -- Work with Spatio-temporal Data in R -- Data Theme: Phenology'
categories: [tutorial-series]
tutorialSeriesName: neon-dc-phenology-series
permalink: tutorial-series/neon-dc-phenology-series/
image:
  feature: NEONCarpentryHeader_2.png
  credit: 
  creditlink: 
---

## About this Workshop Series
In the tutorials in this 
[NEON / Data Carpentry workshop series]({{ site.baseurl }}/tutorial-series/neon-dc-phenology-series/), 
we will learn important skills and concepts that support working with external 
spatio-temporal data including:

* Understanding metadata formats.
* Finding critical information about data using metadata.
* Dealing with null/NoData and missing data values.
* Importing and plotting time series data
* Working with and manipulating data/time formats.
* Importing and plotting raster data in `Geotiff` format.
* Importing and plotting vector (`shapefile` and `.csv` format) data.
* Working with raster time series data.

**R Skill Level:** Intermediate - you've got the basics of `R` down but haven't
worked with spatial data in `R` before.

<div id="objectives" markdown="1">

# Series Goals / Objectives
After completing the workshop, you will:

* Understand different types of spatial & temporal metadata.
* Know how to deal with null and missing values.
* Be able to import and plot time series data (from a .csv format).
* Understand working with and manipulating data/time formats.
* Be able to import and plot raster data in `Geotiff` format.
* Be able to import and plot vector data in `shapefile` and `.csv` formats.
* Know how to work with raster time series data.

## Things You’ll Need To Complete This Lesson
To complete this lesson: you will need the most current version of R, and 
preferably RStudio, loaded on your computer.

### Install R Packages
The needed `R` packages are provided with each. Alternatively, you can install
them all now.


[More on Packages in R - Adapted from Software Carpentry.]({{site.baseurl}}R/Packages-In-R/)


### Download Data

{% include/dataSubsets/_data_Site-Layout-Files.html %}
{% include/dataSubsets/_data_Airborne-Remote-Sensing.html %}

*****

{% include/_greyBox-wd-rscript.html %}
**Working with Spatio-temporal Phenology Data Series:** This tutorial series is
part of a
[NEON / Data Carpentry workshop series]({{ site.baseurl }}/tutorial-series/neon-dc-phenology-series/)
The workshop includes series on
[introduction to spatial data and data management]({{ site.baseurl }}tutorial-series/spatial-data-management-series/),
[raster time-series data in R]({{ site.baseurl }}tutorial-series/raster-time-series/), 
[vector data in R ]({{ site.baseurl }}tutorial-series/vector-data-series/)
and
[tabular time series in R ]({{ site.baseurl }}tutorial-series/tabular-time-series/).

</div> 


## Answer Scientific Questions Using Data 
We often begin a research project with one or more questions that we would like 
to answer. Once we have a question, we identify the:

* Type of data needed to address the question,
* The spatial coverage required - the locations that the data should cover and
the related spatial `extent`, and 
* The required temporal coverage - time period that the data should span to 
properly address the question.

Once we have identified these things, we can determine what methods are 
needed to collect data needed to answer our question.


## Work With External Data
When our question requires data that are small in temporal and/or spatial scale, 
we can often collect the data needed to answer the question ourselves. When we
ask questions that cover larger spatial (e.g. regions to continents) or temporal 
scales (e.g., years to decades), we often need to use data collected by other 
labs, organizations, and agencies. We refer to these data we have not collected
ourselves as **external data**. 

## Metadata - Data That Describe the Data
When working with external data, we need to understand metadata. Metadata is the
documentation associated with a dataset that helps us understand collection and
processing methods, format and other key information. Essential aspects of 
metadata include:

* Knowing **what methods were used to collect and process the data** in order
to trust that the data will be sufficient to answer our question.
* Being sure of **the format and how the data are stored** so that we know
missing data and bad data values that allow for efficient processing and 
accurate analysis of the data. 
* Knowing **key spatial metadata**, when data are explicitly spatial 
(e.g., "GIS" type data), to properly process and visualize the data.

## Programming Language
These tutorials use the `R` programming language although the conceptual
topics relate to all programming languages! 

## Tutorial Series in Workshop & Self-paced Tutorial Series
