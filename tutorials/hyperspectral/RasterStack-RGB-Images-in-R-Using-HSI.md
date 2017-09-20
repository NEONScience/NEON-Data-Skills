---
syncID: d42286b3af6148f3a8fd0863f00752a7
title: "Creating a Raster Stack from Hyperspectral Imagery in HDF5 Format in R"
description: "Open up and explore hyperspectral imagery in HDF format R. Combine multiple bands to create a raster stack. Use these steps to create various band combinations such as RGB, Color-Infrared and False color images."
dateCreated: 2014-11-26 20:49:52
authors: Edmund Hart, Leah A. Wasser
contributors:
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: rhdf5, raster, maps
topics: hyperspectral, HDF5, remote-sensing
languagesTool: R
dataProudct:
code1: hyperspectral/RasterStack-RGB-Images-in-R-Using-HSI.R
tutorialSeries:
---


In this tutorial, we will learn how to create multi (3) band images from hyperspectral 
data. We will also learn how to perform some basic raster calculations 
(known as raster math in the GIS world).

<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this activity, you will be able to:

* Extract a "slice" of data from a hyperspectral data cube.
* Create a rasterstack in R which can then be used to create RGB images from 
bands in a hyperspectral data cube.</li>
* Plot data spatially on a map.</li>
* Create basic vegetation indices like NDVI using raster  based calculations in 
R.

## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### R Libraries to Install:

* **rhdf5**: `source("http://bioconductor.org/biocLite.R")`, `biocLite("rhdf5")`
* **raster**: `install.packages('raster')`
* **rgdal**: `install.packages('rgdal')`
* **maps**: `install.packages('maps')`

[ { { site.baseurl }} R/Packages-In-R/](More on Packages in R - Adapted from Software Carpentry.)

### Data to Download

{% include/dataSubsets/_data_Met-Time-Series.html %}

***
{% include/_greyBox-wd-rscript.html %}
***

### Recommended Skills

We highly recommend you work through the 
<a href="{{ site.baseurl }}/HDF5/Imaging-Spectroscopy-HDF5-In-R/" target="_blank"> *Introduction to Working with Hyperspectral Data in HDF5 Format in R* tutorial</a>
before moving on to this tutorial.

</div>


## About Hyperspectral Data 
We often want to generate a 3 band image from multi or hyperspectral data. The 
most commonly recognized band combination is RGB which stands for Red, Green and 
Blue. RGB images are just like the images that your camera takes. But there are 
other band combinations that are useful too. For example, near infrared images 
emphasize vegetation and help us classify or identify where vegetation is located 
on the ground.

<figure class="third">
    <a href="{{ site.baseurl }}/images/hyperspectral/RGBImage_2.png"><img src="{{ site.baseurl }}/images/hyperspectral/RGBImage_2.png"></a>
    <a href="{{ site.baseurl }}/images/hyperspectral/NIR_G_B.png"><img src="{{ site.baseurl }}/images/hyperspectral/NIR_G_B.png"></a>
    <a href="{{ site.baseurl }}/images/hyperspectral/falseColor.png"><img src="{{ site.baseurl }}/images/hyperspectral/falseColor.png"></a>
    
    <figcaption>SJER image using 3 different band combinations. Left: typical red, green and blue (bands 58,34,19), middle: color infrared: near infrared, green and blue (bands 90, 34, 19).</figcaption>
</figure>

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip - Band Combinations:** The Biodiversity 
Informatics group created a great interactive tool that lets you explore band 
combinations. Check it out:
<a href="http://biodiversityinformatics.amnh.org/interactives/bandcombination.php" target="_blank">Learn more about band combinations using a great online tool!</a>
</div>


## Create a Raster Stack in R

In the [previous activity]({{ site.baseurl }}/HDF5/Imaging-Spectroscopy-HDF5-In-R/), 
we exported a subset of the NEON Reflectance data from a HDF5 file. In this 
activity, we will create a full color image using 3 (red, green and blue - RGB) 
bands. We will follow many of the steps we followed in the 
[intro to working with hyperspectral data activity]({{ site.baseurl }}/HDF5/Imaging-Spectroscopy-HDF5-In-R/). 
These steps included loading required packages, reading in our file and viewing 
the file structure.


    # Load required packages
    library(raster)
    library(rhdf5)
    library(rgdal)
    library(maps)
    
    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files
    #setwd("working-dir-path-here")


    # Read in H5 file
    f <- 'NEON-DS-Imaging-Spectrometer-Data.h5'
    #View HDF5 file structure 
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

