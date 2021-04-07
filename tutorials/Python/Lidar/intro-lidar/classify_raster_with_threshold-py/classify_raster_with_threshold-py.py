#!/usr/bin/env python
# coding: utf-8

# ---
# syncID: c324c554a35f463493349dbd0be19cec
# title: "Classify a Raster Using Threshold Values in Python - 2017"
# description: "Learn how to read NEON lidar raster GeoTIFFs (e.g., CHM, slope, aspect) into Python numpy arrays with gdal and create a classified raster object." 
# dateCreated: 2017-06-21 
# authors: Bridget Hass
# contributors: Max Burner, Donal O'Leary
# estimatedTime: 1 hour
# packagesLibraries: numpy, gdal, matplotlib, matplotlib.pyplot, os
# topics: lidar, raster, remote-sensing
# languagesTool: python
# dataProduct: DP1.30003, DP3.30015, DP3.30024, DP3.30025
# code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Lidar/intro-lidar/classify_raster_with_threshold-py/classify_raster_with_threshold-py.ipynb
# tutorialSeries: intro-lidar-py-series
# urlTitle: classify-raster-thresholds-py
# ---

# 
# In this tutorial, we will learn how to:
# 1. Read NEON LiDAR Raster Geotifs (eg. CHM, Slope Aspect) into Python numpy arrays with gdal.
# 2. Create a classified raster object.
# 
# First, let's import the required packages and set our plot display to be in line:

# <h3><a href="https://ndownloader.figshare.com/files/21754221"> 
# 
# Download NEON Teaching Data Subset: Imaging Spectrometer Data - HDF5 </a></h3> 
# 
#   
# 
# These hyperspectral remote sensing data provide information on the 
# 
# <a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a>  
# 
# <a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank" > San Joaquin  
# 
# Exerimental Range field site</a> in March of 2019. 
# 
# The data were collected over the San Joaquin field site located in California  
# 
# (Domain 17) and processed at NEON headquarters. This data subset is derived from  
# 
# the mosaic tile named NEON_D17_SJER_DP3_257000_4112000_reflectance.h5.  
# 
# The entire dataset can be accessed by request from the  
# 
# <a href="http://data.neonscience.org" target="_blank"> NEON Data Portal</a>. 
# 
# <a href="https://ndownloader.figshare.com/files/21754221" class="link--button link--arrow"> Download Dataset</a> 

# In[1]:


import numpy as np
import gdal
import matplotlib.pyplot as plt
get_ipython().run_line_magic('matplotlib', 'inline')
import warnings
warnings.filterwarnings('ignore')


# ### Open a Geotif with GDAL
# 
# Let's look at the SERC Canopy Height Model (CHM) to start. We can open and read this in Python using the ```gdal.Open``` function:

# In[2]:


chm_filename = '/Users/olearyd/Git/data/NEON_D02_SERC_DP3_368000_4306000_CHM.tif'
#chm_filename = 'NEON_D02_SERC_DP3_367000_4306000_CHM.tif'
chm_dataset = gdal.Open(chm_filename)


# ### Read information from Geotif Tags
# The Geotif file format comes with associated metadata containing information about the location and coordinate system/projection. Once we have read in the dataset, we can access this information with the following commands: 

# In[3]:


#Display the dataset dimensions, number of bands, driver, and geotransform 
cols = chm_dataset.RasterXSize; print('# of columns:',cols)
rows = chm_dataset.RasterYSize; print('# of rows:',rows)
print('# of bands:',chm_dataset.RasterCount)
print('driver:',chm_dataset.GetDriver().LongName)


# ### ```GetProjection``` 
# We can use ```GetProjection``` to see information about the coordinate system and EPSG code. 

# In[4]:


print('projection:',chm_dataset.GetProjection())


# ### ```GetGeoTransform```
# 
# The geotransform contains information about the origin (upper-left corner) of the raster, the pixel size, and the rotation angle of the data. All NEON data in the latest format have zero rotation. In this example, the values correspond to: 

# In[5]:


print('geotransform:',chm_dataset.GetGeoTransform())


