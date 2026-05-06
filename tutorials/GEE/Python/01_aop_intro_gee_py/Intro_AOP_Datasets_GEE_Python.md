---
syncID: d14552056cc440549ae3c1bac80eaeb7
title: "Intro to AOP Datasets in Google Earth Engine (GEE) Python"
description: "Explore AOP reflectance, camera, and lidar datasets in GEE"
dateCreated: 2023-07-25
authors: Bridget Hass
contributors: John Musinsky
estimatedTime: 45 minutes
packagesLibraries: earthengine-api (ee), geemap
topics:
languagesTool: Google Earth Engine, Python
dataProducts: DP3.30006.001, DP3.30006.002, DP3.30010.001, DP3.30015.001, DP3.30024.001, DP3.30018.002
code1: https://github.com/NEONScience/NEON-Data-Skills/blob/main/tutorials/GEE/Python/01_aop_intro_gee_py/Intro_AOP_Datasets_GEE_Python.ipynb
tutorialSeries: 
urlTitle: aop-gee-py-intro
---

<div id="ds-objectives" markdown="1">

### Objectives
After completing this tutorial, you will be able to use Python to:

* Determine the available AOP datasets in Google Earth Engine
* Read in and visualize AOP Reflectance, RGB Camera, and Lidar raster datasets
* Become familiar with the AOP Image Properties
* Filter data based off image properties to pull in dataset(s) of interest
* Explore the interactive mapping features in geemap

### Requirements

To follow along with this code, you will need to:
1. Sign up for a non-commercial Google Earth Engine account here https://code.earthengine.google.com/register.
2. Install **Python 3.9+**
3. Install required Python packages 
- `pip install earthengine-api --upgrade`
- `pip install geemap`

You may need to run the following to upgrade the `google-api-python-client`:
- `pip install --upgrade google-api-python-client`

Notes: 
- This tutorial was developed using Python 3.9, so if you are installing Python for the first time, we recommend that version or higher. This lesson was written in **Jupyter Notebook** so you can run each cell chunk individually, but you can also use a different IDE (Interactive Development Environment) of your choice. 
- If not using **Jupyter**, we recommend using **Spyder**, which has similar functionality. You can install both Python, Jupyter Notebooks, and Spyder by downloading <a href="https://www.anaconda.com/products/distribution" target="_blank">Anaconda</a>.

### Additional Resources
- <a href="https://developers.google.com/earth-engine/tutorials/community/intro-to-python-api" target="_blank">Google Developers Intro to Python API</a>
- <a href="https://book.geemap.org/" target="_blank">`geemap` Text Book</a>
- <a href="https://www.youtube.com/@giswqs" target="_blank">`geemap` YouTube Channel</a>

</div>

## AOP data in Google Earth Engine

