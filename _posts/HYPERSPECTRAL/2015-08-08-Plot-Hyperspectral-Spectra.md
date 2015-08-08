---
layout: post
title: "Plotting Spectral Profiles derived from Hyperspectral Remote Sensing Data in HDF5 Format in R"
date:   2015-08-08 20:49:52
dateCreated:  2015-08-08 20:49:52
lastModified: 2015-08-08 20:49:52
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: rhdf5, raster, rgdal, plyr
authors: Leah A. Wasser
categories: [remote-sensing]
category: remote-sensing
tags: [hyperspectral-remote-sensing,R,HDF5]
mainTag: hyperspectral-remote-sensing
description: "Extract a single pixel's worth of spectra from a a hyperspectral dataset stored in HDF5 format in R. Visualize the spectral profile." 
image:
  feature: hierarchy_folder_purple.png
  credit: The Artistry of Colin Williams, NEON
  creditlink: http://www.neoninc.org
permalink: /HDF5/Plot-Hyperspectral-Pixel-Spectral-Profile-In-R/
code1: R/2015-08-08-Plot-Hyperspectral-Spectra.R
comments: true
---

<section id="table-of-contents" class="toc">
  <header>
    <h3>Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->

<div id="objectives">
<strong>R Skill Level:</strong> Intermediate

<h3>Goals / Objectives</h3>
After completing this activity, you will:
<ol>
<li>Understand how to extract and plot spectra from an HDF5 file.</li>
<li>Know how to work with groups and datasets within an HDF5 file.</li>

</ol>

<h3>What you'll Need</h3>
<ul>
<li>R or R studio to write your code.</li>
<li>The latest version of RHDF5 packag for R.</li>
</ul>

<h3>R Libraries to Install</h3>
<ul>
<li>rhdf5: <code>source("http://bioconductor.org/biocLite.R") ;
biocLite("rhdf5")</code></li>
<li>raster: <code>install.packages('raster')</code></li>
<li>rgdal: <code>install.packages('rgdal')</code></li>
<li>plyr: <code>install.packages('plyr')</code></li>

</ul>

<h3>Data to Download</h3>
<a href="http://neonhighered.org/Data/HDF5/SJER_140123_chip.h5" class="btn btn-success"> 
DOWNLOAD the NEON Imaging Spectrometer Data (HDF5) Format</a>. 
<p>The data in this HDF5 file were collected over the San Joachim field site 
located in California (NEON Domain 17) and processed at NEON headquarters. The 
entire dataset can be accessed <a href="http://neoninc.org/data-resources/get-data/airborne-data" target="_blank">by request from the NEON website.</a>
</p>  
</div> 


In this tutorial, we will extract a single-pixel's worth of reflectance values to
plot a spectral profile for that pixel.


    #first call required libraries
    library(rhdf5)
    library(plyr)
    library(ggplot2)

First, we need to access the H5 file.


    #Define the file name to be opened
    f <- 'SJER_140123_chip.h5'
    #look at the HDF5 file structure 
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


    #r get spatialInfo using the h5readAttributes function 
    spInfo <- h5readAttributes(f,"spatialInfo")
    
    #r get attributes for the Reflectance dataset
    reflInfo <- h5readAttributes(f,"Reflectance")

##Read Wavelength Values

Next, let's read in the wavelength center associated with each band in the HDF5 
file. 



    #read in the wavelength information from the HDF5 file
    wavelengths<- h5read(f,"wavelength")
##Extract Z-dimension data slice

Next, we will extract all reflectance values for one pixel. This makes up the 
spectral signature or profile of the pixel. To do that, we'll use the `h5read` 
function.



    #extract Some Spectra from a single pixel
    aPixel<- h5read(f,"Reflectance",index=list(54,36,NULL))
    
    #reshape the data and turn into dataframe
    b <- adply(aPixel,c(3))
    
    #create clean data frame
    aPixeldf <- b[2]
    
    
    #add wavelength data to matrix
    aPixeldf$Wavelength <- wavelengths
    
    head(aPixeldf)

    ##    V1 Wavelength
    ## 1 237    0.38227
    ## 2 240    0.38728
    ## 3 298    0.39229
    ## 4 278    0.39730
    ## 5 207    0.40231
    ## 6 235    0.40732

##Scale Factor

Then, we can pull the spatial attributes that we'll need to adjust the reflectance 
values. Often, large raster data contain floating point (values with decimals) information.
However, floating point data consume more space (yield a larger file size) compared
to integer values. Thus, to keep the file sizes smaller, the data will be scaled
by a factor of 10, 100, 10000, etc. This `scale factor` will be noted in the data attributes.


    #grab scale factor
    scaleFact <- reflInfo$`Scale Factor`
    
    #add scaled data column to DF
    aPixeldf$scaled <- (aPixeldf$V1/scaleFact)
    
    #make nice column names
    names(aPixeldf) <- c('Reflectance','Wavelength','ScaledReflectance')
    head(aPixeldf)

    ##   Reflectance Wavelength ScaledReflectance
    ## 1         237    0.38227            0.0237
    ## 2         240    0.38728            0.0240
    ## 3         298    0.39229            0.0298
    ## 4         278    0.39730            0.0278
    ## 5         207    0.40231            0.0207
    ## 6         235    0.40732            0.0235

##Plot Spectral Profile

Now we're ready to plot our spectral profile!


    qplot(x=aPixeldf$Wavelength, 
          y=aPixeldf$ScaledReflectance,
          xlab="Wavelength (nm)",
          ylab="Reflectance")

![ ]({{ site.baseurl }}/images/rfigs/2015-08-08-Plot-Hyperspectral-Spectra/plot-spectra-1.png) 

