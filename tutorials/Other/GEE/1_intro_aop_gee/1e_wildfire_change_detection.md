---
syncID: 
title: "Wildfire Change Detection Using AOP SDR and CHM Data in GEE"
description: ""
dateCreated: 2023-07-29
authors: Bridget M. Hass, John Musinsky
contributors: Tristan Goulden, Lukas Straube
estimatedTime: 45 minutes
packagesLibraries: 
topics: lidar, hyperspectral, canopy height, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001, DP3.30015.001
code1: 
tutorialSeries: aop-gee2023
urlTitle: aop-gee-wildfire

---

GEE is a great place to conduct exploratory analysis to better understand the datasets you are working with. In this lesson, we will show how to pull in AOP Surface Directional Reflectance (SDR) data, as well as the Ecosystem Structure (Canopy Height Model - CHM) data to look at interannual differences at the NEON site <a href="https://www.neonscience.org/field-sites/grsm" target="_blank">Great Smokey Mountains (GRSM)</a>, where the <a href="https://www.nps.gov/grsm/learn/chimney-tops-2-fire.htm" target="_blank">Chimney Tops 2 Fire</a> broke out in late November 2016. NEON data over the GRSM site collected in June 2016 and October 2017 captures most of the burned area and presents a unique opportunity to study wildfire effects on the ecosystem and analysis of post-wildfire vegetation recovery. In this lesson, we will calculate the differenced Normalized Burn Ratio (dNBR) between 2017 and 2016, and also create a CHM difference raster to highlight vegetation structure differences in the burned area. We will also pull in Landsat satellite data and create a time-series of the NBR within the burn perimeter to look at annual differences.

Using remote sensing data to better understand wildfire impacts is an active area of research. In April 2023, Park and Sim published an Open Access paper titled <a href="https://www.frontiersin.org/articles/10.3389/frsen.2023.1096000/full" target="_blank">Characterizing spatial burn severity patterns of 2016 Chimney Tops 2 fire using multi-temporal Landsat and NEON LiDAR data"</a>. We encourage you to read this paper for an example of wildfire research using AOP remote sensing and satellite data. This lesson provides an introduction to conducting this sort of analysis in Google Earth Engine.

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
 * Write GEE functions to display map images of AOP SDR, NDVI, and CHM data.
 * Create chart images (histogram and line graphs) to summarize data over an area.
 * Understand how acquisition parameters may affect the interpretation of data.
 * Understand how weather conditions during acquisition may affect reflectance data quality.

You will gain familiarity with:
 * User-defined GEE functions
 * The GEE charting functions (<a href="https://developers.google.com/earth-engine/guides/charts_image" target="_blank">ui.Chart.image</a>)

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * A basic understanding of the GEE code editor and the GEE JavaScript API.
 * Optionally, complete the previous GEE tutorials in this tutorial series: 
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP Data in GEE</a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-sdr-tutorial" target="_blank">Introduction to AOP Hyperspectral Data in GEE</a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-functions" target="_blank">Intro to GEE Functions</a>

## Additional Resources
If this is your first time using GEE, we recommend starting on the Google Developers website, and working through some of the introductory tutorials. The links below are good places to start.
 * <a href="https://developers.google.com/earth-engine/guides/getstarted" target="_blank"> Get Started with Earth-Engine  </a>
 * <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank"> GEE JavaScript Tutorial </a>
 * <a href="https://developers.google.com/earth-engine/guides/charts_image_collection" target="_blank"> GEE Charts Image Collection </a>
 * <a href="https://developers.google.com/earth-engine/guides/reducers_intro" target="_blank"> GEE Reducers </a>

</div>

## Functions to Read in SDR and CHM Image Collections

Let's get started. The code in the beginning of this lesson should look familiar from the previous tutorials in this series. In this first chunk of code, we will the center location of GRSM, and read in the fire perimeter as a FeatureCollection.

```javascript
// Specify center location and flight box for GRSM (https://www.neonscience.org/field-sites/grsm)
var site_center = ee.Geometry.Point([-83.5, 35.7])

// Read in the Chimney Tops fire perimeter shapefile
var ct_fire_boundary = ee.FeatureCollection('projects/neon-sandbox-dataflow-ee/assets/chimney_tops_fire')
```

Next, we'll read in the SDR image collection, and then write a function to mask out the cloudy weather data, and use the `map` feature to apply this to our SDR collection at GRSM. 

