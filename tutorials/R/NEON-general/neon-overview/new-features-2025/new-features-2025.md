---
syncID: 029b47b720dd471293cea2f7cab876fc
title: "New Resources for Working with NEON Data"
description: "Overview of the latest updates and new code resources as of fall 2025."
dateCreated: 2025-09-30
authors: Claire K. Lunch
contributors: 
estimatedTime: 60 minutes
packagesLibraries: neonUtilities, neonOS
topics: 
languageTool: R, Python
dataProduct: 
code1: 
tutorialSeries:
urlTitle: new-features-2025

---


This tutorial provides a tour of recent (as of fall 2025) updates and enhancements to NEON code resources.

If you are new to using NEON data, we recommend first following the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data" target="_blank">Download and Explore</a> tutorial to get familiar with NEON data formats and the `neonUtilities` package.




## Set up R environment

First install and load the necessary packages.


    # install packages. can skip this step if 

    # the packages are already installed

    install.packages("neonUtilities")

    install.packages("lubridate")

    install.packages("devtools")

    devtools::install_github("NEONScience/NEON-geolocation/geoNEON")

    

    # load packages

    library(neonUtilities)

    library(geoNEON)

    library(ggplot2)

    library(lubridate)




## The neonOS package

The `neonOS` package provides functions specifically for working with NEON observational (OS) data products. NEON's human-collected data present some unique challenges: the structure and data relationships within each product are unique, automation is more difficult, and sample relationships are often essential. The `neonOS` package contains functions for duplicate checking, table joining, and sample exploration.

For a detailed introduction to the `neonOS` package, see the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/neonos-duplicates-joins" target="_blank">full tutorial</a>. Here we'll do a quick overview.

We'll use soil data throughout as an example dataset to illustrate code features. Let's say we're interested in the relationships between soil chemistry, microbial communities, and disturbance events. Start by downloading Soil physical and chemical properties, periodic (DP1.10086.001) from Soaproot Saddle (SOAP), 2018-2024.

### Feature: Omit progress bars

Progress bars can now be suppressed in download functions in the `neonUtilities` package. This can be helpful when running code in an automated workflow or batch script. Note that messages associated with progress will be suppressed along with the bars, but messages about exceptions or errors will still be printed to the console.


    soil <- loadByProduct(dpID="DP1.10086.001", 
                         site="SOAP",
                         startdate="2018-01",
                         enddate="2024-12",
                         include.provisional=T,
                         progress=F,
                         check.size=F)

    

    list2env(soil, .GlobalEnv)

    ## <environment: R_GlobalEnv>

To start, we want to assess whether soil moisture is associated with different nitrogen content. Moisture data are in the `sls_soilMoisture` table, and nitrogen data are in the `sls_soilChemistry` table. We'll need to join the tables.

But before joining, let's check both tables for duplicates.

### Feature: Check for duplicate records


    moisturedups <- removeDups(sls_soilMoisture, 
                               variables_10086)

    ## No duplicated key values found!

    chemdups <- removeDups(sls_soilChemistry,
                           variables_10086)

    ## No duplicated key values found!

Neither table contains any duplicates. This is common - staff internal to NEON take advantage of these code resources, too, and use them to detect and resolve duplicates. However, especially if you use Provisional data, it's a good idea to check. See the `neonOS` <a href="https://www.neonscience.org/resources/learning-hub/tutorials/neonos-duplicates-joins" target="_blank">tutorial</a> for more details about the `removeDups()` function, and to see an example that does contain duplicates.

Now we can join the tables.

### Feature: Join observational data tables


    moistchem <- joinTableNEON(sls_soilMoisture,
                               sls_soilChemistry)

Now that we have the nitrogen and moisture data in a single table, we can compare.


    plot(nitrogenPercent~soilMoisture, 
         data=moistchem,
         pch=20)

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/new-features-2025/rfigs/plot-chem-moist-1.png)

Within this dataset, wetter soils tend to also be higher in nitrogen.

## Event data

We are also interested in the impact of disturbance on these soils. Soaproot Saddle is in California - has it burned during the observed time period?

The Site management and event reporting (DP1.10111.001) data product contains records of disturbance and management events that occur at NEON sites. We could download all records from SOAP, but a new function in `neonUtilities` allows us to run a targeted query for specific event types.

