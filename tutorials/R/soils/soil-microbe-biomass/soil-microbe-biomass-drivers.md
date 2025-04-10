---
title: "Soil temperature and moisture controls on soil microbial biomass"
syncID: b5183dec9d8844d28e5b892971517ff8
description: Explore the relationships between microbial biomass and soil temperature and moisture
authors: Edward Ayres
contributors: 
estimatedTime: 1 hour
packagesLibraries: neonUtilities
topics: soil temperature, soil moisture, soil microbial biomass
languagesTool: R
dataProduct: DP1.10104.001, DP1.10086.001
code1: "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/soils/soil-microbe-biomass/soil-microbe-biomass-drivers.R"
tutorialSeries: 
urlTitle: "soil-biomass-drivers"
dateCreated: "2024-3-26"
---

Soil microbial biomass is the mass of bacteria and fungi in the soil and although it is a relatively small component of soil organic matter, these microbes play a major role in several ecosystem processes, including decomposition, nutrient cycling, and soil carbon stabilization. There are many ways to measure microbial biomass and NEON uses the amount of phospholipid fatty acids (PLFAs) in the soil because they turn over quickly making them a good proxy for the amount of living microbial mass. Many factors are known to influence soil microbial biomass, such as soil organic carbon content, vegetation type and litter inputs, soil type, and abiotic conditions, such as temperature and water availability. In this tutorial we'll investigate the relationship between soil microbial biomass and soil temperature and moisture at one NEON site. This will involve downloading NEON data, combining data from different NEON data products, filtering out suspect data, and exploring the microbial biomass relationship with soil temperature and moisture. We'll be using two different NEON data products: 

* **DP1.10104.001, Soil microbe biomass**
* **DP1.10086.001, Soil physical and chemical properties, periodic**

<a href="https://data.neonscience.org/data-products/DP1.10104.001" target="_blank">Soil microbial biomass</a> and corresponding <a href="https://data.neonscience.org/data-products/DP1.10086.001" target="_blank">soil sample temperature and moisture</a> are measured in ten plots at each NEON terrestrial site one-to-three times per year, with each site always sampled during the historic peak in vegetation greenness and sometimes sampled during other seasons or seasonal transition. 

We will be using data from the <a href="https://www.neonscience.org/field-sites/guan" target="_blank">Guanica Forest</a> (GUAN) site in Puerto Rico. The site is in a subtropical dry zone along the southern coast of Puerto Rico characterized by low annual rainfall averaging 840 mm and high evapotranspiration. Given that temperatures are warm and fairly stable at this subtropical site and precipitation is relatively low, we might expect to see a stronger relationship between microbial biomass and soil moisture than with soil temperature, so let's see what the data show.

<div id="ds-objectives" markdown="1">

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R loaded on your computer to complete this tutorial.

</div>

## 1. Setup

Start by installing (if necessary) and loading the `neonUtilities` package.

Installation can be run once, then periodically to get package updates.


    install.packages("neonUtilities")

Now load the package. This needs to be done every time you run code. 


    library(neonUtilities)


## 2. Download the data

Download the soil microbial biomass and soil properties 
data using the `loadByProduct()` function in the `neonUtilities` package. Inputs 
needed for the function are:

* `dpID`: data product ID; soil microbe biomass = DP1.10104.001 (or soil properties, periodic = DP1.10086.001)
* `site`: (vector of) 4-letter site codes; Guanica Forest = GUAN
* `release`: data release to download; we'll use the current latest release: RELEASE-2024
* `check.size`: should this function prompt the user with an estimated download size? Set to `FALSE` here for ease of processing as a script, but good to leave as default `TRUE` when downloading a dataset for the first time.

Since microbial biomass is only measured a few times per year in ten plots the amounts of data is relatively small so we'll download all available data by not specifying start and end dates. Refer to the <a href="https://www.neonscience.org/sites/default/files/cheat-sheet-neonUtilities_0.pdf" target="_blank">cheat sheet</a> 
for the `neonUtilities` package for more details if desired.


    microb <- loadByProduct(dpID = "DP1.10104.001", 
                            site = "GUAN", 
                            release = "RELEASE-2024", 
                            check.size = F)

    

    soil <- loadByProduct(dpID = "DP1.10086.001", 
                          site = "GUAN", 
                          release = "RELEASE-2024", 
                          check.size = F)

## 3. Exploring the data

