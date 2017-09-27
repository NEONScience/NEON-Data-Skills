---
syncID: 8e3b475ba47d407dae623ddadb0924fe
title:  "Plas.io: Free Online Data Viz to Explore LiDAR Data" 
description: "Learn about LiDAR point cloud file formats .las and .laz. Explore LiDAR point cloud data using the free, online Plas.io viewer ."
dateCreated:   2014-07-21 
authors: Leah A. Wasser
contributors:
estimatedTime: 0.25 - 0.5 Hours
packagesLibraries:
topics: lidar, remote-sensing, data-viz
languagesTool: plasio
dataProduct:
code1:
tutorialSeries: [intro-lidar-r-series]
urlTitle: plasio-view-pointclouds
---

In this tutorial, we will explore LiDAR point cloud data using the free, online 
<a href="http://plas.io" target="_blank"> Plas.io viewer</a>. 

<div id="ds-objectives" markdown="1">

## Learning Objectives
At the end of this tutorial, you will be able to: 

* visualize lidar point clouding using the free online data viewer plas.io
* describe some of the attributes associated with discrete return lidar points, including 
intensity, classification and RGB values.
* explain the use of and difference between the .las and .laz lidar file formats 
(standard lidar point cloud formats).

## Things You’ll Need To Complete This Tutorial

* Access to the internet so you can access the 
<a href="http://plas.io" target="_blank"> plas.io website.</a>

### Download Data

{% include/dataSubsets/_data_Sample-LiDAR-Point-Cloud.html %}

</div>

#### Example visualization of LiDAR data 

 <figure>
	<a href="{{ site.baseurl }}/images/lidar/biomass.png">
	<img src="{{ site.baseurl }}/images/lidar/biomass.png"></a>
	<figcaption> LiDAR data collected over Grand Mesa, Colorado as a part of 
	instrument testing and calibration by the National Ecological Observatory Network 
	Airborne Observation Platform (NEON AOP).
	Source: National Ecological Observatory Network (NEON)  
	</figcaption>
</figure>

## LiDAR File Formats
LiDAR data are most often available as discrete points. Although, remember that these data 
can be collected by the lidar instrument, in either discrete or full waveform, formats. 
A collection of discrete return LiDAR points is known as a LiDAR point cloud.

".las" is the commonly used file format to store LIDAR point cloud data. This 
format is supported by the 
<a href="http://www.asprs.org/" target="_blank"> American Society of Photogrammetry and Remote sensing (ASPRS)</a>. 
Recently, the 
<a href="http://www.laszip.org/" target="_blank">.laz</a> 
format has been developed by Martin Isenberg of LasTools. Laz is a highly 
compressed version of .las.

In this tutorial, you will open a .las file, in the plas.io free online lidar 
data viewer. You will then explore some of the attributes associated with a 
lidar data point cloud.

## LiDAR Attribute Data 
Remember that not all lidar data are created equally. Different lidar data may
have different attributes. In this tutorial, we will look at data that contain 
both intensity values and a ground vs non ground classification.


## Plas.io Viewer
We will use the 
<a href="http://plas.io" target="_blank"> plas.io website.</a> 
in this tutorial. As described on their 
<a href="https://github.com/verma/plasio" target="_blank">plas.io github page</a>:

> Plasio is a project by Uday Verma and Howard Butler that implements point cloud 
rendering capability in a browser. Specifically, it provides a functional 
implementation of the ASPRS LAS format, and it can consume LASzip-compressed 
data using LASzip NaCl module. Plasio is Chrome-only at this time, but it is 
hoped that other contributors can step forward to bring it to other browsers.
> 
> It is expected that most WebGL-capable browers should be able to support 
plasio, and it contains nothing that is explicitly Chrome-specific beyond the 
optional NaCL LASzip module. 

This tool is useful because you don't need to install anything to use it! Drag 
and drop your lidar data directly into the tool and begin to play! The website 
also provides access to some prepackaged datasets if you want to experiment on 
your own.

Enough reading, let's open some NEON LiDAR data!
 
### 1. Open a .las file in plas.io

1. Download the NEON prepackaged lidar dataset (above in **Download the Data**) 
if you haven't already.
2. The file is named: `NEON-DS-Sample-LiDAR-Point-Cloud.las`
2. When the download is complete, drag the file `NEON-DS-Sample-LiDAR-Point-Cloud.las` 
into the <a href="http://plas.io" target="_blank"> plas.io website.</a> window.
3. Zoom and pan around the data
4. Use the particle size slider to adjust the size of each individual lidar point. 
NOTE: the particle size slider is located a little more than half way down the 
plas.io toolbar in the "Data" section.

NICE! You should see something similar to the screenshot below:

<figure>
	<a href="{{ site.baseurl }}/images/lidar/plasio_dataImport.png">
	<img src="{{ site.baseurl }}/images/lidar/plasio_dataImport.png"></a>
	<figcaption> NEON lidar data in the plas.io online tool. 
	</figcaption>
</figure>

#### Navigation in Plas.io
You might prefer to use a mouse to explore your data in plas.io. Let's test the navigation out.

1. Left click on the screen and drag the data on the screen. Notice that this tilts the data up and down.
2. Right click on the screen and drag noticing that this moves the entire dataset around
3. Use the scroll bar on your mouse to zoom in and out. 

#### How The Points are Colored

Why is everything grey when the data are loaded? 

Notice that the data, upon initial view, are colored in a black - white color 
scheme. These colors represent the data's intensity values. Remember that the 
intensity value, for each LiDAR point, represents the amount of light energy 
that reflected off of an object and returned to the sensor. In this case, darker 
colors represent LESS light energy returned. Lighter colors represent MORE light 
returned.


 <figure>
	<a href="{{ site.baseurl }}/images/lidar/Lidar_Intensity.jpg">
	<img src="{{ site.baseurl }}/images/lidar/Lidar_Intensity.jpg"></a>
	<figcaption> Lidar intensity values represent the amount of light energy that
	reflected off of an object and returned to the sensor. 
	</figcaption>
</figure>


### 2. Adjust the intensity threshold

Next, scroll down through the tools in plas.io. Look for the Intensity Scaling 
slider. The intensity scaling slider allows you to define the thresholds of 
light to dark intensity values displayed in the image (similar to stretching 
values in an image processing software or even in Photoshop).

Drag the slider back and forth. Notice that you can brighten up the data using the slider.

<figure>
	<a href="{{ site.baseurl }}/images/lidar/intensitySlider.png">
	<img src="{{ site.baseurl }}/images/lidar/intensitySlider.png"></a>
	<figcaption> The intensity scaling slider is located below the color map 
tool so it's easy to miss. Drag the slider back and forth to adjust the range 
of intensity values and to brighten up the lidar point clouds.
	</figcaption>
</figure>


### 3. Change the lidar point cloud color options to Classification

In addition to intensity values, these lidar data also have a classification 
value. Lidar data classification values are numeric, ranging from 0-20 or 
higher. Some common classes include:

- 0 Not classified
- 1 Unassigned
- 2 Ground
- 3 Low vegetation
- 4 Medium vegetation
- 5 High Vegetation
- 6 Building

<figure>
	<a href="{{ site.baseurl }}/images/lidar/plasio_ColorScheme_KendraSand.png">
	<img src="{{ site.baseurl }}/images/lidar/plasio_ColorScheme_KendraSand.png"></a>
	<figcaption> Blue and Orange gradient color scheme submitted by Kendra Sand.
	What color scheme is your favorite?
	</figcaption>
</figure>

In this case, these data are classified as either ground, or non-ground. To 
view the points, colored by class:

- Change the "colorization" setting to "Classification
- Change the intensity blending slider to "All Color" 
- For kicks - play with the various colormap options to change the colors of the points.

<figure>
	<a href="{{ site.baseurl }}/images/lidar/classification_Colorization2.png">
	<img src="{{ site.baseurl }}/images/lidar/classification_Colorization2.png"></a>
	<figcaption> Set the colorization to 'classified' and then adjust the 
	intensity blending to view the points, colored by ground and non-ground classification.
	</figcaption>
</figure>


### 4. Spend Some Time Exploring - Do you See Any Trees?
Finally, spend some time exploring the data. what features do you see in this 
dataset? What does the topography look like? Is the site flat? Hilly? 
Mountainous? What do the lidar data tell you, just upon initial inspection?

## Summary

* The plas.io online point cloud viewer allows you to quickly view and explore 
lidar data point clouds.
* Each lidar data point will have an associated set of attributes. You can 
check the metadata to determine which attributes the dataset contains. 
NEON data, provided above, contain both classification and intensity values. 
* Classification values represent the type of object that the light energy 
reflected off of. Classification values are often ground vs non ground. Some 
lidar data files might have buildings, water bodies and other natural and man 
made elements classified.
* LiDAR data often has an intensity value associated with it. This represents 
the amount of light energy that reflected off an object and returned to the sensor. 

***

## Additional Resources:

*	<a href="http://laspy.readthedocs.org/en/latest/tut_background.html" target="_blank"> What is .las? From laspy - the las Python library</a>
*	<a href="http://www.asprs.org/a/society/committees/standards/asprs_las_spec_v13.pdf" target="_blank"> las v1.3 specifications</a>

