---
syncID: 1newLessonTest
title: "New Tutorial to Test the GitHub Sync
description: "This is a test page to test sync timing."
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
urlTitle: test-new-tutorial
---

This page shows all the NEON stylings as currently shown on the
<a href="http://neonscience.github.io/NEON-Lesson-Building-Data-Skills/example-post" target="_blank"> NEONDataSkills.org website</a>.  

## Rule

This is a rule (horizontal line) in markdown.

***

## Basic Markdown Highlighting

This is basic markdown styling and should need special CSS. 

The use of the highlight ( `text` ) will be reserve for denoting code when used
in text. To add emphasis to other text use **bold** or *italics*. 

# Heading one

## Heading two

### Heading three

#### Heading four

***

Below are the various styles that are used throughout the NEON Data Skills pages. 
For those that have CSS styles that are not yet resolved I give several options. 

***

## GreyBox

This is the "Greybox" styling. The div tag is currently (leaving out the < > so 
it isn't recognized as html): 

`div id="ds-objectives" markdown="1"`  


<div id="ds-objectives" markdown="1">

## Things You’ll Need To Complete This Tutorial
You will need the most current version of `R` and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages

* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`
* **sp:** `install.packages("sp")`

[More on Packages in R - Adapted from Software Carpentry.]({{site.baseurl}}/packages-in-r)

### Download Data

{% include/dataSubsets/_data_Field-Site-Spatial-Data.html %}

## Tutorial Series 
These capstone activities rely on skills learned in the 

* <a href="{{ site.baseurl }}/tutorial-series/spatial-data-types-primer/" target="_blank"> *Primer on Raster Data* series</a>,
* <a href="{{ site.baseurl }}/tutorial-series/intro-hsi-r-series/" target="_blank"> *Introduction to Hyperspectral Remote Sensing Data - in R* series</a>, or
* <a href="{{ site.baseurl }}/tutorial-series/intro-hdf5-r-series/" target="_blank"> *Introduction to the Hierarchical Data Format (HDF5) - Using HDFView & R* series</a>.
 
</div>

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


I could make code chunks look like this if needed. This is designated with: 

div id="ds-code-r" markdown="1"

<div id="ds-code-r" markdown="1">

	 # add 1 +1
	 1+1
	 2

</div>  




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


It could also be written like this. This is designated with:

div id="ds-code-python" markdown="1"


<div id="ds-code-python" markdown="1">

```python
#ls_dataset displays the name, shape, and type of datasets in hdf5 file
def ls_dataset(name,node):
    if isinstance(node, h5py.Dataset):
        print(node)
    
f.visititems(ls_dataset)

```
</div>  


***

## Data Tips

It was changed to look like this. The div tag for this one is: 

`div id="ds-dataTip" markdown="1"`

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** Here is a block with a data tip. 
Sometimes it might have some `code` in it. A data tip can include a list or
links, however, it cannot contain figures, etc. 
</div> 


***

## Challenges

This is how it appears in Markdown. 

<div id="ds-challenge" markdown="1">
## Challenge: Title of Challenge
  
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
	<a href="{{ site.baseurl }}/images/lidar/biomass.png">
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

<iframe width="560" height="315" src="https://www.youtube.com/embed/3iaFzafWJQE" frameborder="0" allowfullscreen></iframe> 

***

