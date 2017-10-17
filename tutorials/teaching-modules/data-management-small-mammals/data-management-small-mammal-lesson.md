---
syncID: 67c077abe20b481c86265cb154cdac79
title: "Data Management using National Ecological Observatory Network’s (NEON) Small Mammal Data with Accompanying Lesson on Mark Recapture Analysis"
description: "In this lesson and accompanying teaching module, students use small mammal trapping data from the National Ecological Observatory Network to understand necessary steps of data management from field collected data to data analysis. Students explore this in the context of estimating small mammal population size using the Lincoln-Peterson model."
dateCreated: 2015-05-18
authors: Jim McNeil, Megan A. Jones
contributors: 
estimatedTime: 
packagesLibraries: ggplot2, plotly
topics: data-analysis, organisms, 
languagesTool: spreadsheet
dataProduct: DP1.10072.001
code1: 
tutorialSeries: tm-data-management-sm-mammals
urlTitle: tm-data-management-small-mammal

---

This teaching module is an online adaptation of a lesson that is currently in 
review for publication in 
<a href="http://tiee.esa.org/" target="_blank"> Teaching Issues and Experiments in Ecology</a>.

Lesson objectives, instructor notes, and downloadable versions of these materials 
can be found on the 
<a href="{{ site.baseurl }}/overview-data-management-small-mammal" target="_blank">Overview page for this teaching module</a>. 

***

## Background Materials

Review the following resources prior to class to prepare for the data management activity:

* NEON website: http://www.neonscience.org/
* Abbreviated NEON Small Mammal Trapping Protocols (available in Resources section)
* <a href="http://data.neonscience.org/api/v0/documents/FSUHandout_Vertebrates.pdf" target="_blank">Thibault, K. NEON breeding bird and small mammal abundance and diversity sampling. NEON.</a>
* Videos explaining small mammal trapping:
	 * National Park Service. <a href="https://youtu.be/KvGvS8pApFE" target="_blank"> From Field to Lab: Small Mammal Monitoring in Denali National Park </a>: 
This video highlights small mammal trapping/handling techniques at 1:32 - 2:30. 
	 * University of Oxford. <a href="https://youtu.be/bIjva3pa2YA" target="_blank">The Laboratory with Leaves (Part 10): Small Mammals </a>: 
This video provides context for why small mammal monitoring is important to ecology in general.
* Sutter, R.D., Wainscott, S.B., Boetsch, J.R., Palmer, C.J. and Rugg, D.J. 
(2015). Practical guidance for integrating data management into long-term 
ecological monitoring projects. Wildlife Society Bulletin, 39: 451–463. 
* Borer, E.T., Seabloom, E.W., Jones, M.B., and Schildhauer, M. (2009). Some 
simple guidelines for data management. Bulletin of the Ecological Society of 
America, 90(2): 205–214.

## Data Management is Important!

Data are the backbone of scientific research and exploration, so learning how to 
collect and process data efficiently is a critical skill for scientific 
professionals. Most people are not born understanding how collect, record, 
enter, and analyze data, but with guidance and practice you can learn how to 
handle information and create world-class datasets. 

Scientific organizations, especially large ones, spend a lot of time and effort 
determining the best ways to process data. The National Ecological Observatory 
Network (NEON) is one such organization that has made efficient data collection 
and processing a priority. NEON was designed to collect long-term ecological 
data on a continental-scale to help researchers address questions related to 
climate change, land-use, and invasive species. Data are collected at field 
sites called domains using standardized protocols, which allow for comparisons 
across large geographic ranges. Data on dozens of different variables and 
species will be collected every year for 30 years, yielding a comprehensive 
look at ecological processes across the entire United States. Regardless of the 
variables being measured, the general flow for data in these projects progresses 
from data collection to data files and metadata files as shown in Figure 1. 


<figure>
	<a href="{{ site.baseurl }}/images/tm-data-managment-sm-mammal/data-flow.png">
	<img src="{{ site.baseurl }}/images/tm-data-managment-sm-mammal/data-flow.png"></a>
	<figcaption> Figure 1. A workflow from data collection (can be in the field, lab, or other 
venue) to data collection sheets (paper, app, or entry form) to data files and 
metadata files. Source: McNeil and Jones. In Prep.   
	</figcaption>
</figure>


Given the scale and scope of the project, they will create literally terabytes 
of data every year, so the information needs to be very well organized to be 
useful. In this activity, you’ll get practice translating field data into a 
usable format for long-term archiving and then explore how real NEON data can be 
used to detect ecological patterns, in this case the change in small mammal 
abundance over a year.

## Field Collection & Data Sheets

Small mammals were chosen by NEON to be bioindicators because they are present 
across the country in a wide variety of habitats. Their small size and short 
lifespan makes them sensitive to environmental changes, and they are responsible 
for spreading or maintaining a wide diversity of zoonotic diseases in an 
environment. They are also easy to safely collect as live specimens using arrays 
of traps like those described in the Abbreviated NEON Small Mammal Trapping 
Protocol. Live trapping has the advantage of being able to return the animal to 
their habitat without having to destructively sample. As you learned in the 
readings and the Youtube videos, in just a few minutes you can collect a lot of 
information from an individual animal. Because researchers want to reduce the 
stress on the animal while it is captured, it’s important to have an efficient 
framework for recording that data. 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Activity:** Take a few minutes now and review 
the NEON Small Mammal sampling datasheet and Abbreviated Sampling Protocol. See 
if you can identify what variable is being recorded in each of the column 
categories. Make sure you know what codes refer to what type of animal being 
collected.

