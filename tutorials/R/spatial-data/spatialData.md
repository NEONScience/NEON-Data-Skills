---
syncID: b152963c4883463883c3b6f0de95fd93
title: "Access and Work with NEON Geolocation Data"
description: "Use files available on the data portal, the NEON API, and the neonUtilities R package to access the locations of NEON sampling events and infrastructure. Calculate more precise locations for certain sampling types, and reference ground sampling to airborne data."
dateCreated: 2019-09-13
authors: [Claire K. Lunch]
contributors:
estimatedTime: 40 minutes
packagesLibraries: neonUtilities
topics: data-management, rep-sci
languageTool: R
code1: R/spatial-data/spatialData.R
tutorialSeries:
urlTitle: neon-spatial-data-basics

---

This tutorial explores NEON geolocation data. The focus is on the locations 
of NEON observational sampling and sensors; NEON remote sensing data are 
inherently spatial and have dedicated tutorials. This tutorial does include 
guidance in linking locations on the ground to remotely sensed images.

## Setup

We'll need several R packages in this tutorial. Install the packages and 
load the libraries for each:


    # run once to get the package, and re-run if you need to get updates
    install.packages("sp")

    ## 
    ## The downloaded binary packages are in
    ## 	/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T//RtmpdIBdy1/downloaded_packages

    install.packages("rgdal")

    ## 
    ## The downloaded binary packages are in
    ## 	/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T//RtmpdIBdy1/downloaded_packages

    install.packages("rgeos")

    ## 
    ## The downloaded binary packages are in
    ## 	/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T//RtmpdIBdy1/downloaded_packages

    install.packages("ggplot2")

    ## 
    ## The downloaded binary packages are in
    ## 	/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T//RtmpdIBdy1/downloaded_packages

    install.packages("ggthemes")

    ## 
    ## The downloaded binary packages are in
    ## 	/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T//RtmpdIBdy1/downloaded_packages

    install.packages("neonUtilities")

    ## 
    ## The downloaded binary packages are in
    ## 	/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T//RtmpdIBdy1/downloaded_packages

    install.packages("devtools")

    ## 
    ## The downloaded binary packages are in
    ## 	/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T//RtmpdIBdy1/downloaded_packages

    devtools::install_github("NEONScience/NEON-geolocation/geoNEON")
    
    # run every time you start a script
    library(sp)
    library(rgdal)
    library(rgeos)
    library(ggplot2)
    library(ggthemes)
    library(neonUtilities)
    library(geoNEON)
    
    options(stringsAsFactors=F)

## Spatial data files

### Site locations

Latitude, longitude, elevation, and some other basic metadata for each site 
are available for download from the <a href="https://www.neonscience.org/field-sites/field-sites-map/list" target="_blank">field sites list page</a> on the NEON website. In this summary by field site, the 
geographic coordinates given for each site correspond to the tower 
location for terrestrial sites, and the center of the permitted reach 
for aquatic sites.

Additional large-scale spatial data files are available on the 
<a href="https://www.neonscience.org/data/spatial-data-maps" target="_blank">spatial data and maps page</a>, primarily as shapefiles. 
Using the domain shapefile and the field sites list, let's make 
a map of NEON site locations.

We'll read in the spatial data using the `rgdal` and `sp` packages 
and plot it using the `ggplot2` package. First, read in the domain 
shapefile:


    # modify "~/data" to the filepath where you downloaded the shapefile
    neon.domains <- readOGR("~/data/NEONDomains_0", layer="NEON_Domains")

    ## OGR data source with driver: ESRI Shapefile 
    ## Source: "/Users/clunch/data/NEONDomains_0", layer: "NEON_Domains"
    ## with 22 features
    ## It has 6 fields

    # the next two commands convert the shapefile to a format ggplot 
    # can use
    neon.domains <- SpatialPolygonsDataFrame(gSimplify(neon.domains, tol=0.1, 
                                                     topologyPreserve=TRUE), 
                                   data=neon.domains@data)
    map <- fortify(neon.domains, region="DomainName")

Let's plot the domains without the sites first:


    gg <- ggplot() + theme_map()
    gg <- gg + geom_map(data=map, map=map,
                        aes(x=long, y=lat, map_id=id, group=group),
                        fill="white", color="black", size=0.3)

    ## Warning: Ignoring unknown aesthetics: x, y

    gg

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/plot-domains-1.png)

Now read in the field sites file, and add points to the map for 
each site:


    # modify "~/data" to the filepath where you downloaded the file
    sites <- read.delim("~/data/field-sites.csv", sep=",", header=T)
    
    gg <- gg + geom_point(data=sites, aes(x=Longitude, y=Latitude))
    gg

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/plot-sites-1.png)

And let's color code sites, plotting terrestrial sites in green and 
aquatic sites in blue:


    gg <- gg + geom_point(data=sites, 
                          aes(x=Longitude, y=Latitude, color=Site.Type)) + 
               scale_color_manual(values=c("blue4", "springgreen4", 
                                           "blue", "olivedrab"),
                                  name="",
                                  breaks=unique(sites$Site.Type))
    gg

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/sites-color-1.png)


### Terrestrial observation plots

The locations of observational sampling plots at terrestrial sites (TOS)
are available in the <a href="http://data.neonscience.org/documents" target="_blank">document library</a> 
on the Data Portal, in the Spatial Data folder, as static files, 
in both tabular and shapefile formats. Your download will be a zip file 
containing tabular files of plot centroids and point locations, and 
shapefiles of plot centroids, point locations, and polygons.