[Google Earth Engine](https://earthengine.google.com/) is a platform for carrying out continental and planetary scale geospatial analyses. It has a multi-pedabyte catalog of satellite imagery and geospatial datasets, and is a powerful environment for comparing and scaling up NEON airborne datasets. 

The NEON data products that have been made available on GEE can be currently be accessed through the `projects/neon-prod-earthengine` folder with an appended suffix of the dataset Acronym and Revision Number, shown in the table below. 

| Acronym | Revision | Data Product      | Data Product ID |
|---------|----------|-------------------|-----------------|
| HSI_REFL | 001 | Surface Directional Reflectance | <a href="https://data.neonscience.org/data-products/DP3.30006.001" target="_blank">DP3.30006.001</a> |
| HSI_REFL | 002 | Surface Bidirectional Reflectance | <a href="https://data.neonscience.org/data-products/DP3.30006.002" target="_blank">DP3.30006.002</a> |
| RGB | 001 | Red Green Blue (Camera Imagery) | <a href="https://data.neonscience.org/data-products/DP3.30010.001" target="_blank">DP3.30010.001</a> |
| DEM | 001 | Digital Surface and Terrain Models (DSM/DTM) | <a href="https://data.neonscience.org/data-products/DP3.30024.001" target="_blank">DP3.30024.001</a> |
| CHM | 001 | Ecosystem Structure (Canopy Height Model; CHM) | <a href="https://data.neonscience.org/data-products/DP3.30015.001" target="_blank">DP3.30015.001</a> |
| CNC | 001 | Canopy Nitrogen Content | <a href="https://data.neonscience.org/data-products/DP3.30018.002" target="_blank">DP3.30018.002</a> |

To access the NEON AOP data you can read in the Image Collection `ee.ImageCollection` followed by the path, eg. the Surface Directional Reflectance can be found under the path `projects/neon-prod-earthengine/assets/HSI_REFL/001`. You can then filter down to a particular site and year of interest using the properties. 

First, import the relevant Earth Engine Python packages, `earthengine-api` [(ee)](https://developers.google.com/earth-engine/guides/python_install) and [geemap](https://geemap.org/). This lesson was written using geemap version 0.22.1. If you have an older version installed, used the command below to update.

## GEE Python Package Installation and Authentication


```python
import ee
import geemap
```

In order to use Earth Engine from within this Jupyter Notebook, we need to first Authenticate (which requires generating a token) and then Initialize, as below. For more detailed instructions on the Authentication process, please refer to the: 
<a href="https://book.geemap.org/chapters/01_introduction.html#earth-engine-authentication" target="_blank">geemap text book Earth Engine authentication section</a>.

When you run the cell below, a web browser will pop up and you will need to select your cloud project and follow the instructions to generate a token (or authorization code), which you will copy into the `Enter verification code:` box below.


```python
ee.Authenticate()
```


<p>To authorize access needed by Earth Engine, open the following
        URL in a web browser and follow the instructions:</p>
        <p><a href=https://code.earthengine.google.com/client-auth</a></p>
        <p>The authorization workflow will generate a code, which you should paste in the box below.</p>



    Enter verification code:  < copy your verification code here >
    

    
    Successfully saved authorization token.
    

If this succeeded, you should see the message "Successfully saved authorization token". Next, you will need to initialize.


```python
ee.Initialize()
```

Now that you've Authenticated and Initialized your Earth Engine account, you can start using the Python API to interact with GEE using the `ee` and `geemap` packageS.

First let's read in the Surface Directional Reflectance Image Collection (`HSI_REFL/001`) and see what data are available in GEE.


```python
# Read in the NEON AOP Surface Directional Reflectance (HSI_REFL/001) Collection:
refl001 = ee.ImageCollection('projects/neon-prod-earthengine/assets/HSI_REFL/001')

refl001_count = refl001.size() # Get the number of reflectance images
refl001_count = str(refl001_count.getInfo())
print(f'Found {refl001_count} Directional Reflectance Images in GEE')

refl001_year_sites = refl001.aggregate_array('system:index').getInfo()
print('First 5 directional reflectance datasets:',refl001_year_sites[:5])
print('Last 5 directional reflectance datasets:',refl001_year_sites[-5:])
```

    Found 124 Directional Reflectance Images in GEE
    First 5 directional reflectance datasets: ['2013_CPER_1', '2014_HARV_2', '2014_JERC_1', '2015_MLBS_1', '2015_TALL_1']
    Last 5 directional reflectance datasets: ['2021_SYCA_2', '2021_TALL_6', '2021_TEAK_5', '2021_WOOD_5', '2021_WREF_4']
    

There are 124 reflectance datasets available as of April 2026, with datasets collected between 2013 and 2021. Starting in 2022, AOP began applying BRDF and topographic corrections to the hyperspectral data, and those bidirectional datasets are available under a new revision number (`HSI_REFL/002`), see the next code chunk. The number of directional reflectance imges you see may be higher than what is shown above, as AOP is continuing to add directional reflectance datasets for older acquisition dates (pre-2022). Next let's look at the bidirectional reflectance images:


```python
# Read in the NEON AOP Bidirectional Reflectance (HSI_REFL/002) Collection:
refl002 = ee.ImageCollection('projects/neon-prod-earthengine/assets/HSI_REFL/002')

refl002_count = refl002.size() # Get the number of bidirectional reflectance images
refl002_count = str(refl002_count.getInfo())
print(f'Found {refl002_count} Bidirectional Reflectance Images in GEE')

refl002_year_sites = refl002.aggregate_array('system:index').getInfo()
print('First 5 bidirectional reflectance datasets:',refl002_year_sites[:5])
print('Last 5 bidirectional reflectance datasets:',refl002_year_sites[-5:])
```

    Found 129 Bidirectional Reflectance Images in GEE
    First 5 bidirectional reflectance datasets: ['2022_ABBY_5', '2022_ARIK_4', '2022_BART_6', '2022_BLAN_5', '2022_CHEQ_5']
    Last 5 bidirectional reflectance datasets: ['2025_TOOL_5', '2025_UNDE_7', '2025_WOOD_7', '2025_WREF_7', '2025_YELL_6']
    

There are currently (as of April 2026) 129 bidirectional reflectance datasets in the GEE image collection, with acquisition dates between 2022-2025. Starting in Spring-Summer 2026, you can expect to see some earlier years of the bidirectional data (data acquired before 2022) added as well.

You can also look for data for a specified site - for example look at all the years of AOP directional reflectance data available for the Central Plains Experimental Range (`CPER`) site:


```python
# See the years of data available for the specified site:
site = 'CPER'

# Get the flight year and site information
flight_years = refl001.aggregate_array('FLIGHT_YEAR').getInfo()
sites = refl001.aggregate_array('NEON_SITE').getInfo()

print('\nYears of Directional Reflectance data available in GEE for ',site+':')
print([year_site[0] for year_site in zip(flight_years,sites) if site in year_site])
```

    
    Years of Directional Reflectance data available in GEE for  CPER:
    [2013, 2017, 2020, 2020, 2021]
    

Let's take a look at another dataset, the high-resolution RGB camera imagery:


```python
# Read in the NEON AOP Camera (RGB) Collection and show all available images:
rgb = ee.ImageCollection('projects/neon-prod-earthengine/assets/RGB/001')

rgb_count = rgb.size() # Get the number of RGB images
rgb_count = str(rgb_count.getInfo())
print(f'Found {rgb_count} RGB Camera Images in GEE')
# print('Count: ', str(rgb_count.getInfo())+'\n')

rgb_year_sites = rgb.aggregate_array('system:index').getInfo()
print('First 5 RGB Images:',rgb_year_sites[:5])
print('Last 5 RGB Images:',rgb_year_sites[-5:])
```

    Found 339 RGB Camera Images in GEE
    First 5 RGB Images: ['2013_CPER_1', '2013_SJER_1', '2013_SOAP_1', '2013_STER_1', '2013_TEAK_1']
    Last 5 RGB Images: ['2025_TOOL_5', '2025_UNDE_7', '2025_WOOD_7', '2025_WREF_7', '2025_YELL_6']
    

As of April 2026, there are 339 Camera images in the collection, with datasets collected between 2013 to 2025. Note that data are added on a rolling basis, so as new data are collected and processed, the image count will increase.

Similarly, you can read in the Lidar DEM, CHM and the Canopy Nitrogen (CNC) collections as follows:

```python
# Read in the NEON AOP DEM Collection (this includes the DTM and DSM as 2 bands)
dem = ee.ImageCollection('projects/neon-prod-earthengine/assets/DEM/001')

# Read in the NEON AOP CHM Collection
chm = ee.ImageCollection('projects/neon-prod-earthengine/assets/CHM/001')

# Read in the NEON AOP Canopy Nitrogen Collection
cnc = ee.ImageCollection('projects/neon-prod-earthengine/assets/CNC/002')
```

## Explore Image Properties

Now that we've read in a couple of image collections, let's take a look at some of the image properties using `geemap.image_props`:


```python
props = geemap.image_props(refl001.first())

# Display the property names for the first 15 properties:
props.keys().getInfo()[:16]

# Optionally display all properties by uncommenting the line below
# props
```




    ['AOP_VISIT_NUMBER',
     'CITATION',
     'DOI',
     'FLIGHT_YEAR',
     'IMAGE_DATE',
     'NEON_DATA_PROD_URL',
     'NEON_DOMAIN',
     'NEON_SITE',
     'NEON_SITE_NAME',
     'NOMINAL_SCALE',
     'PROVISIONAL_RELEASED',
     'RELEASE_YEAR',
     'SCALE_FACTOR',
     'SENSOR_NAME',
     'SENSOR_NUMBER',
     'WL_FWHM_B001']



You can also look at all the Image properties by typing `props`.`

The image properties contain some additional relevant information about the dataset, and are variables you can filter on to select a subset of the data. A lot of these properties are self-explanatory, but some of them may be less apparent. A short description of a few properties is outlined below

### Release and Citation Properties

- `CITATION`: Recommended cictation for the data product accessed through GEE.E
- `PROVISIONAL_RELEASED`: Whether the data are available provisionally, or are Released.
- `RELEASE_YEAR`: The year of the release tag, if the data have been Released
- `DOI`: The Digital Object Identifier of the data product, only available if the data have been Released.

For more information about recommended citations and the release process for NEON data, please see:
- <a href="https://www.neonscience.org/data/guidelines-policies/citing" target="_blank">Acknowledging and Citing NEON</a>
- <a href="https://www.neonscience.org/resources/learning-hub/tutorials/release-provisional-tutorial" target="_blank">Understanding Releases and Provisional Data</a>

### Sensor Properties and Band/Wavelength Information

- `SENSOR_NAME`: The name of the hyperspectral sensor. All NEON sensors are JPL AVIRIS-NG sensors.
- `SENSOR_NUMBER`: The payload number, NIS1 = NEON Imaging Spectrometer, Payload 1. NEON Operates 3 separate payloads, each with a unique hyperspectral sensor (as well as unique LiDAR and Camera sensors) NEON also contracted out science flights over Hawaii (NEON PUUM site) by the Global Airborne Observatory (GAO), previously Carnegie Airborne Observatory (CAO)..
- `WL_FWHM_B###`: Center Wavelength (WL) and Full Width Half Max (FWHM) of the bandh in anoneters (nm)m

In addition there are some `system` properties, including information about the size of the asset, the band names (most of these are just band numbers but the QA bands have more descriptive names), as well as the start and end time of the collection.

## Filter an Image Collection

One of the most useful aspects of having AOP data ingested in Earth Engine is the ability to filter by properties, such as the site name, dates, sensors, etc. In this next section, we will show how to filter datasets to extract only data of interest. We'll use the NEON's <a href="https://www.neonscience.org/field-sites/harv" target="_blank">Harvard Forest (HARV)</a>, in Massachusettes.


```python
# See the years of data available for RGB data at a specified site:
site = 'HARV'

# Get the flight year and site information
rgb_flight_years = rgb.aggregate_array('FLIGHT_YEAR').getInfo()
rgb_sites = rgb.aggregate_array('NEON_SITE').getInfo()

print('\nYears of RGB data available in GEE for',site+':')
print([year_site[0] for year_site in zip(rgb_flight_years, rgb_sites) if site in year_site])
```

    
    Years of RGB data available in GEE for HARV:
    [2014, 2016, 2017, 2018, 2019, 2022, 2024, 2025]
    


```python
# Get the flight year and site information for REFL 001 data at the specified site
refl001_flight_years = refl001.aggregate_array('FLIGHT_YEAR').getInfo()
refl001_sites = refl001.aggregate_array('NEON_SITE').getInfo()

print('\nYears of Directional Reflectance data available in GEE for',site+':')
print([year_site[0] for year_site in zip(refl001_flight_years, refl001_sites) if site in year_site])
```

    
    Years of Directional Reflectance data available in GEE for HARV:
    [2014, 2016, 2017, 2018, 2019]
    


```python
# Get the flight year and site information for REFL 002 data at the specified site
refl002_flight_years = refl002.aggregate_array('FLIGHT_YEAR').getInfo()
refl002_sites = refl002.aggregate_array('NEON_SITE').getInfo()

print('\nYears of Bidirectional Reflectance data available in GEE for',site+':')
print([year_site[0] for year_site in zip(refl002_flight_years, refl002_sites) if site in year_site])
```

    
    Years of Bidirectional Reflectance data available in GEE for HARV:
    [2022, 2024, 2025]
    

Bidirectional data are available for HARV between 2022-2025. Now that you know the years of data available at HARV for each reflectance dataset, you can filter by date as follows:


```python
# Specify the start and end dates
year = 2019
start_date2019 = ee.Date.fromYMD(year, 1, 1) 
end_date2019 = start_date2019.advance(1, "year")

# Filter the RGB image collection on the site and dates
harv_rgb2019 = rgb.filterDate(start_date2019, end_date2019).filterMetadata('NEON_SITE', 'equals', site).mosaic()
```

## Add Data Layers to the Map

In order to visualize and interact with the dataset, we can use `geemap.Map()` as follows, to display Harvard Forest camera and directional reflectance imagery from 2019.


```python
Map = geemap.Map()

# Specify center location of HARV
# NEON field site information can be found on the NEON website here > https://www.neonscience.org/field-sites/harv
geo = ee.Geometry.Point([-72.17, 42.5])

# Set the visualization parameters so contrast is maximized
rgb_vis_params = {'min': 45, 'max': 200, 'gamma': .6}

# Add the RGB data as a layer to the Map
Map.addLayer(harv_rgb2019, rgb_vis_params, 'HARV 2019 RGB Camera');

# Center the map on the site center and set zoom level
Map.centerObject(geo, 11);

Map
```




<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/harv_camera_rgb.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/harv_camera_rgb.png" alt="Harvard Forest RGB Camera" width="800"><figcaption>Harvard Forest RGB Camera Layer</figcaption></a>
</figure><br>



## Surface Directional Reflectance

Next let's take a look at one of the directional reflectance datasets. We will pull in only the data bands, for this example. 

### Reflectance Data Bands


```python
Map = geemap.Map()

# Read in the first image of the SDR Image Collection
harv_refl2019 = refl001.filterDate(start_date2019, end_date2019).filterMetadata('NEON_SITE', 'equals', site).mosaic()

# Read in only the data bands, all of which start with "B", eg. "B001"
harv_refl2019_data = harv_refl2019.select('B.*')

# Set the visualization parameters so contrast is maximized, and display RGB bands (true-color image)
refl001_viz = {'min':0, 'max':1200, 'gamma':0.9, 'bands':['B053','B035','B019']};

# Add the reflectance data as a Layer to the Map
Map.addLayer(harv_refl2019_data, refl001_viz, 'Harvard Forest 2019 Directional Reflectance');

# Center the map on the site center and set zoom level
Map.centerObject(geo, 11);

Map
```



<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/harv_refl_rgb.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/harv_refl_rgb.PNG" alt="Harvard Forest Reflectance Data" width="800"><figcaption>Harvard Forest Reflectance Data Layer</figcaption></a>
</figure><br>



### Reflectance QA Bands

Before we used a regular expression to pull out only the bands starting with "B". We can also take a look at the remaining bands using a similar expression, but this time excluding bands starting with "B". These comprise all of the QA-related bands that provide additional information and context about the data bands. This next chunk of code prints out the IDs of all the QA bands.


```python
# Read in only the QA bands, none of which start with "B"
reflQA_bands = harv_refl2019.select('[^B].*')

# Create a dictionary of the band information
reflQA_band_info = reflQA_bands.getInfo()
type(reflQA_band_info)

# Loop through the band info dictionary to print out the ID of each band
print('QA bands:\n')
for i in range(len(reflQA_band_info['bands'])):
    print(reflQA_band_info['bands'][i]['id'])
```

    QA bands:
    
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
    

Most of these QA bands are related to the Atmospheric Correction (ATCOR), one of the spectrometer processing steps which converts Radiance to Reflectance. For more details on this process, NEON provides an Algorithm Theoretical Basis Document (ATBD), which is available on the NEON data portal and linked here: <a href="https://data.neonscience.org/api/v0/documents/NEON.DOC.001288vB?inline=true" target="_blank">NEON Imaging Spectrometer Radiance to Reflectance ATBD </a>. 

The `Weather_Quality_Indicator` is particularly useful for assessing data quality. The weather quality indicator includes information about the cloud conditions during the flight, as reported by the flight operators, where 1 corresponds to <10% cloud cover, 2 corresponds to 10-50% cloud cover, and 3 corresponds to >50% cloud cover. We recommend using only clear-sky data (1) for a typical analysis, as it results in the highest quality reflectance data.

You mayalso  be interested in the `Acquisition_Date` if, for example, you are linking field data collected on a specific date, or are interested in finding satellite data collected close in time to the AOP imagery.

The next chunks of code show how to add the Weather QA bands to the Map Layer.

### Weather Quality Indicator Band


```python
Map = geemap.Map()

harv_refl_weather_qa2019 = harv_refl2019.select(['Weather_Quality_Indicator']);

# Define a palette for the weather - to match NEON AOP's weather color conventions (green-yellow-red)
gyr_palette = ['green','yellow','red']

# Visualization parameters to display the weather bands (cloud conditions) with the green-yellow-red palette
weather_viz = {'min': 1, 'max': 3, 'palette': gyr_palette, 'opacity': 0.3};

# Add the RGB data as a layer to the Map
Map.addLayer(harv_refl_weather_qa2019, weather_viz, 'HARV 2019 Weather QA');

# Center the map on the site center and set zoom level
Map.centerObject(geo, 11);

Map
```




<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/harv_weather_qa2019.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/harv_weather_qa2019.PNG" alt="Harvard Forest 2019 Weather QA Map" width="800"><figcaption>Harvard Forest 2019 Weather QA Map Layer</figcaption></a>
</figure><br>



In 2019, the AOP was able to collect all but the easternmost flightline in green, or clear-sky weather conditions. Let's take a look at the data from 2018 for comparison:


```python
# Specify the start and end dates
year = 2018
start_date2018 = ee.Date.fromYMD(year, 1, 1) 
end_date2018 = start_date2018.advance(1, "year")

# Filter the reflectance image collection on the site and dates
harv_refl2018 = refl001.filterDate(start_date2018, end_date2018).filterMetadata('NEON_SITE', 'equals', site).mosaic()

Map = geemap.Map()

harv_refl_weather_qa2018 = harv_refl2018.select(['Weather_Quality_Indicator']);

# Define a palette for the weather - to match NEON AOP's weather color conventions (green-yellow-red)
gyr_palette = ['green','yellow','red']

# Visualization parameters to display the weather bands (cloud conditions) with the green-yellow-red palette
weather_viz = {'min': 1, 'max': 3, 'palette': gyr_palette, 'opacity': 0.3};

# Add the weather QA layer to the map
Map.addLayer(harv_refl_weather_qa2018, weather_viz, 'HARV 2019 Weather QA');

# Center the map on the site center and set zoom level
Map.centerObject(geo, 11);

Map
```




    Map(center=[42.5, -72.17], controls=(WidgetControl(options=['position', 'transparent_bg'], widget=HBox(childre…



We can see that in 2019, the weather conditions were sub-optimal for collecting. When working with the AOP data, this is important information to keep in mind - as the reflectance data (and other optical data, such as the camera data) collected in cloudy sky conditions are not directly comparable to data collected in clear skies.

## Recap

In this lesson, you learned how to access the six NEON datasets that are available in GEE: Bidirectional Reflectance (`HSI_REFL/002`), Directional Reflectance (`HSI_REFL/001`), Camera (`RGB/001`), and LiDAR-derived Digital Elevation (Terrain and Surface) Models (`DEM/001`), Ecosystem Structure / Canopy Height Model (`CHM/001`) and the Canopy Nitrogen Content (`CNC/002`) Model. You generated code to determine which AOP datasets are available in GEE for a given Image Collection. You explored the directional reflectance image properties and learned how to filter on metadata to pull out a subset of Images or a single Image from an Image Collection. You learned how to use the `geemap` package to add data layers to the interactive map panel. And lastly, you learned how to select and visualize the `Weather_Quality_Indicator` band, which is a useful first step in assessing the data quality of the AOP reflectance and camera imagery.

This is a great starting point for your own research!
