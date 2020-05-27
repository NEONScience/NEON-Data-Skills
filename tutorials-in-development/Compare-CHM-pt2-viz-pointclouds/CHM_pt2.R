### Compare height CHM tutorial continued
### Bring in pointcloud and clip just the areas within uncertainty ring of tree

library(lidR)
library(sf)

## sort tree height disagreement by difference

vegfil$diff <- vegfil$height-filterCHM

vegfil <- vegfil[order(vegfil$diff, decreasing = T),]

## Top 5 'undermeasures' where LIDAR misses tree crown
top5 <- vegfil[1:5,]

## Good matches where CHM and Veg Structure agree within .5m
good_matches <- vegfil[abs(vegfil$diff)<.5,]

## Download and import lidar pointcloud for this tile
# byTileAOP(dpID="DP1.30003.001", easting = 580000, northing=5075000, 
#           check.size=F, site = "WREF",year = 2017, 
#           savepath = "~/Downloads/", token = NEON_TOKEN)
# 
# WREF_LAS=readLAS("~/Downloads/DP1.30003.001/2017/FullSite/D16/2017_WREF_1/L1/DiscreteLidar/ClassifiedPointCloud/NEON_D16_WREF_DP1_580000_5075000_classified_point_cloud.laz",
#                  filter = "-drop_z_below 50 -drop_z_above 1000")

plot(WREF_LAS)

WREF_top5=lasclipCircle(WREF_LAS, 
                        x=top5$adjEasting, y=top5$adjNorthing,
                        radius=3)

plot(WREF_top5[[5]])



### good matches
WREF_good_matches=lasclipCircle(WREF_LAS, 
                        x=good_matches$adjEasting, y=good_matches$adjNorthing,
                        radius=5)

plot(WREF_good_matches[[1]])


### Add base plots?
SITECODE = 'WREF'

setwd("~/Downloads/")
NEON_all_plots <- st_read('All_NEON_TOS_Plots_V7/All_NEON_TOS_Plot_Polygons_V7.shp')
base_plots_SPDF <- NEON_all_plots[(NEON_all_plots$siteID == SITECODE)&(NEON_all_plots$subtype == 'basePlot'),]

rm(NEON_all_plots)

#Plot base plots
plot(base_plots_SPDF$geometry, border = 'blue')

base_plots_SPDF <- st_transform(base_plots_SPDF, as.character(WREF_LAS@proj4string))

base_crop=st_crop(base_plots_SPDF, extent(WREF_LAS))
plot(base_crop$geometry, border = 'blue')


x = plot(WREF_LAS)
#quads3d(x=coordinates(base_plots_SPDF)[1:8,1], y=coordinates(base_plots_SPDF)[1:8,2])
coords=as.data.frame(st_coordinates(base_crop))
coords$X=coords$X-x[1]
coords$Y=coords$Y-x[2]
coords$Z=rep(base_crop$elevation, each=5)
c=1:nrow(coords)
coords=coords[!c%%5==0,]
#coords$L1=NULL; coords$L2=NULL
#coords$Z=NULL
#quads3d(coords[26:29,], add=T, col="red") # WORKS @ z=0

for(i in 1:(nrow(coords)/4)){
  print(i)
  r=((i-1)*4)+1
  quads3d(x=coords$X[r:(r+3)], y=coords$Y[r:(r+3)], z=coords$Z[r:(r+3)]+50, add=T, col="red")
}
#quads3d(x=coords$X[11:14], y=coords$Y[11:14], z=coords$Z[11:14], add=T, col="red")

#add_dtm3d(x, base_plots_SPDF)

## Download DEM

byTileAOP(dpID="DP3.30024.001", site="WREF", year="2017", 
          easting=veg$adjEasting[which(veg$plotID=="WREF_075")], 
          northing=veg$adjNorthing[which(veg$plotID=="WREF_075")],
          token=NEON_TOKEN,check.size = F,
          savepath="~/Downloads/")

DEM=raster("~/Downloads/DP3.30024.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/DTMGtif/NEON_D16_WREF_DP3_580000_5075000_DTM.tif")

x = plot(WREF_LAS, color="RGB")
add_dtm3d(x, DEM, color=terrain.colors(25))

plot_dtm3d(DEM, color=col)

zlen <- 505 - 341

colorlut <- terrain.colors(zlen) # height color lookup table

col <- colorlut[ DEM_m - 341 ] # assign colors to heights for each point




