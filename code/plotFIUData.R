library("rhdf5")
library("devtools")
library("plotly")


#setup plotly credentials
set_credentials_file("leahawasser", "tpdjz2b8pu")
l <- plotly(username="leahawasser", key="tpdjz2b8pu")

#REAL WORLD DATA EXAMPLE
#r load file (make sure the path is correct!!)
#MAC f <- "/Users/law/Documents/GitHub_Lwasser/NEON_HigherEd/data/fiuTestFile.hdf5"
f <- '/Users/lwasser/Documents/GitHub/NEON_HigherEd/data/NEON_TowerDataD3_D10.hdf5'
h5ls(f,all=T)

# HDF5 allows us to quickly extract parts of a dataset or even groups.
# extract temperature data from one site (Ordway Swisher, Florida) and plot it

temp <- h5read(f,"/Domain_03/Ord/min_1/boom_1/temperature")
#view the header and the first 6 rows of the dataset


set_credentials_file("leahawasser", "tpdjz2b8pu")
p <- plotly(username="leahawasser", key="tpdjz2b8pu")

head(temp)
plot(temp$mean,type='l')
response = p$plotly(temp$mean,type='l')
browseURL(response$url)



library(plotly)
or=temp

py <- plotly(username="leahawasser", key="tpdjz2b8pu")

or$A <- temp$mean
#fit the dates
temp$date <- as.POSIXct(temp$date ,format = "%Y-%m-%d %H:%M:%S", tz = "EST")

orange <- qplot (date,mean,data=temp,geom="line", title="hello",
                 main="Mean Temperature - Ordway Swisher", xlab="Date", 
                 ylab="Mean Temperature (Degrees C)")

orange + theme(axis.title=element_text(face="bold.italic", 
                                  size="24", color="brown"))
orange

out <- py$ggplotly(orange)

plotly_url <- out$response$url










#r extracting metadata from an HDF5 file
# Open file
out <- H5Fopen(f)
# open a group
g <- H5Gopen(out,'/Domain_03/Ord')
#view the first attribute stored in the attributes for the group above (g)
a <- H5Aopen_by_idx(g,1)
H5Aget_name(a)
#get the value for the attribute (in this case it's the site name)
aval <- H5Aread(a)
aval

#Be sure to close all files that you opened!
H5Aclose(a)
H5Gclose(g)
H5Fclose(out)


#The above methods are tedious. Let's create a function that
#will extract all metadata available for a group without our file

h5metadata <- function(fileN, group, natt){
  out <- H5Fopen(fileN)
  g <- H5Gopen(out,group)
  output <- list()
  for(i in 0:(natt-1)){
    ## Open the attribute
    a <- H5Aopen_by_idx(g,i)
    output[H5Aget_name(a)] <-  H5Aread(a)
    ## Close the attributes
    H5Aclose(a)
  }
  H5Gclose(g)
  H5Fclose(out)
  return(output)
}


# Use Function to Extract metadata
fiu_struct <- h5ls(f,all=T)
g <- paste(fiu_struct[2,1:2],collapse="/")
h5metadata(f,g,fiu_struct$num_attrs[2])



#r compare temperatuer data for different booms at the Ordway Swisher site.
library(dplyr)
library(ggplot2)
# Set the path string
s <- "/Domain_03/Ord/min_1"


###All clear until here *****************************************************
#the next part is a way to automate mining the file, pulling out the paths to the temperature data that we 
#want to plot per boom at Ordway. This code is complex but it eliminates the need for us to manually type in the paths to the data
#that we want to use. 

paths <- fiu_struct %.% filter(grepl(s,group), grepl("DATA",otype)) %.% group_by(group) %.% summarise(path = paste(group,name,sep="/"))
ord_temp <- data.frame()

#this loops through and creates a final dataframe
for(i in paths$path){
  boom <-  strsplit(i,"/")[[1]][5]
  dat <- h5read(f,i)
  dat$boom <- rep(boom,dim(dat)[1])
  ord_temp <- rbind(ord_temp,dat)
}


ord_temp$date <- as.POSIXct(ord_temp$date,format = "%Y-%m-%d %H:%M:%S", tz = "EST")

ggplot(ord_temp,aes(x=date,y=mean,group=boom,colour=boom))+geom_path()+ylab("Mean temperature") + xlab("Date")+theme_bw()+ggtitle("3 Days of temperature data at Ordway Swisher")



s <- "min_30"
# Grab the paths for all sites, 30 minute averaged data
paths <- fiu_struct %.% filter(grepl(s,group), grepl("DATA",otype)) %.% group_by(group) %.% summarise(path = paste(group,name,sep="/"))

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
temp30_sum <- temp_30 %.% group_by(date,site) %.% summarise(mean = mean(mean))

#Create plot!
ggplot(temp30_sum,aes(x=date,y=mean,group=site,colour=site)) + geom_path()+ylab("Mean temperature") + xlab("Date")+theme_bw()+ggtitle("Comparison of Ordway-Swisher(FL) vs Sterling(CO)")
