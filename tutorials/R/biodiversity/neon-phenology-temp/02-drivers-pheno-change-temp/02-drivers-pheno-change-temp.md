---
syncID: dca9f480763e4d9f816f51abcf77f70a
title: "Work with NEON's Single-Aspirated Air Temperature Data"
description: "This tutorial demonstrates how to work with NEON single-asperated air temperature data. Specific tasks include conversion to POSIX date/time class, subsetting by date, and plotting the data."
dateCreated: 2017-08-01
authors: Lee Stanish, Megan A. Jones, Natalie Robinson
contributors: Katie Jones, Cody Flagg, Josh Roberti
estimatedTime:
packagesLibraries: dplyr, ggplot2, lubridate
topics: time-series, meteorology
languagesTool: R
dataProduct: NEON.DP1.00002, NEON.DP1.00003
code1: R/NEON-pheno-temp-timeseries/02-drivers-pheno-change-temp.R
tutorialSeries: neon-pheno-temp-series
urlTitle: neon-SAAT-temp-r

---

In this tutorial, we explore the NEON single-aspirated air temperature data. We
start using data that has already been "stacked" using the 
<a href="https://www.neonscience.org/neonDataStackR-temp" target="_blank"> neonDataStackR package</a>. 
We then discuss how to interpret the variables, how to work with date-time and 
date formats, and finally how to plot the data. 

This lesson is part of a series on how to work with both discrete and continuous
time series data. 


<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:

 * work with "stacked" NEON Single-Aspirated Air Temperature data. 
 * correctly format date-time data. 
 * use dplyr functions to filter data.
 * plot time series data in scatter plots using ggplot function. 

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages
* **ggplot2:** `install.packages("ggplot2")`
* **dplyr:** `install.packages("dplyr")`
* **scales:** `install.packages("scales")`
* **tidyr:** `install.packages("tidyr")`
* **lubridate:** `install.packages("lubridate")`


<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Download Data

{% include/dataSubsets/_data_NEON-pheno-temp-timeseries.html %}

****
{% include/_greyBox-wd-rscript.html %}

****

## Additional Resources

* NEON <a href="http://data.neonscience.org" target="_blank"> data portal </a>
* RStudio's <a href="https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf" target="_blank"> data wrangling (dplyr/tidyr) cheatsheet</a>
* <a href="https://github.com/NEONScience" target="_blank">NEONScience GitHub Organization</a>
* <a href="https://cran.r-project.org/web/packages/nneo/index.html" target="_blank">nneo API wrapper on CRAN </a>
* RStudio's <a href="https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf" target="_blank"> data wrangling (dplyr/tidyr) cheatsheet</a>
* Hadley Wickham's 
 <a href="http://docs.ggplot2.org/" target="_blank"> documentation</a> 
 on the `ggplot2` package. 
* Winston Chang's
 <a href="http://www.cookbook-r.com/Graphs/index.html" target="_blank"> 
 *Cookbook for R*</a> site based on his *R Graphics Cookbook* text. 

</div>

## Explore Temperature Data 

The following sections provide a brief overview of the NEON single aspirated
air temperature data. When designing a research project using this data, you 
need to consult the 
<a href="http://data.neonscience.org/data-products/DP1.10055.001" target="_blank">documents associated with this data product</a> and not rely solely on this summary. 

### NEON Air Temperature Data

Temperature is continuously monitored by NEON a by two methods. At terrestrial 
sites temperature for the top of the tower will be derived from the triple 
redundant aspirated air temperature sensor. This is provided as NEON data 
product **NEON.DP1.00003**.  Single Aspirated Air Temperature 
Sensors (SAATS) are deployed to develop temperature profiles at the tower at NEON
terrestrial sites and on the micromet station at NEON aquatic sites. This is 
provided as NEON data product 
**NEON.DP1.00002**.

#### Single-aspirated Air Temperature

