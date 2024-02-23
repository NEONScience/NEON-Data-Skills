## ----import-libraries, results="hide"----------------------------------------------------------------------------------------------------------------------
library(neonUtilities)
library(geoNEON)
library(ggplot2)
library(data.table)
library(dplyr)
library(rhdf5)
library(terra)


## ----field-spectra-info------------------------------------------------------------------------------------------------------------------------------------
field_spectra_info <- neonUtilities::getProductInfo('DP1.30012.001')
field_spectra_info$siteCodes$siteCode
#View(field_spectra_info$siteCodes)
#View(field_spectra_info$siteCodes$availableDataUrls)


## ----load-field-spectra, results="hide"--------------------------------------------------------------------------------------------------------------------
field_spectra <- loadByProduct(dpID='DP1.30012.001',
                              site='RMNP',
                              package="expanded",
                              check.size=FALSE)


## ----field-spectra-names-----------------------------------------------------------------------------------------------------------------------------------
names(field_spectra)


## ----merge-data-metadata-----------------------------------------------------------------------------------------------------------------------------------
spectra_merge <- merge(field_spectra$fsp_spectralData,field_spectra$fsp_sampleMetadata,by="spectralSampleID") 


## ----spectra_merge-colnames--------------------------------------------------------------------------------------------------------------------------------
colnames(spectra_merge)
head(spectra_merge[c("spectralSampleID","downloadFileUrl")])


## ----show-data-url-----------------------------------------------------------------------------------------------------------------------------------------
spectra_merge[1,]$spectralSampleID
spectra_merge[1,]$downloadFileUrl
spectra_merge[1,]$taxonID


## ----read-single-csv---------------------------------------------------------------------------------------------------------------------------------------
FSP_RMNP_20200706_2043 <- read.csv("https://storage.neonscience.org/neon-os-data/data-frame/FSP_RMNP_20200706_204320201221T201729.461Z.csv")


## ----unique-refl-conditions--------------------------------------------------------------------------------------------------------------------------------
unique(FSP_RMNP_20200706_2043$reflectanceCondition)


## ----plot-reflectance-conditions, fig.align="center", fig.width = 12, fig.height = 4.5---------------------------------------------------------------------
refl_conditions_plot <- ggplot(FSP_RMNP_20200706_2043,             
               aes(x = wavelength, 
                   y = reflectance, 
                   color = reflectanceCondition)) + geom_line() 
print(refl_conditions_plot + ggtitle("FSP_RMNP_20200706_2043 - all reflectance conditions"))


## ----plot-single-spectra, fig.align="center", fig.width = 12, fig.height = 4.5-----------------------------------------------------------------------------
FSP_RMNP_20200706_2043_REFL <- FSP_RMNP_20200706_2043[FSP_RMNP_20200706_2043$reflectanceCondition == "top of foliage (sunward) on black reference", c("reflectance","wavelength")]

spectra_plot <- ggplot(FSP_RMNP_20200706_2043_REFL,
                       aes(x = wavelength, 
                           y = reflectance)) + geom_line() 
print(spectra_plot + ggtitle("FSP_RMNP_20200706_2043_REFL - Top of Foliage on Black Reference"))


## ----create-refl-df----------------------------------------------------------------------------------------------------------------------------------------
spectra_list <- list()
for (i in 1:nrow(spectra_merge)) {
  taxonID <- spectra_merge$taxonID[i] # get the taxonID
  url <- spectra_merge$downloadFileUrl[i] # get the data download URL
  refl_data <- read.csv(url) # read the data csv into a dataframe
  # filter to select only the `top on black` reflectanceCondition and keep the reflectance data only
  refl <- refl_data[which(refl_data$reflectanceCondition == "top of foliage (sunward) on black reference"), c("reflectance")]
  spectra_list[[i]] <- refl
}
# get the wavelength values corresponding to the subset we selected for each of the spectra
wavelengths <- refl_data[which(refl_data$reflectanceCondition == "top of foliage (sunward) on black reference"), c("wavelength")]
spectra_df <- as.data.frame(do.call(cbind, spectra_list)) # make a new dataframe from the spectra_list
# assign the taxonID + fspID to the column names to make unique column names
taxonIDs <- paste0(spectra_merge$taxonID,substr(spectra_merge$spectralSampleID,9,22))
colnames(spectra_df) <- taxonIDs
# assign the wavelength values to a new column
spectra_df$wavelength <- wavelengths


