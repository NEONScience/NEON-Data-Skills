---
syncID: 40146c0d0d3b43d0a2dc1f14f6c36ade
title: "Create HDF5 Files in R Using Loops"
description: "Create a HDF5 in R from scratch! Add groups and datasets. View the files with HDFView."
dateCreated: 2014-11-18
authors: Ted Hart, Leah Wasser, Adapted From Software Carpentry
contributors: Elizabeth Webb, Alison Dernbach
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: rhdf5
topics: HDF5
languagesTool: R
dataProduct:
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/Using-hdf5-r/Create-Hierarchical-Data-Format-HDF5-With-Loops/Create-Hierarchical-Data-Format-HDF5-With-Loops.R
tutorialSeries: intro-hdf5-r-series
urlTitle: create-hdf5-loops-r
---

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

* Understand how HDF5 files can be created and structured in R using the rhfd 
libraries. </li>
* Understand the three key HDF5 elements: 
		* the HDF5 file itself,
		* groups,and 
		* datasets.

## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### R Libraries to Install:

* **rhdf5** 

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on 
Packages in R </a>– Adapted from Software Carpentry.

## Recommended Background 

Consider reviewing the documentation for the <a href="http://www.bioconductor.org/packages/release/bioc/manuals/rhdf5/man/rhdf5.pdf" target="_blank">RHDF5 package</a>.

</div>

### A Brief Review - About HDF5

The HDF5 file can store large, heterogeneous datasets that include metadata. It 
also supports efficient `data slicing`, or extraction of particular subsets of a 
dataset which means that you don't have to read  large files read into the computers 
memory/RAM in their entirety in order work with them. This saves a lot of time
 when working with with HDF5 data in R. When HDF5 files contain spatial data, 
they can also be read directly into GIS programs such as `QGiS`.  

The HDF5 format is a self-contained directory structure. We can compare this 
structure to the folders and files located on your computer. However, in HDF5 
files  "directories" are called `groups` and files are called `datasets`. The 
HDF5 element itself is a file. Each element in an HDF5 file can have metadata 
attached to it making HDF5 files "self-describing".

<a href="https://www.neonscience.org/about-hdf5" target="_blank"> Read more about 
HDF5 here. </a>

## HDF5 in R

To access HDF5 files in R, you need base 
<a href="https://www.hdfgroup.org/downloads/hdf5/" target="_blank">HDF5 
libraries</a> 
installed on your computer. 
It might also be useful to install 
<a href="https://www.hdfgroup.org/downloads/hdfview/" target="_blank">the free HDF5 
viewer</a>
which will allow you to explore the contents of an HDF5 file visually using a 
graphic interface. <a href="https://www.neonscience.org/explore-data-hdfview" target="_blank">More about 
working with HDFview and a hands-on activity here.</a>

The package we'll be using is `rhdf5` which is part of the 
<a href="http://www.bioconductor.org" target="_blank">Bioconductor</a> suite of
 R packages. If you haven't installed this package before, you can use the first 
two lines of code below to install the package. Then use the library command to 
call the `library("rhdf5")` library.


    # Install rhdf5 package (only need to run if not already installed)
    #install.packages("BiocManager")
    #BiocManager::install("rhdf5")
    
    # Call the R HDF5 Library
    library("rhdf5")
    
    # set working directory to ensure R can find the file we wish to import and where
    # we want to save our files
    wd <- "~/Documents/data/" #This will depend on your local environment 
    setwd(wd) 

<a href="http://www.bioconductor.org/packages/release/bioc/html/rhdf5.html" target="_blank">Read more about the `rhdf5` package here.</a>

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

    ## file '/Users/olearyd/Git/data/sensorData.h5' already exists.

    ## [1] FALSE

    # create group for location 1
    h5createGroup("sensorData.h5", "location1")

    ## Can not create group. Object with name 'location1' already exists.

    ## [1] FALSE

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

    ## Can not create group. Object with name 'location2' already exists.

    ## Can not create group. Object with name 'location3' already exists.

Now let's view the structure of our HDF5 file. We'll use the `h5ls()` function to do this.


    # View HDF5 File Structure
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

