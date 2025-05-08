---
syncID: 75f8885948494c0dbe6084099c61dd1e
title: "Unsupervised Spectral Classification in Python: KMeans & PCA"
description: "Learn to classify spectral data using KMeans and Principal Components Analysis (PCA)."
dateCreated: 2018-07-10 
authors: Bridget Hass
contributors: Donal O'Leary
estimatedTime: 1 hour
packagesLibraries: gdal, h5py, neonutilities
topics: hyperspectral-remote-sensing, HDF5, remote-sensing, classification
languagesTool: python
dataProduct: NEON.DP1.30006, NEON.DP3.30006
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/classification/kmeans-pca/classification_kmeans_pca.ipynb
tutorialSeries: 
urlTitle: classification-kmeans-pca
---

In this tutorial, we will use the `Spectral Python (SPy)` package to run a KMeans unsupervised classification algorithm and then we will run Principal Component Analysis to reduce data dimensionality.

<div id="ds-objectives" markdown="1">

### Objectives
After completing this tutorial, you will be able to:

* Run kmeans unsupervised classification on AOP hyperspectral data
* Reduce data dimensionality using Principal Component Analysis (PCA)

### Install Python Packages

* **gdal**
* **h5py**
* **scikit-image**
* **spectral**
* **requests**

### For visualization (optional)
`pip install wxPython`
`pip install PyOpenGL PyOpenGL_accelerate`

### Download Data

This tutorial uses a AOP Hyperspectral Surface Bidirectional Reflectance tile (1 km x 1 km) from the NEON <a href="https://www.neonscience.org/field-sites/serc" target="blank">Smithsonian Environmental Research Center(SERC)</a> site.

Spectrometer orthorectified surface bidirectional reflectance - mosaic
https://data.neonscience.org/data-products/DP3.30006.002

Data will be downloaded as part of the lesson using the Python `neonutilities` package

</div>

In this tutorial, we will use the `Spectral Python (SPy)` package to run KMeans unsupervised classification algorithm as well as Principal Component Analysis (PCA).

To learn more about the Spectral Python packages read: 

* <a href="http://www.spectralpython.net/user_guide.html" target="blank">Spectral Python User Guide</a>.
* <a href="http://www.spectralpython.net/algorithms.html#unsupervised-classification" target="_blank">Spectral Python Unsupervised Classification</a>.


## KMeans Clustering


**KMeans** is an iterative clustering algorithm used to classify unsupervised data (eg. data without a training set) into a specified number of groups. The algorithm begins with an initial set of randomly determined cluster centers. Each pixel in the image is then assigned to the nearest cluster center (using distance in N-space as the distance metric) and each cluster center is then re-computed as the centroid of all pixels assigned to the cluster. This process repeats until a desired stopping criterion is reached (e.g. max number of iterations). 

Read more on KMeans clustering from <a href="http://www.spectralpython.net/algorithms.html#k-means-clustering" target="_blank">Spectral Python</a>. 

To visualize how the algorithm works, it's easier look at a 2D data set. In the example below, watch how the cluster centers shift with progressive iterations, 

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-general/KMeans2D.gif">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-general/KMeans2D.gif"></a>
	<figcaption> KMeans clustering demonstration Source: <a href="https://sandipanweb.wordpress.com/2017/03/19/hard-soft-clustering-with-k-means-weighted-k-means-and-gmm-em/" target="_blank">Sandipan Deyn</a>
	</figcaption>
</figure>


## Principal Component Analysis (PCA) - Dimensionality Reduction

Many of the bands within hyperspectral images are often strongly correlated. The principal components transformation represents a linear transformation of the original image bands to a set of new, uncorrelated features. These new features correspond to the eigenvectors of the image covariance matrix, where the associated eigenvalue represents the variance in the direction of the eigenvector. A very large percentage of the image variance can be captured in a relatively small number of principal components (compared to the original number of bands).

Read more about PCA with 
<a href="http://www.spectralpython.net/algorithms.html#principal-components" target="_blank">Spectral Python</a>.


