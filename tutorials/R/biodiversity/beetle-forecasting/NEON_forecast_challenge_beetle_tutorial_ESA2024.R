## ----setup, include=FALSE----------------------------------------------------------------------------------
knitr::opts_chunk$set(eval=TRUE, error=FALSE, warning=FALSE, message=FALSE)


## ----install packages, eval = F----------------------------------------------------------------------------
# install.packages('tidyverse')
# install.packages('lubridate')
# install.packages('tsibble')
# install.packages('fable')
# install.packages('fabletools')
# install.packages('remotes')
# remotes::install_github('eco4cast/neon4cast')
# remotes::install_github("eco4cast/score4cast")


## ----load packages-----------------------------------------------------------------------------------------
version$version.string

library(tidyverse)
library(lubridate)
library(tsibble)
library(fable)
library(fabletools)
library(neon4cast)
library(score4cast)


## ----get all neon site metadata, eval=F--------------------------------------------------------------------
# # To download the NEON site information table:
# neon_site_info <- read_csv("https://www.neonscience.org/sites/default/files/NEON_Field_Site_Metadata_20231026.csv")


## ----get neon sites, eval=F--------------------------------------------------------------------------------
# site_data <- read_csv("https://raw.githubusercontent.com/eco4cast/neon4cast-targets/main/NEON_Field_Site_Metadata_20220412.csv") %>%
#   dplyr::filter(beetles == 1)


## ----set site----------------------------------------------------------------------------------------------
# choose site
my_site = "OSBS"


## ----site forecast dates-----------------------------------------------------------------------------------
# date where we will start making predictions
forecast_startdate <- "2022-01-01" #fit up through 2021, forecast 2022 data

# date where we will stop making predictions
forecast_enddate <- "2025-01-01"


## ----read data---------------------------------------------------------------------------------------------
# beetle targets are here
url <- "https://sdsc.osn.xsede.org/bio230014-bucket01/challenges/targets/project_id=neon4cast/duration=P1W/beetles-targets.csv.gz"

# read in the table
targets <- read_csv(url) %>%
  mutate(datetime = as_date(datetime)) %>%  # set proper formatting
  dplyr::filter(site_id == my_site,  # filter to desired site
                datetime < "2022-12-31") # excluding provisional data 


## ----targets table-----------------------------------------------------------------------------------------
targets[100:110,]


## ----plot targets, fig.height = 6, fig.width = 12, fig.align = "center", fig.cap="Figure: Beetle targets data at OSBS"----
targets %>% 
  as_tsibble(index = datetime, key = variable) %>%
  autoplot() +
  facet_grid(variable ~ ., scales = "free_y") + 
  theme_bw() +
  theme(legend.position = "none")



## ----get training data-------------------------------------------------------------------------------------
targets_train <- targets %>%
  filter(datetime < forecast_startdate) %>%
  pivot_wider(names_from = variable, values_from = observation) %>%
  as_tsibble(index = datetime)


## ----null forecasts----------------------------------------------------------------------------------------
# specify and fit models
# Using a log(x + 1) transform on the abundance data
mod_fits <- targets_train %>% 
  tsibble::fill_gaps() %>% # gap fill the data for the random walk model
  fabletools::model(
    mod_mean = fable::MEAN(log1p(abundance)), # generate a forecast from the historical mean plus the standard deviation of the historical data
    mod_naive = fable::NAIVE(log1p(abundance))) # random walk model, requires gap filling. Generates a forecast from the current observation plus random process noise

# make a forecast
fc_null <- mod_fits %>%
  fabletools::forecast(h = "3 years") 


## ----plot null forecast, fig.height = 6, fig.width = 12, fig.align = "center", fig.cap="Figure: NULL forecasts of ground beetle abundance at OSBS"----
# visualize the forecast
fc_null %>% 
  autoplot(targets_train) +
  facet_grid(.model ~ ., scales = "free_y") +
  theme_bw()


## ----get meteo data----------------------------------------------------------------------------------------

# Get meteorology data
path_to_clim_data <- "https://data.cyverse.org/dav-anon/iplant/projects/NEON/ESA2024/forecasting_beetles_workshop/modeled_climate_2012-2050_OSBS_CMCC_CM2_VHR4.csv"

clim_long <- read_csv(path_to_clim_data)  %>%
        filter(datetime <= forecast_enddate)

# make a tsibble object
clim_long_ts <- clim_long %>%
  as_tsibble(index = datetime, 
             key = c(variable, model_id))

