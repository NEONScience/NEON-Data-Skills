## ----setup, include=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
require(knitr)
knitr::opts_chunk$set(message = FALSE, warning = FALSE)



## ----set-up-env, eval=F-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # # Install neonUtilities package if you have not yet.
# # install.packages("neonUtilities")
# # install.packages("neonOS")
# # install.packages("tidyverse")
# # install.packages("plotly")
# # install.packages("vegan")
# # install.packages("base64enc")
# 


## ----load-packages----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Set global option to NOT convert all character variables to factors
options(stringsAsFactors=F)

# Load required packages
library(neonUtilities)
library(neonOS)
library(tidyverse)
library(plotly)
library(vegan)
library(base64enc)



## ----download-data-inv, results='hide'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# download data of interest - AOS - Macroinvertebrate collection
inv <- neonUtilities::loadByProduct(dpID="DP1.20120.001",
                                    site=c("CUPE","GUIL"), 
                                    startdate="2021-10",
                                    enddate="2024-09",
                                    package="basic",
                                    release= "current",
                                    include.provisional = T,
                                    token = Sys.getenv("NEON_TOKEN"),
                                    check.size = F)



## ----names-inv--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# view all components of the list
names(inv)



## ----unlist-inv-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# unlist the variables and add to the global environment
list2env(inv,envir = .GlobalEnv)



## ----view-citation----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# view formatted citations for DP1.20120.001 download
cat(citation_20120_PROVISIONAL)

cat(`citation_20120_RELEASE-2025`)



## ----view-vars--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# view the entire dataframe in your R environment
view(variables_20120)



## ----view-df----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# view the entire dataframe in your R environment
view(inv_fieldData)



## ----download-data-csd, results='hide'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# download data of interest - AIS - Continuous discharge
csd <- neonUtilities::loadByProduct(dpID="DP4.00130.001",
                                    site=c("CUPE","GUIL"), 
                                    startdate="2021-10",
                                    enddate="2024-09",
                                    package="basic",
                                    release= "current",
                                    include.provisional = T,
                                    token = Sys.getenv("NEON_TOKEN"),
                                    check.size = F)



## ----names-csd--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# view all components of the list
names(csd)



## ----unlist-csd-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# unlist the variables and add to the global environment
list2env(csd, .GlobalEnv)



## ----id-dups----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# what are the primary keys in inv_fieldData?
message("Primary keys in inv_fieldData are: ",
        paste(variables_20120$fieldName[
          variables_20120$table=="inv_fieldData"
          &variables_20120$primaryKey=="Y"
        ],
        collapse = ", ")
        )
# identify duplicates in inv_fieldData
inv_fieldData_dups <- neonOS::removeDups(inv_fieldData,
                                         variables_20120)

# what are the primary keys in inv_persample?
message("Primary keys in inv_persample are: ",
        paste(variables_20120$fieldName[
          variables_20120$table=="inv_persample"
          &variables_20120$primaryKey=="Y"
        ],
        collapse = ", ")
        )
# identify duplicates in inv_persample
inv_persample_dups <- neonOS::removeDups(inv_persample,
                                         variables_20120)

# what are the primary keys in inv_taxonomyProcessed?
message("Primary keys in inv_taxonomyProcessed are: ",
        paste(variables_20120$fieldName[
          variables_20120$table=="inv_taxonomyProcessed"
          &variables_20120$primaryKey=="Y"
        ],
        collapse = ", ")
        )
# identify duplicates in inv_taxonomyProcessed
inv_taxonomyProcessed_dups <- neonOS::removeDups(inv_taxonomyProcessed,
                                         variables_20120)



## ----table-join-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# join inv_fieldData and inv_taxonomyProcessed
inv_fieldTaxJoined <- neonOS::joinTableNEON(inv_fieldData,inv_taxonomyProcessed)



## ----csd-hor----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# use dplyr from the tidyverse collection to get all unique horizontal positions
csd_hor <- csd_continuousDischarge%>%
  dplyr::distinct(siteID,stationHorizontalID)
print(csd_hor)

