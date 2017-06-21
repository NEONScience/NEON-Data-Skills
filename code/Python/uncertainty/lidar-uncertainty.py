# -*- coding: utf-8 -*-
"""
Created on Sun May 14 18:54:29 2017

@author: tgoulden
"""

import h5py
import numpy as np
from math import floor
import os
import gdal
import matplotlib.pyplot as plt
import sys

def plot_band_array(band_array,image_extent,title,cmap_title,colormap,colormap_limits):
    plt.imshow(diff_dsm_array,extent=image_extent)
    cbar = plt.colorbar(); plt.set_cmap(colormap); plt.clim(colormap_limits)
    cbar.set_label(cmap_title,rotation=270,labelpad=20)
    plt.title(title); ax = plt.gca()
    ax.ticklabel_format(useOffset=False, style='plain') 
    rotatexlabels = plt.setp(ax.get_xticklabels(),rotation=90)


print('Start Uncertainty Script')


dsm1_filename = 'C:/RSDI_2017/data/PRIN/2016_PRIN_1_607000_3696000_DSM.tif'
dsm2_filename = 'C:/RSDI_2017/data/PRIN/2016_PRIN_2_607000_3696000_DSM.tif'
dtm1_filename = 'C:/RSDI_2017/data/PRIN/2016_PRIN_1_607000_3696000_DTM.tif'
dtm2_filename = 'C:/RSDI_2017/data/PRIN/2016_PRIN_2_607000_3696000_DTM.tif'
chm_filename = 'C:/RSDI_2017/data/PRIN/2016_PRIN_1_607000_3696000_pit_free_CHM.tif'

dsm1_dataset = gdal.Open(dsm1_filename)
dsm2_dataset = gdal.Open(dsm2_filename)
dtm1_dataset = gdal.Open(dtm1_filename)
dtm2_dataset = gdal.Open(dtm2_filename)
chm_dataset = gdal.Open(chm_filename)

cols_dsm1 = dsm1_dataset.RasterXSize
rows_dsm1 = dsm1_dataset.RasterYSize
bands_dsm1 = dsm1_dataset.RasterCount
mapinfo_dsm1 = dsm1_dataset.GetGeoTransform()
xMin = mapinfo_dsm1[0]
yMax = mapinfo_dsm1[3]
xMax = xMin + chm_dataset.RasterXSize/mapinfo_dsm1[1]
yMin = yMax + chm_dataset.RasterYSize/mapinfo_dsm1[5]
image_extent = (xMin,xMax,yMin,yMax)

cols_dsm2 = dsm2_dataset.RasterXSize
rows_dsm2 = dsm2_dataset.RasterYSize
bands_dsm2 = dsm2_dataset.RasterCount

cols_dtm1 = dtm1_dataset.RasterXSize
rows_dtm1 = dtm1_dataset.RasterYSize
bands_dtm1 = dtm1_dataset.RasterCount

cols_dtm2 = dtm2_dataset.RasterXSize
rows_dtm2 = dtm2_dataset.RasterYSize
bands_dtm2 = dtm2_dataset.RasterCount

cols_chm = chm_dataset.RasterXSize
rows_chm = chm_dataset.RasterYSize
bands_chm = chm_dataset.RasterCount

if (cols_dsm1 != cols_dsm2 or cols_dsm1 != cols_dtm1 or cols_dsm1 != cols_dtm2 or cols_dsm1 != cols_chm):
    sys.exit('Columns from datasets do not match')
       
if (rows_dsm1 != rows_dsm2 or rows_dsm1 != rows_dtm1 or rows_dsm1 != rows_dtm2 or rows_dsm1 != rows_chm):
    sys.exit('Rows from datasets do not match')
       
if (bands_dsm1 != 1 or bands_dsm2 != 1 or bands_dtm1 != 1 or bands_dtm2 != 1 or bands_chm != 1):
    sys.exit('There are the wrong number of bands in a dataset')

dsm1_raster = dsm1_dataset.GetRasterBand(1)
dsm2_raster = dsm2_dataset.GetRasterBand(1)
dtm1_raster = dtm1_dataset.GetRasterBand(1)
dtm2_raster = dtm2_dataset.GetRasterBand(1)
chm_raster = chm_dataset.GetRasterBand(1)

