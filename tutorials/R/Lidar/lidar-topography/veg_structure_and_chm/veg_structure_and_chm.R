options(stringsAsFactors=F)

install.packages("neonUtilities")
install.packages("sp")
install.packages("raster")
install.packages("devtools")
devtools::install_github("NEONScience/NEON-geolocation/geoNEON")

library(sp)
library(raster)
library(neonUtilities)
library(geoNEON)

veglist <- loadByProduct(dpID="DP1.10098.001", site="WREF", package="basic", check.size = FALSE)

vegmap <- getLocTOS(veglist$vst_mappingandtagging, 
                          "vst_mappingandtagging")

veg <- merge(veglist$vst_apparentindividual, vegmap, 
             by=c("individualID","namedLocation",
                  "domainID","siteID","plotID"))

symbols(veg$adjEasting[which(veg$plotID=="WREF_075")], 
        veg$adjNorthing[which(veg$plotID=="WREF_075")], 
        circles=veg$stemDiameter[which(veg$plotID=="WREF_075")]/100/2, 
        inches=F, xlab="Easting", ylab="Northing")

symbols(veg$adjEasting[which(veg$plotID=="WREF_075")], 
        veg$adjNorthing[which(veg$plotID=="WREF_075")], 
        circles=veg$stemDiameter[which(veg$plotID=="WREF_075")]/100/2, 
        inches=F, xlab="Easting", ylab="Northing")
symbols(veg$adjEasting[which(veg$plotID=="WREF_075")], 
        veg$adjNorthing[which(veg$plotID=="WREF_075")], 
        circles=veg$adjCoordinateUncertainty[which(veg$plotID=="WREF_075")], 
        inches=F, add=T, fg="lightblue")

byTileAOP(dpID="DP3.30015.001", site="WREF", year="2017", 
          easting=veg$adjEasting[which(veg$plotID=="WREF_075")], 
          northing=veg$adjNorthing[which(veg$plotID=="WREF_075")],
          check.size = FALSE, savepath="/Users/olearyd/Git/data")
chm <- raster("/Users/olearyd/Git/data/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")

plot(chm, col=topo.colors(5))

vegsub <- veg[which(veg$adjEasting >= extent(chm)[1] &
                      veg$adjEasting <= extent(chm)[2] &
                      veg$adjNorthing >= extent(chm)[3] & 
                      veg$adjNorthing <= extent(chm)[4]),]

bufferCHM <- extract(chm, cbind(vegsub$adjEasting, 
                                vegsub$adjNorthing),
                     buffer=vegsub$adjCoordinateUncertainty, 
                     fun=max)
plot(bufferCHM~vegsub$height, pch=20, xlab="Height", 
     ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")

cor(bufferCHM,vegsub$height, use="complete")

easting10 <- 10*floor(vegsub$adjEasting/10)
northing10 <- 10*floor(vegsub$adjNorthing/10)
vegsub <- cbind(vegsub, easting10, northing10)

vegbin <- stats::aggregate(vegsub, by=list(vegsub$easting10, vegsub$northing10), FUN=max)

CHM10 <- raster::aggregate(chm, fact=10, fun=max)
plot(CHM10, col=topo.colors(5))

vegbin$easting10 <- vegbin$easting10+5
vegbin$northing10 <- vegbin$northing10+5
binCHM <- extract(CHM10, cbind(vegbin$easting10, 
                               vegbin$northing10))
plot(binCHM~vegbin$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")

cor(binCHM, vegbin$height, use="complete")

vegsub <- vegsub[order(vegsub$height, decreasing=T),]

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

filterCHM <- extract(chm, cbind(vegfil$adjEasting, vegfil$adjNorthing),
                         buffer=vegfil$adjCoordinateUncertainty+1, fun=max)
plot(filterCHM~vegfil$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")

cor(filterCHM,vegfil$height)

vegfil <- vegfil[which(vegfil$plantStatus=="Live"),]
filterCHM <- extract(chm, cbind(vegfil$adjEasting, vegfil$adjNorthing),
                         buffer=vegfil$adjCoordinateUncertainty+1, fun=max)
plot(filterCHM~vegfil$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")

cor(filterCHM,vegfil$height)
