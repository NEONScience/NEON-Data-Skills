## ----setup, eval=6, results="hide"-----------------------------------------------------------------------

# install and load raster package
# if raster is already installed, only the library() command 
# needs to be run
install.packages("raster")
library(raster)



## ----load-data, results="hide"---------------------------------------------------------------------------

flux.all <- read.csv("~/data/flux_allSites.csv")
flight.dates <- read.csv("~/data/flight_dates.csv")



## ----load-KONZ, eval=2:3, results="hide"-----------------------------------------------------------------

foot.KONZ <- raster("~/data/footKONZ2020-07.grd")
ndvi.KONZ <- raster("~/data/ndviKONZ2020-07.grd")

# if using Python and rasterio:
footKONZ = rasterio.open("/data/footKONZ2020-07.grd")
ndviKONZ = rasterio.open("/data/ndviKONZ2020-07.grd")



## ----plot-KONZ-NDVI--------------------------------------------------------------------------------------

plot(ndvi.KONZ)



## ----plot-KONZ-foot--------------------------------------------------------------------------------------

filledContour(foot.KONZ, col=topo.colors(20))



## ----plot-trimmed-foot-----------------------------------------------------------------------------------

footAdj <- calc(foot.KONZ, 
                 fun=function(x){ x[x < 0.0005] <- 0; 
                 return(x)})
footMost <- trim(footAdj, values=0)
filledContour(footMost, col=topo.colors(20))



## ----plot-foot-NDVI--------------------------------------------------------------------------------------

plot(ndvi.KONZ)
plot(foot.KONZ, add=T,
     col=terrain.colors(5, alpha=0.5))



## ----mean-NDVI-KONZ--------------------------------------------------------------------------------------

cellStats(ndvi.KONZ, stat="mean", na.rm=T)



## ----align-KONZ-rasters----------------------------------------------------------------------------------

ndvi.KONZ <- crop(ndvi.KONZ, extent(foot.KONZ))
foot.KONZ <- resample(foot.KONZ, ndvi.KONZ)



## ----level-KONZ-pixels-----------------------------------------------------------------------------------

foot.KONZ <- foot.KONZ/cellStats(foot.KONZ, 
                                 stat="sum", 
                                 na.rm=T)



## ----KONZ-weighted-NDVI----------------------------------------------------------------------------------

prop.weight <- foot.KONZ*ndvi.KONZ
cellStats(prop.weight, stat="sum", 
          na.rm=T)



## ----plot-KONZ-flux--------------------------------------------------------------------------------------

flux.all$timeBgn <- as.POSIXct(flux.all$timeBgn, 
                               format="%Y-%m-%d %H:%M:%S",
                               tz="GMT")
flux.KONZ <- flux.all[which(flux.all$siteID=="KONZ" & 
                      flux.all$timeBgn>=as.POSIXct("2020-07-11", 
                                                   tz="GMT") &
                      flux.all$timeBgn<as.POSIXct("2020-07-14", 
                                                   tz="GMT")),]
plot(flux.KONZ$data.fluxCo2.nsae.flux~flux.KONZ$timeBgn, 
     pch=20, xlab="Date", ylab="Net ecosystem exchange")



## ----weighted-NDVI-function------------------------------------------------------------------------------

foot.weighted <- function(ndvi.raster, foot.raster) {

  ndvi.foot <- crop(ndvi.raster, extent(foot.raster))
  foot.ndvi <- raster::resample(foot.raster, ndvi.foot)
  foot.ndvi <- foot.ndvi/cellStats(foot.ndvi, stat="sum", na.rm=T)
  comb <- foot.ndvi*ndvi.foot
  w.ndvi <- cellStats(comb, stat="sum", na.rm=T)
  return(w.ndvi)
  
}



## ----weighted-NDVI-loop----------------------------------------------------------------------------------

