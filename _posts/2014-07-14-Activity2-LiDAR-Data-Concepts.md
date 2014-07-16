# LiDAR Data Products - How We Use LiDAR Data #

## Goals##
- understand the basic, most fundamental physical and ecological applications of lidar data
- understand the key lidar data formats (las, txt, grids and CHM/ DEM) to support this application

## Learning Concepts ##
### Data literacy concepts
*	The basic formats of lidar data - raster and vector
*	Understand how we convert points into grids (basics - interpolation vs gridding?)
*	Grid math

### LiDAR Remote Sensing Concepts
*	Understand how LiDAR is used to measure ground elevation
*	Understand two basic ways lidar can be used to measure tree height
*	Understand ways in which how lidar raster products are derived (point to grid)

## Part 3 i think -- 
CHM
point cloud techniques (percentiles)
Understand how LiDAR data can be used as a proxy estimate of vegetation density (fractional cover / proxy for lai, biomass)
Other applications


## Introduction
* This activity will cover how we use LiDAR data to derive data products that characterize vegetation. 
* As we looked at in activity 1, LiDAR data are simply a bunch of points that tell us something about the heights of things on the ground. 
*	there are a series of steps associated with turning lidar data points into information that we can use in science for things like characterizing vegetation.
*	In this activity, we will explore how discrete lidar data points are used  to create maps of ground elevation and tree height.

To understand lidar data products we need to first understand a few basic data concepts:
*	The difference between Vector and raster data
*	Attribute data associated with vector and raster data
Well review these concepts, hands on, by exploring the data in the freely available qgis software.

Lidar data are often available in vector Format as points.

> #Full Waveform LiDAR Data
>  Some LiDAR systems record the full waveform of returned energy. What this means is that instead of recording only the peak returns, the system records a distribution of returned light energy.
>  <IMAGE - waveform>>
> Link: full waveform LiDAR data presentation . 

## About LiDAR data point clouds: 
*	a Discrete Return LiDAR system records thousands if not millions of  points as it scans the ground.
*	each recorded return of light energy - or lidar point - has a physical x,y and z value. 
*	This xyz information, in addition to information about the scan angle, intensity, and other variables are recorded as attributes of each lidar point.
*	Attributes of typical lidar data points:
 location (x, y) and height (z) value - 
	*	Scan angle
	*	Intensity of light recorded (how much light was recorded)
	*	Return number, etc
We call these files, point clouds. the most common point cloud file format is ".las". 

A key feature of lidar points clouds is that there are a lot of points that cover an area on the ground.
Image: lidar data in the plas.io viewer
Image: Other images of 3d points from. Qt modeler
Image: (2d map showing the spread of point clouds). 
And notice that there are more points in some areas, and less in others…


> Side bar note: ..Let's also have a look at the edges.. More points are at the edges where there is overlap because of the planes flight path

Remember that one pulse of light energy can yield multiple RETURNS. This means that you can have overlapping - or close to overlapping points in some areas where the light energy traveled through something like - say a tree.
<image multiple returns> 

## Classifying lidar point clouds
Now the points clouds are useful because they tell us something about the heights of objects on the ground. However, how do we know whether a point reflected off of a tree, a bird, a building or the ground? In order to develop products like elevation models and canopy height models, we need to classify individual lidar points. Classification of lidar points into classes like
*	ground
*	vegetation
*	buildings
 is a process that is often already done when you download LiDAR point clouds. Programs such as lastools, fusion and terrascan are often used to perform this classification. 

Once the points are classified, they can be used to derive various LiDAR data products- discussed below.
Image/ animation  multiple returns
, the file format most commonly associated with the lidar point clouds is called .las 
sometimes - lidar point cloud files are available in a text file format. 
Free point cloud viewers that open lidar point clouds
*	Us forest service rsac FUSION.
*	Cloud compare
*	Plas.io 
*	Others

You might want to explore some of these data on your own. 

Activity- working with lidar point clouds


1. Bring some data into the plas.io viewer.
	1. Zoom around, notice the 3d nature of the data
	2. view the data by classification
	3. view the data by intensity - what do you notice about intensity values?
	4. View the data by height - what do you notice?

2.	Open up a text file of LiDAR points to see attributes.
	* including scan angle, xyz, intensity etc.

## LiDAR derived raster data products
Point clouds are challenging to work with. For one, there are often mullions of them which can really bog the typcial laptop down. The most commonly used LiDAR data products are in a raster data format. It is much easier to work with individual pixels or cells than to deal with millions of points. Rasters further are easily worked with in most common GIS programs like QGIS.

A raster file is one is a grid of cells, all of which are the same size. A few notes about rasters:
*	Each cell is called a pixel. 
*	And each pixel represents an area on the ground. 
*	The resolution of the raster represents the area that each pixel represents on the ground. So, for instance if the raster is 1m resolution, that simple means that each pixel represents a 1 m by 1m area on the ground.

*	Lidar data products have spatial location associated with them that in turn relates the location of each pixel, to a specific location on the ground.
*	Each pixel is associated with a data value. So if the raster is an elevation model, each pixel contains an elevation value. The raster might also be a land cover dataset..in this case each pixel might represent a particular land cover class.



> Side bar: raster format that you are familiar with is an image...more about that...

## Creating A Raster From LiDAR Point Clouds
So without getting into too much detail, here is a general overview of how creating a raster file from LiDAR data works.



