## ----set-up, warning=FALSE, message=FALSE---------------------------------------------------------------------------------
# install needed package (only uncomment & run if not already installed)
#install.packages("neonUtilities")
#install.packages("dplyr")
#install.packages("ggplot2")

# load needed packages
library(neonUtilities)
library(neonOS)
library(dplyr)
library(ggplot2)
token <- Sys.getenv("NEON_TOKEN")

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. Be sure to move the download into your working directory!
wd <- "~/data" # Change this to match your local environment
setwd(wd)



## ----load-data, message=FALSE, results="hide"-----------------------------------------------------------------------------

phe <- loadByProduct(dpID = "DP1.10055.001", 
                     site=c("BLAN","SCBI","SERC"), 
										 startdate = "2017-01", 
										 enddate="2019-12", 
										 release="RELEASE-2026",
										 token=token,
										 check.size = F) 

# save dataframes from the downloaded list
ind <- phe$phe_perindividual  #individual information
status <- phe$phe_statusintensity  #status & intensity info



## ----look-ind-------------------------------------------------------------------------------------------------------------
# What are the fieldnames in this dataset?
names(ind)

# Unsure of what some of the variables are? Look at the variables table!
View(phe$variables_10055)

# how many rows are in the data?
nrow(ind)

# look at the first six rows of data.
head(ind)

# look at the structure of the dataframe.
str(ind)



## ----look-status----------------------------------------------------------------------------------------------------------

# What variables are included in this dataset?
names(status)
nrow(status)
head(status)
str(status)

# date range
min(status$date)
max(status$date)



## ----remove-duplicates----------------------------------------------------------------------------------------------------

ind_noD <- removeDups(ind, 
                      variables=phe$variables_10055,
                      table="phe_perindividual")

status_noD <- removeDups(status,
                         variables=phe$variables_10055,
                         table="phe_statusintensity")



## ----filter-edit-date-----------------------------------------------------------------------------------------------------

ind_last <- ind_noD %>%
	group_by(individualID) %>%
	filter(editedDate==max(editedDate))



## ----same-fieldnames------------------------------------------------------------------------------------------------------

intersect(names(status_noD), 
          names(ind_last))



## ----rename-column--------------------------------------------------------------------------------------------------------

status_noD <- status_noD %>%
  rename(uidStat=uid, dateStat=date, 
         editedDateStat=editedDate, 
         measuredByStat=measuredBy, 
         recordedByStat=recordedBy, 
         samplingProtocolVersionStat=samplingProtocolVersion, 
         remarksStat=remarks, 
         dataQFStat=dataQF, 
         publicationDateStat=publicationDate)


## ----join-dfs-------------------------------------------------------------------------------------------------------------

phe_ind <- left_join(status_noD, 
                     ind_last)



## ----fix-dates------------------------------------------------------------------------------------------------------------

if(class(phe_ind$date)=="character") {
  phe_ind$date <- as.POSIXct(phe_ind$date,
                             format="%Y-%m-%d",
                             tz="GMT")
}

if(class(phe_ind$dateStat)=="character") {
  phe_ind$dateStat <- as.POSIXct(phe_ind$dateStat,
                             format="%Y-%m-%d",
                             tz="GMT")
}



## ----filter-site----------------------------------------------------------------------------------------------------------

siteOfInterest <- "SCBI"

## using %in% allows one to add a vector if you want more than one site. 
## could also do it with == but won't work with vectors

phe_1st <- phe_ind %>% 
  filter(siteID %in% siteOfInterest)



## ----unique-species-------------------------------------------------------------------------------------------------------

unique(phe_1st$taxonID)

unique(paste(phe_1st$taxonID, 
             phe_1st$scientificName, 
             sep=' - ')) 



## ----filter-species-------------------------------------------------------------------------------------------------------
speciesOfInterest <- "LITU"

phe_1sp <- phe_1st %>%
  filter(taxonID==speciesOfInterest)

# check that it worked
unique(phe_1sp$taxonID)



## ----filter-phenophase----------------------------------------------------------------------------------------------------

# see which phenophases are present
unique(phe_1sp$phenophaseName)

phenophaseOfInterest <- "Leaves"

# subset to just the phenophase of interest 
phe_1sp <- phe_1sp %>%
  filter(phenophaseName %in% phenophaseOfInterest)

# check that it worked
unique(phe_1sp$phenophaseName)



## ----filter-plot-type-----------------------------------------------------------------------------------------------------
# what plots are present?
unique(phe_1sp$subtypeSpecification)

# filter
phe_1spPrimary <- phe_1sp %>%
  filter(subtypeSpecification == 'primary')

