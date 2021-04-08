## ----load-libraries----------------------------------------------------
# load raster package
library(raster)
library(rgdal)

# set working directory to ensure R can find the file we wish to import
wd <- "~/Git/data/" # this will depend on your local environment
# be sure that the downloaded file is in this directory
setwd(wd)




## ----import-DTM-hillshade, fig.cap="Digital terrain model overlaying the hillshade raster showing the 3D ground surface of NEON's site Harvard Forest"----
# import DTM
DTM_HARV <- raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif"))
# import DTM hillshade
DTM_hill_HARV <- 
  raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_DTMhill_WGS84.tif"))

# plot hillshade using a grayscale color ramp 
plot(DTM_hill_HARV,
    col=grey(1:100/100),
    legend=FALSE,
    main="DTM Hillshade\n NEON Harvard Forest Field Site")

# overlay the DTM on top of the hillshade
plot(DTM_HARV,
     col=terrain.colors(10),
     alpha=0.4,
     add=TRUE,
     legend=FALSE)



## ----plot-DTM, fig.cap="Digital terrain model showing the ground surface of NEON's site Harvard Forest"----
# Plot DTM 
plot(DTM_HARV,
     col=terrain.colors(10),
     alpha=1,
     legend=F,
     main="Digital Terrain Model\n NEON Harvard Forest Field Site")



## ----explore-crs-------------------------------------------------------
# view crs for DTM
crs(DTM_HARV)

# view crs for hillshade
crs(DTM_hill_HARV)


## ----reproject-raster--------------------------------------------------

# reproject to UTM
DTM_hill_UTMZ18N_HARV <- projectRaster(DTM_hill_HARV, 
                                       crs=crs(DTM_HARV))

# compare attributes of DTM_hill_UTMZ18N to DTM_hill
crs(DTM_hill_UTMZ18N_HARV)
crs(DTM_hill_HARV)

# compare attributes of DTM_hill_UTMZ18N to DTM_hill
extent(DTM_hill_UTMZ18N_HARV)
extent(DTM_hill_HARV)



## ----challenge-code-extent-crs, echo=FALSE-----------------------------
# The extent for DTM_hill_UTMZ18N_HARV is in UTMs so the extent is in meters. 
# The extent for DTM_hill_HARV is still in lat/long so the extent is expressed
# in decimal degrees.  


## ----view-resolution---------------------------------------------------

# compare resolution
res(DTM_hill_UTMZ18N_HARV)



## ----reproject-assign-resolution, fig.cap="Reprojected digital terrain model overlaying the hillshade raster showing the 3D ground surface of NEON's site Harvard Forest"----
# adjust the resolution 
DTM_hill_UTMZ18N_HARV <- projectRaster(DTM_hill_HARV, 
                                  crs=crs(DTM_HARV),
                                  res=1)
# view resolution
res(DTM_hill_UTMZ18N_HARV)



## ----plot-projected-raster---------------------------------------------
# plot newly reprojected hillshade
plot(DTM_hill_UTMZ18N_HARV,
    col=grey(1:100/100),
    legend=F,
    main="DTM with Hillshade\n NEON Harvard Forest Field Site")

# overlay the DTM on top of the hillshade
plot(DTM_HARV,
     col=terrain.colors(100),
     alpha=0.4,
     add=T,
     legend=F)


## ----challenge-code-reprojection, fig.cap="Digital terrain model overlaying the hillshade raster showing the 3D ground surface of NEON's site San Joaquin Experimental Range", echo=FALSE----

# import DTM
DTM_SJER <- raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/SJER/DTM/SJER_dtmCrop.tif"))
# import DTM hillshade
DTM_hill_SJER <- 
  raster(paste0(wd,"NEON-DS-Airborne-Remote-Sensing/SJER/DTM/SJER_dtmHill.tif"))

# reproject raster 
DTM_hill_UTMZ18N_SJER <- projectRaster(DTM_hill_SJER, 
                                  crs=crs(DTM_SJER),
                                  res=1)
# plot hillshade using a grayscale color ramp 
plot(DTM_hill_UTMZ18N_SJER,
    col=grey(1:100/100),
    legend=F,
    main="DTM with Hillshade\n NEON SJER Field Site")

# overlay the DSM on top of the hillshade
plot(DTM_SJER,
     col=terrain.colors(10),
     alpha=0.4,
     add=T,
     legend=F)



## ----challenge-code-reprojection2, echo=FALSE--------------------------
# The maps look identical. Which is what they should be as the only difference
# is this one was reprojected from WGS84 to UTM prior to plotting.  

