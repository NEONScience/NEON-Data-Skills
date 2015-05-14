---
layout: post
title: "Raster Data in R - The Basics"
date:   2015-1-26 20:49:52
authors: Leah A. Wasser
dateCreated:  2014-11-26 20:49:52
lastModified: 2015-05-08 14:30:52
categories: [Coding and Informatics]
category: coding-and-informatics
tags: [hyperspectral-remote-sensing,R,GIS-Spatial-Data]
mainTag: GIS-Spatial-Data
description: "This post explains the fundamental principles, functions and metadata that you need to work with raster data in R."
code1: 
image:
  feature: lidar_GrandMesa.png
  credit: LiDAR data collected over Grand Mesa, Colorado - National Ecological Observatory Network (NEON)
  creditlink: http://www.neoninc.org
permalink: /R/Raster-Data-In-R/
code1: /R/raster-data-in-R.R
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
**R Skill Level:** Intermediate

<div id="objectives">

<h3>Goals / Objectives</h3>
After completing this activity, you will know:
<ol>
<li>What a raster dataset is and its fundamental attributes.</li>
<li>How to work with the raster package to import rasters into R.</li>
<li>How to perform basic calculations using rasters in R.</li>
</ol>

<h3>Things You'll Need To Complete This Lesson</h3>

<h4>Tools & Libraries To Install</h4>
<ul>
<li>R or R studio to write your code.</li>
<li>R packages `raster` and `rgdal` </li>
</ul>


<h4>Data to Download</h4>

Download the raster and *in situ* collected vegetation structure data:
<ul>
<li><a href="http://neonhighered.org/Data/LidarActivity/CHM_InSitu_Data.zip" class="btn btn-success"> DOWNLOAD NEON  Sample NEON LiDAR Data</a></li>
<li><a href="{{ site.baseurl }}/data/rasterLayers_tif.zip" class="btn btn-success"> DOWNLOAD NEON imagery data (tiff format) California Domain D17</a></li>
</ul>

<p>The LiDAR and imagery data used to create the rasters in this dataset were 
collected over the San Joaquin field site located in California (NEON Domain 17) 
and processed at <a href="http://www.neoninc.org" target="_blank" >NEON </a> 
headquarters. The entire dataset can be accessed by request from the NEON website.</p>  

<h4>Recommended Pre-Lesson Reading</h4>
<ul>
<li>
<a href="{{ site.baseurl }}/GIS-Spatial-Data/Working-With-Rasters/">
Please read "Working With Rasters in R, Python and other NON gui tools.</a>
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
   <figcaption>The National Land Cover dataset is an example of a commonly used 
raster dataset. Each pixel in the Landsat derived raster represents a landcover
class.</figcaption>
</figure>

To work with rasters in R, we need two key libraries, `sp` and `raster`. 
Let's start by loading these into R. To install the raster library you can use 
`install.packages(‘raster’)`. When you install the raster library, `sp` should 
also install. Also install the `rgdal` library" 
`install.packages(‘rgdal’)`.

	#load the raster, sp, and rgdal packages
	library(raster)
	library(sp)
	library(rgdal)
	#Set your working directory to the folder where your data for this workshop
	#are stored. NOTE: if you created a project file in R studio, then you don't
	#need to set the working directory as it's part of the project.
	setwd("~/yourWorkingDirectoryHere")  
	

Next, let's load the raster into R. Notice that we're using some clever code 
that tells R to paste the working directory into the path, and then it tells it 
to add the location of the raster layer.

	#load raster in an R object called 'DEM'
	DEM <- raster("CHM_InSitu_Data/DigitalTerrainModel/SJER2013_DTM.tif")  
	#next, let's look at the attributes of the raster. 
	DEM
	
OUTPUT:

	class       : RasterLayer 
	dimensions  : 5060, 4299, 21752940  (nrow, ncol, ncell)
	resolution  : 1, 1  (x, y)
	extent      : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
	coord. ref. : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
	data source : /Users/law/Documents/1_Workshops/R_Raster_NEON/CHM_InSitu_Data/DigitalTerrainModel/SJER2013_DTM.tif 
	names       : SJER2013_DTM 
		
Notice a few things about this raster. 

* **Nrow, Ncol** is the number of rows and columns data. 
* **Ncells** is the total number of pixels that make up the raster.
*  **Resolution** is the size of each pixel (in meters in this case)
*  **Extent** this is the spatial extent of the raster. this value will be coordinate units associated with the coordinate reference system of the raster.
*  **Coord ref** this is the coordinate reference system string for the raster. This raster is in UTM (Universal Trans mercator) zone 11 with a datum of WGS 84. <a href="http://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system" target="_blank">More on UTM here</a>.

If you do not see the min and max cell values in the output above, try this:

	#Get min and max cell values from raster
	cellStats(DEM, min)
	cellStats(DEM, max)
	cellStats(DEM, range)

