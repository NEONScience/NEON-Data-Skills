##################

# This code attempts to run all the code chunks in the specified Rmd files.
##################
rm(list=ls())
require(knitr)
require(markdown)
options(timeout=300)

# 2 input options:
# 1. Choose a directory under 'tutorials'. Code will attempt all Rmd files found 
#    under the directory (recursively)
# 2. Input a list of paths to specific Rmd files.
dirs <- c("R/NEON-general/neon-overview")

# dirs <- c("R/NEON-general/neon-overview/NEON-download-explore/NEON-download-explore-content.Rmd")

#################### Set up Input Variables #############################

# option to subset the list above

subDir <- dirs[1]

# Inputs - Where the git repo is on your computer
gitRepoPath <-"~/GitHub/NEON-Data-Skills"

gitRepoPath <- path.expand(gitRepoPath) # expand tilde to later remove this root dir from longer filepaths

# set working dir - this is where the data are located
# this is also where a temporary dir is created 
# to store figures (for easier cleanup at the end)
wd_processing_doc <- "/Users/clunch/data"

# set the base url for images and links in the md file
base.url <- "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/"

opts_knit$set(base.url = base.url)
opts_knit$set(root.dir = wd_processing_doc)

#################### Get List of RMD files to Render #############################

# get a list of files to knit / purl
rmd.files <- list.files(file.path(gitRepoPath, "tutorials", subDir),
                        pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)

# Optional - view list of files to ensure you're processing the ones you want to
rmd.files

#################### Set up Image Directory #############################

setwd(wd_processing_doc)

for (f in rmd.files) {
  
  ## to get rid of gitRepoPath root
  subPath <- sub(gitRepoPath, "", dirname(f) )
  
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
  input <- basename(f)
  
  
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