---
syncID: 247b25406fcf482f9f70e408664efc9f
title: "Time Series 04: Subset and Manipulate Time Series Data with dplyr"
description: "In this tutorial, we will use the group_by, summarize and mutate functions in the `dplyr` package to efficiently manipulate atmospheric data collected at the NEON Harvard Forest Field Site. We will use pipes to efficiently perform multiple tasks within a single chunk of code."
dateCreated: 2015-10-22
authors: Megan A. Jones, Marisa Guarinello, Courtney Soderberg, Leah A. Wasser
contributors: Michael Patterson, Donal O'Leary, Collin J. Storlie
estimatedTime: 30 minutes
packagesLibraries: ggplot2, dplyr, lubridate
topics: time-series, phenology
languagesTool: R
dataProduct:
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/intro-to-time-series/04-Dplyr-For-Time-Series-In-R/04-Dplyr-For-Time-Series-In-R.R
tutorialSeries: tabular-time-series
urlTitle: dc-time-series-subset-dplyr-r
---

In this tutorial, we will use the `group_by`, `summarize` and `mutate` functions
in the `dplyr` package to efficiently manipulate atmospheric data collected at
the NEON Harvard Forest Field Site. We will use pipes to efficiently perform
multiple tasks within a single chunk of code.

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

 * Explain several ways to manipulate data using functions in the `dplyr`
 package in R.
 * Use `group-by()`, `summarize()`, and `mutate()` functions. 
 * Write and understand R code with pipes for cleaner, efficient coding.
 * Use the `year()` function from the `lubridate` package to extract year from a
 date-time class variable. 

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, RStudio loaded on
your computer to complete this tutorial.

### Install R Packages
* **lubridate:** `install.packages("lubridate")`
* **dplyr:** `install.packages("dplyr")`
* **ggplot2:** `install.packages("ggplot2")`

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Download Data 
<h3> <a href="https://ndownloader.figshare.com/files/3701572" > NEON Teaching Data Subset: Meteorological Data for Harvard Forest</a></h3>

The data used in this lesson were collected at the 
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map/HARV" target="_blank"> Harvard Forest field site</a>. 
These data are proxy data for what will be available for 30 years on the
 <a href="http://data.neonscience.org/" target="_blank">NEON data portal</a>
for the Harvard Forest and other field sites located across the United States.

<a href="https://ndownloader.figshare.com/files/3701572" class="link--button link--arrow"> Download Dataset</a>





****
**Set Working Directory:** This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

**R Script & Challenge Code:** NEON data lessons often contain challenges that reinforce 
learned skills. If available, the code for challenge solutions is found in the
downloadable R script of the entire lesson, available in the footer of each lesson page.


****

### Additional Resources

* NEON Data Skills tutorial on 
<a href="https://www.neonscience.org/grepl-filter-piping-dplyr-r" target="_blank"> spatial data and piping with dplyr</a>  
* Data Carpentry lesson's on 
<a href="http://www.datacarpentry.org/R-ecology-lesson/03-dplyr.html" target="_blank">Aggregating and Analyzing Data with dplyr</a> 
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
<a href="https://www.neonscience.org/dc-subset-data-no-data-values-r" target="_blank">*Subsetting Time Series Data* tutorial</a>.

If this object isn't already created, please load the `.csv` version: 
`Met_HARV_15min_2009_2011.csv`. Be
sure to convert the date-time column to a POSIXct class after the `.csv` is
loaded. 


    # it's good coding practice to load packages at the top of a script
    
    library(lubridate) # work with dates
    library(dplyr)     # data manipulation (filter, summarize, mutate)
    library(ggplot2)   # graphics
    library(gridExtra) # tile several plots next to each other
    library(scales)
    
    # set working directory to ensure R can find the file we wish to import
    wd <- "~/Documents/"
    
    # 15-min Harvard Forest met data, 2009-2011
    harMet15.09.11<- read.csv(
      file=paste0(wd,"Met_HARV_15min_2009_2011.csv"),
      stringsAsFactors = FALSE)

    ## Warning in file(file, "rt"): cannot open file '/Users/olearyd/Documents/
    ## Met_HARV_15min_2009_2011.csv': No such file or directory

    ## Error in file(file, "rt"): cannot open the connection

    # convert datetime to POSIXct
    harMet15.09.11$datetime<-as.POSIXct(harMet15.09.11$datetime,
                        format = "%Y-%m-%d %H:%M",
                        tz = "America/New_York")

    ## Error in as.POSIXct(harMet15.09.11$datetime, format = "%Y-%m-%d %H:%M", : object 'harMet15.09.11' not found

