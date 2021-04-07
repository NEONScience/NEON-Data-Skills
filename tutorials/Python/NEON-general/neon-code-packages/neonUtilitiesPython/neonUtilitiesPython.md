---
syncID: 5be9f80592394af3bc09cf8e469fef6e
title: "Using neonUtilities in Python"
description: "Use the neonUtilities R package in Python, via the rpy2 library."
dateCreated: 2018-5-10
authors: Claire K. Lunch
contributors: Donal O'Leary
estimatedTime: 0.5 hour
packagesLibraries: rpy2
topics: data-management,rep-sci
languagesTool: python
dataProduct: 
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/NEON-general/neon-code-packages/neonUtilitiesPython/neonUtilitiesPython.py
tutorialSeries: 
urlTitle: neon-utilities-python
---

The instructions below will guide you through using the neonUtilities R package 
in Python, via the rpy2 package. rpy2 creates an R environment you can interact 
with from Python.

The assumption in this tutorial is that you want to work with NEON data in 
Python, but you want to use the handy download and merge functions provided by 
the `neonUtilities` R package to access and format the data for analysis. If 
you want to do your analyses in R, use one of the R-based tutorials below.

For more information about the `neonUtilities` package, and instructions for 
running it in R directly, see the <a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore</a> tutorial 
and/or the <a href="http://www.neonscience.org/neonDataStackR" target="_blank">neonUtilities tutorial</a>.


## Install and set up

Before starting, you will need:

1. Python 3 installed. It is probably possible to use this workflow in Python 2, 
but these instructions were developed and tested using 3.7.4.
2. R installed. You don't need to have ever used it directly. We tested using 
R 3.6.1, but most other recent versions should also work.
3. `rpy2` installed. Run the line below from the command line, it won't run within 
Jupyter. See <a href="https://docs.python.org/3/installing/" target="_blank">Python documentation</a> for more information on how to install packages. 
`rpy2` often has install problems on Windows, see "Windows Users" section below if 
you are running Windows.
4. You may need to install `pip` before installing `rpy2`, if you don't have it 
installed already.

From the command line, run:


```python
pip install rpy2
```

    Requirement already satisfied: rpy2 in /opt/anaconda3/envs/py37/lib/python3.7/site-packages (2.9.4)
    Requirement already satisfied: six in /opt/anaconda3/envs/py37/lib/python3.7/site-packages (from rpy2) (1.15.0)
    Requirement already satisfied: jinja2 in /opt/anaconda3/envs/py37/lib/python3.7/site-packages (from rpy2) (2.11.3)
    Requirement already satisfied: MarkupSafe>=0.23 in /opt/anaconda3/envs/py37/lib/python3.7/site-packages (from jinja2->rpy2) (1.1.1)
    Note: you may need to restart the kernel to use updated packages.


### Windows users

The rpy2 package was built for Mac, and doesn't always work smoothly on Windows. 
If you have trouble with the install, try these steps.

1. Add C:\Program Files\R\R-3.3.1\bin\x64 to the Windows Environment Variable “Path”
2. Install rpy2 manually from https://www.lfd.uci.edu/~gohlke/pythonlibs/#rpy2
    1. Pick the correct version. At the download page the portion of the files 
    with cp## relate to the Python version. e.g., rpy2 2.9.2 cp36 cp36m win_amd64.whl 
    is the correct download when 2.9.2 is the latest version of rpy2 and you are 
    running Python 36 and 64 bit Windows (amd64).
    2. Save the whl file, navigate to it in windows then run pip directly on the file 
    as follows “pip install rpy2 2.9.2 cp36 cp36m win_amd64.whl”
3. Add  an R_HOME Windows environment variable with the path C:\Program Files\R\R-3.4.3 
(or whichever version you are running)
4. Add an R_USER Windows environment variable with the path C:\Users\yourUserName\AppData\Local\Continuum\Anaconda3\Lib\site-packages\rpy2

## Load packages

Now import `rpy2` into your session.


```python
import rpy2
import rpy2.robjects as robjects
from rpy2.robjects.packages import importr
```

Load the base R functionality, using the `rpy2` function `importr()`.


```python
base = importr('base')
utils = importr('utils')
stats = importr('stats')
```

The basic syntax for running R code via `rpy2` is `package.function(inputs)`, 
where `package` is the R package in use, `function` is the name of the function 
within the R package, and `inputs` are the inputs to the function. In other 
words, it's very similar to running code in R as `package::function(inputs)`. 
For example:


```python
stats.rnorm(6, 0, 1)
```





<span>FloatVector with 6 elements.</span>
<table>
  <tbody>
  <tr>

  <td>
    0.235043
  </td>

  <td>
    0.226146
  </td>

  <td>
    0.285580
  </td>

  <td>
    1.052145
  </td>

  <td>
    -0.199384
  </td>

  <td>
    -0.068163
  </td>

  </tr>
  </tbody>
</table>




Suppress R warnings. This step can be skipped, but will result in messages 
getting passed through from R that Python will interpret as warnings.


```python
from rpy2.rinterface import set_writeconsole_warnerror
import logging
set_writeconsole_warnerror(None)
```

Install the `neonUtilities` R package. Here I've specified the RStudio 
CRAN mirror as the source, but you can use a different one if you 
prefer.

You only need to do this step once to use the package, but we update 
the `neonUtilities` package every few months, so reinstalling 
periodically is recommended.

This installation step carries out the same steps in the same places on 
your hard drive that it would if run in R directly, so if you use R 
regularly and have already installed `neonUtilities` on your machine, 
you can skip this step. And be aware, this also means if you install 
other packages, or new versions of packages, via `rpy2`, they'll 
be updated the next time you use R, too.

