### Compare height CHM tutorial continued
### Bring in pointcloud and clip just the areas within uncertainty ring of tree

library(lidR)
library(sf)
library(rgl)
library(neonUtilities)


WREF_LAS=readLAS("~/Downloads/NEON_lidar-point-cloud-line_SOAP/NEON.D17.SOAP.DP1.30003.001.2019-06.basic.20210418T025921Z.RELEASE-2021/NEON_D17_SOAP_DP1_299000_4100000_classified_point_cloud_colorized.laz",
                 filter = "-drop_z_below 1000 -drop_z_above 1300")
x = plot(WREF_LAS, color="RGB") 

#plot(WREF_LAS)
# 
# WREF_top5=lasclipCircle(WREF_LAS, 
#                         x=top5$adjEasting, y=top5$adjNorthing,
#                         radius=3)
# 
# plot(WREF_top5[[5]])
# 
# 
# 
# ### good matches
# WREF_good_matches=lasclipCircle(WREF_LAS, 
#                         x=good_matches$adjEasting, y=good_matches$adjNorthing,
#                         radius=5)
# 
# plot(WREF_good_matches[[1]])


### Add base plots?
SITECODE = 'SOAP'

setwd("~/Downloads/")
NEON_all_plots <- st_read('All_NEON_TOS_Plots_V8/All_NEON_TOS_Plot_Polygons_V8.shp')
base_plots_SPDF <- NEON_all_plots[(NEON_all_plots$siteID == SITECODE)&(NEON_all_plots$subtype == 'basePlot'),]

rm(NEON_all_plots)

#Plot base plots
#plot(base_plots_SPDF$geometry, border = 'blue')

base_plots_SPDF <- st_transform(base_plots_SPDF, as.character(WREF_LAS@proj4string))

#plot(base_plots_SPDF$geometry)

base_crop=st_crop(base_plots_SPDF, extent(WREF_LAS))
plot(base_crop$geometry, border = 'blue')



#quads3d(x=coordinates(base_plots_SPDF)[1:8,1], y=coordinates(base_plots_SPDF)[1:8,2])
coords=as.data.frame(st_coordinates(base_crop))
coords$X=coords$X-x[1]
coords$Y=coords$Y-x[2]
coords$Z=rep(base_crop$elevation, each=5)
c=1:nrow(coords)
coords=coords[!c%%5==0,]


for(i in 1:(nrow(coords)/4)){
  print(i)
  r=((i-1)*4)+1
  quads3d(x=coords$X[r:(r+3)], y=coords$Y[r:(r+3)], z=coords$Z[r:(r+3)]+25,
          add=T, col="red", lwd=2, lit=F)
}

## clip out individual plots
top_left=as.data.frame(st_coordinates(base_crop))
c=1:nrow(top_left)
top_left=top_left[c%%5==1,]

plots_LAS <- 
  lasclipRectangle(WREF_LAS,
                   xleft = (top_left$X), ybottom = (top_left$Y - 40),
                   xright = (top_left$X + 40), ytop = (top_left$Y))


plot(plots_LAS[[4]], color="RGB")
plot(plots_LAS[[4]], color="Classification")

## make tree plots
## First we add the Veg Str dataset

library(sp)
library(raster)
library(neonUtilities)
library(geoNEON)
options(stringsAsFactors=F)

veglist <- loadByProduct(dpID="DP1.10098.001", site="SOAP", check.size = F, package="basic")


vegmap <- getLocTOS(veglist$vst_mappingandtagging, 
                    "vst_mappingandtagging")

## Merge tables
veg <- merge(veglist$vst_apparentindividual, vegmap, 
             by=c("individualID","namedLocation",
                  "domainID","siteID","plotID"))



