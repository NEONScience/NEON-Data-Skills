---
title: "Explore and work with NEON biodiversity data from aquatic ecosystems"
code1: R/SFS-2020/01_working_with_NEON_macroinverts.R
contributors: Donal O'Leary
output:
  html_document:
    df_print: paged
dateCreated: '2020-06-22'
description: Download and explore NEON macroinvertebrate data. This includes instruction
  on how to convert to long and wide tables, as well as an exploration of alpha, beta,
  and gamma diversity from Jost (2007).
estimatedTime: 1 Hour
languagesTool: R
dataProduct: null
packagesLibraries: tidyverse, neonUtilities, vegan, vegetarian
syncID: e0778998a7ea4b7c93da38a364d12a65
authors: Eric R. Sokol
topics: null
tutorialSeries: null
urlTitle: aquatic-diversity-macroinvertebrates
---

<div id="ds-objectives" markdown="1">

## Learning Objectives 
After completing this tutorial you will be able to: 

* Download NEON macroinvertebrate data.
* Organize those data into long and wide tables.
* Calculate alpha, beta, and gamma diversity following Jost (2007).

## Things You’ll Need To Complete This Tutorial

### R Programming Language
You will need a current version of R to complete this tutorial. We also recommend 
the RStudio IDE to work with R. 

### R Packages to Install
Prior to starting the tutorial ensure that the following packages are installed. 

* **tidyverse:** `install.packages("tidyverse")`
* **neonUtilities:** `install.packages("neonUtilities")`
* **vegan:** `install.packages("vegan")`
* **vegetarian:** `install.packages("vegetarian")`

<a href="/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

</div>

## Introduction
Biodiversity is an popular topic within ecology, but quantifying and describing biodiversity precisely can be elusive. In this tutorial, we will describe many of the aspects of biodiversity using NEON's <a href="https://data.neonscience.org/data-products/DP1.20120.001">Macroinvertebrate Collection data</a>.

This tutorial was prepared for the <a href="https://freshwater-science.org/sfs-summer-science"> Society for Freshwater Science 2020 "Summer of Science" </a> program.

## Load Libraries and Prepare Workspace
First, we will load all necessary libraries into our R environment. If you have not already installed these libraries, please see the 'R Packages to Install' section above.

There are also two optional sections in this code chunk: clearing your environment, and loading your NEON API token. Clearning out your environment will erase _all_ of the variables and data that are currently loaded in your R session. This is a good practice for many reasons, but only do this if you are completely sure that you won't be losing any important information! Secondly, your NEON API token will allow you increased download speeds, and helps NEON __anonymously__ track data usage statistics, which helps us optimize our data delivery platforms, and informs our monthly and annual reporting to our funding agency, the National Science Foundation. Please consider signing up for a NEON data user account, and using your token <a href="https://www.neonscience.org/neon-api-tokens-tutorial">as described in this tutorial here</a>.


    # clean out workspace
    
    #rm(list = ls()) # OPTIONAL - clear out your environment
    #gc()            # Uncomment these lines if desired
    
    # load libraries 
    library(tidyverse)
    library(neonUtilities)
    
    
    # source .r file with my NEON_TOKEN
    # source("my_neon_token.R") # OPTIONAL - load NEON token
    # See: https://www.neonscience.org/neon-api-tokens-tutorial

