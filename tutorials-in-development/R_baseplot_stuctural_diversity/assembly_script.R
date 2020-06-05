#Load libraries
library(sp)
library(raster)
library(lidR)
library(rgdal)
library(downloader)
library(httr)
library(jsonlite)
library(plyr)
library(dplyr, quietly = T)


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