## Set up

To run this notebook, the following Python packages need to be installed. You can install required packages from command line `pip install spectra scikit-learn cvxopt`.

or if already in a Jupyter Notebook, run the following code in a Notebook code cell. 
 
Packages:
- neonutilities
- spectral
- scikit-learn (optional)

```python 
import sys
!{sys.executable} -m pip install spectral
!conda install --yes --prefix {sys.prefix} scikit-learn
!conda install --yes --prefix {sys.prefix} cvxopt 
```

In order to make use of the interactive graphics capabilities of `spectralpython`, such as `N-Dimensional Feature Display`, you work in a Python 3.6 environment (as of July 2018). 

For more, read from <a href="http://www.spectralpython.net/graphics.html" target="_blank">Spectral Python</a>.

**Optional:**

**matplotlib wx backend** (for 3-D visualization of PCA, requires Python 3.6)
Find out more on 
<a href="https://stackoverflow.com/questions/42007164/how-to-install-wxpython-phoenix-for-python-3-6" target="_blank"> StackOverflow</a>. 

```python 
conda install -c newville wxpython-phoenix
```

**Managing Conda Environments**
- **nb_conda_kernels** package provides a separate jupyter kernel for each conda environment
- Find out more on 
<a href="https://conda.io/docs/user-guide/tasks/manage-environments.html" target="_blank"> Conda docs</a>. 

```python 
conda install -c conda-forge nb_conda_kernels
```

First, import the required packages and set display preferences:


```python
import h5py
import matplotlib
import neonutilities as nu
import numpy as np
import os
import requests
from spectral import *
from time import time
```


```python
home_dir = os.path.expanduser("~")
data_dir = os.path.join(home_dir,'data')
```

For this example, we will download a bidirectional surface reflectance data cube at the SERC site, collected in 2022.


```python
nu.by_tile_aop(dpid='DP3.30006.002',
               site='SERC',
               year='2022',
               easting=368005,
               northing=4306005,
               include_provisional=True,
               #token=your_token_here
               savepath=os.path.join(data_dir)) # save to the home directory under a 'data' subfolder
```

    Provisional data are included. To exclude provisional data, use input parameter include_provisional=False.
    

    Continuing will download 2 files totaling approximately 692.0 MB. Do you want to proceed? (y/n)  n
    

    Download halted
    

Let's see what data were downloaded.


```python
# iterating over directory and subdirectory to get desired result
for root, dirs, files in os.walk(data_dir):
    for name in files:
        if name.endswith('.h5'):
            print(os.path.join(root, name))  # printing file name
```

    C:\Users\bhass\data\DP3.30006.002\neon-aop-provisional-products\2022\FullSite\D02\2022_SERC_6\L3\Spectrometer\Reflectance\NEON_D02_SERC_DP3_368000_4306000_bidirectional_reflectance.h5
    


```python
h5_tile = r'C:\Users\bhass\data\DP3.30006.002\neon-aop-provisional-products\2022\FullSite\D02\2022_SERC_6\L3\Spectrometer\Reflectance\NEON_D02_SERC_DP3_368000_4306000_bidirectional_reflectance.h5'
```


```python
# function to download data stored on the internet in a public url to a local file
def download_url(url,download_dir):
    if not os.path.isdir(download_dir):
        os.makedirs(download_dir)
    filename = url.split('/')[-1]
    r = requests.get(url, allow_redirects=True)
    file_object = open(os.path.join(download_dir,filename),'wb')
    file_object.write(r.content)
```


```python
module_url = "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/aop_python_modules/neon_aop_hyperspectral.py"
download_url(module_url,'../python_modules')
# os.listdir('../python_modules') #optionally show the contents of this directory to confirm the file downloaded
```


```python
sys.path.insert(0, '../python_modules')
# import the neon_aop_hyperspectral module, the semicolon supresses an empty plot from displaying
import neon_aop_hyperspectral as neon_hs;
```


    
![png](output_14_0.png)
    



