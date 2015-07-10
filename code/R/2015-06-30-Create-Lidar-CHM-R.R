## ----load-libraries, eval=FALSE------------------------------------------
## 
## #load the required R libraries
## #install.packages('raster')
## #install.packages('sp')
## #install.packages('dplyr')
## #install.packages('rgdal')
## #install.packages('ggplot2')
## 

## ----import-plot-DSM-----------------------------------------------------

#Make sure your working directory is set properly!
#The working directory will determine where data are saved. 
#If you already have an R studio project setup then you can skip this step!
#setwd("yourPathHere")    

#Import DSM into R 
library(raster)

# If the code below doesn't work, check your working directory path!  
dsm_f <- "DigitalSurfaceModel/SJER2013_DSM.tif"

dsm <- raster(dsm_f)
# View info about the raster. Then plot it.
dsm
#plot the DSM
myColor=terrain.colors(200)
plot(dsm, col = myColor, main="LiDAR Digital Surface Model")


## ----plot-DTM------------------------------------------------------------

#import the digital terrain model
dtm_f <- "DigitalTerrainModel/SJER2013_DTM.tif"
dtm <- raster(dtm_f)
plot(dtm, col=myColor, main="LiDAR Digital Terrain Model")


## ----calculate-plot-CHM--------------------------------------------------

#use raster math to create CHM
chm <- dsm - dtm

# Create a function that subtracts one raster from another
#canopyCalc <- function(x, y) {
#  return(x - y)
#  }
    
#use the function to create the final CHM
#then plot it.
#You could use the overlay function here 
#chm <- overlay(dsm,dtm,fun = canopyCalc) 
#but you can also perform matrix math to get the same output.
#chm <- canopyCalc(dsm,dtm)


plot(chm, main="LiDAR Canopy Height Model")


## ----write-raster-to-geotiff, eval=FALSE---------------------------------
## 
## #write out the CHM in tiff format. We can look at this in any GIS software.
## #NOTE: the code below places the output in an "outputs" folder.
## #you need to create this folder or else you will get an error.
## writeRaster(chm,"chm.tiff","GTiff")
## 

## ----read-plot-data------------------------------------------------------

#load libraries
library(sp)
library(dplyr)

#import the centroid data and the vegetation structure data
options(stringsAsFactors=FALSE)
centroids <- read.csv("InSitu_Data/SJERPlotCentroids.csv")
insitu_dat <- read.csv("InSitu_Data/D17_2013_vegStr.csv")

#Overlay the centroid points and the stem locations on the CHM plot
#plot the chm
myCol=terrain.colors(6)
plot(chm,col=myCol, main="Plot Locations", breaks=c(-5,0,5,10,40))
#for example, cex = point size 
#pch 0 = square
points(centroids$easting,centroids$northing, pch=0, cex = 2, col = 2)
points(insitu_dat$easting,insitu_dat$northing, pch=19, cex=.5)


## ----createSpatialDf-----------------------------------------------------

#make spatial points data.frame using the CRS (coordinate 
#reference system) from the CHM and apply it to our plot centroid data.
centroid_spdf = SpatialPointsDataFrame(centroids[,4:3],proj4string=chm@crs, centroids)


## ----extract-plot-data---------------------------------------------------

# Insitu sampling took place within 40m x 40m square plots so we use a 20m radius.	
# Note that below will return a dataframe containing the max height
# calculated from all pixels in the buffer for each plot
cent_ovr <- extract(chm,centroid_spdf,buffer = 20, fun=max, df=TRUE)

#grab the names of the plots from the centroid_spdf
cent_ovr$plot_id <- centroid_spdf$Plot_ID  
#fix the column names
names(cent_ovr) <- c('ID','chmMaxHeight','plot_id')

#merge the chm data into the centroids data.frame
centroids <- merge(centroids, cent_ovr, by.x = 'Plot_ID', by.y = 'plot_id')

#have a look at the centroids dataFrame
head(centroids)



## ----explore-data-distribution, eval=FALSE-------------------------------
## 
## #cent_ovrList <- extract(chm,centroid_sp,buffer = 20)
## # create histograms for the first 5 plots of data
## #for (i in 1:5) {
## #  hist(cent_ovrList[[i]], main=(paste("plot",i)))
## #  }
## 

## ----extract-w-shapefile-------------------------------------------------

#install needed packages
#install.packages(rgeos)
#install.packages(maptools)

