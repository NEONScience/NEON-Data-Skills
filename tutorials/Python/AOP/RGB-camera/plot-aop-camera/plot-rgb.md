---
syncID: 67a5e95e1b7445aca7d7750b75c0ee98
title: "Plot NEON RGB Camera Imagery in Python"
description: "Introduction to RGB camera images and reading in multi-band images in Python with rasterio."
dateCreated: 2018-06-30
authors: Bridget Hass 
contributors: Donal O'Leary
estimatedTime: 15 minutes
packagesLibraries: gdal, rasterio, matplotlib
topics: data-analysis, data-visualization, spatial-data-gis 
languagesTool: Python
dataProduct: DP3.30010.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/RGB-camera/intro-rgb-camera/plot-neon-rgb-camera-data/plot-neon-rgb-camera-data.ipynb
tutorialSeries:
urlTitle: plot-neon-rgb-py
---

This tutorial introduces NEON's Level 3 (mosaicked) RGB camera images, Data Product (<a href="https://data.neonscience.org/data-products/DP3.30010.001" target="_blank">DP3.30010.001</a>) and uses the Python package `rasterio` to read in and plot the camera data in Python. In this lesson, we will read in an RGB camera tile collected over the NEON Smithsonian Environmental Research Center (<a href="https://www.neonscience.org/field-sites/serc" target="_blank">SERC</a>) site and plot the mutliband image, as well as the individual bands. This lesson was adapted from the <a href="https://rasterio.readthedocs.io/en/stable/topics/plotting.html" target="_blank">rasterio plotting documentation</a>.

<div id="ds-objectives" markdown="1">

### Learning Objectives

After completing this tutorial, you will be able to: 

* Have an idea of some research applications using airborne camera imagery
* Plot a NEON RGB camera geotiff tile in Python using `rasterio`

### Things You’ll Need To Complete This Tutorial

To complete this tutorial, you will need: 
* Python version 3.9 or higher
* Create a <a href="https://www.neonscience.org/about/user-accounts" target="_blank">NEON user account</a>
* Generate an <a href="https://www.neonscience.org/resources/learning-hub/tutorials/api-token-setup" target="_blank">API token</a> for downloading data

#### Install Python Packages

* rasterio
* matplotlib
* neonutilities
* python-dotenv

#### Data 

For this lesson, we will work with L3 RGB Camera data collected at NEON's <a href="https://www.neonscience.org/field-sites/serc" target="_blank">Smithsonian Environmental Research Center (SERC)</a> site. This data is downloaded in the first part of the tutorial, using the Python `neonutilities` package.

</div>

## Background

As part of the 
<a href="https://www.neonscience.org/data-collection/airborne-remote-sensing" target="_blank"> NEON Airborne Operation Platform's</a> 
suite of remote sensing instruments, the <a href="https://www.neonscience.org/data-collection/camera" target="_blank">digital camera</a> produces high-resolution (<= 10 cm) photographs of the earth’s surface. The camera records light energy that has reflected off the ground in the visible portion (red, green and blue) of the electromagnetic spectrum. Often the camera images are used to provide context for the hyperspectral and LiDAR data, but they can also be used for research purposes in their own right. One such example is the tree-crown mapping work by Weinstein et al. - see the links below for more information!

- <a href="https://www.mdpi.com/2072-4292/11/11/1309" target="_blank">Individual Tree-Crown Detection in RGB Imagery Using Semi-Supervised Deep Learning Neural Networks</a>
- <a href="https://elifesciences.org/articles/62922" target="_blank">A remote sensing derived data set of 100 million individual tree crowns for the National Ecological Observatory Network</a>
- <a href="https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13472" target="_blank">DeepForest: A Python package for RGB deep learning tree crown delineation</a>

For more interactive notebooks showing examples of working with airborne camera imagery, including with the DeepForest package (and other environmental applications), check out:
- <a href="https://edsbook.org/about" target="_blank">Environmental Data Science (EDS) Book</a> and the <a href="https://edsbook.org/gallery" target="_blank">EDS Notebook Gallery</a>


In this lesson we will keep it simple and show how to read in and plot a single camera file (1km x 1km ortho-mosaicked tile) - a first step in any research incorporating the AOP camera data (in Python).

**Tip:** To run a code chunk (cell) in Jupyter Notebook you can either select `Cell > Run Cells` with your cursor placed in the cell you want to run, or use the shortcut key `Shift + Enter`. For more handy shortcuts, refer to the tab `Help > Keyboard Shortcuts`. 

### Import required packages
First let's import the packages that we'll be using in this lesson.


