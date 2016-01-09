---
layout: post
title: "Setting A Working Directory In R"
date:   2015-12-07
lastModified: 2016-01-08
createddate:   2015-12-07
estimatedTime: 5 Min
authors: Megan A. Jones
packagesLibraries: []
categories: [self-paced-tutorial]
category: [self-paced-tutorial]
tags: [R, informatics]
mainTag: 
description: "This lesson explains how to set the Working Directory in R to a 
folder of downloaded data files. "
code1: Set-Working-Directory-In-R.R
image:
  feature: RBanner.png
  credit: National Ecological Observatory Network (NEON).
  creditlink: http://www.neoninc.org
permalink: /R/Set-Working-Directory/
comments: false
---

{% include _toc.html %}

##About
This lesson explains how to set the working directory in `R` to a folder of data
downloaded to a local folder.

**R Skill Level:** Beginner

<div id="objectives" markdown="1">

#Goals / Objectives
After completing this activity, you will:

 * Be able set the `R` Working Directory to a folder of downloaded data.

##Things You’ll Need To Complete This Lesson
To complete this lesson you will need the most current version of R, and 
preferably RStudio, loaded on your computer.

###Download Data (Optional)

{% include/dataSubsets/_data_Met-Time-Series.html %}

</div>

##NEON Data Skills Lessons
Most of the data skills lessons available through the
[NEON Data Skills portal](http://www.NEONdataskills.org  "NEON Data Skills Portal")
utilize one or more teaching datasets that are is available for download within
each lesson in the **Download** **Data** section.  These data 
subsets are hosted on the NEON Data Skills' Figshare site and are freely 
available.  Prior to being able to start the lesson we must set the `R` Working
Directory to the location of these downloaded files.  

##Download the Data
After clicking on the "Download Data" button, the data
(here **NEON-DS-Met-Time-Series.zip**) 
will automatically download.  The data files will be contained within a zipped
folder.  Unless you have set up your computer differently, these downloaded
files will be in your *Downloads* folder.  

While you can leave the data in the *Downloads* folder, many people prefer to
have a separate folder where all the data for specific projects is stored.  For
the purposes of this lesson we will say that we have a folder
**NEON-DS-Met-Time-Series**.  

Use a program already installed on your computer, or one of many free unzipping 
programs that can be readily downloaded, to unzip the folder.  

##Check Current Working Directory
The code `getwd()` can be typed into the `R` console at any point to determine
where the current Working Directory is set.  


    # you can check at any time the current working directory using: 
    # note that the output here is based on the computer originally used, your's
    # will be different. 
    getwd()

    ## [1] "/Users/NEON/Documents/data/"

##Set the Working Directory: Written Path

Pathways in the NEON Data Skills lessons will be written assuming the working
directory is the parent directory to the folder that was downloaded.

Therefore, we are going to be setting our Working Directory to the *data* folder
within our *Documents* folder.  

Pathways for different operating systems are slightly different.  For
explanation purposes we have a:
 
 * user named: NEON
 * initial folder: Documents
 * second folder: data
 * third folder: NEON-DS-Met-Time-Series

Our goal is to set the working directory to *data* so that all pathways with our
code can start with the *NEON-DS-Met-Time-Series* folder that was downloaded.  

###Windows

	setwd("C:/Users/NEON/Documents/data/")


###Mac
	setwd("/Users/NEON/Documents/data")

##Find the Working Directory Path
If you are unsure of the pathway you can find out by right clicking (Mac: 
control+click) on the file/folder of interest and select "Get Info". There 
location information will appear something like: 

Computer > Users > NEON > Documents > data > NEON-DS-Met-Time-Series

If you copy and paste that information it automatically turns into the path to
that folder: 

Windows:  
	C:/Users/NEON/Documents/data/NEON-DS-Met-Time-Series/

Mac:  
	/Users/NEON/Documents/data/NEON-DS-Met-Time-Series

##Set the Working Directory: Using RStudio GUI
Windows or Mac Operating System: go to Session, select Select Working Directory,
select Choose Directory, and select the appropriate folder/directory. 

##Set the Working Directory: Using R GUI
Windows Operating Systems: go to the `File` menu, select `Change Working
Directory`, and select the appropriate folder/directory.

Mac Operating Systems: go to the `Misc` menu, select `Change Working Directory`,
and select the appropriate folder/directory
