## ----load-libraries, results="hide"----------------------------------------------------------------------------------------------------------------
library(terra)

# set working directory, you can change this if desired
wd <- "~/data/" 
setwd(wd)


## ----download-dsm-data, eval=FALSE-----------------------------------------------------------------------------------------------------------------
## byTileAOP(dpID='DP3.30024.001', # lidar elevation
##           site='HARV',
##           year='2022',
##           easting=732000,
##           northing=4713500,
##           check.size=FALSE, # set to TRUE or remove if you want to check the size before downloading
##           savepath = wd)


## ----open-raster, fig.cap="Digital surface model showing the elevation of NEON's site Harvard Forest"----------------------------------------------
# Load raster into R

dsm_harv_file <- paste0(wd, "DP3.30024.001/neon-aop-products/2022/FullSite/D01/2022_HARV_7/L3/DiscreteLidar/DSMGtif/NEON_D01_HARV_DP3_732000_4713000_DSM.tif")
DSM_HARV <- rast(dsm_harv_file)

# View raster structure
DSM_HARV 

# plot raster
# note \n in the title forces a line break in the title
plot(DSM_HARV, 
     main="Digital Surface Model - HARV")



## ----classified-elevation-map, fig.cap="Classified elevation map of NEON's site Harvard Forest", fig.width=10--------------------------------------
# add a color map with 5 colors
col=terrain.colors(3)
# add breaks to the colormap (4 breaks = 3 segments)
brk <- c(250,350, 380,500)

# Expand right side of clipping rect to make room for the legend
par(xpd = FALSE,mar=c(5.1, 4.1, 4.1, 4.5))
# DEM with a custom legend
plot(DSM_HARV, 
	col=col, 
	breaks=brk, 
	main="Classified Elevation Map - HARV",
	legend = FALSE
	)

# turn xpd back on to force the legend to fit next to the plot.
par(xpd = TRUE)
# add a legend - but make it appear outside of the plot
legend( 733100, 4713700,
        legend = c("High Elevation", "Middle","Low Elevation"), 
        fill = rev(col))


## ----view-crs--------------------------------------------------------------------------------------------------------------------------------------
# view crs description
crs(DSM_HARV,describe=TRUE)

# assign crs to an object (class) to use for reprojection and other tasks
harvCRS <- crs(DSM_HARV)



## ----resolution-units------------------------------------------------------------------------------------------------------------------------------
crs(DSM_HARV,proj=TRUE)


## ----view-min-max----------------------------------------------------------------------------------------------------------------------------------
# view the min and max values
min(DSM_HARV)


## ----download-rgb-data, eval=FALSE-----------------------------------------------------------------------------------------------------------------
## byTileAOP(dpID='DP3.30010.001',
##           site='HARV',
##           year='2022',
##           easting=737500,
##           northing=4701500,
##           check.size=FALSE, # set to TRUE or remove if you want to check the size before downloading
##           savepath = wd)


## ----demonstrate-no-data-black, fig.cap="Colorized raster image with NoDataValues around the edge rendered in black"-------------------------------
# Use rast function to read in all bands
RGB_HARV <- 
  rast(paste0(wd,"DP3.30010.001/neon-aop-products/2022/FullSite/D01/2022_HARV_7/L3/Camera/Mosaic/2022_HARV_7_737000_4701000_image.tif"))

# Create an RGB image from the raster
par(col.axis="white",col.lab="white",tck=0)
plotRGB(RGB_HARV, r = 1, g = 2, b = 3, 
        axes=TRUE, main="Raster With NoData Values Rendered in Black")



## ----demonstrate-no-data, fig.cap="Colorized raster image with NoDataValues around the edge removed"-----------------------------------------------
# reassign cells with 0,0,0 to NA
func <- function(x) {
  x[rowSums(x == 0) == 3, ] <- NA
  x}

newRGBImage <- app(RGB_HARV, func)

par(col.axis="white",col.lab="white",tck=0)
# Create an RGB image from the raster stack
plotRGB(newRGBImage, r = 1, g = 2, b = 3,
        axes=TRUE, main="Raster With No Data Values\nNoDataValue= NA")
 


## ----view-raster-histogram, fig.cap="Histogram showing the distribution of digital surface model values that has a default maximum pixels value of 100,000"----

# view histogram of data
hist(DSM_HARV,
     main="Distribution of Digital Surface Model Values\n Histogram Default: 100,000 pixels\n NEON Harvard Forest",
     xlab="DSM Elevation Value (m)",
     ylab="Frequency",
     col="lightblue")



## ----view-dsm-bands--------------------------------------------------------------------------------------------------------------------------------

# view number of bands in the Lidar DSM raster
nlyr(DSM_HARV)


## ----view-rgb-bands--------------------------------------------------------------------------------------------------------------------------------

# view number of bands in the RGB Camera raster
nlyr(RGB_HARV)



## ----describe-meta---------------------------------------------------------------------------------------------------------------------------------

# view metadata attributes before opening the file
describe(path.expand(dsm_harv_file),meta=TRUE)



## ----describe-stats--------------------------------------------------------------------------------------------------------------------------------

# view summary statistics before opening the file
describe(path.expand(dsm_harv_file),options=c("stats"))



## ----challenge-code-attributes, eval=FALSE, echo=FALSE---------------------------------------------------------------------------------------------
## dtm_harv_file <- paste0(wd, "DP3.30024.001/neon-aop-products/2022/FullSite/D01/2022_HARV_7/L3/DiscreteLidar/DTMGtif/NEON_D01_HARV_DP3_732000_4713000_DTM.tif")
## describe(path.expand(dtm_harv_file))
## 
## # ANSWERS ###
## # 1. If this file has the same CRS as DSM_HARV?  Yes: UTM Zone 18, WGS84, meters.
## # 2. What format `NoDataValues` take?  -9999
## # 3. The resolution of the raster data? 1x1 m
## # 4. Is the file a multi- or single-band raster?  Single
## # 5. On what dates was this site flown? Flown on 2022080312, 2022080412, 2022081213, 2022081413 (See the TIFFTAG_DATETIME tag)
## 

