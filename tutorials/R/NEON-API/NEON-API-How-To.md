---
syncID: 457a5c01d051491297dc947939b4210f
title: "Using the NEON API in R"
description: "Tutorial for getting data from the NEON API, using R and the R package httr"
dateCreated:  2017-07-07
authors: [Claire K. Lunch]
contributors: [Christine Laney, Megan A. Jones]
estimatedTime: 1 - 1.5 hours
packagesLibraries: [httr, jsonlite, devtools, downloader, geoNEON, neonUtilities]
topics: data-management, rep-sci
languagesTool: R, API
dataProduct:
code1: R/NEON-API/NEON-API-How-To
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
Which product do you want to get data for? Consult the <a href="http://data.neonscience.org/data-product-catalog" target="_blank">data product catalog</a>.

We'll pick Breeding landbird point counts, DP1.10003.001

First query the products endpoint of the API to find out which sites and dates 
have data available. In the products endpoint, the target is the numbered 
identifier for the data product:


    # Load the necessary libaries
    library(httr)
    library(jsonlite)
    library(dplyr, quietly=T)

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    library(downloader)
    
    # Request data using the GET function & the API call
    req <- GET("http://data.neonscience.org/api/v0/products/DP1.10003.001")
    req

    ## Response [http://data.neonscience.org/api/v0/products/DP1.10003.001]
    ##   Date: 2018-04-24 20:26
    ##   Status: 200
    ##   Content-Type: application/json;charset=UTF-8
    ##   Size: 13.5 kB

The object returned from `GET()` has many layers of information. Entering the 
name of the object gives you some basic information about what you downloaded. 

