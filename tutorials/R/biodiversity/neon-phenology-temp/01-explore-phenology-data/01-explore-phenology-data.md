---
syncID: 57a6e5db49494a4b82f9c1bdeec70e81
title: "Work With NEON's Plant Phenology Data"
description: "Learn to work with NEON plant phenology observation data (NEON.DP1.10055)."
dateCreated: 2017-08-01
authors: Megan A. Jones, Natalie Robinson, Lee Stanish
contributors: Katie Jones, Cody Flagg, Karlee Bradley
estimatedTime: 
packagesLibraries: dplyr, ggplot2
topics: time-series, phenology, organisms
languagesTool: R
dataProduct: NEON.DP1.10055
code1: R/NEON-pheno-temp-timeseries/01-explore-phenology-data.R
tutorialSeries: neon-pheno-temp-series
urlTitle: neon-plant-pheno-data-r
---


Many organisms, including plants, show patterns of change across seasons - 
the different stages of this observable change are called phenophases. In this 
tutorial we explore how to work with NEON plant phenophase data. 



<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:

 * work with "stacked" NEON Plant Phenology Observation data. 
 * correctly format date data. 
 * use dplyr functions to filter data.
 * plot time series data in a bar plot using ggplot the function. 

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages

* **ggplot2:** `install.packages("ggplot2")`
* **dplyr:** `install.packages("dplyr")`


<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Download Data 

<h3> <a href="https://ndownloader.figshare.com/files/9012085">
NEON Teaching Data Subset: Plant Phenology & Single Aspirated Air Temperature</a></h3>


The data used in this lesson were collected at the 
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map" target="_blank"> Domain 02 field sites</a>. 
This teaching data subset represent a small subset of the data NEON will collect over 
30 years and at 20 domains across the United States. NEON data are available on the
<a href="http://data.neonscience.org/" target="_blank">NEON data portal</a>. 

<a href="https://ndownloader.figshare.com/files/9012085" class="link--button link--arrow">
Download Dataset</a>





****
**Set Working Directory:** This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

**R Script & Challenge Code:** NEON data lessons often contain challenges that reinforce 
learned skills. If available, the code for challenge solutions is found in the
downloadable R script of the entire lesson, available in the footer of each lesson page.


****

## Additional Resources

* NEON <a href="http://data.neonscience.org" target="_blank"> data portal </a>
* NEON Plant Phenology Observations <a href="http://data.neonscience.org/api/v0/documents/NEON_phenology_userGuide_vA" target="_blank"> data product user guide</a>
* RStudio's <a href="https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf" target="_blank"> data wrangling (dplyr/tidyr) cheatsheet</a>
* <a href="https://github.com/NEONScience" target="_blank">NEONScience GitHub Organization</a>
* <a href="https://cran.r-project.org/web/packages/nneo/index.html" target="_blank">nneo API wrapper on CRAN </a>

</div>

Plants change throughout the year - these are phenophases. 
Why do they change? 

## Explore Phenology Data 

The following sections provide a brief overview of the NEON plant phenology 
observation data. When designing a research project using this data, you 
need to consult the 
<a href="http://data.neonscience.org/data-products/DP1.10055.001" target="_blank">documents associated with this data product</a> and not rely soley on this summary. 

*The following description of the NEON Plant Phenology Observation data is modified 
from the <a href="http://data.neonscience.org/api/v0/documents/NEON_phenology_userGuide_vA" target="_blank"> data product user guide</a>.*

### NEON Plant Phenology Observation Data

NEON collects plant phenology data and provides it as NEON data product 
**NEON.DP1.10055**.

The plant phenology observations data product provides in-situ observations of 
the phenological status and intensity of tagged plants (or patches) during 
discrete observations events. 

Sampling occurs at all terrestrial field sites at site and season specific 
intervals. Three species for phenology observation are selected based on relative 
abundance in the Tower airshed. There are 30 individuals of each target species 
monitored at each transect. 

#### Status-based Monitoring

NEON employs status-based monitoring, in which the phenological condition of an 
individual is reported any time that individual is observed. At every observations 
bout, records are generated for every phenophase that is occurring and for every 
phenophase not occurring. With this approach, events (such as leaf emergence in 
Mediterranean climates, or flowering in many desert species) that may occur 
multiple times during a single year, can be captured. Continuous reporting of
phenophase status enables quantification of the duration of phenophases rather 
than just their date of onset while allows enabling the explicit quantification 
of uncertainty in phenophase transition dates that are introduced by monitoring 
in discrete temporal bouts.

