## ----setup, include=FALSE---------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----install, eval=FALSE----------------------------------------------------------------------------------------------------------
## 
## # run once to get the package, and re-run if you need to get updates
## install.packages("neonUtilities") # work with NEON data
## install.packages('RPresence', repo='https://www.mbr-pwrc.usgs.gov/mbrCRAN') # library for occupancy modelling
## install.packages("dplyr") # data manipulation
## install.packages("tidyr") # data reshaping and tidying
## install.packages("stringr") # string handling and text processing
## install.packages("ggplot2") # visualization and plotting
## 


## ----message=FALSE, warning=FALSE-------------------------------------------------------------------------------------------------
# load the libraries into your environment
library(neonUtilities)
library(RPresence)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)


## ----warning=FALSE----------------------------------------------------------------------------------------------------------------
# Define NEON sites
large_sites <- c(
  "BARR", "BART", "BONA", "CLBJ", "CPER", "DEJU", "DSNY", "GRSM",
  "GUAN", "HARV", "HEAL", "JERC", "JORN", "KONZ", "MLBS", "MOAB",
  "NIWO", "OAES", "ONAQ", "ORNL", "OSBS", "RMNP", "SJER", "SRER",
  "STEI", "TALL", "TEAK", "UKFS", "UNDE", "WOOD", "WREF", "YELL"
)
small_sites <- c(
  "DELA", "LENO", "TOOL", "SOAP", "STER", "PUUM", "KONA",
  "SERC", "DCFS", "NOGP", "LAJA", "BLAN", "SCBI", "ABBY", "TREE"
)
sites <- c(large_sites, small_sites)

# Set up directories
if (!dir.exists("data")) {
  dir.create("data")
}
if (!dir.exists("outputs")) {
  dir.create("outputs")
}

# Path to cached dataset
bird_counts_path <- file.path("data", "bird_counts.RData")

# Load cached data if available; otherwise download and save
if (file.exists(bird_counts_path)) {
  load(bird_counts_path)
} else {
  bird.counts <- loadByProduct(
    dpID    = "DP1.10003.001",
    package = "basic",
    release = "RELEASE-2026",
    token   = Sys.getenv("NEON_TOKEN"),
    site    = sites,
    check.size = FALSE
  )
  
  save(bird.counts, file = bird_counts_path)
}


## ----brd_perpoint-----------------------------------------------------------------------------------------------------------------
str(bird.counts$brd_perpoint)

head(bird.counts$brd_perpoint, n=5)


## ----brd_countdata----------------------------------------------------------------------------------------------------------------
str(bird.counts$brd_countdata)

head(bird.counts$brd_countdata, n=5)


## ---------------------------------------------------------------------------------------------------------------------------------
brd_perpoint_clean <- bird.counts$brd_perpoint %>%
  mutate(year = str_extract(eventID, "\\d{4}")) %>%
  mutate(pointSurveyID = paste(plotID, "point", pointID, year, "bout", boutNumber, sep = "_"))

brd_countdata_clean <- bird.counts$brd_countdata %>%
  mutate(year = str_extract(eventID, "\\d{4}")) %>%
  mutate(pointSurveyID = paste(plotID, "point", pointID, year, "bout", boutNumber, sep = "_"))


## ---------------------------------------------------------------------------------------------------------------------------------
brd_perpoint_clean <- brd_perpoint_clean %>%
  filter(samplingImpractical == "OK")


## ---------------------------------------------------------------------------------------------------------------------------------
brd_perpoint_clean <- brd_perpoint_clean %>%
  filter(year >= 2017)


## ---------------------------------------------------------------------------------------------------------------------------------
brd_countdata_clean <- brd_countdata_clean %>%
  filter(taxonRank == "species")


## ---------------------------------------------------------------------------------------------------------------------------------
#Join the tables
brd_joineddata_clean <- inner_join(
  brd_countdata_clean,
  brd_perpoint_clean,
  by = "pointSurveyID",
  suffix = c(".count", ".perpoint")
)

#Remove duplicate columns between tables
brd_joineddata_clean <- brd_joineddata_clean %>%
  select(-matches("\\.perpoint$"))
names(brd_joineddata_clean) <- gsub("\\.count$", "", names(brd_joineddata_clean))

head(brd_joineddata_clean, n=5)


## ---------------------------------------------------------------------------------------------------------------------------------
# Filter table by species
bird_species <- "Melanerpes carolinus"

