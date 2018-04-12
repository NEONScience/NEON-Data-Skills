---
syncID: a1388c25d16342cca2643bc2df3fbd8e
title: "Use the neonUtilities Package to Access NEON Data"
description: "Use the neonUtilities R package to download data, and to convert downloaded data from zipped month-by-site files into a table with all data of interest. Temperature data are used as an example. "
dateCreated: 2017-08-01
authors: [Megan A. Jones, Claire K. Lunch ]
contributors:
estimatedTime: 20 minutes
packagesLibraries: neonUtilities
topics: data-management, rep-sci
languageTool: R
code1: R/neonUtilities/neonUtilities.R
tutorialSeries:
urlTitle: neonDataStackR

---

This tutorial goes over how to use the neonUtilities R package 
(formerly the neonDataStackR package).
The first three sections, through the `stackByTable()` function, are 
all you need in order to convert data downloaded from the NEON Data Portal 
in zipped month-by-site files into aggregated files with all data from the 
given site(s) and months. The later sections cover additional functions 
in the package: a conversion function to transform NEON files into 
GeoCSV format and wrappers for the API (Application Programming 
Interface; more info on the NEON API
<a href="http://data.neonscience.org/data-api" target="_blank">here</a>)
that provide alternative pathways for downloading data. 
Unless noted, the data in this tutorial is NEON single aspirated air 
temperature.

## Download the Data
To start, you must have your data of interest downloaded from the 
<a href="http://data.neonscience.org" target="_blank"> NEON Data Portal</a>.  

The stacking function will only work on zipped Comma Separated Value (.csv) 
files and not the NEON data stored in other formats (HDF5, etc). 

Your data will download in a single zipped file. 

The example data below are single-aspirated air temperature available from 
1 January 2015 to 31 December 2016. 

## neonUtilities package

This package was written to combine data downloaded in month-by-site files into a 
full table with all the data of interest from all sites in the downloaded date
range.  

More information on the package see the README in the associated GitHub repo 
<a href="https://github.com/NEONScience/NEON-utilities/tree/master/neonUtilities" target="_blank"> NEONScience/NEON-utilities</a>. 

First, we must install the package from the GitHub repo. You must have the 
**devtools** package installed and loaded to do this. Then load the `neonUtilities` 
package. 


    # install devtools - can skip if already installed
    install.packages("devtools")

    ## Installing package into '/Users/neon/Library/R/3.4/library'
    ## (as 'lib' is unspecified)

    ## Warning in install.packages :
    ##   cannot open URL 'https://cran.rstudio.com/bin/macosx/el-capitan/contrib/3.4/PACKAGES.rds': HTTP status was '404 Not Found'
    ## 
    ## The downloaded binary packages are in
    ## 	/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T//RtmpcwnZ9k/downloaded_packages

    # load devtools
    library(devtools)
    
    # install neonUtilities from GitHub
    install_github("NEONScience/NEON-utilities/neonUtilities", dependencies=TRUE)

    ## Downloading GitHub repo NEONScience/NEON-utilities@master
    ## from URL https://api.github.com/repos/NEONScience/NEON-utilities/zipball/master

    ## Installing neonUtilities

    ## '/Library/Frameworks/R.framework/Resources/bin/R' --no-site-file  \
    ##   --no-environ --no-save --no-restore --quiet CMD INSTALL  \
    ##   '/private/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T/RtmpcwnZ9k/devtools175d5817efee/NEONScience-NEON-utilities-984d3c6/neonUtilities'  \
    ##   --library='/Users/clunch/Library/R/3.4/library' --install-tests

    ## 

    # load neonUtilities
    library (neonUtilities)


## stackByTable()
The function `stackByTable()` joins the month-by-site files from a data 
download. The output will yield data grouped into new files by table name. 
For example the single aspirated air temperature data product contains 1 
minute and 30 minute interval data. The output from this function is one 
.csv with 1 minute data and one .csv with 30 minute data. 

Depending on your file size this function may run for a while. The 2015 and 2016
single aspirated air temperature from two sites that I used for a 2017 workshop
took about 25 minutes to complete. A progress bar will display while the 
stacking is in progress. 

To run the `stackByTable()` function, input the data product ID (DPID) of the 
data you downloaded, and the file path to the downloaded and zipped file. 
The DPID can be found in the data product box on the 
<a href="http://data.neonscience.org/static/browse.html" target="_blank">
new data browse page</a>, or in 
the <a href="http://data.neonscience.org/data-product-catalog" target="_blank">
data product catalog</a>. 
It will be in the form DP#.#####.###; the DPID of single aspirated air 
temperature is DP1.00002.001.


    # stack files - Mac OSX file path shown
    stackByTable("DP1.00002.001","~neon/Documents/data/NEON_temp-air-single.zip")


    Unpacking zip files
      |=========================================================================================| 100%
    Stacking table SAAT_1min
      |=========================================================================================| 100%
    Stacking table SAAT_30min
      |=========================================================================================| 100%
    Finished: All of the data are stacked into  2  tables!
    Copied the first available variable definition file to /stackedFiles and renamed as variables.csv
    Stacked SAAT_1min which has 424800 out of the expected 424800 rows (100%).
    Stacked SAAT_30min which has 14160 out of the expected 14160 rows (100%).
    Stacking took 6.233922 secs
    All unzipped monthly data folders have been removed.

