---
syncID: b152963c4883463883c3b6f0de95fd93
title: "Access and Work with NEON Geolocation Data"
description: "Use files available on the data portal, the NEON API, and the neonUtilities R package to access the locations of NEON sampling events and infrastructure. Calculate more precise locations for certain sampling types, and reference ground sampling to airborne data."
dateCreated: 2019-09-13
authors: [Claire K. Lunch]
contributors: Donal O'Leary
estimatedTime: 40 minutes
packagesLibraries: neonUtilities
topics: data-management, rep-sci
languageTool: R
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/NEON-general/neon-code-packages/spatialData/spatialData.R
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
    
    # the next two commands convert the shapefile to a format ggplot 
    # can use
    neon.domains <- SpatialPolygonsDataFrame(gSimplify(neon.domains, tol=0.1, 
                                                     topologyPreserve=TRUE), 
                                   data=neon.domains@data)
    map <- broom::tidy(neon.domains)

The `broom::tidy()` function might give you some warnings about factor levels, 
but it shouldn't prevent you from continuing on to the next steps.

Let's plot the domains without the sites first:


    gg <- ggplot() + theme_map()
    gg <- gg + geom_map(data=map, map=map,
                        aes(x=long, y=lat, map_id=id, group=group),
                        fill="white", color="black", size=0.3)
    gg

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/plot-domains-1.png)

Now read in the field sites file, and add points to the map for 
each site:


    # modify "~/data" to the filepath where you downloaded the file
    sites <- read.delim("~/data/field-sites.csv", sep=",", header=T)
    
    gg <- gg + geom_point(data=sites, aes(x=Longitude, y=Latitude))
    gg

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/plot-sites-1.png)

And let's color code sites, plotting terrestrial sites in green and 
aquatic sites in blue:


    gg <- gg + geom_point(data=sites, 
                          aes(x=Longitude, y=Latitude, color=Site.Type)) + 
               scale_color_manual(values=c("blue4", "springgreen4", 
                                           "blue", "olivedrab"),
                                  name="",
                                  breaks=unique(sites$Site.Type))
    gg

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/sites-color-1.png)


### Terrestrial observation plots

The locations of observational sampling plots at terrestrial sites (TOS)
are available in the <a href="http://data.neonscience.org/documents" target="_blank">document library</a> 
on the Data Portal, in the Spatial Data folder, as static files, 
in both tabular and shapefile formats. Your download will be a zip file 
containing tabular files of plot centroids and point locations, and 
shapefiles of plot centroids, point locations, and polygons.

The readme file contains descriptions for each of the columns in the 
tabular files.



You can use these files to navigate the spatial layout of sampling for 
TOS: mosquitoes, beetles, plants, birds, etc. In this tutorial, we'll be 
using the location data provided along with data downloads, as well as 
methods in the `geoNEON` package, to explore TOS spatial data, instead of 
these files.

## Spatial data in data downloads

### Observational data

Both aquatic and terrestrial observational data downloads include spatial 
data in the downloaded files. Let's take a look at the small mammal data. 
Download small mammal data from Yellowstone National Park (YELL), August 2018 to investigate. 
If downloading data using the `neonUtilties` package is new to you, check 
out the <a href="https://www.neonscience.org/neonDataStackR" target="_blank">neonUtilities tutorial</a>.


    mam <- loadByProduct(dpID="DP1.10072.001", site="YELL",
                         startdate="2018-08", enddate="2018-08",
                         check.size=F)

