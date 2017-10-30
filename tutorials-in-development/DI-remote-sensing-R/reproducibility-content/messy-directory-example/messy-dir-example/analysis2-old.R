library(raster)
library(rhdf5)

library(neonAOP)
# NDVI data
ndvi <- raster("NEONdata/D17-California/TEAK/2013/spectrometer/veg_index/TEAK_NDVI.tif")
ndvi

hist(ndvi,main="NDVI for Lower Teakettle Field Site")
ndvi[ndvi<.6] <- NA
plot(ndvi,main="NDVI > .6")
n.face.aspect <- teak_nsAspect==1

nFacing.ndvi <- mask(n.face.aspect, ndvi)

plot(nFacing.ndvi,main="North Facing Locations \n NDVI > .6",legend=F)

