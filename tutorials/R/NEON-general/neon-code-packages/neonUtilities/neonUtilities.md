---
syncID: a1388c25d16342cca2643bc2df3fbd8e
title: "Use the neonUtilities Package to Access NEON Data"
description: "Use the neonUtilities R package to download data, and to convert downloaded data from zipped month-by-site files into a table with all data of interest. Temperature data are used as an example. "
dateCreated: 2017-08-01
authors: Claire K. Lunch, Megan A. Jones
contributors: Maxwell Burner
estimatedTime: 40 minutes
packagesLibraries: neonUtilities
topics: data-management, rep-sci
languageTool: R
dataProducts: DP1.00003.001, DP1.00002.001, DP3.30026.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-code-packages/neonUtilities/neonUtilities.R
tutorialSeries:
urlTitle: neonDataStackR

---

This tutorial goes over how to use the neonUtilities R package 
(formerly the neonDataStackR package).

The package contains several functions:

* `stackByTable()`: Takes zip files downloaded from the 
<a href="http://data.neonscience.org" target="_blank">Data Portal</a> or 
downloaded by `zipsByProduct()`, unzips them, and joins 
the monthly files by data table to create a single file per table.
* `zipsByProduct()`: A wrapper for the 
<a href="http://data.neonscience.org/data-api" target="_blank">NEON API</a>; 
downloads data based on data product and site criteria. Stores 
downloaded data in a format that can then be joined by 
`stackByTable()`.
* `loadByProduct()`: Combines the functionality of `zipsByProduct()` and 
`stackByTable()`: Downloads the specified data, stacks the files, and 
loads the files to the R environment.
* `getPackage()`: A wrapper for the NEON API; downloads one 
site-by-month zip file at a time.
* `byFileAOP()`: A wrapper for the NEON API; downloads remote 
sensing data based on data product, site, and year criteria. 
Preserves the file structure of the original data.
* `byTileAOP()`: Downloads remote sensing data for the specified 
data product, subset to tiles that intersect a list of 
coordinates.
* `readTableNEON()`: Reads NEON data tables into R, using the 
variables file to assign R classes to each column.
* `transformFileToGeoCSV()`: Converts any NEON data file in 
csv format into a new file with GeoCSV headers.

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> If you are only interested in joining data 
files downloaded from the NEON Data Portal, you will only need to use 
`stackByTable()`. Follow the instructions in the first section of the 
<a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore</a> 
tutorial.
</div>


## neonUtilities package

This package is intended to provide a toolbox of basic functionality 
for working with NEON data. It currently contains the functions 
listed above, but it is under development and more will be added in 
the future. To report bugs or request new features, post an issue in the GitHub 
repo 
<a href="https://github.com/NEONScience/NEON-utilities/issues" target="_blank">issues page</a>.

If you are already familiar with the `neonUtilities` package, and need a 
quick reference guide to function inputs and notation, see the 
<a href="https://www.neonscience.org/sites/default/files/cheat-sheet-neonUtilities.pdf" target="_blank">neonUtilities cheat sheet</a>.

First, we must install and load the `neonUtilities` package.


    # install neonUtilities - can skip if already installed
    install.packages("neonUtilities")
    # load neonUtilities
    library(neonUtilities)

## Download files and load directly to R: loadByProduct()

The most popular function in `neonUtilities` is `loadByProduct()`. 
This function downloads data from the NEON API, merges the site-by-month 
files, and loads the resulting data tables into the R environment, 
assigning each data type to the appropriate R class. It combines the 
actions of the `zipsByProduct()`, `stackByTable()`, and `readTableNEON()` 
functions, described below.

This is a popular choice because it ensures you're always working with the 
latest data, and it ends with ready-to-use tables in R. However, if you 
use it in a workflow you run repeatedly, keep in mind it will re-download 
the data every time.

`loadByProduct()` works on most observational (OS) and sensor (IS) data, 
but not on surface-atmosphere exchange (SAE) data, remote sensing (AOP) 
data, and some of the data tables in the microbial data products. For 
functions that download AOP data, see the `byFileAOP()` and `byTileAOP()` 
sections in this tutorial. For functions that work with SAE data, see 
the <a href="https://www.neonscience.org/eddy-data-intro" target="_blank">NEON eddy flux data tutorial</a>.

The inputs to `loadByProduct()` control which data to download and how 
to manage the processing:

* `dpID`: the data product ID, e.g. DP1.00002.001
* `site`: defaults to "all", meaning all sites with available data; 
can be a vector of 4-letter NEON site codes, e.g. 
`c("HARV","CPER","ABBY")`.
* `startdate` and `enddate`: defaults to NA, meaning all dates 
with available data; or a date in the form YYYY-MM, e.g. 
2017-06. Since NEON data are provided in month packages, finer 
scale querying is not available. Both start and end date are 
inclusive.
* `package`: either basic or expanded data package. Expanded data 
packages generally include additional information about data 
quality, such as chemical standards and quality flags. Not every 
data product has an expanded package; if the expanded package is 
requested but there isn't one, the basic package will be 
downloaded.
* `avg`: defaults to "all", to download all data; or the 
number of minutes in the averaging interval. See example below; 
only applicable to IS data.
* `savepath`: the file path you want to download to; defaults to the 
working directory.
* `check.size`: T or F: should the function pause before downloading 
data and warn you about the size of your download? Defaults to T; if 
you are using this function within a script or batch process you 
will want to set it to F.
* `nCores`: Number of cores to use for parallel processing. Defaults 
to 1, i.e. no parallelization.

The `dpID` is the data product identifier of the data you want to 
download. The DPID can be found on the 
<a href="http://data.neonscience.org/data-products/explore" target="_blank">
Explore Data Products page</a>.
It will be in the form DP#.#####.###

Let's get triple-aspirated air temperature data (DP1.00003.001) 
from Moab and Onaqui (MOAB and ONAQ), from May--August 2018, and 
name the data object `trip.temp`:


    trip.temp <- loadByProduct(dpID="DP1.00003.001", 
                               site=c("MOAB","ONAQ"),
                               startdate="2018-05", 
                               enddate="2018-08")


    Continuing will download files totaling approximately 7.994569 MB. Do you want to proceed y/n: y
    Downloading 8 files
      |========================================================================================================| 100%
    
    Unpacking zip files using 1 cores.
      |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=00s  
      |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=00s  
    Stacking operation across a single core.
    Stacking table TAAT_1min
      |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=00s  
    Stacking table TAAT_30min
      |++++++++++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=00s  
    Merged the most recent publication of sensor position files for each site and saved to /stackedFiles
    Copied the most recent publication of variable definition file to /stackedFiles
    Finished: Stacked 2 data tables and 2 metadata tables!
    Stacking took 0.8517601 secs

The object returned by `loadByProduct()` is a named list of data 
frames. To work with each of them, select them from the list 
using the `$` operator.


    names(trip.temp)
    View(trip.temp$TAAT_30min)

If you prefer to extract each table from the list and work 
with it as an independent object, you can use the 
`list2env()` function:


    list2env(trip.temp, .GlobalEnv)

For more details about the contents of the data tables and metadata tables, 
check out the <a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore</a> 
tutorial.

If you want to be able to close R and come back to these data without 
re-downloading, you'll want to save the tables locally. We recommend 
also saving the variables file, both so you'll have it to refer to, and 
so you can use it with `readTableNEON()` (see below).


    write.csv(TAAT_30min, 
              "~/Downloads/TAAT_30min.csv", 
              row.names=F)
    write.csv(variables_00003, 
              "~/Downloads/variables_00003.csv", 
              row.names=F)

But, if you want to save files locally and load them into R (or another 
platform) each time you run a script, instead of downloading from the API 
every time, you may prefer to use `zipsByProduct()` and `stackByTable()` 
instead of `loadByProduct()`.

## Join data files: stackByTable()
The function `stackByTable()` joins the month-by-site files from a data 
download. The output will yield data grouped into new files by table name. 
For example, the single aspirated air temperature data product contains 1 
minute and 30 minute interval data. The output from this function is one 
.csv with 1 minute data and one .csv with 30 minute data. 

Depending on your file size this function may run for a while. For 
example, in testing for this tutorial, 124 MB of temperature data took 
about 4 minutes to stack. A progress bar will display while the 
stacking is in progress. 

### Download the Data
To stack data from the Portal, first download the data of interest from the 
<a href="http://data.neonscience.org" target="_blank"> NEON Data Portal</a>. 
To stack data downloaded from the API, see the `zipsByProduct()` section 
below.

Your data will download from the Portal in a single zipped file. 

