
## Unsupervised Spectral Classification - Endmember Extraction

This notebook runs through an example of spectral unmixing to carry out unsupervised classification of a SERC hyperspectral data file using the **`PySpTools`** package to carry out **endmember extraction**, plot **abundance maps** of the spectral endmembers, and use **Spectral Angle Mapping** and **Spectral Information Divergence** to classify the SERC tile. 

Since spectral data is so large in size, it is often useful to remove any unncessary or redundant data in order to save computational time. In this example, we will remove the water vapor bands, but you can also take a subset of bands, depending on your research application. 

In this tutorial, we use the following user-defined functions: 
- **`read_neon_reflh5`**: function to read in NEON AOP Hyperspectral Data file (in hdf5 format)
- **`clean_neon_refl_data`**: function to clean NEON hyperspectral data, including applying the data ignore value and reflectance scale factor, and removing water vapor bands
- **`plot_aop_refl`**: function to plot a band of NEON hyperspectral data for reference

https://pysptools.sourceforge.io/index.html

## Dependencies & Installation:

To run this notebook, you the following python packages need to be installed. You can install from the notebook following the commands below, or you can install required packages from command line after activating the p35 environment.

PySpTools: Download pysptools-0.14.2.tar.gz from https://pypi.python.org/pypi/pysptools

```python 
import sys
!{sys.executable} -m pip install "C:\Users\bhass\Downloads\pysptools-0.14.2.tar.gz
!conda install --yes --prefix {sys.prefix} scikit-learn
!conda install --yes --prefix {sys.prefix} cvxopt 
```

See Also:
https://stackoverflow.com/questions/45156080/installing-modules-to-anaconda-from-tar-gz


```python
import h5py, os, copy
import matplotlib.pyplot as plt
import numpy as np
import pysptools.util as util
import pysptools.eea as eea #endmembers extraction algorithms
import pysptools.abundance_maps as amap
import pysptools.classification as cls
import pysptools.material_count as cnt

from skimage import exposure

%matplotlib inline
import warnings
warnings.filterwarnings('ignore')
```


```python
def read_neon_reflh5(refl_filename):
    """read in a NEON AOP reflectance hdf5 file and returns 
    reflectance array, and header containing metadata in envi format.
    --------
    Parameters
        refl_filename -- full or relative path and name of reflectance hdf5 file
    --------
    Returns 
    --------
    reflArray:
        array of reflectance values
    header:
        dictionary containing the following metadata (all strings):
            bad_band_window1: min and max wavelenths of first water vapor window (tuple)
            bad_band_window2: min and max wavelenths of second water vapor window (tuple)
            bands: # of bands (float)
            coordinate system string: coordinate system information (string)
            data ignore value: value corresponding to no data (float)
            interleave: 'BSQ' (string)
            reflectance scale factor: factor by which reflectance is scaled (float)
            wavelength: wavelength values (float)
            wavelength unit: 'm' (string)
            spatial extent: extent of tile [xMin, xMax, yMin, yMax], UTM meters
    --------
    Example Execution:
    --------
    sercRefl, sercRefl_header = h5refl2array('NEON_D02_SERC_DP1_20160807_160559_reflectance.h5') """
    
    #Read in reflectance hdf5 file (include full or relative path if data is located in a different directory)
    hdf5_file = h5py.File(refl_filename,'r')

    #Get the site name
    file_attrs_string = str(list(hdf5_file.items()))
    file_attrs_string_split = file_attrs_string.split("'")
    sitename = file_attrs_string_split[1]
    
    #Extract the reflectance & wavelength datasets
    refl = hdf5_file[sitename]['Reflectance']
    reflData = refl['Reflectance_Data']
    reflArray = refl['Reflectance_Data'].value
    
    #Create dictionary containing relevant metadata information
    header = {}
    header['map info'] = refl['Metadata']['Coordinate_System']['Map_Info'].value
    header['wavelength'] = refl['Metadata']['Spectral_Data']['Wavelength'].value

    #Extract no data value & set no data value to NaN
    header['data ignore value'] = float(reflData.attrs['Data_Ignore_Value'])
    header['reflectance scale factor'] = float(reflData.attrs['Scale_Factor'])
    header['interleave'] = reflData.attrs['Interleave']
    
    #Extract spatial extent from attributes
    header['spatial extent'] = reflData.attrs['Spatial_Extent_meters']
    
    #Extract bad band windows
    header['bad_band_window1'] = (refl.attrs['Band_Window_1_Nanometers'])
    header['bad_band_window2'] = (refl.attrs['Band_Window_2_Nanometers'])
    
    #Extract projection information
    header['projection'] = refl['Metadata']['Coordinate_System']['Proj4'].value
    header['epsg'] = int(refl['Metadata']['Coordinate_System']['EPSG Code'].value)
    
    #Extract map information: spatial extent & resolution (pixel size)
    mapInfo = refl['Metadata']['Coordinate_System']['Map_Info'].value
    
    hdf5_file.close        
    
    return reflArray, header
```


