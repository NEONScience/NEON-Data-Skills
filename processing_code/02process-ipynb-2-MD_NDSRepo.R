## convert python-based tutorial .ipynb files to 
## .md, .py, .html files, make figures, and 
## update URLs to figures in the .md file

rm(list=ls())

#### MUST CHANGE FOR LOCAL MACHINE ####
# This should point to the absolute path to your tutorials dir
# and must include the (.*) after /tutorials/
pattern="/Users/olearyd/Git/main/NEON-Data-Skills/tutorials/(.*)"
#### MUST CHANGE FOR LOCAL MACHINE ####

# Script will search recursively in this file for all .ipynb files
input.path="~/Git/main/NEON-Data-Skills/tutorials/Python/Hyperspectral/indices/Cal_NDVI_Extract_Spectra_Masks_Flightlines_py/"

# Find all files to change
ipynb.files <- list.files(input.path,
                        pattern="\\.ipynb$", full.names = T, recursive = TRUE)

ipynb.files

# checks to see that the filepaths look right
# basename(ipynb.files)
# dirname(ipynb.files)


for(p in 1:length(ipynb.files)){
#for(p in 7){ #run just 'n'th file in list
  
  print(paste("file #",p,ipynb.files[p]))
  
  # First, clear and run the notebook to ensure it all works properly
  # See the timeout limit - this can take a looong time to run 
  # for some of the turtorials, especially the hyperspectral lessons
  # with clustering and unsupervised classifcation
  # This can also be commented out if you know that the file is ready
  # to convert below
  system(paste0("cd ",dirname(ipynb.files[p]),
  "; jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace ",basename(ipynb.files[p]),
  "; jupyter nbconvert --ExecutePreprocessor.timeout=6000 --ExecutePreprocessor.kernel_name=py37 --to notebook --execute --inplace ",basename(ipynb.files[p])))
  
  # Take the freshly ran .ipynb file (with all code chunk outputs) and 
  # convert to the desired formats
  system(paste0("cd ",dirname(ipynb.files[p]),
                "; jupyter nbconvert --to html ",basename(ipynb.files[p]),
                "; jupyter nbconvert --to script ",basename(ipynb.files[p]),
                "; jupyter nbconvert --to markdown ",basename(ipynb.files[p])))

  # ClearOutputPreprocessor will clear all chunk output and restart the kernel - leaving a blank Notebook ready to run
  # This is desirable for the notebook that people download, but not for the markdown that is shown on the website
  # So we clear it out before saving the file and uploading to GitHub
  system(paste0("cd ",dirname(ipynb.files[p]),
  "; jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace ",basename(ipynb.files[p])))
  
  
  ## After processing into different formats, 
  ## we must re-point URLs to figures in .md file.
  ## This changes the figure links from relative filepaths to 
  ## full URLs for the imges on GitHub
  
  # Find Markdown-style embedded figures with a bunch of escape characters "\\"
  png.pattern="\\!\\[png\\]\\("
  
  # Extract filepath from "/tutorials/" to the tutorial directory
  # see 'pattern' defined at the top of the script
  URL.prefix=sub(pattern,"\\1",dirname(ipynb.files[p]))
  # And append to Markdown figure embed prefix and GitHub Raw URL prefix
  URL.prefix=paste0("![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/",URL.prefix,"/")
  
  #Point to Markdown file instead of Jupyter Notebook file
  MD.name=sub(".ipynb",".md",ipynb.files[p])
  
  # Standard find/replace routine
  fileConn <- file(MD.name)
  fl <- readLines(fileConn)
  
  fl2=sub(png.pattern,URL.prefix,fl)

  # write modified .md file out
  writeLines(fl2, fileConn)
  close(fileConn)    
  
}

