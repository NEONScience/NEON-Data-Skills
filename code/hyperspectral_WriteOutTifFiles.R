#this R code demonstrates how to bring in, visualize and work with spatial HDF5 data into R.
#Special thanks to Edmund Hart for developing this code!
#adapted by Leah A. Wasser 

#r Load `raster` and `rhdf5` packages and read NIS data into R
library(raster)
library(rhdf5)
library(rgdal)

#update rhdf5 if needed.
#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")

#specify the path to the H5 file. Notice that HDF5 extension can be either "hdf5" or "h5"
f <- 'SJER_140123_chip.h5'

#r get spatial info and map info using the h5readAttributes function developed by Ted Hart
spinfo <- h5readAttributes(f,"spatialInfo")

#get the dimensions of the wavelengths dataset in the H5 file
shapeWave<-dim(h5read(f,"wavelength"))
       
#read in the wavelength information from the Hdf5 file using the shape information above
wavelengths<- h5read(f,"wavelength",index=list(1:shapeWave[1],shapeWave[2]))

#get the dimensions of the reflectance dataset in the H5 file

shapeRefl<-dim(h5read(f,"Reflectance"))

#r extract "slices" of data from an HDF5 file (read in only the parts that you need)
#in this case we are extracting band 90 from the data
b90<- h5read(f,"Reflectance",index=list(1:shapeRefl[1],1:shapeRefl[2],90))

#Convert from array to matrix
b90 <- b90[,,1]

#let's look at the dimensions of the b90 objects
#notice that the dimensions are 477 x 502
dim(b90)
refInfo <- h5readAttributes(f,"Reflectance")

#we're done with the H5 file - close it
#close the H5 file
H5close()

#note - when R imports the matrix, the dimensions are read in reverse order
#so we need to transpose x and y values in order for our final image to plot properly
b90<-t(b90)

#plot image
image(b90)


#set data ignore value (15000) to NA (null value)

b90[b90 > 14999] <- NA
image(b90)
image(log(b90))


#######################
#Convert Matrix to Raster
#######################


#Populate the raster image extent value. 
#get the map info, split out elements
mapInfo<-h5read(f,"map info")
mapInfo<-unlist(strsplit(mapInfo, ","))

#define extents of the data using metadata and matrix attributes
xMN=as.numeric(mapInfo[4])
xMX=(xMN+(ncol(b90)))
yMX=as.numeric(mapInfo[5]) 
yMN=(yMN-(nrow(b90)))
     

#define final raster with projection info 
#note, this will throw errors on a MAC if the UTM is capitalized!
b90r<-raster(b90, 
            crs=(spinfo$projdef))

#assign the spatial extent to the raster
extent(b90r) <- rasExt
image(b90r)

#Write out the final raster
writeRaster(b90r,file="band90.tif",overwrite=TRUE)


##################### read in raster