```python
# read in the reflectance data using the aop_h5refl2array function, this may also take a bit of time
start_time = time()
refl, refl_metadata, wavelengths = neon_hs.aop_h5refl2array(h5_tile,'Reflectance')
print("--- It took %s seconds to read in the data ---" % round((time() - start_time),0))
```

    Reading in  C:\Users\bhass\data\DP3.30006.002\neon-aop-provisional-products\2022\FullSite\D02\2022_SERC_6\L3\Spectrometer\Reflectance\NEON_D02_SERC_DP3_368000_4306000_bidirectional_reflectance.h5
    --- It took 27.0 seconds to read in the data ---
    


```python
refl_metadata
```




    {'shape': (1000, 1000, 426),
     'no_data_value': -9999.0,
     'scale_factor': 10000.0,
     'bad_band_window1': array([1340, 1445]),
     'bad_band_window2': array([1790, 1955]),
     'projection': b'+proj=UTM +zone=18 +ellps=WGS84 +datum=WGS84 +units=m +no_defs',
     'EPSG': 32618,
     'res': {'pixelWidth': 1.0, 'pixelHeight': 1.0},
     'extent': (368000.0, 369000.0, 4306000.0, 4307000.0),
     'ext_dict': {'xMin': 368000.0,
      'xMax': 369000.0,
      'yMin': 4306000.0,
      'yMax': 4307000.0},
     'source': 'C:\\Users\\bhass\\data\\DP3.30006.002\\neon-aop-provisional-products\\2022\\FullSite\\D02\\2022_SERC_6\\L3\\Spectrometer\\Reflectance\\NEON_D02_SERC_DP3_368000_4306000_bidirectional_reflectance.h5'}




```python
print('First and last 5 center wavelengths, in nm:')
print(wavelengths[:5])
print(wavelengths[-5:])
```

    First and last 5 center wavelengths, in nm:
    [383.884003 388.891693 393.899506 398.907196 403.915009]
    [2492.149414 2497.157227 2502.165039 2507.172607 2512.18042 ]
    


```python
refl.shape
```




    (1000, 1000, 426)



Next let's define a function to clean and subset the data. 


```python
def clean_neon_refl_data(data, metadata, wavelengths, subset_factor=1):
    """Clean h5 reflectance data and metadata
    1. set data ignore value (-9999) to NaN
    2. apply reflectance scale factor (10000)
    3. remove bad bands (water vapor band windows + last 10 bands): 
        Band_Window_1_Nanometers = 1340, 1445
        Band_Window_2_Nanometers = 1790, 1955
    4. if subset_factor, subset by that factor
    """
    
    # use copy so original data and metadata doesn't change
    data_clean = data.copy().astype(float)
    metadata_clean = metadata.copy()
    
    #set data ignore value (-9999) to NaN:
    if metadata['no_data_value'] in data:
        nodata_ind = np.where(data_clean==metadata['no_data_value'])
        data_clean[nodata_ind]=np.nan 
    
    #apply reflectance scale factor (divide by 10000)
    data_clean = data_clean/metadata['scale_factor']
    
    #remove bad bands 
    #1. define indices corresponding to min/max center wavelength for each bad band window:
    bb1_ind0 = np.max(np.where(np.asarray(wavelengths<float(metadata['bad_band_window1'][0]))))
    bb1_ind1 = np.min(np.where(np.asarray(wavelengths>float(metadata['bad_band_window1'][1]))))

    bb2_ind0 = np.max(np.where(np.asarray(wavelengths<float(metadata['bad_band_window2'][0]))))
    bb2_ind1 = np.min(np.where(np.asarray(wavelengths>float(metadata['bad_band_window2'][1]))))
    bb3_ind0 = len(wavelengths)-15
    
    #define valid band ranges from indices:
    vb1 = list(range(10,bb1_ind0)); 
    vb2 = list(range(bb1_ind1,bb2_ind0))
    vb3 = list(range(bb2_ind1,bb3_ind0))
    # combine them to get a list of the valid bands
    vbs = vb1 + vb2 + vb3
    # subset by subset_factor (if subset_factor = 1 this will return the original valid_bands list)
    valid_bands_subset = vbs[::subset_factor]

    # subset the reflectance data by the valid_bands_subset
    data_clean = data_clean[:,:,valid_bands_subset]

    # subset the wavelengths by the same valid_bands_subset
    wavelengths_clean =[wavelengths[i] for i in valid_bands_subset]
    
    return data_clean, wavelengths_clean
```


