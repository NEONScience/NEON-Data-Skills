---
syncID: 457a5c01d051491297dc947939b4210f
title: "Using the NEON API in R"
description: "Tutorial for getting data from the NEON API, using R and the R package httr"
dateCreated:  2017-07-07
authors: [Claire K. Lunch]
contributors: [Christine Laney, Megan A. Jones, Donal O'Leary]
estimatedTime: 1 - 1.5 hours
packagesLibraries: [httr, jsonlite, devtools, downloader, geoNEON, neonUtilities]
topics: data-management, rep-sci
languagesTool: R, API
dataProduct:
code1: R/NEON-API/NEON-API-How-To.R
tutorialSeries: 
urlTitle: neon-api-usage
---



This is a tutorial in pulling data from the NEON API or Application 
Programming Interface. The tutorial uses R and the R package httr, but the core 
information about the API is applicable to other languages and approaches.

## NEON data
There are 3 basic categories of NEON data:

1. Observational - Data collected by a human in the field, or in an analytical 
laboratory, e.g. beetle identification, foliar isotopes
1. Instrumentation - Data collected by an automated, streaming sensor, e.g. net 
radiation, soil carbon dioxide
1. Remote sensing - Data collected by the airborne observation platform, e.g. 
LIDAR, surface reflectance

This lesson covers all three types of data, but we recommend proceeding 
through the lesson in order and not skipping ahead, since the query principles 
are explained in the first section, on observational data.


<div id="ds-objectives" markdown="1">

## Objectives

After completing this activity, you will be able to:

* Pull observational, instrumentation, and geolocation data from the NEON API.
* Transform API-accessed data from JSON to tabular format for analyses.

## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### Install R Packages

* **httr:** `install.packages("httr")`
* **jsonlite:** `install.packages("jsonlite")`
* **dplyr:** `install.packages("dplyr")`
* **devtools:** `install.packages("devtools")`
* **downloader:** `install.packages("downloader")`
* **geoNEON:** `devtools::install_github("NEONScience/NEON-geolocation/geoNEON")`
* **neonUtilities:** `devtools::install_github("NEONScience/NEON-utilities/neonUtilities")`

Note, you must have devtools installed & loaded, prior to loading geoNEON or neonUtilities. 

### Additional Resources

* <a href="http://data.neonscience.org/data-api" target="_blank">Webpage for the NEON API</a>
* <a href="https://github.com/NEONScience/neon-data-api" target="_blank">GitHub repository for the NEON API</a>
* <a href="https://github.com/ropenscilabs/nneo" target="_blank"> ROpenSci wrapper for the NEON API</a> (not covered in this tutorial)

</div>

## What is an API?

If you are unfamiliar with the concept of an API, think of  an API as a 
‘middle person' that provides a communication path for a software application 
to obtain information from a digital data source. APIs are becoming a very 
common means of sharing digital information. Many of the apps that you use on 
your computer or mobile device to produce maps, charts, reports, and other 
useful forms of information pull data from multiple sources using APIs. In 
the ecological and environmental sciences, many researchers use APIs to 
programmatically pull data into their analyses. (Quoted from the NEON Observatory
Blog story: 
<a href="/observatory/observatory-blog/api-data-availability-viewer-now-live-neon-data-portal" target ="_blank"> API and data availability viewer now live on the NEON data portal</a>.)

## Anatomy of an API call

An example API call: http://data.neonscience.org/api/v0/data/DP1.10003.001/WOOD/2015-07

This includes the base URL, endpoint, and target.

### Base URL: 
<span style="color:#A00606;font-weight:bold">http://data.neonscience.org/api/v0</span><span style="color:#A2A4A3">/data/DP1.10003.001/WOOD/2015-07</span>

Specifics are appended to this in order to get the data or metadata you're 
looking for, but all calls to this API will include the base URL. For the NEON 
API, this is http://data.neonscience.org/api/v0 --
not clickable, because the base URL by itself will take you nowhere!

### Endpoints: 
<span style="color:#A2A4A3">http://data.neonscience.org/api/v0</span><span style="color:#A00606;font-weight:bold">/data</span><span style="color:#A2A4A3">/DP1.10003.001/WOOD/2015-07</span>

What type of data or metadata are you looking for?

* **~/products**
  Information about one or all of NEON's data products

* **~/sites**
  Information about data availability at the site specified in the call

* **~/locations**
  Spatial data for the NEON locations specified in the call

* **~/data**
  Data! By product, site, and date (in monthly chunks).

### Targets:
<span style="color:#A2A4A3">http://data.neonscience.org/api/v0/data</span><span style="color:#A00606;font-weight:bold">/DP1.10003.001/WOOD/2015-07</span>

The specific data product, site, or location you want to get data for.

## Observational data (OS)
Which product do you want to get data for? Consult the <a href="http://data.neonscience.org/data-products/explore" target="_blank">Explore Data Products page</a>.

We'll pick Breeding landbird point counts, DP1.10003.001

First query the products endpoint of the API to find out which sites and dates 
have data available. In the products endpoint, the target is the numbered 
identifier for the data product:


    # Load the necessary libraries
    library(httr)
    library(jsonlite)
    library(dplyr, quietly=T)
    library(downloader)
    
    # Request data using the GET function & the API call
    req <- GET("http://data.neonscience.org/api/v0/products/DP1.10003.001")
    req

    ## Response [https://data.neonscience.org/api/v0/products/DP1.10003.001]
    ##   Date: 2020-04-01 23:10
    ##   Status: 200
    ##   Content-Type: application/json;charset=UTF-8
    ##   Size: 24.2 kB

The object returned from `GET()` has many layers of information. Entering the 
name of the object gives you some basic information about what you downloaded. 

The `content()` function returns the contents in the form of a highly nested 
list. This is typical of JSON-formatted data returned by APIs. We can use the
`names()` function to view the different types of information within this list.


    # View requested data
    req.content <- content(req, as="parsed")
    names(req.content$data)

    ##  [1] "productCodeLong"              "productCode"                  "productCodePresentation"     
    ##  [4] "productName"                  "productDescription"           "productStatus"               
    ##  [7] "productCategory"              "productHasExpanded"           "productScienceTeamAbbr"      
    ## [10] "productScienceTeam"           "productPublicationFormatType" "productAbstract"             
    ## [13] "productDesignDescription"     "productStudyDescription"      "productBasicDescription"     
    ## [16] "productExpandedDescription"   "productSensor"                "productRemarks"              
    ## [19] "themes"                       "changeLogs"                   "specs"                       
    ## [22] "keywords"                     "siteCodes"

You can see all of the infoamtion by running the line `print(req.content)`, but
this will result in a very long printout in your console. Instead, you can view
list items individually. Here, we highlight a couple of interesting examples:


    # View Abstract
    req.content$data$productAbstract

    ## [1] "This data product contains the quality-controlled, native sampling resolution data from NEON's breeding landbird sampling. Breeding landbirds are defined as “smaller birds (usually exclusive of raptors and upland game birds) not usually associated with aquatic habitats” (Ralph et al. 1993). The breeding landbird point counts product provides records of species identification of all individuals observed during the 6-minute count period, as well as metadata which can be used to model detectability, e.g., weather, distances from observers to birds, and detection methods. The NEON point count method is adapted from the Integrated Monitoring in Bird Conservation Regions (IMBCR): Field protocol for spatially-balanced sampling of landbird populations (Hanni et al. 2017; http://bit.ly/2u2ChUB). For additional details, see the user guide, protocols, and science design listed in the Documentation section in [this data product's details webpage](https://data.neonscience.org/data-products/DP1.10003.001). \n\nLatency:\nThe expected time from data and/or sample collection in the field to data publication is as follows, for each of the data tables (in days) in the downloaded data package. See the Data Product User Guide for more information.\n \nbrd_countdata:  120\n\nbrd_perpoint:  120\n\nbrd_personnel:  120\n\nbrd_references:  120"

    # View Available months and associated URLs for Onaqui, Utah - ONAQ
    req.content$data$siteCodes[[27]]

    ## $siteCode
    ## [1] "ONAQ"
    ## 
    ## $availableMonths
    ## $availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## $availableMonths[[2]]
    ## [1] "2018-05"
    ## 
    ## $availableMonths[[3]]
    ## [1] "2018-06"
    ## 
    ## $availableMonths[[4]]
    ## [1] "2019-05"
    ## 
    ## 
    ## $availableDataUrls
    ## $availableDataUrls[[1]]
    ## [1] "https://data.neonscience.org/api/v0/data/DP1.10003.001/ONAQ/2017-05"
    ## 
    ## $availableDataUrls[[2]]
    ## [1] "https://data.neonscience.org/api/v0/data/DP1.10003.001/ONAQ/2018-05"
    ## 
    ## $availableDataUrls[[3]]
    ## [1] "https://data.neonscience.org/api/v0/data/DP1.10003.001/ONAQ/2018-06"
    ## 
    ## $availableDataUrls[[4]]
    ## [1] "https://data.neonscience.org/api/v0/data/DP1.10003.001/ONAQ/2019-05"

To get a more accessible view of which sites have data for which months, you'll 
need to extract data from the nested list. There are a variety of ways to do this, 
in this tutorial we'll explore a couple of them. Here we'll use `fromJSON()`, in 
the jsonlite package, which doesn't fully flatten the nested list, but gets us 
the part we need. To use it, we need a text version of the content. The text 
version is not as human readable but is readable by the `fromJSON()` function. 


    # make this JSON readable -> "text"
    req.text <- content(req, as="text")
    
    # Flatten data frame to see available data. 
    avail <- fromJSON(req.text, simplifyDataFrame=T, flatten=T)
    avail

    ## $data
    ## $data$productCodeLong
    ## [1] "NEON.DOM.SITE.DP1.10003.001"
    ## 
    ## $data$productCode
    ## [1] "DP1.10003.001"
    ## 
    ## $data$productCodePresentation
    ## [1] "NEON.DP1.10003"
    ## 
    ## $data$productName
    ## [1] "Breeding landbird point counts"
    ## 
    ## $data$productDescription
    ## [1] "Count, distance from observer, and taxonomic identification of breeding landbirds observed during point counts"
    ## 
    ## $data$productStatus
    ## [1] "ACTIVE"
    ## 
    ## $data$productCategory
    ## [1] "Level 1 Data Product"
    ## 
    ## $data$productHasExpanded
    ## [1] TRUE
    ## 
    ## $data$productScienceTeamAbbr
    ## [1] "TOS"
    ## 
    ## $data$productScienceTeam
    ## [1] "Terrestrial Observation System (TOS)"
    ## 
    ## $data$productPublicationFormatType
    ## [1] "TOS Data Product Type"
    ## 
    ## $data$productAbstract
    ## [1] "This data product contains the quality-controlled, native sampling resolution data from NEON's breeding landbird sampling. Breeding landbirds are defined as “smaller birds (usually exclusive of raptors and upland game birds) not usually associated with aquatic habitats” (Ralph et al. 1993). The breeding landbird point counts product provides records of species identification of all individuals observed during the 6-minute count period, as well as metadata which can be used to model detectability, e.g., weather, distances from observers to birds, and detection methods. The NEON point count method is adapted from the Integrated Monitoring in Bird Conservation Regions (IMBCR): Field protocol for spatially-balanced sampling of landbird populations (Hanni et al. 2017; http://bit.ly/2u2ChUB). For additional details, see the user guide, protocols, and science design listed in the Documentation section in [this data product's details webpage](https://data.neonscience.org/data-products/DP1.10003.001). \n\nLatency:\nThe expected time from data and/or sample collection in the field to data publication is as follows, for each of the data tables (in days) in the downloaded data package. See the Data Product User Guide for more information.\n \nbrd_countdata:  120\n\nbrd_perpoint:  120\n\nbrd_personnel:  120\n\nbrd_references:  120"
    ## 
    ## $data$productDesignDescription
    ## [1] "Depending on the size of the site, sampling for this product occurs either at either randomly distributed individual points or grids of nine points each. At larger sites, point count sampling occurs at five to fifteen 9-point grids, with grid centers collocated with distributed base plot centers (where plant, beetle, and/or soil sampling may also occur), if possible. At smaller sites (i.e., sites that cannot accommodate a minimum of 5 grids) point counts occur at the southwest corner (point 21) of 5-25 distributed base plots. Point counts are conducted once per breeding season at large sites and twice per breeding season at smaller sites. Point counts are six minutes long, with each minute tracked by the observer, following a two-minute settling-in period. All birds are recorded to species and sex, whenever possible, and the distance to each individual or flock is measured with a laser rangefinder, except in the case of flyovers."
    ## 
    ## $data$productStudyDescription
    ## [1] "This sampling occurs at all NEON terrestrial sites."
    ## 
    ## $data$productBasicDescription
    ## [1] "The basic package contains the per point metadata table that includes data pertaining to the observer and the weather conditions and the count data table that includes all of the observational data."
    ## 
    ## $data$productExpandedDescription
    ## [1] "The expanded package includes two additional tables and two additional fields within the count data table. The personnel table provides institutional information about each observer, as well as their performance on identification quizzes, where available. The references tables provides the list of resources used by an observer to identify birds. The additional fields in the countdata table are family and nativeStatusCode, which are derived from the NEON master list of birds."
    ## 
    ## $data$productSensor
    ## NULL
    ## 
    ## $data$productRemarks
    ## [1] "Queries for this data product will return data collected during the date range specified for brd_perpoint and brd_countdata, but will return data from all dates for brd_personnel (quiz scores may occur over time periods which are distinct from when sampling occurs) and brd_references (which apply to a broad range of sampling dates). A record from brd_perPoint should have 6+ child records in brd_countdata, at least one per pointCountMinute. Duplicates or missing data may exist where protocol and/or data entry aberrations have occurred; users should check data carefully for anomalies before joining tables. Taxonomic IDs of species of concern have been 'fuzzed'; see data package readme files for more information."
    ## 
    ## $data$themes
    ## [1] "Organisms, Populations, and Communities"
    ## 
    ## $data$changeLogs
    ## NULL
    ## 
    ## $data$specs
    ##   specId             specNumber
    ## 1   3656      NEON.DOC.000916vC
    ## 2   2565 NEON_bird_userGuide_vA
    ## 3   3729      NEON.DOC.014041vJ
    ## 
    ## $data$keywords
    ##  [1] "birds"                 "diversity"             "taxonomy"              "community composition"
    ##  [5] "distance sampling"     "avian"                 "species composition"   "population"           
    ##  [9] "vertebrates"           "invasive"              "introduced"            "native"               
    ## [13] "landbirds"             "animals"               "Animalia"              "Aves"                 
    ## [17] "Chordata"              "point counts"         
    ## 
    ## $data$siteCodes
    ##    siteCode                                                                 availableMonths
    ## 1      ABBY                                     2017-05, 2017-06, 2018-06, 2018-07, 2019-05
    ## 2      BARR                                                       2017-07, 2018-07, 2019-06
    ## 3      BART                                     2015-06, 2016-06, 2017-06, 2018-06, 2019-06
    ## 4      BLAN                            2017-05, 2017-06, 2018-05, 2018-06, 2019-05, 2019-06
    ## 5      BONA                                              2017-06, 2018-06, 2018-07, 2019-06
    ## 6      CLBJ                                              2017-05, 2018-04, 2019-04, 2019-05
    ## 7      CPER                   2013-06, 2015-05, 2016-05, 2017-05, 2017-06, 2018-05, 2019-06
    ## 8      DCFS                                     2017-06, 2017-07, 2018-07, 2019-06, 2019-07
    ## 9      DEJU                                                       2017-06, 2018-06, 2019-06
    ## 10     DELA                                              2015-06, 2017-06, 2018-05, 2019-06
    ## 11     DSNY                                     2015-06, 2016-05, 2017-05, 2018-05, 2019-05
    ## 12     GRSM                                     2016-06, 2017-05, 2017-06, 2018-05, 2019-05
    ## 13     GUAN                                     2015-05, 2017-05, 2018-05, 2019-05, 2019-06
    ## 14     HARV                            2015-05, 2015-06, 2016-06, 2017-06, 2018-06, 2019-06
    ## 15     HEAL                                     2017-06, 2018-06, 2018-07, 2019-06, 2019-07
    ## 16     JERC                                              2016-06, 2017-05, 2018-06, 2019-06
    ## 17     JORN                                     2017-04, 2017-05, 2018-04, 2018-05, 2019-04
    ## 18     KONA                                                       2018-05, 2018-06, 2019-06
    ## 19     KONZ                                              2017-06, 2018-05, 2018-06, 2019-06
    ## 20     LAJA                                              2017-05, 2018-05, 2019-05, 2019-06
    ## 21     LENO                                                       2017-06, 2018-05, 2019-06
    ## 22     MLBS                                                                2018-06, 2019-05
    ## 23     MOAB                                              2015-06, 2017-05, 2018-05, 2019-05
    ## 24     NIWO                                              2015-07, 2017-07, 2018-07, 2019-07
    ## 25     NOGP                                                       2017-07, 2018-07, 2019-07
    ## 26     OAES                                     2017-05, 2017-06, 2018-04, 2018-05, 2019-05
    ## 27     ONAQ                                              2017-05, 2018-05, 2018-06, 2019-05
    ## 28     ORNL                                     2016-05, 2016-06, 2017-05, 2018-06, 2019-05
    ## 29     OSBS                                              2016-05, 2017-05, 2018-05, 2019-05
    ## 30     PUUM                                                                         2018-04
    ## 31     RMNP                            2017-06, 2017-07, 2018-06, 2018-07, 2019-06, 2019-07
    ## 32     SCBI 2015-06, 2016-05, 2016-06, 2017-05, 2017-06, 2018-05, 2018-06, 2019-05, 2019-06
    ## 33     SERC                                              2017-05, 2017-06, 2018-05, 2019-05
    ## 34     SJER                                                       2017-04, 2018-04, 2019-04
    ## 35     SOAP                                                       2017-05, 2018-05, 2019-05
    ## 36     SRER                                              2017-05, 2018-04, 2018-05, 2019-04
    ## 37     STEI                   2016-05, 2016-06, 2017-06, 2018-05, 2018-06, 2019-05, 2019-06
    ## 38     STER                   2013-06, 2015-05, 2016-05, 2017-05, 2018-05, 2019-05, 2019-06
    ## 39     TALL                                     2015-06, 2016-07, 2017-06, 2018-06, 2019-05
    ## 40     TEAK                                              2017-06, 2018-06, 2019-06, 2019-07
    ## 41     TOOL                                                       2017-06, 2018-07, 2019-06
    ## 42     TREE                                              2016-06, 2017-06, 2018-06, 2019-06
    ## 43     UKFS                                                       2017-06, 2018-06, 2019-06
    ## 44     UNDE                                     2016-06, 2016-07, 2017-06, 2018-06, 2019-06
    ## 45     WOOD                                     2015-07, 2017-07, 2018-07, 2019-06, 2019-07
    ## 46     WREF                                                       2018-06, 2019-05, 2019-06
    ## 47     YELL                                                                2018-06, 2019-06
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              availableDataUrls
    ## 1                                                                                                                                                                                                                                                                                      https://data.neonscience.org/api/v0/data/DP1.10003.001/ABBY/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/ABBY/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/ABBY/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/ABBY/2018-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/ABBY/2019-05
    ## 2                                                                                                                                                                                                                                                                                                                                                                                                                                https://data.neonscience.org/api/v0/data/DP1.10003.001/BARR/2017-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/BARR/2018-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/BARR/2019-06
    ## 3                                                                                                                                                                                                                                                                                      https://data.neonscience.org/api/v0/data/DP1.10003.001/BART/2015-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/BART/2016-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/BART/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/BART/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/BART/2019-06
    ## 4                                                                                                                                                                                                                 https://data.neonscience.org/api/v0/data/DP1.10003.001/BLAN/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/BLAN/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/BLAN/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/BLAN/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/BLAN/2019-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/BLAN/2019-06
    ## 5                                                                                                                                                                                                                                                                                                                                                           https://data.neonscience.org/api/v0/data/DP1.10003.001/BONA/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/BONA/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/BONA/2018-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/BONA/2019-06
    ## 6                                                                                                                                                                                                                                                                                                                                                           https://data.neonscience.org/api/v0/data/DP1.10003.001/CLBJ/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/CLBJ/2018-04, https://data.neonscience.org/api/v0/data/DP1.10003.001/CLBJ/2019-04, https://data.neonscience.org/api/v0/data/DP1.10003.001/CLBJ/2019-05
    ## 7                                                                                                                                            https://data.neonscience.org/api/v0/data/DP1.10003.001/CPER/2013-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/CPER/2015-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/CPER/2016-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/CPER/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/CPER/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/CPER/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/CPER/2019-06
    ## 8                                                                                                                                                                                                                                                                                      https://data.neonscience.org/api/v0/data/DP1.10003.001/DCFS/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/DCFS/2017-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/DCFS/2018-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/DCFS/2019-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/DCFS/2019-07
    ## 9                                                                                                                                                                                                                                                                                                                                                                                                                                https://data.neonscience.org/api/v0/data/DP1.10003.001/DEJU/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/DEJU/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/DEJU/2019-06
    ## 10                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/DELA/2015-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/DELA/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/DELA/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/DELA/2019-06
    ## 11                                                                                                                                                                                                                                                                                     https://data.neonscience.org/api/v0/data/DP1.10003.001/DSNY/2015-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/DSNY/2016-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/DSNY/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/DSNY/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/DSNY/2019-05
    ## 12                                                                                                                                                                                                                                                                                     https://data.neonscience.org/api/v0/data/DP1.10003.001/GRSM/2016-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/GRSM/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/GRSM/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/GRSM/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/GRSM/2019-05
    ## 13                                                                                                                                                                                                                                                                                     https://data.neonscience.org/api/v0/data/DP1.10003.001/GUAN/2015-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/GUAN/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/GUAN/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/GUAN/2019-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/GUAN/2019-06
    ## 14                                                                                                                                                                                                                https://data.neonscience.org/api/v0/data/DP1.10003.001/HARV/2015-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/HARV/2015-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/HARV/2016-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/HARV/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/HARV/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/HARV/2019-06
    ## 15                                                                                                                                                                                                                                                                                     https://data.neonscience.org/api/v0/data/DP1.10003.001/HEAL/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/HEAL/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/HEAL/2018-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/HEAL/2019-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/HEAL/2019-07
    ## 16                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/JERC/2016-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/JERC/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/JERC/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/JERC/2019-06
    ## 17                                                                                                                                                                                                                                                                                     https://data.neonscience.org/api/v0/data/DP1.10003.001/JORN/2017-04, https://data.neonscience.org/api/v0/data/DP1.10003.001/JORN/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/JORN/2018-04, https://data.neonscience.org/api/v0/data/DP1.10003.001/JORN/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/JORN/2019-04
    ## 18                                                                                                                                                                                                                                                                                                                                                                                                                               https://data.neonscience.org/api/v0/data/DP1.10003.001/KONA/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/KONA/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/KONA/2019-06
    ## 19                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/KONZ/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/KONZ/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/KONZ/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/KONZ/2019-06
    ## 20                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/LAJA/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/LAJA/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/LAJA/2019-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/LAJA/2019-06
    ## 21                                                                                                                                                                                                                                                                                                                                                                                                                               https://data.neonscience.org/api/v0/data/DP1.10003.001/LENO/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/LENO/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/LENO/2019-06
    ## 22                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    https://data.neonscience.org/api/v0/data/DP1.10003.001/MLBS/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/MLBS/2019-05
    ## 23                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/MOAB/2015-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/MOAB/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/MOAB/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/MOAB/2019-05
    ## 24                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/NIWO/2015-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/NIWO/2017-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/NIWO/2018-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/NIWO/2019-07
    ## 25                                                                                                                                                                                                                                                                                                                                                                                                                               https://data.neonscience.org/api/v0/data/DP1.10003.001/NOGP/2017-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/NOGP/2018-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/NOGP/2019-07
    ## 26                                                                                                                                                                                                                                                                                     https://data.neonscience.org/api/v0/data/DP1.10003.001/OAES/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/OAES/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/OAES/2018-04, https://data.neonscience.org/api/v0/data/DP1.10003.001/OAES/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/OAES/2019-05
    ## 27                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/ONAQ/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/ONAQ/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/ONAQ/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/ONAQ/2019-05
    ## 28                                                                                                                                                                                                                                                                                     https://data.neonscience.org/api/v0/data/DP1.10003.001/ORNL/2016-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/ORNL/2016-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/ORNL/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/ORNL/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/ORNL/2019-05
    ## 29                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/OSBS/2016-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/OSBS/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/OSBS/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/OSBS/2019-05
    ## 30                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         https://data.neonscience.org/api/v0/data/DP1.10003.001/PUUM/2018-04
    ## 31                                                                                                                                                                                                                https://data.neonscience.org/api/v0/data/DP1.10003.001/RMNP/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/RMNP/2017-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/RMNP/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/RMNP/2018-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/RMNP/2019-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/RMNP/2019-07
    ## 32 https://data.neonscience.org/api/v0/data/DP1.10003.001/SCBI/2015-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/SCBI/2016-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/SCBI/2016-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/SCBI/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/SCBI/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/SCBI/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/SCBI/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/SCBI/2019-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/SCBI/2019-06
    ## 33                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/SERC/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/SERC/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/SERC/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/SERC/2019-05
    ## 34                                                                                                                                                                                                                                                                                                                                                                                                                               https://data.neonscience.org/api/v0/data/DP1.10003.001/SJER/2017-04, https://data.neonscience.org/api/v0/data/DP1.10003.001/SJER/2018-04, https://data.neonscience.org/api/v0/data/DP1.10003.001/SJER/2019-04
    ## 35                                                                                                                                                                                                                                                                                                                                                                                                                               https://data.neonscience.org/api/v0/data/DP1.10003.001/SOAP/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/SOAP/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/SOAP/2019-05
    ## 36                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/SRER/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/SRER/2018-04, https://data.neonscience.org/api/v0/data/DP1.10003.001/SRER/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/SRER/2019-04
    ## 37                                                                                                                                           https://data.neonscience.org/api/v0/data/DP1.10003.001/STEI/2016-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/STEI/2016-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/STEI/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/STEI/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/STEI/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/STEI/2019-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/STEI/2019-06
    ## 38                                                                                                                                           https://data.neonscience.org/api/v0/data/DP1.10003.001/STER/2013-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/STER/2015-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/STER/2016-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/STER/2017-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/STER/2018-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/STER/2019-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/STER/2019-06
    ## 39                                                                                                                                                                                                                                                                                     https://data.neonscience.org/api/v0/data/DP1.10003.001/TALL/2015-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/TALL/2016-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/TALL/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/TALL/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/TALL/2019-05
    ## 40                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2019-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2019-07
    ## 41                                                                                                                                                                                                                                                                                                                                                                                                                               https://data.neonscience.org/api/v0/data/DP1.10003.001/TOOL/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/TOOL/2018-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/TOOL/2019-06
    ## 42                                                                                                                                                                                                                                                                                                                                                          https://data.neonscience.org/api/v0/data/DP1.10003.001/TREE/2016-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/TREE/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/TREE/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/TREE/2019-06
    ## 43                                                                                                                                                                                                                                                                                                                                                                                                                               https://data.neonscience.org/api/v0/data/DP1.10003.001/UKFS/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/UKFS/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/UKFS/2019-06
    ## 44                                                                                                                                                                                                                                                                                     https://data.neonscience.org/api/v0/data/DP1.10003.001/UNDE/2016-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/UNDE/2016-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/UNDE/2017-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/UNDE/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/UNDE/2019-06
    ## 45                                                                                                                                                                                                                                                                                     https://data.neonscience.org/api/v0/data/DP1.10003.001/WOOD/2015-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/WOOD/2017-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/WOOD/2018-07, https://data.neonscience.org/api/v0/data/DP1.10003.001/WOOD/2019-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/WOOD/2019-07
    ## 46                                                                                                                                                                                                                                                                                                                                                                                                                               https://data.neonscience.org/api/v0/data/DP1.10003.001/WREF/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/WREF/2019-05, https://data.neonscience.org/api/v0/data/DP1.10003.001/WREF/2019-06
    ## 47                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    https://data.neonscience.org/api/v0/data/DP1.10003.001/YELL/2018-06, https://data.neonscience.org/api/v0/data/DP1.10003.001/YELL/2019-06

The object contains a lot of information about the data product, including: 

* keywords under `$data$keywords`, 
* references for documentation under `$data$specs`, 
* data availability by site and month under `$data$siteCodes`, and 
* specific URLs for the API calls for each site and month under 
`$data$siteCodes$availableDataUrls`.

We need `$data$siteCodes` to tell us what we can download.
`$data$siteCodes$availableDataUrls` allows us to avoid writing the API 
calls ourselves in the next steps.


    # get data availability list for the product
    bird.urls <- unlist(avail$data$siteCodes$availableDataUrls)
    length(bird.urls) #total number of URLs

    ## [1] 204

    bird.urls[1:10] #show first 10 URLs available

    ##  [1] "https://data.neonscience.org/api/v0/data/DP1.10003.001/ABBY/2017-05"
    ##  [2] "https://data.neonscience.org/api/v0/data/DP1.10003.001/ABBY/2017-06"
    ##  [3] "https://data.neonscience.org/api/v0/data/DP1.10003.001/ABBY/2018-06"
    ##  [4] "https://data.neonscience.org/api/v0/data/DP1.10003.001/ABBY/2018-07"
    ##  [5] "https://data.neonscience.org/api/v0/data/DP1.10003.001/ABBY/2019-05"
    ##  [6] "https://data.neonscience.org/api/v0/data/DP1.10003.001/BARR/2017-07"
    ##  [7] "https://data.neonscience.org/api/v0/data/DP1.10003.001/BARR/2018-07"
    ##  [8] "https://data.neonscience.org/api/v0/data/DP1.10003.001/BARR/2019-06"
    ##  [9] "https://data.neonscience.org/api/v0/data/DP1.10003.001/BART/2015-06"
    ## [10] "https://data.neonscience.org/api/v0/data/DP1.10003.001/BART/2016-06"

These are the URLs showing us what files are available for each month where 
there are data. 

Let's look at the bird data from Woodworth (WOOD) site from July 2015. We can do 
this by using the above code but now specifying which site/date we want using 
the `grep()` function. 

Note that if there were only one month of data from a site, you could leave 
off the date in the function. If you want date from more than one site/month 
you need to iterate this code, GET fails if you give it more than one URL. 


    # get data availability for WOOD July 2015
    brd <- GET(bird.urls[grep("WOOD/2015-07", bird.urls)])
    brd.files <- fromJSON(content(brd, as="text"))
    
    # view just the available data files 
    brd.files$data$files

    ##                               crc32
    ## 1  f37931d46213246dccf2a161211c9afe
    ## 2  4438e5e050fc7be5949457f42089a397
    ## 3  d84b496cf950b5b96e762473beda563a
    ## 4  e67f1ae72760a63c616ec18108453aaa
    ## 5  e0adb3146b5cce59eea09864145efcb1
    ## 6  df102cb4cfdce092cda3c0942c9d9b67
    ## 7  6d15da01c03793da8fc6d871e6659ea8
    ## 8  d76cfc5443ac27a058fab1d319d31d34
    ## 9  6ba91b6e109ff14d1911dcaad9febeb9
    ## 10 a2c47410a6a0f49d0b1cf95be6238604
    ## 11 f37931d46213246dccf2a161211c9afe
    ## 12 6d15da01c03793da8fc6d871e6659ea8
    ## 13 2ad379ae44f4e87996bdc3dee70a0794
    ## 14 22e3353dabb8b154768dc2eee9873718
    ## 15 e67f1ae72760a63c616ec18108453aaa
    ## 16 680a2f53c0a9d1b0ab4f8814bda5b399
    ##                                                                               name   size
    ## 1      NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.basic.20191107T152331Z.csv  23521
    ## 2                   NEON.D09.WOOD.DP1.10003.001.2015-07.basic.20191107T152331Z.zip  67816
    ## 3                          NEON.D09.WOOD.DP1.10003.001.readme.20191107T152331Z.txt  12784
    ## 4                       NEON.D09.WOOD.DP1.10003.001.variables.20191107T152331Z.csv   7337
    ## 5     NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.basic.20191107T152331Z.csv 346679
    ## 6           NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20191107T152331Z.xml  70539
    ## 7                      NEON.D09.WOOD.DP0.10003.001.validation.20191107T152331Z.csv  10084
    ## 8         NEON.D09.WOOD.DP1.10003.001.brd_references.expanded.20191107T152331Z.csv   1012
    ## 9           NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20191107T152331Z.xml  78750
    ## 10                          NEON.Bird_Conservancy_of_the_Rockies.brd_personnel.csv  46349
    ## 11  NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.expanded.20191107T152331Z.csv  23521
    ## 12                     NEON.D09.WOOD.DP0.10003.001.validation.20191107T152331Z.csv  10084
    ## 13 NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.expanded.20191107T152331Z.csv 367402
    ## 14               NEON.D09.WOOD.DP1.10003.001.2015-07.expanded.20191107T152331Z.zip  79998
    ## 15                      NEON.D09.WOOD.DP1.10003.001.variables.20191107T152331Z.csv   7337
    ## 16                         NEON.D09.WOOD.DP1.10003.001.readme.20191107T152331Z.txt  13063
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        url
    ## 1         https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.basic.20191107T152331Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=5c059ae4f82946010ba8312ad2b4f4df0f6e36c7bebae4ce8b1e04d3528fb07d
    ## 2                      https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.2015-07.basic.20191107T152331Z.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=9834175a330302a0366a13c37611e7cf218612ebbf8b31663bc4d8bfe4cdd48f
    ## 3                             https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.readme.20191107T152331Z.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=0423ba112b280c00459534038f819cb5bf49e5fe50a71b4437524ccb603fb686
    ## 4                          https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.variables.20191107T152331Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=fe3c33a9cf9774c498e5d464abd38100d4fc827ddc31f27b088dd59654a5c68a
    ## 5        https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.basic.20191107T152331Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=96905725239140f389d94113f11a9ddddf008e840f0ce3c1ff92614eef2b10fa
    ## 6              https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20191107T152331Z.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=a00ef580de57068aa109ff895a934ef8142e4b67328460eb641edbe28a5fb5a8
    ## 7                         https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP0.10003.001.validation.20191107T152331Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=fcc628606e087d2427f4f9a307c0daaee9446693ef634d3d41b7e8f1d1d15b0b
    ## 8         https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.brd_references.expanded.20191107T152331Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=4d8bbb9a37dff5035e0a9cae4735e83816f3cf0e5ad13d8174b5166b4e76f8dd
    ## 9           https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20191107T152331Z.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=504ebd8ddccb3cfed9805eac903a3f722e8f8e786ec3f09ec78a2853f8f6304a
    ## 10                          https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.Bird_Conservancy_of_the_Rockies.brd_personnel.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=0cef49e6ded0a541fd9de0fcb5d9ff564fd1e821c79526f9b0d1abcbe670c83a
    ## 11  https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.expanded.20191107T152331Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=44c4a785410323fbb520ebdc5012488fb6c620417936adfc8b2aad9c499a5008
    ## 12                     https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP0.10003.001.validation.20191107T152331Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=57772ec94df0fd227dde63892030a90ec483bb5121653ebaac02c3e72688e17b
    ## 13 https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.expanded.20191107T152331Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=30f618eb80aa2665d64e16370bb6803eb8483b905314ca46ebc3e15d3e49bb6e
    ## 14               https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.2015-07.expanded.20191107T152331Z.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=9d9793d472ff279f7d7e2ea0de5cccaa3da18437ccef2aa5c6e8489879660aec
    ## 15                      https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.variables.20191107T152331Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=c3d9125e44a8ce36d07aa95878de95d2444bf7ff920e2ef856a0666937da6710
    ## 16                         https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.readme.20191107T152331Z.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20200401T231018Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20200401%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=7a6b5cc7fe0e5ebf84c1624caedff947623d47314608f103175b22ec98c317b0

In this output, `name` and `url` are key fields. It provides us with the names 
of the files available for this site and month, and URLs where we can get the 
files. We'll use the file names to pick which ones we want.

The available files include both **data** and **metadata**, and both the **basic**
and **expanded** data packages. Typically the expanded package includes additional 
quality or uncertainty data, either in additional files or additional fields 
than in the basic files. Basic and expanded data packages are available for 
most NEON data products (some only have basic). Metadata are described by file 
name below.

The format for most of the file names is:

**NEON.[domain number].[site code].[data product ID].[file-specific name].
[date of file creation]**

Some files omit the domain and site, since they're not specific to a 
location, like the data product readme. The date of file creation uses the 
ISO6801 format, in this case 20170720T182547Z, and can be used to determine 
whether data have been updated since the last time you downloaded.

Available files in our query for July 2015 at Woodworth are all of the following
(leaving off the initial NEON.D09.WOOD.10003.001): 

* **~.2015-07.expanded.20170720T182547Z.zip:** zip of all files in the expanded 
package

* **~.brd_countdata.2015-07.expanded.20170720T182547Z.csv:** count data table, 
expanded package version: counts of birds at each point

* **~.brd_perpoint.2015-07.expanded.20170720T182547Z.csv:** point data table, 
expanded package version: metadata at each observation point

* **NEON.Bird Conservancy of the Rockies.brd_personnel.csv:** personnel data 
table, accuracy scores for bird observers

* **~.2015-07.basic.20170720T182547Z.zip:** zip of all files in the basic package

* **~.brd_countdata.2015-07.basic.20170720T182547Z.csv:** count data table, 
basic package version: counts of birds at each point

* **~.brd_perpoint.2015-07.basic.20170720T182547Z.csv:** point data table, 
basic package version: metadata at each observation point

* **NEON.DP1.10003.001_readme.txt:** readme for the data product (not specific 
to dates or location). Appears twice in the list, since it's in both the basic 
and expanded package

* **~.20150101-20160613.xml:** Ecological Metadata Language (EML) file. Appears 
twice in the list, since it's in both the basic and expanded package
  
* **~.validation.20170720T182547Z.csv:** validation file for the data product, 
lists input data and data entry rules. Appears twice in the list, since it's in 
both the basic and expanded package
  
* **~.variables.20170720T182547Z.csv:** variables file for the data product, 
lists data fields in downloaded tables. Appears twice in the list, since it's 
in both the basic and expanded package


We'll get the data tables for the point data and count data in the basic 
package. The list of files doesn't return in the same order every time, so we 
won't use position in the list to select. Plus, we want code we can re-use 
when getting data from other sites and other months. So we select files 
based on the data table name and the package name.



    # Get both files
    brd.count <- read.delim(brd.files$data$files$url
                            [intersect(grep("countdata", 
                                            brd.files$data$files$name),
                                        grep("basic", 
                                             brd.files$data$files$name))], 
                            sep=",")
    
    brd.point <- read.delim(brd.files$data$files$url
                            [intersect(grep("perpoint", 
                                            brd.files$data$files$name),
                                        grep("basic", 
                                             brd.files$data$files$name))], 
                            sep=",")

Now we have the data and can access it in R. Just to show that the files we 
pulled have actual data in them, let's make a quick graphic:


    # Cluster by species
    clusterBySp <- brd.count %>% 
    	group_by(scientificName) %>% 
      summarize(total=sum(clusterSize))
    
    # Reorder so list is ordered most to least abundance
    clusterBySp <- clusterBySp[order(clusterBySp$total, decreasing=T),]
    
    # Plot
    barplot(clusterBySp$total, names.arg=clusterBySp$scientificName, 
            ylab="Total", cex.names=0.5, las=2)

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-API/NEON-API-How-To/os-plot-bird-data-1.png)

