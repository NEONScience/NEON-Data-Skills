---
syncID: 61ad1fc43ddd45b49cad1bca48656bbe
title: "NEON AOP Hyperspectral Data in HDF5 format with Python" 
description: "Learn how to read NEON AOP L3 reflectance h5 data in Python and visualize spectral data."
dateCreated: 2018-07-04 
authors: Bridget Hass
contributors: Donal O'Leary
estimatedTime: 1 hour
packagesLibraries: numpy, h5py, matplotlib, neonutilities, scikit-image, ipywidgets
topics: hyperspectral-remote-sensing, HDF5, remote-sensing, reflectance
languagesTool: Python
dataProduct: DP3.30006.001, DP3.30006.002
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/intro-hyperspectral/intro-refl-h5/intro-l3-refl-h5.ipynb
tutorialSeries: intro-hsi-py-series
urlTitle: neon-refl-h5-py
---


In this introductory tutorial, we demonstrate how to read NEON AOP hyperspectral reflectance (Level 3, tiled) data in Python. This starts with the fundamental steps of downloading, reading in, and getting familiar with the HDF5 (h5) format that the reflectance data is delivered in. Then you will develop and practice skills to explore and visualize the spectral data. 

<div id="ds-objectives" markdown="1">
    
### Learning Objectives

After completing this tutorial, you will be able to:

* Use `neonutilities` `list_available_dates` to find available data and `by_tile_aop` to download a single reflectance tile
* Use the package `h5py` and the `visititems` method to read a reflectance HDF5 file and view data attributes.
* Read the data ignore value and scaling factor and apply these values to produce a "cleaned" reflectance array.
* Plot a histogram of reflectance values to visualize the range and distribution of values.
* Extract and plot a single band of reflectance data.
* Apply a histogram stretch and adaptive equalization to improve the contrast of an image. 

### Install Python Packages

* **numpy**
* **matplotlib** 
* **h5py**
* **python-dotenv**
* **neonutilities**
* **ipywidgets** (optional)
* **scikit-image** (optional)

### Set Up NEON User Account and Token

To download data from NEON, we strongly recommend setting up a NEON User Account and creating a token. Using a token when downloading data via the API, including when using the `neonutilities` package, links your downloads to your user account, and also enables faster download speeds. Follow the tutorial <a href="https://www.neonscience.org/resources/learning-hub/tutorials/neon-api-tokens-tutorial" target="_blank">Using an API Token when Accessing NEON Data with neonUtilities</a> for complete instructions on setting up a token.

### Download Data

To complete this tutorial, you will download and read in surface directional reflectance data collected at the NEON <a href="https://www.neonscience.org/field-sites/serc" target="_blank">Smithsonian Environmental Research Center (SERC)</a> site in Maryland. This data is downloaded in the first part of the tutorial, using the `neonutilities` `by_tile_aop` function.

### Additional Resources
More details about the surface bidirectional reflectance data product can be found on the data product page, linked below.
- <a href="https://data.neonscience.org/data-products/DP3.30006.002" target="_blank">Spectrometer orthorectified surface bidirectional reflectance - mosaic</a>

In addition, NEON'S Airborne Observation Platform provides Algorithm Theoretical Basis Documents (ATBDs) for all of their data products. Please refer to the ATBDs below for a more in-depth understanding of the reflectance data.
- <a href="https://data.neonscience.org/api/v0/documents/NEON.DOC.001288vB?inline=true" target="_blank">NEON Imaging Spectrometer Radiance to Reflectance ATBD</a>
- <a href="https://data.neonscience.org/api/v0/documents/NEON.DOC.004365vB?inline=true" target="_blank">Spectrometer Mosaic ATBD</a>

</div>


Hyperspectral remote sensing data is a useful tool for measuring changes to our environment at the Earth’s surface. In this tutorial we explore how to extract information from a tile (1000m x 1000m x 426 bands) of NEON AOP orthorectified surface reflectance data, stored in hdf5 format. For more information on this data product, refer to the <a href="http://data.neonscience.org/data-products/DP3.30006.002" target="_blank">NEON Data Product Catalog</a>.

#### Mapping the Invisible: Introduction to Spectral Remote Sensing

