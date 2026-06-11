---
syncID: 9bf062c33697432790b63db187cbc565
title: "Introduction to NEON Discrete Lidar Data in Python"
description: "Programmatically download lidar data and metadata and explore discrete lidar point clouds and rasters in Python"
dateCreated: 2022-09-24
authors: Bridget Hass
contributors: 
estimatedTime: 45 minutes - 1 hour
packagesLibraries: requests, json, gdal, geopandas, laspy, lasrs
topics:
languagesTool: python
dataProduct: DP3.10003.001, 
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/intro-lidar/intro_point_clouds_py/intro_discrete_point_clouds.py
tutorialSeries: 
urlTitle: neon-discrete-point-clouds
---

<div id="ds-objectives" markdown="1">

### Objectives
After completing this tutorial, you will be able to:

* Use Python functions to programmatically download NEON AOP data from the API
* Download and plot shapefiles and kmls (included as lidar metadata) to visualize coverage for a given year
* Explore and plot the AOP discrete lidar point cloud contents in Python using the `laspy` package
* Read in and plot the AOP L3 raster data products (CHM, DTM, DSM) in Python using the `rasterio` package 

### Things You’ll Need To Complete This Tutorial

To complete this tutorial, you will need: 
* Python version 3.9 or higher
* Create a <a href="https://www.neonscience.org/about/user-accounts" target="_blank">NEON user account</a>
* Generate an <a href="https://www.neonscience.org/resources/learning-hub/tutorials/api-token-setup" target="_blank">API token</a> for downloading data

* **Install required Python packages**

    * requests
    * gdal
    * fiona
    * geopandas
    * rasterio
    * laspy
    * lazrs
    * neonutilities
    * python-dotenv

### Additional Resources

If you are interested in learning more about the neonutilities package or the NEON API, or want a deeper dive in how this works with the Python `requests` package, please refer to the tutorial and webpages linked below.
* <a href="https://www.neonscience.org/resources/learning-hub/tutorials/aop-data-management-releases" target="_blank">Understanding AOP Data Releases and Best Practices for AOP Data Management</a>
* <a href="https://data.neonscience.org/data-api/" target="_blank">NEON Data API</a>

For a handy resource on Jupyter Notebook tips, tricks and shortcuts, check out the DataQuest blog linked below.
 * <a href="https://www.dataquest.io/blog/jupyter-notebook-tips-tricks-sh" target="_blank"> 28 Jupyter Notebook Tips, Tricks, and Shortcuts </a>

</div>

## Overview of AOP Discrete Lidar Data Products

AOP generates several Level-1 and Level-3 (derived) data products. The Level 1 lidar data is the point cloud data, provided in laz (or zipped las) format, while the Level 3 data is provided in geotiff (.tif) raster format. Images of these two data types are shown in the figures below.

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/py-figs/intro-point-clouds-py/AOP-WREF-discrete-point-lidar-forest.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/py-figs/intro-point-clouds-py/AOP-WREF-discrete-point-lidar-forest.png" width="600"/>Lidar Point Cloud</a>
    <figcaption="Example Lidar Point Cloud, colorized by elevation and RGB camera imagery"</figcaption>
</figure>

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/py-figs/intro-point-clouds-py/L3-raster.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/py-figs/intro-point-clouds-py/L3-raster.png" width="300"/>Lidar Elevation Raster</a>
    <figcaption="Example Lidar Elevation Raster"</figcaption>
</figure>

The table below summarizes the NEON AOP Lidar data products. This lesson will give a brief introduction to both the Level 1 Classified Point Cloud data, as well as the Level 3 raster geotiff data products (DTM, DSM, and CHM). For more detailed information on these data products, please refer to: <a href="https://www.neonscience.org/data-collection/lidar" target="_blank"> Airborne Remote Sensing Lidar</a>, and/or click on the linked data product pages in the table. 

