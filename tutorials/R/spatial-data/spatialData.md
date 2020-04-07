---
syncID: b152963c4883463883c3b6f0de95fd93
title: "Access and Work with NEON Geolocation Data"
description: "Use files available on the NEON data portal, NEON API, and  neonUtilities R package to access the locations of NEON sampling events and infrastructure. Calculate more precise locations for certain sampling types and reference ground sampling to airborne data."
dateCreated: 2019-09-13
authors: [Claire K. Lunch]
contributors: Megan Jones
estimatedTime: 40 minutes
packagesLibraries: neonUtilities
topics: data-management, rep-sci
languageTool: R
dataProduct: 
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

<div id="ds-objectives" markdown="1">

## Learning Objectives 
After completing this tutorial you will be able to: 

* access NEON spatial data from the website and through data downloaded with the neonUtilities package. 
* create a simple map with NEON domains and field site locations. 
* access and plot specific sampling locations for TOS data products. 
* access and use sensor location data. 

## Things You’ll Need To Complete This Tutorial

### R Programming Language
You will need a current version of R to complete this tutorial. We also recommend 
the RStudio IDE to work with R. 


</div>


## Setup R Environment

We'll need several R packages in this tutorial. Install the packages, if not 
already installed, and load the libraries for each. 


    # run once to get the package, and re-run if you need to get updates
    install.packages("sp")  # working with spatial data
    install.packages("rgdal")  # working with spatial data
    install.packages("broom")  # tidy up data
    install.packages("ggplot2")  # plotting
    install.packages("neonUtilities")  # work with NEON data
    install.packages("devtools")  # to use the install_github() function
    devtools::install_github("NEONScience/NEON-geolocation/geoNEON")  # work with NEON spatial data



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

    library(broom)
    library(ggplot2)
    library(neonUtilities)
    library(geoNEON)
    
    options(stringsAsFactors=F)
    
    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files. 
    
    wd <- "~/Documents/data/" # This will depend on your local environment
    setwd(wd)

## Source 1: NEON spatial data files

NEON spatial data are available in a number of different files depending on what
spatial data you are interested in. This section covers a variety of spatial 
data files that can be directly downloaded from the NEONScience.org website 
instead of being delivered with a downloaded data product. Later in the tutorial
we'll work with spatial data available with the downloaded data products. 

The goal of this section is to create a map of the entire Observatory that includes
the NEON domain boundaries and differentiates between aquatic and terrestrial field
sites. 

### Site locations & domain boundaries

Most NEON spatial spatial data files that are not part of the data downloads, 
are available on the 
<a href="https://www.neonscience.org/data/spatial-data-maps" target="_blank">Spatial Data and Maps page</a>, 
as both shapefiles and kmz files. 

In addition, latitude, longitude, elevation, and some other basic metadata for each site 
are available for download from the 
<a href="https://www.neonscience.org/field-sites/field-sites-map/list" target="_blank">Field Sites List page</a>
on the NEON website (linked below the table). In this summary of each field site, 
the geographic coordinates given for each site correspond to the tower 
location for terrestrial sites and the center of the permitted reach 
for aquatic sites.

To continue, please download three files from the NEON website: 

* **NEON Domains - Shapefile:** A polygon shapefile defining NEON's domain boundaries. Like all NEON data the Coordinate Reference system is Geographic WGS 84. Available on the <a href="https://www.neonscience.org/data/spatial-data-maps" target="_blank">Spatial Data and Maps page</a>.
* **Field Site csv:** generic locations data for each NEON field site. Available on the <a href="https://www.neonscience.org/field-sites/field-sites-map/list" target="_blank">Field Sites List page</a> (bottom of table). 

The Field Site location data is also available in as a Shapefile and KMZ on the 
Spatial Data and Maps page. We use the file from the site list to demonstrate 
alternative ways to work with spatial data. 

## Map NEON domains 

Using the domain shapefile and the field sites list, let's make a map of NEON 
site locations.

We'll read in the spatial data using the `rgdal` and `sp` packages 
and plot it using the `ggplot2` package. First, read in the domain 
shapefile. 

Be sure to move the downloaded data files into the  working directory you set 
earlier!


    # upload data
    neonDomains <- readOGR("NEONDomains_0" , layer="NEON_Domains")

