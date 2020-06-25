### Bring in the NLCD (vegetation type) raster data

nlcd.ras = raster(paste0(wd,'NLCD/NLCD_2016_Land_Cover_L48_20190424_ghJ2NEt6I0kEkV7MJWd2.tiff'))

### Bring in the NEON AOP Data (effectively an elevation model)

dtm = raster(paste0(wd,"/DP3.30024.001/2019/DTM.tif"))

### Bring in the shape data relating to NEON field sampling boundaries, TOS plots, airshed/tower locs

all.samp.bound=readOGR(paste0(wd,"Field_Sampling_Boundaries/terrestrialSamplingBoundaries.shp"))
all.tower.locs=readOGR(paste0(wd,"NEON_Field_Sites/NEON_Field_Sites_v17.shp"))
all.tos.plots=readOGR(paste0(wd,"NEON_TOS_Plot_Polygons/NEON_TOS_Plot_Polygons.shp"))
all.airshed.locs=readOGR(paste0(wd,"90percentfootprint/90percent_footprint.shp"))

### Determine the CRS of the raster data

nlcd.crs = crs(nlcd.ras)
dtm.crs = crs(dtm)

### Adjust the CRS of the shapedata to match that of the NLCD/DTM data

nlcd.all.samp.bound = spTransform(all.samp.bound, nlcd.crs)
nlcd.all.tower.locs = spTransform(all.tower.locs, nlcd.crs)
nlcd.all.tos.plots = spTransform(all.tos.plots, nlcd.crs)
nlcd.all.airshed.locs = spTransform(all.airshed.locs, nlcd.crs)
dtm.all.samp.bound = spTransform(all.samp.bound, dtm.crs)
dtm.all.tower.locs = spTransform(all.tower.locs, dtm.crs)
dtm.all.tos.plots = spTransform(all.tos.plots, dtm.crs)
dtm.all.airshed.locs = spTransform(all.airshed.locs, dtm.crs)

### Removes shapes which don't correspond to site 'SOAP'

nlcd.soap.samp.bound = nlcd.all.samp.bound[nlcd.all.samp.bound$siteID=="SOAP",]
nlcd.soap.tower.loc = nlcd.all.tower.locs[nlcd.all.tower.locs$siteID=="SOAP",]
nlcd.soap.tos.plots = nlcd.all.tos.plots[nlcd.all.tos.plots$siteID=="SOAP",]
nlcd.soap.airshed.loc = nlcd.all.airshed.locs[nlcd.all.airshed.locs$siteID=="SOAP",]
dtm.soap.samp.bound = dtm.all.samp.bound[dtm.all.samp.bound$siteID=="SOAP",]
dtm.soap.tower.loc = dtm.all.tower.locs[dtm.all.tower.locs$siteID=="SOAP",]
dtm.soap.tos.plots = dtm.all.tos.plots[dtm.all.tos.plots$siteID=="SOAP",]
dtm.soap.airshed.loc = dtm.all.airshed.locs[dtm.all.airshed.locs$siteID=="SOAP",]

### Get the extent of the NEON sampling boundary

nlcd.soap.samp.bound.extent = extent(nlcd.soap.samp.bound)
dtm.soap.samp.bound.extent = extent(dtm.soap.samp.bound)

### Create a new extent object with a 10% buffer around the SOAP sampling boundary

nlcd.x.10.buf = (nlcd.soap.samp.bound.extent@xmax-nlcd.soap.samp.bound.extent@xmin)*0.1
nlcd.y.10.buf = (nlcd.soap.samp.bound.extent@ymax-nlcd.soap.samp.bound.extent@ymin)*0.1
nlcd.new.xmin = nlcd.soap.samp.bound.extent@xmin - nlcd.x.10.buf
nlcd.new.xmax = nlcd.soap.samp.bound.extent@xmax + nlcd.x.10.buf
nlcd.new.ymin = nlcd.soap.samp.bound.extent@ymin - nlcd.y.10.buf
nlcd.new.ymax = nlcd.soap.samp.bound.extent@ymax + nlcd.y.10.buf
nlcd.new.extent = c(nlcd.new.xmin,nlcd.new.xmax,nlcd.new.ymin,nlcd.new.ymax)

dtm.x.10.buf = (dtm.soap.samp.bound.extent@xmax-dtm.soap.samp.bound.extent@xmin)*0.1
dtm.y.10.buf = (dtm.soap.samp.bound.extent@ymax-dtm.soap.samp.bound.extent@ymin)*0.1
dtm.new.xmin = dtm.soap.samp.bound.extent@xmin - dtm.x.10.buf
dtm.new.xmax = dtm.soap.samp.bound.extent@xmax + dtm.x.10.buf
dtm.new.ymin = dtm.soap.samp.bound.extent@ymin - dtm.y.10.buf
dtm.new.ymax = dtm.soap.samp.bound.extent@ymax + dtm.y.10.buf
dtm.new.extent = c(dtm.new.xmin,dtm.new.xmax,dtm.new.ymin,dtm.new.ymax)

### Crop the NLCD and DTM layers according the sampling boundary at SOAP plus 10%

nlcd.crop = crop(x=nlcd.ras,y=nlcd.new.extent) # Included a 10% buffer on all sides of the SOAP sampling boundary
dtm.crop = crop(x=dtm,y=dtm.new.extent) # Inlcluded a 10% buffer on all sides of the SOAP sampling boundary

### Re-project the NLCD data so that the CRS matches that of DTM data

nlcd.crop.proj = projectRaster(nlcd.crop, crs=dtm.crs, method='ngb') # Nearest neighbor method, useful for categorical data

### Create a 'hillshade' map from the NEON AOP DTM data

dtm.slope.crop = terrain(dtm.crop, opt="slope",units="radians")
dtm.aspect.crop = terrain(dtm.crop, opt="aspect",units="radians")
dtm.hillshade.crop = hillShade(dtm.slope.crop, dtm.aspect.crop)

### Overlay shapes on cropped DTM and see how it looks

png('DTMCroppedWithShapes.png')
plot(dtm.hillshade.crop, col=grey((1:90)/100), alpha=1, legend=F)
plot(dtm.crop, alpha=.3, add=T)
plot(dtm.soap.samp.bound, add=T, border="green3")
dev.off()

png('NLCDCroppedWithShapes.png')
plot(nlcd.crop.proj, col=grey((1:90)/100), alpha=1, legend=F)
plot(dtm.soap.samp.bound, add=T, border="green3")
dev.off()

### START HERE ###
### MAKE A MAP OF RASTER OF SOAP