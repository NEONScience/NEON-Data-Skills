--- 
syncID: a6db1047adb34f41b9d17d6ed41f5fd5
title: "Exploring Uncertainty in LiDAR Data using Python"
description: "Learn to analyze the difference between rasters taken a few days apart to assess the uncertainty between days." 
dateCreated: 2017-06-21 
authors: Tristan Goulden
contributors: 
estimatedTime: 
packagesLibraries: numpy, gdal, matplotlib
topics: hyperspectral-remote-sensing, remote-sensing
languagesTool: python
dataProduct: 
code1: Python/remote-sensing/uncertainty/lidar_uncertainty_py.ipynb
tutorialSeries: rs-uncertainty-py-series
urlTitle: lidar-uncertainty-py
---

In this exercise we will analyze the several NEON level 3 lidar rasters to assess 
the uncertainty between days. 

<div id="ds-objectives" markdown="1">

### Objectives
After completing this tutorial, you will be able to:

* Load several tif files with metadata
* Difference tif files
* Create histograms
* Remove areas of DSM & DTMs through logical indexing of the CHM

### Install Python Packages

* numpy
* gdal
* matplotlib.pyplot
* h5py

### Download Data

The link below contains all the data from the 2017 Data Institute (17 GB). <strong>For this tutorial, we
need ONLY the data in the CHEQ, F07A, and PRIN subfolders.</strong> To minimize the size of your
download, please select only these subdirectories to download.

<a href="https://neondata.sharefile.com/d-s11d5c8b9c53426db" target="_blank"class="link--button link--arrow">
Download Uncertainty Exercises Dataset</a>


<a href="https://neondata.sharefile.com/d-sf52f09f65ca497b8" target="_blank"class="link--button link--arrow">
Download Uncertainty DI18 Extension Dataset</a>

</div>


In 2016 the NEON AOP flew the PRIN site in D11 on a poor weather day to 
ensure coverage of the site. The following day, the weather improved and the 
site was flown again to collect good weather spectrometer data. Having 
collections only one day apart provides an opportunity to assess LiDAR 
uncertainty because we should expect that nothing has chnaged between the 
two collects. In this exercise we will analyze the several NEON Level 3 lidar 
rasters to assess the uncertainty.

## Set up system

First, we'll set up our system and load needed packages. 


```python
import sys
sys.version
```




    '3.5.5 |Anaconda custom (64-bit)| (default, Apr 26 2018, 08:11:22) \n[GCC 4.2.1 Compatible Clang 4.0.1 (tags/RELEASE_401/final)]'




```python
import gdal
import h5py
import numpy as np
from math import floor
import os
import matplotlib.pyplot as plt
```

## Define functions

Next, we'll define a few functions that we will use throughout the code. 



```python
def plot_band_array(band_array,image_extent,title,cmap_title,colormap,colormap_limits):
    plt.imshow(diff_dsm_array,extent=image_extent)
    cbar = plt.colorbar(); plt.set_cmap(colormap); plt.clim(colormap_limits)
    cbar.set_label(cmap_title,rotation=270,labelpad=20)
    plt.title(title); ax = plt.gca()
    ax.ticklabel_format(useOffset=False, style='plain') 
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90)
```


```python
def raster2array(geotif_file):
    metadata = {}
    dataset = gdal.Open(geotif_file)
    metadata['array_rows'] = dataset.RasterYSize
    metadata['array_cols'] = dataset.RasterXSize
    metadata['bands'] = dataset.RasterCount
    metadata['driver'] = dataset.GetDriver().LongName
    metadata['projection'] = dataset.GetProjection()
    metadata['geotransform'] = dataset.GetGeoTransform()

    mapinfo = dataset.GetGeoTransform()
    metadata['pixelWidth'] = mapinfo[1]
    metadata['pixelHeight'] = mapinfo[5]

    metadata['ext_dict'] = {}
    metadata['ext_dict']['xMin'] = mapinfo[0]
    metadata['ext_dict']['xMax'] = mapinfo[0] + dataset.RasterXSize/mapinfo[1]
    metadata['ext_dict']['yMin'] = mapinfo[3] + dataset.RasterYSize/mapinfo[5]
    metadata['ext_dict']['yMax'] = mapinfo[3]

    metadata['extent'] = (metadata['ext_dict']['xMin'],metadata['ext_dict']['xMax'],
                          metadata['ext_dict']['yMin'],metadata['ext_dict']['yMax'])

    if metadata['bands'] == 1:
        raster = dataset.GetRasterBand(1)
        metadata['noDataValue'] = raster.GetNoDataValue()
        metadata['scaleFactor'] = raster.GetScale()

        # band statistics
        metadata['bandstats'] = {} #make a nested dictionary to store band stats in same 
        stats = raster.GetStatistics(True,True)
        metadata['bandstats']['min'] = round(stats[0],2)
        metadata['bandstats']['max'] = round(stats[1],2)
        metadata['bandstats']['mean'] = round(stats[2],2)
        metadata['bandstats']['stdev'] = round(stats[3],2)

        array = dataset.GetRasterBand(1).ReadAsArray(0,0,metadata['array_cols'],metadata['array_rows']).astype(np.float)
        array[array==int(metadata['noDataValue'])]=np.nan
        array = array/metadata['scaleFactor']
        return array, metadata

    elif metadata['bands'] > 1:
        print('More than one band ... need to modify function for case of multiple bands')
```

