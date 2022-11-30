## ----install_packages, eval=FALSE---------------------------------------------------------------------------
## 
## install.packages("neonUtilities")
## install.packages("neonOS")
## install.packages("sp")
## install.packages("raster")
## install.packages("devtools")
## devtools::install_github("NEONScience/NEON-geolocation/geoNEON")
## 


## ----load-packages, results="hide"--------------------------------------------------------------------------

library(sp)
library(raster)
library(neonUtilities)
library(neonOS)
library(geoNEON)

options(stringsAsFactors=F)

# set working directory
# adapt directory path for your system
wd <- "~/data"
setwd(wd)



## ----veglist, results="hide"--------------------------------------------------------------------------------

veglist <- loadByProduct(dpID="DP1.10098.001", 
                         site="WREF", 
                         package="basic", 
                         check.size = FALSE)



## ----vegmap, results="hide"---------------------------------------------------------------------------------

vegmap <- getLocTOS(veglist$vst_mappingandtagging, 
                          "vst_mappingandtagging")



## ----veg_merge----------------------------------------------------------------------------------------------

veg <- joinTableNEON(veglist$vst_apparentindividual, 
                     vegmap, 
                     name1="vst_apparentindividual",
                     name2="vst_mappingandtagging")



## ----plot-1-------------------------------------------------------------------------------------------------

symbols(veg$adjEasting[which(veg$plotID=="WREF_075")], 
        veg$adjNorthing[which(veg$plotID=="WREF_075")], 
        circles=veg$stemDiameter[which(veg$plotID=="WREF_075")]/100/2, 
        inches=F, xlab="Easting", ylab="Northing")



## ----plot-2-------------------------------------------------------------------------------------------------

symbols(veg$adjEasting[which(veg$plotID=="WREF_075")], 
        veg$adjNorthing[which(veg$plotID=="WREF_075")], 
        circles=veg$stemDiameter[which(veg$plotID=="WREF_075")]/100/2, 
        inches=F, xlab="Easting", ylab="Northing")
symbols(veg$adjEasting[which(veg$plotID=="WREF_075")], 
        veg$adjNorthing[which(veg$plotID=="WREF_075")], 
        circles=veg$adjCoordinateUncertainty[which(veg$plotID=="WREF_075")], 
        inches=F, add=T, fg="lightblue")



## ----get-chm, results="hide"--------------------------------------------------------------------------------

byTileAOP(dpID="DP3.30015.001", site="WREF", year="2017", 
          easting=veg$adjEasting[which(veg$plotID=="WREF_075")], 
          northing=veg$adjNorthing[which(veg$plotID=="WREF_075")],
          check.size=FALSE, savepath=wd)

chm <- raster(paste0(wd, "/DP3.30015.001/neon-aop-products/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif"))



## ----plot-chm-----------------------------------------------------------------------------------------------

plot(chm, col=topo.colors(5))



## ----vegsub-------------------------------------------------------------------------------------------------

vegsub <- veg[which(veg$adjEasting >= extent(chm)[1] &
                      veg$adjEasting <= extent(chm)[2] &
                      veg$adjNorthing >= extent(chm)[3] & 
                      veg$adjNorthing <= extent(chm)[4]),]



## ----buffer-chm---------------------------------------------------------------------------------------------

bufferCHM <- extract(chm, 
                     cbind(vegsub$adjEasting,
                           vegsub$adjNorthing),
                     buffer=vegsub$adjCoordinateUncertainty, 
                     fun=max)

plot(bufferCHM~vegsub$height, pch=20, xlab="Height", 
     ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----corr-buffer--------------------------------------------------------------------------------------------

cor(bufferCHM, vegsub$height, use="complete")



## ----round-x-y----------------------------------------------------------------------------------------------

easting10 <- 10*floor(vegsub$adjEasting/10)
northing10 <- 10*floor(vegsub$adjNorthing/10)
vegsub <- cbind(vegsub, easting10, northing10)



## ----vegbin-------------------------------------------------------------------------------------------------

vegbin <- stats::aggregate(vegsub, 
                           by=list(vegsub$easting10, 
                                   vegsub$northing10), 
                           FUN=max)



## ----CHM-10-------------------------------------------------------------------------------------------------

CHM10 <- raster::aggregate(chm, fact=10, fun=max)
plot(CHM10, col=topo.colors(5))



## ----adj-tree-coord-----------------------------------------------------------------------------------------

vegbin$easting10 <- vegbin$easting10 + 5
vegbin$northing10 <- vegbin$northing10 + 5
binCHM <- extract(CHM10, cbind(vegbin$easting10, 
                               vegbin$northing10))
plot(binCHM~vegbin$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----cor-2--------------------------------------------------------------------------------------------------

cor(binCHM, vegbin$height, use="complete")



## ----vegsub-2-----------------------------------------------------------------------------------------------

vegsub <- vegsub[order(vegsub$height, 
                       decreasing=T),]



## ----vegfil-------------------------------------------------------------------------------------------------

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



## ----filter-chm---------------------------------------------------------------------------------------------

filterCHM <- extract(chm, cbind(vegfil$adjEasting, vegfil$adjNorthing),
                         buffer=vegfil$adjCoordinateUncertainty+1, fun=max)
plot(filterCHM~vegfil$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----cor-3--------------------------------------------------------------------------------------------------

cor(filterCHM,vegfil$height)



## ----live-trees---------------------------------------------------------------------------------------------

vegfil <- vegfil[which(vegfil$plantStatus=="Live"),]
filterCHM <- extract(chm, cbind(vegfil$adjEasting, vegfil$adjNorthing),
                         buffer=vegfil$adjCoordinateUncertainty+1, fun=max)
plot(filterCHM~vegfil$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----cor-4--------------------------------------------------------------------------------------------------

cor(filterCHM,vegfil$height)