## ----plot-taxon-spectra, fig.align="center", warning = FALSE, fig.width = 14, fig.height = 5---------------------------------------------------------------
data_long <- melt(spectra_df, id = "wavelength",value.name="reflectance",variable.name="taxonID")
all_spectra_plot <- ggplot(data_long,             
               aes(x = wavelength, 
                   y = reflectance, 
                   color = taxonID)) + geom_line() 
print(all_spectra_plot + ggtitle("Spectra of all Taxon IDs collected at RMNP"))


## ----plot-taxon-spectra2, fig.align="center", fig.width = 12, fig.height = 4.5-----------------------------------------------------------------------------
spectra_df2 <- as.data.frame(do.call(cbind, spectra_list)) # make a new dataframe from the spectra_list
# assign the taxonIDs to the column names
taxonIDs <- spectra_merge$taxonID 
colnames(spectra_df2) <- taxonIDs
spectra_df2$wavelength <- wavelengths
data_long2 <- melt(as.data.table(spectra_df2), id = "wavelength")
all_spectra_plot <- ggplot(data_long2,             
               aes(x = wavelength, 
                   y = value, 
                   color = variable)) + geom_line(alpha=0.5) 
print(all_spectra_plot + ggtitle("Spectra of all Taxon IDs collected at RMNP"))


## ----count-taxon-------------------------------------------------------------------------------------------------------------------------------------------
spectra_merge %>% count(taxonID, sort = TRUE)


## ----plot-picol-spectra, fig.align="center", fig.width = 12, fig.height = 4.5------------------------------------------------------------------------------
spectra_data_table <- as.data.table(spectra_df)
picol_data_table <- spectra_data_table[, grep("wavelength|PICOL", names(spectra_data_table)), with = FALSE]
picol_data <- melt(picol_data_table, id = "wavelength",value.name = 'reflectance', variable.name = 'taxon_fsp_ID')
picol_spectra_plot <- ggplot(picol_data,
                            aes(x = wavelength, 
                                y = reflectance, 
                                color = taxon_fsp_ID)) + geom_line() 
print(picol_spectra_plot + ggtitle("Spectra of PICOL samples collected at RMNP"))


## ----view-picol-metadata-----------------------------------------------------------------------------------------------------------------------------------
spectra_merge[which(spectra_merge$taxonID == "PICOL"), c("taxonID","spectralSampleID","plantStatus","leafStatus","leafAge","leafExposure","leafSamplePosition","targetType","targetStatus","measurementVenue","remarks.y")]


## ----ndvi-calculation--------------------------------------------------------------------------------------------------------------------------------------
nir <- spectra_df[which.min(abs(750-spectra_df$wavelength)),]
red <- spectra_df[which.min(abs(650-spectra_df$wavelength)),]
ndvi = (nir - red) / (nir + red) 
ndvi = ndvi[1:(length(ndvi)-1)]


## ----ndvi-barplot, fig.align="right", fig.width = 12, fig.height = 5---------------------------------------------------------------------------------------
pigl_ndvi <- select(ndvi,contains("PICOL"))
barplot(unlist(pigl_ndvi), cex.names=1) 
title(main = "PICOL NDVI", xlab = "sample", ylab = "NDVI")


## ----ndvi-boxplot, fig.align="right", fig.width = 5, fig.height = 5----------------------------------------------------------------------------------------
boxplot(unlist(pigl_ndvi), cex.names=1) 
title(main = "PICOL NDVI Boxplot", xlab = "sample", ylab = "NDVI")