```javascript
// Read in the SDR Image Collection at GRSM
var grsm_sdr_col = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30006-001')
  .filterBounds(site_center)
  
// Function to mask out poor-weather data, keeping only the <10% cloud cover weather data
function clearSDR(image) { 
  // create a single band Weather Quality QA layer 
  var weather_qa = image.select(['Weather_Quality_Indicator']);
  // WEATHER QUALITY INDICATOR = 1 is < 10% CLOUD COVER
  var clear_qa = weather_qa.eq(1);
  // mask out all cloudy pixels from the SDR image
  return image.updateMask(clear_qa);
}

// Use map to apply the clearSDR function to the SDR collection and return a clear-weather subset of the data
var grsm_sdr_cloudfree = grsm_sdr_col.map(clearSDR)
```

Next let's write a function to display the NIS images from 2016, 2017, and 2021 in GEE. For more details on how this function works, you can refer to 
the tutorial <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-functions" target="_blank">Functions in Google Earth Engine (GEE)</a>.

```javascript
// Function to display individual (yearly) SDR Images
function addSDRImage(image) { 
  var image_id = ee.Image(image.id); // get the system:id and convert to string
  var sys_id = ee.String(image_id.get("system:id")).getInfo();  // get the system:id - this is an object on the server
  var filename = sys_id.slice(52,100); // extract the fileName (NEON domain + site code + product code + year)
  var image_rgb = image_id.select(['B053', 'B035', 'B019']);  // select only RGB bands for display
  
  Map.addLayer(image_rgb, {min:220, max:1600}, filename, 1)   // add RGB composite to the map
}

// call the addNISimages function to add SDR layers to map
grsm_sdr_col.evaluate(function(grsm_sdr_col) {
  grsm_sdr_col.features.map(addSDRImage);
})
```

Next we can create a similar function for reading in the CHM dataset over all the years. The main differences between this function and the previous one are that 1) it is set to display a single band image, and 2) instead of hard-coding in the minimum and maximum values to display, we dynamically determine them from the data itself, so it will scale appropriately. 

```javascript
// Read in the CHM Image collection at GRSM
var grsm_chm_col =  ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30015-001')
  .filterBounds(site_center)

// Function to display Single Band Images setting display range to linear 2%
function addSingleBandImage(image) { // display each image in collection
  var image_id = ee.Image(image.id); // get the system:id and convert to string
  var sys_id = ee.String(image_id.get("system:id")).getInfo(); 
  var filename = sys_id.slice(52,100); // extract the fileName (NEON domain + site code + product code + year)

  // Dynamically determine the range of data to display
  // Sets color scale to show all but lowest/highest 2% of data
  var pct_clip = image_id.reduceRegion({
    reducer: ee.Reducer.percentile([2, 98]),
    scale: 10,
    maxPixels: 3e7});

  var keys = pct_clip.keys();
  var pct02 = ee.Number(pct_clip.get(keys.get(0))).round().getInfo()
  var pct98 = ee.Number(pct_clip.get(keys.get(1))).round().getInfo()
    
  Map.addLayer(image_id, {min:pct02, max:pct98, palette: chm_palette}, filename, 0)
}

// Call the addSingleBandImage function to add CHM layers to map 
grsm_chm_col.evaluate(function(grsm_chm_col) {
  grsm_chm_col.features.map(addSingleBandImage);
})

// Center the map on GRSM and set zoom level to 12
Map.setCenter(-83.5, 35.6, 12);
```

Now that you've read in these two datasets (SDR and CHM) over all the years of available data, we encourage you to explore the different layers and see what you notice! 

## Creating CHM Difference Layers

Next let's create a new raster layer of the difference between the CHMs from 2 different years. 

```javascript

```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/chm_diff_map_2021_2018.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/chm_diff_map_2021_2018.png" alt="CHM difference map, 2021-2018"></a>
</figure>

You can see some broad differences, but there also appear to be some noisy artifacts. We can smooth out some of this noise by using a spatial filter.

```
// Smooth out the difference raster (filter out high-frequency patterns)
// Define a boxcar or low-pass kernel.
var boxcar = ee.Kernel.square({
  radius: 1.5, units: 'pixels', normalize: true
});

// Smooth the image by convolving with the boxcar kernel.
var smooth = CHMdiff_2021_2018.convolve(boxcar);
Map.addLayer(smooth, {min: -1, max: 1, palette: ['#FF0000','#FFFFFF','#008000']}, 'CHM diff, smoothed');
```
<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/chm_diff_map_2021_2018_smoothed.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/chm_diff_map_2021_2018_smoothed.PNG" alt="CHM difference map, 2021-2018 smoothed"></a>
</figure>

