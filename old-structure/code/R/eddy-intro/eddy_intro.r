install.packages('BiocManager')
BiocManager::install('rhdf5')
install.packages('neonUtilities')

options(stringsAsFactors=F)

library(neonUtilities)

zipsByProduct(dpID="DP4.00200.001", package="basic", 
              site=c("NIWO", "HARV"), 
              startdate="2018-06", enddate="2018-07",
              savepath="/data", 
              check.size=F)

flux <- stackEddy(filepath="/data/filesToStack00200/",
                 level="dp04")

names(flux)

head(flux$NIWO)

term <- unlist(strsplit(names(flux$NIWO), split=".", fixed=T))
flux$objDesc[which(flux$objDesc$Object %in% term),]

flux$variables

timeB <- as.POSIXct(flux$NIWO$timeBgn, 
                    format="%Y-%m-%dT%H:%M:%S", 
                    tz="GMT")
flux$NIWO <- cbind(timeB, flux$NIWO)

plot(flux$NIWO$data.fluxCo2.nsae.flux~timeB, 
     pch=".", xlab="Date", ylab="CO2 flux",
     xaxt="n")
axis.POSIXct(1, x=timeB, format="%Y-%m-%d")

plot(flux$NIWO$data.fluxCo2.nsae.flux~timeB, 
     pch=20, xlab="Date", ylab="CO2 flux",
     xlim=c(as.POSIXct("2018-07-07", tz="GMT"),
            as.POSIXct("2018-07-09", tz="GMT")),
    ylim=c(-20,20), xaxt="n")
axis.POSIXct(1, x=timeB, format="%Y-%m-%d %H:%M:%S")

pr <- loadByProduct("DP1.00024.001", site="NIWO", avg=30,
                    startdate="2018-06", enddate="2018-07",
                    package="basic", check.size=F)

pr.top <- pr$PARPAR_30min[which(pr$PARPAR_30min$verticalPosition==
                                max(pr$PARPAR_30min$verticalPosition)),]

timeB <- pr.top$startDateTime
pr.top <- cbind(timeB, pr.top)

fx.pr <- merge(pr.top, flux$NIWO, by="timeB")

plot(fx.pr$data.fluxCo2.nsae.flux~fx.pr$PARMean,
     pch=".", ylim=c(-20,20),
     xlab="PAR", ylab="CO2 flux")

prof <- stackEddy(filepath="/data/filesToStack00200/",
                 level="dp03")

head(prof$NIWO)

prof.l2 <- stackEddy(filepath="/data/filesToStack00200/",
                 level="dp02")

head(prof.l2$HARV)

vars <- getVarsEddy("/data/filesToStack00200/NEON.D01.HARV.DP4.00200.001.nsae.2018-07.basic.h5")
head(vars)

iso <- stackEddy(filepath="/data/filesToStack00200/",
               level="dp01", var=c("rtioMoleDryCo2","rtioMoleDryH2o",
                                   "dlta13CCo2","dlta18OH2o"), avg=30)

head(iso$HARV)

iso.d <- iso$HARV[grep("2018-06-25", iso$HARV$timeBgn, fixed=T),]
iso.d <- iso.d[-which(is.na(as.numeric(iso.d$verticalPosition))),]

library(ggplot2)

g <- ggplot(iso.d, aes(y=verticalPosition)) + 
  geom_path(aes(x=data.co2Stor.rtioMoleDryCo2.mean, 
                group=timeBgn, col=timeBgn)) + 
  theme(legend.position="none") + 
  xlab("CO2") + ylab("Tower level")
g

g <- ggplot(iso.d, aes(y=verticalPosition)) + 
  geom_path(aes(x=data.isoCo2.dlta13CCo2.mean, 
                group=timeBgn, col=timeBgn)) + 
  theme(legend.position="none") + 
  xlab("d13C") + ylab("Tower level")
g


