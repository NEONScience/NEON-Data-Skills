## Script for PUUM LiDAR Breakout Session
## For self-hosted Explore NEON Workshop, 
## June 14-17, 2021
## By Donal O'Leary


library(neonUtilities)
library(geoNEON)
library(lidR)
library(sf)
library(rgl)
library(sp)
library(raster)

options(stringsAsFactors=F) #This line may be redundant for R version 4.0.0+

wd <- "~/Downloads/" # This will depend on your local environment
setwd(wd)

SITE="PUUM"

veglist <- loadByProduct(dpID="DP1.10098.001", site=SITE, check.size = F, package="basic")

# retrieve precise XY locations using geoNEON API
vegmap <- getLocTOS(veglist$vst_mappingandtagging, 
                    "vst_mappingandtagging")

## Merge tables
veg <- base::merge(veglist$vst_apparentindividual, vegmap, 
                   by=c('individualID','namedLocation',
                        'domainID','siteID','plotID'))

SITE_LAS=readLAS("~/Downloads/PUUM_NEON_lidar-point-cloud-line/NEON.D20.PUUM.DP1.30003.001.2019-01.basic.20210426T150441Z.PROVISIONAL/NEON_D20_PUUM_DP1_256000_2163000_classified_point_cloud_colorized.laz")

# Great lava flows and electrical wires: NEON_D20_PUUM_DP1_252000_2168000_classified_point_cloud_colorized.laz
# Covers many of the tower plots: NEON_D20_PUUM_DP1_256000_2163000_classified_point_cloud_colorized.laz


rgl_plot=plot(SITE_LAS, color="RGB")

rgl_plot=plot(SITE_LAS, color="Classification")

rgl_plot=plot(SITE_LAS)

## adjust data_table by classification

dt = SITE_LAS@data
# take a look at this table if you like:
# View(dt)

# Remove the noise points
dt = dt[!dt$Classification==7,]

# re-assign the data table to the LAS object
SITE_LAS@data = dt

# Make a plot, this time saving the plot as an object
# called rgl_plot
rgl_plot=plot(SITE_LAS, color="RGB", size=2)

NEON_all_plots <- st_read(paste0(wd,'All_NEON_TOS_Plots_V8/All_NEON_TOS_Plot_Polygons_V8.shp'))

# Select only base plots from the site of interest
base_plots_SPDF <- NEON_all_plots[(NEON_all_plots$siteID == SITE)&(NEON_all_plots$subtype == 'basePlot'),]

# remove the object that contains all of the plots because it is no longer needed
rm(NEON_all_plots)

# re-project these polygons to match the local UTM projection of the LiDAR pointcloud
base_plots_SPDF <- st_transform(base_plots_SPDF, as.character(SITE_LAS@proj4string))

# Finally, crop out all of the plots that are outside of this one mosaic tile
base_crop=st_crop(base_plots_SPDF, extent(SITE_LAS))



coords=as.data.frame(st_coordinates(base_crop))

# make object 'c' to indicate each row of the coords data_frame
c=1:nrow(coords)
# and use that row number to remove every fifth row
coords=coords[!c%%5==0,]

# Now, offset the X and Y coordinates by the lower left corner of the
# LiDAR pointcloud as saved in the 'rgl_plot' object
coords$X=coords$X-rgl_plot[1]
coords$Y=coords$Y-rgl_plot[2]

# And add a Z dimension according to the reported elevation in the
# TOS plots shapefile
coords$Z=rep(base_crop$elevation, each=4)

# Let's take a look at the resulting table
head(coords, 10)


for(i in 1:(nrow(coords)/4)){
  r=((i-1)*4)+1
  quads3d(x=coords$X[r:(r+3)], y=coords$Y[r:(r+3)], 
          z=coords$Z[r:(r+3)]+50, # adding 50m to Z dimension
          add=T, col="red", lwd=2, lit=F)
}


coords=as.data.frame(st_coordinates(base_crop))

# Because we're dealing with varying plot sizes, let's make a new method to get plot boundaries

# First, remove the fifth point
c=1:nrow(coords)
top_left=coords[c%%5==1,]
bot_right = coords[c%%5==3,]

top_left$X2 = bot_right$X
top_left$Y2 = bot_right$Y

# Clip out the plots from the fill 1km LiDAR mosaic tile

plots_LAS <- 
  lasclipRectangle(SITE_LAS,
                   xleft = (top_left$X), ybottom = (top_left$Y2),
                   xright = (top_left$X2), ytop = (top_left$Y))

# Plot an example 
rgl_plot=plot(plots_LAS[[13]], color="RGB", size=2)

# Subset the VST data for just plot #3
tree_boxes=veg[veg$plotID==base_crop$plotID[13],]

# remove any rows that don't have an adjElevation
# This may or may not be needed for your data, but can't hurt
tree_boxes=tree_boxes[!is.na(tree_boxes$adjElevation),]
tree_boxes=tree_boxes[!is.na(tree_boxes$height),]

# offset the X and Y coordinates by the LL corner of the plot
tree_boxes$adjEasting=tree_boxes$adjEasting-rgl_plot[1]
tree_boxes$adjNorthing=tree_boxes$adjNorthing-rgl_plot[2]

head(tree_boxes)