#call the maptools package
#library(maptools)
#extract CHM data using polygon boundaries from a shapefile
#squarePlot <- readShapePoly("PlotCentroid_Shapefile/SJERPlotCentroids_Buffer.shp")
#centroids$chmMaxShape <- extract(chm, squarePlot, weights=FALSE, fun=max)


## ----unique-plots--------------------------------------------------------

# How many plots are there?
unique(insitu_dat$plotid) 


## ----analyze-plot-dplyr--------------------------------------------------

library(dplyr)

#get list of unique plot id's 
unique(insitu_dat$plotid) 

#looks like we have data for two sites
unique(insitu_dat$siteid) 

plotsSJER <- insitu_dat

#we've got some plots for SOAP which is a different region.
#let's just select plots with SJER data
#plotsSJER <- filter(insitu_dat, grepl('SJER', siteid))

#how many unique siteids do we have now?
#unique(plotsSJER$siteid) 


#find the max stem height for each plot
insitu_maxStemHeight <- plotsSJER %>% 
  group_by(plotid) %>% 
  summarise(max = max(stemheight))

head(insitu_maxStemHeight)


names(insitu_maxStemHeight) <- c("plotid","insituMaxHt")
head(insitu_maxStemHeight)
# Optional - do this all in one line of nested commands
#insitu <- insitu_dat %>% filter(plotid %in% centroids$Plot_ID) %>% 
#	      group_by(plotid) %>% 
#	      summarise(max = max(stemheight), quant = quantile(stemheight,.95))
	

## ----analyze-base-r------------------------------------------------------

#Use the aggregate function, the arguments of which are: 
#      the data on which you want to calculate something ~ the grouping variable
#      the FUNction

#insitu_maxStemHeight <- aggregate( insitu_inCentroid$stemheight ~ 
#                                     insitu_inCentroid$plotid, FUN = max )  

#Assign cleaner names to the columns
#names(insitu_maxStemHeight) <- c('plotid','max')

#OPTIONAL - combine the above steps into one line of code.
#add the max and 95th percentile height value for all trees within each plot
#insitu <- cbind(insitu_maxStemHeight,'quant'=tapply(insitu_inCentroid		$stemheight, 
#     insitu_inCentroid$plotid, quantile, prob = 0.95))	


## ----merge-dataframe-----------------------------------------------------

#merge the insitu data into the centroids data.frame
centroids <- merge(centroids, insitu_maxStemHeight, by.x = 'Plot_ID', by.y = 'plotid')
head(centroids)


## ----plot-data-----------------------------------------------------------

#create basic plot
plot(x = centroids$chmMaxHeight, y=centroids$insituMaxHt)


## ----plot-w-ggplot-------------------------------------------------------

library(ggplot2)
#create plot
ggplot(centroids,aes(x=chmMaxHeight, y =insituMaxHt )) + 
  geom_point() + 
  theme_bw() + 
  ylab("Maximum measured height") + 
  xlab("Maximum LiDAR pixel")+
  geom_abline(intercept = 0, slope=1)+
  xlim(0, max(centroids[,7:8])) + 
  ylim(0,max(centroids[,7:8]))


## ----ggplot-data---------------------------------------------------------

#plot with regression fit
p <- ggplot(centroids,aes(x=chmMaxHeight, y =insituMaxHt )) + 
  geom_point() + 
  ylab("Maximum Measured Height") + 
  xlab("Maximum LiDAR Height")+
  geom_abline(intercept = 0, slope=1)+
  geom_smooth(method=lm) +
  xlim(0, max(centroids[,7:8])) + 
  ylim(0,max(centroids[,7:8])) 

p + theme(panel.background = element_rect(colour = "grey")) + 
  ggtitle("LiDAR CHM Derived vs Measured Tree Height") +
  theme(plot.title=element_text(family="sans", face="bold", size=20, vjust=1.9)) +
  theme(axis.title.y = element_text(family="sans", face="bold", size=14, angle=90, hjust=0.54, vjust=1)) +
  theme(axis.title.x = element_text(family="sans", face="bold", size=14, angle=00, hjust=0.54, vjust=-.2))


## ----create-plotly, eval=FALSE-------------------------------------------
## 
## library(plotly)
## #setup your plot.ly credentials
## set_credentials_file("yourUserName", "yourKey")
## p <- plotly(username="yourUserName", key="yourKey")
## 
## #generate the plot
## py <- plotly()
## py$ggplotly()
## 