The spatial data are in the `pertrapnight` table.


    head(mam$mam_pertrapnight[,1:18])

    ##                                    uid                             nightuid
    ## 1 96a598bd-6435-40d8-b802-b933375d1706 918a2e3b-9e41-47dd-99c6-db9ab11fe50b
    ## 2 2e27b36b-d77a-497c-b00d-3ecdbbaf7aad b9982a39-dd87-4fa4-b709-6f9bc4f1c9e3
    ## 3 fcb4ff54-95b7-4992-8491-c6a9ac3201cd 248239a9-ddc3-4321-9c46-29c766870740
    ## 4 7a86e44e-d28f-4d8f-97cb-0c1125bab439 248239a9-ddc3-4321-9c46-29c766870740
    ## 5 9bdf9ed9-0fca-474b-b633-cdf5ad3427f8 248239a9-ddc3-4321-9c46-29c766870740
    ## 6 14effb23-649b-409d-8cc6-ec6066d9c932 918a2e3b-9e41-47dd-99c6-db9ab11fe50b
    ##             namedLocation domainID siteID   plotID trapCoordinate    plotType       nlcdClass
    ## 1 YELL_001.mammalGrid.mam      D12   YELL YELL_001             I3 distributed      shrubScrub
    ## 2 YELL_031.mammalGrid.mam      D12   YELL YELL_031             B2 distributed      shrubScrub
    ## 3 YELL_023.mammalGrid.mam      D12   YELL YELL_023             B9 distributed evergreenForest
    ## 4 YELL_023.mammalGrid.mam      D12   YELL YELL_023             C5 distributed evergreenForest
    ## 5 YELL_023.mammalGrid.mam      D12   YELL YELL_023             F8 distributed evergreenForest
    ## 6 YELL_001.mammalGrid.mam      D12   YELL YELL_001             J3 distributed      shrubScrub
    ##   decimalLatitude decimalLongitude geodeticDatum coordinateUncertainty elevation
    ## 1       44.918169      -110.408714         WGS84                  45.1    1904.1
    ## 2       44.956470      -110.510295         WGS84                  45.2    2136.2
    ## 3       44.938201      -110.630976         WGS84                  45.1    2062.4
    ## 4       44.938201      -110.630976         WGS84                  45.1    2062.4
    ## 5       44.938201      -110.630976         WGS84                  45.1    2062.4
    ## 6       44.918169      -110.408714         WGS84                  45.1    1904.1
    ##   elevationUncertainty             trapStatus  trapType collectDate
    ## 1                  0.1 6 - trap set and empty ShermanLF  2018-08-05
    ## 2                  0.3 6 - trap set and empty ShermanLF  2018-08-05
    ## 3                  0.1 6 - trap set and empty ShermanLF  2018-08-05
    ## 4                  0.1 6 - trap set and empty ShermanLF  2018-08-05
    ## 5                  0.1 6 - trap set and empty ShermanLF  2018-08-05
    ## 6                  0.1 6 - trap set and empty ShermanLF  2018-08-05

