---
syncID: c1cd91f1343b430c9c37497c52cf98ac
title: "Intro to Working with Hyperspectral Remote Sensing Data in HDF5 Format in R"
code1: hyperspectral/Work-With-Hyperspectral-Data-In-R.R
contributors: null
dataProduct: null
dateCreated: 2014-11-26 20:49:52
description: Open up and explore a hyperspectral dataset stored in HDF5 format in
  R. Learn about the power of data slicing in HDF5. Slice our band subsets of the
  data and create and visualize one band.
estimatedTime: 1.0 - 1.5 Hours
languagesTool: R
packagesLibraries: rhdf5, raster, rgdal
authors: Leah A. Wasser, Edmund Hart, Donal O'Leary
topics: hyperspectral, HDF5, remote-sensing
tutorialSeries: intro-hsi-r-series
urlTitle: hsi-hdf5-r
---

In this tutorial, we will explore reading and extracting spatial raster data 
stored within a HDF5 file using R. 

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

* Explain how HDF5 data can be used to store spatial data and the associated 
benefits of this format when working with large spatial data cubes.
* Extract metadata from HDF5 files.
* Slice or subset HDF5 data. You will extract one band of pixels. 
* Plot a matrix as an image and a raster.
* Export a final GeoTIFF (spatially projected) that can be used both in further 
analysis and in common GIS tools like QGIS.


## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### R Libraries to Install:

* **rhdf5**: `install.packages("BiocManager")`, `BiocManager::install("rhdf5")`
* **raster**: `install.packages('raster')`
* **rgdal**: `install.packages('rgdal')`

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in
 R - Adapted from Software Carpentry.</a>

### Data to Download

{% include/dataSubsets/_data_Imaging-Spec-Data-H5-2020.html %}

***
{% include/_greyBox-wd-rscript.html %}

</div> 

## About Hyperspectral Remote Sensing Data

The electromagnetic spectrum is composed of thousands of bands representing 
different types of light energy. Imaging spectrometers (instruments that collect 
hyperspectral data) break the electromagnetic spectrum into groups of bands that 
support classification of objects by their spectral properties on the Earth's 
surface. Hyperspectral data consists of many bands - up to hundreds of bands - 
that cover the electromagnetic spectrum.

The NEON imaging spectrometer (NIS) collects data within the 380 nm to 2510 nm 
portions of the electromagnetic spectrum within bands that are approximately 5 nm 
in width. This results in a hyperspectral data cube that contains approximately 
428 bands - which means BIG DATA. *Remember* that the example dataset used 
here only has 1 out of every 4 bands included in a full NEON hyperspectral dataset 
(this substantially reduces size!). When we refer to bands in this tutorial, 
we will note the band numbers for this example dataset, which may be different 
from NEON production data. 


<figure>
  <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/DataCube.png">
  <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/DataCube.png"></a>
	<figcaption>A data cube of NEON hyperspectral data. Each layer in the cube 
  represents a band.</figcaption>
</figure>
 
The HDF5 data model natively compresses data stored within it (makes it smaller) 
and supports data slicing (extracting only the portions of the data that you 
need to work with rather than reading the entire dataset into memory). These 
features in addition to the ability to support spatial data and associated 
metadata make it ideal for working with large data cubes such as those generated 
by imaging spectrometers.


In this tutorial we will explore reading and extracting spatial raster data 
stored within a HDF5 file using R. 

##  Read HDF5 data into R
We will use the `raster` and `rhdf5` packages to read in the HDF5 file that 
contains hyperspectral data for the 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank">NEON San Joaquin (SJER) field site</a>. 
Let's start by calling the needed packages and reading in our NEON HDF5 file.  

Please be sure that you have *at least* version 2.10 of `rhdf5` installed. Use: 
`packageVersion("rhdf5")` to check the package version. 


    # Load `raster` and `rhdf5` packages and read NIS data into R
    library(raster)
    library(rhdf5)
    library(rgdal)
    
    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files. Be sure to move the download into your working directory!
    wd <- "~/Documents/data/" #This will depend on your local environment
    setwd(wd)
    
    # Define the file name to be opened
    f <- paste0(wd,"NEON_hyperspectral_tutorial_example_subset.h5")

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** To update all packages installed in 
R, use `update.packages()`.
</div>


    # look at the HDF5 file structure 
    View(h5ls(f,all=T))

