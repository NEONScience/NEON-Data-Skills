---
syncID: 67a5e95e1b7445aca7d7750b75c0ee98
title: "Plot NEON RGB Camera Imagery in Python"
description: "Introduction to RGB camera images and reading in multi-band images in Python with rasterio."
dateCreated: 2018-06-30
authors: Bridget Hass 
contributors: Donal O'Leary
estimatedTime: 20 minutes
packagesLibraries: gdal, rasterio, matplotlib
topics: data-analysis, data-visualization, spatial-data-gis 
languagesTool: Python
dataProduct: DP3.30010.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/RGB-camera/plot-aop-camera/plot-neon-rgb-camera-data.ipynb
tutorialSeries:
urlTitle: plot-neon-rgb-py
---

This tutorial introduces NEON RGB camera images (<a href="https://data.neonscience.org/data-products/DP3.30010.001" target="_blank">Data Product DP3.30010.001</a>) and uses the Python package `rasterio` to read in and plot the camera data in Python. In this lesson, we will read in an RGB camera tile collected over the NEON Smithsonian Environmental Research Center (<a href="https://www.neonscience.org/field-sites/serc" target="_blank">SERC</a>) site and plot the mutliband image, as well as the individual bands. This lesson was adapted from the <a href="https://rasterio.readthedocs.io/en/stable/topics/plotting.html" target="_blank">rasterio plotting documentation</a>.

<div id="ds-objectives" markdown="1">

### Objectives

After completing this tutorial, you will be able to: 

* Plot a NEON RGB camera geotiff tile in Python using `rasterio`

### Package Requirements
This tutorial was run in Python version 3.9, using the following packages:

* rasterio
* matplotlib

### Download the Data 

Download the NEON
<a href="https://storage.googleapis.com/neon-aop-products/2021/FullSite/D02/2021_SERC_5/L3/Camera/Mosaic/2021_SERC_5_368000_4306000_image.tif">camera (RGB) imagery tile</a>
collected over the Smithsonian Environmental Research Station (SERC) NEON field site in 2021. Move this data to a desired folder on your local workstation. You will need to know the file path to this data.  

You don't have to download from the link above; the tutorial will demonstrate how to download the data directly from Python into your working directory, but we recommend re-organizing in a way that makes sense for you.

### Background

As part of the 
<a href="https://www.neonscience.org/data-collection/airborne-remote-sensing" target="_blank"> NEON Airborne Operation Platform's</a> 
suite of remote sensing instruments, the digital camera producing high-resolution (<= 10 cm) photographs of the earth’s surface. The camera records light energy that has reflected off the ground in the visible portion (red, green and blue) of the electromagnetic spectrum. Often the camera images are used to provide context for the hyperspectral and LiDAR data, but they can also be used for research purposes in their own right. One such example is the tree-crown mapping work by Weinstein et al. - see the links below for more information!

- <a href="https://www.mdpi.com/2072-4292/11/11/1309" target="_blank">Individual Tree-Crown Detection in RGB Imagery Using Semi-Supervised Deep Learning Neural Networks</a>
- <a href="https://elifesciences.org/articles/62922" target="_blank">A remote sensing derived data set of 100 million individual tree crowns for the National Ecological Observatory Network</a>
- <a href="https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13472" target="_blank">DeepForest: A Python package for RGB deep learning tree crown delineation</a>

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/py-figs/plot-neon-rgb-camera-data/tree-crown-paper-fig-2021.jpg">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/py-figs/plot-neon-rgb-camera-data/tree-crown-paper-fig-2021.jpg" alt="Locations of 37 NEON sites included in the NEON crowns data set and examples of tree predictions shown with RGB imagery for six sites. (Weinstein et al 2021)"></a>
</figure>

**Reference:** Ben G Weinstein, Sergio Marconi, Stephanie A Bohlman, Alina Zare, Aditya Singh, Sarah J Graves, Ethan P White (2021) A remote sensing derived data set of 100 million individual tree crowns for the National Ecological Observatory Network eLife 10:e62922. https://doi.org/10.7554/eLife.62922

In this lesson we will keep it simple and show how to read in and plot a single camera file (1km x 1km ortho-mosaicked tile) - a first step in any research incorporating the AOP camera data (in Python).

</div>

### Import required packages
First let's import the packages that we'll be using in this lesson.


```python
import os
import requests
import rasterio as rio
from rasterio.plot import show, show_hist
import matplotlib.pyplot as plt
```

Next, let's download a camera file. For this tutorial, we will use the `requests` package to download a raster file from the public link where the data is stored. For simplicity, we will show how to download to a data folder in the working directory. You can move the data to a different folder, but if you do that, be sure to update the path to your data accordingly. 


```python
def download_url(url,download_dir):
    if not os.path.isdir(download_dir):
        os.makedirs(download_dir)
    filename = url.split('/')[-1]
    r = requests.get(url, allow_redirects=True)
    file_object = open(os.path.join(download_dir,filename),'wb')
    file_object.write(r.content)
```


```python
# public url where the RGB camera tile is stored
rgb_url = "https://storage.googleapis.com/neon-aop-products/2021/FullSite/D02/2021_SERC_5/L3/Camera/Mosaic/2021_SERC_5_368000_4306000_image.tif"

# download the camera tile to a ./data subfolder in your working directory
download_url(rgb_url,'.\data')

# display the contents in the ./data folder to confirm the download completed
os.listdir('./data')
```

## Open the Camera RGB data with `rasterio`

We can open and read this RGB data that we downloaded in Python using the ```rasterio.open``` function:


```python
# read the RGB file (including the full path) to the variable rgb_dataset
rgb_name = rgb_url.split('/')[-1]
rgb_file = os.path.join(".\data",rgb_name)
rgb_dataset = rio.open(rgb_file)
```

Let's look at a few properties of this dataset to get a sense of the information stored in the rasterio object:


```python
print('rgb_dataset:\n',rgb_dataset)
print('\nshape:\n',rgb_dataset.shape)
print('\nspatial extent:\n',rgb_dataset.bounds)
print('\ncoordinate information (crs):\n',rgb_dataset.crs)
```

Unlike the other AOP data products, camera imagery is generated at 10cm resolution, so each 1km x 1km tile will contain 10000 pixels (other 1m resolution data products will have 1000 x 1000 pixels per tile, where each pixel represents 1 meter).

## Plot the RGB multiband image

We can use rasterio's built-in functions `show` to plot the CHM tile.


```python
show(rgb_dataset);
```

![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/RGB-camera/plot-aop-camera/plot-neon-rgb-camera-data_files/plot-neon-rgb-camera-data_13_0.png)

## Plot each band of the RGB image 

We can also plot each band (red, green, and blue) individually as follows:


```python
fig, (axr, axg, axb) = plt.subplots(1,3, figsize=(21,7))
show((rgb_dataset, 1), ax=axr, cmap='Reds', title='red channel')
show((rgb_dataset, 2), ax=axg, cmap='Greens', title='green channel')
show((rgb_dataset, 3), ax=axb, cmap='Blues', title='blue channel')
plt.show()
```

![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/RGB-camera/plot-aop-camera/plot-neon-rgb-camera-data_files/plot-neon-rgb-camera-data_15_0.png)

That's all for this example! Most of the other AOP raster data are all single band images, but `rasterio` is a handy Python package for working with any geotiff files. You can download and visualize the lidar and spectrometer derived raster images similarly.
