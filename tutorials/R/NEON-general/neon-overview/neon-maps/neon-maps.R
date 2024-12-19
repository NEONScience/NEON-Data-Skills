## ----install, eval=FALSE-------------------------------------------------------------------------
## 
## # run once to get the package, and re-run if you need to get updates
## install.packages("sf")  # work with spatial data
## 


## ----libraries, results="hide"-------------------------------------------------------------------

# run every time you start a script
library(sf)

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. 

wd <- "~/data/" # This will depend on your local environment
setwd(wd)



## ----load-domains, results="hide"----------------------------------------------------------------

# upload data
neonDomains <- read_sf(paste0(wd,"NEONDomains_2024"), layer="NEON_Domains")



## ----plot-domains, fig.width=8, fig.height=6, fig.cap="Map of the United States with each NEON domain outlined"----

plot(st_geometry(neonDomains))



## ----mercator, fig.width=8, fig.height=6---------------------------------------------------------

neonMercator <- st_transform(neonDomains,
                            crs="+proj=merc")
plot(st_geometry(neonMercator))



## ----load-explore-sites--------------------------------------------------------------------------

# read in the data
# make sure the file name matches the file you downloaded
# the date stamp is updated over time
neonSites <- read.delim(paste0(wd,"NEON_Field_Site_Metadata_20241219.csv"), 
                        sep=",", header=T)

# view data structure for each variable
str(neonSites)



## ----plot-sites, fig.width=8, fig.height=6, fig.cap="NEON domain map with site dots added"-------

plot(st_geometry(neonDomains))
points(neonSites$field_latitude~neonSites$field_longitude,
       pch=20)



## ----sites-color, fig.width=8, fig.height=6, fig.cap="NEON domain map with site dots color-coded for aquatic and terrestrial sites"----

# create empty variable
siteCol <- character(nrow(neonSites))

# populate new variable with colors, according to Site.Type
siteCol[grep("Aquatic", neonSites$field_site_type)] <- "blue"
siteCol[grep("Terrestrial", neonSites$field_site_type)] <- "green"

# add color to points on map
plot(st_geometry(neonDomains))
points(neonSites$field_latitude~neonSites$field_longitude,
       pch=20, col=siteCol)