The data come is as a Large SpatialPolygonsDataFrame, which unfortunately, ggplot
can't use. Therefore, we'll need to make a few changes to the data structure to 
convert it to a DataFrame that ggplot can use. 


    # First, add a new column termed "id" composed of the row names of the data
    neonDomains@data$id <- rownames(neonDomains@data)
    
    # Now, use tidy() to convert to a dataframe
    # if you previously used fortify(), this does the same thing. 
    neonDomains_points<- tidy(neonDomains, region="id")

    # Finally, merge the new data with the data from our spatial object
    neonDomainsDF <- merge(neonDomains_points, neonDomains@data, by = "id")
Now that the data are in a dataframe, lets check out what data are available 
for us to plot


    # view data structure for each variable
    str(neonDomainsDF)

    ## 'data.frame':	28293 obs. of  13 variables:
    ##  $ id        : chr  "0" "0" "0" "0" ...
    ##  $ long      : num  -74.3 -74.3 -74.3 -74.3 -74.3 ...
    ##  $ lat       : num  40.5 40.5 40.5 40.5 40.5 ...
    ##  $ order     : int  1 2 3 4 5 6 7 8 9 10 ...
    ##  $ hole      : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
    ##  $ piece     : chr  "1" "1" "1" "1" ...
    ##  $ group     : chr  "0.1" "0.1" "0.1" "0.1" ...
    ##  $ OBJECTID  : int  69 69 69 69 69 69 69 69 69 69 ...
    ##  $ Shape_Leng: num  53.7 53.7 53.7 53.7 53.7 ...
    ##  $ DomainID  : int  1 1 1 1 1 1 1 1 1 1 ...
    ##  $ DomainName: chr  "Northeast" "Northeast" "Northeast" "Northeast" ...
    ##  $ Shape_Le_1: num  53.7 53.7 53.7 53.7 53.7 ...
    ##  $ Shape_Area: num  47.6 47.6 47.6 47.6 47.6 ...

We do have **long**itude and **lat**itude data, as well as names of the domains. 
With this info and now that we have the data in a data frame, we can plot it in 
ggplot. Let's first plot the domains without the sites. Since we a plotting a 
map, this means our longitude is plotted on the x axis and latitude is on our 
y axis. 


    # plot domains
    domainMap <- ggplot(neonDomainsDF) + 
            geom_map(map = neonDomainsDF,
                    aes(x = long, y = lat, map_id = id),
                     fill="white", color="black", size=0.3)

    ## Warning: Ignoring unknown aesthetics: x, y

    domainMap

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/plot-domains-1.png)


