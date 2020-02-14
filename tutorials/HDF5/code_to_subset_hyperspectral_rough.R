### code for subsetting and saving HDF5 file or NEON hyperspectral tutorials

library(rhdf5)




wd="~/Desktop/Hyperspectral_Tutorial/"
setwd(wd)

# Read in H5 file
#f <- paste0(wd,"NEONDSImagingSpectrometerData.h5")
f <- paste0(wd,"NEON_D17_SJER_DP3_257000_4112000_reflectance.h5")
#View HDF5 file structure 
#View(h5ls(f,all=T))
ls=h5ls(f,all=T)

# create hdf5 file
h5createFile("NEON_hyperspectral_tutorial_example_subset.h5")
# create group for location 1
h5createGroup("NEON_hyperspectral_tutorial_example_subset.h5", "SJER/")

h5createGroup("NEON_hyperspectral_tutorial_example_subset.h5", "SJER/Reflectance")

##### EDIT - include Reflectance metadata ((absorption bands))
a=h5readAttributes(f,"/SJER/Reflectance/")
fid <- H5Fopen("NEON_hyperspectral_tutorial_example_subset.h5")
g=H5Gopen(fid, "SJER/Reflectance")

for(i in 1:length(names(a))){
h5writeAttribute(attr = a[[i]], h5obj=g, name=names(a[i]))
}
h5closeAll()

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
  h5write(obj=d,file="NEON_hyperspectral_tutorial_example_subset.h5",
          name=paste0("/SJER/Reflectance/Metadata/Coordinate_System/",cg[i]),
          write.attributes=T)
}

# ma <- h5readAttributes(file = f, 
#                        name = "SJER/Reflectance/Metadata/Coordinate_System/Map_Info")
# # open the file, create a class
# fid <- H5Fopen("NEON_hyperspectral_tutorial_example_subset.h5")
# # open up the dataset to add attributes to, as a class
# mobj=H5Dopen(fid, "SJER/Reflectance/Metadata/Coordinate_System/Map_Info")
# h5writeAttribute(attr = ma[[1]], name=names(ma)[1],
#                  h5obj=mobj)

## extract spatial and spectral subset of full hgperspectral reflectance data:

idx <- seq(from = 1, to = 426, by = 4)

# Wavelengths
ws <- h5read(file = f, 
             name = "SJER/Reflectance/Metadata/Spectral_Data/Wavelength", 
             index = list(idx)
            )
# Wavelength attributes
wa <- h5readAttributes(file = f, 
                       name = "SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
attributes(ws) <- wa
h5write(obj=ws, file="NEON_hyperspectral_tutorial_example_subset.h5",
        name="SJER/Reflectance/Metadata/Spectral_Data/Wavelength",
        write.attributes=T)
# # open the file, create a class
# fid <- H5Fopen("NEON_hyperspectral_tutorial_example_subset.h5")
# # open up the dataset to add attributes to, as a class
# wobj=H5Dopen(fid, "SJER/Reflectance/Metadata/Spectral_Data/Wavelength")
# h5writeAttribute(attr = wa[[1]], name=names(wa)[1],
#                  h5obj=wobj)
# h5writeAttribute(attr = wa[[2]], name=names(wa)[2],
#                  h5obj=wobj)


hs <- h5read(file = f, 
             name = "SJER/Reflectance/Reflectance_Data", 
             index = list(idx, 501:1000, 1:500)
            )
hsd=attributes(hs)

ha <- h5readAttributes(file = f, 
                       name = "SJER/Reflectance/Reflectance_Data")

# ha <- h5readAttributes(file = "NEON_hyperspectral_tutorial_example_subset.h5", 
#                        name = "SJER/Reflectance/Reflectance_Data")

ha$Dimensions=c(500,500,107)
ha$Spatial_Extent_meters[1]=ha$Spatial_Extent_meters[1]+500
ha$Spatial_Extent_meters[3]=ha$Spatial_Extent_meters[3]+500
attributes(hs)=c(hsd,ha)

#attributes(hs) <- ha
attributes(hs)
#attributes(hs)=list(dim=c(107,300,300))

h5write(obj=hs, file="NEON_hyperspectral_tutorial_example_subset.h5",
        name="SJER/Reflectance/Reflectance_Data",
        write.attributes=T)

# # open the file, create a class
# fid <- H5Fopen("NEON_hyperspectral_tutorial_example_subset.h5")
# # open up the dataset to add attributes to, as a class
# hobj=H5Dopen(fid, "SJER/Reflectance/Reflectance_Data")
# for(i in 1:length(ha)){
# h5writeAttribute(attr = ha[[i]], name=names(ha)[i],
#                  h5obj=hobj)
# }


h5closeAll()

View(h5ls("NEON_hyperspectral_tutorial_example_subset.h5", all=T))
