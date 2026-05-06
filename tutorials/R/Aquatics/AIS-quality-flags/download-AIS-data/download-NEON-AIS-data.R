## ----set-up-env, eval=F-----------------------------------------------------------------------------------------------------------------------------------
## # Install neonUtilities package if you have not yet.
## install.packages("neonUtilities")
## install.packages("ggplot2")


## ----load-packages----------------------------------------------------------------------------------------------------------------------------------------
# Set global option to NOT convert all character variables to factors
options(stringsAsFactors=F)

# Load required packages
library(neonUtilities)
library(ggplot2)


## ----download-data-waq, results='hide'--------------------------------------------------------------------------------------------------------------------
# download data of interest - Water Quality
waq <- loadByProduct(dpID="DP1.20288.001", site="PRIN", 
                     startdate="2020-02", enddate="2020-02", 
                     package="expanded", release="current", 
                     check.size = F)



## ----loadBy-list------------------------------------------------------------------------------------------------------------------------------------------
# view all components of the list
names(waq)



## ----unlist-vars, results='hide'--------------------------------------------------------------------------------------------------------------------------
# unlist the variables and add to the global environment
list2env(waq, .GlobalEnv)


## ----view-meta-files, eval=F------------------------------------------------------------------------------------------------------------------------------
## # which sensor locations exist in the water quality dataset we just downloaded?
## View(waq_instantaneous)
## View(sensor_positions_20288)
## View(variables_20288)


## ----check-release----------------------------------------------------------------------------------------------------------------------------------------
# which release is the data from?
unique(waq_instantaneous$release)


## ----waq-hor-num-locations--------------------------------------------------------------------------------------------------------------------------------
# which sensor locations exist in the water quality dataset we just downloaded?
unique(waq_instantaneous$horizontalPosition)


## ----split-waq-hor----------------------------------------------------------------------------------------------------------------------------------------
# Split data into separate dataframes by upstream/downstream locations.
waq_up <- 
  waq_instantaneous[(waq_instantaneous$horizontalPosition=="101"),]
waq_down <- 
  waq_instantaneous[(waq_instantaneous$horizontalPosition=="102"),]


## ----column-names-----------------------------------------------------------------------------------------------------------------------------------------
# One option is to view column names in the data frame
colnames(waq_instantaneous)


## ----column-names-view, eval=F----------------------------------------------------------------------------------------------------------------------------
## # Alternatively, view the variables object corresponding to the data product for more information
## View(variables_20288)


## ----plot-waq-do------------------------------------------------------------------------------------------------------------------------------------------
# plot
doPlot <- ggplot() +
	geom_line(data = waq_down,aes(endDateTime, dissolvedOxygen),na.rm=TRUE, color="blue") +
  geom_ribbon(data=waq_down,aes(x=endDateTime, 
                  ymin = (dissolvedOxygen - dissolvedOxygenExpUncert), 
                  ymax = (dissolvedOxygen + dissolvedOxygenExpUncert)), 
              alpha = 0.4, fill = "grey25") +
	ylim(8, 15) + ylab("DO (mg/L)") + xlab("Date") + ggtitle("PRIN Downstream DO with Uncertainty Bounds") 

doPlot


## ----view-qf----------------------------------------------------------------------------------------------------------------------------------------------
waq_qf_names <- names(waq_down)[grep("QF", names(waq_down))]

print(paste0("Total columns in DP1.20288.001 expanded package = ", 
             as.character(length(waq_qf_names))))

# Let's just look at those corresponding to dissolvedOxygen.
# We need to remove those associated with dissolvedOxygenSaturation.
do_qf_names <- waq_qf_names[grep("dissolvedOxygen",waq_qf_names)]
do_qf_names <- do_qf_names[grep("dissolvedOxygenSat",do_qf_names,invert=T)]

print("dissolvedOxygen columns in DP1.20288.001 expanded package:")
print(do_qf_names)


## ----view-do-qf-------------------------------------------------------------------------------------------------------------------------------------------

for(col_nam in do_qf_names){
  print(paste0(col_nam, " unique values: ", 
               paste0(unique(waq_down[,col_nam]), 
                      collapse = ", ")))
}



