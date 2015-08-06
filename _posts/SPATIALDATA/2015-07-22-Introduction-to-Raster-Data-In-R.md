---
layout: post
title: "Raster Data in R - The Basics"
date:   2015-1-26 20:49:52
authors: Leah A. Wasser
dateCreated:  2014-11-26 20:49:52
lastModified: 2015-07-23 14:28:52
categories: [Coding and Informatics]
category: coding-and-informatics
tags: [hyperspectral-remote-sensing,R,GIS-Spatial-Data]
mainTag: GIS-Spatial-Data
description: "This post explains the fundamental principles, functions and metadata that you need to work with raster data in R."
image:
  feature: lidar_GrandMesa.png
  credit: LiDAR data collected over Grand Mesa, Colorado - National Ecological Observatory Network (NEON)
  creditlink: http://www.neoninc.org
permalink: /R/Raster-Data-In-R/
code1: /R/2015-07-22-Introduction-to-Raster-Data-In-R.R
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

##About
This activity will walk you through the fundamental principles of working 
with raster data in R.

**R Skill Level:** Intermediate - you've got the basics of `R` down.

<div id="objectives">

<h3>Goals / Objectives</h3>
After completing this activity, you will know:
<ol>
<li>What a raster dataset is and its fundamental attributes.</li>
<li>How to import rasters into `R` using the raster library.</li>
<li>How to perform raster calculations in `R`.</li>
</ol>

<h3>Things You'll Need To Complete This Lesson</h3>

<h3>R Libraries to Install:</h3>
<ul>
<li><strong>raster:</strong> <code> install.packages("raster")</code></li>
<li><strong>rgdal:</strong> <code> install.packages("rgdal")</code></li>

</ul>
<h4>Tools To Install</h4>

Please be sure you have the most current version of `R` and preferably
R studio to write your code.


<h4>Data to Download</h4>

Download the raster and *in situ* collected vegetation structure data:
<ul>
<li><a href="http://neonhighered.org/Data/LidarActivity/CHM_InSitu_Data.zip" class="btn btn-success"> DOWNLOAD Sample NEON LiDAR data in Raster Format & Vegetation Sampling Data</a></li>
<li><a href="{{ site.baseurl }}/data/rasterLayers_tif.zip" class="btn btn-success"> DOWNLOAD NEON imagery data (tiff format) California Domain 17 (D17)</a></li>
</ul>

<p>The LiDAR and imagery data used to create the rasters in this dataset were 
collected over the San Joaquin field site located in California (NEON Domain 17) 
and processed at <a href="http://www.neoninc.org" target="_blank" >NEON </a> 
headquarters. The entire dataset can be accessed by request from the NEON website.</p>  

<h4>Recommended Pre-Lesson Reading</h4>
<ul>
<li>
<a href="{{ site.baseurl }}/GIS-Spatial-Data/Working-With-Rasters/" target="_blank">
The Relationship Between Raster Resolution, Spatial extent & Number of Pixels - in R</a>
</li>
<li>
<a href="http://cran.r-project.org/web/packages/raster/raster.pdf" target="_blank">
Read more about the `raster` package in R.</a>
</li>
</ul>
</div>

#About Raster Data
Raster or "gridded" data are data that are saved in pixels. In the spatial world, 
each pixel represents an area on the Earth's surface. For example in the raster 
below, each pixel represents a particular land cover class that would be found in 
that location in the real world. 
<a href="{{ site.baseurl }}/GIS-Spatial-Data/Working-With-Rasters/"> More on 
rasters here</a>. 

<figure>
  <img src="{{ site.baseurl }}/images/spatialData/NLCD06_conus_lg.gif">
   <figcaption>The National Land Cover dataset (NLCD) is an example of a commonly used 
raster dataset. Each pixel in the Landsat derived raster represents a landcover
class.</figcaption>
</figure>

