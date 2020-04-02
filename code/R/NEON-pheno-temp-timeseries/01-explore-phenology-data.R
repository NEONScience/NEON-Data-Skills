<<<<<<< HEAD
## ----setup, include=FALSE------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----loadStuff-----------------------------------------------------------------------------------------

library(neonUtilities)
library(dplyr)
library(ggplot2)

options(stringsAsFactors=F) #used to prevent factors
=======
## ----loadStuff-----------------------------------------------------------

library(dplyr)
library(ggplot2)
library(lubridate)  

>>>>>>> parent of 70a5ba2a... link updates

# set working directory to ensure R can find the file we wish to import
# setwd("working-dir-path-here")

<<<<<<< HEAD
## Two options for accessing data - programmatic or from the example dataset
# Read data from data portal 

phe <- loadByProduct(dpID = "DP1.10055.001", site=c("BLAN","SCBI","SERC"), 
										 startdate = "2017-01", enddate="2019-12", 
										 check.size = F) 
# if you aren't sure you can handle the data file size use check.size = T. 

# save dataframes from the downloaded list
ind <- phe$phe_perindividual  #individual information
status <- phe$phe_statusintensity  #status & intensity info


## If choosing to use example dataset downloaded from this tutorial.
# Read in data
#ind <- read.csv('NEON-pheno-temp-timeseries/pheno/phe_perindividual.csv', 
#		stringsAsFactors = FALSE )

#status <- read.csv('NEON-pheno-temp-timeseries/pheno/phe_statusintensity.csv', 
#		stringsAsFactors = FALSE)



## ----look-ind------------------------------------------------------------------------------------------
=======

# Read in data
ind <- read.csv('NEON-pheno-temp-timeseries/pheno/phe_perindividual.csv', 
		stringsAsFactors = FALSE )

status <- read.csv('NEON-pheno-temp-timeseries/pheno/phe_statusintensity.csv', 
		stringsAsFactors = FALSE)


## ----look-ind------------------------------------------------------------
>>>>>>> parent of 70a5ba2a... link updates
# What are the fieldnames in this dataset?
names(ind)

# how many rows are in the data?
nrow(ind)

# look at the first six rows of data.
<<<<<<< HEAD
#head(ind) #this is a good function to use but looks messy so not rendering it 
=======
head(ind)
>>>>>>> parent of 70a5ba2a... link updates

# look at the structure of the dataframe.
str(ind)


<<<<<<< HEAD

## ----look-status---------------------------------------------------------------------------------------
=======
## ----look-status---------------------------------------------------------
>>>>>>> parent of 70a5ba2a... link updates

# What variables are included in this dataset?
names(status)
nrow(status)
<<<<<<< HEAD
#head(status)   #this is a good function to use but looks messy so not rendering it 
=======
head(status)
>>>>>>> parent of 70a5ba2a... link updates
str(status)

# date range
min(status$date)
max(status$date)


<<<<<<< HEAD

## ----remove-duplicates---------------------------------------------------------------------------------
=======
## ----remove-uid----------------------------------------------------------

ind <- select(ind,-uid)
status <- select (status, -uid)


## ----remove-duplicates---------------------------------------------------
>>>>>>> parent of 70a5ba2a... link updates
# remove duplicates
## expect many

ind_noD <- distinct(ind)
nrow(ind_noD)

status_noD<-distinct(status)
nrow(status_noD)


<<<<<<< HEAD

## ----same-fieldnames-----------------------------------------------------------------------------------

# where is there an intersection of names
intersect(names(status_noD), names(ind_noD))



## ----rename-column-------------------------------------------------------------------------------------

# in Status table rename like columns 
status_noD <- rename(status_noD, uidStat=uid, dateStat=date, 
										 editedDateStat=editedDate, measuredByStat=measuredBy, 
										 recordedByStat=recordedBy, 
										 samplingProtocolVersionStat=samplingProtocolVersion, 
										 remarksStat=remarks, dataQFStat=dataQF, 
										 publicationDateStat=publicationDate)


## ----filter-edit-date----------------------------------------------------------------------------------
=======
## ----same-fieldnames-----------------------------------------------------

# where is there an intersection of names
sameName <- intersect(names(status_noD), names(ind_noD))
sameName


