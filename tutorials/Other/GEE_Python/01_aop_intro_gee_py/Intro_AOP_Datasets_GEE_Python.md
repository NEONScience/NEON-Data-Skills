---
syncID: d14552056cc440549ae3c1bac80eaeb7
title: "Intro to AOP Datasets in Google Earth Engine (GEE) using Python"
description: "Explore AOP reflectance, camera, and lidar datasets in GEE"
dateCreated: 2023-07-25
authors: Bridget Hass
contributors: John Musinsky
estimatedTime: 30 minutes
packagesLibraries: earthengine-api, geemap
topics:
languagesTool: Python, Google Earth Engine
dataProducts: DP3.30006.001, DP3.30010.001, DP3.30015.001, DP3.30024.001
code1: https://github.com/NEONScience/NEON-Data-Skills/blob/main/tutorials/Other/GEE_Python/01_aop_intro_gee_py/Intro_AOP_Datasets_GEE_Python.ipynb
tutorialSeries: 
urlTitle: aop-gee-py-intro
---

<div id="ds-objectives" markdown="1">

### Objectives
After completing this tutorial, you will be able to use Python to:

* Determine the available AOP datasets in Google Earth Engine
* Read in and visualize AOP Reflectance, RGB Camera, and Lidar Raster datasets
* Become familiar with the AOP Image Properties
* Filter data based off image properties to pull in dataset(s) of interest
* Explore the interactive mapping features in geemap

### Requirements

To follow along with this code, you will need to 
1. Sign up for a non-commercial Google Earth Engine account here https://code.earthengine.google.com/register.
2. Install **Python 3.x**
3. Install required Python packages (matplotlib, cartopy and the dependent packages are only required for the last optional part of the tutorial, to create a time-lapse gif)
- earthengine-api
- geemap

Notes: 
- This tutorial was developed using Python 3.9, so if you are installing Python for the first time, we recommend that version. This lesson was written in **Jupyter Notebook** so you can run each cell chunk individually, but you can also use a different IDE (Interactive Development Environment) of your choice. 
- If not using **Jupyter**, we recommend using **Spyder**, which has similar functionality. You can install both Python, Jupyter Notebooks, and Spyder by downloading <a href="https://www.anaconda.com/products/distribution" target="_blank">Anaconda</a>.


### Additional Resources
- <a href="https://developers.google.com/earth-engine/tutorials/community/intro-to-python-api" target="_blank">Google Developers Intro to Python API</a>
- <a href="https://book.geemap.org/" target="_blank">`geemap` Text Book</a>
- <a href="https://www.youtube.com/@giswqs" target="_blank">`geemap` YouTube Channel</a>

</div>

## AOP data in GEE

