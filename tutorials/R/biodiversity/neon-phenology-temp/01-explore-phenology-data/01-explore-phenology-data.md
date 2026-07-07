---
syncID: 57a6e5db49494a4b82f9c1bdeec70e81
title: "Work With NEON's Plant Phenology Data"
description: "Learn to work with NEON plant phenology observation data (DP1.10055.001)."
dateCreated: 2017-08-01
authors: Megan A. Jones, Natalie Robinson, Lee Stanish
contributors: Katie Jones, Cody Flagg, Karlee Bradley, Felipe Sanchez
estimatedTime: 1 hour
packagesLibraries: dplyr, ggplot2
topics: time-series, phenology, organisms
languagesTool: R
dataProduct: DP1.10055.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/biodiversity/neon-phenology-temp/01-explore-phenology-data/01-explore-phenology-data.R
tutorialSeries: neon-pheno-temp-series
urlTitle: neon-plant-pheno-data-r
---

Many organisms, including plants, show patterns of change across seasons - 
the different stages of this observable change are called phenophases. In this 
tutorial we explore how to work with NEON plant phenophase data. 

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:

 * work with NEON Plant Phenology Observation data. 
 * use dplyr functions to filter data.
 * plot time series data in a bar plot using ggplot the function. 

## Things You’ll Need To Complete This Tutorial
* You will need a current version of R (4+) and, preferably, `RStudio` loaded
on your computer to complete this tutorial.
* Create a <a href="https://www.neonscience.org/about/user-accounts" target="_blank">NEON user account</a>
* Generate an <a href="https://www.neonscience.org/resources/learning-hub/tutorials/api-token-setup" target="_blank">API token</a> for downloading data

### Install R Packages

* **neonUtilities:** `install.packages("neonUtilities")`
* **neonOS** `install.packages("neonOS")`
* **ggplot2:** `install.packages("ggplot2")`
* **dplyr:** `install.packages("dplyr")`

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

****

## Additional Resources

* NEON <a href="http://data.neonscience.org" target="_blank"> data portal </a>
* NEON Plant Phenology Observations <a href="http://data.neonscience.org/api/v0/documents/NEON_phenology_userGuide_vA" target="_blank"> data product user guide</a>
* RStudio's <a href="https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf" target="_blank"> data wrangling (dplyr/tidyr) cheatsheet</a>
* <a href="https://github.com/NEONScience" target="_blank">NEONScience GitHub Organization</a>
* <a href="https://cran.r-project.org/web/packages/nneo/index.html" target="_blank">nneo API wrapper on CRAN </a>

</div>

Plants change throughout the year - these are phenophases. 
Why do they change? 

## Explore Phenology Data 

The following sections provide a brief overview of the NEON plant phenology 
observation data. When designing a research project using this data, you 
need to consult the 
<a href="http://data.neonscience.org/data-products/DP1.10055.001" target="_blank">documents associated with this data product</a> and not rely solely on this summary. 

*The following description of the NEON Plant Phenology Observation data is modified 
from the <a href="http://data.neonscience.org/api/v0/documents/NEON_phenology_userGuide_vA" target="_blank"> data product user guide</a>.*

### NEON Plant Phenology Observation Data

NEON collects plant phenology data and provides it as NEON data product 
**DP1.10055.001**.

The plant phenology observations data product provides in-situ observations of 
the phenological status and intensity of tagged plants (or patches) during 
discrete observations events. 

Sampling occurs at all terrestrial field sites at site and season specific 
intervals. During Phase I (dominant species) sampling (pre-2021), three species 
with 30 individuals each are sampled. In 2021, Phase II (community) sampling 
will begin, with <=20 species with 5 or more individuals sampled will occur.

#### Status-based Monitoring

NEON employs status-based monitoring, in which the phenological condition of an 
individual is reported any time that individual is observed. At every observations 
bout, records are generated for every phenophase that is occurring and for every 
phenophase not occurring. With this approach, events (such as leaf emergence in 
Mediterranean zones, or flowering in many desert species) that may occur 
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

Plant phenology observations occur at all terrestrial NEON sites along an 800 
meter square loop transect (primary) and within a 200 m x 200 m plot located 
within view of a canopy level, tower-mounted, phenology camera.

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/neon-organisms/NEONphenoTransect.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/neon-organisms/NEONphenoTransect.png"
	alt="Diagram of a phenology transect layout, with meter layout marked. Point-level geolocations are recorded at eight reference
	points along the perimeter; plot-level geolocation at the plot centroid(star).">
	</a>
	<figcaption> Diagram of a phenology transect layout, with meter layout marked.
	Point-level geolocations are recorded at eight reference points along the 
	perimeter, plot-level geolocation at the plot centroid (star). 
	Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>

#### Timing of Observations

At each site, there are: 

* ~50 observation bouts per year. 
* no more that 100 sampling points per phenology transect.
* no more than 9 sampling points per phenocam plot. 
* 1 annual measurement per year to collect annual size and disease status measurements from 
each sampling point.


#### Available Data Tables

The phenology dataset contains three data tables:

* **phe_statusintensity:** Plant phenophase status and intensity data 
* **phe_perindividual:** Geolocation and taxonomic identification for phenology plants
* **phe_perindividualperyear:** Pecorded once per year, essentially the "metadata" about the plant: DBH, height, etc. 


There are other files in each download including a **readme** with information on 
the data product and the download; a **variables** file that defines the 
term descriptions, data types, and units; a **validation** file with data entry 
validation and parsing rules; and a **citation** file giving the BibTeX citation 
for the downloaded data. 

## Set up R environment

This tutorial is designed to have you download data from the NEON
API using the `neonUtilities` package. As of June 2026, NEON requires an API token 
for data downloads, to reduce bot scraping and improve user support. Tokens can 
be generated in NEON data portal user accounts - log in to your account or 
create one, and go to the API Tokens section. For best practices in storing and 
using tokens, follow the instructions <a href="https://www.neonscience.org/resources/learning-hub/tutorials/api-token-setup" target="_blank">here</a>.

Install and load packages, and load your token. This code assumes you have 
stored your token as an environment variable, as described at the link above. 
If your token is stored in a different way, modify the line of code below as 
needed.


    # install needed package (only uncomment & run if not already installed)

    #install.packages("neonUtilities")

    #install.packages("dplyr")

    #install.packages("ggplot2")

    

    # load needed packages

    library(neonUtilities)

    library(neonOS)

    library(dplyr)

    library(ggplot2)

    token <- Sys.getenv("NEON_TOKEN")

    

    # set working directory to ensure R can find the file we wish to import and where

    # we want to save our files. Be sure to move the download into your working directory!

    wd <- "~/data" # Change this to match your local environment

    setwd(wd)

Let's start by loading our data of interest. For this series, we'll work with 
data from the NEON Domain 02 sites:

* Blandy Farm (BLAN)
* Smithsonian Conservation Biology Institute (SCBI)
* Smithsonian Environmental Research Center (SERC)

And we'll use data from January 2017 to December 2019. This downloads over 9MB
of data. If this is too large, use a smaller date range. If you opt to do this, 
your figures and some output may look different later in the tutorial. 

With this information, we can download our data using the `neonUtilities` package. 


    phe <- loadByProduct(dpID = "DP1.10055.001", 
                         site=c("BLAN","SCBI","SERC"), 
    										 startdate = "2017-01", 
    										 enddate="2019-12", 
    										 release="RELEASE-2026",
    										 token=token,
    										 check.size = F) 

    

    # save dataframes from the downloaded list

    ind <- phe$phe_perindividual  #individual information

    status <- phe$phe_statusintensity  #status & intensity info


