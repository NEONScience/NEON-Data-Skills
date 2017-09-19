## ----load-libraries------------------------------------------------------
# Load packages required for entire script
library(lubridate)  # work with dates
library(ggplot2)  # plotting

# set working directory to ensure R can find the file we wish to import
# setwd("working-dir-path-here")

# Load csv file containing 15 minute averaged atmospheric data 
# for the NEON Harvard Forest Field Site

# Factors=FALSE so data are imported as numbers and characters 
harMet_15Min <- read.csv(
  file="NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-10-15min-m.csv",
  stringsAsFactors = FALSE)

# convert to POSIX date time class - US Eastern Time Zone
harMet_15Min$datetime <- as.POSIXct(harMet_15Min$datetime,
                                format = "%Y-%m-%dT%H:%M",
                                tz = "America/New_York")


## ----subset-by-time------------------------------------------------------
# subset data - 2009-2011
harMet15.09.11 <- subset(harMet_15Min,
                         datetime >= as.POSIXct('2009-01-01 00:00',
                                                tz = "America/New_York") &
                         datetime <= as.POSIXct('2011-12-31 23:59',
                                               tz = "America/New_York"))

# View first and last records in the object 
head(harMet15.09.11[1])
tail(harMet15.09.11[1])


## ----write-csv-----------------------------------------------------------
# write harMet15 subset data to .csv
write.csv(harMet15.09.11, 
          file="Met_HARV_15min_2009_2011.csv")


## ----challenge-code-subsetting, include=TRUE, results="hide", echo=FALSE----

# subset out data points from July 2010
harMet15_July2010 <- subset(harMet15.09.11,
                            datetime >= as.POSIXct('2010-07-01 00:00',
                                                   tz = "America/New_York") &
                            datetime <= as.POSIXct('2010-07-31 23:59', 
                                                   tz = "America/New_York"))

# view first and last rows of data.frame to ensure subset worked
head(harMet15_July2010$datetime)
tail(harMet15_July2010$datetime)

# plot precip data for July 2010
qplot (datetime, prec,
       data= harMet15_July2010,
       main= "Precipitation: July 2010\nNEON Harvard Forest Field Site",
       xlab= "Date", ylab= "Precipitation (mm)")

# 2
# subset out data points from July 2010
harMet15_2011 <- subset(harMet15.09.11,
                            datetime >= as.POSIXct('2011-01-01 00:00',
                                                   tz = "America/New_York") &
                            datetime <= as.POSIXct('2011-12-31 23:59', 
                                                   tz = "America/New_York"))

# view first and last rows of data.frame to ensure subset worked
head(harMet15_2011$datetime)
tail(harMet15_2011$datetime)

# plot precip data for July 2010
qplot (datetime, dewp,
       data= harMet15_2011,
       main= "Dew Point: 2011\nNEON Harvard Forest Field Site",
       xlab= "Date", ylab= "Dew Point (C)")

## ----missing values------------------------------------------------------

# Check for NA values
sum(is.na(harMet15.09.11$datetime))
sum(is.na(harMet15.09.11$airt))

# view rows where the air temperature is NA 
harMet15.09.11[is.na(harMet15.09.11$airt),]

## ----no-data-value-challenge, echo=FALSE, results="hide"-----------------
# check for no data values
sum(is.na(harMet15.09.11$prec))
sum(is.na(harMet15.09.11$parr))


## ----na-in-calculations--------------------------------------------------

# calculate mean of air temperature
mean(harMet15.09.11$airt)

# are there NA values in our data?
sum(is.na(harMet15.09.11$airt))


## ----na-rm---------------------------------------------------------------
# calculate mean of air temperature, ignore NA values
mean(harMet15.09.11$airt, 
     na.rm=TRUE)


## ----Challenge-code-harMet.daily, include=TRUE, results="hide", echo=FALSE----

# 1. import daily file
harMet.daily <- read.csv("NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-06-daily-m.csv", 
      stringsAsFactors = FALSE)
# view file structure
str(harMet.daily)

# 2. Metadata
# Differences in 2 variable names PAR=part, DateTime=date

# 3. convert date 
harMet.daily$date <- as.Date(harMet.daily$date,format = "%Y-%m-%d")
# view structure
str(harMet.daily [1])

# 4. Check for NoData values
sum(is.na(harMet.daily$date))
sum(is.na(harMet.daily$airt))
sum(is.na(harMet.daily$prec))
sum(is.na(harMet.daily$part))
# Output Note: PART is missing 1032 values

# 5. subset out some of the data - 2009-2011
harMetDaily.09.11 <- subset(harMet.daily, date >= as.Date('2009-01-01')
                                        & date <= as.Date('2011-12-31'))

# view first and last rows of the data
head(harMetDaily.09.11$date)
tail(harMetDaily.09.11$date)

# do we still have the NA in part?
sum(is.na(harMetDaily.09.11$part))
# Output note: now only 1 NA!

# 6. Write .csv
write.csv(harMetDaily.09.11, file="Met_HARV_Daily_2009_2011.csv")

# 7.  Plotting air temp 2009-2011
qplot (x=date, y=airt,
       data=harMetDaily.09.11,
       main= "Average Air Temperature \n Harvard Forest",
       xlab="Date", ylab="Temperature (°C)")

