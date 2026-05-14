## ----setup, include=FALSE-------------------------------------------------------------------
require(knitr)
opts_chunk$set(message=FALSE, warning=FALSE)



## ----set-up-env, eval=F---------------------------------------------------------------------
# # # Install neonUtilities package if you have not yet.
# # install.packages("neonUtilities")
# # install.packages("neonOS")
# # install.packages("tidyverse")
# # install.packages("plotly")
# # install.packages("vegan")
# # install.packages("base64enc")
# # install.packages("htmlwidgets")
# # install.packages("htmltools")
# 


## ----load-packages--------------------------------------------------------------------------
# Load required packages
library(neonUtilities)
library(neonOS)
library(tidyverse)
library(plotly)
library(vegan)
library(base64enc)
library(htmlwidgets)
library(htmltools)



## ----choose sites, results='hide'-----------------------------------------------------------
# Create vector of site names to use in loadByProduct()
siteList <- c("CUPE", "GUIL")



## ----choose years, results='hide'-----------------------------------------------------------
# Set the start and end water years to explore
startWY <- 2022
endWY <- 2024

# DO NOT EDIT - format dates for neonUtilities
startWY_query <- paste0(startWY-1, "-10")
endWY_query <- paste0(endWY, "-09")



## ----download-data-inv, results='hide'------------------------------------------------------
# download data of interest - AOS - Macroinvertebrate collection
inv <- loadByProduct(dpID="DP1.20120.001",
                     site=siteList,
                     startdate=startWY_query,
                     enddate=endWY_query,
                     package="expanded",
                     release="current",
                     include.provisional=T,
                     token=Sys.getenv("NEON_TOKEN"),
                     check.size=F)



## ----names-inv------------------------------------------------------------------------------
# view all components of the list
names(inv)



## ----unlist-inv-----------------------------------------------------------------------------
# unlist the variables and add to the global environment
list2env(inv, envir=.GlobalEnv)



## ----view-citation--------------------------------------------------------------------------
# View formatted citations for DP1.20120.001 download
# Locate any citation files and print them in the console
citationFiles <- names(inv)[grepl("citation", names(inv))]
for(c in citationFiles){cat(get(c))}


## ----view-vars, eval=FALSE------------------------------------------------------------------
# # view the entire dataframe in your R environment
# view(variables_20120)
# 


## ----view-df, eval=FALSE--------------------------------------------------------------------
# # view the entire dataframe in your R environment
# view(inv_fieldData)
# 


## ----download-data-csd, results='hide'------------------------------------------------------
# download data of interest - AIS - Continuous discharge
csd <- loadByProduct(dpID="DP4.00130.001",
                     site=siteList, 
                     startdate=startWY_query,
                     enddate=endWY_query,
                     package="basic",
                     release= "current",
                     include.provisional=T,
                     token=Sys.getenv("NEON_TOKEN"),
                     check.size=F)



## ----names-csd------------------------------------------------------------------------------
# view all components of the list
names(csd)



## ----unlist-csd-----------------------------------------------------------------------------
# unlist the variables and add to the global environment
list2env(csd, .GlobalEnv)



## ----id-dups--------------------------------------------------------------------------------
# what are the primary keys in inv_fieldData?
cat("Primary keys in inv_fieldData are:",
    paste(variables_20120$fieldName[
      variables_20120$table=="inv_fieldData"
      &variables_20120$primaryKey=="Y"
    ],
    collapse=", ")
    )
# identify duplicates in inv_fieldData
inv_fieldData_dups <- removeDups(inv_fieldData,
                                 variables_20120)
cat("There are",
    sum(inv_fieldData_dups$duplicateRecordQF%in%c(1, 2)),
    "duplicate records in 'inv_fieldData'")

# what are the primary keys in inv_persample?
cat("Primary keys in inv_persample are:",
    paste(variables_20120$fieldName[
      variables_20120$table=="inv_persample"
      &variables_20120$primaryKey=="Y"
    ],
    collapse=", ")
    )
# identify duplicates in inv_persample
inv_persample_dups <- removeDups(inv_persample,
                                 variables_20120)
cat("There are",
    sum(inv_persample_dups$duplicateRecordQF%in%c(1, 2)),
    "duplicate records in 'inv_persample'")

# what are the primary keys in inv_taxonomyProcessed?
cat("Primary keys in inv_taxonomyProcessed are:",
    paste(variables_20120$fieldName[
      variables_20120$table=="inv_taxonomyProcessed"
      &variables_20120$primaryKey=="Y"
    ],
    collapse=", ")
    )
# identify duplicates in inv_taxonomyProcessed
inv_taxonomyProcessed_dups <- removeDups(inv_taxonomyProcessed,
                                         variables_20120)
cat("There are",
    sum(inv_fieldData_dups$duplicateRecordQF%in%c(1, 2)),
    "duplicate records in 'inv_taxonomyProcessed'")



## ----table-join-----------------------------------------------------------------------------
# join inv_fieldData and inv_taxonomyProcessed
inv_fieldTaxJoined <- joinTableNEON(inv_fieldData, inv_taxonomyProcessed)



## ----sampler-habitat type-------------------------------------------------------------------
# Show breakdown of sampler type by habitat type at each site
sampler_habitat_summ <- inv_fieldTaxJoined%>%
  distinct(siteID, samplerType, habitatType)
sampler_habitat_summ  