The semicolon at the end of the line (here, and in some other function 
calls below) can be omitted. It suppresses a note indicating the output 
of the function is null. The output is null because these functions download 
or modify files on your local drive, but none of the data are read into the 
Python or R environments.


```python
utils.install_packages('neonUtilities', repos='https://cran.rstudio.com/');
```

Now load the `neonUtilities` package. This does need to be run every time 
you use the code; if you're familiar with R, `importr()` is roughly 
equivalent to the `library()` function in R.


```python
neonUtilities = importr('neonUtilities')
```

## Join data files: stackByTable()

The function `stackByTable()` in `neonUtilities` merges the monthly, 
site-level files the <a href="http://data.neonscience.org/home" target="_blank">NEON Data Portal</a> 
provides. Start by downloading the dataset you're interested in from the 
Portal. Here, we'll assume you've downloaded IR Biological Temperature. 
It will download as a single zip file named `NEON_temp-bio.zip`. Note the 
file path it's saved to and proceed.

Run the `stackByTable()` function to stack the data. It requires only one 
input, the path to the zip file you downloaded from the NEON Data Portal.

For additional, optional inputs to `stackByTable()`, see the <a href="http://neonscience.org/neonDataStackR" target="_blank">R tutorial</a> 
for neonUtilities.


```python
neonUtilities.stackByTable(filepath='~/Downloads/NEON_temp-bio.zip');
```

    
     
     |                                                  |
     
    0 % ~calculating  
    
     
     |++++++++++++++++++++++++++++++++++++++++++++++++++|
     
    100% elapsed=00s  
    
    
    Stacking operation across a single core.
    
    Stacking table IRBT_1_minute
    
    
     
     |                                                  |
     
    0 % ~calculating  
    
     
     |+++++++++++++                                     |
     
    25% ~00s          
    
     
     |+++++++++++++++++++++++++                         |
     
    50% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++++            |
     
    75% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++++++++++++++++|
     
    100% elapsed=00s  
    
    
    Stacking table IRBT_30_minute
    
    
     
     |                                                  |
     
    0 % ~calculating  
    
     
     |+++++++++++++                                     |
     
    25% ~00s          
    
     
     |+++++++++++++++++++++++++                         |
     
    50% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++++            |
     
    75% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++++++++++++++++|
     
    100% elapsed=00s  
    
    
    Merged the most recent publication of sensor position files for each site and saved to /stackedFiles
    Copied the most recent publication of variable definition file to /stackedFiles
    
    Finished: Stacked 2 data tables and 2 metadata tables!
    
    Stacking took 1.229288 secs
    
    All unzipped monthly data folders have been removed.
    


Check the folder containing the original zip file from the Data Portal; 
you should now have a subfolder containing the unzipped and stacked files called `stackedFiles`.

## Download files to be stacked: zipsByProduct()

The function `zipsByProduct()` uses the <a href="http://data.neonscience.org/data-api" target="_blank">NEON API</a> to programmatically download 
data files for a given product. The files downloaded by `zipsByProduct()` 
can then be fed into `stackByTable()`.

Run the downloader with these inputs: a DPID, a set of 4-letter site IDs (or 
"all" for all sites), a download package (either basic or expanded), the 
filepath to download the data to, and an indicator to check the size of 
your download before proceeding or not (TRUE/FALSE).

The DPID is the data product identifier, and can be found in the data product 
box on the NEON <a href="https://data.neonscience.org/data-products/explore" target="_blank">Explore Data</a> page. 
Here we'll download Breeding landbird point counts, DP1.10003.001.

There are two differences relative to running `zipsByProduct()` in R directly: 

1. `check.size` becomes `check_size`, because dots have programmatic meaning 
in Python
2. `TRUE` (or `T`) becomes `'TRUE'` because the values TRUE and FALSE don't 
have special meaning in Python the way they do in R, so it interprets them 
as variables if they're unquoted.

`check_size='TRUE'` does not work correctly in the Python environment. It 
estimates the size of the download and asks you to confirm before proceeding, 
and this interactive display doesn't work correctly outside R. Set 
`check_size='FALSE'` to avoid this problem, but be thoughtful about the size 
of your query since it will proceed to download without checking.


```python
neonUtilities.zipsByProduct(dpID='DP1.10003.001', 
                            site=base.c('HARV','BART'), 
                            savepath='~/Downloads',
                            package='basic', 
                            check_size='FALSE');
```

    Finding available files
    
      |                                                                            
      |                                                                      |   0%
      |                                                                            
      |=====                                                                 |   7%
      |                                                                            
      |==========                                                            |  14%
      |                                                                            
      |===============                                                       |  21%
      |                                                                            
      |====================                                                  |  29%
      |                                                                            
      |=========================                                             |  36%
      |                                                                            
      |==============================                                        |  43%
      |                                                                            
      |===================================                                   |  50%
      |                                                                            
      |========================================                              |  57%
      |                                                                            
      |=============================================                         |  64%
      |                                                                            
      |==================================================                    |  71%
      |                                                                            
      |=======================================================               |  79%
      |                                                                            
      |============================================================          |  86%
      |                                                                            
      |=================================================================     |  93%
      |                                                                            
      |======================================================================| 100%
    
    
    
    
    Downloading files totaling approximately 1.343273 MB
    
    Downloading 14 files
    
      |                                                                            
      |                                                                      |   0%
      |                                                                            
      |=====                                                                 |   8%
      |                                                                            
      |===========                                                           |  15%
      |                                                                            
      |================                                                      |  23%
      |                                                                            
      |======================                                                |  31%
      |                                                                            
      |===========================                                           |  38%
      |                                                                            
      |================================                                      |  46%
      |                                                                            
      |======================================                                |  54%
      |                                                                            
      |===========================================                           |  62%
      |                                                                            
      |================================================                      |  69%
      |                                                                            
      |======================================================                |  77%
      |                                                                            
      |===========================================================           |  85%
      |                                                                            
      |=================================================================     |  92%
      |                                                                            
      |======================================================================| 100%
    
    
    14 files successfully downloaded to ~/Downloads/filesToStack10003
    


