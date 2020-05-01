## Webstie redesign script to convert all graphics URLs to their new location


## read in changes (remap_key) and parse out the setion of the URL that is actually relevant
# Turn this into a before,after paired list

graphics.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/graphics", 
                             full.names = F, recursive = T)
# Remove all paths that are rfigs
graphics.files <- graphics.files[!grepl("rfigs/", x = graphics.files, fixed = T)]

# Remove all paths that are pyfigs
graphics.files <- graphics.files[!grepl("py-figs/", x = graphics.files, fixed = T)]


# Find all files to change
Rmd.files <- list.files("~/Git/dev-aten/NEON-Data-Skills",

                        pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)
md.files <- list.files("~/Git/dev-aten/NEON-Data-Skills",
                       pattern="\\.md$", full.names = TRUE, recursive = TRUE)
html.files <- list.files("~/Git/dev-aten/NEON-Data-Skills",
                         pattern="\\.html$", full.names = TRUE, recursive = TRUE)
ipynb.files <- list.files("~/Git/dev-aten/NEON-Data-Skills",
                          pattern="\\.ipynb$", full.names = TRUE, recursive = TRUE)

all.files=c(Rmd.files, md.files, html.files, ipynb.files)


for (file in all.files){
  print(file)
  # open .md (or .Rmd) file
  fileConn <- file(file)
  fl <- readLines(fileConn)
  
  for(i in 1:length(graphics.files)){
    
    p=paste0("/graphics/\\S+/",basename(graphics.files[i]))
    #p=paste0("graphics")
    rep_text=paste0("/graphics/",graphics.files[i])
    fl=gsub(p,rep_text,fl)
    
  }
  
  # write modified .md file out
  writeLines(fl, fileConn)
  close(fileConn)      
  
} #END file