## ----inv abundance wrangle------------------------------------------------------------------
# using the `tidyverse` collection, we can clean the data in one piped function
inv_abundance_summ <- inv_fieldTaxJoined%>%
  # remove events when no samples were collected (samplingImpractical)
  # remove samples not associated with a bout
  filter(is.na(samplingImpractical)&!grepl("GRAB|BRYOZOAN", sampleID))%>%
  
  # calculate abundance (individuals per m2^)
  mutate(abun_M2=estimatedTotalCount/benthicArea)%>%
  
  # clean `collectDate` column header
  rename(collectDate=collectDate.x)%>%
  
  # first, group including `sampleID` and calculate total abundance per sample
  group_by(siteID, collectDate, eventID, sampleID, habitatType, boutNumber)%>%
  summarize(abun_M2_sum=sum(abun_M2, na.rm=TRUE))%>%
  
  # second, group excluding `sampleID` to summarize by each bout (`eventID`)
  group_by(siteID, collectDate, eventID, habitatType, boutNumber)%>%
  
  # summarize to get mean (+/- se) abundance by bout and sampler type
  summarise(across(abun_M2_sum,
                   list(mean=mean, sd=sd,
                        se=~sd(.x, na.rm=TRUE)/sqrt(n())),
                   .names="{.col}_{.fn}"))%>%
  
  # get categorical variable to sort bouts chronologically
  mutate(year=substr(eventID, 6, 9),
         yearBout=paste(year, "Bout", boutNumber, sep="."))



## ----inv abundance plot---------------------------------------------------------------------
# produce stacked plot to show trends within and across sites
inv_abundance_summ%>%
  ggplot(aes(fill=habitatType, color=habitatType,
             y=abun_M2_sum_mean, x=yearBout))+
  geom_point(position=position_dodge(0.5), size=2)+
  geom_errorbar(aes(ymin=abun_M2_sum_mean-abun_M2_sum_se, 
                    ymax=abun_M2_sum_mean+abun_M2_sum_se), 
                width=0.4, alpha=3.0, linewidth=1,
                position=position_dodge(0.5))+
  facet_wrap(~siteID, ncol=1, scales="free_y")+
  theme(axis.text.x=element_text(size=10, angle=30, hjust=1, vjust=1))+
  labs(title="Mean macroinvertebrates per square meter",
       y="Abundance Per Square Meter",
       x="Bout")



## ----inv richness wrangle-------------------------------------------------------------------
inv_richness_clean <- inv_fieldTaxJoined%>%
  # remove events when no samples were collected (samplingImpractical)
  # remove samples not associated with a bout
  filter(is.na(samplingImpractical)&!grepl("GRAB|BRYOZOAN", sampleID))%>%
  # clean `collectDate` column header
  rename(collectDate=collectDate.x)

# extract sample metadata
inv_sample_info <- inv_richness_clean%>%
  select(sampleID, domainID, siteID, namedLocation, 
         collectDate, eventID, boutNumber, 
         habitatType, samplerType, benthicArea)%>%
  distinct()

# filter out rare taxa: only observed 1 (singleton) or 2 (doubleton) times
inv_rare_taxa <- inv_richness_clean%>%
  distinct(sampleID, acceptedTaxonID, scientificName)%>%
  group_by(scientificName)%>%
  summarize(occurrences=n())%>%
  filter(occurrences > 2)

# filter richness table based on taxon list excluding singletons and doubletons
inv_richness_clean <- inv_richness_clean %>%
  filter(scientificName%in%inv_rare_taxa$scientificName) 

# create a matrix of taxa by sampleID
inv_richness_clean_wide <- inv_richness_clean %>%
  # subset to unique combinations of `sampleID` and `scientificName`
  distinct(sampleID, scientificName, .keep_all=T)%>%
  
  # remove any records with no abundance data
  mutate(abun_M2=estimatedTotalCount/benthicArea)%>%
  filter(!is.na(abun_M2))%>%
  
  # pivot to wide format, sum multiple counts per sampleID
  pivot_wider(id_cols=sampleID, 
              names_from=scientificName,
              values_from=abun_M2,
              values_fill=list(abun_M2=0),
              values_fn=list(abun_M2=sum)) %>%
  column_to_rownames(var="sampleID") %>%
  
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



## ----inv richness calculate-----------------------------------------------------------------
# calculate richness
inv_richness <- as.data.frame(
  specnumber(inv_richness_clean_wide)
  )
names(inv_richness) <- "richness"

inv_richness_stats <- estimateR(inv_richness_clean_wide)

# calculate evenness
inv_evenness <- as.data.frame(
  diversity(inv_richness_clean_wide)/log(specnumber(inv_richness_clean_wide))
  )
names(inv_evenness) <- "evenness"

# calculate shannon index
inv_shannon <- as.data.frame(
  diversity(inv_richness_clean_wide, index="shannon")
  )
names(inv_shannon) <- "shannon"

# calculate simpson index
inv_simpson <- as.data.frame(
  diversity(inv_richness_clean_wide, index="simpson")
  )
names(inv_simpson) <- "simpson"

# create a single data frame
inv_diversity_indices <- cbind(inv_richness, 
                               inv_evenness, 
                               inv_shannon, 
                               inv_simpson)

# bring in the metadata table created earlier
inv_diversity_indices <- left_join(rownames_to_column(inv_diversity_indices),
                                   inv_sample_info,
                                   by=c("rowname"="sampleID")) %>%
  rename(sampleID=rowname)

# create summary table for plotting
inv_diversity_summ <- inv_diversity_indices%>%
  pivot_longer(c(richness, evenness, shannon, simpson),
               names_to="indexName",values_to="indexValue")%>%
  group_by(siteID, collectDate, eventID, habitatType, boutNumber, indexName)%>%
  summarize(mean=mean(indexValue),
            n=n(),
            sd=sd(indexValue),
            se=sd/sqrt(n))%>%
  mutate(year=substr(eventID, 6, 9),
         yearBout=paste(year, "Bout", boutNumber, sep="."))


