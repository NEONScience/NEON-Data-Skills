## ----import-libraries, results="hide"-------------------------------------------------------------------------------------------------------------------
library(neonUtilities)
library(neonOS)
library(geoNEON)
library(ggplot2)
library(dplyr)
library(rhdf5)
library(terra)


## ----field-spectra-info---------------------------------------------------------------------------------------------------------------------------------
field_spectra_info <- neonUtilities::getProductInfo('DP1.30012.001')
#View(field_spectra_info$siteCodes) 
#View(field_spectra_info$siteCodes$availableDataUrls) # list available data urls
field_spectra_info$siteCodes$siteCode # list all available sites


## ----load-field-spectra, results="hide"-----------------------------------------------------------------------------------------------------------------
field_spectra <- loadByProduct(dpID='DP1.30012.001',
                              site='RMNP',
                              package="expanded",
                              check.size=FALSE)


## ----field-spectra-names--------------------------------------------------------------------------------------------------------------------------------
names(field_spectra)


## ----list2env, results="hide"---------------------------------------------------------------------------------------------------------------------------
list2env(field_spectra, .GlobalEnv)


## ----merge-data-metadata--------------------------------------------------------------------------------------------------------------------------------
spectra_data_metadata <- joinTableNEON(fsp_spectralData,fsp_sampleMetadata)
spectra_data <- merge(spectra_data_metadata,per_sample,by="spectralSampleID")


## ----spectra_data-colnames------------------------------------------------------------------------------------------------------------------------------
colnames(spectra_data)
head(spectra_data[c("spectralSampleID","taxonID","reflectance","wavelength","reflectanceCondition")],1)


## ----set-wl-refl-to-numeric-----------------------------------------------------------------------------------------------------------------------------
spectra_data$wavelength <- as.numeric(spectra_data$wavelength)
spectra_data$reflectance <- as.numeric(spectra_data$reflectance)


## ----unique-refl-conditions-----------------------------------------------------------------------------------------------------------------------------
unique(spectra_data$reflectanceCondition)


## ----plot-first-fsp, fig.align="center", fig.width = 12, fig.height = 4.5-------------------------------------------------------------------------------
first_spectra_plot <- ggplot(subset(spectra_data, spectralSampleID == "FSP_RMNP_20200706_2043"), 
                             aes(x =wavelength, y = reflectance,
                                 color = reflectanceCondition)) + geom_line() 
print(first_spectra_plot + ggtitle("FSP_RMNP_20200706_2043 spectra, all reflectance conditions"))


## ----plot-first-fsp-top-black, fig.align="center", fig.width = 12, fig.height = 4.5---------------------------------------------------------------------
first_spectra_plot <- ggplot(subset(spectra_data, spectralSampleID == "FSP_RMNP_20200706_2043" & reflectanceCondition == "top of foliage (sunward) on black reference"), aes(x =wavelength, y = reflectance, color = reflectanceCondition)) + geom_line() 
print(first_spectra_plot + ggtitle("FSP_RMNP_20200706_2043 spectra, top of foliage on black reference"))


## ----extract-top-black----------------------------------------------------------------------------------------------------------------------------------
spectra_top_black <- spectra_data %>% dplyr::filter(reflectanceCondition == "top of foliage (sunward) on black reference")


## ----plot-all-spectra, fig.align="center", fig.width = 12, fig.height = 4.5-----------------------------------------------------------------------------
ggplot(spectra_top_black, 
       aes(x =wavelength, y = reflectance,
           color = spectralSampleID)) + geom_line() 


## ----plot-by-species, fig.align="center", fig.width = 12, fig.height = 4.5------------------------------------------------------------------------------
ggplot(spectra_top_black, 
       aes(x =wavelength, y = reflectance,
           color = taxonID)) + geom_line(alpha = 0.5) 


## ----count-taxon----------------------------------------------------------------------------------------------------------------------------------------
spectra_top_black %>% 
  filter(wavelength == 350) %>% 
  count(taxonID, sort = TRUE)


