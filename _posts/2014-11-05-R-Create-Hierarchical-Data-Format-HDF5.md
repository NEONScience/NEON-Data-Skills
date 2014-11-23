---
layout: post
title: "R: Creating HDF5 Files"
date:   2014-11-18 20:49:52
authors: Ted Hart - Adapted from Software Carpentry Materials by Leah A. Wasser
categories: [coding-and-informatics]
tags : [HDF5,R]
description: "Create a HDF5 in R from scratch! Add groups and datasets. View the files in the HDFviewer."
code1: R_Create_Modify_Hdf5.R
image:
  feature: hierarchy_folder_purple.png
  credit: The Artistry of Colin Williams, NEON
  creditlink: http://www.neoninc.org
permalink: /HDF5/Create-HDF5-In-R/
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

**R Skill Level:** intermediate

##Objectives
After completing this activity, you will:

1. Understand how HDF5 files can be created and organized in R supporting increased understanding of the file format and it's potential to store large, heterogeneous file formats. 
2. Understand the basics of manipulating big data sets using indexing, loops, and `dplyr`.
3. Understand the 3 key HDF5 data types: **file**, **groups** and **datasets**.
3. Be exposed to and learn how to apply a variety of data manipulation tasks including identifying data types given a new dataset, string parsing, and working with / formatting date information.

###Overview
The HDF5 file can store large, heterogeneous data sets that include self-describing metadata. It supports compression and parallel I/O. It also supports efficient data slicing, or extraction of particular parts of a dataset; thus, if you don't have to read large files   read into the computers memory / RAM to work with them - a real benefit to languages like `R`. HDF5 also is supporting in many programming languages including `R` and `Python`. When HDF5 files contain spatial data, they can also be read directly into GIS programs such as `QGiS`.  

To be able to access HDF5 files, you'll need to first install the base [HDF5 libraries](http://www.hdfgroup.org/HDF5/release/obtain5.html#obtain). It might also be useful to install [HDFview](http://www.hdfgroup.org/products/java/hdfview/) which will allow you to explore the contents of an HDF5 file visually using a graphic interface. 

The package we'll be using is `rhdf5` which is part of the [Bioconductor](http://www.bioconductor.org) suite of `R` packages. If you haven't installed this package before, you can use the first two lines of code below to install. Then use the library command to call the `rhdf5` library.

	#source("http://bioconductor.org/biocLite.R")
	#biocLite("rhdf5")
	library("rhdf5")

###HDF5 Quick Review
The HDF5 format is a self-contained directory structure. In HDF5 files though "directories" are called "**groups**" and "**files**" are called "datasets". Each element in an hdf5 file can have metadata attached to it making HDF5 files "self-describing".


## Let's Create a File

Let's start by outlining the structure for the file we want to create.  We'll build a file called "sensorData.h5", which will hold data for a set of sensors at three different locations. Each sensor takes three replicates of two different measurements every minute. 

HDF5 allows us to organize and store data in many ways. Therefore we need to decide what type of structure is ideally suited to our data before creating the HDF5 file. To structure the HDF5 file, we'll start at the file level. We will create a group for each sensor location. Within that group, we will create another group, which is sensor type, and then a matrix of time x replicate within that group.

So it will look something like this:

- HDF5 FILE 
	- Location_One (Group)
		- Sensor Type (Group)
			- Actual Data (Dataset)
	- Location_Two  (Group)
		- Sensor Type (Group)
			- Actual Data (Dataset)
	- Location_Three  (Group)
		- Sensor Type (Group)
			- Actual Data (Dataset)
   
So let's create the file and call it "sensorData.h5" and then add our groups. 

	#create hdf5 file
	h5createFile("sensorData.h5")
	h5createGroup("sensorData.h5", "location1")

The process of creating nested groups can be simplified with loops and nested loops.

	#create loops that will populate 2 additional location "groups" in our HDF5 file
	l1 <- c("location2","location3")
	for(i in 1:length(l1)){
  	  h5createGroup("sensorData.h5", l1[i])
	}

Now let's view the structure of our HDF5 file. We'll use the `h5ls()` function to do this.

	#r view HDF5 File Structure
	h5ls("sensorData.h5")

Our group structure that will contain location information is now set-up. However, it doesn't contain any data. Let's simulate some data pretending that each sensor took replicate measurements for 100 minutes. We'll add a 100 x 3 matrix that will be stored as a **dataset** in our HDF5 file. We'll populate this dataset with simulated data for each of our groups. We'll use loops to create these matrices and then paste them into the hdf5 file as datasets.

	#r add data
	for(i in 1:3){
      g <- paste("location",i,sep="")
  	
    h5write(matrix(rgamma(300,2,1),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"precip",sep="/"))
    h5write(matrix(rnorm(300,25,5),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"temp",sep="/"))
	}

###Translating the code above
Sometimes you may run into code that combines multiple functions into one line. It can be helpful to break the pieces of the code apart to understand their function. 

Let's break down the second part of the code above. `matrix(rgamma(300,2,1),ncol=3,nrow=100)` is telling R to create a matrix that has 3 columns and 100 rows. try to past just that line of code into the console and see the result. Notice in this loop we are creating a "precip" and a "temp" dataset and pasting them within each location group (the loop iterates 3 times).

`h5write`
is writing that matrix to a dataset in our hdf file (sensorData.h5). `file = "sensorData.h5",paste(g,"precip",sep="/")` Notice that the dataset is called precip. 

###Our HDf5 File Structure
So now let's look at the structure of our file.  Notice that the `h5ls()` command tells us what each element in the file is, group or dataset. It also provides the dimenensions of the datasets and types of the data. In this case, the  precipitation and temperature datasets are of type 'float' and of dimensions 100 x 3.

<a href="http://www.burns-stat.com/documents/tutorials/impatient-r/more-r-key-objects/more-r-numbers/#twonum" target="_blank">More about float vs integer data here</a>

	#r ls again
	h5ls("sensorData.h5")

HDF5 files can hold mixed types as well.  Each data set can be of it's own type with different types within the group, or a dataset can be of mixed type itself as a dataframe object.  Furthermore, metadata can easily be added by creating attributes in R objects before adding them.  Let's do an example. We'll add some units information to our data. Note that `write.attributes = TRUE` is needed to create embedded metadata.

	#r add metadata}
	p1 <- matrix(rgamma(300,2,1),ncol=3,nrow=100)
	attr(p1,"units") <- "millimeters"
	
	#Now add this back into our file
	h5write(p1,file = "sensorData.h5","location1/precip",write.attributes=T)


Now, we've successfully created an HDF5 file! We can use a different set of functions to quickly read our data back out. If `read.attributes` is set to `TRUE` then we can also see the metadata about the matrix. Furthermore, we can chose to read in a subset, like the first 10 rows of data, rather than loading the entire dataset into R.
 
	#r read in all data
	l1p1 <- h5read("sensorData.h5","location1/precip",read.attributes=T)

	#read in first 10 lines of the data
	l1p1s <- h5read("sensorData.h5","location1/precip",read.attributes = T,index = list(1:10,NULL))


###Extra Credit If you get done early...###
Activity: Think about an application for HDF5 that you might have. Create a new HDF5 File that would support the data that you need to store. 



