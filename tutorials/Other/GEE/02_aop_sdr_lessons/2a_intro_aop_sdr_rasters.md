---
syncID: ea5ebcf71c344bf1b2a7be0067005afd
title: "Introduction to AOP Hyperspectral Data in GEE"
description: "Read in and visualize Surface Directional Reflectance data at NEON site SRER"
dateCreated: 2022-04-14
authors: [Bridget M. Hass]
contributors: [John Musinsky, Tristan Goulden, Lukas Straube]
estimatedTime: 30 minutes
packagesLibraries: 
topics: hyperspectral, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001
code1: 
tutorialSeries: aop-gee
urlTitle: intro-aop-gee-sdr-tutorial

---
## Read in and Visualize AOP SDR Data

In the first <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP data in GEE</a> tutorial, we showed how to explore the NEON AOP GEE Image Collections. We will build off that tutorial in this lesson, to pull in and visualize some AOP hyperspectral data in GEE. Specifically, we will look at surface directional reflectance (SDR) data collected at the NEON site <a href="https://www.neonscience.org/field-sites/srer" target="_blank">SRER</a> (Santa Rita Experimental Range) for 3 years between 2018 and 2021.

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
- Read AOP hyperspectral reflectance raster data sets into GEE
- Visualize multiple years of data and qualitatively explore inter-annual differences

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * A basic understanding of the GEE code editor and the GEE JavaScript API. These are introduced in the tutorial <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP Data in GEE</a>, as well as in the Additional Resources below.
 * A basic understanding of hyperspectral data and the AOP spectral data products. If this is your first time working with AOP hyperspectral data, we encourage you to start with the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/hsi-hdf5-r" target="_blank">Intro to Working with Hyperspectral Remote Sensing Data in R</a> tutorial. You do not need to follow along with the code in those lessons, but at least read through to gain a better understanding NEON's spectral data products.

## Additional Resources
If this is your first time using GEE, we recommend starting on the Google Developers website, and working through some of the introductory tutorials. The links below are good places to start.
 * <a href="https://developers.google.com/earth-engine/guides/getstarted" target="_blank"> Get Started with Earth-Engine  </a>
 * <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank"> GEE JavaScript Tutorial </a>

</div>

Let's get started! In this tutorial we generate basic GEE (JavaScript) code to visualize hyperspectral data. We will work through the following steps:

1) Pull in an AOP hyperspectral data set
2) Set the visualization parameters
3) Mask the no data values
4) Add the AOP layer to the GEE Map
5) Center on the region of interest

We encourage you to follow along with this code chunks in this exercise in your code editor. To run the cells, you can click the **Run** button at the top of the code editor. Note that until you run the last two steps (adding the data layer to the map), you will not see the AOP data show up in the Interactive Map.

1. Read in the SRER 2018 SDR image, using `ee.Image`. We will assign this image to a variable (**var**) called `SRER_SDR2018`. You can refer to the tables in the Data Access and Availability section, in the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP data in GEE tutorial</a>, to see how to pull in spectral data from a different site.

```javascript
var SRER_SDR2018 = ee.Image("projects/neon/D14_SRER/L3/DP3-30006-001_D14_SRER_SDR_2018");
```

As we covered in the previous lesson, when you type this code, it will be underlined in red (the same as you would see with a mis-spelled word). When you hover over this line, you will see an option pop up that says `"SRER_SDR2018" can be converted to an import record. Convert Ignore` 

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2a_intro_sdr/convert_to_import_record.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2a_intro_sdr/convert_to_import_record.png" alt="Convert Variable to Import Record"></a>
</figure>

If you click `Convert`, the line of code will disappear and the variable will be pulled into the top of the code editor, as shown below. Once imported, you can interactively explore this variable - eg. you can expand on the `bands` and `properties` to gain more information about this image, or "asset", as it's called in GEE.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2a_intro_sdr/imports.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2a_intro_sdr/imports.png" alt="Imported Variables"></a>
</figure>

Another way to learn more about this asset is to left-click on the blue `projects/neon/D14_SRER/L3_DP3-30006-001-D14_SRER_SDR_2018`. This will pop up a box with more detailed information about this asset, as shown below:

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2a_intro_sdr/srer_sdr_asset_details.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2a_intro_sdr/srer_sdr_asset_details.png" alt="SRER SDR Asset Details"></a>
</figure>

Click `Esc` to return to the code editor. Note that you can run the code either way, with the variable explicitly specified in the code editor, or imported as a variable, but we encourage you to leave the variable written out in the code, as this way is more reproducible.

2. Set the visualization parameters - this specifies the band combination that is displayed, and other display options. For more detailed information, refer to the GEE documentation on <a href="https://developers.google.com/earth-engine/guides/image_visualization" target="_blank">image visualization</a>.

