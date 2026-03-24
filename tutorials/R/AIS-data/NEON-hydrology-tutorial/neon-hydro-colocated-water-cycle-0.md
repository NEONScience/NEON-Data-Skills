---
syncID: 8dba6493e148496c9402489c43873bf4
title: "NEON-CUAHSI Data Skills Demo: Exploring the Water Cycle at Co-Located Terrestrial-Aquatic Sites"	
description: Hands-on data skills demo on how to download, explore, manipulate, and visualize NEON hydrology data at co-located terrestrial and aquatic sites. Presented in collaboration with the CUAHSI cyberseminar series on April 1, 2026.	
dateCreated: 2026-03-19
authors: Zachary L. Nickerson
contributors: Nicolas M. Harrison
estimatedTime: 1.25 hours
packagesLibraries: neonUtilities, tidyverse, geosphere, plotly
topics: data-download, data-manipulation, data-visualization
subtopics: hydrology, water cycle, precipitation, groundwater, discharge
languagesTool: R, API, Python
dataProduct: DP1.00045.001, DP1.20100.001, DP1.20206.001, DP4.00130.001, DP4.00131.001, DP4.00200.001
code1:
tutorialSeries: 
urlTitle: water-cycle-colocated-sites
---





<!--html_preserve--><!DOCTYPE html>
<div class="body">
<div id="ds-objectives" markdown="1">
<h2 id="learning-objectives">Learning Objectives</h2>
<p>After completing this activity, you will be able to:</p>
<ul>
<li>Download and explore the contents of NEON hydrologic data products
from the observational and instrumented subsystems.</li>
<li>Navigate to tools and data sources for more derived data products
such as geospatial data, bundled eddy-covariance data, or data from
the airborne observation platform.</li>
<li>Understand the similarities and linkages between different NEON data
products.</li>
<li>Join and plot hydrologic data sets from the instrumented subsystem
across a terrestrial-aquatic gradient at NEON co-located sites.</li>
</ul>
<p>You can follow either the R or Python code throughout this tutorial.</p>
<ul>
<li>For R users, we recommend using R version 4+ and RStudio.</li>
<li>For Python users, we recommend using Python 3.9+.</li>
</ul>
<h2 id="set-up-install-packages" class="tabset">Set up: Install Packages</h2>
<p>Packages only need to be installed once, you can skip this step after
the first time:</p>
<h3 id="r_1">R</h3>
<ul>
<li>
<p><strong>neonUtilities</strong>: Basic functions for accessing NEON data</p>
</li>
<li>
<p><strong>tidyverse</strong>: Collection of R packages designed for data science</p>
</li>
<li>
<p><strong>geosphere</strong>: Compute distances between latitude/longitude coordinates</p>
</li>
<li>
<p><strong>plotly</strong>: Functions for producing interactive plots</p>
<p>install.packages(“neonUtilities”)</p>
<p>install.packages(“tidyverse”)</p>
<p>install.packages(“geosphere”)</p>
<p>install.packages(“plotly”)</p>
</li>
</ul>
<h3 id="python_1">Python</h3>
<ul>
<li>
<p><strong>os</strong>: Module allowing interaction with user’s operating system</p>
</li>
<li>
<p><strong>pandas</strong>: Module for working with data frames</p>
</li>
<li>
<p><strong>neonutilities</strong>: Basic functions for accessing NEON data</p>
</li>
<li>
<p><strong>matplotlib</strong>: Functions for plotting</p>
</li>
<li>
<p><strong>geopy</strong>: Compute distances between latitude/longitude coordinates</p>
</li>
<li>
<p><strong>plotly</strong>: Functions for producing interactive plots</p>
</li>
<li>
<p><strong>statsmodels</strong>: Functions for the estimation of statistical models</p>
<p>pip install os</p>
<p>pip install pandas</p>
<p>pip install neonutilities</p>
<p>pip install matplotlib</p>
<p>pip install geopy</p>
<p>pip install plotly</p>
<p>pip install statsmodels</p>
</li>
</ul>
<h2 id="additional-resources">Additional Resources</h2>
<ul>
<li><a href="https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data" target="_blank">Tutorial
for using neonUtilities from both R and Python environments.</a></li>
<li><a href="https://github.com/NEONScience/NEON-Utilities/neonUtilities" target="_blank">GitHub
repository for neonUtilities</a></li>
<li><a href="https://www.neonscience.org/sites/default/files/cheat-sheet-neonUtilities_0.pdf" target="_blank">neonUtilities
cheat sheet</a>. A quick reference guide for users.</li>
<li><a href="https://www.hydroshare.org/resource/53718072f33646fa920f1b72d7b403eb/" target="_blank">HydroShare
Collection - NEON Hydrologic Data Products: Site-Level
Resources</a>.</li>
<li><a href="https://www.youtube.com/watch?v=kJYWra3J6RU&feature=youtu.be" target="_blank">CUAHSI
Cyberseminar Series: Introduction to NEON for Hydrology - An
Overview of Hydrologic Data Products and Tools</a>. :::</li>
</ul>
<h2 id="set-up-load-packages" class="tabset">Set up: Load Packages</h2>
<h3 id="r_2">R</h3>
<pre><code>library(neonUtilities)

library(tidyverse)

library(geosphere)

library(plotly)
</code></pre>
<h3 id="python_2">Python</h3>
<pre><code>import os
import pandas as pd

import neonutilities as nu

import matplotlib.pyplot as plt

import matplotlib.dates as mdates

from geopy.distance import geodesic

import plotly.graph_objects as go

import statsmodels.api as sm

