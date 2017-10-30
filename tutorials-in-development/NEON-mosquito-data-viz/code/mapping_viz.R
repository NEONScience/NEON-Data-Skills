# Clean starting environment
# rm(list = ls())

# LIBRARIES
library(foreign)
library(rgeos)
library(maptools)
library(raster)
library(rbokeh) # Maybe with a map?
library(plyr)
library(dplyr)
library(rgdal) # requires sp, will use proj.4 if installed
library(ggplot2)


require("rgdal") # requires sp, will use proj.4 if installed
require("maptools")
require("ggplot2")
require("plyr")



# My working directory
if(file.exists('~/GitHub/mosquito-intern')){ # Charlotte's path
  repo_location = '~/GitHub/mosquito-intern'
}
if(file.exists('~/GitHub/mosquito-intern')){
  repo_location = '~/GitHub/mosquito-intern'
}
if(!exists('repo_location')){stop('Set the location of the neon_data repository.')}



# Two ways to make a map
# Way #1: Map the data using maptools & the plot function
# # Get shp files of NEON domains
# Ddbf<-read.dbf(paste(repo_location, '/resources/spatial files/NEON-domain-map/NEON_Domains.dbf', sep='/'))
# Dmap<-readShapePoly(paste(repo_location, '/resources/spatial files/NEON-domain-map/NEON_Domains.shp', sep='/'))
# crs(Dmap) <- "+proj=utm +units=m +ellps=WGS84"
# plot(Dmap,col="#ADA96E",bg='#77BFC7',main='NEON Domains',cex.main=1)
# points(tars.firstdomain$lon2, tars.firstdomain$lat2, pch=21, bg= "blue",cex=1)
# # points(long, lat)

# Way #2: Using rgdal, ggplot and aes
# Read blog post here: https://github.com/tidyverse/ggplot2/wiki/plotting-polygon-shapefiles



#Read in file  
NEONmap = readShapePoly(paste(repo_location, 'resources/spatial files/NEON-domain-map/NEON_Domains.shp', sep='/'))
# Manipulate for plotting
NEONmap@data$id = rownames(NEONmap@data)
NEONmap.points = fortify(NEONmap, region="id")
NEONmap.df = join(NEONmap.points, NEONmap@data, by="id")
NEONmap.df$DomainID<-as.character(NEONmap.df$DomainID)
NEONmap.df$nativestat<-ifelse(NEONmap.df$DomainID %in% c(1,2,3,5:17),1,0)
# NEONmap.df$DomainIDnew<-ifelse(nchar(NEONmap.df$DomainID) < 2, paste('D0', NEONmap.df$DomainID, sep=""), paste("D",NEONmap.df$DomainID,sep=""))

# NEONmap.df <-merge(x = tarstax.df, y = NEONmap.df, by.x = "domainID", by.y = "DomainIDnew", all=T )


# # make the plot, allows for multiple df use
# q <- ggplot()+
#   geom_polygon(data = NEONmap.df, aes(long, lat, group=group, fill= nativestat))+
#   guides(fill=FALSE)+
#   geom_path(data = NEONmap.df, aes(long,lat, group=group), color = 'white')+
#   geom_point(data = tars.firstdomain, aes( lon2, lat2, frame = Year), color = 'red', size = 2.5)+
#   labs( x = "Longitude", y ="Latitude")+
#   ggtitle("Map of where Culex tarsalis Found and Native Status")+
#   theme(plot.title = element_text(size = 16, face = "bold"))
# 
# gganimate(q, interval = 3, 'test.gif')


domain.df$tarsPresent<- as.factor(domain.df$tarsPresent)
domain.df$lat2<- as.numeric(domain.df$lat2)
domain.df$lon2<- as.numeric(domain.df$lon2)


mapviz<-ggplot()+
  geom_polygon(data = NEONmap.df, aes(long, lat, group=group, fill= as.factor(nativestat)))+
  geom_path(data = NEONmap.df, aes(long,lat, group=group), color = 'black')+
  scale_fill_manual(values = c("gold", "lightyellow2")) +
  geom_point(data = domain.df, aes( lon2, lat2, color = tarsPresent),size = 2)+
  labs( x = "Longitude", y ="Latitude")+
  ggtitle("Map of Culex tarsalis Observation and Native Status")+
  theme(plot.title = element_text(size = 16, face = "bold"))+
  guides(fill = FALSE, color = FALSE)

# gg <- ggplot()+
#   geom_polygon(data = NEONmap.df, aes(long, lat, group=group), fill = 'white')+
#   geom_path(data = NEONmap.df, aes(long, lat, group = group), color = 'black')