For more information on spectral remote sensing watch the video below. 

<iframe width="560" height="315" src="https://www.youtube.com/embed/3iaFzafWJQE" frameborder="0" allowfullscreen></iframe>


## Set up


First let's import the required packages:


```python
import os
import dotenv
import numpy as np
import h5py
import matplotlib.pyplot as plt
import neonutilities as nu
```

<div id="ds-objectives" markdown="1">

**Data Tip: Using `help` and `?`**

We will be using a number of built-in and user-defined functions and methods throughout the tutorial. If you are uncertain what a certain function does, or how to call it, you can type `help()` or type a `?` at the end of the function or method and run the cell (either select Cell > Run Cells or Shift Enter with your cursor in the cell you want to run). The `?` will pop up a window at the bottom of the notebook displaying the function's `docstrings`, which includes information about the function and usage. We encourage you to use `help` and `?` throughout the tutorial as you come across functions you are unfamiliar with. Try out these commands to learn more about the `h5py` function, for example:

`help(h5py)`

or 

`h5py.File?`

</div>


## Download the reflectance dataset

To start, we will download the NEON bidirectional surface reflectance data (DP3.30006.002) which are provided in hdf5 (.h5) format. Use the neonutilities `by_tile_aop` function below to download the data from the portal. First, set up your token and explore the available data. We will set up the token as an environment variable and use the `dotenv` package to , but you can also hard-code it into the script if you prefer (with the caveat that this is less reproducible).

```python
dotenv.set_key(dotenv_path = ".env",
key_to_set = "NEON_TOKEN",
value_to_set = "YOUR_TOKEN_HERE") # replace this string with the token copied from your NEON User Account page
```


```python
dotenv.load_dotenv()
```




    True




```python
neon_token = os.environ.get("NEON_TOKEN")
```

Now that you have set up the token, you can use it in in the `by_tile_aop` function downloading. Before downloading data, we'll run a couple more `neonutilities` functions to determine what dates of data are available for the SERC site, as well as the spatial extent of the data. We'll start with `list_available_dates` to determine the available dates for the bidirectional reflectance data. This just requires the data product id (`dpid`) and site code (in this case, "SERC") for inputs.


```python
nu.list_available_dates('DP3.30006.002','SERC')
```

    PROVISIONAL Available Dates: 2022-05, 2025-06
    

Currently (as of Nov 2025) there are provisional data available at the SERC site in 2022 and 2025.

We will also need to provide the easting and northing (in UTM) of the coordinates of the reflectance tile we want to download. To determine the tile extents, we can use the `get_aop_tile_extents` function as follows:


```python
serc2025_extents = nu.get_aop_tile_extents('DP3.30006.002','SERC','2025')
# optionally use your token
# serc2025_extents = nu.get_aop_tile_extents('DP3.30006.002','SERC','2025',token=neon_token)
```

    Easting Bounds: (358000, 370000)
    Northing Bounds: (4298000, 4312000)
    

We'll select a single tile to download and explore, that covers some different land types: water, buildings, and vegetation. This tile has southwest coordinates of 368000 (easting) and 4306000 (northing). Use `help(nu.by_tile_aop)` for more details on the function and the required inputs. By default, if you leave out check_size, you will be prompted to continue downloading after seeing the size of the data. This data tile is under 700 MB, but always make sure to check that you have enough space locally before downloading AOP data, as they can be quite large in volume (especially when working with a full site or a larger portion of a site). Set your data download directory, we recommend setting this close to the root directory as the function will maintain the folder structure as it is organized on the cloud storage and the data are somewhat nested.


```python
home_dir = os.path.expanduser("~")
data_dir = os.path.join(home_dir,'data')
```


```python
nu.by_tile_aop(
    dpid='DP3.30006.002',
    site='SERC',
    year='2025',
    easting=368000,
    northing=4306000,
    include_provisional=True,
    savepath=data_dir,
    token=neon_token)
```


```python
We can see where we downloaded the files using `os.walk` as follows:
```


