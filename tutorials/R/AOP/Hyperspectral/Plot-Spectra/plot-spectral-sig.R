
# Import required libraries
library(rhdf5)
library(plyr)
library(ggplot2)
library(neonUtilities)

token <- Sys.getenv("NEON_TOKEN")

data_dir <- "~/data/"

byTileAOP(dpID = 'DP3.30006.001',
          site = 'SJER',
          year = '2021',
          easting = 257000,
          northing = 4112000,
          savepath = data_dir,
          token=token)

# define the h5 file name (specify the full path)
h5_file <- paste0(data_dir,"DP3.30006.001/neon-aop-products/2021/FullSite/D17/2021_SJER_5/L3/Spectrometer/Reflectance/NEON_D17_SJER_DP3_257000_4112000_reflectance.h5")

# look at the HDF5 file structure 
h5ls(h5_file) #optionally specify all=True if you want to see all of the information

# read in the wavelength information from the HDF5 file
wavelengths <- h5read(h5_file,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")

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


# grab scale factor from the Reflectance attributes
reflectanceAttr <- h5readAttributes(h5_file,"/SJER/Reflectance/Reflectance_Data" )

scaleFact <- reflectanceAttr$Scale_Factor

# add scaled data column to DF
aPixeldf$scaled <- (aPixeldf$V1/as.vector(scaleFact))

# make nice column names
names(aPixeldf) <- c('Reflectance','Wavelength','ScaledReflectance')
head(aPixeldf)



ggplot(data=aPixeldf)+
   geom_line(aes(x=Wavelength, y=ScaledReflectance))+
   xlab("Wavelength (nm)")+
   ylab("Reflectance")

