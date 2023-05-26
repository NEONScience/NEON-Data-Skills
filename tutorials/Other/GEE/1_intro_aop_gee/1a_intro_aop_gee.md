---
syncID: 
title: "Introduction to AOP Data in Google Earth Engine (GEE)"
description: "Introductory tutorial on exploring AOP datasets in GEE."
dateCreated: 2022-04-14
authors: Bridget M. Hass, John Musinsky
contributors: Tristan Goulden, Lukas Straube
estimatedTime: 20 minutes
packagesLibraries: 
topics: lidar, hyperspectral, camera, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001, DP3.30010.001, DP3.30015.001 DP3.30024.001
code1: 
tutorialSeries: 
urlTitle: intro-aop-gee

---

<div id="ds-introduction" markdown="1">

Google Earth Engine (GEE) is a free and powerful cloud-computing platform for carrying out remote sensing and geospatial data analysis. In this tutorial, we introduce you to the NEON AOP datasets, which as of May 2023 are being added to Google Earth Engine. NEON is planning to eventually add the full archive of AOP L3 <a href="https://data.neonscience.org/data-products/DP3.30006.001" target="_blank">Surface Directional Reflectance</a>, <a href="https://data.neonscience.org/data-products/DP3.30024.001" target="_blank">LiDAR Elevation</a>, <a href="https://data.neonscience.org/data-products/DP3.30015.001" target="_blank">Ecosystem Structure</a>, and <a href="https://data.neonscience.org/data-products/DP3.30010.001" target="_blank">High-resolution orthorectified camera imagery</a>. We do not currently have a time estimate for when all of the AOP data will be added to GEE, but we are planning to ramp up data additions in the second half of 2023. Please stay tuned for a <a href="https://www.neonscience.org/data-samples/data-notifications" target="_blank"> Data Notification</a> in June 2023 which will more officially announce the plan for adding AOP data to the Google Earth Engine public datasets.

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will become familiar with:
 * The Google Earth Engine (GEE)
 * GEE Image Collections

And you will be able to:
 * Write and run basic JavaScript code in code editor 
 * Discover which NEON AOP datasets are available in GEE
 * Explore the NEON AOP GEE Image Collections

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * A basic understanding of the GEE code editor and the GEE JavaScript API.

## Additional Resources
If this is your first time using GEE, we recommend starting on the Google Developers website, and working through some of the introductory tutorials. The links below are good places to start.
 * <a href="https://developers.google.com/earth-engine/guides/getstarted" target="_blank"> Get Started with Earth-Engine  </a>
 * <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank"> GEE JavaScript Tutorial </a>

</div>

## AOP GEE Data Availability & Access (as of May 2023)

AOP has currently added a subset of AOP Level 3 (mosaicked) data products at 8 NEON sites (as of May 2023) on GEE. This data has been converted to Cloud Optimized GeoTIFF (COG) format. NEON L3 lidar and derived spectral indices are available in geotiff raster format, so are relatively straightforward to add to GEE, however the hyperspectral data is available in hdf5 (hierarchical data) format, and have been converted to the COG format prior to being added to GEE.

The NEON data products that have been made available on GEE can be currently be accessed through the `projects/neon-nonprod-earthengine` folder with an appended prefix of the Data Product ID, matching the IDs on the <a href="https://data.neonscience.org/data-products/explore" target="_blank"> NEON Data Portal</a>. The tables below summarizes the prefixes to use for each data product, and can be used as a reference for reading in AOP GEE datasets. You will see how to access and read in these data products in the next part of this lesson. 

| Acronym | Data Product      | Data Product ID (Prefix) |
|----------|------------|-------------------------|
| SDR | Surface Directional Reflectance | DP3-30006-001 |
| RGB | Red Green Blue (Camera Imagery) | DP3-30010-001 |
| DEM | Digital Surface and Terrain Models (DSM/DTM) | DP3-30024-001 |
| CHM | Ecosystem Structure (Canopy Height Model; CHM) | DP3-30015-001 |

The table below summarizes the sites, products, and years of NEON AOP data that can currently be accessed in GEE.

| Domain | Site(s) | Years(s)      | Data Products        |
|--------|------|------------|----------------------|
| D01 | HARV | 2016, 2019 | SDR, RGB, CHM, DSM, DTM |
| D07 | GRSM | 2016, 2017 | SDR, RGB, CHM, DSM, DTM |
| D14 | JORN | 2019, 2021 | SDR, RGB, CHM, DSM, DTM|
| D10 | CPER | 2020 | SDR, RGB, CHM, DSM, DTM|
| D16 | ABBY | 2021 | SDR, RGB, CHM, DSM, DTM|
| D17 | SJER, SOAP | 2019, 2021 | SDR, RGB, CHM, DSM, DTM |
| D19 | HEAL | 2019, 2021 | SDR, RGB, CHM, DSM, DTM |

