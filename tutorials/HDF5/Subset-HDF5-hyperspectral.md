---
title: "Subsetting HDF5 files to make a smaller deliverable"
code1: null
contributors: null
dataProudct: null
dateCreated: 2020-02-04 14:20:52
description: Take a large HDF5 file and extract only the information that you need,
  then save as a new HDF5 file. For an example, we will take an existing hyperspectral
  dataset (~600Mb) and reduce it in size for subsequent tutorials.
estimatedTime: 1.0 Hours
languagesTool: R
packagesLibraries: rhdf5, raster
syncID: 884cc5915a3842c1ab6617b060797fab
authors: Donal O'Leary
topics: hyperspectral, HDF5, remote-sensing
tutorialSeries: null
urlTitle: null
---

In this tutorial, we will subset an existing HDF5 file containing NEON
hyperspectral data. The purpose of this exercise is to generate a smaller
file for use in subsequent tuorials.

<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this activity, you will be able to:

* Navigate an HDF5 file to identify the variables of interest.</li>
* Generate a new HDF5 file from a subset of the existing dataset.</li>
* Save the new HDF5 file for future use.

## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### R Libraries to Install:

* **rhdf5**: `install.packages("BiocManager")`, `BiocManager::install("rhdf5")`
* **raster**: `install.packages('raster')`

<a href="{{ site.baseurl }}/packages-in-r" target="_blank"> More on Packages in
 R - Adapted from Software Carpentry.</a>

### Data to Download
The purpose of this tutorial is to reduce a large file (~`652Mb`) to a smaller size. The download linked here is the original large file, and therefore you may choose to skip this tutorial and download if you are on a slow internet connection or have file size limitations on your device.

{% include/dataSubsets/_data_Imaging-Spec-Data-Full-Tile-H5-2020.html %}

This file is NEON_D17_SJER_DP3_257000_4112000_reflectance.h5 from March 2019, available on data.neonscience.org.

***
{% include/_greyBox-wd-rscript.html %}
***

### Recommended Skills

If you haven't already, we highly recommend you work through the 
<a href="{{ site.baseurl }}/intro-hdf5-r-series" target="_blank"> *Introduction to Working with HDF5 Format in R* series</a>
before moving on to this tutorial.

</div>


## Why subset your dataset? 
There are many reasons why you may wish to subset you HDF5 file.
Primarily, HDF5 files may contain a large amount of information
that is not necessary for your purposes. By subsetting the file,
you can reduce file size, thereby shrinking your storage needs,
and shortening file transfer/download times. In this example, we
will take a full HDF5 file of NEON hyperspectral reflectance data
from the San Joaquin Experimental Range (SJER) that has a file size
of ~`652 Mb` and make a new HDF5 file with a reduced spatial extent,
and a reduced spectral resolution, yeilding a file of only ~`50.1 Mb`.
This reduction in file size will make it easier and faster to share
your data with others. We will then use this subsetted file in the
<a href="{{ site.baseurl }}/intro-hsi-r-series" target="_blank"> *Introduction to Hyperspectral Remote Sensing Data* series</a>.

If you find that downloading the full `652 Mb` file takes too much
time or storage space, you will find a link to this subsetted file
at the top of each lesson in the <a href="{{ site.baseurl }}/intro-hsi-r-series" target="_blank"> *Introduction to Hyperspectral Remote Sensing Data* series</a>.

## Reading in the HDF5 file

First, we will load the required library for this tutorial:


    # Install rhdf5 package (only need to run if not already installed)
    # install.packages("BiocManager")
    # BiocManager::install("rhdf5")
    
    # Load required packages
    library(rhdf5)

Next, we define our working directory where we have saved the full HDF5 
file of NEON hyperspectral reflectance data from the SJER site. Note,
the filepath to the working directory will depend on your local environment.
Then, we create a string (`f`) of the HDF5 filename and read its attributes.


    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files. Be sure to move the download into your working directory!
    wd="~/Desktop/Hyperspectral_Tutorial/" #This will depend on your local environment
    setwd(wd)
    
    # Read in H5 file
    f <- paste0(wd,"NEON_D17_SJER_DP3_257000_4112000_reflectance.h5")

