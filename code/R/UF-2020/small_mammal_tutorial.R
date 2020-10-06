################ Small mammals ################
# Geraldine Klarenberg
# Explore NEON workshop for UF
# 1 July 2020

# Point out this lesson: https://www.neonscience.org/tm-data-management-small-mammal
# Excel-based, for (undergrad) students

# Load libraries
library(neonUtilities)
library(tidyverse)
library(lubridate)
library(rgdal)
library(sf)

# Use NEON shapefiles to make maps------------------------------------------------------------
# Download shapefiles from https://www.neonscience.org/data/about-data/spatial-data-maps
# NEON Terrestrial Field Site Boundaries - Shapefile
# NEON Terrestrial Observation System (TOS) sampling locations – Shapefile v8

# Load the NEON shapefiles
sample_bounds <- readOGR(dsn="Day3/Small_mammals/Shapefiles/Field_Sampling_Boundaries_2020", layer="terrestrialSamplingBoundaries")
field_sites <- readOGR(dsn="Day3/Small_mammals/Shapefiles/All_NEON_TOS_Plots_V8", layer="All_NEON_TOS_Plot_Polygons_V8")

# Extract only Florida (OSBS) data
sample_bounds_FL <- sample_bounds[which(sample_bounds$siteID=="OSBS"),] 
field_sites_FL <- field_sites[which(field_sites$siteID=="OSBS"),] 

plot(sample_bounds_FL)
plot(field_sites_FL) # this is ALL the sampling plots

# Select only small mammal
field_sites_FL_mammal <- field_sites_FL[which(field_sites_FL$subtype=="mammalGrid"),] 
plot(field_sites_FL_mammal)

# Convert to "simple features" so we can use ggplot for plotting
sample_bounds_FL2 <- st_as_sf(sample_bounds_FL)
field_sites_FL_mammal2 <- st_as_sf(field_sites_FL_mammal) # could've also used st_read() of the original shapefile to get this

general_map <- ggplot()+
  geom_sf(data=sample_bounds_FL2)+
  geom_sf(data=field_sites_FL_mammal2)+
  geom_text(data = field_sites_FL_mammal2, aes(longitude, latitude-0.002, label = plotID), size = 3)+
  theme_bw()+
  theme(axis.title.x=element_blank(), axis.title.y=element_blank())

# Download data ------------------------------------------------------------
zipsByProduct(dpID="DP1.10072.001", site="OSBS", check.size=TRUE,
              savepath = "Day3/Small_mammals")

# Unpack data ------------------------------------------------------------
stackByTable(filepath = "Day3/Small_mammals/filesToStack10072")

# Load the data ------------------------------------------------------------
mammal_data <- read.csv("Day3/Small_mammals/filesToStack10072/stackedFiles/mam_pertrapnight.csv")

# Select data we want to work with ------------------------------------------
mammal_data_select <- mammal_data %>% 
  select(plotID, nlcdClass, decimalLatitude, decimalLongitude, elevation, collectDate, taxonID,
         scientificName, taxonRank, nativeStatusCode, sex, recapture, larvalTicksAttached,
         nymphalTicksAttached, adultTicksAttached)
# the attached ticks data is scarce: only 1 for adults, 3 for nymphs and 4 for larvae

# Turn dates into "proper" dates ---------------------------------------------------
mammal_data_select$collectDate <- ymd(mammal_data_select$collectDate)
# Make year, month, day columns
mammal_data_select$year <- year(mammal_data_select$collectDate)
mammal_data_select$month <- month(mammal_data_select$collectDate)
mammal_data_select$day <- day(mammal_data_select$collectDate)

# Remove recaptures -------------------------------------------------------------
# I am removing recaptures from the same 3-day sampling period 
# (leaving in recaptures in next months)
mammal_data_select <- mammal_data_select %>% 
  filter(!(recapture == "Y" & 
             (year(collectDate) == year(collectDate) & month(collectDate) == month(collectDate)))) 
# remove if recapture is Y, and if the year and month are the same: in some cases
# there is an extra date in a month that they checked traps, and we only want monthly values. 

# Make summaries -------------------------------------------------------------
# See trapping protocol: there are 100 traps, set 3 nights in a row. So there should be ~300 observations
# for each sampling bout / month.
# Group by year, month, plots and species - and count these (do not use day, we're making monthly values)
species_count <- mammal_data_select %>% 
  group_by(year, month, plotID, taxonID) %>% 
  count(taxonID)
# Note: when checking this data, the counts do not always add up to 100 (or 300 for 3 days) because we
# removed the recaptures

