## ----install, eval=F------------------------------------------------------------------------------------
## 
## # run once to get the package, and re-run if you need to get updates
## install.packages("sp")  # work with spatial data
## install.packages("rgdal")  # work with spatial data
## install.packages("maptools")  # work with spatial objects
## install.packages("broom")  # tidy up data
## install.packages("ggplot2")  # plotting
## install.packages("neonUtilities")  # work with NEON data
## install.packages("devtools")  # to use the install_github() function
## devtools::install_github("NEONScience/NEON-geolocation/geoNEON")  # work with NEON spatial data
## 


## ----libraries, results="hide"--------------------------------------------------------------------------

# run every time you start a script
library(sp)
library(rgdal)
library(maptools)
library(broom)
library(ggplot2)
library(neonUtilities)
library(geoNEON)

options(stringsAsFactors=F)

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. 

wd <- "~/Documents/data/" # This will depend on your local environment
setwd(wd)



## ----load-domains, results="hide"-----------------------------------------------------------------------

# upload data
neonDomains <- readOGR(paste0(wd,"NEONDomains_0"), layer="NEON_Domains")



## ----create-df, warning=FALSE---------------------------------------------------------------------------

# first, add a new column termed "id" composed of the row names of the data
neonDomains@data$id <- rownames(neonDomains@data)

# now, use tidy() to convert to a dataframe
# if you previously used fortify(), this does the same thing 
neonDomains_points <- tidy(neonDomains, region="id")

# finally, merge the new data with the data from our spatial object
neonDomainsDF <- merge(neonDomains_points, neonDomains@data, by = "id")



## ----explore-domains------------------------------------------------------------------------------------

# view data structure for each variable
str(neonDomainsDF)



## ----plot-domains, fig.width=8, fig.height=6, fig.cap="Map of the United States with each NEON domain outlined"----

# plot domains
domainMap <- ggplot(neonDomainsDF, aes(x=long, y=lat)) + 
        geom_map(map = neonDomainsDF,
                aes(map_id = id),
                 fill="white", color="black", size=0.3)

domainMap



## ----load-explore-sites---------------------------------------------------------------------------------

# read in the data
neonSites <- read.delim(paste0(wd,"field-sites.csv"), sep=",", header=T)

# view data structure for each variable
str(neonSites)



## ----plot-sites, fig.width=8, fig.height=6, fig.cap="Same map as above but with dots for the field site locations across the country"----

# plot the sites
neonMap <- domainMap + 
        geom_point(data=neonSites, 
                   aes(x=Longitude, y=Latitude))

neonMap 



## ----sites-color, fig.width=8, fig.height=6, fig.cap="Same as maps above but the field site dots are now four different colors"----

# color is determined by the order that the unique values show up
# check order
unique(neonSites$Site.Type)

# add color
sitesMap <- neonMap + 
        geom_point(data=neonSites, 
                      aes(x=Longitude, y=Latitude, color=Site.Type)) + 
           scale_color_manual(values=c("lightskyblue", "forest green", 
                                       "blue4", "light green"),
                              name="",
                              breaks=unique(neonSites$Site.Type))
sitesMap



## ----TOS-readme-----------------------------------------------------------------------------------------

# load TOS plot readme
rdme <- read.delim(paste0(wd,'All_NEON_TOS_Plots_V8/readme.csv'),
                   sep=',', header=T)

# view the variables
rdme[,1]



## ----get-mam-data, results="hide"-----------------------------------------------------------------------

# load mammal data
mam <- loadByProduct(dpID="DP1.10072.001", site="ONAQ",
                     startdate="2018-08", enddate="2018-08",
                     check.size=F)



## ----find-sp-data---------------------------------------------------------------------------------------

View(mam$variables_10072)



## ----print-mam------------------------------------------------------------------------------------------

head(mam$mam_pertrapnight[,1:18])



## ----print-ONAQ020--------------------------------------------------------------------------------------

