---
syncID: 
title: "Plot spectral signatures of AOP SDR data in GEE"
description: "Interactively plot the spectral signature of an AOP SDR pixel in GEE"
dateCreated: 2022-04-15
authors: [Bridget M. Hass]
contributors: [John Musinsky, Tristan Goulden, Lukas Straube]
estimatedTime: 45 minutes
packagesLibraries: 
topics: hyperspectral, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001
code1: 
tutorialSeries: aop-gee
urlTitle: aop-gee-plot-spectra

---

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
- Read in a single AOP Hyperspectral Reflectance raster data set at the NEON site SRER
- Link spectral band #s to wavelength values
- Gain experience with the Earth Engine User Interface API
- Create a plot to display the spectral signature of a given pixel upon clicking

## Requirements

- Complete the following introductory AOP GEE tutorials:
    - [Intro to AOP Data in GEE](https://github.com/NEONScience/NEON-Data-Skills/blob/bhass/tutorials-in-development/GEE/01_Intro_AOP_GEE/1a_GEE_AOP_101.md) 
    - [Intro to AOP Hyperspectral Data in GEE](https://github.com/NEONScience/NEON-Data-Skills/blob/bhass/tutorials-in-development/GEE/02_AOP_Hyperspectral_Lessons/2a_Intro_AOP_Hyperspectral/2a_Intro_AOP_SDR_Rasters.md)
- An understanding of hyperspectral data and AOP spectral data products. If this is your first time working with AOP hyperspectral data, we encourage you to start with the [Intro to Working with Hyperspectral Remote Sensing Data](https://www.neonscience.org/resources/learning-hub/tutorials/hsi-hdf5-r) tutorial. You do not need to follow along with the code in those lessons, but at least read through to gain a better understanding NEON's spectral data products.

</div>

## Read in the AOP SDR 2021 Dataset at SRER

We will start at our ending point of the last tutorial. For this exercise we will only read data from 2021:

```javascript
// This script pulls in hyperspectral data over the Santa Rita Experimental Range (SRER)
// from 2021 and plots RGB 3-band composite of the imagery

// Read in Surface Directional Reflectance (SDR) Images 
var SRER_SDR2021 = ee.Image("projects/neon/D14_SRER/L3/DP3-30006-001_D14_SRER_SDR_2021");

// Set the visualization parameters so contrast is maximized, and set display to show RGB bands 
var visParams = {'min':2,'max':20,'gamma':0.9,'bands':['band053','band035','band019']};

// Mask layer to only show values > 0 (this hides the no data values of -9999) 
var SRER_SDR2021mask = SRER_SDR2021.updateMask(SRER_SDR2021.gte(0.0000));

// Add the 2021 SRER SDR data as layers to the Map:
Map.addLayer(SRER_SDR2021mask, visParams, 'SRER 2021');
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