# GUIL has two horizontal positions because the location of the staff gauge
# changed sometime during this time period. At what date did that occur?
max(csd_continuousDischarge$endDate[
  csd_continuousDischarge$siteID=="GUIL"
  &csd_continuousDischarge$stationHorizontalID=="110"
])



## ----15-min-summ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# 15-min average of continuous discharge data
CSD_15min <- csd_continuousDischarge%>%
  dplyr::mutate(roundDate=lubridate::round_date(endDate,"15 min"))%>%
  dplyr::group_by(siteID,roundDate)%>%
  dplyr::summarise(dischargeMean=mean(continuousDischarge,na.rm=T),
                   dischargeCountQF=sum(dischargeFinalQFSciRvw,na.rm = T))



## ----aos-plot---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
### SHOW BREAKDOWN OF SAMPLER TYPE BY HABITAT TYPE AT EACH SITE ###

sampler_habitat_summ <- inv_fieldTaxJoined%>%
  dplyr::distinct(siteID,samplerType,habitatType)
sampler_habitat_summ  

### PLOT ABUNDANCE ###

# using the `tidyverse` collection, we can clean the data in one piped function
inv_abundance_summ <- inv_fieldTaxJoined%>%
  # remove events when no samples were collected (samplingImpractical)
  # remove samples not associated with a bout
  dplyr::filter(is.na(samplingImpractical)
                &!grepl("GRAB|BRYOZOAN",sampleID))%>%
  
  # calculate abundance (individuals per m2^)
  dplyr::mutate(abun_M2=estimatedTotalCount/benthicArea)%>%
  
  # clean `collectDate` column header
  dplyr::rename(collectDate=collectDate.x)%>%
  
  # first, group including `sampleID` and calculate total abundance per sample
  dplyr::group_by(siteID,collectDate,eventID,sampleID,habitatType,boutNumber)%>%
  dplyr::summarize(abun_M2_sum = sum(abun_M2, na.rm = TRUE))%>%
  
  # second, group excluding `sampleID` to summarize by each bout (`eventID`)
  dplyr::group_by(siteID,collectDate,eventID,habitatType,boutNumber)%>%
  
  # summarize to get mean (+/- se) abundance by bout and sampler type
  dplyr::summarise_each(funs(mean,sd,se=sd(.)/sqrt(n())))%>%
  
  # get categorical variable to sort bouts chronologically
  dplyr::mutate(year=substr(eventID, 6,9),
                yearBout=paste(year,"Bout",boutNumber, sep = "."))

# produce stacked plot to show trends within and across sites
inv_abundance_summ%>%
  ggplot2::ggplot(aes(fill=habitatType, color=habitatType, y=abun_M2_sum_mean, x=yearBout))+
  ggplot2::geom_point(position=position_dodge(0.5), size=2)+
  ggplot2::geom_errorbar(aes(ymin=abun_M2_sum_mean-abun_M2_sum_se, 
                             ymax=abun_M2_sum_mean+abun_M2_sum_se), 
                         width=0.4, alpha=3.0, linewidth=1,
                         position = position_dodge(0.5))+
  ggplot2::facet_wrap(~siteID,ncol = 1,scales="free_y")+
  ggplot2::theme(axis.text.x = element_text(size = 10, angle = 30, 
                                            hjust = 1, vjust = 1))+
  ggplot2::labs(title = "Mean macroinvertebrates per square meter",
                y = "Abundance Per Square Meter",
                x = "Bout")

### PLOT RICHNESS ###

inv_richness_clean <- inv_fieldTaxJoined%>%
  # remove events when no samples were collected (samplingImpractical)
  # remove samples not associated with a bout
  dplyr::filter(is.na(samplingImpractical)
                &!grepl("GRAB|BRYOZOAN",sampleID))%>%
  # clean `collectDate` column header
  dplyr::rename(collectDate=collectDate.x)

# extract sample metadata
inv_sample_info <- inv_richness_clean%>%
  dplyr::select(sampleID, domainID, siteID, namedLocation, 
                collectDate, eventID, boutNumber, 
                habitatType, samplerType, benthicArea)%>%
  dplyr::distinct()

