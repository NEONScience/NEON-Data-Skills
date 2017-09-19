---
syncID: 40146c0d0d3b43d0a2dc1f14f6c36ade
title: "Creating HDF5 Files in R Using Loops"
description: "Create a HDF5 in R from scratch! Add groups and datasets. View the files with HDFView."
dateCreated: 2014-11-18
authors: Ted Hart, Leah Wasser, Adapted From Software Carpentry
contributors: [Elizabeth Webb]
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: rhdf5
topics: HDF5
languagesTool: R
dataProduct:
code1: /HDF5/create-HDF5-In-R.R
tutorialSeries: intro-hdf5-r-series

---

<div id="ds-objectives" markdown="1">

### Learning Objectives
After completing this tutorial, you will be able to:

* Understand how HDF5 files can be created and structured in R using the rhfd libraries. </li>
* Understand the three key HDF5 elements: 
		* the HDF5 file itself,
		* groups,and 
		* datasets.

## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### R Libraries to Install:

* **rhdf5** 

[ { { site.baseurl }} R/Packages-In-R/](More on Packages in R - Adapted from Software Carpentry.)

## Recommended Background 

Consider reviewing the documentation for the <a href="http://www.bioconductor.org/packages/release/bioc/manuals/rhdf5/man/rhdf5.pdf" target="_blank">RHDF5 package</a>.

</div>

### A Brief Review - About HDF5

The HDF5 file can store large, heterogeneous datasets that include metadata. It 
also supports efficient `data slicing`, or extraction of particular subsets of a 
dataset which means that you don't have to read  large files read into the computers 
memory/RAM in their entirety in order work with them. This saves a lot of time
 when working with with HDF5 data in `R`. When HDF5 files contain spatial data, 
they can also be read directly into GIS programs such as `QGiS`.  

The HDF5 format is a self-contained directory structure. We can compare this 
structure to the folders and files located on your computer. However, in HDF5 
files  "directories" are called `groups` and files are called `datasets`. The 
HDF5 element itself is a file. Each element in an HDF5 file can have metadata 
attached to it making HDF5 files "self-describing".

[Read more about HDF5 here.]({{ site.baseurl }}/HDF5/About/)

## HDF5 in R

To access HDF5 files in `R`, you need base <a href="http://www.hdfgroup.org/HDF5/release/obtain5.html#obtain" target="_blank">HDF5 libraries</a> installed on your computer. 
It might also be useful to install <a href="http://www.hdfgroup.org/products/java/hdfview/" target="_blank">the free HDF5 viewer</a> which will allow you to explore the 
contents of an HDF5 file visually using a graphic interface. 
[More about working with HDFview and a hands-on activity here]({{ site.baseurl }}/HDF5/Exploring-Data-HDFView/).

The package we'll be using is `rhdf5` which is part of the 
<a href="http://www.bioconductor.org" target="_blank">Bioconductor</a> suite of
 `R` packages. If you haven't installed this package before, you can use the first 
two lines of code below to install the package. Then use the library command to 
call the `library("rhdf5")` library.


    # Install rhdf5 package (only need to run if not already installed)
    #source("http://bioconductor.org/biocLite.R")
    #biocLite("rhdf5")
    
    # Call the R HDF5 Library
    library("rhdf5")
    
    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files
    #setwd("working-dir-path-here")

<a href="http://www.bioconductor.org/packages/release/bioc/vignettes/rhdf5/inst/doc/rhdf5.pdf" target="_blank">Read more about the `rhdf5` package here.</a>

## Create an HDF5 File in R

Let's start by outlining the structure of the file that we want to create. 
We'll build a file called "sensorData.h5", that will hold data for a set of 
sensors at three different locations. Each sensor takes three replicates of two 
different measurements, every minute. 

HDF5 allows us to organize and store data in many ways. Therefore we need to decide 
what type of structure is ideally suited to our data before creating the HDF5 file. 
To structure the HDF5 file, we'll start at the file level. We will create a group 
for each sensor location. Within each location group, we will create two datasets 
containing temperature and precipitation data collected through time at each location.

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
   
Let's first create the HDF5 file and call it "sensorData.h5". Next, we will add 
a group for each location to the file. 


    # create hdf5 file
    h5createFile("sensorData.h5")

    ## [1] TRUE

    # create group for location 1
    h5createGroup("sensorData.h5", "location1")

    ## [1] TRUE

The output is `TRUE` when the code properly runs. 

