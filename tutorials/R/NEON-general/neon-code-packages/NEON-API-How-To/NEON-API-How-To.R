## ----os-avail-query------------------------------------------------------------------------------------

# Load the necessary libraries
library(httr)
library(jsonlite)

# Request data using the GET function & the API call
req <- GET("http://data.neonscience.org/api/v0/products/DP1.10098.001")
req



## ----os-query-contents---------------------------------------------------------------------------------

# Make the data readable by jsonlite
req.text <- content(req, as="text")

# Flatten json into a nested list
avail <- jsonlite::fromJSON(req.text, 
                            simplifyDataFrame=T, 
                            flatten=T)



## ----os-query-contents-examples------------------------------------------------------------------------

# View description of data product
avail$data$productDescription

# View data product abstract
avail$data$productAbstract



## ----os-query-fromJSON---------------------------------------------------------------------------------

# Look at the first list element for siteCode
avail$data$siteCodes$siteCode[[1]]

# And at the first list element for availableMonths
avail$data$siteCodes$availableMonths[[1]]



## ----os-query-avail-data-------------------------------------------------------------------------------

# Get complete list of available data URLs
wood.urls <- unlist(avail$data$siteCodes$availableDataUrls)

# Total number of URLs
length(wood.urls)

# Show first 10 URLs available
wood.urls[1:10] 



## ----os-query-woody-data-urls--------------------------------------------------------------------------

# Get available data for RMNP Oct 2019
woody <- GET(wood.urls[grep("RMNP/2019-10", wood.urls)])
woody.files <- jsonlite::fromJSON(content(woody, as="text"))

# See what files are available for this site and month
woody.files$data$files$name



## ----os-get-mapandtag-data-----------------------------------------------------------------------------

vst.maptag <- read.csv(woody.files$data$files$url
                       [grep("mappingandtagging",
                             woody.files$data$files$name)])



## ----os-plot-woody-data--------------------------------------------------------------------------------

# Get counts by species 
countBySp <- table(vst.maptag$taxonID)

# Reorder so list is ordered most to least abundance
countBySp <- countBySp[order(countBySp, decreasing=T)]

# Plot abundances
barplot(countBySp, names.arg=names(countBySp), 
        ylab="Total", las=2)



## ----get-loons-----------------------------------------------------------------------------------------

loon.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?family=Gaviidae")



## ----parse-loons---------------------------------------------------------------------------------------

loon.list <- jsonlite::fromJSON(content(loon.req, as="text"))



## ----display-loons-------------------------------------------------------------------------------------

loon.list$data



## ----get-mammals---------------------------------------------------------------------------------------

mam.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?taxonTypeCode=SMALL_MAMMAL&verbose=true")
mam.list <- jsonlite::fromJSON(content(mam.req, as="text"))
mam.list$data[1:10,]



## ----get-aspen-----------------------------------------------------------------------------------------

aspen.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?scientificname=Populus%20tremuloides%20Michx.")
aspen.list <- jsonlite::fromJSON(content(aspen.req, as="text"))
aspen.list$data



## ----get-woody-NLs-------------------------------------------------------------------------------------

head(vst.maptag$namedLocation)



## ----woody-ex-NL---------------------------------------------------------------------------------------

req.loc <- GET("http://data.neonscience.org/api/v0/locations/RMNP_043.basePlot.vst")
vst.RMNP_043 <- jsonlite::fromJSON(content(req.loc, as="text"))
vst.RMNP_043



## ----woody-child-NL------------------------------------------------------------------------------------

req.child.loc <- GET(grep("31", 
                          vst.RMNP_043$data$locationChildrenUrls,
                          value=T))
vst.RMNP_043.31 <- jsonlite::fromJSON(content(req.child.loc, as="text"))
vst.RMNP_043.31


