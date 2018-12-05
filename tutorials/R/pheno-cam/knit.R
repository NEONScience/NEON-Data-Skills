library(knitr)


setwd('~/Projects/NEON-Data-Skills/tutorials/R/pheno-cam/')

rmd_files <- c(
  'detecting-foggy-phenocam-images.Rmd',
  'extracting-timeseries-with-xroi.Rmd',
  'getting-started-phenocamapi.Rmd'
)

for(ii in 1:length(rmd_files)){
  knit(rmd_files[ii])
  purl(rmd_files[ii])
}

file.copy(gsub('.Rmd', '.R', rmd_files), 
          to = '~/Projects/NEON-Data-Skills/code/PhenoCam//', overwrite = TRUE)
