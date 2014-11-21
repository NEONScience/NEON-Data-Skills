---
layout: post
title: "Activity: Working With HDF5 Data in R"
date:   2014-11-05 20:49:52
authors: Ted Hart - Adapted from Software Carpentry Materials by Leah A. Wasser
categories: [Hierarchical Data Formats]
tags : []
description: "This activity will Introduce the HDF5 file format.."
code1: 
image:
  feature: textur2_FieldWork.jpg
  credit: Ordway Swisher Biological Station, NEON, thx to Courtney Meier
  creditlink: http://www.neoninc.org
permalink: /HDF5/HDF5-In-R/
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


    #not sure what this is
    source("../chunk_options.R")
 

**Goals**

1. Teach students about HDF5, a common data format used by many disciplines (also the backbone of NetCDF4)
2. Show students a real use case manipulating big data sets using indexing, loops, and `dplyr`
3. Reinforce to students in a variety of data munging type tasks such as understanding data types, string parsing, and working with dates


HDF5 is a format that allows the storage of large heterogeneous data sets with self-describing metadata.  It supports compression, parallel I/O, and easy data slicing which means large files don't need to be completely read into RAM (a real benefit to `R`).  Plus it has wide support in the many programming languages, `R` included.  To be able to access HDF5 files, you'll need to first install the base [HDF5 libraries](http://www.hdfgroup.org/HDF5/release/obtain5.html#obtain).  It might also be useful to install [HDFview](http://www.hdfgroup.org/products/java/hdfview/) which will allow you to explore the contents of an HDF5 file easily. HDF5 as a format can essentially be thought of as a file system that you load slices of at a time.  HDF5 files consists of groups (directories) and datasets (files).  The dataset holds the actual data, but the groups provide structure to that data, as you'll see in our example.


The package we'll be using is `rhdf5` which is part of the [Bioconductor](http://www.bioconductor.org) suite of `R` packages


	#source("http://bioconductor.org/biocLite.R")
	#biocLite("rhdf5")
	library("rhdf5")

##Review
The HDF5 format is in essence, a self-contained directory structure. In HDF5 files though "directories" are called "groups", and "files" are called "datasets". Each element in an hdf5 file can have metadata attached to it making HDF5 files "self-describing".

## Let's Create a File

Let's start by outlining the file we want to create.  We'll build a file called "sensorData.h5", which will hold data for a set of sensors at three different locations. Each sensor takes three replicates of two different measurements every minute. 

HDF5 allows us to organize and store data in many ways. Therefore we need to decide what type of structure is ideally suited to our data. To structure the HDF5 file, we'll start with a root group. Within that group, we will create a group for each sensor location. Within that group, we will create another group, which is sensor type, and then a matrix of time x replicate within that group.  

So let's create the file and call it "sensorData.h5" and then add our groups. 

###r Create file}
	#create hdf5 file
	h5createFile("sensorData.h5")
	h5createGroup("sensorData.h5", "location1")

The processing of creating nested groups can be simplified with loops, and nested loops.

	#create loops
	l1 <- c("location2","location3")
	for(i in 1:length(l1)){
  	  h5createGroup("sensorData.h5", l1[i])
	}

Now let's checkout our file and see what it looks like, we'll use `h5ls()` to do this.

	#r checkout file
	h5ls("sensorData.h5")

Our group structure is now set-up, but it doesn't contain any data. Let's simulate some data pretending that each sensor took replicate measurements for 100 minutes. We'll add a 100 x 3 matrix (called a dataset in HDF5 terminology) of simulated data to each of our groups. We'll use loops to create these matrices and then paste them into the hdf5 file as datasets.

	#r add data
	for(i in 1:3){
      g <- paste("location",i,sep="")
  	
    h5write(matrix(rgamma(300,2,1),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"precip",sep="/"))
    h5write(matrix(rnorm(300,25,5),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"temp",sep="/"))
	}

Sometimes you may run into code that combines multiple functions into one line. It can be helpful to break the pieces of the code apart to understand their function. 

Let's break down the second part of the code above. `matrix(rgamma(300,2,1),ncol=3,nrow=100)` is telling R to create a matrix that has 3 columns and 100 rows. try to past just that line of code into the console and see the result. Notice in this loop we are creating a "precip" and a "temp" dataset and pasting them within each location group (the loop iterates 3 times).

`h5write`
is writing that matrix to a dataset in our hdf file (sensorData.h5). `file = "sensorData.h5",paste(g,"precip",sep="/")` Notice that the dataset is called precip. 

So now let's look at the structure of our file.  Notice that the `h5ls()` command tells us what each element in the file is, group or dataset. It also provides the dimenensions of the datasets and types of the data. In this case, the  precipitation and temperature datasets are of type 'float' and of dimensions 100 x 3.

[More about float vs interger here](http://www.burns-stat.com/documents/tutorials/impatient-r/more-r-key-objects/more-r-numbers/#twonum)

	#r ls again
	h5ls("sensorData.h5")

HDF5 files can hold mixed types as well.  Each data set can be of it's own type with different types within the group, or a dataset can be of mixed type itself as a dataframe object.  Furthermore, metadata can easily be added by creating attributes in R objects before adding them.  Let's do an example. We'll add some units information to our data. Note that `write.attributes = TRUE` is needed to create embedded metadata.

	#r add metadata}
	p1 <- matrix(rgamma(300,2,1),ncol=3,nrow=100)attr(p1,"units") <- "millimeters"
	
	#Now add this back into our file
	h5write(p1,file = "sensorData.h5","location1/precip",write.attributes=T)



Now we can easily read our data back out. If `read.attributes` is set to `TRUE` then we can see the metadata about the matrix.  Furthermore, we don't need to read the whole data set in, we can examine just the first 10 rows.
```{r read data}
l1p1 <- h5read("sensorData.h5","location1/precip",read.attributes=T)
l1p1s <- h5read("sensorData.h5","location1/precip",read.attributes = T,index = list(1:10,NULL))
```
 
Next we'll work with a realworld data file. We'll look at the structure of an unknown file, extract metadata, and vizualize the contents of the files. The goal of the lesson is to use loops and custom functions to quickly examine data with a complex nested structure using advanced tools like `dplyr`.

# Working with real world files

### Examining file contents

Often we won't know what's in an HDF5 file, and we will need to explore the underlying structure.  So let's load up a file and examine it's contents.

```{r load file}
f <- "data/fiuTestFile.hdf5"
h5ls(f,all=T)
```

Note that it returns the group, the name of a particular node (which may be a group), the type, and class, and the dimensions of the object.  In this case because the class is compound (meaning there are mixed data types), the dimensions are returned as the number of elements.

```{r readHDF}
temp <- h5read(f,"/Domain_03/Ord/min_1/boom_1/temperature")
head(temp)
plot(temp$mean,type='l')
```

### Extracting metadata
It's that simple to extract a single table from an HDF5 file.  Another great advantage of HDF5 is that it's self describing, so metadata is embedded in the file. However the best way to access it via the low level HDF5 API (NOTE To instructors:  I submitted a pull request to the package and a new fxn called 'h5readAttributes(file, name)' is now in the DEV version of rhdf5, so that may be in the latest version)

```{r metadata}
# Open file
out <- H5Fopen(f)
# open a group
g <- H5Gopen(out,'/Domain_03/Ord')
a <- H5Aopen_by_idx(g,1)
H5Aget_name(a)
aval <- H5Aread(a)
aval 
### Lastly we need to close the file
H5Aclose(a)
H5Gclose(g)
H5Fclose(out)
```

But this is really tedious.  We can easily create a simple function that can extract all the metadata from any group.

```{r metdatafxn}

h5metadata <- function(fileN, group, natt){
  out <- H5Fopen(fileN)
  g <- H5Gopen(out,group)
  output <- list()
  for(i in 0:(natt-1)){
    ## Open the attribute
    a <- H5Aopen_by_idx(g,i)
    output[H5Aget_name(a)] <-  H5Aread(a)
    ## Close the attributes
    H5Aclose(a)
  }
  H5Gclose(g)
  H5Fclose(out)
  return(output)
}

```

Now we can combine the information we get from `h5ls` with our metadata extraction function. This means we could easily loop through the whole file and extract metadata for every element.

```{r extracting metadat}
fiu_struct <- h5ls(f,all=T)
g <- paste(fiu_struct[2,1:2],collapse="/")
h5metadata(f,g,fiu_struct$num_attrs[2])
```

### Visualizing temperature differences

Now, let's say we want to compare temeratures across sites, how can we build a dataframe to do this?  We'll use our knowledge of the structure of the HDF5 to easily loop through the file and build a new data frame.  Let's look at Domain 3, 1 minute series across all the booms.

```{r compare booms}
library(dplyr)
library(ggplot2)
# Set the path string
s <- "/Domain_03/Ord/min_1"
### Grab the paths
paths <- fiu_struct %.% filter(grepl(s,group), grepl("DATA",otype)) %.% group_by(group) %.% summarise(path = paste(group,name,sep="/"))
ord_temp <- data.frame()
for(i in paths$path){
  boom <-  strsplit(i,"/")[[1]][5]
  dat <- h5read(f,i)
  dat$boom <- rep(boom,dim(dat)[1])
  ord_temp <- rbind(ord_temp,dat)
}
### Dates aren't dates though, so let's fix that
ord_temp$date <- as.POSIXct(ord_temp$date,format = "%Y-%m-%d %H:%M:%S", tz = "EST")
## Now we can make our plot!
ggplot(ord_temp,aes(x=date,y=mean,group=boom,colour=boom))+geom_path()+ylab("Mean temperature") + xlab("Date")+theme_bw()+ggtitle("3 Days of temperature data at Ordway Swisher")
```

Now, what if we want to compare temperatures at our two different sites? Well let's do that but this time we'll compare 30 minute averages. We'll need to change up our search strings a bit. but we can still use most of the code we just build

```{r Compare sites}

### We want all sites in the minute 30 so this will help us prune our list
s <- "min_30"
### Grab the paths
paths <- fiu_struct %.% filter(grepl(s,group), grepl("DATA",otype)) %.% group_by(group) %.% summarise(path = paste(group,name,sep="/"))
temp_30 <- data.frame()
for(i in paths$path){
  boom <-  strsplit(i,"/")[[1]][5]
  site <- strsplit(i,"/")[[1]][3]
  dat <- h5read(f,i)
  dat$boom <- rep(boom,dim(dat)[1])
  dat$site <- rep(site,dim(dat)[1])
 temp_30 <- rbind(temp_30,dat)
}
### Dates aren't dates though, so let's fix that
temp_30$date <- as.POSIXct(temp_30$date,format = "%Y-%m-%d %H:%M:%S")

temp30_sum <- temp_30 %.% group_by(date,site) %.% summarise(mean = mean(mean))
ggplot(temp30_sum,aes(x=date,y=mean,group=site,colour=site)) + geom_path()+ylab("Mean temperature") + xlab("Date")+theme_bw()+ggtitle("Comparison of Ordway-Swisher(FL) vs Sterling(CO)")
```



