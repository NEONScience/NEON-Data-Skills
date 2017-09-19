## ----read-in-files-------------------------------------------------------
# Remember it is good coding technique to add additional libraries to the top of
# your script 

library(lubridate) # for working with dates
library(ggplot2)  # for creating graphs
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(grid)   # for arrangeing plots
library(dplyr)  # for subsetting by season

# set working directory to ensure R can find the file we wish to import
# setwd("working-dir-path-here")

# read in the Harvard micro-meteorological data; if you don't already have it
harMetDaily.09.11 <- read.csv(
  file="NEON-DS-Met-Time-Series/HARV/FisherTower-Met/Met_HARV_Daily_2009_2011.csv",
  stringsAsFactors = FALSE
  )

#check out the data
str(harMetDaily.09.11)

# read in the NDVI CSV data; if you dont' already have it 
NDVI.2011 <- read.csv(
  file="NEON-DS-Met-Time-Series/HARV/NDVI/meanNDVI_HARV_2011.csv", 
  stringsAsFactors = FALSE
  )

# check out the data
str(NDVI.2011)

## ----challenge-code-convert-date, include=TRUE, results="hide", echo=FALSE----

# check to see class of date field
class(NDVI.2011$Date)
class(harMetDaily.09.11$date)

# convert chr class Date to date class Date
NDVI.2011$Date<- as.Date(NDVI.2011$Date)
harMetDaily.09.11$date<- as.Date(harMetDaily.09.11$date)

# confirm conversion
class(NDVI.2011$Date)
class(harMetDaily.09.11$date)

# 2
# Use dplyr to subset only 2011 data
harMet.daily2011 <- harMetDaily.09.11 %>% 
  mutate(year = year(date)) %>%   #need to create a year only column first
  filter(year == "2011")

# convert data from POSIX class to Date class; both "date" vars. now Date class
harMet.daily2011$date<-as.Date(harMet.daily2011$date)

## ----plot-NDVI-----------------------------------------------------------
# plot NDVI by date
ggplot(NDVI.2011, aes(Date, meanNDVI))+
  geom_point(colour = "forestgreen", size = 4) +
  ggtitle("Daily NDVI at Harvard Forest, 2011")+
  theme(legend.position = "none",
        plot.title = element_text(lineheight=.8, face="bold",size = 20),
        text = element_text(size=20))


## ----plot-PAR-NDVI, echo=FALSE-------------------------------------------

# plot NDVI again
plot.NDVI.2011 <- ggplot(NDVI.2011, aes(Date, meanNDVI))+
  geom_point(colour = "forestgreen", size = 4) +
  ggtitle("Daily NDVI at Harvard Forest, 2011")+
  theme(legend.position = "none",
        plot.title = element_text(lineheight=.8, face="bold",size = 20),
        text = element_text(size=20))

# create plot of julian day vs. PAR
plot.par.2011 <- ggplot(harMet.daily2011, aes(date, part))+
  geom_point(na.rm=TRUE) +
  ggtitle("Daily PAR at Harvard Forest, 2011")+
  theme(legend.position = "none",
        plot.title = element_text(lineheight=.8, face="bold",size = 20),
        text = element_text(size=20))

# display the plots together
grid.arrange(plot.par.2011, plot.NDVI.2011) 

## ----plot-same-xaxis-----------------------------------------------------
# plot PAR
plot2.par.2011 <- plot.par.2011 +
               scale_x_date(labels = date_format("%b %d"),
               date_breaks = "3 months",
               date_minor_breaks= "1 week",
               limits=c(min=min(NDVI.2011$Date),max=max(NDVI.2011$Date))) +
               ylab("Total PAR") + xlab ("")

# plot NDVI
plot2.NDVI.2011 <- plot.NDVI.2011 +
               scale_x_date(labels = date_format("%b %d"),
               date_breaks = "3 months", 
               date_minor_breaks= "1 week",
               limits=c(min=min(NDVI.2011$Date),max=max(NDVI.2011$Date)))+
               ylab("Total NDVI") + xlab ("Date")

# Output with both plots
grid.arrange(plot2.par.2011, plot2.NDVI.2011) 


## ----challengeplot-same-xaxis, echo=FALSE--------------------------------
# 1
# plot air temp
plot.airt.2011 <- ggplot(harMet.daily2011, aes(date, airt))+
  geom_point(colour="darkblue", na.rm=TRUE) +
  ggtitle("Average Air Temperature\n Harvard Forest 2011")+
  scale_x_date(labels = date_format("%b %d"),
               date_breaks = "3 months", date_minor_breaks= "1 week",
               limits=c(min(NDVI.2011$Date),max=max(NDVI.2011$Date)))+
  ylab("Celcius") + xlab ("")+
  theme(legend.position = "none",
        plot.title = element_text(lineheight=.8, face="bold",size = 20),
        text = element_text(size=20))

plot.airt.2011

# 2 output with all 3 together
grid.arrange(plot2.par.2011, plot.airt.2011, plot2.NDVI.2011) 

