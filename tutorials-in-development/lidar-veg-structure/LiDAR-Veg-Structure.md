---
layout: post
title: "Characterize Vegetation Structure Using Lidar Data- #WorkWithData"
date: 2016-04-05
authors: [Leah A. Wasser]
dateCreated: 2016-04-05
lastModified: 2016-04-05
categories: []
category: 
tags: []
mainTag:
scienceThemes: [vegetation]
description: "The overview page I used at CU 5 April 2016."
code1:
image:
  feature: TeachingModules.jpg
  credit: A National Ecological Observatory Network (NEON) - Teaching Module
  creditlink: http://www.neoninc.org
permalink: /lidar-veg-structure/
code1: 
comments: false
---

{% include _toc.html %}

# 


### How LiDAR Works ##
<iframe width="560" height="315" src="//www.youtube.com/embed/EYbhNSUnIdU?rel=0" frameborder="0" allowfullscreen></iframe>


### Let's Get Started - Key Concepts to Review

## Why LiDAR

Scientists often need to characterize vegetation over large regions. We use tools that can estimate key characteristics over large areas because we don’t have the resources to measure each and every tree. These tools often use remote methods. Remote sensing means that we aren’t actually physically measuring things with our hands, we are using sensors which capture information about a landscape and record things that we can use to estimate conditions and characteristics.


{% include _images_nolink.html url="../../images/ScalingTrees_NatGeo.jpg" description="Conventional on the ground methods to measure trees are resource intensive and limit the amount of vegetation that can be characterized! Photo: National Geographic" %}

To measure vegetation across large areas we need remote sensing methods that can take many measurements, quickly using automated sensors. These measurements can  be used to estimate forest structure across larger areas. LiDAR, or light detection ranging (sometimes also referred to as active laser scanning) is one remote sensing method that can be used to map structure including vegetation height, density and other characteristics across a region. LiDAR directly measures the height and density of vegetation on the ground making it an ideal tool for scientists studying vegetation over large areas.

## How LiDAR Works ##

LIDAR is an **active remote sensing** system. An active system means that the system itself generates energy - in this case light - to measure things on the ground. In a LiDAR system, light is emitted from a rapidly firing laser. You can imagine, light quickly strobing from a laser light source. This light travels to the ground and reflects off of things like buildings and tree branches. The reflected light energy then returns to the LiDAR sensor where it is recorded.


A LiDAR system measures the time it takes for emitted light to travel  to the ground and back. That time is used to calculate distance traveled. Distance traveled is then converted to elevation. These measurements are made using the key components of a lidar system including a GPS that identifies the X,Y,Z location of the light energy and an IMU that provides the orientation of the plane in the sky.


## What Is Discrete Return Lidar -- Plasio

### How discrete points are recorded:

<iframe width="560" height="315" src="//www.youtube.com/embed/uSESVm59uDQ?rel=0" frameborder="0" allowfullscreen></iframe>

### Plas.io

1. Concept: Lidar data measure elevation - plas.io, color by height map. NOTE: be sure to turn off intensity shading.
2. Concept: Lidar data can be CLASSIFIED to discriminate veg from ground from other objects.

## ### Three Common LiDAR Data Products ###
- [Digital Terrain Model](http://neonhighered.org/3dRasterLidar/DTM.html) - This product represents the ground.
- [Digital Surface Model](http://neonhighered.org/3dRasterLidar/DSM.html) - This represents the top of the surface (so imagine draping a sheet over the canopy of a forest).
- [Canopy Height Model](http://neonhighered.org/3dRasterLidar/CHM.html) - This represents the elevation of the Earth's surface - and it sometimes also called a DEM or digital elevation model.

<figure class="third">
    <a href="http://neonhighered.org/3d/SJER_DSM_3d.html"><img src="{{ site.baseurl }}/images/lidar/dsm.png"></a>
    <a href="http://neonhighered.org/3d/SJER_DTM_3d.html"><img src="{{ site.baseurl }}/images/lidar/dem.png"></a>
    <a href="http://neonhighered.org/3d/SJER_CHM_3d.html" target="_blank"><img src="{{ site.baseurl }}/images/lidar/chm.png"></a>
    
    <figcaption> 3d models of a: LEFT: lidar derived digital surface model (DSM) , MIDDLE: Digital Elevation Model (DEM) and RIGHT: Canopy Height Model (CHM). Click on the images to view interactive 3d models. </figcaption>
</figure>

 
## CHM vs InSitu Differences Differences

<iframe width="900" height="800" frameborder="0" scrolling="no" src="https://plot.ly/~leahawasser/24.embed"></iframe>

<iframe width="900" height="800" frameborder="0" scrolling="no" src="https://plot.ly/~leahawasser/153.embed"></iframe>


