---
syncID: 8ab4445008fd408fab9992c5c8751505
title: "Test reticulate tabs"
description: Test for tabbed tutorials with R and Python code. Do not publish this tutorial.
dateCreated: '2024-04-25'
dataProducts: 
authors: Claire K. Lunch
contributors: 
estimatedTime: 0 hours
packagesLibraries: neonUtilities, neonutilities
topics: data-management, rep-sci
languageTool: R, Python
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Other/Concept-intros/testing/test_code_tabs.R
tutorialSeries:
urlTitle: test-code-tabs
---



## Load neonUtilities or neonutilities package {.tabset}

### R


    library(neonUtilities)

### Python


    import neonutilities as nu

## Get a citation {.tabset}

### R


    getCitation(dpID='DP1.20093.001', release='RELEASE-2024')

    ## [1] "@misc{https://doi.org/10.48443/fdfd-d514,\n  doi = {10.48443/FDFD-D514},\n  url = {https://data.neonscience.org/data-products/DP1.20093.001/RELEASE-2024},\n  author = {{National Ecological Observatory Network (NEON)}},\n  keywords = {chemistry, water quality, anions, cations, alkalinity, nutrients, surface water, nitrogen (N), carbon (C), total carbon (TC), acid neutralizing capacity (ANC), analytes, grab samples, chemical properties, swc, phosphorus (P)},\n  language = {en},\n  title = {Chemical properties of surface water (DP1.20093.001)},\n  publisher = {National Ecological Observatory Network (NEON)},\n  year = {2024},\n  copyright = {Creative Commons Zero v1.0 Universal}\n}\n"

### Python


    nu.get_citation(dpID='DP1.20093.001', release='RELEASE-2024')

    ## '@misc{https://doi.org/10.48443/fdfd-d514,\n  doi = {10.48443/FDFD-D514},\n  url = {https://data.neonscience.org/data-products/DP1.20093.001/RELEASE-2024},\n  author = {{National Ecological Observatory Network (NEON)}},\n  keywords = {chemistry, water quality, anions, cations, alkalinity, nutrients, surface water, nitrogen (N), carbon (C), total carbon (TC), acid neutralizing capacity (ANC), analytes, grab samples, chemical properties, swc, phosphorus (P)},\n  language = {en},\n  title = {Chemical properties of surface water (DP1.20093.001)},\n  publisher = {National Ecological Observatory Network (NEON)},\n  year = {2024},\n  copyright = {Creative Commons Zero v1.0 Universal}\n}\n'

