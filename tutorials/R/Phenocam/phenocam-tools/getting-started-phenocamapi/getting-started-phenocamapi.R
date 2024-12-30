## ----setup, include = FALSE----------------------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)


## ----libraries, warning=FALSE--------------------------------------------------------------------

library(data.table) #installs package that creates a data frame for visualizing data in row-column table format
library(phenocamapi)  #installs packages of time series and phenocam data from the Phenology Network. Loads required packages rjson, bitops and RCurl
library(lubridate)  #install time series data package
library(jpeg)


## ----obtain-data, fig.height=5, fig.width=8, message=FALSE---------------------------------------

#Obtain phenocam metadata from the Phenology Network in form of a data.table
phenos <- get_phenos()

#Explore metadata table
head(phenos$site) #preview first six rows of the table. These are the first six phenocam sites in the Phenology Network

colnames(phenos)  #view all column names. 
#This is all the metadata we have for the phenocams in the Phenology Network


## ----plot-MAT-MAP, message=FALSE, fig.height=8, fig.width=8--------------------------------------
# #Some sites do not have data on Mean Annual Precipitation (MAP) and Mean Annual Temperature (MAT).

# removing the sites with unknown MAT and MAP values
phenos <- phenos[!((MAT_worldclim == -9999)|(MAP_worldclim == -9999))]

# Making a plot showing all sites by their vegetation type (represented as different symbols and colors) plotting across climate (MAT and MAP) space. Refer to table to identify vegetation type acronyms.
phenos[primary_veg_type=='DB', plot(MAT_worldclim, MAP_worldclim, pch = 19, col = 'green', xlim = c(-5, 27), ylim = c(0, 4000))]
phenos[primary_veg_type=='DN', points(MAT_worldclim, MAP_worldclim, pch = 1, col = 'darkgreen')]
phenos[primary_veg_type=='EN', points(MAT_worldclim, MAP_worldclim, pch = 17, col = 'brown')]
phenos[primary_veg_type=='EB', points(MAT_worldclim, MAP_worldclim, pch = 25, col = 'orange')]
phenos[primary_veg_type=='AG', points(MAT_worldclim, MAP_worldclim, pch = 12, col = 'yellow')]
phenos[primary_veg_type=='SH', points(MAT_worldclim, MAP_worldclim, pch = 23, col = 'red')]

legend('topleft', legend = c('DB','DN', 'EN','EB','AG', 'SH'), 
       pch = c(19, 1, 17, 25, 12, 23), 
       col =  c('green', 'darkgreen', 'brown',  'orange',  'yellow',  'red' ))



## ----filter-flux, fig.height=5, fig.width=6.5, message=FALSE-------------------------------------
# Create a data table only including the sites that have flux_data available and where the FLUX site name is specified
phenofluxsites <- phenos[flux_data==TRUE&!is.na(flux_sitenames)&flux_sitenames!='', 
                         .(PhenoCam=site, Flux=flux_sitenames)] # return as table

#Specify to retain variables of Phenocam site and their flux tower name
phenofluxsites <- phenofluxsites[Flux!='']

# view the first few rows of the data table
head(phenofluxsites)



## ----filter-flux-db, fig.height=5, fig.width=6.5, message=FALSE----------------------------------

#list deciduous broadleaf sites with a flux tower
DB.flux <- phenos[flux_data==TRUE&primary_veg_type=='DB', 
                  site]  # return just the site names as a list

# see the first few rows
head(DB.flux)


## ----get-rois, fig.height=5, fig.width=6.5, message=FALSE----------------------------------------
# Obtaining the list of all the available regions of interest (ROI's) on the PhenoCam server and producing a data table
rois <- get_rois()

# view the data variables in the data table
colnames(rois)

# view first few regions of of interest (ROI) locations
head(rois$roi_name)



## ----fig.height=5, fig.width=6.5, message=FALSE--------------------------------------------------
# list ROIs for dukehw
rois[site=='dukehw',]

# Obtain the decidous broadleaf, ROI ID 1000 data from the dukehw phenocam
dukehw_DB_1000 <- get_pheno_ts(site = 'dukehw', vegType = 'DB', roiID = 1000, type = '3day')

# Produces a list of the dukehw data variables
str(dukehw_DB_1000)



## ----plot-gcc90, fig.height=5, fig.width=8-------------------------------------------------------
# Convert date variable into date format
dukehw_DB_1000[,date:=as.Date(date)]

# plot gcc_90
dukehw_DB_1000[,plot(date, gcc_90, col = 'green', type = 'b')]
mtext('Duke Forest, Hardwood', font = 2)



## ----midday-list, fig.height=5, fig.width=8, message=FALSE---------------------------------------

# obtaining midday_images for dukehw
duke_middays <- get_midday_list('dukehw')

# see the first few rows
head(duke_middays)



## ----midday-download, fig.height=5, fig.width=8--------------------------------------------------
# download a file
destfile <- tempfile(fileext = '.jpg')

# download only the first available file
# modify the `[1]` to download other images
download.file(duke_middays[1], destfile = destfile, mode = 'wb')

# plot the image
img <- try(readJPEG(destfile))
if(class(img)!='try-error'){
  par(mar= c(0,0,0,0))
  plot(0:1,0:1, type='n', axes= FALSE, xlab= '', ylab = '')
  rasterImage(img, 0, 0, 1, 1)
}


## ----midday-time-range, fig.height=6, fig.width=8, message=FALSE, warning=FALSE, eval=TRUE, results="hide"----

# open a temporary directory
tmp_dir <- tempdir()

# download a subset. Example dukehw 2017
download_midday_images(site = 'dukehw', # which site
                       y = 2017, # which year(s)
                       months = 1:12, # which month(s)
                       days = 15, # which days on month(s)
                       download_dir = tmp_dir) # where on your computer

# list of downloaded files
duke_middays_path <- dir(tmp_dir, pattern = 'dukehw*', full.names = TRUE)

head(duke_middays_path)



## ----plot-monthly-forest, fig.height=6, fig.width=8, message=FALSE, eval=TRUE--------------------
n <- length(duke_middays_path)
par(mar= c(0,0,0,0), mfrow=c(4,3), oma=c(0,0,3,0))

for(i in 1:n){
  img <- readJPEG(duke_middays_path[i])
  plot(0:1,0:1, type='n', axes= FALSE, xlab= '', ylab = '')
  rasterImage(img, 0, 0, 1, 1)
  mtext(month.name[i], line = -2)
}
mtext('Seasonal variation of forest at Duke Hardwood Forest', font = 2, outer = TRUE)


