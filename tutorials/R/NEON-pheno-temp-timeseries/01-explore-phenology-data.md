---
syncID: 57a6e5db49494a4b82f9c1bdeec70e81
title: "Work With NEON's Plant Phenology Data"
description: "Learn to work with NEON plant phenology observation data (NEON.DP1.10055)."
dateCreated: 2017-08-01
authors: Megan A. Jones, Natalie Robinson, Lee Stanish
contributors: Katie Jones, Cody Flagg
estimatedTime: 
packagesLibraries: dplyr, ggplot2
topics: time-series, phenology, organisms
languagesTool: R
dataProduct: NEON.DP1.10055
code1: R/NEON-pheno-temp-timeseries/01-explore-phenology-data.R
tutorialSeries: neon-pheno-temp-series
urlTitle: neon-plant-pheno-data-r
---


Many organisms, including plants, show patterns of change across seasons - 
the different stages of this observable change are called phenophases. In this 
tutorial we explore how to work with NEON plant phenophase data. 



<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:

 * work with "stacked" NEON Plant Phenology Observation data. 
 * correctly format date data. 
 * use dplyr functions to filter data.
 * plot time series data in a bar plot using ggplot the function. 

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages

* **ggplot2:** `install.packages("ggplot2")`
* **dplyr:** `install.packages("dplyr")`



<a href="/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Download Data 

{% include/dataSubsets/_data_NEON-pheno-temp-timeseries.html %}

****
{% include/_greyBox-wd-rscript.html %}

****

## Additional Resources

* NEON <a href="http://data.neonscience.org" target="_blank"> data portal </a>
* NEON Plant Phenology Observations <a href="http://data.neonscience.org/api/v0/documents/NEON_phenology_userGuide_vA" target="_blank"> data product user guide</a>
* RStudio's <a href="https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf" target="_blank"> data wrangling (dplyr/tidyr) cheatsheet</a>
* <a href="https://github.com/NEONScience" target="_blank">NEONScience GitHub Organization</a>
* <a href="https://cran.r-project.org/web/packages/nneo/index.html" target="_blank">nneo R package -- an API wrapper -- on CRAN </a>

</div>

Plants change throughout the year - these are phenophases. 
Why do they change? 

## Explore Phenology Data 

The following sections provide a brief overview of the NEON plant phenology 
observation data. When designing a research project using this data, you 
need to consult the 
<a href="http://data.neonscience.org/data-product-view?dpCode=DP1.10055.001" target="_blank">documents associated with this data product</a> and not rely soley on this summary. 

*The following description of the NEON Plant Phenology Observation data is modified 
from the <a href="http://data.neonscience.org/api/v0/documents/NEON_phenology_userGuide_vA" target="_blank"> data product user guide</a>.*

### NEON Plant Phenology Observation Data

NEON collects plant phenology data and provides it as NEON data product 
**NEON.DP1.10055**.

The plant phenology observations data product provides in-situ observations of 
the phenological status and intensity of tagged plants (or patches) during 
discrete observations events. 

Sampling occurs at all terrestrial field sites at site and season specific 
intervals. Three species for phenology observation are selected based on relative 
abundance in the Tower airshed. There are 30 individuals of each target species 
monitored at each transect. 

#### Status-based Monitoring

NEON employs status-based monitoring, in which the phenological condition of an 
individual is reported any time that individual is observed. At every observations 
bout, records are generated for every phenophase that is occurring and for every 
phenophase not occurring. With this approach, events (such as leaf emergence in 
Mediterranean climates, or flowering in many desert species) that may occur 
multiple times during a single year, can be captured. Continuous reporting of
phenophase status enables quantification of the duration of phenophases rather 
than just their date of onset while allows enabling the explicit quantification 
of uncertainty in phenophase transition dates that are introduced by monitoring 
in discrete temporal bouts.

Specific products derived from this sampling include the observed phenophase 
status (whether or not a phenophase is occurring) and the intensity of 
phenophases for individuals in which phenophase status = ‘yes’. Phenophases 
reported are derived from the USA National Phenology Network (USA-NPN) categories. 
The number of phenophases observed varies by growth form and ranges from 1 
phenophase (cactus) to 7 phenophases (semi-evergreen broadleaf). 
In this tutorial we will focus only on the state of the phenophase, not the 
phenophase intensity data. 

#### Phenology Transects 

