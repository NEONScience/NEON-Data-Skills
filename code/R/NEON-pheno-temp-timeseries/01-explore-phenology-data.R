## ----loadStuff-----------------------------------------------------------

library(dplyr)
library(ggplot2)
library(lubridate)  


# set working directory to ensure R can find the file we wish to import
# setwd("working-dir-path-here")


# Read in data
ind <- read.csv('NEON-pheno-temp-timeseries/pheno/phe_perindividual.csv', 
		stringsAsFactors = FALSE )

status <- read.csv('NEON-pheno-temp-timeseries/pheno/phe_statusintensity.csv', 
		stringsAsFactors = FALSE)


## ----look-ind------------------------------------------------------------
# What are the fieldnames in this dataset?
names(ind)

# how many rows are in the data?
nrow(ind)

# look at the first six rows of data.
head(ind)

# look at the structure of the dataframe.
str(ind)


## ----look-status---------------------------------------------------------

# What variables are included in this dataset?
names(status)
nrow(status)
head(status)
str(status)

# date range
min(status$date)
max(status$date)


## ----remove-uid----------------------------------------------------------

ind <- select(ind,-uid)
status <- select (status, -uid)


## ----remove-duplicates---------------------------------------------------
# remove duplicates
## expect many

ind_noD <- distinct(ind)
nrow(ind_noD)

status_noD<-distinct(status)
nrow(status_noD)


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
# retain only the max of the date for each individualID
ind_last <- ind_noD %>%
	group_by(individualID) %>%
	filter(editedDate==max(editedDate))

# oh wait, duplicate dates, retain only one
ind_lastnoD <- ind_last %>%
	group_by(editedDate, individualID) %>%
	filter(row_number()==1)


## ----join-dfs-error------------------------------------------------------

# Create a new dataframe "phe_ind" with all the data from status and some from ind_lastnoD
phe_ind <- left_join(status_noD, ind_lastnoD)



## ----join-dfs------------------------------------------------------------
# drop taxonID, scientificName
status_noD <- select (status_noD, -taxonID, -scientificName)

# Create a new dataframe "phe_ind" with all the data from status and some from ind_lastnoD
phe_ind <- left_join(status_noD, ind_lastnoD)


## ----filter-site---------------------------------------------------------

# set site of interest
siteOfInterest <- "SCBI"

# use filter to select only the site of Interest 
## using %in% allows one to add a vector if you want more than one site. 
## could also do it with == instead of %in% but won't work with vectors

phe_1sp <- filter(phe_ind, siteID %in% siteOfInterest)




## ----filter-species------------------------------------------------------

# see which species are present
unique(phe_1sp$taxonID)

speciesOfInterest <- "LITU"

#subset to just "LITU"
# here just use == but could also use %in%
phe_1sp <- filter(phe_1sp, taxonID==speciesOfInterest)

# check that it worked
unique(phe_1sp$taxonID)


## ----filter-phonophase---------------------------------------------------

# see which species are present
unique(phe_1sp$phenophaseName)

phenophaseOfInterest <- "Leaves"

#subset to just the phenosphase of Interest 
phe_1sp <- filter(phe_1sp, phenophaseName %in% phenophaseOfInterest)

# check that it worked
unique(phe_1sp$phenophaseName)


## ----calc-total-yes------------------------------------------------------

# Total in status by day
sampSize <- count(phe_1sp, date)
inStat <- phe_1sp %>%
	group_by(date) %>%
  count(phenophaseStatus)
inStat <- full_join(sampSize, inStat, by="date")

# Retain only Yes
inStat_T <- filter(inStat, phenophaseStatus %in% "yes")


## ----plot-leaves-total---------------------------------------------------

# plot number of individuals in leaf
phenoPlot <- ggplot(inStat_T, aes(date, n.y)) +
    geom_bar(stat="identity", na.rm = TRUE) 

phenoPlot


# Now let's make the plot look a bit more presentable
phenoPlot <- ggplot(inStat_T, aes(date, n.y)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Total Individuals in Leaf") +
    xlab("Date") + ylab("Number of Individuals") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

phenoPlot


## ----plot-leaves-percentage----------------------------------------------

# convert to percent
inStat_T$percent<- ((inStat_T$n.y)/inStat_T$n.x)*100

# plot percent of leaves
phenoPlot_P <- ggplot(inStat_T, aes(date, percent)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Proportion in Leaf") +
    xlab("Date") + ylab("% of Individuals") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

phenoPlot_P


## ----filter-to-2016------------------------------------------------------

# use filter to select only the site of Interest 
phe_1sp_2016 <- filter(inStat_T, date >= "2016-01-01")

# did it work?
range(phe_1sp_2016$date)


## ----plot-2016-----------------------------------------------------------

# Now let's make the plot look a bit more presentable
phenoPlot16 <- ggplot(phe_1sp_2016, aes(date, n.y)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Total Individuals in Leaf") +
    xlab("Date") + ylab("Number of Individuals") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

phenoPlot16


## ----write-csv, echo = FALSE---------------------------------------------
# Write .csv (this will be read in new in subsuquent lessons)
write.csv( phe_1sp_2016 , file="NEON-pheno-temp-timeseries/pheno/NEONpheno_LITU_Leaves_SCBI_2016.csv", row.names=F)