# view all trap locations in one plot
mam$mam_pertrapnight[which(mam$mam_pertrapnight$plotID=="ONAQ_020"),
                     c("trapCoordinate","decimalLatitude",
                       "decimalLongitude")]



## ----mam-getLocTOS, results="hide"----------------------------------------------------------------------

# download small mam locationso
mam.loc <- getLocTOS(data=mam$mam_pertrapnight,
                           dataProd="mam_pertrapnight")



## ----mam-diff-------------------------------------------------------------------------------------------

# print variable names that are new
names(mam.loc)[which(!names(mam.loc) %in% names(mam$mam_pertrapnight))]



## ----mam-grids, fig.cap="Six square points on a plot each made up of smaller dots that form either a complete square point or a partially filled in square point"----

# plot all trap locations at site
plot(mam.loc$adjEasting, mam.loc$adjNorthing, pch=".",
     xlab="Easting", ylab="Northing")



## ----plot-ONAQ003, fig.width=6, fig.height=6, fig.cap="dots on a plot equally spaced in 10 rows and 10 columns"----

# plot all trap locations in one grid (plot)
plot(mam.loc$adjEasting[which(mam.loc$plotID=="ONAQ_003")], 
     mam.loc$adjNorthing[which(mam.loc$plotID=="ONAQ_003")], 
     pch=".", xlab="Easting", ylab="Northing", cex=3)



## ----plot-captures, fig.width=6, fig.height=6, fig.cap="Same plot as above with 100 equally spaced dots but 22 dots are now blue"----

# plot all captures 
plot(mam.loc$adjEasting[which(mam.loc$plotID == "ONAQ_003")], 
     mam.loc$adjNorthing[which(mam.loc$plotID == "ONAQ_003")], 
     pch=".", xlab="Easting", ylab="Northing")

points(mam.loc$adjEasting[which(mam.loc$plotID == "ONAQ_003" & 
                               mam.loc$trapStatus == "5 - capture")], 
     mam.loc$adjNorthing[which(mam.loc$plotID =="ONAQ_003" &
                              mam.loc$trapStatus == "5 - capture")],
     pch=19, col="blue")



## ----soilT-load, results="hide"-------------------------------------------------------------------------
# load soil temperature data of interest 
soilT <- loadByProduct(dpID="DP1.00041.001", site="TREE",
                    startdate="2018-07", enddate="2018-07",
                    avg=30, check.size=F)



## ----sens-pos-------------------------------------------------------------------------------------------

# create object for sensor positions file
pos <- soilT$sensor_positions_00041

# view names
names(pos)

# view table
View(pos)



## ----pos-levs-------------------------------------------------------------------------------------------

# view names
unique(pos$HOR.VER)



## ----pos-rem--------------------------------------------------------------------------------------------
pos <- pos[-intersect(grep("001.", pos$HOR.VER),
                      which(pos$end=="")),]


## ----pos-join-------------------------------------------------------------------------------------------
# paste horizontalPosition and verticalPosition together
# to match HOR.VER
soilT$ST_30_minute$HOR.VER <- paste(soilT$ST_30_minute$horizontalPosition,
                                    soilT$ST_30_minute$verticalPosition,
                                    sep=".")

# left join to keep all temperature records
soilTHV <- merge(soilT$ST_30_minute, pos, 
                 by="HOR.VER", all.x=T)


## ----soilT-plot, fig.cap="---UPDATE---HERE---"----------------------------------------------------------

gg <- ggplot(soilTHV, 
             aes(endDateTime, soilTempMean, 
                 group=zOffset, color=zOffset)) +
             geom_line() + 
        facet_wrap(~horizontalPosition)
gg



## ----soilT-plot-noQF------------------------------------------------------------------------------------
gg <- ggplot(subset(soilTHV, finalQF==0), 
             aes(endDateTime, soilTempMean, 
                 group=zOffset, color=zOffset)) +
             geom_line() + 
        facet_wrap(~horizontalPosition)
gg