Remember from the discussion above that we want to create three location groups. The 
process of creating nested groups can be simplified with loops and nested loops. 
While the for loop below might seem excessive for adding three groups, it will 
become increasingly more efficient as we need to add more groups to our file. 


    # Create loops that will populate 2 additional location "groups" in our HDF5 file
    	l1 <- c("location2","location3")
    	for(i in 1:length(l1)){
      	  h5createGroup("sensorData.h5", l1[i])
    	}

Now let's view the structure of our HDF5 file. We'll use the `h5ls()` function to do this.


    # View HDF5 File Structure
    h5ls("sensorData.h5")

    ##   group      name     otype dclass dim
    ## 0     / location1 H5I_GROUP           
    ## 1     / location2 H5I_GROUP           
    ## 2     / location3 H5I_GROUP

Our group structure that will contain location information is now set-up. However, 
it doesn't contain any data. Let's simulate some data pretending that each sensor
 took replicate measurements for 100 minutes. We'll add a 100 x 3 matrix that will 
be stored as a **dataset** in our HDF5 file. We'll populate this dataset with 
simulated data for each of our groups. We'll use loops to create these matrices 
and then paste them into each location group within the HDF5 file as datasets.


    # Add datasets to each group
    for(i in 1:3){
          g <- paste("location",i,sep="")
          
          # populate matrix with dummy data
          # create precip dataset within each location group
          h5write(
          	matrix(rnorm(300,2,1),
          				 ncol=3,nrow=100),
    			file = "sensorData.h5",
    			paste(g,"precip",sep="/"))
          
          #create temperature dataset within each location group
          h5write(
          	matrix(rnorm(300,25,5),
          				 ncol=3,nrow=100),
    			file = "sensorData.h5",
    			paste(g,"temp",sep="/"))
    	}

### Understandig Complex Code 

Sometimes you may run into code (like the above code) that combines multiple 
functions. It can be helpful to break the pieces of the code apart to understand 
their overall function. 

Looking at the first `h5write()` chunck above, let's figure out what it is doing.
We can see easily that part of it is telling R to create a matrix (`matrix()`) 
that has 3 columns (`ncol=3`) and 100 rows (`nrow=100`). That is fairly straight 
forward, but what about the rest? 

Do the following to figure out what it's doing.