## ----plot-pipos-spectra, fig.align="center", fig.width = 12, fig.height = 4.5------------------------------------------------------------------------------
spectra_data_table <- as.data.table(spectra_df)
pipos_data_table <- spectra_data_table[, grep("wavelength|PIPOS", names(spectra_data_table)), with = FALSE]
pipos_data <- melt(pipos_data_table, id = "wavelength",value.name = 'reflectance', variable.name = 'taxon_fsp_ID')
pipos_spectra_plot <- ggplot(pipos_data,
                            aes(x = wavelength, 
                                y = reflectance, 
                                color = taxon_fsp_ID)) + geom_line() 
print(pipos_spectra_plot + ggtitle("Spectra of Ponderosa Pine (PIPOS) samples at RMNP"))


## ----plot-potr5-spectra, fig.align="center", fig.width = 12, fig.height = 4.5------------------------------------------------------------------------------
spectra_data_table <- as.data.table(spectra_df)
potr5_data_table <- spectra_data_table[, grep("wavelength|POTR5", names(spectra_data_table)), with = FALSE]
potr5_data <- melt(potr5_data_table, id = "wavelength",value.name = 'reflectance', variable.name = 'taxon_fsp_ID')
potr5_spectra_plot <- ggplot(potr5_data,
                            aes(x = wavelength, 
                                y = reflectance, 
                                color = taxon_fsp_ID)) + geom_line() 
print(picol_spectra_plot + ggtitle("Spectra of Aspen (POTR5) samples @ RMNP"))


## ----plot-picol-potr5-spectra, fig.align="center", fig.width = 12, fig.height = 4.5------------------------------------------------------------------------
spectra_data_table2 <- as.data.table(spectra_df2)
picol_potr5_data_table <- spectra_data_table2[, grep("wavelength|PICOL|POTR5", names(spectra_data_table2)), with = FALSE]

picol_potr5_data <- melt(picol_potr5_data_table, id = "wavelength",value.name = 'reflectance', variable.name = 'taxonID')
picol_potr5_spectra_plot <- ggplot(picol_potr5_data,
                            aes(x = wavelength, 
                                y = reflectance, 
                                color = taxonID)) + geom_line(alpha=0.5) 
print(picol_potr5_spectra_plot + ggtitle("Spectra of Lodgepole (PICOL) and Aspen (POTR5) samples @ RMNP"))


## ----foliar-trait-info-------------------------------------------------------------------------------------------------------------------------------------
foliar_trait_info <- neonUtilities::getProductInfo('DP1.10026.001')
#View(foliar_trait_info$siteCodes)
#View(foliar_trait_info$siteCodes$availableDataUrls)


## ----rmnp-foliar-trait-urls--------------------------------------------------------------------------------------------------------------------------------
# view the RMNP foliar trait available data urls
foliar_trait_info$siteCodes[which(foliar_trait_info$siteCodes$siteCode == 'RMNP'),c("availableDataUrls")]


## ----load-foliar-trait-------------------------------------------------------------------------------------------------------------------------------------
foliar_traits <- loadByProduct(dpID='DP1.10026.001',
                               site='RMNP',
                               startdate='2020-07',
                               package="expanded",
                               check.size=FALSE)
names(foliar_traits)


## ----get-foliar-trait-locs, results="hide"-----------------------------------------------------------------------------------------------------------------
vst.loc <- getLocTOS(data=foliar_traits$vst_mappingandtagging,
                     dataProd="vst_mappingandtagging")


## ----merge-foliar-trait-tables-----------------------------------------------------------------------------------------------------------------------------
foliar_traits_loc <- merge(foliar_traits$cfc_fieldData,vst.loc,by="individualID")


## ----spectra-traits----------------------------------------------------------------------------------------------------------------------------------------
spectra_traits <- merge(spectra_merge,foliar_traits_loc,by="sampleID")
head(spectra_traits[c("spectralSampleID","locationID.x","tagID","taxonID","stemDistance","stemAzimuth","adjEasting","adjNorthing")])


