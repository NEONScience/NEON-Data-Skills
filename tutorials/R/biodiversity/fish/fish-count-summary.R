## ----load-packages, , message=FALSE, warning=FALSE, results="hide"----
library(neonUtilities)
library(ggplot2)
library(dplyr)
library(tidyr)


## ----fshdat, results='hide', message=FALSE---------
fshdat <- neonUtilities::loadByProduct(
  dpID="DP1.20107.001",
  site=c("BLUE", "CRAM"),
  package="basic",
  check.size = FALSE,
  startdate = "2024-01",
  enddate = "2024-12",
  release = 'RELEASE-2026')


## ----download-overview, message=FALSE, warning=FALSE----
# View all tables in the list of downloaded fish data:
names(fshdat)


## ----download-extract, results="hide"--------------
list2env(fshdat, envir=.GlobalEnv)


## ----quality-checks-bulkcount, results="hide"------
bulkCount_count <- fsh_bulkCount %>% 
  select(eventID, boutEndDate,  passNumber, scientificName, taxonID, namedLocation, bulkFishCount) %>%
  group_by(eventID, boutEndDate, passNumber, namedLocation, scientificName, taxonID) %>%
  count()

unique(bulkCount_count$n)


## ----quality-checks-bulkcount-summary, echo=FALSE----
cat('Number of bulk count records for each taxonID and pass:', unique(bulkCount_count$n))


## ----subset-data, results="hide"-------------------
bulkCount_sub <- fsh_bulkCount %>% 
  select(eventID, passStartTime, passEndTime, boutEndDate,
         passNumber, namedLocation, barrierSubReach, 
         scientificName, taxonID, bulkFishCount)


## ----tally-per-fish-individuals, results="hide"----
perFish_total <- fsh_perFish %>%
  select(eventID, passStartTime, passEndTime, boutEndDate, passNumber, 
         namedLocation, barrierSubReach, scientificName, taxonID) %>%
  group_by(eventID, passStartTime, passEndTime, boutEndDate, passNumber, 
         namedLocation, barrierSubReach, scientificName, taxonID) %>%
  count(name = 'individualFishCount')


## ----table-join, results="hide"--------------------
fsh_all <- perFish_total %>%
  full_join(., bulkCount_sub, by=c('eventID', 'passStartTime', 'passEndTime', 
                                   'boutEndDate', 'passNumber', 
                                   'namedLocation', 'barrierSubReach', 
                                   'scientificName', 'taxonID'))


## ----total-captures, results="hide"----------------
fsh_all <- fsh_all %>%  
  mutate(
    totalFishCount = rowSums(across(c(individualFishCount, bulkFishCount)), na.rm = TRUE))


## ----passes-comparison-blue, message=FALSE, fig.width=12, fig.height=7----
# Subset summary data by eventID
blue_spring24 <- fsh_all %>%
  filter(eventID == "BLUE.2024.spring")


## ----passes-plot, message=FALSE, fig.width=12, fig.height=7----
# Plot total captures by pass number and species
ggplot(blue_spring24, aes(x = scientificName, y = totalFishCount, fill = factor(passNumber))) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  facet_wrap(. ~ namedLocation, scales = "free")+
  labs(title = "Fish Captures Across Sampling Passes: Blue River Spring 2024",
       x = "Species",
       y = "Total Fish Count",
       fill = "Pass Number") +
  theme_minimal() +
  theme(legend.position = "bottom")


## ----cram-pass-metadata, message=FALSE-------------
# Filter field data to desired eventID and view fixed vs. random reaches
fixedRandomReach <- fsh_fieldData %>% 
  filter(eventID=="CRAM.2024.fall") %>% 
  select(eventID, namedLocation, fixedRandomReach, samplingImpractical) %>% 
  arrange(namedLocation)

print(fixedRandomReach)
  
samplerType <- fsh_perPass %>% 
  filter(eventID== "CRAM.2024.fall") %>%
  select(eventID, namedLocation, passNumber, samplerType) %>% 
  arrange(namedLocation, passNumber)
        
print(samplerType)


## ----passes-comparison-cram, message=FALSE, fig.width=12, , fig.height=6----
# Subset summary data by eventID
cram_fall24 <- fsh_all %>%
  filter(eventID == "CRAM.2024.fall")


## ----passes-cram-plot, message=FALSE, fig.width=12, , fig.height=6----
# Plot total captures by pass number and species
ggplot(cram_fall24, aes(x = scientificName, y = totalFishCount, fill = factor(passNumber))) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  facet_wrap(. ~ namedLocation)+
  labs(title = "Fish Captures Across Sampling Passes: Crampton Lake Fall 2024",
       x = "Species",
       y = "Total Fish Count",
       fill = "Pass Number") +
  theme_minimal() +
  theme(legend.position = "bottom")


## ----richness-by-site, message=FALSE---------------
richness_by_event <- fsh_all %>%
  select(eventID, scientificName) %>%
  group_by(eventID) %>%
  distinct(scientificName) %>%
  summarise(numSpecies = n()) %>%
  arrange(-numSpecies)


## ----richness-by-site-graph------------------------
ggplot(richness_by_event, aes(x = eventID, y = numSpecies)) +
        geom_bar(stat = "identity") +
        scale_x_discrete(limits = richness_by_event$eventID) +
        theme(axis.text.x = element_text(angle = 90)) +
        scale_y_continuous(breaks = seq(from = 0, to = 30, by = 2)) +
        labs(
          title = "Total Species Richness by EventID",
          x = "Event ID",
          y = "Number of Species"
        )

