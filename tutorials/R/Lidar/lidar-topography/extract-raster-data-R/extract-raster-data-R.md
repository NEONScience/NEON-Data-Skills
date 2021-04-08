---
syncID: 75f786a3b9ee4abba21878eb721704b6
title: "Extract Values from a Raster in R"
description: "Learn to extract data from a raster using circular or square buffers created around a x,y location or from a shapefile. With this we will learn to convert x,y locations in a .csv file into a SpatialPointsDataFrame"
dateCreated: 2014-07-21
authors: Edmund Hart, Leah A. Wasser, Donal O'Leary
contributors: 
estimatedTime: 0.5 Hours
packagesLibraries: raster, sp, rgdal, maptools, rgeos, dplyr, ggplot
topics: lidar, R, raster, remote-sensing, spatial-data-gis
languagesTool:
dataProduct:
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Lidar/lidar-topography/extract-raster-data-R/extract-raster-data-R.R
tutorialSeries: intro-lidar-r-series
urlTitle: extract-values-rasters-r
---


In this tutorial, we go through three methods for extracting data from a raster
in R: 

* from circular buffers around points,
* from square buffers around points, and
* from shapefiles. 

In doing so, we will also learn to convert x,y locations in tabluar format 
(.csv, .xls, .txt) into SpatialPointsDataFrames which can be used with other
spatial data. 

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this activity, you will be able to:

* Convert x,y point locations to SpatialPointsDataFrames
* Assign a Coordinate Reference System (CRS) to a SpatialPointsDataFrame
* Extract values from raster files. 
 
## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded 
on your computer to complete this tutorial.

### Install R Packages

* **raster:** `install.packages("raster")`
* **sp:** `install.packages("sp")`
* **rgdal:** `install.packages("rgdal")`
* **maptools:** `install.packages("maptools")`
* **rgeos:** `install.packages("rgeos")`
* **dplyr:** `install.packages("dplyr")`
* **ggplot2:** `install.packages("ggplot2")`

<a href="https://www.neonscience.org/packages-in-r" target="_blank">
More on Packages in R - Adapted from Software Carpentry</a>

## Download Data
<h3> <a href="https://ndownloader.figshare.com/files/7907590"> NEON Teaching Data Subset: Field Site Spatial Data</a></h3>

These remote sensing data files provide information on the vegetation at the 
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank"> San Joaquin Experimental Range</a> 
and 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SOAP" target="_blank"> Soaproot Saddle</a> 
field sites. The entire dataset can be accessed by request from the 
<a href="http://data.neonscience.org" target="_blank"> NEON Data Portal</a>.

<a href="https://ndownloader.figshare.com/files/7907590" class="link--button link--arrow">
Download Dataset</a>




This tutorial is designed for you to set your working directory to the directory
created by unzipping this file.

****

**Set Working Directory:** This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

**R Script & Challenge Code:** NEON data lessons often contain challenges that reinforce 
learned skills. If available, the code for challenge solutions is found in the
downloadable R script of the entire lesson, available in the footer of each lesson page.


***

## Recommended Reading
<a href="https://www.neonscience.org/chm-dsm-dtm-gridded-lidar-data" target="_blank">
What is a CHM, DSM and DTM? About Gridded, Raster lidar Data</a>

</div>

Let's say we are studying canopy structure at San Joaquin Experimental Range in 
California. Last year we went out and laboriously collected field measured 
height of several trees surrounding each of several randomly collected points. 
It took many sweaty days to complete, now we find out the NEON is collecting 
lidar data over this same area and will be doing to for the duration of our study!
Using this data will save us tons of time and $ -- but how does the data compare. 

Let's extract the data from the NEON provided raster (learning three different 
methods) and then compare them to our ground measured tree heights. 

## Convert x,y Locations to Spatial Data

Let's say we have our *insitu* data in two separate .csv (comma separate value) files: 

* `SJER/VegetationData/D17_2013_vegStr.csv`: contains our vegetation structure data 
for each plot. 
* `SJER/PlotCentroids/SJERPlotCentroids.csv`: contains the plot centroid location 
information (x,y) where we measured trees. 

Let's start by plotting the plot locations where we measured trees (in red) on a map. 

We will need to convert the plot centroids to a spatial points dataset in R. This
is why we need to load two packages - the spatial package 
<a href="http://cran.r-project.org/web/packages/sp/index.html" target="_blank">sp</a> –- 
and a data manipulation package 
<a href="http://cran.r-project.org/web/packages/dplyr/index.html" target="_blank"> dplyr</a> -- 
in addition to working with the raster package.

