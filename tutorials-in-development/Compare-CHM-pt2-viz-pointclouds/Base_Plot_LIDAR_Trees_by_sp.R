# Tutorial In Development
# By Donal O'Leary and Max Burner
# NationalEcological Observatory Network
# July 2, 2020


library(raster)
library(lidR)
library(rgdal)
library(downloader)
library(httr)
library(jsonlite)
library(dplyr)
library(sf)
library(neonUtilities)
library(geoNEON)
library(rgl)

stringsAsFactors=F

## Define Functions:
####FUNCTION: Round value down to nearest multiple of 1000
round1000 <- function(x){
  return(1000*floor(x/1000))
}


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


## Download plots shapefile
setwd("~/Downloads/")
download.file(url="https://data.neonscience.org/api/v0/documents/All_NEON_TOS_Plots_V8",
              destfile = "All_NEON_TOS_Plots_V8.zip")
unzip(zipfile="All_NEON_TOS_Plots_V8.zip", exdir = "All_NEON_TOS_Plots_V8")
NEON_all_plots <- st_read('All_NEON_TOS_Plots_V8/All_NEON_TOS_Plot_Polygons_V8.shp')


## Define sites of interest

### Add base plots?
#SITECODES = c('BART', 'HARV', 'WREF')
SITECODES = c("OSBS")
#SITECODE='BART'

