## ----load-data-------------------------------------------------------
# Remember it is good coding technique to add additional packages to the top of
# your script 
library(lubridate) # for working with dates
library(ggplot2)  # for creating graphs
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots

# set working directory to ensure R can find the file we wish to import
wd <- "~/Git/data/"

# daily HARV met data, 2009-2011
harMetDaily.09.11 <- read.csv(
  file=paste0(wd,"NEON-DS-Met-Time-Series/HARV/FisherTower-Met/Met_HARV_Daily_2009_2011.csv"),
  stringsAsFactors = FALSE)

# covert date to Date class
harMetDaily.09.11$date <- as.Date(harMetDaily.09.11$date)

# monthly HARV temperature data, 2009-2011
harTemp.monthly.09.11<-read.csv(
  file=paste0(wd,"NEON-DS-Met-Time-Series/HARV/FisherTower-Met/Temp_HARV_Monthly_09_11.csv"),
  stringsAsFactors=FALSE
  )

# datetime field is actually just a date 
#str(harTemp.monthly.09.11) 

# convert datetime from chr to date class & rename date for clarification
harTemp.monthly.09.11$date <- as.Date(harTemp.monthly.09.11$datetime)


## ----qplot, fig.cap="A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011"----
# plot air temp
qplot(x=date, y=airt,
      data=harMetDaily.09.11, na.rm=TRUE,
      main="Air temperature Harvard Forest\n 2009-2011",
      xlab="Date", ylab="Temperature (°C)")


## ----basic-ggplot2, fig.cap="A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011"----
# plot Air Temperature Data across 2009-2011 using daily data
ggplot(harMetDaily.09.11, aes(date, airt)) +
           geom_point(na.rm=TRUE)



## ----basic-ggplot2-colors, fig.cap="A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011. The plotting points are now colored blue."----
# plot Air Temperature Data across 2009-2011 using daily data
ggplot(harMetDaily.09.11, aes(date, airt)) +
           geom_point(na.rm=TRUE, color="blue", size=3, pch=18)



## ----basic-ggplot2-labels, fig.cap="A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011. The plotting points are now colored blue and axis labels have been specified."----
# plot Air Temperature Data across 2009-2011 using daily data
ggplot(harMetDaily.09.11, aes(date, airt)) +
           geom_point(na.rm=TRUE, color="blue", size=1) + 
           ggtitle("Air Temperature 2009-2011\n NEON Harvard Forest Field Site") +
           xlab("Date") + ylab("Air Temperature (C)")



## ----basic-ggplot2-labels-named, fig.cap="A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011. The plotting points are now colored purple and axis labels have been specified."----
# plot Air Temperature Data across 2009-2011 using daily data
AirTempDaily <- ggplot(harMetDaily.09.11, aes(date, airt)) +
           geom_point(na.rm=TRUE, color="purple", size=1) + 
           ggtitle("Air Temperature\n 2009-2011\n NEON Harvard Forest") +
           xlab("Date") + ylab("Air Temperature (C)")

# render the plot
AirTempDaily



## ----format-x-axis-labels, fig.cap="A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011. The plotting points are now colored purple and axis ticks and labels have been specified."----
# format x-axis: dates
AirTempDailyb <- AirTempDaily + 
  (scale_x_date(labels=date_format("%b %y")))

AirTempDailyb


## ----format-x-axis-label-ticks, fig.cap=c("A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011. The plotting points are now colored purple, axis labels are specified, and axis ticks are shown at 6 month intervals with user specified formatting.","A scatterplot showing the relationship between time and daily air temperature at  Harvard Forest between 2009 and 2011. The plotting points are now colored purple, axis labels are specified, and axis ticks are shown at yearly intervals with user specified formatting.")----
# format x-axis: dates
AirTempDaily_6mo <- AirTempDaily + 
    (scale_x_date(breaks=date_breaks("6 months"),
      labels=date_format("%b %y")))

AirTempDaily_6mo

# format x-axis: dates
AirTempDaily_1y <- AirTempDaily + 
    (scale_x_date(breaks=date_breaks("1 year"),
      labels=date_format("%b %y")))

AirTempDaily_1y



## ----subset-ggplot-time, fig.cap="A scatterplot showing the relationship between time and daily air temperature at Harvard Forest for the year 2009. The plotting points are now colored purple, axis labels are specified, and axis ticks are shown at yearly intervals with user specified formatting."----

