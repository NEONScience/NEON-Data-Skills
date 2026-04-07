---
syncID: a1388c25d16342cca2643bc2df3fbd8e
title: "Use the neonUtilities Package to Access NEON Data"
description: "Use the neonUtilities R package to download data, and to convert downloaded data from zipped month-by-site files into a table with all data of interest. Temperature data are used as an example. "
dateCreated: 2017-08-01
authors: Claire K. Lunch, Megan A. Jones
contributors: Maxwell Burner
estimatedTime: 40 minutes
packagesLibraries: neonUtilities, neonutilities
topics: data-management, rep-sci
languageTool: R, Python
dataProducts: DP1.00003.001, DP1.00002.001, DP3.30026.001
code1: 
tutorialSeries:
urlTitle: neonDataStackR

---




<!--html_preserve-->


<p>This tutorial provides an overview of functions in the
<code>neonUtilities</code> package in R and the
<code>neonutilities</code> package in Python. These packages provide a
toolbox of basic functionality for working with NEON data.</p>
<p>This tutorial is primarily an index of functions and their inputs;
for more in-depth guidance in using these functions to work with NEON
data, see the
<a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download
and Explore</a> tutorial. If you are already familiar with the
<code>neonUtilities</code> package, and need a quick reference guide to
function inputs and notation, see the
<a href="https://www.neonscience.org/sites/default/files/cheat-sheet-neonUtilities_0.pdf" target="_blank">neonUtilities
cheat sheet</a>.</p>
<div id="function-index" class="section level2 tabset">
<h2 class="tabset">Function index</h2>
<p>The <code>neonUtilities</code>/<code>neonutilities</code> package
contains several functions (use the R and Python tabs to see the syntax
in each language):</p>
<div id="r" class="section level3">
<h3>R</h3>
<ul>
<li><code>stackByTable()</code>: Takes zip files downloaded from the
<a href="http://data.neonscience.org" target="_blank">Data Portal</a> or
downloaded by <code>zipsByProduct()</code>, unzips them, and joins the
monthly files by data table to create a single file per table.</li>
<li><code>zipsByProduct()</code>: A wrapper for the
<a href="http://data.neonscience.org/data-api" target="_blank">NEON
API</a>; downloads data based on data product and site criteria. Stores
downloaded data in a format that can then be joined by
<code>stackByTable()</code>.</li>
<li><code>loadByProduct()</code>: Combines the functionality of
<code>zipsByProduct()</code>,<br />
<code>stackByTable()</code>, and <code>readTableNEON()</code>: Downloads
the specified data, stacks the files, and loads the files to the R
environment.</li>
<li><code>byFileAOP()</code>: A wrapper for the NEON API; downloads
remote sensing data based on data product, site, and year criteria.
Preserves the file structure of the original data.</li>
<li><code>byTileAOP()</code>: Downloads remote sensing data for the
specified data product, subset to tiles that intersect a list of
coordinates.</li>
<li><code>readTableNEON()</code>: Reads NEON data tables into R, using
the variables file to assign R classes to each column.</li>
<li><code>getCitation()</code>: Get a BibTeX citation for a particular
data product and release.</li>
</ul>
</div>
<div id="python" class="section level3">
<h3>Python</h3>
<ul>
<li><code>stack_by_table()</code>: Takes zip files downloaded from the
<a href="http://data.neonscience.org" target="_blank">Data Portal</a> or
downloaded by <code>zips_by_product()</code>, unzips them, and joins the
monthly files by data table to create a single file per table.</li>
<li><code>zips_by_product()</code>: A wrapper for the
<a href="http://data.neonscience.org/data-api" target="_blank">NEON
API</a>; downloads data based on data product and site criteria. Stores
downloaded data in a format that can then be joined by
<code>stack_by_table()</code>.</li>
<li><code>load_by_product()</code>: Combines the functionality of
<code>zips_by_product()</code>,<br />
<code>stack_by_table()</code>, and <code>read_table_neon()</code>:
Downloads the specified data, stacks the files, and loads the files to
the R environment.</li>
<li><code>by_file_aop()</code>: A wrapper for the NEON API; downloads
remote sensing data based on data product, site, and year criteria.
Preserves the file structure of the original data.</li>
<li><code>by_tile_aop()</code>: Downloads remote sensing data for the
specified data product, subset to tiles that intersect a list of
coordinates.</li>
<li><code>read_table_neon()</code>: Reads NEON data tables into R, using
the variables file to assign R classes to each column.</li>
<li><code>get_citation()</code>: Get a BibTeX citation for a particular
data product and release.</li>
</ul>
</div>
</div>
<div id="section" class="section level2 unnumbered">
<h2 class="unnumbered"></h2>
<div id="ds-dataTip" markdown="1">
<p><i class="fa fa-star"></i> If you are only interested in joining data
files downloaded from the NEON Data Portal, you will only need to use
<code>stackByTable()</code>. Follow the instructions in the first
section of the
<a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download
and Explore</a> tutorial.</p>
</div>
</div>
<div id="install-and-load-packages" class="section level2 tabset">
<h2 class="tabset">Install and load packages</h2>
<p>First, install and load the package. The installation step only needs
to be run once, and then periodically to update when new package
versions are released. The load step needs to be run every time you run
your code.</p>
<div id="r-1" class="section level3">
<h3>R</h3>
<pre class="r"><code>## 
## # install neonUtilities - can skip if already installed
## install.packages(&quot;neonUtilities&quot;)
## 
## # load neonUtilities
library(neonUtilities)
## </code></pre>
</div>
<div id="python-1" class="section level3">
<h3>Python</h3>
<pre class="python"><code># install neonutilities - can skip if already installed
# do this in the command line
pip install neonutilities</code></pre>
<pre class="python"><code>
# load neonutilities in working environment
import neonutilities as nu</code></pre>
</div>
</div>
<div id="section-1" class="section level2 unnumbered">
<h2 class="unnumbered"></h2>
</div>
<div id="download-files-and-load-to-working-environment" class="section level2 tabset">
<h2 class="tabset">Download files and load to working environment</h2>
<p>The most popular function in <code>neonUtilities</code> is
<code>loadByProduct()</code> (or <code>load_by_product()</code> in
<code>neonutilities</code>). This function downloads data from the NEON
API, merges the site-by-month files, and loads the resulting data tables
into the programming environment, classifying each variable’s data type
appropriately. It combines the actions of the
<code>zipsByProduct()</code>, <code>stackByTable()</code>, and
<code>readTableNEON()</code> functions, described below.</p>
<p>This is a popular choice because it ensures you’re always working
with the latest data, and it ends with ready-to-use tables. However, if
you use it in a workflow you run repeatedly, keep in mind it will
re-download the data every time.</p>
<p><code>loadByProduct()</code> works on most observational (OS) and
sensor (IS) data, but not on surface-atmosphere exchange (SAE) data,
remote sensing (AOP) data, and some of the data tables in the microbial
data products. For functions that download AOP data, see the
<code>byFileAOP()</code> and <code>byTileAOP()</code> sections in this
tutorial. For functions that work with SAE data, see the
<a href="https://www.neonscience.org/eddy-data-intro" target="_blank">NEON
eddy flux data tutorial</a>. SAE functions are not yet available in
Python.</p>
<p>The inputs to <code>loadByProduct()</code> control which data to
download and how to manage the processing:</p>
<div id="r-2" class="section level3">
<h3>R</h3>
<ul>
<li><code>dpID</code>: The data product ID, e.g. DP1.00002.001</li>
<li><code>site</code>: Defaults to “all”, meaning all sites with
available data; can be a vector of 4-letter NEON site codes, e.g. 
<code>c(&quot;HARV&quot;,&quot;CPER&quot;,&quot;ABBY&quot;)</code>.</li>
<li><code>startdate</code> and <code>enddate</code>: Defaults to NA,
meaning all dates with available data; or a date in the form YYYY-MM,
e.g.  2017-06. Since NEON data are provided in month packages, finer
scale querying is not available. Both start and end date are
inclusive.</li>
<li><code>package</code>: Either basic or expanded data package.
Expanded data packages generally include additional information about
data quality, such as chemical standards and quality flags. Not every
data product has an expanded package; if the expanded package is
requested but there isn’t one, the basic package will be
downloaded.</li>
<li><code>timeIndex</code>: Defaults to “all”, to download all data; or
the number of minutes in the averaging interval. See example below; only
applicable to IS data.</li>
<li><code>release</code>: Specify a particular data Release, e.g. 
<code>&quot;RELEASE-2024&quot;</code>. Defaults to the most recent Release. For
more details and guidance, see the
<a href="https://www.neonscience.org/resources/learning-hub/tutorials/release-provisional-tutorial" target="_blank">
Release and Provisional</a> tutorial.</li>
<li><code>include.provisional</code>: T or F: Should provisional data be
downloaded? If <code>release</code> is not specified, set to T to
include provisional data in the download. Defaults to F.</li>
<li><code>savepath</code>: the file path you want to download to;
defaults to the working directory.</li>
<li><code>check.size</code>: T or F: should the function pause before
downloading data and warn you about the size of your download? Defaults
to T; if you are using this function within a script or batch process
you will want to set it to F.</li>
<li><code>token</code>: Optional API token for faster downloads. See the
<a href="https://www.neonscience.org/resources/learning-hub/tutorials/neon-api-tokens-tutorial" target="_blank">
API token</a> tutorial.</li>
<li><code>nCores</code>: Number of cores to use for parallel processing.
Defaults to 1, i.e. no parallelization.</li>
</ul>
</div>
<div id="python-2" class="section level3">
<h3>Python</h3>
<ul>
<li><code>dpid</code>: the data product ID, e.g. DP1.00002.001</li>
<li><code>site</code>: defaults to “all”, meaning all sites with
available data; can be a list of 4-letter NEON site codes, e.g. 
<code>[&quot;HARV&quot;,&quot;CPER&quot;,&quot;ABBY&quot;]</code>.</li>
<li><code>startdate</code> and <code>enddate</code>: defaults to NA,
meaning all dates with available data; or a date in the form YYYY-MM,
e.g.  2017-06. Since NEON data are provided in month packages, finer
scale querying is not available. Both start and end date are
inclusive.</li>
<li><code>package</code>: either basic or expanded data package.
Expanded data packages generally include additional information about
data quality, such as chemical standards and quality flags. Not every
data product has an expanded package; if the expanded package is
requested but there isn’t one, the basic package will be
downloaded.</li>
<li><code>timeindex</code>: defaults to “all”, to download all data; or
the number of minutes in the averaging interval. See example below; only
applicable to IS data.</li>
<li><code>release</code>: Specify a particular data Release, e.g. 
<code>&quot;RELEASE-2024&quot;</code>. Defaults to the most recent Release. For
more details and guidance, see the
<a href="https://www.neonscience.org/resources/learning-hub/tutorials/release-provisional-tutorial" target="_blank">
Release and Provisional</a> tutorial.</li>
<li><code>include_provisional</code>: True or False: Should provisional
data be downloaded? If <code>release</code> is not specified, set to T
to include provisional data in the download. Defaults to F.</li>
<li><code>savepath</code>: the file path you want to download to;
defaults to the working directory.</li>
<li><code>check_size</code>: True or False: should the function pause
before downloading data and warn you about the size of your download?
Defaults to True; if you are using this function within a script or
batch process you will want to set it to False.</li>
<li><code>token</code>: Optional API token for faster downloads. See the
<a href="https://www.neonscience.org/resources/learning-hub/tutorials/neon-api-tokens-tutorial" target="_blank">
API token</a> tutorial.</li>
<li><code>cloud_mode</code>: Can be set to True if you are working in a
cloud environment; provides more efficient data transfer from NEON cloud
storage to other cloud environments.</li>
<li><code>progress</code>: Set to False to omit the progress bar during
download and stacking.</li>
</ul>
</div>
</div>
<div id="section-2" class="section level2 unnumbered">
<h2 class="unnumbered"></h2>
<p>The <code>dpID</code> (<code>dpid</code>) is the data product
identifier of the data you want to download. The DPID can be found on
the
<a href="http://data.neonscience.org/data-products/explore" target="_blank">
Explore Data Products page</a>. It will be in the form DP#.#####.###</p>
<div id="demo-data-download-and-read" class="section level3 tabset">
<h3 class="tabset">Demo data download and read</h3>
<p>Let’s get triple-aspirated air temperature data (DP1.00003.001) from
Moab and Onaqui (MOAB and ONAQ), from May–August 2018, and name the data
object <code>triptemp</code>:</p>
<div id="r-3" class="section level4">
<h4>R</h4>
<pre class="r"><code>triptemp &lt;- loadByProduct(dpID=&quot;DP1.00003.001&quot;, 
                          site=c(&quot;MOAB&quot;,&quot;ONAQ&quot;),
                          startdate=&quot;2018-05&quot;, 
                          enddate=&quot;2018-08&quot;)</code></pre>
