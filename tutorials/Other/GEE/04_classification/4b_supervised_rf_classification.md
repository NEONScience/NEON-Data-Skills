---
syncID: 
title: "Supervised Classification - Random Forest"
description: "Classifying species using AOP and field data at CLBJ"
dateCreated: 2022-08-02
authors: John Musinsky, Bridget Hass
contributors: Tristan Goulden, Lukas Straube
estimatedTime: 1 hour
packagesLibraries: 
topics: lidar, hyperspectral, canopy height, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001, DP3.30015.001
code1: 
tutorialSeries: aop-gee
urlTitle: aop-gee-random-forest-classification

---

Google Earth Engine has a number of built in machine learning tools that are designed to work with multi-band raster data. This simplifies more complex analyses like classification. In this example, we will show an example of using TOS (Terrestrial Observational Data) woody vegetation data, which includes information about the plant species in the terrestrial sampling plots, to train a random forest machine learning model, over a larger area, using the AOP reflectance and ecosystem structure (CHM) data. We will demonstrate this at the site <a href="https://www.neonscience.org/field-sites/clbj" target="_blank">CLBJ</a>) (Lyndon B. Johnson National Grassland in north-central Texas).

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
 * Integrate NEON airborne (AOP) and field (TOS) datasets
 * Run the Random Forest Classifier in Google Earth Engine
 * Understand pre-processing steps required for supervised learning classification

## Requirements
 * A gmail (@gmail.com) account
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/new_signup/
 * An understanding of the GEE code editor and the GEE JavaScript API.
 * Optionally, complete the previous GEE tutorials in this tutorial series: 
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-tutorial" target="_blank">Intro to AOP Data in GEE</a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-sdr-tutorial" target="_blank">Introduction to AOP Hyperspectral Data in GEE</a>
    * <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-gee-functions" target="_blank">Intro to GEE Functions</a>

## Additional Resources
The links below to the earth engine guides may assist you as you work through this lesson.
 * <a href="https://developers.google.com/earth-engine/guides/classification" target="_blank"> Earth Engine Classification Guide </a>
 * <a href="https://developers.google.com/earth-engine/guides/machine-learning" target="_blank"> Earth Engine Machine Learning Guide </a>

</div>

## Machine Learning Workflow

In this tutorial, we will take you through the following steps to classify species at the NEON site CLBJ. Note that these steps closely align with the more general supervised classification steps, described in the <a href="https://developers.google.com/earth-engine/guides/classification" target="_blank"> Earth Engine Classification Guide </a>.

Workflow:
1. Specify the input data for display and use in analysis
2. Combine the AOP spectrometer reflectance data with the lidar-derived canopy height model (CHM) to create the predictor dataset
3. Create reference (training/test) data for plant species and land cover types based on NEON vegetation structure data
4. Fit a random forest model based on spectral/CHM composite to map the distribution of plant species at CLBJ
5. Evaluate the model accuracy 

Let's get started. In this first chunk of code, we'll specify the CLBJ location, read in the pre-processed woody vegetation data, as well as the TOS and Airshed boundaries.

The plant species data, contained in the CLBJ_veg_2017_filtered feature collection, was derived from the NEON woody plant vegetation structure data product (DP1.10098.001). Land cover classes (grassland, water, shade) were subsequently added to the Feature Collection from visual inspection of the NEON spectrometer reflectance data product (DP3.30006.001). 

```javascript
// Specify CLBJ location
var geo = ee.Geometry.Point([-97.5706464, 33.4045729])
// Load species/land cover samples feature collection to variable (originally a .csv file extracted from  NEON woody plant vegetation structure data product (DP1.10098.001))
var CLBJ_veg = ee.FeatureCollection('projects/neon/AOP_NEON_Plots/CLBJ_veg_2017_filtered')
// Load terrestrial observation system (TOS) boundary to a variable
var CLBJ_TOS = ee.FeatureCollection('projects/neon/AOP_TOS_Boundaries/D11_CLBJ_TOS_dissolve')
//Load tower airshed boundary to a variable
var CLBJ_Airshed = ee.FeatureCollection('projects/neon/Airsheds/CLBJ_90percent_footprint')
```

Next, display the Digital Terrain Model (DTM) and Canopy Height Model (CHM) from the 2017 CLBJ collection, masking out the no-data values (-9999). 