# filter out rare taxa: only observed 1 (singleton) or 2 (doubleton) times
inv_rare_taxa <- inv_richness_clean%>%
  dplyr::distinct(sampleID, acceptedTaxonID, scientificName)%>%
  dplyr::group_by(scientificName)%>%
  dplyr::summarize(occurrences = n())%>%
  dplyr::filter(occurrences > 2)

# filter richness table based on taxon list excluding singletons and doubletons
inv_richness_clean <- inv_richness_clean %>%
  dplyr::filter(scientificName%in%inv_rare_taxa$scientificName) 

# create a matrix of taxa by sampleID
inv_richness_clean_wide <- inv_richness_clean %>%
  # subset to unique combinations of `sampleID` and `scientificName`
  dplyr::distinct(sampleID,scientificName,.keep_all = T)%>%
  
  # remove any records with no abundance data
  dplyr::mutate(abun_M2=estimatedTotalCount/benthicArea)%>%
  filter(!is.na(abun_M2))%>%
  
  # pivot to wide format, sum multiple counts per sampleID
  tidyr::pivot_wider(id_cols = sampleID, 
                     names_from = scientificName,
                     values_from = abun_M2,
                     values_fill = list(abun_M2 = 0),
                     values_fn = list(abun_M2 = sum)) %>%
  tibble::column_to_rownames(var = "sampleID") %>%
  
  #round to integer so that vegan functions will run
  round()

# code check - check col and row sums
# mins should all be > 0 for further analysis in vegan
if(colSums(inv_richness_clean_wide) %>% min()==0){
  stop("Column sum is 0: do not proceed with richness analysis!")
}
if(rowSums(inv_richness_clean_wide) %>% min()==0){
  stop("Row sum is 0: do not proceed with richness analysis!")
}

# use the `vegan` package to calculate diversity indices

# calculate richness
inv_richness <- as.data.frame(
  vegan::specnumber(inv_richness_clean_wide)
  )
names(inv_richness) <- "richness"

inv_richness_stats <- vegan::estimateR(inv_richness_clean_wide)

# calculate evenness
inv_evenness <- as.data.frame(
  vegan::diversity(inv_richness_clean_wide)/
    log(vegan::specnumber(inv_richness_clean_wide))
  )
names(inv_evenness) <- "evenness"

# calculate shannon index
inv_shannon <- as.data.frame(
  vegan::diversity(inv_richness_clean_wide, index = "shannon")
  )
names(inv_shannon) <- "shannon"

# calculate simpson index
inv_simpson <- as.data.frame(
  vegan::diversity(inv_richness_clean_wide, index = "simpson")
  )
names(inv_simpson) <- "simpson"

# create a single data frame
inv_diversity_indices <- cbind(inv_richness, inv_evenness, inv_shannon, inv_simpson)

# bring in the metadata table created earlier
inv_diversity_indices <- dplyr::left_join(
  tibble::rownames_to_column(inv_diversity_indices),
  inv_sample_info,
  by = c("rowname" = "sampleID")) %>%
  dplyr::rename(sampleID = rowname)

# create summary table for plotting
inv_diversity_summ <- inv_diversity_indices%>%
  tidyr::pivot_longer(c(richness,evenness,shannon,simpson),
                      names_to = "indexName",
                      values_to = "indexValue")%>%
  group_by(siteID,collectDate,eventID,habitatType,boutNumber,indexName)%>%
  dplyr::summarize(mean = mean(indexValue),
                   n=n(),
                   sd = sd(indexValue),
                   se=sd/sqrt(n))%>%
  dplyr::mutate(year=substr(eventID, 6,9),
                yearBout=paste(year,"Bout",boutNumber, sep = "."))

# produce plot to show trends within and across sites
inv_diversity_summ%>%
  dplyr::filter(indexName=="richness")%>%
  ggplot2::ggplot(aes(fill=habitatType, color=habitatType, y=mean, x=yearBout))+
  ggplot2::geom_point(position=position_dodge(0.5), size=2)+
  ggplot2::geom_errorbar(aes(ymin=mean-se, ymax=mean+se), 
                         width=0.4, alpha=3.0, linewidth=1,
                         position = position_dodge(0.5))+
  ggplot2::facet_wrap(~siteID,ncol=1)+
  ggplot2::theme(axis.text.x = element_text(size = 10, angle = 30, 
                                            hjust = 1, vjust = 1))+
  labs(title="Mean number of macroinvertebrate taxa per bout",
       y= "Taxon Richness", x = "Bout")