# In this case, the geotransform values correspond to:
# 
# 1. Top-Left X Coordinate = ```358816.0```
# 2. W-E Pixel Resolution = ```1.0```
# 3. Rotation (0 if Image is North-Up) = ```0.0```
# 4. Top-Left Y Coordinate = ```4313476.0```
# 5. Rotation (0 if Image is North-Up) = ```0.0```
# 6. N-S Pixel Resolution = ```-1.0``` 
# 
# We can convert this information into a spatial extent (xMin, xMax, yMin, yMax) by combining information about the origin, number of columns & rows, and pixel size, as follows:

# In[6]:


chm_mapinfo = chm_dataset.GetGeoTransform()
xMin = chm_mapinfo[0]
yMax = chm_mapinfo[3]

xMax = xMin + chm_dataset.RasterXSize/chm_mapinfo[1] #divide by pixel width 
yMin = yMax + chm_dataset.RasterYSize/chm_mapinfo[5] #divide by pixel height (note sign +/-)
chm_ext = (xMin,xMax,yMin,yMax)
print('chm raster extent:',chm_ext)


# ### ```GetRasterBand``` 
# We can read in a single raster band with ```GetRasterBand``` and access information about this raster band such as the No Data Value, Scale Factor, and Statitiscs as follows:

# In[7]:


chm_raster = chm_dataset.GetRasterBand(1)
noDataVal = chm_raster.GetNoDataValue(); print('no data value:',noDataVal)
scaleFactor = chm_raster.GetScale(); print('scale factor:',scaleFactor)
chm_stats = chm_raster.GetStatistics(True,True)
print('SERC CHM Statistics: Minimum=%.2f, Maximum=%.2f, Mean=%.3f, StDev=%.3f' % 
      (chm_stats[0], chm_stats[1], chm_stats[2], chm_stats[3]))


# ### ```ReadAsArray``` 
# 
# Finally we can convert the raster to an array using the ReadAsArray command. Use the extension ```astype(np.float)``` to ensure the array contains floating-point numbers. Once we generate the array, we want to set No Data Values to NaN, and apply the scale factor: 

# In[8]:


chm_array = chm_dataset.GetRasterBand(1).ReadAsArray(0,0,cols,rows).astype(np.float)
chm_array[chm_array==int(noDataVal)]=np.nan #Assign CHM No Data Values to NaN
chm_array=chm_array/scaleFactor
print('SERC CHM Array:\n',chm_array) #display array values


# ### Array Statistics 
# 
# To get a better idea of the dataset, print some basic statistics:

# In[9]:


# Display statistics (min, max, mean); numpy.nanmin calculates the minimum without the NaN values.
print('SERC CHM Array Statistics:')
print('min:',round(np.nanmin(chm_array),2))
print('max:',round(np.nanmax(chm_array),2))
print('mean:',round(np.nanmean(chm_array),2))

# Calculate the % of pixels that are NaN and non-zero:
pct_nan = np.count_nonzero(np.isnan(chm_array))/(rows*cols)
print('% NaN:',round(pct_nan*100,2))
print('% non-zero:',round(100*np.count_nonzero(chm_array)/(rows*cols),2))


# In[10]:


# Plot array
# We can use our plot_band_array function from Day 1
# %load plot_band_array
def plot_band_array(band_array,refl_extent,title,cmap_title,colormap='Spectral'):
    plt.imshow(band_array,extent=refl_extent); 
    cbar = plt.colorbar(); plt.set_cmap(colormap); 
    cbar.set_label(cmap_title,rotation=270,labelpad=20)
    plt.title(title); ax = plt.gca(); 
    ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation #
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degrees


# In[11]:


plot_band_array(chm_array,chm_ext,'SERC Canopy Height','Canopy Height, m')


# ### Plot Histogram of Data 

# In[12]:


import copy
chm_nonan_array = copy.copy(chm_array)
chm_nonan_array = chm_nonan_array[~np.isnan(chm_array)]
plt.hist(chm_nonan_array,weights=np.zeros_like(chm_nonan_array)+1./
         (chm_array.shape[0]*chm_array.shape[1]),bins=50);
plt.title('Distribution of SERC Canopy Height')
plt.xlabel('Tree Height (m)'); plt.ylabel('Relative Frequency')


# We can see that most of the values are zero. In SERC, many of the zero CHM values correspond to bodies of water as well as regions of land without trees. Let's look at a  histogram and plot the data without zero values: 

