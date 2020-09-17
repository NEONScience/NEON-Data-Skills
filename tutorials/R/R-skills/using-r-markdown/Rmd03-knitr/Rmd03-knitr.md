---
syncID: 341f22ea46904019a993e1fbc7a70937
title: "Publish Code - From R Markdown to HTML with knitr"
description: "This tutorial introduces how to use the R knitr package to publish from R Markdown files to HTML (or other) file format."
dateCreated: 2016-01-01
authors:
contributors:
estimatedTime:
packagesLibraries: [knitr, rmarkdown]
topics: data-management
languagesTool: R
dataProducts:
code1: 
tutorialSeries: [RMarkdown]
urlTitle: rmd-use-knitr
---

In this tutorial, we will cover the R `knitr` package that is used to convert
R Markdown into a rendered document (HTML, PDF, etc).

<div id="ds-objectives" markdown="1">

## Learning Objectives

At the end of this activity, you will:

* Be able to produce (‘knit’) an HTML file from a R Markdown file.
* Know how to modify chuck options to change the output in your HTML file.

## Things You’ll Need To Complete This Tutorial

You will need the most current version of R and, preferably, RStudio loaded on
your computer to complete this tutorial.

### Install R Packages

* **knitr:** `install.packages("knitr")`
* **rmarkdown:** `install.packages("rmarkdown")`
</div>

## Share & Publish Results Directly from Your Code!

The `knitr` package allow us to:

* Publish & share preliminary results with collaborators.
* Create professional reports that document our workflow and results directly
from our code, reducing the risk of accidental copy and paste or transcription errors.
* Document our workflow to facilitate reproducibility.
* Efficiently change code outputs (figures, files) given changes in the data, methods, etc.

## Publish from Rmd files with knitr

To complete this tutorial you need:

1. The R `knitr` package to complete this tutorial. If you need help installing 
packages, visit
<a href="https://www.neonscience.org/packages-in-r" target="_blank"> the R packages tutorial</a>.  
2. An R Markdown document that contains a YAML header, code chunks and markdown
segments. If you don't have an **.Rmd** file, visit
<a href="https://www.neonscience.org/rmd-code-intro" target="_blank"> the R Markdown tutorial</a> to create one.

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**When To Knit**: Knitting is a useful exercise
throughout your scientific workflow. It allows you to see what your outputs
look like and also to test that your code runs without errors.
The time required to knit depends on the length and complexity of the script
and the size of your data.
</div>

### How to Knit

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/KnitButton-screenshot.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/KnitButton-screenshot.png"></a>
	<figcaption> Location of the knit button in RStudio in Version 0.99.486.
	Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>

To knit in RStudio, click the **knit** pull down button. You want to use the  
**knit HTML** for this lesson.

When you click the **Knit HTML** button, a  window will open in your console 
titled R Markdown. This
pane shows the knitting progress. The output (HTML in this case) file will
automatically be saved in the current working directory. If there is an error
in the code, an error message will appear with a line number in the R Console
to help you diagnose the problem.

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** You can run `knitr` from the command prompt
using: `render(“input.Rmd”, “all”)`.
</div>

<div id="ds-challenge" markdown="1">

## Activity: Knit Script

Knit the **.Rmd** file that you built in
<a href="https://www.neonscience.org/rmd-code-intro" target="_blank">the last tutorial</a>.
What does it look like?
</div>

### View the Output

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/Rmd-screenshot-html.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/Rmd-screenshot-html.png"></a>
	<figcaption> R Markdown (left) and the resultant HTML (right) after knitting.
	Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>

When knitting is complete, the new HTML file produced will automatically open.

Notice that information from the YAML header (title, author, date) is printed
at the top of the HTML document. Then the HTML shows the text, code, and
results of the code that you included in the RMD document.

<div id="ds-challenge" markdown="1">

## Data Institute Participants: Complete Week 2 Assignment

* Read 
<a href="https://www.neonscience.org/di-rmd-activity" target="_blank"> this week’s assignment </a>
closely.
* Be sure to carefully check your knitr output to make sure it is rendering the
way you think it should!
* When you are complete, submit your .Rmd and .html files to the 
NEON Institute participants GitHub repository 
(**NEONScience/DI-NEON-participants**). 
* The files will have automatically saved to your R working directory, you will 
need to transfer the files to the **/participants/pre-institute3-rmd/** 
directory and submitted via a **pull request**.

</div>

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** If you are a frequent user of LaTex,
you might find
<a href="http://cdn.screenr.com/video/8352c25b-7324-4134-970b-b7c427381adb.mp4" target="_blank">this video from the creator of knitr </a>
informational. It introduces R Markdown & knitr in conjunction with LaTex and
other formats.
</div>