Wow! There are lots of *Agelaius phoeniceus* (Red-winged Blackbirds) at WOOD in July. 


## Instrumentation data (IS)

The process is essentially the same for sensor data. We'll do the same series of 
queries for Soil Temperature, DP1.00041.001. Let's use data from Moab in March 
2017 this time.


    # Request soil temperature data availability info
    req.soil <- GET("http://data.neonscience.org/api/v0/products/DP1.00041.001")
    
    # make this JSON readable
    # Note how we've change this from two commands into one here
    avail.soil <- fromJSON(content(req.soil, as="text"), simplifyDataFrame=T, flatten=T)
    
    # get data availability list for the product
    temp.urls <- unlist(avail.soil$data$siteCodes$availableDataUrls)
    
    # get data availability from location/date of interest
    tmp <- GET(temp.urls[grep("MOAB/2017-03", temp.urls)])
    tmp.files <- fromJSON(content(tmp, as="text"))
    length(tmp.files$data$files$name) # There are a lot of available files

    ## [1] 188

    tmp.files$data$files$name[1:10]   # Let's print the first 10

    ##  [1] "NEON.D13.MOAB.DP1.00041.001.004.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv" 
    ##  [2] "NEON.D13.MOAB.DP1.00041.001.003.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"
    ##  [3] "NEON.D13.MOAB.DP1.00041.001.003.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv" 
    ##  [4] "NEON.D13.MOAB.DP1.00041.001.002.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"
    ##  [5] "NEON.D13.MOAB.DP1.00041.001.005.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv" 
    ##  [6] "NEON.D13.MOAB.DP1.00041.001.005.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"
    ##  [7] "NEON.D13.MOAB.DP1.00041.001.003.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv" 
    ##  [8] "NEON.D13.MOAB.DP1.00041.001.002.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"
    ##  [9] "NEON.DP1.00041.001_readme.txt"                                                          
    ## [10] "NEON.D13.MOAB.DP1.00041.001.001.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"