### Feature: Get event data by event type


    sim <- byEventSIM("fire", site="SOAP")

    

    sim$sim_eventData

    ##                                    uid domainID siteID namedLocation
    ## 1 2c8c0bf8-caf0-4c48-bad3-590d0e737047      D17   SOAP          SOAP
    ## 2 0c1fcf9f-5bee-478c-8412-0bf57925a04b      D17   SOAP          SOAP
    ## 3 4ffe7ac8-ff68-48e8-97e6-2efd446cd3da      D17   SOAP          SOAP
    ## 4 53b0b814-8441-41c4-a44b-91fc3413d97b      D17   SOAP          SOAP
    ## 5 6b641a93-0494-4998-9d8a-c56df5d70891      D17   SOAP          SOAP
    ## 6 8bc10c21-79b3-4421-b0ae-703f98067e6f      D17   SOAP          SOAP
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 locationID
    ## 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             SOAP_007.basePlot.all, SOAP_016.basePlot.all, SOAP_017.basePlot.all, SOAP_018.basePlot.all, SOAP_019.basePlot.all, SOAP_003.tickPlot.tck, SOAP_036.mosquitoPoint.mos, SOAP_039.mosquitoPoint.mos, SOAP_041.mosquitoPoint.mos
    ## 2 SOAP_002.basePlot.all, SOAP_005.basePlot.all, SOAP_006.basePlot.all, SOAP_008.basePlot.all, SOAP_012.basePlot.all, SOAP_013.basePlot.all, SOAP_023.basePlot.all, SOAP_024.basePlot.all, SOAP_026.basePlot.all, SOAP_027.basePlot.all, SOAP_028.basePlot.all, SOAP_043.basePlot.all, SOAP_044.basePlot.all, SOAP_046.basePlot.all, SOAP_050.basePlot.all, SOAP_051.basePlot.all, SOAP_052.basePlot.all, SOAP_055.basePlot.all, SOAP_058.basePlot.all, SOAP_059.basePlot.all, SOAP_060.basePlot.all, SOAP_061.basePlot.all, SOAP_005.tickPlot.tck, SOAP_006.tickPlot.tck, SOAP_026.tickPlot.tck, SOAP_002.mammalGrid.mam, SOAP_006.mammalGrid.mam, SOAP_008.mammalGrid.mam, SOAP_012.mammalGrid.mam, SOAP_032.mammalGrid.mam, SOAP_033.mosquitoPoint.mos, SOAP_035.mosquitoPoint.mos, SOAP_037.mosquitoPoint.mos, SOAP_038.mosquitoPoint.mos, SOAP_039.mosquitoPoint.mos, SOAP_040.mosquitoPoint.mos, SOAP
    ## 3 SOAP_002.basePlot.all, SOAP_005.basePlot.all, SOAP_006.basePlot.all, SOAP_008.basePlot.all, SOAP_012.basePlot.all, SOAP_013.basePlot.all, SOAP_023.basePlot.all, SOAP_024.basePlot.all, SOAP_026.basePlot.all, SOAP_027.basePlot.all, SOAP_028.basePlot.all, SOAP_043.basePlot.all, SOAP_044.basePlot.all, SOAP_046.basePlot.all, SOAP_050.basePlot.all, SOAP_051.basePlot.all, SOAP_052.basePlot.all, SOAP_055.basePlot.all, SOAP_058.basePlot.all, SOAP_059.basePlot.all, SOAP_060.basePlot.all, SOAP_061.basePlot.all, SOAP_005.tickPlot.tck, SOAP_006.tickPlot.tck, SOAP_026.tickPlot.tck, SOAP_002.mammalGrid.mam, SOAP_006.mammalGrid.mam, SOAP_008.mammalGrid.mam, SOAP_012.mammalGrid.mam, SOAP_032.mammalGrid.mam, SOAP_033.mosquitoPoint.mos, SOAP_035.mosquitoPoint.mos, SOAP_037.mosquitoPoint.mos, SOAP_038.mosquitoPoint.mos, SOAP_039.mosquitoPoint.mos, SOAP_040.mosquitoPoint.mos, SOAP
    ## 4 SOAP_002.basePlot.all, SOAP_005.basePlot.all, SOAP_006.basePlot.all, SOAP_008.basePlot.all, SOAP_012.basePlot.all, SOAP_013.basePlot.all, SOAP_023.basePlot.all, SOAP_024.basePlot.all, SOAP_026.basePlot.all, SOAP_027.basePlot.all, SOAP_028.basePlot.all, SOAP_043.basePlot.all, SOAP_044.basePlot.all, SOAP_046.basePlot.all, SOAP_050.basePlot.all, SOAP_051.basePlot.all, SOAP_052.basePlot.all, SOAP_055.basePlot.all, SOAP_058.basePlot.all, SOAP_059.basePlot.all, SOAP_060.basePlot.all, SOAP_061.basePlot.all, SOAP_005.tickPlot.tck, SOAP_006.tickPlot.tck, SOAP_026.tickPlot.tck, SOAP_002.mammalGrid.mam, SOAP_006.mammalGrid.mam, SOAP_008.mammalGrid.mam, SOAP_012.mammalGrid.mam, SOAP_032.mammalGrid.mam, SOAP_033.mosquitoPoint.mos, SOAP_035.mosquitoPoint.mos, SOAP_037.mosquitoPoint.mos, SOAP_038.mosquitoPoint.mos, SOAP_039.mosquitoPoint.mos, SOAP_040.mosquitoPoint.mos, SOAP
    ## 5 SOAP_002.basePlot.all, SOAP_005.basePlot.all, SOAP_006.basePlot.all, SOAP_008.basePlot.all, SOAP_012.basePlot.all, SOAP_013.basePlot.all, SOAP_023.basePlot.all, SOAP_024.basePlot.all, SOAP_026.basePlot.all, SOAP_027.basePlot.all, SOAP_028.basePlot.all, SOAP_043.basePlot.all, SOAP_044.basePlot.all, SOAP_046.basePlot.all, SOAP_050.basePlot.all, SOAP_051.basePlot.all, SOAP_052.basePlot.all, SOAP_055.basePlot.all, SOAP_058.basePlot.all, SOAP_059.basePlot.all, SOAP_060.basePlot.all, SOAP_061.basePlot.all, SOAP_005.tickPlot.tck, SOAP_006.tickPlot.tck, SOAP_026.tickPlot.tck, SOAP_002.mammalGrid.mam, SOAP_006.mammalGrid.mam, SOAP_008.mammalGrid.mam, SOAP_012.mammalGrid.mam, SOAP_032.mammalGrid.mam, SOAP_033.mosquitoPoint.mos, SOAP_035.mosquitoPoint.mos, SOAP_037.mosquitoPoint.mos, SOAP_038.mosquitoPoint.mos, SOAP_039.mosquitoPoint.mos, SOAP_040.mosquitoPoint.mos, SOAP
    ## 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     SOAP_014.basePlot.all, SOAP_016.basePlot.all, SOAP_020.basePlot.all, SOAP_045.basePlot.all, SOAP_047.basePlot.all, SOAP_053.basePlot.all, SOAP_054.basePlot.all, SOAP_056.basePlot.all, SOAP_062.phenology.phe, SOAP
    ##    startDate    endDate ongoingEvent estimatedOrActualDate dateRemarks            eventID
    ## 1 2020-02-24 2020-03-09            N                  <NA>        <NA> SOAP.20200224.fire
    ## 2 2020-09-04 2020-10-04            Y                actual        <NA> SOAP.20200904.fire
    ## 3 2020-10-04 2020-11-03            Y                actual        <NA> SOAP.20201004.fire
    ## 4 2020-11-03 2020-12-03            Y                actual        <NA> SOAP.20201004.fire
    ## 5 2020-12-03 2020-12-24            N                actual        <NA> SOAP.20201004.fire
    ## 6 2021-06-29 2021-07-08            N                actual        <NA> SOAP.20210629.fire
    ##   samplingProtocolVersion eventType    methodTypeChoice name scientificName otherScientificName
    ## 1       NEON.DOC.003282vC      fire fire-controlledBurn <NA>           <NA>                <NA>
    ## 2       NEON.DOC.003282vD      fire       fire-wildfire <NA>           <NA>                <NA>
    ## 3       NEON.DOC.003282vD      fire       fire-wildfire <NA>           <NA>                <NA>
    ## 4       NEON.DOC.003282vD      fire       fire-wildfire <NA>           <NA>                <NA>
    ## 5       NEON.DOC.003282vD      fire       fire-wildfire <NA>           <NA>                <NA>
    ## 6       NEON.DOC.003282vD      fire       fire-wildfire <NA>           <NA>                <NA>
    ##   fireSeverity biomassRemoval minQuantity maxQuantity quantityUnit reporterType         remarks
    ## 1      unknown           <NA>          NA          NA         <NA>    secondary controlled burn
    ## 2         high           <NA>          NA          NA         <NA>      primary      Creek Fire
    ## 3         high           <NA>          NA          NA         <NA>      primary      Creek Fire
    ## 4         high           <NA>          NA          NA         <NA>      primary      Creek Fire
    ## 5         high           <NA>          NA          NA         <NA>      primary      Creek Fire
    ## 6         high           <NA>          NA          NA         <NA>      primary       Blue Fire
    ##            recordedBy dataQF
    ## 1 0000-0002-4748-8985   <NA>
    ## 2 0000-0001-7920-7757   <NA>
    ## 3 0000-0001-7920-7757   <NA>
    ## 4 0000-0001-7920-7757   <NA>
    ## 5 0000-0001-7920-7757   <NA>
    ## 6 0000-0001-7920-7757   <NA>