import numpy as np
</code></pre>
<h2 id="set-neon-data-portal-api-token" class="tabset">Set NEON Data Portal API Token</h2>
<p>It is recommended that NEON data users have a NEON Data Portal API token
set as an environment variable. See
<a href="https://www.neonscience.org/resources/learning-hub/tutorials/neon-api-tokens-tutorial" target="_blank">this
tutorial.</a> for instructions on obtaining a NEON API token.</p>
<h3 id="r_3">R</h3>
<pre><code>Sys.setenv(NEON_PAT=&quot;YOUR_API_TOKEN_HERE&quot;)
</code></pre>
<h3 id="python_3">Python</h3>
<pre><code>os.environ.setdefault('NEON_PAT',&quot;YOUR_API_TOKEN_HERE&quot;)
</code></pre>
<h2 id="download-amp-explore-introduction">Download &amp; Explore: Introduction</h2>
<p>In this tutorial, we will focus on one pair of co-located NEON sites
from Domain 07 - Appalachians &amp; Cumberland Plateau:</p>
<ul>
<li><a href="https://www.neonscience.org/field-sites/ornl" target="_blank">Oak
Ridge National Laboratory (ORNL) - Terrestrial</a></li>
<li><a href="https://www.neonscience.org/field-sites/walk" target="_blank">Walker
Branch (WALK) - Aquatic</a></li>
</ul>
<p>But, the workflow can be replicated for any pair of co-located sites
across the observatory that contain all the data products used in this
tutorial, which is defined by the following criteria:</p>
<ul>
<li>Aquatic site has published discharge data and has groundwater wells
installed.</li>
<li>Terrestrial site has published precipitation data.
<ul>
<li><em>Note</em>: Precipitation data are available from two different data products
depending on the collection method at a site. Check the following data
products to ensure you are downloading the correct data product for a site:
<ul>
<li><a href="https://data.neonscience.org/data-products/DP1.00044.001" target="_blank">Precipitation - weighing gauge (DP1.00044.001)</a></li>
<li><a href="https://data.neonscience.org/data-products/DP1.00045.001" target="_blank">Precipitation - tipping bucket (DP1.00045.001)</a></li>
</ul>
</li>
</ul>
</li>
<li>Terrestrial and aquatic site are within 10-km of each other.</li>
</ul>
<p>The following site pairs meet that criteria:</p>
<table>
<thead>
<tr>
<th>NEON Domain</th>
<th>Aquatic Site</th>
<th>Terrestrial Site</th>
</tr>
</thead>
<tbody>
<tr>
<td>D02</td>
<td>LEWI</td>
<td>BLAN</td>
</tr>
<tr>
<td>D02</td>
<td>POSE</td>
<td>SCBI</td>
</tr>
<tr>
<td>D03</td>
<td>FLNT</td>
<td>JERC</td>
</tr>
<tr>
<td>D06</td>
<td>KING</td>
<td>KONA</td>
</tr>
<tr>
<td>D07</td>
<td>WALK</td>
<td>ORNL</td>
</tr>
<tr>
<td>D08</td>
<td>TOMB</td>
<td>LENO</td>
</tr>
<tr>
<td>D08</td>
<td>BLWA</td>
<td>DELA</td>
</tr>
<tr>
<td>D08</td>
<td>MAYF</td>
<td>TALL</td>
</tr>
<tr>
<td>D12</td>
<td>BLDE</td>
<td>YELL</td>
</tr>
<tr>
<td>D13</td>
<td>COMO</td>
<td>NIWO</td>
</tr>
<tr>
<td>D16</td>
<td>MART</td>
<td>WREF</td>
</tr>
<tr>
<td>D17</td>
<td>BIGC</td>
<td>SOAP</td>
</tr>
</tbody>
</table>
<p>In this tutorial, we will focus on one water year of data: Water Year 2024,
defined as 2023-10-01 through 2024-09-30. And, for each data product used in
this tutorial, we will download data published in RELEASE-2026. To learn more
about the differences between released and provisional data, see the
<a href="https://www.neonscience.org/resources/learning-hub/tutorials/release-provisional-tutorial" target="_blank">Understanding Releases and Provisional Data</a> tutorial on the NEON website.</p>
<h2 id="download-amp-explore-instrumented-data-products" class="tabset">Download &amp; Explore: Instrumented Data Products</h2>
<p>For this exercise, we will download and explore one data product from the
instrumented subsystem: <a href="https://data.neonscience.org/data-products/DP1.00045.001" target="_blank">Precipitation - tipping bucket (DP1.00045.001)</a>.
This data product is published from NEON’s terrestrial sites; thus, we will use the
NEON site code ‘ORNL’.</p>
<h3 id="r_4">R</h3>
<pre><code># Download precipitation data for a single water year

ptp_r &lt;- neonUtilities::loadByProduct(dpID=&quot;DP1.00045.001&quot;,
                                      site=&quot;ORNL&quot;,
                                      startdate=&quot;2023-10&quot;,
                                      enddate=&quot;2024-09&quot;,
                                      release=&quot;RELEASE-2026&quot;,
                                      package='expanded',
                                      check.size = F,
                                      token=Sys.getenv(&quot;NEON_PAT&quot;))
</code></pre>
<h3 id="python_4">Python</h3>
<pre><code># Download precipitation data for a single water year
ptp_py = nu.load_by_product(dpid=&quot;DP1.00045.001&quot;,
                            site=&quot;ORNL&quot;,
                            startdate=&quot;2023-10&quot;,
                            enddate=&quot;2024-09&quot;,
                            release=&quot;RELEASE-2026&quot;,
                            package=&quot;expanded&quot;,
                            check_size=False,
                            token=os.environ.get(&quot;NEON_PAT&quot;))
</code></pre>
<p>Downloads from the NEON Utilities packages contain multiple files, including
data tables, metadata, and data product documentation. Let’s explore each set of
files in turn.</p>
<h3 id="files-associated-with-downloads_1" class="tabset">Files Associated with Downloads</h3>
<p>The data we’ve downloaded comes as an object that is a named list/dictionary of
objects. Let’s view the contents of the download package.</p>
<h4 id="r_5">R</h4>
<pre><code># Get all file names in the download package