## ----set-wd------------------------------------------------------------------------------------------------------------------------------------------------
# set working directory (this will depend on your local environment)
wd <- "~/data/"
setwd(wd)


## ----single-picol-spectra----------------------------------------------------------------------------------------------------------------------------------
FSP_RMNP_PICOL <- spectra_traits[spectra_traits$spectralSampleID == "FSP_RMNP_20200720_1304",]


## ----show-spectral-taxon-ids-------------------------------------------------------------------------------------------------------------------------------
FSP_RMNP_PICOL$spectralSampleID
FSP_RMNP_PICOL$taxonID


## ----download-reflectance, eval=FALSE----------------------------------------------------------------------------------------------------------------------
## byTileAOP(dpID='DP3.30006.001',
##           site='RMNP',
##           year=2020,
##           easting=FSP_RMNP_PICOL$adjEasting,
##           northing=FSP_RMNP_PICOL$adjNorthing,
##           include.provisional=TRUE,
##           savepath=wd)


## ----read-h5-file------------------------------------------------------------------------------------------------------------------------------------------
# Define the h5 file name to be opened
h5_file <- paste0(wd,"DP3.30006.001/neon-aop-products/2020/FullSite/D10/2020_RMNP_3/L3/Spectrometer/Reflectance/NEON_D10_RMNP_DP3_455000_4446000_reflectance.h5")


## ----h5-functions------------------------------------------------------------------------------------------------------------------------------------------
geth5metadata <- function(h5_file){
  # get the site name
  site <- h5ls(h5_file)$group[2]
  
  # get the wavelengths
  wavelengths <- h5read(h5_file,paste0(site,"/Reflectance/Metadata/Spectral_Data/Wavelength"))
  
  # get the epsg code
  h5_epsg <- h5read(h5_file,paste0(site,"/Reflectance/Metadata/Coordinate_System/EPSG Code"))
                    
  # get the Reflectance_Data attributes
  refl_attrs <- h5readAttributes(h5_file,paste0(site,"/Reflectance/Reflectance_Data"))
  
  # grab the UTM coordinates of the spatial extent
  xMin <- refl_attrs$Spatial_Extent_meters[1]
  xMax <- refl_attrs$Spatial_Extent_meters[2]
  yMin <- refl_attrs$Spatial_Extent_meters[3]
  yMax <- refl_attrs$Spatial_Extent_meters[4]
  
  ext <- ext(xMin,xMax,yMin,yMax) # define the extent (left, right, top, bottom)

  no_data <- as.integer(refl_attrs$Data_Ignore_Value)  # define the no data value
  meta_list <- list("wavelengths" = wavelengths, "crs" = crs, "raster_ext" = ext, "no_data_value" = no_data)
  h5closeAll() # cloes all open h5 instances
  
  return(meta_list)
}


  band2Raster <- function(h5_file, band, extent, crs, no_data_value){
    site <- h5ls(h5_file)$group[2] # extract the site info
    # read in the raster for the band specified, this will be an array
    refl_array <- h5read(h5_file,paste0(site,"/Reflectance/Reflectance_Data"),index=list(band,NULL,NULL))
	  refl_matrix <- (refl_array[1,,]) # convert from array to matrix
	  refl_matrix <- t(refl_matrix) # transpose data to fix flipped row and column order
    refl_matrix[refl_matrix == no_data_value] <- NA     # assign data ignore values to NA
    refl_out <- rast(refl_matrix,crs=crs) # write out as a raster
    ext(refl_out) <- extent # assign the extents to the raster
    h5closeAll() # close all open h5 instances
    return(refl_out) # return the terra raster object
}


## ----refl-to-rast------------------------------------------------------------------------------------------------------------------------------------------
# get the relevant metadata using the geth5metadata function
h5_meta <- geth5metadata(h5_file)

# get all bands - a consecutive list of integers from 1:426 (# of bands)
all_bands <- as.list(1:length(h5_meta$wavelengths))

