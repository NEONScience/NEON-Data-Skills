---
layout: post
title: "About: Hierarchical Data Formats (HDF5)"
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


##Learning Goals

1. Provide an introduction to Hierarchical Data Formats - specifically the HDF5 file format - a common data format used by many disciplines (also the backbone of NetCDF4)


##What you'll Need
- Internet access and a working thinking cap.

##About Hierarchical Data Formats - HDF5

The Hierarchical Data Format version 5 (HDF5), is an open file format that supports large, complex, heterogensous data. HDF5 is open source. HDF5 uses a "file directory" like structure, meaning you can organize data within the file in many different ways as you might do on your computer. Finally, HDF5 is a self describing file format. This means that the metadata for the data contained within the HDF5 file, are built into the file itself. Thus, there are no additional files needed when you use or share an hdf5 file. It's all self contained!

>NOTE: HDF5 is one hierarchical data format, that builds upon both HDF4 and NetCDF (two other hierarchical data formats). 

<a href="http://www.hdfgroup.org/why_hdf/" target="_blank" Read  more about HDF5 Here.</a>

###Some Benefits of HDF5 

- **Self-Describing** The data are self describing -- the metadata is embedded within the actual HDF5 file. This allows us to efficiently extract metadata about the data, without needing an additional metadata document!
- **Can Support Heterogeneous Data**: Different types of data can be contained within one hdf5 file. For example, one hdf5 file might contain data for different sites, summarized in different ways (eg 1 minute vs 30 minute averaged), text vs numeric data vs image data. We will take a look at some examples of this here. 
- **Supports Large, Complex Data**: HDF5 formats are designed to handle large, complex datasets. The data contained within the HDF5 are compressed in a way that keeps file sizes down. 
- **Supports Data Slicing:** "Data slicing" or extracting portions of the dataset as needed to be used in analysis means large files don't need to be completely read into the computers memory or RAM. Data slice in beneficial when analyzing data in programs like `R`.  
- **Has wide support in the many programming languages**: Because the HDF5 format is open, it is supposed by a host of programming languages including open source languages like `R` and `Python`.

<figure>
    <a href="{{ site.baseurl }}/images/whyHDF5.jpg"><img src="{{ site.baseurl }}/images/whyHDF5.jpg"></a>
    <figcaption>Why Use HDF5. Image Source: http://www.hdfgroup.org/why_hdf/</figcaption>
</figure>


THe HDF5 - model (or format) can  be thought of as a file system contained and described within one single file. Think about your computer. You probably have a folder or directory structure that keeps your information organized. For example, as a scientist, you might have a data directory with some temperature data for multiple field sites that you are working at. This temperature data might be collected every minute and summarized on an hourly, daily and weekly basis. The folder structure might look something like this:


Site One 

- Temperature data
	- 1 Minute average
	- 30 Minute average
	- 1 Hour average
	- Weekly average

Site Two

- Temperature data
 	- 1 Minute average
	- 30 Minute average
	- 1 Hour average
	- Weekly average


Within **ONE** HDF5 file, you can store a similar set of data organized in the same way (or however you'd like it to be organized). You can load chunks or slices of different types of data into the HDF5 file, in the same way that you might store the datasets within directorys or folders on your laptop. So following this anology, what we know as the "directories" or "folders" on our computers, are called "groups" in an HDF5 file and what we call "files" on our computer, are called are "datasets" in an HDF5 file. 

##HDF5 is a Self Describing Format
HDF5 format is self describing. What this measn is that each group and dataset can have metadata attached to it - that describes exactly what the data are. Using the example above, we might attach information about each site to the file includ the X,Y location, and even a site description. SImilarly, we might add information describing the sensor used to collect the temperature data. To each dataset within the site group, we might attach information pertaining to how the averaging was performed. And describing the time period available. 

One key benefit of all of this metadata attached to each group and dataset, is that it facilitates automation. Using a programming language, like `R`, you can grab information from the metadata that you might need to process the data. All of this attached metadata, makes the hdf5 format, self-describing. 

###Summary
In summary, HDF5 files consists of groups (directories) and datasets (files). The dataset holds the actual data, but the groups provide structure to that data. You'll see what this looks like when we open an hdf5 file in the HDFviewer.



More about HDF5
source: HDF5 Group

https://bluewaters.ncsa.illinois.edu/c/document_library/get_file?uuid=a2dc7a56-cb6e-4c3f-8df0-3a51b5a5caf9&groupId=10157

