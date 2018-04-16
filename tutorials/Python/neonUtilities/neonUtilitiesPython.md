
---
syncID:63993d7274f84e51a1047e1fea9aece1
title: "Using NEON Utilities in Python"
description: "Use the neonUtilities R package in Python, via the rpy2 library."
dateCreated: 2018-12-08
authors: Claire K. Lunch
contributors: 
estimatedTime: 
packagesLibraries: rpy2
topics: data-management,rep-sci
languagesTool: python
dataProduct: 
code1: /Python/neonUtilities/neonUtilitiesPython.ipynb
tutorialSeries: 
urlTitle: utilities-python
---

The instructions below will guide you through using the neonUtilities R package 
in Python, via the rpy2 package. rpy2 creates an R environment you can interact 
with from Python. The focus in this tutorial is on the Python implementation, 
rather than a comprehensive overview of the package itself. For more 
information about the package, and instructions for running it in R directly, 
see the readme for the package on the <a href="https://github.com/NEONScience/NEON-utilities/tree/master/neonUtilities" target="_blank">NEON-utilities GitHub repo</a>, 
and the tutorial on the <a href="http://www.neonscience.org/neonDataStackR" target="_blank">NEON Data Skills page</a>.


## Install and set up

Before starting, you will need:

1. Python 3 installed. It is probably possible to use this workflow in Python 2, but these instructions were developed and tested using 3.6.4.
2. R installed. You don't need to have ever used it directly. We tested using R 3.4.3, but most other recent versions should also work.
3. rpy2 installed. Run the line below from the command line. It won't run within Jupyter, the error message is shown for clarity. It also likely will not work on Windows, see next section if you are running Windows.
4. You may need to install `pip` first, if you don't have it installed already.

From the command line, run:


```python
pip install rpy2
```

    
    The following command must be run outside of the IPython shell:
    
        $ pip install rpy2
    
    The Python package manager (pip) can only be used from outside of IPython.
    Please reissue the `pip` command in a separate terminal or command prompt.
    
    See the Python documentation for more informations on how to install packages:
    
        https://docs.python.org/3/installing/


### Windows users

The rpy2 package was built for Mac, and doesn't always work smoothly on Windows. 
If you have trouble with the install, try these steps.

1. Add C:\Program Files\R\R-3.3.1\bin\x64 to the Windows Environment Variable “Path”
2. Install rpy2 manually from https://www.lfd.uci.edu/~gohlke/pythonlibs/#rpy2
    1. Pick the correct version. At the download page the portion of the files with cp## relate to the Python version. e.g., rpy2 2.9.2 cp36 cp36m win_amd64.whl is the correct download when 2.9.2 is the latest version of rpy2 and you are running Python 36 and 64 bit Windows (amd64).
    2. Save the whl file, navigate to it in windows then run pip directly on the file as follows “pip install rpy2 2.9.2 cp36 cp36m win_amd64.whl”
3. Add  an R_HOME Windows environment variable with the path C:\Program Files\R\R-3.4.3 (or whichever version you are running)
4. Add an R_USER Windows environment variable with the path C:\Users\yourUserName\AppData\Local\Continuum\Anaconda3\Lib\site-packages\rpy2

## Load packages

Now import rpy2 into your session.


```python
import rpy2
import rpy2.robjects as robjects
from rpy2.robjects.packages import importr
```

Import the base R functionality.


```python
base = importr('base')
utils = importr('utils')
```

Suppress R warnings. This step can be skipped, but will result in messages 
getting passed through from R that Python will interpret as warnings.


```python
import warnings
from rpy2.rinterface import RRuntimeWarning
warnings.filterwarnings("ignore", category=RRuntimeWarning)
```

Install the `devtools` R package. The system will ask you to choose a 
CRAN mirror, select one close to your location. You only need to do this 
step once, although if you use this code regularly, re-installing 
periodically to get the newest version is a good idea.

