---
layout: post
title: "Intro to Working with Hyperspectral Remote Sensing Data in HDF5 Format in R"
date:   2015-1-14 20:49:52
dateCreated:  2014-11-26 20:49:52
lastModified: 2015-08-07 14:30:52
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: rhdf5, raster, rgdal
authors: Leah A. Wasser, Edmund Hart
categories: [remote-sensing]
category: remote-sensing
tags: [hyperspectral-remote-sensing,R,HDF5]
mainTag: hyperspectral-remote-sensing
description: "Open up and explore a hyperspectral dataset stored in HDF5 format in R. Learn about the power of data slicing in HDF5. Slice our band subsets of the data and create and visualize one band." 
image:
  feature: hierarchy_folder_purple.png
  credit: The Artistry of Colin Williams, NEON
  creditlink: http://www.neoninc.org
permalink: /HDF5/Imaging-Spectroscopy-HDF5-In-R/
code1: R/2015-06-08-Work-With-Hyperspectral-Data-In-R.R
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
<li>Understand how HDF5 data can be used to store spatial data and the associated 
benefits of this format when working with large spatial data cubes.</li>
<li>Know how to extract metadata from HDF5 files.</li>
<li>Know how to slice or subset HDF5 data. You will extract one band of pixels. 
</li>
<li>Know how to plot a matrix as an image and a raster.</li>
<li>Know how to export a final Geotiff (spatially projected) that can be used 
both in further analysis and in common GIS tools like QGIS.</li>
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
</ul>

<h3>Data to Download</h3>
<a href="http://neonhighered.org/Data/HDF5/SJER_140123_chip.h5" class="btn btn-success"> 
DOWNLOAD the NEON Imaging Spectrometer Data (HDF5) Format</a>. 
<p>The data in this HDF5 file were collected over the San Joachim field site 
located in California (NEON Domain 17) and processed at NEON headquarters. The 
entire dataset can be accessed <a href="http://neoninc.org/data-resources/get-data/airborne-data" target="_blank">by request from the NEON website.</a>
</p>  
</div> 


##About Hyperspectral Remote Sensing Data

The electromagnetic spectrum is composed of thousands of bands representing 
different types of light energy. Imaging spectrometers (instruments that collect 
hyperspectral data) break the electromagnetic spectrum into groups of bands that 
support classification of objects by their spectral properties on the earth's 
surface. Hyperspectral data consists of many bands - up to hundreds of bands - 
that cover the electromagnetic spectrum.

The NEON imaging spectrometer (NIS) collects data within the 380 nm to 2510 nm 
portions of the electromagnetic spectrum within bands that are approximately 5 nm 
in width. This results in a hyperspectral data cube that contains approximately 
428 bands - which means BIG DATA. 


<figure>
  <a href="{{ site.baseurl }}/images/hyperspectral/DataCube.png">
  <img src="{{ site.baseurl }}/images/hyperspectral/DataCube.png"></a>
	<figcaption>A data cube of NEON hyperspectral data. Each layer in the cube 
  represents a band.</figcaption>
</figure>
 
The HDF5 data model natively compresses data stored within it (makes it smaller) 
and supports data slicing (extracting only the portions of the data that you 
need to work with rather than reading the entire dataset into memory). These 
features in addition to the ability to support spatial data and associated 
metadata make it ideal for working with large data cubes such as those generated 
by imaging spectrometers.

##About This Activity
In this activity we will explore reading and extracting spatial raster data 
stored within a HDF5 file using `R`. Please be sure that you have *atleast* 
version 2.10 of `rhdf5` installed. Use: `packageVersion("rhdf5")` to check the 
package version. If you need to update `rhdf5`, use the following code:


    #use the code below to install the rhdf5 library if it's not already installed.
    #source("http://bioconductor.org/biocLite.R")
    #biocLite("rhdf5")
    
    #r Load `raster` and `rhdf5` packages and read NIS data into R
    library(raster)
    library(rhdf5)
    library(rgdal)

<i class="fa fa-star"></i> **Data Tip:** To update all packages installed in `R`, use `update.packages()`.
{: .notice}