First let's take a look at the microbial data that we downloaded, which is a list of seven tables but we're just going to use two of them: `microb$sme_scaledMicrobialBiomass` and `microb$variables_10104`. We can use the `head()` function to get a sense of what the data look like. There are a lot of columns corresponding to a range of different lipids that might be detected in the phospholipid fatty acid (PLFA) analysis, but we're primarily interested in total microbial biomass as indicated by total lipid concentration (`totalLipidConcentration`). We can also see that at least some of the extractions might not have work correctly as indicated by the `analysisResultsQF` column, so we'll want to filter those out later.


    # View the first few rows of the microbial biomass table

    head(microb$sme_scaledMicrobialBiomass)

    ##                                    uid         namedLocation domainID siteID decimalLatitude
    ## 1 faf0345b-6c99-4291-97b8-3158469824bc GUAN_002.basePlot.bgc      D04   GUAN        17.97029
    ## 2 852db0ae-21d0-427d-a850-a1053b30169f GUAN_002.basePlot.bgc      D04   GUAN        17.97029
    ## 3 4ef91e2c-eb2e-4522-9145-0f1e2e2dbf84 GUAN_002.basePlot.bgc      D04   GUAN        17.97029
    ## 4 903d0136-5615-49e2-9d15-40c534bab370 GUAN_001.basePlot.bgc      D04   GUAN        17.97277
    ## 5 dd6062fa-a2a8-446a-a44e-8125071fb4d7 GUAN_001.basePlot.bgc      D04   GUAN        17.97277
    ## 6 672b7109-c653-441f-863a-429ff0d22842 GUAN_001.basePlot.bgc      D04   GUAN        17.97277
    ##   decimalLongitude geodeticDatum coordinateUncertainty elevation elevationUncertainty   plotID
    ## 1        -66.82463         WGS84                 20.10      86.6                  0.1 GUAN_002
    ## 2        -66.82463         WGS84                 20.10      86.6                  0.1 GUAN_002
    ## 3        -66.82463         WGS84                 20.10      86.6                  0.1 GUAN_002
    ## 4        -66.85124         WGS84                 20.13     149.5                  0.1 GUAN_001
    ## 5        -66.85124         WGS84                 20.13     149.5                  0.1 GUAN_001
    ## 6        -66.85124         WGS84                 20.13     149.5                  0.1 GUAN_001
    ##           collectDate freezeDryMass freezeDryDate analysisDate processedDate    laboratoryName
    ## 1 2018-09-24 12:43:00          7.63          <NA>         <NA>    2020-07-16 Microbial ID, Inc
    ## 2 2018-09-24 13:25:00          8.29          <NA>         <NA>    2020-10-12 Microbial ID, Inc
    ## 3 2018-09-24 13:46:00          7.37          <NA>         <NA>    2020-10-12 Microbial ID, Inc
    ## 4 2018-09-24 15:35:00         13.62          <NA>         <NA>    2020-10-12 Microbial ID, Inc
    ## 5 2018-09-24 16:05:00         14.45          <NA>         <NA>    2020-07-16 Microbial ID, Inc
    ## 6 2018-09-24 16:26:00         12.57          <NA>         <NA>    2020-10-12 Microbial ID, Inc
    ##                      sampleID   sampleCode                      biomassID internalLabID batchID
    ## 1  GUAN_002-M-3.5-32-20180924 A00000038797  GUAN_002-M-3.5-32-20180924-BM MI200709-1301      44
    ## 2    GUAN_002-M-5-13-20180924 A00000038798    GUAN_002-M-5-13-20180924-BM MI200915-2134      77
    ## 3 GUAN_002-M-38-12.5-20180924 A00000038799 GUAN_002-M-38-12.5-20180924-BM MI200915-2133      77
    ## 4 GUAN_001-M-35-28.5-20180924 A00000038802 GUAN_001-M-35-28.5-20180924-BM MI200915-2132      77
    ## 5    GUAN_001-M-7-21-20180924 A00000038800    GUAN_001-M-7-21-20180924-BM MI200709-1300      44
    ## 6   GUAN_001-M-2.5-6-20180924 A00000038801   GUAN_001-M-2.5-6-20180924-BM MI200915-2131      77
    ##   testProtocolVersion c8To0ScaledConcentration c10To0ScaledConcentration c11To0ScaledConcentration
    ## 1    Midi_PLFA_SOP_v1                       NA                         0                         0
    ## 2    Midi_PLFA_SOP_v2                       NA                         0                         0
    ## 3    Midi_PLFA_SOP_v2                       NA                         0                         0
    ## 4    Midi_PLFA_SOP_v2                       NA                         0                         0
    ## 5    Midi_PLFA_SOP_v1                       NA                         0                         0
    ## 6    Midi_PLFA_SOP_v2                       NA                         0                         0
    ##   lipid2OH10To0ScaledConcentration c12To0ScaledConcentration c13To0ScaledConcentration
    ## 1                                0                      0.58                         0
    ## 2                                0                      0.52                         0
    ## 3                                0                      0.65                         0
    ## 4                                0                      0.00                         0
    ## 5                                0                      0.25                         0
    ## 6                                0                      0.00                         0
    ##   lipid2OH12To0ScaledConcentration lipid3OH12To0ScaledConcentration c14To1ScaledConcentration
    ## 1                               NA                               NA                         0
    ## 2                               NA                               NA                         0
    ## 3                               NA                               NA                         0
    ## 4                               NA                               NA                         0
    ## 5                               NA                               NA                         0
    ## 6                               NA                               NA                         0
    ##   c14To0ScaledConcentration i14To0ScaledConcentration i15To0ScaledConcentration
    ## 1                      2.69                      3.79                     19.17
    ## 2                      1.76                      1.81                     13.20
    ## 3                      3.00                      1.91                     18.23
    ## 4                      1.28                      0.96                     11.20
    ## 5                      1.34                      1.51                     11.97
    ## 6                      1.12                      1.12                     11.85
    ##   aC15To0ScaledConcentration c15To0ScaledConcentration c15To1ScaledConcentration
    ## 1                       7.23                      1.77                         0
    ## 2                       5.58                      1.44                         0
    ## 3                       5.72                      2.08                         0
    ## 4                       4.05                      0.83                         0
    ## 5                       4.25                      0.82                         0
    ## 6                       4.14                      0.75                         0
    ##   lipid2OH14To0ScaledConcentration lipid3OH14To0ScaledConcentration i16To0ScaledConcentration
    ## 1                               NA                               NA                     13.82
    ## 2                               NA                               NA                     11.44
    ## 3                               NA                               NA                     12.05
    ## 4                               NA                               NA                      7.08
    ## 5                               NA                               NA                      6.40
    ## 6                               NA                               NA                      6.70
    ##   cis16To1n9ScaledConcentration c16To1n7ScaledConcentration c16To1Cis11ScaledConcentration
    ## 1                          8.24                          NA                           6.76
    ## 2                          5.37                          NA                           4.58
    ## 3                          8.67                          NA                           6.27
    ## 4                          5.42                          NA                           3.25
    ## 5                          5.64                          NA                           4.60
    ## 6                          5.28                          NA                           3.49
    ##   c16To0ScaledConcentration lipid10Methyl16To0ScaledConcentration i17To0ScaledConcentration
    ## 1                     43.00                                 32.25                     10.23
    ## 2                     33.01                                 25.39                      8.75
    ## 3                     49.23                                 32.55                      9.63
    ## 4                     21.17                                 23.04                      5.69
    ## 5                     21.81                                 23.63                      5.31
    ## 6                     19.72                                 22.23                      5.33
    ##   c17To1ScaledConcentration cyclo17To0ScaledConcentration c17To0ScaledConcentration
    ## 1                         0                          4.57                      2.31
    ## 2                         0                          2.51                      1.82
    ## 3                         0                          4.70                      2.49
    ## 4                         0                          3.79                      1.05
    ## 5                         0                          3.12                      1.09
    ## 6                         0                          3.21                      1.04
    ##   c17To0AnteisoScaledConcentration c17To1n7ScaledConcentration lipid2OH16To0ScaledConcentration
    ## 1                             8.39                          NA                                0
    ## 2                             8.18                          NA                                0
    ## 3                             6.84                          NA                                0
    ## 4                             4.52                          NA                                0
    ## 5                             4.00                          NA                                0
    ## 6                             4.05                          NA                                0
    ##   lipid10Methyl17To0ScaledConcentration lipid10Methyl17To1ScaledConcentration
    ## 1                                  1.56                                    NA
    ## 2                                  1.25                                    NA
    ## 3                                  1.43                                    NA
    ## 4                                  0.83                                    NA
    ## 5                                  0.69                                    NA
    ## 6                                  0.78                                    NA
    ##   c18To1n13ScaledConcentration c18To3n6ScaledConcentration cis18To2n912ScaledConcentration
    ## 1                           NA                           0                            5.94
    ## 2                           NA                           0                            4.23
    ## 3                           NA                           0                            7.71
    ## 4                           NA                           0                            1.45
    ## 5                           NA                           0                            1.38
    ## 6                           NA                           0                            0.89
    ##   cis18To1n9ScaledConcentration trans18To1n9ScaledConcentration trans18To2n912ScaledConcentration
    ## 1                         16.55                              NA                                NA
    ## 2                         16.21                              NA                                NA
    ## 3                         20.09                              NA                                NA
    ## 4                          7.11                              NA                                NA
    ## 5                          8.22                              NA                                NA
    ## 6                          6.89                              NA                                NA
    ##   c18To3n3ScaledConcentration c18To1n11ScaledConcentration c18To0ScaledConcentration
    ## 1                          NA                        19.02                        NA
    ## 2                          NA                        13.02                        NA
    ## 3                          NA                        21.22                        NA
    ## 4                          NA                         9.16                        NA
    ## 5                          NA                        10.11                        NA
    ## 6                          NA                         7.31                        NA
    ##   lipid10Methyl18To0ScaledConcentration lipid10Methyl18To1ScaledConcentration
    ## 1                                  6.61                                    NA
    ## 2                                  5.88                                    NA
    ## 3                                  5.80                                    NA
    ## 4                                  3.30                                    NA
    ## 5                                  3.53                                    NA
    ## 6                                  3.84                                    NA
    ##   cyclo19To0ScaledConcentration c19To1Cis10ScaledConcentration c20To4n6ScaledConcentration
    ## 1                         44.34                             NA                        1.21
    ## 2                         38.84                             NA                        0.60
    ## 3                         63.43                             NA                        1.15
    ## 4                         15.82                             NA                        0.42
    ## 5                         18.57                             NA                        0.40
    ## 6                         16.93                             NA                        0.29
    ##   c20To5n3ScaledConcentration c20To3n6ScaledConcentration c20To2ScaledConcentration
    ## 1                        0.22                        0.36                         0
    ## 2                        0.00                        0.00                         0
    ## 3                        0.29                        0.25                         0
    ## 4                        0.00                        0.14                         0
    ## 5                        0.00                        0.12                         0
    ## 6                        0.00                        0.00                         0
    ##   c20To1ScaledConcentration c20To3n3ScaledConcentration c20To0ScaledConcentration
    ## 1                      1.31                          NA                      1.11
    ## 2                      0.76                          NA                      1.38
    ## 3                      1.44                          NA                      2.41
    ## 4                      0.61                          NA                      0.52
    ## 5                      0.68                          NA                      0.41
    ## 6                      0.52                          NA                      0.44
    ##   c21To0ScaledConcentration c22To2ScaledConcentration c22To1n9ScaledConcentration
    ## 1                         0                         0                           0
    ## 2                         0                         0                           0
    ## 3                         0                         0                           0
    ## 4                         0                         0                           0
    ## 5                         0                         0                           0
    ## 6                         0                         0                           0
    ##   c22To0ScaledConcentration c22To6CisScaledConcentration c23To0ScaledConcentration
    ## 1                      0.53                            0                      0.35
    ## 2                      1.41                            0                      0.25
    ## 3                      2.28                            0                      0.84
    ## 4                      0.46                            0                      0.00
    ## 5                      0.24                            0                      0.00
    ## 6                      0.48                            0                      0.00
    ##   c24To1ScaledConcentration c24To0ScaledConcentration totalLipidScaledConcentration
    ## 1                         0                      0.66                        264.57
    ## 2                         0                      2.08                        211.29
    ## 3                         0                      2.85                        295.21
    ## 4                         0                      0.42                        133.57
    ## 5                         0                      0.26                        140.32
    ## 6                         0                      0.37                        128.78
    ##   lipidInternalStandardID lipidInternalStandardConcentration lipidInternalStandardResponse
    ## 1                    <NA>                                 NA                            NA
    ## 2                    <NA>                                 NA                            NA
    ## 3                    <NA>                                 NA                            NA
    ## 4                    <NA>                                 NA                            NA
    ## 5                    <NA>                                 NA                            NA
    ## 6                    <NA>                                 NA                            NA
    ##                processedBy                       reviewedBy remarks analysisResultsQF dataQF
    ## 1 X3dKIAlqROSj6yvdqziKsQ==         ujgT9aJ6r0v1tDEzqHQgRg==    <NA>                OK   <NA>
    ## 2 X3dKIAlqROSj6yvdqziKsQ== R4/UGDekA77/irTWzC9I3x3ZBDsojeHY    <NA>                OK   <NA>
    ## 3 X3dKIAlqROSj6yvdqziKsQ== R4/UGDekA77/irTWzC9I3x3ZBDsojeHY    <NA>                OK   <NA>
    ## 4 X3dKIAlqROSj6yvdqziKsQ== R4/UGDekA77/irTWzC9I3x3ZBDsojeHY    <NA>                OK   <NA>
    ## 5 X3dKIAlqROSj6yvdqziKsQ==         ujgT9aJ6r0v1tDEzqHQgRg==    <NA>                OK   <NA>
    ## 6 X3dKIAlqROSj6yvdqziKsQ== R4/UGDekA77/irTWzC9I3x3ZBDsojeHY    <NA>                OK   <NA>
    ##    publicationDate      release
    ## 1 20231228T192405Z RELEASE-2024
    ## 2 20231228T192405Z RELEASE-2024
    ## 3 20231228T192405Z RELEASE-2024
    ## 4 20231228T192405Z RELEASE-2024
    ## 5 20231228T192405Z RELEASE-2024
    ## 6 20231228T192405Z RELEASE-2024