brd_single_species <- brd_joineddata_clean %>%
  filter(scientificName == bird_species)


## ---------------------------------------------------------------------------------------------------------------------------------
# Get all valid site-year combinations across sites (so we can fill in NAs)
valid_site_years <- brd_perpoint_clean %>%
  distinct(siteID, year)


## ---------------------------------------------------------------------------------------------------------------------------------
# Get detections (so we can fill in 0/1s)
detections <- brd_single_species %>%
  group_by(siteID, year) %>%
  summarize(present = 1, .groups = "drop")


## ---------------------------------------------------------------------------------------------------------------------------------
# Join and fill
detection_history <- valid_site_years %>%
  left_join(detections, by = c("siteID", "year")) %>%
  mutate(present = replace_na(present, 0)) %>%
  pivot_wider(
    names_from = year,
    values_from = present
  ) %>%
  arrange(siteID) %>% # sort siteIDs
  select(siteID, sort(names(.)[-1])) # sort surveys

head(detection_history, n=10)


## ---------------------------------------------------------------------------------------------------------------------------------
birds_pao_simple <- createPao(
  data = detection_history[, -1], # detection/nondetection data (survey columns only) from detection_history
  unitnames = detection_history$siteID # siteIDs from detection_history
)


## ---------------------------------------------------------------------------------------------------------------------------------
birds_occupancy_simple <- occMod(
  data = birds_pao_simple,           
  model = list(
    psi ~ 1,
    p ~ 1),
  type = 'so'
  )

summary(birds_occupancy_simple)


## ---------------------------------------------------------------------------------------------------------------------------------
ests <- as.data.frame(print_one_site_estimates(mod = birds_occupancy_simple))

#Rename some values for readability
ests <- ests[1:2,] %>% 
  mutate(parm = c("psi", "p")) %>% 
  select(parm, est, se, lower, upper) %>% 
  rename(., 
    c(
      Parameter = parm,
      Estimate = est,
      SE = se, # Standard Error
      L95 = lower, #95% Confidence Interval - Lower Boundary
      U95 = upper #95% Confidence Interval - Upper Boundary
    )
  ) %>% 
  `rownames<-`(seq_len(nrow(ests[1:2,])))

ests


## ----message=FALSE, warning=FALSE-------------------------------------------------------------------------------------------------
library(sf)
library(rnaturalearth)

url <- "https://www.sciencebase.gov/catalog/file/get/59f5ec2be4b063d5d307e4c3?f=__disk__b5%2F37%2Ffc%2Fb537fc3bf8c92b1162bca650dda01c052e87ec6e"

zip <- tempfile(fileext = ".zip")
dir <- tempdir()

download.file(url, zip, mode = "wb")
unzip(zip, exdir = dir)

melanerpes_carolinus_range <-
  st_read(list.files(dir, "\\.shp$", full.names = TRUE), quiet = TRUE) |>
  st_transform(4326)

site_map <- brd_perpoint_clean %>%
  select(siteID, decimalLatitude, decimalLongitude) %>%
  distinct(siteID, .keep_all = TRUE) %>%
  left_join(
    brd_single_species %>%
      distinct(siteID) %>%
      mutate(present = 1),
    by = "siteID"
  ) %>%
  mutate(present = ifelse(is.na(present), 0, present))

usa <- bind_rows(
  ne_states(country = "United States of America", returnclass = "sf"),
  ne_states(country = "Puerto Rico", returnclass = "sf")
) %>%
  st_transform(4326)

ggplot() +
  geom_sf(data = usa, fill = NA, color = "black") +
  geom_sf(data = melanerpes_carolinus_range,
          fill = "lightgreen",
          color = NA,
          alpha = 0.4) +
  geom_point(data = site_map,
             aes(x = decimalLongitude,
                 y = decimalLatitude,
                 color = factor(present)),
             size = 2) +
  scale_color_manual(
    values = c("0" = "gray70", "1" = "darkgreen"),
    labels = c("Not detected", "Detected"),
    name = "Species observed"
  ) +
  coord_sf(
  xlim = c(-170, -60),
  ylim = c(15, 72),
  expand = FALSE
) +
  labs(
    x = "Longitude",
    y = "Latitude",
    title = "Red-bellied Woodpecker Range and NEON Site Detections"
  ) +
  theme_bw()


