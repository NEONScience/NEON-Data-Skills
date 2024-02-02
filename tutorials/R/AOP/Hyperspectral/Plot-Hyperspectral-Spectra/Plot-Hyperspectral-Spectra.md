---
syncID: 79f902f6c0264f16a9be13f50560860a
title: "Plot Spectral Signatures Derived from Hyperspectral Remote Sensing Data in HDF5 Format in R"
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/AOP/Hyperspectral/Plot-Hyperspectral-Spectra/Plot-Hyperspectral-Spectra.R
contributors: Felipe Sanchez, Bridget Hass
dateCreated: 2015-08-08 20:49:52
description: Extract a single pixel's worth of spectra from a hyperspectral dataset stored in HDF5 format in R. Visualize the spectral signature.
estimatedTime: 1.0 - 1.5 Hours
languagesTool: R
dataProduct: DP3.30006.001
packagesLibraries: rhdf5, plyr, ggplot2, neonUtilties
authors: Leah A. Wasser, Donal O'Leary
topics: hyperspectral, HDF5, remote-sensing
tutorialSeries: null
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
* **neonUtilities**: `install.packages('neonUtilities')`

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in
 R - Adapted from Software Carpentry.</a>


### Data

These hyperspectral remote sensing data provide information on the <a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> <a href="https://www.neonscience.org/field-sites/SJER" target="_blank" >San Joaquin Experimental Range (SJER)</a> field site in March of 2021. The data used in this lesson is the 1km by 1km mosaic tile named NEON_D17_SJER_DP3_257000_4112000_reflectance.h5. If you already completed the previous lesson in this tutorial series, you do not need to download this data again. The entire SJER reflectance dataset can be accessed from the <a href="http://data.neonscience.org" target="_blank">NEON Data Portal</a>.


**Set Working Directory:** This lesson assumes that you have set your working directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview of setting the working directory in R can be found here.</a>


### Recommended Skills

For this tutorial, you should be comfortable reading data from a HDF5 file and have a general familiarity with hyperspectral data. If you aren't familiar with these steps already, we highly recommend you work through the <a href="https://www.neonscience.org/hsi-hdf5-r" target="_blank"> 
*Introduction to Working with Hyperspectral Data in HDF5 Format in R* tutorial</a> before moving on to this tutorial.

</div> 

Everything on our planet reflects electromagnetic radiation from the Sun, and different types of land cover often have dramatically different reflectance properties across the spectrum. One of the most powerful aspects of the NEON Imaging Spectrometer (NIS, or hyperspectral sensor) is that it can accurately measure these reflectance properties at a very high spectral resolution. When you plot the reflectance values across the observed spectrum, you will see 
that different land cover types (vegetation, pavement, bare soils, etc.) have distinct patterns in their reflectance values, a property that we call the 
'spectral signature' of a particular land cover class. 

In this tutorial, we will extract the reflectance values for all bands of a single pixel to plot a spectral signature for that pixel. In order to do this,
we need to pair the reflectance values for that pixel with the wavelength values of the bands that are represented in those measurements. We will also need to adjust the reflectance values by the scaling factor that is saved as an 'attribute' in the HDF5 file. First, let's start by defining the working 
directory and reading in the example dataset.


    # Call required packages

    library(rhdf5)

    library(plyr)

    library(ggplot2)

    ## Learn more about the underlying theory at https://ggplot2-book.org/

    library(neonUtilities)

    

    wd <- "~/data/" #This will depend on your local environment

    setwd(wd)
If you haven't already downloaded the hyperspectral data tile (in one of the previous tutorials in this series), you can use the `neonUtilities` function `byTileAOP` to download a single reflectance tile. You can run `help(byTileAOP)` to see more details on what the various inputs are. For this exercise, we'll specify the UTM Easting and Northing to be (257500, 4112500), which will download the tile with the lower left corner (257000, 4112000).


    byTileAOP(dpID = 'DP3.30006.001',

              site = 'SJER',

              year = '2021',

              easting = 257500,

              northing = 4112500,

              savepath = wd)

