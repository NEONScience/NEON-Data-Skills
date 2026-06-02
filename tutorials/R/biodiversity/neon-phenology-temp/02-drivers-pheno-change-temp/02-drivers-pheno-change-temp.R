## ----setup-env------------------------------------------------------------------------------------------------------------
# Install needed package (only uncomment & run if not already installed)
#install.packages("neonUtilities")
#install.packages("ggplot2")
#install.packages("dplyr")
#install.packages("tidyr")


# Load required libraries
library(neonUtilities)
library(ggplot2)
library(dplyr)
library(tidyr)
library(lubridate)
token <- Sys.getenv("NEON_TOKEN")

# set working directory, modify as needed
wd <- "~/data"
setwd(wd)



## ----import-data, results="hide", message=FALSE---------------------------------------------------------------------------

saat <- loadByProduct(dpID="DP1.00002.001", 
                      site="SCBI", 
                      startdate="2018-01", 
                      enddate="2018-12", 
                      package="basic", 
                      timeIndex="30",
                      release="RELEASE-2026",
                      check.size = F,
                      token=token)



## ----data-structure-------------------------------------------------------------------------------------------------------

names(saat)



## ----unlist---------------------------------------------------------------------------------------------------------------

list2env(saat, .GlobalEnv)



## ----contents-------------------------------------------------------------------------------------------------------------

str(SAAT_30min)



## ----qf-data--------------------------------------------------------------------------------------------------------------

sum(SAAT_30min$finalQF==1)/nrow(SAAT_30min)



## ----na-data--------------------------------------------------------------------------------------------------------------

sum(is.na(SAAT_30min$tempSingleMean))/nrow(SAAT_30min)

mean(SAAT_30min$tempSingleMean)



## ----new-df-noNA----------------------------------------------------------------------------------------------------------

SAAT_30min_noNA <- SAAT_30min %>%
	drop_na(tempSingleMean)

sum(is.na(SAAT_30min_noNA$tempSingleMean))



## ----plot-temp, fig.cap="Scatter plot of mean temperatures for the year 2018 at the Smithsonian Conservation Biology Institute (SCBI). Plotted data shows erroneous sensor readings occured during late April/May 2018."----

tempPlot <- ggplot(SAAT_30min, 
                   aes(startDateTime, 
                       tempSingleMean)) +
    geom_point(size=0.2) +
    ggtitle("Single Aspirated Air Temperature") +
    xlab("Date") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, 
                                    face="bold", 
                                    size = 20)) +
    theme(text = element_text(size=18))

tempPlot



## ----remove-qf-data-------------------------------------------------------------------------------------------------------

SAAT_30minC <- SAAT_30min_noNA %>%
  filter(finalQF==0)



## ----plot-temp-clean, fig.cap="Scatter plot of mean temperatures for the year 2018 at the Smithsonian Conservation Biology Institute (SCBI). Plotted data now has been cleaned of the erroneous sensor readings by filtering out flagged data."----

tempPlot <- ggplot(SAAT_30minC, 
                   aes(startDateTime, 
                       tempSingleMean)) +
    geom_point(size=0.2) +
    ggtitle("Single Aspirated Air Temperature") +
    xlab("Date") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, 
                                    face="bold", 
                                    size = 20)) +
    theme(text = element_text(size=18))

tempPlot



## ----daily-max-dplyr------------------------------------------------------------------------------------------------------

temp_day <- SAAT_30minC %>%
	group_by(date(startDateTime)) %>%
	distinct(date(startDateTime), .keep_all=T) %>%
	mutate(dayMax=max(tempSingleMaximum))



## ----daily-max-plot, fig.cap="Scatter plot of daily maximum temperatures(of 30 minute interval means) for the year 2018 at the Smithsonian Conservation Biology Institute (SCBI)."----

tempPlot_dayMax <- ggplot(temp_day, 
                          aes(startDateTime, 
                              dayMax)) +
    geom_point(size=0.5) +
    ggtitle("Daily Max Air Temperature") +
    xlab("") + ylab("Temp (C)") +
    theme(plot.title = element_text(lineheight=.8, 
                                    face="bold", 
                                    size = 20)) +
    theme(text = element_text(size=18))

tempPlot_dayMax



## ----subset-ggplot-time, fig.cap="Scatter plot showing daily maximum temperatures(of 30 minute interval means) from the beginning of January 2018 through the end of March 2018 at the Smithsonian Conservation Biology Institute (SCBI)."----

# Define Start and end times for the subset
startTime <- as.Date("2018-01-01")
endTime <- as.Date("2018-03-31")

start.end <- c(startTime,endTime)

tempPlot_dayMax3m <- ggplot(temp_day, 
                            aes(startDateTime, 
                                dayMax)) +
           geom_point(color="blue", size=0.5) +  
           ggtitle("Air Temperature\n Jan - March") +
           xlab("Date") + ylab("Air Temperature (C)")+ 
           (scale_x_date(limits=start.end, 
                date_breaks="1 week",
                date_labels="%b %d"))
 
tempPlot_dayMax3m




## ----write-csv, eval = FALSE----------------------------------------------------------------------------------------------
# 
# # optional
# write.csv(temp_day, file="NEONsaat_daily_SCBI_2018.csv", row.names=F)
# 