## ---------------------------------------------------------------------------------------------------------------------------------
# Function to run the simple occupancy model workflow for any species
run_simple_species_model <- function(species_name, common_name){

  brd_species <- brd_joineddata_clean %>%
    filter(siteID %in% sites,
           scientificName == species_name)

  detections <- brd_species %>%
    group_by(siteID, year) %>%
    summarize(present = 1, .groups = "drop")

  detection_history <- valid_site_years %>%
    left_join(detections, by = c("siteID", "year")) %>%
    mutate(present = replace_na(present, 0)) %>%
    pivot_wider(names_from = year, values_from = present) %>%
    arrange(siteID) %>%
    select(siteID, sort(names(.)[-1]))

  pao <- createPao(
    data = detection_history[, -1],
    unitnames = detection_history$siteID,
    title = common_name
  )

  model <- occMod(
    data = pao,
    model = list(
      psi ~ 1,
      p ~ 1
    ),
    type = "so"
  )

  return(model)
}


## ---------------------------------------------------------------------------------------------------------------------------------
owl_model <- run_simple_species_model(
  species_name = "Bubo virginianus",
  common_name = "Great Horned Owl"
)

jay_model <- run_simple_species_model(
  species_name = "Cyanocitta cristata",
  common_name = "Blue Jay"
)


## ---------------------------------------------------------------------------------------------------------------------------------
# Function to extract and rename estimates for simple model
extract_estimates <- function(model){
  
  ests <- as.data.frame(print_one_site_estimates(mod = model))

  ests <- ests[1:2,] %>% 
    mutate(Parameter = c("psi", "p")) %>%
    select(Parameter, est, se, lower, upper) %>%
    rename(
      Estimate = est,
      SE = se,
      L95 = lower,
      U95 = upper
    )

  return(ests)
}

owl_estimates <- extract_estimates(owl_model) %>%
  mutate(Species = "Great Horned Owl")

jay_estimates <- extract_estimates(jay_model) %>%
  mutate(Species = "Blue Jay")

# Combine estimates for plotting
species_estimates <- bind_rows(owl_estimates, jay_estimates)


