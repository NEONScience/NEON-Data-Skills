---
layout: post
title:  "LiDAR Data, Activity 1 -- The Basics"
date:   2014-07-11 20:49:52
categories: [Working With LiDAR Data]
tags : [measuring vegetation,remote sensing, laser scanning]
description: "Learn the basics of how a LiDAR works and what a LiDAR system measures. Explore some LiDAR data using free online tools."

---


## Overview ##

LiDAR or **Li**ght **D**etection **a**nd **R**anging is an active remote sensing system that can be used to measure vegetation height across wide areas. This unit will introduce you to the fundamental concepts needed to understand:

1. What LiDAR data are 
2. The key attributes of LiDAR data
3. How LiDAR data are used to measure trees. 

In this unit, we will explore some LiDAR data using the freely available [plas.io website](http://plas.io) and the open souce, free to download QGIS software (A free GIS software package).


{% include _images.html url="/betaEducationModules/images/shrub.png" description="Look - Some Shrubbery! by Leah Wasser" %}

{% include _images.html url="/betaEducationModules/images/shrub.png" description="Look - Some Shrubbery! by Leah Wasser" %}

[url=https://flic.kr/p/o9bcE6][img]https://farm4.staticflickr.com/3913/14532371197_a17d52e010_s.jpg[/img][/url][url=https://flic.kr/p/o9bcE6]LiDAR data collected at the Soaproot Saddle site by the National Ecological Observatory Network Airborne Observation Platform (NEON AOP).[/url] by [url=https://www.flickr.com/people//]leahawasser[/url], on Flickr

<a href="https://www.flickr.com/photos/126239263@N04/14532371197" title="LiDAR data collected at the Soaproot Saddle site by the National Ecological Observatory Network Airborne Observation Platform (NEON AOP). by Leah Wasser, on Flickr"><img src="https://farm4.staticflickr.com/3913/14532371197_a17d52e010_s.jpg" width="75" height="75" alt="LiDAR data collected at the Soaproot Saddle site by the National Ecological Observatory Network Airborne Observation Platform (NEON AOP)."></a>

##Goals##
*	Understand how LiDAR systems work
*	Understand what LiDAR point clouds are

##Learning Objectives ##
*	Understand that LiDAR data provide elevation information using reflected laser energy.
*	Understand attributes of discrete LiDAR returns are
*	Understand what LiDAR point clouds look like
*	View attributes associated with points in QGIS.


##What to Do In Advance 

*   Watch: The Story of LiDAR Data Video on You Tube
*   Watch: How LiDAR works on youTube
*   [Install QGIS](http://www.qgis.org/en/site/): QGIS is a free to download and use GIS program! It works on both MAC and PC and can be used to work with geospatial data. 
*   Make sure you can access the [plas.io website](http://plas.io/).  


##The Story of LiDAR Data video - On YouTube
<iframe width="560" height="315" src="//www.youtube.com/embed/m7SXoFv6Sdc" frameborder="0" allowfullscreen></iframe>

##How LiDAR Works ##
<iframe width="560" height="315" src="//www.youtube.com/embed/m7SXoFv6Sdc" frameborder="0" allowfullscreen></iframe>


##Learning Outcomes
At the end of this activity, participants should: 

*	Explain how a LiDAR system works
*	List some key attributes of discrete return LiDAR data points
*	Explain how LiDAR data are used in science
*	Understand what LIDAR point clouds look like and know how to use the PLAS.Io viewer to explore LiDAR data las files.
*	Understand the basic formats that lIDAR data are available in.

#Let's Get To It!

##Introduction - Key Points to Review ##

### Why LiDAR ###

As ecologists, we often want to characterize vegetation over large regions. Because we don’t have the resources to measure each and every tree - we use tools that can estimate key characteristics over large areas. These tools often use remote methods - that is to say, we aren’t actually physically measuring things with our hands and eyes, we are using sensors which capture information about a landscape and record things that we can use to estimate conditions and characteristics.


{% include _images.html url="/minimal-mistakes/images/ScalingTrees_NatGeo.jpg" description="Conventional on the ground methods to measure trees are resource intensive and limit the amount of vegetation that can be characterized! Photo: National Geographic" %}

To measure vegetation across large areas we need remote sensing methods that can take many measurements, quickly using automated sensors. These measurements can than be used to estimate forest structure across larger areas. LiDAR, or light detection ranging (sometimes also referred to as active laser scanning) is one RS method that can be used to map vegetation height, density and other characteristics across a region.

### How Scientists Use LiDAR Data ##
There are many different uses for LiDAR data. 
- LiDAR data classically have been used to derive high resolution elevation data <image: low vs high resolution DEM>
- LiDAR data have also been used to derive information about vegetation structure including
	- Canopy Height
	- Canopy Cover 
	- Leaf Area Index
	- Vertical Forest Structure
	- Species identification (in less dense forests with high point density LiDAR)


### How A LiDAR System Works (video review) ##

LIDAR is an **active remote sensing** system. An active system means that the system itself generates energy - in this case light - to measure things on the ground. In a LiDAR system, light is emitted from a rapidly firing laser. You can imagine, light quickly strobing from a laser light source. This light travels to the ground and reflects off of things like buildings and tree branches. The reflected light energy then returns to the LiDAR sensor where it is recorded.


**ANIMATION SHOWING light traveling down and being recorded from powerpoint**

Now remember from the video that the LiDAR system times the travel of the light to the ground and back and that time is used to in turn calculate distance traveled. Distance traveled is then converted to elevation. Also remember that a LiDAR system contains a GPS and an IMU that help it accurately identify the location of reflected light energy, on the ground.

**Insert Animation -- LiDAR Returns **

> Active vs Passive Remote Sensing
> Active systems like LiDAR (and also radar) use their own energy source to sample the earth. In the case of the LiDAR system that source is a light emitted from a rapidly firing laser. A passive system measures existing energy that is emitted from the earth. For example a thermal sensor measures how much heat is emitted from an object - and that object might be heated by the sun. That heat was already there and is simply, **passively** measured by the instrument.
> IMAGE: *THERMAL REMOTE SENSING IMAGE vs LIDAR POINTS or something that shows active vs passive.*


##Digging Deeper - How LiDAR Works

We can think about light in terms of photons. As photons that make up light moves towards the ground, they hits different things - like say branches on a tree. Some of the light reflects off of those objects and returns to the sensor, if the object is small, some light continues down towards the ground. So, you can get multiple reflections from one pulse of light. The distribution of energy that returns to the sensor creates what we call a waveform and may have various peaks associated with it where larger amounts of energy reflected off of things. The peaks in the waveform often represent objects on the ground like - a branch, a group of leaves or a building. 

> ### About LiDAR Waveforms - It's All About the Photons!
> As light or photons travel to the ground, they reflect off of  objects on the ground, and travels back to the LiDAR sensor where they are recorded. The  reflected light energy that returns to the sensor returns as a waveform of energy - seen in the curve below. The areas where more photons or more light energy returns to the sensor are often objects like leaves and branches.
> {% include _images.html url="/minimal-mistakes/images/Waveform.PNG" description="An example LiDAR waveform. Image: National Ecological Observatory Network, Boulder, CO" %}
> 	**Image: photon joke - a Photon Walks in ao Hotel...??&**


### Discrete vs Full Waveform LiDAR ###
LiDAR data may be recorded in two ways.
1. A **Discrete Return LiDAR System** records individual (discrete) points for the peaks in the waveform curve. Discrete return LiDAR systems, identify peaks and record a point at each peak location in the waveform curve. These discrete or individual points are called returns. A discrete system may record 1-4 (and sometimes more) returns from each laser pulse.
2. A **Full Waveform LiDAR System** records a distribution of returned light energy. Full waveform LiDAR data are thus more complex to process however they can often capture more information compared to discrete return LiDAR systems.

##LiDAR File Formats **
* Whether it is collected as discrete points or full waveform, most often LiDAR data are available as discrete points. * Returns make up what is called a LiDAR point cloud.
* The commonly used file format to store LIDAR data is called .las developed by... <link to ASPRS>.

	
##	Activity 1 - Exploring Discrete Return LiDAR data Point Attributes
**need to think this through a bit more **
To complete activity 1, do the following
1. Open up the XXX file in QGIS
2. Use the attribute button to look at the attributes of each point noting that there are key elements: x,y,z and intensity. 
3. Note that there are some other attributes in this file including scan angle, intensity (amount of photons)
4. ???Could also mention that there are other key lidar attributes like return number, etc (all of this is in the ppt)


####QGIS -- Let’s Look at Some DATA
Discrete return LiDAR data just represent the peaks of returned energy. These are discrete points (hence the name). These points contain attributes including and x, y and z values. 

*	Option 1: Open the text file and  look at some values for individual points -- (note that there are other values stored in the las data… but these are the first key ones
*	Option 2: this option will be more about working with QGIS (if you wish to emphasize these skills). Converting a text file with lat longs to a point shapefile. Open QGIS and convert the XYZ values to an actual shapefile.
	
* Have the students bring in an image to see how the points related to on the ground conditions (ie you will be able to generally see where trees are even in the points as there will be more returns there).

** i think i should reconsider this activity because converting the points to a shapefile will be distracting... maybe that can be an advanced option...??**


### Activity Two - Exploring 3D LIDAR data in a free Online Viewer
1. View some LiDAR data in the [plas.io website](plas.io)   **<<-- need to make sure i credit Martin and his colleagues for this **
2. Talk about intensity
3. Talk about classification
4. Talk about what you can measure…looking at the data - have the students begin to guess at the types of things that this data may be used for...



## Wrapping Up -- 
###How LiDAR Data Are Used  ((this can be the last few minutes of the how LiDAR works video)
So as you can see from the 3d model you can begin to see the shapes of trees in the data. But also you can generally identify where the tops are. We can use this information to generate height values. We can also get creative with our processing and do things like look at the ratio between points above the ground and points that represent the ground to estimate things like canopy cover and leaf area index.
We’ll talk about that in more detail in later units.

##Summary
*	A LiDAR system uses a laser + a gps and IMU to estimate the heights of objects on the ground.
*	Discrete LiDAR data is generated from waveforms - and each point represent peak energy points along the returned energy.
*	Discrete LiDAR points contain an x, y and z value. the z value is what is used to generate height.
*	LiDAR data can be used to estimate tree height and even canopy cover using various methods.


----------
----------

## Assessment ##
1. Create a diagram that represents the key components of a LIDAR system.
2. What does a LiDAR system record. 
3. Explain in as few sentences as possible, what LIDAR intensity is. 
4. Draw an example LiDAR waveform. Label the X and Y Axis and note atleast one location where a lidar return might be recorded by a discrete return LiDAR system.


## Extra ##
 
have them create a shapefile in QGIS using a text file... very simple...

###Additional Resources:
*	What is the  [las file format](http://www.asprs.org/Committee "las file format: ")-*
*	General/LASer-LAS-File-Format-Exchange-Activities.html
*	What is Discrete Return lidar (ppt)
*	What is full waveform LiDAR (ppt)
*	[las: python ingest](http://laspy.readthedocs.org/en/latest/tut_background.html)
*	[las v1.3 specs](http://www.asprs.org/a/society/committees/standards/asprs_las_spec_v13.pdf)



## Check out our gallery on Flikr! ##




#THE END 

