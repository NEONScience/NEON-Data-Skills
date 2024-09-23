---
title: Content for download and explore tutorial
output: html_fragment
dateCreated: '2024-09-20'
---

This tutorial covers downloading NEON data, using the Data Portal and 
either the neonUtilities R package or the neonutilities Python package, 
as well as basic instruction in beginning to explore and work with the 
downloaded data, including guidance in navigating data documentation. 
We will explore data of 3 different types, and make a simple figure from 
each.

## NEON data
There are 3 basic categories of NEON data:

1. Remote sensing (AOP) - Data collected by the airborne observation platform, 
e.g. LIDAR, surface reflectance
1. Observational (OS) - Data collected by a human in the field, or in an 
analytical laboratory, e.g. beetle identification, foliar isotopes
1. Instrumentation (IS) - Data collected by an automated, streaming sensor, e.g. 
net radiation, soil carbon dioxide. This category also includes the 
surface-atmosphere exchange (SAE) data, which are processed and structured in 
a unique way, distinct from other instrumentation data 
(see the introductory <a href="https://www.neonscience.org/eddy-data-intro" target="_blank">eddy flux data tutorial</a> for details).

This lesson covers all three types of data. The download procedures are 
similar for all types, but data navigation differs significantly by type.

<div id="ds-objectives" markdown="1">

## Objectives

After completing this activity, you will be able to:

* Download NEON data using the neonUtilities package.
* Understand downloaded data sets and load them into R or Python for analyses.

## Things You’ll Need To Complete This Tutorial
You can follow either the R or Python code throughout this tutorial.
* For R users, we recommend using R version 4+ and RStudio.
* For Python users, we recommend using Python 3.9+.



## Set up: Install Packages {.tabset}

Packages only need to be installed once, you can skip this step after the first time:

### R

* **neonUtilities**: Basic functions for accessing NEON data
* **neonOS**: Functions for common data wrangling needs for NEON observational data.
* **terra**: Spatial data package; needed for working with remote sensing data.


    install.packages("neonUtilities")

    install.packages("neonOS")

    install.packages("terra")

### Python

* **neonutilities**: Basic functions for accessing NEON data
* **rasterio**: Spatial data package; needed for working with remote sensing data.


    pip install neonutilities

    pip install rasterio

## {-}

### Additional Resources

* <a href="https://www.neonscience.org/neon-utilities-python" target="_blank">Tutorial for using neonUtilities from a Python environment.</a>
* <a href="https://github.com/NEONScience/NEON-Utilities/neonUtilities" target="_blank">GitHub repository for neonUtilities</a>
* <a href="https://www.neonscience.org/sites/default/files/cheat-sheet-neonUtilities_0.pdf" target="_blank">neonUtilities cheat sheet</a>. A quick reference guide for users.

</div>


## Set up: Load packages {.tabset}

### R


    library(neonUtilities)

    library(neonOS)

    library(terra)

### Python










































































