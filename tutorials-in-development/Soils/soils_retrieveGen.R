#' @title Download soil microbial metadata and sequence data
#' @author
#' Lee Stanish and Ben Shetterly \email{lstanish@battelleecology.org} \cr
library(neonUtilities)
library(dplyr)
library(httr)

dpID<-"DP1.10086.001" #For field collection and physical properties (mst and pH)
dpID<-"DP1.10078.001" #For elemental chemical (C and N)
dpID<-"DP1.10108.001" #For microbe genetic markers
site<-"all"
startdate <- "2016-01"
enddate <- "2017-01"
View(getProductInfo(dpID))
# Set a directory to load and stack data files
stackingDir='C:/Users/envie/Downloads/NEON 2020/SoilDataTutorial' # update for your directory, DO NOT include a slash at the end
setwd(stackingDir)

# Here, we use zipsByProduct and stackByTable,
# this way the data files are saved in files and prepared for zipsByURI function

if(dir.exists(paste0(stackingDir,"/filesToStack",substr(dpID,5,9)))){
  print("This data product may have downloaded, stacked files already in this directory.")
} else {
  zipsByProduct(dpID=dpID,savepath = stackingDir,site=site, startdate=startdate, enddate=enddate, package="expanded", check.size=TRUE, token=token)
  zipsDir<-paste0(stackingDir,"/filesToStack",substr(dpID,5,9))
  # Stack the zipped files into .csv tables
  stackByTable(filepath = zipsDir)
  # Import the data .csv files into R data frames, using the "table_types"
  # table to filter for the appropriate files. 
  # First use of dplyr verbs.  
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
}

# subset soilCoreCollect data, excluding "tfinal" Ntrans bouts, not used here
sls_scc_init<-sls_soilCoreCollection%>%
  data.frame%>%
  filter(tolower(nTransBoutType)!="tfinal")

# filter and prepare soil microbe data 
# DNA extraction
mmg_dnaex <- mmg_soilDnaExtraction%>%
  filter(grepl("marker gene|marker gene and metagenomics",sequenceAnalysisType))%>%
  mutate(dnaSampleID=toupper(dnaSampleID))

# 16S sequencing metadata
mmg_marker_16S <- mmg_soilMarkerGeneSequencing_16S%>%
  mutate(dnaSampleID=toupper(dnaSampleID))

# ITS sequencing metadata
mmg_marker_ITS <- mmg_soilMarkerGeneSequencing_ITS%>%
  mutate(dnaSampleID=toupper(dnaSampleID))

# Upon testing, found some raw data files are not available (404 response)
# at the URLs given in mmg_soilRawDataFiles table.
# initialize a table with all unique urls, then fill with data availability
# use a loop to retreive each header status code
rawfile_status<-data.frame(uri=unique(mmg_soilRawDataFiles$rawDataFilePath),
                       rawdata_available=NA)
for(u in rawfile_status$uri){
  r<-httr::HEAD(u)
  if(httr::status_code(r) == 200) a<-TRUE else a<-FALSE
  rawfile_status[rawfile_status$uri==u,]$rawdata_available <- a
  rm(r,a)
}
# 16S rawDataFiles metadata - this contains URLs to sequence data
# filter these so only raw data available are kept
# also can ensure the DNA sample ID is distinct, but not sure why this is needed here
mmg_raw16S<-mmg_soilRawDataFiles%>%
  filter(grepl("16S",rawDataFileName),
         rawDataFilePath %in% (rawfile_status%>%filter(rawdata_available)%>%.$uri))
  # distinct(dnaSampleID,.keep_all = TRUE)

# ITS rawDataFiles metadata - this contains URLs to sequence data
mmg_rawITS<-mmg_soilRawDataFiles%>%
  filter(grepl("ITS",rawDataFileName),
         rawDataFilePath %in% (rawfile_status%>%filter(rawdata_available)%>%.$uri))
  # distinct(dnaSampleID,.keep_all = TRUE)

# prepare for raw data download
if(!dir.exists(paste0(stackingDir, '/mmg')) ) {
  dir.create(paste0(stackingDir, '/mmg'))
}
outDir<-list.dirs(stackingDir)[grep("/mmg$",list.dirs(stackingDir))]

targetGene <- '16S'  # change to ITS if you want the ITS data instead
## NEXT LINE ONLY USED IN TESTING ZIPSBYURI
mmg_raw16S<-mmg_raw16S[length(mmg_raw16S$rawDataFilePath),] #Subsetting for testing because raw genome data are very large files


if(targetGene=="16S") {
  write.csv(mmg_raw16S, file=paste0(outDir, "/mmg_soilrawDataFiles.csv"), row.names=FALSE)
}
if(targetGene=="ITS") {
  write.csv(mmg_rawITS, file=paste0(outDir,  "/mmg_soilrawDataFiles.csv"), row.names=FALSE)
}

# If variables file is not available or is not for soil raw gene sequence files,
# write the variables data frame to file; zipsByURI requires it
if(!file.exists(varFile) | !grepl("variables_10108.csv$",varFile)){
  write.csv(variables_10108, file=paste0(outDir, "/variables.csv"), row.names=FALSE)
} else file.copy(from=varFile, to = paste0(outDir,"/variables.csv")) #variables file needs to be in same directory and named "variables.csv"

# Download sequence data (lots of storage space needed!)
zipsByURI(filepath = outDir, savepath = outDir, unzip = FALSE, saveZippedFiles = TRUE)
