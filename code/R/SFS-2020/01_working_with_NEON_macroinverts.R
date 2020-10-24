## ----load libraries, message=FALSE--------------------------------------------------------

# clean out workspace

#rm(list = ls()) # OPTIONAL - clear out your environment
#gc()            # Uncomment these lines if desired

# load libraries 
library(tidyverse)
library(neonUtilities)


# source .r file with my NEON_TOKEN
# source("my_neon_token.R") # OPTIONAL - load NEON token
# See: https://www.neonscience.org/neon-api-tokens-tutorial



## ----download-data------------------------------------------------------------------------

# Macroinvert dpid
my_dpid <- 'DP1.20120.001'
# list of sites
my_site_list <- c('ARIK', 'POSE', 'MAYF')
# get all tables for these sites from the API -- takes < 1 minute
all_tabs_inv <- neonUtilities::loadByProduct(
  dpID = my_dpid,
  site = my_site_list,
  #token = NEON_TOKEN, #Uncomment to use your token
  check.size = F)



## ----download-overview--------------------------------------------------------------------


# what tables do you get with macroinvertebrate 
# data product
names(all_tabs_inv)

# extract items from list and put in R env. 
all_tabs_inv %>% list2env(.GlobalEnv)

# readme has the same informaiton as what you 
# will find on the landing page on the data portal

# The variables file describes each field in 
# the returned data tables
head(variables_20120)

# The validation file provides the rules that 
# constrain data upon ingest into the NEON database:
head(validation_20120)

# the categoricalCodes file provides controlled 
# lists used in the data
head(categoricalCodes_20120)



## ----munging-and-organizing, message=FALSE, tidy=TRUE-------------------------------------

# extract location data into a separate table
table_location <- inv_fieldData %>%
  
# group by columns with site location information
  group_by(siteID, 
         domainID,
         namedLocation, 
         decimalLatitude, 
         decimalLongitude, 
         elevation)%>% 

  # this will return a summary table with 1 row per site 
table_location
  

# create a taxon table, which describes each 
# taxonID that appears in the data set
# start with inv_taxonomyProcessed

table_taxon <- inv_taxonomyProcessed %>%

  # keep only the coluns listed below
  select(order, family, genus, scientificName, acceptedTaxonID, taxonRank, identificationQualifier,
         identificationReferences) %>% 
  
  # remove rows with duplicate information
        distinct() %>%
  # sort table by taxonomic hierarchy
        arrange(order, family, genus, scientificName)

head(table_taxon)

# taxon table information for all taxa in 
# our database can be downloaded here:
# takes 1-2 minutes
# full_taxon_table_from_api <- neonUtilities::getTaxonTable("MACROINVERTEBRATE", token = NEON_TOKEN)


# start with inv_taxonomyProcessed
table_observation <- inv_taxonomyProcessed %>% 
  
  # select a subset of columns from
  # inv_taxonomyProcessed
  select(uid,
         sampleID,
         domainID,
         siteID,
         namedLocation,
         collectDate,
         subsamplePercent,
         individualCount,
         estimatedTotalCount,
         acceptedTaxonID,
         order, family, genus, 
         scientificName,
         taxonRank) %>%
  
  # Join the columns selected above with
  # the inv_fieldData table. These will join 
  # based on the common variable 'sampleID'
  left_join(inv_fieldData %>% 
              select(sampleID, eventID,
                     habitatType, substratumSizeClass, samplerType,
                     benthicArea)) %>%
  
  # Create new variables:
  # Adjust invt counts for benthic area of the sampler to get invt density with comparable units
  # Extract year from date 
  mutate(inv_dens = estimatedTotalCount / benthicArea,
         inv_dens_unit = 'count per square meter',
          year = collectDate %>% 
             lubridate::as_date() %>% 
              lubridate::year())

head(table_observation)[,-1] # hides the uid column for viewing purposes 

# extract sample info
table_sample_info <- table_observation %>%
  select(sampleID, domainID, siteID, namedLocation, 
         collectDate, eventID, year, 
         habitatType, samplerType, benthicArea, 
         inv_dens_unit) %>%
  distinct()

# create a summary of sampling effort associated with taxonomic data
sampling_effort_summary <- table_sample_info %>%
  
  # group by siteID, year and sampler 
  group_by(siteID, year, samplerType) %>%#, habitatType) %>%
  
  # count events, samples and habitat types within each event
  summarise(
    event_count = eventID %>% unique() %>% length(),
    sample_count = sampleID %>% unique() %>% length(),
   habitat_count = habitatType %>% unique() %>% length())

View(sampling_effort_summary) # This shows how many samples were returned from the taxonomy lab, compare with inv_fieldData to
                              # determine if taxonomy data are present from all samples. 


