## ----load-libraries--------------------------------------------------
# load packages
library(ggplot2) # create efficient, professional plots
library(plotly) # create cool interactive plots


# set your working directory to ensure R can find the file we wish to import 
# and where we want to save our files. Be sure to move the download into 
# your working direectory!
wd <- "~/Git/data/" # This will depend on your local environment
setwd(wd)



## ----load-libraries-hidden, echo=FALSE, eval=FALSE, comment=FALSE, results="hide"----
FALSE # this package is only added to get the webpage derived from this code to render
FALSE # the plotly graphs.  It is NOT needed for any of the analysis or data
FALSE # visualizations.
FALSE 
FALSE #install.packages("webshot")
FALSE #webshot::install_phantomjs()
FALSE library(webshot) # embed the plotly plots


## ----import-precip---------------------------------------------------

# import precip data into R data.frame by 
# defining the file name to be opened

precip.boulder <- read.csv(paste0(wd,"disturb-events-co13/precip/805325-precip_daily_2003-2013.csv"), stringsAsFactors = FALSE, header = TRUE )

# view first 6 lines of the data
head(precip.boulder)

# view structure of data
str(precip.boulder)



## ----convert-date----------------------------------------------------

# convert to date/time and retain as a new field
precip.boulder$DateTime <- as.POSIXct(precip.boulder$DATE, 
                                  format="%Y%m%d %H:%M") 
                                  # date in the format: YearMonthDay Hour:Minute 

# double check structure
str(precip.boulder$DateTime)



## ----no-data-values-hist, fig.cap= "Histogram displaying the frquency of total precipitation in inches for the recorded hour."----

# histogram - would allow us to see 999.99 NA values 
# or other "weird" values that might be NA if we didn't know the NA value
hist(precip.boulder$HPCP)



## ----no-data-values--------------------------------------------------
# assing NoData values to NA
precip.boulder$HPCP[precip.boulder$HPCP==999.99] <- NA 

# check that NA values were added; 
# we can do this by finding the sum of how many NA values there are
sum(is.na(precip.boulder))



## ----plot-precip-hourly, fig.cap= "Bar graph of Hourly Precipitation (Inches) for the Boulder station, 050843, spanning years 2003 - 2013. X-axis and Y-axis are Date and Precipitation in Inches, repectively."----
#plot the data
precPlot_hourly <- ggplot(data=precip.boulder,  # the data frame
      aes(DateTime, HPCP)) +   # the variables of interest
      geom_bar(stat="identity") +   # create a bar graph
      xlab("Date") + ylab("Precipitation (Inches)") +  # label the x & y axes
      ggtitle("Hourly Precipitation - Boulder Station\n 2003-2013")  # add a title

precPlot_hourly



## ----daily-summaries, fig.cap= "Bar graph of Daily Precipitation (Inches) for the Boulder station, 050843, spanning years 2003 - 2013. X-axis and Y-axis are Date and Precipitation in Inches, repectively."----

# convert DATE to a Date class 
# (this will strip the time, but that is saved in DateTime)
precip.boulder$DATE <- as.Date(precip.boulder$DateTime, # convert to Date class
                                  format="%Y%m%d %H:%M") 
                                  #DATE in the format: YearMonthDay Hour:Minute 

# double check conversion
str(precip.boulder$DATE)

precPlot_daily1 <- ggplot(data=precip.boulder,  # the data frame
      aes(DATE, HPCP)) +   # the variables of interest
      geom_bar(stat="identity") +   # create a bar graph
      xlab("Date") + ylab("Precipitation (Inches)") +  # label the x & y axes
      ggtitle("Daily Precipitation - Boulder Station\n 2003-2013")  # add a title

precPlot_daily1


## ----daily-summ------------------------------------------------------

# aggregate the Precipitation (PRECIP) data by DATE
precip.boulder_daily <-aggregate(precip.boulder$HPCP,   # data to aggregate
	by=list(precip.boulder$DATE),  # variable to aggregate by
	FUN=sum,   # take the sum (total) of the precip
	na.rm=TRUE)  # if the are NA values ignore them
	# if this is FALSE any NA value will prevent a value be totalled

# view the results
head(precip.boulder_daily)


## ----rename-fields---------------------------------------------------

# rename the columns
names(precip.boulder_daily)[names(precip.boulder_daily)=="Group.1"] <- "DATE"
names(precip.boulder_daily)[names(precip.boulder_daily)=="x"] <- "PRECIP"

# double check rename
head(precip.boulder_daily)


## ----daily-prec-plot, fig.cap= "Bar graph of Daily Precipitation (Inches) for the Boulder station, 050843, using combined hourly data for each day. X-axis and Y-axis are Date and Precipitation in Inches, repectively."----

# plot daily data
precPlot_daily <- ggplot(data=precip.boulder_daily,  # the data frame
      aes(DATE, PRECIP)) +   # the variables of interest
      geom_bar(stat="identity") +   # create a bar graph
      xlab("Date") + ylab("Precipitation (Inches)") +  # label the x & y axes
      ggtitle("Daily Precipitation - Boulder Station\n 2003-2013")  # add a title

precPlot_daily


## ----plot-Aug-Oct-2013,  fig.cap= "Bar graph of Daily Precipitation (Inches) for the Boulder station, 050843, using a subset of the data spanning 2 months around the floods. X-axis and Y-axis are Date and Precipitation in Inches, repectively."----

