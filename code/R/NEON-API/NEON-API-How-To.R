## ----os-avail-query------------------------------------------------------

# Load the necessary libaries
library(httr)
library(jsonlite)
library(dplyr, quietly=T)
library(downloader)

# Request data using the GET function & the API call
req <- GET("http://data.neonscience.org/api/v0/products/DP1.10003.001")
req

## ----os-query-contents---------------------------------------------------

# View requested data
req.content <- content(req, as="parsed")
req.content


## ----os-query-fromJSON---------------------------------------------------
# make this JSON readable -> "text"
req.text <- content(req, as="text")

# Flatten data frame to see available data. 
avail <- fromJSON(req.text, simplifyDataFrame=T, flatten=T)
avail


## ----os-query-avail-data-------------------------------------------------

# get data availability list for the product
bird.urls <- unlist(avail$data$siteCodes$availableDataUrls)
bird.urls


## ----os-query-bird-data-urls---------------------------------------------
# get data availability for WOOD July 2015
brd <- GET(bird.urls[grep("WOOD/2015-07", bird.urls)])
brd.files <- fromJSON(content(brd, as="text"))

# view just the available data files 
brd.files$data$files


## ----os-get-bird-data----------------------------------------------------

# Get both files
brd.count <- read.delim(brd.files$data$files$url
                        [intersect(grep("countdata", 
                                        brd.files$data$files$name),
                                    grep("basic", 
                                         brd.files$data$files$name))], 
                        sep=",")

brd.point <- read.delim(brd.files$data$files$url
                        [intersect(grep("perpoint", 
                                        brd.files$data$files$name),
                                    grep("basic", 
                                         brd.files$data$files$name))], 
                        sep=",")


## ----os-plot-bird-data---------------------------------------------------
# Cluster by species
clusterBySp <- brd.count %>% 
	group_by(scientificName) %>% 
  summarize(total=sum(clusterSize))

# Reorder so list is ordered most to least abundance
clusterBySp <- clusterBySp[order(clusterBySp$total, decreasing=T),]

# Plot
barplot(clusterBySp$total, names.arg=clusterBySp$scientificName, 
        ylab="Total", cex.names=0.5, las=2)


## ----soil-data-----------------------------------------------------------
# Request soil temperature data availability info
req.soil <- GET("http://data.neonscience.org/api/v0/products/DP1.00041.001")

# make this JSON readable
# Note how we've change this from two commands into one here
avail.soil <- fromJSON(content(req.soil, as="text"), simplifyDataFrame=T, flatten=T)

# get data availability list for the product
temp.urls <- unlist(avail.soil$data$siteCodes$availableDataUrls)

# get data availability from location/date of interest
tmp <- GET(temp.urls[grep("MOAB/2017-03", temp.urls)])
tmp.files <- fromJSON(content(tmp, as="text"))
tmp.files$data$files$name


## ----os-get-soil-data----------------------------------------------------

soil.temp <- read.delim(tmp.files$data$files$url
                        [intersect(grep("002.504.030", 
                                        tmp.files$data$files$name),
                                   grep("basic", 
                                        tmp.files$data$files$name))], 
                        sep=",")


## ----os-plot-soil-data---------------------------------------------------
# plot temp ~ date
plot(soil.temp$soilTempMean~as.POSIXct(soil.temp$startDateTime, 
                                       format="%Y-%m-%d T %H:%M:%S Z"), 
     pch=".", xlab="Date", ylab="T")


## ----aop-data------------------------------------------------------------
# Request camera data availability info
req.aop <- GET("http://data.neonscience.org/api/v0/products/DP1.30010.001")

# make this JSON readable
# Note how we've changed this from two commands into one here
avail.aop <- fromJSON(content(req.aop, as="text"), 
                      simplifyDataFrame=T, flatten=T)

# get data availability list for the product
cam.urls <- unlist(avail.aop$data$siteCodes$availableDataUrls)

# get data availability from location/date of interest
cam <- GET(cam.urls[intersect(grep("SJER", cam.urls),
                              grep("2017", cam.urls))])
cam.files <- fromJSON(content(cam, as="text"))

# this list of files is very long, so we'll just look at the first few
head(cam.files$data$files$name)


## ----download-aop-data, eval=FALSE---------------------------------------
## 
## download(cam.files$data$files$url[grep("20170328192931",
##                                        cam.files$data$files$name)],
##          paste(getwd(), "/SJER_image.tif", sep=""), mode="wb")
## 

## ----get-bird-NLs--------------------------------------------------------
# view named location
head(brd.point$namedLocation)


## ----brd-ex-NL-----------------------------------------------------------
# location data 
req.loc <- GET("http://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd")

# make this JSON readable
brd.WOOD_013 <- fromJSON(content(req.loc, as="text"))
brd.WOOD_013


## ----brd-extr-NL---------------------------------------------------------

# load the geoNEON package
library(geoNEON)

# extract the spatial data
brd.point.loc <- def.extr.geo.os(brd.point)

# plot bird point locations 
# note that decimal degrees is also an option in the data
symbols(brd.point.loc$api.easting, brd.point.loc$api.northing, 
        circles=brd.point.loc$api.coordinateUncertainty, 
        xlab="Easting", ylab="Northing", tck=0.01, inches=F)


## ----brd-calc-NL---------------------------------------------------------

brd.point.pt <- def.calc.geo.os(brd.point, "brd_perpoint")


# plot bird point locations 
# note that decimal degrees is also an option in the data
symbols(brd.point.pt$api.easting, brd.point.pt$api.northing, 
        circles=brd.point.pt$adjCoordinateUncertainty, 
        xlab="Easting", ylab="Northing", tck=0.01, inches=F)


## ----get-loons-----------------------------------------------------------
loon.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?family=Gaviidae&offset=0&limit=500")

## ----parse-loons---------------------------------------------------------
loon.list <- fromJSON(content(loon.req, as="text"))

## ----display-loons-------------------------------------------------------
loon.list$data

## ----get-mammals---------------------------------------------------------
mam.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?taxonTypeCode=SMALL_MAMMAL&offset=0&limit=500&verbose=true")
mam.list <- fromJSON(content(mam.req, as="text"))
mam.list$data[1:10,]

## ----get-verbena---------------------------------------------------------
am.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?scientificname=Abronia%20minor%20Standl.")
am.list <- fromJSON(content(am.req, as="text"))
am.list$data

