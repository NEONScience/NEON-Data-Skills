## ----set-up-env, eval=F-----------------------------------------------------------------------------------
## # Install neonUtilities package if you have not yet.
## install.packages("neonUtilities")
## install.packages("ggplot2")
## 


## ----load-packages----------------------------------------------------------------------------------------
# Set global option to NOT convert all character variables to factors
options(stringsAsFactors=F)

# Load required packages
library(neonUtilities)
library(ggplot2)



## ----download-data----------------------------------------------------------------------------------------
# download data of interest - Water Quality
waq<-loadByProduct(dpID="DP1.20288.001", site="BLDE", 
				startdate="2019-10", enddate="2019-11", 
				package="expanded", 
				token = Sys.getenv("NEON_TOKEN"),
				check.size = F)



## ----challenge-code-download-nitrate, echo=FALSE, results='hide', message=FALSE---------------------------
# download data of interest - Nitrate in Suface Water
nitr<-loadByProduct(dpID="DP1.20033.001", site="BLDE", 
											 startdate="2019-10", enddate="2019-11", 
											 package="expanded", 
											 token = Sys.getenv("NEON_TOKEN"),
											 check.size = F)

# #1. 73.3 KiB 
# #2. You can change check.size to True (T), and compare "basic" vs "expaneded"
# package types. The basic package is 66.2 KiB. 



## ----loadBy-list------------------------------------------------------------------------------------------
# view all components of the list
names(waq)

# View the dataFrame
View(waq$waq_instantaneous)



## ----unlist-----------------------------------------------------------------------------------------------

# assign the dataFrame in the list as an object
#wqInst <- waq$waq_instantaneous

# unlist the vari
list2env(waq, .GlobalEnv)



## ----num-locations----------------------------------------------------------------------------------------
# which sensor locations?
unique(waq_instantaneous$horizontalPosition)



## ----split-hor--------------------------------------------------------------------------------------------
# seperate data from sensors
waqUp<-waq_instantaneous[(waq_instantaneous$horizontalPosition=="101"),]
waqDown<-waq_instantaneous[(waq_instantaneous$horizontalPosition=="102"),]



## ----plot-wqual-------------------------------------------------------------------------------------------
# plot
wqual <- ggplot() +
	geom_line(data = waqUp, aes(startDateTime, dissolvedOxygen), na.rm=TRUE, color="purple",) +
	geom_line(data = waqDown, aes(startDateTime, dissolvedOxygen), na.rm=TRUE, color="orange",) +
	geom_line( na.rm = TRUE)+
	ylim(0, 20) + ylab("Dissolved Oxygen (mg/L)") +
	xlab(" ")

wqual



## ----challenge-code-plot-nitrate, echo=FALSE, results='hide', message=FALSE-------------------------------
# create DataFrame
nitrate <- nitr$NSW_15_minute

# which sensor locations?
unique(nitrate$horizontalPosition)

##Yes, there is only one horizonatalPosition. This is because nitrate is only 
##collected at the downstream sensor location. 

# plot
NO3plot <- ggplot(nitrate, aes(startDateTime, surfWaterNitrateMean)) +
	geom_line(na.rm=TRUE, color="blue",) + 
	ylab("NO3-N (uM)") + xlab(" ")

NO3plot


