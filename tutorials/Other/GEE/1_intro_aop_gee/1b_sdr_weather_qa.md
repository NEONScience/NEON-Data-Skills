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

Since reflectance data is collected from a passive energy source (the sun), data that was collected in cloudy sky conditions is not directly comparable to data collected on a clear-sky day, as overhead clouds can obscure the incoming light source. AOP aims to collect data only in optimal (<10% cloud-cover) weather conditions, but cannot always do so due to logistical constraints. The flight operators record the weather conditions during each flight, and this information is passed through to the final data product at the level of the flight line (as cloud conditions can change throughout the day). Cloud conditions are reported as green (<10% cloud cover), yellow (10-50% cloud cover), or red (>50% cloud cover). The figure below shows some examples of what the cloud conditions look like at different flights collected in the three different weather classes (green, yellow, and red).

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/flight_cloud_photos.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/flight_cloud_photos.png" alt="In-flight cloud photos"></a>
</figure>

Note that there is an important distinction between airborne and satellite reflectance data. Satellite data is collected in all weather conditions, and the clouds are below the sensor, so algorithms can be generated to filter out cloudy pixels. With aerial data, we have more control over when the data are collected, to a point, but there would never be clouds below the sensor (largely because of the constriants by the active Lidar sensor). However, clouds may be present overhead, if we collect in sub-optimal conditions, often because we are running out of time in a Domain. There is no direct record of this in the actual datasets, 

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

From the previous lesson, recall that the SDR images include 442 bands. Bands 0-425 are the data bands, which store the spectral reflectance values for each wavelength recorded by the NEON Imaging Spectrometer (NIS). The remaining bands (426-441) contain metadata and QA information that are important for understanding and properly interpreting the hyperspectral data. The weather information, called `Weather_Quality_Indicator` is one of the most important pieces of QA information that is collected about the NIS data, as it has a direct impact on the reflectance values. 

These next lines of code pull out the `Weather_Quality_Indicator` band, select the "green" weather data from that band, and apply a mask to keep only the clear-weather data, which is saved to the variable `soapSDR_clear`.

```javascript
// Extract a single band Weather Quality QA layer
var soapWeather = soapSDR.select(['Weather_Quality_Indicator']);

// Select only the clear weather data (<10% cloud cover)
var soapClearWeather = soapWeather.eq(1); // 1 = 0-10% cloud cover

// Mask out all cloudy pixels from the SDR image
var soapSDR_clear = soapSDR.updateMask(soapClearWeather);
```

## Plot the weather quality band data

For reference, we can plot the weather band data, using AOP's stop-light (red/yellow/green) color schmeme:

```javascript

// center the map at the lat / lon of the site, set zoom to 12
Map.setCenter(-119.25, 37.06, 11);

// Define a palette for the weather - to match NEON AOP's weather color conventions
var gyrPalette = [
  '00ff00', // green (<10% cloud cover)
  'ffff00', // yellow (10-50% cloud cover)
  'ff0000' // red (>50% cloud cover)
];

// Display the weather band (cloud conditions) with the green-yellow-red palette
Map.addLayer(soapWeather,
             {min: 1, max: 3, palette: gyrPalette, opacity: 0.3},
             'SOAP 2019 Cloud Cover Map');
```

## Plot the clear-weather reflectance data
Finally, we can plot a true-color image of only the clear-weather data, from `soapSDR_clear` that we created earlier:

```javascript
// Create a 3-band cloud-free image 
var soapSDR_RGB = soapSDR_clear.select(['B053', 'B035', 'B019']);

// Display the SDR image
Map.addLayer(soapSDR_RGB, {min:103, max:1160}, 'SOAP 2019 Reflectance RGB');
```

## Recap

