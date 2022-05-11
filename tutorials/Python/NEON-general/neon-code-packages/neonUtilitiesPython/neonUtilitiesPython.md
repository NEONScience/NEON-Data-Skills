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
you want to do your analyses in R, use one of the R-based tutorials linked 
below.

For more information about the `neonUtilities` package, and instructions for 
running it in R directly, see the <a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore</a> tutorial 
and/or the <a href="http://www.neonscience.org/neonDataStackR" target="_blank">neonUtilities tutorial</a>.


## Install and set up

Before starting, you will need:

1. Python 3 installed. It is probably possible to use this workflow in Python 2, 
but these instructions were developed and tested using 3.7.4.
2. R installed. You don't need to have ever used it directly. We wrote this 
tutorial using R 4.1.1, but most other recent versions should also work.
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

### Additional troubleshooting

If you're still having trouble getting R to communicate with Python, you can try 
pointing Python directly to your R installation path.

1. Run `R.home()` in R.
2. Run `import os` in Python.
3. Run `os.environ['R_HOME'] = '/Library/Frameworks/R.framework/Resources'` in Python, substituting the file path you found in step 1.

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
    -0.938409
    </td>

    <td>
    0.189041
    </td>

    <td>
    -0.169062
    </td>

    <td>
    0.976939
    </td>

    <td>
    -0.862790
    </td>

    <td>
    0.648383
    </td>

  </tr>
</tbody>
</table>




Suppress R warnings. This step can be skipped, but will result in messages 
getting passed through from R that Python will interpret as warnings.


```python
from rpy2.rinterface_lib.callbacks import logger as rpy2_logger
import logging
rpy2_logger.setLevel(logging.ERROR)
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

    
    The downloaded binary packages are in
    	/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T//Rtmpdy9fY1/downloaded_packages


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
Modify the file path in the code below to match the path on your machine.

For additional, optional inputs to `stackByTable()`, see the <a href="http://neonscience.org/neonDataStackR" target="_blank">R tutorial</a> 
for neonUtilities.


```python
neonUtilities.stackByTable(filepath='/Users/Shared/NEON_temp-bio.zip');
```

    Stacking operation across a single core.
    Stacking table IRBT_1_minute
    Stacking table IRBT_30_minute
    Merged the most recent publication of sensor position files for each site and saved to /stackedFiles
    Copied the most recent publication of variable definition file to /stackedFiles
    Finished: Stacked 2 data tables and 3 metadata tables!
    Stacking took 1.585054 secs
    All unzipped monthly data folders have been removed.


Check the folder containing the original zip file from the Data Portal; 
you should now have a subfolder containing the unzipped and stacked files 
called `stackedFiles`. To import these data to Python, skip ahead to the 
"Read downloaded and stacked files into Python" section; to learn how to 
use `neonUtilities` to download data, proceed to the next section.

## Download files to be stacked: zipsByProduct()

The function `zipsByProduct()` uses the <a href="http://data.neonscience.org/data-api" target="_blank">NEON API</a> to programmatically download 
data files for a given product. The files downloaded by `zipsByProduct()` 
can then be fed into `stackByTable()`.

Run the downloader with these inputs: a data product ID (DPID), a set of 
4-letter site IDs (or "all" for all sites), a download package (either 
basic or expanded), the filepath to download the data to, and an 
indicator to check the size of your download before proceeding or not 
(TRUE/FALSE).

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
                            savepath='/Users/Shared',
                            package='basic', 
                            check_size='FALSE');
```

    Finding available files
      |======================================================================| 100%
    
    Downloading files totaling approximately 3.718684 MB
    Downloading 16 files
      |======================================================================| 100%
    16 files successfully downloaded to /Users/Shared/filesToStack10003


The message output by `zipsByProduct()` indicates the file path where the 
files have been downloaded.

Now take that file path and pass it to `stackByTable()`.


