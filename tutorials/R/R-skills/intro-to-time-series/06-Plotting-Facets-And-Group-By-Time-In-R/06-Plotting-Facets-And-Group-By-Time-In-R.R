## ----load-data---------------------------------------------------------

# Remember it is good coding technique to add additional libraries to the top of
# your script 
library(lubridate) # for working with dates
library(ggplot2)  # for creating graphs
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(grid)   # for arranging plots
library(dplyr)  # for subsetting by season

# set working directory to ensure R can find the file we wish to import
wd <- "~/Documents/"

# daily HARV met data, 2009-2011
harMetDaily.09.11 <- read.csv(
  file=paste0(wd,"NEON-DS-Met-Time-Series/HARV/FisherTower-Met/Met_HARV_Daily_2009_2011.csv"),
  stringsAsFactors = FALSE
  )

# covert date to Date  class
harMetDaily.09.11$date <- as.Date(harMetDaily.09.11$date)



## ----plot-airt, fig.cap="A scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011. Plot title, font, axis scale and axis labels have been specified by the user."----

AirTempDaily <- ggplot(harMetDaily.09.11, aes(date, airt)) +
           geom_point() +
           ggtitle("Daily Air Temperature\n NEON Harvard Forest\n 2009-2011") +
           xlab("Date") + ylab("Temperature (C)") +
           scale_x_date(labels=date_format ("%m-%y"))+
           theme(plot.title = element_text(lineheight=.8, face="bold",
                 size = 20)) +
           theme(text = element_text(size=18))

AirTempDaily


## ----plot-by-year------------------------------------------------------

# add year column to daily values
harMetDaily.09.11$year <- year(harMetDaily.09.11$date)

# view year column head and tail
head(harMetDaily.09.11$year)
tail(harMetDaily.09.11$year)



## ----plot-facet-year---------------------------------------------------
# run this code to plot the same plot as before but with one plot per season
AirTempDaily + facet_grid(. ~ year)


## ----plot-facet-year-2, fig.cap="A three-panel scatterplot showing the relationship between time and daily air temperature at Harvard Forest between 2009 and 2011. Left Panel: 2009. Center Panel: 2010. Right Panel: 2011. Notice each subplot has the time axis scale, covering the whole period 2009 - 2011. Plot titles, fonts, axis scales and axes labels have been specified by the user."----

AirTempDaily <- ggplot(harMetDaily.09.11, aes(date, airt)) +
           geom_point() +
           ggtitle("Daily Air Temperature\n NEON Harvard Forest") +
            xlab("Date") + ylab("Temperature (C)") +
            scale_x_date(labels=date_format ("%m-%y"))+
           theme(plot.title = element_text(lineheight=.8, face="bold",
                 size = 20)) +
           theme(text = element_text(size=18))

# facet plot by year
AirTempDaily + facet_grid(. ~ year)


## ----plot-precip-jd, fig.cap="A three-panel scatterplot showing the relationship between julian-date and daily air temperature at Harvard Forest between 2009 and 2011. Left Panel: 2009. Center Panel: 2010. Right Panel: 2011. Plot titles, fonts, axis scales and axes labels have been specified by the user."----

AirTempDaily_jd <- ggplot(harMetDaily.09.11, aes(jd, airt)) +
           geom_point() +
           ggtitle("Air Temperature\n NEON Harvard Forest Field Site") +
           xlab("Julian Day") + ylab("Temperature (C)") +
           theme(plot.title = element_text(lineheight=.8, face="bold",
                 size = 20)) +
           theme(text = element_text(size=18))

# create faceted panel
AirTempDaily_jd + facet_grid(. ~ year)



## ----rearrange-facets, fig.cap="A three-panel scatterplot showing the relationship between julian-date and daily air temperature at Harvard Forest between 2009 and 2011. Top Panel: 2009. Middle Panel: 2010. Bottom Panel: 2011. Plot titles, fonts, axis scales and axes labels have been specified by the user."----

# move labels to the RIGHT and stack all plots
AirTempDaily_jd + facet_grid(year ~ .)



## ----rearrange-facets-columns, fig.cap="A multi-panel scatterplot showing the relationship between julian-date and daily air temperature at Harvard Forest between 2009 and 2011. Top Left Panel: 2009. Top Right Panel: 2010. Bottom Left Panel: 2011. Bottom Right Panel: Blank. Plot titles, fonts, axis scales and axes labels have been specified by the user."----

# display in two columns
AirTempDaily_jd + facet_wrap(~year, ncol = 2)



## ----plot-airt-soilt, fig.cap="A scatterplot showing the relationship between daily air temperature and daily soil temperature at Harvard Forest between 2009 and 2011. Plot titles, fonts, axis scales and axes labels have been specified by the user."----

airSoilTemp_Plot <- ggplot(harMetDaily.09.11, aes(airt, s10t)) +
           geom_point() +
           ggtitle("Air vs. Soil Temperature\n NEON Harvard Forest Field Site\n 2009-2011") +
           xlab("Air Temperature (C)") + ylab("Soil Temperature (C)") +
           theme(plot.title = element_text(lineheight=.8, face="bold",
                 size = 20)) +
           theme(text = element_text(size=18))