# In[13]:


chm_nonzero_array = copy.copy(chm_array)
chm_nonzero_array[chm_array==0]=np.nan
chm_nonzero_nonan_array = chm_nonzero_array[~np.isnan(chm_nonzero_array)]
# Use weighting to plot relative frequency
plt.hist(chm_nonzero_nonan_array,weights=np.zeros_like(chm_nonzero_nonan_array)+1./
         (chm_array.shape[0]*chm_array.shape[1]),bins=50);

# plt.hist(chm_nonzero_nonan_array.flatten(),50) 
plt.title('Distribution of SERC Non-Zero Canopy Height')
plt.xlabel('Tree Height (m)'); plt.ylabel('Relative Frequency')
# plt.xlim(0,25); plt.ylim(0,4000000)

print('min:',np.amin(chm_nonzero_nonan_array),'m')
print('max:',round(np.amax(chm_nonzero_nonan_array),2),'m')
print('mean:',round(np.mean(chm_nonzero_nonan_array),2),'m')


# From the histogram we can see that the majority of the trees are < 45m. We can replot the CHM array, this time adjusting the color bar to better visualize the variation in canopy height. We will plot the non-zero array so that CHM=0 appears white. 

# In[14]:


plt.imshow(chm_array,extent=chm_ext,clim=(0,45))
cbar = plt.colorbar(); plt.set_cmap('BuGn'); 
cbar.set_label('Canopy Height, m',rotation=270,labelpad=20)
plt.title('SERC Non-Zero CHM, <45m'); ax = plt.gca(); 
ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation #
rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degrees


# ### Create a ```raster2array``` function to automate conversion of Geotif to array:
# 
# Now that we have a basic understanding of how GDAL reads in a Geotif file, we can write a function to read in a NEON geotif, convert it to a numpy array, and store the associated metadata in a Python dictionary in order to more efficiently carry out further analysis:

# In[15]:


# raster2array.py reads in the first band of geotif file and returns an array and associated 
# metadata dictionary containing ...

from osgeo import gdal
import numpy as np

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
#     metadata['xMin'] = mapinfo[0]
#     metadata['yMax'] = mapinfo[3]
#     metadata['xMax'] = mapinfo[0] + dataset.RasterXSize/mapinfo[1]
#     metadata['yMin'] = mapinfo[3] + dataset.RasterYSize/mapinfo[5]
    
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


# In[16]:


SERC_chm_array, SERC_chm_metadata = raster2array(chm_filename)

print('SERC CHM Array:\n',SERC_chm_array)
# print(chm_metadata)

#print metadata in alphabetical order
for item in sorted(SERC_chm_metadata):
    print(item + ':', SERC_chm_metadata[item])


# ## Threshold Based Raster Classification
# Next, we will create a classified raster object. To do this, we will use the numpy.where function to create a new raster based off boolean classifications. Let's classify the canopy height into four groups:
# - Class 1: **CHM = 0 m** 
# - Class 2: **0m < CHM <= 20m**
# - Class 3: **20m < CHM <= 40m**
# - Class 4: **CHM > 40m**

# In[17]:


chm_reclass = copy.copy(chm_array)
chm_reclass[np.where(chm_array==0)] = 1 # CHM = 0 : Class 1
chm_reclass[np.where((chm_array>0) & (chm_array<=20))] = 2 # 0m < CHM <= 20m - Class 2
chm_reclass[np.where((chm_array>20) & (chm_array<=40))] = 3 # 20m < CHM < 40m - Class 3
chm_reclass[np.where(chm_array>40)] = 4 # CHM > 40m - Class 4

print('Min:',np.nanmin(chm_reclass))
print('Max:',np.nanmax(chm_reclass))
print('Mean:',round(np.nanmean(chm_reclass),2))

import matplotlib.colors as colors
plt.figure(); #ax = plt.subplots()
cmapCHM = colors.ListedColormap(['lightblue','yellow','green','red'])
plt.imshow(chm_reclass,extent=chm_ext,cmap=cmapCHM)
plt.title('SERC CHM Classification')
ax=plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation 
rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degrees
# forceAspect(ax,aspect=1) # ax.set_aspect('auto')