Let's explore the data. Let's get to know what the `ind` dataframe looks like.


    # What are the fieldnames in this dataset?

    names(ind)

    ##  [1] "uid"                         "namedLocation"               "domainID"                    "siteID"                     
    ##  [5] "plotID"                      "decimalLatitude"             "decimalLongitude"            "geodeticDatum"              
    ##  [9] "coordinateUncertainty"       "elevation"                   "elevationUncertainty"        "subtypeSpecification"       
    ## [13] "transectMeter"               "directionFromTransect"       "ninetyDegreeDistance"        "sampleLatitude"             
    ## [17] "sampleLongitude"             "sampleCoordinateUncertainty" "sampleElevation"             "sampleElevationUncertainty" 
    ## [21] "date"                        "editedDate"                  "individualID"                "taxonID"                    
    ## [25] "scientificName"              "identificationQualifier"     "taxonRank"                   "nativeStatusCode"           
    ## [29] "identificationHistoryID"     "growthForm"                  "vstTag"                      "measuredBy"                 
    ## [33] "identifiedBy"                "recordedBy"                  "remarks"                     "dataQF"                     
    ## [37] "publicationDate"             "release"

    # Unsure of what some of the variables are? Look at the variables table!

    View(phe$variables_10055)

    

    # how many rows are in the data?

    nrow(ind)

    ## [1] 791

    # look at the first six rows of data.

    head(ind)

    ##                                    uid          namedLocation domainID siteID   plotID decimalLatitude decimalLongitude
    ## 1 c1949cda-a607-4f9c-b866-3c77c1c47856 BLAN_061.phenology.phe      D02   BLAN BLAN_061        39.05963        -78.07385
    ## 2 4871339b-5815-43e1-b0ee-2f0491b28be7 BLAN_061.phenology.phe      D02   BLAN BLAN_061        39.05963        -78.07385
    ## 3 9f170c36-214b-49e9-9571-84475b10c37a BLAN_061.phenology.phe      D02   BLAN BLAN_061        39.05963        -78.07385
    ## 4 2c8bb258-91f3-444b-85e0-6a589bd5fb6a BLAN_061.phenology.phe      D02   BLAN BLAN_061        39.05963        -78.07385
    ## 5 76afbf22-34f0-4e73-979a-4daeac316ab3 BLAN_061.phenology.phe      D02   BLAN BLAN_061        39.05963        -78.07385
    ## 6 fc3cfb08-d6df-4112-ae08-6f2ad3544cd2 BLAN_061.phenology.phe      D02   BLAN BLAN_061        39.05963        -78.07385
    ##   geodeticDatum coordinateUncertainty elevation elevationUncertainty subtypeSpecification transectMeter
    ## 1         WGS84                    NA       183                   NA              primary           491
    ## 2         WGS84                    NA       183                   NA              primary           139
    ## 3         WGS84                    NA       183                   NA              primary           575
    ## 4         WGS84                    NA       183                   NA              primary           501
    ## 5         WGS84                    NA       183                   NA              primary           632
    ## 6         WGS84                    NA       183                   NA              primary           657
    ##   directionFromTransect ninetyDegreeDistance sampleLatitude sampleLongitude sampleCoordinateUncertainty sampleElevation
    ## 1                  Left                  0.5             NA              NA                          NA              NA
    ## 2                  Left                  2.0             NA              NA                          NA              NA
    ## 3                 Right                  2.0             NA              NA                          NA              NA
    ## 4                 Right                  3.0             NA              NA                          NA              NA
    ## 5                  Left                  3.0             NA              NA                          NA              NA
    ## 6                  Left                  2.0             NA              NA                          NA              NA
    ##   sampleElevationUncertainty       date editedDate            individualID taxonID         scientificName
    ## 1                         NA 2016-04-20 2016-05-09 NEON.PLA.D02.BLAN.06290    RHDA Rhamnus davurica Pall.
    ## 2                         NA 2017-02-24 2021-07-13 NEON.PLA.D02.BLAN.06231    RHDA Rhamnus davurica Pall.
    ## 3                         NA 2017-02-24 2021-07-13 NEON.PLA.D02.BLAN.06208    RHDA Rhamnus davurica Pall.
    ## 4                         NA 2017-02-24 2021-07-13 NEON.PLA.D02.BLAN.06503   SOAL6  Solidago altissima L.
    ## 5                         NA 2017-02-24 2021-07-13 NEON.PLA.D02.BLAN.06508   SOAL6  Solidago altissima L.
    ## 6                         NA 2017-02-24 2021-07-13 NEON.PLA.D02.BLAN.06214    RHDA Rhamnus davurica Pall.
    ##   identificationQualifier taxonRank nativeStatusCode identificationHistoryID          growthForm vstTag
    ## 1                    <NA>   species                I                    <NA> Deciduous broadleaf      N
    ## 2                    <NA>   species                I                    <NA> Deciduous broadleaf      N
    ## 3                    <NA>   species                I                    <NA> Deciduous broadleaf      N
    ## 4                    <NA>   species                N                    <NA>                Forb      N
    ## 5                    <NA>   species                N                    <NA>                Forb      N
    ## 6                    <NA>   species                I                    <NA> Deciduous broadleaf      N
    ##                     measuredBy          identifiedBy           recordedBy
    ## 1          jcoloso@neoninc.org  shackley@neoninc.org shackley@neoninc.org
    ## 2 mastersb@battelleecology.org llemmon@field-ops.org                 <NA>
    ## 3 mastersb@battelleecology.org llemmon@field-ops.org                 <NA>
    ## 4 mastersb@battelleecology.org llemmon@field-ops.org                 <NA>
    ## 5 mastersb@battelleecology.org llemmon@field-ops.org                 <NA>
    ## 6 mastersb@battelleecology.org llemmon@field-ops.org                 <NA>
    ##                                                                remarks dataQF  publicationDate      release
    ## 1                                               Nearly dead shaded out   <NA> 20251222T234455Z RELEASE-2026
    ## 2                                                                 <NA>   <NA> 20251222T234455Z RELEASE-2026
    ## 3                                                                 <NA>   <NA> 20251222T234455Z RELEASE-2026
    ## 4 Dropped 20190717 no individuals present had been small and unhealthy   <NA> 20251222T234455Z RELEASE-2026
    ## 5                                                                 <NA>   <NA> 20251222T234455Z RELEASE-2026
    ## 6                                                                 <NA>   <NA> 20251222T234455Z RELEASE-2026

    # look at the structure of the dataframe.

    str(ind)

    ## 'data.frame':	791 obs. of  38 variables:
    ##  $ uid                        : chr  "c1949cda-a607-4f9c-b866-3c77c1c47856" "4871339b-5815-43e1-b0ee-2f0491b28be7" "9f170c36-214b-49e9-9571-84475b10c37a" "2c8bb258-91f3-444b-85e0-6a589bd5fb6a" ...
    ##  $ namedLocation              : chr  "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" ...
    ##  $ domainID                   : chr  "D02" "D02" "D02" "D02" ...
    ##  $ siteID                     : chr  "BLAN" "BLAN" "BLAN" "BLAN" ...
    ##  $ plotID                     : chr  "BLAN_061" "BLAN_061" "BLAN_061" "BLAN_061" ...
    ##  $ decimalLatitude            : num  39.1 39.1 39.1 39.1 39.1 ...
    ##  $ decimalLongitude           : num  -78.1 -78.1 -78.1 -78.1 -78.1 ...
    ##  $ geodeticDatum              : chr  "WGS84" "WGS84" "WGS84" "WGS84" ...
    ##  $ coordinateUncertainty      : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ elevation                  : num  183 183 183 183 183 183 183 183 183 183 ...
    ##  $ elevationUncertainty       : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ subtypeSpecification       : chr  "primary" "primary" "primary" "primary" ...
    ##  $ transectMeter              : num  491 139 575 501 632 657 336 680 753 38 ...
    ##  $ directionFromTransect      : chr  "Left" "Left" "Right" "Right" ...
    ##  $ ninetyDegreeDistance       : num  0.5 2 2 3 3 2 6 5 2 2 ...
    ##  $ sampleLatitude             : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ sampleLongitude            : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ sampleCoordinateUncertainty: num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ sampleElevation            : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ sampleElevationUncertainty : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ date                       : Date, format: "2016-04-20" "2017-02-24" "2017-02-24" "2017-02-24" ...
    ##  $ editedDate                 : Date, format: "2016-05-09" "2021-07-13" "2021-07-13" "2021-07-13" ...
    ##  $ individualID               : chr  "NEON.PLA.D02.BLAN.06290" "NEON.PLA.D02.BLAN.06231" "NEON.PLA.D02.BLAN.06208" "NEON.PLA.D02.BLAN.06503" ...
    ##  $ taxonID                    : chr  "RHDA" "RHDA" "RHDA" "SOAL6" ...
    ##  $ scientificName             : chr  "Rhamnus davurica Pall." "Rhamnus davurica Pall." "Rhamnus davurica Pall." "Solidago altissima L." ...
    ##  $ identificationQualifier    : chr  NA NA NA NA ...
    ##  $ taxonRank                  : chr  "species" "species" "species" "species" ...
    ##  $ nativeStatusCode           : chr  "I" "I" "I" "N" ...
    ##  $ identificationHistoryID    : chr  NA NA NA NA ...
    ##  $ growthForm                 : chr  "Deciduous broadleaf" "Deciduous broadleaf" "Deciduous broadleaf" "Forb" ...
    ##  $ vstTag                     : chr  "N" "N" "N" "N" ...
    ##  $ measuredBy                 : chr  "jcoloso@neoninc.org" "mastersb@battelleecology.org" "mastersb@battelleecology.org" "mastersb@battelleecology.org" ...
    ##  $ identifiedBy               : chr  "shackley@neoninc.org" "llemmon@field-ops.org" "llemmon@field-ops.org" "llemmon@field-ops.org" ...
    ##  $ recordedBy                 : chr  "shackley@neoninc.org" NA NA NA ...
    ##  $ remarks                    : chr  "Nearly dead shaded out" NA NA "Dropped 20190717 no individuals present had been small and unhealthy" ...
    ##  $ dataQF                     : chr  NA NA NA NA ...
    ##  $ publicationDate            : chr  "20251222T234455Z" "20251222T234455Z" "20251222T234455Z" "20251222T234455Z" ...
    ##  $ release                    : chr  "RELEASE-2026" "RELEASE-2026" "RELEASE-2026" "RELEASE-2026" ...

