---
syncID: b968a912e3ea4557b2a7185cd2340069
title: "Random Forest Species Classification using AOP and TOS data in GEE"
description: "Classifying species using AOP and observational field data at CLBJ"
dateCreated: 2022-08-02
authors: John Musinsky, Bridget Hass
contributors: Tristan Goulden
estimatedTime: 1 hour
packagesLibraries: 
topics: lidar, hyperspectral, canopy height, remote-sensing, woody vegetation
languageTool: GEE
dataProduct: DP1.10098.001, DP3.30006.001, DP3.30015.001
code1: 
tutorialSeries: aop-gee
urlTitle: aop-gee-random-forest-classification

---

Google Earth Engine has a number of built in machine learning tools that are designed to work with multi-band raster data. This simplifies more complex analyses like classification (eg. classifying land types or species). In this example, we demonstrate species classification using a random forest machine learning model, using NEON AOP reflectance and ecosystem structure (CHM) data, and TOS (Terrestrial Observation System) woody vegetation data to train the model. For this example, we'll use airshed boundary of the site <a href="https://www.neonscience.org/field-sites/clbj" target="_blank">CLBJ</a> (Lyndon B. Johnson National Grassland in north-central Texas).

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to integrate NEON airborne (AOP) and field (TOS) datasets to run supervised classification, which requires:
 * Understanding pre-processing steps required for supervised learning classification
 * Splitting data into train and test data sets
 * Running the Random Forest machine learning model in Google Earth Engine
 * Assessing model performance and learn what the different accuracy metrics can tell you

## Requirements
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/register/
 * An understanding of the GEE code editor and the GEE JavaScript API.
 * Optionally, complete the first three GEE tutorials in this tutorial series: <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-data-google-earth-engine-tutorial-series" target="_blank">Intro to AOP Data in Google Earth Engine Tutorial Series</a>

## Additional Resources
The links below to the earth engine guides may assist you as you work through this lesson.
 * <a href="https://developers.google.com/earth-engine/guides/classification" target="_blank"> Earth Engine Classification Guide </a>
 * <a href="https://developers.google.com/earth-engine/guides/machine-learning" target="_blank"> Earth Engine Machine Learning Guide </a>

</div>

## Random Forest Machine Learning Workflow

In this tutorial, we will take you through the following steps to classify species at the NEON site CLBJ. Note that these steps closely align with the more general supervised classification steps, described in the <a href="https://developers.google.com/earth-engine/guides/classification" target="_blank"> Earth Engine Classification Guide </a>.

Workflow Steps:
1. Specify the input data for display and use in analysis
2. Combine the AOP spectrometer reflectance data with the lidar-derived canopy height model (CHM) to create the predictor dataset
3. Create reference (training/test) data for plant species and land cover types based on NEON vegetation structure data
4. Fit a random forest model based on spectral/CHM composite to map the distribution of plant species at CLBJ
5. Evaluate the model accuracy 

## Load in and Display the AOP and TOS Data

We'll start by reading in and displaying Map layers of NEON AOP and TOS woody vegetation data. In this first chunk of code, we'll specify the CLBJ location, read in the pre-processed woody vegetation data, as well as the TOS and Airshed boundaries. Details about these boundaries are described on the NEON <a href="https://www.neonscience.org/data-collection/flight-box-design" target="_blank"> Flight Box Design </a> webpage.

The plant species data, contained in the `CLBJ_veg_2017_filtered` feature collection, was derived from the NEON woody plant vegetation structure data product (DP1.10098.001). Land cover classes (grassland, water, shade) were subsequently added to the Feature Collection from visual inspection of the NEON spectrometer reflectance data product (DP3.30006.001). 

