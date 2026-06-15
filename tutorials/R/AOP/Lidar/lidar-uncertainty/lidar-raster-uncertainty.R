## ----load-libraries, message=FALSE, warning=FALSE--------------------------------------------------------------------

# Load needed packages
library(terra)
library(neonUtilities)
library(ggplot2)


## ----set-working-directory-------------------------------------------------------------------------------------------

wd="~/data/" #This will depend on your local environment
setwd(wd)


## ----download-chm, eval=FALSE----------------------------------------------------------------------------------------
## byTileAOP(dpID='DP3.30015.001',
##           site='PRIN',
##           year='2016',
##           easting=607000,
##           northing=3696000,
##           check.size=FALSE, # set to TRUE if you want to confirm before downloading
##           savepath = wd)


## ----download-dem, eval=FALSE----------------------------------------------------------------------------------------
## byTileAOP(dpID='DP3.30024.001',
##           site='PRIN',
##           year='2016',
##           easting=607000,
##           northing=3696000,
##           check.size=FALSE, # set to TRUE if you want to confirm before downloading
##           savepath = wd)


## ----define-lidar-paths, results="hide"------------------------------------------------------------------------------
# Define the CHM, DSM and DTM file names, including the full path
chm_file1 <- paste0(wd,"DP3.30015.001/neon-aop-products/2016/FullSite/D11/2016_PRIN_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D11_PRIN_DP3_607000_3696000_CHM.tif")
chm_file2 <- paste0(wd,"DP3.30015.001/neon-aop-products/2016/FullSite/D11/2016_PRIN_2/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D11_PRIN_DP3_607000_3696000_CHM.tif")
dsm_file1 <- paste0(wd,"DP3.30024.001/neon-aop-products/2016/FullSite/D11/2016_PRIN_1/L3/DiscreteLidar/DSMGtif/NEON_D11_PRIN_DP3_607000_3696000_DSM.tif")
dsm_file2 <- paste0(wd,"DP3.30024.001/neon-aop-products/2016/FullSite/D11/2016_PRIN_2/L3/DiscreteLidar/DSMGtif/NEON_D11_PRIN_DP3_607000_3696000_DSM.tif")
dtm_file1 <- paste0(wd,"DP3.30024.001/neon-aop-products/2016/FullSite/D11/2016_PRIN_1/L3/DiscreteLidar/DTMGtif/NEON_D11_PRIN_DP3_607000_3696000_DTM.tif")
dtm_file2 <- paste0(wd,"DP3.30024.001/neon-aop-products/2016/FullSite/D11/2016_PRIN_2/L3/DiscreteLidar/DTMGtif/NEON_D11_PRIN_DP3_607000_3696000_DTM.tif")


## ----terra-rasters---------------------------------------------------------------------------------------------------

# assign raster to object
chm1 <- rast(chm_file1)
chm2 <- rast(chm_file2)
dsm1 <- rast(dsm_file1)
dsm2 <- rast(dsm_file2)
dtm1 <- rast(dtm_file1)
dtm2 <- rast(dtm_file2)

# view info about one of the rasters
chm1


## ----plot-dsm--------------------------------------------------------------------------------------------------------
# plot the set of DTM rasters
# Set up the plotting area to have 1 row and 2 columns
par(mfrow = c(1, 2))

# Plot the DSMs from the 1st and 2nd collections
plot(dsm1, main = "2016_PRIN_1 DSM")
plot(dsm2, main = "2016_PRIN_2 DSM")


## ----plot-dtm--------------------------------------------------------------------------------------------------------
# Reset the plotting area
par(mfrow = c(1, 2))

# Plot the DTMs from the 1st and 2nd collections
plot(dtm1, main = "2016_PRIN_1 DTM")
plot(dtm2, main = "2016_PRIN_2 DTM")


## ----diff-dsm--------------------------------------------------------------------------------------------------------

# Difference the 2 DSM rasters
dsm_diff <- dsm1 - dsm2

# Calculate mean and standard deviation
dsm_diff_mean <- as.numeric(global(dsm_diff, fun = "mean", na.rm = TRUE))
dsm_diff_std_dev <- as.numeric(global(dsm_diff, fun = "sd", na.rm = TRUE))

