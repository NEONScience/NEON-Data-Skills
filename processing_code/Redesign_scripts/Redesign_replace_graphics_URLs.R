# Replace graphics links with static URLs 
# Use gsub() to find instances of {{ site.baseurl }} AND {{site.baseurl}} that end with an image suffix (png, gif, jpg, any others??)
# Also lookfor {{ site.baseurl}} and {{site.baseurl }} ?? Maybe some others will pop up too

master_dir <- "~/Git/dev-aten/NEON-Data-Skills"

# Find all .Rmd files
# Do this again for .md files!
Rmd.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/tutorials",
                        pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)



# file path to image file folder
# this should not need to change for different tutorials
img.base <- "{{ site.baseurl }}/images/"
img.base2 <- "{{site.baseurl}}/images/"
rep_graphics_url <- "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/"

neon.base <- "{{ site.baseurl }}/"
neon.base2 <- "{{site.baseurl}}/"
rep_neon_url <- "https://www.neonscience.org/"

rel.base <- "href=\"/"
rep_rel_url <- "href=\"https://www.neonscience.org/"
# replce this with rep_neon_url

file=Rmd.files[26]

#for (file in Rmd.files){

# open .md (or .Rmd) file
fileConn <- file(file)
fl.md <- readLines(fileConn)

## First, edit the 
# use "fixed=TRUE" to read in string literally as-is with no special characters (important for . and {})
fl.mod <- gsub(img.base, rep_graphics_url, fl.md, fixed=TRUE)
fl.mod <- gsub(img.base2, rep_graphics_url, fl.mod, fixed=TRUE)

# now replace NEON urls
fl.mod <- gsub(neon.base, rep_neon_url, fl.mod, fixed=TRUE)
fl.mod <- gsub(neon.base2, rep_neon_url, fl.mod, fixed=TRUE)

# now add NEON urls to relative pathways URLs
fl.mod <- gsub(rel.base, rep_rel_url, fl.mod, fixed=TRUE)

# write modified .md file out
writeLines(fl.mod, fileConn)
close(fileConn)      

  
  
  
# } #END file