##1. Read HDF5 data into R
We will use the `raster` and `rhdf5` libraries to read in the HDF5 file that 
contains hyperspectral data for the <a href="http://neoninc.org/science-design/field-sites/san-joaquin" target="_blank">NEON San Joaquin field site</a>. Let's start by calling 
the needed libraries and reading in our NEON HDF5 file.  


    #be sure to set the working directory to the location where you saved your
    # the SJER_120123_chip.h5 file
    #setwd('pathToDataHere')
    getwd()

    ## [1] "/Users/lwasser/Documents/1_Workshops/ESA2015_BigData"

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

When you look at the structure of the data, take note of the `map info dataset`, 
the `spatialInfo` group, and the `wavelength` and `Reflectance` datasets. The 
`spatialInfo` folder contains the spatial attributes of the data including its 
Coordinate Reference System (CRS). The CRS documents how the data are physically 
location on the earth. The `wavelength` dataset contains the middle wavelength 
values for each band in the data. The reflectance dataset contains the image data 
that we will use for both data processing and visualization. 

More Information on raster metadata:

* [Metadata to understand when working with raster data](http://neondataskills.org/HDF5/Working-With-Rasters/ "Key Attributes of Raster Data")

* [Metadata and important concepts associated with multi-band (multi and hyperspectral) rasters](http://neondataskills.org/HDF5/About-Hyperspectral-Remote-Sensing-Data/ "Key Attributes of Raster Data")

<i class="fa fa-star"></i> **Data Tip - HDF5 Structure:** Note that the structure 
of individual HDF5 files may vary depending on who produced the data. In this 
case, the Wavelength and reflectance data within the file are both datasets. 
However the spatial information is contained within a group. Data downloaded from 
another organization like NASA, may look different. This is why it's important to 
explore the data before diving into using it!
{: .notice}

We can use the `h5readAttributes` function to read and extract metadata from the 
HDF5 file. Let's start by reading in the spatial information.



    #r get spatialInfo using the h5readAttributes function 
    spInfo <- h5readAttributes(f,"spatialInfo")
    
    #r get attributes for the Reflectance dataset
    reflInfo <- h5readAttributes(f,"Reflectance")

Next, let's read in the wavelength center associated with each band in the HDF5 
file. 



    #read in the wavelength information from the HDF5 file
    wavelengths<- h5read(f,"wavelength")


Which wavelength is band 19 associated with? (hint: look at the wavelengths 
vector that we just imported and check out the data located at index 19 - 
`wavelengths[19]`).

<figure>
    <a href="{{ site.baseurl }}/images/hyperspectral/bluelight.png">
    <img src="{{ site.baseurl }}/images/hyperspectral/bluelight.png"></a>
    <figcaption>472 nanometers falls within the blue portion of the electromagnetic spectrum.</figcaption>
</figure>

Band 19 has a associate wavelength center or 0.47244 which is in micrometers. 
This value equates to 472.44 nanometers (nm) which is in the visible blue portion 
of the electromagnetic spectrum (~ 400-700 nm). 


<i class="fa fa-star"></i> **Data Tip: Bands and Wavelengths** A *band* represents 
a group of wavelengths. For example, the wavelength values between 800nm and 805nm 
might be one band as captured by an imaging spectrometer. The imaging spectrometer
collects reflected light energy in a pixel for light in that band. Often when you 
work with a multi or hyperspectral dataset, the band information is reported as 
the center wavelength value. This value represents the center point value of the 
wavelengths represented in that  band. Thus in a band spanning 800-805 nm, the 
center would be 802.5 nm). The full width half max (FWHM) will also be reported. 
This value represents the spread of the band around that center point. So, a band 
that covers 800 nm-805 nm might have a FWHM of 2.5 and a wavelength value of 802.5. 
{: .notice}

<figure>
    <a href="{{ site.baseurl }}/images/hyperspectral/spectrumZoomed.png">
    <img src="{{ site.baseurl }}/images/hyperspectral/spectrumZoomed.png"></a>
    <figcaption>Bands represent a range of values (types of light) within the 
    electromagnetic spectrum. Values for each band are often represented as the 
    center point value of each band.</figcaption>
</figure>

The HDF5 dataset that we are working with in this activity contains more 
information than we need to work with. For example, we don't necessarily need 
to process all 426 bands - if we are interested in creating a product like NDVI
which only users bands in the near infra-red and red portions of the spectrum. 
Or we might only be interested in a spatial subset of the data - perhaps a region 
where we have plots in the field.

The HDF5 format allows us to slice (or subset) the data - quickly extracting the 
subset that we need to process. Let's extract one of the green bands in our 
dataset - band 34. By the way - what is the center wavelength value associated 
with band 34? hint `wavelengths[34]`. How do we know this band is a green band 
in the visible portion of the spectrum?


    #note that we can grab the dimensions of the dataset from the attributes
    #we can then use that information to slice out our band data
    nRows <- reflInfo$row_col_band[1]
    nCols <- reflInfo$row_col_band[2]
    nBands <- reflInfo$row_col_band[3]
    
    nRows

    ## [1] 502

    nCols

    ## [1] 477

    nBands

    ## [1] 426

    #The HDF5 read function reads data in the order: Cols, Rows and bands
    #This is different from how R reads data (rows, columns, bands). We'll adjust for 
    #this later
    
    #Extract or "slice" data for band 34 from the HDF5 file
    b34<- h5read(f,"Reflectance",index=list(1:nCols,1:nRows,34))
     
    #what type of object is b34?
    class(b34)

    ## [1] "array"

###A Note About Data Slicing in HDF5
Data slicing allows us to extract and work with subsets of the data rather than 
reading in the entire dataset into memory. Thus, in this case, we can extract and 
plot the green band without reading in all 426 bands of information. The ability 
to slice large datasets, makes HDF5 ideal for working with big data. 	


Next, let's convert our data from an array (more than 2 dimensions) to a matrix 
(just 2 dimensions). We need to have our data in a matrix format to plot it.


    #Convert from array to matrix
    b34 <- b34[,,1]



<i class="fa fa-star"></i> **Data Tip: Arrays vs. Matrices** Arrays are matrices 
with more than 2 dimensions. When we say dimension, we are talking about the "z" 
associated with the data (imagine a series of tabs in a spreadsheet). Put the other 
way: matrices are arrays with only 2 dimensions. Arrays can have any number of 
dimensions one, two, ten or more. 
{: .notice} 

Here is a matrix that is 4 x 3 in size (4 rows and 3 columns):

| Metric    | species 1 | species 2 |
|----------------|-----------|-----------|
| total number   | 23        | 45        |
| average weight | 14        | 5         |
| average length | 2.4       | 3.5       |
| average height | 32        | 12        |

<i class="fa fa-star"></i> **Data Tip: Dimensions in Arrays** An array contains 
1 or more dimensions in the "z" direction. For example, let's say that we collected 
this same set of species data for every day in a 30 day month. We might then have 
a matrix like the one above for each day for a total of 30 days making a 4 x 3 x 
30 array (this dataset has more than 2 dimensions). More on R object types 
<a href="http://www.statmethods.net/input/datatypes.html">here</a>.
{: .notice}

<figure class="half">
    <a href="{{ site.baseurl }}/images/R/matrix.png"><img src="{{ site.baseurl }}/images/R/matrix.png"></a>
    <a href="{{ site.baseurl }}/images/R/array.png"><img src="{{ site.baseurl }}/images/R/array.png"></a>
    <figcaption>Right: a matrix has only 2 dimensions. Left: an array has more than 2 dimensions.</figcaption>
</figure>


Next, let's look at the metadata for the reflectance data. When we do this, take 
note of 1) the scale factor and 2) the data ignore value. Then we can plot the 
band 34 data. Plotting spatial data as a visual "data check" is a good idea to 
make sure processing is being performed correctly and all is well with the image. 

    
    

    # look at the metadata for the reflectance dataset
    h5readAttributes(f,"Reflectance")

    ## $DIMENSION_LABELS
    ## [1] "Wavelength" "Line"       "Sample"    
    ## 
    ## $Description
    ## [1] "Atmospherically corrected reflectance."
    ## 
    ## $`Scale Factor`
    ## [1] 10000
    ## 
    ## $Unit
    ## [1] "unitless. Valid range 0-1."
    ## 
    ## $`data ignore value`
    ## [1] "15000"
    ## 
    ## $row_col_band
    ## [1] 502 477 426

    #plot the image
    image(b34)

