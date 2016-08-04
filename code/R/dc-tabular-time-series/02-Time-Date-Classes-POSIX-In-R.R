## ----load-libraries------------------------------------------------------

# Load packages required for entire script
library(lubridate)  #work with dates

# set working directory to ensure R can find the file we wish to import
# setwd("working-dir-path-here")


## ----read-data-csv-------------------------------------------------------
# Load csv file of 15 min meteorological data from Harvard Forest
# Factors=FALSE so strings, series of letters/ words/ numerals, remain characters
harMet_15Min <- read.csv(
  file="NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-10-15min-m.csv",
  stringsAsFactors = FALSE)

## ----view-date-structure-------------------------------------------------
# view column data class
class(harMet_15Min$datetime)

# view sample data
head(harMet_15Min$datetime)


## ----as-date-only--------------------------------------------------------

# convert column to date class
dateOnly_HARV <- as.Date(harMet_15Min$datetime)

# view data
head(dateOnly_HARV)


## ----explore-as_date-----------------------------------------------------
# Convert character data to date (no time) 
myDate <- as.Date("2015-10-19 10:15")   
str(myDate)

# what happens if the date has text at the end?
myDate2 <- as.Date("2015-10-19Hello")   
str(myDate2)


## ----explore-POSIXct-----------------------------------------------------
# Convert character data to date and time.
timeDate <- as.POSIXct("2015-10-19 10:15")   
str(timeDate)
timeDate


## ----explore-POSIXct2----------------------------------------------------
# to see the data in this 'raw' format, i.e., not formatted according to the 
# class type to show us a date we recognize, use the `unclass()` function.
unclass(timeDate)


## ----explore-POSIXlt-----------------------------------------------------
# Convert character data to POSIXlt date and time
timeDatelt<- as.POSIXlt("2015-10-19 10:15")  
str(timeDatelt)
timeDatelt

unclass(timeDatelt)

## ----view-date-----------------------------------------------------------
# view one date-time field
harMet_15Min$datetime[1]

## ----format-date---------------------------------------------------------
# convert single instance of date/time in format year-month-day hour:min:sec
as.POSIXct(harMet_15Min$datetime[1],format="%Y-%m-%dT%H:%M")

## The format of date-time MUST match the specified format or the data will not
# convert; see what happens when you try it a different way or without the "T"
# specified
as.POSIXct(harMet_15Min$datetime[1],format="%d-%m-%Y%H:%M")
as.POSIXct(harMet_15Min$datetime[1],format="%Y-%m-%d%H:%M")


## ----convert-column------------------------------------------------------
new.date.time <- as.POSIXct(harMet_15Min$datetime,
                            format="%Y-%m-%dT%H:%M" #format time
                            )

# view output
head(new.date.time)

# what class is the output
class(new.date.time)


## ----assign-time-zone----------------------------------------------------
# assign time zone to just the first entry
as.POSIXct(harMet_15Min$datetime[1],
            format = "%Y-%m-%dT%H:%M",
            tz = "America/New_York")

## ----POSIX-convert-best-practice-code------------------------------------
# convert to POSIXct date-time class
harMet_15Min$datetime <- as.POSIXct(harMet_15Min$datetime,
                                format = "%Y-%m-%dT%H:%M",
                                tz = "America/New_York")

# view structure and time zone of the newly defined datetime column
str(harMet_15Min$datetime)
tz(harMet_15Min$datetime)

