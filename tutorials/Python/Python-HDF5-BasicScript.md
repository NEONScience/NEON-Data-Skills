---
syncID: a9b616f171be48d7a0ea2d539de11c87
title: "Opening HDF5 files with Python Sample Code" 
description: "This tutorial provides basic code for opening an HDF5 file in Python using the h5py, numpy, and matplotlib libraries."
dateCreated:   2015-5-08 
authors: David Hulslander, Josh Elliot, Leah A. Wasser, Tristan Goulden
contributors:
estimatedTime:
packagesLibraries: h5py, numpy, matplotlib
topics: HDF5
languagesTool: python
dataProduct:
code1: 
tutorialSeries:
---

<div id="objectives" markdown="1">

## Lesson Objectives 

At the end of this tutorial you will be able to

* open an HDF5 file with Python. 


## Data to Download

{% include/dataSubsets/_data_Sample-Tower-Temp-H5.html %}

{% include/dataSubsets/_data_Imaging-Spec-Data-H5.html %}

</div>

In this tutorial, we'll work with 
<a href="http://neonscience.org/science-design/collection-methods/flux-tower-measurements"> 
temperature data collected using sensors on a flux tower</a> 
by 
<a href="http://{{ site.baseurl }}" target="_blank">the National 
Ecological Observatory Network (NEON) </a>. Here the data is provided in a HDF5 
format to allow for the exploration of this format. More on NEON temperature 
data can be found on the 
<a href="http://data.neon.org" target="_blank">the NEON Data Portal</a>. 
Please note that temperature data is distributed as a flat .csv file and not as an 
HDF5 file. NEON data products including eddy covariance data and remote sensing 
data are however released in the HDF5 format.


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
