## ----metadata-challenge-1, echo=FALSE------------------------------------
# Metadata Notes from hf001_10-15-m_Metadata.txt
#  1. 2001-2015
#  2. Emery Boos - located at the top of the document, email is available
#  3. a lat long is available in the metadata at the top, we see the location described
# as Prospect Hill Tract (Harvard Forest). 
# 4. 342 m elevation, the veg type is not clear in the metadata
# 5. Found in the methods: Delayed melting of snow and ice (caused by problems with rain gage heater or heavy precipitation) is noted in log - daily values are corrected if necessary but 15-minute values are not. The gage may underestimate actual precipitation under windy or cold conditions.
# 6. this could be a discussion. things like units, time zone, etc are all useful
# if accessed programmatically


## ----metadata-challenge-2, echo=FALSE------------------------------------
# Metadata Notes from hf001_10-15-m_Metadata.txt
# 1. airt, s10t, prec, parr

# 2. units for quantitative variables: Celsius (both temps), millimeters,
# molePerMeterSquared

# 3. airt & s10t: average of 1-second measurements. (unit: celsius / missing
# value: NA)
# prec: Total value for 15-minute period. Measured in increments of 0.01 inch.
# (unit: millimeter / missing value: NA)
# parr: Average of 1-second measurements. (unit:
# micromolePerMeterSquaredPerSecond / missing value: NA)

# 4. datetime field, Eastern Standard Time. - note this is found in the methods
# towards the top of the document.

## ----install-EML-package, results="hide", warning=FALSE------------------
# install R EML tool 
# load devtools
library("devtools")
# IF YOU HAVE NOT DONE SO ALREADY: install EML from github -- package in
# development; not on CRAN
#install_github("ropensci/EML", build=FALSE, dependencies=c("DEPENDS", "IMPORTS"))

# load ROpenSci EML package
library("EML")
# load ggmap for mapping
library(ggmap)


## ----read-eml------------------------------------------------------------
# data location
# http://harvardforest.fas.harvard.edu:8080/exist/apps/datasets/showData.html?id=hf001
# table 4 http://harvardforest.fas.harvard.edu/data/p00/hf001/hf001-04-monthly-m.csv

# import EML from Harvard Forest Met Data
# note, for this particular tutorial, we will work with an abridged version of the file
# that you can access directly on the harvard forest website. (see comment below)
eml_HARV <- read_eml("http://harvardforest.fas.harvard.edu/data/eml/hf001.xml")

# import a truncated version of the eml file for quicker demonstration
# eml_HARV <- read_eml("http://neon-workwithdata.github.io/NEON-R-Tabular-Time-Series/hf001-revised.xml")

# view size of object
object.size(eml_HARV)

# view the object class
class(eml_HARV)


## ----view-eml-content----------------------------------------------------
# view the contact name listed in the file

eml_HARV@dataset@creator

# view information about the methods used to collect the data as described in EML
eml_HARV@dataset@methods



## ----map-location, warning=FALSE, message=FALSE--------------------------

# grab x coordinate from the coverage information
XCoord <- eml_HARV@dataset@coverage@geographicCoverage[[1]]@boundingCoordinates@westBoundingCoordinate@.Data

# grab y coordinate from the coverage information
YCoord <- eml_HARV@dataset@coverage@geographicCoverage[[1]]@boundingCoordinates@northBoundingCoordinate@.Data

# map <- get_map(location='Harvard', maptype = "terrain")

# plot the NW corner of the site.
map <- get_map(location='massachusetts', maptype = "toner", zoom =8)

ggmap(map, extent=TRUE) +
  geom_point(aes(x=as.numeric(XCoord),y=as.numeric(YCoord)), 
             color="darkred", size=6, pch=18)


