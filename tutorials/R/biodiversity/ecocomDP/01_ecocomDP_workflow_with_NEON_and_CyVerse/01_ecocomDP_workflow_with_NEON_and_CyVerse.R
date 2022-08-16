## ----load libraries, eval=F, comment=NA-----------------------------------------------------------------------------
# clean out workspace

#rm(list = ls()) # OPTIONAL - clear out your environment
#gc()            # Uncomment these lines if desired

# load packages
library(tidyverse)
library(neonUtilities)
library(ecocomDP)




## ----create-Renviron, eval=F, comment=NA----------------------------------------------------------------------------
usethis::edit_r_environ()


## ----set-token, eval=F, comment=NA----------------------------------------------------------------------------------
NEON_TOKEN=PASTE YOUR TOKEN HERE


## ----read-Renviron, eval=F, comment=NA------------------------------------------------------------------------------
readRenviron("../rstudio/work/home/YOUR CYVERSE USERNAME/.Renviron")


## ----download-data, message=FALSE, warning=FALSE, results='hide'----------------------------------------------------
# Download NEON aquatic macroinvertebrate data from the NEON data portal API
# Should take < 1 minute
all_tabs_inv <- neonUtilities::loadByProduct(
  dpID = "DP1.20120.001", # the NEON aquatic macroinvert data product
  site = c("COMO","HOPB"), # NEON sites
  startdate = "2017-01", # start year-month
  enddate = "2019-12", # end year-month
  token = Sys.getenv("NEON_TOKEN"), # use NEON_TOKEN environmental variable
  check.size = F) # proceed with download regardless of file size



## ----download-all-data, eval=F, comment=NA--------------------------------------------------------------------------
# this download as of Aug 2022 is ~100MB
all_tabs_inv <- neonUtilities::loadByProduct(
  dpID = "DP1.20120.001", # the NEON aquatic macroinvert data product
  token = Sys.getenv("NEON_TOKEN"), # use NEON_TOKEN environmental variable
  check.size = T) # you should probably check the filesize before proceeding


## ----download-overview, message=FALSE, warning=FALSE----------------------------------------------------------------
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



## ----munging-and-organizing, message=FALSE, warning=FALSE-----------------------------------------------------------

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
  dplyr::filter(uid %in% de_duped_uids$uid_to_keep)}


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


## ----long-data, fig.cap= "Horizontal bar graph showing the number of taxa for each taxonomic rank for select NEON sites. Including facet_wrap to the ggplot call creates a seperate plot for each of the faceting arguments, which in this case are domainID and siteID.", message=FALSE, warning=FALSE----

# no. taxa by rank by site
table_observation %>% 
  group_by(domainID, siteID, taxonRank) %>%
  summarize(
    n_taxa = acceptedTaxonID %>% 
        unique() %>% length()) %>%
  ggplot(aes(n_taxa, taxonRank)) +
  facet_wrap(~ domainID + siteID) +
  geom_col()


## ----make-wide, message=FALSE, warning=FALSE------------------------------------------------------------------------
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



## ----search-macroinvert, message=FALSE, warning=FALSE, results='hide'-----------------------------------------------
# clean out workspace from previous section

#rm(list = ls()) # OPTIONAL - clear out your environment
#gc()            # Uncomment these lines if desired

# search for data sets with periphyton or algae
# regex works!
search_result <- ecocomDP::search_data(text = "periphyt|algae")
View(search_result)

# search for invertebrate data products
search_result <- search_data(text = "invertebrate")
View(search_result)


## ----download-neon-macroinvert, message=FALSE, warning=FALSE, results='hide'----------------------------------------
# pull NEON aquatic "Macroinvertebrate collection" from the same sites
# and dates as used in the example above.
data_neon_inv <- read_data(
  id = "neon.ecocomdp.20120.001.001",
  site = c("COMO","HOPB"), # NEON sites
  startdate = "2017-01", # start year-month
  enddate = "2019-12", # end year-month
  token = Sys.getenv("NEON_TOKEN"),
  check.size = FALSE)



## ----view-neon-ecocomDP-str-----------------------------------------------------------------------------------------

