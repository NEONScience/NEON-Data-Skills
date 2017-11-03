---
syncID: NDS-style-guide
title: "NEON Data Skills Styles"
description: "This is an example page with the css styled."
dateCreated:   2015-08-01
authors: Megan A. Jones
contributors: Leslie Goldman
estimatedTime: 
packagesLibraries: [raster, rhdf5, rgdal]
topics: data-analysis, data-visualization, HDF5, spatial-data-gis
languagesTool: R, python
dataProduct: 
code1: 
tutorialSeries: 
urlTitle: styles-css
---

This page shows all the Markdown and html stylings used for NEON Data Skills on
the NEONScience.org website. This is a non-published page used only for 
reference and testing. If you have user permissions on the NEONScience.org website
you can view it at neonscience.org/styles-css. Otherwise, use the text below to
guide the styling used in NEON Data Skills educational resources. 

For a simple markdown cheatsheet check out 
<a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank">this cheatsheet</a>.

***
## Header at top of all tutorial pages

This header must be at the top of each tutorial so that all associated metadata 
will appear correctly.  

    ---
    syncID: sync-id-from-list
    title: "Descriptive Title In Title Case"
    description: "Descriptive text about the tutorial here. Must be all on one line no matter how long."
    dateCreated: 2015-08-01
    authors: Megan A. Jones, Separated by Commas, 
    contributors: Leslie Goldman, Also Seperate, By Commas
    estimatedTime: 1.5 hrs
    packagesLibraries: raster, rhdf5, rgdal
	- see list in processing_code/_data/packagesLibraries.yml for the correct list 
    topics: data-analysis, data-visualization, HDF5, spatial-data-gis 
	- see list in processing_code/_data/tags.yml for the correct list 
    languagesTool: R, python
	- see list in processing_code/_data/languagesTool.yml for the correct list 
    dataProduct: DP1.0001.01
	- all data products used in the tutorial
    code1: code/R/neon-utitlites/
	- the relative file path (code/...) of any code related to the tutorials so that it can be downloaded at the end of the tutorial
    tutorialSeries: 
	- if the tutorial is part of a series, this metadata isn't used by the Drupal site but is useful for tutorial management
    urlTitle: styles-css 
	- a short url that is descriptive but not long
    ---


***

## Rule

This is a rule (horizontal line) in markdown.

***

## Basic Markdown Highlighting

The use of the highlight ( `text` ) will be reserve for denoting code when used
in text. To add emphasis to other text use **bold** or *italics*. 

Write all headers in sentence case.  

# Heading one  
We don't use header one on the site. The title will be in header one but you 
don't code it. 

## Heading two
This level of header will show up in the table of contents on the side bar. It 
should only be used for large section breaks and use descriptive headers. 

### Heading three

#### Heading four

***

## GreyBox

This is the "Greybox" styling which contains the information on set up, data 
downloads, etc for the tutorial/lesson/workshop. 

The necessary div tag (leaving out the < > so it isn't recognized as html): 

`div id="ds-objectives" markdown="1"`  

<div id="ds-objectives" markdown="1">

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages

* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`
* **sp:** `install.packages("sp")`

<a href="{{ site.baseurl }}/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Download Data

{% include/dataSubsets/_data_Field-Site-Spatial-Data.html %}

## Tutorial Series 
These capstone activities rely on skills learned in the 

* <a href="/primer-raster-data-R" target="_blank"> *Primer on Raster Data* series</a>,
* <a href="/intro-hsi-r-series" target="_blank"> *Introduction to Hyperspectral Remote Sensing Data - in R* series</a>, or
* <a href="/intro-hdf5-r-series" target="_blank"> *Introduction to the Hierarchical Data Format (HDF5) - Using HDFView & R* series</a>.
 
</div>

***

## Links

Because we want the ability to have links open on other pages, we only use
html code for links and not markdown code. 

#### External Link 

Code (leaving out the < > so it isn't recognized as html): 

a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank"> Adam Pritchar's Markdown cheatsheet</a

<a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank"> Adam Pritchar's Markdown cheatsheet</a>

#### Internal Link, using relative path (leaving out http://www.neonscience.org). 

Code (leaving out the < > so it isn't recognized as html):

a href="/primer-raster-data-R" target="_blank"> *Primer on Raster Data* series</a

<a href="/primer-raster-data-R" target="_blank"> *Primer on Raster Data* series</a>

***


## Code chunks

### R


In Markdown code chunks look like this (indent only).


	 # add 1 +1
	 1+1
	 2

Notice in the above code `# add 1+1` should be highlighted as a comment, `1+1` 
should be highlighted as input, and `2` should be highlighted as output. All 
should be visually seperate from the surrounding text. 




### Python 

However, we also have code in other languages too. Python currently looks 
like this in the Markdown. 

```python
#ls_dataset displays the name, shape, and type of datasets in hdf5 file
def ls_dataset(name,node):
    if isinstance(node, h5py.Dataset):
        print(node)
    
f.visititems(ls_dataset)
```


***

## Data Tips

Data tip boxes are used ot call out highlights that are useful, but beyond the 
scope of the lesson. Without the star and with a different descriptor, they can 
also be used in other cases. 

There should always be a space between the star and Data Tip.  

The div tag for this one is (leaving out the < > so it isn't recognized as html): 

`div id="ds-dataTip" markdown="1"`
i class="fa fa-star"></i **Data Tip:** 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** Here is a block with a data tip. 
Sometimes it might have some `code` in it. A data tip can include a list or
links, however, it cannot contain figures, etc. 
</div> 


***

## Challenges

The div tag for this one is (leaving out the < > so it isn't recognized as html):
`div id="ds-challenge" markdown="1"`

This is how it appears in Markdown. 

<div id="ds-challenge" markdown="1">
### Challenge: Title of Challenge
  
Here is some challenge text.

* it can have bullets
* another bullet

or 

1. a numbered list
2. or two 

some more text here

**bolding stuff**

*italicize stuff*

It can have multiple paragraphs too.
</div>


***

## Quote Blocks

> Here is a quote block
> you can use all sorts of different spacing and bullets in it too
>
> * list one
> * list two
> but you have to use a `>` on each line for it to work which is a pain.


***

## Image with Caption & Source

<figure>
	### Challenge: <a href="{{ site.baseurl }}/images/lidar/biomass.png">
	<img src="{{ site.baseurl }}/images/lidar/biomass.png"></a>
	<figcaption> Caption here. Source: National Ecological Observatory Network
	(NEON)  
	</figcaption>
</figure>


## Two Images Side-by-side with Caption & Source


<figure class="half">
	<a href="{{ site.baseurl }}/images/lidar/biomass.png">
	<img src="{{ site.baseurl }}/images/lidar/biomass.png">
	</a>
	<a href="{{ site.baseurl }}/images/lidar/biomass.png">
	<img src="{{ site.baseurl }}/images/lidar/biomass.png"></a>
	<figcaption>Caption describing these two images. Include Source: 
	</figcaption>
</figure>

***

## Embedded Videos
Use the embed code (found under Share > Embed) from YouTube to add a video to
lessons.  

(leaving out the < > so it isn't recognized as html)
iframe width="640" height="360" src="https://www.youtube.com/embed/3iaFzafWJQE" frameborder="0" allowfullscreen></iframe

<iframe width="640" height="360" src="https://www.youtube.com/embed/3iaFzafWJQE" frameborder="0" allowfullscreen></iframe> 

***

## Highlight in Specified Color

<span style="color:#A00606;font-weight:bold">http://data.neonscience.org/api/v0</span><span style="color:#565A5C">/data/DP1.10003.001/WOOD/2015-07</span>