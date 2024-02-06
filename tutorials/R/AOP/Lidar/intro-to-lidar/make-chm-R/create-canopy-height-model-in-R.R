## ----load-libraries, message=FALSE, warning=FALSE----------------------------------------------------------------------------------------------------------------------------

# Load needed packages
library(terra)
library(neonUtilities)


## ----set-working-directory---------------------------------------------------------------------------------------------------------------------------------------------------

wd="~/data/" #This will depend on your local environment
setwd(wd)


## ----download-refl, eval=FALSE-----------------------------------------------------------------------------------------------------------------------------------------------
## byTileAOP(dpID='DP3.30024.001',
##           site='SJER',
##           year='2021',
##           easting=257500,
##           northing=4112500,
##           check.size=TRUE, # set to FALSE if you don't want to enter y/n
##           savepath = wd)


## ----define-h5, results="hide"-----------------------------------------------------------------------------------------------------------------------------------------------
# Define the DSM and DTM file names, including the full path
dsm_file <- paste0(wd,"DP3.30024.001/neon-aop-products/2021/FullSite/D17/2021_SJER_5/L3/DiscreteLidar/DSMGtif/NEON_D17_SJER_DP3_257000_4112000_DSM.tif")
dtm_file <- paste0(wd,"DP3.30024.001/neon-aop-products/2021/FullSite/D17/2021_SJER_5/L3/DiscreteLidar/DTMGtif/NEON_D17_SJER_DP3_257000_4112000_DTM.tif")


## ----import-dsm--------------------------------------------------------------------------------------------------------------------------------------------------------------

# assign raster to object
dsm <- rast(dsm_file)

# view info about the raster.
dsm

# plot the DSM
plot(dsm, main="Lidar Digital Surface Model \n SJER, California")



## ----plot-DTM----------------------------------------------------------------------------------------------------------------------------------------------------------------

# import the digital terrain model
dtm <- rast(dtm_file)

plot(dtm, main="Lidar Digital Terrain Model \n SJER, California")



## ----calculate-plot-CHM------------------------------------------------------------------------------------------------------------------------------------------------------

# use raster math to create CHM
chm <- dsm - dtm

# view CHM attributes
chm

plot(chm, main="Lidar CHM - SJER, California")



## ----challenge-code-raster-math, include=TRUE, results="hide", echo=FALSE----------------------------------------------------------------------------------------------------
# conversion 1m = 3.28084 ft
chm_ft <- chm*3.28084

# plot 
plot(chm_ft, main="Lidar Canopy Height Model (in feet)")



## ----write-raster-to-geotiff, eval=FALSE, comment=NA-------------------------------------------------------------------------------------------------------------------------
# write out the CHM in tiff format. 
writeRaster(chm,paste0(wd,"chm_SJER.tif"),"GTiff")


