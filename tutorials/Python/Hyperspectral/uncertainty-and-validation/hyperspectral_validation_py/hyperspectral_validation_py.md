---
syncID: 84457ead9b964c8d916eacde9f271ec7
title: "Assessing Spectrometer Accuracy using Validation Tarps with Python"
description: "Comparison of reflectance curves collected over spectral validation tarps with ASD and NIS sensors." 
dateCreated: 2017-06-21 
authors: Tristan Goulden
contributors: Donal O'Leary, Bridget Hass
estimatedTime: 0.5 hour
packagesLibraries: h5py, gdal, requests
topics: hyperspectral-remote-sensing, remote-sensing
languagesTool: python
dataProduct: 
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/uncertainty-and-validation/hyperspectral_validation_py/hyperspectral_validation_py.ipynb
tutorialSeries: rs-uncertainty-py-series
urlTitle: hyperspectral-validation-py
---

In this tutorial we will learn how to retrieve reflectance curves from a pre-specified coordinate in a NEON AOP HDF5 file, retrieve bad band window indexes and mask portions of a reflectance curve, plot reflectance curves, and gain an understanding of some sources of uncertainty in Neon Imaging Spectrometer (NIS) data.

<div id="ds-objectives" markdown="1">

### Objectives
After completing this tutorial, you will be able to:

* Retrieve reflectance curves from a pre-specified coordinate in a NEON AOP HDF5 file
* Retrieve bad band window indices and mask these invalid portions of the reflectance curves
* Plot reflectance curves on a graph and save the file
* Explain some sources of uncertainty in NEON Image Spectrometry data

### Install Python Packages

* **gdal** 
* **h5py** 
* **requests**


### Download Data

To complete this tutorial, you will use data available from the NEON 2017 Data Institute.

This tutorial uses the following files:

<ul>
<li>CHEQ_Tarp_03_02_refl_bavg.txt (9 KB)</li>
<li>CHEQ_Tarp_48_01_refl_bavg.txt (9 KB)</li>
<li>NEON_D05_CHEQ_DP1_20160912_160540_reflectance.h5 (2.7 GB)</li>
</ul>

Which may be downloaded <a href="https://neondata.sharefile.com/share/view/cdc8242e24ad4517/fofeb6d6-9ebf-4310-814f-9ae4aea8fbd9" target="_blank">from our ShareFile directory here<a/>.

<a href="https://neondata.sharefile.com/share/view/cdc8242e24ad4517/fofeb6d6-9ebf-4310-814f-9ae4aea8fbd9" class="link--button link--arrow">
Download Dataset</a>

The LiDAR and imagery data used to create this raster teaching data subset were collected over the 
<a href="http://www.neonscience.org/" target="_blank"> National Ecological Observatory Network</a>'s
<a href="http://www.neonscience.org/science-design/field-sites/" target="_blank" >field sites</a> and processed at NEON headquarters.
The entire dataset can be accessed on the <a href="http://data.neonscience.org" target="_blank">NEON Data Portal</a>.
    
**Download the CHEQ Reflectance File:** <a href="https://storage.googleapis.com/neon-aop-products/2016/FullSite/D05/2016_CHEQ_2/L1/Spectrometer/ReflectanceH5/NEON_D05_CHEQ_DP1_20160912_160540_reflectance.h5" class="link--button link--arrow">NEON_D05_CHEQ_DP1_20160912_160540_reflectance.h5</a>
    
These data are a part of the NEON 2017 Remote Sensing Data Institute. The complete archive may be found here -<a href="https://neondata.sharefile.com/d-s11d5c8b9c53426db"> NEON Teaching Data Subset: Data Institute 2017 Data Set</a>


### Recommended prerequisites

We recommend you complete the following tutorials prior to this tutorial: 

1.  <a href="https://www.neonscience.org/neon-aop-hdf5-py"> *NEON AOP Hyperspectral Data in HDF5 format with Python*</a>
1.  <a href="https://www.neonscience.org/neon-hsi-aop-functions-python"> *Band Stacking, RGB & False Color Images, and Interactive Widgets in Python*</a>
1.  <a href="https://www.neonscience.org/plot-spec-sig-python/"> *Plot a Spectral Signature in Python*</a>

</div>