# Create custom legend to label the four canopy height classes:
import matplotlib.patches as mpatches
class1_box = mpatches.Patch(color='lightblue', label='CHM = 0m')
class2_box = mpatches.Patch(color='yellow', label='0m < CHM < 20m')
class3_box = mpatches.Patch(color='green', label='20m < CHM < 40m')
class4_box = mpatches.Patch(color='red', label='CHM > 40m')

ax.legend(handles=[class1_box,class2_box,class3_box,class4_box],
          handlelength=0.7,bbox_to_anchor=(1.05, 0.4),loc='lower left',borderaxespad=0.)


# ## Export classified raster to a geotif

# In[18]:


# %load ../hyperspectral_hdf5/array2raster.py
"""
Array to Raster Function from https://pcjericks.github.io/py-gdalogr-cookbook/raster_layers.html)
"""
import gdal, osr #ogr, os, osr
import numpy as np

def array2raster(newRasterfn,rasterOrigin,pixelWidth,pixelHeight,array,epsg):

    cols = array.shape[1]
    rows = array.shape[0]
    originX = rasterOrigin[0]
    originY = rasterOrigin[1]

    driver = gdal.GetDriverByName('GTiff')
    outRaster = driver.Create(newRasterfn, cols, rows, 1, gdal.GDT_Byte)
    outRaster.SetGeoTransform((originX, pixelWidth, 0, originY, 0, pixelHeight))
    outband = outRaster.GetRasterBand(1)
    outband.WriteArray(array)
    outRasterSRS = osr.SpatialReference()
    outRasterSRS.ImportFromEPSG(epsg)
    outRaster.SetProjection(outRasterSRS.ExportToWkt())
    outband.FlushCache()


# In[19]:


#array2raster(newRasterfn,rasterOrigin,pixelWidth,pixelHeight,array)
epsg = 32618 #WGS84, UTM Zone 18N
rasterOrigin = (SERC_chm_metadata['ext_dict']['xMin'],SERC_chm_metadata['ext_dict']['yMax'])
print('raster origin:',rasterOrigin)
array2raster('/Users/olearyd/Git/data/SERC_CHM_Classified.tif',rasterOrigin,1,-1,chm_reclass,epsg)


# ## Challenge 1: Document Your Workflow 
# 1. Look at the code that you created for this lesson. Now imagine yourself months in the future. Document your script so that your methods and process is clear and reproducible for yourself or others to follow in the future. 
# 2. In documenting your script, synthesize the outputs. Do they tell you anything about the vegetation structure at the field site? 
# 
# ## Challenge 2: Try out other Classifications
# Create the following threshold classified outputs:
# 1. A raster where NDVI values are classified into the following categories:
#     * Low greenness: NDVI < 0.3
#     * Medium greenness: 0.3 < NDVI < 0.6
#     * High greenness: NDVI > 0.6
# 2. A raster where aspect is classified into North and South facing slopes: 
# 
# Be sure to document your workflow as you go using Jupyter Markdown cells. When you are finished, explore your outputs to HTML  by selecting File > Download As > HTML (.html). Save the file as LastName_Tues_classifyThreshold.html. Add this to the Tuesday directory in your DI17-NEON-participants Git directory and push them to your fork in GitHub. Merge with the central repository using a pull request. 

# ## Aspect Raster Classification on TEAK Dataset (California)
# 
# Next, we will create a classified raster object based on slope using the TEAK dataset. This time, our classifications will be:
# - **North Facing Slopes**: 0-45 & 315-360 degrees ; class=1
# - **South Facing Slopes**: 135-225 degrees ; class=2
# - **East & West Facing Slopes**: 45-135 & 225-315 degrees ; unclassified
# 
# <p>
# <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/geospatial-skills/NSEWclassification_BozEtAl2015.jpg" style="width: 250px;"/>
# <center><font size="2">Figure: (Boz et al. 2015)</font></center>
# <center><font size="2">http://www.aimspress.com/article/10.3934/energy.2015.3.401/fulltext.html</font></center>
# </p>
# 
# **Further Reading:** There are a range of applications for aspect classification. The link above shows an example of classifying LiDAR aspect data to determine suitability of roofs for PV (photovoltaic) systems. Can you think of any other applications where aspect classification might be useful?
# 
# **Data Tip:** You can calculate aspect in Python from a digital elevation (or surface) model using the pyDEM package: https://earthlab.github.io/tutorials/get-slope-aspect-from-digital-elevation-model/
# 
# **Let's get started.** First we can import the TEAK aspect raster geotif and convert it to an array using the ```raster2array``` function:

# In[20]:


TEAK_aspect_tif = '/Users/olearyd/Git/data/2013_TEAK_1_326000_4103000_DTM_aspect.tif'
TEAK_asp_array, TEAK_asp_metadata = raster2array(TEAK_aspect_tif)
print('TEAK Aspect Array:\n',TEAK_asp_array)

#print metadata in alphabetical order
for item in sorted(TEAK_asp_metadata):
    print(item + ':', TEAK_asp_metadata[item])

plot_band_array(TEAK_asp_array,TEAK_asp_metadata['extent'],'TEAK Aspect','Aspect, degrees')


# In[21]:


aspect_array = copy.copy(TEAK_asp_array)
asp_reclass = copy.copy(aspect_array)
asp_reclass[np.where(((aspect_array>=0) & (aspect_array<=45)) | (aspect_array>=315))] = 1 #North - Class 1
asp_reclass[np.where((aspect_array>=135) & (aspect_array<=225))] = 2 #South - Class 2
asp_reclass[np.where(((aspect_array>45) & (aspect_array<135)) | ((aspect_array>225) & (aspect_array<315)))] = np.nan #W & E - Unclassified

print('Min:',np.nanmin(asp_reclass))
print('Max:',np.nanmax(asp_reclass))
print('Mean:',round(np.nanmean(asp_reclass),2))

def forceAspect(ax,aspect=1):
    im = ax.get_images()
    extent =  im[0].get_extent()
    ax.set_aspect(abs((extent[1]-extent[0])/(extent[3]-extent[2]))/aspect)

# plot_band_array(aspect_reclassified,asp_ext,'North and South Facing Slopes \n HOPB')
from matplotlib import colors
fig, ax = plt.subplots()
cmapNS = colors.ListedColormap(['blue','red'])
plt.imshow(asp_reclass,extent=TEAK_asp_metadata['extent'],cmap=cmapNS)
plt.title('TEAK \n N and S Facing Slopes')
ax=plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation 
rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degrees
ax = plt.gca(); forceAspect(ax,aspect=1)

# Create custom legend to label N & S
import matplotlib.patches as mpatches
blue_box = mpatches.Patch(color='blue', label='North')
red_box = mpatches.Patch(color='red', label='South')
ax.legend(handles=[blue_box,red_box],handlelength=0.7,bbox_to_anchor=(1.05, 0.45), 
          loc='lower left', borderaxespad=0.)


# In[22]:


TEAK_asp_array


# In[23]:


TEAKepsg = 32611 #WGS84 UTM Zone 11N
TEAKorigin = (TEAK_asp_metadata['ext_dict']['xMin'], TEAK_asp_metadata['ext_dict']['yMax'])
print('TEAK raster origin: ',TEAKorigin)
array2raster('/Users/olearyd/Git/data/teak_nsAspect.tif',TEAKorigin,1,-1,TEAK_asp_array,TEAKepsg)


# In[24]:


TEAK_asp_metadata['projection']


# ## References 
# 
# Bayrakci Boz, M.; Calvert, K.; Brownson, J.R.S. An automated model for rooftop PV systems assessment in ArcGIS using LIDAR. AIMS Energy 2015, 3, 401–420.

# ## Scratch / Test Code

# In[25]:


#SERC Aspect Classification - doesn't work well because there is no significant terrain 
SERC_asp_array, SERC_asp_metadata = raster2array(chm_filename)
print('SERC Aspect Array:\n',SERC_asp_array)

#print metadata in alphabetical order
for item in sorted(SERC_asp_metadata):
    print(item + ':', SERC_chm_metadata[item])

plot_band_array(SERC_asp_array,SERC_asp_metadata['extent'],'SERC Aspect','Aspect, degrees')

