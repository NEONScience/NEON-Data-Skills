
library(rhdf5)
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

scaleFact = reflInfo$Scale_Factor


#finally, read in the RGB stack that you created in the previous tutorial
rgbStack <- stack(paste0(wd,"rgbImage.tif"))

## With RGB
plotRGB(rgbStack,
        r=1,g=2,b=3, scale=300, 
        stretch = "lin")
par(col="red", cex=3)
c=click(rgbStack, id=T, xy=T, cell=T, type="p", pch=16, col="magenta", col.lab="red")

c$row=c$cell%/%nrow(rgbStack)+1
c$col=c$cell%%ncol(rgbStack)

Pixel_df=as.data.frame(wavelengths)

for(i in 1:length(c$x)){
# extract Spectra from a single pixel
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