To work with rasters in R, we need two key libraries, `sp` and `raster`. 
To install the raster library you can use `install.packages('raster')`. 
When you install the raster library, `sp` should also install. Also install the 
`rgdal` library" `install.packages('rgdal')`. Among other things, `rgdal` will 
allow us to export rasters to geotiff format.


    #load the raster, sp, and rgdal packages
    library(raster)
    library(sp)
    library(rgdal)
    #Set your working directory to the folder where your data for this workshop
    #are stored. NOTE: if you created a project file in R studio, then you don't
    #need to set the working directory as it's part of the project.
    #setwd("~/yourWorkingDirectoryHere")  

Next, let's load a raster containing elevation data into R.


    #load raster in an R object called 'DEM'
    DEM <- raster("DigitalTerrainModel/SJER2013_DTM.tif")  
    # look at the raster attributes. 
    DEM

    ## class       : RasterLayer 
    ## dimensions  : 5060, 4299, 21752940  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## data source : C:\Users\lwasser\Documents\1_Workshops\ESA2015\DigitalTerrainModel\SJER2013_DTM.tif 
    ## names       : SJER2013_DTM


Notice a few things about this raster. 

* **Nrow, Ncol:** the number of rows and columns in the data (imagine a spreadsheet or a matrix). 
* **Ncells:** the total number of pixels or cells that make up the raster.
*  **Resolution:** the size of each pixel (in meters in this case). 1 meter pixels 
means that each pixel represents a 1m x 1m area on the earth's surface.
*  **Extent:** the spatial extent of the raster. This value will be in the same 
coordinate units as the coordinate reference system of the raster.
*  **Coord ref:** the coordinate reference system string for the raster. This 
raster is in UTM (Universal Trans mercator) zone 11 with a datum of WGS 84. 
<a href="http://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system" target="_blank">More on UTM here</a>.

##Defining Min/Max Values

By default the raster doesn't have the min / max values associated with it's attributes
Let's change that.


    #calculate and save the min and max values of the raster to the raster object
    DEM <- setMinMax(DEM)
    #view raster attributes
    DEM

    ## class       : RasterLayer 
    ## dimensions  : 5060, 4299, 21752940  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## data source : C:\Users\lwasser\Documents\1_Workshops\ESA2015\DigitalTerrainModel\SJER2013_DTM.tif 
    ## names       : SJER2013_DTM 
    ## values      : 228.1, 518.66  (min, max)


##About UTM

<figure>
   <a href="http://upload.wikimedia.org/wikipedia/en/thumb/5/57/Utm-zones.svg/720px-Utm-zones.svg.png
"><img src="http://upload.wikimedia.org/wikipedia/en/thumb/5/57/Utm-zones.svg/720px-Utm-zones.svg.png
"></a>
 <figcaption>The UTM coordinate reference system breaks the world into 60 latitude zones.</figcaption>
</figure>

You can also view the rasters min and max values and the range of values containes
within the pixels.


    #Get min and max cell values from raster
    #NOTE: this code may fail if the raster is too large
    cellStats(DEM, min)

    ## [1] 228.1

    cellStats(DEM, max)

    ## [1] 518.66

    cellStats(DEM, range)

    ## [1] 228.10 518.66

##Working with Rasters in R
Now that we have the raster loaded into R, let's grab some key raster attributes.


    #view coordinate reference system
    DEM@crs

    ## CRS arguments:
    ##  +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84
    ## +towgs84=0,0,0

    #view raster extent
    DEM@extent

    ## class       : Extent 
    ## xmin        : 254570 
    ## xmax        : 258869 
    ## ymin        : 4107302 
    ## ymax        : 4112362

    #plot the raster
    #note that this raster represents a small region of the NEON SJER field site
    plot(DEM, main="Digital Elevation Model, NEON Field Site")

![ ]({{ site.baseurl }}/images/rfigs/2015-07-22-Introduction-to-Raster-Data-In-R/view-crs-plot-1.png) 

We can also create a histogram to view the distribution of values in our raster.
Note that the max number of pixels that R will plot by default is 100,000. We
can tell it to plot more using the `maxpixels` attribute.


    #we can look at the distribution of values in the raster too
    hist(DEM, main="Distribution of elevation values", 
         col= "purple", 
         maxpixels=21752940)