To spatially locate our raster data, we need a few key attributes:

* The coordinate reference system
* The lower left hand corner X, Y location of the raster
* The dimensions (number of pixels in the x and y directions) of the raster to 
   use to calculate the **extent**.
   
We'll begin by grabbing these key attributes from the H5 file.   


    # R get spatial info and map info using the h5readAttributes function
    spInfo <- h5readAttributes(f,"spatialInfo")
    # define coordinate reference system
    myCrs <- spInfo$projdef
    # define the resolution
    res <- spInfo$xscale
    
    #Populate the raster image extent value. 
    mapInfo<-h5read(f,"map info")
    # the map info string contains the lower left hand coordinates of our raster
    # let's grab those next
    # split out the individual components of the mapinfo string
    mapInfo<-unlist(strsplit(mapInfo, ","))
    
    # grab the utm coordinates of the lower left corner
    xMin<-as.numeric(mapInfo[4])
    yMax<-as.numeric(mapInfo[5]) 
    
    # R get attributes for the Reflectance dataset
    reflInfo <- h5readAttributes(f,"Reflectance")
    
    #create objects represents the dimensions of the Reflectance dataset
    #note that there are several ways to access the size of the raster contained
    #within the H5 file
    nRows <- reflInfo$row_col_band[1]
    nCols <- reflInfo$row_col_band[2]
    nBands <- reflInfo$row_col_band[3]
    
    #grab the no data value
    myNoDataValue <- reflInfo$`data ignore value`
    myNoDataValue

    ## [1] "15000"

Next, we'll write a function that will perform the processing that we did step by 
step in the [intro to working with hyperspectral data activity](http://neondataskills.org/HDF5/Imaging-Spectroscopy-HDF5-In-R/). This will allow us to process multiple bands 
in bulk.

The function `band2Rast` slices a band of data from the HDF5 file, and
extracts the reflectance. It them converts the data to a matrix, converts it to
a raster and returns a spatially corrected raster for the specified band. 

The function requires the following variables:

* file: the file
* band: the band number we wish to extract
* noDataValue: the noDataValue for the raster
* xMin, yMin: the X,Y coordinate left hand corner locations for the raster.
* res: the resolution of the raster
* crs: the Coordinate Reference System for the raster

The function output is a spatially referenced, `r` raster object.


    # file: the hdf file
    # band: the band you want to process
    # returns: a matrix containing the reflectance data for the specific band
    
    band2Raster <- function(file, band, noDataValue, xMin, yMin, res, crs){
        #first read in the raster
        out<- h5read(f,"Reflectance",index=list(1:nCols,1:nRows,band))
    	  #Convert from array to matrix
    	  out <- (out[,,1])
    	  #transpose data to fix flipped row and column order 
        #depending upon how your data are formated you might not have to perform this
        #step.
    	  out <-t(out)
        #assign data ignore values to NA
        #note, you might chose to assign values of 15000 to NA
        out[out == myNoDataValue] <- NA
    	  
        #turn the out object into a raster
        outr <- raster(out,crs=myCrs)
     
        # define the extents for the raster
        #note that you need to multiple the size of the raster by the resolution 
        #(the size of each pixel) in order for this to work properly
        xMax <- xMin + (outr@ncols * res)
        yMin <- yMax - (outr@nrows * res)
     
        #create extents class
        rasExt  <- extent(xMin,xMax,yMin,yMax)
       
        #assign the extents to the raster
        extent(outr) <- rasExt
       
        #return the raster object
        return(outr)
    }


Now that the function is created, we can create our list of rasters. The list 
specifies which bands (or dimensions in our hyperspectral dataset) we want to 
include in our raster stack. Let's start with a typical RGB (red, green, blue) 
combination. We will use bands 58, 34, and 19. 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip - wavelengths and bands:** Remember that 
you can look at the wavelengths dataset to determine the center wavelength value 
for each band. 
</div>



    #create a list of the bands we want in our stack
    rgb <- list(58,34,19)
    #lapply tells R to apply the function to each element in the list
    rgb_rast <- lapply(rgb,band2Raster, file = f, 
                       noDataValue=myNoDataValue, 
                       xMin=xMin, yMin=yMin, res=1,
                       crs=myCrs)
    
    #check out the properties or rgb_rast
    #note that it displays properties of 3 rasters.
    
    rgb_rast

    ## [[1]]
    ## class       : RasterLayer 
    ## dimensions  : 502, 477, 239454  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 256521, 256998, 4112069, 4112571  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11N +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 123, 15453  (min, max)
    ## 
    ## 
    ## [[2]]
    ## class       : RasterLayer 
    ## dimensions  : 502, 477, 239454  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 256521, 256998, 4112069, 4112571  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11N +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 116, 15677  (min, max)
    ## 
    ## 
    ## [[3]]
    ## class       : RasterLayer 
    ## dimensions  : 502, 477, 239454  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 256521, 256998, 4112069, 4112571  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11N +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 84, 13805  (min, max)

    #finally, create a raster stack from our list of rasters
    hsiStack <- stack(rgb_rast)

<a href="http://www.r-bloggers.com/using-apply-sapply-lapply-in-r/" target="_blank">More about Lapply here</a>. 

NOTE: We are using the 
<a href="http://www.inside-r.org/packages/cran/raster/docs/stack" target="_blank"> raster stack </a> 
object in R to store several rasters that are of the same CRS and extent.

Next, add the names of the bands to the raster so we can easily keep track of 
the bands in the list.


    #Add the band numbers as names to each raster in the raster list
    
    #Create a list of band names
    bandNames <- paste("Band_",unlist(rgb),sep="")
    
    names(hsiStack) <- bandNames
    #check properties of the raster list - note the band names
    hsiStack

    ## class       : RasterStack 
    ## dimensions  : 502, 477, 239454, 3  (nrow, ncol, ncell, nlayers)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 256521, 256998, 4112069, 4112571  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11N +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0 
    ## names       : Band_58, Band_34, Band_19 
    ## min values  :     123,     116,      84 
    ## max values  :   15453,   15677,   13805

    #scale the data as specified in the reflInfo$Scale Factor
    
    hsiStack <- hsiStack/reflInfo$`Scale Factor`
    
    ### Plot one raster in the stack to make sure things look OK.
    plot(hsiStack$Band_58, main="Band 58")

![ ]({{ site.baseurl }}/images/rfigs/hyperspectral/RasterStack-RGB-Images-in-R-Using-HSI/plot-raster-stack-1.png)

We can play with the color ramps too if we want:


    #change the colors of our raster 
    myCol=terrain.colors(25)
    image(hsiStack$Band_58, main="Band 58", col=myCol)

![ ]({{ site.baseurl }}/images/rfigs/hyperspectral/RasterStack-RGB-Images-in-R-Using-HSI/plot-HSI-raster-1.png)

    #adjust the zlims or the stretch of the image
    myCol=terrain.colors(25)
    image(hsiStack$Band_58, main="Band 58", col=myCol, zlim = c(0,.5))

![ ]({{ site.baseurl }}/images/rfigs/hyperspectral/RasterStack-RGB-Images-in-R-Using-HSI/plot-HSI-raster-2.png)

    #try a different color palette
    myCol=topo.colors(15, alpha = 1)
    image(hsiStack$Band_58, main="Band 58", col=myCol, zlim=c(0,.5))

![ ]({{ site.baseurl }}/images/rfigs/hyperspectral/RasterStack-RGB-Images-in-R-Using-HSI/plot-HSI-raster-3.png)


The `plotRGB` function allows you to combine three bands to create an image. 
<a href="http://www.inside-r.org/packages/cran/raster/docs/plotRGB" target="_blank">
More on plotRGB here.</a>


    # create a 3 band RGB image
    plotRGB(hsiStack,
            r=1,g=2,b=3, scale=300, 
            stretch = "Lin")

![ ]({{ site.baseurl }}/images/rfigs/hyperspectral/RasterStack-RGB-Images-in-R-Using-HSI/plot-RGB-Image-1.png)

<i class="fa fa-star"></i>**A note about image stretching:** 
Notice that the scale is set to 300 on the RGB image that we plotted above. We can adjust this number and notice that the image gets darker - or lighter.
</div>

Once you've created your raster, you can export it as a GeoTIFF. You can bring 
this GeoTIFF into any GIS program!


    #write out final raster	
    #note: if you set overwrite to TRUE, then you will overwite or lose the older
    #version of the tif file! keep this in mind.
    writeRaster(hsiStack, file="rgbImage.tif", format="GTiff", overwrite=TRUE)

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip - False color and near infrared images:** 
Use the band combinations listed at the top of this page to modify the raster list.
What type of image do you get when you change the band values?
</div>

<div id="ds-challenge" markdown="1">
## Challenge: Other band combinations

Use different band combinations to create other "RGB" images. Suggested band 
combinations are below: 

* Color Infrared/False Color: rgb (90,34,19)
* SWIR, NIR, Red Band: rgb (152,90,58)
* False Color: rgb (363,246,55)

More on Band Combinations: 
[http://gdsc.nlr.nl/gdsc/en/information/earth_observation/band_combinations](http://gdsc.nlr.nl/gdsc/en/information/earth_observation/band_combinations)

</div>

## Plot Spectral Data on a Map

We can plot the location of our image on a map of the US. For this we'll use the 
lower left coordinates of the raster, extracted from the SPINFO group. Note that 
these coordinates are in latitude and longitude (geographic coordinates) rather 
than UTM coordinates.


    # Create a Map showing the location of our dataset in R
    map(database="state", region="california")
    points(spInfo$LL_lat~spInfo$LL_lon,pch = 15)
    #add title to map.
    title(main="NEON San Joaquin (SJER) Field Site - Central California")

![ ]({{ site.baseurl }}/images/rfigs/hyperspectral/RasterStack-RGB-Images-in-R-Using-HSI/create-location-map-1.png)

## Raster Math - Creating NDVI and other Vegetation Indices in R
In this last part, we will calculate some vegetation indices using raster math 
in R! We will start by creating NDVI or Normalized Difference Vegetation Index. 

### About NDVI

NDVI is  a ratio between 
the near infrared (NIR) portion of the electromagnetic spectrum and the red 
portion of the spectrum. Please keep in mind that there are different ways to 
aggregate bands when using hyperspectral data. This example is using individual 
bands to perform the NDVI calculation. Using individual bands is not necessarily 
the best way to calculate NDVI from hyperspectral data! 


    #Calculate NDVI
    #select bands to use in calculation (red, NIR)
    ndvi_bands <- c(58,90)
    
    
    #create raster list and then a stack using those two bands
    ndvi_rast <- lapply(ndvi_bands,band2Raster, file = f, noDataValue=15000, 
                        xMin=xMin, yMin=yMin,
                        crs=myCRS,res=1)
    ndvi_stack <- stack(ndvi_rast)
    
    #make the names pretty
    bandNDVINames <- paste("Band_",unlist(ndvi_bands),sep="")
    names(ndvi_stack) <- bandNDVINames
    
    ndvi_stack

    ## class       : RasterStack 
    ## dimensions  : 502, 477, 239454, 2  (nrow, ncol, ncell, nlayers)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 256521, 256998, 4112069, 4112571  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11N +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0 
    ## names       : Band_58, Band_90 
    ## min values  :     123,     315 
    ## max values  :   15453,   15293

    #calculate NDVI
    NDVI <- function(x) {
    	  (x[,2]-x[,1])/(x[,2]+x[,1])
    }
    ndvi_calc <- calc(ndvi_stack,NDVI)
    plot(ndvi_calc, main="NDVI for the NEON SJER Field Site")

![ ]({{ site.baseurl }}/images/rfigs/hyperspectral/RasterStack-RGB-Images-in-R-Using-HSI/create-NDVI-1.png)

    #play with breaks and colors to create a meaningful map
    
    #add a color map with 5 colors
    myCol <- terrain.colors(3)
    #add breaks to the colormap (6 breaks = 5 segments)
    brk <- c(0, .4, .7, .9)
    
    #plot the image using breaks
    plot(ndvi_calc, main="NDVI for the NEON SJER Field Site", col=myCol, breaks=brk)

![ ]({{ site.baseurl }}/images/rfigs/hyperspectral/RasterStack-RGB-Images-in-R-Using-HSI/create-NDVI-2.png)

	
<figure class="half">
<a href="{{ site.baseurl }}/images/hyperspectral/NDVI.png"><img src="{{ site.baseurl }}/images/hyperspectral/NDVI.png"></a>
<a href="{{ site.baseurl }}/images/hyperspectral/EVI.png"><img src="{{ site.baseurl }}/images/hyperspectral/EVI.png"></a>
    
<figcaption>LEFT: NDVI for the NEON SJER field site, created in R. RIGHT: EVI for the NEON SJER field site created in R.</figcaption>
</figure>
	
<div id="ds-challenge" markdown="1">
## Challenge: Work with Indices

Try the following:

1. Calculate EVI using the following formula : 
EVI<- 2.5 * ((b4-b3) / (b4 + 6 * b3- 7.5*b1 + 1))
2. Calculate NDNI using the following equation: 
log(1/p1510)-log(1/p1680)/ log(1/p1510)+log(1/p1680)
3. Explore the bands in the hyperspectral data. What happens if you average reflectance values across multiple red and NIR bands and then calculate NDVI?

</div>