| Acronym / Short Name | Data Product Name | Data Product ID | Link to ATBD |
|---------|-------------------|-----------------|--------------|
| Point Cloud | Discrete return LiDAR point cloud | <a href="https://data.neonscience.org/data-products/DP1.30003.001" target="_blank">DP1.30003.001</a> | <a href="https://data.neonscience.org/api/v0/documents/NEON.DOC.001292vB" target="_blank">NEON L0-to-L1 Discrete Return LiDAR ATBD</a>|
| CHM | Ecosystem structure | <a href="https://data.neonscience.org/data-products/DP3.30015.001" target="_blank">DP3.30015.001</a> | <a href="https://data.neonscience.org/api/v0/documents/NEON.DOC.002387vA" target="_blank">NEON Ecosystem Structure ATBD</a>|
| DSM/DTM | Elevation - LiDAR| <a href="https://data.neonscience.org/data-products/DP3.30024.001" target="_blank">DP3.30024.001</a> | <a href="https://data.neonscience.org/api/v0/documents/NEON.DOC.002390vA" target="_blank">NEON Elevation (DTM and DSM) ATBD</a> |
| Slope/Aspect | Slope and Aspect - LiDAR | <a href="https://data.neonscience.org/data-products/DP3.30025.001" target="_blank">DP3.30025.001</a> | <a href="https://data.neonscience.org/api/v0/documents/NEON.DOC.003791vA" target="_blank">NEON Elevation (Slope and Aspect) ATBD</a> |

The Data Product page contains important information, as well as linked Algorithm Theoretical Basis Documents (ATBDs) which provide necessary information for understanding how the data products were generated, uncertainty associated with the data, and other essential contextual information.


### Lidar Point Clouds

The first part of this tutorial will be working with the Discrete Return LiDAR Point Cloud data product (<a href="https://data.neonscience.org/data-products/DP3.30003.001" target="_blank">DP3.30003.001</a>) at the NEON site <a href="https://www.neonscience.org/field-sites/guan" target="_blank">Guanica Forest (GUAN)</a> in Domain 04, Puerto Rico.

Before we dig into the data, we'll need to import the required packages.

#### Import Packages

First, we need to import the required Python packages. 

**Reminder**: If you haven't installed these packages (see more detailed installation instructions above), you can install them in the notebook as shown below. If the install doesn't work with a simple pip install, download the appropriate wheel file and substitute the package name with the wheel file name (including the full path). We recommend installing these packages one by one so you can make sure each package installs successfully.

```python
!pip install requests
!pip install gdal
!pip install fiona
!pip install geopandas
!pip install rasterio
!pip install laspy
!pip install lazrs
!pip install neonutilities
!pip install python-dotenv
```

Once all packages are successfully installed, import them as follows. Note we will import some of them a bit later.


```python
#import required packages
import os
import requests
import numpy as np
import matplotlib.pyplot as plt
import geopandas as gpd
import laspy
import neonutilities as nu
import dotenv
```

As of June 2026, NEON requires an API token for data downloads, to reduce bot scraping and improve user support. Tokens can be generated in NEON data portal user accounts - log in to your account or create one, and go to the API Tokens section. For best practices in storing and using tokens, follow the instructions <a href="https://www.neonscience.org/resources/learning-hub/tutorials/api-token-setup" target="_blank">here</a>. Once you've set up your token as an environment variable, you can load it using  the `python-dotenv` package as follows, optionally specifying the path to the `.env` file in `load_dotenv()`.


```python
dotenv.load_dotenv()
token = os.environ.get("NEON_TOKEN")
```

Now that we've pulled in the packages needed for the first part of the tutorial, we can download a dataset from the NEON API.

First we'll start by defining variables that specify the NEON data product ID (`dpID`), site, and year. You can change the site code to look at a different site of your interest (for more detailed information about the NEON sites, please check out the <a href="https://www.neonscience.org/field-sites/explore-field-sites" target="_blank">Explore Field Sites</a> webpage. 


```python
dpID='DP1.30003.001' 
site = 'GUAN'
```

We can use the function `nu.list_available_dates` to see what data is available for this data product and site. This function requires two inputs: the data product ID `dpID` and the site ID, `site`.

Optionally run `help` to see the required inputs and more information about this function.
```help(nu.list_available_dates)```


```python
nu.list_available_dates(dpID,site)
```

    RELEASE-2026 Available Dates: 2018-05, 2022-10
    

The AOP has only flown Puerto Rico (D04) in 2018 and 2022 so far (as of 2026). D04 is only on the AOP schedule every 4-5 years, unlike most domains in the continental United States. For this tutorial, we'll look at data from 2022.


```python
year='2022'
```

On your own, you can use `help` to take a look at the `nu.by_file_aop` and `nu.by_tile_aop` functions, which we'll use to download the CHM data for all tiles, and the lidar classified point cloud data for a single tile that we want to explore.

The required inputs for this function are the `product`, `site`, `year` and `token`. Optionally we can specify the `savepath` to save the files. By default, the function will display the size of the files, and prompt the user to continue the download (by typing `y`); any other response will halt the download. This is to prevent an accidental download of a large volume of data.

