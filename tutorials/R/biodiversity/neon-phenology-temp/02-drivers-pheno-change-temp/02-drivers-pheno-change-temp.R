## ----import-data--------------------------------------------------------------------------

# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(lubridate)
library(scales)

# set working directory to ensure R can find the file we wish to import
# setwd("working-dir-path-here")

# Read in data
temp30_sites <- read.csv('NEON-pheno-temp-timeseries/temp/SAAT_30min.csv', stringsAsFactors = FALSE)



## ----data-structure-----------------------------------------------------------------------
# Get a general feel for the data: View structure of data frame
str(temp30_sites)


## ----filter-site--------------------------------------------------------------------------

# set site of interest
siteOfInterest <- c("SCBI")

# use filter to select only the site of Interest 
# using %in% allows one to add a vector if you want more than one site. 
temp30 <- filter(temp30_sites, siteID%in%siteOfInterest)



## ----qf-data------------------------------------------------------------------------------

# Are there quality flags in your data? Count 'em up

sum(temp30$finalQF==1)



## ----na-data------------------------------------------------------------------------------

# Are there NA's in your data? Count 'em up
sum(is.na(temp30$tempSingleMean) )

mean(temp30$tempSingleMean)


## ----new-df-noNA--------------------------------------------------------------------------

# create new dataframe without NAs
temp30_noNA <- temp30 %>%
	drop_na(tempSingleMean)  # tidyr function

# alternate base R
# temp30_noNA <- temp30[!is.na(temp30$tempSingleMean),]

# did it work?
sum(is.na(temp30_noNA$tempSingleMean))



## ----convert-date-time--------------------------------------------------------------------

# View the date range
range(temp30_noNA$startDateTime)

# what format are they in? 
str(temp30_noNA$startDateTime)


## ----explore-POSIXct----------------------------------------------------------------------
# Convert character data to date and time.
timeDate <- as.POSIXct("2015-10-19 10:15")   
str(timeDate)
timeDate



## ----explore-POSIXct2---------------------------------------------------------------------
# to see the data in this 'raw' format, i.e., not formatted according to the 
# class type to show us a date we recognize, use the `unclass()` function.
unclass(timeDate)



## ----explore-POSIXlt----------------------------------------------------------------------
# Convert character data to POSIXlt date and time
timeDatelt<- as.POSIXlt("2015-10-19 10:15")  
str(timeDatelt)
timeDatelt

unclass(timeDatelt)


## ----view-date----------------------------------------------------------------------------
# view one date-time field
temp30_noNA$startDateTime[1]


## ----convert-datetime---------------------------------------------------------------------
# convert to Date Time 
temp30_noNA$startDateTime <- as.POSIXct(temp30_noNA$startDateTime,
																				format = "%Y-%m-%dT%H:%M:%SZ", tz = "GMT")
# check that conversion worked
str(temp30_noNA$startDateTime)


## ----covert-localtz-----------------------------------------------------------------------

## Convert to Local Time Zone 

## Conver to local TZ in new column
temp30_noNA$dtLocal <- format(temp30_noNA$startDateTime, 
															tz="America/New_York", usetz=TRUE)

## check it
head(select(temp30_noNA, startDateTime, dtLocal))



## ----subset-date--------------------------------------------------------------------------
# Limit dataset to dates of interest (2016-01-01 to 2016-12-31)
# alternatively could use ">=" and start with 2016-01-01 00:00
temp30_TOI <- filter(temp30_noNA, dtLocal>"2015-12-31 23:59")

# View the date range
range(temp30_TOI$dtLocal)



## ----plot-temp----------------------------------------------------------------------------
# plot temp data
tempPlot <- ggplot(temp30_TOI, aes(dtLocal, tempSingleMean)) +
    geom_point() +
    ggtitle("Single Asperated Air Temperature") +
    xlab("Date") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

tempPlot



## ----daily-max-dplyr----------------------------------------------------------------------

# convert to date, easier to work with
temp30_TOI$sDate <- as.Date(temp30_TOI$dtLocal)

# did it work
str(temp30_TOI$sDate)

# max of mean temp each day
temp_day <- temp30_TOI %>%
	group_by(sDate) %>%
	distinct(sDate, .keep_all=T) %>%
	mutate(dayMax=max(tempSingleMean))



## ----basic-ggplot2------------------------------------------------------------------------

# plot Air Temperature Data across 2016 using daily data
tempPlot_dayMax <- ggplot(temp_day, aes(sDate, dayMax)) +
    geom_point() +
    ggtitle("Daily Max Air Temperature") +
    xlab("") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

tempPlot_dayMax



## ----subset-ggplot-time-------------------------------------------------------------------

# Define Start and end times for the subset as R objects that are the time class
startTime <- as.Date("2016-01-01")
endTime <- as.Date("2016-03-31")

# create a start and end time R object
start.end <- c(startTime,endTime)
str(start.end)

# View data for first 3 months only
# And we'll add some color for a change. 
tempPlot_dayMax3m <- ggplot(temp_day, aes(sDate, dayMax)) +
           geom_point(color="blue", size=1) +  # defines what points look like
           ggtitle("Air Temperature\n Jan - March") +
           xlab("Date") + ylab("Air Temperature (C)")+ 
           (scale_x_date(limits=start.end, 
                date_breaks="1 week",
                date_labels="%b %d"))
 
tempPlot_dayMax3m




## ----write-csv, echo=FALSE----------------------------------------------------------------
# Write .csv (this will be read in new in subsuquent lessons)
write.csv(temp_day, file="NEON-pheno-temp-timeseries/temp/NEONsaat_daily_SCBI_2016.csv", row.names=F)

