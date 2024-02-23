---
syncID: f0e521fd2eca45e3b6eca7b205669ab0
title: "Explore Field Spectra Data - Scaling Ground and Airborne Observations"
description: "Explore the field spectra data product, link field spectra to airborne surface reflectance data."
dateCreated: 2024-02-12
authors: Bridget Hass
contributors: Claire Lunch
estimatedTime: 1 - 1.5 Hours
packagesLibraries: neonUtilities, geoNEON, terra, rhdf5, ggplot2, data.table, dplyr, 
topics: hyperspectral, foliar traits
languagesTool: R
dataProduct: DP1.30012.001, DP1.10026.001, DP3.30006.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/explore-field-spectra.R
tutorialSeries: 
urlTitle: scale-spectra
---


In this tutorial, we will go through a scaling exercise to link the <a href="https://data.neonscience.org/data-products/DP1.30012.001" target="_blank">field spectral reflectance</a> and airborne <a href="https://data.neonscience.org/data-products/DP3.30006.001" target="_blank">spectrometer orthorectified surface directional reflectance</a>. We will also tie in the <a href="https://data.neonscience.org/data-products/DP1.10026.001" target="_blank">plant foliar traits</a> data, which contains the geographic information associated with the field spectra data. 

Field spectral reflectance provide information about individual leaves or foliage, and samples such as these are often used as spectral endmembers in classification applications. A collection of these spectral data can comprise a spectral library, eg. the <a href="https://www.usgs.gov/labs/spectroscopy-lab/science/spectral-library" target="_blank">USGS Spectral Library</a>. This NEON data product is collected on an opportunistic basis, typically in conjunction with NEON AOP overflights and in coordination with TOS Canopy Foliage Sampling. AOP typically collects spectra at 1-2 sites per year, so it is currently available at a subset of the NEON sites. The tutorial also demonstrates how to programmatically find which data are available.


<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this activity, you will be able to:

* Determine the available field spectra data sets
* Load and plot field spectra data for a given site
* Understand the data and metadata associated with the field spectra data product
* Create a summary plot of leaf clip spectral signatures for a site, and grouped by the taxon ID
* Understand uncertainty associated with the foliar spectra data
* Link field spectra data to foliar trait data to determine the precise location of leaf clip samples
* Compare the field spectra from leaf clip samples with airborne surface reflectance data of the pixel where the leaf-clip sample was taken
 
## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded on your computer to complete this tutorial.

### Install R Packages

* **neonUtilities:** `install.packages("neonUtilities")`
* **geoNEON:** install.packages("devtools"), devtools::install_github("NEONScience/NEON-geolocation/geoNEON")
* **ggplot2:** `install.packages("ggplot2")`
* **data.table:** `install.packages("data.table")`
* **dplyr:** `install.packages("dplyr")`
* **rhdf5:** `install.packages("rhdf5")`
* **terra:** `install.packages("terra")`

</div>


First, load the required libraries.


    library(neonUtilities)

    library(geoNEON)

    library(ggplot2)

    library(data.table)

    library(dplyr)

    library(rhdf5)

    library(terra)

Before downloading the data, we can explore the data product using the `neonUtilities::getProductInfo`. Let's take a look at the field spectra data product as follows. You can take a look at various components of the `field_spectra_info` variable as well by un-commentning the lines starting with `View`.


    field_spectra_info <- neonUtilities::getProductInfo('DP1.30012.001')

    field_spectra_info$siteCodes$siteCode

    ##  [1] "DSNY" "GRSM" "GUAN" "HEAL" "ORNL" "OSBS" "PUUM" "RMNP" "SERC" "STEI" "TREE" "UNDE" "WREF" "YELL"

    #View(field_spectra_info$siteCodes)

    #View(field_spectra_info$siteCodes$availableDataUrls)

We can see that there are data available at 14 sites, as of the end of 2023.

Now that we know what sites have this field spectral data, let's take a look at one of the sites as an example - <a href="https://www.neonscience.org/field-sites/rmnp" target="_blank">Rocky Mountain National Park (RMNP)</a> in Colorado. We'll use this site to demonstrate some exploratory analysis you might start with when working with the field spectral data. To load this data directly into R, you can use the `neonUtilities::loadByProduct` function, specifying the data product ID (dpID) and site. Since this product is collected fairly infrequently, to date there is only one collection per year of this for the subset of sites shown above, so specifying the year-month in addition to the site is not necessary. This data is not too large in volume, so it should be fine to set the option `check.size=FALSE`.



    field_spectra <- loadByProduct(dpID='DP1.30012.001',
                                  site='RMNP',
                                  package="expanded",
                                  check.size=FALSE)

