---
syncID: b2f77d03b14247438894b83bd7771c89
title: "HDFView: Exploring HDF5 Files in the Free HDFview Tool"
description: "Explore HDF5 files and the groups and datasets contained within, using the free HDFview tool. See how HDF5 files can be structured and explore metadata. Explore both spatial and temporal data stored in HDF5!"
dateCreated: 2014-11-19
authors: Leah A. Wasser
contributors: Alison Dernbach, Bridget Hass
estimatedTime: 0.5 Hours
packagesLibraries:
topics: HDF5
languagesTool: HDFView
dataProduct: DP3.30006.001, DP3.30006.002
code1:
tutorialSeries: intro-hdf5-r-series
urlTitle: explore-data-hdfview
---

In this tutorial you will use the free HDFView tool to explore HDF5 files and 
the groups and datasets contained within. You will also see how HDF5 files can 
be structured and explore metadata using both spatial and temporal data stored 
in HDF5!

<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this activity, you will be able to:

* Explain how data can be structured and stored in HDF5 format.
* Navigate to metadata in an HDF5 file, making it "self describing".
* Explore HDF5 files using the free HDFView application. 


## Tools You Will Need

Install the free HDFView application. This application allows you to explore the contents of an HDF5 file easily. 
<a href="https://www.hdfgroup.org/downloads/hdfview/" target="_blank">Click here to go to the download page.</a>

## Data to Download

<h3><a href="https://storage.googleapis.com/neon-aop-provisional-products/2024/FullSite/D17/2024_SJER_7/L3/Spectrometer/Reflectance/NEON_D17_SJER_DP3_254000_4108000_bidirectional_reflectance.h5">
Download NEON Imaging Spectrometer Data at SJER (2024) - NEON_D17_SJER_DP3_254000_4108000_bidirectional_reflectance.h5</a></h3>

These hyperspectral remote sensing data provide information on the
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map/SJER" target="_blank" > San Joaquin Exerimental Range field site.</a>
The data were collected over the San Joaquin field site located in California 
(Domain 17) and processed at NEON headquarters. The entire dataset can be accessed from the 
<a href="https://data.neonscience.org/data-products/DP3.30006.002" target="_blank">Spectrometer orthorectified surface bidirectional reflectance - mosaic</a> page on the NEON data portal.

<a href="https://storage.googleapis.com/neon-aop-provisional-products/2024/FullSite/D17/2024_SJER_7/L3/Spectrometer/Reflectance/NEON_D17_SJER_DP3_254000_4108000_bidirectional_reflectance.h5" class="link--button link--arrow">Download Reflectance Dataset</a>

<h3><a href="https://storage.googleapis.com/neon-sae-files/ods/dataproducts/DP4/2024-04-01/SJER/NEON.D17.SJER.DP4.00200.001.nsae.2024-04.basic.20260115T154231Z.h5">Download NEON Eddy Covariance Data at SJER (2024-04-01)</a></h3>

The SAE data were collected by the
<a href="https://www.neonscience.org/" target="_blank"> National Ecological Observatory Network's</a> 
<a href="https://www.neonscience.org/field-sites/field-sites-map" target="_blank">flux towers at field sites across the US</a>.
The entire dataset can be accessed from the 
<a href="https://data.neonscience.org/data-products/DP4.00200.001" target="_blank">Bundled data products - eddy covariance</a> page on the NEON data portal.

<a href="https://storage.googleapis.com/neon-sae-files/ods/dataproducts/DP4/2024-04-01/SJER/NEON.D17.SJER.DP4.00200.001.nsae.2024-04.basic.20260115T154231Z.h5" class="link--button link--arrow">
Download Eddy Covariance Dataset</a>



</div>

### Installing HDFView

Select the HDFView download option that matches the operating system 
(Mac OS X, Windows, or Linux) and computer setup (32 bit vs 64 bit) that you have. 


## Hierarchical Data Format 5 - HDF5

Hierarchical Data Format version 5 (HDF5), is an open file format that supports 
large, complex, heterogeneous data. Some key points about HDF5:

* HDF5 uses a "file directory" like structure. 
* The HDF5 data models organizes information using `Groups`. Each group may contain one or more `datasets`.
* HDF5 is a self describing file format. This means that the metadata for the 
data contained within the HDF5 file, are built into the file itself.
* One HDF5 file may contain several heterogeneous data types (e.g. images, 
numeric data, data stored as strings). 

