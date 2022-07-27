---
syncID: cd3d3b09400a4a389a198445c5dbfa48
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
urlTitle: intro-aop-gee-sdr-tutorial

---
## Read in and Visualize AOP SDR Data

In the previous <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-sdr-tutorial" target="_blank">Introduction to AOP Hyperspectral Data in GEE</a> tutorial, we showed how to read in SDR data for three individual images. In this tutorial, we will show you a different, more simplified way of doing the same thing, using functions. This is called "refactoring". In any coding language, if you notice you are writing very similar lines of code to do a different thing (for example, we repeated lines of code in the previous tutorial to pull in different years of data, only changing the year each time), it may be an opportunity to create a function,. As you become more proficient with GEE coding, it is good practice to start writing functions to make your scripts more readable and clean. 

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
- Write and call a function to read in and display an AOP SDR image collection
- Modify this function to read in other image collections

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * A basic understanding of the GEE code editor and the GEE JavaScript API. These are introduced in the tutorials:
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP Data in GEE</a>,
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
var myFunction = function(args) {
  // do something with input args
  return output;
};
```

To call the function for a full image collection, you can use a <a href="https://developers.google.com/earth-engine/guides/getstarted#mapping-what-to-do-instead-of-a-for-loop"> map </a> to iterate over items in a collection. This is shown in the script below.

```javascript
// Map the function over the collection.
var newVariable = collection.map(myFunction);
```

For this example, we will provide the full script below, including the function `addNISImage`, with comments explaining what each part of the function does. Note that a helpful troubleshooting technique is to add in `print` statements if you are unsure what you're code is returning. We have included some print statements in this function below, and show the outputs (which would show up in the console tab). Note that these print statements are commented out in the code linked with this tutorial, since they are not required for the function to run.

```javascript
// Specify center location of SRER
var mySite = ee.Geometry.Point([-110.83549, 31.91068])

// Read in the SDR Image Collection
var NISimages = ee.ImageCollection('projects/neon/DP3-30006-001_SDR').filterBounds(mySite)

// Create a function to display each NIS Image in the NEON AOP Image Collection
function addNISImage(image) { 
// get the system:id and convert to string
  var imageId = ee.Image(image.id);
  // get the system:id - this is an object on the server
  var sysID_serverObj = ee.String(imageId.get("system:id"));
  // getInfo() converts to string on the server
  var sysID_serverStr = sysID_serverObj.getInfo()
  print("systemID: "+sysID_serverStr)
  // truncate the string to show only the fileName (4 digit NEON code)
  var fileName = sysID_serverStr.slice(46,100); 
  print("fileName: "+fileName)
  // mask out no-data values and set visualization parameters to show RGB composite
  var imageRGB = imageId.updateMask(imageId.gte(0.0000)).select(['band053', 'band035', 'band019']);
  // add this layer to the map
  Map.addLayer(imageRGB, {min:2, max:20}, fileName)
}

// call the addNISimages function
NISimages.evaluate(function(NISimages) {
  NISimages.features.map(addNISImage);
})

// Center the map on SRER
Map.setCenter(-110.83549, 31.91068, 11);
```

Note that the first half of this function is just pulling out relevant information about the site - in order to obtain the correct label for the layer on the map. You should recognize some of the same syntax from the previous tutorial in the last two lines of code in the function, defining the variable imageRGB, and the `Map.addLayer`. Note that this function is subsetting the SDR image to only pull in the red, green, and blue bands, as opposed to the previous tutorial where we read in the full hyperspectral cube, and then displayed only the RGB composite in the visParam variable. 

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2b_sdr_viz_functions/srer_screenshot.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2b_sdr_viz_functions/srer_screenshot.png" alt="SRER viz function screenshot"></a>
</figure>

You can see that the print statements are showing up in the console, displaying the systemID and fileName. The fileName is applied to the name of the layers in the Map window.

You could alter this function to include the visualization paramters, to subset by other bands, or modify it to work for a different image collection. We encourage you to do this on your own!

## Get Lesson Code

<a href="https://code.earthengine.google.com/52e5e783df69ba1ba86b98b209eb4252" target="_blank">Function to display AOP SDR Image Collections in GEE</a>