![ ]({{ site.baseurl }}/images/rfigs/2015-06-08-Work-With-Hyperspectral-Data-In-R/read-attributes-plot-1.png) 

    #what happens if we plot a log of the data?
    image(log(b34))

![ ]({{ site.baseurl }}/images/rfigs/2015-06-08-Work-With-Hyperspectral-Data-In-R/read-attributes-plot-2.png) 

    #note - when R brings in the matrix, the dimensions are read in reverse order


What do you notice about the image? It's a bit dark and lacking any detail. What 
could be causing this? Let's look at the distribution of reflectance values in 
our data to figure out what is going on.


    #Plot range of reflectance values as a histogram to view range
    #and distribution of values.
    hist(b34,breaks=40,col="darkmagenta")

![ ]({{ site.baseurl }}/images/rfigs/2015-06-08-Work-With-Hyperspectral-Data-In-R/hist-data-1.png) 

    #View values between 0 and 5000
    hist(b34,breaks=40,col="darkmagenta",xlim = c(0, 5000))

![ ]({{ site.baseurl }}/images/rfigs/2015-06-08-Work-With-Hyperspectral-Data-In-R/hist-data-2.png) 

    hist(b34, breaks=40,col="darkmagenta",xlim = c(5000, 15000),ylim=c(0,100))