Let's take a look at all the associated data contained in this product, using the `names` function:


    names(field_spectra)

    ##  [1] "categoricalCodes_30012"      "citation_30012_RELEASE-2024" "fsp_boutMetadata"            "fsp_sampleMetadata"         
    ##  [5] "fsp_spectralData"            "issueLog_30012"              "per_sample"                  "readme_30012"               
    ##  [9] "validation_30012"            "variables_30012"
We encourage looking at all of these variables to learn more about the data product, but you can find the actual data stored in the variables: `fsp_boutMetadata` (contains metadata information about this sampling bout), `fsp_sampleMetadata` (contains relevant metadata about the individual samples), and `fsp_spectralData` (contains information about the individual sample data), and `per_sample` (contains the wavelength and reflectance data). Next, we can merge the data and metadata into a single table as follows. 


    spectra_merge <- merge(field_spectra$fsp_spectralData,field_spectra$fsp_sampleMetadata,by="spectralSampleID") 

You can use `View(spectra_merge)` to see the contents of this dataframe, or alternatively you could just print the variable name. The code below displays all the column names of this dataframe. We'll just show the head (or first 6 rows) of this data frame here, including a few of the columns.


    colnames(spectra_merge)

    ##  [1] "spectralSampleID"         "uid.x"                    "software"                 "locationID.x"             "collectDate.x"           
    ##  [6] "spectralSampleCode.x"     "downloadFileUrl"          "downloadFileName"         "processedBy"              "reviewedBy"              
    ## [11] "remarks.x"                "dataQF.x"                 "publicationDate.x"        "release.x"                "uid.y"                   
    ## [16] "locationID.y"             "domainID"                 "siteID"                   "plotID"                   "plotType"                
    ## [21] "nlcdClass"                "geodeticDatum"            "decimalLatitude"          "decimalLongitude"         "coordinateUncertainty"   
    ## [26] "elevation"                "elevationUncertainty"     "altLatitude"              "altLongitude"             "altCoordinateUncertainty"
    ## [31] "collectDate.y"            "eventID"                  "cfcIndividual"            "taxonID"                  "scientificName"          
    ## [36] "sampleID"                 "sampleCode"               "individualID"             "plantStatus"              "leafStatus"              
    ## [41] "leafAge"                  "leafExposure"             "leafSamplePosition"       "targetType"               "targetStatus"            
    ## [46] "measurementVenue"         "measurementDate"          "leafArrangement"          "spectralSampleCode.y"     "remarks.y"               
    ## [51] "collectedBy"              "recordedBy"               "dataQF.y"                 "publicationDate.y"        "release.y"

    head(spectra_merge[c("spectralSampleID","taxonID","scientificName","plantStatus")])

    ##         spectralSampleID taxonID                                                       scientificName        plantStatus
    ## 1 FSP_RMNP_20200706_2043   POTR5                                           Populus tremuloides Michx. Physically damaged
    ## 2 FSP_RMNP_20200706_2107    PIEN                                   Picea engelmannii Parry ex Engelm.                 OK
    ## 3 FSP_RMNP_20200706_2120   PICOL Pinus contorta Douglas ex Loudon var. latifolia Engelm. ex S. Watson                 OK
    ## 4 FSP_RMNP_20200707_2038    PSME                                 Pseudotsuga menziesii (Mirb.) Franco                 OK
    ## 5 FSP_RMNP_20200707_2058   PIPOS           Pinus ponderosa Lawson & C. Lawson var. scopulorum Engelm.                 OK
    ## 6 FSP_RMNP_20200709_2016   POTR5                                           Populus tremuloides Michx. Physically damaged

The `per_sample` table is where the actual spectral measurements are stored. We can use the following code to extract the spectral data from the first sample in this data set.


    FSP_RMNP_20200706_2043 <- field_spectra$per_sample[which(field_spectra$per_sample$spectralSampleID=="FSP_RMNP_20200706_2043"),]

This data is mainly composed of 3 columns: `wavelength`, `reflectanceCondition`, and `reflectance`. What is the `reflectanceCondition`? Let's look at the unique values represented:


    unique(FSP_RMNP_20200706_2043$reflectanceCondition)

    ## [1] "top of foliage (sunward) on white reference"     "bottom of foliage (downward) on white reference"
    ## [3] "black reference"                                 "top of foliage (sunward) on black reference"    
    ## [5] "bottom of foliage (downward) on black reference"

