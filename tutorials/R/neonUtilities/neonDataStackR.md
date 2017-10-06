---
syncID: a1388c25d16342cca2643bc2df3fbd8e
title: "Use the neonDataStackR package to access NEON data"
description: "Convert data downloaded from the NEON Data Portal in zipped month-by-site files into a table with all data of interest. Temperature data is used as an example. "
dateCreated: 2017-08-01
authors: [Megan A. Jones ]
contributors: [ ]
estimatedTime: 5 minutes
packagesLibraries: neonDataStackR
topics: data-management, rep-sci
languageTool: R
code1: R/neonUtilities/neonDataStackR.R
tutorialSeries:
urlTitle: neonDataStackR

---

This tutorial goes over how to convert data downloaded from the NEON Data Portal 
in zipped month-by-site files into individual files with all data from the 
given site(s) and months. Temperature data is used as an example.

## Download the Data
To start, you must have your data of interest downloaded from the 
<a href="data.neonscience.org" target="_blank"> NEON Data Portal</a>.  

The stacking function will only work on Comma Seperated Value (.csv) files and 
not the NEON data stored in other formats (HDF5, etc). 

Your data will download in a single zipped file. 

The example data is any single-aspirated air temperature available from 
1 January 2015 to 31 December 2016. 

## neonDataStackR package

This package was written to stack data downloaded in month-by-site files into a 
full table with all the data of interest from all sites in the downloaded date
range.  

More information on the package see the README in the associated GitHub repo 
<a href="https://github.com/NEONScience/NEON-utilities/tree/master/neonDataStackR" target="_blank"> NEONScience/NEON-utilities</a>. 

First, install the package from the GitHub repo. You must have the **devtools** 
package installed to do this. Then load the package. 


    library(devtools)

    ## Warning: package 'devtools' was built under R version 3.4.1

    install_github("NEONScience/NEON-utilities/neonDataStackR", dependencies=TRUE)

    ## Downloading GitHub repo NEONScience/NEON-utilities@master
    ## from URL https://api.github.com/repos/NEONScience/NEON-utilities/zipball/master

    ## Installing neonDataStackR

    ## '/Library/Frameworks/R.framework/Resources/bin/R' --no-site-file  \
    ##   --no-environ --no-save --no-restore --quiet CMD INSTALL  \
    ##   '/private/var/folders/0p/x8phw1_156511_jqkryx2t8m2vn2t3/T/RtmpPD2fan/devtools52c155f1e8a2/NEONScience-NEON-utilities-5872bcd/neonDataStackR'  \
    ##   --library='/Users/mjones01/Library/R/3.4/library' --install-tests

    ## 

    library (neonDataStackR)

Now there is a single function to run in this package `stackByTable()`. The output
will yield data grouped into new files by table name.  For example the single 
aspirated air temperature data product contains 1 minute and 30 minute interval
data. The output from this function is one .csv with 1 minute data and one .csv 
with 30 minute data. 

Depending on your file size this function may run for a while. The 2015 and 2016
single aspirated air temperature from two sites that I used for the example took
about 25 minutes to complete.  



    stackByTable("data/NEON_temp-air-single.zip")


    Unpacked  2016-02-SERC-DP1.00002.001-basic-20160708035158.zip
    Unpacked  2016-03-SERC-DP1.00002.001-basic-20160708035642.zip
    Joining, by = c("domainID", "siteID", "horizontalPosition", "verticalPosition", "startDateTime", "endDateTime", "tempSingleMean", "tempSingleMinimum", "tempSingleMaximum", "tempSingleVariance", "tempSingleNumPts", "tempSingleExpUncert", "tempSingleStdErMean", "finalQF")
    Joining, by = c("domainID", "siteID", "horizontalPosition", "verticalPosition", "startDateTime", "endDateTime", "tempSingleMean", "tempSingleMinimum", "tempSingleMaximum", "tempSingleVariance", "tempSingleNumPts", "tempSingleExpUncert", "tempSingleStdErMean", "finalQF")
    Stacked  SAAT_1min
    Joining, by = c("domainID", "siteID", "horizontalPosition", "verticalPosition", "startDateTime", "endDateTime", "tempSingleMean", "tempSingleMinimum", "tempSingleMaximum", "tempSingleVariance", "tempSingleNumPts", "tempSingleExpUncert", "tempSingleStdErMean", "finalQF")
    Joining, by = c("domainID", "siteID", "horizontalPosition", "verticalPosition", "startDateTime", "endDateTime", "tempSingleMean", "tempSingleMinimum", "tempSingleMaximum", "tempSingleVariance", "tempSingleNumPts", "tempSingleExpUncert", "tempSingleStdErMean", "finalQF")
    Stacked  SAAT_30min
    Finished: All of the data are stacked into  2  tables!

From the single-aspirated air temperature data we are given two final tables. 
One with 1 minute intervals: **SAAT_1min** and one for 30 minute intervals: **SAAT_30min**.  

These .csv files are now ready for use.  

