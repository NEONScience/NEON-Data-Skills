---
layout: post
title: "An Example Post With Examples of the NDS Template Format"
description: "This is a sample post to document and explore available styles. 
Description should be fully in PLAIN TEXT -- no code text"
date: 2016-01-18
dateCreated: 2014-11-18
lastModified: 2016-01-13
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries: [R]
authors: [Author One, Author Two]
contributors: [Contributor One]
categories: [self-paced-tutorial]
tags: []
mainTag: 
code1: R-code-File-Name-Here.R
image:
  feature: TeachingModules.jpg
  credit:
  creditlink:
permalink: /example-post
comments: false
---

## Example YAML header
This does not appear on the rendered page, but is the first element of any .Rmd 
or .md file that will render.  
In .Rmd lastModified should be `lastModified: `r format(Sys.time(), "%Y-%m-%d")` `

	 ---
	layout: post
	title: "An Example Post With Examples of the NDS Template Format"
	description: "This is a sample post to document and explore available styles. 
	Description should be fully in PLAIN TEXT -- no code text"
	date: 2016-01-18
	dateCreated: 2014-11-18
	lastModified: 2016-01-13
	estimatedTime: 1.0 - 1.5 Hours
	packagesLibraries: [R,HDF5]
	authors: [Author One, Author Two]
	contributors: [Contributor One]
	categories: [coding-and-informatics]
	tags: [HDF5, R]
	mainTag: HDF5
	code1: R-code-File-Name-Here.R
	image:
	  feature: TeachingModules.jpg
	  credit:
	  creditlink:
	permalink: /example-post/
	comments: false
	---


