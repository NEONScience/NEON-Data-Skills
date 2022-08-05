## ----load libraries, eval=F, comment=NA----------------------------------------------------------------------------
# clean out workspace

#rm(list = ls()) # OPTIONAL - clear out your environment
#gc()            # Uncomment these lines if desired

# load packages
library(tidyverse)
library(neonUtilities)
library(ecocomDP)




## ----create-Renviron, eval=F, comment=NA---------------------------------------------------------------------------
usethis::edit_r_environ()


## ----set-token, eval=F, comment=NA---------------------------------------------------------------------------------
NEON_TOKEN=PASTE YOUR TOKEN HERE


## ----read-Renviron, eval=F, comment=NA-----------------------------------------------------------------------------
readRenviron("../rstudio/work/home/YOUR CYVERSE USERNAME/.Renviron")


## ----download-data, message=FALSE, warning=FALSE, results='hide'---------------------------------------------------
# Download NEON aquatic macroinvertebrate data from the NEON data portal API
# Should take < 1 minute
all_tabs_inv <- neonUtilities::loadByProduct(
  dpID = "DP1.20120.001", # the NEON aquatic macroinvert data product
  site = c("COMO","HOPB"), # NEON sites
  startdate = "2017-01", # start year-month
  enddate = "2019-12", # end year-month
  token = Sys.getenv("NEON_TOKEN"), # use NEON_TOKEN environmental variable
  check.size = F) # proceed with download regardless of file size



## ----download-all-data, eval=F, comment=NA-------------------------------------------------------------------------
# this download as of Aug 2022 is ~100MB
all_tabs_inv <- neonUtilities::loadByProduct(
  dpID = "DP1.20120.001", # the NEON aquatic macroinvert data product
  token = Sys.getenv("NEON_TOKEN"), # use NEON_TOKEN environmental variable
  check.size = T) # you should probably check the filesize before proceeding


## ----download-overview, message=FALSE, warning=FALSE---------------------------------------------------------------
# what tables do you get with macroinvertebrate 
# data product
names(all_tabs_inv)

# extract items from list and put in R env. 
all_tabs_inv %>% list2env(.GlobalEnv)

# readme has the same informaiton as what you 
# will find on the landing page on the data portal

# The variables file describes each field in 
# the returned data tables
View(variables_20120)

# The validation file provides the rules that 
# constrain data upon ingest into the NEON database
View(validation_20120)

# the categoricalCodes file provides controlled 
# lists used in the data
View(categoricalCodes_20120)



## ----munging-and-organizing, message=FALSE, warning=FALSE----------------------------------------------------------

# It is good to check for duplicate records. This had occurred in the past in 
# data published in the inv_fieldData table in 2021. Those duplicates were 
# fixed in the 2022 data release. 
# Here we use sampleID as primary key and if we find duplicate records, we
# keep the first uid associated with any sampleID that has multiple uids

de_duped_uids <- inv_fieldData %>% 
  
  # remove records where no sample was collected
  filter(!is.na(sampleID)) %>%  
  group_by(sampleID) %>%
  summarise(
    n_recs = length(uid),
    n_unique_uids = length(unique(uid)),
    uid_to_keep = dplyr::first(uid)) 





# Are there any records that have more than one unique uid?
max_dups <- max(de_duped_uids$n_unique_uids %>% unique())





# filter data using de-duped uids if they exist
if(max_dups > 1){
  inv_fieldData <- inv_fieldData %>%
  dplyr::filter(uid %in% de_duped_uids$uid_to_keep)
}





# extract year from date, add it as a new column
inv_fieldData <- inv_fieldData %>%
  mutate(
    year = collectDate %>% 
      lubridate::as_date() %>% 
      lubridate::year())




# extract location data into a separate table
table_location <- inv_fieldData %>%

  # keep only the columns listed below
  select(siteID, 
         domainID,
         namedLocation, 
         decimalLatitude, 
         decimalLongitude, 
         elevation) %>%
  
  # keep rows with unique combinations of values, 
  # i.e., no duplicate records
  distinct()




# create a taxon table, which describes each 
# taxonID that appears in the data set
# start with inv_taxonomyProcessed
table_taxon <- inv_taxonomyProcessed %>%

  # keep only the coluns listed below
  select(acceptedTaxonID, taxonRank, scientificName,
         order, family, genus, 
         identificationQualifier,
         identificationReferences) %>%

  # remove rows with duplicate information
  distinct()



# taxon table information for all taxa in 
# our database can be downloaded here:
# takes 1-2 minutes
# full_taxon_table_from_api <- neonUtilities::getTaxonTable("MACROINVERTEBRATE", token = NEON_TOKEN)




# Make the observation table.
# start with inv_taxonomyProcessed

# check for repeated taxa within a sampleID that need to be added together
inv_taxonomyProcessed_summed <- inv_taxonomyProcessed %>% 
  select(sampleID,
         acceptedTaxonID,
         individualCount,
         estimatedTotalCount) %>%
  group_by(sampleID, acceptedTaxonID) %>%
  summarize(
    across(c(individualCount, estimatedTotalCount), ~sum(.x, na.rm = TRUE)))
  



