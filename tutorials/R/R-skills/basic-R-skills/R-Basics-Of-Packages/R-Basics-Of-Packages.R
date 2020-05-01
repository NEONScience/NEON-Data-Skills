## ----install-packages, eval=FALSE-----------------------------
## # install the ggplot2 package
## install.packages("ggplot2")


## ----load-package---------------------------------------------
# load the package
library(ggplot2)


## ----installed-packages, eval=FALSE---------------------------
## 
## # check installed packages
## installed.packages()


## ----update-packages, eval=FALSE------------------------------
## 
## # list all packages where an update is available
## old.packages()
## 
## # update all available packages
## update.packages()
## 
## # update, without prompts for permission/clarification
## update.packages(ask = FALSE)
## 
## # update only a specific package use install.packages()
## install.packages("plotly")
## 


## ----challenge-code-kelv-to-cels, include=TRUE, results="hide", echo=FALSE----

# check installed packages for dplyr
installed.packages()

# If found, is it up to date? 
old.packages()

# If not found, install it. 
install.packages("dplyr")