The message output by `zipsByProduct()` indicates the file path where the 
files have been downloaded.

Now take that file path and pass it to `stackByTable()`.


```python
neonUtilities.stackByTable(filepath='~/Downloads/filesToStack10003');
```

    Unpacking zip files using 1 cores.
    
    
     
     |                                                  |
     
    0 % ~calculating  
    
     
     |++++                                              |
     
    7 % ~00s          
    
     
     |++++++++                                          |
     
    14% ~00s          
    
     
     |+++++++++++                                       |
     
    21% ~00s          
    
     
     |+++++++++++++++                                   |
     
    29% ~00s          
    
     
     |++++++++++++++++++                                |
     
    36% ~00s          
    
     
     |++++++++++++++++++++++                            |
     
    43% ~00s          
    
     
     |+++++++++++++++++++++++++                         |
     
    50% ~00s          
    
     
     |+++++++++++++++++++++++++++++                     |
     
    57% ~00s          
    
     
     |+++++++++++++++++++++++++++++++++                 |
     
    64% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++              |
     
    71% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++++++          |
     
    79% ~00s          
    
     
     |+++++++++++++++++++++++++++++++++++++++++++       |
     
    86% ~00s          
    
     
     |+++++++++++++++++++++++++++++++++++++++++++++++   |
     
    93% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++++++++++++++++|
     
    100% elapsed=00s  
    
    
    Stacking operation across a single core.
    
    Stacking table brd_countdata
    
    
     
     |                                                  |
     
    0 % ~calculating  
    
     
     |++++                                              |
     
    7 % ~00s          
    
     
     |++++++++                                          |
     
    14% ~00s          
    
     
     |+++++++++++                                       |
     
    21% ~00s          
    
     
     |+++++++++++++++                                   |
     
    29% ~00s          
    
     
     |++++++++++++++++++                                |
     
    36% ~00s          
    
     
     |++++++++++++++++++++++                            |
     
    43% ~00s          
    
     
     |+++++++++++++++++++++++++                         |
     
    50% ~00s          
    
     
     |+++++++++++++++++++++++++++++                     |
     
    57% ~00s          
    
     
     |+++++++++++++++++++++++++++++++++                 |
     
    64% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++              |
     
    71% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++++++          |
     
    79% ~00s          
    
     
     |+++++++++++++++++++++++++++++++++++++++++++       |
     
    86% ~00s          
    
     
     |+++++++++++++++++++++++++++++++++++++++++++++++   |
     
    93% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++++++++++++++++|
     
    100% elapsed=00s  
    
    
    Stacking table brd_perpoint
    
    
     
     |                                                  |
     
    0 % ~calculating  
    
     
     |++++                                              |
     
    7 % ~00s          
    
     
     |++++++++                                          |
     
    14% ~00s          
    
     
     |+++++++++++                                       |
     
    21% ~00s          
    
     
     |+++++++++++++++                                   |
     
    29% ~00s          
    
     
     |++++++++++++++++++                                |
     
    36% ~00s          
    
     
     |++++++++++++++++++++++                            |
     
    43% ~00s          
    
     
     |+++++++++++++++++++++++++                         |
     
    50% ~00s          
    
     
     |+++++++++++++++++++++++++++++                     |
     
    57% ~00s          
    
     
     |+++++++++++++++++++++++++++++++++                 |
     
    64% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++              |
     
    71% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++++++          |
     
    79% ~00s          
    
     
     |+++++++++++++++++++++++++++++++++++++++++++       |
     
    86% ~00s          
    
     
     |+++++++++++++++++++++++++++++++++++++++++++++++   |
     
    93% ~00s          
    
     
     |++++++++++++++++++++++++++++++++++++++++++++++++++|
     
    100% elapsed=00s  
    
    
    Copied the most recent publication of validation file to /stackedFiles
    Copied the most recent publication of categoricalCodes file to /stackedFiles
    Copied the most recent publication of variable definition file to /stackedFiles
    
    Finished: Stacked 2 data tables and 3 metadata tables!
    
    Stacking took 0.3607121 secs
    
    All unzipped monthly data folders have been removed.
    


## Read downloaded and stacked files into Python

We've now downloaded biological temperature and bird data, and merged 
the site by month files. Now let's read those data into Python so you 
can proceed with analyses.

First let's take a look at what's in the output folders.


```python
import os
os.listdir('/Users/olearyd/Downloads/filesToStack10003/stackedFiles/')
```




    ['categoricalCodes_10003.csv',
     'brd_countdata.csv',
     'brd_perpoint.csv',
     'readme_10003.txt',
     'variables_10003.csv',
     'validation_10003.csv']




```python
os.listdir('/Users/olearyd/Downloads/NEON_temp-bio/stackedFiles/')
```




    ['IRBT_1_minute.csv',
     'sensor_positions_00005.csv',
     'IRBT_30_minute.csv',
     'variables_00005.csv',
     'readme_00005.txt']



Each data product folder contains a set of data files and metadata files. 
Here, we'll read in the data files and take a look at the contents; for 
more details about the contents of NEON data files and how to interpret them, 
see the <a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore tutorial</a>.

There are a variety of modules and methods for reading tabular data into 
Python; here we'll use the `pandas` module, but feel free to use your own 
preferred method.

First, let's read in the two data tables in the bird data: 
`brd_countdata` and `brd_perpoint`.


