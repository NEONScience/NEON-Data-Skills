## ----setup, include=FALSE-------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----setup-env------------------------------------------------------------------------------
# Install needed package (only uncomment & run if not already installed)
#install.packages("ggplot2")`
#install.packages("dplyr")`
#install.packages("tidyr")`
#install.packages("lubridate")`
#install.packages("scales")`

# Load required libraries

library(ggplot2)  # for plotting
library(dplyr)  # for data munging
library(tidyr)  # for data munging
library(lubridate)
library(scales)

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. Be sure to move the download into your working directory!
wd <- "~/Documents/data/" # Change this to match your local environment
setwd(wd)


## ----import-data----------------------------------------------------------------------------

# download data of interest - Nitrate in Suface Water
saat<-loadByProduct(dpID="DP1.00002.001", site="SCBI", 
										startdate="2018-01", enddate="2018-12", 
										package="basic", 
										avg = "30",
										token = Sys.getenv("NEON_TOKEN"),
										check.size = F)



## ----data-structure-------------------------------------------------------------------------
# View the list
View(saat)


## ----unlist---------------------------------------------------------------------------------

# assign individual dataFrames in the list as an object
#SAAT_30min <- saat$SAAT_30min

# unlist all objects
list2env(saat, .GlobalEnv)



## ----contents-------------------------------------------------------------------------------

# what is in the data?
str(SAAT_30min)



## ----qf-data--------------------------------------------------------------------------------

# Are there quality flags in your data? Count 'em up

sum(SAAT_30min$finalQF==1)



## ----na-data--------------------------------------------------------------------------------

# Are there NA's in your data? Count 'em up
sum(is.na(SAAT_30min$tempSingleMean) )

mean(SAAT_30min$tempSingleMean)


## ----new-df-noNA----------------------------------------------------------------------------

# create new dataframe without NAs
SAAT_30min_noNA <- SAAT_30min %>%
	drop_na(tempSingleMean)  # tidyr function

# alternate base R
# SAAT_30min_noNA <- SAAT_30min[!is.na(SAAT_30min$tempSingleMean),]

# did it work?
sum(is.na(SAAT_30min_noNA$tempSingleMean))



## ----plot-temp------------------------------------------------------------------------------
# plot temp data
tempPlot <- ggplot(SAAT_30min, aes(startDateTime, tempSingleMean)) +
    geom_point() +
    ggtitle("Single Asperated Air Temperature") +
    xlab("Date") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

tempPlot



## ----remove-qf-data-------------------------------------------------------------------------
# subset abd add C to name for "clean"
SAAT_30minC <- filter(SAAT_30min_noNA, SAAT_30min_noNA$finalQF==0)

# Do any quality flags remain? Count 'em up
sum(SAAT_30minC$finalQF==1)



## ----plot-temp-clean------------------------------------------------------------------------
# plot temp data
tempPlot <- ggplot(SAAT_30minC, aes(startDateTime, tempSingleMean)) +
    geom_point() +
    ggtitle("Single Asperated Air Temperature") +
    xlab("Date") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

tempPlot



## ----daily-max-dplyr------------------------------------------------------------------------

# convert to date, easier to work with
SAAT_30minC$Date <- as.Date(SAAT_30minC$startDateTime)

# did it work
str(SAAT_30minC$Date)

# max of mean temp each day
temp_day <- SAAT_30minC %>%
	group_by(Date) %>%
	distinct(Date, .keep_all=T) %>%
	mutate(dayMax=max(tempSingleMean))



## ----daily-max-plot-------------------------------------------------------------------------

# plot Air Temperature Data across 2018 using daily data
tempPlot_dayMax <- ggplot(temp_day, aes(Date, dayMax)) +
    geom_point() +
    ggtitle("Daily Max Air Temperature") +
    xlab("") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

tempPlot_dayMax



## ----subset-ggplot-time---------------------------------------------------------------------

# Define Start and end times for the subset as R objects that are the time class
startTime <- as.Date("2018-01-01")
endTime <- as.Date("2018-03-31")

# create a start and end time R object
start.end <- c(startTime,endTime)
str(start.end)

# View data for first 3 months only
# And we'll add some color for a change. 
tempPlot_dayMax3m <- ggplot(temp_day, aes(Date, dayMax)) +
           geom_point(color="blue", size=1) +  # defines what points look like
           ggtitle("Air Temperature\n Jan - March") +
           xlab("Date") + ylab("Air Temperature (C)")+ 
           (scale_x_date(limits=start.end, 
                date_breaks="1 week",
                date_labels="%b %d"))
 
tempPlot_dayMax3m




## ----write-csv, echo=FALSE------------------------------------------------------------------
# Write .csv (this will be read in new in subsuquent lessons)
write.csv(temp_day, file="NEON-pheno-temp-timeseries/temp/NEONsaat_daily_SCBI_2018.csv", row.names=F)