```python
data_path = os.getcwd()
h5refl_filename = 'NEON_D02_SERC_DP3_368000_4306000_reflectance.h5'
data,header = read_neon_reflh5(h5refl_filename)
```


```python
#Display information stored in header
for key in sorted(header.keys()):
  print(key)
```

    bad_band_window1
    bad_band_window2
    data ignore value
    epsg
    interleave
    map info
    projection
    reflectance scale factor
    spatial extent
    wavelength
    


```python
def clean_neon_refl_data(data,header):
    """Clean h5 reflectance data and header
    1. set data ignore value (-9999) to NaN
    2. apply reflectance scale factor (10000)
    3. remove bad bands (water vapor band windows + last 10 bands): 
        Band_Window_1_Nanometers = 1340,1445
        Band_Window_2_Nanometers = 1790,1955
    """
    
    data_clean = data.copy()
    header_clean = header.copy()
    #set data ignore value (-9999) to NaN:
    data_clean[data_clean==header['data ignore value']]=np.nan #??? get message ValueError: cannot convert float NaN to integer
    #if header['data ignore value'] in data:
    #    print('data ignore values exist in data')
    
    #apply reflectance scale factor (divide by 10000)
    data_clean = data_clean/header['reflectance scale factor']
    
    #remove bad bands 
    #1. define indices corresponding to min/max center wavelength for each bad band window:
    bb1_ind0 = np.max(np.where((np.asarray(header['wavelength'])<float(header['bad_band_window1'][0]))))
    bb1_ind1 = np.min(np.where((np.asarray(header['wavelength'])>float(header['bad_band_window1'][1]))))

    bb2_ind0 = np.max(np.where((np.asarray(header['wavelength'])<float(header['bad_band_window2'][0]))))
    bb2_ind1 = np.min(np.where((np.asarray(header['wavelength'])>float(header['bad_band_window2'][1]))))

    bb3_ind0 = len(header['wavelength'])-10
    
    #define valid band ranges from indices:
    vb1 = list(range(0,bb1_ind0)); #TO DO - don't hard code bands in, fi
    vb2 = list(range(bb1_ind1,bb2_ind0))
    vb3 = list(range(bb2_ind1,bb3_ind0))
    
    valid_band_range = [i for j in (range(0,bb1_ind0),
                                    range(bb1_ind1,bb2_ind0),
                                    range(bb2_ind1,bb3_ind0)) for i in j]
    
    data_clean = data_clean[:,:,vb1+vb2+vb3]
    
    header_clean['wavelength'] = [header['wavelength'][i] for i in valid_band_range]
    
    return data_clean, header_clean
```


```python
print('Raw Data Dimensions:',data.shape)
data_clean,header_clean = clean_neon_refl_data(data,header)
print('Cleaned Data Dimensions:',data_clean.shape)
```

    Raw Data Dimensions:
     (1000, 1000, 426)
    Cleaned Data Dimensions: (1000, 1000, 360)
    


```python
def plot_aop_refl(band_array,refl_extent,colorlimit=(0,1),ax=plt.gca(),title='',cbar ='on',cmap_title='',colormap='Greys'):  
    plot = plt.imshow(band_array,extent=refl_extent,clim=colorlimit); 
    if cbar == 'on':
        cbar = plt.colorbar(plot,aspect=40); plt.set_cmap(colormap); 
        cbar.set_label(cmap_title,rotation=90,labelpad=20)
    plt.title(title); ax = plt.gca(); 
    ax.ticklabel_format(useOffset=False, style='plain'); 
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90); 
```


![png](output_8_0.png)



```python
plot_aop_refl(data_clean[:,:,0],header_clean['spatial extent'],(0,0.3))
```


![png](output_9_0.png)


## Unsupervised Classification with Spectral Unmixing: 
### Endmember Extraction and Abundance Mapping

**Spectral Unmixing** allows pixels to be composed of fractions or abundances of each class.**Spectral Endmembers** can be thought of as the basis spectra of an image. Once these endmember spectra are determined, the image cube can be 'unmixed' into the fractional abundance of each material in each pixel (Winter, 1999).

**Spectral Angle Mapper (SAM):** is a physically-based spectral classification that uses an n-D angle to match pixels to reference spectra. The algorithm determines the spectral similarity between two spectra by calculating the angle between the spectra and treating them as vectors in a space with dimensionality equal to the number of bands. This technique, when used on calibrated reflectance data, is relatively insensitive to illumination and albedo effects. Endmember spectra used by SAM in this example are extracted from the NFINDR algorithm. SAM compares the angle between the endmember spectrum vector and each pixel vector in n-D space. Smaller angles represent closer matches to the reference spectrum. Pixels further away than the specified maximum angle threshold in radians are not classified.

http://www.harrisgeospatial.com/docs/SpectralAngleMapper.html

**Spectral Information Divergence (SID):** is a spectral classification method that uses a divergence measure to match pixels to reference spectra. The smaller the divergence, the more likely the pixels are similar. Pixels with a measurement greater than the specified maximum divergence threshold are not classified. Endmember spectra used by SID in this example are extracted from the NFINDR endmembor extraction algorithm.