## Map NEON field sites
Now we have a map of all the NEON domains. Onto this map, let's plot the NEON 
field site locations. To do this we need to load and explore this data. 


    # read in the data
    neonSites <- read.delim("field-sites.csv", sep=",", header=T)
    
    # view data structure for each variable
    str(neonSites)

    ## 'data.frame':	81 obs. of  36 variables:
    ##  $ Site.Name                 : chr  "Little Rock Lake" "West St Louis Creek" "Pu'u Maka'ala Natural Area Reserve" "Flint River" ...
    ##  $ Site.ID                   : chr  "LIRO" "WLOU" "PUUM" "FLNT" ...
    ##  $ Domain.Name               : chr  "Great Lakes" "Southern Rockies & Colorado Plateau" "Pacific Tropical" "Southeast" ...
    ##  $ Domain.Number             : chr  "D05" "D13" "D20" "D03" ...
    ##  $ State                     : chr  "WI" "CO" "HI" "GA" ...
    ##  $ Nearest.Town              : logi  NA NA NA NA NA NA ...
    ##  $ Latitude                  : num  46 39.9 19.6 31.2 38.9 ...
    ##  $ Longitude                 : num  -89.7 -105.9 -155.3 -84.4 -96.4 ...
    ##  $ Site.Type                 : chr  "Relocatable Aquatic" "Relocatable Aquatic" "Core Terrestrial" "Relocatable Aquatic" ...
    ##  $ Site.Subtype              : chr  "Lake" "Wadeable Stream" "" "Non-wadeable River" ...
    ##  $ Site.Host                 : chr  "Wisconsin Department of Natural Resources" "U.S. Forest Service" "Hawaii State Forest Reserve System Department of Land and Natural Resources, Division of Forestry and Wildlife" "Private Owner" ...
    ##  $ Civil.Construction        : chr  "Complete" "Complete" "Complete" "Complete" ...
    ##  $ Civil.Construction.Text   : logi  NA NA NA NA NA NA ...
    ##  $ Sensor.Installation       : chr  "Complete" "Complete" "Complete" "Complete" ...
    ##  $ Sensor.Installation.Text  : logi  NA NA NA NA NA NA ...
    ##  $ Field.Sampling            : chr  "Ongoing" "Ongoing" "Ongoing" "Ongoing" ...
    ##  $ Field.Sampling.Text       : logi  NA NA NA NA NA NA ...
    ##  $ Data.Status               : chr  "Partially Available" "Partially Available" "Partially Available" "Partially Available" ...
    ##  $ Data.Status.Text          : logi  NA NA NA NA NA NA ...
    ##  $ Construction.Status       : chr  "Complete" "Complete" "Complete" "Complete" ...
    ##  $ Construction.Status.Text  : logi  NA NA NA NA NA NA ...
    ##  $ Overview                  : chr  "LIRO is a seepage lake located in Wisconsin and is representative of the Great Lakes ecosystems.\nTotal data pr"| __truncated__ "Total data products planned for this site: 79\n" "NEON's PUUM field site is located in the Pu'u Maka'ala Natural Area Reserve (NAR) on the eastern side of Hawaii"| __truncated__ "Total data products planned for this site: 75\n" ...
    ##  $ Site.Access               : chr  "Yes" "Yes" "TBD" "No" ...
    ##  $ Mean.Annual.Temperature   : chr  "4.4C/39.92F" "-0.3C/31.46F" "13C/55.4F" "19.5C/67.1F" ...
    ##  $ Mean.Annual.Precipitation : chr  "793 mm" "758 mm" "2685 mm" "1307 mm" ...
    ##  $ Dominant.NLCD.Classes     : chr  "Deciduous Forest, Mixed Forest" "Evergreen Forest" "Evergreen Forest" "Mixed Forest" ...
    ##  $ Elevation                 : chr  "502 m" "3103 m" "1685 m" "45 m" ...
    ##  $ Site.Characteristics      : chr  "" "Watershed Size\n5.19 km2\nUSGS HUC: h14010001\nGeology\nSchist, migmatite, and biotitic gneiss.  Paleoproterozoic.\n" "Geology: \nPahoehoe and aa of the Kau Basalt, deposited between 200-750 years ago.\nUSGS HUC: h20010000\nWind D"| __truncated__ "Watershed Size\n29,100 km2\nUSGS HUC: h03130008\nGeology\nUndifferentiated clay, mud, and beach sand. Pleistoce"| __truncated__ ...
    ##  $ Data.Collection.Types     : chr  "Airborne Remote Sensing Surveys\nRemote sensing surveys of this site collect lidar, spectrometer and high resol"| __truncated__ "Airborne Remote Sensing Surveys\nRemote sensing surveys of this site collect lidar, spectrometer and high resol"| __truncated__ "Airborne Remote Sensing Surveys\nRemote sensing surveys of this field site collect lidar, spectrometer and high"| __truncated__ "Airborne Remote Sensing Surveys\nRemote sensing surveys of this site collect lidar, spectrometer and high resol"| __truncated__ ...
    ##  $ Adjacent.Research.Networks: chr  "" "" "" "Jones Ecological Research Center\n" ...
    ##  $ Field.Office              : chr  "Domain 05\n7647 Notre Dame LaneLand O Lakes, WI 54540\nTelephone: 906.842.2119\nContact us\n" "Domain 10/13\n1685 38th Street, Suite 100Boulder, CO 80301\n​Telephone: 720.836.2439\nContact us\n" "Domain 20\n60 Nowelo StreetHilo, Hawaii  96720\nContact us\n" "Domain 03\n4579 NW 6th Street, Unit B-2Gainesville, FL 32609\nTelephone: 352.505.2019\nContact us\n" ...
    ##  $ Gallery                   : chr  "" "WLOU-D13-Stream-Morpology-Map" "" "" ...
    ##  $ Thumbnail                 : chr  "" "" "" "" ...
    ##  $ Overview.Image            : chr  "" "" "" "" ...
    ##  $ Google.Maps.Embed.Code    : logi  NA NA NA NA NA NA ...
    ##  $ Related.Content           : logi  NA NA NA NA NA NA ...