![ ]({{ site.baseurl }}/images/rfigs/2015-07-22-Introduction-to-Raster-Data-In-R/histogram-1.png) 


## Basic Raster Math

We can also perform calculations on our raster. For instance, we could multiply
all values within the raster by 2.


    #multiple each pixel in the raster by 2
    DEM2 <- DEM * 2
    
    DEM2

    ## class       : RasterLayer 
    ## dimensions  : 5060, 4299, 21752940  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## data source : in memory
    ## names       : SJER2013_DTM 
    ## values      : 456.2, 1037.32  (min, max)

    #plot the new DEM
    plot(DEM2, main="DEM with all values doubled")

![ ]({{ site.baseurl }}/images/rfigs/2015-07-22-Introduction-to-Raster-Data-In-R/raster-math-1.png) 

 
## Plotting Raster Data

R has an `image` function that allows you to control the way a raster is
rendered on the screen. The `plot` command in R has a base setting for the number
of pixels that it will plot (100,000 pixels). The image command thus might be 
better for rendering larger rasters.


    #create a plot of our raster
    image(DEM)

![ ]({{ site.baseurl }}/images/rfigs/2015-07-22-Introduction-to-Raster-Data-In-R/PlotRaster-1.png) 

    #specify the range of values that you want to plot in the DEM
    #just plot pixels between 250 and 300 m in elevation
    image(DEM, zlim=c(250,300))

![ ]({{ site.baseurl }}/images/rfigs/2015-07-22-Introduction-to-Raster-Data-In-R/PlotRaster-2.png) 

    #we can specify the colors too
    col <- terrain.colors(5)
    image(DEM, zlim=c(250,300), main="Digital Elevation Model (DEM)", col=col)

![ ]({{ site.baseurl }}/images/rfigs/2015-07-22-Introduction-to-Raster-Data-In-R/PlotRaster-3.png) 

In the above example. `terrain.colors()` tells `R` to create a palette of colors within the `terrain.colors` color ramp. There are other palettes that you can use as well include `rainbow` and `heat.colors`. 