## Explore The Data
Remember that we are interested in the drivers of phenology including - 
air temperature, precipitation, and PAR (photosynthetic active radiation - or
the amount of visible light). Using the 15-minute averaged data, we could easily
plot each of these variables.  


    ## Error in ggplot(harMet15.09.11, aes(x = datetime, y = airt)): object 'harMet15.09.11' not found

    ## Error in ggplot(harMet15.09.11, aes(x = datetime, y = prec)): object 'harMet15.09.11' not found

    ## Error in ggplot(harMet15.09.11, aes(x = datetime, y = parr)): object 'harMet15.09.11' not found

    ## Warning in grob$wrapvp <- vp: Coercing LHS to a list

    ## Warning in grob$wrapvp <- vp: Coercing LHS to a list

    ## Warning in grob$wrapvp <- vp: Coercing LHS to a list

    ## Error in gList(structure(list("mouse", wrapvp = structure(list(x = structure(0.5, unit = 0L, class = c("simpleUnit", : only 'grobs' allowed in "gList"

However, summarizing the data at a coarser scale (e.g., daily, weekly, by
season, or by year) may be easier to visually interpret during initial stages of
data exploration. 

### Extract Year from a Date-Time Column
To summarize by year efficiently, it is helpful to have a year column that we
can use to `group` by. We can use the `lubridate` function `year()` to extract
the year only from a `date-time` class R column. 


    # create a year column
    harMet15.09.11$year <- year(harMet15.09.11$datetime)

    ## Error in year(harMet15.09.11$datetime): object 'harMet15.09.11' not found

Using `names()` we see that we now have a `year` column in our `data_frame`.


    # check to make sure it worked
    names(harMet15.09.11)

    ## Error in eval(expr, envir, enclos): object 'harMet15.09.11' not found

    str(harMet15.09.11$year)

    ## Error in str(harMet15.09.11$year): object 'harMet15.09.11' not found

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

    ## Error in group_by(harMet15.09.11, year): object 'harMet15.09.11' not found

    # view class of the grouped object
    class(HARV.grp.year)

    ## Error in eval(expr, envir, enclos): object 'HARV.grp.year' not found

The `group_by` function creates a "grouped" object. We can then use this
grouped object to quickly calculate summary statistics by group - in this case,
year. For example, we can count how many measurements were made each year using
the `tally()` function. We can then use the `summarize` function to calculate
the mean air temperature value each year. Note that "summarize" is a common 
function name across many different packages. If you happen to have two packages 
loaded at the same time that both have a "summarize" function, you may not get 
the results that you expect. Therefore, we will "disambiguate" our function by 
specifying which package it comes from using the double colon notation 
`dplyr::summarize()`.


    # how many measurements were made each year?
    tally(HARV.grp.year)

    ## Error in group_vars(x): object 'HARV.grp.year' not found

    # what is the mean airt value per year?
    dplyr::summarize(HARV.grp.year, 
              mean(airt)   # calculate the annual mean of airt
              ) 

    ## Error in dplyr::summarize(HARV.grp.year, mean(airt)): object 'HARV.grp.year' not found

Why did this return a `NA` value for years 2009 and 2010? We know there are some
values for both years. Let's check our data for `NoData` values.


    # are there NoData values?
    sum(is.na(HARV.grp.year$airt))

    ## Error in eval(expr, envir, enclos): object 'HARV.grp.year' not found

    # where are the no data values
    # just view the first 6 columns of data
    HARV.grp.year[is.na(HARV.grp.year$airt),1:6]

    ## Error in eval(expr, envir, enclos): object 'HARV.grp.year' not found