Here there is lots of associated data about the field sites that may be of 
interest. For now, we can see that there are both **Latitude** and **Longitude**
data so we can plot this data onto our previous map. 


    # plot the sites
    neonMap <- domainMap + 
            geom_point(data=neonSites, 
                       aes(x=Longitude, y=Latitude))
    
    neonMap 

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/plot-sites-1.png)

Now we can see all the sites across the Observatory. However, NEON has both
aquatic and terrestrial sites with important differences between the two. Looking
back at the variables in this data set, we can see that **Site.Type** designates
the aquatic and terrestrial sites. However, it goes further and includes whether
or not they are core or relocatable sites. Let's plot that distinction as well. 

We can do this by adding color to our plot, with terrestrial sites in green and
aquatic sites in blue. We can choose darker shades for core sites and lighter 
ones for relocatable sites. 


    # color is determined by the order that the unique values show up. Check order
    unique(neonSites$Site.Type)

    ## [1] "Relocatable Aquatic"     "Core Terrestrial"       
    ## [3] "Core Aquatic"            "Relocatable Terrestrial"

    # add color
    sitesMap <- neonMap + 
            geom_point(data=neonSites, 
                          aes(x=Longitude, y=Latitude, color=Site.Type)) + 
               scale_color_manual(values=c("lightskyblue", "forest green", 
                                           "blue4", "light green"),
                                  name="",
                                  breaks=unique(neonSites$Site.Type))
    sitesMap

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/sites-color-1.png)


## Map terrestrial observation plots

The locations of observational sampling plots at terrestrial sites
are available for download as well from the *NEON Terrestrial Observation System (TOS) sampling locations* file download from the 
<a href="https://www.neonscience.org/data/spatial-data-maps" target="_blank">Spatial Data and Maps page</a> or from the portal in the 
<a href="http://data.neonscience.org/documents" target="_blank">document library</a>. 
The download will be a zip file containing tabular files of plot centroids and 
point locations, and shapefiles of plot centroids, point locations, and polygons.

The readme file contains descriptions for each variable in the tabular files. 


    ## load TOS plot readme
    rdme <- read.delim('All_NEON_TOS_Plots_V7/readme .csv',
                       sep=',', header=T)
    
    ## View the variables
    rdme[,1]

    ##  [1] "country"    "state"      "county"     "domain"     "domainID"  
    ##  [6] "siteNam"    "siteID"     "plotType"   "subtype"    "subSpec"   
    ## [11] "plotID"     "plotSize"   "plotDim"    "pointID"    "latitude"  
    ## [16] "longitude"  "datum"      "utmZone"    "easting"    "northng"   
    ## [21] "horzUncert" "elevatn"    "vertUncert" "minElev"    "maxElev"   
    ## [26] "slope"      "aspect"     "nlcdClass"  "soilOrder"  "crdSource" 
    ## [31] "date"       "filtPos"    "plotPdop"   "plotHdop"   "appMods"   
    ## [36] "plotEdg"

You can use these files to plot the spatial layout of sampling for 
TOS: mosquitoes, beetles, plants, birds, etc. However, for this tutorial, we'll 
be using the location data provided with data downloads, as well as 
methods in the `geoNEON` package, to explore TOS spatial data, instead of 
these files.

You can, however, modify the code from mapping the domains and field sites to 
plot the location data if you'd like to do so. 

## Source 2: Spatial data in data downloads

The second source of data is spatial data in and accompanying data directly 
downloaded from the NEON data portal. How the data are handled are a bit different 
for the Observational Sampling data and the Instrumented Systems data, so we'll 
work through working with both types. 

## Locations for observational data

### Plot level locations
Both aquatic and terrestrial observational data downloads include spatial 
data in the downloaded files. While the specific layout, varies from data type to
data type the method for working with the data are similar. Therefore, we'll work
with NEON Small Mammal Box Trapping data. Our end product for this section is to create a map 
of all the traps within a small mammal grid that captured a mouse in a given 
sampling bout.  

First, let's download the small mammal data from one site, Onaqui (ONAQ), in 
August 2018 to investigate. 

If downloading data using the `neonUtilties` package is new to you, check out the 
<a href="https://www.neonscience.org/neonDataStackR" target="_blank">neonUtilities tutorial</a>.


    # load mammal data
    mam <- loadByProduct(dpID="DP1.10072.001", site="ONAQ",
                         startdate="2018-08", enddate="2018-08",
                         check.size=F)

