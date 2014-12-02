#r Load `raster` and `rhdf5` packages and read NIS data into R
library(raster)
library(rhdf5)

h5metadata <- function(fileN, group, natt){
  out <- H5Fopen(fileN)
  g <- H5Gopen(out,group)
  output <- list()
  for(i in 0:(natt-1)){
    ## Open the attribute
    a <- H5Aopen_by_idx(g,i)
    output[H5Aget_name(a)] <-  H5Aread(a)
    ## Close the attributes
    H5Aclose(a)
  }
  H5Gclose(g)
  H5Fclose(out)
  return(output)
}


#f <- '/Users/lwasser/Documents/Conferences/1_DataWorkshop_ESA2014/HDF5File/SJER_140123_chip.h5'
f <- '/Users/law/Documents/data/SJER_140123_chip.h5'

#look at the HDF5 file structure 
h5ls(f,all=T)

#make sure the hdf5 metadata function is loaded
source("/Users/law/Documents/GitHub_Lwasser/NEON_HigherEd/code/h5metadata.R")

#r get spatial info and map info
spinfo <- h5metadata(f,"spatialInfo",11)
