---
title: "Explore biodiversity with NEON algae data"
syncID: a112429a90d14c9d8620b956a2469062
description: Download and explore NEON algae data. This includes instruction for using
  ecocomDP package to analyze biodiversity.
dateCreated: '2020-06-22'
authors: Eric R. Sokol
contributors: Donal O'Leary, Felipe Sanchez
estimatedTime: 1 Hour
packagesLibraries: tidyverse, neonUtilities, devtools
topics: data-analysis, organisms, data-viz
languagesTool: R
dataProduct: DP1.20120.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/biodiversity/aquatic-macroinvertebrates/02_ecocomDP_workflow_with_NEON_algae/02_ecocomDP_workflow_with_NEON_algae.R
tutorialSeries: null
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
* **vegan:** `install.packages("vegan")`
* **ecocomDP:** `install.packages("ecocomDP")`

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

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

## Load Libraries and Prepare Workspace
First, we will load all necessary libraries into our R environment. If you have not already installed these libraries, please see the 'R Packages to Install' section above. 

There are also two optional sections in this code chunk: clearing your environment, and loading your NEON API token. Clearing out your environment will erase _all_ of the variables and data that are currently loaded in your R session. This is a good practice for many reasons, but only do this if you are completely sure that you won't be losing any important information! Secondly, your NEON API token will allow you increased download speeds, and helps NEON __anonymously__ track data usage statistics, which helps us optimize our data delivery platforms, and informs our monthly and annual reporting to our funding agency, the National Science Foundation. Please consider signing up for a NEON data user account, and using your token <a href="https://www.neonscience.org/neon-api-tokens-tutorial">as described in this tutorial here</a>.


    # clean out workspace
    
    #rm(list = ls()) # OPTIONAL - clear out your environment
    #gc()            # Uncomment these lines if desired
    
    # load packages
    library(tidyverse)
    library(neonUtilities)
    library(vegan)
    library(ecocomDP)
    
    # source .r file with my NEON_TOKEN
    # source("my_neon_token.R") # OPTIONAL - load NEON token
    # See: https://www.neonscience.org/neon-api-tokens-tutorial



## Download Macroinvertibrate Data
In this first step, we show how to search the ecocomDP database for macroinvertibrate data including those from LTER and NEON sites (and others).

    # search for invertebrate data products
    my_search_result <- 
        ecocomDP::search_data(text = "invertebrate")
    View(my_search_result)
    
    # pull data for the NEON aquatic "Macroinvertebrate
    # collection"
    my_data <- ecocomDP::read_data(
      id = "neon.ecocomdp.20120.001.001",
      site = c('ARIK','MAYF'),
      startdate = "2017-06",
      enddate = "2020-03",
      # token = NEON_TOKEN, #Uncomment to use your token
      check.size = FALSE)