For more introduction to the HDF5 format, see our 
<a href="https://www.neonscience.org/about-hdf5" target="_blank"> *About Hierarchical Data Formats - What is HDF5?* tutorial</a>.

In this tutorial, we will explore two different types of data saved in HDF5. 
This will allow us to better understand how one file can store multiple different 
types of data, in different ways.


### Part 1: Exploring Hyperspectral Imagery stored in HDF5

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/neon-aop/aop_siteillustration.jpg"><img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/neon-aop/aop_siteillustration.jpg" alt="Illustration of a NEON site with field scientists on the ground and an airborne observation plane flying above"></a>
    <figcaption>NEON airborne observation platform.</figcaption>
</figure>

First, we will explore a hyperspectral dataset, collected by the 
<a href="https://www.neonscience.org/data-collection/airborne-remote-sensing" target="_blank">NEON Airborne Observation Platform (AOP)</a> 
and saved in HDF5 format. In the hyperpsectral data cubes, each pixel in the dataset contains reflectance values for hundreds of bands (426) collected by the sensor.

A few notes about hyperspectral imagery:

* An imaging spectrometer, which collects hyperspectral imagery, records light energy reflected off objects on the earth's surface.
* The data are inherently spatial. Each pixel in the image is located spatially and represents an area of ground on the earth.
* Similar to an RGB (Red, Green, Blue) camera, an imaging spectrometer records reflected light energy. Each pixel contain several hundred bands of reflectance data.

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-general/LandsatVsHyper-01.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/hyperspectral-general/LandsatVsHyper-01.png" alt="A hyperspectral resolution graph and a landsat TM resolution graph each showing different reflectance values across wavelengths for five differnt plants"></a>
    <figcaption>A hyperspectral instrument records reflected light energy across very narrow bands. The NEON Imaging Spectrometer collects 426 bands of information for each pixel on the ground.</figcaption>
</figure>

Read more about hyperspectral remote sensing data:

* <a href="https://www.neonscience.org/hyper-spec-intro" target="_blank"> *About Hyperspectral Remote Sensing Data* tutorial </a> on this site. 


Let's open some hyperspectral imagery stored in HDF5 format to see what the file 
structure can like for a different type of data.

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/HDF5-general/hdfview_SJER_Refl002.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/HDF5-general/hdfview_SJER_Refl002.png" alt="SJER bidirectional reflectance tile (DP3.30006.002 opened in HDFView)"></a>
    <figcaption>HDFView for a bidirectional reflectance hdf5 file for SJER</figcaption>
</figure>

#### Open the Reflectance H5 file in HDFView

To begin, open the HDFView application.

Within the HDFView application, select File --> Open and navigate to the folder 
where you saved the `NEON_D17_SJER_DP3_254000_4108000_bidirectional_reflectance.h5` file on your computer. Open this file in HDFView.

Open the file and expand the sub-folders. This file is composed of a Reflectance dataset (called `Reflectance_Data`) along with additional Metadata containing the following sub-folders:

* `Ancillary_Imagery`: Datasets including ATCOR inputs and other Quality indicators such as the `Weather_Quality_Indicator`, containing information about the cloud conditions during the flight (for each pixel).
* `Coordinate_System`: geographic information for the dataset.
* `Logs`: Log files for each flight line containing ATCOR processing information and inputs, BRDF correction parameters, and the solar azimuth and zenith angles.
* `Spectral_Data`: Full Width Half Max (FWHM) and Wavelength for each of the 426 spectral bands. 

Let's first look at the metadata stored in the **Coordinate_System** folder. This group 
contains all of the spatial information that a GIS program would need to project 
the data spatially.

Next, double click on the **Wavelength** dataset. Note that this dataset contains 
the central wavelength value for each band in the dataset. 

Finally, click on the **Reflectance_Data** dataset. Note that in the metadata for the 
dataset that the structure of the dataset is 426 x 1000 x 1000 (wavelength, x, 
y), as indicated in the metadata. Right click on the reflectance dataset 
and select **Open As**. Click Image in the "display as" settings on the left hand 
side of the popup. 

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/HDF5-general/hdfview_SJER_Refl002_Dataset_Selection.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/HDF5-general/hdfview_SJER_Refl002_Dataset_Selection.png" alt="SJER bidirectional reflectance tile Dataset Selection"></a>
    <figcaption>HDFView Reflectance Dataset Selection</figcaption>