Specific products derived from this sampling include the observed phenophase 
status (whether or not a phenophase is occurring) and the intensity of 
phenophases for individuals in which phenophase status = ‘yes’. Phenophases 
reported are derived from the USA National Phenology Network (USA-NPN) categories. 
The number of phenophases observed varies by growth form and ranges from 1 
phenophase (cactus) to 7 phenophases (semi-evergreen broadleaf). 
In this tutorial we will focus only on the state of the phenophase, not the 
phenophase intensity data. 

#### Phenology Transects 

Plant phenology observations occurs at all terrestrial NEON sites along an 800 
meter square loop transect (primary) and within a 200 m x 200 m plot located 
within view of a canopy level, tower-mounted, phenology camera.

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/neon-organisms/NEONphenoTransect.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/neon-organisms/NEONphenoTransect.png"></a>
	<figcaption> Diagram of a phenology transect layout, with meter layout marked.
	Point-level geolocations are recorded at eight referecne points along the 
	perimeter, plot-level geolaocation at the plot centoid (star). 
	Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>

#### Timing of Observations

At each site, there are: 

* ~50 observation bouts per year. 
* no more that 100 sampling points per phenology transect.
* no more than 9 sampling points per phenocam plot. 
* 1 bout per year to collect annual size and disease status measurements from 
each sampling point.


#### Available Data Tables

In the downloaded data packet, data are available in two main files

* **phe_statusintensity:** Plant phenophase status and intensity data 
* **phe_perindividual:** Geolocation and taxonomic identification for phenology plants
* **phe_perindividualperyear:** recorded once a year, essentially the "metadata" 
about the plant: DBH, height, etc. 


There are other files in each download including a **readme** with information on 
the data product and the download; a **variables** file that defines the 
term descriptions, data types, and units; a **validation** file with ata entry validation and 
parsing rules; and an **XML** with machine readable metadata. 

## Stack NEON Data

NEON data are delivered in a site and year-month format. When you download data,
you will get a single zipped file containing a directory for each month and site that you've 
requested data for. Dealing with these separate tables from even one or two sites
over a 12 month period can be a bit overwhelming. Luckily NEON provides an R package
**neonUtilities** that takes the unzipped downloaded file and joining the data 
files. The teaching data downloaded with this tutorial is already stacked. If you
are working with other NEON data, please go through the tutorial to stack the data
in 
<a href="https://www.neonscience.org/neonDataStackR" target="_blank">R</a> or in <a href="https://www.neonscience.org/neon-utilities-python" target="_blank">Python</a> 
and then return to this tutorial. 

## Work with NEON Data

When we do this for phenology data we get three files, one for each data table, 
with all the data from your site and date range of interest. 

Let's start by loading our data of interest. 



    library(dplyr)
    library(ggplot2)
    library(lubridate)  
    
    
    # set working directory to ensure R can find the file we wish to import
    # setwd("working-dir-path-here")
    
    
    # Read in data
    ind <- read.csv('NEON-pheno-temp-timeseries/pheno/phe_perindividual.csv', 
    		stringsAsFactors = FALSE )

    ## Warning in file(file, "rt"): cannot open file 'NEON-pheno-temp-timeseries/pheno/
    ## phe_perindividual.csv': No such file or directory

    ## Error in file(file, "rt"): cannot open the connection

    status <- read.csv('NEON-pheno-temp-timeseries/pheno/phe_statusintensity.csv', 
    		stringsAsFactors = FALSE)

    ## Warning in file(file, "rt"): cannot open file 'NEON-pheno-temp-timeseries/pheno/
    ## phe_statusintensity.csv': No such file or directory

    ## Error in file(file, "rt"): cannot open the connection

Let's explore the data. Let's get to know what the `ind` dataframe looks like.


    # What are the fieldnames in this dataset?
    names(ind)

    ## Error in eval(expr, envir, enclos): object 'ind' not found

    # how many rows are in the data?
    nrow(ind)

    ## Error in nrow(ind): object 'ind' not found

    # look at the first six rows of data.
    head(ind)

    ## Error in head(ind): object 'ind' not found

    # look at the structure of the dataframe.
    str(ind)

    ## Error in str(ind): object 'ind' not found

Note that if you first open you data file in Excel, you might see 06/14/2014 as 
the format instead of 2014-06-14. Excel can do some ~~weird~~ interesting things
to dates.

#### Individual locations

To get the specific location data of each individual you would need to do some 
math, or you can use the NEON geolocation 
<a href="https://github.com/NEONScience/NEON-geolocation" target="_blank"> **geoNEON**</a>. 