# examine the structure of the data object that is returned
data_neon_inv %>% names()

# the data package id
data_neon_inv$id

# short list of package summary data
data_neon_inv$metadata$data_package_info

# validation issues? None if returns an empty list
data_neon_inv$validation_issues

# examine the tables
data_neon_inv$tables %>% names()
data_neon_inv$tables$taxon %>% head()
data_neon_inv$tables$observation %>% head()


## ----macroinvert-datavis-space-time, message=FALSE, warning=FALSE, fig.cap="Sampling events in space and time represented in the downloaded data set for benthic macroinvertebrate counts from select NEON sites."----

# Explore the spatial and temporal coverage 
# of the dataset
data_neon_inv %>% plot_sample_space_time()

# As noted above, this plot shows replicate "event_id's" can occur
# at the same time at the same site, indicating these are replicate
# observations or samples. 



## ----macroinvert-datavis-ranks, message=FALSE, warning=FALSE, fig.cap="Frequencies of different taxonomic ranks in benthic macroinvertebrate counts from select NEON sites."----

# Explore the taxonomic resolution in the dataset. 
# What is the most common taxonomic resolution (rank) 
# for macroinvertebrate identifications in this dataset?
data_neon_inv %>% plot_taxa_rank()



## ----flatten-neon-ecocomDP, message=FALSE, warning=FALSE------------------------------------------------------------
# combine all core and ancillary tables into one flat table and explore
# NOTE: we add the id so we can stack with other datasets
flat_neon_inv <- data_neon_inv %>% 
  flatten_data() %>%
  mutate(id = data_neon_inv$id) 
View(flat_neon_inv)

# note that event_id maps to a sample ID in the dataset
# we can tell because multiple event_id's can share a site and date


## ----macroinvert-datavis-densities, message=FALSE, warning=FALSE, fig.cap="Densities of benthic macroinvertebrates from select NEON sites."----
# compare taxa and abundances across sampler types
flat_neon_inv %>% 
  plot_taxa_abund(
    trans = "log10",
    min_relative_abundance = 0.01,
    color_var = "samplerType")



## ----wide-neon-ecocomDP, message=FALSE, warning=FALSE, fig.cap="NMDS of benthic macroinvertebrates from select NEON sites."----
# make wide, event_id by taxon_id
wide_neon_inv <- data_neon_inv$tables$observation %>%
  pivot_wider(
    id_cols = event_id,
    names_from = taxon_id,
    values_from = value,
    values_fill = 0) %>%
  tibble::column_to_rownames("event_id")

# make sure now rows or columns sum to 0
rowSums(wide_neon_inv) %>% min()
colSums(wide_neon_inv) %>% min()  


# load vegan library for ordination analysis
library(vegan)

# create ordination using metaMDS
my_nmds_result <- wide_neon_inv %>% metaMDS()

# ordination stress
my_nmds_result$stress

# plot ordination
ordiplot(my_nmds_result)



## ----download-full-neon-inv, eval=F, message=FALSE, warning=FALSE---------------------------------------------------
## # pull NEON aquatic "Macroinvertebrate collection" for all locations and times
## # in the 2022 Data Release
## 
## # This could take up to 10 mins
## data_neon_inv_allsites <- read_data(
##   id = "neon.ecocomdp.20120.001.001",
##   token = Sys.getenv("NEON_TOKEN"),
##   release = "RELEASE-2022",
##   check.size = FALSE)


## ----load-all-inv-dataset-mounted-cyverse-datastore, eval=F, message=FALSE, warning=FALSE---------------------------
## data_neon_inv_allsites <- readRDS("../rstudio/work/home/shared/NEON/ESA2022/macroinverts_neon.ecocomdp.20120.001.001_release2022.RDS")


## ----load-all-inv-dataset-url, message=FALSE, warning=FALSE---------------------------------------------------------
# reading in the data when not using CyVerse VICE
data_neon_inv_allsites <- readRDS(
  file = gzcon(url("https://data.cyverse.org/dav-anon/iplant/projects/NEON/ESA2022/macroinverts_neon.ecocomdp.20120.001.001_release2022.RDS")))