```python
# clean the data - remove the band bands and subset
start_time = time()
refl_clean, wavelengths_clean = clean_neon_refl_data(refl, refl_metadata, wavelengths, subset_factor=2)
print("--- It took %s seconds to clean and subset the reflectance data ---" % round((time() - start_time),0))
```

    --- It took 12.0 seconds to clean and subset the reflectance data ---
    


```python
# Look at the dimensions of the data after cleaning:
print('Cleaned Data Dimensions:',refl_clean.shape)
print('Cleaned Wavelengths:',len(wavelengths_clean))
```

    Cleaned Data Dimensions: (1000, 1000, 173)
    Cleaned Wavelengths: 173
    


```python
start_time = time()
# run kmeans with 5 clusters and 50 iterations
(m,c) = kmeans(refl_clean, 5, 50) 
print("--- It took %s minutes to run kmeans on the reflectance data ---" % round((time() - start_time)/60,1))
```

    spectral:INFO: k-means iteration 1 - 373101 pixels reassigned.
    k-means iteration 1 - 373101 pixels reassigned.
    spectral:INFO: k-means iteration 2 - 135441 pixels reassigned.
    k-means iteration 2 - 135441 pixels reassigned.
    spectral:INFO: k-means iteration 3 - 54918 pixels reassigned.
    k-means iteration 3 - 54918 pixels reassigned.
    spectral:INFO: k-means iteration 4 - 37397 pixels reassigned.
    k-means iteration 4 - 37397 pixels reassigned.
    spectral:INFO: k-means iteration 5 - 25964 pixels reassigned.
    k-means iteration 5 - 25964 pixels reassigned.
    spectral:INFO: k-means iteration 6 - 22079 pixels reassigned.
    k-means iteration 6 - 22079 pixels reassigned.
    spectral:INFO: k-means iteration 7 - 20998 pixels reassigned.
    k-means iteration 7 - 20998 pixels reassigned.
    spectral:INFO: k-means iteration 8 - 21289 pixels reassigned.
    k-means iteration 8 - 21289 pixels reassigned.
    spectral:INFO: k-means iteration 9 - 23434 pixels reassigned.
    k-means iteration 9 - 23434 pixels reassigned.
    spectral:INFO: k-means iteration 10 - 29612 pixels reassigned.
    k-means iteration 10 - 29612 pixels reassigned.
    spectral:INFO: k-means iteration 11 - 45403 pixels reassigned.
    k-means iteration 11 - 45403 pixels reassigned.
    spectral:INFO: k-means iteration 12 - 84615 pixels reassigned.
    k-means iteration 12 - 84615 pixels reassigned.
    spectral:INFO: k-means iteration 13 - 84172 pixels reassigned.
    k-means iteration 13 - 84172 pixels reassigned.
    spectral:INFO: k-means iteration 14 - 47605 pixels reassigned.
    k-means iteration 14 - 47605 pixels reassigned.
    spectral:INFO: k-means iteration 15 - 27624 pixels reassigned.
    k-means iteration 15 - 27624 pixels reassigned.
    spectral:INFO: k-means iteration 16 - 22031 pixels reassigned.
    k-means iteration 16 - 22031 pixels reassigned.
    spectral:INFO: k-means iteration 17 - 22968 pixels reassigned.
    k-means iteration 17 - 22968 pixels reassigned.
    spectral:INFO: k-means iteration 18 - 27731 pixels reassigned.
    k-means iteration 18 - 27731 pixels reassigned.
    spectral:INFO: k-means iteration 19 - 31293 pixels reassigned.
    k-means iteration 19 - 31293 pixels reassigned.
    spectral:INFO: k-means iteration 20 - 30422 pixels reassigned.
    k-means iteration 20 - 30422 pixels reassigned.
    spectral:INFO: k-means iteration 21 - 25540 pixels reassigned.
    k-means iteration 21 - 25540 pixels reassigned.
    spectral:INFO: k-means iteration 22 - 20758 pixels reassigned.
    k-means iteration 22 - 20758 pixels reassigned.
    spectral:INFO: k-means iteration 23 - 16314 pixels reassigned.
    k-means iteration 23 - 16314 pixels reassigned.
    spectral:INFO: k-means iteration 24 - 13115 pixels reassigned.
    k-means iteration 24 - 13115 pixels reassigned.
    spectral:INFO: k-means iteration 25 - 10736 pixels reassigned.
    k-means iteration 25 - 10736 pixels reassigned.
    spectral:INFO: k-means iteration 26 - 9101 pixels reassigned.
    k-means iteration 26 - 9101 pixels reassigned.
    spectral:INFO: k-means iteration 27 - 7706 pixels reassigned.
    k-means iteration 27 - 7706 pixels reassigned.
    spectral:INFO: k-means iteration 28 - 6495 pixels reassigned.
    k-means iteration 28 - 6495 pixels reassigned.
    spectral:INFO: k-means iteration 29 - 5433 pixels reassigned.
    k-means iteration 29 - 5433 pixels reassigned.
    spectral:INFO: k-means iteration 30 - 4656 pixels reassigned.
    k-means iteration 30 - 4656 pixels reassigned.
    spectral:INFO: k-means iteration 31 - 4038 pixels reassigned.
    k-means iteration 31 - 4038 pixels reassigned.
    spectral:INFO: k-means iteration 32 - 3661 pixels reassigned.
    k-means iteration 32 - 3661 pixels reassigned.
    spectral:INFO: k-means iteration 33 - 3356 pixels reassigned.
    k-means iteration 33 - 3356 pixels reassigned.
    spectral:INFO: k-means iteration 34 - 3216 pixels reassigned.
    k-means iteration 34 - 3216 pixels reassigned.
    spectral:INFO: k-means iteration 35 - 3158 pixels reassigned.
    k-means iteration 35 - 3158 pixels reassigned.
    spectral:INFO: k-means iteration 36 - 3301 pixels reassigned.
    k-means iteration 36 - 3301 pixels reassigned.
    spectral:INFO: k-means iteration 37 - 3525 pixels reassigned.
    k-means iteration 37 - 3525 pixels reassigned.
    spectral:INFO: k-means iteration 38 - 3994 pixels reassigned.
    k-means iteration 38 - 3994 pixels reassigned.
    spectral:INFO: k-means iteration 39 - 5053 pixels reassigned.
    k-means iteration 39 - 5053 pixels reassigned.
    spectral:INFO: k-means iteration 40 - 7114 pixels reassigned.
    k-means iteration 40 - 7114 pixels reassigned.
    spectral:INFO: k-means iteration 41 - 11187 pixels reassigned.
    k-means iteration 41 - 11187 pixels reassigned.
    spectral:INFO: k-means iteration 42 - 18680 pixels reassigned.
    k-means iteration 42 - 18680 pixels reassigned.
    spectral:INFO: k-means iteration 43 - 27140 pixels reassigned.
    k-means iteration 43 - 27140 pixels reassigned.
    spectral:INFO: k-means iteration 44 - 31803 pixels reassigned.
    k-means iteration 44 - 31803 pixels reassigned.
    spectral:INFO: k-means iteration 45 - 29972 pixels reassigned.
    k-means iteration 45 - 29972 pixels reassigned.
    spectral:INFO: k-means iteration 46 - 24678 pixels reassigned.
    k-means iteration 46 - 24678 pixels reassigned.
    spectral:INFO: k-means iteration 47 - 19487 pixels reassigned.
    k-means iteration 47 - 19487 pixels reassigned.
    spectral:INFO: k-means iteration 48 - 15623 pixels reassigned.
    k-means iteration 48 - 15623 pixels reassigned.
    spectral:INFO: k-means iteration 49 - 12934 pixels reassigned.
    k-means iteration 49 - 12934 pixels reassigned.
    spectral:INFO: k-means iteration 50 - 10783 pixels reassigned.
    k-means iteration 50 - 10783 pixels reassigned.
    spectral:INFO: kmeans terminated with 5 clusters after 50 iterations.
    kmeans terminated with 5 clusters after 50 iterations.
    

    --- It took 3.7 minutes to run kmeans on the reflectance data ---
    