Notice that the `neonUtilities` package read the data type from the variables file
and then automatically converts the data to the correct date type in R. 

#### Phenology status
Now let's look at the status data. 


    # What variables are included in this dataset?

    names(status)

    ##  [1] "uid"                           "namedLocation"                 "domainID"                     
    ##  [4] "siteID"                        "plotID"                        "date"                         
    ##  [7] "editedDate"                    "dayOfYear"                     "eventID"                      
    ## [10] "individualID"                  "phenophaseName"                "phenophaseStatus"             
    ## [13] "phenophaseIntensityDefinition" "phenophaseIntensity"           "samplingProtocolVersion"      
    ## [16] "measuredBy"                    "recordedBy"                    "remarks"                      
    ## [19] "dataEntryRecordID"             "dataQF"                        "publicationDate"              
    ## [22] "release"

    nrow(status)

    ## [1] 219327

    head(status)

    ##                                    uid          namedLocation domainID siteID   plotID       date editedDate dayOfYear
    ## 1 25367e54-14e2-4d60-add6-57e9232a4b4a BLAN_061.phenology.phe      D02   BLAN BLAN_061 2017-02-24 2017-03-31        55
    ## 2 95dc8be6-a8e7-44f6-a510-3d7024794fa5 BLAN_061.phenology.phe      D02   BLAN BLAN_061 2017-02-24 2017-03-31        55
    ## 3 29994dd9-6bf7-4fe5-9420-03fbdc9c6d35 BLAN_061.phenology.phe      D02   BLAN BLAN_061 2017-02-24 2017-03-31        55
    ## 4 03514dba-fa81-4734-b39c-3deacb4bece2 BLAN_061.phenology.phe      D02   BLAN BLAN_061 2017-02-24 2017-03-31        55
    ## 5 e93412c3-ec6d-4608-9a71-33e8cae7ac66 BLAN_061.phenology.phe      D02   BLAN BLAN_061 2017-02-24 2017-03-31        55
    ## 6 8d2ec4e2-58a1-4ec0-93ae-6544a5f877de BLAN_061.phenology.phe      D02   BLAN BLAN_061 2017-02-24 2017-03-31        55
    ##   eventID            individualID       phenophaseName phenophaseStatus phenophaseIntensityDefinition phenophaseIntensity
    ## 1    <NA> NEON.PLA.D02.BLAN.06238 Increasing leaf size               no                          <NA>                <NA>
    ## 2    <NA> NEON.PLA.D02.BLAN.06229       Colored leaves               no                          <NA>                <NA>
    ## 3    <NA> NEON.PLA.D02.BLAN.06221   Breaking leaf buds               no                          <NA>                <NA>
    ## 4    <NA> NEON.PLA.D02.BLAN.06212               Leaves               no                          <NA>                <NA>
    ## 5    <NA> NEON.PLA.D02.BLAN.06514       Initial growth               no                          <NA>                <NA>
    ## 6    <NA> NEON.PLA.D02.BLAN.06245   Breaking leaf buds               no                          <NA>                <NA>
    ##   samplingProtocolVersion          measuredBy          recordedBy remarks dataEntryRecordID     dataQF  publicationDate
    ## 1                    <NA> llemmon@neoninc.org llemmon@neoninc.org    <NA>              <NA> legacyData 20251222T234455Z
    ## 2                    <NA> llemmon@neoninc.org llemmon@neoninc.org    <NA>              <NA> legacyData 20251222T234455Z
    ## 3                    <NA> llemmon@neoninc.org llemmon@neoninc.org    <NA>              <NA> legacyData 20251222T234455Z
    ## 4                    <NA> llemmon@neoninc.org llemmon@neoninc.org    <NA>              <NA> legacyData 20251222T234455Z
    ## 5                    <NA> llemmon@neoninc.org llemmon@neoninc.org    <NA>              <NA> legacyData 20251222T234455Z
    ## 6                    <NA> llemmon@neoninc.org llemmon@neoninc.org    <NA>              <NA> legacyData 20251222T234455Z
    ##        release
    ## 1 RELEASE-2026
    ## 2 RELEASE-2026
    ## 3 RELEASE-2026
    ## 4 RELEASE-2026
    ## 5 RELEASE-2026
    ## 6 RELEASE-2026

    str(status)

    ## 'data.frame':	219327 obs. of  22 variables:
    ##  $ uid                          : chr  "25367e54-14e2-4d60-add6-57e9232a4b4a" "95dc8be6-a8e7-44f6-a510-3d7024794fa5" "29994dd9-6bf7-4fe5-9420-03fbdc9c6d35" "03514dba-fa81-4734-b39c-3deacb4bece2" ...
    ##  $ namedLocation                : chr  "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" ...
    ##  $ domainID                     : chr  "D02" "D02" "D02" "D02" ...
    ##  $ siteID                       : chr  "BLAN" "BLAN" "BLAN" "BLAN" ...
    ##  $ plotID                       : chr  "BLAN_061" "BLAN_061" "BLAN_061" "BLAN_061" ...
    ##  $ date                         : Date, format: "2017-02-24" "2017-02-24" "2017-02-24" "2017-02-24" ...
    ##  $ editedDate                   : Date, format: "2017-03-31" "2017-03-31" "2017-03-31" "2017-03-31" ...
    ##  $ dayOfYear                    : int  55 55 55 55 55 55 55 55 55 55 ...
    ##  $ eventID                      : chr  NA NA NA NA ...
    ##  $ individualID                 : chr  "NEON.PLA.D02.BLAN.06238" "NEON.PLA.D02.BLAN.06229" "NEON.PLA.D02.BLAN.06221" "NEON.PLA.D02.BLAN.06212" ...
    ##  $ phenophaseName               : chr  "Increasing leaf size" "Colored leaves" "Breaking leaf buds" "Leaves" ...
    ##  $ phenophaseStatus             : chr  "no" "no" "no" "no" ...
    ##  $ phenophaseIntensityDefinition: chr  NA NA NA NA ...
    ##  $ phenophaseIntensity          : chr  NA NA NA NA ...
    ##  $ samplingProtocolVersion      : chr  NA NA NA NA ...
    ##  $ measuredBy                   : chr  "llemmon@neoninc.org" "llemmon@neoninc.org" "llemmon@neoninc.org" "llemmon@neoninc.org" ...
    ##  $ recordedBy                   : chr  "llemmon@neoninc.org" "llemmon@neoninc.org" "llemmon@neoninc.org" "llemmon@neoninc.org" ...
    ##  $ remarks                      : chr  NA NA NA NA ...
    ##  $ dataEntryRecordID            : chr  NA NA NA NA ...
    ##  $ dataQF                       : chr  "legacyData" "legacyData" "legacyData" "legacyData" ...
    ##  $ publicationDate              : chr  "20251222T234455Z" "20251222T234455Z" "20251222T234455Z" "20251222T234455Z" ...
    ##  $ release                      : chr  "RELEASE-2026" "RELEASE-2026" "RELEASE-2026" "RELEASE-2026" ...

    # date range

    min(status$date)

    ## [1] "2017-02-24"

    max(status$date)

    ## [1] "2019-12-12"