There is known contamination of lipid c18To0 from the Buyer and Sasser high-throughput PLFA method that comes from the solid phase extraction 96 well plates used. Prior to November 2021 this lipid was excluded from the results and no correction to the total lipid concentration data is necessary, however, since then c18To0 has been reported in the data and needs to be subtracted from the total lipid concentration to get a reliable estimate of microbial biomass. Note that an alternative approach to correcting the total lipid concentration data is to perform a blank correction based on lipid concentrations reported in blanks in the `microb$sme_batchResults` table.


    # Identify pre- (i.e., c18To0ScaledConcentration = NA) and post-November 2021 data

    preNov2021 <- is.na(microb$sme_scaledMicrobialBiomass$c18To0ScaledConcentration)

    

    # Add the pre-November 2021 total lipid concentration data to a new column (no correction needed)

    microb$sme_scaledMicrobialBiomass$correctedTotLipidConc[preNov2021] <- 
      microb$sme_scaledMicrobialBiomass$totalLipidScaledConcentration[preNov2021]

    

    # Add the corrected (totalLipidScaledConcentration - c18To0ScaledConcentration) total lipid concentration data to the new column

    microb$sme_scaledMicrobialBiomass$correctedTotLipidConc[!preNov2021] <- 
      microb$sme_scaledMicrobialBiomass$totalLipidScaledConcentration[!preNov2021] - 
      microb$sme_scaledMicrobialBiomass$c18To0ScaledConcentration[!preNov2021]

