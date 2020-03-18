## script to evaluate how many .md files do not have an associated .Rmd file

# Inputs - Where the git repo is on your computer
#gitRepoPath <-"~/Git/dev-aten/NEON-Data-Skills"

#gitRepoPath <- path.expand(gitRepoPath) # expand tilde to later remove this root dir from longer filepaths


# find all .Rmd files
rmd.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/old-tutorials/tutorials",
                        pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)
# Find all .md files
md.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/old-tutorials/tutorials",
                        pattern="\\.md$", full.names = TRUE, recursive = TRUE)

setwd("~/Git/dev-aten/NEON-Data-Skills/processing_code/")
md.files2=md.files
md.files2=gsub("/Users/olearyd/Git/dev-aten/NEON-Data-Skills/old-tutorials/tutorials","",md.files2)
write.table(md.files2, file="md-file-list.txt", quote = FALSE)


# Remove any .md files from the list if they contain "/Python/" in their filepath
# https://stackoverflow.com/questions/40885360/remove-entries-from-string-vector-containing-specific-characters-in-r/40885527
md.files <- md.files[!grepl(paste0("/Python/", collapse = "|"), md.files)]

rmd.files[1]
md.files[14]

rmd.files <- gsub("\\.Rmd","",rmd.files)
md.files <- gsub("\\.md","",md.files)

unpaired.md <- md.files[!md.files %in% rmd.files]