It appears as if there are two `NoData` values (in 2009 and 2010) that are
causing R to return a `NA` for the mean for those years. As we learned
previously, we can use `na.rm` to tell R to ignore those values and calculate
the final mean value.


    # calculate mean but remove NA values
    dplyr::summarize(HARV.grp.year, 
              mean(airt, na.rm = TRUE)
              )

    ## Error in dplyr::summarize(HARV.grp.year, mean(airt, na.rm = TRUE)): object 'HARV.grp.year' not found

Great! We've now used the `group_by` function to create groups for each year 
of our data. We then calculated a summary mean value per year using `summarize`.

### dplyr Pipes 
The above steps utilized several steps of R code and created 1 R object - 
`HARV.grp.year`. We can combine these steps using `pipes` in the `dplyr` 
package.

We can use `pipes` to string functions or processing steps together. The output 
of each step is fed directly into the next step using the syntax: `%>%`. This 
means we don't need to save the output of each intermediate step as a new R
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
example, we can tell R to `tally` or count the number of measurements per
year.

`harMet15.09.11 %>% group_by(year) %>% tally()`

Let's try it!


    # how many measurements were made a year?
    harMet15.09.11 %>% 
      group_by(year) %>%  # group by year
      tally() # count measurements per year

    ## Error in eval(lhs, parent, parent): object 'harMet15.09.11' not found

Piping allows us to efficiently perform operations on our `data_frame` in that:

1. It allows us to condense our code, without naming intermediate steps.
2. The dplyr package is optimized to ensure fast processing!

We can use pipes to summarize data by year too:


    # what was the annual air temperature average 
    year.sum <- harMet15.09.11 %>% 
      group_by(year) %>%  # group by year
      dplyr::summarize(mean(airt, na.rm=TRUE))

    ## Error in eval(lhs, parent, parent): object 'harMet15.09.11' not found

    # what is the class of the output?
    year.sum

    ## Error in eval(expr, envir, enclos): object 'year.sum' not found

    # view structure of output
    str(year.sum)

    ## Error in str(year.sum): object 'year.sum' not found


<div id="ds-challenge" markdown="1">
### Challenge: Using Pipes
Use piping to create a `data_frame` called `jday.avg` that contains the average 
`airt` per Julian day (`harMet15.09.11$jd`). Plot the output using `qplot`.

</div>


    ## Error in eval(lhs, parent, parent): object 'harMet15.09.11' not found

    ## Error in names(jday.avg) <- c("jday", "meanAirTemp"): object 'jday.avg' not found

    ## Error in FUN(X[[i]], ...): object 'jday.avg' not found

![Average Temperature by Julian Date at Harvard Forest Between 2009 and 2011](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/intro-to-time-series/04-Dplyr-For-Time-Series-In-R/rfigs/pipe-demo-1.png)

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:**  Older `dplyr` versions used the `%.%`
syntax to designate a pipe. Pipes are sometimes referred to as chains. 
</div>

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

    ## Error in eval(lhs, parent, parent): object 'harMet15.09.11' not found

The output shows we have 96 values for each day. Is that what we expect? 


    24*4  # 24 hours/day * 4 15-min data points/hour

    ## [1] 96

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:**  If Julian days weren't already in our 
data, we could use the `yday()` function from the `lubridate` package 
to create a new column containing Julian day 
values. More information in this
<a href="https://www.neonscience.org/julian-day-conversion-r" target="_blank"> NEON Data Skills tutorial</a>. 
</div>

### Summarize by Group
We can use `summarize()` function to calculate a summary output value for each
"group" - in this case Julian day per year. Let's calculate the mean air
temperature for each Julian day per year. Note that we are still using
`na.rm=TRUE` to tell R to skip `NA` values.


    harMet15.09.11 %>%         # use the harMet15.09.11 data_frame
      group_by(year, jd) %>%   # group data by Year & Julian day
      dplyr::summarize(mean_airt = mean(airt, na.rm = TRUE))  # mean airtemp per jd / year

    ## Error in eval(lhs, parent, parent): object 'harMet15.09.11' not found

