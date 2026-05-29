## ----install_packages, eval=FALSE-----------------------------------------------------------------------------------------
# 
# install.packages("neonUtilities")
# install.packages("dplyr")
# install.packages("ggplot2")
# install.packages("gridExtra")
# 


## ----load-packages, results="hide", message=FALSE, warning=FALSE----------------------------------------------------------

library(dplyr)
library(ggplot2)
library(gridExtra)
library(neonUtilities)
token <- Sys.getenv("NEON_TOKEN")



## ----soildata, results="hide", message=FALSE------------------------------------------------------------------------------

st <- loadByProduct(dpID="DP1.00041.001",
                    startdate="2021-01",
                    enddate="2021-12", 
                    site="SRER", 
                    package="basic", 
                    timeIndex="30",
                    check.size=F,
                    token=token)

swc <- loadByProduct(dpID="DP1.00094.001", 
                     startdate="2021-01", 
                     enddate="2021-12", 
                     site="SRER", 
                     package="basic", 
                     timeIndex="30", 
                     check.size=F,
                     token=token)

co2 <- loadByProduct(dpID="DP1.00095.001", 
                     startdate="2021-01", 
                     enddate="2021-12", 
                     site="SRER", 
                     package="basic", 
                     timeIndex="30", 
                     check.size=F,
                     token=token)



## ----temp-rows------------------------------------------------------------------------------------------------------------

soilTsub <- st$ST_30_minute |>
  filter(horizontalPosition=="001" & 
           verticalPosition=="502" & 
           finalQF==0)



## ----temp-depth-----------------------------------------------------------------------------------------------------------

head(st$sensor_positions_00041)



## ----temp-depth-2---------------------------------------------------------------------------------------------------------

st$sensor_positions_00041 |>
  filter(HOR.VER=="001.502") |>
  select(zOffset)



## ----temp-plot------------------------------------------------------------------------------------------------------------

ggT <- ggplot(soilTsub, aes(startDateTime,
                            soilTempMean)) +
  geom_point(shape=".") +
  xlab("") +
  ylab("Soil temperature (°C)")
ggT + ggtitle("SRER soil plot 1, 6cm depth, 2021")



## ----swc-row--------------------------------------------------------------------------------------------------------------

soilWsub <- swc$SWS_30_minute |>
  filter(horizontalPosition=="001" &
           verticalPosition=="501" &
           VSWCFinalQF==0)



## ----swc-plot-------------------------------------------------------------------------------------------------------------

labelM=expression(paste("Soil water content (m"^" 3", " m"^"-3", ")"))
ggW <- ggplot(soilWsub, aes(startDateTime,
                            VSWCMean)) +
  geom_point(shape=".") +
  xlab("") +
  ylab(labelM)
ggW + ggtitle("SRER soil plot 1, 6cm depth, 2021")



## ----co2-rows-------------------------------------------------------------------------------------------------------------

soilCO2sub <- co2$SCO2C_30_minute |>
  filter(horizontalPosition=="001" &
           finalQF==0)



## ----co2-depths-----------------------------------------------------------------------------------------------------------

co2$sensor_positions_00095 |>
  filter(grepl("001[.]", HOR.VER)) |>
  select(HOR.VER, zOffset)



## ----co2-plot-------------------------------------------------------------------------------------------------------------

soilCO2sub <- soilCO2sub |>
  mutate(depth = case_when(verticalPosition=="501" ~ "2 cm",
                           verticalPosition=="502" ~ "5 cm",
                           verticalPosition=="503" ~ "19 cm"))

ggC <- ggplot(soilCO2sub, aes(startDateTime, 
                             soilCO2concentrationMean)) +
  geom_point(shape=".", aes(color=depth)) +
  xlab("") +
  ylab("Mean soil CO2 concentration")
ggC



## ----combined-plot--------------------------------------------------------------------------------------------------------

grid.arrange(ggT, ggW, 
             ggC + theme(legend.position="none"), 
  nrow=3)


