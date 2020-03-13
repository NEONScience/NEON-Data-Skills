---
syncID: 4603eeb9116a4e54a649cb53929eb034
title: "Working With Time Series Data Within a Nested HDF5 File in R"
description: "Explore, extract and visualize temporal temperature data collected from a NEON flux tower from multiple sites and sensors in R. Learn how to extract metadata and how to use nested loops and dplyr to perform more advanced queries and data manipulation."
dateCreated: 2014-11-17
authors: Leah A Wasser, Ted Hart
contributors: Elizabeth Webb
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: rhdf5, ggplot2, dplyr
topics: HDF5, data-management
languagesTool: R
dataProduct:
code1: /HDF5/R-Timeseries-HDF5.R
tutorialSeries: intro-hdf5-r-series
urlTitle: time-series-hdf5-r
---

In this tutorial, we'll work with 
<a href="/data-collection/flux-tower-measurements"> 
temperature data collected using sensors on a flux tower</a> 
by 
<a href="/" target="_blank">the National 
Ecological Observatory Network (NEON) </a>. 
Here the data are provided in HDF5 format to allow for the exploration of this 
format. More information about NEON temperature data can be found on the 
<a href="http://data.neonscience.org" target="_blank">the NEON Data Portal</a>. 
Please note that at the present time temperature data are published on the data 
portal as a flat .csv file and not as an HDF5 file. NEON data products currently 
released in HDF5 include eddy covariance data and remote sensing data.

We'll examine our HDF5 file as if we knew nothing about it. We will 
view its structure, extract metadata and visualize data contained 
within datasets in the HDF5 file. We will also use use loops and custom 
functions to efficiently examine data with a complex nested structure 
using advanced tools like `dplyr`.

<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this tutorial, you will be able to:

* Explore an HDF5 file and access groups and datasets 
in R.
* Explain the basics of manipulating big datasets using indexing, 
loops, and `dplyr`.
* Refine your data plotting skills using `ggplot` in R.
* Apply a variety of data manipulation tasks including identifying data types 
given a new dataset, string parsing, and working with & formatting date information.


## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### R Libraries to Install:

* **rhdf5**
* **ggplot2** for plotting: `install.packages("ggplot2")`
* **dplyr** for data manipulation: `install.packages("dplyr")`
* **scales** for plotting dates: `install.packages("scales")`

<a href="{{ site.baseurl }}/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.
### Data to Download
We will use the file below in the optional challenge activity at the end of this 
tutorial.

{% include/dataSubsets/_data_Sample-Tower-Temp-H5.html %}

***
{% include/_greyBox-wd-rscript.html %}
***

### Additional Resources

Consider reviewing the documentation for the <a href="http://www.bioconductor.org/packages/release/bioc/manuals/rhdf5/man/rhdf5.pdf" target="_blank">RHDF5 package</a>.

</div>

## rhdf5 package & R 
To access HDF5 files in R, we'll use `rhdf5` which is part of the 
<a href="http://www.bioconductor.org" target="_blank">Bioconductor</a> suite of 
R packages.

It might also be useful to install 
<a href="http://www.hdfgroup.org/products/java/hdfview/" target="_blank">HDFView</a> 
which will allow you to explore the contents of an HDF5 file visually using a 
graphic interface. 


    # Install rhdf5 library
    #install.packages("BiocManager")
    #BiocManager::install("rhdf5")
    
    
    library("rhdf5")
    # also load ggplot2 and dplyr
    library("ggplot2")
    library("dplyr")
    # a nice R packages that helps with date formatting is scale.
    library("scales")
    
    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files
    #setwd("working-dir-path-here")


### HDF5 Quick Review
The HDF5 format is a self-contained directory structure. In HDF5 files though 
"directories" are called "**groups**" and "**files**" are called "**datasets**". 
Each element in an hdf5 file can have metadata attached to it making HDF5 files 
"self-describing".

<a href="/about-hdf5" target="_blank">Read more about HDF5 in this Data Skills tutorial. </a>

