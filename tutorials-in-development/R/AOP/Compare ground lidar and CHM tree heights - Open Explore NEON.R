## ----install_packages, eval=FALSE------------------------------------------------------------------------
## 
## install.packages("neonUtilities")
## install.packages("sp")
## install.packages("raster")
## install.packages("devtools")
## devtools::install_github("NEONScience/NEON-geolocation/geoNEON")
## 


## ----load-packages, results="hide"-----------------------------------------------------------------------

library(sp)
library(raster)
library(neonUtilities)
library(geoNEON)
library(tidyverse)

options(stringsAsFactors=F)

# set working directory
# adapt directory path for your system
wd <- "~/data/LIDAR"
setwd(wd)


## ----veglist, results="hide"-----------------------------------------------------------------------------

## Download vegetation structure data for site - see https://data.neonscience.org/data-products/DP1.10098.001

veglist <- loadByProduct(dpID="DP1.10098.001", 
                         site="PUUM",
                         startdate="2019-01",
                         enddate="2019-12",
                         package="basic", 
                         check.size = FALSE)


## View the variables files to figure out which data table the spatial data are contained in
View(veglist$variables_10098) 

## Spatial data (decimalLatitude and decimalLongitude, etc) are in the vst_perplotperyear table
View(veglist$vst_perplotperyear)

## Data fields for stemDistance and stemAzimuth contain the distance and azimuth from a pointID to a specific stem
View(veglist$vst_mappingandtagging)


## ----vegmap, results="hide"------------------------------------------------------------------------------

## Use getLocTOS to calculate precise protocol-specific locations for each sampling effort

vegmap <- getLocTOS(veglist$vst_mappingandtagging, 
                          "vst_mappingandtagging")


## ----veg_merge-------------------------------------------------------------------------------------------

## Merge the mapped locations of individuals (the vst_mappingandtagging table) with the annual measurements of height, 
## diameter, etc. (the vst_apparentindividual table)

veg <- merge(veglist$vst_apparentindividual, vegmap, 
             by=c("individualID","namedLocation",
                  "domainID","siteID","plotID"))


## ----plot-1----------------------------------------------------------------------------------------------

## Make a stem map of the plants in plot PUUM_033. The circles argument of the symbols() function expects a radius, 
## but stemDiameter is a diameter, so need to divide by two. Also, stemDiameter is in centimeters, but the mapping scale
## is in meters, so need to divide by 100

symbols(veg$adjEasting[which(veg$plotID=="PUUM_033")], 
        veg$adjNorthing[which(veg$plotID=="PUUM_033")], 
        circles=veg$stemDiameter[which(veg$plotID=="PUUM_033")]/100/2, 
        inches=F, xlab="Easting", ylab="Northing")


## ----plot-2----------------------------------------------------------------------------------------------

## Overlay the estimated uncertainty in the location of each stem

symbols(veg$adjEasting[which(veg$plotID=="PUUM_033")], 
        veg$adjNorthing[which(veg$plotID=="PUUM_033")], 
        circles=veg$adjCoordinateUncertainty[which(veg$plotID=="PUUM_033")], 
        inches=F, add=T, fg="lightblue")


## ----get-chm, results="hide"-----------------------------------------------------------------------------

## Download the CHM tile corresponding to plot PUUM_033 and then load the tile into the environment

byTileAOP(dpID="DP3.30015.001", site="PUUM", year="2019", 
          easting=veg$adjEasting[which(veg$plotID=="PUUM_033")], 
          northing=veg$adjNorthing[which(veg$plotID=="PUUM_033")],
          check.size = FALSE, savepath=wd)

chm <- raster(paste0(wd, "/DP3.30015.001/2019/FullSite/D20/2019_PUUM_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D20_PUUM_DP3_256000_2163000_CHM.tif"))

## Download the DTM and DSM tiles corresponding to plot PUUM_033 and then load the DTM and DSM into the environment

byTileAOP(dpID="DP3.30024.001", site="PUUM", year="2019", 
          easting=veg$adjEasting[which(veg$plotID=="PUUM_033")], 
          northing=veg$adjNorthing[which(veg$plotID=="PUUM_033")],
          check.size = FALSE, savepath=wd)

dtm <- raster(paste0(wd, "/DP3.30024.001/2019/FullSite/D20/2019_PUUM_1/L3/DiscreteLidar/DTMGtif/NEON_D20_PUUM_DP3_256000_2163000_DTM.tif"))

dsm <- raster(paste0(wd, "/DP3.30024.001/2019/FullSite/D20/2019_PUUM_1/L3/DiscreteLidar/DSMGtif/NEON_D20_PUUM_DP3_256000_2163000_DSM.tif"))

## ----plot-chm--------------------------------------------------------------------------------------------

## Plot the CHM, DTM and DSM tiles

plot(chm, col=topo.colors(5))

plot(dtm, col=terrain.colors(25))

plot(dsm, col=hcl.colors(20))

## ----vegsub----------------------------------------------------------------------------------------------

## View the extent of chm and subset the vegetation structure table to only those individuals that fall within the extent of the CHM tile

extent(chm)

vegsub <- veg[which(veg$adjEasting >= extent(chm)[1] &
                      veg$adjEasting <= extent(chm)[2] &
                      veg$adjNorthing >= extent(chm)[3] & 
                      veg$adjNorthing <= extent(chm)[4]),]


## ----buffer-chm------------------------------------------------------------------------------------------

## Extract the CHM value that matches the coordinates of each mapped plant. Include a buffer equal to the uncertainty 
## in the plant's location, and extract the highest CHM value within the buffer. 