## ----inv richness plot----------------------------------------------------------------------
# produce plot to show trends within and across sites
inv_diversity_summ%>%
  filter(indexName=="richness")%>%
  ggplot(aes(fill=habitatType, color=habitatType, y=mean, x=yearBout))+
  geom_point(position=position_dodge(0.5), size=2)+
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se),
                width=0.4, alpha=3.0, linewidth=1,
                position=position_dodge(0.5))+
  facet_wrap(~siteID, ncol=1)+
  theme(axis.text.x=element_text(size=10, angle=30, 
                                 hjust=1, vjust=1))+
  labs(title="Mean number of macroinvertebrate taxa per bout",
       y= "Taxon Richness", x="Bout")



## ----csd-plot-------------------------------------------------------------------------------
# Plot with discharge in linear scale
csd_15_min%>%
  ggplot(aes(x=startDateTime, y=dischargeContinuous))+
  geom_line()+
  facet_wrap(~siteID, ncol=1, scales="free_y")+
  labs(title="Continuous Discharge for Water Years 2022-2024",
       y= "Discharge (L/s)", x="Date")

# Plot with discharge in log scale
csd_15_min%>%
  ggplot(aes(x=startDateTime, y=dischargeContinuous))+
  geom_line()+
  facet_wrap(~siteID, ncol=1, scales="free_y")+
  scale_y_log10()+
  labs(title="Continuous Discharge for Water Years 2022-2024",
       y= "Discharge (L/s)", x="Date")



## ----aos-ais-plot, out.width='100%', out.height='600px', fig.height=4, fig.width=8----------
for(s in 1:length(siteList)){
  # begin the plot code
  AOS_AIS_plot <- csd_15_min%>%
    filter(siteID==siteList[s])%>%
    plot_ly()%>%
    # add trace for continuous discharge
    add_trace(x=~startDateTime, y=~dischargeContinuous,
              type="scatter", mode="line",
              line=list(color='darkgray'),
              name="Discharge")%>%
    # add trace for Abun
    add_trace(data=inv_abundance_summ%>%
                filter(siteID==siteList[s]),
              x=~collectDate, y=~abun_M2_sum_mean,
              linetype=~paste0("Abun: ", habitatType),
              yaxis="y2", type="scatter", mode="line",
              error_y=~list(array=abun_M2_sum_se,
                            color='darkorange'),
              marker=list(color="darkorange"),
              line=list(color="darkorange"),
              visible="legendonly")%>%
    # add trace for Rich
    add_trace(data=inv_diversity_summ%>%
                filter(siteID==siteList[s]
                              &indexName=="richness"),
              x=~collectDate, y=~mean,
              linetype=~paste0("Rich: ", habitatType),
              yaxis="y3", type="scatter", mode="line",
              error_y=~list(array=se,
                            color='darkgreen'),
              marker=list(color="darkgreen"),
              line=list(color="darkgreen"),
              visible="legendonly")%>%
    # define the layout of the plot
    layout(
      title=paste0(siteList[s],
                  " Discharge w/ Macroinvertebrate Abundance & Richness"),
      # format x-axis
      xaxis=list(title="dateTime",
                 automargin=TRUE,
                 domain=c(0, 0.9)),
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
        title='Abundance Per Square Meter',
        showgrid=FALSE,
        automargin=TRUE,
        zeroline=FALSE,
        tickfont=list(color='darkorange'),
        titlefont=list(color='darkorange')),
      # format third y-axis
      yaxis3=list(
        side='right',
        overlaying="y",
        anchor="free",
        title='Taxon Richness',
        showgrid=FALSE,
        zeroline=FALSE,
        automargin=TRUE,
        tickfont=list(color='darkgreen'),
        titlefont=list(color='darkgreen'),
        position=0.99),
      # format legend
      legend=list(xanchor='center',
                  yanchor='top',
                  orientation='h',
                  x=0.5, y=-0.2),
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
  
  # Assign a site-specific plot for using in case studies
  assign(paste0("AOS_AIS_plot_", siteList[s]), AOS_AIS_plot)
  
  # Save HTML plot to local documents folder
  saveWidget(as_widget(AOS_AIS_plot), paste0("~/", siteList[s], "_INV_CSD.html"))
}



## ----case study 1 inputs, include=FALSE-----------------------------------------------------
siteList <- c("WLOU")
startWY <- 2022
endWY <- 2024
startWY_query <- paste0(startWY-1, "-10")
endWY_query <- paste0(endWY, "-09")


## ----download-swc, results='hide'-----------------------------------------------------------
# download data of interest - AOS - Chemical properties of surface water
swc <- loadByProduct(dpID="DP1.20093.001",
                     site=siteList, 
                     startdate=startWY_query,
                     enddate=endWY_query,
                     package="basic",
                     release= "current",
                     include.provisional=T,
                     token=Sys.getenv("NEON_TOKEN"),
                     check.size=F)

# unlist the variables and add to the global environment
list2env(swc, envir=.GlobalEnv)



## ----wrangle-plot-swc-----------------------------------------------------------------------
# check if there are duplicate DOC records
# what are the primary keys in swc_externalLabDataByAnalyte?
cat("Primary keys in swc_externalLabDataByAnalyte are:",
    paste(variables_20093$fieldName[
      variables_20093$table=="swc_externalLabDataByAnalyte"
      &variables_20093$primaryKey=="Y"
    ],
    collapse=", ")
    )

# identify duplicates in swc_externalLabDataByAnalyte
swc_externalLabDataByAnalyte_dups <- removeDups(swc_externalLabDataByAnalyte,
                                                variables_20093)

# no duplicates, great!

# lab data is published `long-format` with 28 analytes analyzed
# show all the analytes published in the lab data
print(unique(swc_externalLabDataByAnalyte$analyte))

# for this exercise, subset lab data to only dissolved organic carbon (DOC)
DOC <- swc_externalLabDataByAnalyte%>%
  filter(analyte=="DOC")

# plot a timeseries of DOC
DOC_plot <- DOC%>%
  ggplot(aes(x=collectDate, y=analyteConcentration))+
  geom_point()+
  labs(title="Dissolved organic carbon (DOC) over time",
       y="DOC (mg/L)",
       x="Date")