When you look at the structure of the data, take note of the "map info" dataset,
the "Coordinate_System" group, and the "wavelength" and "Reflectance" datasets. The
"Coordinate_System" folder contains the spatial attributes of the data including its
EPSG Code, which is easily converted to a Coordinate Reference System (CRS). 
The CRS documents how the data are physically located on the Earth. The "wavelength" 
dataset contains the middle wavelength values for each band in the data. The 
"Reflectance" dataset contains the image data that we will use for both data processing 
and visualization.

More Information on raster metadata:

* <a href="https://www.neonscience.org/raster-data-r" target="_blank"> Raster Data in R 
- The Basics</a> - this tutorial explains more about how rasters work in R and 
their associated metadata.

* <a href="https://www.neonscience.org/hyper-spec-intro" target="_blank"> About 
Hyperspectral Remote Sensing Data</a> -this tutorial explains more about 
metadata and important concepts associated with multi-band (multi and 
hyperspectral) rasters.

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip - HDF5 Structure:** Note that the structure
of individual HDF5 files may vary depending on who produced the data. In this
case, the Wavelength and reflectance data within the file are both datasets.
However, the spatial information is contained within a group. Data downloaded from
another organization like NASA, may look different. This is why it's important to
explore the data before diving into using it!
</div>

We can use the `h5readAttributes()` function to read and extract metadata from the 
HDF5 file. Let's start by learning about the wavelengths described within this file.


    # get information about the wavelengths of this dataset
    wavelengthInfo <- h5readAttributes(f,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
    wavelengthInfo

    ## $Description
    ## [1] "Central wavelength of the reflectance bands."
    ## 
    ## $Units
    ## [1] "nanometers"
    ## 
    ## $dim
    ## [1] 107

Next, we can use the `h5read` function to read the data contained within the
HDF5 file. Let's read in the wavelengths of the band centers:


    # read in the wavelength information from the HDF5 file
    wavelengths <- h5read(f,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
    head(wavelengths)

    ## [1] 381.5437 401.5756 421.6075 441.6394 461.6713 481.7032

    tail(wavelengths)

    ## [1] 2404.764 2424.796 2444.828 2464.860 2484.892 2504.924

Which wavelength is band 6 associated with? 

(Hint: look at the wavelengths 
vector that we just imported and check out the data located at index 6 - 
`wavelengths[6]`).

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/bluelight.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/bluelight.png"></a>
    <figcaption>482 nanometers falls within the blue portion of the electromagnetic spectrum. Source: National Ecological Observatory Network </figcaption>
</figure>

Band 6 has a associate wavelength center of 481.7032 nanometers (nm) which is 
in the blue portion of the visible electromagnetic spectrum (~ 400-700 nm). 

### Bands and Wavelengths

A *band* represents 
a group of wavelengths. For example, the wavelength values between 695 nm and 700 nm 
might be one band as captured by an imaging spectrometer. The imaging spectrometer
collects reflected light energy in a pixel for light in that band. Often when you 
work with a multi or hyperspectral dataset, the band information is reported as 
the center wavelength value. This value represents the center point value of the 
wavelengths represented in that  band. Thus in a band spanning 695-700 nm, the 
center would be 697.5 nm). The full width half max (FWHM) will also be reported. 
This value represents the spread of the band around that center point. So, a band 
that covers 800 nm-805 nm might have a FWHM of 5 nm and a wavelength value of 
802.5 nm. 

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/spectrumZoomed.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/spectrumZoomed.png"></a>
    <figcaption>Bands represent a range of values (types of light) within the 
    electromagnetic spectrum. Values for each band are often represented as the 
    center point value of each band. Source: National Ecological Observatory 
    Network (NEON)</figcaption>
</figure>

The HDF5 dataset that we are working with in this activity may contain more 
information than we need to work with. For example, we don't necessarily need 
to process all 107 bands available in this example dataset (or all 426 bands 
available in a full NEON hyperspectral reflectance file, for that matter)
- if we are interested in creating a product like NDVI which only uses bands in 
the near infra-red and red portions of the spectrum. Or we might only be interested 
in a spatial subset of the data - perhaps a region where we have plots in the field.

The HDF5 format allows us to slice (or subset) the data - quickly extracting the 
subset that we need to process. Let's extract one of the green bands in our 
dataset - band 9. 

By the way - what is the center wavelength value associated 
with band 9? 

Hint: `wavelengths[9]`. 

How do we know this band is a green band in the visible portion of the spectrum?

In order to effectively subset our data, let's first read the important 
reflectance metadata stored as *attributes* in the "Reflectance_Data" dataset. 


    # First, we need to extract the reflectance metadata:
    reflInfo <- h5readAttributes(f, "/SJER/Reflectance/Reflectance_Data")
    reflInfo

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
    ## 
    ## $dim
    ## [1] 107 500 500

    # Next, we read the different dimensions
    
    nRows <- reflInfo$Dimensions[1]
    nCols <- reflInfo$Dimensions[2]
    nBands <- reflInfo$Dimensions[3]
    
    nRows

    ## [1] 500

    nCols

    ## [1] 500

    nBands

    ## [1] 107


The HDF5 read function reads data in the order: Bands, Cols, Rows. This is
different from how R reads data. We'll adjust for this later.


    # Extract or "slice" data for band 9 from the HDF5 file
    b9 <- h5read(f,"/SJER/Reflectance/Reflectance_Data",index=list(9,1:nCols,1:nRows)) 
    
    # what type of object is b9?
    class(b9)

    ## [1] "array"

### A Note About Data Slicing in HDF5
Data slicing allows us to extract and work with subsets of the data rather than 
reading in the entire dataset into memory. Thus, in this case, we can extract and 
plot the green band without reading in all 107 bands of information. The ability 
to slice large datasets makes HDF5 ideal for working with big data. 	

Next, let's convert our data from an array (more than 2 dimensions) to a matrix 
(just 2 dimensions). We need to have our data in a matrix format to plot it.


    # convert from array to matrix by selecting only the first band
    b9 <- b9[1,,]
    
    # check it
    class(b9)

    ## [1] "matrix"


### Arrays vs. Matrices

Arrays are matrices with more than 2 dimensions. When we say dimension, we are 
talking about the "z" 
associated with the data (imagine a series of tabs in a spreadsheet). Put the other 
way: matrices are arrays with only 2 dimensions. Arrays can have any number of 
dimensions one, two, ten or more. 

Here is a matrix that is 4 x 3 in size (4 rows and 3 columns):

| Metric    | species 1 | species 2 |
|----------------|-----------|-----------|
| total number   | 23        | 45        |
| average weight | 14        | 5         |
| average length | 2.4       | 3.5       |
| average height | 32        | 12        |

### Dimensions in Arrays
An array contains 1 or more dimensions in the "z" direction. For example, let's 
say that we collected the same set of species data for every day in a 30 day month.
We might then have a matrix like the one above for each day for a total of 30 days 
making a 4 x 3 x 30 array (this dataset has more than 2 dimensions). More on R object 
types <a href="http://www.statmethods.net/input/datatypes.html">here</a> 
(links to external site, DataCamp).

<figure class="half">
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/R/matrix.png"><img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/R/matrix.png"></a>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/R/array.png"><img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/R/array.png"></a>
    <figcaption>Right: a matrix has only 2 dimensions. Left: an array has more than 2 dimensions.</figcaption>
</figure>

Next, let's look at the metadata for the reflectance data. When we do this, take 
note of 1) the scale factor and 2) the data ignore value. Then we can plot the 
band 9 data. Plotting spatial data as a visual "data check" is a good idea to 
make sure processing is being performed correctly and all is well with the image. 


    # look at the metadata for the reflectance dataset
    h5readAttributes(f,"/SJER/Reflectance/Reflectance_Data")

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
    ## 
    ## $dim
    ## [1] 107 500 500

    # plot the image
    image(b9)

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/rfigs/read-attributes-plot-1.png)

    # oh, that is hard to visually interpret.
    # what happens if we plot a log of the data?
    image(log(b9))

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/rfigs/read-attributes-plot-2.png)