Temperature profiles will be ascertained by deploying SAATS at various heights 
on the core tower infrastructure and mobile platforms. Air temperature at 
aquatic sites will be measured using a single SAAT at a standard height of 3m 
above ground level. Air temperature for this data product is provided as 
one- and thirty-minute averages of 1 Hz observations. Temperature observations 
are made using platinum resistance thermometers, which are housed in a fan 
aspirated shield to reduce radiative bias. The temperature is measured in Ohms 
and subsequently converted to degrees Celsius. Details on the conversion can be
found in the associated Algorithm Theoretic Basis Document (ATBD). 

#### Available Data Tables

When downloaded, data comes with several .csv file for each site and month-year 
selected. There is a 1-minute average and a 30-minute average for each level at 
which there is a sensor. It is important to understand the file names to know 
which file is which. 

The readme associated with the data provides the following information: 
The file naming convention for sensor data files is **NEON.DOM.SITE.DPL.PRNUM.REV.TERMS.HOR.VER.TMI.DESC** 

where:

* **DOM** refers to the domain of data acquisition (D01 or D20)
* **SITE** refers to the standardized four-character alphabetic code of the site of 
data acquisition.
* **DPL** refers to the data product processing level
* **PRNUM** refers to the data product number (see 
<a href="http://data.neonscience.org/data-products/explore" target="_blank">Explore Data Products</a>.)
* **REV** refers to the revision number of the data product. (001 = initial REV, Engineering-Grade or Provisional; 101 = initial REV, Science-Grade)
* **TERMS** is used in data product numbering to identify a sub-product or discrete 
vector of metadata. Since each download file typically contains several 
sub-products, this field is set to 00000 in the file name to maintain 
consistency with the data product numbering scheme.
* **HOR** refers to measurement locations within one horizontal plane. 
* **VER** refers to measurement locations within one vertical plane. For example, 
if eight temperature measurements are collected, one at each tower level, the 
number in the VER field would range from 010-080.
* **TMI** is the Temporal Index; refers to the temporal representation, averaging 
period, or coverage of the data product (e.g., minute, hour, month, year, 
sub-hourly, day, lunar month, single instance, seasonal, annual, multi-annual)
* **DESC** is an abbreviated description of the data product 

Therefore, we can interpret the following .csv file name

**NEON.D02.SERC.DP1.00002.001.00000.000.010.030.SAAT_30min.csv**