## Explore the HDF5 File Structure

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**The Data:** The temperature data used in this 
tutorial were collected by a temperature sensor mounted on a National Ecological 
Observatory Network (NEON) flux tower at the <a href="h/field-sites/field-sites-map/OSBS" target="_blank">NEON field site - Ordway Swisher Biological Station (OSBS)</a>. 
Learn more about 
<a href="/data-collection/flux-tower-measurements" target="_blank">flux data here.</a>
</div>

Let's first explore an HDF5 file that we know nothing about using the R function, 
`h5ls`.



    # Identify file path (be sure to adjust the path to match your file structure!)
    f <- "NEON-DS-Tower-Temperature-Data.hdf5"
    # View structure of file
    h5ls(f)

    ##                               group        name       otype   dclass  dim
    ## 0                                 /   Domain_03   H5I_GROUP              
    ## 1                        /Domain_03        OSBS   H5I_GROUP              
    ## 2                   /Domain_03/OSBS       min_1   H5I_GROUP              
    ## 3             /Domain_03/OSBS/min_1      boom_1   H5I_GROUP              
    ## 4      /Domain_03/OSBS/min_1/boom_1 temperature H5I_DATASET COMPOUND 4323
    ## 5             /Domain_03/OSBS/min_1      boom_2   H5I_GROUP              
    ## 6      /Domain_03/OSBS/min_1/boom_2 temperature H5I_DATASET COMPOUND 4323
    ## 7             /Domain_03/OSBS/min_1      boom_3   H5I_GROUP              
    ## 8      /Domain_03/OSBS/min_1/boom_3 temperature H5I_DATASET COMPOUND 4323
    ## 9             /Domain_03/OSBS/min_1      boom_5   H5I_GROUP              
    ## 10     /Domain_03/OSBS/min_1/boom_5 temperature H5I_DATASET COMPOUND 4323
    ## 11            /Domain_03/OSBS/min_1   tower_top   H5I_GROUP              
    ## 12  /Domain_03/OSBS/min_1/tower_top temperature H5I_DATASET COMPOUND 4323
    ## 13                  /Domain_03/OSBS      min_30   H5I_GROUP              
    ## 14           /Domain_03/OSBS/min_30      boom_1   H5I_GROUP              
    ## 15    /Domain_03/OSBS/min_30/boom_1 temperature H5I_DATASET COMPOUND  147
    ## 16           /Domain_03/OSBS/min_30      boom_2   H5I_GROUP              
    ## 17    /Domain_03/OSBS/min_30/boom_2 temperature H5I_DATASET COMPOUND  147
    ## 18           /Domain_03/OSBS/min_30      boom_3   H5I_GROUP              
    ## 19    /Domain_03/OSBS/min_30/boom_3 temperature H5I_DATASET COMPOUND  147
    ## 20           /Domain_03/OSBS/min_30      boom_5   H5I_GROUP              
    ## 21    /Domain_03/OSBS/min_30/boom_5 temperature H5I_DATASET COMPOUND  147
    ## 22           /Domain_03/OSBS/min_30   tower_top   H5I_GROUP              
    ## 23 /Domain_03/OSBS/min_30/tower_top temperature H5I_DATASET COMPOUND  147
    ## 24                                /   Domain_10   H5I_GROUP              
    ## 25                       /Domain_10        STER   H5I_GROUP              
    ## 26                  /Domain_10/STER       min_1   H5I_GROUP              
    ## 27            /Domain_10/STER/min_1      boom_1   H5I_GROUP              
    ## 28     /Domain_10/STER/min_1/boom_1 temperature H5I_DATASET COMPOUND 4323
    ## 29            /Domain_10/STER/min_1      boom_2   H5I_GROUP              
    ## 30     /Domain_10/STER/min_1/boom_2 temperature H5I_DATASET COMPOUND 4323
    ## 31            /Domain_10/STER/min_1      boom_3   H5I_GROUP              
    ## 32     /Domain_10/STER/min_1/boom_3 temperature H5I_DATASET COMPOUND 4323
    ## 33                  /Domain_10/STER      min_30   H5I_GROUP              
    ## 34           /Domain_10/STER/min_30      boom_1   H5I_GROUP              
    ## 35    /Domain_10/STER/min_30/boom_1 temperature H5I_DATASET COMPOUND  147
    ## 36           /Domain_10/STER/min_30      boom_2   H5I_GROUP              
    ## 37    /Domain_10/STER/min_30/boom_2 temperature H5I_DATASET COMPOUND  147
    ## 38           /Domain_10/STER/min_30      boom_3   H5I_GROUP              
    ## 39    /Domain_10/STER/min_30/boom_3 temperature H5I_DATASET COMPOUND  147