The semicolon at the end of the line (here, and in some other function 
calls below) can be omitted. It suppresses a note indicating the output 
of the function is null. This note appears because these functions download 
or modify files on your local drive, but none of the data are read into the 
Python or R environments.


```python
utils.install_packages('devtools');
```

    --- Please select a CRAN mirror for use in this session ---
    
    
    
    Secure CRAN mirrors
     
    
    
    
    
    
     1: 0-Cloud [https]                   2: Algeria [https]                
     3: Australia (Canberra) [https]      4: Australia (Melbourne 1) [https]
     5: Australia (Melbourne 2) [https]   6: Australia (Perth) [https]      
     7: Austria [https]                   8: Belgium (Ghent) [https]        
     9: Brazil (PR) [https]              10: Brazil (RJ) [https]            
    11: Brazil (SP 1) [https]            12: Brazil (SP 2) [https]          
    13: Bulgaria [https]                 14: Chile 1 [https]                
    15: Chile 2 [https]                  16: China (Guangzhou) [https]      
    17: China (Lanzhou) [https]          18: China (Shanghai) [https]       
    19: Colombia (Cali) [https]          20: Czech Republic [https]         
    21: Denmark [https]                  22: East Asia [https]              
    23: Ecuador (Cuenca) [https]         24: Ecuador (Quito) [https]        
    25: Estonia [https]                  26: France (Lyon 1) [https]        
    27: France (Lyon 2) [https]          28: France (Marseille) [https]     
    29: France (Montpellier) [https]     30: France (Paris 2) [https]       
    31: Germany (Erlangen) [https]       32: Germany (Göttingen) [https]    
    33: Germany (Münster) [https]        34: Greece [https]                 
    35: Iceland [https]                  36: Indonesia (Jakarta) [https]    
    37: Ireland [https]                  38: Italy (Padua) [https]          
    39: Japan (Tokyo) [https]            40: Japan (Yonezawa) [https]       
    41: Malaysia [https]                 42: Mexico (Mexico City) [https]   
    43: Norway [https]                   44: Philippines [https]            
    45: Serbia [https]                   46: Spain (A Coruña) [https]       
    47: Spain (Madrid) [https]           48: Sweden [https]                 
    49: Switzerland [https]              50: Turkey (Denizli) [https]       
    51: Turkey (Mersin) [https]          52: UK (Bristol) [https]           
    53: UK (Cambridge) [https]           54: UK (London 1) [https]          
    55: USA (CA 1) [https]               56: USA (IA) [https]               
    57: USA (KS) [https]                 58: USA (MI 1) [https]             
    59: USA (NY) [https]                 60: USA (OR) [https]               
    61: USA (TN) [https]                 62: USA (TX 1) [https]             
    63: Vietnam [https]                  64: (other mirrors)                
    
    
    
    
    
    
    Selection: 56
    
    
    
    The downloaded binary packages are in
    	/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T//Rtmpp3bvLx/downloaded_packages
    
    
    


Now import the `devtools` package. This does need to be run every time 
you use the code; for those of you who are familiar with R, `importr` 
is roughly equivalent to the `library()` function in R.


```python
devtools = importr('devtools')
```

Using the `devtools` package, install the `neonUtilities` package. As with 
`devtools`, you can theoretically skip this step in the future, but since 
we update `neonUtilities` frequently, we recommend re-installing regularly.
Then import the package.


```python
devtools.install_github('NEONScience/NEON-utilities/neonUtilities');
neonUtils = importr('neonUtilities')
```

## Stack data files

The function `stackByTable()` in `neonUtilities` merges the monthly, 
site-level files the <a href="http://data.neonscience.org/home" target="_blank">NEON Data Portal</a> 
provides. Start by downloading the dataset you're interested in from the 
Portal. It will download as a single zip file. Note the file path it's 
saved to and proceed.