DOC_plot



## ----download-waq, results='hide'-----------------------------------------------------------
# download data of interest - AIS - Water quality
waq <- loadByProduct(dpID="DP1.20288.001",
                     site=siteList, 
                     startdate=startWY_query,
                     enddate=endWY_query,
                     package="basic",
                     release= "current",
                     include.provisional=T,
                     token=Sys.getenv("NEON_TOKEN"),
                     check.size=F)

# unlist the variables and add to the global environment
list2env(waq, envir=.GlobalEnv)



## ----wrangle-plot-waq-----------------------------------------------------------------------
# `waq_instantaneous` table published many water quality metrics in wide-format
# other than fDOM, many other metrics are published in `waq_instantaneous`
# including: dissolved oxygen, specific conductance, pH, chlorophyll, turbidity

# according to the NEON AIS spatial design, fDOM is only measured at the 
# downstream sensor set (S2, HOR=102); subset to HOR 102
WAQ_102 <- waq_instantaneous%>%
  filter(horizontalPosition==102)

# `waq_instantaneous` is published at a 1 minute temporal resolution
# for ease of plotting, let's create a 15-minute average table
fDOM_15min <- WAQ_102%>%
  
  # remove NULL records
  filter(!is.na(rawCalibratedfDOM))%>%
  
  # remove records with a final QF
  filter(fDOMFinalQF==0)%>%
  
  # create 15-minute average of fDOM
  mutate(roundDate=round_date(endDateTime, "15 min"))%>%
  group_by(siteID, roundDate)%>%
  summarize(mean_fDOM=mean(rawCalibratedfDOM))

# plot a timeseries of fDOM
fDOM_plot <- fDOM_15min%>%
  ggplot(aes(x=roundDate, y=mean_fDOM))+
  geom_line()+
  labs(title="fluorescent dissolved organic matter (fDOM) over time",
       y="fDOM (QSU)",
       x="Date")

fDOM_plot



## ----join-aos-ais---------------------------------------------------------------------------
# round DOC `collectDate` to the nearest 15 minute timestamp
DOC$roundDate <- round_date(DOC$collectDate, "15 min")

# perform a left-join, which will join an AIS DOC record to every AIS fDOM 
# record based on matching timestamps
fDOM_DOC_join <- left_join(fDOM_15min, DOC, by="roundDate")


## ----linear-regression----------------------------------------------------------------------
# use `lm` function to create a linear regression: DOC~fDOM
model <- lm(analyteConcentration~mean_fDOM, data=fDOM_DOC_join)

# view a summary of the regression model
print(summary(model))

# show a plot of the relationship with a linear trendline added
fDOM_DOC_plot <- fDOM_DOC_join%>%
  ggplot(aes(x=mean_fDOM, y=analyteConcentration))+
  geom_point()+
  geom_smooth(method="lm", se=T)+
  scale_x_continuous(limits=c(0, 60))+
  labs(title="AOS-DOC vs. AIS-fDOM",
       y="DOC (mg/L)",
       x="fDOM (QSU)")

fDOM_DOC_plot



## ----model-doc------------------------------------------------------------------------------
# predict continuous doc based on the linear regression model coefficients
fDOM_DOC_join$fit <- predict(model,
                             newdata=fDOM_DOC_join,
                             interval="confidence")[, "fit"]

# add two more columns with predicted 95% CI uncertainty around the modeled DOC
conf_int <- predict(model, newdata=fDOM_DOC_join, interval="confidence")
fDOM_DOC_join$lwr <- conf_int[, "lwr"]
fDOM_DOC_join$upr <- conf_int[, "upr"]



## ----plot-model-doc-------------------------------------------------------------------------
# create plot
fDOM_DOC_plot <- plot_ly(data=fDOM_DOC_join)%>%
  
  # plot uncertainty as a ribbon
  add_trace(x=~roundDate, y=~upr, name="95% CI",
            type='scatter', mode='line',
            line=list(color='lightgray'), legendgroup="95CI",
            showlegend=F)%>%
  add_trace(x=~roundDate, y=~lwr, name="95% CI",
            type='scatter', mode='none', fill='tonexty',
            fillcolor='lightgray', legendgroup="95CI")%>%
  
  # plot modeled DOC timeseries
  add_trace(x=~roundDate, y=~fit, name="Modeled DOC",
            type='scatter', mode='line',
            line=list(color='blue'))%>%
  
  # plot grab sample DOC
  add_trace(x=~roundDate, y=~analyteConcentration, name="Grab Sample DOC",
            type='scatter', mode='markers',
            marker=list(color='darkorange'))%>%
  
  # format title, axes, and legend
  layout(title="Dissolved Organic Carbon: Modelled & Grab Sample",
         xaxis=list(title="Date"),
         yaxis=list(title="DOC (mg/L)"),
         legend=list(xanchor='center',
                     yanchor='top',
                     orientation='h',
                     x=0.5, y=-0.2))

# Save HTML plot to local documents folder
saveWidget(as_widget(fDOM_DOC_plot), paste0("~/", siteList, "_fDOM_DOC_model.html"))



## ----case study 2 inputs, include=FALSE-----------------------------------------------------
siteList <- c("CUPE", "GUIL")
startWY <- 2022
endWY <- 2024
startWY_query <- paste0(startWY-1, "-10")
endWY_query <- paste0(endWY, "-09")


## ----case study 2 fiona---------------------------------------------------------------------
# identify the date of Fiona
fionaDate <- "2022-09-19"