What do you notice about the first image? It's washed out and lacking any detail. What 
could be causing this? It got better when plotting the log of the values, but 
still not great. 

Let's look at the distribution of reflectance values in 
our data to figure out what is going on.


    # Plot range of reflectance values as a histogram to view range
    # and distribution of values.
    hist(b9,breaks=40,col="darkmagenta")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/rfigs/hist-data-1.png)

    # View values between 0 and 5000
    hist(b9,breaks=40,col="darkmagenta",xlim = c(0, 5000))

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/rfigs/hist-data-2.png)

    # View higher values
    hist(b9, breaks=40,col="darkmagenta",xlim = c(5000, 15000),ylim=c(0,100))

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/rfigs/hist-data-3.png)

As you're examining the histograms above, keep in mind that reflectance values 
range between 0-1. The **data scale factor** in the metadata tells us to divide 
all reflectance values by 10,000. Thus, a value of 5,000 equates to a reflectance 
value of 0.50. Storing data as integers (without decimal places) compared to 
floating points (with decimal places) creates a smaller file. You will see this 
done often when working with remote sensing data. 

Notice in the data that there are some larger reflectance values (>5,000) that 
represent a smaller number of pixels. These pixels are skewing how the image 
renders. 

### Data Ignore Value
Image data in raster 
format will often contain a data ignore value and a scale factor. The data ignore 
value represents pixels where there are no data. Among other causes, no data 
values may be attributed to the sensor not collecting data in that area of the 
image or to processing results which yield null values. 

