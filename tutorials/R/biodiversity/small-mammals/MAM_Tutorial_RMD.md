---
syncID: TBD
title: "mammal-data-intro"
description: "This tutorial will provide an introduction to discovering, accessing and preparing NEON small mammal collection data using R"
dateCreated: 2022-12-08
authors: Sara Paull
contributors: Sara Paull
estimatedTime: 1.5 hrs
packagesLibraries: neonUtilities, dplyr
topics: data-analysis, data-visualization
languagesTool: R
dataProduct: DP1.10072.001
code1: TBD
tutorialSeries: NA
urlTitle: TBD
---

<div id="ds-objectives" markdown="1">

## Learning Objectives 
After completing this tutorial you will be able to: 

* Download NEON small mammal data. 
* Generate simple abundance metrics.
* Calculate and visualize diversity metrics

<div id="ds-objectives" markdown="1">

## Things You’ll Need To Complete This Tutorial

### R Programming Language
You will need a current version of R to complete this tutorial. We also recommend 
the RStudio IDE to work with R. 

</div>

## 1. Setup

### Load Packages
Start by installing and loading packages (if necessary) and setting 
options. Installation can be run once, then periodically to get package updates.


    * **dplyr:** `install.packages("dplyr")`

    * **neonUtilities:** `install.packages("neonUtilities")`

    * **neonOS:** `install.packages("neonOS")`

    * **ggplot2:** `install.packages("ggplot2")`

<a href="/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

Now load packages. This needs to be done every time you run code. 
We'll also set a working directory for data downloads.


    library(dplyr)

    library(neonUtilities)

    library(neonOS)

    library(ggplot2)

### Download NEON Small Nammal Data
Download the small mammal box trapping data using the `loadByProduct()` function in
the `neonUtilities` package. Inputs needed to the function are:

* `dpID`: data product ID; woody vegetation structure = DP1.10072.001
* `site`: (vector of) 4-letter site codes; SCBI, SRER, UNDE
* `package`: basic or expanded; we'll download basic here
* `check.size`: should this function prompt the user with an estimated download size? Set to `FALSE` here for ease of processing as a script, but good to leave as default `TRUE` when downloading a dataset for the first time.

Refer to the <a href="https://www.neonscience.org/sites/default/files/cheat-sheet-neonUtilities.pdf" target="_blank">cheat sheet</a> 
for the `neonUtilities` package for more details if desired.


    mamdat <- loadByProduct(dpID="DP1.10072.001", 
                             site=c("SCBI", "SRER", "UNDE"),
                             package="basic", 
                             check.size = FALSE,
                            startdate = "2021-01",
                            enddate = "2022-12")

### Set Working Directory if Needed
If the data are not loaded directly into the R session with loadByProduct, this lesson assumes that you have set your working directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>


    #Set working directory

    #wd<-"~/data"

    #setwd(wd)

### NEON Data Citation:
The data used in this tutorial were collected at the 
<a href="http://www.neonscience.org" target="_blank"> National Ecological Observatory Network's</a> 
<a href="/field-sites/field-sites-map" target="_blank"> field sites</a>.  

* NEON (National Ecological Observatory Network). Small mammal box trapping (DP1.10072.001). https://data.neonscience.org (accessed on 2022-12-16)

## 2. Compiling the NEON Small Mammal Data
The data are downloaded into a list of separate tables. Before working with the data the tables are added to the R environment


    #View all tables in the list of downloaded small mammal data:

    names(mamdat)

    ## [1] "categoricalCodes_10072" "issueLog_10072"         "mam_perplotnight"      
    ## [4] "mam_pertrapnight"       "readme_10072"           "validation_10072"      
    ## [7] "variables_10072"

    # The categoricalCodes file provides controlled 

    # lists used in the data

    

    # The issueLog and readme have the same information that you

    # will find on the data product landing page of the data portal

    

    # The mam_perplotnight table includes the date and time for all trap setting efforts and will

    # include an eventID value to indicate a unique bout of sampling in the 2023 release

    

    #The mam_pertrapnight table includes a record for each trap set along with information about any captures and samples.

    

    # The validation file provides the rules that constrain data upon ingest into the NEON database:

    

    # The variables file describes each field in the returned data tables

    

    #Extract the items from the list and add as dataframes in the R environment:

    list2env(mamdat, envir=.GlobalEnv)

    ## <environment: R_GlobalEnv>

