## ----load-dplyr-library-import-data--------------------------------------

#install dplyr library
#install.packages('dplyr')

#load library
library('dplyr')

#setwd('insert path to data files here')
#download example data - NEON small mammal capture data from D01 Harvard Forest - a site located in the heart of the Lyme disease epidemic.
myData <- read.csv('NEON.D01.HARV.DP1.10072.001.mam_capturedata.csv', header = T, 
                       stringsAsFactors = FALSE, strip.white = TRUE, 
                       na.strings = '')


## ----dplyr filter function-----------------------------------------------

#for example, let's create a new data frame that contains only female Peromyscus mainculatus, 
# one of the key small mammal players in the life cycle of Lyme disease-causing bacterium.

data_PeroManicFemales <- filter(myData, scientificName == 'Peromyscus maniculatus', sex == 'F')

#Note that we were able to put multiple conditions into the filter statement, pretty cool!

#how many female P. maniculatus are in the dataset
print(paste('In 2014, NEON technicians captured', nrow(data_PeroManicFemales), 'female Peromyscus maniculatus at Harvard Forest.', sep = ' '))


## ----using grepl with the dplyr filter function--------------------------

#In reality, all species of Peromyscus are viable players in Lyme disease transmission, so we really should be looking at all species of Peromyscus. Since we don't have genera split out as a separate field, we have to search within the scientific name string for the genus -- this is a simple example of pattern matching - 

#we will use the dplyr function filter in combination with the base function grepl to accomplish this

data_PeroFemales <- filter(myData, grepl('Peromyscus', scientificName), sex == 'F')

#how many female Peromyscus are in the dataset
print(paste('In 2014, NEON technicians captured', nrow(data_PeroFemales), 'female Peromyscus spp. at Harvard Forest.', sep = ' '))


## ----dplyr group_by & summarise------------------------------------------

#Since the diversity of the entire small mammal community has been shown to impact disease dynamics among the key reservoir species, we really want to know more about the demographics of the whole community.

#We can quickly generate counts by species and sex in 2 lines of code, using group_by and summarise.

dataBySpSex <- group_by(myData, scientificName, sex)
#Note - the output does not look any different than the original data.frame, but the application of subsequent functions (e.g., summarise) to this new data frame will produce distinctly different results than if you tried the same operations on the original

countsBySpSex <- summarise(dataBySpSex, n_individuals = n())


## ----dplyr piping to combine functions-----------------------------------

#Let's combine several dplyr functions in order to get a summary of the numbers of individuals of female Peromyscus species in our dataset.

dataBySpFem <- myData %>%
                 filter(grepl('Peromyscus', scientificName), sex == 'F') %>%
                   group_by(scientificName) %>%
                      summarise(n_individuals = n())



#For reference, let's see what we would have needed to do for the same output but using R's base functions

#First, subset the data to only female Peromyscus
dataFemPero  <- myData[myData$sex=='F' & grepl('Peromyscus',myData$scientificName),]

#Option 1) Use aggregate and then rename columns--------------------------------
dataBySpFem_agg <-aggregate(dataFemPero$sex ~ dataFemPero$scientificName, data = dataFemPero, FUN = length)
names(dataBySpFem_agg) <- c('scientificName','n_individuals')

#Option 2) Do it by hand--------------------------------------------------------
#Get the unique scientificNames in the subset
sppInDF <- unique(dataFemPero$scientificName[!is.na(dataFemPero$scientificName)])

#Calculate the numbers of individuals of each species
sciName <- vector(); numInd <- vector()
for (i in sppInDF){
  sciName <- c(sciName,i)
  numInd <- c(numInd, length(which(dataFemPero$scientificName==i)))
}

#Create the desired output data frame
dataBySpFem_byHand <- data.frame('scientificName'=sciName, 'n_individuals'=numInd)