### Lidar Metadata

We'll start by exploring some of the metadata, including the pdf documentation, and shapefiles that provide geographic information corresponding to the data. Because AOP data can be pretty large for an entire site, and you may only need to work with a subset of the data for a given site, we recommend starting with the metadata. 

#### Lidar Documentation - QA html and pdf reports

AOP data provides summary html or pdf documents, which include information about the sensors used to collect the lidar data, acquisition parameters, processing parameters, and QA information. When working with any AOP data, we recommend reviewing this documentation, as well as referencing the relevant ATBDs. The QA reports are saved in the "Metadata" folder. We can start by downloading the CHM data for this site and take a look at the reports (on your own) and shapefiles.


```python
# download the CHM data to the C:/data directory - change this if desired
nu.by_file_aop(dpid='DP3.30015.001',
               site='GUAN',
               year=year,
               token=token,
               savepath=r'C:\data',
               check_size=False)
```

    Downloading 177 NEON data files totaling approximately 286.4 MB
    
    100%|███████████████████████████████████| 177/177 [01:26<00:00,  2.04it/s]
    

Use the code cell below to walk through all the directories and display what was downloaded.


```python
# Display end level folders in the savepath
for root, dirs, files in os.walk(r'C:\Data\DP3.30015.001'):
    if not dirs:
        print(root)
```

    C:\Data\DP3.30015.001\neon-aop-products\2022\FullSite\D04\2022_GUAN_2\L3\DiscreteLidar\CanopyHeightModelGtif
    C:\Data\DP3.30015.001\neon-aop-products\2022\FullSite\D04\2022_GUAN_2\Metadata\DiscreteLidar\Reports
    C:\Data\DP3.30015.001\neon-aop-products\2022\FullSite\D04\2022_GUAN_2\Metadata\DiscreteLidar\TileBoundary\geojson
    C:\Data\DP3.30015.001\neon-aop-products\2022\FullSite\D04\2022_GUAN_2\Metadata\DiscreteLidar\TileBoundary\kmls
    C:\Data\DP3.30015.001\neon-aop-products\2022\FullSite\D04\2022_GUAN_2\Metadata\DiscreteLidar\TileBoundary\shps
    C:\Data\DP3.30015.001\neon-publication\release\tag\RELEASE-2026\NEON.DOM.SITE.DP3.30015.001\GUAN\20221001T000000--20221101T000000\basic
    

You can see there are a number of files in the Metadata folder, including Reports and TileBoundary files including geojson, kmls, and shps. Please explore the Reports on your own time. 

#### Plot Shapefile Boundaries

Next let's display the path to the tile boundary shapefile, and save it to the variable `shp_file`:


```python
# display .shp data in the savepath
for root, dirs, files in os.walk(r'C:\Data\DP3.30015.001'):
    for file in files:
        if file.endswith(".shp"):
             shp_file = os.path.join(root, file)
             print(shp_file)
```

    C:\Data\DP3.30015.001\neon-aop-products\2022\FullSite\D04\2022_GUAN_2\Metadata\DiscreteLidar\TileBoundary\shps\NEON_D04_DPQA_2022_GUAN_2_lidar_tile_boundary.shp
    

To plot the boundary shapefile, use `geopandas` (imported as `gpd`) as follows:


```python
gdf = gpd.read_file(shp_file)
gdf.plot(alpha=0.5, edgecolor='black');
ax = plt.gca(); ax.ticklabel_format(style='plain') 
ax.set_title('AOP Coverage of ' + site + ' in ' + year);
plt.xticks(rotation=90); #optionally rotate the xtick labels
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Lidar/intro-lidar/intro_point_clouds_py/intro_discrete_point_clouds_files/intro_discrete_point_clouds_28_0.png)    


Now that we can see the extent of the tiles, we'll pick a single tile in this area to download. For this example, specify the tile `726000_1986000` towards the southern part of the site, including both land and sea.


```python
nu.by_tile_aop(dpid='DP1.30003.001',
               site=site,
               year=year,
               easting=726000,
               northing=1986000,
               savepath='C:\data',
               token=token)