```python
import pandas
brd_perpoint = pandas.read_csv('/Users/olearyd/Downloads/filesToStack10003/stackedFiles/brd_perpoint.csv')
brd_countdata = pandas.read_csv('/Users/olearyd/Downloads/filesToStack10003/stackedFiles/brd_countdata.csv')
```

And take a look at the contents of each file. For descriptions and unit of each 
column, see the `variables_10003` file.


```python
brd_perpoint
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>uid</th>
      <th>namedLocation</th>
      <th>domainID</th>
      <th>siteID</th>
      <th>plotID</th>
      <th>plotType</th>
      <th>pointID</th>
      <th>nlcdClass</th>
      <th>decimalLatitude</th>
      <th>decimalLongitude</th>
      <th>...</th>
      <th>endRH</th>
      <th>observedHabitat</th>
      <th>observedAirTemp</th>
      <th>kmPerHourObservedWindSpeed</th>
      <th>laboratoryName</th>
      <th>samplingProtocolVersion</th>
      <th>remarks</th>
      <th>measuredBy</th>
      <th>publicationDate</th>
      <th>release</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>806378dd-bc51-4d7e-bfd8-2b6bca459868</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>evergreenForest</td>
      <td>44.060146</td>
      <td>-71.315479</td>
      <td>...</td>
      <td>56.0</td>
      <td>evergreen forest</td>
      <td>18.0</td>
      <td>1.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vG</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20201223T141730Z</td>
      <td>RELEASE-2021</td>
    </tr>
    <tr>
      <th>1</th>
      <td>a8a8d1ac-e557-472f-a393-e2183c0098ff</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>B1</td>
      <td>evergreenForest</td>
      <td>44.060146</td>
      <td>-71.315479</td>
      <td>...</td>
      <td>56.0</td>
      <td>deciduous forest</td>
      <td>19.0</td>
      <td>3.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vG</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20201223T141730Z</td>
      <td>RELEASE-2021</td>
    </tr>
    <tr>
      <th>2</th>
      <td>8ebbac22-13c3-43da-bfe3-65f1cdfc85ca</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>A1</td>
      <td>evergreenForest</td>
      <td>44.060146</td>
      <td>-71.315479</td>
      <td>...</td>
      <td>56.0</td>
      <td>mixed deciduous/evergreen forest</td>
      <td>17.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vG</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20201223T141730Z</td>
      <td>RELEASE-2021</td>
    </tr>
    <tr>
      <th>3</th>
      <td>19f48260-d875-48e3-a7fb-dc8bbfb1e4b7</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>A2</td>
      <td>evergreenForest</td>
      <td>44.060146</td>
      <td>-71.315479</td>
      <td>...</td>
      <td>56.0</td>
      <td>deciduous forest</td>
      <td>19.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vG</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20201223T141730Z</td>
      <td>RELEASE-2021</td>
    </tr>
    <tr>
      <th>4</th>
      <td>c516ea74-0b05-4770-804a-c70ca65f3d27</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>B2</td>
      <td>evergreenForest</td>
      <td>44.060146</td>
      <td>-71.315479</td>
      <td>...</td>
      <td>56.0</td>
      <td>deciduous forest</td>
      <td>16.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vG</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20201223T141730Z</td>
      <td>RELEASE-2021</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>1063</th>
      <td>df3cb3cd-f2be-4732-9a7c-8727b479b617</td>
      <td>HARV_014.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_014</td>
      <td>distributed</td>
      <td>A1</td>
      <td>mixedForest</td>
      <td>42.471348</td>
      <td>-72.265421</td>
      <td>...</td>
      <td>65.0</td>
      <td>deciduous forest</td>
      <td>15.0</td>
      <td>1.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vJ</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20201223T141711Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>1064</th>
      <td>c79532ea-c878-4389-a034-fafbabb87b95</td>
      <td>HARV_014.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_014</td>
      <td>distributed</td>
      <td>A2</td>
      <td>mixedForest</td>
      <td>42.471348</td>
      <td>-72.265421</td>
      <td>...</td>
      <td>65.0</td>
      <td>deciduous forest</td>
      <td>17.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vJ</td>
      <td>New small logging road goes right through point 4</td>
      <td>WFREE</td>
      <td>20201223T141711Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>1065</th>
      <td>d52f83b1-2678-479a-bab3-f28bc44cb959</td>
      <td>HARV_014.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_014</td>
      <td>distributed</td>
      <td>A3</td>
      <td>mixedForest</td>
      <td>42.471348</td>
      <td>-72.265421</td>
      <td>...</td>
      <td>65.0</td>
      <td>mixed deciduous/evergreen forest</td>
      <td>19.0</td>
      <td>1.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vJ</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20201223T141711Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>1066</th>
      <td>bfffacc8-c05d-471f-b875-c16b94d70614</td>
      <td>HARV_014.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_014</td>
      <td>distributed</td>
      <td>B3</td>
      <td>mixedForest</td>
      <td>42.471348</td>
      <td>-72.265421</td>
      <td>...</td>
      <td>65.0</td>
      <td>mixed deciduous/evergreen forest</td>
      <td>19.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vJ</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20201223T141711Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>1067</th>
      <td>9276572a-772c-4785-9a9f-2f1a71b950bf</td>
      <td>HARV_014.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_014</td>
      <td>distributed</td>
      <td>C3</td>
      <td>mixedForest</td>
      <td>42.471348</td>
      <td>-72.265421</td>
      <td>...</td>
      <td>65.0</td>
      <td>mixed deciduous/evergreen forest</td>
      <td>18.0</td>
      <td>1.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vJ</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20201223T141711Z</td>
      <td>PROVISIONAL</td>
    </tr>
  </tbody>
</table>
<p>1068 rows × 31 columns</p>
</div>




```python
brd_countdata
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>uid</th>
      <th>namedLocation</th>
      <th>domainID</th>
      <th>siteID</th>
      <th>plotID</th>
      <th>plotType</th>
      <th>pointID</th>
      <th>startDate</th>
      <th>eventID</th>
      <th>pointCountMinute</th>
      <th>...</th>
      <th>vernacularName</th>
      <th>observerDistance</th>
      <th>detectionMethod</th>
      <th>visualConfirmation</th>
      <th>sexOrAge</th>
      <th>clusterSize</th>
      <th>clusterCode</th>
      <th>identifiedBy</th>
      <th>publicationDate</th>
      <th>release</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>78603d80-3f06-4b56-adbb-a524b1f46da5</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09:23Z</td>
      <td>BART_025.C1.2015-06-14T05:23-04:00[US/Eastern]</td>
      <td>2</td>
      <td>...</td>
      <td>Black-and-white Warbler</td>
      <td>17.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Male</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20201223T141730Z</td>
      <td>RELEASE-2021</td>
    </tr>
    <tr>
      <th>1</th>
      <td>35009b65-f5cb-4d61-82f1-7048f94e788a</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09:23Z</td>
      <td>BART_025.C1.2015-06-14T05:23-04:00[US/Eastern]</td>
      <td>1</td>
      <td>...</td>
      <td>Red-eyed Vireo</td>
      <td>9.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Male</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20201223T141730Z</td>
      <td>RELEASE-2021</td>
    </tr>
    <tr>
      <th>2</th>
      <td>b4c6f95a-5ef3-4d84-8222-0dece7870f29</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09:23Z</td>
      <td>BART_025.C1.2015-06-14T05:23-04:00[US/Eastern]</td>
      <td>1</td>
      <td>...</td>
      <td>Black-capped Chickadee</td>
      <td>42.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Male</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20201223T141730Z</td>
      <td>RELEASE-2021</td>
    </tr>
    <tr>
      <th>3</th>
      <td>61e3dcf6-48ae-48c5-9fc9-5f387d7edd56</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09:23Z</td>
      <td>BART_025.C1.2015-06-14T05:23-04:00[US/Eastern]</td>
      <td>2</td>
      <td>...</td>
      <td>Black-throated Green Warbler</td>
      <td>50.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Male</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20201223T141730Z</td>
      <td>RELEASE-2021</td>
    </tr>
    <tr>
      <th>4</th>
      <td>562a36b4-3b1c-4888-9050-57a36eb67af8</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09:23Z</td>
      <td>BART_025.C1.2015-06-14T05:23-04:00[US/Eastern]</td>
      <td>1</td>
      <td>...</td>
      <td>Black-throated Green Warbler</td>
      <td>12.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Male</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20201223T141730Z</td>
      <td>RELEASE-2021</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>10876</th>
      <td>6958df8b-a322-4344-9338-4048400394d5</td>
      <td>HARV_014.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_014</td>
      <td>distributed</td>
      <td>C3</td>
      <td>2020-06-14T14:10Z</td>
      <td>HARV_014.C3.2020-06-14T10:10-04:00[US/Eastern]</td>
      <td>5</td>
      <td>...</td>
      <td>Black-throated Green Warbler</td>
      <td>73.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20201223T141711Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>10877</th>
      <td>e2aee01d-98b1-4d33-846f-51b0535503b6</td>
      <td>HARV_014.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_014</td>
      <td>distributed</td>
      <td>C3</td>
      <td>2020-06-14T14:10Z</td>
      <td>HARV_014.C3.2020-06-14T10:10-04:00[US/Eastern]</td>
      <td>4</td>
      <td>...</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20201223T141711Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>10878</th>
      <td>c7a36a67-49a1-44d2-bfb1-ccfdd3b89009</td>
      <td>HARV_014.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_014</td>
      <td>distributed</td>
      <td>C3</td>
      <td>2020-06-14T14:10Z</td>
      <td>HARV_014.C3.2020-06-14T10:10-04:00[US/Eastern]</td>
      <td>6</td>
      <td>...</td>
      <td>Ruffed Grouse</td>
      <td>140.0</td>
      <td>drumming</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20201223T141711Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>10879</th>
      <td>e1f0940b-cf87-435a-b72a-efbb7fbd2274</td>
      <td>HARV_014.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_014</td>
      <td>distributed</td>
      <td>C3</td>
      <td>2020-06-14T14:10Z</td>
      <td>HARV_014.C3.2020-06-14T10:10-04:00[US/Eastern]</td>
      <td>6</td>
      <td>...</td>
      <td>Ovenbird</td>
      <td>70.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20201223T141711Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>10880</th>
      <td>78316131-33cb-42e6-b0f9-7d3b0a82f071</td>
      <td>HARV_014.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_014</td>
      <td>distributed</td>
      <td>C3</td>
      <td>2020-06-14T14:10Z</td>
      <td>HARV_014.C3.2020-06-14T10:10-04:00[US/Eastern]</td>
      <td>2</td>
      <td>...</td>
      <td>Ovenbird</td>
      <td>64.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20201223T141711Z</td>
      <td>PROVISIONAL</td>
    </tr>
  </tbody>
