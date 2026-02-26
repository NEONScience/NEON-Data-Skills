---
syncID: 
title: "Introduction to the Canopy Nitrogen Data Product"
description: "Introduce the Canopy Nitrogen data product, explain the various data files and show how to mask non-valid pixels." 
dateCreated: 2025-02-25 
authors: Bridget Hass
contributors: Shashi Konduri
estimatedTime: 30 minutes
packagesLibraries: neonutilities, gdal, rasterio
topics: remote-sensing, hyperspectral, nitrogen, foliar traits
languagesTool: Python
dataProduct: DP3.30018.002
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/canopy-nitrogen/intro_canopy_nitrogen.ipynb
tutorialSeries: 
urlTitle: intro-canopy-nitrogen
---

Canopy Nitrogen (Normalized Difference Nitrogen Index (NDNI)) was one of NEON's original data products, however the first algorithm used (a simple index) was deemed to provide data of insufficient quality for the sensor, scale and site conditions associated with NEON AOP collections. See the <a href="https://www.neonscience.org/impact/observatory-blog/upcoming-changes-aop-data-product-catalog" target=_blank>November 17, 2020 Data Notification</a> for more details. Over the past years, AOP has been working on implementing an improved algorithm that produces higher quality results. In February 2025, NEON published a new Canopy Nitrogen (%N) data product (<a href="https://data.neonscience.org/data-products/DP3.30018.002" target=_blank>DP3.30018.002</a>) for a subset of sites, using models derived from NEON's hyperspectral and foliar chemistry data. We are seeking feedback from the community to review this data product before the model is applied to all of NEON's terrestrial sites. For more details on the data product, refer to the Quick Start Guide on the Data Portal page.

In this tutorial, we demonstrate how to download a single tile of the Canopy Nitrogen Data Product over Harvard Forest, and explain the four raster tiles that are associated with this data product. We then show how to use the valid pixel mask to mask out invalid data. 

<div id="ds-objectives" markdown="1">

## Objectives
After completing this tutorial, you will be able to:

- Download the Canopy Nitrogen Data Product
- Understand the 4 files that comprise the Canopy Nitrogen data product
- Mask the Nitrogen data to include only valid pixels

## Install Python Packages
- neonutilities
- rasterio


</div>

Let's get started! First import the required Python packages, `neonutilities` and `rasterio`, as well as some other standard packages.


```python
import neonutilities as nu
import numpy as np
import rasterio
from rasterio.plot import show
import matplotlib.pyplot as plt
import os
```

First let's see what data are available. As of Feb 2026, only a subset of sites have been published, as NEON is seeking input from the user community before producing this model for all NEON terrrestrial sites.


```python
nu.list_available_dates(dpid="DP3.30018.002",
                        site="HARV")
```

    PROVISIONAL Available Dates: 2019-08
    

So far, there is data avaiable for HARV in 2019. All of the Canopy Nitrogen data is currently available provisionally.

Let's first set the download directory (where we will download data) to be in the `Downloads` folder.


```python
download_dir = os.path.expanduser("~\\Downloads")
```

Now we can use `by_tile_aop` to download a single tile for HARV in 2019. We are choosing a tile that includes both forest and part of a lake (the Quabbin Reservoir). 


```python
nu.by_tile_aop(dpid="DP3.30018.002", # download the Canopy Nitrogen Product
               site="HARV", 
               year=2019,
               easting=723000, # UTM easting
               northing=4708000, # UTM northing
               include_provisional=True, # include provisional data
               savepath=download_dir)
```

    Provisional NEON data are included. To exclude provisional data, use input parameter include_provisional=False.
    

    Continuing will download 5 NEON data files totaling approximately 15.7 MB. Do you want to proceed? (y/n)  y
    

    Downloading 5 NEON data files totaling approximately 15.7 MB
    
    100%|████████████████████████████████████████████████████████████████████████████████████| 5/5 [00:08<00:00,  1.79s/it]
    

Display the data files that we've downloaded, looking in the download directory. Data is stored in nested paths under the data product id (`DP3.30018.002`).


