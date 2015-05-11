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

Please review, download and setup the following, prior to attending the brownbag.
<h3>Data to Download</h3>

<ul>
<li><a href="http://neondataskills.org/data/NEON_TowerDataD3_D10.hdf5" class="btn btn-success"> NEON Temperature Data: Sample H5 
Structure</a></li>
<li><a href="##" class="btn btn-success"> NEON Hyperspectral Data: Sample Data
</a></li>
<li><a href="http://neonhighered.org/Data/HDF5/1B.GPM.GMI.TB2014.20150325-S175130-E192403.006085.V03C.HDF5" class="btn btn-success"> EOS Sample Data</a></li>

</ul>

<h2>Download the Free H5 Viewer</h2>

<p>The free H5 viewer will allow you to explore H5 data, using a graphic interface. 
</p>

<ul>
<li>
<a href="http://www.hdfgroup.org/products/java/release/download.html" target="_blank" class="btn btn-success"> HDF5 viewer can be downloaded from this page.</a>
</li>
</ul>



<ul>
<li><a href="http://neondataskills.org/HDF5/Exploring-Data-HDFView/">More on the
 viewer here</a></li>
</ul>

<h3>Please review the following:</h3>
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