The readme file contains descriptions for each of the columns in the 
tabular files.


    ##       Headers
    ## 1     country
    ## 2       state
    ## 3      county
    ## 4      domain
    ## 5    domainID
    ## 6     siteNam
    ## 7      siteID
    ## 8    plotType
    ## 9     subtype
    ## 10    subSpec
    ## 11     plotID
    ## 12   plotSize
    ## 13    plotDim
    ## 14    pointID
    ## 15   latitude
    ## 16  longitude
    ## 17      datum
    ## 18    utmZone
    ## 19    easting
    ## 20    northng
    ## 21 horzUncert
    ## 22    elevatn
    ## 23 vertUncert
    ## 24    minElev
    ## 25    maxElev
    ## 26      slope
    ## 27     aspect
    ## 28  nlcdClass
    ## 29  soilOrder
    ## 30  crdSource
    ## 31       date
    ## 32    filtPos
    ## 33   plotPdop
    ## 34   plotHdop
    ## 35    appMods
    ## 36    plotEdg
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         Descriptions
    ## 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Country the plot centroid falls in
    ## 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   State the plot centroid falls in
    ## 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  County or municipality the plot centroid falls in
    ## 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   NEON domain name
    ## 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Unique identifier of the NEON domain
    ## 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     Full site name
    ## 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Four letter site code
    ## 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          NEON plot type in which sampling occurred: tower, distributed or gradient
    ## 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Type of plot or grid associated with a plot type: basePlot, mammalGrid, birdGrid, tickPlot, mosquitoPoint, phenology
    ## 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         Subtype specification is there to further differentiate between multiple possible sampling methods employed within a single plot subtype.
    ## 11                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Plot identifier (NEON site code_XXX)
    ## 12                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      plot area (m). Note: Tick plots at GUAN are an alternative shape to the standard 40m by 40m square transect.
    ## 13                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             Dimensions of plot (m). Note: Tick plots at GUAN are an alternative shape to the standard 40m by 40m square transect.
    ## 14                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Point Ids according to a standardized grid system
    ## 15                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               The geographic latitude (in decimal degrees, WGS84)
    ## 16                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              The geographic longitude (in decimal degrees, WGS84)
    ## 17                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Model used to measure horizontal position on the earth
    ## 18                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          UTM zone
    ## 19                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   Geographic coordinate specifying the east-west position of a point on the Earth's surface (Universal Transverse Mercator (UTM))
    ## 20                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Geographic coordinate specifying the north-south position of a point on the Earth's surface (Universal Transverse Mercator (UTM))
    ## 21                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               The horizontal distance (in meters) from the given spatial location describing the smallest circle containing the actual location. 
    ## 22                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        Elevation (in meters) above mean sea level
    ## 23                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         The vertical distance (in meters) from the given elevation describing the maximum range (plus or minus) containing the actual elevation. 
    ## 24                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Minimum elevation of the plot (m)
    ## 25                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Maximum elevation of the plot (m)
    ## 26                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Maximum slope gradient (degrees) within the plot
    ## 27                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Slope aspect (degrees) of the maximum slope gradient within the plot
    ## 28                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     National Land Cover Database classification from the initial year of sampling
    ## 29                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             Soil orders are derived from the USDA NRCS soil survey when available
    ## 30                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                The method used to collect or create spatial information.  GeoXH 6000 and Geo 7X are both models of Trimble handheld GPS recievers
    ## 31                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Date of GPS field collection
    ## 32                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Number of filtered positions taken when collecting GPS data
    ## 33                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       position dilution of precision for GPS data
    ## 34                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     Horizontal dilution of precision for GPS data
    ## 35 Pipe-delimited list of sampling modules : bet= beetles; bgc = biogeochemistry; brd = birds; cdw = coarse woody debris; cfc = canopy foliage chemistry; dhp= digital hemispherical photos for leaf area index; div = plant diversity; hbp = herbaceous productivity;ltr = litter and fine woody debris; mam= mammal abundance and diversity; mfb = mat-forming bryophyte production; mos = mosquitoes; mpt = mosquito pathogens; phe = plant phenology; sme= soil microbes;  tck = ticks; vst = vegetation structure.  Note:  the applicable modules list the possible sampling modules at each plot and does not reflect the temporal schedule.  
    ## 36                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         Length of one edge of the plot square (m)
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Further.Documentation
    ## 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ## 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ## 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ## 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ## 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ## 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ## 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ## 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            For more information, see NEON.DOC.000913 'TOS Science Design for Spatial Sampling' for an overview of the terrestrial observation system sampling strategies
    ## 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            For more information, see NEON.DOC.000913 'TOS Science Design for Spatial Sampling' for an overview of the implementation of the study design
    ## 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           For more information, see NEON.DOC.000913 'TOS Science Design for Spatial Sampling' for an overview of the implementation of the study design
    ## 11                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 12                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 13                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 14                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 For more information, see NEON.DOC.001025 'TOS Protocol and Procedure: Plot Establishment' or NEON.DOC.000913 'TOS Science Design for Spatial Sampling'
    ## 15                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 16                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 17                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 18                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 19                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 20                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 21                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 22                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 23                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 24                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 25                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 26                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 27                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 28                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      For more information, see NEON.DOC.000913 'TOS Science Design for Spatial Sampling'. More information about the NLCD itself can be found at 'http://www.mrlc.gov/'
    ## 29                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  For more information, see https://www.nrcs.usda.gov/wps/portal/nrcs/main/soils/survey/
    ## 30                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 31                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 32                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 33                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 34                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ## 35 See the 'TOS SCIENCE DESIGN FOR SPATIAL SAMPLING' (NEON.DOC.000913) for further details regarding which science design document fully articulates each module. See also specific sampling science designs for more information (NEON.DOC.001024 TOS Protocol and Procedure Canopy Foliage Chemistry and Leaf Mass Per Area Measurements, \tNEON.DOC.001100 TOS Protocol and Procedure Ground Beetle and Mosquito Specimen Processing, \tNEON.DOC.014041 TOS Protocol and Procedure: Breeding Landbird Abundance and Diversity, \tNEON.DOC.001709 TOS Protocol and Procedure: Bryophyte Productivity, \tNEON.DOC.001711 TOS Protocol and Procedure: Coarse Downed Wood, \tNEON.DOC.014038 TOS Protocol and Procedure: Core Sampling for Plant Belowground Biomass, \tNEON.DOC.014050 TOS Protocol and Procedure: Ground Beetle Sampling, \tNEON.DOC.001710 TOS Protocol and Procedure: Litterfall and Fine Woody Debris, \tNEON.DOC.001271 TOS Protocol and Procedure: Manual Data Transcription, \tNEON.DOC.014037 TOS Protocol and Procedure: Measurement of Herbaceous Biomass, \tNEON.DOC.014039 TOS Protocol and Procedure: Measurement of Leaf Area Index, \tNEON.DOC.000987 TOS Protocol and Procedure: Measurement of Vegetation Structure, \tNEON.DOC.014049 TOS Protocol and Procedure: Mosquito Sampling, \tNEON.DOC.014042 TOS Protocol and Procedure: Plant Diversity Sampling, \tNEON.DOC.014040 TOS Protocol and Procedure: Plant Phenology, \tNEON.DOC.000481 TOS Protocol and Procedure: Small Mammal Sampling, \tNEON.DOC.014048 TOS Protocol and Procedure: Soil Physical, Chemical, and Microbial Measurements, \tNEON.DOC.014045 TOS Protocol and Procedure: Tick and Tick-Borne Pathogen Sampling)
    ## 36