## Data cleanup and transformation

* Check for duplicates
* Retain only the most recent `editedDate` in each table
* Join tables

### Check for duplicates

NEON data are quality-controlled on data entry and ingest to the database, but 
one of the most common data entry errors is duplicate entry. The `neonOS` 
package contains a function, `removeDups()`, that uses metadata from the 
variables file to check for duplicate records and resolve them if possible. Of 
course NEON also uses these tools internally; if you detect duplicates in data 
in one Release, they may be resolved in the next Release.

Let's check both tables for duplicates.


    ind_noD <- removeDups(ind, 
                          variables=phe$variables_10055,
                          table="phe_perindividual")

    ## No duplicated key values found!

    status_noD <- removeDups(status,
                             variables=phe$variables_10055,
                             table="phe_statusintensity")

    ## 1761 duplicated key values found, representing 3522 non-unique records. Attempting to resolve.

    ## 833 resolveable duplicates merged into matching records
    ## 833 resolved records flagged with duplicateRecordQF=1

    ## 1856 unresolveable duplicates flagged with duplicateRecordQF=2

There are no duplicates in the perindividual table, but there are 3522 duplicate 
records (out of 219327 total records) in the statusintensity table. Inspecting 
the records, the majority are commissioning tests, when two people recorded each 
phenophase to check for agreement. `removeDups()` has resolved each pair to a 
single record when the phenophase data matched, and left as duplicates when the 
data didn't match.