Plant phenology observations occurs at all terrestrial NEON sites along an 800 
meter square loop transect (primary) and within a 200 m x 200 m plot located 
within view of a canopy level, tower-mounted, phenology camera.

 <figure>
	<a href="{{ site.baseurl }}/images/NEON-pheno-temp-timeseries/NEONphenoTransect.png">
	<img src="{{ site.baseurl }}/images/NEON-pheno-temp-timeseries/NEONphenoTransect.png"></a>
	<figcaption> Diagram of a phenology transect layout, with meter layout marked.
	Point-level geolocations are recorded at eight referecne points along the 
	perimeter, plot-level geolaocation at the plot centoid (star). 
	Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>

#### Timing of Observations

At each site, there are: 

* ~50 observation bouts per year. 
* no more that 100 sampling points per phenology transect.
* no more than 9 sampling points per phenocam plot. 
* 1 bout per year to collect annual size and disease status measurements from 
each sampling point.


#### Available Data Tables

In the downloaded data packet, data are available in two main files

* **phe_statusintensity:** Plant phenophase status and intensity data 
* **phe_perindividual:** Geolocation and taxonomic identification for phenology plants
* **phe_perindividualperyear:** recorded once a year, essentially the "metadata" 
about the plant: DBH, height, etc. 


There are other files in each download including a **readme** with information on 
the data product and the download; a **variables** file that defines the 
term descriptions, data types, and units; a **validation** file with ata entry validation and 
parsing rules; and an **XML** with machine readable metadata. 

## Stack NEON Data

NEON data are delivered in a site and year-month format. When you download data,
you will get a single zipped file containing a directory for each month and site that you've 
requested data for. Dealing with these seperate tables from even one or two sites
over a 12 month period can be a bit overwhelming. Luckily NEON provides an R package
**neonUtilities** that takes the unzipped downloaded file and joining the data 
files. 

When we do this for phenology data we get three files, one for each data table, 
with all the data from your site and date range of interest. 

Let's start by loading our data of interest. 



    library(dplyr)
    library(ggplot2)
    library(lubridate)  
    
    
    # set working directory to ensure R can find the file we wish to import
    # setwd("working-dir-path-here")
    
    
    # Read in data
    ind <- read.csv('NEON-pheno-temp-timeseries/pheno/phe_perindividual.csv', 
    		stringsAsFactors = FALSE )
    
    status <- read.csv('NEON-pheno-temp-timeseries/pheno/phe_statusintensity.csv', 
    		stringsAsFactors = FALSE)

