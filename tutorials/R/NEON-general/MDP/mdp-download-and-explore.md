---
title: "NEON Mobile Deployment Platform Data: Download and Explore"
syncID: 35ed4c4378b24a52989a2091fd0fe6a6
description: "Access, work with, and navigate data from NEON mobile deployment platforms."
authors: Cove Sturtevant, Claire Lunch, David Durden, Chris Florian
contributors: 
estimatedTime: 30 minutes
packagesLibraries: neonUtilities, neonMDP
topics: 
languagesTool: R, Google Cloud Storage
dataProduct: 
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/MDP/mdp-download-and-explore.R
tutorialSeries: null
urlTitle: mdp-intro-tutorial
dateCreated: "2025-08-20"
---

This tutorial provides an introduction to working with NEON Mobile Deployment 
Platform (MDP) data, using the `neonMDP` and `neonUtilities` R packages. If you are new to NEON data, we also recommend more general tutorials, including the <a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore tutorial</a> 
and the introduction to <a href="https://www.neonscience.org/resources/learning-hub/tutorials/eddy-data-intro" target="_blank">NEON eddy flux data</a>. 

**A valid login to a NEON MDP data bucket is required to use this tutorial.**

A key difference between public NEON data and MDP data is that MDP data are
not retrieved from the NEON Data Portal. Rather, data are accessed directly from 
a Google Cloud Storage (GCS) bucket with a more complex directory structure than 
data packages downloaded from the Portal. This tutorial shows a user how to 
download the data from the bucket to a local data store and load it into the R 
computing environment for exploration. At that point the data formatting 
matches other NEON data retrieval methods, and users can turn to standard NEON 
tutorials for further guidance. Pointers to particularly relevant tutorials are 
also provided.

This tutorial ends with instructions to write the data loaded into the R 
environment to .csv format should the user desire to work with the data in 
another application in a more traditional format.

<div id="ds-objectives" markdown="1">

## Learning Objectives 
After completing this tutorial you will be able to: 

* Download, compile, and export MDP data 

## Things You’ll Need To Complete This Tutorial

### Bucket login
If you are working on a NEON MDP project and do not already have a login to the 
GCS data bucket, consult the MDP project PI and the NEON Research Support 
Services contact.

### R Programming Language
You will need a current version of R to complete this tutorial. We also recommend 
the RStudio IDE to work with R. 

### R Packages to Install
Prior to starting the tutorial ensure that the following packages are installed.

* **devtools:** `install.packages("devtools")`
* **neonMDP:** `devtools::install_github('NEONScience/NEON-mobile-deployment/neonMDP')`
* **neonUtilities:** `install.packages("neonUtilities")`
* **googleCloudStorageR:** `install.packages("googleCloudStorageR")`

</div>


Load the packages.


    library(neonUtilities)

    library(neonMDP)

    library(googleCloudStorageR)


### Working Directory

This lesson will download MDP data to your working directory. Set the working 
directory, modifying the file path in the code below as needed for your 
computer.


    setwd("~/data/NEON/MDP")



## Download Instrument Data from Google Cloud Storage Bucket

First, we will download all Instrument System (IS) data from the GCS bucket. 
IS data includes all automated sensors except for the Surface-Atmosphere 
Exchange data, which will be downloaded in a separate section below.

Change the bucket in the code below to the bucket set up for your MDP data, 
then run this section once to download all existing IS data from the bucket.
Note that the code will error if data have already been downloaded. 
To retrieve new data each month, see the "get new data" section below.


    setGcsEnv(bucket='neon-rss-md04')

    downloadMDP('Publication')

## Stack IS Data 

NEON data are provided in product-site-month increments. 
The following code will stack (compile) the full time-series of IS products. 
The `stackfromStore()` function stacks data downloaded to the local environment, 
which we did earlier.
Examples for three products are provided below. You can see which products are
available by looking in the "Publication" folder of the working directory.

If there are data from more than one site in the working directory, change 
the `site=` parameter in the code snippets below from "all" to the 4-character 
MDP site code (e.g. "MD04") that you want to explore. 

If data in the MDP bucket have been republished, `stackFromStore()` defaults to 
the most recently published data for each time period. Generally this is the 
right choice, to get the most up-to-date data, but use the `pubdate=` input to 
stack older versions.