```python
# iterate over directory and subdirectory to get the complete list of h5 files
for root, dirs, files in os.walk(data_dir):
    for name in files:
        if name.endswith('.h5'):
            print(os.path.join(root, name))  # print full file name, including the path
```

    C:\Users\bhass\data\DP3.30006.002\neon-aop-provisional-products\2025\FullSite\D02\2025_SERC_7\L3\Spectrometer\Reflectance\NEON_D02_SERC_DP3_368000_4306000_bidirectional_reflectance.h5
    

Now that we've downloaded the data, we can read it in using the `h5py` package.

## Read in hdf5 file

```f = h5py.File('file.h5','r')``` reads in an h5 file to the variable f. 

Now that we have an idea of how to use `h5py` to read in an h5 file, let's use this to explore the hyperspectral reflectance data. Note that if the h5 file is stored in a different directory than where you are running your notebook, you need to include the path (either relative or absolute) to the directory where that data file is stored. Use `os.path.join` to create the full path of the file. 


```python
# Note that you may need to update this filepath if you set a different path to download to
f = h5py.File(os.path.join(data_dir,
                           'DP3.30006.002','neon-aop-provisional-products','2025','FullSite',
                           'D02','2025_SERC_7','L3','Spectrometer','Reflectance',
                           'NEON_D02_SERC_DP3_368000_4306000_bidirectional_reflectance.h5'),'r')
```

## Explore NEON AOP HDF5 Reflectance Files

We can look inside the HDF5 dataset with the ```h5py visititems``` function. The ```list_dataset``` function defined below displays all datasets stored in the hdf5 file and their locations within the hdf5 file:


```python
#list_dataset lists the names of datasets in an hdf5 file
def list_dataset(name,node):
    if isinstance(node, h5py.Dataset):
        print(name)

f.visititems(list_dataset)
```

    SERC/Reflectance/Metadata/Ancillary_Imagery/Acquisition_Date
    SERC/Reflectance/Metadata/Ancillary_Imagery/Aerosol_Optical_Thickness
    SERC/Reflectance/Metadata/Ancillary_Imagery/Aspect
    SERC/Reflectance/Metadata/Ancillary_Imagery/Cast_Shadow
    SERC/Reflectance/Metadata/Ancillary_Imagery/Dark_Dense_Vegetation_Classification
    SERC/Reflectance/Metadata/Ancillary_Imagery/Data_Selection_Index
    SERC/Reflectance/Metadata/Ancillary_Imagery/Haze_Cloud_Water_Map
    SERC/Reflectance/Metadata/Ancillary_Imagery/Illumination_Factor
    SERC/Reflectance/Metadata/Ancillary_Imagery/Path_Length
    SERC/Reflectance/Metadata/Ancillary_Imagery/Sky_View_Factor
    SERC/Reflectance/Metadata/Ancillary_Imagery/Slope
    SERC/Reflectance/Metadata/Ancillary_Imagery/Smooth_Surface_Elevation
    SERC/Reflectance/Metadata/Ancillary_Imagery/Visibility_Index_Map
    SERC/Reflectance/Metadata/Ancillary_Imagery/Water_Vapor_Column
    SERC/Reflectance/Metadata/Ancillary_Imagery/Weather_Quality_Indicator
    SERC/Reflectance/Metadata/Coordinate_System/Coordinate_System_String
    SERC/Reflectance/Metadata/Coordinate_System/EPSG Code
    SERC/Reflectance/Metadata/Coordinate_System/Map_Info
    SERC/Reflectance/Metadata/Coordinate_System/Proj4
    SERC/Reflectance/Metadata/Logs/L003-1_20250612/ATCOR_Input_file
    SERC/Reflectance/Metadata/Logs/L003-1_20250612/ATCOR_Processing_Log
    SERC/Reflectance/Metadata/Logs/L003-1_20250612/BRDF_COEFFS_JSON_for_Hytools
    SERC/Reflectance/Metadata/Logs/L003-1_20250612/BRDF_Config_JSON_for_Hytools
    SERC/Reflectance/Metadata/Logs/L003-1_20250612/Shadow_Processing_Log
    SERC/Reflectance/Metadata/Logs/L003-1_20250612/Skyview_Processing_Log
    SERC/Reflectance/Metadata/Logs/L003-1_20250612/Solar_Azimuth_Angle
    SERC/Reflectance/Metadata/Logs/L003-1_20250612/Solar_Zenith_Angle
    SERC/Reflectance/Metadata/Logs/L004-1_20250612/ATCOR_Input_file
    SERC/Reflectance/Metadata/Logs/L004-1_20250612/ATCOR_Processing_Log
    SERC/Reflectance/Metadata/Logs/L004-1_20250612/BRDF_COEFFS_JSON_for_Hytools
    SERC/Reflectance/Metadata/Logs/L004-1_20250612/BRDF_Config_JSON_for_Hytools
    SERC/Reflectance/Metadata/Logs/L004-1_20250612/Shadow_Processing_Log
    SERC/Reflectance/Metadata/Logs/L004-1_20250612/Skyview_Processing_Log
    SERC/Reflectance/Metadata/Logs/L004-1_20250612/Solar_Azimuth_Angle
    SERC/Reflectance/Metadata/Logs/L004-1_20250612/Solar_Zenith_Angle
    SERC/Reflectance/Metadata/Logs/L005-1_20250612/ATCOR_Input_file
    SERC/Reflectance/Metadata/Logs/L005-1_20250612/ATCOR_Processing_Log
    SERC/Reflectance/Metadata/Logs/L005-1_20250612/BRDF_COEFFS_JSON_for_Hytools
    SERC/Reflectance/Metadata/Logs/L005-1_20250612/BRDF_Config_JSON_for_Hytools
    SERC/Reflectance/Metadata/Logs/L005-1_20250612/Shadow_Processing_Log
    SERC/Reflectance/Metadata/Logs/L005-1_20250612/Skyview_Processing_Log
    SERC/Reflectance/Metadata/Logs/L005-1_20250612/Solar_Azimuth_Angle
    SERC/Reflectance/Metadata/Logs/L005-1_20250612/Solar_Zenith_Angle
    SERC/Reflectance/Metadata/Spectral_Data/FWHM
    SERC/Reflectance/Metadata/Spectral_Data/Wavelength
    SERC/Reflectance/Metadata/to-sensor_Azimuth_Angle
    SERC/Reflectance/Metadata/to-sensor_Zenith_Angle
    SERC/Reflectance/Reflectance_Data
    

