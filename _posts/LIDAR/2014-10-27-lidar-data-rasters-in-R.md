---
layout: post
title: "R: Create a Canopy Height Model from LiDAR derived Rasters (grids) in R"
date:   2014-7-18 20:49:52
createdDate:   2014-07-21 20:49:52
lastModified:   2015-5-11 19:33:52
estimatedTime: 3.0 - 3.5 Hours
packagesLibraries: raster, sp, dplyr, maptools, rgeos
authors: Edmund Hart, Leah A. Wasser
category: remote-sensing
categories: [Remote Sensing]
tags : [lidar, R]
mainTag: lidar
description: "Bring LiDAR-derived raster data (DSM and DTM) into R to create a final canopy height model representing the actual vegetation height with the influence of elevation removed. Then compare lidar derived height (CHM) to field measured tree height to estimate uncertainty in lidar estimates."
permalink: /lidar-data/lidar-data-rasters-in-R/
comments: true
code1: Create_Lidar_CHM.R
image:
  feature: textur2_pointsProfile.png
  credit: National Ecological Observatory Network (NEON)
  creditlink: http://www.neoninc.org
---


<section id="table-of-contents" class="toc">
  <header>
    <h3 >Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->


## Background ##
NEON (National Ecological Observatory Network) will provide derived LiDAR products as one 
of its many free ecological data products. These products will come in a
 [geotiff](http://trac.osgeo.org/geotiff/ "geotiff (read more)") format, which 
is simply a raster format, that is spatially located on the earth. Geotiffs 
can be easily accessed using the `raster` package in R.

A common first analysis using LiDAR data is to derive top of the canopy height values from 
the LiDAR data. These values are often used to track changes in forest structure over time, 
to calculate biomass, and even LAI. Let's dive into the basics of working with raster 
formatted lidar data in R! Before we begin, make sure you've downloaded the data required 
to run the code below.

<div id="objectives">
<h3>What you'll need</h3>
<ol>
<li>R or R studio loaded on your computer </li>
<li><strong>R Libraries:</strong> rgdal, dplyr, raster, maptools, ggplot2 libraries 
installed on you computer.</li>
</ol>

<h2>Data to Download</h2>

Download the raster and <i>insitu</i> collected vegetation structure data:

<a href="http://www.neonhighered.org/Data/LidarActivity/CHM_InSitu_Data.zip" class="btn btn-success"> 
DOWNLOAD NEON  Sample NEON LiDAR Data</a>

<h3>Recommended Reading</h3>
<a href="http://neondataskills.org/remote-sensing/2_LiDAR-Data-Concepts_Activity2/">Overview of DSM, DTM and CHM discussion in the Raster LiDAR Data here.</a>
</div>

> NOTE: The data used in this tutorial were collected by the National Ecological 
> Observatory Network in their <a href="http://www.neoninc.org/science-design/field-sites/san-joaquin" target="_blank">
> Domain 17 California field site</a>. The data are available in full, for 
> no charge, but by request, [from the NEON data portal](http://data.neoninc.org/airborne-data-request "AOP data").


###Required R Packages
Please make sure the following packages are installed: 

[More on Packages in R - Adapted from Software Carpentry.]({{ site.baseurl }}/R/Packages-In-R/ "Packages in R")

    install.packages('raster')
    install.packages('sp')
    install.packages('dplyr')
    install.packages('rgdal')
	install.packages('ggplot2')


##Part 1. Creating a LiDAR derived Canopy Height Model (CHM)
In this activity, we will create a Canopy Height Model. The [canopy height 
model]({{ base.url }} /remote-sensing/2_LiDAR-Data-Concepts_Activity2/), represents
 the actual heights of the trees on the ground. And we can derive the CHM 
by subtracting the ground elevation from the elevation of the top of the surface 
(or the tops of the trees). 

To create the CHM, we will call the raster libraries in R and import the lidar 
derived digital surface model (DSM) and the digital terrain model (DTM). 


	#Make sure your working directory is set properly!
	#The working directory will determine where data are saved. 
	#If you already have an R studio project setup then you can skip this step!
	setwd("yourPathHere")    

    #Import DSM into R 
    library(raster)
    	
	# If the cod ebelow doesn't work, check your working directory path!  
    dsm_f <- "DigitalSurfaceModel/SJER2013_DSM.tif"
    
    dsm <- raster(dsm_f)
    # View info about the raster. Then plot it.
    dsm
    plot(dsm)


Next, we will import the Digital Terrain Model (DTM). The [DTM represents the ground (terrain) elevation]({{ base.url }} /remote-sensing/2_LiDAR-Data-Concepts_Activity2/).


    #import the digital terrain model
    dtm_f <- "DigitalTerrainModel/SJER2013_DTM.tif"
    dtm <- raster(dtm_f)
    plot(dtm)

Finally, we can create the Canopy Height Model (CHM). The[ CHM represents the difference between the DSM and the DTM]({{ base.url }} /remote-sensing/2_LiDAR-Data-Concepts_Activity2/). 
We can perform some basic raster math to calculate the CHM. You can perform the 
SAME raster math in a GIS program like [QGIS](http://www.qgis.org/en/site/ "QGIS").
    
    #Create a function that subtracts one raster from another
    canopyCalc <- function(x, y) {
      return(x - y)
    }
    
	#use the function to create the final CHM
	#then plot it.
    #You could use the overlay function here 
    #chm <- overlay(dsm,dtm,fun = canopyCalc) 
	#but you can also perform matrix math to get the same output.
    chm <- canopyCalc(dsm,dtm)
    plot(chm)


	#write out the CHM in tiff format. We can look at this in any GIS software.
    #NOTE: the code below places the output in an "outputs" folder. 
    #you need to create this folder or else you will get an error.
	writeRaster(chm,"outputs/chm.tiff","GTiff")

We've now successfully created a canopy height model using basic raster math - in 
R! We can bring the `chm.tiff` file into QGIS (or any GIS program) and look at it.  


## Challenge

> 1. Adjust your plot - add breaks at 0, 10, 20 and 30 meters and assign a color 
> map of 3 colors. Add a title to your plot.
> 2. Look at a histogram of your data. Are there sets of breaks that make more 
> sense than 0,10, 20 and 30 meters? Experiment with producing a final map that 
> provides useful information.

### CHALLENGE EXTRA CREDIT!
Share your output map from the challenge above in the comments section at the 
bottom of the page. 

## Part 2. How does our CHM data compare to field measured tree heights?

We now have a canopy height model for our study area in California. However, how 
do the height values extracted from the CHM compare to our laboriously collected, 
field measured canopy height data? Let's find out.

For this activity, we have two csv (comma separate value) files located in the
`InSitu` folder. The first file contains plot centroid location information (X,Y) 
where we measured trees. The second file contains our vegetation structure data 
for each plot. Let's start by plotting the plot locations where we measured trees
 (in red) on a map. 

We will need to convert the plot centroids to a spatial points dataset in R. To do this 
we'll need two additional packages - the spatial package - 
[sp](http://cran.r-project.org/web/packages/sp/index.html "R sp package") - 
and [dplyr](http://cran.r-project.org/web/packages/dplyr/index.html "dplyr").
NOTE: the `sp` library typically installs when you install the raster package. 

Let's get started!

    #load libraries
    library(sp)
    library(dplyr)

    #import the centroid data and the vegetation structure data
	options(stringsAsFactors=FALSE)
	centroids <- read.csv("InSitu/SJERPlotCentroids.csv")
    insitu_dat <- read.csv("InSitu/D17_2013_vegStr.csv")

	#Overlay the centroid points and the stem locations on the CHM plot

	#for example, cex = point size 
    points(centroids$easting,centroids$northing, pch=19, cex = 2, col = 2)
    points(insitu_dat$easting,insitu_dat$northing, pch=19, cex=.5)

> HINT: type in `help(points)` to read about the options for plotting points.
> Also, to see a list of pch values (symbols), check out 
<a href="http://www.endmemo.com/program/R/pchsymbols.php" target=_blank">this website.</a>

###Spatial Data Need a Coordinate Reference System - CRS

Next, assign a CRS to our insitu data. The CRS is information that allows a program like 
QGIS to determine where the data are located, in the world. 
<a href="http://www.sco.wisc.edu/coordinate-reference-systems/coordinate-reference-systems.html" target="_blank">
Read more about CRS here</a>

In this case, we know these data are all in the same projection.

> HINT: to find out what projection our CHM is in, Type `chm@crs`

	#make spatial points object using the CRS (coordinate 
	#reference system) from the CHM and apply it to our plot centroid data.
	centroid_sp <- SpatialPoints(centroids[,4:3],proj4string =CRS(as.character(chm@crs)) )

###Extract CMH data within 20 m radius of each plot centroid.

There are a few ways to go about this task. If your plots are circular, then the extract tool 
will do the job! However, you might need to use a shapefile that contains the plot boundaries
 OR perhaps your plot boundaries are rectangular. Several variations to complete this task 
 are described below.

###Variation 1: Extract Plot Data Using Circle: 20m Radius Plots

	#Insitu sampling took place within 40m x 40m square plots so we use a 20m radius.	
    #Note that below will return a list, so we can extract via lapply
    cent_ovr <- extract(chm,centroid_sp,buffer = 20)

#### Explore The Data Distribution

Before we go any further, it's good to look at the distribution of values we've 
extracted for each plot. Let's create a histogram of the data.

	# create a histogram of all pixels extracted in the second plot
	hist(cent_ovr[[2]])

If we wanted, we could loop through several plots and create histograms using a 
`for loop`.

	# create histograms for the first 5 plots of data
	
	for (i in 1:5) {
	  hist(cent_ovr[[i]], main=(paste("plot",i)))
	}


###Variation 2: Extract CHM values Using a Shapefile

If your plot boundaries are saved in a shapefile, you can use the code below. 
There are two shapefiles in the folder named "PlotCentroid_Shapefile" within the 
zip file that you downloaded at the top of this page. NOTE: to import a shapefile 
using the code below, you'll need to have the `maptools` package installed which 
requires the `rgeos` package. Be sure to install them first:
	
	#install needed packages
	`install.packages(rgeos)`
	`install.packages(maptools)`

	#call the maptools package
	library(maptools)
	#extract CHM data using polygon boundaries from a shapefile
	squarePlot <- readShapePoly("PlotCentroid_Shapefile/SJERPlotCentroids_Buffer.shp")
	cent_ovrMax <- extract(chm, squarePlot, weights=FALSE, fun=max)

Once you've created the `cent_ovrMax` object, you can add the max values to the 
`centroids` data.frame using `centroids$maxHeight <- centr_ovrMax`.

###Variation 3: Derive Square Plot boundaries, then CHM values Using a Shapefile
For see how to extract square plots using a plot centroid value, check out the
 [extracting square shapes activity.]({{ site.baseurl }}/working-with-field-data/Field-Data-Polygons-From-Centroids/ "Polygons")



# Challenge

> One way to setup a layout with multiple plots in R is: `par(mfrow=c(6,3)) `. 
> This code will give you 6 rows of plots with 3 plots in each row. Modify the 
> `for loop` above to plot all 18 histograms. Improve upon the plot's final 
> appearance to make a readable final figure. 


##Working with extracted data 

NOTE: If you followed variation 2 above, you don't need the steps below!

If we use variation ONE above, we create the `centre_ovr` object in R. This object 
contains all of the lidar CHM pixel values contained within our plot boundaries. 
Next, we will create a new column in our `data.frame` that represents the max height value for all pixels
within each plot boundary. To do this, we will use the `sapply` function. The `sapply` function
aggregates elements in the list using a aggregate function such as mean, max or min that we
specify in our code.

## Sapply Example

	# create 3 vectors of numbers
	a <- c(2, 3, 5, 7)
    b <- c(23, 13, 45, 57) 
	c <- c(2, 1, 4, 5) 
	#create a list of lists
	x <- list(a,b,c)

	x
	
The object `x` looks like: 
	
	[[1]]
	[1] 2 3 5 7

	[[2]]
	[1] 23 13 45 57

	[[3]]
	[1] 2 1 4 5

Let's call elements from the list

	# grab the first two elements of the second list in the x object
	x[[2]][1:2]

Calculate summary

	# grab the max value from each list in our object x
	summary <- sapply(x,max)
	
OUTPUT:

	[1]  7 57  5

<a href="http://www.r-bloggers.com/using-apply-sapply-lapply-in-r/" target="_blank">More about
the apply functions in R.</a>

In this case, we'll use the `sapply` command to return the `max` height value for pixels in each plot. 
Given we are working with lidar data, the max value will represent the tallest trees in the plot.

	centroids$chmMax <- sapply(cent_ovr, max)

##Extracting descriptive stats from Insitu Data 
Let's explore two ways to extract stats from a dataset. We can use base R or the 
`dplyr` library. We'll demonstrate both below

###Option 1 - Step by methods to extract stats from our data.frame

First select plots that are also represented in our centroid layer. Quick test - how many 
plots are in the centroid folder?

    insitu_inCentroid <- insitu_dat[insitu_dat$plotid %in% centroids$Plot_ID,] 

    #Optional - create this dataframe using dplyr
    #insitu_inCentroid <- insitu_dat %>% filter(plotid %in% centroids$Plot_ID)

Next, list out plot id results. how many are there?

    unique(insitu_inCentroid$plotid) 

Finally, find the max stem height value for each plot. We will compare this value to the 
max CHM value.
 
    #Here, we use the aggregate function, the arguments of which are: 
    #      the data on which you want to calculate something ~ the grouping variable
    #      the FUNction
    insitu_maxStemHeight <- aggregate( insitu_inCentroid$stemheight ~ 
                insitu_inCentroid$plotid, FUN = max )  
 
    #And make the dataframe prettier by assigning names to the columns
    names(insitu_maxStemHeight) <- c('plotid','max')

    #Optional - create this dataframe using dplyr
    #insitu_maxStemHeight <- insitu_inCentroid %>% 
    #	group_by(plotid) %>% 
    #	summarise(max = max(stemheight))

###Option 2 - Extracting Data Using one Line of Code!
We can combine the above steps into one line of code that takes care of the data
aggregation and summary components. We can take full advantage of the `dplyr`
to do this OR we can use base R.
	
	#add the max and 95th percentile height value for all trees within each plot
    insitu <- cbind(insitu_maxStemHeight,'quant'=tapply(insitu_inCentroid$stemheight, 
                    insitu_inCentroid$plotid, quantile, prob = 0.95))

    #Optional - create this dataframe using dplyr
	#insitu <- insitu_dat %>% filter(plotid %in% centroids$Plot_ID) %>% 
	#	      group_by(plotid) %>% 
	#	      summarise(max = max(stemheight), quant = quantile(stemheight,.95))

	#assign the final output to a column in our centroids object
	centroids$insitu <- insitu$max

### Plot Data (CHM vs Measured)
Let's create a plot that illustrates the relationship between in situ measured 
max canopy height values and lidar derived max canopy height values.

	ggplot(centroids,aes(x=chmMax, y =insitu )) + geom_point() + theme_bw() + 
	     ylab("Maximum measured height") + xlab("Maximum LiDAR pixel")+
	     geom_abline(intercept = 0, slope=1)+xlim(0, max(centroids[,6:7])) + 
	     ylim(0,max(centroids[,6:7]))

We can also add a regression fit to our plot. Explore the GGPLOT options and 
customize your plot.

	#plot with regression fit
	p <- ggplot(centroids,aes(x=chmMax, y =insitu )) + geom_point() + 
	    ylab("Maximum Measured Height") + xlab("Maximum LiDAR Height")+
	    geom_abline(intercept = 0, slope=1)+
	    geom_smooth(method=lm) +
	    xlim(0, max(centroids[,6:7])) + ylim(0,max(centroids[,6:7])) 
	
	p + theme(panel.background = element_rect(colour = "grey")) + 
	    ggtitle("LiDAR CHM Derived vs Measured Tree Height") +
	  theme(plot.title=element_text(family="sans", face="bold", size=20, vjust=1.9)) +
	  theme(axis.title.y = element_text(family="sans", face="bold", size=14, angle=90, hjust=0.54, vjust=1)) +
	  theme(axis.title.x = element_text(family="sans", face="bold", size=14, angle=00, hjust=0.54, vjust=-.2))

Your final plot should look something like this:

![CHM Plot]({{ site.baseurl }}/images/chmPlot.png)

You have now successfully created a canopy height model using lidar data AND compared lidar 
derived vegetation height, within plots, to actual measured tree height data!


#Challenge 

> Create a plot of LiDAR 95th percentile value vs *insitu* max height. Or Lidar 95th 
> percentile vs *insitu* 95th percentile. Add labels to your plot. Customize the
> colors, fonts and the look of your plot. If you are happy with the outcome, share
> your plot in the comments below! 

## Plot.ly Interactive Plotting

## Create Interactive plot.ly map

Plot.ly is a free to use, online interactive data viz site. If you have the 
plot.ly library installed, you can quickly export a ggplot graphic into plot.ly!
 (NOTE: it also works for python matplotlib)!! To use plotly, you need to setup 
an account. Once you've setup an account, you can get your key from the plot.ly 
site to make the code below work.

	library(plotly)
	#setup your plot.ly credentials
	set_credentials_file("yourUserName", "yourKey")
	p <- plotly(username="yourUserName", key="yourKey")

	#generate the plot
	py <- plotly()
	py$ggplotly()


Check out the results! 

NEON Remote Sensing Data compared to NEON Terrestrial Measurements for the SJER Field Site

<iframe width="460" height="293" frameborder="0" seamless="seamless" scrolling="no" src="https://plot.ly/~leahawasser/24.embed?width=460&height=293"></iframe>