Note that `h5ls` returns the structure of the HDF5 file structure including the 
group and dataset names and associated types and sizes of each object. In our file, 
there are datasets that are `compound` in this file. Compound class means there
are a combination of datatypes within the datasets (e.g. numbers, strings, etc)  
contained within that group.

Also note that you can add the `recursive` variable to the `h5ls` command to set 
the number of nested levels that the command returns. Give it a try.


    #specify how many "levels" of nesting are returns in the command
    h5ls(f,recursive=2)

    ##        group      name     otype dclass dim
    ## 0          / Domain_03 H5I_GROUP           
    ## 1 /Domain_03      OSBS H5I_GROUP           
    ## 2          / Domain_10 H5I_GROUP           
    ## 3 /Domain_10      STER H5I_GROUP

    h5ls(f,recursive=3)

    ##             group      name     otype dclass dim
    ## 0               / Domain_03 H5I_GROUP           
    ## 1      /Domain_03      OSBS H5I_GROUP           
    ## 2 /Domain_03/OSBS     min_1 H5I_GROUP           
    ## 3 /Domain_03/OSBS    min_30 H5I_GROUP           
    ## 4               / Domain_10 H5I_GROUP           
    ## 5      /Domain_10      STER H5I_GROUP           
    ## 6 /Domain_10/STER     min_1 H5I_GROUP           
    ## 7 /Domain_10/STER    min_30 H5I_GROUP

## The Data Structure
 
Looking at the `h5ls` output, we see this H5 file has a nested group and dataset 
structure. Below, we will slice out temperature data which is located within the 
following path:
 `Domain_03 --> OSBS --> min_1 --> boom_1 --> temperature`
 
Take note that this path is 4 groups "deep" and leads to one dataset called 
temperature in this part of the HDF5 file as follows:

* **Domain_03** - A NEON domain is an ecologically unique region. Domain 3 is 
one of 20 regions that <a href="/field-sites/spatiotemporal-design" target="_blank" >NEON uses to organize its network spatially </a>.
* **OSBS** - a group representing data from the <a href="/field-sites/field-sites-map/OSBS" target="_blank"> Ordway Swisher Biological Station (OSBS).</a>
* **min_1** - A group representing the mean temperature data value for every for 
one minute in time. Temperature data are often collected at high frequencies (20 hz 
or 20 measurements a second) or more. A typical data product derived from high 
frequency tempearture data are an average value. In this case, all measurements 
are averaged every minute.  
* **boom_1** - Boom 1 is the first and lowest arm or level on the tower. Towers 
often contain arms where the sensors are mounted, that reach out horizontally 
away from the tower (see figure below). The tower at Ordway Swisher has a total 
of 6 booms (booms 1-5 and the tower top). 


<figure>
    <a href="{{ site.baseurl }}/images/NEON-general/NEONtower.png">
    <img src="{{ site.baseurl }}/images/NEON-general/NEONtower.png"></a>
    <figcaption>A NEON tower contains booms, or arms, that house sensors at varying 
    heights along the tower.</figcaption>
