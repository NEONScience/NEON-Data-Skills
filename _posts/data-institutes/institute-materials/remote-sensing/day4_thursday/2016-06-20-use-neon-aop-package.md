---
layout: post
title: "Use NEON AOP Package"
date:   2016-06-18
dateCreated:  2016-05-01
lastModified: 2016-06-23
authors: [Leah A. Wasser]
instructors: 
time: "1:00"
contributors: []
packagesLibraries: [neonAOP]
categories: [self-paced-tutorial]
mainTag: institute-day4
tags: [R, HDF5]
tutorialSeries: institute-day4
description: "Short vignettes that showcase the use of the NEON AOP Package."
code1:  /institute-materials/day4_thursday/use-neon-aop-package.R
image:
  feature: 
  credit: 
  creditlink:
permalink: /R/use-neon-aop-package/
comments: true
---

First, let's load the required libraries.


    ## import R library from github
    # install devtools (if you have not previously intalled it)
    # install.packages("devtools")
    # call devtools library
    # library(devtools)
    
    # install package from github
    # install_github("lwasser/neon-aop-package/neonAOP")
    # call package
    library(neonAOP)
    
    # load packages
    library(raster, rgeos, rgdao)
    library(rhdf5)
    library(ggplot2)
    
    # set wd
    # setwd("~/Documents/data/NEONDI-2016") # Mac
    # setwd("~/data/NEONDI-2016")  # Windows


## Open a Single Band


    # define the CRS definition by EPSG code
    epsg <- 32611
    
    # define the file you want to work with
    f <- "NEONdata/D17-California/TEAK/2013/spectrometer/reflectance/Subset3NIS1_20130614_100459_atmcor.h5"
    
    # open band, return cleaned and scaled raster
    band56 <- open_band(fileName=f,
                      bandNum = 56,
                      epsg=epsg)
    
    # plot data
    plot(band56,
         main="Raster for Lower Teakettle - B56")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day4_thursday/use-neon-aop-package/import-band-1.png)


## Open Several Bands / Create Stack


    # extract 3 bands
    # create  alist of the bands
    # RGB Combo
    bands <- c(58, 34, 19)
    RGBStack <- create_stack(f, 
                             bands, 
                             epsg)
    # plot the stack
    plotRGB(RGBStack, 
            stretch='lin')

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day4_thursday/use-neon-aop-package/create-stack-1.png)

    # CIR create  alist of the bands
    bands <- c(90, 34, 19)
    
    CIRStack <- create_stack(f, 
                             bands, 
                             epsg)
    # plot the stack
    plotRGB(CIRStack, 
            stretch='lin')

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day4_thursday/use-neon-aop-package/create-stack-2.png)

## Try some other band combos:

* `bands <- c(152,90,58)`
* FALSE COLOR: `bands <- c(363, 246, 58)`

Next, let's extract a spatial SUBSET from a H5 file.


    # open file clipping extent
    clip.extent <- readOGR("NEONdata/D17-California/TEAK/vector_data", 
                           "TEAK_plot")

    ## OGR data source with driver: ESRI Shapefile 
    ## Source: "NEONdata/D17-California/TEAK/vector_data", layer: "TEAK_plot"
    ## with 1 features
    ## It has 1 fields

    # calculate extent of H5 file
    h5.ext <- create_extent(f)
    h5.ext

    ## class       : Extent 
    ## xmin        : 325963 
    ## xmax        : 326507 
    ## ymin        : 4102904 
    ## ymax        : 4103482

    # turn the H5 extent into a polygon to check overlap
    h5.ext.poly <- as(extent(h5.ext), 
                      "SpatialPolygons")
    
    crs(h5.ext.poly) <- crs(clip.extent)
    
    # test to see that the extents overlap
    gIntersects(h5.ext.poly, 
                clip.extent)

    ## [1] TRUE

    # Use the clip extent to create the index extent that can be used to slice out data from the 
    # H5 file
    # xmin.index, xmax.index, ymin.index, ymax.index
    # all units will be rounded which means the pixel must occupy a majority (.5 or greater)
    # within the clipping extent
    index.bounds <- calculate_index_extent(extent(clip.extent),
    								h5.ext)
    index.bounds

    ## [1]  39 127  21  92

    # open a band that is subsetted using the clipping extent
    # if you set subsetData to true, then provide the dimensions that you wish to slice out
    b58_clipped <- open_band(fileName=f,
    								bandNum=58,
    								epsg=32611,
    								subsetData = TRUE,
    								dims=index.bounds)
    
    # plot clipped bands
    plot(b58_clipped,
         main="Band 58 Clipped")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day4_thursday/use-neon-aop-package/extract-subset-1.png)


