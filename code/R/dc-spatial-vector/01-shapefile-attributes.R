## ----load-packages-data--------------------------------------------------
# load packages
# rgdal: for vector work; sp package should always load with rgdal. 
library(rgdal)  
# raster: for metadata/attributes- vectors or rasters
library (raster)   

# set working directory to data folder
# setwd("pathToDirHere")

# Import a polygon shapefile 
aoiBoundary_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
                            "HarClip_UTMZ18")

# Import a line shapefile
lines_HARV <- readOGR( "NEON-DS-Site-Layout-Files/HARV/", "HARV_roads")

# Import a point shapefile 
point_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV/",
                      "HARVtower_UTM18N")


## ----view-shapefile-metadata---------------------------------------------
# view class
class(x = point_HARV)

# x= isn't actually needed; it just specifies which object
# view features count
length(point_HARV)

# view crs - note - this only works with the raster package loaded
crs(point_HARV)

# view extent- note - this only works with the raster package loaded
extent(point_HARV)

# view metadata summary
point_HARV

## ----shapefile-attributes------------------------------------------------
# just view the attributes & first 6 attribute values of the data
head(lines_HARV@data)

# how many attributes are in our vector data object?
length(lines_HARV@data)


## ----view-shapefile-attributes-------------------------------------------
# view just the attribute names for the lines_HARV spatial object
names(lines_HARV@data)


## ----challenge-code-attributes-classes, results="hide", echo=FALSE-------
# 1
length(names(point_HARV@data))  #14 attributes
names(aoiBoundary_HARV@data)  #1 attribute

# 2
head(point_HARV@data)  #Harvard University, LTER

# 3
point_HARV@data  # C Country

## ----explore-attribute-values--------------------------------------------
# view all attributes in the lines shapefile within the TYPE field
lines_HARV$TYPE

# view unique values within the "TYPE" attributes
levels(lines_HARV@data$TYPE)


## ----Subsetting-shapefiles-----------------------------------------------
# select features that are of TYPE "footpath"
# could put this code into other function to only have that function work on
# "footpath" lines
lines_HARV[lines_HARV$TYPE == "footpath",]

# save an object with only footpath lines
footpath_HARV <- lines_HARV[lines_HARV$TYPE == "footpath",]
footpath_HARV

# how many features are in our new object
length(footpath_HARV)

## ----plot-subset-shapefile-----------------------------------------------
# plot just footpaths
plot(footpath_HARV,
     lwd=6,
     main="NEON Harvard Forest Field Site\n Footpaths")


## ----plot-subset-shapefile-unique-colors---------------------------------
# plot just footpaths
plot(footpath_HARV,
     col=c("green","blue"), # set color for each feature 
     lwd=6,
     main="NEON Harvard Forest Field Site\n Footpaths \n Feature one = blue, Feature two= green")


## ----challenge-code-feature-subset, results="hide", echo=FALSE-----------

# save an object with only boardwalk lines
boardwalk_HARV<-lines_HARV[lines_HARV$TYPE == "boardwalk",]
boardwalk_HARV

# how many features are in our new object
length(boardwalk_HARV)

# plot just footpaths
plot(boardwalk_HARV,
     col=c("green"), # set color for feature 
     lwd=6,
     main="NEON Harvard Forest Field Site\n Boardwalks\n Feature one = blue, Feature two= green")

# save an object with only boardwalk lines
stoneWall_HARV<-lines_HARV[lines_HARV$TYPE == "stone wall",]
stoneWall_HARV

# how many features are in our new object?
length(stoneWall_HARV)

# plot just footpaths
plot(stoneWall_HARV,
     col=c("green", "blue", "orange", "brown", "darkgreen", "purple"), 
        # set color for each feature 
     lwd=6,
     main="NEON Harvard Forest Field Site\n Stonewalls\n Each Feature in Different Color")


## ----convert-to-factor---------------------------------------------------
# view the original class of the TYPE column
class(lines_HARV$TYPE)

# view levels or categories - note that there are no categories yet in our data!
# the attributes are just read as a list of character elements.
levels(lines_HARV$TYPE)

# Convert the TYPE attribute into a factor
# Only do this IF the data do not import as a factor!
# lines_HARV$TYPE <- as.factor(lines_HARV$TYPE)
# class(lines_HARV$TYPE)
# levels(lines_HARV$TYPE)

# how many features are in each category or level?
summary(lines_HARV$TYPE)

## ----palette-and-plot----------------------------------------------------
# Check the class of the attribute - is it a factor?
class(lines_HARV$TYPE)

# how many "levels" or unique values does hte factor have?
# view factor values
levels(lines_HARV$TYPE)
# count the number of unique values or levels
length(levels(lines_HARV$TYPE))

# create a color palette of 4 colors - one for each factor level
roadPalette <- c("blue","green","grey","purple")
roadPalette
# create a vector of colors - one for each feature in our vector object
# according to its attribute value
roadColors <- c("blue","green","grey","purple")[lines_HARV$TYPE]
roadColors

# plot the lines data, apply a diff color to each factor level)
plot(lines_HARV, 
     col=roadColors,
     lwd=3,
     main="NEON Harvard Forest Field Site\n Roads & Trails")


## ----adjust-line-width---------------------------------------------------
# make all lines thicker
plot(lines_HARV, 
     col=roadColors,
     main="NEON Harvard Forest Field Site\n Roads & Trails\n All Lines Thickness=6",
     lwd=6)


