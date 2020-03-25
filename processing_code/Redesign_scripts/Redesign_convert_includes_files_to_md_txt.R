## convert _includes files to markdown-ready language

# Change:
# Here, make two lists, the sub_patterns to search for, and the sub_replacement to replace with
# <h3> to ###
# references to relative links
sub_patterns=c("<h2>","<h3>","<h4>", "href=\"/")
sub_replacement=c("##","###","####", "href=\"https://www.neonscience.org/")


## Remove:
# For this, we will make a list of HTML elements to remove, then loop through it 

remove_list=c("</h2>","</h3>","</h4>","<p>","</p>")


html.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/processing_code/_includes/dataSubsets",
                        pattern="\\.html$", full.names = TRUE, recursive = TRUE)