### Checking for Duplicates:
It is useful to check the two data tables for duplicate entries.  In the mam_perplotnight table this would be records with the same plot and date.  In the mam_pertrapnight table this would be records with the same nightuid, trap coordinate, and tagID.  It is worth noting that standard function cannot account for multiple captures of untagged individuals in a single trap (trapStatus = 4) and thus those should be filtered out before running the removeDups function.


    #1. check perplotnight table by nightuid using standard removeDups function

    mam_plotNight_nodups <- neonOS::removeDups(data=mam_perplotnight,
                                 variables=variables_10072,
                                 table='mam_perplotnight')

    ## No duplicated key values found!

    #2. check pertrapnight table by nightuid and trapcoordinate using standard removeDups function 

    mam_trapNight_multipleCaps <- mam_pertrapnight %>% filter(trapStatus == "4 - more than 1 capture in one trap" & is.na(tagID) & is.na(individualCode)) #This data subset contains no multiple captures so no further filtering is necessary

    

    mam_trapNight_nodups <- neonOS::removeDups(data=mam_pertrapnight,
                                 variables=variables_10072,
                                 table='mam_pertrapnight') 

    ## No duplicated key values found!

### Joining Tables:
The mam_perplotnight data table contains information about the trapping effort as well as an eventID that can be used to identify the bout of sampling.  These two tables can be joined so that the trapping data will include the associated eventID to group trapping sessions by bout.


    mamjn<-neonOS::joinTableNEON(mam_plotNight_nodups, mam_trapNight_nodups, name1 = "mam_perplotnight", name2 = "mam_pertrapnight")

    

    #It is useful to verify that there are the expected number of records (the total in the pertrapnight table) and that the key variables are not blank/NA.

    which(is.na(mamjn$eventID))

### Additional Quality Verification:
NEON data undergo quality checking and verification procedures at multiple points from the time of data entry up to the point of publication.  Nonetheless, it is considered best practice to check that the data look as they are expected to prior to completing analyses.  

For small mammal data any records that have a tagID should also have a trapStatus that includes the word 'capture'.  Before filtering the data to just the captured individuals from the target taxon it is helpful to ensure that the trapStatus is set correctly.


    trapStatusErrorCheck <- mam_trapNight_nodups %>% 
      filter(!is.na(tagID)) %>% 
      filter(!grepl("capture",trapStatus))

    nrow(trapStatusErrorCheck)

    #There are no records that have a tagID without a captured trapStatus so we can proceed using the trapStatus field to filter the data to only those traps that captured animals.

## 3. Calculating Minimum Number Known Alive:
The minimum number known alive (MNKA) is an index of total small mammal abundance - e.g., Norman A. Slade, Susan M. Blair, An Empirical Test of Using Counts of Individuals Captured as Indices of Population Size, Journal of Mammalogy, Volume 81, Issue 4, November 2000, Pages 1035–1045, https://doi.org/10.1644/1545-1542(2000)081<1035:AETOUC>2.0.CO;2. This approach assumes that a marked individual is present at all sampling points between its first and last capture dates, even if it wasn't actually captured in those interim trapping sessions. 