```javascript
// Specify CLBJ location
var geo = ee.Geometry.Point([-97.5706464, 33.4045729])
// Load species/land cover samples feature collection to variable (originally a .csv file extracted from  NEON woody plant vegetation structure data product (DP1.10098.001))
var clbj_veg = ee.FeatureCollection('projects/neon/AOP_NEON_Plots/CLBJ_veg_2017_filtered')
// Load terrestrial observation system (TOS) boundary to a variable
var clbj_tos = ee.FeatureCollection('projects/neon/AOP_TOS_Boundaries/D11_CLBJ_TOS_dissolve')
// Load tower airshed boundary to a variable
var clbj_airshed = ee.FeatureCollection('projects/neon/Airsheds/CLBJ_90percent_footprint')
```

Next, display the Canopy Height Model (`CHM/001`) from the 2017 CLBJ collection.

```javascript
// Read in Canopy Height Model (CHM) for CLBJ. 
var clbj_chm2017 = ee.ImageCollection('projects/neon-prod-earthengine/assets/CHM/001')
  .filterDate('2017-01-01', '2017-12-31')
  .filterBounds(geo)
  .first();
  
// Add CHM to the map using a histogram stretch based on min and max CHM values
Map.addLayer(clbj_chm2017, {min:0, max:33}, 'CLBJ CHM 2017',0);
```

We also want to pull in the Surface Directional Reflectance data . When we do this, we want to keep only the valid bands. Water vapor absorbs light between wavelengths 1340-1445 nm and 1790-1955 nm, and the atmospheric correction that converts radiance to reflectance subsequently results in spikes in reflectance in these two band windows. For more information on the water vapor bands, refer to the lesson <a href="https://www.neonscience.org/resources/learning-hub/tutorials/plot-spec-sig-tiles-python" target="_blank">Plot Spectral Signatures in Python</a>. We will also remove the last 10 bands, as the bands in this region also tend to be noisy.

