# Instructions for using this script:
# The first time you attempt to use this script, you can simply open it in 
#    RStudio and click "Source"
# There are likely to be many lines of output, but if the final output line 
#    reads: "Hooray, all tests passed!" then you are done! Everything 
#    installed successfully.
# If you don't get the message "Hooray, all tests passed!" then something 
#    has not installed correctly. There should be messages indicating which 
#    package(s) encountered problems. Try to install them again, using the 
#    first four lines of code in this script. You may also need to re-install 
#    packages they depend on - if this is the problem, there will be error 
#    messages in the package installation output indicating specific package 
#    dependencies.
# Once you believe everything has installed correctly, don't click "Source" 
#    again; instead, run only the final line of this script (line 82).
# If you don't get the "Hooray, all tests passed!" message, repeat the steps 
#    above, and contact the workshop instructors if you get stuck.

install.packages("neonUtilities")
install.packages("raster")
install.packages("devtools")
devtools::install_github("NEONScience/NEON-geolocation/geoNEON")

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