See the Help page for the `stackFromStore()` function for descriptions of other 
options you may want to change (e.g. the date range or averaging interval to 
stack).


    # Single-aspirated Air Temperature

    saat <- stackFromStore(dpID='DP1.00002.001', 
                           filepaths=getwd(), 
                           site='all',
                           startdate=NA, enddate=NA, 
                           package='expanded')

    

    # Relative Humidity

    rh <- stackFromStore(dpID='DP1.00098.001', 
                         filepaths=getwd(), 
                         site='all',
                         startdate=NA, enddate=NA, 
                         package='basic')

    

    # Water Quality

    wq <- stackFromStore(dpID='DP1.20288.001', 
                         filepaths=getwd(), 
                         site='all',
                         startdate=NA, enddate=NA, 
                         package='expanded')

You will see messages indicating the Release tag could not be found for the 
stacked tables. This is expected for MDP data, since they do not follow the 
standard NEON data Release paradigm. The messages can be ignored.

The outputs are named lists containing data frames of time-series data
along with other tables containing metadata.

Note that some of the metadata may be irrelevant to your MDP project - for 
example, the `issueLog` table contains data product issues related to sites in 
the NEON project design.


    # 30-minute single-aspirated air temperature (1st 10 rows & columns)

    saat$SAAT_30min[1:10,1:10]

    ##    domainID siteID horizontalPosition verticalPosition       startDateTime         endDateTime tempSingleMean
    ## 1       D14   MD04                000              010 2025-03-27 00:00:00 2025-03-27 00:30:00             NA
    ## 2       D14   MD04                000              010 2025-03-27 00:30:00 2025-03-27 01:00:00             NA
    ## 3       D14   MD04                000              010 2025-03-27 01:00:00 2025-03-27 01:30:00             NA
    ## 4       D14   MD04                000              010 2025-03-27 01:30:00 2025-03-27 02:00:00             NA
    ## 5       D14   MD04                000              010 2025-03-27 02:00:00 2025-03-27 02:30:00             NA
    ## 6       D14   MD04                000              010 2025-03-27 02:30:00 2025-03-27 03:00:00             NA
    ## 7       D14   MD04                000              010 2025-03-27 03:00:00 2025-03-27 03:30:00             NA
    ## 8       D14   MD04                000              010 2025-03-27 03:30:00 2025-03-27 04:00:00             NA
    ## 9       D14   MD04                000              010 2025-03-27 04:00:00 2025-03-27 04:30:00             NA
    ## 10      D14   MD04                000              010 2025-03-27 04:30:00 2025-03-27 05:00:00             NA
    ##    tempSingleMinimum tempSingleMaximum tempSingleVariance
    ## 1                 NA                NA                 NA
    ## 2                 NA                NA                 NA
    ## 3                 NA                NA                 NA
    ## 4                 NA                NA                 NA
    ## 5                 NA                NA                 NA
    ## 6                 NA                NA                 NA
    ## 7                 NA                NA                 NA
    ## 8                 NA                NA                 NA
    ## 9                 NA                NA                 NA
    ## 10                NA                NA                 NA

    # variable descriptions for the single-aspirated air temperature data

    saat$variables_00002[1:10,]

    ##         table          fieldName                                         description dataType          units
    ##        <char>             <char>                                              <char>   <char>         <char>
    ##  1: SAAT_1min           domainID                Unique identifier of the NEON domain   string           <NA>
    ##  2: SAAT_1min             siteID                                      NEON site code   string           <NA>
    ##  3: SAAT_1min horizontalPosition         Index of horizontal location at a NEON site   string           <NA>
    ##  4: SAAT_1min   verticalPosition           Index of vertical location at a NEON site   string           <NA>
    ##  5: SAAT_1min      startDateTime      Date and time at which a sampling is initiated dateTime           <NA>
    ##  6: SAAT_1min        endDateTime      Date and time at which a sampling is completed dateTime           <NA>
    ##  7: SAAT_1min     tempSingleMean Arithmetic mean of single aspirated air temperature     real        celsius
    ##  8: SAAT_1min  tempSingleMinimum            Minimum single aspirated air temperature     real        celsius
    ##  9: SAAT_1min  tempSingleMaximum            Maximum single aspirated air temperature     real        celsius
    ## 10: SAAT_1min tempSingleVariance        Variance in single aspirated air temperature     real celsiusSquared
    ##                  downloadPkg                       pubFormat primaryKey categoricalCodeName
    ##                       <char>                          <char>     <char>              <char>
    ##  1: appended by stackByTable                            <NA>          N                    
    ##  2: appended by stackByTable                            <NA>          N                    
    ##  3: appended by stackByTable                            <NA>          N                    
    ##  4: appended by stackByTable                            <NA>          N                    
    ##  5:                    basic yyyy-MM-dd'T'HH:mm:ss'Z'(floor)       <NA>                <NA>
    ##  6:                    basic yyyy-MM-dd'T'HH:mm:ss'Z'(floor)       <NA>                <NA>
    ##  7:                    basic                   *.####(round)       <NA>                <NA>
    ##  8:                    basic                   *.####(round)       <NA>                <NA>
    ##  9:                    basic                   *.####(round)       <NA>                <NA>
    ## 10:                    basic                   *.####(round)       <NA>                <NA>

