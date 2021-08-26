---
syncID: 5f9c4048a27749c19ee8ecfc78806363
title: "Download and Explore NEON Data"
description: Tutorial for downloading data from the Data Portal and the neonUtilities package, then exploring and understanding the downloaded data
dateCreated: '2018-11-07'
dataProducts: DP1.00024.001, DP1.20063.001, DP3.30015.001
authors: Claire K. Lunch
contributors: Christine Laney, Megan A. Jones, Donal O'Leary
estimatedTime: 1 - 2 hours
packagesLibraries: devtools, neonUtilities, raster
topics: data-management, rep-sci
languageTool: R, API
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/NEON-download-explore/NEON-download-explore.R
tutorialSeries:
urlTitle: download-explore-neon-data
---



This tutorial covers downloading NEON data, using the Data Portal and 
the neonUtilities R package, as well as basic instruction in beginning to 
explore and work with the downloaded data, including guidance in 
navigating data documentation.

## NEON data
There are 3 basic categories of NEON data:

1. Remote sensing (AOP) - Data collected by the airborne observation platform, 
e.g. LIDAR, surface reflectance
1. Observational (OS) - Data collected by a human in the field, or in an 
analytical laboratory, e.g. beetle identification, foliar isotopes
1. Instrumentation (IS) - Data collected by an automated, streaming sensor, e.g. 
net radiation, soil carbon dioxide. This category also includes the eddy 
covariance (EC) data, which are processed and structured in a unique way, distinct 
from other instrumentation data (see <a href="https://www.neonscience.org/eddy-data-intro" target="_blank">Tutorial for EC data</a> for details).

This lesson covers all three types of data. The download procedures are 
similar for all types, but data navigation differs significantly by type.

<div id="ds-objectives" markdown="1">

## Objectives

After completing this activity, you will be able to:

* Download NEON data using the neonUtilities package.
* Understand downloaded data sets and load them into R for analyses.

## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### Install R Packages

* **neonUtilities**: Basic functions for accessing NEON data
* **raster**: Raster package; needed for remote sensing data

Both of these packages can be installed from CRAN:


    install.packages("neonUtilities")
    install.packages("raster")


### Additional Resources

* <a href="https://www.neonscience.org/neonDataStackR" target="_blank">Tutorial for neonUtilities.</a> Some overlap with this tutorial but goes into more detail about the neonUtilities package.
* <a href="https://www.neonscience.org/neon-utilities-python" target="_blank">Tutorial for using neonUtilities from a Python environment.</a>
* <a href="https://github.com/NEONScience/NEON-Utilities/neonUtilities" target="_blank">GitHub repository for neonUtilities</a>
* <a href="https://www.neonscience.org/sites/default/files/cheat-sheet-neonUtilities.pdf" target="_blank">neonUtilities cheat sheet</a>. A quick reference guide for users.

</div>

## Getting started: Download data from the Portal and load packages

Go to the 
<a href="http://data.neonscience.org" target="_blank">NEON Data Portal</a> 
and download some data! Almost any IS or OS data product can be used for this 
section of the tutorial, but we will proceed assuming you've downloaded 
Photosynthetically Active Radiation (PAR) (DP1.00024.001) data. For optimal 
results, download three months of data from one site. The downloaded file 
should be a zip file named NEON_par.zip. For this tutorial, we will be using 
PAR data from the Wind River Experimental Forest (WREF) in Washington state 
from September-November 2019.

Now switch over to R and load all the packages installed above.


    # load packages
    library(neonUtilities)
    library(raster)
    
    # Set global option to NOT convert all character variables to factors
    options(stringsAsFactors=F)


## Stack the downloaded data files: stackByTable()

The `stackByTable()` function will unzip and join the files in the 
downloaded zip file.


    # Modify the file path to match the path to your zip file
    stackByTable("~/Downloads/NEON_par.zip")

In the same directory as the zipped file, you should now have an unzipped 
folder of the same name. When you open this you will see a new folder 
called **stackedFiles**, which should contain five files: 
**PARPAR_30min.csv**, **PARPAR_1min.csv**, **sensor_positions.csv**, 
**variables.csv**, and **readme.txt**.

We'll look at these files in more detail below.

## Download files and load directly to R: loadByProduct()

In the section above, we downloaded a .zip file from the data portal to
our downloads folder, then used the stackByTable() function to transform
those data into a usable format. However, there is a faster way to load
data directly into the R Global Environment using `loadByProduct()`.