Now that we have downloaded the data, let's take a look at tht `ecocomDP` data object structure:


    # examine the structure of the data object that is returned
    my_data %>% names()

    ## [1] "neon.ecocomdp.20120.001.001"

    my_data$neon.ecocomdp.20120.001.001 %>% names()

    ## [1] "metadata"          "tables"            "validation_issues"

    # short list of package summary data
    my_data$neon.ecocomdp.20120.001.001$metadata$data_package_info

    ## $data_package_id
    ## [1] "neon.ecocomdp.20120.001.001.20210728140025"
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
    ## [1] "original NEON data accessed using neonUtilities v2.1.0"
    ## 
    ## $data_access_date_time
    ## [1] "2021-07-28 14:00:30 MDT"

    # validation issues? None if returns an empty list
    my_data$neon.ecocomdp.20120.001.001$validation_issues

    ## list()

    # examine the tables
    my_data$neon.ecocomdp.20120.001.001$tables %>% names()

    ## [1] "location"              "location_ancillary"    "taxon"                 "observation"           "observation_ancillary"
    ## [6] "dataset_summary"

    my_data$neon.ecocomdp.20120.001.001$tables$taxon %>% head()

    ##   taxon_id taxon_rank           taxon_name
    ## 1   ABLMAL    species Ablabesmyia mallochi
    ## 2    ABLSP      genus      Ablabesmyia sp.
    ## 3   ACASP1   subclass            Acari sp.
    ## 4   ACEPYG    species    Acerpenna pygmaea
    ## 5   ACESP1      genus        Acerpenna sp.
    ## 6   ACRABN    species  Acroneuria abnormis
    ##                                                                                                                        authority_system
    ## 1                                                                                               Epler 2001, and Maschwitz and Cook 2000
    ## 2 Roback 1985 and Epler 2001; Weiderholm, 1983; Weiderholm, 1986; Epler 2001; Ferrington et al. 2019; Andersen, Cranston and Epler 2013
    ## 3                                                                                          Thorp and Covich 2001; Thorp and Rogers 2016
    ## 4                                                                                                          Morihara and McCafferty 1979
    ## 5                                                                                                                   Merritt et al. 2019
    ## 6                                                                                                               Stewart and Stark, 2002
    ##   authority_taxon_id
    ## 1               <NA>
    ## 2               <NA>
    ## 3               <NA>
    ## 4               <NA>
    ## 5               <NA>
    ## 6               <NA>

    my_data$neon.ecocomdp.20120.001.001$tables$observation %>% head()

    ##   observation_id             event_id                                 package_id    location_id   datetime taxon_id
    ## 1          obs_1 ARIK.20170712.CORE.1 neon.ecocomdp.20120.001.001.20210728140025 ARIK.AOS.reach 2017-07-12   CAESP5
    ## 2          obs_2 ARIK.20170712.CORE.1 neon.ecocomdp.20120.001.001.20210728140025 ARIK.AOS.reach 2017-07-12  CERSP10
    ## 3          obs_3 ARIK.20170712.CORE.1 neon.ecocomdp.20120.001.001.20210728140025 ARIK.AOS.reach 2017-07-12   CLASP5
    ## 4          obs_4 ARIK.20170712.CORE.1 neon.ecocomdp.20120.001.001.20210728140025 ARIK.AOS.reach 2017-07-12   CLISP3
    ## 5          obs_5 ARIK.20170712.CORE.1 neon.ecocomdp.20120.001.001.20210728140025 ARIK.AOS.reach 2017-07-12   CORSP4
    ## 6          obs_6 ARIK.20170712.CORE.1 neon.ecocomdp.20120.001.001.20210728140025 ARIK.AOS.reach 2017-07-12   CRYSP2
    ##   variable_name     value                   unit
    ## 1       density 1000.0000 count per square meter
    ## 2       density  333.3333 count per square meter
    ## 3       density  333.3333 count per square meter
    ## 4       density  333.3333 count per square meter
    ## 5       density  166.6667 count per square meter
    ## 6       density  833.3333 count per square meter


## Search ecocomDP

We can even search for terms in the ecocomDP database using regular expressions:


    # search for data sets with periphyton or algae
    # regex works!
    my_search_result <- ecocomDP::search_data(text = "periphyt|algae")
    View(my_search_result)

