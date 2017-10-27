---
syncID: ee063c4b3bef435f8d7b7a472266bc98
title: "Data Institute: Install Required R Packages"
description: "This tutorial covers the R packages that you will need to have installed for the Institute."
dateCreated: 2014-05-06
authors:
contributors:
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries:
topics:
subtopics: 
languagesTool: R
dataProduct:
code1: 
tutorialSeries:
urlTitle: di-packages-r
---

## R and RStudio

Once R and RStudio are installed (in
<a href="/setup-git-bash-rstudio" target="_blank"> *Install Git, Bash Shell, R & RStudio*</a>
), open RStudio to make sure it works and you don’t get any error messages. Then,
install the needed R packages. 

## Install/Update R Packages

Please make sure all of these packages are installed and up to date on your 
computer prior to the Institute.

* `install.packages(c("raster", "rasterVis", "rgdal", "rgeos", "rmarkdown", "knitr", "plyr", "dplyr", "ggplot2", "plotly"))`
* The `rhdf5` package is not on CRAN and must be downloaded directly from 
Bioconductor. The can be done using these two commands directly in your R 
console. 
	+ `source("http://bioconductor.org/biocLite.R")`
	+ `biocLite("rhdf5")`
