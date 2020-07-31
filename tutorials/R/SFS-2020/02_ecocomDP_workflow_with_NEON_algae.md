---
syncID: a112429a90d14c9d8620b956a2469062
title: "Explore biodiversity with NEON algae data"
description: "Download and explore NEON algae data. This includes instruction for using ecocomDP package to analyze biodiversity."
dateCreated: 2020-06-22
authors: Eric R. Sokol
contributors: Donal O'Leary
estimatedTime: 1 Hour
packagesLibraries: tidyverse, neonUtilities, devtools
topics:
languagesTool: R
dataProduct:
code1: R/SFS-2020/02_ecocomDP_workflow_with_NEON_algae.R
tutorialSeries: 
urlTitle: aquatic-diversity-algae
---

<div id="ds-objectives" markdown="1">

## Learning Objectives 
After completing this tutorial you will be able to: 

* Use the ecocomDP package to download NEON algae data.
* Analyze biodiversity metrics using the `vegan` package

## Things You’ll Need To Complete This Tutorial

### R Programming Language
You will need a current version of R to complete this tutorial. We also recommend 
the RStudio IDE to work with R. 

### R Packages to Install
Prior to starting the tutorial ensure that the following packages are installed. 

* **tidyverse:** `install.packages("tidyverse")`
* **neonUtilities:** `install.packages("neonUtilities")`
* **devtools:** `install.packages("devtools")`
* **vegan:** `install.packages("vegan")`
* **vegetarian:** `install.packages("vegetarian")`
* **Hmisc:** `install.packages("Hmisc")`

<a href="/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

</div>

## Introduction
In this second live coding section of the workshop, we will explore how to find and download NEON biodiversity data using the ecocomDP package for R, which is under development by the Environmental Data Initiative (EDI).

#### What is ecocomDP?
ecocomDP is both the name of an R package and a data model. 
 
EDI describes the ecocomDP data model as "A dataset design pattern for ecological community data to facilitate synthesis and reuse". 
 
See the ecocomDP github repo here:
<a href="https://github.com/EDIorg/ecocomDP ">https://github.com/EDIorg/ecocomDP</a>.

<figure>
<a href="https://raw.githubusercontent.com/EDIorg/ecocomDP/master/documentation/model/ecocomDP.png">
<img src="https://raw.githubusercontent.com/EDIorg/ecocomDP/master/documentation/model/ecocomDP.png" alt="data model workflow showing relationships between various tables in ecocomDP model"> </a>
<figcaption> Data model workflow showing relationships between various tables in ecocomDP model. Source: EDIorg</figcaption>
</figure>

The motivation is for both NEON biodiversity data products and EDI data packages, including data from the US Long Term Ecological Research Network and Macrosystems Biology projects, to be discoverable through a single data search tool, and to be delivered in a standard format. Our objective here is to demonstrate how the workflow will work with NEON biodiversity data packages. 

This tutorial was prepared for the <a href="https://freshwater-science.org/sfs-summer-science"> Society for Freshwater Science 2020 "Summer of Science" </a> program.

## Load Libraries and Prepare Workspace
First, we will load all necessary libraries into our R environment. If you have not already installed these libraries, please see the 'R Packages to Install' section above. We load the `devtools` package here so that we can install the latest development version of the ecocomDP package from Dr. Sokol's GitHub repository. The ecocomDP package is not yet available through CRAN, and therefore, we must install the package in this manner.

There are also two optional sections in this code chunk: clearing your environment, and loading your NEON API token. Clearning out your environment will erase _all_ of the variables and data that are currently loaded in your R session. This is a good practice for many reasons, but only do this if you are completely sure that you won't be losing any important information! Secondly, your NEON API token will allow you increased download speeds, and helps NEON __anonymously__ track data usage statistics, which helps us optimize our data delivery platforms, and informs our monthly and annual reporting to our funding agency, the National Science Foundation. Please consider signing up for a NEON data user account, and using your token <a href="https://www.neonscience.org/neon-api-tokens-tutorial">as described in this tutorial here</a>.


    # clean out workspace
    
    #rm(list = ls()) # OPTIONAL - clear out your environment
    #gc()            # Uncomment these lines if desired
    
    # load packages
    library(tidyverse)
    library(neonUtilities)
    library(devtools)
    
    # install neon_demo branch of ecocomDP
    devtools::install_github("sokole/ecocomDP@neon_demo")
    
    library(ecocomDP)
    
    # source .r file with my NEON_TOKEN
    # source("my_neon_token.R") # OPTIONAL - load NEON token
    # See: https://www.neonscience.org/neon-api-tokens-tutorial



