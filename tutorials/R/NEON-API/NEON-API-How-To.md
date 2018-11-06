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


    # Load the necessary libraries
    library(httr)
    library(jsonlite)
    library(dplyr, quietly=T)
    library(downloader)
    
    # Request data using the GET function & the API call
    req <- GET("http://data.neonscience.org/api/v0/products/DP1.10003.001")
    req

    ## Response [http://data.neonscience.org/api/v0/products/DP1.10003.001]
    ##   Date: 2018-08-28 19:13
    ##   Status: 200
    ##   Content-Type: application/json;charset=UTF-8
    ##   Size: 13.7 kB

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
    ## [1] 2565
    ## 
    ## $data$specs[[1]]$specNumber
    ## [1] "NEON_bird_userGuide_vA"
    ## 
    ## 
    ## $data$specs[[2]]
    ## $data$specs[[2]]$specId
    ## [1] 3729
    ## 
    ## $data$specs[[2]]$specNumber
    ## [1] "NEON.DOC.014041vJ"
    ## 
    ## 
    ## $data$specs[[3]]
    ## $data$specs[[3]]$specId
    ## [1] 3656
    ## 
    ## $data$specs[[3]]$specNumber
    ## [1] "NEON.DOC.000916vC"
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
    ## [1] "vertebrates"
    ## 
    ## $data$keywords[[10]]
    ## [1] "invasive"
    ## 
    ## $data$keywords[[11]]
    ## [1] "introduced"
    ## 
    ## $data$keywords[[12]]
    ## [1] "native"
    ## 
    ## $data$keywords[[13]]
    ## [1] "landbirds"
    ## 
    ## $data$keywords[[14]]
    ## [1] "animals"
    ## 
    ## $data$keywords[[15]]
    ## [1] "Animalia"
    ## 
    ## $data$keywords[[16]]
    ## [1] "Aves"
    ## 
    ## $data$keywords[[17]]
    ## [1] "Chordata"
    ## 
    ## $data$keywords[[18]]
    ## [1] "point counts"
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
    ## [1] "WOOD"
    ## 
    ## $data$siteCodes[[3]]$availableMonths
    ## $data$siteCodes[[3]]$availableMonths[[1]]
    ## [1] "2015-07"
    ## 
    ## $data$siteCodes[[3]]$availableMonths[[2]]
    ## [1] "2017-07"
    ## 
    ## 
    ## $data$siteCodes[[3]]$availableDataUrls
    ## $data$siteCodes[[3]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2015-07"
    ## 
    ## $data$siteCodes[[3]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2017-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[4]]
    ## $data$siteCodes[[4]]$siteCode
    ## [1] "CPER"
    ## 
    ## $data$siteCodes[[4]]$availableMonths
    ## $data$siteCodes[[4]]$availableMonths[[1]]
    ## [1] "2013-06"
    ## 
    ## $data$siteCodes[[4]]$availableMonths[[2]]
    ## [1] "2015-05"
    ## 
    ## $data$siteCodes[[4]]$availableMonths[[3]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[4]]$availableMonths[[4]]
    ## [1] "2017-05"
    ## 
    ## $data$siteCodes[[4]]$availableMonths[[5]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[4]]$availableDataUrls
    ## $data$siteCodes[[4]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2013-06"
    ## 
    ## $data$siteCodes[[4]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2015-05"
    ## 
    ## $data$siteCodes[[4]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2016-05"
    ## 
    ## $data$siteCodes[[4]]$availableDataUrls[[4]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-05"
    ## 
    ## $data$siteCodes[[4]]$availableDataUrls[[5]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-06"
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
    ## [1] "NOGP"
    ## 
    ## $data$siteCodes[[7]]$availableMonths
    ## $data$siteCodes[[7]]$availableMonths[[1]]
    ## [1] "2017-07"
    ## 
    ## 
    ## $data$siteCodes[[7]]$availableDataUrls
    ## $data$siteCodes[[7]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NOGP/2017-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[8]]
    ## $data$siteCodes[[8]]$siteCode
    ## [1] "JERC"
    ## 
    ## $data$siteCodes[[8]]$availableMonths
    ## $data$siteCodes[[8]]$availableMonths[[1]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[8]]$availableMonths[[2]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[8]]$availableDataUrls
    ## $data$siteCodes[[8]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2016-06"
    ## 
    ## $data$siteCodes[[8]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2017-05"
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
    ## [1] "DEJU"
    ## 
    ## $data$siteCodes[[11]]$availableMonths
    ## $data$siteCodes[[11]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[11]]$availableDataUrls
    ## $data$siteCodes[[11]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DEJU/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[12]]
    ## $data$siteCodes[[12]]$siteCode
    ## [1] "DCFS"
    ## 
    ## $data$siteCodes[[12]]$availableMonths
    ## $data$siteCodes[[12]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## $data$siteCodes[[12]]$availableMonths[[2]]
    ## [1] "2017-07"
    ## 
    ## 
    ## $data$siteCodes[[12]]$availableDataUrls
    ## $data$siteCodes[[12]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-06"
    ## 
    ## $data$siteCodes[[12]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[13]]
    ## $data$siteCodes[[13]]$siteCode
    ## [1] "KONZ"
    ## 
    ## $data$siteCodes[[13]]$availableMonths
    ## $data$siteCodes[[13]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[13]]$availableDataUrls
    ## $data$siteCodes[[13]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/KONZ/2017-06"
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
    ## [1] "BONA"
    ## 
    ## $data$siteCodes[[17]]$availableMonths
    ## $data$siteCodes[[17]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[17]]$availableDataUrls
    ## $data$siteCodes[[17]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BONA/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[18]]
    ## $data$siteCodes[[18]]$siteCode
    ## [1] "BART"
    ## 
    ## $data$siteCodes[[18]]$availableMonths
    ## $data$siteCodes[[18]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[18]]$availableMonths[[2]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[18]]$availableMonths[[3]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[18]]$availableDataUrls
    ## $data$siteCodes[[18]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2015-06"
    ## 
    ## $data$siteCodes[[18]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2016-06"
    ## 
    ## $data$siteCodes[[18]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2017-06"
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
    ## [1] "STEI"
    ## 
    ## $data$siteCodes[[21]]$availableMonths
    ## $data$siteCodes[[21]]$availableMonths[[1]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[21]]$availableMonths[[2]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[21]]$availableMonths[[3]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[21]]$availableDataUrls
    ## $data$siteCodes[[21]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-05"
    ## 
    ## $data$siteCodes[[21]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-06"
    ## 
    ## $data$siteCodes[[21]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[22]]
    ## $data$siteCodes[[22]]$siteCode
    ## [1] "JORN"
    ## 
    ## $data$siteCodes[[22]]$availableMonths
    ## $data$siteCodes[[22]]$availableMonths[[1]]
    ## [1] "2017-04"
    ## 
    ## $data$siteCodes[[22]]$availableMonths[[2]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[22]]$availableDataUrls
    ## $data$siteCodes[[22]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-04"
    ## 
    ## $data$siteCodes[[22]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-05"
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
    ## [1] "ONAQ"
    ## 
    ## $data$siteCodes[[31]]$availableMonths
    ## $data$siteCodes[[31]]$availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[31]]$availableDataUrls
    ## $data$siteCodes[[31]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ONAQ/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[32]]
    ## $data$siteCodes[[32]]$siteCode
    ## [1] "SRER"
    ## 
    ## $data$siteCodes[[32]]$availableMonths
    ## $data$siteCodes[[32]]$availableMonths[[1]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[32]]$availableDataUrls
    ## $data$siteCodes[[32]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SRER/2017-05"
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
    ## [1] "PUUM"
    ## 
    ## $data$siteCodes[[37]]$availableMonths
    ## $data$siteCodes[[37]]$availableMonths[[1]]
    ## [1] "2018-04"
    ## 
    ## 
    ## $data$siteCodes[[37]]$availableDataUrls
    ## $data$siteCodes[[37]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/PUUM/2018-04"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[38]]
    ## $data$siteCodes[[38]]$siteCode
    ## [1] "TREE"
    ## 
    ## $data$siteCodes[[38]]$availableMonths
    ## $data$siteCodes[[38]]$availableMonths[[1]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[38]]$availableMonths[[2]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[38]]$availableDataUrls
    ## $data$siteCodes[[38]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2016-06"
    ## 
    ## $data$siteCodes[[38]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[39]]
    ## $data$siteCodes[[39]]$siteCode
    ## [1] "DSNY"
    ## 
    ## $data$siteCodes[[39]]$availableMonths
    ## $data$siteCodes[[39]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[39]]$availableMonths[[2]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[39]]$availableMonths[[3]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[39]]$availableDataUrls
    ## $data$siteCodes[[39]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2015-06"
    ## 
    ## $data$siteCodes[[39]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2016-05"
    ## 
    ## $data$siteCodes[[39]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[40]]
    ## $data$siteCodes[[40]]$siteCode
    ## [1] "GUAN"
    ## 
    ## $data$siteCodes[[40]]$availableMonths
    ## $data$siteCodes[[40]]$availableMonths[[1]]
    ## [1] "2015-05"
    ## 
    ## $data$siteCodes[[40]]$availableMonths[[2]]
    ## [1] "2017-05"
    ## 
    ## 
    ## $data$siteCodes[[40]]$availableDataUrls
    ## $data$siteCodes[[40]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2015-05"
    ## 
    ## $data$siteCodes[[40]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2017-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[41]]
    ## $data$siteCodes[[41]]$siteCode
    ## [1] "TEAK"
    ## 
    ## $data$siteCodes[[41]]$availableMonths
    ## $data$siteCodes[[41]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[41]]$availableDataUrls
    ## $data$siteCodes[[41]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TEAK/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[42]]
    ## $data$siteCodes[[42]]$siteCode
    ## [1] "UNDE"
    ## 
    ## $data$siteCodes[[42]]$availableMonths
    ## $data$siteCodes[[42]]$availableMonths[[1]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[42]]$availableMonths[[2]]
    ## [1] "2016-07"
    ## 
    ## $data$siteCodes[[42]]$availableMonths[[3]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[42]]$availableDataUrls
    ## $data$siteCodes[[42]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-06"
    ## 
    ## $data$siteCodes[[42]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-07"
    ## 
    ## $data$siteCodes[[42]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2017-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[43]]
    ## $data$siteCodes[[43]]$siteCode
    ## [1] "TOOL"
    ## 
    ## $data$siteCodes[[43]]$availableMonths
    ## $data$siteCodes[[43]]$availableMonths[[1]]
    ## [1] "2017-06"
    ## 
    ## 
    ## $data$siteCodes[[43]]$availableDataUrls
    ## $data$siteCodes[[43]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TOOL/2017-06"

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
    ## 1   2565 NEON_bird_userGuide_vA
    ## 2   3729      NEON.DOC.014041vJ
    ## 3   3656      NEON.DOC.000916vC
    ## 
    ## $data$keywords
    ##  [1] "birds"                 "diversity"            
    ##  [3] "taxonomy"              "community composition"
    ##  [5] "distance sampling"     "avian"                
    ##  [7] "species composition"   "population"           
    ##  [9] "vertebrates"           "invasive"             
    ## [11] "introduced"            "native"               
    ## [13] "landbirds"             "animals"              
    ## [15] "Animalia"              "Aves"                 
    ## [17] "Chordata"              "point counts"         
    ## 
    ## $data$siteCodes
    ##    siteCode                             availableMonths
    ## 1      ORNL                   2016-05, 2016-06, 2017-05
    ## 2      UKFS                                     2017-06
    ## 3      WOOD                            2015-07, 2017-07
    ## 4      CPER 2013-06, 2015-05, 2016-05, 2017-05, 2017-06
    ## 5      HEAL                                     2017-06
    ## 6      TALL                   2015-06, 2016-07, 2017-06
    ## 7      NOGP                                     2017-07
    ## 8      JERC                            2016-06, 2017-05
    ## 9      LAJA                                     2017-05
    ## 10     OSBS                            2016-05, 2017-05
    ## 11     DEJU                                     2017-06
    ## 12     DCFS                            2017-06, 2017-07
    ## 13     KONZ                                     2017-06
    ## 14     LENO                                     2017-06
    ## 15     RMNP                            2017-06, 2017-07
    ## 16     HARV          2015-05, 2015-06, 2016-06, 2017-06
    ## 17     BONA                                     2017-06
    ## 18     BART                   2015-06, 2016-06, 2017-06
    ## 19     BARR                                     2017-07
    ## 20     SJER                                     2017-04
    ## 21     STEI                   2016-05, 2016-06, 2017-06
    ## 22     JORN                            2017-04, 2017-05
    ## 23     GRSM                   2016-06, 2017-05, 2017-06
    ## 24     OAES                            2017-05, 2017-06
    ## 25     SERC                            2017-05, 2017-06
    ## 26     ABBY                            2017-05, 2017-06
    ## 27     MOAB                            2015-06, 2017-05
    ## 28     BLAN                            2017-05, 2017-06
    ## 29     STER          2013-06, 2015-05, 2016-05, 2017-05
    ## 30     DELA                            2015-06, 2017-06
    ## 31     ONAQ                                     2017-05
    ## 32     SRER                                     2017-05
    ## 33     SOAP                                     2017-05
    ## 34     CLBJ                                     2017-05
    ## 35     SCBI 2015-06, 2016-05, 2016-06, 2017-05, 2017-06
    ## 36     NIWO                            2015-07, 2017-07
    ## 37     PUUM                                     2018-04
    ## 38     TREE                            2016-06, 2017-06
    ## 39     DSNY                   2015-06, 2016-05, 2017-05
    ## 40     GUAN                            2015-05, 2017-05
    ## 41     TEAK                                     2017-06
    ## 42     UNDE                   2016-06, 2016-07, 2017-06
    ## 43     TOOL                                     2017-06
    ##                                                                                                                                                                                                                                                                                                                                                    availableDataUrls
    ## 1                                                                                                                                                http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2017-05
    ## 2                                                                                                                                                                                                                                                                                              http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UKFS/2017-06
    ## 3                                                                                                                                                                                                                       http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2015-07, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2017-07
    ## 4  http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2013-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2015-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-06
    ## 5                                                                                                                                                                                                                                                                                              http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HEAL/2017-06
    ## 6                                                                                                                                                http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2016-07, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2017-06
    ## 7                                                                                                                                                                                                                                                                                              http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NOGP/2017-07
    ## 8                                                                                                                                                                                                                       http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2017-05
    ## 9                                                                                                                                                                                                                                                                                              http://data.neonscience.org:80/api/v0/data/DP1.10003.001/LAJA/2017-05
    ## 10                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2017-05
    ## 11                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DEJU/2017-06
    ## 12                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-07
    ## 13                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/KONZ/2017-06
    ## 14                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/LENO/2017-06
    ## 15                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/RMNP/2017-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/RMNP/2017-07
    ## 16                                                                        http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2017-06
    ## 17                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BONA/2017-06
    ## 18                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2017-06
    ## 19                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BARR/2017-07
    ## 20                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SJER/2017-04
    ## 21                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2017-06
    ## 22                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-04, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-05
    ## 23                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2017-06
    ## 24                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OAES/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OAES/2017-06
    ## 25                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SERC/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SERC/2017-06
    ## 26                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ABBY/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ABBY/2017-06
    ## 27                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/MOAB/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/MOAB/2017-05
    ## 28                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BLAN/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BLAN/2017-06
    ## 29                                                                        http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2013-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2015-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2017-05
    ## 30                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DELA/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DELA/2017-06
    ## 31                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ONAQ/2017-05
    ## 32                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SRER/2017-05
    ## 33                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SOAP/2017-05
    ## 34                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CLBJ/2017-05
    ## 35 http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2017-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2017-06
    ## 36                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NIWO/2015-07, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NIWO/2017-07
    ## 37                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/PUUM/2018-04
    ## 38                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2017-06
    ## 39                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2017-05
    ## 40                                                                                                                                                                                                                      http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2015-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2017-05
    ## 41                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TEAK/2017-06
    ## 42                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-07, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2017-06
    ## 43                                                                                                                                                                                                                                                                                             http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TOOL/2017-06

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
    ##  [5] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2015-07"
    ##  [6] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2017-07"
    ##  [7] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2013-06"
    ##  [8] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2015-05"
    ##  [9] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2016-05"
    ## [10] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-05"
    ## [11] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2017-06"
    ## [12] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HEAL/2017-06"
    ## [13] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2015-06"
    ## [14] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2016-07"
    ## [15] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2017-06"
    ## [16] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NOGP/2017-07"
    ## [17] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2016-06"
    ## [18] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2017-05"
    ## [19] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/LAJA/2017-05"
    ## [20] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2016-05"
    ## [21] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2017-05"
    ## [22] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DEJU/2017-06"
    ## [23] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-06"
    ## [24] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DCFS/2017-07"
    ## [25] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/KONZ/2017-06"
    ## [26] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/LENO/2017-06"
    ## [27] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/RMNP/2017-06"
    ## [28] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/RMNP/2017-07"
    ## [29] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-05"
    ## [30] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-06"
    ## [31] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2016-06"
    ## [32] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2017-06"
    ## [33] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BONA/2017-06"
    ## [34] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2015-06"
    ## [35] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2016-06"
    ## [36] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2017-06"
    ## [37] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BARR/2017-07"
    ## [38] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SJER/2017-04"
    ## [39] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-05"
    ## [40] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-06"
    ## [41] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2017-06"
    ## [42] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-04"
    ## [43] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JORN/2017-05"
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
    ## [63] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ONAQ/2017-05"
    ## [64] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SRER/2017-05"
    ## [65] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SOAP/2017-05"
    ## [66] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CLBJ/2017-05"
    ## [67] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2015-06"
    ## [68] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-05"
    ## [69] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-06"
    ## [70] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2017-05"
    ## [71] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2017-06"
    ## [72] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NIWO/2015-07"
    ## [73] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/NIWO/2017-07"
    ## [74] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/PUUM/2018-04"
    ## [75] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2016-06"
    ## [76] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2017-06"
    ## [77] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2015-06"
    ## [78] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2016-05"
    ## [79] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2017-05"
    ## [80] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2015-05"
    ## [81] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2017-05"
    ## [82] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TEAK/2017-06"
    ## [83] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-06"
    ## [84] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-07"
    ## [85] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2017-06"
    ## [86] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TOOL/2017-06"

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
    ## 1  7c999e9ae4f7d94eaa2c11aadaeecd0b
    ## 2  71e695abae2d1943d13e53c95430c6f5
    ## 3  dd27e83b9a5e4a7453f284ae13d1f32d
    ## 4  4d4f86c1379dece680185e992a471432
    ## 5  0cde0267b9141a0f37a14dc7e5c7084a
    ## 6  5428880d2a72e66319eb6f29576a49af
    ## 7  19adfd2c8bedfe867646644e1985dca0
    ## 8  28bbedc80a738c2cd16afad21319136f
    ## 9  81ddde9f27c7ba6d5a9f6cfb07ae78d3
    ## 10 02506292f09b5a4ebcc055b279621f8e
    ## 11 dd27e83b9a5e4a7453f284ae13d1f32d
    ## 12 51b19ca519653f87c7732791b345f89e
    ## 13 19adfd2c8bedfe867646644e1985dca0
    ## 14 8dca69c9edcf4f3df4ee7fa3a0a624dc
    ## 15 4d4f86c1379dece680185e992a471432
    ## 16 bba1d7554ff524604e64ffcb0b23c0b0
    ##                                                                               name
    ## 1     NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.basic.20180418T200718Z.csv
    ## 2           NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20180418T200718Z.xml
    ## 3                       NEON.D09.WOOD.DP1.10003.001.variables.20180418T200718Z.csv
    ## 4      NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.basic.20180418T200718Z.csv
    ## 5                   NEON.D09.WOOD.DP1.10003.001.2015-07.basic.20180418T200718Z.zip
    ## 6                          NEON.D09.WOOD.DP1.10003.001.readme.20180418T200718Z.txt
    ## 7                      NEON.D09.WOOD.DP0.10003.001.validation.20180418T200718Z.csv
    ## 8                NEON.D09.WOOD.DP1.10003.001.2015-07.expanded.20180418T200718Z.zip
    ## 9  NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.expanded.20180418T200718Z.csv
    ## 10          NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20180418T200718Z.xml
    ## 11                      NEON.D09.WOOD.DP1.10003.001.variables.20180418T200718Z.csv
    ## 12                         NEON.D09.WOOD.DP1.10003.001.readme.20180418T200718Z.txt
    ## 13                     NEON.D09.WOOD.DP0.10003.001.validation.20180418T200718Z.csv
    ## 14        NEON.D09.WOOD.DP1.10003.001.brd_references.expanded.20180418T200718Z.csv
    ## 15  NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.expanded.20180418T200718Z.csv
    ## 16                          NEON.Bird_Conservancy_of_the_Rockies.brd_personnel.csv
    ##      size
    ## 1  355660
    ## 2   70196
    ## 3    7280
    ## 4   23962
    ## 5   67654
    ## 6   12361
    ## 7    9830
    ## 8   72540
    ## 9  376383
    ## 10  78407
    ## 11   7280
    ## 12  12640
    ## 13   9830
    ## 14    650
    ## 15  23962
    ## 16  11918
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        url
    ## 1        https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.basic.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=a34b4a3b8b10f95309f9bfc8950c1c2b31e3c809a9259dc099468bb013747730
    ## 2              https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20180418T200718Z.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=a8bcee3b05e266217210253b0fc477f2a55cab4a0e6704fe62af3ad02cd67f5a
    ## 3                          https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.variables.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=579d68a6fe1138bac656812cbb534b0a17ab18907e148c54001fe3c2c44aa9f5
    ## 4         https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.basic.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=f29e096ea6faa0dbdbf5d5df88b29c28d0e9a0dede018b3fa6b3dae07b6b3145
    ## 5                      https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.2015-07.basic.20180418T200718Z.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=bdef19628cebe58e8bd954561f17fe4825c673f778fe227ac56152904afafa9a
    ## 6                             https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.readme.20180418T200718Z.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=daac1c4bd65cd8da3740db89e57e6d096244b04f28c9752f2a02a505e42298e3
    ## 7                         https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP0.10003.001.validation.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=c9470a629fa71c2cd72e2e91e9c9cbd273dbf382c41cd86ee66e26e11cdb1c39
    ## 8                https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.2015-07.expanded.20180418T200718Z.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=0e69847fd19728010c2e0a9493f9388458232a4ebb572f445ad0dd765ee8767c
    ## 9  https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.expanded.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=dfedcc2d3e3e3935b365b0a1f9bb670de34f5f78b00276bf15a37d7bf4d06eee
    ## 10          https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.EML.20150701-20150705.20180418T200718Z.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=3163bd54d19faec307aa838cfaa533b0d1ff59bb1f9190092f5668c38a4959ec
    ## 11                      https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.variables.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=ae6942721651d533a7a41e66eec01a48d7721badbc2d668cce196afa5150e6de
    ## 12                         https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.readme.20180418T200718Z.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=44bd75b779f207145a2d9ca4f4bdefb415b093374dc8bfb0015ccb47d4702f09
    ## 13                     https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP0.10003.001.validation.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=59f0e761c5213f8b5d5b7ab509954228241df93e8e6388289ebf9549396d745b
    ## 14        https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.brd_references.expanded.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=4504f38ca7b77cea8a57bad516bc063e602ca71f0228b7a68cf343f213cf0d1c
    ## 15  https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.expanded.20180418T200718Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=21c0de5423158e5ccaec80c3974247b45bf9ec54c3b755f664cce9de17f45c82
    ## 16                          https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.Bird_Conservancy_of_the_Rockies.brd_personnel.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180828T191308Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180828%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=c020fab1d8ae4d609d5bddc9d3d6c9d27671692ef2a77761900f9546dbd6f2ec

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
    tmp.files$data$files$name

    ##   [1] "NEON.D13.MOAB.DP1.00041.001.003.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##   [2] "NEON.D13.MOAB.DP1.00041.001.003.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##   [3] "NEON.D13.MOAB.DP1.00041.001.002.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [4] "NEON.D13.MOAB.DP1.00041.001.003.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##   [5] "NEON.D13.MOAB.DP1.00041.001.003.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##   [6] "NEON.D13.MOAB.DP1.00041.001.003.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [7] "NEON.D13.MOAB.DP1.00041.001.002.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [8] "NEON.D13.MOAB.DP1.00041.001.003.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [9] "NEON.D13.MOAB.DP1.00041.001.002.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [10] "NEON.D13.MOAB.DP1.00041.001.003.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [11] "NEON.D13.MOAB.DP1.00041.001.001.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [12] "NEON.D13.MOAB.DP1.00041.001.001.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [13] "NEON.D13.MOAB.DP1.00041.001.003.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [14] "NEON.D13.MOAB.DP1.00041.001.005.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [15] "NEON.D13.MOAB.DP1.00041.001.005.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [16] "NEON.D13.MOAB.DP1.00041.001.004.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [17] "NEON.D13.MOAB.DP1.00041.001.005.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [18] "NEON.D13.MOAB.DP1.00041.001.004.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [19] "NEON.D13.MOAB.DP1.00041.001.004.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [20] "NEON.D13.MOAB.DP1.00041.001.003.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [21] "NEON.D13.MOAB.DP1.00041.001.002.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [22] "NEON.D13.MOAB.DP1.00041.001.003.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [23] "NEON.D13.MOAB.DP1.00041.001.2017-03.basic.20170804T063725Z.zip"                            
    ##  [24] "NEON.DP1.00041.001_readme.txt"                                                             
    ##  [25] "NEON.D13.MOAB.DP1.00041.001.005.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [26] "NEON.D13.MOAB.DP1.00041.001.002.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [27] "NEON.D13.MOAB.DP1.00041.001.005.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [28] "NEON.D13.MOAB.DP1.00041.001.004.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [29] "NEON.D13.MOAB.DP1.00041.001.004.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [30] "NEON.D13.MOAB.DP1.00041.001.001.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [31] "NEON.D13.MOAB.DP1.00041.001.001.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [32] "NEON.D13.MOAB.DP1.00041.001.005.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [33] "NEON.D13.MOAB.DP1.00041.001.004.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [34] "NEON.D13.MOAB.DP1.00041.001.004.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [35] "NEON.D13.MOAB.DP1.00041.001.002.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [36] "NEON.D13.MOAB.DP1.00041.001.003.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [37] "NEON.D13.MOAB.DP1.00041.001.002.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [38] "NEON.D13.MOAB.DP1.00041.001.005.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [39] "NEON.D13.MOAB.DP1.00041.001.004.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [40] "NEON.D13.MOAB.DP1.00041.001.002.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [41] "NEON.D13.MOAB.DP1.00041.001.004.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [42] "NEON.D13.MOAB.DP1.00041.001.004.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [43] "NEON.D13.MOAB.DP1.00041.001.004.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [44] "NEON.D13.MOAB.DP1.00041.001.004.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [45] "NEON.D13.MOAB.DP1.00041.001.005.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [46] "NEON.D13.MOAB.DP1.00041.001.005.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [47] "NEON.D13.MOAB.DP1.00041.001.002.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [48] "NEON.D13.MOAB.DP1.00041.001.002.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [49] "NEON.D13.MOAB.DP1.00041.001.004.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [50] "NEON.D13.MOAB.DP1.00041.001.003.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [51] "NEON.D13.MOAB.DP1.00041.001.005.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [52] "NEON.D13.MOAB.DP1.00041.001.005.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [53] "NEON.D13.MOAB.DP1.00041.001.002.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [54] "NEON.D13.MOAB.DP1.00041.001.005.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [55] "NEON.D13.MOAB.DP1.00041.001.001.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [56] "NEON.D13.MOAB.DP1.00041.001.001.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [57] "NEON.D13.MOAB.DP1.00041.001.001.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [58] "NEON.D13.MOAB.DP1.00041.001.002.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [59] "NEON.D13.MOAB.DP1.00041.001.001.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [60] "NEON.D13.MOAB.DP1.00041.001.001.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [61] "NEON.D13.MOAB.DP1.00041.001.003.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [62] "NEON.D13.MOAB.DP1.00041.001.002.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [63] "NEON.D13.MOAB.DP1.00041.001.001.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [64] "NEON.D13.MOAB.DP1.00041.001.003.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [65] "NEON.D13.MOAB.DP1.00041.001.004.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [66] "NEON.D13.MOAB.DP1.00041.001.005.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [67] "NEON.D13.MOAB.DP1.00041.001.002.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [68] "NEON.D13.MOAB.DP1.00041.001.003.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [69] "NEON.D13.MOAB.DP1.00041.001.005.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [70] "NEON.D13.MOAB.DP1.00041.001.20170308-20170401.xml"                                         
    ##  [71] "NEON.D13.MOAB.DP1.00041.001.001.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [72] "NEON.D13.MOAB.DP1.00041.001.001.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [73] "NEON.D13.MOAB.DP1.00041.001.001.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [74] "NEON.D13.MOAB.DP1.00041.001.002.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [75] "NEON.D13.MOAB.DP1.00041.001.003.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [76] "NEON.D13.MOAB.DP1.00041.001.004.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [77] "NEON.D13.MOAB.DP1.00041.001.002.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [78] "NEON.D13.MOAB.DP1.00041.001.002.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [79] "NEON.D13.MOAB.DP1.00041.001.002.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [80] "NEON.D13.MOAB.DP1.00041.001.003.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [81] "NEON.D13.MOAB.DP1.00041.001.001.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [82] "NEON.D13.MOAB.DP1.00041.001.004.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [83] "NEON.D13.MOAB.DP1.00041.001.variables.20170804T063725Z.csv"                                
    ##  [84] "NEON.D13.MOAB.DP1.00041.001.001.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [85] "NEON.D13.MOAB.DP1.00041.001.001.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [86] "NEON.D13.MOAB.DP1.00041.001.001.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [87] "NEON.D13.MOAB.DP1.00041.001.005.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [88] "NEON.D13.MOAB.DP1.00041.001.004.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [89] "NEON.D13.MOAB.DP1.00041.001.005.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [90] "NEON.D13.MOAB.DP1.00041.001.005.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [91] "NEON.D13.MOAB.DP1.00041.001.001.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [92] "NEON.D13.MOAB.DP1.00041.001.004.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [93] "NEON.D13.MOAB.DP1.00041.001.005.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [94] "NEON.D13.MOAB.DP1.00041.001.003.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [95] "NEON.D13.MOAB.DP1.00041.001.003.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ##  [96] "NEON.D13.MOAB.DP1.00041.001.005.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ##  [97] "NEON.DP1.00041.001_readme.txt"                                                             
    ##  [98] "NEON.D13.MOAB.DP1.00041.001.004.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ##  [99] "NEON.D13.MOAB.DP1.00041.001.003.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [100] "NEON.D13.MOAB.DP1.00041.001.002.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [101] "NEON.D13.MOAB.DP1.00041.001.003.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [102] "NEON.D13.MOAB.DP1.00041.001.001.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [103] "NEON.D13.MOAB.DP1.00041.001.001.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [104] "NEON.D13.MOAB.DP1.00041.001.004.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [105] "NEON.D13.MOAB.DP1.00041.001.variables.20170804T063725Z.csv"                                
    ## [106] "NEON.D13.MOAB.DP1.00041.001.002.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [107] "NEON.D13.MOAB.DP1.00041.001.004.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [108] "NEON.D13.MOAB.DP1.00041.001.005.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [109] "NEON.D13.MOAB.DP1.00041.001.001.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [110] "NEON.D13.MOAB.DP1.00041.001.005.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [111] "NEON.D13.MOAB.DP1.00041.001.002.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [112] "NEON.D13.MOAB.DP1.00041.001.004.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [113] "NEON.D13.MOAB.DP1.00041.001.003.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [114] "NEON.D13.MOAB.DP1.00041.001.003.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [115] "NEON.D13.MOAB.DP1.00041.001.003.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [116] "NEON.D13.MOAB.DP1.00041.001.005.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [117] "NEON.D13.MOAB.DP1.00041.001.005.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [118] "NEON.D13.MOAB.DP1.00041.001.003.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [119] "NEON.D13.MOAB.DP1.00041.001.002.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [120] "NEON.D13.MOAB.DP1.00041.001.002.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [121] "NEON.D13.MOAB.DP1.00041.001.001.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [122] "NEON.D13.MOAB.DP1.00041.001.004.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [123] "NEON.D13.MOAB.DP1.00041.001.001.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [124] "NEON.D13.MOAB.DP1.00041.001.005.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [125] "NEON.D13.MOAB.DP1.00041.001.003.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [126] "NEON.D13.MOAB.DP1.00041.001.005.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [127] "NEON.D13.MOAB.DP1.00041.001.004.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [128] "NEON.D13.MOAB.DP1.00041.001.001.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [129] "NEON.D13.MOAB.DP1.00041.001.005.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [130] "NEON.D13.MOAB.DP1.00041.001.005.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [131] "NEON.D13.MOAB.DP1.00041.001.004.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [132] "NEON.D13.MOAB.DP1.00041.001.004.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [133] "NEON.D13.MOAB.DP1.00041.001.002.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [134] "NEON.D13.MOAB.DP1.00041.001.003.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [135] "NEON.D13.MOAB.DP1.00041.001.004.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [136] "NEON.D13.MOAB.DP1.00041.001.2017-03.expanded.20170804T063725Z.zip"                         
    ## [137] "NEON.D13.MOAB.DP1.00041.001.003.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [138] "NEON.D13.MOAB.DP1.00041.001.001.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [139] "NEON.D13.MOAB.DP1.00041.001.003.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [140] "NEON.D13.MOAB.DP1.00041.001.003.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [141] "NEON.D13.MOAB.DP1.00041.001.001.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [142] "NEON.D13.MOAB.DP1.00041.001.004.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [143] "NEON.D13.MOAB.DP1.00041.001.002.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [144] "NEON.D13.MOAB.DP1.00041.001.003.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [145] "NEON.D13.MOAB.DP1.00041.001.005.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [146] "NEON.D13.MOAB.DP1.00041.001.001.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [147] "NEON.D13.MOAB.DP1.00041.001.003.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [148] "NEON.D13.MOAB.DP1.00041.001.003.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [149] "NEON.D13.MOAB.DP1.00041.001.004.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [150] "NEON.D13.MOAB.DP1.00041.001.002.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [151] "NEON.D13.MOAB.DP1.00041.001.005.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [152] "NEON.D13.MOAB.DP1.00041.001.003.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [153] "NEON.D13.MOAB.DP1.00041.001.002.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [154] "NEON.D13.MOAB.DP1.00041.001.003.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [155] "NEON.D13.MOAB.DP1.00041.001.001.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [156] "NEON.D13.MOAB.DP1.00041.001.002.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [157] "NEON.D13.MOAB.DP1.00041.001.002.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [158] "NEON.D13.MOAB.DP1.00041.001.005.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [159] "NEON.D13.MOAB.DP1.00041.001.001.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [160] "NEON.D13.MOAB.DP1.00041.001.002.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [161] "NEON.D13.MOAB.DP1.00041.001.002.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [162] "NEON.D13.MOAB.DP1.00041.001.004.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [163] "NEON.D13.MOAB.DP1.00041.001.005.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [164] "NEON.D13.MOAB.DP1.00041.001.005.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [165] "NEON.D13.MOAB.DP1.00041.001.004.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [166] "NEON.D13.MOAB.DP1.00041.001.20170308-20170401.xml"                                         
    ## [167] "NEON.D13.MOAB.DP1.00041.001.001.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [168] "NEON.D13.MOAB.DP1.00041.001.005.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [169] "NEON.D13.MOAB.DP1.00041.001.001.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [170] "NEON.D13.MOAB.DP1.00041.001.004.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [171] "NEON.D13.MOAB.DP1.00041.001.002.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [172] "NEON.D13.MOAB.DP1.00041.001.002.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [173] "NEON.D13.MOAB.DP1.00041.001.001.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [174] "NEON.D13.MOAB.DP1.00041.001.003.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [175] "NEON.D13.MOAB.DP1.00041.001.004.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [176] "NEON.D13.MOAB.DP1.00041.001.002.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [177] "NEON.D13.MOAB.DP1.00041.001.002.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [178] "NEON.D13.MOAB.DP1.00041.001.005.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [179] "NEON.D13.MOAB.DP1.00041.001.001.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [180] "NEON.D13.MOAB.DP1.00041.001.004.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [181] "NEON.D13.MOAB.DP1.00041.001.005.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [182] "NEON.D13.MOAB.DP1.00041.001.005.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [183] "NEON.D13.MOAB.DP1.00041.001.001.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [184] "NEON.D13.MOAB.DP1.00041.001.002.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [185] "NEON.D13.MOAB.DP1.00041.001.001.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [186] "NEON.D13.MOAB.DP1.00041.001.004.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [187] "NEON.D13.MOAB.DP1.00041.001.004.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [188] "NEON.D13.MOAB.DP1.00041.001.001.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"

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
    
    # this list of files is very long, so we'll just look at the first few
    head(cam.files$data$files$name)

    ## [1] "17032816_EH021656(20170328195922)-1145_ort.tif"
    ## [2] "2017_SJER_2_259000_4106000_image.tif"          
    ## [3] "2017_SJER_2_256000_4103000_image.tif"          
    ## [4] "2017_SJER_2_260000_4101000_image.tif"          
    ## [5] "17032816_EH021656(20170328191928)-0793_ort.tif"
    ## [6] "17032816_EH021656(20170328200420)-1178_ort.tif"

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

    ## [1] "WOOD_013.birdGrid.brd" "WOOD_013.birdGrid.brd" "WOOD_013.birdGrid.brd"
    ## [4] "WOOD_013.birdGrid.brd" "WOOD_013.birdGrid.brd" "WOOD_013.birdGrid.brd"

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