In this tutorial we will be examining the accuracy of the Neon Imaging Spectrometer (NIS) against targets with known reflectance values. The targets consist of two 10 x 10 m tarps which have been specially designed to have 3% reflectance (black tarp) and 
48% reflectance (white tarp) across all of the wavelengths collected by the NIS (see images below). During the Sept. 12 2016 flight over the Chequamegon-Nicolet National Forest (CHEQ), an area in D05 which is part of Steigerwaldt (STEI) site, these tarps were deployed in a gravel pit. During the airborne overflight, observations were also taken over the tarps with an Analytical Spectral Device (ASD), which is a hand-held field spectrometer. The ASD measurements provide a validation source against the airborne measurements. 

 <figure class="half">
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/neon-aop/tarps_close.jpg">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/neon-aop/tarps_close.jpg">
	</a>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/neon-aop/tarps_far.jpg">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/neon-aop/tarps_far.jpg">
	</a>
</figure>  
 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/neon-aop/tarps_aerial.jpg">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/neon-aop/tarps_aerial.jpg"></a>
	<figcaption> The validation tarps, 3% reflectance (black tarp) and 48% reflectance (white tarp), laid out in the field. 
	Source: National Ecological Observatory Network (NEON)  
	</figcaption>
</figure>

To test the accuracy, we will plot reflectance curves from the ASD measurments over the spectral tarps as well as reflectance curves from the NIS over the associated flight line. We can then carry out absolute and relative comparisons. The major error sources in the NIS can be generally categorized into the following components:

1. Calibration of the sensor
2. Quality of ortho-rectification
3. Accuracy of radiative transfer code and subsequent ATCOR interpolation
4. Selection of atmospheric input parameters
5. Terrain relief
6. Terrain cover

Note that ATCOR (the atmospheric correction software used by AOP) specifies the accuracy of reflectance retrievals to be between 3 and 5% of total reflectance. The tarps are located in a flat area, therefore, influences by terrain relief should be minimal. We will have to keep the remining errors in mind as we analyze the data. 


## Get Started

We'll start by importing all of the necessary packages to our python script.


```python
import os, sys
import numpy as np
import requests
import h5py
import csv
import gdal
import matplotlib.pyplot as plt
%matplotlib inline
```

As well as our function to read the hdf5 reflectance files and associated metadata


```python
def h5refl2array(h5_filename):
    hdf5_file = h5py.File(h5_filename,'r')

    #Get the site name
    file_attrs_string = str(list(hdf5_file.items()))
    file_attrs_string_split = file_attrs_string.split("'")
    sitename = file_attrs_string_split[1]
    refl = hdf5_file[sitename]['Reflectance']
    reflArray = refl['Reflectance_Data']
    refl_shape = reflArray.shape
    wavelengths = refl['Metadata']['Spectral_Data']['Wavelength']
    #Create dictionary containing relevant metadata information
    metadata = {}
    metadata['shape'] = reflArray.shape
    metadata['mapInfo'] = refl['Metadata']['Coordinate_System']['Map_Info']
    #Extract no data value & set no data value to NaN\n",
    metadata['scaleFactor'] = float(reflArray.attrs['Scale_Factor'])
    metadata['noDataVal'] = float(reflArray.attrs['Data_Ignore_Value'])
    metadata['bad_band_window1'] = (refl.attrs['Band_Window_1_Nanometers'])
    metadata['bad_band_window2'] = (refl.attrs['Band_Window_2_Nanometers'])
    metadata['projection'] = refl['Metadata']['Coordinate_System']['Proj4'][()]
    metadata['EPSG'] = int(refl['Metadata']['Coordinate_System']['EPSG Code'][()])
    mapInfo = refl['Metadata']['Coordinate_System']['Map_Info'][()]
    mapInfo_string = str(mapInfo); #print('Map Info:',mapInfo_string)\n",
    mapInfo_split = mapInfo_string.split(",")
    #Extract the resolution & convert to floating decimal number
    metadata['res'] = {}
    metadata['res']['pixelWidth'] = mapInfo_split[5]
    metadata['res']['pixelHeight'] = mapInfo_split[6]
    #Extract the upper left-hand corner coordinates from mapInfo\n",
    xMin = float(mapInfo_split[3]) #convert from string to floating point number\n",
    yMax = float(mapInfo_split[4])
    #Calculate the xMax and yMin values from the dimensions\n",
    xMax = xMin + (refl_shape[1]*float(metadata['res']['pixelWidth'])) #xMax = left edge + (# of columns * resolution)\n",
    yMin = yMax - (refl_shape[0]*float(metadata['res']['pixelHeight'])) #yMin = top edge - (# of rows * resolution)\n",
    metadata['extent'] = (xMin,xMax,yMin,yMax),
    metadata['ext_dict'] = {}
    metadata['ext_dict']['xMin'] = xMin
    metadata['ext_dict']['xMax'] = xMax
    metadata['ext_dict']['yMin'] = yMin
    metadata['ext_dict']['yMax'] = yMax
    hdf5_file.close        
    return reflArray, metadata, wavelengths
```

