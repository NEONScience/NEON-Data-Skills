---
syncID: c10184c4075445bf8ade25415103d78d
title:  "What is a CHM, DSM and DTM? About Gridded, Raster LiDAR Data"
description: "Understand LiDAR data product formats and learn the basics of how a LiDAR data are processed."
dateCreated:   2014-07-21 
authors: Leah A. Wasser
contributors:
estimatedTime: 0.25 - 0.5 Hours
packagesLibraries:
topics: lidar, remote-sensing
languagesTool: R
dataProduct:
code1:
tutorialSeries: [intro-lidar-r-series]
urlTitle: chm-dsm-dtm-gridded-lidar-data
---


## Common LiDAR Data Products

* <a href="{{ site.baseurl }}/3d/SJER_DTM_3d.html target="_blank">Digital Terrain Model</a> - This 
product represents the elevation of the ground.
* <a href="{{ site.baseurl }}/3d/SJER_DSM_3d.html" target="_blank">Digital Surface Model</a> - This 
represents the elevation of the tallest surfaces at that point. Imagine draping 
a sheet over the canopy of a forest, the DEM contours with the heights of the 
trees where there are trees but the elevation of the ground when there is a 
clearing in the forest.

* <a href="{{ site.baseurl }}/3d/SJER_CHM_3d.html" target="_blank">Canopy Height Model</a> - This 
represents the difference between a Digital Terrain Model and a Digital Surface 
Model and gives you the height of the objects (in a forest, the trees) that are 
on the surface of the earth.

<figure class="third">
    <a href="{{ site.baseurl }}/3d/SJER_DTM_3d.html" target="_blank"><img src="{{ site.baseurl }}/images/lidar/dem.png"></a>
    <a href="{{ site.baseurl }}/3d/SJER_DSM_3d.html" target="_blank"><img src="{{ site.baseurl }}/images/lidar/dsm.png"></a>
    <a href="{{ site.baseurl }}/3d/SJER_CHM_3d.html" target="_blank"><img src="{{ site.baseurl }}/images/lidar/chm.png"></a>
    
    <figcaption> 3D models of a LiDAR-derived Digital Terrain Model (DTM;left), 
     Digital Surface Model (DSM; middle), and Canopy Height Model (CHM; right). 
     Click on the images to view interactive 3D models. </figcaption>
</figure>


## LiDAR Point Clouds 
Each point in a LiDAR dataset has a X, Y, Z value and other attributes. The 
points may be located anywhere in space are not aligned within any particular 
grid.

 <figure>
	<a href="{{ site.baseurl }}/images/lidar/Lidar_points.png" target="_blank">
	<img src="{{ site.baseurl }}/images/lidar/Lidar_points.png"></a>
	<figcaption> Representative point cloud data. Source: National Ecological 
	Observatory Network (NEON)  
	</figcaption>
</figure>

LiDAR point clouds are typically available in a .las file format. The .las file 
format is a compressed format that can better handle the millions of points that 
are often associated with LiDAR data point clouds.

### Free Point Cloud Viewers for LiDAR Point Clouds
- <a href="http://www.fs.fed.us/eng/rsac/fusion/" target="_blank">Fusion: US Forest Service RSAC</a>
- <a href="http://www.danielgm.net/cc/" target="_blank">Cloud compare</a>
- <a href="http://plas.io" target="_blank">Plas.io website</a>

For more on viewing LiDAR point cloud data using the Plas.io online
viewer, see our tutorial 
<a href="{{ site.baseurl }}/plasio-view-pointclouds" target="_blank"> *Plas.io: Free Online Data Viz to Explore LiDAR Data*</a>. 


### Gridded, or Raster, LiDAR Data Products
LiDAR data products are most often worked within a gridded or raster data format. 
A raster file is a regular grid of cells, all of which are the same size. 

A few notes about rasters:  

