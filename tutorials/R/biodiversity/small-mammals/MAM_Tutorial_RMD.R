## ----load-packages, , message=FALSE, warning=FALSE, results="hide"---------------------------------
library(dplyr)
library(neonUtilities)
library(neonOS)
library(ggplot2)


## ----mamdat, results="hide"------------------------------------------------------------------------
mamdat <- loadByProduct(dpID="DP1.10072.001", 
                         site=c("SCBI", "KONZ", "UNDE"),
                         package="basic", 
                         check.size = FALSE,
                        startdate = "2021-01",
                        enddate = "2022-12")


## ----set directory, results="hide"-----------------------------------------------------------------
#Set working directory
# rm(list=ls())
# wd<-"/Users/paull/Desktop/data/"
# setwd(wd)
# mam_pertrapnight<-neonUtilities::readTableNEON(dataFile = paste0(wd,'NEON_count-small-mammals/stackedFiles/mam_pertrapnight.csv'), varFile = paste0(wd,'NEON_count-small-mammals/stackedFiles/variables_10072.csv'))
# 
# mam_perplotnight<-neonUtilities::readTableNEON(dataFile = paste0(wd,'NEON_count-small-mammals/stackedFiles/mam_perplotnight.csv'), varFile = paste0(wd,'NEON_count-small-mammals/stackedFiles/variables_10072.csv'))
# 
# rpt2_pathogentesting<-neonUtilities::readTableNEON(dataFile = paste0(wd,'NEON_tick-pathogens-rodent/stackedFiles/rpt2_pathogentesting.csv'), varFile = paste0(wd,'NEON_tick-pathogens-rodent/stackedFiles/variables_10064.csv'))
# 
# mam.list<-read.csv(paste0(wd,'taxonTableMAM.csv'))
# 
# variables_10072<-read.csv(paste0(wd, 'NEON_count-small-mammals/stackedFiles/variables_10072.csv'))
# 
# variables_10064<-read.csv(paste0(wd, 'NEON_tick-pathogens-rodent/stackedFiles/variables_10064.csv'))


## ----download-overview, message=FALSE, warning=FALSE-----------------------------------------------
#View all tables in the list of downloaded small mammal data:
names(mamdat)

#Extract the items from the list and add as dataframes in the R environment:
list2env(mamdat, envir=.GlobalEnv)


## ----data download, results="hide"-----------------------------------------------------------------
#1.Check the perplotnight table by nightuid using standard removeDups function
mam_plotNight_nodups <- neonOS::removeDups(data=mam_perplotnight,
                             variables=variables_10072,
                             table='mam_perplotnight')

#2. It is worth noting that standard function cannot account for multiple 
# captures of untagged individuals in a single trap (trapStatus = 4) and thus 
# those should be filtered out before running the removeDups function on the 
# mam_pertrapnight data.
mam_trapNight_multipleCaps <- mam_pertrapnight %>% 
  filter(trapStatus == "4 - more than 1 capture in one trap" & is.na(tagID) & is.na(individualCode)) 
#This data subset contains no multiple captures so no further filtering is 
# necessary

#Check the pertrapnight table using standard removeDups function 
mam_trapNight_nodups <- neonOS::removeDups(data=mam_pertrapnight,
                             variables=variables_10072,
                             table='mam_pertrapnight') 


## ----data join, results="hide"---------------------------------------------------------------------
mamjn<-neonOS::joinTableNEON(mam_plotNight_nodups, mam_trapNight_nodups, name1 = "mam_perplotnight", name2 = "mam_pertrapnight")

#It is helpful to verify that there are the expected number of records (the 
# total in the pertrapnight table) and that the key variables are not blank/NA.
which(is.na(mamjn$eventID))


## ----quality checks, results="hide"----------------------------------------------------------------
trapStatusErrorCheck <- mam_trapNight_nodups %>% 
  filter(!is.na(tagID)) %>% 
  filter(!grepl("capture",trapStatus))
nrow(trapStatusErrorCheck)
#There are no records that have a tagID without a captured trapStatus

tagIDErrorCheck <- mam_trapNight_nodups %>% 
  filter(is.na(tagID)) %>% 
  filter(grepl("capture",trapStatus))
nrow(trapStatusErrorCheck)
#There are no records that lack a tagID but are marked with a captured trapStatus 

