---
syncID: NDS-style-guide
title: "NEON Data Skills Style Guide"
description: "This is an example page with the css styled."
dateCreated:   2015-08-01
authors: Megan A. Jones
contributors: Leslie Goldman, Donal O'Leary
estimatedTime: 
packagesLibraries: raster, rhdf5, rgdal
topics: data-analysis, data-visualization, HDF5, spatial-data-gis
languagesTool: R, python
dataProduct: 
code1: 
tutorialSeries: 
urlTitle: styles-css
---

This page shows all the Markdown and html stylings used for NEON Data Skills 
tutorials on the NEONScience.org website. This is a non-published page used only for 
reference and testing. If you have user permissions on the NEONScience.org website
you can view it at neonscience.org/styles-css. Otherwise, use the text below to
guide the styling used in NEON Data Skills educational resources. 

This should be used in conjunction with a tutorial template document 
(tutorial-template-markdown.md or tutorial-template-Rmarkdown.Rmd). 

For a simple markdown overview, check out 
<a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank">this cheatsheet</a>.

## Accessibility 
Ensuring that our code and training resources are accessible to users is very 
important. Please make sure to always include descriptive alt text for images. 
This 'alt text' can even be added to figures that are produced within the code chunks 
by using the 'fig.cap' code chunk option. Please see the 'code chunk options' 
section below for details.

