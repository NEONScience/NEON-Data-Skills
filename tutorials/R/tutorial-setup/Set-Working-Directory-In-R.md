---
syncID: 4ceab45849cd4a459da8f61d33906706
title: "Download a NEON Teaching Data Subset & Set A Working Directory In R"
description: "This tutorial explains how to set a working directory in R. The working directory points to a directory or folder on the computer where data that you wish to work with in R is stored."
dateCreated:  2015-12-07
authors: Megan A. Jones
contributors: Leah A. Wasser
estimatedTime: 
packagesLibraries:
topics: data-management
languagesTool:
dataProduct:
code1:
tutorialSeries:
---



This tutorial explains how to set a working directory in `R`. The working 
directory points to a directory or folder on the computer where data that you 
wish to work with in `R` is stored.

**R Skill Level:** Beginner

<div id="objectives" markdown="1">

## Objectives
After completing this tutorial, you will be able to:

* Be able to download and uncompress NEON Teaching Data Subsets. 
* Be able to set the `R` working directory.
* Know the difference between full, base and relative paths. 
* Be able to write out both full and relative paths for a given file or
 directory. 

## Things You’ll Need To Complete This Lesson
To complete this lesson you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### Download Data
{% include/dataSubsets/_data_Met-Time-Series.html %}
{% include/dataSubsets/_data_Site-Layout-Files.html %}

</div>

