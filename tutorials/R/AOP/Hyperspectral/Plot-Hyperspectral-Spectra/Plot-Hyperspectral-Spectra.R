## ----call-libraries, results="hide"------------------------------------------------------------------------------------------------------------------------------------------

# Call required packages
library(rhdf5)
library(plyr)
library(ggplot2)
library(neonUtilities)

wd <- "~/data/" #This will depend on your local environment
setwd(wd)


## ----download-refl, eval=FALSE-----------------------------------------------------------------------------------------------------------------------------------------------
## byTileAOP(dpID = 'DP3.30006.001',
##           site = 'SJER',
##           year = '2021',
##           easting = 257500,
##           northing = 4112500,
##           savepath = wd)


## ----open-H5-file------------------------------------------------------------------------------------------------------------------------------------------------------------
# define the h5 file name (specify the full path)
h5_file <- paste0(wd,"DP3.30006.001/neon-aop-products/2021/FullSite/D17/2021_SJER_5/L3/Spectrometer/Reflectance/NEON_D17_SJER_DP3_257000_4112000_reflectance.h5")

# look at the HDF5 file structure 
h5ls(h5_file) #optionally specify all=True if you want to see all of the information


## ----read-band-wavelengths---------------------------------------------------------------------------------------------------------------------------------------------------
# read in the wavelength information from the HDF5 file
wavelengths <- h5read(h5_file,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")


## ----extract-spectra---------------------------------------------------------------------------------------------------------------------------------------------------------
# extract all bands from a single pixel
aPixel <- h5read(h5_file,"/SJER/Reflectance/Reflectance_Data",index=list(NULL,100,35))

# The line above generates a vector of reflectance values.
# Next, we reshape the data and turn them into a dataframe
b <- adply(aPixel,c(1))

# create clean data frame
aPixeldf <- b[2]

# add wavelength data to matrix
aPixeldf$Wavelength <- wavelengths

head(aPixeldf)


## ----pull-scale-factor-------------------------------------------------------------------------------------------------------------------------------------------------------

# grab scale factor from the Reflectance attributes
reflectanceAttr <- h5readAttributes(h5_file,"/SJER/Reflectance/Reflectance_Data" )

scaleFact <- reflectanceAttr$Scale_Factor

# add scaled data column to DF
aPixeldf$scaled <- (aPixeldf$V1/as.vector(scaleFact))

# make nice column names
names(aPixeldf) <- c('Reflectance','Wavelength','ScaledReflectance')
head(aPixeldf)



## ----plot-spectra, fig.width=9, fig.height=6, fig.cap="Spectral signature plot with wavelength in nanometers on the x-axis and reflectance on the y-axis."-------------------

ggplot(data=aPixeldf)+
   geom_line(aes(x=Wavelength, y=ScaledReflectance))+
   xlab("Wavelength (nm)")+
   ylab("Reflectance")