</figure>



    # read in temperature data
    temp <- h5read(f,"/Domain_03/OSBS/min_1/boom_1/temperature")
    
    # view the first few lines of the data 
    head(temp)

    ##                    date numPts     mean      min      max    variance
    ## 1 2014-04-01 00:00:00.0     60 15.06154 14.96886 15.15625 0.002655015
    ## 2 2014-04-01 00:01:00.0     60 14.99858 14.93720 15.04274 0.001254117
    ## 3 2014-04-01 00:02:00.0     60 15.26231 15.03502 15.56683 0.041437537
    ## 4 2014-04-01 00:03:00.0     60 15.45351 15.38553 15.53449 0.001174759
    ## 5 2014-04-01 00:04:00.0     60 15.35306 15.23799 15.42346 0.003526443
    ## 6 2014-04-01 00:05:00.0     60 15.12807 15.05846 15.23494 0.003764170
    ##        stdErr uncertainty
    ## 1 0.006652087  0.01620325
    ## 2 0.004571866  0.01306111
    ## 3 0.026279757  0.05349682
    ## 4 0.004424851  0.01286833
    ## 5 0.007666423  0.01788372
    ## 6 0.007920616  0.01831239

    # generate a quick plot of the data, type=l for "line"
    plot(temp$mean,type='l')

![ ]({{ site.baseurl }}/images/rfigs/HDF5/R-Timeseries-HDF5/readPlotData-1.png)

We can make our plot look nicer by adding date values to the x axis. However, in 
order to list dates on the X axis, we need to assign the date field a date format 
so that R knows how to read and organize the labels on the axis.

Let's clean up the plot above. We can first add dates to the x axis. In order to 
list dates, we need to specify the format that the date field is in.


    # First read in the time as UTC format
    temp$date <- as.POSIXct(temp$date ,format = "%Y-%m-%d %H:%M:%S", tz = "GMT")
    
    # Create a plot using ggplot2 package
    OSBS_Plot <- ggplot(temp,aes(x=date,y=mean))+
      geom_path()+
      ylab("Mean temperature") + 
      xlab("Date in UTC")+
      ggtitle("3 Days of Temperature Data at Ordway Swisher")
    
    OSBS_Plot

![ ]({{ site.baseurl }}/images/rfigs/HDF5/R-Timeseries-HDF5/plot-temp-data-1.png)

Let's have a close look at this plot. Notice anything unusual with it?

Hint: When would you expect the temperature to be the warmest during the day?

<figure>
    <a href="{{ site.baseurl }}/images/HDF5/heating-curve_LNewman.jpg">
    <img src="{{ site.baseurl }}/images/HDF5/heating-curve_LNewman.jpg"></a>
    <figcaption>In many parts of the world, we'd expect the maximum temperature
    to occur during late afternoon. Source: <a href="http://web.gccaz.edu/~lnewman/gph111/topic_units/temperature1/temperature/heating-curve.jpg" target="_blank"> Lynn Newman </a></figcaption>
</figure>

In this case, our data are in 
<a href="http://en.wikipedia.org/wiki/Coordinated_Universal_Time" target="_blank">UTC time zone.</a> 
The UTC time zone is a standardized time zone that does not observe daylight 
savings time. If your data are in UTC, then you will need to convert them to 
the local time zone where the data are collected for the dates and times to 
make sense when you plot & analyze your data. 

For example, find your local time zone on this 
<a href="http://en.wikipedia.org/wiki/List_of_tz_database_time_zones" target="_blank">
wikipedia page.</a> 
How many hours difference is UTC from your local time?

To adjust for time, we need to tell R that the time zone where the data are 
collected is Eastern Standard time since our data were collected at OSBS. We
can use the `attributes` function to set the time zone.


    # convert to local time for pretty plotting
    attributes(temp$date)$tzone <- "US/Eastern"
    
    # now, plot the data!
    OSBS_Plot2 <- ggplot(temp,aes(x=date,y=mean))+
      geom_path()+
      ylab("Mean temperature") + xlab("Date in Eastern Standard Time")+
      theme_bw()+
      ggtitle("3 Days of Temperature Data at Ordway Swisher")
    
    # let's check out the plot
    OSBS_Plot2

![ ]({{ site.baseurl }}/images/rfigs/HDF5/R-Timeseries-HDF5/fix-time-zone-1.png)

Now the temperature peaks occur mid-afternoon when we'd expect them. 

<a href="http://www.statmethods.net/advgraphs/ggplot2.html" target="_blank"> More on customizing plots here</a>.

### Extracting metadata

Metadata can be stored directly within HDF5 files and attached to each `group` or  
`dataset` in the file - or to the file itself. To read the metadata for elements 
in a HDF5 file in R we use the `h5readAttributes` function.

