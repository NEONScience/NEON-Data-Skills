---
syncID: 57a6e5db49494a4b82f9c1bdeec70e81
title: "Work With NEON's Plant Phenology Data"
description: "Learn to work with NEON plant phenology observation data (NEON.DP1.10055)."
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
You will need the most current version of R and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages

* **neonUtilities:** `install.packages("neonUtilities")`
* **ggplot2:** `install.packages("ggplot2")`
* **dplyr:** `install.packages("dplyr")`

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Download Data 

This tutorial is designed to have you download data directly from the NEON
portal API using the neonUtilities package. However, you can also directly 
download this data, prepackaged, from FigShare. This data set includes all the 
files needed for the *Work with NEON OS & IS Data - Plant Phenology & Temperature* 
tutorial series. The data are in the format you would receive if downloading them
using the `zipsByProduct()` function in the neonUtilities package. 

<a href = "https://ndownloader.figshare.com/files/22775042">Direct Download: **NEON Phenology & Temp Time Series Teaching Data Subset (v2 - 2017-2019 data)** (12 MB)</a>

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

In the downloaded data packet, data are available in two main files

* **phe_statusintensity:** Plant phenophase status and intensity data 
* **phe_perindividual:** Geolocation and taxonomic identification for phenology plants
* **phe_perindividualperyear:** recorded once a year, essentially the "metadata" 
about the plant: DBH, height, etc. 


There are other files in each download including a **readme** with information on 
the data product and the download; a **variables** file that defines the 
term descriptions, data types, and units; a **validation** file with data entry 
validation and parsing rules; and an **XML** with machine readable metadata. 

## Stack NEON Data

NEON data are delivered in a site and year-month format. When you download data,
you will get a single zipped file containing a directory for each month and site that you've 
requested data for. Dealing with these separate tables from even one or two sites
over a 12 month period can be a bit overwhelming. Luckily NEON provides an R package
**neonUtilities** that takes the unzipped downloaded file and joining the data 
files. The teaching data downloaded with this tutorial is already stacked. If you
are working with other NEON data, please go through the tutorial to stack the data
in 
<a href="https://www.neonscience.org/neonDataStackR" target="_blank">R</a> or in <a href="https://www.neonscience.org/neon-utilities-python" target="_blank">Python</a> 
and then return to this tutorial. 

## Work with NEON Data

When we do this for phenology data we get three files, one for each data table, 
with all the data from your site and date range of interest. 

First, we need to set up our R environment. 


    # install needed package (only uncomment & run if not already installed)
    #install.packages("neonUtilities")
    #install.packages("dplyr")
    #install.packages("ggplot2")
    
    # load needed packages
    library(neonUtilities)
    library(dplyr)
    library(ggplot2)
    
    
    options(stringsAsFactors=F) #keep strings as character type not factors
    
    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files. Be sure to move the download into your working directory!
    wd <- "~/Documents/data/" # Change this to match your local environment
    setwd(wd)

Let's start by loading our data of interest. For this series, we'll work with 
date from the NEON Domain 02 sites:

* Blandy Farm (BLAN)
* Smithsonian Conservation Biology Institute (SCBI)
* Smithsonian Environmental Research Center (SERC)

And we'll use data from January 2017 to December 2019. This downloads over 9MB
of data. If this is too large, use a smaller date range. If you opt to do this, 
your figures and some output may look different later in the tutorial. 

With this information, we can download our data using the neonUtilities package. 
If you are not using a NEON token to download your data, remove the 
`token = Sys.getenv(NEON_TOKEN)` line of code (learn more about NEON API tokens 
in the 
<a href="https//:www.neonscience.org/neon-api-tokens-tutorial" target="_blank">*Using an API Token when Accessing NEON Data with neonUtilities* tutorial</a>). 

