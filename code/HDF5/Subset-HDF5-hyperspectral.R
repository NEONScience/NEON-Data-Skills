## ----load-libraries--------------------------------------------------------------------

# Install rhdf5 package (only need to run if not already installed)
# install.packages("BiocManager")
# BiocManager::install("rhdf5")

# Load required packages
library(rhdf5)



## ----wd-and-filename-------------------------------------------------------------------
# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. Be sure to move the download into your working directory!
wd <- "~/Documents/data/" # This will depend on your local environment
setwd(wd)

# Make the name of our HDF5 file a variable
f_full <- paste0(wd,"NEON_D17_SJER_DP3_257000_4112000_reflectance.h5")



## ----view-original, eval=FALSE, comment=NA---------------------------------------------
View(h5ls(f_full, all=T))


## ----create-hdf5-----------------------------------------------------------------------
# First, create a name for the new file
f <- paste0(wd, "NEON_hyperspectral_tutorial_example_subset.h5")

# create hdf5 file
h5createFile(f)

# Now we create the groups that we will use to organize our data
h5createGroup(f, "SJER/")
h5createGroup(f, "SJER/Reflectance")
h5createGroup(f, "SJER/Reflectance/Metadata")
h5createGroup(f, "SJER/Reflectance/Metadata/Coordinate_System")
h5createGroup(f, "SJER/Reflectance/Metadata/Spectral_Data")



## ----ref-attributes--------------------------------------------------------------------

a <- h5readAttributes(f_full,"/SJER/Reflectance/")
fid <- H5Fopen(f)
g <- H5Gopen(fid, "SJER/Reflectance")

for(i in 1:length(names(a))){
  h5writeAttribute(attr = a[[i]], h5obj=g, name=names(a[i]))
}

# It's always a good idea to close the file connection immidiately
# after finishing each step that leaves an open connection.
h5closeAll()


## ----populate-group-attributes---------------------------------------------------------

# make a list of all groups within the full tile file
ls <- h5ls(f_full,all=T)

# make a list of all of the names within the Coordinate_System group
cg <- unique(ls[ls$group=="/SJER/Reflectance/Metadata/Coordinate_System",]$name)

# Loop through the list of datasets that we just made above
for(i in 1:length(cg)){
  print(cg[i])
  
  # Read the inividual dataset within the Coordinate_System group
  d=h5read(f_full,paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]))

  # Read the associated attributes (if any)
  a=h5readAttributes(f_full,paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]))
    
  # Assign the attributes (if any) to the dataset
  attributes(d)=a
  
  # Finally, write the dataset to the HDF5 file
  h5write(obj=d,file=f,
          name=paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]),
          write.attributes=T)
}


## ----subset-wavelengths----------------------------------------------------------------

# First, we make our 'index', a list of number that will allow us to select every fourth band, using the "sequence" function seq()
idx <- seq(from = 1, to = 426, by = 4)

# We then use this index to select particular wavelengths from the full tile using the "index=" argument
wavelengths <- h5read(file = f_full, 
             name = "SJER/Reflectance/Metadata/Spectral_Data/Wavelength", 
             index = list(idx)
            )

# As per above, we also need the wavelength attributes
wavelength.attributes <- h5readAttributes(file = f_full, 
                       name = "SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
attributes(wavelengths) <- wavelength.attributes

# Finally, write the subset of wavelengths and their attributes to the subset file
h5write(obj=wavelengths, file=f,
        name="SJER/Reflectance/Metadata/Spectral_Data/Wavelength",
        write.attributes=T)


## ----plot-example-band-----------------------------------------------------------------
# Extract or "slice" data for band 58 from the HDF5 file
b58 <- h5read(f_full,name = "SJER/Reflectance/Reflectance_Data",
             index=list(58,NULL,NULL))
h5closeAll()

# convert from array to matrix
b58 <- b58[1,,]

# Make a plot to view this band
image(log(b58), col=grey(0:100/100))



## ----plot-example-band-subset----------------------------------------------------------
subset_rows <- 1:500
subset_columns <- 501:1000
# Extract or "slice" data for band 44 from the HDF5 file
b58 <- h5read(f_full,name = "SJER/Reflectance/Reflectance_Data",
             index=list(58,subset_columns,subset_rows))
h5closeAll()

# convert from array to matrix
b58 <- b58[1,,]

# Make a plot to view this band
image(log(b58), col=grey(0:100/100))



## ----read-hyp-data---------------------------------------------------------------------

# Read in reflectance data.
# Note the list that we feed into the index argument! 
# This tells the h5read() function which bands, rows, and 
# columns to read. This is ultimately how we reduce the file size.
hs <- h5read(file = f_full, 
             name = "SJER/Reflectance/Reflectance_Data", 
             index = list(idx, subset_columns, subset_rows)
            )


## ----hyp-data-attributes---------------------------------------------------------------

# grab the '$dim' attribute - as this will be needed 
# when writing the file at the bottom
hsd <- attributes(hs)

# We also need the attributes for the reflectance data.
ha <- h5readAttributes(file = f_full, 
                       name = "SJER/Reflectance/Reflectance_Data")

# However, some of the attributes are not longer valid since 
# we changed the spatial extend of this dataset. therefore, 
# we will need to overwrite those with the correct values.
ha$Dimensions <- c(500,500,107) # Note that the HDF5 file saves dimensions in a different order than R reads them
ha$Spatial_Extent_meters[1] <- ha$Spatial_Extent_meters[1]+500
ha$Spatial_Extent_meters[3] <- ha$Spatial_Extent_meters[3]+500
attributes(hs) <- c(hsd,ha)

# View the combined attributes to ensure they are correct
attributes(hs)

# Finally, write the hyperspectral data, plus attributes, 
# to our new file 'f'.
h5write(obj=hs, file=f,
        name="SJER/Reflectance/Reflectance_Data",
        write.attributes=T)

# It's always a good idea to close the HDF5 file connection
# before moving on.
h5closeAll()


## ----view-product, eval=FALSE, comment=NA----------------------------------------------
View(h5ls(f, all=T))