Now let's look at the status data. 


    # What variables are included in this dataset?
    names(status)

    ## Error in eval(expr, envir, enclos): object 'status' not found

    nrow(status)

    ## Error in nrow(status): object 'status' not found

    head(status)

    ## Error in head(status): object 'status' not found

    str(status)

    ## Error in str(status): object 'status' not found

    # date range
    min(status$date)

    ## Error in eval(expr, envir, enclos): object 'status' not found

    max(status$date)

    ## Error in eval(expr, envir, enclos): object 'status' not found

The `uid` is not important to understanding the data so we are going to remove `uid`. 
However, if you are every reporting an error in the data you should include this
with your report. 


    ind <- select(ind,-uid)

    ## Error in select(ind, -uid): object 'ind' not found

    status <- select (status, -uid)

    ## Error in select(status, -uid): object 'status' not found

## Clean up the Data

* remove duplicates (full rows)
* convert date
* retain only the latest `editedDate` in the perIndividual table.

### Remove Duplicates

The individual table (ind) file is included in each site by month-year file. As 
a result when all the tables are stacked there are many duplicates. 

Let's remove any duplicates that exist.


    # remove duplicates
    ## expect many
    
    ind_noD <- distinct(ind)

    ## Error in distinct(ind): object 'ind' not found

    nrow(ind_noD)

    ## Error in nrow(ind_noD): object 'ind_noD' not found

    status_noD<-distinct(status)

    ## Error in distinct(status): object 'status' not found

    nrow(status_noD)

    ## Error in nrow(status_noD): object 'status_noD' not found


### Variable Overlap between Tables

From the initial inspection of the data we can see there is overlap in variable
names between the fields. 

Let's see what they are.


    # where is there an intersection of names
    sameName <- intersect(names(status_noD), names(ind_noD))

    ## Error in intersect(names(status_noD), names(ind_noD)): object 'status_noD' not found

    sameName

    ## Error in eval(expr, envir, enclos): object 'sameName' not found

There are several fields that overlap between the datasets. Some of these are
expected to be the same and will be what we join on. 

However, some of these will have different values in each table. We want to keep 
those distinct value and not join on them. 

We want to rename common fields before joining:

* editedDate
* measuredBy
* recordedBy
* samplingProtocolVersion
* remarks
* dataQF

Now we want to rename the variables that would have duplicate names. We can 
rename all the variables in the status object to have "Stat" at the end of the 
variable name. 


    # rename status editedDate
    status_noD <- rename(status_noD, editedDateStat=editedDate, 
    		measuredByStat=measuredBy, recordedByStat=recordedBy, 
    		samplingProtocolVersionStat=samplingProtocolVersion, 
    		remarksStat=remarks, dataQFStat=dataQF)

    ## Error in rename(status_noD, editedDateStat = editedDate, measuredByStat = measuredBy, : object 'status_noD' not found


### Convert to Date

Our `addDate` and `date` columns are stored as a `character` class. We need to 
convert it to a date class. The `as.Date()` function in base R will do this. 


    # convert column to date class
    ind_noD$editedDate <- as.Date(ind_noD$editedDate)

    ## Error in as.Date(ind_noD$editedDate): object 'ind_noD' not found

    str(ind_noD$editedDate)

    ## Error in str(ind_noD$editedDate): object 'ind_noD' not found

    status_noD$date <- as.Date(status_noD$date)

    ## Error in as.Date(status_noD$date): object 'status_noD' not found

    str(status_noD$date)

    ## Error in str(status_noD$date): object 'status_noD' not found

The individual (ind) table contains all instances that any of the location or 
taxonomy data of an individual was updated. Therefore there are many rows for
some individuals.  We only want the latest `editedDate` on ind. 


    # retain only the max of the date for each individualID
    ind_last <- ind_noD %>%
    	group_by(individualID) %>%
    	filter(editedDate==max(editedDate))

    ## Error in eval(lhs, parent, parent): object 'ind_noD' not found

    # oh wait, duplicate dates, retain only one
    ind_lastnoD <- ind_last %>%
    	group_by(editedDate, individualID) %>%
    	filter(row_number()==1)

    ## Error in eval(lhs, parent, parent): object 'ind_last' not found

### Join Dataframes

Now we can join the two data frames on all the variables with the same name. 
We use a `left_join()` from the dpylr package because we want to match all the 
rows from the "left" (first) dateframe to any rows that also occur in the "right"
 (second) dataframe.  
 
 Check out RStudio's 
 <a href="https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf" target="_blank"> data wrangling (dplyr/tidyr) cheatsheet</a>
 for other types of joins. 
 

    # Create a new dataframe "phe_ind" with all the data from status and some from ind_lastnoD
    phe_ind <- left_join(status_noD, ind_lastnoD)

    ## Error in left_join(status_noD, ind_lastnoD): object 'status_noD' not found

