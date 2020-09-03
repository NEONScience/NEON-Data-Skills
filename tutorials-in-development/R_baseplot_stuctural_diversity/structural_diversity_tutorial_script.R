#This is the script version of the code used for the baseplot structural diversity metrics tutorial
# The code should be identical to that of the tutorial, except that the portion after determining the most recent date for which
#  data is available is wrapped in an 'if'


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
  return(1000*floor(x/1000))
}




















#MAIN












#Load TOS Plot Shape Files into R
#Generate Base Plots Spatial Polygon DF, and plot


SITECODE = 'SOAP'

NEON_all_plots <- readOGR('All_NEON_TOS_Plots_V7/All_NEON_TOS_Plot_Polygons_V7.shp')
base_plots_SPDF <- NEON_all_plots[(NEON_all_plots$siteID == SITECODE)&(NEON_all_plots$subtype == 'basePlot'),]

rm(NEON_all_plots)

plot(base_plots_SPDF, border = 'blue')














###FUNCTION: Check if plot is on tile boundary

#Function checks if plot crosses a tile boundary
#Input is a single plot spdf, output is vector of two boolean values
#  First output boolean is whether plot crosses a horizontal boundary, second is whether it crosses vertical boundary
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





###FUNCTION: Get Plot Coordinates

#Function takes base plot entry, calculates coordinates of tile and returns as a string
get_plot_coords <- function(plot_spdf){
  options(scipen = 99999)
  x <- as.numeric(plot_spdf[19])
  y <- as.numeric(plot_spdf[20])
  
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














#Build Coordinate dataframe, then split by whether plot lays on a tile boundary

coord_df <- data.frame("plotID" = as.character(base_plots_SPDF$plotID),
                       "coord_String" = apply(base_plots_SPDF@data, 1, get_plot_coords),
                       stringsAsFactors = FALSE
)


boundary_df <- coord_df[coord_df$coord_String == 'Plot crosses a tile boundary',]
coord_df <- coord_df[coord_df$coord_String != 'Plot crosses a tile boundary',]











#Get coordinates for plots on boundary tiles
if(nrow(boundary_df) > 0){
  bad_plots <- as.vector(boundary_df$plotID)
  bad_plots <- base_plots_SPDF[base_plots_SPDF$plotID %in% bad_plots,]
  N <- length(bad_plots)
  
}

#make empty "pseudo dataframe" list
boundary_list <- list()




###Function: Get Boundary Plot Coords

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




if(nrow(boundary_df) != 0){
  
  #Fill list with plot IDs and tile coordinates for plots on tile boundaries
  for(i in 1:nrow(bad_plots@data)){
    row <- list(plotID = '', coords = character())
    row[['plotID']] <- as.character(bad_plots@data[i,]$plotID)
    row[['coords']] <- get_boundary_plot_coords(bad_plots@data[i,])
    boundary_list[[i]] <- row
  }
  
  
  #Remove object no longer needed
  rm(bad_plots, row, boundary_df)
  
  
}





#Get unique coordinates, coordinates for each necessary tile

bound_N <- length(boundary_list)

#Get vector of coordinates from plot coordinates dataframe
coord_unique <- as.vector(coord_df$coord_String)

#Append coordinates from boundary plot nested list to coordinate vector
if(bound_N > 0){
  for(i in 1:bound_N){
    coord_unique <- append(coord_unique, boundary_list[[i]][['coords']])
  }
}


coord_unique <- unique(coord_unique)









#Get data from NEON API to determine URLs of required files

  #Make site request to get most recent date for which data is available

PRODUCTCODE <- 'DP1.30003.001'
SERVER <- 'https://data.neonscience.org/api/v0/'



site_req <- GET(paste0(SERVER,'sites/',SITECODE))
site_data <- fromJSON(content(site_req, as = 'text'), flatten = T, simplifyDataFrame = T)$data

dates <- site_data$dataProducts[site_data$dataProducts$dataProductCode == PRODUCTCODE,]$availableMonths
DATE <- ''

if(length(dates) == 0){
  print('This data product not available at selected site')
}else{
  DATE <- dates[[1]][length(dates[[1]])]
}


#Remove site request
rm(site_req, site_data)


if(DATE != ''){
  #Make data request
  data_req <- GET(paste0(SERVER,'data/',PRODUCTCODE,'/',SITECODE,'/',DATE))
  data_avail <- fromJSON(content(data_req, as = 'text'), flatten = T, simplifyDataFrame = T)
  
  
  
  
  
  
  
  
  rm(data_req)
  
  
  
  
  
  
  #Use data request information to get names and urls of files as a data frame
  
  file_N <- length(coord_unique)
  
  files_df <- data.frame(name = rep('',file_N), url = rep('', file_N), coords = rep(NA, file_N))
  
  for(i in 1:file_N){
    
    
    #Get name of file
    file_name <- data_avail$data$files[
      intersect(
        intersect(
          grep(coord_unique[i], data_avail$data$files$name),
          grep('.laz', data_avail$data$files$name)),
        grep('classified_point_cloud', data_avail$data$files$name)
      ),
      'name']
    
    
    #Get URL of file
    file_url <- data_avail$data$files[
      intersect(
        intersect(
          grep(coord_unique[i], data_avail$data$files$name),
          grep('.laz', data_avail$data$files$name)),
        grep('classified_point_cloud', data_avail$data$files$name)
      ),
      'url']
    
    
    if(length(file_name) != 0){
      files_df[i,] <- list(name = file_name, url = file_url, coords = coord_unique[i])
    }else{
      print("Warning: There was no LiDAR file for one of the provided coordinates")
      files_df[i,] <- list(name = 'bad coord', url = 'bad_coord', coords = coord_unique[i])
    }
    
  }
  
  #Remove iterating variables and reponses, and any empty rows
  rm(file_name, file_url)
  
  #Seperate out bad coordinates
  
  bad_coords <- files_df[files_df$name == 'bad coord',]$coords
  files_df <- files_df[files_df$name != 'bad coord',]
  
  
  #Remove bad coordinates from coord_unique
  coord_unique <- setdiff(coord_unique, bad_coords)
  
  
  #Remove any non-boundary plots with bad coordinates
  bad_plot_num <- as.character(length(coord_df[coord_df$coord_String %in% bad_coords,'coord_string']))
  print(paste0('Removed ',bad_plot_num,' non-boundary plots with missing tiles'))
  coord_df <- coord_df[!(coord_df$coord_String %in% bad_coords),]
  
  
  #Remove any boundary plots with bad coordinates
  if(bound_N > 0){
    new_list <- list()
    bad_plot_num <- 0
    
    for(i in 1:length(boundary_list)){
      alpha <- boundary_list[[i]][['coords']][1] %in% bad_coords
      beta <- boundary_list[[i]][['coords']][2] %in% bad_coords
      if(!(alpha|beta)){
        new_list[[i]] <- boundary_list[[i]]
      }else{
        bad_plot_num <- bad_plot_num + 1
      }
    }
    
    boundary_list <- new_list
    
    if(bad_plot_num > 0){
      print(paste0('Removed ',as.character(bad_plot_num),' boundary plots with missing tiles'))
    }
    
  }
  
  
  
  #Remove any bad coordinates from coord_unique
  coord_unique <- setdiff(coord_unique, bad_coords)
  
  #Install any files not already present
  for(i in 1:length(coord_unique)){
    if(!file.exists(files_df[i,]$name)){
      #Try downloading file using full URL
      download.file(files_df[i,]$url, destfile = paste0(getwd(),'/',files_df[i,]$name))
      if(!file.exists(files_df[i,]$name)){
        #Try downloading file using trimmed url
        download.file(paste0(strsplit(files_df[1,]$url, '.laz')[[1]][1], '.laz'),
                      destfile = paste0(getwd(),'/',files_df[i,]$name))
      }
      
    }
  }
  
  
  
  
  
  ###FUNCTION: Calculate Boundary Metrics
  
  #Function takes row of boundary coordinates nested list, plot polygons spatial df, and file df
  #Gets two point cloud files needed for plot and combines them in one object, calculates diversity metrics
  calculate_boundary_metrics <- function(boundary_plot, plots_spdf, file_df){
    
    #Extract rows for required files, record number of extracted rows
    files_sub <- file_df[file_df$coords %in% boundary_plot$coords,]
    N <- nrow(files_sub)
    
    plot_data <- plots_spdf[plots_spdf$plotID == boundary_plot$plotID,]
    
    #Get first LAS object
    merged_LAS <- readLAS(paste0(getwd(),'/',files_sub[1,]$name))
    
    #Get additional LAS objects and combine with first
    for(i in 2:N){
      new_LAS <- readLAS(paste0(getwd(),'/',files_sub[i,]$name))
      merged_LAS <- rbind(merged_LAS, new_LAS)
    }
    
    #calculate metrics
    metrics <- plot_diversity_metrics(plot_data, merged_LAS)
    return(metrics)
  }  
  
  
  
  
  
  
  
  
  
  
  #Record number of plots not on tile boundaries
  
  norm_N <- nrow(coord_df)
  N <- bound_N + norm_N
  
  #Initialize empty dataframe
  
  
  metric_df <- data.frame(plotID = rep('',N),
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
  
  #Add rows for boundary plots
  if(bound_N > 0){
    for(i in seq(1, bound_N)){
      #Attempt to calculate boundary metrics
      attempt <- try(calculate_boundary_metrics(boundary_list[[i]], base_plots_SPDF, files_df))
      if(class(attempt) != 'try-error'){
        #If boundary metrics were calculate successfully, assign them as values to row of dataframe
        metric_df[i,1] <- as.character(boundary_list[[i]]$plotID)
        metric_df[i,(2:16)] <- attempt
      }else{
        print(paste0('Unable to calculate boundary metrics for plot ',as.character(boundary_list[[i]]$plotID)))
      }
      
    }
  }
  
  
  #Add rows for normal plots
  k <- bound_N + 1
  
  #For each tile  
  for(i in seq(1,length(coord_unique))){
    
    file_tile <- files_df[i,]
    plot_ids <- coord_df[(coord_df$coord_String == file_tile$coords),]$plotID
    
    #Get plot located in tile, and make LAS of tile
    coord_plots <- base_plots_SPDF[(base_plots_SPDF$plotID %in% plot_ids),]
    tile_LAS<- readLAS(paste0(getwd(),'/',file_tile$name))
    
    coord_N = length(coord_plots$plotID)
    
    #For each plot located entirely within current tile
    if(coord_N != 0){
      #Try to calculate boundary metrics
      for(j in seq(1,coord_N)){
        attempt <- try(plot_diversity_metrics(coord_plots[j,], tile_LAS))
        if(class(attempt) != 'try-error'){
          metric_df[k,1] <- as.character(coord_plots[j,]$plotID)
          metric_df[k,(2:16)] <- plot_diversity_metrics(coord_plots[j,], tile_LAS)
        }else{
          print(paste0('Unable to calculate metrics for ',as.character(coord_plots[1,]$plotID)))
        }
        k <- k + 1
      }
    }
  }
  
  #Remove empty rows from dataframe
  metric_df <- metric_df[which(!is.na(metric_df[,2])),]
  
  
  #Sort output dataframe rows by plot id
  metric_df <- arrange(metric_df, plotID)
  
  #Uninstall files when done
  #for(file_ in files_df){
  #  file.remove(file_)
  #}
  
  print(metric_df)
  
}