Let's explore the data. Let's get to know what the `ind` dataframe looks like.


    # What are the fieldnames in this dataset?
    names(ind)

    ##  [1] "uid"                         "namedLocation"              
    ##  [3] "domainID"                    "siteID"                     
    ##  [5] "plotID"                      "decimalLatitude"            
    ##  [7] "decimalLongitude"            "geodeticDatum"              
    ##  [9] "coordinateUncertainty"       "elevation"                  
    ## [11] "elevationUncertainty"        "subtypeSpecification"       
    ## [13] "transectMeter"               "directionFromTransect"      
    ## [15] "ninetyDegreeDistance"        "sampleLatitude"             
    ## [17] "sampleLongitude"             "sampleGeodeticDatum"        
    ## [19] "sampleCoordinateUncertainty" "sampleElevation"            
    ## [21] "sampleElevationUncertainty"  "addDate"                    
    ## [23] "editedDate"                  "individualID"               
    ## [25] "taxonID"                     "scientificName"             
    ## [27] "identificationQualifier"     "taxonRank"                  
    ## [29] "growthForm"                  "vstTag"                     
    ## [31] "samplingProtocolVersion"     "measuredBy"                 
    ## [33] "identifiedBy"                "recordedBy"                 
    ## [35] "remarks"                     "dataQF"

    # how many rows are in the data?
    nrow(ind)

    ## [1] 1802

    # look at the first six rows of data.
    head(ind)

    ##                                    uid          namedLocation domainID
    ## 1 16a2656d-7287-46b1-aad7-bd000ec5983f BLAN_061.phenology.phe      D02
    ## 2 35210426-a9f3-4e13-9073-7dfbff670703 BLAN_061.phenology.phe      D02
    ## 3 fff04a10-2c95-44f5-b0df-4a62033d634f BLAN_061.phenology.phe      D02
    ## 4 2d9de2e1-154b-4dd9-840d-2cf81fb77362 BLAN_061.phenology.phe      D02
    ## 5 a32bce80-eeb9-463e-ad40-0cf6fa43bafe BLAN_061.phenology.phe      D02
    ## 6 c1c5f91b-e073-430a-ba48-ee2eb19117a4 BLAN_061.phenology.phe      D02
    ##   siteID   plotID decimalLatitude decimalLongitude geodeticDatum
    ## 1   BLAN BLAN_061        39.05963        -78.07385            NA
    ## 2   BLAN BLAN_061        39.05963        -78.07385            NA
    ## 3   BLAN BLAN_061        39.05963        -78.07385            NA
    ## 4   BLAN BLAN_061        39.05963        -78.07385            NA
    ## 5   BLAN BLAN_061        39.05963        -78.07385            NA
    ## 6   BLAN BLAN_061        39.05963        -78.07385            NA
    ##   coordinateUncertainty elevation elevationUncertainty
    ## 1                    NA       183                   NA
    ## 2                    NA       183                   NA
    ## 3                    NA       183                   NA
    ## 4                    NA       183                   NA
    ## 5                    NA       183                   NA
    ## 6                    NA       183                   NA
    ##   subtypeSpecification transectMeter directionFromTransect
    ## 1              primary           484                 Right
    ## 2              primary           506                 Right
    ## 3              primary           484                 Right
    ## 4              primary           476                  Left
    ## 5              primary           498                 Right
    ## 6              primary           469                  Left
    ##   ninetyDegreeDistance sampleLatitude sampleLongitude sampleGeodeticDatum
    ## 1                  0.5             NA              NA               WGS84
    ## 2                  1.0             NA              NA               WGS84
    ## 3                  2.0             NA              NA               WGS84
    ## 4                  2.0             NA              NA               WGS84
    ## 5                  2.0             NA              NA               WGS84
    ## 6                  2.0             NA              NA               WGS84
    ##   sampleCoordinateUncertainty sampleElevation sampleElevationUncertainty
    ## 1                          NA              NA                         NA
    ## 2                          NA              NA                         NA
    ## 3                          NA              NA                         NA
    ## 4                          NA              NA                         NA
    ## 5                          NA              NA                         NA
    ## 6                          NA              NA                         NA
    ##      addDate editedDate            individualID taxonID
    ## 1 2015-06-25 2015-07-22 NEON.PLA.D02.BLAN.06295    RHDA
    ## 2 2015-06-25 2015-07-22 NEON.PLA.D02.BLAN.06286   LOMA6
    ## 3 2015-06-25 2015-07-22 NEON.PLA.D02.BLAN.06299   LOMA6
    ## 4 2015-06-25 2015-07-22 NEON.PLA.D02.BLAN.06300    RHDA
    ## 5 2015-06-25 2015-07-22 NEON.PLA.D02.BLAN.06288   LOMA6
    ## 6 2015-06-25 2015-07-22 NEON.PLA.D02.BLAN.06297    RHDA
    ##                    scientificName identificationQualifier taxonRank
    ## 1          Rhamnus davurica Pall.                           species
    ## 2 Lonicera maackii (Rupr.) Herder                           species
    ## 3 Lonicera maackii (Rupr.) Herder                           species
    ## 4          Rhamnus davurica Pall.                           species
    ## 5 Lonicera maackii (Rupr.) Herder                           species
    ## 6          Rhamnus davurica Pall.                           species
    ##            growthForm vstTag samplingProtocolVersion
    ## 1 Deciduous broadleaf     NA                      NA
    ## 2 Deciduous broadleaf     NA                      NA
    ## 3 Deciduous broadleaf     NA                      NA
    ## 4 Deciduous broadleaf     NA                      NA
    ## 5 Deciduous broadleaf     NA                      NA
    ## 6 Deciduous broadleaf     NA                      NA
    ##                         measuredBy                     identifiedBy
    ## 1 cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd
    ## 2 cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd
    ## 3 cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd
    ## 4 cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd
    ## 5 cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd
    ## 6 cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd
    ##                         recordedBy remarks dataQF
    ## 1 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd             NA
    ## 2 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd             NA
    ## 3 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd             NA
    ## 4 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd             NA
    ## 5 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd             NA
    ## 6 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd             NA

    # look at the structure of the dataframe.
    str(ind)

    ## 'data.frame':	1802 obs. of  36 variables:
    ##  $ uid                        : chr  "16a2656d-7287-46b1-aad7-bd000ec5983f" "35210426-a9f3-4e13-9073-7dfbff670703" "fff04a10-2c95-44f5-b0df-4a62033d634f" "2d9de2e1-154b-4dd9-840d-2cf81fb77362" ...
    ##  $ namedLocation              : chr  "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" ...
    ##  $ domainID                   : chr  "D02" "D02" "D02" "D02" ...
    ##  $ siteID                     : chr  "BLAN" "BLAN" "BLAN" "BLAN" ...
    ##  $ plotID                     : chr  "BLAN_061" "BLAN_061" "BLAN_061" "BLAN_061" ...
    ##  $ decimalLatitude            : num  39.1 39.1 39.1 39.1 39.1 ...
    ##  $ decimalLongitude           : num  -78.1 -78.1 -78.1 -78.1 -78.1 ...
    ##  $ geodeticDatum              : logi  NA NA NA NA NA NA ...
    ##  $ coordinateUncertainty      : logi  NA NA NA NA NA NA ...
    ##  $ elevation                  : num  183 183 183 183 183 183 183 183 183 183 ...
    ##  $ elevationUncertainty       : logi  NA NA NA NA NA NA ...
    ##  $ subtypeSpecification       : chr  "primary" "primary" "primary" "primary" ...
    ##  $ transectMeter              : num  484 506 484 476 498 469 497 491 504 491 ...
    ##  $ directionFromTransect      : chr  "Right" "Right" "Right" "Left" ...
    ##  $ ninetyDegreeDistance       : num  0.5 1 2 2 2 2 1 0.5 0.5 0.5 ...
    ##  $ sampleLatitude             : logi  NA NA NA NA NA NA ...
    ##  $ sampleLongitude            : logi  NA NA NA NA NA NA ...
    ##  $ sampleGeodeticDatum        : chr  "WGS84" "WGS84" "WGS84" "WGS84" ...
    ##  $ sampleCoordinateUncertainty: logi  NA NA NA NA NA NA ...
    ##  $ sampleElevation            : logi  NA NA NA NA NA NA ...
    ##  $ sampleElevationUncertainty : logi  NA NA NA NA NA NA ...
    ##  $ addDate                    : chr  "2015-06-25" "2015-06-25" "2015-06-25" "2015-06-25" ...
    ##  $ editedDate                 : chr  "2015-07-22" "2015-07-22" "2015-07-22" "2015-07-22" ...
    ##  $ individualID               : chr  "NEON.PLA.D02.BLAN.06295" "NEON.PLA.D02.BLAN.06286" "NEON.PLA.D02.BLAN.06299" "NEON.PLA.D02.BLAN.06300" ...
    ##  $ taxonID                    : chr  "RHDA" "LOMA6" "LOMA6" "RHDA" ...
    ##  $ scientificName             : chr  "Rhamnus davurica Pall." "Lonicera maackii (Rupr.) Herder" "Lonicera maackii (Rupr.) Herder" "Rhamnus davurica Pall." ...
    ##  $ identificationQualifier    : chr  "" "" "" "" ...
    ##  $ taxonRank                  : chr  "species" "species" "species" "species" ...
    ##  $ growthForm                 : chr  "Deciduous broadleaf" "Deciduous broadleaf" "Deciduous broadleaf" "Deciduous broadleaf" ...
    ##  $ vstTag                     : logi  NA NA NA NA NA NA ...
    ##  $ samplingProtocolVersion    : logi  NA NA NA NA NA NA ...
    ##  $ measuredBy                 : chr  "cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m" "cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m" "cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m" "cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m" ...
    ##  $ identifiedBy               : chr  "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" ...
    ##  $ recordedBy                 : chr  "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" ...
    ##  $ remarks                    : chr  "" "" "" "" ...
    ##  $ dataQF                     : logi  NA NA NA NA NA NA ...

