# redesign move existing .Rmd and .md files to their new homes using the 
# key filepath CSV file

master_dir <- "~/Git/dev-aten/NEON-Data-Skills"
setwd("~/Git/dev-aten/NEON-Data-Skills/processing_code/Redesign_scripts/")

key <- read.csv("redesign-tutorial-filepaths.csv")

# Find all .md files
md.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/old-tutorials/tutorials",
                       pattern="\\.md$", full.names = TRUE, recursive = TRUE)

md.files.to.move <- md.files[basename(md.files) %in% key$lesson]

for(i in 1:length(md.files.to.move)){

file <- md.files.to.move[basename(md.files.to.move) %in% key$lesson[i]]

dn <- file.path(master_dir, key$root[i], key$language[i], key$theme[i], key$group[i])

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
  file.copy("~/Git/dev-aten/NEON-Data-Skills/processing_code/NOT_VERIFIED.txt", dn)
  
  print("File copied and flagged for review")
}

}
