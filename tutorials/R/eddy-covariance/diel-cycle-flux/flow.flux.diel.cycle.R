## ----install, eval=FALSE--------------------------------------------------------------------------------------
## 
## install.packages('BiocManager')
## BiocManager::install('rhdf5')
## install.packages('neonUtilities')
## 


## ----package-load---------------------------------------------------------------------------------------------



install.packages('BiocManager')
BiocManager::install('rhdf5')
install.packages('neonUtilities')
install.packages('ggplot2')


options(stringsAsFactors=F)

library(neonUtilities)
library(ggplot2)
dateBgn <- "2021-12-01"
dateEnd <- "2022-12-31"

#Site
site <- c("STEI", "TREE")

#File directory
dirFile <- c(tempdir(),"/home/ddurden/eddy/tmp/tutorial")[2]

## ----download, results="hide", message=FALSE------------------------------------------------------------------

zipsByProduct(dpID="DP4.00200.001", package="basic", 
              site=site, 
              startdate=dateBgn, enddate=dateEnd,
              savepath=dirFile, 
              check.size=F)



## ----stack-dp04, results="hide"-------------------------------------------------------------------------------

flux <- stackEddy(filepath=paste0(dirFile,"/filesToStack00200"),
                  level="dp04")



## ----see-names------------------------------------------------------------------------------------------------

names(flux)

## ----see-variables--------------------------------------------------------------------------------------------

flux$variables



## ----plot-fluxes----------------------------------------------------------------------------------------------

plot(flux$STEI$data.fluxCo2.turb.flux~flux$STEI$timeBgn, 
     pch=".", xlab="Date", ylab="CO2 flux")

plot(flux$TREE$data.fluxCo2.turb.flux~flux$TREE$timeBgn, 
     pch=".", xlab="Date", ylab="CO2 flux")

#Plot evaporative fraction
plot(flux$STEI$timeBgn, flux$STEI$data.fluxCo2.turb.flux, ylim = c(-300, 300), col = ifelse(flux$STEI$qfqm.fluxCo2.turb.qfFinl == 1, "red", "black"))

#Plot evaporative fraction
plot(flux$TREE$timeBgn, flux$TREE$data.fluxCo2.turb.flux, ylim = c(-300, 300), col = ifelse(flux$TREE$qfqm.fluxCo2.turb.qfFinl == 1, "red", "black"))

#Plot evaporative fraction
plot(flux$STEI$timeBgn, flux$STEI$data.fluxCo2.nsae.flux, ylim = c(-300, 300), col = ifelse(flux$STEI$qfqm.fluxCo2.nsae.qfFinl == 1, "red", "black"))

#Plot evaporative fraction
plot(flux$TREE$timeBgn, flux$TREE$data.fluxCo2.nsae.flux, ylim = c(-300, 300), col = ifelse(flux$TREE$qfqm.fluxCo2.nsae.qfFinl == 1, "red", "black"))


flux$STEI$hour <- factor(lubridate::hour(flux$STEI$timeBgn))
flux$TREE$hour <- factor(lubridate::hour(flux$TREE$timeBgn))

flux$STEI$quarter <- factor(lubridate::quarter(flux$STEI$timeBgn))
flux$TREE$quarter <- factor(lubridate::quarter(flux$TREE$timeBgn))

ggplot(flux$STEI, aes(x = hour, y = data.fluxCo2.nsae.flux, fill = quarter)) +
  geom_boxplot() +
  stat_summary(fun.y = median, geom = 'line', aes(group = quarter, colour =quarter)) +
  ylim(-100,100)

ggplot(flux$TREE, aes(x = hour, y = data.fluxCo2.nsae.flux, fill = quarter)) +
  geom_boxplot() +
  stat_summary(fun.y = median, geom = 'line', aes(group = quarter, colour =quarter)) +
  ylim(-100,100)

ggplot(flux$STEI, aes(x = hour, y = data.fluxCo2.turb.flux, fill = quarter)) +
  geom_boxplot() +
  stat_summary(fun.y = median, geom = 'line', aes(group = quarter, colour =quarter)) +
  ylim(-100,100)

ggplot(flux$TREE, aes(x = hour, y = data.fluxCo2.turb.flux, fill = quarter)) +
  geom_boxplot() +
  stat_summary(fun.y = median, geom = 'line', aes(group = quarter, colour =quarter)) +
  ylim(-100,100)

ggplot(flux$STEI, aes(x = hour, y = data.fluxCo2.stor.flux, fill = quarter)) +
  geom_boxplot() +
  stat_summary(fun.y = median, geom = 'line', aes(group = quarter, colour =quarter)) +
  ylim(-100,100)

ggplot(flux$TREE, aes(x = hour, y = data.fluxCo2.stor.flux, fill = quarter)) +
  geom_boxplot() +
  stat_summary(fun.y = median, geom = 'line', aes(group = quarter, colour =quarter)) +
  ylim(-100,100)

#Summing turbulent fluxes
sum(flux$STEI$data.fluxCo2.turb.flux, na.rm = TRUE)
sum(flux$TREE$data.fluxCo2.turb.flux, na.rm = TRUE)
#Summing NSAE fluxes
sum(flux$STEI$data.fluxCo2.nsae.flux, na.rm = TRUE)
sum(flux$TREE$data.fluxCo2.nsae.flux, na.rm = TRUE)

#Summing stor fluxes
sum(flux$STEI$data.fluxCo2.stor.flux, na.rm = TRUE)
sum(flux$TREE$data.fluxCo2.stor.flux, na.rm = TRUE)

# ggplot(flux$STEI, aes(x = hour, y = data.fluxCo2.stor.flux, fill = quarter)) +
#   geom_boxplot() +
#   stat_summary(fun.y = median, geom = 'line', aes(group = quarter, colour =quarter)) +
#   ylim(-100,100)

# ggplot(flux$TREE, aes(x = hour, y = data.fluxCo2.stor.flux, fill = quarter)) +
#   geom_boxplot() +
#   stat_summary(fun.y = median, geom = 'line', aes(group = quarter, colour =quarter)) +
#   ylim(-100,100)

