---
title: "Calculating Forest Structural Diversity Metrics from NEON LiDAR Data"
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Lidar/structural-diversity/structural-diversity-discrete-return/Structural-Diversity-Discrete-Return.R
contributors: Jeff Atkins, Keith Krause, Atticus Stovall
dataProduct: null
dateCreated: '2020-05-01'
description: Read in a NEON LiDAR file (.laz) and calculate several forest structural diversity
  metrics.
estimatedTime: 30 minutes
languagesTool: R
packagesLibraries: lidR, gstat
syncID: 7a3d01f3a2a84e6092774e2d21e13a16
authors: Elizabeth LaRue, Donal O'Leary
topics: hyperspectral, HDF5, remote-sensing
tutorialSeries: null
urlTitle: structural-diversity-discrete-return
fundingSource: "these materials were developed with additional support from NSF MSB-NES # 1924942 to Elizabeth LaRue."
---
<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

* Read a NEON LiDAR file (laz) into R
* Visualize a spatial subset of the LiDAR tile
* Correct a spatial subset of the LiDAR tile for topographic varation
* Calculate 13 structural diversity metrics described in <a href="https://doi.org/10.3390/rs12091407" target="_blank">LaRue, Wagner, et al. (2020) </a>

## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### R Libraries to Install:

* **lidR**: `install.packages('lidR')`
* **gstat**: `install.packages('gstat')`

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More 
on Packages in R - Adapted from Software Carpentry.</a>


### Data to Download

For this tutorial, we will be using two .laz files containing NEON 
AOP point clouds for 1km tiles from the <a href="https://www.neonscience.org/field-sites/field-sites-map/HARV" target="_blank">Harvard Forest (HARV)</a> and 
<a href="https://www.neonscience.org/field-sites/field-sites-map/TEAK" target="_blank">Lower Teakettle (TEAK)</a> sites.

<a href="https://drive.google.com/open?id=1Aemh0IVKvC-LoMj2AXr9k8rDQk77l8k7" target="_blank"> **Link to download .laz files on Google Drive Here.**</a>

***
### Recommended Skills

For this tutorial, you should have an understanding of Light Detection 
And Ranging (LiDAR) technology, specifically how discrete return lidar 
data are collected and represented in las/laz files. For more information 
on how lidar works, please see this 
<a href="https://www.youtube.com/watch?v=EYbhNSUnIdU" target="_blank"> primer video </a>
and
<a href="https://www.neonscience.org/intro-lidar-r-series" target="_blank"> Introduction to Lidar Tutorial Series.</a>

</div> 

## Introduction to Structural Diversity Metrics
Forest structure influences many important ecological processes, including 
biogeochemical cycling, wildfires, species richness and diversity, and many 
others. Quantifying forest structure, hereafter referred to as "structural 
diversity," presents a challenge for many reasons, including difficulty in 
measuring individual trees, limbs, and leaves across large areas. In order 
to overcome this challenge, today's researchers use Light Detection And 
Ranging (LiDAR) technology to measure large areas of forest. It is also 
challenging to calculate meaningful summary metrics of a forest's structure 
that 1) are ecologically relevant and 2) can be used to compare different 
forested locations. In this tutorial, you will be introduced to a few tools 
that will help you to explore and quantify forest structure using LiDAR data 
collected at two field sites of the 
<a href="https://www.neonscience.org/" target="_blank"> 
National Ecological Observatory Network</a>. 

## NEON AOP Discrete Return LIDAR
<a href="https://www.neonscience.org/data-collection/airborne-remote-sensing" target="_blank"> The NEON Airborne Observation Platform (AOP) </a>. 
has several sensors including discrete-return LiDAR, which is useful for measuring forest structural diversity that can be summarized into four categories of metrics: (1) canopy height, (2) canopy cover and openness, and (3) canopy heterogeneity (internal and external), and (4) vegetation area.

We will be comparing the structural diversity of two NEON sites that vary in their structural characteristics. 

First, we will look at <a href="https://www.neonscience.org/field-sites/field-sites-map/HARV" target="_blank">Harvard Forest (HARV)</a>, which is located in Massachusetts. It is a lower elevation, mixed deciduous and evergreen forest dominated by Quercus rubra, Acer rubrum, and Aralia nudicaulis.

Second, we will look at <a href="https://www.neonscience.org/field-sites/field-sites-map/TEAK" target="_blank">Lower Teakettle (TEAK)</a>, which is a high elevation forested NEON site in California. TEAK is an evergreen forest dominated by Abies magnifica, Abies concolor, Pinus jeffreyi, and Pinus contorta. 

