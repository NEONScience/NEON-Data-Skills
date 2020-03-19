---
syncID: 5be9f80592394af3bc09cf8e469fef6e
title: "Using neonUtilities in Python"
description: "Use the neonUtilities R package in Python, via the rpy2 library."
dateCreated: 2018-5-10
authors: Claire K. Lunch
contributors: 
estimatedTime: 20 minutes
packagesLibraries: rpy2
topics: data-management,rep-sci
languagesTool: python
dataProduct: 
code1: /Python/neonUtilities/neonUtilitiesPython.py
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
    -0.526960
    </td>

    <td>
    0.381438
    </td>

    <td>
    0.192045
    </td>

    <td>
    0.004371
    </td>

    <td>
    -1.876321
    </td>

    <td>
    -0.352350
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

    Unpacking zip files using 1 cores.
    Stacking operation across a single core.
    Stacking table IRBT_1_minute
    Stacking table IRBT_30_minute
    Merged the most recent publication of sensor position files for each site and saved to /stackedFiles
    Copied the most recent publication of variable definition file to /stackedFiles
    Finished: Stacked 2 data tables and 2 metadata tables!
    Stacking took 31.57414 secs
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

    Downloading files totaling approximately 0.564841 MB
    Downloading 11 files
      |======================================================================| 100%
    11 files downloaded to ~/Downloads/filesToStack10003


The message output by `zipsByProduct()` indicates the file path where the 
files have been downloaded.

Now take that file path and pass it to `stackByTable()`.


```python
neonUtilities.stackByTable(filepath='~/Downloads/filesToStack10003');
```

    Unpacking zip files using 1 cores.
    Stacking operation across a single core.
    Stacking table brd_countdata
    Stacking table brd_perpoint
    Copied the most recent publication of validation file to /stackedFiles
    Copied the most recent publication of variable definition file to /stackedFiles
    Finished: Stacked 2 data tables and 2 metadata tables!
    Stacking took 0.269058 secs
    All unzipped monthly data folders have been removed.


## Read downloaded and stacked files into Python

We've now downloaded biological temperature and bird data, and merged 
the site by month files. Now let's read those data into Python so you 
can proceed with analyses.

First let's take a look at what's in the output folders.


```python
import os
os.listdir('Downloads/filesToStack10003/stackedFiles/')
```




    ['brd_countdata.csv',
     'brd_perpoint.csv',
     'readme_10003.txt',
     'variables_10003.csv',
     'validation_10003.csv']




