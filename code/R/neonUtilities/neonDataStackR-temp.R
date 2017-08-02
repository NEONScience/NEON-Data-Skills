## ----loadStuff-----------------------------------------------------------

library(devtools)
install_github("NEONScience/NEON-utilities/neonDataStackR", dependencies=TRUE)
library (neonDataStackR)


## ----run-function, eval = FALSE------------------------------------------
## stackByTable("data/NEON_temp-air-single.zip")
## 

## ----sample-output, eval=FALSE-------------------------------------------
## 
## Unpacked  2016-02-SERC-DP1.00002.001-basic-20160708035158.zip
## Unpacked  2016-03-SERC-DP1.00002.001-basic-20160708035642.zip
## Joining, by = c("domainID", "siteID", "horizontalPosition", "verticalPosition", "startDateTime", "endDateTime", "tempSingleMean", "tempSingleMinimum", "tempSingleMaximum", "tempSingleVariance", "tempSingleNumPts", "tempSingleExpUncert", "tempSingleStdErMean", "finalQF")
## Joining, by = c("domainID", "siteID", "horizontalPosition", "verticalPosition", "startDateTime", "endDateTime", "tempSingleMean", "tempSingleMinimum", "tempSingleMaximum", "tempSingleVariance", "tempSingleNumPts", "tempSingleExpUncert", "tempSingleStdErMean", "finalQF")
## Stacked  SAAT_1min
## Joining, by = c("domainID", "siteID", "horizontalPosition", "verticalPosition", "startDateTime", "endDateTime", "tempSingleMean", "tempSingleMinimum", "tempSingleMaximum", "tempSingleVariance", "tempSingleNumPts", "tempSingleExpUncert", "tempSingleStdErMean", "finalQF")
## Joining, by = c("domainID", "siteID", "horizontalPosition", "verticalPosition", "startDateTime", "endDateTime", "tempSingleMean", "tempSingleMinimum", "tempSingleMaximum", "tempSingleVariance", "tempSingleNumPts", "tempSingleExpUncert", "tempSingleStdErMean", "finalQF")
## Stacked  SAAT_30min
## Finished: All of the data are stacked into  2  tables!
## 