You can see that there is a lot of information stored inside this reflectance hdf5 file. Most of this information is *metadata* (data about the reflectance data), for example, this file stores input parameters used in the atmospheric correction. For this introductory lesson, we will only work with two of these datasets, the reflectance data (hyperspectral cube), and the corresponding geospatial information, stored in Metadata/Coordinate_System:

- `SERC/Reflectance/Reflectance_Data`
- `SERC/Reflectance/Metadata/Coordinate_System/`

We can also display the name, shape, and type of each of these datasets using the `ls_dataset` function defined below, which is also called with the `visititems` method: 


```python
#ls_dataset displays the name, shape, and type of datasets in hdf5 file
def ls_dataset(name,node):
    if isinstance(node, h5py.Dataset):
        print(node)
```

**Data Tip:** To see what the `visititems` method does, type `?` at the end, eg.
`f.visititems?`


```python
f.visititems(ls_dataset)
```

    <HDF5 dataset "Acquisition_Date": shape (1000, 1000), type "<i4">
    <HDF5 dataset "Aerosol_Optical_Thickness": shape (1000, 1000), type "<f4">
    <HDF5 dataset "Aspect": shape (1000, 1000), type "<f4">
    <HDF5 dataset "Cast_Shadow": shape (1000, 1000), type "<f4">
    <HDF5 dataset "Dark_Dense_Vegetation_Classification": shape (1000, 1000), type "|u1">
    <HDF5 dataset "Data_Selection_Index": shape (1000, 1000), type "<i4">
    <HDF5 dataset "Haze_Cloud_Water_Map": shape (1000, 1000), type "|u1">
    <HDF5 dataset "Illumination_Factor": shape (1000, 1000), type "<f4">
    <HDF5 dataset "Path_Length": shape (1000, 1000), type "<f4">
    <HDF5 dataset "Sky_View_Factor": shape (1000, 1000), type "<f4">
    <HDF5 dataset "Slope": shape (1000, 1000), type "<f4">
    <HDF5 dataset "Smooth_Surface_Elevation": shape (1000, 1000), type "<f4">
    <HDF5 dataset "Visibility_Index_Map": shape (1000, 1000), type "<f4">
    <HDF5 dataset "Water_Vapor_Column": shape (1000, 1000), type "<f4">
    <HDF5 dataset "Weather_Quality_Indicator": shape (1000, 1000), type "<i4">
    <HDF5 dataset "Coordinate_System_String": shape (), type "|O">
    <HDF5 dataset "EPSG Code": shape (), type "|O">
    <HDF5 dataset "Map_Info": shape (), type "|O">
    <HDF5 dataset "Proj4": shape (), type "|O">
    <HDF5 dataset "ATCOR_Input_file": shape (), type "|O">
    <HDF5 dataset "ATCOR_Processing_Log": shape (), type "|O">
    <HDF5 dataset "BRDF_COEFFS_JSON_for_Hytools": shape (), type "|O">
    <HDF5 dataset "BRDF_Config_JSON_for_Hytools": shape (), type "|O">
    <HDF5 dataset "Shadow_Processing_Log": shape (), type "|O">
    <HDF5 dataset "Skyview_Processing_Log": shape (), type "|O">
    <HDF5 dataset "Solar_Azimuth_Angle": shape (), type "<f4">
    <HDF5 dataset "Solar_Zenith_Angle": shape (), type "<f4">
    <HDF5 dataset "ATCOR_Input_file": shape (), type "|O">
    <HDF5 dataset "ATCOR_Processing_Log": shape (), type "|O">
    <HDF5 dataset "BRDF_COEFFS_JSON_for_Hytools": shape (), type "|O">
    <HDF5 dataset "BRDF_Config_JSON_for_Hytools": shape (), type "|O">
    <HDF5 dataset "Shadow_Processing_Log": shape (), type "|O">
    <HDF5 dataset "Skyview_Processing_Log": shape (), type "|O">
    <HDF5 dataset "Solar_Azimuth_Angle": shape (), type "<f4">
    <HDF5 dataset "Solar_Zenith_Angle": shape (), type "<f4">
    <HDF5 dataset "ATCOR_Input_file": shape (), type "|O">
    <HDF5 dataset "ATCOR_Processing_Log": shape (), type "|O">
    <HDF5 dataset "BRDF_COEFFS_JSON_for_Hytools": shape (), type "|O">
    <HDF5 dataset "BRDF_Config_JSON_for_Hytools": shape (), type "|O">
    <HDF5 dataset "Shadow_Processing_Log": shape (), type "|O">
    <HDF5 dataset "Skyview_Processing_Log": shape (), type "|O">
    <HDF5 dataset "Solar_Azimuth_Angle": shape (), type "<f4">
    <HDF5 dataset "Solar_Zenith_Angle": shape (), type "<f4">
    <HDF5 dataset "FWHM": shape (426,), type "<f8">
    <HDF5 dataset "Wavelength": shape (426,), type "<f8">
    <HDF5 dataset "to-sensor_Azimuth_Angle": shape (1000, 1000), type "<f4">
    <HDF5 dataset "to-sensor_Zenith_Angle": shape (1000, 1000), type "<f4">
    <HDF5 dataset "Reflectance_Data": shape (1000, 1000, 426), type "<i2">
    

