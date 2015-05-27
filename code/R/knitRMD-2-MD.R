#!/usr/bin/env Rscript

input <- commandArgs(trailingOnly = TRUE)
KnitPost <- function(input, base.url = "/") {
  require(knitr)
  opts_knit$set(base.url = base.url)
  fig.path <- paste0("_posts/figs/", sub(".Rmd$", "", basename(input)), "/")
  opts_chunk$set(fig.path = fig.path)
  opts_chunk$set(fig.cap = "center")
  render_jekyll()
  print(paste0("/_posts/", sub(".Rmd$", "", basename(input)), ".md"))
  knit(input, output = paste0("/_posts/", sub(".Rmd$", "", basename(input)), ".md"), envir = parent.frame())
}

KnitPost(input)

#http://www.jonzelner.net/jekyll/knitr/r/2014/07/02/autogen-knitr/

filepath <- "~/Documents/GitHub_Lwasser/NEON_DataSkills"

#file <- "2015-05-21-R-Timeseries-Hierarchical-Data-Format-HDF5.Rmd"
#specify the file to be knit
file <- "~/Documents/GitHub_Lwasser/NEON_DataSkills/code/R/2014-11-05-Intro-HDF5-R.Rmd"
#get the working dir where the data are stored
wd <- getwd()
imagePath <- "images/rfigs/"

#copy .Rmd file to local working directory where the data are located
file.copy(from = file, to=wd, overwrite = TRUE)
require(knitr)

#set the base url for images and links in the md file
base.url="{{ site.baseurl }}/"
input=file
opts_knit$set(base.url = base.url)
#setup path to images
print(paste0(imagePath, sub(".Rmd$", "", basename(input)), "/"))
#check to see if image folders exist

#make sure image directory exists
if (file.exists(imagePath)){
    print("image dir exists - all good")
  } else {
    #create image directory structure
    dir.create(file.path(wd, "images"))
    dir.create(file.path(wd, "images/rfigs"))
  }

fig.path <- paste0("/images/rfigs/", sub(".Rmd$", "", basename(input)), "/")
opts_chunk$set(fig.path = fig.path)
opts_chunk$set(fig.cap = " ")
#render_jekyll()
render_markdown(strict = TRUE)
print(paste0(filepath,"/_posts/HDF5/", sub(".Rmd$", "", basename(input)), ".md"))
#knit(input, output = paste0(filepath,"/_posts/HDF5/", sub(".Rmd$", "", basename(input)), ".md"), envir = parent.frame())
knit(input, output = paste0("_posts/HDF5/", sub(".Rmd$", "", basename(input)), ".md"), envir = parent.frame())

#copy image directory over
file.copy(list.dirs("~/Documents/1_Workshops/R_HDF5Intr_NEON/_posts", full.names = TRUE), "~/Documents/1_Workshops/", recursive=TRUE)

#output code in R format
rCodeOutput <- paste0(filepath,"/code/R/", sub(".Rmd$", "", basename(input)), ".R")

#purl the code to R
purl(file, output = rCodeOutput)