Remember that the metadata for the `Reflectance` dataset designated -9999 as 
`data ignore value`. Thus, let's set all pixels with a value == -9999 to `NA` 
(no value). If we do this, R won't try to render these pixels.


    # there is a no data value in our raster - let's define it
    myNoDataValue <- as.numeric(reflInfo$Data_Ignore_Value)
    myNoDataValue

    ## [1] -9999

    # set all values equal to -9999 to NA
    b9[b9 == myNoDataValue] <- NA
    
    # plot the image now
    image(b9)

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/rfigs/set-values-NA-1.png)

### Reflectance Values and Image Stretch

Our image still looks dark because R is trying to render all reflectance values 
between 0 and 14999 as if they were distributed equally in the histogram. However 
we know they are not distributed equally. There are many more values between 
0-5000 then there are values >5000. 

Images have a distribution of reflectance values. A typical image viewing program 
will render the values by distributing the entire range of reflectance values  
across a range of "shades" that the monitor can render - between 0 and 255. 
However, often the distribution of reflectance values is not linear. For example, 
in the case of our data, most of the reflectance values fall between 0 and 0.5. 
Yet there are a few values >0.8 that are heavily impacting the way the image is 
drawn on our monitor. Imaging processing programs like ENVI, QGIS and ArcGIS (and 
even Adobe Photoshop) allow you to adjust the stretch of the image. This is similar 
to adjusting the contrast and brightness in Photoshop. 

The proper way to adjust our data would be 
what's called an `image stretch`. We will learn how to stretch our image data, 
later. For now, let's plot the values as the log function on the pixel 
reflectance values to factor out those larger values. 


    image(log(b9))

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/rfigs/plot-log-1.png)

The log applied to our image increases the contrast making it look more like an 
image. However, look at the images below. The top one is what our log adjusted 
image looks like when plotted. The bottom on is an RGB version of the same image. 
Notice a difference? 

<figure class="half">
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/RGBImage_2.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/RGBImage_2.png"></a>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/SJER_Flipped.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/SJER_Flipped.png"></a>
    <figcaption>LEFT: The image as it should look. RIGHT: the image that we outputted from the code above. Notice a difference?</figcaption>
</figure>


### Transpose Image

Notice that there are three data dimensions for this file: Bands x Rows x 
Columns. However, when R reads in the dataset, it reads them as: Columns x 
Bands x Rows. The data are flipped. We can quickly transpose the data to correct 
for this using the `t` or `transpose` command in R.

The orientation is rotated in our log adjusted image. This is because R reads 
in matrices starting from the upper left hand corner. Whereas, most rasters 
read pixels starting from the lower left hand corner. In the next section, we 
will deal with this issue by creating a proper georeferenced (spatially located) 
raster in R. The raster format will read in pixels following the same methods 
as other GIS and imaging processing software like QGIS and ENVI do.


    # We need to transpose x and y values in order for our 
    # final image to plot properly
    b9 <- t(b9)
    image(log(b9), main="Transposed Image")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/rfigs/transpose-data-1.png)


## Create a Georeferenced Raster

Next, we will create a proper raster using the `b9` matrix. The raster 
format will allow us to define and manage:

* Image stretch
* Coordinate reference system & spatial reference
* Resolution
* and other raster attributes...

It will also account for the orientation issue discussed above.
 
To create a raster in R, we need a few pieces of information, including: 

* The coordinate reference system (CRS)
* The spatial extent of the image 


### Define Raster CRS

