---
syncID: 
title: "Supervised Classification - Random Forest"
description: "Classifying species using AOP and field data at CLBJ"
dateCreated: 2022-08-02
authors: John Musinsky, Bridget Hass
contributors: Tristan Goulden, Lukas Straube
estimatedTime: 1 hour
packagesLibraries: 
topics: lidar, hyperspectral, canopy height, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001, DP3.30015.001
code1: 
tutorialSeries: aop-gee
urlTitle: aop-gee-random-forest-classification

---

Google Earth Engine has a number of built in machine learning tools that are designed to work with multi-band raster data. This simplifies more complex analyses like classification. In this example, we will show an example of using TOS (Terrestrial Observational Data) woody vegetation data, which includes information about the plant species in the terrestrial sampling plots, to train a random forest machine learning model, over a larger area, using the AOP reflectance and ecosystem structure (CHM) data. We will demonstrate this at the site <a href="https://www.neonscience.org/field-sites/clbj" target="_blank">CLBJ</a>) (Lyndon B. Johnson National Grassland in north-central Texas).

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
 * Integrate NEON airborne (AOP) and field (TOS) datasets
 * Run the Random Forest Classifier in Google Earth Engine
 * Understand pre-processing steps required for supervised learning classification

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * An understanding of the GEE code editor and the GEE JavaScript API.
 * Optionally, complete the previous GEE tutorials in this tutorial series: 
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP Data in GEE</a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-sdr-tutorial" target="_blank">Introduction to AOP Hyperspectral Data in GEE</a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-functions" target="_blank">Intro to GEE Functions</a>

## Additional Resources
The links below to the earth engine guides may assist you as you work through this lesson.
 * <a href="https://developers.google.com/earth-engine/guides/classification" target="_blank"> Earth Engine Classification Guide </a>
 * <a href="https://developers.google.com/earth-engine/guides/machine-learning" target="_blank"> Earth Engine Machine Learning Guide </a>

</div>

## Machine Learning Workflow

In this tutorial, we will take you through the following steps to classify species at the NEON site CLBJ. Note that these steps closely align with the more general supervised classification steps, described in the * <a href="https://developers.google.com/earth-engine/guides/classification" target="_blank"> Earth Engine Classification Guide </a>.

Workflow:
1. Specify the input data for display and use in analysis
2. Combine the AOP spectrometer reflectance data with the lidar-derived canopy height model (CHM) to create the predictor dataset
3. Create reference (training/test) data for plant species and land cover types based on NEON vegetation structure data
4. Fit a random forest model based on spectral/CHM composite to map the distribution of plant species at CLBJ
5. Evaluate the model accuracy 

Let's get started. In this first chunk of code, we'll specify the CLBJ location, read in the pre-processed woody vegetation data, as well as the TOS and Airshed boundaries.

```javascript
// Specify CLBJ location
var geo = ee.Geometry.Point([-97.5706464, 33.4045729])
// Load species/land cover samples feature collection to variable (originally a .csv file extracted from  NEON woody plant vegetation structure data product (DP1.10098.001))
var CLBJ_veg = ee.FeatureCollection('projects/neon/AOP_NEON_Plots/CLBJ_veg_2017_filtered')
// Load terrestrial observation system (TOS) boundary to a variable
var CLBJ_TOS = ee.FeatureCollection('projects/neon/AOP_TOS_Boundaries/D11_CLBJ_TOS_dissolve')
//Load tower airshed boundary to a variable
var CLBJ_Airshed = ee.FeatureCollection('projects/neon/Airsheds/CLBJ_90percent_footprint')
```

Next, display the Digital Terrain model (DTM) from the 2017 CLBJ collection, masking out the no-data values (-9999). 

```javascript
// Display DTM for CLBJ. First, filter the DEM image collection by year, DEM type and geographic location
var CLBJ_DTM2017 = ee.ImageCollection('projects/neon/DP3-30024-001_DEM')
  .filterDate('2017-01-01', '2017-12-31')
  .filterMetadata('Type', 'equals', 'DTM')
  .filterBounds(geo)
  .first();
// Then mask out the no-data values (-9999) in the image and add to the map using a histogram stretch based on lower and upper data values
var CLBJ_DTM2017mask = CLBJ_DTM2017.updateMask(CLBJ_DTM2017.gte(0.0000));
Map.addLayer(CLBJ_DTM2017mask, {min:285, max:1294}, 'CLBJ DTM 2017',0);
```

## Get Lesson Code

<a href="https://code.earthengine.google.com/318a84edf5bdc816d4eb05c9fc2092d4" target="_blank">AOP GEE Random Forest Classification</a>
