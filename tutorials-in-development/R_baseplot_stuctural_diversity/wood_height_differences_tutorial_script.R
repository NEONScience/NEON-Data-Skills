#This is the script version of the code used in the tree height discrepancy tutorial



library(sp)
library(raster)
library(neonUtilities)
library(geoNEON)









#GET REQUIRED DATA



SITECODE = 'TEAK'


#Get woody vegetation product data and location data
SITECODE <- 'HARV'

  #Use neonUtilities to get woody plant vegetaton data
veglist <- loadByProduct(dpID='DP1.10098.001', site=SITECODE, package="basic", check.size = F)

  #Use neonUtilities to get location data
vegmap <- getLocTOS(veglist$vst_mappingandtagging, 'vst_mappingandtagging')







#Create "Veg" dataframe
  #Combine veglist apparentindividual with vegmap
veg <- merge(veglist$vst_apparentindividual, vegmap, by = c('individualID','namedLocation',
                                                            'domainID', 'siteID', 'plotID'))


  #Filter out rows with missing height measurements, missing northing values, or missing easting values
veg <- veg[which(!is.na(veg$height)),]
veg <- veg[which(!is.na(veg$adjEasting)),]
veg <- veg[which(!is.na(veg$adjNorthing)),]



  #Add column to each row indicating coordinates of tile in which the plot falls
veg$tile_coordinates <- paste0(as.character(round1000(veg$adjEasting)),'_',as.character(round1000(veg$adjNorthing)))




#Get SpatialPolygons Data

#Function veg dataframe and file location of all plots shapefile, returns sp_df of site base plots for which
#  woody plant vegetaton data exists
generate_baseplot_spdf <- function(file_location, in_veg){
  NEON_all_plots <- readOGR(file_location)
  site_base_plots <- NEON_all_plots[(NEON_all_plots$plotID %in% in_veg$plotID)&(NEON_all_plots$subtype == 'basePlot'),]
  return(site_base_plots)
}

base_plots_SPDF <- generate_baseplot_spdf('All_NEON_TOS_Plots_V7/All_NEON_TOS_Plot_Polygons_V7.shp', veg)































#GET VEG PLOT COORDS, VEG BOUNDARY COORDS, VEG UNIQUE COORDS, AND VEG FILES




#Functon to round down coordinates to nearest multiple of 1000
round1000 <- function(x){
  return(1000*floor(x/1000))
}


#Functon to round down coordinates to nearest multiple of 1000
round1000 <- function(x){
  return(1000*floor(x/1000))
}


###FUNCTION: Check if plot is on tile boundary
#Input is a single plot spdf, output is vector of four boolean values indicating whether the plot crosses (respectively)
#  the left, right, lower, or upper boundary of the tile on which the plot's center is located
is_on_boundary <- function(x,y){
  the_names <- c('xMin', 'xMax', 'yMin', 'yMax')
  
  tile_diameter <- 1000
  plot_radius <- 20
  
  tile_x <- round1000(x)
  tile_y <- round1000(y)
  
  plot_extent <-   c((x - plot_radius),(x + plot_radius),(y - plot_radius),(y + plot_radius))
  names(plot_extent) <- the_names
  
  tile_extent <- c((tile_x),(tile_x + tile_diameter),(tile_y),(tile_y + tile_diameter))
  names(tile_extent) <- the_names
  
  
  out <- c(FALSE, FALSE, FALSE, FALSE)
  names(out) <- the_names
  
  #If plot left is less than tile left boundary, or plot lower boundary is less than tile lower boundary
  for(name in c('xMin','yMin')){
    if(plot_extent[name] <= tile_extent[name]){
      out[name] <- TRUE
    }
  }
  for(name in c('xMax', 'yMax')){
    if(plot_extent[name] >= tile_extent[name]){
      out[name] <- TRUE
    }
  }
  
  return(out) 
}




#Function takes base plot polygon, calculates coordinates of tile and returns as a string
get_plot_coords <- function(plot_poly){
  options(scipen = 99999)
  x <- as.numeric(plot_poly[19])
  y <- as.numeric(plot_poly[20])
  
  boundary_vec <- is_on_boundary(x,y)
  
  if(any(boundary_vec)){
    return('Plot crosses a tile boundary')
  }
  #Round to get coordinates of tile
  my_east <- round1000(x)
  my_north <- round1000(y)
  
  out <- paste0(as.character(my_east),'_',as.character(my_north))
  return(out)
}


#Function takes a spatialPolygons dataframe of NEON baseplots, and returns tile coordinates for each plot
build_plot_frame <- function(in_polygons){
  options(stringsAsFactors = FALSE)
  
  
  in_data <- as.data.frame(in_polygons@data)
  results <- apply(in_data, 1, get_plot_coords)
  out <- data.frame("plotID" = as.character(in_data$plotID),
                    "coord_String" = results
  )
  
  return(out)
}


