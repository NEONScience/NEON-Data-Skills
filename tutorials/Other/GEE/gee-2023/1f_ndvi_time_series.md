---
syncID: 
title: "NDVI Time Series using AOP Reflectance and Landsat 8 Data in GEE"
description: ""
dateCreated: 2023-08-01
authors: Bridget M. Hass, John Musinsky
contributors: Tristan Goulden
estimatedTime: 45 minutes
packagesLibraries: 
topics: hyperspectral, remote-sensing, ndvi
languageTool: GEE
dataProduct: DP3.30006.001
code1: 
tutorialSeries: aop-gee2023
urlTitle: aop-gee-ndvi-timeseries

---

In this lesson, we'll continue to use the Great Smokey Mountains site, this time creating a time series of the NDVI

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
 * Create an NDVI time series
 * Compare AOP data to Landsat 8 data

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * A basic understanding of the GEE code editor and the GEE JavaScript API.
 * Optionally, complete the previous GEE tutorials in this tutorial series: 
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Introduction to AOP Public Datasets in Google Earth Engine (GEE)/a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-gee-functions" target="_blank">Intro to GEE Functions</a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/aop-gee-wildfire" target="_blank">Wildfire Analysis Using AOP Data in GEE</a>

## Additional Resources
If this is your first time using GEE, we recommend starting on the Google Developers website, and working through some of the introductory tutorials. The links below are good places to start.
 * <a href="https://developers.google.com/earth-engine/guides/getstarted" target="_blank"> Get Started with Earth-Engine  </a>
 * <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank"> GEE JavaScript Tutorial </a>
 * <a href="https://developers.google.com/earth-engine/guides/charts_image_collection" target="_blank"> GEE Charts Image Collection </a>
 * <a href="https://developers.google.com/earth-engine/guides/reducers_intro" target="_blank"> GEE Reducers </a>

</div>

## Read in AOP and Landsat 8 Surface Reflectance Image Collections

```javascript
// Specify center location and for GRSM
var site_center = ee.Geometry.Point([-83.5, 35.7]); 

// Create region of interest (roi)
var roi = ee.FeatureCollection('projects/neon-sandbox-dataflow-ee/assets/chimney_tops_fire')

// Read in the SDR Image Collection
var sdr_col = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30006-001')
  .filterBounds(site_center);

// Read in Landsat 8 Surface Reflectance Image Collection
var l8sr = ee.ImageCollection('LANDSAT/LC08/C02/T1_L2')
                .filterBounds(roi)
                .filter(ee.Filter.calendarRange(2016, 2022, 'year'));
```