## Download Macroinvertibrate Data
In this first step, we show how to search the ecocomDP database for macroinvertibrate data including those from LTER and NEON sites (and others).

    # search for invertebrate data products
    my_search_result <- 
        ecocomDP::search_data(text = "invertebrate")

    ## Searching data ...

    View(my_search_result)
    
    # pull data for the NEON aquatic "Macroinvertebrate
    # collection" data product
    # function not yet compatible with "token" argument 
    # in updated neonUtilities
    my_search_result_data <- 
        ecocomDP::read_data(id = "DP1.20120.001",
                            site = c("ARIK", "POSE"))

    ## Finding available files
    ##   |                                                                          |                                                                  |   0%  |                                                                          |==                                                                |   3%  |                                                                          |====                                                              |   6%  |                                                                          |======                                                            |   9%  |                                                                          |========                                                          |  11%  |                                                                          |=========                                                         |  14%  |                                                                          |===========                                                       |  17%  |                                                                          |=============                                                     |  20%  |                                                                          |===============                                                   |  23%  |                                                                          |=================                                                 |  26%  |                                                                          |===================                                               |  29%  |                                                                          |=====================                                             |  31%  |                                                                          |=======================                                           |  34%  |                                                                          |=========================                                         |  37%  |                                                                          |==========================                                        |  40%  |                                                                          |============================                                      |  43%  |                                                                          |==============================                                    |  46%  |                                                                          |================================                                  |  49%  |                                                                          |==================================                                |  51%  |                                                                          |====================================                              |  54%  |                                                                          |======================================                            |  57%  |                                                                          |========================================                          |  60%  |                                                                          |=========================================                         |  63%  |                                                                          |===========================================                       |  66%  |                                                                          |=============================================                     |  69%  |                                                                          |===============================================                   |  71%  |                                                                          |=================================================                 |  74%  |                                                                          |===================================================               |  77%  |                                                                          |=====================================================             |  80%  |                                                                          |=======================================================           |  83%  |                                                                          |=========================================================         |  86%  |                                                                          |==========================================================        |  89%  |                                                                          |============================================================      |  91%  |                                                                          |==============================================================    |  94%  |                                                                          |================================================================  |  97%  |                                                                          |==================================================================| 100%
    ## 
    ## Downloading files totaling approximately 1.3 MiB
    ## Downloading 35 files
    ##   |                                                                          |                                                                  |   0%  |                                                                          |==                                                                |   3%  |                                                                          |====                                                              |   6%  |                                                                          |======                                                            |   9%  |                                                                          |========                                                          |  12%  |                                                                          |==========                                                        |  15%  |                                                                          |============                                                      |  18%  |                                                                          |==============                                                    |  21%  |                                                                          |================                                                  |  24%  |                                                                          |=================                                                 |  26%  |                                                                          |===================                                               |  29%  |                                                                          |=====================                                             |  32%  |                                                                          |=======================                                           |  35%  |                                                                          |=========================                                         |  38%  |                                                                          |===========================                                       |  41%  |                                                                          |=============================                                     |  44%  |                                                                          |===============================                                   |  47%  |                                                                          |=================================                                 |  50%  |                                                                          |===================================                               |  53%  |                                                                          |=====================================                             |  56%  |                                                                          |=======================================                           |  59%  |                                                                          |=========================================                         |  62%  |                                                                          |===========================================                       |  65%  |                                                                          |=============================================                     |  68%  |                                                                          |===============================================                   |  71%  |                                                                          |=================================================                 |  74%  |                                                                          |==================================================                |  76%  |                                                                          |====================================================              |  79%  |                                                                          |======================================================            |  82%  |                                                                          |========================================================          |  85%  |                                                                          |==========================================================        |  88%  |                                                                          |============================================================      |  91%  |                                                                          |==============================================================    |  94%  |                                                                          |================================================================  |  97%  |                                                                          |==================================================================| 100%
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
    ## Stacking took 0.789788 secs
    ## All unzipped monthly data folders have been removed.

    ## Joining, by = "sampleID"

