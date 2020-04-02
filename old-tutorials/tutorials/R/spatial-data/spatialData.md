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
inherently spatial and have dedicated tutorials. If you are interested in 
connecting remote sensing with ground-based measurements, the methods in 
the <a href="https://www.neonscience.org/tree-heights-veg-structure-chm" target="_blank">canopy height model tutorial</a> can be generalized to 
other data products.

## Setup

We'll need several R packages in this tutorial. Install the packages and 
load the libraries for each:


    # run once to get the package, and re-run if you need to get updates
    install.packages("sp")
    install.packages("rgdal")
    install.packages("rgeos")
    install.packages("ggplot2")
    install.packages("ggthemes")
    install.packages("neonUtilities")
    install.packages("devtools")
    devtools::install_github("NEONScience/NEON-geolocation/geoNEON")


    # run every time you start a script
    library(sp)
    library(rgdal)

    ## rgdal: version: 1.4-8, (SVN revision 845)
    ##  Geospatial Data Abstraction Library extensions to R successfully loaded
    ##  Loaded GDAL runtime: GDAL 2.4.2, released 2019/06/28
    ##  Path to GDAL shared files: /Library/Frameworks/R.framework/Versions/3.6/Resources/library/rgdal/gdal
    ##  GDAL binary built with GEOS: FALSE 
    ##  Loaded PROJ.4 runtime: Rel. 5.2.0, September 15th, 2018, [PJ_VERSION: 520]
    ##  Path to PROJ.4 shared files: /Library/Frameworks/R.framework/Versions/3.6/Resources/library/rgdal/proj
    ##  Linking to sp version: 1.3-2

    library(rgeos)

    ## rgeos version: 0.5-1, (SVN revision 614)
    ##  GEOS runtime version: 3.7.2-CAPI-1.11.2 
    ##  Linking to sp version: 1.3-1 
    ##  Polygon checking: TRUE

    library(ggplot2)

    ## Need help getting started? Try the R Graphics Cookbok: https://r-graphics.org

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


    ##  [1] "country"    "state"      "county"     "domain"     "domainID"   "siteNam"    "siteID"     "plotType"  
    ##  [9] "subtype"    "subSpec"    "plotID"     "plotSize"   "plotDim"    "pointID"    "latitude"   "longitude" 
    ## [17] "datum"      "utmZone"    "easting"    "northng"    "horzUncert" "elevatn"    "vertUncert" "minElev"   
    ## [25] "maxElev"    "slope"      "aspect"     "nlcdClass"  "soilOrder"  "crdSource"  "date"       "filtPos"   
    ## [33] "plotPdop"   "plotHdop"   "appMods"    "plotEdg"

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

The spatial data are in the `pertrapnight` table.


    head(mam$mam_pertrapnight[,1:18])

    ##                                    uid                             nightuid           namedLocation domainID
    ## 1 e806918e-7b0f-49df-b93b-8aab86e4ff0e 98ae24a1-32e8-41d6-8f59-f3760894b25f ONAQ_003.mammalGrid.mam      D15
    ## 2 711e0c7a-efc3-41ea-9ff9-52bb753a055f 1aee40ee-77a3-4317-99bb-731676000400 ONAQ_005.mammalGrid.mam      D15
    ## 3 91a8c6c4-6519-483d-8aa3-1ab536427069 7b770b07-b204-4b88-b627-4cea87ee71fc ONAQ_020.mammalGrid.mam      D15
    ## 4 c3e09bc4-2acf-477f-be61-3170beceef51 7b770b07-b204-4b88-b627-4cea87ee71fc ONAQ_020.mammalGrid.mam      D15
    ## 5 0bb83d77-07c7-4f39-9fd1-cd3e3328d91f 1aee40ee-77a3-4317-99bb-731676000400 ONAQ_005.mammalGrid.mam      D15
    ## 6 256dd5c3-a72f-4084-932b-022f33623aaf 7b770b07-b204-4b88-b627-4cea87ee71fc ONAQ_020.mammalGrid.mam      D15
    ##   siteID   plotID trapCoordinate    plotType  nlcdClass decimalLatitude decimalLongitude geodeticDatum
    ## 1   ONAQ ONAQ_003             G8 distributed shrubScrub        40.20623        -112.4285         WGS84
    ## 2   ONAQ ONAQ_005             I5 distributed shrubScrub        40.18075        -112.4297         WGS84
    ## 3   ONAQ ONAQ_020             A1 distributed shrubScrub        40.18389        -112.4367         WGS84
    ## 4   ONAQ ONAQ_020             G2 distributed shrubScrub        40.18389        -112.4367         WGS84
    ## 5   ONAQ ONAQ_005            D10 distributed shrubScrub        40.18075        -112.4297         WGS84
    ## 6   ONAQ ONAQ_020             H9 distributed shrubScrub        40.18389        -112.4367         WGS84
    ##   coordinateUncertainty elevation elevationUncertainty             trapStatus   trapType collectDate
    ## 1                  45.4    1604.6                  0.2 6 - trap set and empty ShermanXLK  2018-08-14
    ## 2                  45.3    1607.9                  0.4 6 - trap set and empty ShermanXLK  2018-08-14
    ## 3                  45.1    1627.6                  0.1 6 - trap set and empty ShermanXLK  2018-08-14
    ## 4                  45.1    1627.6                  0.1 6 - trap set and empty ShermanXLK  2018-08-14
    ## 5                  45.3    1607.9                  0.4 6 - trap set and empty ShermanXLK  2018-08-14
    ## 6                  45.1    1627.6                  0.1 6 - trap set and empty ShermanXLK  2018-08-14