Start by generating a data table that fills in records of captures of target taxa that are not in the data but are presumed alive on a given trap-night because they were captured before and after that time-point.


    #1. Filter the captures down to the target taxa.  The raw table includes numerous records for opportunistic taxa that are not specifically targeted by our sampling methods.  The small mammal taxonomy table lists each taxonID as being target or not and can be used to filter to only target species.

    

    #Read in master SMALL_MAMMAL taxon table. Use verbose = T to get taxonProtocolCategory

    mam.list <- neonOS::getTaxonList(taxonType="SMALL_MAMMAL", recordReturnLimit=1000, verbose=T)

    

    targetTaxa <- mam.list %>% filter(taxonProtocolCategory == "target") %>% select(taxonID, scientificName)

    

    #Filter trap dataset to just the capture records of target taxa and a few core fields needed for the analyses.

    coreFields <- c("nightuid", "plotID", "collectDate.x", "tagID", "taxonID", "eventID")

    captures <- mamjn %>% 
      filter(grepl("capture",trapStatus) & taxonID %in% targetTaxa$taxonID) %>% 
      select(coreFields) %>%
      rename('collectDate' = 'collectDate.x')

    

    #Next add implicit records of animals assumed present at a given sampling date because they were captured before and after that sample point.

    

    #Generate a column of all of the unique tagIDs included in the dataset

    uTags <- captures %>% select(tagID) %>% filter(!is.na(tagID)) %>% distinct()

    #create empty data frame to populate

    capsNew <- slice(captures,0)

    

    #for each tagged individual, add a record for each night of trapping done on the plots on which it was captured between the first and last dates of capture

    for (i in uTags$tagID){
      indiv <- captures %>% filter(tagID == i)
      firstCap <- as.Date(min(indiv$collectDate), "YYYY-MM-DD", tz = "UTC")
      lastCap <- as.Date(max(indiv$collectDate), "YYYY-MM-DD", tz = "UTC")
      possibleDates <- seq(as.Date(firstCap), as.Date(lastCap), by="days")
      potentialNights <- mam_plotNight_nodups %>% 
        filter(as.character(collectDate) %in% as.character(possibleDates) & 
                                                           plotID %in% indiv$plotID) %>% 
        select(nightuid,plotID, collectDate, eventID) %>% 
        mutate(tagID=i)
      allnights <- left_join(potentialNights, indiv)
      allnights$taxonID<-unique(indiv$taxonID)[1] #Note that taxonID sometimes changes between recaptures.  This uses only the first identification but there are a number of other ways to handle this situation.
      capsNew <- bind_rows(capsNew, allnights)
    }

    

    #check for untagged individuals and add back to the dataset if necessary:

    caps_notags <- captures %>% filter(is.na(tagID))

    caps_notags

Next create a function that takes this data table as the input to calculate the mean minimum number known alive at a given site during a particular bout of sampling. 


    mnka_per_site <- function(capture_data) {
      mnka_by_plot_bout <- capture_data %>% group_by(eventID,plotID) %>% 
        summarize(n=n_distinct(tagID))
        mean_mnka_by_site_bout <- mnka_by_plot_bout %>% mutate(siteID = substr(plotID, 1, 4)) %>%
          group_by(siteID, eventID) %>% 
          summarise(meanMNKA = mean(n))
          return(mean_mnka_by_site_bout)
    }

    

    MNKA<-mnka_per_site(capture_data = capsNew)

    head(MNKA)

    ## # A tibble: 6 × 3
    ## # Groups:   siteID [1]
    ##   siteID eventID      meanMNKA
    ##   <chr>  <chr>           <dbl>
    ## 1 SCBI   SCBI.2021.14     3.33
    ## 2 SCBI   SCBI.2021.18     6   
    ## 3 SCBI   SCBI.2021.22     8.67
    ## 4 SCBI   SCBI.2021.31     8.5 
    ## 5 SCBI   SCBI.2021.35     7   
    ## 6 SCBI   SCBI.2021.39     6.6

Make a graph to visualize the minimum number known alive across sites and years.  


    #If we are interested in just the abundance fluctuations of all Peromyscus leucopus / Peromyscus maniculatis at a site we can first filter the capture dataset down to those 2 species and then run our function and plot the outputs via date.

    splist<-c("PELE", "PEMA")

    PELEPEMA<-capsNew %>% filter(taxonID %in% splist)

    

    MNKA_PE<-mnka_per_site(PELEPEMA)

    

    #Create a dataframe with the first date of collection for each bout to use as the date variable when plotting

    datedf<-mam_plotNight_nodups %>% 
      select(eventID, collectDate) %>% 
      group_by(eventID) %>%
      summarise(Date = min(collectDate)) %>%
      mutate(Year = substr(Date,1,4), MMDD=substr(Date,6,10))

    

    MNKA_PE<-left_join(MNKA_PE, datedf)

    

    PELEabunplot<-ggplot(data=MNKA_PE, aes(x=MMDD, y=meanMNKA, color=Year, group=Year)) +
      geom_point() +
      geom_line()+
      facet_wrap(~siteID) +
      theme(axis.text.x =element_text(angle=90))

    #group tells ggplot which points to group together when connecting via a line.

    

    PELEabunplot

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/biodiversity/small-mammals/rfigs/plot MNKA-1.png)


