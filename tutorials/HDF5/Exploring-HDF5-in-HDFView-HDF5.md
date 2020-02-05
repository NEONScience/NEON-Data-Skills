---
syncID: b2f77d03b14247438894b83bd7771c89
title: "HDFView: Exploring HDF5 Files in the Free HDFview Tool"
description: "Explore HDF5 files and the groups and datasets contained within, using the free HDFview tool. See how HDF5 files can be structured and explore metadata. Explore both spatial and temporal data stored in HDF5!"
dateCreated: 2014-11-19
authors: Leah A. Wasser
contributors:
estimatedTime: 0.25 - 0.5 Hours
packagesLibraries:
topics: HDF5
languagesTool: HDF5View
dataProduct:
code1:
tutorialSeries: [intro-hdf5-r-series]
urlTitle: explore-data-hdfview
---

In this tutorial you will use the free HDFView tool to explore HDF5 files and 
the groups and datasets contained within. You will also see how HDF5 files can 
be structured and explore metadata using both spatial and temporal data stored 
in HDF5!

<div id="ds-objectives" markdown="1">

## Learning Objectives

After completing this activity, you will be able to:

* Explain how data can be structured and stored in HDF5.
* Navigate to metadata in an HDF5 file, making it "self describing".
* Explore HDF5 files using the free HDFView application. 


## Tools You Will Need

Install the free HDFView application. This application allows you to explore 
the contents of an HDF5 file easily. 
<a href="https://www.hdfgroup.org/downloads/hdfview/" target="_blank">Click here to go to the download page. </a>

## Data to Download
NOTE: The first file downloaded has an .HDF5 file extension, the second file 
downloaded above has an .h5 extension. Both extensions represent the HDF5 data 
type.

{% include/dataSubsets/_data_Sample-Tower-Temp-H5.html %}
{% include/dataSubsets/_data_Imaging-Spec-Data-H5.html %}

</div>

### Installing HDFView

Select the HDFView download option that matches the operating system 
(Mac OS X, Windows, or Linux) and computer setup (32 bit vs 64 bit) that you have. 

This tutorial was written with graphics from the VS 2012 version, but it is 
applicable to other versions as well. 


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
<a href="/about-hdf5" target="_blank"> *About Hierarchical Data Formats - What is HDF5?* tutorial</a>.

In this tutorial, we will explore two different types of data saved in HDF5. 
This will allow us to better understand how one file can store multiple different 
types of data, in different ways.

### Part 1: Exploring Temperature Data in HDF5 Format in HDFView

The first thing that we will do is open an HDF5 file in the viewer to get a
 better idea of how HDF5 files can be structured.

#### Open a HDF5/H5 file in HDFView

To begin, open the HDFView application.
Within the HDFView application, select File --> Open and navigate to the folder 
where you saved the `fiuTestFile.hdf5` file on your computer. Open this file in 
HDFView.

If you **click on the name** of the HDF5 file in the left hand window of HDFView, 
you can view metadata for the file. This will be located in the bottom window of 
the application.

<figure>
    <a href="{{ site.baseurl }}/images/HDF5/OpenFIU.png">
    <img src="{{ site.baseurl }}/images/HDF5/OpenFIU.png"></a>
    <figcaption>If you click on the file name within the viewer, you can view 
    any stored metadata for that file, at the bottom of the viewer. You may have 
    to click on the metadata tab at the bottom of the viewer.</figcaption>
</figure>


#### Explore File Structure in HDFView

Next, explore the structure of this file. Notice that there are two Groups 
(represented as folder icons in the viewer) called "Domain_03" and "Domain_10". 
Within each domain group, there are site groups (NEON sites that are located within 
those domains). Expand these folders by double clicking on the folder icons. 
Double clicking expands the groups content just as you might expand a folder 
in Windows explorer.

Notice that there is metadata associated with each group.

Double click on the `OSBS` group located within the Domain_03 group. Notice in 
the metadata window that `OSBS` contains data collected from the 
<a href="/field-sites/field-sites-map/OSBS" target="_blank">NEON Ordway-Swisher Biological Station field site</a>.

Within the `OSBS` group there are two more groups - Min_1 and Min_30. What data 
are contained within these groups? 

Expand the "min_1" group within the OSBS site in Domain_03. Notice that there 
are five more nested groups named "Boom_1, 2, etc". A boom refers to an arm on a 
tower, which sits at a particular height and to which are attached sensors for 
collecting data on such variables as temperature, wind speed, precipitation, 
etc. In this case, we are working with data collected using temperature sensors, 
mounted on the tower booms.

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Note:** The data used in this activity were collected 
by a temperature sensor mounted on a National Ecological Observatory Network (NEON) flux tower. 
<a href="/data-collection/flux-tower-measurements" target="_blank"> Read more about NEON towers here. </a>
</div>