Note spatial information under `$data$[nameOfCoordinate]` and under 
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

    ##   |                                                                         |                                                                 |   0%  |                                                                         |=========                                                        |  14%  |                                                                         |===================                                              |  29%  |                                                                         |============================                                     |  43%  |                                                                         |=====================================                            |  57%  |                                                                         |==============================================                   |  71%  |                                                                         |========================================================         |  86%  |                                                                         |=================================================================| 100%

    # plot bird point locations 
    # note that decimal degrees is also an option in the data
    symbols(brd.point.loc$api.easting, brd.point.loc$api.northing, 
            circles=brd.point.loc$coordinateUncertainty, 
            xlab="Easting", ylab="Northing", tck=0.01, inches=F)

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-API/NEON-API-How-To/brd-extr-NL-1.png)

And use `def.calc.geo.os()` to calculate the point locations of observations.


    brd.point.pt <- def.calc.geo.os(brd.point, "brd_perpoint")

    ##   |                                                                         |                                                                 |   0%  |                                                                         |=                                                                |   2%  |                                                                         |==                                                               |   3%  |                                                                         |===                                                              |   5%  |                                                                         |====                                                             |   6%  |                                                                         |=====                                                            |   8%  |                                                                         |======                                                           |  10%  |                                                                         |=======                                                          |  11%  |                                                                         |========                                                         |  13%  |                                                                         |=========                                                        |  14%  |                                                                         |==========                                                       |  16%  |                                                                         |===========                                                      |  17%  |                                                                         |============                                                     |  19%  |                                                                         |=============                                                    |  21%  |                                                                         |==============                                                   |  22%  |                                                                         |===============                                                  |  24%  |                                                                         |=================                                                |  25%  |                                                                         |==================                                               |  27%  |                                                                         |===================                                              |  29%  |                                                                         |====================                                             |  30%  |                                                                         |=====================                                            |  32%  |                                                                         |======================                                           |  33%  |                                                                         |=======================                                          |  35%  |                                                                         |========================                                         |  37%  |                                                                         |=========================                                        |  38%  |                                                                         |==========================                                       |  40%  |                                                                         |===========================                                      |  41%  |                                                                         |============================                                     |  43%  |                                                                         |=============================                                    |  44%  |                                                                         |==============================                                   |  46%  |                                                                         |===============================                                  |  48%  |                                                                         |================================                                 |  49%  |                                                                         |=================================                                |  51%  |                                                                         |==================================                               |  52%  |                                                                         |===================================                              |  54%  |                                                                         |====================================                             |  56%  |                                                                         |=====================================                            |  57%  |                                                                         |======================================                           |  59%  |                                                                         |=======================================                          |  60%  |                                                                         |========================================                         |  62%  |                                                                         |=========================================                        |  63%  |                                                                         |==========================================                       |  65%  |                                                                         |===========================================                      |  67%  |                                                                         |============================================                     |  68%  |                                                                         |=============================================                    |  70%  |                                                                         |==============================================                   |  71%  |                                                                         |===============================================                  |  73%  |                                                                         |================================================                 |  75%  |                                                                         |==================================================               |  76%  |                                                                         |===================================================              |  78%  |                                                                         |====================================================             |  79%  |                                                                         |=====================================================            |  81%  |                                                                         |======================================================           |  83%  |                                                                         |=======================================================          |  84%  |                                                                         |========================================================         |  86%  |                                                                         |=========================================================        |  87%  |                                                                         |==========================================================       |  89%  |                                                                         |===========================================================      |  90%  |                                                                         |============================================================     |  92%  |                                                                         |=============================================================    |  94%  |                                                                         |==============================================================   |  95%  |                                                                         |===============================================================  |  97%  |                                                                         |================================================================ |  98%  |                                                                         |=================================================================| 100%

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
is one of the shorter ones, and use the `verbose=true` option to see 
a more extensive list of taxon data, including many taxon ranks that 
aren't populated for these taxa. For space here, we display only 
the first 10 taxa:


    mam.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?taxonTypeCode=SMALL_MAMMAL&offset=0&limit=500&verbose=true")
    mam.list <- fromJSON(content(mam.req, as="text"))
    mam.list$data[1:10,]

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
    ##               dwc:vernacularName taxonProtocolCategory
    ## 1      Harriss Antelope Squirrel         opportunistic
    ## 2        Texas Antelope Squirrel         opportunistic
    ## 3  Whitetailed Antelope Squirrel         opportunistic
    ## 4                           <NA>         opportunistic
    ## 5      Nelsons Antelope Squirrel         opportunistic
    ## 6                           <NA>         opportunistic
    ## 7                           <NA>            non-target
    ## 8                       Sewellel            non-target
    ## 9               Whitefooted Vole                target
    ## 10                 Red Tree Vole                target
    ##    dwc:nameAccordingToID
    ## 1   isbn: 978 0801882210
    ## 2   isbn: 978 0801882210
    ## 3   isbn: 978 0801882210
    ## 4   isbn: 978 0801882210
    ## 5   isbn: 978 0801882210
    ## 6   isbn: 978 0801882210
    ## 7   isbn: 978 0801882210
    ## 8   isbn: 978 0801882210
    ## 9   isbn: 978 0801882210
    ## 10  isbn: 978 0801882210
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
    ##    dwc:kingdom gbif:subkingdom gbif:infrakingdom gbif:superdivision
    ## 1     Animalia              NA                NA                 NA
    ## 2     Animalia              NA                NA                 NA
    ## 3     Animalia              NA                NA                 NA
    ## 4     Animalia              NA                NA                 NA
    ## 5     Animalia              NA                NA                 NA
    ## 6     Animalia              NA                NA                 NA
    ## 7     Animalia              NA                NA                 NA
    ## 8     Animalia              NA                NA                 NA
    ## 9     Animalia              NA                NA                 NA
    ## 10    Animalia              NA                NA                 NA
    ##    gbif:division gbif:subdivision gbif:infradivision gbif:parvdivision
    ## 1             NA               NA                 NA                NA
    ## 2             NA               NA                 NA                NA
    ## 3             NA               NA                 NA                NA
    ## 4             NA               NA                 NA                NA
    ## 5             NA               NA                 NA                NA
    ## 6             NA               NA                 NA                NA
    ## 7             NA               NA                 NA                NA
    ## 8             NA               NA                 NA                NA
    ## 9             NA               NA                 NA                NA
    ## 10            NA               NA                 NA                NA
    ##    gbif:superphylum dwc:phylum gbif:subphylum gbif:infraphylum
    ## 1                NA   Chordata             NA               NA
    ## 2                NA   Chordata             NA               NA
    ## 3                NA   Chordata             NA               NA
    ## 4                NA   Chordata             NA               NA
    ## 5                NA   Chordata             NA               NA
    ## 6                NA   Chordata             NA               NA
    ## 7                NA   Chordata             NA               NA
    ## 8                NA   Chordata             NA               NA
    ## 9                NA   Chordata             NA               NA
    ## 10               NA   Chordata             NA               NA
    ##    gbif:superclass dwc:class gbif:subclass gbif:infraclass gbif:superorder
    ## 1               NA  Mammalia            NA              NA              NA
    ## 2               NA  Mammalia            NA              NA              NA
    ## 3               NA  Mammalia            NA              NA              NA
    ## 4               NA  Mammalia            NA              NA              NA
    ## 5               NA  Mammalia            NA              NA              NA
    ## 6               NA  Mammalia            NA              NA              NA
    ## 7               NA  Mammalia            NA              NA              NA
    ## 8               NA  Mammalia            NA              NA              NA
    ## 9               NA  Mammalia            NA              NA              NA
    ## 10              NA  Mammalia            NA              NA              NA
    ##    dwc:order gbif:suborder gbif:infraorder gbif:section gbif:subsection
    ## 1   Rodentia            NA              NA           NA              NA
    ## 2   Rodentia            NA              NA           NA              NA
    ## 3   Rodentia            NA              NA           NA              NA
    ## 4   Rodentia            NA              NA           NA              NA
    ## 5   Rodentia            NA              NA           NA              NA
    ## 6   Rodentia            NA              NA           NA              NA
    ## 7   Rodentia            NA              NA           NA              NA
    ## 8   Rodentia            NA              NA           NA              NA
    ## 9   Rodentia            NA              NA           NA              NA
    ## 10  Rodentia            NA              NA           NA              NA
    ##    gbif:superfamily    dwc:family gbif:subfamily gbif:tribe gbif:subtribe
    ## 1                NA     Sciuridae        Xerinae  Marmotini            NA
    ## 2                NA     Sciuridae        Xerinae  Marmotini            NA
    ## 3                NA     Sciuridae        Xerinae  Marmotini            NA
    ## 4                NA     Sciuridae        Xerinae  Marmotini            NA
    ## 5                NA     Sciuridae        Xerinae  Marmotini            NA
    ## 6                NA     Sciuridae        Xerinae  Marmotini            NA
    ## 7                NA Aplodontiidae           <NA>       <NA>            NA
    ## 8                NA Aplodontiidae           <NA>       <NA>            NA
    ## 9                NA    Cricetidae    Arvicolinae       <NA>            NA
    ## 10               NA    Cricetidae    Arvicolinae       <NA>            NA
    ##           dwc:genus dwc:subgenus gbif:subspecies gbif:variety
    ## 1  Ammospermophilus         <NA>              NA           NA
    ## 2  Ammospermophilus         <NA>              NA           NA
    ## 3  Ammospermophilus         <NA>              NA           NA
    ## 4  Ammospermophilus         <NA>              NA           NA
    ## 5  Ammospermophilus         <NA>              NA           NA
    ## 6  Ammospermophilus         <NA>              NA           NA
    ## 7        Aplodontia         <NA>              NA           NA
    ## 8        Aplodontia         <NA>              NA           NA
    ## 9         Arborimus         <NA>              NA           NA
    ## 10        Arborimus         <NA>              NA           NA
    ##    gbif:subvariety gbif:form gbif:subform speciesGroup dwc:specificEpithet
    ## 1               NA        NA           NA           NA            harrisii
    ## 2               NA        NA           NA           NA           interpres
    ## 3               NA        NA           NA           NA            leucurus
    ## 4               NA        NA           NA           NA            leucurus
    ## 5               NA        NA           NA           NA             nelsoni
    ## 6               NA        NA           NA           NA                 sp.
    ## 7               NA        NA           NA           NA                rufa
    ## 8               NA        NA           NA           NA                rufa
    ## 9               NA        NA           NA           NA             albipes
    ## 10              NA        NA           NA           NA         longicaudus
    ##    dwc:infraspecificEpithet
    ## 1                      <NA>
    ## 2                      <NA>
    ## 3                      <NA>
    ## 4                    tersus
    ## 5                      <NA>
    ## 6                      <NA>
    ## 7                     nigra
    ## 8                      <NA>
    ## 9                      <NA>
    ## 10                     <NA>

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