</div>
<div id="python-3" class="section level4">
<h4>Python</h4>
<pre class="python"><code>triptemp = nu.load_by_product(dpid=&quot;DP1.00003.001&quot;, 
                              site=[&quot;MOAB&quot;,&quot;ONAQ&quot;],
                              startdate=&quot;2018-05&quot;, 
                              enddate=&quot;2018-08&quot;)</code></pre>
</div>
</div>
<div id="section-3" class="section level3 unnumbered">
<h3 class="unnumbered"></h3>
</div>
<div id="view-downloaded-data" class="section level3 tabset">
<h3 class="tabset">View downloaded data</h3>
<p>The object returned by <code>loadByProduct()</code> is a named list
of data tables, or a dictionary of data tables in Python. To work with
each of them, select them from the list.</p>
<div id="r-4" class="section level4">
<h4>R</h4>
<pre class="r"><code>names(triptemp)</code></pre>
<pre><code>## [1] &quot;citation_00003_RELEASE-2024&quot; &quot;issueLog_00003&quot;             
## [3] &quot;readme_00003&quot;                &quot;sensor_positions_00003&quot;     
## [5] &quot;TAAT_1min&quot;                   &quot;TAAT_30min&quot;                 
## [7] &quot;variables_00003&quot;</code></pre>
<pre class="r"><code>temp30 &lt;- triptemp$TAAT_30min</code></pre>
<p>If you prefer to extract each table from the list and work with it as
an independent object, you can use the <code>list2env()</code>
function:</p>
<pre class="r"><code>list2env(trip.temp, .GlobalEnv)</code></pre>
</div>
<div id="python-4" class="section level4">
<h4>Python</h4>
<pre class="python"><code>triptemp.keys()</code></pre>
<pre><code>## dict_keys([&#39;TAAT_1min&#39;, &#39;TAAT_30min&#39;, &#39;citation_00003_RELEASE-2024&#39;, &#39;issueLog_00003&#39;, &#39;readme_00003&#39;, &#39;sensor_positions_00003&#39;, &#39;variables_00003&#39;])</code></pre>
<pre class="python"><code>temp30 = triptemp[&quot;TAAT_30min&quot;]</code></pre>
<p>If you prefer to extract each table from the list and work with it as
an independent object, you can use<br />
<code>globals().update()</code>:</p>
<pre class="python"><code>globals().update(triptemp)</code></pre>
</div>
</div>
<div id="section-4" class="section level3 unnumbered">
<h3 class="unnumbered"></h3>
<p>For more details about the contents of the data tables and metadata
tables, check out the
<a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download
and Explore</a> tutorial.</p>
</div>
</div>
<div id="join-data-files-stackbytable" class="section level2">
<h2>Join data files: stackByTable()</h2>
<p>The function <code>stackByTable()</code> joins the month-by-site
files from a data download. The output will yield data grouped into new
files by table name. For example, the single aspirated air temperature
data product contains 1 minute and 30 minute interval data. The output
from this function is one .csv with 1 minute data and one .csv with 30
minute data.</p>
<p>Depending on your file size this function may run for a while. For
example, in testing for this tutorial, 124 MB of temperature data took
about 4 minutes to stack. A progress bar will display while the stacking
is in progress.</p>
<div id="download-the-data" class="section level3">
<h3>Download the Data</h3>
<p>To stack data from the Portal, first download the data of interest
from the <a href="http://data.neonscience.org" target="_blank"> NEON
Data Portal</a>. To stack data downloaded from the API, see the
<code>zipsByProduct()</code> section below.</p>
<p>Your data will download from the Portal in a single zipped file.</p>
<p>The stacking function will only work on zipped Comma Separated Value
(.csv) files and not the NEON data stored in other formats (HDF5,
etc).</p>
</div>
<div id="run-stackbytable" class="section level3 tabset">
<h3 class="tabset">Run <code>stackByTable()</code></h3>
<p>The example data below are single-aspirated air temperature.</p>
<p>To run the <code>stackByTable()</code> function, input the file path
to the downloaded and zipped file.</p>
<div id="r-5" class="section level4">
<h4>R</h4>
<pre class="r"><code># Modify the file path to the file location on your computer
stackByTable(filepath=&quot;~neon/data/NEON_temp-air-single.zip&quot;)</code></pre>
</div>
<div id="python-5" class="section level4">
<h4>Python</h4>
<pre class="python"><code># Modify the file path to the file location on your computer
nu.stack_by_table(filepath=&quot;/neon/data/NEON_temp-air-single.zip&quot;)</code></pre>
</div>
</div>
<div id="section-5" class="section level3 unnumbered">
<h3 class="unnumbered"></h3>
<p>In the same directory as the zipped file, you should now have an
unzipped directory of the same name. When you open this you will see a
new directory called <strong>stackedFiles</strong>. This directory
contains one or more .csv files (depends on the data product you are
working with) with all the data from the months &amp; sites you
downloaded. There will also be a single copy of the associated
variables, validation, and sensor_positions files, if applicable
(validation files are only available for observational data products,
and sensor position files are only available for instrument data
products).</p>
<p>These .csv files are now ready for use with the program of your
choice.</p>
<p>To read the data tables, we recommend using
<code>readTableNEON()</code>, which will assign each column to the
appropriate data type, based on the metadata in the variables file. This
ensures time stamps and missing data are interpreted correctly.</p>
</div>
</div>
<div id="load-data-to-environment" class="section level2 tabset">
<h2 class="tabset">Load data to environment</h2>
<div id="r-6" class="section level3">
<h3>R</h3>
<pre class="r"><code>SAAT30 &lt;- readTableNEON(
  dataFile=&#39;~/stackedFiles/SAAT_30min.csv&#39;,
  varFile=&#39;~/stackedFiles/variables_00002.csv&#39;
)</code></pre>
</div>
<div id="python-6" class="section level3">
<h3>Python</h3>
<pre class="python"><code>SAAT30 = nu.read_table_neon(
  dataFile=&#39;/stackedFiles/SAAT_30min.csv&#39;,
  varFile=&#39;/stackedFiles/variables_00002.csv&#39;
)</code></pre>
</div>
</div>
<div id="section-6" class="section level2 unnumbered">
<h2 class="unnumbered"></h2>
<div id="other-function-inputs" class="section level3 tabset">
<h3 class="tabset">Other function inputs</h3>
<p>Other input options in <code>stackByTable()</code> are:</p>
<ul>
<li><code>savepath</code> : allows you to specify the file path where
you want the stacked files to go, overriding the default. Set to
<code>&quot;envt&quot;</code> to load the files to the working environment.</li>
<li><code>saveUnzippedFiles</code> : allows you to keep the unzipped,
unstacked files from an intermediate stage of the process; by default
they are discarded.</li>
</ul>
<p>Example usage:</p>
<div id="r-7" class="section level4">
<h4>R</h4>
<pre class="r"><code>stackByTable(filepath=&quot;~neon/data/NEON_temp-air-single.zip&quot;, 
             savepath=&quot;~data/allTemperature&quot;, saveUnzippedFiles=T)

