## ----setup, eval=c(9,10,11), results="hide"--------------------------------------------------------------

# install packages. you can skip this step if 
# the packages are already installed
install.packages("neonUtilities")
install.packages("neonOS")
install.packages("ggplot2")

# load packages
library(neonUtilities)
library(neonOS)
library(ggplot2)



## ----load-data, results="hide"---------------------------------------------------------------------------

apchem <- loadByProduct(dpID="DP1.20063.001", 
                        site=c("PRLA","SUGG","TOOK"), 
                        package="expanded",
                        release="RELEASE-2022",
                        check.size=F)



## ----env, results="hide"---------------------------------------------------------------------------------

list2env(apchem, .GlobalEnv)



## ----remove-dups-biomass---------------------------------------------------------------------------------

apl_biomass <- removeDups(data=apl_biomass, 
                          variables=variables_20063)



## ----view-flag-values------------------------------------------------------------------------------------

unique(apl_biomass$duplicateRecordQF)



## ----remove-dups-analytes, results="hide"----------------------------------------------------------------

apl_plantExternalLabDataPerSample <- removeDups(
  data=apl_plantExternalLabDataPerSample, 
  variables=variables_20063)



## ----view-resolved---------------------------------------------------------------------------------------

apl_plantExternalLabDataPerSample[which(
  apl_plantExternalLabDataPerSample$duplicateRecordQF==1),]



## ----view-unresolved-------------------------------------------------------------------------------------

apl_plantExternalLabDataPerSample[which(
  apl_plantExternalLabDataPerSample$duplicateRecordQF==2),]



## ----join, results="hide"--------------------------------------------------------------------------------

aqbc <- joinTableNEON(apl_biomass,
                      apl_plantExternalLabDataPerSample)



## ----aqbc-check------------------------------------------------------------------------------------------

nrow(apl_biomass)
nrow(apl_plantExternalLabDataPerSample)
nrow(aqbc)



## ----aqbc-view, results="hide"---------------------------------------------------------------------------

View(aqbc)



## ----aq-fig----------------------------------------------------------------------------------------------

gg <- ggplot(subset(aqbc, analyte=="nitrogen"),
             aes(scientificName, analyteConcentration, 
                 group=scientificName, 
                 color=scientificName)) +
             geom_boxplot() + 
             facet_wrap(~siteID) +
        theme(axis.text.x=element_text(angle=90,
                                       hjust=1,
                                       size=4)) +
        theme(legend.position="none") +
        ylab("Nitrogen (%)") + 
        xlab("Scientific name")
gg



## ----with-table-names, results="hide"--------------------------------------------------------------------

bio.dup <- removeDups(data=apchem$apl_biomass,
                      variables=apchem$variables_20063,
                      table="apl_biomass")
chem.dup <- removeDups(data=apchem$apl_plantExternalLabDataPerSample,
                      variables=apchem$variables_20063,
                      table="apl_plantExternalLabDataPerSample")
aq.join <- joinTableNEON(table1=bio.dup, 
                         table2=chem.dup,
                         name1="apl_biomass",
                         name2="apl_plantExternalLabDataPerSample")



## ----load-mos, results="hide"----------------------------------------------------------------------------

mos <- loadByProduct(dpID="DP1.10043.001",
                     site="TOOL", 
                     release="RELEASE-2022",
                     check.size=F)
list2env(mos, .GlobalEnv)



## ----try-join-mos, eval=FALSE----------------------------------------------------------------------------
## 
## mos.sp <- joinTableNEON(mos_trapping,
##                         mos_expertTaxonomistIDProcessed)
## 


## ----join-trap-sort, results="hide"----------------------------------------------------------------------

mos.trap <- joinTableNEON(mos_trapping,
                          mos_sorting)



## ----join-sort-tax, results="hide"-----------------------------------------------------------------------

mos.tax <- joinTableNEON(mos.trap,
                         mos_expertTaxonomistIDProcessed,
                         name1="mos_sorting")



## ----mos-fig---------------------------------------------------------------------------------------------

gg <- ggplot(mos.tax, 
             aes(scientificName, individualCount, 
                 group=scientificName, 
                 color=scientificName)) +
             geom_boxplot() + 
        facet_wrap(~nlcdClass) +
        theme(axis.text.x=element_blank()) +
        ylab("Count") +
        xlab("Scientific name")
gg