To view the groups and datasets in our file, we will grab the nested structure, 
five 'levels' down gets us to the temperature dataset


    # view temp data on "5th" level
    fiu_struct <- h5ls(f,recursive=5)
    
    # have a look at the structure.
    fiu_struct

    ##                               group        name       otype   dclass  dim
    ## 0                                 /   Domain_03   H5I_GROUP              
    ## 1                        /Domain_03        OSBS   H5I_GROUP              
    ## 2                   /Domain_03/OSBS       min_1   H5I_GROUP              
    ## 3             /Domain_03/OSBS/min_1      boom_1   H5I_GROUP              
    ## 4      /Domain_03/OSBS/min_1/boom_1 temperature H5I_DATASET COMPOUND 4323
    ## 5             /Domain_03/OSBS/min_1      boom_2   H5I_GROUP              
    ## 6      /Domain_03/OSBS/min_1/boom_2 temperature H5I_DATASET COMPOUND 4323
    ## 7             /Domain_03/OSBS/min_1      boom_3   H5I_GROUP              
    ## 8      /Domain_03/OSBS/min_1/boom_3 temperature H5I_DATASET COMPOUND 4323
    ## 9             /Domain_03/OSBS/min_1      boom_5   H5I_GROUP              
    ## 10     /Domain_03/OSBS/min_1/boom_5 temperature H5I_DATASET COMPOUND 4323
    ## 11            /Domain_03/OSBS/min_1   tower_top   H5I_GROUP              
    ## 12  /Domain_03/OSBS/min_1/tower_top temperature H5I_DATASET COMPOUND 4323
    ## 13                  /Domain_03/OSBS      min_30   H5I_GROUP              
    ## 14           /Domain_03/OSBS/min_30      boom_1   H5I_GROUP              
    ## 15    /Domain_03/OSBS/min_30/boom_1 temperature H5I_DATASET COMPOUND  147
    ## 16           /Domain_03/OSBS/min_30      boom_2   H5I_GROUP              
    ## 17    /Domain_03/OSBS/min_30/boom_2 temperature H5I_DATASET COMPOUND  147
    ## 18           /Domain_03/OSBS/min_30      boom_3   H5I_GROUP              
    ## 19    /Domain_03/OSBS/min_30/boom_3 temperature H5I_DATASET COMPOUND  147
    ## 20           /Domain_03/OSBS/min_30      boom_5   H5I_GROUP              
    ## 21    /Domain_03/OSBS/min_30/boom_5 temperature H5I_DATASET COMPOUND  147
    ## 22           /Domain_03/OSBS/min_30   tower_top   H5I_GROUP              
    ## 23 /Domain_03/OSBS/min_30/tower_top temperature H5I_DATASET COMPOUND  147
    ## 24                                /   Domain_10   H5I_GROUP              
    ## 25                       /Domain_10        STER   H5I_GROUP              
    ## 26                  /Domain_10/STER       min_1   H5I_GROUP              
    ## 27            /Domain_10/STER/min_1      boom_1   H5I_GROUP              
    ## 28     /Domain_10/STER/min_1/boom_1 temperature H5I_DATASET COMPOUND 4323
    ## 29            /Domain_10/STER/min_1      boom_2   H5I_GROUP              
    ## 30     /Domain_10/STER/min_1/boom_2 temperature H5I_DATASET COMPOUND 4323
    ## 31            /Domain_10/STER/min_1      boom_3   H5I_GROUP              
    ## 32     /Domain_10/STER/min_1/boom_3 temperature H5I_DATASET COMPOUND 4323
    ## 33                  /Domain_10/STER      min_30   H5I_GROUP              
    ## 34           /Domain_10/STER/min_30      boom_1   H5I_GROUP              
    ## 35    /Domain_10/STER/min_30/boom_1 temperature H5I_DATASET COMPOUND  147
    ## 36           /Domain_10/STER/min_30      boom_2   H5I_GROUP              
    ## 37    /Domain_10/STER/min_30/boom_2 temperature H5I_DATASET COMPOUND  147
    ## 38           /Domain_10/STER/min_30      boom_3   H5I_GROUP              
    ## 39    /Domain_10/STER/min_30/boom_3 temperature H5I_DATASET COMPOUND  147

    # now we can use this object to pull group paths from our file!
    fiu_struct[3,1]

    ## [1] "/Domain_03/OSBS"

    ## Let's view the metadata for the OSBS group
    OSBS  <- h5readAttributes(f,fiu_struct[3,1])
    
    # view the attributes
    OSBS

    ## $LatLon
    ## [1] "29.68927/-81.99343"
    ## 
    ## $`Site Name`
    ## [1] "Ordway-Swisher Biological Station Site"

