# This script contains a suite of functions that download AOP L3 data, merge the
# tiles into a full-site raster, and write out theraster data to a geotiff and
# cloud-optimized geotiff (COG)."

# example execution:
# makeFullSiteMosaics('DP3.30024.001','2021','MCRA','c:/neon/data','c:/neon/outputs/2021_MCRA/DEMs',apiToken="your_api_token")
# makeFullSiteMosaics("DP3.30015.001",'2019','CHEQ','c:/neon/data','c:/neon/outputs/2019_CHEQ/CHM')

# Load required packages
library(neonUtilities)
library(raster)
library(gdalUtilities)
library(data.table)
library(docstring)

##----------------------------------------------------------------------------##

#create a lookup data table linking data product, sensor, and download path
lookupTable = data.table(
  dpID = c("DP3.30010.001","DP3.30011.001","DP3.30012.001","DP3.30014.001",
           "DP3.30015.001","DP3.30019.001","DP3.30024.001","DP3.30024.001",
           "DP3.30025.001","DP3.30025.001","DP3.30026.001"),
  sensor = c("Camera",
             "Spectrometer",
             "Spectrometer",
             "Spectrometer",
             "DiscreteLidar",
             "Spectrometer",
             "DiscreteLidar",
             "DiscreteLidar",
             "DiscreteLidar",
             "DiscreteLidar",
             "Spectrometer"),
  dpName = c("image","albedo","LAI","fPAR","CHM","WaterIndices","DTM","DSM",
             "slope","aspect","VegetationIndices"),
  path = c("L3/Camera/Mosaic",
           "L3/Spectrometer/Albedo",
           "L3/Spectrometer/LAI",
           "L3/Spectrometer/FPAR",
           "L3/DiscreteLidar/CanopyHeightModelGtif",
           "L3/Spectrometer/WaterIndices",
           "L3/DiscreteLidar/DTMGtif",
           "L3/DiscreteLidar/DSMGtif",
           "L3/DiscreteLidar/SlopeGtif",
           "L3/DiscreteLidar/AspectGtif",
           "L3/Spectrometer/VegIndices"),
  errorTifs = c(FALSE,FALSE,TRUE,TRUE,FALSE,TRUE,FALSE,FALSE,FALSE,FALSE,TRUE),
  zipped = c(FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,FALSE,FALSE,TRUE)
)

#function to make a new directory, only if it doesn't exist
makeDir <- function(directory) {
  if (!dir.exists(directory)) {
    dir.create(directory,recursive=TRUE)
  }
}

#function to check that the dpID is valid (within the lookup table)
checkdpID <- function(dpID) {
  if (!(dpID %in% lookupTable$dpID)) {
    cat('The dpID is not valid. Please select one of the following dpIDs:\n')
    print(lookupTable[, 1:3][order(sensor,dpID)])
    stop('ERROR! Invalid dpID')
    }
}

#function to get the data paths given the dpID
getDataPaths <- function(dpID) {
  match = tolower(lookupTable$dpID) == tolower(dpID)
  dataPaths = lookupTable[match, path]
  return(dataPaths)
}

#function to get the data abbreviation from the dpID
getDataAbbr <- function(dpID) {
  match = tolower(lookupTable$dpID) == tolower(dpID)
  dataAbbr = lookupTable[match, dpName]
  return(dataAbbr)
}

#function to get the data extensions from the dpID
getDataExts <- function(dpID) {
  match = tolower(lookupTable$dpID) == tolower(dpID)
  hasErrorTifs <- unique(lookupTable[match, errorTifs])
  isZipped <- unique(lookupTable[match,zipped])
  if (isZipped == 'FALSE') {
    dpEnding <- lookupTable[match, dpName]
    if (hasErrorTifs == 'TRUE') {
      dataExts = c(paste0(dpEnding,'.tif'),paste0(dpEnding,'_error.tif'))
    } else {
      dataExts = paste0(dpEnding,'.tif')
    }
  }
  if (dpID == 'DP3.30026.001') {
    dataExts = c('ARVI.tif','ARVI_error.tif',
                 'EVI.tif','EVI_error.tif',
                 'NDVI.tif','NDVI_error.tif',
                 'PRI.tif','PRI_error.tif',
                 'SAVI.tif','SAVI_error.tif')
  }
  if (dpID == 'DP3.30019.001') {
    dataExts = c('MSI.tif','MSI_error.tif',
                 'NDII.tif','NDII_error.tif',
                 'NDWI.tif','NDWI_error.tif',
                 'NMDI.tif','NMDI_error.tif',
                 'WBI.tif','WBI_error.tif')
  }
  return(dataExts)
}