Let's download the data for the NEON "Periphyton, seston, and phytoplankton collection" from "ARIK" and view its structure:


    # pull data for the NEON "Periphyton, seston, and phytoplankton collection" 
    # data product
    my_data <- 
        ecocomDP::read_data(
          id = "neon.ecocomdp.20166.001.001", 
          site = "ARIK",
          startdate = "2017-06",
          enddate = "2020-03",
          # token = NEON_TOKEN, #Uncomment to use your token
          check.size = FALSE)


    # Explore the structure of the returned data object
    my_data %>% names()

    ## [1] "neon.ecocomdp.20166.001.001"

    my_data[[1]] %>% names()

    ## [1] "metadata"          "tables"            "validation_issues"

    my_data[[1]]$metadata$data_package_info

    ## $data_package_id
    ## [1] "neon.ecocomdp.20166.001.001.20210728140053"
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
    ## [1] "original NEON data accessed using neonUtilities v2.1.0"
    ## 
    ## $data_access_date_time
    ## [1] "2021-07-28 14:00:54 MDT"

    my_data[[1]]$validation_issues

    ## list()

    my_data[[1]]$tables %>% names()

    ## [1] "location"              "location_ancillary"    "taxon"                 "observation"           "observation_ancillary"
    ## [6] "dataset_summary"

    my_data[[1]]$tables$location

    ##      location_id  location_name latitude longitude elevation parent_location_id
    ## 1            D10 Central Plains       NA        NA        NA               <NA>
    ## 2           ARIK Arikaree River 39.75825 -102.4471        NA                D10
    ## 3 ARIK.AOS.reach ARIK.AOS.reach 39.75821 -102.4471    1179.5               ARIK
    ## 4    ARIK.AOS.S2    ARIK.AOS.S2 39.75836 -102.4486    1178.7               ARIK

    my_data[[1]]$tables$taxon %>% head()

    ##           taxon_id taxon_rank            taxon_name
    ## 1 ACHNANTHIDIUMSPP      genus    Achnanthidium spp.
    ## 2       AMPHORASPP      genus          Amphora spp.
    ## 3      ANABAENASPP      genus         Anabaena spp.
    ## 4   AULACOSEIRASPP      genus      Aulacoseira spp.
    ## 5    BACILLARIOCSP      class Bacillariophyceae sp.
    ## 6      CALONEISSPP      genus         Caloneis spp.
    ##                                                                                                                                                                                                                                           authority_system
    ## 1                                                   Academy of Natural Sciences of Drexel University and collaborators. 2011 - 2016. ANSP/NAWQA/EPA 2011 diatom and non-diatom taxa names, http://diatom.ansp.org/nawqa/Taxalist.aspx, accessed 1/11/2016.
    ## 2                                                   Academy of Natural Sciences of Drexel University and collaborators. 2011 - 2016. ANSP/NAWQA/EPA 2011 diatom and non-diatom taxa names, http://diatom.ansp.org/nawqa/Taxalist.aspx, accessed 1/11/2016.
    ## 3                                                   Academy of Natural Sciences of Drexel University and collaborators. 2011 - 2016. ANSP/NAWQA/EPA 2011 diatom and non-diatom taxa names, http://diatom.ansp.org/nawqa/Taxalist.aspx, accessed 1/11/2016.
    ## 4                                                   Academy of Natural Sciences of Drexel University and collaborators. 2011 - 2016. ANSP/NAWQA/EPA 2011 diatom and non-diatom taxa names, http://diatom.ansp.org/nawqa/Taxalist.aspx, accessed 1/11/2016.
    ## 5 Academy of Natural Sciences of Drexel University; Academy of Natural Sciences of Drexel University and collaborators. 2011 - 2016. ANSP/NAWQA/EPA 2011 diatom and non-diatom taxa names, http://diatom.ansp.org/nawqa/Taxalist.aspx, accessed 1/11/2016.
    ## 6                                                   Academy of Natural Sciences of Drexel University and collaborators. 2011 - 2016. ANSP/NAWQA/EPA 2011 diatom and non-diatom taxa names, http://diatom.ansp.org/nawqa/Taxalist.aspx, accessed 1/11/2016.
    ##   authority_taxon_id
    ## 1               <NA>
    ## 2               <NA>
    ## 3               <NA>
    ## 4               <NA>
    ## 5               <NA>
    ## 6               <NA>

    my_data[[1]]$tables$observation %>% head()

    ##                         observation_id                  event_id                                 package_id    location_id
    ## 1 2f9cd348-0767-4322-b7b8-19182778a98c ARIK.20170718.EPIPHYTON.3 neon.ecocomdp.20166.001.001.20210728140053 ARIK.AOS.reach
    ## 2 fcb13e4f-2cf6-4d97-9c70-09a70f51fb7e ARIK.20170718.EPIPHYTON.3 neon.ecocomdp.20166.001.001.20210728140053 ARIK.AOS.reach
    ## 3 c2a8fcf8-1cf2-42da-868b-077ea1726433 ARIK.20170718.EPIPHYTON.3 neon.ecocomdp.20166.001.001.20210728140053 ARIK.AOS.reach
    ## 4 6c0a36d3-0075-4d17-bc0a-03b35cb5f179 ARIK.20170718.EPIPHYTON.3 neon.ecocomdp.20166.001.001.20210728140053 ARIK.AOS.reach
    ## 5 6493f9e6-d1b6-42fd-9156-bb4fb97b2854 ARIK.20170718.EPIPHYTON.3 neon.ecocomdp.20166.001.001.20210728140053 ARIK.AOS.reach
    ## 6 63ed13f7-f9ee-46b9-aea4-2fc2c3cfdd09 ARIK.20170718.EPIPHYTON.3 neon.ecocomdp.20166.001.001.20210728140053 ARIK.AOS.reach
    ##     datetime       taxon_id variable_name     value      unit
    ## 1 2017-07-18  NEONDREX48126  cell density 1180.3455 cells/cm2
    ## 2 2017-07-18  NEONDREX33185  cell density  295.0864 cells/cm2
    ## 3 2017-07-18 NEONDREX197003  cell density  147.5409 cells/cm2
    ## 4 2017-07-18 NEONDREX170133  cell density  590.1727 cells/cm2
    ## 5 2017-07-18  NEONDREX37156  cell density  295.0864 cells/cm2
    ## 6 2017-07-18 NEONDREX155017  cell density 2655.7727 cells/cm2