You can use these files to navigate the spatial layout of sampling for 
TOS: mosquitoes, beetles, plants, birds, etc. In this tutorial, we'll be 
using the location data provided along with data downloads, as well as 
methods in the `geoNEON` package, to explore TOS spatial data, instead of 
these files.

## Spatial data in data downloads

### Observational data

Both aquatic and terrestrial observational data downloads include spatial 
data in the downloaded files. Let's take a look at the small mammal data. 
Download small mammal data from Onaqui (ONAQ), August 2018 to investigate. 
If downloading data using the `neonUtilties` package is new to you, check 
out the <a href="https://www.neonscience.org/neonDataStackR" target="_blank">neonUtilities tutorial</a>.


    mam <- loadByProduct(dpID="DP1.10072.001", site="ONAQ",
                         startdate="2018-08", enddate="2018-08",
                         check.size=F)

    ## Downloading 1 files
    ##   |                                                                         |                                                                 |   0%  |                                                                         |=================================================================| 100%
    ## 
    ## Unpacking zip files
    ##   |                                                                         |                                                                 |   0%  |                                                                         |=================================================================| 100%
    ## Stacking table mam_perplotnight
    ##   |                                                                         |                                                                 |   0%  |                                                                         |=================================================================| 100%
    ## Stacking table mam_pertrapnight
    ##   |                                                                         |                                                                 |   0%  |                                                                         |=================================================================| 100%
    ## Finished: All of the data are stacked into 2 tables!
    ## Copied the first available variable definition file to /stackedFiles and renamed as variables.csv
    ## Copied the first available validation file to /stackedFiles and renamed as validation.csv
    ## Stacked mam_perplotnight which has 12 out of the expected 12 rows (100%).
    ## Stacked mam_pertrapnight which has 1200 out of the expected 1200 rows (100%).
    ## Stacking took 0.09011889 secs
    ## All unzipped monthly data folders have been removed.

