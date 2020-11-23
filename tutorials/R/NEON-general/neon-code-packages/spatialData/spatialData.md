---
syncID: b152963c4883463883c3b6f0de95fd93
title: "Access and Work with NEON Geolocation Data"
description: "Use files available on the NEON data portal, NEON API, and  neonUtilities R package to access the locations of NEON sampling events and infrastructure. Calculate more precise locations for certain sampling types and reference ground sampling to airborne data."
dateCreated: 2019-09-13
authors: Claire K. Lunch
contributors: Megan Jones, Alison Dernbach, Donal O'Leary
estimatedTime: 40 minutes
packagesLibraries: sp, rgdal, maptools, broom, ggplot2, neonUtilities
topics: data-management, rep-sci
languageTool: R
dataProduct: DP1.10072.001, DP1.00024.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-code-packages/spatialData/spatialData.R
tutorialSeries:
urlTitle: neon-spatial-data-basics

---

This tutorial explores NEON geolocation data. The focus is on the locations 
of NEON observational sampling and sensors; NEON remote sensing data are 
inherently spatial and have dedicated tutorials. If you are interested in 
connecting remote sensing with ground-based measurements, the methods in 
the <a href="https://www.neonscience.org/tree-heights-veg-structure-chm" target="_blank">canopy height model tutorial</a> 
can be generalized to other data products.

<div id="ds-objectives" markdown="1">

## Learning Objectives 
After completing this tutorial you will be able to: 

* access NEON spatial data from the website and through data downloaded with the 
neonUtilities package. 
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
    install.packages("sp")  # work with spatial data
    install.packages("rgdal")  # work with spatial data
    install.packages("maptools")  # work with spatial objects
    install.packages("broom")  # tidy up data
    install.packages("ggplot2")  # plotting
    install.packages("neonUtilities")  # work with NEON data
    install.packages("devtools")  # to use the install_github() function
    devtools::install_github("NEONScience/NEON-geolocation/geoNEON")  # work with NEON spatial data



    # run every time you start a script
    library(sp)
    library(rgdal)
    library(maptools)
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
data files that can be directly downloaded from the 
<a href="https://www.neonscience.org" target="_blank">NEONScience.org</a> website 
instead of being delivered with a downloaded data product. Later in the tutorial 
we'll work with spatial data available with the downloaded data products.

The goal of this section is to create a map of the entire Observatory that includes 
the NEON domain boundaries and differentiates between aquatic and terrestrial field 
sites. 

### Site locations & domain boundaries

Most NEON spatial data files that are not part of the data downloads 
are available on the 
<a href="https://www.neonscience.org/data/spatial-data-maps" target="_blank">Spatial Data and Maps page</a> 
as both shapefiles and kmz files. 

In addition, latitude, longitude, elevation, and some other basic metadata for each site 
are available for download from the 
<a href="https://www.neonscience.org/field-sites/field-sites-map/list" target="_blank">Field Sites List page</a> 
on the NEON website (linked below the table). In this summary of each field site, 
the geographic coordinates for each site correspond to the tower 
location for terrestrial sites and the center of the permitted reach 
for aquatic sites.

To continue, please download these files from the NEON website: 

* **NEON Domains - Shapefile:** A polygon shapefile defining NEON's domain 
boundaries. Like all NEON data the Coordinate Reference system is Geographic 
WGS 84. Available on the <a href="https://www.neonscience.org/data/spatial-data-maps" target="_blank">Spatial Data and Maps page</a>.
* **Field Site csv:** generic locations data for each NEON field site. Available on the <a href="https://www.neonscience.org/field-sites/field-sites-map/list" target="_blank">Field Sites List page</a> (bottom of table). 

The Field Site location data is also available as a shapefile and KMZ on the 
Spatial Data and Maps page. We use the file from the site list to demonstrate 
alternative ways to work with spatial data. 

## Map NEON domains 

Using the domain shapefile and the field sites list, let's make a map of NEON 
site locations.

We'll read in the spatial data using the `rgdal` and `sp` packages and plot it 
using the `ggplot2` package. First, read in the domain shapefile. 

Be sure to move the downloaded and unzipped data files into the working directory 
you set earlier!


    # upload data
    neonDomains <- readOGR(paste0(wd,"NEONDomains_0"), layer="NEON_Domains")

The data come as a Large SpatialPolygonsDataFrame, which unfortunately `ggplot`
can't use. Therefore, we'll need to make a few changes to the data structure to 
convert it to a dataframe that `ggplot` can use. 


    # first, add a new column termed "id" composed of the row names of the data
    neonDomains@data$id <- rownames(neonDomains@data)
    
    # now, use tidy() to convert to a dataframe
    # if you previously used fortify(), this does the same thing 
    neonDomains_points <- tidy(neonDomains, region="id")
    
    # finally, merge the new data with the data from our spatial object
    neonDomainsDF <- merge(neonDomains_points, neonDomains@data, by = "id")

