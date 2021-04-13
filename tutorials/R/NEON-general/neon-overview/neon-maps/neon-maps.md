---
syncID: 68da96c02c3b4f29944903daf2182c10
title: "NEON Domain and Site Shapefiles and Maps"
description: "Use files available on the NEON data portal and NEON API to create maps of NEON domains and sites."
dateCreated: 2021-04-06
authors: Claire K. Lunch
contributors: Megan Jones, Alison Dernbach, Donal O'Leary
estimatedTime: 20 minutes
packagesLibraries: sp, rgdal
topics: data-management, rep-sci
languageTool: R
dataProduct: 
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/neon-maps/neon-maps.R
tutorialSeries:
urlTitle: neon-maps

---

This tutorial explores NEON domain- and site-level spatial data, using 
shapefiles and tabular data provided by the NEON project. The intent of 
this tutorial is to provide guidance in navigating the data and files 
provided by NEON, and in creating maps of the domain and site locations. 
We hope these data and methods will assist users in generating images and 
figures for publications or presentations related to NEON.

<div id="ds-objectives" markdown="1">

## Learning Objectives 
After completing this tutorial you will be able to: 

* Access NEON spatial data from the NEON website
* Create a simple map with NEON domains and field site locations

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



    # run every time you start a script
    library(sp)
    library(rgdal)
    
    options(stringsAsFactors=F)
    
    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files. 
    
    wd <- "~/data/" # This will depend on your local environment
    setwd(wd)

## NEON spatial data files

NEON spatial data are available in a number of different files depending on which 
spatial data you are interested in. This section covers a variety of spatial 
data files that can be directly downloaded from the 
<a href="https://www.neonscience.org" target="_blank">NEONScience.org</a> website 
instead of being delivered with a downloaded data product.

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
<a href="https://www.neonscience.org/field-sites/explore-field-sites" target="_blank">Field Sites page</a> 
on the NEON website (linked above the image). In this summary of each field site, 
the geographic coordinates for each site correspond to the tower 
location for terrestrial sites and the center of the permitted reach 
for aquatic sites.

To continue, please download these files from the NEON website: 

* **NEON Domain Polygons:** A polygon shapefile defining NEON's domain 
boundaries. Like all NEON data the Coordinate Reference system is Geographic 
WGS 84. Available on the <a href="https://www.neonscience.org/data/spatial-data-maps" target="_blank">Spatial Data and Maps page</a>.
* **Field Site csv:** generic locations data for each NEON field site. Available on the <a href="https://www.neonscience.org/field-sites/explore-field-sites" target="_blank">Field Sites page</a>. 

The Field Site location data is also available as a shapefile and KMZ on the 
Spatial Data and Maps page. We use the file from the site list to demonstrate 
alternative ways to work with spatial data. 

## Map NEON domains 

Using the domain shapefile and the field sites list, let's make a map of NEON 
site locations.

We'll read in the spatial data using the `rgdal` and `sp` packages and plot it 
using base R. First, read in the domain shapefile. 

Be sure to move the downloaded and unzipped data files into the working directory 
you set earlier!


    # upload data
    neonDomains <- readOGR(paste0(wd,"NEONDomains_0"), layer="NEON_Domains")

The data come as a Large SpatialPolygonsDataFrame. Base R has methods 
for working with this data type, and will recognize it automatically 
with the generic `plot()` function. Let's first plot the domains without 
the sites.


    plot(neonDomains)

![Map of the United States with each NEON domain outlined](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/neon-maps/rfigs/plot-domains-1.png)

The data are currently in a Lat-Long projection. The map will look a little 
more familiar if we convert it to a Mercator projection. There are many, 
many map projections possible, and Mercator is distorted in very 
well-documented ways! Here, we'll use it as a demonstration, but you may 
want to use a different projection in your own work.

The `spTransform()` and `CRS()` functions in the `sp` package can be used 
to convert the projection:


    neonMercator <- spTransform(neonDomains,
                                CRS("+proj=merc"))
    plot(neonMercator)

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/neon-maps/rfigs/mercator-1.png)

## Map NEON field sites

Now that we have a map of all the NEON domains, let's plot the NEON field site 
locations on it. To do this, we need to load and explore the field sites data. 


    # read in the data
    neonSites <- read.delim(paste0(wd,"field-sites.csv"), sep=",", header=T)
    
    # view data structure for each variable
    str(neonSites)

    ## 'data.frame':	81 obs. of  26 variables:
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
    ##  $ Gallery                   : chr  "LIRO D05 Bathymetry Map, LIRO D05 Habitat Map" "WLOU-D13-Stream-Morpology-Map" "PUUM plot establishment, Field ecologists venture out to do field sampling at PUUM Hawaii" "FLNT D03 Bathymetry Map, FLNT D03 Habitat Map" ...
    ##  $ Thumbnail                 : chr  "" "" "" "" ...
    ##  $ Overview.Image            : chr  "" "" "" "" ...
    ##  $ Google.Maps.Embed.Code    : logi  NA NA NA NA NA NA ...
    ##  $ Related.Content           : logi  NA NA NA NA NA NA ...

Here there is a lot of associated data about the field sites that may be of 
interest, such as site descriptions and dominant vegetation types. For mapping 
purposes, we can see that there are both **Latitude** and **Longitude**
data, so we can plot this data onto our previous map. 


    plot(neonDomains)
    points(neonSites$Latitude~neonSites$Longitude,
           pch=20)

![NEON domain map with site dots added](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/neon-maps/rfigs/plot-sites-1.png)

Now we can see all the sites across the Observatory. Note that we've switched 
back to the Lat-Long projection, which makes it simple to plot the site 
locations onto the map using their latitude and longitude. To plot them on 
the Mercator projection, we would need to convert the site latitude and 
longitude values into a SpatialPoints object, and then perform the same 
conversion. See `sp` package documentation if you are interested in doing 
this.

NEON has both aquatic and terrestrial sites, with important differences 
between the two. Looking back at the variables in this data set, we can 
see that `Site.Type` designates the aquatic and terrestrial sites. 

Let's differentiate the site types by adding color to our plot, with 
terrestrial sites in green and aquatic sites in blue.


    # create empty variable
    siteCol <- character(nrow(neonSites))
    
    # populate new variable with colors, according to Site.Type
    siteCol[grep("Aquatic", neonSites$Site.Type)] <- "blue"
    siteCol[grep("Terrestrial", neonSites$Site.Type)] <- "green"
    
    # add color to points on map
    plot(neonDomains)
    points(neonSites$Latitude~neonSites$Longitude,
           pch=20, col=siteCol)

![NEON domain map with site dots color-coded for aquatic and terrestrial sites](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/NEON-general/neon-overview/neon-maps/rfigs/sites-color-1.png)

Now we can see where NEON sites are located within the domains. Note that 
a significant number of terrestrial and aquatic sites are co-located; in 
those cases both sites are plotted here, but one color may be 
superimposed over the other.

## Map locations at a specific site

Also available on the
<a href="https://www.neonscience.org/data-samples/data/spatial-data-maps" target="_blank"> Spatial Data and Maps page</a> are shapefiles containing location data at the 
within-site level.

If you are interested in maps of NEON sampling locations and regions, 
explore the downloads available for Terrestrial Observation Sampling 
Locations, Flight Boundaries, and Aquatic Sites Watersheds. These 
downloads contain shapefiles of these locations, and the terrestrial 
sampling file also contains spatial data in tabular form.

If you are interested in learning how to work with sampling location 
data that are provided along with downloads of NEON sensor and 
observational data, see the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/neon-spatial-data-basics" target="_blank">Geolocation Data</a> tutorial.