## Algae Data Flattening and Cleaning

While the ecocomDP data package takes care of some data cleaning and formatting, it is best to join all the tables and flatten the dataset and do some basic checks before proceeding with plotting and analyses:


    # flatten the ecocomDP data tables into one flat table
    my_data_flat <- my_data[[1]]$tables %>% ecocomDP::flatten_data()
    
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
      dplyr::filter(
        !variable_name %in% c("valves","cells"),
        unit == "cells/cm2")
    
    # Note that for this data product
    # neon_sample_id = event_id
    # event_id is the grouping variable for the observation 
    # table in the ecocomDP data model
    
    
    
    # Check for multiple taxon counts per taxon_id by 
    # event_id. 
    my_data_benthic %>% 
      group_by(event_id, taxon_id) %>%
      summarize(n_obs = length(event_id)) %>%
      dplyr::filter(n_obs > 1)

    ## # A tibble: 91 x 3
    ## # Groups:   event_id [10]
    ##    event_id                  taxon_id       n_obs
    ##    <chr>                     <chr>          <int>
    ##  1 ARIK.20170718.EPIPHYTON.2 NEONDREX1010       2
    ##  2 ARIK.20170718.EPIPHYTON.2 NEONDREX1024       2
    ##  3 ARIK.20170718.EPIPHYTON.2 NEONDREX110005     2
    ##  4 ARIK.20170718.EPIPHYTON.2 NEONDREX155017     2
    ##  5 ARIK.20170718.EPIPHYTON.2 NEONDREX16004      2
    ##  6 ARIK.20170718.EPIPHYTON.2 NEONDREX16011      2
    ##  7 ARIK.20170718.EPIPHYTON.2 NEONDREX170133     2
    ##  8 ARIK.20170718.EPIPHYTON.2 NEONDREX170134     2
    ##  9 ARIK.20170718.EPIPHYTON.2 NEONDREX172001     2
    ## 10 ARIK.20170718.EPIPHYTON.2 NEONDREX172006     2
    ## # ... with 81 more rows

    # Per instructions from the lab, these 
    # counts should be summed.
    my_data_summed <- my_data_benthic %>%
      group_by(event_id,taxon_id) %>%
      summarize(value = sum(value, na.rm = FALSE))
    
    my_data_cleaned <- my_data_benthic %>%
      dplyr::select(
        event_id, location_id, datetime,
        taxon_id, taxon_rank, taxon_name) %>%
      distinct() %>%
      right_join(my_data_summed)
    
    
    
    # check for duplicate records, there should not 
    # be any at this point.
    my_data_cleaned %>% 
      group_by(event_id, taxon_id) %>%
      summarize(n_obs = length(event_id)) %>%
      dplyr::filter(n_obs > 1)

    ## # A tibble: 0 x 3
    ## # Groups:   event_id [0]
    ## # ... with 3 variables: event_id <chr>, taxon_id <chr>, n_obs <int>