The `content()` function returns the contents in the form of a highly nested 
list. This is typical of JSON-formatted data returned by APIs. 


    # View requested data
    req.content <- content(req, as="parsed")
    req.content

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
    ## $data$productAbstract
    ## [1] "This data product contains the quality-controlled, native sampling resolution data from NEON's breeding landbird sampling. Breeding landbirds are defined as “smaller birds (usually exclusive of raptors and upland game birds) not usually associated with aquatic habitats” (Ralph et al. 1993). The breeding landbird point counts product provides records of species identification of all individuals observed during the 6-minute count period, as well as metadata which can be used to model detectability, e.g., weather, distances from observers to birds, and detection methods. The NEON point count method is adapted from the Integrated Monitoring in Bird Conservation Regions (IMBCR): Field protocol for spatially-balanced sampling of landbird populations (Hanni et al. 2017; http://bit.ly/2u2ChUB). For additional details, see protocol [NEON.DOC.014041](http://data.neonscience.org/api/v0/documents/NEON.DOC.014041vF): TOS Protocol and Procedure: Breeding Landbird Abundance and Diversity and science design [NEON.DOC.000916](http://data.neonscience.org/api/v0/documents/NEON.DOC.000916vB): TOS Science Design for Breeding Landbird Abundance and Diversity."
    ## 
    ## $data$productDesignDescription
    ## [1] "Depending on the size of the site, sampling for this product occurs either at either randomly distributed individual points or grids of nine points each. At larger sites, point count sampling occurs at five to fifteen 9-point grids, with grid centers collocated with distributed base plot centers (where plant, beetle, and/or soil sampling may also occur), if possible. At smaller sites (i.e., sites that cannot accommodate a minimum of 5 grids) point counts occur at the southwest corner (point 21) of 5-25 distributed base plots. Point counts are conducted once per breeding season at large sites and twice per breeding season at smaller sites. Point counts are six minutes long, with each minute tracked by the observer, following a two-minute settling-in period. All birds are recorded to species and sex, whenever possible, and the distance to each individual or flock is measured with a laser rangefinder, except in the case of flyovers."
    ## 
    ## $data$productStudyDescription
    ## [1] "This sampling occurs at all NEON terrestrial sites."
    ## 
    ## $data$productSensor
    ## NULL
    ## 
    ## $data$productRemarks
    ## [1] "Queries for this data product will return data collected during the date range specified for brd_perpoint and brd_countdata, but will return data from all dates for brd_personnel (quiz scores may occur over time periods which are distinct from when sampling occurs) and brd_references (which apply to a broad range of sampling dates). A record from brd_perPoint should have 6+ child records in brd_countdata, at least one per pointCountMinute. Duplicates or missing data may exist where protocol and/or data entry aberrations have occurred; users should check data carefully for anomalies before joining tables. Taxonomic IDs of species of concern have been 'fuzzed'; see data package readme files for more information."
    ## 
    ## $data$themes
    ## $data$themes[[1]]
    ## [1] "Organisms, Populations, and Communities"
    ## 
    ## 
    ## $data$changeLogs
    ## NULL
    ## 
    ## $data$specs
    ## $data$specs[[1]]
    ## $data$specs[[1]]$specId
    ## [1] 3394
    ## 
    ## $data$specs[[1]]$specNumber
    ## [1] "NEON.DOC.000916vB"
    ## 
    ## 
    ## $data$specs[[2]]
    ## $data$specs[[2]]$specId
    ## [1] 2565
    ## 
    ## $data$specs[[2]]$specNumber
    ## [1] "NEON_bird_userGuide_vA"
    ## 
    ## 
    ## $data$specs[[3]]
    ## $data$specs[[3]]$specId
    ## [1] 2567
    ## 
    ## $data$specs[[3]]$specNumber
    ## [1] "NEON.DOC.014041vF"
    ## 
    ## 
    ## 
    ## $data$keywords
    ## $data$keywords[[1]]
    ## [1] "birds"
    ## 
    ## $data$keywords[[2]]
    ## [1] "diversity"
    ## 
    ## $data$keywords[[3]]
    ## [1] "taxonomy"
    ## 
    ## $data$keywords[[4]]
    ## [1] "community composition"
    ## 
    ## $data$keywords[[5]]
    ## [1] "distance sampling"
    ## 
    ## $data$keywords[[6]]
    ## [1] "avian"
    ## 
    ## $data$keywords[[7]]
    ## [1] "species composition"
    ## 
    ## $data$keywords[[8]]
    ## [1] "population"
    ## 
    ## $data$keywords[[9]]
    ## [1] "landbirds"
    ## 
    ## 
    ## $data$siteCodes
    ## $data$siteCodes[[1]]
    ## $data$siteCodes[[1]]$siteCode
    ## [1] "ORNL"
    ## 
    ## $data$siteCodes[[1]]$availableMonths
    ## $data$siteCodes[[1]]$availableMonths[[1]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[1]]$availableMonths[[2]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[1]]$availableMonths[[3]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[1]]$availableDataUrls
    ## $data$siteCodes[[1]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-05"
    ## 
    ## $data$siteCodes[[1]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-06"
    ## 
    ## $data$siteCodes[[1]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[2]]
    ## $data$siteCodes[[2]]$siteCode
    ## [1] "UKFS"
    ## 
    ## $data$siteCodes[[2]]$availableMonths
    ## $data$siteCodes[[2]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[2]]$availableDataUrls
    ## $data$siteCodes[[2]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UKFS/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[3]]
    ## $data$siteCodes[[3]]$siteCode
    ## [1] "CPER"
    ## 
    ## $data$siteCodes[[3]]$availableMonths
    ## $data$siteCodes[[3]]$availableMonths[[1]]
    ## [1] "2013-06"
    ## 
    ## $data$siteCodes[[3]]$availableMonths[[2]]
    ## [1] "2015-05"
    ## 
    ## $data$siteCodes[[3]]$availableMonths[[3]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[3]]$availableMonths[[4]]
    ## [1] "2017-05"
    ## 
    ## $data$siteCodes[[3]]$availableMonths[[5]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[3]]$availableDataUrls
    ## $data$siteCodes[[3]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2013-06"
    ## 
    ## $data$siteCodes[[3]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2015-05"
    ## 
    ## $data$siteCodes[[3]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2016-05"
    ## 
    ## $data$siteCodes[[3]]$availableDataUrls[[4]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-05"
    ## 
    ## $data$siteCodes[[3]]$availableDataUrls[[5]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[4]]
    ## $data$siteCodes[[4]]$siteCode
    ## [1] "WOOD"
    ## 
    ## $data$siteCodes[[4]]$availableMonths
    ## $data$siteCodes[[4]]$availableMonths[[1]]
    ## [1] "2015-07"
    ## 
    ## $data$siteCodes[[4]]$availableMonths[[2]]
    ## [1] "2017-07"
    ## 
    ## 
    ## $data$siteCodes[[4]]$availableDataUrls
    ## $data$siteCodes[[4]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2015-07"
    ## 
    ## $data$siteCodes[[4]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2017-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[5]]
    ## $data$siteCodes[[5]]$siteCode
    ## [1] "HEAL"
    ## 
    ## $data$siteCodes[[5]]$availableMonths
    ## $data$siteCodes[[5]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[5]]$availableDataUrls
    ## $data$siteCodes[[5]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HEAL/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[6]]
    ## $data$siteCodes[[6]]$siteCode
    ## [1] "TALL"
    ## 
    ## $data$siteCodes[[6]]$availableMonths
    ## $data$siteCodes[[6]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[6]]$availableMonths[[2]]
    ## [1] "2016-07"
    ## 
    ## $data$siteCodes[[6]]$availableMonths[[3]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[6]]$availableDataUrls
    ## $data$siteCodes[[6]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2015-06"
    ## 
    ## $data$siteCodes[[6]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2016-07"
    ## 
    ## $data$siteCodes[[6]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[7]]
    ## $data$siteCodes[[7]]$siteCode
    ## [1] "JERC"
    ## 
    ## $data$siteCodes[[7]]$availableMonths
    ## $data$siteCodes[[7]]$availableMonths[[1]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[7]]$availableMonths[[2]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[7]]$availableDataUrls
    ## $data$siteCodes[[7]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2016-06"
    ## 
    ## $data$siteCodes[[7]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[8]]
    ## $data$siteCodes[[8]]$siteCode
    ## [1] "NOGP"
    ## 
    ## $data$siteCodes[[8]]$availableMonths
    ## $data$siteCodes[[8]]$availableMonths[[1]]
    ## [1] "2017-07"
    ## 
    ## 
    ## $data$siteCodes[[8]]$availableDataUrls
    ## $data$siteCodes[[8]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NOGP/2017-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[9]]
    ## $data$siteCodes[[9]]$siteCode
    ## [1] "LAJA"
    ## 
    ## $data$siteCodes[[9]]$availableMonths
    ## $data$siteCodes[[9]]$availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[9]]$availableDataUrls
    ## $data$siteCodes[[9]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/LAJA/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[10]]
    ## $data$siteCodes[[10]]$siteCode
    ## [1] "OSBS"
    ## 
    ## $data$siteCodes[[10]]$availableMonths
    ## $data$siteCodes[[10]]$availableMonths[[1]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[10]]$availableMonths[[2]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[10]]$availableDataUrls
    ## $data$siteCodes[[10]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2016-05"
    ## 
    ## $data$siteCodes[[10]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[11]]
    ## $data$siteCodes[[11]]$siteCode
    ## [1] "DCFS"
    ## 
    ## $data$siteCodes[[11]]$availableMonths
    ## $data$siteCodes[[11]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## $data$siteCodes[[11]]$availableMonths[[2]]
    ## [1] "2017-07"
    ## 
    ## 
    ## $data$siteCodes[[11]]$availableDataUrls
    ## $data$siteCodes[[11]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-06"
    ## 
    ## $data$siteCodes[[11]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[12]]
    ## $data$siteCodes[[12]]$siteCode
    ## [1] "KONZ"
    ## 
    ## $data$siteCodes[[12]]$availableMonths
    ## $data$siteCodes[[12]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[12]]$availableDataUrls
    ## $data$siteCodes[[12]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/KONZ/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[13]]
    ## $data$siteCodes[[13]]$siteCode
    ## [1] "DEJU"
    ## 
    ## $data$siteCodes[[13]]$availableMonths
    ## $data$siteCodes[[13]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[13]]$availableDataUrls
    ## $data$siteCodes[[13]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DEJU/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[14]]
    ## $data$siteCodes[[14]]$siteCode
    ## [1] "LENO"
    ## 
    ## $data$siteCodes[[14]]$availableMonths
    ## $data$siteCodes[[14]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[14]]$availableDataUrls
    ## $data$siteCodes[[14]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/LENO/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[15]]
    ## $data$siteCodes[[15]]$siteCode
    ## [1] "RMNP"
    ## 
    ## $data$siteCodes[[15]]$availableMonths
    ## $data$siteCodes[[15]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## $data$siteCodes[[15]]$availableMonths[[2]]
    ## [1] "2017-07"
    ## 
    ## 
    ## $data$siteCodes[[15]]$availableDataUrls
    ## $data$siteCodes[[15]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/RMNP/2017-06"
    ## 
    ## $data$siteCodes[[15]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/RMNP/2017-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[16]]
    ## $data$siteCodes[[16]]$siteCode
    ## [1] "HARV"
    ## 
    ## $data$siteCodes[[16]]$availableMonths
    ## $data$siteCodes[[16]]$availableMonths[[1]]
    ## [1] "2015-05"
    ## 
    ## $data$siteCodes[[16]]$availableMonths[[2]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[16]]$availableMonths[[3]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[16]]$availableMonths[[4]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[16]]$availableDataUrls
    ## $data$siteCodes[[16]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-05"
    ## 
    ## $data$siteCodes[[16]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-06"
    ## 
    ## $data$siteCodes[[16]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2016-06"
    ## 
    ## $data$siteCodes[[16]]$availableDataUrls[[4]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[17]]
    ## $data$siteCodes[[17]]$siteCode
    ## [1] "BART"
    ## 
    ## $data$siteCodes[[17]]$availableMonths
    ## $data$siteCodes[[17]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[17]]$availableMonths[[2]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[17]]$availableMonths[[3]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[17]]$availableDataUrls
    ## $data$siteCodes[[17]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2015-06"
    ## 
    ## $data$siteCodes[[17]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2016-06"
    ## 
    ## $data$siteCodes[[17]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[18]]
    ## $data$siteCodes[[18]]$siteCode
    ## [1] "BONA"
    ## 
    ## $data$siteCodes[[18]]$availableMonths
    ## $data$siteCodes[[18]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[18]]$availableDataUrls
    ## $data$siteCodes[[18]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BONA/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[19]]
    ## $data$siteCodes[[19]]$siteCode
    ## [1] "BARR"
    ## 
    ## $data$siteCodes[[19]]$availableMonths
    ## $data$siteCodes[[19]]$availableMonths[[1]]
    ## [1] "2017-07"
    ## 
    ## 
    ## $data$siteCodes[[19]]$availableDataUrls
    ## $data$siteCodes[[19]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BARR/2017-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[20]]
    ## $data$siteCodes[[20]]$siteCode
    ## [1] "SJER"
    ## 
    ## $data$siteCodes[[20]]$availableMonths
    ## $data$siteCodes[[20]]$availableMonths[[1]]
    ## [1] "2017-04"
    ## 
    ## 
    ## $data$siteCodes[[20]]$availableDataUrls
    ## $data$siteCodes[[20]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SJER/2017-04"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[21]]
    ## $data$siteCodes[[21]]$siteCode
    ## [1] "JORN"
    ## 
    ## $data$siteCodes[[21]]$availableMonths
    ## $data$siteCodes[[21]]$availableMonths[[1]]
    ## [1] "2017-04"
    ## 
    ## $data$siteCodes[[21]]$availableMonths[[2]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[21]]$availableDataUrls
    ## $data$siteCodes[[21]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-04"
    ## 
    ## $data$siteCodes[[21]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[22]]
    ## $data$siteCodes[[22]]$siteCode
    ## [1] "STEI"
    ## 
    ## $data$siteCodes[[22]]$availableMonths
    ## $data$siteCodes[[22]]$availableMonths[[1]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[22]]$availableMonths[[2]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[22]]$availableMonths[[3]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[22]]$availableDataUrls
    ## $data$siteCodes[[22]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-05"
    ## 
    ## $data$siteCodes[[22]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-06"
    ## 
    ## $data$siteCodes[[22]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[23]]
    ## $data$siteCodes[[23]]$siteCode
    ## [1] "GRSM"
    ## 
    ## $data$siteCodes[[23]]$availableMonths
    ## $data$siteCodes[[23]]$availableMonths[[1]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[23]]$availableMonths[[2]]
    ## [1] "2017-05"
    ## 
    ## $data$siteCodes[[23]]$availableMonths[[3]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[23]]$availableDataUrls
    ## $data$siteCodes[[23]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2016-06"
    ## 
    ## $data$siteCodes[[23]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2017-05"
    ## 
    ## $data$siteCodes[[23]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[24]]
    ## $data$siteCodes[[24]]$siteCode
    ## [1] "OAES"
    ## 
    ## $data$siteCodes[[24]]$availableMonths
    ## $data$siteCodes[[24]]$availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## $data$siteCodes[[24]]$availableMonths[[2]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[24]]$availableDataUrls
    ## $data$siteCodes[[24]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OAES/2017-05"
    ## 
    ## $data$siteCodes[[24]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OAES/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[25]]
    ## $data$siteCodes[[25]]$siteCode
    ## [1] "SERC"
    ## 
    ## $data$siteCodes[[25]]$availableMonths
    ## $data$siteCodes[[25]]$availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## $data$siteCodes[[25]]$availableMonths[[2]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[25]]$availableDataUrls
    ## $data$siteCodes[[25]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SERC/2017-05"
    ## 
    ## $data$siteCodes[[25]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SERC/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[26]]
    ## $data$siteCodes[[26]]$siteCode
    ## [1] "ABBY"
    ## 
    ## $data$siteCodes[[26]]$availableMonths
    ## $data$siteCodes[[26]]$availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## $data$siteCodes[[26]]$availableMonths[[2]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[26]]$availableDataUrls
    ## $data$siteCodes[[26]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ABBY/2017-05"
    ## 
    ## $data$siteCodes[[26]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ABBY/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[27]]
    ## $data$siteCodes[[27]]$siteCode
    ## [1] "MOAB"
    ## 
    ## $data$siteCodes[[27]]$availableMonths
    ## $data$siteCodes[[27]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[27]]$availableMonths[[2]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[27]]$availableDataUrls
    ## $data$siteCodes[[27]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/MOAB/2015-06"
    ## 
    ## $data$siteCodes[[27]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/MOAB/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[28]]
    ## $data$siteCodes[[28]]$siteCode
    ## [1] "BLAN"
    ## 
    ## $data$siteCodes[[28]]$availableMonths
    ## $data$siteCodes[[28]]$availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## $data$siteCodes[[28]]$availableMonths[[2]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[28]]$availableDataUrls
    ## $data$siteCodes[[28]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BLAN/2017-05"
    ## 
    ## $data$siteCodes[[28]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BLAN/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[29]]
    ## $data$siteCodes[[29]]$siteCode
    ## [1] "STER"
    ## 
    ## $data$siteCodes[[29]]$availableMonths
    ## $data$siteCodes[[29]]$availableMonths[[1]]
    ## [1] "2013-06"
    ## 
    ## $data$siteCodes[[29]]$availableMonths[[2]]
    ## [1] "2015-05"
    ## 
    ## $data$siteCodes[[29]]$availableMonths[[3]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[29]]$availableMonths[[4]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[29]]$availableDataUrls
    ## $data$siteCodes[[29]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2013-06"
    ## 
    ## $data$siteCodes[[29]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2015-05"
    ## 
    ## $data$siteCodes[[29]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2016-05"
    ## 
    ## $data$siteCodes[[29]]$availableDataUrls[[4]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[30]]
    ## $data$siteCodes[[30]]$siteCode
    ## [1] "DELA"
    ## 
    ## $data$siteCodes[[30]]$availableMonths
    ## $data$siteCodes[[30]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[30]]$availableMonths[[2]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[30]]$availableDataUrls
    ## $data$siteCodes[[30]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DELA/2015-06"
    ## 
    ## $data$siteCodes[[30]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DELA/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[31]]
    ## $data$siteCodes[[31]]$siteCode
    ## [1] "SRER"
    ## 
    ## $data$siteCodes[[31]]$availableMonths
    ## $data$siteCodes[[31]]$availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[31]]$availableDataUrls
    ## $data$siteCodes[[31]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SRER/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[32]]
    ## $data$siteCodes[[32]]$siteCode
    ## [1] "ONAQ"
    ## 
    ## $data$siteCodes[[32]]$availableMonths
    ## $data$siteCodes[[32]]$availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[32]]$availableDataUrls
    ## $data$siteCodes[[32]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ONAQ/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[33]]
    ## $data$siteCodes[[33]]$siteCode
    ## [1] "SOAP"
    ## 
    ## $data$siteCodes[[33]]$availableMonths
    ## $data$siteCodes[[33]]$availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[33]]$availableDataUrls
    ## $data$siteCodes[[33]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SOAP/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[34]]
    ## $data$siteCodes[[34]]$siteCode
    ## [1] "CLBJ"
    ## 
    ## $data$siteCodes[[34]]$availableMonths
    ## $data$siteCodes[[34]]$availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[34]]$availableDataUrls
    ## $data$siteCodes[[34]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CLBJ/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[35]]
    ## $data$siteCodes[[35]]$siteCode
    ## [1] "SCBI"
    ## 
    ## $data$siteCodes[[35]]$availableMonths
    ## $data$siteCodes[[35]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[35]]$availableMonths[[2]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[35]]$availableMonths[[3]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[35]]$availableMonths[[4]]
    ## [1] "2017-05"
    ## 
    ## $data$siteCodes[[35]]$availableMonths[[5]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[35]]$availableDataUrls
    ## $data$siteCodes[[35]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2015-06"
    ## 
    ## $data$siteCodes[[35]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-05"
    ## 
    ## $data$siteCodes[[35]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-06"
    ## 
    ## $data$siteCodes[[35]]$availableDataUrls[[4]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2017-05"
    ## 
    ## $data$siteCodes[[35]]$availableDataUrls[[5]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[36]]
    ## $data$siteCodes[[36]]$siteCode
    ## [1] "NIWO"
    ## 
    ## $data$siteCodes[[36]]$availableMonths
    ## $data$siteCodes[[36]]$availableMonths[[1]]
    ## [1] "2015-07"
    ## 
    ## $data$siteCodes[[36]]$availableMonths[[2]]
    ## [1] "2017-07"
    ## 
    ## 
    ## $data$siteCodes[[36]]$availableDataUrls
    ## $data$siteCodes[[36]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NIWO/2015-07"
    ## 
    ## $data$siteCodes[[36]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NIWO/2017-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[37]]
    ## $data$siteCodes[[37]]$siteCode
    ## [1] "TREE"
    ## 
    ## $data$siteCodes[[37]]$availableMonths
    ## $data$siteCodes[[37]]$availableMonths[[1]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[37]]$availableMonths[[2]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[37]]$availableDataUrls
    ## $data$siteCodes[[37]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2016-06"
    ## 
    ## $data$siteCodes[[37]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[38]]
    ## $data$siteCodes[[38]]$siteCode
    ## [1] "DSNY"
    ## 
    ## $data$siteCodes[[38]]$availableMonths
    ## $data$siteCodes[[38]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[38]]$availableMonths[[2]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[38]]$availableMonths[[3]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[38]]$availableDataUrls
    ## $data$siteCodes[[38]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2015-06"
    ## 
    ## $data$siteCodes[[38]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2016-05"
    ## 
    ## $data$siteCodes[[38]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[39]]
    ## $data$siteCodes[[39]]$siteCode
    ## [1] "GUAN"
    ## 
    ## $data$siteCodes[[39]]$availableMonths
    ## $data$siteCodes[[39]]$availableMonths[[1]]
    ## [1] "2015-05"
    ## 
    ## $data$siteCodes[[39]]$availableMonths[[2]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[39]]$availableDataUrls
    ## $data$siteCodes[[39]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2015-05"
    ## 
    ## $data$siteCodes[[39]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[40]]
    ## $data$siteCodes[[40]]$siteCode
    ## [1] "TEAK"
    ## 
    ## $data$siteCodes[[40]]$availableMonths
    ## $data$siteCodes[[40]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[40]]$availableDataUrls
    ## $data$siteCodes[[40]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TEAK/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[41]]
    ## $data$siteCodes[[41]]$siteCode
    ## [1] "UNDE"
    ## 
    ## $data$siteCodes[[41]]$availableMonths
    ## $data$siteCodes[[41]]$availableMonths[[1]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[41]]$availableMonths[[2]]
    ## [1] "2016-07"
    ## 
    ## $data$siteCodes[[41]]$availableMonths[[3]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[41]]$availableDataUrls
    ## $data$siteCodes[[41]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-06"
    ## 
    ## $data$siteCodes[[41]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-07"
    ## 
    ## $data$siteCodes[[41]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[42]]
    ## $data$siteCodes[[42]]$siteCode
    ## [1] "TOOL"
    ## 
    ## $data$siteCodes[[42]]$availableMonths
    ## $data$siteCodes[[42]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[42]]$availableDataUrls
    ## $data$siteCodes[[42]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TOOL/2017-06"

