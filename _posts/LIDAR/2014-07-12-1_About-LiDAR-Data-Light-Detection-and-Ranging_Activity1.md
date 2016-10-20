---
layout: post
title:  "The Basics of LiDAR - Light Detection and Ranging - Remote Sensing"
date:   2014-07-21
createdDate:   2014-07-21
lastModified:   2016-10-20
estimatedTime: 0.25 - .5 Hours
packagesLibraries:
categories: [self-paced-tutorial]
authors: [Leah A. Wasser]
tags : [lidar, R, remote-sensing]
mainTag: lidar
tutorialSeries: [intro-lidar-r-series]
description: "Explore the basics of how a LiDAR system works and what a LiDAR system measures."
image:
  feature: codedpoints2.png
  credit:
  creditlink:
comments: true
---

{% include _toc.html %}


LiDAR or **Li**ght **D**etection **a**nd **R**anging is an active remote sensing
 system that can be used to measure vegetation height across wide areas. This 
page will introduce fundamental lidar concepts including:

1. What LiDAR data are.
2. The key attributes of LiDAR data.
3. How LiDAR data are used to measure trees. 


<figure>
   <a href="https://farm4.staticflickr.com/3913/14532371197_a17d52e010.jpg">
   <img src="https://farm4.staticflickr.com/3913/14532371197_a17d52e010.jpg"></a>
   <figcaption>LiDAR data collected at the Soaproot Saddle site by the National 
Ecological Observatory Network Airborne Observation Platform (NEON AOP) - image 
available on <a href="https://flic.kr/s/aHsk4W4cdP" target="_blank"> Flickr</a>.  
   </figcaption>
</figure>


## LiDAR Background


### The Story of LiDAR Data video
<iframe width="560" height="315" src="//www.youtube.com/embed/m7SXoFv6Sdc?rel=0" frameborder="0" allowfullscreen></iframe>

### How LiDAR Works
<iframe width="560" height="315" src="//www.youtube.com/embed/EYbhNSUnIdU?rel=0" frameborder="0" allowfullscreen></iframe>


## Let's Get Started - Key Concepts to Review

### Why LiDAR

Scientists often need to characterize vegetation over large regions. We use 
tools that can estimate key characteristics over large areas because we don’t 
have the resources to measure each and every tree. These tools often use remote 
methods. Remote sensing means that we aren’t actually physically measuring 
things with our hands, we are using sensors which capture information about a 
landscape and record things that we can use to estimate conditions and 
characteristics.



<figure>
   <a href="{{ site.baseurl }}/images/lidar/ScalingTrees_NatGeo.jpg">
   <img src="{{ site.baseurl }}/images/lidar/ScalingTrees_NatGeo.jpg"></a>
   <figcaption>Conventional on the ground methods to measure trees are resource 
   intensive and limit the amount of vegetation that can be characterized! Source: 
   National Geographic
   </figcaption>
</figure>


To measure vegetation across large areas we need remote sensing methods that can
take many measurements, quickly using automated sensors. These measurements can
be used to estimate forest structure across larger areas. LiDAR, or light 
detection ranging (sometimes also referred to as active laser scanning) is one
remote sensing method that can be used to map structure including vegetation 
height, density and other characteristics across a region. LiDAR directly 
measures the height and density of vegetation on the ground making it an ideal 
tool for scientists studying vegetation over large areas.

### How LiDAR Works

LIDAR is an **active remote sensing** system. An active system means that the 
system itself generates energy - in this case light - to measure things on the 
ground. In a LiDAR system, light is emitted from a rapidly firing laser. You can 
imagine, light quickly strobing from a laser light source. This light travels 
to the ground and reflects off of things like buildings and tree branches. The 
reflected light energy then returns to the LiDAR sensor where it is recorded.


A LiDAR system measures the time it takes for emitted light to travel  to the 
ground and back. That time is used to calculate distance traveled. Distance 
traveled is then converted to elevation. These measurements are made using the 
key components of a lidar system including a GPS that identifies the X,Y,Z 
location of the light energy and an Internal Measurement Unit (IMU) that 
provides the orientation of the plane in the sky.

<iframe width="560" height="315" src="//www.youtube.com/embed/uSESVm59uDQ?rel=0" frameborder="0" allowfullscreen></iframe>


### How Light Energy Is Used to Measure Trees

Light energy is a collection of photons. As photon that make up light moves 
towards the ground, they hit objects such as branches on a tree. Some of the 
light reflects off of those objects and returns to the sensor. If the object is 
small, and there are gaps surrounding it that allow light to pass through, some 
light continues down towards the ground. Because some photons reflect off of 
things like branches but others continue down towards the ground, multiple 
reflections may be recorded from one pulse of light. 

The distribution of energy that returns to the sensor creates what we call a 
waveform. The amount of energy that returned to the LiDAR sensor is known as 
"intensity". The areas where more photons or more light energy returns to the 
sensor create peaks in the distribution of energy. Theses peaks in the waveform 
often represent objects on the ground like - a branch, a group of leaves or a 
building. 


