# To modify image file paths in .md files made from .ipynb files

# Once file has been converted, take folder of image files and move it to NEON-Data-Skills/images
# Move .md file into NEON-Data-Skills/tutorials

# file path to .md file
fl <- "/Users/clunch/GitHub/NEON-Data-Skills/tutorials/Python/neonUtilities/neonUtilitiesPython.md"

# file path to image file folder
# this should not need to change for different tutorials
img.fl <- "[ ]({{ site.baseurl }}/images/"

# open .md file
fileConn <- file(fl)
fl.md <- readLines(fileConn)

# delete leading space
#fl.md <- fl.md[-1]

# replace [png] with file path to images
fl.mod <- gsub("[png](", img.fl, fl.md, fixed=TRUE)

# write modified .md file out
writeLines(fl.mod, fileConn)
close(fileConn)      

