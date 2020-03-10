## ----call-libraries, results="hide"----------------------------------------------------

# Call required packages
library(rhdf5)
library(plyr)
library(ggplot2)

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. Be sure to move the download into your working directory!
wd <- "~/Documents/data/" #This will depend on your local environment
setwd(wd)



## ----open-H5-file----------------------------------------------------------------------

# Define the file name to be opened
f <- paste0(wd,"NEON_hyperspectral_tutorial_example_subset.h5")
# look at the HDF5 file structure 
h5ls(f,all=T) 



## ----read-band-wavelengths-------------------------------------------------------------

# read in the wavelength information from the HDF5 file
wavelengths <- h5read(f,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")



## ----extract-spectra-------------------------------------------------------------------

# extract all bands from a single pixel
aPixel <- h5read(f,"/SJER/Reflectance/Reflectance_Data",index=list(NULL,100,35))

# The line above generates a vector of reflectance values.
# Next, we reshape the data and turn them into a dataframe
b <- adply(aPixel,c(1))

# create clean data frame
aPixeldf <- b[2]

# add wavelength data to matrix
aPixeldf$Wavelength <- wavelengths

head(aPixeldf)



## ----pull-scale-factor-----------------------------------------------------------------

# grab scale factor from the Reflectance attributes
reflectanceAttr <- h5readAttributes(f,"/SJER/Reflectance/Reflectance_Data" )

scaleFact <- reflectanceAttr$Scale_Factor

# add scaled data column to DF
aPixeldf$scaled <- (aPixeldf$V1/as.vector(scaleFact))

# make nice column names
names(aPixeldf) <- c('Reflectance','Wavelength','ScaledReflectance')
head(aPixeldf)



## ----plot-spectra----------------------------------------------------------------------

qplot(x=aPixeldf$Wavelength, 
      y=aPixeldf$ScaledReflectance,
      geom="line",
      xlab="Wavelength (nm)",
      ylab="Reflectance")