This `reflectanceCondition` describes what exactly is being measured. As stated in the Field spectral data Quick Start Guide on the NEON Data Portal <a href="https://data.neonscience.org/data-products/DP1.30012.001" target="_blank">Field spectral data (DP1.30012.001)</a> page, and explained in more detail in the <a href="https://data.neonscience.org/api/v0/documents/NEON_fieldSpectra_userGuide_vC?inline=true" target="_blank">NEON Field Spectra User Guide</a>:

> "Spectral reflectance of both the front and back of the sample is measured against a reflective white spectralon reference panel. A black spectralon reference is then measured, followed by spectral transmittance measurements of the front and back of the sample. Reference measurements of the white reference are taken between each leaf measurement."

When linking with NEON's airborne spectral dataset (DP3.30006.001), the `top of foliage (sunward) on black reference` is what we want to use. For this lesson, we will just focus on this reflectance condition. Let's take a look at the spectra for the single csv we read in:


    refl_conditions_plot <- ggplot(FSP_RMNP_20200706_2043,             
                   aes(x = wavelength, 
                       y = reflectance, 
                       color = reflectanceCondition)) + geom_line() 

    print(refl_conditions_plot + ggtitle("FSP_RMNP_20200706_2043 - all reflectance conditions"))

    ## `geom_line()`: Each group consists of only one observation.
    ## ℹ Do you need to adjust the group aesthetic?


<div class="figure" style="text-align: center">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-reflectance-conditions-1.png" alt=" "  />
<p class="caption"> </p>
</div>

And then subset just to the top of foliage on black reference, to plot the reflectance:


    FSP_RMNP_20200706_2043_REFL <- FSP_RMNP_20200706_2043[FSP_RMNP_20200706_2043$reflectanceCondition == "top of foliage (sunward) on black reference", c("reflectance","wavelength")]

    

    spectra_plot <- ggplot(FSP_RMNP_20200706_2043_REFL,
                           aes(x = wavelength, 
                               y = reflectance)) + geom_line() 

    print(spectra_plot + ggtitle("FSP_RMNP_20200706_2043_REFL - Top of Foliage on Black Reference"))

    ## `geom_line()`: Each group consists of only one observation.
    ## ℹ Do you need to adjust the group aesthetic?


<div class="figure" style="text-align: center">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-single-spectra-1.png" alt=" "  />
<p class="caption"> </p>
</div>

So ... how can we read the spectral data in for all of the samples collected at RMNP? The code chunk below loops through all the spectral samples and creates a new data frame comprised of the taxonID + date of the fspID, and the reflectance values only of the top of the leaf on the black reference. 

    spectra_list <- list()

    for (i in 1:nrow(spectra_merge)) {
      taxonID <- spectra_merge$taxonID[i] # get the taxonID
      ssID <- spectra_merge$spectralSampleID[i] # get the spectralSampleID
      # get the reflectance data for this spectralSampleID from per_sample
      refl_data <- field_spectra$per_sample[which(field_spectra$per_sample$spectralSampleID==ssID),]
      # filter to select only the `top on black` reflectanceCondition and keep the reflectance data only
      refl <- as.numeric(refl_data[which(refl_data$reflectanceCondition == "top of foliage (sunward) on black reference"), c("reflectance")])
      spectra_list[[i]] <- refl
    }

    # get the wavelength values corresponding to the subset we selected for each of the spectra

    wavelengths <- as.numeric(refl_data[which(refl_data$reflectanceCondition == "top of foliage (sunward) on black reference"), c("wavelength")])

    spectra_df <- as.data.frame(do.call(cbind, spectra_list)) # make a new dataframe from the spectra_list

    # assign the taxonID + fspID to the column names to make unique column names

    taxonIDs <- paste0(spectra_merge$taxonID,substr(spectra_merge$spectralSampleID,9,22))

    colnames(spectra_df) <- taxonIDs

    # assign the wavelength values to a new column

    spectra_df$wavelength <- wavelengths

In order to plot the spectra for each `taxonID`, we need to rearrange the data frame so that it contains the data in 3 columns: `wavelength`, `variable`, and `value`. We can do this using `melt` as follows:


    data_long <- melt(spectra_df, id = "wavelength",value.name="reflectance",variable.name="taxonID")

    all_spectra_plot <- ggplot(data_long,             
                   aes(x = wavelength, 
                       y = reflectance, 
                       color = taxonID)) + geom_line() 

    print(all_spectra_plot + ggtitle("Spectra of all Taxon IDs collected at RMNP"))

