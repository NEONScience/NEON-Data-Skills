## ----setup-env--------------------------------------------------------------------------------------------
# Install needed package (only uncomment & run if not already installed)
#install.packages("neonUtilities")
#install.packages("ggplot2")
#install.packages("dplyr")
#install.packages("tidyr")


# Load required libraries
library(neonUtilities)  # for accessing NEON data
library(ggplot2)  # for plotting
library(dplyr)  # for data munging
library(tidyr)  # for data munging

# set working directory
# this step is optional, only needed if you plan to save the 
# data files at the end of the tutorial
wd <- "~/data" # enter your working directory here
setwd(wd)



## ----import-data, results="hide"--------------------------------------------------------------------------

# download data of interest - Single Aspirated Air Temperature
saat <- loadByProduct(dpID="DP1.00002.001", site="SCBI", 
                      startdate="2018-01", enddate="2018-12", 
                      package="basic", timeIndex="30",
                      check.size = F)



## ----data-structure---------------------------------------------------------------------------------------

View(saat)



## ----unlist-----------------------------------------------------------------------------------------------

list2env(saat, .GlobalEnv)



## ----contents---------------------------------------------------------------------------------------------

str(SAAT_30min)



## ----qf-data----------------------------------------------------------------------------------------------

sum(SAAT_30min$finalQF==1)/nrow(SAAT_30min)



## ----na-data----------------------------------------------------------------------------------------------

sum(is.na(SAAT_30min$tempSingleMean))/nrow(SAAT_30min)

mean(SAAT_30min$tempSingleMean)



## ----new-df-noNA------------------------------------------------------------------------------------------

# create new dataframe without NAs
SAAT_30min_noNA <- SAAT_30min %>%
	drop_na(tempSingleMean)  # tidyr function

# alternate base R
# SAAT_30min_noNA <- SAAT_30min[!is.na(SAAT_30min$tempSingleMean),]

# did it work?
sum(is.na(SAAT_30min_noNA$tempSingleMean))



## ----plot-temp, fig.cap="Scatter plot of mean temperatures for the year 2018 at the Smithsonian Conservation Biology Institute (SCBI). Plotted data shows erroneous sensor readings occured during late April/May 2018."----
# plot temp data
tempPlot <- ggplot(SAAT_30min, aes(startDateTime, tempSingleMean)) +
    geom_point(size=0.3) +
    ggtitle("Single Aspirated Air Temperature") +
    xlab("Date") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

tempPlot



## ----remove-qf-data---------------------------------------------------------------------------------------
# subset and add C to name for "clean"
SAAT_30minC <- filter(SAAT_30min_noNA, SAAT_30min_noNA$finalQF==0)

# Do any quality flags remain?
sum(SAAT_30minC$finalQF==1)



## ----plot-temp-clean, fig.cap="Scatter plot of mean temperatures for the year 2018 at the Smithsonian Conservation Biology Institute (SCBI). Plotted data now has been cleaned of the erroneous sensor readings by filtering out flagged data."----
# plot temp data
tempPlot <- ggplot(SAAT_30minC, aes(startDateTime, tempSingleMean)) +
    geom_point(size=0.3) +
    ggtitle("Single Aspirated Air Temperature") +
    xlab("Date") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

tempPlot



## ----daily-max-dplyr--------------------------------------------------------------------------------------

# convert to date, easier to work with
SAAT_30minC$Date <- as.Date(SAAT_30minC$startDateTime)

# max of mean temp each day
temp_day <- SAAT_30minC %>%
	group_by(Date) %>%
	distinct(Date, .keep_all=T) %>%
	mutate(dayMax=max(tempSingleMaximum))



## ----daily-max-plot, fig.cap="Scatter plot of daily maximum temperatures(of 30 minute interval means) for the year 2018 at the Smithsonian Conservation Biology Institute (SCBI)."----

# plot Air Temperature Data across 2018 using daily data
tempPlot_dayMax <- ggplot(temp_day, aes(Date, dayMax)) +
    geom_point(size=0.5) +
    ggtitle("Daily Max Air Temperature") +
    xlab("") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

tempPlot_dayMax



## ----subset-ggplot-time, fig.cap="Scatter plot showing daily maximum temperatures(of 30 minute interval means) from the beginning of January 2018 through the end of March 2018 at the Smithsonian Conservation Biology Institute (SCBI)."----

# Define Start and end times for the subset as R objects that are the time class
startTime <- as.Date("2018-01-01")
endTime <- as.Date("2018-03-31")

# create a start and end time R object
start.end <- c(startTime,endTime)
str(start.end)

# View data for first 3 months only
# And we'll add some color for a change. 
tempPlot_dayMax3m <- ggplot(temp_day, aes(Date, dayMax)) +
           geom_point(color="blue", size=0.5) +  
           ggtitle("Air Temperature\n Jan - March") +
           xlab("Date") + ylab("Air Temperature (C)")+ 
           (scale_x_date(limits=start.end, 
                date_breaks="1 week",
                date_labels="%b %d"))
 
tempPlot_dayMax3m




## ----write-csv, eval = FALSE------------------------------------------------------------------------------
## 
## # Write .csv - this step is optional
## # This will write to the working directory we set at the start of the tutorial
## write.csv(temp_day , file="NEONsaat_daily_SCBI_2018.csv", row.names=F)
## 