*[More on color palettes in R here](https://stat.ethz.ch/R-manual/R-devel/library/grDevices/html/palettes.html "More on color palettes.")
* [Another good post on colors.](http://www.r-bloggers.com/color-palettes-in-r/)
* [RColorBrewer is another powerful tool to create sets of colors.](http://cran.r-project.org/web/packages/RColorBrewer/RColorBrewer.pdf)

## Challenge Yourself

<i class="fa fa-star"></i> What happens if you change the number of colors in the `terrain.colors` command?<br>
<i class="fa fa-star"></i> What happens if you change the `zlim` values in the image command?<br>
<i class="fa fa-star"></i> What are the other attributes that you can specify when using the `image` command?
{: .notice}



## Breaks and Colorbars in R
A digital elevation model (DEM) is an example of a continuous raster. It contains elevation values for a range. For example, elevations values in a DEM might include any set of values between 200 m and 500 m. Given this range, you can plot DEM pixels using a gradient of colors. 

By default, R will assign the gradient of colors uniformly across the full range of values in the data. In our case, our DEM has values between 250 and 500. However, we can adjust the "breaks" which represent the numeric locations where the colors change if we want too.


    #add a color map with 5 colors
    col=terrain.colors(5)
    #add breaks to the colormap (6 breaks = 5 segments)
    brk <- c(250, 300, 350, 400,450,500)
    plot(DEM, col=col, breaks=brk, main="DEM with more breaks")

![ ]({{ site.baseurl }}/images/rfigs/2015-07-22-Introduction-to-Raster-Data-In-R/plot-with-breaks-1.png) 

    # Expand right side of clipping rect to make room for the legend
    par(xpd = FALSE,mar=c(5.1, 4.1, 4.1, 4.5))
    #DEM with a custom legend
    plot(DEM, col=col, breaks=brk, main="DEM with a Custom (buf flipped) Legend",legend = FALSE)
    
    #turn xpd back on to force the legend to fit next to the plot.
    par(xpd = TRUE)
    #add a legend - but make it appear outside of the plot
    legend( par()$usr[2], 4110600,
            legend = c("lowest", "a bit higher", "middle ground", "higher yet", "Highest"), 
            fill = col)

![ ]({{ site.baseurl }}/images/rfigs/2015-07-22-Introduction-to-Raster-Data-In-R/plot-with-breaks-2.png) 

Notice that the legend is in reverse order in the previous plot.
Let's fix that.


    # Expand right side of clipping rect to make room for the legend
    par(xpd = FALSE,mar=c(5.1, 4.1, 4.1, 4.5))
    #DEM with a custom legend
    plot(DEM, col=col, breaks=brk, main="DEM with a Custom Fixed Legend",legend = FALSE)
    #turn xpd back on to force the legend to fit next to the plot.
    par(xpd = TRUE)
    #add a legend - but make it appear outside of the plot
    legend( par()$usr[2], 4110600,
            legend = c("Highest", "Higher yet", "Middle","A bit higher", "Lowest"), 
            fill = rev(col))

![ ]({{ site.baseurl }}/images/rfigs/2015-07-22-Introduction-to-Raster-Data-In-R/plot-with-legend-1.png) 

We can add a custom color map with fewer breaks as well.


    #add a color map with 4 colors
    col=terrain.colors(4)
    #add breaks to the colormap (6 breaks = 5 segments)
    brk <- c(200, 300, 350, 400,500)
    plot(DEM, col=col, breaks=brk, main="DEM with fewer breaks")

![ ]({{ site.baseurl }}/images/rfigs/2015-07-22-Introduction-to-Raster-Data-In-R/add-color-map-1.png) 



A discrete dataset has a set of unique categories or classes. One example could be landuse classes. The example below shows elevation zones generated using the same DEM.


<figure>
    <a href="{{ site.baseurl }}/images/spatialData/DEM_DiscreteLegend.png"><img src="{{ site.baseurl }}/images/spatialData/DEM_DiscreteLegend.png"></a>
    <figcaption>A DEM with discrete classes. In this case, the classes relate to regions of elevation values.</figcaption>
</figure>


#Cropping Rasters in R

You can crop rasters in R using different methods. You can crop the raster directly 
drawing a box in the plot area. To do this, first plot the raster. Then define 
the crop extent by clicking twice: 

1. Click in the UPPER LEFT hand corner where you want the crop 
box to begin. 
2. Click again in the LOWER RIGHT hand corner to define where the box ends.
 
You'll see a red box on the plot. NOTE that this is a manual process that can be
used to quickly define a crop extent.


    #plot the DEM
    plot(DEM)
    #Define the extent of the crop by clicking on the plot
    cropbox1 <- drawExtent()
    #crop the raster, then plot the new cropped raster
    DEMcrop1 <- crop(DEM, cropbox1)
    
    #plot the cropped extent
    plot(DEMcrop1)
You can also manually assign the extent coordinates to be used to crop a raster. 
We'll need the extent defined as (`xmin`, `xmax`, `ymin` , `ymax`) to do this. 
This is how we'd crop using a GIS shapefile (with a rectangular shape)


    #define the crop extent
    cropbox2 <-c(255077.3,257158.6,4109614,4110934)
    #crop the raster
    DEMcrop2 <- crop(DEM, cropbox2)
    #plot cropped DEM
    plot(DEMcrop2)

![ ]({{ site.baseurl }}/images/rfigs/2015-07-22-Introduction-to-Raster-Data-In-R/cropDEMManual-1.png) 
 

## Challenge 

<i class="fa fa-star"></i> Open up file: `DigitalSurfaceModel/SJER2013_DSM.tif`. Save
it to an R object called `DSM`. Convert the raster data to feet.<br>
<i class="fa fa-star"></i> Plot the `DSM` in feet that you created above. Use a custom
color map. Create numeric breaks that make sense given the distribution of the data.
Hint:  your breaks might represent `high elevation`, `medium elevation`, 
`low elevation`. <br>
{: .notice}

### Image Data in R
[Click here to learn more about working with image formatted rasters in R.]({{ site.baseurl }}/R/Image-Raster-Data-In-R/) 