# highlight Fiona at CUPE
AOS_AIS_plot_CUPE_Fiona <- AOS_AIS_plot_CUPE%>%
  # add dashed vertical line to plot created in previous exercise
  add_segments(x=as.POSIXct(fionaDate, tz="UTC"),
               xend=as.POSIXct(fionaDate, tz="UTC"),
               y=0,
               yend=max(csd_15_min$dischargeContinuous[
                 csd_15_min$siteID=="CUPE"],
                 na.rm=T),
               name="Fiona",
               line=list(color='red', dash='dash'))
# Save HTML plot to local documents folder
saveWidget(as_widget(AOS_AIS_plot_CUPE_Fiona), "~/CUPE_INV_CSD_Fiona.html")

# highlight Fiona at GUIL
AOS_AIS_plot_GUIL_Fiona <- AOS_AIS_plot_GUIL%>%
  # add dashed vertical line to plot created in previous exercise
  add_segments(x=as.POSIXct(fionaDate, tz="UTC"),
               xend=as.POSIXct(fionaDate, tz="UTC"),
               y=0,
               yend=max(csd_15_min$dischargeContinuous[
                 csd_15_min$siteID=="GUIL"],
                 na.rm=T),
               name="Fiona",
               line=list(color='red', dash='dash'))
# Save HTML plot to local documents folder
saveWidget(as_widget(AOS_AIS_plot_GUIL_Fiona), "~/GUIL_INV_CSD_Fiona.html")



## ----download-data-geo, results='hide'------------------------------------------------------
# download data of interest - AOS - Stream morphology maps
# the expanded download package is needed to read in the geo_pebbleCount table
geo <- loadByProduct(dpID="DP4.00131.001",
                     site=siteList, 
                     startdate=startWY_query,
                     enddate=endWY_query,
                     package="expanded",
                     release= "current",
                     include.provisional=T,
                     token=Sys.getenv("NEON_TOKEN"),
                     check.size=F)

# unlist the variables and add to the global environment
list2env(geo, envir=.GlobalEnv)



## ----id-dups-geo----------------------------------------------------------------------------
# what are the primary keys in geo_pebbleCount?
cat("Primary keys in geo_pebbleCount are:",
    paste(variables_00131$fieldName[
      variables_00131$table=="geo_pebbleCount"
      &variables_00131$primaryKey=="Y"
    ],
    collapse=", ")
    )
# identify duplicates in geo_pebbleCount
geo_pebbleCount_dups <- removeDups(geo_pebbleCount,variables_00131)


## ----wrangle-plot-geo-----------------------------------------------------------------------
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
  group_by(siteID, surveyEndDate, eventID, pebbleSize_num)%>%
  summarise(frequency=n()/200)

# calculate a cumulative sum of frequency per event ID
for(e in 1:length(unique(geo_pebbleCount_freq$eventID))){
  eventID_freq <- geo_pebbleCount_freq%>%
    filter(eventID==unique(geo_pebbleCount$eventID)[e])
  eventID_freq$CumulativeFreq <- cumsum(eventID_freq$frequency)*100
  if(e==1){
    geo_pebbleCount_freqCumm <- eventID_freq
  }else{
    geo_pebbleCount_freqCumm <- rbind(geo_pebbleCount_freqCumm, eventID_freq)
  }
}

# assign a year to each survey
geo_pebbleCount_freqCumm <- geo_pebbleCount_freqCumm%>%
  mutate(year=format(surveyEndDate, "%Y"))

# create cumulative frequency curve plot using `geom_smooth`
geo_pebbleCount_freqCumm%>%
  ggplot(aes(x=pebbleSize_num, y=CumulativeFreq, color=year)) +
  geom_smooth(method="loess", se=T, linewidth=0.75) +
  labs(title="Cumulative Particle Size Distribution by Year",
       x="Particle Size (mm)", y="Cumulative Frequency (%)") +
  facet_wrap(~siteID)



## ----highlight-fiona-psd, out.width='100%', out.height='800px'------------------------------
# generate small, simple subplots of each pebble count survey
# loop through each site and year to make plot and save to the working directory
for(s in 1:length(unique(geo_pebbleCount_freqCumm$siteID))){
  currSite <- unique(geo_pebbleCount_freqCumm$siteID)[s]
  for(y in 1:length(unique(geo_pebbleCount_freqCumm$year))){
    currYear <- unique(geo_pebbleCount_freqCumm$year)[y]
    currPlot <- geo_pebbleCount_freqCumm%>%
      filter(siteID==currSite
                    &year==currYear)%>%
      ggplot(aes(x=pebbleSize_num, y=CumulativeFreq)) +
      geom_smooth(method="loess", se=T, linewidth=0.75) +
      labs(x=NULL, y=NULL)+
      scale_y_continuous(limits=c(0, 105))+
      scale_x_continuous(limits=c(0, 260))+
      theme_bw()+
      theme(text=element_text(size=18))
    ggsave(plot=currPlot,
                    filename=paste0("~/images/psd_", currSite, currYear, ".png"),
                    width=4, height=7, units="cm")
  }
}

# re-generate the CUPE plot with particle size distribution subplots added
AOS_AIS_plot_CUPE_Fiona <- AOS_AIS_plot_CUPE_Fiona%>%
  layout(images=list(
    # show the CUPE 2022 pebble count survey, conducted 2022-04
    list(source=dataURI(file="~/images/psd_CUPE2022.png"),
         x=0.05, y=0.7, 
         sizex=0.25, sizey=0.25,
         xref="paper", yref="paper", 
         xanchor="left", yanchor="bottom"),
    # show the CUPE 2023 pebble count survey, conducted 2022-05
    list(source=dataURI(file="~/images/psd_CUPE2023.png"),
         x=0.4, y=0.7, 
         sizex=0.25, sizey=0.25,
         xref="paper", yref="paper", 
         xanchor="left", yanchor="bottom"),
    # show the CUPE 2024 pebble count survey, conducted 2022-05
    list(source=dataURI(file="~/images/psd_CUPE2024.png"),
         x=0.7, y=0.7, 
         sizex=0.25, sizey=0.25,
         xref="paper", yref="paper", 
         xanchor="left", yanchor="bottom")
    
    ))