Note that if you first open you data file in Excel, you might see 06/14/2014 as 
the format instead of 2014-06-14. Excel can do some ~~wierd~~ interesting things
to dates.

#### Individual locations

To get the specific location data of each individual you would need to do some 
math, or you can use the NEON geolocation 
<a href="https://github.com/NEONScience/NEON-geolocation" target="_blank"> **geoNEON**</a>. 

Now let's look at the status data. 


    # What variables are included in this dataset?
    names(status)

    ##  [1] "uid"                           "namedLocation"                
    ##  [3] "domainID"                      "siteID"                       
    ##  [5] "plotID"                        "date"                         
    ##  [7] "editedDate"                    "dayOfYear"                    
    ##  [9] "individualID"                  "taxonID"                      
    ## [11] "scientificName"                "growthForm"                   
    ## [13] "phenophaseName"                "phenophaseStatus"             
    ## [15] "phenophaseIntensityDefinition" "phenophaseIntensity"          
    ## [17] "samplingProtocolVersion"       "measuredBy"                   
    ## [19] "recordedBy"                    "remarks"                      
    ## [21] "dataQF"

    nrow(status)

    ## [1] 87292

    head(status)

    ##                                    uid          namedLocation domainID
    ## 1 d63aa5ff-c31d-425f-99b8-6d2fc890f51a BLAN_061.phenology.phe      D02
    ## 2 2c4a0bb9-e942-48fe-bd52-dacd3bc4be74 BLAN_061.phenology.phe      D02
    ## 3 3146c7ef-46a5-4c2f-8ba6-69a700142512 BLAN_061.phenology.phe      D02
    ## 4 c3555684-c2e6-46a2-9290-a3e8524fa4a2 BLAN_061.phenology.phe      D02
    ## 5 4a28f1e3-b14a-4982-9bde-b609ebd51915 BLAN_061.phenology.phe      D02
    ## 6 2c6f4463-6122-431d-8ae6-f9f6e2058965 BLAN_061.phenology.phe      D02
    ##   siteID   plotID       date editedDate dayOfYear            individualID
    ## 1   BLAN BLAN_061 2015-06-25 2015-07-22        NA NEON.PLA.D02.BLAN.06286
    ## 2   BLAN BLAN_061 2015-06-25 2015-07-22        NA NEON.PLA.D02.BLAN.06290
    ## 3   BLAN BLAN_061 2015-06-25 2015-07-22        NA NEON.PLA.D02.BLAN.06291
    ## 4   BLAN BLAN_061 2015-06-25 2015-07-22        NA NEON.PLA.D02.BLAN.06288
    ## 5   BLAN BLAN_061 2015-06-25 2015-07-22        NA NEON.PLA.D02.BLAN.06286
    ## 6   BLAN BLAN_061 2015-06-25 2015-07-22        NA NEON.PLA.D02.BLAN.06300
    ##   taxonID scientificName          growthForm       phenophaseName
    ## 1      NA             NA Deciduous broadleaf         Open flowers
    ## 2      NA             NA Deciduous broadleaf Increasing leaf size
    ## 3      NA             NA Deciduous broadleaf Increasing leaf size
    ## 4      NA             NA Deciduous broadleaf         Open flowers
    ## 5      NA             NA Deciduous broadleaf Increasing leaf size
    ## 6      NA             NA Deciduous broadleaf       Colored leaves
    ##   phenophaseStatus phenophaseIntensityDefinition phenophaseIntensity
    ## 1               no                                                  
    ## 2               no                                                  
    ## 3               no                                                  
    ## 4               no                                                  
    ## 5               no                                                  
    ## 6               no                                                  
    ##   samplingProtocolVersion                       measuredBy
    ## 1                      NA cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m
    ## 2                      NA cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m
    ## 3                      NA cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m
    ## 4                      NA cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m
    ## 5                      NA cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m
    ## 6                      NA cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m
    ##                         recordedBy remarks dataQF
    ## 1 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd    <NA>     NA
    ## 2 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd    <NA>     NA
    ## 3 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd    <NA>     NA
    ## 4 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd    <NA>     NA
    ## 5 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd    <NA>     NA
    ## 6 UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd    <NA>     NA

    str(status)

    ## 'data.frame':	87292 obs. of  21 variables:
    ##  $ uid                          : chr  "d63aa5ff-c31d-425f-99b8-6d2fc890f51a" "2c4a0bb9-e942-48fe-bd52-dacd3bc4be74" "3146c7ef-46a5-4c2f-8ba6-69a700142512" "c3555684-c2e6-46a2-9290-a3e8524fa4a2" ...
    ##  $ namedLocation                : chr  "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" ...
    ##  $ domainID                     : chr  "D02" "D02" "D02" "D02" ...
    ##  $ siteID                       : chr  "BLAN" "BLAN" "BLAN" "BLAN" ...
    ##  $ plotID                       : chr  "BLAN_061" "BLAN_061" "BLAN_061" "BLAN_061" ...
    ##  $ date                         : chr  "2015-06-25" "2015-06-25" "2015-06-25" "2015-06-25" ...
    ##  $ editedDate                   : chr  "2015-07-22" "2015-07-22" "2015-07-22" "2015-07-22" ...
    ##  $ dayOfYear                    : logi  NA NA NA NA NA NA ...
    ##  $ individualID                 : chr  "NEON.PLA.D02.BLAN.06286" "NEON.PLA.D02.BLAN.06290" "NEON.PLA.D02.BLAN.06291" "NEON.PLA.D02.BLAN.06288" ...
    ##  $ taxonID                      : logi  NA NA NA NA NA NA ...
    ##  $ scientificName               : logi  NA NA NA NA NA NA ...
    ##  $ growthForm                   : chr  "Deciduous broadleaf" "Deciduous broadleaf" "Deciduous broadleaf" "Deciduous broadleaf" ...
    ##  $ phenophaseName               : chr  "Open flowers" "Increasing leaf size" "Increasing leaf size" "Open flowers" ...
    ##  $ phenophaseStatus             : chr  "no" "no" "no" "no" ...
    ##  $ phenophaseIntensityDefinition: chr  "" "" "" "" ...
    ##  $ phenophaseIntensity          : chr  "" "" "" "" ...
    ##  $ samplingProtocolVersion      : logi  NA NA NA NA NA NA ...
    ##  $ measuredBy                   : chr  "cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m" "cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m" "cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m" "cVPbPdjHNiEVZ3Vlm83FuXHus5z3id4m" ...
    ##  $ recordedBy                   : chr  "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" "UPKVQ90CmewX9vOGBMiPV2gMtRUi+WUd" ...
    ##  $ remarks                      : chr  NA NA NA NA ...
    ##  $ dataQF                       : logi  NA NA NA NA NA NA ...

    # date range
    min(status$date)

    ## [1] "2015-06-03"

    max(status$date)

    ## [1] "2016-12-05"