</table>
<p>10881 rows × 24 columns</p>
</div>



And now let's do the same with the 30-minute data table for biological 
temperature.


```python
IRBT30 = pandas.read_csv('/Users/olearyd/Downloads/NEON_temp-bio/stackedFiles/IRBT_30_minute.csv')
IRBT30
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>domainID</th>
      <th>siteID</th>
      <th>horizontalPosition</th>
      <th>verticalPosition</th>
      <th>startDateTime</th>
      <th>endDateTime</th>
      <th>bioTempMean</th>
      <th>bioTempMinimum</th>
      <th>bioTempMaximum</th>
      <th>bioTempVariance</th>
      <th>bioTempNumPts</th>
      <th>bioTempExpUncert</th>
      <th>bioTempStdErMean</th>
      <th>finalQF</th>
      <th>publicationDate</th>
      <th>release</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>D16</td>
      <td>ABBY</td>
      <td>0</td>
      <td>10</td>
      <td>2021-03-01T00:00:00Z</td>
      <td>2021-03-01T00:30:00Z</td>
      <td>9.29</td>
      <td>8.47</td>
      <td>9.76</td>
      <td>0.15</td>
      <td>1800.0</td>
      <td>0.52</td>
      <td>0.01</td>
      <td>0</td>
      <td>20210404T194243Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>1</th>
      <td>D16</td>
      <td>ABBY</td>
      <td>0</td>
      <td>10</td>
      <td>2021-03-01T00:30:00Z</td>
      <td>2021-03-01T01:00:00Z</td>
      <td>7.90</td>
      <td>7.23</td>
      <td>8.59</td>
      <td>0.13</td>
      <td>1800.0</td>
      <td>0.52</td>
      <td>0.01</td>
      <td>0</td>
      <td>20210404T194243Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>2</th>
      <td>D16</td>
      <td>ABBY</td>
      <td>0</td>
      <td>10</td>
      <td>2021-03-01T01:00:00Z</td>
      <td>2021-03-01T01:30:00Z</td>
      <td>7.08</td>
      <td>6.86</td>
      <td>7.27</td>
      <td>0.01</td>
      <td>1800.0</td>
      <td>0.52</td>
      <td>0.00</td>
      <td>0</td>
      <td>20210404T194243Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>3</th>
      <td>D16</td>
      <td>ABBY</td>
      <td>0</td>
      <td>10</td>
      <td>2021-03-01T01:30:00Z</td>
      <td>2021-03-01T02:00:00Z</td>
      <td>6.50</td>
      <td>5.95</td>
      <td>6.89</td>
      <td>0.07</td>
      <td>1800.0</td>
      <td>0.52</td>
      <td>0.01</td>
      <td>0</td>
      <td>20210404T194243Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>4</th>
      <td>D16</td>
      <td>ABBY</td>
      <td>0</td>
      <td>10</td>
      <td>2021-03-01T02:00:00Z</td>
      <td>2021-03-01T02:30:00Z</td>
      <td>5.35</td>
      <td>4.98</td>
      <td>5.96</td>
      <td>0.08</td>
      <td>1800.0</td>
      <td>0.52</td>
      <td>0.01</td>
      <td>0</td>
      <td>20210404T194243Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>5947</th>
      <td>D16</td>
      <td>ABBY</td>
      <td>3</td>
      <td>0</td>
      <td>2021-03-31T21:30:00Z</td>
      <td>2021-03-31T22:00:00Z</td>
      <td>13.93</td>
      <td>13.45</td>
      <td>14.27</td>
      <td>0.02</td>
      <td>1800.0</td>
      <td>0.65</td>
      <td>0.00</td>
      <td>0</td>
      <td>20210404T194243Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>5948</th>
      <td>D16</td>
      <td>ABBY</td>
      <td>3</td>
      <td>0</td>
      <td>2021-03-31T22:00:00Z</td>
      <td>2021-03-31T22:30:00Z</td>
      <td>13.85</td>
      <td>13.57</td>
      <td>14.15</td>
      <td>0.01</td>
      <td>1800.0</td>
      <td>0.65</td>
      <td>0.00</td>
      <td>0</td>
      <td>20210404T194243Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>5949</th>
      <td>D16</td>
      <td>ABBY</td>
      <td>3</td>
      <td>0</td>
      <td>2021-03-31T22:30:00Z</td>
      <td>2021-03-31T23:00:00Z</td>
      <td>14.08</td>
      <td>13.57</td>
      <td>14.36</td>
      <td>0.03</td>
      <td>1800.0</td>
      <td>0.65</td>
      <td>0.00</td>
      <td>0</td>
      <td>20210404T194243Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>5950</th>
      <td>D16</td>
      <td>ABBY</td>
      <td>3</td>
      <td>0</td>
      <td>2021-03-31T23:00:00Z</td>
      <td>2021-03-31T23:30:00Z</td>
      <td>14.01</td>
      <td>13.67</td>
      <td>14.22</td>
      <td>0.01</td>
      <td>1800.0</td>
      <td>0.65</td>
      <td>0.00</td>
      <td>0</td>
      <td>20210404T194243Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <th>5951</th>
      <td>D16</td>
      <td>ABBY</td>
      <td>3</td>
      <td>0</td>
      <td>2021-03-31T23:30:00Z</td>
      <td>2021-04-01T00:00:00Z</td>
      <td>13.92</td>
      <td>13.53</td>
      <td>14.25</td>
      <td>0.02</td>
      <td>1800.0</td>
      <td>0.65</td>
      <td>0.00</td>
      <td>0</td>
      <td>20210404T194243Z</td>
      <td>PROVISIONAL</td>
    </tr>
  </tbody>
</table>
<p>5952 rows × 16 columns</p>
</div>



## Download remote sensing files: byFileAOP()

The function `byFileAOP()` uses the <a href="http://data.neonscience.org/data-api" target="_blank">NEON API</a> 
to programmatically download data files for remote sensing (AOP) data 
products. These files cannot be stacked by `stackByTable()` because they 
are not tabular data. The function simply creates a folder in your working 
directory and writes the files there. It preserves the folder structure 
for the subproducts.

The inputs to `byFileAOP()` are a data product ID, a site, a year, 
a filepath to save to, and an indicator to check the size of the 
download before proceeding, or not. As above, set check_size="FALSE" 
when working in Python. Be especially cautious about download size 
when downloading AOP data, since the files are very large.

Here, we'll download Ecosystem structure (Canopy Height Model) data from 
Hopbrook (HOPB) in 2017.


```python
neonUtilities.byFileAOP(dpID='DP3.30015.001', site='HOPB',
                        #easting = 718000, northing = 4709000,
                        year='2017', check_size='FALSE',
                       savepath='~/Downloads');