But there's a limitation here - the latitudes and longitudes provided 
are for the plots, not for the traps. Take a look at the coordinates 
for all traps within a single plot to see this:


    mam$mam_pertrapnight[which(mam$mam_pertrapnight$plotID=="YELL_031"),
                         c("trapCoordinate","decimalLatitude",
                           "decimalLongitude")]

    ##     trapCoordinate decimalLatitude decimalLongitude
    ## 2               B2        44.95647      -110.510295
    ## 10              J8        44.95647      -110.510295
    ## 12              J5        44.95647      -110.510295
    ## 13              B6        44.95647      -110.510295
    ## 20              C7        44.95647      -110.510295
    ## 22              G7        44.95647      -110.510295
    ## 27              I1        44.95647      -110.510295
    ## 30             A10        44.95647      -110.510295
    ## 34              E5        44.95647      -110.510295
    ## 37              B9        44.95647      -110.510295
    ## 40              J2        44.95647      -110.510295
    ## 49              I9        44.95647      -110.510295
    ## 53             H10        44.95647      -110.510295
    ## 54              H7        44.95647      -110.510295
    ## 60              D3        44.95647      -110.510295
    ## 63              H4        44.95647      -110.510295
    ## 64              C6        44.95647      -110.510295
    ## 66              I2        44.95647      -110.510295
    ## 67              B7        44.95647      -110.510295
    ## 70              F9        44.95647      -110.510295
    ## 71              J4        44.95647      -110.510295
    ## 75              C2        44.95647      -110.510295
    ## 77             D10        44.95647      -110.510295
    ## 79              I7        44.95647      -110.510295
    ## 85              J6        44.95647      -110.510295
    ## 87              B4        44.95647      -110.510295
    ## 89              I5        44.95647      -110.510295
    ## 92              A2        44.95647      -110.510295
    ## 94              E3        44.95647      -110.510295
    ## 97              B3        44.95647      -110.510295
    ## 98              C5        44.95647      -110.510295
    ## 101             F7        44.95647      -110.510295
    ## 102             H6        44.95647      -110.510295
    ## 103             D8        44.95647      -110.510295
    ## 105             E9        44.95647      -110.510295
    ## 106             J1        44.95647      -110.510295
    ## 115             H3        44.95647      -110.510295
    ## 116             F3        44.95647      -110.510295
    ## 117             G1        44.95647      -110.510295
    ## 118             A7        44.95647      -110.510295
    ## 120             I3        44.95647      -110.510295
    ## 125             G3        44.95647      -110.510295
    ## 126             E2        44.95647      -110.510295
    ## 129             G5        44.95647      -110.510295
    ## 132             I6        44.95647      -110.510295
    ## 139             D5        44.95647      -110.510295
    ## 141             C9        44.95647      -110.510295
    ## 144             B5        44.95647      -110.510295
    ## 145             F5        44.95647      -110.510295
    ## 148            F10        44.95647      -110.510295
    ## 150             A8        44.95647      -110.510295
    ## 151             C8        44.95647      -110.510295
    ## 152             J7        44.95647      -110.510295
    ## 156            E10        44.95647      -110.510295
    ## 158             F6        44.95647      -110.510295
    ## 159             G6        44.95647      -110.510295
    ## 161             A9        44.95647      -110.510295
    ## 163             I4        44.95647      -110.510295
    ## 164             C1        44.95647      -110.510295
    ## 172             H5        44.95647      -110.510295
    ## 173            C10        44.95647      -110.510295
    ## 180             H2        44.95647      -110.510295
    ## 186             I8        44.95647      -110.510295
    ## 189             G2        44.95647      -110.510295
    ## 195            G10        44.95647      -110.510295
    ## 200             H9        44.95647      -110.510295
    ## 201             E4        44.95647      -110.510295
    ## 203             G9        44.95647      -110.510295
    ## 204             D4        44.95647      -110.510295
    ## 205             E1        44.95647      -110.510295
    ## 211             D1        44.95647      -110.510295
    ## 217             D7        44.95647      -110.510295
    ## 221            B10        44.95647      -110.510295
    ## 222             D2        44.95647      -110.510295
    ## 224             A1        44.95647      -110.510295
    ## 230             H1        44.95647      -110.510295
    ## 231             E7        44.95647      -110.510295
    ## 235             C4        44.95647      -110.510295
    ## 237             J9        44.95647      -110.510295
    ## 241             B1        44.95647      -110.510295
    ## 244             J3        44.95647      -110.510295
    ## 247             E6        44.95647      -110.510295
    ## 249             C3        44.95647      -110.510295
    ## 254             F8        44.95647      -110.510295
    ## 256             G8        44.95647      -110.510295
    ## 261             B8        44.95647      -110.510295
    ## 268             F2        44.95647      -110.510295
    ## 269             A4        44.95647      -110.510295
    ## 271             F4        44.95647      -110.510295
    ## 273             H8        44.95647      -110.510295
    ## 274             D6        44.95647      -110.510295
    ## 277             A5        44.95647      -110.510295
    ## 279            J10        44.95647      -110.510295
    ## 281             A6        44.95647      -110.510295
    ## 282             D9        44.95647      -110.510295
    ## 287             E8        44.95647      -110.510295
    ## 288             G4        44.95647      -110.510295
    ## 290             A3        44.95647      -110.510295
    ## 294            I10        44.95647      -110.510295
    ## 300             F1        44.95647      -110.510295
    ## 305             C2        44.95647      -110.510295
    ## 306            D10        44.95647      -110.510295
    ## 311             A3        44.95647      -110.510295
    ## 316             D5        44.95647      -110.510295
    ## 317             E6        44.95647      -110.510295
    ## 318             G3        44.95647      -110.510295
    ## 326             A5        44.95647      -110.510295
    ## 327             H5        44.95647      -110.510295
    ## 329             I6        44.95647      -110.510295
    ## 333             I1        44.95647      -110.510295
    ## 337             F6        44.95647      -110.510295
    ## 338             J6        44.95647      -110.510295
    ## 340            H10        44.95647      -110.510295
    ## 341             I4        44.95647      -110.510295
    ## 345             A9        44.95647      -110.510295
    ## 347            E10        44.95647      -110.510295
    ## 348             G4        44.95647      -110.510295
    ## 349             J7        44.95647      -110.510295
    ## 352             A4        44.95647      -110.510295
    ## 358             D4        44.95647      -110.510295
    ## 359             C7        44.95647      -110.510295
    ## 363            G10        44.95647      -110.510295
    ## 364             I7        44.95647      -110.510295
    ## 367             A2        44.95647      -110.510295
    ## 369            G10        44.95647      -110.510295
    ## 370            J10        44.95647      -110.510295
    ## 371             F8        44.95647      -110.510295
    ## 375             F4        44.95647      -110.510295
    ## 377             B4        44.95647      -110.510295
    ## 378             C8        44.95647      -110.510295
    ## 379             E7        44.95647      -110.510295
    ## 382             B8        44.95647      -110.510295
    ## 383             H9        44.95647      -110.510295
    ## 385            B10        44.95647      -110.510295
    ## 386             J9        44.95647      -110.510295
    ## 388             I9        44.95647      -110.510295
    ## 389             G6        44.95647      -110.510295
    ## 390             A8        44.95647      -110.510295
    ## 391             H3        44.95647      -110.510295
    ## 392             A6        44.95647      -110.510295
    ## 394             J4        44.95647      -110.510295
    ## 402            C10        44.95647      -110.510295
    ## 404             I5        44.95647      -110.510295
    ## 408             F7        44.95647      -110.510295
    ## 413             A1        44.95647      -110.510295
    ## 416             E3        44.95647      -110.510295
    ## 417             D8        44.95647      -110.510295
    ## 422             D9        44.95647      -110.510295
    ## 423             D2        44.95647      -110.510295
    ## 424             F9        44.95647      -110.510295
    ## 426             F2        44.95647      -110.510295
    ## 429             D7        44.95647      -110.510295
    ## 430             I3        44.95647      -110.510295
    ## 431             J1        44.95647      -110.510295
    ## 438             E1        44.95647      -110.510295
    ## 439             B9        44.95647      -110.510295
    ## 443             D3        44.95647      -110.510295
    ## 444             J8        44.95647      -110.510295
    ## 446             H4        44.95647      -110.510295
    ## 447             D1        44.95647      -110.510295
    ## 449             J3        44.95647      -110.510295
    ## 450             H6        44.95647      -110.510295
    ## 451            F10        44.95647      -110.510295
    ## 452             B7        44.95647      -110.510295
    ## 463             F5        44.95647      -110.510295
    ## 464             E9        44.95647      -110.510295
    ## 465             C4        44.95647      -110.510295
    ## 475             H7        44.95647      -110.510295
    ## 477            A10        44.95647      -110.510295
    ## 481             H2        44.95647      -110.510295
    ## 493             E5        44.95647      -110.510295
    ## 501             F1        44.95647      -110.510295
    ## 507             E8        44.95647      -110.510295
    ## 508             E4        44.95647      -110.510295
    ## 510             F3        44.95647      -110.510295
    ## 513             B6        44.95647      -110.510295
    ## 514             G9        44.95647      -110.510295
    ## 515             D6        44.95647      -110.510295
    ## 517             C6        44.95647      -110.510295
    ## 522             B3        44.95647      -110.510295
    ## 525            I10        44.95647      -110.510295
    ## 526             G2        44.95647      -110.510295
    ## 536             I8        44.95647      -110.510295
    ## 538             C1        44.95647      -110.510295
    ## 540             B5        44.95647      -110.510295
    ## 541             H1        44.95647      -110.510295
    ## 543             J2        44.95647      -110.510295
    ## 554             G5        44.95647      -110.510295
    ## 556             H8        44.95647      -110.510295
    ## 565             G1        44.95647      -110.510295
    ## 571             G7        44.95647      -110.510295
    ## 572             G8        44.95647      -110.510295
    ## 577             C5        44.95647      -110.510295
    ## 578             A7        44.95647      -110.510295
    ## 581             J5        44.95647      -110.510295
    ## 582             I2        44.95647      -110.510295
    ## 585             B1        44.95647      -110.510295
    ## 589             B2        44.95647      -110.510295
    ## 595             C9        44.95647      -110.510295
    ## 596             E2        44.95647      -110.510295
    ## 600             C3        44.95647      -110.510295
    ## 603             D9        44.95647      -110.510295
    ## 605             H4        44.95647      -110.510295
    ## 606             C7        44.95647      -110.510295
    ## 612            A10        44.95647      -110.510295
    ## 616             A2        44.95647      -110.510295
    ## 618             B5        44.95647      -110.510295
    ## 619             H2        44.95647      -110.510295
    ## 622             J5        44.95647      -110.510295
    ## 624             A6        44.95647      -110.510295
    ## 631             I3        44.95647      -110.510295
    ## 633             C8        44.95647      -110.510295
    ## 635             A1        44.95647      -110.510295
    ## 636             C4        44.95647      -110.510295
    ## 637             G8        44.95647      -110.510295
    ## 638             J1        44.95647      -110.510295
    ## 639             J7        44.95647      -110.510295
    ## 640             E4        44.95647      -110.510295
    ## 644             E9        44.95647      -110.510295
    ## 647            J10        44.95647      -110.510295
    ## 648            H10        44.95647      -110.510295
    ## 649            E10        44.95647      -110.510295
    ## 650             B6        44.95647      -110.510295
    ## 652            G10        44.95647      -110.510295
    ## 654            C10        44.95647      -110.510295
    ## 661            D10        44.95647      -110.510295
    ## 662             I7        44.95647      -110.510295
    ## 663            F10        44.95647      -110.510295
    ## 666             G4        44.95647      -110.510295
    ## 668             D1        44.95647      -110.510295
    ## 671             J6        44.95647      -110.510295
    ## 683             H9        44.95647      -110.510295
    ## 685             A7        44.95647      -110.510295
    ## 686             J3        44.95647      -110.510295
    ## 688             F5        44.95647      -110.510295
    ## 697             A3        44.95647      -110.510295
    ## 701             H6        44.95647      -110.510295
    ## 702             B3        44.95647      -110.510295
    ## 706             I8        44.95647      -110.510295
    ## 710             B9        44.95647      -110.510295
    ## 714             F1        44.95647      -110.510295
    ## 715             B7        44.95647      -110.510295
    ## 719             H8        44.95647      -110.510295
    ## 721             I5        44.95647      -110.510295
    ## 724             I4        44.95647      -110.510295
    ## 728             C9        44.95647      -110.510295
    ## 734             A4        44.95647      -110.510295
    ## 735             I9        44.95647      -110.510295
    ## 737             C6        44.95647      -110.510295
    ## 738             C3        44.95647      -110.510295
    ## 740             F8        44.95647      -110.510295
    ## 742             C5        44.95647      -110.510295
    ## 746             D7        44.95647      -110.510295
    ## 751             E2        44.95647      -110.510295
    ## 755             I6        44.95647      -110.510295
    ## 757             E5        44.95647      -110.510295
    ## 761             E8        44.95647      -110.510295
    ## 764             H1        44.95647      -110.510295
    ## 765             E3        44.95647      -110.510295
    ## 766             B1        44.95647      -110.510295
    ## 771             G5        44.95647      -110.510295
    ## 773             E7        44.95647      -110.510295
    ## 780             J9        44.95647      -110.510295
    ## 781            I10        44.95647      -110.510295
    ## 783             G3        44.95647      -110.510295
    ## 786             G9        44.95647      -110.510295
    ## 789             D3        44.95647      -110.510295
    ## 790             B4        44.95647      -110.510295
    ## 792             D5        44.95647      -110.510295
    ## 797             J2        44.95647      -110.510295
    ## 799             C2        44.95647      -110.510295
    ## 803             F6        44.95647      -110.510295
    ## 807             A9        44.95647      -110.510295
    ## 809             A5        44.95647      -110.510295
    ## 810             F3        44.95647      -110.510295
    ## 815             D8        44.95647      -110.510295
    ## 817             E1        44.95647      -110.510295
    ## 818             E6        44.95647      -110.510295
    ## 821             G1        44.95647      -110.510295
    ## 822             D4        44.95647      -110.510295
    ## 827            B10        44.95647      -110.510295
    ## 830             D6        44.95647      -110.510295
    ## 833             B2        44.95647      -110.510295
    ## 842             G7        44.95647      -110.510295
    ## 847             I2        44.95647      -110.510295
    ## 855             C1        44.95647      -110.510295
    ## 857             H7        44.95647      -110.510295
    ## 860             H3        44.95647      -110.510295
    ## 865             A8        44.95647      -110.510295
    ## 870             F7        44.95647      -110.510295
    ## 871             H5        44.95647      -110.510295
    ## 872             F9        44.95647      -110.510295
    ## 875             B8        44.95647      -110.510295
    ## 877             J8        44.95647      -110.510295
    ## 878             F2        44.95647      -110.510295
    ## 880             D2        44.95647      -110.510295
    ## 884             G2        44.95647      -110.510295
    ## 885             I1        44.95647      -110.510295
    ## 891             J4        44.95647      -110.510295
    ## 894             G6        44.95647      -110.510295
    ## 900             F4        44.95647      -110.510295

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

    ## [1] "points"                   "utmZone"                  "northing"                
    ## [4] "easting"                  "adjCoordinateUncertainty" "adjDecimalLatitude"      
    ## [7] "adjDecimalLongitude"      "adjElevation"             "adjElevationUncertainty"

