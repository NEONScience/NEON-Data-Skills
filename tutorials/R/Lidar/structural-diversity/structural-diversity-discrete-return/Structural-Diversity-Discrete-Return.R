## ----call-libraries, results="hide"--------------------------------------------

############### Packages ################### 
library(lidR)
library(gstat)

############### Set working directory ######
#set the working of the downloaded tutorial folder
wd <- "~/Git/data/" #This will depend on your local machine
setwd(wd)



## ----read-in-lidar-data--------------------------------------------------------

############ Read in LiDAR data ###########
#2017 1 km2 tile .laz file type for HARV and TEAK

#Watch out for outlier Z points - this function also allows for the
#ability to filter outlier points well above or below the landscape
#(-drop_z_blow and -drop_z_above). See how we have done this here 
#for you.

HARV <- readLAS(paste0(wd,"NEON_D01_HARV_DP1_727000_4702000_classified_point_cloud_colorized.laz"),
                filter = "-drop_z_below 150 -drop_z_above 325")

TEAK <- readLAS(paste0(wd,"NEON_D17_TEAK_DP1_316000_4091000_classified_point_cloud_colorized.laz"),
                filter = "-drop_z_below 1694 -drop_z_above 2500")




## ----plot-and-summarize-laz-file, eval=F, comment=NA---------------------------
############## Look at data specs ######
#Let's check out the extent, coordinate system, and a 3D plot of each 
#.laz file. Note that on Mac computers you may need to install 
#XQuartz for 3D plots - see xquartz.org
summary(HARV)
plot(HARV)


## ----plot-teak-1km2-point-cloud, eval=F, comment=NA----------------------------
summary(TEAK)
plot(TEAK)


## ----correct-for-elevation-----------------------------------------------------

############## Correct for elevation #####
#We're going to choose a 40 x 40 m spatial extent, which is the
#extent for NEON base plots. 
#First set the center of where you want the plot to be (note easting 
#and northing works in units of m because these data are in a UTM 
#proejction as shown in the summary above).
x <- 727500 #easting 
y <- 4702500 #northing

#Cut out a 200 x 200 m buffer by adding 100 m to easting and 
#northing coordinates (x,y).
data.200m <- 
   clip_rectangle(HARV,
                    xleft = (x - 100), ybottom = (y - 100),
                    xright = (x + 100), ytop = (y + 100))

#Correct for ground height using a kriging function to interpolate 
#elevation from ground points in the .laz file.
#If the function will not run, then you may need to checkfor outliers
#by adjusting the 'drop_z_' arguments when reading in the .laz files.
dtm <- grid_terrain(data.200m, 1, kriging(k = 10L))
data.200m <- normalize_height(data.200m, dtm)

#Will often give a warning if not all points could be corrected, 
#but visually check to see if it corrected for ground height. 
plot(data.200m)
#There's only a few uncorrected points and we'll fix these in 
#the next step. 

#Clip 20 m out from each side of the easting and northing 
#coordinates (x,y).
data.40m <- 
   clip_rectangle(data.200m, 
                    xleft = (x - 20), ybottom = (y - 20),
                    xright = (x + 20), ytop = (y + 20))

data.40m@data$Z[data.40m@data$Z <= .5] <- NA  
#This line filters out all z_vals below .5 m as we are less 
#interested in shrubs/trees. 
#You could change it to zero or another height depending on interests. 

#visualize the clipped plot point cloud
plot(data.40m) 


## ----calculate-structural-diversity-metrics, fig.cap="Canopy Height Model (CHM) of HARV study area"----

############# Structural diversity metrics  ######

#GENERATE CANOPY HEIGHT MODEL (CHM) (i.e. a 1 m2 raster grid of 
#vegetations heights)
#res argument specifies pixel size in meters and dsmtin is 
#for raster interpolation
chm <- grid_canopy(data.40m, res = 1, dsmtin())  

#visualize CHM
plot(chm) 

#MEAN OUTER CANOPY HEIGHT (MOCH)
#calculate MOCH, the mean CHM height value
mean.max.canopy.ht <- mean(chm@data@values, na.rm = TRUE) 

