# redesign move existing .Rmd and .md files to their new homes using the 
# key filepath CSV file

master_dir <- "~/Git/dev-aten/NEON-Data-Skills"
setwd("~/Git/dev-aten/NEON-Data-Skills/processing_code/Redesign_scripts/")

key <- read.csv("redesign-tutorial-filepaths.csv")

# Find all .md files
ipynb.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/code/Python",
                       pattern="\\.ipynb$", full.names = TRUE, recursive = TRUE)

ipynb.files.to.move <- ipynb.files[basename(ipynb.files) %in% gsub("\\.md","\\.ipynb",key$lesson)]

for(i in 1:length(key$lesson)){

file <- ipynb.files.to.move[basename(ipynb.files.to.move) %in% gsub("\\.md","\\.ipynb",key$lesson)[i]]

dn <- file.path(master_dir, key$root[i], key$language[i], key$theme[i], key$group[i], gsub("\\.md","",(as.character(key$lesson[i]))))

print(file)

if (file.exists(dn)){
  #print("Tutorial Dir Exists! ")
} else {
  #create image directory structure
  dir.create(dn, recursive = TRUE)
  #print("Tutorial directory created!")
}

if (dir.exists(dn)){
  # copy .md over
  file.copy(file, dn, recursive=FALSE, overwrite = TRUE)
  # copy over NOT_CHECKED.txt
  #file.copy("~/Git/dev-aten/NEON-Data-Skills/processing_code/NOT_VERIFIED.txt", dn)
  
  print("File copied and flagged for review")
}

}
