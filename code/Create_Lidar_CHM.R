#this code will extract lidar derived cnaopy height data from plots that were measured in situ. the final activity will involve plotting measured vs lidar vegetation height.
#because we will be exporting data in this activity, let's set the working directory before we go any further.


# Import DSM into R 
#please note that the raster package also requires and will load the sp package
library(raster)

# IMPORTANT - the path to your DSM data may be different than the path below.  
dsm_f <- "DigitalSurfaceModel/SJER2013_DSM.tif"

dsm <- raster(dsm_f)
## See info about the raster. notice it has a CRS associated with it.
dsm
plot(dsm, main="NEON Digital Surface Model")

# import the digital terrain model
dtm_f <- "DigitalTerrainModel/SJER2013_DTM.tif"
dtm <- raster(dtm_f)
plot(dtm, main="NEON Digital Terrain Model")

## Create a function that performs this raster math. Canopy height is dsm - dtm
canopyCalc <- function(x, y) {
  return(x - y)
}

#or just call the function
chm <- canopyCalc(dsm,dtm)
### a little raster math
plot(chm, main = "Canopy Height Model - tree height")

#write out the CHM in tiff format. We can look at this in any GIS software.
writeRaster(chm,"outputs/chm2.tiff","GTiff")


#r load libraries
library(sp)
library(dplyr)

#import the centroid data and the vegetation structure data
options(stringsAsFactors=FALSE)

#import CSV files
centroids <- read.csv("InSitu_Data/SJERPlotCentroids.csv")
insitu_dat <- read.csv("InSitu_Data/D17_2013_vegStr.csv")

#Overlay the centroid points and the stem locations on top of CHM plot.
points(centroids$easting,centroids$northing, pch=22, cex = 4,col = 2)
points(insitu_dat$easting,insitu_dat$northing, pch=19, cex=.5)


# Create a spatial points data frame using the CRS (coordinate reference system) from the CHM 
# Apply the CRS to our plot centroid data.
centroid_spdf = SpatialPointsDataFrame(centroids[,4:3],proj4string=chm@crs, centroids)


#extract pixels, we can apply a summary FUNction to grab the max value
#we can also ask R to return the data as a data.frame (df=TRUE)
#the one downside of this method is that we can't look at the distribution of pixel
#values unless we return 
cent_ovr <- extract(chm,centroid_spdf,buffer=20, fun=max,df=TRUE)
#grab the names of the plots from the centroid_spdf
cent_ovr$plot_id <- centroid_spdf$Plot_ID  
#fix the column names
names(cent_ovr) <- c('ID','chmMaxHeight','plot_id')

#merge the chm data into the centroids data.frame
centroids <- merge(centroids, cent_ovr, by.x = 'Plot_ID', by.y = 'plot_id')


## VARIATION 2 -- Extract CHM Values using a shapefile
#to import you need the maptools library which depends upon the rgeos packages.
#install.packages(rgeos)
#install.packages(maptools)


library(maptools)
squarePlot <- readShapePoly("PlotCentroid_Shapefile/SJERPlotCentroids_Buffer.shp")
cent_ovr2 <- extract(chm, squarePlot, weights=FALSE, fun=max)


#summarize In Situ data using DPLYR

#list out plot id results. how many are there?
unique(insitu_dat$plotid) 


#find the max stem height value for each plot. We will compare this value to the max CHM value.
insitu_maxStemHeight <- insitu_inCentroid %>% group_by(plotid) %>% summarise(max = max(stemheight))


#NOTE -- we can be super tricky and combine the above steps into one line of code. See below how this is done.
#this string is taking full advantage of the dplyr package.
insitu <- insitu_dat %>% group_by(plotid) %>% summarise(insitu_95Ht = quantile(stemheight,.95), insitu_maxHt = max(stemheight))


########################

#merge the insitu data into the centroids data.frame
centroids<-merge(centroids, insitu, by.x = 'Plot_ID', by.y = 'plotid')
head(centroids)

#create basic plot
plot(x = centroids$chmMaxHeight, y=centroids$insitu_maxHt)


#Now let's plot our data. We will use the GGPLOT libraries to create our plot
#the plot below has a 1:1 line.
library(ggplot2)
ggplot(centroids,aes(x=chmMaxHeight, y =insitu_maxHt )) + 
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