We can also make a quick plot to see which taxon rank (i.e., what level of taxonomic specificity was achieved by the expert taxonomist) is most common:


    # which taxon rank is most common
    my_data_cleaned %>%
      ggplot(aes(taxon_rank)) +
      geom_bar()

![Bar plot showing the frequency of each taxonomic rank observed in algae count data from the Arikaree River site.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials//R/biodiversity/aquatic-macroinvertebrates/02_ecocomDP_workflow_with_NEON_algae/rfigs/plot-taxon-rank-1.png)

## Species Accumulation Curve
Next, we will plot the species accumulation curve for these samples. To do so, we will first need to convert the density data from m2 to cm2, and make the data 'wide':


    # convert densities from per m2 to per cm2
    my_data_long <- my_data_cleaned %>%
      filter(taxon_rank == "species") %>%
      select(event_id, taxon_id, value)
    
    # make data wide
    my_data_wide <- my_data_long %>% 
      pivot_wider(names_from = taxon_id, 
                  values_from = value,
                  values_fill = list(value = 0)) %>%
      tibble::column_to_rownames("event_id")
      
    # Calculate and plot species accumulcation curve for the 11 sampling events
    # The CIs are based on random permutations of observed samples
    alg_spec_accum_result <- my_data_wide %>% vegan::specaccum(., "random")
    plot(alg_spec_accum_result)

![Species accumalation plot for 11 sampling events. Confidence intervals are based on random permutations of observed samples.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials//R/biodiversity/aquatic-macroinvertebrates/02_ecocomDP_workflow_with_NEON_algae/rfigs/SAC-1-1.png)

## Compare Observed and Simulated species accumulation curves


    # Extract the resampling data used in the above algorithm
    spec_resamp_data <- data.frame(
      data_set = "observed", 
      sampling_effort = rep(1:nrow(alg_spec_accum_result$perm), 
                            each = ncol(alg_spec_accum_result$perm)),
      richness = c(t(alg_spec_accum_result$perm)))
    
    
    # Fit species accumulation model
    spec_accum_mod_1 <- my_data_wide %>% vegan::fitspecaccum(model = "arrh")
    
    
    # create a "predicted" data set from the model to extrapolate out 
    # beyond the number of samples collected
    sim_spec_data <- data.frame()
    for(i in 1:100){
      d_tmp <- data.frame(
        data_set = "predicted",
        sampling_effort = i,
        richness = predict(spec_accum_mod_1, newdata = i))
      
      sim_spec_data <- sim_spec_data %>%
        bind_rows(d_tmp)
    }
    
    
    # plot the "observed" and "simulated" curves with 95% CIs
    data_plot <- spec_resamp_data %>% bind_rows(sim_spec_data) 
    
    data_plot %>%
      ggplot(aes(sampling_effort, richness, 
                 color = as.factor(data_set),
                 fill = as.factor(data_set),
                 linetype = as.factor(data_set))) +
      stat_summary(fun.data = median_hilow, fun.args = list(conf.int = .95), 
                   geom = "ribbon", alpha = 0.25) +
      stat_summary(fun.data = median_hilow, geom = "line", 
                   size = 1) 

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials//R/biodiversity/aquatic-macroinvertebrates/02_ecocomDP_workflow_with_NEON_algae/rfigs/compare-obs-sim-SAC-1.png)
