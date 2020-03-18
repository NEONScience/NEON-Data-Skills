# redesign move existing .Rmd and .md files to their new homes using the 
# key filepath CSV file

setwd("~/Git/dev-aten/NEON-Data-Skills/processing_code/")

key=read.csv("redesign-tutorial-filepaths.csv")

# Find all .md files
md.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/old-tutorials/tutorials",
                       pattern="\\.md$", full.names = TRUE, recursive = TRUE)