## ----csd-plot---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CSD_15min%>%
  ggplot2::ggplot(aes(x=roundDate,y=dischargeMean))+
  ggplot2::geom_line()+
  ggplot2::facet_wrap(~siteID,ncol = 1)+
  # ggplot2::scale_y_log10()+ # Include to show discharge axis in log scale
  labs(title="Continuous Discharge for Water Years 2022-2024",
       y= "Discharge (L/s)", x = "Date")



## ----aos-ais-plot, out.width='100%', out.height='600px'---------------------------------------------------------------------------------------------------------------------------------------------------------------
# choose the site(s) you want to plot
siteToPlot <- c("CUPE","GUIL")

for(s in 1:length(siteToPlot)){
  # begin the plot code
  CSD_15min%>%
    dplyr::filter(siteID==siteToPlot[s])%>%
    plotly::plot_ly()%>%
    # add trace for continuous discharge
    plotly::add_trace(x=~roundDate,y=~dischargeMean,
                      type="scatter",mode="line",
                      line=list(color = 'darkgray'),
                      name="Discharge")%>%
    # add trace for INV abundance
    plotly::add_trace(data=inv_abundance_summ%>%
                        dplyr::filter(siteID==siteToPlot[s]),
                      x=~collectDate,y=~abun_M2_sum_mean,
                      split=~paste0("INV Abundance: ",habitatType),
                      yaxis="y2",type="scatter",mode="line",
                      error_y=~list(array=abun_M2_sum_se,
                                    color='darkorange'),
                      marker=list(color="darkorange"),
                      line=list(color="darkorange"),
                      visible="legendonly")%>%
    # add trace for INV richness
    plotly::add_trace(data=inv_diversity_summ%>%
                        dplyr::filter(siteID==siteToPlot[s]
                                      &indexName=="richness"),
                      x=~collectDate,y=~mean,
                      split=~paste0("INV Richness: ",habitatType),
                      yaxis="y3",type="scatter",mode="line",
                      error_y=~list(array=se,
                                    color='darkgreen'),
                      marker=list(color="darkgreen"),
                      line=list(color="darkgreen"),
                      visible="legendonly")%>%
    # define the layout of the plot
    plotly::layout(
      title = paste0(siteToPlot[s],
                     " Discharge w/ Macroinvertebrate Abundance & Richness"),
      # format x-axis
      xaxis=list(title="dateTime",
                 automargin=TRUE,
                 domain=c(0,0.9)),
      # format first y-axis
      yaxis=list(
        side='left',
        title='Discharge (L/s)',
        showgrid=FALSE,
        zeroline=FALSE,
        automargin=TRUE),
      # format second y-axis
      yaxis2=list(
        side='right',
        overlaying="y",
        title='INV Abundance',
        showgrid=FALSE,
        automargin=TRUE,
        zeroline=FALSE,
        tickfont=list(color = 'darkorange'),
        titlefont=list(color = 'darkorange')),
      # format third y-axis
      yaxis3=list(
        side='right',
        overlaying="y",
        anchor="free",
        title='INV Richness',
        showgrid=FALSE,
        zeroline=FALSE,
        automargin=TRUE,
        tickfont=list(color = 'darkgreen'),
        titlefont=list(color = 'darkgreen'),
        position=0.99),
      # format legend
      legend=list(xanchor = 'center',
                  yanchor = 'top',
                  orientation = 'h',
                  x=0.5,y=-0.2),
      # add button to switch discharge between linear and log
      updatemenus=list(
        list(
          type='buttons',
          buttons=list(
            list(label='linear',
              method='relayout',
              args=list(list(yaxis=list(type='linear')))),
            list(label='log',
              method='relayout',
              args=list(list(yaxis=list(type='log'))))))))
  
}