Now that the data are in a dataframe, let's check out what data are available 
for us to plot.


    # view data structure for each variable
    str(neonDomainsDF)

    ## 'data.frame':	28293 obs. of  13 variables:
    ##  $ id        : chr  "0" "0" "0" "0" ...
    ##  $ long      : num  -74.3 -74.3 -74.3 -74.3 -74.3 ...
    ##  $ lat       : num  40.5 40.5 40.5 40.5 40.5 ...
    ##  $ order     : int  1 2 3 4 5 6 7 8 9 10 ...
    ##  $ hole      : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
    ##  $ piece     : Factor w/ 19 levels "1","2","3","4",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ group     : Factor w/ 52 levels "0.1","1.1","10.1",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ OBJECTID  : int  69 69 69 69 69 69 69 69 69 69 ...
    ##  $ Shape_Leng: num  53.7 53.7 53.7 53.7 53.7 ...
    ##  $ DomainID  : int  1 1 1 1 1 1 1 1 1 1 ...
    ##  $ DomainName: chr  "Northeast" "Northeast" "Northeast" "Northeast" ...
    ##  $ Shape_Le_1: num  53.7 53.7 53.7 53.7 53.7 ...
    ##  $ Shape_Area: num  47.6 47.6 47.6 47.6 47.6 ...

We have **long**itude and **lat**itude data, as well as names of the domains. 
With this information, and now that we have the data in a dataframe, we can plot 
it in ggplot. Let's first plot the domains without the sites. Since we are plotting 
a map, this means our longitude is plotted on the x axis and latitude is on our 
y axis. 


    # plot domains
    domainMap <- ggplot(neonDomainsDF, aes(x=long, y=lat)) + 
            geom_map(map = neonDomainsDF,
                    aes(map_id = id),
                     fill="white", color="black", size=0.3)
    
    domainMap

![Map of the United States with each NEON domain outlined](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/plot-domains-1.png)


## Map NEON field sites
Now that we have a map of all the NEON domains, let's plot the NEON field site 
locations on it. To do this, we need to load and explore the field sites data. 


    # read in the data
    neonSites <- read.delim(paste0(wd,"field-sites.csv"), sep=",", header=T)
    
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

Here there is a lot of associated data about the field sites that may be of 
interest. For now, we can see that there are both **Latitude** and **Longitude**
data so we can plot this data onto our previous map. 


    # plot the sites
    neonMap <- domainMap + 
            geom_point(data=neonSites, 
                       aes(x=Longitude, y=Latitude))
    
    neonMap 

![Same map as above but with dots for the field site locations across the country](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/plot-sites-1.png)

Now we can see all the sites across the Observatory. However, NEON has both 
aquatic and terrestrial sites with important differences between the two. Looking 
back at the variables in this data set, we can see that `Site.Type` designates 
the aquatic and terrestrial sites. However, it goes further and includes whether 
or not they are core or relocatable sites. Let's plot that distinction as well. 

We can do this by adding color to our plot, with terrestrial sites in green and 
aquatic sites in blue. We can choose darker shades for core sites and lighter 
ones for relocatable sites. 


    # color is determined by the order that the unique values show up
    # check order
    unique(neonSites$Site.Type)

    ## [1] "Relocatable Aquatic"     "Core Terrestrial"        "Core Aquatic"           
    ## [4] "Relocatable Terrestrial"

    # add color
    sitesMap <- neonMap + 
            geom_point(data=neonSites, 
                          aes(x=Longitude, y=Latitude, color=Site.Type)) + 
               scale_color_manual(values=c("lightskyblue", "forest green", 
                                           "blue4", "light green"),
                                  name="",
                                  breaks=unique(neonSites$Site.Type))
    sitesMap

![Same as maps above but the field site dots are now four different colors](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/sites-color-1.png)


## Map terrestrial observation plots

The **NEON Terrestrial Observation System (TOS) sampling locations** shapefile 
is available for download from the
<a href="https://www.neonscience.org/data/spatial-data-maps" target="_blank"> Spatial Data and Maps page</a> or from the portal in the
<a href="http://data.neonscience.org/documents" target="_blank"> document library</a>. 
The download will be a zip file containing tabular files of plot centroids and 
point locations, and shapefiles of plot centroids, point locations, and polygons.

The readme file contains descriptions for each variable in the tabular files. 


    # load TOS plot readme
    rdme <- read.delim(paste0(wd,'All_NEON_TOS_Plots_V8/readme.csv'),
                       sep=',', header=T)
    
    # view the variables
    rdme[,1]

    ##  [1] "country"    "state"      "county"     "domain"     "domainID"   "siteNam"    "siteID"    
    ##  [8] "plotType"   "subtype"    "subSpec"    "plotID"     "plotSize"   "plotDim"    "pointID"   
    ## [15] "latitude"   "longitude"  "datum"      "utmZone"    "easting"    "northng"    "horzUncert"
    ## [22] "elevatn"    "vertUncert" "minElev"    "maxElev"    "slope"      "aspect"     "nlcdClass" 
    ## [29] "soilOrder"  "crdSource"  "date"       "filtPos"    "plotPdop"   "plotHdop"   "appMods"   
    ## [36] "plotEdg"