# Make detection histories for each species (i.e. if nothing was caught, a zero is assigned for the
# species)
# Spread the tibble
species_count2 <- spread(species_count, taxonID, n) # should use pivot_wider nowadays...
# Replace NA with 0
species_count2[is.na(species_count2)] <- 0 
# Note that the column with NA (empty) counts is called "V1" now

# Create time series plots -------------------------------------------------------------
# Make plots per species, with lines for each plot
# Get the abbreviated names for the species
species_names <- names(species_count2)[5:ncol(species_count2)]

# Download lookup table of small mammal names:
download.file(url="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/master/code/R/UF-2020/smallmammals_trapped_listnames.csv", 
              destfile = "YOUR-PATH-HERE/smallmammals_trapped_listnames.csv")

# Use a lookup table to add the scientific names and popular names to the plots
# and maybe also the landscape
mammal_names <- read.csv("Day3/Small_mammals//smallmammals_trapped_listnames.csv")

# To make several plots, we will loop over the species names
# We will get species time series for each plotID
# First, add a column with dates
species_count2$date <- ymd(paste(species_count2$year, species_count2$month, "1", sep="/"))
# Turn tibble into dataframe (for some reason the tibble does not play nice in the loop)
species_count2 <- data.frame(species_count2)

for(i in 5:(4+length(species_names))){ # need to do this to loop over count columns properly
  mammal_name <- paste(mammal_names$popular_name[which(mammal_names$taxonID == species_names[i-4])],sep="")
  mammal_plot <- ggplot(species_count2,
                        aes(x=date, y=species_count2[,i]))+
    geom_point()+facet_wrap("plotID", ncol=1)+
    ylab(paste(mammal_name,"\nNumber of individuals trapped",sep=""))+
    xlab("Date")+
    scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))
  ggsave(filename = paste("Day3/Small_mammals/mammal_plot_",species_names[i-4],".pdf",sep=""),
         width=3, height=7,
         device="pdf") # not device = pdf, see https://github.com/daqana/tikzDevice/issues/181
}

# Specifically for tick research --------------------------------------------------------------------
# Select only species that occur abundantly, and where sites are close to / next to tick plots that actually have 
# ticks, 2,3,4 and 5 (this was determined in a different analysis, trust me :) )
species_count_selected <- species_count2 %>% 
  select(year, month, plotID, CRSP, GLVO, OCNU, PEGO, SIHI) %>%  # select species
  filter(plotID == "OSBS_002" | plotID == "OSBS_003" | plotID == "OSBS_004" | plotID == "OSBS_005") %>%  # select sites
  group_by(plotID, year, month) %>% 
  summarize(CRSP =sum(CRSP),
            GLVO = sum(GLVO),
            OCNU = sum(OCNU),
            PEGO = sum(PEGO),
            SIHI =sum(SIHI))

CRSP_plot <- ggplot(species_count_selected,
                    aes(x=ymd(paste(year, month, "1", sep="/")), y=CRSP))+
  geom_point()+facet_wrap("plotID", ncol=1)+
  ylab("Rodents (general)")+
  xlab("")+
  scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))+
  theme(text = element_text(size = 18))

GLVO_plot <- ggplot(species_count_selected,
                    aes(x=ymd(paste(year, month, "1", sep="/")), y=GLVO))+
  geom_point()+facet_wrap("plotID", ncol=1)+
  ylab("Southern flying squirrel (G volans)")+
  xlab("")+
  scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))+
  theme(text = element_text(size = 18))

OCNU_plot <- ggplot(species_count_selected,
                    aes(x=ymd(paste(year, month, "1", sep="/")), y=OCNU))+
  geom_point()+facet_wrap("plotID", ncol=1)+
  ylab("Golden mouse (O nuttalli)")+
  xlab("")+
  scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))+
  theme(text = element_text(size = 18))

PEGO_plot <- ggplot(species_count_selected,
                    aes(x=ymd(paste(year, month, "1", sep="/")), y=PEGO))+
  geom_point()+facet_wrap("plotID", ncol=1)+
  ylab("Cotton mouse (P gossypinus)")+
  xlab("")+
  scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))+
  theme(text = element_text(size = 18))

SIHI_plot <- ggplot(species_count_selected,
                    aes(x=ymd(paste(year, month, "1", sep="/")), y=SIHI))+
  geom_point()+facet_wrap("plotID", ncol=1)+
  ylab("Hispid cotton rat (S hispidus)")+
  xlab("")+
  scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))+
  theme(text = element_text(size = 18))