## CHM Difference Histograms

Next let's plot histograms of the CHM differences, between 2021-2018 as well as between 2021-2019 and 2019-2018. For this example, we'll just look at the values over a small area of the site. Looking at these 3 sets of years, we will see some of the artifacts related to the lidar sensor used (Riegl Q780 or Optech Gemini). If you didn't know about the differences between the sensors, it would look like the canopy was growing and shrinking from year to year.

Before running this chunk of code, you'll need to create a polygon of a region of interest. For this example, I selected a region in the center of the map, shown below, although you can select any region within the site. To create the polygon, select the rectangle out of the shapes in the upper left corner of the map window (hovering over it should say "Draw a rectangle"). Then drag the cursor over the area you wish to cover.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/geometry_map.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/geometry_map.png" alt="Geometry map"></a>
</figure>

When you load in this geometry, you should see the `geometry` variable imported at the top of the code editor window, under Imports. It should look something like this:

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/geometry_import.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/geometry_import.PNG" alt="Geometry imported variable"></a>
</figure>

Once you have this geometry polygon variable set, you can run the following code to generate histograms of the CHM differences over this area.


```javascript

// read in CHMs from 2019 and 2017
var SRER_CHM2019 = ee.ImageCollection('projects/neon/DP3-30024-001_DEM')
  .filterDate('2019-01-01', '2019-12-31')
  .filterBounds(mySite).first();

var SRER_CHM2017 = ee.ImageCollection('projects/neon/DP3-30024-001_DEM')
  .filterDate('2017-01-01', '2017-12-31')
  .filterBounds(mySite).first();

// calculate the CHM difference histograms (2021-2019 & 2019-2018)
var CHMdiff_2021_2019 = SRER_CHM2021.subtract(SRER_CHM2019);
var CHMdiff_2019_2018 = SRER_CHM2019.subtract(SRER_CHM2018);

// Define the histogram charts for each CHM difference image, print to the console.
var hist1 =
    ui.Chart.image.histogram({image: CHMdiff_2021_2019, region: geometry, scale: 50})
        .setOptions({title: 'CHM Difference Histogram, 2021-2019',
                    hAxis: {title: 'CHM Difference (m)',titleTextStyle: {italic: false, bold: true},},
                    vAxis: {title: 'Count', titleTextStyle: {italic: false, bold: true}},});
print(hist1);

var hist2 =
    ui.Chart.image.histogram({image: CHMdiff_2019_2018, region: geometry, scale: 50})
        .setOptions({title: 'CHM Difference Histogram, 2019-2018',
                    hAxis: {title: 'CHM Difference (m)',titleTextStyle: {italic: false, bold: true},},
                    vAxis: {title: 'Count', titleTextStyle: {italic: false, bold: true}},});
print(hist2);

var hist3 =
    ui.Chart.image.histogram({image: CHMdiff_2021_2018, region: geometry, scale: 50})
        .setOptions({title: 'CHM Difference Histogram, 2021-2018',
                    hAxis: {title: 'CHM Difference (m)',titleTextStyle: {italic: false, bold: true},},
                    vAxis: {title: 'Count', titleTextStyle: {italic: false, bold: true}},});
print(hist3);
```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/chm_diff_hist_2021_2019.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/chm_diff_hist_2021_2019.png" alt="CHM difference histogram 2021-2019"></a>
</figure>

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/chm_diff_hist_2019_2018.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/chm_diff_hist_2019_2018.png" alt="CHM difference histogram 2019-2018"></a>
</figure>

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/chm_diff_hist_2021_2018.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/chm_diff_hist_2021_2018.png" alt="CHM difference histogram 2021-2018"></a>
</figure>