To set the visualization parameters, we will create a new variable (called `visParams`). This variable is applied to the layer and determines what is displayed. In this we are setting the RGB bands to display - for this exercise we are setting them to red, green, and blue portions of the spectrum in order to show a True Color Image. You can change these bands to show a False Color Image or any band combination of interest. You can refer to NEON's lessons on <a href="https://www.neonscience.org/resources/learning-hub/tutorials/dc-multiband-rasters-r" target="_blank">Multi-Band Rasters in R</a> or <a href="https://www.neonscience.org/resources/learning-hub/tutorials/neon-hsi-aop-functions-tiles-py" target="_blank">RGB and False Color Images in Python</a> for more background on band stacking.

```javascript
var visParams = {'min':2,'max':20,'gamma':0.9,'bands':['band053','band035','band019']};
```

3. Mask layers to only show values > 0

This step is optional, but recommended. AOP sets No Data Values to -9999, so if you don't mask these out you will see any missing data as black in the image (this will often result in a black boundary surrounding the site, but if any data is missing inside the site that will show up as black as well). To show only the data that was collected, we recommend masking these values using the `updateMask` function, as shown below:

```javascript
var SRER_SDR2018mask = SRER_SDR2018.updateMask(SRER_SDR2021.gte(0.0000));
```

4. Now that we've defined the data, the visualization parameters, and the mask, we can add this Layer to the Map! To do this, we use the `Map.addLayer` function with our masked data variable, `SRER_SDRmask`, using the `visParams` and assign this layer a label, which will show up in the Map.

```javascript
Map.addLayer(SRER_SDR2018mask, visParams, 'SRER 2018');
```

5. Center the map on our area of interest. GEE by default does not know where we are interested in looking. We can center the map over our new data layer by 

```javascript
Map.setCenter(-110.83549, 31.91068, 11);
```

Putting it All Together
---
The following code chunk runs all the steps we just broke down, and also adds in 2 more years of data (2019 and 2021). You can pull in this code into your code editor by clicking <a href="https://code.earthengine.google.com/9b442fa13116b2ae487ac8a78d45ba69" target="_blank">here</a>, or alternately copy and paste the code below into your GEE code editor. Click **Run** to add the 3 SDR data layers for each year.

```javascript
// This script pulls in hyperspectral data over the Santa Rita Experimental Range (SRER)
// from 2018, 2019, and 2021 and plots RGB 3-band composites

// Read in Surface Directional Reflectance (SDR) Images 
var SRER_SDR2018 = ee.Image("projects/neon/D14_SRER/L3/DP3-30006-001_D14_SRER_SDR_2018");
var SRER_SDR2019 = ee.Image("projects/neon/D14_SRER/L3/DP3-30006-001_D14_SRER_SDR_2019");
var SRER_SDR2021 = ee.Image("projects/neon/D14_SRER/L3/DP3-30006-001_D14_SRER_SDR_2021");

// Set the visualization parameters so contrast is maximized, and set display to show RGB bands 
var visParams = {'min':2,'max':20,'gamma':0.9,'bands':['band053','band035','band019']};

// Mask layers to only show values > 0 (this hides the no data values of -9999) 
var SRER_SDR2018mask = SRER_SDR2018.updateMask(SRER_SDR2018.gte(0.0000));
var SRER_SDR2019mask = SRER_SDR2019.updateMask(SRER_SDR2019.gte(0.0000));
var SRER_SDR2021mask = SRER_SDR2021.updateMask(SRER_SDR2021.gte(0.0000));

// Add the 3 years of SRER SDR data as layers to the Map:
Map.addLayer(SRER_SDR2018mask, visParams, 'SRER 2018');
Map.addLayer(SRER_SDR2019mask, visParams, 'SRER 2019');
Map.addLayer(SRER_SDR2021mask, visParams, 'SRER 2021');

// Center the map on SRER & zoom to desired level
Map.setCenter(-110.83549, 31.91068, 11);
```

Once you have the three years of data added, you can look at the different years one at a time by selecting each layer in the Layers box inside the Map:

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2a_intro_sdr/srer_layers.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2a_intro_sdr/srer_layers.png" alt="SRER Layers"></a>
</figure>

If you click anywhere inside the AOP map (where there is data), you will see the 426 spectral bands as a bar chart displayed for each of the layers in the Inspector window (top-right corner of the code editor). You can see the spectral values for different layers by clicking on the arrow to the left of the layer name under Pixels (eg. SRER 2018). Note that these values are just shown as band #s, and you can't tell from the chart what the actual wavelength values are. We will convert the band numbers to wavelengths in the next lesson, so stay tuned!

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2a_intro_sdr/srer_inspector.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/2a_intro_sdr/srer_inspector.png" alt="SRER Inspector"></a>
</figure>

## Get Lesson Code

<a href="https://code.earthengine.google.com/9b442fa13116b2ae487ac8a78d45ba69" target="_blank">Importing and Visualizing SRER SDR Data</a>
