# -*- coding: utf-8 -*-
"""
Created on Wed Jun 20 10:34:49 2018

@author: bhass

neon_aop_hyperspectral contains the following functions for use in the 2018
Remote Sensing Data Institute 

list_dataset (called with h5py.File.visititems):
    lists the name and location of each dataset stored in an hdf5 file 

ls_dataset (called with h5py.File.visititems):
    lists name, shape, and type of each dataset stored in an hdf5 file

aop_h5refl2array:
    reads in NEON AOP reflectance hdf5 file, convert to a cleaned reflectance 
    array and return associated metadata (spatial information and band center 
    wavelengths)

plot_aop_refl:
    reads in and plot a single band or 3 stacked bands of a reflectance array
    
stack_rgb:
    extracts and stacks three bands of a reflectance array
    
plot_aop_rgb:
    reads in and plots 3 bands of a reflectance array as an RGB image
    
"""

import matplotlib.pyplot as plt
import numpy as np
import h5py
from skimage import exposure

def list_dataset(name,node):
    
    """list_dataset lists the name and location of each dataset stored in an hdf5 file.
    --------
    See Also:
    --------
    ls_dataset: 
        Lists name, shape, and type of each dataset stored in an hdf5 file.
    --------
    Usage:
    --------
    f = h5py.File('NEON_D02_SERC_DP3_368000_4306000_reflectance.h5','r') 
    f.visititems(list_dataset)"""
    
    if isinstance(node, h5py.Dataset):
        print(name)

def ls_dataset(name,node):
    
    """ls_dataset lists the name, shape, and datatype of each dataset stored in 
    an hdf5 file.
    --------
    See Also
    --------
    list_dataset: 
        Lists name and location of each dataset stored in an hdf5 file
    Example:
    --------
    f = h5py.File('NEON_D02_SERC_DP3_368000_4306000_reflectance.h5','r') 
    f.visititems(ls_dataset)"""
    
    if isinstance(node, h5py.Dataset):
        print(node)

def aop_h5refl2array(refl_filename):
    """read in NEON AOP reflectance hdf5 file, convert to a cleaned reflectance 
    array and return associated metadata (spatial information and band center 
    wavelengths)
           
    Parameters
    ----------
        refl_filename : string
            reflectance hdf5 file name, including full or relative path

    Returns 
    --------
    reflArray : ndarray
        array of reflectance values
    metadata: dictionary 
        associated metadata containing
            bad_band_window1 (tuple)
            bad_band_window2 (tuple)
            bands: # of bands (float)
            data ignore value: value corresponding to no data (float)
            epsg: coordinate system code (float)
            map info: coordinate system, datum & ellipsoid, pixel dimensions, and origin coordinates (string)
            reflectance scale factor: factor by which reflectance is scaled (float)
            wavelength: center wavelengths of bands (float)
            wavelength unit: 'm' (string)
    --------
    NOTE: This function applies to the NEON hdf5 format implemented in 2016, and should be used for
    data acquired 2016 and after. Data in earlier NEON hdf5 format (collected prior to 2016) is 
    expected to be re-processed after the 2018 flight season. 
    --------
    Example Execution:
    --------
    sercRefl, sercRefl_metadata = h5refl2array('NEON_D02_SERC_DP3_368000_4306000_reflectance.h5') """
    
    
    #Read in reflectance hdf5 file 
    hdf5_file = h5py.File(refl_filename,'r')
    
    #Get the site name
    file_attrs_string = str(list(hdf5_file.items()))
    file_attrs_string_split = file_attrs_string.split("'")
    sitename = file_attrs_string_split[1]
    
    #Extract the reflectance & wavelength datasets
    refl = hdf5_file[sitename]['Reflectance']
    
    
    reflData = refl['Reflectance_Data']
    reflRaw = refl['Reflectance_Data'].value
    
    #Create dictionary containing relevant metadata information
    metadata = {}
    metadata['map info'] = refl['Metadata']['Coordinate_System']['Map_Info'].value
    metadata['wavelength'] = refl['Metadata']['Spectral_Data']['Wavelength'].value

    #Extract no data value & scale factor
    metadata['data ignore value'] = float(reflData.attrs['Data_Ignore_Value'])
    metadata['reflectance scale factor'] = float(reflData.attrs['Scale_Factor'])
    #metadata['interleave'] = reflData.attrs['Interleave']
    
    #Apply no data value
    reflClean = reflRaw.astype(float)
    arr_size = reflClean.shape
    if metadata['data ignore value'] in reflRaw:
        print('% No Data: ',np.round(np.count_nonzero(reflClean==metadata['data ignore value'])*100/(arr_size[0]*arr_size[1]*arr_size[2]),1))
        nodata_ind = np.where(reflClean==metadata['data ignore value'])
        reflClean[nodata_ind]=np.nan 
    
    #Apply scale factor
    reflArray = reflClean/metadata['reflectance scale factor']
    
    #Extract spatial extent from attributes
    metadata['spatial extent'] = reflData.attrs['Spatial_Extent_meters']
    
    #Extract bad band windows
    metadata['bad band window1'] = (refl.attrs['Band_Window_1_Nanometers'])
    metadata['bad band window2'] = (refl.attrs['Band_Window_2_Nanometers'])
    
    #Extract projection information
    #metadata['projection'] = refl['Metadata']['Coordinate_System']['Proj4'].value
    metadata['epsg'] = int(refl['Metadata']['Coordinate_System']['EPSG Code'].value)
    
    #Extract map information: spatial extent & resolution (pixel size)
    metadata['map info'] = refl['Metadata']['Coordinate_System']['Map_Info'].value
    
    hdf5_file.close        
    
    return reflArray, metadata