# Save HTML plot to local documents folder
saveWidget(as_widget(AOS_AIS_plot_CUPE_Fiona), "~/CUPE_INV_CSD_GEO_Fiona.html")

# re-generate the GUIL plot with particle size distribution subplots added
AOS_AIS_plot_GUIL_Fiona <- AOS_AIS_plot_GUIL_Fiona%>%
  layout(images=list(
    # show the GUIL 2022 pebble count survey, conducted 2022-04
      list(source=dataURI(file="~/images/psd_GUIL2022.png"),
         x=0.05, y=0.7, 
         sizex=0.25, sizey=0.25,
         xref="paper", yref="paper", 
         xanchor="left", yanchor="bottom"),
    # show the GUIL 2023 pebble count survey, conducted 2023-03
    list(source=dataURI(file="~/images/psd_GUIL2023.png"),
         x=0.35, y=0.7, 
         sizex=0.25, sizey=0.25,
         xref="paper", yref="paper", 
         xanchor="left", yanchor="bottom"),
    # show the GUIL 2024 pebble count survey, conducted 2024-07
    list(source=dataURI(file="~/images/psd_GUIL2024.png"),
         x=0.75, y=0.7, 
         sizex=0.25, sizey=0.25,
         xref="paper", yref="paper", 
         xanchor="left", yanchor="bottom")
    
    ))
# Save HTML plot to local documents folder
saveWidget(as_widget(AOS_AIS_plot_GUIL_Fiona), "~/_INV_CSD_GEO_Fiona.html")



## ----case study 3 inputs, include=FALSE-----------------------------------------------------
# Run code in the background that repeats intro to AOS and AIS for case study
siteList <- c("KING", "ARIK", "SYCA")
startWY <- 2022
endWY <- 2025
startWY_query <- paste0(startWY-1, "-10")
endWY_query <- paste0(endWY, "-09")
inv <- loadByProduct(dpID="DP1.20120.001",
                     site=siteList, 
                     startdate=startWY_query,
                     enddate=endWY_query,
                     package="basic",
                     release= "current",
                     include.provisional=T,
                     token=Sys.getenv("NEON_TOKEN"),
                     check.size=F)
list2env(inv, envir=.GlobalEnv)
inv_fieldTaxJoined <- joinTableNEON(inv_fieldData, inv_taxonomyProcessed)
sampler_habitat_summ <- inv_fieldTaxJoined%>%
  distinct(siteID, habitatType)
sampler_habitat_summ  
inv_abundance_summ <- inv_fieldTaxJoined%>%
  filter(is.na(samplingImpractical)&!grepl("GRAB|BRYOZOAN", sampleID))%>%
  mutate(abun_M2=estimatedTotalCount/benthicArea)%>%
  rename(collectDate=collectDate.x)%>%
  group_by(siteID, collectDate, eventID, sampleID, habitatType, boutNumber)%>%
  summarize(abun_M2_sum=sum(abun_M2, na.rm=TRUE))%>%
  group_by(siteID, collectDate, eventID, habitatType, boutNumber)%>%
  summarise(across(abun_M2_sum, 
                   list(mean=mean, sd=sd, 
                        se=~sd(.x, na.rm=TRUE)/sqrt(n())),
                   .names="{.col}_{.fn}"))%>%
  mutate(year=substr(eventID, 6, 9),
                yearBout=paste(year, "Bout", boutNumber, sep="."))
inv_richness_clean <- inv_fieldTaxJoined%>%
  filter(is.na(samplingImpractical)&!grepl("GRAB|BRYOZOAN", sampleID))%>%
  rename(collectDate=collectDate.x)
inv_sample_info <- inv_richness_clean%>%
  select(sampleID, domainID, siteID, namedLocation, 
         collectDate, eventID, boutNumber, 
         habitatType, samplerType, benthicArea)%>%
  distinct()
inv_rare_taxa <- inv_richness_clean%>%
  distinct(sampleID, acceptedTaxonID, scientificName)%>%
  group_by(scientificName)%>%
  summarize(occurrences=n())%>%
  filter(occurrences > 2)
inv_richness_clean <- inv_richness_clean %>%
  filter(scientificName%in%inv_rare_taxa$scientificName) 
inv_richness_clean_wide <- inv_richness_clean %>%
  distinct(sampleID, scientificName, .keep_all=T)%>%
  mutate(abun_M2=estimatedTotalCount/benthicArea)%>%
  filter(!is.na(abun_M2))%>%
  pivot_wider(id_cols=sampleID, 
              names_from=scientificName,
              values_from=abun_M2,
              values_fill=list(abun_M2=0),
              values_fn=list(abun_M2=sum)) %>%
  column_to_rownames(var="sampleID") %>%
  round()
if(colSums(inv_richness_clean_wide) %>% min()==0){
  stop("Column sum is 0: do not proceed with richness analysis!")
}
if(rowSums(inv_richness_clean_wide) %>% min()==0){
  stop("Row sum is 0: do not proceed with richness analysis!")
}
inv_richness <- as.data.frame(specnumber(
  inv_richness_clean_wide)
  )
names(inv_richness) <- "richness"
inv_richness_stats <- estimateR(inv_richness_clean_wide)
inv_evenness <- as.data.frame(
  diversity(inv_richness_clean_wide)/log(specnumber(inv_richness_clean_wide))
  )
names(inv_evenness) <- "evenness"
inv_shannon <- as.data.frame(
  diversity(inv_richness_clean_wide, index="shannon")
  )
names(inv_shannon) <- "shannon"
inv_simpson <- as.data.frame(
  diversity(inv_richness_clean_wide, index="simpson")
  )