## Loop through plots and add color boxes for each tree
for(i in 1:length(plots_LAS)){

x=plot(plots_LAS[[i]], color="RGB")
#quads3d(x=coordinates(base_plots_SPDF)[1:8,1], y=coordinates(base_plots_SPDF)[1:8,2])
tree_boxes=veg[veg$plotID==base_crop$plotID[i],]

Thuja_boxes=tree_boxes[tree_boxes$taxonID=="TSHE",]
Thuja_boxes$adjEasting=Thuja_boxes$adjEasting-x[1]
Thuja_boxes$adjNorthing=Thuja_boxes$adjNorthing-x[2]

PSMEM_boxes=tree_boxes[tree_boxes$taxonID=="PSMEM",]
PSMEM_boxes$adjEasting=PSMEM_boxes$adjEasting-x[1]
PSMEM_boxes$adjNorthing=PSMEM_boxes$adjNorthing-x[2]


for(i in 1:(nrow(PSMEM_boxes))){
  print(i)
  d=as.data.frame(PSMEM_boxes[i,c(66,67,71)])
  d[,3]=as.numeric(d[,3])
  d[2:4,]=d[1,]
  d[1,1]=d[1,1]+2
  d[1,2]=d[1,2]-2
  
  d[2,1]=d[2,1]+2
  d[2,2]=d[2,2]+2
  
  d[3,1]=d[3,1]-2
  d[3,2]=d[3,2]+2
  
  d[4,1]=d[4,1]-2
  d[4,2]=d[4,2]-2
  
  d[,3]=d[,3]+PSMEM_boxes[i,16]
  
  #r=((i-1)*4)+1
  #quads3d(x=coords$X[r:(r+3)], y=coords$Y[r:(r+3)], z=coords$Z[r:(r+3)]+50, add=T, col="green")
  quads3d(x=d$adjEasting, y=d$adjNorthing, z=d$adjElevation, 
          add=T, col="green", lwd=2, lit=F)
}


for(i in 1:(nrow(Thuja_boxes))){
  print(i)
  d=as.data.frame(Thuja_boxes[i,c(66,67,71)])
  d[,3]=as.numeric(d[,3])
  d[2:4,]=d[1,]
  d[1,1]=d[1,1]+2
  d[1,2]=d[1,2]-2
  
  d[2,1]=d[2,1]+2
  d[2,2]=d[2,2]+2
  
  d[3,1]=d[3,1]-2
  d[3,2]=d[3,2]+2
  
  d[4,1]=d[4,1]-2
  d[4,2]=d[4,2]-2
  
  d[,3]=d[,3]+Thuja_boxes[i,16]
  
  #r=((i-1)*4)+1
  #quads3d(x=coords$X[r:(r+3)], y=coords$Y[r:(r+3)], z=coords$Z[r:(r+3)]+50, add=T, col="green")
  quads3d(x=d$adjEasting, y=d$adjNorthing, z=d$adjElevation,
          add=T, col="red", lwd=2, lit=F)
}

}

## Let's segment the individual trees, then assign colors according to species
# Let's try to first remove ground and unclassified points
just_trees=plots_LAS[[4]]
dj=just_trees@data
dj=dj[!dj$Classification %in% c(1,2),]
just_trees@data=dj



seg_4 <- segment_trees(just_trees, li2012())
col <- random.colors(200)
x=plot(seg_4, color = "treeID", colorPalette = col)

d=seg_4@data

d=d[d$treeID==4]
d=d[!d$Classification %in% c(1,2),]

indiv_tree = seg_4
indiv_tree@data = d
plot(indiv_tree, color="RGB")

length(unique(seg_4@data$treeID))

tree_boxes=veg[veg$plotID==base_crop$plotID[4],]

tree_boxes$taxonID_fact = as.factor(tree_boxes$taxonID)

# view taxonID as numeric version of factor
as.numeric(tree_boxes$taxonID_fact)



## Now, let's find the tree number associated with each of the measured trees
# Use extract function like CHM vs VST tutorial (hmm, but that requires a rasternot LAS object)
# Let's use the lidR cropping function within the dbh of the tree

tree_boxes=tree_boxes[!is.na(tree_boxes$adjEasting),]

boles = lasclipCircle(seg_4, tree_boxes$adjEasting, tree_boxes$adjNorthing, tree_boxes$stemDiameter/100+.25)

length(boles)

## Define mode function
# thanks to https://www.tutorialspoint.com/r/r_mean_median_mode.htm
# Create the function.
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

modes = rep(0,length(boles))

for(i in 1:length(boles)){
  print(i)
  v = boles[[i]]@data$treeID
  print(v)
  m = getmode(v)
  print(m)
  modes[i] = m
}
modes

## Now that we have the 'dominant' classification for each cylendar, 
# we can find the tallest tree from these groups (as to filter out sub-canopy trees)

unique_modes = unique(modes)
species = rep(0,length(unique_modes))
ctr=1
for(k in unique_modes){
  #print(k)
  #print(modes==k)
  tree = tree_boxes[modes==k,]
  #print(tree)
  tallest = tree[tree$height==max(tree$height),]$taxonID_fact
  print(as.numeric(tallest))
  #print(paste(k , tallest))
  species[ctr]=as.numeric(tallest)
  ctr=ctr+1
}
species


d=seg_4@data

for(t in 1:length(unique_modes)){
  d[d$treeID==unique_modes[t]]$treeID <- species[t]+100
}

classified_trees = seg_4
d = d[d$treeID>99]
classified_trees@data = d

plot(classified_trees, color = "treeID", colorPalette = col)

# d=d[d$treeID==3]
# 
# indiv_tree = seg_4
# indiv_tree@data = d
# plot(indiv_tree, color="RGB")
# 
# length(unique(seg_4@data$treeID))
# 
# tree_boxes$taxonID_fact = as.factor(tree_boxes$taxonID)
# 
# # view taxonID as numeric version of factor
# as.numeric(tree_boxes$taxonID_fact)
