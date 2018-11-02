## ---- echo=TRUE, eval=FALSE----------------------------------------------
## 
## utils::install.packages('xROI', repos = "http://cran.us.r-project.org" )
## 

## ---- echo=TRUE, eval=FALSE----------------------------------------------
## 
## # install devtools first
## utils::install.packages('devtools', repos = "http://cran.us.r-project.org" )
## 
## devtools::install_github("bnasr/xROI")
## 

## ---- echo=TRUE, eval=FALSE----------------------------------------------
## 
## library(xROI)
## Launch()
## 

## ---- echo=TRUE, eval=FALSE----------------------------------------------
## 
## Rscript -e “xROI::Launch(Interactive = TRUE)”
## 

## ---- echo=TRUE, eval=FALSE----------------------------------------------
## 
## xROI::Launch('/path/to/extracted/directory/)
## 