## ----highlight-fiona, out.width='100%', out.height='600px'------------------------------------------------------------------------------------------------------------------------------------------------------------
# identify the date of Fiona
fionaDate <- "2022-09-19"

# highlight Fiona at CUPE
AOS_AIS_plot_CUPE_Fiona <- AOS_AIS_plot_CUPE%>%
  # add dashed vertical line to plot created in previous exercise
  plotly::add_segments(x=as.POSIXct(fionaDate,tz="UTC"),
                       xend=as.POSIXct(fionaDate,tz="UTC"),
                       y=0,
                       yend=max(CSD_15min$dischargeMean[
                         CSD_15min$siteID=="CUPE"],
                         na.rm = T),
                       name="Fiona",
                       line=list(color='red',dash='dash'))

# highlight Fiona at GUIL
AOS_AIS_plot_GUIL_Fiona <- AOS_AIS_plot_GUIL%>%
  # add dashed vertical line to plot created in previous exercise
  plotly::add_segments(x=as.POSIXct(fionaDate,tz="UTC"),
                       xend=as.POSIXct(fionaDate,tz="UTC"),
                       y=0,
                       yend=max(CSD_15min$dischargeMean[
                         CSD_15min$siteID=="CUPE"],
                         na.rm = T),
                       name="Fiona",
                       line=list(color='red',dash='dash'))



## ----download-data-geo, results='hide'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# download data of interest - AOS - Stream morphology maps
# the expanded download package is needed to read in the geo_pebbleCount table
geo <- neonUtilities::loadByProduct(dpID="DP4.00131.001",
                                    site=c("CUPE","GUIL"), 
                                    startdate="2021-10",
                                    enddate="2024-09",
                                    package="expanded",
                                    release= "current",
                                    include.provisional = T,
                                    token = Sys.getenv("NEON_TOKEN"),
                                    check.size = F)

# unlist the variables and add to the global environment
list2env(geo,envir = .GlobalEnv)



## ----id-dups-geo------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# what are the primary keys in geo_pebbleCount?
message("Primary keys in geo_pebbleCount are: ",
        paste(variables_00131$fieldName[
          variables_00131$table=="geo_pebbleCount"
          &variables_00131$primaryKey=="Y"
        ],
        collapse = ", ")
        )
# identify duplicates in geo_pebbleCount
geo_pebbleCount_dups <- neonOS::removeDups(geo_pebbleCount,
                                           variables_00131)


## ----wrangle-plot-geo-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# we want to plot the frequency of `pebbleSize`
# `pebbleSize` is published as a categorical variable (range of size - mm)
# For plotting purposes, convert `pebbleSize` to numeric (lower number in range)
geo_pebbleCount$pebbleSize_num <- NA
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="< 2 mm: silt/clay"
  ] <- 0
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="< 2 mm: sand"
  ] <- 0
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="2 - 2.8 mm: very coarse sand"
  ] <- 2
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="2.8 - 4 mm: very fine gravel"
  ] <-2.8
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="4 - 5.6 mm: fine gravel"
  ] <- 4
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="5.6 - 8 mm: fine gravel"
  ] <- 5.6
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="8 - 11 mm: medium gravel"
  ] <- 8
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="11 - 16 mm: medium gravel"
  ] <- 11
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="16 - 22.6 mm: coarse gravel"
  ] <- 16
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="22.6 - 32 mm: coarse gravel"
  ] <- 22.6
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="32 - 45 mm: very coarse gravel"
  ] <- 32
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="45 - 64 mm: very coarse gravel"
  ] <- 45
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="64 - 90 mm: small cobble"
  ] <- 64
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="90 - 128 mm: medium cobble"
  ] <- 90
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="128 - 180 mm: large cobble"
  ] <- 128
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="180 - 256 mm: large cobble"
  ] <- 180
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="> 256 mm: boulder"
  ] <- 256
geo_pebbleCount$pebbleSize_num[
  geo_pebbleCount$pebbleSize=="> 256 mm: bedrock"
  ] <- 256

# each 'siteID' and 'surveyEndDate' represents a unique pebble count survey

