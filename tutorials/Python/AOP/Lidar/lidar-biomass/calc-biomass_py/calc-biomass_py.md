---
syncID: e6ccf19a4b454ca594388eeaa88ebe12
title: "Calculate Vegetation Biomass from LiDAR Data in Python"
description: "Learn to calculate the biomass of standing vegetation using a canopy height model data product." 
dateCreated: 2017-06-21 
authors: Tristan Goulden
contributors: Donal O'Leary, Bridget Hass
estimatedTime: 1 hour
packagesLibraries: os, sys, numpy, matplotlib, gdal, scipy, scikit-learn, scikit-image
topics: lidar, remote-sensing
languagesTool: python
dataProduct: DP1.10098.001, DP3.30015.001 
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/lidar-biomass/calc-biomass_py/calc-biomass_py.ipynb
tutorialSeries: intro-lidar-py-series
urlTitle: calc-biomass-py
---

<div id="ds-objectives" markdown="1">

In this tutorial, we will calculate the biomass for a section of the SJER site. We 
will be using the Canopy Height Model discrete LiDAR data product as well as NEON
field data on vegetation data. This tutorial will calculate Biomass for individual 
trees in the forest. 

### Objectives
After completing this tutorial, you will be able to:

* Learn how to apply a Gaussian smoothing kernel for high-frequency spatial filtering
* Apply a watershed segmentation algorithm for delineating tree crowns
* Calculate biomass predictor variables from a CHM
* Set up training data for biomass predictions
* Apply a Random Forest machine learning model to calculate biomass


### Install Python Packages

* **gdal** 
* **scipy** 
* **scikit-learn**
* **scikit-image**

The following packages should be part of the standard conda installation:
* **os**
* **sys**
* **numpy**
* **matplotlib**


### Download Data

If you have already downloaded the data set for the Data Institute, you have the 
data for this tutorial within the SJER directory. If you would like to just 
download the data for this tutorial use the following links. 

**Download the Training Data:** <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/lidar-biomass/calc-biomass_py/calc-biomass_py_files/SJER_Biomass_Training.csv" class="link--button link--arrow">SJER_Biomass_Training.csv</a>

**Download the SJER Canopy Height Model Tile:** <a href="https://storage.googleapis.com/neon-aop-products/2018/FullSite/D17/2018_SJER_3/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D17_SJER_DP3_256000_4106000_CHM.tif" class="link--button link--arrow">NEON_D17_SJER_DP3_256000_4106000_CHM.tif</a>

</div>

In this tutorial, we will calculate the biomass for a section of the SJER site. We will be using the Canopy Height Model discrete LiDAR data product as well as NEON field data on vegetation data. This tutorial will calculate biomass for individual 
trees in the forest. 

The calculation of biomass consists of four primary steps:

1. Delineate individual tree crowns
2. Calculate predictor variables for all individual trees
3. Collect training data
4. Apply a Random Forest regression model to estimate biomass from the predictor variables

In this tutorial we will use a watershed segmentation algorithm for delineating tree crowns (step 1) and and a Random Forest (RF) machine learning algorithm for relating the predictor variables to biomass (part 4). The predictor variables were 
selected following suggestions by Gleason et al. (2012) and biomass estimates were determined from DBH (diameter at breast height) measurements following relationships given in Jenkins et al. (2003). 

## Get Started

First, we will import some Python packages required to run various parts of the script:


```python
import os, sys
import gdal, osr
import numpy as np
import matplotlib.pyplot as plt
from scipy import ndimage as ndi
%matplotlib inline 
```

Next, we will add libraries from scikit-learn which will help with the watershed delination, determination of predictor variables and random forest algorithm


```python
#Import biomass specific libraries
from skimage.morphology import watershed
from skimage.feature import peak_local_max
from skimage.measure import regionprops
from sklearn.ensemble import RandomForestRegressor
```

We also need to specify the directory where we will find and save the data needed for this tutorial. You may need to change this line to follow a different working directory structure, or to suit your local machine. I have decided to save my data in the following directory:


```python
data_path = os.path.abspath(os.path.join(os.sep,'neon_biomass_tutorial','data'))
data_path
```




    'D:\\neon_biomass_tutorial\\data'



## Define functions 

Now we will define a few functions that allow us to more easily work with the NEON data. 

* `plot_band_array`: function to plot NEON geospatial raster data


```python
#Define a function to plot a raster band
def plot_band_array(band_array,image_extent,title,cmap_title,colormap,colormap_limits):
    plt.imshow(band_array,extent=image_extent)
    cbar = plt.colorbar(); plt.set_cmap(colormap); plt.clim(colormap_limits)
    cbar.set_label(cmap_title,rotation=270,labelpad=20)
    plt.title(title); ax = plt.gca()
    ax.ticklabel_format(useOffset=False, style='plain') 
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90)
```

* `array2raster`: function to convert a numpy array to a geotiff file


```python
def array2raster(newRasterfn,rasterOrigin,pixelWidth,pixelHeight,array,epsg):

    cols = array.shape[1]
    rows = array.shape[0]
    originX = rasterOrigin[0]
    originY = rasterOrigin[1]

    driver = gdal.GetDriverByName('GTiff')
    outRaster = driver.Create(newRasterfn, cols, rows, 1, gdal.GDT_Float32)
    outRaster.SetGeoTransform((originX, pixelWidth, 0, originY, 0, pixelHeight))
    outband = outRaster.GetRasterBand(1)
    outband.WriteArray(array)
    outRasterSRS = osr.SpatialReference()
    outRasterSRS.ImportFromEPSG(epsg)
    outRaster.SetProjection(outRasterSRS.ExportToWkt())
    outband.FlushCache()
```

* `raster2array`: function to conver rasters to an array


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
        metadata['bandstats'] = {} # make a nested dictionary to store band stats in same 
        stats = raster.GetStatistics(True,True)
        metadata['bandstats']['min'] = round(stats[0],2)
        metadata['bandstats']['max'] = round(stats[1],2)
        metadata['bandstats']['mean'] = round(stats[2],2)
        metadata['bandstats']['stdev'] = round(stats[3],2)

        array = dataset.GetRasterBand(1).ReadAsArray(0,0,
                                                     metadata['array_cols'],
                                                     metadata['array_rows']).astype(np.float)
        array[array==int(metadata['noDataValue'])]=np.nan
        array = array/metadata['scaleFactor']
        return array, metadata

    else:
        print('More than one band ... function only set up for single band data')
```

* `crown_geometric_volume_pct`: function to get the tree height and crown volume percentiles


```python
def crown_geometric_volume_pct(tree_data,min_tree_height,pct):
    p = np.percentile(tree_data, pct)
    tree_data_pct = [v if v < p else p for v in tree_data]
    crown_geometric_volume_pct = np.sum(tree_data_pct - min_tree_height)
    return crown_geometric_volume_pct, p
```

* `get_predictors`: function to get the predictor variables from the biomass data


```python
def get_predictors(tree,chm_array, labels):
    indexes_of_tree = np.asarray(np.where(labels==tree.label)).T
    tree_crown_heights = chm_array[indexes_of_tree[:,0],indexes_of_tree[:,1]]
    
    full_crown = np.sum(tree_crown_heights - np.min(tree_crown_heights))
    
    crown50, p50 = crown_geometric_volume_pct(tree_crown_heights,tree.min_intensity,50)
    crown60, p60 = crown_geometric_volume_pct(tree_crown_heights,tree.min_intensity,60)
    crown70, p70 = crown_geometric_volume_pct(tree_crown_heights,tree.min_intensity,70)
        
    return [tree.label,
            np.float(tree.area),
            tree.major_axis_length,
            tree.max_intensity,
            tree.min_intensity, 
            p50, p60, p70,
            full_crown, 
            crown50, crown60, crown70]