The spatial data are in the `pertrapnight` table.


    head(mam$mam_pertrapnight)

    ##                                    uid
    ## 1 b77289db-b760-48c4-9190-44a4d5949ce2
    ## 2 7a3b267d-a686-4e44-8aaa-64647dea7dec
    ## 3 bbae3ee3-a78e-47d9-a0ea-aa33c1d5066a
    ## 4 6d13e869-18ca-48d9-9eb2-3ea83aa5f508
    ## 5 b9876f71-7065-4f83-8920-452d1aba0e69
    ## 6 a7e09389-cf74-4fc4-8ccf-ea90ec8924ff
    ##                               nightuid           namedLocation domainID
    ## 1 98ae24a1-32e8-41d6-8f59-f3760894b25f ONAQ_003.mammalGrid.mam      D15
    ## 2 1aee40ee-77a3-4317-99bb-731676000400 ONAQ_005.mammalGrid.mam      D15
    ## 3 7b770b07-b204-4b88-b627-4cea87ee71fc ONAQ_020.mammalGrid.mam      D15
    ## 4 7b770b07-b204-4b88-b627-4cea87ee71fc ONAQ_020.mammalGrid.mam      D15
    ## 5 1aee40ee-77a3-4317-99bb-731676000400 ONAQ_005.mammalGrid.mam      D15
    ## 6 7b770b07-b204-4b88-b627-4cea87ee71fc ONAQ_020.mammalGrid.mam      D15
    ##   siteID   plotID trapCoordinate    plotType  nlcdClass decimalLatitude
    ## 1   ONAQ ONAQ_003             G8 distributed shrubScrub        40.20623
    ## 2   ONAQ ONAQ_005             I5 distributed shrubScrub        40.18075
    ## 3   ONAQ ONAQ_020             A1 distributed shrubScrub        40.18389
    ## 4   ONAQ ONAQ_020             G2 distributed shrubScrub        40.18389
    ## 5   ONAQ ONAQ_005            D10 distributed shrubScrub        40.18075
    ## 6   ONAQ ONAQ_020             H9 distributed shrubScrub        40.18389
    ##   decimalLongitude geodeticDatum coordinateUncertainty elevation
    ## 1        -112.4285         WGS84                  45.4    1604.6
    ## 2        -112.4297         WGS84                  45.3    1607.9
    ## 3        -112.4367         WGS84                  45.1    1627.6
    ## 4        -112.4367         WGS84                  45.1    1627.6
    ## 5        -112.4297         WGS84                  45.3    1607.9
    ## 6        -112.4367         WGS84                  45.1    1627.6
    ##   elevationUncertainty             trapStatus   trapType collectDate
    ## 1                  0.2 6 - trap set and empty ShermanXLK  2018-08-14
    ## 2                  0.4 6 - trap set and empty ShermanXLK  2018-08-14
    ## 3                  0.1 6 - trap set and empty ShermanXLK  2018-08-14
    ## 4                  0.1 6 - trap set and empty ShermanXLK  2018-08-14
    ## 5                  0.4 6 - trap set and empty ShermanXLK  2018-08-14
    ## 6                  0.1 6 - trap set and empty ShermanXLK  2018-08-14
    ##      endDate tagID individualCode taxonID scientificName taxonRank
    ## 1 2018-08-14                   NA                                 
    ## 2 2018-08-14                   NA                                 
    ## 3 2018-08-14                   NA                                 
    ## 4 2018-08-14                   NA                                 
    ## 5 2018-08-14                   NA                                 
    ## 6 2018-08-14                   NA                                 
    ##   identificationQualifier identificationReferences nativeStatusCode sex
    ## 1                                               NA                     
    ## 2                                               NA                     
    ## 3                                               NA                     
    ## 4                                               NA                     
    ## 5                                               NA                     
    ## 6                                               NA                     
    ##   recapture fate replacedTag lifeStage testes nipples pregnancyStatus
    ## 1                                                                    
    ## 2                                                                    
    ## 3                                                                    
    ## 4                                                                    
    ## 5                                                                    
    ## 6                                                                    
    ##   vagina hindfootLength earLength tailLength totalLength weight
    ## 1                    NA        NA         NA          NA     NA
    ## 2                    NA        NA         NA          NA     NA
    ## 3                    NA        NA         NA          NA     NA
    ## 4                    NA        NA         NA          NA     NA
    ## 5                    NA        NA         NA          NA     NA
    ## 6                    NA        NA         NA          NA     NA
    ##   larvalTicksAttached nymphalTicksAttached adultTicksAttached
    ## 1                                                            
    ## 2                                                            
    ## 3                                                            
    ## 4                                                            
    ## 5                                                            
    ## 6                                                            
    ##   bloodSampleID bloodSampleBarcode bloodSampleMethod fecalSampleID
    ## 1            NA                 NA                                
    ## 2            NA                 NA                                
    ## 3            NA                 NA                                
    ## 4            NA                 NA                                
    ## 5            NA                 NA                                
    ## 6            NA                 NA                                
    ##   fecalSampleBarcode fecalSampleCondition earSampleID earSampleBarcode
    ## 1                                                                     
    ## 2                                                                     
    ## 3                                                                     
    ## 4                                                                     
    ## 5                                                                     
    ## 6                                                                     
    ##   hairSampleID hairSampleBarcode hairSampleContents voucherSampleID
    ## 1                                                NA              NA
    ## 2                                                NA              NA
    ## 3                                                NA              NA
    ## 4                                                NA              NA
    ## 5                                                NA              NA
    ## 6                                                NA              NA
    ##   voucherSampleBarcode                    measuredBy
    ## 1                   NA   jcramer@battelleecology.org
    ## 2                   NA    cpratt@battelleecology.org
    ## 3                   NA aandroski@battelleecology.org
    ## 4                   NA aandroski@battelleecology.org
    ## 5                   NA    cpratt@battelleecology.org
    ## 6                   NA aandroski@battelleecology.org
    ##                      recordedBy remarks dataQF
    ## 1    cpratt@battelleecology.org             NA
    ## 2   jcramer@battelleecology.org             NA
    ## 3 cpeterson@battelleecology.org             NA
    ## 4 cpeterson@battelleecology.org             NA
    ## 5   jcramer@battelleecology.org             NA
    ## 6 cpeterson@battelleecology.org             NA