Now we have adjusted latitude, longitude, and elevation, and the 
corresponding easting and northing. We can use the easting and northing to 
plot the locations of the mammal traps:


    plot(mam.loc$easting, mam.loc$northing, pch=".",
         xlab="Easting", ylab="Northing")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/mam-grids-1.png)

Each grid has 100 points, so even with each trap plotted as a . we can only 
see a square for each grid. Let's zoom in on a single plot:


    plot(mam.loc$easting[which(mam.loc$plotID=="YELL_031")], 
         mam.loc$northing[which(mam.loc$plotID=="YELL_031")], 
         pch=".", xlab="Easting", ylab="Northing")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/plot-YELL_031-1.png)

Now let's add a layer of data to see which of these traps caught a mammal:


    plot(mam.loc$easting[which(mam.loc$plotID=="YELL_031")], 
         mam.loc$northing[which(mam.loc$plotID=="YELL_031")], 
         pch=".", xlab="Easting", ylab="Northing")
    
    points(mam.loc$easting[which(mam.loc$plotID=="YELL_031" & 
                                   mam.loc$trapStatus=="5 - capture")], 
         mam.loc$northing[which(mam.loc$plotID=="YELL_031" &
                                  mam.loc$trapStatus=="5 - capture")],
         pch=19, col="blue")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/plot-captures-1.png)