Now that we have downloaded the data, let's take a look at tht `ecocomDP` data object structure:


    # examine the structure of the data object that is returned
    my_search_result_data %>% names()

    ## [1] "DP1.20120.001"

    my_search_result_data$DP1.20120.001 %>% names()

    ## [1] "metadata" "tables"

    my_search_result_data$DP1.20120.001$tables %>% names()

    ## [1] "location"    "taxon"       "observation"

    my_search_result_data$DP1.20120.001$tables$taxon %>% head()

    ##   taxon_id taxon_rank          taxon_name  authority_system
    ## 1   STEFEM    species Stenonema femoratum NEON_external_lab
    ## 2    BAESP     family        Baetidae sp. NEON_external_lab
    ## 3   PERSP1     family        Perlidae sp. NEON_external_lab
    ## 4   CHESP5      genus  Cheumatopsyche sp. NEON_external_lab
    ## 5   LEUSP8      genus         Leuctra sp. NEON_external_lab
    ## 6    OPTSP      genus     Optioservus sp. NEON_external_lab
    ##                            authority_taxon_id
    ## 1                         Merritt et al. 2008
    ## 2                         Merritt et al. 2008
    ## 3 Merritt et al. 2008; Stewart and Stark 2002
    ## 4           Merritt et al. 2008; Wiggins 1996
    ## 5 Merritt et al. 2008; Stewart and Stark 2002
    ## 6                         Merritt et al. 2008

    my_search_result_data$DP1.20120.001$tables$observation %>% head()

    ##                         observation_id               event_id
    ## 1 9e013f88-8463-4be2-8475-da816cdfa8f6 POSE.20140722.SURBER.1
    ## 2 4ab7e7a9-bc7e-451f-9eec-0d25924a4dfd POSE.20140722.SURBER.1
    ## 3 9e958d7e-79d1-45fd-bafd-586964d4d26e POSE.20140722.SURBER.1
    ## 4 c4deafd4-ed61-4a15-9c06-29a27338d5e9 POSE.20140722.SURBER.1
    ## 5 a08ab6fd-10e3-4f5f-8bac-b6eb35d21c15 POSE.20140722.SURBER.1
    ## 6 130571ba-09fe-4b89-a752-361a710265cb POSE.20140722.SURBER.1
    ##                     package_id    location_id observation_datetime taxon_id
    ## 1 DP1.20120.001.20200731104219 POSE.AOS.reach  2014-07-22 13:10:00   STEFEM
    ## 2 DP1.20120.001.20200731104219 POSE.AOS.reach  2014-07-22 13:10:00    BAESP
    ## 3 DP1.20120.001.20200731104219 POSE.AOS.reach  2014-07-22 13:10:00   PERSP1
    ## 4 DP1.20120.001.20200731104219 POSE.AOS.reach  2014-07-22 13:10:00   CHESP5
    ## 5 DP1.20120.001.20200731104219 POSE.AOS.reach  2014-07-22 13:10:00   CHESP5
    ## 6 DP1.20120.001.20200731104219 POSE.AOS.reach  2014-07-22 13:10:00   LEUSP8
    ##   variable_name     value                   unit
    ## 1       density  258.0645 count per square meter
    ## 2       density  129.0323 count per square meter
    ## 3       density  129.0323 count per square meter
    ## 4       density 2075.2688 count per square meter
    ## 5       density  258.0645 count per square meter
    ## 6       density  258.0645 count per square meter


## Search ecocomDP

We can even search for terms in the ecocomDP database using regular expressions:


    # search for data sets with periphyton or algae
    # regex works!
    my_search_result <- ecocomDP::search_data(text = "periphyt|algae")

    ## Searching data ...

    View(my_search_result)

