---
syncID: 1c45b4a12e2a47f081c86f167059fad5
title: "Raster 04: Work With Multi-Band Rasters - Image Data in R"	
description: "Import and plot each band and all bands of a three-band raster in R."	
dateCreated: 2015-10-23
authors: Leah A. Wasser, Megan A. Jones, Zack Brym, Kristina Riemer, Jason Williams, Jeff Hollister,  Mike Smorul	
contributors:	Jason Brown, Bridget Hass
estimatedTime: 1 hour
packagesLibraries: terra, neonUtilities, RColorBrewer
topics: data-viz, raster, spatial-data-gis, camera-imagery
subtopics: 
languagesTool: R
dataProduct: DP3.30010.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/04-Multi-Band-Rasters-In-R/04-Multi-Band-Rasters-In-R.R
tutorialSeries: raster-data-series, raster-time-series
urlTitle: dc-multiband-rasters-r

---

This tutorial explores how to import and plot a multiband raster in
R. It also covers how to plot a three-band color image using the `plotRGB()`
function in R.

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

* Know how to identify a single vs. a multiband raster file.
* Be able to import multiband rasters into R using the `terra` package.
* Be able to plot multiband color image rasters in R using `plotRGB()`.
* Understand what a `NoData` value is in a raster.

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` installed on your computer to complete this tutorial.

### Install R Packages

* **terra:** `install.packages("terra")`
* **neonUtilities:** `install.packages("neonUtilities")`


* <a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

#### Data to Download

Data required for this tutorial will be downloaded using `neonUtilities` in the lesson.

The LiDAR and imagery data used in this lesson were collected over the 
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/HARV" target="_blank" >Harvard Forest (HARV)</a> field site. 

The entire dataset can be accessed from the <a href="http://data.neonscience.org" target="_blank">NEON Data Portal</a>.



****

**Set Working Directory:** This lesson assumes that you have set your working directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview of setting the working directory in R can be found here.</a>

**R Script & Challenge Code:** NEON data lessons often contain challenges that reinforce skills. If available, the code for challenge solutions is found in the downloadable R script of the entire lesson, available in the footer of each lesson page.


</div>

## The Basics of Imagery - About Spectral Remote Sensing Data

<iframe width="640" height="360" src="https://www.youtube.com/embed/3iaFzafWJQE" frameborder="0" allowfullscreen></iframe>

## About Raster Bands in R 
As discussed in the <a href="https://www.neonscience.org/dc-raster-data-r" target="_blank"> *Intro to Raster Data* tutorial</a>, 
a raster can contain 1 or more bands.

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/raster-general/single_multi_raster.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/raster-general/single_multi_raster.png"
    alt="Left: 3D image of a raster with only one band. Right: 3D image showing four separate layers of a multi band raster.">
    </a>
    <figcaption>A raster can contain one or more bands. We can use the terra `rast` function to import one single band from a single OR multi-band
    raster. Source: National Ecological Observatory Network (NEON).</figcaption>
</figure>

To work with multiband rasters in R, we need to change how we import and plot our data in several ways. 

* To import multiband raster data we will use the `stack()` function.
* If our multiband data are imagery that we wish to composite, we can use `plotRGB()` (instead of `plot()`) to plot a 3 band raster image.

## About MultiBand Imagery
One type of multiband raster dataset that is familiar to many of us is a color image. A basic color image consists of three bands: red, green, and blue. Each band represents light reflected from the red, green or blue portions of the electromagnetic spectrum. The pixel brightness for each band, when composited creates the colors that we see in an image. 

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-general/RGBSTack_1.jpg">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-general/RGBSTack_1.jpg"
    alt="A graphic depicting the three different color bands (red, green, and blue) of a satellite image and how they create a basic color image when composited."></a>
    <figcaption>A color image consists of 3 bands - red, green and blue. When rendered together in a GIS, or even a tool like Photoshop or any other
    image software, they create a color image. Source: National Ecological Observatory Network (NEON).  
    </figcaption>
</figure>

## Getting Started with Multi-Band Data in R
To work with multiband raster data we will use the `terra` package.


    # terra package to work with raster data

    library(terra)

    

    # package for downloading NEON data

    library(neonUtilities)

    

    # package for specifying color palettes

    library(RColorBrewer)

    

    # set working directory to ensure R can find the file we wish to import

    wd <- "~/data/" # this will depend on your local environment environment

    # be sure that the downloaded file is in this directory

    setwd(wd)

In this tutorial, the multi-band data that we are working with is imagery collected using the 
<a href="https://www.neonscience.org/data-collection/airborne-remote-sensing" target="_blank">NEON Airborne Observation Platform</a>
high resolution camera over the <a href="https://www.neonscience.org/field-sites/field-sites-map/HARV" target="_blank">NEON Harvard Forest field site</a>. Each RGB image is a 3-band raster. The same steps would apply to working with a multi-spectral image with 4 or more bands - like Landsat imagery, or even hyperspectral imagery (in geotiff format). We can plot each band of a multi-band image individually. 



    byTileAOP(dpID='DP3.30010.001', # rgb camera data
              site='HARV',
              year='2022',
              easting=732000,
              northing=4713500,
              check.size=FALSE, # set to TRUE or remove if you want to check the size before downloading
              savepath = wd)

    ## Downloading files totaling approximately 351.004249 MB 
    ## Downloading 1 files
    ##   |                                                                                                                                                                            |                                                                                                                                                                    |   0%  |                                                                                                                                                                            |====================================================================================================================================================================| 100%
    ## Successfully downloaded 1 files to ~/data//DP3.30010.001

![Red, green, and blue composite (true color) image of NEON's Harvard Forest (HARV) site](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/04-Multi-Band-Rasters-In-R/rfigs/demonstrate-RGB-Image-1.png)

Or we can plot each bands separately as follows:


    # Determine the number of bands

    num_bands <- nlyr(RGB_HARV)

    

    # Define colors to plot each

    # Define color palettes for each band using RColorBrewer

    colors <- list(
      brewer.pal(9, "Reds"),
      brewer.pal(9, "Greens"),
      brewer.pal(9, "Blues")
    )

    

    # Plot each band in a loop, with the specified colors

    for (i in 1:num_bands) {
      plot(RGB_HARV[[i]], main=paste("Band", i), col=colors[[i]])
    }

![Red band](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/04-Multi-Band-Rasters-In-R/rfigs/plot-bands-1.png)![Green band](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/04-Multi-Band-Rasters-In-R/rfigs/plot-bands-2.png)![Blue band](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/04-Multi-Band-Rasters-In-R/rfigs/plot-bands-3.png)

### Image Raster Data Attributes

We can display some of the attributes about the raster, as shown below:


    # Print dimensions

    cat("Dimensions:\n")

    ## Dimensions:

    cat("Number of rows:", nrow(RGB_HARV), "\n")

    ## Number of rows: 10000

    cat("Number of columns:", ncol(RGB_HARV), "\n")

    ## Number of columns: 10000

    cat("Number of layers:", nlyr(RGB_HARV), "\n")

    ## Number of layers: 3

    # Print resolution

    resolutions <- res(RGB_HARV)

    cat("Resolution:\n")

    ## Resolution:

    cat("X resolution:", resolutions[1], "\n")

    ## X resolution: 0.1

    cat("Y resolution:", resolutions[2], "\n")

    ## Y resolution: 0.1

    # Get the extent of the raster

    rgb_extent <- ext(RGB_HARV)

    

    # Convert the extent to a string with rounded values

    extent_str <- sprintf("xmin: %d, xmax: %d, ymin: %d, ymax: %d", 
                          round(xmin(rgb_extent)), 
                          round(xmax(rgb_extent)), 
                          round(ymin(rgb_extent)), 
                          round(ymax(rgb_extent)))

    

    # Print the extent string

    cat("Extent of the raster: \n")

    ## Extent of the raster:

    cat(extent_str, "\n")

    ## xmin: 732000, xmax: 733000, ymin: 4713000, ymax: 4714000
Let's take a look at the coordinate reference system, or CRS. You can use the parameters `describe=TRUE` to display this information more succinctly.


    crs(RGB_HARV, describe=TRUE)

    ##                    name authority  code
    ## 1 WGS 84 / UTM zone 18N      EPSG 32618
    ##                                                                                                                                                                                                                                                          area
    ## 1 Between 78°W and 72°W, northern hemisphere between equator and 84°N, onshore and offshore. Bahamas. Canada - Nunavut; Ontario; Quebec. Colombia. Cuba. Ecuador. Greenland. Haiti. Jamaica. Panama. Turks and Caicos Islands. United States (USA). Venezuela
    ##            extent
    ## 1 -78, -72, 84, 0

Let's next examine the raster's minimum and maximum values. What is the range of values for each band?


    # Replace Inf and -Inf with NA

    values(RGB_HARV)[is.infinite(values(RGB_HARV))] <- NA

    

    # Get min and max values for all bands

    min_max_values <- minmax(RGB_HARV)

    

    # Print the results

    cat("Min and Max Values for All Bands:\n")

    ## Min and Max Values for All Bands:

    print(min_max_values)

    ##     2022_HARV_7_732000_4713000_image_1 2022_HARV_7_732000_4713000_image_2 2022_HARV_7_732000_4713000_image_3
    ## min                                  0                                  0                                  0
    ## max                                255                                255                                255

This raster contains values between 0 and 255. These values represent the intensity of brightness associated with the image band. In 
the case of a RGB image (red, green and blue), band 1 is the red band. When we plot the red band, larger numbers (towards 255) represent 
pixels with more red in them (a strong red reflection). Smaller numbers (towards 0) represent pixels with less red in them (less red was reflected). 
To plot an RGB image, we mix red + green + blue values into one single color to create a full color image - this is the standard color image a digital camera creates.

<div id="ds-challenge" markdown="1">

### Challenge: Making Sense of Single Bands of a Multi-Band Image
Go back to the code chunk where you plotted each band separately. Compare the plots of band 1 (red) and band 2 (green). Is the forested area darker or lighter in band 2 (the green band) compared to band 1 (the red band)?  

</div>



## Other Types of Multi-band Raster Data

Multi-band raster data might also contain:

1. **Time series:** the same variable, over the same area, over time. 
2. **Multi or hyperspectral imagery:** image rasters that have 4 or more (multi-spectral) or more than 10-15 (hyperspectral) bands. Check out the NEON
Data Skills <a href="https://www.neonscience.org/hsi-hdf5-r" target="_blank"> **Imaging Spectroscopy HDF5 in R** </a> tutorial to learn how to work with hyperspectral data cubes.

The true color image plotted at the beginning of this lesson looks pretty decent. We can explore whether applying a stretch to the image might improve clarity and contrast using  `stretch="lin"` or `stretch="hist"`.  

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/raster-general/imageStretch_dark.jpg">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/raster-general/imageStretch_dark.jpg"
    alt="Graphic depicting stretching pixel brightness values to make a dark satellite image brighter">
    </a>
    <figcaption>When the range of pixel brightness values is closer to 0, a
    darker image is rendered by default. We can stretch the values to extend to
    the full 0-255 range of potential values to increase the visual contrast of
    the image.
    </figcaption>
</figure>

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/raster-general/imageStretch_light.jpg">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/raster-general/imageStretch_light.jpg"
    alt="Graphic depicting stretching pixel brightness values to make a bright satellite image darker">
    </a>
    <figcaption>When the range of pixel brightness values is closer to 255, a lighter image is rendered by default. We can stretch the values to extend     to the full 0-255 range of potential values to increase the visual contrast of the image.
    </figcaption>
</figure>


    # What does stretch do?

    

    # Plot the linearly stretched raster

    plotRGB(RGB_HARV, stretch="lin")

![Composite RGB image of HARV with a linear stretch](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/04-Multi-Band-Rasters-In-R/rfigs/image-stretch-1.png)

    # Plot the histogram-stretched raster

    plotRGB(RGB_HARV, stretch="hist")

![Composite RGB image of HARV with a histogram stretch](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Geospatial-skills/intro-raster-r/04-Multi-Band-Rasters-In-R/rfigs/image-stretch-2.png)

In this case, the stretch doesn't enhance the contrast our image significantly given the distribution of reflectance (or brightness) values is distributed well between 0 and 255, and applying a stretch appears to introduce some artificial, almost purple-looking brightness to the image.

<div id="ds-challenge" markdown="1">

### Challenge: What Methods Can Be Used on an R Object?
We can view various methods available to call on an R object with `methods(class=class(objectNameHere))`. Use this to figure out:

1. What methods can be used to call on the `RGB_HARV` object? 
2. What methods are available for a single band within `RGB_HARV`? 
3. Why do you think there is a difference? 

</div>



