## ----install_packages, eval=FALSE--------------------------------------------------------------------
# 
# install.packages("neonUtilities")
# 


## ----load-packages, results="hide"-------------------------------------------------------------------

library(neonUtilities)



## ----soildata, results="hide", message=FALSE---------------------------------------------------------

microb <- loadByProduct(dpID = "DP1.10104.001", 
                        site = "GUAN", 
                        release = "RELEASE-2024", 
                        check.size = F)

soil <- loadByProduct(dpID = "DP1.10086.001", 
                      site = "GUAN", 
                      release = "RELEASE-2024", 
                      check.size = F)



## ----explore-microb----------------------------------------------------------------------------------

# View the first few rows of the microbial biomass table
head(microb$sme_scaledMicrobialBiomass)



## ----total-lipid-conc-correction---------------------------------------------------------------------

# Identify pre- (i.e., c18To0ScaledConcentration = NA) and post-November 2021 data
preNov2021 <- is.na(microb$sme_scaledMicrobialBiomass$c18To0ScaledConcentration)

# Add the pre-November 2021 total lipid concentration data to a new column (no correction needed)
microb$sme_scaledMicrobialBiomass$correctedTotLipidConc[preNov2021] <- 
  microb$sme_scaledMicrobialBiomass$totalLipidScaledConcentration[preNov2021]

# Add the corrected (totalLipidScaledConcentration - c18To0ScaledConcentration) total lipid concentration data to the new column
microb$sme_scaledMicrobialBiomass$correctedTotLipidConc[!preNov2021] <- 
  microb$sme_scaledMicrobialBiomass$totalLipidScaledConcentration[!preNov2021] - 
  microb$sme_scaledMicrobialBiomass$c18To0ScaledConcentration[!preNov2021]



## ----microb-units------------------------------------------------------------------------------------

# Identify the units of the totalLipidConcentration data
microb$variables_10104[grep("totalLipidConcentration", microb$variables_10104$fieldName), c("description", "units")]



## ----explore-soil------------------------------------------------------------------------------------

# View the first few rows of the soil core table, which includes soil temperature
head(soil$sls_soilCoreCollection)

# View the first few rows of the soil moisture table
head(soil$sls_soilMoisture)



## ----soil-units--------------------------------------------------------------------------------------

# Identify the units of the soilTemp data
soil$variables_10086[grep("soilTemp", soil$variables_10086$fieldName), c("description", "units")]

# Identify the units of the soilTemp data
soil$variables_10086[grep("soilMoisture", soil$variables_10086$fieldName), c("description", "units")]



## ----temp-rows---------------------------------------------------------------------------------------

# Merge microbial biomass and soil core data tables
coreMicrob <- merge(soil$sls_soilCoreCollection, microb$sme_scaledMicrobialBiomass, by="sampleID")

# Merge soil moisture table with microbial and core table
swcMicrob <- merge(soil$sls_soilMoisture, coreMicrob, by="sampleID")



## ----mb-temp-plot------------------------------------------------------------------------------------

# Identify the different soil plots represented in the table
soilPlots <- unique(swcMicrob$plotID)

# Create a color vector with a different color for each soil plot
colors <- rainbow(length(soilPlots))

# Identify rows that passed the QA/QC tests
goodRows <- grep("OK", swcMicrob$analysisResultsQF)

# Create an empty plotting window for the soil temperature and microbial biomass relationship
plot(swcMicrob$soilTemp, 
     swcMicrob$correctedTotLipidConc, 
     pch=NA, 
     xlab="Soil temperature (degrees C)", 
     ylab="Microbial biomass (nmol lipids/g soil)")

# Loop through the soil plots and add the temperature-microbial biomass relationship
for(i in 1:length(soilPlots)){
  points(swcMicrob$soilTemp[intersect(goodRows, grep(soilPlots[i], swcMicrob$plotID))], 
         swcMicrob$correctedTotLipidConc[intersect(goodRows, grep(soilPlots[i], swcMicrob$plotID))], 
         col=colors[i])
}

# Add a plot legend
legend("topleft", legend=soilPlots, col=colors, pch=1, bty="n")



## ----mb-swc-plot-------------------------------------------------------------------------------------

# Create an empty plotting window for the soil moisture and microbial biomass relationship
plot(swcMicrob$soilMoisture, 
     swcMicrob$correctedTotLipidConc, 
     pch=NA, 
     xlab="Soil moisture (g water / g soil)", 
     ylab="Microbial biomass (nmol lipids/g soil)")

# Loop through the soil plots and add the moisture-microbial biomass relationship
for(i in 1:length(soilPlots)){
  points(swcMicrob$soilMoisture[intersect(goodRows, grep(soilPlots[i], swcMicrob$plotID))], 
         swcMicrob$correctedTotLipidConc[intersect(goodRows, grep(soilPlots[i], swcMicrob$plotID))], 
         col=colors[i])
}

# Add a plot legend
legend("topleft", legend=soilPlots, col=colors, pch=1, bty="n")