as NEON data from Smithsonian Environmental Research Center (SERC) located in 
Domain 02 (D02). The specific data product is level 1 data product (DP1) and is 
single aspirated temperature data (00002). There have not been revisions, there 
are no associated terms, and there is no differentiation in horizontal plane. 
This data comes from the first (010) vertical level of the tower. The temporal 
interval is 30-minute averaged data (030; the other option in our data is 1 minute 
averaging. Finally there is the abbreviated description that is more human readable
and tells us again that it is single-aspirated air temperature at 30 minute averages.  

## Stack NEON Data

All the above data are delivered in a site and year-month format. When you download data,
you will get a single zipped file containing a directory for each month and site that you've 
requested data for. Dealing with these separate files from even one or two sites
over a 12 month period can be a bit overwhelming. Luckily NEON provides an R package
**neonUtilities** that takes the unzipped downloaded file and joining the data 
files. 

For more on this function check out the 
<a href="{{ site.baseurl }}neonDataStackR" target="_blank"> *Use the neonDataStackR package to access NEON data* tutorial</a>. 

When we do this for our temperature data we get two files, one for 1 minute SAAT
and 30 minute SAAT, with all the data from your site and date range of interest. 

Let's start by loading our data of interest.

## Import Data

This tutorial uses 30 minute temperature data from the single aspirated
temperature sensors mounted on level 03 of the NEON tower.



    # Load required libraries
    library(ggplot2)
    library(dplyr)
    library(tidyr)
    library(lubridate)
    library(scales)
    
    # set working directory to ensure R can find the file we wish to import
    # setwd("working-dir-path-here")
    
    # Read in data
    temp30_sites <- read.csv('NEON-pheno-temp-timeseries/temp/SAAT_30min.csv', stringsAsFactors = FALSE)

    ## Warning in file(file, "rt"): cannot open file 'NEON-pheno-temp-timeseries/temp/
    ## SAAT_30min.csv': No such file or directory

    ## Error in file(file, "rt"): cannot open the connection

## Explore Temp. Data

Now that you have the data, let's take a look at the readme and understand 
what's in the data. 


    # Get a general feel for the data: View structure of data frame
    str(temp30_sites)

    ## Error in str(temp30_sites): object 'temp30_sites' not found

View readme and variables file. This will guide you on what the data are.

## Select Site(s) of Interest

Currently, we have data from several sites in our dataset. Let's start by 
limiting the data to our site of interest. 

The following format allows us to easily change sites or select data from 
multiple sites. 


    # set site of interest
    siteOfInterest <- c("SCBI")
    
    # use filter to select only the site of Interest 
    # using %in% allows one to add a vector if you want more than one site. 
    temp30 <- filter(temp30_sites, siteID%in%siteOfInterest)

    ## Error in filter(temp30_sites, siteID %in% siteOfInterest): object 'temp30_sites' not found

## Quality Flags

The sensor data undergo a variety of quality assurance and quality control 
checks. Data can pass or fail these many checks. The expanded data package 
includes all of these quality flags, which can allow you to decide if not passing
one of the checks will significantly hamper your research and if you should 
therefore remove the data from your analysis. The data that we are using is the
basic data package and only includes the `finalQF` flag. 

A pass of the check is **0**, while a fail is **1**. Let's see if we have data 
with a quality flag. 


    # Are there quality flags in your data? Count 'em up
    
    sum(temp30$finalQF==1)

    ## Error in eval(expr, envir, enclos): object 'temp30' not found

How do we want to deal with this quality flagged data. This may depend on why it
is flagged and what questions you are asking. The expanded data package will be
useful for determining this.  

For our demonstration purposes here we will keep the flagged data.  

What about null (`NA`) data? 


    # Are there NA's in your data? Count 'em up
    sum(is.na(temp30$tempSingleMean) )

    ## Error in eval(expr, envir, enclos): object 'temp30' not found

    mean(temp30$tempSingleMean)

    ## Error in mean(temp30$tempSingleMean): object 'temp30' not found

Why was there no output? 

We had previously seen that there are NA values in the temperature data. Given 
there are NA values, R, by default, won't calculate a mean (and many other 
summary statistics) as the NA values could skew the data. 

`na.rm=TRUE` 

tells R to ignore them for calculation,etc


    # create new dataframe without NAs
    temp30_noNA <- temp30 %>%
    	drop_na(tempSingleMean)  # tidyr function

    ## Error in eval(lhs, parent, parent): object 'temp30' not found

    # alternate base R
    # temp30_noNA <- temp30[!is.na(temp30$tempSingleMean),]
    
    # did it work?
    sum(is.na(temp30_noNA$tempSingleMean))

    ## Error in eval(expr, envir, enclos): object 'temp30_noNA' not found

What is the range of dates in our dataset? 
 

    # View the date range
    range(temp30_noNA$startDateTime)

    ## Error in eval(expr, envir, enclos): object 'temp30_noNA' not found

    # what format are they in? 
    str(temp30_noNA$startDateTime)

    ## Error in str(temp30_noNA$startDateTime): object 'temp30_noNA' not found

Ah, here we have a date and time format and there are non standard characters in 
it. Currently our data are in character format. We will need to convert them into 
a date-time format. 

## R - Date-Time - The POSIX classes
If we have a column containing both date and time we need to use a class that
stores both date AND time. Base R offers two closely related classes for date
and time: `POSIXct` and `POSIXlt`. 

#### POSIXct

The `as.POSIXct` method converts a date-time string into a `POSIXct` class. 


    # Convert character data to date and time.
    timeDate <- as.POSIXct("2015-10-19 10:15")   
    str(timeDate)

    ##  POSIXct[1:1], format: "2015-10-19 10:15:00"

    timeDate

    ## [1] "2015-10-19 10:15:00 MDT"

`as.POSIXct` stores both a date and time with an associated time zone. The
default time zone selected, is the time zone that your computer is set to which
is most often your local time zone (Mountain Daylight Time in this example). 