```

    Downloading files totaling approximately 147.800996 MB 
    
    Downloading 213 files
    
      |                                                                            
      |                                                                      |   0%
      |                                                                            
      |=                                                                     |   1%
      |                                                                            
      |=                                                                     |   2%
      |                                                                            
      |==                                                                    |   2%
      |                                                                            
      |==                                                                    |   3%
      |                                                                            
      |===                                                                   |   4%
      |                                                                            
      |===                                                                   |   5%
      |                                                                            
      |====                                                                  |   5%
      |                                                                            
      |====                                                                  |   6%
      |                                                                            
      |=====                                                                 |   7%
      |                                                                            
      |=====                                                                 |   8%
      |                                                                            
      |======                                                                |   8%
      |                                                                            
      |======                                                                |   9%
      |                                                                            
      |=======                                                               |   9%
      |                                                                            
      |=======                                                               |  10%
      |                                                                            
      |========                                                              |  11%
      |                                                                            
      |========                                                              |  12%
      |                                                                            
      |=========                                                             |  12%
      |                                                                            
      |=========                                                             |  13%
      |                                                                            
      |==========                                                            |  14%
      |                                                                            
      |==========                                                            |  15%
      |                                                                            
      |===========                                                           |  15%
      |                                                                            
      |===========                                                           |  16%
      |                                                                            
      |============                                                          |  17%
      |                                                                            
      |=============                                                         |  18%
      |                                                                            
      |=============                                                         |  19%
      |                                                                            
      |==============                                                        |  19%
      |                                                                            
      |==============                                                        |  20%
      |                                                                            
      |===============                                                       |  21%
      |                                                                            
      |===============                                                       |  22%
      |                                                                            
      |================                                                      |  22%
      |                                                                            
      |================                                                      |  23%
      |                                                                            
      |=================                                                     |  24%
      |                                                                            
      |=================                                                     |  25%
      |                                                                            
      |==================                                                    |  25%
      |                                                                            
      |==================                                                    |  26%
      |                                                                            
      |===================                                                   |  27%
      |                                                                            
      |===================                                                   |  28%
      |                                                                            
      |====================                                                  |  28%
      |                                                                            
      |====================                                                  |  29%
      |                                                                            
      |=====================                                                 |  30%
      |                                                                            
      |=====================                                                 |  31%
      |                                                                            
      |======================                                                |  31%
      |                                                                            
      |======================                                                |  32%
      |                                                                            
      |=======================                                               |  33%
      |                                                                            
      |========================                                              |  34%
      |                                                                            
      |========================                                              |  35%
      |                                                                            
      |=========================                                             |  35%
      |                                                                            
      |=========================                                             |  36%
      |                                                                            
      |==========================                                            |  37%
      |                                                                            
      |==========================                                            |  38%
      |                                                                            
      |===========================                                           |  38%
      |                                                                            
      |===========================                                           |  39%
      |                                                                            
      |============================                                          |  40%
      |                                                                            
      |============================                                          |  41%
      |                                                                            
      |=============================                                         |  41%
      |                                                                            
      |=============================                                         |  42%
      |                                                                            
      |==============================                                        |  42%
      |                                                                            
      |==============================                                        |  43%
      |                                                                            
      |===============================                                       |  44%
      |                                                                            
      |===============================                                       |  45%
      |                                                                            
      |================================                                      |  45%
      |                                                                            
      |================================                                      |  46%
      |                                                                            
      |=================================                                     |  47%
      |                                                                            
      |=================================                                     |  48%
      |                                                                            
      |==================================                                    |  48%
      |                                                                            
      |==================================                                    |  49%
      |                                                                            
      |===================================                                   |  50%
      |                                                                            
      |====================================                                  |  51%
      |                                                                            
      |====================================                                  |  52%
      |                                                                            
      |=====================================                                 |  52%
      |                                                                            
      |=====================================                                 |  53%
      |                                                                            
      |======================================                                |  54%
      |                                                                            
      |======================================                                |  55%
      |                                                                            
      |=======================================                               |  55%
      |                                                                            
      |=======================================                               |  56%
      |                                                                            
      |========================================                              |  57%
      |                                                                            
      |========================================                              |  58%
      |                                                                            
      |=========================================                             |  58%
      |                                                                            
      |=========================================                             |  59%
      |                                                                            
      |==========================================                            |  59%
      |                                                                            
      |==========================================                            |  60%
      |                                                                            
      |===========================================                           |  61%
      |                                                                            
      |===========================================                           |  62%
      |                                                                            
      |============================================                          |  62%
      |                                                                            
      |============================================                          |  63%
      |                                                                            
      |=============================================                         |  64%
      |                                                                            
      |=============================================                         |  65%
      |                                                                            
      |==============================================                        |  65%
      |                                                                            
      |==============================================                        |  66%
      |                                                                            
      |===============================================                       |  67%
      |                                                                            
      |================================================                      |  68%
      |                                                                            
      |================================================                      |  69%
      |                                                                            
      |=================================================                     |  69%
      |                                                                            
      |=================================================                     |  70%
      |                                                                            
      |==================================================                    |  71%
      |                                                                            
      |==================================================                    |  72%
      |                                                                            
      |===================================================                   |  72%
      |                                                                            
      |===================================================                   |  73%
      |                                                                            
      |====================================================                  |  74%
      |                                                                            
      |====================================================                  |  75%
      |                                                                            
      |=====================================================                 |  75%
      |                                                                            
      |=====================================================                 |  76%
      |                                                                            
      |======================================================                |  77%
      |                                                                            
      |======================================================                |  78%
      |                                                                            
      |=======================================================               |  78%
      |                                                                            
      |=======================================================               |  79%
      |                                                                            
      |========================================================              |  80%
      |                                                                            
      |========================================================              |  81%
      |                                                                            
      |=========================================================             |  81%
      |                                                                            
      |=========================================================             |  82%
      |                                                                            
      |==========================================================            |  83%
      |                                                                            
      |===========================================================           |  84%
      |                                                                            
      |===========================================================           |  85%
      |                                                                            
      |============================================================          |  85%
      |                                                                            
      |============================================================          |  86%
      |                                                                            
      |=============================================================         |  87%
      |                                                                            
      |=============================================================         |  88%
      |                                                                            
      |==============================================================        |  88%
      |                                                                            
      |==============================================================        |  89%
      |                                                                            
      |===============================================================       |  90%
      |                                                                            
      |===============================================================       |  91%
      |                                                                            
      |================================================================      |  91%
      |                                                                            
      |================================================================      |  92%
      |                                                                            
      |=================================================================     |  92%
      |                                                                            
      |=================================================================     |  93%
      |                                                                            
      |==================================================================    |  94%
      |                                                                            
      |==================================================================    |  95%
      |                                                                            
      |===================================================================   |  95%
      |                                                                            
      |===================================================================   |  96%
      |                                                                            
      |====================================================================  |  97%
      |                                                                            
      |====================================================================  |  98%
      |                                                                            
      |===================================================================== |  98%
      |                                                                            
      |===================================================================== |  99%
      |                                                                            
      |======================================================================| 100%
    
    
    Successfully downloaded  213  files.
    
    NEON_D01_HOPB_DP1_720000_4704000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4705000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4706000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4706000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4705000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_717000_4707000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4706000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4707000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4705000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4706000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_718000_4705000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4710000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_718000_4706000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_720000_4710000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4704000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_717000_4704000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_717000_4708000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4705000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4709000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4710000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4708000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4708000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4705000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_717000_4707000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_720000_4707000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4708000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4707000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4704000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_718000_4707000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4704000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4707000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4709000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4706000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_718000_4709000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4706000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4706000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4706000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4706000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4710000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4708000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4707000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4706000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4710000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4709000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4704000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_719000_4706000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4705000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4709000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4705000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4707000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_720000_4709000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4710000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4706000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4710000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4704000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4709000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_720000_4707000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4704000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4710000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_717000_4706000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_720000_4705000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_719000_4707000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4710000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4710000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4704000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4705000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4708000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4710000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_718000_4707000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4708000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4706000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_718000_4705000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4704000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4709000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4704000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4706000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4707000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4710000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4710000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4709000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4704000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4705000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4707000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4708000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4705000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4710000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4708000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4708000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4708000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4710000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4709000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4704000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4709000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4707000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4707000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_718000_4704000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_718000_4704000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4707000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4704000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4710000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4706000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_719000_4705000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4706000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4709000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4704000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_717000_4710000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4709000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4705000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4709000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4705000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4707000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4707000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4706000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4708000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4708000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_718000_4710000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4704000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4710000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4708000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4708000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4707000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4706000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_718000_4708000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4710000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON.D01.HOPB.DP3.30015.001.readme.20210123T023002Z.txt downloaded to ~/Downloads/DP3.30015.001/release/tag/RELEASE-2021/NEON.DOM.SITE.DP3.30015.001/HOPB/20170801T000000--20170901T000000/basic
    NEON_D01_HOPB_DP1_719000_4708000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4707000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_718000_4705000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4704000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4706000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_717000_4708000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_717000_4710000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4705000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4708000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4708000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_719000_4704000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_719000_4708000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4704000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4706000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4708000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4710000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4709000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4709000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    2017_HOPB_2_L3_discrete_lidar_processing.pdf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/Reports
    NEON_D01_HOPB_DP1_717000_4710000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4710000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4704000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4705000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4709000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_719000_4709000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_718000_4704000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4705000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4704000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4709000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4706000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_718000_4709000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_717000_4708000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_718000_4706000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_720000_4706000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_719000_4710000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_717000_4707000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4707000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_718000_4708000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4705000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4706000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_720000_4705000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4708000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4707000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4709000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4709000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4709000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4708000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_720000_4705000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4707000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4709000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4707000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4709000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4707000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4708000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4704000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4709000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4709000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4704000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4709000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4705000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4707000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_717000_4709000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_718000_4710000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_717000_4706000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4706000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4706000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4705000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4708000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4705000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4707000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4704000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4708000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4710000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4704000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4707000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4704000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_718000_4705000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4705000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4705000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    2017_HOPB_2_V01_LMS_QAQC.pdf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/Reports
    NEON_D01_HOPB_DP1_716000_4710000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4706000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4709000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_717000_4705000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_720000_4704000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4710000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4708000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4710000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    


Let's read one tile of data into Python and view it. We'll use the 
`rasterio` and `matplotlib` modules here, but as with tabular data, 
there are other options available.


```python
import rasterio
CHMtile = rasterio.open('/Users/olearyd/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D01_HOPB_DP3_718000_4709000_CHM.tif')
```


```python
import matplotlib.pyplot as plt
from rasterio.plot import show
fig, ax = plt.subplots(figsize = (8,3))
show(CHMtile)
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/NEON-general/neon-code-packages/neonUtilitiesPython/neonUtilitiesPython_files/neonUtilitiesPython_40_0.png)





    <matplotlib.axes._subplots.AxesSubplot at 0x7ff3a3757510>




```python

```