#MAX CANOPY HEIGHT
#calculate HMAX, the maximum CHM height value
max.canopy.ht <- max(chm@data@values, na.rm=TRUE) 

#RUMPLE
#calculate rumple, a ratio of outer canopy surface area to 
#ground surface area (1600 m^2)
rumple <- rumple_index(chm) 

#TOP RUGOSITY
#top rugosity, the standard deviation of pixel values in chm and 
#is a measure of outer canopy roughness
top.rugosity <- sd(chm@data@values, na.rm = TRUE) 

#DEEP GAPS & DEEP GAP FRACTION
#number of cells in raster (also area in m2)
cells <- length(chm@data@values) 
chm.0 <- chm
chm.0[is.na(chm.0)] <- 0 #replace NAs with zeros in CHM
#create variable for the number of deep gaps, 1 m^2 canopy gaps
zeros <- which(chm.0@data@values == 0) 
deepgaps <- length(zeros) #number of deep gaps
#deep gap fraction, the number of deep gaps in the chm relative 
#to total number of chm pixels
deepgap.fraction <- deepgaps/cells 

#COVER FRACTION
#cover fraction, the inverse of deep gap fraction
cover.fraction <- 1 - deepgap.fraction 

#HEIGHT SD
#height SD, the standard deviation of height values for all points
#in the plot point cloud
vert.sd <- cloud_metrics(data.40m, sd(Z, na.rm = TRUE)) 

#SD of VERTICAL SD of HEIGHT
#rasterize plot point cloud and calculate the standard deviation 
#of height values at a resolution of 1 m^2
sd.1m2 <- grid_metrics(data.40m, sd(Z), 1)
#standard deviation of the calculated standard deviations 
#from previous line 
#This is a measure of internal and external canopy complexity
sd.sd <- sd(sd.1m2[,3], na.rm = TRUE) 
 

#some of the next few functions won't handle NAs, so we need 
#to filter these out of a vector of Z points
Zs <- data.40m@data$Z
Zs <- Zs[!is.na(Zs)]

#ENTROPY 
#entropy, quantifies diversity & evenness of point cloud heights 
#by = 1 partitions point cloud in 1 m tall horizontal slices 
#ranges from 0-1, with 1 being more evenly distributed points 
#across the 1 m tall slices 
entro <- entropy(Zs, by = 1) 

#GAP FRACTION PROFILE 
#gap fraction profile, assesses the distribution of gaps in the 
#canopy volume 
#dz = 1 partitions point cloud in 1 m horizontal slices 
#z0 is set to a reasonable height based on the age and height of 
#the study sites 
gap_frac <- gap_fraction_profile(Zs, dz = 1, z0=3) 
#defines gap fraction profile as the average gap fraction in each 
#1 m horizontal slice assessed in the previous line
GFP.AOP <- mean(gap_frac$gf) 

#VAI
#leaf area density, assesses leaf area in the canopy volume 
#k = 0.5 is a standard extinction coefficient for foliage 
#dz = 1 partitions point cloud in 1 m horizontal slices 
#z0 is set to the same height as gap fraction profile above
LADen<-LAD(Zs, dz = 1, k=0.5, z0=3) 
#vegetation area index, sum of leaf area density values for 
#all horizontal slices assessed in previous line
VAI.AOP <- sum(LADen$lad, na.rm=TRUE) 

#VCI
#vertical complexity index, fixed normalization of entropy 
#metric calculated above
#set zmax comofortably above maximum canopy height
#by = 1 assesses the metric based on 1 m horizontal slices in 
#the canopy
VCI.AOP <- VCI(Zs, by = 1, zmax=100) 


## ----output-HARV-metrics-------------------------------------------------------
#OUTPUT CALCULATED METRICS INTO A TABLE
#creates a dataframe row, out.plot, containing plot descriptors 
#and calculated metrics
HARV_structural_diversity <- 
   data.frame(matrix(c(x, y, mean.max.canopy.ht, max.canopy.ht, 
                       rumple, deepgaps,deepgap.fraction,
                       cover.fraction,top.rugosity, vert.sd, 
                       sd.sd, entro,GFP.AOP, VAI.AOP, VCI.AOP),
                     ncol = 15)) 