If you are using the data downloaded at the start of the tutorial, use the 
commented out code in the second half of this code chunk. 


    ## Two options for accessing data - programmatic or from the example dataset
    # Read data from data portal 
    
    phe <- loadByProduct(dpID = "DP1.10055.001", site=c("BLAN","SCBI","SERC"), 
    										 startdate = "2017-01", enddate="2019-12", 
    										 token = Sys.getenv("NEON_TOKEN"),
    										 check.size = F) 

    ## Finding available files
    ##   |                                                                       |                                                               |   0%  |                                                                       |=                                                              |   1%  |                                                                       |=                                                              |   2%  |                                                                       |==                                                             |   3%  |                                                                       |===                                                            |   4%  |                                                                       |===                                                            |   5%  |                                                                       |====                                                           |   6%  |                                                                       |=====                                                          |   7%  |                                                                       |=====                                                          |   8%  |                                                                       |======                                                         |   9%  |                                                                       |=======                                                        |  11%  |                                                                       |=======                                                        |  12%  |                                                                       |========                                                       |  13%  |                                                                       |=========                                                      |  14%  |                                                                       |=========                                                      |  15%  |                                                                       |==========                                                     |  16%  |                                                                       |===========                                                    |  17%  |                                                                       |===========                                                    |  18%  |                                                                       |============                                                   |  19%  |                                                                       |=============                                                  |  20%  |                                                                       |=============                                                  |  21%  |                                                                       |==============                                                 |  22%  |                                                                       |===============                                                |  23%  |                                                                       |===============                                                |  24%  |                                                                       |================                                               |  25%  |                                                                       |=================                                              |  26%  |                                                                       |=================                                              |  27%  |                                                                       |==================                                             |  28%  |                                                                       |===================                                            |  29%  |                                                                       |===================                                            |  31%  |                                                                       |====================                                           |  32%  |                                                                       |=====================                                          |  33%  |                                                                       |=====================                                          |  34%  |                                                                       |======================                                         |  35%  |                                                                       |=======================                                        |  36%  |                                                                       |=======================                                        |  37%  |                                                                       |========================                                       |  38%  |                                                                       |=========================                                      |  39%  |                                                                       |=========================                                      |  40%  |                                                                       |==========================                                     |  41%  |                                                                       |===========================                                    |  42%  |                                                                       |===========================                                    |  43%  |                                                                       |============================                                   |  44%  |                                                                       |=============================                                  |  45%  |                                                                       |=============================                                  |  46%  |                                                                       |==============================                                 |  47%  |                                                                       |===============================                                |  48%  |                                                                       |===============================                                |  49%  |                                                                       |================================                               |  51%  |                                                                       |================================                               |  52%  |                                                                       |=================================                              |  53%  |                                                                       |==================================                             |  54%  |                                                                       |==================================                             |  55%  |                                                                       |===================================                            |  56%  |                                                                       |====================================                           |  57%  |                                                                       |====================================                           |  58%  |                                                                       |=====================================                          |  59%  |                                                                       |======================================                         |  60%  |                                                                       |======================================                         |  61%  |                                                                       |=======================================                        |  62%  |                                                                       |========================================                       |  63%  |                                                                       |========================================                       |  64%  |                                                                       |=========================================                      |  65%  |                                                                       |==========================================                     |  66%  |                                                                       |==========================================                     |  67%  |                                                                       |===========================================                    |  68%  |                                                                       |============================================                   |  69%  |                                                                       |============================================                   |  71%  |                                                                       |=============================================                  |  72%  |                                                                       |==============================================                 |  73%  |                                                                       |==============================================                 |  74%  |                                                                       |===============================================                |  75%  |                                                                       |================================================               |  76%  |                                                                       |================================================               |  77%  |                                                                       |=================================================              |  78%  |                                                                       |==================================================             |  79%  |                                                                       |==================================================             |  80%  |                                                                       |===================================================            |  81%  |                                                                       |====================================================           |  82%  |                                                                       |====================================================           |  83%  |                                                                       |=====================================================          |  84%  |                                                                       |======================================================         |  85%  |                                                                       |======================================================         |  86%  |                                                                       |=======================================================        |  87%  |                                                                       |========================================================       |  88%  |                                                                       |========================================================       |  89%  |                                                                       |=========================================================      |  91%  |                                                                       |==========================================================     |  92%  |                                                                       |==========================================================     |  93%  |                                                                       |===========================================================    |  94%  |                                                                       |============================================================   |  95%  |                                                                       |============================================================   |  96%  |                                                                       |=============================================================  |  97%  |                                                                       |============================================================== |  98%  |                                                                       |============================================================== |  99%  |                                                                       |===============================================================| 100%
    ## 
    ## Downloading files totaling approximately 11.661285 MB
    ## Downloading 95 files
    ##   |                                                                       |                                                               |   0%  |                                                                       |=                                                              |   1%  |                                                                       |=                                                              |   2%  |                                                                       |==                                                             |   3%  |                                                                       |===                                                            |   4%  |                                                                       |===                                                            |   5%  |                                                                       |====                                                           |   6%  |                                                                       |=====                                                          |   7%  |                                                                       |=====                                                          |   9%  |                                                                       |======                                                         |  10%  |                                                                       |=======                                                        |  11%  |                                                                       |=======                                                        |  12%  |                                                                       |========                                                       |  13%  |                                                                       |=========                                                      |  14%  |                                                                       |=========                                                      |  15%  |                                                                       |==========                                                     |  16%  |                                                                       |===========                                                    |  17%  |                                                                       |===========                                                    |  18%  |                                                                       |============                                                   |  19%  |                                                                       |=============                                                  |  20%  |                                                                       |=============                                                  |  21%  |                                                                       |==============                                                 |  22%  |                                                                       |===============                                                |  23%  |                                                                       |===============                                                |  24%  |                                                                       |================                                               |  26%  |                                                                       |=================                                              |  27%  |                                                                       |=================                                              |  28%  |                                                                       |==================                                             |  29%  |                                                                       |===================                                            |  30%  |                                                                       |===================                                            |  31%  |                                                                       |====================                                           |  32%  |                                                                       |=====================                                          |  33%  |                                                                       |=====================                                          |  34%  |                                                                       |======================                                         |  35%  |                                                                       |=======================                                        |  36%  |                                                                       |=======================                                        |  37%  |                                                                       |========================                                       |  38%  |                                                                       |=========================                                      |  39%  |                                                                       |=========================                                      |  40%  |                                                                       |==========================                                     |  41%  |                                                                       |===========================                                    |  43%  |                                                                       |===========================                                    |  44%  |                                                                       |============================                                   |  45%  |                                                                       |=============================                                  |  46%  |                                                                       |=============================                                  |  47%  |                                                                       |==============================                                 |  48%  |                                                                       |===============================                                |  49%  |                                                                       |================================                               |  50%  |                                                                       |================================                               |  51%  |                                                                       |=================================                              |  52%  |                                                                       |==================================                             |  53%  |                                                                       |==================================                             |  54%  |                                                                       |===================================                            |  55%  |                                                                       |====================================                           |  56%  |                                                                       |====================================                           |  57%  |                                                                       |=====================================                          |  59%  |                                                                       |======================================                         |  60%  |                                                                       |======================================                         |  61%  |                                                                       |=======================================                        |  62%  |                                                                       |========================================                       |  63%  |                                                                       |========================================                       |  64%  |                                                                       |=========================================                      |  65%  |                                                                       |==========================================                     |  66%  |                                                                       |==========================================                     |  67%  |                                                                       |===========================================                    |  68%  |                                                                       |============================================                   |  69%  |                                                                       |============================================                   |  70%  |                                                                       |=============================================                  |  71%  |                                                                       |==============================================                 |  72%  |                                                                       |==============================================                 |  73%  |                                                                       |===============================================                |  74%  |                                                                       |================================================               |  76%  |                                                                       |================================================               |  77%  |                                                                       |=================================================              |  78%  |                                                                       |==================================================             |  79%  |                                                                       |==================================================             |  80%  |                                                                       |===================================================            |  81%  |                                                                       |====================================================           |  82%  |                                                                       |====================================================           |  83%  |                                                                       |=====================================================          |  84%  |                                                                       |======================================================         |  85%  |                                                                       |======================================================         |  86%  |                                                                       |=======================================================        |  87%  |                                                                       |========================================================       |  88%  |                                                                       |========================================================       |  89%  |                                                                       |=========================================================      |  90%  |                                                                       |==========================================================     |  91%  |                                                                       |==========================================================     |  93%  |                                                                       |===========================================================    |  94%  |                                                                       |============================================================   |  95%  |                                                                       |============================================================   |  96%  |                                                                       |=============================================================  |  97%  |                                                                       |============================================================== |  98%  |                                                                       |============================================================== |  99%  |                                                                       |===============================================================| 100%
    ## 
    ## Unpacking zip files using 1 cores.
    ## Stacking operation across a single core.
    ## Stacking table phe_perindividual
    ## Stacking table phe_statusintensity
    ## Stacking table phe_perindividualperyear
    ## Copied the most recent publication of validation file to /stackedFiles
    ## Copied the most recent publication of categoricalCodes file to /stackedFiles
    ## Copied the most recent publication of variable definition file to /stackedFiles
    ## Finished: Stacked 3 data tables and 3 metadata tables!
    ## Stacking took 1.53068 secs

    # if you aren't sure you can handle the data file size use check.size = T. 
    
    # save dataframes from the downloaded list
    ind <- phe$phe_perindividual  #individual information
    status <- phe$phe_statusintensity  #status & intensity info
    
    
    ##If choosing to use example dataset downloaded from this tutorial: 
    
    # Stack multiple files within the downloaded phenology data
    #stackByTable("NEON-pheno-temp-timeseries_v2/filesToStack10055", folder = T)
    
    # read in data - readTableNEON uses the variables file to assign the correct
    # data type for each variable
    #ind <- readTableNEON('NEON-pheno-temp-timeseries_v2/filesToStack10055/stackedFiles/phe_perindividual.csv', 'NEON-pheno-temp-timeseries_v2/filesToStack10055/stackedFiles/variables_10055.csv')
    
    #status <- readTableNEON('NEON-pheno-temp-timeseries_v2/filesToStack10055/stackedFiles/phe_statusintensity.csv', 'NEON-pheno-temp-timeseries_v2/filesToStack10055/stackedFiles/variables_10055.csv')


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
    ## [21] "sampleElevationUncertainty"  "date"                       
    ## [23] "editedDate"                  "individualID"               
    ## [25] "taxonID"                     "scientificName"             
    ## [27] "identificationQualifier"     "taxonRank"                  
    ## [29] "nativeStatusCode"            "growthForm"                 
    ## [31] "vstTag"                      "samplingProtocolVersion"    
    ## [33] "measuredBy"                  "identifiedBy"               
    ## [35] "recordedBy"                  "remarks"                    
    ## [37] "dataQF"                      "publicationDate"            
    ## [39] "release"

    # Unsure of what some of the variables are you? Look at the variables table!
    View(phe$variables_10055)
    # if using the pre-downloaded data, you need to read in the variables file 
    # or open and look at it on your desktop
    #var <- read.csv('NEON-pheno-temp-timeseries_v2/filesToStack10055/stackedFiles/variables_10055.csv')
    #View(var)
    
    # how many rows are in the data?
    nrow(ind)

    ## [1] 433

    # look at the first six rows of data.
    #head(ind) #this is a good function to use but looks messy so not rendering it 
    
    # look at the structure of the dataframe.
    str(ind)

    ## 'data.frame':	433 obs. of  39 variables:
    ##  $ uid                        : chr  "76bf37d9-c834-43fc-a430-83d87e4b9289" "cf0239bb-2953-44a8-8fd2-051539be5727" "833e5f41-d5cb-4550-ba60-e6f000a2b1b6" "6c2e348d-d19e-4543-9d22-0527819ee964" ...
    ##  $ namedLocation              : chr  "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" ...
    ##  $ domainID                   : chr  "D02" "D02" "D02" "D02" ...
    ##  $ siteID                     : chr  "BLAN" "BLAN" "BLAN" "BLAN" ...
    ##  $ plotID                     : chr  "BLAN_061" "BLAN_061" "BLAN_061" "BLAN_061" ...
    ##  $ decimalLatitude            : num  39.1 39.1 39.1 39.1 39.1 ...
    ##  $ decimalLongitude           : num  -78.1 -78.1 -78.1 -78.1 -78.1 ...
    ##  $ geodeticDatum              : chr  NA NA NA NA ...
    ##  $ coordinateUncertainty      : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ elevation                  : num  183 183 183 183 183 183 183 183 183 183 ...
    ##  $ elevationUncertainty       : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ subtypeSpecification       : chr  "primary" "primary" "primary" "primary" ...
    ##  $ transectMeter              : num  491 464 537 15 753 506 527 305 627 501 ...
    ##  $ directionFromTransect      : chr  "Left" "Right" "Left" "Left" ...
    ##  $ ninetyDegreeDistance       : num  0.5 4 2 3 2 1 2 3 2 3 ...
    ##  $ sampleLatitude             : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ sampleLongitude            : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ sampleGeodeticDatum        : chr  "WGS84" "WGS84" "WGS84" "WGS84" ...
    ##  $ sampleCoordinateUncertainty: num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ sampleElevation            : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ sampleElevationUncertainty : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ date                       : POSIXct, format: "2016-04-20" "2017-02-24" ...
    ##  $ editedDate                 : POSIXct, format: "2016-05-09" "2018-05-02" ...
    ##  $ individualID               : chr  "NEON.PLA.D02.BLAN.06290" "NEON.PLA.D02.BLAN.06501" "NEON.PLA.D02.BLAN.06204" "NEON.PLA.D02.BLAN.06223" ...
    ##  $ taxonID                    : chr  "RHDA" "SOAL6" "RHDA" "LOMA6" ...
    ##  $ scientificName             : chr  "Rhamnus davurica Pall." "Solidago altissima L." "Rhamnus davurica Pall." "Lonicera maackii (Rupr.) Herder" ...
    ##  $ identificationQualifier    : chr  NA NA NA NA ...
    ##  $ taxonRank                  : chr  "species" "species" "species" "species" ...
    ##  $ nativeStatusCode           : chr  "I" "N" "I" "I" ...
    ##  $ growthForm                 : chr  "Deciduous broadleaf" "Forb" "Deciduous broadleaf" "Deciduous broadleaf" ...
    ##  $ vstTag                     : chr  NA NA NA NA ...
    ##  $ samplingProtocolVersion    : chr  NA "NEON.DOC.014040vJ" "NEON.DOC.014040vJ" "NEON.DOC.014040vJ" ...
    ##  $ measuredBy                 : chr  "jcoloso@neoninc.org" "jward@battelleecology.org" "alandes@field-ops.org" "alandes@field-ops.org" ...
    ##  $ identifiedBy               : chr  "shackley@neoninc.org" "llemmon@field-ops.org" "llemmon@field-ops.org" "llemmon@field-ops.org" ...
    ##  $ recordedBy                 : chr  "shackley@neoninc.org" NA NA NA ...
    ##  $ remarks                    : chr  "Nearly dead shaded out" "no entry" "no entry" "no entry" ...
    ##  $ dataQF                     : chr  NA NA NA NA ...
    ##  $ publicationDate            : chr  "20201218T103411Z" "20201218T103411Z" "20201218T103411Z" "20201218T103411Z" ...
    ##  $ release                    : chr  "RELEASE-2021" "RELEASE-2021" "RELEASE-2021" "RELEASE-2021" ...