flight.dates$month <- substring(flight.dates$FlightDate, 1, 7)
ndvi.w <- character()
for(i in unique(flight.dates$Site)) {
  
  ffls <- list.files("~/data", "foot", full.names=T)
  afls <- list.files("~/data", "ndvi", full.names=T)
  ffls <- grep(".grd$", ffls, value=T)
  afls <- grep(".grd$", afls, value=T)

  flight.dates.i <- flight.dates[which(flight.dates$Site==i),]
  
  for(j in unique(flight.dates.i$month)) {
    
    footfl <- grep(i, ffls, value=T)
    footfl <- grep(j, footfl, value=T)
    if(length(footfl)==0) {next}
    nfl <- grep(i, afls, value=T)
    nfl <- grep(j, nfl, value=T)
    
    foot <- raster(footfl)
    ndvi <- raster(nfl)
    
    nw <- foot.weighted(ndvi, foot)
    ndvi.w <- rbind(ndvi.w, c(i, j, nw))
    
  }
  
}

ndvi.w <- data.frame(ndvi.w)
names(ndvi.w) <- c('site','month','ndvi')
ndvi.w$ndvi <- as.numeric(ndvi.w$ndvi)

ndvi.w



## ----flux-loop-------------------------------------------------------------------------------------------

ndvi.w$flux <- NA
flight.dates$FlightDate <- as.POSIXct(flight.dates$FlightDate, 
                                      tz="GMT")
for(i in 1:nrow(flight.dates)) {
  
  flux.sub <- flux.all[which(flux.all$siteID==
                               flight.dates$Site[i] & 
                        flux.all$timeBgn>=
                          I(flight.dates$FlightDate[i]-86400) &
                        flux.all$timeBgn<
                          I(flight.dates$FlightDate[i]+86400)),]
  fl <- mean(flux.sub$data.fluxCo2.nsae.flux, na.rm=T)
  ndvi.w$flux[which(ndvi.w$site==flight.dates$Site[i] & 
                      ndvi.w$month==flight.dates$month[i])] <- fl
  
}

# convert to units of grams of carbon per meter squared per day
ndvi.w$flux <- ndvi.w$flux*1e-6*12.011*86400



## ----plot-flux-NDVI--------------------------------------------------------------------------------------

plot(ndvi.w$flux~ndvi.w$ndvi, 
     xlab="NDVI", ylab="NEE",
     pch=20)



## ----plot-flux-NDVI-sites--------------------------------------------------------------------------------

plot(ndvi.w$flux~ndvi.w$ndvi, 
     xlab="NDVI", ylab="NEE",
     type="n", pch=20)
text(ndvi.w$ndvi, ndvi.w$flux,
     labels=ndvi.w$site, cex=0.5)



## ----dayflux-loop----------------------------------------------------------------------------------------

ndvi.w$dayflux <- NA
for(i in 1:nrow(flight.dates)) {
  
  flux.sub <- flux.all[which(flux.all$siteID==
                               flight.dates$Site[i] & 
                        flux.all$timeBgn>=
                          I(flight.dates$FlightDate[i]-86400) &
                        flux.all$timeBgn<
                          I(flight.dates$FlightDate[i]+86400)),]
  fl <- mean(flux.sub$data.fluxCo2.nsae.flux
             [which(flux.sub$data.fluxCo2.nsae.flux<0)], na.rm=T)
  ndvi.w$dayflux[which(ndvi.w$site==flight.dates$Site[i] & 
                      ndvi.w$month==flight.dates$month[i])] <- fl
  
}

ndvi.w$dayflux <- ndvi.w$dayflux*1e-6*12.011*86400



## ----plot-dayflux-NDVI-sites-----------------------------------------------------------------------------

plot(ndvi.w$dayflux~ndvi.w$ndvi, 
     xlab="NDVI", ylab="Daytime NEE",
     type="n", pch=20)
text(ndvi.w$ndvi, ndvi.w$dayflux,
     labels=ndvi.w$site, cex=0.5)


