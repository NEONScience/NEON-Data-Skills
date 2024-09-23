---
title: Content for download and explore tutorial
output: html_fragment
dateCreated: '2024-09-20'
---

This tutorial covers downloading NEON data, using the Data Portal and 
either the neonUtilities R package or the neonutilities Python package, 
as well as basic instruction in beginning to explore and work with the 
downloaded data, including guidance in navigating data documentation. 
We will explore data of 3 different types, and make a simple figure from 
each.

## NEON data
There are 3 basic categories of NEON data:

1. Remote sensing (AOP) - Data collected by the airborne observation platform, 
e.g. LIDAR, surface reflectance
1. Observational (OS) - Data collected by a human in the field, or in an 
analytical laboratory, e.g. beetle identification, foliar isotopes
1. Instrumentation (IS) - Data collected by an automated, streaming sensor, e.g. 
net radiation, soil carbon dioxide. This category also includes the 
surface-atmosphere exchange (SAE) data, which are processed and structured in 
a unique way, distinct from other instrumentation data 
(see the introductory <a href="https://www.neonscience.org/eddy-data-intro" target="_blank">eddy flux data tutorial</a> for details).

This lesson covers all three types of data. The download procedures are 
similar for all types, but data navigation differs significantly by type.

<div id="ds-objectives" markdown="1">

## Objectives

After completing this activity, you will be able to:

* Download NEON data using the neonUtilities package.
* Understand downloaded data sets and load them into R or Python for analyses.

## Things You’ll Need To Complete This Tutorial
You can follow either the R or Python code throughout this tutorial.
* For R users, we recommend using R version 4+ and RStudio.
* For Python users, we recommend using Python 3.9+.



## Set up: Install Packages {.tabset}

Packages only need to be installed once, you can skip this step after the first time:

### R

* **neonUtilities**: Basic functions for accessing NEON data
* **neonOS**: Functions for common data wrangling needs for NEON observational data.
* **terra**: Spatial data package; needed for working with remote sensing data.


    install.packages("neonUtilities")

    install.packages("neonOS")

    install.packages("terra")

### Python

* **neonutilities**: Basic functions for accessing NEON data
* **rasterio**: Spatial data package; needed for working with remote sensing data.


    pip install neonutilities

    pip install rasterio

## {-}

### Additional Resources

* <a href="https://www.neonscience.org/neon-utilities-python" target="_blank">Tutorial for using neonUtilities from a Python environment.</a>
* <a href="https://github.com/NEONScience/NEON-Utilities/neonUtilities" target="_blank">GitHub repository for neonUtilities</a>
* <a href="https://www.neonscience.org/sites/default/files/cheat-sheet-neonUtilities_0.pdf" target="_blank">neonUtilities cheat sheet</a>. A quick reference guide for users.

</div>


## Set up: Load packages {.tabset}

### R


    library(neonUtilities)

    library(neonOS)

    library(terra)

### Python


    
    import neonutilities as nu
    import os
    import rasterio
    import pandas as pd
    import matplotlib.pyplot as plt

## {-}


## Getting started: Download data from the Portal

Go to the 
<a href="http://data.neonscience.org" target="_blank">NEON Data Portal</a> 
and download some data! To follow the tutorial exactly, download 
Photosynthetically active radiation (PAR) (DP1.00024.001) data from 
September-November 2019 at Wind River Experimental Forest (WREF). The 
downloaded file should be a zip file named NEON_par.zip.

If you prefer to explore a different data product, you can still follow this 
tutorial. But it will be easier to understand the steps in the tutorial, 
particularly the data navigation, if you choose a sensor data product for 
this section.

Once you've downloaded a zip file of data from the portal, switch over to R 
or Python to proceed with coding.

## Stack the downloaded data files: stackByTable() {.tabset}

The `stackByTable()` (or `stack_by_table()`) function will unzip and join 
the files in the downloaded zip file.

### R


    # Modify the file path to match the path to your zip file

    stackByTable("~/Downloads/NEON_par.zip")

### Python


    # Modify the file path to match the path to your zip file

    nu.stack_by_table(os.path.expanduser("~/Downloads/NEON_par.zip"))

## {-}

In the directory where the zipped file was saved, you should now have 
an unzipped folder of the same name. When you open this you will see a 
new folder called **stackedFiles**, which should contain at least seven 
files: **PARPAR_30min.csv**, **PARPAR_1min.csv**, **sensor_positions.csv**, 
**variables_00024.csv**, **readme_00024.txt**, **issueLog_00024.csv**, 
and **citation\_00024\_RELEASE-202X.txt**.

## Navigate data downloads: IS {.tabset}

Let's start with a brief description of each file. This set of files is 
typical of a NEON IS data product.

