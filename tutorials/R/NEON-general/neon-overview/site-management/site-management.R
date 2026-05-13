## ----setup, eval=FALSE------------------------------------------------------------------------------------------------------
# 
# install.packages("neonUtilities")
# install.packages("devtools")
# devtools::install_github("NEONScience/NEON-geolocation/geoNEON")
# devtools::install_github("NEONScience/neonSiteMgmtEventData")
# install.packages("ggplot2")
# install.packages("dplyr")
# install.packages("stringr")
# install.packages("tidyr")
# install.packages("lubridate")
# install.packages("terra")
# install.packages("sf")
# install.packages("leaflet")
# install.packages("magrittr")
# install.packages("tidyselect")
# install.packages("tibble")
# 
# library(neonUtilities)
# library(geoNEON)
# library(neonSiteMgmtEventData)
# library(ggplot2)
# library(dplyr)
# library(stringr)
# library(tidyr)
# library(lubridate)
# library(terra)
# library(sf)
# library(leaflet)
# library(magrittr)
# library(tidyselect)
# library(tibble)
# 
# setwd("~/data")
# 


## ----libraries, include=FALSE, results="hide", message=FALSE----------------------------------------------------------------

library(neonUtilities)
library(geoNEON)
library(neonSiteMgmtEventData)
library(ggplot2)
library(dplyr)
library(stringr)
library(tidyr)
library(lubridate)
library(terra)
library(sf)
library(leaflet)
library(magrittr)
library(tidyselect)
library(tibble)



## ----load-data, results="hide", message=FALSE-------------------------------------------------------------------------------

events <- loadByProduct(dpID="DP1.10111.001", 
                        site="TEAK",
                        check.size=F,
                        include.provisional=T)



## ----view-data,sim_eventData------------------------------------------------------------------------------------------------

list2env(events, .GlobalEnv)
head(sim_eventData)



## ----view-types-------------------------------------------------------------------------------------------------------------
sim_eventData |>
  select(eventType, methodTypeChoice) |>
  unique()



## ----view-types, neonSiteMgmtEventData::summarizeSIM------------------------------------------------------------------------
summarizeSIM(df= sim_eventData)


## ----herb-locs--------------------------------------------------------------------------------------------------------------

burn <- sim_eventData |>
  filter(methodTypeChoice=="fire-wildfire")

burn.locs <- burn |>
  select(locationID) |>
  unlist() |>
  str_split(",") |>
  unlist() |>
  trimws() |>
  unique()

burn.locs



## ----load-CA-fires, results="hide", message=FALSE---------------------------------------------------------------------------

fires <- byEventSIM(eventType="fire", 
                    site=c("SJER","SOAP","BIGC","TEAK","TECR"),
                    include.provisional=T)



## ----fire-dates-------------------------------------------------------------------------------------------------------------

fires$sim_eventData |>
  select(siteID, startDate, endDate, methodTypeChoice)


## ----fire-dates, summarizeSIM-----------------------------------------------------------------------------------------------
fireSummary <- summarizeSIM(df= fires$sim_eventData)

fireSummary$yearlyEventTypeTable


## ----CA-locations, results="hide", message=FALSE----------------------------------------------------------------------------

fire.loc <- getLocTOS(fires$sim_eventData, 
                      "sim_eventData")



## ----ex-location-table------------------------------------------------------------------------------------------------------

fire.loc$locationID[7]



## ----SOAP-locations---------------------------------------------------------------------------------------------------------

fire.SOAP <- fire.loc |>
  filter(siteID=="SOAP" & endDate<"2021-01-01") |>
  unnest(cols="locationID", names_sep="_")



## ----download-AOP, results="hide", message=FALSE----------------------------------------------------------------------------

byTileAOP("DP3.30026.001", site="SOAP", year=2019,
          easting=fire.SOAP$locationID_easting,
          northing=fire.SOAP$locationID_northing,
          buffer=10, check.size=F, savepath=getwd())

byTileAOP("DP3.30026.001", site="SOAP", year=2021,
          easting=fire.SOAP$locationID_easting,
          northing=fire.SOAP$locationID_northing,
          buffer=10, check.size=F, savepath=getwd())



## ----unzip-AOP, results="hide"----------------------------------------------------------------------------------------------

zippaths <- list.files(getwd(), pattern=".zip", 
                        full.names=T, recursive=T)

for(i in 1:length(zippaths)) {
  unzip(zippaths[i], exdir=dirname(zippaths[i]))
}



## ----tiles-2019-------------------------------------------------------------------------------------------------------------

tiles2019 <- list.files(getwd(), pattern="NDVI.tif", 
                        full.names=T, recursive=T)
