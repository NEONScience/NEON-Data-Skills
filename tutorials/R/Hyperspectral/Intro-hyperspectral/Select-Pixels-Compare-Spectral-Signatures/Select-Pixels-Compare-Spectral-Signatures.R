## ----load-libraries, message=FALSE, warning=FALSE--------------------

# Load required packages
library(rhdf5)
library(reshape2)
library(raster)
library(plyr)
library(ggplot2)

# set working directory to ensure R can find the file we wish to import and where
# we want to save our files. Be sure to move the download into your working directory!
wd <- "~/Documents/data/" #This will depend on your local environment
setwd(wd)

# define filepath to the hyperspectral dataset
fhs <- paste0(wd,"NEON_hyperspectral_tutorial_example_subset.h5")

# read in the wavelength information from the HDF5 file
wavelengths <- h5read(fhs,"/SJER/Reflectance/Metadata/Spectral_Data/Wavelength")

# grab scale factor from the Reflectance attributes
reflInfo <- h5readAttributes(fhs,"/SJER/Reflectance/Reflectance_Data" )

scaleFact <- reflInfo$Scale_Factor



## ----read-in-RGB-and-plot, fig.cap="RGB image of a portion of the SJER field site using 3 bands from the raster stack. Brightness values have been stretched using the stretch argument to produce a natural looking image. At the top right of the image, there is dark, brakish water. Scattered throughout the image, there are several trees. At the center of the image, there is a baseball field, with low grass. At the bottom left of the image, there is a parking lot and some buildings with highly reflective surfaces, and adjacent to it is a section of a gravel lot."----

# Read in RGB image as a 'stack' rather than a plain 'raster'
rgbStack <- stack(paste0(wd,"NEON_hyperspectral_tutorial_example_RGB_stack_image.tif"))

# Plot as RGB image
plotRGB(rgbStack,
        r=1,g=2,b=3, scale=300, 
        stretch = "lin")



## ----click-to-select, eval=FALSE, comment=NA-------------------------

# change plotting parameters to better see the points and numbers generated from clicking
par(col="red", cex=3)

# use the 'click' function
c <- click(rgbStack, id=T, xy=T, cell=T, type="p", pch=16, col="magenta", col.lab="red")





## ----convert-cell-to-row-column--------------------------------------
# convert raster cell number into row and column (used to extract spectral signature below)
c$row <- c$cell%/%nrow(rgbStack)+1 # add 1 because R is 1-indexed
c$col <- c$cell%%ncol(rgbStack)


## ----extract-spectral-signaures--------------------------------------

# create a new dataframe from the band wavelengths so that we can add
# the reflectance values for each cover type
Pixel_df <- as.data.frame(wavelengths)

# loop through each of the cells that we selected
for(i in 1:length(c$cell)){
# extract Spectra from a single pixel
aPixel <- h5read(fhs,"/SJER/Reflectance/Reflectance_Data",
                 index=list(NULL,c$col[i],c$row[i]))

# scale reflectance values from 0-1
aPixel <- aPixel/as.vector(scaleFact)

# reshape the data and turn into dataframe
b <- adply(aPixel,c(1))

# rename the column that we just created
names(b)[2] <- paste0("Point_",i)

# add reflectance values for this pixel to our combined data.frame called Pixel_df
Pixel_df <- cbind(Pixel_df,b[2])
}



## ----plot-spectral-signatures, fig.width=9, fig.height=6, fig.cap="Plot of spectral signatures for the five different land cover types: Field, Tree, Roof, Soil, and Water. On the x-axis is wavelength in nanometers and on the y-axis is reflectance values."----
# Use the melt() function to reshape the dataframe into a format that ggplot prefers
Pixel.melt <- reshape2::melt(Pixel_df, id.vars = "wavelengths", value.name = "Reflectance")

# Now, let's plot some spectral signatures!
ggplot()+
  geom_line(data = Pixel.melt, mapping = aes(x=wavelengths, y=Reflectance, color=variable), lwd=1.5)+
  scale_colour_manual(values = c("green2", "green4", "grey50","tan4","blue3"),
                      labels = c("Field", "Tree", "Roof","Soil","Water"))+
  labs(color = "Cover Type")+
  ggtitle("Land cover spectral signatures")+
  theme(plot.title = element_text(hjust = 0.5, size=20))+
  xlab("Wavelength")


## ----mask-atmospheric-absorbtion-bands, fig.width=9, fig.height=6, fig.cap="Plot of spectral signatures for the five different land cover types: Field, Tree, Roof, Soil, and Water. Added to the plot are two rectangles in regions near 1400nm and 1850nm where the reflectance measurements are obscured by atmospheric absorption. On the x-axis is wavelength in nanometers and on the y-axis is reflectance values."----

# grab Reflectance metadata (which contains absorption band limits)
reflMetadata <- h5readAttributes(fhs,"/SJER/Reflectance" )

ab1 <- reflMetadata$Band_Window_1_Nanometers
ab2 <- reflMetadata$Band_Window_2_Nanometers

# Plot spectral signatures again with rectangles showing the absorption bands
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


## ----remove-absorbtion-band-reflectances, fig.width=9, fig.height=6, fig.cap="Plot of spectral signatures for the five different land cover types: Field, Tree, Roof, Soil, and Water. Values falling within the two rectangles from the previous image have been set to NA and ommited from the plot. On the x-axis is wavelength in nanometers and on the y-axis is reflectance values."----

# Duplicate the spectral signatures into a new data.frame
Pixel.melt.masked <- Pixel.melt

# Mask out all values within each of the two atmospheric absorbtion bands
Pixel.melt.masked[Pixel.melt.masked$wavelengths>ab1[1]&Pixel.melt.masked$wavelengths<ab1[2],]$Reflectance <- NA
Pixel.melt.masked[Pixel.melt.masked$wavelengths>ab2[1]&Pixel.melt.masked$wavelengths<ab2[2],]$Reflectance <- NA

# Plot the masked spectral signatures
ggplot()+
  geom_line(data = Pixel.melt.masked, mapping = aes(x=wavelengths, y=Reflectance, color=variable), lwd=1.5)+
  scale_colour_manual(values = c("green2", "green4", "grey50","tan4","blue3"),
                      labels = c("Field", "Tree", "Roof", "Soil", "Water"))+
  labs(color = "Cover Type")+
  ggtitle("Land cover spectral signatures")+
  theme(plot.title = element_text(hjust = 0.5, size=20))+
  xlab("Wavelength")



## ----challenge-answer, echo=FALSE, eval=FALSE------------------------
## 
## # Challenge Answers - These challenge problems will depend on the specific
## # pixels that you select, but here we can answer these questions in general.
## 
## # 1. Each vegetation class will likely have slightly different spectral signatures,
## # mostly distinguished by the amplitude of the near-IR bands. As we saw in this
## # tutorial, irrigated grass has a much higher reflectance in the near-IR than
## # does the tree canopy. In general, grasses and irrigated vegetation have a higher
## # reflectance than do natural vegetation, and deciduous trees higher than conifers.
## 
## # 2. If you click four points, the script should work, but the plot labels and
## # colors might be wrong (for example, if you skip the soil point, your water point
## # may have the soil color and label). If you click six points, you will get an error
## # that the ggplot function needs six colors and labels in the scale_color_manual()
## # function. You can simply add the appropriate color and label for your sixth point
## # if you want!
## 
## # 3. Yes, shallow water usually has a different spectral signature than deep water.
## # This is because shallow water actually reflects some light from the soil at the
## # bottom of the water column, so the resulting spectral signature will look like
## # a combination of bare soil and water.
## 

