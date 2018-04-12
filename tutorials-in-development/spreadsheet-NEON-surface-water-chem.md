---
syncID: d52ac2460ddc4dd7b80caab59e963422
title: "Working With NEON Data in Spreadsheets: Surface Water Chemistry Data"
description: "While s."
dateCreated: 2018-01-18
authors: Megan A. Jones
contributors: 
estimatedTime: 30 mins.
packagesLibraries: 
topics: data-viz, data-management
languagesTool: spreadsheet
dataProduct: NEON.DP1.20093
code1: 
tutorialSeries: 
urlTitle: spreadsheets-swc
---

NEON data are complex, consisting of over 180 different data products, with many 
data products made up of several seperate data tables. We recommend that you work
with NEON data in a scripted environment (like R, Python, etc) using a reproducible 
science framework. However, if you need to work in a spreadsheet with NEON
data this tutorial will show you how to: 

* convert from ISO 8601 date format to a Excel recognized date format,
* work with NA values,
* combine tables using the VLOOKUP function, 
* create line and scatter plots
* basic pivot table use, and
* plots from pivot tables. 

This tutorial includes directions but not screenshots of where different icons are
as the arrangement of the buttons in Excel (or Google Sheets or another 
spreadsheet program) vary by version. The directions below are written for Excel 
but all can work with Google Sheets. 

<div id="ds-objectives" markdown="1">

## Things You’ll Need To Complete This Tutorial
You will need a version of a spreadsheet application (Microsoft Excel, Google 
Sheets, etc).


### Download Data

<a href="http://www.neonscience.org/neon-water-chemistry-data-subset-prin-2016-2017" class="link--button link--arrow">
Download NEON Surface Water Chemistry Data Subset</a>

These data represents a subsample of NEON data from one site over several months 
that have been downloaded from the NEON data portal in January 2018 and then the 
<a href="http://www.neonscience.org/neonUtilities" target="_blank"> neonUtilities</a> R script was used to stack all 
the month-site data tables into combined data tables within the StackedFiles 
directory.

</div>

## Research Question
To guide our investigation of using NEON data with spreadsheets we will be investigating
how similar the measurements for acid neutralizing capacity (ANC) is between the domain
and external lab samples. ANC is a measurement that can change as the water sample
sits and is exposed to ambient air. If we see a large difference in the measurements
this would inform whether then ANC needs to be measured at the NEON Domain headquarters 
immediately after sampling or if ANC can be measured by the external lab which 
measures all the other water chemistry data. 


## Surface Water Chemistry Data

NEON collects surface water chemistry data (NEON Data Product NEON.DP1.20093) 
at all aquatic field sites. For more on this data product, view the 
<a href="http://data.neonscience.org/data-product-view?dpCode=DP1.20093.001" target="_blank"> Data Product catalog<a>. 

Water samples are collected 26 times per year at each wadable stream or 
non-wadable stream (river) site and 12 per year at lakes. In streams, 12 samples 
are collected at regular intervals during the sampling season, while the 
remaining 14 are collected on an irregular basis to capture major flow events.
The data are provided in four discrete data tables.

* swc_fieldSuperParent 
  + Contains information about the site, geographic coordinates, and related data.
  + One record per parentSampleID
  + Linking to other data products: siteID, staionID and  collectDate –OR- parentSampleID
* swc_fieldData
  + Contains the surface water chemistry summary data per site per bout
  + One record per parentSampleID (per collectDate) = sampleID
* swc_domainLabData 
  + Contains those chemistry lab results conducted at domain facilities (acid neutralizing capacity (ANC) and alkalinity).
  + Two records per parentSampleID (one domainSampleID each)
* swc_externalLabData
  + Contains most of the chemistry measurements
  + One record per sampleID

Our research question is to compare the domain measured ANC (**ancMeqPerL** in 
swc_domainLabData) and the external lab measured ANC (**externalANC** in 
swc_externalLabData). Therefore, we need to be able join these two tables. 

<div id="ds-challenge" markdown="1">
### Challenge: Variables to Link Tables
  
Explore the respective .csv files. What variables can be used to link the swc_externalLabData
with the swc_domainLabData tables? 

</div>

