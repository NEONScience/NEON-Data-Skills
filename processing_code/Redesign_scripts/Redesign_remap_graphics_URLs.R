## Webstie redesign script to convert all graphics URLs to their new location


## read in changes (remap_key) and parse out the setion of the URL that is actually relevant
# Turn this into a before,after paired list

graphics.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/graphics", 
                             full.names = F, recursive = T)
graphics.no.rfigs <- graphics.files[!grepl("rfigs/", x = graphics.files, fixed = T)]

#setwd("~/Git/dev-aten/NEON-Data-Skills/processing_code/Redesign_scripts/")
#write.csv(graphics.files, file="list_of_graphics_files_before_move.csv")

# Read all .Rmd, .md, and .html files and concatenate the lists together

master_dir <- "~/Git/dev-aten/NEON-Data-Skills"

# Find all .Rmd files
# Do this again for .md files!
Rmd.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/tutorials",
                        pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)
md.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/tutorials",
                       pattern="\\.md$", full.names = TRUE, recursive = TRUE)
html.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/tutorials",
                       pattern="\\.html$", full.names = TRUE, recursive = TRUE)

all.files=c(Rmd.files, md.files, html.files)


# Loop through that list
for (file in all.files){
  
  # open .md (or .Rmd) file
  fileConn <- file(file)
  fl.md <- readLines(fileConn)
  
  for(i in 1:length(remap_key[[1]])){
    
    # use "fixed=TRUE" to read in string literally as-is with no special characters (important for . and {})
    fl.md <- gsub(remap_key[i,1], remap_key[i,2], fl.md, fixed=TRUE)
    
  }

  # write modified .md file out
  writeLines(fl.md, fileConn)
  close(fileConn)      
  
} #END file


