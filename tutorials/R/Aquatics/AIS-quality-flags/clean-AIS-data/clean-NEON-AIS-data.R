## ----set-up-env, eval=F-----------------------------------------------------------------------
## # Install the required package if you have not yet.
## install.packages("neonUtilities")
## install.packages("ggplot2")
## install.packages("zoo")
## install.packages("kableExtra")


## ----load-packages, results='hide', message=FALSE---------------------------------------------
# Load required packages
library(neonUtilities)
library(ggplot2)
library(zoo)
library(kableExtra)


## ----download-data-waq, results='hide', warning=FALSE-----------------------------------------
waq <- neonUtilities::loadByProduct(dpID="DP1.20288.001", site="WALK", 
                     startdate="2024-04", enddate="2024-05",
                     package="expanded", release="current",
                     include.provisional=T,
                     check.size=F)
list2env(waq,.GlobalEnv)


## ----subset-waq-horizontalPosition------------------------------------------------------------
waq_down<-waq_instantaneous[(waq_instantaneous$horizontalPosition==102),]


## ----plot-do-raw------------------------------------------------------------------------------
doPlotRaw <- ggplot() +
	geom_line(data = waq_down,aes(startDateTime, localDissolvedOxygenSat, colour="raw"),na.rm=TRUE) +
  geom_ribbon(data=waq_down,aes(x=startDateTime, 
                  ymin = (localDissolvedOxygenSat - localDOSatExpUncert), 
                  ymax = (localDissolvedOxygenSat + localDOSatExpUncert)), 
                  alpha = 0.3, fill = "red") +
  scale_colour_manual("",breaks=c("raw"),values=c("red")) +
	ylim(0, 120) + ylab("saturation (%)") + xlab("Date")+ ggtitle("WALK dissolvedOxygenSat with Uncertainty")
doPlotRaw


## ----filter-waq-issue-log---------------------------------------------------------------------
issueLog_20288<-issueLog_20288[(grepl(unique(waq_instantaneous$siteID),
                                      issueLog_20288$locationAffected))]
issueLog_20288<-issueLog_20288[!((issueLog_20288$dateRangeStart>
                                    max(waq_instantaneous$startDateTime))
              |(issueLog_20288$dateRangeEnd<
                  min(waq_instantaneous$startDateTime))),]
issueLog_20288 %>%
  kbl() %>%
    kable_styling()


## ----populate-do-clean------------------------------------------------------------------------
waq_down$cleanDissolvedOxygenSat<-waq_down$localDissolvedOxygenSat
waq_down$cleanDissolvedOxygenSat[waq_down$localDOSatFinalQF == 1] <- NA


## ----alternate_step---------------------------------------------------------------------------
stepStart <- as.POSIXct("2024-04-01 00:00:00",tz="GMT")
stepEnd <- as.POSIXct("2024-06-01 00:00:00",tz="GMT") 
maxStep <- 0.1
for(i in 2:nrow(waq_down)){if((waq_down$startDateTime[i]>stepStart)&
                              (waq_down$endDateTime[i]<stepEnd)){
  if((!is.na(waq_down$localDissolvedOxygenSat[i]))&
     (!is.na(waq_down$localDissolvedOxygenSat[i-1]))){
    if(abs(waq_down$localDissolvedOxygenSat[i]-
       waq_down$localDissolvedOxygenSat[i-1])>maxStep){
          waq_down$cleanDissolvedOxygenSat[i] <- NA
          waq_down$cleanDissolvedOxygenSat[i-1] <- NA
      }}}}


## ----alternate_range--------------------------------------------------------------------------
rangeStart <- as.POSIXct("2024-04-01 00:00:00",tz="GMT")
rangeEnd <- as.POSIXct("2024-06-01 00:00:00",tz="GMT") 
minRange <- 80
maxRange <- 120
for(i in 1:nrow(waq_down)){
  if((waq_down$startDateTime[i]>rangeStart)&(waq_down$endDateTime[i]<rangeEnd)){
    if((!is.na(waq_down$localDissolvedOxygenSat[i]))){
      if((waq_down$localDissolvedOxygenSat[i]<minRange)|
         (waq_down$localDissolvedOxygenSat[i]>maxRange)){
            waq_down$cleanDissolvedOxygenSat[i] <- NA
            }}}}


