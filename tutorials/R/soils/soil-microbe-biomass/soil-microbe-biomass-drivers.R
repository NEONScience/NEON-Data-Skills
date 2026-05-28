## ----install_packages, eval=FALSE---------------------------------------------------------------------------
# 
# install.packages("neonUtilities")
# install.packages("neonOS")
# install.packages("dplyr")
# install.packages("ggplot2")
# 


## ----load-packages, results="hide", message=FALSE, warning=FALSE--------------------------------------------

library(dplyr)
library(ggplot2)
library(neonUtilities)
library(neonOS)
token <- Sys.getenv("NEON_TOKEN")



## ----soildata, results="hide", message=FALSE----------------------------------------------------------------

microb <- loadByProduct(dpID = "DP1.10104.001", 
                        site = "GUAN", 
                        release = "RELEASE-2024", 
                        check.size = F,
                        token=token)

soil <- loadByProduct(dpID = "DP1.10086.001", 
                      site = "GUAN", 
                      release = "RELEASE-2024", 
                      check.size = F,
                      token=token)

list2env(microb, .GlobalEnv)
list2env(soil, .GlobalEnv)



## ----explore-microb-----------------------------------------------------------------------------------------

# View the first few rows of the microbial biomass table
head(sme_scaledMicrobialBiomass)



## ----total-lipid-conc-correction----------------------------------------------------------------------------

sme_scaledMicrobialBiomass <- sme_scaledMicrobialBiomass |>
  mutate(correctedTotLipidConc = ifelse(is.na(c18To0ScaledConcentration),
                                        totalLipidScaledConcentration,
                                        totalLipidScaledConcentration - c18To0ScaledConcentration))



## ----microb-units-------------------------------------------------------------------------------------------

variables_10104 |>
  filter(fieldName=="totalLipidConcentration") |>
  select(description, units)



## ----explore-soil-------------------------------------------------------------------------------------------

# View the first few rows of the soil core table, which includes soil temperature
head(sls_soilCoreCollection)

# View the first few rows of the soil moisture table
head(sls_soilMoisture)



## ----soil-units---------------------------------------------------------------------------------------------

variables_10086 |>
  filter(fieldName=="soilTemp") |>
  select(description, units)

variables_10086 |>
  filter(fieldName=="soilMoisture") |>
  select(description, units)



## ----temp-rows----------------------------------------------------------------------------------------------

# Merge soil moisture and soil collection data tables
soilcm <- joinTableNEON(sls_soilCoreCollection, 
                        sls_soilMoisture)

# Merge soil data and microbe biomass data
swcMicrob <- joinTableNEON(soilcm, 
                           sme_scaledMicrobialBiomass, 
                           name1="sls_soilCoreCollection",
                           name2="sme_scaledMicrobialBiomass")



## ----mb-temp-plot-------------------------------------------------------------------------------------------

gg <- ggplot(subset(swcMicrob, analysisResultsQF=="OK"), 
             aes(soilTemp, correctedTotLipidConc)) +
  geom_point(aes(color=plotID)) +
  xlab("Soil temperature (degrees C)") +
  ylab("Microbial biomass (nmol lipids/g soil)")
gg



## ----mb-swc-plot--------------------------------------------------------------------------------------------

gg <- ggplot(subset(swcMicrob, analysisResultsQF=="OK"), 
             aes(soilMoisture, correctedTotLipidConc)) +
  geom_point(aes(color=plotID)) +
  xlab("Soil moisture (g water / g soil)") +
  ylab("Microbial biomass (nmol lipids/g soil)")
gg


