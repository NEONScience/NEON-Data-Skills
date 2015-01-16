#this R code introduces HDF5 file formats.
#special thanks to Edmund Hart for generating this code!
#adapted from submission in Software Carpentry Materials

#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")
library("rhdf5")

#create hdf5 file
h5createFile("sensorData.h5")
h5createGroup("sensorData.h5", "location1")

#let's check out what we've created so far
h5ls("sensorData.h5")

#create loops that populate the hdf5 structure 
#for 2 other locations
l1 <- c("location2","location3")
for(i in 1:length(l1)){
  h5createGroup("sensorData.h5", l1[i])
}

#Notice now we have 3 groups in our hdf5 file
#representing locations 1-3
h5ls("sensorData.h5")

#next, let's simulate some data
#r add data
for(i in 1:3){
  g <- paste("location",i,sep="")
  
  h5write(matrix(rnorm(300,2,1),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"precip",sep="/"))
  h5write(matrix(rnorm(300,25,5),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"temp",sep="/"))
}

#r ls again ti see the new file structure with the datasets added
h5ls("sensorData.h5")

#r add metadata to our datasets
p1 <- matrix(rnorm(300,2,1),ncol=3,nrow=100) 
attr(p1,"units") <- "millimeters"

#r read the precipitation data in for location 1
l1p1 <- h5read("sensorData.h5","location1/precip",read.attributes=T)
#read in just the first 10 lines 
l1p1s <- h5read("sensorData.h5","location1/precip",read.attributes = T,index = list(1:10,NULL))