```javascript
// Display DTM for CLBJ. First, filter the DEM image collection by year, DEM type and geographic location
var CLBJ_DTM2017 = ee.ImageCollection('projects/neon/DP3-30024-001_DEM')
  .filterDate('2017-01-01', '2017-12-31')
  .filterMetadata('Type', 'equals', 'DTM')
  .filterBounds(geo)
  .first();
// Then mask out the no-data values (-9999) in the image and add to the map using a histogram stretch based on lower and upper data values
var CLBJ_DTM2017mask = CLBJ_DTM2017.updateMask(CLBJ_DTM2017.gte(0.0000));
Map.addLayer(CLBJ_DTM2017mask, {min:285, max:1294}, 'CLBJ DTM 2017',0);

// Display CHM for CLBJ. First, filter the DEM image collection by year, DEM type and geographic location
var CLBJ_CHM2017 = ee.ImageCollection('projects/neon/DP3-30024-001_DEM')
  .filterDate('2017-01-01', '2017-12-31')
  .filterMetadata('Type', 'equals', 'CHM')
  .filterBounds(geo)
  .first();
  
// Then mask out the no-data values (-9999) in the image and add to the map using a histogram stretch based on lower and upper data values
var CLBJ_CHM2017mask = CLBJ_CHM2017.updateMask(CLBJ_CHM2017.gte(0.0000));
Map.addLayer(CLBJ_CHM2017mask, {min:0, max:33}, 'CLBJ CHM 2017',0);
```

We also want to pull in the Surface Directional Reflectance (SDR) data. When we do this, we want to remove the water vapor bands. This code looks a little messy, but using the `.select` filter, we are pulling out all the "valid" bands. For more information on the water vapor bands, refer to the lesson ...

```javascript
// Display SDR image for CLBJ. First, filter the image collection by year, type and geographic location
// Then select all bands except water absorption bands (band195-band205 and band287-band310)
var CLBJ_SDR2017 = ee.ImageCollection('projects/neon/DP3-30006-001_SDR')
  .filterDate('2017-01-01', '2017-12-31')
  .filterBounds(geo)
  .first()
  .select('band001', 'band002', 'band003', 'band004', 'band005', 'band006', 'band007', 'band008', 'band009', 'band010', 'band011', 'band012', 'band013', 'band014', 'band015', 'band016', 'band017', 'band018', 'band019', 'band020', 'band021', 'band022', 'band023', 'band024', 'band025', 
  'band026', 'band027', 'band028', 'band029', 'band030', 'band031', 'band032', 'band033', 'band034', 'band035', 'band036', 'band037', 'band038', 'band039', 'band040', 'band041', 'band042', 'band043', 'band044', 'band045', 'band046', 'band047', 'band048', 'band049', 'band050', 'band051', 
  'band052', 'band053', 'band054', 'band055', 'band056', 'band057', 'band058', 'band059', 'band060', 'band061', 'band062', 'band063', 'band064', 'band065', 'band066', 'band067', 'band068', 'band069', 'band070', 'band071', 'band072', 'band073', 'band074', 'band075', 'band076', 'band077', 
  'band078', 'band079', 'band080', 'band081', 'band082', 'band083', 'band084', 'band085', 'band086', 'band087', 'band088', 'band089', 'band090', 'band091', 'band092', 'band093', 'band094', 'band095', 'band096', 'band097', 'band098', 'band099', 'band100', 'band101', 'band102', 'band103', 
  'band104', 'band105', 'band106', 'band107', 'band108', 'band109', 'band110', 'band111', 'band112', 'band113', 'band114', 'band115', 'band116', 'band117', 'band118', 'band119', 'band120', 'band121', 'band122', 'band123', 'band124', 'band125', 'band126', 'band127', 'band128', 'band129', 
  'band130', 'band131', 'band132', 'band133', 'band134', 'band135', 'band136', 'band137', 'band138', 'band139', 'band140', 'band141', 'band142', 'band143', 'band144', 'band145', 'band146', 'band147', 'band148', 'band149', 'band150', 'band151', 'band152', 'band153', 'band154', 'band155', 
  'band156', 'band157', 'band158', 'band159', 'band160', 'band161', 'band162', 'band163', 'band164', 'band165', 'band166', 'band167', 'band168', 'band169', 'band170', 'band171', 'band172', 'band173', 'band174', 'band175', 'band176', 'band177', 'band178', 'band179', 'band180', 'band181', 
  'band182', 'band183', 'band184', 'band185', 'band186', 'band187', 'band188', 'band189', 'band190', 'band191', 'band192', 'band193', 'band194', 'band206', 'band207', 'band208', 'band209', 'band210', 'band211', 'band212', 'band213', 'band214', 'band215', 'band216', 'band217', 'band218', 
  'band219', 'band220', 'band221', 'band222', 'band223', 'band224', 'band225', 'band226', 'band227', 'band228', 'band229', 'band230', 'band231', 'band232', 'band233', 'band234', 'band235', 'band236', 'band237', 'band238', 'band239', 'band240', 'band241', 'band242', 'band243', 'band244', 
  'band245', 'band246', 'band247', 'band248', 'band249', 'band250', 'band251', 'band252', 'band253', 'band254', 'band255', 'band256', 'band257', 'band258', 'band259', 'band260', 'band261', 'band262', 'band263', 'band264', 'band265', 'band266', 'band267', 'band268', 'band269', 'band270', 
  'band271', 'band272', 'band273', 'band274', 'band275', 'band276', 'band277', 'band278', 'band279', 'band280', 'band281', 'band282', 'band283', 'band284', 'band285', 'band286', 'band311', 'band312', 'band313', 'band314', 'band315', 'band316', 'band317', 'band318', 'band319', 'band320', 
  'band321', 'band322', 'band323', 'band324', 'band325', 'band326', 'band327', 'band328', 'band329', 'band330', 'band331', 'band332', 'band333', 'band334', 'band335', 'band336', 'band337', 'band338', 'band339', 'band340', 'band341', 'band342', 'band343', 'band344', 'band345', 'band346', 
  'band347', 'band348', 'band349', 'band350', 'band351', 'band352', 'band353', 'band354', 'band355', 'band356', 'band357', 'band358', 'band359', 'band360', 'band361', 'band362', 'band363', 'band364', 'band365', 'band366', 'band367', 'band368', 'band369', 'band370', 'band371', 'band372', 
  'band373', 'band374', 'band375', 'band376', 'band377', 'band378', 'band379', 'band380', 'band381', 'band382', 'band383', 'band384', 'band385', 'band386', 'band387', 'band388', 'band389', 'band390', 'band391', 'band392', 'band393', 'band394', 'band395', 'band396', 'band397', 'band398', 
  'band399', 'band400', 'band401', 'band402', 'band403', 'band404', 'band405', 'band406', 'band407', 'band408', 'band409', 'band410', 'band411', 'band412', 'band413', 'band414', 'band415', 'band416', 'band417', 'band418', 'band419', 'band420', 'band421', 'band422', 'band423', 'band424', 
  'band425', 'band426');
  
print(CLBJ_SDR2017)
// Mask out the no-data values (-9999) in the image and add to the map using a histogram stretch based on lower and upper data values
var CLBJ_SDR2017mask = CLBJ_SDR2017.updateMask(CLBJ_SDR2017.gte(0.0000)).select(['band053', 'band035', 'band019']);
Map.addLayer(CLBJ_SDR2017mask, {min:.5, max:10}, 'CLBJ SDR 2017', 0);
```

