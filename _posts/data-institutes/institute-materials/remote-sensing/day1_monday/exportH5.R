the chunk below is a weird example.

```{r delete-me, echo=FALSE}

#### DELETE EVERYTHING BELOW

a.raster <- open_band(f, 1, 
                      epsg, subset=TRUE,
                      dims=index.bounds)



# get band
a.band <- open_band(f,
                    bandNum=1, 
                    epsg=32611,
                    subset=TRUE,
                    dims=index.bounds)
# mask band
a.band.mask <- mask(a.band, ndvi)
plot(a.band.mask)





```




# delete?
## Export to H5

Let's export our new data subset to H5

```{r export-h5, echo=FALSE, eval=FALSE }

# Create hdf5 file
h5createFile("subset.h5")

# add some sample data to the H5 file located in the aNEONSite group
# we'll call the dataset "temperature"
h5write(subset.h5, 
        file = "subset.h5", 
        name="Reflectance")

# let's check out the H5 structure again
h5ls("subset.h5")

#open the file, create a class
fid <- H5Fopen("subset.h5")
#open up the dataset to add attributes to, as a class
did <- H5Dopen(fid, "Reflectance")

# let's add some attributes to the group
# did2 <- H5Gopen(fid, "TEAK/")
# h5writeAttribute(did2, attr="Teakettle Field Site",
#                 name="SiteName")
# h5writeAttribute(did2, attr="Southern California",
#                 name="Location")
# Provide the NAME and the ATTR (what the attribute says) 
# for the attribute.

h5writeAttribute(did, attr=proj4string(clip.extent),
                 name="proj4")
h5writeAttribute(did, attr=15000,
                 name="data ignore value")
h5writeAttribute(did, attr=c(1,2,3,4),
                 name="mapTie")
h5writeAttribute(did, attr="Meters",
                 name="Units")


#close the files, groups and the dataset when you're done writing to them!
H5Dclose(did)
# H5Gclose(did2)
H5Fclose(fid)
```




require(devtools)
install_github("ramnathv/slidify")
install_github("ramnathv/slidifyLibraries")
library(slidify)
author("mydeck")