#We can proceed using the trapStatus field to filter the data to only those 
# traps that captured animals.


## ----filter to target taxa, message=FALSE, warning=FALSE,  results="hide"--------------------------
#Read in master SMALL_MAMMAL taxon table. Use verbose = T to get taxonProtocolCategory
mam.list <- neonOS::getTaxonList(taxonType="SMALL_MAMMAL", 
                                 recordReturnLimit=1000, verbose=T)

targetTaxa <- mam.list %>% 
  filter(taxonProtocolCategory == "target") %>% 
  select(taxonID, scientificName)

#Filter trap dataset to just the capture records of target taxa and a few core 
# fields needed for the analyses.
coreFields <- c("nightuid", "plotID", "collectDate.x", "tagID", 
                "taxonID", "eventID")

captures <- mamjn %>% 
  filter(grepl("capture",trapStatus) & taxonID %in% targetTaxa$taxonID) %>% 
  select(coreFields) %>%
  rename('collectDate' = 'collectDate.x')


## ----generate data table MNKA, message=FALSE, warning=FALSE,  results="hide"-----------------------
#Generate a column of all of the unique tagIDs included in the dataset
uTags <- captures %>% select(tagID) %>% filter(!is.na(tagID)) %>% distinct()
#create empty data frame to populate
capsNew <- slice(captures,0)

#For each tagged individual, add a record for each night of trapping done on 
# the plots on which it was captured between the first and last dates of capture
for (i in uTags$tagID){
  indiv <- captures %>% filter(tagID == i)
  firstCap <- as.Date(min(indiv$collectDate), "YYYY-MM-DD", tz = "UTC")
  lastCap <- as.Date(max(indiv$collectDate), "YYYY-MM-DD", tz = "UTC")
  possibleDates <- seq(as.Date(firstCap), as.Date(lastCap), by="days")
  potentialNights <- mam_plotNight_nodups %>% 
    filter(as.character(collectDate) %in% 
             as.character(possibleDates) & plotID %in% indiv$plotID) %>% 
    select(nightuid,plotID, collectDate, eventID) %>% 
    mutate(tagID=i)
  allnights <- left_join(potentialNights, indiv)
  allnights$taxonID<-unique(indiv$taxonID)[1] #Note that taxonID sometimes 
  # changes between recaptures.  This uses only the first identification but 
  #there are a number of other ways to handle this situation.
  capsNew <- bind_rows(capsNew, allnights)
}

#check for untagged individuals and add back to the dataset if necessary:
caps_notags <- captures %>% filter(is.na(tagID))
caps_notags


## ----calculate MNKA, message=FALSE, warning=FALSE--------------------------------------------------
mnka_per_site <- function(capture_data) {
  mnka_by_plot_bout <- capture_data %>% group_by(eventID,plotID) %>% 
    summarize(n=n_distinct(tagID))
    mean_mnka_by_site_bout <- mnka_by_plot_bout %>% 
      mutate(siteID = substr(plotID, 1, 4)) %>%
      group_by(siteID, eventID) %>% 
      summarise(meanMNKA = mean(n))
      return(mean_mnka_by_site_bout)
}

MNKA<-mnka_per_site(capture_data = capsNew)
head(MNKA)


## ----plotMNKA, message=FALSE, warning=FALSE--------------------------------------------------------
#To estimate the minimum number known alive for each species at each bout and 
# site it is possible to loop through and run the function for each taxonID
MNKAbysp<-data.frame()
splist<-unique(capsNew$taxonID)
for(i in 1:length(splist)){
  taxsub<-capsNew %>% 
    filter (taxonID %in% splist[i]) %>% mutate(taxonID = splist[i])
  MNKAtax<-mnka_per_site(taxsub) %>% 
    mutate(taxonID=splist[i], Year = substr(eventID,6,9))
  MNKAbysp<-rbind(MNKAbysp,MNKAtax)
}

#Next we will visualize the abundance flucutations for Peromyscus leucopus 
# through time:
MNKA_PE<-MNKAbysp %>% filter(taxonID%in%"PELE")

#Create a dataframe with the first date of collection for each bout to use as 
# the date variable when plotting
datedf<-mam_plotNight_nodups %>% 
  select(eventID, collectDate) %>% 
  group_by(eventID) %>%
  summarise(Date = min(collectDate)) %>%
  mutate(Year = substr(Date,1,4), MMDD=substr(Date,6,10))

MNKA_PE<-left_join(MNKA_PE, datedf)

PELEabunplot<-ggplot(data=MNKA_PE, 
                     aes(x=MMDD, y=meanMNKA, color=Year, group=Year)) +
  geom_point() +
  geom_line()+
  facet_wrap(~siteID) +
  theme(axis.text.x =element_text(angle=90))
#group tells ggplot which points to group together when connecting via a line.

PELEabunplot


## ----plotDiversity, message=FALSE, warning=FALSE---------------------------------------------------
TaxDat<-MNKAbysp %>% 
  group_by(taxonID, siteID) %>% summarise(max=max(meanMNKA))

TaxPlot<-ggplot(TaxDat, aes(x=taxonID, y=max, fill=taxonID)) + 
  geom_bar(stat = "identity")+
  facet_wrap(~siteID, scales = 'free') +
  theme_bw()+
  theme(axis.text.x = element_text(angle=90, vjust=.5, hjust=1))

TaxPlot


## ----pathogen data compilation, message = FALSE, warning = FALSE, results="hide"-------------------
#First download the rodent pathogen data
rptdat <- loadByProduct(dpID="DP1.10064.002", 
                         site=c("SCBI", "KONZ", "UNDE"),
                         package="basic", 
                         check.size = FALSE,
                        startdate = "2021-01",
                        enddate = "2022-12")

list2env(rptdat, envir=.GlobalEnv)

#Then check for and deal with any duplicates
rpt_pathres_nodups <- neonOS::removeDups(data=rpt2_pathogentesting,
                             variables=variables_10064,
                             table='rpt2_pathogentesting')


## ----trapping pathogen merge, message = FALSE, warning = FALSE-------------------------------------
#First subset the two dataframes that will be merged to select out a smaller 
# subset of columns to make working with the data easier:
rptdat.merge<-rpt_pathres_nodups %>% 
  select(plotID, collectDate, sampleID, testPathogenName, testResult) %>%
  mutate(Site = substr(plotID,1,4))
mamdat.merge<-mam_trapNight_nodups %>% 
  select(taxonID, bloodSampleID, earSampleID)

#Split the rodent pathogen data by sample types (ear or blood) before joining 
# with the trapping data since there are 2 different columns for sampleID in 
# the mammal trapping data - one for blood samples and one for ear samples.
rptear<-rptdat.merge %>% filter(grepl('.E', sampleID, fixed=T))
rptblood<-rptdat.merge %>% filter(grepl('.B', sampleID, fixed=T))

#Join each sample type with the correct column from the mammal trapping data.
rptear.j<-left_join(rptear, mamdat.merge, by=c("sampleID"="earSampleID"))
rptblood.j<-left_join(rptblood, mamdat.merge, by=c("sampleID"="bloodSampleID"))
rptall<-rbind(rptear.j[,-8], rptblood.j[,-8]) #combine the dataframes after 
# getting rid of the last column whose names don't match and whose data is 
# replaced by the sampleID column


## ----prevalencePlots, message = FALSE, warning = FALSE---------------------------------------------
#Calculate the prevalence of the different pathogens in the different taxa at 
#each site.
rptprev<-rptall %>%
  group_by(Site, testPathogenName, taxonID) %>% 
  summarise(tot.test=n(), tot.pos = sum(testResult=='Positive')) %>%
  mutate(prevalence = tot.pos/tot.test)

#Barplot of prevalence by site and pathogen name
PathPlot<-ggplot(rptprev, 
                 aes(x=testPathogenName, y=prevalence, fill=testPathogenName)) + 
  geom_bar(stat = "identity")+
  facet_wrap(~Site) +
  theme_bw()+
  theme(axis.text.x = element_text(angle=90, vjust=.5, hjust=1))
PathPlot

#SCBI seems to have a high prevalence of pathogens - let's look at the 
# prevalence across the species examined for testing:
SCBIpathdat<-rptprev %>% filter(Site %in% 'SCBI')
SCBIPlot<-ggplot(SCBIpathdat, 
                 aes(x=testPathogenName, y=prevalence, fill=testPathogenName)) + 
  geom_bar(stat = "identity")+
  facet_wrap(~taxonID) +
  theme_bw()+
  theme(axis.text.x = element_text(angle=90, vjust=.5, hjust=1))
SCBIPlot

