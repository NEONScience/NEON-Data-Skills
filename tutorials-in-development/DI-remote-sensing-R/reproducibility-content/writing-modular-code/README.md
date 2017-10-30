Writing functions to make code modular
================

This set of `.Rmd` and `.R` files were used to teach making code more
modular and reusable. It was taught as part of a session at the [NEON
Data Institute
2016](http://neon-workwithdata.github.io/neon-data-institute-2016/) by
[Naupaka Zimmerman](http://github.com/naupaka). The files document three
steps of making code more modular. They are:

1. A script that makes very minimal use of functions: `CHM_analysis.Rmd`
1. A script that pulls much of the plotting code into functions, but
   keeps them in the same file: `CHM_Analysis_partially_functionalized.Rmd`
1. A version that pull the function out of the `.Rmd` and into
   a seperate file (`scripts/functions.R`) that is then called with
   `source()`: `CHM_Analysis_functionalized.Rmd`.

These script were written to read in a GeoTIFF formatted raster of
canopy heights (`TEAK_lidarCHM.tif`), although the path in the script
will have to be adjusted to match the user's local directory structure.

These files were written by [Naupaka Zimmerman](http://github.com/naupaka) based on code written by Leah Wasser and Megan Jones, [available here](http://neon-workwithdata.github.io/neon-data-institute-2016/R/classify-by-threshold-R/). 