But there's a limitation here - the latitudes and longitudes provided 
are for the plots, not for the traps. Take a look at all the data for a 
single plot to see this:


    mam$mam_pertrapnight[which(mam$mam_pertrapnight$plotID=="ONAQ_019"),]

    ##                                      uid
    ## 903 51646dee-5048-4438-aaa1-17b4d932d643
    ## 904 8bea3a9b-5337-4cb8-a15d-bea1e3a5e2c3
    ## 905 b31bc465-228f-42bf-b246-3ff492ef6c57
    ## 911 3f25c82f-02b7-4dbf-840f-d8fd65feab97
    ## 914 8f75526e-31cf-41c8-8c84-b6aba19a9ee1
    ## 918 6e56f777-2ec1-41fd-b3d8-8ec6ebfb5c25
    ## 929 311815d1-5e00-49cf-bfa5-b121289c714b
    ## 930 f738ec14-8dfe-44a3-b457-ad4f6ae06faa
    ## 936 55222f13-afb8-41f6-9546-f2f905b4e419
    ## 938 05706c8b-9cd6-4db4-b461-6db2105ee723
    ## 941 b9e67666-3967-4252-895c-d5667c07ce9f
    ## 951 52b42c92-f274-4753-bd21-7a03b5bd9b91
    ## 953 90f4a4fd-cb77-43d7-aa9a-88086a6b52da
    ## 955 653db2a5-aecc-4cec-a40d-f27da9a797c4
    ## 956 d56aa0b1-b775-4192-b3cb-7d0e87fac47f
    ## 958 9ab5cc04-cf93-40aa-a334-4cb816a32ef5
    ##                                 nightuid           namedLocation domainID
    ## 903 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 904 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 905 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 911 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 914 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 918 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 929 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 930 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 936 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 938 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 941 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 951 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 953 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 955 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 956 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ## 958 3ae92a66-13ef-4ef7-8bd3-930698320054 ONAQ_019.mammalGrid.mam      D15
    ##     siteID   plotID trapCoordinate    plotType  nlcdClass decimalLatitude
    ## 903   ONAQ ONAQ_019             F5 distributed shrubScrub        40.17434
    ## 904   ONAQ ONAQ_019             A8 distributed shrubScrub        40.17434
    ## 905   ONAQ ONAQ_019             B8 distributed shrubScrub        40.17434
    ## 911   ONAQ ONAQ_019             A7 distributed shrubScrub        40.17434
    ## 914   ONAQ ONAQ_019             F3 distributed shrubScrub        40.17434
    ## 918   ONAQ ONAQ_019             F2 distributed shrubScrub        40.17434
    ## 929   ONAQ ONAQ_019             G3 distributed shrubScrub        40.17434
    ## 930   ONAQ ONAQ_019            G10 distributed shrubScrub        40.17434
    ## 936   ONAQ ONAQ_019             I3 distributed shrubScrub        40.17434
    ## 938   ONAQ ONAQ_019             J2 distributed shrubScrub        40.17434
    ## 941   ONAQ ONAQ_019             H5 distributed shrubScrub        40.17434
    ## 951   ONAQ ONAQ_019             I7 distributed shrubScrub        40.17434
    ## 953   ONAQ ONAQ_019             D7 distributed shrubScrub        40.17434
    ## 955   ONAQ ONAQ_019             F8 distributed shrubScrub        40.17434
    ## 956   ONAQ ONAQ_019             B3 distributed shrubScrub        40.17434
    ## 958   ONAQ ONAQ_019             G1 distributed shrubScrub        40.17434
    ##     decimalLongitude geodeticDatum coordinateUncertainty elevation
    ## 903        -112.4807         WGS84                  45.1    1724.4
    ## 904        -112.4807         WGS84                  45.1    1724.4
    ## 905        -112.4807         WGS84                  45.1    1724.4
    ## 911        -112.4807         WGS84                  45.1    1724.4
    ## 914        -112.4807         WGS84                  45.1    1724.4
    ## 918        -112.4807         WGS84                  45.1    1724.4
    ## 929        -112.4807         WGS84                  45.1    1724.4
    ## 930        -112.4807         WGS84                  45.1    1724.4
    ## 936        -112.4807         WGS84                  45.1    1724.4
    ## 938        -112.4807         WGS84                  45.1    1724.4
    ## 941        -112.4807         WGS84                  45.1    1724.4
    ## 951        -112.4807         WGS84                  45.1    1724.4
    ## 953        -112.4807         WGS84                  45.1    1724.4
    ## 955        -112.4807         WGS84                  45.1    1724.4
    ## 956        -112.4807         WGS84                  45.1    1724.4
    ## 958        -112.4807         WGS84                  45.1    1724.4
    ##     elevationUncertainty             trapStatus   trapType collectDate
    ## 903                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 904                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 905                  0.1            5 - capture ShermanXLK  2018-08-17
    ## 911                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 914                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 918                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 929                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 930                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 936                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 938                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 941                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 951                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 953                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 955                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 956                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ## 958                  0.1 6 - trap set and empty ShermanXLK  2018-08-17
    ##        endDate               tagID individualCode taxonID
    ## 903 2018-08-17                                 NA        
    ## 904 2018-08-17                                 NA        
    ## 905 2018-08-17 NEON.MAM.D15.132183             NA    PEPA
    ## 911 2018-08-17                                 NA        
    ## 914 2018-08-17                                 NA        
    ## 918 2018-08-17                                 NA        
    ## 929 2018-08-17                                 NA        
    ## 930 2018-08-17                                 NA        
    ## 936 2018-08-17                                 NA        
    ## 938 2018-08-17                                 NA        
    ## 941 2018-08-17                                 NA        
    ## 951 2018-08-17                                 NA        
    ## 953 2018-08-17                                 NA        
    ## 955 2018-08-17                                 NA        
    ## 956 2018-08-17                                 NA        
    ## 958 2018-08-17                                 NA        
    ##         scientificName taxonRank identificationQualifier
    ## 903                                                     
    ## 904                                                     
    ## 905 Perognathus parvus   species                        
    ## 911                                                     
    ## 914                                                     
    ## 918                                                     
    ## 929                                                     
    ## 930                                                     
    ## 936                                                     
    ## 938                                                     
    ## 941                                                     
    ## 951                                                     
    ## 953                                                     
    ## 955                                                     
    ## 956                                                     
    ## 958                                                     
    ##     identificationReferences nativeStatusCode sex recapture     fate
    ## 903                       NA                                        
    ## 904                       NA                                        
    ## 905                       NA                N   M         Y released
    ## 911                       NA                                        
    ## 914                       NA                                        
    ## 918                       NA                                        
    ## 929                       NA                                        
    ## 930                       NA                                        
    ## 936                       NA                                        
    ## 938                       NA                                        
    ## 941                       NA                                        
    ## 951                       NA                                        
    ## 953                       NA                                        
    ## 955                       NA                                        
    ## 956                       NA                                        
    ## 958                       NA                                        
    ##     replacedTag lifeStage     testes nipples pregnancyStatus vagina
    ## 903                                                                
    ## 904                                                                
    ## 905                 adult nonscrotal                               
    ## 911                                                                
    ## 914                                                                
    ## 918                                                                
    ## 929                                                                
    ## 930                                                                
    ## 936                                                                
    ## 938                                                                
    ## 941                                                                
    ## 951                                                                
    ## 953                                                                
    ## 955                                                                
    ## 956                                                                
    ## 958                                                                
    ##     hindfootLength earLength tailLength totalLength weight
    ## 903             NA        NA         NA          NA     NA
    ## 904             NA        NA         NA          NA     NA
    ## 905             26        NA         NA          NA     20
    ## 911             NA        NA         NA          NA     NA
    ## 914             NA        NA         NA          NA     NA
    ## 918             NA        NA         NA          NA     NA
    ## 929             NA        NA         NA          NA     NA
    ## 930             NA        NA         NA          NA     NA
    ## 936             NA        NA         NA          NA     NA
    ## 938             NA        NA         NA          NA     NA
    ## 941             NA        NA         NA          NA     NA
    ## 951             NA        NA         NA          NA     NA
    ## 953             NA        NA         NA          NA     NA
    ## 955             NA        NA         NA          NA     NA
    ## 956             NA        NA         NA          NA     NA
    ## 958             NA        NA         NA          NA     NA
    ##     larvalTicksAttached nymphalTicksAttached adultTicksAttached
    ## 903                                                            
    ## 904                                                            
    ## 905                   N                    N                  N
    ## 911                                                            
    ## 914                                                            
    ## 918                                                            
    ## 929                                                            
    ## 930                                                            
    ## 936                                                            
    ## 938                                                            
    ## 941                                                            
    ## 951                                                            
    ## 953                                                            
    ## 955                                                            
    ## 956                                                            
    ## 958                                                            
    ##     bloodSampleID bloodSampleBarcode bloodSampleMethod
    ## 903            NA                 NA                  
    ## 904            NA                 NA                  
    ## 905            NA                 NA                  
    ## 911            NA                 NA                  
    ## 914            NA                 NA                  
    ## 918            NA                 NA                  
    ## 929            NA                 NA                  
    ## 930            NA                 NA                  
    ## 936            NA                 NA                  
    ## 938            NA                 NA                  
    ## 941            NA                 NA                  
    ## 951            NA                 NA                  
    ## 953            NA                 NA                  
    ## 955            NA                 NA                  
    ## 956            NA                 NA                  
    ## 958            NA                 NA                  
    ##              fecalSampleID fecalSampleBarcode fecalSampleCondition
    ## 903                                                               
    ## 904                                                               
    ## 905 ONAQ.20180817.132183.F       D00000003237                fresh
    ## 911                                                               
    ## 914                                                               
    ## 918                                                               
    ## 929                                                               
    ## 930                                                               
    ## 936                                                               
    ## 938                                                               
    ## 941                                                               
    ## 951                                                               
    ## 953                                                               
    ## 955                                                               
    ## 956                                                               
    ## 958                                                               
    ##                earSampleID earSampleBarcode hairSampleID hairSampleBarcode
    ## 903                                                                       
    ## 904                                                                       
    ## 905 ONAQ.20180817.132183.E     D00000003215                               
    ## 911                                                                       
    ## 914                                                                       
    ## 918                                                                       
    ## 929                                                                       
    ## 930                                                                       
    ## 936                                                                       
    ## 938                                                                       
    ## 941                                                                       
    ## 951                                                                       
    ## 953                                                                       
    ## 955                                                                       
    ## 956                                                                       
    ## 958                                                                       
    ##     hairSampleContents voucherSampleID voucherSampleBarcode
    ## 903                 NA              NA                   NA
    ## 904                 NA              NA                   NA
    ## 905                 NA              NA                   NA
    ## 911                 NA              NA                   NA
    ## 914                 NA              NA                   NA
    ## 918                 NA              NA                   NA
    ## 929                 NA              NA                   NA
    ## 930                 NA              NA                   NA
    ## 936                 NA              NA                   NA
    ## 938                 NA              NA                   NA
    ## 941                 NA              NA                   NA
    ## 951                 NA              NA                   NA
    ## 953                 NA              NA                   NA
    ## 955                 NA              NA                   NA
    ## 956                 NA              NA                   NA
    ## 958                 NA              NA                   NA
    ##                     measuredBy                    recordedBy remarks
    ## 903 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 904 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 905 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 911 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 914 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 918 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 929 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 930 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 936 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 938 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 941 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 951 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 953 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 955 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 956 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ## 958 cpratt@battelleecology.org cpeterson@battelleecology.org        
    ##     dataQF
    ## 903     NA
    ## 904     NA
    ## 905     NA
    ## 911     NA
    ## 914     NA
    ## 918     NA
    ## 929     NA
    ## 930     NA
    ## 936     NA
    ## 938     NA
    ## 941     NA
    ## 951     NA
    ## 953     NA
    ## 955     NA
    ## 956     NA
    ## 958     NA
    ##  [ reached 'max' / getOption("max.print") -- omitted 84 rows ]