# check that it worked
unique(phe_1spPrimary$subtypeSpecification)



## ----calc-total-yes-------------------------------------------------------------------------------------------------------

sampSize <- phe_1spPrimary %>%
  group_by(dateStat) %>%
  summarise(numInd=n_distinct(individualID))

inStat <- phe_1spPrimary %>%
  group_by(dateStat, phenophaseStatus) %>%
  summarise(countYes=n_distinct(individualID))

inStat <- full_join(sampSize, 
                    inStat, 
                    by="dateStat")

# Retain only Yes
inStat_T <- inStat %>% 
  filter(phenophaseStatus %in% "yes")

# check that it worked
unique(inStat_T$phenophaseStatus)



## ----plot-leaves-total, fig.cap=c("Bar plot showing the count of Liriodendrum tulipifera (LITU) individuals from January 2017 through December 2019 at the Smithsonian Conservation Biology Institute (SCBI). Counts represent individuals that were recorded as a 'yes' for the phenophase of interest,'Leaves', and were from the primary plots.","Bar plot showing the count of Liriodendrum tulipifera (LITU) individuals from January 2017 through December 2019 at the Smithsonian Conservation Biology Institute (SCBI). Counts represent individuals that were recorded as a 'yes' for the phenophase of interest,'Leaves', and were from the primary plots. Axis labels and title have been added to make the graph more presentable.")----

# plot number of individuals in leaf
phenoPlot <- ggplot(inStat_T, 
                    aes(dateStat, countYes)) +
    geom_bar(stat="identity", na.rm = TRUE) 

phenoPlot


# Now let's make the plot look a bit more presentable
phenoPlot <- ggplot(inStat_T, 
                    aes(dateStat, countYes)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Total Individuals in Leaf") +
    xlab("Date") + ylab("Number of Individuals") +
    theme(plot.title = element_text(lineheight=.8, 
                                    face="bold", 
                                    size = 20)) +
    theme(text = element_text(size=18))

phenoPlot



## ----plot-leaves-percentage, fig.cap="It might also be useful to visualize the data in different ways while exploring the data. As such, before plotting, we can convert our count data into a percentage by writting an expression that divides the number of individuals with a 'yes' for the phenophase of interest, 'Leaves', by the total number of individuals and then multiplies the result by 100. Using this newly generated dataset of percentages, we can plot the data similarly to how we did in the previous plot. Only this time, the y-axis range goes from 0 to 100 to reflect the percentage data we just generated. The resulting plot now shows a bar plot of the proportion of Liriodendrum tulipifera (LITU) individuals from January 2017 through December 2019 at the Smithsonian Conservation Biology Institute (SCBI). The y-axis represents the percent of individuals that were recorded as a 'yes' for the phenophase of interest,'Leaves', and were from the primary plots."----

# convert to percent
inStat_T$percent <- ((inStat_T$countYes)/
                       inStat_T$numInd)*100

# plot percent of leaves
phenoPlot_P <- ggplot(inStat_T, 
                      aes(dateStat, percent)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Proportion in Leaf") +
    xlab("Date") + ylab("% of Individuals") +
    theme(plot.title = element_text(lineheight=.8, 
                                    face="bold", 
                                    size = 20)) +
    theme(text = element_text(size=18))

phenoPlot_P



## ----filter-to-2018-------------------------------------------------------------------------------------------------------

# use filter to select only the date of interest 
phe_1sp_2018 <- inStat_T %>% 
  filter(dateStat >= "2018-01-01" & 
           dateStat <= "2018-12-31")

# did it work?
range(phe_1sp_2018$dateStat)



## ----plot-2018, fig.cap="In the previous step, we filtered our data by date to only include data from 2018. Reviewing the newly generated dataset we get a bar plot showing the count of Liriodendrum tulipifera (LITU) individuals at the Smithsonian Conservation Biology Institute (SCBI) for the year 2018. Counts represent individuals that were recorded as a 'yes' for the phenophase of interest,'Leaves', and were from the primary plots."----

# Now let's make the plot look a bit more presentable
phenoPlot18 <- ggplot(phe_1sp_2018, 
                      aes(dateStat, countYes)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Total Individuals in Leaf") +
    xlab("Date") + ylab("Number of Individuals") +
    theme(plot.title = element_text(lineheight=.8, 
                                    face="bold", 
                                    size = 20)) +
    theme(text = element_text(size=18))

phenoPlot18



## ----write-csv, eval=F----------------------------------------------------------------------------------------------------
# 
# # optional
# write.csv(phe_1sp_2018 ,
#           file="NEONpheno_LITU_Leaves_SCBI_2018.csv",
#           row.names=F)
# 

