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
  
  h5write(matrix(rgamma(300,2,1),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"precip",sep="/"))
  h5write(matrix(rnorm(300,25,5),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"temp",sep="/"))
}

#r ls again ti see the new file structure with the datasets added
h5ls("sensorData.h5")

#r add metadata to our datasets
p1 <- matrix(rgamma(300,2,1),ncol=3,nrow=100) 
attr(p1,"units") <- "millimeters"

#r read the precipitation data in for location 1
l1p1 <- h5read("sensorData.h5","location1/precip",read.attributes=T)
#read in just the first 10 lines 
l1p1s <- h5read("sensorData.h5","location1/precip",read.attributes = T,index = list(1:10,NULL))

#REAL WORLD DATA EXAMPLE
#r load file (make sure the path is correct!!)
f <- "/Users/law/Documents/GitHub_Lwasser/NEON_HigherEd/data/fiuTestFile.hdf5"
h5ls(f,all=T)

# HDF5 allows us to quickly extract parts of a dataset or even groups.
# extract temperature data from one site (Ordway Swisher, Florida) and plot it

temp <- h5read(f,"/Domain_03/Ord/min_1/boom_1/temperature")
#view the header and the first 6 rows of the dataset
head(temp)
plot(temp$mean,type='l')


#r extracting metadata from an HDF5 file
# Open file
out <- H5Fopen(f)
# open a group
g <- H5Gopen(out,'/Domain_03/Ord')
a <- H5Aopen_by_idx(g,1)
H5Aget_name(a)


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


#Create Function that Extracts All Metadata in a group


# Use Function to Extract metadata
fiu_struct <- h5ls(f,all=T)
g <- paste(fiu_struct[2,1:2],collapse="/")
h5metadata(f,g,fiu_struct$num_attrs[2])



