## ----os-avail-query------------------------------------------------------

library(httr)
library(jsonlite)
library(dplyr, quietly=T)
req <- GET("http://data.neonscience.org/api/v0/products/DP1.10003.001")


## ----os-query-contents---------------------------------------------------

req
req.content <- content(req, as="parsed")
req.content


## ----os-query-fromJSON---------------------------------------------------

req.text <- content(req, as="text")
avail <- fromJSON(req.text, simplifyDataFrame=T, flatten=T)
avail


## ----os-query-avail-data-------------------------------------------------

bird.urls <- unlist(avail$data$siteCodes$availableDataUrls)
bird.urls


## ----os-query-bird-data-urls---------------------------------------------

brd <- GET(bird.urls[grep("WOOD", bird.urls)])
brd.files <- fromJSON(content(brd, as="text"))
brd.files$data$files


## ----os-get-bird-data----------------------------------------------------

brd.count <- read.delim(brd.files$data$files$url
                        [intersect(grep("countdata", brd.files$data$files$name),
                                    grep("basic", brd.files$data$files$name))], sep=",")

brd.point <- read.delim(brd.files$data$files$url
                        [intersect(grep("perpoint", brd.files$data$files$name),
                                    grep("basic", brd.files$data$files$name))], sep=",")


## ----os-plot-bird-data---------------------------------------------------

clusterBySp <- brd.count %>% group_by(scientificName) %>% 
  summarize(total=sum(clusterSize))
clusterBySp <- clusterBySp[order(clusterBySp$total, decreasing=T),]
barplot(clusterBySp$total, names.arg=clusterBySp$scientificName, 
        ylab="Total", cex.names=0.5, las=2)


## ----soil-data-----------------------------------------------------------

req.soil <- GET("http://data.neonscience.org/api/v0/products/DP1.00041.001")
avail.soil <- fromJSON(content(req.soil, as="text"), simplifyDataFrame=T, flatten=T)
temp.urls <- unlist(avail.soil$data$siteCodes$availableDataUrls)
tmp <- GET(temp.urls[grep("MOAB/2017-03", temp.urls)])
tmp.files <- fromJSON(content(tmp, as="text"))
tmp.files$data$files$name


## ----os-get-soil-data----------------------------------------------------

soil.temp <- read.delim(tmp.files$data$files$url
                        [intersect(grep("002.504.030", tmp.files$data$files$name),
                                   grep("basic", tmp.files$data$files$name))], sep=",")


## ----os-plot-soil-data---------------------------------------------------

plot(soil.temp$soilTempMean~soil.temp$startDateTime, pch=".", xlab="Date", ylab="T")


## ----get-bird-NLs--------------------------------------------------------

head(brd.point$namedLocation)


## ----brd-ex-NL-----------------------------------------------------------

req.loc <- GET("http://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd")
brd.WOOD_013 <- fromJSON(content(req.loc, as="text"))
brd.WOOD_013


## ----brd-extr-NL---------------------------------------------------------

library(geoNEON)
brd.point.loc <- def.extr.geo.os(brd.point)

symbols(brd.point.loc$api.easting, brd.point.loc$api.northing, 
        circles=brd.point.loc$coordinateUncertainty, 
        xlab="Easting", ylab="Northing", tck=0.01, inches=F)


## ----brd-calc-NL---------------------------------------------------------

brd.point.pt <- def.calc.geo.os(brd.point, "brd_perpoint")

symbols(brd.point.pt$api.easting, brd.point.pt$api.northing, 
        circles=brd.point.pt$adjCoordinateUncertainty, 
        xlab="Easting", ylab="Northing", tck=0.01, inches=F)