# create an occurrence summary table:  number of samples across all sites in which each taxa was present
taxa_occurrence_summary <- table_observation %>%
  select(sampleID, acceptedTaxonID) %>%
  distinct() %>%  
  group_by(acceptedTaxonID) %>%
  summarise(occurrences = n())

  # filter out taxa that are only observed 1 or 2 times
  taxa_list_cleaned <- taxa_occurrence_summary %>%
    filter(occurrences > 2)

  # filter observation table based on taxon list above to remove rare/uncommon occurrences
  # this is the table we will use for exploratory analysis
  table_observation_cleaned <- table_observation %>%
   filter(acceptedTaxonID %in%
             taxa_list_cleaned$acceptedTaxonID,
           !sampleID %in% c("MAYF.20190729.CORE.1",
                          "POSE.20160718.HESS.1")) #these are outlier sampleIDs




## ----long-data, message=FALSE-------------------------------------------------------------
# create ordered factor for taxon rank 
table_observation_cleaned$taxonRank <- factor(table_observation_cleaned$taxonRank, levels = c('species','speciesGroup','subgenus','genus','tribe','subfamily','family','suborder','order','subclass','class','phylum'))

# no. taxa by rank by site
table_observation_cleaned %>% 
  group_by(domainID, siteID, taxonRank) %>%
  summarise(
    n_taxa = acceptedTaxonID %>% 
      unique() %>% length()) %>%
  ggplot(aes(n_taxa, taxonRank)) +
  facet_wrap(~ domainID + siteID) +
  geom_col()

## ----long-data-2, message=FALSE-----------------------------------------------------------
# library(scales)
# sum densities by order for each sampleID
table_observation_by_order <- 
    table_observation_cleaned %>% 
    filter(!is.na(order)) %>%
    group_by(domainID, siteID, year, 
             eventID, sampleID, habitatType, order) %>%
    summarise(order_dens = sum(inv_dens, na.rm = TRUE))
  
  
# rank occurrence by order (# of samples in which order was present)
table_observation_by_order %>% head()

# ordered list by occurrence
order_rank <- table_observation_by_order %>% group_by(order)%>% 
  summarise(occurrence = (order_dens > 0) %>% sum()) %>%
  arrange(desc(occurrence))
  
table_observation_by_order %>%
  group_by(siteID , order) %>%
  mutate(order = order %>% factor(levels = order_rank$order))%>%
  summarise(
    occurrence =  (order_dens > 0) %>% sum()) %>%# order_dens >0 is logical argument, sum() counts the number of 'TRUE' results
   ggplot()+ 
  geom_col(aes(
    x = order, 
    y = occurrence,
    color = siteID,
    fill = siteID)) + 
  theme_bw()+ theme(axis.text.x = 
          element_text(angle = 45, hjust = 1)) + 
  ggtitle("Rank occurrence by order")



## ----long-data-3--------------------------------------------------------------------------
# faceted densities plot by site
table_observation_by_order %>%
  ggplot(aes(
    x = reorder(order, -order_dens), 
    y = log10(order_dens),
    color = siteID,
    fill = siteID)) +
  geom_boxplot(alpha = .5) +
  facet_grid(siteID ~ .) +
  theme(axis.text.x = 
            element_text(angle = 45, hjust = 1))+
   labs(y = "log of invt density (count/m2)",
            x = "Order",
            title = "Boxplot: Macroinvertebrate density by order")






## ----make-wide----------------------------------------------------------------------------

# select variables of interest:  site and species density info 
table_sample_by_taxon_density_long <- table_observation_cleaned %>%
  select(sampleID, acceptedTaxonID, inv_dens) %>%
  distinct() %>%  # remove duplicate records
  filter(!is.na(inv_dens))

# pivot to wide format, sum multiple counts per sampleID
table_sample_by_taxon_density_wide <- table_sample_by_taxon_density_long %>%
  tidyr::pivot_wider(id_cols = sampleID, 
                     names_from = acceptedTaxonID,
                     values_from = inv_dens,
                     values_fill = list(inv_dens = 0),
                     values_fn = list(inv_dens = sum)) %>%
  column_to_rownames(var = "sampleID") 

# check col and row sums
# These should not be zero
colSums(table_sample_by_taxon_density_wide) %>% min()
rowSums(table_sample_by_taxon_density_wide) %>% min()



## ----calc-alpha---------------------------------------------------------------------------

table_sample_by_taxon_density_wide %>%
  vegetarian::d(lev = 'alpha', q = 0)



## ----simulated-abg------------------------------------------------------------------------

# even distribution, order q = 0 diversity = 10 
vegetarian::d(
  data.frame(spp.a = 10, spp.b = 10, spp.c = 10, 
             spp.d = 10, spp.e = 10, spp.f = 10, 
             spp.g = 10, spp.h = 10, spp.i = 10, 
             spp.j = 10),
  q = 0, 
  lev = "alpha")

# even distribution, order q = 1 diversity = 10
vegetarian::d(
  data.frame(spp.a = 10, spp.b = 10, spp.c = 10, 
             spp.d = 10, spp.e = 10, spp.f = 10, 
             spp.g = 10, spp.h = 10, spp.i = 10, 
             spp.j = 10),
  q = 1, 
  lev = "alpha")