This file will be downloaded into a nested subdirectory under the `~/data` folder (your working directory), inside a folder named `DP3.30006.001` (the Data Product ID). The file should show up in this location: `~/data/DP3.30006.001/neon-aop-products/2021/FullSite/D17/2021_SJER_5/L3/Spectrometer/Reflectance/NEON_D17_SJER_DP3_257000_4112000_reflectance.h5`.

Now we can read in the file and look at the contents using `h5ls`. You can move this file to a different location, but make sure to change the path accordingly.


    # define the h5 file name (specify the full path)

    h5_file <- paste0(wd,"DP3.30006.001/neon-aop-products/2021/FullSite/D17/2021_SJER_5/L3/Spectrometer/Reflectance/NEON_D17_SJER_DP3_257000_4112000_reflectance.h5")

    

    # look at the HDF5 file structure 

    h5ls(h5_file,all=T) 

    ##                                           group                                 name         ltype cset       otype num_attrs  dclass          dtype  stype
    ## 0                                             /                                 SJER H5L_TYPE_HARD    0   H5I_GROUP         3                              
    ## 1                                         /SJER                          Reflectance H5L_TYPE_HARD    0   H5I_GROUP         5                              
    ## 2                             /SJER/Reflectance                             Metadata H5L_TYPE_HARD    0   H5I_GROUP         0                              
    ## 3                    /SJER/Reflectance/Metadata                    Ancillary_Imagery H5L_TYPE_HARD    0   H5I_GROUP         0                              
    ## 4  /SJER/Reflectance/Metadata/Ancillary_Imagery                Aerosol_Optical_Depth H5L_TYPE_HARD    0 H5I_DATASET         5 INTEGER  H5T_STD_I16LE SIMPLE
    ## 5  /SJER/Reflectance/Metadata/Ancillary_Imagery                               Aspect H5L_TYPE_HARD    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE
    ## 6  /SJER/Reflectance/Metadata/Ancillary_Imagery                          Cast_Shadow H5L_TYPE_HARD    0 H5I_DATASET         5 INTEGER   H5T_STD_U8LE SIMPLE
    ## 7  /SJER/Reflectance/Metadata/Ancillary_Imagery Dark_Dense_Vegetation_Classification H5L_TYPE_HARD    0 H5I_DATASET         9 INTEGER   H5T_STD_U8LE SIMPLE
    ## 8  /SJER/Reflectance/Metadata/Ancillary_Imagery                 Data_Selection_Index H5L_TYPE_HARD    0 H5I_DATASET         2 INTEGER  H5T_STD_I32LE SIMPLE
    ## 9  /SJER/Reflectance/Metadata/Ancillary_Imagery                 Haze_Cloud_Water_Map H5L_TYPE_HARD    0 H5I_DATASET         9 INTEGER   H5T_STD_U8LE SIMPLE
    ## 10 /SJER/Reflectance/Metadata/Ancillary_Imagery                  Illumination_Factor H5L_TYPE_HARD    0 H5I_DATASET         5 INTEGER   H5T_STD_U8LE SIMPLE
    ## 11 /SJER/Reflectance/Metadata/Ancillary_Imagery                          Path_Length H5L_TYPE_HARD    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE
    ## 12 /SJER/Reflectance/Metadata/Ancillary_Imagery                      Sky_View_Factor H5L_TYPE_HARD    0 H5I_DATASET         5 INTEGER   H5T_STD_U8LE SIMPLE
    ## 13 /SJER/Reflectance/Metadata/Ancillary_Imagery                                Slope H5L_TYPE_HARD    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE
    ## 14 /SJER/Reflectance/Metadata/Ancillary_Imagery             Smooth_Surface_Elevation H5L_TYPE_HARD    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE
    ## 15 /SJER/Reflectance/Metadata/Ancillary_Imagery                 Visibility_Index_Map H5L_TYPE_HARD    0 H5I_DATASET         5 INTEGER   H5T_STD_U8LE SIMPLE
    ## 16 /SJER/Reflectance/Metadata/Ancillary_Imagery                   Water_Vapor_Column H5L_TYPE_HARD    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE
    ## 17 /SJER/Reflectance/Metadata/Ancillary_Imagery            Weather_Quality_Indicator H5L_TYPE_HARD    0 H5I_DATASET         1 INTEGER   H5T_STD_U8LE SIMPLE
    ## 18                   /SJER/Reflectance/Metadata                    Coordinate_System H5L_TYPE_HARD    0   H5I_GROUP         0                              
    ## 19 /SJER/Reflectance/Metadata/Coordinate_System             Coordinate_System_String H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 20 /SJER/Reflectance/Metadata/Coordinate_System                            EPSG Code H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 21 /SJER/Reflectance/Metadata/Coordinate_System                             Map_Info H5L_TYPE_HARD    0 H5I_DATASET         1  STRING     H5T_STRING SCALAR
    ## 22 /SJER/Reflectance/Metadata/Coordinate_System                                Proj4 H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 23                   /SJER/Reflectance/Metadata                    Flight_Trajectory H5L_TYPE_HARD    0   H5I_GROUP         1                              
    ## 24                   /SJER/Reflectance/Metadata                                 Logs H5L_TYPE_HARD    0   H5I_GROUP         0                              
    ## 25              /SJER/Reflectance/Metadata/Logs                               195724 H5L_TYPE_HARD    0   H5I_GROUP         0                              
    ## 26       /SJER/Reflectance/Metadata/Logs/195724                     ATCOR_Input_file H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 27       /SJER/Reflectance/Metadata/Logs/195724                 ATCOR_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 28       /SJER/Reflectance/Metadata/Logs/195724                Shadow_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 29       /SJER/Reflectance/Metadata/Logs/195724               Skyview_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 30       /SJER/Reflectance/Metadata/Logs/195724                  Solar_Azimuth_Angle H5L_TYPE_HARD    0 H5I_DATASET         0   FLOAT H5T_IEEE_F32LE SCALAR
    ## 31       /SJER/Reflectance/Metadata/Logs/195724                   Solar_Zenith_Angle H5L_TYPE_HARD    0 H5I_DATASET         0   FLOAT H5T_IEEE_F32LE SCALAR
    ## 32              /SJER/Reflectance/Metadata/Logs                               200251 H5L_TYPE_HARD    0   H5I_GROUP         0                              
    ## 33       /SJER/Reflectance/Metadata/Logs/200251                     ATCOR_Input_file H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 34       /SJER/Reflectance/Metadata/Logs/200251                 ATCOR_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 35       /SJER/Reflectance/Metadata/Logs/200251                Shadow_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 36       /SJER/Reflectance/Metadata/Logs/200251               Skyview_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 37       /SJER/Reflectance/Metadata/Logs/200251                  Solar_Azimuth_Angle H5L_TYPE_HARD    0 H5I_DATASET         0   FLOAT H5T_IEEE_F32LE SCALAR
    ## 38       /SJER/Reflectance/Metadata/Logs/200251                   Solar_Zenith_Angle H5L_TYPE_HARD    0 H5I_DATASET         0   FLOAT H5T_IEEE_F32LE SCALAR
    ## 39              /SJER/Reflectance/Metadata/Logs                               200812 H5L_TYPE_HARD    0   H5I_GROUP         0                              
    ## 40       /SJER/Reflectance/Metadata/Logs/200812                     ATCOR_Input_file H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 41       /SJER/Reflectance/Metadata/Logs/200812                 ATCOR_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 42       /SJER/Reflectance/Metadata/Logs/200812                Shadow_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 43       /SJER/Reflectance/Metadata/Logs/200812               Skyview_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 44       /SJER/Reflectance/Metadata/Logs/200812                  Solar_Azimuth_Angle H5L_TYPE_HARD    0 H5I_DATASET         0   FLOAT H5T_IEEE_F32LE SCALAR
    ## 45       /SJER/Reflectance/Metadata/Logs/200812                   Solar_Zenith_Angle H5L_TYPE_HARD    0 H5I_DATASET         0   FLOAT H5T_IEEE_F32LE SCALAR
    ## 46              /SJER/Reflectance/Metadata/Logs                               201441 H5L_TYPE_HARD    0   H5I_GROUP         0                              
    ## 47       /SJER/Reflectance/Metadata/Logs/201441                     ATCOR_Input_file H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 48       /SJER/Reflectance/Metadata/Logs/201441                 ATCOR_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 49       /SJER/Reflectance/Metadata/Logs/201441                Shadow_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 50       /SJER/Reflectance/Metadata/Logs/201441               Skyview_Processing_Log H5L_TYPE_HARD    0 H5I_DATASET         0  STRING     H5T_STRING SCALAR
    ## 51       /SJER/Reflectance/Metadata/Logs/201441                  Solar_Azimuth_Angle H5L_TYPE_HARD    0 H5I_DATASET         0   FLOAT H5T_IEEE_F32LE SCALAR
    ## 52       /SJER/Reflectance/Metadata/Logs/201441                   Solar_Zenith_Angle H5L_TYPE_HARD    0 H5I_DATASET         0   FLOAT H5T_IEEE_F32LE SCALAR
    ## 53                   /SJER/Reflectance/Metadata                        Spectral_Data H5L_TYPE_HARD    0   H5I_GROUP         0                              
    ## 54     /SJER/Reflectance/Metadata/Spectral_Data                                 FWHM H5L_TYPE_HARD    0 H5I_DATASET         2   FLOAT H5T_IEEE_F32LE SIMPLE
    ## 55     /SJER/Reflectance/Metadata/Spectral_Data                           Wavelength H5L_TYPE_HARD    0 H5I_DATASET         2   FLOAT H5T_IEEE_F32LE SIMPLE
    ## 56                   /SJER/Reflectance/Metadata              to-sensor_azimuth_angle H5L_TYPE_HARD    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE
    ## 57                   /SJER/Reflectance/Metadata               to-sensor_zenith_angle H5L_TYPE_HARD    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE
    ## 58                            /SJER/Reflectance                     Reflectance_Data H5L_TYPE_HARD    0 H5I_DATASET        12 INTEGER  H5T_STD_I16LE SIMPLE
    ##    rank               dim            maxdim
    ## 0     0                                    
    ## 1     0                                    
    ## 2     0                                    
    ## 3     0                                    
    ## 4     2       1000 x 1000       1000 x 1000
    ## 5     2       1000 x 1000       1000 x 1000
    ## 6     2       1000 x 1000       1000 x 1000
    ## 7     2       1000 x 1000       1000 x 1000
    ## 8     2       1000 x 1000       1000 x 1000
    ## 9     2       1000 x 1000       1000 x 1000
    ## 10    2       1000 x 1000       1000 x 1000
    ## 11    2       1000 x 1000       1000 x 1000
    ## 12    2       1000 x 1000       1000 x 1000
    ## 13    2       1000 x 1000       1000 x 1000
    ## 14    2       1000 x 1000       1000 x 1000
    ## 15    2       1000 x 1000       1000 x 1000
    ## 16    2       1000 x 1000       1000 x 1000
    ## 17    3   3 x 1000 x 1000   3 x 1000 x 1000
    ## 18    0                                    
    ## 19    0             ( 0 )             ( 0 )
    ## 20    0             ( 0 )             ( 0 )
    ## 21    0             ( 0 )             ( 0 )
    ## 22    0             ( 0 )             ( 0 )
    ## 23    0                                    
    ## 24    0                                    
    ## 25    0                                    
    ## 26    0             ( 0 )             ( 0 )
    ## 27    0             ( 0 )             ( 0 )
    ## 28    0             ( 0 )             ( 0 )
    ## 29    0             ( 0 )             ( 0 )
    ## 30    0             ( 0 )             ( 0 )
    ## 31    0             ( 0 )             ( 0 )
    ## 32    0                                    
    ## 33    0             ( 0 )             ( 0 )
    ## 34    0             ( 0 )             ( 0 )
    ## 35    0             ( 0 )             ( 0 )
    ## 36    0             ( 0 )             ( 0 )
    ## 37    0             ( 0 )             ( 0 )
    ## 38    0             ( 0 )             ( 0 )
    ## 39    0                                    
    ## 40    0             ( 0 )             ( 0 )
    ## 41    0             ( 0 )             ( 0 )
    ## 42    0             ( 0 )             ( 0 )
    ## 43    0             ( 0 )             ( 0 )
    ## 44    0             ( 0 )             ( 0 )
    ## 45    0             ( 0 )             ( 0 )
    ## 46    0                                    
    ## 47    0             ( 0 )             ( 0 )
    ## 48    0             ( 0 )             ( 0 )
    ## 49    0             ( 0 )             ( 0 )
    ## 50    0             ( 0 )             ( 0 )
    ## 51    0             ( 0 )             ( 0 )
    ## 52    0             ( 0 )             ( 0 )
    ## 53    0                                    
    ## 54    1               426               426
    ## 55    1               426               426
    ## 56    2       1000 x 1000       1000 x 1000
    ## 57    2       1000 x 1000       1000 x 1000
    ## 58    3 426 x 1000 x 1000 426 x 1000 x 1000


