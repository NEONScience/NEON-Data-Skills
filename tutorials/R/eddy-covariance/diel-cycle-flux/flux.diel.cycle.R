## ----install-load-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#Required R packages
packReq <- c("BiocManager", "rhdf5", 'neonUtilities', 'ggplot2','tidyverse', "lubridate")

#Install and load all required packages
lapply(packReq, function(x) {
  if(require(x, character.only = TRUE) == FALSE) {
    install.packages(x)
    library(x, character.only = TRUE)
  }})

options(stringsAsFactors=F)



## ----download, results="hide", message=FALSE--------------------------------------------------------------------------------------------------------------------------------------------------

#Target dates
startDate <- "2022-04"
endDate <- "2022-09"

#Site
site <- c("STEI", "TREE")

#File directory
dirFile <- c(tempdir(),"/home/ddurden/eddy/tmp/tutorial")[2]

zipsByProduct(dpID="DP4.00200.001", package="basic", 
              site=site, 
              startdate=startdate, enddate=enddate,
              savepath=dirFile, 
              check.size=FALSE)



## ----stack-dp04, results="hide"---------------------------------------------------------------------------------------------------------------------------------------------------------------

flux <- neonUtilities::stackEddy(filepath=paste0(dirFile,"/filesToStack00200"),
                  level="dp04")



## ----see-variables----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

flux$variables



## ----plot-fluxes------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

flux$STEI$Site <- "STEI"
flux$TREE$Site <- "TREE"

dfFlux <- rbind.data.frame(flux$STEI, flux$TREE)
dfFlux$Site <- as.factor(dfFlux$Site)

dfFlux %>% 
    ggplot(aes(timeBgn, data.fluxCo2.turb.flux, color=factor(qfqm.fluxCo2.turb.qfFinl) )) +
    geom_point() + 
    scale_color_brewer(palette="Set2", name="qfFinal") +
    facet_grid(~Site) 
    



## ----mean-qfqm--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

dfFlux %>% group_by(Site) %>% summarise(mean(qfqm.fluxCo2.turb.qfFinl))



## ----plot-qfqm--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
dfFlux %>% 
  select(contains("qfqm")) %>% 
    pivot_longer(cols = everything(), names_to = "var") %>% 
      group_by(var) %>%  
        summarise(mean_var = mean(value) * 100) %>% 
          ggplot(aes(x = var, y = mean_var, fill = var)) + 
          geom_col() + 
          guides(x = guide_axis(angle = 90)) + 
          labs(x="Variable", y="Percent qfFinal failed") + 
          scale_fill_brewer(palette="RdYlBu")
    



## ----qfqm-remove------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

dfFlux %>% select(contains("qfqm") & contains("fluxCO2"))  %>% summarise_each(sum)
dfFlux %>% select(contains("data") & contains("fluxCO2")) %>% summarise_each(funs(sum(is.na(.))))

dfFlux$data.fluxCo2.turb.flux[(which(dfFlux$qfqm.fluxCo2.turb.qfFinl== 1))] <- NaN
dfFlux$data.fluxCo2.stor.flux[(which(dfFlux$qfqm.fluxCo2.stor.qfFinl== 1))] <- NaN
dfFlux$data.fluxCo2.nsae.flux[(which(dfFlux$qfqm.fluxCo2.nsae.qfFinl== 1))] <- NaN
   
dfFlux %>% select(contains("qfqm") & contains("fluxCO2"))  %>% summarise_each(sum)
dfFlux %>% select(contains("data") & contains("fluxCO2")) %>% summarise_each(funs(sum(is.na(.))))
 



## ----plot-diel-cycle--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

dfFlux$hour <- factor(lubridate::hour(dfFlux$timeBgn))

ggplot(dfFlux, aes(x = hour, y = data.fluxCo2.turb.flux, fill = Site)) +
  geom_boxplot() +
  stat_summary(fun = median, geom = 'line', aes(group = Site, colour = Site)) 



## ----plot-diel-lst----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fileMeta <- list.files(dirFile, pattern = paste0(".*",site[1],".*.h5"), recursive = TRUE, full.names = TRUE)[1]

siteMeta <- h5readAttributes(fileMeta, name = site[1])

siteMeta 

dfFlux$timeBgnLst <- dfFlux$timeBgn + lubridate::hours(siteMeta$TimeDiffUtcLt)
dfFlux$hourLst <- factor(lubridate::hour(dfFlux$timeBgnLst))

ggplot(dfFlux, aes(x = hourLst, y = data.fluxCo2.turb.flux, fill = Site)) +
  geom_boxplot() +
  stat_summary(fun = median, geom = 'line', aes(group = Site, colour = Site)) +
  scale_y_continuous(limits = quantile(dfFlux$data.fluxCo2.turb.flux, c(0.001, 0.999), na.rm = TRUE))



## ----plot-diel-stor---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ggplot(dfFlux, aes(x = hourLst, y = data.fluxCo2.stor.flux, fill = Site)) +
  geom_boxplot() +
  stat_summary(fun = median, geom = 'line', aes(group = Site, colour = Site)) +
  scale_y_continuous(limits = quantile(dfFlux$data.fluxCo2.stor.flux, c(0.001, 0.999), na.rm = TRUE))



## ----plot-diel-nsae---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ggplot(dfFlux, aes(x = hourLst, y = data.fluxCo2.nsae.flux, fill = Site)) +
  geom_boxplot() +
  stat_summary(fun = median, geom = 'line', aes(group = Site, colour = Site)) +
  scale_y_continuous(limits = quantile(dfFlux$data.fluxCo2.nsae.flux, c(0.001, 0.999), na.rm = TRUE))



## ----mean-nsae--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


dfFlux %>% 
  select(contains("data.fluxCo2") | "Site") %>% 
      group_by(Site) %>% 
        summarise_each(funs(mean(., na.rm = TRUE)))