To get a more accessible view of which sites have data for which months, you'll 
need to extract data from the nested list. There are a variety of ways to do this, 
in this tutorial we'll explore a couple of them. Here we'll use `fromJSON()`, in 
the jsonlite package, which doesn't fully flatten the nested list, but gets us 
the part we need. To use it, we need a text version of the content. Data this 
way is not as human readable but is readable by the `fromJSON()` function. 


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
    ## $data$productAbstract
    ## [1] "This data product contains the quality-controlled, native sampling resolution data from NEON's breeding landbird sampling. Breeding landbirds are defined as “smaller birds (usually exclusive of raptors and upland game birds) not usually associated with aquatic habitats” (Ralph et al. 1993). The breeding landbird point counts product provides records of species identification of all individuals observed during the 6-minute count period, as well as metadata which can be used to model detectability, e.g., weather, distances from observers to birds, and detection methods. The NEON point count method is adapted from the Integrated Monitoring in Bird Conservation Regions (IMBCR): Field protocol for spatially-balanced sampling of landbird populations (Hanni et al. 2017; http://bit.ly/2u2ChUB). For additional details, see protocol [NEON.DOC.014041](http://data.neonscience.org/api/v0/documents/NEON.DOC.014041vF): TOS Protocol and Procedure: Breeding Landbird Abundance and Diversity and science design [NEON.DOC.000916](http://data.neonscience.org/api/v0/documents/NEON.DOC.000916vB): TOS Science Design for Breeding Landbird Abundance and Diversity."
    ## 
    ## $data$productDesignDescription
    ## [1] "Depending on the size of the site, sampling for this product occurs either at either randomly distributed individual points or grids of nine points each. At larger sites, point count sampling occurs at five to fifteen 9-point grids, with grid centers collocated with distributed base plot centers (where plant, beetle, and/or soil sampling may also occur), if possible. At smaller sites (i.e., sites that cannot accommodate a minimum of 5 grids) point counts occur at the southwest corner (point 21) of 5-25 distributed base plots. Point counts are conducted once per breeding season at large sites and twice per breeding season at smaller sites. Point counts are six minutes long, with each minute tracked by the observer, following a two-minute settling-in period. All birds are recorded to species and sex, whenever possible, and the distance to each individual or flock is measured with a laser rangefinder, except in the case of flyovers."
    ## 
    ## $data$productStudyDescription
    ## [1] "This sampling occurs at all NEON terrestrial sites."
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
    ## 1   3394      NEON.DOC.000916vB
    ## 2   2565 NEON_bird_userGuide_vA
    ## 3   2567      NEON.DOC.014041vF
    ## 
    ## $data$keywords
    ## [1] "birds"                 "diversity"             "taxonomy"             
    ## [4] "community composition" "distance sampling"     "avian"                
    ## [7] "species composition"   "population"            "landbirds"            
    ## 
    ## $data$siteCodes
    ##    siteCode                             availableMonths
    ## 1      ORNL                   2016-05, 2016-06, 2017-05
    ## 2      UKFS                                     2017-06
    ## 3      CPER 2013-06, 2015-05, 2016-05, 2017-05, 2017-06
    ## 4      WOOD                            2015-07, 2017-07
    ## 5      HEAL                                     2017-06
    ## 6      TALL                   2015-06, 2016-07, 2017-06
    ## 7      JERC                            2016-06, 2017-05
    ## 8      NOGP                                     2017-07
    ## 9      LAJA                                     2017-05
    ## 10     OSBS                            2016-05, 2017-05
    ## 11     DCFS                            2017-06, 2017-07
    ## 12     KONZ                                     2017-06
    ## 13     DEJU                                     2017-06
    ## 14     LENO                                     2017-06
    ## 15     RMNP                            2017-06, 2017-07
    ## 16     HARV          2015-05, 2015-06, 2016-06, 2017-06
    ## 17     BART                   2015-06, 2016-06, 2017-06
    ## 18     BONA                                     2017-06
    ## 19     BARR                                     2017-07
    ## 20     SJER                                     2017-04
    ## 21     JORN                            2017-04, 2017-05
    ## 22     STEI                   2016-05, 2016-06, 2017-06
    ## 23     GRSM                   2016-06, 2017-05, 2017-06
    ## 24     OAES                            2017-05, 2017-06
    ## 25     SERC                            2017-05, 2017-06
    ## 26     ABBY                            2017-05, 2017-06
    ## 27     MOAB                            2015-06, 2017-05
    ## 28     BLAN                            2017-05, 2017-06
    ## 29     STER          2013-06, 2015-05, 2016-05, 2017-05
    ## 30     DELA                            2015-06, 2017-06
    ## 31     SRER                                     2017-05
    ## 32     ONAQ                                     2017-05
    ## 33     SOAP                                     2017-05
    ## 34     CLBJ                                     2017-05
    ## 35     SCBI 2015-06, 2016-05, 2016-06, 2017-05, 2017-06
    ## 36     NIWO                            2015-07, 2017-07
    ## 37     TREE                            2016-06, 2017-06
    ## 38     DSNY                   2015-06, 2016-05, 2017-05
    ## 39     GUAN                            2015-05, 2017-05
    ## 40     TEAK                                     2017-06
    ## 41     UNDE                   2016-06, 2016-07, 2017-06
    ## 42     TOOL                                     2017-06
    ##                                                                                                                                                                                                                                                                                                                                                    availableDataUrls
    ## 1                                                                                                                                                http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2017-05
    ## 2                                                                                                                                                                                                                                                                                              http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UKFS/2017-06
    ## 3  http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2013-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2015-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-06
    ## 4                                                                                                                                                                                                                       http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2015-07, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2017-07
    ## 5                                                                                                                                                                                                                                                                                              http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HEAL/2017-06
    ## 6                                                                                                                                                http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2016-07, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2017-06
    ## 7                                                                                                                                                                                                                       http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2017-05
    ## 8                                                                                                                                                                                                                                                                                              http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NOGP/2017-07
    ## 9                                                                                                                                                                                                                                                                                              http://data.neonscience.org:80/api/v0/data/DP1.10003.001/LAJA/2017-05
    ## 10                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2017-05
    ## 11                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-07
    ## 12                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/KONZ/2017-06
    ## 13                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DEJU/2017-06
    ## 14                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/LENO/2017-06
    ## 15                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/RMNP/2017-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/RMNP/2017-07
    ## 16                                                                        http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2017-06
    ## 17                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2017-06
    ## 18                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BONA/2017-06
    ## 19                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BARR/2017-07
    ## 20                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SJER/2017-04
    ## 21                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-04, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-05
    ## 22                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2017-06
    ## 23                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2017-06
    ## 24                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OAES/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OAES/2017-06
    ## 25                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SERC/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SERC/2017-06
    ## 26                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ABBY/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ABBY/2017-06
    ## 27                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/MOAB/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/MOAB/2017-05
    ## 28                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BLAN/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BLAN/2017-06
    ## 29                                                                        http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2013-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2015-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2017-05
    ## 30                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DELA/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DELA/2017-06
    ## 31                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SRER/2017-05
    ## 32                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ONAQ/2017-05
    ## 33                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SOAP/2017-05
    ## 34                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CLBJ/2017-05
    ## 35 http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2017-06
    ## 36                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NIWO/2015-07, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NIWO/2017-07
    ## 37                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2017-06
    ## 38                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2017-05
    ## 39                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2015-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2017-05
    ## 40                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TEAK/2017-06
    ## 41                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-07, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2017-06
    ## 42                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TOOL/2017-06

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
    bird.urls

    ##  [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-05"
    ##  [2] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-06"
    ##  [3] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2017-05"
    ##  [4] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UKFS/2017-06"
    ##  [5] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2013-06"
    ##  [6] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2015-05"
    ##  [7] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2016-05"
    ##  [8] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-05"
    ##  [9] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-06"
    ## [10] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2015-07"
    ## [11] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2017-07"
    ## [12] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HEAL/2017-06"
    ## [13] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2015-06"
    ## [14] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2016-07"
    ## [15] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2017-06"
    ## [16] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2016-06"
    ## [17] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2017-05"
    ## [18] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NOGP/2017-07"
    ## [19] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/LAJA/2017-05"
    ## [20] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2016-05"
    ## [21] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2017-05"
    ## [22] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-06"
    ## [23] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-07"
    ## [24] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/KONZ/2017-06"
    ## [25] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DEJU/2017-06"
    ## [26] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/LENO/2017-06"
    ## [27] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/RMNP/2017-06"
    ## [28] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/RMNP/2017-07"
    ## [29] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-05"
    ## [30] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-06"
    ## [31] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2016-06"
    ## [32] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2017-06"
    ## [33] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2015-06"
    ## [34] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2016-06"
    ## [35] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2017-06"
    ## [36] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BONA/2017-06"
    ## [37] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BARR/2017-07"
    ## [38] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SJER/2017-04"
    ## [39] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-04"
    ## [40] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-05"
    ## [41] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-05"
    ## [42] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-06"
    ## [43] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2017-06"
    ## [44] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2016-06"
    ## [45] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2017-05"
    ## [46] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2017-06"
    ## [47] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OAES/2017-05"
    ## [48] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OAES/2017-06"
    ## [49] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SERC/2017-05"
    ## [50] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SERC/2017-06"
    ## [51] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ABBY/2017-05"
    ## [52] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ABBY/2017-06"
    ## [53] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/MOAB/2015-06"
    ## [54] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/MOAB/2017-05"
    ## [55] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BLAN/2017-05"
    ## [56] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BLAN/2017-06"
    ## [57] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2013-06"
    ## [58] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2015-05"
    ## [59] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2016-05"
    ## [60] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2017-05"
    ## [61] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DELA/2015-06"
    ## [62] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DELA/2017-06"
    ## [63] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SRER/2017-05"
    ## [64] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ONAQ/2017-05"
    ## [65] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SOAP/2017-05"
    ## [66] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CLBJ/2017-05"
    ## [67] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2015-06"
    ## [68] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-05"
    ## [69] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-06"
    ## [70] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2017-05"
    ## [71] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2017-06"
    ## [72] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NIWO/2015-07"
    ## [73] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NIWO/2017-07"
    ## [74] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2016-06"
    ## [75] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2017-06"
    ## [76] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2015-06"
    ## [77] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2016-05"
    ## [78] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2017-05"
    ## [79] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2015-05"
    ## [80] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2017-05"
    ## [81] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TEAK/2017-06"
    ## [82] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-06"
    ## [83] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-07"
    ## [84] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2017-06"
    ## [85] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TOOL/2017-06"