## Read Wavelength Values

Next, let's read in the wavelength center associated with each band in the HDF5 file. We will later match these with the reflectance values and show both in our final spectral signature plot.


    # read in the wavelength information from the HDF5 file

    wavelengths <- h5read(h5_file,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")


## Extract Z-dimension data slice

Next, we will extract all reflectance values for one pixel. This makes up the spectral signature or profile of the pixel. To do that, we'll use the `h5read()` function. Here we pick an arbitrary pixel at `(100,35)`, and use the `NULL` value to select *all* bands from that location.


    # extract all bands from a single pixel

    aPixel <- h5read(h5_file,"/SJER/Reflectance/Reflectance_Data",index=list(NULL,100,35))

    

    # The line above generates a vector of reflectance values.

    # Next, we reshape the data and turn them into a dataframe

    b <- adply(aPixel,c(1))

    

    # create clean data frame

    aPixeldf <- b[2]

    

    # add wavelength data to matrix

    aPixeldf$Wavelength <- wavelengths

    

    head(aPixeldf)

    ##    V1 Wavelength
    ## 1 206   381.6035
    ## 2 266   386.6132
    ## 3 274   391.6229
    ## 4 297   396.6327
    ## 5 236   401.6424
    ## 6 236   406.6522

## Scale Factor

Then, we can pull the spatial attributes that we'll need to adjust the reflectance values. Often, large raster data contain floating point (values with decimals) information. However, floating point data consume more space (yield a larger file size) compared to integer values. Thus, to keep the file sizes smaller, the data will be scaled by a factor of 10, 100, 10000, etc. This `scale factor` will be noted in the data attributes.


    # grab scale factor from the Reflectance attributes

    reflectanceAttr <- h5readAttributes(f,"/SJER/Reflectance/Reflectance_Data" )

    ## Error in H5Fopen(file, flags = flags, fapl = fapl, native = native): HDF5. File accessibility. Unable to open file.

    scaleFact <- reflectanceAttr$Scale_Factor

    ## Error in eval(expr, envir, enclos): object 'reflectanceAttr' not found

    # add scaled data column to DF

    aPixeldf$scaled <- (aPixeldf$V1/as.vector(scaleFact))

    ## Error in eval(expr, envir, enclos): object 'scaleFact' not found

    # make nice column names

    names(aPixeldf) <- c('Reflectance','Wavelength','ScaledReflectance')

    ## Error in names(aPixeldf) <- c("Reflectance", "Wavelength", "ScaledReflectance"): 'names' attribute [3] must be the same length as the vector [2]

    head(aPixeldf)

    ##    V1 Wavelength
    ## 1 206   381.6035
    ## 2 266   386.6132
    ## 3 274   391.6229
    ## 4 297   396.6327
    ## 5 236   401.6424
    ## 6 236   406.6522

## Plot Spectral Signature

Now we're ready to plot our spectral signature!


    ggplot(data=aPixeldf)+
       geom_line(aes(x=Wavelength, y=ScaledReflectance))+
       xlab("Wavelength (nm)")+
       ylab("Reflectance")

    ## Error in `geom_line()`:
    ## ! Problem while computing aesthetics.
    ## ℹ Error occurred in the 1st layer.
    ## Caused by error:
    ## ! object 'ScaledReflectance' not found