But there's a limitation here - the latitudes and longitudes provided 
are for the plots, not for the traps. Take a look at the coordinates 
for all traps within a single plot to see this:


    mam$mam_pertrapnight[which(mam$mam_pertrapnight$plotID=="ONAQ_019"),
                         c("trapCoordinate","decimalLatitude",
                           "decimalLongitude")]

    ##      trapCoordinate decimalLatitude decimalLongitude
    ## 903              F5        40.17434        -112.4807
    ## 904              A8        40.17434        -112.4807
    ## 905              B8        40.17434        -112.4807
    ## 911              A7        40.17434        -112.4807
    ## 914              F3        40.17434        -112.4807
    ## 918              F2        40.17434        -112.4807
    ## 929              G3        40.17434        -112.4807
    ## 930             G10        40.17434        -112.4807
    ## 936              I3        40.17434        -112.4807
    ## 938              J2        40.17434        -112.4807
    ## 941              H5        40.17434        -112.4807
    ## 951              I7        40.17434        -112.4807
    ## 953              D7        40.17434        -112.4807
    ## 955              F8        40.17434        -112.4807
    ## 956              B3        40.17434        -112.4807
    ## 958              G1        40.17434        -112.4807
    ## 960              B9        40.17434        -112.4807
    ## 961              B7        40.17434        -112.4807
    ## 964              D4        40.17434        -112.4807
    ## 965              J1        40.17434        -112.4807
    ## 966              D6        40.17434        -112.4807
    ## 968              F6        40.17434        -112.4807
    ## 974              I4        40.17434        -112.4807
    ## 980              G2        40.17434        -112.4807
    ## 983              J5        40.17434        -112.4807
    ## 984             I10        40.17434        -112.4807
    ## 985              E8        40.17434        -112.4807
    ## 986              G9        40.17434        -112.4807
    ## 987              J7        40.17434        -112.4807
    ## 990              D3        40.17434        -112.4807
    ## 992              E3        40.17434        -112.4807
    ## 993              H9        40.17434        -112.4807
    ## 998              G6        40.17434        -112.4807
    ## 1000             E7        40.17434        -112.4807
    ## 1001             J3        40.17434        -112.4807
    ## 1008             A1        40.17434        -112.4807
    ## 1010             G5        40.17434        -112.4807
    ## 1011             I6        40.17434        -112.4807
    ## 1012             A4        40.17434        -112.4807
    ## 1014             I2        40.17434        -112.4807
    ## 1015             F9        40.17434        -112.4807
    ## 1016            D10        40.17434        -112.4807
    ## 1017             E2        40.17434        -112.4807
    ## 1019             F1        40.17434        -112.4807
    ## 1020             C8        40.17434        -112.4807
    ## 1021             E5        40.17434        -112.4807
    ## 1022             I9        40.17434        -112.4807
    ## 1035             D5        40.17434        -112.4807
    ## 1038             I8        40.17434        -112.4807
    ## 1046            E10        40.17434        -112.4807
    ## 1050             G4        40.17434        -112.4807
    ## 1055            J10        40.17434        -112.4807
    ## 1056             J4        40.17434        -112.4807
    ## 1060             H8        40.17434        -112.4807
    ## 1061             C5        40.17434        -112.4807
    ## 1062             D8        40.17434        -112.4807
    ## 1063             F4        40.17434        -112.4807
    ## 1066             F7        40.17434        -112.4807
    ## 1070             A2        40.17434        -112.4807
    ## 1073             B6        40.17434        -112.4807
    ## 1075             A6        40.17434        -112.4807
    ## 1076             A5        40.17434        -112.4807
    ## 1077             D9        40.17434        -112.4807
    ## 1085             H2        40.17434        -112.4807
    ## 1088             H7        40.17434        -112.4807
    ## 1096             C3        40.17434        -112.4807
    ## 1098             J8        40.17434        -112.4807
    ## 1100             E1        40.17434        -112.4807
    ## 1101            A10        40.17434        -112.4807
    ## 1105             E4        40.17434        -112.4807
    ## 1106             H1        40.17434        -112.4807
    ## 1107             H4        40.17434        -112.4807
    ## 1109             E6        40.17434        -112.4807
    ## 1112             B4        40.17434        -112.4807
    ## 1114             D1        40.17434        -112.4807
    ## 1115             C1        40.17434        -112.4807
    ## 1118             E9        40.17434        -112.4807
    ## 1122            C10        40.17434        -112.4807
    ## 1123             D2        40.17434        -112.4807
    ## 1125             H6        40.17434        -112.4807
    ## 1131            F10        40.17434        -112.4807
    ## 1132             G8        40.17434        -112.4807
    ## 1136             A9        40.17434        -112.4807
    ## 1137             B2        40.17434        -112.4807
    ## 1140             I5        40.17434        -112.4807
    ## 1141             A3        40.17434        -112.4807
    ## 1146             B1        40.17434        -112.4807
    ## 1147             I1        40.17434        -112.4807
    ## 1155             C7        40.17434        -112.4807
    ## 1160            B10        40.17434        -112.4807
    ## 1164             J6        40.17434        -112.4807
    ## 1165             C4        40.17434        -112.4807
    ## 1168             H3        40.17434        -112.4807
    ## 1169             C9        40.17434        -112.4807
    ## 1171             C6        40.17434        -112.4807
    ## 1176            H10        40.17434        -112.4807
    ## 1177             B5        40.17434        -112.4807
    ## 1178             C2        40.17434        -112.4807
    ## 1179             G7        40.17434        -112.4807
    ## 1196             J9        40.17434        -112.4807

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

