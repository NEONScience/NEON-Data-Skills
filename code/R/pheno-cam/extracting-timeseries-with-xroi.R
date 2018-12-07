## ----install-CRAN, echo=TRUE, eval=FALSE---------------------------------
#> 
#> utils::install.packages('xROI', repos = "http://cran.us.r-project.org" )
#> 

## ----install-GitHub, echo=TRUE, eval=FALSE-------------------------------
#> 
#> # install devtools first
#> utils::install.packages('devtools', repos = "http://cran.us.r-project.org" )
#> 
#> # use devtools to install from GitHub
#> devtools::install_github("bnasr/xROI")
#> 

## ----launch-r, echo=TRUE, eval=FALSE-------------------------------------
#> # load xROI
#> library(xROI)
#> 
#> # launch xROI
#> Launch()
#> 

## 
## ----launch-xroi, echo=TRUE, eval=FALSE----------------------------------
#> 
#> # launch data in ROI
#> # first edit the path below to the dowloaded directory you just extracted
#> xROI::Launch('/path/to/extracted/directory')
#> 
#> # alternatively, you can run without specifying a path and use the interface to browse
#> 

