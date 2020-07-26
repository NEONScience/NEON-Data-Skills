library(rGEDI)
library(raster)
library(sf)
library(rgl)
library(lidR)
library(neonUtilities)

# 
# - Resolve datum discrepancy
# - Make subset of GEDI data in H5 file
# - Send to Katharyn at this point see if it makes sense
# - Fill out the rest of the non-code .Rmd information in collaboration with Katharyn 

## read in AOP flight box KML here and crop GEDI data by that shapefile

chm=raster("~/Downloads/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")

extent(chm)
chm_WGS = projectRaster(chm, crs=CRS("+init=epsg:4326"))
plot(chm_WGS)

## Add base plots
setwd("~/Downloads/")
download.file(url="https://data.neonscience.org/api/v0/documents/All_NEON_TOS_Plots_V8", destfile="All_NEON_TOS_Plots_V8.zip")
unzip("All_NEON_TOS_Plots_V8.zip")
NEON_all_plots <- st_read('All_NEON_TOS_Plots_V8/All_NEON_TOS_Plot_Polygons_V8.shp')

# Select just the WREF site
SITECODE = 'WREF'
base_plots_SPDF <- NEON_all_plots[(NEON_all_plots$siteID == SITECODE)&(NEON_all_plots$subtype == 'basePlot'),]
rm(NEON_all_plots)

base_crop=st_crop(base_plots_SPDF, extent(chm_WGS))
plot(base_crop$geometry, border = 'blue', add=T)


# Study area boundary box coordinates
# entire Tile
ul_lat<- extent(chm_WGS)[4]
lr_lat<- extent(chm_WGS)[3]
ul_lon<- extent(chm_WGS)[1]
lr_lon<- extent(chm_WGS)[2]

# Or, if you want to define your own extent using the interactive 'drawExtent' function on a map:
# e=drawExtent()
# 
# ul_lat<- e[4]
# lr_lat<- e[3]
# ul_lon<- e[1]
# lr_lon<- e[2]


# Specifying the date range
# GEDI data available from 2019-03-25
daterange=c("2019-03-25","2020-07-15")

# Get path to GEDI data
# These lines use an API request to determine which orbits are available that intersect the bounding box of interest.
# Note that you still must download the entire orbit and then subset to your area of interest!
# Word on the street is that a true spatial subsetting tool is in the works.
gLevel1B<-gedifinder(product="GEDI01_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001",daterange=daterange)
gLevel2A<-gedifinder(product="GEDI02_A",ul_lat, ul_lon, lr_lat, lr_lon,version="001",daterange=daterange)
#gLevel2B<-gedifinder(product="GEDI02_B",ul_lat, ul_lon, lr_lat, lr_lon,version="001",daterange=daterange)

# Set output dir for downloading the files
outdir=getwd()

# Downloading GEDI data
#gediDownload(filepath=gLevel1B,outdir=outdir)
#gediDownload(filepath=gLevel2A,outdir=outdir)
#gediDownload(filepath=gLevel2B,outdir=outdir)

#** Herein, we are using only a GEDI sample dataset for this tutorial.
# downloading zip file
# zipfile = file.path(outdir, "examples.zip")
# download.file("https://github.com/carlos-alberto-silva/rGEDI/releases/download/datasets/examples.zip",destfile=zipfile)
# 
# # unzip file
# unzip(zipfile, exdir=outdir)

# Reading GEDI data
gedilevel1b<-readLevel1B(level1Bpath = file.path(outdir, "GEDI01_B_2019206022612_O03482_T00370_02_003_01.h5"))
level1bGeo<-getLevel1BGeo(level1b=gedilevel1b,select=c("elevation_bin0"))
head(level1bGeo)

# Converting shot_number as "integer64" to "character"
level1bGeo$shot_number<-paste0(level1bGeo$shot_number)

# Converting level1bGeo as data.table to SpatialPointsDataFrame
library(sp)
level1bGeo = level1bGeo[!is.na(level1bGeo$latitude_bin0)&!is.na(level1bGeo$longitude_bin0),]