# group by 'siteID' and 'surveyEndDate'` and calculate frequency
geo_pebbleCount_freq <- geo_pebbleCount%>%
  dplyr::group_by(siteID,surveyEndDate,eventID,pebbleSize_num)%>%
  dplyr::summarise(frequency=n()/200)

# calculate a cumulative sum of frequency per event ID
for(e in 1:length(unique(geo_pebbleCount_freq$eventID))){
  eventID_freq <- geo_pebbleCount_freq%>%
    filter(eventID==unique(geo_pebbleCount$eventID)[e])
  eventID_freq$CumulativeFreq <- cumsum(eventID_freq$frequency)*100
  if(e==1){
    geo_pebbleCount_freqCumm <- eventID_freq
  }else{
    geo_pebbleCount_freqCumm <- rbind(geo_pebbleCount_freqCumm,eventID_freq)
  }
}

# assign a year to each survey
geo_pebbleCount_freqCumm <- geo_pebbleCount_freqCumm%>%
  dplyr::mutate(year=format(surveyEndDate,"%Y"))

# create cumulative frequency curve plot using `geom_smooth`
geo_pebbleCount_freqCumm%>%
  ggplot2::ggplot(aes(x = pebbleSize_num, y = CumulativeFreq, color = year)) +
  ggplot2::geom_smooth(method = "loess", se = T, linewidth = 0.75) +
  ggplot2::labs(title="Cumulative Particle Size Distribution by Year",
       x = "Particle Size (mm)", y = "Cumulative Frequency (%)") +
  ggplot2::facet_wrap(~siteID)



## ----highlight-fiona-psd, out.width='100%', out.height='800px'--------------------------------------------------------------------------------------------------------------------------------------------------------
# generate small, simple subplots of each pebble count survey
# loop through each site and year to make plot and save to the working directory
# for(s in 1:length(unique(geo_pebbleCount_freqCumm$siteID))){
#   currSite <- unique(geo_pebbleCount_freqCumm$siteID)[s]
#   for(y in 1:length(unique(geo_pebbleCount_freqCumm$year))){
#     currYear <- unique(geo_pebbleCount_freqCumm$year)[y]
#     currPlot <- geo_pebbleCount_freqCumm%>%
#       dplyr::filter(siteID==currSite
#                     &year==currYear)%>%
#       ggplot2::ggplot(aes(x = pebbleSize_num, y = CumulativeFreq)) +
#       ggplot2::geom_smooth(method = "loess", se = T, linewidth = 0.75) +
#       ggplot2::labs(x = NULL, y = NULL)+
#       ggplot2::scale_y_continuous(limits=c(0,105))+
#       ggplot2::scale_x_continuous(limits=c(0,260))+
#       ggplot2::theme_classic()+
#       ggplot2::theme(text=element_text(size=18))
#     ggplot2::ggsave(plot=currPlot,
#                     filename=paste0("images/psd_",currSite,currYear,".png"),
#                     width = 4, height = 7, units = "cm")
#   }
# }

# re-generate the CUPE plot with particle size distribution subplots added
AOS_AIS_plot_CUPE_Fiona%>%
  layout(images=list(
    # show the CUPE 2022 pebble count survey, conducted 2022-04
    list(source=base64enc::dataURI(file="images/psd_CUPE2022.png"),
         x = 0.05, y = 0.7, 
         sizex = 0.25, sizey = 0.25,
         xref = "paper", yref = "paper", 
         xanchor = "left", yanchor = "bottom"),
    # show the CUPE 2023 pebble count survey, conducted 2022-05
    list(source=base64enc::dataURI(file="images/psd_CUPE2023.png"),
         x = 0.4, y = 0.7, 
         sizex = 0.25, sizey = 0.25,
         xref = "paper", yref = "paper", 
         xanchor = "left", yanchor = "bottom"),
    # show the CUPE 2024 pebble count survey, conducted 2022-05
    list(source=base64enc::dataURI(file="images/psd_CUPE2024.png"),
         x = 0.7, y = 0.7, 
         sizex = 0.25, sizey = 0.25,
         xref = "paper", yref = "paper", 
         xanchor = "left", yanchor = "bottom")
    
    ))