These file names start and end the same way as the observational files, but the 
middle is a little more cryptic. The structure from beginning to end is: 

**NEON.[domain number].[site code].[data product ID].00000.
[soil plot number].[depth].[averaging interval].[data table name].
[year]-[month].[data package].[date of file creation]**

So **NEON.D13.MOAB.DP1.00041.001.00000.002.504.030.ST_30_minute.
2017-03.basic.20170804T063725Z.csv** is the: 

* NEON (`NEON.`)
* Domain 13 (`.D13.`)
* Moab field site (`.MOAB.`) 
* soil temperature data (`.DP1.00041.001.`)
* (internal NEON identifier, always 00000 in published data) (`.00000.`)
* collected in Soil Plot 2, (`.002.`)
* at the 4th depth below the surface (`.504.`)
* and reported as a 30-minute mean of (`.030.` and `.ST_30_minute.`)
* only for the period of March 2017 (`.2017-03.`)
* and provided in a basic data package (`.basic.`)
* published on Aug 4, 2017 at 06:37:25 GMT (`.20170804T063725Z.`).

More information about interpreting file names can be found in the readme that 
accompanies each download.

Let's get data (and the URL) for only the plot and depth described above by selecting 
`002.504.030` and the word `basic` in the file name.

Go get it:


    soil.temp <- read.delim(tmp.files$data$files$url
                            [intersect(grep("002.504.030", 
                                            tmp.files$data$files$name),
                                       grep("basic", 
                                            tmp.files$data$files$name))], 
                            sep=",")

