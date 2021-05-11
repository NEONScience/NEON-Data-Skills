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

options(stringsAsFactors=F)

# set working directory
# adapt directory path for your system
wd <- "~/Downloads/"
setwd(wd)



## ----veglist, results="hide"-----------------------------------------------------------------------------

veglist <- loadByProduct(dpID="DP1.10098.001", 
                         site="PUUM", 
                         package="basic", 
                         check.size = FALSE)



## ----vegmap, results="hide"------------------------------------------------------------------------------

vegmap <- getLocTOS(veglist$vst_mappingandtagging, 
                          "vst_mappingandtagging")



## ----veg_merge-------------------------------------------------------------------------------------------

veg <- merge(veglist$vst_apparentindividual, vegmap, 
             by=c("individualID","namedLocation",
                  "domainID","siteID","plotID"))



## ----plot-1----------------------------------------------------------------------------------------------

symbols(veg$adjEasting[which(veg$plotID=="PUUM_036")], 
        veg$adjNorthing[which(veg$plotID=="PUUM_036")], 
        circles=veg$stemDiameter[which(veg$plotID=="PUUM_036")]/100/2, 
        inches=F, xlab="Easting", ylab="Northing")



## ----plot-2----------------------------------------------------------------------------------------------

symbols(veg$adjEasting[which(veg$plotID=="PUUM_036")], 
        veg$adjNorthing[which(veg$plotID=="PUUM_036")], 
        circles=veg$stemDiameter[which(veg$plotID=="PUUM_036")]/100/2, 
        inches=F, xlab="Easting", ylab="Northing")
symbols(veg$adjEasting[which(veg$plotID=="PUUM_036")], 
        veg$adjNorthing[which(veg$plotID=="PUUM_036")], 
        circles=veg$adjCoordinateUncertainty[which(veg$plotID=="PUUM_036")], 
        inches=F, add=T, fg="lightblue")



## ----get-chm, results="hide"-----------------------------------------------------------------------------

byTileAOP(dpID="DP3.30015.001", site="PUUM", year="2019", 
          easting=veg$adjEasting[which(veg$plotID=="PUUM_036")], 
          northing=veg$adjNorthing[which(veg$plotID=="PUUM_036")],
          check.size = FALSE, savepath=wd)

chm <- raster(paste0(wd, "DP3.30015.001/2019/FullSite/D20/2019_PUUM_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D20_PUUM_DP3_256000_2163000_CHM.tif"))



## ----plot-chm--------------------------------------------------------------------------------------------

plot(chm, col=topo.colors(5))

# Overlay the measured trees on top of this CHM
points(veg$adjEasting, veg$adjNorthing, pch=20)


## ----vegsub----------------------------------------------------------------------------------------------

vegsub <- veg[which(veg$adjEasting >= extent(chm)[1] &
                      veg$adjEasting <= extent(chm)[2] &
                      veg$adjNorthing >= extent(chm)[3] & 
                      veg$adjNorthing <= extent(chm)[4]),]



## ----buffer-chm------------------------------------------------------------------------------------------

bufferCHM <- extract(chm, 
                     cbind(vegsub$adjEasting,
                           vegsub$adjNorthing),
                     buffer=vegsub$adjCoordinateUncertainty, 
                     fun=max)

plot(bufferCHM~vegsub$height, pch=20, xlab="Height", 
     ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")


## ----corr-buffer-----------------------------------------------------------------------------------------

cor(bufferCHM, vegsub$height, use="complete")


## Looks like there is a erronious data point - 
# a 66m tall tree in PUUM is impossible!
# Check the histogram of tree heights to see outlier
hist(vegsub$height)
# Let's remove that point:
vegsub = vegsub[vegsub$height<60,]
# Check histogram again:
hist(vegsub$height)
# Much better.

## ----round-x-y-------------------------------------------------------------------------------------------

easting10 <- 10*floor(vegsub$adjEasting/10)
northing10 <- 10*floor(vegsub$adjNorthing/10)
vegsub <- cbind(vegsub, easting10, northing10)



## ----vegbin----------------------------------------------------------------------------------------------

vegbin <- stats::aggregate(vegsub, by=list(vegsub$easting10, vegsub$northing10), FUN=max)



## ----CHM-10----------------------------------------------------------------------------------------------

CHM10 <- raster::aggregate(chm, fact=10, fun=max)
plot(CHM10, col=topo.colors(5))



## ----adj-tree-coord--------------------------------------------------------------------------------------

vegbin$easting10 <- vegbin$easting10+5
vegbin$northing10 <- vegbin$northing10+5
binCHM <- extract(CHM10, cbind(vegbin$easting10, 
                               vegbin$northing10))
plot(binCHM~vegbin$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----cor-2-----------------------------------------------------------------------------------------------

cor(binCHM, vegbin$height, use="complete")



## ----vegsub-2--------------------------------------------------------------------------------------------

vegsub <- vegsub[order(vegsub$height, decreasing=T),]



## ----vegfil----------------------------------------------------------------------------------------------

# The two dominant canopy trees at this site are:
# Acacia koa
# Metrosideros polymorpha
# Both of which can grow to ~30m and have a wide canopy spread
# approximately equal to the tree's height in some circumstances
# Therefore, we adjust the allometry to remove trees within a radius of
# 0.5 of the tree's height to ensure that we remove understory trees

vegfil <- vegsub
for(i in 1:nrow(vegsub)) {
    if(is.na(vegfil$height[i]))
        next
    dist <- sqrt((vegsub$adjEasting[i]-vegsub$adjEasting)^2 + 
                (vegsub$adjNorthing[i]-vegsub$adjNorthing)^2)
    vegfil$height[which(dist<0.5*vegsub$height[i] & 
                        vegsub$height<vegsub$height[i])] <- NA
}

vegfil <- vegfil[which(!is.na(vegfil$height)),]



## ----filter-chm------------------------------------------------------------------------------------------

filterCHM <- extract(chm, cbind(vegfil$adjEasting, vegfil$adjNorthing),
                         buffer=vegfil$adjCoordinateUncertainty+1, fun=max)
plot(filterCHM~vegfil$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----cor-3-----------------------------------------------------------------------------------------------

cor(filterCHM,vegfil$height)



## ----live-trees------------------------------------------------------------------------------------------

vegfil <- vegfil[which(vegfil$plantStatus=="Live"),]
filterCHM <- extract(chm, cbind(vegfil$adjEasting, vegfil$adjNorthing),
                         buffer=vegfil$adjCoordinateUncertainty+1, fun=max)
plot(filterCHM~vegfil$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----cor-4-----------------------------------------------------------------------------------------------

cor(filterCHM,vegfil$height)


