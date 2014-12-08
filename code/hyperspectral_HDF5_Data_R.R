#this R code demonstrates how to bring in, visualize and work with spatial HDF5 data into R.
#Special thanks to Edmund Hart for developing this code!
#adapted by Leah A. Wasser 

#r Load `raster` and `rhdf5` packages and read NIS data into R
library(raster)
library(rhdf5)

#make sure you have atleast rhdf5 version 2.10 installed
packageVersion("rhdf5")

#update rhdf5 if needed.
#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")

#specify the path to the H5 file. Notice that HDF5 extension can be either "hdf5" or "h5"
#f <- '/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/HDF5File/SJER_140123_chip.h5'
f <- '/Users/law/Documents/data/SJER_140123_chip.h5'

#look at the HDF5 file structure 
h5ls(f,all=T)

#r get spatial info and map info using the h5readAttributes function developed by Ted Hart
spinfo <- h5readAttributes(f,"spatialInfo")

#read in the wavelength information from the Hdf5 file
wavelengths<- h5read(f,"wavelength",index=list(1:426,1))

#r extract "slices" of data from an HDF5 file (read in only the parts that you need)
b34<- h5read(f,"Reflectance",index=list(1:477,1:502,34))

#Convert from array to matrix
b34 <- b34[,,1]

#note - when R brings in the matrix, the dimensions are read in reverse order
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

#convert matrix to raster
#b34r <- raster((b34))
#plot(b34r)

#http://stackoverflow.com/questions/14513480/convert-matrix-to-raster-in-r

# grab raster extent from the metadata
#ex <- sort(unlist(spinfo[2:5]))
#e <- extent(ex)
#assign the extent to the raster
#extent(b34r) <- e



#The code below gets the extend from the map info this -- 
#get the map info, split out elements
mapInfo<-h5read(f,"map info")
mapInfo<-unlist(strsplit(a, ","))

#define extents of the data using metadata and matrix attributes
xmn=as.numeric(mapInfo[4])
xmx=(xmn+nrow(b34))
ymn=as.numeric(mapInfo[5]) 
ymx=(ymn+ncol(b34))

#define final raster with projection info and extents
b34r<-raster(b34, 
            xmn, xmx, ymn,ymx, #the extent info
            crs=CRS("+proj=utm +zone=11 +datum=WGS84+ellps=WGS84")
            )