And the output: 


    # 1
    paste(g, "precip", sep="/")

    ## [1] "location3/precip"

    # 2
    rnorm(300,2,1)

    ##   [1]  1.12160116  2.37206915  1.33052657  1.83329347  2.78469156  0.21951756  1.61651586
    ##   [8]  3.22719604  2.13671092  1.63516541  1.54468880  2.32070535  3.14719285  2.00645027
    ##  [15]  2.06133429  1.45723384  1.43104556  4.15926193  3.85002319  1.15748926  1.93503709
    ##  [22]  1.86915962  1.36021215  2.30083715  2.21046449 -0.02372759  1.54690075  1.87020013
    ##  [29]  0.97110571  1.65512027  2.17813648  1.56675913  2.64604422  2.79411476 -0.14945990
    ##  [36]  2.41051127  2.69399882  1.74000170  1.73502637  1.19408520  1.52722823  2.46432354
    ##  [43]  3.53782484  2.34243381  3.29194930  1.84151991  2.88567260 -0.13647135  3.00296224
    ##  [50]  0.85778037  2.95060383  3.60112607  1.70182011  2.21919357  2.78131358  4.77298934
    ##  [57]  2.05833348  1.83779216  2.69723103  2.99123600  3.50370367  1.94533631  2.27559399
    ##  [64]  2.72276547  0.45838054  1.46426751  2.59186665  1.76153254  0.98961174  1.89289852
    ##  [71]  0.82444265  2.87219678  1.50940120  0.48012497  1.98471512  0.41421129  2.63826815
    ##  [78]  2.27517882  3.23534211  0.97091857  1.65001320  1.22312203  3.21926211  1.61710396
    ##  [85] -0.12658234  1.35538608  1.29323483  2.63494212  2.45595986  1.60861243  0.24972178
    ##  [92]  2.59648815  2.21869671  2.47519870  3.28893524 -0.14351078  2.93625547  2.14517733
    ##  [99]  3.47478297  2.84619247  1.04448393  2.09413526  1.23898831  1.40311390  2.37146803
    ## [106]  2.19227829  1.90681329  2.26303161  2.99884507  1.74326040  2.11683327  1.81492036
    ## [113]  2.40780179  1.61687207  2.72739252  3.03310824  1.03081291  2.64457643  1.91816597
    ## [120]  1.08327451  1.78928748  2.76883928  1.84398295  1.90979931  1.74067337  1.12014125
    ## [127]  3.05520671  2.25953027  1.53057148  2.77369029  2.00694402  0.74746736  0.89913394
    ## [134]  1.92816438  2.35494925  0.67463920  3.05980940  2.71711642  0.78155942  3.72305006
    ## [141]  0.40562629  1.86261895  0.04233856  1.81609868 -0.17246583  1.08597066  0.97175222
    ## [148]  2.03687618  3.18872115  0.75895259  1.16660578  1.07536466  3.03581454  2.30605076
    ## [155]  3.01817174  1.88875411  0.99049222  1.93035897  2.62271411  2.59812578  2.26482981
    ## [162]  1.52726003  1.79621469  2.49783624  2.13485532  2.66744895  0.85641709  3.02384590
    ## [169]  3.67246567  2.60824228  1.52727352  2.27460561  2.80234576  4.11750031  2.61415438
    ## [176]  2.83139343  1.72584747  2.51950703  2.99546055  0.67057429  2.24606561  1.00670141
    ## [183]  1.06021336  2.17286945  1.95552109  2.07089743  2.68618677  0.56123176  3.28782653
    ## [190]  1.77083238  2.62322126  2.70762375  1.26714051  1.20204779  3.11801841  3.00480662
    ## [197]  2.60651464  2.67462075  1.35453017 -0.23423081  1.49772729  2.76268752  1.19530190
    ## [204]  3.10750811  2.52864738  2.26346764  1.83955448  2.49185616  1.91859037  3.22755405
    ## [211]  2.12798826  1.81429861  2.05723804  1.42868965  0.68103571  1.80038283  1.07693405
    ## [218]  2.43567001  2.64638560  3.11027077  2.46869879  0.40045458  3.33896319  2.58523866
    ## [225]  2.38463606  1.61439883  1.72548781  2.68705960  2.53407585  1.71551092  3.14097828
    ## [232]  3.66333494  2.81083499  3.18241488 -0.53755729  3.39492807  1.55778563  2.26579288
    ## [239]  2.97848166  0.58794567  1.84097123  3.34139313  1.98807665  2.80674310  2.19412789
    ## [246]  0.95367365  0.39471881  2.10241933  2.41306228  2.00773589  2.14253569  1.60134185
    ## [253] -0.65119903 -0.38269825  1.00581006  3.25421978  3.71441667  0.55648668  0.10765730
    ## [260] -0.47830919  1.84157184  2.30936354  2.37525467 -0.19275434  2.03402162  2.57293173
    ## [267]  2.63031994  1.15352865  0.90847785  1.28568361  1.84822183  2.98910787  2.63506781
    ## [274]  2.04770689  0.83206248  4.67738935  1.60943184  0.93227396  1.38921205  3.00806535
    ## [281]  0.96669941  1.50688173  2.81325862  0.76749654  0.63227293  1.27648973  2.81562324
    ## [288]  1.65374614  2.20174987  2.27493049  3.94629426  2.58820358  2.89080513  3.37907609
    ## [295]  0.91029648  3.03539190  0.61781396  0.05210651  1.99853728  0.86705444

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


<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** It's useful to learn about the different 
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
  An open HDF5 file handle exists. If the file has changed on disk meanwhile, the 
  function may not work properly. Run 'H5close()' to close all open HDF5 object handles.` 

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
### Challenge: Your Own HDF5

Think about an application for HDF5 that you might have. Create a new HDF5 file 
that would support the data that you need to store. 
</div>

<div id="ds-challenge" markdown="1">
### Challenge: View Data with HDFView
Open the sensordata.H5 file in the HDFView application and explore the contents.

Hint: You may be interested in these tutorials: 

* <a href="https://www.neonscience.org/explore-data-hdfview" target="_blank"> HDFView: 
Exploring HDF5 Files in the Free HDFview Tool </a>. 
* <a href="https://www.neonscience.org/setup-qgis-h5view#install-hdfview" target="_blank"> Install 
HDF5View </a>. 

</div>
