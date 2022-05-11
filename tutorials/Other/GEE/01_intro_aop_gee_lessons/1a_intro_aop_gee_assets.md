---
syncID: 
title: "Introduction to working with AOP Data in Google Earth Engine (GEE)"
description: "Introductory tutorial on exploring AOP datasets in GEE."
dateCreated: 2022-04-14
authors: [Bridget M. Hass]
contributors: [John Musinsky, Tristan Goulden, Lukas Straube]
estimatedTime: 20 minutes
packagesLibraries: 
topics: lidar, hyperspectral, camera, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001, DP3.30010.001, DP3.30024.001
code1: 
tutorialSeries: aop-gee
urlTitle: intro-aop-gee-tutorial

---

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
 * Write basic JavaScript code in the Google Earth Engine (GEE) code editor 
 * Discover which NEON AOP datasets are available in GEE
 * Import Image Collection variables 
 * Explore the NEON AOP GEE Assets

You will gain familiarity with:
 * The GEE Code Editor
 * GEE Image Collections
 * Asset descriptions and details

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * A basic understanding of the GEE code editor and the GEE JavaScript API.

## Additional Resources
If this is your first time using GEE, we recommend starting on the Google Developers website, and working through some of the introductory tutorials. The links below are good places to start.
 * <a href="https://developers.google.com/earth-engine/guides/getstarted" target="_blank"> Get started with Earth-Engine  </a>
 * <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank"> GEE JavaScript Tutorial </a>

</div>

## Background

AOP has published a subset of AOP Level 3 (mosaicked) data products at 6 NEON sites (as of Spring 2022) on GEE. This data has been converted to Cloud Optimized GeoTIFF (COG) format. NEON L3 lidar and derived spectral indices are avaialable in geotiff raster format, so are relatively straightforward to add to GEE, however the hyperspectral data is available in hdf5 (hierarchical data) format, and have been converted to the COG format prior to being added to GEE.