Now that we can see the structure of the hdf5 file, let's take a look at some of the information that is stored inside. Let's start by extracting the reflectance data, which is nested under `SERC/Reflectance/Reflectance_Data`:  


```python
serc_refl = f['SERC']['Reflectance']
print(serc_refl)
```

    <HDF5 group "/SERC/Reflectance" (2 members)>
    

The two members of the HDF5 group `/SERC/Reflectance` are `Metadata` and `Reflectance_Data`. Let's save the reflectance data as the variable serc_reflArray:


```python
serc_reflArray = serc_refl['Reflectance_Data']
print(serc_reflArray)
```

    <HDF5 dataset "Reflectance_Data": shape (1000, 1000, 426), type "<i2">
    

We can extract the size of this reflectance array that we extracted using the `shape` method:


```python
refl_shape = serc_reflArray.shape
print('SERC Reflectance Data Dimensions:',refl_shape)
```

    SERC Reflectance Data Dimensions: (1000, 1000, 426)
    

This 3-D shape (1000,1000,426) corresponds to (y,x,bands), where (x,y) are the dimensions of the reflectance array in pixels. Hyperspectral data sets are often called "cubes" to reflect this 3-dimensional shape.

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-general/DataCube.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-general/DataCube.png"></a>
    <figcaption> A data cube representation of a hyperspectral data set. Source: National Ecological Observatory Network (NEON)</figcaption>
