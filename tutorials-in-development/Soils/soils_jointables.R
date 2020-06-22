
library(neonUtilities)
library(dplyr)
library(tidyr)
library(ggplot2)
library(httr)

setwd()
# Possible TOS data products
dataProducts_OS<-character()
dataProducts_OS[1]<-"DP1.10086.001" #1 field collection and physical properties (mst and pH)
dataProducts_OS[2]<-"DP1.10078.001" #2 elemental chemical (C and N)
dataProducts_OS[3]<-"DP1.10100.001" #3 stable isotopes 
dataProducts_OS[4]<-"DP1.10067.001" #4 roots collection mass
dataProducts_OS[5]<-"DP1.10102.001" #5 roots chemical properties
dataProducts_OS[6]<-"DP1.10047.001" #6 Initial NRCS soil physical properties
dataProducts_OS[7]<-"DP1.10008.001" #7 Initial NRCS soil chemical properties
dataProducts_OS[8]<-"DP1.10108.001" #8 Microbe marker gene sequences
dataProducts_OS[9]<-"DP1.10104.001" #9 Soil microbe biomass
dataProducts_OS[10]<-"DP1.10033.001" #10 Litter field collection funcgroup mass
dataProducts_OS[11]<-"DP1.10031.001" #11 Litter chemical properties

site<-"all"
startdate <- "2014-01"
enddate <- "2019-12"

dpID<-dataProducts_OS[10]
View(getProductInfo(dpID))
loadeddata<-loadByProduct(dpID = dpID, site = site, startdate = startdate, enddate = enddate, token=token, check.size=TRUE)
list2env(loadeddata,.GlobalEnv)

# Possible TIS data products
dataProducts_IS<-character()
dataProducts_IS[1]<-"DP1.00041.001" #1 Soil temperature
dataProducts_IS[2]<-"DP1.00094.001" #2 Soil water content
dataProducts_IS[3]<-"DP1.00095.001" #3 CO2 concentration
dataProducts_IS[4]<-"DP1.00040.001" #4 Heat flux
dataProducts_IS[5]<-"DP1.00066.001" #5 PAR

site<-"all"
startdate <- "2019-03"
enddate <- "2019-09"

dpID<-dataProducts_IS[1]
View(getProductInfo(dpID))
sls_ISdata<-loadByProduct(dpID=dpID, site = site, startdate = startdate, enddate = enddate, avg="30", token=token, check.size=TRUE)

zipsDir
stackByTable(paste0(zipsDir,"/NEON_litterfall.zip"),savepath = zipsDir)

tablefiles<-table_types%>%
  filter(productID==dpID)%>%
  mutate(tablefile=paste0(zipsDir,"/stackedFiles/",tableName,".csv"))%>%
  filter(file.exists(tablefile))
# Construct a file path to the variable table csv and test it exists
varFile<-paste0(zipsDir,"/stackedFiles/variables_",substr(dpID,5,9),".csv")
if(file.exists(varFile)){
  # use sapply to run readTableNEON on each table csv, load into a list object
  # and read the variables table
  tables_dfs<-sapply(tablefiles$tablefile, readTableNEON, varFile=varFile, simplify = FALSE)
  tables_dfs[[varFile]]<-read.csv(varFile)
}
# name the list objects concisely, remove .csv and path
names(tables_dfs)<-gsub(".csv","",basename(names(tables_dfs)))
# Load the dataframes from the list as dataframe objects in the current env.
list2env(tables_dfs,.GlobalEnv)
stacked_files<-list.files(path = paste0(zipsDir,"/stackedFiles"),full.names = TRUE)

# make a function that joins the sampling data with the moisture and pH, 
# returning a joined table
sls_join_phys<-function(sls_list){
  slsm<-sls_list[["sls_soilMoisture"]]
  slsc<-sls_list[["sls_soilCoreCollection"]]
  slsp<-sls_list[["sls_soilpH"]]
  slsj <- slsc%>%
    left_join(slsm,by=c("sampleID","domainID","siteID","plotID","namedLocation","horizon"),suffix=c(".field",".moisture"))%>%
    left_join(slsp,by=c("sampleID","domainID","siteID","plotID","namedLocation","horizon"),suffix=c(".field",".pH"))
  return(slsj)
}

# join the field core data with mositure and pH and 
# remove final N transformation timepoint samples 
sls_scc_joined<-sls_join_phys(lst(sls_soilCoreCollection,sls_soilMoisture,sls_soilpH))%>%
  filter(tolower(nTransBoutType) !="tfinal")

# use summarise to get counts of NAs
# pivot and filter (ignore always and never NA variables) for readability
missing_data_scc<-sls_scc_joined%>%
  summarise(across(everything(),~sum(is.na(.))))%>%
  pivot_longer(everything())%>%
  filter(value>0,value!=nrow(sls_scc_joined))

sls_chemsummary<-sls_soilChemistry%>%
  pivot_longer(c(nitrogenPercent,organicCPercent,CNratio),
               names_to="chem_variable",values_to="value")%>%
  filter(!is.na(value),across(ends_with("QF"),~(.=="OK"|is.na(.))))%>%
  group_by(sampleID,cnSampleID,acidTreatment,chem_variable)%>%
  summarise(mean=mean(value), n=n(), .groups = "keep")%>%
  
  
sls_chem_joined<-sls_scc_joined%>%
  inner_join(sls_bgcSubsampling,by=c("sampleID","domainID","siteID","plotID","namedLocation","horizon"))%>%
  select(sampleID,domainID,siteID,plotID,collectDate=collectDate.field)%>%
  inner_join(sls_chemsummary,by="sampleID", suffix=c(".phys",".chem"))

ggplot(sls_chem_joined,
       aes(x=organicCPercent,
           y=nitrogenPercent,
           color=horizon))+
  facet_wrap(~siteID)+
  geom_point()+
  geom_vline(xintercept = 20,size=2,color="blue")+
  scale_color_manual(values=c("O"="blue","M"="red"))+
  xlab("% Organic Carbon") + ylab("% Total Nitrogen")