The `uid` is not important to understanding the data so we are going to remove `uid`. 
However, if you are every reporting an error in the data you should include this
with your report. 


    ind <- select(ind,-uid)
    status <- select (status, -uid)

## Clean up the Data

* remove duplicates (full rows)
* convert date
* retain only the latest `editedDate` in the perIndividual table.

### Remove Duplicates

The indivdual table (ind) file is included in each site by month-year file. As 
a result when all the tables are stacked there are many duplicates. 

Let's remove any duplicates that exist.


    # remove duplicates
    ## expect many
    
    ind_noD <- distinct(ind)
    nrow(ind_noD)

    ## [1] 1557

    status_noD<-distinct(status)
    nrow(status_noD)

    ## [1] 85693


### Variable Overlap between Tables

From the initial inspection of the data we can see there is overlap in variable
names between the fields. 

Let's see what they are.


    # where is there an intersection of names
    sameName <- intersect(names(status_noD), names(ind_noD))
    sameName

    ##  [1] "namedLocation"           "domainID"               
    ##  [3] "siteID"                  "plotID"                 
    ##  [5] "editedDate"              "individualID"           
    ##  [7] "taxonID"                 "scientificName"         
    ##  [9] "growthForm"              "samplingProtocolVersion"
    ## [11] "measuredBy"              "recordedBy"             
    ## [13] "remarks"                 "dataQF"

