---
syncID: 7e916532e9fa49aeba7464350e661778
title: "Create a Hillshade from a Terrain Raster in Python"
description: "Learn how to create a hillshade from a terrain raster in Python." 
dateCreated: 2017-06-21 
authors: Bridget Hass
contributors: Donal O'Leary
estimatedTime: 0.5 hour
packagesLibraries: gdal, rasterio, neonutilities, python-dotenv
topics: lidar, raster, remote-sensing, elevation, hillshade
languagesTool: Python
dataProduct: DP3.30015.001, DP3.30024.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Lidar/lidar-topography/hillshade/create-hillshade.ipynb
tutorialSeries: intro-lidar-py-series
urlTitle: create-hillshade-py
---

This tutorial covers how to create a hillshade from a terrain raster in Python, and demonstrates a few options for visualizing lidar-derived Digital Elevation Models. 

<div id="ds-objectives" markdown="1">

### Learning Objectives

After completing this tutorial, you will be able to:

* Understand how to read in and visualize Lidar elevation models (DTM, DSM) in Python
* Plot a contour map of the DTM
* Create a hillshade from the DTM
* Calculate and plot Canopy Height along with hillshade and elevation

### Things You’ll Need To Complete This Tutorial

To complete this tutorial, you will need: 
* Python version 3.9 or higher
* Create a <a href="https://www.neonscience.org/about/user-accounts" target="_blank">NEON user account</a>
* Generate an <a href="https://www.neonscience.org/resources/learning-hub/tutorials/api-token-setup" target="_blank">API token</a> for downloading data

#### Install Python Packages

* **gdal** 
* **rasterio**
* **neonutilities**
* **python-dotenv** 

#### Download Data

For this lesson, we will read in Digital Terrain Model (DTM) data collected at NEON's <a href="https://www.neonscience.org/field-sites/teak" target="_blank">Lower Teakettle (TEAK)</a> site in California. This data is downloaded in the first part of the tutorial, using the Python `neonutilities` package.

### Additional Resources

NEON'S Airborne Observation Platform provides Algorithm Theoretical Basis Documents (ATBDs) for all of their data products. Please refer to the ATBDs below for a more in-depth understanding of how the Lidar-derived rasters are generated.

- <a href="https://data.neonscience.org/api/v0/documents/NEON.DOC.002390vB?inline=true" target="_blank">Elevation (DSM and DTM) ATBD</a>
- <a href="https://data.neonscience.org/api/v0/documents/NEON.DOC.002387vB?inline=true" target="_blank">Ecosystem Structure ATBD</a>

</div>

First, let's import the required packages:


```python
import dotenv
import os
import numpy as np
import neonutilities as nu
import rasterio as rio
from rasterio.plot import show
import matplotlib.pyplot as plt
```

As of June 2026, NEON requires an API token for data downloads, to reduce bot scraping and improve user support. Tokens can be generated in NEON data portal user accounts - log in to your account or create one, and go to the API Tokens section. For best practices in storing and using tokens, follow the instructions <a href="https://www.neonscience.org/resources/learning-hub/tutorials/api-token-setup" target="_blank">here</a>. Once you've set up your token as an environment variable, you can load it using  the `python-dotenv` package as follows, optionally specifying the path to the `.env` file in `load_dotenv()`.


```python
dotenv.load_dotenv()
token = os.environ.get("NEON_TOKEN")
```

## Read in the datasets
### Download Lidar Elevation Models from TEAK

To start, we will download the NEON Elevation Models (DTM and DSM) which are provided in geotiff (.tif) format. Use the `download_url` function below to download the data directly from the cloud storage location.

For more information on these data products, refer to the NEON Data Portal page, linked here: <a href="https://data.neonscience.org/data-products/DP3.30024.001" target="_blank">Elevation - LiDAR</a>.


```python
# download the DSM and DTM data to the C:/data directory - change this if desired
nu.by_tile_aop(dpid='DP3.30024.001',
               site='TEAK',
               year=2021,
               easting=320000,
               northing=4092000,
               token=token,
               savepath=r'C:\data')
```

    Provisional NEON data are not included. To download provisional data, use input parameter include_provisional=True.
    

    Continuing will download 3 NEON data files totaling approximately 6.7 MB. Do you want to proceed? (y/n)  y
    

    Downloading 3 NEON data files totaling approximately 6.7 MB
    
    100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 3/3 [00:01<00:00,  2.97it/s]
    

Display the DSM and DTM files that have been downloaded:


```python
dem_dir = os.path.expanduser(r"C:\data\DP3.30024.001")

for root, dirs, files in os.walk(dem_dir):
    for file in files:
        if file.endswith('DTM.tif'):
            dtm_file = os.path.join(root, file)
            print(os.path.join(root, file).replace(os.path.expanduser('~/Downloads/'),'..'))
        if file.endswith('DSM.tif'):
            dsm_file = os.path.join(root, file)
            print(os.path.join(root, file).replace(os.path.expanduser('~/Downloads/'),'..'))
```

    C:\data\DP3.30024.001\neon-aop-products\2021\FullSite\D17\2021_TEAK_5\L3\DiscreteLidar\DSMGtif\NEON_D17_TEAK_DP3_320000_4092000_DSM.tif
    C:\data\DP3.30024.001\neon-aop-products\2021\FullSite\D17\2021_TEAK_5\L3\DiscreteLidar\DTMGtif\NEON_D17_TEAK_DP3_320000_4092000_DTM.tif
    

###  Calculate Hillshade

Hillshade is used to visualize the hypothetical illumination value (from 0-255) of each pixel on a surface given a specified light source. To calculate hillshade, we need the zenith (altitude) and azimuth of the illumination source, as well as the slope and aspect of the terrain. The formula for hillshade is:

