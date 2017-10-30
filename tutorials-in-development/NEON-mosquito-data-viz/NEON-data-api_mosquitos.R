rm(list = ls()) # Clean up workspace
library(httr)
library(XML)
library(jsonlite)

options(stringsAsFactors = F)

# Step 1: What dates and sites are available for my product?

# Step 2: Knowing what is available, get all the data
getDataInfo <- function(query, as = "parsed"){
  url = paste("http://data.neonscience.org/api/v0", "products", query, sep = "/")
  req = GET(url = url) #, add_headers(Accept = "application/json"))
  con = content(req, as = as)
  site = lapply(con$data$siteCodes, as.data.frame)
  dat = data.frame()
  for (i in 1:length(site)){
    len = length(unlist(site[[i]]))
    int = data.frame(unlist(site[[i]])[1:len - 1])
    colnames(int) = "date"
    int$siteID = site[[i]]$siteCode
    
    dat <- rbind(dat, int)
  }
  row.names(dat) = 1:nrow(dat)
  dat$product <- query
  
  return(dat)
}

getNEONData <- function(product, site, date, as = "text"){
  # type = "products" | "sites" | "locations" | "data"
  url = paste("http://data.neonscience.org/api/v0/data", product, site, date, sep = "/")
  req = GET(url = url) #, add_headers(Accept = "application/json"))
  con = content(req, as = as)
  return(con)
}

# Use Mosquito diversity data (DP1.10043.001) as example
dat = getDataInfo(query = "DP1.10043.001")
# Mosquito diversity data have 3 output tables 
# Field sampling records, identification data,
# and archive info
sampData = idData = arcData = data.frame()
for (i in 1:nrow(dat)){
  print(dat[i, ])
  # Get the data links
  err <- try(result <- getNEONData(product = dat$product[i], site = dat$siteID[i],
                                   date = dat$date[i], as = "parsed")  
  )
  # If successful grab data via url download
  if (class(err)!="try-error"){
    # Get the urls for download
    urls = unlist(result$data$urls)
    # By type
    samp = urls[grepl("sampling", urls)]
    id = urls[grepl("identification", urls)]
    arc = urls[grepl("archiv", urls)]
    
    sampData = rbind(sampData,
                     read.csv(url(samp)))
    idData = rbind(idData,
                   read.csv(url(id)))
    arcData = rbind(arcData,
                    read.csv(url(arc)))
  } 
}

# Get pathogen data 
dat = getDataInfo(query = "DP1.10041.001")
pathData = data.frame()
for (i in 1:nrow(dat)){
  print(dat[i, ])
  # Get the data links
  err <- try(result <- getNEONData(product = dat$product[i], site = dat$siteID[i],
                                   date = dat$date[i], as = "parsed")  
  )
  # If successful grab data via url download
  if (class(err)!="try-error"){
    # Get the urls for download
    urls = unlist(result$data$urls)
    pathData = rbind(pathData,
                     read.csv(url(urls)))
  } 
}