<div class="figure" style="text-align: center">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-taxon-spectra-1.png" alt=" "  />
<p class="caption"> </p>
</div>

You'll note there are a number of spectra with `taxonID`s of PICOL, PIPOS, and POTR5. We can also plot the spectra grouped by `taxonID`.


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

<div class="figure" style="text-align: center">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-taxon-spectra2-1.png" alt=" "  />
<p class="caption"> </p>
</div>

We can see there are 7 different species represented. We can get the count of each of the taxonIDs as follows.


    spectra_merge %>% count(taxonID, sort = TRUE)

    ##   taxonID n
    ## 1   PICOL 5
    ## 2   PIPOS 5
    ## 3   POTR5 5
    ## 4    PIEN 3
    ## 5   PIFL2 3
    ## 6    PSME 3
    ## 7   ABLAL 1

Let's dig in a a little more into the `taxonID`s` which have multiple field spectra measurements. PICOL, PIPOS, and POTR5 each have 5 samples - these are the more common species at RMNP. Let's look at the spectra only from PICOL to start. For more details on this species, you can refer to the USDA <a href="https://plants.sc.egov.usda.gov/home/plantProfile?symbol=PICOL" target="_blank">PICOL</a> plant profile page - we can see here that the common name of this species is "Lodgepole Pine".


    spectra_data_table <- as.data.table(spectra_df)

    picol_data_table <- spectra_data_table[, grep("wavelength|PICOL", names(spectra_data_table)), with = FALSE]

    picol_data <- melt(picol_data_table, id = "wavelength",value.name = 'reflectance', variable.name = 'taxon_fsp_ID')

    picol_spectra_plot <- ggplot(picol_data,
                                aes(x = wavelength, 
                                    y = reflectance, 
                                    color = taxon_fsp_ID)) + geom_line() 

    print(picol_spectra_plot + ggtitle("Spectra of PICOL samples collected at RMNP"))

<div class="figure" style="text-align: center">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-picol-spectra-1.png" alt=" "  />
<p class="caption"> </p>
</div>

What do you notice about these spectra? It looks like there is some variation between some of the samples, particularly in the visible portion of the spectrum. Let's go back to the original `spectra_merge` dataframe to see if we can determine more information about these individual samples. The code below pulls out some relevant columns from the data frame which may explain some of the variation we're seeing.


    spectra_merge[which(spectra_merge$taxonID == "PICOL"), c("taxonID","spectralSampleID","plantStatus","leafStatus","leafAge","leafExposure","leafSamplePosition","targetType","targetStatus","measurementVenue","remarks.y")]

    ##    taxonID       spectralSampleID plantStatus leafStatus leafAge leafExposure leafSamplePosition   targetType targetStatus measurementVenue
    ## 3    PICOL FSP_RMNP_20200706_2120          OK    healthy  mature     part-sun             middle pure foliage        fresh       laboratory
    ## 8    PICOL FSP_RMNP_20200709_2050          OK    healthy  mature       sunlit                top pure foliage        fresh       laboratory
    ## 10   PICOL FSP_RMNP_20200713_1117          OK    healthy  mature       sunlit             middle pure foliage        fresh       laboratory
    ## 21   PICOL FSP_RMNP_20200720_1304          OK    healthy  mature       sunlit                top pure foliage        fresh       laboratory
    ## 24   PICOL FSP_RMNP_20200721_1243          OK    healthy  mature       sunlit             middle pure foliage        fresh       laboratory
    ##             remarks.y
    ## 3                <NA>
    ## 8                <NA>
    ## 10 Sampled in AOP lab
    ## 21 Sampled in AOP lab
    ## 24               <NA>

Here, we can see that all the plants have an "OK" status, and all the leaves have a "healthy" status, but we are still seeing some variation in the spectral signatures. This is expected, as there is uncertainty associated with any measurement, due to the properties of the leaf being sample, and the measurements themselves. Note that it appears the absolute values of reflectance vary quite a bit, but the relative reflectance differences, for example between the near infrared (NIR) and visible portions of the spectrum, may be fairly consistent. Let's test this qualitative observation by computing the NDVI (Normalized Difference Vegetation Index, a normalized ratio between the NIR and red portions of the spectrum) and comparing this index across all samples. 