$$Hillshade = 255.0 * (( cos(zenith_I)*cos(slope_T))+(sin(zenith_I)*sin(slope_T)*cos(azimuth_I-aspect_T))$$

Where all angles are in radians. 

For more information about how hillshades work, refer to the ESRI ArcGIS page 
<a href="https://pro.arcgis.com/en/pro-app/3.0/tool-reference/3d-analyst/how-hillshade-works.htm#" target="_blank">How Hillshade Works</a>. 


```python
# function to caluclate hillshade
def hillshade(array,azimuth,angle_altitude):
    azimuth = 360.0 - azimuth 
    
    x, y = np.gradient(array)
    slope = np.pi/2. - np.arctan(np.sqrt(x*x + y*y))
    aspect = np.arctan2(-x, y)
    azm_rad = azimuth*np.pi/180. #azimuth in radians
    alt_rad = angle_altitude*np.pi/180. #altitude in radians
 
    shaded = np.sin(alt_rad)*np.sin(slope) + np.cos(alt_rad)*np.cos(slope)*np.cos((azm_rad - np.pi/2.) - aspect)
    
    return 255*(shaded + 1)/2
```


```python
dtm_dataset = rio.open(dtm_file)
dtm_data = dtm_dataset.read(1)
```



```python
fig, ax = plt.subplots(1, 1, figsize=(6,6))
dtm_map = show(dtm_dataset, title='Digital Terrain Model', adjust=False, cmap='terrain', ax=ax); # adjust=False prevents auto-normalization
show(dtm_dataset, adjust=False, contour=True, ax=ax); # overlay the contours
im = dtm_map.get_images()[0]
fig.colorbar(im, label = 'Elevation (m)', ax=ax) # add a colorbar
ax.ticklabel_format(useOffset=False, style='plain') # turn off scientific notation
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Lidar/lidar-topography/hillshade/create-hillshade_files/output_13_0.png)
    


Now that we have a function to generate hillshade, we need to read in the DTM raster using rasterio and then calculate hillshade using the `hillshade` function. We can then plot both.


```python
# Use hillshade function on the DTM data array
hs_data = hillshade(dtm_data,225,45)
```


```python
fig, ax = plt.subplots(1, 1, figsize=(6,6))
ext = [dtm_dataset.bounds.left, dtm_dataset.bounds.right, dtm_dataset.bounds.bottom, dtm_dataset.bounds.top]
plt.imshow(hs_data, extent=ext)
plt.title('TEAK Hillshade')
ax=plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation 
rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degrees
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Lidar/lidar-topography/hillshade/create-hillshade_files/output_16_0.png)
    



```python
#Overlay transparent hillshade on DTM:
fig, ax = plt.subplots(1, 1, figsize=(6,6))
im1 = plt.imshow(dtm_data,cmap='terrain_r',extent=ext); 
cbar = plt.colorbar(); cbar.set_label('Elevation, m',rotation=270,labelpad=20)
im2 = plt.imshow(hs_data,cmap='Greys',alpha=0.8,extent=ext); #plt.colorbar()
ax=plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation 
rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degrees
plt.grid('on'); # plt.colorbar(); 
plt.title('TEAK Hillshade + DTM');
```



![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Lidar/lidar-topography/hillshade/create-hillshade_files/output_17_0.png)
    


### Calculate CHM & Overlay on Top of Hillshade

Canopy Height can be simply calculated by subtracting the Digital Terrain Model from the Digital Surface Model. While NEON's CHM is calculated using a slightly more sophisticated "pit-free" algorithm (see the ATBD linked at the top of this tutorial), in this example, we'll calculate the CHM with the simple difference formula. First, read in the DSM data set, which we previously downloaded into the data folder.


```python
dsm_dataset = rio.open(dsm_file)
dsm_data = dsm_dataset.read(1)
```



```python
# calculate CHM by differencing the terrain model (DTM) from the surface model (DSM):
chm_data = dsm_data - dtm_data;
```

Plot the Canopy Height Model for reference:


```python
fig, ax = plt.subplots(1, 1, figsize=(6,6))
im1 = plt.imshow(chm_data,cmap='Greens',extent=ext); 
ax=plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation 
fig.colorbar(im1, label = 'CHM (m)', ax=ax) # add a colorbar
ax.set_title('Canopy Height Model (DSM-DTM)');
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Lidar/lidar-topography/hillshade/create-hillshade_files/output_22_0.png)
    


Finally, we can make a plot to bring together all of these visualizations from earlier in the tutorial.


```python
#Overlay transparent hillshade on DTM:
fig, ax = plt.subplots(1, 1, figsize=(10,10))

#Terrain
im1 = plt.imshow(dtm_data,cmap='terrain',extent=ext); 
cbar1 = plt.colorbar(im1,fraction=0.04,pad=0.08,ax=ax); 
cbar1.set_label('Elevation, m',rotation=270,labelpad=20)

#Hillshade
im2 = plt.imshow(hs_data,cmap='Greys',alpha=.5,extent=ext); 

#Canopy
im3 = plt.imshow(chm_data,cmap='Greens',alpha=0.6,extent=ext); 
cbar2 = plt.colorbar(im3,fraction=0.045,pad=0.04,ax=ax); cbar2.set_label('Canopy Height, m',rotation=270,labelpad=15)

ax=plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation 
rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degrees
plt.grid('on'); # plt.colorbar(); 
plt.title('Terrain, Hillshade, & Canopy Height');
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Lidar/lidar-topography/hillshade/create-hillshade_files/output_24_0.png)
