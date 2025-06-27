---
syncID: 5c405525ee9c462aa029b208358a355d
title: "Reflectance pre-processing: masking out bad weather data in GEE"
description: "Learn how find and use weather quality information from the Reflectance QA band in GEE"
dateCreated: 2022-05-27
authors: Bridget M. Hass, John Musinsky
contributors: Tristan Goulden
estimatedTime: 30 minutes
packagesLibraries: 
topics: hyperspectral, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001
code1: 
tutorialSeries: aop-gee2023
urlTitle: aop-sdr-weather-qa-gee

---

Since reflectance data is generated from a passive energy source (the sun), data collected in cloudy sky conditions are not directly comparable to data collected in clear-sky conditions, as overhead clouds can obscure the incoming light source. AOP aims to collect data only in optimal (<10% cloud-cover) weather conditions, but cannot always do so due to logistical constraints. The flight operators record the weather conditions during each flight, and this information is passed through to the final data product at the level of the flight line (as cloud conditions can change throughout the day). Cloud conditions are reported as green (<10% cloud cover), yellow (10-50% cloud cover), or red (>50% cloud cover). The figure below shows some examples of what the cloud conditions look like at different flights collected in the three different weather classes (green, yellow, and red).

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/flight_cloud_photos.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/flight_cloud_photos.png" alt="In-flight cloud photos" style="max-width: 100%; height: auto;">
	<figcaption>Cloud cover percentage during AOP flights. Left: green (<10%), Middle: yellow (10-50%), Right: red (>50%).</figcaption>
	</a>
</figure>  

Note that there is an important distinction between airborne and satellite reflectance data. Satellite data is collected in all weather conditions, and the clouds are below the sensor, so algorithms can be generated to filter out cloudy pixels. With aerial data, we have more control over when the data are collected, to a degree. However, clouds may be present overhead, if it were deemed necessary to collect in sub-optimal weather conditions. AOP typically will only collect in "red" sky conditions if we are running out of time in a Domain and the weather isn't forecasted to improve. Since the clouds won't appear in the actual data, maintaining this record of cloud conditions is essential for properly understanding the data, and using it for change detection or other research applications. For a more direct comparison of reflectance values, we recommend only working with the clear-weather data. This lesson outlines how to do this in GEE.

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
- Extract and plot the weather quality indicator band from the Surface Directional Reflectance dataset
- Mask reflectance data to pull out only clear-weather data for a given site
- Explore other QA bands included in the Reflectance data set

## Requirements

- Complete the following introductory AOP GEE tutorials:
    - <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-image-collections" target="_blank">Introduction to AOP Public Datasets in Google Earth Engine (GEE)</a>
- An understanding of hyperspectral data and AOP spectral data products. If this is your first time working with AOP hyperspectral data, we encourage you to start with:
    - <a href="https://www.neonscience.org/resources/learning-hub/tutorials/hsi-hdf5-r" target="_blank">Intro to Working with Hyperspectral Remote Sensing Data in R</a>. You do not need to follow along with the code in those lessons, but at least read through to gain a better understanding of NEON's hyperspectral data product.

</div>

## Read in the AOP Surface Directional Reflectance 2019 Dataset at SOAP

For this exercise, we will read in directional reflectance data from the NEON site <a href="https://www.neonscience.org/field-sites/soap" target="_blank">Soaproot Saddle (SOAP)</a> collected in 2019: 

```javascript
// Filter image collection by date and site to pull out a single image
var soapSDR = ee.ImageCollection("projects/neon-prod-earthengine/assets/HSI_REFL/001")
  .filterDate('2019-01-01', '2019-12-31')
  .filterMetadata('NEON_SITE', 'equals', 'SOAP')
  .first();
```
## Display the QA Bands

From the previous lesson, recall that the reflectance images include 442 bands. Bands 0-425 are the data bands, which store the spectral reflectance values for each wavelength recorded by the NEON Imaging Spectrometer (NIS). The remaining bands (426-441) contain metadata and QA information that are important for understanding and properly interpreting the hyperspectral data. The data bands all follow the naming convention B001, B002, ..., B426, and the QA bands have more descriptive names that start with something other than the letter "B", so we can use that information to extract the QA bands.