## Download NEON Macroinvertebrate Data
Now that the workspace is prepared, we will download NEON macroinvertebrate data using the neonUtilities function `loadByProduct()`.


    # Macroinvert dpid
    my_dpid <- 'DP1.20120.001'
    # list of sites
    my_site_list <- c('ARIK', 'POSE', 'MAYF')
    # get all tables for these sites from the API -- takes < 1 minute
    all_tabs_inv <- neonUtilities::loadByProduct(
      dpID = my_dpid,
      site = my_site_list,
      #token = NEON_TOKEN, #Uncomment to use your token
      check.size = F)

    ## Finding available files
    ##   |                                                                                          |                                                                                  |   0%  |                                                                                          |=                                                                                 |   2%  |                                                                                          |===                                                                               |   3%  |                                                                                          |====                                                                              |   5%  |                                                                                          |======                                                                            |   7%  |                                                                                          |=======                                                                           |   8%  |                                                                                          |========                                                                          |  10%  |                                                                                          |==========                                                                        |  12%  |                                                                                          |===========                                                                       |  14%  |                                                                                          |=============                                                                     |  15%  |                                                                                          |==============                                                                    |  17%  |                                                                                          |===============                                                                   |  19%  |                                                                                          |=================                                                                 |  20%  |                                                                                          |==================                                                                |  22%  |                                                                                          |===================                                                               |  24%  |                                                                                          |=====================                                                             |  25%  |                                                                                          |======================                                                            |  27%  |                                                                                          |========================                                                          |  29%  |                                                                                          |=========================                                                         |  31%  |                                                                                          |==========================                                                        |  32%  |                                                                                          |============================                                                      |  34%  |                                                                                          |=============================                                                     |  36%  |                                                                                          |===============================                                                   |  37%  |                                                                                          |================================                                                  |  39%  |                                                                                          |=================================                                                 |  41%  |                                                                                          |===================================                                               |  42%  |                                                                                          |====================================                                              |  44%  |                                                                                          |======================================                                            |  46%  |                                                                                          |=======================================                                           |  47%  |                                                                                          |========================================                                          |  49%  |                                                                                          |==========================================                                        |  51%  |                                                                                          |===========================================                                       |  53%  |                                                                                          |============================================                                      |  54%  |                                                                                          |==============================================                                    |  56%  |                                                                                          |===============================================                                   |  58%  |                                                                                          |=================================================                                 |  59%  |                                                                                          |==================================================                                |  61%  |                                                                                          |===================================================                               |  63%  |                                                                                          |=====================================================                             |  64%  |                                                                                          |======================================================                            |  66%  |                                                                                          |========================================================                          |  68%  |                                                                                          |=========================================================                         |  69%  |                                                                                          |==========================================================                        |  71%  |                                                                                          |============================================================                      |  73%  |                                                                                          |=============================================================                     |  75%  |                                                                                          |===============================================================                   |  76%  |                                                                                          |================================================================                  |  78%  |                                                                                          |=================================================================                 |  80%  |                                                                                          |===================================================================               |  81%  |                                                                                          |====================================================================              |  83%  |                                                                                          |=====================================================================             |  85%  |                                                                                          |=======================================================================           |  86%  |                                                                                          |========================================================================          |  88%  |                                                                                          |==========================================================================        |  90%  |                                                                                          |===========================================================================       |  92%  |                                                                                          |============================================================================      |  93%  |                                                                                          |==============================================================================    |  95%  |                                                                                          |===============================================================================   |  97%  |                                                                                          |================================================================================= |  98%  |                                                                                          |==================================================================================| 100%
    ## 
    ## Downloading files totaling approximately 2.541651 MB
    ## Downloading 59 files
    ##   |                                                                                          |                                                                                  |   0%  |                                                                                          |=                                                                                 |   2%  |                                                                                          |===                                                                               |   3%  |                                                                                          |====                                                                              |   5%  |                                                                                          |======                                                                            |   7%  |                                                                                          |=======                                                                           |   9%  |                                                                                          |========                                                                          |  10%  |                                                                                          |==========                                                                        |  12%  |                                                                                          |===========                                                                       |  14%  |                                                                                          |=============                                                                     |  16%  |                                                                                          |==============                                                                    |  17%  |                                                                                          |================                                                                  |  19%  |                                                                                          |=================                                                                 |  21%  |                                                                                          |==================                                                                |  22%  |                                                                                          |====================                                                              |  24%  |                                                                                          |=====================                                                             |  26%  |                                                                                          |=======================                                                           |  28%  |                                                                                          |========================                                                          |  29%  |                                                                                          |=========================                                                         |  31%  |                                                                                          |===========================                                                       |  33%  |                                                                                          |============================                                                      |  34%  |                                                                                          |==============================                                                    |  36%  |                                                                                          |===============================                                                   |  38%  |                                                                                          |=================================                                                 |  40%  |                                                                                          |==================================                                                |  41%  |                                                                                          |===================================                                               |  43%  |                                                                                          |=====================================                                             |  45%  |                                                                                          |======================================                                            |  47%  |                                                                                          |========================================                                          |  48%  |                                                                                          |=========================================                                         |  50%  |                                                                                          |==========================================                                        |  52%  |                                                                                          |============================================                                      |  53%  |                                                                                          |=============================================                                     |  55%  |                                                                                          |===============================================                                   |  57%  |                                                                                          |================================================                                  |  59%  |                                                                                          |=================================================                                 |  60%  |                                                                                          |===================================================                               |  62%  |                                                                                          |====================================================                              |  64%  |                                                                                          |======================================================                            |  66%  |                                                                                          |=======================================================                           |  67%  |                                                                                          |=========================================================                         |  69%  |                                                                                          |==========================================================                        |  71%  |                                                                                          |===========================================================                       |  72%  |                                                                                          |=============================================================                     |  74%  |                                                                                          |==============================================================                    |  76%  |                                                                                          |================================================================                  |  78%  |                                                                                          |=================================================================                 |  79%  |                                                                                          |==================================================================                |  81%  |                                                                                          |====================================================================              |  83%  |                                                                                          |=====================================================================             |  84%  |                                                                                          |=======================================================================           |  86%  |                                                                                          |========================================================================          |  88%  |                                                                                          |==========================================================================        |  90%  |                                                                                          |===========================================================================       |  91%  |                                                                                          |============================================================================      |  93%  |                                                                                          |==============================================================================    |  95%  |                                                                                          |===============================================================================   |  97%  |                                                                                          |================================================================================= |  98%  |                                                                                          |==================================================================================| 100%
    ## 
    ## Unpacking zip files using 1 cores.
    ## Stacking operation across a single core.
    ## Stacking table inv_fieldData
    ## Stacking table inv_persample
    ## Stacking table inv_taxonomyProcessed
    ## Copied the most recent publication of validation file to /stackedFiles
    ## Copied the most recent publication of categoricalCodes file to /stackedFiles
    ## Copied the most recent publication of variable definition file to /stackedFiles
    ## Finished: Stacked 3 data tables and 3 metadata tables!
    ## Stacking took 1.438413 secs
    ## All unzipped monthly data folders have been removed.