You can use these files to plot the spatial layout of sampling for TOS (mosquitoes, 
beetles, plants, birds, etc.). However, instead of using these files, for this 
tutorial we'll be using the location data provided with the data downloads below, 
as well as methods in the `geoNEON` package, to explore TOS spatial data.

You can, however, modify the code above from mapping the domains and field sites to 
plot the location data if you'd like to do so. 

## Source 2: Spatial data in data downloads

The second source of data is spatial data in and accompanying data directly 
downloaded from the NEON data portal. How the data are handled are a bit different 
for the Observational Sampling data and the Instrumented Systems data, so we'll 
go through working with both types. 

## Locations for observational data

### Plot level locations
Both aquatic and terrestrial observational data downloads include spatial 
data in the downloaded files. While the specific layout varies from data type to 
data type the method for working with the data are similar. Therefore, we'll work 
with NEON Small Mammal Box Trapping data. Our end product for this section is to 
create a map of all the traps within a small mammal grid that captured a mouse in a given 
sampling bout.  

First, let's download the small mammal data from one site, Onaqui (ONAQ), in 
August 2018 to investigate. 

If downloading data using the `neonUtilities` package is new to you, check out the 
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


    View(mam$variables_10072)

Looking through the variables, we can see that the spatial data (`decimalLatitude` 
and `decimalLongitude`) are in the `pertrapnight` table. We can look at the first few
entries of the table. 


    head(mam$mam_pertrapnight[,1:18])

    ##                                    uid                             nightuid           namedLocation
    ## 1 80a67c44-e910-447a-828e-6c055aafcaa8 7b770b07-b204-4b88-b627-4cea87ee71fc ONAQ_020.mammalGrid.mam
    ## 2 a13e9723-c471-4870-b5e8-e985ab1de97c 98ae24a1-32e8-41d6-8f59-f3760894b25f ONAQ_003.mammalGrid.mam
    ## 3 8193f7dc-c323-4081-8a59-044486c7e9a7 7b770b07-b204-4b88-b627-4cea87ee71fc ONAQ_020.mammalGrid.mam
    ## 4 db227468-aa3e-47e8-a025-9e7cf882a624 1aee40ee-77a3-4317-99bb-731676000400 ONAQ_005.mammalGrid.mam
    ## 5 33150123-e3f8-40a2-b274-6b97e9101661 1aee40ee-77a3-4317-99bb-731676000400 ONAQ_005.mammalGrid.mam
    ## 6 d6734e56-4b8a-4755-ba3a-b43af6feba7e 1aee40ee-77a3-4317-99bb-731676000400 ONAQ_005.mammalGrid.mam
    ##   domainID siteID   plotID trapCoordinate    plotType  nlcdClass decimalLatitude decimalLongitude
    ## 1      D15   ONAQ ONAQ_020             I4 distributed shrubScrub        40.18389        -112.4367
    ## 2      D15   ONAQ ONAQ_003             J2 distributed shrubScrub        40.20623        -112.4285
    ## 3      D15   ONAQ ONAQ_020             E8 distributed shrubScrub        40.18389        -112.4367
    ## 4      D15   ONAQ ONAQ_005            B10 distributed shrubScrub        40.18075        -112.4297
    ## 5      D15   ONAQ ONAQ_005             J3 distributed shrubScrub        40.18075        -112.4297
    ## 6      D15   ONAQ ONAQ_005             G2 distributed shrubScrub        40.18075        -112.4297
    ##   geodeticDatum coordinateUncertainty elevation elevationUncertainty             trapStatus   trapType
    ## 1         WGS84                  45.1    1627.6                  0.1 6 - trap set and empty ShermanXLK
    ## 2         WGS84                  45.4    1604.6                  0.2 6 - trap set and empty ShermanXLK
    ## 3         WGS84                  45.1    1627.6                  0.1 6 - trap set and empty ShermanXLK
    ## 4         WGS84                  45.3    1607.9                  0.4 6 - trap set and empty ShermanXLK
    ## 5         WGS84                  45.3    1607.9                  0.4 6 - trap set and empty ShermanXLK
    ## 6         WGS84                  45.3    1607.9                  0.4 6 - trap set and empty ShermanXLK
    ##   collectDate
    ## 1  2018-08-14
    ## 2  2018-08-14
    ## 3  2018-08-14
    ## 4  2018-08-14
    ## 5  2018-08-14
    ## 6  2018-08-14