Define the directory where you are storing the data for the data institute. The `h5_filename` is the flightline which contains the tarps, and the tarp_48_filename and tarp_03_filename contain the field validated spectra for the white and black tarp respectively, organized by wavelength and reflectance.


```python
## You will need to change these filepaths according to how you've set up your directory
## As you can see here, I saved the files downloaded above into a sub-directory named "./data"
h5_filename = r'./data/NEON_D05_CHEQ_DP1_20160912_160540_reflectance.h5'
```

Define a function that will read in the contents of a url and write it out to a file:


```python
def url_to_file(url,outfile):
    response = requests.get(url)
    open(outfile,"wb").write(response.content)
```

Run the function on the two urls where the ASD reflectance data is saved, in the NEON-Data-Skills GitHub repository for this lesson.


```python
tarp_03_url = "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/uncertainty-and-validation/hyperspectral_validation_py/data/CHEQ_Tarp_03_02_refl_bavg.txt"
tarp_48_url = "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/uncertainty-and-validation/hyperspectral_validation_py/data/CHEQ_Tarp_48_01_refl_bavg.txt"

url_to_file(tarp_48_url,'./data/CHEQ_Tarp_48_01_refl_bavg.txt')
url_to_file(tarp_03_url,'./data/CHEQ_Tarp_03_02_refl_bavg.txt')
```


```python
tarp_48_filename = r'./data/CHEQ_Tarp_48_01_refl_bavg.txt'
tarp_03_filename = r'./data/CHEQ_Tarp_03_02_refl_bavg.txt'
```

We want to pull the spectra from the airborne data from the center of the tarp to minimize any errors introduced by infiltrating light in adjacent pixels, or through errors in ortho-rectification (source 2). We have pre-determined the coordinates for the center of each tarp which are as follows:

48% reflectance tarp UTMx: 727487, UTMy: 5078970

3% reflectance tarp UTMx: 727497, UTMy: 5078970

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/neon-aop/tarp_centers.jpg">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/neon-aop/tarp_centers.jpg"></a>
	<figcaption> The validation tarps,  3% reflectance (black tarp) and 
48% reflectance (white tarp), laid out in the field. 
	Source: National Ecological Observatory Network (NEON)  
	</figcaption>
</figure>

Let's define these coordinates:


```python
tarp_48_center = np.array([727487,5078970])
tarp_03_center = np.array([727497,5078970])
```

Now we'll use our function designed for NEON AOP's HDF5 files to access the hyperspectral data


```python
[reflArray,metadata,wavelengths] = h5refl2array(h5_filename)
```

Within the reflectance curves there are areas with noisy data due to atmospheric windows in the water absorption bands. For this exercise we do not want to plot these areas as they obscure details in the plots due to their anomolous values. The metadata associated with these band locations is contained in the metadata gathered by our function. We will pull out these areas as 'bad band windows' and determine which indices in the reflectance curves encompass these bad bands.


```python
bad_band_window1 = (metadata['bad_band_window1'])
bad_band_window2 = (metadata['bad_band_window2'])

index_bad_window1 = [i for i, x in enumerate(wavelengths) if x > bad_band_window1[0] and x < bad_band_window1[1]]
index_bad_window2 = [i for i, x in enumerate(wavelengths) if x > bad_band_window2[0] and x < bad_band_window2[1]]
```

Now join the list of indexes together into a single variable


```python
index_bad_windows = index_bad_window1 + index_bad_window2
```

The reflectance data is saved in files which are 'tab delimited.' We will use a numpy function (genfromtxt) to quickly import the tarp reflectance curves observed with the ASD using the '\t' delimiter to indicate tabs are used.


```python
tarp_48_data = np.genfromtxt(tarp_48_filename, delimiter = '\t')
tarp_03_data = np.genfromtxt(tarp_03_filename, delimiter = '\t')
```

Now we'll set all the data inside of those windows to NaNs (not a number) so they will not be included in the plots


