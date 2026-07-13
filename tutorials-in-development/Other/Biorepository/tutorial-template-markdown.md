---
syncID:
title: "NEON Data Skills Tutorial Template"
description: "This is a template page to be copied. Do not edit this template directly or your PR will be rejected."
dateCreated: 2017-12-08
authors: Megan A. Jones
contributors: 
estimatedTime: 
packagesLibraries: 
topics: 
languagesTool: 
dataProduct: 
code1: 
tutorialSeries: 
urlTitle: 
---

This template should be used to start new tutorials. This .md version of the 
template can be used, however there are also R Markdown and Jupyter Notebook 
templates if you will be working in one of those formats. 

All tutorials then have an Info Box with the information necessary for a new user
to NEON tutorials to complete the tutorial. This template has the "Things You'll 
Need to Complete this Tutorial" includes information for R but substitute the 
appropriate information for another language as needed. 

<div id="ds-objectives" markdown="1">

## Learning Objectives 
After completing this tutorial you will be able to: 

* Create a new NEON Data Skills teaching module. 

## Things You’ll Need To Complete This Tutorial

### R Programming Language
You will need a current version of R to complete this tutorial. We also recommend 
the RStudio IDE to work with R. 

### R Packages to Install
Prior to starting the tutorial ensure that the following packages are installed. 
* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`
* **sp:** `install.packages("sp")`

<a href="/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Example Data Set

This tutorial will teach you how to download data directly from the NEON data 
portal.  This example data set is provided as an optional download and a backup. 

#### NEON Teaching Data Subset: Plant Phenology & Single Aspirated Air Temperature

The data used in this tutorial were collected at the 
<a href="http://www.neonscience.org" target="_blank"> National Ecological Observatory Network's</a> 
<a href="/field-sites/field-sites-map" target="_blank"> Domain 02 field sites</a>.  

* National Ecological Observatory Network. 2020. Data Product DP1.10055.001, Plant phenology observations. Provisional data downloaded from http://data.neonscience.org on February 5, 2020. Battelle, Boulder, CO, USA NEON. 2020.
* National Ecological Observatory Network. 2020. Data Product DP1.00002.001, Single aspirated air temperature. Provisional data downloaded from http://data.neonscience.org on February 5, 2020. Battelle, Boulder, CO, USA NEON. 2020.

<a href="https://ndownloader.figshare.com/files/9012085" class="link--button link--arrow">
Download Dataset</a>

### Working Directory
This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

## Additional Resources
You can list any additional resources you'd like to link to if needed. 

* <a href="URL Here" target="_blank"> Resource Name/a>,
 
</div>

Once all the information in the Info Box is complete, then the tutorial really 
begins. H2 headers are used for page navigation on the website and should be used
to denote important sections. H3 & H4 headers can be used for sub headers. 

## Use Template to Create New Tutorial. 
To create a new tutorial, copy this template and save it in the /tutorials-in-development/ 
directory of your fork of the NEON-Data-Skills GitHub repo. If you have questions 
on using a forking workflow in GitHub, please see the series: 
https://www.neonscience.org/version-control-git-series

If you are creating a series of tutorials (recommended if you have lots of learning 
objectives), the "cover page" content for the series is created in the NEONScience.org
Drupal environment. Please create your content in a .md or Word-type document and
email to Megan Jones or neondataskills -at- battelleEcology dot org.  


## Additional information about the YAML Header

This header must be at the top of each tutorial so that all associated metadata 
will appear correctly. (Spaces at beginning of each line only added so as not to render if this document is knit)

    ---
    syncID: sync-id-from-list - this will be added by NEON staff, you do not need to include
    title: "Descriptive Title In Title Case"
    description: "Descriptive text about the tutorial here. Must be all on one line no matter how long."
    dateCreated: 2015-08-01
    authors: Megan A. Jones, Each Author Separated by Commas, 
    contributors: Jane Doe, Also Seperate, By Commas
    estimatedTime: 1.5 hrs
    packagesLibraries: raster, rhdf5, rgdal
    *see list in processing_code/_data/packagesLibraries.yml for the correct list. If you would like to add a term please include in your PR message. 
    topics: data-analysis, data-visualization, HDF5, spatial-data-gis 
    *see list in processing_code/_data/tags.yml for the correct list. If you would like to add a term please include in your PR message. 
    languagesTool: R, python
    *see list in processing_code/_data/languagesTool.yml for the correct list. If you would like to add a term please include in your PR message. 
    dataProduct: DP1.0001.01
    *all NEON data products used in the tutorial written in the above format. (no .yml for this list). 
    code1: code/R/neon-utitlites/
    *the relative file path (code/...) of any code related to the tutorials so that it can be downloaded at the end of the tutorial
    tutorialSeries: 
    *if the tutorial is part of a series, this metadata isn't used by the Drupal site but is useful for tutorial management
    urlTitle: styles-css 
    *a short url that is descriptive but not long
    ---

## Styling 

Our tutorials are styled with Markdown with a few exceptions (see links). 
For a simple markdown overview, check out 
<a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank">this cheatsheet</a>.

We also use specific styling to improve accessibility of our materials and to match 
NEONScience.org CSS. Please refer to the 
<a href="https://github.com/NEONScience/NEON-Data-Skills/blob/master/tutorials/NDS-style-guide.md" target="_blank">NEON Data Skills Style Guide</a>. 
In particular, please not that we html with target="_blank" for all links. We 
do not use Markdown formatting for any links. 

## Submission & Review 
When you are ready for review of your tutorial, complete a Pull Request to the 
NEONScience/NEON-Data-Skills repository. If you have questions on using a forking workflow in GitHub, please see there series: 
<a href="https://www.neonscience.org/version-control-git-series" target="_blank"> More on Packages in R </a>– 


