## convert python files to .md, .py, .html files and make figures

rm(list=ls())

input.path="~/Git/dev-aten/NEON-Data-Skills/tutorials/Python"

# Find all files to change
ipynb.files <- list.files(input.path,
                        pattern="\\.ipynb$", full.names = T, recursive = TRUE)
ipynb.files

basename(ipynb.files)
dirname(ipynb.files)

for(p in 1:length(ipynb.files)){
  
  print(paste("file #",p,ipynb.files[p]))
  system(paste0("cd ",dirname(ipynb.files[p]),
                "; jupyter nbconvert --to html ",basename(ipynb.files[p]),
                "; jupyter nbconvert --to script ",basename(ipynb.files[p]),
                "; jupyter nbconvert --to markdown ",basename(ipynb.files[p])))
  
}