`POSIXct` stores date and time in seconds with the number of seconds beginning
at 1 January 1970. Negative numbers are used to store dates prior to 1970. 
Thus, the `POSIXct` format stores each date and time a single value in units of
seconds. Storing the data this way, optimizes use in `data.frames` and speeds up
computation, processing and conversion to other formats. 


    # to see the data in this 'raw' format, i.e., not formatted according to the 
    # class type to show us a date we recognize, use the `unclass()` function.
    unclass(timeDate)

    ## [1] 1445271300
    ## attr(,"tzone")
    ## [1] ""

Here we see the number of seconds from 1 January 1970 to 9 October 2015
(`1445271300`). Also, we see that a time zone (`tzone`) is associated with the value in seconds. 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** The `unclass` method in R allows you
to view how a particular R object is stored.
</div>

#### POSIXlt
The `POSIXct` format is optimized for storage and computation. However, humans 
aren't quite as computationally efficient as computers! Also, we often want to 
quickly extract some portion of the data (e.g., months). The `POSIXlt` class 
stores date and time information in a format that we are used to seeing (e.g., 
second, min, hour, day of month, month, year, numeric day of year, etc). 



    # Convert character data to POSIXlt date and time
    timeDatelt<- as.POSIXlt("2015-10-19 10:15")  
    str(timeDatelt)

    ##  POSIXlt[1:1], format: "2015-10-19 10:15:00"

    timeDatelt

    ## [1] "2015-10-19 10:15:00 MDT"

    unclass(timeDatelt)

    ## $sec
    ## [1] 0
    ## 
    ## $min
    ## [1] 15
    ## 
    ## $hour
    ## [1] 10
    ## 
    ## $mday
    ## [1] 19
    ## 
    ## $mon
    ## [1] 9
    ## 
    ## $year
    ## [1] 115
    ## 
    ## $wday
    ## [1] 1
    ## 
    ## $yday
    ## [1] 291
    ## 
    ## $isdst
    ## [1] 1
    ## 
    ## $zone
    ## [1] "MDT"
    ## 
    ## $gmtoff
    ## [1] NA

When we convert a string to `POSIXlt`, and view it in R, it still looks
similar to the `POSIXct` format. However, `unclass()` shows us that the data are
stored differently. The `POSIXlt` class stores the hour, minute, second, day,
month, and year separately.

#### Months in POSIXlt 
`POSIXlt` has a few quirks. First, the month values stored in the `POSIXlt`
object use `zero-based indexing`. This means that month #1 (January) is stored
as 0, and month #2 (February) is stored as 1. Notice in the output above,
October is stored as the 9th month (`$mon = 9`).

#### Years in POSIXlt 
Years are also stored differently in the `POSIXlt` class. Year values are stored
using a base index value of 1900. Thus, 2015 is stored as 115 (`$year = 115` 
- 115 years since 1900).

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** To learn more about how R stores
information within date-time and other objects check out the R documentation
by using `?` (e.g., `?POSIXlt`). NOTE: you can use this same syntax to learn
about particular functions (e.g., `?ggplot`).  
</div>

Having dates classified as separate components makes `POSIXlt` computationally
more resource intensive to use in `data.frames`. This slows things down! We will
thus use `POSIXct` for this tutorial.  

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** There are other R packages that
support date-time data classes, including `readr`, `zoo` and `chron`.  
</div>

## Convert to Date-time Class

When we convert from a character to a date-time class we need to tell R how 
the date and time information are stored in each string. To do this, we can use
`format=`. Let's have a look at one of our date-time strings to determine it's 
format.


    # view one date-time field
    temp30_noNA$startDateTime[1]

    ## Error in eval(expr, envir, enclos): object 'temp30_noNA' not found

Looking at the results above, we see that our data are stored in the format:
Year-Month-Day "T" Hour:Minute (`2005-04-26T12:00:00Z`). We can use this 
information to populate our `format` string using the following designations for 
the components of the date-time data:

* %Y - year 
* %m - month
* %d - day
* %H:%M:%S - hours:minutes:seconds

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** A list of options for date-time format
is available in the `strptime` function help: `help(strptime)`. Check it out!
</div>

