## ----install-rhdf5-------------------------------------------------------

# Install rhdf5 package (only need to run if not already installed)
#install.packages("BiocManager")
#BiocManager::install("rhdf5")

# Call the R HDF5 Library
library("rhdf5")

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files
#setwd("working-dir-path-here")

## ----create-hdf5---------------------------------------------------------

# create hdf5 file
h5createFile("sensorData.h5")
# create group for location 1
h5createGroup("sensorData.h5", "location1")


## ----loop-groups---------------------------------------------------------
# Create loops that will populate 2 additional location "groups" in our HDF5 file
	l1 <- c("location2","location3")
	for(i in 1:length(l1)){
  	  h5createGroup("sensorData.h5", l1[i])
	}

## ----view-structure------------------------------------------------------
# View HDF5 File Structure
h5ls("sensorData.h5")


## ----create-loop---------------------------------------------------------
# Add datasets to each group
for(i in 1:3){
      g <- paste("location",i,sep="")
      
      # populate matrix with dummy data
      # create precip dataset within each location group
      h5write(
      	matrix(rnorm(300,2,1),
      				 ncol=3,nrow=100),
			file = "sensorData.h5",
			paste(g,"precip",sep="/"))
      
      #create temperature dataset within each location group
      h5write(
      	matrix(rnorm(300,25,5),
      				 ncol=3,nrow=100),
			file = "sensorData.h5",
			paste(g,"temp",sep="/"))
	}

## ----test----------------------------------------------------------------
# 1
paste(g, "precip", sep="/")
# 2
rnorm(300,2,1)
# 3
g
# 4
help(norm)

## ----file-str------------------------------------------------------------
	# List file structure
	h5ls("sensorData.h5")

## ----metadata------------------------------------------------------------

# Create matrix of "dummy" data
p1 <- matrix(rnorm(300,2,1),ncol=3,nrow=100)
# Add attribute to the matrix (units)
attr(p1,"units") <- "millimeters"

# Write the R matrix to the HDF5 file 
h5write(p1,file = "sensorData.h5","location1/precip",write.attributes=T)

# Close the HDF5 file
H5close()


## ----read-hdf5-----------------------------------------------------------
# Read in all data contained in the precipitation dataset 
l1p1 <- h5read("sensorData.h5","location1/precip",
							 read.attributes=T)

# Read in first 10 lines of the data contained within the precipitation dataset 
l1p1s <- h5read("sensorData.h5","location1/precip",
								read.attributes = T,index = list(1:10,NULL))



