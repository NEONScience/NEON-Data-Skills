---
layout: workshop
title: "ESA 2015: A Hands-On Primer for Working with Big Data in R: Introduction to Hierarchical Data Formats, Lidar Data & Efficient Data Visualization"
estimatedTime: 8.0 Hours
packagesLibraries: RHDF5, raster
language: [R]
date: 2015-08-09 10:49:52
dateCreated:   2015-6-29 10:49:52
lastModified: 2015-6-29 22:11:52
authors: Leah Wasser, Natalie Robinson, Claire Lunch, Kate Thibault, Sarah Elmendorf
tags: [Data-Workshops]
mainTag: Data-Workshops
description: "This workshop will providing hands on experience with working hierarchical data formats (HDF5), and lidar data in R. It will also cover spatial data analysis in R."
code1: 
image:
  feature: hierarchy_folder_green.png
  credit: Colin Williams NEON, Inc.
  creditlink: http://www.neoninc.org
permalink: /Data-Workshops/ESA15-Big-Data-In-R
comments: true 
---

###A NEON #WorkWithData Event

**Date:** 09 August 2015

Ecologists working across scales and integrating disparate datasets face new data management and analysis challenges that demand tools beyond the spreadsheet. This workshop will overview three key data formats: ASCII, HDF5 and las and several key data types including temperature data from a tower, vegetation structure data, hyperspectral imagery and lidar data, that are often encountered when working with ‘Big Data’.  It will provide an introduction to available tools in R for working with these formats and types.

<div id="objectives">

<h2>Background Materials</h2>

<h3>Things to Do Before the Workshop</h3>
<h4>Download The Data</h4>

<a href="{{ site.baseurl }}/data/rasterLayers_tif.zip" class="btn btn-success">
 DOWNLOAD NEON imagery data (tiff format) California Domain D17</a>
<a href="http://www.neonhighered.org/Data/LidarActivity/CHM_InSitu_Data.zip" class="btn btn-success"> 
DOWNLOAD Sample NEON LiDAR Data in Raster Format & Vegetation Sampling data</a>
<a href="http://neonhighered.org/Data/LidarActivity/r_filtered_256000_4111000.las" class="btn btn-success"> 
Download NEON Lidar Point Cloud Data</a>

<h4>Setup RStudio</h4>
To participate in the workshop, we recommend that you come with R and RSTUDIO 
installed. <a href = "http://cran.r-project.org/">R</a> is a programming language 
that specializes in statistical computing. It is a powerful tool for exploratory
 data analysis. To interact with R, we STRONGLY recommend 
<a href="http://www.rstudio.com/">RStudio</a>, an interactive development 
environment (IDE). 


<h4>Install R Packages</h4>
You can chose to install each library individually if you already have some installed.
Or you can download the script below and run it to install all libraries at once.

<ul>
<li>raster - install.packages("raster")</li>
<li>sp (installs with the raster library) - install.packages("sp") </li>
<li>rgdal - install.packages("rgdal")</li>
<li>maptools - install.packages("maptools")</li>
<li>ggplot2 - install.packages("ggplot2")</li>
<li>rgeos - install.packages("rgeos")</li>
<li>dplyr - install.packages("dplyr")</li>
<li>rhdf5 - <code>source("http://bioconductor.org/biocLite.R") ; biocLite("rhdf5")</code></li>
</ul>

<h2>Download the Free H5 Viewer</h2>

<p>The free H5 viewer will allow you to explore H5 data, using a graphic interface. 
</p>

<ul>
<li>
<a href="http://www.hdfgroup.org/products/java/release/download.html" target="_blank" class="btn btn-success"> HDF5 viewer can be downloaded from this page.</a>
</li>
</ul>

<a href="http://neondataskills.org/HDF5/Exploring-Data-HDFView/">More on the
 viewer here</a>

<h3>Please review the following:</h3>
<ul>
<li><a href="http://neondataskills.org/HDF5/About/">What is HDF5? A general overview.</a></li>
</ul>

</div>



##TENTATIVE SCHEDULE

* Please note that we are still developing the agenda for this workshop. The schedule below is subject to change.


| Time        | Topic         | Instructor | 
|-------------|---------------|------------|
| 8:00     | Welcome / Introductions / Logistics |          |
| 9:00     | [Raster Resolution, Extent & CRS in R](http://neondataskills.org/GIS-Spatial-Data/Working-With-Rasters/)       |            |
| 10:15 | ------- BREAK ------- |      |
| 10:30 | LiDAR Data Derived Rasters in R |      |
| 12:00 - 1:00 PM     | Lunch on Your Own |          |
| 1:15     | Introduction to HDF5 in R |          |
| 2:30 | ------- BREAK ------- |      |
| 2:45     | Hyperspectral Imagery in R  |          |
| 3:45 | ------- BREAK ------- |      |
| 4:00     | Hands On Activity?? |          |

 
# Useful HDF5 Resources

* [A set of data tutorials on working with HDF5 in R](http://neondataskills.org/HDF5/ "Working with HDF5 in R")

## Python resources for HDF5:
1. [Downloads, docs, etc on GitHub]( http://www.h5py.org/ )
2. [O’Reilly book on Python and HDF5! The modern stamp of legitimacy for programming.](https://www.hdfgroup.org/HDF5/examples/api18-py.html) 
3. [Python examples from the HDF5 people themselves!](https://www.hdfgroup.org/HDF5/examples/api18-py.html)



# Python Code to Open HDF5 files

The code below is starter code to create an H5 file in Python.

    if __name__ == '__main__':
		#import required libraries
		import h5py as h5
		import numpy as np
		import matplotlib.pyplot as plt
    
		# Read H5 file
		f = h5.File("NIS1_20130615_155109_atmcor.h5", "r")
		# Get and print list of datasets within the H5 file
		datasetNames = [n for n in f.keys()]
		for n in datasetNames:
			print(n)
		
		#extract reflectance data from the H5 file
		reflectance = f['Reflectance']
		#extract one pixel from the data
		reflectanceData = reflectance[:,49,392]
		reflectanceData = reflectanceData.astype(float)

		#divide the data by the scale factor
		#note: this information would be accessed from the metadata
		scaleFactor = 10000.0
		reflectanceData /= scaleFactor
		wavelength = f['wavelength']
		wavelengthData = wavelength[:]
		#transpose the data so wavelength values are in one column
		wavelengthData = np.reshape(wavelengthData, 426)
    
		# Print the attributes (metadata):
		print("Data Description : ", reflectance.attrs['Description'])
		print("Data dimensions : ", reflectance.shape, reflectance.attrs['DIMENSION_LABELS'])
		#print a list of attributes in the H5 file
		for n in reflectance.attrs:
		print(n)
		#close the h5 file
		f.close()
    
		# Plot
		plt.plot(wavelengthData, reflectanceData)
		plt.title("Vegetation Spectra")
		plt.ylabel('Reflectance')
		plt.ylim((0,1))
		plt.xlabel('Wavelength [$\mu m$]')
		plt.show()
	    
		# Write a new HDF file containing this spectrum
		f = h5.File("VegetationSpectra.h5", "w")
		rdata = f.create_dataset("VegetationSpectra", data=reflectanceData)
		attrs = rdata.attrs
		attrs.create("Wavelengths", data=wavelengthData)
		f.close()
