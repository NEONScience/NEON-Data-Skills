## Draft workflow for a lesson on using rasters in R
# Collaboration with Matthew Helmnus (Temple University) and Donal O'Leary (National Ecological Observatory Network)

# Prompt:
# Do you think it easy to have code that downloads lidar height and 
# tree cover for the full AOP footprint, do arithmetic, and then sf intersections?

# Response:
# Let's explore Soaproot Saddle, a relocatable terrestrial field site
# in the foothills of the Sierra Nevada mountains in California.

# Site Description: https://www.neonscience.org/field-sites/field-sites-map/SOAP
# Short overview video: https://www.neonscience.org/soaproot-saddle-overview-soap-drone-video
# Same video on YouTubbe: https://www.youtube.com/watch?v=N0oz3auWq2s&list=PLLWiknuNGd50X1JAJbqQlfwKpXbtJwXFy&index=14


#install.packages("neonUtilities")
#install.packages("raster")

library(neonUtilities)
library(raster)
library(rgdal)

## Download AOP data using byFileAOP() function in neonUtilities
# Note that you can add easting and northing to choose specific tiles,
# but this function will download all tiles within the site if easting 
# and northing are absent.

# We will download the lidar-derived 'Elevation' dataset, which includes the 
# digital terrain model (DTM) and digital surface model (DSM)
# See the NEON lidar tutorial series (https://www.neonscience.org/intro-lidar-r-series)
# especially "What is a CHM, DSM, and DTM? (https://www.neonscience.org/chm-dsm-dtm-gridded-lidar-data)
# for explanation of these datasets and how they were derived

setwd("~/Downloads/SOAP/")
byFileAOP("DP3.30024.001", site="SOAP", 
          year="2019", check.size=T)
# Can download multiple sites e.g., c("SOAP","HARV") and years
# check.size=T is helpful to avoid accidentally downloading many Gbs!


# Let's look at the digital terraim model (DTM) which is a model of the
# Earth's surface with all of the vegetation removed (ground returns only).

## Merge them all together
# First, make a list of all of the downloaded TIFFs. 
# Yes, they are kind of hidden in a long file structure, but this 
# is actually really helpful when you have many sites/years of data
f <- list.files(path = "~/Downloads/SOAP/DP3.30024.001/2019/FullSite/D17/2019_SOAP_4/L3/DiscreteLidar/DTMGtif/", pattern = ".tif$", full.names = TRUE)

# Now load all of the TIFFs into a list of rasters
rl <- lapply(f, raster)

# Finally, we get to mosaic them using the merge() function
# DTM=do.call(merge, c(rl, tolerance = 1)) mosaics all tiles and
# system.time({ ...function... }) times it on your machine in seconds
system.time({ DTM=do.call(merge, c(rl, tolerance = 1)) })

## Let's save the mosaic to avoid having to combine all the tiles again.
writeRaster(DTM, filename = "~/Downloads/SOAP/DP3.30024.001/2019/DTM.tif")
# if you want to read this in again later:
# DTM=raster("~/Downloads/SOAP/DP3.30024.001/2019/DTM.tif")

# plot the full DTM
plot(DTM)


###########
## Shapefiles
###########
# Now that we have a raster, let's read in all of the associated 
# shapefiles for SOAP

# These filepaths assume that you have downloaded and unzipped all files
# (in links) to the "~/Downloads" directory. 

# read in flight boxes
# https://neon.maps.arcgis.com/home/item.html?id=f27616de7f9f401b8732cdf8902ab1d8
setwd("~/Downloads/AOP_Flightboxes/")
AOP_fb=readOGR("AOP_flightboxesAllSites.shp")
# What is the projection for this file?
crs(AOP_fb)

# Select just SOAP
SOAP_AOP_fb=AOP_fb[AOP_fb$siteID=="SOAP",]
# re-project this shapefile into UTM11 to pair with the DTM
SOAP_AOP_fb=spTransform(SOAP_AOP_fb, crs(DTM))
plot(SOAP_AOP_fb, add=T)

# Field site sampling boundaries
# https://neon.maps.arcgis.com/home/item.html?id=4a381f124a73490aa9ad7b1df914d6d8
setwd("~/Downloads/Field_Sampling_Boundaries/")
field_sampling_boundaries=readOGR("terrestrialSamplingBoundaries.shp")
# What is the projection for this file?
crs(field_sampling_boundaries)