NOTE: the `sp` library typically installs when you install the raster package. 


    install.packages("maptools")

    ## 
    ## The downloaded binary packages are in
    ## 	/var/folders/bn/w43q_t8s3_xckn5j4plhb289fqhhfx/T//RtmplXtXZh/downloaded_packages

    # Load needed packages
    library(raster)
    library(rgdal)
    library(dplyr)
    
    # Method 3:shapefiles
    library(maptools)
    
    # plotting
    library(ggplot2)
    
    # set working directory to ensure R can find the file we wish to import and where
    wd <- "C:/Users/mccahill/Documents/GitHub/" #This will depend on your local environment
    setwd(wd)

    ## Error in setwd(wd): cannot change working directory

Let's get started with the *insitu* vegetation data!


    # import the centroid data and the vegetation structure data
    # this means all strings of letter coming in will remain character
    options(stringsAsFactors=FALSE)
    
    # read in plot centroids
    centroids <- read.csv(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/PlotCentroids/SJERPlotCentroids.csv"))

    ## Warning in file(file, "rt"): cannot open file 'C:/Users/mccahill/
    ## Documents/GitHub/NEON-DS-Field-Site-Spatial-Data/SJER/PlotCentroids/
    ## SJERPlotCentroids.csv': No such file or directory

    ## Error in file(file, "rt"): cannot open the connection

    str(centroids)

    ## Formal class 'standardGeneric' [package "methods"] with 8 slots
    ##   ..@ .Data     :function (x, ...)  
    ##   ..@ generic   : chr "centroids"
    ##   .. ..- attr(*, "package")= chr "terra"
    ##   ..@ package   : chr "terra"
    ##   ..@ group     : list()
    ##   ..@ valueClass: chr(0) 
    ##   ..@ signature : chr "x"
    ##   ..@ default   : NULL
    ##   ..@ skeleton  : language (function (x, ...)  stop("invalid call in method dispatch to 'centroids' (no default method)",  ...

    # read in vegetation heights
    vegStr <- read.csv(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/VegetationData/D17_2013_vegStr.csv"))

    ## Warning in file(file, "rt"): cannot open file 'C:/Users/mccahill/
    ## Documents/GitHub/NEON-DS-Field-Site-Spatial-Data/SJER/VegetationData/
    ## D17_2013_vegStr.csv': No such file or directory

    ## Error in file(file, "rt"): cannot open the connection

    str(vegStr)

    ## Error in str(vegStr): object 'vegStr' not found

Now let's load the Canopy Height Model raster. Note, if you completed the
<a href="https://www.neonscience.org/create-chm-rasters-r" target="_blank"> *Create a Canopy Height Model from lidar-derived Rasters in R*</a> 
tutorial this is the same object `chm` you can created. You do not need to reload
the data. 


    # import the digital terrain model
    chm <- raster(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/CHM_SJER.tif"))

    ## Error in .local(.Object, ...) :

    ## Error in .rasterObjectFromFile(x, band = band, objecttype = "RasterLayer", : Cannot create a RasterLayer object from this file. (file does not exist)

    # plot raster
    plot(chm, main="Lidar Canopy Height Model \n SJER, California")

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': object 'chm' not found


Since both files have eastings and northings we can use this data to plot onto 
our existing raster. 


    ## overlay the centroid points and the stem locations on the CHM plot
    # plot the chm
    myCol <- terrain.colors(6)
    plot(chm,col=myCol, main="Plot & Tree Locations", breaks=c(-2,0,2,10,40))

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': object 'chm' not found

    ## plotting details: cex = point size, pch 0 = square
    # plot square around the centroid
    points(centroids$easting,centroids$northing, pch=0, cex = 2 )

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'points': object of type 'closure' is not subsettable

    # plot location of each tree measured
    points(vegStr$easting,vegStr$northing, pch=19, cex=.5, col = 2)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'points': object 'vegStr' not found

Now we have a plot of our CHM showing trees of different (categorical) heights. 
Why might we have chosen these breaks? 

On this CHM plot we've marked the locations of the plot centers. Note the black 
box isn't the plot boundary, but determined by the plot marker we chose so that 
we can see the centroids that would otherwise be "under" the tree height points.
We've also plotted the locations of individual trees we measured (red overlapping 
circles). 

Plotting Tips: use `help(points)` to read about the options for plotting points.
Or to see a list of `pch` values (symbols), check out 
<a href="http://www.endmemo.com/program/R/pchsymbols.php" target="_blank">this website.</a>

## Spatial Data Need a Coordinate Reference System

We plotted the easting and northing of the points accurately on the map, but 
our data doesn't yet have a specific Coordinate Reference System attached to it. The CRS is 
information that allows a program like QGIS to determine where the data are 
located, in the world. 
<a href="http://www.sco.wisc.edu/coordinate-reference-systems/coordinate-reference-systems" target="_blank">
Read more about CRS here</a>

We need to assign a Coordinate Reference System to our insitu data. In this case, 
we know these data are all in the same projection as our original CHM. We can 
quickly figure out what projection an object is in, using `object@crs`.


    # check CHM CRS
    chm@crs

    ## Error in eval(expr, envir, enclos): object 'chm' not found

So our data are in UTM Zone 11 which is correct for California. We can use this 
CRS to make our data points into a Spatial Points Data Frame which then allows 
the points to be treated as spatial objects. 


    ## create SPDF: SpatialPointsDataFrame()
    # specify the easting (column 4) & northing (columns 3) in that order
    # specify CRS proj4string: borrow CRS from chm 
    # specify raster
    centroid_spdf <- SpatialPointsDataFrame(
      centroids[,4:3], proj4string=chm@crs, centroids)

    ## Error in centroids[, 4:3]: object of type 'closure' is not subsettable

    # check centroid CRS
    # note SPDFs don't have a crs slot so `object@crs` won't work
    centroid_spdf

    ## Error in eval(expr, envir, enclos): object 'centroid_spdf' not found

We now have our centroid data as a spatial points data frame. This will allow us
to work with them as spatial data along with other spatial data -- like rasters. 


## Extract CMH Data from Buffer Area

In order to accomplish a goal of comparing the CHM with our ground data, we 
want to extract the CHM height at the point for each tree we measured. To do this,
we will create a boundary region (called a buffer) representing the spatial
extent of each plot (where trees were measured). We will then extract all CHM pixels
that fall within the plot boundary to use to estimate tree height for that plot.

<figure>
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/geospatial-skills/BufferCircular.png">
    <figcaption>When a circular buffer is applied to a raster, some pixels fall 
    fully within the buffer but some are partially excluded. Values for all 
    pixels in the specified raster that fall within the circular buffer are 
    extracted.
    </figcaption>
</figure>

There are a few ways to go about this task. As our plots are circular, we'll use
the extract function in R allows you 
to specify a circular buffer with a given radius around an x,y point location. 
Values for all pixels in the specified raster that fall within the circular 
buffer are extracted. In this case, we can tell R to extract the maximum value 
of all pixels using the `fun=max` argument.

### Method 1: Extract Data From a Circular Buffer

In the first, example we'll presume our insitu sampling took place within a 
circular plot with a 20m radius. Therefore, we will use a buffer of 20m. 

When we use the `extract()` function with `fun=max`, R returns a dataframe 
containing the max height calculated from all pixels in the buffer for each plot.

There are a few other popular packages that have a function called `extract()`, 
so we will specify to use the function from the `raster` package using the "`::`" notation.


    # extract circular, 20m buffer
    
    cent_max <- raster::extract(chm,             # raster layer
    	centroid_spdf,   # SPDF with centroids for buffer
    	buffer = 20,     # buffer size, units depend on CRS
    	fun=max,         # what to value to extract
    	df=TRUE)         # return a dataframe? 

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'extract': object 'chm' not found

    # view
    cent_max

    ## Error in eval(expr, envir, enclos): object 'cent_max' not found

Ack! We've lost our PlotIDs, how will we match them up?


    # grab the names of the plots from the centroid_spdf
    cent_max$plot_id <- centroid_spdf$Plot_ID

    ## Error in eval(expr, envir, enclos): object 'centroid_spdf' not found

    #fix the column names
    names(cent_max) <- c('ID','chmMaxHeight','plot_id')

    ## Error in names(cent_max) <- c("ID", "chmMaxHeight", "plot_id"): object 'cent_max' not found

    # view again - we have plot_ids
    cent_max

    ## Error in eval(expr, envir, enclos): object 'cent_max' not found

    # merge the chm data into the centroids data.frame
    centroids <- merge(centroids, cent_max, by.x = 'Plot_ID', by.y = 'plot_id')

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'y' in selecting a method for function 'merge': object 'cent_max' not found

    # have a look at the centroids dataFrame
    head(centroids)

    ##                                                                                      
    ## 1 new("standardGeneric", .Data = function (x, ...)                                   
    ## 2 standardGeneric("centroids"), generic = structure("centroids", package = "terra"), 
    ## 3     package = "terra", group = list(), valueClass = character(0),                  
    ## 4     signature = "x", default = NULL, skeleton = (function (x,                      
    ## 5         ...)                                                                       
    ## 6     stop("invalid call in method dispatch to 'centroids' (no default method)",

Excellent. We now have the maximum "tree" height for each plot based on the CHM. 

#### Extract All Pixel Heights

If we want to explore the data distribution of pixel height values in each plot, 
we could remove the `fun` call to max and generate a list. 

It's good to look at the distribution of values we've extracted for each plot. 
Then you could generate a histogram for each plot `hist(cent_ovrList[[2]])`. If we wanted, we could loop 
through several plots and create histograms using a `for loop`.


    # extract all
    cent_heightList <- raster::extract(chm,centroid_spdf,buffer = 20)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'extract': object 'chm' not found

    # create histograms for the first 5 plots of data
    # using a for loop
    
    for (i in 1:5) {
      hist(cent_heightList[[i]], main=(paste("plot",i)))
      }

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'hist': object 'cent_heightList' not found

Looking at these distributions, the area has some pretty short trees -- plot 5 
(really, SJER120 since we didn't match up the plotIDs) looks almost bare!

<div id="ds-challenge" markdown="1">
### Challenge: For Loops & Plotting Parameters
Seeing as we have 18 trees in our `cent_heightList`, it would be nice to show all 18 plots organized into 6 rows of plots with 3 plots in each row. Modify the 
`for loop` above to plot all 18 histograms. 

Improve upon the plot's final appearance to make a readable final figure. 
Hint: one way to setup a layout with multiple plots in R is: `par(mfrow=c(2,3))` 
which gives a 2 rows, 3 columns layout. 
</div> 



## Method 2: Square Plots 

To complete this next method, you need to first create square plots around a 
point to create a R object called `polys`. Directions for how to do this are 
contained in this tutorial: 
 
<a href="https://www.neonscience.org/field-data-polygons-centroids" target="_blank">*Create A Square Buffer Around a Plot Centroid in R*</a>. 


Once you have the SpatialPolygon object `polys`, you can use the same `extract()` function
as we did for the circular plots, but this time with no buffer since we already 
have a polygon to use. 


    #Will need to load 'sp' package 'library(sp)'
    square_max <- raster::extract(chm,             # raster layer
    	polys,   # spatial polygon for extraction
    	fun=max,         # what to value to extract
    	df=TRUE)         # return a dataframe? 

However, if you're going this route with your data, we recommend using the next
method! 

## Method 3: Extract Values Using a Shapefile

If our plot boundaries are saved in a shapefile, we can use them to extract the 
data.

In our data, we have two different shapefiles (SJER/PlotCentroids) for this area

* SJERPlotCentroids_Buffer
* SJERPlotCentroids_BuffSquare

To import a shapefile into R we must have the `maptools` package, which 
requires the `rgeos` package, installed.



    # load shapefile data
    centShape <- readOGR(paste0(wd,"NEON-DS-Field-Site-Spatial-Data/SJER/PlotCentroids/SJERPlotCentroids_Buffer.shp"))

    ## Error in ogrListLayers(dsn = dsn): Cannot open data source

    plot(centShape)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': object 'centShape' not found

Then we can simply use the extract function again. Here we specify not weighting
the values returned and we directly add the data to our centroids file instead
of having it be a separate data frame that we later have to match up. 


    # extract max from chm for shapefile buffers
    centroids$chmMaxShape <- raster::extract(chm, centShape, weights=FALSE, fun=max)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'extract': object 'chm' not found

    # view
    head(centroids)

    ##                                                                                      
    ## 1 new("standardGeneric", .Data = function (x, ...)                                   
    ## 2 standardGeneric("centroids"), generic = structure("centroids", package = "terra"), 
    ## 3     package = "terra", group = list(), valueClass = character(0),                  
    ## 4     signature = "x", default = NULL, skeleton = (function (x,                      
    ## 5         ...)                                                                       
    ## 6     stop("invalid call in method dispatch to 'centroids' (no default method)",

Which was faster, extracting from a SpatialPolgygon object (`polys`) or extracting 
with a SpatialPolygonsDataFrame (`centShape`)? Keep this in mind when doing future
work--the SpatialPolgyonsDataFrame is more efficient. 

<div id="ds-challenge" markdown="1">
### Challenge: Square Shapefile Plots

Compare the values from `cent_max` and `square_max`. Are they the same? Why 
might they differ? 

</div>


    ## Error in ogrListLayers(dsn = dsn): Cannot open data source

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': object 'squareShape' not found

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'extract': object 'chm' not found

    ## Error in centroids$chmMaxSquareShape: object of type 'closure' is not subsettable

## Extract Summary Data from Ground Measures 
In our final step, we will extract summary height values from our field data 
(`vegStr`). We can do this using the base R packages (Method 1) or more 
efficiently, using the `dplyr` package (Method 2).


### Method 1: Use Base R

We'll start by find the maximum ground measured stem height value for each plot. 
We will compare this value to the max CHM value.

First, use the `aggregate()` function to summarize our data of interest `stemheight`.
The arguments of which are: 

* the data on which you want to calculate something ~ the grouping variable
* the **FUN**ction we want from the data

Then we'll assign cleaner names to the new data. 


    # find max stemheight
    maxStemHeight <- aggregate( vegStr$stemheight ~ vegStr$plotid, 
    														FUN = max )  

    ## Error in eval(predvars, data, env): object 'vegStr' not found

    # view
    head(maxStemHeight)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'head': object 'maxStemHeight' not found

    #Assign cleaner names to the columns
    names(maxStemHeight) <- c('plotid','insituMaxHeight')

    ## Error in names(maxStemHeight) <- c("plotid", "insituMaxHeight"): object 'maxStemHeight' not found

    # view
    head(maxStemHeight)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'head': object 'maxStemHeight' not found

Bonus: Add in 95% height, while combining the above steps into one line of code.


    # add the max and 95th percentile height value for all trees within each plot
    insitu <- cbind(maxStemHeight,'quant'=tapply(vegStr$stemheight, 
    	vegStr$plotid, quantile, prob = 0.95))

    ## Error in cbind(maxStemHeight, quant = tapply(vegStr$stemheight, vegStr$plotid, : object 'maxStemHeight' not found

    # view
    head(insitu)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'head': object 'insitu' not found


### Method 2: Extract using dplyr

You can also achieve the same results in a more efficient manner using the R 
package **dplyr**. Additionally, the **dplyr** workflow is more similar to a 
typical database approach.

For more on using the **dplyr** package see our tutorial, 
<a href="https://www.neonscience.org/grepl-filter-piping-dplyr-r/" target="_blank"> *Filter, Piping and GREPL Using R DPLYR - An Intro*</a>. 


    # find the max stem height for each plot
    maxStemHeight_d <- vegStr %>% 
      group_by(plotid) %>% 
      summarise(max = max(stemheight))

    ## Error in eval(lhs, parent, parent): object 'vegStr' not found

    # view
    head(maxStemHeight_d)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'head': object 'maxStemHeight_d' not found

    # fix names
    names(maxStemHeight_d) <- c("plotid","insituMaxHeight")

    ## Error in names(maxStemHeight_d) <- c("plotid", "insituMaxHeight"): object 'maxStemHeight_d' not found

    head(maxStemHeight_d)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'head': object 'maxStemHeight_d' not found

And the bonus code with dplyr. 


    # one line of nested commands, 95% height value
    insitu_d <- vegStr %>%
    	filter(plotid %in% centroids$Plot_ID) %>% 
    	group_by(plotid) %>% 
    	summarise(max = max(stemheight), quant = quantile(stemheight,.95))

    ## Error in eval(lhs, parent, parent): object 'vegStr' not found

    # view
    head(insitu_d)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'head': object 'insitu_d' not found


## Combine Ground & Remote Sensed Data

Once we have our summarized insitu data, we can merge it into the `centroids` 
data.frame. The `merge()` function requires two data.frames and the names of the 
columns containing the unique ID that we will merge the data on. In this case, 
we will merge the data on the Plot ID (`plotid`, `Plot_ID`) column. Notice that 
it's spelled slightly differently in both data.frames so we'll need to tell R 
what it's called in each data.frame.

If you plan your data collection, entry, and analyses ahead of time you can 
standardize your names to avoid potential confusion like this!


    # merge the insitu data into the centroids data.frame
    centroids <- merge(centroids, maxStemHeight, by.x = 'Plot_ID', by.y = 'plotid')

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'y' in selecting a method for function 'merge': object 'maxStemHeight' not found

    # view
    head(centroids)

    ##                                                                                      
    ## 1 new("standardGeneric", .Data = function (x, ...)                                   
    ## 2 standardGeneric("centroids"), generic = structure("centroids", package = "terra"), 
    ## 3     package = "terra", group = list(), valueClass = character(0),                  
    ## 4     signature = "x", default = NULL, skeleton = (function (x,                      
    ## 5         ...)                                                                       
    ## 6     stop("invalid call in method dispatch to 'centroids' (no default method)",

## Plot Remote Sensed vs Ground Data

Now we can create a plot that illustrates the relationship between in situ 
measured tree height values and lidar-derived max canopy height values.

We can make a simple plot using the base R `plot()` function:


    #create basic plot
    plot(x = centroids$chmMaxShape, y=centroids$insituMaxHeight)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': object of type 'closure' is not subsettable

Or we can use the `ggplot()` function from the **ggplot2** package. For more on 
using the **ggplot2** package see our tutorial, 
<a href="https://www.neonscience.org/dc-time-series-plot-ggplot-r" target="_blank"> *Plot Time Series with ggplot2 in R*</a>. 

In reality, we know that the trees in these plots are the same height regardless of if we measure them with lidar or from the ground. However, there may be certain biases in our measurements, and it will be interesting to see if one method measures the trees as being taller than the other. To make this comparison, we will add what is called a "1:1" line, i.e., the line where all of the points would fall if both methods measured the trees as exactly the same height. Let's make this "1:1" line dashed and slightly transparent so that it doesn't obscure any of our points.


    # create plot
    
    ggplot(centroids,aes(x=chmMaxShape, y =insituMaxHeight )) + 
      geom_abline(slope=1, intercept = 0, alpha=.5, lty=2)+ # plotting our "1:1" line
      geom_point() + 
      theme_bw() + 
      ylab("Maximum measured height") + 
      xlab("Maximum lidar pixel")

    ## Error:   You're passing a function as global data.
    ##   Have you misspelled the `data` argument in `ggplot()`


We can also add a regression fit to our plot. Explore the `ggplot()` options and 
customize your plot.


    # plot with regression
    
    ggplot(centroids, aes(x=chmMaxShape, y=insituMaxHeight)) +
      geom_abline(slope=1, intercept=0, alpha=.5, lty=2) + #plotting our "1:1" line
      geom_point() +
      geom_smooth(method = lm) + # add regression line and confidence interval
      ggtitle("Lidar CHM-derived vs. Measured Tree Height") +
      ylab("Maximum Measured Height") +
      xlab("Maximum Lidar Height") +
      theme(panel.background = element_rect(colour = "grey"),
            plot.title = element_text(family="sans", face="bold", size=20, vjust=1.19),
            axis.title.x = element_text(family="sans", face="bold", size=14, angle=00, hjust=0.54, vjust=-.2),
            axis.title.y = element_text(family="sans", face="bold", size=14, angle=90, hjust=0.54, vjust=1))

    ## Error:   You're passing a function as global data.
    ##   Have you misspelled the `data` argument in `ggplot()`

You have now successfully compared lidar derived vegetation height, within plots, 
to actual measured tree height data! By comparing the regression line against the 1:1 line, it appears as though lidar underestimates tree height for shorter trees, and overestimates tree height for taller trees.. Or could it be that human observers underestimate the height of very tall trees because it's hard to see the crown from the ground? Or perhaps the lidar-based method mis-judges the elevation of the ground, which would throw off the accuracy of the CHM? As you can see, there are many potential factors leading to this disagreement in height between observation methods, which the savvy researcher would be sure to investigate if tree height is important for their particular pursuits.

If you want to make this an interactive plot, you could use Plotly to do so. 
For more on using the **plotly** package to create interactive plots, see our tutorial 
<a href="https://www.neonscience.org/plotly-r" target="_blank"> *Interactive Data Vizualization with R and Plotly*</a>. 


<div id="ds-challenge" markdown="1">
### Challenge: Plot Data

Create a plot of lidar 95th percentile value vs *insitu* max height. Or lidar 95th 
percentile vs *insitu* 95th percentile. 

Compare this plot to the previous one with max height. Which would you prefer to 
use for your analysis? Why? 

</div>


    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'y' in selecting a method for function 'merge': object 'insitu' not found

    ## Error in ggplot(centroids_c, aes(x = quant, y = insituMaxHeight.x)): object 'centroids_c' not found


