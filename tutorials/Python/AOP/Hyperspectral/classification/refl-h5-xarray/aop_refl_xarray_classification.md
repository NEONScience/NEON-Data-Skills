---
syncID: f685c4fab1004d95887228147dff37d9
title: "Tree Classification with NEON Airborne Imaging Spectrometer Data using Python xarray"
description: "Download, explore, interactively visualize, and perform a supervised classification using NEON AOP bidirectional reflectance data and TOS vegetation structure data."
dateCreated: 2025-07-30
authors: Bridget Hass
contributors: 
estimatedTime: 1 hr 30 minutes
packagesLibraries: 
topics: hyperspectral, remote-sensing
languageTool: GEE
dataProduct: DP1.10098.001, DP3.30006.001, DP3.30006.002
code1: 
tutorialSeries: 
urlTitle: refl-classification-pyxarray

---

# Tree Classification with NEON Airborne Imaging Spectrometer Data using Python xarray

**Summary**  

The National Ecological Observatory Network (NEON) Airborne Observation Platform (AOP) collects airborne remote sensing data, including hyperspectral reflectance data, over 81 sites across the United States and Puerto Rico. In this notebook we will show how to download and visualize reflectance data from NEON's [Smithsonian Environmental Research Center](https://www.neonscience.org/field-sites/serc) site (SERC) in Maryland. 

**Background**