Now we can grab the latitude and longitude for our data from the attributes. 


    # view lat/long
    OSBS$LatLon

    ## [1] "29.68927/-81.99343"

Note, for continued use we may want to convert the format from decimal degrees 
to a different format as this format is more difficult to extract from R!

<div id="ds-challenge" markdown="1">
### Challenge: Further exploration

1. Explore the H5 file further. View attributes for other groups within the file. 
If you have HDFView installed, compare what you see in R to what you see 
in the file visually using the HDFviewer.

2. How would you rewrite the metadata for each site to make it more user friendly? 
Discuss with your neighbor. Map out an H5 file that might be structured in a 
better way to store your data.

</div> 


## Workflows to Extract and Plot From Multiple Groups

The NEON HDF5 file that we are working with contains temperature data collected 
for three days (a very small subset of the available data) by one sensor. What if 
we wanted to create a plot that compared data across sensors or sites? To do this, 
we need to compare data stored within different nested `groups` within our H5 file.

### Complex Data

Data are from different sensors located at different levels at one NEON Field Site,
this multi-nested data can lead to a complex structure. Likely, you'll want to 
work with data from multiple sensors or levels to address your research questions. 

Let's first compare data across temperature sensors located at one site. First, we'll 
loop through the HDF5 file and build a new data frame that contains temperature 
data for each boom on the tower. We'll use the 1-minute averaged data from the NEON 
field site: Ordway Swisher Biological Station located in Florida.


    # use dplyr to subset data by dataset name (temperature)
    # and site / 1 minute average
    newStruct <- fiu_struct %>% filter(grepl("temperature",name),
                                       grepl("OSBS/min_1",group))
    
    #create final paths to access each temperature dataset
    paths <- paste(newStruct$group,newStruct$name,sep="/")
    
    #create a new, empty data.frame
    OSBS_temp <- data.frame()

The above code uses `dplyr` to filter data. Let's break the code down. 
<a href="http://cran.rstudio.com/web/packages/dplyr/" target="_blank">
Read more about the `dplyr` package here</a>

- `fiu_struct`, defined above in the code, is the structure of our HDF5 file 
that we returned using `h5ls`.
- `grepl` looks for a text pattern. Type `help(grepl)` to learn more. If we want 
to return all "paths" in the HDF file that contain the word `temperature` in 
the `$name` column, then we type `grepl("temperature",name)`
- `filter` allows us to look for multiple strings in one command. `help(filter)`
- `%>%` is a `pipe` - syntax specific to the `dplyr` package. It allows you to 
'chain' or combine multiple queries together into one, concise, line of code. 

Pulling this together, type, `fiu_struct %>% filter(grepl("OSBS/min_1",group))` 
in to the R console. What happens?


Next, we will create a loop that will populate the final `data.frame` that contains 
information for all booms in the site that we want to plot.



    #loop through each temp dataset and add to data.frame
    for(i in paths){
      datasetName <- i
      print(datasetName) 
      #read in each dataset in the H5 list
      dat <- h5read(f,datasetName)
      # add boom name to data.frame
      print(strsplit(i,"/")[[1]][5]) 
      dat$boom <- strsplit(i,"/")[[1]][5]
      OSBS_temp <- rbind(OSBS_temp,dat)
    }

    ## [1] "/Domain_03/OSBS/min_1/boom_1/temperature"
    ## [1] "boom_1"
    ## [1] "/Domain_03/OSBS/min_1/boom_2/temperature"
    ## [1] "boom_2"
    ## [1] "/Domain_03/OSBS/min_1/boom_3/temperature"
    ## [1] "boom_3"
    ## [1] "/Domain_03/OSBS/min_1/boom_5/temperature"
    ## [1] "boom_5"
    ## [1] "/Domain_03/OSBS/min_1/tower_top/temperature"
    ## [1] "tower_top"


