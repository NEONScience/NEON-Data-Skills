---
syncID: 3857005e98a544a88a5e58625e32b514
title: "Introduction to working with NEON eddy flux data"
description: "Download and navigate NEON eddy flux data, including basic transformations and merges"
dateCreated:  2019-07-09
authors: Claire K. Lunch
contributors: 
estimatedTime: 1 hour
packagesLibraries: rhdf5, neonUtilities, ggplot2
topics: HDF5, eddy-covariance, eddy-flux
languagesTool: R
dataProduct: DP4.00200.001
code1: /R/eddy-intro/eddy_intro.r
tutorialSeries: 
urlTitle: eddy-data-intro
---

This data tutorial provides an introduction to working with NEON eddy 
flux data, using the `neonUtilities` R package. If you are new to NEON 
data, we recommend starting with a more general tutorial, such as the 
<a href="https://www.neonscience.org/neonDataStackR" target="_blank">neonUtilities tutorial</a> 
or the <a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore tutorial</a>. 
Some of the functions and techniques described in those tutorials will 
be used here, as well as functions and data formats that are unique to 
the eddy flux system.

This tutorial assumes general familiarity with eddy flux data and 
associated concepts.

## 1. Setup

Start by installing and loading packages and setting options. 
To work with the NEON flux data, we need the `rhdf5` package, 
which is hosted on Bioconductor, and requires a different 
installation process than CRAN packages:


```R
install.packages('BiocManager')
BiocManager::install('rhdf5')
install.packages('neonUtilities')
```


```R
options(stringsAsFactors=F)

library(neonUtilities)
```

Use the `zipsByProduct()` function from the `neonUtilities` package to 
download flux data from two sites and two months. The transformations 
and functions below will work on any time range and site(s), but two 
sites and two months allows us to see all the available functionality 
while minimizing download size.

Inputs to the `zipsByProduct()` function:

* `dpID`: DP4.00200.001, the bundled eddy covariance product
* `package`: basic (the expanded package is not covered in this tutorial)
* `site`: NIWO = Niwot Ridge and HARV = Harvard Forest
* `startdate`: 2018-06 (both dates are inclusive)
* `enddate`: 2018-07 (both dates are inclusive)
* `savepath`: modify this to something logical on your machine
* `check.size`: T if you want to see file size before downloading, otherwise F

The download may take a while, especially if you're on a slow network.


```R
zipsByProduct(dpID="DP4.00200.001", package="basic", 
              site=c("NIWO", "HARV"), 
              startdate="2018-06", enddate="2018-07",
              savepath="/data", 
              check.size=F)
```

    Downloading files totaling approximately 313.289221 MB
    Downloading 4 files
      |======================================================================| 100%
    4 files downloaded to /data/filesToStack00200


## 2. Data Levels

There are five levels of data contained in the eddy flux bundle. For full 
details, refer to the <a href="http://data.neonscience.org/api/v0/documents/NEON.DOC.004571vA" target="_blank">NEON algorithm document</a>.

Briefly, the data levels are:

* Level 0' (dp0p): Calibrated raw observations
* Level 1 (dp01): Time-aggregated observations, e.g. 30-minute mean gas concentrations
* Level 2 (dp02): Time-interpolated data, e.g. rate of change of a gas concentration
* Level 3 (dp03): Spatially interpolated data, i.e. vertical profiles
* Level 4 (dp04): Fluxes

The dp0p data are available in the expanded data package and are beyond 
the scope of this tutorial.

The dp02 and dp03 data are used in storage calculations, and the dp04 data 
include both the storage and turbulent components. Since many users will 
want to focus on the net flux data, we'll start there.

## 3. Extract Level 4 data (Fluxes!)

To extract the Level 4 data from the HDF5 files and merge them into a 
single table, we'll use the `stackEddy()` function from the `neonUtilities` 
package.

`stackEddy()` requires two inputs:

* `filepath`: Path to a file or folder, which can be any one of:
    1. A zip file of eddy flux data downloaded from the NEON data portal
    2. A folder of eddy flux data downloaded by the `zipsByProduct()` function
    3. The folder of files resulting from unzipping either of 1 or 2
    4. A single HDF5 file of NEON eddy flux data
* `level`: dp01-4

Input the filepath you downloaded to using `zipsByProduct()` earlier, 
including the `filestoStack00200` folder created by the function, and 
`dp04`:


```R
flux <- stackEddy(filepath="/data/filesToStack00200/",
                 level="dp04")
```

    Extracting data
      |======================================================================| 100%
    Stacking data tables by month
      |======================================================================| 100%
    Joining data variables
      |======================================================================| 100%


We now have an object called `flux`. It's a named list containing four 
tables: one table for each site's data, and `variables` and `objDesc` 
tables.


```R
names(flux)
```


<ol class=list-inline>
	<li>'HARV'</li>
	<li>'NIWO'</li>
	<li>'variables'</li>
	<li>'objDesc'</li>
</ol>



Let's look at the contents of one of the site data files:


```R
head(flux$NIWO)
```


<table>
<caption>A data.frame: 6 × 26</caption>
<thead>
	<tr><th></th><th scope=col>timeBgn</th><th scope=col>timeEnd</th><th scope=col>data.fluxCo2.nsae.flux</th><th scope=col>data.fluxCo2.stor.flux</th><th scope=col>data.fluxCo2.turb.flux</th><th scope=col>data.fluxH2o.nsae.flux</th><th scope=col>data.fluxH2o.stor.flux</th><th scope=col>data.fluxH2o.turb.flux</th><th scope=col>data.fluxMome.turb.veloFric</th><th scope=col>data.fluxTemp.nsae.flux</th><th scope=col>⋯</th><th scope=col>data.foot.stat.veloFric</th><th scope=col>data.foot.stat.distZaxsMeasDisp</th><th scope=col>data.foot.stat.distZaxsRgh</th><th scope=col>data.foot.stat.distZaxsAbl</th><th scope=col>data.foot.stat.distXaxs90</th><th scope=col>data.foot.stat.distXaxsMax</th><th scope=col>data.foot.stat.distYaxs90</th><th scope=col>qfqm.fluxCo2.stor.qfFinl</th><th scope=col>qfqm.fluxH2o.stor.qfFinl</th><th scope=col>qfqm.fluxTemp.stor.qfFinl</th></tr>
	<tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>⋯</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
	<tr><th scope=row>1</th><td>2018-06-01T00:00:00.000Z</td><td>2018-06-01T00:29:59.000Z</td><td>0.1111935</td><td>-0.06191186</td><td>0.1731053</td><td>19.401824</td><td> 3.2511265</td><td>16.150697</td><td>0.19707045</td><td>  4.1712006</td><td>⋯</td><td>0.2</td><td>8.34</td><td>0.03221479</td><td>1000</td><td>333.60</td><td>133.44</td><td>25.02</td><td>1</td><td>1</td><td>0</td></tr>
	<tr><th scope=row>2</th><td>2018-06-01T00:30:00.000Z</td><td>2018-06-01T00:59:59.000Z</td><td>0.9328922</td><td> 0.08534117</td><td>0.8475510</td><td>10.444936</td><td>-1.1768333</td><td>11.621770</td><td>0.19699723</td><td> -0.9163691</td><td>⋯</td><td>0.2</td><td>8.34</td><td>0.33007082</td><td>1000</td><td>258.54</td><td>108.42</td><td>50.04</td><td>1</td><td>1</td><td>0</td></tr>
	<tr><th scope=row>3</th><td>2018-06-01T01:00:00.000Z</td><td>2018-06-01T01:29:59.000Z</td><td>0.4673682</td><td> 0.02177216</td><td>0.4455960</td><td> 5.140617</td><td>-4.3112673</td><td> 9.451884</td><td>0.06518208</td><td> -2.9814957</td><td>⋯</td><td>0.2</td><td>8.34</td><td>0.12876068</td><td>1000</td><td>308.58</td><td>125.10</td><td>58.38</td><td>1</td><td>1</td><td>0</td></tr>
	<tr><th scope=row>4</th><td>2018-06-01T01:30:00.000Z</td><td>2018-06-01T01:59:59.000Z</td><td>0.7263614</td><td> 0.24944366</td><td>0.4769178</td><td> 9.017467</td><td> 0.1980776</td><td> 8.819389</td><td>0.12964000</td><td>-13.3556222</td><td>⋯</td><td>0.2</td><td>8.34</td><td>0.83400000</td><td>1000</td><td>208.50</td><td> 83.40</td><td>75.06</td><td>1</td><td>1</td><td>0</td></tr>
	<tr><th scope=row>5</th><td>2018-06-01T02:00:00.000Z</td><td>2018-06-01T02:29:59.000Z</td><td>0.4740572</td><td> 0.22524363</td><td>0.2488136</td><td> 3.180386</td><td> 0.1316297</td><td> 3.048756</td><td>0.17460706</td><td> -5.3406503</td><td>⋯</td><td>0.2</td><td>8.34</td><td>0.83400000</td><td>1000</td><td>208.50</td><td> 83.40</td><td>66.72</td><td>1</td><td>1</td><td>0</td></tr>
	<tr><th scope=row>6</th><td>2018-06-01T02:30:00.000Z</td><td>2018-06-01T02:59:59.000Z</td><td>0.8807022</td><td> 0.07078007</td><td>0.8099221</td><td> 4.398761</td><td>-0.2989443</td><td> 4.697706</td><td>0.10477970</td><td> -7.2739206</td><td>⋯</td><td>0.2</td><td>8.34</td><td>0.83400000</td><td>1000</td><td>208.50</td><td> 83.40</td><td>41.70</td><td>1</td><td>1</td><td>0</td></tr>
</tbody>
</table>



The `variables` and `objDesc` tables can help you interpret the column 
headers in the data table. The `objDesc` table contains definitions for 
many of the terms used in the eddy flux data product, but it isn't 
complete. To get the terms of interest, we'll break up the column headers 
into individual terms and look for them in the `objDesc` table:


```R
term <- unlist(strsplit(names(flux$NIWO), split=".", fixed=T))
flux$objDesc[which(flux$objDesc$Object %in% term),]
```


<table>
<caption>A data.frame: 6 × 2</caption>
<thead>
	<tr><th></th><th scope=col>Object</th><th scope=col>Description</th></tr>
	<tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
	<tr><th scope=row>138</th><td>angZaxsErth</td><td>Wind direction                                                                                                 </td></tr>
	<tr><th scope=row>171</th><td>data       </td><td>Represents data fields                                                                                         </td></tr>
	<tr><th scope=row>343</th><td>qfFinl     </td><td>The final quality flag indicating if the data are valid for the given aggregation period (1=fail, 0=pass)      </td></tr>
	<tr><th scope=row>420</th><td>qfqm       </td><td>Quality flag and quality metrics, represents quality flags and quality metrics that accompany the provided data</td></tr>
	<tr><th scope=row>604</th><td>timeBgn    </td><td>The beginning time of the aggregation period                                                                   </td></tr>
	<tr><th scope=row>605</th><td>timeEnd    </td><td>The end time of the aggregation period                                                                         </td></tr>
</tbody>
</table>



For the terms that aren't captured here, `fluxCo2`, `fluxH2o`, and `fluxTemp` 
are self-explanatory. The flux components are

* `turb`: Turbulent flux
* `stor`: Storage
* `nsae`: Net surface-atmosphere exchange

The `variables` table contains the units for each field:


```R
flux$variables
```


<table>
<caption>A data.frame: 24 × 5</caption>
<thead>
	<tr><th></th><th scope=col>category</th><th scope=col>system</th><th scope=col>variable</th><th scope=col>stat</th><th scope=col>units</th></tr>
	<tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
	<tr><th scope=row>1</th><td>data</td><td>fluxCo2 </td><td>nsae</td><td>                </td><td>umolCo2 m-2 s-1</td></tr>
	<tr><th scope=row>2</th><td>data</td><td>fluxCo2 </td><td>stor</td><td>                </td><td>umolCo2 m-2 s-1</td></tr>
	<tr><th scope=row>3</th><td>data</td><td>fluxCo2 </td><td>turb</td><td>                </td><td>umolCo2 m-2 s-1</td></tr>
	<tr><th scope=row>4</th><td>data</td><td>fluxH2o </td><td>nsae</td><td>                </td><td>W m-2          </td></tr>
	<tr><th scope=row>5</th><td>data</td><td>fluxH2o </td><td>stor</td><td>                </td><td>W m-2          </td></tr>
	<tr><th scope=row>6</th><td>data</td><td>fluxH2o </td><td>turb</td><td>                </td><td>W m-2          </td></tr>
	<tr><th scope=row>7</th><td>data</td><td>fluxMome</td><td>turb</td><td>                </td><td>m s-1          </td></tr>
	<tr><th scope=row>8</th><td>data</td><td>fluxTemp</td><td>nsae</td><td>                </td><td>W m-2          </td></tr>
	<tr><th scope=row>9</th><td>data</td><td>fluxTemp</td><td>stor</td><td>                </td><td>W m-2          </td></tr>
	<tr><th scope=row>10</th><td>data</td><td>fluxTemp</td><td>turb</td><td>                </td><td>W m-2          </td></tr>
	<tr><th scope=row>11</th><td>data</td><td>foot    </td><td>stat</td><td>angZaxsErth     </td><td>deg            </td></tr>
	<tr><th scope=row>12</th><td>data</td><td>foot    </td><td>stat</td><td>distReso        </td><td>m              </td></tr>
	<tr><th scope=row>13</th><td>data</td><td>foot    </td><td>stat</td><td>veloYaxsHorSd   </td><td>m s-1          </td></tr>
	<tr><th scope=row>14</th><td>data</td><td>foot    </td><td>stat</td><td>veloZaxsHorSd   </td><td>m s-1          </td></tr>
	<tr><th scope=row>15</th><td>data</td><td>foot    </td><td>stat</td><td>veloFric        </td><td>m s-1          </td></tr>
	<tr><th scope=row>16</th><td>data</td><td>foot    </td><td>stat</td><td>distZaxsMeasDisp</td><td>m              </td></tr>
	<tr><th scope=row>17</th><td>data</td><td>foot    </td><td>stat</td><td>distZaxsRgh     </td><td>m              </td></tr>
	<tr><th scope=row>18</th><td>data</td><td>foot    </td><td>stat</td><td>distZaxsAbl     </td><td>m              </td></tr>
	<tr><th scope=row>19</th><td>data</td><td>foot    </td><td>stat</td><td>distXaxs90      </td><td>m              </td></tr>
	<tr><th scope=row>20</th><td>data</td><td>foot    </td><td>stat</td><td>distXaxsMax     </td><td>m              </td></tr>
	<tr><th scope=row>21</th><td>data</td><td>foot    </td><td>stat</td><td>distYaxs90      </td><td>m              </td></tr>
	<tr><th scope=row>22</th><td>qfqm</td><td>fluxCo2 </td><td>stor</td><td>                </td><td>NA             </td></tr>
	<tr><th scope=row>23</th><td>qfqm</td><td>fluxH2o </td><td>stor</td><td>                </td><td>NA             </td></tr>
	<tr><th scope=row>24</th><td>qfqm</td><td>fluxTemp</td><td>stor</td><td>                </td><td>NA             </td></tr>
