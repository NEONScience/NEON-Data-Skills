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

In this lesson, we'll continue to use the Great Smokey Mountains site as an example, this time creating a time series of the mean NDVI within the Chimney Tops 2 Fire perimeter, from 2016-2022. We will plot this along with the NDVI time-series derived from Landsat 8 data, and use this to fill in some more detailed temporal information.

AOP strives to collect every site during peak-greenness, when the predominant vegetation is most photosynthetically active. This is so that when comparing data from year to year, the differences are due to actual changes and not just due to the time of year. 

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
 * Compare AOP data to Landsat 8 data
 * Create an NDVI time series using two sets of data with different timestamps
 * Understand the trade-offs in different kinds of resolutions (spatial, spectral, and temporal)

## Requirements
 * An Earth Engine account. You can register for an Earth Engine account <a href="https://code.earthengine.google.com/register" target="_blank">here</a>
 * A basic understanding of the GEE code editor and the GEE JavaScript API.
 * Optionally, complete the previous GEE tutorials in this tutorial series: 
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Introduction to AOP Public Datasets in Google Earth Engine (GEE)/a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-gee-functions" target="_blank">Intro to GEE Functions</a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/aop-gee-wildfire" target="_blank">Wildfire Analysis Using AOP Data in GEE</a>

## Additional Resources
If this is your first time using GEE, we recommend starting on the Google Developers website, and working through some of the introductory tutorials. The links below are good places to start.
 * <a href="https://developers.google.com/earth-engine/guides/getstarted" target="_blank"> Get Started with Earth-Engine </a>
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


Let's create a function to pre-process the Landsat 8 data, mainly applying cloud masking. Don't worry too much about the details here, but the main thing to be aware of is that different sensors handle the QA bands in different way. Landsat (and other sensors) use something called "bitmasking" to store QA information, which is a space-efficient method for storing information. This cloud-masking function can be found on the earthengine-api GitHub examples <a href="https://github.com/google/earthengine-api/blob/master/javascript/src/examples/CloudMasking/Landsat8SurfaceReflectance.js" target="_blank">here</a>.

```javascript
// cloud masking function for Landsat 8 Collection 2 
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

Next we can plot the two datasets on the same chart. This code was modified from the Stack Overflow post: <a href="https://stackoverflow.com/questions/64776217/how-to-combine-time-series-datasets-with-different-timesteps-in-a-single-plot-on" target="_blank">how-to-combine-time-series-datasets-with-different-timesteps-in-a-single-plot-on</a>.

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

Lastly we can create and plot (print) the time-series chart. Most of this is just setting the chart style.

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

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1f_ndvi_timeseries/ndvi-time-series.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1f_ndvi_timeseries/ndvi-time-series.png" alt="NDVI Time Series Landsat 8 + AOP at GRSM 2016-2022"></a>
</figure>

"C:\Users\bhass\Documents\GitHubRepos\NEON-Data-Skills\graphics\aop-gee2023\1f_ndvi_timeseries\ndvi-time-series.png"

This figure highlights some important points. While the Airborne Observation Platform seeks to collect data in Peak Greenness (when vegetation is most photosynthetically active), this is not always possible due to logistical or other constraints. In this case, one of the AOP collections was in October, past peak-greenness when the leaves already started senescing in some areas. Generating a time-series plot like this can help highlight the data in the context of the larger temporal trends. This brings us to the second point: while AOP data has very high spectral (426 bands) and spatial (1m) resolution, the temporal resolution (annual or bi-annual) may not fully suffice for your research needs. This is where scaling with satellite data - either to expand your analysis to a larger area, or to achieve a more comprehensive temporal understanding - can be very powerful! This tutorial demonstrates a simple example of scaling up the temporal resolution, but demonstrates how GEE makes this sort of scalable analysis much simpler! 
