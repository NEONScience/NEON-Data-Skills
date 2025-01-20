## ----setup, include=FALSE-----------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
options(repos = c(CRAN = "https://cloud.r-project.org"))



## ----install-packages, message=FALSE, warning=FALSE,eval=FALSE----------------------------------
## 
## install.packages('tidyverse')
## install.packages('neonUtilities')
## install.packages('curl')
## install.packages('leaflet')
## install.packages('leaflet.minicharts')
## install.packages('lubridate')
## install.packages('ggplot2')
## 


## ----load-packages, message=FALSE, warning=FALSE,eval=TRUE--------------------------------------

library(tidyverse)
library(neonUtilities)
library(curl)
library(leaflet)
library(leaflet.minicharts)
library(lubridate)
library(ggplot2)



## ----download-Data-New, message=TRUE, warning=FALSE, paged.print=FALSE, results='hide'----------

 NEON.cfc <- loadByProduct(dpID="DP1.10026.001",
                    include.provisional=TRUE,
                    site=c('BLAN','BART','GRSM','HARV',
                           'MLBS','ORNL','SCBI','SERC'),
                    check.size=FALSE)
 
 NEON.ltr <- loadByProduct(dpID="DP1.10033.001",
                    site=c('BLAN','BART','GRSM','HARV',
                           'MLBS','ORNL','SCBI','SERC'),
                    check.size=FALSE)


## ----investigate-NEON-data, message=FALSE, eval=TRUE--------------------------------------------

# What's in a download?

names(NEON.cfc)
names(NEON.ltr)



## ----extract-CN-data, message=FALSE,eval=TRUE---------------------------------------------------

cfc <- NEON.cfc$cfc_carbonNitrogen
ltr <- NEON.ltr$ltr_litterCarbonNitrogen



## ----summarise-CN-data,message=FALSE,warning=FALSE,eval=TRUE------------------------------------

summary.cfc <- cfc %>% 
              mutate(year=year(collectDate)) %>% 
              group_by(siteID,year) %>% 
              summarise(n=length(uid),meanCN=mean(CNratio,na.rm=TRUE))

summary.cfc


summary.ltr <- ltr %>% 
              mutate(year=year(collectDate)) %>% 
              group_by(siteID,year) %>% 
              summarise(n=length(uid),meanCN=mean(CNratio,na.rm=TRUE)) 
summary.ltr



## ----join-cfc-ltr-data,message=FALSE,eval=TRUE--------------------------------------------------

CN <- full_join(summary.cfc,summary.ltr,
                  join_by("siteID"=="siteID","year"=="year"),
                  suffix = c(".cfc",".ltr")) %>%
                  filter(meanCN.cfc>0,meanCN.ltr>0)



## ----filter-cfc-ltr-data,message=FALSE,eval=TRUE------------------------------------------------

CN <- CN %>%
    	filter(!duplicated(siteID,fromLast = TRUE)) %>%
    	mutate(siteYear=paste(siteID,year,sep="."))



## ----load-data, message=FALSE, warning=FALSE,eval=TRUE------------------------------------------

biorepo<-read.csv(curl("https://github.com/kyule/neon-biorepo-tutorial/raw/main/biorepoOccurrences_FecalAndHairSamples_20250102.csv"))



## ----investigate-biorepo-download,message=FALSE,eval=TRUE---------------------------------------


names(biorepo)



## ----summarize-biorepo-data,message=FALSE,eval=TRUE---------------------------------------------
# How many samples are included in the results for each collection, species, and sex?

biorepo %>% 
  group_by(collectionCode,scientificName,sex) %>% 
  count()



## ----filter-uncertain-identification,message=FALSE,eval=TRUE------------------------------------

biorepo <- biorepo %>% 
              filter(!grepl("/",scientificName),!is.na(specificEpithet))



## ----prepare-biorepo-dataset,message=FALSE,eval=TRUE--------------------------------------------

biorepo <- biorepo %>% 
              mutate(siteID=substr(locationID,1,4)) %>% 
              mutate(siteYear=paste(siteID,year,sep=".")) %>%
              filter(siteYear %in% CN$siteYear)



## ----seperate-collections,message=FALSE,eval=TRUE-----------------------------------------------

# Extract the hair and fecal samples

hair <- biorepo %>%
          filter(collectionCode=="MAMC-HA")

fecal <- biorepo %>%
          filter(collectionCode=="MAMC-FE")