Now we have the data and can use it to conduct our analyses. To take 
a quick look at it, let's plot the mean soil temperature by date. 


    # plot temp ~ date
    plot(soil.temp$soilTempMean~as.POSIXct(soil.temp$startDateTime, 
                                           format="%Y-%m-%d T %H:%M:%S Z"), 
         pch=".", xlab="Date", ylab="T")

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-API/NEON-API-How-To/os-plot-soil-data-1.png)

As we'd expect we see daily fluctuation in soil temperature. 


## Remote sensing data (AOP)

Again, the process of determining which sites and time periods have data, and 
finding the URLs for those data, is the same as for the other data types. We'll 
go looking for High resolution orthorectified camera imagery, DP1.30010, and 
we'll look at the flight over San Joaquin Experimental Range (SJER) in March 
2017.


    # Request camera data availability info
    req.aop <- GET("http://data.neonscience.org/api/v0/products/DP1.30010.001")
    
    # make this JSON readable
    # Note how we've changed this from two commands into one here
    avail.aop <- fromJSON(content(req.aop, as="text"), 
                          simplifyDataFrame=T, flatten=T)
    
    # get data availability list for the product
    cam.urls <- unlist(avail.aop$data$siteCodes$availableDataUrls)
    
    # get data availability from location/date of interest
    cam <- GET(cam.urls[intersect(grep("SJER", cam.urls),
                                  grep("2017", cam.urls))])
    cam.files <- fromJSON(content(cam, as="text"))
    
    # this list of files is very long, so we'll just look at the first ten
    head(cam.files$data$files$name, 10)

    ##  [1] "17032816_EH021656(20170328192541)-0843_ort.tif" "17032816_EH021656(20170328184300)-0501_ort.tif"
    ##  [3] "17032816_EH021656(20170328175848)-0138_ort.tif" "17032816_EH021656(20170328184314)-0504_ort.tif"
    ##  [5] "17032816_EH021656(20170328182833)-0378_ort.tif" "17032816_EH021656(20170328182749)-0368_ort.tif"
    ##  [7] "17032816_EH021656(20170328182959)-0398_ort.tif" "17032816_EH021656(20170328195330)-1087_ort.tif"
    ##  [9] "17032816_EH021656(20170328174708)-0028_ort.tif" "17032816_EH021656(20170328175244)-0079_ort.tif"

