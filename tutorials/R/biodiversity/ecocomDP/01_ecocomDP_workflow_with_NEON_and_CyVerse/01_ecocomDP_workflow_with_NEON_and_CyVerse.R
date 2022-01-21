## ----load libraries, eval=F, comment=NA------------------------------------------------------------

# clean out workspace

#rm(list = ls()) # OPTIONAL - clear out your environment
#gc()            # Uncomment these lines if desired

# load packages
library(tidyverse)
library(neonUtilities)
library(ecocomDP)

# source .r file with my NEON_TOKEN
# source("my_neon_token.R") # OPTIONAL - load NEON token
# See: https://www.neonscience.org/neon-api-tokens-tutorial





## ----download-macroinvert, message=FALSE, warning=FALSE, results='hide'----------------------------

# search for invertebrate data products
my_search_result <- ecocomDP::search_data(text = "invertebrate")
View(my_search_result)

# pull data for the NEON aquatic "Macroinvertebrate
# collection" from ARIK collected during 2017 and 2018
my_data <- ecocomDP::read_data(
  id = "neon.ecocomdp.20120.001.001",
  site = "ARIK",
  startdate = "2017-01",
  enddate = "2018-12",
  # token = NEON_TOKEN, #Uncomment to use your token
  check.size = FALSE)



## ----view-ecocomDP-str-----------------------------------------------------------------------------

# examine the structure of the data object that is returned
my_data %>% names()

# the data package id
my_data$id

# short list of package summary data
my_data$metadata$data_package_info

# validation issues? None if returns an empty list
my_data$validation_issues

# examine the tables
my_data$tables %>% names()
my_data$tables$taxon %>% head()
my_data$tables$observation %>% head()



## ----macroinvert-datavis-space-time, message=FALSE, warning=FALSE, fig.cap="Sampling events in space and time represented in the downloaded data set for benthic macroinvertebrate counts from the Arikaree River site."----

# Explore the spatial and temporal coverage 
# of the dataset
my_data %>% ecocomDP::plot_sample_space_time()



## ----macroinvert-datavis-ranks, message=FALSE, warning=FALSE, fig.cap="Frequencies of different taxonomic ranks in benthic macroinvertebrate counts from the Arikaree River site."----

# Explore the taxonomic resolution in the dataset. 
# What is the most common taxonomic resolution (rank) 
# for macroinvertebrate identifications in this dataset?
my_data %>% ecocomDP::plot_taxa_rank()



## ----search-ecocomDP-------------------------------------------------------------------------------

# search for data sets with periphyton or algae
# regex works!
my_search_result <- ecocomDP::search_data(text = "periphyt|algae")
View(my_search_result)



## ----download-algae-data, message=FALSE, warning=FALSE, results='hide'-----------------------------

# pull data for the NEON "Periphyton, seston, and phytoplankton collection" 
# data product (expect the download to take 1-2 mins)
my_data <- ecocomDP::read_data(
  id = "neon.ecocomdp.20166.001.001", 
  site = c("ARIK","COMO"),
  startdate = "2017-01",
  enddate = "2020-12",
  # token = NEON_TOKEN, #Uncomment to use your token
  check.size = FALSE)



## ----explore-algae-data-structure------------------------------------------------------------------
# Explore the structure of the returned data object
my_data %>% names()
my_data$id
my_data$metadata$data_package_info
my_data$validation_issues
my_data$tables %>% names()

my_data$tables$location
my_data$tables$taxon %>% head()
my_data$tables$observation %>% head()



## ----flattening-and-cleaning, message=FALSE, warning=FALSE-----------------------------------------

# flatten the ecocomDP data tables into one flat table
my_data_flat <- my_data %>% ecocomDP::flatten_data()

# This data product has algal densities reported for both
# lakes and streams, so densities could be standardized
# either to volume collected or area sampled. 

# Verify that only benthic algae standardized to area 
# are returned in this data pull:
my_data_flat$unit %>%
    unique()



# filter the data to only records standardized to area
# sampled
my_data_benthic <- my_data_flat %>%
  dplyr::filter(unit == "cells/cm2")


## ----algae-data-vis-space-time, message=FALSE, warning=FALSE, fig.cap="Sampling events in space in time represented in the downloaded data set for algae."----

# Note that you can send flattened data 
# to the ecocomDP plotting functions
my_data_benthic %>% ecocomDP::plot_sample_space_time()



## ----algae-data-vis-richness-time, message=FALSE, warning=FALSE, fig.cap="Benthic algal richness by year at ARIK and COMO"----

# Note that you can also send flattened data 
# to the ecocomDP plotting functions
my_data_benthic %>% ecocomDP::plot_taxa_diversity(time_window_size = "year")


