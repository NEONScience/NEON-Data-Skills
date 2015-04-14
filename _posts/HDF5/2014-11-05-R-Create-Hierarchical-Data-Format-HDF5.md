---
layout: post
title: "R: Creating HDF5 Files in the R"
date:   2015-1-29 15:22:52
dateCreated: 2014-11-18 20:49:52
lastModified: 2014-11-18 20:49:52
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: RHDF5
authors: Ted Hart, Leah Wasser - Adapted from Software Carpentry Materials by Leah A. Wasser
contributors: Elizabeth Webb
categories: [coding-and-informatics]
category: coding-and-informatics
tags: [HDF5,R]
mainTag: HDF5
description: "Create a HDF5 in R from scratch! Add groups and datasets. View the files in the HDFviewer."
code1: R_Create_Modify_Hdf5.R
image:
  feature: hierarchy_folder_purple.png
  credit: Colin Williams NEON, Inc.
  creditlink: http://www.neoninc.org
permalink: /HDF5/Create-HDF5-In-R/
comments: true
---

<section id="table-of-contents" class="toc">
  <header>
    <h3 >Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->

<div id="objectives">
<strong>R Skill Level: </strong> intermediate

<h3>Goals / Objectives</h3>
After completing this activity, you will:
<ol>
<li>Understand how HDF5 files can be created and structured in R using the rhfd libraries. </li>
<li>Understand the 3 key HDF5 elements: the HDF5 file itself and groups and datasets.</li>
</ol>

<h3>What You'll Need</h3>
<ul>
<li>R or R studio installed and the R HDF5 libraries.</li>
<li>Recommended Background: Consider reviewing the documentation for the <a href="http://www.bioconductor.org/packages/release/bioc/manuals/rhdf5/man/rhdf5.pdf" target="_blank">RHDF5 libraries</a></li>
</ul>
</div>

### A Brief Review - About HDF5
The HDF5 file can store large, heterogeneous datasets that include metadata. It also supports efficient `data slicing`, or extraction of particular subsets of a dataset which means that you don't have to read  large files read into the computers memory / RAM in their entirety in order work with them. This saves a lot of time when working with with HDF5 data in `R`. When HDF5 files contain spatial data, they can also be read directly into GIS programs such as `QGiS`.  

Remember that the HDF5 format is a self-contained directory structure. We can compare this structure to the folders and files located on your computer. However, in HDF5 files  "directories" are called `groups` and files are called `datasets`. The HDF5 element itself is a file. Each element in an HDF5 file can have metadata attached to it making HDF5 files "self-describing".

[Read more about HDF5 here.]({{ site.baseurl }}/HDF5/About/)

##HDF5 in R

To access HDF5 files in `R`, you need base <a href="http://www.hdfgroup.org/HDF5/release/obtain5.html#obtain" target="_blank">HDF5 libraries</a> installed on your computer. It might also be useful to install <a href="http://www.hdfgroup.org/products/java/hdfview/" target="_blank">the free HDF5 viewer</a> which will allow you to explore the contents of an HDF5 file visually using a graphic interface. [More about working with HDFview and a hands-on activity here]({{ site.baseurl }}/HDF5/Exploring-Data-HDFView/).

The package we'll be using is `rhdf5` which is part of the <a href="http://www.bioconductor.org" target="_blank">Bioconductor</a> suite of `R` packages. If you haven't installed this package before, you can use the first two lines of code below to install the package. Then use the library command to call the `library("rhdf5")` library.

	#install rhdf5 package
	source("http://bioconductor.org/biocLite.R")
	biocLite("rhdf5")
	library("rhdf5")

<a href="http://www.bioconductor.org/packages/release/bioc/vignettes/rhdf5/inst/doc/rhdf5.pdf" target="_blank">Read more about the `rhdf5` package here.</a>

## Create an HDF5 File in R

Let's start by outlining the structure of the file that we want to create.  We'll build a file called "sensorData.h5", that will hold data for a set of sensors at three different locations. Each sensor takes three replicates of two different measurements, every minute. 

HDF5 allows us to organize and store data in many ways. Therefore we need to decide what type of structure is ideally suited to our data before creating the HDF5 file. To structure the HDF5 file, we'll start at the file level. We will create a group for each sensor location. Within each location group, we will create two datasets containing temperature and precipitation data collected through time at each location.

So it will look something like this:

- HDF5 FILE (sensorData.H5)
	- Location_One (Group)
		- Temperature (Dataset)
		- Precipitation (Dataset)
	- Location_Two  (Group)
		- Temperature (Dataset)
		- Precipitation (Dataset)
	- Location_Three  (Group)
		- Temperature (Dataset)
		- Precipitation (Dataset)
   
Let's first create the HDF5 file and call it "sensorData.h5". Next, we will add a group for each location to the file. 

	#create hdf5 file
	h5createFile("sensorData.h5")
	#create group for location 1
	h5createGroup("sensorData.h5", "location1")