## ----dig-into-qf, echo=TRUE-------------------------------------------------------------------------------------------------------------------------------
# Loop across the QF column names. 
#  Within each column, count the number of rows that equal '1'.
print("FLAG TEST - COUNT")
for (col_nam in do_qf_names){
  totl_qf_in_col <- length(which(waq_down[,col_nam] == 1))
  print(paste0(col_nam,": ",totl_qf_in_col))
}

print(paste0("Total DO observations: ", nrow(waq_down) ))


## ----plot-waq-do-flags------------------------------------------------------------------------------------------------------------------------------------
# plot
doPlot <- ggplot() +
	geom_line(data = waq_down, aes(x=endDateTime, y=dissolvedOxygen,
	                 color=factor(dissolvedOxygenFinalQF)), na.rm=TRUE) +
  scale_color_manual(values = c("0" = "blue","1"="red")) +
  ylim(8, 15) + ylab("DO (mg/L)") + xlab("Date") + ggtitle("PRIN Downstream DO filtered by FinalQF") 
  
doPlot


## ----download-data-tsw, results='hide'--------------------------------------------------------------------------------------------------------------------
# download continuous discharge data
csd <- loadByProduct(dpID="DP1.20053.001", site="PRIN", 
                     startdate="2020-02", enddate="2020-02", 
                     package="expanded", release="current", 
                     check.size = F)
list2env(csd,.GlobalEnv)



## ----tsw-hor-num-locations--------------------------------------------------------------------------------------------------------------------------------
# which sensor locations exist in the temperature of surface water dataset?
unique(TSW_30min$horizontalPosition)


## ----split-tsw-hor----------------------------------------------------------------------------------------------------------------------------------------
# Split data into separate dataframe for downstream location.
tsw_down <- 
  TSW_30min[(TSW_30min$horizontalPosition=="102"),]



## ----remove-tsw-flagged-----------------------------------------------------------------------------------------------------------------------------------
# remove values with a final quality flag
tsw_down<-tsw_down[(tsw_down$finalQF=="0"),]



## ----plot-tsw---------------------------------------------------------------------------------------------------------------------------------------------
# plot
csdPlot <- ggplot() +
	geom_line(data = tsw_down,aes(endDateTime, surfWaterTempMean),na.rm=TRUE, color="blue") +
  geom_ribbon(data=tsw_down,aes(x=endDateTime, 
                  ymin = (surfWaterTempMean-surfWaterTempExpUncert), 
                  ymax = (surfWaterTempMean+surfWaterTempExpUncert)), 
              alpha = 0.4, fill = "grey25") +
	ylim(2, 16) + ylab("Temp (C)") + xlab("Date") + ggtitle("PRIN Downstream Temp with Uncertainty Bounds") 

csdPlot


## ----download-data-csd, results='hide'--------------------------------------------------------------------------------------------------------------------
# download continuous discharge data
csd <- loadByProduct(dpID="DP4.00130.001", site="PRIN", 
                     startdate="2020-02", enddate="2020-02", 
                     package="expanded", release="current", 
                     check.size = F)
list2env(csd,.GlobalEnv)



## ----remove-csd-flagged-----------------------------------------------------------------------------------------------------------------------------------
# remove values with a final quality flag
csd_continuousDischarge<-csd_continuousDischarge[(csd_continuousDischarge$dischargeFinalQF=="0"),]



## ----plot-q-----------------------------------------------------------------------------------------------------------------------------------------------
# plot
csdPlot <- ggplot() +
	geom_line(data = csd_continuousDischarge,aes(endDate, maxpostDischarge),na.rm=TRUE, color="blue") +
  geom_ribbon(data=csd_continuousDischarge,aes(x=endDate, 
                  ymin = (withRemnUncQLower1Std), 
                  ymax = (withRemnUncQUpper1Std)), 
              alpha = 0.4, fill = "grey25") +
	ylim(0, 4000) + ylab("Q (L/s)") + xlab("Date") + ggtitle("PRIN Discharge with Uncertainty Bounds") 

csdPlot