```

    Provisional NEON data are not included. To download provisional data, use input parameter include_provisional=True.
    

    Continuing will download 2 NEON data files totaling approximately 413.8 MB. Do you want to proceed? (y/n)  y
    

    Downloading 2 NEON data files totaling approximately 413.8 MB
    
    100%|███████████████████████████████████████| 2/2 [00:15<00:00,  7.81s/it]
    

We can check that this file successfully downloaded to the expected location. Alternatively you could look in your file explorer.


```python
# display .shp data in the savepath
for root, dirs, files in os.walk(r'C:\Data\DP1.30003.001'):
    for file in files:
        if file.endswith(".laz"):
             laz_file = os.path.join(root, file)
             print(laz_file)
```

    C:\Data\DP1.30003.001\neon-aop-products\2022\FullSite\D04\2022_GUAN_2\L1\DiscreteLidar\ClassifiedPointCloud\NEON_D04_GUAN_DP1_726000_1986000_classified_point_cloud_colorized.laz
    

### Exploring point cloud data with `laspy`

Now that we've successfully downloaded a laz (or zipped las) file, we can use the `laspy` package to read it in! We'll do that in the next line, reading the lidar file into the variable name `point_cloud`:


```python
# read the laz file into a LasData object using laspy.read()
point_cloud=laspy.read(laz_file)
```

Reading in the file with with `laspy.read()` reads in both the metadata and the raw point cloud data. We can print out the `point_cloud` variable to show some basic information about what we've read in:


```python
point_cloud
```




    <LasData(1.4, point fmt: <PointFormat(7, 0 bytes of extra dims)>, 60503721 points, 4 vlrs)>



`point_format.dimension_names` show us the available information stored in this LasData object format:


```python
list(point_cloud.point_format.dimension_names)
```




    ['X',
     'Y',
     'Z',
     'intensity',
     'return_number',
     'number_of_returns',
     'synthetic',
     'key_point',
     'withheld',
     'overlap',
     'scanner_channel',
     'scan_direction_flag',
     'edge_of_flight_line',
     'classification',
     'user_data',
     'scan_angle',
     'point_source_id',
     'gps_time',
     'red',
     'green',
     'blue']



In the next few cells, we can explore some of these variables:


```python
point_cloud.classification
```




    array([2, 2, 2, ..., 1, 1, 2], shape=(60503721,), dtype=uint8)



Let's get the `set` of this `list` to see all the unique classification values in this file. This may take a little time to run.


```python
set(list(point_cloud.classification))
```




    {np.uint8(1), np.uint8(2), np.uint8(5), np.uint8(6), np.uint8(7)}



We can see that there are a several unique classification values for this site.
Las files have "predefined classification schemes defined by the American Society for Photogrammetry and Remote Sensing (ASPRS)". You can refer to the <a href="https://desktop.arcgis.com/en/arcmap/10.3/manage-data/las-dataset/lidar-point-classification.htm" target="_blank">ArcGIS documentation</a> for more details.

The following table lists the LAS classification codes defined by ASPRS for these LAS versions:

| Classification value | Meaning           |
|---------------------|-------------------|
| 0                   | Never classified  |
| 1                   | Unassigned        |
| 2                   | Ground            |
| 3                   | Low Vegetation    |
| 4                   | Medium Vegetation |
| 5                   | High Vegetation   |
| 6                   | Building          |
| 7                   | Low Point         |

Next let's take a look at what we can consider to be the main data - the geographic loation of each point in the point cloud. This can be accessed with `point_cloud.xyz`. Let's take a look:


```python
xyz = point_cloud.xyz
xyz
```




    array([[7.26249992e+05, 1.98624955e+06, 1.83900000e+00],
           [7.26249966e+05, 1.98624954e+06, 1.85400000e+00],
           [7.26249935e+05, 1.98624954e+06, 1.85700000e+00],
           ...,
           [7.26890362e+05, 1.98675012e+06, 3.28200000e+00],
           [7.26890912e+05, 1.98675024e+06, 1.54700000e+00],
           [7.26890837e+05, 1.98675022e+06, 1.62000000e+00]],
          shape=(60503721, 3))



We can see this is a 3-dimensional array, as we might expect. Let's read this into the variable `xyz`:

We can see the size (or number of points) in this array using the built-in python function `len`:


```python
len(xyz)
```




    60503721



There are > 60 million lidar points in this single 1km x 1km tile. For the rest of this exercise, we'll look at a random subset of these points, taking every 100th point (you can change this subset factor, but when we visualize the data in a few steps, subsetting by a larger factor will speed up the time it takes to make the plot).


```python
factor=100
points_dec = xyz[::factor]
```

These point clouds have been "colorized" by the camera RGB imagery. If you refer back to the dimension names, you can see there are a `red`, `green`, and `blue` attributes. We can pull these into a single array by using `np.vstack`:


```python
# points = np.vstack((point_cloud.x, point_cloud.y, point_cloud.z)).transpose()
colors = np.vstack((point_cloud.red, point_cloud.green, point_cloud.blue)).transpose()
```

These colors have been scaled to store the color at a higher resolution, accomodated by the camera, so we'll need to re-scale the values between 0-1 in order to use them in our plot. The code below does this re-scaling, and then subsets the color data to by same factor we used to subset the `xyz` data.


```python
colors_norm = (colors - np.min(colors))/np.ptp(colors)
colors_dec = colors_norm[::factor]
```

### 3D Point Cloud Visualization 
Lastly, we can visualize this 3D data using matplotlib to see what the point cloud looks like. 


```python
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import axes3d
```


```python
# Plot the las data in 3D
fig = plt.figure(figsize=(6,6))
ax = fig.add_subplot(111, projection='3d')
ax.scatter(points_dec[:,0],points_dec[:,1],points_dec[:,2],color=colors_dec,s=4)
ax.set_zlim3d(-10,50)
plt.show()
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Lidar/intro-lidar/intro_point_clouds_py/intro_discrete_point_clouds_files/intro_discrete_point_clouds_61_0.png)   
    