There are six records about fires at SOAP. Looking at the details, we can see one controlled burn in 2020, the Creek Fire in 2020 (four records), and the Blue Fire in 2021.

How does this compare to the measurement dates for the chemistry data?


    unique(year(sls_soilChemistry$collectDate))

    ## [1] 2018 2024

Chemistry measurements were made in 2018 and 2024, before and after the fires. Do nitrogen values differ between the two measurement dates?


    plot(nitrogenPercent~soilMoisture, 
         data=moistchem[which(year(moistchem$collectDate.y)==2018),],
         pch=20)

    points(nitrogenPercent~soilMoisture, 
         data=moistchem[which(year(moistchem$collectDate.y)==2024),],
         pch=20, col="red")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/new-features-2025/rfigs/plot-time-1.png)

No obvious differences in the pattern between the two measurement dates.

If we wanted to dig into the effects of fire more deeply, note that the event data table includes a `locationID` field. This field contains a record of the NEON sampling plots affected by the event - in this case, which plots burned. If there are both burned and unburned plots in our dataset, this could be very informative.

### Pending feature: Site management location data details

There is a NEON code package in development that will help users to more easily work with the location data associated with site events. Stay tuned!

## Community data

We mentioned above that we are also interested in microbial communities. What microbes are living in these soils, and how have they changed over time? Let's download the Soil microbe community taxonomy (DP1.10081.002) data for the same time period at SOAP.

