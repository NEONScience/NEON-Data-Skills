# R Script 2 for "Explore and work with NEON biodiversity data from aquatic ecosystems", JUNE 23, 2020
#
# Author: Eric R. Sokol (esokol@battelleecology.org)
#
#
# changelog and author contributions / copyrights
#   Eric R Sokol (2020-06-22)
#     original creation


#' In this second live coding section of the workshop, we will explore how
#' to find and download NEON biodiversity data using the ecocomDP package 
#' for R, which is under development by the Environmental Data Initiative (EDI).
#' 
#' What is ecocomDP?
#' 
#' ecocomDP is both the name of an R package and a data model. 
#' 
#' EDI describes the ecocomDP data model as "A dataset design pattern for
#' ecological community data to facilitate synthesis and reuse". 
#' 
#' See the ecocomDP github repo here:
#' https://github.com/EDIorg/ecocomDP 
#' 
#' 
#' Link to data model figure: 
#' https://github.com/EDIorg/ecocomDP/blob/master/documentation/model/ecocomDP.png
#' 
#' 
#' The motivation is for both NEON biodiversity data products and
#' EDI data packages, including data from the US Long Term Ecological Research 
#' Network and Macrosystems Biology projects, to be discoverable through a 
#' single data search tool, and to be delivered in a standard format. Our 
#' objective here is to demonstrate how the workflow will work with NEON
#' biodiversity data packages. 



################################
# Getting started
#########################

# clean out workspace

rm(list=ls())
gc()


# load packages
library(tidyverse)
library(neonUtilities)
library(devtools)


# install neon_demo branch of ecocomDP
devtools::install_github("sokole/ecocomDP@neon_demo")

library(ecocomDP)


# search for invertebrate data products
my_search_result <- ecocomDP::search_data(text = "invertebrate")
View(my_search_result)

# pull data for the NEON aquatic "Macroinvertebrate collection" data product
# function not yet compatible with "token" argument in updated neonUtilities
my_search_result_data <- ecocomDP::read_data(id = "DP1.20120.001", 
                                             site = c("ARIK", "POSE"))

# examine the structur eof the data object that is returned
my_search_result_data %>% names()
my_search_result_data$DP1.20120.001 %>% names()
my_search_result_data$DP1.20120.001$tables %>% names()
my_search_result_data$DP1.20120.001$tables$taxon %>% head()
my_search_result_data$DP1.20120.001$tables$observation %>% head()


# search for data sets with periphyton or algae
# regex works!
my_search_result <- ecocomDP::search_data(text = "periphyt|algae")
View(my_search_result)


# pull data for the NEON "Periphyton, seston, and phytoplankton collection" 
# data product
my_search_result_data <- ecocomDP::read_data(id = "DP1.20166.001", 
                                             site = "ARIK")


# Explore the structure of the returned data object
my_search_result_data %>% names()
my_search_result_data[[1]] %>% names()
my_search_result_data[[1]]$tables %>% names()


my_search_result_data[[1]]$tables$location
my_search_result_data[[1]]$tables$taxon %>% head()
my_search_result_data[[1]]$tables$observation %>% head()

# This data product has algal densities reported for both lakes and 
# streams, so densities could be standardized either to volume collected
# or area sampled. 
# Verify that only benthic algae standardized to area are returned in this data pull:
my_search_result_data[[1]]$tables$observation$unit %>% unique()


# join observations with taxon info
alg_observations_with_taxa <- my_search_result_data[[1]]$tables$observation %>%
  filter(!is.na(value)) %>%
  left_join(my_search_result_data[[1]]$tables$taxon) %>%
  select(-authority_taxon_id) %>%
  distinct()


alg_observations_with_taxa %>% head()

# which taxon rank is most common
alg_observations_with_taxa %>%
  ggplot(aes(taxon_rank)) +
  geom_bar()


# convert densities from per m2 to per cm2
alg_dens_long <- alg_observations_with_taxa %>%
  mutate(dens_cm2 = (value / 10000)) %>%
  filter(taxon_rank == "species") %>%
  select(event_id, taxon_id, dens_cm2)

# make data wide
alg_dens_wide <- alg_dens_long %>% 
  pivot_wider(names_from = taxon_id, 
              values_from = dens_cm2,
              values_fill = list(dens_cm2 = 0),
              values_fn = list(dens_cm2 = mean)) %>%
  tibble::column_to_rownames("event_id")
  
# Calculate and plot species accumulcation curve for the 11 sampling events
# The CIs are based on random permutations of observed samples
alg_spec_accum_result <- alg_dens_wide %>% vegan::specaccum(., "random")
plot(alg_spec_accum_result)

# Extract the resampling data used in the above algorithm
spec_resamp_data <- data.frame(
  data_set = "observed", 
  sampling_effort = rep(1:nrow(alg_spec_accum_result$perm), 
                        each = ncol(alg_spec_accum_result$perm)),
  richness = c(t(alg_spec_accum_result$perm)))


# Fit species accumulation model
spec_accum_mod_1 <- alg_dens_wide %>% vegan::fitspecaccum(model = "arrh")


# create a "predicted" data set from the model to extrapolate out 
# beyond the number of samples collected
sim_spec_data <- data.frame()
for(i in 1:25){
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
    

