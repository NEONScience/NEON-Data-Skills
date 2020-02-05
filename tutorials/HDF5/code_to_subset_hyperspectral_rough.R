### code for subsetting and saving HDF5 file or NEON hyperspectral tutorials

library(rhdf5)



wd="~/Desktop/Hyperspectral_Tutorial/"

# Read in H5 file
#f <- paste0(wd,"NEONDSImagingSpectrometerData.h5")
f <- paste0(wd,"NEON_D17_SJER_DP3_257000_4112000_reflectance.h5")
#View HDF5 file structure 
View(h5ls(f,all=T))
ls=h5ls(f,all=T)

# create hdf5 file
h5createFile("NEON_hyperspectral_tutorial_example_subset.h5")
# create group for location 1
h5createGroup("NEON_hyperspectral_tutorial_example_subset.h5", "SJER/")
h5createGroup("NEON_hyperspectral_tutorial_example_subset.h5", "SJER/Reflectance")
h5createGroup("NEON_hyperspectral_tutorial_example_subset.h5", "SJER/Reflectance/Metadata")
h5createGroup("NEON_hyperspectral_tutorial_example_subset.h5", "SJER/Reflectance/Metadata/Coordinate_System")
h5createGroup("NEON_hyperspectral_tutorial_example_subset.h5", "SJER/Reflectance/Metadata/Spectral_Data")

#make a list of all of the names within the Coordinate_System group
cg=unique(ls[ls$group=="/SJER/Reflectance/Metadata/Coordinate_System",]$name)

for(i in 1:length(cg)){
  print(cg[i])
  a=h5readAttributes(f,paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]))
  d=h5read(f,paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]))
  attributes(d)=a
  h5write(obj=d,file="NEON_hyperspectral_tutorial_example_subset.h5",name=paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]))
}


## extract spatial and spectral subset of full hgperspectral reflectance data:

idx <- seq(from = 1, to = 426, by = 4)
ws <- h5read(file = f, 
             name = "SJER/Reflectance/Metadata/Spectral_Data/Wavelength", 
             index = list(idx)
             )
h5write(obj=ws, file="NEON_hyperspectral_tutorial_example_subset.h5",
        name="SJER/Reflectance/Metadata/Spectral_Data/Wavelength")

hs <- h5read(file = f, 
             name = "SJER/Reflectance/Reflectance_Data", 
             index = list(idx,1:300, 701:1000)
)

h5write(obj=hs, file="NEON_hyperspectral_tutorial_example_subset.h5",
        name="SJER/Reflectance/Reflectance_Data")
h5closeAll()

View(h5ls("NEON_hyperspectral_tutorial_example_subset.h5"))
