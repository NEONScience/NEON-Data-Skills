## ----load libraries, eval=F, comment=NA-------------------

# clean out workspace

#rm(list = ls()) # OPTIONAL - clear out your environment
#gc()            # Uncomment these lines if desired

# load packages
library(tidyverse)
library(neonUtilities)
library(devtools)

# install neon_demo branch of ecocomDP
devtools::install_github("sokole/ecocomDP@neon_demo")

library(ecocomDP)

# source .r file with my NEON_TOKEN
# source("my_neon_token.R") # OPTIONAL - load NEON token
# See: https://www.neonscience.org/neon-api-tokens-tutorial





## ----download-macroinvert---------------------------------

# search for invertebrate data products
my_search_result <- 
    ecocomDP::search_data(text = "invertebrate")
View(my_search_result)

# pull data for the NEON aquatic "Macroinvertebrate
# collection" data product
# function not yet compatible with "token" argument 
# in updated neonUtilities
my_search_result_data <- 
    ecocomDP::read_data(id = "DP1.20120.001",
                        site = c("ARIK", "POSE"))



## ----view-ecocomDP-str------------------------------------

# examine the structure of the data object that is returned
my_search_result_data %>% names()
my_search_result_data$DP1.20120.001 %>% names()
my_search_result_data$DP1.20120.001$tables %>% names()
my_search_result_data$DP1.20120.001$tables$taxon %>% head()
my_search_result_data$DP1.20120.001$tables$observation %>% head()



## ----search-ecocomDP--------------------------------------

# search for data sets with periphyton or algae
# regex works!
my_search_result <- ecocomDP::search_data(text = "periphyt|algae")
View(my_search_result)



## ----download-plankton------------------------------------

# pull data for the NEON "Periphyton, seston, and phytoplankton collection" 
# data product
my_search_result_data <- 
    ecocomDP::read_data(id = "DP1.20166.001", site = "ARIK")


# Explore the structure of the returned data object
my_search_result_data %>% names()
my_search_result_data[[1]] %>% names()
my_search_result_data[[1]]$tables %>% names()


my_search_result_data[[1]]$tables$location
my_search_result_data[[1]]$tables$taxon %>% head()
my_search_result_data[[1]]$tables$observation %>% head()

# This data product has algal densities reported for both
# lakes and streams, so densities could be standardized
# either to volume collected or area sampled. 

# Verify that only benthic algae standardized to area 
# are returned in this data pull:
my_search_result_data[[1]]$tables$observation$unit %>%
    unique()




## ----join-obs-taxon---------------------------------------

# join observations with taxon info
alg_observations_with_taxa <- my_search_result_data[[1]]$tables$observation %>%
  filter(!is.na(value)) %>%
  left_join(my_search_result_data[[1]]$tables$taxon) %>%
  select(-authority_taxon_id) %>%
  distinct()

alg_observations_with_taxa %>% head()



## ----plot-taxon-rank, fig.cap= "Bar plot showing the frequency of each taxonomic rank observed in algae count data from the Arikaree River site."----

# which taxon rank is most common
alg_observations_with_taxa %>%
  ggplot(aes(taxon_rank)) +
  geom_bar()



## ----SAC-1, fig.cap= "Species accumalation plot for 11 sampling events. Confidence intervals are based on random permutations of observed samples."----

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



## ----compare-obs-sim-SAC----------------------------------

# Load the 'vegan' package to ensue the lines below will work
library(vegan)
library(Hmisc)
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
    

