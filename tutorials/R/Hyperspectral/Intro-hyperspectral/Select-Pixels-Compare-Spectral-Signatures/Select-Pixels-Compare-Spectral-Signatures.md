---
syncID: db9715ca243944fabbe81031f2ed5cec
title: "Select pixels and compare spectral signatures in R"
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Hyperspectral/Intro-hyperspectral/Select-Pixels-Compare-Spectral-Signatures/Select-Pixels-Compare-Spectral-Signatures.R
contributors: Megan Jones, Felipe Sanchez
dateCreated: 2020-02-18
description: Plot and comapre the spectral signatures of multiple different land cover types using an interactive click-to-extract interface to select pixels.
estimatedTime: 0.5 Hours
languagesTool: R
dataProudct: DP3.30006.001
packagesLibraries: rhdf5, raster, plyr, reshape2, ggplot2
authors: Donal O'Leary
topics: hyperspectral, HDF5, remote-sensing
tutorialSeries: null
urlTitle: select-pixels-compare-spectral-signatures-r
---


In this tutorial, we will learn how to plot spectral signatures of several
different land cover types using an interactive clicking feature of the 
`raster` package.

<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this activity, you will be able to:

* Extract and plot spectra from an HDF5 file.
* Work with groups and datasets within an HDF5 file.
* Use the `raster::click()` function to interact with an RGB raster image

## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### R Libraries to Install:

* **rhdf5**: `install.packages("BiocManager")`, `BiocManager::install("rhdf5")`
* **raster**: `install.packages('raster')`
* **rgdal**: `install.packages('rgdal')`
* **plyr**: `install.packages('plyr')`
* **reshape2**: `install.packages('rehape2')`
* **ggplot2**: `install.packages('ggplot2')`

<a href="https://neonscience.org/packages-in-r" target="_blank"> More on Packages in
 R - Adapted from Software Carpentry.</a>

### Data to Download

<h3><a href="https://ndownloader.figshare.com/files/21754221">
Download NEON Teaching Data Subset: Imaging Spectrometer Data - HDF5 </a></h3>

These hyperspectral remote sensing data provide information on the
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank" > San Joaquin 
Exerimental Range field site</a> in March of 2019.
The data were collected over the San Joaquin field site located in California 
(Domain 17) and processed at NEON headquarters. This data subset is derived from 
the mosaic tile named NEON_D17_SJER_DP3_257000_4112000_reflectance.h5. 
The entire dataset can be accessed by request from the 
<a href="http://data.neonscience.org" target="_blank"> NEON Data Portal</a>.

<a href="https://ndownloader.figshare.com/files/21754221" class="link--button link--arrow">
Download Dataset</a>

