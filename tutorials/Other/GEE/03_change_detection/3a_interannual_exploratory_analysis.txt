---
syncID: 
title: "Exploratory Analysis of AOP Interannual Differences in GEE"
description: "Exploring interannual differences using AOP lidar and hyperspectral data"
dateCreated: 2022-08-01
authors: Bridget M. Hass, John Musinsky
contributors: Tristan Goulden, Lukas Straube
estimatedTime: 45 minutes
packagesLibraries: 
topics: lidar, hyperspectral, canopy height, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001, DP3.30015.001
code1: 
tutorialSeries: aop-gee
urlTitle: aop-gee-exploratory-change-analysis

---

GEE is a great place to conduct exploratory analysis to better understand the datasets you are working with. In this lesson, we will 
show how to pull in AOP Surface Directional Reflectance (SDR) datasets, as well as the Ecosystem Structure data (also called Canopy Height Model, or CHM)
to look at interannual differences at the site SRER. We will discuss some of the acquisition parameters and other factors that affect data interperatation and data quality.

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
 * Write functions to display map images of SDR and CHM data
 * Understand how processing parameters may affect interpretation of data.
 * Understand how weather conditions may affect reflectance data.
 * Create chart images (histogram and line charts) to summarize data over an area.

You will gain familiarity with:
 * User-defined functions
 * The GEE charting functions `ui.Chart.image`

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * A basic understanding of the GEE code editor and the GEE JavaScript API.
 * We recommend you 
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP Data in GEE</a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-sdr-tutorial" target="_blank">Introduction to AOP Hyperspectral Data in GEE</a>
	* <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-functions" target="_blank">Intro to GEE Functions</a>

## Additional Resources
If this is your first time using GEE, we recommend starting on the Google Developers website, and working through some of the introductory tutorials. The links below are good places to start.
 * <a href="https://developers.google.com/earth-engine/guides/getstarted" target="_blank"> Get Started with Earth-Engine  </a>
 * <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank"> GEE JavaScript Tutorial </a>

</div>

## Functions to Read in SDR and CHM Image Collections

Let's get started. In this first chunk of code, we are setting the center location of SRER, reading in the SDR image collection, and then 
creating a function to display the NIS image in GEE. Optionally, we've included lines of code that also calculate and display NDVI from 
the SDR data, so you can uncomment this and run on your own, if you wish. For more details on how this function works, you can refer to 
the tutorial <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-functions" target="_blank">Intro to GEE Functions</a>.

```javascript
// Specify center location of SRER
var mySite = ee.Geometry.Point([-110.83549, 31.91068])

// Read in the SDR Image Collection
var NISimages = ee.ImageCollection('projects/neon/DP3-30006-001_SDR')
  .filterBounds(mySite)

// Function to display NIS Image + NDVI
function addNISImage(image) { 
  var imageId = ee.Image(image.id); // get the system:id and convert to string
  var sysID = ee.String(imageId.get("system:id")).getInfo();  // get the system:id - this is an object on the server
  var fileName = sysID.slice(46,100); // extract the fileName (NEON domain + site code + product code + year)
  var imageMasked = imageId.updateMask(imageId.gte(0.0000)) // mask out no-data values
  var imageRGB = imageMasked.select(['band053', 'band035', 'band019']);  // select only RGB bands for display
  
  Map.addLayer(imageRGB, {min:2, max:20}, fileName, 0)   // add RGB composite to the map
  
  // uncomment the lines below to calculate NDVI from the SDR and display NDVI
  // var nisNDVI =imageMasked.normalizedDifference(["band097", "band055"]).rename("ndvi") // band097 = NIR , band055 = red
  // var ndviViz= {min:0.05, max:.95,palette:['brown','white','green']}
  
  // Map.addLayer(nisNDVI, ndviViz, "NDVI "+fileName,0) // optionally add NDVI to the map
}

// call the addNISimages function to add SDR and NDVI layers to map
NISimages.evaluate(function(NISimages) {
  NISimages.features.map(addNISImage);
})
```