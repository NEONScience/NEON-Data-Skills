---
syncID: f059914f7cf74327908228e63e204d60
title: "Introduction to NEON API in Python"
description: "Use the NEON API in Python, via requests package and json package."
dateCreated: 2020-04-24
authors: Maxwell J. Burner
contributors: Donal O'Leary, Bridget Hass
estimatedTime: 1 hour
packagesLibraries: requests, json
topics: API
languagesTool: Python
dataProduct: DP3.30015.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/NEON-API-python/neon_api_01_introduction_requests_py/neon_api_01_introduction_requests_py.py
tutorialSeries: python-neon-api-series
urlTitle: neon-api-01-introduction-requests
---

<div id="ds-objectives" markdown="1">

### Objectives
After completing this tutorial, you will be able to:

* Understand the components of a NEON API call
* Understand the basic process of making and processing an API request in Python
* Query the `'sites/'` or `'products/'` API endpoints to determine data availability
* Query the `'data/'` API endpoint to get information on specific data files


### Install Python Packages

* **requests**
* **json** 
* **rasterio**

</div>

In this tutorial we will learn to make calls to the NEON API using Python. We will make calls to the `'sites/'` and `'products/'` endpoints of the API to determine availability of data for specific sites and months, and make a call to the `'data/'` endpoint to learn the names and URLs of specific data files.