$$
NDVI = \frac{NIR-RED}{NIR+RED}
$$
You can refer to this tutorial for how you would calculate NDVI from the aerial reflectance data: <a href="https://www.neonscience.org/resources/learning-hub/tutorials/create-raster-stack-hsi-hdf5-r#raster-math-creating-ndvi-and-other-vegetation-indices-in-r" target="_blank">Raster Math - Creating NDVI and Other Vegetation Indices in R</a>.



    nir <- spectra_df[which.min(abs(750-spectra_df$wavelength)),]

    red <- spectra_df[which.min(abs(650-spectra_df$wavelength)),]

    ndvi = (nir - red) / (nir + red) 

    ndvi = ndvi[1:(length(ndvi)-1)]

Let's plot NDVI for all of the samples.


    pigl_ndvi <- select(ndvi,contains("PICOL"))

    barplot(unlist(pigl_ndvi), cex.names=1) 

    title(main = "PICOL NDVI", xlab = "sample", ylab = "NDVI")

<div class="figure" style="text-align: right">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/ndvi-barplot-1.png" alt=" "  />
<p class="caption"> </p>
</div>
We can also make a boxplot.


    boxplot(unlist(pigl_ndvi), cex.names=1) 

    title(main = "PICOL NDVI Boxplot", xlab = "sample", ylab = "NDVI")

<div class="figure" style="text-align: right">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/ndvi-boxplot-1.png" alt=" "  />
<p class="caption"> </p>
</div>

As we can see, the NDVI doesn't vary too much between the various samples. NDVI is a nice proxy for vegetation health, and could potentially be used in training models using this reflectance data, for example.

Let's also plot the spectra of the other more common Rocky Mountain species: <a href="https://plants.sc.egov.usda.gov/home/plantProfile?symbol=PIPO" target="_blank">PIPOS (Ponderosa Pine)</a> and <a href="https://plants.sc.egov.usda.gov/home/plantProfile?symbol=POTR5" target="_blank">POTR5 (Quaking Aspen)</a>, to explore some of the typical variation you might see in the spectral signatures of a single species.

First, start with PIPOS (Ponderosa Pine):


    spectra_data_table <- as.data.table(spectra_df)

    pipos_data_table <- spectra_data_table[, grep("wavelength|PIPOS", names(spectra_data_table)), with = FALSE]

    pipos_data <- melt(pipos_data_table, id = "wavelength",value.name = 'reflectance', variable.name = 'taxon_fsp_ID')

    pipos_spectra_plot <- ggplot(pipos_data,
                                aes(x = wavelength, 
                                    y = reflectance, 
                                    color = taxon_fsp_ID)) + geom_line() 

    print(pipos_spectra_plot + ggtitle("Spectra of Ponderosa Pine (PIPOS) samples at RMNP"))

<div class="figure" style="text-align: center">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-pipos-spectra-1.png" alt=" "  />
<p class="caption"> </p>
</div>

And then POTR5 (Quaking Aspen):


    spectra_data_table <- as.data.table(spectra_df)

    potr5_data_table <- spectra_data_table[, grep("wavelength|POTR5", names(spectra_data_table)), with = FALSE]

    potr5_data <- melt(potr5_data_table, id = "wavelength",value.name = 'reflectance', variable.name = 'taxon_fsp_ID')

    potr5_spectra_plot <- ggplot(potr5_data,
                                aes(x = wavelength, 
                                    y = reflectance, 
                                    color = taxon_fsp_ID)) + geom_line() 

    print(picol_spectra_plot + ggtitle("Spectra of Aspen (POTR5) samples @ RMNP"))

<div class="figure" style="text-align: center">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-potr5-spectra-1.png" alt=" "  />
<p class="caption"> </p>
</div>

Finally, it may be helpful to plot the spectra of two species on the same plot. For this example, we'll show PICOL (Lodgepole Pine) and POTR5 (Quaking Aspen) together, including all 5 measurements of each.


    spectra_data_table2 <- as.data.table(spectra_df2)

    picol_potr5_data_table <- spectra_data_table2[, grep("wavelength|PICOL|POTR5", names(spectra_data_table2)), with = FALSE]

    

    picol_potr5_data <- melt(picol_potr5_data_table, id = "wavelength",value.name = 'reflectance', variable.name = 'taxonID')

    picol_potr5_spectra_plot <- ggplot(picol_potr5_data,
                                aes(x = wavelength, 
                                    y = reflectance, 
                                    color = taxonID)) + geom_line(alpha=0.5) 

    print(picol_potr5_spectra_plot + ggtitle("Spectra of Lodgepole (PICOL) and Aspen (POTR5) samples @ RMNP"))