The data stacker package comes with a data file, table_types. The data file 
is needed for the package to work, and rpy2 doesn't load data by default. So 
we need to load it to the session and then pass it back to the R environment.

First, load the data file:


```python
neonUdata = neonUtils.__rdata__
table_types = neonUdata.fetch('table_types')['table_types']
```

Now, pass it back to the R environment:


```python
robjects.globalenv['table_types'] = table_types
```

Now run the `stackByTable()` function to stack the data. It requires two inputs: 

1. The data product identifier (DPID) of the data you're stacking. DPIDs can be found in the <a href="http://data.neonscience.org/data-product-catalog" target="_blank">Data Product Catalog</a> and are in the form DP#.######.001
2. A file path, the path to the zip file you downloaded from the NEON Data Portal.

For additional, optional inputs, see the <a href="http://neonscience.org/neonDataStackR" target="_blank">R tutorial</a> 
for neonUtilities.


```python
neonUtils.stackByTable('DP1.10100.001','~/Downloads/NEON_isotope-soil-distrib-periodic.zip');
```

    Unpacked  NEON.D02.SCBI.DP1.10100.001.2014-08.expanded.20180308T180515Z.zip
    
    Unpacked  NEON.D07.ORNL.DP1.10100.001.2014-07.expanded.20180308T183441Z.zip
    
    Unpacked  NEON.D10.CPER.DP1.10100.001.2014-07.expanded.20180308T181823Z.zip
    
    Unpacked  NEON.D09.WOOD.DP1.10100.001.2014-08.expanded.20180308T182715Z.zip
    
    Unpacked  NEON.D10.STER.DP1.10100.001.2014-07.expanded.20180308T180231Z.zip
    
    Unpacked  NEON.D15.ONAQ.DP1.10100.001.2014-08.expanded.20180308T182837Z.zip
    
    Unpacked  NEON.D08.TALL.DP1.10100.001.2014-07.expanded.20180308T182745Z.zip
    
    Unpacked  NEON.D01.HARV.DP1.10100.001.2014-07.expanded.20180308T182420Z.zip
    
    Unpacked  NEON.D05.UNDE.DP1.10100.001.2014-07.expanded.20180308T180317Z.zip
    
    Unpacked  NEON.D01.BART.DP1.10100.001.2014-08.expanded.20180308T175912Z.zip
    
    Finished: All of the data are stacked into  1  tables!
    
    Copied the first available NEON.University_of_Wyoming_Stable_Isotope_Facility.bgc_CNiso_externalSummary.csv to /stackedFiles
    Copied the first available variable definition file to /stackedFiles and renamed as variables.csv
    Copied the first available validation file to /stackedFiles and renamed as validation.csv
    Stacked  sls_soilStableIsotopes
    


Check the folder containing the original zip file from the Data Portal; 
you should now have a subfolder containing the unzipped and stacked files.

## Download files to be stacked

The function `zipsByProduct()` uses the <a href="http://data.neonscience.org/data-api" target="_blank">NEON API</a> to programmatically download 
data files for a given product. The files downloaded by `zipsByProduct()` 
can then be fed into `stackByTable()`.

`zipsByProduct()` will create a new folder in the R working directory and 
write the files there. First set the working directory if it isn't set to 
where you want it.


```python
base.setwd('~/Downloads');
```

Run the downloader with these inputs: a DPID, a site (or "all" for all sites), 
a package (either basic or expanded), and an indicator to check the size of 
your download before proceeding, or not.

There are two differences relative to running this function in R directly: 

1. `check.size` becomes `check_size`, because dots have programmatic meaning in Python
2. `TRUE` (or `T`) becomes `"TRUE"` because the values TRUE and FALSE don't have special meaning in Python the way they do in R, so it interprets them as variables if they're unquoted.

`check_size="TRUE"` will estimate the size of the download and ask you to 
confirm before proceeding. This will cause problems in certain environments, 
or in batch processing. Under those circumstances, set `check_size="FALSE"`, 
but consider the size of your query before doing this.


