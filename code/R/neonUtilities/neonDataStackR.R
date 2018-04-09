## ----loadStuff-----------------------------------------------------------
# install devtools - can skip if already installed
install.packages("devtools")

# load devtools
library(devtools)

# install neonUtilities from GitHub
install_github("NEONScience/NEON-utilities/neonUtilities", dependencies=TRUE)

# load neonUtilities
library (neonUtilities)


## ----run-function, eval = FALSE------------------------------------------
## # stack files - Mac OSX file path shown
## stackByTable("DP1.00002.001","~neon/Documents/data/NEON_temp-air-single.zip")
## 

## ----sample-output, eval=FALSE-------------------------------------------
## Unpacking zip files
##   |=========================================================================================| 100%
## Stacking table SAAT_1min
##   |=========================================================================================| 100%
## Stacking table SAAT_30min
##   |=========================================================================================| 100%
## Finished: All of the data are stacked into  2  tables!
## Copied the first available variable definition file to /stackedFiles and renamed as variables.csv
## Stacked SAAT_1min which has 424800 out of the expected 424800 rows (100%).
## Stacked SAAT_30min which has 14160 out of the expected 14160 rows (100%).
## Stacking took 6.233922 secs
## All unzipped monthly data folders have been removed.