These are the URLs showing us what files are available for each month where 
there are data. 

Let's look at the bird data from Woodworth (WOOD) site from July 2015. We can do 
this by using the above code but now specifying which site/date we want using 
the `grep()` function. 

Note, that if there was only one month of data from a site, you can leave off the
date in the function. If you want date from more than one site/month you need 
to iterate this code, GET fails if you give it more than one URL. 


    # get data availability for WOOD July 2015
    brd <- GET(bird.urls[grep("WOOD/2015-07", bird.urls)])
    brd.files <- fromJSON(content(brd, as="text"))
    
    # view just the available data files 
    brd.files$data$files

    ##                               crc32
    ## 1  4d4f86c1379dece680185e992a471432
    ## 2  71e695abae2d1943d13e53c95430c6f5
    ## 3  dd27e83b9a5e4a7453f284ae13d1f32d
    ## 4  7c999e9ae4f7d94eaa2c11aadaeecd0b
    ## 5  19adfd2c8bedfe867646644e1985dca0
    ## 6  0cde0267b9141a0f37a14dc7e5c7084a
    ## 7  5428880d2a72e66319eb6f29576a49af
    ## 8  4d4f86c1379dece680185e992a471432
    ## 9  51b19ca519653f87c7732791b345f89e
    ## 10 bba1d7554ff524604e64ffcb0b23c0b0
    ## 11 19adfd2c8bedfe867646644e1985dca0
    ## 12 02506292f09b5a4ebcc055b279621f8e
    ## 13 28bbedc80a738c2cd16afad21319136f
    ## 14 81ddde9f27c7ba6d5a9f6cfb07ae78d3
    ## 15 dd27e83b9a5e4a7453f284ae13d1f32d
    ## 16 8dca69c9edcf4f3df4ee7fa3a0a624dc
    ##                                                                               name
    ## 1      NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.basic.20180418T200718Z.csv
    ## 2           NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20180418T200718Z.xml
    ## 3                       NEON.D09.WOOD.DP1.10003.001.variables.20180418T200718Z.csv
    ## 4     NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.basic.20180418T200718Z.csv
    ## 5                      NEON.D09.WOOD.DP0.10003.001.validation.20180418T200718Z.csv
    ## 6                   NEON.D09.WOOD.DP1.10003.001.2015-07.basic.20180418T200718Z.zip
    ## 7                          NEON.D09.WOOD.DP1.10003.001.readme.20180418T200718Z.txt
    ## 8   NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.expanded.20180418T200718Z.csv
    ## 9                          NEON.D09.WOOD.DP1.10003.001.readme.20180418T200718Z.txt
    ## 10                          NEON.Bird_Conservancy_of_the_Rockies.brd_personnel.csv
    ## 11                     NEON.D09.WOOD.DP0.10003.001.validation.20180418T200718Z.csv
    ## 12          NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20180418T200718Z.xml
    ## 13               NEON.D09.WOOD.DP1.10003.001.2015-07.expanded.20180418T200718Z.zip
    ## 14 NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.expanded.20180418T200718Z.csv
    ## 15                      NEON.D09.WOOD.DP1.10003.001.variables.20180418T200718Z.csv
    ## 16        NEON.D09.WOOD.DP1.10003.001.brd_references.expanded.20180418T200718Z.csv
    ##      size
    ## 1   23962
    ## 2   70196
    ## 3    7280
    ## 4  355660
    ## 5    9830
    ## 6   67654
    ## 7   12361
    ## 8   23962
    ## 9   12640
    ## 10  11918
    ## 11   9830
    ## 12  78407
    ## 13  72540
    ## 14 376383
    ## 15   7280
    ## 16    650
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        url
    ## 1         https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.basic.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=33701fac26e94c358cce45932e81161bd71cadb24536c72edb9590a4ac8410ff
    ## 2              https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20180418T200718Z.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=901d9e64ea2a0af111dac871bf35953775e715aa85bb7fd8f513b2330df0177b
    ## 3                          https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.variables.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=7a7a9ca4da0e4989d231c20385b32addc096148ae89d9c1ea4e9503474ff0041
    ## 4        https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.basic.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=9c55a56bc475804876443f97d5eb933d17d772cb71e1e3b9cc21854062f6c0f0
    ## 5                         https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP0.10003.001.validation.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=de3a850035e46da380d4901b0868f09c86a102559bd58f47c87d8c954a3f93b0
    ## 6                      https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.2015-07.basic.20180418T200718Z.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=1520893d033850eaec6393effc10a1f0cdc9a4a201e8d895d485aed9b5fd1ea3
    ## 7                             https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.readme.20180418T200718Z.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=b886fd97f6f371a063ffc2e5f8c36ca053dd938f51ceccb0e7b1545be41e0bff
    ## 8   https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.expanded.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=6e73c3fbb7855d08d5b10514d95772931f42df4490345f524e0b2edbf4faa02f
    ## 9                          https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.readme.20180418T200718Z.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=0a10ca81ad41453c34b78609e727c2958f9351d6a0d7c0947ea6047f00ce5182
    ## 10                          https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.Bird_Conservancy_of_the_Rockies.brd_personnel.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=3c1fc705305556fe6d76cc7ec0d0aa62df1f2013126a0fb444e13427104455c6
    ## 11                     https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP0.10003.001.validation.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=5d73447fa8006a630b651ede40fc1ddab06b59db99e7cb80121da55a39b4bc0b
    ## 12          https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20180418T200718Z.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=fe5139191b9d400d61bbb66df20bde73aeb1d82bf73aa93f6907bd517d3522dd
    ## 13               https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.2015-07.expanded.20180418T200718Z.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=d7b28758c1a3a33779fe0690f7bc855822595e6d85a5ff44b060e176b1a86873
    ## 14 https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.expanded.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=e12b3da1e85b92f7c055f19731dd97474448dfd397f6297302c6f89a7f04ea9a
    ## 15                      https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.variables.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=53ec4d87ec442159fff2bfa31b3ab8fe8d05ec38a70bd3f42ccd708cd9770ae8
    ## 16        https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.brd_references.expanded.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180424T202614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180424%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=5f0ae38dcc2abdf8dc21e53898eea75068faed67a61a356c9b5aecb8083a2230

