---
layout: post
title: "About: Hierarchical Data Formats - What is HDF5?"
date:   2015-1-31 20:49:52
dateCreated:   2014-11-27 20:49:52
lastModified:  2015-2-06 14:49:52
estimatedTime: 0.25 - 0.5 Hours
packagesLibraries:
authors: Leah A. Wasser
contributors: Elizabeth Webb
categories: [coding-and-informatics]
category: coding-and-informatics
tags: [HDF5]
mainTag: HDF5
description: "An brief introduction to the Hierarchical Data Format 5 (HDF5) file / data model. Learn about how HDF5 is structured and the benefits of using HDF5."
code1: 
image:
  feature: hierarchy_folder.png
  credit: Colin Williams NEON, Inc.
  creditlink: http://www.neoninc.org
permalink: /HDF5/About
comments: true
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

<div id="objectives">

<h3>Goals / Objectives</h3>
After completing this activity, you will:
<ol>
<li>Understand what the Hierarchical Data Format (HDF5) is.</li>
<li>Understand the key benefits of the HDF5 format, particularly related to big data. </li>
<li>Understand both the types of data that can be stored in HDF5 and how it can be stored / structured.</li>
</ol>

<h3>What You'll Need</h3>
<p>Internet access and a working thinking cap.</p>

</div>

##About Hierarchical Data Formats - HDF5

The Hierarchical Data Format version 5 (HDF5), is an open source file format that supports large, complex, heterogeneous data. HDF5 uses a "file directory" like structure that allows you to organize data within the file in many different structured ways as you might do with files on your computer. The HDF5 format also allows for embedding of metadata making it *self-describing*. 

<i class="fa fa-star"></i> **Data Tip:** HDF5 is one hierarchical data format, that builds upon both HDF4 and NetCDF (two other hierarchical data formats). <a href="http://www.hdfgroup.org/why_hdf/" target="_blank"> Read  more about HDF5 Here.</a>
{: .notice}


<figure>
    <a href="{{ site.baseurl }}/images/whyHDF5.jpg"><img src="{{ site.baseurl }}/images/whyHDF5.jpg"></a>
    <figcaption>Why Use HDF5. Image Source: http://www.hdfgroup.org/why_hdf/</figcaption>
</figure>

##Hierarchical Structure - A file directory within a file

The HDF5 format can  be thought of as a file system contained and described within one single file. Think about the files and folders stored on your computer. You might have a data directory with some temperature data for multiple field sites. This temperature data is collected every minute and summarized on an hourly, daily and weekly basis. Within **ONE** HDF5 file, you can store a similar set of data organized in the same way that you might organize files and folders on your computer. However in a HDF5 file, what we call "directories" or "folders" on our computers, are called `groups` and what we call files on our computer are called `datasets`. 

### 2 Important HDF5 Terms

* **Group:** A folder like element within an HDF5 file that might contain other groups OR datasets within it.
* **Dataset:** The actual data contained within the HDF5 file. Datasets are often (but don't have to be) stored within groups in the file.


<figure>
    <a href="{{ site.baseurl }}/images/HDf5/hdf5_structure4.jpg"><img src="{{ site.baseurl }}/images/HDf5/hdf5_structure4.jpg"></a>
    <figcaption>An example HDF file structure which contains groups, datasets and associated metadata.</figcaption>
</figure> 


An HDF5 file containing data, might be structured like this:  

<figure>
    <a href="{{ site.baseurl }}/images/HDf5/hdf5_structure3.jpg"><img src="{{ site.baseurl }}/images/HDf5/hdf5_structure3.jpg"></a>
    <figcaption>An example HDF5 file structure containing data for multiple field sites and also containing various datasets (averaged at different time intervals).</figcaption>
</figure> 


##HDF5 is a Self Describing Format

HDF5 format is self describing. This means that each file, group and dataset can have associated metadata that describes exactly what the data are. Following the example above, we can embed information about each site to the file such as

* The full name and X,Y location of the site
* Description of the site
* Another other documentation of interest.

Similarly, we might add information describing the sensor used to collect the temperature data. We can attach information about both how the averaging was performed to each dataset within the site group and to describe the time period for which data are available. 

One key benefit of metadata attached to each file, group and dataset, is that it facilitates automation without needing an additional metadata document. Using a programming language, like `R` or `Python`, we can grab information from the metadata that we might need to process the data.

<figure>
    <a href="{{ site.baseurl }}/images/HDf5/hdf5_structure4.jpg"><img src="{{ site.baseurl }}/images/HDf5/hdf5_structure2.jpg"></a>
    <figcaption>HDF5 files are self describing - this means that all elements (the file itself, groups and datasets) can have associated metadata that describes the information contained within the element.</figcaption>
</figure> 

## Compressed & Efficient subsetting
The HDF5 format is a compressed format. The size of all data contained within HDF5 is optimized which makes the overall file size smaller. However, HDF5 files, even when compressed can be quite large given they often contain big data. Another powerful attribute of HDF5 is `data slicing`. Data slicing refers to extracting particular subsets of a dataset stored within the HDF5 file. This means that the entire dataset doesn't have to be read into memory (RAM). It allows us to more efficiently work with very large (gigabytes or more) datasets. 

## Heterogeneous Data Storage
HDF5 files can store many different types of data within in the same file. For example, one group may contain a set of datasets to contain integer (numeric) and text (string) formatted data. One dataset can also contain heterogeneous information (combining text and numeric data). This means that HDF5 can store any of the following (and more) in one file:

- Temperature, precipitation and PAR (photosynthetic active radiation) data for a site or for many sites 
- A set of images that cover one or more areas (each image can have specific spatial information associated with it - all in the same file)
- A multi or hyperspectral spatial dataset that contains thousands of bands.
- Field data for several sites characterizing insects, mammals, vegetation and climate.
- And more much!

## Open Format 
The HDF5 format is open and free to use. The supporting libraries (and a free viewer), can be downloaded from the <a href="http://www.hdfgroup.org" target="_blank">HDF Group </a> website.  As such, it has wide support in a host of programs including open source programming languages like `R` and `Python`, commercial programming tools like `Matlab` and `IDL`. Spatial data, stored in HDF5 format can be used in GIS and imaging programs including `QGIS`, `ArcGIS`, and `ENVI`.


## Summary Points - Benefits of HDF5 

- **Self-Describing** The data with an HDF5 file are self describing. This allows us to efficiently extract metadata without needing an additional metadata document.
- **Supporta Heterogeneous Data**: Different types of data can be contained within one HDF5 file. 
- **Supports Large, Complex Data**: HDF5 is a compressed format that is designed to support  large, heterogeneous, and complex datasets. 
- **Supports Data Slicing:** "Data slicing" or extracting portions of the dataset as needed to be used in analysis means large files don't need to be completely read into the computers memory or RAM.
- **Open Format -  wide support in the many tools**: Because the HDF5 format is open, it is supported by a host of programming languages and tools including open source languages like `R` and `Python` and open GIS tools like `QGIS`.

You'll see what this looks like when [we open an HDF5 file in the HDFviewer]( {{ site.baseurl }}/HDF5/Exploring-Data-HDFView/).


##Additional Resources About HDF5

- <a href="{{ site.baseurl }}/documents/HDF5-Intro.pdf">About HDF5 - Presentation from the HDF5 Group</a>


