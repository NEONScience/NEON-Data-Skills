#!/usr/bin/env Rscript

#input <- commandArgs(trailingOnly = TRUE)
#KnitPost <- function(input, base.url = "/") {
#  require(knitr)
#  opts_knit$set(base.url = base.url)
#  fig.path <- paste0("_posts/figs/", sub(".Rmd$", "", basename(input)), "/")
#  opts_chunk$set(fig.path = fig.path)
#  opts_chunk$set(fig.cap = "center")
#  render_jekyll()
#  print(paste0("/_posts/", sub(".Rmd$", "", basename(input)), ".md"))
#  knit(input, output = paste0("/_posts/", sub(".Rmd$", "", basename(input)), ".md"), envir = parent.frame())
#}

#KnitPost(input)

#http://www.jonzelner.net/jekyll/knitr/r/2014/07/02/autogen-knitr/

# Determine whether i'm on a MAC or PC, then define paths
if(.Platform$OS.type == "windows") {
  print("defining windows paths")
  #this is the path to the github repo on my PC
  gitRepoPath <- "C:/Users/lwasser/Documents/GitHub/NEON-Data-Skills/" 
} else {
    print("defining MAC paths")
    #this is the MAC path to the github repo
    #gitRepoPath <- "~/Documents/GitHub_Lwasser/NEON_DataSkills/"
    gitRepoPath <- "~/Documents/GitHub/NEON-Data-Skills/"
    }

#repoCodePath <- "code/R/rmdFiles"
repoCodePath <- "code/R/"
#get the working dir where the data are stored
wd <- getwd()
#specify the file to be knit
#
#file <- "2014-11-05-Intro-HDF5-R.Rmd"
#file <- "2015-05-21-R-Timeseries-HDF5.Rmd"
#file <- "2015-05-27-R-dplyr-GREPL-Summarise-Piping.Rmd"
#file  <- "2015-06-08-Work-With-Hyperspectral-Data-In-R.Rmd"
#file <- "2015-08-08-Plot-Hyperspectral-Spectra.Rmd"
file <- "2015-06-08-RasterStack-RGB-Images-in-R-Using-HSI.Rmd"
#file <- "2015-06-30-Create-Lidar-CHM-R.Rmd"
#file <- "2014-11-03-Working-With-Rasters-in-R-Python-GIS.Rmd"
#file <- "2015-07-22-Introduction-to-Raster-Data-In-R.Rmd"


#copy .Rmd file to local working directory where the data are located
#file.copy(from = (paste0(gitRepoPath,repoCodePath,file)), to=wd, overwrite = TRUE)

#specify where should the file go within the GH repo
#postsDir <- ("_posts/SPATIALDATA/")
postsDir <- ("_posts/HYPERSPECTRAL/")

#define the file path
imagePath <- "images/rfigs/"
# poth to RMD files

require(knitr)

#set the base url for images and links in the md file
base.url="{{ site.baseurl }}/"
input=file
opts_knit$set(base.url = base.url)
#setup path to images
print(paste0(imagePath, sub(".Rmd$", "", basename(input)), "/"))

figDir <- print(paste0("images/", sub(".Rmd$", "", basename(input)), "/"))

#make sure image directory exists
#if it doesn't exist, create it
#note this will fail if the sub dir doesn't exist
if (file.exists(paste0(wd,"/","images"))){
    print("image dir exists - all good")
  } else {
    #create image directory structure
    dir.create(file.path(wd, "images/"))
    dir.create(file.path(wd, "images/rfigs"))
    dir.create(file.path(wd, figDir))
    print("image directories created!")
  }

fig.path <- paste0("images/rfigs/", sub(".Rmd$", "", basename(input)), "/")
opts_chunk$set(fig.path = fig.path)
opts_chunk$set(fig.cap = " ")
#render_jekyll()
render_markdown(strict = TRUE)
print(paste0(gitRepoPath,postsDir, sub(".Rmd$", "", basename(input)), ".md"))
#knit(input, output = paste0(filepath,"/_posts/HDF5/", sub(".Rmd$", "", basename(input)), ".md"), envir = parent.frame())
#knit the markdown doc
knit(input, output = paste0(gitRepoPath,postsDir, sub(".Rmd$", "", basename(input)), ".md"), envir = parent.frame())
paste0(wd,"/_posts")


#### COPY EVERYTHING OVER to the GIT SITE###
#copy markdown directory over
#note: this should all become variables

#the code below isn't necessary if i knit it directly
#file.copy(list.dirs("~/Documents/1_Workshops/R_HDF5Intr_NEON/_posts/HDF5", full.names = TRUE), "~/Documents/GitHub_Lwasser/NEON_DataSkills/_posts", recursive=TRUE)
#copy image directory over
file.copy(paste0(wd,"/",imagePath), paste0(gitRepoPath,"images/"), recursive=TRUE)
#copy rmd file to the rmd directory on git
file.copy(paste0(wd,"/",file), paste0(gitRepoPath,"code/R"), recursive=TRUE)

#delete local repo copies of RMD files just so things are cleaned up??

## OUTPUT STUFF TO R ##
#output code in R format
rCodeOutput <- paste0(gitRepoPath,"code/R/", sub(".Rmd$", "", basename(input)), ".R")
rCodeOutput
#purl the code to R
purl(file, output = rCodeOutput)