Let's download the data for the NEON "Periphyton, seston, and phytoplankton collection" from "ARIK" and view its structure:


    # pull data for the NEON "Periphyton, seston, and phytoplankton collection" 
    # data product
    my_search_result_data <- 
        ecocomDP::read_data(id = "DP1.20166.001", site = "ARIK")

    ## Finding available files
    ##   |                                                                          |                                                                  |   0%  |                                                                          |====                                                              |   6%  |                                                                          |========                                                          |  12%  |                                                                          |============                                                      |  18%  |                                                                          |================                                                  |  24%  |                                                                          |===================                                               |  29%  |                                                                          |=======================                                           |  35%  |                                                                          |===========================                                       |  41%  |                                                                          |===============================                                   |  47%  |                                                                          |===================================                               |  53%  |                                                                          |=======================================                           |  59%  |                                                                          |===========================================                       |  65%  |                                                                          |===============================================                   |  71%  |                                                                          |==================================================                |  76%  |                                                                          |======================================================            |  82%  |                                                                          |==========================================================        |  88%  |                                                                          |==============================================================    |  94%  |                                                                          |==================================================================| 100%
    ## 
    ## Downloading files totaling approximately 1.9 MiB
    ## Downloading 17 files
    ##   |                                                                          |                                                                  |   0%  |                                                                          |====                                                              |   6%  |                                                                          |========                                                          |  12%  |                                                                          |============                                                      |  19%  |                                                                          |================                                                  |  25%  |                                                                          |=====================                                             |  31%  |                                                                          |=========================                                         |  38%  |                                                                          |=============================                                     |  44%  |                                                                          |=================================                                 |  50%  |                                                                          |=====================================                             |  56%  |                                                                          |=========================================                         |  62%  |                                                                          |=============================================                     |  69%  |                                                                          |==================================================                |  75%  |                                                                          |======================================================            |  81%  |                                                                          |==========================================================        |  88%  |                                                                          |==============================================================    |  94%  |                                                                          |==================================================================| 100%
    ## 
    ## Unpacking zip files using 1 cores.
    ## Stacking operation across a single core.
    ## Stacking table alg_biomass
    ## Stacking table alg_fieldData
    ## Stacking table alg_taxonomyProcessed
    ## Copied the most recent publication of validation file to /stackedFiles
    ## Copied the most recent publication of categoricalCodes file to /stackedFiles
    ## Copied the most recent publication of variable definition file to /stackedFiles
    ## Finished: Stacked 3 data tables and 3 metadata tables!
    ## Stacking took 0.4902141 secs
    ## All unzipped monthly data folders have been removed.

    # Explore the structure of the returned data object
    my_search_result_data %>% names()

    ## [1] "DP1.20166.001"

    my_search_result_data[[1]] %>% names()

    ## [1] "metadata" "tables"

    my_search_result_data[[1]]$tables %>% names()

    ## [1] "location"              "taxon"                 "observation"          
    ## [4] "observation_ancillary"

    my_search_result_data[[1]]$tables$location

    ##   location_id  location_name latitude longitude elevation
    ## 1      lo_1_1            D10       NA        NA        NA
    ## 2      lo_2_1           ARIK       NA        NA        NA
    ## 3      lo_3_1 ARIK.AOS.reach 39.75821 -102.4471    1179.5
    ## 4      lo_3_2    ARIK.AOS.S2 39.75836 -102.4486    1178.7
    ##   parent_location_id
    ## 1               <NA>
    ## 2             lo_1_1
    ## 3             lo_2_1
    ## 4             lo_2_1

    my_search_result_data[[1]]$tables$taxon %>% head()

    ##         taxon_id taxon_rank
    ## 1 NEONDREX455000      genus
    ## 2 NEONDREX803001      genus
    ## 3 NEONDREX170006    species
    ## 4 NEONDREX467013    variety
    ## 5 NEONDREX510002    species
    ## 6  NEONDREX12031    species
    ##                                            taxon_name  authority_system
    ## 1                                      Oedogonium sp. NEON_external_lab
    ## 2                                        Anabaena sp. NEON_external_lab
    ## 3            Sellaphora pupula (Kützing) Meresckowsky NEON_external_lab
    ## 4 Pediastrum duplex var. clathratum (Braun) Lagerheim NEON_external_lab
    ## 5                  Scenedesmus ecornis (Ralfs) Chodat NEON_external_lab
    ## 6                Caloneis schumanniana (Grunow) Cleve NEON_external_lab
    ##                                                                                                                               authority_taxon_id
    ## 1            Wehr, J.D. and R.G. Sheath. 2003. Freshwater Algae of North America: Ecology and Classification. Academic Press, Amsterdam. 918 pp.
    ## 2            Wehr, J.D. and R.G. Sheath. 2003. Freshwater Algae of North America: Ecology and Classification. Academic Press, Amsterdam. 918 pp.
    ## 3                     Mereschkowsky, C. 1902. On Sellaphora, a new genus of Diatoms. Annals and Magazine of Natural History, 9: 185-195, pl. IV.
    ## 4                                                 Prescott, G.W. 1962. Algae of the Western Great Lakes Area. Wm C. Brown. Dubuque, Iowa. 977pp.
    ## 5                                                          Uherkovich, G. 1966. Die Scenedesmus-Arten Ungarns. Akademiai Kiado. Budapest. 173pp.
    ## 6 Cleve, P.T. 1894. Synopsis of the naviculoid diatoms. Part I. Kongliga svenska Vetenskaps-Akademiens Handlingar, Ny Foljd 26(2): 1-194, 5 pls.

    my_search_result_data[[1]]$tables$observation %>% head()

    ##                         observation_id      event_id
    ## 1 b0c9b74a-d3cd-4bb5-b44e-a2361814a47f ARIK.20140715
    ## 2 23e8b755-c7a1-4663-bd52-4e1449a57f41 ARIK.20140715
    ## 3 969252a8-691d-4f7a-aab5-969f8e8ad166 ARIK.20140715
    ## 4 b8aa0bab-3e9d-4a53-a049-acb67ea4e4e6 ARIK.20140715
    ## 5 ebebb1a0-f7db-4b23-86cc-1c37e8728bdb ARIK.20140715
    ## 6 e1078745-9d0b-421c-8697-88e8deed232a ARIK.20140715
    ##                     package_id    location_id observation_datetime
    ## 1 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ## 2 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ## 3 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ## 4 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ## 5 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ## 6 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ##         taxon_id variable_name    value     unit
    ## 1  NEONDREX33185  cell density 25936568 cells/m2
    ## 2   NEONDREX1024  cell density  2803955 cells/m2
    ## 3 NEONDREX110005  cell density  4205932 cells/m2
    ## 4  NEONDREX45002  cell density  1401977 cells/m2
    ## 5 NEONDREX510001  cell density 33702795 cells/m2
    ## 6   NEONDREX1010  cell density  6308886 cells/m2

    # This data product has algal densities reported for both
    # lakes and streams, so densities could be standardized
    # either to volume collected or area sampled. 
    
    # Verify that only benthic algae standardized to area 
    # are returned in this data pull:
    my_search_result_data[[1]]$tables$observation$unit %>%
        unique()

    ## [1] "cells/m2"