```python
tarp_48_data[index_bad_windows] = np.nan
tarp_03_data[index_bad_windows] = np.nan
```

The next step is to determine which pixel in the reflectance data belongs to the center of each tarp. To do this, we will subtract the tarp center pixel location from the upper left corner pixels specified in the map info of the H5 file. This information is saved in the metadata dictionary output from our function that reads NEON AOP HDF5 files. The difference between these coordinates gives us the x and y index of the reflectance curve. 


```python
x_tarp_48_index = int((tarp_48_center[0] - metadata['ext_dict']['xMin'])/float(metadata['res']['pixelWidth']))
y_tarp_48_index = int((metadata['ext_dict']['yMax'] - tarp_48_center[1])/float(metadata['res']['pixelHeight']))

x_tarp_03_index = int((tarp_03_center[0] - metadata['ext_dict']['xMin'])/float(metadata['res']['pixelWidth']))
y_tarp_03_index = int((metadata['ext_dict']['yMax'] - tarp_03_center[1])/float(metadata['res']['pixelHeight']))
```

Next, we will plot both the curve from the airborne data taken at the center of the tarps as well as the curves obtained from the ASD data to provide a visualization of their consistency for both tarps. Once generated, we will also save the figure to a pre-determined location.


```python
plt.figure(1)
tarp_48_reflectance = np.asarray(reflArray[y_tarp_48_index,x_tarp_48_index,:], dtype=np.float32)/metadata['scaleFactor']
tarp_48_reflectance[index_bad_windows] = np.nan
plt.plot(wavelengths,tarp_48_reflectance,label = 'Airborne Reflectance')
plt.plot(wavelengths,tarp_48_data[:,1], label = 'ASD Reflectance')
plt.title('CHEQ 20160912 48% tarp')
plt.xlabel('Wavelength (nm)'); plt.ylabel('Reflectance (%)')
plt.legend()
#plt.savefig('CHEQ_20160912_48_tarp.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)

plt.figure(2)
tarp_03_reflectance = np.asarray(reflArray[y_tarp_03_index,x_tarp_03_index,:], dtype=np.float32)/ metadata['scaleFactor']
tarp_03_reflectance[index_bad_windows] = np.nan
plt.plot(wavelengths,tarp_03_reflectance,label = 'Airborne Reflectance')
plt.plot(wavelengths,tarp_03_data[:,1],label = 'ASD Reflectance')
plt.title('CHEQ 20160912 3% tarp')
plt.xlabel('Wavelength (nm)'); plt.ylabel('Reflectance (%)')
plt.legend()
#plt.savefig('CHEQ_20160912_3_tarp.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)
```




    <matplotlib.legend.Legend at 0x21a44ffdef0>




    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/uncertainty-and-validation/hyperspectral_validation_py/hyperspectral_validation_py_files/hyperspectral_validation_py_27_1.png)
    



    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/uncertainty-and-validation/hyperspectral_validation_py/hyperspectral_validation_py_files/hyperspectral_validation_py_27_2.png)
    


This produces plots showing the results of the ASD and airborne measurements over the 48% tarp. Visually, the comparison between the two appears to be fairly good. However, over the 3% tarp we appear to be over-estimating the reflectance. Large absolute differences could be associated with ATCOR input parameters (source 4). For example, the user must input the local visibility, which is related to aerosol optical thickness (AOT). We don't measure this at every site, therefore input a standard parameter for all sites. 

Given the 3% reflectance tarp has much lower overall reflectance, it may be more informative to determine what the absolute difference between the two curves are and plot that as well.


```python
plt.figure(3)
plt.plot(wavelengths,tarp_48_reflectance-tarp_48_data[:,1]);
plt.title('CHEQ 20160912 48% tarp absolute difference')
plt.xlabel('Wavelength (nm)'); plt.ylabel('Absolute Reflectance Difference (%)')
#plt.savefig('CHEQ_20160912_48_tarp_absolute_diff.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)

plt.figure(4)
plt.plot(wavelengths,tarp_03_reflectance-tarp_03_data[:,1]);
plt.title('CHEQ 20160912 3% tarp absolute difference')
plt.xlabel('Wavelength (nm)'); plt.ylabel('Absolute Reflectance Difference (%)')
#plt.savefig('CHEQ_20160912_3_tarp_absolute_diff.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)
```




    Text(0, 0.5, 'Absolute Reflectance Difference (%)')




    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/uncertainty-and-validation/hyperspectral_validation_py/hyperspectral_validation_py_files/hyperspectral_validation_py_29_1.png)
    



    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/uncertainty-and-validation/hyperspectral_validation_py/hyperspectral_validation_py_files/hyperspectral_validation_py_29_2.png)
    


