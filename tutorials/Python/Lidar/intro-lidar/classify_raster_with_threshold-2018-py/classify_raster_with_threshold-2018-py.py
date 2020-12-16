#!/usr/bin/env python
# coding: utf-8

# ---
# syncID: b0860577d1994b6e8abd23a6edf9e005
# title: "Classify a Raster Using Threshold Values in Python - 2018"
# description: "Learn how to read NEON lidar raster GeoTIFFs (e.g., CHM, slope, aspect) into Python numpy arrays with gdal and create a classified raster object." 
# dateCreated: 2018-07-04 
# authors: Bridget Hass
# contributors: Donal O'Leary, Max Burner
# estimatedTime: 
# packagesLibraries: numpy, gdal, matplotlib, matplotlib.pyplot, os
# topics: lidar, raster, remote-sensing
# languagesTool: python
# dataProduct: DP1.30003, DP3.30015, DP3.30024, DP3.30025
# code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/intro-lidar/classify_raster_with_threshold-2018-py/classify_raster_with_threshold-2018-py.ipynb
# tutorialSeries: intro-lidar-py-series
# urlTitle: classify-raster-thresholds-2018-py
# ---

# In this tutorial, we will learn how to read NEON lidar raster GeoTIFFS 
# (e.g., CHM, slope aspect) into Python `numpy` arrays with gdal and create a 
# classified raster object.
# 
# <div id="ds-objectives" markdown="1">
# 
# ### Objectives
# 
# After completing this tutorial, you will be able to:
# 
# * Read NEON lidar raster GeoTIFFS (e.g., CHM, slope aspect) into Python numpy arrays with gdal.
# * Create a classified raster object using thresholds.
# 
# ### Install Python Packages
# 
# * **numpy**
# * **gdal** 
# * **matplotlib** 
# 
# ### Download Data
# 
# For this lesson, we will be using a 1km tile of a Canopy Height Model derived from lidar data collected at the Smithsonian Environmental Research Center (SERC) NEON site. <a href="https://ndownloader.figshare.com/files/25787420">Download Data Here</a>.
# 
# <a href="https://ndownloader.figshare.com/files/25787420" class="link--button link--arrow">
# Download Dataset</a>
# 
# </div>

# In this tutorial, we will work with the NEON AOP L3 LiDAR ecoysystem structure (Canopy Height Model) data product. For more information about NEON data products and the CHM product DP3.30015.001, see the <a href="http://data.neonscience.org/data-products/DP3.30015.001" target="_blank">NEON Data Product Catalog</a>. 
# 
# First, let's import the required packages and set our plot display to be in-line:

# In[1]:


import numpy as np
import gdal, copy
import matplotlib.pyplot as plt
get_ipython().run_line_magic('matplotlib', 'inline')
import warnings
warnings.filterwarnings('ignore')


# ## Open a GeoTIFF with GDAL
# 
# Let's look at the SERC Canopy Height Model (CHM) to start. We can open and read this in Python using the ```gdal.Open``` function:

# In[2]:


# Note that you will need to update the filepath below according to your local machine
chm_filename = '/Users/olearyd/Git/data/NEON_D02_SERC_DP3_368000_4306000_CHM.tif'
chm_dataset = gdal.Open(chm_filename)


# ### Read GeoTIFF Tags
# The GeoTIFF file format comes with associated metadata containing information about the location and coordinate system/projection. Once we have read in the dataset, we can access this information with the following commands: 

# In[3]:


#Display the dataset dimensions, number of bands, driver, and geotransform 
cols = chm_dataset.RasterXSize; print('# of columns:',cols)
rows = chm_dataset.RasterYSize; print('# of rows:',rows)
print('# of bands:',chm_dataset.RasterCount)
print('driver:',chm_dataset.GetDriver().LongName)


# ### Use GetProjection
# 
# We can use the `gdal` ```GetProjection``` method to display information about the coordinate system and EPSG code. 

# In[4]:


print('projection:',chm_dataset.GetProjection())


# ### Use GetGeoTransform
# 
# The geotransform contains information about the origin (upper-left corner) of the raster, the pixel size, and the rotation angle of the data. All NEON data in the latest format have zero rotation. In this example, the values correspond to: 

# In[5]:


print('geotransform:',chm_dataset.GetGeoTransform())


# In this case, the geotransform values correspond to:
# 
# 1. Left-Most X Coordinate = `367000.0`
# 2. W-E Pixel Resolution = `1.0`
# 3. Rotation (0 if Image is North-Up) = `0.0`
# 4. Upper Y Coordinate = `4307000.0`
# 5. Rotation (0 if Image is North-Up) = `0.0`
# 6. N-S Pixel Resolution = `-1.0` 
# 
# The negative value for the N-S Pixel resolution reflects that the origin of the image is the upper left corner. We can convert this geotransform information into a spatial extent (xMin, xMax, yMin, yMax) by combining information about the origin, number of columns & rows, and pixel size, as follows:

# In[6]:


chm_mapinfo = chm_dataset.GetGeoTransform()
xMin = chm_mapinfo[0]
yMax = chm_mapinfo[3]

xMax = xMin + chm_dataset.RasterXSize/chm_mapinfo[1] #divide by pixel width 
yMin = yMax + chm_dataset.RasterYSize/chm_mapinfo[5] #divide by pixel height (note sign +/-)
chm_ext = (xMin,xMax,yMin,yMax)
print('chm raster extent:',chm_ext)


# ### Use GetRasterBand
# 
# We can read in a single raster band with `GetRasterBand` and access information about this raster band such as the No Data Value, Scale Factor, and Statitiscs as follows:

# In[7]:


chm_raster = chm_dataset.GetRasterBand(1)
noDataVal = chm_raster.GetNoDataValue(); print('no data value:',noDataVal)
scaleFactor = chm_raster.GetScale(); print('scale factor:',scaleFactor)
chm_stats = chm_raster.GetStatistics(True,True)
print('SERC CHM Statistics: Minimum=%.2f, Maximum=%.2f, Mean=%.3f, StDev=%.3f' % 
      (chm_stats[0], chm_stats[1], chm_stats[2], chm_stats[3]))


# ### Use ReadAsArray
# 
# Finally we can convert the raster to an array using the `ReadAsArray` method. Cast the array to a floating point value using `astype(np.float)`. Once we generate the array, we want to set No Data Values to NaN, and apply the scale factor: 

# In[8]:


chm_array = chm_dataset.GetRasterBand(1).ReadAsArray(0,0,cols,rows).astype(np.float)
chm_array[chm_array==int(noDataVal)]=np.nan #Assign CHM No Data Values to NaN
chm_array=chm_array/scaleFactor
print('SERC CHM Array:\n',chm_array) #display array values


# In[9]:


chm_array.shape


# In[10]:


# Calculate the % of pixels that are NaN and non-zero:
pct_nan = np.count_nonzero(np.isnan(chm_array))/(rows*cols)
print('% NaN:',round(pct_nan*100,2))
print('% non-zero:',round(100*np.count_nonzero(chm_array)/(rows*cols),2))


# ## Plot Canopy Height Data
# 
# To get a better idea of the dataset, we can use a similar function to `plot_aop_refl` that we used in the NEON AOP reflectance tutorials:

# In[11]:


def plot_band_array(band_array,refl_extent,colorlimit,ax=plt.gca(),title='',cmap_title='',colormap=''):
    plot = plt.imshow(band_array,extent=refl_extent,clim=colorlimit); 
    cbar = plt.colorbar(plot,aspect=40); plt.set_cmap(colormap); 
    cbar.set_label(cmap_title,rotation=90,labelpad=20);
    plt.title(title); ax = plt.gca(); 
    ax.ticklabel_format(useOffset=False, style='plain'); #do not use scientific notation #
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90); #rotate x tick labels 90 degrees


# ### Histogram of Data 
# 
# As we did with the reflectance tile, it is often useful to plot a histogram of the geotiff data in order to get a sense of the range and distribution of values. First we'll make a copy of the array and remove the `nan` values. 

# In[12]:


import copy
chm_nonan_array = copy.copy(chm_array)
chm_nonan_array = chm_nonan_array[~np.isnan(chm_array)]
plt.hist(chm_nonan_array,weights=np.zeros_like(chm_nonan_array)+1./
         (chm_array.shape[0]*chm_array.shape[1]),bins=50);
plt.title('Distribution of SERC Canopy Height')
plt.xlabel('Tree Height (m)'); plt.ylabel('Relative Frequency')


# On your own, adjust the number of bins, and range of the y-axis to get a good idea of the distribution of the canopy height values. We can see that most of the values are zero. In SERC, many of the zero CHM values correspond to bodies of water as well as regions of land without trees. Let's look at a  histogram and plot the data without zero values: 

# In[13]:


chm_nonzero_array = copy.copy(chm_array)
chm_nonzero_array[chm_array==0]=np.nan
chm_nonzero_nonan_array = chm_nonzero_array[~np.isnan(chm_nonzero_array)]
# Use weighting to plot relative frequency
plt.hist(chm_nonzero_nonan_array,bins=50);

# plt.hist(chm_nonzero_nonan_array.flatten(),50) 
plt.title('Distribution of SERC Non-Zero Canopy Height')
plt.xlabel('Tree Height (m)'); plt.ylabel('Relative Frequency')


# Note that it appears that the trees don't have a smooth or normal distribution, but instead appear blocked off in chunks. This is an artifact of the Canopy Height Model algorithm, which bins the trees into 5m increments (this is done to avoid another artifact of "pits" (Khosravipour et al., 2014). 
# 
# From the histogram we can see that the majority of the trees are < 30m. We can re-plot the CHM array, this time adjusting the color bar limits to better visualize the variation in canopy height. We will plot the non-zero array so that CHM=0 appears white. 

