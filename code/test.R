library(plotly)
p <- plotly(username="MattSundquist", key="4om2jxmhmn")
library(maps)
library(ggplot2)
data(canada.cities)
trace1 <- list(x=map(regions="canada")$x,
               y=map(regions="canada")$y)

trace2 <- list(x= canada.cities$long,
               y=canada.cities$lat,
               text=canada.cities$name,
               type="scatter",
               mode="markers",
               marker=list(
                 "size"=sqrt(canada.cities$pop/max(canada.cities$pop))*100,
                 "opacity"=0.5)
)

response <- p$plotly(trace1,trace2)
url <- response$url
filename <- response$filename
browseURL(response$url)













library(ggmap)
map("state", interior = FALSE)
map("state", boundary = FALSE, col="gray", add = TRUE)

symbols(myData$lat, myData$lat, circles=myData$pop)

myData = data.frame(name=c("Florida","Colorado","california","Harvard","Yellowstone"),
                    lat=c(28.1,39,37,42,44.6), 
                    long=c(-81.6,-105.5,-120,-71,-110),
                    pop=c(280,156,128,118,202))

coordinates(myData) <- c("long", "lat") # promote to SpatialPointsDataFrame
bubble(myData, "pop", maxsize = 2.5, main = "Locations", 
       identify = FALSE, 
       labels=myData$name,
       key.entries = 2^(-1:4))

map(database= "world", ylim=c(45,90), 
    xlim=c(-160,-50), col="grey80", 
    fill=TRUE, projection="gilbert", 
    orientation= c(90,0,225))

#lon <- c(-72, -66, -107, -154)  #fake longitude vector
#lat <- c(81.7, 64.6, 68.3, 60)  #fake latitude vector
coord <- mapproject(myData$lon, myData$lat, proj="gilbert",orientation=c(90, 0, 225))
points(coord, pch=20, cex=1.2, col="red") 

library(maps)
library(mapdata)
library(maptools)
library(sp)
library(raster)
nl <- getData('GADM', country="USA", level=1) #raster data, format SpatialPolygonsDataFrame

# coercing the polygon outlines to a SpatialLines object
spl <- list("sp.lines", as(nl, "SpatialLines"))

bubble(myData, "pop", maxsize = 2.5, main = "Locations", 
       identify = FALSE, 
       labels=myData$name,
       key.entries = 2^(-1:4),
       sp.layout=spl)

lines(spl)



library(ggplot2)
library(sp)
library(raster)
library(maps)
library(mapdata)
library(maptools)
#library(gstat)
library(ggmap)
library(rgeos)
#install.packages('rgeos', type='source')

options(stringsAsFactors = FALSE)
xy <- myData[,c("long", "lat")]
nl <- getData('GADM', country="USA", level=1) #raster data, format SpatialPolygonsDataFrame
nl <- gSimplify(nl, tol=0.02, topologyPreserve=TRUE)
# coercing the polygon outlines to a SpatialLines object
spl <- list("sp.lines", as(nl, "SpatialLines"))
SPDF <- SpatialPointsDataFrame(coords=xy, data=myData)
coordinates(myData) <- c("lat", "long")
projection(SPDF)<- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"
coordinates(SPDF)[1:5,] #retrieves spatial coordinates form the dataframe
bubble(SPDF, "pop", sp.layout=spl, main="This is It!")

map(database= "world", ylim=c(45,90), 
    xlim=c(-160,-50), col="grey80", 
    fill=TRUE, projection="gilbert", 
    orientation= c(90,0,225))













library(map)
library(ggplot2)

myData = data.frame(name=c("Florida","Colorado","california","Harvard","Yellowstone"),
                    lat=c(28.1,39,37,42,44.6), 
                    long=c(-81.6,-105.5,-120,-71,-110),
                    pop=c(280,156,128,118,202))

# Get US map
usa <- map_data("state")
usaAlaska <- map_data("world2",c("usa","Canada"))

# Draw the map and add the data points in myData

ggplot() +
  geom_path(data = usaAlaska, aes(x = long, y = lat, group = group)) +
  geom_point(data = myData, aes(x = long, y = lat, size = pop), color = "red")






