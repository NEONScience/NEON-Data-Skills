---
layout: post
title: "Work with Hyperspectral Remote Sensing data in R -  HDF5"
date:   2016-06-20
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah, Naupaka]
contributors: [Edmund Hart, Megan A. Jones]
time: "2:30"
dateCreated:  2016-05-01
lastModified: 2016-06-22
packagesLibraries: [rhdf5]
categories: [self-paced-tutorial]
mainTag: institute-day1
tags: [R, HDF5]
tutorialSeries: [institute-day1]
description: "Learn how to open a NEON HDF5 file in R."
code1: institute-materials/day1_monday/openNEONH5.R
image:
  feature:
  credit:
  creditlink:
permalink: /R/intro-hdf5-R/
comments: false
---

First, let's load the required libraries.


    # load libraries
    library(raster)
    library(rhdf5)
    library(rgdal)
    
    # set wd
    # setwd("~/Documents/data/NEONDI-2016") #Mac
    # setwd("~/data/NEONDI-2016")  # Windows

## Explore HDF5 Files

Next, define the file name and view the file structure using `H5ls`.


    # define the file name as an object
    f <- "NEONdata/D17-California/TEAK/2013/spectrometer/reflectance/Subset3NIS1_20130614_100459_atmcor.h5"
    
    # view the structure of the H5 file
    h5ls(f, all = TRUE)

## View Data Attributes

Data stored within an H5 file is referred to as a **dataset**. Metadata for each
item in an H5 file is referred to as **attributes**. Next, let's view
the attributes for the map info dataset within the NEON H5 file.


    # View map info attributes
    # Map Info contains some key coordinate reference system information
    # Including the UPPER LEFT corner coordinate in UTM (meters) of the Reflectance
    # data.
    mapInfo <- h5read(f, "map info", read.attributes = TRUE)
    mapInfo

    ## [1] "UTM,1,1,325963.0,4103482.0,1.0000000000e+000,1.0000000000e+000,11,North,WGS-84,units=Meters"
    ## attr(,"Description")
    ## [1] "Basic Map information for envi style programs"


# Grab scale Factor

Next, let's extract the data scale factor from the H5 attributes. Notice the
data ignore value is stored in a character format. NEON will be fixing this
in the future.


    # r  get attributes for the Reflectance dataset
    reflInfo <- h5readAttributes(f, "Reflectance")
    
    # view the scale factor for the data
    reflInfo$`Scale Factor`

    ## [1] 10000

    # view the data ignore value
    reflInfo$`data ignore value`

    ## [1] "15000.0"

# Get shape of reflectance dataset

Let's read the data to grab the dimensions.
Note: in a future version of the data, NEON will have the dimensions as ATTRIBUTES
that you can automatically pull in


    # open the file for viewing
    fid <- H5Fopen(f)
    
    # open the reflectance dataset
    did <- H5Dopen(fid, "Reflectance")
    did

    ## HDF5 DATASET
    ##         name /Reflectance
    ##     filename 
    ##         type H5T_STD_I16LE
    ##         rank 3
    ##         size 544 x 578 x 426
    ##      maxsize 544 x 578 x 426

    # grab the dimensions of the object
    sid <- H5Dget_space(did)
    dims <- H5Sget_simple_extent_dims(sid)$size
    
    # take note that the data seem to come in ROTATED. wavelength is the
    # THIRD dimension rather than the first. Columns are the FIRST dimension, 
    # then rows.
    
    # close everything
    H5Sclose(sid)
    H5Dclose(did)
    H5Fclose(fid)


## View Wavelength Information

Next, let's look at the wavelengths for each band in our hyperspectral data set.
How many bands does our data contain?


    # import the center wavelength in um of each "band"
    wavelengths<- h5read(f,"wavelength")
    str(wavelengths)

    ##  num [1:426, 1] 0.382 0.387 0.392 0.397 0.402 ...

## Read Reflectance Data

Once we know the dimensions of the data, we can more efficiently **slice** out
chunks or subsets of our data out. The power of HDF5 is that it allows us to
store large heterogeneous data. However, we can quickly and efficiently access
those data through "slicing" or extracting subsets of the data.

Let's grab reflectance data for **Band 56** only.


    # Extract or "slice" data for band 56 from the HDF5 file
    b56 <- h5read(f, "Reflectance", index=list(1:dims[1], 1:dims[2], 56))
    
    # note the data come in as an array
    class(b56)

    ## [1] "array"

<i class="fa fa-star"></i> **Data Tip:** If you get an error with the file being 
"open" just use the generic h5 close function: `H5close()`. Once NEON has fixed 
the attributes, you can skip all of this nonsense :)
{: .notice}


## Convert to Matrix

Next, we will convert the data to a matrix and then to a raster.
We don't need an array (which is a multi-dimensional object) because our data
are only 2 dimensions at this point (1 single band).


    # Convert from array to matrix so we can plot and convert to a raster
    b56 <- b56[,,1]
    
    # plot the data
    # what happens when we plot?
    image(b56)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/openNEONH5/view-data-1.png)

    # looks like we need to force a stretch
    image(log(b56),
    			main="Band 56 with log Transformation")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/openNEONH5/view-data-2.png)

    # view distribution of reflectance data
    # force non scientific notation
    options("scipen"=100, "digits"=4)
    
    hist(b56,
         col="springgreen",
         main="Distribution of Reflectance Values \nBand 56")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/openNEONH5/view-data-3.png)

