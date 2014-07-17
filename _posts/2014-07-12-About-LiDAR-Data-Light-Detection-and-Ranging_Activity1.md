---
layout: post
title:  "LiDAR Data, Activity 1 -- The Basics"
date:   2014-07-11 20:49:52
categories: [Working With LiDAR Data]
tags : [measuring vegetation,remote sensing, laser scanning]
description: "Learn the basics of how a LiDAR system operates, how Lidar
data are used in science and explore some free lidar data analysis tools. Awesome!"

---

<div class="clients" markdown="1"> **Markdown text** </div>

## Overview ##

LiDAR or **Li**ght **D**etection **a**nd **R**anging is an active remote sensing system that can be used to measure vegetation height across wide areas. This unit will introduce you to the fundamental concepts needed to understand:

1. What LiDAR data are 
2. The key attributes of LiDAR data
3. How they are used to measure trees. 

In this unit, we will explore some LiDAR data using the freely available plas.io website and optionally, QGIS (open GIS software).


{% include _images.html url="/betaEducationModules/images/shrub.png" description="Look - Some Shrubbery! by Leah Wasser" %}

##Goals#
*	Understand LiDAR as a key tool to measure vegetation over large areas

##Learning Objectives
*	Understand that LiDAR data provide elevation information using reflected laser energy.
*	Understand what discrete LiDAR returns are
*	Understand what LiDAR data look like


##What to Do In Advance 

*   Watch: The Story of LiDAR Data Video on You Tube
*   Watch: How LiDAR works
*   [Install QGIS](http://www.qgis.org/en/site/): QGIS is a free gis program! it works on both MAC and PC and can be used to work with geospatial data. 
*   Make sure you can access the [plas.io website](http://plas.io/).  


##The Story of LiDAR Data video - On YouTube
<iframe width="560" height="315" src="//www.youtube.com/embed/m7SXoFv6Sdc" frameborder="0" allowfullscreen></iframe>

##How LiDAR Works ##



##Learning Outcomes
At the end of this activity, participants should be able to: 

*	Explain how a LiDAR system works
*	Provide some key attributes of discrete return LiDAR data points
*	Explain how LiDAR data are used in science
*	

#Let's Get To It!

##Introduction - Key Points to Review

*	As ecologists, we often want to characterize vegetation over large regions. Because we don’t have the resources to measure each and every tree - we use tools that can estimate key characteristics over large areas. These tools often use remote methods - that is to say, we aren’t actually physically measuring things with our hands and eyes, we are using sensors which capture information about a landscape and record things that we can use to estimate conditions and characteristics.
*	lidar is one RS method that can be used to map vegetation height, density and other characteristics across a region

##How A LiDAR System Works (video review)
*	So a few key concepts -- lidar is an active remote sensing system. this just means that the system itself generates energy - in this case light - to measure things on the ground. A passive system measures existing energy - for example a thermal sensor measures how much heat is emitted from an object. That heat was already there and is simply, passively measured.
*	The way a lidar works is that light is emitted from a rapidly firing laser… so imagine light quickly strobing from a light source… it travels to the ground and reflects off of things. energy that is reflected returns to the lidar sensor and is recorded.
*	Now remember from the video that the lidar system times the travel of the light to the ground and back and that time is used to in turn calculate distance traveled. Distance traveled is then converted to elevation. And that a lidar also contains a GPS and an IMU that help it accurately identify the location of reflected light energy, on the ground.

##Digging Deeper - How LiDAR Works


> Instructor Note: EXPLAIN A WAVEFORM PLOT and how this plot relates to energy returned to the sensor.


*	Now let’s think about light travel. As the light moves towards the ground, it hits different things - like say branches on a tree… Some of the light reflects off of those objects and returns to the sensor, if the object is small, some light continues down towards the ground. So, you can get multiple reflections from one pulse of light. 
*	The distribution of energy that returns to the sensor looks something like this (waveform) and may have various peaks associated with it where larger amounts of energy reflected off of things.
*	These peaks likely represent objects on the ground like - a branch, a group of leaves, a building… etc
*	The most common thing to do with this energy curve is to identify peaks and record a point at each peak location. These discrete or individual points are called returns. 
*	Returns make up what is called a LiDAR point cloud.
*	This type of LiDAR data are called “Discrete Return LiDAR Data”
	
	
##	Activity One - Discrete Return LiDAR data are Points
> Notes: Have the students open up some points <filein QGIS. use the attribute button to look at the attributes of each point noting that there are key elements: x,y,z and intensity. Could also mention that there are other key lidar attributes like return number, etc (all of this is in the ppt)


####QGIS -- Let’s Look at Some DATA
Discrete return LiDAR data just represent the peaks of returned energy. These are discrete points (hence hte name). These points contain attributes including and x, y and z values. 

*	Option 1: Open the text file and  look at some values for individual points -- (note that there are other values stored in the las data… but these are the first key ones
*	Option 2: this option will be more about working with QGIS (if you wish to emphasize these skills). Converting a text file with lat longs to a point shapefile. Open QGIS and convert the XYZ values to an actual shapefile…
	
* Have the students bring in an image to see how the points related to on the ground conditions (ie you will be able to generally see where trees are even in the points as there will be more returns there).



### Activity Two - LiDAR data are 3d Points


1. View some LiDAR data in the [plas.io website](plas.io)
2. Talk about intensity
3. Talk about classification
4. Talk about what you can measure…looking at the data - have the students begin to guess at the types of things that this data may be used for...


## Wrapping Up -- 
###How LiDAR Data Are Used  ((this can be the last few minutes of the how LiDAR works video)
So as you can see from the 3d model you can begin to see the shapes of trees in the data. But also you can generally identify where the tops are. We can use this information to generate height values
We can also get creative with our processing and do things like look at the ratio between points above the ground and points that represent the ground to estimate things like canopy cover and leaf area index.
We’ll talk about that in more detail in the next unit.

##Summary
*	A LiDAR system uses a laser + a gps and IMU to estimate the heights of objects on the ground.
*	Discrete LiDAR data is generated from waveforms - and each point represent peak energy points along the returned energy.
*	Discrete LiDAR points contain an x, y and z value. the z value is what is used to generate height.
*	LiDAR data can be used to estimate tree height and even canopy cover using various methods.

###Additional Resources:
*	What is the  [las file format](http://www.asprs.org/Committee "las file format: ")-*
*	General/LASer-LAS-File-Format-Exchange-Activities.html
*	What is Discrete Return lidar (ppt)
*	What is full waveform LiDAR (ppt)
*	[las: python ingest](http://laspy.readthedocs.org/en/latest/tut_background.html)
*	[las v1.3 specs](http://www.asprs.org/a/society/committees/standards/asprs_las_spec_v13.pdf)

#THE END 