Data downloaded this way are stored in R as a large list. For this tutorial, 
we'll work with the individual dataframes within this large list. Alternatively, 
each dataframe can be assigned as its own object. 

To find the spatial data for any given data product, view the variables files to
figure out which data table the spatial data are contained in. 


    #
    View(mam$variables_10072)
enteries
Looking through the variables, we can see that the spatial data (decimalLatitude and 
decimalLongitude) are in the `pertrapnight` table. We can look at the first few
entries of the table. 


    head(mam$mam_pertrapnight[,1:18])

    ##                                    uid
    ## 1 e806918e-7b0f-49df-b93b-8aab86e4ff0e
    ## 2 711e0c7a-efc3-41ea-9ff9-52bb753a055f
    ## 3 91a8c6c4-6519-483d-8aa3-1ab536427069
    ## 4 c3e09bc4-2acf-477f-be61-3170beceef51
    ## 5 0bb83d77-07c7-4f39-9fd1-cd3e3328d91f
    ## 6 256dd5c3-a72f-4084-932b-022f33623aaf
    ##                               nightuid           namedLocation
    ## 1 98ae24a1-32e8-41d6-8f59-f3760894b25f ONAQ_003.mammalGrid.mam
    ## 2 1aee40ee-77a3-4317-99bb-731676000400 ONAQ_005.mammalGrid.mam
    ## 3 7b770b07-b204-4b88-b627-4cea87ee71fc ONAQ_020.mammalGrid.mam
    ## 4 7b770b07-b204-4b88-b627-4cea87ee71fc ONAQ_020.mammalGrid.mam
    ## 5 1aee40ee-77a3-4317-99bb-731676000400 ONAQ_005.mammalGrid.mam
    ## 6 7b770b07-b204-4b88-b627-4cea87ee71fc ONAQ_020.mammalGrid.mam
    ##   domainID siteID   plotID trapCoordinate    plotType  nlcdClass
    ## 1      D15   ONAQ ONAQ_003             G8 distributed shrubScrub
    ## 2      D15   ONAQ ONAQ_005             I5 distributed shrubScrub
    ## 3      D15   ONAQ ONAQ_020             A1 distributed shrubScrub
    ## 4      D15   ONAQ ONAQ_020             G2 distributed shrubScrub
    ## 5      D15   ONAQ ONAQ_005            D10 distributed shrubScrub
    ## 6      D15   ONAQ ONAQ_020             H9 distributed shrubScrub
    ##   decimalLatitude decimalLongitude geodeticDatum coordinateUncertainty
    ## 1        40.20623        -112.4285         WGS84                  45.4
    ## 2        40.18075        -112.4297         WGS84                  45.3
    ## 3        40.18389        -112.4367         WGS84                  45.1
    ## 4        40.18389        -112.4367         WGS84                  45.1
    ## 5        40.18075        -112.4297         WGS84                  45.3
    ## 6        40.18389        -112.4367         WGS84                  45.1
    ##   elevation elevationUncertainty             trapStatus   trapType
    ## 1    1604.6                  0.2 6 - trap set and empty ShermanXLK
    ## 2    1607.9                  0.4 6 - trap set and empty ShermanXLK
    ## 3    1627.6                  0.1 6 - trap set and empty ShermanXLK
    ## 4    1627.6                  0.1 6 - trap set and empty ShermanXLK
    ## 5    1607.9                  0.4 6 - trap set and empty ShermanXLK
    ## 6    1627.6                  0.1 6 - trap set and empty ShermanXLK
    ##   collectDate
    ## 1  2018-08-14
    ## 2  2018-08-14
    ## 3  2018-08-14
    ## 4  2018-08-14
    ## 5  2018-08-14
    ## 6  2018-08-14

Did you notice that traps A1 and G2 in plot ONAQ_020 have the same location data?
Let's check all the coordinates for all traps within a single plot. 


    # view all trap locations in one plot
    mam$mam_pertrapnight[which(mam$mam_pertrapnight$plotID=="ONAQ_020"),
                         c("trapCoordinate","decimalLatitude",
                           "decimalLongitude")]

    ##     trapCoordinate decimalLatitude decimalLongitude
    ## 3               A1        40.18389        -112.4367
    ## 4               G2        40.18389        -112.4367
    ## 6               H9        40.18389        -112.4367
    ## 8               F8        40.18389        -112.4367
    ## 9               G5        40.18389        -112.4367
    ## 12              G6        40.18389        -112.4367
    ## 14              A5        40.18389        -112.4367
    ## ... several hundred rows removed for your viewing pleasure ...
    ## 884             D8        40.18389        -112.4367
    ## 891             A9        40.18389        -112.4367
    ## 892             B4        40.18389        -112.4367
    ## 898             A3        40.18389        -112.4367
    ## 899             A7        40.18389        -112.4367

