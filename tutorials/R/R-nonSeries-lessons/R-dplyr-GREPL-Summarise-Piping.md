---
syncID: 63635a0daf0c417090e5c38c3103a09a
title: "Filter, Piping and GREPL Using R DPLYR - An Intro"
description: "Learn how to use the filter, group_by, and summarize functions with piping in R's dplyr package. And combine these with grepl to select portions of character strings."
dateCreated: 2015-05-27
authors: Natalie Robinson, Kate Thibault
contributors: 
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: dplyr
topics: data-analysis
languagesTool: R
dataProduct: 
code1: R/R-nonSeries-lessons/R-dplyr-GREPL-Summarise-Piping.R
tutorialSeries: 
urlTitle: grepl-filter-piping-dplyr-r

---

<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this tutorial, you will be able to:

* Filter data, alone and combined with simple pattern matching grepl().
* Use the group_by function in dplyr.
* Use the summarise function in dplyr.
* "Pipe"" functions using dplyr syntax.


## Things You’ll Need To Complete This Tutorial
You will need the most current version of `R` and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages

* **dplyr**: `install.packages("dplyr")` used for data manipulation

### Data to Download:
<a href="{{ site.baseurl }}/data/NEON.D01.HARV.DP1.10072.001.mam_capturedata.csv" target="_blank" class="link--button link--arrow">Download the Sample National Ecological Observatory Network (NEON) Mammal Data HERE.</a>

<a href="{{ site.baseurl }}/science-design/collection-methods/terrestrial-organismal-sampling" target="_blank">Read more about NEON terrestrial measurements, here. </a>

Please note that NEON Small Mammal data are now delivered in a slightly different
format. This data format here is provide to accompany this tutorial on dplyr only. 
</div>


## Intro to dplyr
When working with data frames in R, it is often useful to manipulate and 
summarize data. The `dplyr` package in `R` offers one of the most comprehensive 
group of functions to perform common manipulation tasks. In addition, the 
`dplyr` functions are often of a simpler syntax than most other data manipulation 
functions in R.

## Elements of dplyr
There are several elements of `dplyr` that are unique to the library, and that
do very cool things!

### Functions for manipulating data

The text below was exerpted from the
<a href="http://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html" target="_blank"> R CRAN dpylr vignettes.</a>

Dplyr aims to provide a function for each basic verb of data manipulating, like:

 * `filter()` (and `slice()`)
      * filter rows based on values in specified columns
 * `arrange()`
      * sort data by values in specified columns 
 * `select()` (and `rename()`)
      * view and work with data from only specified columns
 * `distinct()`
      * view and work with only unique values from specified columns
 * `mutate()` (and `transmute()`)
      * add new data to the data frame
 * `summarise()`
      * calculate specified summary statistics on data
 * `sample_n()` and `sample_frac()`
      * return a random sample of rows
 
### Format of function calls
The single table verb functions share these features:

  * The first argument is a `data.frame` (or a dplyr special class tbl_df).
      * `dplyr` can work with data.frames as is, but if you're dealing with large
        data it's worthwhile to convert them to a tbl_df, to avoid printing 
        a lot of data to the screen.
  * The subsequent arguments describe how to manipulate the data (e.g., based on
    which columns, using which summary statistics), and you can refer to columns
    directly (without using $).
  * The result is a new `data.frame`.
  * Function calls do not generate 'side-effects'; you always have to assign the
    results to an object
  
### Grouped operations
Certain functions (e.g., group_by, summarise, and other 'aggregate functions')
allow you to get information for groups of data, in one fell swoop. This is like 
performing database functions with knowing SQL or any other db specific code. 
Powerful stuff!

### Piping
We often need to get a subset of data using one function, and then use 
another function to do something with that subset (and we may do this multiple 
times). This leads to nesting functions, which can get messy and hard to keep 
track of. Enter 'piping', dplyr's way of feeding the output of one function into 
another, and so on, without the hassleof parentheses and brackets. Piping looks 
like:

	data frame %>%
		function to apply first %>%
			function to apply second %>%
				function to apply third

For example, if we want to find the mean body weight of male mice, we'd do this:

	myMammalData %>%
		filter(sex=='m') %>%
			summarise (mean_weight = mean(weight))

This is read as "from data frame `myMammalData`, select only males and return 
the mean weight as a new list `mean_weight`".

## Use dplyr

