---
syncID: f578b1b20ef9483183a8c0abbf417440
title: "Data Activity: Visualize Elevation Change using LiDAR in R to Better Understand the 2013 Colorado Floods"
description: This tutorial teaches how to use Digital Terrain Models derived from LiDAR data to create Digital Elevation Models of Differences that allow us to measure the change in elevation of an area after a disturbance event.	
dateCreated: 2015-05-18
authors: Leah A. Wasser, Megan A. Jones
contributors:	
estimatedTime:	
packagesLibraries: rgdal, raster
topics: time-series, meteorology, data-viz
languagesTool: R
dataProduct:
code1: /teaching-modules/disturb-events-co13/NEON-Boulder-Flood-LiDAR-in-R.R	
tutorialSeries:
urlTitle: da-viz-neon-lidar-co13flood-R
---

{% include _toc.html %}

This tutorial focuses on how to visualize digital elevation models derived from
LiDAR data in R. The tutorial is part of the Data Activities that can be used 
with the 
<a href="{{ site.basurl }}/teaching-modules/disturb-events-co13/" target="_blank"> *Ecological Disturbance Teaching Module*</a>.

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

* Plot raster objects in R (this activity is not designed to be an introduction 
to raster objects in R)
* Create a Digital Elevation Model of Difference (DoD).
* Specify color palettes and breaks when plotting rasters in R. 

### Things You'll Need To Complete This Lesson
Please be sure you have the most current version of R and, preferably,
RStudio to write your code.

 **R Skill Level:** Intermediate - To succeed in this tutorial, you will need to
have basic knowledge for use of the R software program.  

### R Libraries to Install:

* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`


### Data to Download
The data for this data activity can be downloaded directly from the 
<a href="https://ndownloader.figshare.com/files/6780978"> NEON Data Skills account on FigShare</a>. 

So that we all have organized data in the same location, create a `data` directory 
(folder) within your `Documents` directory. Simply put the 
entire unzipped directory in the `data` directory you just created. If you choose to save 
elsewhere you will need to modify the directions below to set your working 
directory accordingly.

</div>


 
## Research Question: How do We Measure Changes in Terrain?

<iframe width="560" height="315" src="https://www.youtube.com/embed/m7SXoFv6Sdc?rel=0&start=105" frameborder="0" allowfullscreen></iframe>

#### Questions
1. How can LiDAR data be collected?  
2. How might we use LiDAR to help study the 2013 Colorado Floods?

### Additional LiDAR Background Materials
This data activity below assumes basic understanding of remote sensing and 
associated landscape models and the use of raster data and plotting raster objects
in R. Consider using these other resources if you wish to gain more background 
in these areas. 

#### Using LiDAR Data

LiDAR data can be used to create many different models of a landscape.  This
brief lesson on 
<a href="http://neondataskills.org/remote-sensing/2_LiDAR-Data-Concepts_Activity2/" target="_blank">
"What is a CHM, DSM and DTM? About Gridded, Raster LiDAR Data"</a> 
explores three important landscape models that are commonly used. 

<figure>
	<a href="{{ site.baseurl }}/images/dc-spatial-raster/lidarTree-height.png">
  <img src="{{ site.baseurl }}/images/dc-spatial-raster/lidarTree-height.png"></a>
  <figcaption>Digital Terrain Models, Digital Surface Models and Canopy Height
  	Models are three common LiDAR-derived data products. The digital terrain model
  	allows scientists to study changes in terrain (topography) over time.
	</figcaption>
</figure>

1. How might we use a CHM, DSM or DTM model to better understand what happened
in the 2013 Colorado Flood? 
2. Would you use only one of the models or could you use two or more of them
together?

In this Data Activity, we will be using Digital Terrain Models (DTMs).

#### More Details on LiDAR

If you are particularly interested in how LiDAR works consider taking a closer
look at how the data is collected and represented by going through this tutorial
on 
<a href="http://neondataskills.org/remote-sensing/1_About-LiDAR-Data-Light-Detection-and-Ranging_Activity1/" target="_blank"> "Light Detection and Ranging."</a> 


## Digital Terrain Models 

We can use a digital terrain model (DTM) to view the surface of the earth. By 
comparing a DTM from before a disturbance event with one from after a disturbance
event, we can get measurements of where the landscape changed.  

First, we need to load the necessary R packages to work with raster files and 
set our working directory to the location of our data. 


    # load libraries
    library(raster)   # work with raster files
    library(rgdal)    # work with raster files
    
    # set working directory to ensure R can find the file we wish to import
    #setwd("working-dir-path-here")

Then we can read in two DTMs. The first DTM `preDTM3.tif` is a model from data
collected 26-27 June 2013 and the `postDTM3.tif` is a model from data collected
on 8 October 2013.  


    # Load DTMs into R
    DTM_pre <- raster("disturb-events-co13/lidar/pre-flood/preDTM3.tif")
    DTM_post <- raster("disturb-events-co13/lidar/post-flood/postDTM3.tif")
    
    # View raster structure
    DTM_pre

    ## class       : RasterLayer 
    ## dimensions  : 2000, 2000, 4e+06  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 473000, 475000, 4434000, 4436000  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=13 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## data source : /Users/mjones01/Documents/data/disturb-events-co13/lidar/pre-flood/preDTM3.tif 
    ## names       : preDTM3

    DTM_post

    ## class       : RasterLayer 
    ## dimensions  : 2000, 2000, 4e+06  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 473000, 475000, 4434000, 4436000  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=13 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## data source : /Users/mjones01/Documents/data/disturb-events-co13/lidar/post-flood/postDTM3.tif 
    ## names       : postDTM3

Among the information we now about our data from looking at the raster structure, 
is that the units are in **meters** for both rasters.  

Hillshade layers are models created to add visual depth to maps. It represents
what the terrain would look like in shadow with the sun at a specific azimuth. 
The default azimuth for many hillshades is 315 degrees -- to the NW.  


    # import DSM hillshade
    DTMpre_hill <- raster("disturb-events-co13/lidar/pre-flood/preDTMhill3.tif")
    DTMpost_hill <- raster("disturb-events-co13/lidar/post-flood/postDTMhill3.tif")

Now we can plot the raster objects (DTM & hillshade) together by using `add=TRUE`
when plotting the second plot. To be able to see the first (hillshade) plot,
through the second (DTM) plot, we also set a value between 0 (transparent) and 1 
(not transparent) for the `alpha=` argument. 


    # plot Pre-flood w/ hillshade
    plot(DTMpre_hill,
            col=grey(1:100/100),  # create a color ramp of grey colors for hillshade
            legend=FALSE,         # no legend, we don't care about the grey of the hillshade
            main="Four Mile Canyon Creek, Boulder County\nPre-Flood",
            axes=FALSE)           # makes for a cleaner plot, if the coordinates aren't necessary
    
    plot(DTM_pre, 
            axes=FALSE,
            alpha=0.5,   # sets how transparent the object will be (0=transparent, 1=not transparent)
            add=T)  # add=TRUE (or T), add plot to the previous plotting frame

![ ]({{ site.baseurl }}/images/rfigs/teaching-modules/disturb-events-co13/NEON-Boulder-Flood-LiDAR-in-R/plot-rasters-1.png)

    # plot Post-flood w/ hillshade
    # note, no add=T in this code, so new plotting frame. 
    plot(DTMpost_hill,
            col=grey(1:100/100),  
            legend=FALSE,
            main="Four Mile Canyon Creek, Boulder County\nPost-Flood",
            axes=FALSE)
    
    plot(DTM_post, 
            axes=FALSE,
            alpha=0.5,
            add=T)

![ ]({{ site.baseurl }}/images/rfigs/teaching-modules/disturb-events-co13/NEON-Boulder-Flood-LiDAR-in-R/plot-rasters-2.png)

#### Questions? 

1. What does the color scale represent? 
1. Can you see changes in these two plots?  
1. Zoom in on the main stream bed.  Are changes more visible?  Can you tell 
where erosion has occurred?  Where soil deposition has occurred?  

### Digital Elevation Model of Difference (DoD)

A **D**igital Elevation Model **o**f **D**ifference (DoD) is a model of the 
change (or difference) between two other digital elevation models - in our case
DTMs.  


    # DoD: erosion to be neg, deposition to be positive, therefore post - pre
    DoD <- DTM_post-DTM_pre
    
    plot(DoD,
            main="Digital Elevation Model of Difference (DoD)",
            axes=FALSE)

![ ]({{ site.baseurl }}/images/rfigs/teaching-modules/disturb-events-co13/NEON-Boulder-Flood-LiDAR-in-R/create-difference-model-1.png)

Here we have our DoD, but it is a bit hard to read. What does the scale bar tell
us?  

Everything in the yellow shades are close to 0m of elevation change, those areas
toward green are up to 10m increase of elevation, and those areas to red and 
white are a 5m or more decrease in elevation.  

We can see a distribution of the values better by viewing a histogram of all
the values in the `DoD` raster object. 


    # histogram of values in DoD
    hist(DoD)

![ ]({{ site.baseurl }}/images/rfigs/teaching-modules/disturb-events-co13/NEON-Boulder-Flood-LiDAR-in-R/hist-DoD-1.png)

Most of the areas have a very small elevation change. To make the map easier to
read, we can do two things. 

1. **Set breaks for where we want the color to represent:** The plot of the DoD 
above uses a continuous scale to show the gradation between the loss of 
elevation and the gain in elevation. While this provides a great deal of 
information, in this case with much of the change around 0 and only a few outlying 
values near -5m or 10m a categorical scale could help us visualize the data better.
In the plotting code we can set this with the `breaks=` argument in the `plot()`
function. Let's use breaks of -5, -1, -0.5, 0.5, 1, 10 -- which will give use 5
categories. 

2. **Change the color scheme:** We can specify a color for each of elevation
categories we just specified with the `breaks`. 
<a href="http://colorbrewer2.org/" target="_blank"> 
ColorBrewer 2.0</a> is a great reference for choosing mapping color palettes and 
provide the hex codes we need for specifying the colors of the map. Once we've
chosen appropriate colors, we can create a vector of those colors and then use
that vector with the `col=` argument in the `plot()` function to specify these. 

Let's now implement these two changes in our code. 


    # Color palette for 5 categories
    difCol5 = c("#d7191c","#fdae61","#ffffbf","#abd9e9","#2c7bb6")
    
    # Alternate palette for 7 categories - try it out!
    #difCol7 = c("#d73027","#fc8d59","#fee090","#ffffbf","#e0f3f8","#91bfdb","#4575b4")
    
    # plot hillshade first
    plot(DTMpost_hill,
            col=grey(1:100/100),  # create a color ramp of grey colors
            legend=FALSE,
            main="Elevation Change Post Flood\nFour Mile Canyon Creek, Boulder County",
            axes=FALSE)
    
    # add the DoD to it with specified breaks & colors
    plot(DoD,
            breaks = c(-5,-1,-0.5,0.5,1,10),
            col= difCol5,
            axes=FALSE,
            alpha=0.4,
            add =T)

![ ]({{ site.baseurl }}/images/rfigs/teaching-modules/disturb-events-co13/NEON-Boulder-Flood-LiDAR-in-R/pretty-diff-model-1.png)

#### Question
Do you think this is the best color scheme or set point for the breaks? Create
a new map that uses different colors and/or breaks.  Does it more clearly show 
patterns than this plot? 

## Optional Extension: Crop to Defined Area 

If we want to crop the map to a smaller area, say the mouth of the canyon 
where most of the erosion and deposition appears to have occurred, we can crop 
by using known geographic locations (in the same CRS as the raster object) or
by manually drawing a box. 

#### Method 1: Manually draw cropbox 


    # plot the rasters you want to crop from 
    plot(DTMpost_hill,
            col=grey(1:100/100),  # create a color ramp of grey colors
            legend=FALSE,
            main="Four Mile Canyon Creek, Boulder County\nPre-Flood",
            axes=FALSE)
    
    plot(DoD,
            breaks = c(-5,-1,-0.5,0.5,1,10),
            col= difCol5,
            axes=FALSE,
            alpha=0.4,
            add =T)
    
    # crop by designating two opposite corners
    cropbox1<-drawExtent()  

<figure>
	<a href="{{ site.baseurl }}/images/disturb-events-co13/drawExtent.png">
  <img src="{{ site.baseurl }}/images/disturb-events-co13/drawExtent.png"></a>
</figure>

After executing the `drawExtent()` function, we now physically click on the plot
at the two opposite corners of the box you want to crop to. You should see a 
box drawn on the plot at this point.

When we call this new object, we can view the new extent. 


    # view the extent of the cropbox1
    cropbox1

    ## class       : Extent 
    ## xmin        : 474276.7 
    ## xmax        : 474392 
    ## ymin        : 4434622 
    ## ymax        : 4434766

It is a good idea to write this new extent down, so that you can use the extent
again the next time you use the script. 

#### Method 2: Define the cropbox

If you know the desired extent of the object you can also use it to crop the box, 
by creating an object that is a vector of the x min, x max, y min, and y max of
the desired area. 


    # desired coordinates of the box
    cropbox2<-c(473792.6,474999,4434526,4435453)

Once you have the crop box defined, either manually or using the coordinate, you 
then crop the desired layer to the crop box. 


    # crop desired layers to this cropbox
    DTM_pre_crop <- crop(DTM_pre, cropbox2)
    DTM_post_crop <- crop(DTM_post, cropbox2)
    DTMpre_hill_crop <- crop(DTMpre_hill,cropbox2)
    DTMpost_hill_crop <- crop(DTMpost_hill,cropbox2)
    DoD_crop <- crop(DoD, cropbox2)
    
    # plot all again using the cropped layers
    
    # PRE
    plot(DTMpre_hill_crop,
            col=grey(1:100/100),  # create a color ramp of grey colors
            legend=FALSE,
            main="Four Mile Canyon Creek, Boulder County\nPre-Flood",
            axes=FALSE)
    # note \n in the title forces a line break in the title
    plot(DTM_pre_crop, 
            axes=FALSE,
            alpha=0.5,
            add=T)

![ ]({{ site.baseurl }}/images/rfigs/teaching-modules/disturb-events-co13/NEON-Boulder-Flood-LiDAR-in-R/plot-crop-raster-1.png)

    # POST
    # plot Post-flood w/ hillshade
    plot(DTMpost_hill_crop,
            col=grey(1:100/100),  # create a color ramp of grey colors
            legend=FALSE,
            main="Four Mile Canyon Creek, Boulder County\nPost-Flood",
            axes=FALSE)
    
    plot(DTM_post_crop, 
            axes=FALSE,
            alpha=0.5,
            add=T)

![ ]({{ site.baseurl }}/images/rfigs/teaching-modules/disturb-events-co13/NEON-Boulder-Flood-LiDAR-in-R/plot-crop-raster-2.png)

    # CHANGE - DoD
    plot(DTMpost_hill_crop,
            col=grey(1:100/100),  # create a color ramp of grey colors
            legend=FALSE,
            main="Elevation Change Post Flood\nFour Mile Canyon Creek, Boulder County",
            axes=FALSE)
    
    plot(DoD_crop,
            breaks = c(-5,-1,-0.5,0.5,1,10),
            col= difCol5,
            axes=FALSE,
            alpha=0.4,
            add =T)

![ ]({{ site.baseurl }}/images/rfigs/teaching-modules/disturb-events-co13/NEON-Boulder-Flood-LiDAR-in-R/plot-crop-raster-3.png)

Now you have a graphic of your particular area of interest. 

## Additional Resources

* How could you create a DoD, if you only have LiDAR from a single time point 
but historical maps?  Check out 
<a href="http://people.cas.sc.edu/hodgsonm/Published_Articles_PDF/James_Hodgson_Ghoshal_Latiolais_DEM%20DIfferencing_Geomorphology2012.pdf" target="_blank"> Allen James et al. 2012. Geomorphic change detection using historic maps and 
DEM differencing: The temporal dimension of geospatial analysis. Geomorphology 137:181-198</a>. 

***
Return to the 
<a href="{{ site.basurl }}/teaching-modules/disturb-events-co13/detailed-lesson"> *Ecological Disturbance Teaching Module* by clicking here</a>.

