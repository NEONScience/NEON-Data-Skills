---
title: "Access NEON Data for Metagenomics"
syncID: a52390817d434a748c4adc3a150529e7
description: Using NEON tools to access metadata for metagenomic samples.
dateCreated: "2023-07-08"
authors: Hugh Cross
contributors: null
estimatedTime: 0.4 hours
packagesLibraries: dplyr, ggplot2, neonUtilities, docknitr
topics: Data Analysis, Metadata
languagesTool: R, Bash
dataProduct: DP1.10107.001, DP1.20279.001, DP1.20281.001
code1: null
tutorialSeries: null
urlTitle: "neon-data-for-metagenomics"
---




This tutorial is being run in conjunction with the workshop "FAIR Data and NEON Data discovery at the National Microbiome Data Collaborative", to introduce the attendees to the NMDC data portal. The purpose of this component is to provide a brief introduction to how to download NEON data, with a focus on those NEON data that can be used as metadata for the NMDC metagenomic analyses of NEON samples. We will provide some brief examples of how to download relevant NEON data for soil and aquatic samples, and then how to wrangle the data to link them to NEON metagenomic samples that have been run through the NMDC Edge pipeline. 


<div id="ds-objectives" markdown="1">

## Learning Objectives 
After completing this tutorial you will be able to: 

* Access information on NEON data relevant to metagenomic research.
* Download NEON data for soil and aquatic samples.
* Process NEON sample data to be able to analyze with metagenomic data

## Things You’ll Need To Complete This Tutorial


### R Programming Language
You will need a current version of R to complete this tutorial. We also recommend 
the RStudio IDE to work with R. 

### R Packages to Install
Prior to starting the tutorial ensure that the following packages are installed. 
* **neonUtilities**: Basic functions for accessing NEON data
* **neonOS**: Functions for common data wrangling needs for NEON observational data
* **tidyverse**: <a href="https://www.tidyverse.org/" target="_blank"> A collection of R packages</a> designed for data science

All of these packages can be installed from CRAN:


    install.packages("neonUtilities")
    install.packages("neonOS")
    install.packages("tidyverse")

<a href="/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Example Data Set

I need to determine if we need an example data set
This tutorial will teach you how to download data directly from the NEON data 
portal.  This example data set is provided as an optional download and a backup. 

### Working Directory
This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

## Additional Resources
This tutorial will provide some basic examples for for finding information and downloading NEON data. For more details on downloading NEON data, <a href="https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data" target="_blank">the "Download and Explore NEON Data" tutorial</a> provides an overview of downloading data using the Data Portal and the neonUtilities R package, and <a href="https://www.neonscience.org/neonDataStackR" target="_blank">this tutorial</a> goes into detail on the neonUtilities package and how the each function works. Most of the examples provided here utilize the R programming language, and NEON provides <a href="https://www.neonscience.org/resources/learning-hub/tutorials/basic-r-skills" target="_blank">a tutorial series on basic R skills to get you started</a>. 
 
</div>

<br/>
<br/>
<br/>

## The NEON Data Portal 

NEON provides a wealth of data to assist with your research. <a href="https://data.neonscience.org/" target="_blank">The NEON Data Portal </a> is the best place to start looking for the data you want. There is a lot of information on this page. For now, we will have a quick tour. 

<figure class="half">
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/graphics/nmdc_neon/data_portal_front_page.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/graphics/nmdc_neon/data_portal_front_page.png"
    alt="RStudio window with default template of a new R Markdown file.">
    </a>
    <figcaption></figcaption>
</figure>  

There are many ways to search the Data Portal, including searching by site. The page includes an interactive map.

<br/>
<br/>
<br/>

### Explore Data Products

From the Data Portal main page, Click on the **EXPLORE** button in the box called "Explore Data Products", or just <a href="https://data.neonscience.org/data-products/explore" target="_blank">go to this link</a>, and you can search by key words or data product codes. For example, type 'metagenomics' in the Search field, and then scroll down through the results. 

Click on the link to <a href="https://data.neonscience.org/data-products/DP1.10107.001" target="_blank">Soil microbe metagenome sequences</a> and the information for this data product will open in a new page. On this page there is a lot of useful information, including a description of the tables are included for the data, links to documents, a Quick Start guide, and much more. You of course are able to download data from this page, and can select specific sites and time ranges in an interactive table. However, in this tutorial we are going to use the neonUtilities R package to access the data. 

<br/>
<br/>

## NEON metadata for metagenomic data 


### Downloading data with neonUtilities