tempsing &lt;- stackByTable(filepath=&quot;~neon/data/NEON_temp-air-single.zip&quot;, 
                         savepath=&quot;envt&quot;, saveUnzippedFiles=F)</code></pre>
</div>
<div id="python-7" class="section level4">
<h4>Python</h4>
<pre class="python"><code>nu.stack_by_table(filepath=&quot;/neon/data/NEON_temp-air-single.zip&quot;, 
                  savepath=&quot;/data/allTemperature&quot;, 
                  saveUnzippedFiles=True)

tempsing &lt;- nu.stack_by_table(filepath=&quot;/neon/data/NEON_temp-air-single.zip&quot;, 
                              savepath=&quot;envt&quot;, 
                              saveUnzippedFiles=False)</code></pre>
</div>
</div>
<div id="section-7" class="section level3 unnumbered">
<h3 class="unnumbered"></h3>
</div>
</div>
<div id="download-files-to-be-stacked-zipsbyproduct" class="section level2 tabset">
<h2 class="tabset">Download files to be stacked: zipsByProduct()</h2>
<p>The function <code>zipsByProduct()</code> is a wrapper for the NEON
API, it downloads zip files for the data product specified and stores
them in a format that can then be passed on to
<code>stackByTable()</code>.</p>
<p>Input options for <code>zipsByProduct()</code> are the same as those
for <code>loadByProduct()</code> described above.</p>
<p>Here, we’ll download single-aspirated air temperature (DP1.00002.001)
data from Wind River Experimental Forest (WREF) for April and May of
2019.</p>
<div id="r-8" class="section level3">
<h3>R</h3>
<pre class="r"><code>zipsByProduct(dpID=&quot;DP1.00002.001&quot;, site=&quot;WREF&quot;, 
              startdate=&quot;2019-04&quot;, enddate=&quot;2019-05&quot;,
              package=&quot;basic&quot;, check.size=T)</code></pre>