There are several fields that overlap between the datasets. Some of these are
expected to be the same and will be what we join on. 

However, some of these will have different values in each table. We want to keep 
those distinct value and not join on them. 

We want to rename common fields before joining:

* editedDate
* measuredBy
* recordedBy
* samplingProtocolVersion
* remarks
* dataQF

Now we want to rename the variables that would have duplicate names. We can 
rename all the variables in the status object to have "Stat" at the end of the 
variable name. 


    # rename status editedDate
    status_noD <- rename(status_noD, editedDateStat=editedDate, 
    		measuredByStat=measuredBy, recordedByStat=recordedBy, 
    		samplingProtocolVersionStat=samplingProtocolVersion, 
    		remarksStat=remarks, dataQFStat=dataQF)


### Convert to Date

Our `addDate` and `date` columns are stored as a `character` class. We need to 
convert it to a date class. The `as.Date()` function in base R will do this. 


    # convert column to date class
    ind_noD$editedDate <- as.Date(ind_noD$editedDate)
    str(ind_noD$editedDate)

    ##  Date[1:1557], format: "2015-07-22" "2015-07-22" "2015-07-22" "2015-07-22" "2015-07-22" ...

    status_noD$date <- as.Date(status_noD$date)
    str(status_noD$date)

    ##  Date[1:85693], format: "2015-06-25" "2015-06-25" "2015-06-25" "2015-06-25" "2015-06-25" ...