In this output, `name` and `url` are key fields. It provides us with the names 
of the files available for this site and month, and URLs where we can get the 
files. We'll use the file names to pick which ones we want.

The available files include both **data** and **metadata**, and both the **basic**
and **expanded** data packages. Typically the expanded package includes additional 
quality or uncertainty data, either in additional files or additional fields 
than in the basic files. Basic and expanded data packages are available for 
most NEON data products (some only have basic). Metadata are described by file 
name below.

The format for most of the file names are:

**NEON.[domain number].[site code].[data product ID].[file-specific name].
[date of file creation] **

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
                            [intersect(grep("countdata", brd.files$data$files$name),
                                        grep("basic", brd.files$data$files$name))], sep=",")
    
    brd.point <- read.delim(brd.files$data$files$url
                            [intersect(grep("perpoint", brd.files$data$files$name),
                                        grep("basic", brd.files$data$files$name))], sep=",")

Now we have the data and can access it in R. Just to show that the files we 
pulled have actual data in them, let's make a quick graphic showing 


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
    tmp.files$data$files$name

    ##   [1] "NEON.D13.MOAB.DP1.00041.001.003.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [2] "NEON.D13.MOAB.DP1.00041.001.004.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [3] "NEON.D13.MOAB.DP1.00041.001.004.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##   [4] "NEON.D13.MOAB.DP1.00041.001.001.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [5] "NEON.D13.MOAB.DP1.00041.001.003.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##   [6] "NEON.D13.MOAB.DP1.00041.001.001.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##   [7] "NEON.D13.MOAB.DP1.00041.001.001.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [8] "NEON.D13.MOAB.DP1.00041.001.005.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [9] "NEON.D13.MOAB.DP1.00041.001.003.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [10] "NEON.D13.MOAB.DP1.00041.001.004.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [11] "NEON.D13.MOAB.DP1.00041.001.004.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [12] "NEON.D13.MOAB.DP1.00041.001.003.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [13] "NEON.D13.MOAB.DP1.00041.001.005.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [14] "NEON.D13.MOAB.DP1.00041.001.005.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [15] "NEON.D13.MOAB.DP1.00041.001.004.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [16] "NEON.D13.MOAB.DP1.00041.001.001.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [17] "NEON.D13.MOAB.DP1.00041.001.004.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [18] "NEON.D13.MOAB.DP1.00041.001.002.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [19] "NEON.D13.MOAB.DP1.00041.001.001.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [20] "NEON.D13.MOAB.DP1.00041.001.005.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [21] "NEON.D13.MOAB.DP1.00041.001.005.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [22] "NEON.D13.MOAB.DP1.00041.001.002.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [23] "NEON.D13.MOAB.DP1.00041.001.003.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [24] "NEON.D13.MOAB.DP1.00041.001.004.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [25] "NEON.D13.MOAB.DP1.00041.001.002.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [26] "NEON.D13.MOAB.DP1.00041.001.005.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [27] "NEON.D13.MOAB.DP1.00041.001.004.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [28] "NEON.D13.MOAB.DP1.00041.001.002.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [29] "NEON.D13.MOAB.DP1.00041.001.001.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [30] "NEON.D13.MOAB.DP1.00041.001.002.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [31] "NEON.D13.MOAB.DP1.00041.001.003.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [32] "NEON.D13.MOAB.DP1.00041.001.001.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [33] "NEON.D13.MOAB.DP1.00041.001.005.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [34] "NEON.D13.MOAB.DP1.00041.001.001.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [35] "NEON.D13.MOAB.DP1.00041.001.004.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [36] "NEON.D13.MOAB.DP1.00041.001.004.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [37] "NEON.D13.MOAB.DP1.00041.001.005.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [38] "NEON.D13.MOAB.DP1.00041.001.003.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [39] "NEON.D13.MOAB.DP1.00041.001.20170308-20170401.xml"                                         
    ##  [40] "NEON.D13.MOAB.DP1.00041.001.002.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [41] "NEON.D13.MOAB.DP1.00041.001.003.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [42] "NEON.D13.MOAB.DP1.00041.001.003.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [43] "NEON.D13.MOAB.DP1.00041.001.004.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [44] "NEON.D13.MOAB.DP1.00041.001.005.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [45] "NEON.D13.MOAB.DP1.00041.001.003.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [46] "NEON.D13.MOAB.DP1.00041.001.002.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [47] "NEON.D13.MOAB.DP1.00041.001.004.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [48] "NEON.D13.MOAB.DP1.00041.001.004.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [49] "NEON.D13.MOAB.DP1.00041.001.003.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [50] "NEON.D13.MOAB.DP1.00041.001.004.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [51] "NEON.D13.MOAB.DP1.00041.001.004.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [52] "NEON.D13.MOAB.DP1.00041.001.001.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [53] "NEON.D13.MOAB.DP1.00041.001.005.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [54] "NEON.D13.MOAB.DP1.00041.001.002.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [55] "NEON.D13.MOAB.DP1.00041.001.001.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [56] "NEON.D13.MOAB.DP1.00041.001.005.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [57] "NEON.D13.MOAB.DP1.00041.001.003.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [58] "NEON.D13.MOAB.DP1.00041.001.004.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [59] "NEON.D13.MOAB.DP1.00041.001.002.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [60] "NEON.D13.MOAB.DP1.00041.001.002.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [61] "NEON.D13.MOAB.DP1.00041.001.005.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [62] "NEON.D13.MOAB.DP1.00041.001.002.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [63] "NEON.D13.MOAB.DP1.00041.001.005.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [64] "NEON.D13.MOAB.DP1.00041.001.003.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [65] "NEON.D13.MOAB.DP1.00041.001.002.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [66] "NEON.D13.MOAB.DP1.00041.001.003.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [67] "NEON.D13.MOAB.DP1.00041.001.001.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [68] "NEON.D13.MOAB.DP1.00041.001.002.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [69] "NEON.D13.MOAB.DP1.00041.001.001.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [70] "NEON.D13.MOAB.DP1.00041.001.003.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [71] "NEON.D13.MOAB.DP1.00041.001.2017-03.basic.20170804T063725Z.zip"                            
    ##  [72] "NEON.D13.MOAB.DP1.00041.001.003.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [73] "NEON.DP1.00041.001_readme.txt"                                                             
    ##  [74] "NEON.D13.MOAB.DP1.00041.001.005.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [75] "NEON.D13.MOAB.DP1.00041.001.002.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [76] "NEON.D13.MOAB.DP1.00041.001.001.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [77] "NEON.D13.MOAB.DP1.00041.001.001.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [78] "NEON.D13.MOAB.DP1.00041.001.003.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [79] "NEON.D13.MOAB.DP1.00041.001.004.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [80] "NEON.D13.MOAB.DP1.00041.001.001.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [81] "NEON.D13.MOAB.DP1.00041.001.004.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [82] "NEON.D13.MOAB.DP1.00041.001.001.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [83] "NEON.D13.MOAB.DP1.00041.001.005.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [84] "NEON.D13.MOAB.DP1.00041.001.005.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [85] "NEON.D13.MOAB.DP1.00041.001.002.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [86] "NEON.D13.MOAB.DP1.00041.001.005.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [87] "NEON.D13.MOAB.DP1.00041.001.002.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [88] "NEON.D13.MOAB.DP1.00041.001.002.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [89] "NEON.D13.MOAB.DP1.00041.001.variables.20170804T063725Z.csv"                                
    ##  [90] "NEON.D13.MOAB.DP1.00041.001.003.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [91] "NEON.D13.MOAB.DP1.00041.001.005.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [92] "NEON.D13.MOAB.DP1.00041.001.001.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [93] "NEON.D13.MOAB.DP1.00041.001.002.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [94] "NEON.D13.MOAB.DP1.00041.001.001.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [95] "NEON.D13.MOAB.DP1.00041.001.003.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ##  [96] "NEON.D13.MOAB.DP1.00041.001.003.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ##  [97] "NEON.D13.MOAB.DP1.00041.001.005.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ##  [98] "NEON.D13.MOAB.DP1.00041.001.2017-03.expanded.20170804T063725Z.zip"                         
    ##  [99] "NEON.D13.MOAB.DP1.00041.001.004.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [100] "NEON.D13.MOAB.DP1.00041.001.004.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [101] "NEON.D13.MOAB.DP1.00041.001.005.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [102] "NEON.D13.MOAB.DP1.00041.001.003.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [103] "NEON.D13.MOAB.DP1.00041.001.004.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [104] "NEON.D13.MOAB.DP1.00041.001.002.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [105] "NEON.D13.MOAB.DP1.00041.001.002.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [106] "NEON.D13.MOAB.DP1.00041.001.003.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [107] "NEON.D13.MOAB.DP1.00041.001.001.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [108] "NEON.D13.MOAB.DP1.00041.001.003.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [109] "NEON.D13.MOAB.DP1.00041.001.001.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [110] "NEON.D13.MOAB.DP1.00041.001.002.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [111] "NEON.D13.MOAB.DP1.00041.001.005.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [112] "NEON.D13.MOAB.DP1.00041.001.001.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [113] "NEON.D13.MOAB.DP1.00041.001.001.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [114] "NEON.D13.MOAB.DP1.00041.001.002.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [115] "NEON.D13.MOAB.DP1.00041.001.004.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [116] "NEON.D13.MOAB.DP1.00041.001.004.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [117] "NEON.D13.MOAB.DP1.00041.001.002.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [118] "NEON.D13.MOAB.DP1.00041.001.001.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [119] "NEON.D13.MOAB.DP1.00041.001.001.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [120] "NEON.D13.MOAB.DP1.00041.001.004.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [121] "NEON.D13.MOAB.DP1.00041.001.004.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [122] "NEON.D13.MOAB.DP1.00041.001.002.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [123] "NEON.D13.MOAB.DP1.00041.001.002.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [124] "NEON.D13.MOAB.DP1.00041.001.002.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [125] "NEON.D13.MOAB.DP1.00041.001.005.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [126] "NEON.D13.MOAB.DP1.00041.001.003.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [127] "NEON.D13.MOAB.DP1.00041.001.001.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [128] "NEON.D13.MOAB.DP1.00041.001.20170308-20170401.xml"                                         
    ## [129] "NEON.D13.MOAB.DP1.00041.001.005.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [130] "NEON.D13.MOAB.DP1.00041.001.004.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [131] "NEON.D13.MOAB.DP1.00041.001.005.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [132] "NEON.D13.MOAB.DP1.00041.001.004.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [133] "NEON.D13.MOAB.DP1.00041.001.003.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [134] "NEON.D13.MOAB.DP1.00041.001.004.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [135] "NEON.D13.MOAB.DP1.00041.001.001.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [136] "NEON.D13.MOAB.DP1.00041.001.002.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [137] "NEON.D13.MOAB.DP1.00041.001.002.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [138] "NEON.D13.MOAB.DP1.00041.001.003.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [139] "NEON.D13.MOAB.DP1.00041.001.002.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [140] "NEON.D13.MOAB.DP1.00041.001.005.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [141] "NEON.D13.MOAB.DP1.00041.001.005.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [142] "NEON.D13.MOAB.DP1.00041.001.005.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [143] "NEON.D13.MOAB.DP1.00041.001.001.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [144] "NEON.D13.MOAB.DP1.00041.001.001.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [145] "NEON.D13.MOAB.DP1.00041.001.001.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [146] "NEON.D13.MOAB.DP1.00041.001.003.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [147] "NEON.D13.MOAB.DP1.00041.001.003.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [148] "NEON.D13.MOAB.DP1.00041.001.005.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [149] "NEON.D13.MOAB.DP1.00041.001.004.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [150] "NEON.D13.MOAB.DP1.00041.001.002.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [151] "NEON.D13.MOAB.DP1.00041.001.004.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [152] "NEON.D13.MOAB.DP1.00041.001.002.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [153] "NEON.D13.MOAB.DP1.00041.001.004.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [154] "NEON.D13.MOAB.DP1.00041.001.003.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [155] "NEON.D13.MOAB.DP1.00041.001.001.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [156] "NEON.D13.MOAB.DP1.00041.001.001.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [157] "NEON.D13.MOAB.DP1.00041.001.002.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [158] "NEON.D13.MOAB.DP1.00041.001.004.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [159] "NEON.D13.MOAB.DP1.00041.001.005.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [160] "NEON.D13.MOAB.DP1.00041.001.004.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [161] "NEON.D13.MOAB.DP1.00041.001.004.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [162] "NEON.D13.MOAB.DP1.00041.001.004.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [163] "NEON.D13.MOAB.DP1.00041.001.005.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [164] "NEON.D13.MOAB.DP1.00041.001.003.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [165] "NEON.D13.MOAB.DP1.00041.001.005.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [166] "NEON.D13.MOAB.DP1.00041.001.002.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [167] "NEON.D13.MOAB.DP1.00041.001.002.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [168] "NEON.D13.MOAB.DP1.00041.001.005.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [169] "NEON.D13.MOAB.DP1.00041.001.002.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [170] "NEON.D13.MOAB.DP1.00041.001.005.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [171] "NEON.D13.MOAB.DP1.00041.001.002.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [172] "NEON.D13.MOAB.DP1.00041.001.003.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [173] "NEON.D13.MOAB.DP1.00041.001.variables.20170804T063725Z.csv"                                
    ## [174] "NEON.D13.MOAB.DP1.00041.001.001.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [175] "NEON.D13.MOAB.DP1.00041.001.005.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [176] "NEON.D13.MOAB.DP1.00041.001.003.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [177] "NEON.D13.MOAB.DP1.00041.001.005.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [178] "NEON.D13.MOAB.DP1.00041.001.001.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [179] "NEON.D13.MOAB.DP1.00041.001.001.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [180] "NEON.D13.MOAB.DP1.00041.001.001.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [181] "NEON.D13.MOAB.DP1.00041.001.004.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [182] "NEON.D13.MOAB.DP1.00041.001.001.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [183] "NEON.D13.MOAB.DP1.00041.001.003.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [184] "NEON.D13.MOAB.DP1.00041.001.005.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [185] "NEON.D13.MOAB.DP1.00041.001.003.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [186] "NEON.D13.MOAB.DP1.00041.001.003.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [187] "NEON.D13.MOAB.DP1.00041.001.003.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [188] "NEON.DP1.00041.001_readme.txt"

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

