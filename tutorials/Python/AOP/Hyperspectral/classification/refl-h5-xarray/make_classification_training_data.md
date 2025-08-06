---
syncID: 6eb4422d262440408f7905d1dd3d1ae2
title: "Make Training Data for Species Modeling from NEON TOS Vegetation Structure Data"
description: "Create a training dataset for tree classification using TOS vegetation structure data."
dateCreated: 2025-07-30
authors: Bridget Hass
contributors: Claire Lunch
estimatedTime: 30 minutes
packagesLibraries: Python
topics: vegetation structure, classification
languageTool: Python
dataProduct: DP1.10098.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/classification/refl-h5-xarray/make_classification_training_data.ipynb
tutorialSeries: 
urlTitle: classification-training-data

---

<div id="ds-objectives" markdown="1">

This notebook demonstrates how to generate a training dataset consisting of tree species, family, and location from the NEON Terrestrial Observation System (TOS) Vegetation Structure data product <a href="https://data.neonscience.org/data-products/DP1.10098.001" target=_blank>DP1.10098.001</a>. We will use data from the <a href="https://www.neonscience.org/field-sites/serc" target=_blank>Smithsonian Environmental Research Center (SERC)</a> site in Maryland. In a subsequent tutorial titled <a href="https://www.neonscience.org/resources/learning-hub/tutorials/refl-classification-pyxarray" target=_blank>Tree Classification with NEON Airborne Imaging Spectrometer Data using Python xarray</a>, we will use this training dataset to train a random forest machine learning model that predicts tree families from the hyperspectral signatures obtained from the airborne remote sensing data. These two tutorials outline a relatively simple modeling example, and represent a starting point for conducting machine learning analyses using NEON data!

### Learning Objectives
- Use the `neonutilities` `load_by_product` function to read in NEON vegetation structure data at a given site
- Use the NEON locations API to determine the geographic position of the vegetation records in UTM x, y coordinates
- Filter the datset to include only the latest data and columns of interest
- Filter the data geospatially to keep data that are within a single AOP 1 km x 1 km tile
  
### Additional Resources

- The lesson <a href="https://www.neonscience.org/resources/learning-hub/tutorials/tree-heights-veg-structure-chm" target=_blank>Compare tree height measured from the ground to a Lidar-based Canopy Height Model</a> is another example of linking ground to airborne data, and shows similar steps of pre-processing TOS woody vegetation data.

- The paper <a href="https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.3002700" target=_blank>Individual canopy tree species maps for the National Ecological Observatory Network</a> outlines methods for large-scale classification using NEON data. The associated NEON Science Seminar <a href="https://www.neonscience.org/get-involved/events/science-seminar-harnessing-neon-enable-future-forest-remote-sensing" target=_blank>Harnessing NEON to enable the future of forest remote sensing</a> may be a useful resource. This talk provides a high-level overview of modeling approaches for tree crown delineation and tree classification using NEON airborne remote sensing data. You can also watch the video below.

<iframe width="560" height="315" src="https://www.youtube.com/watch?v=Weru3hJbwTs&t=3s" frameborder="0" allowfullscreen></iframe>

- Refer to the <a href="https://data.neonscience.org/api/v0/documents/NEON_vegStructure_userGuide_vE?inline=true" target=_blank> vegetation structure user guide</a> for more details on this data product, and to better understand the data quality flags, the sampling.

**Disclaimer**: this notebook is intended to provide an example of how to create an initial training data set for pairing with remote sensing data, and to conduct some exploratory analysis of the vegetation structure data. This does not incporporate outlier detection and removal, or comprehensive pre-processing steps. As part of creating a machine learning model, it is important to assess the training data quality and look for outliers or other potential data quality issues which may impact model results.


</div>


```python
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import neonutilities as nu
import numpy as np
import pandas as pd
import requests
import seaborn as sns
```

## Download and Explore Vegetation Structure Data (DP1.10098.001)

In this first section we’ll load the vegetation structure data, find the locations of the mapped trees, and join to the species and family observations.

