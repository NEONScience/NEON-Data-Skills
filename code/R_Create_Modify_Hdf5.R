#this R code introduces HDF5 file formats.
#special thanks to Edmund Hart for generating this code!
#adapted from submission in Software Carpentry Materials

#Call the R HDF5 Library
#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")
library("rhdf5")

################ PART 1 #####################

# Create hdf5 file
h5createFile("sensorData.h5")
<<<<<<< HEAD
#create a group called location1 within the H5 file

h5createGroup("sensorData.h5", "location1")

#view the structure of the h5 we've created
h5ls("sensorData.h5")

# let's create some sample, numeric data
someData <- matrix(rnorm(300,2,1),ncol=3,nrow=100)

# add some sample data to the H5 file located in the location1 group
# we'll call the dataset "precip_data" in the H5 file
h5write(someData, file = "sensorData.h5", name="precip_data2")

# let's check out the data again
h5ls("sensorData.h5")

#next let's add an attribute to the data that describes it

#open the file, create a class
fid <- H5Fopen("sensorData.h5")
#open up the dataset to add attributes to as a class
did <- H5Dopen(fid, "precip_data2")

# Provide the NAME and the ATTR (what the attribute says) 
# for the attribute.
h5writeAttribute(did, attr="Here is a description of the data",
                 name="Description")
h5writeAttribute(did, attr="Meters",
                 name="Units")

#close the file and the dataset when you're done writing to them
H5Dclose(did)
H5Fclose(fid)



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

