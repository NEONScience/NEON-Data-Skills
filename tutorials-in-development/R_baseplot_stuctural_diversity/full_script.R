#LOAD LIBRARIES
library(sp)
library(raster)
library(lidR)
library(rgdal)
library(downloader)
library(httr)
library(jsonlite)
library(plyr)
library(dplyr, quietly = T)











# FUNCTIONS TO CALCULATE METRICS










#Given a distributed plot spatial dataframe and the LAS object of a lidar point cloud file covering the plot,
#  this function returns an LAS object containing the plot and a surrounding buffer zone

make_buffered_las <- function(plot_spdf, tile_las, buffer = 50){
  
  #Convert plot SPdf to same CRS as tile_las
  plot_converted <- spTransform(plot_spdf, as.character(tile_las@proj4string))
  plot_extent <- extent(plot_converted)
  
  
  #Define Plot center and buffer
  x <- plot_spdf$easting
  y <- plot_spdf$northing
  
  
  in_radius = 20
  out_radius = in_radius + buffer
  
  
  #Clip out plot and buffer
  data.buffered <- lidR::lasclipRectangle(tile_las, xleft = (x - out_radius), xright = (x + out_radius),
                                          ytop = (y + out_radius), ybottom = (y - out_radius))
  
  
  
  #Normalize buffered plot LAS
  dtm <- grid_terrain(data.buffered, 1, kriging(k = 10L))
  data.buffered <- lasnormalize(data.buffered, dtm)
  
  
  #Extract plot area from normlazed data; in other words, remove buffer
  data.plot <- lidR::lasclipRectangle(data.buffered, xleft = (x - in_radius), xright = (x + in_radius),
                                      ytop = (y + in_radius), ybottom = (y - in_radius))
  
  #Remove unreliable values
  data.plot@data$Z[data.plot@data$Z <= .5] <- NA
  
  
  
  return(data.plot)
  
  
  
}

#Given am normalized LAS object for a plot, and SP dataframe row for the same plot, this function calculates and returns
# a named list of diversity indices
structural_diversity_metrics <- function(data.40m, plot_spatPolyDF) {
  x <- plot_spatPolyDF$easting
  y <- plot_spatPolyDF$northing
  chm <- grid_canopy(data.40m, res = 1, dsmtin()) 
  mean.max.canopy.ht <- mean(chm@data@values, na.rm = TRUE) 
  max.canopy.ht <- max(chm@data@values, na.rm=TRUE) 
  rumple <- rumple_index(chm) 
  top.rugosity <- sd(chm@data@values, na.rm = TRUE) 
  cells <- length(chm@data@values) 
  chm.0 <- chm
  chm.0[is.na(chm.0)] <- 0 
  zeros <- which(chm.0@data@values == 0) 
  deepgaps <- length(zeros) 
  deepgap.fraction <- deepgaps/cells 
  cover.fraction <- 1 - deepgap.fraction 
  vert.sd <- cloud_metrics(data.40m, sd(Z, na.rm = TRUE)) 
  sd.1m2 <- grid_metrics(data.40m, sd(Z, na.rm = TRUE), 1) 
  sd.sd <- sd(sd.1m2[,3], na.rm = TRUE) 
  Zs <- data.40m@data$Z
  Zs <- Zs[!is.na(Zs)]
  entro <- entropy(Zs, by = 1) 
  gap_frac <- gap_fraction_profile(Zs, dz = 1, z0=3)
  GFP.AOP <- mean(gap_frac$gf) 
  LADen<-LAD(Zs, dz = 1, k=0.5, z0=3) 
  VAI.AOP <- sum(LADen$lad, na.rm=TRUE) 
  VCI.AOP <- VCI(Zs, by = 1, zmax=100) 
  out.plot <- list(x, y, mean.max.canopy.ht,max.canopy.ht, 
                   rumple,deepgaps, deepgap.fraction, 
                   cover.fraction, top.rugosity, vert.sd, 
                   sd.sd, entro, GFP.AOP, VAI.AOP,VCI.AOP) 
  names(out.plot) <- 
    c("easting", "northing", "mean.max.canopy.ht.aop",
      "max.canopy.ht.aop", "rumple.aop", "deepgaps.aop",
      "deepgap.fraction.aop", "cover.fraction.aop",
      "top.rugosity.aop","vert.sd.aop","sd.sd.aop", 
      "entropy.aop", "GFP.AOP.aop",
      "VAI.AOP.aop", "VCI.AOP.aop")
  return(out.plot)
}