```python
os.listdir('Downloads/NEON_temp-bio/stackedFiles/')
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
brd_perpoint = pandas.read_csv('Downloads/filesToStack10003/stackedFiles/brd_perpoint.csv')
brd_countdata = pandas.read_csv('Downloads/filesToStack10003/stackedFiles/brd_countdata.csv')
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
      <th>startRH</th>
      <th>endRH</th>
      <th>observedHabitat</th>
      <th>observedAirTemp</th>
      <th>kmPerHourObservedWindSpeed</th>
      <th>laboratoryName</th>
      <th>samplingProtocolVersion</th>
      <th>remarks</th>
      <th>measuredBy</th>
      <th>publicationDate</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>dcc40f7c-e1db-4355-8fc9-534541e81a38</td>
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
      <td>72</td>
      <td>56.0</td>
      <td>evergreen forest</td>
      <td>18.0</td>
      <td>1.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vG</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20191107T154457Z</td>
    </tr>
    <tr>
      <td>1</td>
      <td>6a33d032-49ac-4bb5-8d51-887de8a84444</td>
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
      <td>72</td>
      <td>56.0</td>
      <td>deciduous forest</td>
      <td>19.0</td>
      <td>3.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vG</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20191107T154457Z</td>
    </tr>
    <tr>
      <td>2</td>
      <td>7336c159-6101-4eda-98e4-5d5cf90eabae</td>
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
      <td>72</td>
      <td>56.0</td>
      <td>mixed deciduous/evergreen forest</td>
      <td>17.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vG</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20191107T154457Z</td>
    </tr>
    <tr>
      <td>3</td>
      <td>66c44275-3ea7-435f-9c3f-119c840ef331</td>
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
      <td>72</td>
      <td>56.0</td>
      <td>deciduous forest</td>
      <td>19.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vG</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20191107T154457Z</td>
    </tr>
    <tr>
      <td>4</td>
      <td>886e0b82-7e78-4432-860e-ffd209a81466</td>
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
      <td>72</td>
      <td>56.0</td>
      <td>deciduous forest</td>
      <td>16.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vG</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20191107T154457Z</td>
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
      <td>892</td>
      <td>e5129d53-8eea-45db-8c06-e553f054422f</td>
      <td>HARV_016.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_016</td>
      <td>distributed</td>
      <td>C3</td>
      <td>woodyWetlands</td>
      <td>42.458224</td>
      <td>-72.231982</td>
      <td>...</td>
      <td>70</td>
      <td>67.0</td>
      <td>mixed deciduous/evergreen forest</td>
      <td>15.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vJ</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20191205T150111Z</td>
    </tr>
    <tr>
      <td>893</td>
      <td>d5e55ae2-f798-423b-abaf-5dae15074050</td>
      <td>HARV_016.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_016</td>
      <td>distributed</td>
      <td>B3</td>
      <td>woodyWetlands</td>
      <td>42.458224</td>
      <td>-72.231982</td>
      <td>...</td>
      <td>70</td>
      <td>67.0</td>
      <td>deciduous forest</td>
      <td>16.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vJ</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20191205T150111Z</td>
    </tr>
    <tr>
      <td>894</td>
      <td>4c0efec0-0bc2-447e-a264-57efe00a5dca</td>
      <td>HARV_016.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_016</td>
      <td>distributed</td>
      <td>B2</td>
      <td>woodyWetlands</td>
      <td>42.458224</td>
      <td>-72.231982</td>
      <td>...</td>
      <td>70</td>
      <td>67.0</td>
      <td>wetland</td>
      <td>17.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vJ</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20191205T150111Z</td>
    </tr>
    <tr>
      <td>895</td>
      <td>ce77d845-fcb8-4dfd-96ac-b05a491e83a1</td>
      <td>HARV_016.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_016</td>
      <td>distributed</td>
      <td>A2</td>
      <td>woodyWetlands</td>
      <td>42.458224</td>
      <td>-72.231982</td>
      <td>...</td>
      <td>70</td>
      <td>67.0</td>
      <td>deciduous forest</td>
      <td>19.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vJ</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20191205T150111Z</td>
    </tr>
    <tr>
      <td>896</td>
      <td>4afd8d46-a6b5-408a-9a4a-6ed3ec12c035</td>
      <td>HARV_016.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_016</td>
      <td>distributed</td>
      <td>A3</td>
      <td>woodyWetlands</td>
      <td>42.458224</td>
      <td>-72.231982</td>
      <td>...</td>
      <td>70</td>
      <td>67.0</td>
      <td>deciduous forest</td>
      <td>19.0</td>
      <td>0.0</td>
      <td>Bird Conservancy of the Rockies</td>
      <td>NEON.DOC.014041vJ</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20191205T150111Z</td>
    </tr>
  </tbody>
</table>
<p>897 rows × 28 columns</p>
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
      <th>taxonRank</th>
      <th>vernacularName</th>
      <th>observerDistance</th>
      <th>detectionMethod</th>
      <th>visualConfirmation</th>
      <th>sexOrAge</th>
      <th>clusterSize</th>
      <th>clusterCode</th>
      <th>identifiedBy</th>
      <th>publicationDate</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>ad84f42b-f85c-4bb7-8da8-c01ded456940</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09Z</td>
      <td>BART_025.C1.2015-06-14T05:23-04:00[US/Eastern]</td>
      <td>2</td>
      <td>...</td>
      <td>species</td>
      <td>Black-throated Green Warbler</td>
      <td>50.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Male</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20191107T154457Z</td>
    </tr>
    <tr>
      <td>1</td>
      <td>211540a7-1661-4bc7-a066-367eab8eb458</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09Z</td>
      <td>BART_025.C1.2015-06-14T05:23-04:00[US/Eastern]</td>
      <td>1</td>
      <td>...</td>
      <td>species</td>
      <td>Black-throated Green Warbler</td>
      <td>12.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Male</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20191107T154457Z</td>
    </tr>
    <tr>
      <td>2</td>
      <td>0592c99f-6716-4f94-928c-37b1ebb399c9</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09Z</td>
      <td>BART_025.C1.2015-06-14T05:23-04:00[US/Eastern]</td>
      <td>2</td>
      <td>...</td>
      <td>species</td>
      <td>Black-and-white Warbler</td>
      <td>17.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Male</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20191107T154457Z</td>
    </tr>
    <tr>
      <td>3</td>
      <td>8e5a8287-1bca-4431-8b61-4830867079a4</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09Z</td>
      <td>BART_025.C1.2015-06-14T05:23-04:00[US/Eastern]</td>
      <td>1</td>
      <td>...</td>
      <td>species</td>
      <td>Red-eyed Vireo</td>
      <td>9.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Male</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20191107T154457Z</td>
    </tr>
    <tr>
      <td>4</td>
      <td>9b07a045-73a6-40f7-8f88-8c422cc756b8</td>
      <td>BART_025.birdGrid.brd</td>
      <td>D01</td>
      <td>BART</td>
      <td>BART_025</td>
      <td>distributed</td>
      <td>C1</td>
      <td>2015-06-14T09Z</td>
      <td>BART_025.C1.2015-06-14T05:23-04:00[US/Eastern]</td>
      <td>1</td>
      <td>...</td>
      <td>species</td>
      <td>Black-capped Chickadee</td>
      <td>42.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Male</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>JRUEB</td>
      <td>20191107T154457Z</td>
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
      <td>8993</td>
      <td>8b235e8b-c283-4a48-bbe4-91140a94bad0</td>
      <td>HARV_016.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_016</td>
      <td>distributed</td>
      <td>A3</td>
      <td>2019-06-15T14Z</td>
      <td>HARV_016.A3.2019-06-15T09:45-04:00[US/Eastern]</td>
      <td>6</td>
      <td>...</td>
      <td>family</td>
      <td>NaN</td>
      <td>61.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20191205T150111Z</td>
    </tr>
    <tr>
      <td>8994</td>
      <td>0d1bc9ae-9335-4edc-afab-ffd6b687d674</td>
      <td>HARV_016.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_016</td>
      <td>distributed</td>
      <td>A3</td>
      <td>2019-06-15T14Z</td>
      <td>HARV_016.A3.2019-06-15T09:45-04:00[US/Eastern]</td>
      <td>1</td>
      <td>...</td>
      <td>species</td>
      <td>Yellow-bellied Sapsucker</td>
      <td>17.0</td>
      <td>drumming</td>
      <td>Yes</td>
      <td>Male</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20191205T150111Z</td>
    </tr>
    <tr>
      <td>8995</td>
      <td>271dac86-df78-49b6-8704-0f4457fc8635</td>
      <td>HARV_016.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_016</td>
      <td>distributed</td>
      <td>A3</td>
      <td>2019-06-15T14Z</td>
      <td>HARV_016.A3.2019-06-15T09:45-04:00[US/Eastern]</td>
      <td>6</td>
      <td>...</td>
      <td>species</td>
      <td>Rose-breasted Grosbeak</td>
      <td>32.0</td>
      <td>calling</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20191205T150111Z</td>
    </tr>
    <tr>
      <td>8996</td>
      <td>7d59225c-a208-4093-8987-211aaa647230</td>
      <td>HARV_016.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_016</td>
      <td>distributed</td>
      <td>A3</td>
      <td>2019-06-15T14Z</td>
      <td>HARV_016.A3.2019-06-15T09:45-04:00[US/Eastern]</td>
      <td>3</td>
      <td>...</td>
      <td>species</td>
      <td>Ovenbird</td>
      <td>52.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20191205T150111Z</td>
    </tr>
    <tr>
      <td>8997</td>
      <td>cf021aa5-152b-4c65-8094-b1a7e98a0426</td>
      <td>HARV_016.birdGrid.brd</td>
      <td>D01</td>
      <td>HARV</td>
      <td>HARV_016</td>
      <td>distributed</td>
      <td>A3</td>
      <td>2019-06-15T14Z</td>
      <td>HARV_016.A3.2019-06-15T09:45-04:00[US/Eastern]</td>
      <td>5</td>
      <td>...</td>
      <td>species</td>
      <td>Yellow-billed Cuckoo</td>
      <td>63.0</td>
      <td>singing</td>
      <td>No</td>
      <td>Unknown</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>WFREE</td>
      <td>20191205T150111Z</td>
    </tr>
  </tbody>
</table>
<p>8998 rows × 23 columns</p>
</div>



And now let's do the same with the 30-minute data table for biological 
temperature.


```python
IRBT30 = pandas.read_csv('Downloads/NEON_temp-bio/stackedFiles/IRBT_30_minute.csv')
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
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>D02</td>
      <td>BLAN</td>
      <td>0</td>
      <td>10</td>
      <td>2016-05-31T23:30:00Z</td>
      <td>2016-06-01T00:00:00Z</td>
      <td>20.96</td>
      <td>20.34</td>
      <td>21.65</td>
      <td>0.14</td>
      <td>1800.0</td>
      <td>0.58</td>
      <td>0.01</td>
      <td>0</td>
      <td>20171023T054007Z</td>
    </tr>
    <tr>
      <td>1</td>
      <td>D02</td>
      <td>BLAN</td>
      <td>0</td>
      <td>10</td>
      <td>2016-06-01T00:00:00Z</td>
      <td>2016-06-01T00:30:00Z</td>
      <td>19.75</td>
      <td>19.34</td>
      <td>20.36</td>
      <td>0.08</td>
      <td>1800.0</td>
      <td>0.58</td>
      <td>0.01</td>
      <td>0</td>
      <td>20171023T054007Z</td>
    </tr>
    <tr>
      <td>2</td>
      <td>D02</td>
      <td>BLAN</td>
      <td>0</td>
      <td>10</td>
      <td>2016-06-01T00:30:00Z</td>
      <td>2016-06-01T01:00:00Z</td>
      <td>19.13</td>
      <td>18.91</td>
      <td>19.46</td>
      <td>0.02</td>
      <td>1800.0</td>
      <td>0.58</td>
      <td>0.00</td>
      <td>0</td>
      <td>20171023T054007Z</td>
    </tr>
    <tr>
      <td>3</td>
      <td>D02</td>
      <td>BLAN</td>
      <td>0</td>
      <td>10</td>
      <td>2016-06-01T01:00:00Z</td>
      <td>2016-06-01T01:30:00Z</td>
      <td>18.71</td>
      <td>18.49</td>
      <td>18.95</td>
      <td>0.01</td>
      <td>1800.0</td>
      <td>0.58</td>
      <td>0.00</td>
      <td>0</td>
      <td>20171023T054007Z</td>
    </tr>
    <tr>
      <td>4</td>
      <td>D02</td>
      <td>BLAN</td>
      <td>0</td>
      <td>10</td>
      <td>2016-06-01T01:30:00Z</td>
      <td>2016-06-01T02:00:00Z</td>
      <td>18.47</td>
      <td>18.27</td>
      <td>18.64</td>
      <td>0.00</td>
      <td>1800.0</td>
      <td>0.58</td>
      <td>0.00</td>
      <td>0</td>
      <td>20171023T054007Z</td>
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
    </tr>
    <tr>
      <td>308481</td>
      <td>D19</td>
      <td>BONA</td>
      <td>3</td>
      <td>0</td>
      <td>2019-09-30T21:30:00Z</td>
      <td>2019-09-30T22:00:00Z</td>
      <td>11.44</td>
      <td>10.18</td>
      <td>12.73</td>
      <td>0.60</td>
      <td>1800.0</td>
      <td>0.58</td>
      <td>0.02</td>
      <td>0</td>
      <td>20191004T075451Z</td>
    </tr>
    <tr>
      <td>308482</td>
      <td>D19</td>
      <td>BONA</td>
      <td>3</td>
      <td>0</td>
      <td>2019-09-30T22:00:00Z</td>
      <td>2019-09-30T22:30:00Z</td>
      <td>11.60</td>
      <td>9.59</td>
      <td>12.80</td>
      <td>0.47</td>
      <td>1800.0</td>
      <td>0.58</td>
      <td>0.02</td>
      <td>0</td>
      <td>20191004T075451Z</td>
    </tr>
    <tr>
      <td>308483</td>
      <td>D19</td>
      <td>BONA</td>
      <td>3</td>
      <td>0</td>
      <td>2019-09-30T22:30:00Z</td>
      <td>2019-09-30T23:00:00Z</td>
      <td>9.52</td>
      <td>8.66</td>
      <td>10.41</td>
      <td>0.29</td>
      <td>1800.0</td>
      <td>0.58</td>
      <td>0.01</td>
      <td>0</td>
      <td>20191004T075451Z</td>
    </tr>
    <tr>
      <td>308484</td>
      <td>D19</td>
      <td>BONA</td>
      <td>3</td>
      <td>0</td>
      <td>2019-09-30T23:00:00Z</td>
      <td>2019-09-30T23:30:00Z</td>
      <td>10.39</td>
      <td>9.90</td>
      <td>10.90</td>
      <td>0.04</td>
      <td>1800.0</td>
      <td>0.58</td>
      <td>0.00</td>
      <td>0</td>
      <td>20191004T075451Z</td>
    </tr>
    <tr>
      <td>308485</td>
      <td>D19</td>
      <td>BONA</td>
      <td>3</td>
      <td>0</td>
      <td>2019-09-30T23:30:00Z</td>
      <td>2019-10-01T00:00:00Z</td>
      <td>10.31</td>
      <td>9.76</td>
      <td>10.69</td>
      <td>0.05</td>
      <td>1800.0</td>
      <td>0.58</td>
      <td>0.01</td>
      <td>0</td>
      <td>20191004T075451Z</td>
    </tr>
  </tbody>
