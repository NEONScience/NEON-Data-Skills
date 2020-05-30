## New code to develop Soils tutorials for NEON data
## Donal O'Leary 5/29/2020


## Based on:
#http://ncss-tech.github.io/AQP/soilDB/soil-series-query-functions.html
# and
#https://ncss-tech.github.io/AQP/aqp/aqp-intro.html#3_accessing,_setting,_and_replacing_data


## Soil Megapits
# Videos?
# Blog Post about Soils: https://www.neonscience.org/observatory/observatory-blog/digging-dirt-soil-organic-matter
# Link to Biogeochemical Cycling: https://www.neonscience.org/data-collection/biogeochemical
# Link to Megapit soil archive page: https://www.neonscience.org/data/samples-specimens/megapit-soil-archive
# Link to "data collection: soils and sediments": https://www.neonscience.org/data-collection/soils-sediments
# Link to technical document that thoroughly describes the Megapit - good photos to reference!: https://data.neonscience.org/api/v0/documents/NEON.DOC.001307vC



library(neonUtilities)
library(soilDB)
library(aqp)
library(cluster)
library(sharpshootR)
library(dplyr)

# Links to data product IDS
# Soil physical properties (Megapit) DP1.00096.001

MP <- loadByProduct(dpID = "DP1.00096.001", check.size = F)

# Unlist to environment - see download/explore tutorial for description
list2env(MP, .GlobalEnv)

MC <- loadByProduct(dpID = "DP1.00097.001", check.size = F)
list2env(MC, .GlobalEnv)

# Now that they have been unlisted, we can get rid of the original lBP call
rm(MP)
rm(MC)

## Contents of each download
# each data product has the same _perhorizon, _permegapit, and _perarchivesample tables
# Different variables available in the _perbiogeosample tables

# Compare using setdiff() https://stackoverflow.com/questions/1837968/how-to-tell-what-is-in-one-vector-and-not-another

# setdiff(mgc_perbiogeosample$horizonName, mgp_perbiogeosample$horizonName)
# setdiff(mgp_perbiogeosample$horizonName, mgc_perbiogeosample$horizonName)
# 
# setdiff(mgc_perbiogeosample$horizonID, mgp_perbiogeosample$horizonID)
# setdiff(mgp_perbiogeosample$horizonID, mgc_perbiogeosample$horizonID)
# 
# setdiff(mgc_perbiogeosample$siteID, mgp_perbiogeosample$siteID)
# setdiff(mgp_perbiogeosample$siteID, mgc_perbiogeosample$siteID)
# 
# setdiff(mgc_perbiogeosample$biogeoID, mgp_perbiogeosample$biogeoID)
# setdiff(mgp_perbiogeosample$biogeoID, mgc_perbiogeosample$biogeoID)
# 
# all.equal( mgc_perbiogeosample$biogeoID, mgp_perbiogeosample$biogeoID)

# _perhorizon is the common table that defines the horizon boundary depths
# both the physical (mgp) and chemical (mgc) _perbiogeosample tables have information of interest for the analysis of the soils data
# we will join all three tables based on the common 'horizonID' column 
# we will also join based on a few other common columns to avoid duplicate rows (e.g., 'siteID.x' and 'siteID.y')

# Make a new caopy of the _perhorizon table to begin joining variables with horizon boundary depths
S =mgp_perhorizon

# let's make a new label by joining the domainID and the siteID (these will be nice for labeling the plots later)
S$siteLabel=paste(S$domainID, S$siteID, sep="-")

# A few added rows because of 'NA's in the Guanica site data 
##### ADD OTHER VARIABLES HERE?
B=full_join(mgp_perbiogeosample, mgc_perbiogeosample, by=c('horizonID','biogeoID','siteID','horizonName'))

# Select only 'Regular' samples (not audit)
B=B[B$biogeoSampleType.x=="Regular",]

# Remove NA rows that were introduced in the join
B=B[!is.na(B$biogeoSampleType.x),]


S=left_join(S, B, by=c('horizonID', 'siteID','horizonName'))

S <- arrange(S, siteID, horizonTopDepth)

# See which horizonIDs are unaccounted for 
mgp_perbiogeosample[which(mgp_perbiogeosample$horizonID %in% setdiff(S$horizonID, B$horizonID)),]
mgc_perbiogeosample[which(mgc_perbiogeosample$horizonID %in% setdiff(S$horizonID, B$horizonID)),]

