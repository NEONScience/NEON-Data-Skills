---
title: "Filter, Piping, and GREPL Using R DPLYR - An Intro"
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/basic-R-skills/R-dplyr-GREPL-Summarise-Piping/R-dplyr-GREPL-Summarise-Piping.R
contributors: Garrett M. Williams
dataProduct: DP1.10072.001
dateCreated: '2015-05-27'
description: Learn how to use the filter, group_by, and summarize functions with piping
  in R's dplyr package. And combine these with grepl to select portions of character
  strings.
estimatedTime: 1.0 - 1.5 Hours
languagesTool: R
packagesLibraries: dplyr, neonUtilities
syncID: 63635a0daf0c417090e5c38c3103a09a
authors: Natalie Robinson, Kate Thibault, Donal O'Leary
topics: data-analysis
tutorialSeries: null
urlTitle: grepl-filter-piping-dplyr-r
---

<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this tutorial, you will be able to:

* Filter data, alone and combined with simple pattern matching grepl().
* Use the group_by function in dplyr.
* Use the summarise function in dplyr.
* "Pipe" functions using dplyr syntax.


## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages

* **neonUtilities**: `install.packages("neonUtilities")` tools for working with 
 NEON data
* **dplyr**: `install.packages("dplyr")` used for data manipulation

</div>


## Intro to dplyr
When working with data frames in R, it is often useful to manipulate and
summarize data. The `dplyr` package in R offers one of the most comprehensive 
group of functions to perform common manipulation tasks. In addition, the 
`dplyr` functions are often of a simpler syntax than most other data 
manipulation functions in R.

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

  * The first argument is a `data.frame` (or a dplyr special class tbl_df, known 
    as a 'tibble').
      * `dplyr` can work with data.frames as is, but if you're dealing with large
        data it's worthwhile to convert them to a tibble, to avoid printing 
        a lot of data to the screen. You can do this with the function  
        `as_tibble()`.
      * Calling the class function on a tibble will return the vector
        `c("tbl_df", "tbl", "data.frame")`.
  * The subsequent arguments describe how to manipulate the data (e.g., based on
    which columns, using which summary statistics), and you can refer to columns
    directly (without using $).
  * The result is always a new tibble.
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
another, and so on, without the hassleof parentheses and brackets. 

Let's say we want to start with the data frame `my_data`, apply `function1()`, 
then `function2()`, and then `function3()`. This is what that looks like without 
piping:


    function3(function2(function1(my_data)))

This is messy, difficult to read, and the reverse of the order our functions 
actually occur. If any of these functions needed additional arguments, the 
readability would be even worse!

The piping operator `%>%` takes everything in front of it and "pipes" it into 
the first argument of the function after. So now our example looks like this:


    my_data %>%
      function1() %>%
      function2() %>%
      function3()
This runs identically to the original nested version!

For example, if we want to find the mean body weight of male mice, we'd do this:


    	myMammalData %>%                     # start with a data frame
    		filter(sex=='M') %>%               # first filter for rows where sex is male
    		summarise (mean_weight = mean(weight))  # find the mean of the weight 
                                                # column, store as mean_weight

This is read as "from data frame `myMammalData`, select only males and return 
the mean weight as a new list `mean_weight`".

## Download Small Mammal Data

Before we get started, we will need to download our data to investigate. To 
do so, we will use the `loadByProduct()` function from the `neonUtilities` 
package to download data straight from the NEON servers. To learn more about 
this function, please see the <a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore NEON data tutorial here.</a>

Let's look at the NEON small mammal capture data from Harvard Forest (within 
Domain 01) for all of 2014. This site is located in the heart of the Lyme 
disease epidemic.

<a href="https://www.neonscience.org/data-collection/terrestrial-organismal-sampling" target="_blank">Read more about NEON terrestrial measurements here.</a>


    # load packages
    library(dplyr)
    library(neonUtilities)
    
    # load the NEON small mammal capture data
    # NOTE: the check.size = TRUE argument means the function 
    # will require confirmation from you that you want to load 
    # the quantity of data requested
    loadData <- loadByProduct(dpID="DP1.10072.001", site = "HARV", 
                     startdate = "2014-01", enddate = "2014-12", 
                     check.size = TRUE) # Console requires your response!
    
    # if you'd like, check out the data
    str(loadData)