### Filter to last editedDate

The individual (ind) table contains all instances that any of the location or 
taxonomy data of an individual was updated. Therefore there are many rows for
some individuals. We only want the latest `editedDate` in the ind table. 


    ind_last <- ind_noD %>%
    	group_by(individualID) %>%
    	filter(editedDate==max(editedDate))

In this case no rows were removed from the table; NEON staff have already 
resolved the data to the most recent `editedDate`. It is always good to check 
for this, but it is more likely to come up in Provisional data.

### Prepare to join: Variable overlap between tables

From the initial inspection of the data we can see there is overlap in variable
names between the fields.

Let's see what they are.


    intersect(names(status_noD), 
              names(ind_last))

    ##  [1] "uid"               "namedLocation"     "domainID"          "siteID"            "plotID"            "date"             
    ##  [7] "editedDate"        "individualID"      "measuredBy"        "recordedBy"        "remarks"           "dataQF"           
    ## [13] "publicationDate"   "release"           "duplicateRecordQF"

There are several fields that overlap between the datasets. Some of these are
expected to be the same and will be what we join on. 

However, some of these will have different values in each table. We want to keep 
those distinct value and not join on them. Therefore, we rename these 
fields before joining:

* uid
* date
* editedDate
* measuredBy
* recordedBy
* samplingProtocolVersion
* remarks
* dataQF
* publicationDate

We'll rename all the variables in the status object to have "Stat" at the end 
of the variable name. 


    status_noD <- status_noD %>%
      rename(uidStat=uid, dateStat=date, 
             editedDateStat=editedDate, 
             measuredByStat=measuredBy, 
             recordedByStat=recordedBy, 
             samplingProtocolVersionStat=samplingProtocolVersion, 
             remarksStat=remarks, 
             dataQFStat=dataQF, 
             publicationDateStat=publicationDate)

### Join Dataframes

Now we can join the two data frames on all the variables with the same name. 
We use a `left_join()` from the dpylr package because we want to match all the 
rows from the "left" (status) dataframe to any rows that also occur in the "right" 
(individual) dataframe.  
 
 Check out RStudio's 
 <a href="https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf" target="_blank"> data wrangling (dplyr/tidyr) cheatsheet</a>
 for other types of joins. 
 

    phe_ind <- left_join(status_noD, 
                         ind_last)

    ## Joining with `by = join_by(namedLocation, domainID, siteID, plotID, individualID, release, duplicateRecordQF)`

In some cases, the steps above result in date fields being converted to 
string. Check, and convert back to dates if necessary.


    if(class(phe_ind$date)=="character") {
      phe_ind$date <- as.POSIXct(phe_ind$date,
                                 format="%Y-%m-%d",
                                 tz="GMT")
    }

    

    if(class(phe_ind$dateStat)=="character") {
      phe_ind$dateStat <- as.POSIXct(phe_ind$dateStat,
                                 format="%Y-%m-%d",
                                 tz="GMT")
    }

Now that we have a clean, joined dataset we can begin to 
explore our research question: do plants show patterns of changes in phenophase 
across season?

## Patterns in phenophase  

From our larger dataset (several sites, species, phenophases), let's create a
dataframe with only the data from a single site, species, and phenophase and 
call it `phe_1sp`.

## Select site(s) of interest

To do this, we'll first select our site of interest. Note how we set this up 
with an object that is our site of interest. This will allow us to more easily change 
which site or sites if we want to adapt our code later. 


    siteOfInterest <- "SCBI"

    

    ## using %in% allows one to add a vector if you want more than one site. 

    ## could also do it with == but won't work with vectors

    

    phe_1st <- phe_ind %>% 
      filter(siteID %in% siteOfInterest)

## Select species of interest