#Given spatial dataframe row for a distributed plot, and the LAS object of a lidar point cloud covering tile with plot, 
#  this function calculates diversity metrics for the area around the plot.


plot_diversity_metrics <- function(plot_spdf, in_LAS){
  data.distributed_plot <- make_buffered_las(plot_spdf, in_LAS)
  return(structural_diversity_metrics(data.distributed_plot, plot_spdf))
}
















#FUNCTIONS TO ASSEMBLE DATA ON SITES, COORDINATES, FILES






















round1000 <- function(x){
  y = floor(x/1000)
  return(y*1000)
}





#Function takes site code and file location of all plots shapefile, returns sp_df of site base plots
generate_baseplot_spdf <- function(file_location, site_code){
  NEON_all_plots <- readOGR(file_location)
  site_base_plots <- NEON_all_plots[(NEON_all_plots$siteID == site_code)&(NEON_all_plots$subtype == 'basePlot'),]
  return(site_base_plots)
}


#Function checks if plot crosses a tile boundary
#Input is a single plot spdf, output is vector of two boolean values
#  First output boolean is whether plot crosses a horizontal boundary, second is whether it crosses vertical boundary
is_on_boundary <- function(x,y){
  answer <- c(FALSE,FALSE)
  
  
  radius <- 20
  
  extent_vec <- c((x - radius),(x + radius),(y - radius),(y + radius))
  names(extent_vec) <- c('xMin', 'xMax', 'yMin', 'yMax')
  
  #If the plot is on a horizontal tile boundary, the nearest horizontal tile boundary below yMax will be above yMin
  bound_below <- round1000(extent_vec['yMax'])
  if(bound_below >= extent_vec['yMin']){
    answer[1] <- TRUE
  }
  
  #If the plot is on a vertical tile boundary, the nearest vertical tile boundary left of xMax will be right of yMin
  bound_left <- round1000(extent_vec['xMax'])
  if(bound_left >= extent_vec['xMin']){
    answer[2] <- TRUE
  }
  
  return(answer)
}