To remove bands in GEE, you can specify the bands to exclude (here we named this `bands_to_remove`) and use the `.removeAll` function to keep only the valid bands. Note we are including as much spectral information as possible for this tutorial, but you could select a smaller subset of bands and likely obtain similar results. We encourage you to test this out on your own. When running the classification on a larger area, it may be a worthwhile trade-off to include a smaller number of bands so the code runs faster (or doesn't run out of memory).  

```javascript
// Read in Surface Directional Reflectance (HSI_REFL/001) image for CLBJ
var clbj_sdr2017 = ee.ImageCollection('projects/neon-prod-earthengine/assets/HSI_REFL/001')
  .filterDate('2017-01-01', '2017-12-31')
  .filterBounds(geo)
  .first()

// Display the reflectance band names
var band_names = clbj_sdr2017.bandNames()
print('Band Names',band_names)

// Remove the "bad" bands - these are the water vapor absorption bands (B195 - B20 and B287 - B310)
// If you look at the data for these bands, you will see these are all set to the same value of -100.
// Also remove the last 10 bands (B416-B425), as those tend to be noisy. 
var bands_to_remove = ['B195','B196','B197','B198','B199','B200','B201','B202','B203','B204','B205,',
                       'B287','B288','B289','B290','B291','B292','B293','B294','B295','B296','B297','B298',
                       'B299','B300','B301','B302','B303','B304','B305','B306','B307','B308','B309','B310',
                       'B416','B417','B418','B419','B420','B421','B422','B423','B424','B425']

// Select the inverse of the bad bands to include only the valid bands
var bands_to_keep = band_names.removeAll(bands_to_remove)
var clbj_sdr2017_subset = clbj_sdr2017.select(bands_to_keep)

print('CLBJ SDR 2017 Valid Band Subset')
print(clbj_sdr2017_subset)

// Add the reflectance layer to the map using a min max values (histogram stretch) based on lower and upper reflectance values
Map.addLayer(clbj_sdr2017, {bands:['B053', 'B035', 'B019'], min: 150, max: 850}, 'CLBJ SDR 2017', 0);
```

## Combine Subset Reflectance and CHM bands
Next we can combine the reflectance bands (381 after we removed the water vapor bands and the last 10 bands) and the CHM band to create a composite multi-band raster that will become our predictor variable (what we use to generate the random forest classification model). We can then crop this to the tower airshed boundary so we can work with a smaller area. This will speed up the process considerably. Optionally, you could classify the full airshed - this code is commented out, if you want to try that instead.

```javascript
// Combine the reflectance valid data (381 bands) and CHM (1 band) to use in classification
var clbj_sdr_chm2017 = clbj_sdr2017_subset.addBands(clbj_chm2017).aside(print, 'Composite SDR and CHM image');

// Crop the reflectance image/CHM composite to the NEON tower airshed boundary and add to the map
var clbj_sdr_chm_airshed = clbj_sdr_chm2017.clip(clbj_airshed) // comment if uncommenting next line of code
// var clbj_sdr_chm_airshed = clbj_sdr_chm2017 // uncomment to classify entire reflectance scene, and comment the line above
Map.addLayer(clbj_sdr_chm_airshed, {bands:['B053', 'B035', 'B019'], min: 150, max: 850}, 'CLBJ-Airshed Reflectance + CHM 2017');
```

## Display Woody Vegetation Data

The next chunk of code just displays the TOS and Airshed polygon layers, and prints some details about the NEON vegetation structure data to the Console.

```javascript
// Display the TOS boundary polygon layer
Map.addLayer(clbj_tos.style({width: 3, color: "blue", fillColor: "#00000000"}),{},"CLBJ TOS", 0)

// Display the Airshed polygon layer
Map.addLayer(clbj_airshed.style({width: 3, color: "white", fillColor: "#00000000"}),{},"CLBJ Airshed", 0)
Map.centerObject(clbj_airshed)

// Print details about the NEON vegetation structure Feature Collection to the Console
// Plant species data were derived from the NEON woody plant vegetation structure data product (DP1.10098.001)
// Land cover classes (grassland, water, shade) were subsequently added to the Feature Collection by visually 
// inspecting the NEON spectrometer reflectance data product (DP3.30006.001)
print(clbj_veg, 'All woody plant samples')
```

If you have run all the code so far, you should be able to see the following layers in the map. Expand the variables printed to the console to make sure the # of bands are correct, and the "bad" (water vapor / noisy) bands are removed.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/4b_supervised_classification/added_layers.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/4b_supervised_classification/added_layers.png" alt="Classified airshed map"></a>
</figure>

## Create Training Data Variables

Now that we've added the relevant AOP data, let's start preparing the training data, which we read in at the beginning of the script to the variable `clbj_veg`.
This next chunk of code pulls out each species into separate variables (by their taxon ID), and adds a layer to the Map for each of these variables. For more details about each taxa, refer to the USDA plant profile page for each, e.g. CELA: https://plants.sc.egov.usda.gov/plant-profile/CELA.

```javascript
// Filter to pull out the individual species recorded at CLBJ
var cela = clbj_veg.filter(ee.Filter.inList('taxonID', ['CELA']))
// print('CELA', cela)
Map.addLayer(cela, {color: 'yellow'}, 'Sugarberry', 0);

var juvi = clbj_veg.filter(ee.Filter.inList('taxonID', ['JUVI']))
// print('JUVI', juvi)
Map.addLayer(juvi, {color: 'white'}, 'Eastern red cedar', 0);

var prme = clbj_veg.filter(ee.Filter.inList('taxonID', ['PRME']))
// print('PRME', prme)
Map.addLayer(prme, {color: 'green'}, 'Mexican plum', 0);

var quma3 = clbj_veg.filter(ee.Filter.inList('taxonID', ['QUMA3']))
//print('QUMA3', quma3)
Map.addLayer(quma3, {color: 'orange'}, 'Blackjack oak', 0);

var qust = clbj_veg.filter(ee.Filter.inList('taxonID', ['QUST']))
// print('QUST', qust)
Map.addLayer(qust, {color: 'darkgreen'}, 'Post oak', 0);

var ulal = clbj_veg.filter(ee.Filter.inList('taxonID', ['ULAL']))
// print('ULAL', ulal)
Map.addLayer(ulal, {color: 'cyan'}, 'Winged elm', 0);

var ulcr = clbj_veg.filter(ee.Filter.inList('taxonID', ['ULCR']))
// print('ULCR', ulcr)
Map.addLayer(ulcr, {color: 'purple'}, 'Cedar elm', 0);

var grass = clbj_veg.filter(ee.Filter.inList('taxonID', ['GRSS']))
// print('GRASS', grass)
Map.addLayer(grass, {color: 'lightgreen'}, 'Grassland', 0);

var water = clbj_veg.filter(ee.Filter.inList('taxonID', ['WATR']))
// print('WATER', water)
Map.addLayer(water, {color: 'blue'}, 'Water', 0);

var shade = clbj_veg.filter(ee.Filter.inList('taxonID', ['SHADE']));
// print('SHADE', shade)
Map.addLayer(shade, {color: 'black'}, 'Shade', 0);
```

## Train/Test Split

Once we have the training data for each species, we can split the data for each species into training and test data, using an 80/20 split. The training data will be used later on to train the random forest model, and the test data is used to test the accuracy of the model results on an independent data set.

```javascript
// Create training and test subsets for each class (i.e., species types) using stratified random sampling (80/20%)
// Filter.lt means less than and Filter.gte means greater than or equal
// uncomment the print statements to display each of the training samples

var cela_random = cela.randomColumn({seed: 1});
var cela_train = cela_random.filter(ee.Filter.lt('random', 0.80));
var cela_test = cela_random.filter(ee.Filter.gte('random', 0.80));
// print('Sugarberry training samples', cela_train)

var juvi_random = juvi.randomColumn({seed: 1});
var juvi_train = juvi_random.filter(ee.Filter.lt('random', 0.80));
var juvi_test = juvi_random.filter(ee.Filter.gte('random', 0.80));
// print('Eastern Red Cedar training samples', juvi_train)

var prme_random = prme.randomColumn({seed: 1});
var prme_train = prme_random.filter(ee.Filter.lt('random', 0.80));
var prme_test = prme_random.filter(ee.Filter.gte('random', 0.80));
// print('Mexican Plum training samples', prme_train)

var quma3_random = quma3.randomColumn({seed: 1});
var quma3_train = quma3_random.filter(ee.Filter.lt('random', 0.80));
var quma3_test = quma3_random.filter(ee.Filter.gte('random', 0.80));
// print('Blackjack Oak training samples', quma3_train)

var qust_random = qust.randomColumn({seed: 1});
var qust_train = qust_random.filter(ee.Filter.lt('random', 0.80));
var qust_test = qust_random.filter(ee.Filter.gte('random', 0.80));
// print('Post Oak training samples', qust_train)

var ulal_random = ulal.randomColumn({seed: 1});
var ulal_train = ulal_random.filter(ee.Filter.lt('random', 0.80));
var ulal_test = ulal_random.filter(ee.Filter.gte('random', 0.80));
// print('Winged Elm training samples', ulal_train)

var ulcr_random = ulcr.randomColumn({seed: 1});
var ulcr_train = ulcr_random.filter(ee.Filter.lt('random', 0.80));
var ulcr_test = ulcr_random.filter(ee.Filter.gte('random', 0.80));
// print('# of Cedar Elm training samples', ulcr_train)

var grass_random = grass.randomColumn({seed: 1});
var grass_train = grass_random.filter(ee.Filter.lt('random', 0.80));
var grass_test = grass_random.filter(ee.Filter.gte('random', 0.80));
// print('Grassland training samples', grass_train)

var water_random = water.randomColumn({seed: 1});
var water_train = water_random.filter(ee.Filter.lt('random', 0.80));
var water_test = water_random.filter(ee.Filter.gte('random', 0.80));
// print('Water training samples', water_train)

var shade_random = shade.randomColumn({seed: 1});
var shade_train = shade_random.filter(ee.Filter.lt('random', 0.80));
var shade_test = shade_random.filter(ee.Filter.gte('random', 0.80));
// print('Shade training samples', shade_train)
```

Now we can merge all the training data for each species together to create the `training` data (variable), and similarly merge the test data to create the full `test` data. From those data we'll create a `Features` variable containing the predictor data (from the spectral and CHM composite) for the training data.

```javascript
// Combine species-type reference points for training and test partitions
var training = (cela_train).merge(juvi_train).merge(prme_train).merge(quma3_train).merge(qust_train).merge(ulal_train).merge(ulcr_train).merge(grass_train).merge(water_train).merge(shade_train).aside(print, 'Training partition');
var test = (cela_test).merge(juvi_test).merge(prme_test).merge(quma3_test).merge(qust_test).merge(ulal_test).merge(ulcr_test).merge(grass_test).merge(water_test).merge(shade_test).aside(print, 'Test partition');
var all_points = training.merge(test).aside(print,'All points');

// Extract spectral signatures from airshed reflectance/CHM image for training sample based on taxon ID 
var Features = clbj_sdr_chm_airshed.sampleRegions({
  collection: training,
  properties: ['taxonIDnum'],
  scale: 1,
  tileScale:16
});
print('Features with spectral signatures:', Features)
```

## Generate and Apply the Random Forest Model

Now that we've assembled the training and test data, and generated predictor data for all of the training data, we can train our random forest model to creat the `trainedClassifier` variable, and apply it to the reflectance-CHM composite data covering the airshed using `.classify(trainedClassifier)`. Generating the random forest model is pretty simple, once everything is set up!

```javascript
// Train a 100-tree random forest classifier based on spectral signatures from the training sample for each species 
var trained_classifier = ee.Classifier.smileRandomForest(100)
.train({
  features: Features,
  classProperty: 'taxonIDnum',
  inputProperties: clbj_sdr_chm_airshed.bandNames()
});

// Classify the combined reflectance-CHM image from the trained classifier
var classified = clbj_sdr_chm_airshed.classify(trained_classifier);
```

## Assess Model Performance

Next we can assess the performance of this classificiation, by looking at some different metrics. The train accuracy should be high (close to 1, or 100%), as it is testing the performance on the data used to generate the model - however, it is not an accurate representation of the actual accuracy. Instead, the test accuracy tends to be a little more reliable, as it is an independent assessment on the separate (test) data set.

```javascript
// Accuracy Assessment
// Calculate a confusion matrix and overall accuracy for the training sample
// Note that this overestimates the accuracy of the model since it does not consider the test sample
var train_accuracy = trained_classifier.confusionMatrix().accuracy();
print('Train Accuracy', train_accuracy);
```

If you look at the console, you should see a train accuracy of 0.973, pretty good! But we expect this to be good, because we are calculating the accuracy of the samples we used to generate the model. It is not representative of the actual model accuracy.

We can also look at some other accuracy metrics. We won't go into details on each of these, but highlight some of the main takeaways for each of the metrics. For more information on accuracy assessments, you can also refer to <a href="https://blog.gishub.org/earth-engine-tutorial-33-performing-accuracy-assessment-for-image-classification" target="_blank"> Qiusheng Wu's Accuracy Assessment for Image Classification Tutorial</a>

- **Confusion Matrix**: 2D matrix for a classifier based on its training data, where Axis 0 of the matrix corresponds to the input classes (reference data), and axis 1 corresponds to the output classes (classified data). The rows and columns start at class 0 and increase sequentially up to the maximum class value.
- **Overall Accuracy**: conveys what proportion were mapped correctly out of all of the reference sites (includes training and test data)
- **Kappa Coefficient**: evaluates how well a classification performs as compared to randomly assigning classes
- **Producer's Accuracy**: frequency with which a real feature on the ground is correctly shown in the classified map (corresponds to error of omission)
- **User's Accuracy**: frequency with which a feature in the classified map will actually be present on the ground (corresponds to error of commission)

```javascript
// Test the classification accuracy (more reliable estimation of accuracy)
// Extract spectral signatures from airshed reflectance image for test sample
var test = clbj_sdr_chm_airshed.sampleRegions({
  collection: test,
  properties: ['taxonIDnum'],
  scale: 1,
  tileScale: 16
});

// Calculate different test accuracy estimates
var test_classification = test.classify(trained_classifier);
print('Confusion Matrix', test_classification.errorMatrix('taxonIDnum', 'classification'));
print('Overall Accuracy', test_classification.errorMatrix('taxonIDnum', 'classification').accuracy());
// Kappa Coefficient: evaluates how well a classification performs as compared to randomly assigning values
print('Kappa Coefficient', test_classification.errorMatrix('taxonIDnum', 'classification').kappa());
// Producer's Accuracy: frequency with which a real feature on the ground is correctly shown in the classified map (corresponds to error of omission)
print('Producers Accuracy', test_classification.errorMatrix('taxonIDnum', 'classification').producersAccuracy());
// User's Accuracy: frequency with which a feature in the classified map will actually be present on the ground (corresponds to error of commission)
print('Users Accuracy', test_classification.errorMatrix('taxonIDnum', 'classification').consumersAccuracy());
```

When you look in the Console and expand the metrics, you can assess the values. Note each taxon ID is assigned a number so you will need to refer to the order in the code to understand the Confusion Matrix as well as the Producer's and User's Accuracy. Each class is listed below for reference, along with the number of training samples for each of the species, in parentheses. When interpreting accuracy, it's important to consider how many training samples were used to generate the model; the model accuracy is impacted if there is poor representation in the training data.

0) CELA - Sugarberry (12)
1) JUVI - Eastern Redcedar (35)
2) PRME - Mexican Plum (2)
3) QUMA3 - Blackjack Oak (26)
4) QUST - Post Oak (162)
5) ULAL - Winged Elm (5)
6) ULCR - Cedar Elm (18)
7) GRSS - Grass (8)
8) WATR - Water (6)
9) SHADE - Shade (9)

