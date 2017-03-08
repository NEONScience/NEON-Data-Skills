---
layout: workshop-event
title: "NEON Brownbag: Intro to HDF5 at NEON"
estimatedTime: 1.0 Hours
packagesLibraries: [rhdf5, h5py]
language: [python, R]
date: 2015-06-04
dateCreated:   2015-5-08 
lastModified: 2015-5-08
endDate: 2015-06-04
authors: [David Hulslander, Josh Elliot, Leah A. Wasser, Tristan Goulden]
tags: []
mainTag: Data-Workshops
categories: [workshop-event]
description: "This NEON Brownbag increases participants understanding of 
Hierarchical Data Formats in the context of developing the NEON HDF5 operational 
file format. Look here to discover resources on HDF5, code snippets in R, Python 
and Matlab to use H5 files and some example H5 files for Remote Sensing 
Hyperspectral data and time series temperature data."
code1: 
image:
  feature: hierarchy_folder_green.png
  credit: 
  creditlink:
permalink: /Data-Workshops/NEON-Develop-HDF5-Format
comments: true 
---

### Explore the Operational NEON HDF5 Format

This NEON internal brownbag introduces the concept of Hierarchical Data Formats 
in the context of developing the NEON HDF5 operational file format. Look here to 
discover resources on HDF5, code snippets in R, Python and Matlab to use H5 files 
and some example H5 files for Remote Sensing Hyperspectral data and time series 
temperature data.

<div id="objectives" markdown="1">

<h2>Background Materials</h2>

Please review, download and setup the following, prior to attending the brownbag.

<h3>Data to Download</h3>

{% include/dataSubsets/_data_Sample-Tower-Temp-H5.html %}

{% include/dataSubsets/_data_Imaging-Spec-Data-H5.html %}


<h2>Download the Free H5 Viewer</h2>

The free H5 viewer will allow you to explore H5 data, using a graphic interface. 


<a href="http://www.hdfgroup.org/products/java/release/download.html" target="_blank" class="btn btn-success"> HDF5 viewer can be downloaded from this page.</a>

<a href="http://neondataskills.org/HDF5/Exploring-Data-HDFView">Click here to read more on the
 viewer in the *HDFView: Exploring HDF5 Files in the Free HDFview Tool* tutorial.</a>

<h3>Please review the following:</h3>
<ul>
<li><a href="http://neondataskills.org/HDF5/About">What is HDF5? A general overview.</a></li>
</ul>

</div>



## SCHEDULE


| Time        | Topic         | | 
|-------------|---------------| |
| 12:00 | Hand-on exploration of the HDF5 Data Format |          |
| 12:20 | Working with HDF5 in Python - live demo.      |            |
| 12:30 | NEON HDF5 Format - what's next     |      |

 
## Useful HDF5 Resources

* [A set of data tutorials on working with HDF5 in R](http://neondataskills.org/HDF5/ "Working with HDF5 in R")

## Python resources for HDF5:
1. [H5 Python Documentation]( http://www.h5py.org/ )
2. [O’Reilly book on Python and HDF5! The modern stamp of legitimacy for programming.](http://shop.oreilly.com/product/0636920030249.do) 
3. [Python examples from the HDF5 people themselves!](https://www.hdfgroup.org/HDF5/examples/api18-py.html)


## Python Code to Open HDF5 files

For sample python code to open HDF5 files, see the 
<a href="{{ site.baseurl }}/self-paced-tutorial/Python-HDF5-basics"> *Opening HDF5 files with Python Sample Code* tutorial </a>. 

