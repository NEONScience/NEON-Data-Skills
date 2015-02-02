
#this code allows you to explore and visualize data in HDF5 format.

#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")


library("rhdf5")

f <- '/Users/lwasser/Documents/GitHub/NEON_HigherEd/data/NEON_TowerDataD3_D10.hdf5'
h5ls(f,all=T)

# HDF5 allows us to quickly extract parts of a dataset or even groups.
# extract temperature data from one site (Ordway Swisher, Florida) and plot it

temp <- h5read(f,"/Domain_03/OSBS/min_1/boom_1/temperature")
#view the header and the first 6 rows of the dataset
head(temp)
plot(temp$mean,type='l')

#let's fix up the plot above a bit. We can first add dates to the x axis. 
#in order to list dates, we need to specify the format that the date field is in.
temp$date <- as.POSIXct(temp$date ,format = "%Y-%m-%d %H:%M:%S", tz = "EST")

ordwayPlot <- qplot (date,mean,data=temp,geom="line", title="ordwayData",
                 main="Mean Temperature - Ordway Swisher", xlab="Date", 
                 ylab="Mean Temperature (Degrees C)")

#let's check out the plot
ordwayPlot

####################
#more info on customizing plots
#http://www.statmethods.net/advgraphs/ggplot2.html
######################

# Extracting metadata from an HDF5 file

## Get names of elements in our file
fiu_struct <- h5ls(f,all=T)
## Concatenate the second element.
g <- paste(fiu_struct[2,1:2],collapse="/")
## Check out what that element is
print(g)
## Now view the metadata
h5readAttributes(f,g)



#r compare temperatuer data for different booms at the Ordway Swisher site.
library(dplyr)
library(ggplot2)
# Set the path string
s <- "/Domain_03/OSBS/min_1"


#grab the paths

paths <- fiu_struct %>% filter(grepl(s,group), grepl("DATA",otype)) %>% group_by(group) %>% summarise(path = paste(group,name,sep="/"))
ord_temp <- data.frame()

#this loops through and creates a final dataframe
for(i in paths$path){
  boom <-  strsplit(i,"/")[[1]][5]
  dat <- h5read(f,i)
  dat$boom <- rep(boom,dim(dat)[1])
  ord_temp <- rbind(ord_temp,dat)
}


#fix the dates
ord_temp$date <- as.POSIXct(ord_temp$date,format = "%Y-%m-%d %H:%M:%S", tz = "EST")

#plot the data
ggplot(ord_temp,aes(x=date,y=mean,group=boom,colour=boom))+geom_path()+ylab("Mean temperature") + xlab("Date")+theme_bw()+ggtitle("3 Days of temperature data at Ordway Swisher")


### We want all sites in the minute 30 so this will help us prune our list
s <- "min_30"
# Grab the paths for all sites, 30 minute averaged data
paths <- fiu_struct %>% filter(grepl(s,group), grepl("DATA",otype)) %>% group_by(group) %>% summarise(path = paste(group,name,sep="/"))

temp_30 <- data.frame()
for(i in paths$path){
  boom <-  strsplit(i,"/")[[1]][5]
  site <- strsplit(i,"/")[[1]][3]
  dat <- h5read(f,i)
  dat$boom <- rep(boom,dim(dat)[1])
  dat$site <- rep(site,dim(dat)[1])
  temp_30 <- rbind(temp_30,dat)
}

#Assign the date field to a "date" format in R
temp_30$date <- as.POSIXct(temp_30$date,format = "%Y-%m-%d %H:%M:%S")

#assign a mean value for all three booms. 
temp30_sum <- temp_30 %>% group_by(site,date) %>% summarise(mean = mean(mean))

#Create plot!
thePlot <- ggplot(temp30_sum,aes(x=date,y=mean,group=site,colour=site)) + geom_path() +ylab("Mean temperature") + xlab("Date")+theme_bw()+ggtitle("Comparison of Ordway-Swisher vs Sterling CO")

finalPlot2<-thePlot + scale_colour_discrete(name="NEON Site",
                                           breaks=c("OSBS", "STER"),
                                           labels=c("Ordway Swisher Biological Station", "Sterling"))
finalPlot2