# all of these horizons are missing data for their samples (samples not taken) therefore, they are removed during the drop.NA step above
# These areas will 

#what does setdiff() do? Use this to check which ones dropped
setdiff(S$horizonID, B$horizonID)

# no diffs the other way because it's a left_join()
mgp_perbiogeosample[which(mgp_perbiogeosample$horizonID %in% setdiff(B$horizonID, S$horizonID)),]
mgc_perbiogeosample[which(mgc_perbiogeosample$horizonID %in% setdiff(B$horizonID, S$horizonID)),]

## convert NEON soils dataframe into SoilProfileCollection object
depths(S) <- siteLabel ~ horizonTopDepth + horizonBottomDepth

## First, plot a few profiles
par(mar=c(1,6,3,4), mfrow=c(1,1), xpd=NA)
#par(mar=c(1,3,3,4), xpd=NA)
#plotSPC(x[1, ], cex.names=1)
plotSPC(S[which(S@site=="D02-SERC"),], name='horizonName', label='siteLabel', color='clayTotal', col.label='Clay Content (%)',
        col.palette=viridis::viridis(10), cex.names=1, width = .1, axis.line.offset = -6, col.legend.cex = 1.5, n.legend=6, x.idx.offset = 0, n=.88)

par(mar=c(0,2,3,2.5), mfrow=c(1,1), xpd=NA)
plotSPC(S[1:5,], name='horizonName', label='siteLabel', color='clayTotal', col.label='Clay Content (%)',
        col.palette=viridis::viridis(10), cex.names=1, width = .1, col.legend.cex = 1.5, n.legend=6, axis.line.offset = -2)


# split up plots to get them to all fit
# this may take some fussing on different computers
# par(mar=c(0,0,3,0), mfrow=c(2,1))
# plot(S[1:10], name='horizonName', label='siteLabel', color='clayTotal', col.label='Clay Content (%)')
# plot(S[1:10], name='horizonName', label='siteLabel', color='carbonTot')#, col.label='Clay Content (%)')
#plot(S[24:47], name='horizonName', label='siteLabel', color='clayTotal', col.label='Clay Content (%)', legend=F)


### Clustering Plots

setwd("~/Git/dev-aten/NEON-Data-Skills/tutorials-in-development/Soils/")

## Similarity Clustering
d <- profile_compare(S, vars=c('clayTotal','sandTotal', 'siltTotal'), k=0, max_d=100)

# vizualize dissimilarity matrix via divisive hierarchical clustering
d.diana <- diana(d)

# this function is from the sharpshootR package
# requires some manual adjustments
# Scales well to 10"x22" PDF
# Texture
pdf(file="NEON_Soils_Texture_Clusters.pdf", width=22, height=14)
par(mar=c(8,2,5,1), mfrow=c(3,1), xpd=NA)
plotProfileDendrogram(S, d.diana, scaling.factor = .6, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='sandTotal',col.label='Sand Content (%)', col.legend.cex = 1.2, n.legend=6, col.palette=viridis::viridis(10))
plotProfileDendrogram(S, d.diana, scaling.factor = .6, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='siltTotal',col.label='Silt Content (%)', col.legend.cex = 1.2, n.legend=6, col.palette=viridis::viridis(10))
plotProfileDendrogram(S, d.diana, scaling.factor = .6, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='clayTotal',col.label='Clay Content (%)', col.legend.cex = 1.2, n.legend=6, col.palette=viridis::viridis(10))
dev.off()

## Nutrients
d <- profile_compare(S, vars=c('nitrogenTot','carbonTot', 'sulfurTot'), k=0, max_d=100)
d.diana <- diana(d)

pdf(file="NEON_Soils_Nutrient_Clusters.pdf", width=22, height=14)
par(mar=c(8,2,5,1), mfrow=c(3,1), xpd=NA)
plotProfileDendrogram(S, d.diana, scaling.factor = .6, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='nitrogenTot',col.label='Total Nitrogen (g/Kg)', col.legend.cex = 1.2, n.legend=6, col.palette=viridis::viridis(10))
plotProfileDendrogram(S, d.diana, scaling.factor = .6, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='carbonTot',col.label='Total Carbon (g/Kg)', col.legend.cex = 1.2, n.legend=6, col.palette=viridis::viridis(10))
plotProfileDendrogram(S, d.diana, scaling.factor = .6, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='sulfurTot',col.label='Total Sulfur (g/Kg)', col.legend.cex = 1.2, n.legend=6, col.palette=viridis::viridis(10))
dev.off()

