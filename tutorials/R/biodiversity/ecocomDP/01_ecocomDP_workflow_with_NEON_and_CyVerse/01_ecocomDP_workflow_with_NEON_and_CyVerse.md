---
title: "Explore NEON biodiversity data using ecocomDP"
syncID: 19fe7b1f052c478c8a7df52e4e03efbf
description: Download and explore NEON algae and aquatic macroinvertebrate data with
  the ecocomDP package for R using the CyVerse Discovery Environment
dateCreated: '2022-01-21'
authors: Eric R. Sokol
contributors: Donal O'Leary, Felipe Sanchez, Michael Culshaw-Maurer
estimatedTime: 1 Hour
packagesLibraries: tidyverse, neonUtilities, ecocomDP
topics: data-analysis, organisms, data-viz
languagesTool: R
dataProduct: DP1.20120.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/biodiversity/ecocomDP/01_ecocomDP_workflow_with_NEON_and_CyVerse/01_ecocomDP_workflow_with_NEON_and_CyVerse.R
tutorialSeries: null
urlTitle: neon-biodiversity-ecocomdp-cyverse
---

<div id="ds-objectives" markdown="1">

## Learning Objectives 
After completing this tutorial you will be able to: 

* (Optional) Run an RStudio session with `ecocomDP` pre-installed on the VICE cloud using the CyVerse Discovery Environment.
* Use the ecocomDP package to download NEON algae and benthic macroinvertebrate biodiversity data.
* Explore NEON biodiversity datasets with `ecocomDP` plotting functions.


## Things You’ll Need To Complete This Tutorial

## _Option 1: RStudio on the VICE cloud_

### Creating a CyVerse Account