To find the units of the total lipid concentration data we can use the `microb$variables_10104` table, which provides information about each column in the data product. The units are nanomoles of lipids per gram of soil.


    # Identify the units of the totalLipidConcentration data

    microb$variables_10104[grep("totalLipidConcentration", microb$variables_10104$fieldName), c("description", "units")]

    ##                                                                                    description
    ##                                                                                         <char>
    ## 1: Total lipid concentration calculated as the sum of all measured individual lipid components
    ##               units
    ##              <char>
    ## 1: nanomolesPerGram


Next let's look at the soil properties data, which contains 14 tables but we'll just use three of them: `soil$sls_soilCoreCollection` which includes soil temperature at the time of sampling, `soil$sls_soilMoisture`, and lastly `soil$variables_10086` to identify the measurement units.


    # View the first few rows of the soil core table, which includes soil temperature

    head(soil$sls_soilCoreCollection)

    ##                                    uid domainID siteID   plotID         namedLocation    plotType
    ## 1 7cdba53b-fd54-4cee-b004-40172a4bf1fd      D04   GUAN GUAN_005 GUAN_005.basePlot.bgc distributed
    ## 2 3375cf36-12c1-4b14-8fec-22be2b25138e      D04   GUAN GUAN_005 GUAN_005.basePlot.bgc distributed
    ## 3 24573ba0-226b-4584-947b-a47d9a1fe17a      D04   GUAN GUAN_005 GUAN_005.basePlot.bgc distributed
    ## 4 dcf8c867-a596-4ccc-a903-fa600717005d      D04   GUAN GUAN_006 GUAN_006.basePlot.bgc distributed
    ## 5 b8a1a6d6-09ac-4543-967d-c96bf4cc6aad      D04   GUAN GUAN_006 GUAN_006.basePlot.bgc distributed
    ## 6 2b2b3136-a5ec-498a-b6d5-46f464cea7a9      D04   GUAN GUAN_006 GUAN_006.basePlot.bgc distributed
    ##         nlcdClass subplotID coreCoordinateX coreCoordinateY geodeticDatum decimalLatitude
    ## 1 evergreenForest      <NA>            35.5            28.5         WGS84        17.96874
    ## 2 evergreenForest      <NA>            35.5            28.5         WGS84        17.96874
    ## 3 evergreenForest      <NA>            31.0             2.0         WGS84        17.96874
    ## 4 evergreenForest      <NA>            31.0             9.5         WGS84        17.96382
    ## 5 evergreenForest      <NA>            31.0             9.5         WGS84        17.96382
    ## 6 evergreenForest      <NA>            38.5            31.5         WGS84        17.96382
    ##   decimalLongitude coordinateUncertainty elevation elevationUncertainty samplingProtocolVersion
    ## 1        -66.88045                  20.2     164.3                 0.24       NEON.DOC.014048vE
    ## 2        -66.88045                  20.2     164.3                 0.24       NEON.DOC.014048vE
    ## 3        -66.88045                  20.2     164.3                 0.24       NEON.DOC.014048vE
    ## 4        -66.87567                  20.1      98.9                 0.19       NEON.DOC.014048vE
    ## 5        -66.87567                  20.1      98.9                 0.19       NEON.DOC.014048vE
    ## 6        -66.87567                  20.1      98.9                 0.19       NEON.DOC.014048vE
    ##             startDate         collectDate  sampleTiming biophysicalCriteria eventID standingWaterDepth
    ## 1 2015-08-11 12:52:00 2015-08-11 12:52:00 peakGreenness                <NA>    <NA>                  0
    ## 2 2015-08-11 12:52:00 2015-08-11 12:52:00 peakGreenness                <NA>    <NA>                  0
    ## 3 2015-08-11 14:24:00 2015-08-11 14:24:00 peakGreenness                <NA>    <NA>                  0
    ## 4 2015-08-14 12:28:00 2015-08-14 12:28:00 peakGreenness                <NA>    <NA>                  0
    ## 5 2015-08-14 12:28:00 2015-08-14 12:28:00 peakGreenness                <NA>    <NA>                  0
    ## 6 2015-08-14 13:23:00 2015-08-14 13:23:00 peakGreenness                <NA>    <NA>                  0
    ##   nTransBoutType        boutType samplingImpractical incubationMethod incubationCondition
    ## 1             No biogeochemistry                <NA>    no incubation                <NA>
    ## 2             No biogeochemistry                <NA>    no incubation                <NA>
    ## 3             No biogeochemistry                <NA>    no incubation                <NA>
    ## 4             No biogeochemistry                <NA>    no incubation                <NA>
    ## 5             No biogeochemistry                <NA>    no incubation                <NA>
    ## 6             No biogeochemistry                <NA>    no incubation                <NA>
    ##                        sampleID sampleCode toxicodendronPossible horizon horizonDetails soilTemp
    ## 1 GUAN_005-M-35.5-28.5-20150811       <NA>                  <NA>       M           <NA>     26.7
    ## 2 GUAN_005-O-35.5-28.5-20150811       <NA>                  <NA>       O           <NA>     26.7
    ## 3      GUAN_005-M-31-2-20150811       <NA>                  <NA>       M           <NA>     28.2
    ## 4    GUAN_006-O-31-9.5-20150814       <NA>                  <NA>       O           <NA>     28.0
    ## 5    GUAN_006-M-31-9.5-20150814       <NA>                  <NA>       M           <NA>     28.0
    ## 6 GUAN_006-M-38.5-31.5-20150814       <NA>                  <NA>       M           <NA>     28.5
    ##   litterDepth sampleTopDepth sampleBottomDepth sampleExtent soilSamplingDevice soilCoreCount
    ## 1           4            1.5              17.0         <NA>               <NA>             2
    ## 2           4            0.0               1.5         <NA>               <NA>             2
    ## 3           5            0.0              13.0         <NA>               <NA>             1
    ## 4           8            0.0               1.8         <NA>               <NA>             1
    ## 5           8            1.8               9.0         <NA>               <NA>             1
    ## 6           3            0.2              29.0         <NA>               <NA>             1
    ##   geneticSampleID geneticSampleCode geneticSampleCondition geneticSamplePrepMethod
    ## 1            <NA>              <NA>                   <NA>                    <NA>
    ## 2            <NA>              <NA>                   <NA>                    <NA>
    ## 3            <NA>              <NA>                   <NA>                    <NA>
    ## 4            <NA>              <NA>                   <NA>                    <NA>
    ## 5            <NA>              <NA>                   <NA>                    <NA>
    ## 6            <NA>              <NA>                   <NA>                    <NA>
    ##   geneticArchiveSample1ID geneticArchiveSample1Code geneticArchiveSample2ID geneticArchiveSample2Code
    ## 1                    <NA>                      <NA>                    <NA>                      <NA>
    ## 2                    <NA>                      <NA>                    <NA>                      <NA>
    ## 3                    <NA>                      <NA>                    <NA>                      <NA>
    ## 4                    <NA>                      <NA>                    <NA>                      <NA>
    ## 5                    <NA>                      <NA>                    <NA>                      <NA>
    ## 6                    <NA>                      <NA>                    <NA>                      <NA>
    ##   geneticArchiveSample3ID geneticArchiveSample3Code geneticArchiveSample4ID geneticArchiveSample4Code
    ## 1                    <NA>                      <NA>                    <NA>                      <NA>
    ## 2                    <NA>                      <NA>                    <NA>                      <NA>
    ## 3                    <NA>                      <NA>                    <NA>                      <NA>
    ## 4                    <NA>                      <NA>                    <NA>                      <NA>
    ## 5                    <NA>                      <NA>                    <NA>                      <NA>
    ## 6                    <NA>                      <NA>                    <NA>                      <NA>
    ##   geneticArchiveSample5ID geneticArchiveSample5Code geneticArchiveSamplePrepMethod
    ## 1                    <NA>                      <NA>                           <NA>
    ## 2                    <NA>                      <NA>                           <NA>
    ## 3                    <NA>                      <NA>                           <NA>
    ## 4                    <NA>                      <NA>                           <NA>
    ## 5                    <NA>                      <NA>                           <NA>
    ## 6                    <NA>                      <NA>                           <NA>
    ##   geneticArchiveContainer biomassID biomassCode biomassSampleCondition
    ## 1                    <NA>      <NA>        <NA>                   <NA>
    ## 2                    <NA>      <NA>        <NA>                   <NA>
    ## 3                    <NA>      <NA>        <NA>                   <NA>
    ## 4                    <NA>      <NA>        <NA>                   <NA>
    ## 5                    <NA>      <NA>        <NA>                   <NA>
    ## 6                    <NA>      <NA>        <NA>                   <NA>
    ##                                                                                                        remarks
    ## 1 We were not able to reach a depth of 30 cm, soil was collected at the depth that the core was able to reach.
    ## 2                                                                                                         <NA>
    ## 3                                                                 Not able to reach 30 cm depth when sampling.
    ## 4                                                                                                         <NA>
    ## 5                          We were not able to reach 30 cm with coring device due to the obstruction of rocks.
    ## 6                                                                                                         <NA>
    ##               collectedBy     dataQF  publicationDate      release
    ## 1 jaceituno@field-ops.org legacyData 20231226T233738Z RELEASE-2024
    ## 2 jaceituno@field-ops.org legacyData 20231226T233738Z RELEASE-2024
    ## 3 jaceituno@field-ops.org legacyData 20231226T233738Z RELEASE-2024
    ## 4 jaceituno@field-ops.org legacyData 20231226T233738Z RELEASE-2024
    ## 5 jaceituno@field-ops.org legacyData 20231226T233738Z RELEASE-2024
    ## 6 jaceituno@field-ops.org legacyData 20231226T233738Z RELEASE-2024

    # View the first few rows of the soil moisture table

    head(soil$sls_soilMoisture)

    ##                                    uid domainID siteID   plotID         namedLocation
    ## 1 b485f423-4075-4c53-a243-c6024995a826      D04   GUAN GUAN_005 GUAN_005.basePlot.bgc
    ## 2 0d41f81a-6477-4fe8-a2aa-0995f2ce6b0e      D04   GUAN GUAN_005 GUAN_005.basePlot.bgc
    ## 3 e5fe378a-57e7-42a3-aa4e-0d45e32be776      D04   GUAN GUAN_005 GUAN_005.basePlot.bgc
    ## 4 b6307a37-b72c-443b-9075-ef18745f857c      D04   GUAN GUAN_006 GUAN_006.basePlot.bgc
    ## 5 d33d060e-4667-47e5-b2ef-b778a94f5c9c      D04   GUAN GUAN_006 GUAN_006.basePlot.bgc
    ## 6 b04f4770-b6fe-4b8e-bc74-8a3016ec4646      D04   GUAN GUAN_006 GUAN_006.basePlot.bgc
    ##             startDate         collectDate                      sampleID sampleCode
    ## 1 2015-08-11 12:52:00 2015-08-11 12:52:00 GUAN_005-O-35.5-28.5-20150811       <NA>
    ## 2 2015-08-11 12:52:00 2015-08-11 12:52:00 GUAN_005-M-35.5-28.5-20150811       <NA>
    ## 3 2015-08-11 14:24:00 2015-08-11 14:24:00      GUAN_005-M-31-2-20150811       <NA>
    ## 4 2015-08-14 12:28:00 2015-08-14 12:28:00    GUAN_006-O-31-9.5-20150814       <NA>
    ## 5 2015-08-14 12:28:00 2015-08-14 12:28:00    GUAN_006-M-31-9.5-20150814       <NA>
    ## 6 2015-08-14 13:23:00 2015-08-14 13:23:00 GUAN_006-O-38.5-31.5-20150814       <NA>
    ##                   moistureSampleID samplingProtocolVersion horizon       ovenStartDate
    ## 1 GUAN_005-O-35.5-28.5-20150811-SM       NEON.DOC.014048vF       O 2015-08-12 16:00:00
    ## 2 GUAN_005-M-35.5-28.5-20150811-SM       NEON.DOC.014048vF       M 2015-08-12 16:00:00
    ## 3      GUAN_005-M-31-2-20150811-SM       NEON.DOC.014048vF       M 2015-08-12 16:00:00
    ## 4    GUAN_006-O-31-9.5-20150814-SM       NEON.DOC.014048vF       O 2015-08-14 17:04:00
    ## 5    GUAN_006-M-31-9.5-20150814-SM       NEON.DOC.014048vF       M 2015-08-14 17:13:00
    ## 6 GUAN_006-O-38.5-31.5-20150814-SM       NEON.DOC.014048vF       O 2015-08-14 17:45:00
    ##           ovenEndDate boatMass freshMassBoatMass dryMassBoatMass soilMoisture dryMassFraction
    ## 1 2015-08-14 16:47:00     1.10              6.15            5.00        0.295           0.772
    ## 2 2015-08-14 16:50:00     1.10             11.11            9.27        0.225           0.816
    ## 3 2015-08-14 16:51:00     1.08             11.09            8.24        0.398           0.715
    ## 4 2015-08-17 16:00:00     1.07              6.08            5.30        0.184           0.844
    ## 5 2015-08-17 16:00:00     1.07             11.07            9.50        0.186           0.843
    ## 6 2015-08-17 16:00:00     1.09              6.09            5.70        0.085           0.922
    ##   sampleCondition smRemarks smMeasuredBy   smDataQF  publicationDate      release
    ## 1            <NA>      <NA>         <NA> legacyData 20231226T233738Z RELEASE-2024
    ## 2            <NA>      <NA>         <NA> legacyData 20231226T233738Z RELEASE-2024
    ## 3            <NA>      <NA>         <NA> legacyData 20231226T233738Z RELEASE-2024
    ## 4            <NA>      <NA>         <NA> legacyData 20231226T233738Z RELEASE-2024
    ## 5            <NA>      <NA>         <NA> legacyData 20231226T233738Z RELEASE-2024
    ## 6            <NA>      <NA>         <NA> legacyData 20231226T233738Z RELEASE-2024