Now we may only want to view a single species or a set of species. Let's first 
look at the species that are present in our data. We could do this just by looking
at the `taxonID` field which give the four letter UDSA plant code for each 
species. But if we don't know all the plant codes, we can get a bit fancier and 
view both the `taxonID` and `scientificName`.


    unique(phe_1st$taxonID)

    ## [1] "JUNI" "LITU" "MIVI" NA

    unique(paste(phe_1st$taxonID, 
                 phe_1st$scientificName, 
                 sep=' - ')) 

    ## [1] "JUNI - Juglans nigra L."                       "LITU - Liriodendron tulipifera L."            
    ## [3] "MIVI - Microstegium vimineum (Trin.) A. Camus" "NA - NA"

For now, let's choose only the flowering tree *Liriodendron tulipifera* (LITU). 
By writing it this way, we could also add a list of species to the `speciesOfInterest`
object to select for multiple species. 


    speciesOfInterest <- "LITU"

    

    phe_1sp <- phe_1st %>%
      filter(taxonID==speciesOfInterest)

    

    # check that it worked

    unique(phe_1sp$taxonID)

    ## [1] "LITU"


## Select phenophase of interest

And, perhaps a single phenophase. 


    # see which phenophases are present

    unique(phe_1sp$phenophaseName)

    ## [1] "Increasing leaf size" "Leaves"               "Colored leaves"       "Open flowers"         "Falling leaves"      
    ## [6] "Breaking leaf buds"

    phenophaseOfInterest <- "Leaves"

    

    # subset to just the phenophase of interest 

    phe_1sp <- phe_1sp %>%
      filter(phenophaseName %in% phenophaseOfInterest)

    

    # check that it worked

    unique(phe_1sp$phenophaseName)

    ## [1] "Leaves"

## Select only primary plots

NEON plant phenology observations are collected in two types of plots. 

* Primary plots: an 800 meter square phenology loop transect
* Phenocam plots: a 200 m x 200 m plot located within view of a canopy level, 
tower-mounted, phenology camera

In the data, these plots are differentiated by the `subtypeSpecification`. 
Depending on your question you may want to use only one or both of these plot types. 
For this activity, we're going to only look at the primary plots. 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** How do I learn this on my own? Read 
the Data Product User Guide and use the variables files with the data download 
to find the corresponding variables names.
</div>


    # what plots are present?

    unique(phe_1sp$subtypeSpecification)

    ## [1] "primary"  "phenocam"

    # filter

    phe_1spPrimary <- phe_1sp %>%
      filter(subtypeSpecification == 'primary')

    

    # check that it worked

    unique(phe_1spPrimary$subtypeSpecification)

    ## [1] "primary"

## Total in phenophase of interest

The `phenophaseState` is recorded as "yes" or "no" that the individual is in that
phenophase. The `phenophaseIntensity` are categories for how much of the individual
is in that state. For now, we will stick with `phenophaseState`. 

We can now calculate the total number of individuals in that state. We use 
`n_distinct(indvidualID)` to count the individuals (and not the records) in case 
there are duplicate records for an individual. 

But later on we'll also want to calculate the percent of the observed individuals
in the "leaves" status, therefore, we're also adding in a step here to retain the 
sample size so that we can calculate % later. 


    sampSize <- phe_1spPrimary %>%
      group_by(dateStat) %>%
      summarise(numInd=n_distinct(individualID))

    

    inStat <- phe_1spPrimary %>%
      group_by(dateStat, phenophaseStatus) %>%
      summarise(countYes=n_distinct(individualID))

    ## `summarise()` has regrouped the output.
    ## ℹ Summaries were computed grouped by dateStat and phenophaseStatus.
    ## ℹ Output is grouped by dateStat.
    ## ℹ Use `summarise(.groups = "drop_last")` to silence this message.
    ## ℹ Use `summarise(.by = c(dateStat, phenophaseStatus))` for per-operation grouping (`?dplyr::dplyr_by`) instead.

    inStat <- full_join(sampSize, 
                        inStat, 
                        by="dateStat")

    

    # Retain only Yes

    inStat_T <- inStat %>% 
      filter(phenophaseStatus %in% "yes")

    

    # check that it worked

    unique(inStat_T$phenophaseStatus)

    ## [1] "yes"


Now that we have the data we can plot it. 

## Plot with ggplot

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** For a detailed introduction to 
using `ggplot()`, visit 
<a href="https://www.neonscience.org/dc-time-series-plot-ggplot-r" target="_blank"> *Time Series 05: Plot Time Series with ggplot2 in R* tutorial</a>. 
</div>

The default setting for a ggplot bar plot -  `geom_bar()` - is a histogram
designated by `stat="bin"`. However, in this case, we want to plot count values. 
We can use `geom_bar(stat="identity")` to force ggplot to plot actual values.


    # plot number of individuals in leaf

    phenoPlot <- ggplot(inStat_T, 
                        aes(dateStat, countYes)) +
        geom_bar(stat="identity", na.rm = TRUE) 

    

    phenoPlot

