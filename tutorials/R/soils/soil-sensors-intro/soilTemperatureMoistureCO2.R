## ----install_packages, eval=FALSE------------------------------------------------------------------------
## 
## install.packages("neonUtilities")
## 


## ----load-packages, results="hide"-----------------------------------------------------------------------

library(neonUtilities)



## ----soildata, results="hide"----------------------------------------------------------------------------

st <- loadByProduct(dpID="DP1.00041.001",
                    startdate="2021-01",
                    enddate="2021-12", 
                    site="CPER", 
                    package="basic", 
                    timeIndex="30",
                    check.size=F)

swc <- loadByProduct(dpID="DP1.00094.001", 
                     startdate="2021-01", 
                     enddate="2021-12", 
                     site="CPER", 
                     package="basic", 
                     timeIndex="30", 
                     check.size=F)

co2 <- loadByProduct(dpID="DP1.00095.001", 
                     startdate="2021-01", 
                     enddate="2021-12", 
                     site="CPER", 
                     package="basic", 
                     timeIndex="30", 
                     check.size=F)



## ----temp-rows-------------------------------------------------------------------------------------------

p1rowsT <- grep("001", st$ST_30_minute$horizontalPosition)
d2rowsT <- grep("502", st$ST_30_minute$verticalPosition)
goodRowsT <- which(st$ST_30_minute$finalQF == 0)
useTheseT <- intersect(intersect(p1rowsT, d2rowsT), goodRowsT)



## ----temp-depth------------------------------------------------------------------------------------------

head(st$sensor_positions_00041)



## ----temp-depth-2----------------------------------------------------------------------------------------

st$sensor_positions_00041[grep("001.502", st$sensor_positions_00041$HOR.VER), "zOffset"]



## ----temp-depth-3----------------------------------------------------------------------------------------

st$sensor_positions_00041[grep("001.502", st$sensor_positions_00041$HOR.VER), 
                             c("positionStartDateTime", "positionEndDateTime", "zOffset")]



## ----temp-plot-------------------------------------------------------------------------------------------

plot(st$ST_30_minute$startDateTime[useTheseT], 
     st$ST_30_minute$soilTempMean[useTheseT], 
     pch=".", 
     xlab="", 
     ylab="Soil temperature (°C)", 
     main="CPER soil plot 1, 2021")
legend("topleft", legend="6 cm", lty=1, bty="n")



## ----swc-row---------------------------------------------------------------------------------------------

p1rowsM <- grep("001", swc$SWS_30_minute$horizontalPosition)
d1rowsM <- grep("501", swc$SWS_30_minute$verticalPosition)
goodRowsM <- which(swc$SWS_30_minute$VSWCFinalQF == 0)
useTheseM <- intersect(intersect(p1rowsM, d1rowsM), goodRowsM)



## ----swc-plot--------------------------------------------------------------------------------------------

labelM=expression(paste("Soil water content (m"^" 3", " m"^"-3", ")"))
plot(swc$SWS_30_minute$startDateTime[useTheseM], 
     swc$SWS_30_minute$VSWCMean[useTheseM], 
     pch=".", 
     xlab="", 
     ylab=labelM)
legend("topleft", legend="6 cm", lty=1, bty="n")



## ----swc-plot-2------------------------------------------------------------------------------------------

par(mar=c(3,5,2,1))
plot(swc$SWS_30_minute$startDateTime[useTheseM], 
     swc$SWS_30_minute$VSWCMean[useTheseM], 
     pch=".", 
     xlab="", 
     ylab=labelM)
legend("topleft", legend="6 cm", lty=1, bty="n")



## ----co2-rows--------------------------------------------------------------------------------------------

# Identify rows for soil plot 1
p1rowsC <- grep("001", co2$SCO2C_30_minute$horizontalPosition)

# Identify rows for measurement levels 1, 2, and 3
d1rowsC <- grep("501", co2$SCO2C_30_minute$verticalPosition)
d2rowsC <- grep("502", co2$SCO2C_30_minute$verticalPosition)
d3rowsC <- grep("503", co2$SCO2C_30_minute$verticalPosition)

# Identify rows that passed the QA/QC tests
goodRowsC <- which(co2$SCO2C_30_minute$finalQF == 0)

# Identify rows for soil plot 1 that passed the QA/QC tests for each measurement level
useTheseC1 <- intersect(intersect(p1rowsC, d1rowsC), goodRowsC)
useTheseC2 <- intersect(intersect(p1rowsC, d2rowsC), goodRowsC)
useTheseC3 <- intersect(intersect(p1rowsC, d3rowsC), goodRowsC)



## ----co2-depths------------------------------------------------------------------------------------------

rows <- grep(c("001"), co2$sensor_positions_00095$HOR.VER)
co2$sensor_positions_00095[rows, c("positionStartDateTime", "positionEndDateTime", "zOffset")]



## ----co2-plot--------------------------------------------------------------------------------------------

labelC=expression(paste("Soil CO"[2]," concentration (ppm)"))
plot(co2$SCO2C_30_minute$startDateTime[useTheseC1], 
     co2$SCO2C_30_minute$soilCO2concentrationMean[useTheseC1], 
     pch=".", 
     xlab="", 
     ylab=labelC, 
     ylim=c(0, 5000))
points(co2$SCO2C_30_minute$startDateTime[useTheseC2], 
       co2$SCO2C_30_minute$soilCO2concentrationMean[useTheseC2], 
       pch=".", 
       col="red")
points(co2$SCO2C_30_minute$startDateTime[useTheseC3], 
       co2$SCO2C_30_minute$soilCO2concentrationMean[useTheseC3], 
       pch=".", 
       col="blue")
legend("topleft", legend=c("2 cm", "6 cm", "10 cm"), lty=1, col=c("black", "red", "blue"), bty="n")



## ----combined-plot---------------------------------------------------------------------------------------

par(mfcol=c(3,1))
par(mar=c(3,5,2,1))

# Add soil temperature plot
plot(st$ST_30_minute$startDateTime[useTheseT], 
     st$ST_30_minute$soilTempMean[useTheseT], 
     pch=".", 
     xlab="", 
     ylab="Soil temperature (°C)", 
     main="CPER soil plot 1, 2021")
legend("topleft", legend="6 cm", lty=1, bty="n")

# Add soil water content plot
plot(swc$SWS_30_minute$startDateTime[useTheseM], 
     swc$SWS_30_minute$VSWCMean[useTheseM], 
     pch=".", 
     xlab="", 
     ylab=labelM)
legend("topleft", legend="6 cm", lty=1, bty="n")

# Add soil CO2 concentration plot
plot(co2$SCO2C_30_minute$startDateTime[useTheseC1], 
     co2$SCO2C_30_minute$soilCO2concentrationMean[useTheseC1], 
     pch=".", 
     xlab="", 
     ylab=labelC, 
     ylim=c(0, 5000))
points(co2$SCO2C_30_minute$startDateTime[useTheseC2], 
       co2$SCO2C_30_minute$soilCO2concentrationMean[useTheseC2], 
       pch=".", 
       col="red")
points(co2$SCO2C_30_minute$startDateTime[useTheseC3], 
       co2$SCO2C_30_minute$soilCO2concentrationMean[useTheseC3], 
       pch=".", 
       col="blue")
legend("topleft", legend=c("2 cm", "6 cm", "10 cm"), lty=1, col=c("black", "red", "blue"), bty="n")


