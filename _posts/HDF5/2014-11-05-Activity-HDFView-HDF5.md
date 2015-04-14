---
layout: post
title: "HDFView: Exploring HDF5 Files in the Free HDFview Tool"
date:   2015-1-30 20:49:52
lastModified:   2015-1-10 20:49:52
createdDate:   2014-11-19 20:49:52
estimatedTime: 0.25 - 0.5 Hours
packagesLibraries: HDFview
authors: Leah A. Wasser
categories: [coding-and-informatics]
category: coding-and-informatics
tags: [HDF5]
mainTag: HDF5
description: "Explore HDF5 files and the groups and datasets contained within, using the free HDFview tool. See how HDF5 files can be structured and explore metadata. Explore both spatial and temporal data stored in HDF5!"
code1: 
image:
  feature: hierarchy_folder_green.png
  credit: Colin Williams NEON, Inc.
  creditlink: http://www.neoninc.org
permalink: /HDF5/Exploring-Data-HDFView
---
<section id="table-of-contents" class="toc">
  <header>
    <h3>Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->


<div id="objectives">
<h3>Learning Goals</h3>
After completing this activity, you will:
<ol>
<li>Understand how data can be structured and stored in HDF5.</li>
<li>Understand how metadata can be added to an HDF5 file, making it "self describing"</li>
<li>Know how to explore HDF5 files using the free HDF Viewer</li>
</ol>