import copy
aspect_array = copy.copy(SERC_asp_array)
asp_reclass = copy.copy(aspect_array)
asp_reclass[np.where(((aspect_array>=0) & (aspect_array<=45)) | (aspect_array>=315))] = 1 #North - Class 1
asp_reclass[np.where((aspect_array>=135) & (aspect_array<=225))] = 2 #South - Class 2
asp_reclass[np.where(((aspect_array>45) & (aspect_array<135)) | ((aspect_array>225) & (aspect_array<315)))] = np.nan #W & E - Unclassified

# print(aspect_reclassified.dtype)
# print('Reclassified Aspect Matrix:',asp_reclass.shape)
# print(aspect_reclassified)
print('Min:',np.nanmin(asp_reclass))
print('Max:',np.nanmax(asp_reclass))
print('Mean:',round(np.nanmean(asp_reclass),2))

# plot_band_array(aspect_reclassified,asp_ext,'North and South Facing Slopes \n HOPB')
from matplotlib import colors
fig, ax = plt.subplots()
cmapNS = colors.ListedColormap(['blue','red'])
plt.imshow(asp_reclass,extent=SERC_asp_metadata['extent'],cmap=cmapNS)
plt.title('SERC \n N and S Facing Slopes')
ax=plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') #do not use scientific notation 
rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) #rotate x tick labels 90 degrees

# Create custom legend to label N & S
import matplotlib.patches as mpatches
blue_box = mpatches.Patch(color='blue', label='North')
red_box = mpatches.Patch(color='red', label='South')
ax.legend(handles=[blue_box,red_box],handlelength=0.7,
          bbox_to_anchor=(1.05, 0.45), loc='lower left', borderaxespad=0.)


# In[26]:


#Test out slope reclassification on subset of SERC aspect array:
import copy
aspect_subset = aspect_array[1000:1005,1000:1005]
print(aspect_subset)

asp_sub_reclass = copy.copy(aspect_subset)
asp_sub_reclass[np.where(((aspect_subset>=0) & (aspect_subset<=45)) | (aspect_subset>=315))] = 1 #North - Class 1
asp_sub_reclass[np.where((aspect_subset>=135) & (aspect_subset<=225))] = 2 #South - Class 2
asp_sub_reclass[np.where(((aspect_subset>45) & (aspect_subset<135)) | ((aspect_subset>225) & (aspect_subset<315)))] = np.nan #W & E - Unclassified

print('Reclassified Aspect Subset:\n',asp_sub_reclass)


# In[27]:


# Another way to read in a Geotif from a gdal workshop:
# http://download.osgeo.org/gdal/workshop/foss4ge2015/workshop_gdal.pdf
ds = gdal.Open(chm_filename)
print('File list:', ds.GetFileList())
print('Width:', ds.RasterXSize)
print('Height:', ds.RasterYSize)
print('Coordinate system:', ds.GetProjection())
gt = ds.GetGeoTransform() # captures origin and pixel size
print('Origin:', (gt[0], gt[3]))
print('Pixel size:', (gt[1], gt[5]))
print('Upper Left Corner:', gdal.ApplyGeoTransform(gt,0,0))
print('Upper Right Corner:', gdal.ApplyGeoTransform(gt,ds.RasterXSize,0))
print('Lower Left Corner:', gdal.ApplyGeoTransform(gt,0,ds.RasterYSize))
print('Lower Right Corner:',gdal.ApplyGeoTransform(gt,ds.RasterXSize,ds.RasterYSize))
print('Center:', gdal.ApplyGeoTransform(gt,ds.RasterXSize/2,ds.RasterYSize/2))
print('Metadata:', ds.GetMetadata())
print('Image Structure Metadata:', ds.GetMetadata('IMAGE_STRUCTURE'))
print('Number of Bands:', ds.RasterCount)
for i in range(1, ds.RasterCount+1):
    band = ds.GetRasterBand(i) # in GDAL, band are indexed starting at 1!
    interp = band.GetColorInterpretation()
    interp_name = gdal.GetColorInterpretationName(interp)
    (w,h)=band.GetBlockSize()
    print('Band %d, block size %dx%d, color interp %s' % (i,w,h,interp_name))
    ovr_count = band.GetOverviewCount()
    for j in range(ovr_count):
        ovr_band = band.GetOverview(j) # but overview bands starting at 0
        print(' Overview %d: %dx%d'%(j, ovr_band.XSize, ovr_band.YSize))


# In[ ]:




