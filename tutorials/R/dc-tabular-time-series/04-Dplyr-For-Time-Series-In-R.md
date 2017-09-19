---
syncID: 247b25406fcf482f9f70e408664efc9f
title: "Time Series 04: Subset and Manipulate Time Series Data with dplyr"
description: "In this tutorial, we will use the group_by, summarize and mutate functions in the `dplyr` package to efficiently manipulate atmospheric data collected at the NEON Harvard Forest Field Site. We will use pipes to efficiently perform multiple tasks within a single chunk of code."
dateCreated: 2015-10-22
authors: Megan A. Jones, Marisa Guarinello, Courtney Soderberg, Leah A. Wasser
contributors: Michael Patterson
estimatedTime:
packagesLibraries: ggplot2, dplyr, lubridate
topics: time-series, phenology
languagesTool:
dataProduct:
code1: /R/dc-tabular-time-series/04-Dplyr-For-Time-Series-In-R.R
tutorialSeries: tabular-time-series

---

In this tutorial, we will use the `group_by`, `summarize`and `mutate` functions
in the `dplyr` package to efficiently manipulate atmospheric data collected at
the NEON Harvard Forest Field Site. We will use pipes to efficiently perform
multiple tasks within a single chunk of code.


<div id="ds-objectives" markdown="1">

### Learning Objectives
After completing this tutorial, you will be able to:

 * Explain several ways to manipulate data using functions in the `dplyr`
 package in `R`.
 * Use `group-by()`, `summarize()`, and `mutate()` functions. 
 * Write and understand `R` code with pipes for cleaner, efficient coding.
 * Use the `year()` function from the `lubridate` package to extract year from a
 date-time class variable. 

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, RStudio loaded on
your computer to complete this tutorial.

### Install R Packages
* **lubridate:** `install.packages("lubridate")`
* **dplyr:** `install.packages("dplyr")`
* **ggplot2:** `install.packages("ggplot2")`

[More on Packages in R - Adapted from Software Carpentry.]({{ site.baseurl }}/R/Packages-In-R/)

### Download Data 
{% include/dataSubsets/_data_Met-Time-Series.html %}

****
{% include/_greyBox-wd-rscript.html %}

****

### Additional Resources

* NEON Data Skills tutorial on 
<a href="http://neondataskills.org/R/GREPL-Filter-Piping-in-DPLYR-Using-R/" target="_blank"> spatial data and piping with dplyr</a>  
* Data Carpentry lesson's on 
<a href="http://www.datacarpentry.org/R-ecology/04-dplyr.html" target="_blank">Aggregating and Analyzing Data with dplyr</a> 
* <a href="https://cran.r-project.org/web/packages/dplyr/dplyr.pdf" target="_blank"> `dplyr` package description</a>.
* <a href="http://blog.rstudio.org/2014/01/17/introducing-dplyr/" target="_blank">RStudio Introduction to `dplyr`</a>

</div>

## Introduction to dplyr
The `dplyr` package simplifies and increases efficiency of complicated yet
commonly performed data "wrangling" (manipulation / processing) tasks. It uses
the `data_frame` object as both an input and an output.

### Load the Data
We will need the `lubridate` and the `dplyr` packages to complete this tutorial.

We will also use the 15-minute average atmospheric data subsetted to 2009-2011 
for the NEON Harvard Forest Field Site. This subset was created in the
[Subsetting Time Series Data tutorial]({{ site.baseurl }}/R/subset-data-and-no-data-values/ "2009-2011 HarMet Data Subset"). 

If this object isn't already created, please load the `.csv` version: 
`NEON-DS-Met-Time-Series/HARV/FisherTower-Met/Met_HARV_15min_2009_2011.csv`. Be
sure to convert the date-time column to a POSIXct class after the `.csv` is
loaded. 


    # it's good coding practice to load packages at the top of a script
    
    library(lubridate) # work with dates
    library(dplyr)     # data manipulation (filter, summarize, mutate)
    library(ggplot2)   # graphics
    library(gridExtra) # tile several plots next to each other
    library(scales)
    
    # set working directory to ensure R can find the file we wish to import
    # setwd("working-dir-path-here")
    
    # 15-min Harvard Forest met data, 2009-2011
    harMet15.09.11<- read.csv(
      file="NEON-DS-Met-Time-Series/HARV/FisherTower-Met/Met_HARV_15min_2009_2011.csv",
      stringsAsFactors = FALSE
      )
    # convert datetime to POSIXct
    harMet15.09.11$datetime<-as.POSIXct(harMet15.09.11$datetime,
                        format = "%Y-%m-%d %H:%M",
                        tz = "America/New_York")