## ----plot-picol-spectra, fig.align="center", fig.width = 12, fig.height = 4.5---------------------------------------------------------------------------
picol_spectra_plot <- ggplot(subset(spectra_top_black, taxonID == "PICOL"), 
                             aes(x =wavelength, y = reflectance,
                                 color = spectralSampleID)) + geom_line() 
print(picol_spectra_plot + ggtitle("Spectra of PICOL samples collected at RMNP"))


## ----view-picol-metadata--------------------------------------------------------------------------------------------------------------------------------
spectra_top_black[which(spectra_top_black$taxonID == "PICOL" & spectra_top_black$wavelength == 350), c("taxonID","spectralSampleID","plantStatus","leafStatus","leafAge","leafExposure","leafSamplePosition","targetType","targetStatus","measurementVenue","remarks.y")]


## ----plot-potr5-spectra, fig.align="center", fig.width = 12, fig.height = 4.5---------------------------------------------------------------------------
potr5_spectra_plot <- ggplot(subset(spectra_top_black, taxonID == "POTR5"), 
                             aes(x =wavelength, y = reflectance,
                                 color = spectralSampleID)) + geom_line() 
print(potr5_spectra_plot + ggtitle("Spectra of POTR5 samples collected at RMNP"))


## ----plot-picol-potr5-spectra, fig.align="center", fig.width = 12, fig.height = 4.5---------------------------------------------------------------------
potr5_picol_plot <- ggplot(subset(spectra_top_black, taxonID %in% c("POTR5","PICOL")), 
                             aes(x =wavelength, y = reflectance,
                                 color = taxonID)) + geom_line(alpha = 0.5) 
print(potr5_picol_plot + ggtitle("Comparison PICOL (Lodgepole Pine) and POTR5 (Aspen) Leaf sample spectra at RMNP"))


## ----foliar-trait-info----------------------------------------------------------------------------------------------------------------------------------
foliar_trait_info <- neonUtilities::getProductInfo('DP1.10026.001')
#View(foliar_trait_info$siteCodes)
#View(foliar_trait_info$siteCodes$availableDataUrls)


## ----rmnp-foliar-trait-urls-----------------------------------------------------------------------------------------------------------------------------
# view the RMNP foliar trait available data urls
foliar_trait_info$siteCodes[which(foliar_trait_info$siteCodes$siteCode == 'RMNP'),c("availableDataUrls")]


## ----load-foliar-trait, results="hide"------------------------------------------------------------------------------------------------------------------
foliar_traits <- loadByProduct(dpID='DP1.10026.001',
                               site='RMNP',
                               startdate='2020-07',
                               package="expanded",
                               check.size=FALSE)
names(foliar_traits)


## ----get-foliar-trait-locs, results="hide"--------------------------------------------------------------------------------------------------------------
vst.loc <- getLocTOS(data=foliar_traits$vst_mappingandtagging,
                     dataProd="vst_mappingandtagging")


## ----merge-foliar-trait-tables--------------------------------------------------------------------------------------------------------------------------
foliar_traits_loc <- merge(foliar_traits$cfc_fieldData,vst.loc,by="individualID")


## ----spectra-traits-------------------------------------------------------------------------------------------------------------------------------------
spectra_traits <- merge(spectra_top_black,foliar_traits_loc,by="sampleID")
head(spectra_traits[c("spectralSampleID","locationID","tagID","taxonID","stemDistance","stemAzimuth","adjEasting","adjNorthing")])


## ----set-wd, results="hide"-----------------------------------------------------------------------------------------------------------------------------
# set working directory (this will depend on your local environment)
wd <- "~/data/"
setwd(wd)


## ----single-picol-spectra-------------------------------------------------------------------------------------------------------------------------------
FSP_RMNP_PICOL <- spectra_traits[spectra_traits$spectralSampleID == "FSP_RMNP_20200720_1304",]


## ----show-spectral-taxon-ids----------------------------------------------------------------------------------------------------------------------------
FSP_RMNP_PICOL$spectralSampleID[1]
FSP_RMNP_PICOL$taxonID[1]


