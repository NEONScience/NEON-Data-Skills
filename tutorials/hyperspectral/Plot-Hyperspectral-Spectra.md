---
syncID: 79f902f6c0264f16a9be13f50560860a
title: "Plot Spectral Profiles Derived from Hyperspectral Remote Sensing Data in HDF5 Format in R"
description: "Extract a single pixel's worth of spectra from a hyperspectral dataset stored in HDF5 format in R. Visualize the spectral profile." 
dateCreated:  2015-08-08 20:49:52
authors: Leah A. Wasser, Donal O'Leary
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

* Extract and plot a single spectral signature from an HDF5 file.
* Work with groups and datasets within an HDF5 file.


## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### R Libraries to Install:

* **rhdf5**: `install.packages("BiocManager")`, `BiocManager::install("rhdf5")`
* **plyr**: `install.packages('plyr')`
* **ggplot2**: `install.packages('ggplot2')`

<a href="{{ site.baseurl }}/packages-in-r" target="_blank"> More on Packages in
 R - Adapted from Software Carpentry.</a>


### Data to Download
{% include/dataSubsets/_data_Imaging-Spec-Data-H5-2020.html %}

***
{% include/_greyBox-wd-rscript.html %}

***
### Recommended Skills

We highly recommend you work through the 
<a href="{{ site.baseurl }}/hsi-hdf5-r" target="_blank"> *Introduction to Working with Hyperspectral Data in HDF5 Format in R* tutorial</a>
before moving on to this tutorial.

</div> 


In this tutorial, we will extract a single-pixel's worth of reflectance values to
plot a spectral signature for that pixel.


    # Call required packages
    library(rhdf5)
    library(plyr)
    library(ggplot2)
    
    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files. Be sure to move the download into your working directory!
    wd="~/Desktop/Hyperspectral_Tutorial/" #This will depend on your local environment
    setwd(wd)

Now, we need to access the H5 file.


    # Define the file name to be opened
    f <- paste0(wd,"NEON_hyperspectral_tutorial_example_subset.h5")
    # look at the HDF5 file structure 
    h5ls(f,all=T) 

    ##                                           group                     name
    ## 0                                             /                     SJER
    ## 1                                         /SJER              Reflectance
    ## 2                             /SJER/Reflectance                 Metadata
    ## 3                    /SJER/Reflectance/Metadata        Coordinate_System
    ## 4  /SJER/Reflectance/Metadata/Coordinate_System Coordinate_System_String
    ## 5  /SJER/Reflectance/Metadata/Coordinate_System                EPSG Code
    ## 6  /SJER/Reflectance/Metadata/Coordinate_System                 Map_Info
    ## 7  /SJER/Reflectance/Metadata/Coordinate_System                    Proj4
    ## 8                    /SJER/Reflectance/Metadata            Spectral_Data
    ## 9      /SJER/Reflectance/Metadata/Spectral_Data               Wavelength
    ## 10                            /SJER/Reflectance         Reflectance_Data
    ##            ltype corder_valid corder cset       otype num_attrs  dclass
    ## 0  H5L_TYPE_HARD        FALSE      0    0   H5I_GROUP         0        
    ## 1  H5L_TYPE_HARD        FALSE      0    0   H5I_GROUP         5        
    ## 2  H5L_TYPE_HARD        FALSE      0    0   H5I_GROUP         0        
    ## 3  H5L_TYPE_HARD        FALSE      0    0   H5I_GROUP         0        
    ## 4  H5L_TYPE_HARD        FALSE      0    0 H5I_DATASET         0  STRING
    ## 5  H5L_TYPE_HARD        FALSE      0    0 H5I_DATASET         0  STRING
    ## 6  H5L_TYPE_HARD        FALSE      0    0 H5I_DATASET         1  STRING
    ## 7  H5L_TYPE_HARD        FALSE      0    0 H5I_DATASET         0  STRING
    ## 8  H5L_TYPE_HARD        FALSE      0    0   H5I_GROUP         0        
    ## 9  H5L_TYPE_HARD        FALSE      0    0 H5I_DATASET         2   FLOAT
    ## 10 H5L_TYPE_HARD        FALSE      0    0 H5I_DATASET        13 INTEGER
    ##             dtype  stype rank             dim          maxdim
    ## 0                           0                                
    ## 1                           0                                
    ## 2                           0                                
    ## 3                           0                                
    ## 4      H5T_STRING SIMPLE    1               1               1
    ## 5      H5T_STRING SIMPLE    1               1               1
    ## 6      H5T_STRING SIMPLE    1               1               1
    ## 7      H5T_STRING SIMPLE    1               1               1
    ## 8                           0                                
    ## 9  H5T_IEEE_F64LE SIMPLE    1             107             107
    ## 10  H5T_STD_I32LE SIMPLE    3 107 x 500 x 500 107 x 500 x 500


## Read Wavelength Values

Next, let's read in the wavelength center associated with each band in the HDF5 
file. 


    # read in the wavelength information from the HDF5 file
    wavelengths <- h5read(f,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")


## Extract Z-dimension data slice

Next, we will extract all reflectance values for one pixel. This makes up the 
spectral signature or profile of the pixel. To do that, we'll use the `h5read` 
function. Here we pick an arbitrary pixel at `(100,35)`, and use the `NULL` 
value to select _all_ bands from that location.


    # extract all bands from a single pixel
    aPixel <- h5read(f,"/SJER/Reflectance/Reflectance_Data",index=list(NULL,100,35) )
    
    # The line above generates a vector of reflectance values.
    # Next, we reshape the data and turn into dataframe
    b <- adply(aPixel,c(1))
    
    # create clean data frame
    aPixeldf <- b[2]
    
    # add wavelength data to matrix
    aPixeldf$Wavelength <- wavelengths
    
    head(aPixeldf)

    ##    V1 Wavelength
    ## 1 720   381.5437
    ## 2 337   401.5756
    ## 3 336   421.6075
    ## 4 399   441.6394
    ## 5 406   461.6713
    ## 6 426   481.7032

## Scale Factor

Then, we can pull the spatial attributes that we'll need to adjust the reflectance 
values. Often, large raster data contain floating point (values with decimals) information.
However, floating point data consume more space (yield a larger file size) compared
to integer values. Thus, to keep the file sizes smaller, the data will be scaled
by a factor of 10, 100, 10000, etc. This `scale factor` will be noted in the data attributes.


    # grab scale factor from the Reflectance attributes
    reflectanceAttr<- h5readAttributes(f,"/SJER/Reflectance/Reflectance_Data" )
    
    scaleFact = reflectanceAttr$Scale_Factor
    
    # add scaled data column to DF
    aPixeldf$scaled <- (aPixeldf$V1/as.vector(scaleFact))
    
    # make nice column names
    names(aPixeldf) <- c('Reflectance','Wavelength','ScaledReflectance')
    head(aPixeldf)

    ##   Reflectance Wavelength ScaledReflectance
    ## 1         720   381.5437            0.0720
    ## 2         337   401.5756            0.0337
    ## 3         336   421.6075            0.0336
    ## 4         399   441.6394            0.0399
    ## 5         406   461.6713            0.0406
    ## 6         426   481.7032            0.0426

## Plot Spectral Profile

Now we're ready to plot our spectral profile!


    qplot(x=aPixeldf$Wavelength, 
          y=aPixeldf$ScaledReflectance,
          geom="line",
          xlab="Wavelength (nm)",
          ylab="Reflectance")

![ ]({{ site.baseurl }}/images/rfigs/hyperspectral/Plot-Hyperspectral-Spectra/plot-spectra-1.png)