The `loadByProduct()` function calls the NEON server, downloads the monthly 
data files, and 'stacks' them together to form two tables of data called 
'mam_pertrapnight' and 'mam_perplotnight'. It also saves the readme file, 
explanations of variables, and validation metadata, and combines these all into 
a single 'list' that we called 'loadData'. The only part of this list that we 
really need for this tutorial is the 'mam_pertrapnight' table, so let's extract 
just that one and call it 'myData'.


    myData <- loadData$mam_pertrapnight
    
    class(myData) # Confirm that 'myData' is a data.frame

    ## [1] "data.frame"

## Use dplyr

For the rest of this tutorial, we are only going to be working with three 
variables within 'myData':

* `scientificName` a string of "Genus species"
* `sex` a string with "F", "M", or "U"
* `identificationQualifier` a string noting uncertainty in the species 
  identification

## filter()
This function: 

* extracts only a subset of rows from a data frame according to specified
conditions
* is similar to the base function `subset()`, but with simpler syntax
* inputs: data object, any number of conditional statements on the named columns 
  of the data object
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

    ## [1] 98

    # or we could write is as a sentence
    print(paste('In 2014, NEON technicians captured',
                       nrow(data_PeroManicFemales),
                       'female Peromyscus maniculatus at Harvard Forest.',
                       sep = ' '))

    ## [1] "In 2014, NEON technicians captured 98 female Peromyscus maniculatus at Harvard Forest."

That's awesome that we can quickly and easily count the number of female 
Peromyscus maniculatus that were captured at Harvard Forest in 2014. However, 
there is a slight problem. There are two Peromyscus species that are common 
in Harvard Forest: Peromyscus maniculatus (deer mouse) and Peromyscus leucopus 
(white-footed mouse). These species are difficult to distinguish in the field, 
leading to some uncertainty in the identification, which is noted in the 
'identificationQualifier' data field by the term "cf. species" or "aff. species".
(For more information on these terms and 'open nomenclature' please <a href="https://en.wikipedia.org/wiki/Open_nomenclature" target="_blank">see this great Wiki article here</a>).
When the field technician is certain of their identification (or if they forget 
to note their uncertainty), identificationQualifier will be `NA`. Let's run the 
same code as above, but this time specifying that we want only those observations 
that are unambiguous identifications.


    # filter on `scientificName` is Peromyscus maniculatus and `sex` is female. 
    # two equals signs (==) signifies "is"
    data_PeroManicFemalesCertain <- filter(myData, 
                       scientificName == 'Peromyscus maniculatus', 
                       sex == 'F',
                       identificationQualifier =="NA")
    
    # Count the number of un-ambiguous identifications
    nrow(data_PeroManicFemalesCertain)

    ## [1] 0

Woah! So every single observation of a Peromyscus maniculatus had some level 
of uncertainty that the individual may actually be Peromyscus leucopus. This 
is understandable given the difficulty of field identification for these species. 
Given this challenge, it will be best for us to consider these mice at the genus 
level. We can accomplish this by searching for only the genus name in the 
'scientificName' field using the `grepl()` function.

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
all species of *Peromyscus* are viable players in Lyme disease transmission, and 
they are difficult to distinguise in a field setting, so we really should be 
looking at all species of *Peromyscus*. Since we don't have genera split out as 
a separate field, we have to search within the `scientificName` string for the 
genus -- this is a simple example of pattern matching.

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

    ## [1] "In 2014, NEON technicians captured 558 female Peromyscus spp. at Harvard Forest."

## group_by() + summarise()
An alternative to using the filter function to subset the data (and make a new 
data object in the process), is to calculate summary statistics based on some 
grouping factor. We'll use `group_by()`, which does basically the same thing as 
SQL or other tools for interacting with relational databases. For those 
unfamiliar with SQL, no worries - `dplyr` provides lots of additional 
functionality for working with databases (local and remote) that does not 
require knowledge of SQL. How handy! 

The `group_by()` function in `dplyr` allows you to perform functions on a subset 
of a dataset without having to create multiple new objects or construct `for()` 
loops. The combination of `group_by()` and `summarise()` are great for 
generating simple summaries (counts, sums) of grouped data.

