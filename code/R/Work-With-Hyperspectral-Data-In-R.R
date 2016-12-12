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

#r get spatialInfo using the h5readAttributes function 
spInfo <- h5readAttributes(f,"spatialInfo")

#r get attributes for the Reflectance dataset
reflInfo <- h5readAttributes(f,"Reflectance")



## ----read-band-wavelengths-----------------------------------------------

#read in the wavelength information from the HDF5 file
wavelengths<- h5read(f,"wavelength")



## ----get-reflectance-shape-----------------------------------------------

#note that we can grab the dimensions of the dataset from the attributes
#we can then use that information to slice out our band data
nRows <- reflInfo$row_col_band[1]
nCols <- reflInfo$row_col_band[2]
nBands <- reflInfo$row_col_band[3]

nRows
nCols
nBands

#The HDF5 read function reads data in the order: Cols, Rows and bands
#This is different from how R reads data (rows, columns, bands). We'll adjust for 
#this later

#Extract or "slice" data for band 34 from the HDF5 file
b34<- h5read(f,"Reflectance",index=list(1:nCols,1:nRows,34))
 
#what type of object is b34?
class(b34)


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

#there is a no data value in our raster - let's define it
myNoDataValue <- as.numeric(reflInfo$`data ignore value`)
myNoDataValue

#set all values greater than 15,000 to NA
b34[b34 == myNoDataValue] <- NA


## ----plot-log------------------------------------------------------------

image(log(b34))


## ----transpose-data------------------------------------------------------

#We need to transpose x and y values in order for our final image to plot properly
b34<-t(b34)
image(log(b34), main="Transposed image")



## ----read-map-info-------------------------------------------------------

#Populate the raster image extent value. 
#get the map info, split out elements
mapInfo<-h5read(f,"map info")
#Extract each element of the map info information 
#so we can extract the lower left hand corner coordinates.
mapInfo<-unlist(strsplit(mapInfo, ","))

#view the attributes in the map dataset
mapInfo


## ----define-extent-------------------------------------------------------

#grab resolution of raster as an object
res <- spInfo$xscale
res

#Grab the UTM coordinates of the upper left hand corner of the 
#raster

#grab the left side x coordinate (xMin)
xMin <- as.numeric(mapInfo[4]) 
#grab the top corner coordinate (yMax)
yMax <- as.numeric(mapInfo[5])

xMin
yMax


#Calculate the lower right hand corner to define the full extent of the 
#raster. To do this we need the number of columns and rows in the raster
#and the resolution of the raster.

#note that you need to multiple the columns and rows by the resolution of 
#the data to calculate the proper extent!
xMax <- (xMin + (ncol(b34))*res)
yMin <- (yMax - (nrow(b34))*res) 

xMax
yMin

#define the extent (left, right, top, bottom)
rasExt <- extent(xMin,xMax,yMin,yMax)

rasExt



#assign the spatial extent to the raster
extent(b34r) <- rasExt

#look at raster attributes
b34r


## ----define-CRS----------------------------------------------------------

#Create the projection in as object
myCRS <- spInfo$projdef
myCRS

#define final raster with projection info 
#note that capitalization will throw errors on a MAC.
#if UTM is all caps it might cause an error!
b34r <- raster(b34, 
        crs=myCRS)

b34r

#let's have a look at our properly positioned raster. Take note of the 
#coordinates on the x and y axis.

image(log(b34r), 
      xlab = "UTM Easting", 
      ylab = "UTM Northing",
      main = "Properly Positioned Raster")



## ----plot-colors-raster--------------------------------------------------

#let's change the colors of our raster and adjust the zlims 
col=terrain.colors(25)

image(b34r,  
      xlab = "UTM Easting", 
      ylab = "UTM Northing",
      main= "Raster w Custom Colors",
      col=col, 
      zlim=c(0,3000))


## ----write-raster,  eval=FALSE-------------------------------------------
## 
## #write out the raster as a geotiff
## 
## writeRaster(b34r,
##             file="band34.tif",
##             format="GTiff",
##             overwrite=TRUE)
## 
## #It's always good practice to close the H5 connection before moving on!
## #close the H5 file
## H5close()
## 