## Get Started with Google Earth Engine

Once you have set up your Google Earth Engine account you can navigate to the <a href="https://code.earthengine.google.com/" target="_blank">Earth Engine Code Editor</a>. The diagram below, from the <a href="https://developers.google.com/earth-engine/guides/playground" target="_blank">Earth-Engine Playground</a>, shows the main components of the code editor. If you have used other programming languages such as R, Python, or Matlab, this should look fairly similar to other Integrated Development Environments (IDEs) you may have worked with. The main difference is that this has an interactive map at the bottom, similar to Google Maps and Google Earth. We encourage you to play around with the interactive map, or explore the ee documentation, linked above, to gain familiarity with the various features.

<figure>
	<a href="https://developers.google.com/earth-engine/images/Code_editor_diagram.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/1a_intro/code_editor_diagram.png" alt="Earth Engine Code Editor Components."></a>
</figure>

## Read AOP Data Collections into GEE using `ee.ImageCollection`

AOP data can be accessed through GEE through the `projects/neon-prod-earthengine/assets/` folder. In the remainder of this lesson, we will look at the four available AOP datasets, or `ImageCollection`s.

An <a href="https://developers.google.com/earth-engine/guides/ic_creating" target="_blank">ImageCollection</a> is simply a group of images. To find publicly available datasets (primarily satellite data), you can explore the Earth Engine <a href="https://developers.google.com/earth-engine/datasets" target="_blank">Data Catalog</a>. Currently, NEON AOP data cannot be discovered in the main GEE data catalog (this is coming soon!), so the following steps will walk you through how to find available AOP data.

In your code editor, copy and run the following lines of code to create 3 `ImageCollection` variables containing the Surface Directional Reflectance (SDR), Camera Imagery (RGB) and Digital Surface and Terrain Model (DEM) raster data sets. 

```javascript
//read in the AOP image collections as variables

var aopSDR = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30006-001')

var aopRGB = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30010-001') 

var aopCHM = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30015-001')

var aopDEM = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30024-001')
```

A few tips for the working in the Code Editor: 
- In the left panel of the code editor, there is a **Docs** tab which includes API documentation on built in functions, showing the expected input arguments. We encourage you to refer to this documentation, as well as the <a href="https://developers.google.com/earth-engine/tutorials/tutorial_js_01" target="_blank"> GEE JavaScript Tutorial</a> to familiarize yourself with GEE and the JavaScript programming language.
- If you have an error in your code, a red error message will show up in the Console (in the right panel), which tells you the line that failed.
- Save your code frequently! If you try to leave your code while it is unsaved, you will be prompted that there are unsaved changes in the editor.

When you Run the code above (by clicking on the **Run** above the code editor), you will notice that the lines of code become underlined in red, the same as you would see for a spelling error in most text editors. If you hover over each of the lines of codes, you will see a message pop up that says: "*variable_name* can be converted to an import record. Convert Ignore." 

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/aop_import_record_popup.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/aop_import_record_popup.png" alt="GEE Import Record Popup."></a>
</figure>

If you click `Convert`, the line of code will disappear and the variable will be imported into your session directly, and will show up at the top of the code editor. Go ahead and convert the variables for all three lines of code, so you should see the following. Tip: if you type Ctrl-z, you can re-generate the line of code, and the variable will still show up in the imported variables at the top of the editor. Generally it is recommended to retain the code that reads in each variable, for reproducibility. If you don't do this, and wish to share this code with someone else, or run the code outside of your current code editor, the imported variables will not be saved and any subsequent code referring to this variable will result in an error message.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/imported_sdr.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/imported_sdr.png" alt="Imported AOP Image Collections."></a>
</figure>

Note that each of these imported variables can now be expanded, using the arrow to the left of each. These variables now show associated information including *type*, *id*, and *version*. 

Information about the image collections can also be found in a slightly more user-friendly format if you click on the blue link `projects/neon-prod-earthengine/DP3-30006-001`. Below we'll show the window that pops-up when you click on `SDR` and select the **IMAGES** tab. We encourage you to look at all of the datasets similarly. Note: when the GEE datasets become public, you will be able to search for the NEON AOP image collections through the <a href="[https://data.neonscience.org/data-products/explore](https://developers.google.com/earth-engine/datasets)" target="_blank">Earth Engine Data Catalog</a>.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/sdr_asset_details_images.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/sdr_asset_details_images.png" alt="SDR Asset Details Description."></a>
</figure>

