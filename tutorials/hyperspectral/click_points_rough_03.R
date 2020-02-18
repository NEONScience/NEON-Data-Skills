
## Instll BiocManager and rhdf5 if needed
# install.packages("BiocManager")
# BiocManager::install("rhdf5")

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

## convert raster cell number into row and column (used to extract spectral signature below)
c$row=c$cell%/%nrow(rgbStack)+1
c$col=c$cell%%ncol(rgbStack)

Pixel_df=as.data.frame(wavelengths)

for(i in 1:length(c$x)){
# extract Spectra from a single pixel
aPixel <- h5read(f,"/SJER/Reflectance/Reflectance_Data",
                 index=list(NULL,c$col[i],c$row[i]))

aPixel=aPixel/as.vector(scaleFact)
# reshape the data and turn into dataframe
b <- adply(aPixel,c(1))

# scale pixel values
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


## Mask out absorption bands

# grab Reflectance metadata (which contains absorption band limits)
reflMetadata<- h5readAttributes(f,"/SJER/Reflectance" )

ab1 = reflMetadata$Band_Window_1_Nanometers
ab2 = reflMetadata$Band_Window_2_Nanometers

## Plot spectral signatures again with rectangles showing the absorption bands
ggplot()+
  geom_line(data = Pixel.melt, mapping = aes(x=wavelengths, y=Reflectance, color=variable), lwd=1.5)+
  geom_rect(mapping=aes(ymin=min(Pixel.melt$Reflectance),ymax=max(Pixel.melt$Reflectance), xmin=ab1[1], xmax=ab1[2]), color="black", fill="grey40", alpha=0.8)+
  geom_rect(mapping=aes(ymin=min(Pixel.melt$Reflectance),ymax=max(Pixel.melt$Reflectance), xmin=ab2[1], xmax=ab2[2]), color="black", fill="grey40", alpha=0.8)+
  scale_colour_manual(values = c("green2", "green4", "grey50","tan4","blue3"),
                      labels = c("Field", "Tree", "Roof","Soil","Water"))+
  labs(color = "Cover Type")+
  ggtitle("Land cover spectral signatures")+
  theme(plot.title = element_text(hjust = 0.5, size=20))+
  xlab("Wavelength")


## Now, manipulate the melted data.frame to remove all rows with wavelengths in the absorption bands
Pixel.melt.masked=Pixel.melt

Pixel.melt.masked[Pixel.melt.masked$wavelengths>ab1[1]&Pixel.melt.masked$wavelengths<ab1[2],]$Reflectance=NA
Pixel.melt.masked[Pixel.melt.masked$wavelengths>ab2[1]&Pixel.melt.masked$wavelengths<ab2[2],]$Reflectance=NA


ggplot()+
  geom_line(data = Pixel.melt.masked, mapping = aes(x=wavelengths, y=Reflectance, color=variable), lwd=1.5)+
  scale_colour_manual(values = c("green2", "green4", "grey50","tan4","blue3"),
                      labels = c("Field", "Tree", "Roof","Soil","Water"))+
  labs(color = "Cover Type")+
  ggtitle("Land cover spectral signatures")+
  theme(plot.title = element_text(hjust = 0.5, size=20))+
  xlab("Wavelength")