From this we are able to see that the 48% tarp actually has larger absolute differences than the 3% tarp. The 48% tarp performs poorly at the shortest and longest wavelenghths as well as near the edges of the bad band windows. This is related to difficulty in calibrating the sensor in these sensitive areas.

Let's now determine the result of the percent difference, which is the metric used by ATCOR to report accuracy. We can do this by calculating the ratio of the absolute difference between curves to the total reflectance 


```python
tarp_48_data[:,1]
```




    array([0.121788, 0.160818, 0.216826, 0.280265, 0.334808, 0.380589,
           0.413413, 0.433559, 0.444485, 0.450452, 0.454328, 0.456934,
           0.458164, 0.458219, 0.458207, 0.458725, 0.459779, 0.460989,
           0.461874, 0.462423, 0.462963, 0.463569, 0.464248, 0.465105,
           0.466048, 0.466847, 0.467611, 0.468346, 0.46896 , 0.469598,
           0.470219, 0.470866, 0.471497, 0.472077, 0.472633, 0.473202,
           0.473755, 0.474293, 0.4748  , 0.47525 , 0.475699, 0.476177,
           0.476548, 0.47684 , 0.477132, 0.477405, 0.477678, 0.47797 ,
           0.478232, 0.478512, 0.478828, 0.479103, 0.479391, 0.479756,
           0.480031, 0.480293, 0.48051 , 0.480775, 0.481088, 0.481456,
           0.481886, 0.482414, 0.483037, 0.483599, 0.484092, 0.484528,
           0.485042, 0.485752, 0.486196, 0.486552, 0.486706, 0.486904,
           0.487149, 0.487388, 0.487638, 0.487778, 0.4882  , 0.488394,
           0.488585, 0.488787, 0.488988, 0.489209, 0.489405, 0.489585,
           0.489761, 0.489939, 0.490322, 0.490612, 0.490716, 0.490818,
           0.4909  , 0.490982, 0.491079, 0.491207, 0.491312, 0.491358,
           0.491472, 0.491716, 0.492005, 0.492253, 0.492359, 0.49249 ,
           0.49279 , 0.493168, 0.493381, 0.493678, 0.494038, 0.494165,
           0.494463, 0.49519 , 0.49663 , 0.497262, 0.497001, 0.497265,
           0.497263, 0.496609, 0.496609, 0.496721, 0.497002, 0.497194,
           0.497143, 0.49712 , 0.497101, 0.496773, 0.496415, 0.496613,
           0.496802, 0.497018, 0.497188, 0.497496, 0.497683, 0.497924,
           0.498253, 0.498547, 0.498915, 0.499159, 0.499495, 0.499761,
           0.49994 , 0.500202, 0.500416, 0.500666, 0.500886, 0.501175,
           0.501216, 0.501128, 0.500913, 0.500132, 0.49828 , 0.497128,
           0.497843, 0.499116, 0.499811, 0.499224, 0.498039, 0.497003,
           0.496174, 0.495268, 0.494706, 0.494722, 0.495469, 0.496931,
           0.498487, 0.499903, 0.501136, 0.502171, 0.503026, 0.50382 ,
           0.504519, 0.505136, 0.505637, 0.506106, 0.506538, 0.506905,
           0.507184, 0.507431, 0.507631, 0.507776, 0.508015, 0.508237,
           0.508349, 0.508496, 0.508745, 0.508879, 0.508884, 0.508895,
           0.508842, 0.50876 , 0.508753, 0.508731, 0.508595,      nan,
                nan,      nan,      nan,      nan,      nan,      nan,
                nan,      nan,      nan,      nan,      nan,      nan,
                nan,      nan,      nan,      nan,      nan,      nan,
                nan,      nan, 0.500724, 0.501443, 0.501882, 0.502405,
           0.503445, 0.504123, 0.504607, 0.505218, 0.505398, 0.505546,
           0.50591 , 0.506314, 0.50663 , 0.506994, 0.507422, 0.507812,
           0.508068, 0.508322, 0.508611, 0.508949, 0.509306, 0.509588,
           0.509824, 0.51006 , 0.510256, 0.51027 , 0.510142, 0.510059,
           0.510015, 0.509834, 0.509292, 0.508229, 0.506335, 0.503454,
           0.500722, 0.498298, 0.495159, 0.490211, 0.481073, 0.466128,
           0.44719 , 0.427172, 0.410201, 0.402405, 0.405679, 0.413461,
           0.419474, 0.424605, 0.430833, 0.437146, 0.440286, 0.439418,
           0.437765, 0.437313, 0.437048, 0.436279, 0.43626 , 0.438038,
           0.442135, 0.447952, 0.453341, 0.457276, 0.460517, 0.463678,
           0.466676, 0.469739, 0.473058, 0.475525, 0.475921,      nan,
                nan,      nan,      nan,      nan,      nan,      nan,
                nan,      nan,      nan,      nan,      nan,      nan,
                nan,      nan,      nan,      nan,      nan,      nan,
                nan,      nan,      nan,      nan,      nan,      nan,
                nan,      nan,      nan,      nan,      nan,      nan,
                nan,      nan, 0.450145, 0.458835, 0.463486, 0.46657 ,
           0.468216, 0.470486, 0.471366, 0.472068, 0.47199 , 0.471806,
           0.473358, 0.474828, 0.475048, 0.473184, 0.471565, 0.470709,
           0.469972, 0.468168, 0.466824, 0.465904, 0.464248, 0.461999,
           0.458016, 0.451662, 0.44546 , 0.440819, 0.439168, 0.439065,
           0.438856, 0.434764, 0.424311, 0.408778, 0.390798, 0.37346 ,
           0.358592, 0.349597, 0.352219, 0.363315, 0.370883, 0.368763,
           0.36506 , 0.370371, 0.383274, 0.391535, 0.388688, 0.383377,
           0.386067, 0.395072, 0.40213 , 0.402646, 0.399069, 0.392176,
           0.379512, 0.360791, 0.33871 , 0.316484, 0.292645, 0.269174,
           0.250462, 0.237732, 0.230719, 0.232093, 0.240928, 0.249906,
           0.25612 , 0.258627, 0.256236, 0.250489, 0.244231, 0.240549,
           0.241694, 0.2455  , 0.247288, 0.246305, 0.242526, 0.239912,
           0.239862, 0.242515, 0.2456  , 0.246742, 0.247656, 0.249268,
           0.252251, 0.255312, 0.259093, 0.258131, 0.254262, 0.248264,
           0.246521, 0.249996, 0.251353, 0.248547, 0.244414, 0.243021,
           0.243496, 0.234959, 0.211548, 0.198077, 0.196922, 0.208538,
           0.226896, 0.231941, 0.228166, 0.220366, 0.202834, 0.118315,
           0.028503, 0.060764, 0.100254, 0.262053, 0.306834, 0.307893])