http://www.harrisgeospatial.com/docs/SpectralInformationDivergence.html


```python
#Endmember Extraction (Unmixing) - NFINDR Algorithm (Winter, 1999)
wavelength_float = [float(i) for i in header_clean['wavelength']]
ee_axes = {}
ee_axes['wavelength'] = wavelength_float
ee_axes['x']='Wavelength, nm'
ee_axes['y']='Reflectance'
```


```python
ee = eea.NFINDR()
U = ee.extract(data_clean,4,maxit=5,normalize=False,ATGP_init=True)
ee.display(axes=ee_axes,suffix='SERC')
```


![png](output_12_0.png)



```python
#Abundance Maps
am = amap.FCLS()
amaps = am.map(data_clean,U,normalize=False)
am.display(colorMap='jet',columns=4,suffix='SERC')
```


![png](output_13_0.png)



![png](output_13_1.png)



![png](output_13_2.png)



![png](output_13_3.png)



    <matplotlib.figure.Figure at 0x1efe8b6b0f0>


Print mean values of each abundance map to better estimate thresholds to use in the classification routines. 


```python
print('Abundance Map Mean Values:')
print('EM1:',np.mean(amaps[:,:,0]))
print('EM2:',np.mean(amaps[:,:,1]))
print('EM3:',np.mean(amaps[:,:,2]))
print('EM4:',np.mean(amaps[:,:,3]))
```

    Abundance Map Mean Values:
    EM1: 0.591774
    EM2: 0.00089542
    EM3: 0.380964
    EM4: 0.0263671
    

You can also look at histogram of each abundance map:


```python
import matplotlib.pyplot as plt
fig = plt.figure(figsize=(18,8))

ax1 = fig.add_subplot(2,4,1); plt.title('EM1')
amap1_hist = plt.hist(np.ndarray.flatten(amaps[:,:,0]),bins=50,range=[0,1.0]) 

ax2 = fig.add_subplot(2,4,2); plt.title('EM2')
amap1_hist = plt.hist(np.ndarray.flatten(amaps[:,:,1]),bins=50,range=[0,0.001]) 

ax3 = fig.add_subplot(2,4,3); plt.title('EM3')
amap1_hist = plt.hist(np.ndarray.flatten(amaps[:,:,2]),bins=50,range=[0,0.5]) 

ax4 = fig.add_subplot(2,4,4); plt.title('EM4')
amap1_hist = plt.hist(np.ndarray.flatten(amaps[:,:,3]),bins=50,range=[0,0.05]) 
```


![png](output_17_0.png)


Below we define a function to compute and display SID:


```python
def SID(data,E,thrs=None):
    sid = cls.SID()
    cmap = sid.classify(data,E,threshold=thrs)
    sid.display(colorMap='tab20b',suffix='SERC')
```

Now we can call this function using the three endmembers (classes) that contain the most information: 


```python
U2 = U[[0,2,3],:]
SID(data_clean, U2, [0.8,0.3,0.03])
```


![png](output_21_0.png)


From this map we can see that SID did a pretty good job of identifying the water (dark blue), roads/buildings (orange), and vegetation (blue). We can compare it to the USA Topo Base map (https://viewer.nationalmap.gov/):


```python
from IPython.core.display import Image
UStopo_filename = 'SERC_368000_4307000_UStopo.PNG'
UStopo_image = os.path.join(data_path,UStopo_filename)
print('SERC Tile US Topo Base Map')
Image(filename=UStopo_image,width=225,height=225)
```

    SERC Tile US Topo Base Map
    




![png](output_23_1.png)



## Exercises

1. On your own, try the Spectral Angle Mapper. If you aren't sure where to start, refer to `PySpTools` `SAM` documentation, and the Pine Creek example 1. 

https://pysptools.sourceforge.io/classification.html#spectral-angle-mapper-sam
https://pysptools.sourceforge.io/examples_front.html#examples-using-the-ipython-notebook

**Hint**: use the SAM function below, and refer to the SID syntax used above. 

```python
def SAM(data,E,thrs=None):
    sam = cls.SAM()
    cmap = sam.classify(data,E,threshold=thrs)
    sam.display(colorMap='Paired')
```

2. Experiment with different settings with SID and SAM (eg. adjust the # of endmembers, thresholds, etc.) 

3. Determine which algorithm (SID, SAM) you think does a better job classifying the SERC data tile. Synthesize your results in a markdown cell. 

4. Take a subset of the bands before running endmember extraction. How different is the classification if you use only half the data points? How much faster does the algorithm run? When running analysis on large data sets, it is useful to 

**TIPS**: 
- To extract every 10th element from the array `A`, use `A[0::10]`
- Import the package `time` to track the amount of time it takes to run a script. 

```python
start_time = time.time()
# code
elapsed_time = time.time() - start_time
```

## What Next?

`PySpTools` has an alpha interface with the Python machine learning package `scikit-learn`. To apply more advanced machine learning techniques, you may wish to explore some of these algorithms.  

https://pysptools.sourceforge.io/skl.html
http://scikit-learn.org/stable/
