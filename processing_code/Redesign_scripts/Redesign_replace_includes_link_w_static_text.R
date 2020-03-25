# Replace graphics links with static URLs 
# Use gsub() to find instances of {{ site.baseurl }} AND {{site.baseurl}}

library(readr)

# Find all .Rmd files
# Do this again for .md files!
Rmd.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/tutorials",
                        pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)
md.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/tutorials",
                        pattern="\\.md$", full.names = TRUE, recursive = TRUE)

all.files=c(Rmd.files, md.files)

for(file in all.files){
  print(file)
  # read in the file as a single string of text
  file_text=read_file(file)
  
  p="^.*\\{%\\sinclude(\\S+)\\.html\\s%\\}.*$"
  files_vector=sub(p,"\\1",file_text) ## to extract file name
  # if nothing matches the pattern above, this line will return
  # the entire read-in file. So, we check that it is actually a file name
  # below using file.exists()
  while(file.exists(paste0("~/Git/dev-aten/NEON-Data-Skills/processing_code/_includes",files_vector[1],".txt"))){
    print(files_vector[1])
    # Read in the includes file text to use as a replacement
    rep_text=read_file(file(paste0("~/Git/dev-aten/NEON-Data-Skills/processing_code/_includes",files_vector[1],".txt")))
    
    # Now, we actually replace the specific {% include...html %} 
    p2=paste0("{% include",files_vector[1],".html %}")
    
    # replace pattern (p2) with the _includes file text (rep_text)
    file_text=sub(p2,rep_text,file_text, fixed = T)
    
    # Finally, look for any more {% include... %} text in the file and repeat as necessary
    files_vector=sub(p,"\\1",file_text) ## to extract file name
  }
  write_file(file_text, path=file)
}