# First, define the limits -- 2 months around the floods
limits <- as.Date(c("2013-08-15", "2013-10-15"))

# Second, plot the data - Flood Time Period
precPlot_flood <- ggplot(data=precip.boulder_daily,
      aes(DATE, PRECIP)) +
      geom_bar(stat="identity") +
      scale_x_date(limits=limits) +
      xlab("Date") + ylab("Precipitation (Inches)") +
      ggtitle("Precipitation - Boulder Station\n August 15 - October 15, 2013")

precPlot_flood



## ----subset-data, fig.cap= "Bar graph of Daily Precipitation (Inches) for the Boulder station, 050843, using a subset of the data spanning 2 months around the floods. X-axis and Y-axis are Date and Precipitation in Inches, repectively."----

# subset 2 months around flood
precip.boulder_AugOct <- subset(precip.boulder_daily, 
                        DATE >= as.Date('2013-08-15') & 
												DATE <= as.Date('2013-10-15'))

# check the first & last dates
min(precip.boulder_AugOct$DATE)
max(precip.boulder_AugOct$DATE)

# create new plot
precPlot_flood2 <- ggplot(data=precip.boulder_AugOct, aes(DATE,PRECIP)) +
  geom_bar(stat="identity") +
  xlab("Time") + ylab("Precipitation (inches)") +
  ggtitle("Daily Total Precipitation \n Boulder Creek 2013") 

precPlot_flood2 



## ----plotly-prep, eval=FALSE, comment=NA-----------------------------

# setup your plot.ly credentials; if not already set up
#Sys.setenv("plotly_username"="your.user.name.here")
#Sys.setenv("plotly_api_key"="your.key.here")



## ----plotly-precip-data,eval=FALSE, comment=NA, fig.cap= "Bar graph of Daily Precipitation (Inches) for the Boulder station, 050843, using a subset of the data spanning 2 months around the floods. X-axis and Y-axis are Date and Precipitation in Inches, repectively.", message=FALSE----

# view plotly plot in R
ggplotly(precPlot_flood2)


## ----plotly-post-precip-data, eval=FALSE, comment=NA-----------------
# publish plotly plot to your plot.ly online account when you are happy with it
api_create(precPlot_flood2)



## ----all-boulder-station-data, echo=FALSE, results="hide", include=TRUE, fig.cap= "Bar graph of Daily Precipitation (Inches) for the full record of precipitation data available for the Boulder station, 050843. Data spans years 1948 through 2013. X-axis and Y-axis are Date and Precipitation in Inches, repectively."----
# read in data
prec.boulder.all <- read.csv(paste0(wd,"disturb-events-co13/precip/805333-precip_daily_1948-2013.csv"), stringsAsFactors = FALSE, header = TRUE )
                             
# assing NoData values to NA
prec.boulder.all$HPCP[prec.boulder.all$HPCP==999.99] <- NA 

# format date/time
prec.boulder.all$DateTime <- as.POSIXct(prec.boulder.all$DATE, 
                                  format="%Y%m%d %H:%M") 
                                  #Date in the format: YearMonthDay Hour:Minute

# create a year-month variable to aggregate to monthly precip
prec.boulder.all$YearMon  = strftime(prec.boulder.all$DateTime, "%Y/%m")

# aggregate by month
prec.boulder.all_monthly <-aggregate(prec.boulder.all$HPCP,   # data to aggregate
																 by=list(prec.boulder.all$YearMon),  # variable to aggregate by
																 FUN=sum,   # take the sum (total) of the precip
																 na.rm=TRUE)  # if the are NA values ignore them
												# if this is FALSE any NA value will prevent a value be totalled

# rename the columns
names(prec.boulder.all_monthly)[names(prec.boulder.all_monthly)=="Group.1"] <- "DATE"
names(prec.boulder.all_monthly)[names(prec.boulder.all_monthly)=="x"] <- "PRECIP"

# re-format YearMon to a Date so x-axis looks good
prec.boulder.all_monthly$DATE <- paste(prec.boulder.all_monthly$DATE,"/01",sep="")
prec.boulder.all_monthly$DATE <- as.Date(prec.boulder.all_monthly$DATE)

# plot data
precPlot_all <- ggplot(data=prec.boulder.all_monthly, aes(DATE,PRECIP)) +
	geom_bar(stat="identity") +
  xlab("Date") + ylab("Precipitation (inches)") +
  ggtitle("Total Monthly Precipitation \n Boulder, CO Station") 

precPlot_all


## ----plotly-all-boulder-station-data, echo=FALSE, results="hide",eval=FALSE, comment=NA, include=TRUE, fig.cap= "Bar graph of Daily Precipitation (Inches) for the full record of precipitation data available for the Boulder station, 050843. Data spans years 1948 through 2013. X-axis and Y-axis are Date and Precipitation in Inches, repectively."----
# create Plotly plot in R
ggplotly(precPlot_all)

#publish plotly plot to your plot.ly online account when you are happy with it
#api_create(precPlot_all)



## ----inches----------------------------------------------------------

# convert from 100th inch by dividing by 100
precip.boulder$PRECIP<-precip.boulder$HPCP/100

# view & check to make sure conversion occurred
head(precip.boulder)