Note: NEON instrumentation data products are currently (Fall/Winter 2017) being 
reprocessed on a rolling basis, and as each product is re-deployed, the files will 
begin to appear in the format described here. Products that haven't yet 
been reprocessed will return file names like the above, but will be missing the 
year, month, package, and date of creation specifications.

Let's get data (and the URL) for only the plot and depth described above by selecting 
`002.504.030` and the word `basic` in the file name.

Go get it:


    soil.temp <- read.delim(tmp.files$data$files$url
                            [intersect(grep("002.504.030", tmp.files$data$files$name),
                                       grep("basic", tmp.files$data$files$name))], sep=",")

Now we have the data and can use it to conduct our analyses. To show that we do 
in fact have the data let's plot the mean soil temperature by date. 



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
    # Note how we've change this from two commands into one here
    avail.aop <- fromJSON(content(req.aop, as="text"), simplifyDataFrame=T, flatten=T)
    
    # get data availability list for the product
    cam.urls <- unlist(avail.aop$data$siteCodes$availableDataUrls)
    
    # get data availability from location/date of interest
    cam <- GET(cam.urls[grep("SJER", cam.urls)])

    ## Error: length(url) == 1 is not TRUE

    cam.files <- fromJSON(content(cam, as="text"))

    ## Error in inherits(x, "response"): object 'cam' not found

    # this list of files is very long, so we'll just look at the first few
    head(cam.files$data$files$name)

    ## Error in head(cam.files$data$files$name): object 'cam.files' not found

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


    download(cam.files$data$files$url[grep("20170328192931", cam.files$data$files$name)],
             paste(getwd(), "/SJER_image.tif", sep=""))