## ----rename-column-------------------------------------------------------

# rename status editedDate
status_noD <- rename(status_noD, editedDateStat=editedDate, 
		measuredByStat=measuredBy, recordedByStat=recordedBy, 
		samplingProtocolVersionStat=samplingProtocolVersion, 
		remarksStat=remarks, dataQFStat=dataQF)



## ----as-date-only--------------------------------------------------------

# convert column to date class
ind_noD$editedDate <- as.Date(ind_noD$editedDate)
str(ind_noD$editedDate)

status_noD$date <- as.Date(status_noD$date)
str(status_noD$date)


## ----filter-edit-date----------------------------------------------------
>>>>>>> parent of 70a5ba2a... link updates
# retain only the max of the date for each individualID
ind_last <- ind_noD %>%
	group_by(individualID) %>%
	filter(editedDate==max(editedDate))

<<<<<<< HEAD
# oh wait, duplicate dates, retain only the most recent editedDate
=======
# oh wait, duplicate dates, retain only one
>>>>>>> parent of 70a5ba2a... link updates
ind_lastnoD <- ind_last %>%
	group_by(editedDate, individualID) %>%
	filter(row_number()==1)


<<<<<<< HEAD

## ----join-dfs------------------------------------------------------------------------------------------
=======
## ----join-dfs-error------------------------------------------------------
>>>>>>> parent of 70a5ba2a... link updates

# Create a new dataframe "phe_ind" with all the data from status and some from ind_lastnoD
phe_ind <- left_join(status_noD, ind_lastnoD)



<<<<<<< HEAD
## ----filter-site---------------------------------------------------------------------------------------
=======
## ----join-dfs------------------------------------------------------------
# drop taxonID, scientificName
status_noD <- select (status_noD, -taxonID, -scientificName)

# Create a new dataframe "phe_ind" with all the data from status and some from ind_lastnoD
phe_ind <- left_join(status_noD, ind_lastnoD)


## ----filter-site---------------------------------------------------------
>>>>>>> parent of 70a5ba2a... link updates

# set site of interest
siteOfInterest <- "SCBI"

# use filter to select only the site of Interest 
## using %in% allows one to add a vector if you want more than one site. 
## could also do it with == instead of %in% but won't work with vectors

<<<<<<< HEAD
phe_1st <- filter(phe_ind, siteID %in% siteOfInterest)

=======
phe_1sp <- filter(phe_ind, siteID %in% siteOfInterest)
>>>>>>> parent of 70a5ba2a... link updates




<<<<<<< HEAD
## ----filter-species------------------------------------------------------------------------------------

# see which species are present
unique(phe_1st$taxonID)
=======
## ----filter-species------------------------------------------------------

# see which species are present
unique(phe_1sp$taxonID)
>>>>>>> parent of 70a5ba2a... link updates

speciesOfInterest <- "LITU"

#subset to just "LITU"
# here just use == but could also use %in%
<<<<<<< HEAD
phe_1sp <- filter(phe_1st, taxonID==speciesOfInterest)
=======
phe_1sp <- filter(phe_1sp, taxonID==speciesOfInterest)
>>>>>>> parent of 70a5ba2a... link updates

# check that it worked
unique(phe_1sp$taxonID)


<<<<<<< HEAD

## ----filter-phonophase---------------------------------------------------------------------------------

# see which phenophases are present
=======
## ----filter-phonophase---------------------------------------------------

# see which species are present
>>>>>>> parent of 70a5ba2a... link updates
unique(phe_1sp$phenophaseName)

phenophaseOfInterest <- "Leaves"

<<<<<<< HEAD
#subset to just the phenosphase of interest 
=======
#subset to just the phenosphase of Interest 
>>>>>>> parent of 70a5ba2a... link updates
phe_1sp <- filter(phe_1sp, phenophaseName %in% phenophaseOfInterest)

# check that it worked
unique(phe_1sp$phenophaseName)


<<<<<<< HEAD

## ----calc-total-yes------------------------------------------------------------------------------------

# Total in status by day
sampSize <- count(phe_1sp, dateStat)
inStat <- phe_1sp %>%
	group_by(dateStat) %>%
  count(phenophaseStatus)