<h3>What you'll Need</h3>
<ul>
<li>Install the [free HDFview application](http://www.hdfgroup.org/products/java/hdfview/). This application will allow you to explore the contents of an HDF5 file easily. <a href="http://www.hdfgroup.org/products/java/release/download.html" target="_blank">Click HERE to go to the download page. </a></li>
<li>Data: <a href="{{ site.baseurl }}/data/NEON_TowerDataD3_D10.hdf5" class="btn">Download the National Ecological Observatory Network (NEON) Flux Tower Temperature data HERE.</a> </li>
<li>Download the <a href="http://neonhighered.org/Data/HDF5/SJER_140123_chip.h5">NEON Airborne Observation Platform Spectrometer Data HDF5 File.</a> NOTE that this second file has an ".h5" extension while the first has an HDF5 extension. Both extensions represent the HDF5 data type.</li>
</ul>
</div>

###About Installing HDFView
Select the HDFView download option that matches the operating system and computer setup (32 bit vs 64 bit) that you have. Also *don't* click on the "(MDF)" link. Click on the operating system name (ie Windows or Mac for java 1.7).

<figure>
    <a href="{{ site.baseurl }}/images/HDF5View_Install.png">
    <img src="{{ site.baseurl }}/images/HDF5View_Install.png"></a>
    <figcaption>HDFview download options. Click on the operating system name (not the MDF link) to access install files.</figcaption>
</figure>

##Review: Hierarchical Data Format 5 - HDF5

We learned previously that the Hierarchical Data Format version 5 (HDF5), is an open file format that supports large, complex, heterogeneous data. Some key points about HDF5:

-  HDF5 uses a "file directory" like structure. The HDF5 data models organizes information using `Groups`. Each group may contain one or more `datasets`.
-  HDF5 is a self describing file format. This means that the metadata for the data contained within the HDF5 file, are built into the file itself.
-  One HDF5 file may contain several heterogeneous data types (e.g. images, numeric data, data stored as strings) 


##About This Activity - 
In this activity, we will explore two different types of data, saved in HDF5. This will allow us to better understand how one file can store multiple different types of data, in different ways.

#Part 1. Exploring Temperature Data in HDF5 Format in HDFView

The first thing that we will do is open an HDF5 file in the viewer to get a better idea of how HDF5 files can be structured.

- To begin, open the HDFView application.
- Within the HDFView application, select File --> Open and navigate to the folder where you saved the fiuTestFile.hdf5 file on your computer. Open this file in HDFView.
- If you click on the NAME of the HDF5 file in the left hand window of HDFView, you can view metadata for the file (located in the bottom window of the application).


<figure>
    <a href="{{ site.baseurl }}/images/HDf5/OpenFIU.png"><img src="{{ site.baseurl }}/images/HDf5/OpenFIU.png"></a>
    <figcaption>If you click on the file name wtihin the viewer, you can view any stored metadata for that file, at the bottom of the viewer. (you may have to click on the metadata tab at the bottom of the viewer)</figcaption>
</figure>

- Next, explore the structure of this file. Notice that there are two Groups (represented as folder icons in the viewer) called "Domain_03" and "Domain_10". Within each domain group, there site groups (NEON sites that are located within those domains). Expand these folders by double clicking on the folder icons. Double clicking "expands" the groups content just as you might expand a folder in windows explorer.

Notice that there is metadata associated with each group.

- Double click on the "ORD" group located within the Domain_03 group. Notice in the metadata window that Ord contains data collected from the <a href="http://neoninc.org/science-design/field-sites/ordway-swisher-biological-station" target="_blank">NEON Ordway-Swisher Biological Station Field Site</a>.

Within the Ord group there are two more groups - Min_1 and Min_30. What data are contained within these groups? 

- Expand the "min_1" group wtihin the Ord site in Domain_03. Notice that there are 5 more nested groups named "Boom_1, 2, etc". A boom refers to an arm that contains sensors, at a particular height on the tower. In this case, we are working with data collected using temperature sensors, mounted on the tower booms.

<i class="fa fa-star"></i> **Note:** The data used in this activity were collected by a temperature sensor mounted on a National Ecological Observatory Network (NEON) "flux tower". 
<a href="http://neoninc.org/science-design/collection-methods/flux-tower-measurements" target="_blank">Read more about NEON towers, here. </a>
{: .notice}

<figure>
    <a href="{{ site.baseurl }}/images/NEONtower.png"><img src="{{ site.baseurl }}/images/NEONtower.png"></a>
    <figcaption>A NEON tower contains booms or arms that house sensors at varying heights along the tower.</figcaption>
</figure>

Speaking of temperature - what type of sensor is collected the data within the boom_1 folder at the Ordway Swisher site? *HINT: check the metadata for that dataset.*


- Expand the "Boom_1" folder by double clicking it. Finally, we have arrived at a dataset! Have a look at the metadata associated with the temperature dataset within the boom_1 group. Notice that there is metadata describing each attribute in the temperature dataset. 
- Double click on the group name to open up the table in a tabular format. Notice that these data are temporal.

So this is one example of how an hdf5 file could be structured. This particular file contains data from multiple sites, collected from different sensors (from different booms on the tower) and collected over time. Take some time to explore this HDF5 dataset within the HDF viewer. 

Next, we will look at a spatial data stored in HDF5 format.

#Part 2. Exploring Hyperspectral Imagery stored in HDF5

<figure>
    <a href="{{ site.baseurl }}/images/aop_0.jpg"><img src="{{ site.baseurl }}/images/aop_0.jpg"></a>
    <figcaption>NEON airborne observation platform.</figcaption>
</figure>

Next, we will explore a hyperspectral dataset, collected by the <a href="http://neoninc.org/science-design/collection-methods/airborne-remote-sensing">NEON Airborne Observation Platform (AOP)</a> and saved in HDF5 format. Hyperspectral data are naturally hierarchical as each pixel in the data set contains reflectance values for hundreds of bands collected by the sensor. The NEON sensor (imaging spectrometer) collected data within 428 bands.

A few notes about hyperspectral imagery:

- An imaging spectrometer, which collects hyperspectral imagery, records light energy reflected off objects on the earth's surface.
- The data are inherently spatial. Each "pixel" in the image is located spatially and represents an area of ground on the earth.
- Similar to an R,G,B camera, an imaging spectrometer records  
- Each pixel will contain several hundred bands worth of reflectance data.

<figure>
    <a href="{{ site.baseurl }}/images/LandsatVsHyper-01.png">
    <img src="{{ site.baseurl }}/images/LandsatVsHyper-01.png"></a>
    <figcaption>A hyperspectral instruments records reflected light energy across very narrow bands. The NEON Imaging Spectrometer collects 428 bands of information for each pixel on the ground.</figcaption>
</figure>

Read more about hyperspectral data:

- <a href="http://www.geos.ed.ac.uk/abs/research/micromet/Current/airborne/knowledge_exhange/john_ferguson_imaging.pdf" target="_blank">Presentation by Dr John Ferguson</a>
- <a href="http://spacejournal.ohio.edu/pdf/shippert.pdf" target="_blank">White paper by Dr Peg Shippert</a>
- <a href="http://www.asprs.org/a/publications/pers/2004journal/april/highlight.pdf" target="_blank">ASPRS Explanation of Hyperspectral Remote Sensing</a>


Let's open some hyperspectral imagery stored in HDF5 format to see what the file structure can like for a different type of data.

- Open the file. Notice that it is structured differently. This file is composed of 3 datasets: Reflectance, fwhm, and wavelength. It also contains some text information called "map info". Finally it contains a group called spatial info.

- Let's first look at the metadata stored in the spatialinfo group. This group contains all of the spatial information that a GIS program would need to project the data spatially.
- Next double click on the wavelength dataset. Note that this dataset contains the central wavelength value for each band in the dataset. 
- Finally, click on the reflectance dataset. Note that in the metadata for the dataset that the structure of the dataset is 426 x 501 x 477 (wavelength, line, sample). 
- Right click on the reflectance dataset and select `open as`.
- Click Image in the "display as" settings on the left hand side of the popup. 
- In this case, the image data are in the second and third dimensions of this dataset. however, HDFview will default to selecting the first and second dimensions. Let's fix that. 
	- Under height, make sure dim 1 is selected.
	- Under width, make sure dim 3 is selected.  
	- Notice an image preview appears on the left of the pop-up window.
- Hit OK to open the image. You may have to play with the brightness and contrast settings in the viewer to see the data properly. 

Explore the spectral dataset in the HDFviewer taking note of the metadata and data stored within the file.


The end!!  