</figure>

NEON hyperspectral data contain around 426 spectral bands, and when working with tiled data, the spatial dimensions are 1000 x 1000, where each pixel represents 1 meter. Now let's take a look at the wavelength values. First, we will extract wavelength information from the `serc_refl` variable that we created:


```python
#define the wavelengths variable
wavelengths = serc_refl['Metadata']['Spectral_Data']['Wavelength']

#View wavelength information and values
print('wavelengths:',wavelengths)
```

    wavelengths: <HDF5 dataset "Wavelength": shape (426,), type "<f8">
    

We can then use `numpy` (imported as `np`) to see the minimum and maximum wavelength values:


```python
# Display min & max wavelengths
print('min wavelength:', round(np.amin(wavelengths),2),'nm')
print('max wavelength:', round(np.amax(wavelengths),2),'nm')
```

    min wavelength: 381.86 nm
    max wavelength: 2511.32 nm
    

Finally, we can determine the band widths (distance between center bands of two adjacent bands). Let's try this for the first two bands and the last two bands. Remember that Python uses 0-based indexing (`[0]` represents the first value in an array), and note that you can also use negative numbers to splice values from the end of an array (`[-1]` represents the last value in an array).


```python
#show the band widths between the first 2 bands and last 2 bands 
print('band width between first 2 bands =',round(wavelengths[1]-wavelengths[0],3),'nm')
print('band width between last 2 bands =',round(wavelengths[-1]-wavelengths[-2],3),'nm')
```

    band width between first 2 bands = 5.01 nm
    band width between last 2 bands = 5.01 nm
    

The center wavelengths recorded in this hyperspectral cube range from 383.88 - 2512.18 nm, and each band covers a range of ~5 nm. Now let's extract spatial information, which is stored under `SERC/Reflectance/Metadata/Coordinate_System/Map_Info`:


```python
serc_mapInfo = serc_refl['Metadata']['Coordinate_System']['Map_Info']
print('SERC Map Info:')
print(serc_mapInfo[()].decode("utf-8")) # use decode to display the map info as a string
```

    SERC Map Info:
    UTM,  1.000,  1.000,  368000.000,  4307000.000,  1.000000e+00,  1.000000e+00,  18,  North,  WGS-84,  units=Meters, 0
    

**Understanding the output:**

Here we can spatial information about the reflectance data. Below is a break down of what each of these values means:

- `UTM` - coordinate system (Universal Transverse Mercator)
- `1.000, 1.000` - 
- `368000.000, 4307000.0` - UTM coordinates (meters) of the map origin, which refers to the upper-left corner of the image  (xMin, yMax). 
- `1.0000000, 1.0000000` - pixel resolution (meters)
- `18` - UTM zone
- `N` - UTM hemisphere (North for all NEON sites)
- `WGS-84` - reference ellipoid

Note that if you leave out hte `decode."utf-8"`, the letter `b` will appear before UTM, which signifies that the variable-length string data is stored in **b**inary format when it is written to the hdf5 file. Don't worry about it for now, as we will convert the numerical data we need into floating point numbers. For more information on hdf5 strings read the <a href="http://docs.h5py.org/en/latest/strings.html" target="_blank">h5py documentation</a>. 

Let's extract relevant information from the `Map_Info` metadata to define the spatial extent of this dataset. To do this, we can use the `split` method to break up this string into separate values:


```python
#First convert mapInfo to a string
mapInfo_string = serc_mapInfo[()].decode("utf-8") # read in as string
```