To interactively explore NEON data available on GEE, you can use the [aop-data-visualization](https://neon-aop.users.earthengine.app/view/aop-data-visualization) app created by AOP Scientist John Musinsky. 

## AOP GEE Data Availability & Access

The NEON data products that have been made available on GEE can be accessed through the `projects/neon` folder with an appended prefix of the Data Product ID, matching the [NEON data portal](https://data.neonscience.org/data-products/explore). The table below summarizes the prefixes to use for each data product, and is a useful reference for reading in AOP GEE datasets. You will see how to access and read in these data products in the next part of this lesson. 

| Acronym | Data Product      | Data Product ID (Prefix) |
|----------|------------|-------------------------|
| SDR | Surface Directional Reflectance | DP3-30006-001_SDR |
| RGB | Red Green Blue (Camera Imagery) | DP3-30010-001_RGB |
| DEM | Digital Surface and Terrain Models (DSM/DTM) | DP3-30024-001_DEM |
| CHM | Canopy Height Model | DP3-30015-001_CHM |*

The table below summarizes the sites, products, and years of NEON AOP data that can currently be accessed in GEE. The * indicates partial availability.

| Domain | Site | Years      | Data Products        |
|--------|------|------------|----------------------|
| D08 | TALL | 2017, 2018 | SDR, RGB, CHM, DSM, DTM |
| D11 | CLBJ | 2017, 2019 | SDR, RGB, CHM, DSM, DTM |
| D14 | JORN | 2017, 2019 | SDR, RGB*, DSM, DTM|
| D14 | SRER | 2017, 2018, 2019, 2021* | SDR, RGB, CHM*, DSM, DTM|
| D16 | WREF | 2017, 2018 | SDR, RGB, CHM, DSM, DTM |
| D17 | TEAK | 2017, 2018 | SDR, RGB, CHM, DSM, DTM |

## Get Started with Google Earth Engine

Once you have set up your Google Earth Engine account you can navigate to the <a href="https://code.earthengine.google.com/" target="_blank">Earth Engine Code Editor</a>. The diagram below, from the <a href="https://developers.google.com/earth-engine/guides/playground" target="_blank">Earth-Engine Playground</a>, shows the main components of the code editor. If you have used other programming languages such as R, Python, or Matlab, this should look fairly similar to other Integrated Development Environments (IDEs) you may have worked with. The main difference is that this has an interactive map at the bottom, similar to Google Maps and Google Earth. This editor is fairly intuitive. We encourage you to play around with the interactive map, or explore the ee documentation, linked above, to gain familiarity with the various features.

<figure>
	<a href="https://developers.google.com/earth-engine/images/Code_editor_diagram.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/code_editor_diagram.png" alt="Earth Engine Code Editor Components."></a>
</figure>

## Read AOP Data Collections into GEE using `ee.ImageCollection`

AOP data can be accessed through GEE through the `projects/neon` folder. In the remainder of this lesson, we will look at the three AOP datasets, or `ImageCollection`s in this folder.

An <a href="https://developers.google.com/earth-engine/guides/ic_creating" target="_blank">ImageCollection</a> is simply a group of images. To find publicly available datasets (primarily satellite data), you can explore the Earth Engine <a href="https://developers.google.com/earth-engine/datasets" target="_blank">Data Catalog</a>. Currently, NEON AOP data cannot be discovered in the main GEE data catalog, so the following steps will walk you through how to find available AOP data.

In your code editor, copy and run the following lines of code to create 3 `ImageCollection` variables containing the Surface Directional Reflectance (SDR), Camera Imagery (RGB) and Digital Surface and Terrain Model (DEM) raster data sets. 

```javascript
//read in the AOP image collections as variables

var aopSDR = ee.ImageCollection('projects/neon/DP3-30006-001_SDR')

var aopRGB = ee.ImageCollection('projects/neon/DP3-30010-001_RGB') 

var aopDEM = ee.ImageCollection('projects/neon/DP3-30024-001_DEM')
```

A few tips for the Code Editor: 
- In the left panel of the code editor, there is a **Docs** tab which includes API documentation on built in functions, showing the expected input arguments. We encourage you to refer to this documentation, as well as the <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank"> GEE JavaScript Tutorial</a> to familiarize yourself with GEE and the JavaScript programming language.
- If you have an error in your code, a red error message will show up in the Console (in the right panel), which tells you the line that failed.
- Save your code frequently! If you try to leave your code while it is unsaved, you will be prompted that there are unsaved changes in the editor.

When you Run the code above (by clicking on the **Run** above the code editor), you will notice that the lines of code become underlined in red, the same as you would see for a spelling error in most text editors. If you hover over each of the lines of codes, you will see a message pop up that says: `<variable> can be converted to an import record. Convert Ignore`. 

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/import_record_popup.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/import_record_popup.png" alt="GEE Import Record Popup."></a>
</figure>

If you click `Convert`, the line of code will disappear and the variable will be imported into your session directly, and will show up at the top of the code editor. Go ahead and convert the variables for all three lines of code, so you should see the following. Tip: if you type Ctrl-z, you can re-generate the line of code, and the variable will still show up in the imported variables at the top of the editor. It is a good idea to retain the original code that reads in the variable, for reproducibility. If you don't do this, and wish to share this code with someone else, or run the code outside of your own code editor, the imported variables will not be saved.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/aop_imported_image_collections.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/aop_imported_image_collections.png" alt="Imported AOP Image Collections."></a>
</figure>

Note that each of these imported variables can now be expanded, using the arrow to the left of each. These variables now show associated information including *type*, *id*, and *properties*, which if you expand, shows a *description*. This provides more detailed information about the data product.

Information about the image collections can also be found in a slightly more user-friendly format if you click on the blue `projects/neon/DP3-30006-001_SDR`, as well as `DP3-30010-001_RGB` and`DP3-30024-001_DEM`, respectively. Below we'll show the window that pops-up when you click on `SDR`, but we encourage you to look at all three datasets.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/sdr_asset_details_description.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/sdr_asset_details_description.png" alt="SDR Asset Details Description."></a>
</figure>

This allows you to read the full description in a more user-friendly format. Note that the images imported into GEE may have some slight differences from the data downloaded from the data portal. For example, note that the reflectance data in GEE is scaled by 100. We highly encourage you to explore the description and associated documentation for the data products on the NEON data portal as well (eg. <a href="https://data.neonscience.org/data-products/DP3.30006.001" target="_blank">DP3.30006.001</a>) for relevant information about the data products, how they are generated, and other pertinent details.

You can also click on the `IMAGES` tab to explore all the available NEON images for that data product. Some of the text may be cut off in the default view, but if you click in one of the table values the table will expand. This table summarizes individual sites and years that are available for the SDR Image Collection. The ImageID provides the path to read in an individual image. In the next step, we will show how to use this path to pull in a single file. 

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/sdr_asset_details_images.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/sdr_asset_details_images.png" alt="SDR Asset Details Images."></a>
</figure>

## Read AOP Data into GEE using `ee.Image`

As a last step, we will go ahead and use the path specified in the SDR Asset Details Images table to read in a single image. Pulling in a single image uses almost identical syntax as an image collection, see below:

```javascript
var TALL_2017_SDR = ee.Image('projects/neon/DP3-30006-001_SDR/DP3-30006-001_D08_TALL_SDR_2017')
```

Import this variable, and you can see that it pulls in to the Imports at the top, and shows `(426 bands)` at the right. To the right of that you will see blue eye and target icons. If you hover over the eye it displays "Show on Map". Click this eye icon to place a footprint of this data set in the Map display. If you hover over the target icon, you will see the option "Center Map on Record". Click this to center your map on this TALL SDR dataset. You should now see the footprint of the data as a layer in the Google Map.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/tall_sdr_map.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/tall_sdr_map.png" alt="TALL SDR Show On Map."></a>
</figure>

## A Quick Recap

You did it! You should now have a basic understanding of the GEE code editor and it's different components. You have also learned how to read a NEON AOP `ImageCollection` into a variable, import the variable into your code editor session, and navigate through the `ImageCollection` **Asset details** to find the path to an individual `Image`. Lastly, you learned to read in an individual SDR Image, pull the footprint of the data into a Map Layer, and center on that region.

It doesn't look like we've done much so far, but this is a already great achievement! With just a few lines of code, you have imported an entire AOP hyperspectral data set, which is not an easy feat. One of the barriers to working with AOP data (and reflectance data in particular) is it's large data volume, which requires high-performance computing environments to carry out analysis. There are also limited open-source tools for working with the data; many of the software suites for working with hyperspectral data require licenses which can be expensive. In this lesson, we have loaded spectral data over an entire site, and are ready for data exploration and analysis, in a free geospatial cloud-computing platform. 

In the next tutorials we will pull in RGB composites spectral data, interactively plot spectral signatures of pixels in the image, and carry out some more advanced analysis that is highly simplified by the built in GEE functions. 

## Get Lesson Code

<a href="https://code.earthengine.google.com/92d8ecf5795746900d6fd5cad9a685ea" target="_blank">Importing AOP Image Collection Variables</a>
