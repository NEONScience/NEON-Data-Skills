## ----setup, eval=FALSE-------------------------------------------------------------------------------
# 
# # install packages. can skip this step if
# # the packages are already installed
# install.packages("neonUtilities")
# install.packages("neonOS")
# install.packages("lubridate")
# install.packages("ggplot2")
# install.packages("dplyr")
# install.packages("visNetwork")
# 
# # load packages
# library(neonUtilities)
# library(neonOS)
# library(ggplot2)
# library(lubridate)
# library(dplyr)
# library(visNetwork)
# 


## ----libraries, include=FALSE, results="hide"--------------------------------------------------------

library(neonUtilities)
library(neonOS)
library(ggplot2)
library(lubridate)
library(dplyr)
library(visNetwork)



## ----load-data, results="hide"-----------------------------------------------------------------------

soil <- loadByProduct(dpID="DP1.10086.001", 
                     site="SOAP",
                     startdate="2018-01",
                     enddate="2024-12",
                     include.provisional=T,
                     progress=F,
                     check.size=F)

list2env(soil, .GlobalEnv)



## ----dups--------------------------------------------------------------------------------------------

moisturedups <- removeDups(sls_soilMoisture, 
                           variables_10086)

chemdups <- removeDups(sls_soilChemistry,
                       variables_10086)



## ----join-chem-moist---------------------------------------------------------------------------------

moistchem <- joinTableNEON(sls_soilMoisture,
                           sls_soilChemistry)



## ----plot-chem-moist---------------------------------------------------------------------------------

plot(nitrogenPercent~soilMoisture, 
     data=moistchem,
     pch=20)



## ----soap-fire---------------------------------------------------------------------------------------

sim <- byEventSIM("fire", site="SOAP")

sim$sim_eventData



## ----chem-dates--------------------------------------------------------------------------------------

unique(year(sls_soilChemistry$collectDate))



## ----plot-time---------------------------------------------------------------------------------------

plot(nitrogenPercent~soilMoisture, 
     data=moistchem[which(year(moistchem$collectDate.y)==2018),],
     pch=20)
points(nitrogenPercent~soilMoisture, 
     data=moistchem[which(year(moistchem$collectDate.y)==2024),],
     pch=20, col="red")



## ----load-microbe-data, results="hide"---------------------------------------------------------------

micro <- loadByProduct(dpID="DP1.10081.002", 
                     site="SOAP",
                     startdate="2018-05",
                     enddate="2024-12",
                     package="expanded",
                     include.provisional=T,
                     progress=F,
                     check.size=F)

list2env(micro, .GlobalEnv)



## ----plot-microbe-data-------------------------------------------------------------------------------

gg <- ggplot(mct_soilPerSampleTaxonomy_ITS, aes(phylum, individualCount)) +
  geom_col() +
  theme(axis.text.x = element_text(angle = 90))
gg



## ----microbe-dates-----------------------------------------------------------------------------------

unique(year(mct_soilSampleMetadata_ITS$collectDate))



## ----get-sample-tree-1-------------------------------------------------------------------------------

samp <- getSampleTree(sls_soilCoreCollection$sampleID[1])
edges <- data.frame(cbind(to=samp$sampleUuid, from=samp$parentSampleUuid))
nodes <- data.frame(cbind(id=samp$sampleUuid, label=samp$sampleTag))
visNetwork(nodes, edges) |>
  visEdges(arrows="to")



## ----get-sample-tree-2-------------------------------------------------------------------------------

samp <- getSampleTree(sls_soilCoreCollection$sampleID[2])
edges <- data.frame(cbind(to=samp$sampleUuid, from=samp$parentSampleUuid))
nodes <- data.frame(cbind(id=samp$sampleUuid, label=samp$sampleTag))
visNetwork(nodes, edges) |>
  visEdges(arrows="to")


