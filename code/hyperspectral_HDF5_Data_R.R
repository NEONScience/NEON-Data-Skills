#this R code demonstrates how to bring in, visualize and work with spatial HDF5 data into R.
#Special thanks to Edmund Hart for developing this code!
#adapted by Leah A. Wasser 

#r Load `raster` and `rhdf5` packages and read NIS data into R
library(raster)
library(rhdf5)
library(rgdal)

#make sure you have atleast rhdf5 version 2.10 installed
packageVersion("rhdf5")

#update rhdf5 if needed.
#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")

#specify the path to the H5 file. Notice that HDF5 extension can be either "hdf5" or "h5"
f <- '/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/HDF5File/SJER_140123_chip.h5'
#f <- '/Users/law/Documents/data/SJER_140123_chip.h5'

#look at the HDF5 file structure. take note of the
#dimensions of the reflectance dataset (477 x 502 x 426)
# columns, rows and band
h5ls(f,all=T)

#r get spatial info and map info using the h5readAttributes function developed by Ted Hart
spinfo <- h5readAttributes(f,"spatialInfo")

#get the dimensions of the wavelengths dataset in the H5 file
shapeWave<-dim(h5read(f,"wavelength"))
       
#read in the wavelength information from the Hdf5 file using the shape information above
wavelengths<- h5read(f,"wavelength",index=list(1:shapeWave[1],shapeWave[2]))

#get the dimensions of the reflectance dataset in the H5 file

shapeRefl<-dim(h5read(f,"Reflectance"))

#r extract "slices" of data from an HDF5 file (read in only the parts that you need)
#in this case we are extracting band 34 from the data
b34<- h5read(f,"Reflectance",index=list(1:shapeRefl[1],1:shapeRefl[2],34))

#Convert from array to matrix
b34 <- b34[,,1]

#let's look at the dimensions of the b34 objects
#notice that the dimensions are 477 x 502
dim(b34)
refInfo <- h5readAttributes(f,"Reflectance")

#we're done with the H5 file - close it
#close the H5 file
H5close()

#note - when R imports the matrix, the dimensions are read in reverse order
#so we need to transpose x and y values in order for our final image to plot properly
b34<-t(b34)

#plot image
image(b34)

#View range of reflectance values.
#when a program applies color to each pixel in a raster, it stretches
hist(b34,breaks=40,col="darkmagenta",
     main="Distribution of Reflectance Values",
     xlab="Reflectance")
hist(b34,breaks=40,col="darkmagenta",xlim = c(0, 5000),
     main="Distribution of Reflectance Values",
     xlab="Reflectance")
hist(b34, breaks=40,col="darkmagenta",xlim = c(5000, 15000),
     ylim=c(0,100),
     main="Distribution of Reflectance Values",
     xlab="Reflectance")
#set data ignore value (15000) to NA (null value)

b34[b34 > 14999] <- NA
image(b34)
image(log(b34))


#######################
#Convert Matrix to Raster
#######################


#Populate the raster image extent value. 
#get the map info, split out elements
mapInfo<-h5read(f,"map info")
mapInfo<-unlist(strsplit(mapInfo, ","))

#define extents of the data using metadata and matrix attributes
xMN=as.numeric(mapInfo[4])
xMX=(xMN+(ncol(b34)))
yMX=as.numeric(mapInfo[5]) 
yMN=(yMN-(nrow(b34)))
     

#define final raster with projection info 
#note, this will throw errors on a MAC if the UTM is capitalized!
b34r<-raster(b34, 
            crs=(spinfo$projdef))

#assign the spatial extent to the raster
extent(b34r) <- rasExt
image(b34r)

#Write out the final raster
writeRaster(b34r,file="band34.tif",overwrite=TRUE)