## ----download-reflectance, eval=FALSE-------------------------------------------------------------------------------------------------------------------
## byTileAOP(dpID='DP3.30006.001',
##           site='RMNP',
##           year=2020,
##           easting=FSP_RMNP_PICOL$adjEasting,
##           northing=FSP_RMNP_PICOL$adjNorthing,
##           include.provisional=TRUE,
##           savepath=wd)


## ----read-h5-file---------------------------------------------------------------------------------------------------------------------------------------
# Define the h5 file name to be opened
h5_file <- paste0(wd,"DP3.30006.001/neon-aop-products/2020/FullSite/D10/2020_RMNP_3/L3/Spectrometer/Reflectance/NEON_D10_RMNP_DP3_455000_4446000_reflectance.h5")


## ----h5-functions---------------------------------------------------------------------------------------------------------------------------------------
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
  meta_list <- list("wavelengths" = wavelengths, "crs" = crs(paste0("epsg:",h5_epsg)), "raster_ext" = ext, "no_data_value" = no_data)
  h5closeAll() # close all open h5 instances
  
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


## ----refl-to-rast---------------------------------------------------------------------------------------------------------------------------------------
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


## ----plot-band58----------------------------------------------------------------------------------------------------------------------------------------
plot(refl_rast[[58]])
#convert the data frame into a shape file (vector)
m <- vect(cbind(FSP_RMNP_PICOL$adjEasting,
                FSP_RMNP_PICOL$adjNorthing), crs=h5_meta$crs)
# plot
plot(m, add = T)


## ----plot-band58-zoom-----------------------------------------------------------------------------------------------------------------------------------
x_sub = c(455100, 455200)
y_sub = c(4446500, 4446600)
plot(refl_rast[[58]],xlim=x_sub,ylim=y_sub)
plot(m, add = T)


## ----refl-to-rgb-rast-----------------------------------------------------------------------------------------------------------------------------------

rgb <- list(58,34,19)

# lapply tells R to apply the function to each element in the list
rgb_list <- lapply(rgb,
                    FUN = band2Raster,
                    h5_file = h5_file,
                    extent = h5_meta$raster_ext,
                    crs = h5_meta$crs,
                    no_data_value = h5_meta$no_data_value)

rgb_rast <- rast(rgb_list)


## ----plot-refl-rgb--------------------------------------------------------------------------------------------------------------------------------------
plotRGB(rgb_rast,stretch='lin',axes=TRUE)
plot(m, col="red", add = T)
#zoom in
plotRGB(rgb_rast,stretch='lin',xlim=x_sub,ylim=y_sub)
plot(m, col="red", add = T)


## ----extract-air-refl-spectra, fig.align="center", fig.width = 12, fig.height = 4.5---------------------------------------------------------------------
refl_air <- extract(refl_rast, 
                    cbind(FSP_RMNP_PICOL$adjEasting[1],
                          FSP_RMNP_PICOL$adjNorthing[1]))

refl_air_df <- data.frame(t(refl_air))
refl_air_df$wavelengths <- h5_meta$wavelengths
names(refl_air_df) <- c('reflectance','wavelength')

picol_air_plot <- ggplot(refl_air_df,
                         aes(x=wavelength, 
                             y=reflectance)) + geom_line() + ylim(0,2500)
print(picol_air_plot + ggtitle("Airborne Reflectance Spectra of PICOL @ RMNP"))


## ----plot-picol-spectra-both, fig.align="center", fig.width = 12, fig.height = 4.5----------------------------------------------------------------------
# scale the airborne reflectance by the scale factor
refl_air_df$scaled <- (refl_air_df$reflectance/as.vector(10000))

spectra_plot <- ggplot() + 
  geom_line(data=refl_air_df, aes(x=wavelength, y=scaled), color='green', show.legend=TRUE) +
  geom_line(data=FSP_RMNP_PICOL, aes(x =wavelength, y = reflectance), color = "darkgreen", show.legend=TRUE) +
  labs(x="Wavelength (nm)",  y="Reflectance") +
  theme(legend.position = c(2500, 0.3)) +  ylim(0, 0.6)

print(spectra_plot + ggtitle("Spectra of PICOL Leaf Clip & Corresponding Airborne Pixel at RMNP"))