names(inv_simpson) <- "simpson"
inv_diversity_indices <- cbind(inv_richness, inv_evenness, inv_shannon, inv_simpson)
inv_diversity_indices <- left_join(rownames_to_column(inv_diversity_indices),
                                   inv_sample_info,
                                   by=c("rowname"="sampleID")) %>%
  rename(sampleID=rowname)
inv_diversity_summ <- inv_diversity_indices%>%
  pivot_longer(c(richness, evenness, shannon, simpson),
                      names_to="indexName",
                      values_to="indexValue")%>%
  group_by(siteID, collectDate, eventID, habitatType, boutNumber, indexName)%>%
  summarize(mean=mean(indexValue),
                   n=n(),
                   sd=sd(indexValue),
                   se=sd/sqrt(n))%>%
  mutate(year=substr(eventID, 6, 9),
                yearBout=paste(year, "Bout", boutNumber, sep="."))
csd <- loadByProduct(dpID="DP4.00130.001",
                     site=siteList, 
                     startdate=startWY_query,
                     enddate=endWY_query,
                     package="basic",
                     release= "current",
                     include.provisional=T,
                     token=Sys.getenv("NEON_TOKEN"),
                     check.size=F)
list2env(csd, .GlobalEnv)



## ----case study 3 wrangle-------------------------------------------------------------------
# Assign each discharge record a water year
csd_15_min <- csd_15_min%>%
  mutate(waterYear=ifelse(month(startDateTime)>=10,
                          year(startDateTime)+1,
                          year(startDateTime)),
         waterYearStart=as.Date(paste0(waterYear-1, "-10-01")),
         dayOfWaterYear=as.integer(as.Date(startDateTime)-waterYearStart)+1,
         plotDateWY=as.Date("1999-10-01") + (dayOfWaterYear-1))

# Group by site ID and water year and summarize a cumulative sum of discharge to make a cumulative flow curve
csd_15_min_summ <- csd_15_min%>%
  arrange(siteID, waterYear, startDateTime)%>%
  group_by(siteID, waterYear)%>%
  mutate(cumulativeFlow=cumsum(dischargeContinuous),
         cumulativeFlowPct=100*cumulativeFlow/max(cumulativeFlow, na.rm=TRUE))%>%
  ungroup()

# Assign water year and day-of-water-year to invert abundance summary
inv_abundance_case2 <- inv_abundance_summ%>%
  ungroup()%>%
  mutate(waterYear=ifelse(month(collectDate)>=10,
                          year(collectDate)+1,
                          year(collectDate)),
         waterYearStart=as.Date(paste0(waterYear-1, "-10-01")),
         dayOfWaterYear=as.integer(as.Date(collectDate)-waterYearStart)+1,
         plotDateWY=as.Date("1999-10-01") + (dayOfWaterYear-1),
         abun_M2_sum_se=coalesce(abun_M2_sum_se, 0))%>%
  arrange(siteID, waterYear, habitatType, dayOfWaterYear)

# Assign water year and day-of-water-year to invert richness summary
inv_richness_case2 <- inv_diversity_summ%>%
  filter(indexName=="richness")%>%
  ungroup()%>%
  mutate(waterYear=ifelse(month(collectDate)>=10,
                          year(collectDate)+1,
                          year(collectDate)),
         waterYearStart=as.Date(paste0(waterYear-1, "-10-01")),
         dayOfWaterYear=as.integer(as.Date(collectDate)-waterYearStart)+1,
         plotDateWY=as.Date("1999-10-01") + (dayOfWaterYear-1),
         se=coalesce(se, 0))%>%
  arrange(siteID, waterYear, habitatType, dayOfWaterYear)


