---
syncID: 
title: "Extracting Timeseries from Images using xROI"
description: "Delineate Region of Interests (ROI's) and Extract Time-Series Data from Digital Repeat Photography Images using xROI"
date: "2018-11-02"
authors: Bijan Seyednasrollah
contributors:
estimatedTime: 0.5 hrs
packagesLibraries: xROI, raster, rgdal, sp
topics: remote-sensing, phenology, time-series, data-analysis
languagesTool: R
dataProduct:
code1: PhenoCam
tutorialSeries:
urlTitle: xroi
---

Here, we present an interactive open-source toolkit, called xROI[^*], that facilitates the process of time-series extraction and improves the quality of the final data. xROI provides a responsive environment for scientists to interactively:

a) delineate regions of interest (ROI), 
b) handle field of view (FOV) shifts, 
c) extract and export time series data characterizing color-based metrics.

Using `xROI`, the user can detect FOV shifts with minimal difficulty. The software gives user the opportunity to re-adjust mask files or redraw new ones every time an FOV shift occurs.

### Design
R language and Shiny package were used as the main development tool for xROI, while Markdown, HTML, CSS and JavaScript languages were used to smoothen the interactivity. While Shiny apps are primarily used for web-based applications to be used online, we used Shiny for its graphical user interface capabilities. In other words, both UI and server modules are run locally from the same machine and hence no internet connection is required. The xROI’s UI element presents a side-panel for data entry and three main tab-pages, each responsible for a specific task. The server-side element consists of R and shell scripts. Image processing and geospatial features were performed using the `Geospatial Data Abstraction Library (GDAL)` and the `rgdal` and `raster` R packages. 


### Installation
The xROI R package has been published on The Comprehensive R Archive Network (CRAN). The latest tested xROI package can be installed from the <a href="https://cran.r-project.org/package=xROI">CRAN packages repository</a> by running the following command in an R environment:


```r
utils::install.packages('xROI', repos = "http://cran.us.r-project.org" )
```

Alternatively, the latest beta release of xROI can be directly downloaded and installed from the GitHub repository:

```r
# install devtools first
utils::install.packages('devtools', repos = "http://cran.us.r-project.org" )

devtools::install_github("bnasr/xROI")
```

xROI depends on many R packages including: `raster`, `rgdal`, `sp`, `jpeg`, `tiff`, `shiny`, `shinyjs`, `shinyBS`, `shinyAce`, `shinyTime`, `shinyFiles`, `shinydashboard`, `shinythemes`, `colourpicker`, `rjson`, `stringr`, `data.table`, `lubridate`, `plotly`, `moments`, and `RCurl`. All the required libraries and packages will be automatically installed with installation of xROI. The package offers a fully interactive high-level interface as well as a set of low-level functions for ROI processing. 


### How to Launch `xROI`

A comprehensive user manual for low-level image processing using xROI is available from <a href="https://cran.r-project.org/package=xROI/xROI.pdf">xROI.pdf</a>. While the user manual includes a set of examples for each function; here we explain the graphical interactive mode. The interactive mode can be launched from an interactive R environment by the following command.


```r
library(xROI)
Launch()
```

or form the command line (e.g. shell in Linux, Terminal in macOS and Command Prompt in Windows machines) where an R engine is already installed by:


```r
Rscript -e “xROI::Launch(Interactive = TRUE)”
```

Calling the Launch function opens up the app in the system’s default web browser, offering an example dataset to explore different modules or upload a new dataset of images. 


### Real World Example
To get some hands-on experience with `xROI`, we can analyze images from the <a href="https://phenocam.sr.unh.edu/webcam/sites/dukehw/">dukehw</a> of the **PhenoCam** network. You can download the data set from <a href="http://bit.ly/2PzZ2fL">here</a>. 

Follow the steps below:

1. Save and extract the file on your computer. 

2. Open the data set in `xROI`. 

```r
xROI::Launch('/path/to/extracted/directory/)
```

3. Draw and ROI, enter the metadata. 

4. Save the metadata and explore its content.

5. Go to the `Time series extraction` tab. Extract the time-series.

6. Explore if there is any FOV shift in the dataset using the `CLI processer` tab.




[^*]: The R package is developed and maintained by <a href="https://bnasr.github.io/">Bijan Seyednarollah</a>. Most recent release is available from: https://github.com/bnasr/xROI
