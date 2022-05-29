---
syncID: 
title: "Importing AOP Cloud Optimized Geotiffs into Google Earth Engine"
description: "Introductory tutorial on importing new AOP COG datasets into GEE."
dateCreated: 2022-05-29
authors: Bridget M. Hass
contributors: Tristan Goulden, John Musinsky
estimatedTime: 30 minutes
packagesLibraries: 
topics: lidar, hyperspectral, camera, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001, DP3.30010.001, DP3.30024.001
code1: 
tutorialSeries: aop-gee
urlTitle: importing-aop-cog-gee

---

The 

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
 * Import AOP data converted to cloud-optimized geotiffs as an Asset into Google Earth Engine (GEE)
 * Display the datasets in the GEE Interactive Map

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * A basic understanding of the GEE code editor and the GEE JavaScript API.
 * AOP data converted into the COG data format. Refer to the R tutorial to merge and convert data

## Additional Resources
For more information on importing assets into your personal workspace, refer to the Google Developers website documentation on asset management below:
 * <a href="https://developers.google.com/earth-engine/guides/asset_manager" target="_blank"> Earth-Engine Managing Assets </a>
 * <a href="https://developers.google.com/earth-engine/guides/image_upload" target="_blank"> Earth-Engine Image Upload </a>

</div>

## AOP GEE Data Availability & Access

If you are interested in working with AOP data that has not already been uploaded to the `projects/neon` folder (as outlined in the previous lesson, <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP data in GEE</a> Earth-Engine Managing Assets </a>), this tutorial will walk you through importing your own COG datasets. 

To convert AOP L3 data products from geotiff or h5 file formats to COG format, refer to the R tutorials ...