## ----load-all-inv-dataset-from-mounted-cyverse-datastore, message=FALSE, warning=FALSE------------------------------
flat_neon_inv_allsites <- data_neon_inv_allsites %>% flatten_data()


## ----download-ntl-macroinvert, message=FALSE, warning=FALSE---------------------------------------------------------
# pull data for NTL aquatic macroinvertebrates to compate
data_ntl_inv <- read_data(id = "edi.290.2")

# flatten the dataset
flat_ntl_inv <- data_ntl_inv %>%
  flatten_data() %>%
  mutate(
    package_id = data_ntl_inv$id,  # add id so multiple datasets can be stacked
    taxon_rank = tolower(taxon_rank))  # fix case for plotting

View(flat_ntl_inv)



## ----stack-and-compare-ranks, message=FALSE, warning=FALSE, fig.cap="Compare taxonomic ranks used in the NEON and NTL LTER macroinvertebrate datasets"----
# The NEON dataset is pretty extensive, including streams and lakes. Let's
# look at what kind of ancillary data are included that might be useful
# for filtering the dataset:
flat_neon_inv_allsites %>% names()

# what kind of aquaticSiteTypes are in the data?
flat_neon_inv_allsites$aquaticSiteType %>% unique()

# Let's filter the NEON dataset to aquaticSitetypes that are "lake", and
# only include sites in Domain 5, because those sites are relatively close 
# to the NTL LTER site (in Wisconsin)
flat_neon_inv_d05 <- flat_neon_inv_allsites %>%
  filter(aquaticSiteType == "lake",
         domainID == "D05")

# stack two datasets
stacked_inv <- bind_rows(
  flat_neon_inv_d05,
  flat_ntl_inv) %>% 
  as.data.frame()

# compare taxon ranks used in the two data sets
stacked_inv %>% 
  plot_taxa_rank(
    facet_var = "package_id",
    facet_scales = "free_x")



## ----stacked-data-spatial-and-temporal-replication, message=FALSE, warning=FALSE, fig.cap="Comparing spatial and temporal replication of NEON and NTL LTER macroinvertebrate datasets"----
# compare spatial and temporal replication
# updates are planned for this plotting function to allow 
# additional aesthetic mappings and faceting
stacked_inv %>%
  plot_sample_space_time()


## ----stacked-data-map, message=FALSE, warning=FALSE, eval=FALSE-----------------------------------------------------
## # plot on a US Map
## 
## # NOTE: for this to work, you may need to install some dependencies that
## # are not automatically installed with the ecocomDP package.
## #
## # install.packages(c("ggrepel", "usmap", "maptools",
## #                    "rgdal", "ecocomDP", "neonUtilities"), dependencies=TRUE)
## 
## stacked_inv %>%
##   plot_sites()
## 
## # Figure not shown


## ----stacked-data-richness, message=FALSE, warning=FALSE, fig.cap="Richness over time of NEON and NTL LTER macroinvertebrate datasets"----
# explore richness through time
stacked_inv %>% 
  plot_taxa_diversity(time_window_size = "year") 



## ----stacked-occurrence-freq, message=FALSE, warning=FALSE, fig.cap="Occurrence frequencies observed in NEON and NTL LTER macroinvertebrate datasets"----
# compare taxa and abundances
stacked_inv %>% 
  plot_taxa_occur_freq(
    facet_var = "package_id")


## ----plot-common-neon-taxa, message=FALSE, warning=FALSE, fig.cap="No. occurrences of common NEON taxa"-------------
# Plot common NEON taxa abundances
# you can set the min_occurrence argument to have a reasonable cutoff based 
# on the plot above
flat_neon_inv_d05 %>% 
  plot_taxa_occur_freq(min_occurrence = 100)


## ----plot-common-ntl-taxa, message=FALSE, warning=FALSE, fig.cap="No. occurrences of common NTL taxa"---------------
# Plot common NTL taxa abundances
flat_ntl_inv %>% 
  plot_taxa_occur_freq(min_occurrence = 30)

