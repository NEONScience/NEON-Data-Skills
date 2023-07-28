---
syncID: 
title: "Intro to AOP Datasets in Google Earth Engine (GEE) using Python"
description: "Explore AOP reflectance, camera, and lidar datasets in GEE"
dateCreated: 2023-07-25
authors: Bridget Hass
contributors: John Musinsky
estimatedTime: 30 minutes
packagesLibraries: earthengine-api, geemap
topics:
languagesTool: Python, Google Earth Engine
dataProducts: DP3.30006.001, DP3.30010.001, DP3.30015.001, DP3.30024.001
code1: https://github.com/NEONScience/NEON-Data-Skills/blob/main/tutorials/Other/GEE_Python/01_aop_intro_gee_py/Intro_AOP_Datasets_GEE_Python.ipynb
tutorialSeries: 
urlTitle: aop-gee-py-intro
---

<div id="ds-objectives" markdown="1">

### Objectives
After completing this tutorial, you will be able to use Python to:

* Determine the available AOP datasets in Google Earth Engine
* Read in and visualize AOP Reflectance, RGB Camera, and Lidar Raster datasets
* Become familiar with the AOP Image Properties
* Filter data based off image properties to pull in dataset(s) of interest
* Explore the interactive mapping features in geemap

### Requirements

To follow along with this code, you will need to 
1. Sign up for a non-commercial Google Earth Engine account here https://code.earthengine.google.com/register.
2. Install **Python 3.x**
3. Install required Python packages (matplotlib, cartopy and the dependent packages are only required for the last optional part of the tutorial, to create a time-lapse gif)
    - earthengine-api
    - geemap

Notes: 
- This tutorial was developed using Python 3.9, so if you are installing Python for the first time, we recommend that version. This lesson was written in **Jupyter Notebook** so you can run each cell chunk individually, but you can also use a different IDE (Interactive Development Environment) of your choice. 
- If not using **Jupyter**, we recommend using **Spyder**, which has similar functionality. You can install both Python, Jupyter Notebooks, and Spyder by downloading <a href="https://www.anaconda.com/products/distribution" target="_blank">Anaconda</a>.


### Additional Resources
- <a href="https://book.geemap.org/" target="_blank">geemap book</a>
- <a href="https://www.youtube.com/@giswqs" target="_blank">geemap YouTube channel</a>

</div>

## AOP data in GEE