```python
neonUtils.zipsByProduct(dpID='DP1.10023.001', site='HARV', package='basic', check_size='TRUE');
```

    Continuing will download files totaling approximately 0.165245 MB. Do you want to proceed y/n: y
    6 zip files downloaded to /Users/clunch/filesToStack10023
    


The message output by `zipsByProduct()` indicates the file path where the 
files have been downloaded.

Now take that file path and pass it to `stackByTable()`. The file structure 
is slightly different from the zip file returned by the Portal, so we need 
an additional input, folder="TRUE".


```python
neonUtils.stackByTable(dpID='DP1.10023.001', '~/Downloads/filesToStack10023', folder='TRUE');
```

    Unpacked  NEON.D01.HARV.DP1.10023.001.2013-07.basic.20180226T180545Z.zip
    
    Unpacked  NEON.D01.HARV.DP1.10023.001.2014-07.basic.20180226T174946Z.zip
    
    Unpacked  NEON.D01.HARV.DP1.10023.001.2015-06.basic.20180226T174941Z.zip
    
    Unpacked  NEON.D01.HARV.DP1.10023.001.2015-07.basic.20180226T175005Z.zip
    
    Unpacked  NEON.D01.HARV.DP1.10023.001.2016-07.basic.20180226T174902Z.zip
    
    Unpacked  NEON.D01.HARV.DP1.10023.001.2017-07.basic.20180226T174924Z.zip
    
    Finished: All of the data are stacked into  2  tables!
    
    Copied the first available variable definition file to /stackedFiles and renamed as variables.csv
    Copied the first available validation file to /stackedFiles and renamed as validation.csv
    Stacked  hbp_massdata
    Stacked  hbp_perbout
    


## Download remote sensing files

The function `byFileAOP()` uses the <a href="http://data.neonscience.org/data-api" target="_blank">NEON API</a> 
to programmatically download data files for remote sensing (AOP) data 
products. These files cannot be stacked by `stackByTable()` because they 
are not tabular data. The function simply creates a folder in your working 
directory and writes the files there. It preserves the folder structure 
for the subproducts.

The inputs to `byFileAOP()` are a data product ID, a site, a year, and an 
indicator to check the size of the download before proceeding, or not. As 
above, if you are working in an environment that won't handle the 
interactive question, set check_size="FALSE".


```python
neonUtils.byFileAOP(dpID='DP3.30015.001', site='HOPB', year='2017', check_size='TRUE');
```

    Continuing will download 36 files totaling approximately 140.3 MB . Do you want to proceed y/n: y
    Successfully downloaded  36  files.
    
    NEON_D01_HOPB_DP3_719000_4707000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_717000_4704000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_717000_4707000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_717000_4705000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_718000_4709000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_716000_4709000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_719000_4705000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_719000_4708000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_719000_4710000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_720000_4705000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_719000_4706000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_719000_4709000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_720000_4710000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON.D01.HOPB.DP3.30015.001.readme.20180222T152731Z.txt downloaded to /Users/clunch/DP3.30015.001/NEON.DOM.SITE.DP3.30015.001/PROV/HOPB/20170801T000000--20170901T000000/basic
    NEON_D01_HOPB_DP3_720000_4708000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_717000_4706000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_716000_4707000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_716000_4708000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_719000_4704000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_716000_4710000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_717000_4710000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_718000_4708000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_717000_4709000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_716000_4705000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_718000_4704000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_720000_4709000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_716000_4704000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_718000_4705000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_720000_4706000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_717000_4708000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_718000_4707000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_718000_4706000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_718000_4710000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_720000_4707000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_720000_4704000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    NEON_D01_HOPB_DP3_716000_4706000_CHM.tif downloaded to /Users/clunch/DP3.30015.001/2017/FullSite/D01/2017_HOPB_2/L3/DiscreteLidar/CanopyHeightModelGtif
    