NOTE: Be continentious about using `summarise` with other summary functions! You
need to think about weighting for means and variances, and `summarize` doesn't 
work precisely for medians if there is any missing data (e.g., if there was no 
value recorded, maybe it was for a good reason!).

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

    ## `summarise()` regrouping output by 'scientificName' (override with `.groups` argument)

    # view the data (just top 10 rows)
    head(countsBySpSex, 10)

    ## # A tibble: 10 x 3
    ## # Groups:   scientificName [5]
    ##    scientificName          sex   n_individuals
    ##    <chr>                   <chr>         <int>
    ##  1 Blarina brevicauda      F                50
    ##  2 Blarina brevicauda      M                 8
    ##  3 Blarina brevicauda      U                22
    ##  4 Blarina brevicauda      <NA>             19
    ##  5 Glaucomys volans        M                 1
    ##  6 Mammalia sp.            U                 1
    ##  7 Mammalia sp.            <NA>              1
    ##  8 Microtus pennsylvanicus F                 2
    ##  9 Myodes gapperi          F               103
    ## 10 Myodes gapperi          M                99

Note: the output of step 1 (`dataBySpSex`) does not look any different than the 
original dataframe (`myData`), but the application of subsequent functions (e.g.,
summarise) to this new dataframe will produce distinctly different results than 
if you tried the same operations on the original. Try it if you want to see the
difference! This is because the `group_by()` function converted `dataBySpSex` 
into a "grouped_df" rather than just a "data.frame". In order to confirm this, 
try using the `class()` function on both `myData` and `dataBySpSex`. You can 
also read the help documentation for this function by running the code: 
`?group_by()`


    # View class of 'myData' object
    class(myData)

    ## [1] "data.frame"

    # View class of 'dataBySpSex' object
    class(dataBySpSex)

    ## [1] "grouped_df" "tbl_df"     "tbl"        "data.frame"

    # View help file for group_by() function
    ?group_by()

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

    ## `summarise()` ungrouping output (override with `.groups` argument)

    # view the data
    dataBySpFem

    ## # A tibble: 3 x 2
    ##   scientificName         n_individuals
    ##   <chr>                          <int>
    ## 1 Peromyscus leucopus              455
    ## 2 Peromyscus maniculatus            98
    ## 3 Peromyscus sp.                     5

Cool!  

## Base R only

So that is nice, but we had to install a new package `dplyr`. You might ask, 
"Is it really worth it to learn new commands if I can do this is base R."  While
we think "yes", why don't you see for yourself.  Here is the base R code needed 
to accomplish the same task.


    # For reference, the same output but using R's base functions
    
    # First, subset the data to only female Peromyscus
    dataFemPero  <- myData[myData$sex == 'F' & 
                       grepl('Peromyscus', myData$scientificName), ]
    
    # Option 1 --------------------------------
    # Use aggregate and then rename columns
    dataBySpFem_agg <-aggregate(dataFemPero$sex ~ dataFemPero$scientificName, 
                       data = dataFemPero, FUN = length)
    names(dataBySpFem_agg) <- c('scientificName', 'n_individuals')
    
    # view output
    dataBySpFem_agg

    ##           scientificName n_individuals
    ## 1    Peromyscus leucopus           455
    ## 2 Peromyscus maniculatus            98
    ## 3         Peromyscus sp.             5

    # Option 2 --------------------------------------------------------
    # Do it by hand
    
    # Get the unique scientificNames in the subset
    sppInDF <- unique(dataFemPero$scientificName[!is.na(dataFemPero$scientificName)])
    
    # Use a loop to calculate the numbers of individuals of each species
    sciName <- vector(); numInd <- vector()
    for (i in sppInDF) {
      sciName <- c(sciName, i)
      numInd <- c(numInd, length(which(dataFemPero$scientificName==i)))
    }
    
    #Create the desired output data frame
    dataBySpFem_byHand <- data.frame('scientificName'=sciName, 
                       'n_individuals'=numInd)
    
    # view output
    dataBySpFem_byHand

    ##           scientificName n_individuals
    ## 1    Peromyscus leucopus           455
    ## 2 Peromyscus maniculatus            98
    ## 3         Peromyscus sp.             5


