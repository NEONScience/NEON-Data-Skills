---
syncID: 457a5c01d051491297dc947939b4210f
title: "Using the NEON API in R"
description: "Tutorial for getting data from the NEON API, using R and the R package httr"
dateCreated:  2017-07-07
authors: [Claire K. Lunch]
contributors: [Christine Laney, Megan A. Jones]
estimatedTime: 1 - 1.5 hours
packagesLibraries: httr, jsonlite, devtools, geoNEON, neonDataStackR
topics: data-management, rep-sci
languagesTool: R, API
dataProduct:
code1: R/NEON-API/NEON-API-How-To
tutorialSeries: 
urlTitle: neon-api-usage
---


This is a tutorial in pulling data from the NEON API. The tutorial uses R 
and the R package httr, but the core information about the API is applicable 
to other languages and approaches.

There are 3 basic categories of NEON data:

1. Observational - Data collected by a human in the field, or in an analytical laboratory, e.g. beetle identification, foliar isotopes
1. Instrumentation - Data collected by an automated, streaming sensor, e.g. net radiation, soil carbon dioxide
1. Remote sensing - Data collected by the airborne observation platform, e.g. LIDAR, surface reflectance

This lesson covers the first two types of data. NEON remote sensing data are not currently available through the API.


<div id="ds-objectives" markdown="1">

# Objectives
After completing this activity, you will:

* Be able to pull observational, instrumentation, and geolocation data from the NEON API.
* Be able to transform API-accessed data from JSON to tabular format for analyses.

## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### Install R Packages

* **httr:** `install.packages("httr")`
* **jsonlite:** `install.packages("jsonlite")`
* **dplyr:** `install.packages("dplyr")`
* **devtools:** `install.packages("devtools")`
* **geoNEON:** `devtools::install_github("NEONScience/NEON-geolocation/geoNEON")`
* **neonDataStackR:** `devtools::install_github("NEONScience/NEON-utilities/neonDataStackR")`

### Additional Resources