For more on making RMarkdown documents (and the content applies fairly generally
to other content types, please read 
<a href = "https://r-resources.massey.ac.nz/rmarkdown/" target="_blank"> Accessible R Markdown Documents by A. Jonathan R. Godfrey</a> 
and/or 
<a href ="https://www.researchgate.net/publication/333508336_LaTeX_is_NOT_Easy_Creating_Accessible_Scientific_Documents_with_R_Markdown" target="_blank"> LaTeX is NOT Easy: Creating Accessible Scientific Documents with R Markdown</a>. 

## Code syntax 
Please reference the well laid out and easy to navigate 
<a href="https://style.tidyverse.org/syntax.html" target="_blank"> Syntax section </a> 
from Hadley Wickham's *The Tidyverse Style Guide*.  We follow these code syntax
guidelines for NEON Data Skills tutorials (even those not using TidyVerse packages). 

## Use cases for specific markdown
The rest of this document lays out specific use cases for standard markdown in 
NEON Data Skills tutorials or provides the codes for specific CSS treatment on the
website.  

***
## Headings
Write all headers in sentence case.  

# Heading one  
We don't use header one on the site. The title will be in header one but you 
don't code it. 

## Heading two
This level of header will show up in page navigation. It 
should only be used for large section breaks and use descriptive header names. 

### Heading three

#### Heading four

Headings three and four should be used as subheadings within larger topics. 

***

## Basic markdown highlighting

The use of the highlight ( `text` ) will be reserve for denoting code when used
in text. To add emphasis to other text, please use **bold** or *italics*. 

### Code in text conventions

To write code in a text section so that appears in code font, place a grave (`) 
before and after the desired code section. On a standard US keyboard, the grave 
is on the same key as the tidle (~). 

Functions are in a code font (`code font`) and followed by parentheses, like 
`sum()`, or `mean()`.

Other R objects (e.g. objects or function arguments) are in a code font, without 
parentheses, like `flights` or `x`.

If you want to make it clear what package an object comes from, you should use the 
package name followed by two colons, like `dplyr::mutate()`, or
`nycflights13::flights`. 

Items that are related to code but are not themselves code (e.g., general mention 
of a programming language or a package) should not be denoted as code. 

### Math notation 

If you want to include math notation in your tutorial it can be denoted with $. 

    $E=mc^2$
$E=mc^2$

***

## Info box

This is the "Info Box" styling which contains the information on set up, data 
downloads, etc for the tutorial or workshop. 

The necessary div tag (spaces at beginning only added so as not to render): 

    <div id="ds-objectives" markdown="1">  

<div id="ds-objectives" markdown="1">

## Learning Objectives 
After completing this tutorial you will be able to: 

* Create a new NEON Data Skills teaching module. 

## Things You’ll Need To Complete This Tutorial

### R Programming Language
You will need a current version of R to complete this tutorial. We also recommend 
the RStudio IDE to work with R. 

### R Packages to Install
Prior to starting the tutorial ensure that the following packages are installed. 
* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`
* **sp:** `install.packages("sp")`

<a href="/packages-in-r" target="_blank"> More on Packages in R </a>– Adapted from Software Carpentry.

### Example Data Set

This tutorial will teach you how to download data directly from the NEON data 
portal.  This example data set is provided as an optional download and a backup. 

#### NEON Teaching Data Subset: Plant Phenology & Single Aspirated Air Temperature

The data used in this tutorial were collected at the 
<a href="http://www.neonscience.org" target="_blank"> National Ecological Observatory Network's</a> 
<a href="/field-sites/field-sites-map" target="_blank"> Domain 02 field sites</a>.  

* National Ecological Observatory Network. 2020. Data Product DP1.10055.001, Plant phenology observations. Provisional data downloaded from http://data.neonscience.org on February 5, 2020. Battelle, Boulder, CO, USA NEON. 2020.
* National Ecological Observatory Network. 2020. Data Product DP1.00002.001, Single aspirated air temperature. Provisional data downloaded from http://data.neonscience.org on February 5, 2020. Battelle, Boulder, CO, USA NEON. 2020.

<a href="https://ndownloader.figshare.com/files/9012085" class="link--button link--arrow">
Download Dataset (.zip of .csv files)</a>

### Working Directory
Setting and understanding the working directory is a common challenge
for most beginner R programmers. To make matters worse, the working
directory becomes much more complicated when 'knitting' an .Rmd file to
a .md file, when running individual .Rmd file code chunks, and when 
doing any of the above programmatically as a batch using the 
'processing_code' files. In order to ensure expected behavior for all
known use cases, as of early 2020 we are migrating to a new method to
define and call the working directory for tutorials that read in or write
out data. 

We accomplish this by explicetly defining the working directory at the
beginning of the tutorial, and then using paste0(wd, ...) to give the full
file path each and every time that we read or write data. Note that the 
working directory definition includes a `/` character at the end of the
string so that you can easily append this `wd` with a filename or directory
extension to make a complete filepath.

For example, here are the first few lines of the recently updated 'work with hyperspectral data' tutorial (bold added for emphasis): 

`# set working directory to ensure R can find the file we wish to import`
`# and where we want to save our files. Be sure to move the download into `
`# your working directory! `

    `wd <- "~/Documents/data/" #This will depend on your local environment` 
    `setwd(wd)`

`# Define the file name to be opened `

    `f <- paste0(wd,"NEON_hyperspectral_tutorial_example_subset.h5")` 

And again later in the tutorial when writing out a result: 

`# write out the raster as a geotiff `

    `writeRaster(b9r, 
            file=paste0(wd,"band9.tif"), 
            format="GTiff", 
            overwrite=TRUE)` 
            
We still link to the working directory tutorial in this section. Donal will
be updating that tutorial ASAP

## Additional Resources
You can list any additional resources you'd like to link to if needed. 

* <a href="URL Here" target="_blank"> Resource Name</a>,
 
</div>


***

## Code Chunks 

In most tutorials, code is embedded within code chunks.

### R Markdown code chunk options

* `eval = FALSE, comment = NA`: Used when you do not want to evaluate the chunk 
but you do want to keep the code non-commented out in the .R script. (You'll 
almost always want to include `comment=NA`when using `eval=FALSE`)
* `eval =TRUE, purl = FALSE`: Used when you do not want to include a code chunk 
in the .R but you do want it to show in the .md. Relatively few use cases. 
* `include = FALSE, purl = FALSE`: Used when you do not want to show a chunk in 
the .md or the .R files. Typically used for set up of the .RMD or to create a 
graphic to supplement text in a .RMD that isn't part of the actual code of the 
lesson. 
* `echo=FALSE, results="hide"`: Used when you want to evaluate the code but you
don't want the code or results to show in the .md (website) but you do want the 
code to appear in .R. Frequently used  for the "answers" in Challenges code sections. 
* `fig.cap=c("Fig cap 1", "Fig cap 2", ...)`: Used to provide figure captions (alt 
text) for figures produced within the code chunk. By providing a vector of captions, 
you can define figure captions/alt text for multiple figures produced within that
code chunk.

***

## Images 
All images used in NEON Data Skills educational resources must be free of 
copyright issues (CC0, CC-BY, etc). We write out the source and license of all images (linked
when possible). When not restricted by license, we prefer to download and image and host it within
the /images/ directory it GitHub. This prevents broken images when links to external 
websites change. 

Images should be large enough to be useful on the website and in presentations
based on these educational resources. However, they should not be so large as to 
prevent usage of the educational resources in areas with slower internet connections. 
Image file sizes should not exceed 2 MB. Supported image types at this time are 
.jpg, .png, and .gif.  

### Alt text
All images must include alt text that clearly describes what the image is. This 
is not the same as the image caption.  The alt text should clearly and concisely 
describe the important parts of the image, figure, or chart. Consider the user 
who cannot see the image and what information they need to know about it to know 
why you've included this image in the tutorial. 

### Images

    <figure>
    	<a href="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/biomass.png">
    	<img src="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/biomass.png" alt="descriptive text of figure/image"> </a>
    	<figcaption> Caption here. Source: National Ecological Observatory Network
    	(NEON)  
    	</figcaption>
    </figure>

<figure>
	<a href="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/biomass.png">
	<img src="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/biomass.png" alt="descriptive text of figure/image"></a>
	<figcaption> Caption here. Source: National Ecological Observatory Network, CC-BY
	(NEON)  
	</figcaption>
</figure>


### Two images side-by-side 

    <figure class="half">
    	<a href="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/biomass.png">
    	<img src="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/biomass.png" alt="descriptive text of figure/image">
    	</a>
    	<a href="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/OverTimepng">
    	<img src="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/OverTime.png"alt="descriptive text of figure/image"></a>
    	<figcaption>Caption describing these two images LEFT: Blah blah. RIGHT: Blah blah. Source: 
    	</figcaption>
    </figure>

<figure class="half">
	<a href="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/biomass.png" >
	<img src="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/biomass.png" alt="descriptive text of figure/image">
	</a>
	<a href="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/OverTime.png">
	<img src="https://github.com/NEONScience/NEON-Data-Skills/tree/master/images/lidar/OverTime.png" alt="descriptive text of figure/image"></a>
	<figcaption>Caption describing these two images LEFT: Blah blah. RIGHT: Blah blah. Source: National Ecological Observatory Network, CC-BY
	</figcaption>
</figure>

***
## Links

Because we want the ability to have links open on other pages, we only use
html code for links and not markdown code. For visual appeal and accessibility, 
link on text not the full URL. 

Yes: For more details, see 
<a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank"> Adam Pritchar's Markdown cheatsheet</a>

No: For more details, see Adam Pritchar's Markdown cheatsheet at
<a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank"> https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet</a>. 

Exception: If you are really wanting to highlight a specific website URL (short) you may 
link on the URL itself. For example, "If you have additional questions about NEON, visit <a href="https://www.neonscience.org/" target="_blank">neonscience.org</a>."

### Links to webpages

Code (spaces at beginning only added so as not to render): 

    <a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank"> Adam Pritchar's Markdown cheatsheet</a>

Rendered version: 
<a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank"> Adam Pritchar's Markdown cheatsheet</a>


### Direct download links
If the link is going to cause a file to download or open other than another 
webpage, list the document type in the text. 

Code: 
    <a href="https://data.neonscience.org/api/v0/documents/NEON_smammal_userGuide_vA">Download Small Mammal Data Product User Guide(.PDF)</a>
Rendered: 
<a href="https://data.neonscience.org/api/v0/documents/NEON_smammal_userGuide_vA">Download Small Mammal Data Product User Guide(.PDF)</a>



### Internal links, using relative path - DEPRECATED

*2/2020 - We have decided to no longer use relative paths so that RMarkdowns & 
Jupyter Notebooks will render on any computer*. 

Code (spaces at beginning only added so as not to render):

    <a href="/primer-raster-data-R" target="_blank"> *Primer on Raster Data* series</a>

Rendered version: 
<a href="/primer-raster-data-R" target="_blank"> *Primer on Raster Data* series</a>

***


## Data tip boxes

Data tip boxes are used to call out highlights that are useful, but beyond the 
scope of the tutorial content. Without the star and with a different descriptor, they can 
also be used in other cases. 

There should always be a space between the star and Data Tip.  

The div tag for this one is (spaces at beginning only added so as not to render): 

    <div id="ds-dataTip" markdown="1">
    <i class="fa fa-star"></i> **Data Tip:**

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** Here is a block with a data tip. 
Sometimes it might have some `code` in it. A data tip can include a list or
links, however, it cannot contain figures, etc. 
</div> 


***

## Challenge boxes

Challenge boxes are to denote code where users apply the skills/knowledge they 
have just learned to a different data set or modified directions. 

Unless the answer to a Challenge is part of the tutorial, it can be hidden in a
code chunk has is not rendeded on the website but are available in the 
downloadable code. 

Titles of challenges should be H3 header and in sentence case. 

The div tag for this one is (spaces at beginning only added so as not to render):

    <div id="ds-challenge" markdown="1">


<div id="ds-challenge" markdown="1">
### Challenge: Title of challenge
  
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

If you are quoting from another source, you can use a quote block.  
    > Here is a quote block
    > you can use all sorts of different spacing and bullets in it too
    >
    > * list one
    > * list two
    > but you have to use a `>` on each line for it to work which is a pain.

> Here is a quote block
> you can use all sorts of different spacing and bullets in it too
>
> * list one
> * list two
> but you have to use a `>` on each line for it to work which is a pain.

***

## Embedded Videos
Use the embed code (found under Share > Embed) from YouTube to add a video to
tutorials. 

Code (spaces at beginning only added so as not to render):

    <iframe width="640" height="360" src="https://www.youtube.com/embed/3iaFzafWJQE" frameborder="0" allowfullscreen></iframe>

<iframe width="640" height="360" src="https://www.youtube.com/embed/3iaFzafWJQE" frameborder="0" allowfullscreen></iframe> 

***

## Highlight in Specified Color

`<span style="color:#A00606;font-weight:bold">http://data.neonscience.org/api/v0</span><span style="color:#A2A4A3">/data/DP1.10003.001/WOOD/2015-07</span>`

<span style="color:#A00606;font-weight:bold">http://data.neonscience.org/api/v0</span><span style="color:#A2A4A3">/data/DP1.10003.001/WOOD/2015-07</span>



## Example code for testing CSS
This section is included here to test out CSS for the code rendered from Markdown. 

## Code chunks

### R


In Markdown code chunks look like this (indent only).


	 # add 1 +1
	 1+1
	 2

Notice in the above code `# add 1+1` should be highlighted as a comment, `1+1` 
should be highlighted as input, and `2` should be highlighted as output. All 
should be visually separate from the surrounding text. 




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

## Include Files - Deprecated

**2/2020 - decided to not use these but to instead have template language. This 
info will remain here for now but will be removed once the transition away from 
these are complete.**

Include files are used for items/information that need to be to be repeated in 
many places (like the dataset above). By using an include an update can be made 
in one location and applied in all instances. 

In a .md file includes are added with the following code (space between { % and % } 
added so that this does not render).  

    { % include/wkSetup/_setup_data.html % }

where everything after "include" is the file path to the appropriate file. 

If you are creating content in Drupal (series overview, workshop, teaching module), 
these same includes can be used by using the appropriate node ID (space between square brackets
added so that this does not render). 

     [ [nid:6408] ]

It would appear like this: 

{% include/wkSetup/_setup_data.html %}
