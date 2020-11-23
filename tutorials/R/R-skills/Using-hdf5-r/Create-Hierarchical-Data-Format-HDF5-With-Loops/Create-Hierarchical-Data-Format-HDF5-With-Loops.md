---
syncID: 40146c0d0d3b43d0a2dc1f14f6c36ade
title: "Create HDF5 Files in R Using Loops"
description: "Create a HDF5 in R from scratch! Add groups and datasets. View the files with HDFView."
dateCreated: 2014-11-18
authors: Ted Hart, Leah Wasser, Adapted From Software Carpentry
contributors: [Elizabeth Webb]
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

<a href="https://www.neonscience.org/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

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

<a href="https://www.neonscience.org/about-hdf5" target="_blank"> Read more about HDF5 here. </a>

## HDF5 in R

To access HDF5 files in R, you need base 
<a href="http://www.hdfgroup.org/HDF5/release/obtain5.html#obtain" target="_blank">HDF5 libraries</a> 
installed on your computer. 
It might also be useful to install 
<a href="http://www.hdfgroup.org/products/java/hdfview/" target="_blank">the free HDF5 viewer</a>
which will allow you to explore the contents of an HDF5 file visually using a 
graphic interface. <a href="site.basurl/explore-data-hdfview " target="_blank">More about working with HDFview and a hands-on activity here.</a>

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

    ##   [1]  1.278225041  1.284868617  1.028485198  0.318362350  4.404179820  1.799660876
    ##   [7]  3.460595556  1.735899066  3.130863028  1.354210244  2.818990531  2.107555340
    ##  [13]  3.619215172  1.443455603  3.490283217  2.889778193  2.060099558  1.219634620
    ##  [19]  2.314297955  3.029985586  2.262316477  1.703707439  1.793087976  2.876823500
    ##  [25]  2.629081472  3.611718031  2.899456305  2.932489767  2.102816077  3.285371155
    ##  [31]  3.466826970  0.298579523  0.834740429  1.443706295  2.844696872  1.172467769
    ##  [37]  2.290110430  2.223376479  0.228404436  2.424388991  2.039436439  2.538034633
    ##  [43]  2.428410318  0.088923046  1.386994609  1.316143027  1.197590262  2.439426666
    ##  [49]  3.920194904  2.814446646  2.062931998  0.408057796  1.739027933  3.493253833
    ##  [55]  0.838356091  3.116636519  1.859508899  2.902280090  0.601409670  0.882717074
    ##  [61]  1.537303842  2.533771320  2.526003977  0.535008427  2.482415405  0.556113322
    ##  [67]  1.797561722  3.668466873  4.563577371  1.546281531  2.549893828  0.892601578
    ##  [73]  2.909178217 -0.404333577 -0.025179209  1.454654684  1.416837208  0.581098990
    ##  [79]  2.820085896  3.398380310 -0.007530648  3.240257117  2.759808244  0.480811463
    ##  [85]  0.906204687  0.834281049  3.836305875  0.820666078  2.419020439  1.710817173
    ##  [91]  1.424796002  1.686932935  2.530187560  1.367076322  1.555944619  3.113348353
    ##  [97]  2.409473502  1.438906924  2.323954642  3.547961460  2.445353304  0.268802356
    ## [103]  2.744429742  1.720373299  2.261042623  1.356629333  2.248502436  2.402817507
    ## [109]  2.119130738  1.818126069  1.407204988  1.573675989  0.347566787  1.145830089
    ## [115]  1.321335512  2.199631571  2.334126448  2.995400191  2.381974525  1.419763467
    ## [121]  1.563980436  0.220980255  2.428535250  2.747185087  0.521314020  3.278176793
    ## [127]  4.145569324  2.307316594  3.793058520  1.271736271  1.896793240  1.289688897
    ## [133]  2.456810562  2.574999698  2.794638590  2.508250926  1.573771959  3.091495454
    ## [139]  1.369763604  1.615514795  1.430825224  2.788983318  2.933231622  2.805276338
    ## [145]  2.235893439  1.255282219  2.274298830  1.831758820  1.885916559  0.776236925
    ## [151]  3.028436626  2.451765179  1.370753623  0.705835786  2.200012113  3.142588080
    ## [157]  2.951418065  1.502125526  2.908178071  0.659704425  3.066581598  1.854211542
    ## [163]  1.774317972  2.553503211  4.632757453  1.303057888  3.837009300  1.392157783
    ## [169]  2.260663408  1.024466004  2.943655432  2.974393625  2.044658685  1.719941694
    ## [175]  0.199527665  1.426342944  3.769137715  3.101392093  2.159094724  2.118784328
    ## [181]  1.546676946  2.205199477  1.529929080  1.867254380  1.872452201  2.142286940
    ## [187]  2.517705095  1.772501968  2.516229534 -1.329547576  0.166205925  1.949219706
    ## [193]  1.042123159  1.134972988  2.070899827  2.417684524  3.005450451  0.875381065
    ## [199]  1.739566786  2.220111312  3.219015061  2.924833446  2.741152697  2.110338916
    ## [205]  1.482514883  1.013413663  3.383693689  2.905853703  2.280269623  1.700899017
    ## [211]  2.771176259  1.858712597  1.820621801  3.914521551  1.617538677 -0.401901123
    ## [217]  3.029114851  3.315301966  2.460221245  2.299768382  2.639044920  2.736940454
    ## [223]  1.062068866  5.098780957  2.406463821  1.444265120  2.682470627  0.747746944
    ## [229]  3.297873645  2.030445518  3.555606166  2.651980533  1.027529925  1.500905709
    ## [235]  1.724760846  0.939024283  2.125745645  3.077033479  0.306683966  2.395890076
    ## [241]  1.098407170  0.798214630  4.414017054  1.139715644  0.922589984  2.923132443
    ## [247]  0.573015639  0.552231144  3.141549949  1.973925021  0.620865692  3.043250510
    ## [253]  2.980342385  2.032278504  2.888021568  4.251581699  3.537657858  2.161943393
    ## [259]  0.238419724  1.624115679  3.566956547  2.556919868  2.485005486  1.800565497
    ## [265]  2.328704046  2.415496674  0.707173085  3.457049270  2.343035608  0.292409894
    ## [271]  1.618865986  1.394413843  2.710076886  2.875768067  3.616241696  1.279817121
    ## [277]  1.050294037  1.747096436  2.500487777  2.052521771  3.307183062  1.695215657
    ## [283]  0.263322234  2.288240862  0.401556912  3.108155841  2.855198262  0.565221931
    ## [289]  0.640354821  0.006287936  1.239440043  1.060739266  1.566642011  1.138481761
    ## [295]  0.168300300  1.419914356  0.727687395  2.764005825  1.593657081  2.239039725

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
### Challenge: Your Own HDF5

Think about an application for HDF5 that you might have. Create a new HDF5 file 
that would support the data that you need to store. 
</div>

<div id="ds-challenge" markdown="1">
### Challenge: View Data with HDFView
Open the sensordata.H5 file in the HDFView application and explore the contents.

Hint: You may be interested in these tutorials: 

* <a href="https://www.neonscience.org/explore-data-hdfview" target="_blank"> HDFView: Exploring HDF5 Files in the Free HDFview Tool </a>. 
* <a href="{{ site.baseurl }}setup-qgis-h5view#install-hdfview" target="_blank"> Install HDF5View </a>. 

</div>
