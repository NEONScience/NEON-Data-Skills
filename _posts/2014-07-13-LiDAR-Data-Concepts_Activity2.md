  ---
layout: post
title:  "LiDAR Data, Activity 2 -- LiDAR Data Processing Basics"
date:   2014-07-11 20:49:52
categories: [Working With LiDAR Data]
tags : [measuring vegetation,remote sensing, laser scanning]
description: "Learn the basics of how a LiDAR system operates, how Lidar
data are used in science and explore some free lidar data analysis tools. Awesome!"
---
# Overview #
This activity will review the basic data concepts and also processing techniques that are required to convert discrete return LiDAR data points into useful data products that can be used to measure elevation and vegetation height. Concepts include:
*  Raster vs vector data, 
*  attribute data and 
*  different gridding methods that can be used to turn LiDAR data points into rasters that map elevation and tree height across the entire extent of a LiDAR data collection area. 
In this activity, we will cover 4 core LiDAR data products: 1) classified LiDAR data point clouds, 2) digital elevation models, 3) digital surface models and 4) canopy height models.

## Goals##
- understand the basic LiDAR data product formats - raster and vector. 
- Understand what classified LiDAR data points are and how they are used.

## Learning Concepts ##
### Data literacy concepts
*    The basic formats of LiDAR data - raster and vector
*    Understand how we convert points into grids (basics gridding)
*    How to view raster and vector data (and associated attributes) in QGIS

### LiDAR Remote Sensing Concepts
*    Understand how LiDAR data are classified to support derivation of raster based data products
Understand how LiDAR data are used to measure ground elevation
*    Understand two basic ways LiDAR can be used to measure tree height
*    Understand ways in which how LiDAR raster products are derived (point to grid)

## Introduction
* This activity will cover the fundamental processing techniques that are required to convert LiDAR point clouds into useful data products.. 
* As we discussed in Activity 1<link>, LiDAR data are simply a bunch of points that tell us something about the heights of things on the ground. However, the LiDAR system does not tell us what what the points reflected off of. So we can’t distinguish points that are from the ground vs points from vegetation, without further analysis.
*    There are a series of steps associated with turning LiDAR data points into information that we can use in science for things like characterizing vegetation.
*    In this activity, we will explore how discrete LiDAR data points are processed to yield useful data products such as maps of ground elevation and tree height. We will also explore some point data and raster data in QGIS to familiarize ourselves with basic QGIS tools.

To understand LiDAR data products we need to first understand a few basic data concepts:
*    The difference between Vector and Raster data
*    Attribute data associated with vector and raster data
We’ll review these concepts, hands on, by exploring the data in the freely available QGIS software.

## Raster vs Vector Data -- The Basics 
* so let's first talk about the difference between raster and point based vector data. Lidar data points are Vector data . Each point in a LiDAR dataset has a X, Y, Z value and other attributes as we discussed in Activity One. The points may be located anywhere in space are not within any particular grid.
 <link to something on vector data>
http://www.gislounge.com/geodatabases-explored-vector-and-raster-data/

*. In comparison a raster file is a regular grid of cells, all of which are the same size. A few notes about rasters:
*    Each cell is called a pixel. 
*    And each pixel represents an area on the ground. 
*    The resolution of the raster represents the area that each pixel represents on the ground. So, for instance if the raster is 1m resolution, that simple means that each pixel represents a 1 m by 1m area on the ground.
Raster data can have attributes associated with it as well. For instance each cell might represent a particular landcover class or an elevation value. 
<Link to raster overview...>
http://webhelp.esri.com/arcgisdesktop/9.2/index.cfm?TopicName=What_is_raster_data%3F
> Side bar: raster format that you are familiar with is an image...more about that...

## The Skinny -- 
In short, when you go to download lidar data the first question you should ask is what format the data are in. Are you downloading point clouds that you might have to process? Or rasters that are already processed for you. How do you know?
1. check out the metadata
2. look at the file format - if you are downloading a .las file, then you are getting points. 

## creating useful data products from LiDAR data

## Classifying LiDAR point clouds
LiDAR data points are vector data. LiDAR point clouds are useful because they tell us something about the heights of objects on the ground. However, how do we know whether a point reflected off of a tree, a bird, a building or the ground? In order to develop products like elevation models and canopy height models, we need to classify individual LiDAR points. We might classify LiDAR points into classes like
*    ground
*    vegetation
*    buildings
Lidar Point cloud classification is often already done when you download LiDAR point clouds but just know that it’s not to be taken for granted! Programs such as lastools, fusion and terrascan are often used to perform this classification. Once the points are classified, they can be used to derive various LiDAR data products. For example the ground points can be used to create a digital elevation model or DEM. And the vegetation points can be used to create a canopy height model. More on that in the next activity.
So when you are looking at metadata for LiDAR, it's good to notice whether the data have been classified or not. 
Image/ animation: Classifying LiDAR points
--->>>> move this section to activity 1????
## LiDAR Point Cloud File Formats
The file format most commonly associated with the LiDAR point clouds is called .las 
Sometimes - LiDAR point cloud files are available in a text file format. 
### Free point cloud viewers that open LiDAR point clouds
*    Us forest service RSAC FUSION.
*    Cloud compare
*    Plas.io 
*    Others (link to some of the online list of tools)
---! > end move

## LiDAR derived raster data products
While some papers suggest that point cloud derived analysis may yield more accurate estimate of vegetation characteristics (citations here), Point clouds are challenging to work with. For one, there are often millions of points on a LiDAR dataset which can slow processing down. Also point cloud based analysis often requires custom programming. The most commonly used LiDAR data products are in a raster data format. Raster data are easy to work with in common GIS tools like QGIS and even in programming languages like R and Matlab.

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

{% include _images.html url="/minimal-mistakes/images/gridding.gif" description="Animation Showing the general process of taking lidar point clouds and converting them to a Raster Format. Credits: Tristan Goulden, National Ecological Observatory Network" %}

CREATE ANIMATION IN POWERPOINT SHOWING THIS→ Tristan’s graphics??

## ACTIVITY -- Creating a Raster in QGIS
In this activity, we will perform a basic gridding calculation to convert LiDAR data points to a raster grid.
Import the points into qgis...use the layer created earlier.
Perform a basic gridding using max value
Talk about how you decide what value to use if you have lots of points in a cell
Talk about or link to gridding methods...gridding vs interpolation

## Summary
So, here’s what we’ve covered so far
*    There are 2 formats of data: raster / vector
*  LiDAR data are most often nvativley collects as points however we often convert those points to rasters in order to produce maps of ground elevation and vegetation height.
*    And raster data can be created with or without interpolation
We also covered some basic tools to perform gridding in the freely available qgis.

In activity 3, we will review some key LiDAR data products.