Did you notice that traps in plot ONAQ_020 have the same location data?
Let's check the coordinates for all traps within a single plot. 


    # view all trap locations in one plot
    mam$mam_pertrapnight[which(mam$mam_pertrapnight$plotID=="ONAQ_020"),
                         c("trapCoordinate","decimalLatitude",
                           "decimalLongitude")]

    ##     trapCoordinate decimalLatitude decimalLongitude
    ## 1               I4        40.18389        -112.4367
    ## 3               E8        40.18389        -112.4367
    ## 8               F2        40.18389        -112.4367
    ## 15              D6        40.18389        -112.4367
    ## 16              G4        40.18389        -112.4367
    ## 22              H8        40.18389        -112.4367
    ## 27              C5        40.18389        -112.4367
    ## 28              F1        40.18389        -112.4367
    ## 29              I9        40.18389        -112.4367
    ## 34              D9        40.18389        -112.4367
    ## 37              A4        40.18389        -112.4367
    ## 38              D5        40.18389        -112.4367
    ## 39              A6        40.18389        -112.4367
    ## 43              B1        40.18389        -112.4367
    ## 45              E9        40.18389        -112.4367
    ## 47              E2        40.18389        -112.4367
    ## 53             H10        40.18389        -112.4367
    ## 54              D4        40.18389        -112.4367
    ## 56              H5        40.18389        -112.4367
    ## 58              B9        40.18389        -112.4367
    ## 59              I6        40.18389        -112.4367
    ## 60              C6        40.18389        -112.4367
    ## 64              J6        40.18389        -112.4367
    ## 72              E3        40.18389        -112.4367
    ## 73              H7        40.18389        -112.4367
    ## 74              C7        40.18389        -112.4367
    ## 75              D3        40.18389        -112.4367
    ## 77              B5        40.18389        -112.4367
    ## 80              F6        40.18389        -112.4367
    ## 84              A2        40.18389        -112.4367
    ## 85              C1        40.18389        -112.4367
    ## 87              H2        40.18389        -112.4367
    ## 90              D2        40.18389        -112.4367
    ## 91              B2        40.18389        -112.4367
    ## 96              G9        40.18389        -112.4367
    ## 100             J1        40.18389        -112.4367
    ## 103             I7        40.18389        -112.4367
    ## 108             B3        40.18389        -112.4367
    ## 110             H6        40.18389        -112.4367
    ## 113             C4        40.18389        -112.4367
    ## 117             J4        40.18389        -112.4367
    ## 118             F3        40.18389        -112.4367
    ## 120             B8        40.18389        -112.4367
    ## 125             J2        40.18389        -112.4367
    ## 129             F7        40.18389        -112.4367
    ## 131             B6        40.18389        -112.4367
    ## 137             E4        40.18389        -112.4367
    ## 141             A9        40.18389        -112.4367
    ## 145             J3        40.18389        -112.4367
    ## 152             G3        40.18389        -112.4367
    ## 156            B10        40.18389        -112.4367
    ## 158             A3        40.18389        -112.4367
    ## 160            C10        40.18389        -112.4367
    ## 161             B7        40.18389        -112.4367
    ## 162             C2        40.18389        -112.4367
    ## 166            F10        40.18389        -112.4367
    ## 172             E5        40.18389        -112.4367
    ## 173             F4        40.18389        -112.4367
    ## 175             J5        40.18389        -112.4367
    ## 176             A8        40.18389        -112.4367
    ## 179             A1        40.18389        -112.4367
    ## 180             G2        40.18389        -112.4367
    ## 182             H9        40.18389        -112.4367
    ## 184             F8        40.18389        -112.4367
    ## 185             G5        40.18389        -112.4367
    ## 188             G6        40.18389        -112.4367
    ## 190             A5        40.18389        -112.4367
    ## 191             F5        40.18389        -112.4367
    ## 193            E10        40.18389        -112.4367
    ## 195             D1        40.18389        -112.4367
    ## 205             G8        40.18389        -112.4367
    ## 213             G7        40.18389        -112.4367
    ## 214             H1        40.18389        -112.4367
    ## 219             A7        40.18389        -112.4367
    ## 220             H4        40.18389        -112.4367
    ## 222             C3        40.18389        -112.4367
    ## 225             C8        40.18389        -112.4367
    ## 226             B4        40.18389        -112.4367
    ## 227             G1        40.18389        -112.4367
    ## 231             I2        40.18389        -112.4367
    ## 236            J10        40.18389        -112.4367
    ## 239             D8        40.18389        -112.4367
    ## 243             J7        40.18389        -112.4367
    ## 245             E1        40.18389        -112.4367
    ## 247            A10        40.18389        -112.4367
    ## 248             H3        40.18389        -112.4367
    ## 249            I10        40.18389        -112.4367
    ## 263             I3        40.18389        -112.4367
    ## 264             F9        40.18389        -112.4367
    ## 266             C9        40.18389        -112.4367
    ## 267             J8        40.18389        -112.4367
    ## 274            G10        40.18389        -112.4367
    ## 278             J9        40.18389        -112.4367
    ## 281            D10        40.18389        -112.4367
    ## 284             I8        40.18389        -112.4367
    ## 285             D7        40.18389        -112.4367
    ## 287             E6        40.18389        -112.4367
    ## 292             I1        40.18389        -112.4367
    ## 295             I5        40.18389        -112.4367
    ## 299             E7        40.18389        -112.4367
    ## 302             E8        40.18389        -112.4367
    ## 309             F4        40.18389        -112.4367
    ## 310             I9        40.18389        -112.4367
    ## 312             D6        40.18389        -112.4367
    ## 313             A2        40.18389        -112.4367
    ## 317             F8        40.18389        -112.4367
    ## 320            C10        40.18389        -112.4367
    ## 323             G8        40.18389        -112.4367
    ## 328             J1        40.18389        -112.4367
    ## 329             E3        40.18389        -112.4367
    ## 330             A1        40.18389        -112.4367
    ## 333             E4        40.18389        -112.4367
    ## 334             B9        40.18389        -112.4367
    ## 339             C7        40.18389        -112.4367
    ## 344             G7        40.18389        -112.4367
    ## 345             G5        40.18389        -112.4367
    ## 346             G2        40.18389        -112.4367
    ## 348             C9        40.18389        -112.4367
    ## 349             B8        40.18389        -112.4367
    ## 362             E7        40.18389        -112.4367
    ## 368             F1        40.18389        -112.4367
    ## 369             E9        40.18389        -112.4367
    ## 370             H1        40.18389        -112.4367
    ## 371             G4        40.18389        -112.4367
    ## 372             H2        40.18389        -112.4367
    ## 374             A5        40.18389        -112.4367
    ## 378             E2        40.18389        -112.4367
    ## 382             B4        40.18389        -112.4367
    ## 391             B5        40.18389        -112.4367
    ## 394             E6        40.18389        -112.4367
    ## 397             A3        40.18389        -112.4367
    ## 399             J5        40.18389        -112.4367
    ## 400             I2        40.18389        -112.4367
    ## 409             C5        40.18389        -112.4367
    ## 413             B2        40.18389        -112.4367
    ## 415             I1        40.18389        -112.4367
    ## 416             G3        40.18389        -112.4367
    ## 417             F3        40.18389        -112.4367
    ## 418             D7        40.18389        -112.4367
    ## 423             F7        40.18389        -112.4367
    ## 426             B6        40.18389        -112.4367
    ## 433             G1        40.18389        -112.4367
    ## 436             G9        40.18389        -112.4367
    ## 437             J2        40.18389        -112.4367
    ## 443             G6        40.18389        -112.4367
    ## 444             B7        40.18389        -112.4367
    ## 453             C4        40.18389        -112.4367
    ## 454             H6        40.18389        -112.4367
    ## 455            D10        40.18389        -112.4367
    ## 463             J3        40.18389        -112.4367
    ## 464             B1        40.18389        -112.4367
    ## 469            G10        40.18389        -112.4367
    ## 471             A8        40.18389        -112.4367
    ## 474             C8        40.18389        -112.4367
    ## 475             F6        40.18389        -112.4367
    ## 477             D8        40.18389        -112.4367
    ## 479             D1        40.18389        -112.4367
    ## 484             I8        40.18389        -112.4367
    ## 485             A6        40.18389        -112.4367
    ## 488             D9        40.18389        -112.4367
    ## 489            E10        40.18389        -112.4367
    ## 492             I6        40.18389        -112.4367
    ## 493             I5        40.18389        -112.4367
    ## 505             H3        40.18389        -112.4367
    ## 508             A4        40.18389        -112.4367
    ## 509            A10        40.18389        -112.4367
    ## 512             D2        40.18389        -112.4367
    ## 513             B3        40.18389        -112.4367
    ## 514             H7        40.18389        -112.4367
    ## 520             C3        40.18389        -112.4367
    ## 524             D3        40.18389        -112.4367
    ## 525             J9        40.18389        -112.4367
    ## 526             H5        40.18389        -112.4367
    ## 531             J7        40.18389        -112.4367
    ## 534             D5        40.18389        -112.4367
    ## 535             J4        40.18389        -112.4367
    ## 536             A7        40.18389        -112.4367
    ## 538            J10        40.18389        -112.4367
    ## 542             F9        40.18389        -112.4367
    ## 545             I7        40.18389        -112.4367
    ## 547             H9        40.18389        -112.4367
    ## 549             I3        40.18389        -112.4367
    ## 551            H10        40.18389        -112.4367
    ## 552             A9        40.18389        -112.4367
    ## 560             E1        40.18389        -112.4367
    ## 562             E5        40.18389        -112.4367
    ## 563             C1        40.18389        -112.4367
    ## 564             H4        40.18389        -112.4367
    ## 567             C2        40.18389        -112.4367
    ## 568             I4        40.18389        -112.4367
    ## 571             F2        40.18389        -112.4367
    ## 575            B10        40.18389        -112.4367
    ## 578            F10        40.18389        -112.4367
    ## 579             D4        40.18389        -112.4367
    ## 583             H8        40.18389        -112.4367
    ## 584             J6        40.18389        -112.4367
    ## 590             J8        40.18389        -112.4367
    ## 591             F5        40.18389        -112.4367
    ## 598            I10        40.18389        -112.4367
    ## 599             C6        40.18389        -112.4367
    ## 601             E2        40.18389        -112.4367
    ## 602             E1        40.18389        -112.4367
    ## 604             J3        40.18389        -112.4367
    ## 606            D10        40.18389        -112.4367
    ## 607             D9        40.18389        -112.4367
    ## 617             F4        40.18389        -112.4367
    ## 625             B8        40.18389        -112.4367
    ## 626             I7        40.18389        -112.4367
    ## 632             E7        40.18389        -112.4367
    ## 634            A10        40.18389        -112.4367
    ## 636             D8        40.18389        -112.4367
    ## 641             B9        40.18389        -112.4367
    ## 642             C5        40.18389        -112.4367
    ## 645             E3        40.18389        -112.4367
    ## 646             A2        40.18389        -112.4367
    ## 647             C4        40.18389        -112.4367
    ## 648             D1        40.18389        -112.4367
    ## 654             A9        40.18389        -112.4367
    ## 655             B4        40.18389        -112.4367
    ## 661             A3        40.18389        -112.4367
    ## 662             A7        40.18389        -112.4367
    ## 666             B6        40.18389        -112.4367
    ## 667             I8        40.18389        -112.4367
    ## 671             B2        40.18389        -112.4367
    ## 672             C7        40.18389        -112.4367
    ## 676             H6        40.18389        -112.4367
    ## 677            F10        40.18389        -112.4367
    ## 678            I10        40.18389        -112.4367
    ## 686             I3        40.18389        -112.4367
    ## 695             H7        40.18389        -112.4367
    ## 696             C9        40.18389        -112.4367
    ## 709             F6        40.18389        -112.4367
    ## 714            C10        40.18389        -112.4367
    ## 716             I4        40.18389        -112.4367
    ## 722             F1        40.18389        -112.4367
    ## 725             E9        40.18389        -112.4367
    ## 727             G2        40.18389        -112.4367
    ## 728             A8        40.18389        -112.4367
    ## 730             G7        40.18389        -112.4367
    ## 732             J8        40.18389        -112.4367
    ## 737             E8        40.18389        -112.4367
    ## 738             B3        40.18389        -112.4367
    ## 741             H4        40.18389        -112.4367
    ## 747            B10        40.18389        -112.4367
    ## 749             F9        40.18389        -112.4367
    ## 751             H8        40.18389        -112.4367
    ## 752             F5        40.18389        -112.4367
    ## 754             G8        40.18389        -112.4367
    ## 755             H9        40.18389        -112.4367
    ## 756            H10        40.18389        -112.4367
    ## 760             G6        40.18389        -112.4367
    ## 761             A4        40.18389        -112.4367
    ## 762             D2        40.18389        -112.4367
    ## 764             F8        40.18389        -112.4367
    ## 767             G5        40.18389        -112.4367
    ## 769             A6        40.18389        -112.4367
    ## 774             C6        40.18389        -112.4367
    ## 775             B5        40.18389        -112.4367
    ## 778             H1        40.18389        -112.4367
    ## 780             G1        40.18389        -112.4367
    ## 782             J7        40.18389        -112.4367
    ## 785             G4        40.18389        -112.4367
    ## 788             J5        40.18389        -112.4367
    ## 790             C2        40.18389        -112.4367
    ## 792             D4        40.18389        -112.4367
    ## 795             A1        40.18389        -112.4367
    ## 797             A5        40.18389        -112.4367
    ## 800             E4        40.18389        -112.4367
    ## 803            G10        40.18389        -112.4367
    ## 806             J9        40.18389        -112.4367
    ## 807             G3        40.18389        -112.4367
    ## 808             C1        40.18389        -112.4367
    ## 809             D6        40.18389        -112.4367
    ## 813             J6        40.18389        -112.4367
    ## 814             D3        40.18389        -112.4367
    ## 817             I2        40.18389        -112.4367
    ## 820             I6        40.18389        -112.4367
    ## 822             F7        40.18389        -112.4367
    ## 823            J10        40.18389        -112.4367
    ## 830             D5        40.18389        -112.4367
    ## 840             J1        40.18389        -112.4367
    ## 841             H5        40.18389        -112.4367
    ## 843            E10        40.18389        -112.4367
    ## 846             D7        40.18389        -112.4367
    ## 847             I9        40.18389        -112.4367
    ## 850             B7        40.18389        -112.4367
    ## 857             I1        40.18389        -112.4367
    ## 859             F2        40.18389        -112.4367
    ## 864             G9        40.18389        -112.4367
    ## 866             J2        40.18389        -112.4367
    ## 867             J4        40.18389        -112.4367
    ## 868             H2        40.18389        -112.4367
    ## 869             C3        40.18389        -112.4367
    ## 873             I5        40.18389        -112.4367
    ## 875             E5        40.18389        -112.4367
    ## 880             H3        40.18389        -112.4367
    ## 881             E6        40.18389        -112.4367
    ## 888             C8        40.18389        -112.4367
    ## 891             F3        40.18389        -112.4367
    ## 900             B1        40.18389        -112.4367