## ---------------------------------------------------------------------------------------------------------------------------------
ggplot(species_estimates,
       aes(x = Parameter, y = Estimate, fill = Species)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_errorbar(aes(ymin = L95, ymax = U95),
                position = position_dodge(width = 0.7),
                width = 0.15) +
  scale_x_discrete(
    limits = c("psi", "p"),
    labels = c(
      psi = "Occupancy (ψ)",
      p = "Detection (p)"
    )
  ) +
  scale_y_continuous(limits = c(0, 1)) +
  labs(
    x = NULL,
    y = "Estimated Probability",
    title = "Occupancy and Detection Estimates by Species"
  ) +
  theme_bw()


## ---------------------------------------------------------------------------------------------------------------------------------
site_cov <- brd_joineddata_clean %>%
  select(siteID, elevation) %>%
  distinct(siteID, .keep_all = TRUE) %>%
  arrange(siteID) %>%
  tibble::column_to_rownames("siteID")

head(site_cov, n=10)


## ---------------------------------------------------------------------------------------------------------------------------------
# Example categorical covariate
 site_cov_categorical <- brd_perpoint_clean %>%
   select(siteID, nlcdClass) %>%
   distinct(siteID, .keep_all = TRUE) %>%
   mutate(nlcdClass = as.factor(nlcdClass)) %>%
   arrange(siteID) %>%
   tibble::column_to_rownames("siteID")

site_cov_categorical$nlcdClass <- factor(site_cov_categorical$nlcdClass)

head(site_cov_categorical, n=10)


## ---------------------------------------------------------------------------------------------------------------------------------
birds_pao_sitecov <- createPao(
  data = detection_history[, -1], # detection/nondetection data (survey columns only) from detection_history
  unitnames = detection_history$siteID, # site IDs from detection_history
  unitcov = site_cov # add the site covariates
)


## ---------------------------------------------------------------------------------------------------------------------------------
birds_occupancy_sitecov <- occMod(
  data = birds_pao_sitecov,           
  model = list(psi ~ elevation, 
               p ~ 1),
  type = 'so'
  )


## ---------------------------------------------------------------------------------------------------------------------------------
mod.list <-  list(
    birds_occupancy_simple, # the model with formula psi ~ 1, p ~ 1
    birds_occupancy_sitecov # the model with formula psi ~ elevation, p ~ 1
)
aictable <- createAicTable(mod.list = mod.list)
aictable$table


## ---------------------------------------------------------------------------------------------------------------------------------
#get the difference in the neg2loglike between the two models
diff <- abs(birds_occupancy_simple$neg2loglike - birds_occupancy_sitecov$neg2loglike)

#look up our observed difference on a chi-square distribution with 1 degree of freedom (the difference between the number of parameters)
pchisq(diff, 
       df = abs(birds_occupancy_simple$npar - birds_occupancy_sitecov$npar),
       lower.tail = FALSE)



## ---------------------------------------------------------------------------------------------------------------------------------
coef(birds_occupancy_sitecov, 'psi', prob = 0.95)


## ---------------------------------------------------------------------------------------------------------------------------------
data <- cbind(site_cov, birds_occupancy_sitecov$real$psi) %>% 
  distinct(.keep_all = TRUE) %>%
  arrange(elevation)

ggplot(data, aes(x = elevation, y = est)) +
  geom_point(size = 2, alpha = 0.8) +
  labs(
    x = "Elevation",
    y = "Predicted Occupancy Probability"
  ) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_bw()


## ---------------------------------------------------------------------------------------------------------------------------------
survey_effort <- brd_perpoint_clean %>% # we start with brd_perpoint_clean since we want all point-count surveys conducted, not just those that detected birds
  distinct(pointSurveyID, siteID, year) %>%
  group_by(siteID, year) %>%
  summarize(
    survey_effort = n() * 6, # the number of surveys multiplied by 6
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = year,
    values_from = survey_effort,
    values_fill = 0 # We can fill in NAs as 0s since no time was spend conducting surveys for incomplete surveys
  ) %>%
  tibble::column_to_rownames("siteID") %>% # sort siteIDs alphabetically
  select(sort(names(.))) # sort years

head(survey_effort, n=10)


## ---------------------------------------------------------------------------------------------------------------------------------
# flatten the data frame
surveycov <-  data.frame(
  survey_effort = unlist(survey_effort)
  #it is possible to add other survey covariates here
  )

# remove the rownames
row.names(surveycov) <- NULL

head(surveycov)



## ---------------------------------------------------------------------------------------------------------------------------------
birds_pao_surveycov <- createPao(
  data = detection_history[, -1], # detection/nondetection data (survey columns only) from detection_history
  unitnames = detection_history$siteID, # site IDs from detection_history
  unitcov = site_cov, # add the site covariates
  survcov = surveycov # add the survey covariates
)


## ---------------------------------------------------------------------------------------------------------------------------------
birds_occupancy_surveycov <- occMod(
  data = birds_pao_surveycov,           
  model = list(psi ~ elevation,  p ~ survey_effort),
  type = 'so'
  )

summary(birds_occupancy_surveycov)


## ---------------------------------------------------------------------------------------------------------------------------------
mod.list <-  list(
    birds_occupancy_simple, # the model with formula psi ~ 1, p ~ 1
    birds_occupancy_sitecov, # the model with formula psi ~ elevation, p ~ 1
    birds_occupancy_surveycov # the model with formula psi ~ elevation, p ~ survey_effort
)
aictable <- createAicTable(mod.list = mod.list)
aictable$table


## ---------------------------------------------------------------------------------------------------------------------------------
#get the difference in the neg2loglike between the two models
diff <- abs(birds_occupancy_sitecov$neg2loglike - birds_occupancy_surveycov$neg2loglike)

#look up our observed difference on a chi-square distribution with 1 degree of freedom (the difference between the number of parameters)
pchisq(diff, 
       df = abs(birds_occupancy_sitecov$npar - birds_occupancy_surveycov$npar),
       lower.tail = FALSE)



## ---------------------------------------------------------------------------------------------------------------------------------
coef(birds_occupancy_surveycov, 'p', prob = 0.95)


## ---------------------------------------------------------------------------------------------------------------------------------
data <- cbind(surveycov, birds_occupancy_surveycov$real$p) %>% 
  distinct(.keep_all = TRUE) %>%
  arrange(survey_effort)

ggplot(data, aes(x = survey_effort, y = est)) +
  geom_point(size = 2, alpha = 0.8) +
  labs(
    x = "Survey Effort",
    y = "Predicted Detection Probability"
  ) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_bw()