This next piece of code just helps identify where the script portion of our code starts. It is not essential to the code but can be useful when running scripts. 


```python
print('Start Uncertainty Script')
```

    Start Uncertainty Script


To start, we can define all of the input files. This will include two Digital Surface Model (DSMs) tifs from the flight days, two Digital Terrain Models (DTMs) from the flight days, and a single Canopy Height Model (CHM). In this case, all input GeoTiff rasters are a single tile of the site that measures 1000 m by 1000 m.


```python
dsm1_filename = '../data/Uncertainty/PRIN/2016_PRIN_1_607000_3696000_DSM.tif'
dsm2_filename = '../data/Uncertainty/PRIN/2016_PRIN_2_607000_3696000_DSM.tif'
dtm1_filename = '../data/Uncertainty/PRIN/2016_PRIN_1_607000_3696000_DTM.tif'
dtm2_filename = '../data/Uncertainty/PRIN/2016_PRIN_2_607000_3696000_DTM.tif'
chm_filename = '../data/Uncertainty/PRIN/2016_PRIN_1_607000_3696000_pit_free_CHM.tif'
```

Open all of the tif data in the previous files using the raster2array function written for NEON data.


```python
dsm1_array, dsm1_array_metadata = raster2array(dsm1_filename)
dsm2_array, dsm2_array_metadata = raster2array(dsm2_filename)
dtm1_array, dtm1_array_metadata = raster2array(dtm1_filename)
dtm2_array, dtm2_array_metadata = raster2array(dtm2_filename)
chm_array, chm_array_metadata = raster2array(chm_filename)

```

Since we want to know what the changed between the two days, we will create an array with any of the pixel differneces across the two arrays.  To do this let's subtract the two DSMs. 


```python
diff_dsm_array = np.subtract(dsm1_array,dsm2_array)
diff_dtm_array = np.subtract(dtm1_array,dtm2_array) 
```

Let's get some summary statistics for this DSM differences array. 


```python
diff_dsm_array_mean = np.mean(diff_dsm_array)
diff_dsm_array_std = np.std(diff_dsm_array)
print('Mean difference in DSMs: ',round(diff_dsm_array_mean,3),' (m)')
print('Standard deviations of difference in DSMs: ',round(diff_dsm_array_std,3),' (m)')
```

    Mean difference in DSMs:  0.019  (m)
    Standard deviations of difference in DSMs:  0.743  (m)


As a result we get the following:

* Mean difference in DSMs:  0.019  (m)
* Standard deviations of difference in DSMs:  0.743  (m)

The mean is close to zero indicating there was very little systematic bias between the two days. However, we notice that the standard deviation of the data is quite high at 0.743 meters. Generally we expect NEON LiDAR data to have an error below 0.15 meters! Let's take a look at a histogram of the DSM difference. We use the flatten function on the 2D `diff_dsm_array` to convert it into a 1D array which allows the `hist()` function to run faster.


```python
plt.figure(1)
plt.hist(diff_dsm_array.flatten(),100)
plt.title('Histogram of PRIN DSM')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.show()
```


![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/py-figs/lidar-uncertainty/output_19_0.png)



The histogram has long tails, obscuring the distribution near the center. To constrain the x-limits of the histogram we will use the mean and standard deviation just calculated. Since the data appears to be normally distributed, we can constrain the histogram to 95% of the data by including 2 standard deviations above and below the mean.   