#Function takes base plot entry, calculates coordinates of tile and returns as a string
get_plot_coords <- function(plot_spdf){
  options(scipen = 99999)
  x <- as.numeric(plot_spdf[19])
  y <- as.numeric(plot_spdf[20])
  
  boundary_vec <- is_on_boundary(x,y)
  
  if(boundary_vec[1]|boundary_vec[2]){
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
  
  #If tile is on horizontal boundary, get additional northing coordinate
  if(boundary_vec[1]){
    east <- c(east, (east + 1000))
    
  }
  #If tile is on horizontal boundary, get additional easting coordinate
  if(boundary_vec[2]){
    north <- c(north, (north + 1000))
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
  
  for(i in seq(1,4)){
    row <- list(plotID = '', coords = character())
    row[['plotID']] <- as.character(bad_plots[i,]$plotID)
    row[['coords']] <- get_boundary_plot_coords(bad_plots@data[i,])
    out[[i]] <- row
  }
  
  return(out)
}

#Function takes coordinate dataframe and boundary coordinate pseudo-dataframe, returns list of all unique coordinates
get_unique_coordinates <- function(coords_df, boundaries_df){
  N <- length(boundaries_df)
  
  #Get vector of coordinates from plot coordinates dataframe
  out_coords <- as.vector(coords_df$coord_String)
  
  #Append coordinates from boundary plot nested list to coordinate vector
  for(i in seq(1,N)){
    out_coords <- append(out_coords, boundaries_df[[i]][['coords']])
  }
  
  out_coords <- unique(out_coords)
  
  return(out_coords)
}



#Function takes coordinates of tile as string, date, and site; returns named vector with file name and url
find_point_cloud <- function(coords, DATE, SITECODE){
  #Define Request Parameters
  PRODUCTCODE <- 'DP1.30003.001'
  SERVER <- 'https://data.neonscience.org/api/v0/'
  
  #Make data request
  data_req <- GET(paste0(SERVER,'data/',PRODUCTCODE,'/',SITECODE,'/',DATE))
  data_avail <- fromJSON(content(data_req, as = 'text'), flatten = T, simplifyDataFrame = T)
  
  #Get name of file
  file_name <- data_avail$data$files[intersect(
    grep(coords, data_avail$data$files$name),
    grep('.laz', data_avail$data$files$name)
  ),'name']
  
  
  #Get URL of file
  file_url <- data_avail$data$files[intersect(
    grep(coords, data_avail$data$files$name),
    grep('.laz', data_avail$data$files$name)
  ),'url']
  
  
  
  out <- c(name = file_name, url = file_url, coords = coords)
  
  return(out)
}




















#FUNCTIONS THAT GENERATE METRICS DATA FRAME























#Function takes row of file df, coords df, and plots sp_df; calculates structural diversity metrics for each
#  plot located in tile and returns results as dataframe
assemble_tile_metrics <- function(file_tile, coorddf, plot_sdf){
  
  plot_ids <- coorddf[(coorddf$coord_String == file_tile$coords),]$plotID
  
  plots <- plot_sdf[(plot_sdf$plotID %in% plot_ids),]
  tile_LAS<- readLAS(paste0(getwd(),'/',file_tile$name))
  
  
  #Prepare empty data frame
  N <- length(plots)
  DF <- data.frame(plotID = rep('',N),
                   x = rep(NA,N),
                   y = rep(NA,N),
                   mean.max.canopy.ht = rep(NA,N),
                   max.canopy.ht = rep(NA,N), 
                   rumple = rep(NA,N),
                   deepgaps = rep(NA,N),
                   deepgap.fraction = rep(NA,N),
                   cover.fraction = rep(NA,N),
                   top.rugosity = rep(NA,N),
                   vert.sd = rep(NA,N), 
                   sd.sd = rep(NA,N),
                   entro = rep(NA,N),
                   GFP.AOP = rep(NA,N),
                   VAI.AOP = rep(NA,N),
                   VCI.AOP = rep(NA,N)) 
  
  if(N != 0){
    for(i in seq(1,N)){
      DF[i,1] <- as.character(plots[i,]$plotID)
      DF[i,(2:16)] <- plot_diversity_metrics(plots[i,], tile_LAS)
    }
  }
  
  
  return(DF)
  
}

#Function takes row of boundary coordinates nested list, plot polygons spatial df, and file df
#Gets two point cloud files needed for plot and combines them in one object, calculates diversity metrics
calculate_boundary_metrics <- function(boundary_plot, plots_spdf, file_df){
  
  #Extract rows for required files, record number of extracted rows
  files_sub <- file_df[file_df$coords %in% boundary_plot$coords,]
  N <- length(files_sub$coords)
  
  plot_data <- plots_spdf[plots_spdf$plotID == boundary_plot$plotID,]
  
  #Get first LAS object
  merged_LAS <- readLAS(paste0(getwd(),'/',files_sub[1,]$name))
  
  #Get additional LAS objects and combine with first
  for(i in seq(2,N)){
    new_LAS <- readLAS(paste0(getwd(),'/',files_sub[i,]$name))
    merged_LAS <- rbind(merged_LAS, new_LAS)
  }
  
  #calculate metrics
  metrics <- plot_diversity_metrics(plot_data, merged_LAS)
  return(metrics)
}



#Function takes plots sp_df, coords df, and file df. Calculates and compiles diversity metrics for each plot.
#For every file, install file, calculate diveristy metrics of matching plots, remove file

build_metrics_df <- function(this_plots_spdf, this_coords_df, this_files_df, this_boundaries_df){
  #Initialize empty dataframe
  bound_N <- length(this_boundaries_df)
  
  DF <- data.frame(plotID = rep('',bound_N),
                   x = rep(NA,bound_N),
                   y = rep(NA,bound_N),
                   mean.max.canopy.ht = rep(NA,bound_N),
                   max.canopy.ht = rep(NA,bound_N), 
                   rumple = rep(NA,bound_N),
                   deepgaps = rep(NA,bound_N),
                   deepgap.fraction = rep(NA,bound_N),
                   cover.fraction = rep(NA,bound_N),
                   top.rugosity = rep(NA,bound_N),
                   vert.sd = rep(NA,bound_N), 
                   sd.sd = rep(NA,bound_N),
                   entro = rep(NA,bound_N),
                   GFP.AOP = rep(NA,bound_N),
                   VAI.AOP = rep(NA,bound_N),
                   VCI.AOP = rep(NA,bound_N)) 
  
  #Add rows for boundary plots
  if(bound_N > 0){
    for(i in seq(1, bound_N)){
      DF[i,1] <- as.character(this_boundaries_df[[i]]$plotID)
      DF[i,(2:16)] <- calculate_boundary_metrics(this_boundaries_df[[i]], this_plots_spdf, this_files_df)
    }
  }
  
  
  
  #Create metrics data for non-boundary plots by file, and merge with DF
  file_N <- length(this_files_df)
  
  for(i in seq(1,file_N)){
    new_file_DF <- assemble_tile_metrics(this_files_df[i,],this_coords_df,this_plots_spdf)
    DF <- rbind(DF, new_file_DF)
  }
  
  DF <- arrange(DF, plotID)
  
  return(DF)
}














#MAIN


#Function takes site code, returns list of all .laz files needed to cover all baseplots of that site
main_files <- function(sitecode){
  #Load TOS Plot Shape Files into R
  base_plots_SPDF <- generate_baseplot_spdf('All_NEON_TOS_Plots_V7/All_NEON_TOS_Plot_Polygons_V7.shp', sitecode)
  
  #Plot base plots
  plot(base_plots_SPDF, border = 'blue')
  
  #Get coordinates for all plots not on a tile boundary, then split by whether plot is on a boundary
  coord_df <- build_plot_frame(base_plots_SPDF)
  
  boundary_df <- coord_df[coord_df$coord_String == 'Plot crosses a tile boundary',]
  coord_df <- coord_df[coord_df$coord_String != 'Plot crosses a tile boundary',]
  
  #Get coordinates for plots on boundary tiles
  boundary_list <- build_plot_pseudo_frame(base_plots_SPDF, boundary_df)
  
  #Get unique coordinates, coordinates for each necessary tile
  coord_unique <- get_unique_coordinates(coord_df, boundary_list)
  
  #Get file names and urls for all necessary tiles
  files_df <- ldply(coord_unique, find_point_cloud, SITECODE = sitecode, DATE = '2019-06')

  
  return(files_df)
}





#Function takes site code, returns dataframe of structural diversity metrics for all site baseplots
#Currently requires the necessary point cloud files to already be present in working directory.

main <- function(sitecode){
  #Load TOS Plot Shape Files into R
  base_plots_SPDF <- generate_baseplot_spdf('All_NEON_TOS_Plots_V7/All_NEON_TOS_Plot_Polygons_V7.shp', sitecode)
  
  #Plot base plots
  plot(base_plots_SPDF, border = 'blue')
  
  #Get coordinates for all plots not on a tile boundary, then split by whether plot is on a boundary
  coord_df <- build_plot_frame(base_plots_SPDF)
  
  boundary_df <- coord_df[coord_df$coord_String == 'Plot crosses a tile boundary',]
  coord_df <- coord_df[coord_df$coord_String != 'Plot crosses a tile boundary',]
  
  #Get coordinates for plots on boundary tiles
  boundary_list <- build_plot_pseudo_frame(base_plots_SPDF, boundary_df)
  
  #Get unique coordinates, coordinates for each necessary tile
  coord_unique <- get_unique_coordinates(coord_df, boundary_list)
  
  #Get file names and urls for all necessary tiles
  files_df <- ldply(coord_unique, find_point_cloud, SITECODE = sitecode, DATE = '2019-06')
  
  
  #build final dataframe of stuctural diversity metrics
  metric_df <- build_metrics_df(base_plots_SPDF, coord_df, files_df, boundary_list)
  
  return(metric_df)
}


DF <- main('SOAP')