for(SITECODE in SITECODES){
base_plots_SPDF <- NEON_all_plots[(NEON_all_plots$siteID == SITECODE)&(NEON_all_plots$subtype == 'basePlot'),]

# Make new data.frame of plot coordinates
coord_df <- data.frame("plotID" = as.character(base_plots_SPDF$plotID),
                       "coord_String" = apply(base_plots_SPDF, 1, get_plot_coords))


# Remove the plots that cross a mosaic tile boundary
coord_df <- coord_df[coord_df$coord_String != 'Plot crosses a tile boundary',]

# Count how many plots are in each mosaic tile
coord_count = coord_df %>% group_by(coord_String) %>%
  summarise(count=n()) %>% arrange(desc(count))

# Convert coord_String to a string (might be a factor?)
coord_count$coord_String=as.character(coord_count$coord_String)
## most base plots is coord_count$coord_String[1]

## Begin API call process
SERVER <- 'https://data.neonscience.org/api/v0/'
PRODUCTCODE <- 'DP1.30003.001'

site_req <- GET(paste0(SERVER,'sites/',SITECODE))
site_data <- fromJSON(content(site_req, as = 'text'), flatten = T, simplifyDataFrame = T)$data


#Get the most recent month for which data is available
dates <- site_data$dataProducts[site_data$dataProducts$dataProductCode == PRODUCTCODE,]$availableMonths
DATE <- dates[[1]][length(dates[[1]])]


#Remove site request
rm(site_req, site_data, dates)

data_req <- GET(paste0(SERVER,'data/',PRODUCTCODE,'/',SITECODE,'/',DATE))
data_avail <- fromJSON(content(data_req, as = 'text'), flatten = T, simplifyDataFrame = T)

#Get name of file
file_name <- data_avail$data$files[intersect(
  grep(coord_count[1,1], data_avail$data$files$name),
  grep('.laz', data_avail$data$files$name)
),'name']


#Get URL of file
file_url <- data_avail$data$files[intersect(
  grep(coord_count[1,1], data_avail$data$files$name),
  grep('.laz', data_avail$data$files$name)
),'url']


# Download any files not already present
if(!file.exists(file_name)){
  #Try downloading file using full URL
  download.file(file_url, destfile = paste0(getwd(),'/',file_name))
  if(!file.exists(file_name)){
    #Try downloading file using trimmed url
    download.file(paste0(strsplit(file_url, '.laz')[[1]][1], '.laz'),
                  destdir = paste0(getwd(),'/',file_name))
  }
  
}


# Read in LAS file. You will first read it in, then
# calculate mean and sd of vertical component, then
# filter out vertical outliers (if any)
site_LAS=readLAS(file_name)

### remove outlier lidar point outliers using mean and sd statistics
Z_sd=sd(site_LAS@data$Z)
Z_mean=mean(site_LAS@data$Z)

# make filter string in form filter = "-drop_z_below 50 -drop_z_above 1000"
# You can increase or decrease (from 4) the number of sd's to filter outliers
f= paste("-drop_z_below",(Z_mean-4*Z_sd),"-drop_z_above",(Z_mean+4*Z_sd))

# Read in LAS file, trimming off vertical outlier points
site_LAS=readLAS(file_name, filter = f)


## plot lidar w/ base plots:
# re-project plot shapefile to local UTM zone
base_plots_SPDF <- st_transform(base_plots_SPDF, as.character(site_LAS@proj4string))
base_crop=st_crop(base_plots_SPDF, extent(site_LAS))

# Plot LAS and save as an object - this tells you the (x,y) offset
# Plotting a LAS file offsets all X and Y coordinates by the 
# Lower left corner, so you need to subtract those offsets from 
# anything else that you want to plot into the 3D space!
x = plot(site_LAS)
#quads3d(x=coordinates(base_plots_SPDF)[1:8,1], y=coordinates(base_plots_SPDF)[1:8,2])
coords=as.data.frame(st_coordinates(base_crop))
coords$X=coords$X-x[1] # offset points in X direction
coords$Y=coords$Y-x[2] # offset points in Y direction
coords$Z=rep(base_crop$elevation, each=5)
c=1:nrow(coords)

# Remove every 5th point (redundant where square plot returns to origin)
coords=coords[!c%%5==0,]

# Add plots to 3D space using `quads3d()`
for(i in 1:(nrow(coords)/4)){
  print(i)
  r=((i-1)*4)+1
  quads3d(x=coords$X[r:(r+3)], y=coords$Y[r:(r+3)], z=coords$Z[r:(r+3)]+50,
          add=T, col="red", lwd=2, lit=F)
}


## Clip out individual plots from LiDAR point cloud:

top_left=as.data.frame(st_coordinates(base_crop))
c=1:nrow(top_left)
top_left=top_left[c%%5==1,]

# Make a list of LAS clips of individual plots
plots_LAS <- 
  lasclipRectangle(site_LAS,
                   xleft = (top_left$X), ybottom = (top_left$Y - 40),
                   xright = (top_left$X + 40), ytop = (top_left$Y))



## Download veg structure to add to 3D space:
veglist <- loadByProduct(dpID="DP1.10098.001", site=SITECODE, check.size=F)

veglist_mapping <- veglist$vst_mappingandtagging

veglist_mapping <- veglist_mapping[veglist_mapping$plotID %in% base_crop$plotID,]

vegmap <- getLocTOS(veglist_mapping, 
                    "vst_mappingandtagging")

## Merge tables
veg <- merge(veglist$vst_apparentindividual, vegmap, 
             by=c("individualID","namedLocation",
                  "domainID","siteID","plotID"))


#for(p in 5:length(plots_LAS)){ # Uncomment this line to run all plots
# Just the first two plots
for(p in 4){ 
  
  
  x=plot(plots_LAS[[p]])
  
  tree_boxes=veg[veg$plotID==base_crop$plotID[p],]
  tree_boxes=tree_boxes[!is.na(tree_boxes$height),]
  
  trees_ranked = tree_boxes %>% group_by(taxonID) %>%
    summarise(count=n()) %>% arrange(desc(count))
  
  colors_vec = c("green","red","blue","orange","yellow")
  
  for(s in 1:5){
    
    species_boxes=tree_boxes[tree_boxes$taxonID==trees_ranked$taxonID[s],]
    species_boxes$adjEasting=species_boxes$adjEasting-x[1]
    species_boxes$adjNorthing=species_boxes$adjNorthing-x[2]
    species_boxes=species_boxes[!is.na(species_boxes$adjEasting),]
    
  # Add individual tree
  for(i in 1:(nrow(species_boxes))){
    print(i)
    
    # MAke new data.frame for individual tree
    d=as.data.frame(species_boxes[i,c(58,59,63)])
    d[,3]=as.numeric(d[,3])
    
    # Add new rows for four sides of box
    d[2:4,]=d[1,]
    d[1,1]=d[1,1]+2
    d[1,2]=d[1,2]-2
    
    d[2,1]=d[2,1]+2
    d[2,2]=d[2,2]+2
    
    d[3,1]=d[3,1]-2
    d[3,2]=d[3,2]+2
    
    d[4,1]=d[4,1]-2
    d[4,2]=d[4,2]-2
    
    d[,3]=d[,3]+species_boxes[i,16]
    
    # Plot box
    quads3d(x=d$adjEasting, y=d$adjNorthing, z=d$adjElevation, 
            add=T, col=colors_vec[s], lwd=2, lit=F)
  }
  
  }
    
}



} # END SITECODE