Next we can combine the SDR bands (391 after we removed the water vapor bands) and the CHM band to create a composite multi-band raster that will become our predictor variable (what we use to generate the random forest classification model). We can then crop this to the tower airshed boundary so we can start with a smaller area. This will speed up the process considerably. Optionally, you could classify the full airshed - this code is commented out, if you want to try this instead.

```javascript
//Combine the SDR (391 bands) and CHM (1 band) for classification
var composite = CLBJ_SDR2017.addBands(CLBJ_CHM2017mask).aside(print, 'Composite SDR and CHM image');

//Crop the reflectance image/CHM composite to the NEON tower airshed boundary and add to the map
var CLBJ_SDR2017_airshed = composite.clip(CLBJ_Airshed) // comment if uncommenting next line of code
//var CLBJ_SDR2017_airshed = composite // uncomment to classify entire SDR scene
Map.addLayer(CLBJ_SDR2017_airshed, {bands:['band053', 'band035', 'band019'], min:.5, max:10}, 'CLBJ-Airshed SDR/CHM 2017');
```

The next chunk of code just displays the TOS and Airshed polygon layers, and prints some details about the NEON vegetation structure data to the Console.

```
// Display the TOS boundary polygon layer
Map.addLayer(CLBJ_TOS.style({width: 3, color: "blue", fillColor: "#00000000"}),{},"CLBJ TOS", 0)

// Display the Airshed polygon layer
Map.addLayer(CLBJ_Airshed.style({width: 3, color: "white", fillColor: "#00000000"}),{},"CLBJ Airshed", 0)

// Print details about the NEON vegetation structure Feature Collection to the Console
print(CLBJ_veg, 'All woody plant samples')
```

