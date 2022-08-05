---
title: "Explore NEON biodiversity data using ecocomDP"
syncID: 19fe7b1f052c478c8a7df52e4e03efbf
description: Download and explore NEON algae and aquatic macroinvertebrate data with
  the ecocomDP package for R using the CyVerse Discovery Environment
dateCreated: "2022-01-21"
authors: Eric R. Sokol
contributors: "Donal O'Leary, Michael Culshaw-Maurer, Sydne Record"
estimatedTime: 1.5 Hours
packagesLibraries: tidyverse, neonUtilities, ecocomDP
topics: "data-analysis, organisms, data-viz"
languagesTool: R
dataProduct: DP1.20120.001
code1: "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/biodiversity/ecocomDP/01_ecocomDP_workflow_with_NEON_and_CyVerse/01_ecocomDP_workflow_with_NEON_and_CyVerse.R"
tutorialSeries: null
urlTitle: "neon-biodiversity-ecocomdp-cyverse"
---

<div id="ds-objectives" markdown="1">
## Learning Objectives 
After completing this tutorial you will be able to: 

* Run an RStudio session on the Visual Interactive Computing Environment (VICE) using the CyVerse Discovery Environment.
* Search for and download NEON and LTER organismal datasets.
* Understand and work with the ecocomDP data model.
* Explore NEON and LTER biodiversity datasets with `ecocomDP` plotting functions.
</div>

## Introduction  
In this code-along tutorial, we will 
 - learn about tools to facilitate synthesis
 - where and how to find NEON and LTER data
 - what is LTER
 - what is EDI
 - what is NEON
 - options for downloading and working with the dat
 - First, we will learn how to find and download data directly from the NEON and EDI data portals.
 - Learn how to find, dowonload, and explore data using ecocomDP, why an intermediate data pattern? What tools are available?
explore how to find and download NEON and LTER biodiversity data.   

 - using the ecocomDP package for R, which has been developed by the Environmental Data Initiative (EDI) in collaboration with NEON staff.
 
 
### What is ecocomDP?
"ecocomDP" is both the name of an R package and a data model. 
 
EDI describes the ecocomDP data model as "A dataset design pattern for ecological community data to facilitate synthesis and reuse". 
 
See the ecocomDP GitHub repo here:
<a href="https://github.com/EDIorg/ecocomDP ">https://github.com/EDIorg/ecocomDP</a>.

The motivation is for both NEON biodiversity data products and EDI data packages, including data from the US Long Term Ecological Research (LTER) Network and Macrosystems Biology projects, to be discoverable through a single data search tool, and to be delivered in a standard format. Our objective here is to demonstrate how the workflow will work with NEON biodiversity data packages. 



 
 
