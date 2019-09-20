## ----install, eval=F-----------------------------------------------------
## 
## # run once to get the package, and re-run if you need to get updates
## install.packages("sp")
## install.packages("rgdal")
## install.packages("rgeos")
## install.packages("ggplot2")
## install.packages("ggthemes")
## install.packages("neonUtilities")
## install.packages("devtools")
## devtools::install_github("NEONScience/NEON-geolocation/geoNEON")
## 


## ----libraries, results="hide"-------------------------------------------

# run every time you start a script
library(sp)
library(rgdal)
library(rgeos)
library(ggplot2)
library(ggthemes)
library(neonUtilities)
library(geoNEON)

options(stringsAsFactors=F)



## ----domains, results="hide"---------------------------------------------

# modify "~/data" to the filepath where you downloaded the shapefile
neon.domains <- readOGR("~/data/NEONDomains_0", layer="NEON_Domains")

# the next two commands convert the shapefile to a format ggplot 
# can use
neon.domains <- SpatialPolygonsDataFrame(gSimplify(neon.domains, tol=0.1, 
                                                 topologyPreserve=TRUE), 
                               data=neon.domains@data)
map <- fortify(neon.domains, region="DomainName")



## ----plot-domains, message=F, warning=F, fig.width=8, fig.height=6-------

gg <- ggplot() + theme_map()
gg <- gg + geom_map(data=map, map=map,
                    aes(x=long, y=lat, map_id=id, group=group),
                    fill="white", color="black", size=0.3)
gg



## ----plot-sites, fig.width=8, fig.height=6-------------------------------

# modify "~/data" to the filepath where you downloaded the file
sites <- read.delim("~/data/field-sites.csv", sep=",", header=T)

gg <- gg + geom_point(data=sites, aes(x=Longitude, y=Latitude))
gg



## ----sites-color, fig.width=8, fig.height=6------------------------------

gg <- gg + geom_point(data=sites, 
                      aes(x=Longitude, y=Latitude, color=Site.Type)) + 
           scale_color_manual(values=c("blue4", "springgreen4", 
                                       "blue", "olivedrab"),
                              name="",
                              breaks=unique(sites$Site.Type))
gg



## ----TOS-readme, echo=F--------------------------------------------------

rdme <- read.delim('/Users/clunch/Dropbox/NEON/spatial/All_NEON_TOS_Plots_V5/readme .csv',
                   sep=',', header=T)
rdme[,1]



## ----get-mam-data, results="hide"----------------------------------------

mam <- loadByProduct(dpID="DP1.10072.001", site="ONAQ",
                     startdate="2018-08", enddate="2018-08",
                     check.size=F)



## ----print-mam-----------------------------------------------------------

head(mam$mam_pertrapnight[,1:18])



## ----print-ONAQ019-------------------------------------------------------

mam$mam_pertrapnight[which(mam$mam_pertrapnight$plotID=="ONAQ_019"),
                     c("trapCoordinate","decimalLatitude",
                       "decimalLongitude")]



## ----mam-calc, results="hide"--------------------------------------------

mam.loc <- getLocTOS(data=mam$mam_pertrapnight,
                           dataProd="mam_pertrapnight")



## ----mam-diff------------------------------------------------------------

names(mam.loc)[which(!names(mam.loc) %in% names(mam$mam_pertrapnight))]



## ----mam-grids-----------------------------------------------------------

plot(mam.loc$easting, mam.loc$northing, pch=".",
     xlab="Easting", ylab="Northing")



## ----plot-ONAQ019--------------------------------------------------------

plot(mam.loc$easting[which(mam.loc$plotID=="ONAQ_003")], 
     mam.loc$northing[which(mam.loc$plotID=="ONAQ_003")], 
     pch=".", xlab="Easting", ylab="Northing")



## ----plot-captures-------------------------------------------------------

plot(mam.loc$easting[which(mam.loc$plotID=="ONAQ_003")], 
     mam.loc$northing[which(mam.loc$plotID=="ONAQ_003")], 
     pch=".", xlab="Easting", ylab="Northing")

points(mam.loc$easting[which(mam.loc$plotID=="ONAQ_003" & 
                               mam.loc$trapStatus=="5 - capture")], 
     mam.loc$northing[which(mam.loc$plotID=="ONAQ_003" &
                              mam.loc$trapStatus=="5 - capture")],
     pch=19, col="blue")



## ----sens-pos------------------------------------------------------------

pos <- read.delim("~/data/NEON.D05.TREE.DP1.00024.001.2018-07.basic.20190314T150344Z/NEON.D05.TREE.DP1.00024.001.sensor_positions.20190314T150344Z.csv",
                  sep=",", header=T)
names(pos)



## ----par-load, results="hide"--------------------------------------------

pr <- loadByProduct(dpID="DP1.00024.001", site="TREE",
                    startdate="2018-07", enddate="2018-07",
                    avg=30, check.size=F)



## ----par-ver-mean--------------------------------------------------------

pr.mn <- aggregate(pr$PARPAR_30min$PARMean, 
                   by=list(pr$PARPAR_30min$verticalPosition),
                   FUN=mean, na.rm=T)



## ----par-plot------------------------------------------------------------

plot(pr.mn$x, pos$zOffset, type="b", pch=20,
     xlab="Photosynthetically active radiation",
     ylab="Height above tower base (m)")