names(ptp_r)
</code></pre>
<h4 id="python_5">Python</h4>
<pre><code># Get all file names in the download package
ptp_py.keys()
</code></pre>
<p>In this tutorial, we downloaded the <code>expanded</code> download package. What are the
files contained in this download package and why are they useful?</p>
<ul>
<li><code>TIPPRE_1min</code> and <code>TIPPRE_30min</code>: Includes the primary data tables of
the Precipitation - tipping bucket data product. We will dive deeper into
data tables in the next section.</li>
<li><code>sensor_positions_00045</code>: Reports the geolocation of each sensor included
in the download.</li>
<li><code>science_review_flags_00045</code>: Lists each science review flag (SRF) date
range, flag value, and justification applied to the data included in this
download.                                                                   #NH comment: justification applied to the data or the flag?</li>
<li><code>issueLog_00045</code>: Reports issues that may impact data quality, or changes
to a data product that affects one or more sites.</li>
<li><code>variables_00045</code>: This file contains all the variables found in the data
table(s) included in this download. This includes full definitions, units,
and other important information.</li>
<li><code>readme_00130</code>: The readme file provides important information relevant to
the data product and the specific instance of downloading the data.</li>
<li><code>citation_00045_RELEASE-2026</code>: Formatted citation and DOI for the data
included in this download.</li>
</ul>
<h3 id="explore-data-tables_1" class="tabset">Explore Data Tables</h3>
<p>The expanded download package for DP1.00045.001 contains two data tables
that report precipitation time series data, each reporting data at a different
temporal resolution:</p>
<ul>
<li><code>TIPPRE_1min</code>: Tipping bucket precipitation reported at a 1-min resolution</li>
<li><code>TIPPRE_30min</code>: Tipping bucket precipitation averaged to a 30-min resolution</li>
</ul>
<p>Below, we will explore the first few rows of <code>TIPPRE_30min</code>. Add to the code
below to also view other tables included in the expanded download package.</p>
<h4 id="r_6">R</h4>
<pre><code># Print the first 5 records in the time series data

print(&quot;First 5 rows of TIPPRE_30min&quot;)

head(ptp_r$TIPPRE_30min)
</code></pre>
<h4 id="python_6">Python</h4>
<pre><code># Print the first 5 records in the time series data
print(&quot;First 5 rows of TIPPRE_30min&quot;)

print(ptp_py['TIPPRE_30min'].head())
</code></pre>
<h3 id="explore-variables_1" class="tabset">Explore Variables</h3>
<p>The <code>variables_00045</code> file provides insight into the structure of each data
table and associated variables included in a download package. view the
variables file and familiarize yourself with the different fields, data types,
and units used in this data product.</p>
<h4 id="r_7">R</h4>
<pre><code># View variables file to understand data table structure

View(ptp_r$variables_00045)
</code></pre>
<h4 id="python_7">Python</h4>
<pre><code># View variables file to understand data table structure
print(ptp_py['variables_00045'])
</code></pre>
<h2 id="download-amp-explore-observational-data-products" class="tabset">Download &amp; Explore: Observational Data Products</h2>
<p>Let us now explore a hydrologic data product from the observational subsystem.
For this exercise, we move to the surface component of the hydrologic cycle.
We will download and explore hydrologic data derived from surface water
grab samples: <a href="https://data.neonscience.org/data-products/DP1.20206.001" target="_blank">Stable isotopes in surface water (DP1.20206.001)</a>.
This data product is published from NEON’s aquatic sites; thus, we will use the NEON
site code ‘WALK’.</p>
<h3 id="r_8">R</h3>
<pre><code># Download precipitation data for a single water year

asi_r &lt;- neonUtilities::loadByProduct(dpID=&quot;DP1.20206.001&quot;,
                                      site=&quot;WALK&quot;,
                                      startdate=&quot;2023-10&quot;,
                                      enddate=&quot;2024-09&quot;,
                                      release=&quot;RELEASE-2026&quot;,
                                      package='expanded',
                                      check.size = F,
                                      token=Sys.getenv(&quot;NEON_PAT&quot;))
</code></pre>
<h3 id="python_8">Python</h3>
<pre><code># Download precipitation data for a single water year
asi_py = nu.load_by_product(dpid=&quot;DP1.20206.001&quot;,
                            site=&quot;WALK&quot;,
                            startdate=&quot;2023-10&quot;,
                            enddate=&quot;2024-09&quot;,
                            release=&quot;RELEASE-2026&quot;,
                            package=&quot;expanded&quot;,
                            check_size=False,
                            token=os.environ.get(&quot;NEON_PAT&quot;))
</code></pre>

<p>Let’s do the sample exploration of the download as we did for the instrumented
data product and see what is similar and different.</p>
<h3 id="files-associated-with-downloads_2" class="tabset">Files Associated with Downloads</h3>
<h4 id="r_9">R</h4>
<pre><code># Get all file names in the download package

names(asi_r)
</code></pre>
<h4 id="python_9">Python</h4>
<pre><code># Get all file names in the download package
asi_py.keys()
</code></pre>