![ ]({{ site.baseurl }}/images/rfigs/2015-06-08-Work-With-Hyperspectral-Data-In-R/hist-data-3.png) 

    

As you're examining the histograms above, keep in mind that reflectance values 
range between 0-1. The **data scale factor** in the metadata tells us to divide 
all reflectance values by 10,000. Thus, a value of 5,000 equates to a reflectance 
value of 0.50. Storing data as integers (without decimal places) compared to 
floating points (with decimal places) creates a smaller file. You will see this 
done often when working with remote sensing data.  

Notice in the data that there are some larger reflectance values (>5,000) that 
represent a smaller number of pixels. These pixels are skewing how the image renders.   
   
Remember that the metadata for the `Reflectance` dataset designated 15,000 as 
`data ignore value`. Thus, let's set all pixels with a value == 15,000 to `NA` 
(no value). If we do this, R won't try to render these pixels.


    #there is a no data value in our raster - let's define it
    noDataValue <- as.numeric(reflInfo$`data ignore value`)
    noDataValue

    ## [1] 15000

    #set all values greater than 15,000 to NA
    b34[b34 == noDataValue] <- NA

	
	

<i class="fa fa-star"></i> **Data Tip: Data Ignore Value** Image data in raster 
format will often contain a data ignore value and a scale factor. The data ignore 
value represents pixels where there are no data. Among other causes, no data 
values may be attributed to the sensor not collecting data in that area of the 
image or to processing results which yield null values. 
{: .notice}

Our image still looks dark because R is trying to render all reflectance values 
between 0 and 14999 as if they were distributed equally in the histogram. However 
we know they are not distributed equally. There are many more values between 
0-5000 then there are values >5000. The proper way to adjust our data would be 
what's called an `image stretch`. We will learn how to stretch our image data, 
later. For now, let's run a log on the pixel reflectance values to factor out 
those larger values. 


    image(log(b34))

![ ]({{ site.baseurl }}/images/rfigs/2015-06-08-Work-With-Hyperspectral-Data-In-R/plot-log-1.png) 

	
<i class="fa fa-star"></i> **Data Tip: Reflectance Values and Image Stretch** 
Images have a distribution of reflectance values. A typical image viewing program 
will render the values by distributing the entire range of reflectance values  
across a range of "shades" that the monitor can render - between 0 and 255. 
However, often the distribution of reflectance values is not linear. For example, 
in the case of our data, most of the reflectance values fall between 0 and 0.5. 
Yet there are a few values >1 that are heavily impacting the way the image is 
drawn on our monitor. Imaging processing programs like ENVI, QGIS and ArcGIS (and 
even Adobe Photoshop) allow you to adjust the stretch of the image. This is similar 
to adjusting the contrast and brightness in Photoshop. Read more about this topic: 
<a href="http://www.r-s-c-c.org/node/241" target="_blank">About Image Stretch - RSCC</a> 
and another link that discusses image stretch <a href="http://www.r-s-c-c.org/node/240" target="_blank">
Read more about linear image stretch discussion</a>
{: .notice}


