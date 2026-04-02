---
title: Content for intro to continuous discharge tutorial
output: html_fragment
dateCreated: '2025-08-08'
editor_options: 
  markdown: 
    wrap: 72
---

::: {#ds-objectives markdown="1"}
## Objectives

After completing this activity, you will be able to:

-   Download and explore the contents of the NEON Continuous discharge
    data product (DP4.00130.001)
-   Understand how the publication history of this data product
    influences the tables available for download
-   Create a single continuous time series of discharge data for a site
    via data aggregation and table joining
-   Plot continuous time series of stage and discharge with associated
    uncertainties for the lifetime of a site

## Things You’ll Need To Complete This Tutorial

You can follow either the R or Python code throughout this tutorial.

-   For R users, we recommend using R version 4+ and RStudio.
-   For Python users, we recommend using Python 3.9+.



## Set up: Install Packages {.tabset}

Packages only need to be installed once, you can skip this step after
the first time:

### R

-   **neonUtilities**: Basic functions for accessing NEON data
-   **tidyverse**: Collection of R packages designed for data science


    install.packages("neonUtilities")

    install.packages("tidyverse")

### Python

-   **os**: Module allowing interaction with user's operating system
-   **pandas**: Module for working with data frames
-   **neonutilities**: Basic functions for accessing NEON data
-   **matplotlib**: Functions for plotting


    pip install os

    pip install pandas

    pip install neonutilities

    pip install matplotlib

##  {.unnumbered}

### Additional Resources

-   <a href="https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data" target="_blank">Tutorial for using neonUtilities from both R and Python environments.</a>
-   <a href="https://github.com/NEONScience/NEON-Utilities/neonUtilities" target="_blank">GitHub repository for neonUtilities</a>
-   <a href="https://www.neonscience.org/sites/default/files/cheat-sheet-neonUtilities_0.pdf" target="_blank">neonUtilities cheat sheet</a>. A quick reference guide for users.
:::

## Set up: Load Packages {.tabset}

### R











