Ack!  Two different data types.  Why?  Notice that when we checked for intersecting variable names, `data` was one of these variables. We didn't change the `data` column in the ind object from a `character` class to a date class. But, we actually don't want to combine these two `date` columns.

Try it again.  

We can rename the `date` column in ind so that the two dataframes can now join together.


    # rename variables in ind
    ind_noD <- rename(ind_noD, addDate = date)

    ## Error in rename(ind_noD, addDate = date): object 'ind_noD' not found

    # Create a new dataframe "phe_ind" with all the data from status and some from ind_lastnoD
    phe_ind <- left_join(status_noD, ind_lastnoD)

    ## Error in left_join(status_noD, ind_lastnoD): object 'status_noD' not found

Worked this time! 
Now that we have clean datasets we can begin looking into our particular data to 
address our research question: do plants show patterns of changes in phenophase 
across season?

## Patterns in Phenophase  

From our larger dataset (several sites, species, phenophases), let's create a
dataframe with only the data from a single site, species, and phenophase and 
call it `phe_1sp`.

## Select Site(s) of Interest

To do this, we'll first select our site of interest. Note how we set this up 
with an object that is our site of interest. This will allow us to more easily change 
which site or sites if we want to adapt our code later. 


    # set site of interest
    siteOfInterest <- "SCBI"
    
    # use filter to select only the site of Interest 
    ## using %in% allows one to add a vector if you want more than one site. 
    ## could also do it with == instead of %in% but won't work with vectors
    
    phe_1sp <- filter(phe_ind, siteID %in% siteOfInterest)

    ## Error in filter(phe_ind, siteID %in% siteOfInterest): object 'phe_ind' not found

## Select Species of Interest

And now select a single species of interest. For now let's choose the flowering 
tree *Liriodendron tulipifera* (LITU). 


    # see which species are present
    unique(phe_1sp$taxonID)

    ## Error in unique(phe_1sp$taxonID): object 'phe_1sp' not found

    speciesOfInterest <- "LITU"
    
    #subset to just "LITU"
    # here just use == but could also use %in%
    phe_1sp <- filter(phe_1sp, taxonID==speciesOfInterest)

    ## Error in filter(phe_1sp, taxonID == speciesOfInterest): object 'phe_1sp' not found

    # check that it worked
    unique(phe_1sp$taxonID)

    ## Error in unique(phe_1sp$taxonID): object 'phe_1sp' not found


## Select Phenophase of Interest

And, perhaps a single phenophase. 


    # see which species are present
    unique(phe_1sp$phenophaseName)

    ## Error in unique(phe_1sp$phenophaseName): object 'phe_1sp' not found

    phenophaseOfInterest <- "Leaves"
    
    #subset to just the phenosphase of Interest 
    phe_1sp <- filter(phe_1sp, phenophaseName %in% phenophaseOfInterest)

    ## Error in filter(phe_1sp, phenophaseName %in% phenophaseOfInterest): object 'phe_1sp' not found

    # check that it worked
    unique(phe_1sp$phenophaseName)

    ## Error in unique(phe_1sp$phenophaseName): object 'phe_1sp' not found

## Total in Phenophase of Interest

The `phenophaseState` is recorded as "yes" or "no" that the individual is in that
phenophase. The `phenophaseIntensity` are categories for how much of the indvidual
is in that state. For now, we will stick with `phenophaseState`. 

We can now calculate the total individual with that state. 

Here we use pipes `%>%` from the dpylr package to "pass" objects onto the next
function. 


    # Total in status by day
    sampSize <- count(phe_1sp, date)

    ## Error in count(phe_1sp, date): object 'phe_1sp' not found

    inStat <- phe_1sp %>%
    	group_by(date) %>%
      count(phenophaseStatus)

    ## Error in eval(lhs, parent, parent): object 'phe_1sp' not found

    inStat <- full_join(sampSize, inStat, by="date")

    ## Error in full_join(sampSize, inStat, by = "date"): object 'sampSize' not found

    # Retain only Yes
    inStat_T <- filter(inStat, phenophaseStatus %in% "yes")

    ## Error in filter(inStat, phenophaseStatus %in% "yes"): object 'inStat' not found

Now that we have the data we can plot it. 

## Plot with ggplot

The `ggplot()` function within the `ggplot2` package gives us considerable control
over plot appearance. Three basic elements are needed for `ggplot()` to work:

 1. The **data_frame:** containing the variables that we wish to plot,
 2. **`aes` (aesthetics):** which denotes which variables will map to the x-, y-
 (and other) axes,  
 3. **`geom_XXXX` (geometry):** which defines the data's graphical representation
 (e.g. points (`geom_point`), bars (`geom_bar`), lines (`geom_line`), etc).
 