The "T" inserted into the middle of `datetime` isn't a standard character for 
date and time, nor is the "Z" at the end, however we can tell R where the
characters are so R can ignore them and interpret the correct date and time 
as follows: `format="%Y-%m-%dT%H:%M:%"`.

All NEON data are reported in UTC which is the same as GMT.


    # convert to Date Time 
    temp30_noNA$startDateTime <- as.POSIXct(temp30_noNA$startDateTime,
    																				format = "%Y-%m-%dT%H:%M:%SZ", tz = "GMT")

    ## Error in as.POSIXct(temp30_noNA$startDateTime, format = "%Y-%m-%dT%H:%M:%SZ", : object 'temp30_noNA' not found

    # check that conversion worked
    str(temp30_noNA$startDateTime)

    ## Error in str(temp30_noNA$startDateTime): object 'temp30_noNA' not found

Looks good! Except that all the times are in UTC (or GMT), but our phenology are 
daily data. If we want to match the two up precisely, we'd need our date-time 
date on a local time zone to correctly aggregate on a date.  

## Convert to Local Time Zone 

Our site of interest **SCBI** is in the eastern US time zone. We want to convert
to that local time zone so that we can correctly aggreggate date on a daily scale. 
Depending on your research question, this may not be an imperative step. 

We can find out the correct code for our time zone by looking it up: 
<a href="https://en.wikipedia.org/wiki/List_of_tz_database_time_zones" target="_blank"> Wikipedia: List of tz database time zones</a>. 


    ## Convert to Local Time Zone 
    
    ## Conver to local TZ in new column
    temp30_noNA$dtLocal <- format(temp30_noNA$startDateTime, 
    															tz="America/New_York", usetz=TRUE)

    ## Error in format(temp30_noNA$startDateTime, tz = "America/New_York", usetz = TRUE): object 'temp30_noNA' not found

    ## check it
    head(select(temp30_noNA, startDateTime, dtLocal))

    ## Error in select(temp30_noNA, startDateTime, dtLocal): object 'temp30_noNA' not found
Now we have the startDateTime correctly formatted and can now use any function that 
needs a date or date-time class of data. 

## Subset by Date

Now that the date is correctly formatted we can easily choose a desired date
range using the `filter()` function. 

Let's select only the 2016 data. 


    # Limit dataset to dates of interest (2016-01-01 to 2016-12-31)
    # alternatively could use ">=" and start with 2016-01-01 00:00
    temp30_TOI <- filter(temp30_noNA, dtLocal>"2015-12-31 23:59")

    ## Error in filter(temp30_noNA, dtLocal > "2015-12-31 23:59"): object 'temp30_noNA' not found

    # View the date range
    range(temp30_TOI$dtLocal)

    ## Error in eval(expr, envir, enclos): object 'temp30_TOI' not found

<div id="ds-challenge" markdown="1">
### Challenge: Methods Work with Appropriate Classes 
What happens if you try to subset by date using this method if the 
data aren't in a date-time class? Hint: Try it out with our previous `temp30` 
object. 

</div>

For a discussion of date formats is including Date, POSIXct, & POSIXlt see the
NEON Data Skills tutorial
<a href="https://www.neonscience.org/dc-convert-date-time-POSIX-r" target="_blank"> *Time Series 02: Dealing With Dates & Times in R - as.Date, POSIXct, POSIXlt </a>.*


## Scatterplots with ggplot

We can use ggplot to create scatter plots. To create a bar plot, we change the
`geom` element from `geom_bar()` to `geom_point()`.  

Now that we have data subsetted, let's plot the data. But which data to select? 
We have several options: 

* **tempSingleMean**: the mean temperature for the interval
* **tempSingleMinimum**: the minimum temperature during the interval
* **tempSingleMaximum**: the maximum temperature for the interval

Depending on exactly what question you are asking you may prefer to use one over
the other. For many applications, the mean temperature of the one or 30 minute
interval will provide the best representation of the data. 

