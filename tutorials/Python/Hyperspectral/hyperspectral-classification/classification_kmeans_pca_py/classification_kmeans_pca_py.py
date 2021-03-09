#!/usr/bin/env python
# coding: utf-8

# ---
# syncID: 75f8885948494c0dbe6084099c61dd1e
# title: "Unsupervised Spectral Classification in Python: KMeans & PCA"
# description: "Learn to classify spectral data using KMeans and Principal Components Analysis (PCA)."
# dateCreated: 2018-07-10 
# authors: Bridget Hass
# contributors: Donal O'Leary
# estimatedTime:
# packagesLibraries: numpy, gdal, matplotlib, matplotlib.pyplot
# topics: hyperspectral-remote-sensing, HDF5, remote-sensing
# languagesTool: python
# dataProduct: NEON.DP1.30006, NEON.DP3.30006, NEON.DP1.30008
# code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/hyperspectral-classification/classification_kmeans_pca_py/classification_kmeans_pca_py.ipynb
# tutorialSeries: intro-hsi-py-series
# urlTitle: classification-kmeans-pca-python
# ---

# In this tutorial, we will use the `Spectral Python (SPy)` package to run KMeans and Principal Component Analysis unsupervised classification algorithms. 
# 
# <div id="ds-objectives" markdown="1">
# 
# ### Objectives
# After completing this tutorial, you will be able to:
# 
# * Classify spectral remote sensing data. 
# 
# ### Install Python Packages
# 
# * **numpy**
# * **gdal** 
# * **matplotlib** 
# * **matplotlib.pyplot** 
# 
# 
# ### Download Data
# 
# This tutorial uses a 1km AOP Hyperspectral Reflectance 'tile' from the SERC site. <a href="https://ndownloader.figshare.com/files/25752968">
# Download the spectral classification teaching data subset here</a>.
# 
# <a href="https://ndownloader.figshare.com/files/25752968" class="link--button link--arrow">
# Download Dataset</a>
# 
# </div>

# In this tutorial, we will use the `Spectral Python (SPy)` package to run KMeans and Principal Component Analysis unsupervised classification algorithms. 
# 
# To learn more about the Spcral Python packages read: 
# 
# * <a href="http://www.spectralpython.net/user_guide.html" target="blank">Spectral Python User Guide</a>.
# * <a href="http://www.spectralpython.net/algorithms.html#unsupervised-classification" target="_blank">Spectral Python Unsupervised Classification</a>.
# 
# 
# ## KMeans Clustering
# 
# 
# **KMeans** is an iterative clustering algorithm used to classify unsupervised data (eg. data without a training set) into a specified number of groups. The algorithm begins with an initial set of randomly determined cluster centers. Each pixel in the image is then assigned to the nearest cluster center (using distance in N-space as the distance metric) and each cluster center is then re-computed as the centroid of all pixels assigned to the cluster. This process repeats until a desired stopping criterion is reached (e.g. max number of iterations). 
# 
# Read more on KMeans clustering from <a href="http://www.spectralpython.net/algorithms.html#k-means-clustering" target="_blank">Spectral Python</a>. 
# 
# To visualize how the algorithm works, it's easier look at a 2D data set. In the example below, watch how the cluster centers shift with progressive iterations, 
# 
#  <figure>
# 	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-general/KMeans2D.gif">
# 	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-general/KMeans2D.gif"></a>
# 	<figcaption> KMeans clustering demonstration Source: <a href="https://sandipanweb.wordpress.com/2017/03/19/hard-soft-clustering-with-k-means-weighted-k-means-and-gmm-em/" target="_blank">Sandipan Deyn</a>
# 	</figcaption>
# </figure>
# 
# 
# ## Principal Component Analysis (PCA) - Dimensionality Reduction
# 
# Many of the bands within hyperspectral images are often strongly correlated. The principal components transformation represents a linear transformation of the original image bands to a set of new, uncorrelated features. These new features correspond to the eigenvectors of the image covariance matrix, where the associated eigenvalue represents the variance in the direction of the eigenvector. A very large percentage of the image variance can be captured in a relatively small number of principal components (compared to the original number of bands).
# 
# Read more about PCA with 
# <a href="http://www.spectralpython.net/algorithms.html#principal-components" target="_blank">Spectral Python</a>.
# 

