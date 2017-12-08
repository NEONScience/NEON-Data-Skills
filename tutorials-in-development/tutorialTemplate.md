---
syncID:
title: "NEON Data Skills Tutorial Template"
description: "This is a template page to be copied as needed. Do not edit this template directly or your PR will be rejected."
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

This template should be used to start new tutorials. If your tutorial is in R 
or Jupyter Notebooks, or another format that will be converted to markdown. 
Please include the header above but create the tutorial in the appropriate 
application. 

To create a new tutorial, copy this template into the program of your choice. Save
the new tutorial in the /tutorials-in-development/ directory of your fork of the 
NEON-Data-Skills GitHub repo. When you are ready for review of your tutorial, 
complete a Pull Request to the NEONScience/NEON-Data-Skills repository. If you
have questions on using a forking workflow in GitHub, please see there series: 
http://www.neonscience.org/version-control-git-series


If you are creating a series, workshop, or teaching module the "cover page" content
for this is created in a Drupal environment and must be created by NEON staff. 
Please create your content in a .md or Word-type document and email to 
neondataskills -at- battelleEcology dot org.  

***
## Header at top of all tutorial pages

This header must be at the top of each tutorial so that all associated metadata 
will appear correctly. (spaces at beginning only added so as not to render)

    ---
    syncID: sync-id-from-list - this will be added by NEON staff, you do not need to include
    title: "Descriptive Title In Title Case"
    description: "Descriptive text about the tutorial here. Must be all on one line no matter how long."
    dateCreated: 2015-08-01
    authors: Megan A. Jones, Each Author Separated by Commas, 
    contributors: Jane Doe, Also Seperate, By Commas
    estimatedTime: 1.5 hrs
    packagesLibraries: raster, rhdf5, rgdal
	- see list in processing_code/_data/packagesLibraries.yml for the correct list. If you would like to add a term please include in your PR message. 
    topics: data-analysis, data-visualization, HDF5, spatial-data-gis 
	- see list in processing_code/_data/tags.yml for the correct list. If you would like to add a term please include in your PR message. 
    languagesTool: R, python
	- see list in processing_code/_data/languagesTool.yml for the correct list. If you would like to add a term please include in your PR message. 
    dataProduct: DP1.0001.01
	- all NEON data products used in the tutorial written in the above format. (no .yml for this list). 
    code1: code/R/neon-utitlites/
	- the relative file path (code/...) of any code related to the tutorials so that it can be downloaded at the end of the tutorial
    tutorialSeries: 
	- if the tutorial is part of a series, this metadata isn't used by the Drupal site but is useful for tutorial management
    urlTitle: styles-css 
	- a short url that is descriptive but not long
    ---


***

Our tutorials are built with Markdown with a few exceptions (see links). For a simple markdown overview, check out 
<a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank">this cheatsheet</a>.

For specifics on how to include different element/styles in your tutorial, please
see the NDS-style-guide.md in the /tutorials/ directory of this repo for details. 
In particular, please not that we html with target="_blank" for all links. We 
do not use Markdown formatting for any links. 