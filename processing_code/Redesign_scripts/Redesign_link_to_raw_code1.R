## Webstie redesign script to convert all graphics URLs to their new location.
## This file was needed after we re-organized the structure of the /graphics/ dir


## read in changes (remap_key) and parse out the setion of the URL that is actually relevant
# Turn this into a before,after paired list

raw.prefix = "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/"
#"https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/NEON-general/neon-code-packages/NEON-API-How-To/NEON-API-How-To.R"

# Find all files to change
Rmd.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/tutorials/R",
                              pattern="\\.Rmd$", full.names = T, recursive = TRUE)
# Same files, but without prefix
Rmd.files.short <- list.files("~/Git/dev-aten/NEON-Data-Skills/tutorials/R",
                        pattern="\\.Rmd$", full.names = F, recursive = TRUE)

R.files=sub(pattern = "(.*)\\..*$", replacement = "\\1.R", Rmd.files.short)
md.files=sub(pattern = "(.*)\\..*$", replacement = "\\1.md", Rmd.files)
R.URL=paste0("code1: ",raw.prefix, R.files)

for (i in 1:length(Rmd.files)){
  
  # Rmd first
  file=Rmd.files[i]
  print(file)
  # open .md (or .Rmd) file
  fileConn <- file(file)
  fl <- readLines(fileConn)
  
  p="^code1:.*$"
  fl2=sub(p,R.URL[i],fl)
  #head(fl2,13)
  # write modified .md file out
  writeLines(fl2, fileConn)
  close(fileConn)     
  
  ## now do .md file too
  file=md.files[i]
  print(file)
  # open .md (or .Rmd) file
  fileConn <- file(file)
  fl <- readLines(fileConn)
  
  p="^code1:.*$"
  fl2=sub(p,R.URL[i],fl)
  #head(fl2,13)
  # write modified .md file out
  writeLines(fl2, fileConn)
  close(fileConn)     
} #END file
