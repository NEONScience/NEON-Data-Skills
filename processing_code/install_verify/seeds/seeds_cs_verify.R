# Instructions for using this script:
#
# The code in seeds_cs_install.R must be run first. This script verifies 
#    that the installations were successful.
#
# Once you've installed the packages using the install script, open this 
#    script in RStudio and click "Source".
# If the output line reads: "Hooray, all tests passed!" then you are done! 
#    Everything installed successfully.
# If you don't get the message "Hooray, all tests passed!" then something 
#    has not installed correctly. There should be messages indicating which 
#    package(s) encountered problems. Try to install them again, using the 
#    code in the seeds_cs_install.R script. You may also need to re-install 
#    packages they depend on - if this is the problem, there will be error 
#    messages in the package installation output indicating specific package 
#    dependencies.
# Once you believe everything has installed correctly, click "Source" again 
#    on this script, or just run the final line (line 80).
# If you don't get the "Hooray, all tests passed!" message, repeat the steps 
#    above, and contact the workshop instructors if you get stuck.

workshop.readiness <- function() {
  
  # check that packages have been loaded
  pkgs <- c("curl", 
            "raster", 
            "neonUtilities", 
            "geoNEON")
  pkg.fail <- numeric()
  for(i in 1:length(pkgs)) {
    t <- try(requireNamespace(pkgs[i]), silent=TRUE)
    if(class(t)=="try-error") {
      pkg.fail <- c(pkg.fail, i)
    }
  }
  if(length(pkg.fail)>0) {
    message(paste("The following packages are not installed:\n", 
                  paste(pkgs[pkg.fail], collapse="\n"), 
                  "\nInstall necessary packages using install.packages(), unless otherwise specified below.", 
                  sep=""))
  }
  # packages with special install procedures
  if("geoNEON" %in% pkgs[pkg.fail]) {
    message('Install package geoNEON using devtools::install_github("NEONScience/NEON-geolocation/geoNEON")')
  }

  # check for internet
  if(!curl::has_internet()) {
    stop("Internet connection not found. Check internet access.")
  }
  
  # try to use neonUtilities
  bird <- try(capture.output(neonUtilities::loadByProduct(dpID="DP1.10003.001", site="WREF", 
                                       startdate="2019-01", enddate="2019-12",
                                       check.size=F), file=NULL), silent=TRUE)
  if(class(bird)=="try-error") {
    message("Download and read of NEON data failed. Check neonUtilities installation, internet connection, and NEON API status.")
  }
  
  # try to use raster
  chm <- try(raster::raster("https://data.neonscience.org/api/v0/data/DP3.30015.001/ARIK/2020-06/NEON_D10_ARIK_DP3_705000_4395000_CHM.tif"), 
             silent=TRUE)
  if(class(chm)=="try-error") {
    message("Read of NEON AOP tile using raster package failed. Check raster installation, internet connection, and NEON API status.")
  }
  
  # try to use geoNEON
  arik <- try(geoNEON::getLocBySite("ARIK", type="site"), silent=TRUE)
  if(class(arik)=="try-error") {
    message("Location data access via geoNEON package failed. Check geoNEON installation, internet connection, and NEON API status.")
  }
  
  # victory message if no errors
  if(length(pkg.fail)==0 & all(c(class(bird), class(chm), class(arik))!="try-error")) {
    message("Hooray, all tests passed!")
  }
  
}

workshop.readiness()
