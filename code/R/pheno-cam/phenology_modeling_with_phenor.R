## ----install-packages, message = FALSE-----------------------------------
# uncomment for install
# install.packages("devtools")
# install_github("khufkens/phenor")
# install.packages("phenocamr")
# install.packages("maps")

library("phenocamr")
library("phenor")
library("maps")
library("raster")

## ----download-data-------------------------------------------------------
# download the three day time series for deciduous broadleaf data at the 
# Bartlett site and will estimate the phenophases (spring + autumn). 

phenocamr::download_phenocam(
  frequency = 3,
  veg_type = "DB",
  roi_id = 1000,
  site = "bartlettir",
  phenophase = TRUE,
  out_dir = "."
  )


## ----read-data-----------------------------------------------------------
# load the time series data
df <- read.table("bartlettir_DB_1000_3day.csv", header = TRUE, sep = ",")

# read in the transition date file
td <- read.table("bartlettir_DB_1000_3day_transition_dates.csv",
                 header = TRUE,
                 sep = ",")


## ----plot-data-----------------------------------------------------------
# select the rising (spring dates) for 25% threshold of Gcc 90
td <- td[td$direction == "rising" & td$gcc_value == "gcc_90",]

# create a simple line graph of the smooth Green Chromatic Coordinate (Gcc)
# and add points for transition dates
plot(as.Date(df$date), df$smooth_gcc_90, type = "l", xlab = "Date",
     ylab = "Gcc (90th percentile)")
points(x = as.Date(td$transition_25, origin = "1970-01-01"),
       y = td$threshold_25,
       pch = 19,
       col = "red")


## ----manual-thresholds---------------------------------------------------
# the first step in phenocam processing is flagging of the outliers
# on the file you visualized in the previous step
detect_outliers("bartlettir_DB_1000_3day.csv",
                out_dir = ".")

# the second step involves smoothing the data using an optimization approach
# we force the procedure as it will be skipped if smoothed data is already
# available
smooth_ts("bartlettir_DB_1000_3day.csv",
          out_dir = ".",
          force = TRUE)

# the third and final step is the generation of phenological transition dates
td <- phenophases("bartlettir_DB_1000_3day.csv",
            internal = TRUE,
            upper_thresh = 0.8)

## ----plot-manual-thresholds----------------------------------------------
# split out the rising (spring) component for Gcc 90th
td <- td$rising[td$rising$gcc_value == "gcc_90",]

# we can now visualize the upper threshold
plot(as.Date(df$date), df$smooth_gcc_90, type = "l",
     xlab = "Date",
     ylab = "Gcc (90th percentile)")
points(x = as.Date(td$transition_80, origin = "1970-01-01"),
       y = td$threshold_80,
       pch = 19,
       col = "red")

## ----CMIP-data, eval = FALSE---------------------------------------------
## # download source cmip5 data into your temporary directory
## # please note this is a large download: >4GB!
## phenor::download_cmip5(
##   year = 2090,
##   path = tempdir(),
##   model = "MIROC5",
##   scenario = "rcp85"
##   )
## 
## phenor::download_cmip5(
##   year = 2010,
##   path = tempdir(),
##   model = "MIROC5",
##   scenario = "rcp85"
##   )

## ----format-data, eval = TRUE, message = FALSE---------------------------
# Format the phenocam transition date data 
# Specify the direction of the curve 
# Specify the gcc percentile, threshold and the temporal offset

phenocam_data <- phenor::format_phenocam(
  path = ".",
  direction = "rising",
  gcc_value = "gcc_90",
  threshold = 50,
  offset = 264,
  internal = TRUE
  )
# When internal = TRUE, the data will be returned to the R
# workspace, otherwise the data will be saved to disk.

# view data structure
str(phenocam_data)


