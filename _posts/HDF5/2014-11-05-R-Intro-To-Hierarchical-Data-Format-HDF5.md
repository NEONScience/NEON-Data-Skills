---
layout: post
title: "R: Introduction to HDF5 Files in R"
date:   2015-05-20 15:22:52
dateCreated: 2015-05-20 15:22:52
lastModified: 2015-05-20 15:22:52
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: RHDF5
authors: Leah A. Wasser
contributors:
categories: [coding-and-informatics]
category: coding-and-informatics
tags: [HDF5,R]
mainTag: HDF5
description: "Learn how to build a HDF5 file in R from scratch! Add groups,  datasets and attributes. Read data out from the file."
code1: R/Intro-HDF5-R.Rmd
image:
  feature: hierarchy_folder_purple.png
  credit: Colin Williams NEON, Inc.
  creditlink: http://www.neoninc.org
permalink: /HDF5/Intro-To-HDF5-In-R/
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
<li>Understand how HDF5 files can be created and structured in R using the rhfd5 libraries. </li>
<li>Understand the 3 key HDF5 elements: the HDF5 file itself and groups and datasets.</li>
<li>Understand how to add and read attributes from an HDF5 file.</li>
</ol>

<h3>What You'll Need</h3>
<ul>
<li>R or R studio installed and the R HDF5 libraries.</li>
<li>Recommended Background: Consider reviewing the documentation for the <a href="http://www.bioconductor.org/packages/release/bioc/manuals/rhdf5/man/rhdf5.pdf" target="_blank">RHDF5 libraries</a></li>
</ul>
</div>

### A Brief Review - About HDF5
The HDF5 file can store large, heterogeneous datasets that include metadata. It also supports efficient `data slicing`, or extraction of particular subsets of a dataset which means that you don't have to read  large files read into the computers memory / RAM in their entirety in order work with them. 

[Read more about HDF5 here.]({{ site.baseurl }}/HDF5/About/)

##HDF5 in R

To access HDF5 files in `R`, we will use the `rhdf5` library which is part of the <a href="http://www.bioconductor.org" target="_blank">Bioconductor</a> suite of `R` libraries. It might also be useful to install <a href="http://www.hdfgroup.org/products/java/hdfview/" target="_blank">the free HDF5 viewer</a> which will allow you to explore the contents of an HDF5 file using a graphic interface. [More about working with HDFview and a hands-on activity here]({{ site.baseurl }}/HDF5/Exploring-Data-HDFView/).

	#install rhdf5 package
	source("http://bioconductor.org/biocLite.R")
	biocLite("rhdf5")
	library("rhdf5")

<a href="http://www.bioconductor.org/packages/release/bioc/vignettes/rhdf5/inst/doc/rhdf5.pdf" target="_blank">Read more about the `rhdf5` package here.</a>

## Create an HDF5 File in R

First, let's create a basic H5 file with one group and one dataset in it. 

	# Create hdf5 file
	h5createFile("vegData.h5")
	
	# Create a group called aNEONSite within the H5 file
	h5createGroup("vegData.h5", "aNEONSite")

	#view the structure of the h5 we've created
	h5ls("vegData.h5")

Next, let's create some dummy data to add to our H5 file.

	# create some sample, numeric data 
	a <- rnorm(n=40, m=1, sd=1) 
	someData <- matrix(a,nrow=20,ncol=2)

Write the sample data to the H5 file.
	
	# add some sample data to the H5 file located in the aNEONSite group
	# we'll call the dataset "temperature"
	h5write(someData, file = "vegData.h5", name="aNEONSite/temperature")
	
	# let's check out the H5 structure again
	h5ls("vegData.h5")

View a "dump" of the entire HDF5 file. NOTE: use this command with CAUTION if you
are working with larger datasets!

	# we can look at everything too 
	# but be cautious using this command!
	h5dump("vegData.h5")

It's good practice to close files that you open!

	#Close the file.
	H5close()

## Add Metadata (attributes)

First, open up the file.

	#open the file, create a class
	fid <- H5Fopen("vegData.h5")
	#open up the dataset to add attributes to, as a class
	did <- H5Dopen(fid, "aNEONSite/temperature")
	
Let's add some metadata (called attributes in HDF5 land) to our dummy temperature
data.

	# Provide the NAME and the ATTR (what the attribute says) 
	# for the attribute.
	h5writeAttribute(did, attr="Here is a description of the data",
	                 name="Description")
	h5writeAttribute(did, attr="Meters",
	                 name="Units")

We can also add attributes to a group:
	
	#let's add some attributes to the group
	did2 <- H5Gopen(fid, "aNEONSite/")
	h5writeAttribute(did2, attr="San Joachin Experimental Range",
	                 name="SiteName")
	h5writeAttribute(did2, attr="Southern California",
	                 name="Location")

When you are done writing to the file, close it!

	#close the files, groups and the dataset when you're done writing to them!
	H5Dclose(did)
	H5Gclose(did2)
	H5Fclose(fid)

# Working with an HDF5 File in R

Now that we've created our H5 file, let's use it! First, let's have a look at 
the attributes of the dataset and group in the file.


	#look at the attributes of the precip_data dataset
	h5readAttributes(file = "vegData.h5", 
	                 name = "aNEONSite/temperature")

	# you could assign the attributes to an object to access them in the code too:
	a <- h5readAttributes(file = "vegData.h5", 
	                 name = "aNEONSite/temperature")

	#look at the attributes of the aNEONsite group
	h5readAttributes(file = "vegData.h5", 
	                 name = "aNEONSite")
	
	# let's grab some data from the H5 file
	testSubset <- h5read(file = "vegData.h5", 
	                 name = "aNEONSite/temperature")
	
	testSubset2 <- h5read(file = "vegData.h5", 
	                 name = "aNEONSite/temperature",
	                 index=list(NULL,1))

	#close any lingering connections
	H5close()

Once we've created a data subset, we can plot, analysis, use the data however
we want to in R. NOTE: R currently does not handle subsetting when the dataset is
a compound (made up of different types of data). 

	#create a quick plot of the data
	hist(testSubset2[])

# Challenge

Time to test your skills. Open up the D17_2013_vegStr.csv in R. 

* Create a new H5 file called vegStructure.
* Add a group in your h5 file called SJER. 
* Add the veg structure data to that folder.
* Add some attributes the SJER group and to the data. 
* Now, repeat the above with the D17_2013_SOAP_vegStr csv.
* Name your second group SOAP

Some code is below to remind you how to import a CSV into R.

	options(stringsAsFactors = FALSE)
	newData <- read.csv("D17_2013_vegStr.csv")