We can find the units of the soil temperature and soil moisture data in `soil$variables_10086`, which are °C and g water/g soil, respectively.


    # Identify the units of the soilTemp data

    soil$variables_10086[grep("soilTemp", soil$variables_10086$fieldName), c("description", "units")]

    ##                                                 description  units
    ##                                                      <char> <char>
    ## 1: In-situ temperature of soil at approximately 10 cm depth degree

    # Identify the units of the soilTemp data

    soil$variables_10086[grep("soilMoisture", soil$variables_10086$fieldName), c("description", "units")]

    ##                                                              description        units
    ##                                                                   <char>       <char>
    ## 1: Gravimetric water content of soil in grams of water per gram dry soil gramsPerGram


## 4. Combining the data

We have all the data we need but they are currently in several different tables that need to be combined. We'll use the `merge()` function and combine the tables using the `sampleID` column.


    # Merge microbial biomass and soil core data tables

    coreMicrob <- merge(soil$sls_soilCoreCollection, microb$sme_scaledMicrobialBiomass, by="sampleID")

    

    # Merge soil moisture table with microbial and core table

    swcMicrob <- merge(soil$sls_soilMoisture, coreMicrob, by="sampleID")


## 5. Microbial biomass relationship with soil temperature

Next let's identify the sampling plots so we can show the relationship between microbial biomass and soil temperature for each plot. Then we'll create colors for each sampling plot to use in the graph, identify the rows that passed the sample QA/QC tests, and plot the temperature-microbial biomass relationship.


    # Identify the different soil plots represented in the table

    soilPlots <- unique(swcMicrob$plotID)

    

    # Create a color vector with a different color for each soil plot

    colors <- rainbow(length(soilPlots))

    

    # Identify rows that passed the QA/QC tests

    goodRows <- grep("OK", swcMicrob$analysisResultsQF)

    

    # Create an empty plotting window for the soil temperature and microbial biomass relationship

    plot(swcMicrob$soilTemp, 
         swcMicrob$correctedTotLipidConc, 
         pch=NA, 
         xlab="Soil temperature (degrees C)", 
         ylab="Microbial biomass (nmol lipids/g soil)")

    

    # Loop through the soil plots and add the temperature-microbial biomass relationship

    for(i in 1:length(soilPlots)){
      points(swcMicrob$soilTemp[intersect(goodRows, grep(soilPlots[i], swcMicrob$plotID))], 
             swcMicrob$correctedTotLipidConc[intersect(goodRows, grep(soilPlots[i], swcMicrob$plotID))], 
             col=colors[i])
    }

    

    # Add a plot legend

    legend("topleft", legend=soilPlots, col=colors, pch=1, bty="n")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/soils/soil-microbe-biomass/rfigs/mb-temp-plot-1.png)

