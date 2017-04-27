---
layout: post
title: "Install QGIS, HDF5 view"
description:
date: 2016-05-16
dateCreated: 2014-05-06
lastModified: 2016-05-18
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries:
categories: 
tutorialSeries: 
tags: 
mainTag:
code1:
image:
 feature: codedpoints2.png
 credit:
 creditlink:
permalink: /setup/setup-qgis-h5view
comments: true
---

{% include _toc.html %}


## Install QGIS
QGIS is a free, open-source GIS program. To install QGIS:

Download the QGIS installer on the
<a href="http://www.qgis.org/en/site/forusers/download.html" target="_blank">
QGIS download page here</a>. Follow the installation directions below for your
operating system.

### Windows

1. Select the appropriate **QGIS Standalone Installer Version** for your computer.
2. The download will automatically start.
3. Open the .exe file and follow prompts to install (installation may take a
while).
4. Open QGIS to ensure that it is properly downloaded and installed.

### Mac OS X

1. Select <a href="http://www.kyngchaos.com/software/qgis/" target="_blank">
KyngChaos QGIS download page</a>. This will take you to a new page.
2. Select the current version of QGIS. The file download (.dmg format) should
start automatically.
3. Once downloaded, run the .dmg file. When you run the .dmg, it will create a
directory of installer packages that you need to run in a particular order.
IMPORTANT: **read the READ ME BEFORE INSTALLING.rtf file**!

Install the packages in the directory in the order indicated.

1. GDAL Complete.pkg
2. NumPy.pkg
3. matplotlib.pkg
4. QGIS.pkg - **NOTE: you need to install GDAL, NumPy and matplotlib in order to
  successfully install QGIS on your Mac!**

<i class="fa fa-star"></i> **Data Tip:** If your computer doesn't allow you to
open these packages because they are from an unknown developer, right click on
the package and select Open With >Installer (default). You will then be asked
if you want to open the package. Select Open, and the installer will open.
{: .notice}

Once all of the packages are installed, open QGIS to ensure that it is properly
installed.

### LINUX

1. Select the appropriate download for your computer system.
2. Note: if you have previous versions of QGIS installed on your system, you may
run into problems. Check out
<a href="https://www.qgis.org/en/site/forusers/alldownloads.html" target="_blank">
this page from QGIS for additional information</a>.
3. Finally, open QGIS to ensure that it is properly downloaded and installed.



## Install HDFView
The free HDFView application allows you to explore the contents of an HDF5 file.

To install HDFView:

1. Click
<a href="https://www.hdfgroup.org/products/java/release/download.html" target="_blank"> to go to the download page</a>.

2. From the section titled **HDF-Java 2.1x Pre-Built Binary Distributions**
select the HDFView download option that matches the operating system and
computer setup (32 bit vs 64 bit) that you have. The download will start
automatically.

3. Open the downloaded file.
  + Mac - You may want to add the HDFView application to your Applications
directory.
  + Windows - Unzip the file, open the folder, run the .exe file, and follow
directions to complete installation.

4. Open HDFView to ensure that the program installed correctly.

<i class="fa fa-star"></i> **Data Tip:**
The HDFView application requires Java to be up to date. If you are having issues
opening HDFView, try to update Java first!
{: .notice}
