## Webstie redesign script to convert all graphics URLs to their new location.
## This file was needed after we re-organized the structure of the /graphics/ dir

## Updated to work with ipynb files


## read in changes (remap_key) and parse out the section of the URL that is actually relevant
# Turn this into a before,after paired list

## Must set the raw.prefix to 'end' at the same point where the input.path is looking, so that you can append
## the files.short to the prefix to create correct R.URL

raw.prefix = "https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/"
#"https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/tutorials/R/NEON-general/neon-code-packages/NEON-API-How-To/NEON-API-How-To.R"


input.path="~/Git/main/NEON-Data-Skills/tutorials/Python/"

# Find all files to change
Rmd.files <- list.files(input.path,
                              pattern="\\.ipynb$", full.names = T, recursive = TRUE)
# Same files, but without prefix
Rmd.files.short <- list.files(input.path,
                        pattern="\\.ipynb$", full.names = F, recursive = TRUE)

R.files=sub(pattern = "(.*)\\..*$", replacement = "\\1.ipynb", Rmd.files.short)
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
  # file=md.files[i]
  # print(file)
  # # open .md (or .Rmd) file
  # fileConn <- file(file)
  # fl <- readLines(fileConn)
  # 
  # p="^code1:.*$"
  # fl2=sub(p,R.URL[i],fl)
  # #head(fl2,13)
  # # write modified .md file out
  # writeLines(fl2, fileConn)
  # close(fileConn)     
} #END file