```

## Canopy Height Data

With everything set up, we can now start working with our data by define the file path to our CHM file. Note that you will need to change this and subsequent filepaths according to your local machine.


```python
chm_file = os.path.join(data_path,'NEON_D17_SJER_DP3_256000_4106000_CHM.tif')
chm_file
```




    'D:\\neon_biomass_tutorial\\data\\NEON_D17_SJER_DP3_256000_4106000_CHM.tif'



When we output the results, we will want to include the same file information as the input, so we will gather the file name information. 


```python
#Get info from chm file for outputting results
chm_name = os.path.basename(chm_file)
```

Now we will get the CHM data...


```python
chm_array, chm_array_metadata = raster2array(chm_file)
```

..., plot it, and save the figure.


```python
#Plot the original CHM
plt.figure(1)

#Plot the CHM figure
plot_band_array(chm_array,chm_array_metadata['extent'],
                'Canopy Height Model',
                'Canopy Height (m)',
                'Greens',[0, 9])
plt.savefig(os.path.join(data_path,chm_name.replace('.tif','.png')),dpi=300,orientation='landscape',
            bbox_inches='tight',
            pad_inches=0.1)
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/lidar-biomass/calc-biomass_py/calc-biomass_py_files/calc-biomass_py_25_0.png)
    


It looks like SJER primarily has low vegetation with scattered taller trees. 

## Create Filtered CHM

Now we will use a Gaussian smoothing kernal (convolution) across the data set to remove spurious high vegetation points. This will help ensure we are finding the treetops properly before running the watershed segmentation algorithm. 

For different forest types it may be necessary to change the input parameters. Information on the function can be found in the <a href="https://docs.scipy.org/doc/scipy-0.14.0/reference/generated/scipy.ndimage.filters.gaussian_filter.html" target="_blank">SciPy documentation</a>. 

Of most importance are the second and fifth inputs. The second input defines the standard deviation of the Gaussian smoothing kernal. Too large a value will apply too much smoothing, too small and some spurious high points may be left behind. The fifth, the truncate value, controls after how many standard deviations the Gaussian kernal will get cut off (since it theoretically goes to infinity).


```python
#Smooth the CHM using a gaussian filter to remove spurious points
chm_array_smooth = ndi.gaussian_filter(chm_array,2,mode='constant',cval=0,truncate=2.0)
chm_array_smooth[chm_array==0] = 0 
```

Now save a copy of filtered CHM. We will later use this in our code, so we'll output it into our data directory. 


```python
#Save the smoothed CHM
array2raster(os.path.join(data_path,'chm_filter.tif'),
             (chm_array_metadata['ext_dict']['xMin'],chm_array_metadata['ext_dict']['yMax']),
             1,-1,np.array(chm_array_smooth,dtype=float),32611)
```

## Determine local maximums

Now we will run an algorithm to determine local maximums within the image. Setting indices to `False` returns a raster of the maximum points, as opposed to a list of coordinates. The footprint parameter is an area where only a single peak can be found. This should be approximately the size of the smallest tree. Information on more sophisticated methods to define the window can be found in Chen (2006).  


```python
#Calculate local maximum points in the smoothed CHM
local_maxi = peak_local_max(chm_array_smooth,indices=False, footprint=np.ones((5, 5)))
```

Our new object `local_maxi` is an array of boolean values where each pixel is identified as either being the local maximum (`True`) or not being the local maximum (`False`). 


```python
local_maxi
```




    array([[False, False, False, ..., False, False, False],
           [False, False, False, ..., False, False, False],
           [False, False, False, ..., False, False, False],
           ...,
           [False, False, False, ..., False, False, False],
           [False, False, False, ..., False, False, False],
           [False, False, False, ..., False, False, False]])



This is helpful, but it can be difficult to visualize boolean values using our typical numeric plotting procedures as defined in the `plot_band_array` function above. Therefore, we will need to convert this boolean array to an numeric format to use this function. Booleans convert easily to integers with values of `False=0` and `True=1` using the `.astype(int)` method.


```python
local_maxi.astype(int)
```




    array([[0, 0, 0, ..., 0, 0, 0],
           [0, 0, 0, ..., 0, 0, 0],
           [0, 0, 0, ..., 0, 0, 0],
           ...,
           [0, 0, 0, ..., 0, 0, 0],
           [0, 0, 0, ..., 0, 0, 0],
           [0, 0, 0, ..., 0, 0, 0]])



