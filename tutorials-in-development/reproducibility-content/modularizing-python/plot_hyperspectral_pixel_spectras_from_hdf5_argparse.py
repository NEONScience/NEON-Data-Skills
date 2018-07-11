#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Written by Naupaka Zimmerman
# July 11, 2018
# nzimmerman@usfca.edu

# This script takes as input a hyperspectral imagery hdf5 file from the
# NEON AOP platform, assuming the post-2016 hdf5 format. It was developed as
# part of the 2018 Data Skills Institute at NEON in Boulder, CO. It extracts
# the appropriate metadata from the file and then plots the full spectra for
# a given pixel, which is meant to be passed in as a command-line argument.

# It produces three output figures, one with the entire spectra, and then
# two with the band bands (high noise) marked and then removed. It also will
# output a csv file with the wavelength and reflectance with the bad regions
# removed for the selected pixel.

# For usage parameters, use the -h or --help flag.

# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>

import h5py
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from copy import copy
import argparse

# Initialize parser and set up command-line arguments
parser = argparse.ArgumentParser()

parser.add_argument("-v", "--verbose",
                    help="increase output verbosity",
                    action="store_true")

parser.add_argument('-c', '--csvdir',
                    default="./",
                    help="csv file output dir")

parser.add_argument('-f', '--figdir',
                    default="./",
                    help="fig output dir")

parser.add_argument('h5input',
                    help="input h5 file")

parser.add_argument('ycoord',
                    type=int,
                    help="y coord of pixel to plot")

parser.add_argument('xcoord',
                    type=int,
                    help="x coord of pixel to plot")

args = parser.parse_args()

if args.verbose:
    print("Verbosity turned on.")

# capture filename
refl_filename = args.h5input

pixel_to_plot = (args.ycoord, args.xcoord)
if args.verbose: print("pixel_to_plot\n",', '.join(map(str, pixel_to_plot)))

# Read in reflectance hdf5 file
hdf5_file = h5py.File(refl_filename,'r')
if args.verbose: print("hdf5_file\n", hdf5_file)

# Get the file name
file_attrs_string = str(list(hdf5_file.items()))
if args.verbose: print("file_attrs_string\n", file_attrs_string)

file_attrs_string_split = file_attrs_string.split("'")
if args.verbose: print("file_attrs_string_split\n", file_attrs_string_split)

sitename = file_attrs_string_split[1]
if args.verbose: print("sitename\n", sitename)

# Extract the reflectance
refl = hdf5_file[sitename]['Reflectance']
if args.verbose: print("refl\n", refl)

if args.verbose: print("list reflectance attribs\n", list(refl.attrs))

# Get the reflectance data
reflData = refl['Reflectance_Data']
if args.verbose: print("reflData\n", reflData)

# Get the raw values for the reflectance data
reflRaw = refl['Reflectance_Data'].value
if args.verbose: print("reflRaw\n", reflRaw)

# Create dictionary containing relevant metadata information
# make empty dictionary
metadata = {}
if args.verbose: print("metadata\n", metadata)

if args.verbose: print("metadata type\n", type(metadata))

# store the map_info into a key of the same name
metadata['map_info'] = refl['Metadata']['Coordinate_System']['Map_Info'].value
if args.verbose: print("metadata\n", metadata)

# store the wavelength into a key of the same name
metadata['wavelength'] = refl['Metadata']['Spectral_Data']['Wavelength'].value
if args.verbose: print("metadata\n", metadata)

# Extract no data value and store into dict
metadata['data_ignore_value'] = float(reflData.attrs['Data_Ignore_Value'])
if args.verbose: print("metadata\n", metadata)

# Extract scale factor and store into dict
metadata['reflectance_scale_factor'] = float(reflData.attrs['Scale_Factor'])
if args.verbose: print("metadata\n", metadata)

# Apply no data value

# convert raw reflectance into type float (was integer, see above)
reflClean = reflRaw.astype(float)
if args.verbose: print("reflClean\n", reflClean)

# capture shape of this raw data
arr_size = reflClean.shape
if args.verbose: print("arr_size\n", arr_size)

number_of_values_where_no_data = np.count_nonzero(reflClean == metadata['data_ignore_value'])
if args.verbose: print("number_of_values_where_no_data\n", number_of_values_where_no_data)

total_number_of_values_in_array = (arr_size[0] * arr_size[1] * arr_size[2])
if args.verbose: print("total_number_of_values_in_array\n", total_number_of_values_in_array)

# check for the number of missing data points
# no result means all clean
if metadata['data_ignore_value'] in reflRaw:
    # print out the percent with no data rounded to 1 decimal place
    # not sure why multiply times 100?
    if args.verbose: print('% of Points with No Data: ',
          np.round(number_of_values_where_no_data * 100 / total_number_of_values_in_array, 1))

    # replace the ignore values with numpy NaNs
    nodata_ind = np.where(reflClean == metadata['data_ignore_value'])
    reflClean[nodata_ind] = np.nan

# Apply scale factor
reflArray = reflClean / metadata['reflectance_scale_factor']
if args.verbose: print("reflArray\n", reflArray)

# Extract spatial extent from attributes
metadata['spatial_extent'] = reflData.attrs['Spatial_Extent_meters']
if args.verbose: print("metadata spatial extent\n", metadata['spatial_extent'])

# Extract bad band windows
metadata['bad band window1'] = (refl.attrs['Band_Window_1_Nanometers'])
if args.verbose: print("metadata bad band window 1\n", metadata['bad band window1'])