tiles2019 <- grep("2019", tiles2019, value=T)

ndvi2019 <- rast(tiles2019[1])
for(i in 2:length(tiles2019)) {
  ndvii <- rast(tiles2019[i])
  ndvi2019 <- merge(ndvi2019, ndvii)
}



## ----plot-2019-wf-----------------------------------------------------------------------------------------------------------

plot(ndvi2019)

wf.SOAP <- fire.SOAP |>
  filter(methodTypeChoice=="fire-wildfire")
points(wf.SOAP$locationID_easting,
       wf.SOAP$locationID_northing,
       pch=20, col="hotpink")



## ----plot-2019-all----------------------------------------------------------------------------------------------------------

plot(ndvi2019)

points(wf.SOAP$locationID_easting,
       wf.SOAP$locationID_northing,
       pch=20, col="hotpink")

cb.SOAP <- fire.SOAP |>
  filter(methodTypeChoice=="fire-controlledBurn")
points(cb.SOAP$locationID_easting,
       cb.SOAP$locationID_northing,
       pch=20, col="darkred")




## ----plot-2019-add polygons-------------------------------------------------------------------------------------------------

# wildfire polygons
wf.SOAP.df <- fire.loc |>
  filter(siteID=="SOAP" & endDate<"2021-01-01" & 
           eventType == "fire" & 
           methodTypeChoice=="fire-wildfire") 

wf.SOAP.polygon <- createSIMPolygon(df= wf.SOAP.df)

# transform the polygon from WGS84 (standard output) to utm zone 11N 
# to match AOP tiles.  
# coordinate reference system (crs) EPSG values can be searched for 
# on https://spatialreference.org/ref/epsg/
wf.SOAP.polygon.utm <- st_transform(wf.SOAP.polygon$sfObjects[[1]], 
                                    crs = 32611)

# controlled burn polygons
cb.SOAP.df <- fire.loc |>
  filter(siteID=="SOAP" & endDate<"2021-01-01" & 
           eventType == "fire" & 
           methodTypeChoice=="fire-controlledBurn")

cb.SOAP.polygon <- createSIMPolygon(df= cb.SOAP.df)

# transform the polygon from WGS84 (standard output) to utm zone 11N 
# to match AOP tiles.  
# coordinate reference system (crs) EPSG values can be searched for 
# on https://spatialreference.org/ref/epsg/
cb.SOAP.polygon.utm <- st_transform(cb.SOAP.polygon$sfObjects[[1]], 
                                    crs = 32611)


plot(ndvi2019)

points(wf.SOAP$locationID_easting,
       wf.SOAP$locationID_northing,
       pch=20, col="hotpink")

cb.SOAP <- fire.SOAP |>
  filter(methodTypeChoice=="fire-controlledBurn")
points(cb.SOAP$locationID_easting,
       cb.SOAP$locationID_northing,
       pch=20, col="darkred")

plot(sf::st_geometry(wf.SOAP.polygon.utm),
       border = "hotpink",
       lwd = 2.5,
       add = TRUE)

plot(sf::st_geometry(cb.SOAP.polygon.utm),
       border = "darkred",
       lwd = 2.5,
       add = TRUE)


## ----tiles-2021-------------------------------------------------------------------------------------------------------------

tiles2021 <- list.files(getwd(), pattern="NDVI.tif", 
                        full.names=T, recursive=T)
tiles2021 <- grep("2021", tiles2021, value=T)

ndvi2021 <- rast(tiles2021[1])
for(i in 2:length(tiles2021)) {
  ndvii <- rast(tiles2021[i])
  ndvi2021 <- merge(ndvi2021, ndvii)
}



## ----plot-2021-all----------------------------------------------------------------------------------------------------------

plot(ndvi2021)

points(wf.SOAP$locationID_easting,
       wf.SOAP$locationID_northing,
       pch=20, col="hotpink")

points(cb.SOAP$locationID_easting,
       cb.SOAP$locationID_northing,
       pch=20, col="darkred")

plot(sf::st_geometry(wf.SOAP.polygon.utm),
       border = "hotpink",
       lwd = 2.5,
       add = TRUE)

plot(sf::st_geometry(cb.SOAP.polygon.utm),
       border = "darkred",
       lwd = 2.5,
       add = TRUE)



## ----export polygons, warnings= F-------------------------------------------------------------------------------------------
# export the wildfire polygons as kmls
writeExportFile(sfList = wf.SOAP.polygon$sfObjects, 
                outDir = getwd(),
                outType = "kml")

# export the controlled burns polygons as shapefiles
writeExportFile(sfList = cb.SOAP.polygon$sfObjects, 
                outDir = getwd(),
                outType = "shapefile")