File names for AOP data are more variable than for IS or OS data; 
different AOP data products use different naming conventions. 
File formats differ by product as well.

This particular product, camera imagery, is stored in TIFF files. 
For a full list of AOP data products, their naming conventions, and 
their file formats, see <link pending>.

Instead of reading a TIFF into R, we'll download it to the working 
directory. This is one option for getting AOP files from the API; if 
you plan to work with the files in R, you'll need to know how to 
read the relevant file types into R. We hope to add tutorials for 
this in the near future.

To download the TIFF file, we use the `downloader` package, and we'll 
select a file based on the time stamp in the file name: `20170328192931`


    download(cam.files$data$files$url[grep("20170328192931", 
                                           cam.files$data$files$name)],
             paste(getwd(), "/SJER_image.tif", sep=""), mode="wb")


The image, below, of the San Joaquin Experimental Range should now be in your 
working directory.

<figure>
	<a href="{{ site.baseurl }}/images/site-images/SJER_tile_20170328192931.png">
	<img src="{{ site.baseurl }}/images/site-images/SJER_tile_20170328192931.png"></a>
	<figcaption> An example of camera data (DP1.30010.001) from the San Joaquin 
	Experimental Range. Source: National Ecological Observatory Network (NEON) 
	</figcaption>
</figure>

