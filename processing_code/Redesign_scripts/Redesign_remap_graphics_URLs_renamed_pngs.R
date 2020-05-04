## Webstie redesign script to convert all graphics URLs to their new location

## This script is SPECIFICALLY FOR THE .PNG FILES THAT HAVE BEEN RENAMED
# Renamed graphics – I tried to minimize this but if the name was really not informative I changed it. This should be captured in the commits but also added here.  
# raster1.png -> raster_multiple_resolutions.png
# raster2.png -> raster_streched_extent.png
# bluelight.png -> bluelight_EMSpectrum.png
# intensitySlider.png -> plasio_intensitySlider.png
# intensityBlending.png -> plasio_intensityBlending.png
# Colorization.png -> plasio_Colorization.png
# Colorization2.png -> plasio_Colorization2.png

before <- c("raster1.png","raster2.png","bluelight.png",
            "intensitySlider.png","intensityBlending.png",
            "Colorization.png","Colorication2.png")

after <- c("raster_multiple_resolutions.png", "raster_streched_extent.png",
           "bluelight_EMSpectrum.png", "plasio_intensitySlider.png",
           "plasio_intensityBlending.png","plasio_Colorization.png",
           "plasio_Colorization2.png")

## read in changes (remap_key) and parse out the setion of the URL that is actually relevant
# Turn this into a before,after paired list

graphics.files <- list.files("~/Git/dev-aten/NEON-Data-Skills/graphics", 
                             full.names = F, recursive = T)
# Remove all paths that are rfigs
graphics.files <- graphics.files[!grepl("rfigs/", x = graphics.files, fixed = T)]

# Remove all paths that are pyfigs
graphics.files <- graphics.files[!grepl("py-figs/", x = graphics.files, fixed = T)]


# Find all files to change
Rmd.files <- list.files("~/Git/dev-aten/NEON-Data-Skills",
                        
                        pattern="\\.Rmd$", full.names = TRUE, recursive = TRUE)
md.files <- list.files("~/Git/dev-aten/NEON-Data-Skills",
                       pattern="\\.md$", full.names = TRUE, recursive = TRUE)
html.files <- list.files("~/Git/dev-aten/NEON-Data-Skills",
                         pattern="\\.html$", full.names = TRUE, recursive = TRUE)
ipynb.files <- list.files("~/Git/dev-aten/NEON-Data-Skills",
                          pattern="\\.ipynb$", full.names = TRUE, recursive = TRUE)

all.files=c(Rmd.files, md.files, html.files, ipynb.files)


for (file in all.files){
  print(file)
  # open .md (or .Rmd) file
  fileConn <- file(file)
  fl <- readLines(fileConn)
  
  for(i in 1:length(before)){

    # 1) grepl to get only the graphics.files with after[i]  
    
    gf.2.change <- graphics.files[grepl(after[i], x = graphics.files, fixed = T)]
    
    
    # 2) Find lines with "/graphics/.../before[i]"

    # 3) replace "/graphics/.../before[i]" with result of 1.
    
    p=paste0("/graphics/\\S+/",before[i])
    rep_text=paste0("/graphics/",gf.2.change)
    fl=gsub(p,rep_text,fl) # Replace pattern "p" with replacement text "rep_text"
    
  }
  
  # write modified .md file out
  writeLines(fl, fileConn)
  close(fileConn)      
  
} #END file