noDataVal_dsm1 = dsm1_raster.GetNoDataValue()
noDataVal_dsm2 = dsm2_raster.GetNoDataValue()
noDataVal_dtm1 = dtm1_raster.GetNoDataValue()
noDataVal_dtm2 = dtm2_raster.GetNoDataValue()
noDataVal_chm = chm_raster.GetNoDataValue()

#dsm_stats = dsm_raster.GetStatistics(True,True)

dsm_array1 = dsm1_raster.ReadAsArray(0,0,cols_dsm1,rows_dsm1).astype(np.float)
dsm_array2 = dsm2_raster.ReadAsArray(0,0,cols_dsm2,rows_dsm2).astype(np.float)
dtm_array1 = dtm1_raster.ReadAsArray(0,0,cols_dsm1,rows_dsm1).astype(np.float)
dtm_array2 = dtm2_raster.ReadAsArray(0,0,cols_dsm2,rows_dsm2).astype(np.float)
chm_array = chm_raster.ReadAsArray(0,0,cols_chm,rows_chm).astype(np.float)

dsm_array1[dsm_array1==int(noDataVal_dsm1)]=np.nan 
dsm_array2[dsm_array2==int(noDataVal_dsm2)]=np.nan
dtm_array1[dtm_array1==int(noDataVal_dtm1)]=np.nan 
dtm_array2[dtm_array2==int(noDataVal_dtm2)]=np.nan           
chm_array[chm_array==int(noDataVal_chm)]=np.nan 

dsm_array1[1,1] = np.nan
         
diff_dsm_array = np.subtract(dsm_array1,dsm_array2)
diff_dtm_array = np.subtract(dtm_array1,dtm_array2)    

#Plot differences in the DSM

diff_dsm_array_mean = np.nanmean(diff_dsm_array)
diff_dsm_array_std = np.nanstd(diff_dsm_array)
print('Mean difference in DSMs: ',round(diff_dsm_array_mean,3),' (m)')
print('Standard deviations of difference in DSMs: ',round(diff_dsm_array_std,3),' (m)')