In the month of data we're viewing, in this plot, animals were caught at 
50 of the 100 traps.

### Sensor data

Downloads of instrument system (IS) data include a file called 
`sensor_positions.csv`. The sensor positions file contains information 
about the coordinates of each sensor, relative to a reference location. 
Let's look at the sensor locations for photosynthetically active 
radiation (PAR) at the Treehaven site (TREE).

The sensor positions file isn't kept by the methods in the `neonUtilities` 
package (we plan to add this in the future!), so go to the 
<a href="https://data.neonscience.org" target="_blank">Data Portal</a> 
and download the basic PAR (DP1.00024.001) data at TREE for July 2018. Unzip the 
monthly package, and read the sensor positions file into R:


    pos <- read.delim("~/data/NEON.D05.TREE.DP1.00024.001.2018-07.basic.20190314T150344Z/NEON.D05.TREE.DP1.00024.001.sensor_positions.20190314T150344Z.csv",
                      sep=",", header=T)
    names(pos)

    ##  [1] "HOR.VER"            "start"              "end"                "referenceStart"    
    ##  [5] "referenceEnd"       "xOffset"            "yOffset"            "zOffset"           
    ##  [9] "pitch"              "roll"               "azimuth"            "referenceLatitude" 
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

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/NEON-general/neon-code-packages/spatialData/rfigs/par-plot-1.png)







