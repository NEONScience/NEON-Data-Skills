## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----libraries, include = FALSE, echo=FALSE------------------------------
library(data.table)
library(phenocamapi)
library(lubridate)
library(jpeg)

## ---- fig.height=5, fig.width=6.5, message=FALSE-------------------------

# obtaining the phenocam site metadata from the server as data.table
phenos <- get_phenos()

# checking out the first few sites
head(phenos$site)

# checking out the columns
colnames(phenos)

# removing the sites with unkown MAT and MAP values
phenos <- phenos[!((MAT_worldclim == -9999)|(MAP_worldclim == -9999))]

# extracting the PhenoCam climate space based on the WorldClim dataset
# and plotting the sites across the climate space different vegetation type as different symbols and colors
phenos[primary_veg_type=='DB', plot(MAT_worldclim, MAP_worldclim, pch = 19, col = 'green', xlim = c(-5, 27), ylim = c(0, 4000))]
phenos[primary_veg_type=='DN', points(MAT_worldclim, MAP_worldclim, pch = 1, col = 'darkgreen')]
phenos[primary_veg_type=='EN', points(MAT_worldclim, MAP_worldclim, pch = 17, col = 'brown')]
phenos[primary_veg_type=='EB', points(MAT_worldclim, MAP_worldclim, pch = 25, col = 'orange')]
phenos[primary_veg_type=='AG', points(MAT_worldclim, MAP_worldclim, pch = 12, col = 'yellow')]
phenos[primary_veg_type=='SH', points(MAT_worldclim, MAP_worldclim, pch = 23, col = 'red')]
legend('topleft', legend = c('DB','DN', 'EN','EB','AG', 'SH'), 
       pch = c(19, 1, 17, 25, 12, 23), 
       col =  c('green', 'darkgreen', 'brown',  'orange',  'yellow',  'red' ))


## ---- fig.height=5, fig.width=6.5, message=FALSE-------------------------
# store sites with flux_data available
phenofluxsites <- phenos[flux_data==TRUE&!is.na(flux_sitenames), .(PhenoCam=site, Flux=flux_sitenames)]

# see the first few rows
head(phenofluxsites)

#list deciduous broadleaf sites with flux tower
DB.flux <- phenos[flux_data==TRUE&primary_veg_type=='DB', site]

# see the first few rows
head(DB.flux)

## ---- fig.height=5, fig.width=6.5, message=FALSE-------------------------
# obtaining the list of all the available ROI's on the PhenoCam server
rois <- get_rois()

head(rois$roi_name)

colnames(rois)

# list all the ROI's for dukehw
rois[site=='dukehw',]

## ---- fig.height=5, fig.width=6.5, message=FALSE-------------------------
# to obtain the DB 1000  from dukehw
dukehw_DB_1000 <- get_pheno_ts(site = 'dukehw', vegType = 'DB', roiID = 1000, type = '3day')

colnames(dukehw_DB_1000)

dukehw_DB_1000[,date:=as.Date(date)]
dukehw_DB_1000[,plot(date, gcc_90, col = 'green', type = 'b')]
mtext('Duke Forest, Hardwood', font = 2)

## ---- fig.height=5, fig.width=6.5, message=FALSE-------------------------
# obtaining midday_images for dukehw
duke_middays <- get_midday_list('dukehw', direct = FALSE)

# see the first few rows
head(duke_middays)

# download a file
destfile <- tempfile(fileext = '.jpg')
download.file(duke_middays[1], destfile = destfile)

img <- try(readJPEG(destfile))
if(class(img)!='try-error'){
  par(mar= c(0,0,0,0))
  plot(0:1,0:1, type='n', axes= FALSE, xlab= '', ylab = '')
  rasterImage(img, 0, 0, 1, 1)
}

## ---- fig.height=5, fig.width=6.5, message=FALSE, eval=FALSE-------------
## 
## # download a subset
## download_dir <- download_midday_images(site = 'dukehw', y = 2018, months = 4, download_dir = tempdir())
## 
## # list of downloaded files
## duke_middays_path <- dir(download_dir, pattern = 'dukehw*', full.names = TRUE)
## 
## head(duke_middays_path)
## 

