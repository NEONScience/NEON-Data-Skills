### Create the base map for the NEON_Plots tutorial

library(neonUtilities)
library(raster)
library(rgdal)
library(sp)

### Set the working/plotting directories

wd = "/Users/collin/Documents/GitProjects/NEON-Data-Skills/tutorials-in-development/R/NEON_Plots/data/"
pd = "/Users/collin/Documents/GitProjects/NEON-Data-Skills/tutorials-in-development/R/NEON_Plots/plot/"

### IMAGE 1 ###
### ELEVATION CLIPPED TO SOAP EXTENT ###

### Read in the raster for SOAP with elevation data

all.dtm=raster(paste0(wd,"/DP3.30024.001/2019/DTM.tif"))
nlcd = raster(paste0(wd,'NLCD/NLCD_2016_Land_Cover_L48_20190424_ghJ2NEt6I0kEkV7MJWd2.tiff'))

### Read in the shape for field sampling boundaries
### Subset to just SOAP and project the shape

all.bounds=readOGR(paste0(wd,"Field_Sampling_Boundaries/terrestrialSamplingBoundaries.shp"))
SOAP.bound=all.bounds[all.bounds$siteID=="SOAP",]
SOAP.bound=spTransform(SOAP.bound, crs(all.dtm))

### Create an extent object which encompasses SOAP plus a bit around the edge

SOAP.extent = extent(SOAP.bound)
SOAP.x.10.buf = (SOAP.extent@xmax-SOAP.extent@xmin)*0.1
SOAP.y.10.buf = (SOAP.extent@ymax-SOAP.extent@ymin)*0.1
SOAP.xmin = SOAP.extent@xmin - SOAP.x.10.buf
SOAP.xmax = SOAP.extent@xmax + SOAP.x.10.buf
SOAP.ymin = SOAP.extent@ymin - SOAP.y.10.buf
SOAP.ymax = SOAP.extent@ymax + SOAP.y.10.buf
SOAP.extent = c(SOAP.xmin,SOAP.xmax,SOAP.ymin,SOAP.ymax)

### Clip the dtm raster to SOAP extent

SOAP.dtm = crop(all.dtm,SOAP.extent)

### Write out the clipped  dtm raster

writeRaster(x=SOAP.dtm,filename=paste0(wd,'SOAP_DTM.tif'))

### Convert to hillshade

SOAP.dtm.slope=terrain(SOAP.dtm, opt="slope",units="radians")
SOAP.dtm.aspect=terrain(SOAP.dtm, opt="aspect",units="radians")
SOAP.hillshade=hillShade(SOAP.dtm.slope,SOAP.dtm.aspect)

### Write out the hillshade raster

writeRaster(x=SOAP.hillshade,filename=paste0(wd,'SOAP_HILLSHADE.tif'))

### IMAGE 2 ### 
### OVERLAY THE NLCD DATA ON THE HILLSHADE MAP
### START BY

extent.df = data.frame(lon = c(SOAP.extent[1:2]), lat = c(SOAP.extent[3:4]))
coordinates(extent.df) <- 1:2
crs(extent.df) = crs(SOAP.bound)
extent.proj = spTransform(extent.df, crs(nlcd))
nlcd.crop = crop(nlcd,extent(extent.proj))
nlcd.crop.proj = projectRaster(nlcd.crop, crs=crs(SOAP.dtm), method='ngb')

hillshade.proj = projectRaster(SOAP.hillshade, crs=crs(nlcd), method='bilinear')

png(paste0(pd,'twisted.png'))
plot(hillshade.proj, col=grey((1:90)/100), alpha=1, legend=F)
plot(nlcd.crop, alpha=.3, add=T)
dev.off()