What columns have been added by `getLocTOS()`?


    names(mam.loc)[which(!names(mam.loc) %in% names(mam$mam_pertrapnight))]

    ## [1] "points"                   "utmZone"                  "adjNorthing"              "adjEasting"              
    ## [5] "adjCoordinateUncertainty" "adjDecimalLatitude"       "adjDecimalLongitude"      "adjElevation"            
    ## [9] "adjElevationUncertainty"

Now we have adjusted latitude, longitude, and elevation, and the 
corresponding easting and northing. We can use the easting and northing to 
plot the locations of the mammal traps:


    plot(mam.loc$adjEasting, mam.loc$adjNorthing, pch=".",
         xlab="Easting", ylab="Northing")

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/mam-grids-1.png)

Each grid has 100 points, so even with each trap plotted as a . we can only 
see a square for each grid. Let's zoom in on a single plot:


    plot(mam.loc$adjEasting[which(mam.loc$plotID=="ONAQ_003")], 
         mam.loc$adjNorthing[which(mam.loc$plotID=="ONAQ_003")], 
         pch=".", xlab="Easting", ylab="Northing")

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/plot-ONAQ019-1.png)

Now let's add a layer of data to see which of these traps caught a mammal:


    plot(mam.loc$adjEasting[which(mam.loc$plotID=="ONAQ_003")], 
         mam.loc$adjNorthing[which(mam.loc$plotID=="ONAQ_003")], 
         pch=".", xlab="Easting", ylab="Northing")
    
    points(mam.loc$adjEasting[which(mam.loc$plotID=="ONAQ_003" & 
                                   mam.loc$trapStatus=="5 - capture")], 
         mam.loc$adjNorthing[which(mam.loc$plotID=="ONAQ_003" &
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

    ##  [1] "HOR.VER"            "start"              "end"                "referenceStart"     "referenceEnd"      
    ##  [6] "xOffset"            "yOffset"            "zOffset"            "pitch"              "roll"              
    ## [11] "azimuth"            "referenceLatitude"  "referenceLongitude" "referenceElevation"

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