## Display Model Results

Lastly, we can write a function to display the image classification
```
// Function used to display training data and image classification
// Function used to display training data and image classification
function showTrainingData(){
  var colours = ee.List(["yellow", "white", "green", "orange", "darkgreen", "cyan", "purple","lightgreen","blue","black"]);
  var lc_type = ee.List(["CELA", "JUVI", "PRME","QUMA3","QUST","ULAL","ULCR","GRSS","WATR","SHADE"]);
  var lc_label = ee.List([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

  var lc_points = ee.FeatureCollection(
    lc_type.map(function(lc){
      var colour = colours.get(lc_type.indexOf(lc));
      return all_points.filterMetadata("taxonIDnum", "equals", lc_type.indexOf(lc))
                  .map(function(point){
                    return point.set('style', {color: colour, pointShape: "diamond", pointSize: 3, width: 2, fillColor: "00000000"});
                  });
        })).flatten();

  Map.addLayer(classified, {min: 0, max: 9, palette: ["yellow","white", "green", "orange", "darkgreen", "cyan", "purple", "lightgreen", "blue", "black"]}, 'Classified image');
  Map.addLayer(lc_points.style({styleProperty: "style"}), {}, 'All training sample points', false);
  Map.centerObject(geo, 16)
}

// Display the training data and image classification using the showTrainingData function
showTrainingData();
```

Here is our final classified image:

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/4b_supervised_classification/classified_airshed_map.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee/4b_supervised_classification/classified_airshed_map.png" alt="Classified airshed map"></a>
</figure>

## Acknowledgements

This tutorial was modified from a lesson developed by the <a href="https://tropicalstudies.org/" target="_blank">Organization for Tropical Studies</a> as part of the course <a href="https://tropicalstudies.org/course/google-earth-engine-for-ecology-and-conservation/" target="_blank">Google Earth Engine for Ecology and Conservation</a>. Thank you OTS!

## Get Lesson Code

<a href="https://code.earthengine.google.com/2c7078b994777fb5a2020f464fa990b8" target="_blank">AOP GEE Hyperspectral Random Forest Classification</a>
