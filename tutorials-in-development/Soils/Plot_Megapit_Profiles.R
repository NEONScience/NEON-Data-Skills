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

# Links to data product IDS
# Soil physical properties (Megapit) DP1.00096.001

MP <- loadByProduct(dpID = "DP1.00096.001", check.size = F)
list2env(MP, .GlobalEnv)

MC <- loadByProduct(dpID = "DP1.00097.001", check.size = F)
list2env(MC, .GlobalEnv)

rm(MP)
rm(MC)

#mgp_perhorizon <- arrange(mgp_perhorizon, siteID, horizonTopDepth)

S =mgp_perhorizon

S$siteLabel=paste(S$domainID, S$siteID, sep="-")
## join perbiogeosample table or colorization of horizons

B=full_join(mgp_perbiogeosample, mgc_perbiogeosample, by=c('horizonID','biogeoID','siteID','horizonName'))

B=B[B$biogeoSampleType.x=="Regular",]

S=left_join(S, B, by=c('horizonID', 'siteID','horizonName'))

S <- arrange(S, siteID, horizonTopDepth)

depths(S) <- siteLabel ~ horizonTopDepth + horizonBottomDepth

## split up plots to get them to all fit
par(mar=c(0,0,3,0), mfrow=c(2,1))
plot(S[1:10], name='horizonName', label='siteLabel', color='clayTotal', col.label='Clay Content (%)')
plot(S[1:10], name='horizonName', label='siteLabel', color='carbonTot')#, col.label='Clay Content (%)')
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
pdf(file="NEON_Soils_Texture_Clusters.pdf", width=22, height=10)
par(mar=c(1,1,3,1), mfrow=c(3,1))
plotProfileDendrogram(S, d.diana, scaling.factor = 1, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='sandTotal',col.label='Sand Content (%)', col.palette=viridis::viridis(10))
plotProfileDendrogram(S, d.diana, scaling.factor = 1, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='siltTotal',col.label='Silt Content (%)', col.palette=viridis::viridis(10))
plotProfileDendrogram(S, d.diana, scaling.factor = 1, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='clayTotal',col.label='Clay Content (%)', col.palette=viridis::viridis(10))
dev.off()

## Nutrients
d <- profile_compare(S, vars=c('nitrogenTot','carbonTot', 'sulfurTot'), k=0, max_d=100)
d.diana <- diana(d)

pdf(file="NEON_Soils_Nutrient_Clusters.pdf", width=22, height=10)
par(mar=c(1,1,3,1), mfrow=c(3,1))
plotProfileDendrogram(S, d.diana, scaling.factor = 1, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='nitrogenTot',col.label='Total Nitrogen (g/Kg)', col.palette=viridis::viridis(10))
plotProfileDendrogram(S, d.diana, scaling.factor = 1, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='carbonTot',col.label='Total Carbon (g/Kg)', col.palette=viridis::viridis(10))
plotProfileDendrogram(S, d.diana, scaling.factor = 1, y.offset = 2, width=0.25, name='horizonName', label='siteLabel', color='sulfurTot',col.label='Total Sulfur (g/Kg)', col.palette=viridis::viridis(10))
dev.off()