## Geolocation data

You may have noticed some of the spatial data referenced above are a bit vague, 
e.g. "soil plot 2, 4th depth below the surface."

How to get spatial data and what to do with it depends on which type of 
data you're working with.

#### Instrumentation data (both aquatic and terrestrial)
Stay tuned - spatial data for instruments are in the process of entry into 
the NEON database.

#### Observational data - Aquatic
Latitude, longitude, elevation, and associated uncertainties are included in 
data downloads. Most products also include an "additional coordinate uncertainty" 
that should be added to the provided uncertainty. Additional spatial data, such 
as northing and easting, can be downloaded from the API.

#### Observational data - Terrestrial
Latitude, longitude, elevation, and associated uncertainties are included in 
data downloads. These are the coordinates and uncertainty of the sampling plot; 
for many protocols it is possible to calculate a more precise location. 
Instructions for doing this are in the respective data product user guides, and 
code is in the `geoNEON` package on GitHub.

### Querying a single named location
Let's look at the named locations in the bird data we downloaded above. To do this, 
look for the field called `namedLocation`, which is present in all observational 
data products, both aquatic and terrestrial.


    # view named location
    head(brd.point$namedLocation)

    ## [1] "WOOD_013.birdGrid.brd" "WOOD_013.birdGrid.brd" "WOOD_013.birdGrid.brd" "WOOD_013.birdGrid.brd"
    ## [5] "WOOD_013.birdGrid.brd" "WOOD_013.birdGrid.brd"

Here we see the first six entries in the `namedLocation` column which tells us
the names of the Terrestrial Observation plots where the bird surveys were 
conducted. 

We can query the locations endpoint of the API for the first named location, 
`WOOD_013.birdGrid.brd`. 


    # location data 
    req.loc <- GET("http://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd")
    
    # make this JSON readable
    brd.WOOD_013 <- fromJSON(content(req.loc, as="text"))
    brd.WOOD_013

    ## $data
    ## $data$locationDescription
    ## [1] "Plot \"WOOD_013\" at site \"WOOD\""
    ## 
    ## $data$locationName
    ## [1] "WOOD_013.birdGrid.brd"
    ## 
    ## $data$locationType
    ## [1] "OS Plot - brd"
    ## 
    ## $data$domainCode
    ## [1] "D09"
    ## 
    ## $data$siteCode
    ## [1] "WOOD"
    ## 
    ## $data$locationDecimalLatitude
    ## [1] 47.13912
    ## 
    ## $data$locationDecimalLongitude
    ## [1] -99.23243
    ## 
    ## $data$locationElevation
    ## [1] 579.31
    ## 
    ## $data$locationUtmEasting
    ## [1] 482375.7
    ## 
    ## $data$locationUtmNorthing
    ## [1] 5220650
    ## 
    ## $data$locationUtmHemisphere
    ## [1] "N"
    ## 
    ## $data$locationUtmZone
    ## [1] 14
    ## 
    ## $data$alphaOrientation
    ## [1] 0
    ## 
    ## $data$betaOrientation
    ## [1] 0
    ## 
    ## $data$gammaOrientation
    ## [1] 0
    ## 
    ## $data$xOffset
    ## [1] 0
    ## 
    ## $data$yOffset
    ## [1] 0
    ## 
    ## $data$zOffset
    ## [1] 0
    ## 
    ## $data$locationProperties
    ##                             locationPropertyName locationPropertyValue
    ## 1                    Value for Coordinate source            GeoXH 6000
    ## 2               Value for Coordinate uncertainty                  0.28
    ## 3                              Value for Country          unitedStates
    ## 4                               Value for County              Stutsman
    ## 5                Value for Elevation uncertainty                  0.48
    ## 6                   Value for Filtered positions                   121
    ## 7                       Value for Geodetic datum                 WGS84
    ## 8     Value for Horizontal dilution of precision                     1
    ## 9                    Value for Maximum elevation                579.31
    ## 10                   Value for Minimum elevation                569.79
    ## 11 Value for National Land Cover Database (2001)   grasslandHerbaceous
    ## 12                     Value for Plot dimensions           500m x 500m
    ## 13                             Value for Plot ID              WOOD_013
    ## 14                           Value for Plot size                250000
    ## 15                        Value for Plot subtype              birdGrid
    ## 16                           Value for Plot type           distributed
    ## 17    Value for Positional dilution of precision                   2.4
    ## 18            Value for Reference Point Position                    B2
    ## 19                        Value for Slope aspect                238.91
    ## 20                      Value for Slope gradient                  2.83
    ## 21                     Value for Soil type order             Mollisols
    ## 22                      Value for State province                    ND
    ## 23               Value for Subtype Specification            ninePoints
    ## 24                            Value for UTM Zone                   14N
    ## 
    ## $data$locationParent
    ## [1] "WOOD"
    ## 
    ## $data$locationParentUrl
    ## [1] "https://data.neonscience.org/api/v0/locations/WOOD"
    ## 
    ## $data$locationChildren
    ## [1] "WOOD_013.birdGrid.brd.B3" "WOOD_013.birdGrid.brd.C1" "WOOD_013.birdGrid.brd.A1" "WOOD_013.birdGrid.brd.B1"
    ## [5] "WOOD_013.birdGrid.brd.C2" "WOOD_013.birdGrid.brd.B2" "WOOD_013.birdGrid.brd.A2" "WOOD_013.birdGrid.brd.C3"
    ## [9] "WOOD_013.birdGrid.brd.A3"
    ## 
    ## $data$locationChildrenUrls
    ## [1] "https://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd.B3"
    ## [2] "https://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd.C1"
    ## [3] "https://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd.A1"
    ## [4] "https://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd.B1"
    ## [5] "https://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd.C2"
    ## [6] "https://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd.B2"
    ## [7] "https://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd.A2"
    ## [8] "https://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd.C3"
    ## [9] "https://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd.A3"

Note spatial information under `$data$[nameOfCoordinate]` and under 
`$data$locationProperties`. Also note `$data$locationChildren`: these are the 
finer scale locations that can be used to calculate precise spatial data for 
bird observations.

For convenience, we'll use the `geoNEON` package to make the calculations. 
First we'll use `getLocByName()` to get the additional spatial information 
available through the API, and look at the spatial resolution available in the 
initial download:


    # load the geoNEON package
    library(geoNEON)
    
    # extract the spatial data
    brd.point.loc <- getLocByName(brd.point)

    ## 
  |                                                                                                              
  |                                                                                                        |   0%
  |                                                                                                              
  |===============                                                                                         |  14%
  |                                                                                                              
  |==============================                                                                          |  29%
  |                                                                                                              
  |=============================================                                                           |  43%
  |                                                                                                              
  |===========================================================                                             |  57%
  |                                                                                                              
  |==========================================================================                              |  71%
  |                                                                                                              
  |=========================================================================================               |  86%
  |                                                                                                              
  |========================================================================================================| 100%

    # plot bird point locations 
    # note that decimal degrees is also an option in the data
    symbols(brd.point.loc$easting, brd.point.loc$northing, 
            circles=brd.point.loc$coordinateUncertainty, 
            xlab="Easting", ylab="Northing", tck=0.01, inches=F)

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-API/NEON-API-How-To/brd-extr-NL-1.png)

