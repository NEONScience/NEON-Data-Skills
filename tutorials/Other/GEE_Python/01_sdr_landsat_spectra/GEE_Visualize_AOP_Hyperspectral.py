#!/usr/bin/env python
# coding: utf-8

# # Visualizing AOP Hyperspectral Data in Google Earth Engine (GEE) using the Python API
# Authors: John Musinsky, Bridget Hass
# 
# Modified from Qiusheng Wu's [GEE Tutorial #9 - Interactive plotting of Earth Engine data with minimal coding](https://www.youtube.com/watch?v=PDab8mkAFL0), [giswqs_geemap_plotting_notebook](https://github.com/giswqs/geemap/blob/master/examples/notebooks/09_plotting.ipynb)
# 
# ## AOP data in GEE
# 
# [Google Earth Engine](https://earthengine.google.com/) is a platform idea for carrying out continental and planetary scale geospatial analyses. It has a multi-pedabyte catalog of satellite imagery and geospatial datasets, and is a powerful tool for comparing and scaling up NEON airborne datasets. 
# 
# The NEON data products can currently be accessed through the `projects/neon-prod-earthengine/assets/` folder with an appended prefix of the data product ID (DPID) similar to what you see on the [NEON data portal](https://data.neonscience.org/data-products/explore). The table below shows the corresponding prefixes to use for given data products.
# 
# | Acronym | Data Product      | Data Product ID (Prefix)          |
# |----------|------------|-------------------------|
# | SDR | Surface Directional Reflectance | DP3-30006-001 |
# | RGB | Red Green Blue (Camera Imagery) | DP3-30010-001 |
# | CHM | Canopy Height Model | DP3-30015-001 |
# | DSM | Digital Surface Model | DP3-30024-001 |
# | DTM | Digital Terrain Model | DP3-30024-001 |
# 
# ## Hyperspectral Visualization
# In this tutorial, we will take a look at the Healy (HEAL) SDR (hyperspectral) data collected in 2021. The data product prefix to pull in the data is (`projects/neon-prod-earthengine/assets/DP3-30006-001`). 
# 
# This tutorial uses the `geemap` Python package, and was modified from the Jupyter notebook [GEE Tutorial #9 - Interactive plotting of Earth Engine data with minimal coding](https://geemap.org/notebooks/09_plotting/). We will pull in AOP SDR data in addition to Landsat data, and compare the two.
# 
# To access the NEON AOP data you can either use the earth engine `ee.Image` if you know the name of the image you want to pull in or read in the Image Collection `ee.ImageCollection` and filter by the date and other properties of interest.
# 
# First, import the relevant Earth Engine (ee) packages, [ee](https://developers.google.com/earth-engine/guides/python_install) and [geemap](https://geemap.org/). This lesson was written using geemap version 0.22.1. If you have an older version installed, used the command below to update.

# !pip install --upgrade geemap

# In[1]:


import ee, geemap


# In[2]:


geemap.__version__


# First you will need to generate a code to Authenticate Earth Engine. The `ee.AuthenticateLine()` will open up a web browser. Click through the prompts to generate a token, then copy the Authorization code into the `Enter verification code:` box below and click enter to complete.

# In[3]:


ee.Authenticate()


# Now that you've Authenticated, you need to initialize, and then we can get started using Earth Engine in this Python Jupyter Notebook.

# In[4]:


ee.Initialize()


# You can create a Map using `geemap.Map()`. This will show a map that looks like the Map panel in the code editor version of GEE. By default it will show the world.

# In[5]:


Map = geemap.Map()
Map


# Start by defining the location, and we can extract the Healy AOP flightbox boundary from the feature collection so we can clip our satellite data by this area.

# In[6]:


# Specify center location of HEAL (63.875798, -149.21335)
# NEON field site information can be found on the NEON website here > https://www.neonscience.org/field-sites/heal
geo = ee.Geometry.Point([-149.213, 63.876])

# We can also read in the AOP flight boundary around Healy as follows:
flightbox_boundaries = ee.FeatureCollection('projects/neon-sandbox-dataflow-ee/assets/AOP_flightboxesAllSites').select('ADM0_NAME')

# Filter the feature collection to subset on the Healy site.
heal_flightbox = flightbox_boundaries.filterBounds(ee.Geometry.Rectangle(-150, 60, -145, 65))

# Set the style for the polygon to appear in the Map
style = {'color': 'black', 'fillColor': "00000000"}

Map.addLayer(heal_flightbox.style(**style), {}, "Healy Flightbox")

# Center the map on HEAL
Map.centerObject(geo, 11);


# ## Add Landsat 8 Imagery from 2018 to 2021
# 
# https://tutorials.geemap.org/ImageCollection/cloud_free_composite/