## Macroinvertebrate Data Munging
Now that we have the data downloaded, we will need to do some 'data munging' to reorganize our data into a more useful format for this analysis. First, let's take a look at some of the tables that were generated by `loadByProduct()`:


    # what tables do you get with macroinvertebrate 
    # data product
    names(all_tabs_inv)

    ## [1] "categoricalCodes_20120" "inv_fieldData"          "inv_persample"         
    ## [4] "inv_taxonomyProcessed"  "readme_20120"           "validation_20120"      
    ## [7] "variables_20120"

    # extract items from list and put in R env. 
    all_tabs_inv %>% list2env(.GlobalEnv)

    ## <environment: R_GlobalEnv>

    # readme has the same informaiton as what you 
    # will find on the landing page on the data portal
    
    # The variables file describes each field in 
    # the returned data tables
    head(variables_20120)

    ##            table        fieldName
    ## 1: inv_fieldData              uid
    ## 2: inv_fieldData         domainID
    ## 3: inv_fieldData           siteID
    ## 4: inv_fieldData    namedLocation
    ## 5: inv_fieldData  decimalLatitude
    ## 6: inv_fieldData decimalLongitude
    ##                                                                                            description
    ## 1:                                        Unique ID within NEON database; an identifier for the record
    ## 2:                                                                Unique identifier of the NEON domain
    ## 3:                                                                                      NEON site code
    ## 4:                                               Name of the measurement location in the NEON database
    ## 5:  The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area
    ## 6: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area
    ##    dataType         units downloadPkg       pubFormat primaryKey categoricalCodeName
    ## 1:   string          <NA>       basic            asIs          N                    
    ## 2:   string          <NA>       basic            asIs          N                    
    ## 3:   string          <NA>       basic            asIs          N                    
    ## 4:   string          <NA>       basic            asIs          N                    
    ## 5:     real decimalDegree       basic *.######(round)          N                    
    ## 6:     real decimalDegree       basic *.######(round)          N

    # The validation file provides the rules that 
    # constrain data upon ingest into the NEON database:
    head(validation_20120)

    ##            table           fieldName
    ## 1: inv_fielddata                 uid
    ## 2: inv_fielddata          locationID
    ## 3: inv_fielddata     aquaticSiteType
    ## 4: inv_fielddata           startDate
    ## 5: inv_fielddata         collectDate
    ## 6: inv_fielddata samplingImpractical
    ##                                                                         description
    ## 1:                     Unique ID within NEON database; an identifier for the record
    ## 2:                               Identifier for location where sample was collected
    ## 3:                             Type of aquatic site, includes lake, river or stream
    ## 4:                   The start date-time or interval during which an event occurred
    ## 5:                                                     Date of the collection event
    ## 6: Samples and/or measurements were not collected due to the indicated circumstance
    ##    dataType units                  parserToCreate
    ## 1:   string  <NA>                    [CREATE_UID]
    ## 2:   string  <NA>                                
    ## 3:   string  <NA>                                
    ## 4: dateTime  <NA>          [collectDate][REQUIRE]
    ## 5: dateTime  <NA> [CONVERT_TO_UTC(namedLocation)]
    ## 6:   string  <NA>                                
    ##                                                                                                                                                                               entryValidationRulesParser
    ## 1:                                                                                                                                                                                                      
    ## 2: [NAMED_LOCATION_TYPE('AOS outlet named location type' OR 'AOS inlet named location type' OR 'AOS buoy named location type' OR 'AOS reach named location type' OR 'AOS riparian named location type')]
    ## 3:                                                                                                                                                                                                 [LOV]
    ## 4:                                                                                                                                                                                                      
    ## 5:                                                                                                                                                                                                      
    ## 6:                                                                                                                                                                                                 [LOV]
    ##                                                                                                                                                                                                                                                                                                                                                                                      entryValidationRulesForm
    ## 1:                                                                                                                                                                                                                                                                                                                                                                                                   [HIDDEN]
    ## 2: [REQUIRE][FROM_AOS_SPATIAL(IF(siteType='lake'),  AOS outlet named location type OR AOS inlet named location type OR AOS buoy named location type OR AOS riparian named location type)][FROM_AOS_SPATIAL(IF(siteType='stream'), AOS reach named location type)][FROM_AOS_SPATIAL(IF(siteType='river'),  AOS buoy named location type OR AOS riparian named location type OR AOS reach named location type)]
    ## 3:                                                                                                                                                                                                                                                                                                                                                                                                           
    ## 4:                                                                                                                                                                                                                                                                                                                                                                          [DEFAULT_TO(collectDate)][HIDDEN]
    ## 5:                                                                                                                                                                                                                                                                                                                             [DATE_FORMAT('YYYY-MM-DDTHH:MM')][REQUIRE][LESS_THAN_OR_EQUAL_TO (NOW + 24hr)]
    ## 6:

    # the categoricalCodes file provides controlled 
    # lists used in the data
    head(categoricalCodes_20120)

    ##                   name                                 pubCode
    ## 1:     aquaticSiteType                                    lake
    ## 2:     aquaticSiteType                                  stream
    ## 3:     aquaticSiteType                                   river
    ## 4: biophysicalCriteria                OK - no known exceptions
    ## 5: biophysicalCriteria OK - schedule change but conditions met
    ## 6: biophysicalCriteria                      conditions not met
    ##                                                                                            description
    ## 1:                                                                                                lake
    ## 2:                                                                                              stream
    ## 3:                                                                                               river
    ## 4:                                                      Sampling occurred on schedule, no known issues
    ## 5: Sampling occurred not within defined sampling window but reflects the target biophysical conditions
    ## 6:                                         Sampling does not reflect the target biophysical conditions
    ##     startDate endDate
    ## 1: 2012-01-01    <NA>
    ## 2: 2012-01-01    <NA>
    ## 3: 2012-01-01    <NA>
    ## 4: 2012-01-01    <NA>
    ## 5: 2012-01-01    <NA>
    ## 6: 2012-01-01    <NA>