The individual (ind) table contains all instances that any of the location or 
taxonomy data of an individual was updated. Therefore there are many rows for
some individuals.  We only want the latest `editedDate` on ind. 


    # retain only the max of the date for each individualID
    ind_last <- ind_noD %>%
    	group_by(individualID) %>%
    	filter(editedDate==max(editedDate))
    
    # oh wait, duplicate dates, retain only one
    ind_lastnoD <- ind_last %>%
    	group_by(editedDate, individualID) %>%
    	filter(row_number()==1)

### Join Dataframes

Now we can join the two data frames on all the variables with the same name. 
We use a `left_join()` from the dpylr package because we want to match all the 
rows from the "left" (first) dateframe to any rows that also occur in the "right"
 (second) dataframe.  
 
 Check out RStudio's 
 <a href="https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf" target="_blank"> data wrangling (dplyr/tidyr) cheatsheet</a>
 for other types of joins. 
 

    # Create a new dataframe "phe_ind" with all the data from status and some from ind_lastnoD
    phe_ind <- left_join(status_noD, ind_lastnoD)

    ## Joining, by = c("namedLocation", "domainID", "siteID", "plotID", "individualID", "taxonID", "scientificName", "growthForm")

    ## Error in left_join_impl(x, y, by$x, by$y, suffix$x, suffix$y, check_na_matches(na_matches)): Can't join on 'taxonID' x 'taxonID' because of incompatible types (character / logical)

Ack!  Two different data types.  Why?  NA in taxonID is a logicial, but all the 
names are character.  

Try it again.  

`taxonID` and `scientificName` are provided for convenience in Status table, but
most up to date data are always in the `phe_perindividual.csv` files. Therefore, 
we'll remove from the columns from the status data. (This is one more reason why you want to 
fully read the documents associated with the data products!).


    # drop taxonID, scientificName
    status_noD <- select (status_noD, -taxonID, -scientificName)
    
    # Create a new dataframe "phe_ind" with all the data from status and some from ind_lastnoD
    phe_ind <- left_join(status_noD, ind_lastnoD)

    ## Joining, by = c("namedLocation", "domainID", "siteID", "plotID", "individualID", "growthForm")

Worked this time! 
Now that we have clean datasets we can begin looking into our particular data to 
address our research question: do plants show patterns of changes in phenophase 
across season?

## Patterns in Phenophase  

From our larger dataset (several sites, species, phenophases), let's create a
dataframe with only the data from a single site, species, and phenophase and 
call it `phe_1sp`.

## Select Site(s) of Interest

To do this, we'll first select our site of interest. Note how we set this up 
with an object that is our site of interest. This will allow us to more easily change 
which site or sites if we want to adapt our code later. 


    # set site of interest
    siteOfInterest <- "SCBI"
    
    # use filter to select only the site of Interest 
    ## using %in% allows one to add a vector if you want more than one site. 
    ## could also do it with == instead of %in% but won't work with vectors
    
    phe_1sp <- filter(phe_ind, siteID %in% siteOfInterest)

## Select Species of Interest

And now select a single species of interest. For now let's choose the flowering 
tree *Liriodendron tulipifera* (LITU). 


    # see which species are present
    unique(phe_1sp$taxonID)

    ## [1] "JUNI" "MIVI" "LITU"

    speciesOfInterest <- "LITU"
    
    #subset to just "LITU"
    # here just use == but could also use %in%
    phe_1sp <- filter(phe_1sp, taxonID==speciesOfInterest)
    
    # check that it worked
    unique(phe_1sp$taxonID)

    ## [1] "LITU"


## Select Phenophase of Interest

And, perhaps a single phenophase. 


    # see which species are present
    unique(phe_1sp$phenophaseName)

    ## [1] "Colored leaves"       "Increasing leaf size" "Leaves"              
    ## [4] "Open flowers"         "Breaking leaf buds"   "Falling leaves"

    phenophaseOfInterest <- "Leaves"
    
    #subset to just the phenosphase of Interest 
    phe_1sp <- filter(phe_1sp, phenophaseName %in% phenophaseOfInterest)
    
    # check that it worked
    unique(phe_1sp$phenophaseName)

    ## [1] "Leaves"

## Total in Phenophase of Interest

The `phenophaseState` is recorded as "yes" or "no" that the individual is in that
phenophase. The `phenophaseIntensity` are categories for how much of the indvidual
is in that state. For now, we will stick with `phenophaseState`. 

We can now calculate the total indivdiual with that state. 

Here we use pipes `%>%` from the dpylr package to "pass" objects onto the next
function. 


    # Total in status by day
    sampSize <- count(phe_1sp, date)
    inStat <- phe_1sp %>%
    	group_by(date) %>%
      count(phenophaseStatus)
    inStat <- full_join(sampSize, inStat, by="date")
    
    # Retain only Yes
    inStat_T <- filter(inStat, phenophaseStatus %in% "yes")

