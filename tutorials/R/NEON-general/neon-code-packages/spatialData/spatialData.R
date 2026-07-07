## ----install, eval=FALSE----------------------------------------------------------------------------------------------------
# 
# # run once to get the package, and re-run if you need to get updates
# install.packages("ggplot2")
# install.packages("dplyr")
# install.packages("neonUtilities")
# install.packages("neonOS")
# install.packages("devtools")
# devtools::install_github("NEONScience/NEON-geolocation/geoNEON")
# 


## ----libraries, results="hide"----------------------------------------------------------------------------------------------

library(ggplot2)
library(dplyr)
library(neonUtilities)
library(neonOS)
library(geoNEON)

token <- Sys.getenv("NEON_TOKEN")



## ----get-vst-data, results="hide", message=FALSE----------------------------------------------------------------------------

vst <- loadByProduct(dpID="DP1.10098.001", 
                     site="WREF",
                     include.provisional=T,
                     check.size=F,
                     token=token)



## ----find-sp-data-----------------------------------------------------------------------------------------------------------

View(vst$variables_10098)



## ----print-vst-pppy---------------------------------------------------------------------------------------------------------

View(vst$vst_perplotperyear)



## ----plot-plots, fig.cap="All vegetation structure plots at WREF"-----------------------------------------------------------

# start by subsetting data to plots with trees
vst.trees <- vst$vst_perplotperyear |>
  filter(treesPresent=="Y")

# create plot size variable
vst.trees <- vst.trees |>
  mutate(plotsize = case_when(plotType=="tower" ~ 40,
                              plotType=="distributed" ~ 20,
                              TRUE ~ NA))

# create map of plots
symbols(vst.trees$easting,
        vst.trees$northing,
        squares=vst.trees$plotsize, 
        inches=F,
        xlab="Easting", 
        ylab="Northing")



## ----print-vst-mat----------------------------------------------------------------------------------------------------------

View(vst$vst_mappingandtagging)



## ----vst-getLocTOS, results="hide", message=FALSE---------------------------------------------------------------------------

vst.loc <- getLocTOS(data=vst$vst_mappingandtagging,
                     dataProd="vst_mappingandtagging",
                     token=token)



## ----vst-diff---------------------------------------------------------------------------------------------------------------

setdiff(names(vst.loc),
        names(vst$vst_mappingandtagging))



## ----vst-all-trees, fig.cap="All mapped tree locations at WREF"-------------------------------------------------------------

plot(vst.loc$adjEasting, 
     vst.loc$adjNorthing,
     xlab="Easting", 
     ylab="Northing",
     pch=".")



## ----plot-WREF_085, fig.width=6, fig.height=6, fig.cap="Tree locations in plot WREF_085"------------------------------------

plot(subset(vst.loc, plotID=="WREF_085",
            select=c(adjEasting, adjNorthing)),
     pch=20, xlab="Easting", ylab="Northing")



## ----plot-WREF_085-species, fig.width=6, fig.height=6, fig.cap="Tree species and their locations in plot WREF_085"----------

vst.085 <- vst.loc |>
  filter(plotID=="WREF_085")

plot(vst.085$adjEasting,
     vst.085$adjNorthing,
     xlab="Easting", 
     ylab="Northing",
     type="n")
text(vst.085$adjEasting,
     vst.085$adjNorthing,
     labels=vst.085$taxonID,
     cex=0.5)



## ----join-vst---------------------------------------------------------------------------------------------------------------

veg <- joinTableNEON(vst.loc, 
                     vst$vst_apparentindividual,
                     name1="vst_mappingandtagging",
                     name2="vst_apparentindividual")



## ----plot-WREF_085-diameter, fig.width=6, fig.height=6, fig.cap="Tree bole diameters in plot WREF_085"----------------------

veg.085 <- veg |>
  filter(plotID=="WREF_085")

symbols(veg.085$adjEasting, 
        veg.085$adjNorthing, 
        circles=veg.085$stemDiameter/100/2, 
        inches=F, 
        xlab="Easting", 
        ylab="Northing")



## ----soilT-load, results="hide", message=FALSE------------------------------------------------------------------------------

soilT <- loadByProduct(dpID="DP1.00041.001", site="TREE",
                    startdate="2018-07", enddate="2018-07",
                    timeIndex=30, check.size=F,
                    token=token)



## ----sens-pos---------------------------------------------------------------------------------------------------------------

# create object for sensor positions file
pos <- soilT$sensor_positions_00041

# view column names
names(pos)

# view table
View(pos)



## ----pos-levs---------------------------------------------------------------------------------------------------------------

unique(pos$HOR.VER)



## ----issue-log--------------------------------------------------------------------------------------------------------------

soilT$issueLog_00041 |>
  filter(grepl("TREE soil plot 1", locationAffected))



## ----pos-rem----------------------------------------------------------------------------------------------------------------

pos <- pos |>
  filter_out(grepl("001.", pos$HOR.VER) & 
               is.na(positionEndDateTime))



## ----pos-join---------------------------------------------------------------------------------------------------------------

# paste horizontalPosition and verticalPosition together
# to match HOR.VER in the sensor positions file
soilT$ST_30_minute <- soilT$ST_30_minute |>
  mutate(HOR.VER = paste(horizontalPosition,
                         verticalPosition,
                         sep="."))

# left join to keep all temperature records
soilTHV <- merge(soilT$ST_30_minute, pos, 
                 by="HOR.VER", all.x=T)



## ----soilT-plot, fig.cap="Tiled figure of temperature by depth in each plot"------------------------------------------------

gg <- ggplot(soilTHV, 
             aes(endDateTime, soilTempMean, 
                 group=zOffset, color=zOffset)) +
             geom_line() + 
        facet_wrap(~horizontalPosition)
gg



## ----soilT-plot-noQF, fig.cap="Tiled figure of temperature by depth in each plot with only passing quality flags"-----------

gg <- ggplot(subset(soilTHV, finalQF==0), 
             aes(endDateTime, soilTempMean, 
                 group=zOffset, color=zOffset)) +
             geom_line() + 
        facet_wrap(~horizontalPosition)
gg


