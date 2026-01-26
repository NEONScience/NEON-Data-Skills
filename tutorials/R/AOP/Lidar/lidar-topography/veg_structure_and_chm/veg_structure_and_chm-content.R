## ----setup, include=FALSE-------------------------------------------------------------------------------------------
library(arrow)
library(reticulate)
reticulate::py_config()
knitr::opts_chunk$set(echo = TRUE)


## ----install_packages, eval=FALSE-----------------------------------------------------------------------------------
# 
# install.packages("neonUtilities")
# install.packages("neonOS")
# install.packages("terra")
# install.packages("devtools")
# devtools::install_github("NEONScience/NEON-geolocation/geoNEON")
# 


## ----load-packages, results="hide"----------------------------------------------------------------------------------

library(terra)
library(neonUtilities)
library(neonOS)
library(geoNEON)

options(stringsAsFactors=F)

# set working directory
# adapt directory path for your system
wd <- "~/data"



## 
## pip install neonutilities
## pip install geopandas
## pip install rasterio
## pip install rioxarray
## pip install rasterstats
## 

## 
## import neonutilities as nu
## import pandas as pd
## import numpy as np
## import rasterstats as rs
## import geopandas as gpd
## import rioxarray as rxr
## import matplotlib.pyplot as plt
## import matplotlib.collections
## import rasterio
## from rasterio import sample
## from rasterio.enums import Resampling
## import requests
## import time
## import os
## 

## ----veglist, results="hide"----------------------------------------------------------------------------------------

veglist <- loadByProduct(dpID="DP1.10098.001", 
                         site="WREF", 
                         package="basic", 
                         release="RELEASE-2024",
                         check.size = FALSE)



## 
## veglist = nu.load_by_product(dpid="DP1.10098.001",
##                          site="WREF",
##                          package="basic",
##                          release="RELEASE-2024",
##                          check_size = False)
## 

## ----vegmap, results="hide"-----------------------------------------------------------------------------------------

vegmap <- getLocTOS(veglist$vst_mappingandtagging, 
                          "vst_mappingandtagging")



## 
## vegmapall = veglist["vst_mappingandtagging"]
## vegmap = vegmapall.loc[vegmapall["pointID"] != ""]
## vegmap = vegmap.reindex()
## vegmap["points"] = vegmap["namedLocation"] + "." + vegmap["pointID"]
## veg_points = list(set(list(vegmap["points"])))
## 
## easting = []
## northing = []
## coord_uncertainty = []
## elev_uncertainty = []
## drop_points = []
## for i in veg_points:
##     time.sleep(1)
##     vres = requests.get("https://data.neonscience.org/api/v0/locations/"+i)
##     vres_json = vres.json()
##     if vres_json["data"] is not None:
##         easting.append(vres_json["data"]["locationUtmEasting"])
##         northing.append(vres_json["data"]["locationUtmNorthing"])
##         props = pd.DataFrame.from_dict(vres_json["data"]["locationProperties"])
##         cu = props.loc[props["locationPropertyName"] == "Value for Coordinate uncertainty"]["locationPropertyValue"]
##         coord_uncertainty.append(cu[cu.index[0]])
##         eu = props.loc[props["locationPropertyName"] == "Value for Elevation uncertainty"]["locationPropertyValue"]
##         elev_uncertainty.append(eu[eu.index[0]])
##     else:
##         drop_points.append(i)
## 
## veg_points_clean = [v for v in veg_points if v not in drop_points]
## 
## ptdct = dict(points=veg_points_clean,
##              easting=easting,
##              northing=northing,
##              coordinateUncertainty=coord_uncertainty,
##              elevationUncertainty=elev_uncertainty)
## ptfrm = pd.DataFrame.from_dict(ptdct)
## ptfrm.set_index("points", inplace=True)
## 
## vegmap = vegmap.join(ptfrm,
##                      on="points",
##                      how="inner")
## 