```python
#split the strings using the separator "," 
mapInfo_split = mapInfo_string.split(",") 
print(mapInfo_split)
```

    ['UTM', '  1.000', '  1.000', '  368000.000', '  4307000.000', '  1.000000e+00', '  1.000000e+00', '  18', '  North', '  WGS-84', '  units=Meters', ' 0']
    

Now we can extract the spatial information we need from the map info values, convert them to the appropriate data type (float) and store it in a way that will enable us to access and apply it later when we want to plot the data: 


```python
#Extract the resolution & convert to floating decimal number
res = float(mapInfo_split[5]),float(mapInfo_split[6])
print('Resolution:',res)
```

    Resolution: (1.0, 1.0)
    


```python
#Extract the upper left-hand corner coordinates from mapInfo
xMin = float(mapInfo_split[3]) 
yMax = float(mapInfo_split[4])

#Calculate the xMax and yMin values from the dimensions
xMax = xMin + (refl_shape[1]*res[0]) #xMax = left edge + (# of columns * x pixel resolution)
yMin = yMax - (refl_shape[0]*res[1]) #yMin = top edge - (# of rows * y pixel resolution)
```

Now we can define the spatial extent as the tuple `(xMin, xMax, yMin, yMax)`. This is the format required for applying the spatial extent when plotting with `matplotlib.pyplot`.


```python
#Define extent as a tuple:
serc_ext = (xMin, xMax, yMin, yMax)
print('serc_ext:',serc_ext)
print('serc_ext type:',type(serc_ext))
```

    serc_ext: (368000.0, 369000.0, 4306000.0, 4307000.0)
    serc_ext type: <class 'tuple'>
    

## Extract a Single Band from Array

While it is useful to have all the data contained in a hyperspectral cube, it is difficult to visualize all this information at once. We can extract a single band (representing a ~5nm band, approximating a single wavelength) from the cube by using splicing as follows. Note that we have to cast the reflectance data into the type `float`. Recall that since Python indexing starts at 0 instead of 1, in order to extract band 56, we need to use the index 55.


```python
b56 = serc_reflArray[:,:,55].astype(float)
print('b56 type:',type(b56))
print('b56 shape:',b56.shape)
print('Band 56 Reflectance:\n',b56)
```

    b56 type: <class 'numpy.ndarray'>
    b56 shape: (1000, 1000)
    Band 56 Reflectance:
     [[ 628.  647.  768. ...  464.  443.  384.]
     [ 483.  580.  699. ...  424.  476.  466.]
     [ 191.  471.  664. ...  422.  452.  472.]
     ...
     [ 291.  195.  229. ... 1188. 1293. 1178.]
     [ 194.  218.  203. ... 1100. 1235. 1244.]
     [ 164.  192.  216. ... 1106. 1230. 1260.]]
    

Here we can see that we extracted a 2-D array (1000 x 1000) of the scaled reflectance data corresponding to the wavelength band 56. Before we can use the data, we need to clean it up a little. We'll show how to do this below. 

##  Scale factor and No Data Value

This array represents the scaled reflectance for band 56. Recall from exploring the HDF5 data in HDFViewer that NEON AOP reflectance data uses a `Data_Ignore_Value` of `-9999` to represent missing data (often called `NaN`), and a reflectance `Scale_Factor` of `10000.0` in order to save disk space (can use lower precision this way). 

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/HDF5-general/hdfview_SERCrefl.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/HDF5-general/hdfview_SERCrefl.png"></a>
	<figcaption> Screenshot of the NEON HDF5 file format.
	Source: National Ecological Observatory Network
	</figcaption>
</figure>

We can extract and apply the `Data_Ignore_Value` and `Scale_Factor` as follows:


```python
#View and apply scale factor and data ignore value
scaleFactor = serc_reflArray.attrs['Scale_Factor']
noDataValue = serc_reflArray.attrs['Data_Ignore_Value']
print('Scale Factor:',scaleFactor)
print('Data Ignore Value:',noDataValue)

b56[b56==int(noDataValue)]=np.nan
b56 = b56/scaleFactor
print('Cleaned Band 56 Reflectance:\n',b56)
```

    Scale Factor: 10000.0
    Data Ignore Value: -9999
    Cleaned Band 56 Reflectance:
     [[0.0628 0.0647 0.0768 ... 0.0464 0.0443 0.0384]
     [0.0483 0.058  0.0699 ... 0.0424 0.0476 0.0466]
     [0.0191 0.0471 0.0664 ... 0.0422 0.0452 0.0472]
     ...
     [0.0291 0.0195 0.0229 ... 0.1188 0.1293 0.1178]
     [0.0194 0.0218 0.0203 ... 0.11   0.1235 0.1244]
     [0.0164 0.0192 0.0216 ... 0.1106 0.123  0.126 ]]
    