## Things you'll need to complete this tutorial  
#### _1. R Programming Language_
You will need some familiarity with the R programming language to complete this tutorial and we recommend you use a version of the [RStudio IDE](https://www.rstudio.com/products/rstudio/). In this tutorial, we will describe how to access an instance of RStudio with all the required packages pre-installed via your web browser using the Visual Interactive Computing Environment (VICE) provided in the [CyVerse Discovery Environment](https://cyverse.org/discovery-environment). Alternatively, you can also complete most of the exercises in this tutorial using a locally installed version of [R](https://cran.r-project.org/) and [RStudio](https://www.rstudio.com/products/rstudio/download/).

#### _2. [OPTIONAL] A NEON user account and API token_
We recommend that you sign up for a NEON user account and set up an API token to access NEON data following the instructions outlined in [this tutorial](https://www.neonscience.org/resources/learning-hub/tutorials/neon-api-tokens-tutorial). This is not required. You can download NEON data without a token, but using an API token will enable faster download speeds. 

#### _3. [OPTIONAL] Create a CyVerse account and request access to VICE_
To use the cloud computing resources available through VICE, you will need to create a CyVerse account and request access to VICE ahead of time (see below). If you choose this option, all of the required R packages should already be installed and you will be able to easily access and/or share large datasets in the [CyVerse Data Store](https://learning.cyverse.org/ds/)  

#### _4. R packages required for this tutorial_
Prior to starting the tutorial, ensure that the following packages are installed (NOTE: these packages should be pre-installed if you are using the VICE RStudio app): 

* **tidyverse:** `install.packages("tidyverse")`
* **neonUtilities:** `install.packages("neonUtilities")`
* **ecocomDP:** `install.packages("ecocomDP")`

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

<div id="ds-cyverse" markdown="1">
## RStudio on the VICE cloud
### Creating a CyVerse Account

To create a CyVerse account, navigate to [user.cyverse.org](https://user.cyverse.org/) and click "Sign Up". You will be prompted to fill in your name, a username, and an email. It is **highly recommended** that you use a `.edu`, `.org`, or `.gov` email address if you have one. Cloud computing platforms are a prime target for cryptocurrency miners, and using an institutional email address makes it easier to verify that you *aren't* one.

You will be prompted to fill out a few more pieces of information about yourself and what you intend to use CyVerse for. Once you have completed the registration process, you will have a CyVerse account and can proceed to the next step.

### Requesting VICE access

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
</div>


## Load libraries and prepare workspace
First, we will load all necessary libraries into our R environment. If you are not using the RStudio VICE app with the packages pre-installed and you have not already installed these libraries, please see the "R packages required for this tutorial" section above. 

    # clean out workspace
    
    #rm(list = ls()) # OPTIONAL - clear out your environment
    #gc()            # Uncomment these lines if desired
    
    # load packages
    library(tidyverse)
    library(neonUtilities)
    library(ecocomDP)




This code chunk also includes two optional lines for clearing out your environment, which will erase _all_ of the variables and data that are currently loaded in your R session. This is a good practice for many reasons, but only do this if you are completely sure that you won't be losing any important information! 

Also, consider using a NEON API token. This will allow you increased download speeds and helps NEON __anonymously__ track data usage statistics, which helps us optimize our data delivery platforms, and informs our monthly and annual reporting to our funding agency, the National Science Foundation. Please consider signing up for a NEON data user account, and using your token <a href="https://www.neonscience.org/neon-api-tokens-tutorial">as described in this tutorial here</a>. The linked tutorial describes a couple options for using your API token if you are running code locally. Below, we provide instructions for setting up an environmental variable to use your API token with the VICE cloud.

<div id="ds-tokensetup" markdown="1">
## Using your NEON_TOKEN with the VICE cloud
1. In your RStudio session running on the VICE app, type the following in the Console:

    usethis::edit_r_environ()
A new .Renviron file will be created. 

2. Add one line to the .Renviron file. There are no quotes around the token value.

    NEON_TOKEN=PASTE YOUR TOKEN HERE

3. Go to "File -> Save As" and then navigate to "work > home > YOUR CYVERSE USERNAME" and save your .Renviron file in your personal storage space. 

4. Read your .Renviron variables to your R session:

    readRenviron("../rstudio/work/home/YOUR CYVERSE USERNAME/.Renviron")

You should be able to use the above line in any R script running on an RStudio instance on the VICE platform to load your environmental variables. 
</div>

Now that our workspace is prepared, let's look at some data.

## How to get data from the source (NEON and EDI data portals)

### EXAMPLE 1: NEON benthic macroinvertebrates
First, take a look at the data product landing page:
https://data.neonscience.org/data-products/DP1.20120.001

Note the abstract, information on latency, the design description, links to relevant documentation, the issue log, and the data availability matrix. Use the data availability matrix to help guide your choice of NEON sites and dates to include in your data download. 

You can download the data using the web interface ([see this video](https://www.youtube.com/watch?v=gaA_duzWnvk)), but today we will learn how to download data from the NEON Data Portal API in an R session.

#### How to download a NEON data product using `neonUtilities`
NEON data are delivered in site-month chunks, so it is necessary to "stack" the data after you have downloaded all of your desired site-month data packages. However, you do not need to worry about data stacking because the NEON staff have developed the `neonUtilities` R package, which provides wrapper functions to interact with the NEON Data Portal API and appropriately unzip and stack the data tables so that they are more user friendly. For more details, see [this tutorial on NEON data stacking](https://www.neonscience.org/resources/learning-hub/tutorials/neondatastackr). Here we use the `loadByProduct` function to download NEON macroinvertebrate data from two sites from 2017-2019. The `loadByProduct` function will extract the zip files, stack the data, and load it into your R environment. See [this cheatsheet](https://www.neonscience.org/sites/default/files/cheat-sheet-neonUtilities.pdf) for more information on neonUtilities. 


    # Download NEON aquatic macroinvertebrate data from the NEON data portal API
    # Should take < 1 minute
    all_tabs_inv <- neonUtilities::loadByProduct(
      dpID = "DP1.20120.001", # the NEON aquatic macroinvert data product
      site = c("COMO","HOPB"), # NEON sites
      startdate = "2017-01", # start year-month
      enddate = "2019-12", # end year-month
      token = Sys.getenv("NEON_TOKEN"), # use NEON_TOKEN environmental variable
      check.size = F) # proceed with download regardless of file size
To download the entire dataset for all sites for all time, don't include the `site`, `startdate`, or `enddate` arguments. 


    # this download as of Aug 2022 is ~100MB
    all_tabs_inv <- neonUtilities::loadByProduct(
      dpID = "DP1.20120.001", # the NEON aquatic macroinvert data product
      token = Sys.getenv("NEON_TOKEN"), # use NEON_TOKEN environmental variable
      check.size = T) # you should probably check the filesize before proceeding

This larger download will take longer and might time out. For the macroinvertebrates data product the download could take ~5 minutes on a typical setup. This is not insurmountable, but you don't want to have to download and stack the data every time you run an analysis. Also, other NEON data products can be much larger. A nice feature about working with VICE is we can download the large dataset one time and store it in a shared space in the CyVerse Data Store. We will access a dataset saved on the Data Store later in this tutorial.

#### NEON macroinvertebrate data wrangling
Now that we have the data downloaded, we will need to do some 'data wrangling' to reorganize our data into a more useful format for typical community ecology analyses. First, let's take a look at some of the tables that were generated by `loadByProduct()`:


    # what tables do you get with macroinvertebrate 
    # data product
    names(all_tabs_inv)

    ## [1] "categoricalCodes_20120" "inv_fieldData"          "inv_persample"          "inv_taxonomyProcessed" 
    ## [5] "issueLog_20120"         "readme_20120"           "validation_20120"       "variables_20120"

    # extract items from list and put in R env. 
    all_tabs_inv %>% list2env(.GlobalEnv)

    ## <environment: R_GlobalEnv>

    # readme has the same informaiton as what you 
    # will find on the landing page on the data portal
    
    # The variables file describes each field in 
    # the returned data tables
    View(variables_20120)
    
    # The validation file provides the rules that 
    # constrain data upon ingest into the NEON database
    View(validation_20120)
    
    # the categoricalCodes file provides controlled 
    # lists used in the data
    View(categoricalCodes_20120)

Next, we will perform several operations in a row to re-organize our data. Each step is described by a code comment.


    # It is good to check for duplicate records. This had occurred in the past in 
    # data published in the inv_fieldData table in 2021. Those duplicates were 
    # fixed in the 2022 data release. 
    # Here we use sampleID as primary key and if we find duplicate records, we
    # keep the first uid associated with any sampleID that has multiple uids
    
    de_duped_uids <- inv_fieldData %>% 
      
      # remove records where no sample was collected
      filter(!is.na(sampleID)) %>%  
      group_by(sampleID) %>%
      summarise(
        n_recs = length(uid),
        n_unique_uids = length(unique(uid)),
        uid_to_keep = dplyr::first(uid)) 
    
    
    
    
    
    # Are there any records that have more than one unique uid?
    max_dups <- max(de_duped_uids$n_unique_uids %>% unique())
    
    
    
    
    
    # filter data using de-duped uids if they exist
    if(max_dups > 1){
      inv_fieldData <- inv_fieldData %>%
      dplyr::filter(uid %in% de_duped_uids$uid_to_keep)
    }
    
    
    
    
    
    # extract year from date, add it as a new column
    inv_fieldData <- inv_fieldData %>%
      mutate(
        year = collectDate %>% 
          lubridate::as_date() %>% 
          lubridate::year())
    
    
    
    
    # extract location data into a separate table
    table_location <- inv_fieldData %>%
    
      # keep only the columns listed below
      select(siteID, 
             domainID,
             namedLocation, 
             decimalLatitude, 
             decimalLongitude, 
             elevation) %>%
      
      # keep rows with unique combinations of values, 
      # i.e., no duplicate records
      distinct()
    
    
    
    
    # create a taxon table, which describes each 
    # taxonID that appears in the data set
    # start with inv_taxonomyProcessed
    table_taxon <- inv_taxonomyProcessed %>%
    
      # keep only the coluns listed below
      select(acceptedTaxonID, taxonRank, scientificName,
             order, family, genus, 
             identificationQualifier,
             identificationReferences) %>%
    
      # remove rows with duplicate information
      distinct()
    
    
    
    # taxon table information for all taxa in 
    # our database can be downloaded here:
    # takes 1-2 minutes
    # full_taxon_table_from_api <- neonUtilities::getTaxonTable("MACROINVERTEBRATE", token = NEON_TOKEN)
    
    
    
    
    # Make the observation table.
    # start with inv_taxonomyProcessed
    
    # check for repeated taxa within a sampleID that need to be added together
    inv_taxonomyProcessed_summed <- inv_taxonomyProcessed %>% 
      select(sampleID,
             acceptedTaxonID,
             individualCount,
             estimatedTotalCount) %>%
      group_by(sampleID, acceptedTaxonID) %>%
      summarize(
        across(c(individualCount, estimatedTotalCount), ~sum(.x, na.rm = TRUE)))
      
    
    
    
    # join summed taxon counts back with sample and field data
    table_observation <- inv_taxonomyProcessed_summed %>%
      
      # Join relevant sample info back in by sampleID
      left_join(inv_taxonomyProcessed %>% 
                  select(sampleID,
                         domainID,
                         siteID,
                         namedLocation,
                         collectDate,
                         acceptedTaxonID,
                         order, family, genus, 
                         scientificName,
                         taxonRank) %>%
                  distinct()) %>%
      
      # Join the columns selected above with two 
      # columns from inv_fieldData (the two columns 
      # are sampleID and benthicArea)
      left_join(inv_fieldData %>% 
                  select(sampleID, eventID, year, 
                         habitatType, samplerType,
                         benthicArea)) %>%
      
      # some new columns called 'variable_name', 
      # 'value', and 'unit', and assign values for 
      # all rows in the table.
      # variable_name and unit are both assigned the 
      # same text strint for all rows. 
      mutate(inv_dens = estimatedTotalCount / benthicArea,
             inv_dens_unit = 'count per square meter')
    
    
    
    
    
    # check for duplicate records, should return a table with 0 rows
    table_observation %>% 
      group_by(sampleID, acceptedTaxonID) %>% 
      summarize(n_obs = length(sampleID)) %>%
      filter(n_obs > 1)

    ## # A tibble: 0 x 3
    ## # Groups:   sampleID [0]
    ## # ... with 3 variables: sampleID <chr>, acceptedTaxonID <chr>, n_obs <int>

    # extract sample info
    table_sample_info <- table_observation %>%
      select(sampleID, domainID, siteID, namedLocation, 
             collectDate, eventID, year, 
             habitatType, samplerType, benthicArea, 
             inv_dens_unit) %>%
      distinct()
    
    
    
    
    # create an occurrence summary table
    taxa_occurrence_summary <- table_observation %>%
      select(sampleID, acceptedTaxonID) %>%
      distinct() %>%
      group_by(acceptedTaxonID) %>%
      summarize(occurrences = n())
    
    
    
    
    # some summary data
    sampling_effort_summary <- table_sample_info %>%
      
      # group by siteID, year
      group_by(siteID, year, samplerType) %>%
      
      # count samples and habitat types within each event
      summarise(
        event_count = eventID %>% unique() %>% length(),
        sample_count = sampleID %>% unique() %>% length(),
        habitat_count = habitatType %>% 
            unique() %>% length())
    
    
    
    
    # check out the summary table
    sampling_effort_summary %>% as.data.frame() %>% 
      head() %>% print()

    ##   siteID year     samplerType event_count sample_count habitat_count
    ## 1   COMO 2017 modifiedKicknet           2            6             1
    ## 2   COMO 2017          surber           2           10             1
    ## 3   COMO 2018 modifiedKicknet           3            9             1
    ## 4   COMO 2018          surber           3           15             1
    ## 5   COMO 2019 modifiedKicknet           2            6             2
    ## 6   COMO 2019          surber           2           10             1
In addition to the `sampling_effort_summary` table displayed above, we have also extracted some other easy to digest summary tables, including:  

 * `table_location` a list of locations in the dataset
 * `table_taxon` a list of the unique taxa included in the dataset
 * `table_observation` a long format table of observations of taxon counts standardized to sampling effort


Now that the data have been "wrangled", we can plot some basic visualizations to explore some characteristics of this dataset. Here we will look at the taxonomic resolution reported in the dataset. Does it make sense for this type of data?

    # no. taxa by rank by site
    table_observation %>% 
      group_by(domainID, siteID, taxonRank) %>%
      summarize(
        n_taxa = acceptedTaxonID %>% 
            unique() %>% length()) %>%
      ggplot(aes(n_taxa, taxonRank)) +
      facet_wrap(~ domainID + siteID) +
      geom_col()

![Horizontal bar graph showing the number of taxa for each taxonomic rank at the D02:POSE, D08:MAYF, and D10:ARIK sites. Including facet_wrap to the ggplot call creates a seperate plot for each of the faceting arguments, which in this case are domainID and siteID.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials//R/biodiversity/ecocomDP/01_ecocomDP_workflow_with_NEON_and_CyVerse/rfigs/long-data-1.png)

What other visualizations would you plot as an initial exploration of this dataset to determine if it would be sufficient for your science question?

#### Working with 'long' and 'wide' data
'Reshaping' your data to use as an input to a particular function may require you to consider: do I want 'long' or 'wide' data? Here's a link to <a href="https://www.theanalysisfactor.com/wide-and-long-data/">a great article from 'the analysis factor' that describes the differences</a>. Our `table_observation` data.frame is currently in long format, however, many tools used in community ecology analyses, such as functions in the `vegan` R package, expect wide-format site-by-species inputs.   

Below, we create a site-by-species table.


    # select only site by species density info and remove duplicate records
    table_sample_by_taxon_density_long <- table_observation %>%
      select(sampleID, acceptedTaxonID, inv_dens) %>%
      distinct() %>%
      filter(!is.na(inv_dens))
    
    
    
    
    # pivot to wide format, sum multiple counts per sampleID
    table_sample_by_taxon_density_wide <- table_sample_by_taxon_density_long %>%
      tidyr::pivot_wider(id_cols = sampleID, 
                         names_from = acceptedTaxonID,
                         values_from = inv_dens,
                         values_fill = list(inv_dens = 0),
                         values_fn = list(inv_dens = sum)) %>%
      column_to_rownames(var = "sampleID") 
    
    # check col and row sums -- mins should all be > 0
    colSums(table_sample_by_taxon_density_wide) %>% min()

    ## [1] 4

    rowSums(table_sample_by_taxon_density_wide) %>% min()

    ## [1] 32


### EXAMPLE 2: North Temperate Lakes (NTL) LTER site benthic macroinvertebrates from the EDI data portal
You can search EDI data holdings at https://portal.edirepository.org/nis/home.jsp. Searching for "benthic macroinvertebrates" will result in data packages from across the LTER network and other NSF funded projects (e.g., data from LTREB and macrosystems projects). For our exmaple, we will use "[North Temperate Lakes LTER: Benthic Macroinvertebrates 1981 - current](https://doi.org/10.6073/pasta/e34b247937277b35905018f728849a10)". If you go to the data package landing page and scroll down to the "Code Generation" section, there are buttons to generate scripts to download the dataset from the EDI data portal API. Try clicking the ["R" button](https://portal.edirepository.org/nis/codeGeneration?packageId=knb-lter-ntl.11.35&statisticalFileType=r) and running that code in your R session. 

 * Are these data suitable for your science question?
 * Are these data comparable to the NEON benthic macroinvertebrate data set? 
 * What visualizations would help you determine if this dataset would be useful in your synthesis study?
 * What data wrangling steps are needed before you proceed?


## Using ecocomDP

Examining the data model for ecocomDP, we see it follows a star-schema with long-format species abundances (or similar) in the `observation` table. The design pattern includes `location`, `taxon`, and other ancillary tables that provide a flexible option to link additional data to observations, events, locations, and taxa. The ecocomDP library for R includes functions to search the EDI and NEON data holdings, read the data into your R session, and functions to work with and plot datasets that are in the ecocomDP format.  

<figure>
<a href="https://raw.githubusercontent.com/EDIorg/ecocomDP/master/documentation/model/ecocomDP.png">
<img src="https://raw.githubusercontent.com/EDIorg/ecocomDP/master/documentation/model/ecocomDP.png" alt="data model workflow showing relationships between various tables in ecocomDP model"> </a>
<figcaption>Data model workflow showing relationships between various tables in ecocomDP model. Source: EDIorg</figcaption>
</figure>


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
      token = Sys.getenv("NEON_TOKEN"), #Uncomment to use your token
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
    ## [1] "neon.ecocomdp.20120.001.001.20220804212220"
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
    ## [1] "original NEON data accessed using neonUtilities v2.1.4"
    ## 
    ## $data_access_date_time
    ## [1] "2022-08-04 21:22:21 MDT"

    # validation issues? None if returns an empty list
    my_data$validation_issues

    ## list()

    # examine the tables
    my_data$tables %>% names()

    ## [1] "location"              "location_ancillary"    "taxon"                 "observation"          
    ## [5] "observation_ancillary" "dataset_summary"

    my_data$tables$taxon %>% head()

    ##   taxon_id taxon_rank       taxon_name                                    authority_system authority_taxon_id
    ## 1    ABLSP      genus  Ablabesmyia sp.                          Roback 1985 and Epler 2001               <NA>
    ## 2   ACASP1   subclass        Acari sp.                               Thorp and Covich 2001               <NA>
    ## 3   ACTSP5      genus Actinobdella sp.                               Thorp and Covich 2001               <NA>
    ## 4    AESSP     family    Aeshnidae sp.                      Needham, Westfall and May 2000               <NA>
    ## 5   AGASP1  subfamily     Agabinae sp.                   Larson, Alarie, and Roughley 2001               <NA>
    ## 6   ANISP1   suborder   Anisoptera sp. Merritt et al. 2008; Needham, Westfall and May 2000               <NA>

    my_data$tables$observation %>% head()

    ##   observation_id             event_id                                 package_id    location_id            datetime
    ## 1          obs_1 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220804212220 ARIK.AOS.reach 2017-03-22 15:30:00
    ## 2          obs_2 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220804212220 ARIK.AOS.reach 2017-03-22 15:30:00
    ## 3          obs_3 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220804212220 ARIK.AOS.reach 2017-03-22 15:30:00
    ## 4          obs_4 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220804212220 ARIK.AOS.reach 2017-03-22 15:30:00
    ## 5          obs_5 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220804212220 ARIK.AOS.reach 2017-03-22 15:30:00
    ## 6          obs_6 ARIK.20170322.CORE.1 neon.ecocomdp.20120.001.001.20220804212220 ARIK.AOS.reach 2017-03-22 15:30:00
    ##   taxon_id variable_name     value                   unit
    ## 1   BERSP4       density  166.6667 count per square meter
    ## 2   CAESP5       density  166.6667 count per square meter
    ## 3  CERSP10       density 1333.3333 count per square meter
    ## 4   CHISP2       density  166.6667 count per square meter
    ## 5    CONGR       density  500.0000 count per square meter
    ## 6   DIASP8       density  500.0000 count per square meter


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
    ## [1] "neon.ecocomdp.20166.001.001.20220804212239"
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
    ## [1] "original NEON data accessed using neonUtilities v2.1.4"
    ## 
    ## $data_access_date_time
    ## [1] "2022-08-04 21:22:40 MDT"

    my_data$validation_issues

    ## list()

    my_data$tables %>% names()

    ## [1] "location"              "location_ancillary"    "taxon"                 "observation"          
    ## [5] "observation_ancillary" "dataset_summary"

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

    ##                         observation_id                  event_id                                 package_id
    ## 1 7a8dc4e5-e50d-4d9b-81c3-a0d374281acf ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220804212239
    ## 2 b3b59b2e-f828-4fb7-b140-3b19438ccda4 ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220804212239
    ## 3 5b865421-e803-4016-a917-2ef34491e913 ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220804212239
    ## 4 1eece2f0-8a4b-4f44-aba4-b55415bd4970 ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220804212239
    ## 5 71502b14-54ed-4142-80e2-c086b40684f7 ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220804212239
    ## 6 b0815b73-2b94-4a7b-8dfb-5a68ce866533 ARIK.20170327.EPIPHYTON.2 neon.ecocomdp.20166.001.001.20220804212239
    ##      location_id            datetime       taxon_id variable_name        value      unit
    ## 1 ARIK.AOS.reach 2017-03-27 18:01:00  NEONDREX48165  cell density    284.27016 cells/cm2
    ## 2 ARIK.AOS.reach 2017-03-27 18:01:00  NEONDREX16011  cell density     94.75605 cells/cm2
    ## 3 ARIK.AOS.reach 2017-03-27 18:01:00 NEONDREX245001  cell density   2179.40121 cells/cm2
    ## 4 ARIK.AOS.reach 2017-03-27 18:01:00 NEONDREX543001  cell density 136449.47581 cells/cm2
    ## 5 ARIK.AOS.reach 2017-03-27 18:01:00  NEONDREX48004  cell density    284.27016 cells/cm2
    ## 6 ARIK.AOS.reach 2017-03-27 18:01:00  NEONDREX48023  cell density     94.75605 cells/cm2


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
