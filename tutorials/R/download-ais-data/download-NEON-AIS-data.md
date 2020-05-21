---
syncID: 
title: "Download and work with NEON Aquatic Instrument Data "
description: Tutorial for downloading NEON AIS data using the neonUtilities package and then exploring and understanding the downloaded data including seperating out into collection locations using the HOR variable. 
dateCreated: '2020-05-19'
authors: Bobby Hensley, Megan Jones
contributors: 
estimatedTime: 
packagesLibraries: neonUtilities, ggplot2
topics: data-management, rep-sci
languageTool: R, API
code1: R/download-explore/download-NEON-AIS-data.R
tutorialSeries:
urlTitle: download-neon-ais-data
---

This tutorial covers downloading NEON aquatic instrument system (AIS) data, using the 
neonUtilities R package, as well as basic instruction in beginning to 
explore and work with the downloaded data, including guidance in 
navigating data documentation and understanding how to seperate data using the 
horizontal (HOR) variable. 

To set up our mini analyis in which we learn to access and work with the NEON AIS 
data, our goal is to create a seperate R object for data from the various sensor
locations and to create a plot of a variable of interest to compare the data from 
different sensors. 

<div id="ds-objectives" markdown="1">

## Objectives

After completing this activity, you will be able to:

* Download NEON AIS data using the neonUtilities package.
* Understand downloaded data sets and load them into R for analyses.
* Seperate data collected at different sensor locations using the HOR variable.

## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need R, version 3.4 or newer, and, 
preferably, RStudio loaded on your computer.

### Install R Packages

* **neonUtilities**: Basic functions for accessing NEON data
* **ggplot2**: Plotting functions

Some of these packages are on CRAN and can be installed by 
`install.packages()`.

### Additional Resources

* <a href="https://github.com/NEONScience/NEON-Utilities/neonUtilities" target="_blank">GitHub repository for neonUtilities</a>

</div>

## Download files and load directly to R: loadByProduct()

The most popular function in `neonUtilities` is `loadByProduct()`. 
This function downloads data from the NEON API, merges the site-by-month 
files, and loads the resulting data tables into the R environment, 
assigning each data type to the appropriate R class. This is a popular 
choice because it ensures you're always working with the most up to date data, 
and it ends with ready-to-use tables in R. However, if you use it in
a workflow you run repeatedly, keep in mind it will re-download the 
data every time.

Before we get the NEON data, we need to install (if not already done) and load 
the neonUtilities R package. 


    # Install neonUtilities package if you have not yet.
    install.packages("neonUtilities")
    install.packages("ggplot2")


    # Set global option to NOT convert all character variables to factors
    options(stringsAsFactors=F)
    
    # Load required packages
    library(neonUtilities)
    library(ggplot2)

The inputs to `loadByProduct()` control which data to download and how 
to manage the processing. The following are frequently used inputs: 

* `dpID`: the data product ID, e.g. DP1.20288.001
* `site`: defaults to "all", meaning all sites with available data; 
can be a vector of 4-letter NEON site codes, e.g. 
`c("MART","TOMB","BARC")`.
* `startdate` and `enddate`: defaults to NA, meaning all dates 
with available data; or a date in the form YYYY-MM, e.g. 
2017-06. Since NEON data are provided in month packages, finer 
scale querying is not available. Both start and end date are 
inclusive.
* `package`: either basic or expanded data package. Expanded data 
packages generally include additional information about data 
quality, such as chemical standards and quality flags. Not every 
data product has an expanded package; if the expanded package is 
requested but there isn't one, the basic package will be 
downloaded.
* `avg`: defaults to "all", to download all data; or the 
number of minutes in the averaging interval. See example below; 
only applicable to IS data.
* `savepath`: the file path you want to download to; defaults to the 
working directory.
* `check.size`: T or F; should the function pause before downloading 
data and warn you about the size of your download? Defaults to T; if 
you are using this function within a script or batch process you 
will want to set this to F.
* `token`: this allows you to input your NEON API token to obtain faster downloads. 
Learn more about NEON API tokens in the <a href="https//:www.neonscience.org/neon-api-tokens-tutorial" target="_blank">**Using an API Token when Accessing NEON Data with neonUtilities** tutorial</a>. 

There are additional inputs you can learn about in the 
<a href="https//:www.neonscience.org/neonDataStackR" target="_blank">**Use the neonUtilities R Package to Access NEON Data** tutorial</a>. 

The `dpID` is the data product identifier of the data you want to 
download. The DPID can be found on the 
<a href="http://data.neonscience.org/data-products/explore" target="_blank">
Explore Data Products page</a>.

It will be in the form DP#.#####.###. For this tutorial, we'll use the Water 
Quality data product (DP1.20288.001). 

We will want data from only one NEON field site, Blacktail Deer Creek, WY (BLDE)
from October and November 2019. 

Now we can download our data. If you are not using a NEON token to download your
data, remove the `token = Sys.getenv(NEON_TOKEN)` line of code. We have 
`check.size = F` so that the script runs well but remember you always want to 
check your download size first. This code downloads 3.6 MiB and 289.4 KiB 
respectively.


    # download data of interest - Water Quality
    waq<-loadByProduct(dpID="DP1.20288.001", site="BLDE", 
    				startdate="2019-10", enddate="2019-11", 
    				package="expanded", 
    				token = Sys.getenv("NEON_TOKEN"),
    				check.size = F)

    ## 
    ## Downloading files totaling approximately 3.6 MiB
    ## Downloading 2 files
    ##   |                                                                                                          |                                                                                                  |   0%  |                                                                                                          |==================================================================================================| 100%
    ## 
    ## Unpacking zip files using 1 cores.
    ## Stacking operation across a single core.
    ## Stacking table waq_instantaneous
    ## Merged the most recent publication of sensor position files for each site and saved to /stackedFiles
    ## Copied the most recent publication of variable definition file to /stackedFiles
    ## Finished: Stacked 1 data tables and 2 metadata tables!
    ## Stacking took 2.92318 secs

