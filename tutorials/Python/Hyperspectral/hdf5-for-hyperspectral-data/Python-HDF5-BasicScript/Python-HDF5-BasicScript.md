---
syncID: a9b616f171be48d7a0ea2d539de11c87
title: "Open HDF5 files with Python Sample Code" 
description: "This tutorial provides basic code for opening an HDF5 file in Python using the h5py, numpy, and matplotlib libraries."
dateCreated: 2015-5-08
dateUpdated: 2020-04-24
authors: David Hulslander, Josh Elliot, Leah A. Wasser, Tristan Goulden
contributors: Maria Paula Mugnani
estimatedTime: 0.5 hours
packagesLibraries: h5py, numpy, matplotlib
topics: HDF5
languagesTool: python
dataProduct:
code1: 
tutorialSeries:
urlTitle: hdf5-intro-python
---

<div id="ds-objectives" markdown="1">

## Objectives 

At the end of this tutorial you will be able to

* open an HDF5 file with Python. 


## Data to Download

<h3><a href="https://ndownloader.figshare.com/files/7024985" > NEON Teaching Data Subset: Sample Tower Temperature - HDF5 </a></h3>

These temperature data were collected by the
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map" target="_blank">flux towers at field sites across the US</a>.
The entire dataset can be accessed by request from the 
<a href="http://data.neonscience.org" target="_blank"> NEON Data Portal</a>.

<a href="https://ndownloader.figshare.com/files/7024985" class="link--button link--arrow">
Download Dataset </a>




<h3><a href="https://ndownloader.figshare.com/files/7024271">
Download NEON Teaching Data Subset: Imaging Spectrometer Data - HDF5 </a></h3>

These hyperspectral remote sensing data provide information on the
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank" > San Joaquin Exerimental Range field site.</a>
The data were collected over the San Joaquin field site located in California 
(Domain 17) and processed at NEON headquarters. The entire dataset can be accessed by request from the 
<a href="http://data.neonscience.org" target="_blank"> NEON Data Portal</a>.

<a href="https://ndownloader.figshare.com/files/7024271" class="link--button link--arrow">
Download Dataset</a>




</div>

In this tutorial, we'll work with 
<a href="https://www.neonscience.org/data-collection/flux-tower-measurements" target="_blank"> temperature data collected using sensors on a flux tower</a> 
by 
<a href="https://www.neonscience.org/" target="_blank">the National Ecological Observatory Network (NEON) </a>. 
Here the data are provided in a HDF5 format to allow for the exploration of this 
format. More on NEON temperature data can be found on the 
<a href="http://data.neonscience.org" target="_blank">the NEON Data Portal</a>. 
Please note that temperature data are distributed as a flat .csv file and not as an 
HDF5 file. NEON data products including eddy covariance data and remote sensing 
data are however released in the HDF5 format.

## Set working directory
After downloading these datasets, ensure to save them to one folder to simplify importing them later. Let's set your working directory to ensure it is correct.

```python
import os
wd=os.chdir('/yourfilepathhere') #change the file path to your working directory
wd=os.getcwd() #request what is the current working directory
print(wd) #show what is the current working directory
```

## Python Code to Open HDF5 files

The code below is starter code to create an H5 file in Python.
```python
    if __name__ == '__main__':
		# import required libraries
		import h5py as h5
		import numpy as np
		import matplotlib.pyplot as plt
    
		# Read H5 file
		f = h5.File("NEONDSImagingSpectrometerData.h5", "r")
		# Get and print list of datasets within the H5 file
		datasetNames = [n for n in f.keys()]
		for n in datasetNames:
			print(n)
 ```
 we can see that the datasets within the h5 file include on reflectance,
fwhm (full width half max, this is the distance in nanometers between the band center and the edge of the band), map info, spatialInfo and wavelength. Let's start by extracting the reflectance dataset specifically from the H5 file.

 ```python
		
		# extract reflectance data from the H5 file
		reflectance = f['Reflectance']
		# extract one pixel from the data
		reflectanceData = reflectance[:,49,392]
		reflectanceData = reflectanceData.astype(float)

		# divide the data by the scale factor to convert the integer values into floating point values
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
```
 
 Let's plot the wavelength and reflectance data.
 
```python
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
```
This new file "VegetationSpectra.h5" will appear in your personal working directory that you set at the beginning of this tutorial.