The **NEON Imaging Spectrometer (NIS)** is an airborne [imaging spectrometer](https://www.neonscience.org/data-collection/imaging-spectrometer) built by JPL (AVIRIS-NG) and operated by the National Ecological Observatory Network's (NEON) Airborne Observation Platform (AOP). NEON's hyperspectral sensors collect measurements of sunlight reflected from the Earth's surface in 426 narrow (~5 nm) spectral channels spanning wavelengths between ~ 380 - 2500 nm. NEON's remote sensing data is intended to map and answer questions about a landscape, with ecological applications including identifying and classifying plant species and communities, mapping vegetation health, detecting disease or invasive species, and mapping droughts, wildfires, or other natural disturbances and their impacts. 

In 2024, NEON started producing bidirectional reflectance data products (including BRDF and topographic corrections). These are currently available for AOP data collected between 2022-2025. For more details on this newly revised data product, please refer to the tutorial: [Introduction to Bidirectional Hyperspectral Reflectance Data in Python](https://www.neonscience.org/resources/learning-hub/tutorials/neon-brdf-refl-h5-py).

NEON surveys sites spanning the continental US, during peak phenological greenness, capturing each site 3 out of every 5 years, for most terrestrial sites. AOP's [Flight Schedules and Coverage](https://www.neonscience.org/data-collection/flight-schedules-coverage) provide's more information about the current and past schedules.

More detailed information about NEON's airborne sampling design can be found in the paper: [Spanning scales: The airborne spatial and temporal sampling design of the National Ecological Observatory Network](https://besjournals.onlinelibrary.wiley.com/doi/10.1111/2041-210X.13942).

**Requirements**  
 - *No Python setup requirements if connected to the workshop cloud instance!*  
 - **Local Only** Set up Python Environment - See **setup_instructions.md** in the `/setup/` folder to set up a local compatible Python environment

 - NEON API Token (optional, but strongly recommended), see [NEON API Tokens Tutorial](https://www.neonscience.org/resources/learning-hub/tutorials/neon-api-tokens-tutorial) for more details on how to create and set up your token in Python (and R). Once you create your token (on the [NEON User Accounts](https://www.neonscience.org/about/user-accounts)) page, this notebook will show you how to set it as an environment variable and use it for downloading AOP data.

**Download the NEON Flight Boundary Shapefile:** <a href="https://www.neonscience.org/sites/default/files/AOP_flightBoxes_0.zip" class="link--button link--arrow">AOP_flightBoxes.zip</a>

**Learning Objectives**  
- Explore NEON airborne and field (instrumented, observational) shapefiles to understand what colloated data are available
- Use the neonutilities package to determine available reflectance data and download
- Use a custom function to convert reflectance data into an xarray dataset
- Create some interactive visualizations of reflectance data
- Run a random forest model to classify trees using reflectance data and data generated from vegetation structure (as the training data set)
- Evaluate model results
- Understand data QA considerations and potential steps to improve classification results

**Tutorial Outline**  

1. Setup
2. Visualize NEON AOP, OS, and IS shapefiles at SERC
3. Find available NEON reflectance data at SERC and download
4. Read in and visualize reflectance data interactively
5. Create a random forest model to predict the tree families from the reflectance spectra

## 1. Setup

### 1.1 Import Python Packages

If not already installed, install the `neonutilities` and `python-dotenv` packages using `pip` as follows:
- `!pip install neonutilities`
- `!pip install python-dotenv`


```python
# Import required libraries, grouped by functionality
# --- System and utility packages ---
from datetime import timedelta
import dotenv
import os
import requests
#import sys
from zipfile import ZipFile

# --- Data handling and scientific computing ---
import math
import numpy as np
import pandas as pd

# --- Geospatial and multi-dimensional raster data ---
import geopandas as gpd
import h5py
import rasterio as rio  # work with geospatial raster data
import rioxarray as rxr  # work with raster arrays
from shapely import geometry
from shapely.geometry.polygon import orient
from osgeo import gdal  # work with raster and vector geospatial data
import xarray as xr

# --- Plotting and visualization ---
import holoviews as hv
import hvplot.xarray  # plot multi-dimensional arrays
# import hvplot.pandas  # plot DataFrames/Series
import seaborn as sns
from matplotlib import pyplot as plt
import folium
# import folium.plugins
from branca.element import Figure
from IPython.display import display
from skimage import io

# --- neonutilities ---
import neonutilities as nu
```


### 1.2 Set your NEON Token

Define your token. You can set this up on your NEON user account page, https://data.neonscience.org/myaccount. Please refer to the [NEON API Tokens Tutorial](https://www.neonscience.org/resources/learning-hub/tutorials/neon-api-tokens-tutorial) for more details on how to create and set up your token in Python (and R).



```python
# method 1: set the NEON_TOKEN directly in your code
NEON_TOKEN='YOUR_TOKEN_HERE'
```

method 2: set the token as an environment variable using the dotenv package
```
dotenv.set_key(dotenv_path=".env",
key_to_set="NEON_TOKEN",
value_to_set="YOUR_TOKEN_HERE")
```

## 2. Visualize NEON AOP, OS, and IS shapefiles at SERC

In this next section, we will look at some of the NEON spatial data, honing in on our site of interest (SERC). We will look at the AOP flight box (the area over which the NEON AOP platform flies, including multiple priority boxes), the IS tower airshed, and the OS terrestrial sampling boundaries. This will provide an overview of how the NEON sites are set up, and the spatial overlap between the field and airborne data.

First, let's define a function that will download data from a url. We will use this to download shapefile boundares of the NEON AOP flight boxes, as well as the IS and OS shapefiles in order to see the spatial extent of the various data samples that NEON collects.


```python
# function to download data stored on the internet in a public url to a local file
def download_url(url,download_dir):
    if not os.path.isdir(download_dir):
        os.makedirs(download_dir)
    filename = url.split('/')[-1]
    r = requests.get(url, allow_redirects=True)
    file_object = open(os.path.join(download_dir,filename),'wb')
    file_object.write(r.content)
```

### 2.1 NEON AOP flight box boundary

Download, Unzip, and Open the shapefile (.shp) containing the AOP flight box boundaries, which can also be downloaded from [NEON Spatial Data and Maps](https://www.neonscience.org/data-samples/data/spatial-data-maps). Read this shapefile into a `geodataframe`, explore the contents, and check the coordinate reference system (CRS) of the data.


```python
# Download and Unzip the NEON Flight Boundary Shapefile
aop_flight_boundary_url = "https://www.neonscience.org/sites/default/files/AOP_flightBoxes_0.zip"
# Use download_url function to save the file to a directory
os.makedirs('./data/shapefiles', exist_ok=True)
download_url(aop_flight_boundary_url,'./data/shapefiles')
# Unzip the file
with ZipFile(f"./data/shapefiles/{aop_flight_boundary_url.split('/')[-1]}", 'r') as zip_ref:
    zip_ref.extractall('./data/shapefiles')
```


```python
aop_flightboxes = gpd.read_file("./data/shapefiles/AOP_flightBoxes/AOP_flightboxesAllSites.shp")
aop_flightboxes.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>domain</th>
      <th>domainName</th>
      <th>siteName</th>
      <th>siteID</th>
      <th>siteType</th>
      <th>sampleType</th>
      <th>priority</th>
      <th>version</th>
      <th>flightbxID</th>
      <th>geometry</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>D01</td>
      <td>Northeast</td>
      <td>Bartlett Experimental Forest NEON</td>
      <td>BART</td>
      <td>Gradient</td>
      <td>Terrestrial</td>
      <td>1</td>
      <td>1</td>
      <td>D01_BART_R1_P1_v1</td>
      <td>POLYGON ((-71.33426 43.99197, -71.33423 44.081...</td>
    </tr>
    <tr>
      <th>1</th>
      <td>D01</td>
      <td>Northeast</td>
      <td>Harvard Forest &amp; Quabbin Watershed NEON</td>
      <td>HARV</td>
      <td>Core</td>
      <td>Terrestrial</td>
      <td>1</td>
      <td>1</td>
      <td>D01_HARV_C1_P1_v1</td>
      <td>POLYGON ((-72.14819 42.57510, -72.14776 42.383...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>D01</td>
      <td>Northeast</td>
      <td>Harvard Forest &amp; Quabbin Watershed NEON</td>
      <td>HARV</td>
      <td>Core</td>
      <td>Terrestrial</td>
      <td>3</td>
      <td>1</td>
      <td>D01_HARV_C1_P3_v1</td>
      <td>POLYGON ((-72.10812 42.43653, -72.14788 42.436...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>D01</td>
      <td>Northeast</td>
      <td>Lower Hop Brook NEON</td>
      <td>HOPB</td>
      <td>Core</td>
      <td>Aquatic</td>
      <td>2</td>
      <td>1</td>
      <td>D01_HOPB_C1_P2_v1</td>
      <td>POLYGON ((-72.36635 42.46399, -72.36635 42.514...</td>
    </tr>
    <tr>
      <th>4</th>
      <td>D19</td>
      <td>Taiga</td>
      <td>Healy NEON</td>
      <td>HEAL</td>
      <td>Gradient</td>
      <td>Terrestrial</td>
      <td>1</td>
      <td>1</td>
      <td>D19_HEAL_R3_P1_v1</td>
      <td>POLYGON ((-149.31505 63.82981, -149.31505 63.9...</td>
    </tr>
  </tbody>
</table>
</div>



Next, let's examine the AOP flightboxes polygons at the SERC site.


```python
site_id = 'SERC'
aop_flightboxes[aop_flightboxes.siteID == site_id]
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>domain</th>
      <th>domainName</th>
      <th>siteName</th>
      <th>siteID</th>
      <th>siteType</th>
      <th>sampleType</th>
      <th>priority</th>
      <th>version</th>
      <th>flightbxID</th>
      <th>geometry</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>10</th>
      <td>D02</td>
      <td>Mid-Atlantic</td>
      <td>Smithsonian Environmental Research Center NEON</td>
      <td>SERC</td>
      <td>Gradient</td>
      <td>Terrestrial</td>
      <td>1</td>
      <td>1</td>
      <td>D02_SERC_R1_P1_v1</td>
      <td>POLYGON ((-76.62107 38.84504, -76.62107 38.935...</td>
    </tr>
  </tbody>
</table>
</div>



We can see the site `geodataframe` consists of a single polygon, that we want to include in our study site (sometimes NEON sites may have more than one polygon, as there are sometimes multiple areas, with different priorities for collection).


```python
# write this to a new variable called "site_polygon"
site_aop_polygon = aop_flightboxes[aop_flightboxes.siteID == site_id]
# subset to only include columns of interest
site_aop_polygon = site_aop_polygon[['domain','siteName','siteID','sampleType','flightbxID','priority','geometry']]
# rename the flightbxID column to flightboxID for clarity
site_aop_polygon = site_aop_polygon.rename(columns={'flightbxID':'flightboxID'})
site_aop_polygon # display site polygon
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>domain</th>
      <th>siteName</th>
      <th>siteID</th>
      <th>sampleType</th>
      <th>flightboxID</th>
      <th>priority</th>
      <th>geometry</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>10</th>
      <td>D02</td>
      <td>Smithsonian Environmental Research Center NEON</td>
      <td>SERC</td>
      <td>Terrestrial</td>
      <td>D02_SERC_R1_P1_v1</td>
      <td>1</td>
      <td>POLYGON ((-76.62107 38.84504, -76.62107 38.935...</td>
    </tr>
  </tbody>
</table>
</div>



Next we can visualize our region of interest and the exterior boundary polygon containing ROIs. First add a function to help reformat bounding box coordinates to work with leaflet notation.


```python
# Function to convert a bounding box for use in leaflet notation
def convert_bounds(bbox, invert_y=False):
    """
    Helper method for changing bounding box representation to leaflet notation

    ``(lon1, lat1, lon2, lat2) -> ((lat1, lon1), (lat2, lon2))``
    """
    x1, y1, x2, y2 = bbox
    if invert_y:
        y1, y2 = y2, y1
    return ((y1, x1), (y2, x2))
```

Now let's define a function that uses folium to display the bounding box polygon on a map. We will first use this function to visualize the AOP flight box polygon, and then we will use it to visualize the IS and OS polygons as well.


```python
def plot_folium_shapes(
    shapefiles,      # list of file paths or GeoDataFrames
    styles=None,     # list of style dicts for each shapefile
    names=None,      # list of names for each shapefile
    map_center=None, # [lat, lon]
    zoom_start=12
):
    import pyproj
    # If no center is provided, use the centroid of the first shapefile (projected)
    if map_center is None:
        if isinstance(shapefiles[0], str):
            gdf = gpd.read_file(shapefiles[0])
        else:
            gdf = shapefiles[0]
        # Project to Web Mercator (EPSG:3857) for centroid calculation
        gdf_proj = gdf.to_crs(epsg=3857)
        centroid = gdf_proj.geometry.centroid.iloc[0]
        # Convert centroid back to lat/lon
        lon, lat = gpd.GeoSeries([centroid], crs="EPSG:3857").to_crs(epsg=4326).geometry.iloc[0].coords[0]
        map_center = [lat, lon]
    
    m = folium.Map(
        location=map_center,
        zoom_start=zoom_start,
        tiles=None
    )
    folium.TileLayer(
        tiles='https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
        attr='Google',
        name='Google Satellite'
    ).add_to(m)
    
    for i, shp in enumerate(shapefiles):
        if isinstance(shp, str):
            gdf = gpd.read_file(shp)
        else:
            gdf = shp
        style = styles[i] if styles and i < len(styles) else {}
        layer_name = names[i] if names and i < len(names) else f"Shape {i+1}"
        folium.GeoJson(
            gdf,
            name=layer_name,
            style_function=lambda x, style=style: style,
            tooltip=layer_name
        ).add_to(m)
    
    folium.LayerControl().add_to(m)
    return m
```


```python

map1 = plot_folium_shapes(
    shapefiles=[site_aop_polygon],
    names=['NEON AOP Flight Bounding Box']
)

map1
```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-classification/xarray/serc_aop_flightbox.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-classification/xarray/serc_aop_flightbox.png" alt="AOP SERC Flight Box" style="max-width: 100%; height: auto;">
	<figcaption>AOP flight box polygon at the SERC site.</figcaption>
	</a>
</figure> 

### 2.2 NEON OS terrestrial sampling boundaries

We will follow a similar process to download and visualize the NEON OS terrestrial sampling boundaries. The OS terrestrial sampling boundaries are also available as a shapefile, which can be downloaded from [NEON Spatial Data and Maps](https://www.neonscience.org/data-samples/data/spatial-data-maps) page.


```python
# Download and Unzip the NEON Terrestrial Field Sampling Boundaries Shapefile
neon_field_boundary_file = "https://www.neonscience.org/sites/default/files/Field_Sampling_Boundaries_202503.zip"
# Use download_url function to save the file to the data directory
download_url(neon_field_boundary_file,'./data/shapefiles')
```


```python
# Unzip the file
with ZipFile(f"./data/shapefiles/Field_Sampling_Boundaries_202503.zip", 'r') as zip_ref:
    zip_ref.extractall('./data/shapefiles')
```


```python
neon_terr_bounds = gpd.read_file("./data/shapefiles/Field_Sampling_Boundaries/terrestrialSamplingBoundaries.shp")
neon_terr_bounds.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>domainNumb</th>
      <th>domainName</th>
      <th>siteType</th>
      <th>siteName</th>
      <th>siteID</th>
      <th>siteHost</th>
      <th>areaKm2</th>
      <th>acres</th>
      <th>activeSmpl</th>
      <th>geometry</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>D01</td>
      <td>Northeast</td>
      <td>Core Terrestrial</td>
      <td>Harvard Forest</td>
      <td>HARV</td>
      <td>Harvard University, LTER</td>
      <td>11.737025</td>
      <td>2900.270496</td>
      <td>Y</td>
      <td>MULTIPOLYGON (((-72.19445 42.53763, -72.19506 ...</td>
    </tr>
    <tr>
      <th>1</th>
      <td>D02</td>
      <td>Mid-Atlantic</td>
      <td>Gradient Terrestrial</td>
      <td>Blandy Experimental Farm</td>
      <td>BLAN</td>
      <td>University of Virginia</td>
      <td>2.694233</td>
      <td>665.756840</td>
      <td>Y</td>
      <td>POLYGON ((-78.07958 39.05886, -78.07967 39.058...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>D02</td>
      <td>Mid-Atlantic</td>
      <td>Gradient Terrestrial</td>
      <td>Smithsonian Environmental Research Center</td>
      <td>SERC</td>
      <td>Smithsonian Institution</td>
      <td>1.578849</td>
      <td>390.140625</td>
      <td>Y</td>
      <td>POLYGON ((-76.56496 38.89008, -76.56181 38.890...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>D03</td>
      <td>Southeast</td>
      <td>Gradient Terrestrial</td>
      <td>Disney Wilderness Preserve</td>
      <td>DSNY</td>
      <td>The Nature Conservancy</td>
      <td>48.504342</td>
      <td>11985.635953</td>
      <td>Y</td>
      <td>MULTIPOLYGON (((-81.42341 28.14041, -81.42336 ...</td>
    </tr>
    <tr>
      <th>4</th>
      <td>D03</td>
      <td>Southeast</td>
      <td>Core Terrestrial</td>
      <td>Ordway Swisher Biological Station</td>
      <td>OSBS</td>
      <td>University of Florida Foundation</td>
      <td>36.808639</td>
      <td>9095.576345</td>
      <td>Y</td>
      <td>POLYGON ((-82.00711 29.67322, -82.01146 29.673...</td>
    </tr>
  </tbody>
</table>
</div>




```python
# save the boundaries for the site to a new variable called "site_terr_bounds"
site_terr_bounds = neon_terr_bounds[neon_terr_bounds.siteID == site_id]
site_terr_bounds.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>domainNumb</th>
      <th>domainName</th>
      <th>siteType</th>
      <th>siteName</th>
      <th>siteID</th>
      <th>siteHost</th>
      <th>areaKm2</th>
      <th>acres</th>
      <th>activeSmpl</th>
      <th>geometry</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>2</th>
      <td>D02</td>
      <td>Mid-Atlantic</td>
      <td>Gradient Terrestrial</td>
      <td>Smithsonian Environmental Research Center</td>
      <td>SERC</td>
      <td>Smithsonian Institution</td>
      <td>1.578849</td>
      <td>390.140625</td>
      <td>Y</td>
      <td>POLYGON ((-76.56496 38.89008, -76.56181 38.890...</td>
    </tr>
    <tr>
      <th>37</th>
      <td>D02</td>
      <td>Mid-Atlantic</td>
      <td>Gradient Terrestrial</td>
      <td>Smithsonian Environmental Research Center Addi...</td>
      <td>SERC</td>
      <td>Smithsonian Institution</td>
      <td>8.748920</td>
      <td>2154.938095</td>
      <td>Y</td>
      <td>MULTIPOLYGON (((-76.55686 38.85611, -76.55699 ...</td>
    </tr>
  </tbody>
</table>
</div>



### 2.3 NEON IS tower footprint boundaries

Lastly, we'll download and read in the IS tower footprint shapefile, which represents the area of the airshed over which the IS tower collects data. This shapefile is available from the [NEON Spatial Data and Maps](https://www.neonscience.org/data-samples/data/spatial-data-maps) page, but is pre-downloaded for convenience.


```python
# Unzip the 90 percent footprint tower airshed file
with ZipFile(f"./data/90percentfootprint.zip", 'r') as zip_ref:
    zip_ref.extractall('./data/shapefiles')
```


```python

neon_tower_airshed = gpd.read_file("./data/shapefiles/90percentfootprint/90percent_footprint.shp")
neon_tower_airshed.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Domain</th>
      <th>DomainName</th>
      <th>SiteName</th>
      <th>Type</th>
      <th>Zone</th>
      <th>Notes</th>
      <th>Source</th>
      <th>SiteID</th>
      <th>BUFF_DIST</th>
      <th>geometry</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>16.0</td>
      <td>Pacific Northwest</td>
      <td>Abby Road</td>
      <td>Gradient</td>
      <td>10.0</td>
      <td>major</td>
      <td>1-D absolute_FP_flux.csv</td>
      <td>ABBY</td>
      <td>210.0</td>
      <td>POLYGON ((-122.32828 45.76120, -122.32828 45.7...</td>
    </tr>
    <tr>
      <th>1</th>
      <td>1.0</td>
      <td>Northeast</td>
      <td>Bartlett Experimental Forest</td>
      <td>Gradient</td>
      <td>19.0</td>
      <td>major</td>
      <td>1-D absolute_FP_flux.csv</td>
      <td>BART</td>
      <td>530.0</td>
      <td>POLYGON ((-71.28731 44.06388, -71.29385 44.064...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>1.0</td>
      <td>Northeast</td>
      <td>Bartlett Experimental Forest</td>
      <td>Gradient</td>
      <td>19.0</td>
      <td>secondary</td>
      <td>1-D absolute_FP_flux.csv</td>
      <td>BART</td>
      <td>530.0</td>
      <td>POLYGON ((-71.28940 44.05935, -71.28731 44.063...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>18.0</td>
      <td>Tundra</td>
      <td>Barrow Environmental Observatory</td>
      <td>Gradient</td>
      <td>4.0</td>
      <td>major</td>
      <td>1-D absolute_FP_flux.csv</td>
      <td>BARR</td>
      <td>700.0</td>
      <td>POLYGON ((-156.61936 71.28241, -156.61041 71.2...</td>
    </tr>
    <tr>
      <th>4</th>
      <td>18.0</td>
      <td>Tundra</td>
      <td>Barrow Environmental Observatory</td>
      <td>Gradient</td>
      <td>4.0</td>
      <td>secondary</td>
      <td>1-D absolute_FP_flux.csv</td>
      <td>BARR</td>
      <td>700.0</td>
      <td>POLYGON ((-156.61936 71.28241, -156.62351 71.2...</td>
    </tr>
  </tbody>
</table>
</div>




```python
# save the boundaries for the site to a new variable called "site_terr_bounds"
site_tower_bounds = neon_tower_airshed[neon_tower_airshed.SiteID == site_id]
site_tower_bounds.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Domain</th>
      <th>DomainName</th>
      <th>SiteName</th>
      <th>Type</th>
      <th>Zone</th>
      <th>Notes</th>
      <th>Source</th>
      <th>SiteID</th>
      <th>BUFF_DIST</th>
      <th>geometry</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>49</th>
      <td>2.0</td>
      <td>Mid-Atlantic</td>
      <td>Smithsonian Environmental Research Center</td>
      <td>Gradient</td>
      <td>18.0</td>
      <td>major</td>
      <td>1-D absolute_FP_flux.csv</td>
      <td>SERC</td>
      <td>1020.0</td>
      <td>POLYGON ((-76.56001 38.89008, -76.57162 38.891...</td>
    </tr>
    <tr>
      <th>50</th>
      <td>2.0</td>
      <td>Mid-Atlantic</td>
      <td>Smithsonian Environmental Research Center</td>
      <td>Gradient</td>
      <td>18.0</td>
      <td>secondary</td>
      <td>1-D absolute_FP_flux.csv</td>
      <td>SERC</td>
      <td>1020.0</td>
      <td>POLYGON ((-76.54889 38.88708, -76.56001 38.890...</td>
    </tr>
    <tr>
      <th>51</th>
      <td>2.0</td>
      <td>Mid-Atlantic</td>
      <td>Smithsonian Environmental Research Center</td>
      <td>Gradient</td>
      <td>18.0</td>
      <td>major</td>
      <td>1-D absolute_FP_flux.csv</td>
      <td>SERC</td>
      <td>1020.0</td>
      <td>POLYGON ((-76.55777 38.88106, -76.55801 38.881...</td>
    </tr>
  </tbody>
</table>
</div>



### 2.4 Visualize AOP, OS, and IS boundaries together

Now that we've read in all the shapefiles into geodataframes, we can visualize them all together as follows. We will use the `plot_folium_shapes` function defined above, and define a `styles` list of dictionaries specifying the color, so that we can display each polygon with a different color.


```python
neon_shapefiles = [site_aop_polygon, site_terr_bounds, site_tower_bounds]

# define a list of styles for the polygons
# each style is a dictionary with 'fillColor' and 'color' keys
styles = [
    {'fillColor': '#228B22', 'color': '#228B22'}, # green
    {'fillColor': '#00FFFFFF', 'color': '#00FFFFFF'}, # blue
    {'fillColor': '#FF0000', 'color': '#FF0000'}, # red
    {'fillColor': '#FFFF00', 'color': '#FFFF00'}, # yellow
]

map2 = plot_folium_shapes(
    shapefiles=neon_shapefiles,
    names=['NEON AOP Flight Bounding Box', 'NEON Terrestrial Sampling Boundaries', 'NEON Tower Airshed'],
    styles=styles
)

map2
```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-classification/xarray/serc_aop_os_is_shapefiles.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-classification/xarray/serc_aop_os_is_shapefiles.png" alt="AOP SERC Flight Box" style="max-width: 100%; height: auto;">
	<figcaption>AOP, OS, and IS polygons at the SERC site.</figcaption>
	</a>
</figure> 


Above we can see the SOAP flightbox, and the exterior TOS boundary polygon which shows the extent of the area where observational data are collected.

## 3. Find available NEON reflectance data and download

Finally we can look at the available NEON hyperspectral reflectance data, which are delivered as 1 km by 1 km hdf5 files (also called tiles) over the site. The next figure we make will make it clear why the files are called tiles. First, we will determine the available reflectance data, and then pull in some metadata shapefiles from another L3 AOP data product, derived from the lidar data.

NEON hyperspectral reflectance data are currently available under two different revisions, as AOP is in the process of implementing a BRDF (Bidirectional Reflectance Distribution Function), but this has not been applied to the full archive of data yet. These data product IDs are DP3.30006.001 (directional surface reflectance), and DP3.30006.002 (bidirectional surface reflectance). The bidirectional surface reflectance data include BRDF and topographic corrections, which helps correct for differences in illumination throughout the flight. 

### 3.1 Find available data
Let's see what data are available at the SERC site for each of these data products using the `neonutilities` `list_available_dates` function as follows:


```python
# define the data product IDs for the reflectance data
refl_rev1_dpid = 'DP3.30006.001'
refl_rev2_dpid = 'DP3.30006.002'
```


```python
print(f'Directional Reflectance Data Available at NEON Site {site_id}:')
nu.list_available_dates(refl_rev1_dpid,site_id)
```

    Directional Reflectance Data Available at NEON Site SERC:
    

    RELEASE-2025 Available Dates: 2016-07, 2017-07, 2017-08, 2019-05, 2021-08
    


```python
print(f'Bidirectional Reflectance Data Available at NEON Site {site_id}:')
nu.list_available_dates(refl_rev2_dpid,site_id)
```

    Bidirectional Reflectance Data Available at NEON Site SERC:
    

    PROVISIONAL Available Dates: 2022-05, 2025-06
    

The dates provided are the year and month that the data were published (YYYY-MM). A single site may be collected over more than one month, so this publish date typically represents the month where the majority of the flight lines were collected. There are released directional reflectance data available from 2016 to 2021, and provisional bidirectional reflectance data available in 2022 and 2025. As of 2025, bidirectional data are only available provisionally because they were processed in 2024 (there is a year lag-time before data is released to allow for time to review for data quality issues).

For this exercise, we'll look at the most recent data, from 2025. You may wish to consider other factors, for example if you collected field data in a certain year, you are looking at a year when there was a recent disturbance, or if you want to find the clearest weather data (data are not always collected in optimal sky conditions). For SERC, the most recent clear (<10% cloud cover) weather collection to date was in 2017, so this directional reflectance data may be another good option to consider for your analysis.

For this lesson, we will use the 2025 bidirectional reflectance data, which is provisional.


```python
year = '2025'
```

### 3.2 Download NEON Lidar data using neonutilities by_file_aop

We can download the reflectance data either using the neonutilities function `nu.by_file_aop`, which downloads all tiles for the entire site for a given year, or `nu.by_tile_aop`. To figure out the inputs of these functions, you can type `nu.by_tile_aop?`, for example. 

AOP data are projected into a WGS84 coordinate system, with coordinates in UTM x, y. When using `nu.by_tile_aop` you need to specify the UTM easting and northing values for the tiles you want to download. If you're not sure the extent of the site, you can use the function `nu.get_aop_tile_extents`. Let's do that here, for the SOAP site collected in 2024. First set up your NEON token as follows, replacing the `"YOUR TOKEN HERE"` string with the token copied from the NEON "[My Account](https://data.neonscience.org/myaccount)" page. This will help speeed up downloads, and is strongly recommended (and will likely soon be required) for interacting with the NEON data via the API.

```
dotenv.set_key(dotenv_path=".env",
key_to_set="NEON_TOKEN",
value_to_set="YOUR TOKEN HERE")
```


```python
serc2025_utm_extents = nu.get_aop_tile_extents(refl_rev2_dpid, 
                                               site_id,
                                               year,
                                               token=os.environ.get("NEON_TOKEN"))
```

    Easting Bounds: (358000, 370000)
    Northing Bounds: (4298000, 4312000)
    

The AOP collection over SERC in 2025 extends from UTM 358000 - 370000 m (Easting) and 4298000 - 4312000 m (Northing). To display a list of the extents of every tile, you can print `serc2025_utm_extents`. This is sometimes useful when trying to determine the extents of irregularly shaped sites.

We can also look at the full extents by downloading one of the smaller lidar raster data products to start. The L3 lidar data products include metadata shapefiles that can be useful for understanding the spatial extents of the individual files that comprise the data product. To show how to look at these shapefiles, we can download the Canopy Height Model data (DP3.30015.001). The next cell shows how to do this:


```python
# download all CHM tiles (https://data.neonscience.org/data-products/DP3.30015.001)
nu.by_file_aop(dpid='DP3.30015.001', # Ecosystem Structure / CHM 
               site=site_id,
               year=year,
               include_provisional=True,
               token='NEON_TOKEN',
               savepath='./data')
```


```python
# Unzip the lidar tile boundary file
with ZipFile(f"./data/shapefiles/2025_SERC_7_TileBoundary.zip", 'r') as zip_ref:
    zip_ref.extractall('./data/shapefiles/2025_SERC_7_TileBoundary')
```


```python
aop_tile_boundaries = gpd.read_file("./data/shapefiles/2025_SERC_7_TileBoundary/shps/NEON_D02_SERC_DPQA_2025_merged_tiles_boundary.shp")
aop_tile_boundaries.head()
```



<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>TileID</th>
      <th>geometry</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2025_SERC_7_358000_4300000</td>
      <td>POLYGON ((358958.450 4300999.990, 358959.030 4...</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2025_SERC_7_358000_4301000</td>
      <td>POLYGON ((358999.990 4301657.090, 358999.990 4...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2025_SERC_7_358000_4302000</td>
      <td>POLYGON ((358999.990 4302731.120, 358999.980 4...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2025_SERC_7_358000_4303000</td>
      <td>POLYGON ((358999.990 4303918.030, 358999.990 4...</td>
    </tr>
    <tr>
      <th>4</th>
      <td>2025_SERC_7_358000_4304000</td>
      <td>POLYGON ((358999.990 4304833.100, 358999.990 4...</td>
    </tr>
  </tbody>
</table>
</div>




```python
# append this last boundary file to the existing neon_shapefiles list
neon_shapefiles.append(aop_tile_boundaries)

# plot all shapefiles together
map3 = plot_folium_shapes(
    shapefiles=neon_shapefiles,
    names=['NEON AOP Flight Bounding Box', 'NEON Terrestrial Sampling Boundaries', 'NEON Tower Airshed', 'AOP Tile Boundaries'],
    styles=styles,
    zoom_start=12
)

map3
```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-classification/xarray/serc_aop_tiles.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-classification/xarray/serc_aop_tiles.png" alt="AOP SERC Flight Box" style="max-width: 100%; height: auto;">
	<figcaption>AOP, OS, and IS polygons at the SERC site.</figcaption>
	</a>
</figure> 


From the image above, you can see why the data are called "tiles"! The individual tiles make up a grid comprising the full site. These smaller areas make it easier to process the large data, and allow for batch processing instead of running an operation on a huge file, which might cause memory errors.

### 3.3 Download NEON Reflectance Data using neonutilities by_tile_aop

Now that we've explored the spatial extent of the NEON airborne data, as well as the OS terrestrial sampling plots and the IS tower airshed, we can start playing with the data! 
First, let's download a single tile to start. For this exercise we'll download the tile that encompasses the NEON tower, since there is typically more OS sampling in the NEON tower plots. The tile of interest for us is `365000_4305000` (note that AOP tiles are named by the SW or lower-left coordinate of the tile).

You can specify the download path using the `savepath` variable. Let's set it to a data directory in line with the root directory where we're working, in this case we'll set it to `./data/NEON/refl`. 

The reflectance data are large in size (especially for an entire site's worth of data), so by default the download functions will display the expected download size and ask if you want to proceed with the download (y/n). The reflectance tile downloaded below is ~ 660 MB in size, so make sure you have enough space on your local disk (or cloud platform) before downloading. If you want to download without being prompted to continue, you can set the input variable `check_size=False`.

By default the files will be downloaded following the same structure that they are stored in on Google Cloud Storage, so the actual data files are nested in sub-folders. We encourage you to navigate through the `data/DP3.30006.002` folder, and explore the additional metadata (such as QA reports) that are downloaded along with the data.


```python
# download the tile that encompasses the NEON tower
nu.by_tile_aop(dpid='DP3.30006.002',
               site=site_id,
               year=2025,
               easting=364005,
               northing=4305005,
               include_provisional=True,
               token='NEON_TOKEN',
               check_size=False,
               savepath='./data')
```

You can either navigate to the download folder in File Explorer, or to programmatically see what files were downloaded, you can display the files as follows:


```python
# see all files that were downloaded (including data, metadata, and READMEs):
for root, dirs, files in os.walk(r'data\DP3.30006.002'):
    for name in files:
        print(os.path.join(root, name))  # print file name
```

    data\DP3.30006.002\citation_DP3.30006.002_PROVISIONAL.txt
    data\DP3.30006.002\issueLog_DP3.30006.002.csv
    data\DP3.30006.002\neon-aop-provisional-products\2025\FullSite\D02\2025_SERC_7\L3\Spectrometer\Reflectance\NEON_D02_SERC_DP3_364000_4305000_bidirectional_reflectance.h5
    data\DP3.30006.002\neon-publication\NEON.DOM.SITE.DP3.30006.002\SERC\20250601T000000--20250701T000000\basic\NEON.D02.SERC.DP3.30006.002.readme.20250719T050120Z.txt
    

You can see there are several .txt and .csv files in addition to the .h5 data file (NEON_D02_SERC_DP3_364000_4305000_bidirectional_reflectance.h5). These include citation information: `citation_DP3.30006.002_PROVISIONAL.txt`, an issue log: `issueLog_DP3.30006.002.csv`, and a README: `NEON.D02.SERC.DP3.30006.002.readme.20250719T050120Z.txt`. We encourage you to look through these files, particularly the issue log, which conveys information about issues and the resolution for the data product in question. Make sure there is not a known issue with the data you downloaded, especially since it is provisional.

If you only want to see the names of the .h5 reflectance data you downloaded, you can modify the code as follows:


```python
# see only the .h5 files that were downloaded
for root, dirs, files in os.walk(r'.\data\DP3.30006.002'):
    for name in files:
        if name.endswith('.h5'):
            print(os.path.join(root, name))  # print file name
```

    .\data\DP3.30006.002\neon-aop-provisional-products\2025\FullSite\D02\2025_SERC_7\L3\Spectrometer\Reflectance\NEON_D02_SERC_DP3_364000_4305000_bidirectional_reflectance.h5
    

Success! We've now downloaded a NEON bidirectional surface reflectance tile into our data directory.

## 4. Read in and visualize reflectance data interactively

### 4.1 Convert Reflectance Data to an xarray Dataset

The function below will read in a NEON reflectance hdf5 dataset and export an xarray dataset. According to the `xarray` documentation, "xarray makes working with labelled multi-dimensional arrays in Python simple, efficient, and fun!" `rioxarray` is simply the rasterio xarray extension, so you can work with xarray for geospatial data.


```python
def aop_h5refl2xarray(h5_filename):
    """
    Reads a NEON AOP reflectance HDF5 file and returns an xarray.Dataset with reflectance and weather quality indicator data.

    Parameters
    ----------
    h5_filename : str
        Path to the NEON AOP reflectance HDF5 file.

    Returns
    -------
    dsT : xarray.Dataset
        An xarray Dataset containing:
            - 'reflectance': DataArray of reflectance values (y, x, wavelengths)
            - 'weather_quality_indicator': DataArray of weather quality indicator (y, x)
            - Coordinates: y (UTM northing), x (UTM easting), wavelengths, fwhm, good_wavelengths
            - Metadata attributes: projection, spatial_ref, EPSG, no_data_value, scale_factor, bad_band_window1, bad_band_window2, etc.
    """
    import h5py
    import numpy as np
    import xarray as xr

    with h5py.File(h5_filename) as hdf5_file:
        print('Reading in ', h5_filename)
        sitename = list(hdf5_file.keys())[0]
        h5_refl_group = hdf5_file[sitename]['Reflectance']
        refl_dataset = h5_refl_group['Reflectance_Data']
        refl_array = refl_dataset[()].astype('float32')

        # Transpose and flip reflectance data
        refl_arrayT = np.transpose(refl_array, (1, 0, 2))
        refl_arrayT = refl_array[::-1, :, :]

        refl_shape = refl_arrayT.shape
        wavelengths = h5_refl_group['Metadata']['Spectral_Data']['Wavelength'][:]
        fwhm = h5_refl_group['Metadata']['Spectral_Data']['FWHM'][:]

        # Weather Quality Indicator: transpose and flip to match reflectance
        wqi_array = h5_refl_group['Metadata']['Ancillary_Imagery']['Weather_Quality_Indicator'][()]
        wqi_arrayT = np.transpose(wqi_array, (1, 0))
        wqi_arrayT = wqi_array[::-1, :]

        # Collect metadata
        metadata = {}
        metadata['shape'] = refl_shape
        metadata['no_data_value'] = float(refl_dataset.attrs['Data_Ignore_Value'])
        metadata['scale_factor'] = float(refl_dataset.attrs['Scale_Factor'])
        metadata['bad_band_window1'] = h5_refl_group.attrs['Band_Window_1_Nanometers']
        metadata['bad_band_window2'] = h5_refl_group.attrs['Band_Window_2_Nanometers']
        metadata['projection'] = h5_refl_group['Metadata']['Coordinate_System']['Proj4'][()].decode('utf-8')
        metadata['spatial_ref'] = h5_refl_group['Metadata']['Coordinate_System']['Coordinate_System_String'][()].decode('utf-8')
        metadata['EPSG'] = int(h5_refl_group['Metadata']['Coordinate_System']['EPSG Code'][()])

        # Parse map info for georeferencing
        map_info = str(h5_refl_group['Metadata']['Coordinate_System']['Map_Info'][()]).split(",")
        pixel_width = float(map_info[5])
        pixel_height = float(map_info[6])
        x_min = float(map_info[3]); x_min = int(x_min)
        y_max = float(map_info[4]); y_max = int(y_max)
        x_max = x_min + (refl_shape[1]*pixel_width); x_max = int(x_max)
        y_min = y_max - (refl_shape[0]*pixel_height); y_min = int(y_min)

        # Calculate UTM coordinates for x and y axes
        x_coords = np.linspace(x_min, x_max, num=refl_shape[1]).astype(float)
        y_coordsT = np.linspace(y_min, y_max, num=refl_shape[0]).astype(float)

        # Flag good/bad wavelengths (1=good, 0=bad)
        good_wavelengths = np.ones_like(wavelengths)
        for bad_window in [metadata['bad_band_window1'], metadata['bad_band_window2']]:
            bad_indices = np.where((wavelengths >= bad_window[0]) & (wavelengths <= bad_window[1]))[0]
            good_wavelengths[bad_indices] = 0
        good_wavelengths[-10:] = 0

        # Create xarray DataArray for reflectance
        refl_xrT = xr.DataArray(
            refl_arrayT,
            dims=["y", "x", "wavelengths"],
            name="reflectance",
            coords={
                "y": ("y", y_coordsT),
                "x": ("x", x_coords),
                "wavelengths": ("wavelengths", wavelengths),
                "fwhm": ("wavelengths", fwhm),
                "good_wavelengths": ("wavelengths", good_wavelengths)
            }
        )

        # Create xarray DataArray for Weather Quality Indicator
        wqi_xrT = xr.DataArray(
            wqi_arrayT,
            dims=["y", "x"],
            name="weather_quality_indicator",
            coords={
                "y": ("y", y_coordsT),
                "x": ("x", x_coords)
            }
        )

        # Create xarray Dataset and add metadata as attributes
        dsT = xr.Dataset({
            "reflectance": refl_xrT,
            "weather_quality_indicator": wqi_xrT
        })
        for key, value in metadata.items():
            if key not in ['shape', 'extent', 'ext_dict']:
                dsT.attrs[key] = value

        return dsT
```

Now that we've defined a function that reads in the reflectance hdf5 data and exports an xarray dataset, we can apply this function to our downloaded reflectance data. This should take around 15 seconds or so to run.


```python
%%time
# serc_refl_h5 = r'./data/NEON_D02_SERC_DP3_364000_4305000_bidirectional_reflectance.h5'
serc_refl_h5 = r'./data/DP3.30006.002/neon-aop-provisional-products/2025/FullSite/D02/2025_SERC_7/L3/Spectrometer/Reflectance/NEON_D02_SERC_DP3_364000_4305000_bidirectional_reflectance.h5'
serc_refl_xr = aop_h5refl2xarray(serc_refl_h5)
```

    Reading in  ./data/DP3.30006.002/neon-aop-provisional-products/2025/FullSite/D02/2025_SERC_7/L3/Spectrometer/Reflectance/NEON_D02_SERC_DP3_364000_4305000_bidirectional_reflectance.h5
    CPU times: total: 23.5 s
    Wall time: 24.1 s
    

Next let's define a function that updates the neon reflectance xarray dataset to apply the no data value (-9999), set the bad bands to NaN, and applies the CRS to make the xarray objet an rioxarray object. These could also be incorporated into the function above, but you may wish to work with unscaled reflectance data, for example, so we will keep these functions separate for now.


```python
def update_neon_xr(neon_refl_ds):

    # Set no data values (-9999) equal to np.nan
    neon_refl_ds.reflectance.data[neon_refl_ds.reflectance.data == -9999] = np.nan
    
    # Scale by the reflectance scale factor
    neon_refl_ds['reflectance'].data = ((neon_refl_ds['reflectance'].data) /
                                        (neon_refl_ds.attrs['scale_factor']))
    
    # Set "bad bands" (water vapor absorption bands and noisy bands) to NaN
    neon_refl_ds['reflectance'].data[:,:,neon_refl_ds['good_wavelengths'].data==0.0] = np.nan

    neon_refl_ds.rio.write_crs(f"epsg:{neon_refl_ds.attrs['EPSG']}", inplace=True)
    
    return neon_refl_ds
```

Apply this function on our xarray dataset. This should take a few seconds to run.


```python
serc_refl_xr = update_neon_xr(serc_refl_xr)
```

### 4.2 Explore the reflectance dataset

Display the dataset. You can use the up and down arrows to the left of the table (e.g. to the left of Dimensions, Coordinates, Data variables, etc.) to explore each part of the dataset in more detail. You can also click on the icons to the right to see more details.


```python
serc_refl_xr
```




<div><svg style="position: absolute; width: 0; height: 0; overflow: hidden">
<defs>
<symbol id="icon-database" viewBox="0 0 32 32">
<path d="M16 0c-8.837 0-16 2.239-16 5v4c0 2.761 7.163 5 16 5s16-2.239 16-5v-4c0-2.761-7.163-5-16-5z"></path>
<path d="M16 17c-8.837 0-16-2.239-16-5v6c0 2.761 7.163 5 16 5s16-2.239 16-5v-6c0 2.761-7.163 5-16 5z"></path>
<path d="M16 26c-8.837 0-16-2.239-16-5v6c0 2.761 7.163 5 16 5s16-2.239 16-5v-6c0 2.761-7.163 5-16 5z"></path>
</symbol>
<symbol id="icon-file-text2" viewBox="0 0 32 32">
<path d="M28.681 7.159c-0.694-0.947-1.662-2.053-2.724-3.116s-2.169-2.030-3.116-2.724c-1.612-1.182-2.393-1.319-2.841-1.319h-15.5c-1.378 0-2.5 1.121-2.5 2.5v27c0 1.378 1.122 2.5 2.5 2.5h23c1.378 0 2.5-1.122 2.5-2.5v-19.5c0-0.448-0.137-1.23-1.319-2.841zM24.543 5.457c0.959 0.959 1.712 1.825 2.268 2.543h-4.811v-4.811c0.718 0.556 1.584 1.309 2.543 2.268zM28 29.5c0 0.271-0.229 0.5-0.5 0.5h-23c-0.271 0-0.5-0.229-0.5-0.5v-27c0-0.271 0.229-0.5 0.5-0.5 0 0 15.499-0 15.5 0v7c0 0.552 0.448 1 1 1h7v19.5z"></path>
<path d="M23 26h-14c-0.552 0-1-0.448-1-1s0.448-1 1-1h14c0.552 0 1 0.448 1 1s-0.448 1-1 1z"></path>
<path d="M23 22h-14c-0.552 0-1-0.448-1-1s0.448-1 1-1h14c0.552 0 1 0.448 1 1s-0.448 1-1 1z"></path>
<path d="M23 18h-14c-0.552 0-1-0.448-1-1s0.448-1 1-1h14c0.552 0 1 0.448 1 1s-0.448 1-1 1z"></path>
</symbol>
</defs>
</svg>
<style>/* CSS stylesheet for displaying xarray objects in jupyterlab.
 *
 */

:root {
  --xr-font-color0: var(--jp-content-font-color0, rgba(0, 0, 0, 1));
  --xr-font-color2: var(--jp-content-font-color2, rgba(0, 0, 0, 0.54));
  --xr-font-color3: var(--jp-content-font-color3, rgba(0, 0, 0, 0.38));
  --xr-border-color: var(--jp-border-color2, #e0e0e0);
  --xr-disabled-color: var(--jp-layout-color3, #bdbdbd);
  --xr-background-color: var(--jp-layout-color0, white);
  --xr-background-color-row-even: var(--jp-layout-color1, white);
  --xr-background-color-row-odd: var(--jp-layout-color2, #eeeeee);
}

html[theme=dark],
body[data-theme=dark],
body.vscode-dark {
  --xr-font-color0: rgba(255, 255, 255, 1);
  --xr-font-color2: rgba(255, 255, 255, 0.54);
  --xr-font-color3: rgba(255, 255, 255, 0.38);
  --xr-border-color: #1F1F1F;
  --xr-disabled-color: #515151;
  --xr-background-color: #111111;
  --xr-background-color-row-even: #111111;
  --xr-background-color-row-odd: #313131;
}

.xr-wrap {
  display: block !important;
  min-width: 300px;
  max-width: 700px;
}

.xr-text-repr-fallback {
  /* fallback to plain text repr when CSS is not injected (untrusted notebook) */
  display: none;
}

.xr-header {
  padding-top: 6px;
  padding-bottom: 6px;
  margin-bottom: 4px;
  border-bottom: solid 1px var(--xr-border-color);
}

.xr-header > div,
.xr-header > ul {
  display: inline;
  margin-top: 0;
  margin-bottom: 0;
}

.xr-obj-type,
.xr-array-name {
  margin-left: 2px;
  margin-right: 10px;
}

.xr-obj-type {
  color: var(--xr-font-color2);
}

.xr-sections {
  padding-left: 0 !important;
  display: grid;
  grid-template-columns: 150px auto auto 1fr 20px 20px;
}

.xr-section-item {
  display: contents;
}

.xr-section-item input {
  display: none;
}

.xr-section-item input + label {
  color: var(--xr-disabled-color);
}

.xr-section-item input:enabled + label {
  cursor: pointer;
  color: var(--xr-font-color2);
}

.xr-section-item input:enabled + label:hover {
  color: var(--xr-font-color0);
}

.xr-section-summary {
  grid-column: 1;
  color: var(--xr-font-color2);
  font-weight: 500;
}

.xr-section-summary > span {
  display: inline-block;
  padding-left: 0.5em;
}

.xr-section-summary-in:disabled + label {
  color: var(--xr-font-color2);
}

.xr-section-summary-in + label:before {
  display: inline-block;
  content: '►';
  font-size: 11px;
  width: 15px;
  text-align: center;
}

.xr-section-summary-in:disabled + label:before {
  color: var(--xr-disabled-color);
}

.xr-section-summary-in:checked + label:before {
  content: '▼';
}

.xr-section-summary-in:checked + label > span {
  display: none;
}

.xr-section-summary,
.xr-section-inline-details {
  padding-top: 4px;
  padding-bottom: 4px;
}

.xr-section-inline-details {
  grid-column: 2 / -1;
}

.xr-section-details {
  display: none;
  grid-column: 1 / -1;
  margin-bottom: 5px;
}

.xr-section-summary-in:checked ~ .xr-section-details {
  display: contents;
}

.xr-array-wrap {
  grid-column: 1 / -1;
  display: grid;
  grid-template-columns: 20px auto;
}

.xr-array-wrap > label {
  grid-column: 1;
  vertical-align: top;
}

.xr-preview {
  color: var(--xr-font-color3);
}

.xr-array-preview,
.xr-array-data {
  padding: 0 5px !important;
  grid-column: 2;
}

.xr-array-data,
.xr-array-in:checked ~ .xr-array-preview {
  display: none;
}

.xr-array-in:checked ~ .xr-array-data,
.xr-array-preview {
  display: inline-block;
}

.xr-dim-list {
  display: inline-block !important;
  list-style: none;
  padding: 0 !important;
  margin: 0;
}

.xr-dim-list li {
  display: inline-block;
  padding: 0;
  margin: 0;
}

.xr-dim-list:before {
  content: '(';
}

.xr-dim-list:after {
  content: ')';
}

.xr-dim-list li:not(:last-child):after {
  content: ',';
  padding-right: 5px;
}

.xr-has-index {
  font-weight: bold;
}

.xr-var-list,
.xr-var-item {
  display: contents;
}

.xr-var-item > div,
.xr-var-item label,
.xr-var-item > .xr-var-name span {
  background-color: var(--xr-background-color-row-even);
  margin-bottom: 0;
}

.xr-var-item > .xr-var-name:hover span {
  padding-right: 5px;
}

.xr-var-list > li:nth-child(odd) > div,
.xr-var-list > li:nth-child(odd) > label,
.xr-var-list > li:nth-child(odd) > .xr-var-name span {
  background-color: var(--xr-background-color-row-odd);
}

.xr-var-name {
  grid-column: 1;
}

.xr-var-dims {
  grid-column: 2;
}

.xr-var-dtype {
  grid-column: 3;
  text-align: right;
  color: var(--xr-font-color2);
}

.xr-var-preview {
  grid-column: 4;
}

.xr-index-preview {
  grid-column: 2 / 5;
  color: var(--xr-font-color2);
}

.xr-var-name,
.xr-var-dims,
.xr-var-dtype,
.xr-preview,
.xr-attrs dt {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  padding-right: 10px;
}

.xr-var-name:hover,
.xr-var-dims:hover,
.xr-var-dtype:hover,
.xr-attrs dt:hover {
  overflow: visible;
  width: auto;
  z-index: 1;
}

.xr-var-attrs,
.xr-var-data,
.xr-index-data {
  display: none;
  background-color: var(--xr-background-color) !important;
  padding-bottom: 5px !important;
}

.xr-var-attrs-in:checked ~ .xr-var-attrs,
.xr-var-data-in:checked ~ .xr-var-data,
.xr-index-data-in:checked ~ .xr-index-data {
  display: block;
}

.xr-var-data > table {
  float: right;
}

.xr-var-name span,
.xr-var-data,
.xr-index-name div,
.xr-index-data,
.xr-attrs {
  padding-left: 25px !important;
}

.xr-attrs,
.xr-var-attrs,
.xr-var-data,
.xr-index-data {
  grid-column: 1 / -1;
}

dl.xr-attrs {
  padding: 0;
  margin: 0;
  display: grid;
  grid-template-columns: 125px auto;
}

.xr-attrs dt,
.xr-attrs dd {
  padding: 0;
  margin: 0;
  float: left;
  padding-right: 10px;
  width: auto;
}

.xr-attrs dt {
  font-weight: normal;
  grid-column: 1;
}

.xr-attrs dt:hover span {
  display: inline-block;
  background: var(--xr-background-color);
  padding-right: 10px;
}

.xr-attrs dd {
  grid-column: 2;
  white-space: pre-wrap;
  word-break: break-all;
}

.xr-icon-database,
.xr-icon-file-text2,
.xr-no-icon {
  display: inline-block;
  vertical-align: middle;
  width: 1em;
  height: 1.5em !important;
  stroke-width: 0;
  stroke: currentColor;
  fill: currentColor;
}
</style><pre class='xr-text-repr-fallback'>&lt;xarray.Dataset&gt; Size: 2GB
Dimensions:                    (y: 1000, x: 1000, wavelengths: 426)
Coordinates:
  * y                          (y) float64 8kB 4.305e+06 4.305e+06 ... 4.306e+06
  * x                          (x) float64 8kB 3.64e+05 3.64e+05 ... 3.65e+05
  * wavelengths                (wavelengths) float64 3kB 381.9 ... 2.511e+03
    fwhm                       (wavelengths) float64 3kB 5.674 5.673 ... 6.302
    good_wavelengths           (wavelengths) float64 3kB 1.0 1.0 1.0 ... 0.0 0.0
    spatial_ref                int32 4B 0
Data variables:
    reflectance                (y, x, wavelengths) float32 2GB 0.0021 ... nan
    weather_quality_indicator  (y, x) int32 4MB 2 2 2 2 2 2 2 ... 2 2 2 2 2 2 2
Attributes:
    no_data_value:     -9999.0
    scale_factor:      10000.0
    bad_band_window1:  [1340 1445]
    bad_band_window2:  [1790 1955]
    projection:        +proj=UTM +zone=18 +ellps=WGS84 +datum=WGS84 +units=m ...
    spatial_ref:       PROJCS[&quot;WGS_1984_UTM_Zone_18N&quot;,GEOGCS[&quot;GCS_WGS_1984&quot;,D...
    EPSG:              32618</pre><div class='xr-wrap' style='display:none'><div class='xr-header'><div class='xr-obj-type'>xarray.Dataset</div></div><ul class='xr-sections'><li class='xr-section-item'><input id='section-0321435d-9253-4656-b032-c7fac36a1a11' class='xr-section-summary-in' type='checkbox' disabled ><label for='section-0321435d-9253-4656-b032-c7fac36a1a11' class='xr-section-summary'  title='Expand/collapse section'>Dimensions:</label><div class='xr-section-inline-details'><ul class='xr-dim-list'><li><span class='xr-has-index'>y</span>: 1000</li><li><span class='xr-has-index'>x</span>: 1000</li><li><span class='xr-has-index'>wavelengths</span>: 426</li></ul></div><div class='xr-section-details'></div></li><li class='xr-section-item'><input id='section-843a89ff-7c14-4e0f-aa66-4839644ab35b' class='xr-section-summary-in' type='checkbox'  checked><label for='section-843a89ff-7c14-4e0f-aa66-4839644ab35b' class='xr-section-summary' >Coordinates: <span>(6)</span></label><div class='xr-section-inline-details'></div><div class='xr-section-details'><ul class='xr-var-list'><li class='xr-var-item'><div class='xr-var-name'><span class='xr-has-index'>y</span></div><div class='xr-var-dims'>(y)</div><div class='xr-var-dtype'>float64</div><div class='xr-var-preview xr-preview'>4.305e+06 4.305e+06 ... 4.306e+06</div><input id='attrs-be086411-a57a-49a2-bb55-3b93dceeb919' class='xr-var-attrs-in' type='checkbox' disabled><label for='attrs-be086411-a57a-49a2-bb55-3b93dceeb919' title='Show/Hide attributes'><svg class='icon xr-icon-file-text2'><use xlink:href='#icon-file-text2'></use></svg></label><input id='data-526c872c-3f27-4642-945c-d586688bd4db' class='xr-var-data-in' type='checkbox'><label for='data-526c872c-3f27-4642-945c-d586688bd4db' title='Show/Hide data repr'><svg class='icon xr-icon-database'><use xlink:href='#icon-database'></use></svg></label><div class='xr-var-attrs'><dl class='xr-attrs'></dl></div><div class='xr-var-data'><pre>array([4305000.      , 4305001.001001, 4305002.002002, ..., 4305997.997998,
       4305998.998999, 4306000.      ])</pre></div></li><li class='xr-var-item'><div class='xr-var-name'><span class='xr-has-index'>x</span></div><div class='xr-var-dims'>(x)</div><div class='xr-var-dtype'>float64</div><div class='xr-var-preview xr-preview'>3.64e+05 3.64e+05 ... 3.65e+05</div><input id='attrs-4eb0cb6a-0616-4ebb-bc4c-0ac58b7191db' class='xr-var-attrs-in' type='checkbox' disabled><label for='attrs-4eb0cb6a-0616-4ebb-bc4c-0ac58b7191db' title='Show/Hide attributes'><svg class='icon xr-icon-file-text2'><use xlink:href='#icon-file-text2'></use></svg></label><input id='data-a3e07a66-a266-45f5-95fc-d20a130a610b' class='xr-var-data-in' type='checkbox'><label for='data-a3e07a66-a266-45f5-95fc-d20a130a610b' title='Show/Hide data repr'><svg class='icon xr-icon-database'><use xlink:href='#icon-database'></use></svg></label><div class='xr-var-attrs'><dl class='xr-attrs'></dl></div><div class='xr-var-data'><pre>array([364000.      , 364001.001001, 364002.002002, ..., 364997.997998,
       364998.998999, 365000.      ])</pre></div></li><li class='xr-var-item'><div class='xr-var-name'><span class='xr-has-index'>wavelengths</span></div><div class='xr-var-dims'>(wavelengths)</div><div class='xr-var-dtype'>float64</div><div class='xr-var-preview xr-preview'>381.9 386.9 ... 2.506e+03 2.511e+03</div><input id='attrs-bf89a3fb-1f8e-4372-95e8-0585d331ee2d' class='xr-var-attrs-in' type='checkbox' disabled><label for='attrs-bf89a3fb-1f8e-4372-95e8-0585d331ee2d' title='Show/Hide attributes'><svg class='icon xr-icon-file-text2'><use xlink:href='#icon-file-text2'></use></svg></label><input id='data-468df02a-b267-4552-8b62-868c5d61c0d8' class='xr-var-data-in' type='checkbox'><label for='data-468df02a-b267-4552-8b62-868c5d61c0d8' title='Show/Hide data repr'><svg class='icon xr-icon-database'><use xlink:href='#icon-database'></use></svg></label><div class='xr-var-attrs'><dl class='xr-attrs'></dl></div><div class='xr-var-data'><pre>array([ 381.858398,  386.868896,  391.879395, ..., 2501.30249 , 2506.312988,
       2511.323486])</pre></div></li><li class='xr-var-item'><div class='xr-var-name'><span>fwhm</span></div><div class='xr-var-dims'>(wavelengths)</div><div class='xr-var-dtype'>float64</div><div class='xr-var-preview xr-preview'>5.674 5.673 5.671 ... 6.298 6.302</div><input id='attrs-7f051972-446f-4e1b-aaac-519e73389125' class='xr-var-attrs-in' type='checkbox' disabled><label for='attrs-7f051972-446f-4e1b-aaac-519e73389125' title='Show/Hide attributes'><svg class='icon xr-icon-file-text2'><use xlink:href='#icon-file-text2'></use></svg></label><input id='data-2c9ad341-7923-46fa-8161-56a9514c3460' class='xr-var-data-in' type='checkbox'><label for='data-2c9ad341-7923-46fa-8161-56a9514c3460' title='Show/Hide data repr'><svg class='icon xr-icon-database'><use xlink:href='#icon-database'></use></svg></label><div class='xr-var-attrs'><dl class='xr-attrs'></dl></div><div class='xr-var-data'><pre>array([5.673991, 5.672635, 5.671291, 5.669962, 5.668645, 5.667343,
       5.666053, 5.664777, 5.663514, 5.662264, 5.661028, 5.659805,
       5.658596, 5.6574  , 5.656217, 5.655048, 5.653892, 5.65275 ,
       5.65162 , 5.650505, 5.649402, 5.648313, 5.647237, 5.646175,
       5.645126, 5.644091, 5.643068, 5.64206 , 5.641064, 5.640082,
       5.639113, 5.638158, 5.637216, 5.636287, 5.635372, 5.63447 ,
       5.633582, 5.632707, 5.631845, 5.630996, 5.630161, 5.62934 ,
       5.628531, 5.627737, 5.626955, 5.626187, 5.625432, 5.624691,
       5.623962, 5.623248, 5.622546, 5.621859, 5.621184, 5.620522,
       5.619875, 5.61924 , 5.618619, 5.618011, 5.617417, 5.616836,
       5.616269, 5.615714, 5.615173, 5.614646, 5.614131, 5.613631,
       5.613143, 5.612669, 5.612209, 5.611762, 5.611328, 5.610907,
       5.6105  , 5.610106, 5.609725, 5.609358, 5.609004, 5.608664,
       5.608337, 5.608024, 5.607723, 5.607437, 5.607163, 5.606903,
       5.606656, 5.606423, 5.606203, 5.605996, 5.605803, 5.605623,
       5.605456, 5.605303, 5.605164, 5.605037, 5.604924, 5.604825,
       5.604738, 5.604665, 5.604606, 5.604559, 5.604527, 5.604507,
       5.604501, 5.604508, 5.604529, 5.604563, 5.60461 , 5.604671,
       5.604745, 5.604833, 5.604933, 5.605048, 5.605175, 5.605316,
       5.605471, 5.605638, 5.605819, 5.606014, 5.606222, 5.606443,
...
       5.882821, 5.885555, 5.888303, 5.891065, 5.89384 , 5.896628,
       5.899429, 5.902244, 5.905073, 5.907914, 5.910769, 5.913638,
       5.91652 , 5.919415, 5.922323, 5.925245, 5.92818 , 5.931129,
       5.934091, 5.937067, 5.940055, 5.943058, 5.946073, 5.949102,
       5.952144, 5.9552  , 5.958269, 5.961351, 5.964447, 5.967556,
       5.970678, 5.973814, 5.976963, 5.980125, 5.983302, 5.986491,
       5.989694, 5.992909, 5.996139, 5.999382, 6.002638, 6.005908,
       6.00919 , 6.012486, 6.015796, 6.019119, 6.022456, 6.025805,
       6.029169, 6.032545, 6.035935, 6.039338, 6.042755, 6.046185,
       6.049628, 6.053084, 6.056554, 6.060038, 6.063535, 6.067045,
       6.070569, 6.074105, 6.077656, 6.081219, 6.084796, 6.088387,
       6.09199 , 6.095608, 6.099238, 6.102882, 6.106539, 6.11021 ,
       6.113894, 6.117591, 6.121302, 6.125026, 6.128764, 6.132514,
       6.136279, 6.140056, 6.143847, 6.147651, 6.151469, 6.1553  ,
       6.159144, 6.163002, 6.166873, 6.170758, 6.174656, 6.178567,
       6.182492, 6.18643 , 6.190381, 6.194346, 6.198324, 6.202315,
       6.20632 , 6.210339, 6.21437 , 6.218415, 6.222474, 6.226545,
       6.23063 , 6.234729, 6.238841, 6.242966, 6.247104, 6.251256,
       6.255422, 6.2596  , 6.263792, 6.267998, 6.272216, 6.276449,
       6.280694, 6.284953, 6.289225, 6.293511, 6.29781 , 6.302122])</pre></div></li><li class='xr-var-item'><div class='xr-var-name'><span>good_wavelengths</span></div><div class='xr-var-dims'>(wavelengths)</div><div class='xr-var-dtype'>float64</div><div class='xr-var-preview xr-preview'>1.0 1.0 1.0 1.0 ... 0.0 0.0 0.0 0.0</div><input id='attrs-ed7e4040-7abf-4128-9163-0c707108039e' class='xr-var-attrs-in' type='checkbox' disabled><label for='attrs-ed7e4040-7abf-4128-9163-0c707108039e' title='Show/Hide attributes'><svg class='icon xr-icon-file-text2'><use xlink:href='#icon-file-text2'></use></svg></label><input id='data-9e7fb133-2962-43c1-a604-d8a944b43f8f' class='xr-var-data-in' type='checkbox'><label for='data-9e7fb133-2962-43c1-a604-d8a944b43f8f' title='Show/Hide data repr'><svg class='icon xr-icon-database'><use xlink:href='#icon-database'></use></svg></label><div class='xr-var-attrs'><dl class='xr-attrs'></dl></div><div class='xr-var-data'><pre>array([1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.,
       0., 0., 0., 0., 0., 0., 0., 0., 0., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 0., 0., 0., 0., 0., 0., 0.,
       0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.,
       0., 0., 0., 0., 0., 0., 0., 0., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,
       1., 1., 1., 1., 1., 1., 1., 1., 0., 0., 0., 0., 0., 0., 0., 0., 0.,
       0.])</pre></div></li><li class='xr-var-item'><div class='xr-var-name'><span>spatial_ref</span></div><div class='xr-var-dims'>()</div><div class='xr-var-dtype'>int32</div><div class='xr-var-preview xr-preview'>0</div><input id='attrs-6d91fe5a-5ea9-42dd-a2c2-54e22359ffe0' class='xr-var-attrs-in' type='checkbox' ><label for='attrs-6d91fe5a-5ea9-42dd-a2c2-54e22359ffe0' title='Show/Hide attributes'><svg class='icon xr-icon-file-text2'><use xlink:href='#icon-file-text2'></use></svg></label><input id='data-5a07f491-a605-49c2-8bc0-d5bd1ac1465d' class='xr-var-data-in' type='checkbox'><label for='data-5a07f491-a605-49c2-8bc0-d5bd1ac1465d' title='Show/Hide data repr'><svg class='icon xr-icon-database'><use xlink:href='#icon-database'></use></svg></label><div class='xr-var-attrs'><dl class='xr-attrs'><dt><span>crs_wkt :</span></dt><dd>PROJCS[&quot;WGS 84 / UTM zone 18N&quot;,GEOGCS[&quot;WGS 84&quot;,DATUM[&quot;WGS_1984&quot;,SPHEROID[&quot;WGS 84&quot;,6378137,298.257223563,AUTHORITY[&quot;EPSG&quot;,&quot;7030&quot;]],AUTHORITY[&quot;EPSG&quot;,&quot;6326&quot;]],PRIMEM[&quot;Greenwich&quot;,0,AUTHORITY[&quot;EPSG&quot;,&quot;8901&quot;]],UNIT[&quot;degree&quot;,0.0174532925199433,AUTHORITY[&quot;EPSG&quot;,&quot;9122&quot;]],AUTHORITY[&quot;EPSG&quot;,&quot;4326&quot;]],PROJECTION[&quot;Transverse_Mercator&quot;],PARAMETER[&quot;latitude_of_origin&quot;,0],PARAMETER[&quot;central_meridian&quot;,-75],PARAMETER[&quot;scale_factor&quot;,0.9996],PARAMETER[&quot;false_easting&quot;,500000],PARAMETER[&quot;false_northing&quot;,0],UNIT[&quot;metre&quot;,1,AUTHORITY[&quot;EPSG&quot;,&quot;9001&quot;]],AXIS[&quot;Easting&quot;,EAST],AXIS[&quot;Northing&quot;,NORTH],AUTHORITY[&quot;EPSG&quot;,&quot;32618&quot;]]</dd><dt><span>semi_major_axis :</span></dt><dd>6378137.0</dd><dt><span>semi_minor_axis :</span></dt><dd>6356752.314245179</dd><dt><span>inverse_flattening :</span></dt><dd>298.257223563</dd><dt><span>reference_ellipsoid_name :</span></dt><dd>WGS 84</dd><dt><span>longitude_of_prime_meridian :</span></dt><dd>0.0</dd><dt><span>prime_meridian_name :</span></dt><dd>Greenwich</dd><dt><span>geographic_crs_name :</span></dt><dd>WGS 84</dd><dt><span>horizontal_datum_name :</span></dt><dd>World Geodetic System 1984</dd><dt><span>projected_crs_name :</span></dt><dd>WGS 84 / UTM zone 18N</dd><dt><span>grid_mapping_name :</span></dt><dd>transverse_mercator</dd><dt><span>latitude_of_projection_origin :</span></dt><dd>0.0</dd><dt><span>longitude_of_central_meridian :</span></dt><dd>-75.0</dd><dt><span>false_easting :</span></dt><dd>500000.0</dd><dt><span>false_northing :</span></dt><dd>0.0</dd><dt><span>scale_factor_at_central_meridian :</span></dt><dd>0.9996</dd><dt><span>spatial_ref :</span></dt><dd>PROJCS[&quot;WGS 84 / UTM zone 18N&quot;,GEOGCS[&quot;WGS 84&quot;,DATUM[&quot;WGS_1984&quot;,SPHEROID[&quot;WGS 84&quot;,6378137,298.257223563,AUTHORITY[&quot;EPSG&quot;,&quot;7030&quot;]],AUTHORITY[&quot;EPSG&quot;,&quot;6326&quot;]],PRIMEM[&quot;Greenwich&quot;,0,AUTHORITY[&quot;EPSG&quot;,&quot;8901&quot;]],UNIT[&quot;degree&quot;,0.0174532925199433,AUTHORITY[&quot;EPSG&quot;,&quot;9122&quot;]],AUTHORITY[&quot;EPSG&quot;,&quot;4326&quot;]],PROJECTION[&quot;Transverse_Mercator&quot;],PARAMETER[&quot;latitude_of_origin&quot;,0],PARAMETER[&quot;central_meridian&quot;,-75],PARAMETER[&quot;scale_factor&quot;,0.9996],PARAMETER[&quot;false_easting&quot;,500000],PARAMETER[&quot;false_northing&quot;,0],UNIT[&quot;metre&quot;,1,AUTHORITY[&quot;EPSG&quot;,&quot;9001&quot;]],AXIS[&quot;Easting&quot;,EAST],AXIS[&quot;Northing&quot;,NORTH],AUTHORITY[&quot;EPSG&quot;,&quot;32618&quot;]]</dd></dl></div><div class='xr-var-data'><pre>array(0)</pre></div></li></ul></div></li><li class='xr-section-item'><input id='section-0f5d4312-02fe-42ae-a7d2-0090ccd492b5' class='xr-section-summary-in' type='checkbox'  checked><label for='section-0f5d4312-02fe-42ae-a7d2-0090ccd492b5' class='xr-section-summary' >Data variables: <span>(2)</span></label><div class='xr-section-inline-details'></div><div class='xr-section-details'><ul class='xr-var-list'><li class='xr-var-item'><div class='xr-var-name'><span>reflectance</span></div><div class='xr-var-dims'>(y, x, wavelengths)</div><div class='xr-var-dtype'>float32</div><div class='xr-var-preview xr-preview'>0.0021 0.0079 0.0125 ... nan nan</div><input id='attrs-723ccd01-6d06-4f62-905a-1ceaf43c9abc' class='xr-var-attrs-in' type='checkbox' disabled><label for='attrs-723ccd01-6d06-4f62-905a-1ceaf43c9abc' title='Show/Hide attributes'><svg class='icon xr-icon-file-text2'><use xlink:href='#icon-file-text2'></use></svg></label><input id='data-03e8ae53-18bf-47c0-bda7-f038b00b7bca' class='xr-var-data-in' type='checkbox'><label for='data-03e8ae53-18bf-47c0-bda7-f038b00b7bca' title='Show/Hide data repr'><svg class='icon xr-icon-database'><use xlink:href='#icon-database'></use></svg></label><div class='xr-var-attrs'><dl class='xr-attrs'></dl></div><div class='xr-var-data'><pre>array([[[0.0021, 0.0079, 0.0125, ...,    nan,    nan,    nan],
        [0.0019, 0.0091, 0.0175, ...,    nan,    nan,    nan],
        [0.    , 0.0072, 0.0084, ...,    nan,    nan,    nan],
        ...,
        [0.0111, 0.0228, 0.0213, ...,    nan,    nan,    nan],
        [0.0118, 0.0199, 0.022 , ...,    nan,    nan,    nan],
        [0.0081, 0.0191, 0.0208, ...,    nan,    nan,    nan]],

       [[0.0024, 0.0105, 0.0109, ...,    nan,    nan,    nan],
        [0.0013, 0.0003, 0.0064, ...,    nan,    nan,    nan],
        [0.    , 0.0082, 0.0072, ...,    nan,    nan,    nan],
        ...,
        [0.0059, 0.0197, 0.0215, ...,    nan,    nan,    nan],
        [0.0067, 0.0192, 0.0204, ...,    nan,    nan,    nan],
        [0.0109, 0.0238, 0.0228, ...,    nan,    nan,    nan]],

       [[0.    , 0.0067, 0.0154, ...,    nan,    nan,    nan],
        [0.0016, 0.0055, 0.0088, ...,    nan,    nan,    nan],
        [0.002 , 0.0111, 0.0076, ...,    nan,    nan,    nan],
        ...,
...
        [0.0032, 0.0091, 0.0129, ...,    nan,    nan,    nan],
        [0.0036, 0.0108, 0.0162, ...,    nan,    nan,    nan],
        [0.0026, 0.0099, 0.0135, ...,    nan,    nan,    nan]],

       [[0.0073, 0.0099, 0.0089, ...,    nan,    nan,    nan],
        [0.0004, 0.0147, 0.0128, ...,    nan,    nan,    nan],
        [0.0029, 0.0121, 0.0128, ...,    nan,    nan,    nan],
        ...,
        [0.0067, 0.0147, 0.0095, ...,    nan,    nan,    nan],
        [0.0068, 0.0149, 0.0097, ...,    nan,    nan,    nan],
        [0.0015, 0.0133, 0.0146, ...,    nan,    nan,    nan]],

       [[0.006 , 0.011 , 0.0125, ...,    nan,    nan,    nan],
        [0.0071, 0.0157, 0.0121, ...,    nan,    nan,    nan],
        [0.0022, 0.013 , 0.0107, ...,    nan,    nan,    nan],
        ...,
        [0.0037, 0.011 , 0.0155, ...,    nan,    nan,    nan],
        [0.0038, 0.0113, 0.0158, ...,    nan,    nan,    nan],
        [0.002 , 0.0099, 0.017 , ...,    nan,    nan,    nan]]],
      dtype=float32)</pre></div></li><li class='xr-var-item'><div class='xr-var-name'><span>weather_quality_indicator</span></div><div class='xr-var-dims'>(y, x)</div><div class='xr-var-dtype'>int32</div><div class='xr-var-preview xr-preview'>2 2 2 2 2 2 2 2 ... 2 2 2 2 2 2 2 2</div><input id='attrs-596c3e1e-6f94-467d-8aea-79eda9ec50c4' class='xr-var-attrs-in' type='checkbox' disabled><label for='attrs-596c3e1e-6f94-467d-8aea-79eda9ec50c4' title='Show/Hide attributes'><svg class='icon xr-icon-file-text2'><use xlink:href='#icon-file-text2'></use></svg></label><input id='data-5f4db268-b76d-485c-8ebc-be06d3d42d2a' class='xr-var-data-in' type='checkbox'><label for='data-5f4db268-b76d-485c-8ebc-be06d3d42d2a' title='Show/Hide data repr'><svg class='icon xr-icon-database'><use xlink:href='#icon-database'></use></svg></label><div class='xr-var-attrs'><dl class='xr-attrs'></dl></div><div class='xr-var-data'><pre>array([[2, 2, 2, ..., 2, 2, 2],
       [2, 2, 2, ..., 2, 2, 2],
       [2, 2, 2, ..., 2, 2, 2],
       ...,
       [2, 2, 2, ..., 2, 2, 2],
       [2, 2, 2, ..., 2, 2, 2],
       [2, 2, 2, ..., 2, 2, 2]])</pre></div></li></ul></div></li><li class='xr-section-item'><input id='section-7aafc381-f758-4639-ad88-129c072e5a95' class='xr-section-summary-in' type='checkbox'  ><label for='section-7aafc381-f758-4639-ad88-129c072e5a95' class='xr-section-summary' >Indexes: <span>(3)</span></label><div class='xr-section-inline-details'></div><div class='xr-section-details'><ul class='xr-var-list'><li class='xr-var-item'><div class='xr-index-name'><div>y</div></div><div class='xr-index-preview'>PandasIndex</div><div></div><input id='index-15522ebf-afe6-4bd1-ad5a-619acf0276be' class='xr-index-data-in' type='checkbox'/><label for='index-15522ebf-afe6-4bd1-ad5a-619acf0276be' title='Show/Hide index repr'><svg class='icon xr-icon-database'><use xlink:href='#icon-database'></use></svg></label><div class='xr-index-data'><pre>PandasIndex(Index([        4305000.0, 4305001.001001001, 4305002.002002002,
       4305003.003003003, 4305004.004004004, 4305005.005005005,
       4305006.006006006, 4305007.007007007, 4305008.008008008,
       4305009.009009009,
       ...
       4305990.990990991, 4305991.991991992, 4305992.992992993,
       4305993.993993994, 4305994.994994995, 4305995.995995996,
       4305996.996996997, 4305997.997997998, 4305998.998998999,
               4306000.0],
      dtype=&#x27;float64&#x27;, name=&#x27;y&#x27;, length=1000))</pre></div></li><li class='xr-var-item'><div class='xr-index-name'><div>x</div></div><div class='xr-index-preview'>PandasIndex</div><div></div><input id='index-9cc80752-35ed-4879-b3c9-da3655546032' class='xr-index-data-in' type='checkbox'/><label for='index-9cc80752-35ed-4879-b3c9-da3655546032' title='Show/Hide index repr'><svg class='icon xr-icon-database'><use xlink:href='#icon-database'></use></svg></label><div class='xr-index-data'><pre>PandasIndex(Index([          364000.0,   364001.001001001, 364002.00200200203,
         364003.003003003,   364004.004004004,   364005.005005005,
       364006.00600600604,   364007.007007007,   364008.008008008,
         364009.009009009,
       ...
         364990.990990991,   364991.991991992,   364992.992992993,
       364993.99399399396,   364994.994994995,   364995.995995996,
         364996.996996997,   364997.997997998,   364998.998998999,
                 365000.0],
      dtype=&#x27;float64&#x27;, name=&#x27;x&#x27;, length=1000))</pre></div></li><li class='xr-var-item'><div class='xr-index-name'><div>wavelengths</div></div><div class='xr-index-preview'>PandasIndex</div><div></div><input id='index-330f7743-e53b-49dc-8f2d-cef7520e1ef5' class='xr-index-data-in' type='checkbox'/><label for='index-330f7743-e53b-49dc-8f2d-cef7520e1ef5' title='Show/Hide index repr'><svg class='icon xr-icon-database'><use xlink:href='#icon-database'></use></svg></label><div class='xr-index-data'><pre>PandasIndex(Index([ 381.858398,  386.868896,  391.879395,  396.889893,  401.900391,
        406.910889,  411.921387,  416.932007,  421.942505,  426.953003,
       ...
       2466.229004, 2471.239502,     2476.25, 2481.260498, 2486.270996,
       2491.281494, 2496.291992,  2501.30249, 2506.312988, 2511.323486],
      dtype=&#x27;float64&#x27;, name=&#x27;wavelengths&#x27;, length=426))</pre></div></li></ul></div></li><li class='xr-section-item'><input id='section-d044cdb6-98cb-4860-9c76-18729a9eebfa' class='xr-section-summary-in' type='checkbox'  checked><label for='section-d044cdb6-98cb-4860-9c76-18729a9eebfa' class='xr-section-summary' >Attributes: <span>(7)</span></label><div class='xr-section-inline-details'></div><div class='xr-section-details'><dl class='xr-attrs'><dt><span>no_data_value :</span></dt><dd>-9999.0</dd><dt><span>scale_factor :</span></dt><dd>10000.0</dd><dt><span>bad_band_window1 :</span></dt><dd>[1340 1445]</dd><dt><span>bad_band_window2 :</span></dt><dd>[1790 1955]</dd><dt><span>projection :</span></dt><dd>+proj=UTM +zone=18 +ellps=WGS84 +datum=WGS84 +units=m +no_defs</dd><dt><span>spatial_ref :</span></dt><dd>PROJCS[&quot;WGS_1984_UTM_Zone_18N&quot;,GEOGCS[&quot;GCS_WGS_1984&quot;,DATUM[&quot;D_WGS_1984&quot;,SPHEROID[&quot;WGS_1984&quot;,6378137.0,298.257223563]],PRIMEM[&quot;Greenwich&quot;,0.0],UNIT[&quot;Degree&quot;,0.0174532925199433]],PROJECTION[&quot;Transverse_Mercator&quot;],PARAMETER[&quot;False_Easting&quot;,500000.0],PARAMETER[&quot;False_Northing&quot;,0.0],PARAMETER[&quot;Central_Meridian&quot;,-75.0],PARAMETER[&quot;Scale_Factor&quot;,0.9996],PARAMETER[&quot;Latitude_Of_Origin&quot;,0.0],UNIT[&quot;Meter&quot;,1.0]]</dd><dt><span>EPSG :</span></dt><dd>32618</dd></dl></div></li></ul></div></div>




```python
# function to auto-scale to make RGB images more realistic
def gamma_adjust(rgb_ds, bright=0.2, white_background=False):
    array = rgb_ds.reflectance.data
    gamma = math.log(bright)/math.log(np.nanmean(array)) # Create exponent for gamma scaling - can be adjusted by changing 0.2 
    scaled = np.power(np.nan_to_num(array,nan=1),np.nan_to_num(gamma,nan=1)).clip(0,1) # Apply scaling and clip to 0-1 range
    if white_background == True:
        scaled = np.nan_to_num(scaled, nan = 1) # Set NANs to 1 so they appear white in plots
    rgb_ds.reflectance.data = scaled
    return rgb_ds
```

### 4.3 Plot the reflectance dataset

Now let's plot a true color (or RGB) image of the reflectance data as shown in the cell below.


```python
# Plot the RGB image of the SERC tower tile
serc_refl_rgb = serc_refl_xr.sel(wavelengths=[650, 560, 470], method='nearest')
serc_refl_rgb = gamma_adjust(serc_refl_rgb,bright=0.3,white_background=True)

serc_rgb_plot = serc_refl_rgb.hvplot.rgb(y='y',x='x',bands='wavelengths',
                         xlabel='UTM x',ylabel='UTM y',
                         title='NEON AOP Reflectance RGB - SERC Tower Tile',
                         frame_width=480, frame_height=480)

# Set axis format to integer (no scientific notation)
serc_rgb_plot = serc_rgb_plot.opts(
    xformatter='%.0f',
    yformatter='%.0f'
)

serc_rgb_plot
```

 
### 4.4 Plot the weather quality indicator data

We can look at the weather conditions during the flight by displaying the `weather_quality_indicator` data array. This is a 2D array with values ranging from 1 to 3, where: 1 = <10% cloud cover, 2 = 10-50% cloud cover, 3 = >50% cloud cover. NEON uses a stop-light convention to indicate the weather and cloud conditions, where green (1) is good, yellow (2) is moderate, and red (3) is poor. The figure below shows some examples of these three conditions as captured by the flight operators during science flights.

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/flight_cloud_photos.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee2023/1b_sdr_weather/flight_cloud_photos.png" alt="In-flight cloud photos" style="max-width: 100%; height: auto;">
	<figcaption>Cloud cover percentage during AOP flights. Left: green (<10%), Middle: yellow (10-50%), Right: red (>50%).</figcaption>
	</a>
</figure>  

Let's visualize this weather quality indicator data for this SERC tile using a transparent color on top of our RGB reflectance plot, following the same stop-light convention.


```python
# Prepare the WQI mask
wqi = serc_refl_xr.weather_quality_indicator

# Map WQI values to colors: 1=green, 2=yellow, 3=red, 0/other=transparent
wqi_colors = ['#228B22', '#FFFF00', '#FF0000']
# wqi_mask = wqi[wqi > 0]  # mask out zeros or nodata

# Use hvplot with categorical colormap and alpha (50% transparency)
wqi_overlay = wqi.hvplot.image(
    x='x', y='y', cmap=wqi_colors,
    clim=(1, 3), colorbar=False, alpha=0.5, 
    xlabel='UTM x', ylabel='UTM y',
    title='NEON AOP Reflectance Weather Quality - SERC Tower Tile',
    frame_width=480, frame_height=480)

# Overlay the RGB and WQI
(serc_rgb_plot * wqi_overlay).opts(title="RGB + Weather Quality Indicator").opts(xformatter='%.0f',
                                                                                 yformatter='%.0f')

```


The cloud conditions for this tile are yellow, which indicates somewhere between 10-50% cloud cover, which is moderate. This is not ideal for reflectance data, but it is still usable. As we will use this data for classification, you would want to consider how the cloud cover may impact your results. You may wish to find a clear-weather (<10% cloud cover) tile to run classification, or at a minimum compare results between the two to better understand how cloud cover impacts the model.

### 4.5 Plot a false color image

Let's continue visualizing the data, next by making a False-Color image, which is a 3-band combination that shows you more than what you would see with the naked eye. For example, you can pull in SWIR or NIR bands to create an image that shows more information about vegetation health Here we will use a SWIR band (2000 nm), a NIR band (850 nm), and blue band (450 nm). Try some different band combinations on your own, remembering not to use bands that are flagged as bad (e.g. the last 10 bands, or those in the bad band windows between 1340-1445 nm and between 1790-1955 nm).


```python
# Plot a False-Color image of the SERC tower tile
serc_refl_false_color = serc_refl_xr.sel(wavelengths=[2000, 850, 450], method='nearest')
serc_refl_false_color = gamma_adjust(serc_refl_false_color,bright=0.3,white_background=True)
serc_refl_false_color.hvplot.rgb(y='y',x='x',bands='wavelengths',
                         xlabel='UTM x',ylabel='UTM y',
                         title='NEON AOP Reflectance False Color Image - SERC Tower Tile',
                         frame_width=480, frame_height=480).opts(xformatter='%.0f', yformatter='%.0f')
```


### 4.6 Make an interactive spectral signature plot

We can also make an interactive plot that displays the spectral signature of the reflectance data for any pixel you click on. This is useful for exploring the spectral signature of different land cover types, and can help you identify which bands may be most useful for classification.


```python
# Interactive Points Plotting
# Modified from https://github.com/auspatious/hyperspectral-notebooks/blob/main/03_EMIT_Interactive_Points.ipynb
POINT_LIMIT = 10
color_cycle = hv.Cycle('Category20')

# Create RGB Map
map = serc_refl_rgb.hvplot.rgb(x='x', y='y',
                               bands='wavelengths',
                               fontscale=1.5,
                               xlabel='UTM x', ylabel='UTM y',
                               frame_width=480, frame_height=480).opts(xformatter='%.0f', yformatter='%.0f')

# Set up a holoviews points array to enable plotting of the clicked points
xmid = serc_refl_rgb.x.values[int(len(serc_refl_rgb.x) / 2)]
ymid = serc_refl_rgb.y.values[int(len(serc_refl_rgb.y) / 2)]

x0 = serc_refl_rgb.x.values[0]
y0 = serc_refl_rgb.y.values[0]

# first_point = ([xmid], [ymid], [0])
first_point = ([x0], [y0], [0])
points = hv.Points(first_point, vdims='id')
points_stream = hv.streams.PointDraw(
    data=points.columns(),
    source=points,
    drag=True,
    num_objects=POINT_LIMIT,
    styles={'fill_color': color_cycle.values[1:POINT_LIMIT+1], 'line_color': 'gray'}
)

posxy = hv.streams.PointerXY(source=map, x=xmid, y=ymid)
clickxy = hv.streams.Tap(source=map, x=xmid, y=ymid)

# Function to build spectral plot of clicked location to show on hover stream plot
def click_spectra(data):
    coordinates = []
    if data is None or not any(len(d) for d in data.values()):
        coordinates.append(clicked_points[0][0], clicked_points[1][0])
    else:
        coordinates = [c for c in zip(data['x'], data['y'])]
    
    plots = []
    for i, coords in enumerate(coordinates):
        x, y = coords
        data = serc_refl_xr.sel(x=x, y=y, method="nearest")
        plots.append(
            data.hvplot.line(
                y="reflectance",
                x="wavelengths",
                color=color_cycle,
                label=f"{i}"
            )
        )
        points_stream.data["id"][i] = i
    return hv.Overlay(plots)

def hover_spectra(x,y):
    return serc_refl_xr.sel(x=x,y=y,method='nearest').hvplot.line(y='reflectance',x='wavelengths', color='black', frame_width=400)
    # return emit_ds.sel(longitude=x,latitude=y,method='nearest').hvplot.line(y='reflectance',x='wavelengths',
    #                                                                         color='black', frame_width=400)
# Define the Dynamic Maps
click_dmap = hv.DynamicMap(click_spectra, streams=[points_stream])
hover_dmap = hv.DynamicMap(hover_spectra, streams=[posxy])
# Plot the Map and Dynamic Map side by side
hv.Layout(hover_dmap*click_dmap + map * points).cols(2).opts(
    hv.opts.Points(active_tools=['point_draw'], size=10, tools=['hover'], color='white', line_color='gray'),
    hv.opts.Overlay(show_legend=False, show_title=False, fontscale=1.5, frame_height=480)
)
```


## 5. Supervised Classification Using TOS Vegetation Structure Data

In the last part of this lesson, we'll go over an example of how to run a supervised classification using the reflectance data along with observational "vegetation structure" data. We will create a random forest model to classify the families of trees represented in this SERC tile, using species determined from the vegetation structure data product (https://data.neonscience.org/data-products/DP1.10098.001)[DP1.10098.001] See the notebook __ to see how the vegetation structure data were pre-processed to generate the training data file. In this notebook, we will just read in this file as a starting point.

Note that this is a quick-and-dirty example, and there are many ways you could improve the classification results, such as using more training data (this uses only data within this AOP tile), filtering out sub-optimal data (e.g. data collected in > 10 % cloud cover conditions, removing outliers (e.g. due to spatial mis-match, shadowing, or other issues), tuning the model parameters, or using a different classification algorithm.

Let's get started, first by exploring the training data.

### 5.1 Read in the training data

First, read in the training data csv file (called `serc_2025_training_data.csv`) that was generated in the previous lesson. This file contains the training data for the random forest model, including the taxonId, family, and geographic coordinates (UTM easting and northing) of the training points. Note that there was not a lot of extensive pre-processing when creating this training data, so you may want to consider ways to assess and improve the training data quality before running the model. 


```python
woody_veg_data = pd.read_csv(r"./data/serc_2025_training_data.csv")
woody_veg_data.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>date_AI</th>
      <th>individualID</th>
      <th>scientificName</th>
      <th>taxonID</th>
      <th>family</th>
      <th>growthForm</th>
      <th>plantStatus</th>
      <th>plotID_AI</th>
      <th>pointID</th>
      <th>stemDiameter</th>
      <th>adjEasting</th>
      <th>adjNorthing</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00039</td>
      <td>Fagus grandifolia Ehrh.</td>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_054</td>
      <td>57</td>
      <td>10.7</td>
      <td>364993.798628</td>
      <td>4.305656e+06</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00041</td>
      <td>Liquidambar styraciflua L.</td>
      <td>LIST2</td>
      <td>Hamamelidaceae</td>
      <td>small tree</td>
      <td>Standing dead</td>
      <td>SERC_054</td>
      <td>57</td>
      <td>9.7</td>
      <td>364990.841914</td>
      <td>4.305660e+06</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00043</td>
      <td>Quercus falcata Michx.</td>
      <td>QUFA</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Dead, broken bole</td>
      <td>SERC_054</td>
      <td>57</td>
      <td>37.1</td>
      <td>364991.794414</td>
      <td>4.305655e+06</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00062</td>
      <td>Quercus falcata Michx.</td>
      <td>QUFA</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_054</td>
      <td>39</td>
      <td>59.7</td>
      <td>364990.424114</td>
      <td>4.305650e+06</td>
    </tr>
    <tr>
      <th>4</th>
      <td>2023-11-29 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00173</td>
      <td>Fagus grandifolia Ehrh.</td>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_047</td>
      <td>21</td>
      <td>22.5</td>
      <td>364673.259742</td>
      <td>4.305225e+06</td>
    </tr>
  </tbody>
</table>
</div>



We can use the `xarray` `sel` method to select the reflectance data corresponding to the training points. This will return an xarray dataset with the reflectance values for each band at the training point locations. As a test, let's plot the reflectance values for the first training point, which corresponds to an American Beech tree (Fagaceae family).


```python
# Define the coordinates of the first training data pixel
easting = woody_veg_data.iloc[0]['adjEasting']
northing = woody_veg_data.iloc[0]['adjNorthing']

# Extract the reflectance data from serc_refl_xr for the specified coordinates
pixel_value = serc_refl_xr.sel(x=easting, y=northing, method='nearest')
pixel_value.reflectance

# Plot the reflectance values for the pixel
plt.plot(pixel_value['wavelengths'].values.flatten(), pixel_value['reflectance'].values.flatten(), 'o');
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/classification/refl-h5-xarray/aop_refl_xarray_classification_files/aop_refl_xarray_classification_75_0.png)
    


As another test, we can plot the refletance value for one of the water bodies that shows up in the reflectance data. In the interactive plot, hover your mouse over one of the water bodies to see the UTM x, y coordinates, and then set those as the easting and northing, as shown below.


```python
# Define the coordinates of the pixel over the pool in the NW corner of the site
easting = 364750
northing = 4305180

# Extract and plot the reflectance data from serc_refl_xr specified coordinates
pixel_value = serc_refl_xr.sel(x=easting, y=northing, method='nearest')
plt.plot(pixel_value['wavelengths'].values.flatten(), pixel_value['reflectance'].values.flatten(), 'o');
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/classification/refl-h5-xarray/aop_refl_xarray_classification_files/aop_refl_xarray_classification_77_0.png)
    


You can see that the spectral signature of water is quite different from that of vegetation.

Now that we've extracted the pixel value for a single pixel, we can extract the reflectance values for all of the training data points. We will loop through the rows of the training dataframe and use the `xarray.Dataset.sel` method to select the reflectance values of the pixels corresponding to the same geographic location as the training data points, and then we will convert this into a pandas DataFrame for use in the random forest model.

### 5.2 Inspect the training data

It is good practice to visually inspect the spectral signatures of the training data, for example, as shown above, to make sure you are executing the code correctly, and that there aren't any major outliers (e.g. you might catch instances of geographic mismatch between the terrestrial location and the airborne data, or if there was a shadowing effect that caused the reflectance values to be very low).


```python
# Get the wavelengths as column names for reflectance
wavelengths = serc_refl_xr.wavelengths.values
wavelength_cols = [f'refl_{int(wl)}' for wl in wavelengths]

records = []

for idx, row in woody_veg_data.iterrows():
    # Find nearest pixel in xarray
    y_val = serc_refl_xr.y.sel(y=row['adjNorthing'], method='nearest').item()
    x_val = serc_refl_xr.x.sel(x=row['adjEasting'], method='nearest').item()
    # Extract reflectance spectrum
    refl = serc_refl_xr.reflectance.sel(y=y_val, x=x_val).values
    # Build record: taxonID, easting, northing, reflectance values
    record = {
        'taxonID': row['taxonID'],
        'family': row['family'],
        'adjEasting': row['adjEasting'],
        'adjNorthing': row['adjNorthing'],
    }
    # Add reflectance values with wavelength column names
    record.update({col: val for col, val in zip(wavelength_cols, refl)})
    records.append(record)
```

Now create a dataframe from this records, and display the first few rows. You can see that the reflectance values are in columns named `refl_381`, `refl_386`, etc., and the family is in the `family` column.


```python
reflectance_df = pd.DataFrame.from_records(records)
# display the updated dataframe, which now includes the reflectance values for all 
reflectance_df
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>taxonID</th>
      <th>family</th>
      <th>adjEasting</th>
      <th>adjNorthing</th>
      <th>refl_381</th>
      <th>refl_386</th>
      <th>refl_391</th>
      <th>refl_396</th>
      <th>refl_401</th>
      <th>refl_406</th>
      <th>...</th>
      <th>refl_2466</th>
      <th>refl_2471</th>
      <th>refl_2476</th>
      <th>refl_2481</th>
      <th>refl_2486</th>
      <th>refl_2491</th>
      <th>refl_2496</th>
      <th>refl_2501</th>
      <th>refl_2506</th>
      <th>refl_2511</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364993.798628</td>
      <td>4.305656e+06</td>
      <td>0.0119</td>
      <td>0.0199</td>
      <td>0.0208</td>
      <td>0.0201</td>
      <td>0.0140</td>
      <td>0.0142</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>LIST2</td>
      <td>Hamamelidaceae</td>
      <td>364990.841914</td>
      <td>4.305660e+06</td>
      <td>0.0103</td>
      <td>0.0140</td>
      <td>0.0141</td>
      <td>0.0209</td>
      <td>0.0123</td>
      <td>0.0132</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2</th>
      <td>QUFA</td>
      <td>Fagaceae</td>
      <td>364991.794414</td>
      <td>4.305655e+06</td>
      <td>0.0046</td>
      <td>0.0158</td>
      <td>0.0200</td>
      <td>0.0168</td>
      <td>0.0140</td>
      <td>0.0141</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>3</th>
      <td>QUFA</td>
      <td>Fagaceae</td>
      <td>364990.424114</td>
      <td>4.305650e+06</td>
      <td>0.0060</td>
      <td>0.0211</td>
      <td>0.0168</td>
      <td>0.0172</td>
      <td>0.0162</td>
      <td>0.0142</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>4</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364673.259742</td>
      <td>4.305225e+06</td>
      <td>0.0029</td>
      <td>0.0181</td>
      <td>0.0211</td>
      <td>0.0216</td>
      <td>0.0151</td>
      <td>0.0128</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>202</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364679.533579</td>
      <td>4.305222e+06</td>
      <td>0.0095</td>
      <td>0.0175</td>
      <td>0.0238</td>
      <td>0.0211</td>
      <td>0.0115</td>
      <td>0.0137</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>203</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364455.772024</td>
      <td>4.305415e+06</td>
      <td>0.0072</td>
      <td>0.0168</td>
      <td>0.0155</td>
      <td>0.0126</td>
      <td>0.0122</td>
      <td>0.0134</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>204</th>
      <td>QUAL</td>
      <td>Fagaceae</td>
      <td>364470.101669</td>
      <td>4.305412e+06</td>
      <td>0.0000</td>
      <td>0.0103</td>
      <td>0.0128</td>
      <td>0.0126</td>
      <td>0.0095</td>
      <td>0.0092</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>205</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364577.886559</td>
      <td>4.305883e+06</td>
      <td>0.0126</td>
      <td>0.0186</td>
      <td>0.0167</td>
      <td>0.0197</td>
      <td>0.0126</td>
      <td>0.0139</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>206</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364353.644854</td>
      <td>4.305790e+06</td>
      <td>0.0110</td>
      <td>0.0172</td>
      <td>0.0161</td>
      <td>0.0213</td>
      <td>0.0153</td>
      <td>0.0195</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
<p>207 rows × 430 columns</p>
</div>



Display the unique taxonIDs and families represented in this training data set:


```python
reflectance_df.taxonID.unique()
```




    array(['FAGR', 'LIST2', 'QUFA', 'LITU', 'ACRU', 'CACA18', 'NYSY', 'ULMUS',
           'CAGL8', 'QURU', 'QUAL', 'CATO6', 'PINUS', 'QUERC', 'COFL2',
           'PRAV', 'QUVE'], dtype=object)




```python
reflectance_df.family.unique()
```




    array(['Fagaceae', 'Hamamelidaceae', 'Magnoliaceae', 'Aceraceae',
           'Betulaceae', 'Cornaceae', 'Ulmaceae', 'Juglandaceae', 'Pinaceae',
           'Rosaceae'], dtype=object)



Next we can manipulate the dataframe using `melt` to reshape the data and make it easier to display the reflectance spectra for each family. This is a helpful first step to visualizing the data and understanding what we're working with before getting into the classification model.

After re-shaping, we can make a figure to display what the spectra look like for the different families that were recorded as part of the vegetation structure data.


```python
# Assuming reflectance_df is your DataFrame and wavelength columns start with 'refl_'
melted_df = reflectance_df.melt(
    id_vars=['family', 'adjEasting', 'adjNorthing'],
    value_vars=[col for col in reflectance_df.columns if col.startswith('refl_')],
    var_name='wavelength',
    value_name='reflectance'
)

# Convert 'wavelength' from 'refl_XXX' to integer
melted_df['wavelength'] = melted_df['wavelength'].str.replace('refl_', '').astype(int)

summary_df = (
    melted_df
    .groupby(['family', 'wavelength'])
    .reflectance
    .agg(['mean', 'min', 'max'])
    .reset_index()
)

plt.figure(figsize=(12, 7))

# Create a color palette
palette = sns.color_palette('hls', n_colors=summary_df['family'].nunique())

for i, (family, group) in enumerate(summary_df.groupby('family')):
    # print(family)
    if family in ['Fagaceae','Magnoliaceae','Hamamelidaceae','Juglandaceae','Aceraceae']:
    # Plot mean line
        plt.plot(group['wavelength'], group['mean'], label=family, color=palette[i])
        # Plot min-max fill
        plt.fill_between(
            group['wavelength'],
            group['min'],
            group['max'],
            color=palette[i],
            alpha=0.2
        )

plt.xlabel('Wavelength')
plt.ylabel('Reflectance')
plt.title('Average Reflectance Spectra by Family \n (with Min/Max Range)')
plt.legend(title='family')
plt.tight_layout()
plt.show()
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/classification/refl-h5-xarray/aop_refl_xarray_classification_files/aop_refl_xarray_classification_86_0.png)
    


We can see that the spectral signatures for the different families have similar shapes, and there is a decent amount of spread in the reflectance values for each family. Some of this spread may be due to the cloud conditions during the time of acquisition. Reflectance values of one species may vary depending on how cloudy it was, or whether there was a cloud obscuring the sun during the collection. The random forest model may not be able to fully distinguish between the different families based on their spectral signatures, but we will see!

### 5.3 Set up the Random Forest Model to Classify Tree Families
We can set up our random forest model by following the steps below:

1. Prepare the training data by dropping the `family` column and setting the `family` column as the target variable. Remove the bad bands (NaN) from the reflectance predictor variables.
2. Split the data into training and testing sets.
3. Train the random forest model on the training data.
4. Evaluate the model on the testing data.
5. Visualize the results.

We will need to import scikit-learn (sklearn) packages in order to run the random forest model. If you don't have these packages installed, you can install them using `!pip install scikit-learn`.


```python
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, accuracy_score
```

### 5.4 Prepare and clean the training data


```python
# 1. Prepare the Data
# Identify reflectance columns
refl_cols = [col for col in reflectance_df.columns if col.startswith('refl_')]

# Remove rows with any NaN in reflectance columns (these are the 'bad bands')
clean_df = reflectance_df.dropna(axis=1)
# re-define refl_columns after removing the ones that are all NaN
refl_cols = [col for col in clean_df.columns if col.startswith('refl_')]
```


```python
# display the cleaned dataframe
clean_df
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>taxonID</th>
      <th>family</th>
      <th>adjEasting</th>
      <th>adjNorthing</th>
      <th>refl_381</th>
      <th>refl_386</th>
      <th>refl_391</th>
      <th>refl_396</th>
      <th>refl_401</th>
      <th>refl_406</th>
      <th>...</th>
      <th>refl_2416</th>
      <th>refl_2421</th>
      <th>refl_2426</th>
      <th>refl_2431</th>
      <th>refl_2436</th>
      <th>refl_2441</th>
      <th>refl_2446</th>
      <th>refl_2451</th>
      <th>refl_2456</th>
      <th>refl_2461</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364993.798628</td>
      <td>4.305656e+06</td>
      <td>0.0119</td>
      <td>0.0199</td>
      <td>0.0208</td>
      <td>0.0201</td>
      <td>0.0140</td>
      <td>0.0142</td>
      <td>...</td>
      <td>0.0246</td>
      <td>0.0227</td>
      <td>0.0238</td>
      <td>0.0213</td>
      <td>0.0240</td>
      <td>0.0191</td>
      <td>0.0272</td>
      <td>0.0298</td>
      <td>0.0158</td>
      <td>0.0258</td>
    </tr>
    <tr>
      <th>1</th>
      <td>LIST2</td>
      <td>Hamamelidaceae</td>
      <td>364990.841914</td>
      <td>4.305660e+06</td>
      <td>0.0103</td>
      <td>0.0140</td>
      <td>0.0141</td>
      <td>0.0209</td>
      <td>0.0123</td>
      <td>0.0132</td>
      <td>...</td>
      <td>0.0208</td>
      <td>0.0195</td>
      <td>0.0201</td>
      <td>0.0217</td>
      <td>0.0268</td>
      <td>0.0191</td>
      <td>0.0173</td>
      <td>0.0388</td>
      <td>0.0180</td>
      <td>0.0181</td>
    </tr>
    <tr>
      <th>2</th>
      <td>QUFA</td>
      <td>Fagaceae</td>
      <td>364991.794414</td>
      <td>4.305655e+06</td>
      <td>0.0046</td>
      <td>0.0158</td>
      <td>0.0200</td>
      <td>0.0168</td>
      <td>0.0140</td>
      <td>0.0141</td>
      <td>...</td>
      <td>0.0295</td>
      <td>0.0262</td>
      <td>0.0277</td>
      <td>0.0266</td>
      <td>0.0302</td>
      <td>0.0285</td>
      <td>0.0274</td>
      <td>0.0306</td>
      <td>0.0317</td>
      <td>0.0211</td>
    </tr>
    <tr>
      <th>3</th>
      <td>QUFA</td>
      <td>Fagaceae</td>
      <td>364990.424114</td>
      <td>4.305650e+06</td>
      <td>0.0060</td>
      <td>0.0211</td>
      <td>0.0168</td>
      <td>0.0172</td>
      <td>0.0162</td>
      <td>0.0142</td>
      <td>...</td>
      <td>0.0208</td>
      <td>0.0218</td>
      <td>0.0245</td>
      <td>0.0240</td>
      <td>0.0300</td>
      <td>0.0219</td>
      <td>0.0262</td>
      <td>0.0262</td>
      <td>0.0240</td>
      <td>0.0236</td>
    </tr>
    <tr>
      <th>4</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364673.259742</td>
      <td>4.305225e+06</td>
      <td>0.0029</td>
      <td>0.0181</td>
      <td>0.0211</td>
      <td>0.0216</td>
      <td>0.0151</td>
      <td>0.0128</td>
      <td>...</td>
      <td>0.0244</td>
      <td>0.0228</td>
      <td>0.0230</td>
      <td>0.0197</td>
      <td>0.0237</td>
      <td>0.0208</td>
      <td>0.0105</td>
      <td>0.0048</td>
      <td>0.0244</td>
      <td>0.0189</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>202</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364679.533579</td>
      <td>4.305222e+06</td>
      <td>0.0095</td>
      <td>0.0175</td>
      <td>0.0238</td>
      <td>0.0211</td>
      <td>0.0115</td>
      <td>0.0137</td>
      <td>...</td>
      <td>0.0251</td>
      <td>0.0080</td>
      <td>0.0114</td>
      <td>0.0079</td>
      <td>0.0129</td>
      <td>0.0061</td>
      <td>0.0188</td>
      <td>0.0414</td>
      <td>0.0173</td>
      <td>0.0153</td>
    </tr>
    <tr>
      <th>203</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364455.772024</td>
      <td>4.305415e+06</td>
      <td>0.0072</td>
      <td>0.0168</td>
      <td>0.0155</td>
      <td>0.0126</td>
      <td>0.0122</td>
      <td>0.0134</td>
      <td>...</td>
      <td>0.0257</td>
      <td>0.0184</td>
      <td>0.0216</td>
      <td>0.0239</td>
      <td>0.0154</td>
      <td>0.0170</td>
      <td>0.0145</td>
      <td>0.0181</td>
      <td>0.0180</td>
      <td>0.0208</td>
    </tr>
    <tr>
      <th>204</th>
      <td>QUAL</td>
      <td>Fagaceae</td>
      <td>364470.101669</td>
      <td>4.305412e+06</td>
      <td>0.0000</td>
      <td>0.0103</td>
      <td>0.0128</td>
      <td>0.0126</td>
      <td>0.0095</td>
      <td>0.0092</td>
      <td>...</td>
      <td>0.0099</td>
      <td>0.0100</td>
      <td>0.0099</td>
      <td>0.0084</td>
      <td>0.0079</td>
      <td>0.0100</td>
      <td>0.0104</td>
      <td>0.0221</td>
      <td>0.0080</td>
      <td>0.0131</td>
    </tr>
    <tr>
      <th>205</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364577.886559</td>
      <td>4.305883e+06</td>
      <td>0.0126</td>
      <td>0.0186</td>
      <td>0.0167</td>
      <td>0.0197</td>
      <td>0.0126</td>
      <td>0.0139</td>
      <td>...</td>
      <td>0.0174</td>
      <td>0.0193</td>
      <td>0.0201</td>
      <td>0.0200</td>
      <td>0.0169</td>
      <td>0.0112</td>
      <td>0.0213</td>
      <td>0.0270</td>
      <td>0.0155</td>
      <td>0.0170</td>
    </tr>
    <tr>
      <th>206</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>364353.644854</td>
      <td>4.305790e+06</td>
      <td>0.0110</td>
      <td>0.0172</td>
      <td>0.0161</td>
      <td>0.0213</td>
      <td>0.0153</td>
      <td>0.0195</td>
      <td>...</td>
      <td>0.0423</td>
      <td>0.0428</td>
      <td>0.0356</td>
      <td>0.0382</td>
      <td>0.0263</td>
      <td>0.0381</td>
      <td>0.0281</td>
      <td>0.0291</td>
      <td>0.0257</td>
      <td>0.0213</td>
    </tr>
  </tbody>
</table>
<p>207 rows × 367 columns</p>
</div>



Note that we have > 360 predictor variables (reflectance values for each band), and only 100 training points, so the model may not perform very well, due to over fitting. You can try increasing the number of training points by using more of the training data, or by using a different classification algorithm. Recall that we just pulled woody vegetation data from this tile that covers the tower, and there are also data collected throughout the rest of the TOS terrestrial sampling plots, so you could pull in more training data from the other tiles as well. You would likely not need all of the reflectance bands - for example, you could take every 2nd or 3rd band, or perform a PCA to reduce the number of bands. These are all things you could test as part of your model. For this lesson, we will include all of the valid reflectance bands for the sake of simplicity.

That said, we will need to remove some of the families that are poorly represented in the training data, as they will not be able to be predicted by the model. We can do this by filtering out families that have less than 10 training points. If you leave these in, the model will not be able to predict them, and will return an error when you try to evaluate the model.


```python
# determine the number of training data points for each family
clean_df[['taxonID','family']].groupby('family').count().sort_values('taxonID', ascending=False)
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>taxonID</th>
    </tr>
    <tr>
      <th>family</th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>Fagaceae</th>
      <td>73</td>
    </tr>
    <tr>
      <th>Magnoliaceae</th>
      <td>35</td>
    </tr>
    <tr>
      <th>Hamamelidaceae</th>
      <td>29</td>
    </tr>
    <tr>
      <th>Juglandaceae</th>
      <td>22</td>
    </tr>
    <tr>
      <th>Aceraceae</th>
      <td>16</td>
    </tr>
    <tr>
      <th>Cornaceae</th>
      <td>13</td>
    </tr>
    <tr>
      <th>Betulaceae</th>
      <td>11</td>
    </tr>
    <tr>
      <th>Ulmaceae</th>
      <td>5</td>
    </tr>
    <tr>
      <th>Pinaceae</th>
      <td>2</td>
    </tr>
    <tr>
      <th>Rosaceae</th>
      <td>1</td>
    </tr>
  </tbody>
</table>
</div>




```python
# Remove the rows where there are fewer than 10 samples
# List of families to remove
families_to_remove = ['Rosaceae', 'Pinaceae', 'Ulmaceae']

# Remove rows where family is in the families_to_remove list
clean_df = clean_df[~clean_df['family'].isin(families_to_remove)].copy()
```

### 5.5 Encode the target variable

Next we need to encode the target variable (family) as integers, so that the model can work properly. Encoding is the process of converting from human-readable text (words / characters) to the byte representations used by computers. We can do this using the `LabelEncoder` from scikit-learn.


```python
# Encode the Target Variable (family)
# Machine learning models require numeric targets. Use LabelEncoder:
le = LabelEncoder()
clean_df['family_encoded'] = le.fit_transform(clean_df['family'])
# Display the cleaned dataframe after encoding the target variable
clean_df[['taxonID','family','family_encoded','adjEasting','adjNorthing','refl_381','refl_2461']].head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>taxonID</th>
      <th>family</th>
      <th>family_encoded</th>
      <th>adjEasting</th>
      <th>adjNorthing</th>
      <th>refl_381</th>
      <th>refl_2461</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>3</td>
      <td>364993.798628</td>
      <td>4.305656e+06</td>
      <td>0.0119</td>
      <td>0.0258</td>
    </tr>
    <tr>
      <th>1</th>
      <td>LIST2</td>
      <td>Hamamelidaceae</td>
      <td>4</td>
      <td>364990.841914</td>
      <td>4.305660e+06</td>
      <td>0.0103</td>
      <td>0.0181</td>
    </tr>
    <tr>
      <th>2</th>
      <td>QUFA</td>
      <td>Fagaceae</td>
      <td>3</td>
      <td>364991.794414</td>
      <td>4.305655e+06</td>
      <td>0.0046</td>
      <td>0.0211</td>
    </tr>
    <tr>
      <th>3</th>
      <td>QUFA</td>
      <td>Fagaceae</td>
      <td>3</td>
      <td>364990.424114</td>
      <td>4.305650e+06</td>
      <td>0.0060</td>
      <td>0.0236</td>
    </tr>
    <tr>
      <th>4</th>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>3</td>
      <td>364673.259742</td>
      <td>4.305225e+06</td>
      <td>0.0029</td>
      <td>0.0189</td>
    </tr>
  </tbody>
</table>
</div>




```python
# Confirm that the number of unique encodings is the same as the number of unique families, as a sanity check
clean_df['family_encoded'].nunique()
```




    7



### 5.6 Split the data into training and testing sets

In this next step, we will split the data into training and testing sets. We will use 80% of the data for training and 20% for testing (this is the default split). This is a common practice in machine learning to test the performance of the model, and to ensure that the model is able to generalize to new data (e.g. you're not over-fitting).


```python
# Split Data into Train/Test Sets
X = clean_df[refl_cols].values
y = clean_df['family_encoded'].values

X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, random_state=42)
```

### 5.7 Create a Random Forest Classifier Object


```python
# Create a Random Forest Classifier object and fit it to the training data
clf = RandomForestClassifier(n_estimators=100, random_state=42)
clf.fit(X_train, y_train)
```

### 5.8 Evaluate the Model


```python
# Determine the accuracy scores based off of the test set
y_pred = clf.predict(X_test)
print("Accuracy:", accuracy_score(y_test, y_pred))
print(classification_report(y_test, y_pred, target_names=le.classes_))
```

    Accuracy: 0.5
                    precision    recall  f1-score   support
    
         Aceraceae       0.67      0.50      0.57         4
        Betulaceae       0.00      0.00      0.00         3
         Cornaceae       0.00      0.00      0.00         3
          Fagaceae       0.55      0.67      0.60        18
    Hamamelidaceae       0.67      0.29      0.40         7
      Juglandaceae       0.33      0.17      0.22         6
      Magnoliaceae       0.47      0.89      0.62         9
    
          accuracy                           0.50        50
         macro avg       0.38      0.36      0.34        50
      weighted avg       0.47      0.50      0.46        50
    

What do these accuracy metrics mean?

- **Precision**: Of the items predicted as a given class, what fraction were actually that class?  
  (Precision = True Positives / (True Positives + False Positives))

- **Recall**: Of all actual items of a given class, what fraction were correctly predicted?  
  (Recall = True Positives / (True Positives + False Negatives))

- **F1-score**: The harmonic mean of precision and recall. It balances both metrics.  
  (F1 = 2 * (Precision * Recall) / (Precision + Recall))

- **Support**: The number of true instances of each class in the dataset (i.e., how many samples belong to each class).

These metrics are commonly used to evaluate classification models. Ideally we would be closer to 1 for the precision, recall, and f1-scores, which would indicate that the model is performing well. The support values indicate how many training points were used for each family, and you can see that some families have very few training points, which is likely negatively impacting the model performance.

## Discussion

What are some things you could do to improve the classification results?

Models are only as good as the underlying training data - so the better the training data (more + higher quality training data points) the better your results will be. 

You could consider the following:
- **Increase the number of training points**: Use more training data from the other tiles
- **Filter out sub-optimal data**: Remove training points that were collected in poor weather conditions (e.g. > 10% cloud cover), or that are outliers (e.g. due to spatial mis-match, shadowing, or other issues)
- **Average the reflectance values over an entire tree crown**: In this example, we just pulled the reflectance values from a single pixel, but you could average the reflectance values over an entire tree crown to get a more representative value for each tree. If part of the tree is in shadow, you may want to remove that pixel from the average.
- **Tune the model parameters**: You can adjust the hyperparameters of the random forest model, such as the number of trees, maximum depth, and minimum samples per leaf, to improve performance.
- **Use a different classification algorithm**: Random forest is a good starting point, but you could also try other algorithms such as support vector machines, gradient boosting, or neural networks to see if they perform better.

## Next Steps

In this example, we just scratched the surface of what you can do with NEON reflectance data. Here are some next steps you could take to further explore and analyze the data:
- **Apply the model to the entire reflectance dataset**: Use the trained model to predict the tree families for all pixels in the reflectance dataset, and visualize the results.
- **Try out the same model on SERC that was acquired in better weather conditions**: Use the reflectance data from SERC 2017, which was collected in clearer weather conditions, to see if the model performs better. Note that you may need to make some minor modifications to the aop_h5refl2xarray functions to accommodate the slightly different data structure of the directional reflectance data product (2019 data is not yet available with BRDF and topographic corrections.)
- **Explore other NEON sites**: Use the `neonutilities` package to explore reflectance data from other NEON sites, and compare the spectral signatures of different land cover types.
- **Add in other NEON AOP datasets**: In this lesson, we only looked at the reflectance data. How might other NEON data products compliment this analysis? For example, you could look at the lidar data to get information about the structure of the vegetation, for example the Canopy Height Model (CHM) or the Digital Surface Model (DSM). You could also look at the AOP imagery data.
- **Use the reflectance data for other applications**: The reflectance data can be used for a variety of applications, such as mapping vegetation health, detecting disease or invasive species, and mapping droughts, wildfires, or other natural disturbances and their impacts. You could use a similar approach to explore some of these applications.


```python
# Bonus: Apply the model to the full AOP reflectance data tile at SERC (IS tower area)

# 1. Prepare the data:

# Extract the reflectance array from your xarray Dataset:
refl = serc_refl_xr['reflectance'].values  # shape: (y, x, bands)
# Remove the bad bands so that we can apply the model, which only uses 363 bands
good_bands = serc_refl_xr['good_wavelengths'].values.astype(bool)
refl_good = refl[:, :, good_bands]         # shape: (y, x, n_good_bands)

# 2. Reshape for prediction:
nrows, ncols, nbands = refl_good.shape
refl_2d = refl_good.reshape(-1, nbands)

# 3. Apply the model:
# Use the trained random forest model (e.g., rf_model) to predict values for every pixel
preds = clf.predict(refl_2d)

# 4. Reshape predictions back to image (y, x):
pred_map = preds.reshape(nrows, ncols)

# 5. Create an xarray DataArray for mapping, using the coordinates from your original data:
pred_xr = xr.DataArray(
    pred_map,
    dims=('y', 'x'),
    coords={'y': serc_refl_xr['y'], 'x': serc_refl_xr['x']},
    name='classification_prediction'
)

# 6. Plot the map, using hvplot to visualize:
# pred_xr.hvplot.image(x='x', y='y', cmap='tab20', title='Random Forest Classification Map')
```


```python
classes = le.classes_
print('classes:', classes)

class_labels = dict(enumerate(classes))
print('class labels:',class_labels)
```


```python
# Convert your prediction DataArray to a categorical type with labels:
pred_xr_labeled = pred_xr.copy()
pred_xr_labeled = pred_xr_labeled.assign_coords(
    family=(('y', 'x'), np.vectorize(class_labels.get)(pred_xr.values))
)
```


```python
# Plot the classification map, using hvplot to visualize:
from matplotlib.colors import ListedColormap, BoundaryNorm
# Plot using hvplot with the family coordinate as the color dimension:

family_codes = np.arange(7)
family_names = classes
# Choose 7 distinct colors (can use tab10, Set1, or your own)
colors = plt.get_cmap('tab10').colors[:7]  # 7 distinct colors from tab10
cmap = ListedColormap([code_to_color[code] for code in family_codes])

# Create a mapping from code to color
code_to_color = {code: colors[i] for i, code in enumerate(family_codes)}

pred_xr_labeled.hvplot.image(
    x='x', y='y', groupby=[], color='family', cmap=cmap,
    title='Random Forest Classification Map', frame_width=600, frame_height=600
).opts(xormatter='%.0f', yformatter='%.0f')
```


```python
# Optional: Create a custom colorbar for the classification map
from matplotlib.colors import ListedColormap, BoundaryNorm

fig, ax = plt.subplots(figsize=(6, 1))
fig.subplots_adjust(bottom=0.5)

# Create a colormap and norm
cmap = ListedColormap([code_to_color[code] for code in family_codes])
norm = BoundaryNorm(np.arange(-0.5, 7.5, 1), cmap.N)

# Create colorbar
cb = plt.colorbar(
    plt.cm.ScalarMappable(norm=norm, cmap=cmap),
    cax=ax, orientation='horizontal', ticks=family_codes
)
cb.ax.set_xticklabels(family_names,fontsize=6)
cb.set_label('Family')
plt.show()
```