There isn't an obvious relationship between soil temperature and microbial biomass and the range in soil temperature is relatively narrow due to the subtropical location of the site.


## 6. Microbial biomass relationship with soil moisture

Now let's make a similar plot using soil moisture instead of soil temperature.


    # Create an empty plotting window for the soil moisture and microbial biomass relationship

    plot(swcMicrob$soilMoisture, 
         swcMicrob$correctedTotLipidConc, 
         pch=NA, 
         xlab="Soil moisture (g water / g soil)", 
         ylab="Microbial biomass (nmol lipids/g soil)")

    

    # Loop through the soil plots and add the moisture-microbial biomass relationship

    for(i in 1:length(soilPlots)){
      points(swcMicrob$soilMoisture[intersect(goodRows, grep(soilPlots[i], swcMicrob$plotID))], 
             swcMicrob$correctedTotLipidConc[intersect(goodRows, grep(soilPlots[i], swcMicrob$plotID))], 
             col=colors[i])
    }

    

    # Add a plot legend

    legend("topleft", legend=soilPlots, col=colors, pch=1, bty="n")

![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/soils/soil-microbe-biomass/rfigs/mb-swc-plot-1.png)

There's a lot of noise, but generally there appears to be a positive relationship between soil moisture and microbial biomass. Given the warm but relatively dry conditions at GUAN it is perhaps not surprising that microbial biomass increases when more water is available in the soil.

It is likely that many other factors besides soil temperature and moisture also influence microbial biomass. Some of these relationships could be further explored using these data products (e.g., soil pH or organic carbon content) as well as other NEON data (e.g., root biomass). In addition, NEON data from across the US could be used to identify the dominant drivers of microbial biomass in different meteorological zones.