The log applied to our image increases the contrast making it look more like an 
image. However, look at the images below. The top one is what our log adjusted 
image looks like when plotted. The bottom on is an RGB version of the same image. 
Notice a difference? 


<figure class="half">
    <a href="{{ site.baseurl }}/images/hyperspectral/RGBImage_2.png"><img src="{{ site.baseurl }}/images/hyperspectral/RGBImage_2.png"></a>
    <a href="{{ site.baseurl }}/images/hyperspectral/SJER_Flipped.png"><img src="{{ site.baseurl }}/images/hyperspectral/SJER_Flipped.png"></a>
    <figcaption>LEFT: the image as it should look. RIGHT: the image that we outputted from the code above. Notice a difference?</figcaption>
</figure>


    #We need to transpose x and y values in order for our final image to plot properly
    b34<-t(b34)
    image(log(b34), main="Transposed image")

![ ]({{ site.baseurl }}/images/rfigs/2015-06-08-Work-With-Hyperspectral-Data-In-R/transpose-data-1.png) 

    

<i class="fa fa-star"></i> **Data Tip: Transpose** in HDF5 view, notice that there 
are three data dimensions for this file: Bands x Rows x Columns. However, when R 
reads in the dataset, it reads them as: Columns x Bands x Rows. The data are flipped. 
We can quickly transpose the data to correct for this using the `t` or `transpose` 
command in `R`.
{: .notice} 


The orientation is rotated in our log adjusted image. This is because `R` reads in matrices starting from the upper left hand corner. Whereas, most rasters read pixels starting from the lower left hand corner. In the next section, we will deal with this issue by creating a proper georeferenced (spatiall located) raster in R. The raster format will read in pixels following the same methods as other GIS and imaging processing software like QGIS and ENVI do.


##2. Create a Georeferenced Raster
Next, we will create a proper raster using the `b34` matrix. The raster format will allow us to define and manage:

* Image stretch
* Coordinate reference system / spatial reference
* Resolution

It will also account for the orientation issue discussed above.
 
To create a raster in R, we need a few pieces of information, including: 

* The coordinate reference system (CRS)
* The location of the first pixel (located in the lower left hand corner of the raster). 
* The resolution or size of each pixel in the data. 

First let's grab the spatial information that we need from the HDF5 file. The CRS and associated information that is needed is stored in the `map info` dataset. The map info string looks something like this:
<br>
`"UTM,1.000,1.000,256521.000,4112571.000,1.000000e+000,`
`1.000000e+000,11,North,WGS-84,units=Meters" `. 
<br>
Notice that this information is separated by commas. We can use the `strsplit` command in R to extract each element into a vector. The elements are position 4 and 5 represent the lower left hand corner of the raster. We need this information to define the raster's extent.


    #Populate the raster image extent value. 
    #get the map info, split out elements
    mapInfo<-h5read(f,"map info")
    #Extract each element of the map info information 
    #so we can extract the lower left hand corner coordinates.
    mapInfo<-unlist(strsplit(mapInfo, ","))
    
    #view the attributes in the map dataset
    mapInfo

    ##  [1] "UTM"           "1.000"         "1.000"         "256521.000"   
    ##  [5] "4112571.000"   "1.000000e+000" "1.000000e+000" "11"           
    ##  [9] "North"         "WGS-84"        "units=Meters"

Next we define the extents of our raster. The extents will be used to calculate the raster's resolution. The lower left hand corner is located at mapInfo[4:5]. We can define the final raster dataset extent by adding the number of rows to the Y lower left hand corner coordinate and the number of columns in the `Reflectance` dataset to the X lower left hand corner coordinate.   

<figure>
	<a href="{{ site.baseurl }}/images/hyperspectral/sat_image_lat_lon.png"><img src="{{ site.baseurl }}/images/hyperspectral/sat_image_lat_lon.png"></a>
    
    <figcaption>The extent of a raster represents the spatial location of each corner. The coordinate units will be determined by the spatial projection / coordinate reference system that the data are in. Learn more by clicking on the link below. </figcaption>
</figure>

