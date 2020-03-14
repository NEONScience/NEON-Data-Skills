# there is some code in here I need to fix it

from #numpy import * 

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

metadata['ext_dict'] = {}
metadata['ext_dict']['xMin'] = mapinfo[0]
metadata['ext_dict']['xMax'] = mapinfo[0] + dataset.RasterXSize/mapinfo[1]
metadata['ext_dict']['yMin'] = mapinfo[3] + dataset.RasterYSize/mapinfo[5]
metadata['ext_dict']['yMax'] = mapinfo[3]
    
    # metadata['extent'] = (metadata['ext_dict']['xMin'],metadata['ext_dict']['xMax'],
#                           metadata['ext_dict']['yMin'],metadata['ext_dict']['yMax'])
#     
#     if metadata['bands'] == 1:
#         raster = dataset.GetRasterBand(1)
#         metadata['noDataValue'] = raster.GetNoDataValue()
#         metadata['scaleFactor'] = raster.GetScale()
        
    band statistics
    metadata['bandstats'] = {} #make a nested dictionary to store band stats in same 
    stats = raster.GetStatistics(True,True)
    metadata['bandstats']['min'] = round(stats[0],2)
    metadata['bandstats']['max'] = round(stats[1],2)
    metadata['bandstats']['mean'] = round(stats[2],2)
    metadata['bandstats']['stdev'] = round(stats[3],2)
    
array = dataset.GetRasterBand(1).ReadAsArray(0,0,metadata['array_cols'],metadata['array_rows']).astype(np.float)
array[array==metadata['noDataValue']]=np.nan
array = array/metadata['scaleFactor']
array = array[::-1] #inverse array because Python is column major
return array, metadata

elif metadata['bands'] > 1:
    print('More than one band ... need to modify function for case of multiple bands')

# fix this up later maybe a function
cols = array.shape[1]
rows = array.shape[0]
originX = rasterOrigin[0]
originY = rasterOrigin[1]

driver = gdal.GetDriverByName('GTiff')
outRaster = driver.Create(newRasterfn, cols, rows, 1, gdal.GDT_Byte)
outRaster.SetGeoTransform((originX, pixelWidth, 0, originY, 0, pixelHeight))
outband = outRaster.GetRasterBand(1)

import gdal

outband.WriteArray(array)
outRasterSRS = osr.SpatialReference()
outRasterSRS.ImportFromEPSG(epsg)
outRaster.SetProjection(outRasterSRS.ExportToWkt())
outband.FlushCache()