And use `getLocTOS()` to calculate the point locations of observations.


    brd.point.pt <- getLocTOS(brd.point, "brd_perpoint")

    ## 
  |                                                                                                              
  |                                                                                                        |   0%
  |                                                                                                              
  |==                                                                                                      |   2%
  |                                                                                                              
  |===                                                                                                     |   3%
  |                                                                                                              
  |=====                                                                                                   |   5%
  |                                                                                                              
  |=======                                                                                                 |   6%
  |                                                                                                              
  |========                                                                                                |   8%
  |                                                                                                              
  |==========                                                                                              |  10%
  |                                                                                                              
  |============                                                                                            |  11%
  |                                                                                                              
  |=============                                                                                           |  13%
  |                                                                                                              
  |===============                                                                                         |  14%
  |                                                                                                              
  |=================                                                                                       |  16%
  |                                                                                                              
  |==================                                                                                      |  17%
  |                                                                                                              
  |====================                                                                                    |  19%
  |                                                                                                              
  |=====================                                                                                   |  21%
  |                                                                                                              
  |=======================                                                                                 |  22%
  |                                                                                                              
  |=========================                                                                               |  24%
  |                                                                                                              
  |==========================                                                                              |  25%
  |                                                                                                              
  |============================                                                                            |  27%
  |                                                                                                              
  |==============================                                                                          |  29%
  |                                                                                                              
  |===============================                                                                         |  30%
  |                                                                                                              
  |=================================                                                                       |  32%
  |                                                                                                              
  |===================================                                                                     |  33%
  |                                                                                                              
  |====================================                                                                    |  35%
  |                                                                                                              
  |======================================                                                                  |  37%
  |                                                                                                              
  |========================================                                                                |  38%
  |                                                                                                              
  |=========================================                                                               |  40%
  |                                                                                                              
  |===========================================                                                             |  41%
  |                                                                                                              
  |=============================================                                                           |  43%
  |                                                                                                              
  |==============================================                                                          |  44%
  |                                                                                                              
  |================================================                                                        |  46%
  |                                                                                                              
  |==================================================                                                      |  48%
  |                                                                                                              
  |===================================================                                                     |  49%
  |                                                                                                              
  |=====================================================                                                   |  51%
  |                                                                                                              
  |======================================================                                                  |  52%
  |                                                                                                              
  |========================================================                                                |  54%
  |                                                                                                              
  |==========================================================                                              |  56%
  |                                                                                                              
  |===========================================================                                             |  57%
  |                                                                                                              
  |=============================================================                                           |  59%
  |                                                                                                              
  |===============================================================                                         |  60%
  |                                                                                                              
  |================================================================                                        |  62%
  |                                                                                                              
  |==================================================================                                      |  63%
  |                                                                                                              
  |====================================================================                                    |  65%
  |                                                                                                              
  |=====================================================================                                   |  67%
  |                                                                                                              
  |=======================================================================                                 |  68%
  |                                                                                                              
  |=========================================================================                               |  70%
  |                                                                                                              
  |==========================================================================                              |  71%
  |                                                                                                              
  |============================================================================                            |  73%
  |                                                                                                              
  |==============================================================================                          |  75%
  |                                                                                                              
  |===============================================================================                         |  76%
  |                                                                                                              
  |=================================================================================                       |  78%
  |                                                                                                              
  |===================================================================================                     |  79%
  |                                                                                                              
  |====================================================================================                    |  81%
  |                                                                                                              
  |======================================================================================                  |  83%
  |                                                                                                              
  |=======================================================================================                 |  84%
  |                                                                                                              
  |=========================================================================================               |  86%
  |                                                                                                              
  |===========================================================================================             |  87%
  |                                                                                                              
  |============================================================================================            |  89%
  |                                                                                                              
  |==============================================================================================          |  90%
  |                                                                                                              
  |================================================================================================        |  92%
  |                                                                                                              
  |=================================================================================================       |  94%
  |                                                                                                              
  |===================================================================================================     |  95%
  |                                                                                                              
  |=====================================================================================================   |  97%
  |                                                                                                              
  |======================================================================================================  |  98%
  |                                                                                                              
  |========================================================================================================| 100%

    # plot bird point locations 
    # note that decimal degrees is also an option in the data
    symbols(brd.point.pt$adjEasting, brd.point.pt$adjNorthing, 
            circles=brd.point.pt$adjCoordinateUncertainty, 
            xlab="Easting", ylab="Northing", tck=0.01, inches=F)

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-API/NEON-API-How-To/brd-calc-NL-1.png)

Now you can see the individual points where the respective point counts were 
located. 

## Taxonomy

NEON maintains accepted taxonomies for many of the taxonomic identification 
data we collect. NEON taxonomies are available for query via the API; they 
are also provided via an interactive user interface, the <a href="http://data.neonscience.org/static/taxon.html" target="_blank">Taxon Viewer</a>.

NEON taxonomy data provides the reference information for how NEON 
validates taxa; an identification must appear in the taxonomy lists 
in order to be accepted into the NEON database. Additions to the lists 
are reviewed regularly. The taxonomy lists also provide the author 
of the scientific name, and the reference text used.

The taxonomy endpoint of the API works a little bit differently from the 
other endpoints. In the "Anatomy of an API Call" section above, each 
endpoint has a single type of target - a data product number, a named 
location name, etc. For taxonomic data, there are multiple query 
options, and some of them can be used in combination.
For example, a query for taxa in the Pinaceae family:

<span style="color:#A2A4A3">http://data.neonscience.org/api/v0/taxonomy</span><span style="color:#A00606;font-weight:bold">/?family=Pinaceae</span>

The available types of queries are listed in the <a href="http://data.neonscience.org/data-api#!/taxonomy/Get_taxonomy" target="_blank">taxonomy section</a> 
of the API web page. Briefly, they are:

* `taxonTypeCode`: Which of the taxonomies maintained by NEON are you 
looking for? BIRD, FISH, PLANT, etc. Cannot be used in combination 
with the taxonomic rank queries.
* each of the major taxonomic ranks from genus through kingdom
* `scientificname`: Genus + specific epithet (+ authority). Search is 
by exact match only, see final example below.
* `verbose`: Do you want the short (`false`) or long (`true`) response
* `offset`: Skip this number of items in the list. Defaults to 50.
* `limit`: Result set will be truncated at this length. Defaults to 50.

Staff on the NEON project have plans to modify the settings for `offset` 
and `limit`, such that `offset` will default to 0 and `limit` will default 
to ∞, but in the meantime users will want to set these manually. They are 
set to non-default values in the examples below.

For the first example, let's query for the loon family, Gaviidae, in the 
bird taxonomy. Note that query parameters are case-sensitive.


    loon.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?family=Gaviidae&offset=0&limit=500")

Parse the results into a list using `fromJSON()`:


    loon.list <- fromJSON(content(loon.req, as="text"))

And look at the `$data` element of the results, which contains:

* The full taxonomy of each taxon
* The short taxon code used by NEON (taxonID/acceptedTaxonID)
* The author of the scientific name (scientificNameAuthorship)
* The vernacular name, if applicable
* The reference text used (nameAccordingToID)

The terms used for each field are matched to Darwin Core (dwc) and 
the Global Biodiversity Information Facility (gbif) terms, where 
possible, and the matches are indicated in the column headers.


    loon.list$data

    ##   taxonTypeCode taxonID acceptedTaxonID dwc:scientificName dwc:scientificNameAuthorship dwc:taxonRank
    ## 1          BIRD    ARLO            ARLO      Gavia arctica                   (Linnaeus)       species
    ## 2          BIRD    COLO            COLO        Gavia immer                   (Brunnich)       species
    ## 3          BIRD    PALO            PALO     Gavia pacifica                   (Lawrence)       species
    ## 4          BIRD    RTLO            RTLO     Gavia stellata                (Pontoppidan)       species
    ## 5          BIRD    YBLO            YBLO      Gavia adamsii                 (G. R. Gray)       species
    ##   dwc:vernacularName    dwc:nameAccordingToID dwc:kingdom dwc:phylum dwc:class   dwc:order dwc:family dwc:genus
    ## 1        Arctic Loon doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes   Gaviidae     Gavia
    ## 2        Common Loon doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes   Gaviidae     Gavia
    ## 3       Pacific Loon doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes   Gaviidae     Gavia
    ## 4  Red-throated Loon doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes   Gaviidae     Gavia
    ## 5 Yellow-billed Loon doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes   Gaviidae     Gavia
    ##   gbif:subspecies gbif:variety
    ## 1              NA           NA
    ## 2              NA           NA
    ## 3              NA           NA
    ## 4              NA           NA
    ## 5              NA           NA

To get the entire list for a particular taxonomic type, use the 
`taxonTypeCode` query. Be cautious with this query, the PLANT taxonomic 
list has several hundred thousand entries.