inStat <- full_join(sampSize, inStat, by="dateStat")
=======
## ----calc-total-yes------------------------------------------------------

# Total in status by day
sampSize <- count(phe_1sp, date)
inStat <- phe_1sp %>%
	group_by(date) %>%
  count(phenophaseStatus)
inStat <- full_join(sampSize, inStat, by="date")
>>>>>>> parent of 70a5ba2a... link updates

# Retain only Yes
inStat_T <- filter(inStat, phenophaseStatus %in% "yes")


<<<<<<< HEAD

## ----plot-leaves-total---------------------------------------------------------------------------------

# plot number of individuals in leaf
phenoPlot <- ggplot(inStat_T, aes(dateStat, n.y)) +
=======
## ----plot-leaves-total---------------------------------------------------

# plot number of individuals in leaf
phenoPlot <- ggplot(inStat_T, aes(date, n.y)) +
>>>>>>> parent of 70a5ba2a... link updates
    geom_bar(stat="identity", na.rm = TRUE) 

phenoPlot


# Now let's make the plot look a bit more presentable
<<<<<<< HEAD
phenoPlot <- ggplot(inStat_T, aes(dateStat, n.y)) +
=======
phenoPlot <- ggplot(inStat_T, aes(date, n.y)) +
>>>>>>> parent of 70a5ba2a... link updates
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Total Individuals in Leaf") +
    xlab("Date") + ylab("Number of Individuals") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

phenoPlot


<<<<<<< HEAD

## ----plot-leaves-percentage----------------------------------------------------------------------------
=======
## ----plot-leaves-percentage----------------------------------------------
>>>>>>> parent of 70a5ba2a... link updates

# convert to percent
inStat_T$percent<- ((inStat_T$n.y)/inStat_T$n.x)*100

# plot percent of leaves
<<<<<<< HEAD
phenoPlot_P <- ggplot(inStat_T, aes(dateStat, percent)) +
=======
phenoPlot_P <- ggplot(inStat_T, aes(date, percent)) +
>>>>>>> parent of 70a5ba2a... link updates
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Proportion in Leaf") +
    xlab("Date") + ylab("% of Individuals") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

phenoPlot_P


<<<<<<< HEAD

## ----filter-to-2018------------------------------------------------------------------------------------

# use filter to select only the date of interest 
phe_1sp_2018 <- filter(inStat_T, dateStat >= "2018-01-01" & dateStat <= "2018-12-31")

# did it work?
range(phe_1sp_2018$dateStat)



## ----plot-2018-----------------------------------------------------------------------------------------

# Now let's make the plot look a bit more presentable
phenoPlot18 <- ggplot(phe_1sp_2018, aes(dateStat, n.y)) +
=======
## ----filter-to-2016------------------------------------------------------

# use filter to select only the site of Interest 
phe_1sp_2016 <- filter(inStat_T, date >= "2016-01-01")

# did it work?
range(phe_1sp_2016$date)


## ----plot-2016-----------------------------------------------------------

# Now let's make the plot look a bit more presentable
phenoPlot16 <- ggplot(phe_1sp_2016, aes(date, n.y)) +
>>>>>>> parent of 70a5ba2a... link updates
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Total Individuals in Leaf") +
    xlab("Date") + ylab("Number of Individuals") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

<<<<<<< HEAD
phenoPlot18



## ----write-csv, eval=F---------------------------------------------------------------------------------
## # Write .csv (this will be read in new in subsuquent lessons)
## # This will write to your current working directory, change as desired.
## write.csv( phe_1sp_2018 , file="NEONpheno_LITU_Leaves_SCBI_2018.csv", row.names=F)
## 
## #If you are using the downloaded example date, this code will write it to the
## #data file.
## 
## #write.csv( phe_1sp_2016 , file="NEON-pheno-temp-timeseries/pheno/NEONpheno_LITU_Leaves_SCBI_2016.csv", row.names=F)
## 
=======
phenoPlot16


## ----write-csv, echo = FALSE---------------------------------------------
# Write .csv (this will be read in new in subsuquent lessons)
write.csv( phe_1sp_2016 , file="NEON-pheno-temp-timeseries/pheno/NEONpheno_LITU_Leaves_SCBI_2016.csv", row.names=F)

>>>>>>> parent of 70a5ba2a... link updates