## ----plot-do-qf-------------------------------------------------------------------------------
doPlotQF <- ggplot() +
	geom_line(data = waq_down,aes(startDateTime, localDissolvedOxygenSat, colour="raw"),na.rm=TRUE) +
  geom_line(data = waq_down,aes(startDateTime, cleanDissolvedOxygenSat, colour="clean"),na.rm=TRUE) +
  geom_ribbon(data=waq_down,aes(x=startDateTime, 
                  ymin = (cleanDissolvedOxygenSat - localDOSatExpUncert), 
                  ymax = (cleanDissolvedOxygenSat + localDOSatExpUncert)), 
                  alpha = 0.3, fill = "blue") +
  scale_colour_manual("",breaks=c("raw","clean"),values=c("red","blue")) +
	ylim(0, 120) + ylab("saturation (%)") + xlab("Date")+ ggtitle("WALK dissolvedOxygenSat with Uncertainty")
doPlotQF


## ----view-ais-cal-do--------------------------------------------------------------------------
doCleanCal<-ais_multisondeCleanCal[,c("startDate","s1PreCleaningDO",
                          "s2PreCleaningDO","s1PostCleaningDO",
                          "s2PostCleaningDO","s1DOCalSuccessful",
                          "s2DOCalSuccessful","s1BucketDO",
                          "s2BucketDO")]
doCleanCal %>%
  kbl() %>%
    kable_styling()


## ----correct-do-drift-------------------------------------------------------------------------
driftStart <- as.POSIXct("2024-04-29 17:00:00",tz="GMT")
driftEnd <- as.POSIXct("2024-05-13 15:00:00",tz="GMT") 
drift <- 106.1-95.5
  for(i in 1:nrow(waq_down)){
    if(waq_down$startDateTime[i]>driftStart&
       waq_down$startDateTime[i]<driftEnd){
        waq_down$cleanDissolvedOxygenSat[i] <- 
          waq_down$cleanDissolvedOxygenSat[i]-
          (drift*(as.numeric(difftime(waq_down$startDateTime[i],
                          driftStart,units="secs"))/
                    as.numeric(difftime(driftEnd,
                          driftStart,units="secs"))))
        }}


## ----plot-do-drift-corrected------------------------------------------------------------------
doPlotDrift <- ggplot() +
	geom_line(data = waq_down,aes(startDateTime, localDissolvedOxygenSat, colour="raw"),na.rm=TRUE) +
  geom_line(data = waq_down,aes(startDateTime, cleanDissolvedOxygenSat, colour="clean"),na.rm=TRUE) +
  geom_ribbon(data=waq_down,aes(x=startDateTime, 
                  ymin = (cleanDissolvedOxygenSat - localDOSatExpUncert), 
                  ymax = (cleanDissolvedOxygenSat + localDOSatExpUncert)), 
                  alpha = 0.3, fill = "blue") +
  scale_colour_manual("",breaks=c("raw","clean"),values=c("red","blue")) +
	ylim(90, 110) + ylab("saturation (%)") + xlab("Date")+ ggtitle("WALK dissolvedOxygenSat with Uncertainty")
doPlotDrift


## ----do-gap_fill------------------------------------------------------------------------------
waq_down$cleanDissolvedOxygenSat<-
  zoo::na.approx(waq_down$cleanDissolvedOxygenSat,maxgap=300)


## ----plot-do-gap-filled-----------------------------------------------------------------------
doPlotFilled <- ggplot() +
	geom_line(data = waq_down,aes(startDateTime, localDissolvedOxygenSat, colour="raw"),na.rm=TRUE) +
  geom_line(data = waq_down,aes(startDateTime, cleanDissolvedOxygenSat, colour="clean"),na.rm=TRUE) +
  geom_ribbon(data=waq_down,aes(x=startDateTime, 
                  ymin = (cleanDissolvedOxygenSat - localDOSatExpUncert), 
                  ymax = (cleanDissolvedOxygenSat + localDOSatExpUncert)), 
                  alpha = 0.3, fill = "blue") +
  scale_colour_manual("",breaks=c("raw","clean"),values=c("red","blue")) +
	ylim(90, 110) + ylab("saturation (%)") + xlab("Date")+ ggtitle("WALK dissolvedOxygenSat with Uncertainty")
doPlotFilled


## ----download-data-nsw, results='hide', warning=FALSE-----------------------------------------
nsw <- neonUtilities::loadByProduct(dpID="DP1.20033.001", site="WALK", 
                     startdate="2024-01", enddate="2024-02",
                     package="expanded", release="current",
                     include.provisional=T,
                     check.size=F)
list2env(nsw,.GlobalEnv)


## ----check-nsw-horizontalPosition-------------------------------------------------------------
print(unique(NSW_15_minute$horizontalPosition))


