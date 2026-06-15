
# Load needed packages and set API token
library(terra)
library(neonUtilities)
token <- Sys.getenv("NEON_TOKEN")


data_dir="~/data/" #This will depend on your local environment


byTileAOP(dpID='DP3.30024.001',
          site='SJER',
          year='2021',
          easting=257500,
          northing=4112500,
          check.size=TRUE, # set to FALSE if you don't want to enter y/n
          savepath = data_dir,
          token=token)

# Define the DSM and DTM file names, including the full path
dsm_file <- paste0(data_dir,"DP3.30024.001/neon-aop-products/2021/FullSite/D17/2021_SJER_5/L3/DiscreteLidar/DSMGtif/NEON_D17_SJER_DP3_257000_4112000_DSM.tif")
dtm_file <- paste0(data_dir,"DP3.30024.001/neon-aop-products/2021/FullSite/D17/2021_SJER_5/L3/DiscreteLidar/DTMGtif/NEON_D17_SJER_DP3_257000_4112000_DTM.tif")


# assign raster to object
dsm <- rast(dsm_file)

# view info about the raster.
dsm

# plot the DSM
plot(dsm, main="Lidar Digital Surface Model \n SJER, California")



# import the digital terrain model
dtm <- rast(dtm_file)

plot(dtm, main="Lidar Digital Terrain Model \n SJER, California")



# use raster math to create CHM
chm <- dsm - dtm

# view CHM attributes
chm

plot(chm, main="Lidar CHM - SJER, California")


# conversion 1m = 3.28084 ft
chm_ft <- chm*3.28084

# plot 
plot(chm_ft, main="Lidar Canopy Height Model (in feet)")

# # write out the CHM in tiff format.
# writeRaster(chm,paste0(wd,"CHM_SJER.tif"),"GTiff")
# 