### Feature: Seamless stacking of microbe community data

The community data are in the expanded data package.


    micro <- loadByProduct(dpID="DP1.10081.002", 
                         site="SOAP",
                         startdate="2018-01",
                         enddate="2024-12",
                         package="expanded",
                         include.provisional=T,
                         progress=F,
                         check.size=F)

    ## 
    ## NEON.D17.SOAP.DP1.10081.002.2018-05.expanded.20250129T000730Z.RELEASE-2025.zip could not be downloaded. Re-attempting.

    ## Stacking per-sample files. These files may be very large; download data in smaller subsets if performance problems are encountered.

    ## Variables file was not found or was inconsistent for table mct_soilPerSampleTaxonomy_ITS. Schema will be inferred; performance may be reduced.

    list2env(micro, .GlobalEnv)

    ## <environment: R_GlobalEnv>

Let's look at the distribution by phylum of fungal taxon units at SOAP.


    gg <- ggplot(mct_soilPerSampleTaxonomy_ITS, aes(phylum, individualCount)) +
      geom_col() +
      theme(axis.text.x = element_text(angle = 90))

    gg

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/new-features-2025/rfigs/plot-microbe-data-1.png)

But can we compare the communities at the two time points?


    unique(year(mct_soilSampleMetadata_ITS$collectDate))

    ## [1] 2018

Marker gene data were collected in 2024, but the community taxonomy data are not available yet.

Suppose we wanted to compare soil chemistry data to plant communities instead of microbial communities? The Plant presence and percent cover (DP1.10058.001) data product would be a good place to start.

### Pending feature: neonPlants R package

We are very close to releasing the `neonPlants` package, which will facilitate use of NEON's various plant data products, including both community and biomass data. Stay tuned!

## Samples



## Other languages and platforms

### Feature: Python version of neonutilities

For years, neonUtilities has only been available in R, but as of 2024 we have a Python version!

Aside from some minor formatting differences - `neonutilities` in all lower case, function names in `snake_case` rather than `camelCase` - the functions and inputs are the same in Python as in R. For example, to download the same soil dataset:

```

import neonutilities as nu

soil = nu.load_by_product(dpid="DP1.10086.001", 
                     site="SOAP",
                     startdate="2018-01",
                     enddate="2024-12",
                     include_provisional=True,
                     progress=False,
                     check_size=False)

```

Other code packages, including `neonOS` and `geoNEON`, haven't been implemented in Python yet. Similarly, not all features of neonUtilities are available in Python yet. In particular, we are actively working on incoporating the surface-atmosphere exchange functions in Python.

### Pending feature: Surface-atmosphere exchange data stacking in Python

This should be available within a few weeks.

### Feature: Cloud mode

The `loadByProduct()` function works by downloading NEON data files to a temporary directory and then reading them into R in stacked form. With new cloud-native software, it is possible to accomplish this without the intermediate download step - the files are imported directly to the code environment and stacked simultaneously. If you are working in a cloud environment, add the input `cloud.mode=T` (or `cloud_mode=True` in Python) to `loadByProduct()` for much faster and more efficient data access.

If you are new to working in cloud environments but want to start exploring, we recommend checking out <a href="https://cyverse.org/" target="_blank">CyVerse</a>.

## Stay connected!

New code releases and updates are announced via NEON <a href="https://www.neonscience.org/data-samples/data-notifications" target="_blank">data notifications</a>. Sign up to get data notifications sent to your inbox by making a NEON <a href="https://www.neonscience.org/about/user-accounts" target="_blank">user account</a>.

If you have any questions, or want to request new features, use the <a href="https://www.neonscience.org/about/contact-us" target="_blank">Contact Us</a> page.
