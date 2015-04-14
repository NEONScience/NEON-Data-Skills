---
layout: post
title:  "Activity: Free Online Data Viz to Explore LiDAR Data"
date:   2014-7-19 11:00:52
createdDate:   2014-07-21 20:49:52
lastModified:   2015-1-06 22:33:52
estimatedTime: 0.25 - 0.5 Hours
packagesLibraries: plas.io website
category: remote-sensing
categories: [Remote Sensing]
tags : [lidar]
authors: leah a wasser
description: "Learn the basics of how a LiDAR works and what a LiDAR system measures. Explore some LiDAR data using free online tools."
image:
  feature: lidar_GrandMesa.png
  credit: LiDAR data collected over Grand Mesa, Colorado - National Ecological Observatory Network (NEON)
  creditlink: http://www.neoninc.org
comments: true
---


## Overview ##

In this activity, we will explore lidar data point clouds and learn:

1. How to visualize lidar point clouding using a free online data viewer 
2. About some of the attributes associated with discrete return lidar points including intensity, classification and RGB values.
3. About the .las and .laz lidar file formats (standard lidar point cloud formats).

## What you Need  ##
1. Access to the internet so you can  the <a href="http://plas.io" target="_blank"> plas.io website.</a>
2. Your very own, sparking personality.
3. Download lidar data collected by NEON AOP (National ecological observatory network, airborne observation platform). <a href="http://www.neonhighered.org/Data/LidarActivity/r_filtered_256000_4111000.las" class="btn btn-success"> DOWNLOAD Sample NEON LiDAR Point Cloud Data</a>

{% include _images.html url="https://farm4.staticflickr.com/3932/15408420007_3176835b51.jpg" description="LiDAR data collected over Grand Mesa, Colorado as a part of instrument testing and calibration by the National Ecological Observatory Network Airborne Observation Platform (NEON AOP)." link="https://www.flickr.com/photos/128087132@N06/sets/72157648481541867/" %}

##Quick Review -- LiDAR File Formats
LiDAR data are most often available as discrete points. Although, remember that these data can be collected by the lidar instrument, in either discrete or full waveform, formats. A collection of discrete return LiDAR points is known as a LiDAR point cloud.

".las" is the commonly used file format to store LIDAR point cloud data. This format is supported by the <a href="http://www.asprs.org/" target="_blank"> American Society of Photogrammetry and Remote sensing (ASPRS)</a>. Recently, the <a href="http://www.laszip.org/" target="_blank">.laz</a> format has been  developed by Martin Isenberg of LasTools. Laz is a highly compressed version of .las.

In this activity, you will open a .las file, in the plas.io free online lidar data viewer. You will then explore some of the attributes associated with a lidar data point cloud.

###LiDAR Attribute Data 
Remember that not all lidar data are created equally. Different lidar data may have different attributes. In this activity, we will look at data that contain both intensity values and a ground vs non ground classification.


## Key Review Concepts ##
We will use the <a href="http://plas.io" target="_blank"> plas.io website.</a> in this activity. As described on their  <a href="https://github.com/verma/plasio" target="_blank">plas.io github page</a>:

> Plasio is a project by Uday Verma and Howard Butler that implements point cloud rendering capability in a browser. Specifically, it provides a functional implementation of the ASPRS LAS format, and it can consume LASzip-compressed data using LASzip NaCl module. Plasio is Chrome-only at this time, but it is hoped that other contributors can step forward to bring it to other browsers.
> 
> It is expected that most WebGL-capable browers should be able to support plasio, and it contains nothing that is explicitly Chrome-specific beyond the optional NaCL LASzip module. 

This tool is useful because you don't need to install anything to use it! Drag and drop your lidar data directly into the tool and begin to play! The website also provides access to some prepackaged datasets if you want to experiment on your own.

Enough reading, let's open some NEON LiDAR data!
 
## 1. Open a .las file in plas.io ###