The latitude and longitude are the same for every record! This is because the 
latitudes and longitudes provided are for the plots, not for the traps. Other 
TOS data has the same pattern: the data download contains the plot-level 
coordinates. This important information is in the **Data Product User Guide** and 
can be downloaded from the 
<a href="http://data.neonscience.org" target="_blank">NEON Data Portal</a> on a 
data product's page. Understanding nuances like this is one reason it is 
important to read the Data Product User Guide.

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

For more information about the NEON API, see the 
<a href="https://www.neonscience.org/neon-api-usage" target="_blank">API tutorial</a> 
and the 
<a href="https://data.neonscience.org/data-api" target="_blank">API web page</a>. 
For more information about the location calculations used in each data product, 
see the Data Product User Guide for each product.

The `getLocTOS()` function requires two inputs:

* A data table that contains spatial data from a NEON TOS data product
* The NEON table name of that data table

For small mammal box trap locations, the function call looks like this. This 
function may take a while to download all the location data. 


    # download small mam locationso
    mam.loc <- getLocTOS(data=mam$mam_pertrapnight,
                               dataProd="mam_pertrapnight")

    ## Warning in showSRID(uprojargs, format = "PROJ", multiline = "NO"): Discarded datum Unknown based on WGS84
    ## ellipsoid in CRS definition

