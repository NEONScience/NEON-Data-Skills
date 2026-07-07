## ----set-up-env, eval=F-------------------------------------------------------------------------------------
# 
# install.packages("neonUtilities")
# install.packages("neonOS")
# install.packages("aqp")
# install.packages("cluster")
# install.packages("sharpshootR")
# install.packages("dplyr")
# install.packages("Ternary")
# 


## ----load-packages, message=FALSE, warning=FALSE------------------------------------------------------------

# Load required packages
library(neonUtilities)
library(neonOS)
library(aqp)
library(cluster)
library(sharpshootR)
library(dplyr)
library(Ternary)

token <- Sys.getenv("NEON_TOKEN")



## ----download-data, results='hide', message=FALSE-----------------------------------------------------------

MP <- loadByProduct(dpID="DP1.00096.001", 
                    check.size = F,
                    token=token)

list2env(MP, .GlobalEnv)



## ----join-bgc-----------------------------------------------------------------------------------------------

S <- joinTableNEON(mgp_perhorizon,
                   mgp_perbiogeosample)

S <- arrange(S, siteID, horizonTopDepth)



## ----site-labels--------------------------------------------------------------------------------------------

## combine 'domainID' and 'siteID' into a new label variable
S$siteLabel <- sprintf("%s-%s", S$domainID, S$siteID)



## ----RGB-colors---------------------------------------------------------------------------------------------

# duplicate physical property variables
S$r <- S$sandTotal # Sand is Red 'r'
S$g <- S$siltTotal # Silt is Green 'g'
S$b <- S$clayTotal # Clay is Blue 'b'

# set NA values to 100 (white)
S$r[is.na(S$r)] <- 100
S$g[is.na(S$g)] <- 100
S$b[is.na(S$b)] <- 100

# normalize values to 1 and convert to vector of colors using 'rgb()' function
S$textureColor <- rgb(red=S$r/100, 
                      green=S$g/100, 
                      blue=S$b/100, 
                      alpha=1, 
                      maxColorValue = 1)



## ----make-SPC-object----------------------------------------------------------------------------------------

depths(S) <- siteLabel ~ horizonTopDepth + horizonBottomDepth



## ----move-site-attributes-----------------------------------------------------------------------------------

site(S) <- ~ siteID + nrcsDescriptionID



## ----plot-SERC----------------------------------------------------------------------------------------------

# set plot margins
par(mar=c(1,0,3,15), mfrow=c(1,1), xpd=NA)

# Plot SERC clay profile
plotSPC(subset(S, siteID=="SERC"), 
        name='horizonName.x', label='siteLabel', 
        color='clayTotal', col.label='Clay Content (%)',
        col.palette=viridis::viridis(10), 
        cex.names=1, width = 0.1, 
        depth.axis = list(style="traditional",
                          line=6,
                          cex=1), 
        col.legend.cex = 1.5, n.legend=6, 
        x.idx.offset = 0, n=.88)




## ----plot-WREF----------------------------------------------------------------------------------------------

par(mar=c(1,0,3,15), mfrow=c(1,1), xpd=NA)

plotSPC(subset(S, siteID=="WREF"),  
        name='horizonName.x', label='siteLabel', 
        color='pMjelm', 
        col.label='Phosphorus (mg/Kg)',
        col.palette=viridis::viridis(10), 
        cex.names=1, width = 0.1, 
        depth.axis = list(style="traditional",
                          line=6,
                          cex=1), 
        col.legend.cex = 1.5, n.legend=4, 
        x.idx.offset = 0, n=.88)



## ----plot-three---------------------------------------------------------------------------------------------

par(mar=c(0,2,3,2.5), mfrow=c(1,1), xpd=NA)

plotSPC(subset(S, siteID %in% c('WREF', 'JORN', 'GUAN')),
        name='horizonName.x', label='siteLabel', 
        color='sandTotal', 
        col.label='Percent Sand (%)',
        col.palette=viridis::viridis(10),
        n.legend = 5)



## ----ternary-plot-------------------------------------------------------------------------------------------

par(mfrow=c(1, 1), mar=rep(.3, 4))