The latitude and longitude are the same for every record! This is because the 
latitudes and longitudes provided are for the plots, not for the traps. This pattern 
is the same for other TOS data, the data download contains the plot-level 
coordinates. This information is in the Data Product User Guide for this, and 
other, NEON data and understanding nuances like this is one reason it is 
important to read the Data Product User Guide for data products before starting 
to use them.

For many analyses, this level of spatial data is sufficient. But for other 
types of analyses, you may need more precise locations. The `geoNEON` package 
can get these data for you.

### Sampling locations 

The `getLocTOS()` function in the `geoNEON` package uses the NEON API to 
access NEON location data and then makes protocol-specific calculations 
to return precise locations for each sampling effort. This function works for a 
subset of NEON TOS data products. The list of tables and data products that can 
be entered is in the 
<a href="https://github.com/NEONScience/NEON-geolocation/tree/master/geoNEON" target="_blank">package documentation on GitHub</a>. 

For more information about the NEON 
API, see the 
<a href="https://www.neonscience.org/neon-api-usage" target="_blank">API tutorial</a> 
and the 
<a href="https://data.neonscience.org/data-api" target="_blank">API web page</a>. 
For more information about the location calculations used in each data product, 
see the Data Product User Guide for each product.

The `getLocTOS()` function requires two inputs:

* A data table, that contains spatial data, from a NEON TOS data product
* The NEON table name of that data table

For small mammal box trap locations, the function call looks like this. This 
function may take a while to download all the location data. 


    # download small mam
    mam.loc <- getLocTOS(data=mam$mam_pertrapnight,
                               dataProd="mam_pertrapnight")

What additional data are now available in the data obtained by `getLocTOS()`?


    # print variable name that are new
    names(mam.loc)[which(!names(mam.loc) %in% names(mam$mam_pertrapnight))]

    ## [1] "points"                   "utmZone"                 
    ## [3] "adjNorthing"              "adjEasting"              
    ## [5] "adjCoordinateUncertainty" "adjDecimalLatitude"      
    ## [7] "adjDecimalLongitude"      "adjElevation"            
    ## [9] "adjElevationUncertainty"

Now we have adjusted latitude, longitude, and elevation, and the 
corresponding easting and northing UTM data. We also have coordinate uncertainty 
data for these coordinates. 

We can use the easting and northing data to plot the locations of the mammal traps. 


    # plot all trap locations at site
    plot(mam.loc$adjEasting, mam.loc$adjNorthing, pch=".",
         xlab="Easting", ylab="Northing")

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/mam-grids-1.png)

Each trap grid has 100 points (individual trap locations), so even with each
trap plotted as a dot (.) we can only see a square for each grid. 
Let's zoom in on a single plot:


    # plot all trap locations in one grid (plot)
    plot(mam.loc$adjEasting[which(mam.loc$plotID=="ONAQ_003")], 
         mam.loc$adjNorthing[which(mam.loc$plotID=="ONAQ_003")], 
         pch=".", xlab="Easting", ylab="Northing")

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/plot-ONAQ003-1.png)

This isn't the most interesting plot given that that each small mammal box 
trapping grid is a 10 x 10 plot of traps. 

Now, let's add a layer of data to see which of these traps caught a mammal during
the August 2018 sampling bout. To do this we need to look at our variables file
again and see what variable gives us information about captures. We can see that
**trapStatus** provides the information on what happened to each trap. It has 
categorical data on the status: 

* 0 - no data
* 1 - trap not set
* 2 - trap disturbed/door closed but empty
* 3 - trap door open or closed w/ spoor left
* 4 - >1 capture in one trap
* 5 - capture
* 6 - trap set and empty