#Function takes spatialPolygons data frame for one plot that crosses a boundary, returns coordinates for 
#  each tile the plot crosses. Output is vector of coordinate strings
get_boundary_plot_coords <- function(plot_spdf_row){
  options(scipen = 99999)
  x <- as.numeric(plot_spdf_row[19])
  y <- as.numeric(plot_spdf_row[20])
  
  east <- round1000(x)
  north <- round1000(y)
  
  
  boundary_vec <- is_on_boundary(x,y)
  
  #If tile is on left boundary, get easting coordinate of tile to left. If plot crosses right boundary, get
  # easting coordinate of tile to right
  if(boundary_vec['xMin']){
    east <- c(east, east - 1000)
  } else if(boundary_vec['xMax']){
    east <- c(east, east + 1000)
  }
  
  
  
  #If plot crosses lower tile boundary, get northing of tile below. Otherwise, if plot crosses upper tile boundary, get 
  # northing of tile above
  if(boundary_vec['yMin']){
    north <- c(north, north - 1000)
  } else if(boundary_vec['yMax']){
    north <- c(north, north + 1000)
  }
  
  
  
  #If tile crosses both boundaries, make vector of four empty strings. Otherwise, make vector of two empty strings
  out <- ifelse(boundary_vec[1]&boundary_vec[2],c('','','',''),c('',''))
  
  #Build vector of coordinate strings
  i <- 1
  for(n_coord in north){
    for(e_coord in east){
      out[i] <- paste0(as.character(e_coord),'_',as.character(n_coord))
      i = i + 1
    }
  }
  
  return(out)
}




#function takes spatial polygons dataframe, dataframe of plots that cross boundaries, returns named nested list 'pseudo-dataframe'
#  with 'row' for each plot, columns being plot id and list of tiles that plot extends into
build_plot_pseudo_frame <- function(in_polygons, bad_plot_df){
  
  bad_plots <- as.vector(bad_plot_df$plotID)
  bad_plots <- in_polygons[in_polygons$plotID %in% bad_plots,]
  N <- length(bad_plots)
  
  #make empty pseudo_dataframe
  out <- list()
  
  for(i in 1:nrow(bad_plots@data)){
    row <- list(plotID = '', coords = character())
    row[['plotID']] <- as.character(bad_plots[i,]$plotID)
    row[['coords']] <- get_boundary_plot_coords(bad_plots@data[i,])
    out[[i]] <- row
  }
  
  return(out)
}

#Function takes coordinate dataframe and boundary coordinate pseudo-dataframe, returns list of all unique coordinates
get_unique_coordinates <- function(coords_df, boundaries_pdf){
  N <- length(boundaries_pdf)
  
  #Get vector of coordinates from plot coordinates dataframe
  out_coords <- as.vector(coords_df$coord_String)
  
  #Append coordinates from boundary plot nested list to coordinate vector
  if(N > 0){
    for(i in seq(1,N)){
      out_coords <- append(out_coords, boundaries_pdf[[i]][['coords']])
    }
  }
  
  
  out_coords <- unique(out_coords)
  
  return(out_coords)
}


#Function takes coordinate dataframe and boundary coordinate pseudo-dataframe, returns list of all unique coordinates
get_unique_coordinates <- function(coords_df, boundaries_pdf){
  N <- length(boundaries_pdf)
  
  #Get vector of coordinates from plot coordinates dataframe
  out_coords <- as.vector(coords_df$coord_String)
  
  #Append coordinates from boundary plot nested list to coordinate vector
  if(N > 0){
    for(i in seq(1,N)){
      out_coords <- append(out_coords, boundaries_pdf[[i]][['coords']])
    }
  }
  
  
  out_coords <- unique(out_coords)
  
  return(out_coords)
}




#  Get coordinates for all plots not on a tile boundary, then split by whether plot is on a boundary
coord_df <- build_plot_frame(base_plots_SPDF)

boundary_df <- coord_df[coord_df$coord_String == 'Plot crosses a tile boundary',]


coord_df <- coord_df[coord_df$coord_String != 'Plot crosses a tile boundary',]

#  Get coordinates for plots on boundary tiles IF there are any
boundary_list <- list()

if(nrow(boundary_df) > 0){
  boundary_list <- build_plot_pseudo_frame(base_plots_SPDF, boundary_df)
}



#  Get unique coordinates, coordinates for each necessary tile
coord_unique <- get_unique_coordinates(coord_df, boundary_list)

















#CREATE CHM LIST

# Download Files
#Download CHM for each tile coordinate in coord_unique

for(coord in coord_unique){
  parts <- unlist(strsplit(coord, '_'))
  tile_east <- as.integer(parts[1])
  tile_north <- as.integer(parts[2])


  byTileAOP(dpID="DP3.30015.001", site=SITECODE, year="2017", 
          easting=tile_east, 
          northing=tile_north,
          savepath=paste0(getwd(),'/data/lidar_data'),
          check.size = F)

}

rm(coord)




#Read CHM Data into R as list of Raster Objects
chm_list <- list()

