---
layout: post
title: "About: Hierarchical Data Formats (HDF5)"
date:   2014-11-05 20:49:52
authors: Ted Hart - Adapted from Software Carpentry Materials by Leah A. Wasser
categories: [Hierarchical Data Formats]
tags : []
description: "This activity will Introduce the HDF5 file format.."
code1: 
image:
  feature: textur2_FieldWork.jpg
  credit: Ordway Swisher Biological Station, NEON, thx to Courtney Meier
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


    #not sure what this is
    source("../chunk_options.R")
 

##Learning Goals

1. Provide an introduction to Hierarchical Data Formats - specifically the HDF5 file format - a common data format used by many disciplines (also the backbone of NetCDF4)
2. Use the HDF viewer to explore a HDF5 file to better understand the benefits and possibilities of these data formats 

##What you'll Need
Install the [free HDFview application](http://www.hdfgroup.org/products/java/hdfview/). This application will allow you to explore the contents of an HDF5 file easily. 

##About Hierarchical Data Formats - HDF5

The Hierarchical Data Format, allows the storage of large heterogeneous data sets with self-describing metadata. HDF5 is one hierarchical data format, that builds upon both HDF4 and NetCDF (two other hierarchical data formats). 
<a href="http://www.hdfgroup.org/why_hdf/" target="_blank" Read  more about HDF5 Here.</a>

###Some Benefits of HDF5 

- **Self-Describing** The data are self describing -- the metadata is embedded within the actual HDF5 file. This allows us to efficiently extract metadata about the data, without needing an additional metadata document!
- **Heterogeneous Data**: Different types of data can be contained within one hdf5 file. For example, one hdf5 file might contain data for different sites, summarized in different ways (eg 1 minute vs 30 minute averaged), text vs numeric data. We will take a look at some examples of this here. 
- **Large, Complex Data**: HDF5 formats are designed to handle large, complex datasets 
- It supports compression, parallel I/O, and easy data slicing which means large files don't need to be completely read into RAM (a real benefit to `R`).  
- Has wide support in the many programming languages, `R` included.


![Why HDF5]({{ site.baseurl }}/images/whyHDF5.jpg)

<figure>
    <a href="{{ site.baseurl }}/images/whyHDF5.jpg"><img src="{{ site.baseurl }}/images/whyHDF5.jpg"></a>
    <figcaption>HDF5. Image Source: http://www.hdfgroup.org/why_hdf/</figcaption>
</figure>

caption: 

HDF5 as a format can essentially be thought of as a file system contained within one single file. If you think about your computer, you might have a folder structure. For example, you might have some temperature data for multiple field sites that you are working at. This temperature data might be collected every 30 minutes and summarized on an hourly, daily and weekly basis. The folder structure might look like this

Site One 

- temperature data
	- 30 minute average
	- 1 hour average
	- Weekly average

Site Two

- temperature data
	- 30 minute average
	- 1 hour average
	- Weekly average


Within the HDF5 file, you can store chunks or slices of different types of data for that you load slices of at a time in the same way that you might store the data within folders on your laptop. So following this anology, the "directories" or "folders" are called "groups" in an HDF5 file and "files" are "datasets".   Each group and dataset can have metadata attached to it - making it self-describing. 

In summary, HDF5 files consists of groups (directories) and datasets (files). The dataset holds the actual data, but the groups provide structure to that data, as you'll see in our example.


##Exploring and HDF5 File in HDFView

https://bluewaters.ncsa.illinois.edu/c/document_library/get_file?uuid=a2dc7a56-cb6e-4c3f-8df0-3a51b5a5caf9&groupId=10157