#this R code demonstrates how to bring in, visualize and work with spatial HDF5 data into R.
#Special thanks to Edmund Hart for developing this code!
#adapted by Leah A. Wasser 

#r Load `raster` and `rhdf5` packages and read NIS data into R
library(raster)
library(rhdf5)
#f <- '/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/HDF5File/SJER_140123_chip.h5'
f <- '/Users/law/Documents/GitHub_Lwasser/NEON_HigherEd/data/SJER_140123_chip.h5'

#look at the HDF5 file structure 
h5ls(f,all=T)

#make sure the hdf5 metadata function is loaded
source("/Users/law/Documents/GitHub_Lwasser/NEON_HigherEd/code/h5metadata.R")

#r get spatial info and map info
spinfo <- h5metadata(f,"spatialInfo",11)
