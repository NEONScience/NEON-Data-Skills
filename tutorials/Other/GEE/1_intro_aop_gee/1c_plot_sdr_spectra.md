---
syncID: d2e642ff6bb44f8798ddbe4fd5e45243
title: "Plot spectral signatures of AOP Reflectance data in GEE"
description: "Interactively plot the spectral signature of an AOP SDR pixel in GEE"
dateCreated: 2022-04-15
authors: Bridget M. Hass, John Musinsky
contributors: Tristan Goulden, Lukas Straube
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
- Read in a single AOP Hyperspectral Reflectance raster data set at the NEON site SOAP
- Link spectral band #s to wavelength values
- Create an interactive widget to plot the spectral signature of a given pixel upon clicking

## Requirements

- Complete the following introductory AOP GEE tutorials:
    - <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-image-collections" target="_blank">Introduction to AOP Public Datasets in Google Earth Engine (GEE)</a>
- An understanding of hyperspectral data and AOP spectral data products. If this is your first time working with AOP hyperspectral data, we encourage you to start with the [Intro to Working with Hyperspectral Remote Sensing Data](https://www.neonscience.org/resources/learning-hub/tutorials/hsi-hdf5-r) tutorial. You do not need to follow along with the code in those lessons, but at least read through to gain a better understanding NEON's spectral data products.

</div>

## Read in the AOP SDR 2021 Dataset at SOAP

We will start at our ending point of the last tutorial. For this exercise we will only read data from SOAP collected in 2021:

```javascript
// Filter image collection by date and site
var soapSDR = ee.ImageCollection("projects/neon-prod-earthengine/assets/DP3-30006-001")
  .filterDate('2021-01-01', '2021-12-31')
  .filterMetadata('NEON_SITE', 'equals', 'SOAP')
  .first();

// Create a 3-band true-color image 
var soapSDR_RGB = soapSDR.select(['B053', 'B035', 'B019']);

// Display the SDR image
Map.addLayer(soapSDR_RGB, {min:103, max:1160}, 'SOAP 2021 Reflectance RGB');

// Center the map at the lat / lon of the site, set zoom to 12
Map.setCenter(-119.25, 37.06, 12);
```

## Extract data bands
Next we will extract only the "data" bands in order to plot the spectral information. The SDR data contains 426 data bands, and a number of QA/Metdata bands that provide  additional information that can be useful in interpreting and analyzing the data (such as the Weather Quality Information). For plotting the spectra, we only need the data bands.

```javascript
// Pull out only the data bands (these all start with B, eg. B001)
var soapSDR_data = soapSDR.select('B.*')
print(soapSDR_data)

// Read in the properties as a dictionary
var properties = soapSDR.toDictionary()
// print(properties)

print('Data description',properties.select(['DESCRIPTION']).values())
print('SOAP SDR data:',ee.Algorithms.Describe(soapSDR_data))
```

## Extract wavelength information from the properties

Similar to the code above, we can use a regular expression to pull out the wavelength information from the properties. The wavelength and Full Width Half Max (FWHM) information is stored in the properties starting with WL_FWHM_B. These are stored as strings, so the nex step is to write a funciton that converts the string to a float, and only pulls out the center wavelength value (by splitting on the "," and pulling out only the first value). This is all we need for now, but if you needed the FWHM information, you could write a similar function. Lastly, we'll apply the function using GEE `.map` to pull out the wavelength information. We an then print some information about what we've extracted

```javascript
// Select the WL_FWHM_B*** band properties (using regex)
var wl_fwhm_dict = properties.select(['WL_FWHM_B+\\d{3}']);

// Pull out the wavelength, fwhm values to a list
var wl_fwhm_list = wl_fwhm_dict.values()
print('Wavelength FWHM list:',wl_fwhm_list)

// Function to pull out the wavelength values only and convert the string to float
var get_wavelengths = function(x) {
  var str_split = ee.String(x).split(',')
  var first_elem = ee.Number.parse((str_split.get(0)))
  return first_elem
}

// apply the function to the wavelength full-width-half-max list
var wavelengths = wl_fwhm_list.map(get_wavelengths)

print('Wavelengths:',wavelengths)
print('# of data bands:',wavelengths.length())
```

## Interactively plot the spectral signature of a pixel

Lastly, we'll create a plot in the Map panel, and use the `Map.onClick` function to create a spectral signature of a given pixel that you click on. Most of the code below specifies formatting, figure labels, etc.

```javascript
// Create a panel to hold the spectral signature plot
var panel = ui.Panel();
panel.style().set({width: '600px',height: '300px',position: 'top-left'});
Map.add(panel);
Map.style().set('cursor', 'crosshair');

// Create a function to draw a chart when a user clicks on the map.
Map.onClick(function(coords) {
  panel.clear();
  var point = ee.Geometry.Point(coords.lon, coords.lat);
    wavelengths.evaluate(function(wvlnghts) {
      var chart = ui.Chart.image.regions({
        image: soapSDR_data, 
        regions: point, 
        scale: 1,
        seriesProperty: 'λ (nm)', 
        xLabels: wavelengths.getInfo()
    });
    chart.setOptions({
      title: 'Reflectance',
      hAxis: {title: 'Wavelength (nm)', 
      vAxis: {title: 'Reflectance'},
      gridlines: { count: 5 }}
    });
    // Create and update the location label 
    var location = 'Longitude: ' + coords.lon.toFixed(2) + ' ' +
                   'Latitude: ' + coords.lat.toFixed(2);
    panel.widgets().set(1, ui.Label(location));
    panel.add(chart);
  })
});
```

When you run this code, (linked at the bottom), you will see the SOAP 2021 SDR layer show up in the Map panel, along with a white figure panel. When you click anywhere in the SDR image, the empty figure will be populated with the spectral signature of the pixel you clicked on.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1c_plot_spectra/soap_spectral_plot.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1c_plot_spectra/soap_spectral_plot.PNG" alt="SOAP Specral Plot"></a>
</figure>

## Recap

In this lesson you learned how to read in wavelength information from the Surface Directional Reflectance (SDR) properties in GEE, created functions to convert from one data format to another, and created an interactive plot to visualize the spectral signature of a selected pixel. You can quickly see how GEE is a powerful tool for interactive data visualization and exploratory analysis.

## Get Lesson Code

<a href="https://code.earthengine.google.com/0bc6632b15a3d29d545c85fbceaa67b7" target="_blank">AOP GEE SDR Weather Quality</a>
