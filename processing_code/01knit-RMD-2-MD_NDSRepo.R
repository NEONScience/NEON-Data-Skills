##################

# This code takes a set of Rmd files from a designated git repo and
# 1) knits them to jekyll flavored markdown
# 2) purls them to .R files
# it then cleans up all image directories, etc from the working dir!
##################

require(knitr)
dirs <- c("R/eddy4r/",
          "R/neonUtilities/",
          "R/NEON-API/",
          "data-institutes/rmd-intro/",
          "R/R-nonSeries-lessons/",
          "dataviz/",
          "R/download-explore/")

#################### Set up Input Variables #############################

# set directory (order above) that you'd like to build

subDir <- dirs[7]

# Inputs - Where the git repo is on your computer
gitRepoPath <-"/Users/clunch/GitHub/NEON-Data-Skills"

# set working dir - this is where the data are located
wd <- "~/Documents/data"

################### CONFIG BELOW IS REQUIRED BY JEKYLL - DON'T CHANGE ##########
#set data working dir
setwd(wd)

# set series subdir
#subDir <- paste0(dir,"/")

# don't change - this is the tutorials dir location required by jekyll
postsDir <- file.path("tutorials", subDir)
codeDir <- file.path("code", subDir)

# images path
imagePath <- paste0("images/rfigs/", subDir)

# set the base url for images and links in the md file
base.url="{{ site.baseurl }}/"
opts_knit$set(base.url = base.url)

#################### Check For/Set up Image Directories  #############################
# make sure image directory exists within the working directory (will later by 
# transfered, and deleted)
# if it doesn't exist, create it
# note this will fail if the sub dir doesn't exist
if (file.exists(file.path(wd, imagePath))){
  print("Temp Image Dirs Exists! ")
} else {
  #create image directory structure
  dir.create(file.path(wd, imagePath), recursive = TRUE)
  print("temp image directory created!")
}

# NOTE -- delete the image directory at the end!


# make sure image subdir exists in the git repo
# then clean out image subdir on git if it exists
# note this will fail if the sub dir doesn't exist
if (file.exists(file.path(gitRepoPath, imagePath))){
  print("GIT image dir exists")
} else {
  # create image directory structure
  dir.create(file.path(gitRepoPath, imagePath), recursive = TRUE)
  print("GIT image directory created!")
}

################# Check For/Set up/Clean out Code Dir  #################

if (file.exists(file.path(gitRepoPath, codeDir))){
  print("code dir exists - and has been cleaned out")
} else {
  # create image directory structure
  dir.create(file.path(gitRepoPath, codeDir), recursive = TRUE)
  print("new code sub dir created.")
}

################# Clean out Dirs  #################
# NOTE: comment this out if you just want to rebuild one lesson

# clean out posts dir to avoid the issue of duplicate files -- WHY? this deletes the files?
#unlink(paste0(gitRepoPath, postsDir,"*"), recursive = TRUE)
# clean out code dir to avoid the issue of duplicate files
unlink(paste0(gitRepoPath,"/", codeDir,"*"), recursive = TRUE)
# clean out images dir to avoid the issue of duplicate files
unlink(paste0(gitRepoPath,"/", imagePath,"*"), recursive = TRUE)


# copy image directory over
# file.copy(paste0(wd,"/",fig.path), paste0(gitRepoPath,imagePath), recursive=TRUE)

# copy rmd file to the rmd directory on git
# file.copy(paste0(wd,"/",basename(files)), gitRepoPath, recursive=TRUE)
#################### Get List of RMD files to Render #############################


# get a list of files to knit / purl
rmd.files <- list.files(file.path(gitRepoPath, postsDir), pattern="\\.Rmd$", full.names = TRUE )

#################### Set up Image Directory #############################

# just render one file
# rmd.files <- rmd.files[5]

for (files in rmd.files) {

  # copy .Rmd file to data working directory
  file.copy(from = files, to=wd, overwrite = TRUE)
  input=basename(files)

  # setup path to images
  # print(paste0(imagePath, sub(".Rmd$", "", basename(input)), "/"))
  fig.path <- print(paste0(imagePath, sub(".Rmd$", "", input), "/"))


  opts_chunk$set(fig.path = fig.path)
  opts_chunk$set(fig.cap = " ")
  # render_jekyll()
  render_markdown(strict = TRUE)
  # create the markdown file name - add a date at the beginning to Jekyll recognizes
  # it as a post
  mdFile <- paste0(file.path(gitRepoPath,postsDir),sub(".Rmd$", "", input), ".md")

  # knit Rmd to jekyll flavored md format
  knit(input, output = mdFile, envir = parent.frame())

  # COPY image directory, rmd file OVER to the GIT SITE###
  # only copy over if there are images for the lesson
  if (dir.exists(paste0(wd,"/",fig.path))){
    # copy image directory over
    file.copy(paste0(wd,"/",fig.path), file.path(gitRepoPath,imagePath), recursive=TRUE)
  }

  # copy rmd file to the rmd directory on git
  # file.copy(paste0(wd,"/",basename(files)), gitRepoPath, recursive=TRUE)

  # delete local repo copies of RMD files just so things are cleaned up??

  ## OUTPUT STUFF TO R ##
  # output (purl) code in .R format
  rCodeOutput <- paste0(file.path(gitRepoPath, codeDir), sub(".Rmd$", "", basename(files)), ".R")

  # purl the code to R
  purl(files, output = rCodeOutput)

  # CLEAN UP
  # remove Rmd file from data working directory
  unlink(basename(files))

  # print when file is knit
  doneWith <- paste0("processed: ",files)
  print(doneWith)

}

###### Local image cleanup #####

# clean up working directory images dir (remove all sub dirs)
unlink(paste0(wd,"/",imagePath,"*"), recursive = TRUE)

########################### end script