Notice that the neonUtilities package read the data type from the variables file
and then automatically converts the data to the correct date type in R. 

(Note that if you first opened your data file in Excel, you might see 06/14/2014 as 
the format instead of 2014-06-14. Excel can do some ~~weird~~ interesting things
to dates.)

#### Phenology status
Now let's look at the status data. 


    # What variables are included in this dataset?
    names(status)

    ##  [1] "uid"                           "namedLocation"                
    ##  [3] "domainID"                      "siteID"                       
    ##  [5] "plotID"                        "date"                         
    ##  [7] "editedDate"                    "dayOfYear"                    
    ##  [9] "individualID"                  "phenophaseName"               
    ## [11] "phenophaseStatus"              "phenophaseIntensityDefinition"
    ## [13] "phenophaseIntensity"           "samplingProtocolVersion"      
    ## [15] "measuredBy"                    "recordedBy"                   
    ## [17] "remarks"                       "dataQF"                       
    ## [19] "publicationDate"               "release"

    nrow(status)

    ## [1] 219357

    #head(status)   #this is a good function to use but looks messy so not rendering it 
    str(status)

    ## 'data.frame':	219357 obs. of  20 variables:
    ##  $ uid                          : chr  "b69ada55-41d1-41c7-9031-149c54de51f9" "9be6f7ad-4422-40ac-ba7f-e32e0184782d" "58e7aeaf-163c-4ea2-ad75-db79a580f2f8" "efe7ca02-d09e-4964-b35d-aebdac8f3efb" ...
    ##  $ namedLocation                : chr  "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" "BLAN_061.phenology.phe" ...
    ##  $ domainID                     : chr  "D02" "D02" "D02" "D02" ...
    ##  $ siteID                       : chr  "BLAN" "BLAN" "BLAN" "BLAN" ...
    ##  $ plotID                       : chr  "BLAN_061" "BLAN_061" "BLAN_061" "BLAN_061" ...
    ##  $ date                         : POSIXct, format: "2017-02-24" "2017-02-24" ...
    ##  $ editedDate                   : POSIXct, format: "2017-03-31" "2017-03-31" ...
    ##  $ dayOfYear                    : num  55 55 55 55 55 55 55 55 55 55 ...
    ##  $ individualID                 : chr  "NEON.PLA.D02.BLAN.06229" "NEON.PLA.D02.BLAN.06226" "NEON.PLA.D02.BLAN.06222" "NEON.PLA.D02.BLAN.06223" ...
    ##  $ phenophaseName               : chr  "Leaves" "Leaves" "Leaves" "Leaves" ...
    ##  $ phenophaseStatus             : chr  "no" "no" "no" "no" ...
    ##  $ phenophaseIntensityDefinition: chr  NA NA NA NA ...
    ##  $ phenophaseIntensity          : chr  NA NA NA NA ...
    ##  $ samplingProtocolVersion      : chr  NA NA NA NA ...
    ##  $ measuredBy                   : chr  "llemmon@neoninc.org" "llemmon@neoninc.org" "llemmon@neoninc.org" "llemmon@neoninc.org" ...
    ##  $ recordedBy                   : chr  "llemmon@neoninc.org" "llemmon@neoninc.org" "llemmon@neoninc.org" "llemmon@neoninc.org" ...
    ##  $ remarks                      : chr  NA NA NA NA ...
    ##  $ dataQF                       : chr  "legacyData" "legacyData" "legacyData" "legacyData" ...
    ##  $ publicationDate              : chr  "20201217T203824Z" "20201217T203824Z" "20201217T203824Z" "20201217T203824Z" ...
    ##  $ release                      : chr  "RELEASE-2021" "RELEASE-2021" "RELEASE-2021" "RELEASE-2021" ...

    # date range
    min(status$date)

    ## [1] "2017-02-24 GMT"

    max(status$date)

    ## [1] "2019-12-12 GMT"