[Google Earth Engine](https://earthengine.google.com/) is a platform idea for carrying out continental and planetary scale geospatial analyses. It has a multi-pedabyte catalog of satellite imagery and geospatial datasets, and is a powerful tool for comparing and scaling up NEON airborne datasets. 

The NEON data products can currently be accessed through the `projects/neon-prod-earthengine/assets/` folder with an appended prefix of the data product ID (DPID) similar to what you see on the [NEON data portal](https://data.neonscience.org/data-products/explore). The table below shows the corresponding prefixes to use for the available data products.

| Acronym | Data Product      | Data Product ID (Prefix)          |
|----------|------------|-------------------------|
| SDR | Surface Directional Reflectance | DP3-30006-001 |
| RGB | Red Green Blue (Camera Imagery) | DP3-30010-001 |
| CHM | Canopy Height Model | DP3-30015-001 |
| DSM | Digital Surface Model | DP3-30024-001 |
| DTM | Digital Terrain Model | DP3-30024-001 |


To access the NEON AOP data you can read in the Image Collection `ee.ImageCollection` and filter by the date and other properties of interest.

First, import the relevant Earth Engine Python packages, `earthengine-api` [(ee)](https://developers.google.com/earth-engine/guides/python_install) and [geemap](https://geemap.org/). This lesson was written using geemap version 0.22.1. If you have an older version installed, used the command below to update.

## GEE Python API


```python
import ee, geemap
```

In order to use Earth Engine from within this Jupyter Notebook, we need to first Authenticate (which requires generating a token) and then Initialize, as below. For more detailed instructions on the Authentication process, please refer to the: 
<a href="https://book.geemap.org/chapters/01_introduction.html#earth-engine-authentication" target="_blank">geemap text book Earth Engine authentication section</a>.


```python
geemap.__version__
```




    '0.22.1'




```python
ee.Authenticate()
```


<p>To authorize access needed by Earth Engine, open the following
        URL in a web browser and follow the instructions:

        ...
        
        <p>The authorization workflow will generate a code, which you should paste in the box below.</p>

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/enter_verification_code.PNG">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/enter_verification_code.PNG" alt="enter_verification_code screenshot" width="600"><figcaption></figcaption></a>
</figure><br>

When the token is entered, you should receive the notice: `"Successfully saved authorization token."`
    


```python
ee.Initialize()
```

Now that you've logged in to your Earth Engine account, you can start using the Python API with the `ee` package.

First let's read in the Surface Directional Reflectance (SDR) Image Collection and take a look at the available data.


```python
# Read in the NEON AOP Surface Directional Reflectance (SDR) Collection:
sdrCol = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30006-001')

# List all available sites in the NEON SDR image collection:
print('All Available NEON SDR Images:')

# Get the number of SDR images
sdrCount = sdrCol.size()
print('Count: ', str(sdrCount.getInfo())+'\n')

print(sdrCol.aggregate_array('system:index').getInfo())
```

    All Available NEON SDR Images:
    Count:  25
    
    ['2013_CPER_1_SDR', '2016_CLBJ_1_SDR', '2016_GRSM_2_SDR', '2016_HARV_3_SDR', '2017_CLBJ_2_SDR', '2017_CPER_3_SDR', '2017_GRSM_3_SDR', '2017_SERC_3_SDR', '2018_CLBJ_3_SDR', '2019_CLBJ_4_SDR', '2019_HARV_6_SDR', '2019_HEAL_3_SDR', '2019_JORN_3_SDR', '2019_SOAP_4_SDR', '2020_CPER_5_SDR', '2020_CPER_7_SDR', '2020_NIWO_4_SDR', '2021_ABBY_4_SDR', '2021_CLBJ_5_SDR', '2021_CPER_8_SDR', '2021_GRSM_5_SDR', '2021_HEAL_4_SDR', '2021_JORN_4_SDR', '2021_SJER_5_SDR', '2021_SOAP_5_SDR']
    

We can also look for data for a specified site - for example look at all the years of AOP SDR data available for a given site.


```python
# See the years of data available for the specified site:
site = 'CPER'

# Get the flight year and site information
flightYears = sdrCol.aggregate_array('FLIGHT_YEAR').getInfo()
sites = sdrCol.aggregate_array('NEON_SITE').getInfo()

print('\nYears of SDR data available in GEE for',site+':')
print([year_site[0] for year_site in zip(flightYears,sites) if site in year_site])
```

    
    Years of SDR data available in GEE for CPER:
    [2013, 2017, 2020, 2020, 2021]
    

Let's take a look at another dataset, the high-resolution RGB camera imagery:


```python
# Read in the NEON AOP Camera (RGB) Collection:
rgbCol = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30010-001')

# List all available sites in the NEON SDR image collection:
print('All Available NEON Camera Images:')
# Get the number of RGB images
rgbCount = rgbCol.size()
print('Count: ', str(sdrCount.getInfo())+'\n')
print(rgbCol.aggregate_array('system:index').getInfo())
```

    All Available NEON Camera Images:
    Count:  25
    
    ['2016_HARV_3_RGB', '2017_CLBJ_2_RGB', '2017_GRSM_3_RGB', '2017_SERC_3_RGB', '2018_CLBJ_3_RGB', '2018_TEAK_3_RGB', '2019_BART_5_RGB', '2019_CLBJ_4_RGB', '2019_HARV_6_RGB', '2019_HEAL_3_RGB', '2019_JORN_3_RGB', '2019_SOAP_4_RGB', '2020_CPER_7_RGB', '2020_NIWO_4_RGB', '2020_RMNP_3_RGB', '2020_UKFS_5_RGB', '2020_UNDE_4_RGB', '2020_YELL_3_RGB', '2021_ABBY_4_RGB', '2021_BLAN_4_RGB', '2021_BONA_4_RGB', '2021_CLBJ_5_RGB', '2021_DEJU_4_RGB', '2021_DELA_6_RGB', '2021_HEAL_4_RGB', '2021_JERC_6_RGB', '2021_JORN_4_RGB', '2021_LENO_6_RGB', '2021_MLBS_4_RGB', '2021_OSBS_6_RGB', '2021_SERC_5_RGB', '2021_SJER_5_RGB', '2021_SOAP_5_RGB', '2021_TALL_6_RGB', '2021_WREF_4_RGB']
    

Similarly, you can read in the DEM and CHM collections as follows:

```python
# Read in the NEON AOP DEM Collection (this includes the DTM and DSM as 2 bands)
demCol = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30024-001')

# Read in the NEON AOP CHM Collection
chmCol = ee.ImageCollection('projects/neon-prod-earthengine/assets/DP3-30015-001')
```

## Explore Image Properties

Now that we've read in a couple of image collections, let's take a look at some of the image properties using `geemap.image_props`:


```python
props = geemap.image_props(sdrCol.first())
props
```




<div><style>:root {
  --font-color-primary: var(--jp-content-font-color0, rgba(0, 0, 0, 1));
  --font-color-secondary: var(--jp-content-font-color2, rgba(0, 0, 0, 0.6));
  --font-color-accent: rgba(123, 31, 162, 1);
  --border-color: var(--jp-border-color2, #e0e0e0);
  --background-color: var(--jp-layout-color0, white);
  --background-color-row-even: var(--jp-layout-color1, white);
  --background-color-row-odd: var(--jp-layout-color2, #eeeeee);
}

html[theme="dark"],
body[data-theme="dark"],
body.vscode-dark {
  --font-color-primary: rgba(255, 255, 255, 1);
  --font-color-secondary: rgba(255, 255, 255, 0.6);
  --font-color-accent: rgb(173, 132, 190);
  --border-color: #2e2e2e;
  --background-color: #111111;
  --background-color-row-even: #111111;
  --background-color-row-odd: #313131;
}

.ee {
  padding: 1em;
  line-height: 1.5em;
  min-width: 300px;
  max-width: 1200px;
  overflow-y: scroll;
  max-height: 600px;
  border: 1px solid var(--border-color);
  font-family: monospace;
}

.ee li {
  list-style-type: none;
}

.ee ul {
  padding-left: 1.5em !important;
  margin: 0;
}

.ee > ul {
  padding-left: 0 !important;
}

.ee-open,
.ee-shut {
  color: var(--font-color-secondary);
  cursor: pointer;
  margin: 0;
}

.ee-open:hover,
.ee-shut:hover {
  color: var(--font-color-primary);
}

.ee-k {
  color: var(--font-color-accent);
  margin-right: 6px;
}

.ee-v {
  color: var(--font-color-primary);
}

.ee-toggle {
  display: none;
}

.ee-shut + ul {
  display: none;
}

.ee-open + ul {
  display: block;
}

.ee-shut::before {
  display: inline-block;
  content: "▼";
  margin-right: 6px;
  transform: rotate(-90deg);
  transition: transform 0.2s;
}

.ee-open::before {
  transform: rotate(0deg);
  display: inline-block;
  content: "▼";
  margin-right: 6px;
  transition: transform 0.2s;
}
</style><div class='ee'><ul><li><label class='ee-shut'>Object (446 properties)<input type='checkbox' class='ee-toggle'></label><ul><li><span class='ee-k'>AOP_VISIT_NUMBER:</span><span class='ee-v'>1</span></li><li><span class='ee-k'>DESCRIPTION:</span><span class='ee-v'>Orthorectified surface directional reflectance (0-1 unitless, scaled by 10000) computed from the NEON Imaging Spectrometer (NIS), an AVIRIS-NG sensor. The data contain 426 bands spanning the visible to short-wave infrared portions of the electromagnetic spectrum; band widths are ~5nm. Wavelengths between 1340-1445nm and 1790-1955nm are set to -100; these are water vapor absorption bands and do not have valid values. All 426 bands are orthorectified and output onto a fixed, uniform spatial grid using nearest-neighbor resampling. No BRDF-correction has been applied. Flight lines are mosaicked using the most-nadir pixels and data acquired during the best weather conditions, when possible. Data are calibrated and atmospherically corrected, and include additional QA and ancillary bands; see band descriptions for more information.</span></li><li><span class='ee-k'>FLIGHT_YEAR:</span><span class='ee-v'>2013</span></li><li><span class='ee-k'>IMAGE_DATE:</span><span class='ee-v'>2013-06-25</span></li><li><span class='ee-k'>NEON_DATA_PROD_ID:</span><span class='ee-v'>DP3.30006.001</span></li><li><span class='ee-k'>NEON_DATA_PROD_URL:</span><span class='ee-v'>https://data.neonscience.org/data-products/DP3.30006.001</span></li><li><span class='ee-k'>NEON_DOMAIN:</span><span class='ee-v'>D10</span></li><li><span class='ee-k'>NEON_SITE:</span><span class='ee-v'>CPER</span></li><li><span class='ee-k'>NOMINAL_SCALE:</span><span class='ee-v'>1</span></li><li><span class='ee-k'>PRODUCT_TYPE:</span><span class='ee-v'>SDR</span></li><li><span class='ee-k'>SCALING_FACTOR:</span><span class='ee-v'>10000</span></li><li><span class='ee-k'>SENSOR_NAME:</span><span class='ee-v'>AVIRIS-NG</span></li><li><span class='ee-k'>SENSOR_NUMBER:</span><span class='ee-v'>NIS1</span></li><li><span class='ee-k'>WL_FWHM_B001:</span><span class='ee-v'>382.3465,5.8456</span></li><li><span class='ee-k'>WL_FWHM_B002:</span><span class='ee-v'>387.3553,5.8463</span></li><li><span class='ee-k'>WL_FWHM_B003:</span><span class='ee-v'>392.3641,5.847</span></li><li><span class='ee-k'>WL_FWHM_B004:</span><span class='ee-v'>397.373,5.8477</span></li><li><span class='ee-k'>WL_FWHM_B005:</span><span class='ee-v'>402.3818,5.8484</span></li><li><span class='ee-k'>WL_FWHM_B006:</span><span class='ee-v'>407.3906,5.8491</span></li><li><span class='ee-k'>WL_FWHM_B007:</span><span class='ee-v'>412.3995,5.8499</span></li><li><span class='ee-k'>WL_FWHM_B008:</span><span class='ee-v'>417.4083,5.8506</span></li><li><span class='ee-k'>WL_FWHM_B009:</span><span class='ee-v'>422.4171,5.8514</span></li><li><span class='ee-k'>WL_FWHM_B010:</span><span class='ee-v'>427.4259,5.8522</span></li><li><span class='ee-k'>WL_FWHM_B011:</span><span class='ee-v'>432.4348,5.853</span></li><li><span class='ee-k'>WL_FWHM_B012:</span><span class='ee-v'>437.4436,5.8538</span></li><li><span class='ee-k'>WL_FWHM_B013:</span><span class='ee-v'>442.4524,5.8546</span></li><li><span class='ee-k'>WL_FWHM_B014:</span><span class='ee-v'>447.4613,5.8555</span></li><li><span class='ee-k'>WL_FWHM_B015:</span><span class='ee-v'>452.4701,5.8563</span></li><li><span class='ee-k'>WL_FWHM_B016:</span><span class='ee-v'>457.4789,5.8572</span></li><li><span class='ee-k'>WL_FWHM_B017:</span><span class='ee-v'>462.4877,5.858</span></li><li><span class='ee-k'>WL_FWHM_B018:</span><span class='ee-v'>467.4966,5.8589</span></li><li><span class='ee-k'>WL_FWHM_B019:</span><span class='ee-v'>472.5054,5.8598</span></li><li><span class='ee-k'>WL_FWHM_B020:</span><span class='ee-v'>477.5142,5.8607</span></li><li><span class='ee-k'>WL_FWHM_B021:</span><span class='ee-v'>482.5231,5.8616</span></li><li><span class='ee-k'>WL_FWHM_B022:</span><span class='ee-v'>487.5319,5.8626</span></li><li><span class='ee-k'>WL_FWHM_B023:</span><span class='ee-v'>492.5407,5.8635</span></li><li><span class='ee-k'>WL_FWHM_B024:</span><span class='ee-v'>497.5496,5.8645</span></li><li><span class='ee-k'>WL_FWHM_B025:</span><span class='ee-v'>502.5584,5.8655</span></li><li><span class='ee-k'>WL_FWHM_B026:</span><span class='ee-v'>507.5672,5.8664</span></li><li><span class='ee-k'>WL_FWHM_B027:</span><span class='ee-v'>512.576,5.8674</span></li><li><span class='ee-k'>WL_FWHM_B028:</span><span class='ee-v'>517.5849,5.8684</span></li><li><span class='ee-k'>WL_FWHM_B029:</span><span class='ee-v'>522.5937,5.8695</span></li><li><span class='ee-k'>WL_FWHM_B030:</span><span class='ee-v'>527.6025,5.8705</span></li><li><span class='ee-k'>WL_FWHM_B031:</span><span class='ee-v'>532.6114,5.8715</span></li><li><span class='ee-k'>WL_FWHM_B032:</span><span class='ee-v'>537.6202,5.8726</span></li><li><span class='ee-k'>WL_FWHM_B033:</span><span class='ee-v'>542.629,5.8737</span></li><li><span class='ee-k'>WL_FWHM_B034:</span><span class='ee-v'>547.6378,5.8747</span></li><li><span class='ee-k'>WL_FWHM_B035:</span><span class='ee-v'>552.6468,5.8758</span></li><li><span class='ee-k'>WL_FWHM_B036:</span><span class='ee-v'>557.6555,5.8769</span></li><li><span class='ee-k'>WL_FWHM_B037:</span><span class='ee-v'>562.6643,5.878</span></li><li><span class='ee-k'>WL_FWHM_B038:</span><span class='ee-v'>567.6732,5.8792</span></li><li><span class='ee-k'>WL_FWHM_B039:</span><span class='ee-v'>572.682,5.8803</span></li><li><span class='ee-k'>WL_FWHM_B040:</span><span class='ee-v'>577.6908,5.8815</span></li><li><span class='ee-k'>WL_FWHM_B041:</span><span class='ee-v'>582.6996,5.8826</span></li><li><span class='ee-k'>WL_FWHM_B042:</span><span class='ee-v'>587.7085,5.8838</span></li><li><span class='ee-k'>WL_FWHM_B043:</span><span class='ee-v'>592.7173,5.885</span></li><li><span class='ee-k'>WL_FWHM_B044:</span><span class='ee-v'>597.726,5.8862</span></li><li><span class='ee-k'>WL_FWHM_B045:</span><span class='ee-v'>602.735,5.8874</span></li><li><span class='ee-k'>WL_FWHM_B046:</span><span class='ee-v'>607.7438,5.8887</span></li><li><span class='ee-k'>WL_FWHM_B047:</span><span class='ee-v'>612.7526,5.8899</span></li><li><span class='ee-k'>WL_FWHM_B048:</span><span class='ee-v'>617.7614,5.8912</span></li><li><span class='ee-k'>WL_FWHM_B049:</span><span class='ee-v'>622.7703,5.8924</span></li><li><span class='ee-k'>WL_FWHM_B050:</span><span class='ee-v'>627.7791,5.8937</span></li><li><span class='ee-k'>WL_FWHM_B051:</span><span class='ee-v'>632.7879,5.895</span></li><li><span class='ee-k'>WL_FWHM_B052:</span><span class='ee-v'>637.7968,5.8963</span></li><li><span class='ee-k'>WL_FWHM_B053:</span><span class='ee-v'>642.8056,5.8976</span></li><li><span class='ee-k'>WL_FWHM_B054:</span><span class='ee-v'>647.8144,5.8989</span></li><li><span class='ee-k'>WL_FWHM_B055:</span><span class='ee-v'>652.8232,5.9003</span></li><li><span class='ee-k'>WL_FWHM_B056:</span><span class='ee-v'>657.8321,5.9016</span></li><li><span class='ee-k'>WL_FWHM_B057:</span><span class='ee-v'>662.8409,5.903</span></li><li><span class='ee-k'>WL_FWHM_B058:</span><span class='ee-v'>667.8496,5.9043</span></li><li><span class='ee-k'>WL_FWHM_B059:</span><span class='ee-v'>672.8586,5.9057</span></li><li><span class='ee-k'>WL_FWHM_B060:</span><span class='ee-v'>677.8674,5.9071</span></li><li><span class='ee-k'>WL_FWHM_B061:</span><span class='ee-v'>682.8762,5.9085</span></li><li><span class='ee-k'>WL_FWHM_B062:</span><span class='ee-v'>687.885,5.91</span></li><li><span class='ee-k'>WL_FWHM_B063:</span><span class='ee-v'>692.8939,5.9114</span></li><li><span class='ee-k'>WL_FWHM_B064:</span><span class='ee-v'>697.9027,5.9129</span></li><li><span class='ee-k'>WL_FWHM_B065:</span><span class='ee-v'>702.9115,5.9143</span></li><li><span class='ee-k'>WL_FWHM_B066:</span><span class='ee-v'>707.9204,5.9158</span></li><li><span class='ee-k'>WL_FWHM_B067:</span><span class='ee-v'>712.9292,5.9173</span></li><li><span class='ee-k'>WL_FWHM_B068:</span><span class='ee-v'>717.938,5.9188</span></li><li><span class='ee-k'>WL_FWHM_B069:</span><span class='ee-v'>722.9469,5.9203</span></li><li><span class='ee-k'>WL_FWHM_B070:</span><span class='ee-v'>727.9557,5.9218</span></li><li><span class='ee-k'>WL_FWHM_B071:</span><span class='ee-v'>732.9645,5.9234</span></li><li><span class='ee-k'>WL_FWHM_B072:</span><span class='ee-v'>737.9734,5.9249</span></li><li><span class='ee-k'>WL_FWHM_B073:</span><span class='ee-v'>742.9822,5.9264</span></li><li><span class='ee-k'>WL_FWHM_B074:</span><span class='ee-v'>747.991,5.928</span></li><li><span class='ee-k'>WL_FWHM_B075:</span><span class='ee-v'>752.9998,5.9296</span></li><li><span class='ee-k'>WL_FWHM_B076:</span><span class='ee-v'>758.0088,5.9312</span></li><li><span class='ee-k'>WL_FWHM_B077:</span><span class='ee-v'>763.0175,5.9328</span></li><li><span class='ee-k'>WL_FWHM_B078:</span><span class='ee-v'>768.0263,5.9344</span></li><li><span class='ee-k'>WL_FWHM_B079:</span><span class='ee-v'>773.0351,5.9361</span></li><li><span class='ee-k'>WL_FWHM_B080:</span><span class='ee-v'>778.044,5.9377</span></li><li><span class='ee-k'>WL_FWHM_B081:</span><span class='ee-v'>783.0528,5.9394</span></li><li><span class='ee-k'>WL_FWHM_B082:</span><span class='ee-v'>788.0616,5.941</span></li><li><span class='ee-k'>WL_FWHM_B083:</span><span class='ee-v'>793.0705,5.9427</span></li><li><span class='ee-k'>WL_FWHM_B084:</span><span class='ee-v'>798.0793,5.9444</span></li><li><span class='ee-k'>WL_FWHM_B085:</span><span class='ee-v'>803.088,5.9461</span></li><li><span class='ee-k'>WL_FWHM_B086:</span><span class='ee-v'>808.0969,5.9479</span></li><li><span class='ee-k'>WL_FWHM_B087:</span><span class='ee-v'>813.1058,5.9496</span></li><li><span class='ee-k'>WL_FWHM_B088:</span><span class='ee-v'>818.1146,5.9513</span></li><li><span class='ee-k'>WL_FWHM_B089:</span><span class='ee-v'>823.1234,5.9531</span></li><li><span class='ee-k'>WL_FWHM_B090:</span><span class='ee-v'>828.1323,5.9549</span></li><li><span class='ee-k'>WL_FWHM_B091:</span><span class='ee-v'>833.1411,5.9566</span></li><li><span class='ee-k'>WL_FWHM_B092:</span><span class='ee-v'>838.1499,5.9584</span></li><li><span class='ee-k'>WL_FWHM_B093:</span><span class='ee-v'>843.1587,5.9602</span></li><li><span class='ee-k'>WL_FWHM_B094:</span><span class='ee-v'>848.1676,5.962</span></li><li><span class='ee-k'>WL_FWHM_B095:</span><span class='ee-v'>853.1764,5.9639</span></li><li><span class='ee-k'>WL_FWHM_B096:</span><span class='ee-v'>858.1852,5.9657</span></li><li><span class='ee-k'>WL_FWHM_B097:</span><span class='ee-v'>863.1941,5.9676</span></li><li><span class='ee-k'>WL_FWHM_B098:</span><span class='ee-v'>868.2029,5.9694</span></li><li><span class='ee-k'>WL_FWHM_B099:</span><span class='ee-v'>873.2117,5.9713</span></li><li><span class='ee-k'>WL_FWHM_B100:</span><span class='ee-v'>878.2205,5.9732</span></li><li><span class='ee-k'>WL_FWHM_B101:</span><span class='ee-v'>883.2294,5.9751</span></li><li><span class='ee-k'>WL_FWHM_B102:</span><span class='ee-v'>888.2382,5.977</span></li><li><span class='ee-k'>WL_FWHM_B103:</span><span class='ee-v'>893.247,5.979</span></li><li><span class='ee-k'>WL_FWHM_B104:</span><span class='ee-v'>898.2559,5.9809</span></li><li><span class='ee-k'>WL_FWHM_B105:</span><span class='ee-v'>903.2647,5.9828</span></li><li><span class='ee-k'>WL_FWHM_B106:</span><span class='ee-v'>908.2735,5.9848</span></li><li><span class='ee-k'>WL_FWHM_B107:</span><span class='ee-v'>913.2824,5.9868</span></li><li><span class='ee-k'>WL_FWHM_B108:</span><span class='ee-v'>918.2912,5.9888</span></li><li><span class='ee-k'>WL_FWHM_B109:</span><span class='ee-v'>923.3,5.9908</span></li><li><span class='ee-k'>WL_FWHM_B110:</span><span class='ee-v'>928.3088,5.9928</span></li><li><span class='ee-k'>WL_FWHM_B111:</span><span class='ee-v'>933.3177,5.9948</span></li><li><span class='ee-k'>WL_FWHM_B112:</span><span class='ee-v'>938.3265,5.9969</span></li><li><span class='ee-k'>WL_FWHM_B113:</span><span class='ee-v'>943.3353,5.9989</span></li><li><span class='ee-k'>WL_FWHM_B114:</span><span class='ee-v'>948.3442,6.001</span></li><li><span class='ee-k'>WL_FWHM_B115:</span><span class='ee-v'>953.353,6.0031</span></li><li><span class='ee-k'>WL_FWHM_B116:</span><span class='ee-v'>958.3618,6.0051</span></li><li><span class='ee-k'>WL_FWHM_B117:</span><span class='ee-v'>963.3706,6.0072</span></li><li><span class='ee-k'>WL_FWHM_B118:</span><span class='ee-v'>968.3795,6.0094</span></li><li><span class='ee-k'>WL_FWHM_B119:</span><span class='ee-v'>973.3883,6.0115</span></li><li><span class='ee-k'>WL_FWHM_B120:</span><span class='ee-v'>978.3971,6.0136</span></li><li><span class='ee-k'>WL_FWHM_B121:</span><span class='ee-v'>983.406,6.0158</span></li><li><span class='ee-k'>WL_FWHM_B122:</span><span class='ee-v'>988.4148,6.0179</span></li><li><span class='ee-k'>WL_FWHM_B123:</span><span class='ee-v'>993.4236,6.0201</span></li><li><span class='ee-k'>WL_FWHM_B124:</span><span class='ee-v'>998.4324,6.0223</span></li><li><span class='ee-k'>WL_FWHM_B125:</span><span class='ee-v'>1003.4413,6.0245</span></li><li><span class='ee-k'>WL_FWHM_B126:</span><span class='ee-v'>1008.4501,6.0267</span></li><li><span class='ee-k'>WL_FWHM_B127:</span><span class='ee-v'>1013.4589,6.0289</span></li><li><span class='ee-k'>WL_FWHM_B128:</span><span class='ee-v'>1018.4678,6.0312</span></li><li><span class='ee-k'>WL_FWHM_B129:</span><span class='ee-v'>1023.4766,6.0334</span></li><li><span class='ee-k'>WL_FWHM_B130:</span><span class='ee-v'>1028.4854,6.0357</span></li><li><span class='ee-k'>WL_FWHM_B131:</span><span class='ee-v'>1033.4941,6.0379</span></li><li><span class='ee-k'>WL_FWHM_B132:</span><span class='ee-v'>1038.503,6.0402</span></li><li><span class='ee-k'>WL_FWHM_B133:</span><span class='ee-v'>1043.5118,6.0425</span></li><li><span class='ee-k'>WL_FWHM_B134:</span><span class='ee-v'>1048.5208,6.0448</span></li><li><span class='ee-k'>WL_FWHM_B135:</span><span class='ee-v'>1053.5295,6.0472</span></li><li><span class='ee-k'>WL_FWHM_B136:</span><span class='ee-v'>1058.5385,6.0495</span></li><li><span class='ee-k'>WL_FWHM_B137:</span><span class='ee-v'>1063.5472,6.0518</span></li><li><span class='ee-k'>WL_FWHM_B138:</span><span class='ee-v'>1068.556,6.0542</span></li><li><span class='ee-k'>WL_FWHM_B139:</span><span class='ee-v'>1073.565,6.0566</span></li><li><span class='ee-k'>WL_FWHM_B140:</span><span class='ee-v'>1078.5737,6.0589</span></li><li><span class='ee-k'>WL_FWHM_B141:</span><span class='ee-v'>1083.5825,6.0613</span></li><li><span class='ee-k'>WL_FWHM_B142:</span><span class='ee-v'>1088.5914,6.0637</span></li><li><span class='ee-k'>WL_FWHM_B143:</span><span class='ee-v'>1093.6002,6.0662</span></li><li><span class='ee-k'>WL_FWHM_B144:</span><span class='ee-v'>1098.609,6.0686</span></li><li><span class='ee-k'>WL_FWHM_B145:</span><span class='ee-v'>1103.6179,6.071</span></li><li><span class='ee-k'>WL_FWHM_B146:</span><span class='ee-v'>1108.6267,6.0735</span></li><li><span class='ee-k'>WL_FWHM_B147:</span><span class='ee-v'>1113.6355,6.076</span></li><li><span class='ee-k'>WL_FWHM_B148:</span><span class='ee-v'>1118.6443,6.0785</span></li><li><span class='ee-k'>WL_FWHM_B149:</span><span class='ee-v'>1123.6532,6.0809</span></li><li><span class='ee-k'>WL_FWHM_B150:</span><span class='ee-v'>1128.662,6.0834</span></li><li><span class='ee-k'>WL_FWHM_B151:</span><span class='ee-v'>1133.6708,6.086</span></li><li><span class='ee-k'>WL_FWHM_B152:</span><span class='ee-v'>1138.6797,6.0885</span></li><li><span class='ee-k'>WL_FWHM_B153:</span><span class='ee-v'>1143.6885,6.091</span></li><li><span class='ee-k'>WL_FWHM_B154:</span><span class='ee-v'>1148.6973,6.0936</span></li><li><span class='ee-k'>WL_FWHM_B155:</span><span class='ee-v'>1153.706,6.0962</span></li><li><span class='ee-k'>WL_FWHM_B156:</span><span class='ee-v'>1158.715,6.0987</span></li><li><span class='ee-k'>WL_FWHM_B157:</span><span class='ee-v'>1163.7238,6.1013</span></li><li><span class='ee-k'>WL_FWHM_B158:</span><span class='ee-v'>1168.7325,6.1039</span></li><li><span class='ee-k'>WL_FWHM_B159:</span><span class='ee-v'>1173.7415,6.1066</span></li><li><span class='ee-k'>WL_FWHM_B160:</span><span class='ee-v'>1178.7502,6.1092</span></li><li><span class='ee-k'>WL_FWHM_B161:</span><span class='ee-v'>1183.7592,6.1118</span></li><li><span class='ee-k'>WL_FWHM_B162:</span><span class='ee-v'>1188.768,6.1145</span></li><li><span class='ee-k'>WL_FWHM_B163:</span><span class='ee-v'>1193.7769,6.1172</span></li><li><span class='ee-k'>WL_FWHM_B164:</span><span class='ee-v'>1198.7856,6.1198</span></li><li><span class='ee-k'>WL_FWHM_B165:</span><span class='ee-v'>1203.7944,6.1225</span></li><li><span class='ee-k'>WL_FWHM_B166:</span><span class='ee-v'>1208.8033,6.1252</span></li><li><span class='ee-k'>WL_FWHM_B167:</span><span class='ee-v'>1213.8121,6.1279</span></li><li><span class='ee-k'>WL_FWHM_B168:</span><span class='ee-v'>1218.8209,6.1307</span></li><li><span class='ee-k'>WL_FWHM_B169:</span><span class='ee-v'>1223.8297,6.1334</span></li><li><span class='ee-k'>WL_FWHM_B170:</span><span class='ee-v'>1228.8386,6.1362</span></li><li><span class='ee-k'>WL_FWHM_B171:</span><span class='ee-v'>1233.8474,6.1389</span></li><li><span class='ee-k'>WL_FWHM_B172:</span><span class='ee-v'>1238.8562,6.1417</span></li><li><span class='ee-k'>WL_FWHM_B173:</span><span class='ee-v'>1243.8651,6.1445</span></li><li><span class='ee-k'>WL_FWHM_B174:</span><span class='ee-v'>1248.8739,6.1473</span></li><li><span class='ee-k'>WL_FWHM_B175:</span><span class='ee-v'>1253.8827,6.1501</span></li><li><span class='ee-k'>WL_FWHM_B176:</span><span class='ee-v'>1258.8915,6.1529</span></li><li><span class='ee-k'>WL_FWHM_B177:</span><span class='ee-v'>1263.9004,6.1558</span></li><li><span class='ee-k'>WL_FWHM_B178:</span><span class='ee-v'>1268.9092,6.1586</span></li><li><span class='ee-k'>WL_FWHM_B179:</span><span class='ee-v'>1273.918,6.1615</span></li><li><span class='ee-k'>WL_FWHM_B180:</span><span class='ee-v'>1278.9269,6.1643</span></li><li><span class='ee-k'>WL_FWHM_B181:</span><span class='ee-v'>1283.9357,6.1672</span></li><li><span class='ee-k'>WL_FWHM_B182:</span><span class='ee-v'>1288.9445,6.1701</span></li><li><span class='ee-k'>WL_FWHM_B183:</span><span class='ee-v'>1293.9534,6.173</span></li><li><span class='ee-k'>WL_FWHM_B184:</span><span class='ee-v'>1298.9622,6.176</span></li><li><span class='ee-k'>WL_FWHM_B185:</span><span class='ee-v'>1303.971,6.1789</span></li><li><span class='ee-k'>WL_FWHM_B186:</span><span class='ee-v'>1308.9799,6.1818</span></li><li><span class='ee-k'>WL_FWHM_B187:</span><span class='ee-v'>1313.9886,6.1848</span></li><li><span class='ee-k'>WL_FWHM_B188:</span><span class='ee-v'>1318.9976,6.1878</span></li><li><span class='ee-k'>WL_FWHM_B189:</span><span class='ee-v'>1324.0063,6.1908</span></li><li><span class='ee-k'>WL_FWHM_B190:</span><span class='ee-v'>1329.0153,6.1938</span></li><li><span class='ee-k'>WL_FWHM_B191:</span><span class='ee-v'>1334.024,6.1968</span></li><li><span class='ee-k'>WL_FWHM_B192:</span><span class='ee-v'>1339.0328,6.1998</span></li><li><span class='ee-k'>WL_FWHM_B193:</span><span class='ee-v'>1344.0416,6.2028</span></li><li><span class='ee-k'>WL_FWHM_B194:</span><span class='ee-v'>1349.0505,6.2059</span></li><li><span class='ee-k'>WL_FWHM_B195:</span><span class='ee-v'>1354.0593,6.2089</span></li><li><span class='ee-k'>WL_FWHM_B196:</span><span class='ee-v'>1359.0681,6.212</span></li><li><span class='ee-k'>WL_FWHM_B197:</span><span class='ee-v'>1364.077,6.2151</span></li><li><span class='ee-k'>WL_FWHM_B198:</span><span class='ee-v'>1369.0858,6.2182</span></li><li><span class='ee-k'>WL_FWHM_B199:</span><span class='ee-v'>1374.0946,6.2213</span></li><li><span class='ee-k'>WL_FWHM_B200:</span><span class='ee-v'>1379.1034,6.2244</span></li><li><span class='ee-k'>WL_FWHM_B201:</span><span class='ee-v'>1384.1123,6.2276</span></li><li><span class='ee-k'>WL_FWHM_B202:</span><span class='ee-v'>1389.1211,6.2307</span></li><li><span class='ee-k'>WL_FWHM_B203:</span><span class='ee-v'>1394.1299,6.2338</span></li><li><span class='ee-k'>WL_FWHM_B204:</span><span class='ee-v'>1399.1388,6.237</span></li><li><span class='ee-k'>WL_FWHM_B205:</span><span class='ee-v'>1404.1476,6.2402</span></li><li><span class='ee-k'>WL_FWHM_B206:</span><span class='ee-v'>1409.1564,6.2434</span></li><li><span class='ee-k'>WL_FWHM_B207:</span><span class='ee-v'>1414.1652,6.2466</span></li><li><span class='ee-k'>WL_FWHM_B208:</span><span class='ee-v'>1419.1741,6.2498</span></li><li><span class='ee-k'>WL_FWHM_B209:</span><span class='ee-v'>1424.1829,6.2531</span></li><li><span class='ee-k'>WL_FWHM_B210:</span><span class='ee-v'>1429.1917,6.2563</span></li><li><span class='ee-k'>WL_FWHM_B211:</span><span class='ee-v'>1434.2006,6.2596</span></li><li><span class='ee-k'>WL_FWHM_B212:</span><span class='ee-v'>1439.2094,6.2628</span></li><li><span class='ee-k'>WL_FWHM_B213:</span><span class='ee-v'>1444.2181,6.2661</span></li><li><span class='ee-k'>WL_FWHM_B214:</span><span class='ee-v'>1449.227,6.2694</span></li><li><span class='ee-k'>WL_FWHM_B215:</span><span class='ee-v'>1454.2358,6.2727</span></li><li><span class='ee-k'>WL_FWHM_B216:</span><span class='ee-v'>1459.2448,6.276</span></li><li><span class='ee-k'>WL_FWHM_B217:</span><span class='ee-v'>1464.2535,6.2793</span></li><li><span class='ee-k'>WL_FWHM_B218:</span><span class='ee-v'>1469.2625,6.2827</span></li><li><span class='ee-k'>WL_FWHM_B219:</span><span class='ee-v'>1474.2712,6.286</span></li><li><span class='ee-k'>WL_FWHM_B220:</span><span class='ee-v'>1479.28,6.2894</span></li><li><span class='ee-k'>WL_FWHM_B221:</span><span class='ee-v'>1484.2888,6.2928</span></li><li><span class='ee-k'>WL_FWHM_B222:</span><span class='ee-v'>1489.2977,6.2962</span></li><li><span class='ee-k'>WL_FWHM_B223:</span><span class='ee-v'>1494.3065,6.2996</span></li><li><span class='ee-k'>WL_FWHM_B224:</span><span class='ee-v'>1499.3153,6.303</span></li><li><span class='ee-k'>WL_FWHM_B225:</span><span class='ee-v'>1504.3242,6.3064</span></li><li><span class='ee-k'>WL_FWHM_B226:</span><span class='ee-v'>1509.333,6.3099</span></li><li><span class='ee-k'>WL_FWHM_B227:</span><span class='ee-v'>1514.3418,6.3133</span></li><li><span class='ee-k'>WL_FWHM_B228:</span><span class='ee-v'>1519.3507,6.3168</span></li><li><span class='ee-k'>WL_FWHM_B229:</span><span class='ee-v'>1524.3595,6.3203</span></li><li><span class='ee-k'>WL_FWHM_B230:</span><span class='ee-v'>1529.3683,6.3238</span></li><li><span class='ee-k'>WL_FWHM_B231:</span><span class='ee-v'>1534.3771,6.3272</span></li><li><span class='ee-k'>WL_FWHM_B232:</span><span class='ee-v'>1539.386,6.3308</span></li><li><span class='ee-k'>WL_FWHM_B233:</span><span class='ee-v'>1544.3948,6.3343</span></li><li><span class='ee-k'>WL_FWHM_B234:</span><span class='ee-v'>1549.4036,6.3378</span></li><li><span class='ee-k'>WL_FWHM_B235:</span><span class='ee-v'>1554.4125,6.3414</span></li><li><span class='ee-k'>WL_FWHM_B236:</span><span class='ee-v'>1559.4213,6.3449</span></li><li><span class='ee-k'>WL_FWHM_B237:</span><span class='ee-v'>1564.43,6.3485</span></li><li><span class='ee-k'>WL_FWHM_B238:</span><span class='ee-v'>1569.4388,6.3521</span></li><li><span class='ee-k'>WL_FWHM_B239:</span><span class='ee-v'>1574.4478,6.3557</span></li><li><span class='ee-k'>WL_FWHM_B240:</span><span class='ee-v'>1579.4565,6.3593</span></li><li><span class='ee-k'>WL_FWHM_B241:</span><span class='ee-v'>1584.4655,6.3629</span></li><li><span class='ee-k'>WL_FWHM_B242:</span><span class='ee-v'>1589.4742,6.3666</span></li><li><span class='ee-k'>WL_FWHM_B243:</span><span class='ee-v'>1594.4832,6.3702</span></li><li><span class='ee-k'>WL_FWHM_B244:</span><span class='ee-v'>1599.492,6.3739</span></li><li><span class='ee-k'>WL_FWHM_B245:</span><span class='ee-v'>1604.5007,6.3776</span></li><li><span class='ee-k'>WL_FWHM_B246:</span><span class='ee-v'>1609.5096,6.3812</span></li><li><span class='ee-k'>WL_FWHM_B247:</span><span class='ee-v'>1614.5184,6.3849</span></li><li><span class='ee-k'>WL_FWHM_B248:</span><span class='ee-v'>1619.5272,6.3886</span></li><li><span class='ee-k'>WL_FWHM_B249:</span><span class='ee-v'>1624.5361,6.3924</span></li><li><span class='ee-k'>WL_FWHM_B250:</span><span class='ee-v'>1629.5449,6.3961</span></li><li><span class='ee-k'>WL_FWHM_B251:</span><span class='ee-v'>1634.5537,6.3999</span></li><li><span class='ee-k'>WL_FWHM_B252:</span><span class='ee-v'>1639.5625,6.4036</span></li><li><span class='ee-k'>WL_FWHM_B253:</span><span class='ee-v'>1644.5714,6.4074</span></li><li><span class='ee-k'>WL_FWHM_B254:</span><span class='ee-v'>1649.5802,6.4112</span></li><li><span class='ee-k'>WL_FWHM_B255:</span><span class='ee-v'>1654.589,6.415</span></li><li><span class='ee-k'>WL_FWHM_B256:</span><span class='ee-v'>1659.5979,6.4188</span></li><li><span class='ee-k'>WL_FWHM_B257:</span><span class='ee-v'>1664.6067,6.4226</span></li><li><span class='ee-k'>WL_FWHM_B258:</span><span class='ee-v'>1669.6155,6.4264</span></li><li><span class='ee-k'>WL_FWHM_B259:</span><span class='ee-v'>1674.6243,6.4303</span></li><li><span class='ee-k'>WL_FWHM_B260:</span><span class='ee-v'>1679.6332,6.4341</span></li><li><span class='ee-k'>WL_FWHM_B261:</span><span class='ee-v'>1684.642,6.438</span></li><li><span class='ee-k'>WL_FWHM_B262:</span><span class='ee-v'>1689.6508,6.4419</span></li><li><span class='ee-k'>WL_FWHM_B263:</span><span class='ee-v'>1694.6595,6.4458</span></li><li><span class='ee-k'>WL_FWHM_B264:</span><span class='ee-v'>1699.6685,6.4497</span></li><li><span class='ee-k'>WL_FWHM_B265:</span><span class='ee-v'>1704.6772,6.4536</span></li><li><span class='ee-k'>WL_FWHM_B266:</span><span class='ee-v'>1709.6862,6.4575</span></li><li><span class='ee-k'>WL_FWHM_B267:</span><span class='ee-v'>1714.695,6.4615</span></li><li><span class='ee-k'>WL_FWHM_B268:</span><span class='ee-v'>1719.7039,6.4654</span></li><li><span class='ee-k'>WL_FWHM_B269:</span><span class='ee-v'>1724.7126,6.4694</span></li><li><span class='ee-k'>WL_FWHM_B270:</span><span class='ee-v'>1729.7216,6.4734</span></li><li><span class='ee-k'>WL_FWHM_B271:</span><span class='ee-v'>1734.7303,6.4774</span></li><li><span class='ee-k'>WL_FWHM_B272:</span><span class='ee-v'>1739.7393,6.4814</span></li><li><span class='ee-k'>WL_FWHM_B273:</span><span class='ee-v'>1744.748,6.4854</span></li><li><span class='ee-k'>WL_FWHM_B274:</span><span class='ee-v'>1749.7568,6.4894</span></li><li><span class='ee-k'>WL_FWHM_B275:</span><span class='ee-v'>1754.7656,6.4935</span></li><li><span class='ee-k'>WL_FWHM_B276:</span><span class='ee-v'>1759.7744,6.4975</span></li><li><span class='ee-k'>WL_FWHM_B277:</span><span class='ee-v'>1764.7834,6.5016</span></li><li><span class='ee-k'>WL_FWHM_B278:</span><span class='ee-v'>1769.7922,6.5057</span></li><li><span class='ee-k'>WL_FWHM_B279:</span><span class='ee-v'>1774.801,6.5098</span></li><li><span class='ee-k'>WL_FWHM_B280:</span><span class='ee-v'>1779.8098,6.5139</span></li><li><span class='ee-k'>WL_FWHM_B281:</span><span class='ee-v'>1784.8186,6.518</span></li><li><span class='ee-k'>WL_FWHM_B282:</span><span class='ee-v'>1789.8274,6.5221</span></li><li><span class='ee-k'>WL_FWHM_B283:</span><span class='ee-v'>1794.8362,6.5263</span></li><li><span class='ee-k'>WL_FWHM_B284:</span><span class='ee-v'>1799.845,6.5304</span></li><li><span class='ee-k'>WL_FWHM_B285:</span><span class='ee-v'>1804.8538,6.5346</span></li><li><span class='ee-k'>WL_FWHM_B286:</span><span class='ee-v'>1809.8625,6.5388</span></li><li><span class='ee-k'>WL_FWHM_B287:</span><span class='ee-v'>1814.8716,6.5429</span></li><li><span class='ee-k'>WL_FWHM_B288:</span><span class='ee-v'>1819.8804,6.5472</span></li><li><span class='ee-k'>WL_FWHM_B289:</span><span class='ee-v'>1824.8892,6.5514</span></li><li><span class='ee-k'>WL_FWHM_B290:</span><span class='ee-v'>1829.898,6.5556</span></li><li><span class='ee-k'>WL_FWHM_B291:</span><span class='ee-v'>1834.9069,6.5598</span></li><li><span class='ee-k'>WL_FWHM_B292:</span><span class='ee-v'>1839.9156,6.5641</span></li><li><span class='ee-k'>WL_FWHM_B293:</span><span class='ee-v'>1844.9246,6.5683</span></li><li><span class='ee-k'>WL_FWHM_B294:</span><span class='ee-v'>1849.9333,6.5726</span></li><li><span class='ee-k'>WL_FWHM_B295:</span><span class='ee-v'>1854.9423,6.5769</span></li><li><span class='ee-k'>WL_FWHM_B296:</span><span class='ee-v'>1859.951,6.5812</span></li><li><span class='ee-k'>WL_FWHM_B297:</span><span class='ee-v'>1864.9598,6.5855</span></li><li><span class='ee-k'>WL_FWHM_B298:</span><span class='ee-v'>1869.9688,6.5898</span></li><li><span class='ee-k'>WL_FWHM_B299:</span><span class='ee-v'>1874.9775,6.5942</span></li><li><span class='ee-k'>WL_FWHM_B300:</span><span class='ee-v'>1879.9865,6.5985</span></li><li><span class='ee-k'>WL_FWHM_B301:</span><span class='ee-v'>1884.9952,6.6029</span></li><li><span class='ee-k'>WL_FWHM_B302:</span><span class='ee-v'>1890.004,6.6073</span></li><li><span class='ee-k'>WL_FWHM_B303:</span><span class='ee-v'>1895.0128,6.6116</span></li><li><span class='ee-k'>WL_FWHM_B304:</span><span class='ee-v'>1900.0219,6.616</span></li><li><span class='ee-k'>WL_FWHM_B305:</span><span class='ee-v'>1905.0306,6.6205</span></li><li><span class='ee-k'>WL_FWHM_B306:</span><span class='ee-v'>1910.0394,6.6249</span></li><li><span class='ee-k'>WL_FWHM_B307:</span><span class='ee-v'>1915.048,6.6293</span></li><li><span class='ee-k'>WL_FWHM_B308:</span><span class='ee-v'>1920.057,6.6338</span></li><li><span class='ee-k'>WL_FWHM_B309:</span><span class='ee-v'>1925.0658,6.6382</span></li><li><span class='ee-k'>WL_FWHM_B310:</span><span class='ee-v'>1930.0746,6.6427</span></li><li><span class='ee-k'>WL_FWHM_B311:</span><span class='ee-v'>1935.0834,6.6472</span></li><li><span class='ee-k'>WL_FWHM_B312:</span><span class='ee-v'>1940.0922,6.6517</span></li><li><span class='ee-k'>WL_FWHM_B313:</span><span class='ee-v'>1945.101,6.6562</span></li><li><span class='ee-k'>WL_FWHM_B314:</span><span class='ee-v'>1950.1097,6.6607</span></li><li><span class='ee-k'>WL_FWHM_B315:</span><span class='ee-v'>1955.1188,6.6652</span></li><li><span class='ee-k'>WL_FWHM_B316:</span><span class='ee-v'>1960.1276,6.6698</span></li><li><span class='ee-k'>WL_FWHM_B317:</span><span class='ee-v'>1965.1364,6.6744</span></li><li><span class='ee-k'>WL_FWHM_B318:</span><span class='ee-v'>1970.1451,6.6789</span></li><li><span class='ee-k'>WL_FWHM_B319:</span><span class='ee-v'>1975.154,6.6835</span></li><li><span class='ee-k'>WL_FWHM_B320:</span><span class='ee-v'>1980.1628,6.6881</span></li><li><span class='ee-k'>WL_FWHM_B321:</span><span class='ee-v'>1985.1718,6.6927</span></li><li><span class='ee-k'>WL_FWHM_B322:</span><span class='ee-v'>1990.1805,6.6973</span></li><li><span class='ee-k'>WL_FWHM_B323:</span><span class='ee-v'>1995.1895,6.702</span></li><li><span class='ee-k'>WL_FWHM_B324:</span><span class='ee-v'>2000.1982,6.7066</span></li><li><span class='ee-k'>WL_FWHM_B325:</span><span class='ee-v'>2005.2072,6.7113</span></li><li><span class='ee-k'>WL_FWHM_B326:</span><span class='ee-v'>2010.216,6.7159</span></li><li><span class='ee-k'>WL_FWHM_B327:</span><span class='ee-v'>2015.2249,6.7206</span></li><li><span class='ee-k'>WL_FWHM_B328:</span><span class='ee-v'>2020.2336,6.7253</span></li><li><span class='ee-k'>WL_FWHM_B329:</span><span class='ee-v'>2025.2424,6.73</span></li><li><span class='ee-k'>WL_FWHM_B330:</span><span class='ee-v'>2030.2512,6.7347</span></li><li><span class='ee-k'>WL_FWHM_B331:</span><span class='ee-v'>2035.26,6.7395</span></li><li><span class='ee-k'>WL_FWHM_B332:</span><span class='ee-v'>2040.269,6.7442</span></li><li><span class='ee-k'>WL_FWHM_B333:</span><span class='ee-v'>2045.2778,6.749</span></li><li><span class='ee-k'>WL_FWHM_B334:</span><span class='ee-v'>2050.2866,6.7537</span></li><li><span class='ee-k'>WL_FWHM_B335:</span><span class='ee-v'>2055.2954,6.7585</span></li><li><span class='ee-k'>WL_FWHM_B336:</span><span class='ee-v'>2060.3042,6.7633</span></li><li><span class='ee-k'>WL_FWHM_B337:</span><span class='ee-v'>2065.313,6.7681</span></li><li><span class='ee-k'>WL_FWHM_B338:</span><span class='ee-v'>2070.3218,6.7729</span></li><li><span class='ee-k'>WL_FWHM_B339:</span><span class='ee-v'>2075.3308,6.7777</span></li><li><span class='ee-k'>WL_FWHM_B340:</span><span class='ee-v'>2080.3396,6.7826</span></li><li><span class='ee-k'>WL_FWHM_B341:</span><span class='ee-v'>2085.3484,6.7874</span></li><li><span class='ee-k'>WL_FWHM_B342:</span><span class='ee-v'>2090.3572,6.7923</span></li><li><span class='ee-k'>WL_FWHM_B343:</span><span class='ee-v'>2095.366,6.7972</span></li><li><span class='ee-k'>WL_FWHM_B344:</span><span class='ee-v'>2100.3748,6.8021</span></li><li><span class='ee-k'>WL_FWHM_B345:</span><span class='ee-v'>2105.3835,6.807</span></li><li><span class='ee-k'>WL_FWHM_B346:</span><span class='ee-v'>2110.3926,6.8119</span></li><li><span class='ee-k'>WL_FWHM_B347:</span><span class='ee-v'>2115.4014,6.8168</span></li><li><span class='ee-k'>WL_FWHM_B348:</span><span class='ee-v'>2120.4102,6.8218</span></li><li><span class='ee-k'>WL_FWHM_B349:</span><span class='ee-v'>2125.419,6.8267</span></li><li><span class='ee-k'>WL_FWHM_B350:</span><span class='ee-v'>2130.4277,6.8317</span></li><li><span class='ee-k'>WL_FWHM_B351:</span><span class='ee-v'>2135.4365,6.8366</span></li><li><span class='ee-k'>WL_FWHM_B352:</span><span class='ee-v'>2140.4453,6.8416</span></li><li><span class='ee-k'>WL_FWHM_B353:</span><span class='ee-v'>2145.4543,6.8466</span></li><li><span class='ee-k'>WL_FWHM_B354:</span><span class='ee-v'>2150.4631,6.8516</span></li><li><span class='ee-k'>WL_FWHM_B355:</span><span class='ee-v'>2155.472,6.8567</span></li><li><span class='ee-k'>WL_FWHM_B356:</span><span class='ee-v'>2160.4807,6.8617</span></li><li><span class='ee-k'>WL_FWHM_B357:</span><span class='ee-v'>2165.4895,6.8668</span></li><li><span class='ee-k'>WL_FWHM_B358:</span><span class='ee-v'>2170.4983,6.8718</span></li><li><span class='ee-k'>WL_FWHM_B359:</span><span class='ee-v'>2175.507,6.8769</span></li><li><span class='ee-k'>WL_FWHM_B360:</span><span class='ee-v'>2180.516,6.882</span></li><li><span class='ee-k'>WL_FWHM_B361:</span><span class='ee-v'>2185.525,6.8871</span></li><li><span class='ee-k'>WL_FWHM_B362:</span><span class='ee-v'>2190.5337,6.8922</span></li><li><span class='ee-k'>WL_FWHM_B363:</span><span class='ee-v'>2195.5425,6.8973</span></li><li><span class='ee-k'>WL_FWHM_B364:</span><span class='ee-v'>2200.5515,6.9025</span></li><li><span class='ee-k'>WL_FWHM_B365:</span><span class='ee-v'>2205.5603,6.9076</span></li><li><span class='ee-k'>WL_FWHM_B366:</span><span class='ee-v'>2210.569,6.9128</span></li><li><span class='ee-k'>WL_FWHM_B367:</span><span class='ee-v'>2215.578,6.9179</span></li><li><span class='ee-k'>WL_FWHM_B368:</span><span class='ee-v'>2220.5867,6.9231</span></li><li><span class='ee-k'>WL_FWHM_B369:</span><span class='ee-v'>2225.5955,6.9283</span></li><li><span class='ee-k'>WL_FWHM_B370:</span><span class='ee-v'>2230.6045,6.9335</span></li><li><span class='ee-k'>WL_FWHM_B371:</span><span class='ee-v'>2235.6133,6.9388</span></li><li><span class='ee-k'>WL_FWHM_B372:</span><span class='ee-v'>2240.622,6.944</span></li><li><span class='ee-k'>WL_FWHM_B373:</span><span class='ee-v'>2245.6309,6.9492</span></li><li><span class='ee-k'>WL_FWHM_B374:</span><span class='ee-v'>2250.6396,6.9545</span></li><li><span class='ee-k'>WL_FWHM_B375:</span><span class='ee-v'>2255.6484,6.9598</span></li><li><span class='ee-k'>WL_FWHM_B376:</span><span class='ee-v'>2260.6572,6.965</span></li><li><span class='ee-k'>WL_FWHM_B377:</span><span class='ee-v'>2265.6663,6.9703</span></li><li><span class='ee-k'>WL_FWHM_B378:</span><span class='ee-v'>2270.675,6.9756</span></li><li><span class='ee-k'>WL_FWHM_B379:</span><span class='ee-v'>2275.6838,6.981</span></li><li><span class='ee-k'>WL_FWHM_B380:</span><span class='ee-v'>2280.6926,6.9863</span></li><li><span class='ee-k'>WL_FWHM_B381:</span><span class='ee-v'>2285.7014,6.9916</span></li><li><span class='ee-k'>WL_FWHM_B382:</span><span class='ee-v'>2290.7102,6.997</span></li><li><span class='ee-k'>WL_FWHM_B383:</span><span class='ee-v'>2295.719,7.0024</span></li><li><span class='ee-k'>WL_FWHM_B384:</span><span class='ee-v'>2300.728,7.0078</span></li><li><span class='ee-k'>WL_FWHM_B385:</span><span class='ee-v'>2305.7368,7.0132</span></li><li><span class='ee-k'>WL_FWHM_B386:</span><span class='ee-v'>2310.7456,7.0186</span></li><li><span class='ee-k'>WL_FWHM_B387:</span><span class='ee-v'>2315.7544,7.024</span></li><li><span class='ee-k'>WL_FWHM_B388:</span><span class='ee-v'>2320.7632,7.0294</span></li><li><span class='ee-k'>WL_FWHM_B389:</span><span class='ee-v'>2325.7722,7.0348</span></li><li><span class='ee-k'>WL_FWHM_B390:</span><span class='ee-v'>2330.781,7.0403</span></li><li><span class='ee-k'>WL_FWHM_B391:</span><span class='ee-v'>2335.7898,7.0458</span></li><li><span class='ee-k'>WL_FWHM_B392:</span><span class='ee-v'>2340.7986,7.0512</span></li><li><span class='ee-k'>WL_FWHM_B393:</span><span class='ee-v'>2345.8074,7.0568</span></li><li><span class='ee-k'>WL_FWHM_B394:</span><span class='ee-v'>2350.8164,7.0622</span></li><li><span class='ee-k'>WL_FWHM_B395:</span><span class='ee-v'>2355.8252,7.0678</span></li><li><span class='ee-k'>WL_FWHM_B396:</span><span class='ee-v'>2360.834,7.0733</span></li><li><span class='ee-k'>WL_FWHM_B397:</span><span class='ee-v'>2365.8428,7.0788</span></li><li><span class='ee-k'>WL_FWHM_B398:</span><span class='ee-v'>2370.8516,7.0844</span></li><li><span class='ee-k'>WL_FWHM_B399:</span><span class='ee-v'>2375.8604,7.09</span></li><li><span class='ee-k'>WL_FWHM_B400:</span><span class='ee-v'>2380.8691,7.0955</span></li><li><span class='ee-k'>WL_FWHM_B401:</span><span class='ee-v'>2385.8782,7.1011</span></li><li><span class='ee-k'>WL_FWHM_B402:</span><span class='ee-v'>2390.887,7.1067</span></li><li><span class='ee-k'>WL_FWHM_B403:</span><span class='ee-v'>2395.8958,7.1124</span></li><li><span class='ee-k'>WL_FWHM_B404:</span><span class='ee-v'>2400.9045,7.118</span></li><li><span class='ee-k'>WL_FWHM_B405:</span><span class='ee-v'>2405.9133,7.1236</span></li><li><span class='ee-k'>WL_FWHM_B406:</span><span class='ee-v'>2410.922,7.1293</span></li><li><span class='ee-k'>WL_FWHM_B407:</span><span class='ee-v'>2415.931,7.1349</span></li><li><span class='ee-k'>WL_FWHM_B408:</span><span class='ee-v'>2420.94,7.1406</span></li><li><span class='ee-k'>WL_FWHM_B409:</span><span class='ee-v'>2425.9487,7.1463</span></li><li><span class='ee-k'>WL_FWHM_B410:</span><span class='ee-v'>2430.9575,7.152</span></li><li><span class='ee-k'>WL_FWHM_B411:</span><span class='ee-v'>2435.9663,7.1577</span></li><li><span class='ee-k'>WL_FWHM_B412:</span><span class='ee-v'>2440.975,7.1634</span></li><li><span class='ee-k'>WL_FWHM_B413:</span><span class='ee-v'>2445.984,7.1692</span></li><li><span class='ee-k'>WL_FWHM_B414:</span><span class='ee-v'>2450.993,7.1749</span></li><li><span class='ee-k'>WL_FWHM_B415:</span><span class='ee-v'>2456.0017,7.1807</span></li><li><span class='ee-k'>WL_FWHM_B416:</span><span class='ee-v'>2461.0105,7.1865</span></li><li><span class='ee-k'>WL_FWHM_B417:</span><span class='ee-v'>2466.0193,7.1922</span></li><li><span class='ee-k'>WL_FWHM_B418:</span><span class='ee-v'>2471.028,7.198</span></li><li><span class='ee-k'>WL_FWHM_B419:</span><span class='ee-v'>2476.037,7.2039</span></li><li><span class='ee-k'>WL_FWHM_B420:</span><span class='ee-v'>2481.046,7.2097</span></li><li><span class='ee-k'>WL_FWHM_B421:</span><span class='ee-v'>2486.0547,7.2155</span></li><li><span class='ee-k'>WL_FWHM_B422:</span><span class='ee-v'>2491.0635,7.2214</span></li><li><span class='ee-k'>WL_FWHM_B423:</span><span class='ee-v'>2496.0723,7.2272</span></li><li><span class='ee-k'>WL_FWHM_B424:</span><span class='ee-v'>2501.081,7.2331</span></li><li><span class='ee-k'>WL_FWHM_B425:</span><span class='ee-v'>2506.0898,7.239</span></li><li><span class='ee-k'>WL_FWHM_B426:</span><span class='ee-v'>2511.0989,7.2449</span></li><li><span class='ee-k'>system:asset_size:</span><span class='ee-v'>68059.439009 MB</span></li><li><label class='ee-shut'>system:band_names: List (442 elements)<input type='checkbox' class='ee-toggle'></label><ul><li><span class='ee-k'>0:</span><span class='ee-v'>B001</span></li><li><span class='ee-k'>1:</span><span class='ee-v'>B002</span></li><li><span class='ee-k'>2:</span><span class='ee-v'>B003</span></li><li><span class='ee-k'>3:</span><span class='ee-v'>B004</span></li><li><span class='ee-k'>4:</span><span class='ee-v'>B005</span></li><li><span class='ee-k'>5:</span><span class='ee-v'>B006</span></li><li><span class='ee-k'>6:</span><span class='ee-v'>B007</span></li><li><span class='ee-k'>7:</span><span class='ee-v'>B008</span></li><li><span class='ee-k'>8:</span><span class='ee-v'>B009</span></li><li><span class='ee-k'>9:</span><span class='ee-v'>B010</span></li><li><span class='ee-k'>10:</span><span class='ee-v'>B011</span></li><li><span class='ee-k'>11:</span><span class='ee-v'>B012</span></li><li><span class='ee-k'>12:</span><span class='ee-v'>B013</span></li><li><span class='ee-k'>13:</span><span class='ee-v'>B014</span></li><li><span class='ee-k'>14:</span><span class='ee-v'>B015</span></li><li><span class='ee-k'>15:</span><span class='ee-v'>B016</span></li><li><span class='ee-k'>16:</span><span class='ee-v'>B017</span></li><li><span class='ee-k'>17:</span><span class='ee-v'>B018</span></li><li><span class='ee-k'>18:</span><span class='ee-v'>B019</span></li><li><span class='ee-k'>19:</span><span class='ee-v'>B020</span></li><li><span class='ee-k'>20:</span><span class='ee-v'>B021</span></li><li><span class='ee-k'>21:</span><span class='ee-v'>B022</span></li><li><span class='ee-k'>22:</span><span class='ee-v'>B023</span></li><li><span class='ee-k'>23:</span><span class='ee-v'>B024</span></li><li><span class='ee-k'>24:</span><span class='ee-v'>B025</span></li><li><span class='ee-k'>25:</span><span class='ee-v'>B026</span></li><li><span class='ee-k'>26:</span><span class='ee-v'>B027</span></li><li><span class='ee-k'>27:</span><span class='ee-v'>B028</span></li><li><span class='ee-k'>28:</span><span class='ee-v'>B029</span></li><li><span class='ee-k'>29:</span><span class='ee-v'>B030</span></li><li><span class='ee-k'>30:</span><span class='ee-v'>B031</span></li><li><span class='ee-k'>31:</span><span class='ee-v'>B032</span></li><li><span class='ee-k'>32:</span><span class='ee-v'>B033</span></li><li><span class='ee-k'>33:</span><span class='ee-v'>B034</span></li><li><span class='ee-k'>34:</span><span class='ee-v'>B035</span></li><li><span class='ee-k'>35:</span><span class='ee-v'>B036</span></li><li><span class='ee-k'>36:</span><span class='ee-v'>B037</span></li><li><span class='ee-k'>37:</span><span class='ee-v'>B038</span></li><li><span class='ee-k'>38:</span><span class='ee-v'>B039</span></li><li><span class='ee-k'>39:</span><span class='ee-v'>B040</span></li><li><span class='ee-k'>40:</span><span class='ee-v'>B041</span></li><li><span class='ee-k'>41:</span><span class='ee-v'>B042</span></li><li><span class='ee-k'>42:</span><span class='ee-v'>B043</span></li><li><span class='ee-k'>43:</span><span class='ee-v'>B044</span></li><li><span class='ee-k'>44:</span><span class='ee-v'>B045</span></li><li><span class='ee-k'>45:</span><span class='ee-v'>B046</span></li><li><span class='ee-k'>46:</span><span class='ee-v'>B047</span></li><li><span class='ee-k'>47:</span><span class='ee-v'>B048</span></li><li><span class='ee-k'>48:</span><span class='ee-v'>B049</span></li><li><span class='ee-k'>49:</span><span class='ee-v'>B050</span></li><li><span class='ee-k'>50:</span><span class='ee-v'>B051</span></li><li><span class='ee-k'>51:</span><span class='ee-v'>B052</span></li><li><span class='ee-k'>52:</span><span class='ee-v'>B053</span></li><li><span class='ee-k'>53:</span><span class='ee-v'>B054</span></li><li><span class='ee-k'>54:</span><span class='ee-v'>B055</span></li><li><span class='ee-k'>55:</span><span class='ee-v'>B056</span></li><li><span class='ee-k'>56:</span><span class='ee-v'>B057</span></li><li><span class='ee-k'>57:</span><span class='ee-v'>B058</span></li><li><span class='ee-k'>58:</span><span class='ee-v'>B059</span></li><li><span class='ee-k'>59:</span><span class='ee-v'>B060</span></li><li><span class='ee-k'>60:</span><span class='ee-v'>B061</span></li><li><span class='ee-k'>61:</span><span class='ee-v'>B062</span></li><li><span class='ee-k'>62:</span><span class='ee-v'>B063</span></li><li><span class='ee-k'>63:</span><span class='ee-v'>B064</span></li><li><span class='ee-k'>64:</span><span class='ee-v'>B065</span></li><li><span class='ee-k'>65:</span><span class='ee-v'>B066</span></li><li><span class='ee-k'>66:</span><span class='ee-v'>B067</span></li><li><span class='ee-k'>67:</span><span class='ee-v'>B068</span></li><li><span class='ee-k'>68:</span><span class='ee-v'>B069</span></li><li><span class='ee-k'>69:</span><span class='ee-v'>B070</span></li><li><span class='ee-k'>70:</span><span class='ee-v'>B071</span></li><li><span class='ee-k'>71:</span><span class='ee-v'>B072</span></li><li><span class='ee-k'>72:</span><span class='ee-v'>B073</span></li><li><span class='ee-k'>73:</span><span class='ee-v'>B074</span></li><li><span class='ee-k'>74:</span><span class='ee-v'>B075</span></li><li><span class='ee-k'>75:</span><span class='ee-v'>B076</span></li><li><span class='ee-k'>76:</span><span class='ee-v'>B077</span></li><li><span class='ee-k'>77:</span><span class='ee-v'>B078</span></li><li><span class='ee-k'>78:</span><span class='ee-v'>B079</span></li><li><span class='ee-k'>79:</span><span class='ee-v'>B080</span></li><li><span class='ee-k'>80:</span><span class='ee-v'>B081</span></li><li><span class='ee-k'>81:</span><span class='ee-v'>B082</span></li><li><span class='ee-k'>82:</span><span class='ee-v'>B083</span></li><li><span class='ee-k'>83:</span><span class='ee-v'>B084</span></li><li><span class='ee-k'>84:</span><span class='ee-v'>B085</span></li><li><span class='ee-k'>85:</span><span class='ee-v'>B086</span></li><li><span class='ee-k'>86:</span><span class='ee-v'>B087</span></li><li><span class='ee-k'>87:</span><span class='ee-v'>B088</span></li><li><span class='ee-k'>88:</span><span class='ee-v'>B089</span></li><li><span class='ee-k'>89:</span><span class='ee-v'>B090</span></li><li><span class='ee-k'>90:</span><span class='ee-v'>B091</span></li><li><span class='ee-k'>91:</span><span class='ee-v'>B092</span></li><li><span class='ee-k'>92:</span><span class='ee-v'>B093</span></li><li><span class='ee-k'>93:</span><span class='ee-v'>B094</span></li><li><span class='ee-k'>94:</span><span class='ee-v'>B095</span></li><li><span class='ee-k'>95:</span><span class='ee-v'>B096</span></li><li><span class='ee-k'>96:</span><span class='ee-v'>B097</span></li><li><span class='ee-k'>97:</span><span class='ee-v'>B098</span></li><li><span class='ee-k'>98:</span><span class='ee-v'>B099</span></li><li><span class='ee-k'>99:</span><span class='ee-v'>B100</span></li><li><span class='ee-k'>100:</span><span class='ee-v'>B101</span></li><li><span class='ee-k'>101:</span><span class='ee-v'>B102</span></li><li><span class='ee-k'>102:</span><span class='ee-v'>B103</span></li><li><span class='ee-k'>103:</span><span class='ee-v'>B104</span></li><li><span class='ee-k'>104:</span><span class='ee-v'>B105</span></li><li><span class='ee-k'>105:</span><span class='ee-v'>B106</span></li><li><span class='ee-k'>106:</span><span class='ee-v'>B107</span></li><li><span class='ee-k'>107:</span><span class='ee-v'>B108</span></li><li><span class='ee-k'>108:</span><span class='ee-v'>B109</span></li><li><span class='ee-k'>109:</span><span class='ee-v'>B110</span></li><li><span class='ee-k'>110:</span><span class='ee-v'>B111</span></li><li><span class='ee-k'>111:</span><span class='ee-v'>B112</span></li><li><span class='ee-k'>112:</span><span class='ee-v'>B113</span></li><li><span class='ee-k'>113:</span><span class='ee-v'>B114</span></li><li><span class='ee-k'>114:</span><span class='ee-v'>B115</span></li><li><span class='ee-k'>115:</span><span class='ee-v'>B116</span></li><li><span class='ee-k'>116:</span><span class='ee-v'>B117</span></li><li><span class='ee-k'>117:</span><span class='ee-v'>B118</span></li><li><span class='ee-k'>118:</span><span class='ee-v'>B119</span></li><li><span class='ee-k'>119:</span><span class='ee-v'>B120</span></li><li><span class='ee-k'>120:</span><span class='ee-v'>B121</span></li><li><span class='ee-k'>121:</span><span class='ee-v'>B122</span></li><li><span class='ee-k'>122:</span><span class='ee-v'>B123</span></li><li><span class='ee-k'>123:</span><span class='ee-v'>B124</span></li><li><span class='ee-k'>124:</span><span class='ee-v'>B125</span></li><li><span class='ee-k'>125:</span><span class='ee-v'>B126</span></li><li><span class='ee-k'>126:</span><span class='ee-v'>B127</span></li><li><span class='ee-k'>127:</span><span class='ee-v'>B128</span></li><li><span class='ee-k'>128:</span><span class='ee-v'>B129</span></li><li><span class='ee-k'>129:</span><span class='ee-v'>B130</span></li><li><span class='ee-k'>130:</span><span class='ee-v'>B131</span></li><li><span class='ee-k'>131:</span><span class='ee-v'>B132</span></li><li><span class='ee-k'>132:</span><span class='ee-v'>B133</span></li><li><span class='ee-k'>133:</span><span class='ee-v'>B134</span></li><li><span class='ee-k'>134:</span><span class='ee-v'>B135</span></li><li><span class='ee-k'>135:</span><span class='ee-v'>B136</span></li><li><span class='ee-k'>136:</span><span class='ee-v'>B137</span></li><li><span class='ee-k'>137:</span><span class='ee-v'>B138</span></li><li><span class='ee-k'>138:</span><span class='ee-v'>B139</span></li><li><span class='ee-k'>139:</span><span class='ee-v'>B140</span></li><li><span class='ee-k'>140:</span><span class='ee-v'>B141</span></li><li><span class='ee-k'>141:</span><span class='ee-v'>B142</span></li><li><span class='ee-k'>142:</span><span class='ee-v'>B143</span></li><li><span class='ee-k'>143:</span><span class='ee-v'>B144</span></li><li><span class='ee-k'>144:</span><span class='ee-v'>B145</span></li><li><span class='ee-k'>145:</span><span class='ee-v'>B146</span></li><li><span class='ee-k'>146:</span><span class='ee-v'>B147</span></li><li><span class='ee-k'>147:</span><span class='ee-v'>B148</span></li><li><span class='ee-k'>148:</span><span class='ee-v'>B149</span></li><li><span class='ee-k'>149:</span><span class='ee-v'>B150</span></li><li><span class='ee-k'>150:</span><span class='ee-v'>B151</span></li><li><span class='ee-k'>151:</span><span class='ee-v'>B152</span></li><li><span class='ee-k'>152:</span><span class='ee-v'>B153</span></li><li><span class='ee-k'>153:</span><span class='ee-v'>B154</span></li><li><span class='ee-k'>154:</span><span class='ee-v'>B155</span></li><li><span class='ee-k'>155:</span><span class='ee-v'>B156</span></li><li><span class='ee-k'>156:</span><span class='ee-v'>B157</span></li><li><span class='ee-k'>157:</span><span class='ee-v'>B158</span></li><li><span class='ee-k'>158:</span><span class='ee-v'>B159</span></li><li><span class='ee-k'>159:</span><span class='ee-v'>B160</span></li><li><span class='ee-k'>160:</span><span class='ee-v'>B161</span></li><li><span class='ee-k'>161:</span><span class='ee-v'>B162</span></li><li><span class='ee-k'>162:</span><span class='ee-v'>B163</span></li><li><span class='ee-k'>163:</span><span class='ee-v'>B164</span></li><li><span class='ee-k'>164:</span><span class='ee-v'>B165</span></li><li><span class='ee-k'>165:</span><span class='ee-v'>B166</span></li><li><span class='ee-k'>166:</span><span class='ee-v'>B167</span></li><li><span class='ee-k'>167:</span><span class='ee-v'>B168</span></li><li><span class='ee-k'>168:</span><span class='ee-v'>B169</span></li><li><span class='ee-k'>169:</span><span class='ee-v'>B170</span></li><li><span class='ee-k'>170:</span><span class='ee-v'>B171</span></li><li><span class='ee-k'>171:</span><span class='ee-v'>B172</span></li><li><span class='ee-k'>172:</span><span class='ee-v'>B173</span></li><li><span class='ee-k'>173:</span><span class='ee-v'>B174</span></li><li><span class='ee-k'>174:</span><span class='ee-v'>B175</span></li><li><span class='ee-k'>175:</span><span class='ee-v'>B176</span></li><li><span class='ee-k'>176:</span><span class='ee-v'>B177</span></li><li><span class='ee-k'>177:</span><span class='ee-v'>B178</span></li><li><span class='ee-k'>178:</span><span class='ee-v'>B179</span></li><li><span class='ee-k'>179:</span><span class='ee-v'>B180</span></li><li><span class='ee-k'>180:</span><span class='ee-v'>B181</span></li><li><span class='ee-k'>181:</span><span class='ee-v'>B182</span></li><li><span class='ee-k'>182:</span><span class='ee-v'>B183</span></li><li><span class='ee-k'>183:</span><span class='ee-v'>B184</span></li><li><span class='ee-k'>184:</span><span class='ee-v'>B185</span></li><li><span class='ee-k'>185:</span><span class='ee-v'>B186</span></li><li><span class='ee-k'>186:</span><span class='ee-v'>B187</span></li><li><span class='ee-k'>187:</span><span class='ee-v'>B188</span></li><li><span class='ee-k'>188:</span><span class='ee-v'>B189</span></li><li><span class='ee-k'>189:</span><span class='ee-v'>B190</span></li><li><span class='ee-k'>190:</span><span class='ee-v'>B191</span></li><li><span class='ee-k'>191:</span><span class='ee-v'>B192</span></li><li><span class='ee-k'>192:</span><span class='ee-v'>B193</span></li><li><span class='ee-k'>193:</span><span class='ee-v'>B194</span></li><li><span class='ee-k'>194:</span><span class='ee-v'>B195</span></li><li><span class='ee-k'>195:</span><span class='ee-v'>B196</span></li><li><span class='ee-k'>196:</span><span class='ee-v'>B197</span></li><li><span class='ee-k'>197:</span><span class='ee-v'>B198</span></li><li><span class='ee-k'>198:</span><span class='ee-v'>B199</span></li><li><span class='ee-k'>199:</span><span class='ee-v'>B200</span></li><li><span class='ee-k'>200:</span><span class='ee-v'>B201</span></li><li><span class='ee-k'>201:</span><span class='ee-v'>B202</span></li><li><span class='ee-k'>202:</span><span class='ee-v'>B203</span></li><li><span class='ee-k'>203:</span><span class='ee-v'>B204</span></li><li><span class='ee-k'>204:</span><span class='ee-v'>B205</span></li><li><span class='ee-k'>205:</span><span class='ee-v'>B206</span></li><li><span class='ee-k'>206:</span><span class='ee-v'>B207</span></li><li><span class='ee-k'>207:</span><span class='ee-v'>B208</span></li><li><span class='ee-k'>208:</span><span class='ee-v'>B209</span></li><li><span class='ee-k'>209:</span><span class='ee-v'>B210</span></li><li><span class='ee-k'>210:</span><span class='ee-v'>B211</span></li><li><span class='ee-k'>211:</span><span class='ee-v'>B212</span></li><li><span class='ee-k'>212:</span><span class='ee-v'>B213</span></li><li><span class='ee-k'>213:</span><span class='ee-v'>B214</span></li><li><span class='ee-k'>214:</span><span class='ee-v'>B215</span></li><li><span class='ee-k'>215:</span><span class='ee-v'>B216</span></li><li><span class='ee-k'>216:</span><span class='ee-v'>B217</span></li><li><span class='ee-k'>217:</span><span class='ee-v'>B218</span></li><li><span class='ee-k'>218:</span><span class='ee-v'>B219</span></li><li><span class='ee-k'>219:</span><span class='ee-v'>B220</span></li><li><span class='ee-k'>220:</span><span class='ee-v'>B221</span></li><li><span class='ee-k'>221:</span><span class='ee-v'>B222</span></li><li><span class='ee-k'>222:</span><span class='ee-v'>B223</span></li><li><span class='ee-k'>223:</span><span class='ee-v'>B224</span></li><li><span class='ee-k'>224:</span><span class='ee-v'>B225</span></li><li><span class='ee-k'>225:</span><span class='ee-v'>B226</span></li><li><span class='ee-k'>226:</span><span class='ee-v'>B227</span></li><li><span class='ee-k'>227:</span><span class='ee-v'>B228</span></li><li><span class='ee-k'>228:</span><span class='ee-v'>B229</span></li><li><span class='ee-k'>229:</span><span class='ee-v'>B230</span></li><li><span class='ee-k'>230:</span><span class='ee-v'>B231</span></li><li><span class='ee-k'>231:</span><span class='ee-v'>B232</span></li><li><span class='ee-k'>232:</span><span class='ee-v'>B233</span></li><li><span class='ee-k'>233:</span><span class='ee-v'>B234</span></li><li><span class='ee-k'>234:</span><span class='ee-v'>B235</span></li><li><span class='ee-k'>235:</span><span class='ee-v'>B236</span></li><li><span class='ee-k'>236:</span><span class='ee-v'>B237</span></li><li><span class='ee-k'>237:</span><span class='ee-v'>B238</span></li><li><span class='ee-k'>238:</span><span class='ee-v'>B239</span></li><li><span class='ee-k'>239:</span><span class='ee-v'>B240</span></li><li><span class='ee-k'>240:</span><span class='ee-v'>B241</span></li><li><span class='ee-k'>241:</span><span class='ee-v'>B242</span></li><li><span class='ee-k'>242:</span><span class='ee-v'>B243</span></li><li><span class='ee-k'>243:</span><span class='ee-v'>B244</span></li><li><span class='ee-k'>244:</span><span class='ee-v'>B245</span></li><li><span class='ee-k'>245:</span><span class='ee-v'>B246</span></li><li><span class='ee-k'>246:</span><span class='ee-v'>B247</span></li><li><span class='ee-k'>247:</span><span class='ee-v'>B248</span></li><li><span class='ee-k'>248:</span><span class='ee-v'>B249</span></li><li><span class='ee-k'>249:</span><span class='ee-v'>B250</span></li><li><span class='ee-k'>250:</span><span class='ee-v'>B251</span></li><li><span class='ee-k'>251:</span><span class='ee-v'>B252</span></li><li><span class='ee-k'>252:</span><span class='ee-v'>B253</span></li><li><span class='ee-k'>253:</span><span class='ee-v'>B254</span></li><li><span class='ee-k'>254:</span><span class='ee-v'>B255</span></li><li><span class='ee-k'>255:</span><span class='ee-v'>B256</span></li><li><span class='ee-k'>256:</span><span class='ee-v'>B257</span></li><li><span class='ee-k'>257:</span><span class='ee-v'>B258</span></li><li><span class='ee-k'>258:</span><span class='ee-v'>B259</span></li><li><span class='ee-k'>259:</span><span class='ee-v'>B260</span></li><li><span class='ee-k'>260:</span><span class='ee-v'>B261</span></li><li><span class='ee-k'>261:</span><span class='ee-v'>B262</span></li><li><span class='ee-k'>262:</span><span class='ee-v'>B263</span></li><li><span class='ee-k'>263:</span><span class='ee-v'>B264</span></li><li><span class='ee-k'>264:</span><span class='ee-v'>B265</span></li><li><span class='ee-k'>265:</span><span class='ee-v'>B266</span></li><li><span class='ee-k'>266:</span><span class='ee-v'>B267</span></li><li><span class='ee-k'>267:</span><span class='ee-v'>B268</span></li><li><span class='ee-k'>268:</span><span class='ee-v'>B269</span></li><li><span class='ee-k'>269:</span><span class='ee-v'>B270</span></li><li><span class='ee-k'>270:</span><span class='ee-v'>B271</span></li><li><span class='ee-k'>271:</span><span class='ee-v'>B272</span></li><li><span class='ee-k'>272:</span><span class='ee-v'>B273</span></li><li><span class='ee-k'>273:</span><span class='ee-v'>B274</span></li><li><span class='ee-k'>274:</span><span class='ee-v'>B275</span></li><li><span class='ee-k'>275:</span><span class='ee-v'>B276</span></li><li><span class='ee-k'>276:</span><span class='ee-v'>B277</span></li><li><span class='ee-k'>277:</span><span class='ee-v'>B278</span></li><li><span class='ee-k'>278:</span><span class='ee-v'>B279</span></li><li><span class='ee-k'>279:</span><span class='ee-v'>B280</span></li><li><span class='ee-k'>280:</span><span class='ee-v'>B281</span></li><li><span class='ee-k'>281:</span><span class='ee-v'>B282</span></li><li><span class='ee-k'>282:</span><span class='ee-v'>B283</span></li><li><span class='ee-k'>283:</span><span class='ee-v'>B284</span></li><li><span class='ee-k'>284:</span><span class='ee-v'>B285</span></li><li><span class='ee-k'>285:</span><span class='ee-v'>B286</span></li><li><span class='ee-k'>286:</span><span class='ee-v'>B287</span></li><li><span class='ee-k'>287:</span><span class='ee-v'>B288</span></li><li><span class='ee-k'>288:</span><span class='ee-v'>B289</span></li><li><span class='ee-k'>289:</span><span class='ee-v'>B290</span></li><li><span class='ee-k'>290:</span><span class='ee-v'>B291</span></li><li><span class='ee-k'>291:</span><span class='ee-v'>B292</span></li><li><span class='ee-k'>292:</span><span class='ee-v'>B293</span></li><li><span class='ee-k'>293:</span><span class='ee-v'>B294</span></li><li><span class='ee-k'>294:</span><span class='ee-v'>B295</span></li><li><span class='ee-k'>295:</span><span class='ee-v'>B296</span></li><li><span class='ee-k'>296:</span><span class='ee-v'>B297</span></li><li><span class='ee-k'>297:</span><span class='ee-v'>B298</span></li><li><span class='ee-k'>298:</span><span class='ee-v'>B299</span></li><li><span class='ee-k'>299:</span><span class='ee-v'>B300</span></li><li><span class='ee-k'>300:</span><span class='ee-v'>B301</span></li><li><span class='ee-k'>301:</span><span class='ee-v'>B302</span></li><li><span class='ee-k'>302:</span><span class='ee-v'>B303</span></li><li><span class='ee-k'>303:</span><span class='ee-v'>B304</span></li><li><span class='ee-k'>304:</span><span class='ee-v'>B305</span></li><li><span class='ee-k'>305:</span><span class='ee-v'>B306</span></li><li><span class='ee-k'>306:</span><span class='ee-v'>B307</span></li><li><span class='ee-k'>307:</span><span class='ee-v'>B308</span></li><li><span class='ee-k'>308:</span><span class='ee-v'>B309</span></li><li><span class='ee-k'>309:</span><span class='ee-v'>B310</span></li><li><span class='ee-k'>310:</span><span class='ee-v'>B311</span></li><li><span class='ee-k'>311:</span><span class='ee-v'>B312</span></li><li><span class='ee-k'>312:</span><span class='ee-v'>B313</span></li><li><span class='ee-k'>313:</span><span class='ee-v'>B314</span></li><li><span class='ee-k'>314:</span><span class='ee-v'>B315</span></li><li><span class='ee-k'>315:</span><span class='ee-v'>B316</span></li><li><span class='ee-k'>316:</span><span class='ee-v'>B317</span></li><li><span class='ee-k'>317:</span><span class='ee-v'>B318</span></li><li><span class='ee-k'>318:</span><span class='ee-v'>B319</span></li><li><span class='ee-k'>319:</span><span class='ee-v'>B320</span></li><li><span class='ee-k'>320:</span><span class='ee-v'>B321</span></li><li><span class='ee-k'>321:</span><span class='ee-v'>B322</span></li><li><span class='ee-k'>322:</span><span class='ee-v'>B323</span></li><li><span class='ee-k'>323:</span><span class='ee-v'>B324</span></li><li><span class='ee-k'>324:</span><span class='ee-v'>B325</span></li><li><span class='ee-k'>325:</span><span class='ee-v'>B326</span></li><li><span class='ee-k'>326:</span><span class='ee-v'>B327</span></li><li><span class='ee-k'>327:</span><span class='ee-v'>B328</span></li><li><span class='ee-k'>328:</span><span class='ee-v'>B329</span></li><li><span class='ee-k'>329:</span><span class='ee-v'>B330</span></li><li><span class='ee-k'>330:</span><span class='ee-v'>B331</span></li><li><span class='ee-k'>331:</span><span class='ee-v'>B332</span></li><li><span class='ee-k'>332:</span><span class='ee-v'>B333</span></li><li><span class='ee-k'>333:</span><span class='ee-v'>B334</span></li><li><span class='ee-k'>334:</span><span class='ee-v'>B335</span></li><li><span class='ee-k'>335:</span><span class='ee-v'>B336</span></li><li><span class='ee-k'>336:</span><span class='ee-v'>B337</span></li><li><span class='ee-k'>337:</span><span class='ee-v'>B338</span></li><li><span class='ee-k'>338:</span><span class='ee-v'>B339</span></li><li><span class='ee-k'>339:</span><span class='ee-v'>B340</span></li><li><span class='ee-k'>340:</span><span class='ee-v'>B341</span></li><li><span class='ee-k'>341:</span><span class='ee-v'>B342</span></li><li><span class='ee-k'>342:</span><span class='ee-v'>B343</span></li><li><span class='ee-k'>343:</span><span class='ee-v'>B344</span></li><li><span class='ee-k'>344:</span><span class='ee-v'>B345</span></li><li><span class='ee-k'>345:</span><span class='ee-v'>B346</span></li><li><span class='ee-k'>346:</span><span class='ee-v'>B347</span></li><li><span class='ee-k'>347:</span><span class='ee-v'>B348</span></li><li><span class='ee-k'>348:</span><span class='ee-v'>B349</span></li><li><span class='ee-k'>349:</span><span class='ee-v'>B350</span></li><li><span class='ee-k'>350:</span><span class='ee-v'>B351</span></li><li><span class='ee-k'>351:</span><span class='ee-v'>B352</span></li><li><span class='ee-k'>352:</span><span class='ee-v'>B353</span></li><li><span class='ee-k'>353:</span><span class='ee-v'>B354</span></li><li><span class='ee-k'>354:</span><span class='ee-v'>B355</span></li><li><span class='ee-k'>355:</span><span class='ee-v'>B356</span></li><li><span class='ee-k'>356:</span><span class='ee-v'>B357</span></li><li><span class='ee-k'>357:</span><span class='ee-v'>B358</span></li><li><span class='ee-k'>358:</span><span class='ee-v'>B359</span></li><li><span class='ee-k'>359:</span><span class='ee-v'>B360</span></li><li><span class='ee-k'>360:</span><span class='ee-v'>B361</span></li><li><span class='ee-k'>361:</span><span class='ee-v'>B362</span></li><li><span class='ee-k'>362:</span><span class='ee-v'>B363</span></li><li><span class='ee-k'>363:</span><span class='ee-v'>B364</span></li><li><span class='ee-k'>364:</span><span class='ee-v'>B365</span></li><li><span class='ee-k'>365:</span><span class='ee-v'>B366</span></li><li><span class='ee-k'>366:</span><span class='ee-v'>B367</span></li><li><span class='ee-k'>367:</span><span class='ee-v'>B368</span></li><li><span class='ee-k'>368:</span><span class='ee-v'>B369</span></li><li><span class='ee-k'>369:</span><span class='ee-v'>B370</span></li><li><span class='ee-k'>370:</span><span class='ee-v'>B371</span></li><li><span class='ee-k'>371:</span><span class='ee-v'>B372</span></li><li><span class='ee-k'>372:</span><span class='ee-v'>B373</span></li><li><span class='ee-k'>373:</span><span class='ee-v'>B374</span></li><li><span class='ee-k'>374:</span><span class='ee-v'>B375</span></li><li><span class='ee-k'>375:</span><span class='ee-v'>B376</span></li><li><span class='ee-k'>376:</span><span class='ee-v'>B377</span></li><li><span class='ee-k'>377:</span><span class='ee-v'>B378</span></li><li><span class='ee-k'>378:</span><span class='ee-v'>B379</span></li><li><span class='ee-k'>379:</span><span class='ee-v'>B380</span></li><li><span class='ee-k'>380:</span><span class='ee-v'>B381</span></li><li><span class='ee-k'>381:</span><span class='ee-v'>B382</span></li><li><span class='ee-k'>382:</span><span class='ee-v'>B383</span></li><li><span class='ee-k'>383:</span><span class='ee-v'>B384</span></li><li><span class='ee-k'>384:</span><span class='ee-v'>B385</span></li><li><span class='ee-k'>385:</span><span class='ee-v'>B386</span></li><li><span class='ee-k'>386:</span><span class='ee-v'>B387</span></li><li><span class='ee-k'>387:</span><span class='ee-v'>B388</span></li><li><span class='ee-k'>388:</span><span class='ee-v'>B389</span></li><li><span class='ee-k'>389:</span><span class='ee-v'>B390</span></li><li><span class='ee-k'>390:</span><span class='ee-v'>B391</span></li><li><span class='ee-k'>391:</span><span class='ee-v'>B392</span></li><li><span class='ee-k'>392:</span><span class='ee-v'>B393</span></li><li><span class='ee-k'>393:</span><span class='ee-v'>B394</span></li><li><span class='ee-k'>394:</span><span class='ee-v'>B395</span></li><li><span class='ee-k'>395:</span><span class='ee-v'>B396</span></li><li><span class='ee-k'>396:</span><span class='ee-v'>B397</span></li><li><span class='ee-k'>397:</span><span class='ee-v'>B398</span></li><li><span class='ee-k'>398:</span><span class='ee-v'>B399</span></li><li><span class='ee-k'>399:</span><span class='ee-v'>B400</span></li><li><span class='ee-k'>400:</span><span class='ee-v'>B401</span></li><li><span class='ee-k'>401:</span><span class='ee-v'>B402</span></li><li><span class='ee-k'>402:</span><span class='ee-v'>B403</span></li><li><span class='ee-k'>403:</span><span class='ee-v'>B404</span></li><li><span class='ee-k'>404:</span><span class='ee-v'>B405</span></li><li><span class='ee-k'>405:</span><span class='ee-v'>B406</span></li><li><span class='ee-k'>406:</span><span class='ee-v'>B407</span></li><li><span class='ee-k'>407:</span><span class='ee-v'>B408</span></li><li><span class='ee-k'>408:</span><span class='ee-v'>B409</span></li><li><span class='ee-k'>409:</span><span class='ee-v'>B410</span></li><li><span class='ee-k'>410:</span><span class='ee-v'>B411</span></li><li><span class='ee-k'>411:</span><span class='ee-v'>B412</span></li><li><span class='ee-k'>412:</span><span class='ee-v'>B413</span></li><li><span class='ee-k'>413:</span><span class='ee-v'>B414</span></li><li><span class='ee-k'>414:</span><span class='ee-v'>B415</span></li><li><span class='ee-k'>415:</span><span class='ee-v'>B416</span></li><li><span class='ee-k'>416:</span><span class='ee-v'>B417</span></li><li><span class='ee-k'>417:</span><span class='ee-v'>B418</span></li><li><span class='ee-k'>418:</span><span class='ee-v'>B419</span></li><li><span class='ee-k'>419:</span><span class='ee-v'>B420</span></li><li><span class='ee-k'>420:</span><span class='ee-v'>B421</span></li><li><span class='ee-k'>421:</span><span class='ee-v'>B422</span></li><li><span class='ee-k'>422:</span><span class='ee-v'>B423</span></li><li><span class='ee-k'>423:</span><span class='ee-v'>B424</span></li><li><span class='ee-k'>424:</span><span class='ee-v'>B425</span></li><li><span class='ee-k'>425:</span><span class='ee-v'>B426</span></li><li><span class='ee-k'>426:</span><span class='ee-v'>Aerosol_Optical_Depth</span></li><li><span class='ee-k'>427:</span><span class='ee-v'>Aspect</span></li><li><span class='ee-k'>428:</span><span class='ee-v'>Cast_Shadow</span></li><li><span class='ee-k'>429:</span><span class='ee-v'>Dark_Dense_Vegetation_Classification</span></li><li><span class='ee-k'>430:</span><span class='ee-v'>Haze_Cloud_Water_Map</span></li><li><span class='ee-k'>431:</span><span class='ee-v'>Illumination_Factor</span></li><li><span class='ee-k'>432:</span><span class='ee-v'>Path_Length</span></li><li><span class='ee-k'>433:</span><span class='ee-v'>Sky_View_Factor</span></li><li><span class='ee-k'>434:</span><span class='ee-v'>Slope</span></li><li><span class='ee-k'>435:</span><span class='ee-v'>Smooth_Surface_Elevation</span></li><li><span class='ee-k'>436:</span><span class='ee-v'>Visibility_Index_Map</span></li><li><span class='ee-k'>437:</span><span class='ee-v'>Water_Vapor_Column</span></li><li><span class='ee-k'>438:</span><span class='ee-v'>to-sensor_Azimuth_Angle</span></li><li><span class='ee-k'>439:</span><span class='ee-v'>to-sensor_Zenith_Angle</span></li><li><span class='ee-k'>440:</span><span class='ee-v'>Weather_Quality_Indicator</span></li><li><span class='ee-k'>441:</span><span class='ee-v'>Acquisition_Date</span></li></ul></li><li><span class='ee-k'>system:id:</span><span class='ee-v'>projects/neon-prod-earthengine/assets/DP3-30006-001/2013_CPER_1_SDR</span></li><li><span class='ee-k'>system:index:</span><span class='ee-v'>2013_CPER_1_SDR</span></li><li><span class='ee-k'>system:time_end:</span><span class='ee-v'>2013-06-25 10:42:05</span></li><li><span class='ee-k'>system:time_start:</span><span class='ee-v'>2013-06-25 08:30:45</span></li><li><span class='ee-k'>system:version:</span><span class='ee-v'>1689911980211725</span></li></ul></li></ul></div><script>function toggleHeader() {
    const parent = this.parentElement;
    parent.className = parent.className === "ee-open" ? "ee-shut" : "ee-open";
}

for (let c of document.getElementsByClassName("ee-toggle")) {
    c.onclick = toggleHeader;
}</script></div>



```
AOP_VISIT_NUMBER:1
DESCRIPTION:Orthorectified surface directional reflectance (0-1 unitless, scaled by 10000) ...
FLIGHT_YEAR:2013
IMAGE_DATE:2013-06-25
NEON_DATA_PROD_ID:DP3.30006.001
NEON_DATA_PROD_URL:https://data.neonscience.org/data-products/DP3.30006.001
NEON_DOMAIN:D10
NEON_SITE:CPER
NOMINAL_SCALE:1
PRODUCT_TYPE:SDR
SCALING_FACTOR:10000
SENSOR_NAME:AVIRIS-NG
SENSOR_NUMBER:NIS1
WL_FWHM_B001:382.3465,5.8456
    
system:asset_size:68059.439009 MB
system:band_names: List (442 elements)
system:id:projects/neon-prod-earthengine/assets/DP3-30006-001/2013_CPER_1_SDR
system:index:2013_CPER_1_SDR
system:time_end:2013-06-25 10:42:05
system:time_start:2013-06-25 08:30:45
system:version:1689911980211725
```

The image properties contain some additional relevant information about the dataset, and are variables you can filter on to select a subset of the data. A lot of these properties are self-explanatory, but some of them may be less apparent. A short description of a few properties is outlined below. Note that when the datasets become part of the Google Public Datasets, you will be able to see descriptions of the properties in GEE.

- `SENSOR_NAME`: The name of the hyperspectral sensor. All NEON sensors are JPL AVIRIS-NG sensors.
- `SENSOR_NUMBER`: The payload number, NIS1 = NEON Imaging Spectrometer, Payload 1. NEON Operates 3 separate payloads, each with a unique hyperspectral sensor (as well as unique LiDAR and Camera sensors).
- `WL_FWHM_B###`: Center Wavelength (WL) and Full Width Half Max (FWHM) of the band, both in nm

In addition there are some `system` properties, including information about the size of the asset, the band names (most of these are just band numbers but the QA bands have more descriptive names), as well as the start and end time of the collection.

## Filter an Image Collection

One of the most useful aspects of having AOP data ingested in Earth Engine is the ability to filter by properties, such as the site name, dates, sensors, etc. In this next section, we will show how to filter datasets to extract only data of interest. We'll use the NEON's <a href="https://www.neonscience.org/field-sites/serc" target="_blank">Smithsonian Environmental Research Center (SERC)</a>, in Maryland.


```python
# See the years of data available for the specified site:
site = 'SERC'

# Get the flight year and site information
flightYears = rgbCol.aggregate_array('FLIGHT_YEAR').getInfo()
sites = rgbCol.aggregate_array('NEON_SITE').getInfo()

print('\nYears of RGB data available in GEE for',site+':')
print([year_site[0] for year_site in zip(flightYears,sites) if site in year_site])
```

    
    Years of RGB data available in GEE for SERC:
    [2017, 2021]
    


```python
# Get the flight year and site information
flightYears = sdrCol.aggregate_array('FLIGHT_YEAR').getInfo()
sites = sdrCol.aggregate_array('NEON_SITE').getInfo()

print('\nYears of SDR data available in GEE for',site+':')
print([year_site[0] for year_site in zip(flightYears,sites) if site in year_site])
```

    
    Years of SDR data available in GEE for SERC:
    [2017]
    


```python
# Specify the start and end dates
year = 2017
start_date = ee.Date.fromYMD(year, 1, 1) 
end_date = start_date.advance(1, "year")

# Filter the RGB image collection on the site and dates
SERC_RGB_2017 = rgbCol.filterDate(start_date, end_date).filterMetadata('NEON_SITE', 'equals', site).mosaic()
```

## Add Data Layers to the Map

In order to visualize and interact with the dataset, we can use `geemap.Map()` as follows:


```python
Map = geemap.Map()
Map
```

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/serc_map_layers.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/aop-gee-python/intro_aop_gee_py/serc_map_layers.png" alt="SERC Map Layers" width="600"><figcaption>Map Panel with SERC 2017 RGB and SDR Layers Added</figcaption></a>
</figure><br>


We'll start by reading in an RGB image over the Smithsonian Environmental Research Center (SERC) and adding the layer to the Map.


```python
# Specify center location of SERC: 38.890131, -76.560014
# NEON field site information can be found on the NEON website here > https://www.neonscience.org/field-sites/serc
geo = ee.Geometry.Point([-76.56, 38.89])

# Set the visualization parameters so contrast is maximized
rgb_vis_params = {'min': 0, 'max': 250, 'gamma': 0.8}

# Add the SERC RGB data as a layer to the Map
Map.addLayer(SERC_RGB_2017, rgb_vis_params, 'SERC 2017 RGB Camera');

# Center the map on SERC and set zoom level
Map.centerObject(geo, 12);
```

## Surface Directional Reflectance (SDR)

Next let's take a look at one of the SDR datasets. We will pull in only the data bands, for this example. 

### SDR Data Bands


```python
# Read in the first image of the SDR Image Collection
sdrImage = sdrCol.filterDate(start_date, end_date).filterMetadata('NEON_SITE', 'equals', site).mosaic()

# Read in only the data bands, all of which start with "B", eg. "B001"
sdrData = sdrImage.select('B.*')

# Set the visualization parameters so contrast is maximized, and display RGB bands (true-color image)
sdrVisParams = {'min':0, 'max':1200, 'gamma':0.9, 'bands':['B053','B035','B019']};

# Add the SERC RGB data as a layer to the Map
Map.addLayer(sdrData, sdrVisParams, 'SERC 2017 SDR');
```

### SDR QA Bands

Before we used a regular expression to pull out only the bands starting with "B". We can also take a look at the remaining bands using a similar expression, but this time excluding bands starting with "B". These comprise all of the QA-related bands that provide additional information and context about the data bands. This next chunk of code prints out the IDs of all the QA bands.


```python
# Read in only the QA bands, none of which start with "B"
sdrQA_bands = sdrImage.select('[^B].*')

# Create a dictionary of the band information
sdrQA_band_info = sdrQA_bands.getInfo()
type(sdrQA_band_info)

# Loop through the band info dictionary to print out the ID of each band
print('QA band IDs:\n')
for i in range(len(sdrQA_band_info['bands'])):
    print(sdrQA_band_info['bands'][i]['id'])
```

    QA band IDs:
    
    Aerosol_Optical_Depth
    Aspect
    Cast_Shadow
    Dark_Dense_Vegetation_Classification
    Haze_Cloud_Water_Map
    Illumination_Factor
    Path_Length
    Sky_View_Factor
    Slope
    Smooth_Surface_Elevation
    Visibility_Index_Map
    Water_Vapor_Column
    to-sensor_Azimuth_Angle
    to-sensor_Zenith_Angle
    Weather_Quality_Indicator
    Acquisition_Date
    

Most of these QA bands are related to the Atmospheric Correction (ATCOR), one of the processing steps in converting Radiance to Reflectance. For more details on this process, NEON provides an Algorithm Theoretical Basis Document (ATBD), which is available from the data portal. https://data.neonscience.org/api/v0/documents/NEON.DOC.001288vB?inline=true

Bands that may be most useful for standard analyses are the `Weather_Quality_Indicator` and `Acquisition_Date`. The weather quality indicator includes information about the cloud conditions during the flight, as reported by the flight operators, where 1 corresponds to <10% cloud cover, 2 corresponds to 10-50% cloud cover, and 3 corresponds to >50% cloud cover. We recommend using only clear-sky data for a typical analysis, as it comprises the highest quality reflectance data.

You may be interested in the acquisition date if, for example, you are linking field data collected on a specific date, or are interested in finding satellite data collected close in time to the AOP imagery.

The next chunks of code show how to add the Weather QA bands to the Map Layer.

### Weather Quality Indicator Band


```python
sdrWeatherQA = sdrCol.select(['Weather_Quality_Indicator']);

# Define a palette for the weather - to match NEON AOP's weather color conventions (green-yellow-red)
gyrPalette = ['00ff00', # green (<10% cloud cover)
              'ffff00', # yellow (10-50% cloud cover)
              'ff0000']; # red (>50% cloud cover)
             
# Visualization parameters to display the weather bands (cloud conditions) with the green-yellow-red palette
weatherVisParams = {'min': 1, 'max': 3, 'palette': gyrPalette, 'opacity': 0.3};

# Add the SERC RGB data as a layer to the Map
Map.addLayer(sdrWeatherQA, weatherVisParams, 'SERC 2017 Weather QA');
```

## Recap

In this lesson, you learned how to access the four NEON datasets that are available in GEE: Surface Directional Reflectance (SDR), Camera (RGB), and LiDAR-derived Digital Elevation (Terrain and Surface) Models (DTM and DSM) and Ecosystem Structure / Canopy Height Model (CHM). You practiced code to determine which datasets are available for a given Image Collection. You explored the image properties and learned how to filter on the metadata to pull out a subset of images from an Image Collection. You learned how to use `geemap` to add data layers to the interactive map panel. You learned how to select and visualize the Weather_Quality_Indicator band, which is a useful first step in working with any reflectance data. 

This is a great starting point for your own research!