Now look at the example data sheet. On the data sheet, circle the column headings 
for the following variables:

* Plot ID
* Date of capture
* Species
* Individual identification
* Sex
* Weight
* Whether individual is a recapture?

</div>

## Data Sheets & Data Files

Processing raw data sheets into a data table is only easy if the data table is 
well designed. 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Activity:**Thinking about the presentation and the principles described in 
Borer et al. 2010 and Sutter et al. 2015, work in pairs to create an Excel data 
file that displays the information from your example data sheet for the variables 
you identified above. Make sure that your data table adheres to the best practices 
for data file construction that we talked about.
</div>


<div id="ds-challenge" markdown="1">
**Discussion questions**:

1. Do you think the NEON data sheets are well designed to transfer the information 
to a data file?  What makes the process easier and what makes it challenging?
2. Imagine you were responsible for entering data from hundreds of data sheets. 
How would you make sure you were not making mistakes?  What types of checks 
could you do to make sure you were correctly transferring the data?

</div> 

## Public Data & NEON

Another hallmark of NEON is that the data are all publically available. NEON has 
created an <a href="http://data.neonscience.org" target="_blank"> online data portal (http://data.neonscience.org)</a> 
that allows access to all of the NEON data from any Domain across the country. 
This portal will serve as the long-term repository and clearinghouse for all of 
the NEON data in perpetuity. 

We will use a series of data files downloaded from this portal to estimate the 
abundance of several small mammal species in different seasons (spring, summer, 
and fall) at NEON’s Smithsonian Conservation Biological Station field site 
during 2014 and 2015.

## Metadata

As we talked about during the presentation, metadata are another important 
component of collecting good data. A good metadata file can help someone 
unfamiliar with a data file interpret the codes and variables presented – 
and will help you remember what you did when you come back to the data later. 
It also provides an opportunity to discuss any irregularities in the data set. 
Discussion Questions:
Examine the metadata file for the NEON data file. Briefly discuss with your 
partner how this file could have helped you interpret the data sheet and create 
your own data file or perform data analysis. Be prepared to share your 
observations with the class.


## Data Analysis
Once you have a well-designed data file, you can use that information to 
determine interesting patterns. One of the simplest ways that the NEON small 
mammal datasets can be used is to calculate abundance estimates for individual 
species within the plots. There are many ways to estimate abundance. One of the 
simplest is the Lincoln-Peterson method. This calculation uses data about the 
recapture of marked individuals of a species to estimate how many individuals 
of that species are present in a particular habitat. Because NEON small mammal 
protocols include marking individual animals with unique numerical identifiers, 
we can easily use NEON datasets to calculate small mammal abundance using 
Lincoln-Peterson according the following equation.

n1/N=n2/m2

N = total population size estimate
n1 = Number of individuals captured and marked in first sampling bout
n2 = Number of individuals captured in second sampling bout
m2 = Number of marked individuals in second sampling bout

It’s important to note that there are several assumptions that should be met for 
this calculation to generate an accurate estimate of population size:

* Individuals are randomly distributed between captures
* There is no change in the population (i.e. births, deaths, immigration, emigration) between sampling bouts
* Marking individuals does not impact their likelihood of being captured again in the future

<div id="ds-challenge" markdown="1"> **Discussion question:** Lincoln-Peterson estimation 
depends on several assumptions about the population. Knowing what you do based 
on the sampling methods outlined in the Abbreviated NEON Small Mammal Trapping 
Protocols document, do you think any of those assumptions have been violated in 
this data set?  Why and what could be done to address those issues?
</div>

Working in pairs, use the workbook – NEONSmallMammalDataAbundanceWorkbook.xlsx – 
as a guide to calculate the Lincoln-Peterson estimation of population abundance 
using the following protocol:

1. Open the data file (NEON.D02.SCBI.DP1.10072.001.mam_pertrapnight.072014to052015.csv) using Excel.
You and your partner will perform the analysis for sampling bouts either in the spring (April to May 2015), the summer (July to August 2014), or the fall (September to October 2014) for samples collected in your assigned plot. Record your time frame and plotID below:

Time frame:____________________

Plot ID:____________________

Sort the data by plot ID and then by collectDate. Now you can see when trapping 
occurred at each plot. 
You will perform the Lincoln-Peterson calculation for white-footed mice 
(*Peromyscus leucopus*, abbreviated as PELE). Therefore, filter your data for 
the specified taxonID and plotID. Now you see only the data of interest for you 
Lincoln-Peterson calculation.

Identify unique individuals collected throughout your time frame. Record the following:

Number of individuals captured during the first month of the time frame (n1): _________

Number of individuals captured during the second month of the time frame (n2):_______

Number of individuals from the first month recaptured during the second month (m2):___

Use these numbers to calculate the population abundance of PELE for your site and time frame:
Share your results with the class.

<div id="ds-challenge" markdown="1">**Discussion questions:**

Based on everyone’s data, how does the population abundance change for 
white-footed mice between plots?  What are some hypotheses for why this 
pattern may exist?

Based on everyone’s data, how does the population abundance change for 
white-footed mice over the year at this site?  What are some hypotheses for 
why this pattern may exist?

</div>

*** 

### Acknowledgements

Jim McNeil would like to thank Leah Card, Field Technician II - Mammalogist, 
Domain 2 Field Operations, for providing the original data to create this 
activity (this activity now uses data downloaded in September 2017). We also 
want to thank all members of the 2017 Spring Faculty Mentoring Network 
<a href="https://qubeshub.org/groups/dig" target="_blank"> Dig Into Data </a>
for providing feedback on the concept and scope of the activity for dissemination. 