## Create new HDF5 file framework

Now, we create a new empty HDF5 file, and then populate this file with the
groups that we need to save our essential information for this subset.
Note that the function `h5createFile()` will not overwrite an existing
file. Therefore, if you have already created or downloaded this file, the
function will throw an error!


    # First, create a name for the new file
    nf <- paste0(wd, "NEON_hyperspectral_tutorial_example_subset.h5")
    
    
    # create hdf5 file
    
    h5createFile(nf)

    ## [1] TRUE

    h5createGroup(nf, "SJER/")

    ## [1] TRUE

    h5createGroup(nf, "SJER/Reflectance")

    ## [1] TRUE

    h5createGroup(nf, "SJER/Reflectance/Metadata")

    ## [1] TRUE

    h5createGroup(nf, "SJER/Reflectance/Metadata/Coordinate_System")

    ## [1] TRUE

    h5createGroup(nf, "SJER/Reflectance/Metadata/Spectral_Data")

    ## [1] TRUE

## Adding group attributes
One of the great things about HDF5 files is that they can contain _data_ and _attributes_ within the same group. 
As explained within the <a href="{{ site.baseurl }}/intro-hdf5-r-series" target="_blank"> Introduction to Working with HDF5 Format in R series</a>, attributes are a type of metadata that are associated with an HDF5 group or dataset. There may be multiple attributes associated with each group and/or dataset. Attributes come with a name and an associated array of information. In this tutorial, we will read the existing attribute data from the full hyperspectral tile using the `h5readAttributes()` function (which returns a `list` of attributes), then we loop through those attributes and write each attribute to its appropriate group using the `h5writeAttribute()` function.

First, we will do this for the low-level "SJER/Reflectance" group. 


    a=h5readAttributes(f,"/SJER/Reflectance/")
    fid <- H5Fopen(nf)
    g=H5Gopen(fid, "SJER/Reflectance")
    
    for(i in 1:length(names(a))){
    h5writeAttribute(attr = a[[i]], h5obj=g, name=names(a[i]))
    }
    h5closeAll()

Next, we will loop through each of the datasets within the Coordinate_System group, and copy those (and their attributes, if present) from the full tile to our subset file. The Coordinate_System group contains many important pieces of information for geolocating our data, so we need to make sure that the sunset file has those data.


    # make a list of all groups within the full tile file
    ls=h5ls(f,all=T)
    
    #make a list of all of the names within the Coordinate_System group
    cg=unique(ls[ls$group=="/SJER/Reflectance/Metadata/Coordinate_System",]$name)
    
    for(i in 1:length(cg)){
      print(cg[i])
      a=h5readAttributes(f,paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]))
      d=h5read(f,paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]))
      attributes(d)=a
      h5write(obj=d,file=nf,
              name=paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]),
              write.attributes=T)
    }

    ## [1] "Coordinate_System_String"
    ## [1] "EPSG Code"
    ## [1] "Map_Info"
    ## [1] "Proj4"

## Spectral Subsetting

