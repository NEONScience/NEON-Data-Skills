---
layout: post
title: "Methods of Exploring NEON Mosquito Data in R"
date:  2017-06-16
authors: [Charlotte Roiger]
dateCreated:  2017-05-20
lastModified: 2017-07-27
description: "This is a tutorial that shows users how to clean and perform an initial analysis using NEON mosquito data."
tags: [R]
image: #update later
  feature: TeachingModules.jpg
  credit: A National Ecological Observatory Network (NEON) - Teaching Module
  creditlink: http://www.neonscience.org
permalink: /R/carabid-clean-data # update later
code1: carabid-beetle-data/Beetle-Data-Clean-Portal-Data.R # update later
code2: carabid-beetle-data/carabid-NEON-data-cleanup.R # update later
comments: false
---

{% include _toc.html %}

## About
SENTENCES ADD HERE


**R Skill Level:** Intermediate - you've got the basics of `R` down

<div id="objectives" markdown="1">

# Goals & Objectives

After completing this tutorial, you will be able to:

*	Download mosquito trapping, identification, and sorting information from the 
  NEON data portal
* Download precipitation and temperature data from Global Historical Climatology
  Network
* Merge data frames to create one unified data frame with relevant variables to 
  address research questions
* Subset data by year
* Use ggplot2 in R to create visualizations of data trends and maps  


## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, RStudio loaded on
your computer to complete this tutorial.

### R Libraries to Install:

These R packages will be used in the tutorial below. Please make sure they are 
installed prior to starting the tutorial. 
 
* **dplyr:** `install.packages("dplyr")`
* **plyr:** `install.packages("plyr")`
* **tidyverse:** `install.packages("tidyverse")`
*	**plyr:** `install.packages("plyr")`
*	**mosaic:** `install.packages("mosaic")`
*	**metScanR:** `install.packages("metScanR")`





