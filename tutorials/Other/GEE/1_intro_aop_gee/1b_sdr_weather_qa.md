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
