---
layout: post
title: "Activity: Installing & Updating Packages in R"
date:   2014-10-27 20:49:52
authors: Leah A. Wasser - Activity Modified From Data Carpentry and Software Carpentry Content 
categories: [Using R]
tags : []
description: "This activity provides the basics of installing and working with packaged in R"
permalink: /R/Packages-In-R/
image:
  feature: textur2_pointsProfile.jpg
  credit: National Ecological Observatory Network (NEON) Higher Education
  creditlink: http://www.neoninc.org
---
<section id="table-of-contents" class="toc">
  <header>
    <h3 >Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->

# What you'll need
1. R or R studio loaded on your computer
2. A functioning thinking cap.

# What you'll Learn Here
- The basics of what a package is in R
- How to install a package in R
- How to update a package in R
- How to see what packages are installed on your computer 

## About Packages in R

Packages are collections of R functions, data, and compiled code in a well-defined format. When you install a package it gives you access to a set of commands that are not available in the base R set of functions. The directory where packages are stored is called the library. R comes with a standard set of packages. Others are available for download and installation. Once installed, they have to be loaded into the session to be used.

###More on Packages

- <a href="http://www.statmethods.net/interface/packages.html" target="_blank">Definition adapted from the Quick-R website</a>
- <a href="http://www.r-bloggers.com/installing-r-packages/" target="_blank">Read more about installing packages in R by R-bloggers.</a>

##Installing Packages in R
The website that hosts many of the R packages is called <a href="http://cran.r-project.org/" target="_blank">"CRAN"</a>. `install.packages("package-name")` will download a package from one of the <a href="http://cran.r-project.org/" target="_blank">CRAN mirrors where the packages are saved</a> assuming that a binary (or set of installation files) is available for your operating system. If you have not set a preferred CRAN mirror in your options(), then a menu will pop up asking you to choose a location from which you'd like to install your packages.

To install packages, use the code: `install.packages('package-Name-Here)` So, for example, you can use the code below to install the sp and rgdal packages. NOTE: you can just type this into the command line of R to install each package. Once a package is installed, you don't have to install it again! 

    install.packages(‘raster’)
    install.packages(‘sp’)

##What Packages are installed On Your Machine? 
Good question - let's find out. Use `old.packages()` to list all your locally installed packages that are now out of date. `update.packages()` will update all packages in the known libraries interactively. This can take a while if you haven't done it recently. To update everything without any user intervention, use the `ask = FALSE` argument.

In <a href="http://www.rstudio.com/" target="_blank">RStudio</a>, you can also manage packages using Tools -> Install Packages.

##Updating Packages
Sometimes packages are updated by the users who created them. Updating packages can sometimes make changes to both the package and also to how your code runs. If you already have a lot of code in R, be cautious about updating packages. Otherwise let's just go ahead and update our packages so things are up to date.


    {r, eval=FALSE}
    update.packages(ask = FALSE)



##Activity

Following this activity, you should be able to do the following -- so have at it!

- Check to see if the dplyr package is installed on your computer
- Next, install the "dplyr" package in R. if it's already installed, consider a different package such as ggplot2.





