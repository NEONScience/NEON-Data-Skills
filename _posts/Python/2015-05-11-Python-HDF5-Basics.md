---
layout: post
title: "Opening HDF5 files with Python Sample Code" 
authors: [David Hulslander, Josh Elliot, Leah A. Wasser, Tristan Goulden]
date: 2015-5-08
dateCreated:   2015-5-08 
lastModified: 2017-02-08
packagesLibraries: [h5py, numpy, matplotlib]
language: [python]
categories:  [self-paced-tutorial]
tags: [HDF5]
mainTag: 
description: "This tutorial provides basic code for opening an HDF5 file in Python
using the h5py, numpy, and matplotlib libraries."
code1: 
image:
  feature: activitiesBanner.png
  credit: National Ecological Observatory Network (NEON)
  creditlink:
permalink: /self-paced-tutorial/Python-HDF5-basics
comments: true
---

<div id="objectives" markdown="1">

## Lesson Objectives 

At the end of this tutorial you will be able to

* open an HDF5 file with Python. 


## Data to Download

{% include/dataSubsets/_data_Sample-Tower-Temp-H5.html %}

{% include/dataSubsets/_data_Imaging-Spec-Data-H5.html %}

</div>


## Python Code to Open HDF5 files

The code below is starter code to create an H5 file in Python.

    if __name__ == '__main__':
		# import required libraries
		import h5py as h5
		import numpy as np
		import matplotlib.pyplot as plt
    
		# Read H5 file
		f = h5.File("NEON-DS-Imaging-Spectrometer-Data.h5", "r")
		# Get and print list of datasets within the H5 file
		datasetNames = [n for n in f.keys()]
		for n in datasetNames:
			print(n)
		
		# extract reflectance data from the H5 file
		reflectance = f['Reflectance']
		# extract one pixel from the data
		reflectanceData = reflectance[:,49,392]
		reflectanceData = reflectanceData.astype(float)

		# divide the data by the scale factor
		# note: this information would be accessed from the metadata
		scaleFactor = 10000.0
		reflectanceData /= scaleFactor
		wavelength = f['wavelength']
		wavelengthData = wavelength[:]
		#transpose the data so wavelength values are in one column
		wavelengthData = np.reshape(wavelengthData, 426)
    
		# Print the attributes (metadata):
		print("Data Description : ", reflectance.attrs['Description'])
		print("Data dimensions : ", reflectance.shape, reflectance.attrs['DIMENSION_LABELS'])
		# print a list of attributes in the H5 file
		for n in reflectance.attrs:
		print(n)
		# close the h5 file
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
