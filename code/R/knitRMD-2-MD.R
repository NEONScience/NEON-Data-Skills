#!/usr/bin/env Rscript

input <- commandArgs(trailingOnly = TRUE)
KnitPost <- function(input, base.url = "/") {
  require(knitr)
  opts_knit$set(base.url = base.url)
  fig.path <- paste0("_posts/figs/", sub(".Rmd$", "", basename(input)), "/")
  opts_chunk$set(fig.path = fig.path)
  opts_chunk$set(fig.cap = "center")
  render_jekyll()
  print(paste0("/_posts/", sub(".Rmd$", "", basename(input)), ".md"))
  knit(input, output = paste0("/_posts/", sub(".Rmd$", "", basename(input)), ".md"), envir = parent.frame())
}

KnitPost(input)

#http://www.jonzelner.net/jekyll/knitr/r/2014/07/02/autogen-knitr/

file <- "2015-05-21-R-Timeseries-Hierarchical-Data-Format-HDF5.Rmd"
#file <- "testThis.Rmd"

require(knitr)
base.url="{{ site.baseurl }}/"
input=file
opts_knit$set(base.url = base.url)
fig.path <- paste0("images/rfigs/", sub(".Rmd$", "", basename(input)), "/")
opts_chunk$set(fig.path = fig.path)
opts_chunk$set(fig.cap = " ")
#render_jekyll()
render_markdown(strict = TRUE)
print(paste0("/_posts/", sub(".Rmd$", "", basename(input)), ".md"))
knit(input, output = paste0("_posts/", sub(".Rmd$", "", basename(input)), ".md"), envir = parent.frame())
