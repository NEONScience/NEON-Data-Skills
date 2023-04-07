# Instructions for using this script:
#
# Run each line of this script in R to install the needed packages. If 
#    the installation process results in errors, try to resolve them. 
#    The most common errors are usually related to packages that these 
#    packages depend on. If you see error messages referencing other 
#    packages, install those independently, then attempt the original 
#    installation again.
# Once you've installed these four packages successfully, go to the 
#    lens_verify.R script and follow the instructions to test 
#    the installations.
# If you encounter any problems, return to this script to resolve.

install.packages("neonUtilities")
install.packages("neonOS")
install.packages("raster")
install.packages("devtools")
devtools::install_github("NEONScience/NEON-geolocation/geoNEON")
