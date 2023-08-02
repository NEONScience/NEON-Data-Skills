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

```javascript
// cloud masking function for Landsat 8 collection 2 is on GitHub under examples
// https://github.com/google/earthengine-api/blob/master/javascript/src/examples/CloudMasking/Landsat8SurfaceReflectance.js 
function maskL8sr(image) {

  var qaMask = image.select('QA_PIXEL').bitwiseAnd(parseInt('11111', 2)).eq(0);
  var saturationMask = image.select('QA_RADSAT').eq(0);

  // Apply the scaling factors to the appropriate bands.
  var opticalBands = image.select('SR_B.').multiply(0.0000275).add(-0.2);
  var thermalBands = image.select('ST_B.*').multiply(0.00341802).add(149.0);

  // Replace the original bands with the scaled ones and apply the masks.
  return image.addBands(opticalBands, null, true)
      .addBands(thermalBands, null, true)
      .updateMask(qaMask)
      .updateMask(saturationMask);
}

// Apply the cloud masking function
l8sr = l8sr.filterBounds(roi).map(maskL8sr)
```

Next we can do a trick to plot the two datasets on the same chart. This was modified from https://stackoverflow.com/questions/64776217/how-to-combine-time-series-datasets-with-different-timesteps-in-a-single-plot-on).

```javascript
// compute ndvi bands to add to each collection
var addL8Bands = function(image){
  var l8_ndvi = image.normalizedDifference(['SR_B5','SR_B4']).rename('l8_ndvi')
  var aop_ndvi = ee.Image().rename('aop_ndvi') 
  return image.addBands(l8_ndvi).addBands(aop_ndvi)
}

var addAOPBands = function(image){
  var aop_ndvi = image.normalizedDifference(['B097', 'B055']).rename('aop_ndvi')
  var l8_ndvi = ee.Image().rename('l8_ndvi') 
  return image.addBands(aop_ndvi).addBands(l8_ndvi)
}

l8sr = l8sr.map(addL8Bands)
sdr_col = sdr_col.map(addAOPBands)

print('NIS Images',sdr_col)

// merge the collections
var merged = l8sr.merge(sdr_col).select(['l8_ndvi', 'aop_ndvi'])
```

Lastly we can create the time-series chart. Most of this is just setting the chart style.

```javascript
// Set chart style properties.
// https://developers.google.com/earth-engine/guides/charts_style
var chartStyle = {
  title: 'NDVI at Chimney Tops Fire ROI - AOP + Landsat 8',
  hAxis: {
    title: 'Date',
    titleTextStyle: {italic: false, bold: true},
    gridlines: {color: 'FFFFFF'}
  },
  vAxis: {
    title: 'Mean NDVI',
    titleTextStyle: {italic: false, bold: true},
    gridlines: {color: 'FFFFFF'},
    format: 'short',
    baselineColor: 'FFFFFF'
  },
  series: {
    0: {lineWidth: 3, color: 'E37D05', pointSize: 7},
    1: {lineWidth: 3, color: '1D6B99'}
  },
  chartArea: {backgroundColor: 'EBEBEB'}
};

// Plot the merged (AOP + Landsat 8) Image Collection NDVI Time Series
var ndvi_timeseries = ui.Chart.image.series({
  imageCollection: merged,
  region: roi,
  reducer: ee.Reducer.mean(),
  scale: 30 // 	Scale to use with the reducer in meters
}).setOptions(chartStyle);

print(ndvi_timeseries)
```

This figure highlights some important points. While the Airborne Observation Platform seeks to collect data in Peak Greenness (when vegetation is most photosynthetically active), this is not always possible due to logistical or other constraints. In this case, one of the collections was in October, past peak-greenness and the leaves already started senescing in some areas. Generating a plot like this can help highlight the data in the context of the larger temporal trends. This brings us to the second point, which is that while AOP data has very high spectral (426 bands) and spatial (1m) resolution, the temporal resolution (annual or bi-annual) may not be sufficient for your research needs. This is where scaling with satellite data - either to look at a larger area, or more frequent sampling - can be very powerful! This is just a short example of one way to do this, but hopefully this demonstrates that GEE makes this sort of scalable analysis much simpler! 
