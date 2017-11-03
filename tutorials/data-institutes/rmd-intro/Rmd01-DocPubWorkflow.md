---
syncID: c234390cc4724005b20d9a6048c8a889
title: "Document & Publish Your Workflow: R Markdown & knitr"
description: "This tutorial introduces the importance of tools supporting documenting & publishing a workflow."
dateCreated: 2016-01-01
authors:
contributors:
estimatedTime:
packagesLibraries:
topics: data-management
languagesTool: R
dataProduct:
code1:
tutorialSeries: [RMarkdown]
urlTitle: rmd-knitr-intro
---

This tutorial we will work with the `knitr` and `rmarkdown` packages within
`RStudio` to learn how to effectively and efficiently document and publish our
workflows online.

<div id="ds-objectives" markdown="1">

## Learning Objectives
At the end of this activity, you will be able to:

* Explain why documenting and publishing one's code is important.
* Describe two tools that enable ease of publishing code & output: R Markdown and 
the `knitr` package. 

</div>

## Documentation Is Important

As we read in
<a href="{{ site.baseurl }}/rep-sci-intro" target="_blank"> the Reproducible Science overview</a>,
the four facets of reproducible science are:

* Documentation
* Organization,
* Automation and
* Dissemination.

This week we will learn about the R Markdown file format (and R package) which
can be used with the `knitr` package to document and publish (disseminate) your
code and code output.

<a class="link--button link--arrow" href="http://neon-workwithdata.github.io/slide-shows/share-publish-archive-slideshow.html" target= "_blank"> View Slideshow: Share, Publish & Archive - from the Reproducible Science Curriculum</a>

## The Tools We Will Use

### R Markdown  

> “R Markdown is an authoring format that enables easy creation of dynamic
documents, presentations, and reports from R. It combines the core syntax of
markdown (an easy to write plain text format) with embedded R code chunks that
are run so their output can be included in the final document. R Markdown
documents are fully reproducible (they can be automatically regenerated whenever
underlying R code or data changes)."
-- <a href="http://rmarkdown.rstudio.com/" target="_blank">RStudio documentation</a>.

We use markdown syntax in R Markdown (.rmd) files to document workflows and
to share data processing, analysis and visualization outputs. We can also use it
to create documents that combine R code, output and text.

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** Most of the
<a href="https://github.com/NEONScience/NEON-Data-Skills/" target="_blank">NEON Data Skills educational resources</a> on this site are built using R Markdown files.
</div>



### Why R Markdown?
There are many advantages to using R Markdown in your work:

* Human readable syntax.
* Simple syntax - it can be learned quickly.
* All components of your work are clearly documented. You don't have to remember
what steps, assumptions, tests were used.
* You can easily extend or refine analyses by modifying existing or adding new
code blocks.
* Analysis results can be disseminated in various formats including HTML, PDF,
slide shows and more.
* Code and data can be shared with a colleague to replicate the workflow.

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:**
<a href="https://rpubs.com/" target= "_blank ">RPubs</a>
is a quick way to share and publish code.
</div>

## Knitr

The `knitr` package for R allows us to create readable documents from R Markdown
files.

<figure class="half">
	<a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute3-rmd/rmd-file.png">
	<img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute3-rmd/rmd-file.png">
	</a>
	<a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute3-rmd/knitr-output.png">
	<img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute3-rmd/knitr-output.png">
	</a>
	<figcaption>R Markdown script (left) and the HTML produced from the knit R 
	Markdown script (right). Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>  
>The knitr package was designed to be a transparent engine for dynamic report
generation with R --
<a href="http://yihui.name/knitr/" target="_blank"> Yihui Xi -- knitr package creator</a>


In the next tutorial we will learn more about working with the R Markdown format in RStudio.