# make wide
clim_wide <- clim_long %>%
  select(-unit) %>%
  pivot_wider(names_from = variable, values_from = prediction)


## ----plot clim data, fig.height = 6, fig.width = 12, fig.align = "center", fig.cap="Figure: modeled meteorology data at OSBS"----
# visualize meteorology data
clim_long_ts %>%
  ggplot(aes(datetime, prediction)) + 
  geom_line() +
  facet_grid(variable ~ ., scales = "free_y") +
  geom_vline(xintercept = lubridate::as_date(forecast_startdate),
             lty = 2) + 
  theme_bw() +
  theme(legend.position = "none")



## ----eval=TRUE, echo = TRUE, error=FALSE, warning=FALSE, message=FALSE-------------------------------------
# subset into past and future datasets, based on forecast_startdate
clim_past <- clim_wide %>%
  filter(datetime < forecast_startdate,
         datetime > "2012-01-01")

clim_future <- clim_wide %>%
  filter(datetime >= forecast_startdate,
         datetime <= forecast_enddate)



## ----eval=TRUE, echo = TRUE, error=FALSE, warning=FALSE, message=FALSE-------------------------------------
# combine target and meteorology data into a training dataset
targets_clim_train <- targets_train %>%
  left_join(clim_past)


## ----eval=TRUE, echo = TRUE, error=FALSE, warning=FALSE, message=FALSE-------------------------------------
# specify and fit model
mod_fit_candidates <- targets_clim_train %>%
  fabletools::model(
    mod_temp = fable::TSLM(log1p(abundance) ~ temperature_2m_mean),
    mod_precip = fable::TSLM(log1p(abundance) ~ precipitation_sum),
    mod_temp_precip = fable::TSLM(log1p(abundance) ~ temperature_2m_mean + precipitation_sum))

# look at fit stats and identify the best model using AIC, where the lowest AIC is the best model
fabletools::report(mod_fit_candidates) %>%
  select(`.model`, AIC)


## ----plot tslm modeled vs observed, fig.height = 6, fig.width = 12, fig.align = "center", fig.cap="Figure: TSLM predictions of beetle abundances at OSBS compared against observed data"----
# visualize model fit
# augment reformats model output into a tsibble for easier plotting
fabletools::augment(mod_fit_candidates) %>%
  ggplot(aes(x = datetime)) +
  geom_line(aes(y = abundance, lty = "Obs"), color = "dark gray") +
  geom_line(aes(y = .fitted, color = .model, lty = "Model")) +
  facet_grid(.model ~ .) +
  theme_bw()



## ----forecast best tslm------------------------------------------------------------------------------------
# focus on temperature model for now
mod_best_lm <- mod_fit_candidates %>% select(mod_temp)
report(mod_best_lm)

# make a forecast
# filter "future" meteorology data to target model
fc_best_lm <- mod_best_lm %>%
  fabletools::forecast(
    new_data = 
      clim_future %>%
      as_tsibble(index = datetime)) 


## ----plot tslm forecast, fig.height = 6, fig.width = 12, fig.align = "center", fig.cap="Figure: TSLM forecast of beelte abundance at OSBS"----
# visualize the forecast
fc_best_lm %>% 
  autoplot(targets_train) +
  facet_grid(.model ~ .) + 
  theme_bw()



## ----format for efi submission-----------------------------------------------------------------------------
# update dataframe of model output for submission
fc_best_lm_efi <- fc_best_lm %>% 
  mutate(site_id = my_site) %>% #efi needs a NEON site ID
  neon4cast::efi_format() %>%
  mutate(
    project_id = "neon4cast",
    model_id = "bet_abund_example_tslm_temp",
    reference_datetime = forecast_startdate,
    duration = "P1W")


## ----submission table--------------------------------------------------------------------------------------
head(fc_best_lm_efi)


## ----plot tslm submission, fig.height = 6, fig.width = 12, fig.align = "center", fig.cap="Figure: TSLM forecast submission file for OSBS, parameter indicates emsemble member"----
# visualize the EFI-formatted submission
fc_best_lm_efi %>% 
  as_tsibble(index = datetime,
             key = c(model_id, parameter)) %>%
  ggplot(aes(datetime, prediction, color = parameter)) +
  geom_line() +
  facet_grid(model_id ~ .) +
  theme_bw()


