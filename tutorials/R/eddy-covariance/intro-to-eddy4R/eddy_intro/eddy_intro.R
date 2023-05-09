## ----install, eval=FALSE--------------------------------------------------------------------------------------
## 
## install.packages('BiocManager')
## BiocManager::install('rhdf5')
## install.packages('neonUtilities')
## 


## ----package-load---------------------------------------------------------------------------------------------

options(stringsAsFactors=F)

library(neonUtilities)



## ----download, results="hide", message=FALSE------------------------------------------------------------------

zipsByProduct(dpID="DP4.00200.001", package="basic", 
              site=c("NIWO", "HARV"), 
              startdate="2018-06", enddate="2018-07",
              savepath="~/Downloads", 
              check.size=F)



## ----stack-dp04, results="hide"-------------------------------------------------------------------------------

flux <- stackEddy(filepath="~/Downloads/filesToStack00200",
                 level="dp04")



## ----see-names------------------------------------------------------------------------------------------------

names(flux)



## ----flux-head------------------------------------------------------------------------------------------------

head(flux$NIWO)



## ----obj-desc-terms-------------------------------------------------------------------------------------------

term <- unlist(strsplit(names(flux$NIWO), split=".", fixed=T))
flux$objDesc[which(flux$objDesc$Object %in% term),]



## ----see-variables--------------------------------------------------------------------------------------------

flux$variables



## ----plot-fluxes----------------------------------------------------------------------------------------------

plot(flux$NIWO$data.fluxCo2.nsae.flux~flux$NIWO$timeBgn, 
     pch=".", xlab="Date", ylab="CO2 flux")



## ----plot-two-days--------------------------------------------------------------------------------------------

plot(flux$NIWO$data.fluxCo2.nsae.flux~flux$NIWO$timeBgn, 
     pch=20, xlab="Date", ylab="CO2 flux",
     xlim=c(as.POSIXct("2018-07-07", tz="GMT"),
            as.POSIXct("2018-07-09", tz="GMT")),
    ylim=c(-20,20), xaxt="n")
axis.POSIXct(1, x=flux$NIWO$timeBgn, 
             format="%Y-%m-%d %H:%M:%S")



## ----download-par, results="hide"-----------------------------------------------------------------------------

pr <- loadByProduct("DP1.00024.001", site="NIWO", 
                    timeIndex=30, package="basic", 
                    startdate="2018-06", enddate="2018-07",
                    check.size=F)



## ----get-tower-top--------------------------------------------------------------------------------------------

pr.top <- pr$PARPAR_30min[which(pr$PARPAR_30min$verticalPosition==
                                max(pr$PARPAR_30min$verticalPosition)),]



## ----time-stamp-match-----------------------------------------------------------------------------------------

pr.top$timeBgn <- pr.top$startDateTime



## ----merge----------------------------------------------------------------------------------------------------

fx.pr <- merge(pr.top, flux$NIWO, by="timeBgn")



## ----plot-par-flux--------------------------------------------------------------------------------------------

plot(fx.pr$data.fluxCo2.nsae.flux~fx.pr$PARMean,
     pch=".", ylim=c(-20,20),
     xlab="PAR", ylab="CO2 flux")



## ----stack-dp03, results="hide", message=FALSE----------------------------------------------------------------

prof <- stackEddy(filepath="~/Downloads/filesToStack00200/",
                 level="dp03")



## ----head-dp03------------------------------------------------------------------------------------------------

head(prof$NIWO)



## ----stack-dp02, results="hide", message=FALSE----------------------------------------------------------------

prof.l2 <- stackEddy(filepath="~/Downloads/filesToStack00200/",
                 level="dp02")



## ----head-dp02------------------------------------------------------------------------------------------------

head(prof.l2$HARV)



## ----get-vars-------------------------------------------------------------------------------------------------

vars <- getVarsEddy("~/Downloads/filesToStack00200/NEON.D01.HARV.DP4.00200.001.nsae.2018-07.basic.20201020T201317Z.h5")
head(vars)



## ----stack-dp01, results="hide", message=FALSE----------------------------------------------------------------

iso <- stackEddy(filepath="~/Downloads/filesToStack00200/",
               level="dp01", var=c("rtioMoleDryCo2","rtioMoleDryH2o",
                                   "dlta13CCo2","dlta18OH2o"), avg=30)



## ----head-dp01------------------------------------------------------------------------------------------------

head(iso$HARV)



## ----get-one-day, warning=FALSE-------------------------------------------------------------------------------

iso.d <- iso$HARV[grep("2018-06-25", iso$HARV$timeBgn, fixed=T),]
iso.d <- iso.d[-which(is.na(as.numeric(iso.d$verticalPosition))),]



## ----gg, results="hide", message=FALSE------------------------------------------------------------------------

library(ggplot2)



## ----plot-co2-profile, message=FALSE, warning=FALSE-----------------------------------------------------------

g <- ggplot(iso.d, aes(y=verticalPosition)) + 
  geom_path(aes(x=data.co2Stor.rtioMoleDryCo2.mean, 
                group=timeBgn, col=timeBgn)) + 
  theme(legend.position="none") + 
  xlab("CO2") + ylab("Tower level")
g



## ----plot-iso-profile, message=FALSE, warning=FALSE-----------------------------------------------------------

g <- ggplot(iso.d, aes(y=verticalPosition)) + 
  geom_path(aes(x=data.isoCo2.dlta13CCo2.mean, 
                group=timeBgn, col=timeBgn)) + 
  theme(legend.position="none") + 
  xlab("d13C") + ylab("Tower level")
g


