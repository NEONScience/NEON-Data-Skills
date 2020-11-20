# Replace graphics links with static URLs 
# Use gsub() to find instances of {{ site.baseurl }} AND {{site.baseurl}}

master_dir <- "~/Git/main/NEON-Data-Skills"

# Find all .Rmd files
# Do this again for .md files!
Rmd.files <- list.files("~/Git/main/NEON-Data-Skills/tutorials",
                        pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)
md.files <- list.files("~/Git/main/NEON-Data-Skills/tutorials",
                        pattern="\\.md$", full.names = TRUE, recursive = TRUE)

all.files=c(Rmd.files, md.files)

# character strings to find and their replacements.
# There may or may not be spaces surrounding "site.baseurl"

# First, replace the image references
graphics.base <- "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/"
rep_graphics_url <- "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/"

# Next, replace neonscience.org baseurl references
figures.base <- "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/"
rep_figures_url <- "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/"

# Finally, replace relative URL pathway references
rel.base <- "href=\"/"
rep_rel_url <- "href=\"https://www.neonscience.org/"

# Test a single file
#file=Rmd.files[26]

for (file in all.files){

# open .md (or .Rmd) file
fileConn <- file(file)
fl.md <- readLines(fileConn)

## First, edit the 
# use "fixed=TRUE" to read in string literally as-is with no special characters (important for . and {})
fl.mod <- gsub(graphics.base, rep_graphics_url, fl.md, fixed=TRUE)

fl.mod <- gsub(figures.base, rep_figures_url, fl.md, fixed=TRUE)
# fl.mod <- gsub(img.base2, rep_graphics_url, fl.mod, fixed=TRUE)
# 
# # now replace NEON urls
# fl.mod <- gsub(neon.base, rep_neon_url, fl.mod, fixed=TRUE)
# fl.mod <- gsub(neon.base2, rep_neon_url, fl.mod, fixed=TRUE)
# 
# # now add NEON urls to relative pathways URLs
# fl.mod <- gsub(rel.base, rep_rel_url, fl.mod, fixed=TRUE)

# write modified .md file out
writeLines(fl.mod, fileConn)
close(fileConn)      

} #END file