This next chunk of code pulls out the variables for each species (by their taxon ID), and adds a layer for each of the species training data variables.

```javascript
var CLBJ_QUMA3 = CLBJ_veg.filter(ee.Filter.inList('taxonID', ['QUMA3']))
Map.addLayer(CLBJ_QUMA3, {color: 'orange'}, 'Blackjack oak', 0);

var CLBJ_QUST = CLBJ_veg.filter(ee.Filter.inList('taxonID', ['QUST']))
Map.addLayer(CLBJ_QUST, {color: 'darkgreen'}, 'Post oak', 0);

var CLBJ_ULAL = CLBJ_veg.filter(ee.Filter.inList('taxonID', ['ULAL']))
Map.addLayer(CLBJ_ULAL, {color: 'cyan'}, 'Winged elm', 0);

var CLBJ_ULCR = CLBJ_veg.filter(ee.Filter.inList('taxonID', ['ULCR']))
Map.addLayer(CLBJ_ULCR, {color: 'purple'}, 'Cedar elm', 0);

var CLBJ_GRSS = CLBJ_veg.filter(ee.Filter.inList('taxonID', ['GRSS']))
Map.addLayer(CLBJ_GRSS, {color: 'lightgreen'}, 'Grassland', 0);

var CLBJ_WATR = CLBJ_veg.filter(ee.Filter.inList('taxonID', ['WATR']))
Map.addLayer(CLBJ_WATR, {color: 'blue'}, 'Water', 0);

var CLBJ_SHADE = CLBJ_veg.filter(ee.Filter.inList('taxonID', ['SHADE']));
Map.addLayer(CLBJ_SHADE, {color: 'black'}, 'Shade', 0);
```

```javascript
// Create training and test subsets for each class (i.e., species types) using stratified random sampling (80/20%)

var new_table = CLBJ_CELA.randomColumn({seed: 1});
var CELAtraining = new_table.filter(ee.Filter.lt('random', 0.80));
var CELAtest = new_table.filter(ee.Filter.gte('random', 0.80));

var new_table = CLBJ_JUVI.randomColumn({seed: 1});
var JUVItraining = new_table.filter(ee.Filter.lt('random', 0.80));
var JUVItest = new_table.filter(ee.Filter.gte('random', 0.80));

var new_table = CLBJ_PRME.randomColumn({seed: 1});
var PRMEtraining = new_table.filter(ee.Filter.lt('random', 0.80));
var PRMEtest = new_table.filter(ee.Filter.gte('random', 0.80));

var new_table = CLBJ_QUMA3.randomColumn({seed: 1});
var QUMA3training = new_table.filter(ee.Filter.lt('random', 0.80));
var QUMA3test = new_table.filter(ee.Filter.gte('random', 0.80));

var new_table = CLBJ_QUST.randomColumn({seed: 1});
var QUSTtraining = new_table.filter(ee.Filter.lt('random', 0.80));
var QUSTtest = new_table.filter(ee.Filter.gte('random', 0.80));

var new_table = CLBJ_ULAL.randomColumn({seed: 1});
var ULALtraining = new_table.filter(ee.Filter.lt('random', 0.80));
var ULALtest = new_table.filter(ee.Filter.gte('random', 0.80));

var new_table = CLBJ_ULCR.randomColumn({seed: 1});
var ULCRtraining = new_table.filter(ee.Filter.lt('random', 0.80));
var ULCRtest = new_table.filter(ee.Filter.gte('random', 0.80));

var new_table = CLBJ_GRSS.randomColumn({seed: 1});
var GRSStraining = new_table.filter(ee.Filter.lt('random', 0.80));
var GRSStest = new_table.filter(ee.Filter.gte('random', 0.80));

var new_table = CLBJ_WATR.randomColumn({seed: 1});
var WATRtraining = new_table.filter(ee.Filter.lt('random', 0.80));
var WATRtest = new_table.filter(ee.Filter.gte('random', 0.80));

var new_table = CLBJ_SHADE.randomColumn({seed: 1});
var SHADEtraining = new_table.filter(ee.Filter.lt('random', 0.80));
var SHADEtest = new_table.filter(ee.Filter.gte('random', 0.80));
```

## Get Lesson Code

<a href="https://code.earthengine.google.com/318a84edf5bdc816d4eb05c9fc2092d4" target="_blank">AOP GEE Random Forest Classification</a>