![Bar plot showing the count of Liriodendrum tulipifera (LITU) individuals from January 2017 through December 2019 at the Smithsonian Conservation Biology Institute (SCBI). Counts represent individuals that were recorded as a 'yes' for the phenophase of interest,'Leaves', and were from the primary plots.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/biodiversity/neon-phenology-temp/01-explore-phenology-data/rfigs/plot-leaves-total-1.png)

    # Now let's make the plot look a bit more presentable

    phenoPlot <- ggplot(inStat_T, 
                        aes(dateStat, countYes)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Total Individuals in Leaf") +
        xlab("Date") + ylab("Number of Individuals") +
        theme(plot.title = element_text(lineheight=.8, 
                                        face="bold", 
                                        size = 20)) +
        theme(text = element_text(size=18))

    

    phenoPlot

![Bar plot showing the count of Liriodendrum tulipifera (LITU) individuals from January 2017 through December 2019 at the Smithsonian Conservation Biology Institute (SCBI). Counts represent individuals that were recorded as a 'yes' for the phenophase of interest,'Leaves', and were from the primary plots. Axis labels and title have been added to make the graph more presentable.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/biodiversity/neon-phenology-temp/01-explore-phenology-data/rfigs/plot-leaves-total-2.png)

We could also covert this to percentage and plot that. 


    # convert to percent

    inStat_T$percent <- ((inStat_T$countYes)/
                           inStat_T$numInd)*100

    

    # plot percent of leaves

    phenoPlot_P <- ggplot(inStat_T, 
                          aes(dateStat, percent)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Proportion in Leaf") +
        xlab("Date") + ylab("% of Individuals") +
        theme(plot.title = element_text(lineheight=.8, 
                                        face="bold", 
                                        size = 20)) +
        theme(text = element_text(size=18))

    

    phenoPlot_P

![It might also be useful to visualize the data in different ways while exploring the data. As such, before plotting, we can convert our count data into a percentage by writting an expression that divides the number of individuals with a 'yes' for the phenophase of interest, 'Leaves', by the total number of individuals and then multiplies the result by 100. Using this newly generated dataset of percentages, we can plot the data similarly to how we did in the previous plot. Only this time, the y-axis range goes from 0 to 100 to reflect the percentage data we just generated. The resulting plot now shows a bar plot of the proportion of Liriodendrum tulipifera (LITU) individuals from January 2017 through December 2019 at the Smithsonian Conservation Biology Institute (SCBI). The y-axis represents the percent of individuals that were recorded as a 'yes' for the phenophase of interest,'Leaves', and were from the primary plots.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/biodiversity/neon-phenology-temp/01-explore-phenology-data/rfigs/plot-leaves-percentage-1.png)

The plots demonstrate the nice expected pattern of increasing leaf-out, peak, 
and drop-off.

## Drivers of phenology

Now that we see that there are differences in and shifts in phenophases, what 
are the drivers of phenophases?

The NEON phenology measurements track sensitive and easily observed indicators 
of biotic responses to meteorological variability by monitoring the timing and duration 
of phenological stages in plant communities. Plant phenology is affected by forces 
such as temperature, timing and duration of pest infestations and disease outbreaks, 
water fluxes, nutrient budgets, carbon dynamics, and food availability and has 
feedbacks to trophic interactions, carbon sequestration, community composition 
and ecosystem function.  (quoted from 
<a href="http://data.neonscience.org/api/v0/documents/NEON_phenology_userGuide_vA" target="_blank"> Plant Phenology Observations user guide</a>.)

## Filter by date

In the next part of this series, we will be exploring temperature as a driver of
phenology. Temperature data are quite large (NEON provides this in 1 minute or 30
minute intervals) so let's trim our phenology date down to only one year so that 
we aren't working with as large a dataset. 

Let's filter to just 2018 data. 


    # use filter to select only the date of interest 

    phe_1sp_2018 <- inStat_T %>% 
      filter(dateStat >= "2018-01-01" & 
               dateStat <= "2018-12-31")

    

    # did it work?

    range(phe_1sp_2018$dateStat)

    ## [1] "2018-04-13 GMT" "2018-11-20 GMT"

How does that look? 


    # Now let's make the plot look a bit more presentable

    phenoPlot18 <- ggplot(phe_1sp_2018, 
                          aes(dateStat, countYes)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Total Individuals in Leaf") +
        xlab("Date") + ylab("Number of Individuals") +
        theme(plot.title = element_text(lineheight=.8, 
                                        face="bold", 
                                        size = 20)) +
        theme(text = element_text(size=18))

    

    phenoPlot18

![In the previous step, we filtered our data by date to only include data from 2018. Reviewing the newly generated dataset we get a bar plot showing the count of Liriodendrum tulipifera (LITU) individuals at the Smithsonian Conservation Biology Institute (SCBI) for the year 2018. Counts represent individuals that were recorded as a 'yes' for the phenophase of interest,'Leaves', and were from the primary plots.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/biodiversity/neon-phenology-temp/01-explore-phenology-data/rfigs/plot-2018-1.png)

Now that we've filtered down to just the 2018 data from SCBI for LITU in leaf, 
we may want to save that subsetted data for another use. To do that you can write
the data frame to a .csv file. 

You do not need to follow this step if you are continuing on to the next tutorials
in this series as you already have the data frame in your environment. Of course
if you close R and then come back to it, you will need to re-load this data and 
instructions for that are provided in the relevant tutorials. 


    # optional

    write.csv(phe_1sp_2018 , 

              file="NEONpheno_LITU_Leaves_SCBI_2018.csv", 

              row.names=F)