The goal of subsetting this dataset is to substantially reduce the file size to make it faster to download and process these data. While each AOP mosaic tile is not particularly large in terms of its spatial scale (1km by 1km at 1m resolution= 1,000,000 pixels, or about half as many pixels at shown on a standard 1080p computer screen), the 426 spectral bands available result in a fairly large file size. While having hundreds of bands is important for advanced research, we can use far fewer bands for demonstartion and teaching purposes, while still getting a good sense of what these hyperspectral data can do. Therefore, we will reduce the spectral resolution of these data by selecting every fourth band in the dataset, which reduces the file size to 1/4 of the original!


    #First, we make out 'index'  a list of number that will allow us to select every fourth band
    idx <- seq(from = 1, to = 426, by = 4)
    
    # We then use this index to select particular wavelengths from the full tile using the "index=" argument
    ws <- h5read(file = f, 
                 name = "SJER/Reflectance/Metadata/Spectral_Data/Wavelength", 
                 index = list(idx)
                )
    
    # As per above, we also need the wavelength attributes
    wa <- h5readAttributes(file = f, 
                           name = "SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
    attributes(ws) <- wa
    
    # Finally, write the subset of wavelengths and their attributes to the subset file
    h5write(obj=ws, file=nf,
            name="SJER/Reflectance/Metadata/Spectral_Data/Wavelength",
            write.attributes=T)

## Spatial Subsetting

Even after spectral subsetting, our file size would be greater than 100Mb. Therefore, we will perform a spatial subsetting process as well when we read the hyperspectral imagery data. Note that the `index=` argument in `h5read` requires a `list()` object of three dimenstions for this example - in the order of band, column, row. Here, we are taking every fourth band (using our `idx` variabe), columns 501:1000 (the eastern half of the tile) and rows 1:500 (the northern half of the tile). The results in us extracting every fourth band of the northeast quadrant of the mosaic tile.



    # Read in reflectance data - note the index argument! This is ultimately how we reduce the file size.
    hs <- h5read(file = f, 
                 name = "SJER/Reflectance/Reflectance_Data", 
                 index = list(idx, 501:1000, 1:500)
                )
    # grab the '$dim' attribute - as this will be needed when writing the file at the bottom
    hsd=attributes(hs)
    
    # We also need the attributes for the reflectance data, of course.
    ha <- h5readAttributes(file = f, 
                           name = "SJER/Reflectance/Reflectance_Data")
    
    # However, some of the attributes are not longer valid since we changed the spatial extend of this dataset.
    # therefore, we will need to overwrite those with the correct values.
    ha$Dimensions=c(500,500,107)
    ha$Spatial_Extent_meters[1]=ha$Spatial_Extent_meters[1]+500
    ha$Spatial_Extent_meters[3]=ha$Spatial_Extent_meters[3]+500
    attributes(hs)=c(hsd,ha)
    
    attributes(hs)

    ## $dim
    ## [1] 107 500 500
    ## 
    ## $Cloud_conditions
    ## [1] "For cloud conditions information see Weather Quality Index dataset."
    ## 
    ## $Cloud_type
    ## [1] "Cloud type may have been selected from multiple flight trajectories."
    ## 
    ## $Data_Ignore_Value
    ## [1] -9999
    ## 
    ## $Description
    ## [1] "Atmospherically corrected reflectance."
    ## 
    ## $Dimension_Labels
    ## [1] "Line, Sample, Wavelength"
    ## 
    ## $Dimensions
    ## [1] 500 500 107
    ## 
    ## $Interleave
    ## [1] "BSQ"
    ## 
    ## $Scale_Factor
    ## [1] 10000
    ## 
    ## $Spatial_Extent_meters
    ## [1]  257500  258000 4112500 4113000
    ## 
    ## $Spatial_Resolution_X_Y
    ## [1] 1 1
    ## 
    ## $Units
    ## [1] "Unitless."
    ## 
    ## $Units_Valid_range
    ## [1]     0 10000

    h5write(obj=hs, file=nf,
            name="SJER/Reflectance/Reflectance_Data",
            write.attributes=T)

    ## You created a large dataset with compression and chunking.
    ## The chunk size is equal to the dataset dimensions.
    ## If you want to read subsets of the dataset, you should testsmaller chunk sizes to improve read times.

    h5closeAll()

That's it! We just created a subset of the original HDF5 file, and included the most essential groups and metadata for exploratory analysis. You may consider adding other information, such as the weather quality indicator, when subsetting datasets for your own purposes.
If you want to take a look at the subset that you just made, run the `h5ls()` function:

    View(h5ls(nf, all=T))