#function to get a list of the directories with L3 geotiff data
getDownloadDirs <- function(wd,siteCode,dpID,year) {
  downloadDirs <- list.dirs(file.path(wd,dpID,"neon-aop-products",year,"FullSite"),recursive=TRUE)
  return(downloadDirs)
}

#function to get the unique year-site-visits -- usually there is only one visit per year, 
#but occasionally there may be more than one visit in the same year.
#this handles the general case of any # of visits per year
getYearSiteVisits <- function(downloadDirs,siteCode) {
  yearSiteVisits <- c()
  for(i in 1:length(downloadDirs)) {
    dirParts <- unlist(strsplit(downloadDirs[[i]],.Platform$file.sep))
    ## The next line worked when using dataDirs, but less efficient when using allDownloadDirs, see if there's a better way to do this
    ysv <- dirParts[length(dirParts)-3] 
    if (grepl(siteCode,ysv)) {yearSiteVisits <- append(yearSiteVisits, ysv)} else {next}
  }
  return(unique(yearSiteVisits))
}

#function to get the directories containing data
getDataDirs <- function(dataRootDir,siteCode,dpID,downloadDirs) {
  dataPaths <- getDataPaths(dpID)
  yearSiteVisits <- getYearSiteVisits(downloadDirs,siteCode)
  dataDirs <- c()
  for (i in 1:length(dataPaths)) {
    for (j in 1:length(yearSiteVisits)) {
      dataDir <-  grep(glob2rx(paste0(dataRootDir,"*",yearSiteVisits[j],"/",dataPaths[i])), downloadDirs, value = TRUE)
      if (length(dataDir)==0) {next} else {dataDirs <- append(dataDirs, dataDir)}
    }
    
  }
  return(dataDirs)
}

#function to get the data tiles by extension
getDataTilesByExt <- function(dataDirs,dataExts) {
  dataTiles <- list()
  for(i in 1:length(dataDirs)) {
    for(j in 1:length(dataExts)) {
      dataTileList <- list.files(dataDirs[i],pattern=dataExts[j],full.names=TRUE,ignore.case=TRUE)
      if (length(dataTileList)==0) {next} else {dataTiles[[(length(dataTiles) + 1)]] <- dataTileList}
    }
  }
  return(dataTiles)
}

#function to get all the zipped folders (for water and vegetation indices)
getZippedFolders <- function(dataDirs) {
  zipFolders <- list()
  for(i in 1:length(dataDirs)) {
    dirParts <- unlist(strsplit(dataDirs[[i]],.Platform$file.sep))
    zipFolders[[i]] = list.files(dataDirs[i],pattern='.zip',full.names=TRUE)
  }
  return(zipFolders)
}

#function to unzip folders
unzipFolders <- function(zippedFolders,outDir) {
  mapply(unzip, zipfile = zippedFolders, exdir = outDir)
}

#function to merge all data tiles
mergeDataTiles <- function(dataTiles) {
  rasters <- lapply(dataTiles,FUN=brick)
  sprintf('Merging tiled rasters')
  fullMosaic <- do.call(merge, c(rasters, tolerance = 1))
  return(fullMosaic)
}

#function to write raster to geotiff file
writeFullMosaicTif <- function(fullMosaic,outFileDir,outFileTif) {
  sprintf('Writing geotiff %s',outFileTif)
  makeDir(outFileDir)
  writeRaster(fullMosaic,file=file.path(outFileDir,outFileTif), format="GTiff", overwrite=TRUE)
}

#function to convert geotiff to cloud-optimized geotiff
convertTif2Cog <- function(outFileDir,inFileTif,outFileCog) {
  # sprintf('Converting geotiff %s to COG: %s',inFileTif,outFileCog)
  gdalUtilities::gdal_translate(src_dataset = file.path(outFileDir,inFileTif),
                                dst_dataset = file.path(outFileDir,outFileCog),
                                co = matrix(c("TILED=YES",
                                              "COPY_SRC_OVERVIEWS=YES",
                                              "COMPRESS=DEFLATE"),
                                            ncol = 1))
}

