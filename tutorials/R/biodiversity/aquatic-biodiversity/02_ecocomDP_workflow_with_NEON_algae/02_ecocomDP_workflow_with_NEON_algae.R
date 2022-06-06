## ----load libraries, eval=F, comment=NA-----------------------------------------------------------------------------------------------

# clean out workspace

#rm(list = ls()) # OPTIONAL - clear out your environment
#gc()            # Uncomment these lines if desired

# load packages
library(tidyverse)
library(neonUtilities)
library(vegan)
library(ecocomDP)

# source .r file with my NEON_TOKEN
# source("my_neon_token.R") # OPTIONAL - load NEON token
# See: https://www.neonscience.org/neon-api-tokens-tutorial





## ----download-macroinvert, message=FALSE, warning=FALSE, results='hide'---------------------------------------------------------------

# search for invertebrate data products
my_search_result <- 
    ecocomDP::search_data(text = "invertebrate")
View(my_search_result)

# pull data for the NEON aquatic "Macroinvertebrate
# collection"
my_data <- ecocomDP::read_data(
  id = "neon.ecocomdp.20120.001.001",
  site = "ARIK",
  startdate = "2017-06",
  enddate = "2020-03",
  # token = NEON_TOKEN, #Uncomment to use your token
  check.size = FALSE)



## ----view-ecocomDP-str----------------------------------------------------------------------------------------------------------------

# examine the structure of the data object that is returned
my_data %>% names()
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



## ----search-ecocomDP------------------------------------------------------------------------------------------------------------------

# search for data sets with periphyton or algae
# regex works!
my_search_result <- ecocomDP::search_data(text = "periphyt|algae")
View(my_search_result)



## ----download-algae-data, message=FALSE, warning=FALSE, results='hide'----------------------------------------------------------------

# pull data for the NEON "Periphyton, seston, and phytoplankton collection" 
# data product
my_data <- 
    ecocomDP::read_data(
      id = "neon.ecocomdp.20166.001.001", 
      site = "ARIK",
      startdate = "2017-06",
      enddate = "2020-03",
      # token = NEON_TOKEN, #Uncomment to use your token
      check.size = FALSE)



## ----explore-data-structure-----------------------------------------------------------------------------------------------------------
# Explore the structure of the returned data object
my_data %>% names()
my_data$metadata$data_package_info
my_data$validation_issues
my_data$tables %>% names()

my_data$tables$location
my_data$tables$taxon %>% head()
my_data$tables$observation %>% head()


## ----flattening-and-cleaning, message=FALSE, warning=FALSE----------------------------------------------------------------------------

# flatten the ecocomDP data tables into one flat table
my_data_flat <- my_data$tables %>% ecocomDP::flatten_data()

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



## ----plot-taxon-rank, fig.cap= "Bar plot showing the frequency of each taxonomic rank observed in algae count data from the Arikaree River site."----

# Which taxon ranks are most common?
my_data_benthic %>% ecocomDP::plot_taxa_rank()


## ----algae-data-vis-richness-time, message=FALSE, warning=FALSE, fig.cap="Benthic algal richness by year at ARIK and COMO"------------

# plot richness by year
my_data_benthic %>% ecocomDP::plot_taxa_diversity(time_window_size = "year")



## ----more-cleaning, message=FALSE, warning=FALSE--------------------------------------------------------------------------------------

# Note that for this data product
# neon_sample_id = event_id
# event_id is a grouping variable for the observation 
# table in the ecocomDP data model



# Check for multiple taxon counts per taxon_id by 
# event_id. 
my_data_benthic %>% 
  group_by(event_id, taxon_id) %>%
  summarize(n_obs = length(event_id)) %>%
  dplyr::filter(n_obs > 1)



# Per instructions from the lab, these 
# counts should be summed.
my_data_summed <- my_data_benthic %>%
  group_by(event_id,taxon_id) %>%
  summarize(value = sum(value, na.rm = FALSE),
            observation_id = dplyr::first(observation_id))

my_data_cleaned <- my_data_benthic %>%
  dplyr::select(
    event_id, location_id, datetime,
    taxon_id, taxon_rank, taxon_name) %>%
  distinct() %>%
  right_join(my_data_summed)



# check for duplicate records, there should not 
# be any at this point.
my_data_cleaned %>% 
  group_by(event_id, taxon_id) %>%
  summarize(n_obs = length(event_id)) %>%
  dplyr::filter(n_obs > 1)



## ----SAC-1, fig.cap= "Species accumalation plot for 11 sampling events. Confidence intervals are based on random permutations of observed samples."----

# convert densities from per m2 to per cm2
my_data_long <- my_data_cleaned %>%
  filter(taxon_rank == "species") %>%
  select(event_id, taxon_id, value)

# make data wide
my_data_wide <- my_data_long %>% 
  pivot_wider(names_from = taxon_id, 
              values_from = value,
              values_fill = list(value = 0)) %>%
  tibble::column_to_rownames("event_id")
  
# Calculate and plot species accumulcation curve for the 11 sampling events
# The CIs are based on random permutations of observed samples
alg_spec_accum_result <- my_data_wide %>% vegan::specaccum(., "random")
plot(alg_spec_accum_result)



## ----compare-obs-sim-SAC--------------------------------------------------------------------------------------------------------------

# Extract the resampling data used in the above algorithm
spec_resamp_data <- data.frame(
  data_set = "observed", 
  sampling_effort = rep(1:nrow(alg_spec_accum_result$perm), 
                        each = ncol(alg_spec_accum_result$perm)),
  richness = c(t(alg_spec_accum_result$perm)))


# Fit species accumulation model
spec_accum_mod_1 <- my_data_wide %>% vegan::fitspecaccum(model = "arrh")


# create a "predicted" data set from the model to extrapolate out 
# beyond the number of samples collected
sim_spec_data <- data.frame()
for(i in 1:100){
  d_tmp <- data.frame(
    data_set = "predicted",
    sampling_effort = i,
    richness = predict(spec_accum_mod_1, newdata = i))
  
  sim_spec_data <- sim_spec_data %>%
    bind_rows(d_tmp)
}


# plot the "observed" and "simulated" curves with 95% CIs
data_plot <- spec_resamp_data %>% bind_rows(sim_spec_data) 

data_plot %>%
  ggplot(aes(sampling_effort, richness, 
             color = as.factor(data_set),
             fill = as.factor(data_set),
             linetype = as.factor(data_set))) +
  stat_summary(fun.data = median_hilow, fun.args = list(conf.int = .95), 
               geom = "ribbon", alpha = 0.25) +
  stat_summary(fun.data = median_hilow, geom = "line", 
               size = 1) 
    

