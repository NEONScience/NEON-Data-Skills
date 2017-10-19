---
syncID: 2e8e865ff45e47f2b1ba26c0992baa9e
title: "Time Series 02: Dealing With Dates & Times in R - as.Date, POSIXct, POSIXlt"
description: "This tutorial explores working with date and time classes in R. We will overview the differences between As.Date, POSIXct and POSIXlt as used to convert a date/time field in character (string) format to a date-time format that is recognized by R. This conversion supports efficient plotting, subsetting and analysis of time series data."
dateCreated: 2015-10-22
authors: Megan A. Jones, Marisa Guarinello, Courtney Soderberg, Leah A. Wasser
contributors: Leah A. Wasser
estimatedTime:
packagesLibraries: lubridate
topics: time-series, phenology
languagesTool:
dataProduct:
code1: /R/dc-tabular-time-series/02-Time-Date-Classes-POSIX-In
tutorialSeries: tabular-time-series
urlTitle: dc-convert-date-time-POSIX-r
---


This tutorial explores working with date and time field in R. We will overview
the differences between `as.Date`, `POSIXct` and `POSIXlt` as used to convert
a date / time field in character (string) format to a date-time format that is 
recognized by `R`. This conversion supports efficient plotting, subsetting and
analysis of time series data.


<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

* Describe various date-time classes and data structure in `R`. 
* Explain the difference between `POSIXct` and `POSIXlt` data classes are and 
why POSIXct may be preferred for some tasks. 
* Convert a column containing date-time information in character
format to a date-time `R` class.
* Convert a date-time column to different date-time classes. 
* Write out a date-time class object in different ways (month-day,
month-day-year, etc). 

## Things You’ll Need To Complete This Tutorials
You will need the most current version of R and, preferably, RStudio loaded on
your computer to complete this tutorial.

### Install R Packages
* **lubridate:** `install.packages("lubridate")`

<a href="{{ site.baseurl }}/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Download Data 
{% include/dataSubsets/_data_Met-Time-Series.html %}

****

{% include/_greyBox-wd-rscript.html %}
</div>

## The Data Approach
In the [Intro to Time Series Data in R tutorial ]({{ site.baseurl }}/dc-brief-tabular-time-series-qplot-r)
we imported a time series dataset in `.csv` format into `R`. We learned how to 
quickly plot these data by converting the date column to an `R` `Date` class.
In this tutorial we will explore how to work with a column that contains both a
date AND a time stamp.

We will use functions from both base `R` and the `lubridate` package to work 
with date-time data classes.


    # Load packages required for entire script
    library(lubridate)  #work with dates
    
    # set working directory to ensure R can find the file we wish to import
    # setwd("working-dir-path-here")

## Import CSV File
First, let's import our time series data. We are interested in temperature, 
precipitation and photosynthetically active radiation (PAR) - metrics that are 
strongly associated with vegetation green-up and brown down (phenology or 
phenophase timing). We will use the `hf001-10-15min-m.csv` file 
that contains atmospheric data for the NEON Harvard Forest field site,
aggregated at 15-minute intervals. 


    # Load csv file of 15 min meteorological data from Harvard Forest
    # Factors=FALSE so strings, series of letters/words/numerals, remain characters
    harMet_15Min <- read.csv(
      file="NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-10-15min-m.csv",
      stringsAsFactors = FALSE)

## Date and Time Data
Let's revisit the data structure of our `harMet_15Min` object. What is the class
of the `date-time` column?


    # view column data class
    class(harMet_15Min$datetime)

    ## [1] "character"

    # view sample data
    head(harMet_15Min$datetime)

    ## [1] "2005-01-01T00:15" "2005-01-01T00:30" "2005-01-01T00:45"
    ## [4] "2005-01-01T01:00" "2005-01-01T01:15" "2005-01-01T01:30"

Our `datetime` column is stored as a `character` class. We need to convert it to 
date-time class. What happens when we use the `as.Date` method that we learned
about in the 
[Intro to Time Series Data in R ]({{ site.baseurl }}/dc-brief-tabular-time-series-qplot-r "for as.Date") 
tutorial?


    # convert column to date class
    dateOnly_HARV <- as.Date(harMet_15Min$datetime)
    
    # view data
    head(dateOnly_HARV)

    ## [1] "2005-01-01" "2005-01-01" "2005-01-01" "2005-01-01" "2005-01-01"
    ## [6] "2005-01-01"

When we use `as.Date`, we lose the time stamp. 

### Explore Date and Time Classes

#### R - Date Class - as.Date
As we just saw, the `as.Date` format doesn't store any time information. When we
use the`as.Date` method to convert a date stored as a character class to an `R`
`date` class, it will ignore all values after the date string.


    # Convert character data to date (no time) 
    myDate <- as.Date("2015-10-19 10:15")   
    str(myDate)

    ##  Date[1:1], format: "2015-10-19"

    # what happens if the date has text at the end?
    myDate2 <- as.Date("2015-10-19Hello")   
    str(myDate2)

    ##  Date[1:1], format: "2015-10-19"

As we can see above the `as.Date()` function will convert the characters that it
recognizes to be part of a date into a date class and ignore all other 
characters in the string. 

