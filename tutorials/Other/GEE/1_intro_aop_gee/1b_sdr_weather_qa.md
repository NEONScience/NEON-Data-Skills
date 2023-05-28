---
syncID: 
title: "SDR Pre-processing in GEE: masking out bad weather data"
description: "Learn how find and use weather quality information from the Reflectance QA band in GEE"
dateCreated: 2022-05-27
authors: Bridget M. Hass, John Musinsky
contributors: Tristan Goulden, Lukas Straube
estimatedTime: 30 minutes
packagesLibraries: 
topics: hyperspectral, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001
code1: 
tutorialSeries: 
urlTitle: aop-sdr-weather-qa-gee

---

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
- Use the weather QA band to pull out good weather data
- Find and understand the additional QA bands included in the Reflectance data set

## Requirements

- Complete the following introductory AOP GEE tutorials:
    - <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-image-collections" target="_blank">Introduction to AOP Public Datasets in Google Earth Engine (GEE)</a>
- An understanding of hyperspectral data and AOP spectral data products. If this is your first time working with AOP hyperspectral data, we encourage you to start with the [Intro to Working with Hyperspectral Remote Sensing Data](https://www.neonscience.org/resources/learning-hub/tutorials/hsi-hdf5-r) tutorial. You do not need to follow along with the code in those lessons, but at least read through to gain a better understanding NEON's spectral data products.

</div>

## Read in the AOP SDR 2019 Dataset at SRER

We will start at our ending point of the last tutorial. For this exercise we will only read data from 2021:

```javascript
// Filter image collection by date and site to pull out a single image
var soapSDR = ee.ImageCollection("projects/neon-prod-earthengine/assets/DP3-30006-001")
  .filterDate('2019-01-01', '2019-12-31')
  .filterMetadata('NEON_SITE', 'equals', 'SOAP')
  .first();
```

## Read in the `Weather_Quality_Indicator` Band

From the previous lesson, recall that the SDR images include 442 bands. Bands 0-425 are the data bands, which store the spectral reflectance values for each wavelength recorded by the NEON Imaging Spectrometer (NIS). The remaining bands (426-441) contain metadata and QA information that are important for understanding and properly interpreting the hyperspectral data. The weather information, called `Weather_Quality_Indicator` is one of the most important pieces of QA information that is collected about the NIS data, as it has a direct impact on the reflectance values. Since reflectance data is collected from a passive energy source (the sun), data that was collected in cloudy sky conditions is not directly comparable to data collected on a clear-sky day, as the cloud obscure the incoming light source. AOP aims to collect data only in optimal (<10% cloud-cover) weather conditions, but cannot always do so due to logistical constraints. The flight operators record the weather conditions during each flight, and this information is passed through to the final data product at the level of the flight line (as cloud conditions can change throughout the day). The figure below shows some examples of what the cloud conditions might look like at different flights collected in the three different weather classes (green, yellow, and red).

```javascript
// Extract a single band Weather Quality QA layer
var soapWeather = soapSDR.select(['Weather_Quality_Indicator']);

// Select only the clear weather data (<10% cloud cover)
var soapClearWeather = soapWeather.eq(1); // 1 = 0-10% cloud cover

// Mask out all cloudy pixels from the SDR image
var soapSDR_clear = soapSDR.updateMask(soapClearWeather);
```

## Create the wavelengths variable

In the last tutorial, we ended by viewing a bar chart of the reflectance values v. band #, but we couldn't see the wavelengths corresponding to those bands. Here we set a wavelengths variable (**var**) that we will apply to generate a spectral plot (wavelengths v. reflectance). To add this wavelength information, we will use the [`ee.List.sequence`](https://developers.google.com/earth-engine/apidocs/ee-list-sequence) function, which is used as follows: `ee.List.sequence(start, end, step, count)` to "generate a sequence of numbers from start to end (inclusive) in increments of step, or in count equally-spaced increments."

```javascript
// Set wavelength variable for spectral plot
var wavelengths = ee.List.sequence(381, 2510, 5).getInfo()
var bands_no =  ee.List.sequence(1, 426).getInfo() 
```

## [Earth Engine User Interface](https://developers.google.com/earth-engine/guides/ui)

[ui.Panel](https://developers.google.com/earth-engine/apidocs/ui-panel)

```javascript
// Create a panel to hold the spectral signature plot
var panel = ui.Panel();
panel.style().set({width: '600px',height: '300px',position: 'top-left'});
Map.add(panel);
Map.style().set('cursor', 'crosshair');
```

## [Map.onClick](https://developers.google.com/earth-engine/apidocs/ui-map-onclick)

```javascript
// Create a function to draw a chart when a user clicks on the map.
Map.onClick(function(coords) {
  panel.clear();
  var point = ee.Geometry.Point(coords.lon, coords.lat);
  var chart = ui.Chart.image.regions(SRER_SDR2021, point, null, 1, 'λ (nm)', wavelengths);
    chart.setOptions({title: 'SRER 2021 Reflectance',
                      hAxis: {title: 'Wavelength (nm)', 
                      vAxis: {title: 'Reflectance'},
                      gridlines: { count: 5 }}
                              });
    // Create and update the location label 
  var location = 'Longitude: ' + coords.lon.toFixed(2) + ' ' +
                 'Latitude: ' + coords.lat.toFixed(2);
  panel.widgets().set(1, ui.Label(location));
  panel.add(chart);
});
```

Finally, we'll add the SRER data layer and center on that layer. Here we use the `Map.centerObject` function to center on our SRER_SDR2021 object.

```javascript
// Add the 2021 SRER SDR data as a layer to the Map:
Map.addLayer(SRER_SDR2021mask, visParams, 'SRER 2021');

Map.centerObject(SRER_SDR2021,11)
```

When you run this code, linked [here](https://code.earthengine.google.com/33d1d2b66c81c705c0b48e5d158abc9e), you will see the SRER SDR layer show up in the Map panel, along with a blank figure outline. When you click anywhere in this image, the figure will be populated with the spectral signature of the pixel you clicked on.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2b_plot_spectra/srer_spectral_plot.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2b_plot_spectra/srer_spectral_plot.png" alt="SRER Inspector"></a>
</figure>
