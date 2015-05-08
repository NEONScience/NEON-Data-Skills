---
layout: workshop
title: "NEON Brownbag: Intro to HDF5 Workshop"
estimatedTime: 1.0 Hours
packagesLibraries: RHDF5, H5PY
language: [python,R]
date: 2015-5-08 10:49:52
dateCreated:   2015-5-08 10:49:52
lastModified: 2015-5-08 22:11:52
authors: David Hulslander, Josh Elliot, Leah A. Wasser, Tristan Goulden 
tags: [Data-Workshops]
mainTag: Data-Workshops
description: "This NEON internal brownbag introduces the concept of Hierarchical Data Formats in the context of developing the NEON HDF5 operational file format. Look here to discover resources on HDF5, code snippets in R, Python and Matlab to use H5 files and some example H5 files for Remote Sensing Hyperspectral data and time series temperature data."
code1: 
image:
  feature: hierarchy_folder_green.png
  credit: Colin Williams NEON, Inc.
  creditlink: http://www.neoninc.org
permalink: /Data-Workshops/NEON-Develop-HDF5-Format
comments: true 
---

###Exploring the Operational NEON HDF5 Format

**Date:** 11 May 2015

This NEON internal brownbag introduces the concept of Hierarchical Data Formats 
in the context of developing the NEON HDF5 operational file format. Look here to 
discover resources on HDF5, code snippets in R, Python and Matlab to use H5 files 
and some example H5 files for Remote Sensing Hyperspectral data and time series 
temperature data.

<div id="objectives">

<h2>Background Materials</h2>

<h3>Data to Download</h3>
<p>We will use the data below in our brownbag. Please download it in advance.</p>

<ul>
<li><a href="http://neondataskills.org/data/NEON_TowerDataD3_D10.hdf5" class="btn btn-success"> NEON Temperature Data: Sample H5 
Structure</a></li>
<li><a href="##" class="btn btn-success"> NEON Hyperspectral Data: Sample Data
</a></li>
<li><a href="##" class="btn btn-success"> EOS Sample Data</a></li>

</ul>

<h2>Download the Free H5 Viewer</h2>

<p>If you would like to participate in the hands-on exploration of H5 data, 
please download the H5 viewer prior to coming to the brownbag.</p>

<a href="http://www.hdfgroup.org/products/java/release/download.html" target="_blank" class="btn btn-success"> HDF5 viewer can be downloaded from this page.</a>



<ul>
<li><a href="http://neondataskills.org/HDF5/Exploring-Data-HDFView/">More on the
 viewer here</a></li>
</ul>

<h3>Prior to the Brownbag please review the following:</h3>
<ul>
<li><a href="http://neondataskills.org/HDF5/About/">What is HDF5? A general overview.</a></li>
</ul>

</div>



##SCHEDULE


| Time        | Topic         | Instructor | 
|-------------|---------------|------------|
| 12:00     | Hand-on exploration of the HDF5 Data Format |          |
| 12:20     | Working with HDF5 in Python - live demo.      |            |
| ~12:30 | NEON HDf5 Format - what's next     |      |

 
# Useful HDF5 Resources

* [A set of data tutorials on working with HDF5 in R](http://neondataskills.org/HDF5/ "Working with HDF5 in R")


# Python Code to Open HDF5 files

The code below is starter code to create an H5 file in Python.

	import h5py

	# create the new H5 file

	hFile = h5py.File('data/brightPixelsH5/bri' + plot + '.h5', 'a') 
	#grp = hFile.create_group("Reflectance")
	#create the reflectance group
	hFile['Reflectance'] = brightPixels
	hFile.close()