# join summed taxon counts back with sample and field data
table_observation <- inv_taxonomyProcessed_summed %>%
  
  # Join relevant sample info back in by sampleID
  left_join(inv_taxonomyProcessed %>% 
              select(sampleID,
                     domainID,
                     siteID,
                     namedLocation,
                     collectDate,
                     acceptedTaxonID,
                     order, family, genus, 
                     scientificName,
                     taxonRank) %>%
              distinct()) %>%
  
  # Join the columns selected above with two 
  # columns from inv_fieldData (the two columns 
  # are sampleID and benthicArea)
  left_join(inv_fieldData %>% 
              select(sampleID, eventID, year, 
                     habitatType, samplerType,
                     benthicArea)) %>%
  
  # some new columns called 'variable_name', 
  # 'value', and 'unit', and assign values for 
  # all rows in the table.
  # variable_name and unit are both assigned the 
  # same text strint for all rows. 
  mutate(inv_dens = estimatedTotalCount / benthicArea,
         inv_dens_unit = 'count per square meter')





# check for duplicate records, should return a table with 0 rows
table_observation %>% 
  group_by(sampleID, acceptedTaxonID) %>% 
  summarize(n_obs = length(sampleID)) %>%
  filter(n_obs > 1)




# extract sample info
table_sample_info <- table_observation %>%
  select(sampleID, domainID, siteID, namedLocation, 
         collectDate, eventID, year, 
         habitatType, samplerType, benthicArea, 
         inv_dens_unit) %>%
  distinct()




# create an occurrence summary table
taxa_occurrence_summary <- table_observation %>%
  select(sampleID, acceptedTaxonID) %>%
  distinct() %>%
  group_by(acceptedTaxonID) %>%
  summarize(occurrences = n())




# some summary data
sampling_effort_summary <- table_sample_info %>%
  
  # group by siteID, year
  group_by(siteID, year, samplerType) %>%
  
  # count samples and habitat types within each event
  summarise(
    event_count = eventID %>% unique() %>% length(),
    sample_count = sampleID %>% unique() %>% length(),
    habitat_count = habitatType %>% 
        unique() %>% length())




# check out the summary table
sampling_effort_summary %>% as.data.frame() %>% 
  head() %>% print()




## ----long-data, fig.cap= "Horizontal bar graph showing the number of taxa for each taxonomic rank at the D02:POSE, D08:MAYF, and D10:ARIK sites. Including facet_wrap to the ggplot call creates a seperate plot for each of the faceting arguments, which in this case are domainID and siteID.", message=FALSE, warning=FALSE----

# no. taxa by rank by site
table_observation %>% 
  group_by(domainID, siteID, taxonRank) %>%
  summarize(
    n_taxa = acceptedTaxonID %>% 
        unique() %>% length()) %>%
  ggplot(aes(n_taxa, taxonRank)) +
  facet_wrap(~ domainID + siteID) +
  geom_col()


## ----make-wide, message=FALSE, warning=FALSE-----------------------------------------------------------------------
# select only site by species density info and remove duplicate records
table_sample_by_taxon_density_long <- table_observation %>%
  select(sampleID, acceptedTaxonID, inv_dens) %>%
  distinct() %>%
  filter(!is.na(inv_dens))




# pivot to wide format, sum multiple counts per sampleID
table_sample_by_taxon_density_wide <- table_sample_by_taxon_density_long %>%
  tidyr::pivot_wider(id_cols = sampleID, 
                     names_from = acceptedTaxonID,
                     values_from = inv_dens,
                     values_fill = list(inv_dens = 0),
                     values_fn = list(inv_dens = sum)) %>%
  column_to_rownames(var = "sampleID") 

# check col and row sums -- mins should all be > 0
colSums(table_sample_by_taxon_density_wide) %>% min()
rowSums(table_sample_by_taxon_density_wide) %>% min()



## ----download-macroinvert, message=FALSE, warning=FALSE, results='hide'--------------------------------------------

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
  token = Sys.getenv("NEON_TOKEN"), #Uncomment to use your token
  check.size = FALSE)



## ----view-ecocomDP-str---------------------------------------------------------------------------------------------

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



## ----search-ecocomDP-----------------------------------------------------------------------------------------------

# search for data sets with periphyton or algae
# regex works!
my_search_result <- ecocomDP::search_data(text = "periphyt|algae")
View(my_search_result)



## ----download-algae-data, message=FALSE, warning=FALSE, results='hide'---------------------------------------------

# pull data for the NEON "Periphyton, seston, and phytoplankton collection" 
# data product (expect the download to take 1-2 mins)
my_data <- ecocomDP::read_data(
  id = "neon.ecocomdp.20166.001.001", 
  site = c("ARIK","COMO"),
  startdate = "2017-01",
  enddate = "2020-12",
  # token = NEON_TOKEN, #Uncomment to use your token
  check.size = FALSE)



## ----explore-algae-data-structure----------------------------------------------------------------------------------
# Explore the structure of the returned data object
my_data %>% names()
my_data$id
my_data$metadata$data_package_info
my_data$validation_issues
my_data$tables %>% names()

my_data$tables$location
my_data$tables$taxon %>% head()
my_data$tables$observation %>% head()



## ----flattening-and-cleaning, message=FALSE, warning=FALSE---------------------------------------------------------

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