For an example, let's look up the small mammal taxonomic list, which 
is one of the shorter ones, and use the `verbose=true` option to see 
a more extensive list of taxon data, including many taxon ranks that 
aren't populated for these taxa. For space here, we display only 
the first 10 taxa:


    mam.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?taxonTypeCode=SMALL_MAMMAL&offset=0&limit=500&verbose=true")
    mam.list <- fromJSON(content(mam.req, as="text"))
    mam.list$data[1:10,]

    ##    taxonTypeCode taxonID acceptedTaxonID               dwc:scientificName dwc:scientificNameAuthorship
    ## 1   SMALL_MAMMAL    AMHA            AMHA        Ammospermophilus harrisii          Audubon and Bachman
    ## 2   SMALL_MAMMAL    AMIN            AMIN       Ammospermophilus interpres                      Merriam
    ## 3   SMALL_MAMMAL    AMLE            AMLE        Ammospermophilus leucurus                      Merriam
    ## 4   SMALL_MAMMAL    AMLT            AMLT Ammospermophilus leucurus tersus                      Goldman
    ## 5   SMALL_MAMMAL    AMNE            AMNE         Ammospermophilus nelsoni                      Merriam
    ## 6   SMALL_MAMMAL    AMSP            AMSP             Ammospermophilus sp.                         <NA>
    ## 7   SMALL_MAMMAL    APRN            APRN            Aplodontia rufa nigra                       Taylor
    ## 8   SMALL_MAMMAL    APRU            APRU                  Aplodontia rufa                   Rafinesque
    ## 9   SMALL_MAMMAL    ARAL            ARAL                Arborimus albipes                      Merriam
    ## 10  SMALL_MAMMAL    ARLO            ARLO            Arborimus longicaudus                         True
    ##    dwc:taxonRank            dwc:vernacularName taxonProtocolCategory dwc:nameAccordingToID
    ## 1        species     Harriss Antelope Squirrel         opportunistic  isbn: 978 0801882210
    ## 2        species       Texas Antelope Squirrel         opportunistic  isbn: 978 0801882210
    ## 3        species Whitetailed Antelope Squirrel         opportunistic  isbn: 978 0801882210
    ## 4     subspecies                          <NA>         opportunistic  isbn: 978 0801882210
    ## 5        species     Nelsons Antelope Squirrel         opportunistic  isbn: 978 0801882210
    ## 6          genus                          <NA>         opportunistic  isbn: 978 0801882210
    ## 7     subspecies                          <NA>            non-target  isbn: 978 0801882210
    ## 8        species                      Sewellel            non-target  isbn: 978 0801882210
    ## 9        species              Whitefooted Vole                target  isbn: 978 0801882210
    ## 10       species                 Red Tree Vole                target  isbn: 978 0801882210
    ##                                                                                                                                                 dwc:nameAccordingToTitle
    ## 1  Wilson D. E. and D. M. Reeder. 2005. Mammal Species of the World; A Taxonomic and Geographic Reference. Third edition. Johns Hopkins University Press; Baltimore, MD.
    ## 2  Wilson D. E. and D. M. Reeder. 2005. Mammal Species of the World; A Taxonomic and Geographic Reference. Third edition. Johns Hopkins University Press; Baltimore, MD.
    ## 3  Wilson D. E. and D. M. Reeder. 2005. Mammal Species of the World; A Taxonomic and Geographic Reference. Third edition. Johns Hopkins University Press; Baltimore, MD.
    ## 4  Wilson D. E. and D. M. Reeder. 2005. Mammal Species of the World; A Taxonomic and Geographic Reference. Third edition. Johns Hopkins University Press; Baltimore, MD.
    ## 5  Wilson D. E. and D. M. Reeder. 2005. Mammal Species of the World; A Taxonomic and Geographic Reference. Third edition. Johns Hopkins University Press; Baltimore, MD.
    ## 6  Wilson D. E. and D. M. Reeder. 2005. Mammal Species of the World; A Taxonomic and Geographic Reference. Third edition. Johns Hopkins University Press; Baltimore, MD.
    ## 7  Wilson D. E. and D. M. Reeder. 2005. Mammal Species of the World; A Taxonomic and Geographic Reference. Third edition. Johns Hopkins University Press; Baltimore, MD.
    ## 8  Wilson D. E. and D. M. Reeder. 2005. Mammal Species of the World; A Taxonomic and Geographic Reference. Third edition. Johns Hopkins University Press; Baltimore, MD.
    ## 9  Wilson D. E. and D. M. Reeder. 2005. Mammal Species of the World; A Taxonomic and Geographic Reference. Third edition. Johns Hopkins University Press; Baltimore, MD.
    ## 10 Wilson D. E. and D. M. Reeder. 2005. Mammal Species of the World; A Taxonomic and Geographic Reference. Third edition. Johns Hopkins University Press; Baltimore, MD.
    ##    dwc:kingdom gbif:subkingdom gbif:infrakingdom gbif:superdivision gbif:division gbif:subdivision
    ## 1     Animalia              NA                NA                 NA            NA               NA
    ## 2     Animalia              NA                NA                 NA            NA               NA
    ## 3     Animalia              NA                NA                 NA            NA               NA
    ## 4     Animalia              NA                NA                 NA            NA               NA
    ## 5     Animalia              NA                NA                 NA            NA               NA
    ## 6     Animalia              NA                NA                 NA            NA               NA
    ## 7     Animalia              NA                NA                 NA            NA               NA
    ## 8     Animalia              NA                NA                 NA            NA               NA
    ## 9     Animalia              NA                NA                 NA            NA               NA
    ## 10    Animalia              NA                NA                 NA            NA               NA
    ##    gbif:infradivision gbif:parvdivision gbif:superphylum dwc:phylum gbif:subphylum gbif:infraphylum
    ## 1                  NA                NA               NA   Chordata             NA               NA
    ## 2                  NA                NA               NA   Chordata             NA               NA
    ## 3                  NA                NA               NA   Chordata             NA               NA
    ## 4                  NA                NA               NA   Chordata             NA               NA
    ## 5                  NA                NA               NA   Chordata             NA               NA
    ## 6                  NA                NA               NA   Chordata             NA               NA
    ## 7                  NA                NA               NA   Chordata             NA               NA
    ## 8                  NA                NA               NA   Chordata             NA               NA
    ## 9                  NA                NA               NA   Chordata             NA               NA
    ## 10                 NA                NA               NA   Chordata             NA               NA
    ##    gbif:superclass dwc:class gbif:subclass gbif:infraclass gbif:superorder dwc:order gbif:suborder
    ## 1               NA  Mammalia            NA              NA              NA  Rodentia            NA
    ## 2               NA  Mammalia            NA              NA              NA  Rodentia            NA
    ## 3               NA  Mammalia            NA              NA              NA  Rodentia            NA
    ## 4               NA  Mammalia            NA              NA              NA  Rodentia            NA
    ## 5               NA  Mammalia            NA              NA              NA  Rodentia            NA
    ## 6               NA  Mammalia            NA              NA              NA  Rodentia            NA
    ## 7               NA  Mammalia            NA              NA              NA  Rodentia            NA
    ## 8               NA  Mammalia            NA              NA              NA  Rodentia            NA
    ## 9               NA  Mammalia            NA              NA              NA  Rodentia            NA
    ## 10              NA  Mammalia            NA              NA              NA  Rodentia            NA
    ##    gbif:infraorder gbif:section gbif:subsection gbif:superfamily    dwc:family gbif:subfamily gbif:tribe
    ## 1               NA           NA              NA               NA     Sciuridae        Xerinae  Marmotini
    ## 2               NA           NA              NA               NA     Sciuridae        Xerinae  Marmotini
    ## 3               NA           NA              NA               NA     Sciuridae        Xerinae  Marmotini
    ## 4               NA           NA              NA               NA     Sciuridae        Xerinae  Marmotini
    ## 5               NA           NA              NA               NA     Sciuridae        Xerinae  Marmotini
    ## 6               NA           NA              NA               NA     Sciuridae        Xerinae  Marmotini
    ## 7               NA           NA              NA               NA Aplodontiidae           <NA>       <NA>
    ## 8               NA           NA              NA               NA Aplodontiidae           <NA>       <NA>
    ## 9               NA           NA              NA               NA    Cricetidae    Arvicolinae       <NA>
    ## 10              NA           NA              NA               NA    Cricetidae    Arvicolinae       <NA>
    ##    gbif:subtribe        dwc:genus dwc:subgenus gbif:subspecies gbif:variety gbif:subvariety gbif:form
    ## 1             NA Ammospermophilus         <NA>              NA           NA              NA        NA
    ## 2             NA Ammospermophilus         <NA>              NA           NA              NA        NA
    ## 3             NA Ammospermophilus         <NA>              NA           NA              NA        NA
    ## 4             NA Ammospermophilus         <NA>              NA           NA              NA        NA
    ## 5             NA Ammospermophilus         <NA>              NA           NA              NA        NA
    ## 6             NA Ammospermophilus         <NA>              NA           NA              NA        NA
    ## 7             NA       Aplodontia         <NA>              NA           NA              NA        NA
    ## 8             NA       Aplodontia         <NA>              NA           NA              NA        NA
    ## 9             NA        Arborimus         <NA>              NA           NA              NA        NA
    ## 10            NA        Arborimus         <NA>              NA           NA              NA        NA
    ##    gbif:subform speciesGroup dwc:specificEpithet dwc:infraspecificEpithet
    ## 1            NA         <NA>            harrisii                     <NA>
    ## 2            NA         <NA>           interpres                     <NA>
    ## 3            NA         <NA>            leucurus                     <NA>
    ## 4            NA         <NA>            leucurus                   tersus
    ## 5            NA         <NA>             nelsoni                     <NA>
    ## 6            NA         <NA>                 sp.                     <NA>
    ## 7            NA         <NA>                rufa                    nigra
    ## 8            NA         <NA>                rufa                     <NA>
    ## 9            NA         <NA>             albipes                     <NA>
    ## 10           NA         <NA>         longicaudus                     <NA>

To get information about a single taxon, use the `scientificname` 
query. This query will not do a fuzzy match, so you need to query 
the exact name of the taxon in the NEON taxonomy. Because of this, 
the query will be most useful when you already have NEON data in 
hand and are looking for more information about a specific taxon. 
Querying on `scientificname` is unlikely to be an efficient way to 
figure out if NEON recognizes a particular taxon.

In addition, scientific names contain spaces, which are not 
allowed in a URL. The spaces need to be replaced with the URL 
encoding replacement, %20.

For an example, let's look up the little sand verbena, *Abronia 
minor Standl.* Searching for *Abronia minor* will fail, because 
the NEON taxonomy for this species includes the authority. The 
search will also fail with spaces. Search for 
`Abronia%20minor%20Standl.`, and in this case we can omit 
`offset` and `limit` because we know there can only be a single 
result:


    am.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?scientificname=Abronia%20minor%20Standl.")
    am.list <- fromJSON(content(am.req, as="text"))
    am.list$data

    ##   taxonTypeCode taxonID acceptedTaxonID    dwc:scientificName dwc:scientificNameAuthorship dwc:taxonRank
    ## 1         PLANT   ABMI2           ABMI2 Abronia minor Standl.                      Standl.       species
    ##    dwc:vernacularName                       dwc:nameAccordingToID dwc:kingdom    dwc:phylum     dwc:class
    ## 1 little sand verbena http://plants.usda.gov (accessed 8/25/2014)     Plantae Magnoliophyta Magnoliopsida
    ##        dwc:order    dwc:family dwc:genus gbif:subspecies gbif:variety
    ## 1 Caryophyllales Nyctaginaceae   Abronia              NA           NA

## Stacking NEON data 

At the top of this tutorial, we installed the `neonUtilities` package. 
This is a custom R package that stacks the monthly files provided by 
the NEON data portal into a single continuous file for each type of 
data table in the download. It currently handles files downloaded from 
the data portal, but not files pulled from the API. That functionality 
will be added soon!

For a guide to using `neonUtilities` on data downloaded from the portal, 
look <a href="/neonDataStackR" target="_blank">here</a>.