What additional data are now available in the data obtained by `getLocTOS()`?


    # print variable names that are new
    names(mam.loc)[which(!names(mam.loc) %in% names(mam$mam_pertrapnight))]

    ## [1] "points"                   "utmZone"                  "adjNorthing"             
    ## [4] "adjEasting"               "adjCoordinateUncertainty" "adjDecimalLatitude"      
    ## [7] "adjDecimalLongitude"      "adjElevation"             "adjElevationUncertainty"

Now we have adjusted latitude, longitude, and elevation, and the 
corresponding easting and northing UTM data. We also have coordinate uncertainty 
data for these coordinates. 

We can use the easting and northing data to plot the locations of the mammal traps. 


    # plot all trap locations at site
    plot(mam.loc$adjEasting, mam.loc$adjNorthing, pch=".",
         xlab="Easting", ylab="Northing")

![Six square points on a plot each made up of smaller dots that form either a complete square point or a partially filled in square point](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/mam-grids-1.png)

Each trap grid has 100 points (individual trap locations), so even with each 
trap plotted as a dot (.) we can only see a square for each grid. 

Let's zoom in on a single plot:


    # plot all trap locations in one grid (plot)
    plot(mam.loc$adjEasting[which(mam.loc$plotID=="ONAQ_003")], 
         mam.loc$adjNorthing[which(mam.loc$plotID=="ONAQ_003")], 
         pch=".", xlab="Easting", ylab="Northing", cex=3)

