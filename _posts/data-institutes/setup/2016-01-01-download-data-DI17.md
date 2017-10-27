---
layout: post
title: "Download the Data"
description: "This tutorial covers the data and set up the data directory you 
will need for the 2017 Institute on Remote Sensing."
date: 2017-05-17
dateCreated: 2017-06-09
lastModified: 2017-06-09
estimatedTime: 
packagesLibraries:
authors: 
contributors:
categories: [self-paced-tutorial]
tutorialSeries: 
mainTag: 
code1: 
image:
 feature: data-institute-rs.png
 credit:
 creditlink:
permalink: /setup/download-data-DI17
comments: true
---


{% include _toc.html %}

## NEON AOP Data 

Currently the NEON AOP data is distributed through a Citrix account. When data 
is requested, users are given their own account through which they can access the
data. For the Data Institute, we've created a single download that contains the
files needed for the tutorials during the Institute. 

We recommend downloading the complete Data Institute 2017 teaching data subsets 
from the button in the instructions below (direct download from Citrix). 


## Download & Uncompress the Data

#### 1) Download
First, we will download the data to a location on the computer. To download the 
data for this tutorial, click the blue button **Download NEON Teaching Data 
Subset: Data Institute 2017**. 

Caution: This file set includes hyperspectral and lidar data sets and is therefore
a large file (12 GB).  Ensure that you have sufficient space on your hard drive 
before you begin the download.  If not, download to an external hard drive and 
make sure to correct for the change in file path when working through the scripts.

<div id="objectives" markdown="1">


### Download Data

 <a href="https://neondata.sharefile.com/d-sf1eb1e9c5174760a" class="btn btn-success">
Download NEON Teaching Data Subset: Data Institute 2017</a>

 <a href="https://ndownloader.figshare.com/files/8730436" class="btn btn-success">
Download NEON Teaching Data Subset: Data Institute 2017 - Spectral Classification</a>

</div>

After clicking on the **Download Data** button, the data will automatically 
download to the computer. This is a large file so it might take a while to 
download. 

#### 2) Locate .zip file
Second, we need to find the downloaded .zip file. Many browsers default to 
downloading to the **Downloads** directory on your computer. 
Note: You may have previously specified a specific directory (folder) for files
downloaded from the internet, if so, the .zip file will download there. 

<figure>
	 <a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute0-setup/DI16-Download_AllSets.png">
	 <img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute0-setup/DI16-Download_AllSets.png"></a>
	 <figcaption> Screenshot of the computer's Downloads folder containing the
	 newly downloaded file. Source: National Ecological
	 Observatory Network (NEON) 
	 </figcaption>
</figure> 

#### 3) Move to **RSDI-2017** directory
Third, we must move the data files to the location we want to work with them. 
We recommend moving the .zip to create a dedicated subdirectory within a 
**data** directory in the **Documents** directory on your computer 
(**~/Documents/data/RSDI-2017**). This **RSDI-2017** directory can then be a repository for all data subsets you use 
for the NEON Data Institute tutorials. 

Note: If you chose to store your data in 
a different directory (e.g., not in **~/Documents/data/RSDI-2017**), modify 
the directions below with the appropriate file path to your **RSDI-2017** 
directory. 

#### 4) Unzip/uncompress
Fourth, we need to unzip/uncompress the file so that the data files can be 
accessed. Use your favorite tool that can unpackage/open .zip files (e.g.,
winzip, Archive Utility, etc). Depending on the tool you use to uncompress the files,
you may need to individually uncompress the individual files within the main file. 


#### 5) Combine the Subsets
Fifth, we need to put all three data subsets within a single directory structure. 
The directory should be the same as in this screenshot (below). 

<figure>
	 <a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute0-setup/AllSets_FileStructureScreenShot.png">
	 <img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute0-setup/AllSets_FileStructureScreenShot.png"></a>
	 <figcaption> Screenshot of the <b></b> directory structure: nested 
	 <b>Documents</b>, <b>data</b>, <b>RSDI-2017</b>, and other 
	 directories.(Note: this figure indicates the 2016 data not the 2017 data). Source: National Ecological Observatory Network
	 (NEON) 
	 </figcaption>
</figure> 

Due to difference in the tools used to uncompress the zipped files, the name of 
the directory you initially see once unzipping is complete may differ. 

You will now have all the teaching data subsets that will be used in the NEON
Data Institute 2017. 
