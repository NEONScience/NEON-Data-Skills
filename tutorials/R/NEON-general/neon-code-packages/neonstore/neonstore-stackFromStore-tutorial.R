## ----setup, eval=c(7,8), results="hide"------------------------------------------------------------------

# install packages. can skip this step if already installed
install.packages("neonstore")
install.packages("neonUtilities")

# load packages
library(neonstore)
library(neonUtilities)



## ----check-dir, results="hide"---------------------------------------------------------------------------

neon_dir()



## ----download, results="hide", message=FALSE-------------------------------------------------------------

neon_download(product="DP4.00200.001", 
              start_date="2019-01-01",
              end_date="2020-01-01",
              type="basic",
              site=c("TOOL","WREF","GUAN"))

neon_download(product="DP1.00002.001", 
              start_date="2019-01-01",
              end_date="2020-01-01",
              type="basic",
              site=c("TOOL","WREF","GUAN"))

neon_download(product="DP1.10058.001", 
              start_date="2019-01-01",
              end_date="2021-01-01",
              type="expanded",
              site=c("TOOL","WREF","GUAN"))



## ----download-again, results="hide", message=FALSE-------------------------------------------------------

neon_download(product="DP1.10058.001", 
              start_date="2019-01-01",
              end_date="2020-01-01",
              type="expanded",
              site=c("TOOL","WREF","GUAN"))



## ----stack-T, results="hide"-----------------------------------------------------------------------------

temp <- stackFromStore(filepaths=neon_dir(),
                       dpID="DP1.00002.001", 
                       startdate="2019-03",
                       enddate="2019-04",
                       package="basic",
                       site=c("TOOL","WREF"))



## ----stack-div, results="hide", warning=FALSE------------------------------------------------------------

pppc <- stackFromStore(filepaths=neon_dir(),
                       dpID="DP1.10058.001", 
                       pubdate="2021-01-01",
                       package="expanded")



## ----which-div-------------------------------------------------------------------------------------------

unique(pppc$div_1m2Data$siteID)
min(pppc$div_1m2Data$endDate)
max(pppc$div_1m2Data$endDate)



## ----stack-sae, results="hide"---------------------------------------------------------------------------

flux <- stackFromStore(filepaths=neon_dir(), 
                       dpID="DP4.00200.001", 
                       site="WREF",
                       startdate="2019-04",
                       enddate="2019-05",
                       package="basic", 
                       level="dp04")


