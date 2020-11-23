---
syncID: f059914f7cf74327908228e63e204d60
title: "Introduction to NEON API in Python"
description: "Use the NEON API in Python, via requests package and json package."
dateCreated: 2020-04-24
authors: Maxwell J. Burner
contributors: Donal O'Leary
estimatedTime: 1 hour
packagesLibraries: requests, json
topics:
languagesTool: python
dataProduct: DP3.10003.001
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/NEON-API-python/neon_api_01_introduction_requests_py/neon_api_01_introduction_requests_py.py
tutorialSeries: python-neon-api-series
urlTitle: neon-api-01-introduction-requests
---

<div id="ds-objectives" markdown="1">

### Objectives
After completing this tutorial, you will be able to:

* Understand the components of a NEON API call
* Understand the basic process of making and processing an API request in Python
* Query the 'sites/' or 'products/' API endpoints to determine data availability
* Query the 'data/' API endpoint to get information on specific data files


### Install Python Packages

* **requests**
* **json** 



</div>

In this tutorial we will learn to make calls to the NEON API using Python. We will make calls to the 'sites/' and 'products/' endpoints of the API to determine availability of data for specific sites and months, and make a call to the 'data/' endpoint to learn the names and URLs of specific data files.

An API is an [*Application Programming Interface*](https://rapidapi.com/blog/api-glossary/api-call/); this is a system that allows programs to send instructions and requests to servers, typically recieving data in exchange. Whereas sending a URL over the web normally would cause a web page to be displayed, sending an API call URL results in the deisred data being directly downloaded to your computer. NEON provides an API that allows different programming languages to send requests for NEON data files and products.

In this tutorial we will cover how to use API calls to learn about what types of NEON data products are available for different sites and time periods.

## Basic API Call Components

The actual API call takes the form of a web URL, the contents of which determine what data is returned. This URL can be broken down into three parts, which appear in order:

- The **base url** is the location of the server storing the data. This will be the same for all NEON API calls.

- The **endpoint** indicates what type of data or metadata we are looking to download. This tutorial covers three endpoints: *sites/*, *products/*, and *data/*; other endpoints will be covered in later tutorials.

- The **target** is a value or series of values that indicate the specific data product, site, location, or data files we are looking up.



In python we can easily deal with the complexities of the API call with by creating the different parts of the request as strings, then combining them with string concatenation. Concatenating (combining end to end) string in python is as easy as using a '+' sign. This approach makes it easy to modify different parts of our request as needed.




```python
import requests
import json
```


```python
#Every request begins with the server's URL
SERVER = 'http://data.neonscience.org/api/v0/'
```

## Site Querying

NEON manages 81 different sites across the United States and Puerto Rico. These sites are separated into two main groups, terrestrial and aquatic, and the aquatic sites are further subdivided into lakes, rivers, and wadable streams. Each of these different site types has a different set of instrumentation and observation strategies, therefore, not every data product is available at every site. Often we begin by asking what kinds of data products are available for a given site. This is done by using the *sites/* endpoint in the API; this endpoint is used for getting information about specific NEON field sites. In this example we will query which data products are available at the <a href="https://www.neonscience.org/field-sites/field-sites-map/TEAK" target="_blank">Lower Teakettle (TEAK)</a> site.


```python
#Site Code for Lower Teakettle
SITECODE = 'TEAK'
```

We first use the requests module to send the API request using the 'get' function; this returns a 'request' object.
To more easily access the data returned by the request, we convert the request object into a Python JSON object.


```python
#Make request, using the sites/ endpoint
site_request = requests.get(SERVER+'sites/'+SITECODE)

#Convert to Python JSON object
site_json = site_request.json()
```

The JSON object in Python is a complex collection, with nested layers of dictionaries ('dicts') and lists. 

Briefly, a list is a collection of data in which each element is identified by index number, while a dictionary is a collection in which each element is identified by a label (called a 'key') that is usually a text string. You can visit the [w3schools website](https://www.w3schools.com/python/python_lists.asp) for more information on lists, and the [realpython website](https://realpython.com/python-dicts/) for more information on dictionaries. 

Dictionaries are defined using curly brackets ({...}) and lists are defined using square brackets (\[...\]). When we look at the request in JSON format, we can see this this is quite a lot of text arranged in nested dicts and lists:


```python
site_json
```




    {'data': {'siteCode': 'TEAK',
      'siteName': 'Lower Teakettle Site, RELOCATABLE',
      'siteDescription': 'Lower Teakettle',
      'siteType': 'RELOCATABLE',
      'siteLatitude': 37.00583,
      'siteLongitude': -119.00602,
      'stateCode': 'CA',
      'stateName': 'California',
      'domainCode': 'D17',
      'domainName': 'Pacific Southwest',
      'dataProducts': [{'dataProductCode': 'DP1.00001.001',
        'dataProductTitle': '2D wind speed and direction',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00002.001',
        'dataProductTitle': 'Single aspirated air temperature',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00002.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00003.001',
        'dataProductTitle': 'Triple aspirated air temperature',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00003.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00004.001',
        'dataProductTitle': 'Barometric pressure',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00004.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00005.001',
        'dataProductTitle': 'IR biological temperature',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00005.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00006.001',
        'dataProductTitle': 'Precipitation',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00006.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00014.001',
        'dataProductTitle': 'Shortwave radiation (direct and diffuse pyranometer)',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00014.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00023.001',
        'dataProductTitle': 'Shortwave and longwave radiation (net radiometer)',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00023.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00024.001',
        'dataProductTitle': 'Photosynthetically active radiation (PAR)',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00024.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00033.001',
        'dataProductTitle': 'Phenology images',
        'availableMonths': ['2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00033.001/TEAK/2020-08']},
       {'dataProductCode': 'DP1.00040.001',
        'dataProductTitle': 'Soil heat flux plate',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00040.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00041.001',
        'dataProductTitle': 'Soil temperature',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00041.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00042.001',
        'dataProductTitle': 'Snow depth and understory phenology images',
        'availableMonths': ['2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00042.001/TEAK/2020-08']},
       {'dataProductCode': 'DP1.00066.001',
        'dataProductTitle': 'Photosynthetically active radiation (quantum line)',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00066.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00094.001',
        'dataProductTitle': 'Soil water content and water salinity',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00094.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00095.001',
        'dataProductTitle': 'Soil CO2 concentration',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2020-08',
         'https://data.neonscience.org/api/v0/data/DP1.00095.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.00096.001',
        'dataProductTitle': 'Soil physical and chemical properties, Megapit',
        'availableMonths': ['2016-08'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00096.001/TEAK/2016-08']},
       {'dataProductCode': 'DP1.00098.001',
        'dataProductTitle': 'Relative humidity',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.00098.001/TEAK/2020-09']},
       {'dataProductCode': 'DP1.10003.001',
        'dataProductTitle': 'Breeding landbird point counts',
        'availableMonths': ['2017-06', '2018-06', '2019-06', '2019-07'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2019-07']},
       {'dataProductCode': 'DP1.10017.001',
        'dataProductTitle': 'Digital hemispheric photos of plot vegetation',
        'availableMonths': ['2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10017.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.10017.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10017.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10017.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.10017.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.10017.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP1.10017.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.10017.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.10017.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.10017.001/TEAK/2020-08']},
       {'dataProductCode': 'DP1.10022.001',
        'dataProductTitle': 'Ground beetles sampled from pitfall traps',
        'availableMonths': ['2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2020-05',
         '2020-06',
         '2020-07',
         '2020-08'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10022.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10022.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10022.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.10022.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.10022.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.10022.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.10022.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.10022.001/TEAK/2020-08']},
       {'dataProductCode': 'DP1.10023.001',
        'dataProductTitle': 'Herbaceous clip harvest',
        'availableMonths': ['2019-07', '2019-08', '2019-09', '2019-11', '2020-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10023.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10023.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10023.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.10023.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP1.10023.001/TEAK/2020-06']},
       {'dataProductCode': 'DP1.10033.001',
        'dataProductTitle': 'Litterfall and fine woody debris production and chemistry',
        'availableMonths': ['2019-07', '2019-08', '2019-09', '2019-10', '2019-11'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10033.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10033.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10033.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.10033.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.10033.001/TEAK/2019-11']},
       {'dataProductCode': 'DP1.10038.001',
        'dataProductTitle': 'Mosquito sequences DNA barcode',
        'availableMonths': ['2019-07', '2019-08', '2019-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10038.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10038.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10038.001/TEAK/2019-09']},
       {'dataProductCode': 'DP1.10043.001',
        'dataProductTitle': 'Mosquitoes sampled from CO2 traps',
        'availableMonths': ['2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2020-06',
         '2020-07',
         '2020-08'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10043.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.10043.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10043.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10043.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.10043.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.10043.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.10043.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.10043.001/TEAK/2020-08']},
       {'dataProductCode': 'DP1.10045.001',
        'dataProductTitle': 'Non-herbaceous perennial vegetation structure',
        'availableMonths': ['2015-08', '2015-09', '2015-10'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10045.001/TEAK/2015-08',
         'https://data.neonscience.org/api/v0/data/DP1.10045.001/TEAK/2015-09',
         'https://data.neonscience.org/api/v0/data/DP1.10045.001/TEAK/2015-10']},
       {'dataProductCode': 'DP1.10055.001',
        'dataProductTitle': 'Plant phenology observations',
        'availableMonths': ['2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2020-03'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10055.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.10055.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10055.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10055.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.10055.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.10055.001/TEAK/2020-03']},
       {'dataProductCode': 'DP1.10058.001',
        'dataProductTitle': 'Plant presence and percent cover',
        'availableMonths': ['2017-07', '2019-07', '2019-08', '2019-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10058.001/TEAK/2017-07',
         'https://data.neonscience.org/api/v0/data/DP1.10058.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10058.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10058.001/TEAK/2019-09']},
       {'dataProductCode': 'DP1.10064.001',
        'dataProductTitle': 'Rodent-borne pathogen status',
        'availableMonths': ['2019-07', '2019-08', '2019-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10064.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10064.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10064.001/TEAK/2019-09']},
       {'dataProductCode': 'DP1.10066.001',
        'dataProductTitle': 'Root biomass and chemistry, Megapit',
        'availableMonths': ['2016-08'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10066.001/TEAK/2016-08']},
       {'dataProductCode': 'DP1.10072.001',
        'dataProductTitle': 'Small mammal box trapping',
        'availableMonths': ['2019-07',
         '2019-08',
         '2019-09',
         '2020-06',
         '2020-07',
         '2020-08'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10072.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10072.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10072.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.10072.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.10072.001/TEAK/2020-07',
         'https://data.neonscience.org/api/v0/data/DP1.10072.001/TEAK/2020-08']},
       {'dataProductCode': 'DP1.10076.001',
        'dataProductTitle': 'Small mammal sequences DNA barcode',
        'availableMonths': ['2019-07', '2019-08', '2019-09'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10076.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10076.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10076.001/TEAK/2019-09']},
       {'dataProductCode': 'DP1.10086.001',
        'dataProductTitle': 'Soil physical and chemical properties, periodic',
        'availableMonths': ['2019-06', '2019-07', '2019-10', '2020-05'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10086.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.10086.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP1.10086.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP1.10086.001/TEAK/2020-05']},
       {'dataProductCode': 'DP1.10093.001',
        'dataProductTitle': 'Ticks sampled using drag cloths',
        'availableMonths': ['2019-06',
         '2019-08',
         '2019-09',
         '2020-05',
         '2020-06',
         '2020-08'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10093.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP1.10093.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP1.10093.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP1.10093.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP1.10093.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP1.10093.001/TEAK/2020-08']},
       {'dataProductCode': 'DP1.10098.001',
        'dataProductTitle': 'Woody plant vegetation structure',
        'availableMonths': ['2015-08', '2015-09', '2015-10'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10098.001/TEAK/2015-08',
         'https://data.neonscience.org/api/v0/data/DP1.10098.001/TEAK/2015-09',
         'https://data.neonscience.org/api/v0/data/DP1.10098.001/TEAK/2015-10']},
       {'dataProductCode': 'DP1.10111.001',
        'dataProductTitle': 'Site management and event reporting',
        'availableMonths': ['2019-12'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.10111.001/TEAK/2019-12']},
       {'dataProductCode': 'DP1.30001.001',
        'dataProductTitle': 'LiDAR slant range waveform',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.30001.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP1.30001.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP1.30001.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.30001.001/TEAK/2019-06']},
       {'dataProductCode': 'DP1.30003.001',
        'dataProductTitle': 'Discrete return LiDAR point cloud',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.30003.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP1.30003.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP1.30003.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.30003.001/TEAK/2019-06']},
       {'dataProductCode': 'DP1.30006.001',
        'dataProductTitle': 'Spectrometer orthorectified surface directional reflectance - flightline',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.30006.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP1.30006.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP1.30006.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.30006.001/TEAK/2019-06']},
       {'dataProductCode': 'DP1.30008.001',
        'dataProductTitle': 'Spectrometer orthrorectified at-sensor radiance - flightline',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.30008.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP1.30008.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP1.30008.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.30008.001/TEAK/2019-06']},
       {'dataProductCode': 'DP1.30010.001',
        'dataProductTitle': 'High-resolution orthorectified camera imagery',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.30010.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP1.30010.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP1.30010.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP1.30010.001/TEAK/2019-06']},
       {'dataProductCode': 'DP2.30011.001',
        'dataProductTitle': 'Albedo - spectrometer - flightline',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP2.30011.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP2.30011.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP2.30011.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP2.30011.001/TEAK/2019-06']},
       {'dataProductCode': 'DP2.30012.001',
        'dataProductTitle': 'LAI - spectrometer - flightline',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP2.30012.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP2.30012.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP2.30012.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP2.30012.001/TEAK/2019-06']},
       {'dataProductCode': 'DP2.30014.001',
        'dataProductTitle': 'fPAR - spectrometer - flightline',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP2.30014.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP2.30014.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP2.30014.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP2.30014.001/TEAK/2019-06']},
       {'dataProductCode': 'DP2.30016.001',
        'dataProductTitle': 'Total biomass map - spectrometer - flightline',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP2.30016.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP2.30016.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP2.30016.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP2.30016.001/TEAK/2019-06']},
       {'dataProductCode': 'DP2.30018.001',
        'dataProductTitle': 'Canopy nitrogen - flightline',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP2.30018.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP2.30018.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP2.30018.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP2.30018.001/TEAK/2019-06']},
       {'dataProductCode': 'DP2.30019.001',
        'dataProductTitle': 'Canopy water content - flightline',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP2.30019.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP2.30019.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP2.30019.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP2.30019.001/TEAK/2019-06']},
       {'dataProductCode': 'DP2.30020.001',
        'dataProductTitle': 'Canopy xanthophyll cycle - flightline',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP2.30020.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP2.30020.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP2.30020.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP2.30020.001/TEAK/2019-06']},
       {'dataProductCode': 'DP2.30022.001',
        'dataProductTitle': 'Canopy lignin - flightline',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP2.30022.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP2.30022.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP2.30022.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP2.30022.001/TEAK/2019-06']},
       {'dataProductCode': 'DP2.30026.001',
        'dataProductTitle': 'Vegetation indices - spectrometer - flightline',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP2.30026.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP2.30026.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP2.30026.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP2.30026.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30006.001',
        'dataProductTitle': 'Spectrometer orthorectified surface directional reflectance - mosaic',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30006.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30006.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30006.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30006.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30010.001',
        'dataProductTitle': 'High-resolution orthorectified camera imagery mosaic',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30010.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30010.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30010.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30010.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30011.001',
        'dataProductTitle': 'Albedo - spectrometer - mosaic',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30011.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30011.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30011.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30011.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30012.001',
        'dataProductTitle': 'LAI - spectrometer - mosaic',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30012.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30012.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30012.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30012.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30014.001',
        'dataProductTitle': 'fPAR - spectrometer - mosaic',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30014.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30014.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30014.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30014.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30015.001',
        'dataProductTitle': 'Ecosystem structure',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30015.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30015.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30015.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30015.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30016.001',
        'dataProductTitle': 'Total biomass map - spectrometer - mosaic',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30016.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30016.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30016.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30016.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30018.001',
        'dataProductTitle': 'Canopy nitrogen - mosaic',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30018.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30018.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30018.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30018.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30019.001',
        'dataProductTitle': 'Canopy water content - mosaic',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30019.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30019.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30019.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30019.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30020.001',
        'dataProductTitle': 'Canopy xanthophyll cycle - mosaic',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30020.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30020.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30020.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30020.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30022.001',
        'dataProductTitle': 'Canopy lignin - mosaic',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30022.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30022.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30022.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30022.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30024.001',
        'dataProductTitle': 'Elevation - LiDAR',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30024.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30024.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30024.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30024.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30025.001',
        'dataProductTitle': 'Slope and Aspect - LiDAR',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30025.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30025.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30025.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30025.001/TEAK/2019-06']},
       {'dataProductCode': 'DP3.30026.001',
        'dataProductTitle': 'Vegetation indices - spectrometer - mosaic',
        'availableMonths': ['2013-06', '2017-06', '2018-06', '2019-06'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP3.30026.001/TEAK/2013-06',
         'https://data.neonscience.org/api/v0/data/DP3.30026.001/TEAK/2017-06',
         'https://data.neonscience.org/api/v0/data/DP3.30026.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP3.30026.001/TEAK/2019-06']},
       {'dataProductCode': 'DP4.00200.001',
        'dataProductTitle': 'Bundled data products - eddy covariance',
        'availableMonths': ['2018-06',
         '2018-07',
         '2018-08',
         '2018-09',
         '2018-10',
         '2018-11',
         '2018-12',
         '2019-01',
         '2019-02',
         '2019-03',
         '2019-04',
         '2019-05',
         '2019-06',
         '2019-07',
         '2019-08',
         '2019-09',
         '2019-10',
         '2019-11',
         '2019-12',
         '2020-01',
         '2020-02',
         '2020-03',
         '2020-04',
         '2020-05',
         '2020-06',
         '2020-07'],
        'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2018-06',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2018-07',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2018-08',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2018-09',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2018-10',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2018-11',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2018-12',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-01',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-02',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-03',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-04',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-05',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-06',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-07',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-08',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-09',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-10',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-11',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2019-12',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2020-01',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2020-02',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2020-03',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2020-04',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2020-05',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2020-06',
         'https://data.neonscience.org/api/v0/data/DP4.00200.001/TEAK/2020-07']}]}}



At the uppermost level the JSON object is a dictionary containing a single element with the label 'data'. This 'data' element in turn contains a dictionary with elements containing various pieces of information about the site. When we want to know what elements a dict contians, we can use the *.keys()* method to list the keys to each element in that dict.


```python
#Use the 'keys' method to view the component of the uppermost json dictionary
site_json.keys()
```




    dict_keys(['data'])



This output shows that the entire API response is contained within a single dict called 'data'. In order to access any of the information contained within this highest-level 'data' dict, we will need to reference that dict directly. Let's view the different keys that are available within 'data':


```python
#Access the 'data' component, and use the 'keys' method to view to componenets of the json data dictionary
site_json['data'].keys()
```




    dict_keys(['siteCode', 'siteName', 'siteDescription', 'siteType', 'siteLatitude', 'siteLongitude', 'stateCode', 'stateName', 'domainCode', 'domainName', 'dataProducts'])



The returned JSON keys includes information on site location, site type, site name and code, and the availability of different data products for the site. This last piece of information is located in the element with the 'dataProducts' key.

The 'dataProducts' element is a list of dictionaries, one for each type of NEON data product available at the site; each of these dictionaries has the same keys, but different values. Let's look at the JSON for the first entry ("\[0\]") in the list of data products:


```python
#View the first data product dictionary
site_json['data']['dataProducts'][0]
```




    {'dataProductCode': 'DP1.00001.001',
     'dataProductTitle': '2D wind speed and direction',
     'availableMonths': ['2018-06',
      '2018-07',
      '2018-08',
      '2018-09',
      '2018-10',
      '2018-11',
      '2018-12',
      '2019-01',
      '2019-02',
      '2019-03',
      '2019-04',
      '2019-05',
      '2019-06',
      '2019-07',
      '2019-08',
      '2019-09',
      '2019-10',
      '2019-11',
      '2019-12',
      '2020-01',
      '2020-02',
      '2020-03',
      '2020-04',
      '2020-05',
      '2020-06',
      '2020-07',
      '2020-08',
      '2020-09'],
     'availableDataUrls': ['https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-06',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-07',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-08',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-09',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-10',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-11',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2018-12',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-01',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-02',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-03',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-04',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-05',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-06',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-07',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-08',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-09',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-10',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-11',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2019-12',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-01',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-02',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-03',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-04',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-05',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-06',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-07',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-08',
      'https://data.neonscience.org/api/v0/data/DP1.00001.001/TEAK/2020-09']}



Lists are a type of sequential data, so we can use Python's *for* loop to directly go through every element one by one, in this case to print out the data product code and data product name.


```python
#View product code and name for every available data product
for product in site_json['data']['dataProducts']:
    print(product['dataProductCode'],product['dataProductTitle'])
```

    DP1.00001.001 2D wind speed and direction
    DP1.00002.001 Single aspirated air temperature
    DP1.00003.001 Triple aspirated air temperature
    DP1.00004.001 Barometric pressure
    DP1.00005.001 IR biological temperature
    DP1.00006.001 Precipitation
    DP1.00014.001 Shortwave radiation (direct and diffuse pyranometer)
    DP1.00023.001 Shortwave and longwave radiation (net radiometer)
    DP1.00024.001 Photosynthetically active radiation (PAR)
    DP1.00033.001 Phenology images
    DP1.00040.001 Soil heat flux plate
    DP1.00041.001 Soil temperature
    DP1.00042.001 Snow depth and understory phenology images
    DP1.00066.001 Photosynthetically active radiation (quantum line)
    DP1.00094.001 Soil water content and water salinity
    DP1.00095.001 Soil CO2 concentration
    DP1.00096.001 Soil physical and chemical properties, Megapit
    DP1.00098.001 Relative humidity
    DP1.10003.001 Breeding landbird point counts
    DP1.10017.001 Digital hemispheric photos of plot vegetation
    DP1.10022.001 Ground beetles sampled from pitfall traps
    DP1.10023.001 Herbaceous clip harvest
    DP1.10033.001 Litterfall and fine woody debris production and chemistry
    DP1.10038.001 Mosquito sequences DNA barcode
    DP1.10043.001 Mosquitoes sampled from CO2 traps
    DP1.10045.001 Non-herbaceous perennial vegetation structure
    DP1.10055.001 Plant phenology observations
    DP1.10058.001 Plant presence and percent cover
    DP1.10064.001 Rodent-borne pathogen status
    DP1.10066.001 Root biomass and chemistry, Megapit
    DP1.10072.001 Small mammal box trapping
    DP1.10076.001 Small mammal sequences DNA barcode
    DP1.10086.001 Soil physical and chemical properties, periodic
    DP1.10093.001 Ticks sampled using drag cloths
    DP1.10098.001 Woody plant vegetation structure
    DP1.10111.001 Site management and event reporting
    DP1.30001.001 LiDAR slant range waveform
    DP1.30003.001 Discrete return LiDAR point cloud
    DP1.30006.001 Spectrometer orthorectified surface directional reflectance - flightline
    DP1.30008.001 Spectrometer orthrorectified at-sensor radiance - flightline
    DP1.30010.001 High-resolution orthorectified camera imagery
    DP2.30011.001 Albedo - spectrometer - flightline
    DP2.30012.001 LAI - spectrometer - flightline
    DP2.30014.001 fPAR - spectrometer - flightline
    DP2.30016.001 Total biomass map - spectrometer - flightline
    DP2.30018.001 Canopy nitrogen - flightline
    DP2.30019.001 Canopy water content - flightline
    DP2.30020.001 Canopy xanthophyll cycle - flightline
    DP2.30022.001 Canopy lignin - flightline
    DP2.30026.001 Vegetation indices - spectrometer - flightline
    DP3.30006.001 Spectrometer orthorectified surface directional reflectance - mosaic
    DP3.30010.001 High-resolution orthorectified camera imagery mosaic
    DP3.30011.001 Albedo - spectrometer - mosaic
    DP3.30012.001 LAI - spectrometer - mosaic
    DP3.30014.001 fPAR - spectrometer - mosaic
    DP3.30015.001 Ecosystem structure
    DP3.30016.001 Total biomass map - spectrometer - mosaic
    DP3.30018.001 Canopy nitrogen - mosaic
    DP3.30019.001 Canopy water content - mosaic
    DP3.30020.001 Canopy xanthophyll cycle - mosaic
    DP3.30022.001 Canopy lignin - mosaic
    DP3.30024.001 Elevation - LiDAR
    DP3.30025.001 Slope and Aspect - LiDAR
    DP3.30026.001 Vegetation indices - spectrometer - mosaic
    DP4.00200.001 Bundled data products - eddy covariance


Typically, we use site queries to determine for which months a particular data product is available at a particular site. Let's look for the availability of Breeding Landbird Counts (DP1.10003.001)


```python
#Look at Breeding Landbird Count data products
PRODUCTCODE = 'DP1.10003.001'
```

For each data product, there will be a list of the months for which data of that type was collected and it available at the site, and a corresponding list with the URLs that we would put into the API to get data on that month of data products.


```python
#Get available months of Breeding Landbird Count data products for TEAK site
#Loop through the 'dataProducts' list items (each one a dict) at the site
for product in site_json['data']['dataProducts']: 
    if(product['dataProductCode'] == PRODUCTCODE): #If a list item's 'dataProductCode' dict element equals the product code string,
        print('Available Months: ',product['availableMonths']) #print the available months and URLs
        print('URLs for each Month: ', product['availableDataUrls'])
```

    Available Months:  ['2017-06', '2018-06', '2019-06', '2019-07']
    URLs for each Month:  ['https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2017-06', 'https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2018-06', 'https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2019-06', 'https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2019-07']


## Data Product Querying

Alternatively, we may want a specific type of data product, but aren't certain of the sites and months for which that data is available. In this case we can use the product code and the *products/* API endpoint to look up availbility.


```python
#Make request
product_request = requests.get(SERVER+'products/'+PRODUCTCODE)
product_json = product_request.json()
```

The product JSON will again store everything first in a 'data' element. Within this container, the product data is a dictionary with information on the data product we are looking up.


```python
#Print keys for product data dictionary
print(product_json['data'].keys())
```

    dict_keys(['productCodeLong', 'productCode', 'productCodePresentation', 'productName', 'productDescription', 'productStatus', 'productCategory', 'productHasExpanded', 'productScienceTeamAbbr', 'productScienceTeam', 'productPublicationFormatType', 'productAbstract', 'productDesignDescription', 'productStudyDescription', 'productBasicDescription', 'productExpandedDescription', 'productSensor', 'productRemarks', 'themes', 'changeLogs', 'specs', 'keywords', 'siteCodes'])


This request returned a lot of different types of information. Much of this information is meant to provide explanations and context for the data product. Let's look at the abstract, which provides a relatively brief description of the data product.


```python
#Print code, name, and abstract of data product
print(product_json['data']['productCode'])
print(product_json['data']['productName'])
print()
print(product_json['data']['productAbstract'])
```

    DP1.10003.001
    Breeding landbird point counts
    
    This data product contains the quality-controlled, native sampling resolution data from NEON's breeding landbird sampling. Breeding landbirds are defined as “smaller birds (usually exclusive of raptors and upland game birds) not usually associated with aquatic habitats” (Ralph et al. 1993). The breeding landbird point counts product provides records of species identification of all individuals observed during the 6-minute count period, as well as metadata which can be used to model detectability, e.g., weather, distances from observers to birds, and detection methods. The NEON point count method is adapted from the Integrated Monitoring in Bird Conservation Regions (IMBCR): Field protocol for spatially-balanced sampling of landbird populations (Hanni et al. 2017; http://bit.ly/2u2ChUB). For additional details, see protocol [NEON.DOC.014041](http://data.neonscience.org/api/v0/documents/NEON.DOC.014041vF): TOS Protocol and Procedure: Breeding Landbird Abundance and Diversity and science design [NEON.DOC.000916](http://data.neonscience.org/api/v0/documents/NEON.DOC.000916vB): TOS Science Design for Breeding Landbird Abundance and Diversity.
    
    Latency: The expected time from data and/or sample collection in the field to data publication is as follows, for each of the data tables (in days) in the downloaded data package. See the Data Product User Guide for more information.
     
    brd_countdata: 120
    
    brd_perpoint: 120
    
    brd_personnel: 120
    
    brd_references: 120



For looking up the availability of the data product, we want the 'siteCodes' element. This is a list with an entry for each site at which the data product is available. Each site entry is a dict whose elements includes site code, a list of months for which data is available, and a list of the API request URLs to request data for that site for a given month.


```python
#View keys of one site dictionary
print(product_json['data']['siteCodes'][0].keys())
```

    dict_keys(['siteCode', 'availableMonths', 'availableDataUrls'])


We can look up the availability of data at a particular site, and get a URL to request data for a specific month. We know from earlier that Lower Teakettle (TEAK) has the data product we want for June 2018; we can get the URL needed to request that data with nested loops through site and month lists.


```python
#View available months and corresponding API urls, then save desired URL
for site in product_json['data']['siteCodes']:
    if(site['siteCode'] == SITECODE):
        for month in zip(site['availableMonths'],site['availableDataUrls']): #Loop through the list of months and URLs
            print(month[0],month[1]) 
            if(month[0] == '2018-06'): #If data is available for the desired month, save the URL
                data_url = month[1]
    
```

    2017-06 https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2017-06
    2018-06 https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2018-06
    2019-06 https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2019-06
    2019-07 https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2019-07



```python
print(data_url)
```

    https://data.neonscience.org/api/v0/data/DP1.10003.001/TEAK/2018-06


## Data File Querying

We now know that landbird count data products are available for 2018-06 at the Lower Teakettle site. Using the server url, site code, product code, and a year-month argument, we can make a request to the *data/* endpoint of the NEON API. This will allow us to see what specific landbird count data files can be obtained for 2018-06 at the Lower Teakettle site, and to learn the locations of these files as URLs.


```python
#Make Request
data_request = requests.get(SERVER+'data/'+PRODUCTCODE+'/'+SITECODE+'/'+'2018-06')
data_json = data_request.json()
```

Alternatively we could use one of the "Available Data URLs" from a *sites/* or *products/* request, like the data_url we saved earlier.


```python
#Make request with saved url
data_request = requests.get(data_url)
data_json = data_request.json()
```


```python
#Print dict key for 'data' element of data JSON
print(data_json['data'].keys())
```

    dict_keys(['files', 'productCode', 'siteCode', 'month'])


As with the sites JSON content, the uppermost level of a data request JSON object is a dictionary whose only member has the 'data' key; this member in turn is a dictionary with the product code, the sitecode, the month, and a list of the available data files.

The 'files' list is a list of python dictionaries, one for each file available based on our query; the dictionary for each file includes an internal reference code, the file name, the size of the file in bytes, and the url at which the file is located.


```python
#View keys and values in first file dict
for key in data_json['data']['files'][0].keys(): #Loop through keys of the data file dict
    print(key,':\t', data_json['data']['files'][0][key])
```

    name :	 NEON.D17.TEAK.DP1.10003.001.2018-06.basic.20191107T153235Z.zip
    size :	 84312
    md5 :	 c9b9c73ec183a38b80702a087fb84e21
    crc32 :	 None
    url :	 https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/TEAK/20180601T000000--20180701T000000/basic/NEON.D17.TEAK.DP1.10003.001.2018-06.basic.20191107T153235Z.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20201029T175656Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20201029%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=800ef142c87bd4a76df78ae149b11733860c85db79fa1cb477faa3b7c5b9664e



```python
for file in data_json['data']['files']:
    print(file['name'])
```

    NEON.D17.TEAK.DP1.10003.001.2018-06.basic.20191107T153235Z.zip
    NEON.D17.TEAK.DP1.10003.001.variables.20191107T153235Z.csv
    NEON.D17.TEAK.DP1.10003.001.EML.20180619-20180622.20191107T153235Z.xml
    NEON.D17.TEAK.DP0.10003.001.validation.20191107T153235Z.csv
    NEON.D17.TEAK.DP1.10003.001.brd_perpoint.2018-06.basic.20191107T153235Z.csv
    NEON.D17.TEAK.DP1.10003.001.readme.20191107T153235Z.txt
    NEON.D17.TEAK.DP1.10003.001.brd_countdata.2018-06.basic.20191107T153235Z.csv
    NEON.D17.TEAK.DP1.10003.001.2018-06.expanded.20191107T153235Z.zip
    NEON.D17.TEAK.DP1.10003.001.readme.20191107T153235Z.txt
    NEON.D17.TEAK.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153235Z.csv
    NEON.D17.TEAK.DP1.10003.001.EML.20180619-20180622.20191107T153235Z.xml
    NEON.Bird_Conservancy_of_the_Rockies.brd_personnel.csv
    NEON.D17.TEAK.DP1.10003.001.brd_perpoint.2018-06.expanded.20191107T153235Z.csv
    NEON.D17.TEAK.DP0.10003.001.validation.20191107T153235Z.csv
    NEON.D17.TEAK.DP1.10003.001.brd_references.expanded.20191107T153235Z.csv
    NEON.D17.TEAK.DP1.10003.001.variables.20191107T153235Z.csv


A number of different files are available, but the actual count data are in files which have 'brd_perpoint' or 'brd_countdata' in the file name. 

We can use *if* statements to get info on only these files. The Python **in** operator, in addition to being part of the construction of for loops, can check if a particular value is present in a sequence, so it can check if a particular series of characters is present in a string.


```python
for file in data_json['data']['files']:
    if(('_perpoint' in file['name'])|('_countdata' in file['name'])): #if file name includes '_perpoint' or '_countdata'
        print(file['name'],file['url'])
```

    NEON.D17.TEAK.DP1.10003.001.brd_perpoint.2018-06.basic.20191107T153235Z.csv https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/TEAK/20180601T000000--20180701T000000/basic/NEON.D17.TEAK.DP1.10003.001.brd_perpoint.2018-06.basic.20191107T153235Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20201029T175656Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=pub-internal-read%2F20201029%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=1193770acd201d1e20b5c9252d217d3c7950a613dacef6c908df8d980d48d2b2
    NEON.D17.TEAK.DP1.10003.001.brd_countdata.2018-06.basic.20191107T153235Z.csv https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/TEAK/20180601T000000--20180701T000000/basic/NEON.D17.TEAK.DP1.10003.001.brd_countdata.2018-06.basic.20191107T153235Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20201029T175656Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20201029%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=9820745fe8e5132f7c40fe0f9cb92757043850a770d09557b437c0bb496a8180
    NEON.D17.TEAK.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153235Z.csv https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/TEAK/20180601T000000--20180701T000000/expanded/NEON.D17.TEAK.DP1.10003.001.brd_countdata.2018-06.expanded.20191107T153235Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20201029T175656Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20201029%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=98f4e33b3d4143da4690ed7cacac1d694996ad65a87b0f518a646b110dc6c236
    NEON.D17.TEAK.DP1.10003.001.brd_perpoint.2018-06.expanded.20191107T153235Z.csv https://neon-prod-pub-1.s3.data.neonscience.org/NEON.DOM.SITE.DP1.10003.001/PROV/TEAK/20180601T000000--20180701T000000/expanded/NEON.D17.TEAK.DP1.10003.001.brd_perpoint.2018-06.expanded.20191107T153235Z.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20201029T175656Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=pub-internal-read%2F20201029%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=53b04340c6e8190cb4a18c06d7f00f5934387c1ef513c717bf03611dc6aa42a4


We can download the desired files by simply going to the obtained URLs in any browser. However, we might want the Python script to download the files for us. Alternatively, depending on the type of file, various funcitons exist that could read data from the file directly into Python. We'll dicuss this, along with how to identify which file we want, in the next tutorial.
