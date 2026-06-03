## ----install-load, results='hide', message=FALSE, warning=FALSE, eval=7:8---------------------------------------------------

install.packages('BiocManager')
BiocManager::install('rhdf5')
install.packages('neonUtilities')
install.packages('ggplot2')
install.packages('dplyr')
install.packages('tidyr')

library(neonUtilities)
library(rhdf5)
library(ggplot2)
library(dplyr)
library(tidyr)



## ----download, results="hide", message=FALSE--------------------------------------------------------------------------------

token <- Sys.getenv("NEON_TOKEN")

startDate <- "2022-04"
endDate <- "2022-09"

site <- c("STEI", "TREE")

dirFile <- getwd()

zipsByProduct(dpID="DP4.00200.001", package="basic", 
              site=site, 
              startdate=startDate, 
              enddate=endDate,
              savepath=dirFile, 
              check.size=FALSE,
              token=token)



## ----stack-dp04, results="hide", message=FALSE------------------------------------------------------------------------------

flux <- stackEddy(filepath=paste0(dirFile,
                                  "/filesToStack00200"),
                  level="dp04")



## ----see-variables----------------------------------------------------------------------------------------------------------

flux$variables



## ----plot-fluxes------------------------------------------------------------------------------------------------------------

flux$STEI$Site <- "STEI"
flux$TREE$Site <- "TREE"

dfFlux <- rbind.data.frame(flux$STEI, flux$TREE)

dfFlux %>% 
    ggplot(aes(timeBgn, 
               data.fluxCo2.turb.flux, 
               color=factor(qfqm.fluxCo2.turb.qfFinl) )) +
    geom_point() + 
    scale_color_brewer(palette="Set2", 
                       name="qfFinal") +
    facet_grid(~Site) 
    



## ----mean-qfqm--------------------------------------------------------------------------------------------------------------

dfFlux %>% 
  group_by(Site) %>% 
  summarise(mean(qfqm.fluxCo2.turb.qfFinl))



## ----plot-qfqm--------------------------------------------------------------------------------------------------------------

dfFlux %>% 
  select(contains("qfqm")) %>% 
    pivot_longer(cols = everything(), 
                 names_to = "var") %>% 
      group_by(var) %>%  
        summarise(mean_var = mean(value) * 100) %>% 
          ggplot(aes(x = var, y = mean_var, 
                     fill = var)) + 
          geom_col() + 
          guides(x = guide_axis(angle = 90)) + 
          labs(x="Variable", 
               y="Percent qfFinal failed") + 
          scale_fill_brewer(palette="RdYlBu")
    



## ----qfqm-remove------------------------------------------------------------------------------------------------------------

dfFlux %>% 
  select(contains("qfqm") & 
           contains("fluxCO2")) %>% 
  summarise(across(everything(), sum))

dfFlux %>% 
  select(contains("data") & 
           contains("fluxCO2")) %>% 
  summarise(across(everything(), 
                   function(x) 
                     {sum(is.na(x))}))

dfFlux$data.fluxCo2.turb.flux[(which(dfFlux$qfqm.fluxCo2.turb.qfFinal==1))] <- NA
dfFlux$data.fluxCo2.stor.flux[(which(dfFlux$qfqm.fluxCo2.stor.qfFinal==1))] <- NA
dfFlux$data.fluxCo2.nsae.flux[(which(dfFlux$qfqm.fluxCo2.nsae.qfFinal==1))] <- NA
   
dfFlux %>% 
  select(contains("qfqm") & 
           contains("fluxCO2")) %>% 
  summarise(across(everything(), sum))

dfFlux %>% 
  select(contains("data") & 
           contains("fluxCO2")) %>% 
  summarise(across(everything(), 
                   function(x) 
                     {sum(is.na(x))}))
 



## ----plot-diel-cycle--------------------------------------------------------------------------------------------------------

dfFlux$hour <- factor(lubridate::hour(dfFlux$timeBgn))

ggplot(dfFlux, aes(x = hour, 
                   y = data.fluxCo2.turb.flux, 
                   fill = Site)) +
  geom_boxplot() +
  stat_summary(fun = median, 
               geom = 'line', 
               aes(group = Site, 
                   colour = Site)) 



## ----plot-diel-lst----------------------------------------------------------------------------------------------------------

fileMeta <- list.files(dirFile, 
                       pattern = paste0(".*", 
                                        site[1], 
                                        ".*.h5"), 
                       recursive = TRUE, 
                       full.names = TRUE)[1]

siteMeta <- h5readAttributes(fileMeta, 
                             name = site[1])

siteMeta 

dfFlux$timeBgnLst <- dfFlux$timeBgn + 
  lubridate::hours(siteMeta$TimeDiffUtcLt)
dfFlux$hourLst <- factor(lubridate::hour(dfFlux$timeBgnLst))

ggplot(dfFlux, aes(x = hourLst, 
                   y = data.fluxCo2.turb.flux, 
                   fill = Site)) +
  geom_boxplot() +
  stat_summary(fun = median, 
               geom = 'line', 
               aes(group = Site, 
                   colour = Site)) +
  scale_y_continuous(limits = quantile(dfFlux$data.fluxCo2.turb.flux, 
                                       c(0.001, 0.999), 
                                       na.rm = TRUE))



## ----plot-diel-stor---------------------------------------------------------------------------------------------------------

ggplot(dfFlux, aes(x = hourLst, 
                   y = data.fluxCo2.stor.flux, 
                   fill = Site)) +
  geom_boxplot() +
  stat_summary(fun = median, 
               geom = 'line', 
               aes(group = Site, 
                   colour = Site)) +
  scale_y_continuous(limits = quantile(dfFlux$data.fluxCo2.stor.flux, 
                                       c(0.001, 0.999), 
                                       na.rm = TRUE))



## ----plot-diel-nsae---------------------------------------------------------------------------------------------------------

ggplot(dfFlux, aes(x = hourLst, 
                   y = data.fluxCo2.nsae.flux, 
                   fill = Site)) +
  geom_boxplot() +
  stat_summary(fun = median, 
               geom = 'line', 
               aes(group = Site, 
                   colour = Site)) +
  scale_y_continuous(limits = quantile(dfFlux$data.fluxCo2.nsae.flux, 
                                       c(0.001, 0.999), 
                                       na.rm = TRUE))



## ----mean-nsae--------------------------------------------------------------------------------------------------------------


dfFlux %>% 
  select(contains("data.fluxCo2") | "Site") %>% 
      group_by(Site) %>% 
        summarise(across(everything(), mean,
                         na.rm=TRUE))