### Download The Data
**NOTE: eventually turn these into teaching data subsets with others, then change to download buttons**
You can download cleaned data files [here](//github.com/klevan/carabid-workshop/blob/master/data/zip%20files/cleaned-Data.zip), 
NOAA weather data for each site [here](//github.com/klevan/carabid-workshop/blob/master/data/NOAA%20weather%20data%20for%202014.csv), 
NEON map shp files [here](//github.com/klevan/carabid-workshop/blob/master/data/zip%20files/map%20data.zip) 
and the script we will be modifying [here](//github.com/klevan/carabid-workshop/blob/master/code/data-analysis.R). 
</div>



## NEON Mosquito Data

The mosquito data on the NEON Data Portal are divided by type of information 
into six tables:
 * field collection data
 * sorting data
 * identification and pinning data
 * pathogen pooling data
 * pathogen results data
 * archiving pooling data

#################################################################################################

For this tutorial we focus on the 2014 data and the 13 sites
for which data is available in that year. To look at all this data requires 
downloading 39 files (one field, sorting and pinning data for each site) and 
combining the datasheets across all sites for each type of data (i.e., field, 
sorting and pinning). 

NEON provides several documents with information about the Carabid beetle protocal & 
data collection. It is highly recommended you are familiar with the
<a href="http://data.neonscience.org/data-product-view?dpCode=DP1.10022.001" 
target="_blank">data product documents </a>
prior to using NEON carabid beetle data for your research. 

#################################################################################################


We'll explore these six tables and then combine them into a couple of clean
tables for use with analysis. 

First, set up the R environment. 


    # Load packages required for entire script. 
    library(plyr)      # move/manipulate data
    library(dplyr)     # move/manipulate data
    library(foreign)   
    library(maptools)  # used for creating maps of NEON field sites
    library(raster)    # manipulate spatial data
    #library(rbokeh)
    library(rgdal)     # manipulate and read spatial data
    library(ggplot2)   # creation of plots and visualizations
    library(tidyverse) # move/manipulate data
    library(mosaic)    # good for data exploration
    
    #Set strings as factors equal to false thoughout
    options(stringsAsFactors = FALSE) 
    
    # set working directory to ensure R can find the file we wish to import
    #setwd("working-dir-path-here")


### Field Collection Data Table

Read in the field collection data table. 


    #Read in the data TO BE CHANGED AS PORTAL DEVELOPS
    trap = read.csv('NEON-mosquito-data-viz/mos_trapping_in.csv')
    
    # set strings as factors as false throughout
    options(stringsAsFactors = FALSE) 
    
    #This command allows you to view the structure of the data
    str(trap)

    ## 'data.frame':	20613 obs. of  28 variables:
    ##  $ uid                    : chr  "eb7d9ac7-6ba4-46b5-877f-17df9578d862" "72b426be-334f-4fd3-97f4-6b2c4a148572" "a822fd87-746b-4c3e-8b7b-bfa4031cc176" "5020274e-a39d-4472-9bdd-29a6e469876b" ...
    ##  $ plotID                 : chr  "OSBS_057.mosquitoPoint.mos" "OSBS_053.mosquitoPoint.mos" "OSBS_054.mosquitoPoint.mos" "OSBS_058.mosquitoPoint.mos" ...
    ##  $ setDate                : chr  "2017-05-02T08:04" "2017-05-02T09:29" "2017-05-02T09:14" "2017-05-02T10:27" ...
    ##  $ collectDate            : chr  "2017-05-02T16:29" "2017-05-02T17:25" "2017-05-02T17:10" "2017-05-02T18:28" ...
    ##  $ trapHours              : logi  NA NA NA NA NA NA ...
    ##  $ nightOrDay             : chr  "day" "day" "day" "day" ...
    ##  $ eventID                : chr  "OSBS.2017.19" "OSBS.2017.19" "OSBS.2017.19" "OSBS.2017.19" ...
    ##  $ sampleID               : chr  "OSBS_057.20170502.1629" "OSBS_053.20170502.1725" "OSBS_054.20170502.1710" "OSBS_058.20170502.1828" ...
    ##  $ sampleCode             : logi  NA NA NA NA NA NA ...
    ##  $ sampleFate             : chr  "processed" "processed" "processed" "processed" ...
    ##  $ samplingProtocolVersion: chr  "NEON.DOC.014049vH" "NEON.DOC.014049vH" "NEON.DOC.014049vH" "NEON.DOC.014049vH" ...
    ##  $ sampleTiming           : chr  "Field season" "Field season" "Field season" "Field season" ...
    ##  $ numVialsSampleID       : int  1 1 1 1 1 1 1 1 1 1 ...
    ##  $ fanStatus              : chr  "On" "On" "On" "On" ...
    ##  $ catchCupStatus         : chr  "OK" "OK" "OK" "OK" ...
    ##  $ dryIceStatus           : chr  "Present" "Absent" "Present" "Present" ...
    ##  $ sampleCondition        : chr  "No known compromise" "No known compromise" "No known compromise" "No known compromise" ...
    ##  $ targetTaxaPresent      : chr  "Y" "Y" "Y" "Y" ...
    ##  $ remarks                : chr  "" "" "" "" ...
    ##  $ recordedBy             : chr  "biwaniec@battelleecology.org" "biwaniec@battelleecology.org" "biwaniec@battelleecology.org" "biwaniec@battelleecology.org" ...
    ##  $ enteredBy              : chr  "" "" "" "" ...
    ##  $ pdaDecimalLatitude     : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ pdaDecimalLongitude    : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ pdaAccuracy            : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ pdaElevation           : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ fulcrumVersion         : logi  NA NA NA NA NA NA ...
    ##  $ platformInfo           : logi  NA NA NA NA NA NA ...
    ##  $ dataQF                 : logi  NA NA NA NA NA NA ...

This table contains information related to:

* metadata about the sampling event, includes: 
   + `plotID`: label of where a sample was collected
   + `setDate`: when traps were set
   + `collectDate`: the date of trap collection
   + `sampleID`: unique label of sample collection events
   + `targetTaxaPresent`:an indication of whether mosquitos were found in the 
      sample 
   + `HoursOfTrapping`: the number of days a given trap was in the field
   + `samplingProtocolVersion`: the document number and the version of the 
      sampling protocol used. These can be found in the 
<a href="http://data.neonscience.org/documents" target="_blank"> NEON Documents Library</a>. 

For sake of convenience we have only included the meta data for certain variables
that we will use to carry out our analysis. For more metadata please see:
INSERT LINK OR SOMETHING FOR SORT METADATA

* metadata about the quality of the data 

Unique collection events have a unique `sampleID` with the format = 
`plotID.trapID.collectDate.TimeOfCollection`. 

### Sorting Data Table



    # read in sorting TO BE CHANGED AS PORTAL DEVELOPS
    sort = read.csv('NEON-mosquito-data-viz/mos_sorting_in.csv')
    
    # set strings as factors as false throughout
    options(stringsAsFactors = FALSE) 
    
    str(sort)

    ## 'data.frame':	10979 obs. of  20 variables:
    ##  $ uid            : logi  NA NA NA NA NA NA ...
    ##  $ plotID         : chr  "OSBS_056.mosquitoPoint.mos" "OSBS_057.mosquitoPoint.mos" "OSBS_055.mosquitoPoint.mos" "OSBS_054.mosquitoPoint.mos" ...
    ##  $ setDate        : chr  "2014-04-08T18:46" "2014-04-08T19:00" "2014-04-08T19:20" "2014-04-08T19:36" ...
    ##  $ collectDate    : chr  "2014-04-09T09:20" "2014-04-09T09:40" "2014-04-09T10:02" "2014-04-09T10:16" ...
    ##  $ receivedDate   : int  20140904 20140904 20140904 20140904 20140904 20140904 20140904 20141014 20140904 20140904 ...
    ##  $ sortDate       : int  20140908 20140908 20140906 20140906 20140905 20140909 20140909 20141014 20140909 20140908 ...
    ##  $ sampleID       : chr  "OSBS_056.20140409.0920" "OSBS_057.20140409.0940" "OSBS_055.20140409.1002" "OSBS_054.20140409.1016" ...
    ##  $ sampleCode     : logi  NA NA NA NA NA NA ...
    ##  $ sampleFate     : logi  NA NA NA NA NA NA ...
    ##  $ subsampleID    : chr  "OSBS_056.20140409.0920.S.01" "OSBS_057.20140409.0940.S.01" "OSBS_055.20140409.1002.S.01" "OSBS_054.20140409.1016.S.01" ...
    ##  $ subsampleCode  : logi  NA NA NA NA NA NA ...
    ##  $ subsampleFate  : logi  NA NA NA NA NA NA ...
    ##  $ totalWeight    : num  0.5 0.5 0.5 0.5 0.5 ...
    ##  $ subsampleWeight: num  0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 ...
    ##  $ bycatchWeight  : num  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ sampleCondition: logi  NA NA NA NA NA NA ...
    ##  $ remarks        : chr  "tech names may not be accurate" "tech names may not be accurate" "tech names may not be accurate" "tech names may not be accurate" ...
    ##  $ sortedBy       : chr  "dweissmann@comosquitocontrol.com" "dweissmann@comosquitocontrol.com" "dweissmann@comosquitocontrol.com" "dweissmann@comosquitocontrol.com" ...
    ##  $ laboratoryName : chr  "Colorado Mosquito Control" "Colorado Mosquito Control" "Colorado Mosquito Control" "Colorado Mosquito Control" ...
    ##  $ dataQF         : logi  NA NA NA NA NA NA ...

This table contains information about weight of subsamples and weight of bycatch. 

* metadata about the subsampling event, includes:
  + `plotID`: label of where a sample was collected
  + `setDate`: when traps were set
  + `collectDate`: the date of trap collection
  + `sampleID`: unique label of sample collection events
  + `subsampleID`: Unique label of subsampling collection events
  + `totalWeight`: Total weight of sample
  + `subsampleWeight`: Total weight of subsample
  + `bycatchWeight`: Total weight of bycatch in the subsample

Unique records have a unique `subSampleID` (format = 
`plotID.trapID.collectDate.TimeofCollection.S.01` ). 

For sake of convenience we have only included the meta data for certain variables
that we will use to carry out our analysis. For more metadata please see:
INSERT LINK OR SOMETHING FOR SORT METADATA

### Identification Data Table


    # read in data
    id = read.csv('NEON-mosquito-data-viz/mos_identification_in.csv')
    
    # set strings as factors as false throughout
    options(stringsAsFactors = FALSE) 
    
    # view structure of the data
    str(id)

    ## 'data.frame':	42649 obs. of  29 variables:
    ##  $ uid                     : logi  NA NA NA NA NA NA ...
    ##  $ plotID                  : chr  "OSBS_056.mosquitoPoint.mos" "OSBS_056.mosquitoPoint.mos" "OSBS_056.mosquitoPoint.mos" "OSBS_056.mosquitoPoint.mos" ...
    ##  $ setDate                 : chr  "2014-04-08T18:46" "2014-04-08T18:46" "2014-04-08T18:46" "2014-04-08T18:46" ...
    ##  $ collectDate             : chr  "2014-04-09T09:20" "2014-04-09T09:20" "2014-04-09T09:20" "2014-04-09T09:20" ...
    ##  $ identifiedDate          : int  20140908 20140908 20140908 20140908 20140908 20140908 20140908 20140908 20140908 20140908 ...
    ##  $ subsampleID             : chr  "OSBS_056.20140409.0920.S.01" "OSBS_056.20140409.0920.S.01" "OSBS_056.20140409.0920.S.01" "OSBS_056.20140409.0920.S.01" ...
    ##  $ subsampleCode           : logi  NA NA NA NA NA NA ...
    ##  $ subsampleFate           : logi  NA NA NA NA NA NA ...
    ##  $ testingID               : chr  "" "" "" "OSBS.2014.14.CULERR.F.T" ...
    ##  $ testingIDCode           : logi  NA NA NA NA NA NA ...
    ##  $ testingIDFate           : logi  NA NA NA NA NA NA ...
    ##  $ archiveID               : chr  "OSBS.2014.14.AEDMIT.F.A" "OSBS.2014.14.ANOCRU.F.A" "OSBS.2014.14.ANOSPP1.F.A" "OSBS.2014.14.CULERR.F.A" ...
    ##  $ archiveIDCode           : logi  NA NA NA NA NA NA ...
    ##  $ archiveFate             : logi  NA NA NA NA NA NA ...
    ##  $ targetTaxaPresent       : chr  "Y" "Y" "Y" "Y" ...
    ##  $ individualCount         : int  1 177 7 39 3 26 2 2 1 1 ...
    ##  $ scientificName          : chr  "Aedes mitchellae" "Anopheles crucians" "Anopheles spp." "Culex erraticus" ...
    ##  $ identificationQualifier : chr  "" "" "" "" ...
    ##  $ sex                     : chr  "F" "F" "F" "F" ...
    ##  $ individualIDList        : chr  "" "MOS.D03.000543|MOS.D03.000544|MOS.D03.000545" "" "MOS.D03.000573|MOS.D03.000574|MOS.D03.000575|MOS.D03.000576|MOS.D03.000577|MOS.D03.000578|MOS.D03.000579|MOS.D03.000580" ...
    ##  $ individualCode          : logi  NA NA NA NA NA NA ...
    ##  $ individualFate          : logi  NA NA NA NA NA NA ...
    ##  $ identificationReferences: chr  "Darsie Jr., R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitoes of Nort"| __truncated__ "Darsie Jr., R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitoes of Nort"| __truncated__ "Darsie Jr., R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitoes of Nort"| __truncated__ "Darsie Jr., R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitoes of Nort"| __truncated__ ...
    ##  $ sampleCondition         : logi  NA NA NA NA NA NA ...
    ##  $ identificationRemarks   : chr  "" "" "specimens in poor condition" "" ...
    ##  $ remarks                 : chr  "" "" "" "" ...
    ##  $ identifiedBy            : chr  "M.J. Weissmann" "M.J. Weissmann" "M.J. Weissmann" "M.J. Weissmann" ...
    ##  $ laboratoryName          : chr  "Colorado Mosquito Control" "Colorado Mosquito Control" "Colorado Mosquito Control" "Colorado Mosquito Control" ...
    ##  $ dataQF                  : logi  NA NA NA NA NA NA ...

The identification table contains information about the types of mosquitos found
in each subsample. 

* metadata about the subsampling event, includes:
  + `plotID`: label of where a sample was collected
  + `setDate`: when traps were set
  + `collectDate`: the date of trap collection
  + `sampleID`: unique label of sample collection events
  + `subsampleID`: Unique label of subsampling collection events
  + `individualCount`: The number of each species found in a subsample
  + `scientificName`: The Scientific name of each species found in a subsample

* metadata about the quality of the data 

The identification table contains information about all mosquitos that were 
found in each subsample. Each sample in the identification dataset contains the
target taxa and once identified is either directly archived, or first sent to an
external lab for Pathogen testing. 

### Taxonomy Data Table


    #read in data
    taxonomy = read.csv("NEON-mosquito-data-viz/mosquito_taxonomy.csv")
    
    # set strings as factors as false throughout
    options(stringsAsFactors = FALSE) 
    
    str(taxonomy)

    ## 'data.frame':	670 obs. of  103 variables:
    ##  $ taxonID                 : chr  "AEDCAN" "AEDFUL" "TOXRUT" "URAANH" ...
    ##  $ acceptedTaxonID         : chr  "AEDCAN" "AEDFUL" "TOXRUT" "URAANH" ...
    ##  $ synonymyStartUseDate    : int  20120501 20120501 20120501 20120501 20120501 20120501 20120501 20120501 20120501 20120501 ...
    ##  $ synonymyEndUseDate      : logi  NA NA NA NA NA NA ...
    ##  $ kingdom                 : chr  "Animalia" "Animalia" "Animalia" "Animalia" ...
    ##  $ phylum                  : chr  "Arthropoda" "Arthropoda" "Arthropoda" "Arthropoda" ...
    ##  $ class                   : chr  "Insecta" "Insecta" "Insecta" "Insecta" ...
    ##  $ order                   : chr  "Diptera" "Diptera" "Diptera" "Diptera" ...
    ##  $ family                  : chr  "Culicidae" "Culicidae" "Culicidae" "Culicidae" ...
    ##  $ subfamily               : chr  "Culicinae" "Culicinae" "Toxorhynchitinae" "Culicinae" ...
    ##  $ tribe                   : chr  "Culicini" "Culicini" "Toxorhynchitini" "Culicini" ...
    ##  $ genus                   : chr  "Aedes" "Aedes" "Toxorhynchites" "Uranotaenia" ...
    ##  $ subgenus                : logi  NA NA NA NA NA NA ...
    ##  $ speciesGroup            : chr  "" "" "" "" ...
    ##  $ specificEpithet         : chr  "canadensis" "fulvus" "rutilus" "anhydor" ...
    ##  $ infraspecificEpithet    : chr  "mathesoni" "pallens" "septentrionalis" "syntheta" ...
    ##  $ scientificName          : chr  "Aedes canadensis mathesoni" "Aedes fulvus pallens" "Toxorhynchites rutilus septentrionalis" "Uranotaenia anhydor syntheta" ...
    ##  $ scientificNameAuthorship: chr  "" "Ross" "" "" ...
    ##  $ taxonRank               : chr  "subspecies" "subspecies" "subspecies" "subspecies" ...
    ##  $ vernacularName          : logi  NA NA NA NA NA NA ...
    ##  $ nameAccordingTo         : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ nameAccordingToID       : chr  "isbn: 0813027845" "isbn: 0813027845" "isbn: 0813027845" "isbn: 0813027845" ...
    ##  $ taxonProtocolCategory   : chr  "target" "target" "target" "target" ...
    ##  $ l48NativeStatusCode     : chr  "N" "N" "N" "N" ...
    ##  $ l48NativeStatusSource   : chr  "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" ...
    ##  $ l48LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ akNativeStatusCode      : chr  "A" "A" "A" "A" ...
    ##  $ akNativeStatusSource    : chr  "" "" "" "" ...
    ##  $ akLocalityStatusSource  : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ hiNativeStatusCode      : chr  "A" "A" "A" "A" ...
    ##  $ hiNativeStatusSource    : chr  "" "" "" "" ...
    ##  $ hiLocalityStatusSource  : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ prNativeStatusCode      : chr  "A" "N" "A" "A" ...
    ##  $ prNativeStatusSource    : chr  "" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "" "" ...
    ##  $ prLocalityStatusSource  : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d01NativeStatusCode     : chr  "A" "A" "N" "A" ...
    ##  $ d01NativeStatusSource   : chr  "" "" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "" ...
    ##  $ d01LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d02NativeStatusCode     : chr  "N" "N" "N" "A" ...
    ##  $ d02NativeStatusSource   : chr  "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "" ...
    ##  $ d02LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d03NativeStatusCode     : chr  "N" "N" "N" "N" ...
    ##  $ d03NativeStatusSource   : chr  "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" ...
    ##  $ d03LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d04NativeStatusCode     : chr  "A" "N" "A" "A" ...
    ##  $ d04NativeStatusSource   : chr  "" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "" "" ...
    ##  $ d04LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d05NativeStatusCode     : chr  "A" "A" "A" "A" ...
    ##  $ d05NativeStatusSource   : chr  "" "" "" "" ...
    ##  $ d05LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d06NativeStatusCode     : chr  "A" "A" "N" "N" ...
    ##  $ d06NativeStatusSource   : chr  "" "" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" ...
    ##  $ d06LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d07NativeStatusCode     : chr  "A" "N" "N" "A" ...
    ##  $ d07NativeStatusSource   : chr  "" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "" ...
    ##  $ d07LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d08NativeStatusCode     : chr  "N" "N" "N" "N" ...
    ##  $ d08NativeStatusSource   : chr  "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" ...
    ##  $ d08LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d09NativeStatusCode     : chr  "A" "A" "A" "A" ...
    ##  $ d09NativeStatusSource   : chr  "" "" "" "" ...
    ##  $ d09LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d10NativeStatusCode     : chr  "A" "A" "A" "N" ...
    ##  $ d10NativeStatusSource   : chr  "" "" "" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" ...
    ##  $ d10LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d11NativeStatusCode     : chr  "A" "N" "N" "N" ...
    ##  $ d11NativeStatusSource   : chr  "" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" ...
    ##  $ d11LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d12NativeStatusCode     : chr  "A" "A" "A" "A" ...
    ##  $ d12NativeStatusSource   : chr  "" "" "" "" ...
    ##  $ d12LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d13NativeStatusCode     : chr  "A" "A" "A" "A" ...
    ##  $ d13NativeStatusSource   : chr  "" "" "" "" ...
    ##  $ d13LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d14NativeStatusCode     : chr  "A" "A" "A" "N" ...
    ##  $ d14NativeStatusSource   : chr  "" "" "" "The Global Invasive Species Database, http://www.issg.org/database, accessed Feb 4, 2015" ...
    ##  $ d14LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d15NativeStatusCode     : chr  "A" "A" "A" "A" ...
    ##  $ d15NativeStatusSource   : chr  "" "" "" "" ...
    ##  $ d15LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d16NativeStatusCode     : chr  "A" "A" "A" "A" ...
    ##  $ d16NativeStatusSource   : chr  "" "" "" "" ...
    ##  $ d16LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d17NativeStatusCode     : chr  "A" "A" "A" "A" ...
    ##  $ d17NativeStatusSource   : chr  "" "" "" "" ...
    ##  $ d17LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d18NativeStatusCode     : chr  "A" "A" "A" "A" ...
    ##  $ d18NativeStatusSource   : chr  "" "" "" "" ...
    ##  $ d18LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d19NativeStatusCode     : chr  "A" "A" "A" "A" ...
    ##  $ d19NativeStatusSource   : chr  "" "" "" "" ...
    ##  $ d19LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ d20NativeStatusCode     : chr  "A" "A" "A" "A" ...
    ##  $ d20NativeStatusSource   : chr  "" "" "" "" ...
    ##  $ d20LocalityStatusSource : chr  "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ "Darsie, R. F., and R. A. Ward. 2005. Identification and geographical distribution of the mosquitos of North Ame"| __truncated__ ...
    ##  $ infraclass              : logi  NA NA NA NA NA NA ...
    ##  $ infraorder              : logi  NA NA NA NA NA NA ...
    ##  $ subclass                : logi  NA NA NA NA NA NA ...
    ##  $ suborder                : logi  NA NA NA NA NA NA ...
    ##   [list output truncated]

This table contains information about mosquito taxonomy as well as the native
status of each mosquito species in the data frame.

* metadata about the subsampling event, includes:
  + `scientificName`: the Scientific name of each species found in a subsample
  + `d##NativeStatusCode`: an indicator of whether a species is native to 
     each domain
     
SHOULD I ALSO ADD IN THE DOMAIN, PRECIP, AND TEMP TABLES HERE?

HOW SHOULD I TALK ABOUT THE SOURCE FUNCTION


## Wrangling the Data

### Obtaining location information

Before we can begin analyzing our data frames, we need to create a few new 
variables and collect all the information we need into a unified usable 
dataframe. To start, we will be extracting latitude and longitude information 
from NEON's application programming interfaces. 


    # Create a vector of unique plotIDs from the trap dataframe to speed up the data scraping process
    uniquePlotIDs <- unique(trap$plotID)
    
    source('NEON-mosquito-data-viz/get_NEON_location.R')
    
    # Use the lapply() to create a list where each element is a single plotID with GPS data
    latlon <- lapply(uniquePlotIDs, get_NEON_location, output="latlon")

Once we have the vector of unique plot IDs, we then use the lapply command to go
through each element of uniquePlotIDs, apply the get_NEON_location function, and
return a list of unique plot IDs paired with its corresponding location 
information.


    # Convert list into a data frame with the do.call function
    latlon.df <- do.call(rbind, latlon)
    
    # Match the names of your columns in this dataframe to other dataframes
    names(latlon.df) <- c("uniquePlotIDs", "lat", "lon", "northing", "easting", "utmZone", "elevation", "NLCDclass") 
    
    # Removing datapoints with latitude or longitude listed as 1, not a viable sampling location
    latlon.df[latlon.df==1]<-NA

Next we need to put together the location and plot identification information 
with our trapping data. To achieve this goal, we will use the merge command to 
match each plot ID in our latlon data frame to a plot ID in the trap data set.
The merge command allows users to match rows of separate dataframes by certain
key variables (in this case by plot ID) to create one unified data frame. For 
more information on the merge function, please see INSERT WEBSITE


    # Merging trap data with latitude and  longitude data
    trap <- merge(x = latlon.df, y = trap, by.x = "uniquePlotIDs", by.y = "plotID") 

Once we are done merging our two data frames, we might notice that there is
still a lot of missing latitude and longitude information (NEED TO INCLUDE WHY
THIS IS???) However for some rows in our trapping dataset the variables
pdaDecimalLatitude and pdaDecimalLongitude have location information that was
not present in our latlon data frame. So we use an if-else statement to collect
all of our latitude and longitude information into two more complete variables.


    # Filling in more latitude and longitude data
    trap$lat2<-ifelse(is.na(trap$lat)==TRUE, trap$pdaDecimalLatitude,trap$lat)
    
    trap$lon2<-ifelse(is.na(trap$lon)==TRUE, trap$pdaDecimalLongitude,trap$lon)

The next step in our data cleaning process is to consolidate all of the 
information stored in the trapping, identification, and sorting data frames. 
A lot of the information in the sorting data frame is very similar to what is
found in the identification data frame. But, one key difference is that the 
sorting data frame also contains the weight of the subsample, the weight of the 
bycatch, and the total weight of the sample. So we want to only select the 
columns in the sorting data frame that aren't in the id data frame.


    # Create a vector of column names that are in sort but not in id
    cols = colnames(sort)[!colnames(sort)%in%colnames(id)]
    
    # Merge id with subsetted sorting data frame
    id <- left_join(id, sort[, c('subsampleID', cols)], 
                    by = "subsampleID")

If we want to then merge our id data frame with the information in trap, we 
first have to simplify the trap data to lower processing times. We do that by
selecting only the rows of our trap data frame that are unique, and omitting any
rows that have repeated Plot IDs. 


    #Creating a dataframe with only the unique plotIDs and lat2 lon2 data for merging
    uniquetrap<-trap[!duplicated(trap[,1]),c("uniquePlotIDs","lat2","lon2", "elevation","NLCDclass")]
    
    #Merging id df with lat2 lon2 data
    id <- merge(x = uniquetrap, y = id, by.y = "plotID", by.x = "uniquePlotIDs", all.y = TRUE)

One thing to keep in mind is that the identification and sorting data frames 
only contain samples where the mosquitoes were present. However, we might also
be interested in analyzing the samples where mosquitoes were not present. So we
need to find the rows in the trap data frame where the plot ID is not in the
id data frame and the target taxon is not present. First we create a subset of
the trap data frame where mosquitoes were not found in the sample. Since we 
want to then merge these rows with those in our id data frame we add in columns
that are present in the id dataframe but not in the trap data frame and row-bind
these two data frames together.


    # Get zero traps from trapping
    new_trap<- trap[!trap$sampleID %in% id$sampleID & trap$targetTaxaPresent=="N",]
    
    #Add columns in new_trap that weren't present in the ID table then add new_trap to ID table
    new_trap <- new_trap[, colnames(new_trap)[colnames(new_trap)%in%colnames(id)]]
    
    new_trap[, colnames(id)[!colnames(id)%in%colnames(new_trap)]]<-NA
    
    id <- rbind(id,new_trap)

###Creating Variables and Obtaining Weather Data 

Now that we have a more complete id data set, we want to create a couple of 
variables that could be useful in our analysis as well as obtain weather data
from the National Oceanic and Atmospheric Administration (NOAA). To start, we 
will note that the individual count present in each observation of the id data
frame is only the individual count of each subsample. So to estimate the 
number of individuals in each sample we will use the sample weight,
by-catch weight, and subsample weight to generate a sample multiplier. To 
create the sample multiplier we use an if-else statement to find only the rows
in the id dataframe where by-catch weight information is present. Then we divide
the total sample weight by the by-catch weight subtracted from the subsample
weight. Next we use another if-else statement to replace all instances where
the sample multiplier is infinity with NAs. We then create a new variable called
'newindividualCount'where we multiply the individual count by the sample
multiplier.


    #Creation of sample Multiplier
    id$sampleMultiplier <- ifelse(is.na(id$bycatchWeight), id$totalWeight/id$subsampleWeight, id$totalWeight/(id$subsampleWeight-id$bycatchWeight))
    id$sampleMultiplier <- ifelse(id$sampleMultiplier==Inf, NA, id$sampleMultiplier)
    id$sampleMultiplier <- ifelse(id$subsampleWeight==0 & id$individualCount != 0, 1, id$sampleMultiplier)
    
    #Creation of New individual Count with Multiplier
    id$newindividualCount <-ifelse(is.na(id$sampleMultiplier)==F, round(id$individualCount*id$sampleMultiplier), NA)

Now that we have an estimate of the abundance of each species in a sample, we
also want to create a variable that takes into account the amount of time a 
trap was deployed. One issue present with creating this variable is that traps 
were either deployed overnight or collected within the space of one day. To
address this challenge, we first create a variable that returns true if the 
set date and the collect date are on the same day. Next we create two variables
that converts the minutes of the set and collect times into hours. After that, 
we use an if-else statement to find observations where set and collection dates
were on the same day, then we subtract the set hours from the collection hours
to get the number of hours that the trap was deployed. If the trap was deployed
over the period of two days, we calculate the number of hours from when the trap
was set until midnight by subtracting the set time from 24, then added the
number of hours the trap was deployed on the collect day to yield the hours of 
deployment. 


    #Creation of a variable to test whether samples were collected on the same day or different days
    id$sameDay <- ifelse(substr(id$collectDate, 9, 10) != substr(id$setDate,9,10), FALSE, TRUE)
    
    #Creating variables that convert the time of set and collection to hours
    id$setHours <-((as.numeric(substr(id$setDate,15,16))/60)+(as.numeric(substr(id$setDate,12,13))))
    id$collectHours <-((as.numeric(substr(id$collectDate,15,16))/60)+(as.numeric(substr(id$collectDate,12,13))))
    
    #variable to calculate the number of hours of trap deployment
    id$HoursOfTrapping <-ifelse(id$sameDay == TRUE, id$collectHours - id$setHours, (24 - id$setHours) + id$collectHours)
    
    #Changing hours of trapping to positive number 
    id$HoursOfTrapping <- abs(as.numeric(id$HoursOfTrapping))

In our current id data frame, we have only the set and collect dates of each 
sample, where the collect date and time is formatted as "YYYY-MM-DDThh:mm".
However, if we want to look at the Julian date of observation for Culex 
tarsalis, we might want the date and year when the sample was collected. So we 
use the 'substr' command to collect only the first four characters of the
'collectDate' variable to pull year information, then we convert year to a 
factor. However, in the id data frame there are some observations where the 
collection date was not available. For many of the observations where 
collection information is missing, the date of when the sample was recieved so
we can extract year information in a similar fashion from the 'recievedDate' 
variable. 


    #Extracting year information for id
    id$Year<-substr(id$collectDate,1,4)
    
    #Extracting year information for id from both collect date and recieved date
    id$receivedDate <- as.character(id$receivedDate)
    
    id$Year<-ifelse(is.na(id$collectDate), substr(id$receivedDate,1,4), substr(id$collectDate,1,4))
    
    #Exctracting date information for id
    id$Date<-substr(id$collectDate,1,10)

Our next objective is to obtain weather information for each day in our data set.
The data in our temperature data frame ('temp.df') and precipitation data frame
('precip.df') can be related to our NEON mosquito data by date and by proximity 
to NEON sample sites. So first we convert the date in the temperature and 
precipitation data frames to the variable type 'Date'. Next we find
the site of each sample by taking the first four characters of each plot ID, and
then merge the id data frame first with the temperature data frame by 'siteID' 
and 'Date'. Now our data frame is nicely integrated, but we need to fix the 
units of our maximum temperature variable by dividing each number in the column 
called 'value' by ten. Then for clarity we rename the variable 'value' as 
'Max.TempC'. We then repeat this process for our precipitation data. 


    #Change temp date type
    temp.df$date <- as.Date(temp.df$date)
    
    #Broad Site ID variable 
    id$siteID<-substr(id$uniquePlotIDs,1,4)
    
    #merging id with temp data
    id <- merge(x = temp.df, y = id, by.y = c('siteID','Date'), by.x = c('siteID','date'), all.y = TRUE)
    
    #Converting temperature to proper value
    id$value<-id$value/10
    names(id)[5]<-"Max.TempC"
    
    #Change precip date type
    precip.df$date <- as.Date(precip.df$date)
    
    #Merge id with precip data
    id <- merge(x = precip.df[,c(1,4,9)], y = id, by.y = c('siteID', 'date'), by.x = c('siteID', 'date'), all.y = TRUE)
    
    #converting temperature to proper value and renaming
    id$value<-id$value/10
    names(id)[3]<-"Precipmm"

### Finishing Touches and Filtering Data

Now that we have location and weather information in a more usable format we
are almost ready to start analyzing our NEON data. However we need to add domain
and taxon rank information to our data frames so we can track changes in
mosquito ranges and filter out missing data.


    #Merge with domain info.
    id <- merge(x = domain.df, y = id, by.y = "siteID", by.x = "siteid", all.y = TRUE)
    
    id$domainid <- as.character(id$domainid)
    
    #Merge with taxonomy df for taxson rank
    id <- merge( x = taxonomy[,c("scientificName", "taxonRank")], y = id, by.x = "scientificName", by.y = "scientificName")

Speaking of missing data, a quick exploration of our resulting identification
data frame might reveal that the number of mosquito observations fluctuate 
greatly for the years 2012, 2013, and 2015. This is because of changes in 
sampling design, making the observations for these years less comparable to 
2014 and 2016. Due to the changes in sampling design for mosquito collection,
we will continue on with our analysis and focus in on the data from 2014 and
2016. We will also filter our existing data by taxon rank. We choose to filter 
out any observations in our data that are not identified down to the species or
subspecies level so we can get a better idea of species richness and find 
samples where *Culex tarsalis* was present.


    #Filter by species and subspecies classification
    id <- dplyr::filter(id, id$taxonRank %in% c("subspecies","species"))
    
    #smalle subset only containing 2014 and 2016
    idsmall<-dplyr::filter(id, id$Year %in% c(2014,2016))