The metagenomics data available on the NEON website includes only the raw sequence files. It is more useful to access the data processed through the NMDC Edge pipeline, as we have learned. However, the NEON samples collected for metagenomic sequencing were also subjected to a wide range of measurements, including carbon and nitrogen isotopes, soil temperature, and pH. The functional and taxonomic information available on the NMDC data portal can be analyzed along with all other NEON data from the soil and aquatic samples. 

We will start by accessing some soil chemical and physical measurements using the neonUtilities package. But even though we will be using R to do this, it is still useful to look up the information on the NEON Data Portal. Go back to the <a href="https://data.neonscience.org/data-products/explore" target="_blank">Explore Data Products page</a>, reset all filters, then type in "Soil physical and chemical properties" in the Search bar. Scroll down and click on "Soil physical and chemical properties, periodic" (DP1.10086.001). 

With the information from the Data Portal, we can download this data product using the **neonUtilities** package. We will start with a subset of terrestrial sites. Go ahead and set up the following command in a text file in RStudio or text editor. 



    #
    library(neonUtilities)
    
    soilTrialSites = c("HARV","SCBI","DSNY","UNDE","WREF")
    
    soilChem2018 <- loadByProduct(
      dpID='DP1.10086.001',
      startdate = "2018-01",
      enddate = "2018-12",
      check.size = FALSE,
      site = soilTrialSites,
      package='expanded')

For full details on the `loadByProduct()` function, see the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/neondatastackr" target="_blank">'Use the neonUtilities Package' tutorial</a>. Here we will just note some of the parameters. The `dpID` parameters is taken right from the Data Portal page for that data product. The `startdate` and `enddate` define the time range, and for the `site` parameter, we can enter a list of the four-letter codes for each site. The `check.size` we are leaving as `FALSE`, to prevent the function from warning us before big downloads. If you are going to do a big download, for example, if you do not specify a time range with `startdate/enddate` or define the sites to download using the `site` parameter, it is a good idea to leave this option at `TRUE`. If you are incorporating this code into a script as part of a pipeline, for example, then you should set this at `FALSE`. 

<br/>

### Viewing the data

Once you have run this code and downloaded the data, we can have a look. The object returned by `loadByProduct()` function is a named list of data frames. To view or access each one, you can select them from the list of data frames using the `$` operator. For example, if we would like to view the table `sls_soilChemistry` table in RStudio, then we can use the `View()` function:


    View(soilChem2018$sls_soilChemistry)

You will then see a table open in a new tab in RStudio. You can see a lot of information in this table. This table contains multiple measurements of soil chemistry data that could be useful for metagenomics analysis. These include carbon and nitrogen isotopes (`organic13C`, `d15N`), percent C and N (`organicCPercent`, `nitrogenPercent`), and ratio of carbon to nitrogen (`CNratio`). 

Take some time on your own to explore the other tables with this download.

<br/>
<br/>

## Wrangling sample data for metagenomic samples

Now that you are familiar with downloading and viewing data through the neonUtilities package, we can start to focus on linking the data to the metagenomic samples. For soil samples, the DNA samples for metagenomics are combined from individual soil samples. This is why you will not see any of the chemistry data we just viewed corresponding to any metagenomic DNA sample directly. We need to access the list of samples that were combined to create a soil composite sample, so we can link these data directly. For this we look at the `sls_metagenomicsPooling` table.   


    View(soilChem2018$sls_metagenomicsPooling)

In this table the list for each composite DNA sample is in the column `genomicsPooledIDList`. For example, if we want to look at the list of samples used for the first composite sample 'HARV_033-O-20180709-COMP' (sample is in the `genomicsSampleID` field), we can pull up the list:


    soilChem2018$sls_metagenomicsPooling$genomicsPooledIDList[1]
    # you can check to confirm the first sample is HARV_033-O-20180709-COMP
    soilChem2018$sls_metagenomicsPooling[1,'genomicsSampleID']
    # then you can get the list:
    soilChem2018$sls_metagenomicsPooling[1,'genomicsPooledIDList']
    # You can also see them together:
    soilChem2018$sls_metagenomicsPooling[1,10:11]

The content of this field is a list demarcated by the pipe symbol ("|"): 

"HARV_033-O-6.5-31.5-20180709|HARV_033-O-21-34.5-20180709|HARV_033-O-8.5-15.5-20180709"

From the list you can see that there are three samples for the composite sample (there can be anywhere from 1-3 samples for each composite), all from plot **HARV_033** collected on 7/9/2018, and all from the organic horizon. 

<br/>
<br/>


## Additional examples for accessing data

<br/>
<br/>
<br/>