#function that generates the full site mosaic for any of the AOP L3 raster tifs:
makeFullSiteMosaics <- function(dpID,year,siteCode,dataRootDir,outFileDir,apiToken=NULL) {
  #' Download all AOP files for a given site, year, and L3 product, mosaic the files, and save the full site mosaic to a tiff and cloud-optimized geotiff.
  #'
  #' This function 1) Runs the neonUtilities byFileAOP function to download NEON 
  #' AOP data by site, year, and product (see byFileAOP documention for additional details). 
  #' 2) merges the raster tiles into a full-site mosaic, as well as the 
  #' associated error tifs, where applicable, and 3) saves the full site mosaics 
  #' to a tif and cloud-optimized geotiff.
  #' 
  #' @param dpID The identifier of the AOP data product to download, in the form DP3.PRNUM.REV, e.g. DP3.30011.001. This works for all AOP L3 rasters except L3 reflectance. If an invalid data product ID is provided, the code will show an error message and display the valid dpIDs.
  #' @param year The four-digit year to search for data.
  #' @param siteCode The four-letter code of a single NEON site, e.g. 'MCRA'.
  #' @param dataRootDir The file path to download data to. 
  #' @param outFileDir The file path where the full-site mosaic geotiffs and cloud-optimized geotiffs are saved.
  #' @param apiToken User specific API token (generated within neon.datascience user accounts). If not provided, no API token is used.
  #' @return description
  
  cat('Generating full-site mosaic(s)\n')
  cat(paste('dpID: ',dpID,'\n'))
  cat(paste('year: ',year,'\n'))
  cat(paste('site: ',siteCode,'\n'))
  
  #check that dpID is valid (if dpID is not valid, this will display error message and exit the script)
  checkdpID(dpID)
  #download dpID for that site and year
  makeDir(dataRootDir)
  
  if (is.null(apiToken)) {
    byFileAOP(dpID, site=siteCode,year=year,check.size=F,savepath=dataRootDir)} 
  else {
    byFileAOP(dpID, site=siteCode,year=year,check.size=F,savepath=dataRootDir,token=apiToken)}
  
  dataPaths <- getDataPaths(dpID)
  dataAbbrs <- getDataAbbr(dpID)
  cat('Data Name(s):\n')
  cat(dataAbbrs,sep='\n')
  dataExts <- getDataExts(dpID)
  downloadDirs <- getDownloadDirs(dataRootDir,siteCode,dpID,year)
  # allDownloadDirs <- unique(dirname(list.files(file.path(dataRootDir,dpID,'neon-aop-products',year),rec=T))) #only list folders with files
  # cat('All download folders:\n')
  # print(allDownloadDirs[2:length(allDownloadDirs)])
  dataDirs <- getDataDirs(dataRootDir,siteCode,dpID,downloadDirs)
  cat('Data directories:\n')
  cat(dataDirs,sep='\n')

  # if data product is veg indices or water indices, unzip first
  if (dpID == "DP3.30019.001" | dpID == "DP3.30026.001") {
    cat('Unzipping folders\n')
    zippedDataFolders <- getZippedFolders(dataDirs)
    for (i in 1:length(zippedDataFolders)) {
      mapply(unzip, zipfile = zippedDataFolders[[i]], exdir = dataDirs[[i]])
    }
  }
  
  #get the list of dataTiles for each data directory and extension
  dataTiles <- getDataTilesByExt(dataDirs,dataExts)
  
  cat('Creating full site mosaics\n')
  fullMosaics <- list()
  fullMosaicNames <- list()
  for (i in 1:length(dataTiles)) {
    fullMosaics[[i]] <- mergeDataTiles(dataTiles[[i]])
    dataDirSplit <- unlist(strsplit(dataTiles[[i]][1],.Platform$file.sep))
    tileNameSplit <- unlist(strsplit(dataTiles[[i]][1],'_'))
    if (tail(tileNameSplit,1)=='error.tif') {
      fullMosaicNames[[i]] <- paste0(dataDirSplit[9],'_',tail(tileNameSplit,n=2)[1],'_error.tif')} 
    else {
      fullMosaicNames[[i]] <- paste0(dataDirSplit[9],'_',tail(tileNameSplit,n=1))}
  }
  
  cat('Writing full mosaics to Geotiffs and Cloud-Optimized Geotiffs\n')
  makeDir(outFileDir)
  for (i in 1:length(fullMosaics)) {
    outFileTif <- fullMosaicNames[[i]]
    cat(paste0('Generating ',outFileTif,'\n'))
    writeFullMosaicTif(fullMosaics[[i]],outFileDir,outFileTif)
    # name the COG file the same as tif but with COG suffix
    outFileCog <- gsub(".tif", "_COG.tif", outFileTif) 
    cat(paste0('Generating ',outFileCog,'\n'))
    convertTif2Cog(outFileDir,outFileTif,outFileCog)
  }
} 