<p>When we view the content of the observational data product download, we notice
similarities and differences relative to the instrumented data product. For example, both
data products include <code>citation</code>, <code>variables</code>, <code>issuelog</code>, and <code>readme</code>
files. What do we notice that is different?</p>
<ul>
<li>The observational data product does not contain <code>science_review_flags</code> or
<code>sensor_positions</code> files. Those files are specific to instrumented data
products.</li>
<li>Files specific to observational data products are included:
<ul>
<li><code>categoricalCodes_20206</code>: Some variables in the data tables are
published as strings and constrained to a standardized list of values
(LOV). This file shows all the LOV options for variables published in this
data product.</li>
<li><code>validation_20206</code>: If any fields require validation prior to
publication, those validation rules are reported in this table.</li>
</ul>
</li>
<li>There are many more data tables published in this observational data product.
Let’s explore that in the next section.</li>
</ul>
<h3 id="explore-data-tables_2" class="tabset">Explore Data Tables</h3>
<p>For this sample-based observational data product, there are many more tables
published than the previous instrumented data product we explored. That is
because data are collected and published at each point along the lifetime of a
sample, from collection to analysis. Let’s break down the table structure for this
stable isotopes data product.</p>
<ul>
<li><code>asi_fieldSuperParent</code>: Field data associated with the ‘superparent’ water
sample, which is a 4-L grab samples that, once subsampled, results in
multiple observational data products, including this stable isotopes
data product.</li>
<li><code>asi_fieldData</code>: Field data associated with the stable isotopes subsample.</li>
<li><code>asi_externalLabH2OIsotopes</code>: Results of hydrogen-2 and oxygen-18 stable
isotope ratio analysis in filtered surface water samples.</li>
<li><code>asi_externalLabSummaryData</code>: Accuracy and precision data for the instrument
used in the analysis of H2O stable isotopes.</li>
<li><code>asi_POMExternalLabDataPerSample</code>: Results of carbon-13 and nitrogen-15
stable isotope ratio analysis in particulate organic matter (POM) filtered
out of surface water samples.</li>
<li><code>asi_externalLabPOMSummaryData</code>: Accuracy and precision data for the
instrument used in the analysis of POM stable isotopes.</li>
</ul>
<p>For this exercise, let’s just explore the first few rows of
<code>asi_externalLabH2OIsotopes</code>. Add to the code below to also view other tables
included in the expanded download package.</p>
<h4 id="r_10">R</h4>
<pre><code># Print the first 5 records in H2O stable isotope lab data

print(&quot;First 5 rows of asi_externalLabH2OIsotopes&quot;)

head(asi_r$asi_externalLabH2OIsotopes)
</code></pre>
<h4 id="python_10">Python</h4>
<pre><code># Print the first 5 records in H2O stable isotope lab data
print(&quot;First 5 rows of asi_externalLabH2OIsotopes&quot;)

print(asi_py['asi_externalLabH2OIsotopes'].head())
</code></pre>

<h3 id="explore-variables_2" class="tabset">Explore Variables</h3>
<h4 id="r_11">R</h4>
<pre><code># View variables file to understand data table structure

View(asi_r$variables_20206)
</code></pre>
<h4 id="python_11">Python</h4>
<pre><code># View variables file to understand data table structure
print(asi_py['variables_20206'])
</code></pre>

<h2 id="download-amp-explore-higher-level-hydrologic-data-products">Download &amp; Explore: Higher-Level Hydrologic Data Products</h2>
<p>NEON data products are processed at progressive levels. The precipitation and
stable isotopes data products are Level 1 data products, which is the lowest
level of data processing required for a NEON data product. Higher level
hydrologic data products exist that include additional processing in the form of
spatial and/or temporal interpolation, or the incorporation of algorithms or
scientific theory to derive higher-order quantities.</p>
<p><a href="https://www.neonscience.org/data-samples/data-management/data-processing" target="_blank">More information on NEON data processing levels</a>.</p>
<p>For this exercise, we will introduce three high-level hydrologic data products
and show how to download them.</p>
<h3 id="stream-morphology-maps" class="tabset">Stream morphology maps</h3>
<p>The <a href="https://data.neonscience.org/data-products/DP4.00131.001" target="_blank">Stream morphology maps (DP4.00131.001)</a>
data product is a Level 4 aquatic data product published at all NEON stream
sites. The data product includes many data tables with post-processed survey
data and links to geospatial data and site maps stored in the cloud. Let’s
download the data product and fetch the geospatial data from the cloud.</p>
<h4 id="r_12">R</h4>
<pre><code># Download stream morpholog data for the lifetime of a site

geo_r &lt;- neonUtilities::loadByProduct(dpID=&quot;DP4.00131.001&quot;,
                                      site=&quot;WALK&quot;,
                                      release=&quot;RELEASE-2026&quot;,
                                      package='basic',
                                      check.size = F,
                                      token=Sys.getenv(&quot;NEON_PAT&quot;))



# URL to download geospatial data from the cloud is stored in geo_surveySummary

# Get the URL for the most recent geomorphology survey

print(max(geo_r$geo_surveySummary$dataFilePath[
  geo_r$geo_surveySummary$surveyBoutTypeID==&quot;geomorphology&quot;
]))



# Copy and paste the URL to your browser to retrieve the data package
</code></pre>
<h4 id="python_12">Python</h4>
<pre><code># Download stream morpholog data for the lifetime of a site
geo_py = nu.load_by_product(dpid=&quot;DP4.00131.001&quot;,
                            site=&quot;WALK&quot;,
                            release=&quot;RELEASE-2026&quot;,
                            package=&quot;basic&quot;,
                            check_size=False,
                            token=os.environ.get(&quot;NEON_PAT&quot;))

# URL to download geospatial data from the cloud is stored in geo_surveySummary
# Get the URL for the most recent geomorphology survey
print(max(geo_py['geo_surveySummary']['dataFilePath'][
    geo_py['geo_surveySummary']['surveyBoutTypeID']==&quot;geomorphology&quot;
]))


# Copy and paste the URL to your browser to retrieve the data package
</code></pre>
<h3 id="net-surface-atmosphere-exchange-eddy-covariance" class="tabset">Net Surface-Atmosphere Exchange (Eddy Covariance)</h3>
<p>The net surface-atmosphere exchange data products are available for all
terrestrial sites and are bundled together in a single Level 4 data product:
<a href="https://data.neonscience.org/data-products/DP4.00200.001" target="_blank">Bundled data products - eddy covariance (DP4.00200.001)</a>.
The data packages do not contain comma separated tabular data. Rather, the data
and metadata are stored as HDF5 files.</p>
<p>To download and view bundled eddy covariance data, you cannot use the standard
R-loadByProduct() or Python-load_by_product() function. You must use a
combination of other functions available in the NEON Utilities package.</p>
<h4 id="r_13">R</h4>
<pre><code># Download precipitation data for a single water year