# un-even distribution, order q = 0 diversity = 10
vegetarian::d(
  data.frame(spp.a = 90, spp.b = 2, spp.c = 1, 
             spp.d = 1, spp.e = 1, spp.f = 1, 
             spp.g = 1, spp.h = 1, spp.i = 1, 
             spp.j = 1),
  q = 0, 
  lev = "alpha")

# un-even distribution, order q = 1 diversity = 1.72
vegetarian::d(
  data.frame(spp.a = 90, spp.b = 2, spp.c = 1, 
             spp.d = 1, spp.e = 1, spp.f = 1, 
             spp.g = 1, spp.h = 1, spp.i = 1, 
             spp.j = 1),
  q = 1, 
  lev = "alpha")



## ----compare-q-NEON-----------------------------------------------------------------------

# Nest data by siteID
data_nested_by_siteID <- table_sample_by_taxon_density_wide %>%
  tibble::rownames_to_column("sampleID") %>%
  left_join(table_sample_info %>% 
                select(sampleID, siteID)) %>%
  tibble::column_to_rownames("sampleID") %>%
  nest(data = -siteID) # this uses siteID as grouping variable

# apply richness calculation by site  
data_nested_by_siteID %>% mutate(
  alpha_q0 = purrr::map_dbl(
    .x = data,
    .f = ~ vegetarian::d(abundances = .,
    lev = 'alpha', 
    q = 0)))

# Note that POSE has the highest mean diversity



# Now calculate alpha, beta, and gamma using orders 0 and 1,
# Note that I don't make all the argument assignments as explicitly here
diversity_partitioning_results <- 
    data_nested_by_siteID %>% 
    mutate(
        n_samples = purrr::map_int(data, ~ nrow(.)),
        alpha_q0 = purrr::map_dbl(data, ~vegetarian::d(
            abundances = ., lev = 'alpha', q = 0)),
        alpha_q1 = purrr::map_dbl(data, ~ vegetarian::d(
            abundances = ., lev = 'alpha', q = 1)),
         gamma_q0 = purrr::map_dbl(data, ~ vegetarian::d(
            abundances = ., lev = 'gamma', q = 0)),
        gamma_q1 = purrr::map_dbl(data, ~ vegetarian::d(
            abundances = ., lev = 'gamma', q = 1)),
        beta_q0 = purrr::map_dbl(data, ~ vegetarian::d(
            abundances = ., lev = 'beta', q = 0)),
        beta_q1 = purrr::map_dbl(data, ~ vegetarian::d(
            abundances = ., lev = 'beta', q = 1)))
       


diversity_partitioning_results %>% select(-data) %>% print()

# Note that POSE has the highest mean diversity



## ----local-regional-var, echo=F-----------------------------------------------------------

##########################################################
# local and regional scale variability
#########################################

# This doesn't make sense to do for macroinverts unless we can get 
# finer spatial resolution. 

# devtools::install_github("sokole/ltermetacommunities/ltmc")
# library(ltmc)
# 
# # Variability in aggregate biomass following
# # Wang and Loreau (2014)
# metacommunity_variability_results_POSE <- table_observation %>%
#   filter(!is.na(inv_dens), siteID == "POSE") %>%
#   ltmc::metacommunity_variability(
#     data_long = .,
#     time_step_col_name = "year",
#     site_id_col_name = "namedLocation",
#     taxon_id_col_name = "order",
#     biomass_col_name = "inv_dens",
#     variability_type = "agg")



## ----NMDS---------------------------------------------------------------------------------


# create ordination using NMDS
my_nmds_result <- table_sample_by_taxon_density_wide %>% vegan::metaMDS()

# plot stress
my_nmds_result$stress
p1 <- vegan::ordiplot(my_nmds_result)
vegan::ordilabel(p1, "species") # how similar taxon densities are across samples 

# merge NMDS scores with sampleID information for plotting
nmds_scores <- my_nmds_result %>% vegan::scores() %>%
  as.data.frame() %>%
  tibble::rownames_to_column("sampleID") %>%
  left_join(table_sample_info) 


# # How I determined the outlier(s)
nmds_scores %>% arrange(desc(NMDS1)) %>% head()
nmds_scores %>% arrange(desc(NMDS1)) %>% tail()


# Plot samples in community composition space by year
nmds_scores %>%
  ggplot(aes(NMDS1, NMDS2, color = siteID, 
             shape = samplerType)) +
  geom_point() +
  facet_wrap(~ as.factor(year))

# Plot samples in community composition space
# facet by siteID and habitat type
# color by year
nmds_scores %>%
  ggplot(aes(NMDS1, NMDS2, color = as.factor(year), 
             shape = samplerType)) +
  geom_point() +
  facet_grid(habitatType ~ siteID, scales = "free")
  