Next, we will perform several operations in a row to re-organize our data. Each step is described by a code comment.


    # extract location data into a separate table
    table_location <- inv_fieldData %>%
      
    # group by columns with site location information
      group_by(siteID, 
             domainID,
             namedLocation, 
             decimalLatitude, 
             decimalLongitude, 
             elevation)%>% 
    
      # this will return a summary table with 1 row per site 
    table_location

    ## Error in table_location(.): could not find function "table_location"

    # create a taxon table, which describes each 
    # taxonID that appears in the data set
    # start with inv_taxonomyProcessed
    
    table_taxon <- inv_taxonomyProcessed %>%
    
      # keep only the coluns listed below
      select(order, family, genus, scientificName, acceptedTaxonID, taxonRank, identificationQualifier,
             identificationReferences) %>% 
      
      # remove rows with duplicate information
            distinct() %>%
      # sort table by taxonomic hierarchy
            arrange(order, family, genus, scientificName)
    
    head(table_taxon)

    ##            order         family     genus  scientificName acceptedTaxonID taxonRank
    ## 1     Actinedida    Limnesiidae  Tyrellia    Tyrellia sp.          TYRSP1     genus
    ## 2  Aeolosomatida Aeolosomatidae Aeolosoma   Aeolosoma sp.          AEOSP2     genus
    ## 3      Amphipoda     Gammaridae      <NA>  Gammaridae sp.          GAMSP1    family
    ## 4      Amphipoda    Hyalellidae  Hyalella    Hyalella sp.          HYASP2     genus
    ## 5 Anthoathecatae       Hydridae     Hydra Hydra americana         HYDAME2   species
    ## 6 Anthoathecatae       Hydridae     Hydra       Hydra sp.         HYDSP21     genus
    ##   identificationQualifier     identificationReferences
    ## 1                    <NA>        Thorp and Rogers 2016
    ## 2                    <NA> Kathman and Brinkhurst, 1999
    ## 3                    <NA>        Thorp and Covich 2001
    ## 4                    <NA>        Thorp and Covich 2001
    ## 5                    <NA>                   Smith 2001
    ## 6                    <NA>        Thorp and Covich 2001

    # taxon table information for all taxa in 
    # our database can be downloaded here:
    # takes 1-2 minutes
    # full_taxon_table_from_api <- neonUtilities::getTaxonTable("MACROINVERTEBRATE", token = NEON_TOKEN)
    
    
    # start with inv_taxonomyProcessed
    table_observation <- inv_taxonomyProcessed %>% 
      
      # select a subset of columns from
      # inv_taxonomyProcessed
      select(uid,
             sampleID,
             domainID,
             siteID,
             namedLocation,
             collectDate,
             subsamplePercent,
             individualCount,
             estimatedTotalCount,
             acceptedTaxonID,
             order, family, genus, 
             scientificName,
             taxonRank) %>%
      
      # Join the columns selected above with
      # the inv_fieldData table. These will join 
      # based on the common variable 'sampleID'
      left_join(inv_fieldData %>% 
                  select(sampleID, eventID,
                         habitatType, substratumSizeClass, samplerType,
                         benthicArea)) %>%
      
      # Create new variables:
      # Adjust invt counts for benthic area of the sampler to get invt density with comparable units
      # Extract year from date 
      mutate(inv_dens = estimatedTotalCount / benthicArea,
             inv_dens_unit = 'count per square meter',
              year = collectDate %>% 
                 lubridate::as_date() %>% 
                  lubridate::year())
    
    head(table_observation)[,-1] # hides the uid column for viewing purposes 

    ##                 sampleID domainID siteID  namedLocation         collectDate
    ## 1 POSE.20140722.SURBER.1      D02   POSE POSE.AOS.reach 2014-07-22 13:10:00
    ## 2 POSE.20140722.SURBER.1      D02   POSE POSE.AOS.reach 2014-07-22 13:10:00
    ## 3 POSE.20140722.SURBER.1      D02   POSE POSE.AOS.reach 2014-07-22 13:10:00
    ## 4 POSE.20140722.SURBER.1      D02   POSE POSE.AOS.reach 2014-07-22 13:10:00
    ## 5 POSE.20140722.SURBER.1      D02   POSE POSE.AOS.reach 2014-07-22 13:10:00
    ## 6 POSE.20140722.SURBER.1      D02   POSE POSE.AOS.reach 2014-07-22 13:10:00
    ##   subsamplePercent individualCount estimatedTotalCount acceptedTaxonID         order
    ## 1                8               2                  24          STEFEM Ephemeroptera
    ## 2                8               1                  12           BAESP Ephemeroptera
    ## 3                8               1                  12          PERSP1    Plecoptera
    ## 4                8              16                 193          CHESP5   Trichoptera
    ## 5                8               2                  24          CHESP5   Trichoptera
    ## 6                8               2                  24          LEUSP8    Plecoptera
    ##           family          genus      scientificName taxonRank       eventID habitatType
    ## 1  Heptageniidae      Stenonema Stenonema femoratum   species POSE.20140722      riffle
    ## 2       Baetidae           <NA>        Baetidae sp.    family POSE.20140722      riffle
    ## 3       Perlidae           <NA>        Perlidae sp.    family POSE.20140722      riffle
    ## 4 Hydropsychidae Cheumatopsyche  Cheumatopsyche sp.     genus POSE.20140722      riffle
    ## 5 Hydropsychidae Cheumatopsyche  Cheumatopsyche sp.     genus POSE.20140722      riffle
    ## 6     Leuctridae        Leuctra         Leuctra sp.     genus POSE.20140722      riffle
    ##   substratumSizeClass samplerType benthicArea  inv_dens          inv_dens_unit year
    ## 1              cobble      surber       0.093  258.0645 count per square meter 2014
    ## 2              cobble      surber       0.093  129.0323 count per square meter 2014
    ## 3              cobble      surber       0.093  129.0323 count per square meter 2014
    ## 4              cobble      surber       0.093 2075.2688 count per square meter 2014
    ## 5              cobble      surber       0.093  258.0645 count per square meter 2014
    ## 6              cobble      surber       0.093  258.0645 count per square meter 2014

    # extract sample info
    table_sample_info <- table_observation %>%
      select(sampleID, domainID, siteID, namedLocation, 
             collectDate, eventID, year, 
             habitatType, samplerType, benthicArea, 
             inv_dens_unit) %>%
      distinct()
    
    # create a summary of sampling effort associated with taxonomic data
    sampling_effort_summary <- table_sample_info %>%
      
      # group by siteID, year and sampler 
      group_by(siteID, year, samplerType) %>%#, habitatType) %>%
      
      # count events, samples and habitat types within each event
      summarise(
        event_count = eventID %>% unique() %>% length(),
        sample_count = sampleID %>% unique() %>% length(),
       habitat_count = habitatType %>% unique() %>% length())
    
    View(sampling_effort_summary) # This shows how many samples were returned from the taxonomy lab, compare with inv_fieldData to
                                  # determine if taxonomy data are present from all samples. 
    
    
    # create an occurrence summary table:  number of samples across all sites in which each taxa was present
    taxa_occurrence_summary <- table_observation %>%
      select(sampleID, acceptedTaxonID) %>%
      distinct() %>%  
      group_by(acceptedTaxonID) %>%
      summarise(occurrences = n())
    
      # filter out taxa that are only observed 1 or 2 times
      taxa_list_cleaned <- taxa_occurrence_summary %>%
        filter(occurrences > 2)
    
      # filter observation table based on taxon list above to remove rare/uncommon occurrences
      # this is the table we will use for exploratory analysis
      table_observation_cleaned <- table_observation %>%
       filter(acceptedTaxonID %in%
                 taxa_list_cleaned$acceptedTaxonID,
               !sampleID %in% c("MAYF.20190729.CORE.1",
                              "POSE.20160718.HESS.1")) #these are outlier sampleIDs