for(i in 1:length(coord_unique)){
  this_chm <- raster(paste0(getwd(),"/data/lidar_data/DP3.30015.001/2017/FullSite/D01/2017_HARV_4/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D01_",SITECODE,"_DP3_",coord_unique[i],"_CHM.tif"))
  chm_list <- append(chm_list, list(list(coord = coord_unique[i], chm = this_chm)))
}
rm(this_chm)















#CALCULATING HIEGHT DISCREPANCY VALUES


###Function takes vegetation dataframe and CHM, plots relationship between CHM heights and measured heights of trees
height_discrepency <- function(in_veg, in_chm){
  #For each chm/plot in list, extract tree heights, and compare them to measured tree heights
  #Remove rows from in_veg that lack height values
  
  
  #Extract veg data that falls inside CHM
  vegsub <- in_veg[which(in_veg$adjEasting >= extent(in_chm)[1] &
                           in_veg$adjEasting <= extent(in_chm)[2] &
                           in_veg$adjNorthing >= extent(in_chm)[3] & 
                           in_veg$adjNorthing <= extent(in_chm)[4]),]
  #Extract CHM data for each tree, with buffer matching coordinate uncertainty
  bufferCHM <- extract(in_chm, cbind(vegsub$adjEasting, 
                                     vegsub$adjNorthing),
                       buffer=vegsub$adjCoordinateUncertainty, 
                       fun=max)
  
  
  
  #Comparison Method Two: Tree Based
  #  Sort veg structure data by height
  vegsub <- vegsub[order(vegsub$height, decreasing = T),]
  
  #  For each tree x, we want to estimate which nearby trees may lay beneath the canopy of x. Iterate over all trees:
  #Caluclate the distance of each tree from target tree
  #Choose an estimate for canopy size, and remove trees within that distance of main tree
  
  vegfil <- vegsub
  
  for(i in 1:nrow(vegsub)){
    if(is.na(vegfil$height[i])){
      next
    }
    #Calculate distance of each tree from target tree
    dist <- sqrt((vegsub$adjEasting[i] - vegsub$adjEasting)^2+
                   (vegsub$adjNorthing[i] - vegsub$adjNorthing)^2)
    
    #Choose estimate for canopy size as fraction of height, and remove trees within that distance
    vegfil$height[which(dist<0.3*vegsub$height[i] & 
                          vegsub$height<vegsub$height[i])] <- NA
  }
  
  #Remove empty entries
  vegfil <- vegfil[which(!is.na(vegfil$height)),]
  
  
  #Exclude dead or broken trees
  vegfil <- vegfil[which(vegfil$plantStatus=="Live"),]
  
  if(length(vegfil$height) > 0){
    #Extract raster values based on filtered trees
    filterCHM <- extract(in_chm, cbind(vegfil$adjEasting, vegfil$adjNorthing),
                         buffer=vegfil$adjCoordinateUncertainty+1, fun=max)
    
    plot(filterCHM~vegfil$height, pch=20, 
         xlab="Height", ylab="Canopy height model")
    lines(c(0,50), c(0,50), col="grey")
    out <- mean(vegfil$height - filterCHM)
  }else{
    print('After filtering, there were no Non-NA values')
  }
  return(out)
}





#Add emtpy column for height discrepancy values
DF$height_discrepancy <- NA




#Add data for plots not falling on tile boundaries

#  For each non-boundary plot, calculate the height discrepancy and save that value in the dataframe
for(i in 1:nrow(coord_df)){
  plot_row <- coord_df[i,]
  #RUn through CHM list until the CHM for the tile the plot is located on is reached
  for(entry in chm_list){
    if(entry$coord == plot_row$coord_String){
      #Get height discrepancy value
      height_dif <- calculate_height_discrepancy(veg, coord_df[i, 'plotID'], entry$chm)
      
      #Assign resulting value to output dataframe
      DF[DF$plotID == plot_row$plotID,]$height_discrepancy <- height_dif
    }
    
  }
}




#Add data for plots falling on tile boundaries

#For each plot falling on a boundary
for(boundary_plot in boundary_list){
  
  #Make list of CHMs needed
  plot_chms <- list()
  
  #Run through CHM list
  for(chm_entry in chm_list){
    #Save CHMs for tiles on which the plot is present
    if(chm_entry$coord %in% boundary_plot$coords){
      plot_chms <- append(plot_chms, list(chm_entry))
    }
  }
  print(length(plot_chms))
  #Initialize merged CHM
  merged_chm <- plot_chms[[1]][['chm']]
  
  #Merge additional CHMs into merged CHM
  for(i in 2:length(plot_chms)){
    merged_chm <- merge(merged_chm, plot_chms[[i]][['chm']])
  }
  
  #Run height difference calculation
  height_difference <- calculate_height_discrepancy(veg, boundary_plot$plotID, merged_chm)
  DF[DF$plotID == boundary_plot$plotID,]$height_discrepancy <- height_difference
  
}