## Clean up the Data

* remove duplicates (full rows)
* convert to date format
* retain only the most recent `editedDate` in the perIndividual and status table.

### Remove Duplicates

The individual table (ind) file is included in each site by month-year file. As 
a result when all the tables are stacked there are many duplicates. 

Let's remove any duplicates that exist.


    # drop UID as that will be unique for duplicate records
    ind_noUID <- select(ind, -(uid))

    ## Error in (function (classes, fdef, mtable) : unable to find an inherited method for function 'select' for signature '"data.frame"'

    status_noUID <- select(status, -(uid))

    ## Error in (function (classes, fdef, mtable) : unable to find an inherited method for function 'select' for signature '"data.frame"'

    # remove duplicates
    ## expect many
    
    ind_noD <- distinct(ind_noUID)

    ## Error in distinct(ind_noUID): object 'ind_noUID' not found

    nrow(ind_noD)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'nrow': object 'ind_noD' not found

    status_noD<-distinct(status_noUID)

    ## Error in distinct(status_noUID): object 'status_noUID' not found

    nrow(status_noD)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'nrow': object 'status_noD' not found


### Variable Overlap between Tables

From the initial inspection of the data we can see there is overlap in variable
names between the fields.

Let's see what they are.


    # where is there an intersection of names
    intersect(names(status_noD), names(ind_noD))

    ## Error in intersect(names(status_noD), names(ind_noD)): object 'status_noD' not found