# Select just SOAP
SOAP_field_boundary=field_sampling_boundaries[field_sampling_boundaries$siteID=="SOAP",]
SOAP_field_boundary=spTransform(SOAP_field_boundary, crs(DTM))
plot(SOAP_field_boundary, add=T, border="green3")


# Field site tower point locations
# https://neon.maps.arcgis.com/home/item.html?id=3af642ac5b5b422fbc8c09132d0e13cb
setwd("~/Downloads/NEON_Field_Sites/")
NEON_fs=readOGR("NEON_Field_Sites_v16_1.shp")
# What is the projection for this file?
crs(NEON_fs)

# Select just SOAP
SOAP_fs=NEON_fs[NEON_fs$siteID=="SOAP",]
SOAP_fs=spTransform(SOAP_fs, crs(DTM))
plot(SOAP_fs, add=T, pch=7)


# All TOS plots (see site description page for different plot types)
# https://www.neonscience.org/field-sites/field-sites-map/SOAP
setwd("~/Downloads/All_NEON_TOS_Plots_V7/")
NEON_tos_plots=readOGR("All_NEON_TOS_Plot_Polygons_V7.shp")
crs(NEON_tos_plots)

SOAP_tos_plot=NEON_tos_plots[NEON_tos_plots$siteID=="SOAP",]
SOAP_tos_plot=spTransform(SOAP_tos_plot, crs(DTM))
plot(SOAP_tos_plot[SOAP_tos_plot$subtype=="basePlot",], border="blue")

# Take a look at all of the different plot types.
View(SOAP_tos_plot@data)
# This would be cool to plot different types in different colors!
# plot(SOAP_tos_plot[SOAP_tos_plot$plotType=="tower",], border="red", add=T)
# Or to use the different nlcdClass types to extract CHM and plot histograms
# of vegetation height - see the raster::extract() function


# Flux Airsheds
# https://neon.maps.arcgis.com/home/item.html?id=d87cd176dd6a468294fc0ac70918c631
setwd("~/Downloads/90percentfootprint/")
NEON_airsheds=readOGR("90percent_footprint.shp")
crs(NEON_airsheds)

SOAP_airshed=NEON_airsheds[NEON_airsheds$SiteID=="SOAP",]
SOAP_airshed=spTransform(SOAP_airshed, crs(DTM))
plot(SOAP_airshed, add=T, border="orange3")


## This is cool and all, but we can hardly see the field site 
# when zoomed out this far. Let's clip the mosaic to just the 
# field site boundary and try again.

DTM_field_c=crop(DTM, extent(SOAP_field_boundary))
DTM_field_ras=mask(DTM_field_c, SOAP_field_boundary)
plot(DTM_field_ras)

plot(SOAP_field_boundary, add=T, border="green3")
plot(SOAP_fs, add=T, pch=7)
plot(SOAP_tos_plot, add=T, border="blue")
plot(SOAP_airshed, add=T, border="orange3")


## Make hillshade
# I think that we can still make this look nicer. Let's make a hillshade
# for SOAP
DTM_slope=terrain(DTM, opt="slope",units="radians")
DTM_aspect=terrain(DTM, opt="aspect",units="radians")
DTM_hillshade=hillShade(DTM_slope, DTM_aspect)

plot(DTM_hillshade, col=grey((1:90)/100), alpha=1, legend=F)
plot(DTM, alpha=.3, add=T)

# Great! But we're too far zoomed out to really see the field sites
# Let's clip the DTM to the field site boundary to see better detail

# Crop and mask the DTM
DTM_field_c=crop(DTM, extent(SOAP_field_boundary))
DTM_field_ras=mask(DTM_field_c, SOAP_field_boundary)

# Crop and mask the hillshade
DTM_hill_field_c=crop(DTM_hillshade, extent(SOAP_field_boundary))
DTM_hill_field_ras=mask(DTM_hill_field_c, SOAP_field_boundary)

# plot the zoomed-in view
plot(DTM_hill_field_ras, col=grey((1:90)/100), alpha=1, legend=F)
plot(DTM_field_ras, alpha=.3, add=T)

# and add the field sampling shapefiles again
plot(SOAP_field_boundary, add=T, border="green3")
plot(SOAP_fs, add=T, pch=7)
plot(SOAP_tos_plot, add=T, border="blue")
plot(SOAP_airshed, add=T, border="orange3")