</figure>

Notice an image preview appears on the left of the pop-up window. Click OK to open 
the image. You may have to play with the brightness and contrast settings in the 
viewer to see the data properly. 

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/HDF5-general/hdfview_SJER_Reflectance_Preview.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/HDF5-general/hdfview_SJER_Reflectance_Preview.png" alt="SJER bidirectional reflectance greyscale preview"></a>
    <figcaption>HDFView Reflectance Preview</figcaption>
</figure>

Explore the spectral dataset in the HDFViewer taking note of the metadata and data stored within the file.

### Part 2: Exploring Surface Atmosphere Exchange (SAE) Data in HDFView

Next, we will look at the SAE bundled eddy covariance h5 data. As in the first part, we will start by opening the h5 file (download from the link at the top of this tutorial) in the viewer to get a better idea of how this data is structured.

#### Open the Bundled Eddy Covariance H5 file in HDFView

Open the HDFView application. Within the application, select **File --> Open** and navigate to the folder 
where you saved the SAE hdf5 file on your computer. Open this file in HDFView.

If you **click on the name** of the HDF5 file in the left hand window of HDFView, 
you can view metadata for the file. This will be located in the bottom window of 
the application.

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/HDF5-general/hdfview_SJER_SAE.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/HDF5-general/hdfview_SJER_SAE.png" alt="SJER Eddy Covariance HDF5 File"></a>
    <figcaption>HDFView Reflectance Dataset Selection</figcaption>
</figure>

#### Explore File Structure in HDFView

Next, explore the structure of this bundled eddy covariane file. 

Notice at the bottom there is a `readMe` attribute. If you double click on this, you'll see the text "Net Surface Atmosphere Exchange (NSAE) HDF5 File Structure Description. The NSAE file you downloaded from NEON data portal is in the HDF5 format. This document describes the HDF5 file structure. This file will provide the HDF5 hierarchical layout of the file and a description of each HDF5 group level. The full descriptions of objects can be found in the objDesc data table provided within the HDF5 file. The 'Exploring NEON Eddy-Covariance Data Products in HDF5 file format' document provides a greater level of detail ..."

Documentation for each NEON data product is contained on the respective data product page. It is strongly recommended to peruse the relevant documentation, starting with the Quick Start Guides. The document referenced above in the readMe is linked here: <a href="https://data.neonscience.org/api/v0/documents/NEON_how_to_view_hdf5_vA?inline=true" target="_blank">Exploring NEON Eddy-Covariance Data Products in HDF5 file format</a> .

Now that you've read the readMe, and referencing the document above, take a look at the structure of the data in HDFView.

Notice that there are multiple groups (folders) under the `SJER` root folder starting with `dp`. Expand these folders by double clicking on the folder icons. These represent the different data product levels, from 01 to 04, and

* `dp01`: Level 1
* `dp02`: Level 2
* `dp03`: Level 3
* `dp04`: Level 4
* `dp0p`: Level 0 prime

Under each of the levels there is a data folder with subfolders labeled by the data product identification codes as well as quality information (`qfqm`) and uncertainty (`ucrt`). 

Notice that there is also metadata associated with each group.

Within the `dp04/data` group there are five more groups: `fluxCo2`, `fluxH2o`, `fluxMome`, `fluxTemp`, and `foot`. What data are contained within these groups? 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Note:** The data used in this activity were collected by sensors mounted on a National Ecological Observatory Network (NEON) flux tower. 
<a href="https://www.neonscience.org/data-collection/meteorology" target="_blank">Read more about NEON towers here.</a>
</div>

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/NEON-general/NEONtower.png">
    <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/NEON-general/NEONtower.png" alt="Illustration of a NEON tower with arms containing sensors extending horizontally off of the tower structure" style="width: 70%;"></a>
    <figcaption>A NEON flux tower contains booms or arms that house sensors at varying heights along the tower.</figcaption>
</figure>

So this is another example of how a NEON HDF5 file is structured. Take some time to explore this HDF5 dataset within the HDFViewer, using the reference document as needed.