## ----format-cmip, eval = FALSE-------------------------------------------
## # format the cmip5 data
## cmip5_2090 <- phenor::format_cmip5(
##   path = tempdir(),
##   year = 2090,
##   offset = 264,
##   model = "MIROC5",
##   scenario = "rcp85",
##   extent = c(-95, -65, 24, 50),
##   internal = FALSE
##   )
## 
## cmip5_2010 <- phenor::format_cmip5(
##   path = tempdir(),
##   year = 2010,
##   offset = 264,
##   model = "MIROC5",
##   scenario = "rcp85",
##   extent = c(-95, -65, 24, 50),
##   internal = FALSE
##   )
## 

## ----model-param, eval = TRUE--------------------------------------------
# load example data
data("phenocam_DB")

# Calibrate a simple Thermal Time (TT) model using simulated annealing
# for both the phenocam and PEP725 data. This routine might take some
# time to execute.
phenocam_par <- model_calibration(
  model = "TT",
  data = phenocam_DB,
  method = "GenSA",
  control = list(max.call = 4000),
  par_ranges = sprintf("%s/extdata/parameter_ranges.csv", path.package("phenor")),
  plot = TRUE)

# you can specify or alter the parameter ranges as located in
# copy this file and use the par_ranges parameter to use your custom version
print(sprintf("%s/extdata/parameter_ranges.csv", path.package("phenor")))


## ----view-par, eval = TRUE-----------------------------------------------
# only list the TT model parameters, ignore other
# ancillary fields
print(phenocam_par$par)

## ----get-cmip-data, eval = TRUE------------------------------------------
# download the cmip5 files from the demo repository
download.file("https://github.com/khufkens/phenocamr_phenor_demo/raw/master/data/phenor_cmip5_data_MIROC5_2090_rcp85.rds",
              "phenor_cmip5_data_MIROC5_2090_rcp85.rds")

download.file("https://github.com/khufkens/phenocamr_phenor_demo/raw/master/data/phenor_cmip5_data_MIROC5_2010_rcp85.rds",
              "phenor_cmip5_data_MIROC5_2010_rcp85.rds")

# read in cmip5 data
cmip5_2090 <- readRDS("phenor_cmip5_data_MIROC5_2090_rcp85.rds")
cmip5_2010 <- readRDS("phenor_cmip5_data_MIROC5_2010_rcp85.rds")

## ----model, eval = TRUE--------------------------------------------------
# project results forward to 2090 using the phenocam parameters
cmip5_projection_2090 <- phenor::estimate_phenology(
  par = phenocam_par$par, # provide parameters
  data = cmip5_2090, # provide data
  model = "TT" # make sure to use the same model !
)

# project results forward to 2010 using the phenocam parameters
cmip5_projection_2010 <- phenor::estimate_phenology(
  par = phenocam_par$par, # provide parameters
  data = cmip5_2010, # provide data
  model = "TT" # make sure to use the same model !
)

## ----map-model, eval = TRUE----------------------------------------------
# plot the gridded results and overlay
# a world map outline
par(oma = c(0,0,0,0))
raster::plot(cmip5_phenocam_projection, main = "DOY")
maps::map("world", add = TRUE)

## ----map-model-diff, eval = TRUE-----------------------------------------
# plot the gridded results and overlay
# a world map outline for reference
par(oma = c(0,0,0,0))
raster::plot(cmip5_projection_2010 - cmip5_projection_2090,
             main = expression(Delta * "DOY"))
maps::map("world", add = TRUE)

## ----get-pep725-data-----------------------------------------------------
# to list all species use
species_list <- phenor::check_pep725_species(list = TRUE)

# to search only for Quercus (oak) use
quercus_nr <- phenor::check_pep725_species(species = "quercus")

# return results
head(species_list)
head(quercus_nr)


## ----eval = FALSE--------------------------------------------------------
## phenor::download_pep725(
##   credentials = "~/pep725_credentials.txt",
##   species = 111,
##   path = ".",
##   internal = FALSE
##   )

## ----format-pep-data, eval = FALSE---------------------------------------
## # provisional query, code not run due to download / login requirements
## pep725_data <- phenor::format_pep725(
##   pep_path = ".",
##   eobs_path = "/your/eobs/path/",
##   bbch = "11",
##   offset = 264,
##   count = 60,
##   resolution = 0.25
##   )

