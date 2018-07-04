library(raster)
library(rhdf5)
library(rgdal)
library(neonAOP)
#load and plot data
chm <- raster("CHM.tif")
plot(soap.chm)
soap.chm[soap.chm==0]<-NA
density(chm)
plot(chm)
soap.chm[chm==0]<-NA
density(chm)

plot(sjer.chm)
hist(sjer.chm)
density(sjer.chm)
den.out <- density(sjer.chm)

str(den.out)

bins <- c(min(den.out$x),rep(peakx, each= 2), max(den.out$x))
bins.mat<- matrix(bins,ncol =2,byrow = TRUE)
bins.mat <-cbind(bins.mat,1:dim(bins.mat)[1])
bins.mat

sjer.chm.cut <- cut(sjer.chm, breaks = bins)
plot(sjer.chm.cut)
plot(sjer.chm.cut[sjer.chm.cut > 3])

?cut
bins

plot(sjer.chm.binned, 
	 col=rainbow(length(sjer.chm.binned[, 3])))

findInterval()
?findInterval
sapply(bins,function(x) abline(v=x,col="red"))

sapply(tim.min,function(x) abline(v=x,col="red"))

## writeRaster(asp.ns,
##             filename="outputs/TEAK/Teak_nsAspect.tif",
##             format="GTiff",
##             options="COMPRESS=LZW",
##             overwrite = TRUE,
##             NAflag = -9999)
## 

