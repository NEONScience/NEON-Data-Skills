---
syncID: 79f902f6c0264f16a9be13f50560860a
title: "Plot Spectral Profiles Derived from Hyperspectral Remote Sensing Data in HDF5 Format in R"
description: "Extract a single pixel's worth of spectra from a a hyperspectral dataset stored in HDF5 format in R. Visualize the spectral profile." 
dateCreated:  2015-08-08 20:49:52
authors: Leah A. Wasser
contributors:
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: rhdf5, raster, rgdal, plyr
topics: hyperspectral, HDF5, remote-sensing 
languagesTool: R
dataProduct:
code1: hyperspectral/Plot-Hyperspectral-Spectra.R
tutorialSeries:
urlTitle: plot-hsi-spectral-profile-r
---

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

* Extract and plot spectra from an HDF5 file.
* Work with groups and datasets within an HDF5 file.


## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### R Libraries to Install:

* **rhdf5**: `source("http://bioconductor.org/biocLite.R")`, `biocLite("rhdf5")`
* **plyr**: `install.packages('plyr')`
* **ggplot2**: `install.packages('ggplot2')`

[ {{ site.baseurl }}/packages-in-r](More on Packages in R - Adapted from Software Carpentry.)

### Data to Download
{% include/dataSubsets/_data_Imaging-Spec-Data-H5.html %}

***
{% include/_greyBox-wd-rscript.html %}
***
### Recommended Skills

We highly recommend you work through the 
<a href="{{ site.baseurl }}/HDF5/Imaging-Spectroscopy-HDF5-In-R/" target="_blank"> *Introduction to Working with Hyperspectral Data in HDF5 Format in R* tutorial</a>
before moving on to this tutorial.

</div> 


In this tutorial, we will extract a single-pixel's worth of reflectance values to
plot a spectral profile for that pixel.


    # Call required packages
    library(rhdf5)
    library(plyr)
    library(ggplot2)
    
    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files
    #setwd("working-dir-path-here")

Now, we need to access the H5 file.


    # Define the file name to be opened
    f <- 'NEON-DS-Imaging-Spectrometer-Data.h5'
    # look at the HDF5 file structure 
    h5ls(f,all=T) 

    ##   group        name         ltype corder_valid corder cset       otype
    ## 0     / Reflectance H5L_TYPE_HARD        FALSE      0    0 H5I_DATASET
    ## 1     /        fwhm H5L_TYPE_HARD        FALSE      0    0 H5I_DATASET
    ## 2     /    map info H5L_TYPE_HARD        FALSE      0    0 H5I_DATASET
    ## 3     / spatialInfo H5L_TYPE_HARD        FALSE      0    0   H5I_GROUP
    ## 4     /  wavelength H5L_TYPE_HARD        FALSE      0    0 H5I_DATASET
    ##   num_attrs  dclass          dtype  stype rank             dim
    ## 0         6 INTEGER  H5T_STD_I16LE SIMPLE    3 477 x 502 x 426
    ## 1         2   FLOAT H5T_IEEE_F32LE SIMPLE    2         426 x 1
    ## 2         1  STRING     HST_STRING SIMPLE    1               1
    ## 3        11                                  0                
    ## 4         2   FLOAT H5T_IEEE_F32LE SIMPLE    2         426 x 1
    ##            maxdim
    ## 0 477 x 502 x 426
    ## 1         426 x 1
    ## 2               1
    ## 3                
    ## 4         426 x 1

Next, we can read the spatial attributes of the file.


    # r get spatialInfo using the h5readAttributes function 
    spInfo <- h5readAttributes(f,"spatialInfo")
    
    # r get attributes for the Reflectance dataset
    reflInfo <- h5readAttributes(f,"Reflectance")

## Read Wavelength Values

Next, let's read in the wavelength center associated with each band in the HDF5 
file. 


    # read in the wavelength information from the HDF5 file
    wavelengths<- h5read(f,"wavelength")
    # convert wavelength to nanometers (nm)
    # NOTE: this is optional!
    wavelengths <- wavelengths*1000


## Extract Z-dimension data slice

Next, we will extract all reflectance values for one pixel. This makes up the 
spectral signature or profile of the pixel. To do that, we'll use the `h5read` 
function.


    # extract Some Spectra from a single pixel
    aPixel<- h5read(f,"Reflectance",index=list(54,36,NULL))
    
    # reshape the data and turn into dataframe
    b <- adply(aPixel,c(3))
    
    # create clean data frame
    aPixeldf <- b[2]
    
    # add wavelength data to matrix
    aPixeldf$Wavelength <- wavelengths
    
    head(aPixeldf)

    ##    V1 Wavelength
    ## 1 237     382.27
    ## 2 240     387.28
    ## 3 298     392.29
    ## 4 278     397.30
    ## 5 207     402.31
    ## 6 235     407.32

    # we are now done working with the HDF5 file and are now using the dataframe `b`. 
    # therefore, we should close the H5 file
    H5close()

## Scale Factor

Then, we can pull the spatial attributes that we'll need to adjust the reflectance 
values. Often, large raster data contain floating point (values with decimals) information.
However, floating point data consume more space (yield a larger file size) compared
to integer values. Thus, to keep the file sizes smaller, the data will be scaled
by a factor of 10, 100, 10000, etc. This `scale factor` will be noted in the data attributes.


    # grab scale factor
    scaleFact <- reflInfo$`Scale Factor`
    
    # add scaled data column to DF
    aPixeldf$scaled <- (aPixeldf$V1/scaleFact)
    
    # make nice column names
    names(aPixeldf) <- c('Reflectance','Wavelength','ScaledReflectance')
    head(aPixeldf)

    ##   Reflectance Wavelength ScaledReflectance
    ## 1         237     382.27            0.0237
    ## 2         240     387.28            0.0240
    ## 3         298     392.29            0.0298
    ## 4         278     397.30            0.0278
    ## 5         207     402.31            0.0207
    ## 6         235     407.32            0.0235

## Plot Spectral Profile

Now we're ready to plot our spectral profile!


    qplot(x=aPixeldf$Wavelength, 
          y=aPixeldf$ScaledReflectance,
          xlab="Wavelength (nm)",
          ylab="Reflectance")

![ ]({{ site.baseurl }}/images/rfigs/hyperspectral/Plot-Hyperspectral-Spectra/plot-spectra-1.png)

