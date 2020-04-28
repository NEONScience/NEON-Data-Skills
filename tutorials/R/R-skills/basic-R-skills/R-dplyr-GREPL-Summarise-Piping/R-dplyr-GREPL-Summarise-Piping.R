## ----example-nested-functions, eval=FALSE---------------------------------------------------------------------------------
##   function3(function2(function1(my_data)))


## ----example-piped-functions, eval=FALSE----------------------------------------------------------------------------------
##   my_data %>%
##     function1() %>%
##       function2() %>%
##         function3()


## ----example-mammal-data, eval=FALSE--------------------------------------------------------------------------------------
## 	myMammalData %>%                            # start with a data frame
## 		filter(sex=='M') %>%                      # first filter for rows where sex is male
## 			summarise (mean_weight = mean(weight))  # find the mean of the weight column, store as mean_weight


## ----load-dplyr-library-import-data, eval=FALSE, comment=NA---------------------------------------------------------------

# load packages
library(dplyr)
library(neonUtilities)

# load the NEON small mammal capture data
# NOTE: the check.size = TRUE argument means the function 
# will require confirmation from you that you want to load 
# the quantity of data requested
loadData <- loadByProduct(dpID="DP1.10072.001", site = "HARV", 
                 startdate = "2014-01", enddate = "2014-12", 
                 check.size = TRUE) # Console requires your response!

# if you'd like, check out the data
str(loadData)

## ----load-dplyr-library-import-data-hidden, include=FALSE-----------------------------------------------------------------

library(dplyr)
library(neonUtilities)

# load the NEON small mammal capture data
loadData <- loadByProduct(dpID="DP1.10072.001", site = "HARV", 
                 startdate = "2014-01", enddate = "2014-12", 
                 check.size = F) # set to F in hidden code chunk
                                 # to allow knitting to process correctly



## ----extract-pertrapnight-------------------------------------------------------------------------------------------------

myData <- loadData$mam_pertrapnight

class(myData) # Confirm that 'myData' is a data.frame



## ----dplyr-filter-function------------------------------------------------------------------------------------------------

# filter on `scientificName` is Peromyscus maniculatus and `sex` is female. 
# two equals signs (==) signifies "is"
data_PeroManicFemales <- filter(myData, 
                   scientificName == 'Peromyscus maniculatus', 
                   sex == 'F')

# Note how we were able to put multiple conditions into the filter statement,
# pretty cool!



## ----dplyr-filter-print---------------------------------------------------------------------------------------------------
# how many female P. maniculatus are in the dataset
# would could simply count the number of rows in the new dataset
nrow(data_PeroManicFemales)

# or we could write is as a sentence
print(paste('In 2014, NEON technicians captured',
                   nrow(data_PeroManicFemales),
                   'female Peromyscus maniculatus at Harvard Forest.',
                   sep = ' '))


## ----dplyr-filter-function-uncertainty------------------------------------------------------------------------------------

# filter on `scientificName` is Peromyscus maniculatus and `sex` is female. 
# two equals signs (==) signifies "is"
data_PeroManicFemalesCertain <- filter(myData, 
                   scientificName == 'Peromyscus maniculatus', 
                   sex == 'F',
                   identificationQualifier =="NA")

# Count the number of un-ambiguous identifications
nrow(data_PeroManicFemalesCertain)



## ----using grepl with the dplyr filter function---------------------------------------------------------------------------

# combine filter & grepl to get all Peromyscus (a part of the 
# scientificName string)
data_PeroFemales <- filter(myData,
                   grepl('Peromyscus', scientificName),
                   sex == 'F')

# how many female Peromyscus are in the dataset
print(paste('In 2014, NEON technicians captured',
                   nrow(data_PeroFemales),
                   'female Peromyscus spp. at Harvard Forest.',
                   sep = ' '))



## ----dplyr-group_by-summarise---------------------------------------------------------------------------------------------
# how many of each species & sex were there?
# step 1: group by species & sex
dataBySpSex <- group_by(myData, scientificName, sex)

# step 2: summarize the number of individuals of each using the new df
countsBySpSex <- summarise(dataBySpSex, n_individuals = n())

# view the data (just top 10 rows)
head(countsBySpSex, 10)



## ----compare-classes------------------------------------------------------------------------------------------------------

# View class of 'myData' object
class(myData)

# View class of 'dataBySpSex' object
class(dataBySpSex)


## ----compare-classes-2, eval=FALSE, comment=NA----------------------------------------------------------------------------
# View help file for group_by() function
?group_by()



## ----dplyr-piping-combine-functions---------------------------------------------------------------------------------------

# combine several functions to get a summary of the numbers of individuals of 
# female Peromyscus species in our dataset.
# remember %>% are "pipes" that allow us to pass information from one function 
# to the next. 

dataBySpFem <- myData %>%
                 filter(grepl('Peromyscus', scientificName), sex == "F") %>%
                   group_by(scientificName) %>%
                      summarise(n_individuals = n())

# view the data
dataBySpFem



## ----same-but-base-r------------------------------------------------------------------------------------------------------
# For reference, the same output but using R's base functions

# First, subset the data to only female Peromyscus
dataFemPero  <- myData[myData$sex=='F' & 
                   grepl('Peromyscus',myData$scientificName),]

# Option 1 --------------------------------
# Use aggregate and then rename columns
dataBySpFem_agg <-aggregate(dataFemPero$sex ~ dataFemPero$scientificName, 
                   data = dataFemPero, FUN = length)
names(dataBySpFem_agg) <- c('scientificName','n_individuals')

# view output
dataBySpFem_agg

# Option 2 --------------------------------------------------------
# Do it by hand

# Get the unique scientificNames in the subset
sppInDF <- unique(dataFemPero$scientificName[!is.na(dataFemPero$scientificName)])

# Use a loop to calculate the numbers of individuals of each species
sciName <- vector(); numInd <- vector()
for (i in sppInDF){
  sciName <- c(sciName, i)
  numInd <- c(numInd, length(which(dataFemPero$scientificName==i)))
}

#Create the desired output data frame
dataBySpFem_byHand <- data.frame('scientificName'=sciName, 
                   'n_individuals'=numInd)

# view output
dataBySpFem_byHand