Let's plot it. 


    # plot temp data
    tempPlot <- ggplot(temp30_TOI, aes(dtLocal, tempSingleMean)) +
        geom_point() +
        ggtitle("Single Asperated Air Temperature") +
        xlab("Date") + ylab("Temp (C)") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))

    ## Error in ggplot(temp30_TOI, aes(dtLocal, tempSingleMean)): object 'temp30_TOI' not found

    tempPlot

    ## Error in eval(expr, envir, enclos): object 'tempPlot' not found

Given all the data -- 68,000+ observations -- it took a little while for that to 
plot.  

What patterns can you see in the data? 

Right now we are looking at all the data points in the dataset. However, we may
want to view or aggregate the data differently:  

* aggregated data: min, mean, or max over a some duration
* the number of days since a freezing temperatures
* or some other segregation of the data.  

Given that in the previous tutorial, 
<a href="https://www.neonscience.org/neon-plant-pheno-data-r" target="_blank"> *Work With NEON's Plant Phenology Data*</a>, 
we were working with phenology data collected on a daily scale let's aggregate
to that level.  

## Aggregate Data by Day

We can use the dplyr package functions to aggregate the data. However, we have to
choose what product we want from the aggregation. Again, you might want daily 
minimum temps, mean temperature or maximum temps depending on your question. 

In the context of phenology, minimum temperatures might be very important if you
are interested in a species that is very frost susceptible. Any days with a 
minimum temperature below 0C could dramatically change the phenophase. For other 
species or climates, maximum thresholds may be very import. Or you might be most
interested in the daily mean.  

For this tutorial, let's stick with maximum daily temperature (of the interval
means).  


    # convert to date, easier to work with
    temp30_TOI$sDate <- as.Date(temp30_TOI$dtLocal)

    ## Error in as.Date(temp30_TOI$dtLocal): object 'temp30_TOI' not found

    # did it work
    str(temp30_TOI$sDate)

    ## Error in str(temp30_TOI$sDate): object 'temp30_TOI' not found

    # max of mean temp each day
    temp_day <- temp30_TOI %>%
    	group_by(sDate) %>%
    	distinct(sDate, .keep_all=T) %>%
    	mutate(dayMax=max(tempSingleMean))

    ## Error in eval(lhs, parent, parent): object 'temp30_TOI' not found

Now we can plot the daily temperature. 


    # plot Air Temperature Data across 2016 using daily data
    tempPlot_dayMax <- ggplot(temp_day, aes(sDate, dayMax)) +
        geom_point() +
        ggtitle("Daily Max Air Temperature") +
        xlab("") + ylab("Temp (C)") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))

    ## Error in ggplot(temp_day, aes(sDate, dayMax)): object 'temp_day' not found

    tempPlot_dayMax

    ## Error in eval(expr, envir, enclos): object 'tempPlot_dayMax' not found

What do we gain by this visualization? What do we loose over the 30 minute 
intervals?  


## ggplot - Subset by Time
Sometimes we want to scale the x- or y-axis to a particular time subset without 
subsetting the entire `data_frame`. To do this, we can define start and end 
times. We can then define these `limits` in the `scale_x_date` object as 
follows:

`scale_x_date(limits=start.end) +`


Let's plot just the first three months of the year. 


    # Define Start and end times for the subset as R objects that are the time class
    startTime <- as.Date("2016-01-01")
    endTime <- as.Date("2016-03-31")
    
    # create a start and end time R object
    start.end <- c(startTime,endTime)
    str(start.end)

    ##  Date[1:2], format: "2016-01-01" "2016-03-31"

    # View data for first 3 months only
    # And we'll add some color for a change. 
    tempPlot_dayMax3m <- ggplot(temp_day, aes(sDate, dayMax)) +
               geom_point(color="blue", size=1) +  # defines what points look like
               ggtitle("Air Temperature\n Jan - March") +
               xlab("Date") + ylab("Air Temperature (C)")+ 
               (scale_x_date(limits=start.end, 
                    date_breaks="1 week",
                    date_labels="%b %d"))

    ## Error in ggplot(temp_day, aes(sDate, dayMax)): object 'temp_day' not found

    tempPlot_dayMax3m

    ## Error in eval(expr, envir, enclos): object 'tempPlot_dayMax3m' not found



    ## Error in is.data.frame(x): object 'temp_day' not found


