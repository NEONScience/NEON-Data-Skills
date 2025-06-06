# redesign move existing .Rmd and .md files to their new homes using the 
# key filepath CSV file

master_dir <- "~/Git/dev-aten/NEON-Data-Skills"
setwd("~/Git/dev-aten/NEON-Data-Skills/processing_code/Redesign_scripts/")

key <- read.csv("redesign-tutorial-filepaths.csv")

# Find all .md files
Rmd.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/old-tutorials/tutorials",
                       pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)

Rmd.files.to.move <- Rmd.files[basename(Rmd.files) %in% gsub("\\.md","\\.Rmd",key$lesson)]

#not_Rmd.files.to.move <- Rmd.files[!basename(Rmd.files) %in% gsub("\\.md","\\.Rmd",key$lesson)]

for(i in 1:length(key$lesson)){
  
  file <- Rmd.files.to.move[basename(Rmd.files.to.move) %in% gsub("\\.md","\\.Rmd",key$lesson)[i]]
  
  if(length(file)>0){
  
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
    file.copy("~/Git/dev-aten/NEON-Data-Skills/processing_code/NOT_VERIFIED.txt", dn)
    
    print("File copied and flagged for review")
    
    if(file.exists(gsub("\\.Rmd","\\.md",file))){
      unlink(file.path(dn,gsub("\\.Rmd","\\.md",basename(file))))
      print(".md deleted - must be remade once .Rmd is updated")
    }
  }

  }
  
}