## Explore The Data
Remember that we are interested in the drivers of phenology including - 
air temperature, precipitation, and PAR (photosynthetic active radiation - or
the amount of visible light). Using the 15-minute averaged data, we could easily
plot each of these variables.  

![ ]({{ site.baseurl }}/images/rfigs/R/dc-tabular-time-series/04-Dplyr-For-Time-Series-In-R/15-min-plots-1.png)

However, summarizing the data at a coarser scale (e.g., daily, weekly, by
season, or by year) may be easier to visually interpret during initial stages of
data exploration. 

### Extract Year from a Date-Time Column
To summarize by year efficiently, it is helpful to have a year column that we
can use to `group` by. We can use the `lubridate` function `year()` to extract
the year only from a `date-time` class `R` column. 


    # create a year column
    harMet15.09.11$year <- year(harMet15.09.11$datetime)

Using `names()` we see that we now have a `year` column in our `data_frame`.


    # check to make sure it worked
    names(harMet15.09.11)

    ##  [1] "X"        "datetime" "jd"       "airt"     "f.airt"   "rh"      
    ##  [7] "f.rh"     "dewp"     "f.dewp"   "prec"     "f.prec"   "slrr"    
    ## [13] "f.slrr"   "parr"     "f.parr"   "netr"     "f.netr"   "bar"     
    ## [19] "f.bar"    "wspd"     "f.wspd"   "wres"     "f.wres"   "wdir"    
    ## [25] "f.wdir"   "wdev"     "f.wdev"   "gspd"     "f.gspd"   "s10t"    
    ## [31] "f.s10t"   "year"

    str(harMet15.09.11$year)

    ##  num [1:105108] 2009 2009 2009 2009 2009 ...

Now that we have added a year column to our `data_frame`, we can use `dplyr` to 
summarize our data.

## Manipulate Data using dplyr
Let's start by extracting a yearly air temperature value for the Harvard Forest
data. To calculate a yearly average, we need to:

1. Group our data by year.
2. Calculate the mean precipitation value for each group (ie for each year).

We will use `dplyr` functions `group_by` and `summarize` to perform these steps.


    # Create a group_by object using the year column 
    HARV.grp.year <- group_by(harMet15.09.11, # data_frame object
                              year) # column name to group by
    
    # view class of the grouped object
    class(HARV.grp.year)

    ## [1] "grouped_df" "tbl_df"     "tbl"        "data.frame"

The `group_by` function creates a "grouped" object. We can then use this
grouped object to quickly calculate summary statistics by group - in this case,
year. For example, we can count how many measurements were made each year using
the `tally()` function. We can then use the `summarize` function to calculate
the mean air temperature value each year.


    # how many measurements were made each year?
    tally(HARV.grp.year)

    ## # A tibble: 3 x 2
    ##    year     n
    ##   <dbl> <int>
    ## 1  2009 35036
    ## 2  2010 35036
    ## 3  2011 35036

    # what is the mean airt value per year?
    summarize(HARV.grp.year, 
              mean(airt)   # calculate the annual mean of airt
              ) 

    ## # A tibble: 3 x 2
    ##    year `mean(airt)`
    ##   <dbl>        <dbl>
    ## 1  2009           NA
    ## 2  2010           NA
    ## 3  2011     8.746906

Why did this return a `NA` value for years 2009 and 2010? We know there are some
values for both years. Let's check our data for `NoData` values.


    # are there NoData values?
    sum(is.na(HARV.grp.year$airt))

    ## [1] 2

    # where are the no data values
    # just view the first 6 columns of data
    HARV.grp.year[is.na(HARV.grp.year$airt),1:6]

    ## # A tibble: 2 x 6
    ##        X            datetime    jd  airt f.airt    rh
    ##    <int>              <dttm> <int> <dbl>  <chr> <int>
    ## 1 158360 2009-07-08 14:15:00   189    NA      M    NA
    ## 2 203173 2010-10-18 09:30:00   291    NA      M    NA

It appears as if there are two `NoData` values (in 2009 and 2010) that are
causing `R` to return a `NA` for the mean for those years. As we learned
previously, we can use `na.rm` to tell `R` to ignore those values and calculate
the final mean value.


    # calculate mean but remove NA values
    summarize(HARV.grp.year, 
              mean(airt, na.rm = TRUE)
              )

    ## # A tibble: 3 x 2
    ##    year `mean(airt, na.rm = TRUE)`
    ##   <dbl>                      <dbl>
    ## 1  2009                   7.630758
    ## 2  2010                   9.026040
    ## 3  2011                   8.746906