Download the vegetation structure data using the `load_by_product` function in the `neonutilities` package (imported as `nu`). Inputs to the function can be shown by typing `help(load_by_product)`.
  
Refer to t  e<a href=https://www.neonscience.org/sites/default/files/cheat-sheet-neonUtilities.pdf target=_blank R neonutilities cheat sheet</a>  or the neonUtilities package for more details and the complete index of possible function inputs. The cheat sheet is focused on the R package, but nearly all the inputs are the sam.e

Note that in this example, we will pull in all the woody vegetation data (collected over all years), but if you are trying to modeldata collected  in a single year, you can select just that year by specifying the `startdate` and `enddate`, or later filtering out the vegetation data by the` eventI`D We have set `check_size=False` since the data are not very large, but to check the size of what the data you are downloading first, you could omit this input, or set it to `True`..


```python
veg_dict = nu.load_by_product(dpid="DP1.10098.001", 
                              site="SERC", 
                              package="basic", 
                              release="RELEASE-2025",
                              check_size=False)
```

    Finding available files
    100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 23/23 [00:56<00:00,  2.46s/it]
    Downloading 23 NEON DP1.10098.001 files totaling approximately 40.0 MB.
    Downloading files
    100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 23/23 [00:24<00:00,  1.07s/it]
    C:\Users\bhass\.conda\envs\lpdaac_vitals\lib\site-packages\neonutilities\unzip_and_stack.py:140: UserWarning: Filepaths on Windows are limited to 260 characters. Attempting to extract a filepath that is > 260 characters long. Move your working or savepath directory closer to the root directory or enable long path support in Windows.
      warnings.warn(
    Stacking data files
    100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 4/4 [00:01<00:00,  2.38it/s]
    

Get a list of the points


```python
veg_map_all = veg_dict["vst_mappingandtagging"]
veg_map = veg_map_all.loc[veg_map_all["pointID"] != ""]
veg_map = veg_map.reindex()
veg_map["points"] = veg_map["namedLocation"] + "." + veg_map["pointID"]
veg_points = list(set(list(veg_map["points"])))
```

Look at the unique `eventID`s. . All sampling at a site that occurs within a given bout is identified by a unique eventID, which represents the date of the bout.


```python
veg_map_all.eventID.unique()
```




    array(['vst_SERC_2015', 'vst_SERC_2016', 'vst_SERC_2017', 'vst_SERC_2018',
           'vst_SERC_2019', 'vst_SERC_2020', 'vst_SERC_2021', 'vst_SERC_2022',
           'vst_SERC_2023'], dtype=object)



Get the number of records for each `eventID`:


```python
# Group by 'eventID' and get the count
eventID_counts = veg_map_all[['individualID','eventID']].groupby(['eventID']).count()
print("\nCounts of each eventID:\n", eventID_counts)
```

    
    Counts of each eventID:
                    individualID
    eventID                    
    vst_SERC_2015          1890
    vst_SERC_2016          1330
    vst_SERC_2017            96
    vst_SERC_2018           127
    vst_SERC_2019           254
    vst_SERC_2020            22
    vst_SERC_2021            54
    vst_SERC_2022           494
    vst_SERC_2023            40
    

It looks like most of the trees were mapped in 2015 and 2016, which was when the SERC plots were first established. You could look at data only from one year, and compare to AOP data from the same year, or if you are not too worried about matching measurements to remote sensing data collected in the same year, you could use all years. We'll do the latter in this example.

## Determine the geographic location of the surveyed vegetation

Loop through all of the points in `veg_points` to determine the easting and norhting from the <a href="https://data.neonscience.org/data-api/endpoints/locations/" target=_blank>NEON Locations API</a>.



```python
easting = []
northing = []
coord_uncertainty = []
elev_uncertainty = []
for i in veg_points:
    vres = requests.get("https://data.neonscience.org/api/v0/locations/"+i)
    vres_json = vres.json()
    easting.append(vres_json["data"]["locationUtmEasting"])
    northing.append(vres_json["data"]["locationUtmNorthing"])
    props = pd.DataFrame.from_dict(vres_json["data"]["locationProperties"])
    cu = props.loc[props["locationPropertyName"]=="Value for Coordinate uncertainty"]["locationPropertyValue"]
    coord_uncertainty.append(cu[cu.index[0]])
    eu = props.loc[props["locationPropertyName"]=="Value for Elevation uncertainty"]["locationPropertyValue"]
    elev_uncertainty.append(eu[eu.index[0]])

pt_dict = dict(points=veg_points, 
               easting=easting,
               northing=northing,
               coordinateUncertainty=coord_uncertainty,
               elevationUncertainty=elev_uncertainty)

pt_df = pd.DataFrame.from_dict(pt_dict)
pt_df.set_index("points", inplace=True)

veg_map = veg_map.join(pt_df, 
                     on="points", 
                     how="inner")
```

Next, use the `stemDistance` and `stemAzimuth` data to calculate the precise locations of individuals, relative to the reference locations.

- $Easting = easting.pointID + stemDistance*sin(\theta)$
- $Northing = northing.pointID + stemDistance*cos(\theta)$
- $\theta = stemAzimuth*\pi/180$

Also adjust the coordinate and elevation uncertainties.


```python
veg_map["adjEasting"] = (veg_map["easting"]
                        + veg_map["stemDistance"]
                        * np.sin(veg_map["stemAzimuth"]
                                   * np.pi / 180))

veg_map["adjNorthing"] = (veg_map["northing"]
                        + veg_map["stemDistance"]
                        * np.cos(veg_map["stemAzimuth"]
                                   * np.pi / 180))

veg_map["adjCoordinateUncertainty"] = veg_map["coordinateUncertainty"] + 0.6

veg_map["adjElevationUncertainty"] = veg_map["elevationUncertainty"] + 1
```

Look at the columns to see all the information contained in this dataset.


```python
veg_map.columns
```




    Index(['uid', 'namedLocation', 'date', 'eventID', 'domainID', 'siteID',
           'plotID', 'pointID', 'stemDistance', 'stemAzimuth', 'recordType',
           'individualID', 'supportingStemIndividualID', 'previouslyTaggedAs',
           'otherTagID', 'otherTagOrg', 'samplingProtocolVersion',
           'identificationHistoryID', 'taxonID', 'scientificName', 'genus',
           'family', 'taxonRank', 'identificationReferences', 'morphospeciesID',
           'morphospeciesIDRemarks', 'identificationQualifier', 'remarks',
           'measuredBy', 'recordedBy', 'dataQF', 'publicationDate', 'release',
           'points', 'easting', 'northing', 'coordinateUncertainty',
           'elevationUncertainty', 'adjEasting', 'adjNorthing',
           'adjCoordinateUncertainty', 'adjElevationUncertainty'],
          dtype='object')



### Combine location with tree traits

Now we have the mapped locations of individuals in the `vst_mappingandtagging` table, and the annual measurements of tree dimensions such as height and diameter in the vst_apparentindividual table. To bring these measurements together, join the two tables. Refer to the <a href="https://data.neonscience.org/api/v0/documents/quick-start-guides/NEON.QSG.DP1.00001.001v2?inline=TRUE" target=_blank>Quick Start Guide for Vegetation Structure</a> for more information about the data tables and the joining instructions.


```python
veg_dict["vst_apparentindividual"].set_index("individualID", inplace=True)
veg = veg_map.join(veg_dict["vst_apparentindividual"],
                   on="individualID",
                   how="inner",
                   lsuffix="_MAT",
                   rsuffix="_AI")
```


```python
# show all the columns in the joined veg dataset
veg.columns
```




    Index(['uid_MAT', 'namedLocation_MAT', 'date_MAT', 'eventID_MAT',
           'domainID_MAT', 'siteID_MAT', 'plotID_MAT', 'pointID', 'stemDistance',
           'stemAzimuth', 'recordType', 'individualID',
           'supportingStemIndividualID', 'previouslyTaggedAs', 'otherTagID',
           'otherTagOrg', 'samplingProtocolVersion', 'identificationHistoryID',
           'taxonID', 'scientificName', 'genus', 'family', 'taxonRank',
           'identificationReferences', 'morphospeciesID', 'morphospeciesIDRemarks',
           'identificationQualifier', 'remarks_MAT', 'measuredBy_MAT',
           'recordedBy_MAT', 'dataQF_MAT', 'publicationDate_MAT', 'release_MAT',
           'points', 'easting', 'northing', 'coordinateUncertainty',
           'elevationUncertainty', 'adjEasting', 'adjNorthing',
           'adjCoordinateUncertainty', 'adjElevationUncertainty', 'uid_AI',
           'namedLocation_AI', 'date_AI', 'eventID_AI', 'domainID_AI', 'siteID_AI',
           'plotID_AI', 'subplotID', 'tempStemID', 'tagStatus', 'growthForm',
           'plantStatus', 'stemDiameter', 'measurementHeight',
           'changedMeasurementLocation', 'height', 'baseCrownHeight',
           'breakHeight', 'breakDiameter', 'maxCrownDiameter',
           'ninetyCrownDiameter', 'canopyPosition', 'shape', 'basalStemDiameter',
           'basalStemDiameterMsrmntHeight', 'maxBaseCrownDiameter',
           'ninetyBaseCrownDiameter', 'dendrometerInstallationDate',
           'initialGapMeasurementDate', 'initialBandStemDiameter',
           'initialDendrometerGap', 'dendrometerHeight', 'dendrometerGap',
           'dendrometerCondition', 'bandStemDiameter', 'remarks_AI',
           'recordedBy_AI', 'measuredBy_AI', 'dataEntryRecordID', 'dataQF_AI',
           'publicationDate_AI', 'release_AI'],
          dtype='object')




```python
# look at the dataframe for out a subset of the columns that may be relevant
veg[['date_AI','individualID','scientificName','taxonID','family','growthForm','plantStatus','plotID_AI','pointID','stemDiameter','adjEasting','adjNorthing']].head(5)
```




<div>

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>date_AI</th>
      <th>individualID</th>
      <th>scientificName</th>
      <th>taxonID</th>
      <th>family</th>
      <th>growthForm</th>
      <th>plantStatus</th>
      <th>plotID_AI</th>
      <th>pointID</th>
      <th>stemDiameter</th>
      <th>adjEasting</th>
      <th>adjNorthing</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>1</th>
      <td>2015-09-28</td>
      <td>NEON.PLA.D02.SERC.08038</td>
      <td>Carya glabra (Mill.) Sweet</td>
      <td>CAGL8</td>
      <td>Juglandaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_045</td>
      <td>43</td>
      <td>46.4</td>
      <td>364809.083993</td>
      <td>4.304727e+06</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2016-10-11</td>
      <td>NEON.PLA.D02.SERC.08038</td>
      <td>Carya glabra (Mill.) Sweet</td>
      <td>CAGL8</td>
      <td>Juglandaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_045</td>
      <td>43</td>
      <td>47.1</td>
      <td>364809.083993</td>
      <td>4.304727e+06</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2017-11-16</td>
      <td>NEON.PLA.D02.SERC.08038</td>
      <td>Carya glabra (Mill.) Sweet</td>
      <td>CAGL8</td>
      <td>Juglandaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_045</td>
      <td>43</td>
      <td>47.4</td>
      <td>364809.083993</td>
      <td>4.304727e+06</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2018-10-02</td>
      <td>NEON.PLA.D02.SERC.08038</td>
      <td>Carya glabra (Mill.) Sweet</td>
      <td>CAGL8</td>
      <td>Juglandaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_045</td>
      <td>43</td>
      <td>47.9</td>
      <td>364809.083993</td>
      <td>4.304727e+06</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2019-11-07</td>
      <td>NEON.PLA.D02.SERC.08038</td>
      <td>Carya glabra (Mill.) Sweet</td>
      <td>CAGL8</td>
      <td>Juglandaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_045</td>
      <td>43</td>
      <td>47.9</td>
      <td>364809.083993</td>
      <td>4.304727e+06</td>
    </tr>
  </tbody>
</table>
</div>



## Remove duplicate records

Some of these trees may have several recorded measurements, since we included all years of data. We will select only the latest recorded data so as to remove any duplicated data points. While measurements such as the tree height and stem diamter may change from one year to the next, the species should not.


```python
# Convert 'date_AI' to datetime
veg.loc[:, 'date_AI'] = pd.to_datetime(veg['date_AI'])

# Sort the DataFrame by 'individualID' and 'date_AI' in descending order
veg_date_sorted = veg.sort_values(by=['individualID', 'date_AI'], ascending=[True, False])

# Drop duplicates, keeping the first occurrence (which is the latest, or most recent, due to sorting)
veg_latest = veg_date_sorted.drop_duplicates(subset='individualID', keep='first').copy()

# Display the DataFrame with only the latest entries for each individualID
print(len(veg_latest))

# Display a subset of the columns
veg_latest[['date_AI','individualID','scientificName','taxonID','family','growthForm','plantStatus','plotID_AI','pointID','stemDiameter','adjEasting','adjNorthing']].head(5)
```

    1185
    




<div>

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>date_AI</th>
      <th>individualID</th>
      <th>scientificName</th>
      <th>taxonID</th>
      <th>family</th>
      <th>growthForm</th>
      <th>plantStatus</th>
      <th>plotID_AI</th>
      <th>pointID</th>
      <th>stemDiameter</th>
      <th>adjEasting</th>
      <th>adjNorthing</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>805</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00017</td>
      <td>Acer rubrum L.</td>
      <td>ACRU</td>
      <td>Aceraceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_054</td>
      <td>39</td>
      <td>27.5</td>
      <td>365000.851457</td>
      <td>4.305652e+06</td>
    </tr>
    <tr>
      <th>823</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00029</td>
      <td>Fagus grandifolia Ehrh.</td>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_054</td>
      <td>57</td>
      <td>34.2</td>
      <td>365008.826768</td>
      <td>4.305655e+06</td>
    </tr>
    <tr>
      <th>819</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00032</td>
      <td>Fagus grandifolia Ehrh.</td>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_054</td>
      <td>39</td>
      <td>32.0</td>
      <td>365002.039970</td>
      <td>4.305661e+06</td>
    </tr>
    <tr>
      <th>3865</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00039</td>
      <td>Fagus grandifolia Ehrh.</td>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_054</td>
      <td>57</td>
      <td>10.7</td>
      <td>364993.798628</td>
      <td>4.305656e+06</td>
    </tr>
    <tr>
      <th>3136</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00041</td>
      <td>Liquidambar styraciflua L.</td>
      <td>LIST2</td>
      <td>Hamamelidaceae</td>
      <td>small tree</td>
      <td>Standing dead</td>
      <td>SERC_054</td>
      <td>57</td>
      <td>9.7</td>
      <td>364990.841914</td>
      <td>4.305660e+06</td>
    </tr>
  </tbody>
</table>
</div>



Now create a new dataframe containing only the veg data that are within a single AOP tile (which are 1 km x 1 km in size). For this, you will need to know the bounds (minimum and maximum UTM easting and northing) of the area you are sampling. For this exercise, we will choose the AOP data with SW (lower left) UTM coordinates of 364000, 4305000. This tile encompasses the NEON tower at the SERC site.


```python
veg_tower_tile = veg_latest[(veg_latest['adjEasting'].between(364000, 365000)) & (veg_latest['adjNorthing'].between(4305000, 4306000))]
```

How many records do we have within this tile?


```python
len(veg_tower_tile)
```




    207



There are 207 unique vegetation records in this area. We can also look at the unique `taxonID`s that are represented.


```python
# look at the unique Taxon IDs
veg_tower_tile.taxonID.unique()
```




    array(['FAGR', 'LIST2', 'QUFA', 'LITU', 'ACRU', 'CACA18', 'NYSY', 'ULMUS',
           'CAGL8', 'QURU', 'QUAL', 'CATO6', 'PINUS', 'QUERC', 'COFL2',
           'PRAV', 'QUVE'], dtype=object)



Let's keep only a subset of the columns that we are interested in, and look at the dataframe:


```python
veg_tower_tile_short = veg_tower_tile[['date_AI','individualID','scientificName','taxonID','family','growthForm','plantStatus','plotID_AI','pointID','stemDiameter','adjEasting','adjNorthing']]
veg_tower_tile_short
```




<div>

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>date_AI</th>
      <th>individualID</th>
      <th>scientificName</th>
      <th>taxonID</th>
      <th>family</th>
      <th>growthForm</th>
      <th>plantStatus</th>
      <th>plotID_AI</th>
      <th>pointID</th>
      <th>stemDiameter</th>
      <th>adjEasting</th>
      <th>adjNorthing</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>3865</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00039</td>
      <td>Fagus grandifolia Ehrh.</td>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_054</td>
      <td>57</td>
      <td>10.7</td>
      <td>364993.798628</td>
      <td>4.305656e+06</td>
    </tr>
    <tr>
      <th>3136</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00041</td>
      <td>Liquidambar styraciflua L.</td>
      <td>LIST2</td>
      <td>Hamamelidaceae</td>
      <td>small tree</td>
      <td>Standing dead</td>
      <td>SERC_054</td>
      <td>57</td>
      <td>9.7</td>
      <td>364990.841914</td>
      <td>4.305660e+06</td>
    </tr>
    <tr>
      <th>800</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00043</td>
      <td>Quercus falcata Michx.</td>
      <td>QUFA</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Dead, broken bole</td>
      <td>SERC_054</td>
      <td>57</td>
      <td>37.1</td>
      <td>364991.794414</td>
      <td>4.305655e+06</td>
    </tr>
    <tr>
      <th>911</th>
      <td>2022-12-05 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00062</td>
      <td>Quercus falcata Michx.</td>
      <td>QUFA</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_054</td>
      <td>39</td>
      <td>59.7</td>
      <td>364990.424114</td>
      <td>4.305650e+06</td>
    </tr>
    <tr>
      <th>1762</th>
      <td>2023-11-29 00:00:00</td>
      <td>NEON.PLA.D02.SERC.00173</td>
      <td>Fagus grandifolia Ehrh.</td>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_047</td>
      <td>21</td>
      <td>22.5</td>
      <td>364673.259742</td>
      <td>4.305225e+06</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>3787</th>
      <td>2023-11-29 00:00:00</td>
      <td>NEON.PLA.D02.SERC.14231</td>
      <td>Fagus grandifolia Ehrh.</td>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_047</td>
      <td>23</td>
      <td>10.8</td>
      <td>364679.533579</td>
      <td>4.305222e+06</td>
    </tr>
    <tr>
      <th>4103</th>
      <td>2023-01-16 00:00:00</td>
      <td>NEON.PLA.D02.SERC.14548</td>
      <td>Fagus grandifolia Ehrh.</td>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_057</td>
      <td>41</td>
      <td>11.1</td>
      <td>364455.772024</td>
      <td>4.305415e+06</td>
    </tr>
    <tr>
      <th>4096</th>
      <td>2023-01-16 00:00:00</td>
      <td>NEON.PLA.D02.SERC.14563</td>
      <td>Quercus alba L.</td>
      <td>QUAL</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_057</td>
      <td>43</td>
      <td>10.1</td>
      <td>364470.101669</td>
      <td>4.305412e+06</td>
    </tr>
    <tr>
      <th>3818</th>
      <td>2022-11-15 00:00:00</td>
      <td>NEON.PLA.D02.SERC.14709</td>
      <td>Fagus grandifolia Ehrh.</td>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live</td>
      <td>SERC_052</td>
      <td>41</td>
      <td>10.4</td>
      <td>364577.886559</td>
      <td>4.305883e+06</td>
    </tr>
    <tr>
      <th>3828</th>
      <td>2022-11-17 00:00:00</td>
      <td>NEON.PLA.D02.SERC.14723</td>
      <td>Fagus grandifolia Ehrh.</td>
      <td>FAGR</td>
      <td>Fagaceae</td>
      <td>single bole tree</td>
      <td>Live, physically damaged</td>
      <td>SERC_067</td>
      <td>59</td>
      <td>10.1</td>
      <td>364353.644854</td>
      <td>4.305790e+06</td>
    </tr>
  </tbody>
</table>
<p>207 rows × 12 columns</p>
</div>



To get a better sense of the data, we can also look at the # of each species, to see if some species have more representation than others.


```python
# display the taxonID counts, sorted descending
veg_tower_tile_taxon_counts = veg_tower_tile[['individualID','taxonID']].groupby(['taxonID']).count()
veg_tower_tile_taxon_counts.sort_values(by='individualID',ascending=False)
```




<div>

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>individualID</th>
    </tr>
    <tr>
      <th>taxonID</th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>FAGR</th>
      <td>47</td>
    </tr>
    <tr>
      <th>LITU</th>
      <td>35</td>
    </tr>
    <tr>
      <th>LIST2</th>
      <td>29</td>
    </tr>
    <tr>
      <th>ACRU</th>
      <td>16</td>
    </tr>
    <tr>
      <th>CAGL8</th>
      <td>12</td>
    </tr>
    <tr>
      <th>CACA18</th>
      <td>11</td>
    </tr>
    <tr>
      <th>QUAL</th>
      <td>10</td>
    </tr>
    <tr>
      <th>NYSY</th>
      <td>10</td>
    </tr>
    <tr>
      <th>CATO6</th>
      <td>10</td>
    </tr>
    <tr>
      <th>QUFA</th>
      <td>9</td>
    </tr>
    <tr>
      <th>ULMUS</th>
      <td>5</td>
    </tr>
    <tr>
      <th>QURU</th>
      <td>4</td>
    </tr>
    <tr>
      <th>COFL2</th>
      <td>3</td>
    </tr>
    <tr>
      <th>PINUS</th>
      <td>2</td>
    </tr>
    <tr>
      <th>QUVE</th>
      <td>2</td>
    </tr>
    <tr>
      <th>PRAV</th>
      <td>1</td>
    </tr>
    <tr>
      <th>QUERC</th>
      <td>1</td>
    </tr>
  </tbody>
</table>
</div>




```python
# display the family counts, sorted descending
veg_tower_tile_family_counts = veg_tower_tile[['individualID','family']].groupby(['family']).count()
veg_tower_tile_family_counts.sort_values(by='individualID',ascending=False)
```




<div>

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>individualID</th>
    </tr>
    <tr>
      <th>family</th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>Fagaceae</th>
      <td>73</td>
    </tr>
    <tr>
      <th>Magnoliaceae</th>
      <td>35</td>
    </tr>
    <tr>
      <th>Hamamelidaceae</th>
      <td>29</td>
    </tr>
    <tr>
      <th>Juglandaceae</th>
      <td>22</td>
    </tr>
    <tr>
      <th>Aceraceae</th>
      <td>16</td>
    </tr>
    <tr>
      <th>Cornaceae</th>
      <td>13</td>
    </tr>
    <tr>
      <th>Betulaceae</th>
      <td>11</td>
    </tr>
    <tr>
      <th>Ulmaceae</th>
      <td>5</td>
    </tr>
    <tr>
      <th>Pinaceae</th>
      <td>2</td>
    </tr>
    <tr>
      <th>Rosaceae</th>
      <td>1</td>
    </tr>
  </tbody>
</table>
</div>



It looks like there are a number of species mapped in this tower plot. You can use the https://plants.usda.gov website to look up the species information. The top 5 most abundant mapped species are linked below.

- [FAGR](https://plants.usda.gov/plant-profile/FAGR): American Beech (Fagus grandifolia Ehrh.)
- [LITU](https://plants.usda.gov/plant-profile/LITU): Tuliptree (Liriodendron tulipifera L.)
- [LIST2](https://plants.usda.gov/plant-profile/LIST2): Sweetgum (Liquidambar styraciflua L.)
- [ACRU](https://plants.usda.gov/plant-profile/ACRU): Red Maple (Acer rubrum L.)
- [CAGL8](https://plants.usda.gov/plant-profile/CAGL8): Sweet pignut hickory (Carya glabra (Mill.))

When carrying out classification, the species that only have small representation (1-5 samples) may not be modeled accurately due to a lack of sufficient training data. The challenge of mapping rarer species due to insufficient training data is well known (and is sometimes called the 'long-tail' effect) e.g. In the next tutorial, we will remove these poorly represented samples when we generate our model. 

Zhang, C., Chen, Y., Xu, B. et al. Improving prediction of rare species’ distribution from community data. Sci Rep 10, 12230 (2020). https://doi.org/10.1038/s41598-020-69157-x

## Write training dataframe to csv file

Nonetheless, we have a fairly decent training dataset to work with. We can save the dataframe to a csv file called `serc_training_data.csv` as follows:


```python
veg_tower_tile_short.to_csv(r'.\data\serc_training_data.csv',index=False)
```

## Plot species and stem diameter

Finally, we can make a quick plot using `seaborn` (imported as `sns`) to show the spatial distrubtion of the trees surveyed in this area, along with their species (`scientificName`). Most of this code helps improve the formatting and appearance of the figure; the first `sns.scatterplot` chunk is all you really need to do to plot the essentials.


```python
ax = sns.scatterplot(
    data=veg_tower_tile_short,
    x='adjEasting',
    y='adjNorthing',
    size='stemDiameter',
    hue='scientificName',
    sizes=(2, 20),
    alpha=0.7
)

ax.set_aspect('equal', adjustable='datalim')

# Remove scientific notation
ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f'{x:.0f}'))
ax.yaxis.set_major_formatter(mticker.FuncFormatter(lambda y, _: f'{y:.0f}'))

ax.legend_.remove()

handles, labels = ax.get_legend_handles_labels()
n_species = veg_tower_tile_short['scientificName'].nunique()

# Species legend
hue_handles = handles[1:n_species+1]
hue_labels = labels[1:n_species+1]
legend1 = ax.legend(
    hue_handles, hue_labels,
    title="Species",
    bbox_to_anchor=(1.05, 0.5),
    loc='center left',
    fontsize='small',
    title_fontsize='small'
)
ax.add_artist(legend1)

# Size legend (skip the first label, which is the old 'stemDiameter')
size_handles = handles[n_species+2:]
size_labels = labels[n_species+2:]
legend2 = ax.legend(
    size_handles, size_labels,
    title="Stem Diameter (cm)",
    bbox_to_anchor=(1.5, 0.5),
    loc='center left',
    fontsize='small',
    title_fontsize='small'
)

# Add title and axis labels
ax.set_title("SERC Tree Species and Stem Diameters", fontsize=14)
ax.set_xlabel("Easting (m)", fontsize=12)
ax.set_ylabel("Northing (m)", fontsize=12)

plt.show()
```


    
![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/AOP/Hyperspectral/classification/refl-h5-xarray/make_classification_training_data_files/make_classification_training_data_38_0.png)
    


## Recap

In this lesson we have curated a training data set containing information about the tree family and species as well as its geographic location in UTM x, y coordinates. We can now pair this dataset with remote sensing data and create a model to predict the tree's family based off airborne spectral data. The next tutorial, <a href="https://www.neonscience.org/resources/learning-hub/tutorials/refl-classification-pyxarray" target=_blank>DP1.10098.001</a>, will show how to do this!