```python
neonUtilities.stackByTable(filepath='/Users/Shared/filesToStack10003');
```

    Unpacking zip files using 1 cores.
    Stacking operation across a single core.
    Stacking table brd_countdata
    Stacking table brd_perpoint
    Copied the most recent publication of validation file to /stackedFiles
    Copied the most recent publication of categoricalCodes file to /stackedFiles
    Copied the most recent publication of variable definition file to /stackedFiles
    Finished: Stacked 2 data tables and 4 metadata tables!
    Stacking took 0.3076231 secs
    All unzipped monthly data folders have been removed.


## Read downloaded and stacked files into Python

We've downloaded biological temperature and bird data, and merged 
the site by month files. Now let's read those data into Python so you 
can proceed with analyses.

First let's take a look at what's in the output folders.


```python
import os
os.listdir('/Users/Shared/filesToStack10003/stackedFiles/')
```




    ['categoricalCodes_10003.csv',
     'issueLog_10003.csv',
     'brd_countdata.csv',
     'brd_perpoint.csv',
     'readme_10003.txt',
     'variables_10003.csv',
     'validation_10003.csv']




```python
os.listdir('/Users/Shared/NEON_temp-bio/stackedFiles/')
```




    ['IRBT_1_minute.csv',
     'sensor_positions_00005.csv',
     'issueLog_00005.csv',
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
brd_perpoint = pandas.read_csv('/Users/Shared/filesToStack10003/stackedFiles/brd_perpoint.csv')
brd_countdata = pandas.read_csv('/Users/Shared/filesToStack10003/stackedFiles/brd_countdata.csv')
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
      <td>0</td>
      <td>32ab1419-b087-47e1-829d-b1a67a223a01</td>
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
      <td>20211222T013942Z</td>
      <td>RELEASE-2022</td>
    </tr>
    <tr>
      <td>1</td>
      <td>f02e2458-caab-44d8-a21a-b3b210b71006</td>
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
      <td>20211222T013942Z</td>
      <td>RELEASE-2022</td>
    </tr>
    <tr>
      <td>2</td>
      <td>58ccefb8-7904-4aa6-8447-d6f6590ccdae</td>
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
      <td>20211222T013942Z</td>
      <td>RELEASE-2022</td>
    </tr>
    <tr>
      <td>3</td>
      <td>1b14ead4-03fc-4d47-bd00-2f6e31cfe971</td>
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
      <td>20211222T013942Z</td>
      <td>RELEASE-2022</td>
    </tr>
    <tr>
      <td>4</td>
      <td>3055a0a5-57ae-4e56-9415-eeb7704fab02</td>
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
      <td>20211222T013942Z</td>
      <td>RELEASE-2022</td>
    </tr>
    <tr>
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
      <td>...</td>
    </tr>
    <tr>
      <td>1234</td>
      <td>3400dfdf-54f1-4921-a3b0-61f03c6db3e9</td>
      <td>HARV_006.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_006</td>
      <td>distributed</td>
      <td>A1</td>
      <td>deciduousForest</td>
      <td>42.401149</td>
      <td>-72.253238</td>
      <td>...</td>
      <td>43.0</td>
      <td>other</td>
      <td>16.0</td>
      <td>10.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vK</td>
      <td>The RH would not stay still today, kept swingi...</td>
      <td>JGLAG</td>
      <td>20211222T011332Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>1235</td>
      <td>b43b199c-51b6-4222-b575-7564315e47bb</td>
      <td>HARV_006.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_006</td>
      <td>distributed</td>
      <td>A2</td>
      <td>deciduousForest</td>
      <td>42.401149</td>
      <td>-72.253238</td>
      <td>...</td>
      <td>43.0</td>
      <td>deciduous forest</td>
      <td>15.0</td>
      <td>4.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vK</td>
      <td>The RH would not stay still today, kept swingi...</td>
      <td>JGLAG</td>
      <td>20211222T011332Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>1236</td>
      <td>a7040ad5-d253-47b7-964d-2711dafa42c4</td>
      <td>HARV_006.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_006</td>
      <td>distributed</td>
      <td>B2</td>
      <td>deciduousForest</td>
      <td>42.401149</td>
      <td>-72.253238</td>
      <td>...</td>
      <td>43.0</td>
      <td>deciduous forest</td>
      <td>16.0</td>
      <td>1.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vK</td>
      <td>The RH would not stay still today, kept swingi...</td>
      <td>JGLAG</td>
      <td>20211222T011332Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>1237</td>
      <td>97a3c2dc-d8b0-436f-af62-00c88167b60e</td>
      <td>HARV_006.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_006</td>
      <td>distributed</td>
      <td>B3</td>
      <td>deciduousForest</td>
      <td>42.401149</td>
      <td>-72.253238</td>
      <td>...</td>
      <td>43.0</td>
      <td>deciduous forest</td>
      <td>17.0</td>
      <td>1.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vK</td>
      <td>The RH would not stay still today, kept swingi...</td>
      <td>JGLAG</td>
      <td>20211222T011332Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>1238</td>
      <td>b8a27ff5-3aa3-432a-858e-c8d31324ab2e</td>
      <td>HARV_006.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_006</td>
      <td>distributed</td>
      <td>A3</td>
      <td>deciduousForest</td>
      <td>42.401149</td>
      <td>-72.253238</td>
      <td>...</td>
      <td>43.0</td>
      <td>deciduous forest</td>
      <td>18.0</td>
      <td>1.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vK</td>
      <td>The RH would not stay still today, kept swingi...</td>
      <td>JGLAG</td>
      <td>20211222T011332Z</td>
      <td>PROVISIONAL</td>
    </tr>
  </tbody>
</table>
<p>1239 rows × 31 columns</p>
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
      <td>0</td>
      <td>4e22256f-5e86-4a2c-99be-dd1c7da7af28</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09:23Z</td>
      <td>BART_025.C1.2015-06-14</td>
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
      <td>20211222T013942Z</td>
      <td>RELEASE-2022</td>
    </tr>
    <tr>
      <td>1</td>
      <td>93106c0d-06d8-4816-9892-15c99de03c91</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09:23Z</td>
      <td>BART_025.C1.2015-06-14</td>
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
      <td>20211222T013942Z</td>
      <td>RELEASE-2022</td>
    </tr>
    <tr>
      <td>2</td>
      <td>5eb23904-9ae9-45bf-af27-a4fa1efd4e8a</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09:23Z</td>
      <td>BART_025.C1.2015-06-14</td>
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
      <td>20211222T013942Z</td>
      <td>RELEASE-2022</td>
    </tr>
    <tr>
      <td>3</td>
      <td>99592c6c-4cf7-4de8-9502-b321e925684d</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09:23Z</td>
      <td>BART_025.C1.2015-06-14</td>
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
      <td>20211222T013942Z</td>
      <td>RELEASE-2022</td>
    </tr>
    <tr>
      <td>4</td>
      <td>6c07d9fb-8813-452b-8182-3bc5e139d920</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09:23Z</td>
      <td>BART_025.C1.2015-06-14</td>
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
      <td>20211222T013942Z</td>
      <td>RELEASE-2022</td>
    </tr>
    <tr>
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
      <td>...</td>
    </tr>
    <tr>
      <td>13579</td>
      <td>87c9dae4-ee30-4673-b669-5ca8acdc7bd7</td>
      <td>HARV_006.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_006</td>
      <td>distributed</td>
      <td>A3</td>
      <td>2021-06-16T13:08Z</td>
      <td>HARV_006.A3.2021-06-16</td>
      <td>1</td>
      <td>...</td>
      <td>Eastern Towhee</td>
      <td>13.0</td>
      <td>calling</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JGLAG</td>
      <td>20211222T011332Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>13580</td>
      <td>1a65553a-6189-4c74-a1e3-2ada0f1d9f63</td>
      <td>HARV_006.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_006</td>
      <td>distributed</td>
      <td>A3</td>
      <td>2021-06-16T13:08Z</td>
      <td>HARV_006.A3.2021-06-16</td>
      <td>4</td>
      <td>...</td>
      <td>NaN</td>
      <td>20.0</td>
      <td>visual</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JGLAG</td>
      <td>20211222T011332Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>13581</td>
      <td>e33deb1c-e79d-41dc-8fc1-8e984b9d0450</td>
      <td>HARV_006.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_006</td>
      <td>distributed</td>
      <td>A3</td>
      <td>2021-06-16T13:08Z</td>
      <td>HARV_006.A3.2021-06-16</td>
      <td>1</td>
      <td>...</td>
      <td>Eastern Towhee</td>
      <td>48.0</td>
      <td>calling</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JGLAG</td>
      <td>20211222T011332Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>13582</td>
      <td>070ec577-9aec-4d05-91df-86124d383697</td>
      <td>HARV_006.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_006</td>
      <td>distributed</td>
      <td>A3</td>
      <td>2021-06-16T13:08Z</td>
      <td>HARV_006.A3.2021-06-16</td>
      <td>1</td>
      <td>...</td>
      <td>Eastern Towhee</td>
      <td>61.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JGLAG</td>
      <td>20211222T011332Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>13583</td>
      <td>7a3be1a1-03c3-49e7-a486-343708c3b271</td>
      <td>HARV_006.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_006</td>
      <td>distributed</td>
      <td>A3</td>
      <td>2021-06-16T13:08Z</td>
      <td>HARV_006.A3.2021-06-16</td>
      <td>2</td>
      <td>...</td>
      <td>Veery</td>
      <td>64.0</td>
      <td>calling</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JGLAG</td>
      <td>20211222T011332Z</td>
      <td>PROVISIONAL</td>
    </tr>
  </tbody>
</table>
<p>13584 rows × 24 columns</p>
</div>



And now let's do the same with the 30-minute data table for biological 
temperature.


```python
IRBT30 = pandas.read_csv('/Users/Shared/NEON_temp-bio/stackedFiles/IRBT_30_minute.csv')
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
      <td>0</td>
      <td>D18</td>
      <td>BARR</td>
      <td>0</td>
      <td>10</td>
      <td>2021-09-01T00:00:00Z</td>
      <td>2021-09-01T00:30:00Z</td>
      <td>7.82</td>
      <td>7.43</td>
      <td>8.39</td>
      <td>0.03</td>
      <td>1800.0</td>
      <td>0.60</td>
      <td>0.00</td>
      <td>0</td>
      <td>20211219T025212Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>1</td>
      <td>D18</td>
      <td>BARR</td>
      <td>0</td>
      <td>10</td>
      <td>2021-09-01T00:30:00Z</td>
      <td>2021-09-01T01:00:00Z</td>
      <td>7.47</td>
      <td>7.16</td>
      <td>7.75</td>
      <td>0.01</td>
      <td>1800.0</td>
      <td>0.60</td>
      <td>0.00</td>
      <td>0</td>
      <td>20211219T025212Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>2</td>
      <td>D18</td>
      <td>BARR</td>
      <td>0</td>
      <td>10</td>
      <td>2021-09-01T01:00:00Z</td>
      <td>2021-09-01T01:30:00Z</td>
      <td>7.43</td>
      <td>6.89</td>
      <td>8.11</td>
      <td>0.07</td>
      <td>1800.0</td>
      <td>0.60</td>
      <td>0.01</td>
      <td>0</td>
      <td>20211219T025212Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>3</td>
      <td>D18</td>
      <td>BARR</td>
      <td>0</td>
      <td>10</td>
      <td>2021-09-01T01:30:00Z</td>
      <td>2021-09-01T02:00:00Z</td>
      <td>7.36</td>
      <td>6.78</td>
      <td>8.15</td>
      <td>0.06</td>
      <td>1800.0</td>
      <td>0.60</td>
      <td>0.01</td>
      <td>0</td>
      <td>20211219T025212Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>4</td>
      <td>D18</td>
      <td>BARR</td>
      <td>0</td>
      <td>10</td>
      <td>2021-09-01T02:00:00Z</td>
      <td>2021-09-01T02:30:00Z</td>
      <td>6.91</td>
      <td>6.50</td>
      <td>7.27</td>
      <td>0.03</td>
      <td>1800.0</td>
      <td>0.60</td>
      <td>0.00</td>
      <td>0</td>
      <td>20211219T025212Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
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
      <td>13099</td>
      <td>D18</td>
      <td>BARR</td>
      <td>3</td>
      <td>0</td>
      <td>2021-11-30T21:30:00Z</td>
      <td>2021-11-30T22:00:00Z</td>
      <td>-14.62</td>
      <td>-14.78</td>
      <td>-14.46</td>
      <td>0.00</td>
      <td>1800.0</td>
      <td>0.57</td>
      <td>0.00</td>
      <td>0</td>
      <td>20211206T221914Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>13100</td>
      <td>D18</td>
      <td>BARR</td>
      <td>3</td>
      <td>0</td>
      <td>2021-11-30T22:00:00Z</td>
      <td>2021-11-30T22:30:00Z</td>
      <td>-14.59</td>
      <td>-14.72</td>
      <td>-14.50</td>
      <td>0.00</td>
      <td>1800.0</td>
      <td>0.57</td>
      <td>0.00</td>
      <td>0</td>
      <td>20211206T221914Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>13101</td>
      <td>D18</td>
      <td>BARR</td>
      <td>3</td>
      <td>0</td>
      <td>2021-11-30T22:30:00Z</td>
      <td>2021-11-30T23:00:00Z</td>
      <td>-14.56</td>
      <td>-14.65</td>
      <td>-14.45</td>
      <td>0.00</td>
      <td>1800.0</td>
      <td>0.57</td>
      <td>0.00</td>
      <td>0</td>
      <td>20211206T221914Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>13102</td>
      <td>D18</td>
      <td>BARR</td>
      <td>3</td>
      <td>0</td>
      <td>2021-11-30T23:00:00Z</td>
      <td>2021-11-30T23:30:00Z</td>
      <td>-14.50</td>
      <td>-14.60</td>
      <td>-14.39</td>
      <td>0.00</td>
      <td>1800.0</td>
      <td>0.57</td>
      <td>0.00</td>
      <td>0</td>
      <td>20211206T221914Z</td>
      <td>PROVISIONAL</td>
    </tr>
    <tr>
      <td>13103</td>
      <td>D18</td>
      <td>BARR</td>
      <td>3</td>
      <td>0</td>
      <td>2021-11-30T23:30:00Z</td>
      <td>2021-12-01T00:00:00Z</td>
      <td>-14.45</td>
      <td>-14.57</td>
      <td>-14.32</td>
      <td>0.00</td>
      <td>1800.0</td>
      <td>0.57</td>
      <td>0.00</td>
      <td>0</td>
      <td>20211206T221914Z</td>
      <td>PROVISIONAL</td>
    </tr>
  </tbody>
</table>
<p>13104 rows × 16 columns</p>
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
                        year='2017', check_size='FALSE',
                       savepath='/Users/Shared');
```

    Downloading files totaling approximately 147.930656 MB 
    Downloading 217 files
      |======================================================================| 100%
    Successfully downloaded  217  files.


Let's read one tile of data into Python and view it. We'll use the 
`rasterio` and `matplotlib` modules here, but as with tabular data, 
there are other options available.


```python
import rasterio
CHMtile = rasterio.open('/Users/Shared/DP3.30015.001/neon-aop-products/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D01_HOPB_DP3_718000_4709000_CHM.tif')
```


```python
import matplotlib.pyplot as plt
from rasterio.plot import show
fig, ax = plt.subplots(figsize = (8,3))
show(CHMtile)
```


    <Figure size 800x300 with 1 Axes>





    <matplotlib.axes._subplots.AxesSubplot at 0x7fa16298fd50>




```python
fig
```




![Canopy Height Model at Hopbrook in 2017](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/NEON-general/neon-code-packages/neonUtilitiesPython/neonUtilitiesPython_files/neonUtilitiesPython_41_0.png)




```python

```