## Working with 'Long' data
'Reshaping' your data to use as an input to a particular fuction may require you to consider: do I want 'long' or 'wide' data? Here's a link to <a href="https://www.theanalysisfactor.com/wide-and-long-data/">a great article from 'the analysis factor' that describes the differences</a>.

For this first step, we will use data in a 'long' table:


    # create ordered factor for taxon rank 
    table_observation_cleaned$taxonRank <- factor(table_observation_cleaned$taxonRank, levels = c('species','speciesGroup','subgenus','genus','tribe','subfamily','family','suborder','order','subclass','class','phylum'))
    
    # no. taxa by rank by site
    table_observation_cleaned %>% 
      group_by(domainID, siteID, taxonRank) %>%
      summarise(
        n_taxa = acceptedTaxonID %>% 
          unique() %>% length()) %>%
      ggplot(aes(n_taxa, taxonRank)) +
      facet_wrap(~ domainID + siteID) +
      geom_col()

![ ]({{ site.baseurl }}/images/rfigs/R/SFS-2020/01_working_with_NEON_macroinverts/long-data-1.png)

    # library(scales)
    # sum densities by order for each sampleID
    table_observation_by_order <- 
        table_observation_cleaned %>% 
        filter(!is.na(order)) %>%
        group_by(domainID, siteID, year, 
                 eventID, sampleID, habitatType, order) %>%
        summarise(order_dens = sum(inv_dens, na.rm = TRUE))
      
      
    # rank occurrence by order (# of samples in which order was present)
    table_observation_by_order %>% head()

    ## # A tibble: 6 x 8
    ## # Groups:   domainID, siteID, year, eventID, sampleID, habitatType [2]
    ##   domainID siteID  year eventID      sampleID             habitatType order       order_dens
    ##   <chr>    <chr>  <dbl> <chr>        <chr>                <chr>       <chr>            <dbl>
    ## 1 D02      POSE    2014 POSE.201407… POSE.20140722.SURBE… riffle      Coleoptera       516. 
    ## 2 D02      POSE    2014 POSE.201407… POSE.20140722.SURBE… riffle      Ephemeropt…     5172. 
    ## 3 D02      POSE    2014 POSE.201407… POSE.20140722.SURBE… riffle      Odonata          129. 
    ## 4 D02      POSE    2014 POSE.201407… POSE.20140722.SURBE… riffle      Plecoptera      1290. 
    ## 5 D02      POSE    2014 POSE.201407… POSE.20140722.SURBE… riffle      Trichoptera     8839. 
    ## 6 D02      POSE    2014 POSE.201410… POSE.20141028.HESS.2 pool        Collembola        34.9

    # ordered list by occurrence
    order_rank <- table_observation_by_order %>% group_by(order)%>% 
      summarise(occurrence = (order_dens > 0) %>% sum()) %>%
      arrange(desc(occurrence))
      
    table_observation_by_order %>%
      group_by(siteID , order) %>%
      mutate(order = order %>% factor(levels = order_rank$order))%>%
      summarise(
        occurrence =  (order_dens > 0) %>% sum()) %>%# order_dens >0 is logical argument, sum() counts the number of 'TRUE' results
       ggplot()+ 
      geom_col(aes(
        x = order, 
        y = occurrence,
        color = siteID,
        fill = siteID)) + 
      theme_bw()+ theme(axis.text.x = 
              element_text(angle = 45, hjust = 1)) + 
      ggtitle("Rank occurrence by order")

