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
code1: /Python/neonUtilities/neonUtilitiesPython.ipynb
tutorialSeries: 
urlTitle: neon-utilities-python
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

1. Python 3 installed. It is probably possible to use this workflow in Python 2, 
but these instructions were developed and tested using 3.6.4.
2. R installed. You don't need to have ever used it directly. We tested using 
R 3.4.3, but most other recent versions should also work.
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
        -1.767571
      </td>
      
      <td>
        -0.550345
      </td>
      
      <td>
        -0.195803
      </td>
      
      <td>
        -1.345787
      </td>
      
      <td>
        -1.184887
      </td>
      
      <td>
        -1.140016
      </td>
      
      </tr>
      </tbody>
    </table>
    



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

This installation step carries out the same steps that it would if 
run in R directly, so if you use R regularly and have already installed 
`devtools` on your machine, you can skip this step, although again, 
it's wise to update regularly. And be aware, this also means if you 
install new versions of packages via `rpy2`, they'll be updated the 
next time you use R, too.

The semicolon at the end of the line (here, and in some other function 
calls below) can be omitted. It suppresses a note indicating the output 
of the function is null. The output is null because these functions download 
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
    17: China (Lanzhou) [https]          18: China (Shanghai 1) [https]     
    19: China (Shanghai 2) [https]       20: Colombia (Cali) [https]        
    21: Czech Republic [https]           22: Denmark [https]                
    23: East Asia [https]                24: Ecuador (Cuenca) [https]       
    25: Ecuador (Quito) [https]          26: Estonia [https]                
    27: France (Lyon 1) [https]          28: France (Lyon 2) [https]        
    29: France (Marseille) [https]       30: France (Montpellier) [https]   
    31: France (Paris 2) [https]         32: Germany (Erlangen) [https]     
    33: Germany (Göttingen) [https]      34: Germany (Münster) [https]      
    35: Greece [https]                   36: Iceland [https]                
    37: India [https]                    38: Indonesia (Jakarta) [https]    
    39: Ireland [https]                  40: Italy (Padua) [https]          
    41: Japan (Tokyo) [https]            42: Japan (Yonezawa) [https]       
    43: Korea (Ulsan) [https]            44: Malaysia [https]               
    45: Mexico (Mexico City) [https]     46: Norway [https]                 
    47: Philippines [https]              48: Serbia [https]                 
    49: Spain (A Coruña) [https]         50: Spain (Madrid) [https]         
    51: Sweden [https]                   52: Switzerland [https]            
    53: Turkey (Denizli) [https]         54: Turkey (Mersin) [https]        
    55: UK (Bristol) [https]             56: UK (Cambridge) [https]         
    57: UK (London 1) [https]            58: USA (CA 1) [https]             
    59: USA (IA) [https]                 60: USA (KS) [https]               
    61: USA (MI 1) [https]               62: USA (NY) [https]               
    63: USA (OR) [https]                 64: USA (TN) [https]               
    65: USA (TX 1) [https]               66: Vietnam [https]                
    67: (other mirrors)                  
    
    
    
    
    
    Selection: 59
    
    
    
    The downloaded binary packages are in
    	/var/folders/_k/gbjn452j1h3fk7880d5ppkx1_9xf6m/T//RtmpstlW3C/downloaded_packages
    
    
    


Now load the `devtools` package. This does need to be run every time 
you use the code; if you're familiar with R, `importr()` is roughly 
equivalent to the `library()` function in R.


```python
devtools = importr('devtools')
```

Using the `install_github()` function from the `devtools` package, install 
the `neonUtilities` package from its location in the <a href="https://github.com/NEONScience" target="_blank"> public NEON GitHub</a> 
repository. As with `devtools`, you can theoretically skip this step in 
the future, but since we update `neonUtilities` frequently, we recommend 
re-installing regularly. Then load the package.


```python
devtools.install_github('NEONScience/NEON-utilities/neonUtilities');
neonUtils = importr('neonUtilities')
```

## Join data files: stackByTable()

The function `stackByTable()` in `neonUtilities` merges the monthly, 
site-level files the <a href="http://data.neonscience.org/home" target="_blank">NEON Data Portal</a> 
provides. Start by downloading the dataset you're interested in from the 
Portal. It will download as a single zip file. Note the file path it's 
saved to and proceed.

The data stacker package comes with a data file, `table_types`. The data file 
is needed for the package to work, and `rpy2` doesn't load data by default. So 
we need to load it to the session and then pass it back to the R environment.

First, extract the data object from the package. Then extract the 
`table_types` object from the data object:


```python
neonUdata = neonUtils.__rdata__
table_types = neonUdata.fetch('table_types')['table_types']
```

Now, pass it back to the R environment:


```python
robjects.globalenv['table_types'] = table_types
```

Now run the `stackByTable()` function to stack the data. It requires only one 
input, the path to the zip file you downloaded from the NEON Data Portal.

For additional, optional inputs to `stackByTable()`, see the <a href="http://neonscience.org/neonDataStackR" target="_blank">R tutorial</a> 
for neonUtilities.


```python
neonUtils.stackByTable(filepath='~/Downloads/NEON_isotope-soil-distrib-periodic.zip');
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
you should now have a subfolder containing the unzipped and stacked files called `stackedFiles`.

## Download files to be stacked: zipsByProduct()

The function `zipsByProduct()` uses the <a href="http://data.neonscience.org/data-api" target="_blank">NEON API</a> to programmatically download 
data files for a given product. The files downloaded by `zipsByProduct()` 
can then be fed into `stackByTable()`.

`zipsByProduct()` will create a new folder in the R working directory and 
write the files there. First, set the working directory if it isn't set to 
where you want it.


```python
base.setwd('~/Downloads');
```

Run the downloader with these inputs: a DPID, a 4-letter site ID (or "all" for all sites), 
a package (either basic or expanded), and an indicator to check the size of 
your download before proceeding or not (TRUE/FALSE).

There are two differences relative to running this function in R directly: 

1. `check.size` becomes `check_size`, because dots have programmatic meaning 
in Python
2. `TRUE` (or `T`) becomes `'TRUE'` because the values TRUE and FALSE don't 
have special meaning in Python the way they do in R, so it interprets them 
as variables if they're unquoted.

`check_size='TRUE'` will estimate the size of the download and ask you to 
confirm before proceeding. This will cause problems in certain environments, 
or in batch processing. Under those circumstances, set `check_size='FALSE'`, 
but consider the size of your query before doing this.


```python
neonUtils.zipsByProduct(dpID='DP1.10023.001', site='HARV', 
                        package='basic', check_size='TRUE');
```

    Continuing will download files totaling approximately 0.165245 MB. Do you want to proceed y/n: y
    6 zip files downloaded to /Users/clunch/filesToStack10023
    


The message output by `zipsByProduct()` indicates the file path where the 
files have been downloaded.

Now take that file path and pass it to `stackByTable()`. The file structure 
is slightly different from the zip file returned by the Portal, so we need 
an additional input, folder="TRUE".


```python
neonUtils.stackByTable(filepath='~/Downloads/filesToStack10023', folder='TRUE');
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
    


## Download remote sensing files: byFileAOP()

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
neonUtils.byFileAOP(dpID='DP3.30015.001', site='HOPB', 
                    year='2017', check_size='TRUE');
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
    

