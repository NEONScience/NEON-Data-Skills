## ----load-data-----------------------------------------------------------

# it's good coding practice to load packages at the top of a script

library(lubridate) # work with dates
library(dplyr)     # data manipulation (filter, summarize, mutate)
library(ggplot2)   # graphics
library(gridExtra) # tile several plots next to each other
library(scales)

# set working directory to ensure R can find the file we wish to import
# setwd("working-dir-path-here")

# 15-min Harvard Forest met data, 2009-2011
harMet15.09.11<- read.csv(
  file="NEON-DS-Met-Time-Series/HARV/FisherTower-Met/Met_HARV_15min_2009_2011.csv",
  stringsAsFactors = FALSE
  )
# convert datetime to POSIXct
harMet15.09.11$datetime<-as.POSIXct(harMet15.09.11$datetime,
                    format = "%Y-%m-%d %H:%M",
                    tz = "America/New_York")

## ----15-min-plots, echo=FALSE--------------------------------------------

a <- ggplot(harMet15.09.11, aes(x=datetime, y=airt)) + 
           geom_point(na.rm=TRUE, size = .1) +
           scale_x_datetime(breaks=date_breaks("1 year")) +
           ggtitle("Air Temp \n NEON Harvard Forest Field Site") +
           xlab("Date") + 
           ylab("Air Temperature, Celcius")

b <- ggplot(harMet15.09.11, aes(x=datetime, y=prec)) +
          geom_point(na.rm=TRUE, size = .1) +
          scale_x_datetime(breaks=date_breaks("1 year")) +
           ggtitle("Precipitation \n NEON Harvard Forest Field Site")+
           xlab("Date") + ylab("Daily Total Precip., mm")

c <- ggplot(harMet15.09.11, aes(x=datetime, y=parr))+
          geom_point(na.rm=TRUE, size = .1) +
           scale_x_datetime(breaks=date_breaks("1 year")) +
           ggtitle("PAR \n NEON Harvard Forest Field Site") +
           xlab("Date") + ylab("Total PAR-Daily Mean")

grid.arrange(a,b,c, ncol=2)


## ----dplyr-lubridate-2---------------------------------------------------
# create a year column
harMet15.09.11$year <- year(harMet15.09.11$datetime)

## ----dplyr-lubridate-3---------------------------------------------------

# check to make sure it worked
names(harMet15.09.11)
str(harMet15.09.11$year)

## ----group-by-dplyr------------------------------------------------------

# Create a group_by object using the year column 
HARV.grp.year <- group_by(harMet15.09.11, # data_frame object
                          year) # column name to group by

# view class of the grouped object
class(HARV.grp.year)

## ----tally-by-year-------------------------------------------------------
# how many measurements were made each year?
tally(HARV.grp.year)

# what is the mean airt value per year?
summarize(HARV.grp.year, 
          mean(airt)   # calculate the annual mean of airt
          ) 


## ----check-data----------------------------------------------------------
# are there NoData values?
sum(is.na(HARV.grp.year$airt))

# where are the no data values
# just view the first 6 columns of data
HARV.grp.year[is.na(HARV.grp.year$airt),1:6]


## ----calculate-mean-value------------------------------------------------
# calculate mean but remove NA values
summarize(HARV.grp.year, 
          mean(airt, na.rm = TRUE)
          )


## ----using-pipes---------------------------------------------------------

# how many measurements were made a year?
harMet15.09.11 %>% 
  group_by(year) %>%  # group by year
  tally() # count measurements per year


## ----summ-data-----------------------------------------------------------
# what was the annual air temperature average 
year.sum <- harMet15.09.11 %>% 
  group_by(year) %>%  # group by year
  summarize(mean(airt, na.rm=TRUE))

# what is the class of the output?
year.sum
# view structure of output
str(year.sum)

## ----pipe-demo, echo = FALSE---------------------------------------------

# create dataframe
jday.avg <- harMet15.09.11 %>%      # within the harMet15.09.11 data
            group_by(jd) %>%      # group the data by the Julian day
            summarize((mean(airt,na.rm=TRUE)))  # summarize temp per julian day
names(jday.avg) <- c("jday","meanAirTemp")

# plot average air temperature by Julian day
qplot(jday.avg$jday, jday.avg$meanAirTemp,
        main="Average Air Temperature by Julian Day\n 2009-2011\n NEON Harvard Forest Field Site",
      xlab="Julian Day", ylab="Temp (C)")


## ----dplyr-group---------------------------------------------------------
harMet15.09.11 %>%         # use the harMet15.09.11 data_frame
  group_by(year, jd) %>%   # group data by Year & Julian day
  tally()                  # tally (count) observations per jd / year

## ----simple-math---------------------------------------------------------
24*4  # 24 hours/day * 4 15-min data points/hour

## ----dplyr-summarize-----------------------------------------------------
harMet15.09.11 %>%         # use the harMet15.09.11 data_frame
  group_by(year, jd) %>%   # group data by Year & Julian day
  summarize(mean_airt = mean(airt, na.rm = TRUE))  # mean airtemp per jd / year

## ----challenge-answer, echo=FALSE----------------------------------------
# calculate total percip by year & day
total.prec <- harMet15.09.11 %>%
  group_by(year, jd) %>%
  summarize(sum_prec = sum(prec, na.rm = TRUE)) 

# plot precip
qplot(total.prec$jd, total.prec$sum_prec,
      main="Total Precipitation",
      xlab="Julian Day", ylab="Precip (mm)", 
      colour=as.factor(total.prec$year))


## ----dplyr-mutate--------------------------------------------------------

harMet15.09.11 %>%
  mutate(year2 = year(datetime)) %>%
  group_by(year2, jd) %>%
  summarize(mean_airt = mean(airt, na.rm = TRUE))


## ----dplyr-create-data-frame---------------------------------------------

harTemp.daily.09.11<-harMet15.09.11 %>%
                    mutate(year2 = year(datetime)) %>%
                    group_by(year2, jd) %>%
                    summarize(mean_airt = mean(airt, na.rm = TRUE))

head(harTemp.daily.09.11)

## ----dplyr-dataframe-----------------------------------------------------
# add in a datatime column
harTemp.daily.09.11 <- harMet15.09.11 %>%
  mutate(year3 = year(datetime)) %>%
  group_by(year3, jd) %>%
  summarize(mean_airt = mean(airt, na.rm = TRUE), datetime = first(datetime))

# view str and head of data
str(harTemp.daily.09.11)
head(harTemp.daily.09.11)

## ----challenge-code-dplyr, results="hide", include=TRUE, echo=FALSE------
# 1
total.prec2 <- harMet15.09.11 %>%
  group_by(year, jd) %>%
  summarize(sum_prec = sum(prec, na.rm = TRUE), datetime = first(datetime)) 

qplot(x=total.prec2$datetime, y=total.prec2$sum_prec,
    main="Total Daily Precipitation 2009-2011\nNEON Harvard Forest Field Site",
    xlab="Date (Daily Values)", ylab="Precip (mm)")

# p2
harTemp.monthly.09.11 <- harMet15.09.11 %>%
  mutate(month = month(datetime), year= year(datetime)) %>%
  group_by(month, year) %>%
  summarize(mean_airt = mean(airt, na.rm = TRUE), datetime = first(datetime))

qplot(harTemp.monthly.09.11$datetime, harTemp.monthly.09.11$mean_airt,
  main="Monthly Mean Air Temperature 2009-2011\nNEON Harvard Forest Field Site",
  xlab="Date (Month)", ylab="Air Temp (C)")

str(harTemp.monthly.09.11)