For more information about naming conventions, data tables, and metadata, see 
the <a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore</a> 
tutorial.

## Download Surface-Atmosphere Exchange Data from Google Cloud Storage Bucket

Now we will download all Surface-Atmosphere Exchange (SAE) data from the GCS bucket. 

Change the bucket in the code below to the bucket set up for your MDP data, 
then run this section once to download all existing SAE data from the bucket.
Note that the code will error if data have already been downloaded. 
To retrieve new data each month, see the "get new data" section below.


    setGcsEnv(bucket='neon-rss-md04')

    downloadMDP('ods/dataproducts/DP4')

## Stack SAE Data 

The following code will stack (compile) SAE products providing a complete 
time-series for the downloaded MDP site. The `stackFromStore()` function utilizes
the `stackEddy()` function which is described in great detail in the 
<a href="https://www.neonscience.org/eddy-data-intro" target="_blank">Introduction to working with NEON eddy flux data</a> tutorial. 
The MDP data files are in the same format as described in the tutorial.  Below we
show examples of stacking the Level 4 flux data and Level 1 isotopic ratios.

If there are data from more than one site in the working directory, change 
the `site=` parameter in the code snippets below from "all" to the 4-character 
MDP site code (e.g. "MD04") that you want to explore. See the Help pages for the 
`stackFromStore()` function and the `stackEddy()` function for descriptions of 
other options you may want to change.


    # NSAE data

    flux <- stackFromStore(dpID='DP4.00200.001', 
                           filepaths=paste(getwd(), 'ods', sep='/'), 
                           site='all', startdate=NA, enddate=NA, 
                           package='basic', level='dp04')

    

    # CO2 isotope data

    iso <- stackFromStore(dpID='DP4.00200.001', 
                          filepaths=paste(getwd(), 'ods', sep='/'), 
                          site='all', startdate=NA, enddate=NA, 
                          package='basic', level='dp01', 
                          timeIndex=30, var='dlta13CCo2')

You may see a warning saying something like 
`no non-missing arguments to max; returning -Inf`. This is related to the daily 
basic package files in the MDP bucket. These files are ignored in stacking 
using `stackFromStore()`; consult NEON if you need to use the daily basic files. 
Otherwise you can ignore this warning.