Now that we have the data we can plot it. 

## Plot with ggplot

The `ggplot()` function within the `ggplot2` package gives us considerable control
over plot appearance. Three basic elements are needed for `ggplot()` to work:

 1. The **data_frame:** containing the variables that we wish to plot,
 2. **`aes` (aesthetics):** which denotes which variables will map to the x-, y-
 (and other) axes,  
 3. **`geom_XXXX` (geometry):** which defines the data's graphical representation
 (e.g. points (`geom_point`), bars (`geom_bar`), lines (`geom_line`), etc).
 
The syntax begins with the base statement that includes the `data_frame`
(`inStat_T`) and associated x (`date`) and y (`n`) variables to be
plotted:

`ggplot(inStat_T, aes(date, n))`

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** For a more detailed introduction to 
using `ggplot()`, visit 
<a href="/dc-time-series-plot-ggplot-r" target="_blank"> *Time Series 05: Plot Time Series with ggplot2 in R* tutorial</a>. 
</div>

### Bar Plots with ggplot
To successfully plot, the last piece that is needed is the `geom`etry type. 
To create a bar plot, we set the `geom` element from to `geom_bar()`.  

The default setting for a ggplot bar plot -  `geom_bar()` - is a histogram
designated by `stat="bin"`. However, in this case, we want to plot count values. 
We can use `geom_bar(stat="identity")` to force ggplot to plot actual values.


    # plot number of individuals in leaf
    phenoPlot <- ggplot(inStat_T, aes(date, n.y)) +
        geom_bar(stat="identity", na.rm = TRUE) 
    
    phenoPlot

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-pheno-temp-timeseries/01-explore-phenology-data/plot-leaves-total-1.png)

    # Now let's make the plot look a bit more presentable
    phenoPlot <- ggplot(inStat_T, aes(date, n.y)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Total Individuals in Leaf") +
        xlab("Date") + ylab("Number of Individuals") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))
    
    phenoPlot

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-pheno-temp-timeseries/01-explore-phenology-data/plot-leaves-total-2.png)

We could also covert this to percentage and plot that. 


    # convert to percent
    inStat_T$percent<- ((inStat_T$n.y)/inStat_T$n.x)*100
    
    # plot percent of leaves
    phenoPlot_P <- ggplot(inStat_T, aes(date, percent)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Proportion in Leaf") +
        xlab("Date") + ylab("% of Individuals") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))
    
    phenoPlot_P

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-pheno-temp-timeseries/01-explore-phenology-data/plot-leaves-percentage-1.png)

The plots demonstrate that, while the 2016 data show the nice expected pattern 
of increasing leaf-out, peak, and drop-off, we seem to be missing the increase 
in leaf-out in 2015. Looking at the data, we see that there was no data collected
before May of 2015 -- we're missing most of leaf out!

## Filter by Date

That may create problems with downstream analyses. Let's filter the dataset to 
include just 2016.


    # use filter to select only the site of Interest 
    phe_1sp_2016 <- filter(inStat_T, date >= "2016-01-01")
    
    # did it work?
    range(phe_1sp_2016$date)

    ## [1] "2016-03-21" "2016-11-23"

How does that look? 


    # Now let's make the plot look a bit more presentable
    phenoPlot16 <- ggplot(phe_1sp_2016, aes(date, n.y)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Total Individuals in Leaf") +
        xlab("Date") + ylab("Number of Individuals") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))
    
    phenoPlot16

![ ]({{ site.baseurl }}/images/rfigs/R/NEON-pheno-temp-timeseries/01-explore-phenology-data/plot-2016-1.png)


## Drivers of Phenology

Now that we see that there are differences in and shifts in phenophases, what 
are the drivers of phenophases?

The NEON phenology measurements track sensitive and easily observed indicators 
of biotic responses to climate variability by monitoring the timing and duration 
of phenological stagesin plant communities. Plant phenology is affected by forces 
such as temperature, timing and duration of pest infestations and disease outbreaks, 
water fluxes, nutrient budgets, carbon dynamics, and food availability and has 
feedbacks to trophic interactions, carbon sequestration, community composition 
and ecosystem function.  (quoted from 
<a href="http://data.neonscience.org/api/v0/documents/NEON_phenology_userGuide_vA" target="_blank"> Plant Phenology Observations user guide</a>.)