## Join Observation and Taxon info

Next, we join the observation and taxon information so that we can see the full taxonomic information, rather than just the taxon_id, for each sampling event:


    # join observations with taxon info
    alg_observations_with_taxa <- my_search_result_data[[1]]$tables$observation %>%
      filter(!is.na(value)) %>%
      left_join(my_search_result_data[[1]]$tables$taxon) %>%
      select(-authority_taxon_id) %>%
      distinct()

    ## Joining, by = "taxon_id"

    alg_observations_with_taxa %>% head()

    ##                         observation_id      event_id
    ## 1 b0c9b74a-d3cd-4bb5-b44e-a2361814a47f ARIK.20140715
    ## 2 23e8b755-c7a1-4663-bd52-4e1449a57f41 ARIK.20140715
    ## 3 969252a8-691d-4f7a-aab5-969f8e8ad166 ARIK.20140715
    ## 4 b8aa0bab-3e9d-4a53-a049-acb67ea4e4e6 ARIK.20140715
    ## 5 ebebb1a0-f7db-4b23-86cc-1c37e8728bdb ARIK.20140715
    ## 6 e1078745-9d0b-421c-8697-88e8deed232a ARIK.20140715
    ##                     package_id    location_id observation_datetime
    ## 1 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ## 2 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ## 3 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ## 4 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ## 5 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ## 6 DP1.20166.001.20200731104234 ARIK.AOS.reach  2014-07-15 18:00:00
    ##         taxon_id variable_name    value     unit taxon_rank
    ## 1  NEONDREX33185  cell density 25936568 cells/m2    species
    ## 2   NEONDREX1024  cell density  2803955 cells/m2    species
    ## 3 NEONDREX110005  cell density  4205932 cells/m2    species
    ## 4  NEONDREX45002  cell density  1401977 cells/m2    variety
    ## 5 NEONDREX510001  cell density 33702795 cells/m2    species
    ## 6   NEONDREX1010  cell density  6308886 cells/m2    species
    ##                                               taxon_name  authority_system
    ## 1                    Eunotia bilunaris (Ehrenberg) Souza NEON_external_lab
    ## 2               Achnanthidium exiguum (Grunow) Czarnecki NEON_external_lab
    ## 3                    Encyonema silesiacum (Bleisch) Mann NEON_external_lab
    ## 4 Meridion circulare var. constrictum (Ralfs) Van Heurck NEON_external_lab
    ## 5             Scenedesmus quadricauda (Turpin) Brébisson NEON_external_lab
    ## 6         Achnanthidium minutissimum (Kützing) Czarnecki NEON_external_lab

