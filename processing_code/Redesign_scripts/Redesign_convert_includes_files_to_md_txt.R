## convert _includes files to markdown-ready language

# Change:
# Here, make two lists, the sub_patterns to search for, and the sub_replacement to replace with
# <h3> to ###
# references to relative links
sub_patterns=c("<b>","</b>","<h2>","<h3>","<h4>", "href=\"/")
sub_replacement=c("**","**","##","###","####", "href=\"https://www.neonscience.org/")


## Remove:
# For this, we will make a list of HTML elements to remove, then loop through it 

remove_list=c("</h2>","</h3>","</h4>","<p>","</p>")


html.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/processing_code/_includes/old-tutorialSeries",
                        pattern="\\.html$", full.names = TRUE, recursive = TRUE)

for (file in html.files){
  
  # open .md (or .Rmd) file
  fileConn <- file(file)
  fl.md <- readLines(fileConn)
  
  # replace patterns that need replacing
  for(i in 1:length(sub_patterns)){
    fl.md <- gsub(sub_patterns[i], sub_replacement[i], fl.md, fixed=TRUE)
  }
  
  # remove patterns that need removing
  for(j in 1:length(remove_list)){
    fl.md <- gsub(remove_list[j], "", fl.md, fixed=TRUE)
  }
  
  # write modified .txt file out
  fn=basename(file)
  fn=gsub(".html",".txt",fn,fixed=TRUE)
  fn=paste0("/Users/olearyd/Git/dev-aten/NEON-Data-Skills/processing_code/_includes/tutorialSeries/",fn)
  writeLines(fl.md, fn)
  close(fileConn)      
  
} #END file