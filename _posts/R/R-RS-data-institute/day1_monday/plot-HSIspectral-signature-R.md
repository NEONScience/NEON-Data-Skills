---
layout: post
title: "Plot a Spectral Signature from Hyperspectral Remote Sensing data in R -  HDF5"
date:   2016-06-18
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah, Naupaka]
contributors: [Megan A. Jones]
time: "4:00"
dateCreated:  2016-05-01
lastModified: 2016-06-22
packagesLibraries: [rhdf5]
categories: [self-paced-tutorial]
mainTag: institute-day1
tags: [R, HDF5]
tutorialSeries: [institute-day1]
description: "Learn how to plot a spectral signature from a NEON HDF5 file in R."
code1: R/plot-HSIspectral-signature-R.R
image:
  feature:
  credit:
  creditlink:
permalink: /R/plot-spectral-signature/
comments: false
---


<div id="objectives">
<strong>R Skill Level:</strong> Intermediate

<h3>Goals / Objectives</h3>
After completing this activity, you will be able to:
<ol>
<li>Extract and plot spectra from an HDF5 file.</li>
<li>Work with groups and datasets within an HDF5 file.</li>
</ol>

</div>


In this tutorial, we will extract a single-pixel's worth of reflectance values to
plot a spectral profile for that pixel.


    #first call required libraries
    library(rhdf5)
    library(raster)
    library(plyr)
    library(rgeos)
    library(rgdal)
    library(ggplot2)
    
    # be sure to set your working directory
    # setwd("~/Documents/data/NEONDI-2016") # Mac
    # setwd("~/data/NEONDI-2016")  # Windows

## Import H5 Functions

In this scenario, we have built a suite of **fuctions** that allow us to quickly
open and read from an H5 file. Rather than code out each step to open the H5 file,
let's open that file first using the `source` function which reads the functions into
our working environment. We can then use the funtions to quickly and efficiently
open the H5 data.


    ## VIA dev tools
    
    # install devtools (only if you have not previously intalled it)
    # install.packages("devtools")
    # call devtools library
    library(devtools)
    
    ## install from github
    install_github("lwasser/neon-aop-package/neonAOP")

    ## Skipping install for github remote, the SHA1 (5b9a37fe) has not changed since last install.
    ##   Use `force = TRUE` to force installation

    ## call library
    library(neonAOP)
    
    
    
    ## VIA SOURCE
    
    # your file will be in your working directory! This one happens to be in a diff dir
    # than our data
    
    # source("/Users/lwasser/Documents/GitHub/neon-data-institute-2016/_posts/institute-materials/day1_monday/import-HSIH5-functions.R")
    
    # source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")

First, we need to access the H5 file.


    # Define the file name to be opened
    f <- "NEONdata/D17-California/TEAK/2013/spectrometer/reflectance/Subset3NIS1_20130614_100459_atmcor.h5"
    
    # Look at the HDF5 file structure
    h5ls(f, all=T)

## Open a Band

Next, we can use the `open_band` function to quickly open up a band.
Let's open band 56.


    # get CRS
    epsg <- 32611
    # open band
    band <- open_band(fileName=f,
                      bandNum = 56,
                      epsg=epsg)
    # plot data
    plot(band,
         main="NEON Hyperspectral Data\n Band 56",
         col=grey(1:100/100))

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/plot-HSIspectral-signature-R/read-spatial-attributes-1.png)

## Read Wavelength Values

Next, let's read in the wavelength center associated with each band in the HDF5
file.



    #read in the wavelength information from the HDF5 file
    wavelengths<- h5read(f,"wavelength")
    # convert wavelength to nanometers (nm)
    # NOTE: this is optional!
    wavelengths <- wavelengths*1000

## Extract Z-dimension data slice

Next, we will extract all reflectance values for one pixel. This makes up the
spectral signature or profile of the pixel. To do that, we'll use the `h5read`
function.

We will use the `adply` function to convert the data in array format, into a
dataframe for easy plotting.



    # extract Spectra from a single "pixel:
    # keep in mind that the first value is your columns and the second is rows
    # "null" tells the function to return ALL values in the matrix (n=426 bands)
    aPixel<- h5read(f,  # the file
                    "Reflectance",  # the dataset in the file
                    index=list(54, 36, NULL)) # the column, row and band(s)
    
    # reshape the data and turn into dataframe
    # split the data by the 3rd dimension
    aPixeldf <- adply(aPixel, 3)
    
    # we only need the second row of the df, the first row is a duplicate
    aPixeldf <- aPixeldf[2]
    names(aPixeldf) <- c("reflectance")
    
    
    # add wavelength data to matrix
    aPixeldf$wavelength <- wavelengths
    
    head(aPixeldf)

    ##   reflectance wavelength
    ## 1         503      382.3
    ## 2         623      387.3
    ## 3         720      392.3
    ## 4         692      397.3
    ## 5         550      402.3
    ## 6         563      407.3

## Scale Factor

Then, we can pull the spatial attributes that we'll need to adjust the reflectance
values. Often, large raster data contain floating point (values with decimals) information.
However, floating point data consume more space (yield a larger file size) compared
to integer values. Thus, to keep the file sizes smaller, the data will be scaled
by a factor of 10, 100, 10000, etc. This `scale factor` will be noted in the data attributes.


    # r get attributes for the Reflectance dataset
    reflInfo <- h5readAttributes(f,"Reflectance")
    
    # grab scale factor
    scale.factor <- reflInfo$`Scale Factor`
    
    # add scaled data column to DF
    aPixeldf$reflectance <- aPixeldf$reflectance/scale.factor
    
    head(aPixeldf)

    ##   reflectance wavelength
    ## 1      0.0503      382.3
    ## 2      0.0623      387.3
    ## 3      0.0720      392.3
    ## 4      0.0692      397.3
    ## 5      0.0550      402.3
    ## 6      0.0563      407.3

## Plot Spectral Profile

Now we're ready to plot our spectral profile!


    # plot using GGPLOT2
    qplot(x=aPixeldf$wavelength,
          y=aPixeldf$reflectance,
          xlab="Wavelength (nm)",
          ylab="Reflectance",
          main="Spectral Signature for a Single Pixel")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/plot-HSIspectral-signature-R/plot-spectra-1.png)