# Define Start and end times for the subset as R objects that are the time class
startTime <- as.Date("2011-01-01")
endTime <- as.Date("2012-01-01")

# create a start and end time R object
start.end <- c(startTime,endTime)
start.end

# View data for 2011 only
# We will replot the entire plot as the title has now changed.
AirTempDaily_2011 <- ggplot(harMetDaily.09.11, aes(date, airt)) +
           geom_point(na.rm=TRUE, color="purple", size=1) + 
           ggtitle("Air Temperature\n 2011\n NEON Harvard Forest") +
           xlab("Date") + ylab("Air Temperature (C)")+ 
           (scale_x_date(limits=start.end,
                             breaks=date_breaks("1 year"),
                             labels=date_format("%b %y")))

AirTempDaily_2011



## ----nice-font, fig.cap="A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011. The plotting points are now colored purple, axis labels are specified, axis ticks are shown at yearly intervals with user specified formatting and the background is now white instead of grey."----
# Apply a black and white stock ggplot theme
AirTempDaily_bw<-AirTempDaily_1y +
  theme_bw()

AirTempDaily_bw


## ----install-new-themes, fig.cap=c("A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011. The plotting points are now colored purple, axis labels are specified, axis ticks are shown at yearly intervals with user specified formatting and the background is now blue instead of grey and has white grid marks.","A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011. The plotting points are now colored purple, axis labels are specified, axis ticks are shown at yearly intervals with user specified formatting and the background is now white instead of grey, has grey grid marks and a blue border.")----
# install additional themes
# install.packages('ggthemes', dependencies = TRUE)
library(ggthemes)
AirTempDaily_economist<-AirTempDaily_1y +
  theme_economist()

AirTempDaily_economist

AirTempDaily_strata<-AirTempDaily_1y +
  theme_stata()

AirTempDaily_strata



## ----increase-font-size, fig.cap="A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011. The plotting points are now colored purple, axis label text is specified, plot label text is specified, plot label text is bolded and axis ticks are shown at yearly intervals with user specified formatting."----
# format x axis with dates
AirTempDaily_custom<-AirTempDaily_1y +
  # theme(plot.title) allows to format the Title separately from other text
  theme(plot.title = element_text(lineheight=.8, face="bold",size = 20)) +
  # theme(text) will format all text that isn't specifically formatted elsewhere
  theme(text = element_text(size=18)) 

AirTempDaily_custom



## ----challenge-code-ggplot-precip, echo=FALSE, fig.cap="A scatterplot showing the relationship between time and daily precipitation at Harvard Forest Between 2009 and 2011. Plot title, axis labels, text size and axis scale have been specified by the user."----
# plot precip
PrecipDaily <- ggplot(harMetDaily.09.11, aes(date, prec)) +
           geom_point() +
           ggtitle("Daily Precipitation Harvard Forest\n 2009-2011") +
            xlab("Date") + ylab("Precipitation (mm)") +
            scale_x_date(labels=date_format ("%m-%y"))+
           theme(plot.title = element_text(lineheight=.8, face="bold",
                 size = 20)) +
           theme(text = element_text(size=18))

PrecipDaily


## ----ggplot-geom_bar, fig.cap="A barchart showing the relationship between time and daily precipitation at Harvard Forest Between 2009 and 2011. Plot title, axis labels, text size and axis scale have been specified by the user."----
# plot precip
PrecipDailyBarA <- ggplot(harMetDaily.09.11, aes(date, prec)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Daily Precipitation\n Harvard Forest") +
    xlab("Date") + ylab("Precipitation (mm)") +
    scale_x_date(labels=date_format ("%b %y"), breaks=date_breaks("1 year")) +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))

PrecipDailyBarA


## ----ggplot-geom_bar-subset, results="hide", include=TRUE, echo=FALSE, fig.cap="A barchart showing the relationship between time and daily precipitation at Harvard Forest Between 2009 and 2011. Plot title, axis labels, text size and axis scale have been specified by the user."----
# Define Start and end times for the subset as R objects that are the date class
startTime2 <- as.Date("2010-01-01")
endTime2 <- as.Date("2011-01-01")

# create a start and end times R object
start.end2 <- c(startTime2,endTime2)
start.end2