```python
plt.figure(1)
plt.hist(diff_dsm_array.flatten(),100,range=[diff_dsm_array_mean-2*diff_dsm_array_std, diff_dsm_array_mean+2*diff_dsm_array_std])
plt.title('Histogram of PRIN DSM')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.show()
```


![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/py-figs/lidar-uncertainty/output_21_0.png)


The histogram shows a wide variation in DSM differences, with those at the 95% limit at around +/- 1.5 m. Let's take a look at the spatial distribution of the errors by plotting a map of the difference between the two DSMs. Here we'll also use the extra variable in the plot function to constrain the limits of the colorbar to 95% of the observations. 


```python
plt.figure(3)
plot_band_array(diff_dsm_array,dsm1_array_metadata['extent'],'DSM Difference','Difference (m)','bwr',[diff_dsm_array_mean-2*diff_dsm_array_std, diff_dsm_array_mean+2*diff_dsm_array_std])
plt.show()
```

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/py-figs/lidar-uncertainty/output_23_0.png)


It seems that there is a spatial pattern in the distribution of errors. Now let's take a look at the histogram and map for the difference in DTMs.


```python
diff_dtm_array_mean = np.nanmean(diff_dtm_array)
diff_dtm_array_std = np.nanstd(diff_dtm_array)
print('Mean difference in DTMs: ',round(diff_dtm_array_mean,3),' (m)')
print('Standard deviations of difference in DTMs: ',round(diff_dtm_array_std,3),' (m)')          

plt.figure(4)
plt.hist(diff_dtm_array.flatten()[~np.isnan(diff_dtm_array.flatten())],100,range=[diff_dtm_array_mean-2*diff_dtm_array_std, diff_dtm_array_mean+2*diff_dtm_array_std])
plt.title('Histogram of PRIN DTM')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.show()

plt.figure(5)
plot_band_array(diff_dtm_array,dtm1_array_metadata['extent'],'DTM Difference','Difference (m)','bwr',[diff_dtm_array_mean-2*diff_dtm_array_std, diff_dtm_array_mean+2*diff_dtm_array_std])
plt.show()
```

    Mean difference in DTMs:  0.014  (m)
    Standard deviations of difference in DTMs:  0.102  (m)



![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/py-figs/lidar-uncertainty/output_25_1.png)


![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/py-figs/lidar-uncertainty/output_25_2.png)


The overall magnitude of differences are smaller than in the DSM but the same spatial pattern of the error is evident. 

Now, we'll plot the Canopy Height Model (CHM) of the same area. In the CHM, the tree heights above ground are represented, with all ground pixels having zero elevation. This time we'll use a colorbar which shows the ground as light green and the highest vegetation as dark green. We can set the lower limit of the color bar to zero and the upper limit to the mean canopy height to get a good color variation. 


```python
chm_array_mean = np.nanmean(chm_array)
chm_array_std = np.nanstd(chm_array)
plt.figure(6)
plot_band_array(chm_array,dtm1_array_metadata['extent'],'Canopy height Model','Canopy height (m)','Greens',[0, chm_array_mean])
plt.savefig('PRIN_CHM.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)
plt.show()
```


![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/py-figs/lidar-uncertainty/output_27_0.png)


From the CHM, it appears the spatial distribution of error patterns follow the location of vegetation. 

Now let's isolate only the pixels in the difference DSM that correspond to vegetation location, calcualte the mean and standard deviation and plot the associated histogram. Before displaying the histogram, we'll remove the no data values from the difference DSM and the non-zero pixels from the CHM. To keep the number of elements the same in each vector to allow element-wise logical operations in Python, we have to remove the difference DSM no data elements from the CHM array as well. 


```python
diff_dsm_array_veg_mean = np.nanmean(diff_dsm_array[chm_array!=0.0])
diff_dsm_array_veg_std = np.nanstd(diff_dsm_array[chm_array!=0.0])
plt.figure(7)
print('Mean difference in DSMs on veg points: ',round(diff_dsm_array_veg_mean,3),' (m)')
print('Standard deviations of difference in DSMs on veg points: ',round(diff_dsm_array_veg_std,3),' (m)')

plt.figure(8)
diff_dsm_array_nodata_removed = diff_dsm_array[~np.isnan(diff_dsm_array)]
chm_dsm_nodata_removed = chm_array[~np.isnan(diff_dsm_array)]
plt.hist(diff_dsm_array_nodata_removed[chm_dsm_nodata_removed!=0.0],100,range=[diff_dsm_array_veg_mean-2*diff_dsm_array_veg_std, diff_dsm_array_veg_mean+2*diff_dsm_array_veg_std])
plt.title('Histogram of PRIN DSM (veg)')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.show()
```

    Mean difference in DSMs on veg points:  0.064  (m)
    Standard deviations of difference in DSMs on veg points:  1.381  (m)