The most popular function in `neonUtilities` is `loadByProduct()`. 
This function downloads data from the NEON API, merges the site-by-month 
files, and loads the resulting data tables into the R environment, 
assigning each data type to the appropriate R class. This is a popular 
choice because it ensures you're always working with the latest data, 
and it ends with ready-to-use tables in R. However, if you use it in
a workflow you run repeatedly, keep in mind it will re-download the 
data every time.

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
* `forceParallel`: If the data volume to be processed does not meet 
minimum requirements to run in parallel, this overrides.

The `dpID` is the data product identifier of the data you want to 
download. The DPID can be found on the 
<a href="http://data.neonscience.org/data-products/explore" target="_blank">
Explore Data Products page</a>.
It will be in the form DP#.#####.###

Here, we'll download aquatic plant chemistry data from 
three lake sites: Prairie Lake (PRLA), Suggs Lake (SUGG), 
and Toolik Lake (TOOK).


    apchem <- loadByProduct(dpID="DP1.20063.001", 
                      site=c("PRLA","SUGG","TOOK"), 
                      package="expanded", check.size=T)


The object returned by `loadByProduct()` is a named list of data 
frames. To work with each of them, select them from the list 
using the `$` operator.


    names(apchem)
    View(apchem$apl_plantExternalLabDataPerSample)

If you prefer to extract each table from the list and work 
with it as an independent object, you can use the 
`list2env()` function:


    list2env(apchem, .GlobalEnv)

    ## <environment: R_GlobalEnv>

If you want to be able to close R and come back to these data without 
re-downloading, you'll want to save the tables locally. We recommend 
also saving the variables file, both so you'll have it to refer to, and 
so you can use it with `readTableNEON()` (see below).


    write.csv(apl_clipHarvest, 
              "~/Downloads/apl_clipHarvest.csv", 
              row.names=F)
    write.csv(apl_biomass, 
              "~/Downloads/apl_biomass.csv", 
              row.names=F)
    write.csv(apl_plantExternalLabDataPerSample, 
              "~/Downloads/apl_plantExternalLabDataPerSample.csv", 
              row.names=F)
    write.csv(variables_20063, 
              "~/Downloads/variables_20063.csv", 
              row.names=F)

But, if you want to save files locally and load them into R (or another 
platform) each time you run a script, instead of downloading from the API 
every time, you may prefer to use `zipsByProduct()` and `stackByTable()` 
instead of `loadByProduct()`, as we did in the first section above. Details
can be found in our <a href="https://www.neonscience.org/neonDataStackR" target="_blank">neonUtilities tutorial</a>. You can also try out the 
community-developed `neonstore` package, which is designed for 
maintaining a local store of the NEON data you use.

## Download remote sensing data: byFileAOP() and byTileAOP()

Remote sensing data files are very large, so downloading them 
can take a long time. `byFileAOP()` and `byTileAOP()` enable 
easier programmatic downloads, but be aware it can take a very 
long time to download large amounts of data.

Input options for the AOP functions are:

* `dpID`: the data product ID, e.g. DP1.00002.001
* `site`: the 4-letter code of a single site, e.g. HARV
* `year`: the 4-digit year to download
* `savepath`: the file path you want to download to; defaults to the 
working directory
* `check.size`: T or F: should the function pause before downloading 
data and warn you about the size of your download? Defaults to T; if 
you are using this function within a script or batch process you 
will want to set it to F.
* `easting`: `byTileAOP()` only. Vector of easting UTM coordinates whose 
corresponding tiles you want to download
* `northing`: `byTileAOP()` only. Vector of northing UTM coordinates 
whose corresponding tiles you want to download
* `buffer`: `byTileAOP()` only. Size in meters of buffer to include 
around coordinates when deciding which tiles to download

Here, we'll download one tile of Ecosystem structure (Canopy Height 
Model) (DP3.30015.001) from WREF in 2017.


    byTileAOP("DP3.30015.001", site="WREF", year="2017", check.size = T,
              easting=580000, northing=5075000, savepath="~/Downloads")

In the directory indicated in `savepath`, you should now have a folder 
named `DP3.30015.001` with several nested subfolders, leading to a tif 
file of a canopy height model tile. We'll look at this in more detail 
below.

## Navigate data downloads: IS

Let's take a look at the PAR data we downloaded earlier. We'll 
read in the 30-minute file using the function `readTableNEON()`, 
which uses the `variables.csv` file to assign data types to each 
column of data:


    par30 <- readTableNEON(
      dataFile="~/Downloads/NEON_par/stackedFiles/PARPAR_30min.csv", 
      varFile="~/Downloads/NEON_par/stackedFiles/variables_00024.csv")
    View(par30)