The latitude and longitude are the same for every record. This pattern 
is the same for other TOS data, the data download contains the plot-level 
coordinates.

For many analyses, this level of spatial data is sufficient! But for other 
types of analyses, you may need more precise locations. The `geoNEON` package 
can get these data for you.

The `getLocTOS()` function in the `geoNEON` package uses the NEON API to 
access NEON location data, and then makes protocol-specific calculations 
to return precise sampling locations. For more information about the NEON 
API, see the <a href="https://www.neonscience.org/neon-api-usage" target="_blank">API tutorial</a> 
and the <a href="https://data.neonscience.org/data-api" target="_blank">API web page</a>. 
For more information about the location calculations used in each data product, 
see the Data Product User Guide for each product.

The `getLocTOS()` function requires two inputs:

* A data table from a NEON TOS data product
* The NEON table name of the first input

The list of tables and data products that can be entered is in the 
<a href="https://github.com/NEONScience/NEON-geolocation/tree/master/geoNEON" target="_blank">package documentation on GitHub</a>.

For small mammals, the function call looks like this:


    mam.loc <- getLocTOS(data=mam$mam_pertrapnight,
                               dataProd="mam_pertrapnight")

    ##   |                                                                         |                                                                 |   0%  |                                                                         |                                                                 |   1%  |                                                                         |=                                                                |   1%  |                                                                         |=                                                                |   2%  |                                                                         |==                                                               |   2%  |                                                                         |==                                                               |   3%  |                                                                         |==                                                               |   4%  |                                                                         |===                                                              |   4%  |                                                                         |===                                                              |   5%  |                                                                         |====                                                             |   6%  |                                                                         |====                                                             |   7%  |                                                                         |=====                                                            |   7%  |                                                                         |=====                                                            |   8%  |                                                                         |======                                                           |   8%  |                                                                         |======                                                           |   9%  |                                                                         |======                                                           |  10%  |                                                                         |=======                                                          |  10%  |                                                                         |=======                                                          |  11%  |                                                                         |=======                                                          |  12%  |                                                                         |========                                                         |  12%  |                                                                         |========                                                         |  13%  |                                                                         |=========                                                        |  13%  |                                                                         |=========                                                        |  14%  |                                                                         |==========                                                       |  15%  |                                                                         |==========                                                       |  16%  |                                                                         |===========                                                      |  16%  |                                                                         |===========                                                      |  17%  |                                                                         |===========                                                      |  18%  |                                                                         |============                                                     |  18%  |                                                                         |============                                                     |  19%  |                                                                         |=============                                                    |  19%  |                                                                         |=============                                                    |  20%  |                                                                         |=============                                                    |  21%  |                                                                         |==============                                                   |  21%  |                                                                         |==============                                                   |  22%  |                                                                         |===============                                                  |  22%  |                                                                         |===============                                                  |  23%  |                                                                         |===============                                                  |  24%  |                                                                         |================                                                 |  24%  |                                                                         |================                                                 |  25%  |                                                                         |=================                                                |  26%  |                                                                         |=================                                                |  27%  |                                                                         |==================                                               |  27%  |                                                                         |==================                                               |  28%  |                                                                         |===================                                              |  28%  |                                                                         |===================                                              |  29%  |                                                                         |===================                                              |  30%  |                                                                         |====================                                             |  30%  |                                                                         |====================                                             |  31%  |                                                                         |====================                                             |  32%  |                                                                         |=====================                                            |  32%  |                                                                         |=====================                                            |  33%  |                                                                         |======================                                           |  33%  |                                                                         |======================                                           |  34%  |                                                                         |=======================                                          |  35%  |                                                                         |=======================                                          |  36%  |                                                                         |========================                                         |  36%  |                                                                         |========================                                         |  37%  |                                                                         |========================                                         |  38%  |                                                                         |=========================                                        |  38%  |                                                                         |=========================                                        |  39%  |                                                                         |==========================                                       |  39%  |                                                                         |==========================                                       |  40%  |                                                                         |==========================                                       |  41%  |                                                                         |===========================                                      |  41%  |                                                                         |===========================                                      |  42%  |                                                                         |============================                                     |  42%  |                                                                         |============================                                     |  43%  |                                                                         |============================                                     |  44%  |                                                                         |=============================                                    |  44%  |                                                                         |=============================                                    |  45%  |                                                                         |==============================                                   |  46%  |                                                                         |==============================                                   |  47%  |                                                                         |===============================                                  |  47%  |                                                                         |===============================                                  |  48%  |                                                                         |================================                                 |  48%  |                                                                         |================================                                 |  49%  |                                                                         |================================                                 |  50%  |                                                                         |=================================                                |  50%  |                                                                         |=================================                                |  51%  |                                                                         |=================================                                |  52%  |                                                                         |==================================                               |  52%  |                                                                         |==================================                               |  53%  |                                                                         |===================================                              |  53%  |                                                                         |===================================                              |  54%  |                                                                         |====================================                             |  55%  |                                                                         |====================================                             |  56%  |                                                                         |=====================================                            |  56%  |                                                                         |=====================================                            |  57%  |                                                                         |=====================================                            |  58%  |                                                                         |======================================                           |  58%  |                                                                         |======================================                           |  59%  |                                                                         |=======================================                          |  59%  |                                                                         |=======================================                          |  60%  |                                                                         |=======================================                          |  61%  |                                                                         |========================================                         |  61%  |                                                                         |========================================                         |  62%  |                                                                         |=========================================                        |  62%  |                                                                         |=========================================                        |  63%  |                                                                         |=========================================                        |  64%  |                                                                         |==========================================                       |  64%  |                                                                         |==========================================                       |  65%  |                                                                         |===========================================                      |  66%  |                                                                         |===========================================                      |  67%  |                                                                         |============================================                     |  67%  |                                                                         |============================================                     |  68%  |                                                                         |=============================================                    |  68%  |                                                                         |=============================================                    |  69%  |                                                                         |=============================================                    |  70%  |                                                                         |==============================================                   |  70%  |                                                                         |==============================================                   |  71%  |                                                                         |==============================================                   |  72%  |                                                                         |===============================================                  |  72%  |                                                                         |===============================================                  |  73%  |                                                                         |================================================                 |  73%  |                                                                         |================================================                 |  74%  |                                                                         |=================================================                |  75%  |                                                                         |=================================================                |  76%  |                                                                         |==================================================               |  76%  |                                                                         |==================================================               |  77%  |                                                                         |==================================================               |  78%  |                                                                         |===================================================              |  78%  |                                                                         |===================================================              |  79%  |                                                                         |====================================================             |  79%  |                                                                         |====================================================             |  80%  |                                                                         |====================================================             |  81%  |                                                                         |=====================================================            |  81%  |                                                                         |=====================================================            |  82%  |                                                                         |======================================================           |  82%  |                                                                         |======================================================           |  83%  |                                                                         |======================================================           |  84%  |                                                                         |=======================================================          |  84%  |                                                                         |=======================================================          |  85%  |                                                                         |========================================================         |  86%  |                                                                         |========================================================         |  87%  |                                                                         |=========================================================        |  87%  |                                                                         |=========================================================        |  88%  |                                                                         |==========================================================       |  88%  |                                                                         |==========================================================       |  89%  |                                                                         |==========================================================       |  90%  |                                                                         |===========================================================      |  90%  |                                                                         |===========================================================      |  91%  |                                                                         |===========================================================      |  92%  |                                                                         |============================================================     |  92%  |                                                                         |============================================================     |  93%  |                                                                         |=============================================================    |  93%  |                                                                         |=============================================================    |  94%  |                                                                         |==============================================================   |  95%  |                                                                         |==============================================================   |  96%  |                                                                         |===============================================================  |  96%  |                                                                         |===============================================================  |  97%  |                                                                         |===============================================================  |  98%  |                                                                         |================================================================ |  98%  |                                                                         |================================================================ |  99%  |                                                                         |=================================================================|  99%  |                                                                         |=================================================================| 100%

