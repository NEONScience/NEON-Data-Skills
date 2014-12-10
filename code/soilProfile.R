# load required packages, you may have to install these if missing:
# install.packages('aqp', dep=TRUE)
library("aqp")
#install.packages("aqp", type="source")
#the HMISC libaries are required to run this. install this first.
library(Hmisc)
library(lattice)
library(MASS)

# load sample data set, a data.frame object with horizon-level data from 10 profiles
data(sp4)
str(sp4)

# upgrade to SoilProfileCollection
# 'id' is the name of the column containing the profile ID
# 'top' is the name of the column containing horizon upper boundaries
# 'bottom' is the name of the column containing horizon lower boundaries
depths(sp4) <- id ~ top + bottom

# check it out:
class(sp4) # class name