## NEON Data Skills Tutorials
Many NEON tutorials, available through the 
[NEON Data Skills portal](http://www.NEONdataskills.org "NEON Data Skills Portal"),
utilize teaching data subsets which are hosted on the NEON Data Skills 
fig**share** repository. If a data subset is required for a tutorial it can be 
downloaded at the top of each tutorial in the **Download Data** section. 

Prior to working with any data in `R`, we must set the **working directory** to
the location of the data files. Setting the working directory tells `R` where 
the data files are located on the computer. If the working directory is not 
correctly set first, when we try to open a file we will get an error telling us 
that `R` cannot find the file. 

<i class="fa fa-star"></i> **Data Tip:** All NEON Data Skills tutorials are
written assuming the working directory is the parent directory to the 
uncompressed .zip file of downloaded data.  This allows for multiple data 
subsets to be accessed in the tutorial without resetting the working directory. 
{: .notice}

* Wondering why we're saying **directory** instead of **folder**?  See our
discussion of 
<a href="{{ site.baseurl }}/R/Set-Working-Directory#directory-vs-folder"> Directory vs. Folder.</a>

## Download & Uncompress the Data

#### 1) Download
 First, we will download the data to a location on the computer. To download the 
data for this tutorial, click the blue button **Download NEON Teaching Data 
Subset: Meteorological Data for Harvard Forest** within the box at the 
top of this page. 

Note: In other NEON Data Skills tutorials, download all data subsets in the
**Download Data** section prior to starting the tutorial. Here, the second
data subset is for those wishing to practice these skills in a Challenge 
activity and will be downloaded at that time. 

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/download-data-screenshot.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/download-data-screenshot.png"></a>
	 <figcaption> Screenshot of the <b>Download Data </b> button at the top of 
	 NEON Data Skills tutorials. Source: National Ecological Observatory Network
	 (NEON) 
	 </figcaption>
</figure> 

After clicking on the **Download Data** button, the data will automatically 
download to the computer. 

#### 2) Locate .zip file
Second, we need to find the downloaded .zip file. Many browsers default to 
downloading to the **Downloads** directory on your computer. 
Note: You may have previously specified a specific directory (folder) for files
downloaded from the internet, if so, the .zip file will download there.

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/downloads_folder.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/downloads_folder.png"></a>
	 <figcaption> Screenshot of the computer's Downloads folder containing the
	 new <b>NEONDSMetTimeSeries.zip </b> file. Source: National Ecological
	 Observatory Network (NEON) 
	 </figcaption>
</figure> 

#### 3) Move to **data** directory
Third, we must move the data files to the location we want to work with them. 
We recommend moving the .zip to a dedicated **data** directory within the
**Documents** directory on your computer. This **data** directory can 
then be a repository for all data subsets you use for the NEON Data Skills 
tutorials. Note: If you chose  to store your data in a different directory 
(e.g., not in **~/Documents/data**), modify the directions below with the 
appropriate file path to your **data** directory. 

#### 4) Unzip/uncompress
Fourth, we need to unzip/uncompress the file so that the data files can be 
accessed. Use your favorite tool that can unpackage/open .zip files (e.g.,
winzip, Archive Utility, etc). The files will now be accessible in a directory 
named `NEON-DS-Met-Time-Series` containing all the subdirectories and files that
 make up the data set or the subdirectories and files will be unzipped directly 
into the data directory. If the latter happens, they need to be moved into a 
`data/NEON-DS-Met-Time-Series` directory.

* Want to make sure you have these steps down!  Try it with another file in this
<a href="{{ site.baseurl }}/R/Set-Working-Directory#challenge-download-and-unzip-teaching-data-subset"> Challenge activity on Downloading & Unzipping Data Subsets.</a>

The directory should be the same as in this screenshot (below). Note that 
`NEON-DS-Site-Lyout-Files` directory will only be in your directory if you 
completed the challenge above. If you did not, your directory should look the 
same but without that directory. 

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/neon-documents-contents.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/neon-documents-contents.png"></a>
	 <figcaption> Screenshot of the <b>neon</b> directory with the nested 
	 <b>Documents</b>, <b>data</b>, <b>NEON-DS-Met-Time-Series</b>, and other 
	 directories. Source: National Ecological Observatory Network
	 (NEON) 
	 </figcaption>
</figure> 


## The R Working Directory
In `R`, the working directory is the directory where `R` starts when looking for 
any file to open (as directed by a file path) and where it saves any output. 

Without a working directory all `R` scripts would need the full file path 
written any time we wanted to open or save a file. It is more efficient if we 
have a **base file path** set as our **working directory** and then all file 
paths written in our scripts only consist of the file path relative to that base
 path (a **relative path**). 

* If you are unfamiliar with the term **full path**, **base path**, or **relative
 path**, please see the section on
<a href="{{ site.baseurl }}/R/Set-Working-Directory#full-base-and-relative-paths"> Full, Base, and Relative Paths</a>
for a more detailed explanation before continuing with this tutorial.  

### Find a Full Path to a File in Unknown Location
If you are unsure of the path to a specific directory or file, you can
find this information for a particular file/directory of interest by looking in 
the:

* Windows: **Properties**, General tab (right click on the file/directory) or 
in the file path bar at the top of each window (select versions). 
* Mac OS X: **Get Info** (right clicking/control+click on the file/directory)

The file path may appear as: 

Computer > Users > neon > Documents > data > NEON-DS-Met-Time-Series

Copy and paste this information to automatically reformat into the full 
path to the directory or file: 

* Windows:  `C:\Users\neon\Documents\data\NEON-DS-Met-Time-Series`
* Mac OS X:  `/Users/neon/Documents/data/NEON-DS-Met-Time-Series`

<i class="fa fa-star"></i> **Data Tip:** File or directory paths and the home 
directory will appear slightly different in different operating systems. 
Linux will appear as
 `/home/neon/`. Windows will be similar to `C:\Documents and Settings\neon\` or
 `C:\Users\neon\`. The format varies by Windows version. Make special note of 
the direction of the slashes. Mac OS X and Unix format will appear as
 `/Users/neon/`. This tutorial will show Mac OSX output unless specifically
noted. 
{: .notice}

### Determine Current Working Directory
Once we are in the `R` program, we can view the current working directory
using the code `getwd()`. 

	# view current working directory 
	getwd()
	[1] "/Users/neon"

The working directory is currently set to the home directory `/Users/neon`. 
Remember, your current working directory will have a different user name and may
appear different based on operating system. 

This code can be used at any time to determine the current working directory. 

## Set the Working Directory
To set our current working directory to the location where our data are located,
we can either set the working directory in the `R` script or use our current GUI
to select the working directory.

<i class="fa fa-star"></i> **Data Tip:** All NEON Data Skills tutorials are
written assuming the working directory is the parent directory to the downloaded
data (the **data** directory in this tutorial). This allows for multiple data 
subsets to be accessed in the tutorial without resetting the working directory. 
{: .notice} 

We want to set our working directory to the **data** directory.

### Set the Working Directory: Base Path in Script
We can set the working directory using the code `setwd("PATH")` where PATH is 
the full path to the desired directory. 

Now, set your working directory to the directory where you have the data saved. 
There is no `R` output from `setwd()`. If we want to check that the working
directory is correctly set we can use `getwd()`.
 
#### Example Windows File Path
Notice the the backslashes used in Windows paths must be changed to slashes in
`R`. 

	# set the working directory to `data` folder
	setwd("C:/Users/neon/Documents/data")

	# check to ensure path is correct
	getwd()
	[1] "C:/Users/neon/Documents/data"

#### Example Mac OS X File Path
	# set the working directory to `data` folder
	setwd("/Users/neon/Documents/data")

	# check to ensure path is correct
	getwd()
	[1] "/Users/neon/Documents/data"

<i class="fa fa-star"></i> **Data Tip:** If using RStudio, you can view the 
contents of the working directory in the Files pane.
{: .notice}
 <figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/RStudio-working-directory.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/RStudio-working-directory.png"></a>
	 <figcaption> The Files pane in RStudio shows the contents of the current
	 working directory. Source: National Ecological Observatory Network
	 (NEON) 
	 </figcaption>
</figure> 
{: .notice}

### Set the Working Directory: Using RStudio GUI

1. Go to `Session` in menu bar,
2. select `Select Working Directory`,
3. select `Choose Directory`,
4. in the new window that appears, select the appropriate directory. 

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/RStudio-GUI-setWD.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/RStudio-GUI-setWD.png"></a>
	 <figcaption> How to set the working directory using the RStudio GUI.
	 Source: National Ecological Observatory Network (NEON) 
	 </figcaption>
</figure> 


### Set the Working Directory: Using R GUI

#### Windows Operating Systems: 

1. Go to the `File` menu bar,
2. select `Change dir...` or `Change Working Directory`,
3. in the new window that appears, select the appropriate directory.

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/Windows-RGUI-setWD.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/Windows-RGUI-setWD.png"></a>
	 <figcaption> How to set the working directory using the R GUI in Windows.
	 Source: National Ecological Observatory Network (NEON) 
	 </figcaption>
</figure> 

#### Mac Operating Systems:

1. Go to the `Misc` menu, 
2. select `Change Working Directory`,
3. in the new window that appears, select the appropriate directory.

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/Mac-RGUI-setWD.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/Mac-RGUI-setWD.png"></a>
	 <figcaption> How to set the working directory using the R GUI in Mac OS X. 
	 Source: National Ecological Observatory Network (NEON)  
	 </figcaption>
</figure> 


***

## Directory vs. Folder

"Directory" and "Folder" both refer to the same thing. Folder makes a lot of sense when we
think of an
isolated folder as a "bin" containing many files. However, the analogy to a
physical file folder falters when we start thinking about the relationship 
between different folders and how we tell a computer to find a specific folder. 
This is why the term directory is often preferred. Any directory (folder) can 
hold other directories and/or files. When we set the *working directory*, we 
are telling the computer the location of the directory (or folder) to start with
 when looking for other files or directories, or to save any output to. 

Return to the next section in the tutorial: 
<a href="{{ site.baseurl }}/R/Set-Working-Directory#download--uncompress-the-data"> Download & Uncompress The Data</a>

***

<div id="challenge" markdown="1">
## Challenge: Download and Unzip Teaching Data Subset
Prepare the **Site Layout Shapefiles Teaching Data Subset** so that the files
are accessible and ready to be opened in`R`. 
</div>

Return to the next section in the tutorial: 
<a href="{{ site.baseurl }}/R/Set-Working-Directory#the-r-working-directory"> The R Working Directory</a>

***

## Full, Base, and Relative Paths

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/neon-documents-contents.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/neon-documents-contents.png"></a>
	 <figcaption> Screenshot of the <b>neon</b> directory with the nested 
	 <b>Documents</b>, <b>data</b>, <b>NEON-DS-Met-Time-Series</b>, and other 
	 directories. Source: National Ecological Observatory Network
	 (NEON) 
	 </figcaption>
</figure> 

The data downloaded and unzipped in the previous steps are located within a 
nested set of directories: 
 
 * primary-level/home directory: **neon**
	+ This directory isn't obvious as we are within this directory once we log
	into the computer. 
	+ You will see your own user ID.
 * secondary-level directory:   **neon/Documents**
 * tertiary-level directory: 	**neon/Documents/data**
 * quaternary-level directory:  **neon/Documents/data/NEON-DS-Met-Time-Series**
 * quaternary-level directory:  **neon/Documents/data/NEON-DS-Site-Layout-Shapefiles** 

### Full & Base Path
The **full path** is essentially the complete "directions" for how to find the 
desired directory or file. It **always** starts with the home directory or root
(e.g., `/Users/neon/`). A full path is the **base path** when used to set 
the working directory to a specific directory. The base path for the
 `NEON-DS-Met-Time-Series` directory would be:

	 /Users/neon/Documents/data/NEON-DS-Met-Time-Series 

<i class="fa fa-star"></i> **Data Tip:** File or directory paths and the home 
directory will appear slightly different in different operating systems. 
Linux will appear as
 `/home/neon/`. Windows will be similar to `C:\Documents and Settings\neon\` or
 `C:\Users\neon\`. The format varies by Windows version. Make special note of 
the direction of the slashes. Mac OS X and Unix format will appear as
 `/Users/neon/`. This tutorial will show Mac OS X output unless specifically
noted. 
{: .notice}

<div id="challenge" markdown="1">
## Challenge: Full File Path
Write out the full path for the `NEON-DS-Site-Layout-Shapefiles` directory. Use
the format of the operating system you are currently using. 

Bonus: Write the path as for one of the other operating systems. 
</div>

### Relative Path
A relative path is a path to a directory or file that is starts from the
location determined by the working directory. If our working directory is set
to the **data** directory,

	 /Users/neon/Documents/data/

we can then create a relative path for all directories and files within the
**data** directory. 

<figure>
	 <a href="{{ site.baseurl }}/images/set-working-dir/data-folder-contents.png">
	 <img src="{{ site.baseurl }}/images/set-working-dir/data-folder-contents.png"></a>
	 <figcaption> Screenshot of the data directory containing the both NEON Data 
	 Skills Teaching Subsets. Source: National Ecological Observatory Network
	 (NEON) 
	 </figcaption>
</figure> 

The relative path for the `meanNDVI_HARV_2011.csv` file would be: 

	 NEON-DS-Met-Time-Series/HARV/NDVI/meanNDVI_HARV_2011.csv

<div id="challenge" markdown="1">
## Challenge: Relative File Path
Use the format of your current operating system:

1. Write out the **full path** to for the `Boundary-US-State-Mass.shp` file. 
2. Write out the **relative path** for the `Boundary-US-State-Mass.shp` file
assuming that the working directory is set to `/Users/neon/Documents/data/`. 

Bonus: Write the paths as for one of the other operating systems. 
</div>

Return to the next section in the tutorial: 
<a href="{{ site.baseurl }}/R/Set-Working-Directory#find-a-full-path-to-a-file-in-unknown-location"> Find a Full Path to a File in Unknown Location</a>