Great! We've now used the `group_by` function to create groups for each year 
of our data. We then calculated a summary mean value per year using `summarize`.

### dplyr Pipes 
The above steps utilized several steps of `R` code and created 1 `R` object - 
`HARV.grp.year`. We can combine these steps using `pipes` in the `dplyr` 
package.

We can use `pipes` to string functions or processing steps together. The output 
of each step is fed directly into the next step using the syntax: `%>%`. This 
means we don't need to save the output of each intermediate step as a new `R`
object.

A few notes about piping syntax:

* A pipe begins with the object name that we will be manipulating, in our case
`harMet15.09.11`.
* It then links that object with first manipulation step using `%>%`.
* Finally, the first function is called, in our case `group_by(year)`. Note
that because we specified the object name in step one above, we can just use the
column name

So, we have: `harMet15.09.11 %>% group_by(year) `

* We can then add an additional function (or more functions!) to our pipe. For
example, we can tell `R` to `tally` or count the number of measurements per
year.

`harMet15.09.11 %>% group_by(year) %>% tally()`

Let's try it!


    # how many measurements were made a year?
    harMet15.09.11 %>% 
      group_by(year) %>%  # group by year
      tally() # count measurements per year

    ## # A tibble: 3 x 2
    ##    year     n
    ##   <dbl> <int>
    ## 1  2009 35036
    ## 2  2010 35036
    ## 3  2011 35036

Piping allows us to efficiently perform operations on our `data_frame` in that:

1. It allows us to condense our code, without naming intermediate steps.
2. The dplyr package is optimized to ensure fast processing!

We can use pipes to summarize data by year too:


    # what was the annual air temperature average 
    year.sum <- harMet15.09.11 %>% 
      group_by(year) %>%  # group by year
      summarize(mean(airt, na.rm=TRUE))
    
    # what is the class of the output?
    year.sum

    ## # A tibble: 3 x 2
    ##    year `mean(airt, na.rm = TRUE)`
    ##   <dbl>                      <dbl>
    ## 1  2009                   7.630758
    ## 2  2010                   9.026040
    ## 3  2011                   8.746906

    # view structure of output
    str(year.sum)

    ## Classes 'tbl_df', 'tbl' and 'data.frame':	3 obs. of  2 variables:
    ##  $ year                    : num  2009 2010 2011
    ##  $ mean(airt, na.rm = TRUE): num  7.63 9.03 8.75


<div id="ds-challenge" markdown="1">
## Challenge: Using Pipes
Use piping to create a `data_frame` called `jday.avg` that contains the average 
`airt` per Julian day (`harMet15.09.11$jd`). Plot the output using `qplot`.

</div>

![ ]({{ site.baseurl }}/images/rfigs/R/dc-tabular-time-series/04-Dplyr-For-Time-Series-In-R/pipe-demo-1.png)

<div id="ds-dataTip">
<i class="fa fa-star"></i>**Data Tip:**  Older `dplyr` versions used the `%.%`
syntax to designate a pipe. Pipes are sometimes referred to as chains. 
{: .notice }

## Other dplyr Functions

`dplyr` works based on a series of *verb* functions that allow us to manipulate
the data in different ways: 

 * `filter()` & `slice()`: filter rows based on values in specified columns
 * `group-by()`: group all data by a column
 * `arrange()`: sort data by values in specified columns 
 * `select()` & `rename()`: view and work with data from only specified columns
 * `distinct()`: view and work with only unique values from specified columns
 * `mutate()` & `transmute()`: add new data to a data frame
 * `summarise()`: calculate the specified summary statistics
 * `sample_n()` & `sample_frac()`: return a random sample of rows
 
(List modified from the CRAN `dplyr` 
<a href="https://cran.r-project.org/web/packages/dplyr/dplyr.pdf" target="_blank"> package description</a>. )

The syntax for all `dplyr` functions is similar: 

 * the first argument is the target `data_frame`, 
 * the subsequent arguments dictate what to do with that `data_frame` and 
 * the output is a new data frame. 

### Group by a Variable (or Two)
Our goal for this tutorial is to view drivers of annual phenology patterns.
Specifically, we want to explore daily average temperature throughout the year.
This means we need to calculate average temperature, for each day, across three
years. To do this we can use the `group_by()` function as we did earlier.
However this time, we can group by two variables: year and Julian Day (jd) as follows:

`group_by(year, jd)`

Let's begin by counting or `tally`ing the total measurements per Julian day (or
year day) using the `group_by()` function and pipes. 


    harMet15.09.11 %>%         # use the harMet15.09.11 data_frame
      group_by(year, jd) %>%   # group data by Year & Julian day
      tally()                  # tally (count) observations per jd / year

    ## # A tibble: 1,096 x 3
    ## # Groups:   year [?]
    ##     year    jd     n
    ##    <dbl> <int> <int>
    ##  1  2009     1    96
    ##  2  2009     2    96
    ##  3  2009     3    96
    ##  4  2009     4    96
    ##  5  2009     5    96
    ##  6  2009     6    96
    ##  7  2009     7    96
    ##  8  2009     8    96
    ##  9  2009     9    96
    ## 10  2009    10    96
    ## # ... with 1,086 more rows

The output shows we have 96 values for each day. Is that what we expect? 


    24*4  # 24 hours/day * 4 15-min data points/hour

    ## [1] 96

<div id="ds-dataTip">
<i class="fa fa-star"></i>**Data Tip:**  If Julian days weren't already in our 
data, we could use the `yday()` function
<a href="http://www.inside-r.org/packages/cran/lubridate/docs/yday"/>
from the `lubridate` package to create a new column containing Julian day 
values. [More information in this NEON Data Skills tutorial ]({{ site.baseurl }}/R/julian-day-conversion/). 
{: .notice }

### Summarize by Group
We can use `summarize()` function to calculate a summary output value for each
"group" - in this case Julian day per year. Let's calculate the mean air
temperature for each Julian day per year. Note that we are still using
`na.rm=TRUE` to tell `R` to skip `NA` values.


    harMet15.09.11 %>%         # use the harMet15.09.11 data_frame
      group_by(year, jd) %>%   # group data by Year & Julian day
      summarize(mean_airt = mean(airt, na.rm = TRUE))  # mean airtemp per jd / year

    ## # A tibble: 1,096 x 3
    ## # Groups:   year [?]
    ##     year    jd  mean_airt
    ##    <dbl> <int>      <dbl>
    ##  1  2009     1 -15.128125
    ##  2  2009     2  -9.143750
    ##  3  2009     3  -5.539583
    ##  4  2009     4  -6.352083
    ##  5  2009     5  -2.414583
    ##  6  2009     6  -4.915625
    ##  7  2009     7  -2.590625
    ##  8  2009     8  -3.227083
    ##  9  2009     9  -9.915625
    ## 10  2009    10 -11.131250
    ## # ... with 1,086 more rows

<div id="ds-challenge" markdown="1">
## Challenge: Summarization & Calculations with dplyr
We can use `sum` to calculate the total rather than mean value for each Julian
Day. Using this information, do the following:

1. Calculate total `prec` for each Julian Day over the 3 years - name your
data_frame `total.prec`. 
2. Create a plot of Daily Total Precipitation for 2009-2011. 
3. Add a title and x and y axis labels.
4. If you use `qplot` to create your plot, use
`colour=as.factor(total.prec$year)` to color the data points by year.

</div>

![ ]({{ site.baseurl }}/images/rfigs/R/dc-tabular-time-series/04-Dplyr-For-Time-Series-In-R/challenge-answer-1.png)

### Mutate - Add data_frame Columns to dplyr Output
We can use the `mutate()` function of `dplyr` to add additional columns of
information to a data_frame. For instance, we added the year column
independently at the very beginning of the tutorial. However, we can add the
year using a `dplyr` pipe that also summarizes our data. To do this, we would
use the syntax:

`mutate(year2 = year(datetime))`

year2 is the name of the column that will be added to the output `dplyr`
data_frame.


    harMet15.09.11 %>%
      mutate(year2 = year(datetime)) %>%
      group_by(year2, jd) %>%
      summarize(mean_airt = mean(airt, na.rm = TRUE))

    ## # A tibble: 1,096 x 3
    ## # Groups:   year2 [?]
    ##    year2    jd  mean_airt
    ##    <dbl> <int>      <dbl>
    ##  1  2009     1 -15.128125
    ##  2  2009     2  -9.143750
    ##  3  2009     3  -5.539583
    ##  4  2009     4  -6.352083
    ##  5  2009     5  -2.414583
    ##  6  2009     6  -4.915625
    ##  7  2009     7  -2.590625
    ##  8  2009     8  -3.227083
    ##  9  2009     9  -9.915625
    ## 10  2009    10 -11.131250
    ## # ... with 1,086 more rows