```python
plt.figure(5)
relative_diff_48 = 100*(np.divide(tarp_48_reflectance-tarp_48_data[:,1],tarp_48_data[:,1]))
plt.plot(wavelengths,100*np.divide(tarp_48_reflectance-tarp_48_data[:,1],tarp_48_data[:,1]));
plt.title('CHEQ 20160912 48% tarp percent difference')
plt.xlabel('Wavelength (nm)'); plt.ylabel('Percent Reflectance Difference')
plt.ylim((-100,100))
#plt.savefig('CHEQ_20160912_48_tarp_relative_diff.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)

plt.figure(6)
plt.plot(wavelengths,100*np.divide(tarp_03_reflectance-tarp_03_data[:,1],tarp_03_data[:,1]));
plt.title('CHEQ 20160912 3% tarp percent difference')
plt.xlabel('Wavelength (nm)'); plt.ylabel('Percent Reflectance Difference')
plt.ylim((-100,150))
#plt.savefig('CHEQ_20160912_3_tarp_relative_diff.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)
```




    (-100, 150)




    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/uncertainty-and-validation/hyperspectral_validation_py/hyperspectral_validation_py_files/hyperspectral_validation_py_32_1.png)
    



    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/uncertainty-and-validation/hyperspectral_validation_py/hyperspectral_validation_py_files/hyperspectral_validation_py_32_2.png)
    




From these plots we can see that even though the absolute error on the 48% tarp was larger, the relative error on the 48% tarp is generally much smaller. The 3% tarp can have errors exceeding 50% for most of the tarp. This indicates that targets with low reflectance values may have higher relative errors.


