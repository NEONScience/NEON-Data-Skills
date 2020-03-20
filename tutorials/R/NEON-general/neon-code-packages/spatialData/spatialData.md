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
    map <- fortify(neon.domains, region="DomainName")

    ## Error in maptools::unionSpatialPolygons(cp, attr[, region]): isTRUE(gpclibPermitStatus()) is not TRUE

Let's plot the domains without the sites first:


    gg <- ggplot() + theme_map()
    gg <- gg + geom_map(data=map, map=map,
                        aes(x=long, y=lat, map_id=id, group=group),
                        fill="white", color="black", size=0.3)

    ## Error in geom_map(data = map, map = map, aes(x = long, y = lat, map_id = id, : is.data.frame(map) is not TRUE

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
    ##             namedLocation domainID siteID   plotID trapCoordinate    plotType
    ## 1 YELL_001.mammalGrid.mam      D12   YELL YELL_001             I3 distributed
    ## 2 YELL_031.mammalGrid.mam      D12   YELL YELL_031             B2 distributed
    ## 3 YELL_023.mammalGrid.mam      D12   YELL YELL_023             B9 distributed
    ## 4 YELL_023.mammalGrid.mam      D12   YELL YELL_023             C5 distributed
    ## 5 YELL_023.mammalGrid.mam      D12   YELL YELL_023             F8 distributed
    ## 6 YELL_001.mammalGrid.mam      D12   YELL YELL_001             J3 distributed
    ##         nlcdClass decimalLatitude decimalLongitude geodeticDatum coordinateUncertainty
    ## 1      shrubScrub        44.91817        -110.4087         WGS84                  45.1
    ## 2      shrubScrub        44.95647        -110.5103         WGS84                  45.2
    ## 3 evergreenForest        44.93820        -110.6310         WGS84                  45.1
    ## 4 evergreenForest        44.93820        -110.6310         WGS84                  45.1
    ## 5 evergreenForest        44.93820        -110.6310         WGS84                  45.1
    ## 6      shrubScrub        44.91817        -110.4087         WGS84                  45.1
    ##   elevation elevationUncertainty             trapStatus  trapType collectDate
    ## 1    1904.1                  0.1 6 - trap set and empty ShermanLF  2018-08-05
    ## 2    2136.2                  0.3 6 - trap set and empty ShermanLF  2018-08-05
    ## 3    2062.4                  0.1 6 - trap set and empty ShermanLF  2018-08-05
    ## 4    2062.4                  0.1 6 - trap set and empty ShermanLF  2018-08-05
    ## 5    2062.4                  0.1 6 - trap set and empty ShermanLF  2018-08-05
    ## 6    1904.1                  0.1 6 - trap set and empty ShermanLF  2018-08-05