for(j in 1:(nrow(tree_boxes))){
  
  # make a new data_frame 'd' for the individual tree
  d=as.data.frame(tree_boxes[j,c("adjNorthing","adjEasting",
                                 "adjElevation","height","stemDiameter")])
  
  # convert adjElevation from character to numeric
  d[,3]=as.numeric(d[,3]) 
  
  # Must generate 4 arc segments to complete the circle
  # Note that we add the tree height to the adjElevation
  # so that we can plot the circle at the top of the tree
  center=c(d[[2]],d[[1]], d[[3]]+d[[4]])
  
  # Define the radius of the circle from the stemDiameter
  # Divide by 100 because stemDiameter is in cm,
  # and divide by 2 because it is a diameter not a radius!
  # Multiply by 10 to make it easier to see
  radius = d[[5]]/100/2*10 
  
  # define circle cardinal direction points by
  # offsetting by length `rdius` from the center of the tree
  circle_N = center
  circle_N[2] = circle_N[2]+radius
  
  circle_E = center
  circle_E[1] = circle_E[1]+radius
  
  circle_S = center
  circle_S[2] = circle_E[2]-radius
  
  circle_W = center
  circle_W[1] = circle_W[1]-radius
  
  # plot arcs
  # N to E
  arc3d(
    from = circle_N, 
    to = circle_E, 
    center = center,
    col="green", lwd=2)
  
  # E to S
  arc3d(
    from = circle_E, 
    to = circle_S, 
    center = center,
    col="red", lwd=2)
  
  # S to W
  arc3d(
    from = circle_S, 
    to = circle_W, 
    center = center,
    col="orange", lwd=2) 
  
  # W to N
  arc3d(
    from = circle_W, 
    to = circle_N, 
    center = center,
    col="blue", lwd=2)
  
}

top_five = sort(table(veg$scientificName), decreasing = T)[1:5]
top_five

names(top_five)


# make a new chr vector of colors for the circles
col_tree=c("green","red","blue","orange","white")

# Print out colors and species

for(color in 1:length(col_tree)){
  print(paste(col_tree[color], "is for", names(top_five)[color]))
}


for(i in c(10)){
  
  rgl_plot=plot(plots_LAS[[i]], color="RGB", size=2)
  
  # Subset the VST data for just this plot
  tree_boxes=veg[veg$plotID==base_crop$plotID[i],]
  
  # remove any rows that don't have an adjElevation
  # This may or may not be needed for your data, but can't hurt
  tree_boxes=tree_boxes[!is.na(tree_boxes$adjElevation),]
  tree_boxes=tree_boxes[!is.na(tree_boxes$height),]
  
  # offset the X and Y coordinates by the LL corner of the plot
  tree_boxes$adjEasting=tree_boxes$adjEasting-rgl_plot[1]
  tree_boxes$adjNorthing=tree_boxes$adjNorthing-rgl_plot[2]
  
  ## Top five species for this plot:
  top_five = sort(table(tree_boxes$scientificName), decreasing = T)[1:5]
  
  # make a new chr vector of colors for the circles
  col_tree=c("green","red","blue","orange","white")
  
  # Print out colors and species
  
  for(color in 1:length(col_tree)){
    print(paste0("Plot #",i," ",col_tree[color], " is for ", names(top_five)[color]))
  }
  
  for(sp in 1:length(names(top_five))){
    
    # subset for just the species of interest
    tree_boxes_sp=tree_boxes[tree_boxes$scientificName == names(top_five)[sp],]
    
    # first, test to see if there are any of that species in this plot
    if(nrow(tree_boxes_sp)>0){
      # loop through each tree in this plot
      for(j in 1:(nrow(tree_boxes_sp))){
        
        # make a new data_frame 'd' for the individual tree
        d=as.data.frame(tree_boxes_sp[j,c("adjNorthing","adjEasting",
                                       "adjElevation","height","stemDiameter")])
        
        # convert adjElevation from character to numeric
        d[,3]=as.numeric(d[,3]) 
        
        # Test to ensure that d is not missing any information
        if(!complete.cases(d)){
          break
        }
        
        # Must generate 4 arc segments to complete the circle
        # Note that we add the tree height to the adjElevation
        # so that we can plot the circle at the top of the tree
        center=c(d[[2]],d[[1]], d[[3]]+d[[4]])
        
        # Define the radius of the circle from the stemDiameter
        # Divide by 200 because stemDiameter is in cm,
        # and is a diameter not a radius!
        # Multiply by 10 to make it easier to see
        radius = d[[5]]/200*10 
        
        # define circle cardinal direction points by
        # offsetting by length `rdius` from the center of the tree
        circle_N = center
        circle_N[2] = circle_N[2]+radius
        
        circle_E = center
        circle_E[1] = circle_E[1]+radius
        
        circle_S = center
        circle_S[2] = circle_E[2]-radius
        
        circle_W = center
        circle_W[1] = circle_W[1]-radius
        
        # plot arcs
        # N to E
        arc3d(
          from = circle_N, 
          to = circle_E, 
          center = center,
          col=col_tree[sp], lwd=2)
        
        # E to S
        arc3d(
          from = circle_E, 
          to = circle_S, 
          center = center,
          col=col_tree[sp], lwd=2)
        
        # S to W
        arc3d(
          from = circle_S, 
          to = circle_W, 
          center = center,
          col=col_tree[sp], lwd=2) 
        
        # W to N
        arc3d(
          from = circle_W, 
          to = circle_N, 
          center = center,
          col=col_tree[sp], lwd=2)
        
      } # end tree_boxes
    } # end if statement
    
  } # end for top_five sp
  
} # end TOS plot