<div id="ds-dataTip">
<i class="fa fa-star"></i>**Data Tip:** The `mutate` function is similar to
`transform()` in base `R`. However,`mutate()` allows us to create and 
immediately use the variable (`year2`).
{: .notice }

## Save dplyr Output as data_frame
We can save output from a `dplyr` pipe as a new `R` object to use for quick
plotting. 


    harTemp.daily.09.11<-harMet15.09.11 %>%
                        mutate(year2 = year(datetime)) %>%
                        group_by(year2, jd) %>%
                        summarize(mean_airt = mean(airt, na.rm = TRUE))
    
    head(harTemp.daily.09.11)

    ## # A tibble: 6 x 3
    ## # Groups:   year2 [1]
    ##   year2    jd  mean_airt
    ##   <dbl> <int>      <dbl>
    ## 1  2009     1 -15.128125
    ## 2  2009     2  -9.143750
    ## 3  2009     3  -5.539583
    ## 4  2009     4  -6.352083
    ## 5  2009     5  -2.414583
    ## 6  2009     6  -4.915625

### Add Date-Time To dplyr Output
In the challenge above, we created a plot of daily precipitation data using
`qplot`. However, the x-axis ranged from 0-366 (Julian Days for the year). It
would have been easier to create a meaningful plot across all three years if we
had a continuous date variable in our `data_frame` representing the year and
date for each summary value. 

We can add the the `datetime` column value to our `data_frame` by adding an
additional argument to the `summarize()` function. In this case, we will add the
`first` datetime value that `R` encounters when summarizing data by group as
follows:

`datetime = first(datetime)`

Our new summarize statement in our pipe will look like this:

`summarize(mean_airt = mean(airt, na.rm = TRUE), datetime = first(datetime))`

Let's try it!


    # add in a datatime column
    harTemp.daily.09.11 <- harMet15.09.11 %>%
      mutate(year3 = year(datetime)) %>%
      group_by(year3, jd) %>%
      summarize(mean_airt = mean(airt, na.rm = TRUE), datetime = first(datetime))
    
    # view str and head of data
    str(harTemp.daily.09.11)

    ## Classes 'grouped_df', 'tbl_df', 'tbl' and 'data.frame':	1096 obs. of  4 variables:
    ##  $ year3    : num  2009 2009 2009 2009 2009 ...
    ##  $ jd       : int  1 2 3 4 5 6 7 8 9 10 ...
    ##  $ mean_airt: num  -15.13 -9.14 -5.54 -6.35 -2.41 ...
    ##  $ datetime : POSIXct, format: "2009-01-01 00:15:00" "2009-01-02 00:15:00" ...
    ##  - attr(*, "vars")= chr "year3"
    ##  - attr(*, "drop")= logi TRUE

    head(harTemp.daily.09.11)

    ## # A tibble: 6 x 4
    ## # Groups:   year3 [1]
    ##   year3    jd  mean_airt            datetime
    ##   <dbl> <int>      <dbl>              <dttm>
    ## 1  2009     1 -15.128125 2009-01-01 00:15:00
    ## 2  2009     2  -9.143750 2009-01-02 00:15:00
    ## 3  2009     3  -5.539583 2009-01-03 00:15:00
    ## 4  2009     4  -6.352083 2009-01-04 00:15:00
    ## 5  2009     5  -2.414583 2009-01-05 00:15:00
    ## 6  2009     6  -4.915625 2009-01-06 00:15:00

<div id="ds-challenge" markdown="1">
## Challenge: Combined dplyr Skills

1. Plot daily total precipitation from 2009-2011 as we did in the previous
challenge. However this time, use the new syntax that you learned (mutate and
summarize to add a datetime column to your output data_frame).
2. Create a data_frame of the average *monthly* air temperature for 2009-2011.
Name the new data frame `harTemp.monthly.09.11`. Plot your output.

</div>

![ ]({{ site.baseurl }}/images/rfigs/R/dc-tabular-time-series/04-Dplyr-For-Time-Series-In-R/challenge-code-dplyr-1.png)![ ]({{ site.baseurl }}/images/rfigs/R/dc-tabular-time-series/04-Dplyr-For-Time-Series-In-R/challenge-code-dplyr-2.png)