But there's a limitation here - the latitudes and longitudes provided 
are for the plots, not for the traps. Take a look at the coordinates 
for all traps within a single plot to see this:


    mam$mam_pertrapnight[which(mam$mam_pertrapnight$plotID=="YELL_031"),
                         c("trapCoordinate","decimalLatitude",
                           "decimalLongitude")]

    ##     trapCoordinate decimalLatitude decimalLongitude
    ## 2               B2        44.95647        -110.5103
    ## 10              J8        44.95647        -110.5103
    ## 12              J5        44.95647        -110.5103
    ## 13              B6        44.95647        -110.5103
    ## 20              C7        44.95647        -110.5103
    ## 22              G7        44.95647        -110.5103
    ## 27              I1        44.95647        -110.5103
    ## 30             A10        44.95647        -110.5103
    ## 34              E5        44.95647        -110.5103
    ## 37              B9        44.95647        -110.5103
    ## 40              J2        44.95647        -110.5103
    ## 49              I9        44.95647        -110.5103
    ## 53             H10        44.95647        -110.5103
    ## 54              H7        44.95647        -110.5103
    ## 60              D3        44.95647        -110.5103
    ## 63              H4        44.95647        -110.5103
    ## 64              C6        44.95647        -110.5103
    ## 66              I2        44.95647        -110.5103
    ## 67              B7        44.95647        -110.5103
    ## 70              F9        44.95647        -110.5103
    ## 71              J4        44.95647        -110.5103
    ## 75              C2        44.95647        -110.5103
    ## 77             D10        44.95647        -110.5103
    ## 79              I7        44.95647        -110.5103
    ## 85              J6        44.95647        -110.5103
    ## 87              B4        44.95647        -110.5103
    ## 89              I5        44.95647        -110.5103
    ## 92              A2        44.95647        -110.5103
    ## 94              E3        44.95647        -110.5103
    ## 97              B3        44.95647        -110.5103
    ## 98              C5        44.95647        -110.5103
    ## 101             F7        44.95647        -110.5103
    ## 102             H6        44.95647        -110.5103
    ## 103             D8        44.95647        -110.5103
    ## 105             E9        44.95647        -110.5103
    ## 106             J1        44.95647        -110.5103
    ## 115             H3        44.95647        -110.5103
    ## 116             F3        44.95647        -110.5103
    ## 117             G1        44.95647        -110.5103
    ## 118             A7        44.95647        -110.5103
    ## 120             I3        44.95647        -110.5103
    ## 125             G3        44.95647        -110.5103
    ## 126             E2        44.95647        -110.5103
    ## 129             G5        44.95647        -110.5103
    ## 132             I6        44.95647        -110.5103
    ## 139             D5        44.95647        -110.5103
    ## 141             C9        44.95647        -110.5103
    ## 144             B5        44.95647        -110.5103
    ## 145             F5        44.95647        -110.5103
    ## 148            F10        44.95647        -110.5103
    ## 150             A8        44.95647        -110.5103
    ## 151             C8        44.95647        -110.5103
    ## 152             J7        44.95647        -110.5103
    ## 156            E10        44.95647        -110.5103
    ## 158             F6        44.95647        -110.5103
    ## 159             G6        44.95647        -110.5103
    ## 161             A9        44.95647        -110.5103
    ## 163             I4        44.95647        -110.5103
    ## 164             C1        44.95647        -110.5103
    ## 172             H5        44.95647        -110.5103
    ## 173            C10        44.95647        -110.5103
    ## 180             H2        44.95647        -110.5103
    ## 186             I8        44.95647        -110.5103
    ## 189             G2        44.95647        -110.5103
    ## 195            G10        44.95647        -110.5103
    ## 200             H9        44.95647        -110.5103
    ## 201             E4        44.95647        -110.5103
    ## 203             G9        44.95647        -110.5103
    ## 204             D4        44.95647        -110.5103
    ## 205             E1        44.95647        -110.5103
    ## 211             D1        44.95647        -110.5103
    ## 217             D7        44.95647        -110.5103
    ## 221            B10        44.95647        -110.5103
    ## 222             D2        44.95647        -110.5103
    ## 224             A1        44.95647        -110.5103
    ## 230             H1        44.95647        -110.5103
    ## 231             E7        44.95647        -110.5103
    ## 235             C4        44.95647        -110.5103
    ## 237             J9        44.95647        -110.5103
    ## 241             B1        44.95647        -110.5103
    ## 244             J3        44.95647        -110.5103
    ## 247             E6        44.95647        -110.5103
    ## 249             C3        44.95647        -110.5103
    ## 254             F8        44.95647        -110.5103
    ## 256             G8        44.95647        -110.5103
    ## 261             B8        44.95647        -110.5103
    ## 268             F2        44.95647        -110.5103
    ## 269             A4        44.95647        -110.5103
    ## 271             F4        44.95647        -110.5103
    ## 273             H8        44.95647        -110.5103
    ## 274             D6        44.95647        -110.5103
    ## 277             A5        44.95647        -110.5103
    ## 279            J10        44.95647        -110.5103
    ## 281             A6        44.95647        -110.5103
    ## 282             D9        44.95647        -110.5103
    ## 287             E8        44.95647        -110.5103
    ## 288             G4        44.95647        -110.5103
    ## 290             A3        44.95647        -110.5103
    ## 294            I10        44.95647        -110.5103
    ## 300             F1        44.95647        -110.5103
    ## 305             C2        44.95647        -110.5103
    ## 306            D10        44.95647        -110.5103
    ## 311             A3        44.95647        -110.5103
    ## 316             D5        44.95647        -110.5103
    ## 317             E6        44.95647        -110.5103
    ## 318             G3        44.95647        -110.5103
    ## 326             A5        44.95647        -110.5103
    ## 327             H5        44.95647        -110.5103
    ## 329             I6        44.95647        -110.5103
    ## 333             I1        44.95647        -110.5103
    ## 337             F6        44.95647        -110.5103
    ## 338             J6        44.95647        -110.5103
    ## 340            H10        44.95647        -110.5103
    ## 341             I4        44.95647        -110.5103
    ## 345             A9        44.95647        -110.5103
    ## 347            E10        44.95647        -110.5103
    ## 348             G4        44.95647        -110.5103
    ## 349             J7        44.95647        -110.5103
    ## 352             A4        44.95647        -110.5103
    ## 358             D4        44.95647        -110.5103
    ## 359             C7        44.95647        -110.5103
    ## 363            G10        44.95647        -110.5103
    ## 364             I7        44.95647        -110.5103
    ## 367             A2        44.95647        -110.5103
    ## 369            G10        44.95647        -110.5103
    ## 370            J10        44.95647        -110.5103
    ## 371             F8        44.95647        -110.5103
    ## 375             F4        44.95647        -110.5103
    ## 377             B4        44.95647        -110.5103
    ## 378             C8        44.95647        -110.5103
    ## 379             E7        44.95647        -110.5103
    ## 382             B8        44.95647        -110.5103
    ## 383             H9        44.95647        -110.5103
    ## 385            B10        44.95647        -110.5103
    ## 386             J9        44.95647        -110.5103
    ## 388             I9        44.95647        -110.5103
    ## 389             G6        44.95647        -110.5103
    ## 390             A8        44.95647        -110.5103
    ## 391             H3        44.95647        -110.5103
    ## 392             A6        44.95647        -110.5103
    ## 394             J4        44.95647        -110.5103
    ## 402            C10        44.95647        -110.5103
    ## 404             I5        44.95647        -110.5103
    ## 408             F7        44.95647        -110.5103
    ## 413             A1        44.95647        -110.5103
    ## 416             E3        44.95647        -110.5103
    ## 417             D8        44.95647        -110.5103
    ## 422             D9        44.95647        -110.5103
    ## 423             D2        44.95647        -110.5103
    ## 424             F9        44.95647        -110.5103
    ## 426             F2        44.95647        -110.5103
    ## 429             D7        44.95647        -110.5103
    ## 430             I3        44.95647        -110.5103
    ## 431             J1        44.95647        -110.5103
    ## 438             E1        44.95647        -110.5103
    ## 439             B9        44.95647        -110.5103
    ## 443             D3        44.95647        -110.5103
    ## 444             J8        44.95647        -110.5103
    ## 446             H4        44.95647        -110.5103
    ## 447             D1        44.95647        -110.5103
    ## 449             J3        44.95647        -110.5103
    ## 450             H6        44.95647        -110.5103
    ## 451            F10        44.95647        -110.5103
    ## 452             B7        44.95647        -110.5103
    ## 463             F5        44.95647        -110.5103
    ## 464             E9        44.95647        -110.5103
    ## 465             C4        44.95647        -110.5103
    ## 475             H7        44.95647        -110.5103
    ## 477            A10        44.95647        -110.5103
    ## 481             H2        44.95647        -110.5103
    ## 493             E5        44.95647        -110.5103
    ## 501             F1        44.95647        -110.5103
    ## 507             E8        44.95647        -110.5103
    ## 508             E4        44.95647        -110.5103
    ## 510             F3        44.95647        -110.5103
    ## 513             B6        44.95647        -110.5103
    ## 514             G9        44.95647        -110.5103
    ## 515             D6        44.95647        -110.5103
    ## 517             C6        44.95647        -110.5103
    ## 522             B3        44.95647        -110.5103
    ## 525            I10        44.95647        -110.5103
    ## 526             G2        44.95647        -110.5103
    ## 536             I8        44.95647        -110.5103
    ## 538             C1        44.95647        -110.5103
    ## 540             B5        44.95647        -110.5103
    ## 541             H1        44.95647        -110.5103
    ## 543             J2        44.95647        -110.5103
    ## 554             G5        44.95647        -110.5103
    ## 556             H8        44.95647        -110.5103
    ## 565             G1        44.95647        -110.5103
    ## 571             G7        44.95647        -110.5103
    ## 572             G8        44.95647        -110.5103
    ## 577             C5        44.95647        -110.5103
    ## 578             A7        44.95647        -110.5103
    ## 581             J5        44.95647        -110.5103
    ## 582             I2        44.95647        -110.5103
    ## 585             B1        44.95647        -110.5103
    ## 589             B2        44.95647        -110.5103
    ## 595             C9        44.95647        -110.5103
    ## 596             E2        44.95647        -110.5103
    ## 600             C3        44.95647        -110.5103
    ## 603             D9        44.95647        -110.5103
    ## 605             H4        44.95647        -110.5103
    ## 606             C7        44.95647        -110.5103
    ## 612            A10        44.95647        -110.5103
    ## 616             A2        44.95647        -110.5103
    ## 618             B5        44.95647        -110.5103
    ## 619             H2        44.95647        -110.5103
    ## 622             J5        44.95647        -110.5103
    ## 624             A6        44.95647        -110.5103
    ## 631             I3        44.95647        -110.5103
    ## 633             C8        44.95647        -110.5103
    ## 635             A1        44.95647        -110.5103
    ## 636             C4        44.95647        -110.5103
    ## 637             G8        44.95647        -110.5103
    ## 638             J1        44.95647        -110.5103
    ## 639             J7        44.95647        -110.5103
    ## 640             E4        44.95647        -110.5103
    ## 644             E9        44.95647        -110.5103
    ## 647            J10        44.95647        -110.5103
    ## 648            H10        44.95647        -110.5103
    ## 649            E10        44.95647        -110.5103
    ## 650             B6        44.95647        -110.5103
    ## 652            G10        44.95647        -110.5103
    ## 654            C10        44.95647        -110.5103
    ## 661            D10        44.95647        -110.5103
    ## 662             I7        44.95647        -110.5103
    ## 663            F10        44.95647        -110.5103
    ## 666             G4        44.95647        -110.5103
    ## 668             D1        44.95647        -110.5103
    ## 671             J6        44.95647        -110.5103
    ## 683             H9        44.95647        -110.5103
    ## 685             A7        44.95647        -110.5103
    ## 686             J3        44.95647        -110.5103
    ## 688             F5        44.95647        -110.5103
    ## 697             A3        44.95647        -110.5103
    ## 701             H6        44.95647        -110.5103
    ## 702             B3        44.95647        -110.5103
    ## 706             I8        44.95647        -110.5103
    ## 710             B9        44.95647        -110.5103
    ## 714             F1        44.95647        -110.5103
    ## 715             B7        44.95647        -110.5103
    ## 719             H8        44.95647        -110.5103
    ## 721             I5        44.95647        -110.5103
    ## 724             I4        44.95647        -110.5103
    ## 728             C9        44.95647        -110.5103
    ## 734             A4        44.95647        -110.5103
    ## 735             I9        44.95647        -110.5103
    ## 737             C6        44.95647        -110.5103
    ## 738             C3        44.95647        -110.5103
    ## 740             F8        44.95647        -110.5103
    ## 742             C5        44.95647        -110.5103
    ## 746             D7        44.95647        -110.5103
    ## 751             E2        44.95647        -110.5103
    ## 755             I6        44.95647        -110.5103
    ## 757             E5        44.95647        -110.5103
    ## 761             E8        44.95647        -110.5103
    ## 764             H1        44.95647        -110.5103
    ## 765             E3        44.95647        -110.5103
    ## 766             B1        44.95647        -110.5103
    ## 771             G5        44.95647        -110.5103
    ## 773             E7        44.95647        -110.5103
    ## 780             J9        44.95647        -110.5103
    ## 781            I10        44.95647        -110.5103
    ## 783             G3        44.95647        -110.5103
    ## 786             G9        44.95647        -110.5103
    ## 789             D3        44.95647        -110.5103
    ## 790             B4        44.95647        -110.5103
    ## 792             D5        44.95647        -110.5103
    ## 797             J2        44.95647        -110.5103
    ## 799             C2        44.95647        -110.5103
    ## 803             F6        44.95647        -110.5103
    ## 807             A9        44.95647        -110.5103
    ## 809             A5        44.95647        -110.5103
    ## 810             F3        44.95647        -110.5103
    ## 815             D8        44.95647        -110.5103
    ## 817             E1        44.95647        -110.5103
    ## 818             E6        44.95647        -110.5103
    ## 821             G1        44.95647        -110.5103
    ## 822             D4        44.95647        -110.5103
    ## 827            B10        44.95647        -110.5103
    ## 830             D6        44.95647        -110.5103
    ## 833             B2        44.95647        -110.5103
    ## 842             G7        44.95647        -110.5103
    ## 847             I2        44.95647        -110.5103
    ## 855             C1        44.95647        -110.5103
    ## 857             H7        44.95647        -110.5103
    ## 860             H3        44.95647        -110.5103
    ## 865             A8        44.95647        -110.5103
    ## 870             F7        44.95647        -110.5103
    ## 871             H5        44.95647        -110.5103
    ## 872             F9        44.95647        -110.5103
    ## 875             B8        44.95647        -110.5103
    ## 877             J8        44.95647        -110.5103
    ## 878             F2        44.95647        -110.5103
    ## 880             D2        44.95647        -110.5103
    ## 884             G2        44.95647        -110.5103
    ## 885             I1        44.95647        -110.5103
    ## 891             J4        44.95647        -110.5103
    ## 894             G6        44.95647        -110.5103
    ## 900             F4        44.95647        -110.5103

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