An API is an [*Application Programming Interface*](https://rapidapi.com/blog/api-glossary/api-call/). This is a system that allows programs to send instructions and requests to servers, typically receiving data in exchange. While sending a URL over the web normally display a web page, when sending an API call URL, the desired data are directly downloaded to your computer. NEON provides an API that allows different programming languages to send requests for NEON data files and products.

In this tutorial we will cover how to use API calls to learn about what types of NEON data products are available for different sites and time periods.

## Basic API Call Components

The actual API call takes the form of a web URL, the contents of which determine what data is returned. This URL can be broken down into three parts, which appear in order:

- The **base url** is the location of the server storing the data. This will be the same for all NEON API calls.

- The **endpoint** indicates what type of data or metadata we are looking to download. This tutorial covers three endpoints: `sites/`, `products/`, and `data/`; other endpoints will be covered in later tutorials.

- The **target** is a value or series of values that indicate the specific data product, site, location, or data files we are looking up.



In Python we can easily deal with the complexities of the API call by setting the different parts of the request as strings, then concatenating them. Concatenating (combining end to end) strings in Python is as easy as using a `+` sign. This approach makes it easy to modify different parts of our request as needed.


```python
import os
import requests
import json
import itertools
```


```python
#Every request begins with the server's URL
SERVER = 'http://data.neonscience.org/api/v0/'
```

## Site Querying

NEON manages 81 different sites across the United States and Puerto Rico. These sites are separated into two main groups, terrestrial and aquatic, and the aquatic sites are further subdivided into lakes, rivers, and wadable streams. Each of these different site types have different instrumentation and observation configurations, so not every data product is available at every site. We can start by asking what kinds of data products are available for a given site. This is done by using the *sites/* endpoint in the API; this endpoint is used for getting information about specific NEON field sites. In this example we will query which data products are available at the <a href="https://www.neonscience.org/field-sites/field-sites-map/TEAK" target="_blank">Lower Teakettle (TEAK)</a> site.


```python
#Site Code for Lower Teakettle
SITECODE = 'TEAK'
```

We first use the requests module to send the API request using the 'get' function; this returns a 'request' object.
To more easily access the data returned by the request, we convert the request object into a Python JSON object.


```python
#Define the url, using the sites/ endpoint
url = SERVER+'sites/'+SITECODE
print(url)
```


```python
#Request the url
site_request = requests.get(url)

#Convert the request to Python JSON object
site_json = site_request.json()
```

The JSON object in Python is a complex collection, with nested layers of dictionaries ('dicts') and lists. 

In short, a list is a collection of data in which each element is identified by index number, while a dictionary is a collection in which each element is identified by a label (called a 'key') that is usually a text string. You can visit the [w3schools website](https://www.w3schools.com/python/python_lists.asp) for more information on lists, and the [realpython website](https://realpython.com/python-dicts/) for more information on dictionaries. 

Dictionaries are defined using curly brackets ({...}) and lists are defined using square brackets (\[...\]). When we look at the request in JSON format, we can see this this is quite a lot of text arranged in nested dicts and lists. Click on the url link to see the data in JSON format in a new tab.

At the highest level, the JSON object is a dictionary containing a single element with the label `'data'`. This `'data'` element in turn contains a dictionary with elements containing various pieces of information about the site. When we want to know what elements a dict contians, we can use the *.keys()* method to list the keys to each element in that dict.


```python
#Use the 'keys' method to view the component of the uppermost json dictionary
site_json.keys()
```

This output shows that the entire API response is contained within a single dict called `'data'`. In order to access any of the information contained within this highest-level `'data'` dict, we will need to reference that dictionary directly. Let's view the different keys that are available within `'data'`:


```python
#Access the 'data' component, and use the 'keys' method to view to componenets of the json data dictionary
site_json['data'].keys()
```

These JSON keys include information on site location, site type, site name and code, and the availability of different data products for the site. 

Let's use the `itertools.islice` and `.items()` methods to display some of this information in more detail. This next line will print out the first 12 components of the `'data'` component. 


```python
dict(itertools.islice(site_json['data'].items(),12))
```

This last piece of information in the `'data'` dictionary is stored within the `'dataProducts'` key.

The `'dataProducts'` element is a list of dictionaries, one for each type of NEON data product available at the site; each of these dictionaries has the same keys, but different values. Let's look at the JSON for the third to last entry ("\[-3\]") in the list of data products:


```python
#View a data product dictionary
site_json['data']['dataProducts'][-3]
```

Lists are a type of sequential data, so we can use Python's *for* loop to directly go through every element one by one, in this case to print out the data product code and data product name.


```python
#View product code and name for every available data product
for product in site_json['data']['dataProducts']:
    print(product['dataProductCode'],product['dataProductTitle'])
```

Typically, we use site queries to determine which months a particular data product is available at a given site. Let's look for the availability of Ecosystem structure (DP3.30015.001) - this is the Canopy Height Model, one of the data products generated by NEON's Airborne Observation Platform (AOP).


```python
#Set the Ecosystem structure (CHM) data product
PRODUCTCODE = 'DP3.30015.001'
```

For each data product, there will be a list of the months for which data of that type was collected and it available at the site, and a corresponding list with the URLs that we would put into the API to get data on that month of data products.


```python
#Get available months of Ecosystem structure data products for TEAK site
#Loop through the 'dataProducts' list items (each one is a dictionary) at the site
for product in site_json['data']['dataProducts']: 
    #if a list item's 'dataProductCode' dict element equals the product code string
    if(product['dataProductCode'] == PRODUCTCODE): 
        #print the available months
        print('Available Months: ',product['availableMonths'])
        print('URLs for each Month:')
        #print the available URLs
        for url in product['availableDataUrls']:
            print(url)
```

## Data Product Querying

Alternatively, we may want a specific type of data product, but aren't certain of the sites and months for which that data is available. In this case we can use the product code and the `products/` API endpoint to look up availability.


```python
#Make request
product_request = requests.get(SERVER+'products/'+PRODUCTCODE)
product_json = product_request.json()
```

The product JSON will again store everything first in a `'data'` element. Within this container, the product data is a dictionary with information on the data product we are looking up.


```python
#Print keys for product data dictionary
print(product_json['data'].keys())
```

This request returned a lot of different types of information. Much of this information is meant to provide explanations and context for the data product. Let's look at the abstract, which provides a relatively brief description of the data product.


```python
#Print code, name, and abstract of data product
print(product_json['data']['productCode'])
print(product_json['data']['productName'],'\n')
print(product_json['data']['productAbstract'])
```

To look up the availability of the data product, we want the `'siteCodes'` element. This is a list with an entry for each site where the data product is available. Each site entry is a dict whose elements includes site code, a list of months for which data is available, and a list of the API request URLs to request data for that site for a given month.


```python
#View keys of one site dictionary
print(product_json['data']['siteCodes'][0].keys())
```

We can look up the availability of data at a particular site and get a URL to request data for a specific month. We saw that Lower Teakettle (TEAK) has the data product we want for June 2018; we can get the URL needed to request that data by creating a nested for loop to go through the site and month lists.


```python
#View available months and corresponding API urls, then save desired URL
for site in product_json['data']['siteCodes']:
    if(site['siteCode'] == SITECODE):
        for month in zip(site['availableMonths'],site['availableDataUrls']): #Loop through the list of months and URLs
            print(month[0],month[1]) 
            if(month[0] == '2018-06'): #If data is available for the desired month, save the URL
                data_url = month[1]
```


```python
print(data_url)
```

## Data File Querying

We now know that landbird count data products are available for 2018-06 at the Lower Teakettle site. Using the server url, site code, product code, and a year-month argument, we can make a request to the `data/` endpoint of the NEON API. This will allow us to see what CHM data files can be obtained for 2018-06 at the Lower Teakettle site, and to learn the locations of these files as URLs.


```python
#Make Request
data_request = requests.get(SERVER+'data/'+PRODUCTCODE+'/'+SITECODE+'/'+'2018-06')
data_json = data_request.json()
```

Alternatively we could use one of the "Available Data URLs" from a `sites/` or `products/` request, like the data_url we saved earlier.


```python
#Make request with saved url
data_request = requests.get(data_url)
data_json = data_request.json()
```


```python
#Print dict key for 'data' element of data JSON
print(data_json['data'].keys())
```

As with the sites JSON content, the uppermost level of a data request JSON object is a dictionary whose only member has the `'data'` key; this member in turn is a dictionary with the product code, the sitecode, the month, and a list of the available data files.

The `'files'` list is a list of Python dictionaries, one for each file available based on our query. The dictionary for each file includes the `name` of the file, `size` of the file in bytes, a `crc32c` checksum code, and the `url` of the file - clicking on this url will download the file.


```python
#View keys and values in first file dict
for key in data_json['data']['files'][0].keys(): #Loop through keys of the data file dict
    print(key,':\t', data_json['data']['files'][0][key])
```

Next let's take a look at the names of the first 10 files, by looping through the `data_json['data']['files']` list:


```python
#Display the names of the first 10 files
for file in data_json['data']['files'][:10]:
    print(file['name'])
```

A number of different files are available, but the actual CHM data are in files which have 'CHM.tif' in the file name. The files ending in "classified_point_cloud.shp/shx/prj/dbf" are shapefiles that are provided as metadata and can be used to determine the spatial extent. For now we will only focus on the actual data files.

We can use `if` statements to pull out information on only the CHM raster (tif) files. The Python **in** operator checks if a particular value is present in a sequence. In this case we'll check if a particular series of characters `'CHM.tif'` is present in the file name string.


```python
for file in data_json['data']['files'][:20]:
    if 'CHM.tif' in file['name']:
        print(file['name'])
        print(file['url'])
```

Click on the link to the last file in this list. As a last step, we will read it in and plot it! You can do this with a number of different packages, but we'll show how to do it with the `rasterio` package. We'll need to import a few more packages for plotting.


```python
import rasterio as rio
import matplotlib.pyplot as plt
from rasterio.plot import show
```

Determine where your file is downloaded. The code below assumes it was downloaded to the "C:/Users/username/Downloads" directory, but you can change this path if you've saved the file to a different location.


```python
#Read in the CHM file - change the path if it's not in this Downloads directory
username = os.getlogin()
chm_tif = r'C:/Users/'+username+'/Downloads/NEON_D17_TEAK_DP3_319000_4107000_CHM.tif'
chm = rio.open(chm_tif)
```

Finally we can define the plot settings and use rasterio `show` to display this CHM tile.


```python
#Configure the plot
fig, ax = plt.subplots(1,1, figsize=(5,5));

#Don't use scientific notation for the y axis label
ax.get_yaxis().get_major_formatter().set_scientific(False)

#Display the CHM
show((chm, 1), ax=ax, cmap='Greens', title='NEON_D17_TEAK_DP3_319000_4107000_CHM.tif');
```
