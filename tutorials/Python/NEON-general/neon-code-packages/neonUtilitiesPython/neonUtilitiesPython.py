#!/usr/bin/env python
# coding: utf-8

# ---
# syncID: 5be9f80592394af3bc09cf8e469fef6e
# title: "Using neonUtilities in Python"
# description: "Use the neonUtilities R package in Python, via the rpy2 library."
# dateCreated: 2018-5-10
# authors: Claire K. Lunch
# contributors: Donal O'Leary
# estimatedTime: 0.5 hour
# packagesLibraries: rpy2
# topics: data-management,rep-sci
# languagesTool: python
# dataProduct: 
# code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/NEON-general/neon-code-packages/neonUtilitiesPython/neonUtilitiesPython.py
# tutorialSeries: 
# urlTitle: neon-utilities-python
# ---

# The instructions below will guide you through using the neonUtilities R package 
# in Python, via the rpy2 package. rpy2 creates an R environment you can interact 
# with from Python.
# 
# The assumption in this tutorial is that you want to work with NEON data in 
# Python, but you want to use the handy download and merge functions provided by 
# the `neonUtilities` R package to access and format the data for analysis. If 
# you want to do your analyses in R, use one of the R-based tutorials below.
# 
# For more information about the `neonUtilities` package, and instructions for 
# running it in R directly, see the <a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore</a> tutorial 
# and/or the <a href="http://www.neonscience.org/neonDataStackR" target="_blank">neonUtilities tutorial</a>.
# 
# 
# ## Install and set up
# 
# Before starting, you will need:
# 
# 1. Python 3 installed. It is probably possible to use this workflow in Python 2, 
# but these instructions were developed and tested using 3.7.4.
# 2. R installed. You don't need to have ever used it directly. We tested using 
# R 3.6.1, but most other recent versions should also work.
# 3. `rpy2` installed. Run the line below from the command line, it won't run within 
# Jupyter. See <a href="https://docs.python.org/3/installing/" target="_blank">Python documentation</a> for more information on how to install packages. 
# `rpy2` often has install problems on Windows, see "Windows Users" section below if 
# you are running Windows.
# 4. You may need to install `pip` before installing `rpy2`, if you don't have it 
# installed already.
# 
# From the command line, run:

# In[1]:


pip install rpy2


# ### Windows users
# 
# The rpy2 package was built for Mac, and doesn't always work smoothly on Windows. 
# If you have trouble with the install, try these steps.
# 
# 1. Add C:\Program Files\R\R-3.3.1\bin\x64 to the Windows Environment Variable “Path”
# 2. Install rpy2 manually from https://www.lfd.uci.edu/~gohlke/pythonlibs/#rpy2
#     1. Pick the correct version. At the download page the portion of the files 
#     with cp## relate to the Python version. e.g., rpy2 2.9.2 cp36 cp36m win_amd64.whl 
#     is the correct download when 2.9.2 is the latest version of rpy2 and you are 
#     running Python 36 and 64 bit Windows (amd64).
#     2. Save the whl file, navigate to it in windows then run pip directly on the file 
#     as follows “pip install rpy2 2.9.2 cp36 cp36m win_amd64.whl”
# 3. Add  an R_HOME Windows environment variable with the path C:\Program Files\R\R-3.4.3 
# (or whichever version you are running)
# 4. Add an R_USER Windows environment variable with the path C:\Users\yourUserName\AppData\Local\Continuum\Anaconda3\Lib\site-packages\rpy2

# ## Load packages

# Now import `rpy2` into your session.

# In[2]:


import rpy2
import rpy2.robjects as robjects
from rpy2.robjects.packages import importr


# Load the base R functionality, using the `rpy2` function `importr()`.

# In[3]:


base = importr('base')
utils = importr('utils')
stats = importr('stats')


# The basic syntax for running R code via `rpy2` is `package.function(inputs)`, 
# where `package` is the R package in use, `function` is the name of the function 
# within the R package, and `inputs` are the inputs to the function. In other 
# words, it's very similar to running code in R as `package::function(inputs)`. 
# For example:

# In[4]:


stats.rnorm(6, 0, 1)


# Suppress R warnings. This step can be skipped, but will result in messages 
# getting passed through from R that Python will interpret as warnings.

# In[5]:


from rpy2.rinterface import set_writeconsole_warnerror
import logging
set_writeconsole_warnerror(None)


# Install the `neonUtilities` R package. Here I've specified the RStudio 
# CRAN mirror as the source, but you can use a different one if you 
# prefer.
# 
# You only need to do this step once to use the package, but we update 
# the `neonUtilities` package every few months, so reinstalling 
# periodically is recommended.
# 
# This installation step carries out the same steps in the same places on 
# your hard drive that it would if run in R directly, so if you use R 
# regularly and have already installed `neonUtilities` on your machine, 
# you can skip this step. And be aware, this also means if you install 
# other packages, or new versions of packages, via `rpy2`, they'll 
# be updated the next time you use R, too.
# 
# The semicolon at the end of the line (here, and in some other function 
# calls below) can be omitted. It suppresses a note indicating the output 
# of the function is null. The output is null because these functions download 
# or modify files on your local drive, but none of the data are read into the 
# Python or R environments.

# In[6]:


utils.install_packages('neonUtilities', repos='https://cran.rstudio.com/');


# Now load the `neonUtilities` package. This does need to be run every time 
# you use the code; if you're familiar with R, `importr()` is roughly 
# equivalent to the `library()` function in R.

# In[7]:


neonUtilities = importr('neonUtilities')


# ## Join data files: stackByTable()
# 
# The function `stackByTable()` in `neonUtilities` merges the monthly, 
# site-level files the <a href="http://data.neonscience.org/home" target="_blank">NEON Data Portal</a> 
# provides. Start by downloading the dataset you're interested in from the 
# Portal. Here, we'll assume you've downloaded IR Biological Temperature. 
# It will download as a single zip file named `NEON_temp-bio.zip`. Note the 
# file path it's saved to and proceed.

# Run the `stackByTable()` function to stack the data. It requires only one 
# input, the path to the zip file you downloaded from the NEON Data Portal.
# 
# For additional, optional inputs to `stackByTable()`, see the <a href="http://neonscience.org/neonDataStackR" target="_blank">R tutorial</a> 
# for neonUtilities.

# In[8]:


neonUtilities.stackByTable(filepath='~/Downloads/NEON_temp-bio.zip');


# Check the folder containing the original zip file from the Data Portal; 
# you should now have a subfolder containing the unzipped and stacked files called `stackedFiles`.

# ## Download files to be stacked: zipsByProduct()
# 
# The function `zipsByProduct()` uses the <a href="http://data.neonscience.org/data-api" target="_blank">NEON API</a> to programmatically download 
# data files for a given product. The files downloaded by `zipsByProduct()` 
# can then be fed into `stackByTable()`.

# Run the downloader with these inputs: a DPID, a set of 4-letter site IDs (or 
# "all" for all sites), a download package (either basic or expanded), the 
# filepath to download the data to, and an indicator to check the size of 
# your download before proceeding or not (TRUE/FALSE).
# 
# The DPID is the data product identifier, and can be found in the data product 
# box on the NEON <a href="https://data.neonscience.org/data-products/explore" target="_blank">Explore Data</a> page. 
# Here we'll download Breeding landbird point counts, DP1.10003.001.
# 
# There are two differences relative to running `zipsByProduct()` in R directly: 
# 
# 1. `check.size` becomes `check_size`, because dots have programmatic meaning 
# in Python
# 2. `TRUE` (or `T`) becomes `'TRUE'` because the values TRUE and FALSE don't 
# have special meaning in Python the way they do in R, so it interprets them 
# as variables if they're unquoted.
# 
# `check_size='TRUE'` does not work correctly in the Python environment. It 
# estimates the size of the download and asks you to confirm before proceeding, 
# and this interactive display doesn't work correctly outside R. Set 
# `check_size='FALSE'` to avoid this problem, but be thoughtful about the size 
# of your query since it will proceed to download without checking.

