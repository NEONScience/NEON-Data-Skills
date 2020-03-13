library(ggplot2)
library(dplyr)
options(stringsAsFactors = FALSE)
SJER_chm <- raster("SJER_lidarCHM.tif")
SJER_chm
SJER_chm[SJER_chm==0] <- NA

SJER_plots <- readOGR("NEONdata/D17-California/SJER/vector_data","SJER_plot_centroids")

SJER_height <- extract(SJER_chm,SJER_plots,buffer=20,fun=max,sp=TRUE,stringsAsFactors=FALSE)


# # import the centroid data and the vegetation structure data
# SJER_insitu <- read.csv("NEONdata/D17-California/SJER/2013/insitu/veg_structure/D17_2013_SJER_vegStr.csv",
#                         stringsAsFactors = FALSE)
# 
# 
# #find the max stem height for each plot
# insitu_maxStemHeight <- SJER_insitu %>%
#   group_by(plotid) %>%
#   summarise(max = max(stemheight))


names(insitu_maxStemHeight) <- c("plotid","insituMaxHt")
SJER_height@data <- data.frame(SJER_height@data,
                               insitu_maxStemHeight[match(SJER_height@data[,"Plot_ID"], insitu_maxStemHeight$plotid),])

# #plot with regression fit
# p <- ggplot(SJER_height@data, aes(x=SJER_lidarCHM, y = insituMaxHt)) +
#   geom_point() +
#   ylab("Maximum Measured Height") +
#   xlab("Maximum LiDAR Height")+
#   ggtitle("LiDAR CHM Derived vs Measured Tree Height") +
#   geom_abline(intercept = 0, slope=1)+
#   geom_smooth(method=lm)
# 
# p <- ggplot(TEAK_height@data, aes(x=SOAP_lidarCHM, y = insituMaxHt)) +
#   geom_point() +
#   ylab("Maximum Measured Height") +
#   xlab("Maximum LiDAR Height")+
#   ggtitle("LiDAR DEM Derived vs Measured Tree Height") +
#   geom_abline(intercept = 0, slope=1)+
#   geom_smooth(method=lm)
# 

library(plotly)
p