# In[14]:


plot_band_array(chm_array,
                chm_ext,
                (0,35),
                title='SERC Canopy Height',
                cmap_title='Canopy Height, m',
                colormap='BuGn')


# ## Threshold Based Raster Classification
# Next, we will create a classified raster object. To do this, we will use the se the numpy.where function to create a new raster based off boolean classifications. Let's classify the canopy height into five groups:
# - Class 1: **CHM = 0 m** 
# - Class 2: **0m < CHM <= 10m**
# - Class 3: **10m < CHM <= 20m**
# - Class 4: **20m < CHM <= 30m**
# - Class 5: **CHM > 30m**
# 
# We can use `np.where` to find the indices where a boolean criteria is met. 

# In[15]:


chm_reclass = copy.copy(chm_array)
chm_reclass[np.where(chm_array==0)] = 1 # CHM = 0 : Class 1
chm_reclass[np.where((chm_array>0) & (chm_array<=10))] = 2 # 0m < CHM <= 10m - Class 2
chm_reclass[np.where((chm_array>10) & (chm_array<=20))] = 3 # 10m < CHM <= 20m - Class 3
chm_reclass[np.where((chm_array>20) & (chm_array<=30))] = 4 # 20m < CHM <= 30m - Class 4
chm_reclass[np.where(chm_array>30)] = 5 # CHM > 30m - Class 5


# We can define our own colormap to plot these discrete classifications, and create a custom legend to label the classes:

# In[16]:


import matplotlib.colors as colors
plt.figure(); 
cmapCHM = colors.ListedColormap(['lightblue','yellow','orange','green','red'])
plt.imshow(chm_reclass,extent=chm_ext,cmap=cmapCHM)
plt.title('SERC CHM Classification')
ax=plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation 
rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degrees

# Create custom legend to label the four canopy height classes:
import matplotlib.patches as mpatches
class1_box = mpatches.Patch(color='lightblue', label='CHM = 0m')
class2_box = mpatches.Patch(color='yellow', label='0m < CHM <= 10m')
class3_box = mpatches.Patch(color='orange', label='10m < CHM <= 20m')
class4_box = mpatches.Patch(color='green', label='20m < CHM <= 30m')
class5_box = mpatches.Patch(color='red', label='CHM > 30m')

ax.legend(handles=[class1_box,class2_box,class3_box,class4_box,class5_box],
          handlelength=0.7,bbox_to_anchor=(1.05, 0.4),loc='lower left',borderaxespad=0.)


# <div id="ds-challenge" markdown="1">
# **Challenge: Document Your Workflow**
# 
# 1. Look at the code that you created for this lesson. Now imagine yourself months in the future. Document your script so that your methods and process is clear and reproducible for yourself or others to follow when you come back to this work at a later date. 
# 2. In documenting your script, synthesize the outputs. Do they tell you anything about the vegetation structure at the field site? 
# 
# </div>
# 
# <div id="ds-challenge" markdown="1">
# **Challenge: Try Another Classification**
# 
# Create the following threshold classified outputs:
# 
# 1. A raster where NDVI values are classified into the following categories:
#     * Low greenness: NDVI < 0.3
#     * Medium greenness: 0.3 < NDVI < 0.6
#     * High greenness: NDVI > 0.6
# 2. A raster where aspect is classified into North and South facing slopes: 
#     * North: 0-45 & 315-360 degrees 
#     * South: 135-225 degrees
# 
#  <figure>
# 	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/geospatial-skills/NSEWclassification_BozEtAl2015.jpg">
# 	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/geospatial-skills/NSEWclassification_BozEtAl2015.jpg"></a>
# 	<figcaption> Reclassification of aspect (azimuth) values: North, 315-45 
# 	degrees; East, 45-135 degrees; South, 135-225 degrees; West, 225-315 degrees.
# 	Source: <a href="http://www.aimspress.com/article/10.3934/energy.2015.3.401/fulltext.html"> Boz et al. 2015 </a>
# 	</figcaption>
# </figure>
# 
# Be sure to document your workflow as you go using Jupyter Markdown cells. 
# 
# **Data Institute Participants:** When you are finished, export your outputs to HTML by selecting File > Download As > HTML (.html). Save the file as LastName_Tues_classifyThreshold.html. Add this to the Tuesday directory in your DI-NEON-participants Git directory and push them to your fork in GitHub. Merge with the central repository using a pull request. 
# 
# </div>

# ## References 
# 
# Khosravipour, Anahita & Skidmore, Andrew & Isenburg, Martin & Wang, Tiejun & Hussin, Yousif. (2014). <a href="https://www.researchgate.net/publication/273663100_Generating_Pit-free_Canopy_Height_Models_from_Airborne_Lidar" target="_blank"> Generating Pit-free Canopy Height Models from Airborne Lidar. Photogrammetric Engineering & Remote Sensing</a>. 80. 863-872. 10.14358/PERS.80.9.863. 
# 