As you can imagine, these two forest types will have both similarities and differences in their structural attributes. We can quantify these attributes by calculating several different structural diversity metrics, and comparing 
the results.

## Loading the LIDAR Products
To begin, we first need to load our required R packages, and set our working 
directory to the location where we saved the input LiDAR .laz files that can be 
downloaded from the NEON Data Portal.


    ############### Packages ################### 
    library(lidR)

    ## lidR 3.0.3 using 1 threads. Help on <gis.stackexchange.com>. Bug report on <github.com/Jean-Romain/lidR>.

    library(gstat)
    
    ############### Set working directory ######
    #set the working of the downloaded tutorial folder
    wd <- "~/Git/data/" #This will depend on your local machine
    setwd(wd)

Next, we will read in the LiDAR data using the `lidR::readLAS()` function. 
Note that this function can read in both `.las` and `.laz` file formats.


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


    ############## Look at data specs ######
    #Let's check out the extent, coordinate system, and a 3D plot of each 
    #.laz file. Note that on Mac computers you may need to install 
    #XQuartz for 3D plots - see xquartz.org
    summary(HARV)
    plot(HARV)

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/lidar-point-clouds/HARV1km2.JPG">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/lidar-point-clouds/HARV1km2.JPG"
    alt="1 km-squared point cloud from Harvard Forest showing a gentle slope covered in a continuous canopy of mixed forest.">
    </a>
</figure>


    summary(TEAK)
    plot(TEAK)


<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/lidar-point-clouds/TEAK1km2.JPG">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/lidar-point-clouds/TEAK1km2.JPG"
    alt="1 km-squared point cloud from Lower Teakettle showing mountainous terrain covered in a patchy conifer forest, with tall, skinny conifers clearly visible emerging from the discontinuous canopy.">
    </a>
</figure>

## Normalizing Tree Height to Ground
To begin, we will take a look at the structural diversity of the dense mixed deciduous/evergreen 
forest of HARV. We're going to choose a 40 x 40 m spatial extent for our analysis, but first we 
need to normalize the height values of this LiDAR point cloud from an absolute elevation 
above mean sea level to height above the ground using the `lidR::lasnormalize()` function. This 
function relies on spatial interpolation, and therefore we want to perform this step on an area 
that is quite a bit larger than our area of interest to avoid edge effects. To be safe, we will 
clip out an area of 200 x 200 m, normalize it, and then clip out our smaller area of interest.


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
       lasclipRectangle(HARV,
                        xleft = (x - 100), ybottom = (y - 100),
                        xright = (x + 100), ytop = (y + 100))
    
    #Correct for ground height using a kriging function to interpolate 
    #elevation from ground points in the .laz file.
    #If the function will not run, then you may need to checkfor outliers
    #by adjusting the 'drop_z_' arguments when reading in the .laz files.
    dtm <- grid_terrain(data.200m, 1, kriging(k = 10L))

    ## Warning: There were 7 degenerated ground points. Some X Y coordinates
    ## were repeated but with different Z coordinates. min Z were retained.

    data.200m <- lasnormalize(data.200m, dtm)
    
    #Will often give a warning if not all points could be corrected, 
    #but visually check to see if it corrected for ground height. 
    plot(data.200m)
    #There's only a few uncorrected points and we'll fix these in 
    #the next step. 
    
    #Clip 20 m out from each side of the easting and northing 
    #coordinates (x,y).
    data.40m <- 
       lasclipRectangle(data.200m, 
                        xleft = (x - 20), ybottom = (y - 20),
                        xright = (x + 20), ytop = (y + 20))
    
    data.40m@data$Z[data.40m@data$Z <= .5] <- NA  
    #This line filters out all z_vals below .5 m as we are less 
    #interested in shrubs/trees. 
    #You could change it to zero or another height depending on interests. 
    
    #visualize the clipped plot point cloud
    plot(data.40m) 

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/lidar-point-clouds/HARV40mx40m.JPG">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/lidar-point-clouds/HARV40mx40m.JPG"
    alt="40 meter by 40 meter point cloud from Harvard Forest showing a cross-section of the forest structure with a complex canopy- and sub-canopy structure with many rounded crowns, characteristic of a deciduous-dominated section of forest.">
    </a>
</figure>

## Calculating Structural Diversity Metrics
Now that we have our area of interest normalized and clipped, we can proceed with calculating 
our structural diversity metrics. 


    ############# Structural diversity metrics  ######
    
    #GENERATE CANOPY HEIGHT MODEL (CHM) (i.e. a 1 m2 raster grid of 
    #vegetations heights)
    #res argument specifies pixel size in meters and dsmtin is 
    #for raster interpolation
    chm <- grid_canopy(data.40m, res = 1, dsmtin())  
    
    #visualize CHM
    plot(chm) 