You can click on the **IMAGES** tab to explore all the available NEON images for that data product. Some of the text may be cut off in the default view, but if you click in one of the table values the table will expand. This table summarizes individual sites and years that are available for the SDR Image Collection. The ImageID provides the path to read in an individual image. 

Note that the images imported into GEE may have some slight differences from the data downloaded from the data portal. We highly encourage you to explore the description and associated documentation for the data products on the NEON data portal as well (eg. <a href="https://data.neonscience.org/data-products/DP3.30006.001" target="_blank">DP3.30006.001</a>) for relevant information about the data products, how they are generated, and other pertinent details.

## Display All Images in a Collection

Since we are rolling out the AOP data additions to GEE, the first thing you may want to do is see what datasets are currently available. A quick way to do this is using`.toList()`, as follows:

```javascript
// list all available images in the NEON Surface Directional Reflectance (SDR) image collection:
print('Images in the NEON SDR ImageCollection')
print(sdrCol.toList(20));
```

In the **Console** tab to the right of the code, you will see a list of all available images. Expand the box to see the full path. The names of the all the SDR images follow the format `YEAR_SITE_VISIT_SDR`, so you can identify the site and year of data this way. AOP typically visits each site 3 out of every 4 years, so the visit number indicates the number of times AOP has visited that site. In some cases, AOP may re-visit a site twice in the same year.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/sdr_image_list.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/sdr_image_list.PNG" alt="SDR Image List."></a>
</figure>

## Explore Image Properties

You can expand each image by clicking on the arrow to the left of the image name to explore the properties. These include additional metadata information about the properties, as well as information about each of the bands.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/sdr_image_properties_expanded.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/sdr_image_properties_expanded.PNG" alt="SDR Image Properties."></a>
</figure>


## Filter by Image Properties

Next, we can explore some filtering options to pull out individual images from an Image Collection. In the example shown below, we can filter by the date (`.filterDate`) by providing a date range, and filter by other properties using `.filterMetadata`.

```javascript
// read in a single SDR image at the NEON site SOAP in 2021
var sdrSOAP = ee.ImageCollection("projects/neon-prod-earthengine/assets/DP3-30006-001")
  .filterDate('2021-01-01', '2021-12-31') // filter by date - 2021
  .filterMetadata('NEON_SITE', 'equals', 'SOAP') // filter by site
  .first(); // select the first one to pull out a single image
```

## Display True Color Image

Lastly let's plot a true color image (red-green-blue or RGB composite) of the reflectance data that we've just read into the variable `sdrSOAP`. To do this, first we pull out the RGB bands, set visualization parameters, center the map over the site, and then add the map using `Map.addLayer`.

```javascript
// pull out the red, green, an dblue bands
var rgb = sdrSOAP.select(['B053', 'B035', 'B019']);

// set visualization parameters
var rgbVis = {min: 100, max: 2400, gamma: 0.8};

// center the map at the lat / lon of the site, set zoom to 12
Map.setCenter(-119.25, 37.06, 12);

// add this RGB layer to the Map and give it a title
Map.addLayer(rgb, rgbVis, 'SOAP 2021 RGB Camera Imagery');
```

When you run the code you should now see the map!

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/soap_sdr_rgb.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1a_intro_aop_gee/soap_sdr_rgb.PNG" alt="SOAP SDR RGB."></a>
</figure>

## A Quick Recap

You did it! You should now have a basic understanding of the GEE code editor and it's different components. You have also learned how to read a NEON AOP `ImageCollection` into a variable, import the variable into your code editor session, and navigate through the `ImageCollection` **Asset details** to find the path to an individual `Image`. Lastly, you learned to read in an individual SDR Image, and display a map of a True-Color Image (RGB composite).

It doesn't look like we've done much so far, but this is a already great achievement! With just a few lines of code, you can import an entire AOP hyperspectral data set, which in most other coding environments, is not as straightforward. One of the major challenges to working with AOP data (and reflectance data in particular) is it's large data volume, which requires high-performance computing environments to read in the data, visualize, and analyze it. There are also limited open-source tools for working with the data; many of the established software suites for working with hyperspectral data require licenses which can be expensive. In this lesson, we have loaded spectral data covering an entire site, and are ready for data exploration and analysis, in a free geospatial cloud-computing platform. 

## Get Lesson Code

<a href="https://code.earthengine.google.com/242c2abd066c28fd17777fc8603a3510" target="_blank">Into to AOP GEE Assets</a>
