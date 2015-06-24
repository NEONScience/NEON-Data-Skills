## ----install-load-library, results="hide"--------------------------------

#use the code below to install the rhdf5 library if it's not already installed.
#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")

#r Load `raster` and `rhdf5` packages and read NIS data into R
library(raster)
library(rhdf5)
library(rgdal)




## ----set-wd-view-file-strux----------------------------------------------


#be sure to set the working directory to the location where you saved your
# the SJER_120123_chip.h5 file
#setwd('pathToDataHere')
getwd()

#Define the file name to be opened
f <- 'SJER_140123_chip.h5'
#look at the HDF5 file structure 
h5ls(f,all=T) 


## ----read-spatial-attributes---------------------------------------------

#r get spatial info and map info using the h5readAttributes function 
spinfo <- h5readAttributes(f,"spatialInfo")

#r get attributes for the Reflectance dataset
reflInfo <- h5readAttributes(f,"Reflectance")



## ----read-band-wavelengths-----------------------------------------------

#read in the wavelength information from the HDF5 file
wavelengths<- h5read(f,"wavelength")


## ----get-reflectance-shape-----------------------------------------------

#note that we can grab tne dimensions of the dataset from the attributes
#we can then use that information to slice out our band data
nRows <- reflInfo$row_col_band[1]
nCols <- reflInfo$row_col_band[2]
nBands <- reflInfo$row_col_band[3]

#The HDF5 read function reads data in the order: Cols, Rows and bands
#This is different from how R reads data (rows, columns, bands). We'll adjust for 
#this later

#Extract or "slice" data for band 34 from the HDF5 file
b34<- h5read(f,"Reflectance",index=list(1:nCols,1:nRows,34))
 

## ----convert-to-matrix---------------------------------------------------

#Convert from array to matrix
b34 <- b34[,,1]


## ----read-attributes-plot------------------------------------------------
    
# look at the metadata for the reflectance dataset
h5readAttributes(f,"Reflectance")
#plot the image

image(b34)

#what happens if we plot a log of the data?
image(log(b34))
#note - when R brings in the matrix, the dimensions are read in reverse order
    


## ----hist-data-----------------------------------------------------------

#Plot range of reflectance values as a histogram to view range
#and distribution of values.
hist(b34,breaks=40,col="darkmagenta")
#View values between 0 and 5000
hist(b34,breaks=40,col="darkmagenta",xlim = c(0, 5000))
hist(b34, breaks=40,col="darkmagenta",xlim = c(5000, 15000),ylim=c(0,100))


## ----set-values-NA-------------------------------------------------------
#set all values greater than 15000
b34[b34 == 15000] <- NA


## ----plot-log------------------------------------------------------------

image(log(b34))


## ----transpose-data------------------------------------------------------

#We need to transpose x and y values in order for our final image to plot properly
b34<-t(b34)
image(log(b34))



## ----define-extent-------------------------------------------------------

#define extents of the data using metadata and matrix attributes
xMN=as.numeric(mapInfo[4])
xMX=(xMN+(ncol(b34)))
yMX=as.numeric(mapInfo[5]) 
yMN=(yMX-(nrow(b34)))     
rasExt <- extent(xMN,xMX,yMN,yMX)

#define final raster with projection info 
#note that capitalization will throw errors on a MAC.
#if UTM is all caps it might cause an error!
b34r<-raster(b34, 
      crs=(spinfo$projdef))

#assign the spatial extent to the raster
extent(b34r) <- rasExt
#look at raster attributes
b34r

image(log(b34r), 
      xlab = "UTM Easting", 
      ylab = "UTM Northing",
      main= "Properly Positioned Raster")



## ----plot-colors-raster--------------------------------------------------

#let's change the colors of our raster and adjust the zlims 
col=terrain.colors(25)
image(b34r, main="Band 58", col=col, zlim=c(0,3000))

## ----write-raster,  eval=FALSE-------------------------------------------
## 
## #write out the raster as a geotiff
## 
## writeRaster(b34r,file="band34.tif",overwrite=TRUE)
## 
## 
## #close the H5 file
## H5close()
## 