```python
nitrogen_dir = os.path.join(download_dir,'DP3.30018.002')
for root, dirs, files in os.walk(nitrogen_dir):
    for file in files:
        print(os.path.join(root.replace(download_dir,'..'),file))
```

    ..\DP3.30018.002\citation_DP3.30018.002_PROVISIONAL.txt
    ..\DP3.30018.002\issueLog_DP3.30018.002.csv
    ..\DP3.30018.002\neon-aop-provisional-products\2019\FullSite\D01\2019_HARV_6\L3\Spectrometer\Nitrogen\NEON_D01_HARV_DP3_723000_4708000_nitrogen.tif
    ..\DP3.30018.002\neon-aop-provisional-products\2019\FullSite\D01\2019_HARV_6\L3\Spectrometer\Nitrogen\NEON_D01_HARV_DP3_723000_4708000_nitrogen_classification.tif
    ..\DP3.30018.002\neon-aop-provisional-products\2019\FullSite\D01\2019_HARV_6\L3\Spectrometer\Nitrogen\NEON_D01_HARV_DP3_723000_4708000_nitrogen_uncertainty.tif
    ..\DP3.30018.002\neon-aop-provisional-products\2019\FullSite\D01\2019_HARV_6\L3\Spectrometer\Nitrogen\NEON_D01_HARV_DP3_723000_4708000_nitrogen_valid.tif
    ..\DP3.30018.002\neon-publication\NEON.DOM.SITE.DP3.30018.002\HARV\20190801T000000--20190901T000000\basic\NEON..HARV.DP3.30018.002.readme.20260210T033154Z.txt
    

The download includes a `citation` file, `issueLog` file, `readme` file, and four geotiff (.tif) files. We encourage you to look through the text files on your own, and please cite NEON data! We will now explore each of the the geotiff files. We can use the `rasterio` package to read in and display these files.

The four raster files that make up the canopy nitrogen data product are explained briefly below:
1) `_nitrogen.tif`: mosaicked %N map covering all tiles within each site is available. 
2) `_nitrogen_uncertainty.tif`: %N uncertainty map - uncertainty associated with the %N predictions. It is calculated by taking the standard deviation of the %N predictions from each decision tree in the random forest model for each 1 m pixel within the tile.
3) `_nitrogen_classification.tif`: Classification result for needle vs non-needle model, which is a binary map generated using SVM classification, where needle types are coded as 0 and non-needle types as 1. The "non-needle" class includes all vegetation types that are not needle leaf, such as broadleaf trees, shrubs, herbaceous cover, and others. Separate random forest regression models have been developed to predict foliar nitrogen values for needle and non-needle vegetation types.
4) `_nitrogen_valid.tif`: Valid pixel mask based on NDVI threshold of 0.2, where values less than 0.2 are set to 0 ("non-valid"). This mask is intended to enable exclusion of non-vegetated areas, such as roads, water bodies, built-up areas, bare rock, and so forth.

The code chunk below shows how to read the four files into variables, which we can then plot.


```python
# read each of the files into the four variables
for root, dirs, files in os.walk(nitrogen_dir):
    for file in files:
        if file.endswith('nitrogen.tif'):  
            nitrogen = os.path.join(root,file)
        if file.endswith('nitrogen_uncertainty.tif'):  
            nitrogen_uncertainty = os.path.join(root,file)
        if file.endswith('nitrogen_classification.tif'):  
            needle_classification = os.path.join(root,file)
        if file.endswith('nitrogen_valid.tif'):  
            validity_classification = os.path.join(root,file)
```

Make a function to display the rasters.


```python
# Function to open a raster and plot, including a colorbar and some additional formatting options
def plot_neon_raster(raster_file, title, colormap='viridis'):
    with rasterio.open(raster_file) as src:
        fig, ax = plt.subplots(1, 1)
        plot = show(src, ax=ax, cmap=colormap)
        im = plot.get_images()[0]
        fig.colorbar(im, ax=ax)
    
        # Disable scientific notation on the y-axis
        ax.ticklabel_format(axis='y', style='plain')
    
        plt.title(title)
        plt.xlabel("UTM x")
        plt.ylabel("UTM y")
        plt.show()
```


```python
plot_neon_raster(nitrogen, 'Canopy Nitrogen (%)');
```

    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/canopy_nitrogen/intro_canopy_nitrogen_files/intro_canopy_nitrogen_16_1.png)

C:\Users\bhass\Documents\GitHubRepos\NEON-Data-Skills\tutorials\Python\AOP\Hyperspectral\canopy_nitrogen

