## ----install, eval=FALSE---------------------------------------------------------------------------------
## 
## # run once to get the package, and re-run if you need to get updates
## install.packages("ggplot2")  # plotting
## install.packages("neonUtilities")  # work with NEON data
## install.packages("devtools")  # to use the install_github() function
## devtools::install_github("NEONScience/NEON-geolocation/geoNEON")  # work with NEON spatial data
## 


## ----libraries, results="hide"---------------------------------------------------------------------------

# run every time you start a script
library(ggplot2)
library(neonUtilities)
library(geoNEON)

options(stringsAsFactors=F)



## ----get-vst-data, results="hide"------------------------------------------------------------------------

# load veg structure data
vst <- loadByProduct(dpID="DP1.10098.001", site="WREF",
                     check.size=F)



## ----find-sp-data----------------------------------------------------------------------------------------

View(vst$variables_10098)



## ----print-vst-pppy--------------------------------------------------------------------------------------

head(vst$vst_perplotperyear)



## ----plot-plots, fig.cap="All vegetation structure plots at WREF"----------------------------------------

# start by subsetting data to plots with trees
vst.trees <- vst$vst_perplotperyear[which(
        vst$vst_perplotperyear$treesPresent=="Y"),]

# make variable for plot sizes
plot.size <- numeric(nrow(vst.trees))

# populate plot sizes in new variable
plot.size[which(vst.trees$plotType=="tower")] <- 40
plot.size[which(vst.trees$plotType=="distributed")] <- 20

# create map of plots
symbols(vst.trees$easting,
        vst.trees$northing,
        squares=plot.size, inches=F,
        xlab="Easting", ylab="Northing")



## ----print-vst-mat---------------------------------------------------------------------------------------

head(vst$vst_mappingandtagging)



## ----vst-getLocTOS, results="hide"-----------------------------------------------------------------------

# calculate individual tree locations
vst.loc <- getLocTOS(data=vst$vst_mappingandtagging,
                           dataProd="vst_mappingandtagging")



## ----vst-diff--------------------------------------------------------------------------------------------

# print variable names that are new
names(vst.loc)[which(!names(vst.loc) %in% 
                             names(vst$vst_mappingandtagging))]



## ----vst-all-trees, fig.cap="All mapped tree locations at WREF"------------------------------------------

# plot all trap locations at site
plot(vst.loc$adjEasting, vst.loc$adjNorthing, pch=".",
     xlab="Easting", ylab="Northing")



## ----plot-WREF_085, fig.width=6, fig.height=6, fig.cap="Tree locations in plot WREF_085"-----------------

# plot all trap locations in one grid (plot)
plot(vst.loc$adjEasting[which(vst.loc$plotID=="WREF_085")], 
     vst.loc$adjNorthing[which(vst.loc$plotID=="WREF_085")], 
     pch=20, xlab="Easting", ylab="Northing")



## ----plot-WREF_085-species, fig.width=6, fig.height=6, fig.cap="Tree species and their locations in plot WREF_085"----

plot(vst.loc$adjEasting[which(vst.loc$plotID=="WREF_085")], 
     vst.loc$adjNorthing[which(vst.loc$plotID=="WREF_085")], 
     type="n", xlab="Easting", ylab="Northing")
text(vst.loc$adjEasting[which(vst.loc$plotID=="WREF_085")], 
     vst.loc$adjNorthing[which(vst.loc$plotID=="WREF_085")],
     labels=vst.loc$taxonID[which(vst.loc$plotID=="WREF_085")],
     cex=0.5)



## ----join-vst--------------------------------------------------------------------------------------------

veg <- merge(vst.loc, vst$vst_apparentindividual,
             by=c("individualID","namedLocation",
                  "domainID","siteID","plotID"))



## ----plot-WREF_085-diameter, fig.width=6, fig.height=6, fig.cap="Tree bole diameters in plot WREF_085"----

symbols(veg$adjEasting[which(veg$plotID=="WREF_085")], 
        veg$adjNorthing[which(veg$plotID=="WREF_085")], 
        circles=veg$stemDiameter[which(veg$plotID=="WREF_085")]/100/2, 
        inches=F, xlab="Easting", ylab="Northing")



## ----soilT-load, results="hide"--------------------------------------------------------------------------

# load soil temperature data of interest 
soilT <- loadByProduct(dpID="DP1.00041.001", site="TREE",
                    startdate="2018-07", enddate="2018-07",
                    avg=30, check.size=F)



## ----sens-pos--------------------------------------------------------------------------------------------

# create object for sensor positions file
pos <- soilT$sensor_positions_00041

# view column names
names(pos)

# view table
View(pos)



## ----pos-levs--------------------------------------------------------------------------------------------

unique(pos$HOR.VER)



## ----pos-rem---------------------------------------------------------------------------------------------

pos <- pos[-intersect(grep("001.", pos$HOR.VER),
                      which(pos$end=="")),]



## ----pos-join--------------------------------------------------------------------------------------------

# paste horizontalPosition and verticalPosition together
# to match HOR.VER in the sensor positions file
soilT$ST_30_minute$HOR.VER <- paste(soilT$ST_30_minute$horizontalPosition,
                                    soilT$ST_30_minute$verticalPosition,
                                    sep=".")

# left join to keep all temperature records
soilTHV <- merge(soilT$ST_30_minute, pos, 
                 by="HOR.VER", all.x=T)



## ----soilT-plot, fig.cap="Tiled figure of temperature by depth in each plot"-----------------------------

gg <- ggplot(soilTHV, 
             aes(endDateTime, soilTempMean, 
                 group=zOffset, color=zOffset)) +
             geom_line() + 
        facet_wrap(~horizontalPosition)
gg



## ----soilT-plot-noQF, fig.cap="Tiled figure of temperature by depth in each plot with only passing quality flags"----

gg <- ggplot(subset(soilTHV, finalQF==0), 
             aes(endDateTime, soilTempMean, 
                 group=zOffset, color=zOffset)) +
             geom_line() + 
        facet_wrap(~horizontalPosition)
gg