airSoilTemp_Plot



## ----faceted-temp-plots, fig.cap="A three-panel scatterplot showing the relationship between daily air temperature and daily soil temperature at Harvard Forest between 2009 and 2011. Top Panel: 2009. Middle Panel: 2010. Bottom Panel: 2011. Plot titles, fonts, axis scales and axes labels have been specified by the user."----
# create faceted panel
airSoilTemp_Plot + facet_grid(year ~ .)


## ----challenge-answer-temp-month, echo=FALSE,  fig.cap="A multi-panel scatterplot showing the relationship between daily air temperature and daily soil temperature according to month at Harvard Forest between 2009 and 2011. Panels run left-to-right, top-to-bottom, starting with January in top-left position. Plot titles, fonts, axis scales and axes labels have been specified by the user."----

# add month column to daily values
harMetDaily.09.11$month <- month(harMetDaily.09.11$date)

# recreate plot
airSoilTemp_Plot <- ggplot(harMetDaily.09.11, aes(airt, s10t)) +
           geom_point() +
           ggtitle("Air vs. Soil Temperature\n NEON Harvard Forest Field Site\n 2009-2011") +
           xlab("Air Temperature (C)") + ylab("Soil Temperature (C)") +
           theme(plot.title = element_text(lineheight=.8, face="bold",
                 size = 20)) +
           theme(text = element_text(size=18))

# create faceted panel
airSoilTemp_Plot + facet_wrap(~month, nc=3)



## ----extract-month-name, fig.cap="A multi-panel scatterplot showing the relationship between daily air temperature and daily soil temperature according to month at Harvard Forest between 2009 and 2011. Notice panels are now placed in alphabetical order by month. Plot titles, fonts, axis scales and axes labels have been specified by the user."----
# add text month name column
harMetDaily.09.11$month_name <- format(harMetDaily.09.11$date,"%B")

# view head and tail
head(harMetDaily.09.11$month_name)
tail(harMetDaily.09.11$month_name)

# recreate plot
airSoilTemp_Plot <- ggplot(harMetDaily.09.11, aes(airt, s10t)) +
           geom_point() +
           ggtitle("Air vs. Soil Temperature \n NEON Harvard Forest Field Site\n 2009-2011") +
            xlab("Air Temperature (C)") + ylab("Soil Temperature (C)") +
           theme(plot.title = element_text(lineheight=.8, face="bold",
                 size = 20)) +
           theme(text = element_text(size=18))

# create faceted panel
airSoilTemp_Plot + facet_wrap(~month_name, nc=3)



## ----factor------------------------------------------------------------
# order the factors
harMetDaily.09.11$month_name = factor(harMetDaily.09.11$month_name, 
                                      levels=c('January','February','March',
                                               'April','May','June','July',
                                               'August','September','October',
                                               'November','December'))


## ----plot-by-month-levels, fig.cap="A multi-panel scatterplot showing the relationship between daily air temperature and daily soil temperature according to month at Harvard Forest between 2009 and 2011. Panels run left-to-right, top-to-bottom, starting with January in top-left position. Plot titles, fonts, axis scales and axes labels have been specified by the user."----

# recreate plot
airSoilTemp_Plot <- ggplot(harMetDaily.09.11, aes(airt, s10t)) +
           geom_point() +
           ggtitle("Air vs. Soil Temperature \n NEON Harvard Forest Field Site\n 2009-2011") +
            xlab("Air Temperature (C)") + ylab("Soil Temperature (C)") +
           theme(plot.title = element_text(lineheight=.8, face="bold",
                 size = 20)) +
           theme(text = element_text(size=18))

# create faceted panel
airSoilTemp_Plot + facet_wrap(~month_name, nc=3)



## ----subsetting-by-season-1--------------------------------------------

# add month to data_frame - note we already performed this step above.
harMetDaily.09.11$month  <- month(harMetDaily.09.11$date)

# view head and tail of column
head(harMetDaily.09.11$month)
tail(harMetDaily.09.11$month)


## ----subsetting-by-season-2--------------------------------------------

harMetDaily.09.11 <- harMetDaily.09.11 %>% 
  mutate(season = 
           ifelse(month %in% c(12, 1, 2), "Winter",
           ifelse(month %in% c(3, 4, 5), "Spring",
           ifelse(month %in% c(6, 7, 8), "Summer",
           ifelse(month %in% c(9, 10, 11), "Fall", "Error")))))


# check to see if this worked
head(harMetDaily.09.11$month)
head(harMetDaily.09.11$season)
tail(harMetDaily.09.11$month)
tail(harMetDaily.09.11$season)



## ----plot-by-season, fig.cap="A multi-panel scatterplot showing the relationship between daily air temperature and daily soil temperature according to user specified season at Harvard Forest between 2009 and 2011. Panels run left-to-right: fall, spring, summer and winter.. Plot titles, fonts, axis scales and axes labels have been specified by the user."----