<div class="figure" style="text-align: center">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-picol-potr5-spectra-1.png" alt=" "  />
<p class="caption"> </p>
</div>

Here we can see that while there is considerable overlap in the visible portion of the electromagnetic spectrum, there are some distinct differences in the spectral signatures between these two species, particularly in the infrared regions.

## Foliar Trait Data

As described in the Field Spectra Data Quick Start Guide, 

> "To find the geographic location of each plant, use the plant crown shapefiles in the Plant foliar physical and chemical properties data product (DP1.10026.001, table cfc_shapefile). For the locations of plants that have not been mapped to shapefiles, follow the instructions in the Data Product User Guide for DP1.10026.001."

This next section outlines how you would go about finding the geolocation information for the field spectra data. This is necessary if you are doing any sort of scaling exercise with the AOP hyperspectral data, which we will demonstrate next.

Let's start by looking at the product information for this foliar trait data product.


    foliar_trait_info <- neonUtilities::getProductInfo('DP1.10026.001')

    #View(foliar_trait_info$siteCodes)

    #View(foliar_trait_info$siteCodes$availableDataUrls)

We can get the `availableDataUrls` of the RMNP site as follows:


    # view the RMNP foliar trait available data urls

    foliar_trait_info$siteCodes[which(foliar_trait_info$siteCodes$siteCode == 'RMNP'),c("availableDataUrls")]

    ## [[1]]
    ## [1] "https://data.neonscience.org/api/v0/data/DP1.10026.001/RMNP/2020-07"

Let's download the foliar trait data from 2020-07 at RMNP to obtain the precise location information of the foliar spectra samples.


    foliar_traits <- loadByProduct(dpID='DP1.10026.001',
                                   site='RMNP',
                                   startdate='2020-07',
                                   package="expanded",
                                   check.size=FALSE)

    names(foliar_traits)

We can use the `geoNEON` package to obtain the refined geolocation information, based on product-specific rules and spatial designs. For more details on this package, please refer to the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/neon-spatial-data-basics" target="_blank">Access and Work with NEON Geolocation Data</a> tutorial.



    vst.loc <- getLocTOS(data=foliar_traits$vst_mappingandtagging,
                         dataProd="vst_mappingandtagging")

Now let's merge the foliar traits `cfc_fieldData` with this `vst.loc` data, which now includes the refined (adjusted) locations.


    foliar_traits_loc <- merge(foliar_traits$cfc_fieldData,vst.loc,by="individualID")

Finally, we can merge this `foliar_traits_loc` data frame with the `spectra_merge` data frame by the `sampleID` in order to link the field spectra samples with the geolocation information. Note that there is also a `crownPolygonID` column, which contains the id of the crown polygon shape file. We will hold off on using this crown polygon for now, but will start by using the adjusted geolocations calculated using `geoNEON` to obtain the corresponding airborne reflectance data.


    spectra_traits <- merge(spectra_merge,foliar_traits_loc,by="sampleID")

    head(spectra_traits[c("spectralSampleID","locationID.x","tagID","taxonID","stemDistance","stemAzimuth","adjEasting","adjNorthing")])

    ##         spectralSampleID          locationID.x tagID taxonID stemDistance stemAzimuth adjEasting adjNorthing
    ## 1 FSP_RMNP_20200716_1215 RMNP_009.basePlot.cfc  3861   POTR5         10.4        28.3   459058.0     4450439
    ## 2 FSP_RMNP_20200714_0910 RMNP_019.basePlot.cfc  4352   PIFL2          5.8       143.5   458176.5     4449625
    ## 3 FSP_RMNP_20200716_1149 RMNP_009.basePlot.cfc  3832   PIFL2         16.9        14.0   459046.8     4450436
    ## 4 FSP_RMNP_20200709_2050 RMNP_041.basePlot.cfc  2496   PICOL         17.6       278.2   453521.1     4458506
    ## 5 FSP_RMNP_20200706_2120 RMNP_004.basePlot.cfc  3472   PICOL          5.8        83.0   453949.4     4448624
    ## 6 FSP_RMNP_20200709_2104 RMNP_041.basePlot.cfc  2510   POTR5         15.0       335.8   453532.4     4458517