# In[9]:


neonUtilities.zipsByProduct(dpID='DP1.10003.001', 
                            site=base.c('HARV','BART'), 
                            savepath='~/Downloads',
                            package='basic', 
                            check_size='FALSE');


# The message output by `zipsByProduct()` indicates the file path where the 
# files have been downloaded.
# 
# Now take that file path and pass it to `stackByTable()`.

# In[10]:


neonUtilities.stackByTable(filepath='~/Downloads/filesToStack10003');


# ## Read downloaded and stacked files into Python
# 
# We've now downloaded biological temperature and bird data, and merged 
# the site by month files. Now let's read those data into Python so you 
# can proceed with analyses.
# 
# First let's take a look at what's in the output folders.

# In[11]:


import os
os.listdir('/Users/olearyd/Downloads/filesToStack10003/stackedFiles/')


# In[12]:


os.listdir('/Users/olearyd/Downloads/NEON_temp-bio/stackedFiles/')


# Each data product folder contains a set of data files and metadata files. 
# Here, we'll read in the data files and take a look at the contents; for 
# more details about the contents of NEON data files and how to interpret them, 
# see the <a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore tutorial</a>.
# 
# There are a variety of modules and methods for reading tabular data into 
# Python; here we'll use the `pandas` module, but feel free to use your own 
# preferred method.
# 
# First, let's read in the two data tables in the bird data: 
# `brd_countdata` and `brd_perpoint`.

# In[13]:


import pandas
brd_perpoint = pandas.read_csv('/Users/olearyd/Downloads/filesToStack10003/stackedFiles/brd_perpoint.csv')
brd_countdata = pandas.read_csv('/Users/olearyd/Downloads/filesToStack10003/stackedFiles/brd_countdata.csv')


# And take a look at the contents of each file. For descriptions and unit of each 
# column, see the `variables_10003` file.

# In[14]:


brd_perpoint


# In[15]:


brd_countdata


# And now let's do the same with the 30-minute data table for biological 
# temperature.

# In[16]:


IRBT30 = pandas.read_csv('/Users/olearyd/Downloads/NEON_temp-bio/stackedFiles/IRBT_30_minute.csv')
IRBT30


# ## Download remote sensing files: byFileAOP()
# 
# The function `byFileAOP()` uses the <a href="http://data.neonscience.org/data-api" target="_blank">NEON API</a> 
# to programmatically download data files for remote sensing (AOP) data 
# products. These files cannot be stacked by `stackByTable()` because they 
# are not tabular data. The function simply creates a folder in your working 
# directory and writes the files there. It preserves the folder structure 
# for the subproducts.
# 
# The inputs to `byFileAOP()` are a data product ID, a site, a year, 
# a filepath to save to, and an indicator to check the size of the 
# download before proceeding, or not. As above, set check_size="FALSE" 
# when working in Python. Be especially cautious about download size 
# when downloading AOP data, since the files are very large.
# 
# Here, we'll download Ecosystem structure (Canopy Height Model) data from 
# Hopbrook (HOPB) in 2017.

# In[17]:


neonUtilities.byFileAOP(dpID='DP3.30015.001', site='HOPB',
                        #easting = 718000, northing = 4709000,
                        year='2017', check_size='FALSE',
                       savepath='~/Downloads');


# Let's read one tile of data into Python and view it. We'll use the 
# `rasterio` and `matplotlib` modules here, but as with tabular data, 
# there are other options available.

# In[18]:


import rasterio
CHMtile = rasterio.open('/Users/olearyd/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D01_HOPB_DP3_718000_4709000_CHM.tif')


# In[19]:


import matplotlib.pyplot as plt
from rasterio.plot import show
fig, ax = plt.subplots(figsize = (8,3))
show(CHMtile)


# In[ ]:




