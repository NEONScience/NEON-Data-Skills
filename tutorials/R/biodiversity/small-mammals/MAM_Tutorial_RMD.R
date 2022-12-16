## ----install_packages, eval=FALSE------------------------------------------------------------------
## * **dplyr:** `install.packages("dplyr")`
## * **neonUtilities:** `install.packages("neonUtilities")`
## * **neonOS:** `install.packages("neonOS")`
## * **ggplot2:** `install.packages("ggplot2")`


## ----load-packages, , message=FALSE, warning=FALSE, results="hide"---------------------------------
library(dplyr)
library(neonUtilities)
library(neonOS)
library(ggplot2)


## ----mamdat, results="hide"------------------------------------------------------------------------
mamdat <- loadByProduct(dpID="DP1.10072.001", 
                         site=c("SCBI", "SRER", "UNDE"),
                         package="basic", 
                         check.size = FALSE,
                        startdate = "2021-01",
                        enddate = "2022-12")


## ----set directory, results="hide"-----------------------------------------------------------------
#Set working directory
#wd<-"~/data"
#setwd(wd)



## ----download-overview, message=FALSE, warning=FALSE-----------------------------------------------
#View all tables in the list of downloaded small mammal data:
names(mamdat)
# The categoricalCodes file provides controlled 
# lists used in the data

# The issueLog and readme have the same information that you
# will find on the data product landing page of the data portal

# The mam_perplotnight table includes the date and time for all trap setting efforts and will
# include an eventID value to indicate a unique bout of sampling in the 2023 release

#The mam_pertrapnight table includes a record for each trap set along with information about any captures and samples.

# The validation file provides the rules that constrain data upon ingest into the NEON database:

# The variables file describes each field in the returned data tables

#Extract the items from the list and add as dataframes in the R environment:
list2env(mamdat, envir=.GlobalEnv)


## ----data download, results="hide"-----------------------------------------------------------------
#1. check perplotnight table by nightuid using standard removeDups function
mam_plotNight_nodups <- neonOS::removeDups(data=mam_perplotnight,
                             variables=variables_10072,
                             table='mam_perplotnight')
#2. check pertrapnight table by nightuid and trapcoordinate using standard removeDups function 
mam_trapNight_multipleCaps <- mam_pertrapnight %>% filter(trapStatus == "4 - more than 1 capture in one trap" & is.na(tagID) & is.na(individualCode)) #This data subset contains no multiple captures so no further filtering is necessary

mam_trapNight_nodups <- neonOS::removeDups(data=mam_pertrapnight,
                             variables=variables_10072,
                             table='mam_pertrapnight') 


## ----data join, results="hide"---------------------------------------------------------------------
mamjn<-neonOS::joinTableNEON(mam_plotNight_nodups, mam_trapNight_nodups, name1 = "mam_perplotnight", name2 = "mam_pertrapnight")

#It is useful to verify that there are the expected number of records (the total in the pertrapnight table) and that the key variables are not blank/NA.
which(is.na(mamjn$eventID))


## ----quality checks, results="hide"----------------------------------------------------------------
trapStatusErrorCheck <- mam_trapNight_nodups %>% 
  filter(!is.na(tagID)) %>% 
  filter(!grepl("capture",trapStatus))
nrow(trapStatusErrorCheck)
#There are no records that have a tagID without a captured trapStatus so we can proceed using the trapStatus field to filter the data to only those traps that captured animals.


## ----generate data table MNKA, message=FALSE, warning=FALSE,  results="hide"-----------------------
#1. Filter the captures down to the target taxa.  The raw table includes numerous records for opportunistic taxa that are not specifically targeted by our sampling methods.  The small mammal taxonomy table lists each taxonID as being target or not and can be used to filter to only target species.

#Read in master SMALL_MAMMAL taxon table. Use verbose = T to get taxonProtocolCategory
mam.list <- neonOS::getTaxonList(taxonType="SMALL_MAMMAL", recordReturnLimit=1000, verbose=T)

targetTaxa <- mam.list %>% filter(taxonProtocolCategory == "target") %>% select(taxonID, scientificName)

#Filter trap dataset to just the capture records of target taxa and a few core fields needed for the analyses.
coreFields <- c("nightuid", "plotID", "collectDate.x", "tagID", "taxonID", "eventID")
captures <- mamjn %>% 
  filter(grepl("capture",trapStatus) & taxonID %in% targetTaxa$taxonID) %>% 
  select(coreFields) %>%
  rename('collectDate' = 'collectDate.x')

#Next add implicit records of animals assumed present at a given sampling date because they were captured before and after that sample point.

#Generate a column of all of the unique tagIDs included in the dataset
uTags <- captures %>% select(tagID) %>% filter(!is.na(tagID)) %>% distinct()
#create empty data frame to populate
capsNew <- slice(captures,0)

#for each tagged individual, add a record for each night of trapping done on the plots on which it was captured between the first and last dates of capture
for (i in uTags$tagID){
  indiv <- captures %>% filter(tagID == i)
  firstCap <- as.Date(min(indiv$collectDate), "YYYY-MM-DD", tz = "UTC")
  lastCap <- as.Date(max(indiv$collectDate), "YYYY-MM-DD", tz = "UTC")
  possibleDates <- seq(as.Date(firstCap), as.Date(lastCap), by="days")
  potentialNights <- mam_plotNight_nodups %>% 
    filter(as.character(collectDate) %in% as.character(possibleDates) & 
                                                       plotID %in% indiv$plotID) %>% 
    select(nightuid,plotID, collectDate, eventID) %>% 
    mutate(tagID=i)
  allnights <- left_join(potentialNights, indiv)
  allnights$taxonID<-unique(indiv$taxonID)[1] #Note that taxonID sometimes changes between recaptures.  This uses only the first identification but there are a number of other ways to handle this situation.
  capsNew <- bind_rows(capsNew, allnights)
}

#check for untagged individuals and add back to the dataset if necessary:
caps_notags <- captures %>% filter(is.na(tagID))
caps_notags


## ----calculate MNKA, message=FALSE, warning=FALSE--------------------------------------------------

mnka_per_site <- function(capture_data) {
  mnka_by_plot_bout <- capture_data %>% group_by(eventID,plotID) %>% 
    summarize(n=n_distinct(tagID))
    mean_mnka_by_site_bout <- mnka_by_plot_bout %>% mutate(siteID = substr(plotID, 1, 4)) %>%
      group_by(siteID, eventID) %>% 
      summarise(meanMNKA = mean(n))
      return(mean_mnka_by_site_bout)
}

MNKA<-mnka_per_site(capture_data = capsNew)
head(MNKA)


## ----plot MNKA, message=FALSE, warning=FALSE-------------------------------------------------------
#If we are interested in just the abundance fluctuations of all Peromyscus leucopus / Peromyscus maniculatis at a site we can first filter the capture dataset down to those 2 species and then run our function and plot the outputs via date.
splist<-c("PELE", "PEMA")
PELEPEMA<-capsNew %>% filter(taxonID %in% splist)

MNKA_PE<-mnka_per_site(PELEPEMA)

#Create a dataframe with the first date of collection for each bout to use as the date variable when plotting
datedf<-mam_plotNight_nodups %>% 
  select(eventID, collectDate) %>% 
  group_by(eventID) %>%
  summarise(Date = min(collectDate)) %>%
  mutate(Year = substr(Date,1,4), MMDD=substr(Date,6,10))

MNKA_PE<-left_join(MNKA_PE, datedf)

PELEabunplot<-ggplot(data=MNKA_PE, aes(x=MMDD, y=meanMNKA, color=Year, group=Year)) +
  geom_point() +
  geom_line()+
  facet_wrap(~siteID) +
  theme(axis.text.x =element_text(angle=90))
#group tells ggplot which points to group together when connecting via a line.

PELEabunplot

