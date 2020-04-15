## ----setupLibrary-------------------------------------------------------------------------

# Install rhdf5 library
#install.packages("BiocManager")
#BiocManager::install("rhdf5")


library("rhdf5")
# also load ggplot2 and dplyr
library("ggplot2")
library("dplyr")
# a nice R packages that helps with date formatting is scale.
library("scales")

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files
#setwd("working-dir-path-here")


## ----defineH5Path-------------------------------------------------------------------------
# Identify file path (be sure to adjust the path to match your file structure!)
f <- "NEONDSTowerTemperatureData.hdf5"
# View structure of file
h5ls(f)



## ----viewH5Structure----------------------------------------------------------------------
#specify how many "levels" of nesting are returns in the command
h5ls(f,recursive=2)
h5ls(f,recursive=3)



## ----readPlotData-------------------------------------------------------------------------
# read in temperature data
temp <- h5read(f,"/Domain_03/OSBS/min_1/boom_1/temperature")

# view the first few lines of the data 
head(temp)

# generate a quick plot of the data, type=l for "line"
plot(temp$mean,type='l')
	


## ----plot-temp-data-----------------------------------------------------------------------


# First read in the time as UTC format
temp$date <- as.POSIXct(temp$date ,format = "%Y-%m-%d %H:%M:%S", tz = "GMT")

# Create a plot using ggplot2 package
OSBS_Plot <- ggplot(temp,aes(x=date,y=mean))+
  geom_path()+
  ylab("Mean temperature") + 
  xlab("Date in UTC")+
  ggtitle("3 Days of Temperature Data at Ordway Swisher")

OSBS_Plot


## ----fix-time-zone------------------------------------------------------------------------

# convert to local time for pretty plotting
attributes(temp$date)$tzone <- "US/Eastern"

# now, plot the data!
OSBS_Plot2 <- ggplot(temp,aes(x=date,y=mean))+
  geom_path()+
  ylab("Mean temperature") + xlab("Date in Eastern Standard Time")+
  theme_bw()+
  ggtitle("3 Days of Temperature Data at Ordway Swisher")

# let's check out the plot
OSBS_Plot2



## ----viewAttributes-----------------------------------------------------------------------

# view temp data on "5th" level
fiu_struct <- h5ls(f,recursive=5)

# have a look at the structure.
fiu_struct

# now we can use this object to pull group paths from our file!
fiu_struct[3,1]

## Let's view the metadata for the OSBS group
OSBS  <- h5readAttributes(f,fiu_struct[3,1])

# view the attributes
OSBS


## ----lat-long-----------------------------------------------------------------------------

# view lat/long
OSBS$LatLon



## ----multGroups---------------------------------------------------------------------------

# use dplyr to subset data by dataset name (temperature)
# and site / 1 minute average
newStruct <- fiu_struct %>% filter(grepl("temperature",name),
                                   grepl("OSBS/min_1",group))

#create final paths to access each temperature dataset
paths <- paste(newStruct$group,newStruct$name,sep="/")

#create a new, empty data.frame
OSBS_temp <- data.frame()



## ----createDataframe----------------------------------------------------------------------

#loop through each temp dataset and add to data.frame
for(i in paths){
  datasetName <- i
  print(datasetName) 
  #read in each dataset in the H5 list
  dat <- h5read(f,datasetName)
  # add boom name to data.frame
  print(strsplit(i,"/")[[1]][5]) 
  dat$boom <- strsplit(i,"/")[[1]][5]
  OSBS_temp <- rbind(OSBS_temp,dat)
}



## ----plotBoomData-------------------------------------------------------------------------

#fix the dates
OSBS_temp$date <- as.POSIXct(OSBS_temp$date,format = "%Y-%m-%d %H:%M:%S", tz = "EST")

#plot the data
OSBS_allPlot <-ggplot(OSBS_temp,aes(x=date,y=mean,group=boom,colour=boom))+
  geom_path()+
  ylab("Mean temperature") + xlab("Date")+
  theme_bw()+
  ggtitle("3 Days of temperature data at Ordway Swisher")+
  scale_x_datetime(breaks=pretty_breaks(n=4))

OSBS_allPlot



## ----compareGroupData---------------------------------------------------------------------
# grab just the paths to temperature data, 30 minute average
pathStrux <- fiu_struct %>% filter(grepl("temperature",name), 
                                   grepl("min_30",group)) 
# create final paths
paths <- paste(pathStrux$group,pathStrux$name,sep="/")

# create empty dataframe
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

# Assign the date field to a "date" format in R
temp_30$date <- as.POSIXct(temp_30$date,format = "%Y-%m-%d %H:%M:%S")

# generate a mean temperature for every date across booms
temp30_sum <- temp_30 %>% group_by(date,site) %>% summarise(mean = mean(mean))

# Create plot!
compPlot <- ggplot(temp30_sum,aes(x=date,y=mean,group=site,colour=site)) + 
  geom_path()+ylab("Mean temperature, 30 Minute Average") + 
  xlab("Date")+
  theme_bw()+
  ggtitle("Comparison of OSBS (FL) vs STER (CO)") +
  scale_x_datetime( breaks=pretty_breaks(n=4))

compPlot