# re-generate the GUIL plot with particle size distribution subplots added
AOS_AIS_plot_GUIL_Fiona%>%
  layout(images=list(
    # show the GUIL 2022 pebble count survey, conducted 2022-04
      list(source=base64enc::dataURI(file="images/psd_GUIL2022.png"),
         x = 0.05, y = 0.7, 
         sizex = 0.25, sizey = 0.25,
         xref = "paper", yref = "paper", 
         xanchor = "left", yanchor = "bottom"),
    # show the GUIL 2023 pebble count survey, conducted 2023-03
    list(source=base64enc::dataURI(file="images/psd_GUIL2023.png"),
         x = 0.35, y = 0.7, 
         sizex = 0.25, sizey = 0.25,
         xref = "paper", yref = "paper", 
         xanchor = "left", yanchor = "bottom"),
    # show the GUIL 2024 pebble count survey, conducted 2024-07
    list(source=base64enc::dataURI(file="images/psd_GUIL2024.png"),
         x = 0.75, y = 0.7, 
         sizex = 0.25, sizey = 0.25,
         xref = "paper", yref = "paper", 
         xanchor = "left", yanchor = "bottom")
    
    ))



## ----download-swc, results='hide'-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# download data of interest - AOS - Chemical properties of surface water
swc <- neonUtilities::loadByProduct(dpID="DP1.20093.001",
                                    site=c("CUPE"), 
                                    startdate="2021-10",
                                    enddate="2024-09",
                                    package="basic",
                                    release= "current",
                                    include.provisional = T,
                                    token = Sys.getenv("NEON_TOKEN"),
                                    check.size = F)

# unlist the variables and add to the global environment
list2env(swc,envir = .GlobalEnv)



## ----wrangle-plot-swc-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# check if there are duplicate DOC records
# what are the primary keys in swc_externalLabDataByAnalyte?
message("Primary keys in swc_externalLabDataByAnalyte are: ",
        paste(variables_20093$fieldName[
          variables_20093$table=="swc_externalLabDataByAnalyte"
          &variables_20093$primaryKey=="Y"
        ],
        collapse = ", ")
        )
# identify duplicates in swc_externalLabDataByAnalyte
swc_externalLabDataByAnalyte_dups <- neonOS::removeDups(
  swc_externalLabDataByAnalyte,
  variables_20093)

# no duplicates, great!

# lab data is published `long-format` with 28 analytes analyzed
# show all the analytes published in the lab data
print(unique(swc_externalLabDataByAnalyte$analyte))

# for this exercise, subset lab data to only dissolved organic carbon (DOC)
DOC <- swc_externalLabDataByAnalyte%>%
  dplyr::filter(analyte=="DOC")

# plot a timeseries of DOC
DOC%>%
  ggplot2::ggplot(aes(x=collectDate,y=analyteConcentration))+
  ggplot2::geom_point()+
  ggplot2::labs(title = "Dissolved organic carbon (DOC) over time",
                y = "DOC (mg/L)",
                x = "Date")



## ----download-waq, results='hide'-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# download data of interest - AIS - Water quality
waq <- neonUtilities::loadByProduct(dpID="DP1.20288.001",
                                    site=c("CUPE"), 
                                    startdate="2021-10",
                                    enddate="2024-09",
                                    package="basic",
                                    release= "current",
                                    include.provisional = T,
                                    token = Sys.getenv("NEON_TOKEN"),
                                    check.size = F)

# unlist the variables and add to the global environment
list2env(waq,envir = .GlobalEnv)



## ----wrangle-plot-waq-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# `waq_instantaneous` table published many water quality metrics in wide-format
# other than fDOM, many other metrics are published in `waq_instantaneous`
# including: dissolved oxygen, specific conductance, pH, chlorophyll, turbidity

# according to the NEON AIS spatial design, fDOM is only measured at the 
# downstream sensor set (S2, HOR = 102); subset to HOR 102
WAQ_102 <- waq_instantaneous%>%
  dplyr::filter(horizontalPosition==102)