First, we need to define the Coordinate reference system (CRS) of the raster. 
To do that, we can first grab the EPSG code from the HDF5 attributes, and covert the
EPSG to a CRS string. Then we can assign that CRS to the raster object.


    # Extract the EPSG from the h5 dataset
    myEPSG <- h5read(f, "/SJER/Reflectance/Metadata/Coordinate_System/EPSG Code")
    
    # convert the EPSG code to a CRS string
    myCRS <- crs(paste0("+init=epsg:",myEPSG))
    
    # define final raster with projection info 
    # note that capitalization will throw errors on a MAC.
    # if UTM is all caps it might cause an error!
    b9r <- raster(b9, 
            crs=myCRS)
    
    # view the raster attributes
    b9r

    ## class      : RasterLayer 
    ## dimensions : 500, 500, 250000  (nrow, ncol, ncell)
    ## resolution : 0.002, 0.002  (x, y)
    ## extent     : 0, 1, 0, 1  (xmin, xmax, ymin, ymax)
    ## crs        : +init=epsg:32611 +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## source     : memory
    ## names      : layer 
    ## values     : 0, 9210  (min, max)

    # let's have a look at our properly oriented raster. Take note of the 
    # coordinates on the x and y axis.
    
    image(log(b9r), 
          xlab = "UTM Easting", 
          ylab = "UTM Northing",
          main = "Properly Oriented Raster")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/rfigs/define-CRS-1.png)

Next we define the extents of our raster. The extents will be used to calculate 
the raster's resolution. Fortunately, the spatial extent is provided in the
HDF5 file "Reflectance_Data" group attributes that we saved before as `reflInfo`.


    # Grab the UTM coordinates of the spatial extent
    xMin <- reflInfo$Spatial_Extent_meters[1]
    xMax <- reflInfo$Spatial_Extent_meters[2]
    yMin <- reflInfo$Spatial_Extent_meters[3]
    yMax <- reflInfo$Spatial_Extent_meters[4]
    
    # define the extent (left, right, top, bottom)
    rasExt <- extent(xMin,xMax,yMin,yMax)
    rasExt

    ## class      : Extent 
    ## xmin       : 257500 
    ## xmax       : 258000 
    ## ymin       : 4112500 
    ## ymax       : 4113000

    # assign the spatial extent to the raster
    extent(b9r) <- rasExt
    
    # look at raster attributes
    b9r

    ## class      : RasterLayer 
    ## dimensions : 500, 500, 250000  (nrow, ncol, ncell)
    ## resolution : 1, 1  (x, y)
    ## extent     : 257500, 258000, 4112500, 4113000  (xmin, xmax, ymin, ymax)
    ## crs        : +init=epsg:32611 +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## source     : memory
    ## names      : layer 
    ## values     : 0, 9210  (min, max)

<figure>
		<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/sat_image_lat_lon.png">
		<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral/sat_image_lat_lon.png"></a>
		<figcaption>The extent of a raster represents the spatial location of each 
		corner. The coordinate units will be determined by the spatial projection/
		coordinate reference system that the data are in. Source: National Ecological
		Observatory Network (NEON) </figcaption>
</figure>

<a href="https://www.neonscience.org/raster-data-series" target="_blank"> Learn more about raster attributes including extent, and coordinate reference systems here.</a>

We can adjust the colors of our raster too if we want.


    # let's change the colors of our raster and adjust the zlims 
    col <- terrain.colors(25)
    
    image(b9r,  
          xlab = "UTM Easting", 
          ylab = "UTM Northing",
          main= "Raster w Custom Colors",
          col=col, 
          zlim=c(0,3000))

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/rfigs/plot-colors-raster-1.png)


We've now created a raster from band 9 reflectance data. We can export the data
as a raster, using the `writeRaster` command. 


    # write out the raster as a geotiff
    writeRaster(b9r,
                file=paste0(wd,"band9.tif"),
                format="GTiff",
                overwrite=TRUE)
    
    # It's always good practice to close the H5 connection before moving on!
    # close the H5 file
    H5close()


<div id="ds-challenge" markdown="1">
### Challenge: Work with Rasters

Try these three extensions on your own: 

1. Create rasters using other bands in the dataset.

2. Vary the distribution of values in the image to mimic an image stretch. 
e.g. `b9[b9 > 6000 ] <- 6000`

3. Use what you know to extract ALL of the reflectance values for
ONE pixel rather than for an entire band. HINT: this will require you to pick
an x and y value and then all values in the z dimension:
`aPixel<- h5read(f,"Reflectance",index=list(NULL,100,35))`. Plot the spectra 
output.

</div>
