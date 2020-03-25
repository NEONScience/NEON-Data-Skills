# Replace graphics links with static URLs 
# Use gsub() to find instances of {{ site.baseurl }} AND {{site.baseurl}}

library(readr)

master_dir <- "~/Git/dev-aten/NEON-Data-Skills"

# Find all .Rmd files
# Do this again for .md files!
Rmd.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/tutorials",
                        pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)
md.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/tutorials",
                        pattern="\\.md$", full.names = TRUE, recursive = TRUE)

#all.files=c(Rmd.files, md.files)
all.files="~/Git/dev-aten/NEON-Data-Skills/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/Work-With-Hyperspectral-Data-In-R.Rmd"
#test_text=read_file("~/Git/dev-aten/NEON-Data-Skills/tutorials/R/Hyperspectral/Intro-hyperspectral/Work-With-Hyperspectral-Data-In-R/Work-With-Hyperspectral-Data-In-R.Rmd")

for(file in all.files){
  print(file)
  test_text=read_file(file)
  
  p="^.*\\{%\\sinclude(\\S+)\\.html\\s%\\}.*$"
  files_vector=sub(p,"\\1",test_text) ## to extract file name
  #print(files_vector)
  while(file.exists(paste0("~/Git/dev-aten/NEON-Data-Skills/processing_code/_includes",files_vector[1],".txt"))){
    print("yes")
    rep_text=read_file(file(paste0("~/Git/dev-aten/NEON-Data-Skills/processing_code/_includes",files_vector[1],".txt")))
    
    p2=paste0("{% include",files_vector[1],".html %}")
    test_text=sub(p2,rep_text,test_text, fixed = T)
    files_vector=sub(p,"\\1",test_text) ## to extract file name
  }
  write_file(test_text, path="~/Git/dev-aten/NEON-Data-Skills/test.rmd")
}

# p="^.*\\{%\\sinclude(\\S+)\\.html\\s%\\}.*$"
# files_vector=sub(p,"\\1",test_text) ## to extract file name
# 
# #rep_text=readLines(file(paste0("~/Git/dev-aten/NEON-Data-Skills/processing_code/_includes",files_vector[1],".txt")))
# rep_text=read_file(file(paste0("~/Git/dev-aten/NEON-Data-Skills/processing_code/_includes",files_vector[1],".txt")))
# 
# #p2="\\{%\\sinclude(\\S+)\\.html\\s%\\}"
# 
# p2=paste0("{% include",files_vector[1],".html %}")
# test_text3=sub(p2,rep_text,test_text, fixed = T)
# files_vector=sub(p,"\\1",test_text2) ## to extract file name
# 
# 
# write_file(test_text3, path="~/Git/dev-aten/NEON-Data-Skills/test.rmd")

# fileConn <- file(file)
# fl.md <- readLines(fileConn)
# 
# 
# # Test a single file
# #file=Rmd.files[26]
# 
# for (file in all.files){
# 
# # open .md (or .Rmd) file
# fileConn <- file(file)
# fl.md <- readLines(fileConn)
# 
# ## First, edit the 
# # use "fixed=TRUE" to read in string literally as-is with no special characters (important for . and {})
# fl.mod <- gsub(img.base, rep_graphics_url, fl.md, fixed=TRUE)
# fl.mod <- gsub(img.base2, rep_graphics_url, fl.mod, fixed=TRUE)
# 
# # now replace NEON urls
# fl.mod <- gsub(neon.base, rep_neon_url, fl.mod, fixed=TRUE)
# fl.mod <- gsub(neon.base2, rep_neon_url, fl.mod, fixed=TRUE)
# 
# # now add NEON urls to relative pathways URLs
# fl.mod <- gsub(rel.base, rep_rel_url, fl.mod, fixed=TRUE)
# 
# # write modified .md file out
# writeLines(fl.mod, fileConn)
# close(fileConn)      
# 
# } #END file