There are several fields that overlap between the datasets. Some of these are
expected to be the same and will be what we join on. 

However, some of these will have different values in each table. We want to keep 
those distinct value and not join on them. Therefore, we can rename these 
fields before joining:

* date
* editedDate
* measuredBy
* recordedBy
* samplingProtocolVersion
* remarks
* dataQF
* publicationDate

Now we want to rename the variables that would have duplicate names. We can 
rename all the variables in the status object to have "Stat" at the end of the 
variable name. 


    # in Status table rename like columns 
    status_noD <- rename(status_noD, dateStat=date, 
    										 editedDateStat=editedDate, measuredByStat=measuredBy, 
    										 recordedByStat=recordedBy, 
    										 samplingProtocolVersionStat=samplingProtocolVersion, 
    										 remarksStat=remarks, dataQFStat=dataQF, 
    										 publicationDateStat=publicationDate)

    ## Error in rename(status_noD, dateStat = date, editedDateStat = editedDate, : object 'status_noD' not found

### Filter to last editedDate

The individual (ind) table contains all instances that any of the location or 
taxonomy data of an individual was updated. Therefore there are many rows for
some individuals.  We only want the latest `editedDate` on ind. 


    # retain only the max of the date for each individualID
    ind_last <- ind_noD %>%
    	group_by(individualID) %>%
    	filter(editedDate==max(editedDate))

    ## Error in eval(lhs, parent, parent): object 'ind_noD' not found

    # oh wait, duplicate dates, retain only the most recent editedDate
    ind_lastnoD <- ind_last %>%
    	group_by(editedDate, individualID) %>%
    	filter(row_number()==1)

    ## Error in eval(lhs, parent, parent): object 'ind_last' not found

