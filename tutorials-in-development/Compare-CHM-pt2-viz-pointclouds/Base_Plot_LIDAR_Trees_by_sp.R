## Download fiels sites shapefile
#LOAD LIBRARIES
#library(sp)
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




## Define sites of interest

### Add base plots?
SITECODES = c('BART', 'HARV', 'WREF')

#SITECODE='BART'

for(SITECODE in SITECODES){
setwd("~/Downloads/")
NEON_all_plots <- st_read('All_NEON_TOS_Plots_V7/All_NEON_TOS_Plot_Polygons_V7.shp')
base_plots_SPDF <- NEON_all_plots[(NEON_all_plots$siteID == SITECODE)&(NEON_all_plots$subtype == 'basePlot'),]

rm(NEON_all_plots)

#Extract data from polygons dataframe
#in_data <- as.data.frame(base_plots_SPDF@data)

coord_df <- data.frame("plotID" = as.character(base_plots_SPDF$plotID),
                       "coord_String" = apply(base_plots_SPDF, 1, get_plot_coords))

#rm(in_data)


#boundary_df <- coord_df[coord_df$coord_String == 'Plot crosses a tile boundary',]
coord_df <- coord_df[coord_df$coord_String != 'Plot crosses a tile boundary',]


coord_count = coord_df %>% group_by(coord_String) %>%
  summarise(count=n()) %>% arrange(desc(count))
  
## most base plots is coord_count$coord_String[1]

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

#Install any files not already present

if(!file.exists(file_name)){
  #Try downloading file using full URL
  download.file(file_url, destfile = paste0(getwd(),'/',file_name))
  if(!file.exists(file_name)){
    #Try downloading file using trimmed url
    download.file(paste0(strsplit(file_url, '.laz')[[1]][1], '.laz'),
                  destdir = paste0(getwd(),'/',file_name))
  }
  
}


site_LAS=readLAS(file_name)

### trim bad lidar point outliers
Z_sd=sd(site_LAS@data$Z)
Z_mean=mean(site_LAS@data$Z)

#make filter string in form filter = "-drop_z_below 50 -drop_z_above 1000"
f= paste("-drop_z_below",(Z_mean-4*Z_sd),"-drop_z_above",(Z_mean+4*Z_sd))

site_LAS=readLAS(file_name, filter = f)

#plot(site_LAS)
## Use max lidar functions to determine which LIDAR tiles contain field plots
 ## Which lidar tile contains the most base plots? Let's just use that one

## Download lidar tile

## plot lidar w/ base plots:
base_plots_SPDF <- st_transform(base_plots_SPDF, as.character(site_LAS@proj4string))
base_crop=st_crop(base_plots_SPDF, extent(site_LAS))
x = plot(site_LAS)
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
  quads3d(x=coords$X[r:(r+3)], y=coords$Y[r:(r+3)], z=coords$Z[r:(r+3)]+50,
          add=T, col="red", lwd=2, lit=F)
}



top_left=as.data.frame(st_coordinates(base_crop))
c=1:nrow(top_left)
top_left=top_left[c%%5==1,]

plots_LAS <- 
  lasclipRectangle(site_LAS,
                   xleft = (top_left$X), ybottom = (top_left$Y - 40),
                   xright = (top_left$X + 40), ytop = (top_left$Y))



## Download veg structure
veglist <- loadByProduct(dpID="DP1.10098.001", site=SITECODE, check.size=F)

veglist_mapping <- veglist$vst_mappingandtagging

veglist_mapping <- veglist_mapping[veglist_mapping$plotID %in% base_crop$plotID,]

vegmap <- getLocTOS(veglist_mapping, 
                    "vst_mappingandtagging")

## Merge tables
veg <- merge(veglist$vst_apparentindividual, vegmap, 
             by=c("individualID","namedLocation",
                  "domainID","siteID","plotID"))


for(p in 1:length(plots_LAS)){
#for(p in 1:2){ 
  
  
  x=plot(plots_LAS[[p]])
  #quads3d(x=coordinates(base_plots_SPDF)[1:8,1], y=coordinates(base_plots_SPDF)[1:8,2])
  tree_boxes=veg[veg$plotID==base_crop$plotID[p],]
  
  trees_ranked = tree_boxes %>% group_by(taxonID) %>%
    summarise(count=n()) %>% arrange(desc(count))
  
  colors_vec = c("green","red","blue","orange","yellow")
  
  for(s in 1:5){
    
    species_boxes=tree_boxes[tree_boxes$taxonID==trees_ranked$taxonID[s],]
    species_boxes$adjEasting=species_boxes$adjEasting-x[1]
    species_boxes$adjNorthing=species_boxes$adjNorthing-x[2]
    
  
  for(i in 1:(nrow(species_boxes))){
    print(i)
    d=as.data.frame(species_boxes[i,c(59,60,64)])
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
    
    d[,3]=d[,3]+species_boxes[i,16]
    
    #r=((i-1)*4)+1
    #quads3d(x=coords$X[r:(r+3)], y=coords$Y[r:(r+3)], z=coords$Z[r:(r+3)]+50, add=T, col="green")
    quads3d(x=d$adjEasting, y=d$adjNorthing, z=d$api.elevation, 
            add=T, col=colors_vec[s], lwd=2, lit=F)
  }
  
  }
    
}



} # END SITECODE