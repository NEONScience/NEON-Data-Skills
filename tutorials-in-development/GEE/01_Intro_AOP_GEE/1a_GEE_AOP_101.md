# AOP Data in Google Earth Engine (GEE) 101
### This lesson is the starting point for working with AOP data in GEE!

---

Author: Bridget Hass

Contributors: John Musinsky, Tristan Goulden, Lukas Straube

Last Updated: April 13, 2022

Objectives
---
- Introduce the Google Earth Engine (GEE) code editor 
- See which NEON AOP datasets are available in GEE
- Learn how to access the NEON AOP GEE datasets

Requirements
---
-	A gmail (@gmail.com) and Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
-	A basic understanding of the GEE code editor and the GEE JavaScript API. If you have never used GEE before, we recommend starting on the [google developers earth-engine page](https://developers.google.com/earth-engine/guides/getstarted) and working through some of the introductory tutorials.

Background
---
AOP has published a subset of AOP (L3) data products at 6 NEON sites (as of April 2022) on GEE. This data has been converted to Cloud Optimized Geotif (COG) format. NEON L3 lidar and derived spectral indices are avaialable in geotif raster format, so are relatively easy to add to GEE, however the hyperspectral data is available in hdf5 (hierarchical data format), and have been converted to the COG format prior to being added to GEE. 

To interactively explore NEON data available on GEE, you can use the [aop-data-visualization](https://neon-aop.users.earthengine.app/view/aop-data-visualization) app created by AOP Scientist John Musinsky. 

Data Availability & Access
---
The NEON data products that have been made available on GEE can be accessed through the `projects/neon` folder with an appended prefix of the Data Product ID, matching the [NEON data portal](https://data.neonscience.org/data-products/explore). The table below summarizes the prefixes to use for each data product. You will see how to access and read in these data products in the first part of this tutorial, so you may come back to this table if you wish to read in a different dataset.

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

Get Started with Google Earth Engine
---

Once you have set up your Google Earth Engine account you can navigate to the [earth engine code editor](https://code.earthengine.google.com/). The diagram below, from the [earth engine documentation](https://developers.google.com/earth-engine/guides/playground), shows the main components of the code editor. If you have used other programming languages such as R, Python, or Matlab, this should look fairly similar to other Integrated Development Environments (IDEs) you may have worked with. The main difference is that this has an interactive map at the bottom, similar to Google Maps / Google Earth. This editor is fairly intuitive; we encourage you to play around with the interactive map, or explore the ee documentation, linked above, to gain familiarity with the various features.

![Earth Engine Code Editor Components](Code_editor_diagram.png)


Read AOP Data into GEE using `ee.ImageCollection`
---

AOP data can be accessed through GEE through the `projects/NEON` folder. In the remainder of this lesson, we will look at the three AOP datasets, or `ImageCollection`s in this folder.

An [ImageCollection](https://developers.google.com/earth-engine/guides/ic_creating) is a stack of images. To find publicly available datasets (primarily satellite data), you can explore the Earth Engine [data catalog](https://developers.google.com/earth-engine/datasets). Currently, NEON AOP data in GEE cannot be discovered in the main data catalog, so the next steps will walk you through how you can find available AOP data.

In your code editor, copy and run the following lines of code to create 3 `ImageCollection` variables containing the Surface Directional Reflectance (SDR), Camera Imagery (RGB) and Digital Surface and Terrain Model (DEM) raster data sets. 

```javascript
//read in the AOP image collections as variables

var aopSDR = ee.ImageCollection('projects/neon/DP3-30006-001_SDR')

var aopRGB = ee.ImageCollection('projects/neon/DP3-30010-001_RGB') 

var aopDEM = ee.ImageCollection('projects/neon/DP3-30024-001_DEM')
```

When you enter that code, you will notice that the lines of code are underlined in red, the same as you would see for a spelling error in most text editors. If you hover over each of the lines of codes, you will see a message pop up that says: `<variable> can be converted to an import record. Convert Ignore`. 

![Import_Record_Popup](Import_Record_Popup.png)

If you click `Convert`, the line of code will disappear and instead the variable will be pulled into the script directly, and will show up at the top of the code editor. Go ahead and do this for all three lines of code, so you should see the following. Tip: if you type Ctrl-z, you can re-generate the line of code, and the variable will still show up in the imported variables at the top of the editor. It is a good idea to retain the original code that reads in the variable, for reproducibility. If you don't do this, and wish to share this code with someone else, or run the code outside of your own code editor, the imported variables will not be saved.

![AOP_ImageCollections_Imported](AOP_ImageCollections_Imported.png)

Note that each of these imported variables can now be expanded, using the arrow to the left of each. They have associated information *type*, *id*, *version*, and *properties*, which if you expand, shows a *description*. This provides more detailed information of the GEE data product.

Information about the image collections can also be found in a slightly more user-friendly format if you click on the blue `projects/neon/DP3-30006-001_SDR`, as well as `DP3-30010-001_RGB` and`DP3-30024-001_DEM`, respectively. Below we'll show the window that pops-up when you click on `SDR`, but we encourage you to look at all three datasets.

![SDR_AssetDetails_Description](SDR_AssetDetails_Description.png)

This allows you to read the full description in a more user-friendly format. Note that the images imported into GEE may have some slight differences from the data downloaded from the data portal. For example, note that the reflectance data in GEE is scaled by 100. We highly encourage you to explore the description and associated documentation for the data products on the NEON data portal as well (eg. [DP3.30006.001](https://data.neonscience.org/data-products/DP3.30006.001)) for relevant information about the data products, how they are generated, and other pertinent details.

You can also click on the "IMAGES" to explore all the available images. Some of the text may be cut off in the default view, but if you click in one of the table values the table will expand. Here you can see the individual sites and years that are available for that data product. 

![SDR_AssetDetails_Images](SDR_AssetDetails_Images.png)