Now let's use some of the functions with NEON small mammal capture data from 
Harvard Forest (within Domain 01). This site is located in the heart of the 
Lyme disease epidemic.


    # install dplyr library -- only if it isn't already installed
    #install.packages('dplyr')
    
    # load library
    library(dplyr)
    
    # set working directory to the location of the NEON mammal data downloaded
    # via the link above.
    #setwd('insert path to data files here')
    
    # read in the NEON small mammal capture data
    myData <- read.csv('NEON.D01.HARV.DP1.10072.001.mam_capturedata.csv', 
                       header = T, 
                       stringsAsFactors = FALSE, strip.white = TRUE, 
                       na.strings = '')
    
    # if you'd like, check out the data
    #str(myData)

For the rest of this tutorial, we are only going to be working with:

* `scientificName` a string of "Genus species"
* `sex` a string with "F", "M", or "U" 

## filter()
This function: 

* extracts only a subset of rows from a data frame according to specified
conditions
* is similar to the base function `subset()`, but with simpler syntax
* inputs: data object, any number of conditional statements on the named columns of the data object
* output: a data object of the same class as the input object (e.g., 
  data.frame in, data.frame out) with only those rows that meet the conditions

For example, let's create a new dataframe that contains only female *Peromyscus 
mainculatus*, one of the key small mammal players in the life cycle of Lyme 
disease-causing bacterium.


    # filter on `scientificName` is Peromyscus maniculatus and `sex` is female. 
    # two equals signs (==) signifies "is"
    data_PeroManicFemales <- filter(myData, 
                       scientificName == 'Peromyscus maniculatus', 
                       sex == 'F')
    
    # Note how we were able to put multiple conditions into the filter statement,
    # pretty cool!

So we have a dataframe with our female *P. mainculatus* but how many are there? 


    # how many female P. maniculatus are in the dataset
    # would could simply count the number of rows in the new dataset
    nrow(data_PeroManicFemales)

    ## [1] 85

    # or we could write is as a sentence
    print(paste('In 2014, NEON technicians captured',
                       nrow(data_PeroManicFemales),
                       'female Peromyscus maniculatus at Harvard Forest.',
                       sep = ' '))

    ## [1] "In 2014, NEON technicians captured 85 female Peromyscus maniculatus at Harvard Forest."