Great, now we have the field spectra data and the corresponding locations of the leaf-clip samples. 

## Airborne Reflectance Data

For the final part of this lesson, we will download the airborne reflectance data, and use some pre-defined functions to read the reflectance data into a `terra:rast` Spatial Object, and extract the spectral signature of the pixel corresponding to the location of the leaf-clip sample. We can use the `neonUtilities::byTileAOP` function to download only the 1km x 1km tile that contains the data we're interested in. First, let's set the working directory to where we want to download the data. 



    # set working directory (this will depend on your local environment)

    wd <- "~/data/"

    setwd(wd)

We will download the corresponding reflectance spectra of the pixel corresponding to where a single PICOL sample was located. Let's extract that sample from the `spectral_traits` table so we can easily pull out the geographic information.


    FSP_RMNP_PICOL <- spectra_traits[spectra_traits$spectralSampleID == "FSP_RMNP_20200720_1304",]

Check the `spectralSampleID` and `taxonID`:


    FSP_RMNP_PICOL$spectralSampleID

    ## [1] "FSP_RMNP_20200720_1304"

    FSP_RMNP_PICOL$taxonID

    ## [1] "PICOL"
Download the reflectance data that encompasses this data point. Reflectance data can be quite large (~500-600+ MB per tile), so for this example, we'll only download the single tile needed. We'll leave the `check.size` field empty (default is TRUE), which means we will need to enter `y` in order to continue the download.


    byTileAOP(dpID='DP3.30006.001',

              site='RMNP',

              year=2020,

              easting=FSP_RMNP_PICOL$adjEasting,

              northing=FSP_RMNP_PICOL$adjNorthing,

              include.provisional=TRUE,

              savepath=wd)

This file will be downloaded into a nested subdirectory under the ~/data folder, inside a folder named DP3.30006.001 (the Data Product ID of the aerial reflectance data). The file should show up in this location: ~/data/DP3.30006.001/neon-aop-products/2020/FullSite/D10/2020_RMNP_3/L3/Spectrometer/Reflectance/NEON_D10_RMNP_DP3_455000_4446000_reflectance.h5. Let's define an `h5_file` variable that points to the full path to this file.


    # Define the h5 file name to be opened

    h5_file <- paste0(wd,"DP3.30006.001/neon-aop-products/2020/FullSite/D10/2020_RMNP_3/L3/Spectrometer/Reflectance/NEON_D10_RMNP_DP3_455000_4446000_reflectance.h5")

Now we can use some pre-defined functions for working with the airborne reflectance data. For more details, please refer to the <a href="https://www.neonscience.org/resources/learning-hub/tutorials/introduction-hyperspectral-remote-sensing-data" target="_blank">Introduction to Hyperspectral Remote Sensing</a> tutorial series.



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

Now that we've defined these functions, we can run `lapply` on the band2Raster function, using all the bands. This may take a minute or two to run.



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

Let's plot a single band (in the red wavelength) of the reflectance tile, for reference. 


    plot(refl_rast[[58]])

    #convert the data frame into a shape file (vector)

    m <- vect(cbind(FSP_RMNP_PICOL$adjEasting,
                    FSP_RMNP_PICOL$adjNorthing), crs=h5_meta$crs)

    # plot

    plot(m, add = T)

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-band58-1.png)

And we can zoom in on the sample location.


    x_sub = c(455100, 455200)

    y_sub = c(4446500, 4446600)

    plot(refl_rast[[58]],xlim=x_sub,ylim=y_sub)

    plot(m, add = T)

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-band58-zoom-1.png)

We can also plot an RGB image. First we'll run `lapply` on the band2Raster function, this time using a list only consisting of the RGB bands:


    rgb <- list(58,34,19)

    

    # lapply tells R to apply the function to each element in the list

    rgb_list <- lapply(rgb,
                        FUN = band2Raster,
                        h5_file = h5_file,
                        extent = h5_meta$raster_ext,
                        crs = h5_meta$crs,
                        no_data_value = h5_meta$no_data_value)

    

    rgb_rast <- rast(rgb_list)

Plot the RGB of the entire 1km x 1km tile, as well as zoomed in on the sample location.


    plotRGB(rgb_rast,stretch='lin',axes=TRUE)

    plot(m, col="red", add = T)

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-refl-rgb-1.png)

    #zoom in

    plotRGB(rgb_rast,stretch='lin',xlim=x_sub,ylim=y_sub)

    plot(m, col="red", add = T)

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-refl-rgb-2.png)

