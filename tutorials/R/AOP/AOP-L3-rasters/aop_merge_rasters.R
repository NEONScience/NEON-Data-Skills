## ----set-working-directory,message=FALSE,warning=FALSE-----------------------------------------------------------
# change the wd depending on your local environment
wd <- file.path(path.expand("~"),"GitHubRepos","NEON-Data-Skills","tutorials","R","AOP","AOP-L3-rasters") 
setwd(wd)


## ----source-aop-mosaic-rasters,message=FALSE,warning=FALSE-------------------------------------------------------
source("./aop_merge_raster_functions.R")


## ----help-makeFullSiteMosaics,eval=F-----------------------------------------------------------------------------
## help(makeFullSiteMosaics)


## ----display-neon-token-file,eval=F------------------------------------------------------------------------------
## NEON_TOKEN <- "MY TOKEN"


## ----source-api-token,message=FALSE,warning=FALSE----------------------------------------------------------------
source(paste0(wd,"/neon_token.R"))


## ----get-timeout-------------------------------------------------------------------------------------------------
timeout0 <- getOption('timeout')
print(timeout0)


## ----set-timeout-------------------------------------------------------------------------------------------------
options(timeout=300)
getOption('timeout')


## ----set-data-folders,message=FALSE,warning=FALSE----------------------------------------------------------------
download_folder <- 'c:/neon/data'
chm_output_folder <- 'c:/neon/outputs/2021_MCRA/CHM/'


## ----run-mcra-2021-chm,eval=T,results=FALSE,message=FALSE,warning=FALSE------------------------------------------
makeFullSiteMosaics('DP3.30015.001','2021','MCRA',download_folder,chm_output_folder,NEON_TOKEN)


## ----list-chm-output-files---------------------------------------------------------------------------------------
list.files(chm_output_folder)


## ----plot-chm-full-mosaic,message=FALSE,warning=FALSE------------------------------------------------------------
MCRA_CHM <- raster(file.path(chm_output_folder,'2021_MCRA_2_CHM.tif'))
plot(MCRA_CHM,main="2021_MCRA_2 Canopy Height Model") # add title with main)


## ----set-veg-indices-output-folder-------------------------------------------------------------------------------
veg_indices_output_folder<-'c:/neon/outputs/2021_MCRA/VegIndices/'


## ----run-mcra-2021-veg-indices,eval=T,results=FALSE,message=FALSE,warning=FALSE----------------------------------
makeFullSiteMosaics('DP3.30026.001','2021','MCRA',download_folder,veg_indices_output_folder,NEON_TOKEN)


## ----list-veg-indices-output-files-------------------------------------------------------------------------------
list.files(veg_indices_output_folder)


## ----read-ndvi-full-mosaics,message=FALSE,warning=FALSE----------------------------------------------------------
MCRA_NDVI <- raster(file.path(veg_indices_output_folder,'2021_MCRA_2_NDVI.tif'))
MCRA_NDVI_error <- raster(file.path(veg_indices_output_folder,'2021_MCRA_2_NDVI_error.tif'))


## ----plot-mcra-ndvi----------------------------------------------------------------------------------------------
plot(MCRA_NDVI,main="2021_MCRA_2 NDVI")


## ----plot-mcra-ndvi-error----------------------------------------------------------------------------------------
plot(MCRA_NDVI_error,main="2021_MCRA_2 NDVI Error") 


## ----change-timeout-back-----------------------------------------------------------------------------------------
options(timeout=timeout0)
getOption('timeout')

