---
layout: post
title: "About: Hierarchical Data Formats - What is HDF5?"
date:   2014-11-27 20:49:52
authors: Leah A. Wasser
categories: [coding-and-informatics]
category: coding-and-informatics
tags: [HDF5]
mainTag: HDF5
description: "An brief introduction to the Hierarchical Data Format 5 (HDF5) file / data model. Learn about how HDF5 is structured and the benefits of using HDF5."
code1: 
image:
  feature: hierarchy_folder.png
  credit: Colin Williams
  creditlink: http://www.neoninc.org
permalink: /HDF5/About
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
<li>Have a better understanding of what HDF5, Hierarchical Data Format is</li>
<li>Know the key components of the HDF5 data model that make it useful to scientists working with big data.</li>
<li>Understand both the types of data that can be stored in HDF5 and how it can be stored.</li>
</ol>

<h3>What You'll Need</h3>
<p>Internet access and a working thinking cap.</p>

</div>

##About Hierarchical Data Formats - HDF5

The Hierarchical Data Format version 5 (HDF5), is an open source file format that supports large, complex, heterogensous data.  HDF5 uses a "file directory" like structure that allows you to organize data within the file in many different structured ways as you might do with files on your computer. Finally, HDF5 is a self describing file format. Self-describing means that the metadata for data contained within the HDF5 file, are built into the file itself. Thus, there are no additional files needed when you use or share an HDF5 file. It's all self contained.

<i class="fa fa-star"></i> **Data Tip:** HDF5 is one hierarchical data format, that builds upon both HDF4 and NetCDF (two other hierarchical data formats). <a href="http://www.hdfgroup.org/why_hdf/" target="_blank"> Read  more about HDF5 Here.</a>
{: .notice}


###Some Benefits of HDF5 

- **Self-Describing** The data with an HDF5 file are self describing. This means that metadata are embedded within the actual HDF5 file. This allows us to efficiently extract metadata about the data, without needing an additional metadata document.
- **Can Support Heterogeneous Data**: Different types of data can be contained within one HDF5 file. For example, one HDF5 file might contain data for different sites, summarized in different ways (eg 1 minute vs 30 minute average). One file can also contain text, numeric and spatial image data.
- **Supports Large, Complex Data**: HDF5 formats are designed to handle large, complex datasets. The data contained within the HDF5 are compressed to reduce file size. 
- **Supports Data Slicing:** "Data slicing" or extracting portions of the dataset as needed to be used in analysis means large files don't need to be completely read into the computers memory or RAM. Data slicing is beneficial when analyzing large datasets in programs like `R` or `Python`.  
- **Has wide support in the many programming languages**: Because the HDF5 format is open, it is supported by a host of programming languages including open source languages like `R` and `Python`.

<figure>
    <a href="{{ site.baseurl }}/images/whyHDF5.jpg"><img src="{{ site.baseurl }}/images/whyHDF5.jpg"></a>
    <figcaption>Why Use HDF5. Image Source: http://www.hdfgroup.org/why_hdf/</figcaption>
</figure>

##Hierarchical Structure - A file directory within a file

THe HDF5 format can  be thought of as a file system contained and described within one single file. Think about your computer. You probably have a folder or directory structure that keeps your files organized. For example, as a scientist, you might have a data directory with some temperature data for multiple field sites that you are working at. This temperature data might be collected every minute and summarized on an hourly, daily and weekly basis. Within **ONE** HDF5 file, you can store a similar set of data organized in the same way that you might organize files and folders on your computer. However in a HDF5 file, what we call "directories" or "folders" on our computers, are called "groups" and what we call "files" on our computer are called datasets. 


<figure>
    <a href="{{ site.baseurl }}/images/HDf5/hdf5_structure4.jpg"><img src="{{ site.baseurl }}/images/HDf5/hdf5_structure4.jpg"></a>
    <figcaption>An examle HDF file structure which contains groups, datasets and associated metadata.</figcaption>
</figure> 




The HDF5 file might be structured like this:  


Site One (Group)

- Temperature data
	- 1 Minute average
	- 30 Minute average
	- 1 Hour average
	- Weekly average

Site Two (Group)

- Temperature data
 	- 1 Minute average
	- 30 Minute average
	- 1 Hour average
	- Weekly average


##Examples of Types of Data That can be Stored in One HDF5 File 
HDF5 files can store many different types of data. And they can store all of those data in the same place. This means that you could store any of the following in one file:

- Temperature, precipitation and PAR (photosynthetic active radiation) data for a site or for many sites 
- A set of images that cover one or more areas (each image can have specific spatial information associated with it - all in the same file)
- a multi or hyperspectral spatial dataset that contains thousands of bands.
- plot data for several sites characerizing insects, vegetation and climate.


## Compressed & Efficient subsetting
The HDF5 format is a compressed format. This means that the size of all data contained in HDF5 is optimized. More powerful is the ability to quickly and efficiently extract parts or subsets of a dataset stored within HDF5. Subsetting allows a scientist to efficiently work with very large (gigabytes or more) datasets. 


##HDF5 is a Self Describing Format
HDF5 format is self describing. This means that each group and dataset can have associated metadata that describes exactly what the data are. Using the example above, we might attach information about each site to the file include the X,Y location, and even a site description. Similarly, we might add information describing the sensor used to collect the temperature data. We can attach information pertaining to both how the averaging was performed to each dataset within the site group and to describe the time period for which data are available. 

One key benefit of all of this metadata attached to each group and dataset, is that it facilitates automation. Using a programming language, like `R` or `Python`, you can grab information from the metadata that you might need to process the data.

<figure>
    <a href="{{ site.baseurl }}/images/HDf5/hdf5_structure4.jpg"><img src="{{ site.baseurl }}/images/HDf5/hdf5_structure2.jpg"></a>
    <figcaption>HDF5 files are self describing - this means that all elements (the file itself, groups and datasets) can have associated metadata that describes the information contained within the element.</figcaption>
</figure> 

###Summary
In summary, HDF5 files consists of groups (directories) and datasets (files). The dataset holds the actual data, but the groups provide structure to that data. You'll see what this looks like when we open an HDF5 file in the HDFviewer.



##Additional Resources About HDF5

- <a href="{{ site.baseurl }}/documents/HDF5-Intro.pdf">About HDF5 - Presentation from the HDF5 Group</a>


