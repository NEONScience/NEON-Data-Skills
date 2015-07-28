---
layout: post
title: "R: Create a Canopy Height Model from LiDAR derived Rasters (grids) in R"
date:   2014-7-18 20:49:52
createdDate:   2014-07-21 20:49:52
lastModified:   2015-07-23 19:33:52
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: raster, sp, dplyr, maptools, rgeos
authors: Edmund Hart, Leah A. Wasser
category: remote-sensing
categories: [Remote Sensing]
tags : [lidar, R]
mainTag: lidar
description: "Bring LiDAR-derived raster data (DSM and DTM) into R to create a final canopy height model representing the actual vegetation height with the influence of elevation removed. Then compare lidar derived height (CHM) to field measured tree height to estimate uncertainty in lidar estimates."
permalink: /lidar-data/lidar-data-rasters-in-R/
comments: true
code1: /R/2015-06-30-Create-Lidar-CHM-R.R
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
is a `tif` raster format that is spatially located on the earth. Geotiffs 
can be accessed using the `raster` package in R.

A common first analysis using LiDAR data is to derive top of the canopy height values from 
the LiDAR data. These values are often used to track changes in forest structure over time, 
to calculate biomass, and even LAI. Let's dive into the basics of working with raster 
formatted lidar data in R! Before we begin, make sure you've downloaded the data required 
to run the code below.

<div id="objectives">
<h3>What you'll need</h3>

You will need the most current version of R or R studio loaded on your computer 
to complete this lesson.

<h3>R Libraries to Install:</h3>
<ul>
<li><strong>raster:</strong> <code> install.packages("raster")</code></li>
<li><strong>sp:</strong> <code> install.packages("sp")</code></li>
<li><strong>rgdal:</strong> <code> install.packages("rgdal")</code></li>
<li><strong>dplyr:</strong> <code> install.packages("dplyr")</code></li>
<li><strong>ggplot2:</strong> <code> install.packages("ggplot2")</code></li>
</ul>

<a href="{{ site.baseurl }}/R/Packages-In-R/" target="_blank"> 
More on Packages in R - Adapted from Software Carpentry.</a>

<h2>Data to Download</h2>

Download the raster and <i>insitu</i> collected vegetation structure data:

<a href="http://www.neonhighered.org/Data/LidarActivity/CHM_InSitu_Data.zip" class="btn btn-success"> 
DOWNLOAD NEON  Sample NEON LiDAR Data</a>

<h3>Recommended Reading</h3>
<a href="http://neondataskills.org/remote-sensing/2_LiDAR-Data-Concepts_Activity2/">
What is a CHM, DSM and DTM? About Gridded, Raster LiDAR Data</a>
</div>