Note that the algorithm still had on the order of 10000 clusters reassigning, when the 50 iterations were reached. You may extend the # of iterations.

**Data Tip**: You can iterrupt the algorithm with a keyboard interrupt (CTRL-C) if you notice that the number of reassigned pixels drops off. Kmeans catches the `KeyboardInterrupt` exception and returns the clusters generated at the end of the previous iteration. If you are running the algorithm interactively, this feature allows you to set the max number of iterations to an arbitrarily high number and then stop the algorithm when the clusters have converged to an acceptable level. If you happen to set the max number of iterations too small (many pixels are still migrating at the end of the final iteration), you cancall kmeans again to resume processing by passing the cluster centers generated by the previous call as the optional `start_clusters` argument to the function.

Let's try that now:


```python
start_time = time()
# run kmeans with 5 clusters and 50 iterations
(m, c) = kmeans(refl_clean, 5, 50, start_clusters=c) 
print("--- It took %s minutes to run kmeans on the reflectance data ---" % round((time() - start_time)/60,1))
```

    spectral:INFO: k-means iteration 1 - 787247 pixels reassigned.
    k-means iteration 1 - 787247 pixels reassigned.
    spectral:INFO: k-means iteration 2 - 7684 pixels reassigned.
    k-means iteration 2 - 7684 pixels reassigned.
    spectral:INFO: k-means iteration 3 - 6552 pixels reassigned.
    k-means iteration 3 - 6552 pixels reassigned.
    spectral:INFO: k-means iteration 4 - 5462 pixels reassigned.
    k-means iteration 4 - 5462 pixels reassigned.
    spectral:INFO: k-means iteration 5 - 4681 pixels reassigned.
    k-means iteration 5 - 4681 pixels reassigned.
    spectral:INFO: k-means iteration 6 - 4011 pixels reassigned.
    k-means iteration 6 - 4011 pixels reassigned.
    spectral:INFO: k-means iteration 7 - 3325 pixels reassigned.
    k-means iteration 7 - 3325 pixels reassigned.
    spectral:INFO: k-means iteration 8 - 2843 pixels reassigned.
    k-means iteration 8 - 2843 pixels reassigned.
    spectral:INFO: k-means iteration 9 - 2411 pixels reassigned.
    k-means iteration 9 - 2411 pixels reassigned.
    spectral:INFO: k-means iteration 10 - 2089 pixels reassigned.
    k-means iteration 10 - 2089 pixels reassigned.
    spectral:INFO: k-means iteration 11 - 1742 pixels reassigned.
    k-means iteration 11 - 1742 pixels reassigned.
    spectral:INFO: k-means iteration 12 - 1482 pixels reassigned.
    k-means iteration 12 - 1482 pixels reassigned.
    spectral:INFO: k-means iteration 13 - 1257 pixels reassigned.
    k-means iteration 13 - 1257 pixels reassigned.
    spectral:INFO: k-means iteration 14 - 1109 pixels reassigned.
    k-means iteration 14 - 1109 pixels reassigned.
    spectral:INFO: k-means iteration 15 - 960 pixels reassigned.
    k-means iteration 15 - 960 pixels reassigned.
    spectral:INFO: k-means iteration 16 - 781 pixels reassigned.
    k-means iteration 16 - 781 pixels reassigned.
    spectral:INFO: k-means iteration 17 - 615 pixels reassigned.
    k-means iteration 17 - 615 pixels reassigned.
    spectral:INFO: k-means iteration 18 - 557 pixels reassigned.
    k-means iteration 18 - 557 pixels reassigned.
    spectral:INFO: k-means iteration 19 - 476 pixels reassigned.
    k-means iteration 19 - 476 pixels reassigned.
    spectral:INFO: k-means iteration 20 - 398 pixels reassigned.
    k-means iteration 20 - 398 pixels reassigned.
    spectral:INFO: k-means iteration 21 - 345 pixels reassigned.
    k-means iteration 21 - 345 pixels reassigned.
    spectral:INFO: k-means iteration 22 - 318 pixels reassigned.
    k-means iteration 22 - 318 pixels reassigned.
    spectral:INFO: k-means iteration 23 - 253 pixels reassigned.
    k-means iteration 23 - 253 pixels reassigned.
    spectral:INFO: k-means iteration 24 - 208 pixels reassigned.
    k-means iteration 24 - 208 pixels reassigned.
    spectral:INFO: k-means iteration 25 - 174 pixels reassigned.
    k-means iteration 25 - 174 pixels reassigned.
    spectral:INFO: k-means iteration 26 - 178 pixels reassigned.
    k-means iteration 26 - 178 pixels reassigned.
    spectral:INFO: k-means iteration 27 - 149 pixels reassigned.
    k-means iteration 27 - 149 pixels reassigned.
    spectral:INFO: k-means iteration 28 - 140 pixels reassigned.
    k-means iteration 28 - 140 pixels reassigned.
    spectral:INFO: k-means iteration 29 - 118 pixels reassigned.
    k-means iteration 29 - 118 pixels reassigned.
    spectral:INFO: k-means iteration 30 - 96 pixels reassigned.
    k-means iteration 30 - 96 pixels reassigned.
    spectral:INFO: k-means iteration 31 - 103 pixels reassigned.
    k-means iteration 31 - 103 pixels reassigned.
    spectral:INFO: k-means iteration 32 - 88 pixels reassigned.
    k-means iteration 32 - 88 pixels reassigned.
    spectral:INFO: k-means iteration 33 - 73 pixels reassigned.
    k-means iteration 33 - 73 pixels reassigned.
    spectral:INFO: k-means iteration 34 - 59 pixels reassigned.
    k-means iteration 34 - 59 pixels reassigned.
    spectral:INFO: k-means iteration 35 - 61 pixels reassigned.
    k-means iteration 35 - 61 pixels reassigned.
    spectral:INFO: k-means iteration 36 - 42 pixels reassigned.
    k-means iteration 36 - 42 pixels reassigned.
    spectral:INFO: k-means iteration 37 - 32 pixels reassigned.
    k-means iteration 37 - 32 pixels reassigned.
    spectral:INFO: k-means iteration 38 - 37 pixels reassigned.
    k-means iteration 38 - 37 pixels reassigned.
    spectral:INFO: k-means iteration 39 - 36 pixels reassigned.
    k-means iteration 39 - 36 pixels reassigned.
    spectral:INFO: k-means iteration 40 - 36 pixels reassigned.
    k-means iteration 40 - 36 pixels reassigned.
    spectral:INFO: k-means iteration 41 - 28 pixels reassigned.
    k-means iteration 41 - 28 pixels reassigned.
    spectral:INFO: k-means iteration 42 - 24 pixels reassigned.
    k-means iteration 42 - 24 pixels reassigned.
    spectral:INFO: k-means iteration 43 - 27 pixels reassigned.
    k-means iteration 43 - 27 pixels reassigned.
    spectral:INFO: k-means iteration 44 - 25 pixels reassigned.
    k-means iteration 44 - 25 pixels reassigned.
    spectral:INFO: k-means iteration 45 - 21 pixels reassigned.
    k-means iteration 45 - 21 pixels reassigned.
    spectral:INFO: k-means iteration 46 - 14 pixels reassigned.
    k-means iteration 46 - 14 pixels reassigned.
    spectral:INFO: k-means iteration 47 - 12 pixels reassigned.
    k-means iteration 47 - 12 pixels reassigned.
    spectral:INFO: k-means iteration 48 - 16 pixels reassigned.
    k-means iteration 48 - 16 pixels reassigned.
    spectral:INFO: k-means iteration 49 - 11 pixels reassigned.
    k-means iteration 49 - 11 pixels reassigned.
    spectral:INFO: k-means iteration 50 - 13 pixels reassigned.
    k-means iteration 50 - 13 pixels reassigned.
    spectral:INFO: kmeans terminated with 5 clusters after 50 iterations.
    kmeans terminated with 5 clusters after 50 iterations.
    

    --- It took 3.6 minutes to run kmeans on the reflectance data ---
    

