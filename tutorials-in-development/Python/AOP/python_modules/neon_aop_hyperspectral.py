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

import h5py
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from skimage import exposure

from typing import Literal, get_args

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

# define raster types for the 
_RASTER_TYPES = Literal["Cast_Shadow",
                        "Data_Selection_Index",
                        "GLT_Data",
                        "Haze_Cloud_Water_Map",
                        "IGM_Data",
                        "Illumination_Factor",
                        "OBS_Data",
                        "Radiance",
                        "Reflectance", 
                        "Sky_View_Factor",
                        "to-sensor_Azimuth_Angle",
                        "to-sensor_Zenith_Angle",
                        "Visibility_Index_Map",
                        "Weather_Quality_Indicator"]

# def func(a, b, c, type_: _TYPES = "solar"):
#     options = get_args(_TYPES)
#     assert type_ in options, f"'{type_}' is not in {options}"

def aop_h5refl2array(h5_filename, raster_type_: _RASTER_TYPES, only_metadata = False):
    """read in NEON AOP reflectance hdf5 file and return the un-scaled 
    reflectance array, associated metadata, and wavelengths
           
    Parameters
    ----------
        h5_filename : string
            reflectance hdf5 file name, including full or relative path
        raster : string
            name of raster value to read in; this will typically be the reflectance data, 
            but other data stored in the h5 file can be accessed as well
            valid options: 
                Cast_Shadow (ATCOR input)
                Data_Selection_Index
                GLT_Data
                Haze_Cloud_Water_Map (ATCOR output)
                IGM_Data
                Illumination_Factor (ATCOR input)
                OBS_Data 
                Reflectance
                Radiance
                Sky_View_Factor (ATCOR input)
                to-sensor_Azimuth_Angle
                to-sensor_Zenith_Angle
                Visibility_Index_Map: sea level values of visibility index / total optical thickeness
                Weather_Quality_Indicator: estimated percentage of overhead cloud cover during acquisition

    Returns 
    --------
    raster_array : ndarray
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
    wavelengths: array
            wavelength values, in nm
    --------
    Example Execution:
    --------
    refl, refl_metadata = aop_h5refl2array('NEON_D02_SERC_DP3_368000_4306000_reflectance.h5','Reflectance') """

    raster_options = get_args(_RASTER_TYPES)
    assert raster_type_ in raster_options, f"'{raster_type_}' is not a recognized raster. You must select one of the following rasters: {raster_options}."

    with h5py.File(h5_filename) as hdf5_file:
        print('Reading in ',h5_filename)
        # get the site name
        sitename = str(list(hdf5_file.items())).split("'")[1]
        productType = str(list(hdf5_file[sitename].items())).split("'")[1]
        
        # get the product type (reflectance, radiance, atcor inputs, ...)
        if productType == 'Reflectance':
            productBaseLoc = hdf5_file[sitename]['Reflectance']
        elif productType == 'Radiance':
            productBaseLoc = hdf5_file[sitename]['Radiance']
        
        if raster_type_ == 'Reflectance':
            raster_type_ = 'Reflectance_Data'
            productLoc = productBaseLoc
        elif raster_type_ == 'Radiance':
            productLoc = productBaseLoc
        elif raster_type_ == 'to-sensor_Azimuth_Angle' or raster_type_ == 'to-sensor_Zenith_Angle':
            productLoc = productBaseLoc['Metadata']
        elif raster_type_ == 'GLT_Data' or raster_type_ == 'IGM_Data' or raster_type_ == 'OBS_Data':
            productLoc = productBaseLoc['Metadata']['Ancillary_Rasters']
        else:
            productLoc = productBaseLoc['Metadata']['Ancillary_Imagery']
        
        if 'DP3' in h5_filename and raster_type_ == 'to-sensor_Azimuth_Angle':
            raster_type_ = 'to-sensor_azimuth_angle'
        
        if 'DP3' in h5_filename and raster_type_ == 'to-sensor_Zenith_Angle':
            raster_type_ = 'to-sensor_zenith_angle'

        if raster_type_ == 'Radiance':
            raster_array = productLoc['RadianceDecimalPart']
        else:
            raster_array = productLoc[raster_type_]
        
        rasterShape = raster_array.shape
        wavelengths = productBaseLoc['Metadata']['Spectral_Data']['Wavelength']

        # create dictionary containing metadata information
        metadata = {}
        metadata['shape'] = rasterShape
        
        if raster_type_ == 'Data_Selection_Index':
            metadata['no_data_value'] = -1
            metadata['scale_factor'] = 1
        elif raster_type_ == 'Weather_Quality_Indicator':
            metadata['no_data_value'] = 0
            metadata['scale_factor'] = 1
        elif raster_type_ == 'Cast_Shadow' or raster_type_ == 'Illumination_Factor' or raster_type_ == 'Sky_View_Factor' or raster_type_ == 'Visibility_Index_Map' or raster_type_ == 'Haze_Cloud_Water_Map':
            metadata['no_data_value'] = 241
        elif raster_type_ == 'Radiance':
            metadata['no_data_value'] = float(raster_array.attrs['Data_Ignore_Value'])
            metadata['scale_factor'] = float(raster_array.attrs['Scale'])
        elif raster_type_ == 'GLT_Data':
            metadata['no_data_value'] = 0.0
            metadata['scale_factor'] = 1.0
        elif raster_type_ == 'OBS_Data' or raster_type_ == 'IGM_Data':
            metadata['no_data_value'] = float(raster_array.attrs['Data_Ignore_Value'])
            metadata['scale_factor'] = 1.0
        else:
            metadata['no_data_value'] = float(raster_array.attrs['Data_Ignore_Value'])
            metadata['scale_factor'] = float(raster_array.attrs['Scale_Factor'])

        if raster_type_ == 'Reflectance_Data':  
            metadata['bad_band_window1'] = (productLoc.attrs['Band_Window_1_Nanometers'])
            metadata['bad_band_window2'] = (productLoc.attrs['Band_Window_2_Nanometers'])
        
        metadata['projection'] = productBaseLoc['Metadata']['Coordinate_System']['Proj4'][()]
        metadata['EPSG'] = int(productBaseLoc['Metadata']['Coordinate_System']['EPSG Code'][()])
        mapInfo = productBaseLoc['Metadata']['Coordinate_System']['Map_Info'][()]
        mapInfo_string = str(mapInfo) #print('Map Info:',mapInfo_string)\n",
        mapInfo_split = mapInfo_string.split(",")
        # extract the resolution & convert to floating decimal number
        metadata['res'] = {}
        metadata['res']['pixelWidth'] = float(mapInfo_split[5])
        metadata['res']['pixelHeight'] = float(mapInfo_split[6])
        # extract the upper left-hand corner coordinates from mapInfo and cast to float
        xMin = float(mapInfo_split[3]) 
        yMax = float(mapInfo_split[4])
        # calculate the xMax and yMin values from the dimensions
        xMax = xMin + (rasterShape[1]*float(metadata['res']['pixelWidth'])) #xMax = left edge + (# of columns * resolution)\n",
        yMin = yMax - (rasterShape[0]*float(metadata['res']['pixelHeight'])) #yMin = top edge - (# of rows * resolution)\n",
        metadata['extent'] = (xMin,xMax,yMin,yMax)
        metadata['ext_dict'] = {}
        metadata['ext_dict']['xMin'] = xMin
        metadata['ext_dict']['xMax'] = xMax
        metadata['ext_dict']['yMin'] = yMin
        metadata['ext_dict']['yMax'] = yMax
        
        if raster_type_ == 'Radiance':
            raster_array = productLoc['RadianceIntegerPart'][:] + productLoc['RadianceDecimalPart'][:]/metadata['scale_factor']
            raster_array[raster_array==productLoc['RadianceIntegerPart'].attrs['Data_Ignore_Value']+productLoc['RadianceDecimalPart'].attrs['Data_Ignore_Value']/metadata['scale_factor']]=-9999
            metadata['no_data_value'] = -9999

        raster_array = raster_array[:]
        wavelengths = wavelengths[:]

        if raster_type_ == 'Reflectance_Data':
            # create dictionary linking wavelength and band #
            wavelength_dict = dict(zip(range(0, len(wavelengths)), wavelengths))
            wavelength_df = pd.DataFrame.from_dict(wavelength_dict,orient='index',columns=['wavelength_nm'])
            
            # extract the bands corresponding to the min and max values for the two bad band windows
            bb1_min = wavelength_df['wavelength_nm'].sub(metadata['bad_band_window1'][0]).abs().idxmin()
            bb1_max = wavelength_df['wavelength_nm'].sub(metadata['bad_band_window1'][1]).abs().idxmin()
            bb2_min = wavelength_df['wavelength_nm'].sub(metadata['bad_band_window2'][0]).abs().idxmin()
            bb2_max = wavelength_df['wavelength_nm'].sub(metadata['bad_band_window2'][1]).abs().idxmin()
            
            # get bad bands
            bad_bands = list(range(bb1_min,bb1_max)) + list(range(bb2_min,bb2_max))
            
            raster_array[:,:,bad_bands] = -100

    metadata['source'] = h5_filename
    
    if only_metadata:
        return raster_array[:], metadata, wavelengths
    else:
        return raster_array, metadata, wavelengths

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
            Stored in metadata['extent'] from aop_h5refl2array function
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
    >>> plot_aop_refl(refl_b56,
              refl_metadata['extent'],
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
    
def stack_rgb(refl_array,bands):
    
    ''' extract and stack three bands of a reflectance array 
    --------
    Parameters
    --------
        refl_array: ndarray (m x n x #bands)
            Array of reflectance values, created from aop_h5refl2array
        bands: tuple
            Indices of bands to extract (R,G,B)

    Returns 
    --------
        stacked_rgb: ndarray (m x n x 3)
            array containing 3 bands specified 
    --------

    Examples:
    --------
    >>> stack_rgb(refl,(58,34,19)) '''
    
    red = refl_array[:,:,bands[0]-1]
    green = refl_array[:,:,bands[1]-1]
    blue = refl_array[:,:,bands[2]-1]
    
    stacked_rgb = np.stack((red,green,blue),axis=2)
    
    return stacked_rgb

def plot_aop_rgb(rgb_array,ext,ls_pct=5,plot_title=''):
    
    ''' read in and plot 3 bands of a reflectance array as an RGB image
    --------
    Parameters
    --------
        rgb_array: ndarray (m x n x 3)
            3-band array of reflectance values, created from stack_rgb
        ext: tuple
            Extent of reflectance data to be plotted (xMin, xMax, yMin, yMax) 
            Stored in metadata['extent'] from aop_h5refl2array function
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
    >>> plot_aop_rgb(rgb,
                     refl_metadata['extent'],
                     plot_title = 'SERC RGB')'''
    
    p_low, p_high = np.percentile(rgb_array[~np.isnan(rgb_array)], (ls_pct,100-ls_pct))
    img_rescale = exposure.rescale_intensity(rgb_array, in_range=(p_low,p_high))
    plt.imshow(img_rescale,extent=ext)
    plt.title(plot_title + '\n Linear ' + str(ls_pct) + '% Contrast Stretch'); 
    ax = plt.gca(); ax.ticklabel_format(useOffset=False, style='plain') 
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90) 