> NOTE: The data used in this tutorial were collected by the National Ecological 
> Observatory Network in their <a href="http://www.neoninc.org/science-design/field-sites/san-joaquin" target="_blank">
> Domain 17 California field site</a>. The data are available in full, for 
> no charge, but by request, [from the NEON data portal](http://data.neoninc.org/airborne-data-request "AOP data").


##Part 1. Creating a LiDAR derived Canopy Height Model (CHM)
In this lesson, we will create a Canopy Height Model. The [canopy height 
model]({{ base.url }} /remote-sensing/2_LiDAR-Data-Concepts_Activity2/), represents
 the actual heights of the trees on the ground. And we can derive the CHM 
by subtracting the ground elevation from the elevation of the top of the surface 
(or the tops of the trees). 

To create the CHM, we will use the `raster` library in `R` and import the lidar 
derived digital surface model (DSM) and the digital terrain model (DTM). 


    #Make sure your working directory is set properly!
    #The working directory will determine where data are saved. 
    #If you already have an R studio project setup then you can skip this step!
    #setwd("yourPathHere")    
    
    #Import DSM into R 
    library(raster)
    library(rgdal)
    
    # If the code below doesn't work, check your working directory path!  
    dsm_f <- "DigitalSurfaceModel/SJER2013_DSM.tif"
    
    dsm <- raster(dsm_f)
    # View info about the raster. Then plot it.
    dsm

    ## class       : RasterLayer 
    ## dimensions  : 5060, 4299, 21752940  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 254570, 258869, 4107302, 4112362  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## data source : /Users/law/Documents/1_Workshops/ESA_2015/DigitalSurfaceModel/SJER2013_DSM.tif 
    ## names       : SJER2013_DSM

    #plot the DSM
    myColor=terrain.colors(200)
    plot(dsm, col = myColor, main="LiDAR Digital Surface Model")

![ ]({{ site.baseurl }}/images/rfigs/2015-06-30-Create-Lidar-CHM-R/import-plot-DSM-1.png) 

Next, we will import the Digital Terrain Model (DTM). The 
[DTM represents the ground (terrain) elevation]({{ base.url }} /remote-sensing/2_LiDAR-Data-Concepts_Activity2/).


    #import the digital terrain model
    dtm_f <- "DigitalTerrainModel/SJER2013_DTM.tif"
    dtm <- raster(dtm_f)
    plot(dtm, col=myColor, main="LiDAR Digital Terrain Model")

![ ]({{ site.baseurl }}/images/rfigs/2015-06-30-Create-Lidar-CHM-R/plot-DTM-1.png) 

Finally, we can create the Canopy Height Model (CHM). The [CHM represents the difference between the DSM and the DTM]({{ base.url }} /remote-sensing/2_LiDAR-Data-Concepts_Activity2/). 
We can perform some basic raster math to calculate the CHM. You can perform the 
SAME raster math in a GIS program like [QGIS](http://www.qgis.org/en/site/ "QGIS").


    #use raster math to create CHM
    chm <- dsm - dtm
    
    # Create a function that subtracts one raster from another
    #canopyCalc <- function(x, y) {
    #  return(x - y)
    #  }
        
    #use the function to create the final CHM
    #then plot it.
    #You could use the overlay function here 
    #chm <- overlay(dsm,dtm,fun = canopyCalc) 
    #but you can also perform matrix math to get the same output.
    #chm <- canopyCalc(dsm,dtm)
    
    
    plot(chm, main="LiDAR Canopy Height Model")

![ ]({{ site.baseurl }}/images/rfigs/2015-06-30-Create-Lidar-CHM-R/calculate-plot-CHM-1.png) 

We can write out the raster as a geoTiff using the `writeRaster` function.




    #write out the CHM in tiff format. We can look at this in any GIS software.
    #note that you need the rdgal library to use this function.
    writeRaster(chm,"chm.tiff","GTiff")

We've now successfully created a canopy height model using basic raster math - in 
R! We can bring the `chm.tiff` file into QGIS (or any GIS program) and look at it.  


###CHALLENGES

> 1. Adjust your plot - add breaks at 0, 10, 20 and 30 meters and assign a color 
> map of 3 colors. Add a title to your plot.
> 2. Look at a histogram of your data. Are there sets of breaks that make more 
> sense than 0, 10, 20 and 30 meters? Experiment with producing a final map that 
> provides useful information.
> 3. Convert the CHM from meters to feet. Plot it using breaks that make sense for
> the data. Then export is as a geotiff.
> 4. In the `CanopyHeightModel` folder, you will find an already processed CHM called 
> `SJER2013_CHM.tif`. The processing that was used to create this CHM, is different from
> what we did above in this tutorial. Import that file in `R` and call it `CHM_NEON`. 
> Calculate the difference between the CHM that you created above and this already 
> created raster. Do you notice any differences between the 2 rasters? How significant
> are the differences?

### EXTRA CREDIT!
Share your output map from the challenge above in the comments section at the 
bottom of the page. 

## Part 2. How does our CHM data compare to field measured tree heights?

We now have a canopy height model for our study area in California. However, how 
do the height values extracted from the CHM compare to our laboriously collected, 
field measured canopy height data? To figure this out, we will use manually collected
tree height data, measured within circular plots across our study area. We will compare
the maximum measured tree height value to the maximum lidar derived height value 
for each circular plot using regression.

For this activity, we have two `csv` (comma separate value) files located in the
`InSitu_Data` folder. The first file contains plot centroid location information (X,Y) 
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

    ## 
    ## Attaching package: 'dplyr'
    ## 
    ## The following objects are masked from 'package:raster':
    ## 
    ##     intersect, select, union
    ## 
    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag
    ## 
    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    #import the centroid data and the vegetation structure data
    options(stringsAsFactors=FALSE)
    centroids <- read.csv("InSitu_Data/SJERPlotCentroids.csv")
    insitu_dat <- read.csv("InSitu_Data/D17_2013_vegStr.csv")
    
    #Overlay the centroid points and the stem locations on the CHM plot
    #plot the chm
    myCol=terrain.colors(6)
    plot(chm,col=myCol, main="Plot Locations", breaks=c(-5,0,5,10,40))
    #for example, cex = point size 
    #pch 0 = square
    points(centroids$easting,centroids$northing, pch=0, cex = 2, col = 2)
    points(insitu_dat$easting,insitu_dat$northing, pch=19, cex=.5)

![ ]({{ site.baseurl }}/images/rfigs/2015-06-30-Create-Lidar-CHM-R/read-plot-data-1.png) 

> HINT: type in `help(points)` to read about the options for plotting points.
 
To see a list of pch values (symbols), check out 
<a href="http://www.endmemo.com/program/R/pchsymbols.php" target="_blank">this website.</a>

###Spatial Data Need a Coordinate Reference System - CRS

Next, assign a CRS to our insitu data. The CRS is information that allows a program like 
QGIS to determine where the data are located, in the world. 
<a href="http://www.sco.wisc.edu/coordinate-reference-systems/coordinate-reference-systems.html" target="_blank">
Read more about CRS here</a>

In this case, we know these data are all in the same projection. Remember that 
we can quickly figure out what projection our CHM is in, using `chm@crs`.


    #make spatial points data.frame using the CRS (coordinate 
    #reference system) from the CHM and apply it to our plot centroid data.
    centroid_spdf = SpatialPointsDataFrame(centroids[,4:3],proj4string=chm@crs, centroids)

###Extract CMH data within 20 m radius of each plot centroid.

Next, we will create a boundary region (called a buffer) representing the spatial
extent of each plot (where trees were measured). We will then extract all CHM pixels
that fall within the plot boundary to use to estimate tree height for that plot.

There are a few ways to go about this task. If your plots are circular, then the 
extract tool will do the job! Our plots are circular so that is what we'll use.


<figure>
    <img src="{{ site.baseurl }}/images/spatialData/BufferCircular.png">
    <figcaption>The extract function in R allows you to specify a circular buffer 
    radius around an x,y point location. Values for all pixels in the specified 
    raster that fall within the circular buffer are extracted. In this case, we
    will tell R to extract the maximum value of all pixels using the fun=max
    command.
    </figcaption>
</figure>

### Variation 1: Extract Plot Data Using Circle: 20m Radius Plots


    # Insitu sampling took place within 40m x 40m square plots so we use a 20m radius.	
    # Note that below will return a dataframe containing the max height
    # calculated from all pixels in the buffer for each plot
    cent_ovr <- extract(chm,centroid_spdf,buffer = 20, fun=max, df=TRUE)
    
    #grab the names of the plots from the centroid_spdf
    cent_ovr$plot_id <- centroid_spdf$Plot_ID  
    #fix the column names
    names(cent_ovr) <- c('ID','chmMaxHeight','plot_id')
    
    #merge the chm data into the centroids data.frame
    centroids <- merge(centroids, cent_ovr, by.x = 'Plot_ID', by.y = 'plot_id')
    
    #have a look at the centroids dataFrame
    head(centroids)

    ##    Plot_ID  Point northing  easting Remarks ID chmMaxHeight
    ## 1 SJER1068 center  4111568 255852.4      NA  1    18.940002
    ## 2  SJER112 center  4111299 257407.0      NA  2    24.189972
    ## 3  SJER116 center  4110820 256838.8      NA  3    13.299988
    ## 4  SJER117 center  4108752 256176.9      NA  4    10.989990
    ## 5  SJER120 center  4110476 255968.4      NA  5     5.690002
    ## 6  SJER128 center  4111389 257078.9      NA  6    19.079987

#### If you want to explore The Data Distribution

If you want to explore the data distribution of pixel height values in each plot, 
you could remove the `fun` call to max and generate a list. 
`cent_ovrList <- extract(chm,centroid_sp,buffer = 20)`. It's good to look at the 
distribution of values we've extracted for each plot. Then you could generate a 
histogram for each plot `hist(cent_ovrList[[2]])`. If we wanted, we could loop 
through several plots and create histograms using a `for loop`.


    #cent_ovrList <- extract(chm,centroid_sp,buffer = 20)
    # create histograms for the first 5 plots of data
    #for (i in 1:5) {
    #  hist(cent_ovrList[[i]], main=(paste("plot",i)))
    #  }

# Challenge

> One way to setup a layout with multiple plots in R is: `par(mfrow=c(6,3)) `. 
> This code will give you 6 rows of plots with 3 plots in each row. Modify the 
> `for loop` above to plot all 18 histograms. Improve upon the plot's final 
> appearance to make a readable final figure. 

###Variation 2: Extract CHM values Using a Shapefile

If your plot boundaries are saved in a shapefile, you can use the code below. 
There are two shapefiles in the folder named "PlotCentroid_Shapefile" within the 
zip file that you downloaded at the top of this page. NOTE: to import a shapefile 
using the code below, you'll need to have the `maptools` package installed which 
requires the `rgeos` package. Be sure to install them first:


    #install needed packages
    #install.packages(rgeos)
    #install.packages(maptools)
    
    #call the maptools package
    #library(maptools)
    #extract CHM data using polygon boundaries from a shapefile
    #squarePlot <- readShapePoly("PlotCentroid_Shapefile/SJERPlotCentroids_Buffer.shp")
    #centroids$chmMaxShape <- extract(chm, squarePlot, weights=FALSE, fun=max)

###Variation 3: Derive Square Plot boundaries, then CHM values around a point
For see how to extract square plots using a plot centroid value, check out the
 [extracting square shapes activity.]({{ site.baseurl }}/working-with-field-data/Field-Data-Polygons-From-Centroids/ "Polygons")
 
 <figure>
    <img src="{{ site.baseurl }}/images/spatialData/BufferSquare.png">
    <figcaption>If you had square shaped plots, the code in the link above would
    extract pixel values within a square shaped buffer.
    </figcaption>
</figure>



##Extract descriptive stats from Insitu Data 
In our final step, we will extract summary height values from our field data. 
We will use the `dplyr` library to do this efficiently. We'll demonstrate both below

### Extract stats from our data.frame using DPLYR

First let's see how many plots are in the centroid folder.

    # How many plots are there?
    unique(insitu_dat$plotid) 

    ##  [1] "SOAP43"   "SOAP331"  "SOAP139"  "SOAP1343" "SOAP143"  "SOAP63"  
    ##  [7] "SOAP1563" "SOAP1695" "SOAP255"  "SOAP1611" "SOAP283"  "SOAP1515"
    ## [13] "SOAP223"  "SOAP555"  "SOAP299"  "SOAP991"  "SOAP95"   "SOAP187" 
    ## [19] "SJER128"  "SJER2796" "SJER272"  "SJER112"  "SJER1068" "SJER916" 
    ## [25] "SJER361"  "SJER3239" "SJER824"  "SJER8"    "SJER952"  "SJER116" 
    ## [31] "SJER117"  "SJER37"   "SJER4"    "SJER192"  "SJER36"   "SJER120"


Next, find the maximum MEASURED stem height value for each plot. We will compare 
this value to the max CHM value.


    library(dplyr)
    
    #get list of unique plot id's 
    unique(insitu_dat$plotid) 

    ##  [1] "SOAP43"   "SOAP331"  "SOAP139"  "SOAP1343" "SOAP143"  "SOAP63"  
    ##  [7] "SOAP1563" "SOAP1695" "SOAP255"  "SOAP1611" "SOAP283"  "SOAP1515"
    ## [13] "SOAP223"  "SOAP555"  "SOAP299"  "SOAP991"  "SOAP95"   "SOAP187" 
    ## [19] "SJER128"  "SJER2796" "SJER272"  "SJER112"  "SJER1068" "SJER916" 
    ## [25] "SJER361"  "SJER3239" "SJER824"  "SJER8"    "SJER952"  "SJER116" 
    ## [31] "SJER117"  "SJER37"   "SJER4"    "SJER192"  "SJER36"   "SJER120"

    #looks like we have data for two sites
    unique(insitu_dat$siteid) 

    ## [1] "SOAP" "SJER"

    plotsSJER <- insitu_dat
    
    #we've got some plots for SOAP which is a different region.
    #let's just select plots with SJER data
    #plotsSJER <- filter(insitu_dat, grepl('SJER', siteid))
    
    #how many unique siteids do we have now?
    #unique(plotsSJER$siteid) 
    
    
    #find the max stem height for each plot
    insitu_maxStemHeight <- plotsSJER %>% 
      group_by(plotid) %>% 
      summarise(max = max(stemheight))
    
    head(insitu_maxStemHeight)

    ## Source: local data frame [6 x 2]
    ## 
    ##     plotid  max
    ## 1 SJER1068 19.3
    ## 2  SJER112 23.9
    ## 3  SJER116 16.0
    ## 4  SJER117 11.0
    ## 5  SJER120  8.8
    ## 6  SJER128 18.2

    names(insitu_maxStemHeight) <- c("plotid","insituMaxHt")
    head(insitu_maxStemHeight)

    ## Source: local data frame [6 x 2]
    ## 
    ##     plotid insituMaxHt
    ## 1 SJER1068        19.3
    ## 2  SJER112        23.9
    ## 3  SJER116        16.0
    ## 4  SJER117        11.0
    ## 5  SJER120         8.8
    ## 6  SJER128        18.2

    # Optional - do this all in one line of nested commands
    #insitu <- insitu_dat %>% filter(plotid %in% centroids$Plot_ID) %>% 
    #	      group_by(plotid) %>% 
    #	      summarise(max = max(stemheight), quant = quantile(stemheight,.95))

## Option 2 - Use Base R to achieve the same results

If you don't want to use DPLYR, you can also achieve the same results using base 
R. However, the DPLYR workflow is more similar to a typical database approach.



    #Use the aggregate function, the arguments of which are: 
    #      the data on which you want to calculate something ~ the grouping variable
    #      the FUNction
    
    #insitu_maxStemHeight <- aggregate( insitu_inCentroid$stemheight ~ 
    #                                     insitu_inCentroid$plotid, FUN = max )  
    
    #Assign cleaner names to the columns
    #names(insitu_maxStemHeight) <- c('plotid','max')
    
    #OPTIONAL - combine the above steps into one line of code.
    #add the max and 95th percentile height value for all trees within each plot
    #insitu <- cbind(insitu_maxStemHeight,'quant'=tapply(insitu_inCentroid		$stemheight, 
    #     insitu_inCentroid$plotid, quantile, prob = 0.95))	

### Merge the data into the centroids data.frame

Once we have our summarized insitu data, we can `merge` it into the centroids 
`data.frame`. Merge requires two data.frames and the names of the columns 
containing the unique ID that we will merge the data on. In this case, we will
merge the data on the plot_id column. Notice that it's spelled slightly differently 
in both data.frames so we'll need to tell R what it's called in each data.frame.


    #merge the insitu data into the centroids data.frame
    centroids <- merge(centroids, insitu_maxStemHeight, by.x = 'Plot_ID', by.y = 'plotid')
    head(centroids)

    ##    Plot_ID  Point northing  easting Remarks ID chmMaxHeight insituMaxHt
    ## 1 SJER1068 center  4111568 255852.4      NA  1    18.940002        19.3
    ## 2  SJER112 center  4111299 257407.0      NA  2    24.189972        23.9
    ## 3  SJER116 center  4110820 256838.8      NA  3    13.299988        16.0
    ## 4  SJER117 center  4108752 256176.9      NA  4    10.989990        11.0
    ## 5  SJER120 center  4110476 255968.4      NA  5     5.690002         8.8
    ## 6  SJER128 center  4111389 257078.9      NA  6    19.079987        18.2

### Plot Data (CHM vs Measured)
Let's create a plot that illustrates the relationship between in situ measured 
max canopy height values and lidar derived max canopy height values.

We can make a simple plot using the base R `plot` function:


    #create basic plot
    plot(x = centroids$chmMaxHeight, y=centroids$insituMaxHt)

![ ]({{ site.baseurl }}/images/rfigs/2015-06-30-Create-Lidar-CHM-R/plot-data-1.png) 

Or we can use ggplot:


    library(ggplot2)
    #create plot
    ggplot(centroids,aes(x=chmMaxHeight, y =insituMaxHt )) + 
      geom_point() + 
      theme_bw() + 
      ylab("Maximum measured height") + 
      xlab("Maximum LiDAR pixel")+
      geom_abline(intercept = 0, slope=1)+
      xlim(0, max(centroids[,7:8])) + 
      ylim(0,max(centroids[,7:8]))

![ ]({{ site.baseurl }}/images/rfigs/2015-06-30-Create-Lidar-CHM-R/plot-w-ggplot-1.png) 


We can also add a regression fit to our plot. Explore the GGPLOT options and 
customize your plot.


    #plot with regression fit
    p <- ggplot(centroids,aes(x=chmMaxHeight, y =insituMaxHt )) + 
      geom_point() + 
      ylab("Maximum Measured Height") + 
      xlab("Maximum LiDAR Height")+
      geom_abline(intercept = 0, slope=1)+
      geom_smooth(method=lm) +
      xlim(0, max(centroids[,7:8])) + 
      ylim(0,max(centroids[,7:8])) 
    
    p + theme(panel.background = element_rect(colour = "grey")) + 
      ggtitle("LiDAR CHM Derived vs Measured Tree Height") +
      theme(plot.title=element_text(family="sans", face="bold", size=20, vjust=1.9)) +
      theme(axis.title.y = element_text(family="sans", face="bold", size=14, angle=90, hjust=0.54, vjust=1)) +
      theme(axis.title.x = element_text(family="sans", face="bold", size=14, angle=00, hjust=0.54, vjust=-.2))

![ ]({{ site.baseurl }}/images/rfigs/2015-06-30-Create-Lidar-CHM-R/ggplot-data-1.png) 



You have now successfully created a canopy height model using lidar data AND compared lidar 
derived vegetation height, within plots, to actual measured tree height data!


#Challenge 

> Create a plot of LiDAR 95th percentile value vs *insitu* max height. Or Lidar 95th 
> percentile vs *insitu* 95th percentile. Add labels to your plot. Customize the
> colors, fonts and the look of your plot. If you are happy with the outcome, share
> your plot in the comments below! 

## Create Plot.ly Interactive Plot

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
