---
syncID: 52f863b138b14d79a97e91422fc17b4f
title: "Merging GeoTIFF Files to Create a Mosaic"
description: "Learn to merge multiple GeoTIFF files to great a larger area of interest." 
dateCreated: 2018-07-05 
authors: Bridget Hass, Donal O'Leary
contributors: 
estimatedTime: 30 minutes
packagesLibraries: subprocess, gdal, osgeo, glob, numpy, matplotlib
topics: lidar, data-analysis, remote-sensing
languagesTool: python
dataProduct: NEON.DP3.30015, NEON.DP3.30024, NEON.DP3.30025
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/intro-lidar/merge_lidar_geotiff_files_py/merge_lidar_geotiff_files_py.py
tutorialSeries: intro-lidar-py-series
urlTitle: merge-lidar-geotiff-py
---

In your analysis you will likely want to work with an area larger than a single file, from a few tiles to an entire NEON field site. In this tutorial, we will demonstrate how to use the `gdal_merge` utility to mosaic multiple tiles together. You will need to install GDAL and the GDAL-python bindings on your machine in order to use the code below.

<div id="ds-objectives" markdown="1">

### Objectives
After completing this tutorial, you will be able to:

* Merge multiple geotif raster tiles into a single mosaicked raster
* Use the functions `raster2array` to read a tif raster into a Python array

### Install Python Packages

* **subprocess**
* **glob**
* **gdal**
* **osgeo** 
* **matplotlib** 
* **numpy**


### Download Data

<h3> NEON Teaching Data Subset: Data Institute 2018</h3> 

To complete these materials, you will use data available from the NEON 2018 Data
Institute teaching datasets available for download. 

The LiDAR and imagery data used to create this raster teaching data subset 
were collected over the 
<a href="http://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="http://www.neonscience.org/science-design/field-sites/" target="_blank" >field sites</a>
and processed at NEON headquarters.
All NEON data products can be accessed on the 
<a href="http://data.neonscience.org" target="_blank"> NEON data portal</a>.

<a href="https://ndownloader.figshare.com/files/27535799" target="_blank"class="link--button link--arrow">
Download the TEAK Aspect Tiles from FigShare</a>
</div>

In your analysis you will likely want to work with an area larger than a single file, from a few tiles to an entire NEON field site. In this tutorial, we will demonstrate how to use the `gdal_merge` utility to mosaic multiple tiles together. 

This can be done in command line, or as a system command through `Python` as shown in this lesson. **If you installed `Python` using `Anaconda`, you should have `gdal_merge.py` downloaded into your folder, in a path similar to `C:\Users\user\AppData\Local\Continuum\Anaconda3\Scripts`. You can also download it here and save it to your working directory.** For details on `gdal_merge` refer to the <a href="http://www.gdal.org/gdal_merge.html" target="_blank">gdal website</a>.

We'll start by importing the following packages:



```python
import numpy as np
import matplotlib.pyplot as plt
import os, glob
from osgeo import gdal
```

Make a list of files to mosaic using `glob.glob`, and print the result. In this example, we are selecting all files ending with `_aspect.tif` in the folder `TEAK_Aspect_Tiles`. Note that you will need to change this filepath according to your local machine.


```python
files_to_mosaic = glob.glob('/Users/olearyd/Git/data/TEAK_Aspect_Tiles/*_aspect.tif')
files_to_mosaic
```




    ['/Users/olearyd/Git/data/TEAK_Aspect_Tiles/NEON_D17_TEAK_DP3_321000_4100000_aspect.tif',
     '/Users/olearyd/Git/data/TEAK_Aspect_Tiles/NEON_D17_TEAK_DP3_320000_4101000_aspect.tif',
     '/Users/olearyd/Git/data/TEAK_Aspect_Tiles/NEON_D17_TEAK_DP3_320000_4100000_aspect.tif',
     '/Users/olearyd/Git/data/TEAK_Aspect_Tiles/NEON_D17_TEAK_DP3_321000_4101000_aspect.tif']



In order to run the `gdal_merge` function, we need these files as a series of strings. We can get them in the correct format using `join`:


```python
files_string = " ".join(files_to_mosaic)
print(files_string)
```

    /Users/olearyd/Git/data/TEAK_Aspect_Tiles/NEON_D17_TEAK_DP3_321000_4100000_aspect.tif /Users/olearyd/Git/data/TEAK_Aspect_Tiles/NEON_D17_TEAK_DP3_320000_4101000_aspect.tif /Users/olearyd/Git/data/TEAK_Aspect_Tiles/NEON_D17_TEAK_DP3_320000_4100000_aspect.tif /Users/olearyd/Git/data/TEAK_Aspect_Tiles/NEON_D17_TEAK_DP3_321000_4101000_aspect.tif


Now that we have the list of files we want to mosaic, we can run a system command to combine them into one raster.


```python
command = "gdal_merge.py -o /Users/olearyd/Git/data/TEAK_Aspect_Tiles/TEAK_Aspect_Mosaic.tif -of gtiff " + files_string
print(os.popen(command).read())
```

    0...10...20...30...40...50...60...70...80...90...100 - done.
    



```python
print(os.popen('ls /Users/olearyd/Git/data/TEAK_Aspect_Tiles/').read())
```

    NEON_D17_TEAK_DP3_320000_4100000_aspect.tif
    NEON_D17_TEAK_DP3_320000_4101000_aspect.tif
    NEON_D17_TEAK_DP3_321000_4100000_aspect.tif
    NEON_D17_TEAK_DP3_321000_4101000_aspect.tif
    TEAK_Aspect_Mosaic.tif
    


