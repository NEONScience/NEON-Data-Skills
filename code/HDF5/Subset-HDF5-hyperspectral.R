## ----load-libraries------------------------------------------------------

# Install rhdf5 package (only need to run if not already installed)
# install.packages("BiocManager")
# BiocManager::install("rhdf5")

# Load required packages
library(rhdf5)



## ----read-in-file--------------------------------------------------------
# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. Be sure to move the download into your working directory!
wd="~/Desktop/Hyperspectral_Tutorial/" #This will depend on your local environment
setwd(wd)

# Read in H5 file
f <- paste0(wd,"NEON_D17_SJER_DP3_257000_4112000_reflectance.h5")



## ----create-hdf5---------------------------------------------------------
# First, create a name for the new file
nf <- paste0(wd, "NEON_hyperspectral_tutorial_example_subset.h5")


# create hdf5 file

h5createFile(nf)
h5createGroup(nf, "SJER/")
h5createGroup(nf, "SJER/Reflectance")
h5createGroup(nf, "SJER/Reflectance/Metadata")
h5createGroup(nf, "SJER/Reflectance/Metadata/Coordinate_System")
h5createGroup(nf, "SJER/Reflectance/Metadata/Spectral_Data")



## ----ref-attributes------------------------------------------------------

a=h5readAttributes(f,"/SJER/Reflectance/")
fid <- H5Fopen(nf)
g=H5Gopen(fid, "SJER/Reflectance")

for(i in 1:length(names(a))){
h5writeAttribute(attr = a[[i]], h5obj=g, name=names(a[i]))
}
h5closeAll()


## ----populate-group-attributes-------------------------------------------

# make a list of all groups within the full tile file
ls=h5ls(f,all=T)

#make a list of all of the names within the Coordinate_System group
cg=unique(ls[ls$group=="/SJER/Reflectance/Metadata/Coordinate_System",]$name)

for(i in 1:length(cg)){
  print(cg[i])
  a=h5readAttributes(f,paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]))
  d=h5read(f,paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]))
  attributes(d)=a
  h5write(obj=d,file=nf,
          name=paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]),
          write.attributes=T)
}


## ----subset-wavelengths--------------------------------------------------
#First, we make out 'index'  a list of number that will allow us to select every fourth band
idx <- seq(from = 1, to = 426, by = 4)

# We then use this index to select particular wavelengths from the full tile using the "index=" argument
ws <- h5read(file = f, 
             name = "SJER/Reflectance/Metadata/Spectral_Data/Wavelength", 
             index = list(idx)
            )

# As per above, we also need the wavelength attributes
wa <- h5readAttributes(file = f, 
                       name = "SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
attributes(ws) <- wa

# Finally, write the subset of wavelengths and their attributes to the subset file
h5write(obj=ws, file=nf,
        name="SJER/Reflectance/Metadata/Spectral_Data/Wavelength",
        write.attributes=T)


## ----read-hyp-data-------------------------------------------------------
# Read in reflectance data - note the index argument! This is ultimately how we reduce the file size.
hs <- h5read(file = f, 
             name = "SJER/Reflectance/Reflectance_Data", 
             index = list(idx, 501:1000, 1:500)
            )
# grab the '$dim' attribute - as this will be needed when writing the file at the bottom
hsd=attributes(hs)

# We also need the attributes for the reflectance data, of course.
ha <- h5readAttributes(file = f, 
                       name = "SJER/Reflectance/Reflectance_Data")

# However, some of the attributes are not longer valid since we changed the spatial extend of this dataset.
# therefore, we will need to overwrite those with the correct values.
ha$Dimensions=c(500,500,107)
ha$Spatial_Extent_meters[1]=ha$Spatial_Extent_meters[1]+500
ha$Spatial_Extent_meters[3]=ha$Spatial_Extent_meters[3]+500
attributes(hs)=c(hsd,ha)

attributes(hs)

h5write(obj=hs, file=nf,
        name="SJER/Reflectance/Reflectance_Data",
        write.attributes=T)

h5closeAll()


## ----view-product, eval=FALSE, comment=NA--------------------------------
View(h5ls(nf, all=T))