{% include _toc.html %}

	Below the YAML header, the first code should be the include for a table of
	contents that appears in the right side bar "Overview": 
	
	 { % include _toc.html %} 
	
	*NOTE: there should NOT be a space between the initial { and %; only added 
	here so the code will not render.  

## About
1-2 sentences describing what the lesson is about.  
This is an example post to document and explore available styles.  Each section
first has the text/style as it renders and then the text/style is repeated as a
code chunk to demonstrate how it is coded. 

	## About
	1-2 sentences describing what the lesson is about.  
	This is an example post to document and explore available styles.  Each 
	section first has the text/style as it renders and then the text/style is 
	repeated as a code chunk to demonstrate how it is written/ coded in .Rmd or
	.md.

**R Skill Level:** Intermediate - you've got the basics of `R` down.
	 
	 **R Skill Level:** Intermediate - you've got the basics of `R` down.

<div id="objectives" markdown="1">

# Goals / Objectives
After completing this activity, you will:

* Objective 1.
* Objective 2.

## Things You’ll Need To Complete This Tutorial
To complete this tutorial you will need the most current version of R and, 
preferably, RStudio loaded on your computer.

### Install R Packages

* **library:** `install.packages("library")`
* **rgdal:** `install.packages("rgdal")`

* [More on Packages in R - Adapted from Software Carpentry.]({{site.baseurl}}R/Packages-In-R/)

### Download Data

{% include/dataSubsets/_data_Landsat-NDVI.html %}

	
****

{% include/_greyBox-wd-rscript.html %}

*** 

### Additional Resources

* one resources
* another 

</div>

**In the example text below, look for NOTEs the provide extra details but should
NOT be included in actual .Rmd or .md files.** 

	<div id="objectives" markdown="1">

	# Goals / Objectives
	After completing this activity, you will:
	* Objective 1
	* Objective 2 

	## Things You’ll Need To Complete This Tutorial
	To complete this tutorial you will need the most current version of R and, 
	preferably, RStudio loaded on your computer.

	### R Libraries to Install:

	* **library:** `install.packages("library")`
	* **rgdal:** `install.packages("rgdal")`

	[ { { site.baseurl }} R/Packages-In-R/](More on Packages in R - Adapted from Software Carpentry.)
	NOTE: there should NOT be a space between the initial brackets - { and {.
	It is only added here so the code will not render. 
	
	### Download Data

	{ % include/dataSubsets/_data_Landsat-NDVI.html %}

	NOTE: you can have more than 1 download button/include per section.  
	NOTE: there should NOT be a space between the initial { and %. 
	It is only added here so the code will not render.
	***

	{ % include/_greyBox-wd-rscript.html %}
	NOTE: there should NOT be a space between the initial { and %. 
	It is only added here so the code will not render.
	
	****
	### Additional Resources
	* one resource
	* another resource

	</div>

## Brief Text & Coding Style Guide 
All tutorials & files have a 80 character width limit.  Single space after a 
period is used throughout.  

The use of the highlight ( `text` ) will be reserve for denoting code when used
in text. To add emphasis to other text use **bold** or *italics*. 

	 The use of the highlight ( `text` ) will be reserve for denoting code when
	 used in text. To add emphasis to other text use **bold** or *italics*. 

Functions described in the text are written at `function()` (e.g.,"We will use
`read_OGR()` to read in these data.") and directories are written
 `home/directory/`. 

In code chunks there should be a space between the chunk initial and end code 
and the text. All comments in coding chunks should have a space between the # and the text 

	 ```{r code-chunk}
	 
	 # add 1 +1
	 1+1
	 2
	 
	 ```


***

## Rule

create rule (pale grey horizontal line) using atlas 3 stars ( * )

	 to create a rule
	 ***

***

## Headers
All headers with in lessons are headers 2-4. There MUST be a space between the #
and the text for these to render properly with Jekyll 3.0. Headers 1 & 2  show up
in the table of contents side bar (default, can be changed in the _config file).  

## Heading two
	## Heading two

### Heading three
	### Heading three 

#### Heading four
	#### Heading four 

***

## Data Tips/Data Notes

When there is "bonus" information it can be added as a Data Tip (coding related)
or Data Note (not coding related). Same look for both just the first words are
different. 

<i class="fa fa-star"></i> **Data Tip:** Here is a block with a data tip. 
Sometimes it might have some `code` in it. A data tip can include a list or
links, however, it cannot contain figures, etc. 
{: .notice}

	<i class="fa fa-star"></i> **Data Tip:** Here is a block with a data tip. 
	Sometimes it might have some `code` in it. A data tip can include a list or
	links, however, it cannot contain figures, etc.
	{: .notice}



***

## Quote Blocks

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

## Links & Additional Information
Any internal links (those to other locations within neondataskills.org) will 
open within the same tab.  External links should open in a new tab 
(target="_blank").

When adding additional information with links to the lessons they should be as a 
separate bullet point or bulleted list unless incorporated into the text.  

### Internal Link

* See the 
[About Categories, Tags and Other YAML organized tutorial]({{ site.baseurl }}NDS-documentation/categories-and-tags/)
to understand more about the YAML elements used in the NEON Data Skills portal. 

		 * See the 
		[About Categories, Tags and Other YAML organized tutorial]({{ site.baseurl }}NDS-documentation/categories-and-tags/)
		to understand more about the YAML elements used in the NEON Data Skills 
		portal. 

### External Link

* Visit the 
<a href="http://www.neoninc.org/science-design/field-sites/harvard-forest" target="_blank">Harvard Forest field site</a> 
for more information on the location.  

		 * Visit the 
		<a href="http://www.neoninc.org/science-design/field-sites/harvard-forest" target="_blank">Harvard Forest field site</a> 
		for more information on the location. 

***

## Image with Caption & Source

<figure>
	<a href="{{ site.baseurl }}/images/example-post-images/pnt_line_poly.png">
	<img src="{{ site.baseurl }}/images/example-post-images/pnt_line_poly.png"></a>
	<figcaption> Caption here. Source: National Ecological Observatory Network
	(NEON)  
	</figcaption>
</figure>

**NOTE: space between initial { { only added to prevent code from rendering in 
this example.**  

	 <figure>
		<a href="{ { site.baseurl }}/images/example-post-images/pnt_line_poly.png">
		<img src="{ { site.baseurl }}/images/example-post-images/pnt_line_poly.png"></a>
		<figcaption> Caption here. 
		Source: National Ecological Observatory Network (NEON)  
		</figcaption>
	</figure>

replace `{ { site.baseurl } }/images/example-post-images/pnt_line_poly.png` with 
the full URL if image is not in the images folder or a local image.


***

## Two Images Side-by-side with Caption & Source

<figure class="half">
	<a href="{{ site.baseurl }}/images/example-post-images/600x300.jpg">
	<img src="{{ site.baseurl }}/images/example-post-images/600x300.jpg">
	</a>
	<a href="{{ site.baseurl }}/images/example-post-images/600x300.jpg">
	<img src="{{ site.baseurl }}/images/example-post-images/600x300.jpg"></a>
	<figcaption>Caption describing these two images. Include Source: 
	</figcaption>
</figure>

 **NOTE: space between initial { { only added to prevent code from rendering in 
this example (below).**

	 <figure class="half">
		<a href="{ { site.baseurl }}/images/example-post-images/600x300.jpg">
		<img src="{ { site.baseurl }}/images/example-post-images/600x300.jpg">
		</a>
		<a href="{ { site.baseurl }}/images/example-post-images/600x300.jpg">
		<img src="{ { site.baseurl }}/images/example-post-images/600x300.jpg">
		</a>
		<figcaption>Caption describing these two images. Source: here
		</figcaption>
	</figure>    


replace `{ { site.baseurl }}/images/example-post-images/pnt_line_poly.png` with 
the full URL if image is not in the images folder or a local image.   
**NOTE: space between initial { { only added to prevent code from rendering in 
this example.**  

***

## Embedded Videos
Use the embed code (found under Share > Embed) from YouTube to add a video to
lessons.  

<iframe width="560" height="315" src="https://www.youtube.com/embed/3iaFzafWJQE" frameborder="0" allowfullscreen></iframe> 

	 <iframe width="560" height="315" src="https://www.youtube.com/embed/3iaFzafWJQE" frameborder="0" allowfullscreen></iframe>  

***

## Challenges

All challenges are Header 2. The div tag (<\div>) goes BEFORE the code chunk 
associated with the challenge. 

<div id="challenge" markdown="1">
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


	 <div id="challenge" markdown="1">
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

	 it can have multiple paragraphs, too.
	 </div>
  
  
### Challenge Code Chunks

We can include the answers to challenge questions in the .Rmd files but not have
them appear. If we set `echo=FALSE`, then the code will render in the `R` script
(that can be downloaded at the bottom of each page) but will not render on the 
page itself. 

	``` {r challenge-code-name-here, echo=FALSE}
	# we don't want challenge code to post but do want it to appear 
	# in the .R script.
	```

If we want to hide the answer output add `results=hide`. If we want to
keep the figures and allow them to show use `include=TRUE`.

	```  {r challenge-code-name, include=TRUE, results="hide", echo=FALSE}
	# If you want figures but no code or results to appear.
	```