# ## Set up
# 
# To run this notebook, the following Python packages need to be installed. You can install required packages from command line `pip install spectra scikit-learn cvxopt`.
# 
# or if already in a Jupyter Notebook, run the following code in a Notebook code cell. 
#  
# Packages:
# - pylab
# - spectral
# - scikit-learn (optional)
# 
# ```python 
# import sys
# !{sys.executable} -m pip install spectral
# !conda install --yes --prefix {sys.prefix} scikit-learn
# !conda install --yes --prefix {sys.prefix} cvxopt 
# ```
# 
# In order to make use of the interactive graphics capabilities of `spectralpython`, such as `N-Dimensional Feature Display`, you work in a Python 3.6 environment (as of July 2018). 
# 
# For more, read from <a href="http://www.spectralpython.net/graphics.html" target="_blank">Spectral Python</a>.
# 
# **Optional:**
# 
# **matplotlib wx backend** (for 3-D visualization of PCA, requires Python 3.6)
# Find out more on 
# <a href="https://stackoverflow.com/questions/42007164/how-to-install-wxpython-phoenix-for-python-3-6" target="_blank"> StackOverflow</a>. 
# 
# ```python 
# conda install -c newville wxpython-phoenix
# ```
# 
# **Managing Conda Environments**
# - **nb_conda_kernels** package provides a separate jupyter kernel for each conda environment
# - Find out more on 
# <a href="https://conda.io/docs/user-guide/tasks/manage-environments.html" target="_blank"> Conda docs</a>. 
# 
# ```python 
# conda install -c conda-forge nb_conda_kernels
# ```

# First, import the required packages and set display preferences:

# In[1]:


from spectral import *
import spectral.io.envi as envi
import numpy as np
import matplotlib

#for clean output, to not print warnings, don't use when developing script
import warnings
warnings.filterwarnings('ignore')


# For this example, we will read in a reflectance tile in ENVI format. NEON provides an h5 plugin for ENVI 

# In[2]:


# You will need to download the example dataset above,
# extract the files therein,
# and update the filepaths below per your local machine
img = envi.open('/Users/olearyd/Git/data/NEON_D02_SERC_DP3_368000_4306000_reflectance.hdr',
                '/Users/olearyd/Git/data/NEON_D02_SERC_DP3_368000_4306000_reflectance.dat')


# Note that the information is stored differently when read in with `envi.open`. We can find the wavelength information in `img.bands.centers`. Let's take a look at the first and last wavelengths values: 

# In[3]:


print('First 3 Band Center Wavelengths:',img.bands.centers[:3])
print('Last 3 Band Center Wavelengths:',img.bands.centers[-3:])


# We'll set the Water Vapor Band windows to NaN:

# In[4]:


img.bands.centers[191:211]==np.nan
img.bands.centers[281:314]==np.nan
img.bands.centers[-10:]==np.nan


# To get a quick look at the `img` data, use the `params` method:

# In[5]:


img.params


# Metadata information is stored in `img.metadata`, a dictionary. Let's look at the metadata contents:

# In[6]:


md = img.metadata
print('Metadata Contents:')
for item in md:
    print('\t',item)


# To access any of these metadata items, use the syntax `md['description']` or `md['map info']`:

# In[7]:


print('description:',md['description'])
print('map info:',md['map info'])


# You can also use `type` and `len` to look at the type and length (or number) of some of the metadata contents:

# In[8]:


print(type(md['wavelength']))
print('Number of Bands:',len(md['wavelength']))


# Let's look at the data using `imshow`, a wrapper around matplotlib's imshow for multi-band images:

# In[9]:


view = imshow(img,bands=(58,34,19),stretch=0.05,title="RGB Image of 2017 SERC Tile")
print(view)