## 
## vegmap["adjEasting"] = (vegmap["easting"]
##                         + vegmap["stemDistance"]
##                         * np.sin(vegmap["stemAzimuth"]
##                                    * np.pi / 180))
## 
## vegmap["adjNorthing"] = (vegmap["northing"]
##                         + vegmap["stemDistance"]
##                         * np.cos(vegmap["stemAzimuth"]
##                                    * np.pi / 180))
## 

## 
## vegmap["adjCoordinateUncertainty"] = vegmap["coordinateUncertainty"] + 0.6
## vegmap["adjElevationUncertainty"] = vegmap["elevationUncertainty"] + 1
## 

## ----veg-merge------------------------------------------------------------------------------------------------------

veg <- joinTableNEON(veglist$vst_apparentindividual, 
                     vegmap, 
                     name1="vst_apparentindividual",
                     name2="vst_mappingandtagging")



## 
## veglist["vst_apparentindividual"].set_index("individualID", inplace=True)
## veg = vegmap.join(veglist["vst_apparentindividual"],
##                   on="individualID",
##                   how="inner",
##                   lsuffix="_MAT",
##                   rsuffix="_AI")
## 

## ----plot-1---------------------------------------------------------------------------------------------------------

veg2017 <- veg[which(veg$eventID.y=="vst_WREF_2017"),]

symbols(veg2017$adjEasting[which(veg2017$plotID=="WREF_075")], 
        veg2017$adjNorthing[which(veg2017$plotID=="WREF_075")], 
        circles=veg2017$stemDiameter[which(veg2017$plotID=="WREF_075")]/100/2, 
        inches=F, xlab="Easting", ylab="Northing")



## ----plot-2---------------------------------------------------------------------------------------------------------

symbols(veg2017$adjEasting[which(veg2017$plotID=="WREF_075")], 
        veg2017$adjNorthing[which(veg2017$plotID=="WREF_075")], 
        circles=veg2017$stemDiameter[which(veg2017$plotID=="WREF_075")]/100/2, 
        inches=F, xlab="Easting", ylab="Northing")
symbols(veg2017$adjEasting[which(veg2017$plotID=="WREF_075")], 
        veg2017$adjNorthing[which(veg2017$plotID=="WREF_075")], 
        circles=veg2017$adjCoordinateUncertainty[which(veg2017$plotID=="WREF_075")], 
        inches=F, add=T, fg="lightblue")



## 
## veg2017 = veg.loc[veg["eventID_AI"]=="vst_WREF_2017"]
## veg75 = veg2017.loc[veg2017["plotID_AI"]=="WREF_075"]
## 
## fig, ax = plt.subplots()
## 
## xy = np.array(tuple(zip(veg75.adjEasting, veg75.adjNorthing)))
## srad = veg75.stemDiameter/100/2
## patches = [plt.Circle(center, size) for center, size in zip(xy, srad)]
## 
## coll = matplotlib.collections.PatchCollection(patches, facecolors="white", edgecolors="black")
## ax.add_collection(coll)
## 
## ax.margins(0.1)
## plt.show()
## 

## 
## fig, ax = plt.subplots()
## 
## sunc = veg75.adjCoordinateUncertainty
## patchunc = [plt.Circle(center, size) for center, size in zip(xy, sunc)]
## 
## coll = matplotlib.collections.PatchCollection(patches, facecolors="None", edgecolors="black")
## collunc = matplotlib.collections.PatchCollection(patchunc, facecolors="None", edgecolors="lightblue")
## ax.add_collection(coll)
## ax.add_collection(collunc)
## 
## ax.margins(0.1)
## plt.show()
## 

## ----get-chm, results="hide"----------------------------------------------------------------------------------------

byTileAOP(dpID="DP3.30015.001", site="WREF", year=2017, 
          easting=veg2017$adjEasting[which(veg2017$plotID=="WREF_075")], 
          northing=veg2017$adjNorthing[which(veg2017$plotID=="WREF_075")],
          check.size=FALSE, savepath=wd)

chm <- rast(paste0(wd, "/DP3.30015.001/neon-aop-products/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif"))



## ----plot-chm-------------------------------------------------------------------------------------------------------

plot(chm, col=topo.colors(5))



## 
## nu.by_tile_aop(dpid="DP3.30015.001", site="WREF", year="2017",
##           easting=list(veg75.adjEasting),
##           northing=list(veg75.adjNorthing),
##           check_size=False, savepath=os.getcwd())
## 

## 
## chm = rasterio.open(os.getcwd() + "/DP3.30015.001/neon-aop-products/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")
## 
## chmx = rxr.open_rasterio(os.getcwd() + "/DP3.30015.001/neon-aop-products/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif").squeeze()
## 

## 
## plt.imshow(chm.read(1))
## plt.show()
## 

## ----vegsub---------------------------------------------------------------------------------------------------------

vegsub <- veg2017[which(veg2017$adjEasting >= ext(chm)[1] &
                        veg2017$adjEasting <= ext(chm)[2] &
                        veg2017$adjNorthing >= ext(chm)[3] & 
                        veg2017$adjNorthing <= ext(chm)[4]),]



## 
## vegsub = veg2017.loc[(veg2017["adjEasting"] >= chm.bounds[0]) &
##                  (veg2017["adjEasting"] <= chm.bounds[1]) &
##                  (veg2017["adjNorthing"] >= chm.bounds[2]) &
##                  (veg2017["adjNorthing"] <= chm.bounds[3])]
## vegsub = vegsub.reset_index(drop=True)
## 

## ----no-buffer-chm--------------------------------------------------------------------------------------------------

valCHM <- extract(chm, 
                  cbind(vegsub$adjEasting,
                  vegsub$adjNorthing))

