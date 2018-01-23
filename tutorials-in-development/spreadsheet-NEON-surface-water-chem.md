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

NEON data are complex, consisting of over 180 different data products with many 
data products made up of several seperate data tables. We recommend that you work
with NEON data in a scripted environment (like R, Python, etc) using a reproducible 
science framework. However, if you need to work in a spreadsheet with NEON
data this tutorial will show you how to: 

* convert from ISO 8601 date format to a Excel recognized date format,
* work with NA values,
* combine tables using the VLOOKUP function, and
* create line and scatter plots. 

<div id="ds-objectives" markdown="1">

## Things You’ll Need To Complete This Tutorial
You will need a version of a spreadsheet application (Microsoft Excel, Google 
Sheets, etc).


### Download Data

<a href="http://www.neonscience.org/neon-water-chemistry-data-subset-prin-2016-2017" class="link--button link--arrow">
Download NEON Surface Water Chemistry Data Subset</a>

These data represents a subsample of NEON data from one site over several months 
that have been downloaded from the NEON data portal and then the 
<a href="http://www.neonscience.org/neonDataStackR" target="_blank"> neonDataStackR</a> R script was used to stack all 
the month-site data tables into combined data tables within the StackedFiles 
directory.

</div>

## Surface Water Chemistry Data

Collected ~26 times per year at stream/river & 12 per lake

Four data tables 

* swc_fieldSuperParent 
  + One record per parentSampleID
  + Linking to other data products: siteID, staionID and  collectDate –OR- parentSampleID
* swc_fieldData
  + One record per parentSampleID (per collectDate) = sampleID
* swc_domainLabData 
  + Acid Neutralizing Capacity (ANC) and alkalinity
  + Two records per sampleID (one domainSampleID each)
* swc_externalLabData
  + Most of the chemistry measurements
  + One record per sampleID

**Research question:** domain vs external ANC
ANC: Acid neutralizing capacity titration result from Domain/external lab in milligrams of Calcium Carbonate per liter
 
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


