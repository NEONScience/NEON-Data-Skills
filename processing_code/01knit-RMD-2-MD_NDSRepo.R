##################

# This code takes a set of Rmd files from a designated git repo and
# 1) knits them to jekyll flavored markdown
# 2) purls them to .R files
# it then cleans up all image directories, etc from the working dir!
##################
rm(list=ls())
require(knitr)
require(markdown)

# Choose the directory under 'tutorials' to knit
# You can choose a high-level directory and this script will search
# that directory recursively, knitting every .Rmd within it.
# Note: do not put '/' at the end of your directory name
dirs <- c("R/NEON-general/neon-overview/NEON-download-explore",
          "R/NEON-general/neon-code-packages/neonUtilities",
          "R/NEON-general/neon-code-packages/spatialData",
          "R/Lidar/lidar-topography/veg_structure_and_chm",
          "R/NEON-general/neon-code-packages/neonOS",
          "R/biodiversity/small-mammals")

#################### Set up Input Variables #############################

# set directory (order above) that you'd like to build

subDir <- dirs[6]

# Inputs - Where the git repo is on your computer
gitRepoPath <-"~/Documents/GitHub/FORKS/NEON-Data-Skills"

gitRepoPath <- path.expand(gitRepoPath) # expand tilde to later remove this root dir from longer filepaths

# set working dir - this is where the data are located
# this is also where a temporary dir is created by this
# processing_code to generate documents and figures
wd_processing_doc <- "/Users/paull/Documents/"

# set the base url for images and links in the md file
base.url <- "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/"

# how to reference raw images on github:
# https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/NEON-general/GGplot.png
opts_knit$set(base.url = base.url)
opts_knit$set(root.dir = wd_processing_doc)

#################### Get List of RMD files to Render #############################

# get a list of files to knit / purl
rmd.files <- list.files(file.path(gitRepoPath, "tutorials", subDir),
                        pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)

# Optional - view list of files to ensure you're processing the ones you want to
rmd.files

#################### Set up Image Directory #############################

# just render one file
# rmd.files <- rmd.files[43:61] #41-44 are CO floods tutorials. 
# #41 COOP-NEIS-Precipitation-In-R.Rmd is causing a problem when reading in data
# so is #42 nCLIMDIV-Palmer-Drought-In-R.Rmd
# Should update with paste0(wd,...) to make it work again!

#rmd.files <- c(rmd.files[1:40], rmd.files[43:61])

setwd(wd_processing_doc)

for (f in rmd.files) {
  
  ## to get rid of gitRepoPath root
  subPath=sub(gitRepoPath, "", dirname(f) )
  
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
  #file.copy(from = f, to=tut_temp_dir, overwrite = TRUE)
  
  # get the file's name to make output filenames
  input=basename(f)
  
  
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
  fileName <- sub("\\.Rmd$","",basename(f))
  outPath <- paste0(tut_temp_dir, "/", fileName)
  mdFile <- paste0(outPath, ".md")
  rCodeOutput <- paste0(outPath, ".R")
  htmlFile <- paste0(outPath, ".html")
  pdfFile <- paste0(outPath, ".pdf")
  
  
  setwd(wd_processing_doc)
  # knit Rmd to jekyll flavored md format
  # Still calling file in original github location, not in temp
  knit(f, output = mdFile, envir = parent.frame())
  
  # make an HTML version too
  markdown::markdownToHTML(mdFile, output = htmlFile)
  
  # purl the code to R
  purl(f, output = rCodeOutput)
  
  # COPY image directory, rmd file OVER to the GIT SITE###
  # only copy over if there are images for the lesson
  if (dir.exists(tut_temp_dir)){
    # copy image directory over
    file.copy(tut_temp_dir, 
              dirname(dirname(f)), ## gets one level higher so that f copied to correct location
              recursive=TRUE)
  }
  
  ################# Clean out Dirs  #################
  unlink(paste0(tut_temp_dir,"/*"), recursive = TRUE)
  
  # print when file is knit
  print(paste0("processed: ",f))
  
} # END 'files'

###### Local image cleanup #####

# clean up working directory images dir (remove all sub dirs)
#unlink(paste0(wd_processing_doc,"/",subPath,"*"), recursive = TRUE)

########################### end script