From the single-aspirated air temperature data we are given two final tables. 
One with 1 minute intervals: **SAAT_1min** and one for 30 minute intervals: 
**SAAT_30min**.  

In the same directory as the zipped file, you should now have an unzipped 
directory of the same name. When you open this you will see a new directory 
called **stackedFiles**. This directory contains one or more .csv files 
(depends on the data product you are working with) with all the data from 
the months & sites you downloaded. There will also be a single copy of the 
associated varibles.csv and validation.csv files, if applicable (validation 
files are only available for observational data products).

These .csv files are now ready for use with the program of your choice. 


## zipsByProduct()
The function `zipsByProduct()` is a wrapper for the NEON API, it 
downloads zip files for the data product specified and stores them in 
a format that can then be passed on to `stackByTable()`.

Inputs to `zipsByProduct()` are:

* dpID: the data product ID, e.g. DP1.00002.001
* site: either the 4-letter code of a single site, e.g. HARV, or "all", 
indicating all sites with data available
* package: either basic or expanded data package
* check.size: T or F: should the function pause before downloading 
data and warn you about the size of your download? Defaults to T; if 
you are using this function within a script or batch process you 
will want to set it to F.

Try it now. 


    zipsByProduct("DP1.00002.001", site="HARV", package="basic", check.size=T)


    Continuing will download files totaling approximately 121.470836 MB. Do you want to proceed y/n: y
    trying URL 'https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.00002.001/PROV/HARV/20141001T000000--20141101T000000/basic/NEON.D01.HARV.DP1.00002.001.2014-10.basic.20171010T150911Z.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180409T214634Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20180409%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=1349949ab91294c564250825007e50315967655a1d0e1a4392d19f310e910654'
    Content type 'application/zip' length 1593260 bytes (1.5 MB)
    ==================================================
    downloaded 1.5 MB
    
    (Further URLs omitted for space. Function returns a message 
      for each URL it attempts to download from)
    
    36 zip files downloaded to /Users/neon/filesToStack00002

Downloaded files can now be passed to `stackByTable()` to be 
stacked. Another input is required in this case, folder=T.


    stackByTable("DP1.00002.001", "/Users/neon/filesToStack00002", folder=T)

## getPackage()

If you only need a single site-month (e.g., to test code 
you're writing), the `getPackage()` function can be used to 
download a single zip file. Here we'll download the 
November 2017 temperature data from Harvard Forest (HARV).


    getPackage("DP1.00002.001", site_code="HARV", 
               year_month="2017-11", package="basic")

The file should now be saved to your working directory.

## byFileAOP()

Remote sensing data files can be very large, and NEON remote sensing 
(AOP) data are stored in a directory structure that makes them easier 
to navigate. `byFileAOP()` downloads AOP files from the API while 
preserving their directory structure. This provides a convenient way 
to access AOP data programmatically.

Be aware that downloads from `byFileAOP()` can take a VERY long time, 
depending on the data you request and your connection speed. You 
may need to run the function and then leave your machine on and 
downloading for an extended period of time.

Here the example download is the Ecosystem Structure data product at 
Hop Brook (HOPB) in 2017; we use this as the example because it's a 
relatively small year-site-product combination.


    byFileAOP("DP3.30015.001", site="HOPB", year="2017", check.size=T)


    Continuing will download 36 files totaling approximately 140.3 MB . Do you want to proceed y/n: y
    trying URL 'https://neon-aop-product.s3.data.neonscience.org:443/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D01_HOPB_DP3_716000_4704000_CHM.tif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180410T233031Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20180410%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=92833ebd10218f4e2440cb5ea78d1c8beac4ee4c10be5c6aeefb72d18cf6bd78'
    Content type 'application/octet-stream' length 4009489 bytes (3.8 MB)
    ==================================================
    downloaded 3.8 MB
    
    (Further URLs omitted for space. Function returns a message 
      for each URL it attempts to download from)
    
    Successfully downloaded  36  files.
    NEON_D01_HOPB_DP3_716000_4704000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_716000_4705000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    
    (Further messages omitted for space.)

The files should now be downloaded to a new folder in your 
working directory.

## transformFileToGeoCSV()

`transformFileToGeoCSV()` takes a NEON csv file, plus its 
corresponding variables file, and writes out a new version of the 
file with 
<a href="http://geows.ds.iris.edu/documents/GeoCSV.pdf" target="_blank">GeoCSV</a>
headers. This allows for compatibility with data 
provided by 
<a href="http://www.unavco.org/" target="_blank">UNAVCO</a> 
and other facilities.

Inputs to `transformFileToGeoCSV()` are the file path to the data 
file, the file path to the variables file, and the file path where
you want to write out the new version. It works on single site-month 
files, not on stacked files.

In this example, we'll convert the November 2017 temperature data  
from HARV that we downloaded with `getPackage()` earlier. First, 
you'll need to unzip the file so you can get to the data files. 
Then we'll select the file for the tower top, which we can 
identify by the 050 in the VER field (see the 
<a href="http://data.neonscience.org/file-naming-conventions" target="_blank"> file naming conventions</a> 
page for more information).


    transformFileToGeoCSV("~/NEON.D01.HARV.DP1.00002.001.000.050.030.SAAT_30min.2017-11.basic.20171207T181046Z.csv", 
                          "~/NEON.D01.HARV.DP1.00002.001.variables.20171207T181046Z.csv",
                          "~/SAAT_30min_geo.csv")