## ----collections-by-species-site-combinations,message=FALSE,eval=TRUE---------------------------

hairBySpecies <- hair %>% 
                  group_by(siteID,scientificName) %>% 
                  count() %>% 
                  arrange(desc(n)) %>%
                  group_by(siteID) %>%
                  slice(1:2) %>% 
                  mutate(siteSp=paste(siteID,scientificName,sep="_"))



## ----filter-by-species-site-combinations,message=FALSE,eval=TRUE--------------------------------


hair <- hair %>% 
          mutate(siteSp=paste(siteID,scientificName,sep="_")) %>%
          filter(siteSp %in% hairBySpecies$siteSp)

fecal <- fecal %>% 
          mutate(siteSp=paste(siteID,scientificName,sep="_")) %>%
          filter(siteSp %in% hairBySpecies$siteSp)



## ----match-hair-fecal-samples,message=FALSE,eval=TRUE-------------------------------------------

sampleMatches <- data.frame(hair=c(),fecal=c())

for (i in 1:nrow(fecal)){
  matchHair <- hair$catalogNumber[grepl(fecal$catalogNumber[i],hair$associatedOccurrences)][1]
  
  if(is.na(matchHair) == FALSE){
    sampleMatches <- rbind(sampleMatches,data.frame(hair=matchHair,fecal=fecal$catalogNumber[i]))
  }
  
}



## ----remove-duplicates,message=FALSE,eval=TRUE--------------------------------------------------

sampleMatches <- sampleMatches %>% filter(!duplicated(hair))




## ----grab-full-data,message=FALSE,eval=TRUE-----------------------------------------------------


# Grab the rest of the data associated with the hair samples

hairMatches <- sampleMatches %>% 
                	left_join(hair,join_by("hair"=="catalogNumber")) 




## ----filter-available-sample-size,message=FALSE,eval=TRUE---------------------------------------


hairMatchSummary <- hairMatches %>%
                		group_by(siteSp) %>% 
                		count() %>% 
                		filter(n>=10)
                

hairMatches <- hairMatches %>%
            		filter(siteSp %in% hairMatchSummary$siteSp)





## ----choose-sample, message=FALSE,eval=TRUE-----------------------------------------------------

set.seed(85705)
hairMatchSet <-  hairMatches[sample(nrow(hairMatches)),] %>%
                	arrange(desc(siteSp)) %>% group_by(siteSp) %>% 
                	slice(1:10)


## ----full-request,message=FALSE,eval=TRUE-------------------------------------------------------

# Filter the full data sets to those involved in the request of interest

request <- biorepo %>%
                filter(catalogNumber %in% c(hairMatchSet$hair,hairMatchSet$fecal))



## ----map-summary,message=FALSE,eval=TRUE--------------------------------------------------------

mapSummary <- hairMatchSet %>%
				group_by(siteID) %>% 
				summarise(lat=mean(decimalLatitude),lng=mean(decimalLongitude)) %>% 					  left_join(CN,join_by("siteID"=="siteID"))


## ----add-species,message=FALSE,eval=TRUE--------------------------------------------------------

mapSummaryWithSpecies <- hairMatchSet %>%
						group_by(siteID,scientificName) %>%
						count() %>%
						left_join(mapSummary,join_by("siteID"=="siteID")) %>% 
						spread(scientificName, n)
					


## ----map,message=FALSE,eval=TRUE----------------------------------------------------------------

basemap <- leaflet() %>% 
				addTiles() %>%
				addProviderTiles(providers$CartoDB.PositronNoLabels) %>% 
				setView(lng = -75, lat = 42, zoom = 5)

speciesByCN <- basemap %>% 
				  addMinicharts(mapSummaryWithSpecies$lng, mapSummaryWithSpecies$lat,
				  type ='pie',
				  chartdata = mapSummaryWithSpecies[,10:12],
				  width = mapSummaryWithSpecies$meanCN.cfc/2)

speciesByCN



## ----plot,eval=TRUE-----------------------------------------------------------------------------


PleucSites <- mapSummaryWithSpecies[!is.na(mapSummaryWithSpecies$`Peromyscus leucopus`), ]

ggplot(PleucSites, aes(x = meanCN.ltr, y = meanCN.cfc)) +
  geom_point() +
  labs(
    x = "Litter CN ratio",
    y = "Canopy Foliage CN ratio",
  ) +
  theme_minimal() 