<p>Downloaded files can now be passed to <code>stackByTable()</code> to
be stacked.</p>
<pre class="r"><code>stackByTable(filepath=paste(getwd(), 
                            &quot;/filesToStack00002&quot;, 
                            sep=&quot;&quot;))</code></pre>
</div>
<div id="python-8" class="section level3">
<h3>Python</h3>
<pre class="python"><code>nu.zips_by_product(dpid=&quot;DP1.00002.001&quot;, site=&quot;WREF&quot;, 
                   startdate=&quot;2019-04&quot;, enddate=&quot;2019-05&quot;,
                   package=&quot;basic&quot;, check_size=True)</code></pre>
<p>Downloaded files can now be passed to <code>stackByTable()</code> to
be stacked.</p>
<pre class="python"><code>nu.stack_by_table(filepath=os.getcwd()+
                  &quot;/filesToStack00002&quot;)</code></pre>
</div>
</div>
<div id="section-8" class="section level2 unnumbered">
<h2 class="unnumbered"></h2>
<p>For many sensor data products, download sizes can get very large, and
<code>stackByTable()</code> takes a long time. The 1-minute or 2-minute
files are much larger than the longer averaging intervals, so if you
don’t need high- frequency data, the <code>timeIndex</code> input option
lets you choose which averaging interval to download.</p>
<p>This option is only applicable to sensor (IS) data, since OS data are
not averaged.</p>
<div id="download-by-averaging-interval" class="section level3 tabset">
<h3 class="tabset">Download by averaging interval</h3>
<p>Download only the 30-minute data for single-aspirated air temperature
at WREF:</p>
<div id="r-9" class="section level4">
<h4>R</h4>
<pre class="r"><code>zipsByProduct(dpID=&quot;DP1.00002.001&quot;, site=&quot;WREF&quot;, 
              startdate=&quot;2019-04&quot;, enddate=&quot;2019-05&quot;,
              package=&quot;basic&quot;, timeIndex=30, 
              check.size=T)</code></pre>
