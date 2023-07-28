---
syncID: 
title: "Function for Visualizing AOP Image Collections in GEE"
description: "Load in and visualize SDR data using a function"
dateCreated: 2022-07-27
authors: Bridget M. Hass, John Musinsky
contributors: Tristan Goulden, Lukas Straube
estimatedTime: 20 minutes
packagesLibraries: 
topics: hyperspectral, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001
code1: 
tutorialSeries: aop-gee
urlTitle: intro-aop-gee-functions

---
## Writing a Function to Visualize AOP SDR Image Collections

In the previous <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-sdr-tutorial" target="_blank">Introduction to AOP Hyperspectral Data in GEE</a> tutorial, we showed how to read in SDR data for images from 3 years. In this tutorial, we will show you a different, more simplified way of doing the same thing, using functions. This is called "refactoring". In any coding language, if you notice you are writing very similar lines of code repeatedly, it may be an opportunity to create a function. For example, in the previous tutorial, we repeated lines of code to pull in different years of data at SRER, the only difference being the year and the variable names for each year. As you become more proficient with GEE coding, it is good practice to start writing functions to make your scripts more readable and reproducible. 

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
- Write and call a function to read in and display an AOP SDR Image Collection
- Write a function to read in and remove poor weather data from an SDR Image Collection
- Modify this function to read in other image collections

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * A basic understanding of the GEE code editor and the GEE JavaScript API. These are introduced in the tutorials:
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP Data in GEE</a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-sdr-tutorial" target="_blank">Introduction to AOP Hyperspectral Data in GEE</a>
 * A basic understanding of hyperspectral data and the AOP spectral data products. If this is your first time working with AOP hyperspectral data, we encourage you to start with the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/hsi-hdf5-r" target="_blank">Intro to Working with Hyperspectral Remote Sensing Data in R</a> tutorial. You do not need to follow along with the code in those lessons, but at least read through to gain a better understanding NEON's spectral data products.

## Additional Resources
If this is your first time using GEE, we recommend starting on the Google Developers website, and working through some of the introductory tutorials. The links below are good places to start.
 * <a href="https://developers.google.com/earth-engine/guides/getstarted" target="_blank"> Get Started with Earth-Engine </a>
 * <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank"> GEE JavaScript Tutorial </a>
 * <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_03" target="_blank"> Functional Programming in GEE </a>

</div>

Let's get started! First let's take a look at the syntax for writing user-defined functions in GEE. If you are familiar with other programming languages, this should look somewhat familiar. The function requires input arguments `args` and returns an `output`.

```javascript
var functionName = function(args) {
  // do something with input args
  return output;
};
```

To call the function for a full image collection, you can use a <a href="https://developers.google.com/earth-engine/guides/getstarted#mapping-what-to-do-instead-of-a-for-loop"> map </a> to iterate over items in a collection. This is shown in the script below.

```javascript
// Map the function over the collection.
var newVariable = collection.map(myFunction);
```

For this example, we will provide the full script below, including the function `addNISImage`, with comments explaining what each part of the function does. Note that a helpful troubleshooting technique is to add in `print` statements if you are unsure what the code is returning. We have included some print statements in this function below, and show the outputs (which would show up in the console tab). Note that these print statements are commented out in the code linked with this tutorial, since they are not required for the function to run. 

For a little more detail on how this function was created, please refer to this GIS Stack Exchange Post: <a href="https://gis.stackexchange.com/questions/284610/add-display-all-images-of-mycollection-in-google-earth-engine" target="_blank">Add/display all images of my collection in google earth engine</a>. When writing your code, stack overflow is your friend!

```javascript
// define visualization parameters for the reflectance data, showing a true-color image
// B053 ~ 642 nm, B035 ~ 552 nm , B019 ~ 472nm 
var sdrVisParams = {'min':0, 'max':1200, 'gamma':0.9, 'bands':['B053','B035','B019']};

// Create a function to display each NIS Image in the NEON AOP Image Collection
function addNISImage(image) { 
// get the system:id and convert to string
  var imageId = ee.Image(image.id);
  // get the system:id - this is an object on the server
  var sysID_serverObj = ee.String(imageId.get("system:id"));
  // getInfo() converts to string on the server
  var sysID_serverStr = sysID_serverObj.getInfo()
  // truncate the string to show only the fileName (NEON domain + site code + product code + year)
  var fileName = sysID_serverStr.slice(52,100); 
  //print("fileName: "+fileName) // optionally print the file name, can uncomment

  // add this layer to the map using the true-color (RGB) visualization parameters
  Map.addLayer(imageId, sdrVisParams, fileName)
}

// call the addNISimages function
NISimages.evaluate(function(NISimages) {
  NISimages.features.map(addNISImage);
})

// Center the map on site and set zoom level (11)
Map.centerObject(siteCenter, 11);
```

Note that the first half of this function is just pulling out relevant information about the site - in order to properly label the layer on the Map display. You should recognize some of the same syntax from the previous tutorial in the last two lines of code in the function, defining the variable `imageRGB`, using `updateMask`, and finally using `Map.addLayer` to add the layer to the Map window. Note that this function is subsetting the SDR image to only pull in the red, green, and blue bands, as opposed to the previous tutorial where we read in the full hyperspectral cube, and then displayed only the RGB composite in the visParam variable. 

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2b_sdr_viz_functions/srer_screenshot.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2b_sdr_viz_functions/srer_screenshot.png" alt="SRER viz function screenshot"></a>
</figure>



```javascript
// Define a palette for the weather - to match NEON AOP's weather color conventions
var gyrPalette = [
  '00ff00',  // green (<10% cloud cover)
  'ffff00',  // yellow (10-50% cloud cover)
  'ff0000']; // red (>50% cloud cover)

// Build upon the function to add a layer of the weather band, and 
// mask out poor-weather data (>10% cloud cover), keeping only the clear weather (<10% cloud cover)
function clearNISImages(image) { 
  // get the system:id and convert to string
  var imageId = ee.Image(image.id);
  // get the system:id - this is an object on the server
  var sysID_serverObj = ee.String(imageId.get("system:id"));
  // getInfo() converts to string on the server
  var sysID_serverStr = sysID_serverObj.getInfo()
  // truncate the string to show only the fileName (NEON domain + site code + product code + year)
  var fileName = sysID_serverStr.slice(52,100); // optionally print, can uncomment
  
  // create a single band Weather Quality QA layer for 2016
  var weather_qa = imageId.select(['Weather_Quality_Indicator']);
  // WEATHER QUALITY INDICATOR = 1 is < 10% CLOUD COVER
  var clear_qa = weather_qa.eq(1);
  // mask out all cloudy pixels from the SDR image
  var imageClear = imageId.updateMask(clear_qa);

  // add the weather QA bands to the map with the green-yellow-red palette
  Map.addLayer(weather_qa, {min: 1, max: 3, palette: gyrPalette, opacity: 0.3}, fileName + ' Weather QA Band')

  // add the clear weather reflectance layer to the map - the 0 means the layer won't be turned on by default
  Map.addLayer(imageClear, sdrVisParams, fileName + ' Clear',0)
}

//call the clearNISImages function
NISimages.evaluate(function(NISimages) {
  NISimages.features.map(clearNISImages);
})
```

## Get Lesson Code

<a href="https://code.earthengine.google.com/0a3af7782726a1e4bb6e8c299fb883f2" target="_blank">Functions to display AOP SDR Image Collections in GEE</a>