The resultant data lists will include the `variables` and `objDesc` tables to 
help you interpret the data by describing term definitions and units for 
variables.


    # flux data variables (1st 10 rows)

    flux$variables[1:10,]

    ##    category  system variable    stat           units
    ## 1      data fluxCo2     nsae timeBgn              NA
    ## 2      data fluxCo2     nsae timeEnd              NA
    ## 3      data fluxCo2     nsae    flux umolCo2 m-2 s-1
    ## 4      data fluxCo2     stor timeBgn              NA
    ## 5      data fluxCo2     stor timeEnd              NA
    ## 6      data fluxCo2     stor    flux umolCo2 m-2 s-1
    ## 7      data fluxCo2     turb timeBgn              NA
    ## 8      data fluxCo2     turb timeEnd              NA
    ## 9      data fluxCo2     turb    flux umolCo2 m-2 s-1
    ## 10     data fluxH2o     nsae timeBgn              NA

    # CO2 isotope data (1st 10 rows & columns)

    iso$MD04[1:10,1:10]

    ##    horizontalPosition verticalPosition             timeBgn             timeEnd data.isoCo2.dlta13CCo2.mean
    ## 1                 000              010 2025-04-01 00:00:00 2025-04-01 00:29:59                         NaN
    ## 2                 000              010 2025-04-01 00:30:00 2025-04-01 00:59:59                         NaN
    ## 3                 000              010 2025-04-01 01:00:00 2025-04-01 01:29:59                         NaN
    ## 4                 000              010 2025-04-01 01:30:00 2025-04-01 01:59:59                         NaN
    ## 5                 000              010 2025-04-01 02:00:00 2025-04-01 02:29:59                         NaN
    ## 6                 000              010 2025-04-01 02:30:00 2025-04-01 02:59:59                         NaN
    ## 7                 000              010 2025-04-01 03:00:00 2025-04-01 03:29:59                         NaN
    ## 8                 000              010 2025-04-01 03:30:00 2025-04-01 03:59:59                         NaN
    ## 9                 000              010 2025-04-01 04:00:00 2025-04-01 04:29:59                         NaN
    ## 10                000              010 2025-04-01 04:30:00 2025-04-01 04:59:59                         NaN
    ##    data.isoCo2.dlta13CCo2.min data.isoCo2.dlta13CCo2.max data.isoCo2.dlta13CCo2.vari data.isoCo2.dlta13CCo2.numSamp
    ## 1                         NaN                        NaN                          NA                              0
    ## 2                         NaN                        NaN                          NA                              0
    ## 3                         NaN                        NaN                          NA                              0
    ## 4                         NaN                        NaN                          NA                              0
    ## 5                         NaN                        NaN                          NA                              0
    ## 6                         NaN                        NaN                          NA                              0
    ## 7                         NaN                        NaN                          NA                              0
    ## 8                         NaN                        NaN                          NA                              0
    ## 9                         NaN                        NaN                          NA                              0
    ## 10                        NaN                        NaN                          NA                              0
    ##    qfqm.isoCo2.dlta13CCo2.qfFinl
    ## 1                              1
    ## 2                              1
    ## 3                              1
    ## 4                              1
    ## 5                              1
    ## 6                              1
    ## 7                              1
    ## 8                              1
    ## 9                              1
    ## 10                             1

Refer to the <a href="https://www.neonscience.org/eddy-data-intro" target="_blank">Introduction to working with NEON eddy flux data</a> tutorial for further details.

## Get New Data

To retrieve new data published to the bucket each month, change the bucket in 
the code below to the bucket set up for your MDP data, then run this section.



    setGcsEnv(bucket='neon-rss-md04')

    updateMDP('Publication')

    updateMDP('ods/dataproducts/DP4')

## Explore Data by Accessing other NEON Tutorials 

After stacking the IS data, you can transfer to the 
<a href="https://www.neonscience.org/resources/learning-hub/tutorials/get-started-neon-data-series-data-tutorials#jump-70" target="_blank">Explore Temperature data</a> section in the Get Started with NEON Data series of tutorials. The tutorial guides you through the data and metadata contents of the list output from the `stackFromStore()` function for IS products, including how to interpret quality flags as well as do basic plotting and manipulation of data tables. 

There are several SAE related tutorials. The aforementioned 
<a href="https://www.neonscience.org/eddy-data-intro" target="_blank">Introduction to working with NEON eddy flux data</a> is
a great starting point. Another tutorial that may be of interest is the
<a href="https://www.neonscience.org/resources/learning-hub/tutorials/eddy-diel-cycle" target="_blank"> Exploring diel carbon flux cycles</a>, which provides 
a more comprehensive exploration of the carbon fluxes by looking at diel 
patterns and highlighting how to utilize NEON quality flags to evaluate data 
quality.

## Save Data in .csv Format 

If preferred, IS time-series data compiled with the `stackFromStore()` function can easily be written to .csv format. The following example code will write the 30-minute single-aspirated air temperature data to your working directory.


    write.csv(saat$SAAT_30min, 
              file="SAAT_30min_stacked.csv", 
              row.names=F)

Writing out the stacked SAE data to .csv is similarly easy. The following example code will write the 30-minute CO<sub>2</sub> isotope data to the working directory. Change the "MD04" site code in `iso$MD04` in the code below to the 4-character site code for your MDP. 


    write.csv(iso$MD04, 
              file="co2_isotopes_30min_stacked.csv", 
              row.names=F)