```python
import os
import dotenv
import neonutilities as nu
import rasterio as rio
from rasterio.plot import show, show_hist
import matplotlib.pyplot as plt
```

Next, let's download a single camera file (1 km x 1 km tile).

As of June 2026, NEON requires an API token for data downloads, to reduce bot scraping and improve user support. Tokens can be generated in NEON data portal user accounts - log in to your account or create one, and go to the API Tokens section. For best practices in storing and using tokens, follow the instructions <a href="https://www.neonscience.org/resources/learning-hub/tutorials/api-token-setup" target="_blank">here</a>. Once you've set up your token as an environment variable, you can load it using  the `python-dotenv` package as follows, optionally specifying the path to the `.env` file in `load_dotenv()`.


```python
dotenv.load_dotenv()
token = os.environ.get("NEON_TOKEN")
```


```python
# download the RGB Camera data to the C:/data directory - change this if desired
nu.by_tile_aop(dpid='DP3.30010.001',
               site='SERC',
               year=2021,
               easting=368000,
               northing=4306000,
               token=token,
               savepath=r'C:\data')
```

    Provisional NEON data are not included. To download provisional data, use input parameter include_provisional=True.
    

    Continuing will download 2 NEON data files totaling approximately 68.8 MB. Do you want to proceed? (y/n)  y
    

    Downloading 2 NEON data files totaling approximately 68.8 MB
    
    100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 2/2 [00:01<00:00,  1.05it/s]
    

Display the RGB tile that you've downloaded:


```python
rgb_dir = os.path.expanduser(r"C:\data\DP3.30010.001")

for root, dirs, files in os.walk(rgb_dir):
    for file in files:
        if file.endswith('.tif'):
            rgb_file = os.path.join(root, file)
            print(rgb_file)
```

    C:\data\DP3.30010.001\neon-aop-products\2021\FullSite\D02\2021_SERC_5\L3\Camera\Mosaic\2021_SERC_5_368000_4306000_image.tif
    

## Open the Camera RGB data with `rasterio`

We can open and read this RGB data that we downloaded in Python using the ```rasterio.open``` function:


```python
# read the RGB file (including the full path) to the variable rgb_dataset
rgb_dataset = rio.open(rgb_file)
```



Let's look at a few properties of this dataset to get a sense of the information stored in the rasterio object:


```python
print('rgb_dataset:\n',rgb_dataset)
print('\nshape:\n',rgb_dataset.shape)
print('\nspatial extent:\n',rgb_dataset.bounds)
print('\ncoordinate information (crs):\n',rgb_dataset.crs)
```

    rgb_dataset:
     <open DatasetReader name='C:\data\DP3.30010.001\neon-aop-products\2021\FullSite\D02\2021_SERC_5\L3\Camera\Mosaic\2021_SERC_5_368000_4306000_image.tif' mode='r'>
    
    shape:
     (10000, 10000)
    
    spatial extent:
     BoundingBox(left=368000.0, bottom=4306000.0, right=369000.0, top=4307000.0)
    
    coordinate information (crs):
     PROJCS["WGS 84 / UTM zone 18N",GEOGCS["WGS 84",DATUM["World Geodetic System 1984",SPHEROID["WGS 84",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-75],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1,AUTHORITY["EPSG","9001"]],AXIS["Easting",EAST],AXIS["Northing",NORTH]]
    

Unlike the other AOP data products, camera imagery is generated at 10cm resolution, so each 1km x 1km tile will contain 10000 pixels (other 1m resolution data products will have 1000 x 1000 pixels per tile, where each pixel represents 1 meter).

## Plot the RGB multiband image

We can use rasterio's built-in functions `show` to plot the CHM tile.


```python
show(rgb_dataset);
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/RGB-camera/plot-aop-camera/plot-rgb_files/output_15_0.png)
    


## Plot each band of the RGB image 

We can also plot each band (red, green, and blue) individually as follows:


```python
fig, (axr, axg, axb) = plt.subplots(1,3, figsize=(21,7))
show((rgb_dataset, 1), ax=axr, cmap='Reds', title='red channel')
show((rgb_dataset, 2), ax=axg, cmap='Greens', title='green channel')
show((rgb_dataset, 3), ax=axb, cmap='Blues', title='blue channel')
plt.show()
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/RGB-camera/plot-aop-camera/plot-rgb_files/output_17_0.png)
    


That's all for this example! Most of the other AOP raster data are all single band images so you can't make a 3-band composite like for the camera. You can make RGB composites using different bands of the hyperspectral data. In summary, `rasterio` is a handy Python package for working with any geotiff files. You can download and visualize the lidar and spectrometer derived raster images similarly.