## Plot single reflectance band

Now we can plot this band using the Python package ```matplotlib.pyplot```, which we imported at the beginning of the lesson as ```plt```. Note that the default colormap is jet unless otherwise specified. You can explore using different colormaps on your own; see the <a href="https://matplotlib.org/examples/color/colormaps_reference.html" target="_blank">mapplotlib colormaps</a> for  for other options. 


```python
serc_plot = plt.imshow(b56, extent=serc_ext, cmap='Greys') 
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/intro-hyperspectral/intro-refl-h5/intro-l3-refl-h5_files/intro-l3-refl-h5_57_0.png)
    


We can see that this image looks pretty washed out. To see why this is, it helps to look at the range and distribution of reflectance values that we are plotting. We can do this by making a histogram. 

## Plot histogram

We can plot a histogram using the `matplotlib.pyplot.hist` function. Note that this function won't work if there are any NaN values, so we can ensure we are only plotting the real data values using the call below. You can also specify the # of bins you want to divide the data into. 


```python
plt.hist(b56[~np.isnan(b56)],50); #50 signifies the # of bins
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/intro-hyperspectral/intro-refl-h5/intro-l3-refl-h5_files/intro-l3-refl-h5_60_0.png)
    


We can see that most of the reflectance values are < 0.4. In order to show more contrast in the image, we can adjust the colorlimit (`clim`) to 0-0.4:


```python
serc_plot = plt.imshow(b56, extent=serc_ext, cmap='Greys', clim=(0, 0.2)) 
plt.title('SERC Band 56 Reflectance');
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/intro-hyperspectral/intro-refl-h5/intro-l3-refl-h5_files/intro-l3-refl-h5_62_0.png)
    


## Optional Exercise: Image Processing -- Contrast Stretch & Histogram Equalization 

We can also try out some basic image processing to better visualize the reflectance data using the `scikit-image` package. 

Histogram equalization is a method in image processing of contrast adjustment using the image's histogram. Stretching the histogram can improve the contrast of a displayed image, as we will show how to do below. 

The following code is adapted from scikit-image's tutorial
<a href="http://scikit-image.org/docs/stable/auto_examples/color_exposure/plot_equalize.html#sphx-glr-auto-examples-color-exposure-plot-equalize-py" target="_blank"> Histogram Equalization</a>.

Below we demonstrate how you can create a widget to interactively explore different linear contrast stretches.


```python
from skimage import exposure
from ipywidgets import interact

def linearStretch(percent):
    pLow, pHigh = np.percentile(b56[~np.isnan(b56)], (percent,100-percent))
    img_rescale = exposure.rescale_intensity(b56, in_range=(pLow,pHigh))
    plt.imshow(img_rescale,extent=serc_ext,cmap='gist_earth') 
    #cbar = plt.colorbar(); cbar.set_label('Reflectance')
    plt.title('SERC Band 56 \n Linear ' + str(percent) + '% Contrast Stretch'); 
    ax = plt.gca()
    ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation #
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degree
    
interact(linearStretch,percent=(0,50,1));
```


    interactive(children=(IntSlider(value=25, description='percent', max=50), Output()), _dom_classes=('widget-int…


Here you can see that adjusting the colorlimit displays features (eg. roads, buildings) much better than when we set the colormap limits to the entire range of reflectance values. 

## Recap

In this lesson, you learned to use several of the AOP-focused functions in the `neonutilities` package to find available AOP data, see the spatial extents for the reflectance data product in the year of interest. You then learned how to download a single tile of the bidirectional reflectance data using `nu.by_tile_aop`, explored the contents of the h5 reflectance file, and carried out some basic pre-processing and visualization steps. Great job!
