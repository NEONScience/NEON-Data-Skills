## ----call-libraries, results="hide"--------------------------------------

#first call required libraries
library(rhdf5)
library(plyr)
library(ggplot2)


## ----open-H5-file--------------------------------------------------------

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
#convert wavelength to nanometers (nm)
#NOTE: this is optional!
wavelengths <- wavelengths*1000


## ----extract-spectra-----------------------------------------------------

#extract Some Spectra from a single pixel
aPixel<- h5read(f,"Reflectance",index=list(54,36,NULL))

#reshape the data and turn into dataframe
b <- adply(aPixel,c(3))

#create clean data frame
aPixeldf <- b[2]


#add wavelength data to matrix
aPixeldf$Wavelength <- wavelengths

head(aPixeldf)



## ----pull-scale-factor---------------------------------------------------

#grab scale factor
scaleFact <- reflInfo$`Scale Factor`

#add scaled data column to DF
aPixeldf$scaled <- (aPixeldf$V1/scaleFact)

#make nice column names
names(aPixeldf) <- c('Reflectance','Wavelength','ScaledReflectance')
head(aPixeldf)


## ----plot-spectra--------------------------------------------------------

qplot(x=aPixeldf$Wavelength, 
      y=aPixeldf$ScaledReflectance,
      xlab="Wavelength (nm)",
      ylab="Reflectance")