<figure>
   <a href="{{ site.baseurl }}/images/lidar/Waveform.PNG">
   <img src="{{ site.baseurl }}/images/lidar/Waveform.PNG"></a>
   <figcaption>An example LiDAR waveform. Source: National Ecological 
   Observatory Network, Boulder, CO - image 
available on <a href="https://flic.kr/s/aHsk4W4cdP" target="_blank"> Flickr</a>.
   </figcaption>
</figure>


## How Scientists Use LiDAR Data
There are many different uses for LiDAR data. 

- LiDAR data classically have been used to derive high resolution elevation data

<figure>
   <a href="{{ site.baseurl }}/images/lidar/HighRes.png">
   <img src="{{ site.baseurl }}/images/lidar/HighRes.png"></a>
   <figcaption>LiDAR data have historically been used to generate high 
   resolution elevation datasets. Source: National Ecological Observatory 
   Network - image 
   available on <a href="https://flic.kr/s/aHsk4W4cdP" target="_blank"> Flickr</a>.
   </figcaption>
</figure>

- LiDAR data have also been used to derive information about vegetation 
structure including
	- Canopy Height
	- Canopy Cover 
	- Leaf Area Index
	- Vertical Forest Structure
	- Species identification (in less dense forests with high point density LiDAR)


<figure>
   <a href="{{ site.baseurl }}/images/lidar/Treeline_ScannedPoints.png">
   <img src="{{ site.baseurl }}/images/lidar/Treeline_ScannedPoints.png"></a>
   <figcaption>Cross section showing LiDAR point cloud data (above) and the 
   corresponding landscape profile (below). Source: National Ecological Observatory 
   Network - image 
   available on <a href="https://flic.kr/s/aHsk4W4cdP" target="_blank"> Flickr</a>.
   </figcaption>
</figure>


## Discrete vs. Full Waveform LiDAR
A waveform or distribution of light energy is what returns to the LiDAR sensor. 
However, this return may be recorded in two different ways.

1. A **Discrete Return LiDAR System** records individual (discrete) points for 
the peaks in the waveform curve. Discrete return LiDAR systems, identify peaks 
and record a point at each peak location in the waveform curve. These discrete 
or individual points are called returns. A discrete system may record 1-4 (and 
sometimes more) returns from each laser pulse.
2. A **Full Waveform LiDAR System** records a distribution of returned light 
energy. Full waveform LiDAR data are thus more complex to process however they 
can often capture more information compared to discrete return LiDAR systems.

## LiDAR File Formats
Whether it is collected as discrete points or full waveform, most often LiDAR 
data are available as discrete points. A collection of discrete return LiDAR 
points is known as a LiDAR point cloud.

The commonly used file format to store LIDAR point cloud data is called .las 
which is a format supported by the Americal Society of Photogrammetry and Remote 
Sensing (ASPRS). Recently, the [.laz](http://www.laszip.org/) format has been 
developed by Martin Isenberg of LasTools. The differences is that .laz is a 
highly compressed version of .las.

### LiDAR Data Attributes: X,Y, Z, Intensity and Classification
LiDAR data attributes can vary, depending upon how the data were collected and 
processed. You can determine what attributes are available for each lidar point 
by looking at the metadata. All lidar data points will have an associated X,Y 
location and Z (elevation values). Most lidar data points will have an intensity 
value, representing the amount of light energy recorded by the sensor.

Some LiDAR data will also be "classified" -- not top secret, but with specifications
about what the date are. Classification of LiDAR point clouds is an additional 
processing step. Classification simply represents the type of object that the 
laser return reflected off of. So if the light energy reflected off of a tree, 
it might be classified as "vegetation". And if it reflected off of the ground, 
it might be classified as "ground".

Some LiDAR products will be classified as "ground/non ground". Some datasets 
will be further processed to determine which points reflected off of buildings 
and other infrastructure. Some LiDAR data will be classified according to the 
vegetation type.   


## Exploring 3D LiDAR data in a free Online Viewer
[Check out our activity that uses a free online LiDAR data viewer to view NEON LiDAR data!](http://neondataskills.org/lidar-data/online-data-viewer/). 
The Plas.io viewer used in this activity was developed by Martin Isenberg of 
Las Tools and his colleagues.


## Summary

*	A LiDAR system uses a laser, a GPS and an IMU to estimate the heights of 
objects on the ground.
*	Discrete LiDAR data is generated from waveforms -- each point represent 
peak energy points along the returned energy.
*	Discrete LiDAR points contain an x, y and z value. The z value is what is 
used to generate height.
*	LiDAR data can be used to estimate tree height and even canopy cover using 
various methods.


----------


## Additional Resources

*	What is the [las file format](http://www.asprs.org/committee-general/laser-las-file-format-exchange-activities.html "las file format: ")?
*	Using .las with Python? [las: python ingest](http://laspy.readthedocs.org/en/latest/tut_background.html)
*	Specifications for [las v1.3](http://www.asprs.org/a/society/committees/standards/asprs_las_spec_v13.pdf)

