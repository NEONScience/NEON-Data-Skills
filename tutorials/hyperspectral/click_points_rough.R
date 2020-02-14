





# plot(b34r,      xlab = "UTM Easting", 
#      ylab = "UTM Northing",
#      main= "Raster w Custom Colors",
#      col=col, 
#      zlim=c(0,3000))
# 
# c=click(b34r,id=T, xy=T, cell=T)

library(reshape2)
library(raster)
library(plyr)
library(ggplot2)

wd="~/Desktop/Hyperspectral_Tutorial/" #This will depend on your local environment
f <- paste0(wd,"NEON_hyperspectral_tutorial_example_subset.h5")

# read in the wavelength information from the HDF5 file
wavelengths <- h5read(f,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")

# grab scale factor from the Reflectance attributes
reflInfo<- h5readAttributes(f,"/SJER/Reflectance/Reflectance_Data" )

scaleFact = reflectanceAttr$Scale_Factor

nRows <- reflInfo$Dimensions[1]
nCols <- reflInfo$Dimensions[2]
nBands <- reflInfo$Dimensions[3]

#grab the no data value
myNoDataValue <- as.integer(reflInfo$Data_Ignore_Value)

myEPSG <- h5read(f,"/SJER/Reflectance/Metadata/Coordinate_System/EPSG Code" )
myCRS <- crs(paste0("+init=epsg:",myEPSG))

# Grab the UTM coordinates of the spatial extent

xMin <- reflInfo$Spatial_Extent_meters[1]
xMax <- reflInfo$Spatial_Extent_meters[2]
yMin <- reflInfo$Spatial_Extent_meters[3]
yMax <- reflInfo$Spatial_Extent_meters[4]

# define the extent (left, right, top, bottom)
rasExt <- extent(xMin,xMax,yMin,yMax)

## Def band2rast
band2Raster <- function(file, band, noDataValue, extent, CRS){
  #first read in the raster
  out<- h5read(file,"/SJER/Reflectance/Reflectance_Data",index=list(band,NULL,NULL))
  #Convert from array to matrix
  out <- (out[1,,])
  #transpose data to fix flipped row and column order 
  #depending upon how your data are formatted you might not have to perform this
  #step.
  out <-t(out)
  #assign data ignore values to NA
  #note, you might chose to assign values of 15000 to NA
  out[out == myNoDataValue] <- NA
  
  #turn the out object into a raster
  outr <- raster(out,crs=CRS)
  
  #assign the extents to the raster
  extent(outr) <- extent
  
  #return the raster object
  return(outr)
}

rgb <- c(14,8,4)
wavelengths[rgb]
#lapply tells R to apply the function to each element in the list
rgb_rast <- lapply(rgb,FUN=band2Raster, file = f,
                   noDataValue=myNoDataValue, 
                   extent=rasExt,
                   CRS=myCRS)

#check out the properties or rgb_rast
#note that it displays properties of 3 rasters.

rgb_rast

#finally, create a raster stack from our list of rasters
rgbStack <- stack(rgb_rast)

## With RGB
plotRGB(rgbStack,
        r=1,g=2,b=3, scale=300, 
        stretch = "Lin")
par(col="red", cex=3)
c=click(rgbStack, id=T, xy=T, cell=T, type="p", pch=16, col="magenta", col.lab="red")

c$row=c$cell%/%nrow(rgbStack)+1
c$col=c$cell%%ncol(rgbStack)

Pixel_df=as.data.frame(wavelengths)

for(i in 1:length(c$x)){
# extract Some Spectra from a single pixel
aPixel <- h5read(f,"/SJER/Reflectance/Reflectance_Data",
                 index=list(NULL,c$col[i],c$row[i]))
# reshape the data and turn into dataframe
b <- adply(aPixel,c(1))

# scale pixel values
b[2]=b[2]/scaleFact
names(b)[2]=paste0("Point_",i)

# create clean data frame
Pixel_df=cbind(Pixel_df,b[2])
}

# Use the melt() funciton to reshape the dataframe into a format that ggplot prefers
Pixel.melt=melt(Pixel_df, id.vars = "wavelengths", value.name = "Reflectance")

ggplot()+
  geom_line(data = Pixel.melt, mapping = aes(x=wavelengths, y=Reflectance, color=variable), lwd=1.5)+
  scale_colour_manual(values = c("green2", "green4", "grey50","tan4","blue3"),
                      labels = c("Field", "Tree", "Roof","Soil","Water"))+
  labs(color = "Cover Type")+
  ggtitle("Land cover spectral signatures")+
  theme(plot.title = element_text(hjust = 0.5, size=20))+
  xlab("Wavelength")

# p=drawPoly(b34r, sp=T)
# crs(p)=crs(b34r)
# plot(p)
# 
# plot(b34r, add=T, alpha=.5)
