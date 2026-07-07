library(terra)

# set working directory
wd <- "~/data/"
setwd(wd)

# set api token
token <- Sys.getenv("NEON_TOKEN")

byTileAOP(dpID='DP3.30024.001', # lidar elevation
          site='HARV',
          year='2022',
          easting=732000,
          northing=4713500,
          check.size=FALSE, # set to TRUE to check the size before downloading
          savepath = wd,
          token=token)

# import raster into R
dsm_harv_file <- paste0(wd, "DP3.30024.001/neon-aop-products/2022/FullSite/D01/2022_HARV_7/L3/DiscreteLidar/DSMGtif/NEON_D01_HARV_DP3_732000_4713000_DSM.tif")
DSM_HARV <- rast(dsm_harv_file)

# Plot raster object
plot(DSM_HARV, main="Digital Surface Model - HARV")


# Plot distribution of raster values 
DSMhist<-hist(DSM_HARV,
     breaks=3,
     main="Histogram Digital Surface Model\n NEON Harvard Forest Field Site",
     col="lightblue",  # changes bin color
     xlab= "Elevation (m)")  # label the x-axis

# Where are breaks and how many pixels in each category?
DSMhist$breaks
DSMhist$counts


# plot using breaks.
plot(DSM_HARV, 
     breaks = c(300, 350, 400, 450), 
     col = terrain.colors(3),
     main="Digital Surface Model (DSM) - HARV")


# Assign color to a object for repeat use/ ease of changing
myCol = terrain.colors(3)

# Add axis labels
plot(DSM_HARV, 
     breaks = c(300, 350, 400, 450), 
     col = myCol,
     main="Digital Surface Model - HARV", 
     xlab = "UTM Easting (m)", 
     ylab = "UTM Northing (m)")

# or we can turn off the axis altogether
plot(DSM_HARV, 
     breaks = c(300, 350, 400, 450), 
     col = myCol,
     main="Digital Surface Model - HARV", 
     axes=FALSE)


# Find min & max
min(DSM_HARV)

# Break every 10m starting at 310
# Plot with 6 categories at even intervals across the pixel value range. 
plot(DSM_HARV, 
     breaks = seq(310, 440, by=10),  #define start & end, and interval
     col = terrain.colors(13),
      main="Digital Surface Model - HARV", 
     xlab = "Easting", 
     ylab = "Northing")


slope <- terrain(DSM_HARV, "slope", unit="radians")
aspect <- terrain(DSM_HARV, "aspect", unit="radians")
hill <- shade(slope, aspect, 45, 270)
plot(hill, col=grey(0:100/100), legend=FALSE, mar=c(2,2,1,4))
plot(DSM_HARV, col=terrain.colors(25, alpha=0.35), add=TRUE, main="HARV DSM with Hillshade")