**Remember** that the example dataset linked here only has 1 out of every 4 bands
included in a full NEON hyperspectral dataset (this substantially reduces the file 
size!). When we refer to bands in this tutorial, we will note the band numbers for 
this example dataset, which are different from NEON production data. To convert 
a band number (b) from this example data subset to the equivalent band in a full 
NEON hyperspectral file (b'), use the following equation: b' = 1+4*(b-1).





***
<h3><a href="https://ndownloader.figshare.com/files/21767328">
Download NEON Teaching Data Subset: RGB Image of SJER</a></h3>

This RGB image is derived from hyperspectral remote sensing data collected on the
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank" > San Joaquin Exerimental Range field site</a> in March of 2019.
The data were collected over the San Joaquin field site located in California 
(Domain 17) and processed at NEON headquarters. The entire dataset can be accessed by request from the 
<a href="http://data.neonscience.org" target="_blank"> NEON Data Portal</a>.

<a href="https://ndownloader.figshare.com/files/21767328" class="link--button link--arrow">
Download Dataset</a>





***
**Set Working Directory:** This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

**R Script & Challenge Code:** NEON data lessons often contain challenges that reinforce 
learned skills. If available, the code for challenge solutions is found in the
downloadable R script of the entire lesson, available in the footer of each lesson page.


### Recommended Skills

This tutorial will require that you be comfortable navigating HDF5 files, 
and have an understanding of what spectral signatures are. For additional 
information on these topics, we highly recommend you work through the 
<a href="https://neonscience.org/intro-hsi-r-series" target="_blank"> *Introduction to Hyperspectral Remote Sensing Data* series</a>
before moving on to this tutorial.

</div>


## Getting Started

First, we need to load our required packages, and import the hyperspectral
data (in HDF5 format). We will also collect a few other important pieces of 
information (band wavelengths and scaling factor) while we're at it.


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

Now, we read in the RGB image that we created in an earlier tutorial and plot it. 
If you didn't make this image before, you can download it from the link at the top 
of this page.


    # Read in RGB image as a 'stack' rather than a plain 'raster'
    rgbStack <- stack(paste0(wd,"NEON_hyperspectral_tutorial_example_RGB_stack_image.tif"))
    
    # Plot as RGB image
    plotRGB(rgbStack,
            r=1,g=2,b=3, scale=300, 
            stretch = "lin")

![RGB image of a portion of the SJER field site using 3 bands from the raster stack. Brightness values have been stretched using the stretch argument to produce a natural looking image. At the top right of the image, there is dark, brakish water. Scattered throughout the image, there are several trees. At the center of the image, there is a baseball field, with low grass. At the bottom left of the image, there is a parking lot and some buildings with highly reflective surfaces, and adjacent to it is a section of a gravel lot.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Hyperspectral/Intro-hyperspectral/Select-Pixels-Compare-Spectral-Signatures/rfigs/read-in-RGB-and-plot-1.png)

## Interactive `click` Function from `raster` Package

Next, we use an interactive clicking function to identify the pixels that we want
to extract spectral signatures for. To follow along best with this tutorial, we 
suggest the following five cover types (exact location shown below). 

1. Irrigated grass
2. Tree canopy (avoid the shaded northwestern side of the tree)
3. Roof
4. Bare soil (baseball diamond infield)
5. Open water

As shown here:
<figure >
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral-general/Click_points.png"><img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/hyperspectral-general/Click_points.png"
    alt="RGB image of a portion of the SJER field site using 3 bands fom the raster stack. Also displayed are points labeled with numbers one through five, representing five cover types selected using the interactive click function from the raster package. At the top right of the image, the dark, brakish water has been selected as point 5. The tops of a cluster of trees on the top left of the image has been selected as point 2. At the center of the image, the baseball field with low grass has been selected as point 1. At the bottom left of the image the top of a building has been selected as point 3, and the adjacent gravel lot has been selected as point 4. Plotting parameters have been changed to enhance visibility.">
    </a>
<figcaption> Five different land cover types chosen for this study (magenta dots) in the order listed above (red numbers).</figcaption>
</figure>



    # change plotting parameters to better see the points and numbers generated from clicking
    par(col="red", cex=3)
    
    # use the 'click' function
    c <- click(rgbStack, id=T, xy=T, cell=T, type="p", pch=16, col="magenta", col.lab="red")

Once you have clicked your five points, press the `ESC` key to save your
clicked points and close the function before moving on to the next step. If 
you make a mistake in the step, run the `plotRGB()` function again to start over.


The `click()` function identifies the cell number that you clicked, but in order 
to extract spectral signatures, we need to convert that cell number into a row
and column, as shown here:


    # convert raster cell number into row and column (used to extract spectral signature below)
    c$row <- c$cell%/%nrow(rgbStack)+1 # add 1 because R is 1-indexed
    c$col <- c$cell%%ncol(rgbStack)

## Extract Spectral Signatures from HDF5 file
Next, we loop through each of the cells that we selected to use the `h5read()` 
function to etract the reflectance values of all bands from the given row and
column. 


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

## Plot Spectral signatures using ggplot2
Finally, we have everything that we need to plot the spectral signatures for 
each of the pixels that we clicked. In order to color our lines by the different
land cover types, we will first reshape our data using the `melt()` function, then
plot the spectral signatures.


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

![Plot of spectral signatures for the five different land cover types: Field, Tree, Roof, Soil, and Water. On the x-axis is wavelength in nanometers and on the y-axis is reflectance values.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Hyperspectral/Intro-hyperspectral/Select-Pixels-Compare-Spectral-Signatures/rfigs/plot-spectral-signatures-1.png)

Nice! However, there seems to be something weird going on in the wavelengths 
near 1400nm and 1850 nm...

## Atmospheric Absorbtion Bands 
Those irregularities around 1400nm and 1850 nm are two major atmospheric 
absorbtion bands - regions where gasses in the atmosphere (primarily carbon 
dioxide and water vapor) absorb radiation, and therefore, obscure the 
reflected radiation that the imaging spectrometer measures. Fortunately, the 
lower and upper bound of each of those atmopheric absopbtion bands is specified 
in the HDF5 file. Let's read those bands and plot rectangles where the 
reflectance measurements are obscured by atmospheric absorbtion. 


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

![Plot of spectral signatures for the five different land cover types: Field, Tree, Roof, Soil, and Water. Added to the plot are two rectangles in regions near 1400nm and 1850nm where the reflectance measurements are obscured by atmospheric absorption. On the x-axis is wavelength in nanometers and on the y-axis is reflectance values.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Hyperspectral/Intro-hyperspectral/Select-Pixels-Compare-Spectral-Signatures/rfigs/mask-atmospheric-absorbtion-bands-1.png)

Now we can clearly see that the noisy sections of each spectral signature are 
within the atmospheric absorbtion bands. For our final step, let's take all 
reflectance values from within each absorbtion band and set them to `NA` to 
remove the noisy sections from the plot.


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

![Plot of spectral signatures for the five different land cover types: Field, Tree, Roof, Soil, and Water. Values falling within the two rectangles from the previous image have been set to NA and ommited from the plot. On the x-axis is wavelength in nanometers and on the y-axis is reflectance values.](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/Hyperspectral/Intro-hyperspectral/Select-Pixels-Compare-Spectral-Signatures/rfigs/remove-absorbtion-band-reflectances-1.png)

There you have it, spectral signatures for five different land cover types, 
with the readings from the atmospheric absorbtion bands removed.

<div id="ds-challenge" markdown="1">
### Challenge: Compare Spectral Signatures

There are many interesting comparisons to make with spectral signatures. 
Try these challenges to explore hyperspectral data further:

1. Compare five different types of vegetation, and pick an appropriate color
for each of their lines. A nice guide to the many different color options
in R can be found <a href="http://sape.inf.usi.ch/quick-reference/ggplot2/colour" target="_blank"> *here*.</a>

2. What happens if you only click four points? What about six? How does this
change the spectral signature plots, and can you fix any errors that occur?

3. Does shallow water have a different spectral signature than deep water?

</div>


