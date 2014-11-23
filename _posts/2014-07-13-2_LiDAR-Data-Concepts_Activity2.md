---
layout: post
title:  "Raster LiDAR Data"
date:   2014-07-11 20:49:52
category: remote-sensing
categories: [Remote Sensing]
tags : [lidar]
description: "Understand two common LiDAR data product formats: raster and vector and learn the basics of how a LiDAR data are processed."
image:
  feature: lidar_GrandMesa.jpg
  credit: LiDAR data collected over Grand Mesa, Colorado - National Ecological Observatory Network (NEON)
  creditlink: http://www.neoninc.org
---

<section id="table-of-contents" class="toc">
  <header>
    <h3 >Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->


### Three Common LiDAR Data Products ###
- [Digital Terrain Model](http://neoninc.org/NEONedu/ESA2014/DTM.html) - This product represents the ground.
- [Digital Surface Model](http://neoninc.org/NEONedu/ESA2014/DSM.html) - This represents the top of the surface (so imagine draping a sheet over the canopy of a forest).
- [Canopy Height Model](http://neoninc.org/NEONedu/ESA2014/CHM.html) - This represents the elevation of the Earth's surface - and it sometimes also called a DEM or digital elevation model.


## LiDAR Point Clouds -- The Basics  ##
Each point in a LiDAR dataset has a X, Y, Z value and other attributes. The points may be located anywhere in space are not aligned within any particular grid. <image: LiDAR data point spacing>.

LiDAR point clouds are typically available in a .las file format. The .las file format is a compressed format that can better handle the millions of points that are often associated with LiDAR data point clouds.


#### Gridded or Raster LiDAR Data Products ###
LiDAR data products are most often worked within a gridded or raster data format. A raster file is a regular grid of cells, all of which are the same size. A few notes about rasters:  

-  Each cell is called a pixel. 
-  And each pixel represents an area on the ground. 
-  The resolution of the raster represents the area that each pixel represents on the ground. So, for instance if the raster is 1 m resolution, that simple means that each pixel represents a 1 m by 1m area on the ground.

Raster data can have attributes associated with it as well. For instance in a LiDAR derived digital elevation model (DEM), each cell might represent a particular elevation value.  In a LIDAR derived intensity image, each cell represents a LIDAR intensity value.

## What To Look for In The Metadata  
In short, when you go to download LiDAR data the first question you should ask is what format the data are in. Are you downloading point clouds that you might have to process? Or rasters that are already processed for you. How do you know?
1. check out the metadata
2. look at the file format - if you are downloading a .las file, then you are getting points. 

## Creating useful data products from LiDAR data

### Classifying LiDAR point clouds
LiDAR data points are vector data. LiDAR point clouds are useful because they tell us something about the heights of objects on the ground. However, how do we know whether a point reflected off of a tree, a bird, a building or the ground? In order to develop products like elevation models and canopy height models, we need to classify individual LiDAR points. We might classify LiDAR points into classes including:
- Ground
- Vegetation
- Buildings
Lidar Point cloud classification is often already done when you download LiDAR point clouds but just know that it’s not to be taken for granted! Programs such as lastools, fusion and terrascan are often used to perform this classification. Once the points are classified, they can be used to derive various LiDAR data products. 



### Free point cloud viewers that open LiDAR point clouds ###
- [Fusion: US Forest Service RSAC](http://www.fs.fed.us/eng/rsac/fusion/)
- [Cloud compare](http://www.danielgm.net/cc/)
- [Plas.io website](http://plas.io) 
- Others (link to some of the online list of tools)

## Creating A Raster From LiDAR Point Clouds
There are different ways to create a raster from LiDAR point clouds. Let's look one of the most basic ways to create a raster file points- basic gridding. When you perform a gridding algorithm, you are simply calculating a value, using point data, for each pixels in your raster dataset. To do this:

1. To begin, a grid is placed on top of the LiDAR data in space. each cell in the grid has the same spatial dimensions. These dimensions represent that particular area on the ground. 
2. So we might overlay a 1m by 1m grid over the LiDAR data points . 
3. To create the raster file, we simply calculate a value, using the LiDAR points for each 1m cell.
4. Now there are different algorithms that can be applied to calculate this value. 
5. We can use a simple grid approach and use basic math to calculate the value for each cell. For example, we might take the mean elevation of all LiDAR points within each cell. This might mean that some cells have no value - which might be ok. 
6. Or, we can use a more advanced approach that considers the values of points outside of the call in addition to points within the cell to calculate a value. This method - called interpolation .
7. Interpolation is useful because it can provide us with some ability to predict cell values in areas where there are no data (or no points). And to quantify the error associated with those predictions which is useful to know, if you are doing research. 
8. You can view a grid in 2dimensions or 3dimensions. <<pan around a 2d hill shade and then a 3d hillshade...>>

{% include _images.html url="../../images/gridding.gif" description="Animation Showing the general process of taking lidar point clouds and converting them to a Raster Format. Credits: Tristan Goulden, National Ecological Observatory Network" %}



## Use Images From The LiDAR Data Image Gallery In Your Presentations & Teaching! ##


<iframe width="100%" height="500px" frameborder="0" scrolling="no" src="http://flickrit.com/slideshowholder.php?height=75&size=big&setId=72157648481541867&caption=true&theme=1&thumbnails=1&transition=1&layoutType=responsive&sort=0" ></iframe>