# plot of precipitation
# subset just the 2011 data by using scale_x_date(limits)
ggplot(harMetDaily.09.11, aes(date, prec)) +
    geom_bar(stat="identity", na.rm = TRUE) +
    ggtitle("Daily Precipitation\n 2010\n Harvard Forest") +
    xlab("") + ylab("Precipitation (mm)") +
    scale_x_date(labels=date_format ("%B"),
    								 breaks=date_breaks("4 months"), limits=start.end2) +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18))



## ----ggplot-color, fig.cap="A barchart showing the relationship between time and daily precipitation at Harvard Forest Between 2009 and 2011. Plot title, axis labels, text size and axis scale have been specified by the user. Bars have been colored blue."----
# specifying color by name
PrecipDailyBarB <- PrecipDailyBarA+
  geom_bar(stat="identity", colour="darkblue")

PrecipDailyBarB



## ----ggplot-geom_lines,fig.cap="A lineplot showing the relationship between time and daily air temperature at Harvard Forest Between 2009 and 2011. Plot title, axis labels, text size and axis scale have been specified by the user."----
AirTempDaily_line <- ggplot(harMetDaily.09.11, aes(date, airt)) +
           geom_line(na.rm=TRUE) +  
           ggtitle("Air Temperature Harvard Forest\n 2009-2011") +
           xlab("Date") + ylab("Air Temperature (C)") +
           scale_x_date(labels=date_format ("%b %y")) +
           theme(plot.title = element_text(lineheight=.8, face="bold", 
                                          size = 20)) +
           theme(text = element_text(size=18))

AirTempDaily_line


## ----challenge-code-geom_lines&points, echo=FALSE, fig.cap="A lineplot with points added showing the relationship between time and daily air temperature at Harvard Forest Between 2009 and 2011. Plot title, axis labels, text size and axis scale have been specified by the user."----
AirTempDaily + geom_line(na.rm=TRUE) 


## ----ggplot-trend-line, fig.cap="A scatterplot showing the relationship between time and daily precipitation at Harvard Forest Between 2009 and 2011. Plot title, axis labels, text size and axis scale have been specified by the user. A green trend line has been added using the default method."----
# adding on a trend lin using loess
AirTempDaily_trend <- AirTempDaily + stat_smooth(colour="green")

AirTempDaily_trend


## ----challenge-code-linear-trend, echo=FALSE, fig.cap="A neatly formatted barchart showing the relationship between time and daily precipitation at Harvard Forest Between 2009 and 2011. Plot title, axis labels, text size and axis scale have been specified by the user."----
ggplot(harMetDaily.09.11, aes(date, prec)) +
      geom_bar(stat="identity", colour="darkorchid4") + #dark orchid 4 = #68228B
      ggtitle("Daily Precipitation with Linear Trend\n Harvard Forest") +
      xlab("Date") + ylab("Precipitation (mm)") +
      scale_x_date(labels=date_format ("%b %y"))+
      theme(plot.title = element_text(lineheight=.8, face="italic", size = 20)) +
      theme(text = element_text(size=18))+
      stat_smooth(method="lm", colour="grey")


## ----plot-airtemp-Monthly, echo=FALSE, fig.cap="A neatly formatted scatterplot showing the relationship between time and monthly average air temperature at Harvard Forest Between 2009 and 2011. Plot title, axis labels, text size and axis scale have been specified by the user."----
AirTempMonthly <- ggplot(harTemp.monthly.09.11, aes(date, mean_airt)) +
    geom_point() +
    ggtitle("Average Monthly Air Temperature\n 2009-2011\n NEON Harvard Forest") +
    theme(plot.title = element_text(lineheight=.8, face="bold", size = 20)) +
    theme(text = element_text(size=18)) +
    xlab("Date") + ylab("Air Temperature (C)") +
    scale_x_date(labels=date_format ("%b%y"))

AirTempMonthly



## ----compare-precip, fig.cap="Two scatterplots combined in a single image.  Above: the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011.  Below: the relationship between time and monthly average air temperature at Harvard Forest between 2009 and 2011"----
# note - be sure library(gridExtra) is loaded!
# stack plots in one column 
grid.arrange(AirTempDaily, AirTempMonthly, ncol=1)


## ----challenge-code-grid-arrange, echo=FALSE, fig.cap="Two scatterplots combined in a single image.  Left: the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011.  Right: the relationship between time and monthly average air temperature at Harvard Forest between 2009 and 2011"----
grid.arrange(AirTempDaily, AirTempMonthly, ncol=2)

