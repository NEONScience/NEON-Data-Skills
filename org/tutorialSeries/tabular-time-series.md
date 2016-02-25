---
layout: tutorial-series-landing
title: 'Introduction to Working With Time Series Data in Text Formats in R'
categories: [tutorial-series]
tutorialSeriesName: tabular-time-series
permalink: tutorial-series/tabular-time-series/
image:
  feature: NEONCarpentryHeader_2.png
  credit: 
  creditlink: 
---

## About
The tutorials in this series cover how to open, work with and plot tabular 
time-series data in `R`.  Additional topics include working with time and date 
classes (e.g., POSIXct, POSIXlt, and Date), subsetting time series data by date 
and time and created facetted or tiles 
sets of plots.

Data used in this series cover NEON Harvard Forest Field Site and are in .csv 
file format. 

**R Skill Level:** Intermediate - you've got the basics of `R` down but haven't
previously worked with time-series data in `R`.

<div id="objectives" markdown="1">

# Series Goals / Objectives
After completing the series you will:

* **Time Series 00**
	+ Be able to open a `.csv` file in `R` using `read.csv()`and understand why
we are using that file type.
	+ Understand how to work data stored in different columns within a 
`data.frame` in `R`.
	+ Understand how to examine `R` object structures and data `classes`.
	+ Be able to convert dates, stored as a character class, into an `R` date 
class.
	+ Know how to create a quick plot of a time-series data set using `qplot`. 
* **Time Series 01**
	+ Know how to import a .csv file and examine the structure of the related `R`
object. 
	+ Use a metadata file to better understand the content of a dataset.
	+ Understand the importance of including metadata details in your `R` script.
	+ Know what an EML file is. 
* **Time Series 02**
	+ Understand various date-time classes and data structure in `R`. 
	+ Understand what `POSIXct` and `POSIXlt` data classes are and why POSIXct 
may be preferred for some tasks. 
	+ Be able to convert a column containing date-time information in character
format to a date-time `R` class.
	+ Be able to convert a date-time column to different date-time classes. 
	+ Learn how to write out a date-time class object in different ways 
(month-day, month-day-year, etc). 
* **Time Series 03**
	+ Be able to subset data by date. 
	+ Know how to search for NA or missing data values. 
	+ Understand different possibilities on how to deal with missing data. 
* **Time Series 04**
	+ Know several ways to manipulate data using functions in the `dplyr` package
 in `R`.
	+ Be able to use `group-by()`, `summarize()`, and `mutate()` functions. 
	+ Write and understand `R` code with pipes for cleaner, efficient coding.
	+ Use the `year()` function from the `lubridate` package to extract year from a
 date-time class variable. 
* **Time Series 05**
	+ Be able to create basic time series plots using `ggplot()` in `R`.
	+ Understand the syntax of `ggplot()` and know how to find out more about the
 package. 
	+ Be able to plot data using scatter and bar plots.
* **Time Series 06**
	+ Know how to use `facets()` in the `ggplot2` package.
	+ Be able to combine different types of data into one plot layout.
* **Time Series Culmination Activity**
	+ have applied `ggplot2` and `dplyr` skills to a new data set.
	+ learn how to set min/max axis values in `ggplot()` to align data on multiple plots. 

## Things You’ll Need To Complete This Series

### Setup RStudio
To complete the tutorial series you will need an updated version of `R` and,
preferably, RStudio installed on your computer.

 <a href = "http://cran.r-project.org/">R</a> 
is a programming language that specializes in statistical computing. It is a 
powerful tool for exploratory data analysis. To interact with `R`, we strongly
recommend 
<a href="http://www.rstudio.com/">RStudio</a>,
an interactive development environment (IDE). 

### Install R Packages
You can chose to install packages with each lesson or you can download all 
of the necessary `R` packages now. 

* **ggplot2:** `install.packages("ggplot2")`
* **lubridate:** `install.packages("lubridate")`
* **dplyr:** `install.packages("dplyr")`
* **scales:** `install.packages("scales")`
* **gridExtra:** `install.packages("gridExtra")`
* **ggthemes:** `install.packages("ggthemes")`
* **reshape2:** `install.packages("reshape2")`
* **zoo:** `install.packages("zoo")`

[More on Packages in R - Adapted from Software Carpentry.]({{site.baseurl}}R/Packages-In-R/)

### Download Data

{% include/dataSubsets/_data_Met-Time-Series.html %}

*****

{% include/_greyBox-wd-rscript.html %}
**Working with Spatio-temporal Data in R Series:** This tutorial series is
part of a larger
[spatio-temporal tutorial series and Data Carpentry workshop.]({{ site.baseurl }}tutorial-series/neon-dc-phenology-series/)
Included series are
[introduction to spatio-temporal data and data management]({{ site.baseurl }}tutorial-series/spatial-data-management-series/),
[working With raster data in R]({{ site.baseurl }}tutorial-series/raster-data-series/), 
[working with vector data in R ]({{ site.baseurl }}tutorial-series/vector-data-series/)
and
[working with tabular time series in R]({{ site.baseurl }}tutorial-series/tabular-time-series/).

</div> 

## Tutorials in the Series
