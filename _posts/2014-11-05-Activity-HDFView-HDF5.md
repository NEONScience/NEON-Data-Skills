---
layout: post
title: "Activity: Exploring HDF5 Files in HDFView"
date:   2014-11-05 20:49:52
authors: Leah A. Wasser
categories: [Hierarchical Data Formats]
tags : []
description: "An activity in progress -- This activity will Introduce the HDF5 file format."
code1: 
image:
  feature: textur2_FieldWork.jpg
  credit: Ordway Swisher Biological Station, NEON, thx to Courtney Meier
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


    #not sure what this is
    source("../chunk_options.R")
 

##Learning Goals

1. Provide an introduction to Hierarchical Data Formats - specifically the HDF5 file format - a common data format used by many disciplines (also the backbone of NetCDF4)
2. Use the HDF viewer to explore a HDF5 file to better understand the benefits and possibilities of these data formats 

##What you'll Need
- Install the [free HDFview application](http://www.hdfgroup.org/products/java/hdfview/). This application will allow you to explore the contents of an HDF5 file easily. <a href="http://www.hdfgroup.org/products/java/release/download.html" target="_blank">Click HERE to go to the download page. </a>

NOTE: Select the HDFView + Java Wrapper download that matches the operating system and computer setup (32 bit vs 64 bit) that you have:
<figure>
    <a href="{{ site.baseurl }}/images/HDF5View_Install.png">
    <img src="{{ site.baseurl }}/images/HDF5View_Install.png"></a>
    <figcaption>Download the HDFview that includes the java wrapper.</figcaption>
</figure>

- Download the [National ecological observatory network (NEON) Flux Tower Temperature data TOWER  HERE]({{ site.baseurl }}/data/fiuTestFile.hdf5 "FIU data").
- Download the [LINK HERE]({{ site.baseurl }}/data/fiuTestFile.hdf5 "FIU data").and the Hyperspectral Remote Sensing hdf5 files <<ADD LINKS>>

##About Hierarchical Data Formats - HDF5

The Hierarchical Data Format version 5 (HDF5), is an open file format that supports large, complex, heterogensous data. HDF5 is open source. HDF5 uses a "file directory" like structure, meaning you can organize data within the file in many different ways as you might do on your computer. Finally, HDF5 is a self describing file format. This means that the metadata for the data contained within the HDF5 file, are built into the file itself. Thus, there are no additional files needed when you use or share an hdf5 file. It's all self contained!

>NOTE: HDF5 is one hierarchical data format, that builds upon both HDF4 and NetCDF (two other hierarchical data formats). 

<a href="http://www.hdfgroup.org/why_hdf/" target="_blank" Read  more about HDF5 Here.</a>


##About This Activity - 
In this activity, you will explore two different types of data, stored within the same HDF5 format. , to see how different types of data can be stored

##Exploring and HDF5 File in HDFView

The first thing that we will do, is open an HDF5 file in the viewer to see how HDF5 files can be structured.

1. Open up HDFView
2. Navigate to the folder where you saved the fiuTestFile.hdf5 file and open it in HDFView. Notice that HDFview can open other HDF files including HDF4.
3. Notice that if you click on the NAME of the HDF5 file in the left hand window of HDFView, you can view metadata for the file (located in the bottom window of the application).

C:\Users\lwasser\Documents\GitHub\NEON_HigherEd\
<figure>
    <a href="{{ site.baseurl }}/images/HDf5/OpenFIU.png"><img src="{{ site.baseurl }}/images/HDf5/OpenFIU.png"></a>
    <figcaption>Open up the FIU file in the HDFViewer</figcaption>
</figure>

4. Next, explore the structure of this file. Notice that there are two Groups (represented as folder icons in the viewer) called "Domain_03" and "Domain_10". Within each domain group, there site groups (NEON sites that are located within those domains). Expand these folders by double clicking on the folder icons. Double clicking "expands" the groups content just as you might expand a folder in windows explorer.

Notice that there is metadata associated with each group.

5. Double click on the "ORD" group. Notice in the metadata window that Ord contains metadata that tells you this is data from the NEON Ordway-Swisher Biological Station Field Site.

Within the Ord group there are two more groups - Min_1 and Min_30. 

What data are contained within these groups? 



- Expand the "min_1" group wtihin the Ord site in Domain_03. Notice that there are 5 more nested groups named "Boom_1, 2, etc". A boom just equates to an arm at a particular height on the tower where there are sensors. In this case, there is a temperature sensor.
- 
- Speaking of temperature - what type of sensor is collected the data within the boom_1 folder at the Ordway Swisher site? 

Expand the "Boom_1" folder by double clicking it. Finally, we have arrived at a dataset! Have a look at the metadata associated with the temperature dataset within the boom_1 group. Notice that there is metadata describing each attribute in the temperature dataset. Double click on the group name to open up the table in a tabular format.

Notice that these data are temporal.

#Summary


More about HDF5
source: HDF5 Group

https://bluewaters.ncsa.illinois.edu/c/document_library/get_file?uuid=a2dc7a56-cb6e-4c3f-8df0-3a51b5a5caf9&groupId=10157

