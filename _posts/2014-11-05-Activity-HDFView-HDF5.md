---
layout: post
title: "HDFView: Exploring HDF5 Files in a Free Viewer"
date:   2014-11-19 20:49:52
authors: Leah A. Wasser
categories: [Coding and Informatics]
category: coding-and-informatics
tags : [HDF5]
description: "Explore HDF5 files and the groups and datasets contained within, using the free HDFview tool. See how HDF5 files can be structured and explore metadata. Explore both spatial and temporal data stored in HDF5!"
code1: 
image:
  feature: hierarchy_folder_green.png
  credit: Colin Williams
  creditlink: http://www.neoninc.org
permalink: /HDF5/Exploring-Data-HDFView
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


##Learning Goals

1. Provide an introduction to Hierarchical Data Formats - specifically the HDF5 file format - a common data format used by many disciplines (also the backbone of NetCDF4)
2. Use the HDF viewer to explore a HDF5 file to better understand the benefits and possibilities of these data formats 

##What you'll Need
- Install the [free HDFview application](http://www.hdfgroup.org/products/java/hdfview/). This application will allow you to explore the contents of an HDF5 file easily. <a href="http://www.hdfgroup.org/products/java/release/download.html" target="_blank">Click HERE to go to the download page. </a>

NOTE: Select the HDFView download option that matches the operating system and computer setup (32 bit vs 64 bit) that you have. Also *don't* click on the "(MDF)" link. Click on the operating system name (ie Windows or Mac for java 1.7).

<figure>
    <a href="{{ site.baseurl }}/images/HDF5View_Install.png">
    <img src="{{ site.baseurl }}/images/HDF5View_Install.png"></a>
    <figcaption>Download the HDFview without the java wrapper.</figcaption>
</figure>

- Download the [National Ecological Observatory Network (NEON) Flux Tower Temperature data HERE]({{ site.baseurl }}/data/NEON_TowerDataD3_D10.hdf5 "FIU data").
- Download the [National Ecological Observatory Network (NEON)Airborne Observation Platform Spectrometer Data HDF5 File](http://neonhighered.org/Data/HDF5/SJER_140123_chip.h5 "FIU data"). NOTE that this second file has an h5 extension while the first has an HDF5 extension. Both extensions represent the hdf5 data type.

##Review: Hierarchical Data Format 5 - HDF5

We learned previously that the Hierarchical Data Format version 5 (HDF5), is an open file format that supports large, complex, heterogeneous data. Some key points about HDF5:

-  HDF5 uses a "file directory" like structure. The HDF5 data models organizes information using "Groups". Each group may contain one or more "datasets.
-  HDF5 is a self describing file format. This means that the metadata for the data contained within the HDF5 file, are built into the file itself.
-  One hdf5 file may contain several hetergeonous data types (eg images, numeric data, data stored as strings, etc) 


##About This Activity - 
In this activity, we will explore two different types of data, saved in HDF5. This will allow us to better understand how one file can store multiple different types of data, in different ways.

#Part 1. Exploring Temperature Data in HDF5 Format in HDFView

The first thing that we will do is open an HDF5 file in the viewer to get a better idea of how HDF5 files can be structured.

- To begin, open up the HDFView application.
- Within the HDFView application, select File --> Open and navigate to the folder where you saved the fiuTestFile.hdf5 file on your computer. Open this file HDFView.
- If you click on the NAME of the HDF5 file in the left hand window of HDFView, you can view metadata for the file (located in the bottom window of the application).

C:\Users\lwasser\Documents\GitHub\NEON_HigherEd\
<figure>
    <a href="{{ site.baseurl }}/images/HDf5/OpenFIU.png"><img src="{{ site.baseurl }}/images/HDf5/OpenFIU.png"></a>
    <figcaption>Open up the FIU file in the HDFViewer. If you click on the file name wtihin the viewer, you can view any stored metadata for that file, at the bottom of the viewer. (you may have to click on the metadata tab at the bottom of the viewer)</figcaption>
</figure>

- Next, explore the structure of this file. Notice that there are two Groups (represented as folder icons in the viewer) called "Domain_03" and "Domain_10". Within each domain group, there site groups (NEON sites that are located within those domains). Expand these folders by double clicking on the folder icons. Double clicking "expands" the groups content just as you might expand a folder in windows explorer.

Notice that there is metadata associated with each group.

5. Double click on the "ORD" group. Notice in the metadata window that Ord contains metadata that tells you this is data from the NEON Ordway-Swisher Biological Station Field Site.

Within the Ord group there are two more groups - Min_1 and Min_30. 

What data are contained within these groups? 

- Expand the "min_1" group wtihin the Ord site in Domain_03. Notice that there are 5 more nested groups named "Boom_1, 2, etc". A boom just equates to an arm at a particular height on the tower where there are sensors. In this case, there is a temperature sensor.


Speaking of temperature - what type of sensor is collected the data within the boom_1 folder at the Ordway Swisher site? 

Expand the "Boom_1" folder by double clicking it. Finally, we have arrived at a dataset! Have a look at the metadata associated with the temperature dataset within the boom_1 group. Notice that there is metadata describing each attribute in the temperature dataset. Double click on the group name to open up the table in a tabular format.

Notice that these data are temporal.

So that is one example of how an hdf5 file could be structured. This particular file contained data from multiple sites, collected from different sensors (from different booms on the tower) and collected over time. Next, we will look at a spatial data stored in HDF5 format.

#Part 2. Exploring Hyperspectral Imagery stored in HDF5

Next, we will explore a hyperspectral dataset, collected by the NEON Airborne Observation Platform (AOP) and saved in HDF5 format. Hyperspectral data is naturally hierarchical as each pixel in the data set has hundreds of associated reflectance values associated with it that spans the electromagnetic spectrum.

A few notes about hyperspectral imagery:
- AnHyperspectral imagery records light energy reflected off objects on the earth's surface
- The data are inherently spatial. Each "pixel" in the image is located spatially and represents an area of ground on the earth.
- Similar to an R,G,B camera, an imaging spectrometer records  
- Each pixel will contain several hundred bands worth of reflectance data.

<figure>
    <a href="{{ site.baseurl }}/images/LandsatVsHyper-01.png">
    <img src="{{ site.baseurl }}/images/LandsatVsHyper-01.png"></a>
    <figcaption>A hyperspectral instruments records reflected light energy across very narrow bands. The NEON Imaging Spectrometer collects ~426 bands of information for each pixel on the ground!</figcaption>
</figure>

Read more about hyperspectral data:

- <a href="http://www.geos.ed.ac.uk/abs/research/micromet/Current/airborne/knowledge_exhange/john_ferguson_imaging.pdf" target="_blank">Presentation by Dr John Ferguson</a>
- <a href="http://spacejournal.ohio.edu/pdf/shippert.pdf" target="_blank">White paper by Dr Peg Shippert</a>
- <a href="http://www.asprs.org/a/publications/pers/2004journal/april/highlight.pdf" target="_blank">ASPRS Explanation of Hyperspectral Remote Sensing</a>


Let's open some hyperspectral imagery stored in hdf5 format to see what the file structure can like for a different type of data.

- Open the file. Notice that it is structured differently. This file is composed of 3 datasets: Reflectance, fwhm, and wavelength. It also contains some text information called "map info". Finally it contains a group called spatial info.

- Let's first look at the metadata stored in the spatialinfo group. This group contains all of the spatial information that a GIS program would need to render the data on the screen.
- Next, 
-  

