# -*- coding: utf-8 -*-
"""
Created on Mon Apr  8 08:18:00 2019
@author: bhass

Functions to display available urls and download NEON AOP data using the NEON Data API.
"""

import requests, urllib, os

def list_available_urls(product,site):
    """
    list_available urls lists the api url for a given product and site
    --------
     Inputs:
         product: the data product code (eg. 'DP3.30015.001' - CHM)
         site: the 4-digit NEON site code (eg. 'SRER', 'JORN')
    --------
    Usage:
    --------
    jorn_chm_urls = list_available_urls('DP3.30015.001','JORN')
    """
    r = requests.get("http://data.neonscience.org/api/v0/products/" + product)
    for i in range(len(r.json()['data']['siteCodes'])):
        if site in r.json()['data']['siteCodes'][i]['siteCode']:
            data_urls=r.json()['data']['siteCodes'][i]['availableDataUrls']
    if len(data_urls)==0:
        print('WARNING: no urls found for product ' + product + ' at site ' + site)
    else:
        return data_urls

def list_available_urls_by_year(product,site,year):
    """
    list_available urls_by_year lists the api url for a given product, site, and year
    --------
     Inputs:
         product: the data product code (eg. 'DP3.30015.001' - CHM)
         site: the 4-digit NEON site code (eg. 'SRER', 'JORN')
         year: the year data was collected (eg. '2017','2018','2019')
    --------
    Usage:
    --------
    jorn_chm_2018_url = list_available_urls_by_year('DP3.30015.001','JORN','2018')
    """
    r = requests.get("http://data.neonscience.org/api/v0/products/" + product)
    for i in range(len(r.json()['data']['siteCodes'])):
        if site in r.json()['data']['siteCodes'][i]['siteCode']:
            all_data_urls=r.json()['data']['siteCodes'][i]['availableDataUrls']
    data_urls = [url for url in all_data_urls if year in url]
    if len(data_urls)==0:
        print('WARNING: no urls found for product ' + product + ' at site ' + site + ' in year ' + year)
    else:
        return data_urls
    
def download_urls(url_list,download_folder_root,zip=False):
    # downloads data from urls to folder, maintaining month-year folder structure
    for url in url_list:
        month = url.split('/')[-1]
        download_folder = download_folder_root + month + '/'
        if not os.path.exists(download_folder):
            os.makedirs(download_folder)
        r=requests.get(url)
        files=r.json()['data']['files']
        for i in range(len(files)):
            if zip==False:
                if '.zip' not in files[i]['name']:
                    print('downloading ' + files[i]['name'] + ' to ' + download_folder)
                    urllib.request.urlretrieve(files[i]['url'],download_folder + files[i]['name'])
            elif zip==True:
                if '.zip' in files[i]['name']:
                    print('downloading ' + files[i]['name'] + ' to ' + download_folder)
                    urllib.request.urlretrieve(files[i]['url'],download_folder + files[i]['name'])

def download_file(url,filename):
    r = requests.get(url)
    with open(filename, 'wb') as f:
        for chunk in r.iter_content(chunk_size=1024): 
            if chunk: # filter out keep-alive new chunks
                f.write(chunk)
    return

def get_file_size(urls,match_string):
    size=0
    for url in urls:
        r = requests.get(url)
        files = r.json()['data']['files']
        for i in range(len(files)):
            if match_string is not None:
                if match_string in files[i]['name']:
    #             print('downloading ' + files[i]['name'] + ' to ' + download_folder)
                    size += int(files[i]['size'])
            else:
                size += int(files[i]['size'])
    if size < 10**3:
        print('Download size:',size,'bytes')
    elif size > 10**3 and size < 10**6:
        print('Download size:',round(size/(10**6),2),'kB')
    elif size > 10**6 and size < 10**9:
        print('Download size:',round(size/(10**6),2),'MB')
    elif size > 10**9 and size < 10**12:
        print('Download size:',round(size/(10**9),2),'GB')
    else:
        print('Download size:',round(size/(10**12),2),'TB')
    return size

def download_aop_files(product,site,year=None,download_folder='./data',match_string=None,check_size=True):
    """
    download_aop_files downloads NEON AOP files from the AOP for a given data product, site, and 
    optional year, download folder, and 
    --------
     Inputs:
         required:
             product: the data product code (eg. 'DP3.30015.001' - CHM)
             site: the 4-digit NEON site code (eg. 'SRER', 'JORN')
         
         optional:
             year: year (eg. '2020'); default (None) is all years
             download_folder: folder to store downloaded files; default (./data) in current directory
             match_string: subset of data to match, need to use exact pattern for file name
             check_size: prompt to continue download (y/n) after displaying size; default = True
    --------
    Usage:
    --------
    download_aop_files('DP3.30015.001','JORN','2019','./data/JORN_2019/CHM','314000_3610000_CHM.tif')
    """
    
    #get a list of the urls for a given data product, site, and year (if included)
    if year is not None:
        urls = list_available_urls_by_year(product,site,year)
    else:
        urls = list_available_urls(product,site)
    
    #make the download folder if it doesn't already exist
    if not os.path.exists(download_folder):
        os.makedirs(download_folder)
    
    #get the size of all the files you are planning to download
    size = get_file_size(urls,match_string)
    
    #prompt to continue with download after displaying the file size
    if check_size:
        if input("Do you want to continue with the download? (y/n) ") != "y":
            print('Exiting download_aop_files')
            return
    
    #download files in the urls
    for url in urls:
        r = requests.get(url)
        files = r.json()['data']['files']
        for i in range(len(files)):
            if match_string is not None:
                if match_string in files[i]['name']:
                    print('downloading ' + files[i]['name'] + ' to ' + download_folder)
                    try:
                        download_file(files[i]['url'],os.path.join(download_folder,files[i]['name']))
                    except requests.exceptions.RequestException as e:
                        print(e)
            else:
                try:
                    download_file(files[i]['url'],os.path.join(download_folder,files[i]['name']))
                except requests.exceptions.RequestException as e:
                    print(e)