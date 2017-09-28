---
syncID: 344014eb3c9542f9b491e7955288f8c4
title: "Convert to Julian Day"
description: "This tutorial explains why Julian days are useful and teaches how to create a Julian day variable from a Date or Data/Time class variable."
dateCreated: 2015-10-18
authors: Megan A. Jones, Marisa Guarinello, Courtney Soderberg, Leah A. Wasser
contributors: 
estimatedTime:
packagesLibraries: lubridate
topics: time-series
languagesTool: R
dataProduct:
code1: /R/dc-tabular-time-series/Convert-to-Julian-Day-In-R.R
tutorialSeries: tabular-time-series
urlTitle: julian-day-conversion-r
---

This tutorial defines Julian (year) day as most often used in an ecological 
context, explains why Julian days are useful for analyis and plotting, and 
teaches how to create a Julian day variable from a Date or Data/Time class 
variable.

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

 * Define a Julian day (year day) as used in most ecological 
 contexts.
 * Convert a Date or Date/Time class variable to a Julian day
 variable.

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, RStudio loaded on your computer to complete this tutorial.

### Install R Packages

* **lubridate:** `install.packages("lubridate")`

[More on Packages in R - Adapted from Software Carpentry.]({{ site.baseurl }}/packages-in-r)

### Download Data 
{% include/dataSubsets/_data_Met-Time-Series.html %}

****
{% include/_greyBox-wd-rscript.html %}

</div>

## Convert Between Time Formats - Julian Days
Julian days, as most often used in an ecological context, is a continuous count 
of the number of days beginning at Jan 1 each year. Thus each year will have up 
to 365 (non-leap year) or 366 (leap year) days. 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Note:** This format can also be called ordinal
day or year day. In some contexts, Julian day can refer specifically to a 
numeric day count since 1 January 4713 BCE or as a count from some other origin 
day, instead of an annual count of 365 or 366 days.
</div>

Including a Julian day variable in your data set can be very useful when
comparing data across years, when plotting data, and when matching your data
with other types of data that include Julian day. 

## Load the Data
Load this data set that we will use to convert a date into a year day or Julian 
day. 

Notice the date is read in as a character and must first be converted to a Date
class.


    # Load packages required for entire script
    library(lubridate)  #work with dates
    
    # set working directory to ensure R can find the file we wish to import
    # setwd("working-dir-path-here")
    
    # Load csv file of daily meterological data from Harvard Forest
    # Factors=FALSE so strings, series of letters/ words/ numerals, remain characters
    harMet_DailyNoJD <- read.csv(
      file="NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-06-daily-m-NoJD.csv",
      stringsAsFactors = FALSE
      )
    
    # what data class is the date column? 
    str(harMet_DailyNoJD$date)

    ##  chr [1:5345] "2/11/01" "2/12/01" "2/13/01" "2/14/01" "2/15/01" ...

    # convert "date" from chr to a Date class and specify current date format
    harMet_DailyNoJD$date<- as.Date(harMet_DailyNoJD$date, "%m/%d/%y")

## Convert with yday()
To quickly convert from from Date to Julian days, can we use `yday()`, a 
function from the `lubridate` package. 


    # to learn more about it type
    ?yday

We want to create a new column in the existing data frame, titled `julian`, that
contains the Julian day data.  


    # convert with yday into a new column "julian"
    harMet_DailyNoJD$julian <- yday(harMet_DailyNoJD$date)  
    
    # make sure it worked all the way through. 
    head(harMet_DailyNoJD$julian) 

    ## [1] 42 43 44 45 46 47

    tail(harMet_DailyNoJD$julian)

    ## [1] 268 269 270 271 272 273

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip:**  In this tutorial we converted from
`Date` class to a Julian day, however, you can convert between any recognized
date/time class (POSIXct, POSIXlt, etc) and Julian day using `yday`.  
</div>
