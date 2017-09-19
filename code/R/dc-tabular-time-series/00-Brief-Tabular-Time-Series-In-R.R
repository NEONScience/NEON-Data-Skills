## ----load-packages-------------------------------------------------------
# Load packages required for entire script. 
# library(PackageName)  # purpose of package
library(ggplot2)   # efficient, pretty plotting - required for qplot function

# set working directory to ensure R can find the file we wish to import
# setwd("working-dir-path-here")


## ----import-csv----------------------------------------------------------

# Load csv file of daily meteorological data from Harvard Forest
harMet.daily <- read.csv(
      file="NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-06-daily-m.csv",
      stringsAsFactors = FALSE
      )

## ----dataframe-----------------------------------------------------------
# what type of R object is our imported data?
class(harMet.daily)


## ----view-data-structure-------------------------------------------------

# view first 6 rows of the dataframe 
head(harMet.daily)

# View the structure (str) of the data 
str(harMet.daily)

## ----data-class-examples-------------------------------------------------

a <- "mouse"
b <- "sparrow"
class(a)
class(b)

# subract a-b 
a-b


## ----data-class-num------------------------------------------------------

c <- 2
d <- 1
class(c)
class(d)
# subract a-b 
c-d


## ----data-class-example-2------------------------------------------------

# create a new object
speciesObserved <- c("speciesb","speciesc","speciesa")
speciesObserved

# determine the class
class(speciesObserved)

# calculate the minimum
min(speciesObserved)

# create numeric object
prec <- c(1,2,5,3,6)
# view class
class(prec)
# calculate min value
min(prec)


## ----plot-data-----------------------------------------------------------
# quickly plot air temperature
qplot(x=date, y=airt, 
      data=harMet.daily,
      main="Daily Air Temperature\nNEON Harvard Forest Field Site")


## ----view-class----------------------------------------------------------
# View data class for each column that we wish to plot
class(harMet.daily$date)

class(harMet.daily$airt)


## ----convert-date-time---------------------------------------------------

# convert column to date class
harMet.daily$date <- as.Date(harMet.daily$date)

# view R class of data
class(harMet.daily$date)

# view results
head(harMet.daily$date)

## ----qplot-data----------------------------------------------------------
# quickly plot the data and include a title using main=""
# In title string we can use '\n' to force the string to break onto a new line
qplot(x=date,y=airt, 
      data=harMet.daily,
      main="Daily Air Temperature w/ Date Assigned\nNEON Harvard Forest Field Site")  


## ----challenge-code-plotting, echo=FALSE---------------------------------
# 1
qplot(x=date,y=prec, 
      data=harMet.daily,
      main="Daily Precipitation \nNEON Harvard Forest",
      xlab="Date", ylab="Daily Precipitation")  

# 2 Precipiation does not appear to have the same striking annual pattern as 
# air temperature does. 

# 3
qplot(x=airt,y=prec, 
      data=harMet.daily,
      main="Relationship between precipitation & air temperature \nNEON Harvard Forest",
      xlab="Air Temperature", ylab="Daily Precipitation")  