</table>
<p>308486 rows × 15 columns</p>
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
                       savepath='~/Downloads');
```

    Downloading files totaling approximately 147.8 MB MB
    Downloading 213 files
      |======================================================================| 100%
    Successfully downloaded  213  files.
    NEON_D01_HOPB_DP1_718000_4706000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4710000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4705000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4705000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4707000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_717000_4710000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_717000_4710000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4706000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4709000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4705000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4710000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4708000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    2017_HOPB_2_L3_discrete_lidar_processing.pdf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/Reports
    NEON_D01_HOPB_DP1_716000_4710000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4705000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4705000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4709000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4704000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4708000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4710000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4705000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_720000_4710000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_719000_4706000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4710000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4710000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4708000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_718000_4704000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4705000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4706000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4707000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_720000_4709000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4705000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4708000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4704000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4706000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4710000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4706000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4706000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4708000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4710000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4707000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_717000_4708000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_720000_4707000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_718000_4706000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_717000_4708000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4707000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4706000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4709000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4707000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4705000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4705000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_718000_4710000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_718000_4704000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_718000_4707000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4708000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4706000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4705000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_716000_4706000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4709000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_720000_4708000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4704000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4704000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4704000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4706000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4704000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4709000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_717000_4705000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_717000_4705000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4709000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4708000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4707000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4707000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4707000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4709000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_719000_4709000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4710000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_720000_4706000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4709000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4709000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4710000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4709000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4706000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4710000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4709000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4706000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_717000_4706000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_720000_4710000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4708000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_719000_4708000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_718000_4708000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_720000_4704000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4704000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4707000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_720000_4708000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4709000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4706000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4704000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4704000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_718000_4709000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4705000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4705000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4708000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4709000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4710000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4709000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_716000_4704000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_719000_4705000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_718000_4705000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4705000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_720000_4705000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4706000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4709000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4704000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4709000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4708000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4704000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4708000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4706000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4708000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4709000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4708000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4710000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4710000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4708000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4709000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4707000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4707000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4710000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4709000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4708000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4705000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4704000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_718000_4709000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4707000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4706000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4706000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4706000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_719000_4707000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_720000_4707000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4710000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_717000_4704000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_720000_4704000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4707000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4705000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4705000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4707000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4704000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_718000_4705000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_716000_4704000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4709000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_717000_4707000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_719000_4704000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_717000_4708000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4706000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_717000_4707000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4710000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4709000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4704000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4707000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4710000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    2017_HOPB_2_V01_LMS_QAQC.pdf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/Reports
    NEON_D01_HOPB_DP1_719000_4706000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4710000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4706000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_718000_4708000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_720000_4704000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4707000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_720000_4709000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_718000_4707000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4705000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_716000_4705000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON.D01.HOPB.DP3.30015.001.readme.20190925T213945Z.txt downloaded to ~/Downloads/DP3.30015.001/NEON.DOM.SITE.DP3.30015.001/PROV/HOPB/20170801T000000--20170901T000000/basic
    NEON_D01_HOPB_DP1_718000_4707000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4707000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4708000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_717000_4709000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_718000_4705000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4705000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4706000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4704000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_719000_4710000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4708000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4709000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4710000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4706000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4705000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4709000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4707000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4707000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4710000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP3_720000_4710000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_719000_4708000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4709000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4704000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4704000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4705000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4708000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_718000_4710000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4704000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_716000_4705000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_717000_4706000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4708000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP3_718000_4707000_CHM.tif downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP1_718000_4708000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4707000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4708000_classified_point_cloud.shx downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_720000_4710000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls
    NEON_D01_HOPB_DP1_719000_4704000_classified_point_cloud.dbf downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_717000_4704000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4704000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4706000_classified_point_cloud.shp downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_716000_4707000_classified_point_cloud.prj downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/shps
    NEON_D01_HOPB_DP1_719000_4706000_classified_point_cloud.kml downloaded to ~/Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/Metadata/DiscreteLidar/TileBoundary/kmls


Let's read one tile of data into Python and view it. We'll use the 
`rasterio` and `matplotlib` modules here, but as with tabular data, 
there are other options available.


```python
import rasterio
CHMtile = rasterio.open('Downloads/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D01_HOPB_DP3_718000_4709000_CHM.tif')
```


```python
import matplotlib.pyplot as plt
from rasterio.plot import show
fig, ax = plt.subplots(figsize = (8,3))
show(CHMtile)
```


![ ](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/neonUtilitiesPython_files/neonUtilitiesPython_40_0.png)





    <matplotlib.axes._subplots.AxesSubplot at 0x157bfb210>