![ ]({{ site.baseurl }}/images/rfigs/R/SFS-2020/01_working_with_NEON_macroinverts/long-data-2-1.png)

    # faceted densities plot by site
    table_observation_by_order %>%
      ggplot(aes(
        x = reorder(order, -order_dens), 
        y = log10(order_dens),
        color = siteID,
        fill = siteID)) +
      geom_boxplot(alpha = .5) +
      facet_grid(siteID ~ .) +
      theme(axis.text.x = 
                element_text(angle = 45, hjust = 1))+
       labs(y = "log of invt density (count/m2)",
                x = "Order",
                title = "Boxplot: Macroinvertebrate density by order")

![ ]({{ site.baseurl }}/images/rfigs/R/SFS-2020/01_working_with_NEON_macroinverts/long-data-3-1.png)


## Multiscale Biodiversity

### Reshape the data

For the next set of biodiversity analyses, we want to convert our data to a 'wide' format, where each row is a distinct sample, each column is a taxon ID and the cell values are invt density (count per square meter).  


    # select variables of interest:  site and species density info 
    table_sample_by_taxon_density_long <- table_observation_cleaned %>%
      select(sampleID, acceptedTaxonID, inv_dens) %>%
      distinct() %>%  # remove duplicate records
      filter(!is.na(inv_dens))
    
    # pivot to wide format, sum multiple counts per sampleID
    table_sample_by_taxon_density_wide <- table_sample_by_taxon_density_long %>%
      tidyr::pivot_wider(id_cols = sampleID, 
                         names_from = acceptedTaxonID,
                         values_from = inv_dens,
                         values_fill = list(inv_dens = 0),
                         values_fn = list(inv_dens = sum)) %>%
      column_to_rownames(var = "sampleID") 
    
    # check col and row sums
    # These should not be zero
    colSums(table_sample_by_taxon_density_wide) %>% min()

    ## [1] 28

    rowSums(table_sample_by_taxon_density_wide) %>% min()

    ## [1] 18.86792

### Multiscale Biodiversity

Reference:
Jost, L. 2007. Partitioning diversity into independent alpha and beta components. Ecology 88:2427–2439. <a href="https://doi.org/10.1890/06-1736.1">https://doi.org/10.1890/06-1736.1</a>.

These metrics are based on Robert Whittaker's multiplicative diversity where

- alpha is local biodiversity (e.g., the mean diversity at a patch)
- gamma is regional biodiversity
- and beta diversity is a measure of among-patch variability in community composition. 

Beta could be interpreted as the number of "distinct" communities present within the region.

The relationship among alpha, beta, and gamma diversity is:
   __beta = gamma / alpha__ 

The influence of relative abundances over the calculation of alpha, beta, and gamma diversity metrics is determined by the coefficient q. The coefficient "q" determines the "order" of the diversity metric, where q = 0 provides diversity measures based on richness, and higher orders of q give more weight to taxa that have higher abundances in the data. Order q = 1 is related to Shannon diveristy metrics, and order q = 2 is related to Simpson diversity metrics.

#### Alpha diversity is average local richness.
Order q = 0 alpha diversity calcuated for our dataset returns a mean local richness (i.e., species counts) of ~27 taxa per sample across the entire data set.


    table_sample_by_taxon_density_wide %>%
      vegetarian::d(lev = 'alpha', q = 0)

    ## [1] 27.74303

#### Comparing alpha diversity calculated using different orders:

Order q = 1 alpha diversity returns mean number of "species equivalents" per sample in the data set. This approach incoporates evenness because when abundances are more even across taxa, taxa are weighted more equally toward counting as a "species equivalent".  
For example, if you have a sample with 100 individuals evenly spread across 10 species (10 individuals per species) as in the first example below, the number of order q = 1 species equivalents will equal the richness (10).

