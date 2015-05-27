## ----setupLibrary--------------------------------------------------------

#Install rhdf5 library
#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")


library("rhdf5")
#also load ggplot2 and dplyr
library("ggplot2")
library("dplyr")
library("scales")

## ----defineH5Path, results='hide'----------------------------------------

#NOTE: be sure to adjust the path to match your file structure!
# Identify file path
f <- "NEON_TowerDataD3_D10.hdf5"
# View structure of file
h5ls(f)


## ----viewH5Structure-----------------------------------------------------
#specify how many "levels" of nesting are returns in the command
h5ls(f,recursive=2)
h5ls(f,recursive=3)


## ----readPlotData--------------------------------------------------------
#read in temperature data
temp <- h5read(f,"/Domain_03/OSBS/min_1/boom_1/temperature")
#view the first few lines of the data 
head(temp)
#generate a quick plot of the data, type=l for "line"
plot(temp$mean,type='l')
	

## ----plot-temp-data------------------------------------------------------

# Let's clean up the plot abovet. We can first add dates to the x axis. 
# In order to list dates, we need to specify the format that the date field is in.
# First read in the time as UTC format
temp$date <- as.POSIXct(temp$date ,format = "%Y-%m-%d %H:%M:%S", tz = "GMT")

# Create a plot using GGPLOT
ordwayPlot <- ggplot(temp,aes(x=date,y=mean))+
  geom_path()+
  ylab("Mean temperature") + 
  xlab("Date in UTC")+
  ggtitle("3 Days of Temperature Data at Ordway Swisher")

ordwayPlot

## ----fix-time-zone-------------------------------------------------------

#convert to local time for pretty plotting
attributes(temp$date)$tzone <- "America/New_York"

ordwayPlot2 <- ggplot(temp,aes(x=date,y=mean))+
  geom_path()+
  ylab("Mean temperature") + xlab("Date in Eastern Standard Time")+
  theme_bw()+
  ggtitle("3 Days of Temperature Data at Ordway Swisher")+
  scale_x_datetime(breaks=pretty_breaks(n=4))

#let's check out the plot
ordwayPlot2


## ----viewAttributes------------------------------------------------------

## View the groups and datasets in our file, 
#we will grab the nested structure, 5 'levels' down
#5 levels gets us to the temperature dataset
fiu_struct <- h5ls(f,recursive=5)

## have a look at the structure.
fiu_struct

#now we can use this object to pull group paths from our file!
fiu_struct[3,1]

## Let's view the metadata for the OSBS group
OSBS  <- h5readAttributes(f,fiu_struct[3,1])
#view the attributes
OSBS

# Grab the lat and long from the data
# note we might want to format the lat and long differently 
# This format is more difficult to extract from R!
OSBS$LatLon


## ----multGroups----------------------------------------------------------

#r compare temperature data for different booms at the Ordway Swisher site.
library(dplyr)
library(ggplot2)


# use dplyr to subset data by dataset name (temperature)
# and site / 1 minute average
newStruct <- fiu_struct %>% filter(grepl("temperature",name),
                                   grepl("OSBS/min_1",group))

#create final paths to access each temperature dataset
paths <- paste(newStruct$group,newStruct$name,sep="/")

#create a new, empty data.frame
ord_temp <- data.frame()



## ----createDataframe-----------------------------------------------------

#loop through each temp dataset and add to data.frame
for(i in paths){
  datasetName <- i
  print(datasetName) 
  #read in each dataset in the H5 list
  dat <- h5read(f,datasetName)
  # add boom name to data.frame
  print(strsplit(i,"/")[[1]][5]) 
  dat$boom <- strsplit(i,"/")[[1]][5]
  ord_temp <- rbind(ord_temp,dat)
}


## ----plotBoomData--------------------------------------------------------

#fix the dates
ord_temp$date <- as.POSIXct(ord_temp$date,format = "%Y-%m-%d %H:%M:%S", tz = "EST")

# a nice R packages that helps with date formating is scale.
# install.packages("scales")
library("scales")
#plot the data
ggplot(ord_temp,aes(x=date,y=mean,group=boom,colour=boom))+
  geom_path()+
  ylab("Mean temperature") + xlab("Date")+
  theme_bw()+
  ggtitle("3 Days of temperature data at Ordway Swisher")+
  scale_x_datetime(breaks=pretty_breaks(n=4))



## ----compareGroupData----------------------------------------------------
#grab just the paths to temperature data, 30 minute average
pathStrux <- fiu_struct %>% filter(grepl("temperature",name), 
                                   grepl("min_30",group)) 
#create final paths
paths <- paste(pathStrux$group,pathStrux$name,sep="/")

#create empty dataframe
temp_30 <- data.frame()

for(i in paths){
  #create columns for boom name and site name
  boom <-  strsplit(i,"/")[[1]][5]
  site <- strsplit(i,"/")[[1]][3]
  dat <- h5read(f,i)
  dat$boom <- boom
  dat$site <- site
 temp_30 <- rbind(temp_30,dat)
}

#Assign the date field to a "date" format in R
temp_30$date <- as.POSIXct(temp_30$date,format = "%Y-%m-%d %H:%M:%S")

# generate a mean temperature for every date across booms
temp30_sum <- temp_30 %>% group_by(date,site) %>% summarise(mean = mean(mean))

#Create plot!
ggplot(temp30_sum,aes(x=date,y=mean,group=site,colour=site)) + 
  geom_path()+ylab("Mean temperature, 30 Minute Average") + 
  xlab("Date")+
  theme_bw()+
  ggtitle("Comparison of Ordway-Swisher Biological Station (FL) vs North Sterling (CO)") +
  scale_x_datetime( breaks=pretty_breaks(n=4))


