teak_nsAspect <- raster("outputs/TEAK/TEAK_nsAspect.tif")
par(xpd = FALSE, mar=c(5.1, 4.1, 4.1, 4.5))

plot(teak_nsAspect,col=c("white","blue","green"),main="North and South Facing Slopes \n Lower Teakettle",legend=F)
par(xpd=TRUE)
legend((par()$usr[2]+20),4103300,legend=c("North","South"),fill=c("blue","green"),bty="n")
ndvi <- raster("NEONdata/D17-California/TEAK/2013/spectrometer/veg_index/TEAK_NDVI.tif")
ndvi

hist(ndvi,main="NDVI for Lower Teakettle Field Site")


writeRaster(nFacing.ndvi,#filename="outputs/TEAK/TEAK_n_ndvi6.tif",format="GTiff",options="COMPRESS=LZW",overwrite = TRUE,NAflag = -9999)

