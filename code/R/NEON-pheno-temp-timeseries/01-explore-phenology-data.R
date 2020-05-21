## ----setup, include=FALSE-------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----set-up---------------------------------------------------------------------------------

library(neonUtilities)
library(dplyr)
library(ggplot2)

options(stringsAsFactors=F) #used to prevent factors

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. Be sure to move the download into your working directory!
wd <- "~/Documents/data/" # Change this to match your local environment
setwd(wd)



## ----load-data------------------------------------------------------------------------------

## Two options for accessing data - programmatic or from the example dataset
# Read data from data portal 

phe <- loadByProduct(dpID = "DP1.10055.001", site=c("BLAN","SCBI","SERC"), 
										 startdate = "2017-01", enddate="2019-12", 
										 token = Sys.getenv("NEON_TOKEN"),
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



## ----look-ind-------------------------------------------------------------------------------
# What are the fieldnames in this dataset?
names(ind)

# Unsure of what some of the variables are you? Look at the variables table!
View(phe$variables_10055)

# how many rows are in the data?
nrow(ind)

# look at the first six rows of data.
#head(ind) #this is a good function to use but looks messy so not rendering it 

# look at the structure of the dataframe.
str(ind)



## ----look-status----------------------------------------------------------------------------

# What variables are included in this dataset?
names(status)
nrow(status)
#head(status)   #this is a good function to use but looks messy so not rendering it 
str(status)

# date range
min(status$date)
max(status$date)



## ----remove-duplicates----------------------------------------------------------------------
# drop UID as that will be unique for duplicate records
ind_noUID <- select(ind, -(uid))

status_noUID <- select(status, -(uid))

# remove duplicates
## expect many

ind_noD <- distinct(ind_noUID)
nrow(ind_noD)

status_noD<-distinct(status_noUID)
nrow(status_noD)



## ----same-fieldnames------------------------------------------------------------------------

# where is there an intersection of names
intersect(names(status_noD), names(ind_noD))



## ----rename-column--------------------------------------------------------------------------

# in Status table rename like columns 
status_noD <- rename(status_noD, dateStat=date, 
										 editedDateStat=editedDate, measuredByStat=measuredBy, 
										 recordedByStat=recordedBy, 
										 samplingProtocolVersionStat=samplingProtocolVersion, 
										 remarksStat=remarks, dataQFStat=dataQF, 
										 publicationDateStat=publicationDate)


## ----filter-edit-date-----------------------------------------------------------------------
# retain only the max of the date for each individualID
ind_last <- ind_noD %>%
	group_by(individualID) %>%
	filter(editedDate==max(editedDate))

# oh wait, duplicate dates, retain only the most recent editedDate
ind_lastnoD <- ind_last %>%
	group_by(editedDate, individualID) %>%
	filter(row_number()==1)



## ----join-dfs-------------------------------------------------------------------------------

# Create a new dataframe "phe_ind" with all the data from status and some from ind_lastnoD
phe_ind <- left_join(status_noD, ind_lastnoD)



## ----filter-site----------------------------------------------------------------------------

# set site of interest
siteOfInterest <- "SCBI"

# use filter to select only the site of Interest 
## using %in% allows one to add a vector if you want more than one site. 
## could also do it with == instead of %in% but won't work with vectors

phe_1st <- filter(phe_ind, siteID %in% siteOfInterest)



## ----unique-species-------------------------------------------------------------------------

# see which species are present - taxon ID only
unique(phe_1st$taxonID)

# see which species are present - taxon ID + species name
unique(paste(phe_1st$taxonID, phe_1st$scientificName, sep=' - ')) 



## ----filter-species-------------------------------------------------------------------------
speciesOfInterest <- "LITU"

#subset to just "LITU"
# here just use == but could also use %in%
phe_1sp <- filter(phe_1st, taxonID==speciesOfInterest)

# check that it worked
unique(phe_1sp$taxonID)



## ----filter-phenophase----------------------------------------------------------------------

# see which phenophases are present
unique(phe_1sp$phenophaseName)

phenophaseOfInterest <- "Leaves"

#subset to just the phenosphase of interest 
phe_1sp <- filter(phe_1sp, phenophaseName %in% phenophaseOfInterest)

# check that it worked
unique(phe_1sp$phenophaseName)



## ----filter-plot-type-----------------------------------------------------------------------
# what plots are present?
unique(phe_1sp$subtypeSpecification)

# filter
phe_1spPrimary <- filter(phe_1sp, subtypeSpecification == 'primary')

# check that it worked
unique(phe_1spPrimary$subtypeSpecification)



## ----calc-total-yes-------------------------------------------------------------------------
# Calculate sample size for later use
sampSize <- phe_1spPrimary%>%
  group_by(dateStat)%>%
  summarize(numInd= n_distinct(individualID))

# Total in status by day for distinct individuals
inStat <- phe_1spPrimary%>%
  group_by(dateStat, phenophaseStatus)%>%
  summarize(countYes=n_distinct(individualID))

inStat <- full_join(sampSize, inStat, by="dateStat")

# Retain only Yes
inStat_T <- filter(inStat, phenophaseStatus %in% "yes")

# check that it worked
unique(inStat_T$phenophaseStatus)



## ----plot-leaves-total----------------------------------------------------------------------

# plot number of individuals in leaf
phenoPlot <- ggplot(inStat_T, aes(dateStat, countYes)) +
    geom_bar(stat="identity", na.rm = TRUE) 

phenoPlot


# Now let's make the plot look a bit more presentable
phenoPlot <- ggplot(inStat_T, aes(dateStat, countYes)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Total Individuals in Leaf") +
    xlab("Date") + ylab("Number of Individuals") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

phenoPlot



## ----plot-leaves-percentage-----------------------------------------------------------------

# convert to percent
inStat_T$percent<- ((inStat_T$countYes)/inStat_T$numInd)*100

# plot percent of leaves
phenoPlot_P <- ggplot(inStat_T, aes(dateStat, percent)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Proportion in Leaf") +
    xlab("Date") + ylab("% of Individuals") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

phenoPlot_P



## ----filter-to-2018-------------------------------------------------------------------------

# use filter to select only the date of interest 
phe_1sp_2018 <- filter(inStat_T, dateStat >= "2018-01-01" & dateStat <= "2018-12-31")

# did it work?
range(phe_1sp_2018$dateStat)



## ----plot-2018------------------------------------------------------------------------------

# Now let's make the plot look a bit more presentable
phenoPlot18 <- ggplot(phe_1sp_2018, aes(dateStat, countYes)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Total Individuals in Leaf") +
    xlab("Date") + ylab("Number of Individuals") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

phenoPlot18



## ----write-csv, eval=F----------------------------------------------------------------------
## # Write .csv - this step is optional
## # This will write to your current working directory, change as desired.
## write.csv( phe_1sp_2018 , file="NEONpheno_LITU_Leaves_SCBI_2018.csv", row.names=F)
## 
## #If you are using the downloaded example date, this code will write it to the
## # pheno data file.
## 
## #write.csv( phe_1sp_2016 , file="NEON-pheno-temp-timeseries/pheno/NEONpheno_LITU_Leaves_SCBI_2016.csv", row.names=F)
## 