![Canopy Height Model (CHM) of HARV study area](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Lidar/structural-diversity/structural-diversity-discrete-return/rfigs/calculate-structural-diversity-metrics-1.png)

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
    vert.sd <- lasmetrics(data.40m, sd(Z, na.rm = TRUE)) 

    ## Error in lasmetrics(data.40m, sd(Z, na.rm = TRUE)): could not find function "lasmetrics"

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

We now have 13 metrics of structural diversity, which we can arrange into a single table:


    #OUTPUT CALCULATED METRICS INTO A TABLE
    #creates a dataframe row, out.plot, containing plot descriptors 
    #and calculated metrics
    HARV_structural_diversity <- 
       data.frame(matrix(c(x, y, mean.max.canopy.ht, max.canopy.ht, 
                           rumple, deepgaps,deepgap.fraction,
                           cover.fraction,top.rugosity, vert.sd, 
                           sd.sd, entro,GFP.AOP, VAI.AOP, VCI.AOP),
                         ncol = 15)) 

    ## Error in matrix(c(x, y, mean.max.canopy.ht, max.canopy.ht, rumple, deepgaps, : object 'vert.sd' not found

    #provide descriptive names for the calculated metrics
    colnames(HARV_structural_diversity) <- 
       c("easting", "northing", "mean.max.canopy.ht.aop",
         "max.canopy.ht.aop", "rumple.aop", "deepgaps.aop",
         "deepgap.fraction.aop","cover.fraction.aop", 
         "top.rugosity.aop", "vert.sd.aop", "sd.sd.aop", 
         "entropy.aop", "GFP.AOP.aop", "VAI.AOP.aop", "VCI.AOP.aop") 

    ## Error in colnames(HARV_structural_diversity) <- c("easting", "northing", : object 'HARV_structural_diversity' not found

    #View the results
    HARV_structural_diversity 

    ## Error in eval(expr, envir, enclos): object 'HARV_structural_diversity' not found

## Combining Everything Into One Function
Now that we have run through how to measure each structural diversity metric, let's create a 
convenient function to run these a little faster on the TEAK site for a comparison of structural 
diversity with HARV. 


    #Let's correct for elevation and measure structural diversity for TEAK
    x <- 316400 
    y <- 4091700
    
    data.200m <- lasclipRectangle(TEAK, 
                                  xleft = (x - 100), ybottom = (y - 100),
                                  xright = (x + 100), ytop = (y + 100))
    
    dtm <- grid_terrain(data.200m, 1, kriging(k = 10L))

    ## Warning: There were 4 degenerated ground points. Some X Y Z coordinates
    ## were repeated. They were removed.

    ## Warning: There were 41 degenerated ground points. Some X Y coordinates
    ## were repeated but with different Z coordinates. min Z were retained.

    data.200m <- lasnormalize(data.200m, dtm)
    
    data.40m <- lasclipRectangle(data.200m, 
                                 xleft = (x - 20), ybottom = (y - 20),
                                 xright = (x + 20), ytop = (y + 20))
    data.40m@data$Z[data.40m@data$Z <= .5] <- 0  
    plot(data.40m)

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/lidar-point-clouds/TEAK40mx40m.JPG">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/lidar-point-clouds/TEAK40mx40m.JPG"
    alt="40 meter by 40 meter point cloud from Lower Teakettle showing a cross-section of the forest structure with several tall, pointed conifers separated by deep gaps in the canopy.">
    </a>
</figure>


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
       vert.sd <- lasmetrics(data.40m, sd(Z, na.rm = TRUE)) 
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

    ## Error in lasmetrics(data.40m, sd(Z, na.rm = TRUE)): could not find function "lasmetrics"

## Comparing Metrics Between Forests
How does the structural diversity of the evergreen TEAK forest compare to the mixed deciduous/evergreen forest from HARV? Let's combine the result data.frames for a direct comparison:


    combined_results=rbind(HARV_structural_diversity, 
                           TEAK_structural_diversity)

    ## Error in rbind(HARV_structural_diversity, TEAK_structural_diversity): object 'HARV_structural_diversity' not found

    # Add row names for clarity
    row.names(combined_results)=c("HARV","TEAK")

    ## Error in row.names(combined_results) = c("HARV", "TEAK"): object 'combined_results' not found

    # Take a look to compare
    combined_results

    ## Error in eval(expr, envir, enclos): object 'combined_results' not found