TernaryPlot(alab="% Sand \u2192", blab="% Silt \u2192", clab="\u2190 % Clay ",
            lab.col=c('red', 'green3', 'blue'),
            point='up', lab.cex=1.5, grid.minor.lines=1, axis.cex=1.5,
            grid.lty='solid', col=rgb(0.9, 0.9, 0.9), grid.col='white', 
            axis.col=rgb(0.6, 0.6, 0.6), ticks.col=rgb(0.6, 0.6, 0.6),
            padding=0.08)

cols <- TernaryPointValues(rgb)

ColourTernary(cols, spectrum = NULL, resolution=45)



## ----plot-physical-texture----------------------------------------------------------------------------------

par(mar=c(0,2,3,2.5), mfrow=c(1,1), xpd=NA)

plotSPC(subset(S, siteID %in% c('WREF', 'JORN', 'GUAN')),
        name='horizonName.x', label='siteLabel', 
        color='textureColor')



## ----cluster-texture----------------------------------------------------------------------------------------

# subset to meet quality threshold
S.sub <- HzDepthLogicSubset(S)

# classify soil profiles
d <- NCSP(S.sub, vars=c('clayTotal',
                        'sandTotal', 
                        'siltTotal'), 
          k=0)

# vizualize dissimilarity matrix via divisive hierarchical clustering
d.diana <- diana(d)

# Plot the resulting dendrogram
plotProfileDendrogram(S.sub, d.diana, scaling.factor = .6, 
                      y.offset = 2, width=0.25, cex.names=.4, 
                      name='horizonName.x', label='siteLabel', 
                      color='textureColor')



## ----plot-texture-clusters----------------------------------------------------------------------------------

# Check and set working directory as needed.
getwd()
# setwd("enter path to save PDF here")

# Open 'pdf' graphic device. Define file name and large dimensions
pdf(file="NEON_Soils_Texture_Color_Clusters.pdf", width=24, height=10)

# set plot margins and generate plot
par(mar=c(12,2,10,1), mfrow=c(1,1), xpd=NA)
plotProfileDendrogram(S.sub, d.diana, scaling.factor = .6, 
                      y.offset = 2, width=0.25, cex.names=.4, 
                      name='horizonName', label='siteLabel',
                      color='textureColor')

# Close and save the device
dev.off()



## ----cluster-nutrients--------------------------------------------------------------------------------------

## Cluster as above, but for nutrient variables
d.nutrients <- NCSP(S.sub, 
                    vars=c('nitrogenTot',
                           'carbonTot', 
                           'sulfurTot'),
                    k=0)

# vizualize dissimilarity matrix via divisive hierarchical clustering
d.diana.nutrients <- diana(d.nutrients)



## ----plot-nutrient-clusters---------------------------------------------------------------------------------

# Open 'pdf' graphic device. Define file name and large dimensions
pdf(file="NEON_Soils_Nutrient_Clusters.pdf", width=24, height=14)

# Set plot margins
par(mar=c(8,2,5,1), mfrow=c(3,1), xpd=NA)

# Make plots for each nutrient of interest
plotProfileDendrogram(S.sub, d.diana.nutrients, scaling.factor = .6, 
                      y.offset = 2, width=0.25, name='horizonName', 
                      label='siteLabel', color='nitrogenTot',
                      col.label='Total Nitrogen (g/Kg)', 
                      col.legend.cex = 1.2, n.legend=6, 
                      col.palette=viridis::viridis(8))
plotProfileDendrogram(S.sub, d.diana.nutrients, scaling.factor = .6, 
                      y.offset = 2, width=0.25, name='horizonName', 
                      label='siteLabel', color='carbonTot',
                      col.label='Total Carbon (g/Kg)', 
                      col.legend.cex = 1.2, n.legend=6, 
                      col.palette=viridis::viridis(8))
plotProfileDendrogram(S.sub, d.diana.nutrients, scaling.factor = .6, 
                      y.offset = 2, width=0.25, name='horizonName', 
                      label='siteLabel', color='sulfurTot',
                      col.label='Total Sulfur (g/Kg)', 
                      col.legend.cex = 1.2, n.legend=6, 
                      col.palette=viridis::viridis(8))

# Close and save the device
dev.off()