## ----submit forecast to efi, eval=F------------------------------------------------------------------------
# # file name format is: theme_name-year-month-day-model_id.csv
# 
# # set the theme name
# theme_name <- "beetles"
# 
# # set your submission date
# file_date <- Sys.Date()
# 
# # make sure the model_id in the filename matches the model_id in the data
# # NOTE: having the text string "example" in the file name will prevent this
# # submission from being displayed on the challenge dashboard or being included
# # in statistics about challenge participation.
# efi_model_id <- "bet_abund_example_tslm_temp"
# 
# # format the file name
# forecast_file <- paste0(theme_name,"-",file_date,"-",efi_model_id,".csv.gz")
# 
# # write the file to your working directory
# write_csv(fc_best_lm_efi, forecast_file)
# 
# # submit the file
# neon4cast::submit(forecast_file = forecast_file)
# 


## ----get scores from efi, eval=F---------------------------------------------------------------------------
# # This example requires the `arrow` package
# # install.packages("arrow")
# library(arrow)
# 
# # what is your model_id?
# # my_mod_id <- "bet_abund_example_tslm_temp"
# # my_mod_id <- "bet_example_mod_null"
# my_mod_id <- "bet_example_mod_naive"
# 
# # format the URL
# my_url <- paste0(
#   "s3://anonymous@bio230014-bucket01/challenges/scores/parquet/project_id=neon4cast/duration=P1W/variable=abundance/model_id=",
#   my_mod_id,
#   "?endpoint_override=sdsc.osn.xsede.org")
# 
# # bind dataset
# ds_mod_results <- arrow::open_dataset(my_url)
# 
# # get recs for dates that are scored
# my_scores <- ds_mod_results %>%
#   filter(!is.na(crps)) %>%
#   collect()
# 
# head(my_scores)


## ----score forecast----------------------------------------------------------------------------------------
# filter to 2022 because that is the latest release year
# 2023 is provisional and most sites do not yet have data reported
targets_2022 <- targets %>% 
  dplyr::filter(
    datetime >= "2022-01-01", 
    datetime < "2023-01-01",
    variable == "abundance",
    observation > 0)

# list of target site dates for filtering mod predictions
target_site_dates_2022 <- targets_2022 %>%
  select(site_id, datetime) %>% distinct()

# filter model forecast data to dates where we have observations
mod_results_to_score_lm <- fc_best_lm_efi %>%
  left_join(target_site_dates_2022,.) %>%
  dplyr::filter(!is.na(parameter))

# score the forecasts
mod_scores <- score(
  forecast = mod_results_to_score_lm,
  target = targets_2022) 

head(mod_scores)


## ----getting null model scores-----------------------------------------------------------------------------
# get scores for the mean and naive models
# the fc_null object has scores from both models
# note: we need to add site_id back in for efi_format() to work
fc_null_efi <- fc_null %>% 
  mutate(site_id = my_site) %>% #efi needs a NEON site ID
  neon4cast::efi_format() 

# filter to dates where we have target data from 2022
mod_results_to_score_null <- fc_null_efi %>%
  left_join(target_site_dates_2022,.) %>%
  dplyr::filter(!is.na(parameter))

# score the forecasts for those dates
mod_null_scores <- score(
  forecast = mod_results_to_score_null,
  target = targets_2022) 

# stack the scores for our best_lm and the null models
# forcing reference_datetime to be the same type in both tables
# so they will stack
all_mod_scores <- bind_rows(
  mod_null_scores %>% mutate(
    reference_datetime = as.character(reference_datetime)), 
  mod_scores %>% mutate(
    reference_datetime = as.character(reference_datetime)))


## ----plot forecasts to raw target data, fig.height = 6, fig.width = 12, fig.align = "center", fig.cap="Figure: Compare Forecasts to Raw Data. Ensemble forecasts are the lines and the black circles are the direct observations."----

mod_results_to_score_lm <- mod_results_to_score_lm |> select(site_id,datetime,parameter,model_id,family,variable,prediction)

rbind(mod_results_to_score_null,mod_results_to_score_lm) %>% 
  ggplot(., aes(datetime, prediction, color = model_id, group=interaction(parameter, model_id))) +
  geom_line(lwd = 1)+
  geom_point(aes(datetime, observation), color = "black", size = 6, inherit.aes = F, data = targets_2022)+
  ylab("Abundance")+
  theme_classic()



## ----plot forecast scores, fig.height = 6, fig.width = 12, fig.align = "center", fig.cap="Figure: Forecast scores (CRPS) for models predicting beetle abundance at the OSBS NEON site during the 2022 field season"----

all_mod_scores %>%
  ggplot(aes(datetime, crps, color = model_id)) +
  geom_line() +
  theme_bw() +
  ggtitle("Forecast scores over time at OSBS for 2022")


