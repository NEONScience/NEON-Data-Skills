---
layout: post
title: "Install Required R Packages "
description: "This tutorial covers the R packages that you will need to have 
installed for the Institute."
date: 2016-05-18
dateCreated: 2014-05-06
lastModified: 2016-05-18
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries:
authors:
contributors:
categories: [tutorial-series]
tutorialSeries: [pre-institute0]
mainTag: pre-institute0
code1: 
image:
 feature: data-institutes.png
 credit:
 creditlink:
permalink: /tutorial-series/install-R-packages
comments: true
---

## R and RStudio

Once R and RStudio are installed (in
<a href="{{ site.baseurl }}/tutorial-series/setup-your-computer" target="_blank"> *Install Git, Bash Shell & R / RStudio*</a>
), open RStudio to make sure it works and you don’t get any error messages. Then,
install the needed R packages. 

## Install/Update R Packages

Please make sure all of these packages are installed and up to date on your 
computer prior to the Institute.

* `install.packages(c("raster", "rasterVis", "rgdal", "rgeos", "rmarkdown", "knitr", "plyr", "dplyr", "ggplot2", "plotly"))`
* The `Rhdf5` package is not on CRAN and must be downloaded directly from 
Bioconductor. The can be done using these two commands directly in your R 
console. 
	+ `source("http://bioconductor.org/biocLite.R")`
	+ `biocLite("rhdf5")`
