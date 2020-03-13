## ----load-libraries------------------------------------------------------

# load packages
library(rgdal)  # for vector work; sp package should always load with rgdal. 
library (raster)   # for metadata/attributes- vectors or rasters

# set working directory to data folder
# setwd("pathToDirHere")


## ----read-csv------------------------------------------------------------

# Read the .csv file
State.Boundary.US <- readOGR("NEON-DS-Site-Layout-Files/US-Boundary-Layers",
          "US-State-Boundaries-Census-2014")

# look at the data structure
class(State.Boundary.US)


## ----find-coordinates----------------------------------------------------

# view column names
plot(State.Boundary.US, 
     main="Map of Continental US State Boundaries\n US Census Bureau Data")


## ----check-out-coordinates-----------------------------------------------
# Read the .csv file
Country.Boundary.US <- readOGR("NEON-DS-Site-Layout-Files/US-Boundary-Layers",
          "US-Boundary-Dissolved-States")

# look at the data structure
class(Country.Boundary.US)

# view column names
plot(State.Boundary.US, 
     main="Map of Continental US State Boundaries\n US Census Bureau Data",
     border="gray40")

# view column names
plot(Country.Boundary.US, 
     lwd=4, 
     border="gray18",
     add=TRUE)


## ----explore-units-------------------------------------------------------

# Import a point shapefile 
point_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
                      "HARVtower_UTM18N")
class(point_HARV)

# plot point - looks ok? 
plot(point_HARV, 
     pch = 19, 
     col = "purple",
     main="Harvard Fisher Tower Location")

## ----layer-point-on-states-----------------------------------------------
# plot state boundaries  
plot(State.Boundary.US, 
     main="Map of Continental US State Boundaries \n with Tower Location",
     border="gray40")

# add US border outline 
plot(Country.Boundary.US, 
     lwd=4, 
     border="gray18",
     add=TRUE)

# add point tower location
plot(point_HARV, 
     pch = 19, 
     col = "purple",
     add=TRUE)


## ----crs-sleuthing-------------------------------------------------------

# view CRS of our site data
crs(point_HARV)

# view crs of census data
crs(State.Boundary.US)
crs(Country.Boundary.US)

## ----view-extent---------------------------------------------------------

# extent for HARV in UTM
extent(point_HARV)

# extent for object in geographic
extent(State.Boundary.US)


## ----crs-sptranform------------------------------------------------------

# reproject data
point_HARV_WGS84 <- spTransform(point_HARV,
                                crs(State.Boundary.US))

# what is the CRS of the new object
crs(point_HARV_WGS84)
# does the extent look like decimal degrees?
extent(point_HARV_WGS84)

## ----plot-again----------------------------------------------------------

# plot state boundaries  
plot(State.Boundary.US, 
     main="Map of Continental US State Boundaries\n With Fisher Tower Location",
     border="gray40")

# add US border outline 
plot(Country.Boundary.US, 
     lwd=4, 
     border="gray18",
     add=TRUE)

# add point tower location
plot(point_HARV_WGS84, 
     pch = 19, 
     col = "purple",
     add=TRUE)


## ----challenge-code-MASS-Map,  include=TRUE, results="hide", echo=FALSE, warning=FALSE----
# import mass boundary layer
# read the .csv file
NE.States.Boundary.US <- readOGR("NEON-DS-Site-Layout-Files/US-Boundary-Layers",
          "Boundary-US-State-NEast")
# view crs
crs(NE.States.Boundary.US)

# create CRS object
UTM_CRS <- crs(point_HARV)
UTM_CRS

# reproject line and point data
NE.States.Boundary.US.UTM  <- spTransform(NE.States.Boundary.US,
                                UTM_CRS)
NE.States.Boundary.US.UTM

# plot state boundaries  
plot(NE.States.Boundary.US.UTM , 
     main="Map of Northeastern US\n With Fisher Tower Location - UTM Zone 18N",
     border="gray18",
     lwd=2)

# add point tower location
plot(point_HARV, 
     pch = 19, 
     col = "purple",
     add=TRUE)

# add legend
# to create a custom legend, we need to fake it
legend("bottomright", 
       legend=c("State Boundary","Fisher Tower"),
       lty=c(1,NA),
       pch=c(NA,19),
       col=c("gray18","purple"),
       bty="n")