# When dealing with NEON hyperspectral data, we first want to remove the water vapor & noisy bands, keeping only the valid bands. To speed up the classification algorithms for demonstration purposes, we'll look at a subset of the data using `read_subimage`, a built in method to subset by area and bands. Type `help(img.read_subimage)` to see how it works. 

# In[10]:


valid_band_range = [i for j in (range(0,191), range(212, 281), range(315,415)) for i in j] #remove water vapor bands
img_subset = img.read_subimage(range(400,600),range(400,600),bands=valid_band_range) #subset image by area and bands


# Plot the subsetted image for reference:

# In[11]:


view = imshow(img_subset,bands=(58,34,19),stretch=0.01,title="RGB Image of 2017 SERC Tile Subset")


# Now that we have the image subsetted, lets run the `k-means` algorithm. Type `help(kmeans)` to show how the function works. To run the k-means algorithm on the image and create 5 clusters, using a maximum of 50 iterations, use the following syntax:

# In[12]:


(m,c) = kmeans(img_subset,5,50) 


# Note that the algorithm terminated afte 14 iterations, when the pixels stopped being reassigned. 
# 
# **Data Tip**: You can iterrupt the algorithm with a keyboard interrupt (CTRL-C) if you notice that the number of reassigned pixels drops off. Kmeans catches the KeyboardInterrupt exception and returns the clusters generated at the end of the previous iteration. If you are running the algorithm interactively, this feature allows you to set the max number of iterations to an arbitrarily high number and then stop the algorithm when the clusters have converged to an acceptable level. If you happen to set the max number of iterations too small (many pixels are still migrating at the end of the final iteration), you can simply call kmeans again to resume processing by passing the cluster centers generated by the previous call as the optional `start_clusters` argument to the function.
# 
# Let's take a look at the cluster centers `c`. In this case, these represent spectras of the five clusters of reflectance that the data were grouped into.

# In[13]:


print(c.shape)


# `c` contains 5 groups of spectral curves with 360 bands (the # of bands we've kept after removing the water vapor windows and the last 10 noisy bands). Let's plot these spectral classes:

# In[14]:


get_ipython().run_line_magic('matplotlib', 'inline')
import pylab
pylab.figure()
for i in range(c.shape[0]):
    pylab.plot(c[i])
pylab.show
pylab.title('Spectral Classes from K-Means Clustering')
pylab.xlabel('Bands (with Water Vapor Windows Removed)')
pylab.ylabel('Reflectance')


# In[15]:


#%matplotlib notebook
view = imshow(img_subset, bands=(58,34,19),stretch=0.01, classes=m)
view.set_display_mode('overlay')
view.class_alpha = 0.5 #set transparency
view.show_data


# ## Challenges: K-Means
# 
# 1. What do you think the spectral classes in the figure you just created represent? 
# 2. Try using a different number of clusters in the `kmeans` algorithm (e.g., 3 or 10) to see what spectral classes and classifications result. 

# ## Principal Component Analysis (PCA)
# 
# Many of the bands within hyperspectral images are often strongly correlated. The principal components transformation represents a linear transformation of the original image bands to a set of new, uncorrelated features. These new features correspond to the eigenvectors of the image covariance matrix, where the associated eigenvalue represents the variance in the direction of the eigenvector. A very large percentage of the image variance can be captured in a relatively small number of principal components (compared to the original number of bands) .

# In[16]:


pc = principal_components(img_subset)
pc_view = imshow(pc.cov)
xdata = pc.transform(img_subset)


# In the covariance matrix display, lighter values indicate strong positive covariance, darker values indicate strong negative covariance, and grey values indicate covariance near zero.

# In[17]:


pcdata = pc.reduce(num=10).transform(img_subset)


# In[18]:


pc_0999 = pc.reduce(fraction=0.999)

# How many eigenvalues are left?
print(len(pc_0999.eigenvalues))

img_pc = pc_0999.transform(img_subset)
print(img_pc.shape)

v = imshow(img_pc[:,:,:5], stretch_all=True)