### Join Dataframes

Now we can join the two data frames on all the variables with the same name. 
We use a `left_join()` from the dpylr package because we want to match all the 
rows from the "left" (first) dataframe to any rows that also occur in the "right"
 (second) dataframe.  
 
 Check out RStudio's 
 <a href="https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf" target="_blank"> data wrangling (dplyr/tidyr) cheatsheet</a>
 for other types of joins. 
 

    # Create a new dataframe "phe_ind" with all the data from status and some from ind_lastnoD
    phe_ind <- left_join(status_noD, ind_lastnoD)

    ## Error in left_join(status_noD, ind_lastnoD): object 'status_noD' not found

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
    
    phe_1st <- filter(phe_ind, siteID %in% siteOfInterest)

    ## Error in filter(phe_ind, siteID %in% siteOfInterest): object 'phe_ind' not found

## Select Species of Interest

Now we may only want to view a single species or a set of species. Let's first 
look at the species that are present in our data. We could do this just by looking
at the `taxonID` field which give the four letter UDSA plant code for each 
species. But if we don't know all the plant codes, we can get a bit fancier and 
view both 


    # see which species are present - taxon ID only
    unique(phe_1st$taxonID)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'unique': object 'phe_1st' not found

    # or see which species are present with taxon ID + species name
    unique(paste(phe_1st$taxonID, phe_1st$scientificName, sep=' - ')) 

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'unique': object 'phe_1st' not found

For now, let's choose only the flowering tree *Liriodendron tulipifera* (LITU). 
By writing it this way, we could also add a list of species to the `speciesOfInterest`
object to select for multiple species. 


    speciesOfInterest <- "LITU"
    
    #subset to just "LITU"
    # here just use == but could also use %in%
    phe_1sp <- filter(phe_1st, taxonID==speciesOfInterest)

    ## Error in filter(phe_1st, taxonID == speciesOfInterest): object 'phe_1st' not found

    # check that it worked
    unique(phe_1sp$taxonID)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'unique': object 'phe_1sp' not found


## Select Phenophase of Interest

And, perhaps a single phenophase. 


    # see which phenophases are present
    unique(phe_1sp$phenophaseName)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'unique': object 'phe_1sp' not found

    phenophaseOfInterest <- "Leaves"
    
    #subset to just the phenosphase of interest 
    phe_1sp <- filter(phe_1sp, phenophaseName %in% phenophaseOfInterest)

    ## Error in filter(phe_1sp, phenophaseName %in% phenophaseOfInterest): object 'phe_1sp' not found

    # check that it worked
    unique(phe_1sp$phenophaseName)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'unique': object 'phe_1sp' not found

## Select only Primary Plots

NEON plant phenology observations are collected along two types of plots. 

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

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'unique': object 'phe_1sp' not found

    # filter
    phe_1spPrimary <- filter(phe_1sp, subtypeSpecification == 'primary')

    ## Error in filter(phe_1sp, subtypeSpecification == "primary"): object 'phe_1sp' not found

    # check that it worked
    unique(phe_1spPrimary$subtypeSpecification)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'unique': object 'phe_1spPrimary' not found

## Total in Phenophase of Interest

The `phenophaseState` is recorded as "yes" or "no" that the individual is in that
phenophase. The `phenophaseIntensity` are categories for how much of the individual
is in that state. For now, we will stick with `phenophaseState`. 

We can now calculate the total number of individuals with that state. We use 
`n_distinct(indvidualID)` count the individuals (and not the records) in case 
there are duplicate records for an individual. 

But later on we'll also want to calculate the percent of the observed individuals
in the "leaves" status, therefore, we're also adding in a step here to retain the 
sample size so that we can calculate % later. 

Here we use pipes `%>%` from the dpylr package to "pass" objects onto the next
function. 


    # Calculate sample size for later use
    sampSize <- phe_1spPrimary %>%
      group_by(dateStat) %>%
      summarise(numInd= n_distinct(individualID))

    ## Error in eval(lhs, parent, parent): object 'phe_1spPrimary' not found

    # Total in status by day for distinct individuals
    inStat <- phe_1spPrimary%>%
      group_by(dateStat, phenophaseStatus)%>%
      summarise(countYes=n_distinct(individualID))

    ## Error in eval(lhs, parent, parent): object 'phe_1spPrimary' not found

    inStat <- full_join(sampSize, inStat, by="dateStat")

    ## Error in full_join(sampSize, inStat, by = "dateStat"): object 'sampSize' not found

    # Retain only Yes
    inStat_T <- filter(inStat, phenophaseStatus %in% "yes")

    ## Error in filter(inStat, phenophaseStatus %in% "yes"): object 'inStat' not found

    # check that it worked
    unique(inStat_T$phenophaseStatus)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'unique': object 'inStat_T' not found


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
<a href="https://www.neonscience.org/dc-time-series-plot-ggplot-r" target="_blank"> *Time Series 05: Plot Time Series with ggplot2 in R* tutorial</a>. 
</div>

### Bar Plots with ggplot
To successfully plot, the last piece that is needed is the `geom`etry type. 
To create a bar plot, we set the `geom` element from to `geom_bar()`.  

The default setting for a ggplot bar plot -  `geom_bar()` - is a histogram
designated by `stat="bin"`. However, in this case, we want to plot count values. 
We can use `geom_bar(stat="identity")` to force ggplot to plot actual values.


    # plot number of individuals in leaf
    phenoPlot <- ggplot(inStat_T, aes(dateStat, countYes)) +
        geom_bar(stat="identity", na.rm = TRUE) 

    ## Error in ggplot(inStat_T, aes(dateStat, countYes)): object 'inStat_T' not found

    phenoPlot

    ## Error in eval(expr, envir, enclos): object 'phenoPlot' not found

    # Now let's make the plot look a bit more presentable
    phenoPlot <- ggplot(inStat_T, aes(dateStat, countYes)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Total Individuals in Leaf") +
        xlab("Date") + ylab("Number of Individuals") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))

    ## Error in ggplot(inStat_T, aes(dateStat, countYes)): object 'inStat_T' not found

    phenoPlot

    ## Error in eval(expr, envir, enclos): object 'phenoPlot' not found

We could also covert this to percentage and plot that. 


    # convert to percent
    inStat_T$percent<- ((inStat_T$countYes)/inStat_T$numInd)*100

    ## Error in eval(expr, envir, enclos): object 'inStat_T' not found

    # plot percent of leaves
    phenoPlot_P <- ggplot(inStat_T, aes(dateStat, percent)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Proportion in Leaf") +
        xlab("Date") + ylab("% of Individuals") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))

    ## Error in ggplot(inStat_T, aes(dateStat, percent)): object 'inStat_T' not found

    phenoPlot_P

    ## Error in eval(expr, envir, enclos): object 'phenoPlot_P' not found

The plots demonstrate the nice expected pattern of increasing leaf-out, peak, 
and drop-off.

## Drivers of Phenology

Now that we see that there are differences in and shifts in phenophases, what 
are the drivers of phenophases?

The NEON phenology measurements track sensitive and easily observed indicators 
of biotic responses to climate variability by monitoring the timing and duration 
of phenological stages in plant communities. Plant phenology is affected by forces 
such as temperature, timing and duration of pest infestations and disease outbreaks, 
water fluxes, nutrient budgets, carbon dynamics, and food availability and has 
feedbacks to trophic interactions, carbon sequestration, community composition 
and ecosystem function.  (quoted from 
<a href="http://data.neonscience.org/api/v0/documents/NEON_phenology_userGuide_vA" target="_blank"> Plant Phenology Observations user guide</a>.)

## Filter by Date

In the next part of this series, we will be exploring temperature as a driver of
phenology. Temperature date is quite large (NEON provides this in 1 minute or 30
minute intervals) so let's trim our phenology date down to only one year so that 
we aren't working with as large a data. 

Let's filter to just 2018 data. 


    # use filter to select only the date of interest 
    phe_1sp_2018 <- filter(inStat_T, dateStat >= "2018-01-01" & dateStat <= "2018-12-31")

    ## Error in filter(inStat_T, dateStat >= "2018-01-01" & dateStat <= "2018-12-31"): object 'inStat_T' not found

    # did it work?
    range(phe_1sp_2018$dateStat)

    ## Error in eval(expr, envir, enclos): object 'phe_1sp_2018' not found

How does that look? 


    # Now let's make the plot look a bit more presentable
    phenoPlot18 <- ggplot(phe_1sp_2018, aes(dateStat, countYes)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Total Individuals in Leaf") +
        xlab("Date") + ylab("Number of Individuals") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))

    ## Error in ggplot(phe_1sp_2018, aes(dateStat, countYes)): object 'phe_1sp_2018' not found

    phenoPlot18

    ## Error in eval(expr, envir, enclos): object 'phenoPlot18' not found

Now that we've filtered down to just the 2018 data from SCBI for LITU in leaf, 
we may want to save that subsetted data for another use. To do that you can write
the data frame to a .csv file. 

You do not need to follow this step if you are continuing on to the next tutorials
in this series as you already have the data frame in your environment. Of course
if you close R and then come back to it, you will need to re-load this data and 
instructions for that are provided in the relevant tutorials. 


    # Write .csv - this step is optional 
    # This will write to your current working directory, change as desired.
    write.csv( phe_1sp_2018 , file="NEONpheno_LITU_Leaves_SCBI_2018.csv", row.names=F)
    
    #If you are using the downloaded example date, this code will write it to the 
    # pheno data file. Note - this file is already a part of the download.
    
    #write.csv( phe_1sp_2018 , file="NEON-pheno-temp-timeseries_v2/NEONpheno_LITU_Leaves_SCBI_2018.csv", row.names=F)