Alternatively, if 90 of the 100 individuals in the sample are one species, and the other 10 individuals are spread across the other 9 species, there will only be 1.72 order q = 1 species equivalents, whereas, there are still 10 species in the sample (q=0). 


    # even distribution, order q = 0 diversity = 10 
    vegetarian::d(
      data.frame(spp.a = 10, spp.b = 10, spp.c = 10, 
                 spp.d = 10, spp.e = 10, spp.f = 10, 
                 spp.g = 10, spp.h = 10, spp.i = 10, 
                 spp.j = 10),
      q = 0, 
      lev = "alpha")

    ## [1] 10

    # even distribution, order q = 1 diversity = 10
    vegetarian::d(
      data.frame(spp.a = 10, spp.b = 10, spp.c = 10, 
                 spp.d = 10, spp.e = 10, spp.f = 10, 
                 spp.g = 10, spp.h = 10, spp.i = 10, 
                 spp.j = 10),
      q = 1, 
      lev = "alpha")

    ## [1] 10

    # un-even distribution, order q = 0 diversity = 10
    vegetarian::d(
      data.frame(spp.a = 90, spp.b = 2, spp.c = 1, 
                 spp.d = 1, spp.e = 1, spp.f = 1, 
                 spp.g = 1, spp.h = 1, spp.i = 1, 
                 spp.j = 1),
      q = 0, 
      lev = "alpha")

    ## [1] 10

    # un-even distribution, order q = 1 diversity = 1.72
    vegetarian::d(
      data.frame(spp.a = 90, spp.b = 2, spp.c = 1, 
                 spp.d = 1, spp.e = 1, spp.f = 1, 
                 spp.g = 1, spp.h = 1, spp.i = 1, 
                 spp.j = 1),
      q = 1, 
      lev = "alpha")

    ## [1] 1.718546

## Comparing orders of q for NEON data

Let's compare the orders q = 0 and q= 1 for the different levels of diversity across samples collected from ARIK, POSE, and MAYF.


    # Nest data by siteID
    data_nested_by_siteID <- table_sample_by_taxon_density_wide %>%
      tibble::rownames_to_column("sampleID") %>%
      left_join(table_sample_info %>% 
                    select(sampleID, siteID)) %>%
      tibble::column_to_rownames("sampleID") %>%
      nest(data = -siteID) # this uses siteID as grouping variable

    ## Joining, by = "sampleID"

    # apply richness calculation by site  
    data_nested_by_siteID %>% mutate(
      alpha_q0 = purrr::map_dbl(
        .x = data,
        .f = ~ vegetarian::d(abundances = .,
        lev = 'alpha', 
        q = 0)))

    ## # A tibble: 3 x 3
    ##   siteID data                 alpha_q0
    ##   <chr>  <list>                  <dbl>
    ## 1 POSE   <tibble [101 × 390]>     38.8
    ## 2 MAYF   <tibble [119 × 390]>     22.2
    ## 3 ARIK   <tibble [103 × 390]>     23.3

    # Note that POSE has the highest mean diversity
    
    
    
    # Now calculate alpha, beta, and gamma using orders 0 and 1,
    # Note that I don't make all the argument assignments as explicitly here
    diversity_partitioning_results <- 
        data_nested_by_siteID %>% 
        mutate(
            n_samples = purrr::map_int(data, ~ nrow(.)),
            alpha_q0 = purrr::map_dbl(data, ~vegetarian::d(
                abundances = ., lev = 'alpha', q = 0)),
            alpha_q1 = purrr::map_dbl(data, ~ vegetarian::d(
                abundances = ., lev = 'alpha', q = 1)),
             gamma_q0 = purrr::map_dbl(data, ~ vegetarian::d(
                abundances = ., lev = 'gamma', q = 0)),
            gamma_q1 = purrr::map_dbl(data, ~ vegetarian::d(
                abundances = ., lev = 'gamma', q = 1)),
            beta_q0 = purrr::map_dbl(data, ~ vegetarian::d(
                abundances = ., lev = 'beta', q = 0)),
            beta_q1 = purrr::map_dbl(data, ~ vegetarian::d(
                abundances = ., lev = 'beta', q = 1)))
           
    
    
    diversity_partitioning_results %>% select(-data) %>% print()

    ## # A tibble: 3 x 8
    ##   siteID n_samples alpha_q0 alpha_q1 gamma_q0 gamma_q1 beta_q0 beta_q1
    ##   <chr>      <int>    <dbl>    <dbl>    <dbl>    <dbl>   <dbl>   <dbl>
    ## 1 POSE         101     38.8    15.5       282     99.5    7.26    6.43
    ## 2 MAYF         119     22.2     9.50      221     65.2    9.95    6.86
    ## 3 ARIK         103     23.3     8.40      192     49.2    8.25    5.86

    # Note that POSE has the highest mean diversity



## Using NMDS to ordinate samples

Finally, we will use Nonmetric Multidimensional Scaling (NMDS) to ordinate samples using the `vegan` package as shown below:


    # create ordination using NMDS
    my_nmds_result <- table_sample_by_taxon_density_wide %>% vegan::metaMDS()

    ## Square root transformation
    ## Wisconsin double standardization
    ## Run 0 stress 0.2134463 
    ## Run 1 stress 0.2278972 
    ## Run 2 stress 0.2136507 
    ## ... Procrustes: rmse 0.01364717  max resid 0.1287878 
    ## Run 3 stress 0.2268473 
    ## Run 4 stress 0.216296 
    ## Run 5 stress 0.223065 
    ## Run 6 stress 0.2238931 
    ## Run 7 stress 0.2230453 
    ## Run 8 stress 0.2337675 
    ## Run 9 stress 0.2245226 
    ## Run 10 stress 0.2240318 
    ## Run 11 stress 0.2430486 
    ## Run 12 stress 0.2338812 
    ## Run 13 stress 0.213612 
    ## ... Procrustes: rmse 0.008396279  max resid 0.06811547 
    ## Run 14 stress 0.2187651 
    ## Run 15 stress 0.2327976 
    ## Run 16 stress 0.2364947 
    ## Run 17 stress 0.2161999 
    ## Run 18 stress 0.2249374 
    ## Run 19 stress 0.2229457 
    ## Run 20 stress 0.2429693 
    ## *** No convergence -- monoMDS stopping criteria:
    ##      1: no. of iterations >= maxit
    ##     19: stress ratio > sratmax

    # plot stress
    my_nmds_result$stress

    ## [1] 0.2134463

    p1 <- vegan::ordiplot(my_nmds_result)
    vegan::ordilabel(p1, "species") # how similar taxon densities are across samples 