</div>
<div id="python-9" class="section level4">
<h4>Python</h4>
<pre class="python"><code>nu.zips_by_product(dpid=&quot;DP1.00002.001&quot;, site=&quot;WREF&quot;, 
                   startdate=&quot;2019-04&quot;, 
                   enddate=&quot;2019-05&quot;, package=&quot;basic&quot;, 
                   timeindex=30, check_size=True)</code></pre>
</div>
</div>
<div id="section-9" class="section level3 unnumbered">
<h3 class="unnumbered"></h3>
<p>The 30-minute files can be stacked and loaded as usual.</p>
</div>
</div>
<div id="download-remote-sensing-files" class="section level2 tabset">
<h2 class="tabset">Download remote sensing files</h2>
<p>Remote sensing data files can be very large, and NEON remote sensing
(AOP) data are stored in a directory structure that makes them easier to
navigate. <code>byFileAOP()</code> downloads AOP files from the API
while preserving their directory structure. This provides a convenient
way to access AOP data programmatically.</p>
<p>Be aware that downloads from <code>byFileAOP()</code> can take a VERY
long time, depending on the data you request and your connection speed.
You may need to run the function and then leave your machine on and
downloading for an extended period of time.</p>
<p>Here the example download is the Ecosystem Structure data product at
Hop Brook (HOPB) in 2017; we use this as the example because it’s a
relatively small year-site-product combination.</p>
<div id="r-10" class="section level3">
<h3>R</h3>
<pre class="r"><code>byFileAOP(&quot;DP3.30015.001&quot;, site=&quot;HOPB&quot;, 
          year=2017, check.size=T)</code></pre>