* [Website for the NEON API](http://data.neonscience.org/data-api)
* [GitHub repository for the NEON API](https://github.com/NEONScience/neon-data-api)
* [ROpenSci wrapper for the NEON API](https://github.com/ropenscilabs/nneo) (not covered in this tutorial)

</div>

## Anatomy of an API call

An example API call: http://data.neonscience.org/api/v0/data/DP1.10003.001/WOOD/2015-07

This includes the base URL, endpoint, and target.

### Base URL: 
<span style="color:#A00606;font-weight:bold">http://data.neonscience.org/api/v0</span><span style="color:#C6C5C5">/data/DP1.10003.001/WOOD/2015-07</span>

Specifics are appended to this in order to get the data or 
metadata you're looking for, but all calls to this API will include 
the base URL. For the NEON API, this is http://data.neonscience.org/api/v0 
(not clickable, because the base URL by itself will take you nowhere!)

### Endpoints: 
<span style="color:#C6C5C5">http://data.neonscience.org/api/v0</span><span style="color:#A00606;font-weight:bold">/data</span><span style="color:#C6C5C5">/DP1.10003.001/WOOD/2015-07</span>

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
<span style="color:#C6C5C5">http://data.neonscience.org/api/v0/data</span><span style="color:#A00606;font-weight:bold">/DP1.10003.001/WOOD/2015-07</span>

The specific data product, site, or location you want to get data for.


## Observational data
Which product do you want to get data for? Consult the <a href="http://data.neonscience.org/data-product-catalog" target="_blank">data product catalog</a>.

We'll pick Breeding landbird point counts, DP1.10003.001

First query the products endpoint of the API to find out which sites and dates 
have data available. In the products endpoint, the target is the numbered 
identifier for the data product:


    library(httr)

    ## Warning: package 'httr' was built under R version 3.4.1

    library(jsonlite)
    library(dplyr, quietly=T)

    ## Warning: package 'dplyr' was built under R version 3.4.1

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    req <- GET("http://data.neonscience.org/api/v0/products/DP1.10003.001")

The object returned from `GET()` has many layers of information. Entering the name of 
the object gives you some basic information about what you downloaded. The `content()` 
function returns the contents in the form of a highly nested list. This is typical of 
JSON-formatted data returned by APIs:


    req

    ## Response [http://data.neonscience.org/api/v0/products/DP1.10003.001]
    ##   Date: 2017-09-28 20:28
    ##   Status: 200
    ##   Content-Type: application/json;charset=UTF-8
    ##   Size: 7.18 kB

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
    ## [1] "Queries for this data product will return data collected during the date range specified for brd_perpoint and brd_countdata, but will return data from all dates for brd_personnel (quiz scores may occur over time periods which are distinct from when sampling occurs) and brd_references (which apply to a broad range of sampling dates). A record from brd_perPoint should have 6+ child records in brd_countdata, at least one per pointCountMinute. Duplicates or missing data may exist where protocol and/or data entry aberrations have occurred; users should check data carefully for anomalies before joining tables."
    ## 
    ## $data$themes
    ## $data$themes[[1]]
    ## [1] "Organisms, Populations, and Communities"
    ## 
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
    ## [1] 2566
    ## 
    ## $data$specs[[2]]$specNumber
    ## [1] "NEON.DOC.00916vB"
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
    ## [1] "DSNY"
    ## 
    ## $data$siteCodes[[1]]$availableMonths
    ## $data$siteCodes[[1]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[1]]$availableMonths[[2]]
    ## [1] "2016-05"
    ## 
    ## 
    ## $data$siteCodes[[1]]$availableDataUrls
    ## $data$siteCodes[[1]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2015-06"
    ## 
    ## $data$siteCodes[[1]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2016-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[2]]
    ## $data$siteCodes[[2]]$siteCode
    ## [1] "BART"
    ## 
    ## $data$siteCodes[[2]]$availableMonths
    ## $data$siteCodes[[2]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[2]]$availableMonths[[2]]
    ## [1] "2016-06"
    ## 
    ## 
    ## $data$siteCodes[[2]]$availableDataUrls
    ## $data$siteCodes[[2]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2015-06"
    ## 
    ## $data$siteCodes[[2]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2016-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[3]]
    ## $data$siteCodes[[3]]$siteCode
    ## [1] "DELA"
    ## 
    ## $data$siteCodes[[3]]$availableMonths
    ## $data$siteCodes[[3]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## 
    ## $data$siteCodes[[3]]$availableDataUrls
    ## $data$siteCodes[[3]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DELA/2015-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[4]]
    ## $data$siteCodes[[4]]$siteCode
    ## [1] "OSBS"
    ## 
    ## $data$siteCodes[[4]]$availableMonths
    ## $data$siteCodes[[4]]$availableMonths[[1]]
    ## [1] "2016-05"
    ## 
    ## 
    ## $data$siteCodes[[4]]$availableDataUrls
    ## $data$siteCodes[[4]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2016-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[5]]
    ## $data$siteCodes[[5]]$siteCode
    ## [1] "GUAN"
    ## 
    ## $data$siteCodes[[5]]$availableMonths
    ## $data$siteCodes[[5]]$availableMonths[[1]]
    ## [1] "2015-05"
    ## 
    ## 
    ## $data$siteCodes[[5]]$availableDataUrls
    ## $data$siteCodes[[5]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2015-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[6]]
    ## $data$siteCodes[[6]]$siteCode
    ## [1] "TREE"
    ## 
    ## $data$siteCodes[[6]]$availableMonths
    ## $data$siteCodes[[6]]$availableMonths[[1]]
    ## [1] "2016-06"
    ## 
    ## 
    ## $data$siteCodes[[6]]$availableDataUrls
    ## $data$siteCodes[[6]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2016-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[7]]
    ## $data$siteCodes[[7]]$siteCode
    ## [1] "SCBI"
    ## 
    ## $data$siteCodes[[7]]$availableMonths
    ## $data$siteCodes[[7]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[7]]$availableMonths[[2]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[7]]$availableMonths[[3]]
    ## [1] "2016-06"
    ## 
    ## 
    ## $data$siteCodes[[7]]$availableDataUrls
    ## $data$siteCodes[[7]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2015-06"
    ## 
    ## $data$siteCodes[[7]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-05"
    ## 
    ## $data$siteCodes[[7]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-06"
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
    ## 
    ## $data$siteCodes[[8]]$availableDataUrls
    ## $data$siteCodes[[8]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2016-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[9]]
    ## $data$siteCodes[[9]]$siteCode
    ## [1] "UNDE"
    ## 
    ## $data$siteCodes[[9]]$availableMonths
    ## $data$siteCodes[[9]]$availableMonths[[1]]
    ## [1] "2016-06"
    ## 
    ## $data$siteCodes[[9]]$availableMonths[[2]]
    ## [1] "2016-07"
    ## 
    ## 
    ## $data$siteCodes[[9]]$availableDataUrls
    ## $data$siteCodes[[9]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-06"
    ## 
    ## $data$siteCodes[[9]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[10]]
    ## $data$siteCodes[[10]]$siteCode
    ## [1] "TALL"
    ## 
    ## $data$siteCodes[[10]]$availableMonths
    ## $data$siteCodes[[10]]$availableMonths[[1]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[10]]$availableMonths[[2]]
    ## [1] "2016-07"
    ## 
    ## 
    ## $data$siteCodes[[10]]$availableDataUrls
    ## $data$siteCodes[[10]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2015-06"
    ## 
    ## $data$siteCodes[[10]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2016-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[11]]
    ## $data$siteCodes[[11]]$siteCode
    ## [1] "STER"
    ## 
    ## $data$siteCodes[[11]]$availableMonths
    ## $data$siteCodes[[11]]$availableMonths[[1]]
    ## [1] "2015-05"
    ## 
    ## $data$siteCodes[[11]]$availableMonths[[2]]
    ## [1] "2016-05"
    ## 
    ## 
    ## $data$siteCodes[[11]]$availableDataUrls
    ## $data$siteCodes[[11]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2015-05"
    ## 
    ## $data$siteCodes[[11]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2016-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[12]]
    ## $data$siteCodes[[12]]$siteCode
    ## [1] "CPER"
    ## 
    ## $data$siteCodes[[12]]$availableMonths
    ## $data$siteCodes[[12]]$availableMonths[[1]]
    ## [1] "2015-05"
    ## 
    ## $data$siteCodes[[12]]$availableMonths[[2]]
    ## [1] "2016-05"
    ## 
    ## 
    ## $data$siteCodes[[12]]$availableDataUrls
    ## $data$siteCodes[[12]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2015-05"
    ## 
    ## $data$siteCodes[[12]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2016-05"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[13]]
    ## $data$siteCodes[[13]]$siteCode
    ## [1] "ORNL"
    ## 
    ## $data$siteCodes[[13]]$availableMonths
    ## $data$siteCodes[[13]]$availableMonths[[1]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[13]]$availableMonths[[2]]
    ## [1] "2016-06"
    ## 
    ## 
    ## $data$siteCodes[[13]]$availableDataUrls
    ## $data$siteCodes[[13]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-05"
    ## 
    ## $data$siteCodes[[13]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[14]]
    ## $data$siteCodes[[14]]$siteCode
    ## [1] "STEI"
    ## 
    ## $data$siteCodes[[14]]$availableMonths
    ## $data$siteCodes[[14]]$availableMonths[[1]]
    ## [1] "2016-05"
    ## 
    ## $data$siteCodes[[14]]$availableMonths[[2]]
    ## [1] "2016-06"
    ## 
    ## 
    ## $data$siteCodes[[14]]$availableDataUrls
    ## $data$siteCodes[[14]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-05"
    ## 
    ## $data$siteCodes[[14]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[15]]
    ## $data$siteCodes[[15]]$siteCode
    ## [1] "GRSM"
    ## 
    ## $data$siteCodes[[15]]$availableMonths
    ## $data$siteCodes[[15]]$availableMonths[[1]]
    ## [1] "2016-06"
    ## 
    ## 
    ## $data$siteCodes[[15]]$availableDataUrls
    ## $data$siteCodes[[15]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2016-06"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[16]]
    ## $data$siteCodes[[16]]$siteCode
    ## [1] "WOOD"
    ## 
    ## $data$siteCodes[[16]]$availableMonths
    ## $data$siteCodes[[16]]$availableMonths[[1]]
    ## [1] "2015-07"
    ## 
    ## 
    ## $data$siteCodes[[16]]$availableDataUrls
    ## $data$siteCodes[[16]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2015-07"
    ## 
    ## 
    ## 
    ## $data$siteCodes[[17]]
    ## $data$siteCodes[[17]]$siteCode
    ## [1] "HARV"
    ## 
    ## $data$siteCodes[[17]]$availableMonths
    ## $data$siteCodes[[17]]$availableMonths[[1]]
    ## [1] "2015-05"
    ## 
    ## $data$siteCodes[[17]]$availableMonths[[2]]
    ## [1] "2015-06"
    ## 
    ## $data$siteCodes[[17]]$availableMonths[[3]]
    ## [1] "2016-06"
    ## 
    ## 
    ## $data$siteCodes[[17]]$availableDataUrls
    ## $data$siteCodes[[17]]$availableDataUrls[[1]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-05"
    ## 
    ## $data$siteCodes[[17]]$availableDataUrls[[2]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-06"
    ## 
    ## $data$siteCodes[[17]]$availableDataUrls[[3]]
    ## [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2016-06"

To get a more accessible view of which sites have data for which months, you'll 
need to extract data from the nested list. There are a variety of ways to do this, 
in this tutorial we'll explore a couple of them. Here we'll use `fromJSON()`, in the 
`jsonlite` package, which doesn't fully flatten the nested list, but gets us the part 
we need. To use it, we need a text version of the content:


    req.text <- content(req, as="text")
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
    ## [1] "Queries for this data product will return data collected during the date range specified for brd_perpoint and brd_countdata, but will return data from all dates for brd_personnel (quiz scores may occur over time periods which are distinct from when sampling occurs) and brd_references (which apply to a broad range of sampling dates). A record from brd_perPoint should have 6+ child records in brd_countdata, at least one per pointCountMinute. Duplicates or missing data may exist where protocol and/or data entry aberrations have occurred; users should check data carefully for anomalies before joining tables."
    ## 
    ## $data$themes
    ## [1] "Organisms, Populations, and Communities"
    ## 
    ## $data$specs
    ##   specId             specNumber
    ## 1   2565 NEON_bird_userGuide_vA
    ## 2   2566       NEON.DOC.00916vB
    ## 3   2567      NEON.DOC.014041vF
    ## 
    ## $data$keywords
    ## [1] "birds"                 "diversity"             "taxonomy"             
    ## [4] "community composition" "distance sampling"     "avian"                
    ## [7] "species composition"   "population"            "landbirds"            
    ## 
    ## $data$siteCodes
    ##    siteCode           availableMonths
    ## 1      DSNY          2015-06, 2016-05
    ## 2      BART          2015-06, 2016-06
    ## 3      DELA                   2015-06
    ## 4      OSBS                   2016-05
    ## 5      GUAN                   2015-05
    ## 6      TREE                   2016-06
    ## 7      SCBI 2015-06, 2016-05, 2016-06
    ## 8      JERC                   2016-06
    ## 9      UNDE          2016-06, 2016-07
    ## 10     TALL          2015-06, 2016-07
    ## 11     STER          2015-05, 2016-05
    ## 12     CPER          2015-05, 2016-05
    ## 13     ORNL          2016-05, 2016-06
    ## 14     STEI          2016-05, 2016-06
    ## 15     GRSM                   2016-06
    ## 16     WOOD                   2015-07
    ## 17     HARV 2015-05, 2015-06, 2016-06
    ##                                                                                                                                                                                                      availableDataUrls
    ## 1                                                                         http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2016-05
    ## 2                                                                         http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2016-06
    ## 3                                                                                                                                                http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DELA/2015-06
    ## 4                                                                                                                                                http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2016-05
    ## 5                                                                                                                                                http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2015-05
    ## 6                                                                                                                                                http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2016-06
    ## 7  http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-06
    ## 8                                                                                                                                                http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2016-06
    ## 9                                                                         http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-07
    ## 10                                                                        http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2016-07
    ## 11                                                                        http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2015-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2016-05
    ## 12                                                                        http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2015-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2016-05
    ## 13                                                                        http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-06
    ## 14                                                                        http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-06
    ## 15                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2016-06
    ## 16                                                                                                                                               http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2015-07
    ## 17 http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-05, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-06, http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2016-06

The object contains a lot of information about the data product, including 
keywords under `$data$keywords`, references for documentation under `$data$specs`, 
and data availability by site and month under `$data$siteCodes`, 
which is what we need to tell us what we can download. The specific 
URLs for the API calls for each site and month are listed under 
`$data$siteCodes$availableDataUrls`, so we don't even have to write the calls 
ourselves in the next steps.


    bird.urls <- unlist(avail$data$siteCodes$availableDataUrls)
    bird.urls

    ##  [1] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2015-06"
    ##  [2] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DSNY/2016-05"
    ##  [3] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2015-06"
    ##  [4] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/BART/2016-06"
    ##  [5] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/DELA/2015-06"
    ##  [6] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/OSBS/2016-05"
    ##  [7] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GUAN/2015-05"
    ##  [8] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TREE/2016-06"
    ##  [9] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2015-06"
    ## [10] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-05"
    ## [11] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/SCBI/2016-06"
    ## [12] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/JERC/2016-06"
    ## [13] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-06"
    ## [14] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/UNDE/2016-07"
    ## [15] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2015-06"
    ## [16] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/TALL/2016-07"
    ## [17] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2015-05"
    ## [18] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STER/2016-05"
    ## [19] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2015-05"
    ## [20] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/CPER/2016-05"
    ## [21] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-05"
    ## [22] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/ORNL/2016-06"
    ## [23] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-05"
    ## [24] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/STEI/2016-06"
    ## [25] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/GRSM/2016-06"
    ## [26] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/WOOD/2015-07"
    ## [27] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-05"
    ## [28] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2015-06"
    ## [29] "http://data.neonscience.org:80/api/v0/data/DP1.10003.001/HARV/2016-06"

These are the URLs showing us what files are available for each month where 
there are data. For simplicity, we'll just query the single month of data 
available at the Woodworth (WOOD) site.


    brd <- GET(bird.urls[grep("WOOD", bird.urls)])
    brd.files <- fromJSON(content(brd, as="text"))
    brd.files$data$files

    ##                               crc32
    ## 1  c26d8ee478ddc41e5a3ebf0b1adb8c17
    ## 2  4a5f2420d1f24131e350e4adc207b12e
    ## 3  5ce80c39de222e286f73b915c06527dd
    ## 4  9d746c8eb43b6d84e2db925d9aca50b1
    ## 5  88b416d167e5021e40cdae7ec605c194
    ## 6  7d1d2c21f0016212087cdc1041f37054
    ## 7  9bc7bc357209579748cb103a899933b0
    ## 8  8241d346adeeac463737112f47cffaa8
    ## 9  7d1d2c21f0016212087cdc1041f37054
    ## 10 4a5f2420d1f24131e350e4adc207b12e
    ## 11 9bc7bc357209579748cb103a899933b0
    ## 12 4972362cad0bd5873aa356af86e45826
    ## 13 bfb5fd016eb775adf65bdb0c4b0914f8
    ## 14 cdbd556c2b5396115fde5b22f6643d81
    ## 15 61b33b64b9095e50331295a2cf6c0bbc
    ##                                                                               name
    ## 1                                NEON.D09.WOOD.DP1.10003.001.20150101-20160613.xml
    ## 2      NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.basic.20170720T182547Z.csv
    ## 3                   NEON.D09.WOOD.DP1.10003.001.2015-07.basic.20170720T182547Z.zip
    ## 4     NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.basic.20170720T182547Z.csv
    ## 5                                                    NEON.DP1.10003.001_readme.txt
    ## 6                      NEON.D09.WOOD.DP0.10003.001.validation.20170720T182547Z.csv
    ## 7                       NEON.D09.WOOD.DP1.10003.001.variables.20170720T182547Z.csv
    ## 8                           NEON.Bird Conservancy of the Rockies.brd_personnel.csv
    ## 9                      NEON.D09.WOOD.DP0.10003.001.validation.20170720T182547Z.csv
    ## 10  NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.expanded.20170720T182547Z.csv
    ## 11                      NEON.D09.WOOD.DP1.10003.001.variables.20170720T182547Z.csv
    ## 12               NEON.D09.WOOD.DP1.10003.001.2015-07.expanded.20170720T182547Z.zip
    ## 13 NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.expanded.20170720T182547Z.csv
    ## 14                                                   NEON.DP1.10003.001_readme.txt
    ## 15                               NEON.D09.WOOD.DP1.10003.001.20150101-20160613.xml
    ##      size
    ## 1   69927
    ## 2   23962
    ## 3   67239
    ## 4  355660
    ## 5   11098
    ## 6    9826
    ## 7    7280
    ## 8    2553
    ## 9    9826
    ## 10  23962
    ## 11   7280
    ## 12  69271
    ## 13 376383
    ## 14  11234
    ## 15  74721
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   url
    ## 1                                   https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.20150101-20160613.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=14c3a59c58ee5baa8dfe84adaff640a829eaf914eaf213f05127c7af47c20d47
    ## 2         https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.basic.20170720T182547Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=6ed9ea5c078973e76726909b6ef40d68128d8a044b04158bd63d4553e1b74b08
    ## 3                      https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.2015-07.basic.20170720T182547Z.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=cfa0361c1a7624e0d68dcce3a852f1d9ecc8c78efbed9bee5b50eae28c5b1cea
    ## 4        https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.basic.20170720T182547Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=9ea67b4bd7efea87efd4344cde1d5dfa48f45212430c4b363b65e218e2b02c9f
    ## 5                                                       https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.DP1.10003.001_readme.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=fd2aed89d17c2b155b50ced53a8f65ee32d30b27b33c2891d2c742db89a02f3c
    ## 6                         https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP0.10003.001.validation.20170720T182547Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=719933fde5f662bab081d00a241bdbbcbf03f9a1ec565360ba06aae17a6c2a44
    ## 7                          https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/basic/NEON.D09.WOOD.DP1.10003.001.variables.20170720T182547Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=1aab6a8809faa2356b5ab9e3b70227c4fb559a86426ae6a0e01b54ca012bd2c1
    ## 8                   https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.Bird%20Conservancy%20of%20the%20Rockies.brd_personnel.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=12af66cb82968467707e97d18730b47d3aa4d528f3c720ed23b0b5f79f8b671e
    ## 9                      https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP0.10003.001.validation.20170720T182547Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=a81e4a0eee8b5e170feb5618515660df67e8c00d4cae2080961cb34050a41fea
    ## 10  https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.brd_perpoint.2015-07.expanded.20170720T182547Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=af6be2f2d2587fddf79a2b2e20ad68c73fa4c2164b0d68779e7b346e3e7ed25b
    ## 11                      https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.variables.20170720T182547Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=4fc823828428fb5547eb71e1cac2fcaac972674c715cef393f30c944689562f8
    ## 12               https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.2015-07.expanded.20170720T182547Z.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=4498b70e04c1924618179eb4bcdf5b178e4d5f99079600dd4a8f9567115416bd
    ## 13 https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.brd_countdata.2015-07.expanded.20170720T182547Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=67230e91c44e4962348557dd5d4f8b6f88104dc76d4a588c60c9fd18a27070cc
    ## 14                                                   https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.DP1.10003.001_readme.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=427ef4d28b2c7dd6546018f802db6eebd99e5ebe27db2f82e7709e0862306e93
    ## 15                               https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/WOOD/20150701T000000--20150801T000000/expanded/NEON.D09.WOOD.DP1.10003.001.20150101-20160613.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20170928T202822Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20170928%2Fdata%2Fs3%2Faws4_request&X-Amz-Signature=1107a027a2533fb1f588303794fb94eb6c867f5dbe7f007ecb05d561e29a4fda

And now we have the names of the files available for this site and 
month, and URLs where we can get the files. We'll use 
the file names to pick which ones we want.

The available files include both data and metadata, and both the basic and 
expanded data packages. Metadata are described by file name below. Basic 
and expanded data packages are available for most NEON data products 
(some only have basic). Typically the expanded package includes additional 
quality or uncertainty data, either in additional files or additional 
fields in the basic files.

The format for most of the file names is 
NEON.[domain number].[site code].[data product ID].[file-specific name].
[date of file creation] 

Some files omit the domain and site, since they're not specific to a 
location, like the data product readme. The date of file creation, in 
this case 20170720T182547Z, can be used to determine whether data have 
been updated since the last time you downloaded.

Leaving off NEON.D09.WOOD.10003.001, available files in our query for 
July 2015 at Woodworth are all of the following: 

* **~.2015-07.expanded.20170720T182547Z.zip:** zip of all files in the expanded package
  
* **~.brd_countdata.2015-07.expanded.20170720T182547Z.csv:** count data table, expanded package version: counts of birds at each point
  
* **~.brd_perpoint.2015-07.expanded.20170720T182547Z.csv:** point data table, expanded package version: metadata at each observation point
  
* **NEON.Bird Conservancy of the Rockies.brd_personnel.csv:** personnel data table: accuracy scores for bird observers
  
* **~.2015-07.basic.20170720T182547Z.zip:** zip of all files in the basic package
  
* **~.brd_countdata.2015-07.basic.20170720T182547Z.csv:** count data table, basic package version: counts of birds at each point
  
* **~.brd_perpoint.2015-07.basic.20170720T182547Z.csv:** point data table, basic package version: metadata at each observation point
  
* **NEON.DP1.10003.001_readme.txt:** readme for the data product (not specific to dates or location). Appears twice in the list, since it's in both the basic and expanded package
  
* **~.20150101-20160613.xml:** Ecological Metadata Language (EML) file. Appears twice in the list, since it's in both the basic and expanded package
  
* **~.validation.20170720T182547Z.csv:** validation file for the data product: lists input data and data entry rules. Appears twice in the list, since it's in both the basic and expanded package
  
* **~.variables.20170720T182547Z.csv:** variables file for the data product: lists data fields in downloaded tables. Appears twice in the list, since it's in both the basic and expanded package


We'll get the data tables for the point data and count data in the basic 
package. The list of files doesn't return in the same order every time, so we 
won't use position in the list to select. Plus, we want code we can re-use 
when getting data from other sites and other months. So we select files 
based on the data table name and the package name:


    brd.count <- read.delim(brd.files$data$files$url
                            [intersect(grep("countdata", brd.files$data$files$name),
                                        grep("basic", brd.files$data$files$name))], sep=",")
    
    brd.point <- read.delim(brd.files$data$files$url
                            [intersect(grep("perpoint", brd.files$data$files$name),
                                        grep("basic", brd.files$data$files$name))], sep=",")

Just to prove the files we pulled have actual data in them, a quick graphic:


    clusterBySp <- brd.count %>% group_by(scientificName) %>% 
      summarize(total=sum(clusterSize))
    clusterBySp <- clusterBySp[order(clusterBySp$total, decreasing=T),]
    barplot(clusterBySp$total, names.arg=clusterBySp$scientificName, 
            ylab="Total", cex.names=0.5, las=2)

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-API//NEON-API-How-To/os-plot-bird-data-1.png)


## Instrumentation data
The process is essentially the same for sensor data. We'll do the same series of 
queries for Soil temperature, DP1.00041.001, and get data from Moab in March.


    req.soil <- GET("http://data.neonscience.org/api/v0/products/DP1.00041.001")
    avail.soil <- fromJSON(content(req.soil, as="text"), simplifyDataFrame=T, flatten=T)
    temp.urls <- unlist(avail.soil$data$siteCodes$availableDataUrls)
    tmp <- GET(temp.urls[grep("MOAB/2017-03", temp.urls)])
    tmp.files <- fromJSON(content(tmp, as="text"))
    tmp.files$data$files$name

    ##   [1] "NEON.D13.MOAB.DP1.00041.001.003.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##   [2] "NEON.D13.MOAB.DP1.00041.001.005.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [3] "NEON.D13.MOAB.DP1.00041.001.003.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [4] "NEON.D13.MOAB.DP1.00041.001.003.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [5] "NEON.D13.MOAB.DP1.00041.001.001.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##   [6] "NEON.D13.MOAB.DP1.00041.001.002.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##   [7] "NEON.D13.MOAB.DP1.00041.001.005.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##   [8] "NEON.D13.MOAB.DP1.00041.001.variables.20170804T063725Z.csv"                                
    ##   [9] "NEON.D13.MOAB.DP1.00041.001.005.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [10] "NEON.D13.MOAB.DP1.00041.001.004.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [11] "NEON.D13.MOAB.DP1.00041.001.001.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [12] "NEON.D13.MOAB.DP1.00041.001.001.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [13] "NEON.D13.MOAB.DP1.00041.001.001.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [14] "NEON.D13.MOAB.DP1.00041.001.003.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [15] "NEON.D13.MOAB.DP1.00041.001.004.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [16] "NEON.D13.MOAB.DP1.00041.001.003.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [17] "NEON.D13.MOAB.DP1.00041.001.002.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [18] "NEON.D13.MOAB.DP1.00041.001.003.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [19] "NEON.D13.MOAB.DP1.00041.001.005.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [20] "NEON.D13.MOAB.DP1.00041.001.005.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [21] "NEON.D13.MOAB.DP1.00041.001.004.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [22] "NEON.D13.MOAB.DP1.00041.001.005.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [23] "NEON.D13.MOAB.DP1.00041.001.003.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [24] "NEON.D13.MOAB.DP1.00041.001.001.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [25] "NEON.D13.MOAB.DP1.00041.001.003.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [26] "NEON.D13.MOAB.DP1.00041.001.004.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [27] "NEON.D13.MOAB.DP1.00041.001.005.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [28] "NEON.D13.MOAB.DP1.00041.001.004.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [29] "NEON.D13.MOAB.DP1.00041.001.005.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [30] "NEON.D13.MOAB.DP1.00041.001.002.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [31] "NEON.D13.MOAB.DP1.00041.001.002.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [32] "NEON.D13.MOAB.DP1.00041.001.001.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [33] "NEON.D13.MOAB.DP1.00041.001.002.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [34] "NEON.D13.MOAB.DP1.00041.001.004.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [35] "NEON.D13.MOAB.DP1.00041.001.005.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [36] "NEON.D13.MOAB.DP1.00041.001.002.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [37] "NEON.D13.MOAB.DP1.00041.001.001.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [38] "NEON.D13.MOAB.DP1.00041.001.002.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [39] "NEON.D13.MOAB.DP1.00041.001.001.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [40] "NEON.D13.MOAB.DP1.00041.001.003.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [41] "NEON.D13.MOAB.DP1.00041.001.002.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [42] "NEON.D13.MOAB.DP1.00041.001.2017-03.basic.20170804T063725Z.zip"                            
    ##  [43] "NEON.D13.MOAB.DP1.00041.001.004.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [44] "NEON.D13.MOAB.DP1.00041.001.003.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [45] "NEON.D13.MOAB.DP1.00041.001.002.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [46] "NEON.D13.MOAB.DP1.00041.001.004.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [47] "NEON.D13.MOAB.DP1.00041.001.003.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [48] "NEON.D13.MOAB.DP1.00041.001.001.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [49] "NEON.D13.MOAB.DP1.00041.001.001.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [50] "NEON.D13.MOAB.DP1.00041.001.002.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [51] "NEON.D13.MOAB.DP1.00041.001.004.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [52] "NEON.D13.MOAB.DP1.00041.001.005.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [53] "NEON.DP1.00041.001_readme.txt"                                                             
    ##  [54] "NEON.D13.MOAB.DP1.00041.001.004.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [55] "NEON.D13.MOAB.DP1.00041.001.004.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [56] "NEON.D13.MOAB.DP1.00041.001.002.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [57] "NEON.D13.MOAB.DP1.00041.001.005.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [58] "NEON.D13.MOAB.DP1.00041.001.001.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [59] "NEON.D13.MOAB.DP1.00041.001.005.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [60] "NEON.D13.MOAB.DP1.00041.001.004.506.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [61] "NEON.D13.MOAB.DP1.00041.001.005.507.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [62] "NEON.D13.MOAB.DP1.00041.001.003.505.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [63] "NEON.D13.MOAB.DP1.00041.001.005.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [64] "NEON.D13.MOAB.DP1.00041.001.004.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [65] "NEON.D13.MOAB.DP1.00041.001.004.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [66] "NEON.D13.MOAB.DP1.00041.001.004.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [67] "NEON.D13.MOAB.DP1.00041.001.002.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [68] "NEON.D13.MOAB.DP1.00041.001.003.502.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [69] "NEON.D13.MOAB.DP1.00041.001.002.507.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [70] "NEON.D13.MOAB.DP1.00041.001.001.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [71] "NEON.D13.MOAB.DP1.00041.001.004.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [72] "NEON.D13.MOAB.DP1.00041.001.002.509.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [73] "NEON.D13.MOAB.DP1.00041.001.005.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [74] "NEON.D13.MOAB.DP1.00041.001.002.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [75] "NEON.D13.MOAB.DP1.00041.001.001.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [76] "NEON.D13.MOAB.DP1.00041.001.001.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [77] "NEON.D13.MOAB.DP1.00041.001.003.501.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [78] "NEON.D13.MOAB.DP1.00041.001.005.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [79] "NEON.D13.MOAB.DP1.00041.001.005.504.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [80] "NEON.D13.MOAB.DP1.00041.001.001.505.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [81] "NEON.D13.MOAB.DP1.00041.001.20170308-20170401.xml"                                         
    ##  [82] "NEON.D13.MOAB.DP1.00041.001.001.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [83] "NEON.D13.MOAB.DP1.00041.001.001.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [84] "NEON.D13.MOAB.DP1.00041.001.005.504.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [85] "NEON.D13.MOAB.DP1.00041.001.003.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [86] "NEON.D13.MOAB.DP1.00041.001.003.508.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [87] "NEON.D13.MOAB.DP1.00041.001.002.508.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [88] "NEON.D13.MOAB.DP1.00041.001.002.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [89] "NEON.D13.MOAB.DP1.00041.001.002.503.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [90] "NEON.D13.MOAB.DP1.00041.001.001.503.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [91] "NEON.D13.MOAB.DP1.00041.001.003.502.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [92] "NEON.D13.MOAB.DP1.00041.001.004.501.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [93] "NEON.D13.MOAB.DP1.00041.001.004.506.030.ST_30_minute.2017-03.basic.20170804T063725Z.csv"   
    ##  [94] "NEON.D13.MOAB.DP1.00041.001.003.509.001.ST_1_minute.2017-03.basic.20170804T063725Z.csv"    
    ##  [95] "NEON.D13.MOAB.DP1.00041.001.005.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ##  [96] "NEON.D13.MOAB.DP1.00041.001.001.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ##  [97] "NEON.D13.MOAB.DP1.00041.001.002.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ##  [98] "NEON.D13.MOAB.DP1.00041.001.001.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ##  [99] "NEON.D13.MOAB.DP1.00041.001.001.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [100] "NEON.D13.MOAB.DP1.00041.001.003.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [101] "NEON.D13.MOAB.DP1.00041.001.004.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [102] "NEON.D13.MOAB.DP1.00041.001.005.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [103] "NEON.D13.MOAB.DP1.00041.001.004.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [104] "NEON.D13.MOAB.DP1.00041.001.004.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [105] "NEON.D13.MOAB.DP1.00041.001.2017-03.expanded.20170804T063725Z.zip"                         
    ## [106] "NEON.D13.MOAB.DP1.00041.001.002.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [107] "NEON.D13.MOAB.DP1.00041.001.005.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [108] "NEON.D13.MOAB.DP1.00041.001.005.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [109] "NEON.D13.MOAB.DP1.00041.001.004.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [110] "NEON.D13.MOAB.DP1.00041.001.005.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [111] "NEON.D13.MOAB.DP1.00041.001.004.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [112] "NEON.D13.MOAB.DP1.00041.001.005.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [113] "NEON.D13.MOAB.DP1.00041.001.003.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [114] "NEON.D13.MOAB.DP1.00041.001.002.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [115] "NEON.D13.MOAB.DP1.00041.001.003.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [116] "NEON.D13.MOAB.DP1.00041.001.005.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [117] "NEON.D13.MOAB.DP1.00041.001.002.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [118] "NEON.D13.MOAB.DP1.00041.001.003.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [119] "NEON.D13.MOAB.DP1.00041.001.001.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [120] "NEON.D13.MOAB.DP1.00041.001.004.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [121] "NEON.D13.MOAB.DP1.00041.001.003.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [122] "NEON.D13.MOAB.DP1.00041.001.002.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [123] "NEON.D13.MOAB.DP1.00041.001.002.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [124] "NEON.D13.MOAB.DP1.00041.001.001.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [125] "NEON.D13.MOAB.DP1.00041.001.005.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [126] "NEON.D13.MOAB.DP1.00041.001.002.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [127] "NEON.D13.MOAB.DP1.00041.001.002.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [128] "NEON.D13.MOAB.DP1.00041.001.001.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [129] "NEON.D13.MOAB.DP1.00041.001.003.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [130] "NEON.D13.MOAB.DP1.00041.001.001.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [131] "NEON.D13.MOAB.DP1.00041.001.variables.20170804T063725Z.csv"                                
    ## [132] "NEON.D13.MOAB.DP1.00041.001.005.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [133] "NEON.D13.MOAB.DP1.00041.001.002.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [134] "NEON.D13.MOAB.DP1.00041.001.003.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [135] "NEON.D13.MOAB.DP1.00041.001.004.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [136] "NEON.D13.MOAB.DP1.00041.001.005.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [137] "NEON.D13.MOAB.DP1.00041.001.002.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [138] "NEON.D13.MOAB.DP1.00041.001.004.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [139] "NEON.DP1.00041.001_readme.txt"                                                             
    ## [140] "NEON.D13.MOAB.DP1.00041.001.005.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [141] "NEON.D13.MOAB.DP1.00041.001.004.507.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [142] "NEON.D13.MOAB.DP1.00041.001.004.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [143] "NEON.D13.MOAB.DP1.00041.001.004.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [144] "NEON.D13.MOAB.DP1.00041.001.003.503.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [145] "NEON.D13.MOAB.DP1.00041.001.005.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [146] "NEON.D13.MOAB.DP1.00041.001.005.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [147] "NEON.D13.MOAB.DP1.00041.001.005.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [148] "NEON.D13.MOAB.DP1.00041.001.003.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [149] "NEON.D13.MOAB.DP1.00041.001.004.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [150] "NEON.D13.MOAB.DP1.00041.001.002.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [151] "NEON.D13.MOAB.DP1.00041.001.003.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [152] "NEON.D13.MOAB.DP1.00041.001.002.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [153] "NEON.D13.MOAB.DP1.00041.001.002.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [154] "NEON.D13.MOAB.DP1.00041.001.001.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [155] "NEON.D13.MOAB.DP1.00041.001.003.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [156] "NEON.D13.MOAB.DP1.00041.001.001.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [157] "NEON.D13.MOAB.DP1.00041.001.003.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [158] "NEON.D13.MOAB.DP1.00041.001.001.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [159] "NEON.D13.MOAB.DP1.00041.001.004.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [160] "NEON.D13.MOAB.DP1.00041.001.004.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [161] "NEON.D13.MOAB.DP1.00041.001.005.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [162] "NEON.D13.MOAB.DP1.00041.001.003.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [163] "NEON.D13.MOAB.DP1.00041.001.001.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [164] "NEON.D13.MOAB.DP1.00041.001.004.504.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [165] "NEON.D13.MOAB.DP1.00041.001.002.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [166] "NEON.D13.MOAB.DP1.00041.001.001.506.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [167] "NEON.D13.MOAB.DP1.00041.001.001.509.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [168] "NEON.D13.MOAB.DP1.00041.001.002.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [169] "NEON.D13.MOAB.DP1.00041.001.002.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [170] "NEON.D13.MOAB.DP1.00041.001.20170308-20170401.xml"                                         
    ## [171] "NEON.D13.MOAB.DP1.00041.001.003.507.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [172] "NEON.D13.MOAB.DP1.00041.001.001.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [173] "NEON.D13.MOAB.DP1.00041.001.003.501.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [174] "NEON.D13.MOAB.DP1.00041.001.004.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [175] "NEON.D13.MOAB.DP1.00041.001.003.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [176] "NEON.D13.MOAB.DP1.00041.001.004.501.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [177] "NEON.D13.MOAB.DP1.00041.001.003.509.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [178] "NEON.D13.MOAB.DP1.00041.001.003.505.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [179] "NEON.D13.MOAB.DP1.00041.001.005.504.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [180] "NEON.D13.MOAB.DP1.00041.001.001.502.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [181] "NEON.D13.MOAB.DP1.00041.001.001.506.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [182] "NEON.D13.MOAB.DP1.00041.001.005.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [183] "NEON.D13.MOAB.DP1.00041.001.005.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [184] "NEON.D13.MOAB.DP1.00041.001.002.508.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"
    ## [185] "NEON.D13.MOAB.DP1.00041.001.001.505.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [186] "NEON.D13.MOAB.DP1.00041.001.001.508.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [187] "NEON.D13.MOAB.DP1.00041.001.004.503.001.ST_1_minute.2017-03.expanded.20170804T063725Z.csv" 
    ## [188] "NEON.D13.MOAB.DP1.00041.001.002.502.030.ST_30_minute.2017-03.expanded.20170804T063725Z.csv"

These file names start and end the same way as the observational 
files, but the middle is a little more cryptic. The structure 
from beginning to end is: 

NEON.[domain number].[site code].[data product ID].00000.
[soil plot number].[depth].[averaging interval].[data table name].
[year]-[month].[data package].[date of file creation]

So NEON.D13.MOAB.DP1.00041.001.00000.002.504.030.ST_30_minute.
2017-03.basic.20170804T063725Z.csv is 
the basic data package of the 30-minute mean of soil temperature 
from March 2017 at Moab in soil plot 2, 4th depth below the 
surface, published on Aug 4, 2017, at 06:37:25 GMT.

We'll pull out the URL for the plot and depth described above by 
selecting "002.504.030" and the word "basic" in the file name.

Go get it:


    soil.temp <- read.delim(tmp.files$data$files$url
                            [intersect(grep("002.504.030", tmp.files$data$files$name),
                                       grep("basic", tmp.files$data$files$name))], sep=",")

And again, a plot to show we've downloaded something with data in it:


    plot(soil.temp$soilTempMean~soil.temp$startDateTime, pch=".", xlab="Date", ylab="T")

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-API//NEON-API-How-To/os-plot-soil-data-1.png)

Note: NEON instrumentation data products are currently being reprocessed 
on a rolling basis, and as each product is re-deployed, the files will 
begin to appear in the format described here. Products that haven't yet 
been reprocessed will return file names like the above, but missing the 
year, month, package, and date of creation specifications.


## Geolocation data
You may have noticed some of the spatial data referenced above is a bit vague, 
e.g. "soil plot 2, 4th depth below the surface."

How to get spatial data and what to do with it depends on which type of 
data you're working with.

### Instrumentation data (either aquatic or terrestrial)
Stay tuned - spatial data for instruments are in the process of entry into 
the NEON database.

### Observational data - Aquatic
Latitude, longitude, elevation, and associated uncertainties are included in 
data downloads. Most products also include an "additional coordinate uncertainty" 
that should be added to the provided uncertainty. Additional spatial data, such 
as northing and easting, can be downloaded from the API.

### Observational data - Terrestrial
Latitude, longitude, elevation, and associated uncertainties are included in 
data downloads. These are the coordinates and uncertainty of the sampling plot; 
for many protocols it is possible to calculate a more precise location. 
Instructions for doing this are in the data product user guides, and code is 
in the `geoNEON` package on GitHub.

### Querying a single named location
Let's look at the named locations in the bird data we downloaded. To do this, 
look for the field called `namedLocation`, which is present in all observational 
data products, both aquatic and terrestrial.


    head(brd.point$namedLocation)

    ## [1] WOOD_013.birdGrid.brd WOOD_013.birdGrid.brd WOOD_013.birdGrid.brd
    ## [4] WOOD_013.birdGrid.brd WOOD_013.birdGrid.brd WOOD_013.birdGrid.brd
    ## 7 Levels: WOOD_006.birdGrid.brd ... WOOD_020.birdGrid.brd

Query the locations endpoint of the API for the first named location, 
WOOD_013.birdGrid.brd


    req.loc <- GET("http://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd")
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
    ## 1             Value for Reference Point Position                    B2
    ## 2                      Value for Plot dimensions           500m x 500m
    ## 3                Value for Subtype Specification            ninePoints
    ## 4                         Value for Plot subtype              birdGrid
    ## 5                            Value for Plot type           distributed
    ## 6  Value for National Land Cover Database (2001)   grasslandHerbaceous
    ## 7                      Value for Soil type order             Mollisols
    ## 8                            Value for Plot size                250000
    ## 9                              Value for Plot ID              WOOD_013
    ## 10                      Value for State province                    ND
    ## 11                             Value for Country          unitedStates
    ## 12    Value for Positional dilution of precision                   2.4
    ## 13    Value for Horizontal dilution of precision                     1
    ## 14              Value for Coordinate uncertainty                  0.28
    ## 15               Value for Elevation uncertainty                  0.48
    ## 16                   Value for Minimum elevation                569.79
    ## 17                              Value for County              Stutsman
    ## 18                   Value for Coordinate source            GeoXH 6000
    ## 19                            Value for UTM Zone                   14N
    ## 20                  Value for Filtered positions                   121
    ## 21                   Value for Maximum elevation                579.31
    ## 22                      Value for Geodetic datum                 WGS84
    ## 23                        Value for Slope aspect                238.91
    ## 24                      Value for Slope gradient                  2.83

Note spatial information under `$data` and under `$data$locationProperties`.
Also note `$data$locationChildren`: these are the finer scale locations that 
can be used to calculate precise spatial data for bird observations.

For convenience, we'll use the `geoNEON` package to make the calculations. 
First we'll use `def.extr.geo.os()` to get the additional spatial information 
available through the API, and look at the spatial resolution available in the 
initial download:


    library(geoNEON)
    brd.point.loc <- def.extr.geo.os(brd.point)
    
    symbols(brd.point.loc$easting, brd.point.loc$northing, 
            circles=brd.point.loc$uncorr.coordinateUncertainty, 
            xlab="Easting", ylab="Northing", tck=0.01, inches=F)

    ## Error in symbols(brd.point.loc$easting, brd.point.loc$northing, circles = brd.point.loc$uncorr.coordinateUncertainty, : invalid symbol parameter vector

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-API//NEON-API-How-To/brd-extr-NL-1.png)

And use `def.calc.geo.os()` to calculate the point locations of 
observations:


    brd.point.pt <- def.calc.geo.os(brd.point, "brd_perpoint")
    
    symbols(brd.point.pt$easting, brd.point.pt$northing, 
            circles=brd.point.pt$coordinateUncertainty, 
            xlab="Easting", ylab="Northing", tck=0.01, inches=F)

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-API//NEON-API-How-To/brd-calc-NL-1.png)


## Coming soon
At the top of this tutorial, we installed the `neonDataStackR` package. 
This is a custom R package that stacks the monthly files provided by 
the NEON data portal into a single continuous file for each type of 
data table in the download. It currently handles files downloaded from 
the data portal, but not files pulled from the API. That functionality 
will be added soon!

For a guide to using `neonDataStackR` on data downloaded from the portal, 
look <a href="{{ site.baseurl }}/neonDataStackR" target="_blank">here</a>.