## ----case study 3 plot----------------------------------------------------------------------
# Build one stacked plot per site with cumulative flow, abundance, and richness
for(s in 1:length(siteList)){
  waterYears <- sort(
    unique(csd_15_min_summ$waterYear[csd_15_min_summ$siteID==siteList[s]]))

  # Set fixed axis ranges for this site so all WY panels are directly comparable
  site_flow <- csd_15_min_summ%>%
    filter(siteID==siteList[s])
  site_abun <- inv_abundance_case2%>%
    filter(siteID==siteList[s])
  site_rich <- inv_richness_case2%>%
    filter(siteID==siteList[s])
  abun_labels <- sort(unique(paste0("Abun: ", site_abun$habitatType)))
  rich_labels <- sort(unique(paste0("Rich: ", site_rich$habitatType)))
  x_range <- range(site_flow$plotDateWY, na.rm=TRUE)
  y1_range <- c(0, max(site_flow$cumulativeFlow, na.rm=TRUE))
  abun_upper <- c(site_abun$abun_M2_sum_mean + site_abun$abun_M2_sum_se,
                  site_abun$abun_M2_sum_mean)
  if(all(is.na(abun_upper))){
    y2_range <- c(0, 1)
  }else{
    y2_range <- c(0, max(abun_upper, na.rm=TRUE))
  }
  rich_upper <- c(site_rich$mean + site_rich$se,
                  site_rich$mean)
  if(all(is.na(rich_upper))){
    y3_range <- c(0, 1)
  }else{
    y3_range <- c(0, max(rich_upper, na.rm=TRUE))
  }
  
  # Create each subplot and store in list
  wyPlots <- list()
  for(wy in 1:length(waterYears)){
    # Subset down to current site and water year
    cumsumPlot <- plot_ly(data=csd_15_min_summ%>%
                            filter(siteID==siteList[s]
                                   &waterYear==waterYears[wy]))%>%
      # Cumulative flow curve
      add_trace(x=~plotDateWY,
                y=~cumulativeFlow,
                type="scatter",
                mode="lines",
                line=list(color="darkgray"),
                name="Cumulative Flow",
                showlegend=F)%>%
      # Benthic macroinvertebrate abundance by habitat type
      add_trace(data=inv_abundance_case2%>%
                  filter(siteID==siteList[s]
                                &waterYear==waterYears[wy]),
                x=~plotDateWY,
                y=~abun_M2_sum_mean,
                split=~paste0("Abun: ", habitatType),
                linetype=~paste0("Abun: ", habitatType),
                yaxis="y2",
                type="scatter",
                mode="lines+markers",
                error_y=~list(array=abun_M2_sum_se,
                              color='darkorange',
                              visible=TRUE),
                marker=list(color="darkorange"),
                line=list(color="darkorange", width=2),
                showlegend=F)%>%
      # Benthic macroinvertebrate richness by habitat type
      add_trace(data=inv_richness_case2%>%
                  filter(siteID==siteList[s]
                                &waterYear==waterYears[wy]),
                x=~plotDateWY,
                y=~mean,
                split=~paste0("Rich: ", habitatType),
                linetype=~paste0("Rich: ", habitatType),
                yaxis="y3",
                type="scatter",
                mode="lines+markers",
                error_y=~list(array=se,
                              color='darkgreen',
                              visible=TRUE),
                marker=list(color="darkgreen"),
                line=list(color="darkgreen", width=2),
                showlegend=F)%>%
      # Plot layout
      layout(
        title=paste0(siteList[s], " | WY ", waterYears[wy]),
        xaxis=list(title="Month-Day",
                   automargin=TRUE,
                   domain=c(0, 0.9),
             range=x_range,
             type="date",
             tick0="1999-10-01",
             dtick="M1",
             tickformat="%m-%d"),
        yaxis=list(
          side='left',
          title='Cumulative Flow (L/s)',
          showgrid=FALSE,
          zeroline=FALSE,
          automargin=TRUE,
          range=y1_range),
        yaxis2=list(
          side='right',
          overlaying="y",
          title='Abundance Per Square Meter',
          showgrid=FALSE,
          automargin=TRUE,
          zeroline=FALSE,
          range=y2_range,
          tickfont=list(color='darkorange'),
          titlefont=list(color='darkorange')),
        yaxis3=list(
          side='right',
          overlaying="y",
          anchor="free",
          title='Taxon Richness',
          showgrid=FALSE,
          zeroline=FALSE,
          automargin=TRUE,
          range=y3_range,
          tickfont=list(color='darkgreen'),
          titlefont=list(color='darkgreen'),
          position=0.99)
      )

    wyPlots[[wy]] <- cumsumPlot
  }
  
  # Create customized legend that will link to traces on all plots
  # Uses a combination of HTML tools and custom JavaScript
  legend_items <- c(
    list(tags$button(
      type="button",
      class="case2-legend-item active",
      `data-trace-name`="Cumulative Flow",
      HTML("<span style='display:inline-block;width:18px;border-top:3px solid darkgray;margin-right:6px;vertical-align:middle;'></span>Cumulative Flow")
    )),
    lapply(abun_labels, function(lbl) {
      tags$button(
        type="button",
        class="case2-legend-item active",
        `data-trace-name`=lbl,
        HTML(paste0("<span style='display:inline-block;width:18px;border-top:3px solid darkorange;margin-right:6px;vertical-align:middle;'></span>", lbl))
      )
    }),
    lapply(rich_labels, function(lbl) {
      tags$button(
        type="button",
        class="case2-legend-item active",
        `data-trace-name`=lbl,
        HTML(paste0("<span style='display:inline-block;width:18px;border-top:3px solid darkgreen;margin-right:6px;vertical-align:middle;'></span>", lbl))
      )
    })
  )
  legendSyncJs <- sprintf(
    paste(
      "(function(){",
      "  var container=document.getElementById('case2_%s');",
      "  if (!container || container.dataset.legendBound === '1') return;",
      "  container.dataset.legendBound='1';",
      "  container.addEventListener('click', function(ev){",
      "    var btn=ev.target.closest('.case2-legend-item');",
      "    if (!btn) return;",
      "    var traceName=btn.getAttribute('data-trace-name');",
      "    var hideTrace=!btn.classList.contains('inactive');",
      "    var newVis=hideTrace ? false : true;",
      "    var plots=container.querySelectorAll('.js-plotly-plot');",
      "    plots.forEach(function(gd){",
      "      var idx=[];",
      "      for (var i=0; i < gd.data.length; i++) {",
      "        if (gd.data[i].name === traceName) idx.push(i);",
      "      }",
      "      if (idx.length) Plotly.restyle(gd, {visible: newVis}, idx);",
      "    });",
      "    btn.classList.toggle('inactive');",
      "  });",
      "})();",
      sep="\n"
    ),
    siteList[s]
  )
  
  # Build final stacked plots
  curr_plot <- tagList(
    tags$h3(
      paste0("Cumulative Flow, Abundance, and Richness for ",
             siteList[s], " (Stacked by Water Year)")
    ),
    div(
      id=paste0("case2_", siteList[s]),
      tags$div(
        style=paste(
          "display:flex;flex-wrap:wrap;gap:8px;align-items:center;",
          "padding:8px 10px;margin:0 0 8px 0;background:#ffffff;",
          "border:1px solid #d9d9d9;border-radius:4px;"
        ),
        legend_items
      ),
      tags$style(HTML(
        ".case2-legend-item {background:#fff;border:1px solid #cfcfcf;border-radius:4px;padding:4px 8px;cursor:pointer;font-size:12px;}\n.case2-legend-item.inactive {opacity:0.45;}"
      )),
      wyPlots
    ),
    tags$script(HTML(legendSyncJs))
  )

  # Save HTML plot to local documents folder
  output_file <- file.path(path.expand("~"), paste0(siteList[s], "_cumSumWY.html"))
  save_html(
    browsable(curr_plot),
    file=output_file,
    libdir=paste0(siteList[s], "_cumSumWY_files")
  )
}