1. Download the NEON prepackaged lidar dataset [-->RIGHT CLICK Here to download<--](http://www.neoninc.org/NEONedu/Data/LidarActivity/data.htm "SAMPLE NEON LiDAR Data") if you haven't already.
2. The file is named: r_filtered_256000_4111000.las 
2. When the download is complete, drag the file r_filtered_256000_4111000.las into the <a href="http://plas.io" target="_blank"> plas.io website.</a> window.
3. Zoom and pan around the data
4. Use the particle size slider to adjust the size of each individual lidar point. NOTE: the particle size slider is located a little more than half way down the plas.io toolbar in the "Data" section.

NICE! You should see something similar to the screenshot below:

{% include _images_nolink.html url="../../images/plasio_dataImport.png" description="NEON lidar data in the plas.io online tool." %}

### Navigation Around Your Data in Plas.io
You might prefer to use a mouse to explore your data in plas.io. Let's test the navigation out.

1. Left click on the screen and drag the data on the screen. Notice that this tilts the data up and down.
2. Right click on the screen and drag noticing that this moves the entire dataset around
3. Use the scroll bar on your mouse to zoom in and out. 

###How The Points are Colored - Why is everything grey when the data are loaded? 
Notice that the data, upon initial view, are colored in a black - white color scheme. These colors represent the data's intensity values. Remember that the intensity value, for each LiDAR point, represents the amount of light energy that reflected off of an object and returned to the sensor. In this case, darker colors represent LESS light energy returned. Lighter colors represent MORE light returned.

{% include _images_nolink.html url="../../images/Lidar_Intensity.png" description="Lidar intensity values represent the amount of light energy that reflected off of an object and returned to the sensor." %}


## 2. Adjust the intensity threshold

Next, scroll down through the tools in plas.io. Look for the Intensity Scaling slider. The intensity scaling slider allows you to define the thresholds of light to dark intensity values displayed in the image (similar to stretching values in an image processing software or even in photoshop).

Drag the slider back and forth. Notice that you can brighten up the data using the slider.

{% include _images_nolink.html url="../../images/intensitySlider.png" description="The intensity scaling slider is located below the color map tool so it's easy to miss. Drag the slider back and forth to adjust the range of intensity values and to brighten up the lidar point clouds." %}

## 3. Change the lidar point cloud color options to Classification

In addition to intensity values, these lidar data also have a classification value. Lidar data classification values are numeric, ranging from 0-20 or higher. Some common classes include:

- 0 Not classified
- 1 Unassigned
- 2 Ground
- 3 Low vegetation
- 4 Medium vegetation
- 5 High Vegetation
- 6 Building

{% include _images_nolink.html url="../../images/plasio_ColorsKendra.png" description="Blue and Orange gradient color scheme submitted by Kendra Sand. Which color scheme is your favorite? email screenshots to: lwasser at neoninc.org" %}

In this case, these data are classified as either ground, or non-ground. To view the points, colored by class:

- Change the "colorization" setting to "Classification
- Change the intensity blending slider to "All Color" 
- For kicks - play with the various colormap options to change the colors of the points.

{% include _images_nolink.html url="../../images/classification_Colorization2.png" description="Set the colorization to 'classified' and then adjust the intensity blending to view the points, colored by ground and non-ground classification." %}

## 4. Spend Some Time Exploring - Do you See Any Trees?
Finally, spend some time exploring the data. what features do you see in this dataset? What does the topography look like? Is the site flat? Hilly? Mountainous? What do the lidar data tell you, just upon initial inspection?

##Summary
*	The plas.io online point cloud viewer allows you to quickly view and explore lidar data point clouds.
*	Each lidar data point will have an associated set of attributes. You can check the metadata to determine which attributes the dataset contains. NEON data, provided above, contain both classification and intensity values. 
*	Classification values represent the type of object that the light energy reflected off of. Classification values are often ground vs non ground. Some lidar data files might have buildings, water bodies and other natural and man made elements classified.
*	LiDAR data often has an intensity value associated with it. This represents the amount of light energy that reflected off an object and returned to the sensor. 


----------
----------


###Additional Resources:
*	What is the <a href="http://www.asprs.org/Committee" target="_blank"> las file format</a>?
*	<a href="http://laspy.readthedocs.org/en/latest/tut_background.html" target="_blank"> Las: python ingest</a>
*	<a href="http://www.asprs.org/a/society/committees/standards/asprs_las_spec_v13.pdf" target="_blank"> las v1.3 specifications</a>


## Use Images From The LiDAR Data Image Gallery In Your Presentations & Teaching! ##


<iframe width="100%" height="500px" frameborder="0" scrolling="no" src="http://flickrit.com/slideshowholder.php?height=75&size=big&setId=72157648481541867&caption=true&theme=1&thumbnails=1&transition=1&layoutType=responsive&sort=0" ></iframe>



#THE END 