## Extract a Subset from a Stack


    # create  alist of the bands
    bands <- c(19,34,58)
    
    # clip out raster
    rgbRast.clip <- create_stack(file=f,
                bands=bands,
                epsg=epsg,
                subset=TRUE,
                dims=index.bounds)
    
    plotRGB(rgbRast.clip,
            stretch="lin")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day4_thursday/use-neon-aop-package/extract-stack-1.png)

    rgbRast <- create_stack(file=f,
                  bands=bands,
                  epsg=epsg,
                  subset=FALSE)
    
    plotRGB(rgbRast,
            stretch="lin")
    
    plot(clip.extent,
         add=T,
         border="yellow",
         lwd=3)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day4_thursday/use-neon-aop-package/extract-stack-2.png)

## Extract Spectra


    # read in the wavelength information from the HDF5 file
    wavelengths <- h5read(f, "wavelength")
    head(wavelengths)

    ##         [,1]
    ## [1,] 0.38227
    ## [2,] 0.38728
    ## [3,] 0.39229
    ## [4,] 0.39730
    ## [5,] 0.40231
    ## [6,] 0.40732

    # NOTE: this currently doesn't work properly if the file is rotated
    h5.ext <- create_extent(f)
    
    # calculate the index subset dims to extract data from the H5 file
    subset.dims <- calculate_index_extent(clip.extent, 
                        h5.ext, 
                        xscale = 1, yscale = 1)
    
    
    # turn the H5 extent into a polygon to check overlap
    h5.ext.poly <- as(extent(h5.ext),
                    "SpatialPolygons")
    
    # assign crs to new polygon
    crs(h5.ext.poly) <- CRS("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
    
    # ensure the two extents overlap
    gIntersects(h5.ext.poly, 
                clip.extent)

    ## [1] TRUE

    # finally determine the subset to extract from the h5 file
    index.bounds <- calculate_index_extent(extent(clip.extent), 
                    h5.ext)
    
    # open a band
    a.raster <- open_band(f, 
                          56, 
                          epsg)
    
    # grab the average reflectance value for a band
    refl <- extract_av_refl(a.raster, 
                            aFun = mean)
    
    refl

    ## [1] 0.1037593


## Get Spectra from Many Bands


    # grab all bands
    bands <- c(1:426)
    
    # get stack
    all.bands.stack <- create_stack(f, 
                             bands, 
                             epsg)
    
    # get spectra for each band
    spectra <- extract_av_refl(all.bands.stack, 
                               aFun = mean)
    spectra <- as.data.frame(spectra)
    
    # read in the wavelength information from the HDF5 file
    wavelengths<- h5read(f, "wavelength")
    
    # convert wavelength to nanometers (nm)
    wavelengths <- wavelengths * 1000
    
    spectra$wavelength <- wavelengths[bands]
    
    # plot spectra
    qplot(x=spectra$wavelength,
          y=spectra$spectra,
          xlab="Wavelength (nm)",
          ylab="Reflectance",
          main="Spectra for all pixels",
          ylim = c(0, .35))

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day4_thursday/use-neon-aop-package/get-spectra-bands-1.png)


## Get Spectra From Masked Bands Only

In this instance, we are using a mask to extract only the pixels where NDVI > .6.
This represents vegetation.


    index.bounds <- calculate_index_extent(extent(clip.extent),
    								h5.ext)
    head(bands)

    ## [1] 1 2 3 4 5 6

    epsg

    ## [1] 32611

    # clip out raster
    rgbRast.clip <- create_stack(file=f,
                bands=bands,
                epsg=epsg,
                subset=TRUE,
                dims=index.bounds)
    
    # calculate NDVI
    redBand <- rgbRast.clip[[60]]
    nirBand <- rgbRast.clip[[83]]
    
    ndvi <- (nirBand - redBand) / (nirBand + redBand)
    plot(ndvi)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day4_thursday/use-neon-aop-package/spectra-masked-bands-1.png)

    # create mask
    ndvi[ndvi < .6] <- NA
    plot(ndvi)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day4_thursday/use-neon-aop-package/spectra-masked-bands-2.png)

    # mask stack
    rgbRast.clip.mask <- mask(rgbRast.clip, ndvi)
    
    # get spectra for each band
    spectra.mask <- extract_av_refl(rgbRast.clip.mask, 
                               aFun = mean)
    
    spectra.mask <- as.data.frame(spectra.mask)
    
    # read in the wavelength information from the HDF5 file
    wavelengths<- h5read(f, "wavelength")
    
    # convert wavelength to nanometers (nm)
    wavelengths <- wavelengths * 1000
    
    spectra.mask$wavelength <- wavelengths[bands]
    
    # plot spectra
    qplot(x=spectra.mask$wavelength,
          y=spectra.mask$spectra,
          xlab="Wavelength (nm)",
          ylab="Reflectance",
          main="Spectra for pixels NDVI> .6",
          ylim = c(0, .35))

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day4_thursday/use-neon-aop-package/spectra-masked-bands-3.png)