<div id="ds-challenge" markdown="1">
### Challenge: Summarization & Calculations with dplyr
We can use `sum` to calculate the total rather than mean value for each Julian
Day. Using this information, do the following:

1. Calculate total `prec` for each Julian Day over the 3 years - name your
data_frame `total.prec`. 
2. Create a plot of Daily Total Precipitation for 2009-2011. 
3. Add a title and x and y axis labels.
4. If you use `qplot` to create your plot, use
`colour=as.factor(total.prec$year)` to color the data points by year.

</div>


    ## Error in eval(lhs, parent, parent): object 'harMet15.09.11' not found

    ## Error in FUN(X[[i]], ...): object 'total.prec' not found

![Average Daily Precipitation (mm) at Harvard Forest by Julian Date for the time period 2009 - 2011](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/intro-to-time-series/04-Dplyr-For-Time-Series-In-R/rfigs/challenge-answer-1.png)

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
      dplyr::summarize(mean_airt = mean(airt, na.rm = TRUE))

    ## Error in eval(lhs, parent, parent): object 'harMet15.09.11' not found

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** The `mutate` function is similar to
`transform()` in base R. However,`mutate()` allows us to create and 
immediately use the variable (`year2`).
</div>

## Save dplyr Output as data_frame
We can save output from a `dplyr` pipe as a new R object to use for quick
plotting. 


    harTemp.daily.09.11<-harMet15.09.11 %>%
                        mutate(year2 = year(datetime)) %>%
                        group_by(year2, jd) %>%
                        dplyr::summarize(mean_airt = mean(airt, na.rm = TRUE))

    ## Error in eval(lhs, parent, parent): object 'harMet15.09.11' not found

    head(harTemp.daily.09.11)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'head': object 'harTemp.daily.09.11' not found

### Add Date-Time To dplyr Output
In the challenge above, we created a plot of daily precipitation data using
`qplot`. However, the x-axis ranged from 0-366 (Julian Days for the year). It
would have been easier to create a meaningful plot across all three years if we
had a continuous date variable in our `data_frame` representing the year and
date for each summary value. 

We can add the the `datetime` column value to our `data_frame` by adding an
additional argument to the `summarize()` function. In this case, we will add the
`first` datetime value that R encounters when summarizing data by group as
follows:

`datetime = first(datetime)`

Our new summarize statement in our pipe will look like this:

`summarize(mean_airt = mean(airt, na.rm = TRUE), datetime = first(datetime))`

Let's try it!


    # add in a datatime column
    harTemp.daily.09.11 <- harMet15.09.11 %>%
      mutate(year3 = year(datetime)) %>%
      group_by(year3, jd) %>%
      dplyr::summarize(mean_airt = mean(airt, na.rm = TRUE), datetime = first(datetime))

    ## Error in eval(lhs, parent, parent): object 'harMet15.09.11' not found

    # view str and head of data
    str(harTemp.daily.09.11)

    ## Error in str(harTemp.daily.09.11): object 'harTemp.daily.09.11' not found

    head(harTemp.daily.09.11)

    ## Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'head': object 'harTemp.daily.09.11' not found

<div id="ds-challenge" markdown="1">
### Challenge: Combined dplyr Skills

1. Plot daily total precipitation from 2009-2011 as we did in the previous
challenge. However this time, use the new syntax that you learned (mutate and
summarize to add a datetime column to your output data_frame).
2. Create a data_frame of the average *monthly* air temperature for 2009-2011.
Name the new data frame `harTemp.monthly.09.11`. Plot your output.

</div>


    ## Error in eval(lhs, parent, parent): object 'harMet15.09.11' not found

    ## Error in FUN(X[[i]], ...): object 'total.prec2' not found

    ## Error in eval(lhs, parent, parent): object 'harMet15.09.11' not found

    ## Error in FUN(X[[i]], ...): object 'harTemp.monthly.09.11' not found

![Daily Precipitation at Harvard Forest Between 2009 and 2011](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/intro-to-time-series/04-Dplyr-For-Time-Series-In-R/rfigs/challenge-code-dplyr-1.png)

    ## Error in str(harTemp.monthly.09.11): object 'harTemp.monthly.09.11' not found