plot(valCHM$NEON_D16_WREF_DP3_580000_5075000_CHM~
       vegsub$height, pch=20, xlab="Height", 
     ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----corr-no-buffer-------------------------------------------------------------------------------------------------

cor(valCHM$NEON_D16_WREF_DP3_580000_5075000_CHM, 
    vegsub$height, use="complete")



## 
## valCHM = list(sample.sample_gen(chm,
##                                 tuple(zip(vegsub["adjEasting"],
##                                           vegsub["adjNorthing"])),
##                                 masked=True))
## 
## fig, ax = plt.subplots()
## 
## ax.plot((0,50), (0,50), linewidth=1, color="black")
## ax.scatter(vegsub.height, valCHM, s=1)
## 
## ax.set_xlabel("Height")
## ax.set_ylabel("Canopy height model")
## 
## plt.show()
## 

## 
## CHMlist = np.array([c.tolist()[0] for c in valCHM])
## idx = np.intersect1d(np.where(np.isfinite(vegsub.height)),
##                      np.where(CHMlist != None))
## np.corrcoef(vegsub.height[idx], list(CHMlist[idx]))[0,1]
## 

## ----buffer-chm-----------------------------------------------------------------------------------------------------

valCHMbuff <- extract(chm, 
                  buffer(vect(cbind(vegsub$adjEasting,
                  vegsub$adjNorthing)),
                  width=vegsub$adjCoordinateUncertainty),
                  fun=max)

plot(valCHMbuff$NEON_D16_WREF_DP3_580000_5075000_CHM~
       vegsub$height, pch=20, xlab="Height", 
     ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----corr-buffer----------------------------------------------------------------------------------------------------

cor(valCHMbuff$NEON_D16_WREF_DP3_580000_5075000_CHM, 
    vegsub$height, use="complete")



## 
## vegloc = vegsub[["individualID","adjEasting","adjNorthing","adjCoordinateUncertainty"]]
## v = vegloc.rename(columns={"individualID": "indID", "adjEasting": "easting",
##                "adjNorthing": "northing", "adjCoordinateUncertainty": "coordUnc"},
##                inplace=False)
## 
## gdf = gpd.GeoDataFrame(
##        v, geometry=gpd.points_from_xy(v.easting, v.northing))
## gdf["geometry"] = gdf["geometry"].buffer(distance=gdf["coordUnc"])
## gdf.to_file(os.getcwd() + "/trees_with_buffer.shp")
## 
## chm_height = rs.zonal_stats(os.getcwd() + "/trees_with_buffer.shp", chmx.values,
##                             affine=chmx.rio.transform(),
##                             nodata=-9999, stats="max")
## 
## valCHMbuff = [h["max"] for h in chm_height]
## 

## 
## fig, ax = plt.subplots()
## 
## ax.plot((0,50), (0,50), linewidth=1, color="black")
## ax.scatter(vegsub.height, valCHMbuff, s=1)
## 
## ax.set_xlabel("Height")
## ax.set_ylabel("Canopy height model")
## 
## plt.show()
## 

## 
## CHMbufflist = np.array(valCHMbuff)
## idx = np.intersect1d(np.where(np.isfinite(vegsub.height)),
##                      np.where(CHMbufflist != None))
## np.corrcoef(vegsub.height[idx], list(CHMbufflist[idx]))[0,1]
## 

## ----round-x-y------------------------------------------------------------------------------------------------------

easting10 <- 10*floor(vegsub$adjEasting/10)
northing10 <- 10*floor(vegsub$adjNorthing/10)
vegsub <- cbind(vegsub, easting10, northing10)



## ----vegbin---------------------------------------------------------------------------------------------------------

vegbin <- stats::aggregate(vegsub, 
                           by=list(vegsub$easting10, 
                                   vegsub$northing10), 
                           FUN=max)



## ----CHM-10---------------------------------------------------------------------------------------------------------

CHM10 <- terra::aggregate(chm, fact=10, fun=max)
plot(CHM10, col=topo.colors(5))



## ----adj-tree-coord-------------------------------------------------------------------------------------------------

vegbin$easting10 <- vegbin$easting10 + 5
vegbin$northing10 <- vegbin$northing10 + 5
binCHM <- extract(CHM10, cbind(vegbin$easting10, 
                               vegbin$northing10))
plot(binCHM$NEON_D16_WREF_DP3_580000_5075000_CHM~
       vegbin$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----cor-2----------------------------------------------------------------------------------------------------------

cor(binCHM$NEON_D16_WREF_DP3_580000_5075000_CHM, 
    vegbin$height, use="complete")



## 
## vegsub["easting10"] = 10*np.floor(vegsub.adjEasting/10)
## vegsub["northing10"] = 10*np.floor(vegsub.adjNorthing/10)
## vegsubloc = vegsub[["height","easting10","northing10"]]
## 

## 
## vegbin = vegsubloc.groupby(["easting10", "northing10"]).max().add_suffix('_max').reset_index()
## 

## 
## target_res = (10, 10)
## 
## with rasterio.open(os.getcwd() + "/DP3.30015.001/neon-aop-products/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif") as src:
##      data, transform = rasterio.warp.reproject(source=src.read(),
##                                 src_transform=src.transform,
##                                 src_crs=src.crs,
##                                 dst_crs=src.crs,
##                                 dst_nodata=src.nodata,
##                                 dst_resolution=target_res,
##                                 resampling=Resampling.max)
##      profile = src.profile
##      profile.update(transform=transform, driver='GTiff',
##                     height=data.shape[1], width=data.shape[2])
## 
##      with rasterio.open(os.getcwd() + '/CHM_10m.tif', 'w', **profile) as dst:
##                     dst.write(data)
## 
## chm10 = rasterio.open(os.getcwd() + '/CHM_10m.tif')
## 

## 
## plt.imshow(chm10.read(1))
## plt.show()
## 

## 
## valCHM10 = list(sample.sample_gen(chm10, tuple(zip(vegbin["easting10"]+5,
##                                                    vegbin["northing10"]+5)),
##                                                    masked=True))
## 
## fig, ax = plt.subplots()
## 
## ax.plot((0,50), (0,50), linewidth=1, color="black")
## ax.scatter(vegbin.height_max, valCHM10, s=1)
## 
## ax.set_xlabel("Height")
## ax.set_ylabel("Canopy height model")
## 
## plt.show()
## 

## 
## CHM10list = np.array([c.tolist()[0] for c in valCHM10])
## idx = np.intersect1d(np.where(np.isfinite(vegbin.height_max)),
##                      np.where(CHM10list != None))
## np.corrcoef(vegbin.height_max[idx], list(CHM10list[idx]))[0,1]
## 

## ----vegsub-2-------------------------------------------------------------------------------------------------------

vegsub <- vegsub[order(vegsub$height, 
                       decreasing=T),]



## ----vegfil---------------------------------------------------------------------------------------------------------

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



## ----filter-chm-----------------------------------------------------------------------------------------------------

filterCHM <- extract(chm, 
                     cbind(vegfil$adjEasting, 
                           vegfil$adjNorthing))
plot(filterCHM$NEON_D16_WREF_DP3_580000_5075000_CHM~
       vegfil$height, pch=20, 
     xlab="Height", ylab="Canopy height model")
lines(c(0,50), c(0,50), col="grey")



## ----cor-3----------------------------------------------------------------------------------------------------------

cor(filterCHM$NEON_D16_WREF_DP3_580000_5075000_CHM,
    vegfil$height)



## 
## vegfil = vegsub.sort_values(by="height", ascending=False, ignore_index=True)
## 

## 
## height = vegfil.height.reset_index()
## for i in vegfil.index:
##     if height.height[i] is None:
##         pass
##     else:
##         dist = np.sqrt(np.square(vegfil.adjEasting[i]-vegfil.adjEasting) +
##                        np.square(vegfil.adjNorthing[i]-vegfil.adjNorthing))
##         idx = vegfil.index[(vegfil.height<height.height[i]) & (dist<0.3*height.height[i])]
##         height.loc[idx, "height"] = None
## 

## 
## filterCHM = list(sample.sample_gen(chm, tuple(zip(vegfil["adjEasting"],
##                                                   vegfil["adjNorthing"])),
##                                                   masked=True))
## 
## fig, ax = plt.subplots()
## 
## ax.plot((0,50), (0,50), linewidth=1, color="black")
## ax.scatter(height.height, filterCHM, s=1)
## 
## ax.set_xlabel("Height")
## ax.set_ylabel("Canopy height model")
## 
## plt.show()
## 

## 
## filCHMlist = np.array([c.tolist()[0] for c in filterCHM])
## idx = np.intersect1d(np.where(np.isfinite(height.height)),
##                      np.where(filCHMlist != None))
## np.corrcoef(height.height[idx], list(filCHMlist[idx]))[0,1]
## 

## ----live-trees-----------------------------------------------------------------------------------------------------

vegfil <- vegfil[which(vegfil$plantStatus=="Live"),]

filterCHM <- extract(chm, 
                     cbind(vegfil$adjEasting, 
                           vegfil$adjNorthing))

plot(filterCHM$NEON_D16_WREF_DP3_580000_5075000_CHM~
       vegfil$height, pch=20, 
     xlab="Height", ylab="Canopy height model")

lines(c(0,50), c(0,50), col="grey")



## ----cor-4----------------------------------------------------------------------------------------------------------

cor(filterCHM$NEON_D16_WREF_DP3_580000_5075000_CHM,
    vegfil$height)



## 
## idx = vegfil.index[vegfil.plantStatus!="Live"]
## height.loc[idx, "height"] = None
## 
## fig, ax = plt.subplots()
## 
## ax.plot((0,50), (0,50), linewidth=1, color="black")
## ax.scatter(height.height, filterCHM, s=1)
## 
## ax.set_xlabel("Height")
## ax.set_ylabel("Canopy height model")
## 
## plt.show()
## 

## 
## idx = np.intersect1d(np.where(np.isfinite(height.height)),
##                      np.where(filCHMlist != None))
## np.corrcoef(height.height[idx], list(filCHMlist[idx]))[0,1]
## 