# recreate plot
airSoilTemp_Plot <- ggplot(harMetDaily.09.11, aes(airt, s10t)) +
           geom_point() +
           ggtitle("Air vs. Soil Temperature\n 2009-2011\n NEON Harvard Forest Field Site") +
            xlab("Air Temperature (C)") + ylab("Soil Temperature (C)") +
           theme(plot.title = element_text(lineheight=.8, face="bold",
                 size = 20)) +
           theme(text = element_text(size=18))

# run this code to plot the same plot as before but with one plot per season
airSoilTemp_Plot + facet_grid(. ~ season)



## ----plot-by-season2,fig.cap="A multi-panel scatterplot showing the relationship between daily air temperature and daily soil temperature according to user specified season at Harvard Forest between 2009 and 2011. Panels run top-to-bottom: fall, spring, summer and winter.. Plot titles, fonts, axis scales and axes labels have been specified by the user."----

# for a landscape orientation of the plots we change the order of arguments in
# facet_grid():
airSoilTemp_Plot + facet_grid(season ~ .)



## ----assigning-level-to-season, include=TRUE, results="hide", echo=FALSE, fig.cap=c("A multi-panel scatterplot showing the relationship between daily air temperature and daily soil temperature according to user specified season at Harvard Forest between 2009 and 2011. Top-left: winter.  Top-right: spring. Bottom-left: summer. Bottom-right: fall. Plot titles, fonts, axis scales and axes labels have been specified by the user.","A multi-panel scatterplot showing the relationship between daily air temperature and daily soil temperature according to user specified season and year at Harvard Forest between 2009 and 2011. Columns are left-to-right: winter, spring, summer and fall.  Rows are top-to-bottom: 2009, 2010 and 2011. Plot titles, fonts, axis scales and axes labels have been specified by the user.")----
# 1
# create factor / assign levels
harMetDaily.09.11$season<- factor(harMetDaily.09.11$season, 
                                  level=c("Winter","Spring","Summer","Fall")) 

# check to make sure it worked
str(harMetDaily.09.11$season)

# rerun original air & soil temp code to incorporate the levels. 
airSoilTemp_Plot_season <- ggplot(harMetDaily.09.11,aes(airt, s10t)) + 
  geom_point(na.rm=TRUE) +    #removing the NA values
  ggtitle("Seasonal Air vs Soil Temperature\n 2009-2011 \n NEON Harvard Forest Site") +
  theme(plot.title = element_text(lineheight=.8, face="bold",size = 20)) +
  theme(text = element_text(size=20)) +
  xlab("Air Temperature (C)") + ylab("Soil Temperature (C)")

# 2   air & soil temp by season         
# new facetted plots
airSoilTemp_Plot_season + facet_wrap(~ season, nc=2)

# 3  air & soil temp by season & year
# new facetted plots
airSoilTemp_Plot_season + facet_grid(year ~ season)


## ----view-year-month-data, echo=FALSE----------------------------------

met_monthly_HARV <- read.csv(
  paste0(wd,"NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-04-monthly-m.csv"),
  stringsAsFactors = FALSE
  )

# view header of date
head(met_monthly_HARV$date)


## ----challenge-code-convert-monthly-data, results="hide", echo=FALSE, message=FALSE----

# read in the data
met_monthly_HARV <- read.csv(
  paste0(wd,"NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-04-monthly-m.csv"),
  stringsAsFactors = FALSE
  )
# base R
# convert to date time - add a day "01" to each date to support this in base R
met_monthly_HARV$date_base <- as.Date(paste(met_monthly_HARV$date,"-01",sep=""))
head(met_monthly_HARV$date_base)
class(met_monthly_HARV$date_base)

# zoo
# load the zoo package
library(zoo)

# convert to yearmon class 
met_monthly_HARV$ymon_zoo <- as.yearmon(met_monthly_HARV$date)
head(met_monthly_HARV$ymon_zoo)
class(met_monthly_HARV$ymon_zoo)

# convert yearmon to Date class
met_monthly_HARV$date_zoo<- as.Date(met_monthly_HARV$ymon_zoo)
head(met_monthly_HARV$date_zoo)
class(met_monthly_HARV$date_zoo)



## ----challenge-code-plot-yearmonth-data, include=TRUE, results="hide", echo=FALSE, fig.cap="A multi-panel scatterplot showing the relationship between time and monthly average air temperature according to year at Harvard Forest between 2001 and 2015. Top-left: winter.  Panels run left-to-right, top-to-bottom, starting with 2001 in the top-left corner. Plot titles, fonts, axis scales and axes labels have been specified by the user."----
# add year- for facetted plot
met_monthly_HARV$year <- year(met_monthly_HARV$date_base)

# add month - x-axis in plot
met_monthly_HARV$month <- factor(month(met_monthly_HARV$date_base))

# create plot
long_term_temp <- ggplot(met_monthly_HARV,aes(month, airt)) +
        geom_point(na.rm=TRUE) +    #removing the NA values
        ggtitle("Air Temperature 2001-2015 \n NEON Harvard Forest Site") +
        theme(plot.title = element_text(lineheight=.8, face="bold",size = 20)) +
        theme(text = element_text(size=20)) +
        xlab("Month") + ylab("Air Temperature (C)")

# new facetted plots
long_term_temp + facet_wrap(~ year, nc=3)


