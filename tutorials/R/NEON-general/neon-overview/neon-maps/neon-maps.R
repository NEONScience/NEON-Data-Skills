## ----install, eval=FALSE---------------------------------------------------------------------------------
## 
## # run once to get the package, and re-run if you need to get updates
## install.packages("sp")  # work with spatial data
## install.packages("rgdal")  # work with spatial data
## 


## ----libraries, results="hide"---------------------------------------------------------------------------

# run every time you start a script
library(sp)
library(rgdal)

options(stringsAsFactors=F)

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. 

wd <- "~/data/" # This will depend on your local environment
setwd(wd)



## ----load-domains, results="hide"------------------------------------------------------------------------

# upload data
neonDomains <- readOGR(paste0(wd,"NEONDomains_0"), layer="NEON_Domains")



## ----plot-domains, fig.width=8, fig.height=6, fig.cap="Map of the United States with each NEON domain outlined"----

plot(neonDomains)



## ----mercator, fig.width=8, fig.height=6-----------------------------------------------------------------

neonMercator <- spTransform(neonDomains,
                            CRS("+proj=merc"))
plot(neonMercator)



## ----load-explore-sites----------------------------------------------------------------------------------

# read in the data
neonSites <- read.delim(paste0(wd,"field-sites.csv"), sep=",", header=T)

# view data structure for each variable
str(neonSites)



## ----plot-sites, fig.width=8, fig.height=6, fig.cap="NEON domain map with site dots added"---------------

plot(neonDomains)
points(neonSites$Latitude~neonSites$Longitude,
       pch=20)



## ----sites-color, fig.width=8, fig.height=6, fig.cap="NEON domain map with site dots color-coded for aquatic and terrestrial sites"----

# create empty variable
siteCol <- character(nrow(neonSites))

# populate new variable with colors, according to Site.Type
siteCol[grep("Aquatic", neonSites$Site.Type)] <- "blue"
siteCol[grep("Terrestrial", neonSites$Site.Type)] <- "green"

# add color to points on map
plot(neonDomains)
points(neonSites$Latitude~neonSites$Longitude,
       pch=20, col=siteCol)