```python
plot_neon_raster(nitrogen_uncertainty, 'Canopy Nitrogen Uncertainty (%)', 'jet');
```
   


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/canopy_nitrogen/intro_canopy_nitrogen_files/intro_canopy_nitrogen_17_1.png)    


Note that you can see a vertical line through the middle of the image. This is because the model was created using the surface directional reflectance, and there are some artifacts that show up on the edges of flightlines. In the future, the model will be trained on the bidirectional reflectance (BRDF and topographic corrected) so these artifacts should not appear, or be as prominent.

Next we'll look at the needle / non-needle classification map:


```python
# create a binary color map to display the 2 classes
import matplotlib.colors as mcolors
colors = ['#ff4d4d', '#4dff4d'] 
cmap_binary = mcolors.ListedColormap(colors)
plot_neon_raster(needle_classification, 'Needle / Non-Needle Classification', cmap_binary);
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/canopy_nitrogen/intro_canopy_nitrogen_files/intro_canopy_nitrogen_19_1.png)    
    


It looks like the forest is a mix of needle and non-needle, which makes sense - there are a lot of deciduous trees in the Northeast, and there also may be fields and other vegetation types! There are also classifications in the lake, which don't really make sense. That brings us to the last raster, the validity classification. You can plot that as follows:


```python
plot_neon_raster(validity_classification, 'Valid Pixels', cmap_binary);
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/canopy_nitrogen/intro_canopy_nitrogen_files/intro_canopy_nitrogen_21_1.png)    


We can see that the water body (Quabbin Reservoir) is not valid (values are 0). This makes sense - canopy nitrogen does not make sense over water bodies! You may wish to create your own mask, as this just relies on a simple NDVI threshold (anything with NDVI < 0.2 is set to zero). You can use the NEON NDVI data product (Vegetation Indices - DP3.30026.001), or other indices, or the surface reflectance data directly. We can also see that the areas of higher uncertainty are areas that should not be used anyway.

Finally, we can use this valid pixel mask to mask out data in the original Canopy Nitrogen mask.


```python
# Read both rasters (nitrogen and valid pixel map)
with rasterio.open(nitrogen) as src_nitrogen:
    nitrogen_data = src_nitrogen.read(1).astype(float)
    nitrogen_profile = src_nitrogen.profile
    nitrogen_transform = src_nitrogen.transform

with rasterio.open(validity_classification) as src_valid:
    valid_data = src_valid.read(1)

# Mask in one line: set to NaN where validity is 0
nitrogen_masked = np.where(valid_data == 0, np.nan, nitrogen_data)
```



```python
# Get extent from the raster transform
left, bottom, right, top = rasterio.transform.array_bounds(
    nitrogen_profile['height'], nitrogen_profile['width'], nitrogen_transform)

# plot the masked raster
plt.figure(figsize=(8, 6))
plt.imshow(nitrogen_masked, cmap='viridis', extent=[left, right, bottom, top])
plt.colorbar(label='Canopy Nitrogen (%)')
plt.title('Masked Canopy Nitrogen (%)')
plt.xlabel('UTM Easting (m)')
plt.ylabel('UTM Northing (m)')
plt.ticklabel_format(axis='y', style='plain')
plt.show()
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/canopy_nitrogen/intro_canopy_nitrogen_files/intro_canopy_nitrogen_24_0.png)    
    


There are some pixels in the lake that were not masked out - these are pixels where the NDVI was > 0.2. You can also see there is a diagonal (NW-SE) strip running across the NE corner of the plot - this could be a clear-cut for powerline or a road. We highly encourage you to look at other imagery, such as the NEON RGB Camera Imagery (DP3.30010.001) or the Reflectance RGB Imagery (DP3.30006.001, DP3.30006.002), or even external imagery sources such as Google Earth, or satellite derived land cover classifications to provide more contextual information, and to understand where the nitrogen map makes sense to use. You may also wish to create your own valid pixel mask, but the one provided is intended to give a general sense of where the data can meaningfully be applied.

## Recap

In this lesson, you've explored the four raster files in the canopy nitrogen data product and learned how to mask using the NDVI threshold valid pixel layer, as well as some caveats to using this validity. It is important to pull in additional data sources and to perform your own analysis and QAQC when working with any NEON data. This lesson is just intended to show the first step in working with this raster data, but we hope you explore more on your own!