Remember from the discussion above that we want to create 3 location groups. The process of creating nested groups can be simplified with loops and nested loops. While the for loop below might seem excessive for adding three groups, it will become increasingly more efficient as we need to add more groups to our file. 

	#create loops that will populate 2 additional location "groups" in our HDF5 file
	l1 <- c("location2","location3")
	for(i in 1:length(l1)){
  	  h5createGroup("sensorData.h5", l1[i])
	}

Now let's view the structure of our HDF5 file. We'll use the `h5ls()` function to do this.

	# View HDF5 File Structure
	h5ls("sensorData.h5")

Our group structure that will contain location information is now set-up. However, it doesn't contain any data. Let's simulate some data pretending that each sensor took replicate measurements for 100 minutes. We'll add a 100 x 3 matrix that will be stored as a **dataset** in our HDF5 file. We'll populate this dataset with simulated data for each of our groups. We'll use loops to create these matrices and then paste them into each location group within the HDF5 file as datasets.

    # Add datasets to each group
    for(i in 1:3){
      g <- paste("location",i,sep="")
      #populate matrix with dummy data
      #create precip dataset within each location group
      h5write(matrix(rnorm(300,2,1),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"precip",sep="/"))
      #create temperature dataset within each location group
      h5write(matrix(rnorm(300,25,5),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"temp",sep="/"))
	}

### Understandig Complex Code 
Sometimes you may run into code that combines multiple functions into one line. It can be helpful to break the pieces of the code apart to understand their function. 

Let's start with `matrix(rnorm(300,2,1),ncol=3,nrow=100)`. This is telling R to create a matrix that has 3 columns and 100 rows. Do the following to figure out what it's doing.

1. Paste `(g,"temp",sep="/")` into the R console. What is the result?
2. Paste `rnorm(300,2,1)` into the console and see the result. 
3. Type `g` into the console and take note of the result.
2. Type help(norm) to understand what norm does. 

The `rnorm` function creates a set of random numbers that fall into a normal distribution. You specify the mean and standard deviation of the dataset and R does the rest. Notice in this loop we are creating a "precip" and a "temp" dataset and pasting them into each location group (the loop iterates 3 times).

The `h5write` function is writing each matrix to a dataset in our HDF5 file (sensorData.h5). It is looking for the following arguments: `hrwrite(dataset,YourHdfFileName,LocationOfDatasetInH5File)`. Therefore, the code: `(matrix(rnorm(300,2,1),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"precip",sep="/"))` tells R to add a random matrix of values to the sensorData HDF5 file within the path called `g`.  It also tells R to call the dataset within that group, "precip". 

### HDF5 File Structure
Next, let's check the file structure of the sensorData.h5 file. The `h5ls()` command tells us what each element in the file is, group or dataset. It also identifies the dimensions and types of data stored within the datasets in the HDF5 file. In this case, the  precipitation and temperature datasets are of type 'float' and of dimensions 100 x 3 (100 rows by 3 columns).


<i class="fa fa-star"></i> **Data Tip:** It's useful to learn about the different types of data that can be stored within R (and other objects). <a href="http://www.burns-stat.com/documents/tutorials/impatient-r/more-r-key-objects/more-r-numbers/#twonum" target="_blank">Learn more about float vs integer data here</a>
{: .notice}


	# List file structure
	h5ls("sensorData.h5")

### Data Types within HDF5
HDF5 files can hold mixed types of data. For example HDF5 files can store both strings and numbers in the same file. Each dataset in an HDF5 file can be its own type. For example a dataset can be composed of all integer values or it could be composed of all strings (characters). A group can contain a mix of string, and number based datasets.  However a dataset can also be mixed within the dataset containing a combination of numbers and strings. 

##Add Metdata to HDF5 Files

Some metadata can be added to an HDF5 file in R by creating attributes in R objects before adding them to the HDF5 file. Let's look at an example of how we do this. We'll add the units of our data as an attribute of the R matrix before adding it to the HDF5 file. Note that `write.attributes = TRUE` is needed when you write to the HDF5 file, in order to add metadata to the dataset.

	# Create matrix of "dummy" data
	p1 <- matrix(rnorm(300,2,1),ncol=3,nrow=100)
	# Add attribute to the matrix (units)
	attr(p1,"units") <- "millimeters"
	
	# Write the R matrix to the HDF5 file 
	h5write(p1,file = "sensorData.h5","location1/precip",write.attributes=T)


## Reading Data from an HDF5 File
We just learned how to create an HDF5 file and write information to the file. We use a different set of functions to read data from an HDF5 file. If `read.attributes` is set to `TRUE` when we read the data, then we can also see the metadata for the matrix. Furthermore, we can chose to read in a subset, like the first 10 rows of data, rather than loading the entire dataset into R.
 
	# Read in all data contained in the precipitation dataset 
	l1p1 <- h5read("sensorData.h5","location1/precip",read.attributes=T)

	# Read in first 10 lines of the data contained within the precipitation dataset 
	l1p1s <- h5read("sensorData.h5","location1/precip",read.attributes = T,index = list(1:10,NULL))


###Extra Credit If you get done early...###

* Think about an application for HDF5 that you might have. Create a new HDF5 File that would support the data that you need to store. 
*  Open the sensordata.H5 file in the HDFviewer.