Next we can plot the raster of local maximums by coercing the boolean array into an array of integers inline. The following figure shows the difference in finding local maximums for a filtered vs. non-filtered CHM.

We will save the graphics (.png) in an outputs folder sister to our working directory and data outputs (.tif) to our data directory. 


```python
#Plot the local maximums
plt.figure(2)
plot_band_array(local_maxi.astype(int),chm_array_metadata['extent'],
                'Maximum',
                'Maxi',
                'Greys',
                [0, 1])

plt.savefig(data_path+chm_name[0:-4]+ '_Maximums.png',
            dpi=300,orientation='landscape',
            bbox_inches='tight',pad_inches=0.1)

array2raster(data_path+'maximum.tif',
             (chm_array_metadata['ext_dict']['xMin'],chm_array_metadata['ext_dict']['yMax']),
             1,-1,np.array(local_maxi,dtype=np.float32),32611)
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/lidar-biomass/calc-biomass_py/calc-biomass_py_files/calc-biomass_py_37_0.png)
    


If we were to look at the overlap between the tree crowns and the local maxima from each method, it would appear a bit like this raster. 

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/raster-general/raster-classification-filter-vs-nonfilter.jpg" >
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/raster-general/raster-classification-filter-vs-nonfilter.jpg" width="70%"/></a>
	<figcaption> The difference in finding local maximums for a filtered vs. un-filtered CHM. 
	Source: National Ecological Observatory Network (NEON) 
	</figcaption>
</figure>


Apply labels to all of the local maximum points


```python
#Identify all the maximum points
markers = ndi.label(local_maxi)[0]
```

Next we will create a mask layer of all of the vegetation points so that the watershed segmentation will only occur on the trees and not extend into the surrounding ground points. Since 0 represent ground points in the CHM, setting the mask to 1 where the CHM is not zero will define the mask


```python
#Create a CHM mask so the segmentation will only occur on the trees
chm_mask = chm_array_smooth
chm_mask[chm_array_smooth != 0] = 1
```

## Watershed segmentation

As in a river system, a watershed is divided by a ridge that divides areas. Here our watershed are the individual tree canopies and the ridge is the delineation between each one. 

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/raster-general/raster-classification-watershed-segments.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/raster-general/raster-classification-watershed-segments.png" width="70%"></a>
	<figcaption> A raster classified based on watershed segmentation. 
	Source: National Ecological Observatory Network (NEON) 
	</figcaption>
</figure>

Next, we will perform the watershed segmentation which produces a raster of labels.


```python
#Perform watershed segmentation        
labels = watershed(chm_array_smooth, markers, mask=chm_mask)
labels_for_plot = labels.copy()
labels_for_plot = np.array(labels_for_plot,dtype = np.float32)
labels_for_plot[labels_for_plot==0] = np.nan
max_labels = np.max(labels)
```


```python
#Plot the segments      
plot_band_array(labels_for_plot,chm_array_metadata['extent'],
                'Crown Segmentation','Tree Crown Number',
                'Spectral',[0, max_labels])

plt.savefig(data_path+chm_name[0:-4]+'_Segmentation.png',
            dpi=300,orientation='landscape',
            bbox_inches='tight',pad_inches=0.1)

array2raster(data_path+'labels.tif',
             (chm_array_metadata['ext_dict']['xMin'],
              chm_array_metadata['ext_dict']['yMax']),
             1,-1,np.array(labels,dtype=float),32611)
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/lidar-biomass/calc-biomass_py/calc-biomass_py_files/calc-biomass_py_44_0.png)
    


Now we will get several properties of the individual trees will be used as predictor variables. 


```python
#Get the properties of each segment
tree_properties = regionprops(labels,chm_array)
```

Now we will get the predictor variables to match the (soon to be loaded) training data using the `get_predictors` function defined above. The first column will be segment IDs, the rest will be the predictor variables, namely the tree label, area, major_axis_length, maximum height, minimum height, height percentiles (p50, p60, p70), and crown geometric volume percentiles (full and percentiles 50, 60, and 70).