## grepl()
This is a function in the base package (e.g., it isn't part of `dplyr`) that is 
part of the suite of Regular Expressions functions. `grepl` uses regular 
expressions to match patterns in character strings. Regular expressions offer 
very powerful and useful tricks for data manipulation. They can be complicated 
and therefore are a challenge to learn, but well worth it! 

Here, we present a very simple example.

* inputs: pattern to match, character vector to search for a match
* output: a logical vector indicating whether the pattern was found within 
each element of the input character vector

Let's use `grepl` to learn more about our possible disease vectors. In reality, 
all species of *Peromyscus* are viable players in Lyme disease transmission, so 
we really should be looking at all species of *Peromyscus*. Since we don't have 
genera split out as a separate field, we have to search within the 
`scientificName` string for the genus -- this is a simple example of pattern 
matching.

We can use the `dplyr` function `filter()` in combination with the base function
`grepl()` to accomplish this.


    # combine filter & grepl to get all Peromyscus (a part of the 
    # scientificName string)
    data_PeroFemales <- filter(myData,
                       grepl('Peromyscus', scientificName),
                       sex == 'F')
    
    # how many female Peromyscus are in the dataset
    print(paste('In 2014, NEON technicians captured',
                       nrow(data_PeroFemales),
                       'female Peromyscus spp. at Harvard Forest.',
                       sep = ' '))

    ## [1] "In 2014, NEON technicians captured 612 female Peromyscus spp. at Harvard Forest."

## group_by() + summarise()
An alternative to using the filter function to subset the data (and make a new 
data object in the process), is to calculate summary statistics based on some 
grouping factor. We'll use `group_by()`, which does basically the same thing as 
SQL or other tools for interacting with relational databases. For those 
unfamiliar with SQL, no worries - `dplyr` provides lots of additional 
functionality for working with databases (local and remote) that does not 
require knowledge of SQL. How handy! 

The `group_by()` function in `dplyr` allows you to perform functions on a subset 
of a dataset without having to create multiple new objects or construct for 
loops. The combination of `group_by()` and `summarise()` are great for 
generating simple summaries (counts, sums) of grouped data. 

NOTE: Be continentious about using `summarise` with other summary functions! You
need to think about weighting for means and variances, and `summarize` doesn't 
work precisely for medians if there is any missing data (e.g., there was no value
recorded, maybe for a good reason!).

Continuing with our small mammal data, since the diversity of the entire small 
mammal community has been shown to impact disease dynamics among the key 
reservoir species, we really want to know more about the demographics of the 
whole community. We can quickly generate counts by species and sex in 2 lines of
code, using `group_by` and `summarise`.


    # how many of each species & sex were there?
    # step 1: group by species & sex
    dataBySpSex <- group_by(myData, scientificName, sex)
    
    # step 2: summarize the number of individuals of each using the new df
    countsBySpSex <- summarise(dataBySpSex, n_individuals = n())
    
    # view the data (just top 10 rows)
    head(countsBySpSex, 10)

    ## # A tibble: 10 x 3
    ## # Groups:   scientificName [5]
    ##             scientificName   sex n_individuals
    ##                      <chr> <chr>         <int>
    ##  1      Blarina brevicauda     f             2
    ##  2      Blarina brevicauda     F            49
    ##  3      Blarina brevicauda     M             8
    ##  4      Blarina brevicauda     U             2
    ##  5      Blarina brevicauda  <NA>            38
    ##  6        Glaucomys volans     M             1
    ##  7            Mammalia sp.  <NA>             2
    ##  8 Microtus pennsylvanicus     F             2
    ##  9          Myodes gapperi     F           102
    ## 10          Myodes gapperi     m            12

    # hmm, it looks like on data entry some females were recorded as `F` and some 
    # as `f`.  R is interpreting these as different "sexes". We would need to 
    # remember this if we want to filter all females or go back and clean the 
    # the original data.

Note: the output of step 1 (`dataBySpSex`) does not look any different than the 
original dataframe (`myData`), but the application of subsequent functions (e.g.,
summarise) to this new dataframe will produce distinctly different results than 
if you tried the same operations on the original.  Try it if you want to see the
difference!

## Pipe functions together

We created multiple new data objects during our explorations of `dplyr` 
functions, above. While this works, we can produce the same results more 
efficiently by chaining functions together and creating only one new data object
that encapsulates all of the previously sought information: `filter` on only 
females, `grepl` to get only Peromyscus spp., `group_by` individual species, and
`summarise` the numbers of individuals.


    # combine several functions to get a summary of the numbers of individuals of 
    # female Peromyscus species in our dataset.
    # remember %>% are "pipes" that allow us to pass information from one function 
    # to the next. 
    
    dataBySpFem <- myData %>%
                     filter(grepl('Peromyscus', scientificName), sex == "F") %>%
                       group_by(scientificName) %>%
                          summarise(n_individuals = n()) 
    
    # view the data
    dataBySpFem

    ## # A tibble: 3 x 2
    ##           scientificName n_individuals
    ##                    <chr>         <int>
    ## 1    Peromyscus leucopus           522
    ## 2 Peromyscus maniculatus            85
    ## 3         Peromyscus sp.             5

Cool!  

## Base R only

So that is nice, but we had to install a new package `dplyr`. You might ask, 
"Is it really worth it to learn new commands if I can do this is base R."  While
we think "yes", why don't you see for yourself.  Here is the base R code needed 
to accomplish the same task.


    # For reference, the same output but using R's base functions
    
    # First, subset the data to only female Peromyscus
    dataFemPero  <- myData[myData$sex=='F' & 
                       grepl('Peromyscus',myData$scientificName),]
    
    # Option 1 --------------------------------
    # Use aggregate and then rename columns
    dataBySpFem_agg <-aggregate(dataFemPero$sex ~ dataFemPero$scientificName, 
                       data = dataFemPero, FUN = length)
    names(dataBySpFem_agg) <- c('scientificName','n_individuals')
    
    # view output
    dataBySpFem_agg

    ##           scientificName n_individuals
    ## 1    Peromyscus leucopus           522
    ## 2 Peromyscus maniculatus            85
    ## 3         Peromyscus sp.             5

    # Option 2 --------------------------------------------------------
    # Do it by hand
    
    # Get the unique scientificNames in the subset
    sppInDF <- unique(dataFemPero$scientificName[!is.na(dataFemPero$scientificName)])
    
    # Use a loop to calculate the numbers of individuals of each species
    sciName <- vector(); numInd <- vector()
    for (i in sppInDF){
      sciName <- c(sciName,i)
      numInd <- c(numInd, length(which(dataFemPero$scientificName==i)))
    }
    
    #Create the desired output data frame
    dataBySpFem_byHand <- data.frame('scientificName'=sciName, 
                       'n_individuals'=numInd)
    
    # view output
    dataBySpFem_byHand

    ##           scientificName n_individuals
    ## 1    Peromyscus leucopus           522
    ## 2 Peromyscus maniculatus            85
    ## 3         Peromyscus sp.             5


