---
syncID: 
title: "Principal Component Analysis of AOP Hyperspectral Data in GEE"
description: "Apply Principal Component Analysis (PCA) to NEON AOP hyperspectral reflectance data to reduce data dimensionality"
dateCreated: 2025-01-28
authors: John Musinsky
contributors: Bridget Hass
estimatedTime: 1 hour
packagesLibraries: 
topics: hyperspectral, remote-sensing
languageTool: GEE
dataProduct: DP3.30006.001, DP3.30006.002
code1: 
tutorialSeries: 
urlTitle: aop-gee-refl-pca

---

Google Earth Engine has a number of built in machine learning tools that are designed to work with multi-band raster data. This simplifies more complex analyses like classification (eg. classifying land types or species). In this example, we demonstrate species classification using a random forest machine learning model, using NEON AOP reflectance and ecosystem structure (CHM) data, and TOS (Terrestrial Observation System) woody vegetation data to train the model. For this example, we'll use airshed boundary of the site <a href="https://www.neonscience.org/field-sites/clbj" target="_blank">CLBJ</a> (Lyndon B. Johnson National Grassland in north-central Texas).

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:
* Apply Principal Component Analysis (PCA) to NEON AOP hyperspectral reflectance data to reduce data dimensionality
* Create a reproducible workflow for processing high-dimensional spectral data
* Export and load PCA results as Earth Engine assets
* Compare original hyperspectral bands with PCA-transformed data
* Interpret the information content in different principal components

## Requirements
 * An Earth Engine account. You can sign up for an Earth Engine account here: https://earthengine.google.com/register/
 * An understanding of the GEE code editor and the GEE JavaScript API.
 * Optionally, complete the first three GEE tutorials in this tutorial series: <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-data-google-earth-engine-tutorial-series" target="_blank">Intro to AOP Data in Google Earth Engine Tutorial Series</a>
 * A basic understanding of dimensionality reduction and PCA concepts. If this is your first time working with PCA, we recommend reviewing this concept in the context of hyperspectral data analysis.

## Additional Resources

The links below to the earth engine guides may assist you as you work through this lesson.
 * <a href="https://developers.google.com/earth-engine/guides/arrays_eigen_analysis" target="_blank"> Earth Engine Principal Components (Eigen) Analysis </a>
 * <a href="https://developers.google.com/earth-engine/guides/machine-learning" target="_blank"> Earth Engine Machine Learning Guide </a>

</div>

## Script 1: Computing PCA


### Read in the AOP Directional Reflectance Image

First, we'll import the hyperspectral data and create a natural color composite for visualization:

```javascript

// Import and filter NEON AOP hyperspectral imagery
var reflLIRO_2022 = ee.ImageCollection("projects/neon-prod-earthengine/assets/HSI_REFL/002")
  .filterMetadata('NEON_SITE', 'equals', 'LIRO') // Select LIRO site
  .filterDate("2022-01-01", "2022-12-31") // Select 2022 data
  .first(); // Get the first image

// Create RGB visualization using specific bands
var reflLIRO_2022view = ee.ImageCollection("projects/neon-prod-earthengine/assets/HSI_REFL/002")
  .filterMetadata('NEON_SITE', 'equals', 'LIRO')
  .filterDate("2022-01-01", "2022-12-31")
  .first().select(['B053', 'B035', 'B019']); // Select bands for RGB visualization

// Center on the LIRO reflectance dataset
Map.centerObject(reflLIRO_2022, 12);

// Add the layer to the Map
Map.addLayer(reflLIRO_2022view, {min:103, max:1160}, 'Original RGB');

```

### Set up Sampling for PCA

PCA requires representative samples to compute the covariance matrix. We'll collect 500 random samples:


```javascript

var numberOfSamples = 500;

var sample = reflLIRO_2022.sample({
  region: reflLIRO_2022.geometry(),
  scale: 10,
  numPixels: numberOfSamples,
  seed: 1,
  geometries: true
});

var samplePoints = ee.FeatureCollection(sample);

```

### Create Helper Functions

We need two main helper functions: one to generate band names and another to perform the PCA:

```javascript

// Function to generate names for the principal component bands
// Example: PC1, PC2, PC3, etc.
function getNewBandNames(prefix, num) {
    return ee.List.sequence(1, num).map(function(i) {
        return ee.String(prefix).cat(ee.Number(i).int().format());
    });
}

/// Function to perform Principal Component Analysis
function calcImagePca(image, numComponents, samplePoints) {
    // Convert the image into an array for matrix operations
    var arrayImage = image.toArray();
    var region = samplePoints.geometry();
    
    // Calculate mean values for each band
    var meanDict = image.reduceRegion({
        reducer: ee.Reducer.mean(),
        geometry: region,
        scale: 10,
        maxPixels: 1e13,
        bestEffort: true,
        tileScale: 16                               // Parameter to prevent computation timeout
    });
    
    // Center the data by subtracting the mean
    var meanImage = ee.Image.constant(meanDict.values(image.bandNames()));
    var meanArray = meanImage.toArray().arrayRepeat(0, 1);
    var meanCentered = arrayImage.subtract(meanArray);
    
    // Calculate the covariance matrix
    var covar = meanCentered.reduceRegion({
        reducer: ee.Reducer.centeredCovariance(),
        geometry: region,
        scale: 10,
        maxPixels: 1e13,
        bestEffort: true,
        tileScale: 16
    });
    
    // Compute eigenvalues and eigenvectors
    var covarArray = ee.Array(covar.get('array'));
    var eigens = covarArray.eigen();
    var eigenVectors = eigens.slice(1, 1);  // Extract eigenvectors
    
    // Project the mean-centered data onto the eigenvectors
    var principalComponents = ee.Image(eigenVectors)
        .matrixMultiply(meanCentered.toArray(1));
    
    // Return the desired number of components
    return principalComponents
        .arrayProject([0])  // Project the array to 2D
        .arraySlice(0, 0, numComponents); // Select the first n components
}
```


### Apply PCA and Export Results

Now we'll apply PCA and export the results. Change the `assetId` tag below to one of your cloud projects.

```javascript
// Apply PCA to the hyperspectral image
var numComponents = 5;                              // Number of components to retain
var pcaImage = calcImagePca(reflLIRO_2022, numComponents, samplePoints);
var bandNames = getNewBandNames('PC', numComponents);
var finalPcaImage = pcaImage.arrayFlatten([bandNames]);  // Convert to regular image

// Export the PCA results to Earth Engine Assets
// This step may take several minutes to complete
Export.image.toAsset({
    image: finalPcaImage,
    description: 'PCA_LIRO_2022',
    assetId: 'projects/neon-sandbox-dataflow-ee/assets/PCA_LIRO_2022',
    scale: 1,                                       // Output resolution in meters
    maxPixels: 1e13                                 // Increase max pixels for large exports
});
```