neonUtilities::zipsByProduct(dpID=&quot;DP4.00200.001&quot;,
                             site=&quot;ORNL&quot;,
                             startdate=&quot;2023-10&quot;,
                             enddate=&quot;2024-09&quot;,
                             release=&quot;RELEASE-2026&quot;,
                             package='basic',
                             check.size = F,
                             token=Sys.getenv(&quot;NEON_PAT&quot;))

# Stack the data download, parse to data frames and read into environment 

# defaults to stacking only L4 products

sae_r &lt;- neonUtilities::stackEddy(filepath = &quot;filesToStack00200&quot;)



# The data are stored by site name - print the header of the 'ORNL' table

head(sae_r$ORNL)
</code></pre>
<h4 id="python_13">Python</h4>
<pre><code># Download precipitation data for a single water year
nu.zips_by_product(dpid=&quot;DP4.00200.001&quot;,
                   site=&quot;ORNL&quot;,
                   startdate=&quot;2023-10&quot;,
                   enddate=&quot;2024-09&quot;,
                   release=&quot;RELEASE-2026&quot;,
                   package=&quot;basic&quot;,
                   check_size=False,
                   token=os.environ.get(&quot;NEON_PAT&quot;))

# Stack the data download, parse to data frames and read into environment 
# defaults to stacking only L4 products
# sae_py = nu.stack_eddy(filepath = &quot;filesToStack00200&quot;)

# The data is stored by site name - print the header of the 'ORNL' table
# print(sae_py[&quot;ORNL&quot;].head())
</code></pre>
<h3 id="canopy-water-indices-mosaic">Canopy Water Indices - Mosaic</h3>
<p>The <a href="https://data.neonscience.org/data-products/DP3.30019.001" target="_blank">Canopy water indices - mosaic (DP3.30019.001)</a>
is a Level 3 (spatially-interpolated) data product published from the Airborne
Observation Platform (AOP) subsystem.</p>
<p>Remote sensing data products are large, but NEON has developed many tools
to aid users in downloading and interpreting AOP data. We will not download AOP
data in this exercise. Rather, follow the links below for guides on downloading
AOP data in R, Python, and Google Earth Engine (GEE).</p>
<ul>
<li><a href="https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data#download-remote-sensing-data-byfileaop-and-bytileaop" target="_blank">Download and Explore NEON Data</a>.
<ul>
<li>Directly links to ‘Download remote sensing data: byFileAOP() and byTileAOP()’ section.</li>
</ul>
</li>
<li><a href="https://www.neonscience.org/resources/learning-hub/tutorials/intro-aop-data-google-earth-engine-gee-tutorial-series" target="_blank">Intro to AOP Data in Google Earth Engine (GEE) Tutorial Series</a>.</li>
<li><a href="https://www.neonscience.org/resources/learning-hub/tutorials/aop-data-management-releases" target="_blank">Understanding AOP Data Releases and Best Practices for AOP Data Management</a>.</li>
</ul>
<h2></h2>
<h2 id="merge-amp-visualize-the-water-cycle-at-co-located-sites">Merge &amp; Visualize: The Water Cycle at Co-Located Sites</h2>
<p>In this exercise, we will merge together three hydrologic data products, each
from a different section of the water cycle at NEON co-located sites:</p>
<ul>
<li><a href="https://data.neonscience.org/data-products/DP1.00045.001" target="_blank">Precipitation - tipping bucket (DP1.00045.001)</a>.</li>
<li><a href="https://data.neonscience.org/data-products/DP1.20100.001" target="_blank">Elevation of groundwater (DP1.20100.001)</a>.</li>
<li><a href="https://data.neonscience.org/data-products/DP4.00130.001" target="_blank">Continuous discharge (DP4.00130.001)</a>.</li>
</ul>
<p>We will download each data product, identify how each product can be related,
then merge the three data streams into a single data frame.</p>
<h3 id="download-data-products" class="tabset">Download Data Products</h3>
<p>This time, we will download the basic download packages.</p>
<h4 id="r_14">R</h4>
<pre><code># Download precipitation data for a single water year

ptp_r &lt;- neonUtilities::loadByProduct(dpID=&quot;DP1.00045.001&quot;,
                                      site=&quot;ORNL&quot;, # Terrestrial data product
                                      startdate=&quot;2023-10&quot;,
                                      enddate=&quot;2024-09&quot;,
                                      release=&quot;RELEASE-2026&quot;,
                                      package='basic',
                                      check.size = F,
                                      token=Sys.getenv(&quot;NEON_PAT&quot;))



# Download groundwater elevation data for a single water year

egw_r &lt;- neonUtilities::loadByProduct(dpID=&quot;DP1.20100.001&quot;,
                                      site=&quot;WALK&quot;, # Aquatic data product
                                      startdate=&quot;2023-10&quot;,
                                      enddate=&quot;2024-09&quot;,
                                      release=&quot;RELEASE-2026&quot;,
                                      package='basic',
                                      check.size = F,
                                      token=Sys.getenv(&quot;NEON_PAT&quot;))



# Download discharge data for a single water year

csd_r &lt;- neonUtilities::loadByProduct(dpID=&quot;DP4.00130.001&quot;,
                                      site=&quot;WALK&quot;, # Aquatic data product
                                      startdate=&quot;2023-10&quot;,
                                      enddate=&quot;2024-09&quot;,
                                      release=&quot;RELEASE-2026&quot;,
                                      package='basic',
                                      check.size = F,
                                      token=Sys.getenv(&quot;NEON_PAT&quot;))
