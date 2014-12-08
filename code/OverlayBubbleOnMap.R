#this code will take some data and will plot it using a "bubble" approach 
#it will overlay the bubbles on top of a base map. For it to work, layers should be in 
#WGS84 (geographic) CRS with lat long x,y values. then reproject the map as you see fit.

library(maptools)
library(mapproj)
library(rgeos)
library(rgdal)
library(ggplot2)

#sometimes Rgdal doesn't want to install given the version of R you are running.
#try this:
#install.packages('rgdal', type='source')

# for theme_map
devtools::source_gist("33baa3a79c5cfef0f6df")

# nice US map GeoJSON
#us <- readOGR(dsn="http://eric.clst.org/wupl/Stuff/gz_2010_us_040_00_500k.json", layer="OGRGeoJSON")

#this is now a local layer for all to use!
us <- readOGR("C:/Users/lwasser/Documents/GitHub/NEON_HigherEd/code/BubbleMapData/gz_2010_us_040_00_500k.json", layer="OGRGeoJSON")

#canada layer is one i found, downloaded and reprojected to WGS84 geographic
#this dataset is on my home mac as i processed it there- need to push it to GIT.
#can<-readOGR("/Users/law/Downloads/Canada","canadaWGS84")


#http://eric.clst.org/Stuff/USGeoJSON
#http://stackoverflow.com/questions/17267248/how-where-do-i-get-geojson-data-for-states-provinces-and-administrative-region

# Simplify the topology to decrease the file size 
us <- SpatialPolygonsDataFrame(gSimplify(us, tol=0.1, topologyPreserve=TRUE), 
                               data=us@data)

# Simplify the topology to decrease the file size 
#can <- SpatialPolygonsDataFrame(gSimplify(can, tol=0.1, topologyPreserve=TRUE), 
                               # data=can@data)

# Remove extraneous regions from the map
us <- us[!us$NAME %in% c("Alaska", "Hawaii", "Puerto Rico", "District of Columbia"),]
#us <- us[!us$NAME %in% c( "Hawaii", "Puerto Rico", "District of Columbia"),]

# for ggplot
#FORTIFY: http://docs.ggplot2.org/0.9.3.1/fortify.map.html
#This function turns a map into a data frame that can more easily be plotted with ggplot2.
map <- fortify(us, region="NAME")
#canMap <- fortify(can, region="NAME")

#NOTE: if you run into errors running fortify, make sure install.packages('gpclib', type='source')
#then make sure gpclibPermitStatus() is true when you type it into the console.

# Pop Data
myData <- data.frame(name=c("Florida", "Colorado", "California", "Harvard", "Yellowstone"),
                     lat=c(28.1, 39, 37, 42, 44.6), 
                     long=c(-81.6, -105.5, -120, -71,-110),
                     pop=c(280, 156, 128, 118, 202))

# the map
#https://source.opennews.org/en-US/learning/choosing-right-map-projection/
gg <- ggplot()
# the base map
gg <- gg + geom_map(data=map, map=map,
                    aes(x=long, y=lat, map_id=id, group=group),
                    fill="#ffffff", color="#0e0e0e", size=0.15)
#geom_polygon(data = biggestWatershed
#gg <- gg + geom_map(data=canMap, map=canMap,
                #    aes(x=long, y=lat, map_id=id, group=group),
                 #   fill="#ffffff", color="#cccccc", size=0.15)
# your bubbles
gg <- gg + geom_point(data=myData, 
                      aes(x=long, y=lat, size=pop), color="#AD655F") 

#these limits are for a us map.
gg <- gg + xlim(-125, -75) + 
  ylim(25, 50) +
  labs(title="Species Occurrence Data") +
  coord_equal()

# Assign a projection to the map. Mercator or Albers work although mercator
# makes alaska look ginormous.
#gg <- gg + coord_map(projection="mercator")
gg <- gg + coord_map(projection="albers", lat=40, lat1=45,orientation=c(100,-100,0))

#tweak the legend
gg <- gg + theme_map() +
  theme(legend.position="bottom") +
  xlab("Longitude") +
  ylab("") +
  theme(plot.title=element_text(size=16))
gg


library(plotly)
#set user credentials
py <- plotly(username="leahawasser", key="tpdjz2b8pu")
out <-py$ggplotly(gg)

