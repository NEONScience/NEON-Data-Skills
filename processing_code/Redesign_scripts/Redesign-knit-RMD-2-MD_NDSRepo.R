## Notes for website redesign of this code
# Some things, such as URLs, will need to be changed after migrating the 
# dev-aten branch to the master branch. These locations are marked with the tag:
### CHANGE AFTER MIGRATION

# Items to be changed prior to migration:
### CHANGE NOW


##################

# This code takes a set of Rmd files from a designated git repo and
# 1) knits them to jekyll flavored markdown
# 2) purls them to .R files
# it then cleans up all image directories, etc from the working dir!
##################

require(knitr)
require(markdown)

# Choose the directory under 'tutorials' to knit
# You can choose a high-level directory and this script will search
# that directory recursively, knitting every .Rmd within it.
# Note: do not put '/' at the end of your directory name
dirs <- c("R/eddy4r",
          "R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R",
          "R/R-skills/Using-hdf5-r/Intro-HDF5-R")

#################### Set up Input Variables #############################

# set directory (order above) that you'd like to build

subDir <- dirs[2] 

# Inputs - Where the git repo is on your computer
### CHANGE AFTER MIGRATION
gitRepoPath <-"~/Git/dev-aten/NEON-Data-Skills"

gitRepoPath <- path.expand(gitRepoPath) # expand tilde to later remove this root dir from longer filepaths

# Where do you keep your data for the tutorials? Previously, this was in 
# "~/Git/data" but then it doesn't work with new wd style. This should help people 
# who want to knit the documents themselves.
# dataPath <- "~/Documents/data"
### Deprecating this because ~/Git/data must be working dir for fig paths to work

# set working dir - this is where the data are located
# this is also where a temporary dir is created by this
# processing_code to generate documents and figures
wd_processing_doc <- "~/Git/data"

# set the base url for images and links in the md file
### CHANGE AFTER MIGRATION
### CHANGE NOW
base.url <- "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/"

# how to reference raw images on github:
# https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/NEON-general/GGplot.png
opts_knit$set(base.url = base.url)
opts_knit$set(root.dir = wd_processing_doc)

#################### Get List of RMD files to Render #############################

# get a list of files to knit / purl
rmd.files <- list.files(file.path(gitRepoPath, "tutorials", subDir),
                        pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)



#################### Set up Image Directory #############################

# just render one file
#rmd.files <- rmd.files[43:61] #41-44 are CO floods tutorials. 
# #41 COOP-NEIS-Precipitation-In-R.Rmd is causing a problem when reading in data
# so is #42 nCLIMDIV-Palmer-Drought-In-R.Rmd
# Should update with paste0(wd,...) to make it work again!

#rmd.files <- c(rmd.files[1:40], rmd.files[43:61])

setwd(wd_processing_doc)

for (files in rmd.files) {
  
  ## to get rid of gitRepoPath root
  subPath=sub(gitRepoPath, "", dirname(files) )
  
  tut_temp_dir <- paste0(wd_processing_doc, subPath)
  
  if (file.exists(tut_temp_dir)){
    print("Tutorial temp Dir Exists! ")
  } else {
    #create image directory structure
    dir.create(tut_temp_dir, recursive = TRUE)
    print("Tutorial temp directory created!")
  }
  
  tut_temp_img_path <- file.path(tut_temp_dir,"rfigs")
  
  if (file.exists(tut_temp_img_path)){
    print("Temp Image Dir Exists! ")
  } else {
    #create image directory structure
    dir.create(tut_temp_img_path, recursive = TRUE)
    print("temp image directory created!")
  }
  
  subPath_img <- file.path(subPath, "rfigs")
  
  # copy .Rmd file to data working directory
  #file.copy(from = files, to=tut_temp_dir, overwrite = TRUE)
  
  # get the file's name to make output filenames
  input=basename(files)
  
  
  # setup path to images
  fig.path <- print(paste0(subPath_img, "/"))
  fig.path <- substr(fig.path,2,nchar(fig.path))
  # remember, fig.path gets concatenated with the base.url to make the 
  # URL for the figures in the resulting markdown document.
  opts_chunk$set(fig.path = fig.path)
  opts_chunk$set(fig.cap = " ")
  # render_jekyll()
  render_markdown(strict = TRUE)
  
  
  # create output file names - add a date at the beginning to Jekyll recognizes
  # it as a post
  fileName <- sub("\\.Rmd$","",basename(files))
  outPath <- paste0(tut_temp_dir, "/", fileName)
  mdFile <- paste0(outPath, ".md")
  rCodeOutput <- paste0(outPath, ".R")
  htmlFile <- paste0(outPath, ".html")
  pdfFile <- paste0(outPath, ".pdf")
  
  
  setwd(wd_processing_doc)
  # knit Rmd to jekyll flavored md format
  # Still calling file in original github location, not in temp
  knit(files, output = mdFile, envir = parent.frame())
  
  # mak an HTML version too
  markdown::markdownToHTML(mdFile, output = htmlFile)
  
  # purl the code to R
  purl(files, output = rCodeOutput)
  
  # COPY image directory, rmd file OVER to the GIT SITE###
  # only copy over if there are images for the lesson
  if (dir.exists(tut_temp_dir)){
    # copy image directory over
    file.copy(tut_temp_dir, 
              dirname(dirname(files)), ## gets one level higher so that files copied to correct location
              recursive=TRUE)
  }
  
  ################# Clean out Dirs  #################
  unlink(paste0(tut_temp_dir,"/*"), recursive = TRUE)
  
  # print when file is knit
  print(paste0("processed: ",files))
  
} # END 'files'

###### Local image cleanup #####

# clean up working directory images dir (remove all sub dirs)
#unlink(paste0(wd_processing_doc,"/",subPath,"*"), recursive = TRUE)

########################### end script
#files=rmd.files[13]
#files