plt.figure(1)
plt.hist(diff_dsm_array.flatten()[~np.isnan(diff_dsm_array.flatten())],100)
plt.title('Histogram of PRIN DSM')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.savefig('Histogram_of_PRIN_DSM_diff.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)


print([diff_dsm_array_mean-2*diff_dsm_array_std, diff_dsm_array_mean+2*diff_dsm_array_std])

plt.figure(2)
plt.hist(diff_dsm_array.flatten()[~np.isnan(diff_dsm_array.flatten())],100,range=[diff_dsm_array_mean-2*diff_dsm_array_std, diff_dsm_array_mean+2*diff_dsm_array_std])
plt.title('Histogram of PRIN DSM')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.savefig('Histogram_of_PRIN_DSM_95percent.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)

plt.figure(3)
plot_band_array(diff_dsm_array,image_extent,'DSM Difference','Difference (m)','bwr',[diff_dsm_array_mean-2*diff_dsm_array_std, diff_dsm_array_mean+2*diff_dsm_array_std])
plt.savefig('PRIN_DSM_difference.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)

#Plot differences in the DTM

diff_dtm_array_mean = np.nanmean(diff_dtm_array)
diff_dtm_array_std = np.nanstd(diff_dtm_array)
plt.figure(4)
plot_band_array(diff_dtm_array,image_extent,'DTM Difference','Difference (m)','bwr',[diff_dtm_array_mean-2*diff_dtm_array_std, diff_dtm_array_mean+2*diff_dtm_array_std])
print('Mean difference in DTMs: ',round(diff_dtm_array_mean,3),' (m)')
print('Standard deviations of difference in DTMs: ',round(diff_dtm_array_std,3),' (m)')          
plt.savefig('PRIN_DTM_difference.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)

plt.figure(5)
plt.hist(diff_dtm_array.flatten()[~np.isnan(diff_dtm_array.flatten())],100,range=[diff_dtm_array_mean-2*diff_dtm_array_std, diff_dtm_array_mean+2*diff_dtm_array_std])
plt.title('Histogram of PRIN DTM')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.savefig('Histogram_of_PRIN_DTM_diff.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)


#Plot CHM

chm_array_mean = np.nanmean(chm_array)
chm_array_std = np.nanstd(chm_array)
print('CHMs: ',round(chm_array_mean,3),' (m)')
print('Standard deviations of difference CHMs: ',round(chm_array_std,3),' (m)') 
plt.figure(6)
plot_band_array(chm_array,image_extent,'Canopy height Model','Canopy height (m)','Greens',[0, chm_array_mean])
plt.savefig('PRIN_CHM.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)


#Plot differences in the DSM for veg points only

diff_dsm_array_veg_mean = np.nanmean(diff_dsm_array[chm_array!=0.0])
diff_dsm_array_veg_std = np.nanstd(diff_dsm_array[chm_array!=0.0])
plt.figure(7)
print('Mean difference in DSMs on veg points: ',round(diff_dsm_array_veg_mean,3),' (m)')
print('Standard deviations of difference in DSMs on veg points: ',round(diff_dsm_array_veg_std,3),' (m)')

plt.figure(8)
diff_dsm_array_nodata_removed = diff_dsm_array[~np.isnan(diff_dsm_array)]
chm_dsm_nodata_removed = chm_array[~np.isnan(diff_dsm_array)]
plt.hist(diff_dsm_array_nodata_removed[chm_dsm_nodata_removed!=0.0],100,range=[diff_dsm_array_veg_mean-2*diff_dsm_array_veg_std, diff_dsm_array_veg_mean+2*diff_dsm_array_veg_std])
plt.title('Histogram of PRIN DSM (veg)')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.savefig('Histogram_of_PRIN_DSM_diff_veg.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)


#Plot differences in the DTM for veg points only

diff_dtm_array_veg_mean = np.nanmean(diff_dtm_array[chm_array!=0.0])
diff_dtm_array_veg_std = np.nanstd(diff_dtm_array[chm_array!=0.0])
print('Mean difference in DTMs on veg points: ',round(diff_dtm_array_veg_mean,3),' (m)')
print('Standard deviations of difference in DTMs on veg points: ',round(diff_dtm_array_veg_std,3),' (m)')


plt.figure(10)
diff_dtm_array_nodata_removed = diff_dtm_array[~np.isnan(diff_dtm_array)] 
chm_dtm_nodata_removed = chm_array[~np.isnan(diff_dtm_array)]
plt.hist((diff_dtm_array_nodata_removed[chm_dtm_nodata_removed!=0.0]),100,range=[diff_dtm_array_veg_mean-2*diff_dtm_array_veg_std, diff_dtm_array_veg_mean+2*diff_dtm_array_veg_std])
plt.title('Histogram of PRIN DTM (veg)')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.savefig('Histogram_of_PRIN_DTM_diff_veg.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)

#Plot differences in the DSM for ground points only

diff_dsm_array_ground_mean = np.nanmean(diff_dsm_array[chm_array==0.0])
diff_dsm_array_ground_std = np.nanstd(diff_dsm_array[chm_array==0.0])
print('Mean difference in DSMs on ground points: ',round(diff_dsm_array_ground_mean,3),' (m)')
print('Standard deviations of difference in DSMs on ground points: ',round(diff_dsm_array_ground_std,3),' (m)')

plt.figure(11)
plt.hist((diff_dsm_array_nodata_removed[chm_dsm_nodata_removed==0.0]),100,range=[diff_dsm_array_ground_mean-2*diff_dsm_array_ground_std, diff_dsm_array_ground_mean+2*diff_dsm_array_ground_std])
plt.title('Histogram of PRIN DSM (ground)')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.savefig('Histogram_of_PRIN_DSM_diff_ground.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)

#Plot differences in the DTM for ground points only

diff_dtm_array_ground_mean = np.nanmean(diff_dtm_array[chm_array==0.0])
diff_dtm_array_ground_std = np.nanstd(diff_dtm_array[chm_array==0.0])
print('Mean difference in DTMs on ground points: ',round(diff_dtm_array_ground_mean,3),' (m)')
print('Standard deviations of difference in DTMs on ground points: ',round(diff_dtm_array_ground_std,3),' (m)')

plt.figure(12)
plt.hist((diff_dtm_array_nodata_removed[chm_dtm_nodata_removed==0.0]),100,range=[diff_dtm_array_ground_mean-2*diff_dtm_array_ground_std, diff_dtm_array_ground_mean+2*diff_dtm_array_ground_std])
plt.title('Histogram of PRIN DTM (ground)')
plt.xlabel('Height Difference(m)'); plt.ylabel('Frequency')
plt.savefig('Histogram_of_PRIN_DTM_diff_ground.png',dpi=300,orientation='landscape',bbox_inches='tight',pad_inches=0.1)



plt.show()