</code></pre>
<h4 id="python_14">Python</h4>
<pre><code># Download precipitation data for a single water year
ptp_py = nu.load_by_product(dpid=&quot;DP1.00045.001&quot;,
                             site=&quot;ORNL&quot;, # Terrestrial data product
                             startdate=&quot;2023-10&quot;,
                             enddate=&quot;2024-09&quot;,
                             release=&quot;RELEASE-2026&quot;,
                             package='basic',
                             check_size=False,
                             token=os.environ.get(&quot;NEON_PAT&quot;))

# Download groundwater elevation data for a single water year
egw_py = nu.load_by_product(dpid=&quot;DP1.20100.001&quot;,
                             site=&quot;WALK&quot;, # Aquatic data product
                             startdate=&quot;2023-10&quot;,
                             enddate=&quot;2024-09&quot;,
                             release=&quot;RELEASE-2026&quot;,
                             package='basic',
                             check_size=False,
                             token=os.environ.get(&quot;NEON_PAT&quot;))

# Download discharge data for a single water year
csd_py = nu.load_by_product(dpid=&quot;DP4.00130.001&quot;,
                             site=&quot;WALK&quot;, # Aquatic data product
                             startdate=&quot;2023-10&quot;,
                             enddate=&quot;2024-09&quot;,
                             release=&quot;RELEASE-2026&quot;,
                             package='basic',
                             check_size=False,
                             token=os.environ.get(&quot;NEON_PAT&quot;))
</code></pre>
<h3 id="identify-relational-data-amp-merge" class="tabset">Identify Relational Data &amp; Merge</h3>
<p>Due to the standardized spatial and temporal designs of NEON data products,
these three instrumented data products can be related and merged in a relatively
easy fashion.</p>
<p><strong>Temporal Relationships</strong></p>
<ul>
<li>All three data products have the same temporal structure. They all have the
columns <code>startDateTime</code> and <code>endDateTime</code> in the data tables, and the
columns are all formatted the same in published data: YYYY-MM-DD HH:MM:SS
(UTC).</li>
<li>All three data products are published at a similar temporal frequency. The
precipitation and groundwater elevation products are each published at a
30-min resolution and the discharge product is published at a 15-min
resolution.</li>
<li>Therefore, merging the three tables by one of the datetime columns will
ensure the data will be temporally related.</li>
</ul>
<p><strong>Spatial Relationships</strong></p>
<ul>
<li>For this pair of co-located sites, the precipitation and discharge data
products are published at one location, but the groundwater elevation
data product is published at multiple locations.</li>
<li>For this exercise, we will use the groundwater well location that is closest
to the discharge locations. This information can easily be parsed by
comparing sensor location coordinates in the <code>sensor_positions</code> file
included in each data download.</li>
</ul>
<h4 id="r_15">R</h4>
<pre><code># In this download, there are 3 well locations that publish elevation

# There is only 1 location for discharge

# Use `geosphere` to identify which well location is closest to discharge

egw_coords &lt;- egw_r$sensor_positions_20100%&gt;%
  dplyr::distinct(locationReferenceLatitude,locationReferenceLongitude,
                  .keep_all = T)

csd_coords &lt;- csd_r$sensor_positions_00130

dist &lt;- geosphere::distHaversine(egw_coords[,c('locationReferenceLongitude',
                                               'locationReferenceLatitude')],
                                 csd_coords[,c('locationReferenceLongitude',
                                               'locationReferenceLatitude')])



# Which well is closest to the discahrge location (horizontal position - HOR)?

close_loc &lt;- egw_coords$HOR.VER[which.min(dist)]



# Let's use only the data from the closest well (subset by HOR)

egw_df &lt;- egw_r$EOG_30_min[
  egw_r$EOG_30_min$horizontalPosition== substr(close_loc,0,3),# First 3 digits = HOR
]



# Merge 3 data streams into a single data frame

# Keep the relevant data needed to plot timeseries and examine relationships

ptp_df &lt;- ptp_r$TIPPRE_30min%&gt;%
  dplyr::select(endDateTime,precipBulk,finalQF)

egw_df &lt;- egw_df%&gt;%
  dplyr::select(endDateTime,groundwaterElevMean,gWatElevFinalQF)

csd_df &lt;- csd_r$csd_15_min%&gt;%
  dplyr::select(endDateTime,dischargeContinuous,dischargeFinalQF)



wc_df &lt;- dplyr::full_join(ptp_df,egw_df)

wc_df &lt;- dplyr::full_join(wc_df,csd_df)

wc_df &lt;- wc_df[order(wc_df$endDateTime),]
</code></pre>
<h4 id="python_15">Python</h4>
<pre><code># In this download, there are 3 well locations that publish elevation
# There is only 1 location for discharge
# Use `geopy` to identify which well location is closest to discharge
from geopy.distance import geodesic

egw_coords = egw_py['sensor_positions_20100'].drop_duplicates(subset=['locationReferenceLatitude', 'locationReferenceLongitude'])

csd_coords = csd_py['sensor_positions_00130']

dist = egw_coords.apply(lambda row: geodesic((row['locationReferenceLatitude'], row['locationReferenceLongitude']), 
                                              (csd_coords.iloc[0]['locationReferenceLatitude'], csd_coords.iloc[0]['locationReferenceLongitude'])).meters, axis=1)

# Which well is closest to the discharge location (horizontal position - HOR)?
close_loc = egw_coords.loc[dist.idxmin(), 'HOR.VER']

# Let's use only the data from the closest well (subset by HOR)
egw_df = egw_py['EOG_30_min'][egw_py['EOG_30_min']['horizontalPosition'] == close_loc[:3]]  # First 3 digits = HOR

# Merge 3 data streams into a single data frame
# Keep the relevant data needed to plot timeseries and examine relationships
ptp_df = ptp_py['TIPPRE_30min'][['endDateTime', 'precipBulk', 'finalQF']]

egw_df = egw_df[['endDateTime', 'groundwaterElevMean', 'gWatElevFinalQF']]

csd_df = csd_py['csd_15_min'][['endDateTime', 'dischargeContinuous', 'dischargeFinalQF']]