```javascript
// Pull out and display only the qa bands (these all start with something other than B)
// '[^B].*' is a regular expression to pull out bands that don't start with B
var soapSDR_qa = soapSDR.select('[^B].*') 
print('QA Bands',soapSDR_qa)
```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/qa_bands.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/qa_bands.PNG" alt="Reflectance QA Bands" style="max-width: 100%; height: auto;">
	</a>
</figure>

Most of these QA bands are inputs to and outputs from the Atmospheric Correction (ATCOR), the process which converts radiance to atmospherically corrected reflectance. We will elaborate on these QA bands further, and encourage you to read more details about these data in the <a href="https://data.neonscience.org/api/v0/documents/NEON.DOC.001288vB?inline=true" target="_blank">NEON Imaging Spectrometer Radiance to Reflectance Algorithm Theoritical Basis Document</a>. For the purposes of this exercise, we will focus on the Weather Quality Indicator band. Note that you can explore each of the QA bands, following similar steps below, adjusting the band names and values accordingly.

## Read in the `Weather_Quality_Indicator` Band

The weather information, called `Weather_Quality_Indicator` is one of the most important pieces of QA information that is collected about the NIS data, as it has a direct impact on the reflectance values. 

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

For reference, we can plot the weather band data, using AOP's stop-light (red/yellow/green) color scheme, with the code below:

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

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/soap_clear_sdr_weather_map.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/soap_clear_sdr_weather_map.PNG" alt="GEE Map of SOAP Weather Quality Map and Clear Reflectance Data" style="max-width: 100%; height: auto;">
	</a>
</figure>

## Plot acquisition dates

We can apply the same concepts to explore another one of the QA bands, this time let's look at the `Acquisition_Date`. This may be useful if you are trying to find the dates that correspond to field data you've collected, or you want to scale up to satellite data, for example. To determine the minimum and maximum dates, you can use `reduceRegion` with the reducer `ee.Reducer.minMax()` as follows. Then use these start and end date values in the visualization parameters. 

**Tip:** You may not wish to show every layer by default if you are plotting many layers. You can choose not to display a layer by default by including a "0" as the last input of `Map.addLayer`. Once you run the code, to toggle the layer on, find the **`Layers`** tab in the upper right corner of the Map Window and check the box to the left of the layer you want to display. You can click on the lock icon to make it so that the Layers full display stays open (by default it minimizes).
	
```javascript	
// Extract acquisition dates QA band
var soapDates = soapSDR.select(['Acquisition_Date']);

// Get the minimum and maximum values of the soapDates band
var minMaxValues = soapDates.reduceRegion({reducer: ee.Reducer.minMax(),maxPixels: 1e10})
print('min and max dates', minMaxValues);
	
// Map acquisition dates, don't display layer by default
Map.addLayer(soapDates,
            {min:20190612, max:20190616, opacity: 0.5},
            'SOAP 2019 Acquisition Dates',0);
```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/soap_acquisition_dates.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/soap_acquisition_dates.PNG" alt="SOAP 2019 Acquisition Dates" style="max-width: 100%; height: auto;">
	</a>
</figure>
	
## Recap

In this lesson you learned how to read in Weather Quality Information from the Reflectance QA bands in GEE. You learned to mask data to keep only the imagery collected in the clearest sky conditions (<10% cloud cover), and plot the three weather quality classes. You also learned how to find the other QA bands. Following a similar approach, you can explore each of the QA bands similarly. Filtering by the weather quality is an important first pre-processing step to working with NEON hyperspectral data, and is essential for interpreting the data and carrying out subsequent data analysis.

## Get Lesson Code

<a href="https://code.earthengine.google.com/3b9f43d1e1baefab5ceabc6a59d03b51" target="_blank">AOP GEE SDR Weather Quality</a>