level1bGeo_spdf<-st_as_sf(level1bGeo, 
                          coords = c("longitude_bin0", "latitude_bin0"),
                          crs=CRS("+init=epsg:4326"))

# level1bGeo_spdf<-SpatialPointsDataFrame(cbind(level1bGeo$longitude_bin0, level1bGeo$latitude_bin0),
#                                         data=level1bGeo)

#level1bGeo_spdf@proj4string=CRS("+init=epsg:4326")


## change this to crop by AOP flight box - that's the real about of ALS data that can be compared
level1bgeo_WREF=st_crop(level1bGeo_spdf, chm_WGS)

# Exporting level1bGeo as ESRI Shapefile
#raster::shapefile(level1bGeo_spdf,paste0(outdir,"\\GEDI01_B_2019108080338_O01964_T05337_02_003_01_sub"))

library(leaflet)
library(leafsync)

m = leaflet() %>%
  addCircleMarkers(level1bgeo_WREF$longitude_bin0,
                   level1bgeo_WREF$latitude_bin0,
                   radius = 1,
                   opacity = 1,
                   color = "red")  %>%
  addScaleBar(options = list(imperial = FALSE)) %>%
  addProviderTiles(providers$Esri.WorldImagery) %>%
  addLegend(colors = "red", labels= "Samples",title ="GEDI Level1B")

m

# plot(chm_WGS)
# points(x=level1bgeo_WREF$longitude_bin0,
#        y=level1bgeo_WREF$latitude_bin0,
#        radius = 1,
#        opacity = 1,
#        color = "red")
# 
# plot(base_crop$geometry, border = 'blue', add=T)
library(maptools)
## transform to UTM
level1bgeo_WREF_UTM=st_transform(level1bgeo_WREF, crs=chm$NEON_D16_WREF_DP3_580000_5075000_CHM@crs)

# buffer the GEDI shot center by a radius of 12.5m to represent the full 25m diameter GEDI footprint
level1bgeo_WREF_UTM_buffer=st_buffer(level1bgeo_WREF_UTM, dist=12.5)
base_crop_UTM=st_transform(base_crop, crs=chm$NEON_D16_WREF_DP3_580000_5075000_CHM@crs)
plot(chm)
plot(level1bgeo_WREF_UTM_buffer, add=T, col="transparent")
#labels <- layer(sp.text(coordinates(level1bgeo_WREF_UTM_buffer), txt = level1bgeo_WREF_UTM$shot_number, pos = 1))
plot(base_crop_UTM, add=T, border="blue", col="transparent")

# add labes with the last three digits of the GEDI shot_number
pointLabel(st_coordinates(level1bgeo_WREF_UTM),labels=substr(level1bgeo_WREF_UTM$shot_number, 15, 17), cex=.6)
###
# Extracting GEDI full-waveform for a given shot_number
wf <- getLevel1BWF(gedilevel1b,shot_number = "34820321600151786")

oldpar <- par()
par(mfrow = c(1,2), mar=c(4,4,1,1), cex.axis = 1.5)

plot(wf, relative=FALSE, polygon=TRUE, type="l", lwd=2, col="forestgreen",
     xlab="Waveform Amplitude", ylab="Elevation (m)")
grid()
plot(wf, relative=TRUE, polygon=FALSE, type="l", lwd=2, col="forestgreen",
     xlab="Waveform Amplitude (%)", ylab="Elevation (m)")
grid()
par(oldpar)


byTileAOP(dpID = "DP1.30003.001", site = SITECODE, year = 2017, easting = extent(chm)[1], northing=extent(chm)[3], check.size = F)


# ### remove outlier lidar point outliers using mean and sd statistics
# Z_sd=sd(site_LAS@data$Z)
# Z_mean=mean(site_LAS@data$Z)
# 
# # make filter string in form filter = "-drop_z_below 50 -drop_z_above 1000"
# # You can increase or decrease (from 4) the number of sd's to filter outliers
# f= paste("-drop_z_below",(Z_mean-4*Z_sd),"-drop_z_above",(Z_mean+4*Z_sd))
# 
# # Read in LAS file, trimming off vertical outlier points
# site_LAS=readLAS(file_name, filter = f)


## crop pointcloud to GEDI footprints
WREF_LAS=readLAS("~/Downloads/DP1.30003.001/2017/FullSite/D16/2017_WREF_1/L1/DiscreteLidar/ClassifiedPointCloud/NEON_D16_WREF_DP1_580000_5075000_classified_point_cloud.laz",
                 filter = "-drop_z_below 50 -drop_z_above 1000")

#Plot the full LiDAR point cloud mosaic tile (1km^2)
plot(WREF_LAS)

# Clip the pointcloud by the GEDI footprints created by buffering above. This makes a 'list' of LAS objects
WREF_GEDI_footprints=lasclip(WREF_LAS, geometry = level1bgeo_WREF_UTM_buffer)

# we can plot individual footprint clips
plot(WREF_GEDI_footprints[[13]])

for(shot_n in 1:1){
wf <- getLevel1BWF(gedilevel1b,shot_number = level1bgeo_WREF$shot_number[shot_n])

summary(wf@dt$rxwaveform)

d=wf@dt
# normalize rxwaveform
d$rxwaveform=d$rxwaveform-min(d$rxwaveform)
d$rxwaveform=d$rxwaveform/max(d$rxwaveform)

#add xy data
d$x=st_coordinates(level1bgeo_WREF_UTM[shot_n,])[1]
d$y=st_coordinates(level1bgeo_WREF_UTM[shot_n,])[2]

d$y_wf=d$y+d$rxwaveform*30
summary(d)
p=plot(WREF_GEDI_footprints[[shot_n]])
points3d(x=d$x-p[1], y=d$y_wf-p[2]+12.5, z=d$elevation+20, col="green", add=T)

}

#p=plot(WREF_GEDI_footprints[[13]])
#p=plot(WREF_GEDI_footprints[[13]])
# points3d(x=WREF_GEDI_footprints[[2]]@data$X-p[1],
#          y=WREF_GEDI_footprints[[2]]@data$Y-p[2],
#          z=WREF_GEDI_footprints[[2]]@data$Z,
#          add=T, #color = WREF_GEDI_footprints[[2]]@data$Z, 
#          colorPalette = height.colors(50))
# plot(WREF_GEDI_footprints[[1:26]],
#      color = "Z", colorPalette = height.colors(50),
#      add=T)
#lapply(WREF_GEDI_footprints[2:26], plot, add=T)
## Adding 20 to elevation as a quick fix - error introduced in spatial transformation? (elevation here not projected)

# Plot all GEDI cylindars and waveforms at the same time

WREF_GEDI_footprints_combined=lasclip(WREF_LAS, geometry = as_Spatial(st_union(level1bgeo_WREF_UTM_buffer)), radius=12.5)

## might need to reproduce this above by clipping in a different way (that doesn't produce a list). Merge footprints first?
p=plot(WREF_GEDI_footprints_combined)

for(shot in 1:length(level1bgeo_WREF_UTM$shot_number)){
  # Extracting GEDI full-waveform for a given shot_number
  wf <- getLevel1BWF(gedilevel1b, shot_number = level1bgeo_WREF_UTM$shot_number[shot])
  d=wf@dt
  # normalize rxwaveform
  d$rxwaveform=d$rxwaveform-min(d$rxwaveform)
  d$rxwaveform=d$rxwaveform/max(d$rxwaveform)
  
  #add xy data
  d$x=st_coordinates(level1bgeo_WREF_UTM[shot,])[1]
  d$y=st_coordinates(level1bgeo_WREF_UTM[shot,])[2]
  
  d$y_wf=d$y+d$rxwaveform*30
  points3d(x=d$x-p[1], y=d$y_wf-p[2]+12.5, z=d$elevation+20, col="green", add=T)
  
}
library(rhdf5)
h5closeAll()


diff=raster("WGS84_NAD83_seperation.tif")
diff
chm
chm_NAD = projectRaster(chm, crs=CRS(diff@crs@projargs))
chm_NAD
diff=crop(diff,extent(chm_NAD))
plot(diff)