What columns have been added by `getLocTOS()`?


    names(mam.loc)[which(!names(mam.loc) %in% names(mam$mam_pertrapnight))]

    ## [1] "points"                   "utmZone"                 
    ## [3] "northing"                 "easting"                 
    ## [5] "adjCoordinateUncertainty" "adjDecimalLatitude"      
    ## [7] "adjDecimalLongitude"      "adjElevation"            
    ## [9] "adjElevationUncertainty"

Now we have adjusted latitude, longitude, and elevation, and the 
corresponding easting and northing. We can use the easting and northing to 
plot the locations of the mammal traps:


    plot(mam.loc$easting, mam.loc$northing, pch=".",
         xlab="Easting", ylab="Northing")

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/mam-grids-1.png)

Each grid has 100 points, so even with each trap plotted as a . we can only 
see a square for each grid. Let's zoom in on a single plot:


    plot(mam.loc$easting[which(mam.loc$plotID=="ONAQ_003")], 
         mam.loc$northing[which(mam.loc$plotID=="ONAQ_003")], 
         pch=".", xlab="Easting", ylab="Northing")

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/plot-ONAQ019-1.png)

Now let's add a layer of data to see which of these traps caught a mammal:


    plot(mam.loc$easting[which(mam.loc$plotID=="ONAQ_003")], 
         mam.loc$northing[which(mam.loc$plotID=="ONAQ_003")], 
         pch=".", xlab="Easting", ylab="Northing")
    
    points(mam.loc$easting[which(mam.loc$plotID=="ONAQ_003" & 
                                   mam.loc$trapStatus=="5 - capture")], 
         mam.loc$northing[which(mam.loc$plotID=="ONAQ_003" &
                                  mam.loc$trapStatus=="5 - capture")],
         pch=19, col="blue")

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/plot-captures-1.png)

