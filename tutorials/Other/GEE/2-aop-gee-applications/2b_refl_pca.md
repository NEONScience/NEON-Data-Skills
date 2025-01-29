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


The principal components (PC) transform is a spectral rotation that takes spectrally correlated image data and outputs uncorrelated data. This can be a useful tool, especially for the high-dimensional AOP data, which is comprised of 426 bands (~380 valid bands, excluding the water vapor and noisy bands). Many of these bands may be correlated, so PCA can be a useful first step for reducing dimensionality and creating a more manageable (smaller) dataset to work with for further analysis, without reducing the essential information.

For this example, we'll use bidirectional reflectance data over the NEON site <a href="https://www.neonscience.org/field-sites/liro" target="_blank">Little Rock Lake (LIRO)</a> in Wisconsin.

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
 * An understanding of the GEE code editor and the GEE JavaScript API. See <a href="https://developers.google.com/earth-engine/guides/playground" target="_blank">Earth Engine Code Editor</a> for a basic introduction.
 * Optionally, complete the first three GEE tutorials in the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-data-google-earth-engine-tutorial-series" target="_blank">Intro to AOP Data in Google Earth Engine Tutorial Series</a>
 * A basic understanding of dimensionality reduction and PCA concepts. If this is your first time working with PCA, we recommend reviewing this concept in the context of hyperspectral data analysis.

## Additional Resources

The link below to the earth engine Eigen Analysis guide may assist you as you work through this lesson.
 * <a href="https://developers.google.com/earth-engine/guides/arrays_eigen_analysis" target="_blank"> Earth Engine Principal Components (Eigen) Analysis </a>

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

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/2b_refl_pca/liro_rgb.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/2b_refl_pca/liro_rgb.png" alt="LIRO Reflectance RGB Image"></a>
</figure>


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

## Script 2: Visualizing PCA Results

After the export completes, run this second script to visualize the results:

```javascript
// Load the original hyperspectral image, selecting bands for RGB visualization
// B053 (~660nm, red), B035 (~550nm, green), B019 (~450nm, blue)
var reflLIRO_2022view = ee.ImageCollection("projects/neon-prod-earthengine/assets/HSI_REFL/002")
    .filterMetadata('NEON_SITE', 'equals', 'LIRO')  // Select LIRO experimental forest site
    .filterDate("2022-01-01", "2022-12-31")         // Select 2022 data
    .first()                                        // Get first (and likely only) image
    .select(['B053', 'B035', 'B019']);              // Select bands for natural color display

// Load the pre-computed PCA results from Earth Engine Assets
// This asset was created by Script 1 and contains the first 5 principal components
var pcaAsset = ee.Image('projects/neon-sandbox-dataflow-ee/assets/PCA_LIRO_2022_1m');

print("PCA image - top 5 PCA bands", pcaAsset)

// Center the map on our study area
// Zoom level 12 provides a good overview of the LIRO site
Map.centerObject(reflLIRO_2022view, 12);

// Add layers to the map
// Start with the original RGB image as the base layer
Map.addLayer(reflLIRO_2022view, 
    {min: 103, max: 1160},                          // Set visualization parameters
    'Original RGB');                                // Layer name in the Layer Manager

// Add the first principal component on top
// PC1 typically contains the most variance/information from the original bands
Map.addLayer(pcaAsset, 
    {bands: ['PC1'],                                // Display only the first component
     min: -7000, max: 40000},                       // Set stretch values for good contrast
    'PC1 from Asset');                              // Layer name in the Layer Manager
```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/2b_refl_pca/liro_pca.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/2b_refl_pca/liro_pca.PNG" alt="LIRO Reflectance PCA Image"></a>
</figure>

## Understanding the Results

### Interpreting Principal Components

**PC1**: Usually represents overall brightness/albedo variations (typically 90%+ of variance)
**PC2**: Often highlights vegetation vs. non-vegetation contrasts
**PC3**: May reveal subtle features not visible in original bands

### On your own:

1. Compare PC1 with the original RGB image to understand major landscape features
2. Look for patterns in PC2 and PC3 that might reveal hidden information
3. Consider how different PCs might be useful for your specific research questions

## Troubleshooting Tips

### Memory Limits

If you encounter "User memory limit exceeded", try the following:

- Increase the `scale` parameter (try 20 or 30)
- Increase `tileScale` up to 16
- Reduce the region size if possible


### Export Issues

If the export fails:
- Verify the asset path is valid
- Check project permissions
- Try increasing `maxPixels`
- Allow sufficient time for processing


### Visualization Problems

If the PCA results don't display:
- Verify the export completed successfully
- Check the asset path in Script 2
- Adjust the visualization parameters
- Try displaying one band at a time

## Recap

In this lesson you:

- Learned how to implement PCA on hyperspectral data in GEE
- Created a workflow that handles large datasets efficiently
- Visualized and exported transformed data
- Gained experience interpreting PCA results


## Get Lesson Code

<a href="https://code.earthengine.google.com/1b47039e0663bfe8eb16c8bb0f4e49f2" target="_blank">Reflectance PCA Analysis: Part 1</a>

<a href="https://code.earthengine.google.com/f7a2af2ad3b35c7fb3d8c6215ca374b9" target="_blank">Reflectance PCA Analysis: Part 2</a>