Great! It looks like GDAL merged the files together into the `TEAK_Aspect_Mosaic.tif` file. Worth pointing out here is that `gdal_merge` function has a LOT of options and is extremely powerful and flexible. We suggest that you <a href="https://gdal.org/programs/gdal_merge.html" target="_blank">read the GDAL function documentation here</a> and experiement with your own commands. This may be easier to practice first in the command line, but integrating python scripts and command line functions here (as when using the `os.system()` function) is incredibly useful for processing large datasets.

Now we can define and then use the function `raster2array` to read in the mosaiced array. This function converts the geotif file into an array, and also stores relevant metadata (eg. spatial information) into the dicitonary `metadata`. Load or import this function into your cell with `%load raster2array`. Note that this function requires the imported packages at the beginning of this notebook in order to run. 


```python
def raster2array(geotif_file):
    metadata = {}
    dataset = gdal.Open(geotif_file)
    metadata['array_rows'] = dataset.RasterYSize
    metadata['array_cols'] = dataset.RasterXSize
    metadata['bands'] = dataset.RasterCount
    metadata['driver'] = dataset.GetDriver().LongName
    metadata['projection'] = dataset.GetProjection()
    metadata['geotransform'] = dataset.GetGeoTransform()
    
    mapinfo = dataset.GetGeoTransform()
    metadata['pixelWidth'] = mapinfo[1]
    metadata['pixelHeight'] = mapinfo[5]

    xMin = mapinfo[0]
    xMax = mapinfo[0] + dataset.RasterXSize/mapinfo[1]
    yMin = mapinfo[3] + dataset.RasterYSize/mapinfo[5]
    yMax = mapinfo[3]
    
    metadata['extent'] = (xMin,xMax,yMin,yMax)
    
    raster = dataset.GetRasterBand(1)
    array_shape = raster.ReadAsArray(0,0,metadata['array_cols'],metadata['array_rows']).astype(np.float).shape
    metadata['noDataValue'] = raster.GetNoDataValue()
    metadata['scaleFactor'] = raster.GetScale()
    
    array = np.zeros((array_shape[0],array_shape[1],dataset.RasterCount),'uint8') #pre-allocate stackedArray matrix
    
    if metadata['bands'] == 1:
        raster = dataset.GetRasterBand(1)
        metadata['noDataValue'] = raster.GetNoDataValue()
        metadata['scaleFactor'] = raster.GetScale()
              
        array = dataset.GetRasterBand(1).ReadAsArray(0,0,metadata['array_cols'],metadata['array_rows']).astype(np.float)
        #array[np.where(array==metadata['noDataValue'])]=np.nan
        array = array/metadata['scaleFactor']
    
    elif metadata['bands'] > 1:    
        for i in range(1, dataset.RasterCount+1):
            band = dataset.GetRasterBand(i).ReadAsArray(0,0,metadata['array_cols'],metadata['array_rows']).astype(np.float)
            #band[np.where(band==metadata['noDataValue'])]=np.nan
            band = band/metadata['scaleFactor']
            array[...,i-1] = band

    return array, metadata
```

We can call this function as follows:


```python
TEAK_aspect_array, TEAK_aspect_metadata = raster2array('/Users/olearyd/Git/Data/TEAK_Aspect_Tiles/TEAK_Aspect_Mosaic.tif')
```

Look at the size of the mosaicked tile using `.shape`. Since we created a mosaic of four 1000m x 1000m tiles, we expect the new tile to be 2000m x 2000m


```python
TEAK_aspect_array.shape
```




    (2000, 2000)



Let's take a look at the contents of the metadata dictionary:


```python
#print metadata in alphabetical order
for item in sorted(TEAK_aspect_metadata):
    print(item + ':', TEAK_aspect_metadata[item])
```

    array_cols: 2000
    array_rows: 2000
    bands: 1
    driver: GeoTIFF
    extent: (320000.0, 322000.0, 4100000.0, 4102000.0)
    geotransform: (320000.0, 1.0, 0.0, 4102000.0, 0.0, -1.0)
    noDataValue: None
    pixelHeight: -1.0
    pixelWidth: 1.0
    projection: PROJCS["WGS 84 / UTM zone 11N",GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-117],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1,AUTHORITY["EPSG","9001"]],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","32611"]]
    scaleFactor: 1.0


Load the function `plot_array` to plot the array:


```python
def plot_array(array,spatial_extent,colorlimit,ax=plt.gca(),title='',cmap_title='',colormap=''):
    plot = plt.imshow(array,extent=spatial_extent,clim=colorlimit); 
    cbar = plt.colorbar(plot,aspect=40); plt.set_cmap(colormap); 
    cbar.set_label(cmap_title,rotation=90,labelpad=20);
    plt.title(title); ax = plt.gca(); 
    ax.ticklabel_format(useOffset=False, style='plain'); 
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90); 
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/intro-lidar/merge_lidar_geotiff_files_py/merge_lidar_geotiff_files_py_files/merge_lidar_geotiff_files_py_20_0.png)


Finally, let's take a look at a plot of the tile mosaic:


```python
plot_array(TEAK_aspect_array,
           TEAK_aspect_metadata['extent'],
           (0,360),
           title='TEAK Aspect',
           cmap_title='Aspect, degrees',
           colormap='jet')
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/intro-lidar/merge_lidar_geotiff_files_py/merge_lidar_geotiff_files_py_files/merge_lidar_geotiff_files_py_22_0.png)


### Challenges

1. Use the function `raster2array` to read in and plot each tile separately. Confirm that the mosaicked raster looks reasonable. 
2. Download 9 adjacent tiles of another LiDAR L3 data product of your choice and use gdal_merge to combine them. You can find NEON data on the <a href="http://data.neonscience.org/home" target="_blank">NEON Data Portal</a> or NEON's Citrix FileShare system. 