![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/py-figs/lidar-uncertainty/output_29_1.png)


    <Figure size 432x288 with 0 Axes>


The results show a similar mean difference of near zero, but an extremely high standard deviation of 1.381 m! Since the DSM represents the top of the tree canopy, this provides the level of uncertainty we can expect in the canopy height in forests characteristic of the PRIN site using NEON LiDAR data. 

Next we'll calculate the statistics and plot the histogram of the DTM vegetated areas


```python
diff_dtm_array_veg_mean = np.nanmean(diff_dtm_array[chm_array!=0.0])
diff_dtm_array_veg_std = np.nanstd(diff_dtm_array[chm_array!=0.0])
plt.figure(9)
print('Mean difference in DTMs on veg points: ',round(diff_dtm_array_veg_mean,3),' (m)')
print('Standard deviations of difference in DTMs on veg points: ',round(diff_dtm_array_veg_std,3),' (m)')

plt.figure(10)
diff_dtm_array_nodata_removed = diff_dtm_array[~np.isnan(diff_dtm_array)] 
chm_dtm_nodata_removed = chm_array[~np.isnan(diff_dtm_array)]
plt.hist((diff_dtm_array_nodata_removed[chm_dtm_nodata_removed!=0.0]),100,range=[diff_dtm_array_veg_mean-2*diff_dtm_array_veg_std, diff_dtm_array_veg_mean+2*diff_dtm_array_veg_std])
plt.title('Histogram of PRIN DTM (veg)')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.show()
```

    Mean difference in DTMs on veg points:  0.023  (m)
    Standard deviations of difference in DTMs on veg points:  0.163  (m)



    <Figure size 432x288 with 0 Axes>



![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/DI-remote-sensing-Python/classify_raster_with_threshold_notebook/output_31_2.png)

Here we can see that the mean difference is almost zero at 0.023 m, and the variation in less than the DSM at 0.163 m. 

Although the variation is reduced, it is still larger than expected for LiDAR. This is because under vegetation there may not be much laser energy reaching the ground, and those points that do may return with lower signal. The sparsity of points leads to surface interpolation over larger areas which can miss variations in the topography. Since the distribution of LIDAR and their location varied for each day, this resulted in different terrain representations and a uncertianty in the ground surface. This shows that the accuracy of LiDAR DTMs is reduced when under vegetation.

Finally, let's look at the DTM difference on only the ground points (where CHM = 0).


```python
diff_dtm_array_ground_mean = np.nanmean(diff_dtm_array[chm_array==0.0])
diff_dtm_array_ground_std = np.nanstd(diff_dtm_array[chm_array==0.0])
print('Mean difference in DTMs on ground points: ',round(diff_dtm_array_ground_mean,3),' (m)')
print('Standard deviations of difference in DTMs on ground points: ',round(diff_dtm_array_ground_std,3),' (m)')

plt.figure(11)
plt.hist((diff_dtm_array_nodata_removed[chm_dtm_nodata_removed==0.0]),100,range=[diff_dtm_array_ground_mean-2*diff_dtm_array_ground_std, diff_dtm_array_ground_mean+2*diff_dtm_array_ground_std])
plt.title('Histogram of PRIN DTM (ground)')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.show()

```

    Mean difference in DTMs on ground points:  0.011  (m)
    Standard deviations of difference in DTMs on ground points:  0.068  (m)


![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/py-figs/lidar-uncertainty/output_33_1.png)


In the open ground scenario we are able to produce the error chatracteristics we expect with a mean difference of only 0.011 m and a variation of 0.068 m. 

This shows that the uncertainty we expect in the NEON LiDAR system (~0.15 m) is only valid in bare, open, hard surface scenarios. We cannot expect the accuracy of the LiDAR to reach this level when vegetation is present. Quantifying the top of the canopy is particularly difficult and can lead to uncertainty in excess of 1 m for any given pixel.  