# `waq_instantaneous` is published at a 1 minute temporal resolution
# for ease of plotting, let's create a 15-minute average table
fDOM_15min <- WAQ_102%>%
  
  # remove NULL records
  dplyr::filter(!is.na(rawCalibratedfDOM))%>%
  
  # remove records with a final QF
  dplyr::filter(fDOMFinalQF==0)%>%
  
  # create 15-minute average of fDOM
  mutate(roundDate=lubridate::round_date(endDateTime,"15 min"))%>%
  group_by(siteID,roundDate)%>%
  summarize(mean_fDOM=mean(rawCalibratedfDOM))

# plot a timeseries of fDOM
fDOM_15min%>%
  ggplot2::ggplot(aes(x=roundDate,y=mean_fDOM))+
  ggplot2::geom_line()+
  ggplot2::labs(title = "fluorescent dissolved organic matter (fDOM) over time",
                y = "fDOM (QSU)",
                x = "Date")



## ----join-aos-ais-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# round DOC `collectDate` to the nearest 15 minute timestamp
DOC$roundDate <- lubridate::round_date(DOC$collectDate,"15 min")

# perform a left-join, which will join an AIS DOC record to every AIS fDOM 
# record based on matching timestamps
fDOM_DOC_join <- dplyr::left_join(fDOM_15min,DOC,by="roundDate")


## ----linear-regression------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# use `lm` function to create a linear regression: DOC~fDOM
model <- lm(analyteConcentration~mean_fDOM,data=fDOM_DOC_join)

# view a summary of the regression model
print(summary(model))

# show a plot of the relationship with a linear trendline added
fDOM_DOC_join%>%
  ggplot2::ggplot(aes(x=mean_fDOM,y=analyteConcentration))+
  ggplot2::geom_point()+
  ggplot2::geom_smooth(method="lm",se=T)+
  ggplot2::scale_x_continuous(limits=c(0,60))+
  ggplot2::labs(title = "AOS-DOC vs. AIS-fDOM",
                y = "DOC (mg/L)",
                x = "fDOM (QSU)")



## ----model-doc--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# predict continuous doc based on the linear regression model coefficients
fDOM_DOC_join$fit <- predict(model,
                             newdata = fDOM_DOC_join,
                             interval = "confidence")[, "fit"]

# add two more columns with predicted 95% CI uncertainty around the modeled DOC
conf_int <- predict(model, newdata = fDOM_DOC_join, interval = "confidence")
fDOM_DOC_join$lwr <- conf_int[, "lwr"]
fDOM_DOC_join$upr <- conf_int[, "upr"]



## ----plot-model-doc, out.width='100%', out.height='600px'-------------------------------------------------------------------------------------------------------------------------------------------------------------
# create plot
plotly::plot_ly(data=fDOM_DOC_join)%>%
  
  # plot uncertainty as a ribbon
  plotly::add_trace(x=~roundDate,y=~upr,name="95% CI",
                    type='scatter',mode='line',
                    line=list(color='lightgray'),legendgroup="95CI",
                    showlegend=F)%>%
  plotly::add_trace(x=~roundDate,y=~lwr,name="95% CI",
                    type='scatter',mode='none',fill = 'tonexty',
                    fillcolor = 'lightgray',legendgroup="95CI")%>%
  
  # plot modeled DOC timeseries
  plotly::add_trace(x=~roundDate,y=~fit,name="Modeled DOC",
                    type='scatter',mode='line',
                    line=list(color='blue'))%>%
  
  # plot grab sample DOC
  plotly::add_trace(x=~roundDate,y=~analyteConcentration,name="Grab Sample DOC",
                    type='scatter',mode='markers',
                    marker=list(color='darkorange'))%>%
  
  # format title, axes, and legend
  plotly::layout(title="Dissolved Organic Carbon: Modelled & Grab Sample",
                 xaxis=list(title="Date"),
                 yaxis=list(title="DOC (mg/L)"),
                 legend=list(xanchor = 'center',
                             yanchor = 'top',
                             orientation = 'h',
                             x=0.5,y=-0.2))