The loop above iterates through the file and grabs the temperature data for each 
boom in the 1 minute data series for Ordway. It also adds the boom name to the 
end of the `data.frame` as follows: 

- `for i in path$path`: loop through each `path` in the `path` object. NOTE: 
the boom 4 sensor was not operational when this HDF5 file was created, which is 
why there is no boom 4 in our list! Thus we will need do iterate through the 
data 5 times instead of 6.
- `dat <- h5read(f,i)`: read in the temperature dataset from our hdf5 file (f) 
for path `i`.
-  `dat$boom <- strsplit(i,"/")[[1]][5]: add the boom name to a column called 
`boom` in our data.frame
-  `ord_temp <- rbind(ord_temp,dat)`: append dataset to the end of the data.frame

    
<div id="ds-challenge" markdown="1">
### Challenge: Modify Loops

Modify the loop above so that it adds both the boom name, the site name and 
the data type (1 minute) as columns in our data frame.

</div>

### Cleaning Up Dates
The dates field in our data frame aren't imported by default in "date format". 
We need to tell R to format the information as a date. Formatting out date fields 
also allows us to properly label the x axis of our plots.

Once the dates have been formatted we can create a plot with cleaner X axis labels.


    #fix the dates
    OSBS_temp$date <- as.POSIXct(OSBS_temp$date,format = "%Y-%m-%d %H:%M:%S", tz = "EST")
    
    #plot the data
    OSBS_allPlot <-ggplot(OSBS_temp,aes(x=date,y=mean,group=boom,colour=boom))+
      geom_path()+
      ylab("Mean temperature") + xlab("Date")+
      theme_bw()+
      ggtitle("3 Days of temperature data at Ordway Swisher")+
      scale_x_datetime(breaks=pretty_breaks(n=4))
    
    OSBS_allPlot

![ ]({{ site.baseurl }}/images/rfigs/HDF5/R-Timeseries-HDF5/plotBoomData-1.png)

## Data from different sites

Next, let's compare temperature at two different sites: Ordway Swisher Biological 
Station (OSBS) located in Florida and North Sterling (STER) located in north 
central Colorado. This time we'll plot data averaged every 30 minutes instead of 
every minute. We'll need to modify our search strings a bit. But we can still 
re-use most of the code that we just built.


    # grab just the paths to temperature data, 30 minute average
    pathStrux <- fiu_struct %>% filter(grepl("temperature",name), 
                                       grepl("min_30",group)) 
    # create final paths
    paths <- paste(pathStrux$group,pathStrux$name,sep="/")
    
    # create empty dataframe
    temp_30 <- data.frame()
    
    for(i in paths){
      #create columns for boom name and site name
      boom <-  strsplit(i,"/")[[1]][5]
      site <- strsplit(i,"/")[[1]][3]
      dat <- h5read(f,i)
      dat$boom <- boom
      dat$site <- site
     temp_30 <- rbind(temp_30,dat)
    }
    
    # Assign the date field to a "date" format in R
    temp_30$date <- as.POSIXct(temp_30$date,format = "%Y-%m-%d %H:%M:%S")
    
    # generate a mean temperature for every date across booms
    temp30_sum <- temp_30 %>% group_by(date,site) %>% summarise(mean = mean(mean))
    
    # Create plot!
    compPlot <- ggplot(temp30_sum,aes(x=date,y=mean,group=site,colour=site)) + 
      geom_path()+ylab("Mean temperature, 30 Minute Average") + 
      xlab("Date")+
      theme_bw()+
      ggtitle("Comparison of OSBS (FL) vs STER (CO)") +
      scale_x_datetime( breaks=pretty_breaks(n=4))
    
    compPlot

![ ]({{ site.baseurl }}/images/rfigs/HDF5/R-Timeseries-HDF5/compareGroupData-1.png)