We can see a mix of both land and sea here, with slightly fewer returns over the ocean. The z scale is stretched considerably compared to x and y. A lot of the energy from the laser beam is absorbed in water, so it is typical to see low point density over bodies of water. Remember this plot only displays 1/100th of the data, so there is a lot more data in the las file than is shown here.

### Lidar Raster Data - CHM

Lastly, we'll take a look at a derived (Level-3, or L3) data product generated from this point cloud data. NEON generates 5 different derived L3 products from the discrete data: Digital Terrain Model (DTM), Digital Surface Model (DSM), Canopy Height Model (CHM), Slope, and Aspect.

In the last part of this lesson, we'll show how to read in and visualize the CHM (downloaded previously) using Python package `rasterio`. First we'll import the package and sub-package that's used to display the data


```python
import rasterio
from rasterio.plot import show
```

In the next couple cells, we'll find the CHM tile corresponding to the las file that we read in, and then plot it.


```python
# display .shp data in the savepath
for root, dirs, files in os.walk(r'C:\Data\DP3.30015.001'):
    for file in files:
        if file.endswith("726000_1986000_CHM.tif"):
             chm_file = os.path.join(root, file)
             print(chm_file)
```

    C:\Data\DP3.30015.001\neon-aop-products\2022\FullSite\D04\2022_GUAN_2\L3\DiscreteLidar\CanopyHeightModelGtif\NEON_D04_GUAN_DP3_726000_1986000_CHM.tif
    

Next we'll read this in, using `rasterio`, as follows:


```python
chm = rasterio.open(chm_file)
```


And finally, we can plot the data using the rasterio `show` function that we imported earlier.


```python
fig, ax = plt.subplots(figsize=(6, 6))
show(chm, ax=ax)
ax.ticklabel_format(style='plain', axis='y') # turn off scientific notation for the y-axis (or both axes)
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Lidar/intro-lidar/intro_point_clouds_py/intro_discrete_point_clouds_files/intro_discrete_point_clouds_71_0.png) 
    


## Additional Resources

* **L1 Point Clouds (.laz)**: If you'd like to continue exploring the point cloud data in Python using `laspy`, <a href="https://laspy.readthedocs.io/en/latest/complete_tutorial.html" target="_blank"> laspy website </a> has some nice examples you can follow, now that you know how to download NEON point cloud data and read it into Python.
* **L3 Rasters (.tif)**: Refer to the <a href="https://rasterio.readthedocs.io/en/latest/" target="_blank"> rasterio documentation </a> for more options on plotting, and beyond in rasterio.

### Python and Beyond - Other Options for working with Point Cloud Data

There are also a number of open-source tools for working with point-cloud data. Python may not be the best option for developing more rigourous processing workflows, for example. The resources below show some other recommended tools that can be integrated with Python for your analysis:

* <a href="https://rapidlasso.com/lastools/" target="_blank">LAStools</a>
* <a href="https://pdal.io/en/stable/" target="_blank">PDAL (Point Data Abstraction Library)</a> 
* <a href="https://plas.io/" target="_blank">plas.io (free, interactive, web-based point cloud visualization)</a> 
* <a href="https://r-lidar.github.io/lidRbook/" target="_blank"> lidR (R package for point cloud data)</a>