The image, below, of the San Joaquin Experimental Range should now be in your 
working directory.

<figure>
	<a href="{{ site.baseurl }}/images/site-images/SJER_tile_20170328192931.png">
	<img src="{{ site.baseurl }}/images/site-images/SJER_tile_20170328192931.png"></a>
	<figcaption> An example of camera data (DP1.30010.001) from the San Joaquin 
	Experimental Range. Source: National Ecological Observatory Network (NEON) 

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

    ## [1] WOOD_013.birdGrid.brd WOOD_013.birdGrid.brd WOOD_013.birdGrid.brd
    ## [4] WOOD_013.birdGrid.brd WOOD_013.birdGrid.brd WOOD_013.birdGrid.brd
    ## 7 Levels: WOOD_006.birdGrid.brd ... WOOD_020.birdGrid.brd

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
    ## $data$domainCode
    ## [1] "D09"
    ## 
    ## $data$siteCode
    ## [1] "WOOD"
    ## 
    ## $data$locationParent
    ## [1] "WOOD"
    ## 
    ## $data$locationParentUrl
    ## [1] "http://data.neonscience.org:80/api/v0/locations/WOOD"
    ## 
    ## $data$locationChildren
    ## [1] "WOOD_013.birdGrid.brd.B2" "WOOD_013.birdGrid.brd.A2"
    ## [3] "WOOD_013.birdGrid.brd.A1" "WOOD_013.birdGrid.brd.B1"
    ## [5] "WOOD_013.birdGrid.brd.B3" "WOOD_013.birdGrid.brd.A3"
    ## [7] "WOOD_013.birdGrid.brd.C1" "WOOD_013.birdGrid.brd.C2"
    ## [9] "WOOD_013.birdGrid.brd.C3"
    ## 
    ## $data$locationChildrenUrls
    ## [1] "http://data.neonscience.org:80/api/v0/locations/WOOD_013.birdGrid.brd.B2"
    ## [2] "http://data.neonscience.org:80/api/v0/locations/WOOD_013.birdGrid.brd.A2"
    ## [3] "http://data.neonscience.org:80/api/v0/locations/WOOD_013.birdGrid.brd.A1"
    ## [4] "http://data.neonscience.org:80/api/v0/locations/WOOD_013.birdGrid.brd.B1"
    ## [5] "http://data.neonscience.org:80/api/v0/locations/WOOD_013.birdGrid.brd.B3"
    ## [6] "http://data.neonscience.org:80/api/v0/locations/WOOD_013.birdGrid.brd.A3"
    ## [7] "http://data.neonscience.org:80/api/v0/locations/WOOD_013.birdGrid.brd.C1"
    ## [8] "http://data.neonscience.org:80/api/v0/locations/WOOD_013.birdGrid.brd.C2"
    ## [9] "http://data.neonscience.org:80/api/v0/locations/WOOD_013.birdGrid.brd.C3"
    ## 
    ## $data$locationProperties
    ##                             locationPropertyName locationPropertyValue
    ## 1                Value for Subtype Specification            ninePoints
    ## 2                            Value for Plot type           distributed
    ## 3                              Value for Plot ID              WOOD_013
    ## 4                      Value for Soil type order             Mollisols
    ## 5             Value for Reference Point Position                    B2
    ## 6  Value for National Land Cover Database (2001)   grasslandHerbaceous
    ## 7                         Value for Plot subtype              birdGrid
    ## 8                      Value for Plot dimensions           500m x 500m
    ## 9                            Value for Plot size                250000
    ## 10                             Value for Country          unitedStates
    ## 11    Value for Horizontal dilution of precision                     1
    ## 12               Value for Elevation uncertainty                  0.48
    ## 13                   Value for Minimum elevation                569.79
    ## 14              Value for Coordinate uncertainty                  0.28
    ## 15    Value for Positional dilution of precision                   2.4
    ## 16                      Value for State province                    ND
    ## 17                  Value for Filtered positions                   121
    ## 18                            Value for UTM Zone                   14N
    ## 19                   Value for Coordinate source            GeoXH 6000
    ## 20                      Value for Slope gradient                  2.83
    ## 21                      Value for Geodetic datum                 WGS84
    ## 22                              Value for County              Stutsman
    ## 23                        Value for Slope aspect                238.91
    ## 24                   Value for Maximum elevation                579.31

Note spatial information under `$data$[nameOfCorrdinate]` and under 
`$data$locationProperties`. Also note `$data$locationChildren`: these are the 
finer scale locations that can be used to calculate precise spatial data for 
bird observations.

For convenience, we'll use the `geoNEON` package to make the calculations. 
First we'll use `def.extr.geo.os()` to get the additional spatial information 
available through the API, and look at the spatial resolution available in the 
initial download:


    # load the geoNEON package
    library(geoNEON)
    
    # extract the spatial data
    brd.point.loc <- def.extr.geo.os(brd.point)

    ##   |                                                                         |                                                                 |   0%  |                                                                         |=========                                                        |  14%  |                                                                         |===================                                              |  29%  |                                                                         |============================                                     |  43%  |                                                                         |=====================================                            |  57%  |                                                                         |==============================================                   |  71%  |                                                                         |========================================================         |  86%

    # plot bird point locations 
    # note that decimal degrees is also an option in the data
    symbols(brd.point.loc$api.easting, brd.point.loc$api.northing, 
            circles=brd.point.loc$coordinateUncertainty, 
            xlab="Easting", ylab="Northing", tck=0.01, inches=F)

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-API/NEON-API-How-To/brd-extr-NL-1.png)