</div>
<div id="python-10" class="section level3">
<h3>Python</h3>
<pre class="python"><code>nu.by_file_aop(dpid=&quot;DP3.30015.001&quot;, 
               site=&quot;HOPB&quot;, year=2017, 
               check_size=True)</code></pre>
</div>
</div>
<div id="section-10" class="section level2 unnumbered">
<h2 class="unnumbered"></h2>
<p>The files should now be downloaded to a new folder in your working
directory.</p>
</div>
<div id="download-remote-sensing-files-for-specific-coordinates" class="section level2 tabset">
<h2 class="tabset">Download remote sensing files for specific
coordinates</h2>
<p>Often when using remote sensing data, we only want data covering a
certain area - usually the area where we have coordinated ground
sampling. <code>byTileAOP()</code> queries for data tiles containing a
specified list of coordinates. It only works for the tiled, AKA
mosaicked, versions of the remote sensing data, i.e. the ones with data
product IDs beginning with “DP3”.</p>
<p>Here, we’ll download tiles of vegetation indices data (DP3.30026.001)
corresponding to select observational sampling plots. For more
information about accessing NEON spatial data, see the
<a href="https://www.neonscience.org/neon-api-usage" target="_blank">
API tutorial</a> and the in-development
<a href="https://github.com/NEONScience/NEON-geolocation/tree/master/geoNEON" target="_blank"> geoNEON package</a>.</p>
<p>For now, assume we’ve used the API to look up the plot centroids of
plots SOAP_009 and SOAP_011 at the Soaproot Saddle site. You can also
look these up in the Spatial Data folder of the
<a href="https://data.neonscience.org/documents" target="_blank">
document library</a>. The coordinates of the two plots in UTMs are
298755,4101405 and 299296,4101461. These are 40x40m plots, so in looking
for tiles that contain the plots, we want to include a 20m buffer. The
“buffer” is actually a square, it’s a delta applied equally to both the
easting and northing coordinates.</p>
<div id="r-11" class="section level3">
<h3>R</h3>
<pre class="r"><code>byTileAOP(dpID=&quot;DP3.30026.001&quot;, site=&quot;SOAP&quot;, 
          year=2018, easting=c(298755,299296),
          northing=c(4101405,4101461),
          buffer=20)</code></pre>
</div>
<div id="python-11" class="section level3">
<h3>Python</h3>
<pre class="python"><code>nu.by_tile_aop(dpid=&quot;DP3.30026.001&quot;, 
               site=&quot;SOAP&quot;, year=2018, 
               easting=[298755,299296],
               northing=[4101405,4101461],
               buffer=20)</code></pre>
</div>
</div>
<div id="section-11" class="section level2 unnumbered">
<h2 class="unnumbered"></h2>
<p>The 2 tiles covering the SOAP_009 and SOAP_011 plots have<br />
been downloaded.</p>
</div><!--/html_preserve-->