metadata['bad band window2'] = (refl.attrs['Band_Window_2_Nanometers'])
if args.verbose: print("metadata bad band window 2\n", metadata['bad band window2'])

# Extract projection information
# metadata['projection'] = refl['Metadata']['Coordinate_System']['Proj4'].value
metadata['epsg'] = int(refl['Metadata']['Coordinate_System']['EPSG Code'].value)
if args.verbose: print("metadata epsg\n", metadata['epsg'])

# Extract map information: spatial extent & resolution (pixel size)
mapInfo = refl['Metadata']['Coordinate_System']['Map_Info'].value
if args.verbose: print("mapInfo\n", mapInfo)

hdf5_file.close

# Make a new empty pandas data frame
serc_pixel_df = pd.DataFrame()

# add a column of reflectance data from the cleaned reflectance array
serc_pixel_df['reflectance'] = reflArray[pixel_to_plot[0], pixel_to_plot[1], :]

# add a second column to the data frame with the wavelength info
serc_pixel_df['wavelengths'] = metadata['wavelength']

# check for any weirdness
if args.verbose: print(serc_pixel_df.head(5))

# check for any weirdness
if args.verbose: print(serc_pixel_df.tail(5))

# make a plot!
serc_pixel_df.plot(x='wavelengths',
                   y='reflectance',
                   kind='scatter',
                   edgecolor='none')

plt.title('Spectral Signature for '+sitename+' Pixel '+', '.join(map(str, pixel_to_plot)))

ax = plt.gca() # gca is short for get current axes

ax.set_xlim([np.min(serc_pixel_df['wavelengths']),
             np.max(serc_pixel_df['wavelengths'])])

ax.set_ylim([np.min(serc_pixel_df['reflectance']),
             np.max(serc_pixel_df['reflectance'])])

ax.set_xlabel("Wavelength, nm")
ax.set_ylabel("Reflectance")

ax.grid(True)

fig = ax.get_figure()
fig.savefig(args.figdir+'/'+sitename+'_'+'_'.join(map(str, pixel_to_plot))+'_plot_1_all.png')


bbw1 = metadata['bad band window1']
if args.verbose: print('Bad Band Window 1:', bbw1)

bbw2 = metadata['bad band window2']
if args.verbose: print('Bad Band Window 2:', bbw2)

# make a plot with the bad regions plotted
serc_pixel_df.plot(x='wavelengths',
                   y='reflectance',
                   kind='scatter',
                   edgecolor='none')

plt.title('Spectral Signature for '+sitename+' Pixel '+', '.join(map(str, pixel_to_plot)))

ax1 = plt.gca()
ax1.grid(True)

ax1.set_xlim([np.min(serc_pixel_df['wavelengths']),
              np.max(serc_pixel_df['wavelengths'])])

ax1.set_ylim(0, 0.5)

ax1.set_xlabel("Wavelength, nm")
ax1.set_ylabel("Reflectance")

# Add in red dotted lines to show boundaries of bad band windows:
ax1.plot((bbw1[0], bbw1[0]), (0, 1.5), 'r--')
ax1.plot((bbw1[1], bbw1[1]), (0, 1.5), 'r--')
ax1.plot((bbw2[0], bbw2[0]), (0, 1.5), 'r--')
ax1.plot((bbw2[1], bbw2[1]), (0, 1.5), 'r--')

fig = ax1.get_figure()
fig.savefig(args.figdir+'/'+sitename+'_'+'_'.join(map(str, pixel_to_plot))+'_plot_2_bad_bands_marked.png')

# make a copy to deal with the mutable data type
w = copy(metadata['wavelength'])

# can also use bbw1[0] or bbw1[1] to avoid hard-coding in
w[((w >= bbw1[0]) & (w <= bbw1[1])) | ((w >= bbw2[0]) & (w <= bbw2[1]))] = np.nan

# the last 10 bands sometimes have noise - best to eliminate
w[-10:] = np.nan

# optionally print wavelength values to show that -9999 values are replaced with nan
if args.verbose: print("check for NaN replacement\n", w)

serc_pixel_df['wavelengths'] = w

if args.verbose: print("serc_pixel_df\n", serc_pixel_df)

serc_pixel_df.to_csv(args.csvdir+'/'+sitename+'_'+'_'.join(map(str, pixel_to_plot))+'_cleaned.csv')


serc_pixel_df.plot(x='wavelengths',
                   y='reflectance',
                   kind='scatter',
                   edgecolor='none')

plt.title('Spectral Signature for '+sitename+' Pixel '+', '.join(map(str, pixel_to_plot)))

ax2 = plt.gca()  # stands for 'get current axis'
ax2.grid(True)
ax2.set_xlim([np.min(serc_pixel_df['wavelengths']),
              np.max(serc_pixel_df['wavelengths'])])
ax2.set_ylim(0, 0.5)
ax2.set_xlabel("Wavelength, nm")
ax2.set_ylabel("Reflectance")

#Add in red dotted lines to show boundaries of bad band windows:
ax2.plot((bbw1[0], bbw1[0]), (0, 1.5), 'r--')
ax2.plot((bbw1[1], bbw1[1]), (0, 1.5), 'r--')
ax2.plot((bbw2[0], bbw2[0]), (0, 1.5), 'r--')
ax2.plot((bbw2[1], bbw2[1]), (0, 1.5), 'r--')

fig = ax2.get_figure()
fig.savefig(args.figdir+'/'+sitename+'_'+'_'.join(map(str, pixel_to_plot))+'_plot_3_marked_and_cleaned.png')