* **PARPAR_30min.csv**: PAR data at 30-minute averaging intervals
* **PARPAR_1min.csv**: PAR data at 1-minute averaging intervals
* **sensor_positions.csv**: The physical location of each sensor collecting PAR measurements. There is a PAR sensor at each level of the WREF tower, and this table lets you connect the tower level index to the height of the sensor in meters.
* **variables_00024.csv**: Definitions and units for each data field in the PARPAR_#min tables.
* **readme_00024.txt**: Basic information about the PAR data product.
* **issueLog_00024.csv**: A record of known issues associated with PAR data.
* **citation\_00024\_RELEASE-202X.txt**: The citation to use when you publish a paper using these data, in BibTeX format.

We'll explore the 30-minute data. To read the file, use the function 
`readTableNEON()` or `read_table_neon()`, which uses the variables file 
to assign data types to each column of data:

### R


    par30 <- readTableNEON(
      dataFile="~/Downloads/NEON_par_R/stackedFiles/PARPAR_30min.csv", 
      varFile="~/Downloads/NEON_par_R/stackedFiles/variables_00024.csv")

    head(par30)

    par30 <- readTableNEON(

      dataFile="~/Downloads/NEON_par/stackedFiles/PARPAR_30min.csv", 

      varFile="~/Downloads/NEON_par/stackedFiles/variables_00024.csv")

    head(par30)

### Python


    
    par30 = nu.read_table_neon(
      data_file=os.path.expanduser(
        "~/Downloads/NEON_par/stackedFiles/PARPAR_30min.csv"), 
      var_file=os.path.expanduser(
        "~/Downloads/NEON_par/stackedFiles/variables_00024.csv"))
    # Open the par30 table in the table viewer of your choice

## {-}

The first four columns are added by `stackByTable()` when it merges 
files across sites, months, and tower heights. The column 
`publicationDate` is the date-time stamp indicating when the data 
were published, and the `release` column indicates which NEON data release 
the data belong to. For more information about NEON data releases, see the 
<a href="https://www.neonscience.org/data-samples/data-management/data-revisions-releases" target="_blank">Data Product Revisions and Releases</a> page.

Information about each data column can be found in the variables file, 
where you can see definitions and units for each column of data.

### Plot PAR data {.tabset}

Now that we know what we're looking at, let's plot PAR from the top 
tower level. We'll use the mean PAR from each averaging interval, and we 
can see from the sensor positions file that the vertical index 080 
corresponds to the highest tower level. To explore the sensor positions 
data in more depth, see the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/neon-spatial-data-basics" target="_blank">spatial data</a> tutorial.

#### R


    plot(PARMean~endDateTime, 
         data=par30[which(par30$verticalPosition=="080"),],
         type="l")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/NEON-download-explore/rfigs/plot-par-1.png)

#### Python


    par30top = par30[par30.verticalPosition=="080"]
    fig, ax = plt.subplots()
    ax.plot(par30top.endDateTime, par30top.PARMean)
    plt.show()

<div class="figure">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/NEON-download-explore/rfigs/p-plot-par-1.png" alt=" " width="672" />
<p class="caption"> </p>
</div>

### {-}

Looks good! The sun comes up and goes down every day, and some days 
are cloudy.

### Plot more PAR data {.tabset}

To see another layer of data, add PAR from a lower tower level to the 
plot.

#### R


    plot(PARMean~endDateTime, 
         data=par30[which(par30$verticalPosition=="080"),],
         type="l")

    

    lines(PARMean~endDateTime, 
         data=par30[which(par30$verticalPosition=="020"),],
         col="blue")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/NEON-download-explore/rfigs/plot-par-lower-3.png)

#### Python


    par30low = par30[par30.verticalPosition=="020"]
    fig, ax = plt.subplots()
    ax.plot(par30top.endDateTime, par30top.PARMean)
    ax.plot(par30low.endDateTime, par30low.PARMean)
    plt.show()

<div class="figure">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/NEON-download-explore/rfigs/p-plot-par-lower-1.png" alt=" " width="672" />
<p class="caption"> </p>
</div>

### {-}

We can see there is a lot of light attenuation through the canopy.

## Download files and load directly to R: loadByProduct() {.tabset}

At the start of this tutorial, we downloaded data from the NEON data portal. 
NEON also provides an API, and the `neonUtilities` packages provide methods 
for downloading programmatically in R.

The steps we carried out above - downloading from the portal, stacking the 
downloaded files, and reading in to R or Python - can all be carried out in 
one step by the neonUtilities function `loadByProduct()`.

To get the same PAR data we worked with above, we would run this line of code 
using `loadByProduct()`:

### R























