The stacking function will only work on zipped Comma Separated Value (.csv) 
files and not the NEON data stored in other formats (HDF5, etc). 

### Run `stackByTable()`

The example data below are single-aspirated air temperature. 

To run the `stackByTable()` function, input the file path to the 
downloaded and zipped file. 


    # stack files - Mac OSX file path shown
    stackByTable(filepath="~neon/data/NEON_temp-air-single.zip")


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
associated variables, validation, and sensor_positions files, if applicable 
(validation files are only available for observational data products, and 
sensor position files are only available for instrument data products).

These .csv files are now ready for use with the program of your choice.

To read the data tables into R, we recommend using `readTableNEON()`, 
which will assign each column to the relevant R class, based on the 
metadata in the variables file. This ensures time stamps and missing 
data are interpreted correctly in R.


    SAAT30 <- readTableNEON(
      dataFile='~/stackedFiles/SAAT_30min.csv',
      varFile='~/stackedFiles/variables_00002.csv'
    )

### Other options

Other input options in `stackByTable()` are:

* `savepath` : allows you to specify the file path 
where you want the stacked files to go, overriding the default. 
* `saveUnzippedFiles` : allows you to keep the unzipped, unstacked 
files from an intermediate stage of the process; by default they 
are discarded.

Example usage:


    stackByTable(filepath="~neon/data/NEON_temp-air-single.zip", 
                 savepath="~data/allTemperature", saveUnzippedFiles=T)

## Download files to be stacked: zipsByProduct()
The function `zipsByProduct()` is a wrapper for the NEON API, it 
downloads zip files for the data product specified and stores them in 
a format that can then be passed on to `stackByTable()`.

Input options for `zipsByProduct()` are the same as those for 
`loadByProduct()` described above, except for `nCores`.

Here, we'll download single-aspirated air temperature (DP1.00002.001) 
data from Wind River Experimental Forest (WREF) for April and May of 
2019.


    zipsByProduct(dpID="DP1.00002.001", site="WREF", 
                  startdate="2019-04", enddate="2019-05",
                  package="basic", check.size=T)


    Continuing will download files totaling approximately 12.750557 MB. Do you want to proceed y/n: y
    Downloading 2 files
      |========================================================================================================| 100%
    2 files downloaded to /Users/neon/filesToStack00002

Downloaded files can now be passed to `stackByTable()` to be 
stacked.


    stackByTable(filepath="/Users/neon/filesToStack00002")

For many sensor data products, download sizes can get 
very large, and `stackByTable()` takes a long time. The 
1-minute or 2-minute files are much larger than the 
longer averaging intervals, so if you don't need high-
frequency data, the `avg` input option lets you choose 
which averaging interval to download.

This option is only applicable to sensor (IS) data, 
since OS data are not averaged.

Download only the 30-minute data for single-aspirated 
air temperature at WREF:


    zipsByProduct(dpID="DP1.00002.001", site="WREF", 
                  startdate="2019-04", enddate="2019-05",
                  package="basic", avg=30, check.size=T)


    Continuing will download files totaling approximately 2.101936 MB. Do you want to proceed y/n: y
    Downloading 17 files
      |========================================================================================================| 100%
    17 files downloaded to /Users/neon/filesToStack00002

The 30-minute files can be stacked as usual, and can 
be read into R using `readTableNEON()`:


    stackByTable(filepath="/Users/neon/filesToStack00002")
    SAAT30 <- readTableNEON(
      dataFile='/Users/neon/filesToStack00002/stackedFiles/SAAT_30min.csv',
      varFile='/Users/neon/filesToStack00002/stackedFiles/variables_00002.csv'
    )


## Download a single zip file: getPackage()