# Print the statistics
print(paste("Mean DSM Difference:", round(dsm_diff_mean,3)))
print(paste("Standard Deviation of DSM Difference:", round(dsm_diff_std_dev,3)))



## ----dsm-diff-hist---------------------------------------------------------------------------------------------------

# Set options to avoid scientific notation
options(scipen = 999)

# Plot a histogram of the raster values
hist(dsm_diff, breaks = 100, main = "Histogram of DSM Difference", xlab = "Height Difference (m)", ylab = "Frequency", col = "lightblue", border = "black")



## ----dsm-diff-hist-zoomed-in-----------------------------------------------------------------------------------------

# Calculate x-axis limits: mean ± 2 * standard deviation
xlim_lower <- dsm_diff_mean - 2 * dsm_diff_std_dev
xlim_upper <- dsm_diff_mean + 2 * dsm_diff_std_dev

# Plot a histogram of the raster values with 100 bins, x-axis set to ±2 standard deviations
hist(dsm_diff, breaks = 250, xlim = c(xlim_lower, xlim_upper), 
     main = "Histogram of Difference DSM", xlab = "Height Difference (m)", 
     ylab = "Frequency", col = "lightblue", border = "black")



## ----spatial-distribution-dsm-diff-----------------------------------------------------------------------------------

custom_palette <- colorRampPalette(c("blue", "white", "red"))(9)
breaks = c(-1.75, -1.25, -0.75, -0.25, 0.25, 0.75, 1.25, 2)

# Plot using terra's plot function
plot(dsm_diff, 
     main = "DSM Difference Map", 
     col=custom_palette,
     breaks=breaks,
     axes = TRUE, 
     legend = TRUE)



## ----diff-dtm--------------------------------------------------------------------------------------------------------

# Difference the 2 DTM rasters
dtm_diff <- dtm1 - dtm2

# Calculate mean and standard deviation
dtm_diff_mean <- as.numeric(global(dtm_diff, fun = "mean", na.rm = TRUE))
dtm_diff_std_dev <- as.numeric(global(dtm_diff, fun = "sd", na.rm = TRUE))

# Print the statistics
print(paste("Mean DTM Difference:", round(dtm_diff_mean,3)))
print(paste("Standard Deviation of DSM Difference:", round(dtm_diff_std_dev,3)))



## ----spatial-distribution-dtm-diff-----------------------------------------------------------------------------------

custom_palette <- colorRampPalette(c("blue", "white", "red"))(5)
breaks = c(-1, -0.6, -0.2, 0.2, 0.6, 1)

plot(dtm_diff, 
     main = "DTM Difference Map", 
     col=custom_palette,
     breaks=breaks,
     axes = TRUE, 
     legend = TRUE)


## ----plot-chm--------------------------------------------------------------------------------------------------------
# Reset the plotting area
par(mfrow = c(1, 2))

# Plot the CHMs from the 1st and 2nd collections
plot(chm1, main = "2016_PRIN_1 CHM")
plot(chm2, main = "2016_PRIN_2 CHM")


## ----mask-dsm-veg-pixels---------------------------------------------------------------------------------------------

# Create a mask of non-zero values in the CHM raster
chm_mask <- chm1 != 0

# Apply the veg mask to the DSM difference raster
dsm_diff_masked_veg <- mask(dsm_diff, chm_mask, maskvalue = FALSE)

# Calculate mean and standard deviation of the DSM difference only using vegetated pixels
dsm_diff_masked_veg_mean <- as.numeric(global(dsm_diff_masked_veg, fun = "mean", na.rm = TRUE))
dsm_diff_masked_veg_std_dev <- as.numeric(global(dsm_diff_masked_veg, fun = "sd", na.rm = TRUE))

# Print the statistics
print(paste("Mean DSM Difference on Veg Pixels:", round(dsm_diff_masked_veg_mean,3)))
print(paste("Standard Deviation of DSM Difference on Veg Pixels:", round(dsm_diff_masked_veg_std_dev,3)))