<div id="ds-challenge" markdown="1">
### Challenge: Download Nitrate Data
  
Using what you've learned above, can you modify the code to download data for the following parameters. 

* Data Product DP1.20033.001: nitrate in surface water
* The expanded data tables
* Dates matching the other data products you've downloaded

1. What is the size of the downloaded data? 
2. Without downloading all the data, how can you tell what the difference in size
between the "expanded" and "basic" packages is? 
</div>



## Files Associated with Downloads

The data we've downloaded comes as an object that is a named list of objects. 
To work with each of them, select them from the list using the `$` operator. 


    # view all components of the list
    names(waq)

    ## [1] "readme_20288"           "sensor_positions_20288" "variables_20288"        "waq_instantaneous"

    # View the dataFrame
    View(waq$waq_instantaneous)

We can see that there are four objects in the downloaded water quality data. One 
dataframe of data (`waq_instantaneous`) and three metadata files. 

If you'd like you can use the `$` operator to assign an object from an item in 
the list. If you prefer to extract each table from the list and work with it as an 
independent objects, which we will do, you can use the `list2env()` function. 


    # assign the dataFrame in the list as an object
    #wqInst <- waq$waq_instantaneous
    
    # unlist the vari
    list2env(waq, .GlobalEnv)

    ## <environment: R_GlobalEnv>

So what exactly are these four files and why would you want to use them? 

* **data file(s)**: There will always be one or more dataframes that include the 
primary data of the data product you downloaded. Multiple dataframes are available 
when there are related datatables for a single data product.
* **readme_xxxxx**: The readme file, with the corresponding 5 digits from the data
product number, provides you with important information relevant to the data 
product and the specific instance of downloading the data.
* **sensor_postions_xxxxx**: this file contains information about the coordinates 
of each sensor, relative to a reference location. 
* **variables_xxxxx**: this file contains all the variables found in the associated
data table(s). This includes full definitions, units, and other important 
information. 

## Data from Different Sensor Locations (HOR)

NEON collected the same type of data from sensors in different locations. These 
data are delivered together but you will frequently want to plot the data seperately 
or only include data from one sensor in your analysis. NEON uses the 
`horizontalPosition` and `verticalPosition` variables in the data table to 
describe which sensor location the data are collected from. Below we summarize 
the common locations, for a complete list see 
**Lunch, C. 2020. NEON Data Product Numbering Convention. NEON.DOC.002651 (<a href = "https://data.neonscience.org/api/v0/documents/NEON.DOC.002651vE" target = "_blank"> direct download of PDF</a>). 

The `verticalPosition` indicates where the measurement is relative to the water: 

* 000: on-shore
* 100: in-stream/river/lake 

Water quality data always have a `verticalPosition` of 100. 

NEON uses the `horizontalPosition` variable in the data tables to describes which data a sensor 
is collected from. The `horizontalPosition` is always three digit number for AIS 
data: 

* 101: stream sensors located at the **upstream** station on a **monopod mount**, 
* 111: stream sensors located at the **upstream** station on an **overhead cable mount**, 
* 131: stream sensors located at the **upstream** station on a **stand alone pressure transducer mount**, 
* 102: stream sensors located at the **downstream** station on a monopod mount, 
* 112: stream sensors located at the **downstream** station on an **overhead cable mount** 
* 132: stream sensors located at the **downstream** station on a **stand alone pressure transducer mount**, 
* 110: **pressure transducers** mounted to a **staff gauge**. 
* 103: sensors mounted on a **buoys in lakes or rivers**
* 130 and 140: sensors mounted in the **littoral zone** of lakes

You'll frequenty want to know which sensor locations are represented in your 
data. We can do this by looking for the `unique()` position designations in 
`horizontalPostions`. 


    # which sensor locations?
    unique(waq_instantaneous$horizontalPosition)

    ## [1] "101" "102"

We can see that there are two sensor positions at BLDE during October and November
2019. As the locations of sensors can change at sites over time, it is a good 
idea to check this when you're adding in new locations or a new date range to your
analyses. 

Now we can use this information to split the data into that from the upstream 
sensor (101) and the downstream sensor (102). 


    # seperate data from sensors
    waqUp<-waq_instantaneous[(waq_instantaneous$horizontalPosition=="101"),]
    waqDown<-waq_instantaneous[(waq_instantaneous$horizontalPosition=="102"),]

## Plot Data

Now that we have our data seperated into the upstream and downstream data, let's
plot both of the data sets together. We want to create a plot of the measures of
Dissolved Oxygen from the two differnet sensors. 


    # plot
    wqual <- ggplot() +
    	geom_line(data = waqUp, aes(startDateTime, dissolvedOxygen), na.rm=TRUE, color="purple",) +
    	geom_line(data = waqDown, aes(startDateTime, dissolvedOxygen), na.rm=TRUE, color="orange",) +
    	geom_line( na.rm = TRUE)+
    	ylim(0, 20) + ylab("Dissolved Oxygen (mg/L)") +
    	xlab(" ")
    
    wqual

![ ]({{ site.baseurl }}/images/rfigs/R/download-ais-data/download-NEON-AIS-data/plot-wqual-1.png)

<div id="ds-challenge" markdown="1">
### Challenge: Plot Nitrate Data

Using what you've learned above, create a plot of the mean nitrate for the 
surface water, comparing as many sensors as are available in the data set.

</div>

![ ]({{ site.baseurl }}/images/rfigs/R/download-ais-data/download-NEON-AIS-data/challenge-code-plot-nitrate-1.png)
