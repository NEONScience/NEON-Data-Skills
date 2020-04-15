## ----load-packages-data-------------------------------------------------------------------

# load packages
# rgdal: for vector work; sp package should always load with rgdal. 
library(rgdal)  
# raster: for metadata/attributes- vectors or rasters
library(raster)   

# set working directory to data folder
# setwd("pathToDirHere")

# Import a polygon shapefile 
aoiBoundary_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV",
                            "HarClip_UTMZ18", stringsAsFactors = T)

# Import a line shapefile
lines_HARV <- readOGR( "NEON-DS-Site-Layout-Files/HARV", "HARV_roads", stringsAsFactors = T)

# Import a point shapefile 
point_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV",
                      "HARVtower_UTM18N", stringsAsFactors = T)



## ----plot-unique-lines--------------------------------------------------------------------

# view the factor levels
levels(lines_HARV$TYPE)
# create vector of line width values
lineWidth <- c(2,4,3,8)[lines_HARV$TYPE]
# view vector
lineWidth

# create a color palette of 4 colors - one for each factor level
roadPalette <- c("blue","green","grey","purple")
roadPalette
# create a vector of colors - one for each feature in our vector object
# according to its attribute value
roadColors <- c("blue","green","grey","purple")[lines_HARV$TYPE]
roadColors

# create vector of line width values
lineWidth <- c(2,4,3,8)[lines_HARV$TYPE]
# view vector
lineWidth

# in this case, boardwalk (the first level) is the widest.
plot(lines_HARV, 
     col=roadColors,
     main="NEON Harvard Forest Field Site\n Roads & Trails \nLine Width Varies by Type Attribute Value",
     lwd=lineWidth)



## ----add-legend-to-plot-------------------------------------------------------------------
plot(lines_HARV, 
     col=roadColors,
     main="NEON Harvard Forest Field Site\n Roads & Trails\n Default Legend")

# we can use the color object that we created above to color the legend objects
roadPalette

# add a legend to our map
legend("bottomright", 
       legend=levels(lines_HARV$TYPE), 
       fill=roadPalette, 
       bty="n", # turn off the legend border
       cex=.8) # decrease the font / legend size



## ----plot-many-shapefiles-----------------------------------------------------------------

# Plot multiple shapefiles
plot(aoiBoundary_HARV, 
     col = "grey93", 
     border="grey",
     main="NEON Harvard Forest Field Site")

plot(lines_HARV, 
     col=roadColors,
     add = TRUE)

plot(point_HARV, 
     add  = TRUE, 
     pch = 19, 
     col = "purple")

# assign plot to an object for easy modification!
plot_HARV<- recordPlot()



## ----create-custom-labels-----------------------------------------------------------------

# create a list of all labels
labels <- c("Tower", "AOI", levels(lines_HARV$TYPE))
labels

# render plot
plot_HARV

# add a legend to our map
legend("bottomright", 
       legend=labels, 
       bty="n", # turn off the legend border
       cex=.8) # decrease the font / legend size


## ----add-colors---------------------------------------------------------------------------

# we have a list of colors that we used above - we can use it in the legend
roadPalette

# create a list of colors to use 
plotColors <- c("purple", "grey", roadPalette)
plotColors

# render plot
plot_HARV

# add a legend to our map
legend("bottomright", 
       legend=labels, 
       fill=plotColors,
       bty="n", # turn off the legend border
       cex=.8) # decrease the font / legend size



## ----custom-symbols-----------------------------------------------------------------------

# create a list of pch values
# these are the symbols that will be used for each legend value
# ?pch will provide more information on values
plotSym <- c(16,15,15,15,15,15)
plotSym

# Plot multiple shapefiles
plot_HARV

# to create a custom legend, we need to fake it
legend("bottomright", 
       legend=labels,
       pch=plotSym, 
       bty="n", 
       col=plotColors,
       cex=.8)



## ----refine-legend------------------------------------------------------------------------
# create line object
lineLegend = c(NA,NA,1,1,1,1)
lineLegend
plotSym <- c(16,15,NA,NA,NA,NA)
plotSym

# plot multiple shapefiles
plot_HARV

# build a custom legend
legend("bottomright", 
       legend=labels, 
       lty = lineLegend,
       pch=plotSym, 
       bty="n", 
       col=plotColors,
       cex=.8)



## ----challenge-code-plot-color, results="hide", warning= FALSE, echo=FALSE----------------
## 1
# open plot locations
plotLocations <- readOGR("NEON-DS-Site-Layout-Files/HARV",
          "PlotLocations_HARV")

# how many unique soils?  Two
unique(plotLocations$soilTypeOr)

# create new color palette -- topo.colors palette
blueGreen <- c("blue","darkgreen")
blueGreen

# plot roads
plot(lines_HARV, 
     col=roadColors,
     main="NEON Harvard Forest Field Site\n Study Plots by Soil Type\n One Symbol for All Types")

# plot the locations 
plot(plotLocations,
     col=(blueGreen)[plotLocations$soilTypeOr], 
     pch=18,
     add=TRUE)

# create line object
lineLegendElement = c(NA,NA,1,1,1,1)
lineLegendElement
plotSymElements <- c(18,18,NA,NA,NA,NA)
plotSymElements

# create vector of colors
colorElements <- c(blueGreen, roadPalette)
colorElements

# create legend 
legend("bottomright", 
       legend=c("Inceptisols","Histosols",levels(lines_HARV$TYPE)),
       pch=plotSymElements, 
       lty=lineLegendElement,
       col=colorElements,
       bty="n", 
       cex=1)

## 2
# create vector of DIFFERENT plot symbols
plSymbols <- c(15,17)[plotLocations$soilTypeOr]
plSymbols

# plot roads
plot(lines_HARV, 
     col=roadColors,
     main="NEON Harvard Forest Field Site\n Study Plots by Soil Type\n Different Symbols for Types")

# plot the locations 
plot(plotLocations,
     col=(blueGreen)[plotLocations$soilTypeOr], 
     pch=plSymbols,
     add=TRUE)

# create line object
lineLegendElement  <- c(NA,NA,1,1,1,1)
lineLegendElement
plotSymElementsMod <- c(15,17,NA,NA,NA,NA)
plotSymElementsMod

# create vector of colors
colorElements <- c(blueGreen, roadPalette)
colorElements
# create legend 
legend("bottomright", 
       legend=c("Inceptisols","Histosols",levels(lines_HARV$TYPE)),
       pch=plotSymElementsMod, 
       lty=lineLegendElement,
       col=colorElements,
       bty="n", 
       cex=1)