Let's take a minute to understand what's going on here. In each case, we subtracted the earlier year from the later year. So from 2019 to 2021, it looks like the vegetation grew on average by ~0.6m, but from 2018 to 2019 it shrunk by the same amount. This is because in 2021 there was a lower vertical cutoff, so shrubs of at least 0.67m were resolved, where before anything below 2m was obscured. These low shrubs are likely the dominant source of the change we're seeing. We can see the same pattern, but in reverse between 2018 and 2019. The difference histogram from 2021 to 2018 more accurately represents the change, which is centered around 0, and the map we displayed shows local changes in certain areas, related to actual vegetation growth and ecological drivers. Note that 2021 was a particularly wet year, and AOP's flight was in optimal peak greenness, as you can see when comparing the SDR imagery to earlier years.

## NDVI Time Series

Last but not least, we can take a quick look at NDVI changes over the four years of data. A quick way to look at the interannual changes are to make a line plot, which we'll do shortly. First let's take a step back and see the weather conditions during the collections. For every mission, the AOP flight operators assess the cloud conditions and note whether the cloud clover is <10% (green), 10-50% (yellow), or >50% (red). This information gets passed through to the reflectance hdf5 data, and is also available in the summary metadata documents, delivered with all the spectrometer data products. The weather conditions have direct implications for data quality, and while we strive to collect data in "green" weather conditions, it is not always possible, so the user must take this into consideration when working with the data.

The figure below shows the weather conditions at SRER for each of the 4 collections. In 2017 and 2021, the full site was collected in <10% cloud conditions, while in 2018 and 2019 there were mixed weather conditions. However, for all four years, the center of the site was collected in optimal cloud conditions.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/srer_weather_conditions_2017-2021.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/srer_weather_conditions_2017-2021.PNG" alt="SRER weather conditions 2017-2021"></a>
</figure>

With this in mind, let's use the same geometry we used before, centered in the middle of the plot, to look at the mean NDVI over the four years in a small part of the site. Here's the GEE code for doing this:

```javascript
// calculate NDVI for the geometry
var ndvi = NISimages.map(function(image) {
    var ndviClip = image.clip(geometry)
    return ndviClip.addBands(ndviClip.normalizedDifference(["band097", "band055"]).rename('NDVI'))
});

// Create a time series chart, with image, geometry & median reducer
var plotNDVI = ui.Chart.image.seriesByRegion(ndvi, geometry, ee.Reducer.median(), 
              'NDVI', 100, 'system:time_start') // band, scale, x-axis property
              .setChartType('LineChart').setOptions({
                title: 'Median NDVI for Selected Geometry',
                hAxis: {title: 'Date'},
                vAxis: {title: 'NDVI'},
                legend: {position: "none"},
                lineWidth: 1,
                pointSize: 3
});

// Display the chart
print(plotNDVI);
```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/ndvi_time_series.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/3a_change_detection/ndvi_time_series.PNG" alt="NDVI time series"></a>
</figure>

We can see how much NDVI has increased in 2021 relative to the earlier years, which makes sense when we look at the reflectance RGB composites - it is much greener in 2021! While this line plot doesn't show us a lot of information now, as the AOP data set builds up in years to come, this may become a more interesting figure. 

On your own, we encourage you to dig into the code from this tutorial and modify according to your scientific interests. Think of some questions you have about this dataset, and modify these functions or try writing your own function to answer your question. For example, try out a different reducer, repeat the plots for different areas of the site, and see if there are any other datasets that you could bring in to help you with your analysis. You can also pull in satellite data and see how the NEON data compares. This is just the starting point!

## Get Lesson Code

<a href="https://code.earthengine.google.com/8a8ee1c359d14c6c2413b6483a2b1615" target="_blank">AOP GEE Internannual Change Exploratory Analysis</a>


### Footnotes

- To download the metadata documentation without downloading all the data products, you can go through the process of downloading the data product, and when you get to the files, select only the ".pdf" extension. The Algorithm Theoretical Basis Documents (ATBDs), which can be downloaded either from the data product information page or from the data portal, also discuss the uncertainty and important information pertaining to the data.
- The vertical resolution is related to the outgoing pulse width of the lidar system. Optech Gemini has a 10ns outgoing pulse, while the Riegl Q780 and Optech Galaxy Prime sensors have a 3ns outgoing pulse width. At the nominal flying altitude of 1000m AGL, 10ns translates to a range resolution of ~2m, while 3ns corresponds to 2/3m. 
- From 2021 onward, all NEON lidar collections have the improved vertical resolution of .67m, as NEON started operating the Optech Galaxy Prime, which replaced one of the Optech Gemini sensors. This has a 3ns outgoing pulse width, matching the Riegl Q780 system.
