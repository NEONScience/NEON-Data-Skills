## ----loadStuff, eval=FALSE, comment=NA---------------------------------------------------------------------------

# install neonUtilities - can skip if already installed
install.packages("neonUtilities")

# load neonUtilities
library(neonUtilities)



## ----getCFC, eval=FALSE, comment=NA------------------------------------------------------------------------------

foliar <- loadByProduct(dpID="DP1.10026.001", site="all", 
                        package="expanded", check.size=F,
                        token="PASTE YOUR TOKEN HERE")



## ----getAOP, eval=FALSE, comment=NA------------------------------------------------------------------------------

chm <- byTileAOP(dpID="DP3.30015.001", site="WREF", 
                 year=2017, check.size=F,
                 easting=c(571000,578000), 
                 northing=c(5079000,5080000), 
                 savepath="/data",
                 token="PASTE YOUR TOKEN HERE")



## ----useTokenName, eval=FALSE, comment=NA------------------------------------------------------------------------

NEON_TOKEN <- "PASTE YOUR TOKEN HERE"

foliar <- loadByProduct(dpID="DP1.10026.001", site="all", 
                        package="expanded", check.size=F,
                        token=NEON_TOKEN)



## ----scriptToSource, eval=FALSE, comment=NA----------------------------------------------------------------------

NEON_TOKEN <- "PASTE YOUR TOKEN HERE"



## ----source, eval=FALSE, comment=NA------------------------------------------------------------------------------

source("/data/neon_token_source.R")



## ----getdir, eval=FALSE, comment=NA------------------------------------------------------------------------------

# For Windows:
Sys.getenv("R_USER")

# For Mac/Linux:
Sys.getenv("HOME")



## ----Renviron, eval=FALSE, comment=NA----------------------------------------------------------------------------

NEON_TOKEN=PASTE YOUR TOKEN HERE



## ----useEnvtToken, eval=FALSE, comment=NA------------------------------------------------------------------------

foliar <- loadByProduct(dpID="DP1.10026.001", site="all", 
                        package="expanded", check.size=F,
                        token=Sys.getenv("NEON_TOKEN"))