Therefore, we need to plot all trap locations in this plot (ONAQ_003) for which 
trapStatus is "5 - capture" (technically, we should add in a capture status of 
4 as well but for demonstration purposes, keeping it simple). 


    # plot all captures 
    plot(mam.loc$adjEasting[which(mam.loc$plotID == "ONAQ_003")], 
         mam.loc$adjNorthing[which(mam.loc$plotID == "ONAQ_003")], 
         pch=".", xlab="Easting", ylab="Northing")
    
    points(mam.loc$adjEasting[which(mam.loc$plotID == "ONAQ_003" & 
                                   mam.loc$trapStatus == "5 - capture")], 
         mam.loc$adjNorthing[which(mam.loc$plotID =="ONAQ_003" &
                                  mam.loc$trapStatus == "5 - capture")],
         pch=19, col="blue")

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/plot-captures-1.png)

In the month of data we're viewing, in this plot, small mammals were caught at 
27 of the 100 trap locations.

The basic techniques for working with this data can be adapted to other TOS 
location data for other data products.  

## Locations for sensor data

Downloads of instrument system (IS) data include a file called 
**sensor_positions.csv**. The sensor positions file contains information 
about the coordinates of each sensor, relative to a reference location. 

While the specifics vary, techniques are generalizable for working with sensor 
data and the sensor_positions.csv file. For this tutorial, let's look at the 
sensor locations for photosynthetically active radiation (PAR; DP1.00024.001) at 
the NEON Treehaven site (TREE) in July 2018. To reduce our file size, we'll use 
the 30 minute averaging interval. Our final product from this section is to 
create a spatially explicit picture of light attenuation through the canopy.

If downloading data using the `neonUtilties` package is new to you, check out the 
<a href="https://www.neonscience.org/neonDataStackR" target="_blank">neonUtilities tutorial</a>.

This function will download <1 MB of data as written so we have `check.size =F` 
for ease of running the code. 


    # load PAR data of interest 
    par <- loadByProduct(dpID="DP1.00024.001", site="TREE",
                        startdate="2018-07", enddate="2018-07",
                        avg=30, check.size=F)

### Sensor positions file 
Now we can specifically look at the sensor positions file.


    # create object for sens. pos. file
    pos <- par$sensor_positions_00024
    
    # view names
    names(pos)

    ##  [1] "siteID"             "HOR.VER"            "start"             
    ##  [4] "end"                "referenceStart"     "referenceEnd"      
    ##  [7] "xOffset"            "yOffset"            "zOffset"           
    ## [10] "pitch"              "roll"               "azimuth"           
    ## [13] "referenceLatitude"  "referenceLongitude" "referenceElevation"
    ## [16] "publicationDate"

The sensor locations are indexed by the `HOR.VER` variable - see the 
<a href="https://data.neonscience.org/file-naming-conventions" target="_blank">file naming conventions</a> 
page for more details. 

Using `unique()` we can view all the locations indexes in this file. 


    # view names
    unique(pos$HOR.VER)

    ## [1] "000.010" "000.020" "000.030" "000.040" "000.050" "000.060"

PAR data are collected at multiple levels of the NEON tower but along a single 
vertical plane. We see this reflected in the data where HOR=000 (all data collected)
at the tower location. The VER index varies (VER = 010 to 060) showing that the 
vertical position is changing and that PAR is measured at six different levels.

The x, y, and z offsets in the sensor positions file are the relative distance, 
in meters, to the reference latitude, longitude, and elevation in the file. 

The HOR and VER indices in the sensor positions file correspond to the 
`verticalPosition` and `horizontalPosition` fields in `par$PARPAR_30min`.

Since our goal is to plot a profile of the PAR through the canopy, we need to 
start by using the `aggregate()` function to calculate mean PAR at each vertical 
position on the tower over the month.


    # calc mean PAR at each level
    parMean <- aggregate(par$PARPAR_30min$PARMean, 
                       by=list(par$PARPAR_30min$verticalPosition),
                       FUN=mean, na.rm=T)

And now we can plot mean PAR relative to elevation on the tower since that is the 
zOffset. 


    # plot PAR
    plot(parMean$x, pos$zOffset, type="b", pch=20,
         xlab="Photosynthetically active radiation",
         ylab="Height above tower base (m)")

![ ]({{ site.baseurl }}/images/rfigs/R/spatial-data/spatialData/par-plot-1.png)

From our plot we can see that the amount of light (with PAR as a proxy) increases
higher up in the canopy.  