[Google Earth Engine](https://earthengine.google.com/) is a platform idea for carrying out continental and planetary scale geospatial analyses. It has a multi-pedabyte catalog of satellite imagery and geospatial datasets, and is a powerful tool for comparing and scaling up NEON airborne datasets. 

The NEON data products can currently be accessed through the `projects/neon-prod-earthengine/assets/` folder with an appended prefix of the data product ID (DPID) similar to what you see on the [NEON data portal](https://data.neonscience.org/data-products/explore). The table below shows the corresponding prefixes to use for the available data products.

| Acronym | Data Product      | Data Product ID (Prefix)          |
|----------|------------|-------------------------|
| SDR | Surface Directional Reflectance | DP3-30006-001 |
| RGB | Red Green Blue (Camera Imagery) | DP3-30010-001 |
| CHM | Canopy Height Model | DP3-30015-001 |
| DSM | Digital Surface Model | DP3-30024-001 |
| DTM | Digital Terrain Model | DP3-30024-001 |


To access the NEON AOP data you can read in the Image Collection `ee.ImageCollection` and filter by the date and other properties of interest.

First, import the relevant Earth Engine Python packages, `earthengine-api` [(ee)](https://developers.google.com/earth-engine/guides/python_install) and [geemap](https://geemap.org/). This lesson was written using geemap version 0.22.1. If you have an older version installed, used the command below to update.

## GEE Python API


```python
import ee, geemap
```

In order to use Earth Engine from within this Jupyter Notebook, we need to first Authenticate (which requires generating a token) and then Initialize, as below. For more detailed instructions on the Authentication process, please refer to the: 
<a href="https://book.geemap.org/chapters/01_introduction.html#earth-engine-authentication" target="_blank">geemap text book Earth Engine authentication section</a>.


```python
geemap.__version__
```




    '0.22.1'




```python
ee.Authenticate()
```


<p>To authorize access needed by Earth Engine, open the following
        <p>The authorization workflow will generate a code, which you should paste in the box below.</p>

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/enter_verification_code.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/enter_verification_code.PNG" alt="enter_verification_code screenshot" width="600"><figcaption></figcaption></a>
</figure><br>

When the token is entered, you should receive the notice: `"Successfully saved authorization token."`
    


```python
ee.Initialize()
```

Now that you've logged in to your Earth Engine account, you can start using the Python API with the `ee` package.

First let's read in the Surface Directional Reflectance (SDR) Image Collection and take a look at the available data.


```python
# Read in the NEON AOP Surface Directional Reflectance (SDR) Collection:
sdrCol = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30006-001')

# List all available sites in the NEON SDR image collection:
print('All Available NEON SDR Images:')

# Get the number of SDR images
sdrCount = sdrCol.size()
print('Count: ', str(sdrCount.getInfo())+'\n')

print(sdrCol.aggregate_array('system:index').getInfo())
```

    All Available NEON SDR Images:
    Count:  25
    
    ['2013_CPER_1_SDR', '2016_CLBJ_1_SDR', '2016_GRSM_2_SDR', '2016_HARV_3_SDR', '2017_CLBJ_2_SDR', '2017_CPER_3_SDR', '2017_GRSM_3_SDR', '2017_SERC_3_SDR', '2018_CLBJ_3_SDR', '2019_CLBJ_4_SDR', '2019_HARV_6_SDR', '2019_HEAL_3_SDR', '2019_JORN_3_SDR', '2019_SOAP_4_SDR', '2020_CPER_5_SDR', '2020_CPER_7_SDR', '2020_NIWO_4_SDR', '2021_ABBY_4_SDR', '2021_CLBJ_5_SDR', '2021_CPER_8_SDR', '2021_GRSM_5_SDR', '2021_HEAL_4_SDR', '2021_JORN_4_SDR', '2021_SJER_5_SDR', '2021_SOAP_5_SDR']
    

We can also look for data for a specified site - for example look at all the years of AOP SDR data available for a given site.


```python
# See the years of data available for the specified site:
site = 'CPER'

# Get the flight year and site information
flightYears = sdrCol.aggregate_array('FLIGHT_YEAR').getInfo()
sites = sdrCol.aggregate_array('NEON_SITE').getInfo()

print('\nYears of SDR data available in GEE for',site+':')
print([year_site[0] for year_site in zip(flightYears,sites) if site in year_site])
```

    
    Years of SDR data available in GEE for CPER:
    [2013, 2017, 2020, 2020, 2021]
    

Let's take a look at another dataset, the high-resolution RGB camera imagery:


```python
# Read in the NEON AOP Camera (RGB) Collection:
rgbCol = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30010-001')

# List all available sites in the NEON SDR image collection:
print('All Available NEON Camera Images:')
# Get the number of RGB images
rgbCount = rgbCol.size()
print('Count: ', str(sdrCount.getInfo())+'\n')
print(rgbCol.aggregate_array('system:index').getInfo())
```

    All Available NEON Camera Images:
    Count:  25
    
    ['2016_HARV_3_RGB', '2017_CLBJ_2_RGB', '2017_GRSM_3_RGB', '2017_SERC_3_RGB', '2018_CLBJ_3_RGB', '2018_TEAK_3_RGB', '2019_BART_5_RGB', '2019_CLBJ_4_RGB', '2019_HARV_6_RGB', '2019_HEAL_3_RGB', '2019_JORN_3_RGB', '2019_SOAP_4_RGB', '2020_CPER_7_RGB', '2020_NIWO_4_RGB', '2020_RMNP_3_RGB', '2020_UKFS_5_RGB', '2020_UNDE_4_RGB', '2020_YELL_3_RGB', '2021_ABBY_4_RGB', '2021_BLAN_4_RGB', '2021_BONA_4_RGB', '2021_CLBJ_5_RGB', '2021_DEJU_4_RGB', '2021_DELA_6_RGB', '2021_HEAL_4_RGB', '2021_JERC_6_RGB', '2021_JORN_4_RGB', '2021_LENO_6_RGB', '2021_MLBS_4_RGB', '2021_OSBS_6_RGB', '2021_SERC_5_RGB', '2021_SJER_5_RGB', '2021_SOAP_5_RGB', '2021_TALL_6_RGB', '2021_WREF_4_RGB']
    

Similarly, you can read in the DEM and CHM collections as follows:

```python
# Read in the NEON AOP DEM Collection (this includes the DTM and DSM as 2 bands)
demCol = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30024-001')

# Read in the NEON AOP CHM Collection
chmCol = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30015-001')
```

## Explore Image Properties

Now that we've read in a couple of image collections, let's take a look at some of the image properties using `geemap.image_props`:


```python
props = geemap.image_props(sdrCol.first())

# Optionally display all properties by uncommenting the line below
# props
```


```python
# Display the property names for the first 15 properties:
props.keys().getInfo()[:15]
```




    ['AOP_VISIT_NUMBER',
     'DESCRIPTION',
     'FLIGHT_YEAR',
     'IMAGE_DATE',
     'NEON_DATA_PROD_ID',
     'NEON_DATA_PROD_URL',
     'NEON_DOMAIN',
     'NEON_SITE',
     'NOMINAL_SCALE',
     'PRODUCT_TYPE',
     'SCALING_FACTOR',
     'SENSOR_NAME',
     'SENSOR_NUMBER',
     'WL_FWHM_B001',
     'WL_FWHM_B002']



You can also look at all the Image properties by typing `props`. This generates a long output, so we will just show a portion of the output from that:

```
AOP_VISIT_NUMBER:1
DESCRIPTION:Orthorectified surface directional reflectance (0-1 unitless, scaled by 10000) ...
FLIGHT_YEAR:2013
IMAGE_DATE:2013-06-25
NEON_DATA_PROD_ID:DP3.30006.001
NEON_DATA_PROD_URL:https://data.neonscience.org/data-products/DP3.30006.001
NEON_DOMAIN:D10
NEON_SITE:CPER
NOMINAL_SCALE:1
PRODUCT_TYPE:SDR
SCALING_FACTOR:10000
SENSOR_NAME:AVIRIS-NG
SENSOR_NUMBER:NIS1
WL_FWHM_B001:382.3465,5.8456
    
system:asset_size:68059.439009 MB
system:band_names: List (442 elements)
system:id:projects/neon-prod-earthengine/assets/DP3-30006-001/2013_CPER_1_SDR
system:index:2013_CPER_1_SDR
system:time_end:2013-06-25 10:42:05
system:time_start:2013-06-25 08:30:45
system:version:1689911980211725
```

The image properties contain some additional relevant information about the dataset, and are variables you can filter on to select a subset of the data. A lot of these properties are self-explanatory, but some of them may be less apparent. A short description of a few properties is outlined below. Note that when the datasets become part of the Google Public Datasets, you will be able to see descriptions of the properties in GEE.

- `SENSOR_NAME`: The name of the hyperspectral sensor. All NEON sensors are JPL AVIRIS-NG sensors.
- `SENSOR_NUMBER`: The payload number, NIS1 = NEON Imaging Spectrometer, Payload 1. NEON Operates 3 separate payloads, each with a unique hyperspectral sensor (as well as unique LiDAR and Camera sensors).
- `WL_FWHM_B###`: Center Wavelength (WL) and Full Width Half Max (FWHM) of the band, both in nm

In addition there are some `system` properties, including information about the size of the asset, the band names (most of these are just band numbers but the QA bands have more descriptive names), as well as the start and end time of the collection.

## Filter an Image Collection

One of the most useful aspects of having AOP data ingested in Earth Engine is the ability to filter by properties, such as the site name, dates, sensors, etc. In this next section, we will show how to filter datasets to extract only data of interest. We'll use the NEON's <a href="https://www.neonscience.org/field-sites/serc" target="_blank">Smithsonian Environmental Research Center (SERC)</a>, in Maryland.


```python
# See the years of data available for the specified site:
site = 'SERC'

# Get the flight year and site information
flightYears = rgbCol.aggregate_array('FLIGHT_YEAR').getInfo()
sites = rgbCol.aggregate_array('NEON_SITE').getInfo()

print('\nYears of RGB data available in GEE for',site+':')
print([year_site[0] for year_site in zip(flightYears,sites) if site in year_site])
```

    
    Years of RGB data available in GEE for SERC:
    [2017, 2021]
    


```python
# Get the flight year and site information
flightYears = sdrCol.aggregate_array('FLIGHT_YEAR').getInfo()
sites = sdrCol.aggregate_array('NEON_SITE').getInfo()

print('\nYears of SDR data available in GEE for',site+':')
print([year_site[0] for year_site in zip(flightYears,sites) if site in year_site])
```

    
    Years of SDR data available in GEE for SERC:
    [2017]
    


```python
# Specify the start and end dates
year = 2017
start_date = ee.Date.fromYMD(year, 1, 1) 
end_date = start_date.advance(1, "year")

# Filter the RGB image collection on the site and dates
SERC_RGB_2017 = rgbCol.filterDate(start_date, end_date).filterMetadata('NEON_SITE', 'equals', site).mosaic()
```

## Add Data Layers to the Map

In order to visualize and interact with the dataset, we can use `geemap.Map()` as follows:


```python
Map = geemap.Map()
Map
```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/serc_sdr_rgb_layers.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/serc_sdr_rgb_layers.png" alt="SERC Map Layers" width="800"><figcaption>Map Panel with SERC 2017 RGB and SDR Layers Added</figcaption></a>
</figure><br>



We'll start by reading in an RGB image over the Smithsonian Environmental Research Center (SERC) and adding the layer to the Map.


```python
# Specify center location of SERC: 38.890131, -76.560014
# NEON field site information can be found on the NEON website here > https://www.neonscience.org/field-sites/serc
geo = ee.Geometry.Point([-76.56, 38.89])

# Set the visualization parameters so contrast is maximized
rgb_vis_params = {'min': 0, 'max': 250, 'gamma': 0.8}

# Add the SERC RGB data as a layer to the Map
Map.addLayer(SERC_RGB_2017, rgb_vis_params, 'SERC 2017 RGB Camera');

# Center the map on SERC and set zoom level
Map.centerObject(geo, 12);
```

## Surface Directional Reflectance (SDR)

Next let's take a look at one of the SDR datasets. We will pull in only the data bands, for this example. 

### SDR Data Bands


```python
# Read in the first image of the SDR Image Collection
sdrImage = sdrCol.filterDate(start_date, end_date).filterMetadata('NEON_SITE', 'equals', site).mosaic()

# Read in only the data bands, all of which start with "B", eg. "B001"
sdrData = sdrImage.select('B.*')

# Set the visualization parameters so contrast is maximized, and display RGB bands (true-color image)
sdrVisParams = {'min':0, 'max':1200, 'gamma':0.9, 'bands':['B053','B035','B019']};

# Add the SERC RGB data as a layer to the Map
Map.addLayer(sdrData, sdrVisParams, 'SERC 2017 SDR');
```

### SDR QA Bands

Before we used a regular expression to pull out only the bands starting with "B". We can also take a look at the remaining bands using a similar expression, but this time excluding bands starting with "B". These comprise all of the QA-related bands that provide additional information and context about the data bands. This next chunk of code prints out the IDs of all the QA bands.


```python
# Read in only the QA bands, none of which start with "B"
sdrQA_bands = sdrImage.select('[^B].*')

# Create a dictionary of the band information
sdrQA_band_info = sdrQA_bands.getInfo()
type(sdrQA_band_info)

# Loop through the band info dictionary to print out the ID of each band
print('QA band IDs:\n')
for i in range(len(sdrQA_band_info['bands'])):
    print(sdrQA_band_info['bands'][i]['id'])
```

    QA band IDs:
    
    Aerosol_Optical_Depth
    Aspect
    Cast_Shadow
    Dark_Dense_Vegetation_Classification
    Haze_Cloud_Water_Map
    Illumination_Factor
    Path_Length
    Sky_View_Factor
    Slope
    Smooth_Surface_Elevation
    Visibility_Index_Map
    Water_Vapor_Column
    to-sensor_Azimuth_Angle
    to-sensor_Zenith_Angle
    Weather_Quality_Indicator
    Acquisition_Date
    

Most of these QA bands are related to the Atmospheric Correction (ATCOR), one of the processing steps in converting Radiance to Reflectance. For more details on this process, NEON provides an Algorithm Theoretical Basis Document (ATBD), which is available from the data portal. https://data.neonscience.org/api/v0/documents/NEON.DOC.001288vB?inline=true

Bands that may be most useful for standard analyses are the `Weather_Quality_Indicator` and `Acquisition_Date`. The weather quality indicator includes information about the cloud conditions during the flight, as reported by the flight operators, where 1 corresponds to <10% cloud cover, 2 corresponds to 10-50% cloud cover, and 3 corresponds to >50% cloud cover. We recommend using only clear-sky data for a typical analysis, as it comprises the highest quality reflectance data.

You may be interested in the acquisition date if, for example, you are linking field data collected on a specific date, or are interested in finding satellite data collected close in time to the AOP imagery.

The next chunks of code show how to add the Weather QA bands to the Map Layer.

### Weather Quality Indicator Band


```python
sdrWeatherQA = sdrCol.select(['Weather_Quality_Indicator']);

# Define a palette for the weather - to match NEON AOP's weather color conventions (green-yellow-red)
gyrPalette = ['00ff00', # green (<10% cloud cover)
              'ffff00', # yellow (10-50% cloud cover)
              'ff0000']; # red (>50% cloud cover)
             
# Visualization parameters to display the weather bands (cloud conditions) with the green-yellow-red palette
weatherVisParams = {'min': 1, 'max': 3, 'palette': gyrPalette, 'opacity': 0.3};

# Add the SERC RGB data as a layer to the Map
Map.addLayer(sdrWeatherQA, weatherVisParams, 'SERC 2017 Weather QA');
```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/serc_weather_qa_layer.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/serc_weather_qa_layer.png" alt="SERC Weather QA Layer" width="800"><figcaption>Map Panel Displaying SERC 2017 Weather QA Layer</figcaption></a>
</figure><br>

In 2017 most of the SERC site was collected in "green" (<10% cloud cover) sky conditions, with the exception of a small portion on the western side of the flight box. When working with this dataset, we recommend only using this clear-sky portion, where clouds have not obscured the reflectance values.

## Recap

In this lesson, you learned how to access the four NEON datasets that are available in GEE: Surface Directional Reflectance (SDR), Camera (RGB), and LiDAR-derived Digital Elevation (Terrain and Surface) Models (DTM and DSM) and Ecosystem Structure / Canopy Height Model (CHM). You generated code to determine which AOP datasets are available in GEE for a given Image Collection. You explored the SDR image properties and learned how to filter on specified metadata to pull out a subset of Images or a single Image from an Image Collection. You learned how to use `geemap` to add data layers to the interactive map panel. And lastly, you learned how to select and visualize the `Weather_Quality_Indicator` band, which is a useful first step in working with AOP reflectance data. 

This is a great starting point for your own research!