```python
predictors_chm = np.array([get_predictors(tree, chm_array, labels) for tree in tree_properties])
X = predictors_chm[:,1:]
tree_ids = predictors_chm[:,0]
```

## Training data

We now bring in the training data file which is a simple CSV file with no header. If you haven't yet downloaded this, you can scroll up to the top of the lesson and find the **Download Data** section. The first column is biomass, and the remaining columns are the same predictor variables defined above. The tree diameter and max height are defined in the NEON vegetation structure data along with the tree DBH. The field validated values are used for training, while the other were determined from the CHM and camera images by manually delineating the tree crowns and pulling out the relevant information from the CHM. 

Biomass was calculated from DBH according to the formulas in Jenkins et al. (2003). 


```python
#Get the full path + training data file
training_data_file = os.path.join(data_path,'SJER_Biomass_Training.csv')

#Read in the training data csv file into a numpy array
training_data = np.genfromtxt(training_data_file,delimiter=',') 

#Grab the biomass (Y) from the first column
biomass = training_data[:,0]

#Grab the biomass predictors from the remaining columns
biomass_predictors = training_data[:,1:12]
```

## Random Forest classifiers

We can then define parameters of the Random Forest classifier and fit the predictor variables from the training data to the Biomass estimates.


```python
#Define parameters for the Random Forest Regressor
max_depth = 30

#Define regressor settings
regr_rf = RandomForestRegressor(max_depth=max_depth, random_state=2)

#Fit the biomass to regressor variables
regr_rf.fit(biomass_predictors,biomass)
```




    RandomForestRegressor(bootstrap=True, ccp_alpha=0.0, criterion='mse',
                          max_depth=30, max_features='auto', max_leaf_nodes=None,
                          max_samples=None, min_impurity_decrease=0.0,
                          min_impurity_split=None, min_samples_leaf=1,
                          min_samples_split=2, min_weight_fraction_leaf=0.0,
                          n_estimators=100, n_jobs=None, oob_score=False,
                          random_state=2, verbose=0, warm_start=False)



We will now apply the Random Forest model to the predictor variables to estimate biomass


```python
#Apply the model to the predictors
estimated_biomass = regr_rf.predict(X)
```

To output a raster, pre-allocate (copy) an array from the labels raster, then cycle through the segments and assign the biomass estimate to each individual tree segment.


```python
#Set an out raster with the same size as the labels
biomass_map =  np.array((labels),dtype=float)
#Assign the appropriate biomass to the labels
biomass_map[biomass_map==0] = np.nan
for tree_id, biomass_of_tree_id in zip(tree_ids, estimated_biomass):
    biomass_map[biomass_map == tree_id] = biomass_of_tree_id  
```

## Calculate Biomass
Collect some of the biomass statistics and then plot the results and save an output geotiff.


```python
#Get biomass stats for plotting
mean_biomass = np.mean(estimated_biomass)
std_biomass = np.std(estimated_biomass)
min_biomass = np.min(estimated_biomass)
sum_biomass = np.sum(estimated_biomass)

print('Sum of biomass is ',sum_biomass,' kg')

# Plot the biomass!
plt.figure(5)
plot_band_array(biomass_map,chm_array_metadata['extent'],
                'Biomass (kg)','Biomass (kg)',
                'winter',
                [min_biomass+std_biomass, mean_biomass+std_biomass*3])

# Save the biomass figure; use the same name as the original file, but replace CHM with Biomass
plt.savefig(os.path.join(data_path,chm_name.replace('CHM.tif','Biomass.png')),
            dpi=300,orientation='landscape',
            bbox_inches='tight',
            pad_inches=0.1)

# Use the array2raster function to create a geotiff file of the Biomass
array2raster(os.path.join(data_path,chm_name.replace('CHM.tif','Biomass.tif')),
             (chm_array_metadata['ext_dict']['xMin'],chm_array_metadata['ext_dict']['yMax']),
             1,-1,np.array(biomass_map,dtype=float),32611)
```

    Sum of biomass is  7249752.02745825  kg
    


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/lidar-biomass/calc-biomass_py/calc-biomass_py_files/calc-biomass_py_59_1.png)
    

