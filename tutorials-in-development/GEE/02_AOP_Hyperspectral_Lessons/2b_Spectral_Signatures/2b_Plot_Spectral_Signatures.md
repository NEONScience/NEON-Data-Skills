# Plot Spectral Signatures
## Interactively plot the spectral signature of a pixel

---

Author: Bridget Hass

Contributors: John Musinsky, Tristan Goulden, Lukas Straube

Last Updated: April 14, 2022

Objectives
---
- Read in a single AOP Hyperspectral Reflectance raster data set at the NEON site SRER
- Link spectral band #s to wavelength values
- Gain experience with the Earth Engine User Interface (`ui`) API
- Create an inset plot to display the spectral signature of a given pixel upon clicking

Requirements
---
- Complete the introductory AOP GEE tutorials [Intro to AOP Data in GEE](https://github.com/NEONScience/NEON-Data-Skills/blob/bhass/tutorials-in-development/GEE/01_Intro_AOP_GEE/1a_GEE_AOP_101.md) and [Intro to AOP Hyperspectral Data in GEE](https://github.com/NEONScience/NEON-Data-Skills/blob/bhass/tutorials-in-development/GEE/02_AOP_Hyperspectral_Lessons/2a_Intro_AOP_Hyperspectral/2a_Intro_AOP_SDR_Rasters.md)
- An understanding of hyperspectral data and AOP spectral data products. If this is your first time working with AOP hyperspectral data, we encourage you to start with the [Intro to Working with Hyperspectral Remote Sensing Data](https://www.neonscience.org/resources/learning-hub/tutorials/hsi-hdf5-r) tutorial. You do not need to follow along with the code in those lessons, but at least read through to gain a better understanding NEON's spectral data products.

Read in the AOP SDR Dataset at SRER (2021 only)
---

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

Create the wavelengths variable
---

```javascript
// Set wavelength variable for spectral plot
var wavelengths = ee.List.sequence(381, 2510, 5).getInfo()
var bands_no =  ee.List.sequence(1, 426).getInfo() 
```

[Earth Engine User Interface](https://developers.google.com/earth-engine/guides/ui)
---

```javascript
// Create a panel to hold the spectral signature plot
var panel = ui.Panel();
panel.style().set({width: '600px',height: '300px',position: 'top-left'});
Map.add(panel);
Map.style().set('cursor', 'crosshair');
```

[Map.onClick](https://developers.google.com/earth-engine/apidocs/ui-map-onclick)

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
