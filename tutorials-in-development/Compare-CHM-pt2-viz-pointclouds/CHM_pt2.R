### Compare height CHM tutorial continued
### Bring in pointcloud and clip just the areas within uncertainty ring of tree


## sort tree height disagreement by difference

vegfil$diff <- vegfil$height-filterCHM

vegfil <- vegfil[order(vegfil$diff, decreasing = T),]

## Top 5 'undermeasures' where LIDAR misses tree crown
top5 <- vegfil[1:5,]

## Good matches where CHM and Veg Structure agree within .5m
good_matches <- vegfil[abs(vegfil$diff)<.5,]

## Download and import lidar pointcloud for this tile
byTileAOP(dpID="DP1.30003.001", easting = 580000, northing=5075000, 
          check.size=F, site = "WREF",year = 2017, 
          savepath = "~/Downloads/", token = NEON_TOKEN)

WREF_LAS=readLAS("~/Downloads/DP1.30003.001/2017/FullSite/D16/2017_WREF_1/L1/DiscreteLidar/ClassifiedPointCloud/NEON_D16_WREF_DP1_580000_5075000_classified_point_cloud.laz")

plot(WREF_LAS)

lasclipCircle(WREF, x,y,radius)