And use `def.calc.geo.os()` to calculate the point locations of observations.


    brd.point.pt <- def.calc.geo.os(brd.point, "brd_perpoint")

    ##   |                                                                         |                                                                 |   0%  |                                                                         |=                                                                |   2%  |                                                                         |==                                                               |   3%  |                                                                         |===                                                              |   5%  |                                                                         |====                                                             |   6%  |                                                                         |=====                                                            |   8%  |                                                                         |======                                                           |  10%  |                                                                         |=======                                                          |  11%  |                                                                         |========                                                         |  13%  |                                                                         |=========                                                        |  14%  |                                                                         |==========                                                       |  16%  |                                                                         |===========                                                      |  17%  |                                                                         |============                                                     |  19%  |                                                                         |=============                                                    |  21%  |                                                                         |==============                                                   |  22%  |                                                                         |===============                                                  |  24%  |                                                                         |=================                                                |  25%  |                                                                         |==================                                               |  27%  |                                                                         |===================                                              |  29%  |                                                                         |====================                                             |  30%  |                                                                         |=====================                                            |  32%  |                                                                         |======================                                           |  33%  |                                                                         |=======================                                          |  35%  |                                                                         |========================                                         |  37%  |                                                                         |=========================                                        |  38%  |                                                                         |==========================                                       |  40%  |                                                                         |===========================                                      |  41%  |                                                                         |============================                                     |  43%  |                                                                         |=============================                                    |  44%  |                                                                         |==============================                                   |  46%  |                                                                         |===============================                                  |  48%  |                                                                         |================================                                 |  49%  |                                                                         |=================================                                |  51%  |                                                                         |==================================                               |  52%  |                                                                         |===================================                              |  54%  |                                                                         |====================================                             |  56%  |                                                                         |=====================================                            |  57%  |                                                                         |======================================                           |  59%  |                                                                         |=======================================                          |  60%  |                                                                         |========================================                         |  62%  |                                                                         |=========================================                        |  63%  |                                                                         |==========================================                       |  65%  |                                                                         |===========================================                      |  67%  |                                                                         |============================================                     |  68%  |                                                                         |=============================================                    |  70%  |                                                                         |==============================================                   |  71%  |                                                                         |===============================================                  |  73%  |                                                                         |================================================                 |  75%  |                                                                         |==================================================               |  76%  |                                                                         |===================================================              |  78%  |                                                                         |====================================================             |  79%  |                                                                         |=====================================================            |  81%  |                                                                         |======================================================           |  83%  |                                                                         |=======================================================          |  84%  |                                                                         |========================================================         |  86%  |                                                                         |=========================================================        |  87%  |                                                                         |==========================================================       |  89%  |                                                                         |===========================================================      |  90%  |                                                                         |============================================================     |  92%  |                                                                         |=============================================================    |  94%  |                                                                         |==============================================================   |  95%  |                                                                         |===============================================================  |  97%  |                                                                         |================================================================ |  98%

    # plot bird point locations 
    # note that decimal degrees is also an option in the data
    symbols(brd.point.pt$api.easting, brd.point.pt$api.northing, 
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
* `verbose`: Do you want the short (`false`) or verbose (`true`) response
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

    ##   taxonTypeCode taxonID acceptedTaxonID dwc:scientificName
    ## 1          BIRD    ARLO            ARLO      Gavia arctica
    ## 2          BIRD    COLO            COLO        Gavia immer
    ## 3          BIRD    PALO            PALO     Gavia pacifica
    ## 4          BIRD    RTLO            RTLO     Gavia stellata
    ## 5          BIRD    YBLO            YBLO      Gavia adamsii
    ##   dwc:scientificNameAuthorship dwc:taxonRank dwc:vernacularName
    ## 1                   (Linnaeus)       species        Arctic Loon
    ## 2                   (Brunnich)       species        Common Loon
    ## 3                   (Lawrence)       species       Pacific Loon
    ## 4                (Pontoppidan)       species  Red-throated Loon
    ## 5                 (G. R. Gray)       species Yellow-billed Loon
    ##      dwc:nameAccordingToID dwc:kingdom dwc:phylum dwc:class   dwc:order
    ## 1 doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes
    ## 2 doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes
    ## 3 doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes
    ## 4 doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes
    ## 5 doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes
    ##   dwc:family dwc:genus gbif:subspecies gbif:variety
    ## 1   Gaviidae     Gavia              NA           NA
    ## 2   Gaviidae     Gavia              NA           NA
    ## 3   Gaviidae     Gavia              NA           NA
    ## 4   Gaviidae     Gavia              NA           NA
    ## 5   Gaviidae     Gavia              NA           NA

To get the entire list for a particular taxonomic type, use the 
`taxonTypeCode` query. Be cautious with this query, the PLANT taxonomic 
list has several hundred thousand entries.

For an example, let's look up the small mammal taxonomic list, which 
is one of the shorter ones, and then display only the first 20 taxa:


    mam.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?taxonTypeCode=SMALL_MAMMAL&offset=0&limit=500")
    mam.list <- fromJSON(content(mam.req, as="text"))
    mam.list$data[1:20,]

    ##    taxonTypeCode taxonID acceptedTaxonID               dwc:scientificName
    ## 1   SMALL_MAMMAL    AMHA            AMHA        Ammospermophilus harrisii
    ## 2   SMALL_MAMMAL    AMIN            AMIN       Ammospermophilus interpres
    ## 3   SMALL_MAMMAL    AMLE            AMLE        Ammospermophilus leucurus
    ## 4   SMALL_MAMMAL    AMLT            AMLT Ammospermophilus leucurus tersus
    ## 5   SMALL_MAMMAL    AMNE            AMNE         Ammospermophilus nelsoni
    ## 6   SMALL_MAMMAL    AMSP            AMSP             Ammospermophilus sp.
    ## 7   SMALL_MAMMAL    APRN            APRN            Aplodontia rufa nigra
    ## 8   SMALL_MAMMAL    APRU            APRU                  Aplodontia rufa
    ## 9   SMALL_MAMMAL    ARAL            ARAL                Arborimus albipes
    ## 10  SMALL_MAMMAL    ARLO            ARLO            Arborimus longicaudus
    ## 11  SMALL_MAMMAL    ARPO            ARPO                   Arborimus pomo
    ## 12  SMALL_MAMMAL    ARSP            ARSP                    Arborimus sp.
    ## 13  SMALL_MAMMAL    BATA            BATA                  Baiomys taylori
    ## 14  SMALL_MAMMAL    BLBR            BLBR               Blarina brevicauda
    ## 15  SMALL_MAMMAL    BLCA            BLCA             Blarina carolinensis
    ## 16  SMALL_MAMMAL    BLHY            BLHY                Blarina hylophaga
    ## 17  SMALL_MAMMAL    BLSP            BLSP                      Blarina sp.
    ## 18  SMALL_MAMMAL    BRID            BRID           Brachylagus idahoensis
    ## 19  SMALL_MAMMAL    CHBA            CHBA              Chaetodipus baileyi
    ## 20  SMALL_MAMMAL    CHCA            CHCA         Chaetodipus californicus
    ##    dwc:scientificNameAuthorship dwc:taxonRank
    ## 1           Audubon and Bachman       species
    ## 2                       Merriam       species
    ## 3                       Merriam       species
    ## 4                       Goldman    subspecies
    ## 5                       Merriam       species
    ## 6                          <NA>         genus
    ## 7                        Taylor    subspecies
    ## 8                    Rafinesque       species
    ## 9                       Merriam       species
    ## 10                         True       species
    ## 11           Johnson and George       species
    ## 12                         <NA>         genus
    ## 13                       Thomas       species
    ## 14                          Say       species
    ## 15                      Bachman       species
    ## 16                       Elliot       species
    ## 17                         <NA>         genus
    ## 18                      Merriam       species
    ## 19                      Merriam       species
    ## 20                      Merriam       species
    ##               dwc:vernacularName dwc:nameAccordingToID dwc:kingdom
    ## 1      Harriss Antelope Squirrel  isbn: 978 0801882210    Animalia
    ## 2        Texas Antelope Squirrel  isbn: 978 0801882210    Animalia
    ## 3  Whitetailed Antelope Squirrel  isbn: 978 0801882210    Animalia
    ## 4                           <NA>  isbn: 978 0801882210    Animalia
    ## 5      Nelsons Antelope Squirrel  isbn: 978 0801882210    Animalia
    ## 6                           <NA>  isbn: 978 0801882210    Animalia
    ## 7                           <NA>  isbn: 978 0801882210    Animalia
    ## 8                       Sewellel  isbn: 978 0801882210    Animalia
    ## 9               Whitefooted Vole  isbn: 978 0801882210    Animalia
    ## 10                 Red Tree Vole  isbn: 978 0801882210    Animalia
    ## 11              Sonoma Tree Vole  isbn: 978 0801882210    Animalia
    ## 12                          <NA>  isbn: 978 0801882210    Animalia
    ## 13          Northern Pygmy Mouse  isbn: 978 0801882210    Animalia
    ## 14    Northern Shorttailed Shrew  isbn: 978 0801882210    Animalia
    ## 15    Southern Shorttailed Shrew  isbn: 978 0801882210    Animalia
    ## 16     Elliots Shorttailed Shrew  isbn: 978 0801882210    Animalia
    ## 17                          <NA>  isbn: 978 0801882210    Animalia
    ## 18                  Pygmy Rabbit  isbn: 978 0801882210    Animalia
    ## 19          Baileys Pocket Mouse  isbn: 978 0801882210    Animalia
    ## 20       California Pocket Mouse  isbn: 978 0801882210    Animalia
    ##    dwc:phylum dwc:class    dwc:order    dwc:family        dwc:genus
    ## 1    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
    ## 2    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
    ## 3    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
    ## 4    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
    ## 5    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
    ## 6    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
    ## 7    Chordata  Mammalia     Rodentia Aplodontiidae       Aplodontia
    ## 8    Chordata  Mammalia     Rodentia Aplodontiidae       Aplodontia
    ## 9    Chordata  Mammalia     Rodentia    Cricetidae        Arborimus
    ## 10   Chordata  Mammalia     Rodentia    Cricetidae        Arborimus
    ## 11   Chordata  Mammalia     Rodentia    Cricetidae        Arborimus
    ## 12   Chordata  Mammalia     Rodentia    Cricetidae        Arborimus
    ## 13   Chordata  Mammalia     Rodentia    Cricetidae          Baiomys
    ## 14   Chordata  Mammalia Soricomorpha     Soricidae          Blarina
    ## 15   Chordata  Mammalia Soricomorpha     Soricidae          Blarina
    ## 16   Chordata  Mammalia Soricomorpha     Soricidae          Blarina
    ## 17   Chordata  Mammalia Soricomorpha     Soricidae          Blarina
    ## 18   Chordata  Mammalia   Lagomorpha     Leporidae      Brachylagus
    ## 19   Chordata  Mammalia     Rodentia  Heteromyidae      Chaetodipus
    ## 20   Chordata  Mammalia     Rodentia  Heteromyidae      Chaetodipus
    ##    gbif:subspecies gbif:variety
    ## 1               NA           NA
    ## 2               NA           NA
    ## 3               NA           NA
    ## 4               NA           NA
    ## 5               NA           NA
    ## 6               NA           NA
    ## 7               NA           NA
    ## 8               NA           NA
    ## 9               NA           NA
    ## 10              NA           NA
    ## 11              NA           NA
    ## 12              NA           NA
    ## 13              NA           NA
    ## 14              NA           NA
    ## 15              NA           NA
    ## 16              NA           NA
    ## 17              NA           NA
    ## 18              NA           NA
    ## 19              NA           NA
    ## 20              NA           NA

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

    ##   taxonTypeCode taxonID acceptedTaxonID    dwc:scientificName
    ## 1         PLANT   ABMI2           ABMI2 Abronia minor Standl.
    ##   dwc:scientificNameAuthorship dwc:taxonRank  dwc:vernacularName
    ## 1                      Standl.       species little sand verbena
    ##                         dwc:nameAccordingToID dwc:kingdom    dwc:phylum
    ## 1 http://plants.usda.gov (accessed 8/25/2014)     Plantae Magnoliophyta
    ##       dwc:class      dwc:order    dwc:family dwc:genus gbif:subspecies
    ## 1 Magnoliopsida Caryophyllales Nyctaginaceae   Abronia              NA
    ##   gbif:variety
    ## 1           NA

## Stacking NEON data 

At the top of this tutorial, we installed the `neonUtilities` package. 
This is a custom R package that stacks the monthly files provided by 
the NEON data portal into a single continuous file for each type of 
data table in the download. It currently handles files downloaded from 
the data portal, but not files pulled from the API. That functionality 
will be added soon!

For a guide to using `neonUtilities` on data downloaded from the portal, 
look <a href="/neonDataStackR" target="_blank">here</a>.