def plot_aop_refl(band_array,refl_extent,colorlimit=(0,1),ax=plt.gca(),title='',cbar ='on',cmap_title='',colormap='Greys'):
    
    ''' read in and plot a single band or 3 stacked bands of a reflectance array
    --------
    Parameters
    --------
        band_array: ndarray
            Array of reflectance values, created from aop_h5refl2array
            If 'band_array' is a 2-D array, plots intensity of values
            If 'band_array' is a 3-D array (3 bands), plots RGB image, set cbar to 'off' and don't need to specify colormap 
        refl_extent: tuple
            Extent of reflectance data to be plotted (xMin, xMax, yMin, yMax) 
            Stored in metadata['spatial extent'] from aop_h5refl2array function
        colorlimit: tuple, optional
            Range of values to plot (min,max). 
            Look at the histogram of reflectance values before plotting to determine colorlimit.
        ax: axis handle, optional
            Axis to plot on; specify if making figure with subplots. Default is current axis, plt.gca()
        title: string, optional
            plot title 
        cbar: string, optional
            Use cbar = 'on' (default), shows colorbar; use if plotting 1-band array
            If cbar = 'off' (or not 'on'), does no
        cmap_title: string, optional
            colorbar title (eg. 'reflectance', etc.)
        colormap: string, optional
            Matplotlib colormap to plot 
            see https://matplotlib.org/examples/color/colormaps_reference.html

    Returns 
    --------
        plots flightline array of single band of reflectance data
    --------

    Examples:
    --------
    >>> plot_aop_refl(sercb56,
              sercMetadata['spatial extent'],
              colorlimit=(0,0.3),
              title='SERC Band 56 Reflectance',
              cmap_title='Reflectance',
              colormap='Greys_r') '''
    
    plot = plt.imshow(band_array,extent=refl_extent,clim=colorlimit); 
    if cbar == 'on':
        cbar = plt.colorbar(plot,aspect=40); plt.set_cmap(colormap); 
        cbar.set_label(cmap_title,rotation=90,labelpad=20)
    plt.title(title); ax = plt.gca(); 
    ax.ticklabel_format(useOffset=False, style='plain'); #do not use scientific notation for ticklabels
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90); #rotate x tick labels 90 degrees
    
def stack_rgb(reflArray,bands):
    
    ''' extract and stack three bands of a reflectance array 
    --------
    Parameters
    --------
        reflArray: ndarray (m x n x #bands)
            Array of reflectance values, created from aop_h5refl2array
        bands: tuple
            Indices of bands to extract (R,G,B)

    Returns 
    --------
        stackedRGB: ndarray (m x n x 3)
            array containing 3 bands specified 
    --------

    Examples:
    --------
    >>> stack_rgb(sercRefl,(58,34,19)) '''
    
    red = reflArray[:,:,bands[0]-1]
    green = reflArray[:,:,bands[1]-1]
    blue = reflArray[:,:,bands[2]-1]
    
    stackedRGB = np.stack((red,green,blue),axis=2)
    
    return stackedRGB

def plot_aop_rgb(rgbArray,ext,ls_pct=5,plot_title=''):
    
    ''' read in and plot 3 bands of a reflectance array as an RGB image
    --------
    Parameters
    --------
        rgbArray: ndarray (m x n x 3)
            3-band array of reflectance values, created from stack_rgb
        ext: tuple
            Extent of reflectance data to be plotted (xMin, xMax, yMin, yMax) 
            Stored in metadata['spatial extent'] from aop_h5refl2array function
        ls_pct: integer or float, optional
            linear stretch percent
        plot_title: string, optional
            image title

    Returns 
    --------
        plots RGB image of 3 bands of reflectance data
    --------

    Examples:
    --------
    >>> plot_aop_rgb(SERCrgb,
                     sercMetadata['spatial extent'],
                     plot_title = 'SERC RGB')'''
    
    pLow, pHigh = np.percentile(rgbArray[~np.isnan(rgbArray)], (ls_pct,100-ls_pct))
    img_rescale = exposure.rescale_intensity(rgbArray, in_range=(pLow,pHigh))
    plt.imshow(img_rescale,extent=ext)
    plt.title(plot_title + '\n Linear ' + str(ls_pct) + '% Contrast Stretch'); 
    ax = plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') 
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) 