We can also make a quick plot to see which taxon rank (i.e., what level of taxonomic specificity was achieved by the expert taxonomist) is most common:


    # which taxon rank is most common
    alg_observations_with_taxa %>%
      ggplot(aes(taxon_rank)) +
      geom_bar()

![ ]({{ site.baseurl }}/images/rfigs/R/SFS-2020/02_ecocomDP_workflow_with_NEON_algae/plot-taxon-rank-1.png)

## Species Accumulation Curve
Next, we will plot the species accumulation curve for these samples. To do so, we will first need to convert the density data from m2 to cm2, and make the data 'wide':


    # convert densities from per m2 to per cm2
    alg_dens_long <- alg_observations_with_taxa %>%
      mutate(dens_cm2 = (value / 10000)) %>%
      filter(taxon_rank == "species") %>%
      select(event_id, taxon_id, dens_cm2)
    
    # make data wide
    alg_dens_wide <- alg_dens_long %>% 
      pivot_wider(names_from = taxon_id, 
                  values_from = dens_cm2,
                  values_fill = list(dens_cm2 = 0),
                  values_fn = list(dens_cm2 = mean)) %>%
      tibble::column_to_rownames("event_id")
      
    # Calculate and plot species accumulcation curve for the 11 sampling events
    # The CIs are based on random permutations of observed samples
    alg_spec_accum_result <- alg_dens_wide %>% vegan::specaccum(., "random")
    plot(alg_spec_accum_result)

![ ]({{ site.baseurl }}/images/rfigs/R/SFS-2020/02_ecocomDP_workflow_with_NEON_algae/SAC-1-1.png)

## Compare Observed and Simulated species accumulation curves


    # Extract the resampling data used in the above algorithm
    spec_resamp_data <- data.frame(
      data_set = "observed", 
      sampling_effort = rep(1:nrow(alg_spec_accum_result$perm), 
                            each = ncol(alg_spec_accum_result$perm)),
      richness = c(t(alg_spec_accum_result$perm)))
    
    
    # Fit species accumulation model
    spec_accum_mod_1 <- alg_dens_wide %>% vegan::fitspecaccum(model = "arrh")
    
    
    # create a "predicted" data set from the model to extrapolate out 
    # beyond the number of samples collected
    sim_spec_data <- data.frame()
    for(i in 1:25){
      d_tmp <- data.frame(
        data_set = "predicted",
        sampling_effort = i,
        richness = predict(spec_accum_mod_1, newdata = i))
      
      sim_spec_data <- sim_spec_data %>%
        bind_rows(d_tmp)
    }
    
    
    # plot the "observed" and "simulated" curves with 95% CIs
    data_plot <- spec_resamp_data %>% bind_rows(sim_spec_data) 
    
    # Note that the stat_summary function, as used here, requires
    # the Hmisc package to be installed, though you do not need
    # to load Hmisc using the 'library()' funciton
    data_plot %>%
      ggplot(aes(sampling_effort, richness, 
                 color = as.factor(data_set),
                 fill = as.factor(data_set),
                 linetype = as.factor(data_set))) +
      stat_summary(fun.data = median_hilow, fun.args = list(conf.int = .95), 
                   geom = "ribbon", alpha = 0.25) +
      stat_summary(fun.data = median_hilow, geom = "line", 
                   size = 1) 

![ ]({{ site.baseurl }}/images/rfigs/R/SFS-2020/02_ecocomDP_workflow_with_NEON_algae/compare-obs-sim-SAC-1.png)