To create a CyVerse account, navigate to [user.cyverse.org](https://user.cyverse.org/) and click "Sign Up". You will be prompted to fill in your name, a username, and an email. It is **highly recommended** that you use a `.edu`, `.org`, or `.gov` email address if you have one. Cloud computing platforms are a prime target for cryptocurrency miners, and using an institutional email address makes it easier to verify that you *aren't* one.

You will be prompted to fill out a few more pieces of information about yourself and what you intend to use CyVerse for. Once you have completed the registration process, you will have a CyVerse account and can proceed to the next step.

### Requesting VICE Access

Next, you will have to request access to the Visual Interactive Computing Environment (VICE), which is a platform for running interactive applications, like RStudio or JupyterLab, on the cloud. VICE access requires a one-time approval, due to the cryptocurrency miner issue mentioned above.

You can navigate to [user.cyverse.org/services](https://user.cyverse.org/services) to find services you have access to. You can locate **DE-VICE** and click "Request Access", where you will be prompted to provide information about why you are using VICE. It may take up to a day for VICE access to be approved, so it is worth doing this step ahead of time.

**NOTE**: if you are participating in a workshop that is registered through CyVerse, you may have pre-approved for VICE access. If this is the case, **DE-VICE** will be listed under "My Services", and instead of seeing "Request Access", you will see "Launch". 

Once **DE-VICE** appears under "My Services" in the User Portal, with a "Launch" button, that means you have been approved for VICE access, and you can proceed to the next step.

### Launching RStudio with the `ecocomDP` package

We will be using an RStudio application running on the VICE cloud. It already has several R packages installed for this tutorial.

Use this URL to access the application: [https://de.cyverse.org/apps/de/61b7335a-52d2-11ec-ba89-008cfa5ae621](https://de.cyverse.org/apps/de/61b7335a-52d2-11ec-ba89-008cfa5ae621).  
Click on the app name ("Rocker Verse + ecocomDP") to proceed.  

**NOTE**: You may be prompted to log in using your CyVerse credentials.

Next, you will see a screen where you can name your analysis and change other parameters. We will just use the default options, so you can hit the **Next** button to move through each page until you reach the last page. Now you can click **Launch Analysis** to launch the RStudio application.

You will be taken to a page that says your analysis has been submitted. You can now go to the lefthand navigation bar and click on the **Analyses** item to go to the Analyses page. From here you can see all your currently running analyses, as well as any completed analyses. Your *Rocker Verse + ecocomDP* analysis should have a Status of either "Submitted" or "Running". It may take a few minutes for the analysis to launch. On the righthand side of the screen, you should see a **Launch Analysis** icon that looks like a square with an arrow coming out of it. Click on it to open your analysis in a new tab.

You will either be brought to a loading page or directly to an RStudio session. If you are on the loading page, just wait a few minutes, and RStudio should appear.

Once RStudio is open, you should be able to begin the rest of the tutorial.

**NOTE**: to get more information on using any of the CyVerse platforms, including VICE, you can check out the [CyVerse Learning Center](https://learning.cyverse.org/).


## _Option 2: Run R locally on your machine_
### The R Programming Language
You will need a current version of R to complete this tutorial. We also recommend 
the RStudio IDE to work with R. 

### R Packages to Install
Prior to starting the tutorial, ensure that the following packages are installed. 

* **tidyverse:** `install.packages("tidyverse")`
* **neonUtilities:** `install.packages("neonUtilities")`
* **ecocomDP:** `install.packages("ecocomDP")`

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

</div>

## Introduction
In this code-along tutorial, we will explore how to find and download NEON biodiversity data using the ecocomDP package for R, which has been developed by the Environmental Data Initiative (EDI) in collaboration with NEON staff.

#### What is ecocomDP?
"ecocomDP" is both the name of an R package and a data model. 
 
EDI describes the ecocomDP data model as "A dataset design pattern for ecological community data to facilitate synthesis and reuse". 
 
See the ecocomDP GitHub repo here:
<a href="https://github.com/EDIorg/ecocomDP ">https://github.com/EDIorg/ecocomDP</a>.

<figure>
<a href="https://raw.githubusercontent.com/EDIorg/ecocomDP/master/documentation/model/ecocomDP.png">
<img src="https://raw.githubusercontent.com/EDIorg/ecocomDP/master/documentation/model/ecocomDP.png" alt="data model workflow showing relationships between various tables in ecocomDP model"> </a>
<figcaption>Data model workflow showing relationships between various tables in ecocomDP model. Source: EDIorg</figcaption>
</figure>

The motivation is for both NEON biodiversity data products and EDI data packages, including data from the US Long Term Ecological Research Network and Macrosystems Biology projects, to be discoverable through a single data search tool, and to be delivered in a standard format. Our objective here is to demonstrate how the workflow will work with NEON biodiversity data packages. 

## Load Libraries and Prepare Workspace
First, we will load all necessary libraries into our R environment. If you are not using the RStudio VICE app with the packages pre-installed and you have not already installed these libraries, please see the 'R Packages to Install' section above. 

There are also two optional sections in this code chunk: clearing your environment, and loading your NEON API token. Clearing out your environment will erase _all_ of the variables and data that are currently loaded in your R session. This is a good practice for many reasons, but only do this if you are completely sure that you won't be losing any important information! Secondly, your NEON API token will allow you increased download speeds, and helps NEON __anonymously__ track data usage statistics, which helps us optimize our data delivery platforms, and informs our monthly and annual reporting to our funding agency, the National Science Foundation. Please consider signing up for a NEON data user account, and using your token <a href="https://www.neonscience.org/neon-api-tokens-tutorial">as described in this tutorial here</a>.


    # clean out workspace
    
    #rm(list = ls()) # OPTIONAL - clear out your environment
    #gc()            # Uncomment these lines if desired
    
    # load packages
    library(tidyverse)
    library(neonUtilities)
    library(ecocomDP)
    
    # source .r file with my NEON_TOKEN
    # source("my_neon_token.R") # OPTIONAL - load NEON token
    # See: https://www.neonscience.org/neon-api-tokens-tutorial





## Download Macroinvertibrate Data
In this first step, we show how to search the ecocomDP database for macroinvertebrate data including those from LTER and NEON sites (and others).


    # search for invertebrate data products
    my_search_result <- ecocomDP::search_data(text = "invertebrate")
    View(my_search_result)
    
    # pull data for the NEON aquatic "Macroinvertebrate
    # collection" from ARIK collected during 2017 and 2018
    my_data <- ecocomDP::read_data(
      id = "neon.ecocomdp.20120.001.001",
      site = "ARIK",
      startdate = "2017-01",
      enddate = "2018-12",
      # token = NEON_TOKEN, #Uncomment to use your token
      check.size = FALSE)


Now that we have downloaded the data, let's take a look at tht `ecocomDP` data object structure:


    # examine the structure of the data object that is returned
    my_data %>% names()

    ## [1] "id"                "metadata"          "tables"            "validation_issues"

    # the data package id
    my_data$id

    ## [1] "neon.ecocomdp.20120.001.001"

    # short list of package summary data
    my_data$metadata$data_package_info

    ## $data_package_id
    ## [1] "neon.ecocomdp.20120.001.001.20220124132950"
    ## 
    ## $taxonomic_group
    ## [1] "MACROINVERTEBRATES"
    ## 
    ## $orig_NEON_data_product_id
    ## [1] "DP1.20120.001"
    ## 
    ## $NEON_to_ecocomDP_mapping_method
    ## [1] "neon.ecocomdp.20120.001.001"
    ## 
    ## $data_access_method
    ## [1] "original NEON data accessed using neonUtilities v2.1.3"
    ## 
    ## $data_access_date_time
    ## [1] "2022-01-24 13:29:51 MST"

    # validation issues? None if returns an empty list
    my_data$validation_issues

    ## list()

    # examine the tables
    my_data$tables %>% names()

    ## [1] "location"              "location_ancillary"    "taxon"                 "observation"           "observation_ancillary" "dataset_summary"

    my_data$tables$taxon %>% head()

    ##   taxon_id taxon_rank       taxon_name                                    authority_system authority_taxon_id
    ## 1    ABLSP      genus  Ablabesmyia sp.                          Roback 1985 and Epler 2001               <NA>
    ## 2   ACASP1   subclass        Acari sp.                               Thorp and Covich 2001               <NA>
    ## 3   ACTSP5      genus Actinobdella sp.                               Thorp and Covich 2001               <NA>
    ## 4    AESSP     family    Aeshnidae sp.                      Needham, Westfall and May 2000               <NA>
    ## 5   AGASP1  subfamily     Agabinae sp.                   Larson, Alarie, and Roughley 2001               <NA>
    ## 6   ANISP1   suborder   Anisoptera sp. Merritt et al. 2008; Needham, Westfall and May 2000               <NA>

    my_data$tables$observation %>% head()

    ##   observation_id             event_id                                 package_id    location_id            datetime taxon_id variable_name     value                   unit
    ## 1          obs_1 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220124132950 ARIK.AOS.reach 2017-03-22 15:30:00   BERSP4       density  166.6667 count per square meter
    ## 2          obs_2 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220124132950 ARIK.AOS.reach 2017-03-22 15:30:00   CAESP5       density  166.6667 count per square meter
    ## 3          obs_3 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220124132950 ARIK.AOS.reach 2017-03-22 15:30:00  CERSP10       density 1333.3333 count per square meter
    ## 4          obs_4 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220124132950 ARIK.AOS.reach 2017-03-22 15:30:00   CHISP2       density  166.6667 count per square meter
    ## 5          obs_5 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220124132950 ARIK.AOS.reach 2017-03-22 15:30:00    CONGR       density  500.0000 count per square meter
    ## 6          obs_6 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220124132950 ARIK.AOS.reach 2017-03-22 15:30:00   DIASP8       density  500.0000 count per square meter


## Basic Data Visualization

The `ecocomDP` package offers some useful data visualization tools.


    # Explore the spatial and temporal coverage 
    # of the dataset
    my_data %>% ecocomDP::plot_sample_space_time()

![Sampling events in space and time represented in the downloaded data set for benthic macroinvertebrate counts from the Arikaree River site.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials//R/biodiversity/ecocomDP/01_ecocomDP_workflow_with_NEON_and_CyVerse/rfigs/macroinvert-datavis-space-time-1.png)


    # Explore the taxonomic resolution in the dataset. 
    # What is the most common taxonomic resolution (rank) 
    # for macroinvertebrate identifications in this dataset?
    my_data %>% ecocomDP::plot_taxa_rank()

![Frequencies of different taxonomic ranks in benthic macroinvertebrate counts from the Arikaree River site.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials//R/biodiversity/ecocomDP/01_ecocomDP_workflow_with_NEON_and_CyVerse/rfigs/macroinvert-datavis-ranks-1.png)




## Search `ecocomDP`

Additionally, we can search for terms in the ecocomDP database using regular expressions:


    # search for data sets with periphyton or algae
    # regex works!
    my_search_result <- ecocomDP::search_data(text = "periphyt|algae")
    View(my_search_result)


Let's download data for the NEON "Periphyton, seston, and phytoplankton collection" from "ARIK" and "COMO" and view their structure:


    # pull data for the NEON "Periphyton, seston, and phytoplankton collection" 
    # data product (expect the download to take 1-2 mins)
    my_data <- ecocomDP::read_data(
      id = "neon.ecocomdp.20166.001.001", 
      site = c("ARIK","COMO"),
      startdate = "2017-01",
      enddate = "2020-12",
      # token = NEON_TOKEN, #Uncomment to use your token
      check.size = FALSE)



    # Explore the structure of the returned data object
    my_data %>% names()

    ## [1] "id"                "metadata"          "tables"            "validation_issues"

    my_data$id

    ## [1] "neon.ecocomdp.20166.001.001"

    my_data$metadata$data_package_info

    ## $data_package_id
    ## [1] "neon.ecocomdp.20166.001.001.20220124133015"
    ## 
    ## $taxonomic_group
    ## [1] "ALGAE"
    ## 
    ## $orig_NEON_data_product_id
    ## [1] "DP1.20166.001"
    ## 
    ## $NEON_to_ecocomDP_mapping_method
    ## [1] "neon.ecocomdp.20166.001.001"
    ## 
    ## $data_access_method
    ## [1] "original NEON data accessed using neonUtilities v2.1.3"
    ## 
    ## $data_access_date_time
    ## [1] "2022-01-24 13:30:16 MST"

    my_data$validation_issues

    ## list()

    my_data$tables %>% names()

    ## [1] "location"              "location_ancillary"    "taxon"                 "observation"           "observation_ancillary" "dataset_summary"

    my_data$tables$location

    ##      location_id                       location_name parent_location_id latitude longitude elevation
    ## 1            D10                      Central Plains               <NA>       NA        NA        NA
    ## 2            D13 Southern Rockies & Colorado Plateau               <NA>       NA        NA        NA
    ## 3           ARIK                      Arikaree River                D10 39.75825 -102.4471        NA
    ## 4           COMO                          Como Creek                D13 40.03496 -105.5449        NA
    ## 5 ARIK.AOS.reach                      ARIK.AOS.reach               ARIK 39.75821 -102.4471    1179.5
    ## 6    ARIK.AOS.S2                         ARIK.AOS.S2               ARIK 39.75836 -102.4486    1178.7
    ## 7 COMO.AOS.reach                      COMO.AOS.reach               COMO 40.03496 -105.5442    3021.6
    ## 8    COMO.AOS.S2                         COMO.AOS.S2               COMO 40.03494 -105.5444    3023.0

    my_data$tables$taxon %>% head()

    ##           taxon_id taxon_rank         taxon_name
    ## 1 ACHNANTHIDIUMSPP      genus Achnanthidium spp.
    ## 2       AMPHORASPP      genus       Amphora spp.
    ## 3      ANABAENASPP      genus      Anabaena spp.
    ## 4   APHANOCAPSASPP      genus   Aphanocapsa spp.
    ## 5            AUDSP      genus    Audouinella sp.
    ## 6   AULACOSEIRASPP      genus   Aulacoseira spp.
    ##                                                                                                                                                                                                                                                              authority_system
    ## 1                                                                      Academy of Natural Sciences of Drexel University and collaborators. 2011 - 2016. ANSP/NAWQA/EPA 2011 diatom and non-diatom taxa names, http://diatom.ansp.org/nawqa/Taxalist.aspx, accessed 1/11/2016.
    ## 2 Academy of Natural Sciences of Drexel University and collaborators. 2011 - 2016. ANSP/NAWQA/EPA 2011 diatom and non-diatom taxa names, http://diatom.ansp.org/nawqa/Taxalist.aspx, accessed 1/11/2016.; http://diatom.ansp.org/nawqa/Taxalist.aspx (accessed Jan 11, 2016).
    ## 3 Academy of Natural Sciences of Drexel University and collaborators. 2011 - 2016. ANSP/NAWQA/EPA 2011 diatom and non-diatom taxa names, http://diatom.ansp.org/nawqa/Taxalist.aspx, accessed 1/11/2016.; http://diatom.ansp.org/nawqa/Taxalist.aspx (accessed Jan 11, 2016).
    ## 4 Academy of Natural Sciences of Drexel University and collaborators. 2011 - 2016. ANSP/NAWQA/EPA 2011 diatom and non-diatom taxa names, http://diatom.ansp.org/nawqa/Taxalist.aspx, accessed 1/11/2016.; http://diatom.ansp.org/nawqa/Taxalist.aspx (accessed Jan 11, 2016).
    ## 5                                                                                    M.D. Guiry in Guiry, M.D. & Guiry, G.M. 2020. AlgaeBase. World-wide electronic publication, National University of Ireland, Galway. http://www.algaebase.org; searched on 26 March 2020.
    ## 6 Academy of Natural Sciences of Drexel University and collaborators. 2011 - 2016. ANSP/NAWQA/EPA 2011 diatom and non-diatom taxa names, http://diatom.ansp.org/nawqa/Taxalist.aspx, accessed 1/11/2016.; http://diatom.ansp.org/nawqa/Taxalist.aspx (accessed Jan 11, 2016).
    ##   authority_taxon_id
    ## 1               <NA>
    ## 2               <NA>
    ## 3               <NA>
    ## 4               <NA>
    ## 5               <NA>
    ## 6               <NA>

    my_data$tables$observation %>% head()

    ##                         observation_id                  event_id                                 package_id    location_id            datetime       taxon_id variable_name
    ## 1 7a8dc4e5-e50d-4d9b-81c3-a0d374281acf ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220124133015 ARIK.AOS.reach 2017-03-27 18:01:00  NEONDREX48165  cell density
    ## 2 b3b59b2e-f828-4fb7-b140-3b19438ccda4 ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220124133015 ARIK.AOS.reach 2017-03-27 18:01:00  NEONDREX16011  cell density
    ## 3 5b865421-e803-4016-a917-2ef34491e913 ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220124133015 ARIK.AOS.reach 2017-03-27 18:01:00 NEONDREX245001  cell density
    ## 4 1eece2f0-8a4b-4f44-aba4-b55415bd4970 ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220124133015 ARIK.AOS.reach 2017-03-27 18:01:00 NEONDREX543001  cell density
    ## 5 71502b14-54ed-4142-80e2-c086b40684f7 ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220124133015 ARIK.AOS.reach 2017-03-27 18:01:00  NEONDREX48004  cell density
    ## 6 b0815b73-2b94-4a7b-8dfb-5a68ce866533 ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220124133015 ARIK.AOS.reach 2017-03-27 18:01:00  NEONDREX48023  cell density
    ##          value      unit
    ## 1    284.27016 cells/cm2
    ## 2     94.75605 cells/cm2
    ## 3   2179.40121 cells/cm2
    ## 4 136449.47581 cells/cm2
    ## 5    284.27016 cells/cm2
    ## 6     94.75605 cells/cm2


## Algae Data Flattening and Cleaning

While the ecocomDP data package takes care of some data cleaning and formatting, it is best to join all the tables and flatten the dataset and do some basic checks before proceeding with plotting and analyses:


    # flatten the ecocomDP data tables into one flat table
    my_data_flat <- my_data %>% ecocomDP::flatten_data()
    
    # This data product has algal densities reported for both
    # lakes and streams, so densities could be standardized
    # either to volume collected or area sampled. 
    
    # Verify that only benthic algae standardized to area 
    # are returned in this data pull:
    my_data_flat$unit %>%
        unique()

    ## [1] "cells/cm2" "cells/mL"

    # filter the data to only records standardized to area
    # sampled
    my_data_benthic <- my_data_flat %>%
      dplyr::filter(unit == "cells/cm2")


## Explore Benthic Algae Data with `ecocomDP` Plotting Functions


    # Note that you can send flattened data 
    # to the ecocomDP plotting functions
    my_data_benthic %>% ecocomDP::plot_sample_space_time()

![Sampling events in space in time represented in the downloaded data set for algae.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials//R/biodiversity/ecocomDP/01_ecocomDP_workflow_with_NEON_and_CyVerse/rfigs/algae-data-vis-space-time-1.png)




    # Note that you can also send flattened data 
    # to the ecocomDP plotting functions
    my_data_benthic %>% ecocomDP::plot_taxa_diversity(time_window_size = "year")

![Benthic algal richness by year at ARIK and COMO](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials//R/biodiversity/ecocomDP/01_ecocomDP_workflow_with_NEON_and_CyVerse/rfigs/algae-data-vis-richness-time-1.png)