# In[7]:


start_year = 2018
end_year = 2021

years = ee.List.sequence(start_year, end_year)
years.getInfo()

def yearly_landsat_image(year):
    
    # read in only data from the summer months to simulate peak-greenness 
    # (AOP typically collects data from D19 in July-August)
    start_date = ee.Date.fromYMD(year, 5, 15) 
    end_date = start_date.advance(4, "month")
    
    l8_collection = ee.ImageCollection('LANDSAT/LC08/C01/T1')         .filterDate(start_date, end_date)         .filterBounds(geo) 
    
    # create a simple cloud-free composite
    image = ee.Algorithms.Landsat.simpleComposite(l8_collection).clipToCollection(heal_flightbox)
    
    # can also try a custom composite
    # customComposite = ee.Algorithms.Landsat.simpleComposite(l8_collection, 75, 5).clipToCollection(heal_flightbox);

    return image
#     return customComposite

images = years.map(yearly_landsat_image)

vis_params = {'bands': ['B4',  'B3',  'B2'], 'min': 10, 'max': 200, 'gamma': 2}

for index in range(0, 3):
    image = ee.Image(images.get(index))
    layer_name = "Landsat 8 " + str(index + start_year)
    Map.addLayer(image, vis_params, layer_name)
    
# Center the map on HEAL
Map.centerObject(geo, 11);


# ## Add HEAL Surface Directional Reflectance Data
# 
# This next chunk of code shows how to add the AOP SDR imagery, using the Red, Green, and Blue bands for visualizing a true-color image.

# In[8]:


# Read in Surface Directional Reflectance (SDR) Images 
aopSDR = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30006-001')

# Filter by geometry to read in HEAL SDR image from 2021
healSDR_2021 = aopSDR.filterDate('2021-01-01', '2021-12-31').filterBounds(geo).first();

# Read in only the data bands, all of which start with "B", eg. "B001"
healSDR_2021_data = healSDR_2021.select('B.*')

# Set the visualization parameters so contrast is maximized, and display RGB bands (true-color image)
visParams = {'min':0,'max':1200,'gamma':0.9,'bands':['B053','B035','B019']};

# Add the HEAL data as a layer to the Map
Map.addLayer(healSDR_2021_data, visParams, 'HEAL 2021 SDR');

# Center the map on HEAL
Map.centerObject(geo, 11);


# We can also set some plot options for the spectral signature plot, which is a built in feature!

# ### Map.set_plot_options 
# 
# There are various options to change with the plot, for this example we will set overlay to true. Refer to the [documentation](https://geemap.org/geemap/#geemap.geemap.Map.set_plot_options) for more options.

# In[9]:


get_ipython().run_line_magic('pinfo', 'Map.set_plot_options')


# In[10]:


Map.set_plot_options(plot_type='scatter',
                     add_marker_cluster=True,
                     default_size=12,
                     stroke_width=2,
                     axes_options={"x": {"label": "band number"},"y": {"label": "reflectance"}})


# In[ ]:


#optionally can set overlay to True to see multiple spectral signatures on the same plot
Map.set_plot_options(overlay=True)


# To clear features from the map you can use `MAP.remove_drawn_feature`. You may also need to re-run the cells starting with `Map = geemap.Map()` to clear the Map panel and start from scratch. Feel free to explore on your own!

# In[ ]:


Map.remove_drawn_features()


# ## Image Properties
# We can look into the properties of the Healy imagery using `geemap.image_props`. We encourage you to explore the dataset!

# In[ ]:


props = geemap.image_props(healSDR_2021_data)
props


# ## Optional Exercises
# 
# Here are a few more exercises to try out:
# 1. Create a function to read in AOP SDR images, similar to the Landsat function, and read in all the years of HEAL data.
# 2. Explore the GEE map functionality to convert Javascript to Python.

# ### geemap.js_snippet_to_py
# `js_snippet_to_py` converts a snippet of `JavaScript` (js) code to python. Try out on your own! 

# In[ ]:


get_ipython().run_line_magic('pinfo', 'geemap.js_snippet_to_py')


# In[ ]:


js_snippet = ""
geemap.js_snippet_to_py(js_snippet, add_new_cell=True, import_ee=True, import_geemap=True, show_map=True)


# ## Additional Python-GEE Resources to Explore!
# 
# - https://developers.google.com/earth-engine/guides/python_install
# - https://github.com/giswqs
# - https://github.com/giswqs/geemap/blob/master/examples/notebooks/
# - https://github.com/giswqs/earthengine-py-notebooks
# 
# Wu, Q., (2020). geemap: A Python package for interactive mapping with Google Earth Engine. The Journal of Open Source Software, 5(51), 2305. https://doi.org/10.21105/joss.02305