[Learn more about raster attributes including extent, and coordinate reference systems here.](http://neondataskills.org/HDF5/Working-With-Rasters/) 



    #grab resolution of raster as an object
    res <- spInfo$xscale
    res

    ## [1] 1

    #Grab the UTM coordinates of the upper left hand corner of the 
    #raster
    
    #grab the left side x coordinate (xMin)
    xMin <- as.numeric(mapInfo[4]) 
    #grab the top corner coordinate (yMax)
    yMax <- as.numeric(mapInfo[5])
    
    xMin

    ## [1] 256521

    yMax

    ## [1] 4112571

    #Calculate the lower right hand corner to define the full extent of the 
    #raster. To do this we need the number of columns and rows in the raster
    #and the resolution of the raster.
    
    #note that you need to multiple the columns and rows by the resolution of 
    #the data to calculate the proper extent!
    xMax=(xMN+(ncol(b34))*res)
    yMin=(yMX-(nrow(b34))*res)     
    
    xMax

    ## [1] 256998

    yMin

    ## [1] 4112069

    #define the extent (left, right, top, bottom)
    rasExt <- extent(xMin,xMax,yMin,yMax)
    
    rasExt

    ## class       : Extent 
    ## xmin        : 256521 
    ## xmax        : 256998 
    ## ymin        : 4112069 
    ## ymax        : 4112571

    #assign the spatial extent to the raster
    extent(b34r) <- rasExt
    
    #look at raster attributes
    b34r

    ## class       : RasterLayer 
    ## dimensions  : 502, 477, 239454  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 256521, 256998, 4112069, 4112571  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11N +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 116, 15677  (min, max)

###Define Raster CRS

We have defined the extent of our raster but we still need to define the Coordinate 
reference system (`CRS`) of the raster. To do that, we can first grab the CRS
string from the HDF5 attributes. Then we can assign that CRS to the raster object.


    #Create the projection in as object
    myCRS <- spInfo$projdef
    myCRS

    ## [1] "+proj=utm  +zone=11N +ellps=WGS84 +datum=WGS84"

    #define final raster with projection info 
    #note that capitalization will throw errors on a MAC.
    #if UTM is all caps it might cause an error!
    b34r<-raster(b34, 
          crs=myCRS)
    
    b34r

    ## class       : RasterLayer 
    ## dimensions  : 502, 477, 239454  (nrow, ncol, ncell)
    ## resolution  : 0.002096436, 0.001992032  (x, y)
    ## extent      : 0, 1, 0, 1  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11N +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 116, 15677  (min, max)

    #let's have a look at our properly positioned raster. Take note of the 
    #coordinates on the x and y axis.
    
    image(log(b34r), 
          xlab = "UTM Easting", 
          ylab = "UTM Northing",
          main = "Properly Positioned Raster")

![ ]({{ site.baseurl }}/images/rfigs/2015-06-08-Work-With-Hyperspectral-Data-In-R/define-CRS-1.png) 

We can adjust the colors of our raster too if we want.


    #let's change the colors of our raster and adjust the zlims 
    col=terrain.colors(25)
    
    image(b34r,  
          xlab = "UTM Easting", 
          ylab = "UTM Northing",
          main= "Raster w Custom Colors",
          col=col, 
          zlim=c(0,3000))

![ ]({{ site.baseurl }}/images/rfigs/2015-06-08-Work-With-Hyperspectral-Data-In-R/plot-colors-raster-1.png) 


We've now created a raster from band 34 reflectance data. We can export the data
as a raster, using the `writeRaster` command. 


    #write out the raster as a geotiff
    
    writeRaster(b34r,
                file="band34.tif",
                format="GTiff",
                overwrite=TRUE)
    
    #It's always good practice to close the H5 connection before moving on!
    #close the H5 file
    H5close()


	
###Extra Credit

If you get done early, consider trying the following: 

1. Create rasters using other bands in the dataset.

2. Vary the distribution of values in the image to mimic an image stretch. 
e.g. `b34[b34 > 6000 ] <- 10000`

3. Extra tricky -- use what you know to extract ALL of the reflectance values for
ONE pixel rather than for an entire band. HINT: this will require you to pick
an x and y value and then all values in the z dimension:
`aPixel<- h5read(f,"Reflectance",index=list(54,36,NULL))`. Plot the spectra output.
{: .notice}

 
