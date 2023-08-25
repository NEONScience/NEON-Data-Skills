# -*- coding: utf-8 -*-
"""
Created on Mon Apr  8 08:18:00 2019
@author: bhass

Functions to display available urls and download NEON AOP data using the NEON Data API.
"""

import requests, urllib, os

class AopApiHandler:
    def __init__(self, token=None, release_tag=None):
        self.base_url = 'https://data.neonscience.org/api/v0/'
        self.data_url = self.base_url + 'data'
        self.product_url = self.base_url + 'products'
        self.token = token
        self.release_tag = release_tag
        # determine this dynamically from the API? don't think you can query it directly by data product though
        # LATEST requires elevated permissions (internal use only)
        self.valid_aop_releases = ['RELEASE-2023', 'LATEST'] 

    def construct_product_url(self, dpid):
        # Construct the base product URL
        url = f"{self.product_url}"

        # Add the data product ID
        url += f"/{dpid}"

        return url

    def get_full_data_url(self, data_url):
        # Check if the provided release tag is valid
        if self.release_tag and self.release_tag not in self.valid_release_tags:
            print("Invalid release tag provided.")
            return None

        # Add the release tag if it's provided and valid
        if self.release_tag:
            if '?' in data_url:
                data_url += f"&release={self.release_tag}"
            else:
                data_url += f"?release={self.release_tag}"

        # Add the token if it's provided
        if self.token:
            data_url += f"?apiToken={self.token}"

        return data_url

    def make_request(self, url):
        # Make the API request
        try:
            response = requests.get(url)

            # Check for successful response
            if response.status_code == 200:
                return response.json()
            else:
                print(
                    f"Request failed with status code {response.status_code}")
                return None
        except Exception as e:
            print(f"An error occurred: {str(e)}")
            return None
        
    def list_sites_by_product(self, dpid):
        """
        list_all_available_sites lists all the available sites for a given data product id (dpid)
        --------
        Inputs:
            product: the data product code (eg. 'DP3.30015.001' - CHM)
        --------
        Usage:
        --------
        jorn_chm_urls = list_available_urls('DP3.30015.001')
        """
        product_url = self.construct_product_url(dpid)
        r = self.make_request(product_url)
        site_codes = []
        for i in range(len(r['data']['siteCodes'])):
            site_code = r['data']['siteCodes'][i]['siteCode']
            site_codes.append(site_code)
        return site_codes
    
    def list_urls_by_product(self, dpid):
        """
        list_urls_by_product lists all the available api url for a given data product id (dpid)
        --------
        Inputs:
            product: the data product code (eg. 'DP3.30015.001' - CHM)
        --------
        Usage:
        --------
        jorn_chm_urls = list_urls_by_product('DP3.30015.001')
        """
        product_url = self.construct_product_url(dpid)
        # print(product_url)
        r = self.make_request(product_url)
        data_urls = []
        for i in range(len(r['data']['siteCodes'])):
            data_urls_temp = r['data']['siteCodes'][i]['availableDataUrls']
            data_urls.extend(data_urls_temp)

        return data_urls
 
    def list_urls_by_product_site(self, dpid, site, year=None):
        """
        list_urls_by_product_site lists the api url for a given data product id (dpid) and site id (site)
        --------
        Inputs:
            dpid: the data product code (eg. 'DP3.30015.001' - CHM)
            site: the 4-digit NEON site code (eg. 'SRER', 'JORN')
            year (optional): string of the year ('2013' to present)
        --------
        Usage:
        --------
        jorn_chm_urls = urls_by_product_site('DP3.30015.001','JORN')
        """
        product_url = self.construct_product_url(dpid)
        # print(product_url)
        r = self.make_request(product_url)
        for i in range(len(r['data']['siteCodes'])):
            if site in r['data']['siteCodes'][i]['siteCode']:
                data_urls=r['data']['siteCodes'][i]['availableDataUrls']
        if year:
            data_urls = [url for url in data_urls if year in url]
        if len(data_urls)==0:
            print('WARNING: no urls found for product ' + dpid + ' at site ' + site)
        else:
            return data_urls   
    
    def download_urls(self, url_list, download_folder_root, zip=False):

        # downloads data from urls to folder, maintaining month-year folder structure
        for url in url_list:
            month = url.split('/')[-1]
            download_folder = download_folder_root + month + '/'
            
            if not os.path.exists(download_folder):
                os.makedirs(download_folder)
            full_url = self.get_full_url(url)

            print('full url',full_url)
            
            r = self.make_request(full_url)
            files=r['data']['files']
            for i in range(len(files)):
                if zip:
                    if '.zip' in files[i]['name']:
                        print('downloading ' + files[i]['name'] + ' to ' + download_folder)
                        urllib.request.urlretrieve(files[i]['url'],download_folder + files[i]['name'])
                else:
                    if '.zip' not in files[i]['name']:
                        print('downloading ' + files[i]['name'] + ' to ' + download_folder)
                        urllib.request.urlretrieve(files[i]['url'],download_folder + files[i]['name'])

    def download_file(self, url, filename):
        full_url = self.get_full_data_url(url)
        r = requests.get(full_url)
        with open(filename, 'wb') as f:
            for chunk in r.iter_content(chunk_size=1024): 
                if chunk: # filter out keep-alive new chunks
                    f.write(chunk)
        return

    def list_all_files(self, urls, ext=None):
        all_files = []
        for url in urls:
            r = requests.get(url)
            files = r.json()['data']['files']
            for i in range(len(files)):
                if ext:
                    if files[i]['name'].endswith(ext):
                        all_files.append(files[i]['name'])
                else:
                    all_files.append(files[i]['name'])
        return all_files


    def get_file_size(self, urls, match_string = None, file_list = None):
        size=int(0)
        count=int(0)
        for url in urls:
            r = requests.get(url)
            files = r.json()['data']['files']
            for i in range(len(files)):
                if match_string:
                    if match_string in files[i]['name']:
        #             print('downloading ' + files[i]['name'] + ' to ' + download_folder)
                        size += int(files[i]['size'])
                elif file_list:
                    for f in file_list:
                        if f in files[i]['name']:
                            size += int(files[i]['size'])
                            count = count + 1
                else:
                    size += int(files[i]['size'])
        if count !=0:
            print('file count: ' + str(count))
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

    def download_aop_files(self, product, site, year=None, download_folder='./data', match_string=None, check_size=True):
        """
        download_aop_files downloads NEON AOP files from the API for a given data product, site, and 
        optional year, download folder, and match_string (eg. to download only a single tile if you know the name)
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
        
        urls = self.list_urls_by_product_site(product, site, year)

        #make the download folder if it doesn't already exist
        if not os.path.exists(download_folder):
            os.makedirs(download_folder)
        
        #get the size of all the files you are planning to download
        size = self.get_file_size(urls, match_string)
        
        #prompt to continue with download after displaying the file size
        if check_size:
            if input("Do you want to continue with the download? (y/n) ") != "y":
                print('Exiting download_aop_files')
                return
        
        #download files in the urls
        for url in urls:
            full_url = self.get_full_data_url(url)
            print(full_url)
            r = self.make_request(full_url)
            files = r['data']['files']
            for i in range(len(files)):
                if match_string is not None:
                    if match_string in files[i]['name']:
                        print('downloading ' + files[i]['name'] + ' to ' + download_folder)
                        try:
                            self.download_file(files[i]['url'],os.path.join(download_folder,files[i]['name']))
                        except requests.exceptions.RequestException as e:
                            print(e)
                else:
                    try:
                        self.download_file(files[i]['url'],os.path.join(download_folder,files[i]['name']))
                    except requests.exceptions.RequestException as e:
                        print(e)

    def download_aop_file_list(self, product, site, file_list, year = None, download_folder = './data', check_size = False):
        """
        download_aop_file_list downloads a list of NEON AOP files from the API for a given data product, site, and 
        optional year and download folder
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
        list_of_files = [']
        download_aop_file_list('DP3.30015.001','JORN',year='2019',download_folder='./data/JORN_2019/CHM')
        """
        
        #get a list of the urls for a given data product, site, and year (if included)
        
        urls = self.list_urls_by_product_site(product, site, year)
        
        #make the download folder if it doesn't already exist
        if not os.path.exists(download_folder):
            os.makedirs(download_folder)
        
        #get the size of all the files to be downloaded
        #prompt to continue with download after displaying the file size
        if check_size:
            size = self.get_file_size(urls, file_list = file_list)
            if input("Do you want to continue with the download? (y/n) ") != "y":
                print('Exiting download_aop_files')
                return

        # Create a set of file names from file_list for faster lookup
        file_set = set(file_list)

        # Iterate through files in the API response and check if they are in file_list
        for url in urls:
            full_url = self.get_full_data_url(url)
            r = self.make_request(full_url)
            files = r.get('data', {}).get('files', [])
            
            for file_info in files:
                file_name = file_info.get('name', '')
                
                if file_name in file_set:
                    download_path = os.path.join(download_folder, file_name)
                    print(f'Downloading {file_name} to {download_folder}')
                    
                    try:
                        self.download_file(file_info['url'], download_path)
                    except requests.exceptions.RequestException as e:
                        print(e)
    
    def get_aop_file_urls(self, product, site, file_list, year = None):
        """
        download_aop_file_list downloads a list of NEON AOP files from the API for a given data product, site, and 
        optional year and download folder
        --------
        Inputs:
            required:
                product: the data product code (eg. 'DP3.30015.001' - CHM)
                site: the 4-digit NEON site code (eg. 'SRER', 'JORN')
            
            optional:
                year: year (eg. '2020'); default (None) is all years
                match_string: subset of data to match, need to use exact pattern for file name
                check_size: prompt to continue download (y/n) after displaying size; default = True
        --------
        Usage:
        --------
        list_of_files = [']
        download_aop_file_list('DP3.30015.001','JORN',year='2019',download_folder='./data/JORN_2019/CHM')
        """
        
        #get a list of the urls for a given data product, site, and year (if included)
        
        data_urls = self.list_urls_by_product_site(product, site, year)
               
        # Create a set of file names from file_list for faster lookup
        file_set = set(file_list)

        # Iterate through files in the API response and check if they are in file_list
        file_url_list = []
        for data_url in data_urls:
            full_data_url = self.get_full_data_url(data_url)
            # print(full_data_url)
            r = self.make_request(full_data_url)
            files = r.get('data', {}).get('files', [])
            
            for file_info in files:
                file_name = file_info.get('name', '')
                
                if file_name in file_set:
                    file_url_list.append(file_info['url'])

        return file_url_list