![ ]({{ site.baseurl }}/images/rfigs/R/SFS-2020/01_working_with_NEON_macroinverts/NMDS-1.png)

    # merge NMDS scores with sampleID information for plotting
    nmds_scores <- my_nmds_result %>% vegan::scores() %>%
      as.data.frame() %>%
      tibble::rownames_to_column("sampleID") %>%
      left_join(table_sample_info) 

    ## Joining, by = "sampleID"

    # # How I determined the outlier(s)
    nmds_scores %>% arrange(desc(NMDS1)) %>% head()

    ##                  sampleID     NMDS1       NMDS2 domainID siteID  namedLocation
    ## 1  POSE.20150721.SURBER.1 1.5742532 -0.02425078      D02   POSE POSE.AOS.reach
    ## 2  POSE.20150330.SURBER.1 1.2299946 -0.75884534      D02   POSE POSE.AOS.reach
    ## 3 ARIK.20160919.KICKNET.3 1.0875597 -0.14280868      D10   ARIK ARIK.AOS.reach
    ## 4 ARIK.20150325.KICKNET.4 0.9929619 -0.27960972      D10   ARIK ARIK.AOS.reach
    ## 5 ARIK.20160919.KICKNET.4 0.9905714 -0.53136594      D10   ARIK ARIK.AOS.reach
    ## 6 ARIK.20140714.KICKNET.4 0.9868035 -1.33136322      D10   ARIK ARIK.AOS.reach
    ##           collectDate       eventID year habitatType     samplerType benthicArea
    ## 1 2015-07-21 14:43:00 POSE.20150721 2015      riffle          surber       0.093
    ## 2 2015-03-30 14:30:00 POSE.20150330 2015      riffle          surber       0.093
    ## 3 2016-09-19 22:06:00 ARIK.20160919 2016         run modifiedKicknet       0.250
    ## 4 2015-03-25 17:15:00 ARIK.20150325 2015         run modifiedKicknet       0.250
    ## 5 2016-09-19 22:06:00 ARIK.20160919 2016         run modifiedKicknet       0.250
    ## 6 2014-07-14 17:51:00 ARIK.20140714 2014         run modifiedKicknet       0.250
    ##            inv_dens_unit
    ## 1 count per square meter
    ## 2 count per square meter
    ## 3 count per square meter
    ## 4 count per square meter
    ## 5 count per square meter
    ## 6 count per square meter

    nmds_scores %>% arrange(desc(NMDS1)) %>% tail()

    ##                 sampleID     NMDS1      NMDS2 domainID siteID  namedLocation
    ## 318 MAYF.20170314.CORE.1 -1.045603  1.2495550      D08   MAYF MAYF.AOS.reach
    ## 319 MAYF.20160321.CORE.2 -1.087688  0.9935332      D08   MAYF MAYF.AOS.reach
    ## 320 MAYF.20180326.CORE.3 -1.095837 -0.5646813      D08   MAYF MAYF.AOS.reach
    ## 321 MAYF.20180726.CORE.2 -1.231606  0.1671310      D08   MAYF MAYF.AOS.reach
    ## 322 MAYF.20190311.CORE.1 -1.440107  0.6270889      D08   MAYF MAYF.AOS.reach
    ## 323 MAYF.20190311.CORE.2 -1.504627  0.7647755      D08   MAYF MAYF.AOS.reach
    ##             collectDate       eventID year habitatType samplerType benthicArea
    ## 318 2017-03-14 14:11:00 MAYF.20170314 2017         run        core       0.006
    ## 319 2016-03-21 16:09:00 MAYF.20160321 2016         run        core       0.006
    ## 320 2018-03-26 14:50:00 MAYF.20180326 2018         run        core       0.006
    ## 321 2018-07-26 14:17:00 MAYF.20180726 2018         run        core       0.006
    ## 322 2019-03-11 15:00:00 MAYF.20190311 2019         run        core       0.006
    ## 323 2019-03-11 15:00:00 MAYF.20190311 2019         run        core       0.006
    ##              inv_dens_unit
    ## 318 count per square meter
    ## 319 count per square meter
    ## 320 count per square meter
    ## 321 count per square meter
    ## 322 count per square meter
    ## 323 count per square meter

    # Plot samples in community composition space by year
    nmds_scores %>%
      ggplot(aes(NMDS1, NMDS2, color = siteID, 
                 shape = samplerType)) +
      geom_point() +
      facet_wrap(~ as.factor(year))

![ ]({{ site.baseurl }}/images/rfigs/R/SFS-2020/01_working_with_NEON_macroinverts/NMDS-2.png)

    # Plot samples in community composition space
    # facet by siteID and habitat type
    # color by year
    nmds_scores %>%
      ggplot(aes(NMDS1, NMDS2, color = as.factor(year), 
                 shape = samplerType)) +
      geom_point() +
      facet_grid(habitatType ~ siteID, scales = "free")

![ ]({{ site.baseurl }}/images/rfigs/R/SFS-2020/01_working_with_NEON_macroinverts/NMDS-3.png)