wc_df = pd.merge(ptp_df, egw_df, on='endDateTime', how='outer')

wc_df = pd.merge(wc_df, csd_df, on='endDateTime', how='outer')

wc_df = wc_df.sort_values('endDateTime')
</code></pre>
<h3 id="plot-amp-download-merged-interactive-timeseries" class="tabset">Plot &amp; Download Merged Interactive Timeseries</h3>
<p>Now, let’s plot the three data streams in a single plotting field. We will use
the <code>plotly</code> package to give us the ability to interact with the plot. Check
your current working directory for the HTML file containing the plot.</p>
<h4 id="r_16">R</h4>
<pre><code># Format each y-axis

y1 &lt;- list(side='left',
           automargin=T,
           title=&quot;Discharge (L s-1)&quot;,
           tickfont=list(size=16),
           titlefont=list(size=18),
           showgrid=F,
           zeroline=F)

y2 &lt;- list(side='right',
           overlaying=&quot;y&quot;,
           automargin=T,
           title=&quot;Groundwater Elevation (m)&quot;,
           tickfont=list(size=16,color = '#CC79A7'),
           titlefont=list(size=18,color = '#CC79A7'),
           showgrid=F,
           zeroline=F)

y3 &lt;- list(side='right',
           overlaying=&quot;y&quot;,
           automargin=T,
           title=&quot;Precipitation (mm)&quot;,
           tickfont=list(size=16,color = &quot;#0072B2&quot;),
           titlefont=list(size=18,color = &quot;#0072B2&quot;),
           showgrid=F,
           zeroline=F,
           anchor=&quot;free&quot;,
           position=0.98)



# Build plot layout

ts &lt;- plotly::plot_ly(data=wc_df)%&gt;%
  plotly::layout(
    yaxis = y1, yaxis2 = y2, yaxis3 = y3,
    xaxis=list(domain=c(0,.9),
               tick=14,
               automargin=T,
               title=&quot;Date&quot;,
               tickfont=list(size=16),
               titlefont=list(size=18)),
    legend=list(orientation = &quot;h&quot;,
                y=-0.15,
                font=list(size=14)),
    updatemenus=list(
      list(
        type='buttons',
        showactive=FALSE,
        buttons=base::list(
          list(label='Scale Discharge\n- Linear -',
               method='relayout',
               args=list(list(yaxis=list(type='linear',
                                         title=&quot;Discharge (L s-1)&quot;,
                                         tickfont=list(size=16),
                                         titlefont=list(size=18),
                                         showgrid=F,
                                         zeroline=F)))),
          list(label='Scale Discharge\n- Log -',
               method='relayout',
               args=list(list(yaxis=list(type='log',
                                         title=&quot;Discharge (L s-1) - log&quot;,
                                         tickfont=list(size=16),
                                         titlefont=list(size=18),
                                         showgrid=F,
                                         zeroline=F))))))))



# Plot traces

ts &lt;- ts%&gt;%
  # H and Q Series
  plotly::add_trace(x=~endDateTime,y=~dischargeContinuous, 
                    name=&quot;Discharge&quot;,type='scatter',mode='line',
                    line = list(color = &quot;black&quot;))%&gt;%
  plotly::add_trace(x=~endDateTime,y=~groundwaterElevMean,
                    yaxis=&quot;y2&quot;, name=&quot;GW Elevation&quot;,type='scatter',mode='line',
                    line = list(color = '#CC79A7'))%&gt;%
  plotly::add_trace(x=~endDateTime,y=~precipBulk, yaxis=&quot;y3&quot;,
                    name=&quot;Precipitation&quot;,type='scatter',mode='line',
                    line = list(color = '#0072B2'))



htmlwidgets::saveWidget(plotly::as_widget(ts),
                        &quot;NEON.D07.P.H.Q.WY2024.html&quot;)
</code></pre>
<h4 id="python_16">Python</h4>
<pre><code># Create figure
wc_df_ts = wc_df.dropna(subset=['precipBulk'])

fig = go.Figure()

# Format axes and layout
fig.update_layout(
    margin=dict(l=90, r=110, t=40, b=60),
    
    xaxis=dict(
        domain=[0, 0.9],
        tickmode='auto',
        nticks=14,
        automargin=True,
        title=&quot;Date&quot;,
        tickfont=dict(size=16)
    ),

    yaxis=dict(
        title=&quot;Discharge (L s-1)&quot;,
        tickfont=dict(size=16),
        showgrid=False,
        zeroline=False
    ),

    yaxis2=dict(
        title=&quot;Groundwater Elevation (m)&quot;,
        tickfont=dict(size=16, color='#CC79A7'),
        showgrid=False,
        zeroline=False,
        overlaying='y',
        side='right'
    ),

    yaxis3=dict(
        title=&quot;Precipitation (mm)&quot;,
        tickfont=dict(size=16, color='#0072B2'),
        showgrid=False,
        zeroline=False,
        overlaying='y',
        side='right',
        anchor='free',
        position=0.98
    ),

    legend=dict(
        orientation=&quot;h&quot;,
        y=-0.15,
        font=dict(size=14)
    ),

    updatemenus=[
        dict(
            type='buttons',
            showactive=False,
            buttons=[
                dict(
                    label='Scale Discharge\n- Linear -',
                    method='relayout',
                    args=[{
                        'yaxis.type': 'linear',
                        'yaxis.title': &quot;Discharge (L s-1)&quot;
                    }]
                ),
                dict(
                    label='Scale Discharge\n- Log -',
                    method='relayout',
                    args=[{
                        'yaxis.type': 'log',
                        'yaxis.title': &quot;Discharge (L s-1) - log&quot;
                    }]
                )
            ]
        )
    ]
)

# Add traces
fig.add_trace(go.Scatter(
    x=wc_df_ts['endDateTime'],
    y=wc_df_ts['dischargeContinuous'],
    mode='lines',
    name='Discharge',
    line=dict(color='black')
))

fig.add_trace(go.Scatter(
    x=wc_df_ts['endDateTime'],
    y=wc_df_ts['groundwaterElevMean'],
    mode='lines',
    name='GW Elevation',
    line=dict(color='#CC79A7'),
    yaxis='y2'
))

fig.add_trace(go.Scatter(
    x=wc_df_ts['endDateTime'],
    y=wc_df_ts['precipBulk'],
    mode='lines',
    name='Precipitation',
    line=dict(color='#0072B2'),
    yaxis='y3'
))

fig.write_html(&quot;NEON.D07.P.H.Q.WY2024.html&quot;)
</code></pre>
<h3 id="further-exploration-cumulative-precipitation-amp-discharge" class="tabset">Further Exploration: Cumulative Precipitation &amp; Discharge</h3>
<h4 id="r_17">R</h4>
<pre><code># Plot cumulative precipitation &amp; discharge together using ggplot with 2 y-axes

wc_df_subset &lt;- wc_df%&gt;%
  filter(!is.na(precipBulk))

wc_df_subset$cumulativeP &lt;- cumsum(wc_df_subset$precipBulk)

wc_df_subset$cumulativeQ &lt;- cumsum(wc_df_subset$dischargeContinuous)

cumsum &lt;- wc_df_subset%&gt;%
  ggplot(aes(x = endDateTime)) +
  geom_smooth(aes(y = cumulativeP), method=&quot;loess&quot;, color = &quot;#0072B2&quot;) +
  geom_smooth(aes(y = cumulativeQ/150), method=&quot;loess&quot;, color = &quot;black&quot;) +
  scale_y_continuous(
    name = &quot;Cumulative Precipitation (mm)&quot;,
    sec.axis = sec_axis(~ .*150, name = &quot;Cumulative Discharge (L s-1)&quot;)
  ) +
  labs(x = &quot;Date&quot;) +
  theme_minimal() +
  theme(
    axis.title.y.left = element_text(color = &quot;#0072B2&quot;, size = 14),
    axis.title.y.right = element_text(color = &quot;black&quot;, size = 14)
  )

cumsum
</code></pre>
<p><img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AIS-data/NEON-hydrology-tutorial/rfigs/R-plot-wc-2-1.png" alt=" " /></p>
<h4 id="python_17">Python</h4>
<pre><code># Plot cumulative precipitation &amp; discharge together using ggplot with 2 y-axes
wc_df_subset = wc_df[~wc_df['precipBulk'].isna()].copy()

wc_df_subset['cumulativeP'] = wc_df_subset['precipBulk'].cumsum()

wc_df_subset['cumulativeQ'] = wc_df_subset['dischargeContinuous'].cumsum()

x = wc_df_subset['endDateTime']

x_numeric = x.astype(np.int64)  # nanoseconds since epoch

lowess = sm.nonparametric.lowess

smoothP = lowess(wc_df_subset['cumulativeP'], x_numeric, frac=0.3)

smoothQ = lowess(wc_df_subset['cumulativeQ'] / 150, x_numeric, frac=0.3)

fig, ax1 = plt.subplots(figsize=(10, 6))

ax1.plot(x, smoothP[:,1], color='#0072B2', label='Cumulative Precipitation (mm) – LOESS')

ax1.set_xlabel('Date', fontsize=12)

ax1.set_ylabel('Cumulative Precipitation (mm)', color='#0072B2', fontsize=12)

ax1.tick_params(axis='y', labelcolor='#0072B2')

ax2 = ax1.twinx()

ax2.plot(x, smoothQ[:,1], color='black', label='Cumulative Discharge (L s-1) – LOESS')

ax2.set_ylabel('Cumulative Discharge (L s-1)', color='black', fontsize=12)

ax2.tick_params(axis='y', labelcolor='black')

fig.tight_layout()

plt.show()
</code></pre>
<h3 id="further-exploration-correlation-of-groundwater-elevation-amp-discharge" class="tabset">Further Exploration: Correlation of Groundwater Elevation &amp; Discharge</h3>
<h4 id="r_18">R</h4>
<pre><code># Plot scatterplots of one variable to another to assess correlation

# Create a continuous color scale by date to add the time-of-year dimension

corr &lt;- wc_df %&gt;%
  ggplot(aes(x = groundwaterElevMean, y = dischargeContinuous, color = as.integer(endDateTime))) +
  geom_point(aes(color = as.Date(endDateTime))) +
  scale_color_date(low=&quot;blue&quot;,high=&quot;darkorange&quot;) +
  labs(x = &quot;Groundwater Elevation (m)&quot;, y = &quot;Discharge (L s-1)&quot;, color = &quot;Date&quot;) +
  theme_minimal()

corr
</code></pre>
<p><img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/AIS-data/NEON-hydrology-tutorial/rfigs/R-plot-wc-3-1.png" alt=" " /></p>
<h4 id="python_18">Python</h4>
<pre><code># Plot scatterplots of one variable to another to assess correlation
# Create a continuous color scale by date to add the time-of-year dimension
dates = pd.to_datetime(wc_df['endDateTime'])

date_nums = mdates.date2num(dates)

fig, ax = plt.subplots(figsize=(10, 6))

scatter = ax.scatter(
    wc_df['groundwaterElevMean'],
    wc_df['dischargeContinuous'],
    c=date_nums,
    cmap='cool',
    alpha=0.6
)

ax.set_xlabel('Groundwater Elevation (m)', fontsize=12)

ax.set_ylabel('Discharge (L s-1)', fontsize=12)

cbar = plt.colorbar(scatter, ax=ax)

cbar.set_label('Date', fontsize=12)

tick_locs = cbar.get_ticks()

cbar.ax.set_yticklabels([mdates.num2date(t).strftime('%Y-%m-%d') for t in tick_locs])

plt.tight_layout()

plt.show()
</code></pre>
</div>
</div>
</body>
</html><!--/html_preserve-->
