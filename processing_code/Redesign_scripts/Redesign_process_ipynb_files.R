## convert python files to .md, .py, .html files and make figures

rm(list=ls())

input.path="~/Git/main/NEON-Data-Skills/tutorials/Python"

# Find all files to change
ipynb.files <- list.files(input.path,
                        pattern="\\.ipynb$", full.names = T, recursive = TRUE)

ipynb.files <- ipynb.files[7]
ipynb.files

basename(ipynb.files)
dirname(ipynb.files)




for(p in 1:length(ipynb.files)){
  
  print(paste("file #",p,ipynb.files[p]))
  
  # First, clear and run the notebook to ensure it all works properly
  system(paste0("cd ",dirname(ipynb.files[p]),
  "; jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace ",basename(ipynb.files[p]),
  "; jupyter nbconvert --to notebook --execute --inplace ",basename(ipynb.files[p])))
  
  system(paste0("cd ",dirname(ipynb.files[p]),
                "; jupyter nbconvert --to html ",basename(ipynb.files[p]),
                "; jupyter nbconvert --to script ",basename(ipynb.files[p]),
                "; jupyter nbconvert --to markdown ",basename(ipynb.files[p])))

  # ClearOutputPreprocessor will clear all chunk output and restart the kernel - leaving a blank Notebook ready to run
  # This is desirable for the notebook that people download, but not for the markdown that is shown on the website
  system(paste0("cd ",dirname(ipynb.files[p]),
  "; jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace ",basename(ipynb.files[p])))
  
  
  ## Must re-point URLs to figures in .md file
  
  png.pattern="\\!\\[png\\]\\("
  pattern="/Users/olearyd/Git/main/NEON-Data-Skills/tutorials/(.*)"
  URL.prefix=sub(pattern,"\\1",dirname(ipynb.files[p]))
  URL.prefix=paste0("![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/",URL.prefix,"/")
  
  MD.name=sub(".ipynb",".md",ipynb.files[p])
  
  fileConn <- file(MD.name)
  fl <- readLines(fileConn)
  
  fl2=sub(png.pattern,URL.prefix,fl)
  #head(fl2,13)
  # write modified .md file out
  writeLines(fl2, fileConn)
  close(fileConn)    
  
}