<figure>
    <a href="http://www.neondataskills.org/images/dc-spatial-raster/imageStretch_dark.jpg">
    <img src="http://www.neondataskills.org/images/dc-spatial-raster/imageStretch_dark.jpg">
    </a>
    <figcaption>When the range of pixel brightness values is closer to 0, a
    darker image is rendered by default. We can stretch the values to extend to
    the full 0-255 range of potential values to increase the visual contrast of
    the image.
    </figcaption>
</figure>

<figure>
    <a href="http://www.neondataskills.org/images/dc-spatial-raster/imageStretch_light.jpg">
    <img src="http://www.neondataskills.org/images/dc-spatial-raster/imageStretch_light.jpg">
    </a>
    <figcaption>When the range of pixel brightness values is closer to 255, a
    lighter image is rendered by default. We can stretch the values to extend to
    the full 0-255 range of potential values to increase the visual contrast of
    the image.
    </figcaption>
</figure>

## Data Clean-up

We have now imported some reflectance data for Band 56 into R.
However, we need to do a bit of cleanup including:

1. Set the **no data value** to 15,000.
2. Apply the **scale factor** to the data (10,000).

Let's do that next.


    # extract no data value from the attributes
    noDataVal <- as.integer(reflInfo$`data ignore value`)
    # set all reflectance values = 15,000 to NA
    b56[b56 == noDataVal] <- NA
    
    # Extract the scale factor as an object
    scaleFactor <- reflInfo$`Scale Factor`
    
    # divide all values in our B56 object by the scale factor to get a range of
    # reflectance values between 0-1 (the valid range)
    b56 <- b56/scaleFactor
    
    # view distribution of reflectance values
    hist(b56,
         main="Distribution with NoData Value Considered\nData Scaled")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/openNEONH5/no-data-scale-1.png)

## Data Values Outside the Valid Range

Note -- if we notice values > 1 (outside of the valid range) we may want to assign
those values to NA.

Next, let's look at the data.

<figure class="half">
    <a href="{{ site.baseurl }}/images/spatialData/teakettle-crop-image.png">
    <img src="{{ site.baseurl }}/images/spatialData/teakettle-crop-image.png"></a>
    <a href="{{ site.baseurl }}/images/spatialData/view-data-2.png">
    <img src="{{ site.baseurl }}/images/spatialData/view-data-2.png"></a>
    <figcaption>LEFT: Final Lower Teakettle Image, RIGHT: Our Plotted Data. Notice a difference?</figcaption>
</figure>




    # Because the data import as column, row but we require row, column in R,
    # we need to transpose x and y values in order for our final image to plot 
    # properly
    
    b56 <- t(b56)
    image(log(b56), main="Band 56\nTransposed Values")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/openNEONH5/transpose-data-1.png)

## Define Spatial Extent

Next, we need to create the spatial extent required to position the raster in 
space.


    # We can extract the upper left-hand corner coordinates.
    # the numbers as position 4 and 5 are the UPPER LEFT CORNER (x,y)
    mapInfo<-unlist(strsplit(mapInfo, ","))
    
    # grab the X,Y left corner coordinate
    # ensure the format is numeric with as.numeric()
    xMin <- as.numeric(mapInfo[4])
    yMax <- as.numeric(mapInfo[5])
    
    # we can get the x and y resolution from this string too
    res <- c(mapInfo[6],mapInfo[7])
    res <- as.numeric(res)
    
    # finally calculate the xMax value and the yMin value from the dimensions 
    # we grabbed above. The xMax is the left corner + number of columns* resolution.
    xMax <- xMin + (dims[1]*res[1])
    yMin <- yMax - (dims[2]*res[2])
    
    # also note that x and y res are the same (1 meter)
    
    # Now, define the raster extent
    # define the extent (left, right, top, bottom)
    rasExt <- extent(xMin, xMax, yMin, yMax)
    
    # now we can create a raster and assign it it's spatial extent
    b56r <- raster(b56,
                   crs=CRS("+init=epsg:32611"))
    # assign CRS
    extent(b56r) <- rasExt
    
    # view raster object attributes
    b56r

    ## class       : RasterLayer 
    ## dimensions  : 578, 544, 314432  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 325963, 326507, 4102904, 4103482  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +init=epsg:32611 +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : layer 
    ## values      : 0.0033, 0.5678  (min, max)

    # plot the new image
    plot(b56r, 
         main="Raster for Lower Teakettle \nBand 56")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/openNEONH5/read-map-info-1.png)

## Export to GeoTIFF

Finally, we may want to export our new raster to a GeoTIFF format.


    writeRaster(b56r,
                file="Outputs/TEAK/band56.tif",
                format="GTiff",
                naFlag=-9999)