<figure>
    <a href="{{ site.baseurl }}/images/NEONtower.png">
    <img src="{{ site.baseurl }}/images/NEONtower.png"></a>
    <figcaption>A NEON flux tower contains booms or arms that house sensors at varying heights along the tower.</figcaption>
</figure>

Speaking of temperature - what type of sensor is collected the data within the 
boom_1 folder at the Ordway Swisher site? *HINT: check the metadata for that dataset.*


Expand the "Boom_1" folder by double clicking it. Finally, we have arrived at 
a dataset! Have a look at the metadata associated with the temperature dataset 
within the boom_1 group. Notice that there is metadata describing each attribute 
in the temperature dataset. 
Double click on the group name to open up the table in a tabular format. Notice 
that these data are temporal.

So this is one example of how an HDF5 file could be structured. This particular 
file contains data from multiple sites, collected from different sensors (mounted 
on different booms on the tower) and collected over time. Take some time to 
explore this HDF5 dataset within the HDFViewer. 


### Part 2: Exploring Hyperspectral Imagery stored in HDF5

<figure>
    <a href="{{ site.baseurl }}/images/aop_0.jpg"><img src="{{ site.baseurl }}/images/aop_0.jpg"></a>
    <figcaption>NEON airborne observation platform.</figcaption>
</figure>

Next, we will explore a hyperspectral dataset, collected by the 
<a href="/data-collection/airborne-remote-sensing" target="_blank">NEON Airborne Observation Platform (AOP)</a> 
and saved in HDF5 format. Hyperspectral 
data are naturally hierarchical, as each pixel in the dataset contains reflectance 
values for hundreds of bands collected by the sensor. The NEON sensor 
(imaging spectrometer) collected data within 428 bands.

A few notes about hyperspectral imagery:

* An imaging spectrometer, which collects hyperspectral imagery, records light 
energy reflected off objects on the earth's surface.
* The data are inherently spatial. Each "pixel" in the image is located spatially 
and represents an area of ground on the earth.
* Similar to an Red, Green, Blue (RGB) camera, an imaging spectrometer records 
reflected light energy. Each pixel will contain several hundred bands worth of 
reflectance data.

<figure>
    <a href="{{ site.baseurl }}/images/LandsatVsHyper-01.png">
    <img src="{{ site.baseurl }}/images/LandsatVsHyper-01.png"></a>
    <figcaption>A hyperspectral instruments records reflected light energy across 
    very narrow bands. The NEON Imaging Spectrometer collects 428 bands of 
    information for each pixel on the ground.</figcaption>
</figure>

Read more about hyperspectral remote sensing data:

* <a href="{{ site.baseurl }}/hyper-spec-intro" target="_blank"> *About Hyperspectral Remote Sensing Data* tutorial </a> on this site. 
* <a href="http://spacejournal.ohio.edu/pdf/shippert.pdf" target="_blank">White paper by Dr Peg Shippert</a>


Let's open some hyperspectral imagery stored in HDF5 format to see what the file 
structure can like for a different type of data.

Open the file. Notice that it is structured differently. This file is composed 
of 3 datasets: 

* Reflectance, 
* fwhm, and 
* wavelength. 

It also contains some text information called "map info". Finally it contains a 
group called spatial info.

Let's first look at the metadata stored in the **spatialinfo group**. This group 
contains all of the spatial information that a GIS program would need to project 
the data spatially.

Next, double click on the **wavelength dataset**. Note that this dataset contains 
the central wavelength value for each band in the dataset. 

Finally, click on the **reflectance dataset**. Note that in the metadata for the 
dataset that the structure of the dataset is 426 x 501 x 477 (wavelength, line, 
sample), as indicated in the metadata. Right click on the reflectance dataset 
and select **Open As**. Click Image in the "display as" settings on the left hand 
side of the popup. 

In this case, the image data are in the second and third dimensions of this 
dataset. However, HDFView will default to selecting the first and second dimensions 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Note:** HDF5 files use 0-based indexing. Therefore, 
the first dimension is called `dim 0` and the second is called `dim 1`. 
</div>

Let’s tell the HDFViewer to use the second and third dimensions to view the image: 

1.  Under `height`, make sure `dim 1` is selected.
1.  Under `width`, make sure `dim 2` is selected.  

Notice an image preview appears on the left of the pop-up window. Click OK to open 
the image. You may have to play with the brightness and contrast settings in the 
viewer to see the data properly. 

Explore the spectral dataset in the HDFViewer taking note of the metadata and 
data stored within the file.