Next we can extract the aerial reflectance spectra using the `terra::extract` function as follows. We'll create a data frame of the wavelengths and reflectance of that pixel.


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

<div class="figure" style="text-align: center">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/extract-air-refl-spectra-1.png" alt=" "  />
<p class="caption"> </p>
</div>

Plot the leaf-clip spectra of this PICOL sample.


    spectra_data_table <- as.data.table(spectra_df)

    picol_data_table <- spectra_data_table[, grep("wavelength|PICOL_20200720_1304", names(spectra_data_table)), with = FALSE]

    picol_data <- melt(picol_data_table, id = "wavelength",value.name = 'reflectance', variable.name = 'taxon_fsp_ID')

    picol_leafclip_plot <- ggplot(picol_data,
                                 aes(x = wavelength, 
                                     y = reflectance)) + geom_line() 

    print(picol_leafclip_plot + ggtitle("Leaf-Clip Spectra of PICOL FSP_RMNP_20200720_1304"))

<div class="figure" style="text-align: center">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-picol-spectra-leafclip-1.png" alt=" "  />
<p class="caption"> </p>
</div>

## Plotting Leaf-Clip and Airborne Data Together

Finally, let's make a plot of these two spectra (leaf-clip and aerial reflectance) together.


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

<div class="figure" style="text-align: center">
<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AOP/Hyperspectral/Field-Spectra/rfigs/plot-picol-spectra-both-1.png" alt=" "  />
<p class="caption"> </p>
</div>

Why is there a difference between the leaf-clip spectra and the remotely-sensed spectra of the corresponding pixel? Here are a few things to consider ...

Each reflectance pixel represents a 1m x 1m area, so it contains an average spectra of all the vegetation and non-vegetation that are contained in that area. For example, a single pixel could contain the reflectance of a mix of leaves as well as branches, and any gaps in the tree canopy (eg. the ground under the tree). This averaging is called "spectral mixing" and you can perform "spectral un-mixing" to decompose an average spectra into it's component parts. These leaf clip spectra can be used as "end-members", in classification applications, for example. 

Also, it is important to understand that there are uncertainties in the ASD measurements as well as the airborne spectra. There may be some geographic uncertainty associated with both the airborne data (which has 0.5 m horizontal resolution), as well as with the field sample geolocations. There is also some uncertainty in the spectral data itself. For example, there is uncertainty resulting from the atmospheric correction applied when generating the reflectance data from the at-sensor-radiance. Weather conditions during the flight are important to consider as well. The Airborne Observation Platform is typically able to collect the coincident overflights in clear weather, but this may not always be the case. For more on hyperspectral uncertainties and variation, please refer to the <a href="https://data.neonscience.org/api/v0/documents/NEON.DOC.004365vB?inline=true" target="_blank">Spectrometer Mosaic ATBD</a> (Algorithm Theoretical Basis Document).

### Next Steps

Hopefully this tutorial provides a bouncing-off point for more exploratory analysis and/or in-depth research. What else might you want to explore, using these three integrated datasets?

Here are some ideas to pursue on your own:

1. We demonstrated how to plot the field spectral sample together with the aerial reflectance of the pixel. What if there is a geographic mis-match between the field and airborne data? What other approaches could you use to align these datasets (eg. applying a buffer, integrating the CHM data)?

2. Starting in 2020 (including RMNP 2020), the foliar traits data products include shape files of the polygons of the tree crowns where the samples are taken from. Try pulling in that tree crown shape files and plotting the average spectra inside the tree crown area. 


<div id="ds-dataTip" markdown="1">

<i class="fa fa-star"></i> **Data Tip:** to see what crown polygon data are available, you can specify `tabl='cfc_shapefile'` in the `loadByProduct` function:

```
polygons <- loadByProduct(dpID='DP1.10026.001', 
                          tabl='cfc_shapefile', 
                          include.provisional=T,
                          check.size=F)
```

</div>

The foliar trait data is also a key data set for scaling - for example, a common ecological application would be to develop foliar trait models from the airborne reflectance data, using the in-situ foliar trait data to train the model, eg. <a href="https://nph.onlinelibrary.wiley.com/doi/full/10.1111/nph.16711" target="_blank">Foliar functional traits from imaging spectroscopy across biomes in eastern North America (Wang et al. 2020)</a>. NEON is currently developing foliar trait data products following this method. This is beyond the scope of this lesson, but the initial steps for conducting that sort of analysis using NEON data would be the same.