##About UTM

<figure>
   <a href="http://upload.wikimedia.org/wikipedia/en/thumb/5/57/Utm-zones.svg/720px-Utm-zones.svg.png
"><img src="http://upload.wikimedia.org/wikipedia/en/thumb/5/57/Utm-zones.svg/720px-Utm-zones.svg.png
"></a>
 <figcaption>The UTM coordinate reference system breaks the world into 60 latitude zones.</figcaption>
</figure>

##Working with Rasters in R
Now that we have the raster loaded into R, let's grab some key metadata.


	DEM@crs
	DEM@extent
	#plot the raster
	plot(DEM)


Also notice it has a resolution and a set of dimension values associated with the raster. This means less work for us!

	DEM
	
OUTPUT:

	class       : RasterLayer 
	dimensions  : 5060, 4299, 21752940  (nrow, ncol, ncell)
	resolution  : 1, 1  (x, y)
	extent      : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
	coord. ref. : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
	data source : /Users/law/Documents/data/CHM_InSitu_Data/DigitalSurfaceModel/SJER2013_DSM.tif 
	names       : SJER2013_DSM 


## Image vs Plot

R has an `image` function that allows you to better control the way a raster is
rendered on the screen. The `plot` command in R has a base setting for the number
of pixels that it will plot (100,000 pixels). The image command thus might be 
better for rendering larger rasters.

	#let's create a plot of our raster
	image(DEM)
	#specify the range of values that you want to plot in the DEM
	#just plot pixels between 250 and 300 m in elevation
	image(DEM, zlim=c(250,300))

	#we can specify the colors too
	col <- terrain.colors(5)
	image(DEM, zlim=c(250,300), col=col)


## Challenge Yourself

1. What happens if you change the number of colors in the terrain.colors command?

