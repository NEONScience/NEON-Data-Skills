## ----load libraries-----------------------------------------------------------------------

# Install rhdf5 package (only need to run if not already installed)
#install.packages("BiocManager")
#BiocManager::install("rhdf5")

# Call the R HDF5 Library
library("rhdf5")

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files
#setwd("working-dir-path-here")



## ----create_new_hdf5_file-----------------------------------------------------------------

# Create hdf5 file
h5createFile("vegData.h5")
h5createFile()

# create a group called aNEONSite within the H5 file
h5createGroup("vegData.h5", "aNEONSite")

# view the structure of the h5 we've created
h5ls("vegData.h5")


## ----create_sample_data-------------------------------------------------------------------
# create some sample, numeric data 
a <- rnorm(n=40, m=1, sd=1) 
someData <- matrix(a,nrow=20,ncol=2)


## ----add_data_to_file---------------------------------------------------------------------

# add some sample data to the H5 file located in the aNEONSite group
# we'll call the dataset "temperature"
h5write(someData, file = "vegData.h5", name="aNEONSite/temperature")

# let's check out the H5 structure again
h5ls("vegData.h5")



## ----view_h5_contents---------------------------------------------------------------------

# we can look at everything too 
# but be cautious using this command!
h5dump("vegData.h5")

# Close the file. This is good practice.
H5close()



## ----add-attributes-to-file---------------------------------------------------------------

# open the file, create a class
fid <- H5Fopen("vegData.h5")
# open up the dataset to add attributes to, as a class
did <- H5Dopen(fid, "aNEONSite/temperature")

# Provide the NAME and the ATTR (what the attribute says) for the attribute.
h5writeAttribute(did, attr="Here is a description of the data",
                 name="Description")
h5writeAttribute(did, attr="Meters",
                 name="Units")



## ----group-attributes---------------------------------------------------------------------
# let's add some attributes to the group
did2 <- H5Gopen(fid, "aNEONSite/")

h5writeAttribute(did2, attr="San Joaquin Experimental Range",
                 name="SiteName")

h5writeAttribute(did2, attr="Southern California",
                 name="Location")

# close the files, groups and the dataset when you're done writing to them!
H5Dclose(did)

H5Gclose(did2)

H5Fclose(fid)



## ----read & review attributes-------------------------------------------------------------

# look at the attributes of the precip_data dataset
h5readAttributes(file = "vegData.h5", 
                 name = "aNEONSite/temperature")

# look at the attributes of the aNEONsite group
h5readAttributes(file = "vegData.h5", 
                 name = "aNEONSite")

# let's grab some data from the H5 file
testSubset <- h5read(file = "vegData.h5", 
                 name = "aNEONSite/temperature")

testSubset2 <- h5read(file = "vegData.h5", 
                 name = "aNEONSite/temperature",
                 index=list(NULL,1))
H5close()




## ----access-plot-data---------------------------------------------------------------------

# create a quick plot of the data
hist(testSubset2)



## ----challenge-code-HDF5-file, echo=FALSE-------------------------------------------------

# options(stringsAsFactors = FALSE)
# newData <- read.csv("D17_2013_SJER_vegStr.csv")


