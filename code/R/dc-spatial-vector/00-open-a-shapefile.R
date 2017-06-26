## ----load-libraries------------------------------------------------------

# load required libraries
# for vector work; sp package will load with rgdal.
library(rgdal)  
# for metadata/attributes- vectors or rasters
library(raster) 

# set working directory to the directory location on your computer where
# you downloaded and unzipped the data files for the tutorial
# setwd("pathToDirHere")

## ----Import-Shapefile----------------------------------------------------

# Import a polygon shapefile: readOGR("path","fileName")
# no extension needed as readOGR only imports shapefiles
aoiBoundary_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV",
                            "HarClip_UTMZ18")


## ----view-metadata-------------------------------------------------------
# view just the class for the shapefile
class(aoiBoundary_HARV)

# view just the crs for the shapefile
crs(aoiBoundary_HARV)

# view just the extent for the shapefile
extent(aoiBoundary_HARV)

# view all metadata at same time
aoiBoundary_HARV

## ----Shapefile-attributes-2----------------------------------------------
# alternate way to view attributes 
aoiBoundary_HARV@data


## ----shapefile-summary---------------------------------------------------
# view a summary of metadata & attributes associated with the spatial object
summary(aoiBoundary_HARV)


## ----plot-shapefile------------------------------------------------------
# create a plot of the shapefile
# 'lwd' sets the line width
# 'col' sets internal color
# 'border' sets line color
plot(aoiBoundary_HARV, col="cyan1", border="black", lwd=3,
     main="AOI Boundary Plot")


## ----import-point-line, echo=FALSE, results="hide"-----------------------
# import line shapefile
lines_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV",layer = "HARV_roads")
# import point shapefile
point_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV", layer="HARVtower_UTM18N")

# 1
class(lines_HARV)
class(point_HARV)

# 2
crs(lines_HARV)
extent(lines_HARV)
crs(point_HARV)
extent(point_HARV)

# 3 
#lines_HARV contains only lines and point_HARV contains only 1 point

# 4 -> numerous ways to find this; lines_HARV=13,
length(lines_HARV)  #easiest, but not previously taught
lines_HARV  #look at 'features'
attributes(lines_HARV)  #found in the $data section as above

# Alternative code for 1-4: view metadata/attributes all at once
lines_HARV
attributes(lines_HARV)


## ----plot-multiple-shapefiles--------------------------------------------
# Plot multiple shapefiles
plot(aoiBoundary_HARV, col = "lightgreen", 
     main="NEON Harvard Forest\nField Site")
plot(lines_HARV, add = TRUE)

# use the pch element to adjust the symbology of the points
plot(point_HARV, add  = TRUE, pch = 19, col = "purple")

## ----challenge-vector-raster-overlay, echo=FALSE-------------------------

# import CHM
chm_HARV <- raster("NEON-DS-Airborne-Remote-Sensing/HARV/CHM/HARV_chmCrop.tif")

plot(chm_HARV,
     main="Map of Study Area\n w/ Canopy Height Model\nNEON Harvard Forest Field Site")

plot(lines_HARV, 
     add = TRUE,
     col="black")
plot(aoiBoundary_HARV, border="grey20", 
     add = TRUE,
     lwd=4)
plot(point_HARV, pch=8, 
     add=TRUE)