The first four columns are added by `stackByTable()` when it merges 
files across sites, months, and tower heights. The final column, 
`publicationDate`, is the date-time stamp indicating when the data 
were published. This can be used as an indicator for whether data 
have been updated since the last time you downloaded them.

The remaining columns are described by the variables file:


    parvar <- read.csv("~/Downloads/NEON_par/stackedFiles/variables_00024.csv")
    View(parvar)

The variables file shows you the definition and units for each column 
of data.

Now that we know what we're looking at, let's plot PAR from the top 
tower level:


    plot(PARMean~startDateTime, 
         data=par30[which(par30$verticalPosition=="080"),],
         type="l")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/NEON-download-explore/rfigs/plot-par-1.png)

Looks good! The sun comes up and goes down every day, and some days 
are cloudy. If you want to dig in a little deeper, try plotting PAR 
from lower tower levels on the same axes to see light attenuation 
through the canopy.

## Navigate data downloads: OS

Let's take a look at the aquatic plant data. OS data products 
are simple in that the data generally tabular, and data volumes are 
lower than the other NEON data types, but they are complex in that 
almost all consist of multiple tables containing information collected 
at different times in different ways. For example, samples collected 
in the field may be shipped to a laboratory for analysis. Data 
associated with the field collection will appear in one data table, 
and the analytical results will appear in another. Complexity in 
working with OS data usually involves bringing data together from 
multiple measurements or scales of analysis.

As with the IS data, the variables file can tell you more about 
the data. OS data also come with a validation file, which contains 
information about the validation and controlled data entry that 
were applied to the data:


    View(variables_20063)
    
    View(validation_20063)

OS data products each come with a Data Product User Guide, 
which can be downloaded with the data, or accessed from the 
document library on the Data Portal, or the <a href="https://data.neonscience.org/data-products/DP1.20063.001" target="_blank">Product Details</a> 
page for the data product. The User Guide is designed to give 
a basic introduction to the data product, including a brief 
summary of the protocol and descriptions of data format and 
structure.

To get started with the aquatic plant chemistry data, let's 
take a look at carbon isotope ratios in plants across the three 
sites we downloaded. The chemical analytes are reported in the 
`apl_plantExternalLabDataPerSample` table, and the table is in 
long format, with one record per sample per analyte, so we'll 
subset to only the carbon isotope analyte:


    boxplot(analyteConcentration~siteID, 
            data=apl_plantExternalLabDataPerSample, 
            subset=analyte=="d13C",
            xlab="Site", ylab="d13C")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/NEON-download-explore/rfigs/13C-by-site-1.png)

We see plants at Suggs and Toolik are quite low in 13C, with more 
spread at Toolik than Suggs, and plants at Prairie Lake are relatively 
enriched. Clearly the next question is what species these data represent. 
But taxonomic data aren't present in the `apl_plantExternalLabDataPerSample` 
table, they're in the `apl_biomass` table. We'll need to join the two 
tables to get chemistry by taxon.

The Data Relationships section of the User Guide can help you determine 
which fields to use as the key to join the tables. Here, `sampleID` is 
the joining variable. We'll also include the basic spatial variables, to 
avoid creating unnecessary duplicates of those columns.


    apct <- merge(apl_biomass, 
                  apl_plantExternalLabDataPerSample, 
                  by=c("sampleID","namedLocation",
                       "domainID","siteID"))

Using the merged data, now we can plot carbon isotope ratio 
for each taxon.




    boxplot(analyteConcentration~scientificName, 
            data=apct, subset=analyte=="d13C", 
            xlab=NA, ylab="d13C", 
            las=2, cex.axis=0.7)

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/NEON-download-explore/rfigs/plot-13C-by-tax-1.png)

And now we can see most of the sampled plants have carbon 
isotope ratios around -30, with just two species accounting 
for most of the more enriched samples.

## Navigate data downloads: AOP

To work with AOP data, the best bet is the `raster` package. 
It has functionality for most analyses you might want to do.

We'll use it to read in the tile we downloaded:


    chm <- raster("~/Downloads/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")

The `raster` package includes plotting functions:




    plot(chm, col=topo.colors(6))

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/NEON-download-explore/rfigs/plot-aop-1.png)

Now we can see canopy height across the downloaded tile; 
the tallest trees are over 60 meters, not surprising in 
the Pacific Northwest. There is a clearing or clear 
cut in the lower right corner.