1. Type `paste(g,"precip",sep="/")` into the R console. What is the result?
2. Type `rnorm(300,2,1)` into the console and see the result. 
3. Type `g` into the console and take note of the result.
4. Type `help(norm)` to understand what norm does. 


    # 1
    paste(g, "precip", sep="/")

    ## [1] "location3/precip"

    # 2
    rnorm(300,2,1)

    ##   [1]  2.13042031  2.60179021  2.44064215  1.13162833  1.47184959
    ##   [6]  1.07634970  0.95895940  1.26092956  2.81653731  2.44605577
    ##  [11]  3.54395993  1.72467132  2.42292457  0.74759103  2.59891866
    ##  [16]  1.49179354  2.19250018 -0.75667848  3.57306683  2.60427372
    ##  [21]  4.86555485  2.17898526  1.56027594  1.63817318  2.27365553
    ##  [26]  2.50751969  1.57929306  2.65931598  1.47429543  2.11815923
    ##  [31]  0.42262602  1.32804838  0.88516294  1.81839678  2.58987334
    ##  [36]  0.08798260  2.46291907  0.44556448  0.07761009  2.79454050
    ##  [41]  1.97894437  1.12743325  1.08396320  3.82916864 -0.04656204
    ##  [46]  1.70034604  3.25225440  1.79938140  2.95193156  1.32646730
    ##  [51]  1.02467394  3.82492220  3.54341520  1.46151645  2.36653227
    ##  [56]  4.88001481  0.92673749  3.12495570  2.08946117  2.91380139
    ##  [61]  1.31992234  1.85302451  1.35219937  0.30146461  1.67144591
    ##  [66]  2.16731064  1.95748011  1.09449561  1.61407008  1.74057875
    ##  [71]  1.21766744  1.91552929  1.50464978  1.58198082  3.59301781
    ##  [76]  3.43846163  2.61448213  2.70726692  0.25933796  2.25467369
    ##  [81]  1.95755438  1.18705143  0.99243717  2.93421012  2.54649663
    ##  [86]  0.87558057  0.38942096  1.05055507  2.68996266  1.91840213
    ##  [91]  2.98738481  2.44901096  4.06625990  2.57125577  3.11950737
    ##  [96]  2.82350471  1.53472443  1.65068055  0.80682112  1.68159527
    ## [101]  0.86434545  1.91091922  1.77338089  2.06111320  2.38328552
    ## [106]  1.82751759  1.16705598  1.11925164  3.17452452  0.48352048
    ## [111]  1.16123724  3.75876340  2.63447321  1.26530244  1.95788176
    ## [116]  1.56490995  1.39949683  3.33069807  2.79504689  1.79095458
    ## [121]  2.77659158  2.21766668  1.70951648  2.34036419  2.22248068
    ## [126]  0.48977010  2.25590859  0.18024104  0.97090736  0.65759769
    ## [131]  2.06168040  1.79262814  1.09505569  3.16697974  1.47507929
    ## [136]  3.14278227  0.31762826  1.47191935  2.01486555  1.51682491
    ## [141]  3.55450196  1.68103052  3.60327599  3.07715913  3.67942831
    ## [146]  1.90110462  2.92296883  1.95484997  2.43681599  1.55122952
    ## [151]  4.27607956  0.69963432  0.99162172  1.40374653  2.13788524
    ## [156]  2.34678286  0.71887932  0.54072319  2.01944175  1.07096247
    ## [161] -0.40800825  2.97155392  1.91213268  0.92916239  1.15432742
    ## [166]  1.59794258  0.55685706  2.33160039  1.61899913  2.22874388
    ## [171]  2.18102232  2.31267109  2.81118676  2.70018642  2.51153567
    ## [176]  1.93550944  3.03819024  2.37584511  1.72203931  0.98858281
    ## [181]  1.13585201  2.20748037  1.70210379 -0.22832290  1.35182374
    ## [186]  1.89761937  1.26146924  2.39992972  1.58075694  2.94543739
    ## [191]  4.09979101  1.90905931  3.51558106  1.74125394  1.37891067
    ## [196]  2.53207407  3.78405331  2.45732997  2.61277999  1.95205878
    ## [201]  3.54699673  0.34524781  2.11989691  3.10267867  3.05406753
    ## [206]  2.74076619  1.17724412  1.76614732 -1.00518120  1.17667263
    ## [211]  0.53147967  0.01288092  2.18940636  1.32040176  2.28737754
    ## [216]  3.09157696  0.31466643  1.75228987  1.39874084  2.11016984
    ## [221]  0.43482560  3.59949318  1.26567209  1.91845636  1.88147579
    ## [226]  2.83623034  2.94230727  1.38018637  3.04321447  1.48893059
    ## [231]  2.73588405  1.04241420  1.88456191  3.78954704  3.07929767
    ## [236]  1.66296357  1.50781945  2.15776277  2.73451989  2.18614214
    ## [241]  2.64794127  2.09614724  3.71210970  0.37146419  2.11082299
    ## [246]  1.30725919  1.51449028  1.31373032  2.83547131  3.24061663
    ## [251]  0.77176549  1.84010339  0.91138262  0.16382850  1.97845106
    ## [256]  1.57252808  1.77214675  1.39852056  2.05005315  2.51608954
    ## [261]  1.90681726  2.21505682  1.47142940  0.52557427  3.83478952
    ## [266]  2.80756575  2.28020747  2.61168964  2.12909645  3.44491341
    ## [271]  2.18813329  2.00677236  1.89422344  2.02773803  2.22385489
    ## [276]  1.70105935  1.87829386  1.30610294  1.88838906  0.68982171
    ## [281]  3.50123665  3.40074887  2.25554270  4.49417288  1.54605503
    ## [286]  2.36101662  1.34784530  2.56714946  2.10000272  3.12826680
    ## [291]  1.17400090  1.63110438  0.83531798  2.44892354  2.29279718
    ## [296]  2.40443996  2.57945863  2.02856407  2.43893535  3.47015235

    # 3
    g

    ## [1] "location3"

    # 4
    help(norm)

The `rnorm` function creates a set of random numbers that fall into a normal 
distribution. You specify the mean and standard deviation of the dataset and R 
does the rest. Notice in this loop we are creating a "precip" and a "temp" dataset 
and pasting them into each location group (the loop iterates 3 times).

The `h5write` function is writing each matrix to a dataset in our HDF5 file 
(sensorData.h5). It is looking for the following arguments: `hrwrite(dataset,YourHdfFileName,LocationOfDatasetInH5File)`. Therefore, the code: 
`(matrix(rnorm(300,2,1),ncol=3,nrow=100),file = "sensorData.h5",paste(g,"precip",sep="/"))` 
tells R to add a random matrix of values to the sensorData HDF5 file within the 
path called `g`. It also tells R to call the dataset within that group, "precip". 

