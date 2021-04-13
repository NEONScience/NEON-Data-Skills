---
syncID: 3ec42e1e75ed4057b9d49325acf51963
title: "Installing & Updating Packages in R"
description: "This tutorial provides the basics of installing and working with packages in R."
dateCreated: 2014-10-27
authors: Leah A. Wasser - Modified From Data Carpentry and Software Carpentry 
contributors: Garrett M. Williams
estimatedTime: 30 minutes
packagesLibraries:
topics: data-analysis
languagesTool: R
dataProduct:
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/basic-R-skills/R-Basics-Of-Packages/R-Basics-Of-Packages.R
tutorialSeries: R-basics
urlTitle: packages-in-r
---

This tutorial provides the basics of installing and working with packages in R.

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to: 

* Describe the basics of an R package
* Install a package in R
* Call (use) an installed R package
* Update a package in R
* View the packages installed on your computer 

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded
on your computer to complete this tutorial.


****

**Set Working Directory:** This lesson assumes that you have set your working 
directory to the location of the downloaded and unzipped data subsets. 

<a href="https://www.neonscience.org/set-working-directory-r" target="_blank"> An overview
of setting the working directory in R can be found here.</a>

**R Script & Challenge Code:** NEON data lessons often contain challenges that reinforce 
learned skills. If available, the code for challenge solutions is found in the
downloadable R script of the entire lesson, available in the footer of each lesson page.

****

## Additional Resources

* More on packages from <a href="http://www.statmethods.net/interface/packages.html" target="_blank">Quick-R</a>.
* <a href="http://www.r-bloggers.com/installing-r-packages/" target="_blank">Article on R-bloggers about installing packages in R</a>. 


</div>

## About Packages in R

Packages are collections of R functions, data, and compiled code in a 
well-defined format. When you install a package it gives you access to a set 
of commands that are not available in the base R set of functions. The directory
where packages are stored is called the library. R comes with a standard set of 
packages. Others are available for download and installation. Once installed, 
they have to be loaded into the session to be used.

## Installing Packages in R
To install a package you have to know where to get the package.  Most established
packages are available from 
<a href="http://cran.r-project.org/" target="_blank">"CRAN"</a> or the Comprehensive
R Archive Network. 

Packages download from specific CRAN "mirrors"" where the packages are saved 
(assuming that a binary, or set of installation files, is available for your 
operating system). If you have not set a preferred CRAN mirror in your 
`options()`, then a menu will pop up asking you to choose a location from which 
you'd like to install your packages.

To install any package from CRAN, you use `install.packages()`.  You only need to 
install packages the first time you use R (or after updating to a new version). 


    # install the ggplot2 package
    install.packages("ggplot2") 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**R Tip:** You can just type this into the command 
line of R to install each package. Once a package is installed, you don't have 
to install it again while using the version of R!
</div>


## Use a Package

Once a package is installed (basically the functions are downloaded to your 
computer), you need to "call" the package into the current session of R.  This 
is essentially like saying, "Hey R, I will be using these functions now, please 
have them ready to go".  You have to do this ever time you start a new R session,
so this should be at the top of your script. 

When you want to call a package, use `library(PackageNameHere)`. You may also 
see some people using `require()` -- while that works in most cases, it does 
function slightly differently and best practice is to use `library()`.  


    # load the package
    library(ggplot2)
 
## What Packages are Installed Now? 

If you want to use a package, but aren't sure if you've installed it before,
you can check! In code you, can use `installed.packages()`.  


    # check installed packages
    installed.packages()

If you are using RStudio, you can also check out the Packages tab. It will list
all the currently installed packages and have a check mark next to them if they 
are currently loaded and ready to use. You can also update and install packages
from this tab.  While you can "call" a package from here too by checking the box
I wouldn't recommend this as calling the package isn't in your script and you 
if you run the script again this could trip you up!

## Updating Packages

Sometimes packages are updated by the users who created them. Updating packages 
can sometimes make changes to both the package and also to how your code runs. 
** If you already have a lot of code using a package, be cautious about updating 
packages as some functionality may change or disappear.**  

Otherwise, go ahead and update old packages so things are up to date.

In code you, can use `old.packages()` to check to see what packages are out of 
date. 

`update.packages()` will update all packages in the known libraries 
interactively. This can take a while if you haven't done it recently! To update 
everything without any user intervention, use the `ask = FALSE` argument.

If you only want to update a single package, the best way to do it is using
`install.packages()` again.


    # list all packages where an update is available
    old.packages()
    
    # update all available packages
    update.packages()
    
    # update, without prompts for permission/clarification
    update.packages(ask = FALSE)
    
    # update only a specific package use install.packages()
    install.packages("plotly")

In <a href="http://www.rstudio.com/" target="_blank">RStudio</a>, you can also 
manage packages using Tools -> Install Packages.

<div id="ds-challenge" markdown="1">

### Challenge: Installing Packages

Check to see if you can install the `dplyr` package or a package of interest to
you. 

1. Check to see if the `dplyr` package is installed on your computer.
1. If it is not installed, install the "dplyr" package in R.
1. If installed, is it up to date? 

</div>