## ----line-width-unique---------------------------------------------------
class(lines_HARV$TYPE)
levels(lines_HARV$TYPE)
# create vector of line widths
lineWidths <- (c(1,2,3,4))[lines_HARV$TYPE]
# adjust line width by level
# in this case, boardwalk (the first level) is the widest.
plot(lines_HARV, 
     col=roadColors,
     main="NEON Harvard Forest Field Site\n Roads & Trails \n Line width varies by TYPE Attribute Value",
     lwd=lineWidths)

## ----bicycle-map, include=TRUE, results="hide", echo=FALSE---------------

# view the factor levels
levels(lines_HARV$TYPE)
# create vector of line width values
lineWidth <- c(2,4,3,8)[lines_HARV$TYPE]
# view vector
lineWidth

# in this case, boardwalk (the first level) is the widest.
plot(lines_HARV, 
     col=roadColors,
     main="NEON Harvard Forest Field Site\n Roads & Trails \n Line width varies by Type Attribute Value",
     lwd=lineWidth)


## ----add-legend-to-plot--------------------------------------------------
plot(lines_HARV, 
     col=roadColors,
     main="NEON Harvard Forest Field Site\n Roads & Trails\n Default Legend")

# we can use the color object that we created above to color the legend objects
roadPalette

# add a legend to our map
legend("bottomright",   # location of legend
      legend=levels(lines_HARV$TYPE), # categories or elements to render in 
			 # the legend
      fill=roadPalette) # color palette to use to fill objects in legend.


## ----modify-legend-plot--------------------------------------------------

plot(lines_HARV, 
     col=roadColors,
     main="NEON Harvard Forest Field Site\n Roads & Trails \n Modified Legend")
# add a legend to our map
legend("bottomright", 
       legend=levels(lines_HARV$TYPE), 
       fill=roadPalette, 
       bty="n", # turn off the legend border
       cex=.8) # decrease the font / legend size


## ----plot-different-colors-----------------------------------------------

# manually set the colors for the plot!
newColors <- c("springgreen", "blue", "magenta", "orange")
newColors

# plot using new colors
plot(lines_HARV, 
     col=(newColors)[lines_HARV$TYPE],
     main="NEON Harvard Forest Field Site\n Roads & Trails \n Pretty Colors")

# add a legend to our map
legend("bottomright", 
       levels(lines_HARV$TYPE), 
       fill=newColors, 
       bty="n", cex=.8)


## ----bicycle-map-2, include=TRUE, results="hide", echo=FALSE-------------
# view levels 
levels(lines_HARV$BicyclesHo)
# make sure the attribute is of class "Factor"

class(lines_HARV$BicyclesHo)

# convert to factor if necessary
lines_HARV$BicyclesHo <- as.factor(lines_HARV$BicyclesHo)
levels(lines_HARV$BicyclesHo)

# remove NA values
lines_removeNA <- lines_HARV[na.omit(lines_HARV$BicyclesHo),]
# count factor levels
length(levels(lines_HARV$BicyclesHo))
# set colors so only the allowed roads are magenta
# note there are 3 levels so we need 3 colors
challengeColors <- c("magenta","grey","grey")
challengeColors

# set line width so the first factor level is thicker than the others
lines_HARV$BicyclesHo
c(4,1,1)[lines_HARV$BicyclesHo]

# plot using new colors
plot(lines_HARV,
     col=(challengeColors)[lines_HARV$BicyclesHo],
     lwd=c(4,1,1)[lines_HARV$BicyclesHo],
     main="NEON Harvard Forest Field Site\n Roads Where Bikes and Horses Are Allowed")

# add a legend to our map
legend("bottomright", 
       levels(lines_HARV$BicyclesHo), 
       fill=challengeColors, 
       bty="n", # turn off border
       cex=.8) # adjust font size


## ----challenge-code-plot-color, results="hide", warning= FALSE, echo=FALSE----
## 1
# Read the shapefile file
State.Boundary.US <- readOGR("NEON-DS-Site-Layout-Files/US-Boundary-Layers",
          "US-State-Boundaries-Census-2014")

# how many levels?
levels(State.Boundary.US$region)
colors <- c("purple","springgreen","yellow","brown","grey")
colors

plot(State.Boundary.US,
     col=(colors)[State.Boundary.US$region],
     main="Contiguous U.S. State Boundaries \n 50 Colors")

# add a legend to our map
legend("bottomright", 
       levels(State.Boundary.US$region), 
       fill=colors, 
       bty="n", #turn off border
       cex=.7) #adjust font size

## 2
# open plot locations
plotLocations <- readOGR("NEON-DS-Site-Layout-Files/HARV",
          "PlotLocations_HARV")

# how many unique soils?  Two
unique(plotLocations$soilTypeOr)

# create new color palette -- topo.colors palette
blueGreen <- c("blue","springgreen")
blueGreen

# plot the locations 
plot(plotLocations,
     col=(blueGreen)[plotLocations$soilTypeOr], 
     pch=18,
     main="NEON Harvard Forest Field Site\n Study Plots by Soil Type\n One Symbol for All Types")

# create legend 
legend("bottomright", 
       legend=c("Intceptisols","Histosols"),
       pch=18, 
       col=blueGreen,
       bty="n", 
       cex=1)

## 3
# create vector of plot symbols
plSymbols <- c(15,17)[plotLocations$soilTypeOr]
plSymbols

# plot the locations 
plot(plotLocations,
     col=plotLocations$soilTypeOr, 
     pch=plSymbols,
     main="NEON Harvard Forest Field Site\n Study Plots by Soil Type\n Unique Symbol for Each Type")

# create vector of plot symbols ONLY. Legend needs only the symbols
plSymbolsL <- c(15,17)
plSymbolsL

# create legend 
legend("bottomright", 
       legend=c("Intceptisols","Histosols"),
       pch=plSymbolsL, 
       col=palette(),
       bty="n", 
       cex=1)