[More on colors here](https://stat.ethz.ch/R-manual/R-devel/library/grDevices/html/palettes.html "More on colors.")

[Another good post on colors.](http://www.r-bloggers.com/color-palettes-in-r/)

2. What happens if you change the zlim values in the image command?
3. What are the other attributes that you can specify when using the image command?

## Breaks and Colorbars in R
A digital elevation model (DEM) is an example of a continuous raster. It contains elevation values for a range. For example, elevations values in a DEM might include any set of values between 200 m and 500 m. Given this range, you can plot DEM pixels using a gradient of colors. Like this:


	#let's create a plot of our raster
	plot(DEM, main="Digital Elevation Model (DEM)", legend=T)


<figure>
    <a href="{{ site.baseurl }}/images/spatialData/DEMRaster.png"><img src="{{ site.baseurl }}/images/spatialData/DEMRaster.png"></a>
    <figcaption>A DEM is a continuous dataset. Thus we can apply a gradient of colors to the data.</figcaption>
</figure>

By default, R will assign the gradient of colors uniformly across the full range of values in the data. In our case, our DEM has values between 250 and 500. However, we can adjust the "breaks" which represent the numeric locations where the colors change if we want too.


	#add a color map with 5 colors
	col=terrain.colors(5)
	#add breaks to the colormap (6 breaks = 5 segments)
	brk <- c(250, 300, 350, 400,450,500)
	plot(DEM, col=col, breaks=brk, main="DEM with more breaks")

<figure>
    <a href="{{ site.baseurl }}/images/spatialData/DEM_5Breaks.png"><img src="{{ site.baseurl }}/images/spatialData/DEM_5Breaks.png"></a>
    <figcaption>A DEM with more breaks.</figcaption>
</figure>

	#add a color map with 4 colors
	col=terrain.colors(4)
	#add breaks to the colormap (6 breaks = 5 segments)
	 brk <- c(200, 300, 350, 400,500)
	plot(DEM, col=col, breaks=brk, main="DEM with fewer breaks")

<figure>
    <a href="{{ site.baseurl }}/images/spatialData/DEM_FewerBreaks.png"><img src="{{ site.baseurl }}/images/spatialData/DEM_FewerBreaks.png"></a>
    <figcaption>A DEM with fewer breaks.</figcaption>
</figure>

A discrete dataset has a set of unique categories or classes. One example could be landuse classes. The example below shows elevation zones generated using the same DEM.


<figure>
    <a href="{{ site.baseurl }}/images/spatialData/DEM_DiscreteLegend.png"><img src="{{ site.baseurl }}/images/spatialData/DEM_DiscreteLegend.png"></a>
    <figcaption>A DEM with discrete classes. In this case, the classes relate to regions of elevation values.</figcaption>
</figure>


#Cropping Rasters in R

You can crop rasters in R using different methods. You can crop the raster directly 
in the plot area. To do this, first plot the raster. Then define the crop extent 
by clicking twice: 

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
	plot(DEMcrop1)

You can also manually assign the extent coordinates to be used to crop a raster. 
We'll need the extent defined as (`xmin`, `xmax`, `ymin` , `ymax`) to do this. 
This is how we'd crop using a GIS shapefile (with a rectangular shape)

	cropbox2 <-c(255077.3,257158.6,4109614,4110934)
	DEMcrop2 <- crop(DEM, cropbox2)
	plot(DEMcrop2)


## Working with multiple rasters within Raster Stacks and Raster Bricks
We've now loaded a raster into R. We've also made sure we knew the `CRS` 
(coordinate reference system) and extent of the dataset among other key metadata 
attributes. Next, let's create a raster stack from 3 raster images.

A raster stack is a collection of raster layers. Each raster layer in the stack 
needs to be in the same projection (CRS), spatial extent and resolution. You 
might use raster stacks for different reasons. For instance, you might want to 
group a time series of rasters representing precipitation or temperature into 
one R object. 

In this lesson, we will stack 3 bands from a multi-band image together to create 
a final RGB image.

The difficult way to do this is to load our rasters one at a time. But that takes
 a good bit of effort. 

	#import tiffs
	band19 <- "rasterLayers_tif/band19.tif"
	band34 <- "rasterLayers_tif/band34.tif"
	band58 <- "rasterLayers_tif/band58.tif"

We can also use the list.files command to grab all of the files in a directory.
We can use `full.names=TRUE` to ensure that R will store the directory path in our list of
rasters.

	#create list of files to make raster stack
	rasterlist <-  list.files('rasterLayers_tif', full.names=TRUE)

NOTE: If your list of rasters is located in your main R working directory, you can
achieve the same results as above by looking for all files with a '.tif' extension:
 `rasterlist <-  list.files('rasterLayers_tif', full.names=TRUE, pattern="tif")`. 

	#create raster stack
	rgbRaster <- stack(rasterlist)

	#check to see that you've created a raster stack and plot the layers
	rgbRaster
	plot(rgbRaster)



<figure>
   <a href="{{ site.baseurl }}/images/spatialData/rgbStackPlot.png"><img src="{{ site.baseurl }}/images/spatialData/rgbStackPlot.png"></a>
 <figcaption>All rasters in the rasterstack plotted.</figcaption>
</figure>

You can plot an RGB image from the stack. You need to specify the order of the bands when you do this. In our raster stack, band 19 which is the blue band, is first in the list, whereas band 58 which is the red band is last. Thus the order is 3,2,1 to ensure the red band is rendered first as red. 

	#plot an RGB version of the stack
	plotRGB(rgbRaster,r=3,g=2,b=1, scale=800, stretch = "Lin")



You can also explore the data.


	#look at histogram of reflectance values for all rasters
	hist(rgbRaster)


<figure>
   <a href="{{ site.baseurl }}/images/spatialData/RGBhist.png"><img src="{{ site.baseurl }}/images/spatialData/RGBhist.png"></a>
 <figcaption>Histogram of reflectance values for each raster in the raster stack.</figcaption>
</figure>

	#remember that crop function? You can crop all rasters within a raster stack too
	#finally you can crop all rasters within a raster stack!
	rgbCrop <- c(256770.7,256959,4112140,4112284)
	rgbRaster_crop <- crop(rgbRaster, rgbCrop)
	plot(rgbRaster_crop)

<figure>
   <a href="{{ site.baseurl }}/images/spatialData/cropRaster2.png"><img src="{{ site.baseurl }}/images/spatialData/cropRaster2.png"></a>
 <figcaption>Cropped rasters in the raster stack.</figcaption>
</figure>


##Raster Bricks in R
Now we have a list of rasters in a stack. These rasters are all the same extent CRS and resolution but a raster brick will create one raster object in R that contains all of the rasters we can use this object to quickly create RGB images!

	#create raster brick
	RGBbrick <- brick(rgbRaster)
	plotRGB(RGBbrick,r=3,g=2,b=1, scale=800, stretch = "Lin")

## Write a raster to a Geotiff File in R

We can write out the raster in tiff format as well. When we do this it will copy the CRS, extent and resolution information so the data will read properly into a GIS as well. Note that this writes the raster in the order they are in - in the stack. In this case, the blue (band 19) is first but it's looking for the red band first (RGB). One way around this is to generate a new raster stack with the rasters in the proper order - red, green and blue format.

	#Make a new stack in the order we want the data in: 
	finalRGBstack <- stack(rgbRaster$band58,rgbRaster$band34,rgbRaster$band19)
	#write the geotiff - change overwrite=TRUE to overwrite=FALSE if you want to make sure you don't overwrite your files!
	writeRaster(finalRGBstack,"rgbRaster.tiff","GTiff", overwrite=TRUE)
 

## Challenge 

1. Open band 90 in the rasters folder. You might want to look at it in QGIS first compared to the other rasters. Look closely at the extent and pixel size. Does anything look off? Fix what's missing. Export a new geotiff. Do things line up?