The syntax begins with the base statement that includes the `data_frame`
(`inStat_T`) and associated x (`date`) and y (`n`) variables to be
plotted:

`ggplot(inStat_T, aes(date, n))`

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** For a more detailed introduction to 
using `ggplot()`, visit 
<a href="https://www.neonscience.org/dc-time-series-plot-ggplot-r" target="_blank"> *Time Series 05: Plot Time Series with ggplot2 in R* tutorial</a>. 
</div>

### Bar Plots with ggplot
To successfully plot, the last piece that is needed is the `geom`etry type. 
To create a bar plot, we set the `geom` element from to `geom_bar()`.  

The default setting for a ggplot bar plot -  `geom_bar()` - is a histogram
designated by `stat="bin"`. However, in this case, we want to plot count values. 
We can use `geom_bar(stat="identity")` to force ggplot to plot actual values.


    # plot number of individuals in leaf
    phenoPlot <- ggplot(inStat_T, aes(date, n.y)) +
        geom_bar(stat="identity", na.rm = TRUE) 

    ## Error in ggplot(inStat_T, aes(date, n.y)): object 'inStat_T' not found

    phenoPlot

    ## Error in eval(expr, envir, enclos): object 'phenoPlot' not found

    # Now let's make the plot look a bit more presentable
    phenoPlot <- ggplot(inStat_T, aes(date, n.y)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Total Individuals in Leaf") +
        xlab("Date") + ylab("Number of Individuals") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))

    ## Error in ggplot(inStat_T, aes(date, n.y)): object 'inStat_T' not found

    phenoPlot

    ## Error in eval(expr, envir, enclos): object 'phenoPlot' not found

We could also covert this to percentage and plot that. 


    # convert to percent
    inStat_T$percent<- ((inStat_T$n.y)/inStat_T$n.x)*100

    ## Error in eval(expr, envir, enclos): object 'inStat_T' not found

    # plot percent of leaves
    phenoPlot_P <- ggplot(inStat_T, aes(date, percent)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Proportion in Leaf") +
        xlab("Date") + ylab("% of Individuals") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))

    ## Error in ggplot(inStat_T, aes(date, percent)): object 'inStat_T' not found

    phenoPlot_P

    ## Error in eval(expr, envir, enclos): object 'phenoPlot_P' not found

The plots demonstrate that, while the 2016 data show the nice expected pattern 
of increasing leaf-out, peak, and drop-off, we seem to be missing the increase 
in leaf-out in 2015. Looking at the data, we see that there was no data collected
before May of 2015 -- we're missing most of leaf out!

## Filter by Date

That may create problems with downstream analyses. Let's filter the dataset to 
include just 2016.


    # use filter to select only the site of Interest 
    phe_1sp_2016 <- filter(inStat_T, date >= "2016-01-01")

    ## Error in filter(inStat_T, date >= "2016-01-01"): object 'inStat_T' not found

    # did it work?
    range(phe_1sp_2016$date)

    ## Error in eval(expr, envir, enclos): object 'phe_1sp_2016' not found

How does that look? 


    # Now let's make the plot look a bit more presentable
    phenoPlot16 <- ggplot(phe_1sp_2016, aes(date, n.y)) +
        geom_bar(stat="identity", na.rm = TRUE) +
        ggtitle("Total Individuals in Leaf") +
        xlab("Date") + ylab("Number of Individuals") +
        theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
        theme(text = element_text(size=18))

    ## Error in ggplot(phe_1sp_2016, aes(date, n.y)): object 'phe_1sp_2016' not found

    phenoPlot16

    ## Error in eval(expr, envir, enclos): object 'phenoPlot16' not found


## Drivers of Phenology

Now that we see that there are differences in and shifts in phenophases, what 
are the drivers of phenophases?

The NEON phenology measurements track sensitive and easily observed indicators 
of biotic responses to climate variability by monitoring the timing and duration 
of phenological stagesin plant communities. Plant phenology is affected by forces 
such as temperature, timing and duration of pest infestations and disease outbreaks, 
water fluxes, nutrient budgets, carbon dynamics, and food availability and has 
feedbacks to trophic interactions, carbon sequestration, community composition 
and ecosystem function.  (quoted from 
<a href="http://data.neonscience.org/api/v0/documents/NEON_phenology_userGuide_vA" target="_blank"> Plant Phenology Observations user guide</a>.)



    ## Error in is.data.frame(x): object 'phe_1sp_2016' not found


