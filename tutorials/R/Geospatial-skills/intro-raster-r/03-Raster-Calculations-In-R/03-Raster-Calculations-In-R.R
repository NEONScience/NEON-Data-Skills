## ----load-libraries----------------------------------------------------
# load raster package
library(raster)

# set working directory to ensure R can find the file we wish to import
wd <- "~/Git/data/" # this will depend on your local environment environment
# be sure that the downloaded file is in this directory
setwd(wd)

# view info about the dtm & dsm raster data that we will work with.
GDALinfo(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif"))
GDALinfo(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif"))



## ----load-plot-data, fig.cap=c("Digital terrain model showing the ground surface of NEON's site Harvard Forest","Digital surface model showing the elevation of NEON's site Harvard Forest")----
# load the DTM & DSM rasters
DTM_HARV <- raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif"))
DSM_HARV <- raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif"))

# create a quick plot of each to see what we're dealing with
plot(DTM_HARV,
     main="Digital Terrain Model \n NEON Harvard Forest Field Site")

plot(DSM_HARV,
     main="Digital Surface Model \n NEON Harvard Forest Field Site")


## ----raster-math, fig.cap="Canopy height model showing the height of the trees of NEON's site Harvard Forest"----
# Raster math example
CHM_HARV <- DSM_HARV - DTM_HARV 

# plot the output CHM
plot(CHM_HARV,
     main="Canopy Height Model - Raster Math Subtract\n NEON Harvard Forest Field Site",
     axes=FALSE) 



## ----create-hist, fig.cap="Histogram of canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest"----
# histogram of CHM_HARV
hist(CHM_HARV,
  col="springgreen4",
  main="Histogram of Canopy Height Model\nNEON Harvard Forest Field Site",
  ylab="Number of Pixels",
  xlab="Tree Height (m) ")



## ----challenge-code-CHM-HARV,  include=TRUE, results="hide", fig.cap=c("Histogram of canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest", "Histogram of canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest with six breaks", "Canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest with four breaks"), echo=FALSE----
# 1) 
minValue(CHM_HARV)
maxValue(CHM_HARV)
# 2) Looks at histogram, minValue(NAME)/maxValue(NAME), NAME and look at values
# slot. 
# 3
hist(CHM_HARV, 
     col="springgreen4",
     main = "Histogram of Canopy Height Model\nNEON Harvard Forest Field Site",
     maxpixels=ncell(CHM_HARV))
# 4 
hist(CHM_HARV, 
     col="lightgreen",
     main = "Histogram of Canopy Height Model\nNEON Harvard Forest Field Site",
     maxpixels=ncell(CHM_HARV),
     breaks=8)

# 5
myCol=terrain.colors(4)
plot(CHM_HARV,
     breaks=c(0,10,20,30),
     col=myCol,
     axes=F,
     main="Canopy Height Model \nNEON Harvard Forest Field Site")



## ----raster-overlay, fig.cap="Canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest produced by the overlay() function"----
CHM_ov_HARV<- overlay(DSM_HARV,
                      DTM_HARV,
                      fun=function(r1, r2){return(r1-r2)})

plot(CHM_ov_HARV,
  main="Canopy Height Model - Overlay Subtract\n NEON Harvard Forest Field Site")


## ----write-raster------------------------------------------------------
# export CHM object to new GeotIFF
writeRaster(CHM_ov_HARV, paste0(wd,"chm_HARV.tiff"),
            format="GTiff",  # specify output format - GeoTIFF
            overwrite=TRUE, # CAUTION: if this is true, it will overwrite an
                            # existing file
            NAflag=-9999) # set no data value to -9999



## ----challenge-code-SJER-CHM,include=TRUE, results="hide", fig.cap=c("Histogram of digital terrain model showing the distribution of the ground surface of NEON's site San Joaquin Experimental Range", "Histogram of digital surface model showing the distribution of the elevation of NEON's site San Joaquin Experimental Range", "Histogram of canopy height model showing the distribution of the height of the trees of NEON's site San Joaquin Experimental Range", "Canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest", "Histogram of canopy height model showing the distribution of the height of the trees of NEON's site Harvard Forest", "Histogram of canopy height model showing the distribution of the height of the trees of NEON's site San Joaquin Experimental Range"), echo=FALSE----
# 1.
# load the DTM
DTM_SJER <- raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/SJER/DTM/SJER_dtmCrop.tif"))
# load the DSM
DSM_SJER <- raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/SJER/DSM/SJER_dsmCrop.tif"))

# check CRS, units, etc
DTM_SJER
DSM_SJER

# check values
hist(DTM_SJER, 
     maxpixels=ncell(DTM_SJER),
     main="Digital Terrain Model - Histogram\n NEON SJER Field Site",
     col="slategrey",
     ylab="Number of Pixels",
     xlab="Elevation (m)")
hist(DSM_SJER, 
     maxpixels=ncell(DSM_SJER),
     main="Digital Surface Model - Histogram\n NEON SJER Field Site",
     col="slategray2",
     ylab="Number of Pixels",
     xlab="Elevation (m)")

# 2.
# use overlay to subtract the two rasters & create CHM
CHM_SJER <- overlay(DSM_SJER,DTM_SJER,
                    fun=function(r1, r2){return(r1-r2)})

hist(CHM_SJER, 
     main="Canopy Height Model - Histogram\n NEON SJER Field Site",
     col="springgreen4",
     ylab="Number of Pixels",
     xlab="Elevation (m)")

# 3
# plot the output
plot(CHM_SJER,
     main="Canopy Height Model - Overlay Subtract\n NEON SJER Field Site",
     axes=F)

# 4 
# Write to object to file
writeRaster(CHM_SJER,paste0(wd,"chm_ov_SJER.tiff"),
            format="GTiff", 
            overwrite=TRUE, 
            NAflag=-9999)

# 4.Tree heights are much shorter in SJER. 
# view histogram of HARV again. 
par(mfcol=c(2,1))
hist(CHM_HARV, 
     main="Canopy Height Model - Histogram\nNEON Harvard Forest Field Site",
     col="springgreen4",
      ylab="Number of Pixels",
     xlab="Elevation (m)")

hist(CHM_SJER, 
  main="Canopy Height Model - Histogram\nNEON SJER Field Site",
  col="slategrey", 
  ylab="Number of Pixels",
  xlab="Elevation (m)")


