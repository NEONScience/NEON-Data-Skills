---
syncID: a82f3466e5e9433fbbf8026a54e720ae
title: "Assignment: Reproducible Workflows with Jupyter Notebooks"
description: "This page details how to complete the assignment for pre-Institute week 3 on documenting your code with Jupyter Notebooks."
dateCreated: 2017-06-12
dateUpdated: 2020-04-21
authors: Maria Paula Mugnani
contributors: Donal O'Leary
estimatedTime: 1 hour
packagesLibraries:
topics: data-management, rep-sci
languagesTool: Python
dataProduct:
code1:
tutorialSeries: JupPy
urlTitle: jupyter-python-cul-activity

---

In this tutorial you will learn how to open a .tiff file in Jupyter Notebook and learn about kernels. 

The goal of the activity is simply to ensure that you have basic
familiarity with Jupyter Notebooks and that the environment, especially the 
`gdal` package is correctly set up before you pursue more programming tutorials. If you already
are familiar with Jupyter Notebooks using Python, you may be able to complete the 
assignment without working through the instructions. 

<div id="ds-objectives" markdown="1">

This will be accomplished by:
  *Create a new  Jupyter kernel
  *Download a GEOTIFF file
  *Import file onto Jupyter Notebooks
  *Check the raster size



## Assignment: Open a Tiff File in Jupyter Notebook 



### Set up Environment 

First, we will set up the environment as you would need for each of the live 
coding sections of the Data Institute. The following directions are copied over
from the Data Institute Set up Materials.

In your terminal application, navigate to the directory (`cd`) that where you
want the Jupyter Notebooks to be saved (or where they already exist). 

We need to create a new Jupyter kernel for the Python 3.8 conda environment 
(py38) that Jupyter Notebooks will use. 

In your Command Prompt/Terminal, type: 

`python -m ipykernel install --user --name py34 --display-name "Python 3.8 NEON-RSDI"`

In your Command Prompt/Terminal, navigate to the directory (`cd`) that you 
created last week in the GitHub materials. This is where the Jupyter Notebook 
will be saved and the easiest way to access existing notebooks. 

###Open Jupyter Notebook
Open Jupyter Notebook by typing into a command terminal:

`jupyter notebook`

Once the notebook is open, check which version of Python you are in. 

	 # Check what version of Python.  Should be 3.8. 
	 import sys
	 sys.version

To ensure that the correct kernel will operate, navigate to **Kernel** in the menu, 
select **Kernel/Restart Kernel And Clear All Outputs**. 

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/pre-institute-content/pre-institute3-jupPy/jupPy-kernel.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/pre-institute-content/pre-institute3-jupPy/jupPy-kernel.png" alt="Navigate to 'Kernel' in the top navigation bar, then select 'Restart & Clear Output'."></a>
	<figcaption> To ensure that the correct kernel will operate, navigate to 
	Kernel in the menu, select "Restart/Restart & Clear Output". 
	Source: National Ecological Observatory Network (NEON)  
	</figcaption>
</figure>


You should now be able to work in the notebook. 



#Download the digital terrain model (GEOTIFF file)
Download the NEON GeoTiFF file of a digital terrain model (dtm) of the San Joaquin Experimental Range.
Click this link to download dtm data: https://ndownloader.figshare.com/articles/2009586/versions/10. This will download a zippped full of data originally from a NEON data carpentry tutorial (https://datacarpentry.org/geospatial-workshop/data/).

Once downloaded, navigate through the folder to C:NEON-DS-Airborne-Remote-Sensing.zip\NEON-DS-Airborne-Remote-Sensing\SJER\DTM and save this file onto your own personal working directory.
. 

###Open GEOTIFF file in Jupyter Notebooks using gdal


The `gdal` package that occasionally has problems with some versions of Python. 
Therefore test out loading it using: 

`import gdal`.  

If you have trouble, ensure that 'gdal' is installed on your current environment.

## Establish your directory

Place the downloaded dtm file in a repository of your choice (or your current 
working directory). Navigate to that directory. 
	 wd= '/your-file-path-here' #Input the directory to where you saved the .tif file


### Import the TIFF

Import the NEON GeoTiFF file of the digital terrain model (DTM) </a> 
from San Joaquin Experimental Range. Open the file using the `gdal.Open` command.Determine the size of the raster and (optional) plot the raster.

#Use GDAL to open GEOTIFF file stored in your directory
 SJER_DTM = gdal.Open(wd + 'SJER_dtmCrop.tif')>


#Determine the raster size. 

	  SJER_DTM.RasterXSize

Add in both code chunks and text (markdown) chunks to fully explain what is done. If you would like to also plot the file, feel free to do so.  


### Push .ipynb to GitHub.  

  When finished, save as a .ipynb file.