### HDF5 File Structure
Next, let's check the file structure of the sensorData.h5 file. The `h5ls()` 
command tells us what each element in the file is, group or dataset. It also 
identifies the dimensions and types of data stored within the datasets in the 
HDF5 file. In this case, the  precipitation and temperature datasets are of type 
'float' and of dimensions 100 x 3 (100 rows by 3 columns).


<div id="ds-dataTip">
<i class="fa fa-star"></i>**Data Tip:** It's useful to learn about the different 
types of data that can be stored within R (and other objects). 
<a href="http://www.burns-stat.com/documents/tutorials/impatient-r/more-r-key-objects/more-r-numbers/#twonum" target="_blank">Learn more about float vs integer data here</a>
</div>


    	# List file structure
    	h5ls("sensorData.h5")

    ##        group      name       otype dclass     dim
    ## 0          / location1   H5I_GROUP               
    ## 1 /location1    precip H5I_DATASET  FLOAT 100 x 3
    ## 2 /location1      temp H5I_DATASET  FLOAT 100 x 3
    ## 3          / location2   H5I_GROUP               
    ## 4 /location2    precip H5I_DATASET  FLOAT 100 x 3
    ## 5 /location2      temp H5I_DATASET  FLOAT 100 x 3
    ## 6          / location3   H5I_GROUP               
    ## 7 /location3    precip H5I_DATASET  FLOAT 100 x 3
    ## 8 /location3      temp H5I_DATASET  FLOAT 100 x 3

### Data Types within HDF5

HDF5 files can hold mixed types of data. For example HDF5 files can store both 
strings and numbers in the same file. Each dataset in an HDF5 file can be its 
own type. For example a dataset can be composed of all integer values or it 
could be composed of all strings (characters). A group can contain a mix of string, 
and number based datasets.  However a dataset can also be mixed within the dataset 
containing a combination of numbers and strings. 

## Add Metdata to HDF5 Files

Some metadata can be added to an HDF5 file in R by creating attributes in R 
objects before adding them to the HDF5 file. Let's look at an example of how we 
do this. We'll add the units of our data as an attribute of the R matrix before 
adding it to the HDF5 file. Note that `write.attributes = TRUE` is needed when 
you write to the HDF5 file, in order to add metadata to the dataset.


    # Create matrix of "dummy" data
    p1 <- matrix(rnorm(300,2,1),ncol=3,nrow=100)
    # Add attribute to the matrix (units)
    attr(p1,"units") <- "millimeters"
    
    # Write the R matrix to the HDF5 file 
    h5write(p1,file = "sensorData.h5","location1/precip",write.attributes=T)
    
    # Close the HDF5 file
    H5close()

We close the file at the end once we are done with it. Otherwise, next time you 
open a HDF5 file, you will get a warning message similar to: 

`Warning message:
In h5checktypeOrOpenLoc(file, readonly = TRUE) :
  An open HDF5 file handle exists. If the file has changed on disk meanwhile, the function may not work properly. Run 'H5close()' to close all open HDF5 object handles.` 

## Reading Data from an HDF5 File

We just learned how to create an HDF5 file and write information to the file. 
We use a different set of functions to read data from an HDF5 file. If 
`read.attributes` is set to `TRUE` when we read the data, then we can also see 
the metadata for the matrix. Furthermore, we can chose to read in a subset, 
like the first 10 rows of data, rather than loading the entire dataset into R.


    # Read in all data contained in the precipitation dataset 
    l1p1 <- h5read("sensorData.h5","location1/precip",
    							 read.attributes=T)
    
    # Read in first 10 lines of the data contained within the precipitation dataset 
    l1p1s <- h5read("sensorData.h5","location1/precip",
    								read.attributes = T,index = list(1:10,NULL))

Now you are ready to go onto the other tutorials in the series to explore more 
about HDF5 files. 

<div id="ds-challenge" markdown="1">
## Challenge: Your Own HDF5

Think about an application for HDF5 that you might have. Create a new HDF5 file 
that would support the data that you need to store. 
</div>

<div id="ds-challenge" markdown="1">
## Challenge: View Data with HDFView
Open the sensordata.H5 file in the HDFView application and explore the contents.

Hint: You may be interested in these tutorials: 

* <a href="{{ site.baseurl }}/HDF5/Exploring-Data-HDFView" target="_blank"> HDFView: Exploring HDF5 Files in the Free HDFview Tool </a>. 
* <a href="{{ site.baseurl }}/setup/setup-qgis-h5view#install-hdfview" target="_blank"> Install HDF5View </a>. 

</div>