#provide descriptive names for the calculated metrics
colnames(HARV_structural_diversity) <- 
   c("easting", "northing", "mean.max.canopy.ht.aop",
     "max.canopy.ht.aop", "rumple.aop", "deepgaps.aop",
     "deepgap.fraction.aop","cover.fraction.aop", 
     "top.rugosity.aop", "vert.sd.aop", "sd.sd.aop", 
     "entropy.aop", "GFP.AOP.aop", "VAI.AOP.aop", "VCI.AOP.aop") 

#View the results
HARV_structural_diversity 



## ----calculate-structural-diversity-metrics-TEAK-------------------------------
#Let's correct for elevation and measure structural diversity for TEAK
x <- 316400 
y <- 4091700

data.200m <- clip_rectangle(TEAK, 
                              xleft = (x - 100), ybottom = (y - 100),
                              xright = (x + 100), ytop = (y + 100))

dtm <- grid_terrain(data.200m, 1, kriging(k = 10L))
data.200m <- normalize_height(data.200m, dtm)

data.40m <- clip_rectangle(data.200m, 
                             xleft = (x - 20), ybottom = (y - 20),
                             xright = (x + 20), ytop = (y + 20))
data.40m@data$Z[data.40m@data$Z <= .5] <- 0  
plot(data.40m)


## ----structural-diversity-function---------------------------------------------

#Zip up all the code we previously used and write function to 
#run all 13 metrics in a single function. 
structural_diversity_metrics <- function(data.40m) {
   chm <- grid_canopy(data.40m, res = 1, dsmtin()) 
   mean.max.canopy.ht <- mean(chm@data@values, na.rm = TRUE) 
   max.canopy.ht <- max(chm@data@values, na.rm=TRUE) 
   rumple <- rumple_index(chm) 
   top.rugosity <- sd(chm@data@values, na.rm = TRUE) 
   cells <- length(chm@data@values) 
   chm.0 <- chm
   chm.0[is.na(chm.0)] <- 0 
   zeros <- which(chm.0@data@values == 0) 
   deepgaps <- length(zeros) 
   deepgap.fraction <- deepgaps/cells 
   cover.fraction <- 1 - deepgap.fraction 
   vert.sd <- cloud_metrics(data.40m, sd(Z, na.rm = TRUE)) 
   sd.1m2 <- grid_metrics(data.40m, sd(Z), 1) 
   sd.sd <- sd(sd.1m2[,3], na.rm = TRUE) 
   Zs <- data.40m@data$Z
   Zs <- Zs[!is.na(Zs)]
   entro <- entropy(Zs, by = 1) 
   gap_frac <- gap_fraction_profile(Zs, dz = 1, z0=3)
   GFP.AOP <- mean(gap_frac$gf) 
   LADen<-LAD(Zs, dz = 1, k=0.5, z0=3) 
   VAI.AOP <- sum(LADen$lad, na.rm=TRUE) 
   VCI.AOP <- VCI(Zs, by = 1, zmax=100) 
   out.plot <- data.frame(
      matrix(c(x, y, mean.max.canopy.ht,max.canopy.ht, 
               rumple,deepgaps, deepgap.fraction, 
               cover.fraction, top.rugosity, vert.sd, 
               sd.sd, entro, GFP.AOP, VAI.AOP,VCI.AOP),
             ncol = 15)) 
   colnames(out.plot) <- 
      c("easting", "northing", "mean.max.canopy.ht.aop",
        "max.canopy.ht.aop", "rumple.aop", "deepgaps.aop",
        "deepgap.fraction.aop", "cover.fraction.aop",
        "top.rugosity.aop","vert.sd.aop","sd.sd.aop", 
        "entropy.aop", "GFP.AOP.aop",
        "VAI.AOP.aop", "VCI.AOP.aop") 
   print(out.plot)
}

TEAK_structural_diversity <- structural_diversity_metrics(data.40m)



## ----combine results-----------------------------------------------------------

combined_results=rbind(HARV_structural_diversity, 
                       TEAK_structural_diversity)

# Add row names for clarity
row.names(combined_results)=c("HARV","TEAK")

# Take a look to compare
combined_results