![dots on a plot equally spaced in 10 rows and 10 columns](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/plot-ONAQ003-1.png)

This isn't the most interesting plot given that that each small mammal box 
trapping grid is a 10 x 10 plot of traps. 

Now, let's add a layer of data to see which of these traps caught a mammal during 
the August 2018 sampling bout. To do this we need to look at our variables file 
again and see what variable gives us information about captures. We can see that 
`trapStatus` provides the information on what happened to each trap. It has 
categorical data on the status: 

* 0 - no data
* 1 - trap not set
* 2 - trap disturbed/door closed but empty
* 3 - trap door open or closed w/ spoor left
* 4 - >1 capture in one trap
* 5 - capture
* 6 - trap set and empty

Therefore, we need to plot all trap locations in this plot (ONAQ_003) for which 
`trapStatus` is "5 - capture" (technically, we should add in a capture status of 
4 but for demonstration purposes, we'll keep it simple).


    # plot all captures 
    plot(mam.loc$adjEasting[which(mam.loc$plotID == "ONAQ_003")], 
         mam.loc$adjNorthing[which(mam.loc$plotID == "ONAQ_003")], 
         pch=".", xlab="Easting", ylab="Northing")
    
    points(mam.loc$adjEasting[which(mam.loc$plotID == "ONAQ_003" & 
                                   mam.loc$trapStatus == "5 - capture")], 
         mam.loc$adjNorthing[which(mam.loc$plotID =="ONAQ_003" &
                                  mam.loc$trapStatus == "5 - capture")],
         pch=19, col="blue")

![Same plot as above with 100 equally spaced dots but 22 dots are now blue](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/plot-captures-1.png)

In the month of data we're viewing small mammals were caught at 22 of the 100 
trap locations in this plot.

The basic techniques for working with this data can be adapted to other TOS 
location data for other data products.  

## Locations for sensor data

Downloads of instrument system (IS) data include a file called 
**sensor_positions.csv**. The sensor positions file contains information 
about the coordinates of each sensor, relative to a reference location. 

While the specifics vary, techniques are generalizable for working with sensor 
data and the sensor_positions.csv file. For this tutorial, let's look at the 
sensor locations for soil temperature (PAR; DP1.00041.001) at  
the NEON Treehaven site (TREE) in July 2018. To reduce our file size, we'll use 
the 30 minute averaging interval. Our final product from this section is to 
create a depth profile of soil temperature in one soil plot.

If downloading data using the `neonUtilties` package is new to you, check out the 
<a href="https://www.neonscience.org/neonDataStackR" target="_blank">neonUtilities tutorial</a>.

This function will download about 7 MB of data as written so we have `check.size =F` 
for ease of running the code. 


    # load soil temperature data of interest 
    soilT <- loadByProduct(dpID="DP1.00041.001", site="TREE",
                        startdate="2018-07", enddate="2018-07",
                        avg=30, check.size=F)

### Sensor positions file 
Now we can specifically look at the sensor positions file.


    # create object for sensor positions file
    pos <- soilT$sensor_positions_00041
    
    # view names
    names(pos)

    ##  [1] "siteID"               "HOR.VER"              "name"                 "description"         
    ##  [5] "start"                "end"                  "referenceName"        "referenceDescription"
    ##  [9] "referenceStart"       "referenceEnd"         "xOffset"              "yOffset"             
    ## [13] "zOffset"              "pitch"                "roll"                 "azimuth"             
    ## [17] "referenceLatitude"    "referenceLongitude"   "referenceElevation"   "publicationDate"

    # view table
    View(pos)

The sensor locations are indexed by the `HOR.VER` variable - see the 
<a href="https://data.neonscience.org/file-naming-conventions" target="_blank">file naming conventions</a> 
page for more details. 

Using `unique()` we can view all the location indexes in this file. 


    # view names
    unique(pos$HOR.VER)

    ##  [1] "001.501" "001.502" "001.503" "001.504" "001.505" "001.506" "001.507" "001.508" "001.509" "002.501"
    ## [11] "002.502" "002.503" "002.504" "002.505" "002.506" "002.507" "002.508" "002.509" "003.501" "003.502"
    ## [21] "003.503" "003.504" "003.505" "003.506" "003.507" "003.508" "003.509" "004.501" "004.502" "004.503"
    ## [31] "004.504" "004.505" "004.506" "004.507" "004.508" "004.509" "005.501" "005.502" "005.503" "005.504"
    ## [41] "005.505" "005.506" "005.507" "005.508" "005.509"

Soil temperature data are collected in 5 instrumented soil plots inside the 
tower footprint. We see this reflected in the data where HOR = 001 to 005. 
Within each plot, temperature is measured at 9 depths, seen in VER = 501 to 
509. At some sites, the number of depths may differ slightly.

The x, y, and z offsets in the sensor positions file are the relative distance, 
in meters, to the reference latitude, longitude, and elevation in the file. 

The HOR and VER indices in the sensor positions file correspond to the 
`verticalPosition` and `horizontalPosition` fields in `soilT$ST_30_minute`.

Note that there are two sets of position data for soil plot 001, and that 
one set has an `end` date in the file. This indicates sensors either 
moved or were relocated; in this case there was a frost heave incident. 
You can read about it in the issue log, both in the readme file and on 
the <a href="https://data.neonscience.org/data-products/DP1.00041.001" target="_blank">Data Product Details</a> page.

Since we're working with data from July 2018, and the change in 
sensor locations is dated Nov 2018, we'll use the original locations.


    pos <- pos[-intersect(grep("001.", pos$HOR.VER),
                          which(pos$end=="")),]

Our goal is to plot a time series of temperature, stratified by 
depth, so let's start by joining the data file and sensor positions 
file, to bring the depth measurements into the same data frame with 
the data.


    # paste horizontalPosition and verticalPosition together
    # to match HOR.VER
    soilT$ST_30_minute$HOR.VER <- paste(soilT$ST_30_minute$horizontalPosition,
                                        soilT$ST_30_minute$verticalPosition,
                                        sep=".")
    
    # left join to keep all temperature records
    soilTHV <- merge(soilT$ST_30_minute, pos, 
                     by="HOR.VER", all.x=T)

And now we can plot soil temperature over time for each depth. 
We'll use `ggplot` since it's well suited to this kind of 
stratification. Each soil plot is its own panel:


    gg <- ggplot(soilTHV, 
                 aes(endDateTime, soilTempMean, 
                     group=zOffset, color=zOffset)) +
                 geom_line() + 
            facet_wrap(~horizontalPosition)
    gg

    ## Warning: Removed 1488 row(s) containing missing values (geom_path).

![---UPDATE---HERE---](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/soilT-plot-1.png)

We can see that as soil depth increases, temperatures 
become much more stable, while the shallowest measurement 
has a clear diurnal cycle. We can also see that 
something has gone wrong with one of the sensors in plot 
002. To remove those data, use only values where the final 
quality flag passed, i.e. `finalQF` = 0


    gg <- ggplot(subset(soilTHV, finalQF==0), 
                 aes(endDateTime, soilTempMean, 
                     group=zOffset, color=zOffset)) +
                 geom_line() + 
            facet_wrap(~horizontalPosition)
    gg

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/soilT-plot-noQF-1.png)