</tbody>
</table>



Let's plot some data! First, we'll need to convert the time stamps 
to an R date-time format (right now they're just character fields).

### Time stamps

NEON sensor data come with time stamps for both the start and end of 
the averaging period. Depending on the analysis you're doing, you may 
want to use one or the other; for general plotting, re-formatting, and 
transformations, I prefer to use the start time, because there 
are some small inconsistencies between data products in a few of the 
end time stamps.

Note that **all** NEON data use UTC time, noted as 
`tz="GMT"` in the code below. This is true across NEON's instrumented, 
observational, and airborne measurements. When working with NEON data, 
it's best to keep everything in UTC as much as possible, otherwise it's 
very easy to end up with data in mismatched times, which can cause 
insidious and hard-to-detect problems. Be sure to include the `tz` 
argument in all the lines of code below - if there is no time zone 
specified, R will default to the local time zone it detects on your 
operating system.


```R
timeB <- as.POSIXct(flux$NIWO$timeBgn, 
                    format="%Y-%m-%dT%H:%M:%S", 
                    tz="GMT")
flux$NIWO <- cbind(timeB, flux$NIWO)
```


```R
plot(flux$NIWO$data.fluxCo2.nsae.flux~timeB, 
     pch=".", xlab="Date", ylab="CO2 flux",
     xaxt="n")
axis.POSIXct(1, x=timeB, format="%Y-%m-%d")
```


![ ]({{ site.baseurl }}/images/eddy_intro_files/eddy_intro_20_0.png)


Like a lot of flux data, these data have some stray spikes, but there 
is a clear diurnal pattern going into the growing season.

Let's trim down to just two days of data to see a few other details.


```R
plot(flux$NIWO$data.fluxCo2.nsae.flux~timeB, 
     pch=20, xlab="Date", ylab="CO2 flux",
     xlim=c(as.POSIXct("2018-07-07", tz="GMT"),
            as.POSIXct("2018-07-09", tz="GMT")),
    ylim=c(-20,20), xaxt="n")
axis.POSIXct(1, x=timeB, format="%Y-%m-%d %H:%M:%S")
```


![ ]({{ site.baseurl }}/images/eddy_intro_files/eddy_intro_22_0.png)


Note the timing of C uptake; the UTC time zone is clear here, where 
uptake occurs at times that appear to be during the night.

## 4. Merge flux data with other sensor data

Many of the data sets we would use to interpret and model flux data are 
measured as part of the NEON project, but are not present in the eddy flux 
data product bundle. In this section, we'll download PAR data and merge 
them with the flux data; the steps taken here can be applied to any of the 
NEON instrumented (IS) data products.

### Download PAR data

To get NEON PAR data, use the `loadByProduct()` function from the 
`neonUtilities` package. `loadByProduct()` takes the same inputs as 
`zipsByProduct()`, but it loads the downloaded data directly into the 
current R environment.

Let's download PAR data matching the Niwot Ridge flux data. The inputs 
needed are:

* `dpID`: DP1.00024.001
* `site`: NIWO
* `startdate`: 2018-06
* `enddate`: 2018-07
* `package`: basic
* `avg`: 30

The new input here is `avg=30`, which downloads only the 30-minute data. 
Since the flux data are at a 30-minute resolution, we can save on 
download time by disregarding the 1-minute data files (which are of course 
30 times larger). The `avg` input can be left off if you want to download 
all available averaging intervals.


```R
pr <- loadByProduct("DP1.00024.001", site="NIWO", avg=30,
                    startdate="2018-06", enddate="2018-07",
                    package="basic", check.size=F)
```

    Downloading files totaling approximately 1.281789 MB
    Downloading 11 files
      |======================================================================| 100%
    
    Stacking operation across a single core.
    Stacking table PARPAR_30min
    Merged the most recent publication of sensor position files for each site and saved to /stackedFiles
    Copied the most recent publication of variable definition file to /stackedFiles
    Finished: Stacked 1 data tables and 2 metadata tables!
    Stacking took 0.2982938 secs


`pr` is another named list, and again, metadata and units can be found in 
the `variables` table. The `PARPAR_30min` table contains a `verticalPosition` 
field. This field indicates the position on the tower, with 10 being the 
first tower level, and 20, 30, etc going up the tower.

### Join PAR to flux data

We'll connect PAR data from the tower top to the flux data.


```R
pr.top <- pr$PARPAR_30min[which(pr$PARPAR_30min$verticalPosition==
                                max(pr$PARPAR_30min$verticalPosition)),]
```

`loadByProduct()` automatically converts time stamps when it reads the 
data, so here we just need to indicate which time field to use to 
merge the flux and PAR data.


```R
timeB <- pr.top$startDateTime
pr.top <- cbind(timeB, pr.top)
```

And merge the two datasets:


```R
fx.pr <- merge(pr.top, flux$NIWO, by="timeB")
```


```R
plot(fx.pr$data.fluxCo2.nsae.flux~fx.pr$PARMean,
     pch=".", ylim=c(-20,20),
     xlab="PAR", ylab="CO2 flux")
```


![ ]({{ site.baseurl }}/images/eddy_intro_files/eddy_intro_33_0.png)


If you're interested in data in the eddy covariance bundle besides the 
net flux data, the rest of this tutorial will guide you through how to 
get those data out of the bundle.

## 5. Vertical profile data (Level 3)

The Level 3 (`dp03`) data are the spatially interpolated profiles of 
the rates of change of CO<sub>2</sub>, H<sub>2</sub>O, and temperature.
Extract the Level 3 data from the HDF5 file using `stackEddy()` with 
the same syntax as for the Level 4 data.


```R
prof <- stackEddy(filepath="/data/filesToStack00200/",
                 level="dp03")
```

    Extracting data
      |======================================================================| 100%
    Stacking data tables by month
      |======================================================================| 100%
    Joining data variables
      |======================================================================| 100%



```R
head(prof$NIWO)
```


<table>
<caption>A data.frame: 6 × 506</caption>
<thead>
	<tr><th></th><th scope=col>timeBgn</th><th scope=col>timeEnd</th><th scope=col>data.co2Stor.rateRtioMoleDryCo2.0.1 m</th><th scope=col>data.co2Stor.rateRtioMoleDryCo2.0.2 m</th><th scope=col>data.co2Stor.rateRtioMoleDryCo2.0.3 m</th><th scope=col>data.co2Stor.rateRtioMoleDryCo2.0.4 m</th><th scope=col>data.co2Stor.rateRtioMoleDryCo2.0.5 m</th><th scope=col>data.co2Stor.rateRtioMoleDryCo2.0.6 m</th><th scope=col>data.co2Stor.rateRtioMoleDryCo2.0.7 m</th><th scope=col>data.co2Stor.rateRtioMoleDryCo2.0.8 m</th><th scope=col>⋯</th><th scope=col>qfqm.tempStor.rateTemp.7.5 m</th><th scope=col>qfqm.tempStor.rateTemp.7.6 m</th><th scope=col>qfqm.tempStor.rateTemp.7.7 m</th><th scope=col>qfqm.tempStor.rateTemp.7.8 m</th><th scope=col>qfqm.tempStor.rateTemp.7.9 m</th><th scope=col>qfqm.tempStor.rateTemp.8 m</th><th scope=col>qfqm.tempStor.rateTemp.8.1 m</th><th scope=col>qfqm.tempStor.rateTemp.8.2 m</th><th scope=col>qfqm.tempStor.rateTemp.8.3 m</th><th scope=col>qfqm.tempStor.rateTemp.8.4 m</th></tr>
	<tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>⋯</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
	<tr><th scope=row>1</th><td>2018-06-01T00:00:00.000Z</td><td>2018-06-01T00:29:59.000Z</td><td>-0.0002681938</td><td>-0.0002681938</td><td>-0.0002681938</td><td>-0.0002681938</td><td>-0.0002681938</td><td>-0.0002681938</td><td>-0.0002681938</td><td>-0.0002681938</td><td>⋯</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td></tr>
	<tr><th scope=row>2</th><td>2018-06-01T00:30:00.000Z</td><td>2018-06-01T00:59:59.000Z</td><td> 0.0004878799</td><td> 0.0004878799</td><td> 0.0004878799</td><td> 0.0004878799</td><td> 0.0004878799</td><td> 0.0004673503</td><td> 0.0004331343</td><td> 0.0003989183</td><td>⋯</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td></tr>
	<tr><th scope=row>3</th><td>2018-06-01T01:00:00.000Z</td><td>2018-06-01T01:29:59.000Z</td><td> 0.0005085725</td><td> 0.0005085725</td><td> 0.0005085725</td><td> 0.0005085725</td><td> 0.0005085725</td><td> 0.0005025472</td><td> 0.0004925052</td><td> 0.0004824631</td><td>⋯</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td></tr>
	<tr><th scope=row>4</th><td>2018-06-01T01:30:00.000Z</td><td>2018-06-01T01:59:59.000Z</td><td> 0.0013276966</td><td> 0.0013276966</td><td> 0.0013276966</td><td> 0.0013276966</td><td> 0.0013276966</td><td> 0.0013735225</td><td> 0.0014498989</td><td> 0.0015262753</td><td>⋯</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td></tr>
	<tr><th scope=row>5</th><td>2018-06-01T02:00:00.000Z</td><td>2018-06-01T02:29:59.000Z</td><td> 0.0007344040</td><td> 0.0007344040</td><td> 0.0007344040</td><td> 0.0007344040</td><td> 0.0007344040</td><td> 0.0008510161</td><td> 0.0010453695</td><td> 0.0012397230</td><td>⋯</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td></tr>
	<tr><th scope=row>6</th><td>2018-06-01T02:30:00.000Z</td><td>2018-06-01T02:59:59.000Z</td><td>-0.0009449785</td><td>-0.0009449785</td><td>-0.0009449785</td><td>-0.0009449785</td><td>-0.0009449785</td><td>-0.0007653319</td><td>-0.0004659209</td><td>-0.0001665099</td><td>⋯</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td></tr>
</tbody>
</table>



## 6. Un-interpolated vertical profile data (Level 2)

The Level 2 data are interpolated in time but not in space. They 
contain the rates of change at the measurement heights.

Again, they can be extracted from the HDF5 files using `stackEddy()` 
with the same syntax:


```R
prof.l2 <- stackEddy(filepath="/data/filesToStack00200/",
                 level="dp02")
```

    Extracting data
      |======================================================================| 100%
    Stacking data tables by month
      |======================================================================| 100%
    Joining data variables
      |======================================================================| 100%



```R
head(prof.l2$HARV)
```


<table>
<caption>A data.frame: 6 × 9</caption>
<thead>
	<tr><th></th><th scope=col>verticalPosition</th><th scope=col>timeBgn</th><th scope=col>timeEnd</th><th scope=col>data.co2Stor.rateRtioMoleDryCo2.mean</th><th scope=col>data.h2oStor.rateRtioMoleDryH2o.mean</th><th scope=col>data.tempStor.rateTemp.mean</th><th scope=col>qfqm.co2Stor.rateRtioMoleDryCo2.qfFinl</th><th scope=col>qfqm.h2oStor.rateRtioMoleDryH2o.qfFinl</th><th scope=col>qfqm.tempStor.rateTemp.qfFinl</th></tr>
	<tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
	<tr><th scope=row>1</th><td>010</td><td>2018-06-01T00:00:00.000Z</td><td>2018-06-01T00:29:59.000Z</td><td>         NaN</td><td>NaN</td><td> 2.583333e-05</td><td>1</td><td>1</td><td>0</td></tr>
	<tr><th scope=row>2</th><td>010</td><td>2018-06-01T00:30:00.000Z</td><td>2018-06-01T00:59:59.000Z</td><td> 0.002194788</td><td>NaN</td><td>-2.008056e-04</td><td>1</td><td>1</td><td>0</td></tr>
	<tr><th scope=row>3</th><td>010</td><td>2018-06-01T01:00:00.000Z</td><td>2018-06-01T01:29:59.000Z</td><td>-0.010752434</td><td>NaN</td><td>-1.901111e-04</td><td>1</td><td>1</td><td>0</td></tr>
	<tr><th scope=row>4</th><td>010</td><td>2018-06-01T01:30:00.000Z</td><td>2018-06-01T01:59:59.000Z</td><td> 0.002556148</td><td>NaN</td><td>-7.419444e-05</td><td>1</td><td>1</td><td>0</td></tr>
	<tr><th scope=row>5</th><td>010</td><td>2018-06-01T02:00:00.000Z</td><td>2018-06-01T02:29:59.000Z</td><td>-0.015977747</td><td>NaN</td><td>-1.537083e-04</td><td>1</td><td>1</td><td>0</td></tr>
	<tr><th scope=row>6</th><td>010</td><td>2018-06-01T02:30:00.000Z</td><td>2018-06-01T02:59:59.000Z</td><td>-0.000537461</td><td>NaN</td><td>-1.874861e-04</td><td>1</td><td>1</td><td>0</td></tr>
</tbody>
</table>



Note that here, as in the PAR data, there is a `verticalPosition` field. 
It has the same meaning as in the PAR data, indicating the tower level of 
the measurement.

## 7. Calibrated raw data (Level 1)

Level 1 (`dp01`) data are calibrated, and aggregated in time, but 
otherwise untransformed. Use Level 1 data for raw gas 
concentrations and atmospheric stable isotopes.

Using `stackEddy()` to extract Level 1 data requires additional 
inputs. The Level 1 files are too large to simply pull out all the 
variables by default, and they include mutiple averaging intervals, 
which can't be merged. So two additional inputs are needed:

* `avg`: The averaging interval to extract
* `var`: One or more variables to extract

What variables are available, at what averaging intervals? Another 
function in the `neonUtilities` package, `getVarsEddy()`, returns 
a list of HDF5 file contents. It requires only one input, a filepath 
to a single NEON HDF5 file:


```R
vars <- getVarsEddy("/data/filesToStack00200/NEON.D01.HARV.DP4.00200.001.nsae.2018-07.basic.h5")
head(vars)
```


<table>
<caption>A data.frame: 6 × 12</caption>
<thead>
	<tr><th></th><th scope=col>site</th><th scope=col>level</th><th scope=col>category</th><th scope=col>system</th><th scope=col>hor</th><th scope=col>ver</th><th scope=col>tmi</th><th scope=col>name</th><th scope=col>otype</th><th scope=col>dclass</th><th scope=col>dim</th><th scope=col>oth</th></tr>
	<tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
	<tr><th scope=row>5</th><td>HARV</td><td>dp01</td><td>data</td><td>amrs</td><td>000</td><td>060</td><td>01m</td><td>angNedXaxs</td><td>H5I_DATASET</td><td>COMPOUND</td><td>44640</td><td>NA</td></tr>
	<tr><th scope=row>6</th><td>HARV</td><td>dp01</td><td>data</td><td>amrs</td><td>000</td><td>060</td><td>01m</td><td>angNedYaxs</td><td>H5I_DATASET</td><td>COMPOUND</td><td>44640</td><td>NA</td></tr>
	<tr><th scope=row>7</th><td>HARV</td><td>dp01</td><td>data</td><td>amrs</td><td>000</td><td>060</td><td>01m</td><td>angNedZaxs</td><td>H5I_DATASET</td><td>COMPOUND</td><td>44640</td><td>NA</td></tr>
	<tr><th scope=row>9</th><td>HARV</td><td>dp01</td><td>data</td><td>amrs</td><td>000</td><td>060</td><td>30m</td><td>angNedXaxs</td><td>H5I_DATASET</td><td>COMPOUND</td><td>1488 </td><td>NA</td></tr>
	<tr><th scope=row>10</th><td>HARV</td><td>dp01</td><td>data</td><td>amrs</td><td>000</td><td>060</td><td>30m</td><td>angNedYaxs</td><td>H5I_DATASET</td><td>COMPOUND</td><td>1488 </td><td>NA</td></tr>
	<tr><th scope=row>11</th><td>HARV</td><td>dp01</td><td>data</td><td>amrs</td><td>000</td><td>060</td><td>30m</td><td>angNedZaxs</td><td>H5I_DATASET</td><td>COMPOUND</td><td>1488 </td><td>NA</td></tr>
</tbody>
</table>



Inputs to `var` can be any values from the `name` field in the table 
returned by `getVarsEddy()`. Let's take a look at CO<sub>2</sub> and 
H<sub>2</sub>O, <sup>13</sup>C in CO<sub>2</sub> and <sup>18</sup>O in 
H<sub>2</sub>O, at 30-minute aggregation. Let's look at Harvard Forest 
for these data, since deeper canopies generally have more interesting 
profiles:


```R
iso <- stackEddy(filepath="/data/filesToStack00200/",
               level="dp01", var=c("rtioMoleDryCo2","rtioMoleDryH2o",
                                   "dlta13CCo2","dlta18OH2o"), avg=30)
```

    Extracting data
      |======================================================================| 100%
    Stacking data tables by month
      |======================================================================| 100%
    Joining data variables
      |======================================================================| 100%



```R
head(iso$HARV)
```


<table>
<caption>A data.frame: 6 × 84</caption>
<thead>
	<tr><th></th><th scope=col>verticalPosition</th><th scope=col>timeBgn</th><th scope=col>timeEnd</th><th scope=col>data.co2Stor.rtioMoleDryCo2.mean</th><th scope=col>data.co2Stor.rtioMoleDryCo2.min</th><th scope=col>data.co2Stor.rtioMoleDryCo2.max</th><th scope=col>data.co2Stor.rtioMoleDryCo2.vari</th><th scope=col>data.co2Stor.rtioMoleDryCo2.numSamp</th><th scope=col>data.co2Turb.rtioMoleDryCo2.mean</th><th scope=col>data.co2Turb.rtioMoleDryCo2.min</th><th scope=col>⋯</th><th scope=col>ucrt.isoCo2.rtioMoleDryCo2.se</th><th scope=col>ucrt.isoCo2.rtioMoleDryH2o.mean</th><th scope=col>ucrt.isoCo2.rtioMoleDryH2o.vari</th><th scope=col>ucrt.isoCo2.rtioMoleDryH2o.se</th><th scope=col>ucrt.isoH2o.dlta18OH2o.mean</th><th scope=col>ucrt.isoH2o.dlta18OH2o.vari</th><th scope=col>ucrt.isoH2o.dlta18OH2o.se</th><th scope=col>ucrt.isoH2o.rtioMoleDryH2o.mean</th><th scope=col>ucrt.isoH2o.rtioMoleDryH2o.vari</th><th scope=col>ucrt.isoH2o.rtioMoleDryH2o.se</th></tr>
	<tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>⋯</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
	<tr><th scope=row>1</th><td>010</td><td>2018-06-01T00:00:00.000Z</td><td>2018-06-01T00:29:59.000Z</td><td>509.3375</td><td>451.4786</td><td>579.3518</td><td>845.0795</td><td>235</td><td>NA</td><td>NA</td><td>⋯</td><td>      NA</td><td>       NaN</td><td>       NaN</td><td>         NA</td><td>       NaN</td><td>        NaN</td><td>         NA</td><td>       NaN</td><td>        NaN</td><td>         NA</td></tr>
	<tr><th scope=row>2</th><td>010</td><td>2018-06-01T00:30:00.000Z</td><td>2018-06-01T00:59:59.000Z</td><td>502.2736</td><td>463.5470</td><td>533.6622</td><td>161.3652</td><td>175</td><td>NA</td><td>NA</td><td>⋯</td><td>1.764965</td><td>0.08848440</td><td>0.01226428</td><td>0.014335993</td><td>0.02544454</td><td>0.003017400</td><td>0.008116413</td><td>0.06937514</td><td>0.009640249</td><td>0.006855142</td></tr>
	<tr><th scope=row>3</th><td>010</td><td>2018-06-01T01:00:00.000Z</td><td>2018-06-01T01:29:59.000Z</td><td>521.6139</td><td>442.8649</td><td>563.0518</td><td>547.9924</td><td>235</td><td>NA</td><td>NA</td><td>⋯</td><td>      NA</td><td>       NaN</td><td>       NaN</td><td>         NA</td><td>       NaN</td><td>        NaN</td><td>         NA</td><td>       NaN</td><td>        NaN</td><td>         NA</td></tr>
	<tr><th scope=row>4</th><td>010</td><td>2018-06-01T01:30:00.000Z</td><td>2018-06-01T01:59:59.000Z</td><td>469.6317</td><td>432.6588</td><td>508.7463</td><td>396.8379</td><td>175</td><td>NA</td><td>NA</td><td>⋯</td><td>1.149078</td><td>0.08917388</td><td>0.01542679</td><td>0.017683602</td><td>0.01373503</td><td>0.002704220</td><td>0.008582764</td><td>0.08489408</td><td>0.008572288</td><td>0.005710986</td></tr>
	<tr><th scope=row>5</th><td>010</td><td>2018-06-01T02:00:00.000Z</td><td>2018-06-01T02:29:59.000Z</td><td>484.7725</td><td>436.2842</td><td>537.4641</td><td>662.9449</td><td>235</td><td>NA</td><td>NA</td><td>⋯</td><td>      NA</td><td>       NaN</td><td>       NaN</td><td>         NA</td><td>       NaN</td><td>        NaN</td><td>         NA</td><td>       NaN</td><td>        NaN</td><td>         NA</td></tr>
	<tr><th scope=row>6</th><td>010</td><td>2018-06-01T02:30:00.000Z</td><td>2018-06-01T02:59:59.000Z</td><td>476.8554</td><td>443.7055</td><td>515.6598</td><td>246.6969</td><td>175</td><td>NA</td><td>NA</td><td>⋯</td><td>0.670111</td><td>        NA</td><td>        NA</td><td>0.005890447</td><td>0.01932110</td><td>0.002095066</td><td>0.008049170</td><td>0.02813808</td><td>0.002551672</td><td>0.002654748</td></tr>
</tbody>
</table>



Let's plot vertical profiles of CO<sub>2</sub> and <sup>13</sup>C in CO<sub>2</sub> 
on a single day. 

Here, for convenience, instead of converting the time stamps 
to a time format, it's easy to use the character format to extract the ones 
we want using `grep()`. And discard the `verticalPosition` values that are 
string values - those are the calibration gases.


```R
iso.d <- iso$HARV[grep("2018-06-25", iso$HARV$timeBgn, fixed=T),]
iso.d <- iso.d[-which(is.na(as.numeric(iso.d$verticalPosition))),]
```

    Warning message in which(is.na(as.numeric(iso.d$verticalPosition))):
    “NAs introduced by coercion”


`ggplot` is well suited to these types of data, let's use it to plot 
the profiles.


```R
library(ggplot2)
```


```R
g <- ggplot(iso.d, aes(y=verticalPosition)) + 
  geom_path(aes(x=data.co2Stor.rtioMoleDryCo2.mean, 
                group=timeBgn, col=timeBgn)) + 
  theme(legend.position="none") + 
  xlab("CO2") + ylab("Tower level")
g
```

    Warning message:
    “Removed 2 rows containing missing values (geom_path).”



![ ]({{ site.baseurl }}/images/eddy_intro_files/eddy_intro_50_1.png)



```R
g <- ggplot(iso.d, aes(y=verticalPosition)) + 
  geom_path(aes(x=data.isoCo2.dlta13CCo2.mean, 
                group=timeBgn, col=timeBgn)) + 
  theme(legend.position="none") + 
  xlab("d13C") + ylab("Tower level")
g
```

    Warning message:
    “Removed 55 rows containing missing values (geom_path).”



![ ]({{ site.baseurl }}/images/eddy_intro_files/eddy_intro_51_1.png)


The legends are omitted for space, see if you can work out the times 
of day the different colors represent.


```R

```