## ----plot-nsw-raw-----------------------------------------------------------------------------
nswPlotRaw <- ggplot() +
	geom_line(data = NSW_15_minute,aes(startDateTime, surfWaterNitrateMean, colour="raw"),na.rm=TRUE) +
  geom_ribbon(data=NSW_15_minute,aes(x=startDateTime, 
                  ymin = (surfWaterNitrateMean - surfWaterNitrateExpUncert), 
                  ymax = (surfWaterNitrateMean + surfWaterNitrateExpUncert)), 
                  alpha = 0.3, fill = "red") +
  scale_colour_manual("",breaks=c("raw"),values=c("red")) +
	ylim(-2, 12) + ylab("concentration (uM)") + xlab("Date")+ ggtitle("WALK surfWaterNitrateMean with Uncertainty")
nswPlotRaw


## ----filter-nsw-issue-log---------------------------------------------------------------------
issueLog_20033<-issueLog_20033[(grepl(unique(NSW_15_minute$siteID),
                                      issueLog_20033$locationAffected))]
issueLog_20033<-issueLog_20033[!((issueLog_20033$dateRangeStart>
                                    max(NSW_15_minute$startDateTime))
              |(issueLog_20033$dateRangeEnd<
                  min(NSW_15_minute$startDateTime))),]
issueLog_20033 %>%
  kbl() %>%
    kable_styling()


## ----populate-nsw-clean-----------------------------------------------------------------------
NSW_15_minute$cleanSurfWaterNitrate<-NSW_15_minute$surfWaterNitrateMean
NSW_15_minute$cleanSurfWaterNitrate[NSW_15_minute$finalQF == 1] <- NA


## ----plot-nsw-qf------------------------------------------------------------------------------
nswPlotQF <- ggplot() +
	geom_line(data = NSW_15_minute,aes(startDateTime, surfWaterNitrateMean, colour="raw"),na.rm=TRUE) +
  geom_line(data = NSW_15_minute,aes(startDateTime, cleanSurfWaterNitrate, colour="clean"),na.rm=TRUE) +
  geom_ribbon(data=NSW_15_minute,aes(x=startDateTime, 
                  ymin = (cleanSurfWaterNitrate - surfWaterNitrateExpUncert), 
                  ymax = (cleanSurfWaterNitrate + surfWaterNitrateExpUncert)), 
                  alpha = 0.3, fill = "blue") +
  scale_colour_manual("",breaks=c("raw","clean"),values=c("red","blue")) +
	ylim(-2, 12) + ylab("concentration (uM)") + xlab("Date")+ ggtitle("WALK surfWaterNitrateMean with Uncertainty")
nswPlotQF


## ----view-ais-cal-nsw-------------------------------------------------------------------------
nswCleanCal<-ais_sunaCleanAndCal[,c("collectDate","preCleanNitrateBlankConc",
                          "postCleanNitrateBlankConc","postCalNitrateBlankConc")]
nswCleanCal %>%
  kbl() %>%
    kable_styling()


## ----correct-nsw-shift------------------------------------------------------------------------
shiftStart <- as.POSIXct("2024-01-11 20:00:00",tz="GMT")
shiftEnd <- as.POSIXct("2024-02-05 16:00:00",tz="GMT") 
offset <- 1.1
gain <- 1
  for(i in 1:nrow(NSW_15_minute)){
    if(NSW_15_minute$startDateTime[i]>shiftStart&NSW_15_minute$startDateTime[i]<shiftEnd){
      NSW_15_minute$cleanSurfWaterNitrate[i] <- 
        NSW_15_minute$cleanSurfWaterNitrate[i]*gain+offset}}


## ----plot-nsw-shift---------------------------------------------------------------------------
nswPlotShift <- ggplot() +
	geom_line(data = NSW_15_minute,aes(startDateTime, surfWaterNitrateMean, colour="raw"),na.rm=TRUE) +
  geom_line(data = NSW_15_minute,aes(startDateTime, cleanSurfWaterNitrate, colour="clean"),na.rm=TRUE) +
  geom_ribbon(data=NSW_15_minute,aes(x=startDateTime, 
                  ymin = (cleanSurfWaterNitrate - surfWaterNitrateExpUncert), 
                  ymax = (cleanSurfWaterNitrate + surfWaterNitrateExpUncert)), 
                  alpha = 0.3, fill = "blue") +
  scale_colour_manual("",breaks=c("raw","clean"),values=c("red","blue")) +
	ylim(-2, 12) + ylab("concentration (uM)") + xlab("Date")+ ggtitle("WALK surfWaterNitrateMean with Uncertainty")
nswPlotShift