Passing the initial clusters in sped up the convergence considerably, the second time around.

Let's take a look at the new cluster centers `c`. In this case, these represent spectral signatures of the five clusters (classes) that the data were grouped into. First we can take a look at the shape:


```python
print(c.shape)
```

    (5, 173)
    

`c` contains 5 groups of spectral curves with 173 bands (the # of bands we've kept after subsetting and removing the water vapor windows, first 10 noisy bands and last 15 noisy bands). We can plot these spectral classes as follows:


```python
import pylab
pylab.figure()
for i in range(c.shape[0]):
    pylab.plot(wavelengths_clean, c[i],'.')
pylab.show
pylab.title('Spectral Classes from K-Means Clustering')
pylab.xlabel('Wavelength (nm)')
pylab.ylabel('Reflectance');
```


    
![png](output_29_0.png)
    


Next, we can look at the classes in map view, as well as a true color image.


```python
view = imshow(refl_clean, bands=(58,34,19),stretch=0.01, classes=m, extent=refl_metadata['extent'])
view.set_display_mode('overlay')
view.class_alpha = 1 #set transparency
view.show_data;
```


    
![png](output_31_0.png)
    



```python
view = imshow(refl_clean, bands=(24,12,4), stretch=0.03, extent=refl_metadata['extent'])
view.show_data;
```


    
![png](output_32_0.png)
    


When dealing with NEON hyperspectral data, we first want to remove the water vapor & noisy bands, keeping only the valid bands. To speed up the classification algorithms for demonstration purposes, we'll look at a subset of the data using `read_subimage`, a built in method to subset by area and bands. Type `help(img.read_subimage)` to see how it works. 

## Challenges: K-Means

1. What do you think the spectral classes in the figure you just created represent? 
2. Try using a different number of clusters in the `kmeans` algorithm (e.g., 3 or 10) to see what spectral classes and classifications result. 

## Principal Component Analysis (PCA)

Many of the bands within hyperspectral images are often strongly correlated. The principal components transformation represents a linear transformation of the original image bands to a set of new, uncorrelated features. These new features correspond to the eigenvectors of the image covariance matrix, where the associated eigenvalue represents the variance in the direction of the eigenvector. A very large percentage of the image variance can be captured in a relatively small number of principal components (compared to the original number of bands) .


```python
pc = principal_components(refl_clean)
pc_view = imshow(pc.cov)
xdata = pc.transform(refl_clean)
```


    
![png](output_36_0.png)
    


In the covariance matrix display, lighter values indicate strong positive covariance, darker values indicate strong negative covariance, and grey values indicate covariance near zero.


```python
pcdata = pc.reduce(num=3).transform(refl_clean)
```


```python
pc_99 = pc.reduce(fraction=0.99)

# How many eigenvalues are left?
print('# of eigenvalues:',len(pc_99.eigenvalues))

img_pc = pc_99.transform(refl_clean)
print(img_pc.shape)

v = imshow(img_pc[:,:,:3], stretch_all=True, extent=refl_metadata['extent']);
```

    # of eigenvalues: 3
    (1000, 1000, 3)
    


    
![png](output_39_1.png)
    