bufferCHM <- raster::extract(chm, 
                     cbind(vegsub$adjEasting,
                           vegsub$adjNorthing),
                     buffer=vegsub$adjCoordinateUncertainty, 
                     fun=max)


## ----scatterplot-buffer-chm------------------------------------------------------------------------------

## Create a scatterplot of each tree's height vs. the CHM value at its location 

plot(bufferCHM~vegsub$height, pch=20, xlab="VST canopy height", 
     ylab="Lidar canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----corr-buffer-----------------------------------------------------------------------------------------

## Strength of correlation between the ground and lidar measurements (low correlation)

cor(bufferCHM, vegsub$height, use="complete")


## ----round-x-y-------------------------------------------------------------------------------------------

## Filtering understory from dataset (map-centric vs. tree-centric)
## Approach #1: Use a map-centric approach to filter out understory: select a pixel size (e.g., 10m) and aggregate both 
## the vegetation structure data and the CHM  to find the tallest point in each pixel

    ## Use floor() instead of round() so each tree ends up in the pixel with the same numbering as the raster pixels 

easting10 <- 10*floor(vegsub$adjEasting/10)
northing10 <- 10*floor(vegsub$adjNorthing/10)
vegsub <- cbind(vegsub, easting10, northing10)


## ----vegbin----------------------------------------------------------------------------------------------

## Use the stats package version of the aggregate() function to get the tallest tree in each 10m bin

vegbin <- stats::aggregate(vegsub, by=list(vegsub$easting10, vegsub$northing10), FUN=max)

# symbols(vegbin$adjEasting[which(vegbin$plotID=="PUUM_033")], 
#         vegbin$adjNorthing[which(vegbin$plotID=="PUUM_033")], 
#         circles=vegbin$stemDiameter[which(vegbin$plotID=="PUUM_033")]/100/2, 
#         inches=F, xlab="Easting", ylab="Northing")

## ----CHM-10----------------------------------------------------------------------------------------------

## Use the raster package version of the aggregate() function to create a 10m resolution version of the CHM to match

CHM10 <- raster::aggregate(chm, fact=10, fun=max)
plot(CHM10, col=topo.colors(5))


## ----adj-tree-coord--------------------------------------------------------------------------------------

## Use the extract() function again to get the values from each pixel (uncertainty buffers no longer needed); 
## add 5 to each tree coordinate to make sure it's in the correct pixel since grids are numbered by the corners

vegbin$easting10 <- vegbin$easting10+5
vegbin$northing10 <- vegbin$northing10+5
binCHM <- raster::extract(CHM10, cbind(vegbin$easting10, 
                               vegbin$northing10))
plot(binCHM~vegbin$height, pch=20, 
     xlab="VST canopy height", ylab="Lidar canopy height model")
lines(c(0,50), c(0,50), col="grey")


## ----cor-2-----------------------------------------------------------------------------------------------

## Improved correlation between field measurements and CHM, but a lot of data has been lost  going to a lower resolution

cor(binCHM, vegbin$height, use="complete")


## ----vegsub-2--------------------------------------------------------------------------------------------

## Approach #2: Use trees as the starting point instead of map area. Start by sorting the veg structure data by height

vegsub <- vegsub[order(vegsub$height, decreasing=T),]


## ----vegfil----------------------------------------------------------------------------------------------

# For each tree, estimate which nearby trees might be beneath its canopy and discard those points:
        ## 1. Calculate the distance of each tree from the target tree
        ## 2. Pick a reasonable estimate for canopy size, and discard shorter trees within that radius (e.g., 0.3 times height)
        ## 3. Iterate over all trees

vegfil <- vegsub
for(i in 1:nrow(vegsub)) {
    if(is.na(vegfil$height[i]))
        next
    dist <- sqrt((vegsub$adjEasting[i]-vegsub$adjEasting)^2 + 
                (vegsub$adjNorthing[i]-vegsub$adjNorthing)^2)
    vegfil$height[which(dist<0.3*vegsub$height[i] & 
                        vegsub$height<vegsub$height[i])] <- NA
}

vegfil <- vegfil[which(!is.na(vegfil$height)),]


## ----filter-chm------------------------------------------------------------------------------------------

## Now extract the raster values, as above, increasing the buffer size to better account for the uncertainty 
## in the lidar data as well as the uncertainty in the ground locations

filterCHM <- raster::extract(chm, cbind(vegfil$adjEasting, vegfil$adjNorthing),
                         buffer=vegfil$adjCoordinateUncertainty+1, fun=max)
plot(filterCHM~vegfil$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")


## ----cor-3-----------------------------------------------------------------------------------------------

## Improved correlation between field measurements and CHM, filtering out most understory trees without losing 
## as many overstory trees

cor(filterCHM,vegfil$height)


## ----live-trees------------------------------------------------------------------------------------------

## The plantStatus field in the veg structure data indicates whether a plant is dead, broken, or otherwise damaged.
## It's possible but unlikely that dead stem is tallest structure, also less likely to get a good lidar return.
## Exclude trees that aren't alive

vegfil <- vegfil[which(vegfil$plantStatus=="Live"),]
filterCHM <- raster::extract(chm, cbind(vegfil$adjEasting, vegfil$adjNorthing),
                         buffer=vegfil$adjCoordinateUncertainty+1, fun=max)
plot(filterCHM~vegfil$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")


## ----cor-4-----------------------------------------------------------------------------------------------

## One stem removed, slight improvement in correlation stat

cor(filterCHM,vegfil$height)


