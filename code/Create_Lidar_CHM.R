#this code will extract lidar derived cnaopy height data from plots that were measured in situ. the final activity will involve plotting measured vs lidar vegetation height.

#because we will be exporting data in this activity, let's set the working directory before we go any further.
setwd("~/Conferences/1_DataWorkshop_ESA2014/ESAWorkshop_data")

# C:\Users\lwasser\Documents\Conferences\1_DataWorkshop_ESA2014\ESAWorkshop_data\Part3_LiDAR
#mac
# ~\Users\law\Documents\data\CHM_InSitu_Data\

# Import DSM into R 
#please note that the raster package also requires and will load the sp package
library(raster)

# IMPORTANT - the path to your DSM data may be different than the path below.  
dsm_f <- "C:/Users/lwasser/Documents/workshopData/ESAWorkshop_data/Part3_LiDAR/DigitalSurfaceModel/SJER2013_DSM.tif"
#dsm_f <- "/Users/law/Documents/data/CHM_InSitu_Data/DigitalSurfaceModel/SJER2013_DSM.tif"
dsm <- raster(dsm_f)
## See info about the raster. notice it has a CRS associated with it.
dsm
plot(dsm)

# import the digital terrain model
dtm_f <- "C:/Users/lwasser/Documents/workshopData/ESAWorkshop_data/Part3_LiDAR/DigitalTerrainModel/SJER2013_DTM.tif"
#mac 
#dtm_f <- "/Users/law/Documents/data/CHM_InSitu_Data/DigitalTerrainModel/SJER2013_DTM.tif"

dtm <- raster(dtm_f)
plot(dtm)

## Create a function that performs this raster math. Canopy height is dsm - dtm
canopyCalc <- function(x, y) {
  return(x - y)
}

#use the function to create the final CHM
#chm <- overlay(dsm,dtm,fun = canopyCalc)

#or just call the function
chm <- canopyCalc(dsm,dtm)
### a little raster math
plot(chm)

#write out the CHM in tiff format. We can look at this in any GIS software.
writeRaster(chm,"outputs/chm2.tiff","GTiff")


#r load libraries
library(sp)
library(dplyr)

#import the centroid data and the vegetation structure data
options(stringsAsFactors=FALSE)

# Please note that the syntax for a path is slightly different between mac and pc.
#mac
#centroids <- read.csv("/Users/law/Documents/data/CHM_InSitu_Data/InSitu_Data/SJERPlotCentroids.csv")
#insitu_dat <- read.csv("/Users/law/Documents/data/CHM_InSitu_Data/InSitu_Data/D17_2013_vegStr.csv")

#pc
centroids <- read.csv("/Users/lwasser/Documents/workshopData/ESAWorkshop_data/InSitu_Data/SJERPlotCentroids.csv")
insitu_dat <- read.csv("/Users/lwasser/Documents/workshopData/ESAWorkshop_data/InSitu_Data/D17_2013_vegStr.csv")

#Overlay the centroid points and the stem locations on top of CHM plot.
points(centroids$easting,centroids$northing, pch=22, cex = 4,col = 2)
points(insitu_dat$easting,insitu_dat$northing, pch=19, cex=.5)


# Create a spatial points object using the CRS (coordinate reference system) from the CHM 
# Apply the CRS to our plot centroid data.
centroid_sp <- SpatialPoints(centroids[,4:3],proj4string =CRS(as.character(chm@crs)) )


# Insitu sampling took place within 40m x 40m plots at SJER.  
# Note that below will return a list, so we can extract via lapply
#buffer =- radius, not diameter
cent_ovr <- extract(chm,centroid_sp,buffer = 20)


## VARIATION 2 -- Extract CHM Values using a shapefile
#to import you need the maptools library which depends upon the rgeos packages.
#install.packages(rgeos)
#install.packages(maptools)


library(maptools)
squarePlot <- readShapePoly("/Users/lwasser/Documents/workshopData/ESAWorkshop_data/InSitu_Data/SJERPlotCentroids_Buffer.shp")
cent_ovr2 <- extract(chm, squarePlot, weights=FALSE, fun=max)


#extract the max CHM value for each plot within the 10 m buffer defined above. Add it to the centroids object
centroids$chmMax <- unlist(lapply(cent_ovr,max))



#now, there are two ways to do the next part. Let's start with writing each line out.

#first slelect plots that are also represented in our centroid layer. Quick test - how many plots are in the centroid folder?
insitu_inCentroid <- insitu_dat %>% filter(plotid %in% centroids$Plot_ID)

#list out plot id results. how many are there?
unique(insitu_inCentroid$plotid) 


#find the max stem height value for each plot. We will compare this value to the max CHM value.
insitu_maxStemHeight <- insitu_inCentroid %>% group_by(plotid) %>% summarise(max = max(stemheight))


#NOTE -- we can be super tricky and combine the above steps into one line of code. See below how this is done.
#this string is taking full advantage of the dplyr package.
insitu <- insitu_dat %>% filter(plotid %in% centroids$Plot_ID) %>% group_by(plotid) %>% summarise(quant = quantile(stemheight,.95), max = max(stemheight))

#add the max height value to the centroids object.
centroids$insitu <- insitu_maxStemHeight$max


#Now let's plot our data. We will use the GGPLOT libraries to create our plot
#the plot below has a 1:1 line.
library(ggplot2)
ggplot(centroids,aes(x=chmMax, y =insitu )) + 
  geom_point() + theme_bw() + ylab("Maximum Measured Height") + 
  xlab("Maximum LiDAR Height")+geom_abline(intercept = 0, slope=1)+
  xlim(0, max(centroids[,6:7])) + ylim(0,max(centroids[,6:7])) 

#plot with regression fit
p <- ggplot(centroids,aes(x=chmMax, y =insitu )) + geom_point() + 
  ylab("Maximum Measured Height") + xlab("Maximum LiDAR Height")+
  geom_abline(intercept = 0, slope=1)+
  geom_smooth(method=lm) +
  xlim(0, max(centroids[,6:7])) + ylim(0,max(centroids[,6:7])) 

p + theme(panel.background = element_rect(colour = "grey")) + ggtitle("LiDAR CHM Derived vs Measured Tree Height") +
  theme(plot.title=element_text(family="sans", face="bold", size=20, vjust=1.9)) +
  theme(axis.title.y = element_text(family="sans", face="bold", size=14, angle=90, hjust=0.54, vjust=1)) +
  theme(axis.title.x = element_text(family="sans", face="bold", size=14, angle=00, hjust=0.54, vjust=-.2))



## create plotly map

library(plotly)
set_credentials_file("yourUserName", "yourKey")
p <- plotly(username="yourUserName", key="yourKey")

py <- plotly()
py$ggplotly()