# lapply applies the function `band2Raster` to each element in the list `all_bands`
refl_list <- lapply(all_bands,
                    FUN = band2Raster,
                    h5_file = h5_file,
                    extent = h5_meta$raster_ext,
                    crs = h5_meta$crs,
                    no_data_value = h5_meta$no_data_value)

refl_rast <- rast(refl_list)


## ----plot-band58-------------------------------------------------------------------------------------------------------------------------------------------
plot(refl_rast[[58]])
#convert the data frame into a shape file (vector)
m <- vect(cbind(FSP_RMNP_PICOL$adjEasting,
                FSP_RMNP_PICOL$adjNorthing), crs=h5_meta$crs)
# plot
plot(m, add = T)


## ----plot-band58-zoom--------------------------------------------------------------------------------------------------------------------------------------
x_sub = c(455100, 455200)
y_sub = c(4446500, 4446600)
plot(refl_rast[[58]],xlim=x_sub,ylim=y_sub)
plot(m, add = T)


## ----refl-to-rgb-rast--------------------------------------------------------------------------------------------------------------------------------------

rgb <- list(58,34,19)

# lapply tells R to apply the function to each element in the list
rgb_list <- lapply(rgb,
                    FUN = band2Raster,
                    h5_file = h5_file,
                    extent = h5_meta$raster_ext,
                    crs = h5_meta$crs,
                    no_data_value = h5_meta$no_data_value)

rgb_rast <- rast(rgb_list)


## ----plot-refl-rgb-----------------------------------------------------------------------------------------------------------------------------------------
plotRGB(rgb_rast,stretch='lin',axes=TRUE)
plot(m, col="red", add = T)
#zoom in
plotRGB(rgb_rast,stretch='lin',xlim=x_sub,ylim=y_sub)
plot(m, col="red", add = T)


## ----extract-air-refl-spectra, fig.align="center", fig.width = 12, fig.height = 4.5------------------------------------------------------------------------
refl_air <- extract(refl_rast, 
                    cbind(FSP_RMNP_PICOL$adjEasting,
                          FSP_RMNP_PICOL$adjNorthing))

refl_air_df <- data.frame(t(refl_air))
refl_air_df$wavelengths <- h5_meta$wavelengths
names(refl_air_df) <- c('reflectance','wavelength')

picol_air_plot <- ggplot(refl_air_df,
                         aes(x=wavelength, 
                             y=reflectance)) + geom_line() + ylim(0,2500)
print(picol_air_plot + ggtitle("Airborne Reflectance Spectra of PICOL @ RMNP"))


## ----plot-picol-spectra-leafclip, fig.align="center", fig.width = 12, fig.height = 4.5---------------------------------------------------------------------
spectra_data_table <- as.data.table(spectra_df)
picol_data_table <- spectra_data_table[, grep("wavelength|PICOL_20200720_1304", names(spectra_data_table)), with = FALSE]
picol_data <- melt(picol_data_table, id = "wavelength",value.name = 'reflectance', variable.name = 'taxon_fsp_ID')
picol_leafclip_plot <- ggplot(picol_data,
                             aes(x = wavelength, 
                                 y = reflectance)) + geom_line() 
print(picol_leafclip_plot + ggtitle("Leaf-Clip Spectra of PICOL FSP_RMNP_20200720_1304"))


## ----plot-picol-spectra-both, fig.align="center", fig.width = 12, fig.height = 4.5-------------------------------------------------------------------------
# scale the airborne reflectance by the scale factor
refl_air_df$scaled <- (refl_air_df$reflectance/as.vector(10000))

spectra_plot <- ggplot() + 
  geom_line(data=refl_air_df, aes(x=wavelength, y=scaled), color='green', show.legend=TRUE) +
  geom_line(data=picol_data, aes(x=wavelength, y=reflectance), color='darkgreen', show.legend=TRUE) +

  labs(x="Wavelength (nm)",
       y="Reflectance") +
  theme(legend.position = c(2500, 0.3)) +
  ylim(0, 0.5)

print(spectra_plot + ggtitle("Spectra of PICOL Leaf Clip & Corresponding Airborne Pixel at RMNP"))

