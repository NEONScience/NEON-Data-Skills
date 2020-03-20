## ----load-dplyr-library-import-data-------------------------------------------------------

# install dplyr library -- only if it isn't already installed
#install.packages('dplyr')

# load library
library(dplyr)

# set working directory to the location of the NEON mammal data downloaded
# via the link above.
#setwd('insert path to data files here')

# read in the NEON small mammal capture data
myData <- read.csv('NEON.D01.HARV.DP1.10072.001.mam_capturedata.csv', 
                   header = T, 
                   stringsAsFactors = FALSE, strip.white = TRUE, 
                   na.strings = '')

# if you'd like, check out the data
#str(myData)


## ----dplyr-filter-function----------------------------------------------------------------

# filter on `scientificName` is Peromyscus maniculatus and `sex` is female. 
# two equals signs (==) signifies "is"
data_PeroManicFemales <- filter(myData, 
                   scientificName == 'Peromyscus maniculatus', 
                   sex == 'F')

# Note how we were able to put multiple conditions into the filter statement,
# pretty cool!



## ----dplyr-filter-print-------------------------------------------------------------------
# how many female P. maniculatus are in the dataset
# would could simply count the number of rows in the new dataset
nrow(data_PeroManicFemales)

# or we could write is as a sentence
print(paste('In 2014, NEON technicians captured',
                   nrow(data_PeroManicFemales),
                   'female Peromyscus maniculatus at Harvard Forest.',
                   sep = ' '))


## ----using grepl with the dplyr filter function-------------------------------------------

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



## ----dplyr group_by & summarise-----------------------------------------------------------
# how many of each species & sex were there?
# step 1: group by species & sex
dataBySpSex <- group_by(myData, scientificName, sex)

# step 2: summarize the number of individuals of each using the new df
countsBySpSex <- summarise(dataBySpSex, n_individuals = n())

# view the data (just top 10 rows)
head(countsBySpSex, 10)

# hmm, it looks like on data entry some females were recorded as `F` and some 
# as `f`.  R is interpreting these as different "sexes". We would need to 
# remember this if we want to filter all females or go back and clean the 
# the original data.



## ----dplyr-piping-combine-functions-------------------------------------------------------

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



## ----same-but-base-r----------------------------------------------------------------------
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
  sciName <- c(sciName,i)
  numInd <- c(numInd, length(which(dataFemPero$scientificName==i)))
}

#Create the desired output data frame
dataBySpFem_byHand <- data.frame('scientificName'=sciName, 
                   'n_individuals'=numInd)

# view output
dataBySpFem_byHand


