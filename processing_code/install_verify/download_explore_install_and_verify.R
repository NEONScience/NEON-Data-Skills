# Instructions for using this script:
#
# Run all lines of code in the script. If you're using RStudio, the easiest
#    way to do this is to open this file in RStudio and click the "Source" 
#    button.
#
# If the final output line reads: "Hooray, all tests passed!" then you are done! 
#    Everything installed successfully.
# If you don't get the message "Hooray, all tests passed!" then something 
#    has not installed correctly. There should be messages indicating which 
#    package(s) encountered problems. Try to install them again, using any 
#    suggestions made in the messages. You may also need to re-install 
#    packages they depend on - if this is the problem, there will be error 
#    messages in the package installation output indicating specific package 
#    dependencies.
# Once you believe everything has installed correctly, re-run the final line 
#    (line 87).
# If you don't get the "Hooray, all tests passed!" message, repeat the steps 
#    above, and contact the workshop instructors if you get stuck.

install.packages("neonUtilities", quiet=T)
install.packages("neonOS", quiet=T)
install.packages("terra", quiet=T)

workshop.readiness <- function() {
  
  # check that packages have been loaded
  pkgs <- c("curl", 
            "terra", 
            "neonUtilities", 
            "neonOS")
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
                  "\nInstall necessary packages using install.packages()", 
                  sep=""))
  }

  # check for internet
  if(!curl::has_internet()) {
    stop("Internet connection not found. Check internet access, and check firewall and security settings to ensure R is allowed to access the internet.")
  }
  
  # try to use neonUtilities
  bird <- try(capture.output(neonUtilities::loadByProduct(dpID="DP1.10003.001", site="WREF", 
                                       startdate="2019-01", enddate="2019-12",
                                       check.size=F), file=NULL), silent=TRUE)
  if(inherits(bird, "try-error")) {
    message("Download and read of NEON data failed. Check neonUtilities installation, internet connection, and NEON API status.")
  }
  
  # try to use neonOS
  if(inherits(bird, "try-error")) {
    message("Because download and read of NEON data failed, neonOS could not be checked. Resolve neonUtilities installation first, then check neonOS installation.")
  } else {
    temp <- capture.output(bird <- neonUtilities::loadByProduct(dpID="DP1.10003.001", site="WREF", 
                                         startdate="2019-01", enddate="2019-12",
                                         check.size=F), file=paste(tempdir(), "/tempout.txt", sep=""))
    birdtab <- try(capture.output(neonOS::joinTableNEON(bird$brd_perpoint, bird$brd_countdata,
                                                        "brd_perpoint", "brd_countdata")))
    if(inherits(birdtab, "try-error")) {
      message("Join of NEON tables failed. Check neonOS installation.")
    }
  }
  
  # try to read raster with terra
  chm <- try(terra::rast("https://data.neonscience.org/api/v0/data/DP3.30015.001/ARIK/2020-06/NEON_D10_ARIK_DP3_705000_4395000_CHM.tif"), 
             silent=TRUE)
  if(inherits(chm, "try-error")) {
    message("Read of NEON AOP tile using terra package failed. Check terra installation, internet connection, and NEON API status.")
  }
  
  # victory message if no errors
  if(length(pkg.fail)==0 & all(c(class(bird), class(chm), class(birdtab))!="try-error")) {
    message("Hooray, all tests passed!")
  }
  
}

workshop.readiness()