The external lab data has individual records per **sampleID** while the domain 
lab data has individual records per **domainSampleID** of which there are two
per **parentSampleID**. However, the swc_fieldData table contains both **sampleID**
 and **parentSampleID**. Therefore, we can use it to join the two table of interest. 

## .csv files

Let's get started with the data. Remember, we're starting with "stacked" data 
(see Download Data above). 

Let's start by opening the stacked external lab data (swc_externalLabData.csv). 
This csv (comma seperate value) file when opened with Excel contains a single 
worksheet with the value in it. 

A good rule is to never do any data manipulations to raw data - **keep raw data raw**. 
Therefore, we will save this .csv as an Excel workbook (.xslx). Let's name that 
file **NEON_ANC_Comparison.xlsx**. 

```
Save swc_externalLabData.csv as NEON_ANC_Comparison.xlsx, a Excel workbook

```

Now that that our data are in a workbook we can open a new sheet and name it 
"C.ExternalField" as we'll use this to join the External lab and Field data tables. 
Start by pasting all of the External lab data into this worksheet. 

We need all of our data of interest in the same workbook for this to work most 
easily. Therefore, create two new sheets and paste data from swc_fieldData into one
and swc_domainLabData into the other. Now we can work to join the tables.   

## Date values in Excel 

Let's go back to our C.ExternalField worksheet, which for now only contains the 
External Lab data. 

## NA values in Excel

When we join the data tables we will want to consider areas where there are no
data or where the NEON data has NA values. As a quick excersize to demonstrate
how Excel deals with NA values let's create a line plot of the **waterCalcium**
variable. In our dataset this has "NA" values for sampling bouts in March and 
April of 2017. 

### Create Line Plot

To create a line plot, highlight 


Open External Data table
Create .xls workbook. PaloozaDataTraining
Keep raw data raw
Copy to a new sheet
Basic Line Plot – collectDate ~ externalANC
•	Create Plots
o	Highlight both columns
o	Insert Plot: Line
o	Copy Paste to new sheet – Plots
o	Huh – something up with dates – same spacing if 2 days vs 2 weeks apart
•	Dates
o	To keep as a DateTime ISO 8601   =TEXT(F2,"yyyy-mm-ddThh:MM:ss")
o	Copy, add column, then text to Columns – rename collectDate_new
Dealing with NAs
•	Create Plot: Date ~waterCalcium
•	Zeros? What is up with that?
o	NA values: replace with   #N/A or   =NA()

Combine the tables – How does the Domain ANC compare to the External ANC? 

Step 1 external lab + Field data = get sampleID and parentSampleID together. 
o	Consolidate – no text! Numbers only 
o	VLOOKUP
o	=IFERROR(VLOOKUP($A2,Sheet2!$A$1:$C$6,COLUMN(A1),FALSE),"")
o	IFERROR -> gives custom error if the formula doesn’t work.  We’ll use #N/A
o	VLOOKUP = vertical look up 
	organize data so that the value you look up (part number) is to the left of the return value you want to find (price of the part).
	Lookup value: $A2 – what do you want to look up? 
	Range containing the look up value –Other table to be combined with $Sheet2!$A$1:$C$6
	Column to look in – default is the # but yuck counting; instead use COLUMN(A1) where A1 is a cell in the chosen column and this returns the column #. 
	T/F for approximate/exact match
Step2 DomainLab Data (2 lines per parentSampleID)~ combo
•	KEY: must copy paste all as values (save the formula elsewhere). Then copy parentSampleID into A column OF BOTH TABLES as the thing you are looking for must be to the left of the thing you are looking in. 
=IFERROR(VLOOKUP($A2,swc_domainLabData!$A$1:$N$43,COLUMN(K1),FALSE),"#N/A")
•	Then repeat above but with DomainLabData

Basic Scatter Plot – externalANC (X) ~ domainANC (Y)
o	Outlier – why? 
Two variable plot – Date Collected ~ externalANC (X) ~ domainANC (Y)
o	What about looking at it by time?  Plot both with time as line plot.
o	Copy plot to be able to compare the new one;
o	Now double click on one of the series, “secondary axis”. 
o	Now you have the two different axes.