If you only need a single site-month (e.g., to test code 
you're writing), the `getPackage()` function can be used to 
download a single zip file. Here we'll download the 
November 2017 temperature data from HARV.


    getPackage("DP1.00002.001", site_code="HARV", 
               year_month="2017-11", package="basic")

The file should now be saved to your working directory.

## Download remote sensing files: byFileAOP()

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


    byFileAOP("DP3.30015.001", site="HOPB", 
              year="2017", check.size=T)


    Continuing will download 36 files totaling approximately 140.3 MB . Do you want to proceed y/n: y
    trying URL 'https://neon-aop-product.s3.data.neonscience.org:443/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D01_HOPB_DP3_716000_4704000_CHM.tif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20180410T233031Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20180410%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=92833ebd10218f4e2440cb5ea78d1c8beac4ee4c10be5c6aeefb72d18cf6bd78'
    Content type 'application/octet-stream' length 4009489 bytes (3.8 MB)
    ==================================================
    downloaded 3.8 MB
    
    (Further URLs omitted for space. Function returns a message 
      for each URL it attempts to download from)
    
    Successfully downloaded  36  files.
    NEON_D01_HOPB_DP3_716000_4704000_CHM.tif downloaded to /Users/neon/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_716000_4705000_CHM.tif downloaded to /Users/neon/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    
    (Further messages omitted for space.)

The files should now be downloaded to a new folder in your 
working directory.

## Download remote sensing files for specific coordinates: byTileAOP()

Often when using remote sensing data, we only want data covering a
certain area - usually the area where we have coordinated ground 
sampling. `byTileAOP()` queries for data tiles containing a 
specified list of coordinates. It only works for the tiled, AKA 
mosaicked, versions of the remote sensing data, i.e. the ones with 
data product IDs beginning with "DP3".

Here, we'll download tiles of vegetation indices data (DP3.30026.001) 
corresponding to select observational sampling plots. For more information 
about accessing NEON spatial data, see the 
<a href="https://www.neonscience.org/neon-api-usage" target="_blank">
API tutorial</a> and the in-development <a href="https://github.com/NEONScience/NEON-geolocation/tree/master/geoNEON" 
target="_blank">
geoNEON package</a>.

For now, assume we've used the API to look up the plot centroids of 
plots SOAP_009 and SOAP_011 at the Soaproot Saddle site. You can 
also look these up in the Spatial Data folder of the 
<a href="https://data.neonscience.org/documents" target="_blank">
document library</a>. 
The coordinates of the two plots in UTMs are 298755,4101405 and 
299296,4101461. These are 40x40m plots, so in looking for tiles 
that contain the plots, we want to include a 20m buffer. The 
"buffer" is actually a square, it's a delta applied equally to 
both the easting and northing coordinates.


    byTileAOP(dpID="DP3.30026.001", site="SOAP", 
              year="2018", easting=c(298755,299296),
              northing=c(4101405,4101461),
              buffer=20)


    trying URL 'https://neon-aop-product.s3.data.neonscience.org:443/2018/FullSite/D17/2018_SOAP_3/L3/Spectrometer/VegIndices/NEON_D17_SOAP_DP3_299000_4101000_VegIndices.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20190313T225238Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20190313%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=e9ae6858242b48df0677457e31ea3d86b2f20ac2cf43d5fc02847bbaf2e1da47'
    Content type 'application/octet-stream' length 47798759 bytes (45.6 MB)
    ==================================================
    downloaded 45.6 MB
    
    (Further URLs omitted for space. Function returns a message 
      for each URL it attempts to download from)
    
    Successfully downloaded  2  files.
    NEON_D17_SOAP_DP3_298000_4101000_VegIndices.zip downloaded to /Users/neon/DP3.30026.001/2018/FullSite/D17/2018_SOAP_3/L3/Spectrometer/VegIndices
    NEON_D17_SOAP_DP3_299000_4101000_VegIndices.zip downloaded to /Users/neon/DP3.30026.001/2018/FullSite/D17/2018_SOAP_3/L3/Spectrometer/VegIndices

The 2 tiles covering the SOAP_009 and SOAP_011 plots have  
been downloaded.

## Convert files to GeoCSV: transformFileToGeoCSV()

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
you want to write out the new version. It works on both single 
site-month files and on stacked files.

In this example, we'll convert the November 2017 temperature data  
from HARV that we downloaded with `getPackage()` earlier. First, 
you'll need to unzip the file so you can get to the data files. 
Then we'll select the file for the tower top, which we can 
identify by the 050 in the VER field (see the 
<a href="http://data.neonscience.org/file-naming-conventions" target="_blank">file naming conventions</a> 
page for more information).


    transformFileToGeoCSV("~/NEON.D01.HARV.DP1.00002.001.000.050.030.SAAT_30min.2017-11.basic.20171207T181046Z.csv", 
                          "~/NEON.D01.HARV.DP1.00002.001.variables.20171207T181046Z.csv",
                          "~/SAAT_30min_geo.csv")