In the month of data we're viewing, in this plot, animals were caught at 
27 of the 100 traps.


### Sensor data

Downloads of instrument system (IS) data include a file called 
`sensor_positions.csv`. The sensor positions file contains information 
about the coordinates of each sensor, relative to a reference location. 
Let's look at the sensor locations for photosynthetically active 
radiation (PAR) at the Treehaven site (TREE).

The sensor positions file isn't kept by the methods in the `neonUtilities` 
package (we plan to add this in the future!), so go to the 
<a href="https://data.neonscience.org" target="_blank">Data Portal</a> 
and download PAR (DP1.00024.001) data at TREE for July 2018. Unzip the 
monthly package, and read the sensor positions file into R:


    pos <- read.delim("~/data/NEON.D05.TREE.DP1.00024.001.2018-07.basic.20190314T150344Z/NEON.D05.TREE.DP1.00024.001.sensor_positions.20190314T150344Z.csv",
                      sep=",", header=T)
    names(pos)

    ##  [1] "HOR.VER"            "start"              "end"               
    ##  [4] "referenceStart"     "referenceEnd"       "xOffset"           
    ##  [7] "yOffset"            "zOffset"            "pitch"             
    ## [10] "roll"               "azimuth"            "referenceLatitude" 
    ## [13] "referenceLongitude" "referenceElevation"

The sensor locations are indexed by the HOR.VER indices - see the 
<a href="https://data.neonscience.org/file-naming-conventions" target="_blank">file naming conventions</a> 
page for more details about these indices. Here, the PAR data are collected at 
each level of the tower (HOR=000), so only the VER index varies (VER=010-060).

The x, y, and z offsets in the sensor positions file are in meters, and are 
relative to the reference latitude, longitude, and elevation in the file. 
Let's use the offsets to create a spatially explicit picture of light 
attenuation through the canopy.

Load the July 2018 PAR data from TREE into R using `loadByProduct()`:


    pr <- loadByProduct(dpID="DP1.00024.001", site="TREE",
                        startdate="2018-07", enddate="2018-07",
                        avg=30, check.size=F)

    ## Downloading 7 files
    ##   |                                                                         |                                                                 |   0%  |                                                                         |=========                                                        |  14%  |                                                                         |===================                                              |  29%  |                                                                         |============================                                     |  43%  |                                                                         |=====================================                            |  57%  |                                                                         |==============================================                   |  71%  |                                                                         |========================================================         |  86%  |                                                                         |=================================================================| 100%
    ## 
    ## Stacking table PARPAR_30min
    ##   |                                                                         |                                                                 |   0%  |                                                                         |===========                                                      |  17%  |                                                                         |======================                                           |  33%  |                                                                         |================================                                 |  50%  |                                                                         |===========================================                      |  67%  |                                                                         |======================================================           |  83%  |                                                                         |=================================================================| 100%
    ## Finished: All of the data are stacked into 1 tables!
    ## Copied the first available variable definition file to /stackedFiles and renamed as variables.csv
    ## Stacked PARPAR_30min which has 8928 out of the expected 8928 rows (100%).
    ## Stacking took 0.136374 secs
    ## All unzipped monthly data folders have been removed.

The HOR and VER indices in the sensor positions file correspond to the 
`verticalPosition` and `horizontalPosition` fields in `pr$PARPAR_30min`, 
although R has stripped off the leading zeroes from both indices.

Use the `aggregate()` function to calculate mean PAR at each vertical 
position on the tower over the month.


    pr.mn <- aggregate(pr$PARPAR_30min$PARMean, 
                       by=list(pr$PARPAR_30min$verticalPosition),
                       FUN=mean, na.rm=T)

And now we can plot mean PAR relative to elevation on the tower:


    plot(pr.mn$x, pos$zOffset, type="b", pch=20,
         xlab="Photosynthetically active radiation",
         ylab="Height above tower base (m)")

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/par-plot-1.png)