*  Each cell is called a pixel. 
*  And each pixel represents an area on the ground. 
*  The resolution of the raster represents the area that each pixel represents 
on the ground. So, for instance if the raster is 1 m resolution, that simple 
means that each pixel represents a 1m by 1m area on the ground.


 <figure>
	<a href="{{ site.baseurl }}/images/dc-spatial-raster/raster_concept.png" target="_blank">
	<img src="{{ site.baseurl }}/images/dc-spatial-raster/raster_concept.png"></a>
	<figcaption> Raster or “gridded” data are stored as a grid of values which 
	are rendered on a map as pixels. Each pixel value represents an area on the 
	Earth’s surface.  Source: National Ecological Observatory Network (NEON)  
	</figcaption>
</figure>


Raster data can have attributes associated with them as well. For instance in a 
LiDAR-derived digital elevation model (DEM), each cell might represent a 
particular elevation value. In a LIDAR-derived intensity image, each cell 
represents a LIDAR intensity value.

## LiDAR Related Metadata
In short, when you go to download LiDAR data the first question you should ask 
is what format the data are in. Are you downloading point clouds that you might 
have to process? Or rasters that are already processed for you. How do you know?

1. Check out the metadata! 
2. Look at the file format - if you are downloading a .las file, then you are 
getting points. If it is .tif, then it is a post-processing raster file. 

## Create Useful Data Products from LiDAR Data

### Classify LiDAR Point Clouds

LiDAR data points are vector data. LiDAR point clouds are useful because they 
tell us something about the heights of objects on the ground. However, how do 
we know whether a point reflected off of a tree, a bird, a building or the 
ground? In order to develop products like elevation models and canopy height 
models, we need to classify individual LiDAR points. We might classify LiDAR 
points into classes including:

* Ground
* Vegetation
* Buildings

LiDAR point cloud classification is often already done when you download LiDAR 
point clouds but just know that it’s not to be taken for granted! Programs such 
as lastools, fusion and terrascan are often used to perform this classification. 
Once the points are classified, they can be used to derive various LiDAR data 
products. 


### Create A Raster From LiDAR Point Clouds
There are different ways to create a raster from LiDAR point clouds. 

#### Point to Raster Methods - Basic Gridding
Let's look one of the most basic ways to create a raster file points - basic gridding. 
When you perform a gridding algorithm, you are simply calculating a value, using 
point data, for each pixels in your raster dataset. 

1. To begin, a grid is placed on top of the LiDAR data in space. Each cell in 
the grid has the same spatial dimensions. These dimensions represent that 
particular area on the ground. If we want to derive a 1 m resolution raster 
from the LiDAR data, we overlay a 1m by 1m grid over the LiDAR data points. 
2. Within each 1m x 1m cell, we calculate a value to be applied to that cell, 
using the LiDAR points found within that cell. The simplest method of doing this
is to take the max, min or mean height value of all lidar points found within 
the 1m cell. If we use this approach, we might have cells in the raster that 
don't contains any lidar points. These cells will have a "no data" value if we 
process our raster in this way. 

<figure>
    <a href="http://{{ site.baseurl }}/gridding-interpolation-spatial-data-gif" target="_blank">
    <img src="{{ site.baseurl }}/images/lidar/gridding.gif"></a>
    <figcaption> Animation showing the general process of taking LiDAR point 
    clouds and converting them to a raster format. 
    Source: Tristan Goulden, National Ecological Observatory Network (NEON)  
	</figcaption>
</figure>

#### Point to Raster Methods - Interpolation

A different approach is to interpolate the value for each cell. 

1. In this approach we still start with placing the grid on top of the LiDAR 
data in space. 
2. Interpolation considers the values of points outside of the cell in addition
to points within the cell to calculate a value. Interpolation is useful because 
it can provide us with some ability to predict or calculate cell values in areas 
where there are no data (or no points). And to quantify the error associated with those 
predictions which is useful to know, if you are doing research. 


***

For learning more on how to work with LiDAR data, consider going through the 
<a href="{{ site.baseurl }}/raster-data-series" target="_blank">*Introduction to Working With Raster Data in R*</a> 
tutorial series.  