## ----masked-dsm-histogram--------------------------------------------------------------------------------------------

# Calculate x-axis limits: mean ± 2 * standard deviation
masked_xlim_lower <- dsm_diff_masked_veg_mean - 2 * dsm_diff_masked_veg_std_dev
masked_xlim_upper <- dsm_diff_masked_veg_mean + 2 * dsm_diff_masked_veg_std_dev

# Plot a histogram of the raster values with 100 bins, x-axis set to ±2 standard deviations
hist(dsm_diff_masked_veg, breaks = 250, xlim = c(masked_xlim_lower, masked_xlim_upper), 
     main = "Histogram of Difference DSM in Vegetated Areas", xlab = "Height Difference (m)", 
     ylab = "Frequency", col = "lightblue", border = "black")


## ----mask-dtm-veg-pixels---------------------------------------------------------------------------------------------

# Apply the veg mask to the DTM difference raster
dtm_diff_masked_veg <- mask(dtm_diff, chm_mask, maskvalue = FALSE)

# Calculate mean and standard deviation of the dtm difference only using vegetated pixels
dtm_diff_masked_veg_mean <- as.numeric(global(dtm_diff_masked_veg, fun = "mean", na.rm = TRUE))
dtm_diff_masked_veg_std_dev <- as.numeric(global(dtm_diff_masked_veg, fun = "sd", na.rm = TRUE))

# Print the statistics
print(paste("Mean DTM Difference on Veg Pixels:", round(dtm_diff_masked_veg_mean,3)))
print(paste("Standard Deviation of DTM Difference on Veg Pixels:", round(dtm_diff_masked_veg_std_dev,3)))


## ----masked-dtm-histogram--------------------------------------------------------------------------------------------

# Calculate x-axis limits: mean ± 2 * standard deviation
masked_xlim_lower <- dtm_diff_masked_veg_mean - 2 * dtm_diff_masked_veg_std_dev
masked_xlim_upper <- dtm_diff_masked_veg_mean + 2 * dtm_diff_masked_veg_std_dev

# Plot a histogram of the raster values with 100 bins, x-axis set to ±2 standard deviations
hist(dtm_diff_masked_veg, breaks = 250, xlim = c(masked_xlim_lower, masked_xlim_upper), 
     main = "Histogram of Difference DTM in Vegetated Areas", xlab = "Height Difference (m)", 
     ylab = "Frequency", col = "lightblue", border = "black")


## ----mask-dsm-ground-------------------------------------------------------------------------------------------------

ground_mask <- chm1 == 0

# Apply the ground mask to the DSM difference raster
dsm_diff_masked_ground <- mask(dsm_diff, ground_mask, maskvalue = FALSE)

# Calculate mean and standard deviation of the DSM difference only using vegetated pixels
dsm_diff_masked_ground_mean <- as.numeric(global(dsm_diff_masked_ground, fun = "mean", na.rm = TRUE))
dsm_diff_masked_ground_std_dev <- as.numeric(global(dsm_diff_masked_ground, fun = "sd", na.rm = TRUE))

# Print the statistics
print(paste("Mean DSM Difference on Ground Pixels:", round(dsm_diff_masked_ground_mean,4)))
print(paste("Standard Deviation of DSM Difference on Ground Pixels:", round(dsm_diff_masked_ground_std_dev,3)))


## ----dsm-diff-masked-ground-hist-------------------------------------------------------------------------------------

# Calculate x-axis limits: mean ± 2 * standard deviation
masked_xlim_lower <- dsm_diff_masked_ground_mean - 2 * dsm_diff_masked_ground_std_dev
masked_xlim_upper <- dsm_diff_masked_ground_mean + 2 * dsm_diff_masked_ground_std_dev

# Plot a histogram of the raster values with 100 bins, x-axis set to ±2 standard deviations
hist(dsm_diff_masked_ground, breaks = 500, xlim = c(masked_xlim_lower, masked_xlim_upper), 
     main = "Histogram of Difference DTM over Ground Pixels", xlab = "Height Difference (m)", 
     ylab = "Frequency", col = "lightblue", border = "black")

