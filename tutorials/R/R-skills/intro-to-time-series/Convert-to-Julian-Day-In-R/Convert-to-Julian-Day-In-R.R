## ----load-data-------------------------------------------------------

# Load packages required for entire script
library(lubridate)  #work with dates

# set working directory to ensure R can find the file we wish to import
wd <- "~/Git/data/"

# Load csv file of daily meteorological data from Harvard Forest
# Factors=FALSE so strings, series of letters/ words/ numerals, remain characters
harMet_DailyNoJD <- read.csv(
  file=paste0(wd,"NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-06-daily-m-NoJD.csv"),
  stringsAsFactors = FALSE
  )

# what data class is the date column? 
str(harMet_DailyNoJD$date)

# convert "date" from chr to a Date class and specify current date format
harMet_DailyNoJD$date<- as.Date(harMet_DailyNoJD$date, "%m/%d/%y")


## ----yday------------------------------------------------------------
# to learn more about it type
?yday


## ----julian-day-convert----------------------------------------------
# convert with yday into a new column "julian"
harMet_DailyNoJD$julian <- yday(harMet_DailyNoJD$date)  

# make sure it worked all the way through. 
head(harMet_DailyNoJD$julian) 
tail(harMet_DailyNoJD$julian)