1. To begin, a grid is placed on top of the lidar data in space. each cell in the grid has the same spatial dimensions. These dimensions represent that particular area on the ground. 
2. So we might overlay a 1m by 1m grid over the lidar data points . 
3. To create the raster file, we simply calculate a value, using the lidar points for each 1m cell.
4. Now there are different algorithms that can be applied to calculate this value. 
5. We can use a simple grid approach and use basic math to calculate the value for each cell. For example, we might take the mean elevation of all lidar points within each cell. This might mean that some cells have no value - which might be ok. 
6. Or, we can use a more advanced approach that considers the values of points outside of the call in addition to points within the cell to calculate a value. This method - called interpolation .
7. Interpolation is useful because it can provide us with some ability to predict cell values in areas where there are no data (or no points). And to quantify the error associated with those predictions which is useful to know, if you are doing research. 
8. You can view a grid in 2dimensions or 3dimensions. <<pan around a 2d hill shade and then a 3d hillshade...>>

So here, you see on the screen a grid of lidar derived height values for an areas in XXXX, colorado. This data is called a digital surface model - we will talk about this type of data in a minutes. 

So, here’s what we’ve covered so far
*	There are 2 formats of data: raster / vector
*	And raster data can be created with or without interpolation. 

Now, let’s move on to some lidar data products

The Basics -- Converting Point Clouds to Grids
the basics of interpolation vs gridding ...

3 Basic LiDAR Data Products
So, now that we understand the basic lidar data formats, let’s have a look at 3 basic and very common types of gridded lidar datasets. 
The Digital elevation model - which represents the ground elevation, 
The Digital surface model - which represents the highest point surface of all lidar points - both ground, trees and buildings - the whole cup of tea
And the Canopy Height Model - the surface the represents the HEIGHTS of objects on the ground - after removing ground elevation. So the CHM represents the actual heights of things above ground.
Let’s talk about these next.

Converting Point Clouds to Grids - Creating a DEM
So digital elevation models are one of the most common datasets that you might find. Let’s start by exploring, how we create a digital elevation model, from lidar point clouds.
To create a DEM from lidar data, First, classification algorithms are run on the lidar points which classify the points according to what they reflected off of.  We won’t get into the details of how these algorithms work, but often a scientist will classify the data into ground and non ground points.
If we want to take this a step further, we might classify the non ground points into trees and buildings and maybe even other things like powerlines to use in other lidar data products - we’ll talk about that step later.
So, if you see a lidar data set that is “classified” - that just means that each point has some category assigned to it. You might check out the metadata to find out what categories were used in the classification. 
Now, to create the raster DEM, we need to assign each cell in the raster, an elevation value.
Now when working with lidar data, it is common to have gaps in ground returns, particularly in regions of dense vegetation where laser energy did not travel all the way to the ground and in areas where there is deep water.
Also, we don’t expect to see too many clifs out there in the landscape
So, Digital Elevation Models are often created using some sort of interpolator. If you are a GIS geek, kriging is a common one to use because it allows us to create a smoother model that fills in gaps.... 
So, by using an interpolator, we can convert thousands of ground-classified lidar points into a continuous elevation surface, that covers a larger area - and that doesn’t have gaps. Each cell in the raster has a value. <image of surface model>. 
And - oh yea, they are pretty cool to look at… right?
Now of course there are a few more steps of this process that we are leaving out - BUT this covers the basics of how lidar data can be be processed and used to create a digital elevation model - which is a surface that represents the elevation values of the earth’s surface.

Understand Two Basic Ways LiDAR can be used to measure tree height
Now, that we understand how we take lidar points and convert them into elevation values. Let’s take this a step further and calculate tree height information.
Now, remember when we were creating the digital elevation model, we used the ground classified points to create a gridded surface of ground elevation values. If we want to extract tree height information, we can do the same thing but use vegetation classified points instead.
Now, let’s think about this for a moment… if we JUST take the vegetation classified lidar points, and grid them like we did the ground points, perhaps using an algorithm that calculated the MAX elevation value for each cell, will we get tree height?
well - no - not exactly… if we do this what we will get is the elevation values for each cell at the tops of the trees. But this isn’t quite the height of the tops of the trees above ground.
to get the heights of the tops of the trees - we need to subtract, the elevation of the ground FROM the elevation values from the tops of the trees… this analysis - often called a residual analysis because it gives us the residual height in between the top of the tree and the ground - or the trees height!


Now to focus our discussion, we are going to assume that the lidar data we are working with is in a “point cloud” format. This may be from a discrete return lidar data - or a full waveform lidar system. But we are working with discrete lidar data points. 




Estimating Tree Height and ground elevation from LiDAR
So to The most common products here
* DEM
DSM
CHM

So, one of the most common uses of lidar data is to estimate height. Height values are lidar’s native measurement.

One lidar product some people like to use is called the canopy height model. The canopy height model is a raster that represents the heights of the tops of the trees and buildings, with the influence of ground removed.

So how do we remove the influence of the ground? Well, here’s one option.

1. start with a digital surface model representing the first returns of all lidar pulses. 
2. use a digital elevation model, which represents the elevation of the ground only (trees and buildings are removed).
3. subtract the elevation value from the groun   

GRIDDED LIDAR DERIVED SURFACE MODELS
So let’s first have a look at the types of gridded lidar data sets that you might consider working with. The first most basic lidar grid - is what’s called a digital surface model. 

A digital surface model, represents ONLY the first returned lidar data points - so in theory - it represents the top of the forest - or close to that (if there is forest), and the top of buildings, and the ground. you get the idea. 

When creating a DSM, a scientist will often take the max height value of first returns for each cell in the grid - and assign that to each cell. a DSM looks something like this.
Now often, what a scientist really wants to know is either the heights of the trees, where the trees are or the heights of the ground - or some combination of all of these things. They might also want some estimate surrounding how much vegetation there is in a particular area. Let’s explore these ideas next.

.


LIDAR POINT CLOUD PRODUCTS