#### R - Date-Time - The POSIX classes
If we have a column containing both date and time we need to use a class that
stores both date AND time. Base `R` offers two closely related classes for date
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
is most often your local time zone. 

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
<i class="fa fa-star"></i>**Data Tip:** The `unclass` method in `R` allows you
to view how a particular `R` object is stored.
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

When we convert a string to `POSIXlt`, and view it in `R`, it still looks
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
<i class="fa fa-star"></i>**Data Tip:** To learn more about how `R` stores
information within date-time and other objects check out the `R` documentation
by using `?` (e.g., `?POSIXlt`). NOTE: you can use this same syntax to learn
about particular functions (e.g., `?ggplot`).  
</div>

Having dates classified as separate components makes `POSIXlt` computationally
more resource intensive to use in `data.frames`. This slows things down! We will
thus use `POSIXct` for this tutorial.  

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip:** There are other `R` packages that
support date-time data classes, including `readr`, `zoo` and `chron`.  
</div>

## Convert to Date-time Class

When we convert from a character to a date-time class we need to tell `R` how 
the date and time information are stored in each string. To do this, we can use
`format=`. Let's have a look at one of our date-time strings to determine it's 
format.


    # view one date-time field
    harMet_15Min$datetime[1]

    ## [1] "2005-01-01T00:15"

Looking at the results above, we see that our data are stored in the format:
Year-Month-Day "T" Hour:Minute (`2005-01-01T00:15`). We can use this information 
to populate our `format` string using the following designations for the
components of the date-time data:

* %Y - year 
* %m - month
* %d - day
* %H:%M - hours:minutes

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip:** A list of options for date-time format
is available in the `strptime` function help: `help(strptime)`. Check it out!   
</div>

The "T" inserted into the middle of `datetime` isn't a standard character for 
date and time, however we can tell `R` where the character is so it can ignore 
it and interpret the correct date and time as follows:
`format="%Y-%m-%dT%H:%M"`.  


    # convert single instance of date/time in format year-month-day hour:min:sec
    as.POSIXct(harMet_15Min$datetime[1],format="%Y-%m-%dT%H:%M")

    ## [1] "2005-01-01 00:15:00 MST"

    ## The format of date-time MUST match the specified format or the data will not
    # convert; see what happens when you try it a different way or without the "T"
    # specified
    as.POSIXct(harMet_15Min$datetime[1],format="%d-%m-%Y%H:%M")

    ## [1] NA

    as.POSIXct(harMet_15Min$datetime[1],format="%Y-%m-%d%H:%M")

    ## [1] NA

Using the syntax we've learned, we can convert the entire `datetime` column into 
`POSIXct` class.


    new.date.time <- as.POSIXct(harMet_15Min$datetime,
                                format="%Y-%m-%dT%H:%M" #format time
                                )
    
    # view output
    head(new.date.time)

    ## [1] "2005-01-01 00:15:00 MST" "2005-01-01 00:30:00 MST"
    ## [3] "2005-01-01 00:45:00 MST" "2005-01-01 01:00:00 MST"
    ## [5] "2005-01-01 01:15:00 MST" "2005-01-01 01:30:00 MST"

    # what class is the output
    class(new.date.time)

    ## [1] "POSIXct" "POSIXt"


### About Time Zones
Above, we successfully converted our data into a date-time class. However, what 
`timezone` is the output `new.date.time` object that we created using? 

`2005-04-15 03:30:00 MDT`

It appears as if our data were assigned MDT (which is the timezone of the
computer where these tutorials were processed originally - in Colorado - Mountain
Time). However, we know from the metadata, explored in the
[Why Metadata Are Important: How to Work with Metadata in Text & EML Format tutorial ]({{ site.baseurl }}/dc-metadata-importance-eml-r),
that these data were stored in Eastern Standard Time.

### Assign Time Zone

When we convert a date-time formatted column to `POSIXct` format, we need to
assign an associated **time zone**. If we don't assign a time zone,`R` will 
default to the local time zone that is defined on your computer. 
There are individual designations for different time zones and time zone 
variants (e.g., does the time occur during daylight savings time). 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip:** Codes for time zones can be found in this 
<a href="https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"
target="_blank">time zone table</a>. 
</div>

The code for the Eastern time zone that is the closest match to the NEON Harvard
Forest field site is `America/New_York`. Let's convert our `datetime` field 
one more time, and define the associated timezone (`tz=`).


    # assign time zone to just the first entry
    as.POSIXct(harMet_15Min$datetime[1],
                format = "%Y-%m-%dT%H:%M",
                tz = "America/New_York")

    ## [1] "2005-01-01 00:15:00 EST"

The output above, shows us that the time zone is now correctly set as EST.  

### Convert to Date-time Data Class

Now, using the syntax that we learned above, we can convert the entire
`datetime` column to a `POSIXct` class.


    # convert to POSIXct date-time class
    harMet_15Min$datetime <- as.POSIXct(harMet_15Min$datetime,
                                    format = "%Y-%m-%dT%H:%M",
                                    tz = "America/New_York")
    
    # view structure and time zone of the newly defined datetime column
    str(harMet_15Min$datetime)

    ##  POSIXct[1:376800], format: "2005-01-01 00:15:00" "2005-01-01 00:30:00" ...

    tz(harMet_15Min$datetime)

    ## [1] "America/New_York"

Now that our `datetime` data are properly identified as a `POSIXct` date-time
data class we can continue on and look at the patterns of precipitation,
temperature, and PAR through time. 
